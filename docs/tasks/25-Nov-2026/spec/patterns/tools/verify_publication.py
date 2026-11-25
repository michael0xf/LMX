#!/usr/bin/env python3
"""Read-only verification of every published XLSX/PDF against the common model.

XLSX checks read the exported ZIP/XML, including formula caches and active native
conditional-format rules. They do not execute Excel. PDF checks read actual text,
green number spans and underline paths, in addition to the generation receipt.
Page bounds and visual layout are reviewed separately. No LMX execution is claimed.
"""
from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
from io import BytesIO
import json
import math
from pathlib import Path
import posixpath
import re
import sys
import xml.etree.ElementTree as ET
from zipfile import ZipFile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
REL = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
GREEN = "176233"
GREEN_RGB = tuple(int(GREEN[i:i + 2], 16) / 255 for i in (0, 2, 4))
ERROR_VALUE = re.compile(r"^#(?:REF!|DIV/0!|VALUE!|NAME\?|N/A|NUM!|NULL!|SPILL!|CALC!)$")
CF_FORMULA = re.compile(
    r"^=?AND\(ISNUMBER\(([A-Z]+[1-9][0-9]*)\),([A-Z]+[1-9][0-9]*)=MIN\("
    r"(\$[A-Z]+\$[1-9][0-9]*(?:,\$[A-Z]+\$[1-9][0-9]*)*)\)\)$"
)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def numeric(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)


def deprecated_metric(text):
    compact = re.sub(r"[\s_\-]+", "", str(text).casefold())
    return any(label in compact for label in (
        "безсложногоthrows", "безсложныхthrows", "withoutcomplexthrows",
        "withoutcomplicatedthrows", "nocomplexthrows",
    ))


def column(index):
    result = ""
    index += 1
    while index:
        index, digit = divmod(index - 1, 26)
        result = chr(65 + digit) + result
    return result


def address(row, col):
    return f"{column(col)}{row}"


def absolute(cell):
    match = re.fullmatch(r"([A-Z]+)([1-9][0-9]*)", cell)
    if not match:
        raise ValueError(f"Invalid cell address: {cell}")
    return f"${match[1]}${match[2]}"


def one_cell(sqref):
    match = re.fullmatch(r"([A-Z]+[1-9][0-9]*)(?::([A-Z]+[1-9][0-9]*))?", sqref)
    if match and (match[2] is None or match[1] == match[2]):
        return match[1]
    return None


def table_rows(table):
    rows = [(row, bool(table["eligible_rows"][i])) for i, row in enumerate(table["rows"])]
    if table.get("total"):
        rows.append((table["total"]["values"], bool(table["total"]["compare"])))
    return rows


def minimum_columns(table, values, eligible):
    candidates = [col for col in table["comparison_columns"] if numeric(values[col])]
    if not eligible or not candidates:
        return [], []
    minimum = min(values[col] for col in candidates)
    return candidates, [col for col in candidates if values[col] == minimum]


def expected_pdf_green(table):
    result = []
    for row, (values, eligible) in enumerate(table_rows(table)):
        _, winners = minimum_columns(table, values, eligible)
        result.extend({"row": row, "column": col, "value": values[col]} for col in winners)
    return result


class Checks:
    def __init__(self, file=None):
        self.result = {"file": file, "checks": 0, "errors": []} if file else {"checks": 0, "errors": []}

    def check(self, ok, message):
        self.result["checks"] += 1
        if not ok:
            self.result["errors"].append(message)
        return bool(ok)

    def finish(self, **extra):
        self.result.update(extra)
        self.result["status"] = "FAIL" if self.result["errors"] else "PASS"
        return self.result


def xml_value(cell, strings):
    kind = cell.get("t", "n")
    if kind == "inlineStr":
        return "".join(node.text or "" for node in cell.findall("m:is//m:t", NS))
    node = cell.find("m:v", NS)
    if node is None or node.text is None:
        return None
    text = node.text
    if kind == "s":
        return strings[int(text)]
    if kind in ("str", "e", "d"):
        return text
    if kind == "b":
        return text == "1"
    value = float(text)
    return int(value) if math.isfinite(value) and value.is_integer() else value


def green_dxf(dxf):
    color = dxf.find("m:font/m:color", NS)
    bottom = dxf.find("m:border/m:bottom", NS)
    line_color = bottom.find("m:color", NS) if bottom is not None else None
    bold = dxf.find("m:font/m:b", NS)
    return (
        color is not None and color.get("rgb", "").upper()[-6:] == GREEN
        and bold is not None and bold.get("val", "1") not in ("0", "false")
        and bottom is not None and bottom.get("style") == "thin"
        and line_color is not None and line_color.get("rgb", "").upper()[-6:] == GREEN
    )


def workbook_check(root, document, filename, receipt):
    audit = Checks(filename)
    path = root / filename
    if not audit.check(path.is_file(), "Exported XLSX is missing"):
        return audit.finish()
    data = path.read_bytes()
    digest = sha(data)
    audit.check(receipt is not None, "Workbook is missing from the current generation receipt")
    if receipt:
        audit.check(receipt.get("sha256") == digest, "Workbook SHA256 differs from generation receipt")
        audit.check(receipt.get("formula_errors") == 0, "Generation receipt did not record zero formula errors")
    data_cells = count_cells = total_cells = 0
    expected_groups = []
    verified_groups = []
    sheet_names = []
    try:
        with ZipFile(BytesIO(data)) as archive:
            strings = []
            if "xl/sharedStrings.xml" in archive.namelist():
                string_xml = ET.fromstring(archive.read("xl/sharedStrings.xml"))
                strings = ["".join(t.text or "" for t in si.iterfind(".//m:t", NS)) for si in string_xml]
            styles = ET.fromstring(archive.read("xl/styles.xml"))
            dxfs_node = styles.find("m:dxfs", NS)
            dxfs = list(dxfs_node) if dxfs_node is not None else []
            relationships = ET.fromstring(archive.read("xl/_rels/workbook.xml.rels"))
            targets = {r.get("Id"): r.get("Target") for r in relationships}
            workbook = ET.fromstring(archive.read("xl/workbook.xml"))
            sheets = {}
            for sheet in workbook.findall("m:sheets/m:sheet", NS):
                target = targets[sheet.get(f"{{{REL}}}id")]
                target = target.lstrip("/") if target.startswith("/") else posixpath.normpath("xl/" + target)
                sheets[sheet.get("name")] = ET.fromstring(archive.read(target))
            sheet_names = list(sheets)
            expected_names = [sheet["name"] for sheet in document["sheets"]]
            audit.check(sheet_names == expected_names, f"Sheet names/order differ: {sheet_names!r} != {expected_names!r}")
            for name, xml in sheets.items():
                raw_cells = {cell.get("r"): cell for cell in xml.findall("m:sheetData/m:row/m:c", NS)}
                cells = {cell: xml_value(node, strings) for cell, node in raw_cells.items()}
                for cell, node in raw_cells.items():
                    value = cells[cell]
                    audit.check(node.get("t") != "e" and not (isinstance(value, str) and ERROR_VALUE.fullmatch(value)),
                                f"{name}!{cell}: Excel error value {value!r}")
                    audit.check(not isinstance(value, float) or math.isfinite(value),
                                f"{name}!{cell}: non-finite numeric value")
                    if node.find("m:f", NS) is not None:
                        audit.check(node.find("m:v", NS) is not None and value is not None,
                                    f"{name}!{cell}: formula has no cached result")
                    if isinstance(value, str):
                        audit.check(not deprecated_metric(value), f"{name}!{cell}: deprecated Throws metric")
                source_sheet = next((view for view in document["sheets"] if view["name"] == name), None)
                if source_sheet is None:
                    continue
                audit.check(cells.get("A1") == source_sheet["title"], f"{name}!A1: sheet title differs from model")
                expected_rules = {}
                formula_cells = set()
                numeric_cells = set()
                previous_table_end = 0
                for table in source_sheet["tables"]:
                    matches = []
                    for cell, value in cells.items():
                        match = re.fullmatch(r"A([1-9][0-9]*)", cell)
                        if value != table["title"] or not match:
                            continue
                        title_row = int(match[1])
                        if title_row <= previous_table_end:
                            continue
                        if [cells.get(address(title_row + 1, c)) for c in range(len(table["headers"]))] == table["headers"]:
                            matches.append(title_row)
                    if not audit.check(len(matches) == 1, f"{name}/{table['title']}: expected one exact title/header pair, found {len(matches)}"):
                        continue
                    first = matches[0] + 2
                    previous_table_end = first + len(table_rows(table)) - 1
                    header_row = first - 1
                    extra_headers = [cell for cell, value in cells.items() if value is not None
                                     and re.fullmatch(r"[A-Z]+" + str(header_row), cell)
                                     and cell not in {address(header_row, c) for c in range(len(table["headers"]))}]
                    audit.check(not extra_headers, f"{name}/{table['title']}: unexpected extra header columns {extra_headers}")
                    for index, (values, eligible) in enumerate(table_rows(table)):
                        row = first + index
                        for col, expected in enumerate(values):
                            cell = address(row, col)
                            actual = cells.get(cell)
                            data_cells += 1
                            count_cells += int(numeric(expected))
                            if numeric(expected):
                                numeric_cells.add(cell)
                            audit.check(actual == expected and (not numeric(expected) or numeric(actual)),
                                        f"{name}!{cell}: {actual!r} != model {expected!r}")
                        candidates, winners = minimum_columns(table, values, eligible)
                        if not candidates:
                            continue
                        candidate_cells = [address(row, col) for col in candidates]
                        winner_cells = [address(row, col) for col in winners]
                        rules = []
                        refs = ",".join(absolute(cell) for cell in candidate_cells)
                        for cell in candidate_cells:
                            formula = f"=AND(ISNUMBER({cell}),{cell}=MIN({refs}))"
                            expected_rules[cell] = {"formula": formula, "candidates": candidate_cells,
                                                    "winner": cell in winner_cells}
                            rules.append({"cell": cell, "formula": formula})
                        expected_groups.append({"sheet": name, "table": table["title"], "row": row,
                                                "cells": candidate_cells, "expected_winners": winner_cells, "rules": rules})
                    if table.get("total"):
                        total = table["total"]
                        total_row = first + len(table["rows"])
                        for col in total["columns"]:
                            cell = address(total_row, col)
                            formula_cells.add(cell)
                            total_cells += 1
                            refs = [address(first + row, col) for row in total["included_rows"]]
                            formula = f"SUM({','.join(refs)})" if refs else "0"
                            node = raw_cells.get(cell)
                            actual_formula = node.findtext("m:f", default="", namespaces=NS) if node is not None else ""
                            audit.check(actual_formula.lstrip("=") == formula,
                                        f"{name}!{cell}: total formula differs from exact included rows")
                            model_sum = sum(table["rows"][row][col] for row in total["included_rows"])
                            audit.check(model_sum == total["values"][col], f"{name}!{cell}: model total is not sum of included rows")
                            actual_values = [cells.get(ref) for ref in refs]
                            audit.check(all(numeric(value) for value in actual_values), f"{name}!{cell}: total input is not numeric")
                            if all(numeric(value) for value in actual_values):
                                audit.check(cells.get(cell) == sum(actual_values), f"{name}!{cell}: cached total differs from independent SUM")
                actual_formulas = {cell for cell, node in raw_cells.items() if node.find("m:f", NS) is not None}
                audit.check(actual_formulas == formula_cells,
                            f"{name}: formula targets differ; extra={sorted(actual_formulas-formula_cells)}, missing={sorted(formula_cells-actual_formulas)}")
                actual_numeric = {cell for cell, value in cells.items() if numeric(value)}
                audit.check(actual_numeric == numeric_cells,
                            f"{name}: numeric count-cell inventory differs; extra={sorted(actual_numeric-numeric_cells)}, missing={sorted(numeric_cells-actual_numeric)}")
                seen = Counter()
                active_winners = set()
                for formatting in xml.findall("m:conditionalFormatting", NS):
                    cell = one_cell(formatting.get("sqref", ""))
                    for rule in formatting.findall("m:cfRule", NS):
                        if not audit.check(cell is not None and cell in expected_rules,
                                           f"{name}: unexpected conditional-format target {formatting.get('sqref')!r}"):
                            continue
                        seen[cell] += 1
                        expected = expected_rules[cell]
                        formula = rule.findtext("m:formula", default="", namespaces=NS)
                        match = CF_FORMULA.fullmatch(formula)
                        good_formula = bool(match and match[1] == cell and match[2] == cell
                                            and match[3].split(",") == [absolute(ref) for ref in expected["candidates"]])
                        audit.check(rule.get("type") == "expression" and good_formula,
                                    f"{name}!{cell}: conditional-format formula does not compare exactly the eligible cells")
                        dxf_id = rule.get("dxfId", "")
                        valid_dxf = dxf_id.isdigit() and int(dxf_id) < len(dxfs)
                        audit.check(valid_dxf and green_dxf(dxfs[int(dxf_id)]),
                                    f"{name}!{cell}: conditional-format style lacks green bold font / green thin bottom line")
                        if good_formula:
                            values = [cells.get(ref) for ref in expected["candidates"]]
                            values = [value for value in values if numeric(value)]
                            if numeric(cells.get(cell)) and values and cells[cell] == min(values):
                                active_winners.add(cell)
                audit.check(set(seen) == set(expected_rules),
                            f"{name}: conditional-format coverage differs; missing={sorted(set(expected_rules)-set(seen))}")
                audit.check(all(count == 1 for count in seen.values()), f"{name}: repeated conditional-format rules on the same count cell")
                expected_active = {cell for cell, info in expected_rules.items() if info["winner"]}
                audit.check(active_winners == expected_active,
                            f"{name}: active green winners differ; missing={sorted(expected_active-active_winners)}, extra={sorted(active_winners-expected_active)}")
                for group in [group for group in expected_groups if group["sheet"] == name]:
                    verified_groups.append({key: value for key, value in group.items() if key != "rules"} | {
                        "actual_winners": [cell for cell in group["cells"] if cell in active_winners]})
    except Exception as exc:
        audit.check(False, f"XLSX ZIP/XML verification failed: {type(exc).__name__}: {exc}")
    if receipt:
        audit.check(receipt.get("comparison_groups") == expected_groups,
                    "Generation comparison_groups differ from groups independently recovered from model and worksheet headers")
        audit.check(receipt.get("checked_cells") == data_cells, "Generation checked_cells differs from independently checked data cells")
        audit.check(receipt.get("formula_totals") == total_cells, "Generation formula_totals differs from model")
        audit.check(receipt.get("sheets") == sheet_names, "Generation sheet inventory differs from exported XLSX")
    return audit.finish(sha256=digest, data_cells=data_cells, numeric_count_cells=count_cells,
                        formula_totals=total_cells, sheets=sheet_names, comparison_groups=verified_groups,
                        green_winner_cells=sum(len(g["expected_winners"]) for g in expected_groups),
                        tied_groups=sum(len(g["expected_winners"]) > 1 for g in expected_groups))


def pdf_check(root, document, filename, receipt, table_receipts):
    audit = Checks(filename)
    path = root / filename
    if not audit.check(path.is_file(), "Exported PDF is missing"):
        return audit.finish()
    data = path.read_bytes()
    digest = sha(data)
    audit.check(receipt is not None, "PDF is missing from the current generation receipt")
    if receipt and receipt.get("sha256") is not None:
        audit.check(receipt["sha256"] == digest, "PDF SHA256 differs from generation receipt")
    expected_green = []
    numeric_counts = Counter()
    table_count = 0
    for view in document["sheets"]:
        for table in view["tables"]:
            table_count += 1
            expected = expected_pdf_green(table)
            expected_green.extend(expected)
            for values, _ in table_rows(table):
                numeric_counts.update(str(value) for value in values if numeric(value))
            reports = [record for record in table_receipts if record.get("file") == document["stem"] + ".pdf"
                       and record.get("sheet") == view["name"] and record.get("table") == table["title"]]
            if audit.check(len(reports) == 1, f"{view['name']}/{table['title']}: expected exactly one PDF table receipt"):
                record = reports[0]
                audit.check(record.get("green_cells") == expected,
                            f"{view['name']}/{table['title']}: reported green cells differ from independently calculated minima, including ties")
                audit.check(record.get("rows") == len(table["rows"]), f"{view['name']}/{table['title']}: PDF receipt row count differs")
                audit.check(record.get("minimum_basis") == "full source characters", f"{view['name']}/{table['title']}: wrong metric basis")
    pages = 0
    green_spans = []
    underline_count = 0
    text = ""
    try:
        import fitz
        with fitz.open(stream=data, filetype="pdf") as pdf:
            pages = len(pdf)
            spans = []
            for page_number, page in enumerate(pdf, 1):
                text += page.get_text() + "\n"
                page_spans = [span for block in page.get_text("dict")["blocks"] if "lines" in block
                              for line in block["lines"] for span in line["spans"]]
                spans.extend(page_spans)
                lines = []
                for drawing in page.get_drawings():
                    color = drawing.get("color")
                    if color and len(color) == 3 and max(abs(a-b) for a, b in zip(color, GREEN_RGB)) < .002:
                        lines.extend(item for item in drawing["items"] if item[0] == "l")
                underline_count += len(lines)
                for span in page_spans:
                    if span.get("color") != int(GREEN, 16):
                        continue
                    green_spans.append({"page": page_number, "value": span["text"].strip()})
                    x0, y0, x1, y1 = span["bbox"]
                    underline = any(abs(start.x - x0) < .2 and abs(end.x - x1) < .2
                                    and abs(start.y - end.y) < .1 and y0 <= start.y <= y1 + 1
                                    for _, start, end in lines)
                    audit.check(underline, f"Page {page_number}: green number {span['text']!r} has no matching underline")
            actual_numbers = Counter(span["text"].strip() for span in spans)
            missing_numbers = numeric_counts - actual_numbers
            audit.check(not missing_numbers, f"Actual PDF text lacks model count occurrences: {dict(missing_numbers)}")
        audit.check(pages > 0, "PDF has no pages")
        audit.check(not deprecated_metric(text), "Actual PDF text contains the deprecated complex-Throws metric")
        actual_green = Counter(span["value"] for span in green_spans)
        wanted_green = Counter(str(cell["value"]) for cell in expected_green)
        audit.check(actual_green == wanted_green,
                    f"Actual green PDF numbers differ from model winners; missing={dict(wanted_green-actual_green)}, extra={dict(actual_green-wanted_green)}")
        audit.check(underline_count == len(expected_green),
                    f"Actual green underline count {underline_count} differs from model winner count {len(expected_green)}")
        normalized_text = re.sub(r"\s+", "", text)
        for view in document["sheets"]:
            for table in view["tables"]:
                for header in table["headers"]:
                    audit.check(re.sub(r"\s+", "", header) in normalized_text,
                                f"Actual PDF text lacks model header {header!r}")
    except Exception as exc:
        audit.check(False, f"PDF content verification failed: {type(exc).__name__}: {exc}")
    return audit.finish(sha256=digest, pages=pages, tables=table_count,
                        expected_green_cells=len(expected_green), actual_green_spans=len(green_spans),
                        actual_green_underlines=underline_count, text_sha256=sha(text.encode()))


def load_receipt(root, name, model_hash, expected_files, global_checks):
    path = root / name
    if not global_checks.check(path.is_file(), f"Missing publication generation report: {name}"):
        return {}, {"file": name, "status": "MISSING"}
    data = path.read_bytes()
    try:
        report = json.loads(data)
    except (ValueError, UnicodeError) as exc:
        global_checks.check(False, f"Cannot read generation report {name}: {exc}")
        return {}, {"file": name, "sha256": sha(data), "status": "INVALID"}
    global_checks.check(report.get("source") == "PUBLICATION_DATA.json", f"{name}: wrong source model")
    global_checks.check(report.get("source_sha256") == model_hash, f"{name}: stale source model SHA256")
    files = [item.get("file") for item in report.get("files", [])]
    global_checks.check(Counter(files) == Counter(expected_files),
                        f"{name}: output inventory differs; missing={sorted(set(expected_files)-set(files))}, extra={sorted(set(files)-set(expected_files))}")
    global_checks.check(report.get("lmx_runtime_execution") == "NOT_RUN", f"{name}: unexpected LMX execution claim")
    return report, {"file": name, "sha256": sha(data), "source_sha256": report.get("source_sha256")}


def verify(root):
    global_checks = Checks()
    model_path = root / "PUBLICATION_DATA.json"
    model_bytes = model_path.read_bytes()
    model = json.loads(model_bytes)
    model_hash = sha(model_bytes)
    global_checks.check(not model.get("errors"), "Common publication model contains errors")
    global_checks.check(not deprecated_metric(model_bytes.decode()), "Common publication model contains a deprecated Throws metric")
    global_checks.check(model.get("lmx_parser_execution") == "NOT_RUN" and model.get("lmx_runtime_execution") == "NOT_RUN",
                        "Common model has an unexpected LMX execution claim")
    documents = {doc["stem"]: doc for doc in model["documents"]}
    outputs = [(doc["stem"], doc, None) for doc in model["documents"]]
    for mirror in model.get("mirrors", []):
        outputs.append((mirror["target"], documents[mirror["source"]], mirror["source"]))
    expected_outputs=len(model['documents'])+len(model.get('mirrors',[]))
    global_checks.check(len(outputs)==len({stem for stem, _, _ in outputs})==expected_outputs,
                        "Every declared document and mirror must have one distinct exported pair")
    receipts = {}
    receipt_info = {}
    for kind, suffix, filename in (
        ("workbooks", ".xlsx", "validation/workbook_publication_20261123.json"),
        ("pdfs", ".pdf", "validation/pdf_generation_20261123.json"),
    ):
        receipts[kind], receipt_info[kind] = load_receipt(root, filename, model_hash,
                                                       [stem + suffix for stem, _, _ in outputs], global_checks)
    expected_pdf_tables = Counter((doc["stem"] + ".pdf", view["name"], table["title"])
                                 for doc in model["documents"] for view in doc["sheets"] for table in view["tables"])
    actual_pdf_tables = Counter((record.get("file"), record.get("sheet"), record.get("table"))
                               for record in receipts["pdfs"].get("tables", []))
    global_checks.check(expected_pdf_tables == actual_pdf_tables, "PDF generation table inventory differs from all primary model tables")
    workbooks, pdfs = [], []
    for stem, document, mirror in outputs:
        workbook_receipt = next((record for record in receipts["workbooks"].get("files", []) if record.get("file") == stem + ".xlsx"), None)
        pdf_receipt = next((record for record in receipts["pdfs"].get("files", []) if record.get("file") == stem + ".pdf"), None)
        workbooks.append(workbook_check(root, document, stem + ".xlsx", workbook_receipt))
        pdfs.append(pdf_check(root, document, stem + ".pdf", pdf_receipt, receipts["pdfs"].get("tables", [])))
        if mirror:
            for suffix, receipt in ((".xlsx", workbook_receipt), (".pdf", pdf_receipt)):
                a, b = root / (stem + suffix), root / (mirror + suffix)
                global_checks.check(a.is_file() and b.is_file() and a.read_bytes() == b.read_bytes(),
                                    f"Mirror {stem+suffix} is not byte-identical to {mirror+suffix}")
                global_checks.check(receipt is not None and receipt.get("byte_identical_to") == mirror + suffix,
                                    f"Mirror receipt {stem+suffix} lacks its canonical source")
    global_checks.check(model_path.read_bytes() == model_bytes, "Publication model changed during verification; rerun after generation")
    for info in receipt_info.values():
        if info.get("sha256"):
            global_checks.check(sha((root / info["file"]).read_bytes()) == info["sha256"],
                                f"{info['file']} changed during verification; rerun after generation")
    for result in workbooks + pdfs:
        if result.get("sha256"):
            global_checks.check(sha((root / result["file"]).read_bytes()) == result["sha256"],
                                f"{result['file']} changed during verification; rerun after generation")
    failed = [record["file"] for record in workbooks + pdfs if record["status"] != "PASS"]
    report = global_checks.finish(schema_version=1, generated_utc=datetime.now(timezone.utc).isoformat(),
        source="PUBLICATION_DATA.json", source_sha256=model_hash, generation_reports=receipt_info,
        verifier={"file": "tools/verify_publication.py", "sha256": sha(Path(__file__).read_bytes())},
        summary={"expected_workbooks": expected_outputs, "verified_workbooks": len(workbooks),
                 "passed_workbooks": sum(row["status"] == "PASS" for row in workbooks),
                 "expected_pdfs": expected_outputs, "verified_pdfs": len(pdfs),
                 "passed_pdfs": sum(row["status"] == "PASS" for row in pdfs),
                 "data_cells": sum(row.get("data_cells", 0) for row in workbooks),
                 "numeric_count_cells": sum(row.get("numeric_count_cells", 0) for row in workbooks),
                 "formula_totals": sum(row.get("formula_totals", 0) for row in workbooks),
                 "green_xlsx_winner_cells": sum(row.get("green_winner_cells", 0) for row in workbooks),
                 "tied_xlsx_groups": sum(row.get("tied_groups", 0) for row in workbooks),
                 "failed_files": failed},
        workbooks=workbooks, pdfs=pdfs, lmx_parser_execution="NOT_RUN", lmx_runtime_execution="NOT_RUN",
        native_excel_execution="NOT_RUN",
        scope="Read-only exported ZIP/XML values, exact SUM formulas/caches, native CF targets/formulas/dxfs and every equal minimum; PDF generation table minima plus actual text, green count spans and underlines. Visual page/sheet bounds are reviewed separately.")
    if failed:
        report["status"] = "FAIL"
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--output", type=Path, help="Default: ROOT/validation/publication_checks.json")
    args = parser.parse_args()
    root = args.root.resolve()
    report = verify(root)
    output = args.output or root / "validation/publication_checks.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"status": report["status"], **report["summary"], "global_errors": report["errors"],
                      "report": str(output)}, ensure_ascii=False))
    return 0 if report["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())

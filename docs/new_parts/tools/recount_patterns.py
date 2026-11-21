#!/usr/bin/env python3
"""Recount and validate the nine extended LMX pattern groups.

Run from the unpacked archive root (or use the script's absolute path elsewhere):
    python tools/recount_patterns.py
    python tools/recount_patterns.py --json recount-report.json
    python tools/recount_patterns.py --root path/to/new_parts --json report.json

Only Python's standard library is used. This checks publication consistency,
not language semantics or execution of the example programs. XLSX is checked
for a valid workbook ZIP container; PDF for file presence/signature. Workbook
cell calculations and page rendering remain separate validation tasks.
"""
from __future__ import annotations

import argparse
import codecs
import csv
import io
import json
import re
import sys
import zipfile
from collections import Counter
from pathlib import Path

LANGUAGES = {
    "LMX": ("lmx", "lm3", "lmx"),
    "TypeScript": ("typescript", "ts", "typescript"),
    "C#": ("csharp", "cs", "csharp"),
    "Java": ("java", "java", "java"),
    "Go": ("go", "go", "go"),
    "Python": ("python", "py", "python"),
    "Erlang": ("erlang", "erl", "erlang"),
    "Rust": ("rust", "rs", "rust"),
    "Haskell": ("haskell", "hs", "haskell"),
    "Scala": ("scala", "scala", "scala"),
}
SCOPES_RU = {
    "core": "Ядро сценария",
    "protocol": "Протокол и порты",
    "executable": "Самостоятельный пример",
}


def canonical_code(code: str) -> str:
    """Exactly the normalization used for the published source files."""
    return code.strip() + "\n"


def metrics(code: str) -> dict[str, int]:
    return {
        "nonwhitespace_characters": sum(not ch.isspace() for ch in code),
        "nonblank_lines": sum(bool(line.strip()) for line in code.splitlines()),
        "utf8_bytes": len(code.encode("utf-8")),
    }


def fenced_blocks(text: str) -> tuple[list[tuple[str, str]], bool]:
    """Read unindented Markdown fences; preserve code whitespace exactly."""
    blocks = []
    fence = None
    language = ""
    body: list[str] = []
    for line in text.splitlines(keepends=True):
        if fence is None:
            found = re.match(r"^ {0,3}(`{3,}|~{3,})([^\r\n]*)\r?\n?$", line)
            if found:
                fence = found.group(1)
                language = found.group(2).strip()
                body = []
        else:
            closing = re.match(r"^ {0,3}([`~]+)[ \t]*\r?\n?$", line)
            if closing and set(closing.group(1)) == {fence[0]} and len(closing.group(1)) >= len(fence):
                blocks.append((language, "".join(body)))
                fence = None
            else:
                body.append(line)
    return blocks, fence is None


def split_table_row(line: str) -> list[str]:
    """The generated comparison tables have no unescaped pipes in cells."""
    return [part.strip() for part in re.split(r"(?<!\\)\|", line.strip())[1:-1]]


def audit(root: Path) -> dict:
    errors: list[dict[str, str]] = []
    groups = []
    all_ids: list[int] = []
    listing_count = 0
    total_bytes = 0
    pattern_ids = []
    implementation_ids = []
    try:
        manifest=json.loads((root/'comparison_sources/catalog_manifest.json').read_text(encoding='utf-8'))
        expected_ids=set(manifest['pattern_ids'])|set(manifest['implementation_ids'])
        assert manifest['pattern_ids']==list(range(1,91))
    except (OSError,ValueError,KeyError,AssertionError) as exc:
        return {'ok':False,'error_count':1,'errors':[{'file':'comparison_sources/catalog_manifest.json','message':str(exc)}]}

    def relative(path: Path) -> str:
        try:
            return path.relative_to(root).as_posix()
        except ValueError:
            return path.name

    def fail(path: Path, message: str) -> None:
        errors.append({"file": relative(path), "message": message})

    def read_text(path: Path) -> str | None:
        try:
            return path.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as exc:
            fail(path, f"Cannot read UTF-8 text: {exc.__class__.__name__}: {exc}")
            return None

    json_files = sorted(root.glob("[0-9][0-9]_*/patterns.json"))
    if len(json_files) != 9:
        fail(root, f"Expected 9 group patterns.json files; found {len(json_files)}")

    for json_file in json_files:
        directory = json_file.parent
        group_name = directory.name
        raw = read_text(json_file)
        if raw is None:
            continue
        try:
            data = json.loads(raw)
        except json.JSONDecodeError as exc:
            fail(json_file, f"Invalid JSON: {exc}")
            continue
        controls = data.get("languages", [])
        if not isinstance(controls, list) or len(controls) != 2 or len(set(controls)) != 2 or "LMX" in controls:
            fail(json_file, "languages must contain exactly two different controls, without LMX")
            continue
        language_order = ["LMX"] + controls
        if any(language not in LANGUAGES for language in language_order):
            fail(json_file, f"Unsupported language mapping: {language_order}")
            continue
        patterns = data.get("patterns", [])
        if not isinstance(patterns, list):
            fail(json_file, "patterns is not a list")
            continue

        expected_csv = []
        expected_markdown: set[str] = set()
        expected_sources: set[str] = set()
        pattern_reports = []
        comparison_path = directory / f"LMX_Comparison_{group_name}.md"
        comparison_text = read_text(comparison_path)
        comparison_rows = {}
        if comparison_text is not None:
            for line in comparison_text.splitlines():
                if re.match(r"^\|\s*\d+\s*\|", line):
                    cells = split_table_row(line)
                    if cells:
                        key = int(cells[0])
                        if key in comparison_rows:
                            fail(comparison_path, f"Duplicate table row for ID {key}")
                        comparison_rows[key] = cells

        for pattern in sorted(patterns,key=lambda p:(p.get('paired_with',p['id']),p.get('kind','pattern')=='implementation',p['id'])):
            if not isinstance(pattern, dict):
                fail(json_file, "A pattern is not an object")
                continue
            identifier = pattern.get("id")
            if type(identifier) is not int:
                fail(json_file, f"Non-integer pattern ID: {identifier!r}")
                continue
            all_ids.append(identifier)
            record_kind=pattern.get('kind','pattern')
            record_layer='implementation' if record_kind=='implementation' else 'usage' if pattern.get('implementation_ids') else 'scenario'
            if record_kind=='implementation':
                implementation_ids.append(identifier)
                if pattern.get('paired_with') not in range(1,91): fail(json_file,f'ID {identifier}: invalid paired_with')
            elif record_kind=='pattern': pattern_ids.append(identifier)
            else: fail(json_file,f'ID {identifier}: unknown kind {record_kind!r}')
            slug = pattern.get("slug", "")
            if not isinstance(slug, str) or not re.fullmatch(r"[a-z0-9][a-z0-9_]*", slug):
                fail(json_file, f"Invalid ASCII snake_case slug for ID {identifier}: {slug!r}")
                continue
            stem = f"{identifier:03d}_{slug}"
            markdown_name = stem + "_comparision.md"
            expected_markdown.add(markdown_name)
            markdown_path = directory / markdown_name
            markdown_text = read_text(markdown_path)
            blocks = []
            if markdown_text is not None:
                blocks, closed = fenced_blocks(markdown_text)
                if not closed:
                    fail(markdown_path, "Unclosed Markdown code fence")
                if len(blocks) != 3:
                    fail(markdown_path, f"Expected exactly 3 fenced code blocks; found {len(blocks)}")

            listings = pattern.get("listings", [])
            actual_order = [x.get("language") for x in listings if isinstance(x, dict)] if isinstance(listings, list) else []
            if actual_order != language_order:
                fail(json_file, f"ID {identifier}: listing order {actual_order} differs from {language_order}")
                continue

            csv_row = {
                "id": str(identifier),
                "pattern": pattern.get("name", ""),
                "scope": pattern.get("scope", ""),
                "kind":record_kind,
                "layer":record_layer,
                "source": markdown_name,
            }
            measured = {}
            for position, listing in enumerate(listings):
                language = listing["language"]
                code = listing.get("code")
                if not isinstance(code, str) or not code.strip():
                    fail(json_file, f"ID {identifier}/{language}: missing or empty code")
                    continue
                normalized = canonical_code(code)
                counts = metrics(normalized)
                measured[language] = counts
                listing_count += 1
                total_bytes += counts["utf8_bytes"]
                folder, extension, fence_language = LANGUAGES[language]
                source_path = directory / "examples" / folder / f"{stem}.{extension}"
                expected_sources.add(source_path.relative_to(directory).as_posix())
                try:
                    actual_bytes = source_path.read_bytes()
                    if actual_bytes != normalized.encode("utf-8"):
                        fail(source_path, f"ID {identifier}/{language}: source differs from code.strip() + LF")
                except OSError as exc:
                    fail(source_path, f"Cannot read source: {exc.__class__.__name__}: {exc}")
                if position < len(blocks):
                    found_language, found_code = blocks[position]
                    if found_language != fence_language:
                        fail(markdown_path, f"ID {identifier}: fence {position+1} is {found_language!r}, expected {fence_language!r}")
                    if found_code != normalized:
                        fail(markdown_path, f"ID {identifier}/{language}: fenced code differs from the canonical source")
                if markdown_text is not None:
                    expected_line = f"| {language} | {counts['nonwhitespace_characters']} | {counts['nonblank_lines']} |"
                    if expected_line not in markdown_text.splitlines():
                        fail(markdown_path, f"ID {identifier}/{language}: missing or stale source-size table row")
                    source_link = source_path.relative_to(directory).as_posix()
                    if f"]({source_link})" not in markdown_text:
                        fail(markdown_path, f"ID {identifier}/{language}: missing exact source link {source_link}")
                csv_row[f"{language}_characters"] = str(counts["nonwhitespace_characters"])
                csv_row[f"{language}_nonblank_lines"] = str(counts["nonblank_lines"])
                csv_row[f"{language}_utf8_bytes"] = str(counts["utf8_bytes"])
            expected_csv.append(csv_row)
            pattern_reports.append({"id": identifier, "name": pattern.get("name"),"kind":record_kind,"layer":record_layer, "source": markdown_name, "metrics": measured})

            if comparison_text is not None:
                cells = comparison_rows.get(identifier)
                if cells is None:
                    fail(comparison_path, f"Missing group table row for ID {identifier}")
                elif len(cells) != 6:
                    fail(comparison_path, f"ID {identifier}: expected 6 table cells, found {len(cells)}")
                else:
                    if f"]({markdown_name})" not in cells[1]:
                        fail(comparison_path, f"ID {identifier}: wrong source Markdown link")
                    for offset, language in enumerate(language_order, start=2):
                        if language in measured:
                            value = measured[language]
                            expected_value = f"{value['nonwhitespace_characters']} / {value['nonblank_lines']}"
                            if cells[offset] != expected_value:
                                fail(comparison_path, f"ID {identifier}/{language}: table says {cells[offset]!r}, expected {expected_value!r}")
                    scope_label = {'implementation':'Реализация библиотеки','usage':'Использование библиотеки'}.get(record_layer,SCOPES_RU.get(pattern.get("scope")))
                    if scope_label is not None and cells[5] != scope_label:
                        fail(comparison_path, f"ID {identifier}: unexpected scope label {cells[5]!r}")

        actual_markdown = {p.name for p in directory.glob("*_comparision.md")}
        if actual_markdown != expected_markdown:
            fail(directory, f"Pattern Markdown set mismatch: missing={sorted(expected_markdown-actual_markdown)}, extra={sorted(actual_markdown-expected_markdown)}")
        actual_sources = {p.relative_to(directory).as_posix() for p in (directory / "examples").glob("*/*") if p.is_file() and re.match(r"^\d{3}_", p.name)}
        if actual_sources != expected_sources:
            fail(directory / "examples", f"Source set mismatch: missing={sorted(expected_sources-actual_sources)}, extra={sorted(actual_sources-expected_sources)}")
        if comparison_text is not None and set(comparison_rows) != {x["id"] for x in pattern_reports}:
            fail(comparison_path, "Group Markdown table IDs differ from patterns.json")

        csv_path = directory / f"LMX_Comparison_{group_name}.csv"
        try:
            csv_bytes = csv_path.read_bytes()
            if not csv_bytes.startswith(codecs.BOM_UTF8):
                fail(csv_path, "CSV is missing its UTF-8 BOM")
            reader = csv.DictReader(io.StringIO(csv_bytes.decode("utf-8-sig"), newline=""))
            header = reader.fieldnames or []
            required_header = ["id", "pattern", "scope","kind","layer"] + [f"{l}_characters" for l in language_order] + [f"{l}_nonblank_lines" for l in language_order] + ["source"]
            optional_header = {f"{l}_utf8_bytes" for l in language_order}
            if [h for h in header if h not in optional_header] != required_header:
                fail(csv_path, f"Unexpected CSV header: {header}")
            rows = list(reader)
            if len(rows) != len(expected_csv):
                fail(csv_path, f"Expected {len(expected_csv)} CSV rows, found {len(rows)}")
            for position, (actual, expected) in enumerate(zip(rows, expected_csv), start=2):
                for key in header:
                    if key in expected and actual.get(key) != expected[key]:
                        fail(csv_path, f"Row {position}, {key}: {actual.get(key)!r} != {expected[key]!r}")
                if None in actual:
                    fail(csv_path, f"Row {position} has extra unheaded cells")
        except (OSError, UnicodeError, csv.Error) as exc:
            fail(csv_path, f"Cannot validate CSV: {exc.__class__.__name__}: {exc}")

        promised = ["README.md", "LMX_Design_Patterns.ru.md", "LMX_Design_Patterns.en.md"] + [f"LMX_Comparison_{group_name}.{extension}" for extension in ("md", "csv", "xlsx", "pdf")]
        for name in promised:
            path = directory / name
            if not path.is_file() or path.stat().st_size == 0:
                fail(path, "Missing or empty promised deliverable")
        xlsx = directory / f"LMX_Comparison_{group_name}.xlsx"
        if xlsx.is_file():
            try:
                with zipfile.ZipFile(xlsx) as workbook:
                    damaged = workbook.testzip()
                    if damaged:
                        fail(xlsx, f"Damaged ZIP member: {damaged}")
                    for member in ("[Content_Types].xml", "xl/workbook.xml"):
                        if member not in workbook.namelist():
                            fail(xlsx, f"Missing workbook member {member}")
            except (OSError, zipfile.BadZipFile) as exc:
                fail(xlsx, f"Invalid XLSX container: {exc}")
        pdf = directory / f"LMX_Comparison_{group_name}.pdf"
        if pdf.is_file():
            try:
                pdf_bytes = pdf.read_bytes()
                if not pdf_bytes.startswith(b"%PDF-") or b"%%EOF" not in pdf_bytes[-2048:]:
                    fail(pdf, "Missing PDF header or final EOF marker")
            except OSError as exc:
                fail(pdf, f"Cannot read PDF: {exc}")
        groups.append({"directory": group_name, "languages": language_order, "pattern_count":sum(p['kind']=='pattern' for p in pattern_reports),"implementation_count":sum(p['kind']=='implementation' for p in pattern_reports),"comparison_count": len(pattern_reports), "patterns": pattern_reports})

    seen = Counter(all_ids)
    missing = sorted(expected_ids - set(seen))
    extra = sorted(set(seen) - expected_ids)
    duplicates = {str(k): v for k, v in sorted(seen.items()) if v != 1}
    if missing or extra or duplicates:
        fail(root, f"Catalog IDs must occur exactly once: missing={missing}, extra={extra}, duplicates={duplicates}")
    if sorted(pattern_ids)!=list(range(1,91)): fail(root,'Original 90 pattern IDs/kinds were changed')
    if sorted(implementation_ids)!=manifest['implementation_ids']: fail(root,'Implementation IDs/kinds differ from manifest')
    if listing_count != 3*len(expected_ids):
        fail(root, f"Expected {3*len(expected_ids)} listings; found {listing_count}")
    return {
        "ok": not errors,
        "scope": "Publication consistency and mechanical code counts. No claim of LMX execution, adapter guarantees, XLSX formula evaluation or PDF visual QA.",
        "method": {
            "source_normalization": "code.strip() + '\\n', UTF-8 with LF",
            "nonwhitespace_characters": "Unicode code points for which str.isspace() is false; comments and string literals are included",
            "nonblank_lines": "splitlines() entries with nonempty strip()",
            "utf8_bytes": "len(canonical_source.encode('utf-8')) including spaces and the final LF",
            "csv": "UTF-8 BOM required; *_utf8_bytes columns are checked if present, otherwise bytes remain in this report",
        },
        "group_count": len(json_files),
        "pattern_count": len(pattern_ids),
        "implementation_count":len(implementation_ids),
        "comparison_count":len(all_ids),
        "listing_count": listing_count,
        "total_source_utf8_bytes": total_bytes,
        "error_count": len(errors),
        "errors": errors,
        "groups": groups,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent, help="Archive root; defaults to the parent of this tools directory")
    parser.add_argument("--json", type=Path, help="Also save the JSON report to this path")
    args = parser.parse_args()
    report = audit(args.root.resolve())
    payload = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(payload, encoding="utf-8")
    sys.stdout.write(payload)
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())

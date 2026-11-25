#!/usr/bin/env python3
"""Recount and validate every registered LMX pattern/algorithm group.

Run from the unpacked archive root (or use the script's absolute path elsewhere):
    python tools/recount_patterns.py
    python tools/recount_patterns.py --json recount-report.json
    python tools/recount_patterns.py --root path/to/spec/patterns --json report.json
    python tools/recount_patterns.py --sources-only --json source-report.json

Only Python's standard library is used. This checks publication consistency,
not language semantics or execution of the example programs. --sources-only
checks JSON, complete source boundaries, and Markdown code without requiring the
publication tables/artifacts to have been regenerated yet. XLSX is checked
for a valid workbook ZIP container; PDF for file presence/signature. Workbook
cell calculations and page rendering remain separate validation tasks.
"""
from __future__ import annotations

import argparse
from lmx_style_variants import measure, normalize, validate_variants
import codecs
import csv
import hashlib
import html
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
    "C++": ("cpp", "cpp", "cpp"),
    "JavaScript": ("javascript", "js", "javascript"),
}
SCOPES_RU = {
    "core": "Ядро сценария",
    "protocol": "Протокол и порты",
    "executable": "Самостоятельный пример",
}


def canonical_code(code: str) -> str:
    """Exactly the normalization used for the published source files."""
    return normalize(code)


def historical_code(alternative: dict) -> str:
    """Show required context before the separately retained original client."""
    prefix = alternative.get('context_prefix', '')
    return (canonical_code(prefix) + '\n' if prefix else '') + canonical_code(alternative['code'])


PROCEDURAL_BEGIN = "# BEGIN PROCEDURAL LMX (excluded from character counts)"
PROCEDURAL_END = "# END PROCEDURAL LMX"
ALTERNATIVE_BEGIN = "# BEGIN ALTERNATIVE LMX (excluded from character counts)"
ALTERNATIVE_END = "# END ALTERNATIVE LMX"


def source_parts(text: str) -> tuple[str, str | None]:
    """Count the current listing, retaining the archived original for review."""
    begin,end = (ALTERNATIVE_BEGIN,ALTERNATIVE_END) if ALTERNATIVE_BEGIN in text else (PROCEDURAL_BEGIN,PROCEDURAL_END)
    if begin not in text:
        return text, None
    primary, archive = text.split(begin, 1)
    if end not in archive:
        raise ValueError("Missing end of the alternative LMX listing")
    archive, tail = archive.split(end, 1)
    if tail.strip():
        raise ValueError("Unexpected content after the procedural LMX archive")
    lines = archive.strip("\r\n").splitlines()
    if any(not line.startswith("# ") and line != "#" for line in lines):
        raise ValueError("Procedural LMX must be entirely commented out")
    old = "\n".join(line[2:] if line.startswith("# ") else "" for line in lines)
    return canonical_code(primary), canonical_code(old)


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


KINDS = {"pattern": "pattern_ids", "algorithm": "algorithm_ids",
         "implementation": "implementation_ids"}
STYLES = ("procedural", "functional")
STYLE_LABELS = {"procedural": "LMX — процедурный", "functional": "LMX — функциональный"}
SOURCE_SUFFIXES = {"." + spec[1] for spec in LANGUAGES.values()} | {".lmx", ".mjs", ".cjs"}


def plain_cell(value: object) -> str:
    """Ignore visual winner decoration, never discard a numeric value."""
    return html.unescape(re.sub(r"<[^>]*>", "", str(value))).replace("**", "").strip()


def table_rows(text: str) -> list[list[str]]:
    return [[plain_cell(value) for value in split_table_row(line)]
            for line in text.splitlines() if line.startswith("|")]


def audit(root: Path, *, sources_only: bool = False) -> dict:
    """Recount registered complete boundaries. This never edits any source file."""
    root = root.resolve()
    errors, groups = [], []
    observed = {}
    physical_sources = set()
    listing_count = compatibility_listing_count = total_bytes = 0
    style_ids = []
    kind_ids = {kind: [] for kind in KINDS}

    def relative(path):
        try:
            return Path(path).resolve().relative_to(root).as_posix()
        except ValueError:
            return str(path)

    def fail(path, message):
        errors.append({"file": relative(path), "message": message})

    def read_text(path):
        try:
            return path.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as exc:
            fail(path, f"Cannot read UTF-8 text: {exc}")
            return None

    def read_json(path):
        raw = read_text(path)
        if raw is not None:
            try:
                return json.loads(raw)
            except json.JSONDecodeError as exc:
                fail(path, f"Invalid JSON: {exc}")
        return None

    manifest_path = root / "comparison_sources/catalog_manifest.json"
    manifest = read_json(manifest_path) or {}
    catalog = {}
    declared_ids = set()
    for kind, key in KINDS.items():
        values = manifest.get(key, [])
        if (not isinstance(values, list) or any(type(value) is not int for value in values)
                or len(values) != len(set(values))):
            fail(manifest_path, f"{key} must contain distinct integer IDs")
            continue
        if declared_ids.intersection(values):
            fail(manifest_path, f"ID kinds overlap in {key}")
        declared_ids.update(values)
    entries = manifest.get("comparisons", [])
    if not isinstance(entries, list) or not entries:
        fail(manifest_path, "comparisons must be a nonempty array")
        entries = []
    for entry in entries:
        if not isinstance(entry, dict) or type(entry.get("id")) is not int:
            fail(manifest_path, "Every catalog comparison requires an integer ID")
            continue
        identifier = entry["id"]
        if identifier in catalog:
            fail(manifest_path, f"Duplicate catalog ID {identifier}")
        catalog[identifier] = entry
        kind = entry.get("kind")
        if kind not in KINDS or identifier not in manifest.get(KINDS.get(kind, ""), []):
            fail(manifest_path, f"ID {identifier}: kind disagrees with the catalog ID lists")
        if not re.fullmatch(r"[0-9]{2}_[A-Za-z0-9_]+", str(entry.get("directory", ""))):
            fail(manifest_path, f"ID {identifier}: invalid group directory")
    if set(catalog) != declared_ids:
        fail(manifest_path, "Catalog comparison IDs differ from its kind ID lists")

    documents, published_groups = {}, {}
    publication_path = root / "PUBLICATION_DATA.json"
    if not sources_only:
        publication = read_json(publication_path) or {}
        documents = {item.get("stem"): item for item in publication.get("documents", [])}
        published_groups = {item.get("directory"): item for item in publication.get("groups", [])}
        for key in ("lmx_parser_execution", "lmx_runtime_execution"):
            if publication.get(key) != "NOT_RUN":
                fail(publication_path, f"{key} must remain NOT_RUN without an execution receipt")

    json_files = sorted(root.glob("[0-9][0-9]_*/patterns.json"))
    actual_directories = {path.parent.name for path in json_files}
    expected_directories = {entry.get("directory") for entry in catalog.values()}
    if actual_directories != expected_directories:
        fail(manifest_path, f"Group inventory differs: missing={sorted(expected_directories-actual_directories)}, "
                            f"extra={sorted(actual_directories-expected_directories)}")

    for json_file in json_files:
        directory = json_file.parent
        data = read_json(json_file)
        if not isinstance(data, dict):
            continue
        records = data.get("patterns", [])
        if not isinstance(records, list) or any(not isinstance(record, dict) for record in records):
            fail(json_file, "patterns must be an array of records")
            continue
        controls = data.get("languages", [])
        if (not isinstance(controls, list) or len(controls) < 2
                or any(not isinstance(language, str) for language in controls)
                or len(set(controls)) != len(controls) or "LMX" in controls
                or any(language not in LANGUAGES for language in controls)):
            fail(json_file, "languages must declare the distinct supported foreign language union")
            continue
        expected_sources, expected_pages = set(), set()
        group_reports, expected_csv = [], []
        actual_controls = set()
        group_listing_count = group_compatibility_count = 0

        def register_source(name):
            if not isinstance(name, str) or not name or Path(name).is_absolute():
                fail(json_file, f"Invalid relative source path: {name!r}")
                return None
            path = (directory / name).resolve()
            if not path.is_relative_to(root):
                fail(json_file, f"Source escapes the patterns directory: {name}")
                return None
            physical_sources.add(path)
            if path.is_relative_to(directory / "examples"):
                expected_sources.add(path.relative_to(directory).as_posix())
            return path

        def boundary(owner, fallback, language, identifier):
            """Read source_files once each, including shared definitions and core bodies."""
            names = owner.get("source_files") or [owner.get("source_file") or owner.get("source") or fallback]
            if (not isinstance(names, list) or not names or
                    any(not isinstance(name, str) or not name for name in names)):
                fail(json_file, f"ID {identifier}/{language}: invalid source_files boundary")
                return [], []
            paths = [register_source(name) for name in names]
            valid_paths = [path for path in paths if path is not None]
            if len(valid_paths) != len(set(valid_paths)):
                fail(json_file, f"ID {identifier}/{language}: one physical source is included twice")
            declared_source = owner.get("source_file")
            if declared_source and (directory / declared_source).resolve() not in valid_paths:
                fail(json_file, f"ID {identifier}/{language}: source_file is outside its counted source_files")
            parts = []
            for name, path in zip(names, paths):
                if path is None:
                    continue
                text = read_text(path)
                if text is None:
                    continue
                try:
                    current, archived = source_parts(text) if language == "LMX" else (text, None)
                except ValueError as exc:
                    fail(path, str(exc))
                    continue
                parts.append((name, canonical_code(current)))
                if archived is not None:
                    alternative = record.get("alternative", {}).get("LMX")
                    retained = (historical_code(alternative) if alternative else
                                canonical_code(record["procedural_lmx"]) if record.get("procedural_lmx") else None)
                    if archived != retained:
                        fail(path, f"ID {identifier}: archived body differs from explicit metadata")
            if len(parts) == len(names):
                assembled = normalize("\n\n".join(part.rstrip() for _, part in parts))
                if assembled != canonical_code(owner.get("code", "")):
                    fail(json_file, f"ID {identifier}/{language}: source_files assembly differs from JSON code: {names}")
            # Fixture aliases are present and inspectable, but never counted as a second body.
            entry = owner.get("entry_source_file")
            if entry and entry not in names:
                path = register_source(entry)
                if path is not None:
                    read_text(path)
            return names, parts

        for record in records:
            identifier = record.get("id")
            if type(identifier) is not int:
                fail(json_file, f"Non-integer record ID: {identifier!r}")
                continue
            if identifier in observed:
                fail(json_file, f"ID {identifier}: appears in more than one record")
            observed[identifier] = (directory.name, record)
            kind = record.get("kind", "pattern")
            if kind not in KINDS:
                fail(json_file, f"ID {identifier}: unsupported record kind {kind!r}")
                continue
            kind_ids[kind].append(identifier)
            pair = record.get("languages", controls)
            if (not isinstance(pair, list) or len(pair) != 2 or
                    any(not isinstance(language, str) for language in pair) or
                    len(set(pair)) != 2 or any(language not in controls for language in pair)):
                fail(json_file, f"ID {identifier}: exactly two distinct declared control languages are required")
                continue
            actual_controls.update(pair)
            languages = ["LMX"] + pair
            catalog_entry = catalog.get(identifier, {})
            for field, value in (("directory", directory.name), ("kind", kind),
                                 ("paired_with", record.get("paired_with")),
                                 ("implementation_ids", record.get("implementation_ids", [])),
                                 ("usage_ids", record.get("usage_ids", [])), ("languages", pair)):
                if catalog_entry.get(field) != value:
                    fail(manifest_path, f"ID {identifier}: {field} differs from the source index")
            slug = record.get("slug", "")
            if not isinstance(slug, str) or not re.fullmatch(r"[a-z0-9][a-z0-9_]*", slug):
                fail(json_file, f"ID {identifier}: invalid ASCII snake_case slug")
                continue
            stem = f"{identifier:03d}_{slug}"
            page_name = stem + "_comparision.md"
            page = directory / page_name
            expected_pages.add(page_name)
            markdown = read_text(page) or ""
            blocks, closed = fenced_blocks(markdown)
            blocks = [(tag, canonical_code(body)) for tag, body in blocks]
            if not closed:
                fail(page, "Unclosed Markdown fence")
            listings = record.get("listings", [])
            if (not isinstance(listings, list) or any(not isinstance(listing, dict) for listing in listings) or
                    [listing.get("language") for listing in listings] != languages):
                fail(json_file, f"ID {identifier}: expected compatibility mirrors in {languages} order")
                continue
            styled = bool(record.get("lmx_variants"))
            if styled:
                style_ids.append(identifier)
                if kind == "implementation":
                    fail(json_file, f"ID {identifier}: common implementation must retain one canonical body")
                for issue in validate_variants(record, directory):
                    fail(json_file, f"ID {identifier}: {issue}")
                if set(record["lmx_variants"]) != set(STYLES):
                    continue
                if canonical_code(listings[0].get("code", "")) != canonical_code(record["lmx_variants"]["functional"].get("code", "")):
                    fail(json_file, f"ID {identifier}: LMX compatibility mirror differs from functional style")
            allowed_blocks = set()
            requirements = []
            measured, style_metrics, comparison_metrics = {}, {}, {}
            source_boundaries, linked_parts = {}, []
            csv_row = {"id": str(identifier), "pattern": record.get("name", ""), "kind": kind,
                       "source": page_name, "language_1": pair[0], "language_2": pair[1]}

            def count_listing(label, prefix, code, names):
                nonlocal listing_count, total_bytes, group_listing_count
                full = measure(code)
                comparison_metrics[label] = full
                source_boundaries[label] = names
                for key in ("characters", "nonblank_lines", "utf8_bytes", "sha256"):
                    csv_row[prefix + "_" + key] = str(full[key])
                listing_count += 1
                group_listing_count += 1
                total_bytes += full["utf8_bytes"]
                return full

            for listing in listings:
                language = listing["language"]
                code = listing.get("code")
                if not isinstance(code, str) or not code.strip():
                    fail(json_file, f"ID {identifier}/{language}: empty code")
                    continue
                code = canonical_code(code)
                full = measure(code)
                measured[language] = full
                stored_metrics = listing.get("metrics", {})
                if (not isinstance(stored_metrics, dict) or
                        any(stored_metrics.get(key) != full[key] for key in ("characters", "nonblank_lines", "utf8_bytes", "sha256")) or
                        any(key not in full or full[key] != value for key, value in stored_metrics.items())):
                    fail(json_file, f"ID {identifier}/{language}: complete-source metrics are stale")
                compatibility_listing_count += 1
                group_compatibility_count += 1
                folder, extension, tag = LANGUAGES[language]
                default_source = f"examples/{folder}/{stem}.{extension}"
                if language == "LMX" and styled:
                    # The legacy field is an alias, never an additional measured listing.
                    functional = record["lmx_variants"]["functional"]
                    if listing.get("source_files") and listing["source_files"] != (functional.get("source_files") or [functional["source_file"]]):
                        fail(json_file, f"ID {identifier}: compatibility boundary differs from functional style")
                    if listing.get("source_file") and listing["source_file"] != functional.get("source_file"):
                        fail(json_file, f"ID {identifier}: compatibility source_file differs from functional style")
                    for style in STYLES:
                        variant = record["lmx_variants"][style]
                        body = canonical_code(variant["code"])
                        names, parts = boundary(variant, default_source, language, identifier)
                        allowed_blocks.add((tag, body))
                        allowed_blocks.update((tag, part) for _, part in parts)
                        requirements.append((tag, body, names, parts, variant.get("source_file")))
                        style_metrics[style] = count_listing(STYLE_LABELS[style], "LMX_" + style, body, names)
                else:
                    names, parts = boundary(listing, default_source, language, identifier)
                    allowed_blocks.add((tag, code))
                    allowed_blocks.update((tag, part) for _, part in parts)
                    requirements.append((tag, code, names, parts, listing.get("source_file") or default_source))
                    label = "LMX — общая реализация" if language == "LMX" and kind == "implementation" else language
                    prefix = "LMX_implementation" if language == "LMX" and kind == "implementation" else language
                    count_listing(label, prefix, code, names)
                variants = record.get("variants", {}).get(language, {})
                if variants and not (language == "LMX" and styled):
                    selected = record.get("primary_variant", {}).get(language)
                    if selected not in variants or canonical_code(variants.get(selected, "")) != code:
                        fail(json_file, f"ID {identifier}/{language}: compatibility selection differs from source")

            # Explanatory sources have explicit metadata and never replace a measured style.
            for language, alternative in record.get("alternative", {}).items():
                if language not in LANGUAGES:
                    fail(json_file, f"ID {identifier}: unknown alternative language {language}")
                    continue
                historical = historical_code(alternative)
                block = (LANGUAGES[language][2], historical)
                allowed_blocks.add(block)
                if block not in blocks:
                    fail(page, f"ID {identifier}: missing registered explanatory {language} listing")
                if alternative.get("context_prefix"):
                    original = alternative["code"]
                    if hashlib.sha256(original.encode()).hexdigest() != alternative.get("preserved_code_sha256"):
                        fail(json_file, f"ID {identifier}/{language}: historical source hash changed")
                    context = next((other for other in records if other.get("id") == alternative.get("context_prefix_source_id")), {})
                    if alternative["context_prefix"] != context.get("alternative", {}).get(language, {}).get("code"):
                        fail(json_file, f"ID {identifier}/{language}: historical context mismatch")
            for language, body in record.get("previous_controls", {}).items():
                allowed_blocks.add((LANGUAGES[language][2], canonical_code(body)))
            if record.get("procedural_lmx"):
                allowed_blocks.add(("lmx", canonical_code(record["procedural_lmx"])))
            for companion in record.get("companion_sources", []):
                if companion.get("counts_as_primary") is not False:
                    fail(json_file, f"ID {identifier}: companion must explicitly stay outside primary counts")
                path = register_source(companion.get("file"))
                if path is not None:
                    text = read_text(path)
                    if text is not None and hashlib.sha256(text.encode()).hexdigest() != companion.get("sha256"):
                        fail(path, "Companion source differs from its registered hash")
            for index, block in enumerate(blocks, 1):
                if block not in allowed_blocks:
                    fail(page, f"ID {identifier}: Markdown code block {index} ({block[0]}) differs from all registered bodies/fragments")
            for tag, body, names, parts, main in requirements:
                if (tag, body) in blocks:
                    continue
                for name, part in parts:
                    if (tag, part) in blocks:
                        continue
                    # A common helper may be linked once instead of reproduced on every page.
                    # Its entire physical body still belongs to the counted source boundary.
                    if name != main and f"]({name})" in markdown:
                        linked_parts.append(name)
                    else:
                        fail(page, f"ID {identifier}: missing or changed required {tag} fragment {name}")

            if not sources_only:
                rows = table_rows(markdown)
                for label, counts in comparison_metrics.items():
                    expected = [label, str(counts["characters"]), str(counts["nonblank_lines"])]
                    labels = {label}
                    if label == "LMX — общая реализация":
                        labels.update({"LMX", "LMX — реализация"})
                    if sum(rows.count([name, *expected[1:]]) for name in labels) != 1:
                        fail(page, f"ID {identifier}/{label}: expected one full-source metric row {expected}")
                for names in source_boundaries.values():
                    for name in names:
                        if f"]({name})" not in markdown:
                            fail(page, f"ID {identifier}: missing source link {name}")

            layer = ("implementation" if kind == "implementation" else
                     "shared_implementation_client" if record.get("comparison_level") == "shared_implementation_client" else
                     "usage" if record.get("implementation_ids") else kind)
            report = {"id": identifier, "name": record.get("name"), "kind": kind,
                      "layer": layer, "languages": pair, "source": page_name,
                      "metrics": {listing["language"]: metrics(canonical_code(listing["code"]))
                                  for listing in listings if isinstance(listing.get("code"), str)},
                      "full_metrics": measured, "comparison_metrics": comparison_metrics,
                      "source_boundaries": source_boundaries,
                      "markdown_linked_parts": sorted(set(linked_parts))}
            if styled:
                report["lmx_variants"] = {style: metrics(record["lmx_variants"][style]["code"]) for style in STYLES}
                report["lmx_variant_full_metrics"] = style_metrics
            group_reports.append(report)
            expected_csv.append(csv_row)

        if actual_controls != set(controls):
            fail(json_file, f"Declared language union differs from per-record pairs: {sorted(actual_controls)}")
        actual_pages = {path.name for path in directory.glob("*_comparision.md")}
        if actual_pages != expected_pages:
            fail(directory, f"Markdown inventory differs: missing={sorted(expected_pages-actual_pages)}, extra={sorted(actual_pages-expected_pages)}")
        actual_sources = {path.relative_to(directory).as_posix() for path in (directory / "examples").rglob("*")
                          if path.is_file() and path.suffix in SOURCE_SUFFIXES}
        if actual_sources != expected_sources:
            fail(directory / "examples", f"Source inventory differs: missing={sorted(expected_sources-actual_sources)}, extra={sorted(actual_sources-expected_sources)}")

        if not sources_only:
            # Columns are the ordered union of the records' actual pairs/styles. Unused
            # foreign columns are empty, not zero; SHA-256 follows the measured body.
            csv_path = directory / f"LMX_Comparison_{directory.name}.csv"
            try:
                raw = csv_path.read_bytes()
                if not raw.startswith(codecs.BOM_UTF8):
                    fail(csv_path, "CSV is missing its UTF-8 BOM")
                reader = csv.DictReader(io.StringIO(raw.decode("utf-8-sig"), newline=""))
                actual = list(reader)
                header = list(dict.fromkeys(key for row in expected_csv for key in row))
                if reader.fieldnames != header:
                    fail(csv_path, f"CSV schema differs from current per-record languages/styles: {reader.fieldnames}")
                if len(actual) != len(expected_csv):
                    fail(csv_path, f"Expected {len(expected_csv)} CSV rows; found {len(actual)}")
                for index, (row, expected) in enumerate(zip(actual, expected_csv), 2):
                    for key in header:
                        if row.get(key) != expected.get(key, ""):
                            fail(csv_path, f"Row {index}, {key}: {row.get(key)!r} != {expected.get(key, '')!r}")
                    if None in row:
                        fail(csv_path, f"Row {index}: extra unheaded cells")
            except (OSError, UnicodeError, csv.Error) as exc:
                fail(csv_path, f"Cannot validate CSV: {exc}")

            stem = f"{directory.name}/LMX_Comparison_{directory.name}"
            document = documents.get(stem)
            comparison_path = root / (stem + ".md")
            comparison = read_text(comparison_path) or ""
            expected_table, publication_ids = [], []
            by_id = {row["id"]: row for row in group_reports}
            if not document:
                fail(publication_path, f"Missing publication document {stem}")
            for view in (document or {}).get("sheets", []):
                for table in view.get("tables", []):
                    expected_table.append([str(value).replace("\n", " ") for value in table["headers"]])
                    rows = table["rows"] + ([table["total"]["values"]] if table.get("total") else [])
                    expected_table.extend([["—" if value is None else str(value).replace("|", "\\|").replace("\n", " ")
                                            for value in row] for row in rows])
                    for row in table["rows"]:
                        if not row or not str(row[0]).isdigit() or int(row[0]) not in by_id:
                            fail(publication_path, f"{stem}: invalid comparison row identity {row[:1]}")
                            continue
                        identifier = int(row[0]); publication_ids.append(identifier)
                        source_report = by_id[identifier]
                        values = [value["characters"] for value in source_report["comparison_metrics"].values()]
                        columns = table.get("comparison_columns", [])
                        if any(type(column) is not int or column < 0 or column >= len(row) for column in columns):
                            fail(publication_path, f"{stem}/{identifier}: invalid comparison columns")
                        elif [row[column] for column in columns] != values:
                            fail(publication_path, f"{stem}/{identifier}: comparison values differ from complete sources")
                        if len(controls) > 2 and [row[4], row[6]] != source_report["languages"]:
                            fail(publication_path, f"{stem}/{identifier}: displayed control pair differs from source pair")
                    if table.get("total"):
                        for column in table.get("comparison_columns", []):
                            total = table["total"]["values"][column]
                            if total is not None and total != sum(row[column] for row in table["rows"] if isinstance(row[column], (int, float))):
                                fail(publication_path, f"{stem}: stale total in comparison column {column}")
            observed_table = [row for row in table_rows(comparison)
                              if not all(re.fullmatch(r":?-+:?", value) for value in row)]
            if not expected_table or observed_table != expected_table:
                fail(comparison_path, "Summary tables differ from the publication model")
            if Counter(publication_ids) != Counter(by_id.keys()):
                fail(publication_path, f"{stem}: publication rows do not cover each source ID once")
            published = {row.get("id"): row for row in published_groups.get(directory.name, {}).get("records", [])}
            if set(published) != set(by_id):
                fail(publication_path, f"{directory.name}: published record set differs from source index")
            for identifier, report in by_id.items():
                row = published.get(identifier, {})
                if row.get("metrics") != report["full_metrics"]:
                    fail(publication_path, f"{directory.name}/{identifier}: published complete-source metrics are stale")
                if report.get("lmx_variant_full_metrics") and row.get("lmx_variants") != report["lmx_variant_full_metrics"]:
                    fail(publication_path, f"{directory.name}/{identifier}: published style metrics are stale")
            for extension in ("pdf", "xlsx"):
                path = root / (stem + "." + extension)
                if not path.is_file() or path.stat().st_size == 0:
                    fail(path, "Missing or empty publication artifact")
                    continue
                if extension == "pdf":
                    raw = path.read_bytes()
                    if not raw.startswith(b"%PDF-") or b"%%EOF" not in raw[-2048:]:
                        fail(path, "Missing PDF signature or final EOF marker")
                else:
                    try:
                        with zipfile.ZipFile(path) as workbook:
                            damaged = workbook.testzip()
                            if damaged:
                                fail(path, f"Damaged ZIP member: {damaged}")
                            for member in ("[Content_Types].xml", "xl/workbook.xml"):
                                if member not in workbook.namelist():
                                    fail(path, f"Missing workbook member {member}")
                    except (OSError, zipfile.BadZipFile) as exc:
                        fail(path, f"Invalid XLSX container: {exc}")
        groups.append({"directory": directory.name, "languages": ["LMX"] + controls,
                       "language_pairing": "per_record" if any(record.get("languages") for record in records) else "per_group",
                       "pattern_count": sum(row["kind"] == "pattern" for row in group_reports),
                       "algorithm_count": sum(row["kind"] == "algorithm" for row in group_reports),
                       "implementation_count": sum(row["kind"] == "implementation" for row in group_reports),
                       "comparison_count": len(group_reports), "compatibility_listing_count": group_compatibility_count,
                       "listing_count": group_listing_count, "patterns": group_reports})

    if set(observed) != declared_ids:
        fail(manifest_path, f"Every catalog ID must occur once: missing={sorted(declared_ids-set(observed))}, extra={sorted(set(observed)-declared_ids)}")
    for kind, key in KINDS.items():
        if sorted(kind_ids[kind]) != sorted(manifest.get(key, [])):
            fail(manifest_path, f"Observed {kind} IDs/kinds differ from {key}")
    for identifier, (directory, record) in observed.items():
        for implementation in record.get("implementation_ids", []):
            other = observed.get(implementation, (None, {}))[1]
            if other.get("kind") != "implementation" or identifier not in other.get("usage_ids", []):
                fail(manifest_path, f"ID {identifier}: missing reciprocal implementation link {implementation}")
        if record.get("kind") == "implementation":
            usages = record.get("usage_ids", [])
            if record.get("paired_with") not in usages:
                fail(manifest_path, f"ID {identifier}: paired_with must identify one declared usage")
            for usage in usages:
                other = observed.get(usage, (None, {}))[1]
                if not other or identifier not in other.get("implementation_ids", []):
                    fail(manifest_path, f"ID {identifier}: missing reciprocal usage link {usage}")
    return {"ok": not errors,
            "scope": "Registered complete-source consistency; no language execution, production parser/type check, XLSX calculation or PDF visual QA.",
            "mode": "sources_only" if sources_only else "sources_and_publication",
            "lmx_parser_execution": "NOT_RUN", "lmx_runtime_execution": "NOT_RUN",
            "publication_checks": "SKIPPED" if sources_only else "CHECKED",
            "method": {"source_normalization": "LF, code.strip() + final LF; ordered source_files joined with one blank line",
                       "nonwhitespace_characters": "Unicode code points with str.isspace()==False; declarations, Throws, comments and literals included",
                       "nonblank_lines": "Nonempty stripped splitlines() entries",
                       "utf8_bytes": "Complete canonical source encoded in UTF-8, including whitespace and final LF",
                       "styles": "Both registered styles are counted independently; the legacy LMX listing is only a compatibility mirror",
                       "boundaries": "All declared source_files, once per style; shared helpers never disappear from the measurement",
                       "markdown": "Shown full bodies/fragments match registered sources; linked common helper bodies remain fully counted",
                       "csv": "Dynamic ordered columns for actual per-record languages/styles; absent foreign values stay empty",
                       "artifacts": "Only workbook ZIP integrity and PDF signatures; rendering/formula validation is separate"},
            "group_count": len(json_files), "pattern_count": len(kind_ids["pattern"]),
            "algorithm_count": len(kind_ids["algorithm"]), "implementation_count": len(kind_ids["implementation"]),
            "comparison_count": len(observed), "compatibility_listing_count": compatibility_listing_count,
            "listing_count": listing_count, "style_contract_count": len(style_ids),
            "style_listing_count": len(STYLES) * len(style_ids), "physical_source_count": len(physical_sources),
            "total_source_utf8_bytes": total_bytes, "error_count": len(errors), "errors": errors, "groups": groups}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent,
                        help="patterns directory or archive root containing spec/patterns")
    parser.add_argument("--json", type=Path, help="Also save the JSON report to this path")
    parser.add_argument("--sources-only", action="store_true",
                        help="Check source bodies, JSON metrics and Markdown code; skip publication tables/CSV/PDF/XLSX")
    args = parser.parse_args()
    root = args.root.resolve()
    if not (root / "comparison_sources/catalog_manifest.json").exists() and (root / "spec/patterns").is_dir():
        root = root / "spec/patterns"
    report = audit(root, sources_only=args.sources_only)
    payload = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(payload, encoding="utf-8")
    sys.stdout.write(payload)
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())

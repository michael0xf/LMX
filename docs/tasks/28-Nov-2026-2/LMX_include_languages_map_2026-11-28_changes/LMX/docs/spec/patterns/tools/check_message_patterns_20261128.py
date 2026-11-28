#!/usr/bin/env python3
"""Check publication/source consistency for IDs 109-112; never execute LMX."""
from pathlib import Path
import csv
import hashlib
import json
import re
import shutil
import subprocess
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
GROUP = ROOT / "06_async_and_messages"
IDS = (109, 110, 111, 112)
REPORT = ROOT / "validation/message_patterns_20261128.json"
errors = []
checks = []
source_hashes = {}


def check(name, good, detail=None):
    checks.append({"check": name, "status": "PASS" if good else "FAIL", "detail": detail})
    if not good:
        errors.append(name)


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def metrics(code):
    return {
        "characters": sum(not c.isspace() for c in code),
        "nonblank_lines": sum(bool(line.strip()) for line in code.splitlines()),
        "utf8_bytes": len(code.encode()),
        "sha256": hashlib.sha256(code.encode()).hexdigest(),
    }


group = load(GROUP / "patterns.json")
records = {record["id"]: record for record in group["patterns"]}
check("Group has 15 distinct records", len(records) == len(group["patterns"]) == 15)
check("Four new canonical records exist", set(IDS) <= set(records))
markdown = [GROUP / "README.md", GROUP / "MESSAGE_PROTOCOLS_2026-11-28.md"]
language_files = (("LMX", "lmx", "lm3"), ("Go", "go", "go"), ("Erlang", "erlang", "erl"))
for number in IDS:
    record = records[number]
    stem = f"{number:03d}_{record['slug']}"
    comparison = GROUP / f"{stem}_comparision.md"
    markdown.append(comparison)
    rendered = comparison.read_text()
    listings = {listing["language"]: listing for listing in record["listings"]}
    check(f"{number} has LMX/Go/Erlang", set(listings) == {"LMX", "Go", "Erlang"})
    check(f"{number} has RU/EN catalog fields", all(record.get(f"{field}_{lang}") for field in
          ("summary", "scenario", "expected", "lmx_notes", "comparison", "limits") for lang in ("ru", "en")))
    for language, directory, extension in language_files:
        source = GROUP / "examples" / directory / f"{stem}.{extension}"
        code = source.read_text()
        listing = listings[language]
        key = source.relative_to(ROOT).as_posix()
        source_hashes[key] = hashlib.sha256(source.read_bytes()).hexdigest()
        check(f"{number} {language} exact canonical mirror", code == listing["code"])
        check(f"{number} {language} full-source metrics", metrics(code) == listing["metrics"])
        fence = chr(96) * 3
        check(f"{number} {language} exact Markdown listing",
              fence + directory + "\n" + code + fence in rendered)
        check(f"{number} {language} no placeholder body",
              not re.search(r"\b(TODO|TBD|NotImplementedError|pass)\b|\.\.\.", code))
        if language == "LMX":
            lines = code.splitlines()
            reset_errors = [i + 1 for i, line in enumerate(lines[:-1])
                            if not line.strip() and lines[i + 1].strip()
                            and lines[i + 1][0].isspace()]
            check(f"{number} LMX no blank-line nested continuation", not reset_errors, reset_errors)
            check(f"{number} LMX no blocking/synchronization statement",
                  not re.search(r"^\s*(synchronized|wait|sleep|join)\s*[:(]", code, re.M))
            check(f"{number} LMX indentation uses spaces", "\t" not in code)

manifest = load(ROOT / "comparison_sources/catalog_manifest.json")
check("Catalog manifest includes four new pattern IDs",
      set(IDS) <= set(manifest["pattern_ids"]) and len(manifest["pattern_ids"]) == 97)
manifest_records = {record["id"]: record for record in manifest["comparisons"]}
check("Manifest preserves group and comparison languages",
      all(manifest_records[number]["directory"] == GROUP.name and
          manifest_records[number]["languages"] == ["Go", "Erlang"] for number in IDS))
publication = load(ROOT / "PUBLICATION_DATA.json")
published_group = next(item for item in publication["groups"] if item["directory"] == GROUP.name)
published = {record["id"]: record for record in published_group["records"]}
stat_group = next(item for item in load(ROOT / "validation/statistics_20261122.json")["groups"]
                  if item["directory"] == GROUP.name)
statistics = {record["id"]: record for record in stat_group["records"]}
with (GROUP / "LMX_Comparison_06_async_and_messages.csv").open(encoding="utf-8-sig", newline="") as stream:
    csv_rows = {int(row["id"]): row for row in csv.DictReader(stream)}
check("Published group and CSV both contain 15 records", len(published) == len(csv_rows) == 15)
for number in IDS:
    for listing in records[number]["listings"]:
        language = listing["language"]
        values = listing["metrics"]
        check(f"{number} {language} JSON/statistics/CSV metric agreement",
              all(published[number]["metrics"][language][key] == value and
                  statistics[number]["metrics"][language][key] == value and
                  str(csv_rows[number][f"{language}_{key}"]) == str(value)
                  for key, value in values.items()))

cases = load(ROOT / "validation/message_protocol_cases_20261128.json")
check("Expected cases cover exactly the four additions",
      cases["status"] == "EXPECTED_NOT_RUN" and [case["id"] for case in cases["patterns"]] == list(IDS))
check("Expected cases distinguish sequence and boundary constraints",
      all(case["sequence"] and case["boundary_constraints"] for case in cases["patterns"]))
local_links = 0
for document in markdown:
    for destination in re.findall(r"\[[^\]]*\]\(([^)]+)\)", document.read_text()):
        parsed = urlsplit(destination)
        if parsed.scheme or destination.startswith("#"):
            continue
        target = (document.parent / unquote(parsed.path)).resolve()
        local_links += 1
        check(f"Local link {document.name} -> {destination}",
              target.exists() or target == REPORT)

toolchains = {}
for executable, args in (("go", ["version"]), ("erl", ["-noshell", "-eval", "halt()."]),
                         ("erlc", ["-version"])):
    location = shutil.which(executable)
    if location is None:
        toolchains[executable] = {"status": "UNAVAILABLE", "path": None}
        continue
    probe = subprocess.run([location, *args], capture_output=True, text=True, timeout=10)
    text = (probe.stdout + probe.stderr).strip()
    usable = probe.returncode == 0 and (executable != "go" or text.startswith("go version go"))
    toolchains[executable] = {
        "status": "AVAILABLE" if usable else "UNUSABLE",
        "path": location, "returncode": probe.returncode, "probe": text[:500]
    }

report = {
    "edition": "2026-11-28",
    "status": "STATIC_CONSISTENCY_PASS" if not errors else "STATIC_CONSISTENCY_FAIL",
    "scope": "Exact source mirrors, metrics, catalog/publication records and local references. Layout scans are not an LMX parser.",
    "new_pattern_ids": list(IDS),
    "group_records": 15,
    "source_files_reviewed": len(source_hashes),
    "local_links_checked": local_links,
    "checks": checks,
    "errors": errors,
    "source_sha256": source_hashes,
    "toolchain_probes": toolchains,
    "lmx_parser_type_runtime": "NOT_RUN",
    "go_compile_runtime": "NOT_RUN",
    "erlang_compile_runtime": "NOT_RUN",
    "native_adapters": "REQUIRE_IMPLEMENTATION",
    "expected_protocol_sequences": "validation/message_protocol_cases_20261128.json",
    "workbook_publication": "validation/workbook_publication_20261128.json",
    "pdf_publication": "validation/pdf_generation_20261128.json",
    "visual_review": "validation/message_publication_visual_20261128.json"
}
REPORT.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({"status": report["status"], "checks": len(checks), "errors": errors,
                  "source_files": len(source_hashes)}, ensure_ascii=False))
raise SystemExit(bool(errors))

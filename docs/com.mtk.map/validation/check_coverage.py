#!/usr/bin/env python3
"""Verify exact source-to-draft inventory coverage, without claiming execution."""
from pathlib import Path
from collections import Counter
import hashlib
import json

BASE = Path(__file__).resolve().parent
storage = json.loads((BASE / "coverage_storage.json").read_text())["entries"]
tags = json.loads((BASE / "coverage_tags.json").read_text())["methods"]
inventory = json.loads((BASE / "java_method_inventory.json").read_text())["declarations"]

def key(row, kind):
    if kind == "storage":
        path = row["source"].split("com.mtk.map/", 1)[1]
        method = row["method"]
    elif kind == "tags":
        path = row["original_archive_path"].split("com.mtk.map/", 1)[1]
        method = row["name"]
    else:
        path = row["source_path"].split("java_original/", 1)[1]
        method = row["name"]
    return path, row["class"], method, row["line"]

a = {key(row, "storage") for row in storage}
b = {key(row, "tags") for row in tags}
c = {key(row, "inventory") for row in inventory}
assert len(a) == len(storage) and len(b) == len(tags), "duplicate mapping"
assert len(c) == len(inventory), "duplicate inventory item"
assert not a & b, "overlapping ownership"
assert a | b == c, {"missing": sorted(c - (a | b)), "extra": sorted((a | b) - c)}
report = {
    "status": "EXACT_AST_COVERAGE_PASS",
    "inventory": "java_method_inventory.json",
    "total_declarations": len(c),
    "storage_declarations": len(a),
    "upper_declarations": len(b),
    "overlap": 0, "missing": 0,
    "status_counts": dict(Counter(row["status"] for row in storage + tags)),
    "input_sha256": {name: hashlib.sha256((BASE / name).read_bytes()).hexdigest()
                     for name in ("java_method_inventory.json",
                                  "coverage_storage.json", "coverage_tags.json")},
    "scope": "Source-to-draft mapping completeness; not LMX compilation or runtime acceptance",
}
(BASE / "coverage_summary.json").write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + "\n")
print(json.dumps({key: report[key] for key in ("status", "total_declarations",
      "storage_declarations", "upper_declarations", "overlap", "missing",
      "status_counts")}, ensure_ascii=False, indent=2))

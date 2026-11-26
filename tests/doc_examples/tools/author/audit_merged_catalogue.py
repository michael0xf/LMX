#!/usr/bin/env python3
"""Read-only merged catalogue audit: original patterns scope plus explicit spec/ARROW_EXAMPLES.md.

Run:
  python -B audit_catalogue.py EXTRACTED_ROOT --output catalogue_audit.json

Stable .bNN identifiers are opaque catalogue keys. Current block ordinal and
first content line are checked independently against places.tsv. No LMX code
is executed and recorded parser/build/run results are not called fresh tests.
"""
from __future__ import annotations

import argparse
import collections
import csv
import difflib
import hashlib
import json
import re
from pathlib import Path


def normalized(data: bytes) -> bytes:
    return data.replace(b"\r\n", b"\n").replace(b"\r", b"\n").rstrip(b"\n") + b"\n"


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def rows(path: Path):
    with path.open(encoding="utf-8", newline="") as stream:
        return [dict(row, _tsv_line=i) for i, row in enumerate(csv.DictReader(stream, delimiter="\t"), 2)]


def fenced_blocks(path: Path, root: Path):
    """Recognize CommonMark-style backtick/tilde fences without entering them.

    Fences with up to three leading spaces are handled; the source text inside
    is retained bytewise. Alternate content with indentation removed is emitted
    only for diagnostics if such a fence is encountered.
    """
    data = path.read_bytes().replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    lines = data.splitlines(keepends=True)
    active = None
    ordinal = 0
    found, unclosed, related = [], [], []
    for i, line in enumerate(lines, 1):
        plain = line.rstrip(b"\n")
        if active is None:
            match = re.fullmatch(rb"( {0,3})(`{3,}|~{3,})([^\r\n]*)", plain)
            if not match:
                continue
            indent, marker, info = match.groups()
            if marker.startswith(b"`") and b"`" in info:
                continue
            info = info.strip().decode("utf-8", errors="replace")
            language = info.split()[0] if info else ""
            active = {"open_line": i, "line": i + 1, "indent": len(indent),
                      "char": marker[:1], "width": len(marker), "info": info,
                      "is_lmx": language.lower() == "lmx", "body": []}
            if language.lower().startswith("lmx") and language.lower() != "lmx":
                related.append({"doc": path.relative_to(root).as_posix(), "line": i, "info": info})
        else:
            closing = re.fullmatch(rb" {0,3}(" + re.escape(active["char"]) + rb"{"
                                   + str(active["width"]).encode() + rb",})[ \t]*", plain)
            if closing:
                if active["is_lmx"]:
                    ordinal += 1
                    found.append({"doc": path.relative_to(root).as_posix(), "kind": "block",
                                  "block": ordinal, "line": active["line"],
                                  "open_line": active["open_line"], "close_line": i,
                                  "indent": active["indent"], "info": active["info"],
                                  "data": normalized(b"".join(active["body"]))})
                active = None
            else:
                active["body"].append(line)
    if active and active["is_lmx"]:
        unclosed.append({"doc": path.relative_to(root).as_posix(), "line": active["open_line"]})
    return found, unclosed, related


def text_diff(expected: bytes, actual: bytes):
    a = expected.decode("utf-8", errors="replace").splitlines()
    b = actual.decode("utf-8", errors="replace").splitlines()
    first = next((i for i, (x, y) in enumerate(zip(a, b), 1) if x != y), min(len(a), len(b)) + 1)
    diff = list(difflib.unified_diff(a, b, fromfile="catalogue", tofile="document", n=2))
    return {"first_different_source_line": first, "expected_sha256": sha(expected),
            "actual_sha256": sha(actual), "diff": diff[:100], "diff_truncated": len(diff) > 100}


def audit(root: Path):
    catalogue = root / "doc_examples"
    patterns = root / "spec/patterns"
    index_all = rows(catalogue / "index.tsv")
    metadata = [r for r in index_all if r["id"].startswith("#")]
    index = [r for r in index_all if not r["id"].startswith("#")]
    places = rows(catalogue / "places.tsv")
    issues = []

    def issue(category, **detail):
        if "kind" in detail:
            detail["place_kind"] = detail.pop("kind")
        issues.append({"kind": category, **detail})

    by_id = collections.defaultdict(list)
    for row in index:
        by_id[row["id"]].append(row)
    for ident, group in by_id.items():
        if len(group) != 1:
            issue("duplicate_index_id", id=ident, lines=[r["_tsv_line"] for r in group])

    src_by_id = collections.defaultdict(list)
    src_by_hash = collections.defaultdict(list)
    src = {}
    for path in sorted((catalogue / "src").rglob("*")):
        if not path.is_file():
            continue
        raw = path.read_bytes()
        data = normalized(raw)
        ident = path.stem
        src_by_id[ident].append(path)
        src_by_hash[sha(data)].append(ident)
        src[ident] = {"path": path.relative_to(root).as_posix(), "data": data,
                      "sha256": sha(data), "bytes": len(data)}
        if path.suffix not in (".lm3", ".lmx"):
            issue("unexpected_src_extension", path=path.relative_to(root).as_posix())
        if raw != data:
            issue("src_not_canonical_lf_one_trailing_lf", id=ident, path=path.relative_to(root).as_posix())
    for ident, paths in src_by_id.items():
        if len(paths) != 1:
            issue("duplicate_src_id", id=ident, paths=[p.relative_to(root).as_posix() for p in paths])
    for digest, ids in src_by_hash.items():
        if len(ids) != 1:
            issue("duplicate_src_content", sha256=digest, ids=ids)
    for ident in sorted(set(by_id) - set(src_by_id)):
        issue("index_without_source", id=ident)
    for ident in sorted(set(src_by_id) - set(by_id)):
        issue("source_without_index", id=ident)

    blocks = []
    related_labels = []
    md_files = sorted(p for p in patterns.rglob("*") if p.is_file() and p.suffix.lower() == ".md")
    extra = root / "spec/ARROW_EXAMPLES.md"
    if extra.is_file():
        md_files.append(extra)
        md_files.sort()
    for path in md_files:
        found, unclosed, related = fenced_blocks(path, root)
        blocks.extend(found)
        related_labels.extend(related)
        for entry in unclosed:
            issue("unclosed_lmx_fence", **entry)
    block_by_line = {(b["doc"], b["line"]): b for b in blocks}
    block_by_number = {(b["doc"], b["block"]): b for b in blocks}

    all_code_files = sorted(p for p in (root / "spec").rglob("*")
                            if p.is_file() and p.suffix.lower() in (".lm3", ".lmx"))
    expected_files = []
    excluded_files = []
    outside_scope = []
    for path in all_code_files:
        rel = path.relative_to(root)
        if not path.is_relative_to(patterns):
            outside_scope.append(rel.as_posix())
        elif path.suffix.lower() == ".lmx" and "LMX_Fn_Receivers" in path.relative_to(patterns).parts:
            excluded_files.append(rel.as_posix())
        else:
            expected_files.append(rel.as_posix())

    expected_keys = {(f, "file", 1) for f in expected_files}
    expected_keys.update((b["doc"], "block", b["line"]) for b in blocks)
    encountered = collections.defaultdict(list)
    place_counts = collections.Counter(p["id"] for p in places)
    verified = []
    resolved_by_id = collections.defaultdict(list)
    physical_normalization = []
    for place in places:
        ident = place["id"]
        line = int(place["line"])
        doc = place["doc"]
        if not doc.startswith("docs/spec/patterns/") and doc != "docs/spec/ARROW_EXAMPLES.md":
            issue("unexpected_place_prefix", place=place)
            continue
        doc = doc.removeprefix("docs/")
        kind = place["kind"]
        key = (doc, kind, line)
        encountered[key].append(place["_tsv_line"])
        entry = {"id": ident, "doc": doc, "kind": kind, "line": line,
                 "places_tsv_line": place["_tsv_line"]}
        if ident not in by_id:
            issue("place_without_index", **entry)
        if ident not in src:
            issue("place_without_source", **entry)
            continue
        path = root / doc
        if not path.is_file():
            issue("place_document_missing", **entry)
            continue
        if kind == "file":
            if place["block"] != "-" or line != 1:
                issue("invalid_file_place_position", **entry, block=place["block"])
            data = normalized(path.read_bytes())
            if data != path.read_bytes():
                physical_normalization.append(entry)
        elif kind == "block":
            block = block_by_line.get((doc, line))
            if block is None:
                candidate = block_by_number.get((doc, int(place["block"])))
                issue("block_content_start_line_mismatch", **entry, block=int(place["block"]),
                      current_line=candidate["line"] if candidate else None)
                continue
            entry["block"] = block["block"]
            entry["open_line"] = block["open_line"]
            entry["close_line"] = block["close_line"]
            if int(place["block"]) != block["block"]:
                issue("current_lmx_block_ordinal_mismatch", **entry, listed_block=int(place["block"]))
            data = block["data"]
        else:
            issue("unknown_place_kind", **entry)
            continue
        entry["matches"] = data == src[ident]["data"]
        entry["sha256"] = sha(data)
        if not entry["matches"]:
            issue("place_content_mismatch", **entry, **text_diff(src[ident]["data"], data))
        resolved_by_id[ident].append(entry)
        verified.append(entry)
    for key, lines in encountered.items():
        if len(lines) != 1:
            issue("duplicate_place", doc=key[0], place_kind=key[1], line=key[2], tsv_lines=lines)
    for ident, row_group in by_id.items():
        if place_counts[ident] != int(row_group[0]["places"]):
            issue("index_places_count_mismatch", id=ident, index=int(row_group[0]["places"]),
                  actual=place_counts[ident])
        if place_counts[ident] == 0:
            issue("index_source_has_no_places", id=ident)
    for key in sorted(expected_keys - set(encountered)):
        doc, kind, line = key
        data = (normalized((root/doc).read_bytes()) if kind == "file" else block_by_line[(doc, line)]["data"])
        context = (root/doc).read_text(encoding="utf-8").splitlines()
        issue("document_example_missing_from_places", doc=doc, place_kind=kind, line=line,
              matching_catalogue_ids=src_by_hash.get(sha(data), []),
              preceding_context=context[max(0,line-10):max(0,line-1)])
    for key in sorted(set(encountered) - expected_keys):
        issue("place_outside_discovered_scope", doc=key[0], place_kind=key[1], line=key[2])

    latest = [r for r in index if "dfa3bc9a" in r["note"]]
    latest_fixed = [r for r in latest if r["class"] == "fixed"]
    latest_debt = [r for r in index if r["class"] == "parser-debt:21.12"]

    def selected_record(row, marker):
        ident = row["id"]
        source_lines = src[ident]["data"].decode("utf-8").splitlines()
        marker_lines = [i for i, line in enumerate(source_lines, 1) if marker(line)]
        positions = []
        for place in resolved_by_id[ident]:
            lines = (root/place["doc"]).read_text(encoding="utf-8").splitlines()
            entries = []
            for n in marker_lines:
                absolute = place["line"] + n - 1
                actual = lines[absolute-1] if absolute <= len(lines) else None
                entries.append({"source_line": n, "document_line": absolute,
                                "text": source_lines[n-1], "exact_marker_match": actual == source_lines[n-1]})
            positions.append(dict(place, markers=entries))
        snippets = [{"line": n, "lines": source_lines[max(0,n-3):n+2]} for n in marker_lines]
        return dict(row, source=src[ident]["path"], source_sha256=src[ident]["sha256"],
                    marker_lines=marker_lines, snippets=snippets, positions=positions)

    fixed_detail = [selected_record(r, lambda line: line.strip() == "---") for r in latest_fixed]
    debt_detail = [selected_record(r, lambda line: ":=" in line and "(" in line) for r in latest_debt]
    selected_ids = {r["id"] for r in latest_fixed + latest_debt}
    unlisted_occurrences = []
    for ident in selected_ids:
        known_keys = {(r["doc"], r["kind"], r["line"]) for r in resolved_by_id[ident]}
        data = src[ident]["data"]
        for block in blocks:
            key = (block["doc"], "block", block["line"])
            if block["data"] == data and key not in known_keys:
                unlisted_occurrences.append({"id": ident, "doc": block["doc"], "line": block["line"], "kind": "block"})
        for f in expected_files:
            key = (f, "file", 1)
            if normalized((root/f).read_bytes()) == data and key not in known_keys:
                unlisted_occurrences.append({"id": ident, "doc": f, "line": 1, "kind": "file"})

    recorded_runs = [r for r in index if r["build"] != "-" or r["run"] != "-"]
    stable_id_current_ordinal_differences = []
    for place in places:
        suffix = re.search(r"\.b(\d+)$", place["id"])
        if place["kind"] == "block" and suffix and int(suffix.group(1)) != int(place["block"]):
            stable_id_current_ordinal_differences.append(
                {"id":place["id"], "doc":place["doc"].removeprefix("docs/"),
                 "line":int(place["line"]), "current_lmx_block":int(place["block"])})
    status_counts = {field: dict(collections.Counter(r[field] for r in index))
                     for field in ("kind", "class", "p0", "build", "run")}
    report = {
        "schema": "lmx-catalogue-audit-v1",
        "root": str(root),
        "scope": "doc_examples versus all .lm3, all .lmx outside LMX_Fn_Receivers, and all LMX fenced blocks under spec/patterns plus explicit spec/ARROW_EXAMPLES.md",
        "source_read_only": True,
        "parser_or_runtime_executed": False,
        "normalization": "CRLF/CR to LF, retain spaces and all non-newline bytes, exactly one final LF",
        "stable_bNN_ids_treated_as_opaque": True,
        "input_hashes": {p.relative_to(root).as_posix():sha(p.read_bytes()) for p in
                         (catalogue/"README.md", catalogue/"index.tsv", catalogue/"places.tsv")},
        "summary": {"index_texts":len(index), "src_files":sum(map(len,src_by_id.values())),
                    "distinct_src_texts":len(src_by_hash), "places":len(places),
                    "listed_place_kinds":dict(collections.Counter(p["kind"] for p in places)),
                    "discovered_lmx_fenced_blocks":len(blocks), "markdown_files_scanned":len(md_files),
                    "all_lmx_source_files_under_spec":len(all_code_files),
                    "discovered_in_scope_source_files":len(expected_files),
                    "excluded_package_lmx_files":len(excluded_files),
                    "verified_places":len(verified), "bytewise_matches_after_normalization":sum(v["matches"] for v in verified),
                    "issue_count":len(issues), "issue_kinds":dict(collections.Counter(x["kind"] for x in issues))},
        "issues":issues,
        "status_counts_recorded_not_rerun":status_counts,
        "graph_metadata_for_recorded_build_run":metadata,
        "latest_p0_cohort_recorded_not_rerun":{
            "count":len(latest), "classes":dict(collections.Counter(r["class"] for r in latest)),
            "p0":dict(collections.Counter(r["p0"] for r in latest)),
            "notes_mention_package_2026_11_24":sum("пакетом 2026-11-24" in r["note"] for r in latest),
            "notes_mention_package_2026_11_23":sum("пакетом 2026-11-23" in r["note"] for r in latest)},
        "latest_fixed_detail":fixed_detail,
        "parser_debt_21_12_detail":debt_detail,
        "selected_text_unlisted_exact_occurrences":unlisted_occurrences,
        "recorded_build_run_rows_not_rerun":recorded_runs,
        "recorded_execution_summary_not_rerun":{
            "build_and_run_unrecorded":sum(r["build"] == r["run"] == "-" for r in index),
            "recorded_build_ok":sum(r["build"].endswith(": ok") for r in index),
            "recorded_build_refused":sum("refused" in r["build"] for r in index),
            "recorded_run_answered_5_seen_None":sum("answered 5, seen None" in r["run"] for r in index),
            "recorded_run_exit_1_seen_None":sum("exit 1, seen None" in r["run"] for r in index),
            "interpretation":"These are historical index observations, not successful runtime verification in this audit."},
        "nonzero_p0_rows_not_rerun":[r for r in index if r["p0"] != "0"],
        "other_fixed_rows":[r for r in index if r["class"] == "fixed" and r not in latest_fixed],
        "refused_class_rows":[r for r in index if r["class"] == "refused"],
        "excluded_package_lmx_files":excluded_files,
        "source_files_outside_patterns":outside_scope,
        "related_non_lmx_fence_labels":related_labels,
        "indented_lmx_fences":[{k:v for k,v in b.items() if k != "data"} for b in blocks if b["indent"]],
        "stable_ids_differing_from_current_block_ordinals":stable_id_current_ordinal_differences,
        "limits":[
            "Parser, Graph compiler and interpreter were not run; statuses are extracted exactly from index.tsv.",
            "Historical 356 unchanged / 65 changed / 11 new / 9 removed / 20 moved claims require the previous catalogue and are not independently established by this current-tree audit.",
            f"The {len(excluded_files)} LMX_Fn_Receivers .lmx files have separate package acceptance and are intentionally outside this catalogue; its Markdown LMX fences remain included.",
            "JSON negative-control fixtures are not fenced documentation examples or .lm3/.lmx files and are not silently reclassified as production failures."
        ],
        "physical_doc_file_line_ending_normalization":physical_normalization,
        "verified_places":verified,
    }
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.output.resolve()
    if output.is_relative_to(root):
        parser.error("Report must be outside the read-only source tree")
    report = audit(root)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report["summary"], ensure_ascii=False, indent=2))
    print(f"Report: {output}")
    raise SystemExit(0 if not report["issues"] else 1)


if __name__ == "__main__":
    main()

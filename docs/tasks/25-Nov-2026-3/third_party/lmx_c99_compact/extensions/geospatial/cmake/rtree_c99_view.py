#!/usr/bin/env python3
"""Name one private union for strict C99; keep public API/layout semantics."""
from pathlib import Path
import argparse
import difflib
import hashlib
import json
import re

p = argparse.ArgumentParser()
p.add_argument("source", type=Path)
p.add_argument("output", type=Path)
args = p.parse_args()
original = args.source.read_text()
before = """    union {
        struct node *nodes[MAXITEMS];
        struct item datas[MAXITEMS];
    };"""
after = before.replace("    };", "    } entries;")
if original.count(before) != 1:
    raise SystemExit("Pinned rtree private union changed; manual review required")
view = original.replace(before, after)
# Both member names occur only in struct node. No public struct is changed.
view, count = re.subn(r"->(nodes|datas)\b", r"->entries.\1", view)
if count != 40:
    raise SystemExit("Unexpected rtree member access count: " + str(count))
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(view)
args.output.with_suffix(".patch").write_text("".join(difflib.unified_diff(
    original.splitlines(True), view.splitlines(True),
    fromfile="upstream/rtree.c", tofile="build-view/rtree.c")))
args.output.with_suffix(".json").write_text(json.dumps({
    "source_sha256": hashlib.sha256(original.encode()).hexdigest(),
    "view_sha256": hashlib.sha256(view.encode()).hexdigest(),
    "private_unions_named": 1, "member_accesses_rewritten": count,
    "public_header_changed": False,
    "algorithm_changes": False,
    "upstream_configuration": "RTREE_NOATOMICS=1 (external synchronization required)"
}, indent=2) + "\n")

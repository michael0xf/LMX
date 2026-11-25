#!/usr/bin/env python3
"""Replace binary literals / empty aggregate initializers with C99 spellings."""
from pathlib import Path
import argparse
import difflib
import hashlib
import json
import re

p=argparse.ArgumentParser()
p.add_argument("source",type=Path)
p.add_argument("output",type=Path)
args=p.parse_args()
original=args.source.read_text()
view=original
literals=[]
initializers=0
if args.source.name == "h3Index.c":
    literals=list(dict.fromkeys(re.findall(r"\b0b[01]+\b",original)))
    if literals != ["0b00001000", "0b100100100100100100100100100100100100100100100"]:
        raise SystemExit("Pinned H3 binary literals changed; review required")
    for prefix,literal in zip(("return h == ","const uint64_t MHI = "),literals):
        statement=prefix+literal+";"
        if original.count(statement)!=1:
            raise SystemExit("Pinned H3 constant statement changed; review required")
        view=view.replace(statement,prefix+hex(int(literal,2))+";")
elif args.source.name == "area.c":
    initializers=original.count("Adder adder = {};")
    if initializers != 3:
        raise SystemExit("Pinned H3 aggregate initializers changed; review required")
    view=view.replace("Adder adder = {};", "Adder adder = {0};")
else:
    raise SystemExit("Unexpected H3 source view requested")
args.output.parent.mkdir(parents=True,exist_ok=True)
args.output.write_text(view)
args.output.with_suffix(".patch").write_text("".join(difflib.unified_diff(
    original.splitlines(True),view.splitlines(True),
    fromfile="upstream/"+args.source.name,tofile="build-view/"+args.source.name)))
args.output.with_suffix(".json").write_text(json.dumps({
    "original_sha256":hashlib.sha256(original.encode()).hexdigest(),
    "view_sha256":hashlib.sha256(view.encode()).hexdigest(),
    "literal_replacements":{literal:hex(int(literal,2)) for literal in literals},
    "zero_initializers":initializers,
    "algorithm_change":False},indent=2)+"\n")

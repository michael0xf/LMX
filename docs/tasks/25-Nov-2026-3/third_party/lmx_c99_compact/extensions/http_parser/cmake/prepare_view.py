#!/usr/bin/env python3
"""Make a typed-callback C99 build view; never edit the vendored release."""
from pathlib import Path
import difflib
import json
import re
import shutil
import argparse
import hashlib

parser = argparse.ArgumentParser()
parser.add_argument("--source", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
vendor = args.source.resolve()
view = args.output.resolve()
pin = json.loads((root / "provenance/llhttp.json").read_text())
build_inputs = ("include/llhttp.h", "src/api.c", "src/http.c", "src/llhttp.c")
for path in build_inputs:
    expected = pin["files"][path]
    if hashlib.sha256((vendor / path).read_bytes()).hexdigest() != expected:
        raise ValueError("Changed pinned llhttp source: " + path)
for path in build_inputs:
    (view / path).parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(vendor / path, view / path)
changes = {}

def write(rel, new, count):
    old = (vendor / rel).read_text()
    (view / rel).write_text(new)
    changes[rel] = count
    return "".join(difflib.unified_diff(
        old.splitlines(True), new.splitlines(True),
        fromfile="upstream/" + rel, tofile="c99_view/" + rel))

patch = ""
s = (vendor / "include/llhttp.h").read_text()
old = "  void* _span_cb0;"
assert s.count(old) == 1
s = s.replace(old, "  int (*_span_cb0)(llhttp__internal_t*, const unsigned char*, const unsigned char*);")
patch += write("include/llhttp.h", s, 1)

s = (vendor / "src/llhttp.c").read_text()
old = "             llhttp__internal_t*, const char*, const char*);"
assert s.count(old) == 1
s = s.replace(old, "             llhttp__internal_t*, const unsigned char*, const unsigned char*);")
old = "state->_span_cb0)(state, state->_span_pos0, (const char*) endp)"
assert s.count(old) == 1
s = s.replace(old, "state->_span_cb0)(state, state->_span_pos0, (const unsigned char*) endp)")
patch += write("src/llhttp.c", s, 2)

# Generated llhttp.c declares its private callback boundary with unsigned-char
# pointers. Make the out-of-line definitions agree, while retaining the public
# callback API's const-char pointer at the explicit conversion below.
s = (vendor / "src/api.c").read_text()
s, n = re.subn(
    r"(int llhttp__on_[a-z_]+\(llhttp_t\* s, )const char\* p, const char\* endp",
    r"\1const unsigned char* p, const unsigned char* endp", s)
assert n == 25, n
old = "settings->NAME((PARSER), (START), (LEN))"
assert s.count(old) == 1
s = s.replace(old, "settings->NAME((PARSER), (const char*) (START), (LEN))")
patch += write("src/api.c", s, n + 1)

s = (vendor / "src/http.c").read_text()
s, n = re.subn(
    r"(int llhttp__(?:before_headers_complete|after_headers_complete|after_message_complete)\(llhttp_t\* parser, )const char\* p,(\s+)const char\* endp",
    r"\1const unsigned char* p,\2const unsigned char* endp", s)
assert n == 3, n
patch += write("src/http.c", s, n)

results = view / "lmx_adaptation"
results.mkdir(parents=True, exist_ok=True)
(results / "c99_callback.patch").write_text(patch)
(results / "c99_adaptation.json").write_text(json.dumps(changes, indent=2) + "\n")
print(json.dumps(changes, indent=2))

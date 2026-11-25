#!/usr/bin/env python3
"""Name the single public anonymous struct in minmea_type for strict C99.

Source spelling is intentionally .type.fields.sentence_id/.talker_id.
Union size, member byte offsets and algorithms are unchanged. No field macros.
"""
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
args.output.mkdir(parents=True, exist_ok=True)
header = (args.source/"minmea.h").read_text()
before = """  struct {
    char talker_id[2];
    char sentence_id[3];
    char null_terminator;
  };"""
after = before.replace("  };", "  } fields;")
if header.count(before) != 1:
    raise SystemExit("Pinned minmea union changed; manual review required")
new_header = header.replace(before, after)
source = (args.source/"minmea.c").read_text()
new_source, count = re.subn(r"(\.|->)(talker_id|sentence_id|null_terminator)\b",
                            r"\1fields.\2", source)
if count != 24:
    raise SystemExit("Unexpected minmea member access count: " + str(count))
metadata = {"anonymous_structs_named":1,"source_member_accesses":count,
            "public_spelling_change":"type.fields.talker_id / type.fields.sentence_id",
            "algorithm_change":False,"files":[]}
patch = []
for name, old, new in [("minmea.h",header,new_header),("minmea.c",source,new_source)]:
    (args.output/name).write_text(new)
    patch += difflib.unified_diff(old.splitlines(True),new.splitlines(True),
                                  fromfile="upstream/"+name,tofile="build-view/"+name)
    metadata["files"].append({"file":name,
        "original_sha256":hashlib.sha256(old.encode()).hexdigest(),
        "view_sha256":hashlib.sha256(new.encode()).hexdigest()})
(args.output/"minmea.patch").write_text("".join(patch))
(args.output/"minmea-view.json").write_text(json.dumps(metadata,indent=2)+"\n")

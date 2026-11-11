#!/bin/sh
# usage: l1map.sh GENERATION_DIR   (e.g. NS/boot-f12/g2)
# The generated L1 (and L1 headers) a generation's records name, as `hash path-below-the-stage` lines, sorted by path.
# A path named twice with two hashes shows as two lines.
g="$1"
for r in "$g/frontend/record.txt" "$g/runtime/record.txt" "$g/tool/record.txt"; do
    [ -f "$r" ] && grep -E '^[0-9a-f]{64}  .*\.lm1$' "$r"
done | sed -E 's|^([0-9a-f]{64})  .*/fable-main01/(.*)$|\1 \2|' | sort -k2,2 -k1,1 -u

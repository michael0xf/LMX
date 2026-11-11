#!/bin/sh
# usage: rowl1.sh OUT_A OUT_B LIST
# The generated L1 of every program a suite list builds -- OUT/<name>-native/p.lm1 and OUT/<name>-forced/p.lm1 of a
# runs, twins or links row (<name>: the source's file name up to its first dot; a twins row builds its twin too) --
# compared between two suite OUT directories by exact path (nothing is listed).  Prints the programs whose L1 differs
# or is missing on one side, then the counts.
a="$1"; b="$2"; list="$3"
same=0; diff=0; none=0; onesided=0
names=$(awk -F'\t' '/^#/ || NF < 2 { next } $1 == "runs" || $1 == "links" || $1 == "twins" { n = $2; sub(/.*\//, "", n); sub(/\..*$/, "", n); print n } $1 == "twins" { n = $5; sub(/.*\//, "", n); sub(/\..*$/, "", n); print n }' "$list" | sort -u)
for n in $names; do
    for m in native forced; do
        fa="$a/$n-$m/p.lm1"; fb="$b/$n-$m/p.lm1"
        if [ -f "$fa" ] && [ -f "$fb" ]; then
            if cmp -s "$fa" "$fb"; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF $n-$m"; fi
        elif [ -f "$fa" ] || [ -f "$fb" ]; then onesided=$((onesided+1)); echo "ONE-SIDED $n-$m"
        else none=$((none+1)); fi
    done
done
echo "programs with the same L1: $same; with a different L1: $diff; built on one side only: $onesided; built on neither side (mode not asked): $none"

#!/bin/sh
# interp.sh GRAPH-DIR WITH-P0 NAME...  -- from the probe directory: for each NAME.lm2 print its text, the P0 tree when
# WITH-P0 is 1, and the output and exit code of the clean-graph interpreter (`run NAME.lm2 1`) of GRAPH-DIR.
G=$1; P0=$2; shift; shift
for stem in "$@"; do
  echo "=== $stem.lm2"
  cat "$stem.lm2"
  if [ "$P0" = 1 ]; then
    echo "--- p0"
    "$G/graph_trans-prod.exe" 0 entry 0 -- p0 "$stem.lm2" 2>&1 | grep -v l2_eternal_driver
  fi
  echo "--- run"
  "$G/graph_trans-prod.exe" 0 entry 0 -- run "$stem.lm2" 1 > "$stem.interp.tmp" 2>&1; rc=$?
  grep -v l2_eternal_driver "$stem.interp.tmp"
  rm -f "$stem.interp.tmp"
  echo "exit=$rc"
done

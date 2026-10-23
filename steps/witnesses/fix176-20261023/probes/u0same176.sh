#!/bin/bash
# Slice 176's patch replay evidence: GNU patch applies each -U0 delta of the packet to a copy of its Verified175 input
# (runs/replay-patches-01/stage176); the working binary's `same` compares each result with the stage's input.
# Usage: u0same176.sh TOOL
T="$1"
S=/c/Nyasha_Planet/LMX/build2/opus_fix176
V=/c/Nyasha_Planet/LMX/build2/opus_fix175
W=/c/Nyasha_Planet/LMX/steps/witnesses/fix176-20261023
R=$S/runs/replay-patches-01
mkdir -p $R/stage176/src/l2src $S/runs/u0-same-01 || exit 1
for f in l2trans.lm1 lmx_implements.lm1; do
    cp $V/src/l2src/$f $R/stage176/src/l2src/$f || exit 1
    (cd $R && patch -p0 --quiet stage176/src/l2src/$f < $W/$f.patch) || exit 1
done
cd $S/runs/u0-same-01 || exit 1
for f in l2trans.lm1 lmx_implements.lm1; do
    echo "== $f.patch -> $S/src/l2src/$f"
    $T 0 entry 0 -- same C:/Nyasha_Planet/LMX/build2/opus_fix176/runs/replay-patches-01/stage176/src/l2src/$f C:/Nyasha_Planet/LMX/build2/opus_fix176/src/l2src/$f > same-$f.out 2>&1
    echo "exit=$?" >> same-$f.out
    tr -d '\r' < same-$f.out | grep -E '^(SAME|lmx:|exit=)'
done

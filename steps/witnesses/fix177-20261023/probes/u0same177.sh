#!/bin/bash
# Slice 177's patch replay evidence: GNU patch applies each -U0 delta of the packet to a copy of its Verified176 input
# (runs/replay-patches-02/stage177); the working binary's `same` compares each result with the stage's input.
# Usage: u0same177.sh TOOL
T="$1"
S=/c/Nyasha_Planet/LMX/build2/opus_fix177
V=/c/Nyasha_Planet/LMX/build2/opus_fix176
W=/c/Nyasha_Planet/LMX/steps/witnesses/fix177-20261023
R=$S/runs/replay-patches-02
F="l2trans.lm1 lmx_implements.lm1 lmx_walk.lm1 lmx_walk.h.lm1"
if [ -e $R ] || [ -e $S/runs/u0-same-02 ]; then echo "refused: an output exists"; exit 1; fi
mkdir -p $R/stage177/src/l2src $S/runs/u0-same-02 || exit 1
for f in $F; do
    cp $V/src/l2src/$f $R/stage177/src/l2src/$f || exit 1
    (cd $R && patch -p0 --quiet stage177/src/l2src/$f < $W/$f.patch) || exit 1
done
cd $S/runs/u0-same-02 || exit 1
for f in $F; do
    echo "== $f.patch -> $S/src/l2src/$f"
    $T 0 entry 0 -- same C:/Nyasha_Planet/LMX/build2/opus_fix177/runs/replay-patches-02/stage177/src/l2src/$f C:/Nyasha_Planet/LMX/build2/opus_fix177/src/l2src/$f > same-$f.out 2>&1
    echo "exit=$?" >> same-$f.out
    tr -d '\r' < same-$f.out | grep -E '^(SAME|lmx:|exit=)'
done

#!/bin/bash
# Slice 178's patch replay evidence: GNU patch applies each -U0 delta of the packet to a copy of its Verified177 input
# (runs/replay-patches-01/stage178; the new L2 module from an empty file); the working binary's `same` compares each
# result with the stage's input. The stage's lmx_list_owned.lm1 and .h.lm1 are the build's products, regenerated from
# lmx_list_owned.lm2 (runs/regen-*), not replayed here. Usage: u0same178.sh TOOL
T="$1"
S=/c/Nyasha_Planet/LMX/build2/opus_fix178
V=/c/Nyasha_Planet/LMX/build2/opus_fix177
W=/c/Nyasha_Planet/LMX/steps/witnesses/fix178-20261024
R=$S/runs/replay-patches-01
F="l2trans.lm1 lmx_list_owned.lm2"
if [ -e $R ] || [ -e $S/runs/u0-same-01 ]; then echo "refused: an output exists"; exit 1; fi
mkdir -p $R/stage178/src/l2src $S/runs/u0-same-01 || exit 1
cp $V/src/l2src/l2trans.lm1 $R/stage178/src/l2src/l2trans.lm1 || exit 1
: > $R/stage178/src/l2src/lmx_list_owned.lm2 || exit 1
for f in $F; do
    (cd $R && patch -p0 --quiet stage178/src/l2src/$f < $W/$f.patch) || exit 1
done
cd $S/runs/u0-same-01 || exit 1
for f in $F; do
    echo "== $f.patch -> $S/src/l2src/$f"
    $T 0 entry 0 -- same C:/Nyasha_Planet/LMX/build2/opus_fix178/runs/replay-patches-01/stage178/src/l2src/$f C:/Nyasha_Planet/LMX/build2/opus_fix178/src/l2src/$f > same-$f.out 2>&1
    echo "exit=$?" >> same-$f.out
    tr -d '\r' < same-$f.out | grep -E '^(SAME|lmx:|exit=)'
done

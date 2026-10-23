#!/bin/sh
# Slice 176 probe: the links witness (tests/l2/lib) built by one frontend and linked with one runtime, as the runner's
# links row builds it: each library `--library --construct NAME` (under --walk-methods too in the forced mode), the
# owner with `--provider NAME` for each, linked with that mode's objects, run at the root and walked.
# Usage: probe176.sh FRONTEND RUNTIME-DIR OUT-DIR STAGE MODE   (MODE native or forced)
FE="$1"
RT="$2"
P="$3"
STAGE="$4"
MODE="$5"
SRC=$STAGE/src
T=$STAGE/tests/lib
LIB=C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src
GCC=C:/Qt/Tools/mingw1310_64/bin/gcc.exe
CF="-pipe -std=c99 -O2 -fstrict-aliasing -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I $STAGE/headers -I C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes -I C:/Nyasha_Planet/LMX/build2/includes -I C:/Nyasha_Planet/LMX -I C:/Nyasha_Planet/LMX/lm1/build -I $STAGE/src --param ggc-min-heapsize=16384 --param ggc-min-expand=20 -Dmain=l2_generated_main -Dlmx_root_launch=l2_driver_root_launch -Dlmx_merge_owned=l2_driver_merge_owned -Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned -Dlmx_merge_used_owned=l2_driver_merge_used_owned -Dlmx_service_post=l2_driver_service_post"
WALK=""
if [ "$MODE" = forced ]; then WALK="--walk-methods"; fi
mkdir -p "$P"
OBJS=""
PROV=""
for item in lib_a=lib_a_new lib_b=lib_b_new lib_c=lib_c_new lib_m=lib_m_new; do
    L=${item%%=*}
    N=${item#*=}
    (cd $SRC && $FE $WALK --library --construct $N $T/$L.lm2 $LIB/convert.lm2 $LIB/primitive.lm2 $P/$L.lm1 > $P/$L.L2.log 2>&1); echo "$L L2 exit=$?"
    (cd $SRC && /c/Nyasha_Planet/LMX/bin/l1trans.exe $P/$L.lm1 $P/$L.c > $P/$L.L1.log 2>&1); echo "$L L1 exit=$?"
    (cd $SRC && $GCC $CF -c $P/$L.c -o $P/$L.o > $P/$L.CC.log 2>&1); echo "$L CC exit=$?"
    OBJS="$OBJS $P/$L.o"
    PROV="$PROV --provider $N"
done
(cd $SRC && $FE $WALK $PROV $T/lib_owner.lm2 $LIB/convert.lm2 $LIB/primitive.lm2 $P/owner.lm1 > $P/owner.L2.log 2>&1); echo "owner L2 exit=$?"
(cd $SRC && /c/Nyasha_Planet/LMX/bin/l1trans.exe $P/owner.lm1 $P/owner.c > $P/owner.L1.log 2>&1); echo "owner L1 exit=$?"
(cd $SRC && $GCC $CF -c $P/owner.c -o $P/owner.o > $P/owner.CC.log 2>&1); echo "owner CC exit=$?"
$GCC $P/owner.o $RT/driver.o C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o $OBJS -Wl,--strip-debug -o $P/owner.exe > $P/owner.LD.log 2>&1; echo "owner LD exit=$?"
(cd $P && ./owner.exe 0 entry 7 > $P/run-root0.log 2>&1; echo "owner root0 exit=$?")
(cd $P && ./owner.exe 0 entry 7 walkroot 1 > $P/run-root1.log 2>&1; echo "owner root1 exit=$?")
grep -h 'S81\|lmx: invariant\|lmx: R0' $P/run-root0.log $P/run-root1.log | head -20

#!/bin/sh
# Control (175): the 175 witness (tests/l2/lib) built with a given frontend, stage and runtime, run at the root.
# Usage: control174.sh FRONTEND STAGE RUNTIME-DIR OUT-DIR
FE="$1"
STAGE="$2"
RT="$3"
P="$4"
T=C:/Nyasha_Planet/LMX/tests/l2/lib
SRC=$STAGE/src
LIB=C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src
GCC=C:/Qt/Tools/mingw1310_64/bin/gcc.exe
CF="-pipe -std=c99 -O2 -fstrict-aliasing -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I $STAGE/headers -I C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes -I C:/Nyasha_Planet/LMX/build2/includes -I C:/Nyasha_Planet/LMX -I C:/Nyasha_Planet/LMX/lm1/build -I $STAGE/src --param ggc-min-heapsize=16384 --param ggc-min-expand=20 -Dmain=l2_generated_main -Dlmx_root_launch=l2_driver_root_launch -Dlmx_merge_owned=l2_driver_merge_owned -Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned -Dlmx_merge_used_owned=l2_driver_merge_used_owned -Dlmx_service_post=l2_driver_service_post"
mkdir -p $P
for x in a b c; do
    (cd $SRC && $FE --library --construct lib_${x}_new $T/lib_$x.lm2 $LIB/convert.lm2 $LIB/primitive.lm2 $P/lib_$x.lm1 > $P/lib_$x.L2.log 2>&1); echo "lib_$x L2 exit=$?"
    (cd $SRC && /c/Nyasha_Planet/LMX/bin/l1trans.exe $P/lib_$x.lm1 $P/lib_$x.c > $P/lib_$x.L1.log 2>&1); echo "lib_$x L1 exit=$?"
    (cd $SRC && $GCC $CF -c $P/lib_$x.c -o $P/lib_$x.o > $P/lib_$x.CC.log 2>&1); echo "lib_$x CC exit=$?"
done
(cd $SRC && $FE --provider lib_a_new --provider lib_b_new --provider lib_c_new $T/lib_owner.lm2 $LIB/convert.lm2 $LIB/primitive.lm2 $P/owner.lm1 > $P/owner.L2.log 2>&1); echo "owner L2 exit=$?"
(cd $SRC && /c/Nyasha_Planet/LMX/bin/l1trans.exe $P/owner.lm1 $P/owner.c > $P/owner.L1.log 2>&1); echo "owner L1 exit=$?"
(cd $SRC && $GCC $CF -c $P/owner.c -o $P/owner.o > $P/owner.CC.log 2>&1); echo "owner CC exit=$?"
$GCC $P/owner.o $RT/driver.o C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o $P/lib_a.o $P/lib_b.o $P/lib_c.o -Wl,--strip-debug -o $P/owner.exe > $P/owner.LD.log 2>&1; echo "owner LD exit=$?"
(cd $P && ./owner.exe 0 entry 7 > $P/owner.run0.log 2>&1; echo "owner root0 exit=$?")
grep -h 'S81\|lmx: invariant\|l2_eternal_driver' $P/owner.run0.log

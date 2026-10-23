#!/bin/sh
# Probe builds for slice 175 (not suite rows). Usage: probe.sh FRONTEND RUNTIME-DIR PROBE-DIR STAGE
# PROBE-DIR holds this directory's .lm2 sources. Libraries: translate --library --construct, l1trans, gcc -c (each
# step's exit printed). Owners: translate with --provider; probe_owner and probe_owner_d are compiled, linked with
# their libraries and run at the root and walked.
FE="$1"
RT="$2"
P="$3"
STAGE="$4"
SRC=$STAGE/src
LIB=C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src
GCC=C:/Qt/Tools/mingw1310_64/bin/gcc.exe
LIBC=C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o
CF="-pipe -std=c99 -O2 -fstrict-aliasing -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I $STAGE/headers -I C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes -I C:/Nyasha_Planet/LMX/build2/includes -I C:/Nyasha_Planet/LMX -I C:/Nyasha_Planet/LMX/lm1/build -I $STAGE/src --param ggc-min-heapsize=16384 --param ggc-min-expand=20 -Dmain=l2_generated_main -Dlmx_root_launch=l2_driver_root_launch -Dlmx_merge_owned=l2_driver_merge_owned -Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned -Dlmx_merge_used_owned=l2_driver_merge_used_owned -Dlmx_service_post=l2_driver_service_post"
l1 () {
    (cd $SRC && /c/Nyasha_Planet/LMX/bin/l1trans.exe $P/$1.lm1 $P/$1.c > $P/$1.L1.log 2>&1); echo "$1 L1 exit=$?"
    (cd $SRC && $GCC $CF -c $P/$1.c -o $P/$1.o > $P/$1.CC.log 2>&1); echo "$1 CC exit=$?"
}
lib () {
    (cd $SRC && $FE --library --construct "$2" $P/$1.lm2 $LIB/convert.lm2 $LIB/primitive.lm2 $P/$1.lm1 > $P/$1.L2.log 2>&1); echo "$1 L2 exit=$?"
    l1 $1
}
owner () {
    name="$1"; shift
    (cd $SRC && $FE "$@" $P/$name.lm2 $LIB/convert.lm2 $LIB/primitive.lm2 $P/$name.lm1 > $P/$name.L2.log 2>&1); echo "$name L2 exit=$?"
}
run () {
    name="$1"; shift
    $GCC $P/$name.o $RT/driver.o $LIBC "$@" -Wl,--strip-debug -o $P/$name.exe > $P/$name.LD.log 2>&1; echo "$name LD exit=$?"
    (cd $P && ./$name.exe 0 entry 7 > $P/$name.run0.log 2>&1; echo "$name root0 exit=$?")
    (cd $P && ./$name.exe 0 entry 7 walkroot 1 > $P/$name.run1.log 2>&1; echo "$name root1 exit=$?")
    grep -h 'PROBE175\|l2_eternal_driver' $P/$name.run0.log $P/$name.run1.log
}
lib lib_t7 lib_t7_new
lib lib_s lib_s_new
lib lib_r lib_r_new
lib lib_d lib_d_new
owner bad_provider --provider lib_a_new
grep -h 'incompatible entry signature' $P/bad_provider.L2.log
owner probe_owner --provider lib_r_new --provider lib_d_new
l1 probe_owner
run probe_owner $P/lib_r.o $P/lib_d.o $P/lib_s.o
grep -c 'multiple definition' $P/probe_owner.LD.log
owner probe_owner_d --provider lib_d_new
l1 probe_owner_d
run probe_owner_d $P/lib_d.o

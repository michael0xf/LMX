#!/bin/bash
# A probe frontend of slice 178's stage: the stage's l2trans.lm1 translated by l1trans and compiled once, as
# bld_frontend does (tools/l2/build.lm2), into runs/LABEL; no smoke. Usage: fe_probe.sh LABEL
L="$1"
S=/c/Nyasha_Planet/LMX/build2/opus_fix178
O=$S/runs/$L
if [ -z "$L" ] || [ -e "$O" ]; then echo "refused: a new label for every attempt"; exit 1; fi
mkdir -p "$O" || exit 1
cp $S/src/l2src/l2trans.lm1 $O/frontend-source.lm1 || exit 1
cd $S/src || exit 1
/c/Nyasha_Planet/LMX/bin/l1trans.exe C:/Nyasha_Planet/LMX/build2/opus_fix178/runs/$L/frontend-source.lm1 C:/Nyasha_Planet/LMX/build2/opus_fix178/runs/$L/frontend.c > $O/L1.log 2>&1
r=$?
echo "l1trans exit=$r"
if [ $r -ne 0 ]; then tr -d '\r' < $O/L1.log | head -5; exit 2; fi
C:/Qt/Tools/mingw1310_64/bin/gcc.exe -pipe -std=c99 -O0 -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I C:/Nyasha_Planet/LMX/build2/opus_fix178/headers -I C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes -I C:/Nyasha_Planet/LMX/build2/includes -I C:/Nyasha_Planet/LMX -I C:/Nyasha_Planet/LMX/lm1/build -I C:/Nyasha_Planet/LMX/build2/opus_fix178/src --param ggc-min-heapsize=16384 --param ggc-min-expand=20 C:/Nyasha_Planet/LMX/build2/opus_fix178/runs/$L/frontend.c C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o -o C:/Nyasha_Planet/LMX/build2/opus_fix178/runs/$L/l2trans.exe > $O/COMPILE.log 2>&1
r=$?
echo "gcc exit=$r"
if [ $r -ne 0 ]; then tr -d '\r' < $O/COMPILE.log | grep -E 'error' | head -10; exit 3; fi
sha256sum $O/frontend-source.lm1 $O/l2trans.exe

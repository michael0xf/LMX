#!/bin/bash
# A mutant frontend of slice 178: the mutated translator SOURCE (a copy, build2/opus_mut178b/mut/*.lm1) lowered by
# l1trans and compiled once as bld_frontend compiles the frontend (tools/l2/build.lm2), cwd and headers the mutant
# stage's, into opus_mut178b/runs/LABEL; no smoke. Usage: fe_mut178.sh SOURCE LABEL
SRC="$1"
L="$2"
M=/c/Nyasha_Planet/LMX/build2/opus_mut178b
O=$M/runs/$L
if [ -z "$L" ] || [ -e "$O" ]; then echo "refused: a new label for every attempt"; exit 1; fi
mkdir -p "$O" || exit 1
cp "$SRC" $O/frontend-source.lm1 || exit 1
cd $M/src || exit 1
/c/Nyasha_Planet/LMX/bin/l1trans.exe C:/Nyasha_Planet/LMX/build2/opus_mut178b/runs/$L/frontend-source.lm1 C:/Nyasha_Planet/LMX/build2/opus_mut178b/runs/$L/frontend.c > $O/L1.log 2>&1
r=$?
echo "l1trans exit=$r"
if [ $r -ne 0 ]; then tr -d '\r' < $O/L1.log | head -5; exit 2; fi
C:/Qt/Tools/mingw1310_64/bin/gcc.exe -pipe -std=c99 -O0 -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I C:/Nyasha_Planet/LMX/build2/opus_mut178b/headers -I C:/Nyasha_Planet/LMX/buold_temp/codex_header98_source_control_06/includes -I C:/Nyasha_Planet/LMX/build2/includes -I C:/Nyasha_Planet/LMX -I C:/Nyasha_Planet/LMX/lm1/build -I C:/Nyasha_Planet/LMX/build2/opus_mut178b/src --param ggc-min-heapsize=16384 --param ggc-min-expand=20 C:/Nyasha_Planet/LMX/build2/opus_mut178b/runs/$L/frontend.c C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o -o C:/Nyasha_Planet/LMX/build2/opus_mut178b/runs/$L/l2trans.exe > $O/COMPILE.log 2>&1
r=$?
echo "gcc exit=$r"
if [ $r -ne 0 ]; then tr -d '\r' < $O/COMPILE.log | grep -E 'error' | head -10; exit 3; fi
sha256sum $O/frontend-source.lm1 $O/l2trans.exe

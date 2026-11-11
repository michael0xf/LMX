#!/bin/sh
# runprobe.sh FE SOURCE.lm2 EXPECT [modes]  -- from the probe directory: translate SOURCE with the cold frontend FE
# (native and --walk-methods), then finish as the suite does (its record.txt): l1trans, gcc -c, link with driver.o and
# l2_libc.o, run `p-prod.exe 0 entry EXPECT` and the same with `walkroot 1`.  One line per mode.
# Artifacts: <stem>-r<mode>/p.lm1, p.c, p.o, p-prod.exe, *.log in the current directory.
FE=$1; SRC=$2; EXP=$3; MODES=${4:-"n f"}
PW=C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01
NS=$PW/fable-main01
BOOT=$NS/boot-f18/g2
GCC=C:/Qt/Tools/mingw1310_64/bin/gcc.exe
stem=$(basename "$SRC" .lm2)
for mode in $MODES; do
  d=$stem-r$mode
  mkdir -p "$d"
  if [ "$mode" = n ]; then "$FE" "$SRC" $NS/src/l2src/convert.lm2 $NS/src/l2src/primitive.lm2 "$d/p.lm1" > "$d/p.L2.log" 2>&1; rc=$?
  else "$FE" --walk-methods "$SRC" $NS/src/l2src/convert.lm2 $NS/src/l2src/primitive.lm2 "$d/p.lm1" > "$d/p.L2.log" 2>&1; rc=$?; fi
  if [ $rc -ne 0 ]; then echo "$stem $mode L2 rc=$rc $(grep -v l2_eternal_driver "$d/p.L2.log" | head -1 | cut -c1-220)"; continue; fi
  here=$(pwd -W 2>/dev/null || pwd)
  ( cd /c/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/fable-main01/src && "$BOOT/frontend/l1trans.exe" "$here/$d/p.lm1" "$here/$d/p.c" ) > "$d/p.L1.log" 2>&1; rc=$?
  if [ $rc -ne 0 ]; then echo "$stem $mode L1 rc=$rc $(head -2 "$d/p.L1.log" | cut -c1-220 | tr '\n' '|')"; continue; fi
  "$GCC" -pipe -std=c99 -O2 -fstrict-aliasing -DLMX_OBSERVE_WALK=0 -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I $NS/headers --param ggc-min-heapsize=16384 --param ggc-min-expand=20 -Dmain=l2_generated_main -Dlmx_root_launch=l2_driver_root_launch -Dlmx_merge_owned=l2_driver_merge_owned -Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned -Dlmx_merge_used_owned=l2_driver_merge_used_owned -Dlmx_service_post=l2_driver_service_post -c "$d/p.c" -o "$d/p.o" > "$d/p.CC.log" 2>&1; rc=$?
  if [ $rc -ne 0 ]; then echo "$stem $mode CC rc=$rc $(grep -m2 -i error "$d/p.CC.log" | cut -c1-220 | tr '\n' '|')"; continue; fi
  "$GCC" "$d/p.o" $BOOT/runtime/driver.o $BOOT/frontend/l2_libc.o -Wl,--strip-debug -o "$d/p-prod.exe" > "$d/p.LD.log" 2>&1; rc=$?
  if [ $rc -ne 0 ]; then echo "$stem $mode LD rc=$rc $(head -2 "$d/p.LD.log" | cut -c1-220 | tr '\n' '|')"; continue; fi
  ( cd "$d" && ./p-prod.exe 0 entry "$EXP" > run-root0.log 2>&1; echo $? > run-root0.rc )
  ( cd "$d" && ./p-prod.exe 0 entry "$EXP" walkroot 1 > run-root1.log 2>&1; echo $? > run-root1.rc )
  echo "$stem $mode run(expect $EXP): root0 rc=$(cat "$d/run-root0.rc") root1 rc=$(cat "$d/run-root1.rc") $(head -1 "$d/run-root0.log" | cut -c1-160)"
done

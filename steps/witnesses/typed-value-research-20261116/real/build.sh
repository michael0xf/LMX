#!/usr/bin/env bash
# FABLE-R-TV-D (opus, 2026-11-16): builds bench-time.exe and bench-mem.exe against the accepted G2 runtime.
# Run only on fable_pc's signal.  Nothing in selfbuild or in the accepted stage is written; outputs go to $OUT.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
GCC=${GCC:-C:/Qt/Tools/mingw1310_64/bin/gcc.exe}
S=${S:-C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/sol-m14-field-values-01}
G2=${G2:-$S/boot-f410-02/g2}
RT=${RT:-$G2/runtime}
FE=${FE:-$G2/frontend}
HDR=${HDR:-$S/headers}
OUT=${OUT:-C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/opus/tv-real}
mkdir -p "$OUT"

# The compile flags of an emitted fixture p.c (f410-baseline-full-01/<fixture>-native/p.CC.log), without -H.
PFLAGS="-pipe -std=c99 -O2 -fstrict-aliasing -DLMX_OBSERVE_WALK=0 -Wall -Wextra -Werror=implicit-function-declaration \
-Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I $HDR \
--param ggc-min-heapsize=16384 --param ggc-min-expand=20 -Dmain=l2_generated_main \
-Dlmx_root_launch=l2_driver_root_launch -Dlmx_merge_owned=l2_driver_merge_owned \
-Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned -Dlmx_merge_used_owned=l2_driver_merge_used_owned \
-Dlmx_service_post=l2_driver_service_post"

{
    echo "# tv-real build $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "# RT=$RT FE=$FE HDR=$HDR"
    sha256sum "$RT/driver.o" "$FE/l2_libc.o" "$HERE/tv_real_bench.c"
    # One hash of the whole header tree the bench was compiled against (S/headers is rewritten by later builds).
    echo "$( (cd "$HDR" && find . -name '*.h' -type f | LC_ALL=C sort | xargs sha256sum) | sha256sum | cut -d' ' -f1)  headers-tree $HDR"
} > "$OUT/build-record.txt"

"$GCC" $PFLAGS -c "$HERE/tv_real_bench.c" -o "$OUT/bench-time.o" 2> "$OUT/bench-time.CC.log"
"$GCC" $PFLAGS -DTV_WRAP=1 -c "$HERE/tv_real_bench.c" -o "$OUT/bench-mem.o" 2> "$OUT/bench-mem.CC.log"
# The link line of an emitted fixture (p-prod.LD.log): p.o driver.o l2_libc.o -Wl,--strip-debug.
"$GCC" "$OUT/bench-time.o" "$RT/driver.o" "$FE/l2_libc.o" -Wl,--strip-debug -o "$OUT/bench-time.exe" \
    2> "$OUT/bench-time.LD.log"
"$GCC" "$OUT/bench-mem.o" "$RT/driver.o" "$FE/l2_libc.o" -Wl,--strip-debug \
    -Wl,--wrap=calloc,--wrap=malloc,--wrap=realloc,--wrap=free -o "$OUT/bench-mem.exe" 2> "$OUT/bench-mem.LD.log"
sha256sum "$OUT/bench-time.exe" "$OUT/bench-mem.exe" >> "$OUT/build-record.txt"
echo "built: $OUT/bench-time.exe $OUT/bench-mem.exe (record: $OUT/build-record.txt)"

#!/bin/sh
# Builds the prototype: bench and sizes per representation (plain and +native word) and the gcc -S listings.
# Compile only; nothing is run here.  Usage: sh build.sh [rep ...]   (default: all nine + tv_packed_map + tv_align_noline)
# tv_packed_map = tv_packed with -DPK_START_MAP=1 (record-start bitmap kept at every allocation, checked type_of_address).
# tv_align_noline = tv_align with -DTA_LINE_RULE=0 (no 64-byte line rule, no hole).
# 2x2 controls: tv_word (unaligned x memcpy), tv_word_typed (unaligned x typed, GNU aligned(1)), tv_align_memcpy (aligned x memcpy), tv_align (aligned x typed).
# tv_word_raw8 / tv_align_raw8: dense storage aligned on 8 instead of 64 (-DTV_RAW_ALIGN=8 does it for the other tv_* representations).
set -e
CC=${CC:-/c/Qt/Tools/mingw1310_64/bin/gcc.exe}
EXE=${EXE:-.exe}
FLAGS="-std=c99 -O2 -fstrict-aliasing -Wall -Wextra -I."
cd "$(dirname "$0")"
mkdir -p bin asm
REPS="$*"
[ -n "$REPS" ] || REPS="tv_align tv_align_noline tv_word tv_word_typed tv_align_memcpy tv_word_raw8 tv_align_raw8 tv_prefix tv_tagged cur_range cur_chunkhdr tv_packed tv_packed_map tv_full tv_compact"
for rep in $REPS; do
    echo "== $rep"
    NAME=$rep
    EXTRA=""
    if [ "$rep" = "tv_packed_map" ]; then
        NAME=tv_packed
        EXTRA="-DPK_START_MAP=1"
    fi
    if [ "$rep" = "tv_align_noline" ]; then
        NAME=tv_align
        EXTRA="-DTA_LINE_RULE=0"
    fi
    # controls separating the cost of unaligned addresses from the cost of memcpy access (2x2 with tv_word / tv_align)
    if [ "$rep" = "tv_word_typed" ]; then
        NAME=tv_word
        EXTRA="-DTW_TYPED_UNALIGNED=1"
    fi
    if [ "$rep" = "tv_align_memcpy" ]; then
        NAME=tv_align
        EXTRA="-DTA_MEMCPY=1"
    fi
    # the earlier dense-storage placement (8-byte alignment instead of 64)
    if [ "$rep" = "tv_word_raw8" ]; then
        NAME=tv_word
        EXTRA="-DTW_RAW_ALIGN=8"
    fi
    if [ "$rep" = "tv_align_raw8" ]; then
        NAME=tv_align
        EXTRA="-DTA_RAW_ALIGN=8"
    fi
    $CC $FLAGS -DREP=$NAME $EXTRA -o bin/bench_$rep$EXE bench_main.c
    $CC $FLAGS -DREP=$NAME $EXTRA -DLMX_NATIVE_WORD=1 -o bin/bench_${rep}_nw$EXE bench_main.c
    $CC $FLAGS -DREP=$NAME $EXTRA -S -o asm/bench_$rep.s bench_main.c
    $CC $FLAGS -DREP=$NAME $EXTRA -o bin/sizes_$rep$EXE programs/sizes.c
    $CC $FLAGS -DREP=$NAME $EXTRA -DLMX_NATIVE_WORD=1 -o bin/sizes_${rep}_nw$EXE programs/sizes.c
done
echo "build ok"

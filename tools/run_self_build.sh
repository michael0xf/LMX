#!/bin/sh
# Self-build of the live L1 chain -- the PORTABLE twin of tools/run_self_build.ps1, added
# 20.09.2026 because the convergence cycle existed only as a PowerShell script while the
# bootstrap had both twins (bootstrap_l1.sh / bootstrap_l1.bat).  A self-build that can only be
# driven from Windows is not the cross-platform property the acceptance requires: the cycle
# itself has to run on Ubuntu and Mac, and this is that half.
#
# It is a PORT, not a rewrite: same seed, same eight generated files, same three passes, same
# three verdicts, same exit code.  What differs is only what the platform forces -- gcc and git
# are invoked without a shell wrapper, and equality is cmp(1) instead of a file hash, which is
# the same question asked with the tools this side has.
#
# B0 is gcc of lm1/build/l1trans.lm1.c AS CHECKED OUT (the seed is VERSIONED; without it the
# self-build cannot start at all).  Pass 1: B0 regenerates the eight generated files of
# l1src/buildCore.lm1's lm_build_generate_all map into a stamped directory.  B1 from pass 1's
# l1trans.lm1.c, pass 2; B2 from pass 2's, pass 3.  Green is the fixed point: pass 3 == pass 2
# byte for byte.
#
# TWO seed comparisons are reported beside it, and they answer DIFFERENT questions:
#   * working-tree seed vs fixed point -- is the file on disk what the build converges to;
#   * HEAD:path blob vs fixed point    -- is what a CLEAN CLONE gets the same.  The second is the
#     property that makes a checkout reproducible, and it is not the same question: a local edit
#     to the seed moves the first and not the second.
# Executables are compared by nothing: gcc output here is not byte-reproducible from identical C.
#
#   tools/run_self_build.sh
#   OUT_DIR=/tmp/sb LM_CC=clang tools/run_self_build.sh
set -u

for arg in "$@"; do
    case "$arg" in
        -h|--help) sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "run_self_build.sh: unexpected argument: $arg" >&2; exit 2 ;;
    esac
done

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo=$(CDPATH= cd -- "$script_dir/.." && pwd)
cd "$repo" || { echo "run_self_build.sh: cannot enter $repo" >&2; exit 1; }

: "${LM_CC:=gcc}"
: "${LM_HASH_CMD:=git}"
OUT_DIR=${OUT_DIR:-"$repo/build/self_build/$(date +%Y%m%d_%H%M%S)_$$"}
LOG_DIR=$OUT_DIR/logs

MAP='l1src/p0.h.lm1|lm1/build/l1src/p0.lm1.h
l1src/own.lm1|lm1/build/own.lm1.c
l1src/parser.lm1|lm1/build/parser.lm1.c
l1src/l1trans.lm1|lm1/build/l1trans.lm1.c
l1src/printTree.lm1|lm1/build/printTree.lm1.c
l1src/finalize.lm1|lm1/build/finalize.lm1.c
l1src/make.lm1|lm1/build/make.lm1.c
l1src/buildCore.lm1|lm1/build/buildCore.lm1.c'

# The same flags the .ps1 uses for B0 and for every translator rebuild, so the twins cannot
# drift: -I . and the pass's own lm1/build are the include roots.
FLAGS='-std=c99 -Wall -Wextra -Wpedantic -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -Werror=implicit-function-declaration -Werror=implicit-int'

# The registry variables would make the translator take a different path; the .ps1 clears them,
# and a twin that did not would measure a different program.
unset LM_TRANS_REGISTRY LM_TRANS_REGISTRY_VIEW LM_P0_REGISTRY LM_P0_COMPARE_REGISTRY 2>/dev/null || :

mkdir -p "$LOG_DIR" "$OUT_DIR/b0" "$OUT_DIR/b1" "$OUT_DIR/b2" \
         "$OUT_DIR/pass1/lm1/build/l1src" "$OUT_DIR/pass2/lm1/build/l1src" "$OUT_DIR/pass3/lm1/build/l1src" || exit 1
printf '%s\n' "$MAP" > "$LOG_DIR/map.txt"

head=$(git rev-parse HEAD 2>/dev/null || echo unknown)
dirty=$(git status --porcelain -uno -- l1src lm1/build | wc -l | tr -d ' ')
echo "self-build on $(printf '%s' "$head" | cut -c1-8); tracked changes under l1src and lm1/build: $dirty; evidence $OUT_DIR"
echo "self-build: compiler $LM_CC; portable cycle tools/run_self_build.sh"

started=$(date +%s)
: > "$LOG_DIR/red.txt"
red() { printf '%s\n' "$1" >> "$LOG_DIR/red.txt"; }

build_translator() {   # label include_dir source exe
    _label=$1; _inc=$2; _src=$3; _exe=$4
    # shellcheck disable=SC2086
    $LM_CC $FLAGS -I . -I "$_inc" -o "$_exe" "$_src" > "$LOG_DIR/$_label.gcc.log" 2>&1
    if [ $? -ne 0 ] || [ ! -f "$_exe" ]; then
        red "$_label gcc failed (log $LOG_DIR/$_label.gcc.log)"
        return 1
    fi
    return 0
}

run_pass() {           # label exe dir
    _label=$1; _exe=$2; _dir=$3
    while IFS='|' read -r _src _dst; do
        [ -n "$_src" ] || continue
        _out=$_dir/$_dst
        mkdir -p "$(dirname -- "$_out")" || { red "$_label mkdir $_dst"; continue; }
        "$_exe" "$_src" "$_out" > "$LOG_DIR/$_label.$(basename -- "$_dst").log" 2>&1
        if [ $? -ne 0 ] || [ ! -f "$_out" ]; then
            red "$_label translate $_src failed (log $LOG_DIR/$_label.$(basename -- "$_dst").log)"
        fi
    done < "$LOG_DIR/map.txt"
}

blob_of() {            # committed_path file  -> blob id, or empty
    [ -f "$2" ] || { printf ''; return; }
    git hash-object "--path=$1" -- "$2" 2>/dev/null | tr -d '\r\n'
}

# Windows appends .exe to gcc's output, POSIX does not -- and the difference must be handled
# HERE, not by a tolerant file test, because the built translator is also EXECUTED a few lines
# down and a wrong path would be reported as a failed build rather than as a missing suffix.
case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW*|MSYS*|CYGWIN*) EXE_EXT=.exe ;;
    *)                    EXE_EXT= ;;
esac

B0=$OUT_DIR/b0/l1trans$EXE_EXT
build_translator b0 lm1/build "lm1/build/l1trans.lm1.c" "$B0" && run_pass pass1 "$B0" "$OUT_DIR/pass1"
B1=$OUT_DIR/b1/l1trans$EXE_EXT
if [ -f "$OUT_DIR/pass1/lm1/build/l1trans.lm1.c" ]; then
    build_translator b1 "$OUT_DIR/pass1/lm1/build" "$OUT_DIR/pass1/lm1/build/l1trans.lm1.c" "$B1" && run_pass pass2 "$B1" "$OUT_DIR/pass2"
fi
B2=$OUT_DIR/b2/l1trans$EXE_EXT
if [ -f "$OUT_DIR/pass2/lm1/build/l1trans.lm1.c" ]; then
    build_translator b2 "$OUT_DIR/pass2/lm1/build" "$OUT_DIR/pass2/lm1/build/l1trans.lm1.c" "$B2" && run_pass pass3 "$B2" "$OUT_DIR/pass3"
fi

fixed=0; committed_eq=0; b0_eq=0; head_eq=0
while IFS='|' read -r src dst; do
    [ -n "$src" ] || continue
    f1=$OUT_DIR/pass1/$dst; f2=$OUT_DIR/pass2/$dst; f3=$OUT_DIR/pass3/$dst
    if [ -f "$f2" ] && [ -f "$f3" ] && cmp -s "$f2" "$f3"; then
        fixed=$((fixed + 1))
    else
        red "fixed point $dst: pass 3 differs from pass 2"
    fi
    committed_blob=$(blob_of "$dst" "$dst")
    fixed_blob=$(blob_of "$dst" "$f2")
    if [ -n "$committed_blob" ] && [ "$committed_blob" = "$fixed_blob" ]; then
        committed_eq=$((committed_eq + 1))
    else
        red "committed $dst ${committed_blob:-absent} differs from the fixed point ${fixed_blob:-absent}"
    fi
    if [ -n "$committed_blob" ] && [ "$committed_blob" = "$(blob_of "$dst" "$f1")" ]; then
        b0_eq=$((b0_eq + 1))
    fi
    # What a CLEAN CLONE would get: the blob in HEAD, not the file on disk.
    head_blob=$(git rev-parse "HEAD:$dst" 2>/dev/null | tr -d '\r\n')
    if [ -n "$head_blob" ] && [ "$head_blob" = "$fixed_blob" ]; then
        head_eq=$((head_eq + 1))
    fi
done < "$LOG_DIR/map.txt"

sec=$(( $(date +%s) - started ))
echo "working-tree seed (B0 input) regenerates $b0_eq of 8 committed files unchanged (reported, not decisive)"
echo "HEAD:path seed blobs $head_eq of 8 equal to the fixed point -- this is what a CLEAN CLONE gets (the working-tree count above is a different question)"

reds=$(wc -l < "$LOG_DIR/red.txt" | tr -d ' ')
if [ "$reds" -gt 0 ]; then
    while IFS= read -r line; do echo "RED $line"; done < "$LOG_DIR/red.txt"
    echo "self-build FAIL: fixed point $fixed of 8 (pass 3 == pass 2), working-tree seed C $committed_eq of 8 equal to the fixed point, in ${sec}s; evidence $OUT_DIR"
    exit 1
fi
echo "self-build PASS: fixed point 8 of 8 (pass 3 == pass 2), working-tree seed C 8 of 8 equal to the fixed point, in ${sec}s; evidence $OUT_DIR"
exit 0

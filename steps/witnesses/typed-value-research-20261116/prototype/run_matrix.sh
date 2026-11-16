#!/bin/sh
# Prints (RUN=1: also runs) the measurement matrix.  Not run by the author of the prototype: measurements belong to the pipeline owner.
# Usage: RUN=1 sh run_matrix.sh [small|large] [rep ...]  > results.tsv
SIZE=${1:-small}
[ $# -gt 0 ] && shift
REPS="$*"
[ -n "$REPS" ] || REPS="tv_align tv_align_noline tv_word tv_word_typed tv_align_memcpy tv_word_raw8 tv_align_raw8 tv_prefix tv_tagged cur_range cur_chunkhdr tv_packed tv_packed_map tv_full tv_compact"
cd "$(dirname "$0")"
EXE=${EXE:-.exe}
if [ "$SIZE" = small ]; then
    T1="64 8 20000 9 1"; T1W="64 8 20000 9 1"; T2="64 12 10000 9 1"; T3="64 12 256 2000000 10000 9 1"
    T4="64 100000 9 1"; T5="200 5 2000 1"; T6="1024 10000 9 1"; T7="64 12 10000 9 1"
else
    T1="500000 8 1 5 1"; T1W="300000 8 1 5 1"; T2="200000 12 1 5 1"; T3="150000 12 2000000 4000000 1 5 1"
    T4="1000000 1 5 1"; T5="600000 5 3 1"; T6="50000000 1 5 1"; T7="200000 12 1 5 1"
fi
go() {
    echo "# $*" >&2
    if [ "$RUN" = 1 ]; then "$@"; fi
}
for r in $REPS; do
    b=bin/bench_$r$EXE
    for st in "" "--straddle"; do
        go $b $st t1 $T1
        go $b $st t1w $T1W
        go $b $st t2 $T2
        go $b $st t3 $T3
        go $b $st t3w $T3
        go $b $st t4 $T4
        go $b $st t4w $T4
        go $b $st t5 $T5
        go $b $st t7 $T7
    done
    go $b t6 $T6
done

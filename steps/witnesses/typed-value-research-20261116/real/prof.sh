#!/usr/bin/env bash
# FABLE-R-TV-D item 5 (opus, 2026-11-16): a whole fixture run under the profiler.  Run only on fable_pc's signal.
#
# The accepted G2's driver.c is compiled again into $OUT/prof (never over the accepted driver.o) twice:
#   pg  -- with -pg, for gprof: time shares and the calls of the functions that stay out of line;
#   cyg -- with -finstrument-functions plus tv_cyg_hooks.c: exact entry counts of every function, inlined copies
#          included (driver.c is one translation unit, so -O2 inlines many runtime functions and mcount misses them).
# Each is linked with the fixture's forced p.o (as p-prod.exe is) and run for both roots; the same is done for a control
# fixture, and the scenario's counts minus the control's are the program's own work (the driver's self-checks --
# ids, code links, activation -- run in both and cancel).
#
# driver.c must be compiled against the headers it was generated with, and p.o must come from the same build: with
# RT, HDR and FIXDIR of different builds, either the compile stops (prototype drift) or the ABI may differ silently.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
GCC=${GCC:-C:/Qt/Tools/mingw1310_64/bin/gcc.exe}
GPROF=${GPROF:-C:/Qt/Tools/mingw1310_64/bin/gprof.exe}
NM=${NM:-C:/Qt/Tools/mingw1310_64/bin/nm.exe}
S=${S:-C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/sol-m14-field-values-01}
G2=${G2:-$S/boot-f410-02/g2}
RT=${RT:-$G2/runtime}
FE=${FE:-$G2/frontend}
HDR=${HDR:-$S/headers}
FIXDIR=${FIXDIR:-$S/f410-g2-full-01}
FIX=${FIX:-private_hidden_binding}
CTRL=${CTRL:-assign_known}
# Optional second scenario: the clean graph's interpreter (graph-check `run` mode).  GRAPHDIR is a build-graph output
# of the SAME G2 and headers (it holds graph_trans.o); the tool is relinked from that object with the instrumented
# driver, as build-graph links it with driver.o.  Unset GRAPHDIR skips it.
GRAPHDIR=${GRAPHDIR:-}
GSRC=${GSRC:-$S/tests/graph}
GFIX=${GFIX:-control_flow}
GCTRL=${GCTRL:-data_write}
VARIANTS=${VARIANTS:-cyg}
OUT=${OUT:-C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/opus/tv-real}
P=$OUT/prof
mkdir -p "$P"
TARGETS="lmx_range_entry_at lmx_range_cell_pool lmx_range_classify lmx_range_type_of lmx_graph_value_in \
lmx_source_name_local lmx_arena_find_profiled lmx_range_stride lmx_range_entry_chunk lmx_graph_cell_in \
lmx_graph_node_in lmx_graph_backing_cell_in lmx_pool_chunk_at lmx_value_context_cell_in lmx_arena_index_data \
lmx_arena_index_len lmx_walk_value_cell lmx_domain_kind lmx_domain_type"

# The compile flags of the accepted driver.c (o410-rt-01/record.txt, the build-runtime record), without -H.
DFLAGS="-pipe -std=c99 -O2 -fstrict-aliasing -DLMX_OBSERVE_WALK=0 -Wall -Wextra -Werror=implicit-function-declaration \
-Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I $HDR \
--param ggc-min-heapsize=16384 --param ggc-min-expand=20"

REC=$P/prof-record.txt
{
    echo "# tv-real prof $(date -u +%Y-%m-%dT%H:%M:%SZ) FIX=$FIX CTRL=$CTRL VARIANTS=$VARIANTS"
    echo "# RT=$RT FE=$FE HDR=$HDR FIXDIR=$FIXDIR"
    sha256sum "$RT/driver.c" "$RT/driver.o" "$FE/l2_libc.o" "$FIXDIR/$FIX-forced/p.o" "$FIXDIR/$CTRL-forced/p.o"
} > "$REC"

# run_fixture EXE DIR ROOT: root 0 and root 1 as the suite runs them (f410-baseline-full-01/record.txt).
run_fixture() {
    local exe=$1 dir=$2 root=$3
    mkdir -p "$dir"
    (
        cd "$dir" || exit 1
        rm -f gmon.out cyg-counts.txt
        if [ "$root" = 0 ]; then
            LMX_CYG_OUT="$dir/cyg-counts.txt" "$exe" 0 entry 7 > run.log 2>&1
        else
            LMX_CYG_OUT="$dir/cyg-counts.txt" "$exe" 0 entry 7 walkroot 1 > run.log 2>&1
        fi
        echo "exit $?" >> run.log
    )
    echo "$exe root$root: $(tail -1 "$dir/run.log")" >> "$REC"
}

# run_graph EXE DIR SOURCE: the clean graph's interpreter, as graph-check runs it (`-- run SOURCE 1`).
run_graph() {
    local exe=$1 dir=$2 source=$3
    mkdir -p "$dir"
    (
        cd "$dir" || exit 1
        rm -f gmon.out cyg-counts.txt
        LMX_CYG_OUT="$dir/cyg-counts.txt" "$exe" 0 entry 0 -- run "$source" 1 > run.log 2>&1
        echo "exit $?" >> run.log
    )
    echo "$exe run $source: $(tail -1 "$dir/run.log")" >> "$REC"
}

# gprof flat profile -> TSV: function pct_time self_seconds calls (calls empty for a function without mcount).
flat_tsv() {
    awk 'BEGIN { OFS = "\t" }
         /^ *%/ || /^ *time/ || /^Flat/ || /^Each sample/ || NF == 0 { next }
         NF >= 7 && $1 ~ /^[0-9.]+$/ { print $7, $1, $3, $4; next }
         NF >= 4 && $1 ~ /^[0-9.]+$/ { print $NF, $1, $3, ""; next }' "$1"
}

# cyg counts -> TSV: function count, by the executable's symbols (corrected for an image relocation, if any).
cyg_tsv() {
    local counts=$1 nmfile=$2
    awk -v nmfile="$nmfile" '
        BEGIN {
            while ((getline line < nmfile) > 0) {
                n = split(line, f, " ")
                if (n >= 3) {
                    a = tolower(f[1])
                    if (!(a in name)) name[a] = f[3]
                    if (f[3] == "__cyg_profile_func_enter") selfstatic = strtonum("0x" a)
                }
            }
        }
        /^#self / { slide = strtonum("0x" $2) - selfstatic; next }
        /^#/ { next }
        { addr = strtonum("0x" $1) - slide; key = sprintf("%016x", addr); print ((key in name) ? name[key] : "?" $1) "\t" $2 }
    ' "$counts" | sort -t "$(printf '\t')" -k2,2nr
}

# summary rows: variant fixture root kind function value1 value2 value3
summarize() {
    local variant=$1 fx=$2 root=$3 tsv=$4
    local t
    for t in $TARGETS; do
        awk -F'\t' -v t="$t" -v v="$variant" -v fx="$fx" -v r="$root" 'BEGIN { OFS = "\t"; found = 0 }
            $1 == t { print v, fx, "root" r, "target", $1, $2, $3, $4; found = 1 }
            END { if (!found) print v, fx, "root" r, "target", t, "absent", "", "" }' "$tsv"
    done
    head -20 "$tsv" | awk -F'\t' -v v="$variant" -v fx="$fx" -v r="$root" 'BEGIN { OFS = "\t" }
        { print v, fx, "root" r, "top20", $1, $2, $3, $4 }'
}

# delta rows: the scenario's count minus the control's, by function (count column: pg = 4th, cyg = 2nd).
delta() {
    local variant=$1 root=$2 a=$3 b=$4 col=$5
    awk -F'\t' -v col="$col" -v v="$variant" -v r="$root" 'BEGIN { OFS = "\t" }
        NR == FNR { ctrl[$1] = $col + 0; next }
        { d = ($col + 0) - ((($1) in ctrl) ? ctrl[$1] : 0); if (d != 0) print v, "delta", "root" r, "calls", $1, d, "", "" }' \
        "$b" "$a" | sort -t "$(printf '\t')" -k6,6nr
}

SUMMARY=$P/summary.tsv
printf 'variant\tfixture\troot\tkind\tfunction\tv1\tv2\tv3\n' > "$SUMMARY"
echo "# pg: v1 = %time, v2 = self seconds, v3 = calls; cyg: v1 = entries; delta: v1 = $FIX minus $CTRL" >> "$SUMMARY"

for variant in $VARIANTS; do
    if [ "$variant" = pg ]; then
        flag=-pg
    else
        flag=-finstrument-functions
    fi
    if ! "$GCC" $DFLAGS $flag -c "$RT/driver.c" -o "$P/driver-$variant.o" 2> "$P/driver-$variant.CC.log"; then
        echo "driver.c $flag compile failed: $P/driver-$variant.CC.log (driver.c vs the headers in $HDR?)" | tee -a "$REC"
        exit 1
    fi
    extra=""
    if [ "$variant" = cyg ]; then
        "$GCC" -std=c99 -O2 -Wall -Wextra -c "$HERE/tv_cyg_hooks.c" -o "$P/tv_cyg_hooks.o" || exit 1
        extra="$P/tv_cyg_hooks.o -Wl,--disable-dynamicbase"
    fi
    for fx in "$FIX" "$CTRL"; do
        exe=$P/$fx-$variant.exe
        # shellcheck disable=SC2086
        if ! "$GCC" $flag "$FIXDIR/$fx-forced/p.o" "$P/driver-$variant.o" "$FE/l2_libc.o" $extra -o "$exe" \
                2> "$P/$fx-$variant.LD.log"; then
            echo "link failed: $P/$fx-$variant.LD.log" | tee -a "$REC"
            exit 1
        fi
        [ "$variant" = cyg ] && "$NM" --defined-only "$exe" > "$P/$fx-cyg.nm"
        for root in 0 1; do
            d=$P/$variant-$fx-root$root
            run_fixture "$exe" "$d" "$root"
            if [ "$variant" = pg ]; then
                "$GPROF" -b -p "$exe" "$d/gmon.out" > "$d/flat.txt" 2>> "$REC"
                "$GPROF" -b -q "$exe" "$d/gmon.out" > "$d/graph.txt" 2>> "$REC"
                flat_tsv "$d/flat.txt" > "$d/flat.tsv"
                summarize pg "$fx" "$root" "$d/flat.tsv" >> "$SUMMARY"
            else
                cyg_tsv "$d/cyg-counts.txt" "$P/$fx-cyg.nm" > "$d/counts.tsv"
                summarize cyg "$fx" "$root" "$d/counts.tsv" >> "$SUMMARY"
            fi
        done
    done
    for root in 0 1; do
        if [ "$variant" = pg ]; then
            delta pg "$root" "$P/pg-$FIX-root$root/flat.tsv" "$P/pg-$CTRL-root$root/flat.tsv" 4 >> "$SUMMARY"
        else
            delta cyg "$root" "$P/cyg-$FIX-root$root/counts.tsv" "$P/cyg-$CTRL-root$root/counts.tsv" 2 >> "$SUMMARY"
        fi
    done
    if [ -n "$GRAPHDIR" ]; then
        gexe=$P/graph-$variant.exe
        sha256sum "$GRAPHDIR/graph_trans.o" >> "$REC"
        # shellcheck disable=SC2086
        if ! "$GCC" $flag "$GRAPHDIR/graph_trans.o" "$P/driver-$variant.o" "$FE/l2_libc.o" $extra -o "$gexe" \
                2> "$P/graph-$variant.LD.log"; then
            echo "graph link failed: $P/graph-$variant.LD.log" | tee -a "$REC"
            exit 1
        fi
        [ "$variant" = cyg ] && "$NM" --defined-only "$gexe" > "$P/graph-cyg.nm"
        for g in "$GFIX" "$GCTRL"; do
            d=$P/$variant-graph-$g
            run_graph "$gexe" "$d" "$GSRC/$g.lm2"
            if [ "$variant" = pg ]; then
                "$GPROF" -b -p "$gexe" "$d/gmon.out" > "$d/flat.txt" 2>> "$REC"
                flat_tsv "$d/flat.txt" > "$d/flat.tsv"
                summarize pg "graph:$g" interp "$d/flat.tsv" >> "$SUMMARY"
            else
                cyg_tsv "$d/cyg-counts.txt" "$P/graph-cyg.nm" > "$d/counts.tsv"
                summarize cyg "graph:$g" interp "$d/counts.tsv" >> "$SUMMARY"
            fi
        done
        if [ "$variant" = pg ]; then
            delta pg interp "$P/pg-graph-$GFIX/flat.tsv" "$P/pg-graph-$GCTRL/flat.tsv" 4 >> "$SUMMARY"
        else
            delta cyg interp "$P/cyg-graph-$GFIX/counts.tsv" "$P/cyg-graph-$GCTRL/counts.tsv" 2 >> "$SUMMARY"
        fi
    fi
done

mkdir -p "$HERE/results"
cp "$SUMMARY" "$REC" "$HERE/results/"
echo "summary: $SUMMARY; record: $REC; copies in $HERE/results/"

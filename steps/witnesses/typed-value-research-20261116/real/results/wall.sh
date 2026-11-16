#!/usr/bin/env bash
# FABLE-R-TV-L: wall time of the accepted (uninstrumented) forced runs, scenario vs control, N runs each, per root.
# Process start is included in both and cancels in the difference.  Output: TSV fixture root n median min max (ms).
set -u
S=C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/sol-m14-field-values-01
FIXDIR=${FIXDIR:-$S/f410-g2-full-01}
N=${N:-31}
OUT=${OUT:-C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/opus/tv-real}
W=$OUT/wall.tsv
printf 'fixture\troot\tn\tmedian_ms\tmin_ms\tmax_ms\texit\n' > "$W"
for fx in private_hidden_binding assign_known; do
    exe=$FIXDIR/$fx-forced/p-prod.exe
    for root in 0 1; do
        rm -f "$OUT/wall-samples.txt"
        rc=0
        for i in $(seq 1 "$N"); do
            t0=$(date +%s%N)
            if [ "$root" = 0 ]; then "$exe" 0 entry 7 > /dev/null 2>&1; else "$exe" 0 entry 7 walkroot 1 > /dev/null 2>&1; fi
            rc=$?
            t1=$(date +%s%N)
            echo $(( (t1 - t0) / 1000 )) >> "$OUT/wall-samples.txt"
        done
        sort -n "$OUT/wall-samples.txt" | awk -v fx="$fx" -v r="$root" -v rc="$rc" '{ v[NR] = $1 } END {
            m = (NR % 2) ? v[(NR + 1) / 2] : (v[NR / 2] + v[NR / 2 + 1]) / 2
            printf "%s\troot%s\t%d\t%.3f\t%.3f\t%.3f\t%s\n", fx, r, NR, m / 1000, v[1] / 1000, v[NR] / 1000, rc }' >> "$W"
    done
done
cat "$W"

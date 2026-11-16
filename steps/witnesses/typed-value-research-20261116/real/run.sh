#!/usr/bin/env bash
# FABLE-R-TV-D (opus, 2026-11-16): runs items 0-4 of the bench built by build.sh.  Run only on fable_pc's signal.
# Each run is a separate process.  The driver's exit status is NOT the bench's result: the driver's main reports after
# the bench returns that no host was launched.  The bench's result is its "#tv-real done status=0" line.
# Extra key=value arguments for every run: EXTRA="R=21 calls=400000".
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${OUT:-C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/opus/tv-real}
EXTRA=${EXTRA:-}
STAMP=$(date -u +%Y%m%dT%H%M%SZ)
TSV=$OUT/tv-real-$STAMP.tsv
REC=$OUT/run-record-$STAMP.txt
: > "$TSV"
: > "$REC"
failed=0

run() {
    local exe=$1
    shift
    echo "\$ $exe 0 -- $* $EXTRA out=$TSV" >> "$REC"
    # shellcheck disable=SC2086
    "$exe" 0 -- "$@" $EXTRA out="$TSV" > "$OUT/last.stdout" 2> "$OUT/last.stderr"
    local rc=$?
    local done_line
    done_line=$(grep '^#tv-real done' "$OUT/last.stdout" || true)
    echo "  driver exit $rc; bench: ${done_line:-NO DONE LINE}" >> "$REC"
    sed 's/^/  stderr: /' "$OUT/last.stderr" >> "$REC"
    awk -F'\t' '!/^#/ && !($1 ~ /^[0-9]$/ && NF == 13)' "$OUT/last.stdout" | sed 's/^/  driver: /' >> "$REC"
    case "$done_line" in
        *status=0) ;;
        *) failed=1 ;;
    esac
}

run "$OUT/bench-time.exe" sizes
run "$OUT/bench-time.exe" classify
run "$OUT/bench-time.exe" slot
run "$OUT/bench-mem.exe" mem
run "$OUT/bench-time.exe" create

mkdir -p "$HERE/results"
cp "$TSV" "$REC" "$OUT/build-record.txt" "$HERE/results/"
echo "rows: $TSV; record: $REC; copies in $HERE/results/; failed=$failed"
exit $failed

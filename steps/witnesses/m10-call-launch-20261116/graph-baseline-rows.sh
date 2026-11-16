#!/bin/sh
# Runs the rows FROM..TO of a graph-check list one by one, each under a time limit, because the tool's
# `checks` has no time limit and one hanging fixture stops the whole list.
# Usage: sh graph-baseline-rows.sh LIST FROM TO LIMIT_SECONDS OUT_LOG STAGE TOOL OUT_LABEL
#   STAGE     the stage directory (the working directory of the tool)
#   TOOL      lmxtool.exe of the working set
#   OUT_LABEL the output directory name used in LIST (leftover processes started from it are killed)
LIST=$1; FROM=$2; TO=$3; LIMIT=$4; LOG=$5; STAGE=$6; T=$7; LABEL=$8
ROW=${LOG%.log}.row.tsv
cd "$STAGE" || exit 9
i=$FROM
while [ "$i" -le "$TO" ]; do
    sed -n "${i}p" "$LIST" > "$ROW"
    name=$(awk -F'\t' '{print $9}' "$ROW" | sed 's#.*/tests/graph/##; s#\.lm2$##')
    timeout "$LIMIT" "$T" 0 entry 0 -- checks "$ROW" > "$LOG.one" 2>&1
    rc=$?
    modes=$(grep '^GRAPH-CHECK' "$LOG.one" | awk '{printf "%s=%s ", $2, $4}')
    if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
        powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { \$_.Name -eq 'graph_trans-prod.exe' -or \$_.ExecutablePath -like '*$LABEL*' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" > /dev/null 2>&1
        printf 'ROW\t%s\t%s\tTIMEOUT\t%s\n' "$i" "$name" "$modes" >> "$LOG"
    else
        printf 'ROW\t%s\t%s\t%s\t%s\n' "$i" "$name" "$rc" "$modes" >> "$LOG"
    fi
    i=$((i + 1))
done
rm -f "$ROW" "$LOG.one"
echo done

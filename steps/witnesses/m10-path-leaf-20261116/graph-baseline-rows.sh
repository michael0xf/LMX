#!/bin/sh
# Runs the rows FROM..TO of a graph-check list one by one, each under a time limit, because the tool's
# `checks` has no time limit and one hanging fixture stops the whole list.
# Usage: sh graph-baseline411-rows.sh LIST FROM TO LIMIT_SECONDS OUT_LOG
LIST=$1; FROM=$2; TO=$3; LIMIT=$4; LOG=$5
S=C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/sol-m14-field-values-01
T=$S/boot-f411-01/lmxtool.exe
ROW=${LOG%.log}.row.tsv
cd /c/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/sol-m14-field-values-01 || exit 9
i=$FROM
while [ "$i" -le "$TO" ]; do
    sed -n "${i}p" "$LIST" > "$ROW"
    name=$(awk -F'\t' '{print $9}' "$ROW" | sed 's#.*/tests/graph/##; s#\.lm2$##')
    timeout "$LIMIT" "$T" 0 entry 0 -- checks "$ROW" > "$LOG.one" 2>&1
    rc=$?
    if [ "$rc" -eq 124 ] || [ "$rc" -eq 137 ]; then
        powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { \$_.Name -eq 'graph_trans-prod.exe' -or \$_.ExecutablePath -like '*f411-graph-base-01*' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" > /dev/null 2>&1
        modes=$(grep '^GRAPH-CHECK' "$LOG.one" | awk '{printf "%s=%s ", $2, $4}')
        printf 'ROW\t%s\t%s\tTIMEOUT\t%s\n' "$i" "$name" "$modes" >> "$LOG"
    else
        modes=$(grep '^GRAPH-CHECK' "$LOG.one" | awk '{printf "%s=%s ", $2, $4}')
        printf 'ROW\t%s\t%s\t%s\t%s\n' "$i" "$name" "$rc" "$modes" >> "$LOG"
    fi
    i=$((i + 1))
done
rm -f "$ROW" "$LOG.one"
echo done

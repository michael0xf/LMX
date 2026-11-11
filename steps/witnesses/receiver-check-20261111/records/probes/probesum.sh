#!/bin/sh
# probesum.sh FE NAME...  -- from the probe directory: run each NAME.lm2 through runprobe2.sh (expected exit 7) and
# print one line per translation mode with the actual outcome: the translation or build error, or the exit code each
# root executor gave ("stopped" = R0 was stopped by an uncaught throw or a stop request).
SC=$(dirname "$0")
FE=$1; shift
actual() {
  if [ "$(cat "$1.rc" 2>/dev/null)" = 0 ]; then echo 7; return; fi
  if grep -q 'R0 was stopped' "$1.log"; then echo stopped; return; fi
  x=$(grep -o 'exit [0-9]*, expected' "$1.log" | head -1 | sed 's/exit \([0-9]*\),.*/\1/')
  if [ -n "$x" ]; then echo "$x"; return; fi
  echo unknown
}
for stem in "$@"; do
  out=$(sh "$SC/runprobe2.sh" "$FE" "$stem.lm2" 7)
  for mode in n f; do
    line=$(printf '%s\n' "$out" | grep "^$stem $mode ")
    case "$line" in
      *" run(expect"*) echo "$stem $mode exit root0=$(actual "$stem-r$mode/run-root0") root1=$(actual "$stem-r$mode/run-root1")" ;;
      *) echo "$line" ;;
    esac
  done
done

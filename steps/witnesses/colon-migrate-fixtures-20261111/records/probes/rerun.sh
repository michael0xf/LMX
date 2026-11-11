#!/bin/sh
# usage: rerun.sh RECORD MODULE TAG FRONTEND [nograph]
# The translation command of the machine module MODULE (src/l2src/MODULE.lm2 or tools/MODULE.lm2 as the first
# source) taken from the build record RECORD and run again by FRONTEND (a hosted l2trans.exe) with the module's
# generated L1 and header written into the probe directory as TAG-MODULE.lm1 / TAG-MODULE.h.lm1.  With `nograph` the
# word --graph is dropped: the module goes through the P0 route.  The environment is the caller's (L2_COLON_WRITES,
# L2_OS_TARGET).  Runs in the stage's src; prints the exit code and the first lines of the log.
record="$1"; m="$2"; tag="$3"; fe="$4"; ng="$5"
PW=C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01
NS=/c/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/fable-main01
PR=/c/Nyasha_Planet/LMX/build2/codex_fix250generationchain01/runs/fable-m6-probe01
out="$PR/$tag-$m.out"
[ -e "$out" ] && { echo "exists: $out"; exit 1; }
cmd=$(grep '^\$ ' "$record" | grep -E "/(l2src|tools)/$m\.lm2 " | head -1 | sed -e 's/^\$ //')
[ -z "$cmd" ] && { echo "no command for $m in $record"; exit 1; }
# the frontend: the first word of the command
cmd=$(printf '%s' "$cmd" | sed -E "s|^[^ ]+|$fe|")
cmd=$(printf '%s' "$cmd" | sed -e "s|$PW/fable-main01/src/l2src/$m\.h\.lm1|$PW/runs/fable-m6-probe01/$tag-$m.h.lm1|g" -e "s|$PW/fable-main01/src/l2src/$m\.lm1|$PW/runs/fable-m6-probe01/$tag-$m.lm1|g")
[ "$ng" = "nograph" ] && cmd=$(printf '%s' "$cmd" | sed -e 's| --graph | |')
case "$cmd" in *"$PW/fable-main01/src/l2src/$m.lm1"*) echo "output not redirected"; exit 1;; esac
( cd "$NS/src" || exit 1; eval "$cmd" > "$out" 2>&1; echo "$tag $m exit=$?" )
head -3 "$out" | cut -c1-220

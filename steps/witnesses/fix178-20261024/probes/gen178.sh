#!/bin/bash
# Slice 178: the growable list's machine module generated as bld_kernel_l2 (tools/l2/build.lm2) generates it -- the
# same frontend arguments, cwd = the stage's src -- but into runs/LABEL instead of in place. Its outputs name only the
# header's file name and the source's, so they are the bytes the recipe writes. Usage: gen178.sh STAGE FRONTEND LABEL
S="$1"
FE="$2"
L="$3"
O=$S/runs/$L
if [ -z "$L" ] || [ -e "$O" ]; then echo "refused: a new label for every attempt"; exit 1; fi
mkdir -p "$O" || exit 1
SW=$(cygpath -m "$S")
OW=$(cygpath -m "$O")
B=C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src
set -- --library
for n in lmx_list_len lmx_list_cap lmx_list_data lmx_list_new_owned lmx_list_new_profiled lmx_list_append_owned lmx_list_remove_owned lmx_list_value; do
    set -- "$@" --machine $n
done
set -- "$@" --header $OW/lmx_list_owned.h.lm1 $SW/src/l2src/lmx_list_owned.lm2 $B/convert.lm2 $B/primitive.lm2 $OW/lmx_list_owned.lm1
echo "$FE $*" > $O/command.txt
cd $S/src || exit 1
"$FE" "$@" > $O/l2.log 2>&1
r=$?
echo "exit=$r" >> $O/l2.log
echo "l2trans exit=$r"
tr -d '\r' < $O/l2.log | head -5
sha256sum $SW/src/l2src/lmx_list_owned.lm2 $O/lmx_list_owned.h.lm1 $O/lmx_list_owned.lm1 2>/dev/null

#!/bin/bash
# Slice 178's machine module checks: each source of SRC translated by FRONTEND as a machine module (--library
# --machine NAME, the harness parts) into OUT/<case>, its diagnostic and exit in OUT/<case>/out.txt; list_int_codes,
# the list's earlier form, runs from the stage's src as the build runs the list. The positive case forward is then
# lowered by bin/l1trans.exe and compiled with a C caller by the stage's gcc, linked with nothing else, and run.
# Usage: machine_neg178.sh FRONTEND SRC OUT
FE="$1"
I="$2"
O="$3"
S=/c/Nyasha_Planet/LMX/build2/opus_fix178
B=C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_consumer49_full_01/src
GCC=C:/Qt/Tools/mingw1310_64/bin/gcc.exe
if [ -z "$O" ] || [ -e "$O" ]; then echo "refused: a new output for every attempt"; exit 1; fi
mkdir -p "$O" || exit 1
OW=$(cygpath -m "$O")
IW=$(cygpath -m "$I")
one() {
    c="$1"; d="$2"; shift 2
    mkdir -p "$O/$c" || exit 1
    echo "cd $d && $FE $*" > "$O/$c/command.txt"
    (cd "$d" && "$FE" "$@" > "$O/$c/out.txt" 2>&1; echo "exit=$?" >> "$O/$c/out.txt")
    printf '%-14s ' "$c"; tr -d '\r' < "$O/$c/out.txt" | tr '\n' ' '; echo
}
P="$B/convert.lm2 $B/primitive.lm2"
one missing $O --library --machine m_two $IW/m_missing.lm2 $P $OW/missing/m_missing.lm1
one statement $O --library --machine m_one $IW/m_statement.lm2 $P $OW/statement/m_statement.lm1
one root_field $O --library --machine m_one $IW/m_root_field.lm2 $P $OW/root_field/m_root_field.lm1
one structure $O --library --machine m_one $IW/m_structure.lm2 $P $OW/structure/m_structure.lm1
one bodyless $O --library --machine m_one $IW/m_bodyless.lm2 $P $OW/bodyless/m_bodyless.lm1
one throws $O --library --machine m_check $IW/m_throws.lm2 $P $OW/throws/m_throws.lm1
one unit_field $O --library --machine m_read $IW/m_unit_field.lm2 $P $OW/unit_field/m_unit_field.lm1
one array_field $O --library --machine m_first $IW/m_array_field.lm2 $P $OW/array_field/m_array_field.lm1
one l2name $O --library --machine m_one $IW/m_l2name.lm2 $P $OW/l2name/m_l2name.lm1
one add $O --library --machine m_add $IW/m_add.lm2 $P $OW/add/m_add.lm1
one cond $O --library --machine m_pos $IW/m_cond.lm2 $P $OW/cond/m_cond.lm1
one actual $O --library --machine m_call $IW/m_actual.lm2 $P $OW/actual/m_actual.lm1
one divide $O --library --machine m_div $IW/m_divide.lm2 $P $OW/divide/m_divide.lm1
one remainder $O --library --machine m_rem $IW/m_remainder.lm2 $P $OW/remainder/m_remainder.lm1
L="--library"
for n in lmx_list_len lmx_list_cap lmx_list_data lmx_list_new_owned lmx_list_new_profiled lmx_list_append_owned lmx_list_remove_owned lmx_list_value; do
    L="$L --machine $n"
done
one list_int_codes $S/src $L --header $OW/list_int_codes/m_list_int_codes.h.lm1 $IW/m_list_int_codes.lm2 $P $OW/list_int_codes/m_list_int_codes.lm1
one forward $O --library --machine m_twice --machine m_half --machine m_rest --machine m_span --header $OW/forward/m_forward.h.lm1 $IW/m_forward.lm2 $P $OW/forward/m_forward.lm1
F="$O/forward"
cp $I/m_forward_main.c $F/ || exit 1
(cd $F && /c/Nyasha_Planet/LMX/bin/l1trans.exe m_forward.h.lm1 m_forward.lm1.h > l1-header.txt 2>&1; echo "exit=$?" >> l1-header.txt)
(cd $F && /c/Nyasha_Planet/LMX/bin/l1trans.exe m_forward.lm1 m_forward.c > l1-module.txt 2>&1; echo "exit=$?" >> l1-module.txt)
(cd $F && $GCC -pipe -std=c99 -O0 -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I . m_forward.c m_forward_main.c -o m_forward.exe > cc.txt 2>&1; echo "exit=$?" >> cc.txt)
(cd $F && ./m_forward.exe > run.txt 2>&1; echo "exit=$?" >> run.txt)
for s in l1-header l1-module cc run; do printf 'forward %-10s ' $s; tr -d '\r' < $F/$s.txt | tr '\n' ' '; echo; done

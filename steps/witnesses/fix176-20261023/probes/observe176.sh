#!/bin/sh
# Slice 176: link the objects of a probe176.sh output with the observing runtime into a new directory, run it at the
# root and walked, count the walked bodies of library M's method and of the owner's try_m and try_n, and print the
# witness lines.
# Usage: observe176.sh OBJ-DIR RUNTIME-DIR OUT-DIR LABEL
P="$1"
RT="$2"
O="$3"
LABEL="$4"
mkdir -p "$O" || exit 1
/c/Qt/Tools/mingw1310_64/bin/gcc.exe $P/owner.o $RT/driver-observe.o C:/Nyasha_Planet/LMX/buold_temp/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o $P/lib_a.o $P/lib_b.o $P/lib_c.o $P/lib_m.o -Wl,--strip-debug -o $O/owner-obs.exe
echo "$LABEL link exit=$?"
for r in 0 1; do
    if [ $r = 0 ]; then (cd $O && ./owner-obs.exe 0 entry 7 > run-obs-root$r.log 2>&1); else (cd $O && ./owner-obs.exe 0 entry 7 walkroot 1 > run-obs-root$r.log 2>&1); fi
    echo "$LABEL root$r exit=$?"
    echo "  walked bodies: lib_m_bump $(grep -c 'LMX_OBSERVE WALK_BODY lib_m_bump' $O/run-obs-root$r.log), try_m $(grep -c 'LMX_OBSERVE WALK_BODY try_m' $O/run-obs-root$r.log), try_n $(grep -c 'LMX_OBSERVE WALK_BODY try_n' $O/run-obs-root$r.log)"
    grep -h 'S81\|lmx: invariant\|lmx: R0' $O/run-obs-root$r.log | sed 's/^/  /'
done

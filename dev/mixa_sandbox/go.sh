#!/bin/bash
# mixa_sandbox/go.sh — bridge mixa_sandbox with NEW Message kernel in l2src_sandbox
# Ticket 20260918-071903:
#   L2SRC=dev/l2src_sandbox/l2src; cwd=l2src_sandbox for translate;
#   drop vendor host-ingress; no -Wl,--allow-multiple-definition;
#   Message entry = mixa_app_main_msg (old mixa_app_main excluded).
#
# Link strategy (why not every kernel .o): L1 predef embeds bodies, so compiling
# every lmx_*.lm1 as its own .o duplicates symbols (turn/gc/range/…). Root
# already predefs the core. We compile ALL kernel units to .o (translate check),
# then link lmx_root.o + a few extras not fully covered by root, with range_*
# localized in those extras so they do not collide with root's copy.
set -u
SANDBOX=/c/Nyasha_Planet/L1/dev/mixa_sandbox
L1ROOT=/c/Nyasha_Planet/L1
WORKDIR="$SANDBOX"
MIXA="$SANDBOX/mixa_manager"
L2SRC_PARENT="$L1ROOT/dev/l2src_sandbox"
L2SRC="$L2SRC_PARENT/l2src"
L1T="$L1ROOT/bin/l1trans.exe"
HDR=/tmp/mixa_hdr
OBJ=/tmp/mixa_obj
THIN=/tmp/mixa_thin
set -e
cd "$WORKDIR"
mkdir -p "$HDR/mixa_manager" "$HDR/l2src" "$HDR/l2src_kernel" "$OBJ" "$THIN"

if [ ! -x "$L1T" ] && [ ! -f "$L1T" ]; then
  echo "ERROR: l1trans not found at $L1T" >&2
  exit 1
fi
if [ ! -d "$L2SRC" ]; then
  echo "ERROR: sandbox kernel not found at $L2SRC" >&2
  exit 1
fi

echo "=== sandbox go.sh (ticket 20260918-071903) ==="
echo "WORKDIR=$WORKDIR"
echo "MIXA=$MIXA"
echo "L2SRC=$L2SRC"
echo "L2SRC_PARENT=$L2SRC_PARENT"
echo "L1T=$L1T"

echo "=== 1. Generate headers ==="
for h in "$MIXA"/*.h.lm1; do
  [ -f "$h" ] || continue
  n=$(basename "$h" .h.lm1)
  (cd "$WORKDIR" && "$L1T" "mixa_manager/$n.h.lm1" "$HDR/mixa_manager/$n.lm1.h") 2>/dev/null || true
done
# Kernel headers: cwd=l2src_sandbox so predef "l2src/..." resolves.
# Emit into l2src_kernel/ for mixa_app_message.h.lm1 includes; mirror to l2src/.
for h in "$L2SRC"/*.h.lm1; do
  [ -f "$h" ] || continue
  n=$(basename "$h" .h.lm1)
  (cd "$L2SRC_PARENT" && "$L1T" "l2src/$n.h.lm1" "$HDR/l2src_kernel/$n.lm1.h") 2>/dev/null || true
  if [ -f "$HDR/l2src_kernel/$n.lm1.h" ]; then
    cp -f "$HDR/l2src_kernel/$n.lm1.h" "$HDR/l2src/$n.lm1.h"
  fi
done
echo "headers: $(ls "$HDR/mixa_manager/"*.lm1.h "$HDR/l2src_kernel/"*.lm1.h 2>/dev/null | wc -l)"

# Modules excluded from BOTH translation and compilation — skipping translation
# avoids WARN spam for modules that can't resolve predef/include from cwd.
#   headless ctors duplicate win32; share_win32 / message_exec: prior excludes
#   mixa_app_main: old main — prefer Message entry mixa_app_main_msg
#   mixa_event_source: still vendor LmxMsgRuntime/lmx_msg_* API (debt); includes
#     l2src/lmx_message.h (old C, now .lm1) — won't resolve from mixa_sandbox
#   lmx_dec: needs decNumber.h (third_party/decNumber/decNumber-icu-368), not
#     compiled into the app — excluded instead of adding -I (lmx_app_main doesn't
#     link decimal symbols anyway; see CLOSURE note)
EXCLUDE_EXACT="mixa_app_main mixa_event_source mixa_share_win32 lmx_message_exec mixa_backend_ctors_headless lmx_dec"

echo "=== 2. Compile .lm1 -> .c ==="
rm -f "$OBJ"/*.c "$OBJ"/*.log 2>/dev/null || true
for m in "$MIXA"/*.lm1; do
  [ -f "$m" ] || continue
  [[ "$m" == *.h.lm1 ]] && continue
  n=$(basename "$m" .lm1)
  skip=0
  for ex in $EXCLUDE_EXACT; do [ "$n" = "$ex" ] && skip=1; done
  [ $skip -eq 1 ] && continue
  (cd "$WORKDIR" && "$L1T" "mixa_manager/$n.lm1" "$OBJ/$n.c") 2>"$OBJ/$n.log" || echo "WARN: $n failed"
done
# ALL kernel lmx_*.lm1 impls (not *.h.lm1, not *_selftest.lm1).
for m in "$L2SRC"/lmx_*.lm1; do
  [ -f "$m" ] || continue
  [[ "$m" == *.h.lm1 ]] && continue
  [[ "$m" == *_selftest.lm1 ]] && continue
  n=$(basename "$m" .lm1)
  skip=0
  for ex in $EXCLUDE_EXACT; do [ "$n" = "$ex" ] && skip=1; done
  [ $skip -eq 1 ] && continue
  (cd "$L2SRC_PARENT" && "$L1T" "l2src/$n.lm1" "$OBJ/$n.c") 2>"$OBJ/$n.log" || echo "WARN: $n failed"
done
echo "EXCLUDED: $EXCLUDE_EXACT"
echo "C files: $(ls "$OBJ"/*.c 2>/dev/null | wc -l)"

echo "=== 4. Compile .c -> .o ==="
rm -f "$OBJ"/*.o 2>/dev/null || true
# Prefer HDR (generated kernel headers) over any stale mixa_sandbox/l2src shadow copies.
CFLAGS="-std=c99 -DLMX_MSG_AFFINITY_UI=1 -Wno-implicit-function-declaration -Wno-error -I $HDR -I $SANDBOX -I $MIXA -I $L2SRC -I $L2SRC_PARENT -I $L1ROOT -I $L1ROOT/lm1/build"
for c in "$OBJ"/*.c; do
  [ -f "$c" ] || continue
  n=$(basename "$c" .c)
  skip=0
  for ex in $EXCLUDE_EXACT; do
    [ "$n" = "$ex" ] && skip=1
  done
  [ $skip -eq 1 ] && continue
  gcc $CFLAGS -c "$c" -o "$OBJ/$n.o" 2>"$OBJ/$n.gcc.log" || echo "WARN: compile $n"
done

echo "=== 5. Link (root amalgamation + thinned extras; no allow-multiple-definition) ==="
# Mixa objects
OBJS=""
for o in "$OBJ"/*.o; do
  [ -f "$o" ] || continue
  n=$(basename "$o" .o)
  # Only mixa/mtk objects here; kernel handled below
  case "$n" in
    lmx_*) continue ;;
  esac
  skip=0
  for ex in $EXCLUDE_EXACT; do
    [ "$n" = "$ex" ] && skip=1
  done
  [ $skip -eq 1 ] && continue
  OBJS="$OBJS $o"
done

if [ ! -f "$OBJ/lmx_root.o" ]; then
  echo "BUILD FAILED: lmx_root.o missing"
  exit 1
fi
if [ ! -f "$OBJ/mixa_app_main_msg.o" ]; then
  echo "BUILD FAILED: mixa_app_main_msg.o missing (Message entry)"
  if [ -f "$OBJ/mixa_app_main_msg.gcc.log" ]; then cat "$OBJ/mixa_app_main_msg.gcc.log"; fi
  exit 1
fi

# Extras not fully covered by lmx_root predef tree (undefined otherwise)
EXTRAS="lmx_implements lmx_array_owned lmx_array_ref_owned lmx_chars_owned"
rm -f "$THIN"/*.o 2>/dev/null || true
localize_range() {
  local src="$1" dst="$2"
  cp -f "$src" "$dst"
  for s in lmx_range_add lmx_range_classify lmx_range_drop lmx_range_pool \
           lmx_range_reserve lmx_range_stride lmx_range_type_of \
           lmx_range_clear lmx_range_open lmx_range_close; do
    if nm "$dst" 2>/dev/null | grep -q " T ${s}$"; then
      objcopy --localize-symbol="$s" "$dst" 2>/dev/null || true
    fi
  done
}

KERNEL_OBJS="$OBJ/lmx_root.o"
for n in $EXTRAS; do
  if [ -f "$OBJ/$n.o" ]; then
    localize_range "$OBJ/$n.o" "$THIN/$n.o"
    KERNEL_OBJS="$KERNEL_OBJS $THIN/$n.o"
  else
    echo "WARN: missing extra $n.o"
  fi
done

if [ -z "$OBJS" ]; then
  echo "BUILD FAILED: no mixa objects"
  exit 1
fi

rm -f /tmp/mixa_app.exe /tmp/mixa_link.log
set +e
gcc $OBJS $KERNEL_OBJS -o /tmp/mixa_app.exe -lshell32 -lgdi32 -luser32 -lwinmm > /tmp/mixa_link.log 2>&1
LINK_ST=$?
set -e
if [ "$LINK_ST" -ne 0 ]; then
  echo "=== link errors (tail) ==="
  tail -40 /tmp/mixa_link.log
  echo "BUILD FAILED"
  exit 1
fi

if [ -f /tmp/mixa_app.exe ]; then
  echo "BUILD OK: /tmp/mixa_app.exe"
  [ "${1:-}" != "just-build" ] && "/tmp/mixa_app.exe" . 2>&1 | head -5 || true
else
  echo "BUILD FAILED"
  exit 1
fi
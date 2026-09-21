#!/usr/bin/env sh
# L1 bootstrap for a NEW HOST -- ported METHOD, not code.
#
# What was ported and from where: the method of lingvamyxa_old_worked_version/buildCore.lm0.sh
# (and its .bat twin), which the author asked to bring over.  Their method is: derive the repo
# from the script's own location, let every tool be overridden (LM_CC/LM_AR/LM_RANLIB), pick the
# thread provider explicitly with platform auto-detection, and pass C99 plus the platform feature
# defines.  What was NOT ported: their generated sources and their link set.  In the old tree
# `trans` was linked from libparser.a + libown.a; the present translator is AMALGAMATED
# (lm1/build/l1trans.lm1.c), so linking those libraries again would duplicate symbols.  So this
# script compiles B0 out of the tracked C and nothing else.
#
# WHY B0 MATTERS: a copied Windows l1trans.exe proves nothing on a new host and is not
# byte-reproducible anyway.  B0 -- the current tracked C compiled by THIS host's compiler -- is
# the honest starting point of the chain; tools/run_self_build.ps1 then drives B0 -> pass1/B1 ->
# pass2/B2 -> pass3 and checks the fixed point.
#
# SCOPE, said plainly so it is not mistaken for more: this builds the L1 (translator) bootstrap
# only.  It is NOT the L2/kernel chain and NOT the manager (port) chain; those stay separate
# steps.  Nothing here falls back to any other tree's paths.
#
#   sh tools/bootstrap_l1.sh
#   LM_CC=clang LM_THREAD_PROVIDER=auto sh tools/bootstrap_l1.sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$project_root"

: "${LM_CMAKE:=cmake}"
: "${LM_CC:=gcc}"
: "${LM_AR:=ar}"
: "${LM_RANLIB:=ranlib}"
: "${LM_THREAD_PROVIDER:=single}"

case "$LM_THREAD_PROVIDER" in
    auto)
        case "$(uname -s 2>/dev/null || printf '%s\n' unknown)" in
            CYGWIN*|MINGW*|MSYS*) thread_provider=win32 ;;
            Darwin|Linux|FreeBSD|NetBSD|OpenBSD|DragonFly|SunOS|AIX) thread_provider=pthread ;;
            *) thread_provider=single ;;
        esac
        ;;
    pthread|win32|single) thread_provider=$LM_THREAD_PROVIDER ;;
    *)
        echo "bootstrap_l1.sh: unsupported LM_THREAD_PROVIDER: $LM_THREAD_PROVIDER" >&2
        echo "Expected one of: auto, pthread, win32, single." >&2
        exit 1
        ;;
esac

case "$thread_provider" in
    pthread)
        thread_provider_define="-DLM_THREAD_PROVIDER=LM_THREAD_PROVIDER_PTHREAD"
        thread_native_flag="-pthread"
        ;;
    win32)
        thread_provider_define="-DLM_THREAD_PROVIDER=LM_THREAD_PROVIDER_WIN32"
        thread_native_flag=
        ;;
    single)
        thread_provider_define="-DLM_THREAD_PROVIDER=LM_THREAD_PROVIDER_SINGLE"
        thread_native_flag=
        ;;
esac

exe_suffix=
case "$(uname -s 2>/dev/null || printf '%s\n' unknown)" in
    CYGWIN*|MINGW*|MSYS*) exe_suffix=.exe ;;
esac

posix_feature_define="-D_POSIX_C_SOURCE=200809L"

seed="lm1/build/l1trans.lm1.c"
if [ ! -f "$seed" ]; then
    echo "bootstrap_l1.sh: seed not found: $seed" >&2
    echo "It is VERSIONED (commit 2d24852); check 'git ls-files lm1/build'." >&2
    exit 1
fi

if ! command -v "$LM_CC" >/dev/null 2>&1; then
    echo "bootstrap_l1.sh: C compiler not found: $LM_CC" >&2
    echo "Set LM_CC to the cc/gcc/clang path and retry." >&2
    exit 1
fi

stamp=$(date +%Y%m%d_%H%M%S)
out="build/self_build/bootstrap_$stamp"
if command -v "$LM_CMAKE" >/dev/null 2>&1; then
    "$LM_CMAKE" -E make_directory "$out"
else
    mkdir -p "$out"
fi

# Same flags as tools/run_self_build.ps1 uses for B0, so the two entry points cannot drift:
# -I . and -I lm1/build are the PRESENT include roots (the old script's -Ilm1 was that tree's).
"$LM_CC" -std=c99 -Wall -Wextra -Wpedantic \
    -Werror=incompatible-pointer-types -Werror=discarded-qualifiers \
    -Werror=implicit-function-declaration -Werror=implicit-int \
    "$thread_provider_define" "$posix_feature_define" ${thread_native_flag:+"$thread_native_flag"} \
    -I . -I lm1/build -o "$out/l1trans$exe_suffix" "$seed"

echo "bootstrap_l1.sh: built $out/l1trans$exe_suffix"
echo "bootstrap_l1.sh: host compiler $LM_CC; thread provider $thread_provider ($thread_provider_define)"
echo "bootstrap_l1.sh: this is B0 only -- run tools/run_self_build.sh for the fixed-point cycle"

# SMOKE, not decoration: B0 must at least start and answer on this host.  A silent B0 would
# otherwise be discovered three passes later.
"$out/l1trans$exe_suffix" >/dev/null 2>&1 || b0_status=$?
if [ "${b0_status:-0}" -gt 128 ]; then
    echo "bootstrap_l1.sh: B0 CRASHED (status $b0_status) -- do not trust the cycle" >&2
    exit 1
fi
echo "bootstrap_l1.sh: B0 smoke ok (status ${b0_status:-0}; a non-zero usage exit is fine, a crash is not)"

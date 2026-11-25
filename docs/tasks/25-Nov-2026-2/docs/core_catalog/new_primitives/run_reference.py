#!/usr/bin/env python3
"""Build the standalone C99 guide with the supplied sources, without downloads.

Native GCC/Clang runner for environments without CMake. It reproduces the
reviewed choices in collection/cmake/Precision.cmake; see README.ru.md.
It never modifies the supplied collection. Build products stay in --build-dir.
"""
from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys


def run(command, *, env=None):
    result = subprocess.run(command, text=True, capture_output=True, env=env)
    if result.returncode:
        raise RuntimeError(shlex.join(map(str, command)) + "\n" + result.stdout + result.stderr)
    return result.stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--collection", type=Path, required=True)
    parser.add_argument("--build-dir", type=Path, required=True)
    parser.add_argument("--numeric-extra", type=Path,
                        help="Defaults to COLLECTION/extensions/numeric_extra")
    parser.add_argument("--cc", default=os.environ.get("CC", "cc"))
    parser.add_argument("--jobs", type=int, default=4)
    parser.add_argument("--sanitize", action="store_true")
    parser.add_argument("--leak-check", action="store_true",
                        help="Enable LeakSanitizer too; not supported under ptrace")
    args = parser.parse_args()
    collection = args.collection.resolve()
    build = args.build_dir.resolve()
    source = Path(__file__).resolve().parent
    if build == source or build == collection or source in build.parents and build.name == "vendor":
        raise SystemExit("Choose a separate build directory")
    build.mkdir(parents=True, exist_ok=True)
    generated = build / "generated"
    generated.mkdir(exist_ok=True)
    extra = (args.numeric_extra or collection / "extensions/numeric_extra").resolve()
    bf_generated = generated / "libbf"
    run([sys.executable, str(extra / "prepare_libbf.py"),
         str(extra.parent.parent / "vendor/libbf"), str(bf_generated)])
    cc = shlex.split(args.cc)
    flags = ["-std=c99", "-pedantic-errors", "-O1", "-g"]
    if args.sanitize:
        flags += ["-fsanitize=address,undefined", "-fno-omit-frame-pointer"]
    probe = build / "abi_probe.c"
    probe.write_text('#include <stddef.h>\n#include <stdio.h>\nint main(void){printf("%zu\\n",sizeof(size_t));return 0;}\n')
    probe_exe = build / "abi_probe"
    run(cc + ["-std=c99", "-pedantic-errors", str(probe), "-o", str(probe_exe)])
    bits = int(run([str(probe_exe)]).strip()) * 8
    if bits not in (32, 64):
        raise SystemExit("MPDecimal requires 32-bit or 64-bit size_t")
    tommath = collection / "vendor/libtommath"
    mpdec = collection / "vendor/mpdecimal/libmpdec"
    decnumber = collection / "vendor/decnumber"
    precision_cmake = collection / "cmake/Precision.cmake"
    source_list = (tommath / "sources.cmake").read_text()
    match = re.search(r"set\(SOURCES\s+(.*?)\)", source_list, re.S)
    if not match:
        raise SystemExit("Cannot read pinned LibTomMath source list")
    names = match.group(1).split()
    if any(not re.fullmatch(r"[A-Za-z0-9_]+\.c", name) for name in names):
        raise SystemExit("Unexpected LibTomMath source-list form; review required")
    mpd_header = (mpdec / "mpdecimal.h.in").read_text()
    if mpd_header.count("@MPD_HEADER_CONFIG@") != 1:
        raise SystemExit("Unexpected MPDecimal template; review required")
    other_bits = 96 - bits
    config = (f"/* Reference build: native size_t is {bits} bits. */\n"
              f"#define MPD_CONFIG_{bits} 1\n"
              f"#if defined(MPD_CONFIG_{other_bits}) || defined(CONFIG_{other_bits})\n"
              '#error "incompatible MPDecimal configuration"\n#endif')
    (generated / "mpdecimal.h").write_text(mpd_header.replace("@MPD_HEADER_CONFIG@", config))
    portable = (mpdec / "mpdecimal.c").read_text()
    if portable.count("defined(__SIZEOF_INT128__)") != 3:
        raise SystemExit("MPDecimal portability guards changed; review Precision.cmake")
    portable_path = generated / "mpdecimal_portable.c"
    portable_path.write_text(portable.replace("defined(__SIZEOF_INT128__)", "defined(HAVE_UINT128_T)"))
    modules = "basearith context constants convolute crt mpsignal difradix2 fnt fourstep io mpalloc numbertheory sixstep transpose".split()
    # Guard this independent runner against drift in the collection adapter.
    cmake_text = precision_cmake.read_text()
    for module in modules:
        if not re.search(r"\b" + re.escape(module) + r"\b", cmake_text):
            raise SystemExit("MPDecimal module list differs from Precision.cmake")
    inputs = [(tommath / name, ["-DMP_32BIT"], False) for name in names]
    inputs += [(mpdec / (name + ".c"), [f"-DCONFIG_{bits}", "-DANSI"], False) for name in modules]
    inputs += [(portable_path, [f"-DCONFIG_{bits}", "-DANSI"], False)]
    inputs += [(decnumber / (name + ".c"), [], False) for name in ("decNumber", "decContext")]
    inputs += [(bf_generated / name, [], False) for name in ("libbf.c", "cutils.c")]
    inputs += [(source / name, ["-DMP_32BIT"], True) for name in
               ("primitive_runtime.c", "numeric_provider.c", "real_provider.c", "conversion_bridge.c", "reference_check.c")]
    includes = [str(path) for path in (source, generated, bf_generated, tommath, mpdec, decnumber)]
    include_flags = [flag for path in includes for flag in ("-I", path)]

    def compile_one(item):
        index, (path, definitions, own_code) = item
        output = build / f"part_{index:03}.o"
        strict = ["-Wall", "-Wextra", "-Werror"] if own_code else []
        run(cc + flags + include_flags + definitions + strict + ["-c", str(path), "-o", str(output)])
        return output

    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.jobs)) as pool:
        objects = list(pool.map(compile_one, enumerate(inputs)))
    executable = build / "lmx_numeric_reference_check"
    run(cc + flags + list(map(str, objects)) + ["-lm", "-o", str(executable)])
    environment = os.environ.copy()
    if args.sanitize:
        environment["ASAN_OPTIONS"] = f"detect_leaks={int(args.leak_check)}:halt_on_error=1"
        environment["UBSAN_OPTIONS"] = "halt_on_error=1:print_stacktrace=1"
    output = run([str(executable)], env=environment)
    report = {
        "scope": "Standalone C99 reference only; not LMX interpreter/native integration",
        "status": "PASS",
        "compiler": run(cc + ["--version"]).splitlines()[0],
        "c_standard": "C99 with -pedantic-errors; guide code also -Wall -Wextra -Werror",
        "sanitizers": (["address", "undefined"] + (["leak detection"] if args.leak_check else [])) if args.sanitize else [],
        "leak_check": "enabled" if args.sanitize and args.leak_check else "NOT_RUN (opt-in; unavailable under ptrace)",
        "size_t_bits": bits,
        "compiled_translation_units": len(inputs),
        "precision_cmake_sha256": hashlib.sha256(precision_cmake.read_bytes()).hexdigest(),
        "stdout": output.strip(),
        "lmx_runtime_execution": "NOT_RUN",
        "full_collection_build": "NOT_RUN",
        "source_modified": False,
    }
    (build / "verification.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, ValueError) as error:
        print(error, file=sys.stderr)
        raise SystemExit(1)

#!/usr/bin/env python3
"""Exercise default gates and a reviewed, enabled generated compress2 gate.

Example from the patched project root:
  python3 docs/core_catalog/bridge/run_generated_shim_tests.py \
    --catalog-root docs/core_catalog --source third_party/lmx_c99_compact \
    --report docs/core_catalog/validation/generated_shim_tests.json

The generator is used unchanged. Three shipped samples must compile and link
without native library headers/objects and return REVIEW_REQUIRED. The actual
on-demand compress2 output is then enabled by compress2_example.c and linked
against the supplied zlib C sources for a binary compression roundtrip and
rejection tests. This is evidence for this example, not for all catalogue APIs
or for LMX arena lowering. No tools or dependencies are downloaded.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile


DEFAULT_MAIN = r'''
#include "lmx_catalog_bridge.h"
#include <stdio.h>
#include <string.h>
@DECLARATIONS@
int main(void) {
    unsigned failures = 0, count = 0;
    const unsigned char owner = 1;
    lmx_catalog_frame f = {0};
    f.abi_version = 1; f.owner = &owner;
@CALLS@
    printf("{\"gates\":%u,\"failures\":%u,\"native_libraries_linked\":0}\n", count, failures);
    return failures ? 1 : 0;
}
'''


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--catalog-root", type=Path, required=True)
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--compiler", default=os.environ.get("CC", "cc"))
    ap.add_argument("--build-dir", type=Path)
    ap.add_argument("--report", type=Path)
    ap.add_argument("--sanitize", action="store_true")
    args = ap.parse_args()
    bridge = Path(__file__).resolve().parent
    catalog, collection = args.catalog_root.resolve(), args.source.resolve()
    generator = bridge.parent / "tools/build_c_catalog.py"
    owned = tempfile.TemporaryDirectory(prefix="lmx-generated-shim-") if args.build_dir is None else None
    build = Path(owned.name) if owned else args.build_dir.resolve()
    build.mkdir(parents=True, exist_ok=True)
    cc = shlex.split(args.compiler)
    report = {"scope": "three default generated gates plus reviewed enabled on-demand zlib compress2 gate",
              "not_tested": ["other enabled C APIs", "LMX arena lowering", "L3 execution", "other platforms"],
              "pass": False, "commands": [], "inputs": [], "sanitized": args.sanitize}
    common = ["-std=c99", "-O1", "-g", "-Wall", "-Wextra"]
    if args.sanitize:
        common += ["-fsanitize=address,undefined", "-fno-omit-frame-pointer"]
        report["sanitizer_environment"] = {k: os.environ[k] for k in ("ASAN_OPTIONS", "UBSAN_OPTIONS", "LSAN_OPTIONS") if k in os.environ}
        if "detect_leaks=0" in os.environ.get("ASAN_OPTIONS", ""):
            report["not_tested"].append("LeakSanitizer (explicitly disabled by ASAN_OPTIONS)")

    def run(argv):
        p = subprocess.run([str(x) for x in argv], cwd=build, capture_output=True, text=True)
        report["commands"].append({"argv": [str(x) for x in argv], "returncode": p.returncode,
                                   "stdout": p.stdout, "stderr": p.stderr})
        if p.returncode:
            raise RuntimeError("command failed: " + str(argv[0]))
        return p

    def record(path):
        report["inputs"].append({"path": str(path), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})

    try:
        report["compiler"] = run(cc + ["--version"]).stdout.splitlines()[0]
        emitted = build / "generated_compress2.c"
        run([sys.executable, generator, "--catalog-root", catalog, "--emit-shim", "compress2",
             "--component", "base:zlib", "--shim-output", emitted])
        samples = [catalog / "c_shims" / n for n in (
            "base_zlib_compress2.c", "acoustic_jansson_json_loadb.c", "acoustic_liquid_dsp_agc_crcf_create.c")]
        report["on_demand_matches_shipped_sample"] = emitted.read_bytes() == samples[0].read_bytes()
        if not report["on_demand_matches_shipped_sample"]:
            raise RuntimeError("on-demand compress2 differs from the shipped sample")
        gates = []
        for sample in samples:
            content = sample.read_text()
            function = re.search(r"\bint (lmx_bridge_\w+)\(void \*opaque\)", content).group(1)
            symbol = re.search(r'lmx_catalog_review_required\(frame, "([^"]+)"\)', content).group(1)
            gates.append((function, symbol))
            record(sample)
        declarations = "\n".join("int " + function + "(void *);" for function, symbol in gates)
        calls = []
        for function, symbol in gates:
            calls.append('    ++count; f.result.kind = LMXC_UNSIGNED; f.result.unsigned_value = 777;\n'
                         '    if (' + function + '(&f) != LMXC_REVIEW_REQUIRED ||\n'
                         '        f.status != LMXC_REVIEW_REQUIRED || f.result.kind != LMXC_NONE ||\n'
                         '        f.diagnostic_symbol == NULL || strcmp(f.diagnostic_symbol, "' + symbol + '") != 0) ++failures;')
        default_main = build / "default_gates.c"
        default_main.write_text(DEFAULT_MAIN.replace("@DECLARATIONS@", declarations).replace("@CALLS@", "\n".join(calls)))
        default_exe = build / "default_gates"
        # Deliberately no native include directories, objects or libraries.
        run(cc + common + ["-pedantic", "-Werror", "-I", bridge, default_main, *samples,
                           bridge / "lmx_catalog_bridge.c", "-o", default_exe])
        report["default_gates"] = json.loads(run([default_exe]).stdout)
        undefined = run(["nm", "-u", default_exe]).stdout
        forbidden = [symbol for function, symbol in gates if re.search(r"\b" + re.escape(symbol) + r"\b", undefined)]
        report["native_symbols_in_default_executable"] = forbidden
        if forbidden:
            raise RuntimeError("default gate unexpectedly references a native library")

        zlib = collection / "vendor/zlib"
        sources = [bridge / "lmx_catalog_bridge.c", bridge / "compress2_example.c"] + [zlib / (n + ".c") for n in (
            "adler32", "crc32", "deflate", "trees", "zutil", "compress", "inflate", "inffast", "inftrees", "uncompr")]
        objects = []
        for i, source in enumerate(sources):
            obj = build / ("enabled_" + str(i) + ".o")
            own_flags = ["-pedantic", "-Werror"] if source.parent == bridge else []
            run(cc + common + own_flags + ["-DLMXC99_COMPRESS2_EXAMPLE_TEST", "-I", bridge, "-I", build,
                                         "-I", zlib, "-c", source, "-o", obj])
            record(source)
            objects.append(obj)
        record(bridge / "lmx_catalog_bridge.h"); record(emitted); record(zlib / "zlib.h")
        enabled_exe = build / "enabled_compress2"
        run(cc + common + objects + ["-o", enabled_exe])
        report["enabled_compress2"] = json.loads(run([enabled_exe]).stdout)
        report["pass"] = report["default_gates"]["failures"] == 0 and report["enabled_compress2"]["failures"] == 0
    except (OSError, RuntimeError, ValueError, AttributeError) as exc:
        report["error"] = str(exc)
    finally:
        substitutions = sorted([(str(bridge), "${PROJECT}/docs/core_catalog/bridge"),
                                 (str(generator), "${PROJECT}/docs/core_catalog/tools/build_c_catalog.py"),
                                 (str(catalog), "${CATALOG}"), (str(collection), "${COLLECTION}"),
                                 (str(build), "${BUILD}")], key=lambda p: -len(p[0]))

        def normalized(value):
            if isinstance(value, str):
                for old, new in substitutions:
                    value = value.replace(old, new)
                return value
            if isinstance(value, dict):
                return {k: normalized(v) for k, v in value.items()}
            if isinstance(value, list):
                return [normalized(v) for v in value]
            return value

        report = normalized(report)
        report["normalized_paths"] = {"applied": True, "${PROJECT}": "project containing this runner",
                                      "${CATALOG}": "--catalog-root", "${COLLECTION}": "--source", "${BUILD}": "test build directory"}
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report, indent=2))
        if owned:
            owned.cleanup()
    return 0 if report["pass"] else 1


if __name__ == "__main__":
    sys.exit(main())

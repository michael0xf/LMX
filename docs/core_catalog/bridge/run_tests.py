#!/usr/bin/env python3
"""Build/run meaningful C99 reference-frame tests against the pinned zlib source.

Usage (from the project root after applying the patch):
  python3 docs/core_catalog/bridge/run_tests.py --source third_party/lmx_c99_compact
  python3 docs/core_catalog/bridge/run_tests.py --source third_party/lmx_c99_compact --sanitize

This tests real C frames and two real zlib APIs. It does not claim that LMX graph
lowering, the L3 compiler, any other generated shim, or other platforms are tested.
No compiler tools or dependencies are downloaded. CC may contain compiler flags.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--source", type=Path, required=True, help="lmx_c99_compact source directory")
    ap.add_argument("--compiler", default=os.environ.get("CC", "cc"))
    ap.add_argument("--build-dir", type=Path, help="retain build products here; default: temporary")
    ap.add_argument("--report", type=Path, help="write a reproducible JSON validation report")
    ap.add_argument("--sanitize", action="store_true", help="enable address and undefined-behavior sanitizers")
    args = ap.parse_args()
    bridge = Path(__file__).resolve().parent
    source = args.source.resolve()
    zlib = source / "vendor/zlib"
    inputs = [bridge / "test_bridge.c", bridge / "lmx_catalog_bridge.c",
              bridge / "lmx_catalog_bridge.h", zlib / "adler32.c", zlib / "crc32.c",
              zlib / "zlib.h", zlib / "zconf.h", zlib / "crc32.h", zlib / "zutil.h"]
    missing = [str(p) for p in inputs if not p.is_file()]
    if missing:
        ap.error("required files are missing: " + ", ".join(missing))
    compiler = shlex.split(args.compiler)
    if not compiler:
        ap.error("empty compiler command")
    owned_temp = tempfile.TemporaryDirectory(prefix="lmx-catalog-bridge-") if args.build_dir is None else None
    build = Path(owned_temp.name) if owned_temp else args.build_dir.resolve()
    build.mkdir(parents=True, exist_ok=True)
    report = {"scope": "explicit C99 frames, lifetime/type/range checks, real pinned zlib checksums",
              "not_tested": ["LMX arena lowering", "LMX/L3 compiler", "other generated shims", "other platforms"],
              "sanitize": args.sanitize, "inputs": [], "commands": [], "pass": False}
    if args.sanitize:
        report["sanitizer_environment"] = {
            key: os.environ[key] for key in ("ASAN_OPTIONS", "UBSAN_OPTIONS", "LSAN_OPTIONS") if key in os.environ
        }
        if "detect_leaks=0" in os.environ.get("ASAN_OPTIONS", ""):
            report["not_tested"].append("LeakSanitizer (explicitly disabled by ASAN_OPTIONS)")
    for p in inputs:
        relative = "bridge/" + p.name if p.parent == bridge else str(p.relative_to(source))
        report["inputs"].append({"path": relative, "sha256": hashlib.sha256(p.read_bytes()).hexdigest()})
    base_flags = ["-std=c99", "-O1", "-g", "-Wall", "-Wextra"]
    if args.sanitize:
        base_flags += ["-fsanitize=address,undefined", "-fno-omit-frame-pointer"]

    def run(cmd: list[str]) -> subprocess.CompletedProcess[str]:
        result = subprocess.run(cmd, cwd=build, text=True, capture_output=True)
        report["commands"].append({"argv": cmd, "returncode": result.returncode,
                                   "stdout": result.stdout, "stderr": result.stderr})
        return result

    try:
        version = run(compiler + ["--version"])
        report["compiler"] = version.stdout.splitlines()[0] if version.stdout else args.compiler
        sources = [bridge / "test_bridge.c", bridge / "lmx_catalog_bridge.c", zlib / "adler32.c", zlib / "crc32.c"]
        objects = []
        for index, p in enumerate(sources):
            obj = build / (str(index) + ".o")
            flags = base_flags + (["-Werror", "-pedantic"] if p.parent == bridge else [])
            result = run(compiler + flags + ["-I", str(bridge), "-I", str(zlib), "-c", str(p), "-o", str(obj)])
            if result.returncode:
                raise RuntimeError("C99 compilation failed: " + p.name)
            objects.append(str(obj))
        exe = build / ("test_bridge.exe" if os.name == "nt" else "test_bridge")
        result = run(compiler + base_flags + objects + ["-o", str(exe)])
        if result.returncode:
            raise RuntimeError("link failed")
        result = run([str(exe)])
        if result.returncode:
            raise RuntimeError("behavioral checks failed")
        report["result"] = json.loads(result.stdout.strip())
        report["pass"] = report["result"]["failures"] == 0
    except (OSError, RuntimeError, ValueError) as exc:
        report["error"] = str(exc)
    finally:
        # Preserve the commands/results while making the evidence relocatable.
        # Only report strings are normalized; compilation used the real paths.
        replacements = sorted(
            [(str(bridge), "${PROJECT}/docs/core_catalog/bridge"),
             (str(source), "${COLLECTION}"), (str(build), "${BUILD}")],
            key=lambda item: -len(item[0]),
        )

        def normalized(value):
            if isinstance(value, str):
                for before, after in replacements:
                    value = value.replace(before, after)
                return value
            if isinstance(value, list):
                return [normalized(item) for item in value]
            if isinstance(value, dict):
                return {key: normalized(item) for key, item in value.items()}
            return value

        report = normalized(report)
        report["normalized_paths"] = {
            "applied": True,
            "${PROJECT}": "project root containing docs/core_catalog/bridge",
            "${COLLECTION}": "collection directory passed through --source",
            "${BUILD}": "temporary directory or directory passed through --build-dir",
            "scope": "Report paths only; actual compiler options and execution results are preserved.",
        }
        if args.report:
            args.report.parent.mkdir(parents=True, exist_ok=True)
            args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print(json.dumps(report, indent=2))
        if owned_temp:
            owned_temp.cleanup()
    return 0 if report["pass"] else 1


if __name__ == "__main__":
    sys.exit(main())

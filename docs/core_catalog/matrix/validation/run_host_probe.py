#!/usr/bin/env python3
"""Reproduce focused native C99 probes; this is not an LMX implementation.
The collection is read-only. Generated views, binaries and logs live in --output.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--collection", type=Path, required=True,
                        help="extracted third_party/lmx_c99_compact")
    parser.add_argument("--output", type=Path, required=True,
                        help="separate writable directory outside collection and validation sources")
    parser.add_argument("--cc", default="cc", help="C compiler executable; no shell command")
    args = parser.parse_args()
    collection, output = args.collection.resolve(), args.output.resolve()
    here = Path(__file__).resolve().parent
    if collection == output or collection in output.parents or here == output or here in output.parents:
        parser.error("--output must be outside collection and this validation-source directory")
    compiler = shutil.which(args.cc)
    if not compiler:
        parser.error("C compiler executable not found")
    nm = shutil.which("nm")
    if not nm:
        parser.error("nm executable not found")
    receipt = json.loads((here.parent / "validation_report.json").read_text())
    for relative, expected in receipt["source_provenance_sha256"].items():
        relative = Path(relative).relative_to("third_party/lmx_c99_compact")
        source = collection / relative
        if not source.is_file() or digest(source) != expected:
            parser.error("source differs from reviewed archive: " + str(relative))
    output.mkdir(parents=True, exist_ok=True)
    generated = output / "generated"
    vendor = collection / "vendor"
    def run(command: list[str], log: str) -> subprocess.CompletedProcess[str]:
        result = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (output / log).write_text(result.stdout)
        if result.returncode:
            print(result.stdout, file=sys.stderr)
            raise RuntimeError(f"{log}: exit {result.returncode}")
        return result
    run([sys.executable, str(collection / "extensions/acoustic/cmake/build_views.py"),
         str(vendor), str(generated / "acoustic")], "acoustic_view.log")
    run([sys.executable, str(collection / "extensions/tensors/scripts/mint_view.py"),
         str(vendor / "mint"), str(generated / "mint")], "mint_view.log")
    # Exactly the two transformations in the hash-checked UtensilView.cmake.
    text = (vendor / "utensil/utensil.h").read_text()
    if text.count("#ifdef __APPLE__") != 5 or text.count("#include <float.h>") != 1:
        raise RuntimeError("unexpected Utensil header layout")
    text = text.replace("#include <float.h>", "#include <assert.h>\n#include <float.h>")
    text = text.replace("#ifdef __APPLE__", "#if defined(__APPLE__) && !defined(LMX_UTENSIL_CPU_ONLY)")
    (generated / "utensil").mkdir(parents=True, exist_ok=True)
    (generated / "utensil/utensil.h").write_text(text)
    # Same scalar/logging options as the reviewed acoustic target; metadata
    # identifies this selected-source probe, not a complete collection build.
    text = (vendor / "liquid_dsp/cmake/liquid.config.h.in").read_text()
    config = {"PROJECT_COPYRIGHT": "upstream liquid-dsp", "PROJECT_LICENSE": "MIT",
              "BUILD_ENV": "local selected-source review probe", "CMAKE_BUILD_TYPE": "Debug",
              "CMAKE_SYSTEM_NAME": "Linux", "CMAKE_SYSTEM_PROCESSOR": "host",
              "ENABLE_LOGGING": "1", "LIQUID_LOG_LEVEL_COMPILE": "0", "ENABLE_COLOR": "0"}
    text = re.sub(r"@([A-Za-z0-9_]+)@",
                  lambda m: config.get(m[1], "0" if m[1].startswith("BUILD_") else ""), text)
    (generated / "acoustic/liquid_include/liquid.config.h").write_text(text)
    includes = [generated / "acoustic/liquid_include", vendor / "liquid_dsp/include",
                vendor / "libfixmatrix", vendor / "libfixmath/libfixmath",
                vendor / "cminpack/include", vendor / "cminpack/src", vendor / "klib",
                generated / "mint", generated / "utensil"]
    defines = ["_XOPEN_SOURCE=700", "LIQUID_LOGGING_ENABLE=1", "LIQUID_LOG_LEVEL_COMPILE=0",
               "FIXMATH_NO_CACHE", "CMINPACK_NO_DLL", "LMX_MINT_TENSORS_ONLY=1",
               "LMX_UTENSIL_CPU_ONLY=1"]
    sources = ([here / name for name in ["probe.c", "mint_probe.c", "utensil_probe.c"]]
               + [vendor / "liquid_dsp/src/matrix/src" / name
                  for name in ["matrixf.c", "matrixcf.c", "smatrixb.c", "smatrix.common.c"]]
               + [vendor / "liquid_dsp/src/core/src/error.c", generated / "acoustic/liquid/logging.c"]
               + sorted((vendor / "libfixmatrix").glob("*.c"))
               + sorted((vendor / "libfixmath/libfixmath").glob("*.c"))
               + [vendor / "cminpack/src" / name for name in ["qrfac.c", "qform.c", "enorm.c", "dpmpar.c"]]
               + [vendor / "klib/keigen.c"])
    flags = ["-std=c99", "-pedantic-errors", "-O0", "-g", "-ffp-contract=off"]
    executable = output / "matrix_backend_probe"
    command = ([compiler] + flags + ["-D" + d for d in defines]
               + ["-I" + str(p) for p in includes] + [str(p) for p in sources]
               + ["-lm", "-o", str(executable)])
    (output / "command.json").write_text(json.dumps(command, indent=2) + "\n")
    run(command, "compile.log")
    result = run([str(executable)], "native_output.log")
    cases = [json.loads(line) for line in result.stdout.splitlines() if line.startswith("{")]
    if len(cases) != 12 or not all(case.get("pass") is True for case in cases):
        raise RuntimeError("expected twelve successful behavior/limitation probes")
    symbols = run([nm, "--defined-only", str(executable)], "symbols.log").stdout
    wanted = ["matrixf_div", "matrixcf_trans", "matrixcf_hermitian", "matrixf_inv",
              "matrixf_ludecomp_doolittle", "matrixf_qrdecomp_gramschmidt", "qrfac",
              "qform", "enorm", "mf16_mul", "smatrixb_mul", "ke_eigen_sd", "mt_matmul", "ut_matmul"]
    observed = {name: [line.split()[1:] for line in symbols.splitlines()
                      if line.split()[-1:] == [name]] for name in wanted}
    if not all(observed.values()):
        raise RuntimeError("a required native definition is absent")
    report = {"status": "PASS", "kind": "selected_source_native_probe",
              "not_lmx_runtime": True, "command": command, "defines": defines, "flags": flags,
              "sources_sha256": {str(p): digest(p) for p in sources},
              "harness_sha256": {p.name: digest(p) for p in [Path(__file__).resolve(),
                                                          here / "probe.c", here / "mint_probe.c",
                                                          here / "utensil_probe.c"]},
              "cases": cases, "symbols": observed,
              "limitation": "A reproduced upstream defect is a passing counterexample, not backend correctness.",
              "not_run": ["production LMX parser/runtime", "C-shim bridge", "whole collection CMake/CTest",
                          "GPU", "external BLAS/LAPACK", "broad numerical stability"]}
    (output / "report.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"PASS: {len(cases)} focused cases, {len(sources)} C units, {len(observed)} native definitions")
    print(output / "report.json")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

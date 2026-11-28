#!/usr/bin/env python3
"""Build and run the real host CPython C API helper, never a LMX emulator."""
from __future__ import annotations

import hashlib
import json
import platform
import shlex
import shutil
import subprocess
import sys
import sysconfig
import tempfile
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
source = HERE / "cpython_host_probe.c"
compiler = shutil.which("cc")
library_name = sysconfig.get_config_var("LDLIBRARY")
libdirs = [Path(sys.base_prefix) / "lib", Path(sysconfig.get_config_var("LIBDIR") or "")]
library = next((folder / library_name for folder in libdirs
                if library_name and (folder / library_name).is_file()), None)
report = {
    "generated_utc": datetime.now(timezone.utc).isoformat(),
    "status": "NOT_RUN",
    "scope": "real host CPython C API only; no LMX execution",
    "python_version": sys.version,
    "host": platform.platform(),
    "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
    "production_lmx": "NOT_RUN",
    "target_platform_builds": "NOT_RUN",
    "cases": [],
}
if not compiler or not library or sys.version_info < (3, 12):
    report["reason"] = "requires cc, shared host libpython, and CPython >=3.12"
else:
    with tempfile.TemporaryDirectory(prefix="lmx_cpython_probe_") as directory:
        executable = Path(directory) / "cpython_host_probe"
        command = [compiler, "-std=c99", "-Wall", "-Wextra", "-Werror",
                   str(source), "-I" + sysconfig.get_path("include"),
                   str(library), "-Wl,-rpath," + str(library.parent),
                   "-o", str(executable)]
        command += shlex.split((sysconfig.get_config_var("LIBS") or "") + " "
                               + (sysconfig.get_config_var("SYSLIBS") or ""))
        compiled = subprocess.run(command, capture_output=True, text=True, timeout=60)
        report["compile_command"] = command
        report["compile_exit"] = compiled.returncode
        report["compile_stderr"] = compiled.stderr
        if compiled.returncode:
            report["status"] = "HOST_PROBE_COMPILE_FAIL"
        else:
            executed = subprocess.run([str(executable), sys.executable, sys.base_prefix],
                                      capture_output=True, text=True, timeout=60)
            report["execution_exit"] = executed.returncode
            report["execution_stderr"] = executed.stderr
            report["cases"] = [json.loads(line) for line in executed.stdout.splitlines()
                               if line.startswith("{")]
            report["status"] = "HOST_C_API_PASS" if (
                executed.returncode == 0 and len(report["cases"]) == 9
                and all(case["passed"] for case in report["cases"])
            ) else "HOST_C_API_FAIL"
(HERE / "host_probe_report.json").write_text(
    json.dumps(report, ensure_ascii=False, indent=2) + "\n")
print(json.dumps(report, ensure_ascii=False, indent=2))
raise SystemExit(report["status"] != "HOST_C_API_PASS")

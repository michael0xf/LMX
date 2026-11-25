#!/usr/bin/env python3
"""Build and exercise the seven nonnumeric additions without the full collection.

This checks C compilation and selected C behavior; it does not compile LMX.
No network operation or package installation is performed.
"""
import argparse
import hashlib
import json
from pathlib import Path
import platform
import shutil
import subprocess


def run(command, log):
    result = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    log.write_text(result.stdout)
    if result.returncode:
        raise SystemExit(f"Command failed ({result.returncode}); see {log}\n" + result.stdout[-5000:])
    return result.stdout


def cmake_quote(value):
    return str(value).replace("\\", "/").replace('"', '\\"')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", required=True, type=Path)
    parser.add_argument("--work-dir", required=True, type=Path, help="Isolated build/log directory")
    parser.add_argument("--cmake", default="cmake")
    parser.add_argument("--ctest", help="Defaults to ctest alongside the selected CMake")
    parser.add_argument("--report", type=Path)
    parser.add_argument("--legacy-xxhash-dir", type=Path, help="Existing LZ4 xxhash source directory for the two-backend test")
    args = parser.parse_args()
    project = args.project.resolve()
    compact = project / "third_party/lmx_c99_compact"
    extension = compact / "extensions/text_hash_extra"
    work = args.work_dir.resolve()
    work.mkdir(parents=True, exist_ok=True)
    cmake = shutil.which(args.cmake) or args.cmake
    ctest = args.ctest or str(Path(cmake).with_name("ctest"))
    if not Path(ctest).exists():
        ctest = shutil.which("ctest") or ctest
    source = work / "driver"
    build = work / "build"
    source.mkdir(exist_ok=True)
    source.joinpath("CMakeLists.txt").write_text('''cmake_minimum_required(VERSION 3.20)
project(LMXNonnumericChecks LANGUAGES C)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(BUILD_TESTING ON)
function(lmx_c99_target target)
    set_target_properties(${target} PROPERTIES C_STANDARD 99 C_STANDARD_REQUIRED YES C_EXTENSIONS NO)
    if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(${target} PRIVATE -pedantic-errors)
    endif()
endfunction()
enable_testing()
''' + 'set(LMX_VENDOR_DIR "' + cmake_quote(compact / "vendor") + '")\n'
        + 'add_subdirectory("' + cmake_quote(extension) + '" additions)\n')
    provenance = json.loads((extension / "PROVENANCE.json").read_text())
    mismatches = []
    for name, item in provenance.items():
        for entry in item["files"]:
            path = compact / "vendor" / name / entry["path"]
            if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != entry["sha256"]:
                mismatches.append(str(path.relative_to(project)))
    if mismatches:
        raise SystemExit("Pinned upstream file hashes differ: " + ", ".join(mismatches))
    configure = [cmake, "-S", str(source), "-B", str(build), "-DCMAKE_BUILD_TYPE=MinSizeRel"]
    if args.legacy_xxhash_dir:
        configure.append("-DLMX_LEGACY_XXHASH_DIR=" + str(args.legacy_xxhash_dir.resolve()))
    run(configure, work / "configure.log")
    run([cmake, "--build", str(build), "--config", "MinSizeRel", "--parallel", "4"], work / "build.log")
    tests = json.loads(run([ctest, "--test-dir", str(build), "-C", "MinSizeRel", "--show-only=json-v1"], work / "test_list.json"))
    run([ctest, "--test-dir", str(build), "-C", "MinSizeRel", "--output-on-failure"], work / "tests.log")
    archives = []
    for path in sorted((build / "additions").rglob("*")):
        if path.suffix not in (".a", ".lib"):
            continue
        info = {"archive": path.name, "archive_bytes": path.stat().st_size}
        size = shutil.which("size")
        if size:
            result = subprocess.run([size, str(path)], capture_output=True, text=True)
            if result.returncode == 0:
                rows = [line.split() for line in result.stdout.splitlines()[1:]]
                values = [list(map(int, row[:3])) for row in rows if len(row) >= 3 and all(x.isdigit() for x in row[:3])]
                if values:
                    info.update(dict(zip(("text_bytes", "data_bytes", "bss_bytes"), (sum(row[i] for row in values) for i in range(3)))))
        archives.append(info)
    if len(archives) != 8:
        raise SystemExit(f"Expected eight static archives from seven components; found {len(archives)}")
    if any(a["archive_bytes"] >= 1_000_000 for a in archives):
        raise SystemExit("At least one archive exceeds the decimal 1 MB criterion")
    compile_commands = build / "compile_commands.json"
    compiler = None
    compiler_version = None
    strict = None
    if compile_commands.exists():
        commands = json.loads(compile_commands.read_text())
        strict = all("-std=c99" in c["command"] and "-pedantic-errors" in c["command"] for c in commands)
        if commands:
            compiler = commands[0]["command"].split()[0]
            version = subprocess.run([compiler, "--version"], capture_output=True, text=True)
            if version.returncode == 0:
                compiler_version = version.stdout.splitlines()[0]
    namespace_check = "NOT_RUN"
    nm = shutil.which("nm")
    modern = next((p for p in (build / "additions").rglob("*xxhash_modern.a")), None)
    if nm and modern:
        result = subprocess.run([nm, "-g", "--defined-only", str(modern)], capture_output=True, text=True)
        if result.returncode == 0:
            names = [line.split()[-1] for line in result.stdout.splitlines() if len(line.split()) >= 3]
            if not names or any(not name.startswith("LMXC99_XXH_") for name in names):
                raise SystemExit("Unprefixed public symbol found in modern xxHash archive")
            namespace_check = "PASS"
    report = {
        "scope": "C_ONLY_COMPONENT_SMOKE_NOT_LMX_RUNTIME",
        "system": platform.platform(), "machine": platform.machine(),
        "build_profile": "CMake MinSizeRel; C99; extensions disabled; GNU/Clang pedantic-errors",
        "compiler": compiler, "compiler_version": compiler_version,
        "all_commands_have_std_c99_pedantic_errors": strict,
        "xxhash_modern_all_public_symbols_namespaced": namespace_check,
        "upstream_file_hashes": "PASS", "configure": "PASS", "build": "PASS",
        "tests": [{"name": t["name"], "result": "PASS"} for t in tests["tests"]],
        "archives": archives,
        "size_limit_bytes": 1_000_000,
        "other_platforms": "NOT_RUN", "interactive_tty_editing": "NOT_RUN",
        "lm3_compilation": "NOT_RUN", "lm3_runtime": "NOT_RUN",
    }
    report_path = args.report or (work / "report.json")
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps({"archives": archives, "tests_passed": len(tests["tests"]), "report": str(report_path)}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

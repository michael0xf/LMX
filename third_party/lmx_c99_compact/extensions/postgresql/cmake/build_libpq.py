#!/usr/bin/env python3
"""Offline libpq build using upstream configure and GNU make.

Original release sources remain read-only. Small generated C99 views cover
the OAuth variadic macro and two Windows ABI spellings. The final archive retains the complete libpq API and just
the frontend support-object closure on POSIX. MinGW keeps upstream's DLL and
import library rather than confusing import stubs with implementation objects.
"""
import argparse
import difflib
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


def run_logged(command, cwd, log, env=None):
    print("RUN", " ".join(str(x) for x in command), flush=True)
    result = subprocess.run(command, cwd=cwd, env=env, stdout=log,
                            stderr=subprocess.STDOUT, text=True)
    log.flush()
    if result.returncode:
        raise SystemExit("Upstream command failed; see " + str(log.name))


def prepare_view(source, build, windows=False):
    relative = Path("src/interfaces/libpq/fe-auth-oauth.c")
    original = (source / relative).read_text()
    needle = "libpq_gettext(fmt), ##__VA_ARGS__"
    if original.count(needle) != 1:
        raise SystemExit("Unexpected OAuth macro; review the pinned source")
    view = original.replace(needle, "libpq_gettext(fmt), __VA_ARGS__")
    for message in ("JSON is too deeply nested",
                    "top-level element must be an object"):
        before = 'oauth_json_set_error(ctx, "' + message + '");'
        after = ('oauth_json_set_error(ctx, "%s", libpq_gettext("'
                 + message + '"));')
        if view.count(before) != 2:
            raise SystemExit("Unexpected OAuth call sites; review source")
        view = view.replace(before, after)
    destination = build / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(view)
    diff = difflib.unified_diff(original.splitlines(True), view.splitlines(True),
                                fromfile="upstream/" + str(relative),
                                tofile="build-view/" + str(relative))
    (build / "lmx-c99-oauth.patch").write_text("".join(diff))
    (build / "lmx-source-view.json").write_text(json.dumps({
        "source": str(relative),
        "original_sha256": hashlib.sha256(original.encode()).hexdigest(),
        "view_sha256": hashlib.sha256(view.encode()).hexdigest(),
        "change": "Four empty-varargs calls become translated %s arguments; "
                  "remove GNU comma swallowing. Message text is unchanged."
    }, indent=2) + "\n")
    if windows:
        # These are OS ABI compatibility details, not PostgreSQL algorithms.
        # Win32 dlsym deliberately exposes a data-pointer API for a procedure
        # address. Copy its equal-width Windows representation explicitly;
        # strict ISO C does not allow the original implicit pointer conversion.
        edits = [
            ("src/port/win32dlopen.c",
             "\tptr = GetProcAddress((HMODULE) handle, symbol);",
             "\t{\n"
             "\t\tFARPROC proc = GetProcAddress((HMODULE) handle, symbol);\n"
             "\t\ttypedef char lmx_win32_proc_pointer_width[(sizeof(proc) == sizeof(ptr)) ? 1 : -1];\n"
             "\t\t(void) sizeof(lmx_win32_proc_pointer_width);\n"
             "\t\tmemcpy(&ptr, &proc, sizeof(ptr));\n"
             "\t}"),
            ("src/port/win32env.c",
             "typedef int (_cdecl * PUTENVPROC)",
             "typedef int (__cdecl * PUTENVPROC)"),
        ]
        details = []
        for name, before, after in edits:
            original_win = (source / name).read_text()
            if original_win.count(before) != 1:
                raise SystemExit("Unexpected pinned Windows port source: " + name)
            view_win = original_win.replace(before, after)
            output = build / name
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_text(view_win)
            patch_name = "lmx-c99-" + Path(name).stem + ".patch"
            (build / patch_name).write_text("".join(difflib.unified_diff(
                original_win.splitlines(True), view_win.splitlines(True),
                fromfile="upstream/" + name, tofile="build-view/" + name)))
            details.append({"source": name,
                            "original_sha256": hashlib.sha256(original_win.encode()).hexdigest(),
                            "view_sha256": hashlib.sha256(view_win.encode()).hexdigest(),
                            "patch": patch_name})
        (build / "lmx-windows-source-views.json").write_text(
            json.dumps(details, indent=2) + "\n")


def configure(args):
    source, build = args.source.resolve(), args.build.resolve()
    build.mkdir(parents=True, exist_ok=True)
    prepare_view(source, build, windows=bool(args.host))
    env = os.environ.copy()
    for key in ("CFLAGS", "CPPFLAGS", "LDFLAGS", "LIBS", "CXXFLAGS"):
        env.pop(key, None)
    env.update(CC=args.cc, CFLAGS=args.cflags, AR=args.ar,
               RANLIB=args.ranlib, BISON=args.bison, FLEX=args.flex,
               PERL=args.perl, M4=args.m4)
    if args.windres:
        env["WINDRES"] = args.windres
    # libpq does not compile the server's semaphore/shared-memory/TAS units.
    # Keep every upstream OS/CPU configure probe and platform template, but
    # suppress just those unused output symlinks in a separate build copy.
    configure_original = (source / "configure").read_text()
    configure_client = configure_original
    before = 'ac_config_links="$ac_config_links src/backend/port/tas.s:src/backend/port/tas/${tas_file}"'
    if configure_client.count(before) != 1:
        raise SystemExit("Unexpected pinned configure TAS link output")
    configure_client = configure_client.replace(before, ": # client-only: no server TAS link output")
    before = 'src/backend/port/pg_sema.c:${SEMA_IMPLEMENTATION} src/backend/port/pg_shmem.c:${SHMEM_IMPLEMENTATION} '
    if configure_client.count(before) != 1:
        raise SystemExit("Unexpected pinned configure server port link outputs")
    configure_client = configure_client.replace(before, "")
    configure_view = build / "lmx-configure-client.sh"
    configure_view.write_text(configure_client)
    (build / "lmx-client-configure.patch").write_text("".join(difflib.unified_diff(
        configure_original.splitlines(True), configure_client.splitlines(True),
        fromfile="upstream/configure", tofile="build-view/configure")))
    command = [args.shell, configure_view.as_posix(), "--srcdir=" + source.as_posix(),
               "--disable-nls", "--without-readline", "--without-zlib",
               "--without-icu", "--without-libcurl", "--without-gssapi",
               "--without-ldap", "--without-pam", "--without-bonjour",
               "--without-llvm", "--without-python", "--without-perl",
               "--without-tcl"]
    if args.host:
        # MSYS's own host is not the MinGW target. Pass both triplets so
        # configure selects the existing win32 implementation, also for cross
        # compilation from a Linux build host.
        build_triplet = subprocess.check_output(
            [args.shell, (source / "config/config.guess").as_posix()],
            cwd=build, env=env, text=True).strip()
        command += ["--build=" + build_triplet, "--host=" + args.host]
    # Omitting --with-ssl selects upstream's no-SSL default. --with-ssl=no is
    # invalid in PostgreSQL 18, so do not pass a fictitious backend argument.
    with (build / "lmx-configure.log").open("w") as log:
        run_logged(command, build, log, env)
    settings = (build / "src/Makefile.global").read_text()
    cflags = re.search(r"^CFLAGS\s*=\s*(.*)$", settings, re.M).group(1)
    if "-std=c99" not in cflags or "-pedantic-errors" not in cflags:
        raise SystemExit("Upstream configuration did not retain strict C99")
    if re.search(r"-std=(gnu|c)(11|17|18|2[03x])", cflags):
        raise SystemExit("Unexpected newer C language mode")
    (build / "lmx-configure.json").write_text(json.dumps({
        "compiler": args.cc, "cflags": cflags, "configure": command,
        "with_ssl": "no", "server_binaries": False,
        "host_triplet": args.host,
    }, indent=2) + "\n")


def archive_objects(ar, archive):
    names = subprocess.check_output([ar, "t", str(archive)], text=True)
    return [archive.parent / name for name in names.splitlines() if name]


def symbols(nm, object_file):
    # POSIX nm format; Mach-O's leading underscores are kept consistently.
    output = subprocess.check_output([nm, "-g", "-P", str(object_file)], text=True)
    defined, required, weak = set(), set(), set()
    for line in output.splitlines():
        fields = line.split()
        if len(fields) < 2 or len(fields[1]) != 1:
            continue
        name, kind = fields[:2]
        if kind == "U":
            required.add(name)
        elif kind in ("w", "v"):
            weak.add(name)
        elif kind.upper() != "N":
            defined.add(name)
    return defined, required, weak


def build_archive(args):
    build = args.build.resolve()
    if args.windows_dll:
        # Refresh small pinned views before an incremental retry as well.
        prepare_view(args.source.resolve(), build, windows=True)
    env = os.environ.copy()
    env["M4"] = args.m4
    steps = [
        ("src/common", "libpgcommon_shlib.a"),
        ("src/port", "libpgport_shlib.a"),
    ]
    if args.windows_dll:
        # The stock MinGW DLL rule links both shared-build support archives
        # and the normal frontend archives. Build those exact prerequisites,
        # without invoking the server-oriented `all` targets.
        steps += [("src/common", "libpgcommon.a"),
                  ("src/port", "libpgport.a")]
    steps.append(("src/interfaces/libpq",
                  "libpq.dll" if args.windows_dll else "libpq.a"))
    with (build / "lmx-build.log").open("w") as log:
        for directory, target in steps:
            command = [args.make, "-C", (build / directory).as_posix(),
                       "-j" + str(args.jobs), target]
            if directory == "src/interfaces/libpq":
                # The normal static target otherwise invokes submake 'all'
                # and builds the unrelated *_srv archives as a side effect.
                command.append("SHLIB_PREREQS=")
            run_logged(command, build, log, env)
    if args.windows_dll:
        # On MinGW upstream libpq.a is produced by --out-implib and its members
        # are not the libpq implementation .o files. Stage that import library
        # plus the matching DLL without applying POSIX static-closure logic.
        pairs = [
            (build / "src/interfaces/libpq/libpq.a", args.archive),
            (build / "src/interfaces/libpq/libpq.dll", args.windows_dll),
        ]
        outputs = []
        for original, destination in pairs:
            if not original.is_file() or not original.stat().st_size:
                raise SystemExit("Missing upstream Windows artifact: " + str(original))
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(original, destination)
            outputs.append({"file": str(destination),
                            "bytes": destination.stat().st_size,
                            "sha256": hashlib.sha256(destination.read_bytes()).hexdigest()})
        (build / "lmx-windows-dll.json").write_text(json.dumps({
            "kind": "upstream MinGW shared library plus import library",
            "static_object_closure": False, "with_ssl": "no",
            "outputs": outputs,
            "runtime_note": "Deploy the DLL and inspect compiler/runtime DLL dependencies for the chosen toolchain."
        }, indent=2) + "\n")
        audit_compilation(build)
        print("Built", args.windows_dll, "and", args.archive)
        return
    roots = archive_objects(args.ar, build / "src/interfaces/libpq/libpq.a")
    candidates = []
    for directory in ("common", "port"):
        candidates += archive_objects(args.ar, build / "src" / directory /
                                      ("libpg" + directory + "_shlib.a"))
    table = {obj: symbols(args.nm, obj) for obj in roots + candidates}
    selected = set(roots)
    while True:
        defined = set().union(*(table[obj][0] for obj in selected))
        unresolved = set().union(*(table[obj][1] for obj in selected)) - defined
        additions = {obj for obj in candidates
                     if table[obj][0] & unresolved} - selected
        if not additions:
            break
        selected.update(additions)
    providers = {}
    for obj in selected:
        for symbol in table[obj][0]:
            providers.setdefault(symbol, []).append(str(obj.relative_to(build)))
    duplicates = {name: objects for name, objects in providers.items()
                  if len(objects) > 1}
    if duplicates:
        raise SystemExit("Duplicate selected symbols: " + repr(duplicates))
    # Keep archive member names unique (same stems could occur in two dirs).
    names = [obj.name for obj in selected]
    if len(set(names)) != len(names):
        raise SystemExit("Duplicate archive member names require review")
    args.archive.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.archive.with_suffix(".tmp.a")
    temporary.unlink(missing_ok=True)
    subprocess.run([args.ar, "rcs", str(temporary),
                    *[str(obj) for obj in sorted(selected)]], check=True)
    subprocess.run([args.ranlib, str(temporary)], check=True)
    temporary.replace(args.archive)
    # A library-safe support closure must never pull frontend fatal allocators.
    if any(name.lstrip("_") in ("exit", "pg_fatal", "pg_malloc")
           for name in unresolved):
        raise SystemExit("Unexpected fatal frontend allocator dependency")
    (build / "lmx-object-closure.json").write_text(json.dumps({
        "libpq_objects": len(roots), "support_objects": len(selected)-len(roots),
        "objects": [str(obj.relative_to(build)) for obj in sorted(selected)],
        "external_symbols": sorted(unresolved),
        "all_selected_defined_symbols": sorted(providers),
        "duplicate_symbols": duplicates,
        "archive_bytes": args.archive.stat().st_size,
    }, indent=2) + "\n")
    audit_compilation(build)
    print("Built", args.archive, "from", len(selected), "client objects")


def audit_compilation(build):
    lines = (build / "lmx-build.log").read_text().splitlines()
    compilations = [line for line in lines
                    if " -c " in line and " -o " in line]
    failures = [line for line in compilations
                if "-std=c99" not in line or "-pedantic-errors" not in line
                or re.search(r"-std=(gnu|c)(11|17|18|2[03x])", line)]
    if failures:
        raise SystemExit("Compile-language audit failed: " + repr(failures))
    server_objects = list(build.glob("src/**/*_srv.o"))
    if server_objects:
        raise SystemExit("Unexpected server-variant objects in fresh client build")
    (build / "lmx-compile-audit.json").write_text(json.dumps({
        "compile_commands_this_invocation": len(compilations),
        "all_commands_strict_c99": not failures,
        "server_variant_objects": len(server_objects),
        "configured_standard": "c99", "pedantic_errors": True,
        "commands": compilations,
    }, indent=2) + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("phase", choices=("configure", "build"))
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--build", type=Path, required=True)
    parser.add_argument("--archive", type=Path)
    parser.add_argument("--cc")
    parser.add_argument("--cflags")
    parser.add_argument("--host", help="MinGW compiler target triplet")
    parser.add_argument("--windres", help="MinGW resource compiler")
    parser.add_argument("--windows-dll", type=Path,
                        help="Stage upstream DLL here; --archive becomes its import library")
    parser.add_argument("--shell", default="sh")
    parser.add_argument("--ar", default="ar")
    parser.add_argument("--ranlib", default="ranlib")
    parser.add_argument("--nm", default="nm")
    parser.add_argument("--make", default="make")
    parser.add_argument("--bison", default="bison")
    parser.add_argument("--flex", default="flex")
    parser.add_argument("--perl", default="perl")
    parser.add_argument("--m4", default="m4")
    parser.add_argument("--jobs", type=int, default=2)
    args = parser.parse_args()
    if args.phase == "configure":
        configure(args)
    else:
        build_archive(args)


if __name__ == "__main__":
    main()

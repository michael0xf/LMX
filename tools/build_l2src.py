#!/usr/bin/env python3
"""Portable twin of tools/build_l2src.ps1: translate dev/l2src_sandbox to C, compile, link the
selftests by symbol and run them -- on any host with gcc, nm and python (the cloud sessions).

    python tools/build_l2src.py                 # build the translator from the seed, then everything
    python tools/build_l2src.py --no-run        # link the selftests, do not run them
    python tools/build_l2src.py --translator P  # use an existing l1trans (no pin check here)
    python tools/build_l2src.py --only lmx_pool # only the selftests whose name contains the text

It is a PORT of the .ps1 (same staging, same nm link resolver, same expected-fatal
contract for lmx_close_watchdog_running_selftest), not a replacement: the .ps1 with the pinned
bin/l1trans.exe stays the gate on the author's machine.  Two differences, said out loud:
  * the translator is gcc of lm1/build/l1trans.lm1.c AS CHECKED OUT (the self-build seed, the same
    B0 tools/run_self_build.sh starts from) unless --translator names one; L1_PIN.txt is not
    consulted, since the pin is the hash of a Windows executable;
  * off Windows the three platform bodies are the POSIX twins, and those compiles add
    `-pthread` and `-D_POSIX_C_SOURCE=200809L`. The .ps1 gate always stages the Win32
    body and does not change its flags.
Evidence goes under build/l2src_py/<stamp>/ (ignored by git).
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FLAGS_BASE = ['-std=c99', '-Wall', '-Wextra', '-Wpedantic',
              '-Werror=incompatible-pointer-types', '-Werror=discarded-qualifiers',
              '-Werror=implicit-function-declaration', '-Werror=implicit-int']
SELFTEST_TIMEOUT = 120


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--translator', type=Path, default=None)
    ap.add_argument('--out', type=Path, default=None)
    ap.add_argument('--no-run', action='store_true')
    ap.add_argument('--only', default=None, help='run only the selftests whose name contains this text')
    ap.add_argument('--cc', default='gcc')
    args = ap.parse_args()

    out = args.out or (ROOT / 'build' / 'l2src_py' / time.strftime('%Y%m%d_%H%M%S'))
    if out.exists():
        shutil.rmtree(out)
    logs = out / 'logs'
    for d in ('logs', 'obj', 'bin', 'headers/l2src/tests', 'src/l2src/tests', 'src/l1src'):
        (out / d).mkdir(parents=True, exist_ok=True)
    print(f'build_l2src.py: repository root={ROOT}')
    print(f'build_l2src.py: evidence {out}')

    # 0) the translator
    translator = args.translator
    if translator is None:
        seed = ROOT / 'lm1' / 'build' / 'l1trans.lm1.c'
        translator = out / 'b0' / 'l1trans'
        translator.parent.mkdir(parents=True)
        cmd = [args.cc] + FLAGS_BASE + ['-I', str(ROOT), '-I', str(ROOT / 'lm1' / 'build'), '-o', str(translator), str(seed)]
        with open(logs / 'b0.gcc.log', 'w') as fh:
            r = subprocess.run(cmd, stdout=fh, stderr=subprocess.STDOUT)
        if r.returncode != 0 or not translator.exists():
            print(f'build_l2src.py RED: the translator did not build from {seed}; log {logs / "b0.gcc.log"}')
            return 1
        print(f'build_l2src.py: translator built from the seed {seed}')
    translator = translator.resolve()
    print(f'build_l2src.py: translator {translator}')

    # 1) stage: the sandbox is the live tree; sources reference each other as "l2src/<name>"
    flat = ROOT / 'dev' / 'l2src_sandbox'
    staged = out / 'src' / 'l2src'
    n = 0
    host = 'win32' if os.name == 'nt' else 'posix'
    for f in flat.glob('*.lm1'):
        if f.name.endswith('_win32.lm1') or f.name.endswith('_posix.lm1'):
            continue
        shutil.copy(f, staged / f.name); n += 1
    # -200: one logical body name. Windows keeps the Win32 body; another host takes the POSIX body.
    for logical in ('lmx_clock.lm1', 'lmx_process_deadline.lm1', 'lmx_manager_running.lm1', 'lmx_manager_running_lane.lm1'):
        physical = logical.replace('.lm1', '_' + host + '.lm1')
        shutil.copy(flat / physical, staged / logical); n += 1
    for f in (flat / 'tests').glob('*.lm1'):
        shutil.copy(f, staged / 'tests' / f.name); n += 1
    for f in (flat / 'l1src').iterdir():
        if f.is_file():
            shutil.copy(f, out / 'src' / 'l1src' / f.name); n += 1
    source_base = out / 'src'
    headers = out / 'headers'
    obj = out / 'obj'
    bindir = out / 'bin'
    dec = ROOT / 'third_party' / 'decNumber' / 'decNumber-icu-368'
    flags = FLAGS_BASE + ['-I', str(ROOT), '-I', str(ROOT / 'lm1' / 'build'), '-I', str(source_base),
                          '-I', str(headers), '-I', str(dec)]
    if host == 'posix':
        flags += ['-pthread', '-D_POSIX_C_SOURCE=200809L']
    print(f'build_l2src.py: sources STAGED from {flat} -> {staged} ({n} files, incl. kernel-side l1src); cwd = {source_base}')

    rows = []
    failed = []

    def row(state, label, note=''):
        rows.append((state, label, note))
        print(f'{state:<4} {label:<40} {note}', flush=True)
        if state == 'FAIL':
            failed.append(label)

    def safe(name):
        return re.sub(r'[:/\\*?"<>|]', '_', name)

    def captured(exe, argv, logname):
        log = logs / (safe(logname) + '.log')
        with open(log, 'w') as fh:
            fh.write(f'invoke: "{exe}" {" ".join(str(a) for a in argv)}\n')
            fh.flush()
            r = subprocess.run([str(exe)] + [str(a) for a in argv], stdout=fh, stderr=subprocess.STDOUT, cwd=str(source_base))
        return r.returncode, log

    def convert(label, rel, target):
        code, log = captured(translator, [rel, target], 'translate_' + label)
        if code != 0 or not Path(target).exists():
            row('FAIL', label, f'translate exit {code}; log {log}')
            return False
        return True

    def compile_c(label, src, o):
        code, log = captured(args.cc, flags + ['-c', src, '-o', o], 'compile_' + label)
        if code != 0 or not Path(o).exists():
            row('FAIL', label, f'gcc exit {code}; log {log}')
            return False
        return True

    symcache = {}

    def symbols(path, undefined=False):
        if not Path(path).exists():
            return set()
        key = (str(path), undefined)
        if key in symcache:
            return symcache[key]
        text = subprocess.run(['nm', '-u' if undefined else '--defined-only', str(path)], capture_output=True, text=True).stdout
        found = set()
        for line in text.splitlines():
            parts = line.split()
            if len(parts) >= 2 and re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', parts[-1]):
                found.add(parts[-1])
        symcache[key] = found
        return found

    def resolve_link(test_obj, pool):
        # The same resolver as the .ps1: add only objects defining a symbol the program still
        # lacks, in rounds; the program's own object counts as a provider from round 0.
        chosen = []
        selected = set()
        for _ in range(32):
            need = set(symbols(test_obj, True))
            for o in chosen:
                need |= symbols(o, True)
            have = set(symbols(test_obj))
            for o in chosen:
                have |= symbols(o)
            missing = need - have
            if not missing:
                break
            added = False
            for o in pool:
                if o in selected:
                    continue
                if symbols(o) & missing:
                    chosen.append(o); selected.add(o); added = True
                    break
            if not added:
                break
        return chosen

    t0 = time.time()
    # 2) predef headers
    for h in sorted(staged.glob('*.h.lm1')):
        base = h.name[:-len('.h.lm1')]
        if convert(f'header:{base}', f'l2src/{h.name}', headers / 'l2src' / f'{base}.lm1.h'):
            row('OK', f'header:{base}')
    for h in sorted((staged / 'tests').glob('*.h.lm1')):
        base = h.name[:-len('.h.lm1')]
        if convert(f'header:tests/{base}', f'l2src/tests/{h.name}', headers / 'l2src' / 'tests' / f'{base}.lm1.h'):
            row('OK', f'header:tests/{base}')
    # 3) units
    objects = []
    units = [u for u in sorted(staged.glob('*.lm1')) if not u.name.endswith('_selftest.lm1') and not u.name.endswith('.h.lm1')]
    units += [u for u in sorted((staged / 'tests').glob('*.lm1')) if not u.name.endswith('_selftest.lm1') and not u.name.endswith('.h.lm1')]
    for u in units:
        in_tests = u.parent.name == 'tests'
        base = ('tests_' if in_tests else '') + u.name[:-4]
        rel = f'l2src/tests/{u.name}' if in_tests else f'l2src/{u.name}'
        c = obj / f'{base}.c'
        o = obj / f'{base}.o'
        if not convert(f'unit:{base}', rel, c):
            continue
        if compile_c(f'unit:{base}', c, o):
            objects.append(o); row('OK', f'unit:{base}')
    # 4) hand-written C and the vendored decNumber
    for c in sorted(staged.glob('*.c')):
        base = c.name[:-2]
        o = obj / f'{base}.o'
        if compile_c(f'handC:{base}', c, o):
            row('OK', f'handC:{base}')
    third = []
    for name in ('decNumber.c', 'decContext.c'):
        src = dec / name
        if not src.exists():
            continue
        base = name[:-2]
        o = obj / f'tp_{base}.o'
        if compile_c(f'thirdparty:{base}', src, o):
            third.append(o); row('OK', f'thirdparty:{base}')
    # 5) selftests
    selftests = sorted(list(staged.glob('*_selftest.lm1')) + list((staged / 'tests').glob('*_selftest.lm1')), key=lambda p: p.name)
    for t in selftests:
        base = t.name[:-4]
        if args.only and args.only not in base:
            continue
        rel = f'l2src/tests/{t.name}' if t.parent.name == 'tests' else f'l2src/{t.name}'
        c = obj / f'{base}.c'
        exe = bindir / base
        if not convert(f'selftest:{base}', rel, c):
            continue
        to = obj / f'{base}.selftest.o'
        if not compile_c(f'selftest:{base}', c, to):
            continue
        link = flags + ['-o', exe, to]
        text = c.read_text(errors='replace')
        for fn in ('malloc', 'free', 'realloc', 'calloc'):
            if re.search(f'__wrap_{fn}|__real_{fn}', text):
                link.append(f'-Wl,--wrap={fn}')
        link += resolve_link(to, objects + third)
        code, log = captured(args.cc, link, f'selftest:{base}')
        if code != 0 or not exe.exists():
            row('FAIL', f'selftest:{base}', f'link exit {code}; log {log}')
            continue
        if args.no_run:
            row('OK', f'selftest:{base}', 'linked')
            continue
        log = logs / (safe(f'run:selftest:{base}') + '.log')
        try:
            r = subprocess.run([str(exe)], capture_output=True, timeout=SELFTEST_TIMEOUT, cwd=str(source_base))
        except subprocess.TimeoutExpired:
            row('FAIL', f'selftest:{base}', f'TIMEOUT after {SELFTEST_TIMEOUT} s (killed)')
            continue
        stdout = r.stdout.decode(errors='replace')
        stderr = r.stderr.decode(errors='replace')
        log.write_text(f'invoke: "{exe}"\nexit {r.returncode}\n--- stdout\n{stdout}\n--- stderr\n{stderr}')
        if base == 'lmx_close_watchdog_running_selftest':
            # THE ONE TARGET ALLOWED TO BE FATAL ON PURPOSE (the .ps1's five-clause contract).
            why = ''
            if r.returncode != 3:
                why = f'exit {r.returncode}, expected exactly 3'
            elif 'PROBE-RUNNING armed:' not in stdout:
                why = 'the armed marker is missing from STDOUT'
            elif 'PROBE-RUNNING the close RETURNED' in stdout:
                why = 'the close RETURNED'
            elif 'the overall close deadline expired' not in stderr:
                why = 'no close-deadline diagnostic on STDERR'
            if why:
                row('FAIL', f'selftest:{base}', f'expected-fatal FAILED: {why}; log {log}')
            else:
                row('OK', f'selftest:{base}', 'ran, expected-fatal: exit 3, armed stdout, deadline stderr')
            continue
        if r.returncode == 0:
            row('OK', f'selftest:{base}', 'ran, exit 0')
        else:
            row('FAIL', f'selftest:{base}', f'ran, exit {r.returncode}; log {log}')
    # 6) selftests written in C
    for c in sorted(staged.glob('*_selftest.c')):
        base = c.name[:-2]
        if args.only and args.only not in base:
            continue
        to = obj / f'{base}.o'
        exe = bindir / base
        if not to.exists():
            row('FAIL', f'cselftest:{base}', f'object never built: {to}')
            continue
        code, log = captured(args.cc, flags + ['-o', exe, to] + resolve_link(to, objects + third), f'cselftest:{base}')
        if code != 0 or not exe.exists():
            row('FAIL', f'cselftest:{base}', f'link exit {code}; log {log}')
            continue
        if args.no_run:
            row('OK', f'cselftest:{base}', 'linked')
            continue
        try:
            r = subprocess.run([str(exe)], capture_output=True, timeout=SELFTEST_TIMEOUT, cwd=str(source_base))
        except subprocess.TimeoutExpired:
            row('FAIL', f'cselftest:{base}', 'TIMEOUT')
            continue
        row('OK' if r.returncode == 0 else 'FAIL', f'cselftest:{base}', f'ran, exit {r.returncode}')

    print()
    sec = int(time.time() - t0)
    (out / 'rows.txt').write_text('\n'.join(f'{s:<4} {l:<40} {n}' for s, l, n in rows) + '\n')
    if failed:
        print(f'build_l2src.py RED: {len(failed)} of {len(rows)} targets failed ({", ".join(failed)}); {sec}s; evidence {out}')
        return 1
    print(f'build_l2src.py GREEN: {len(rows)} targets, no failures; {sec}s; evidence {out}')
    return 0


if __name__ == '__main__':
    sys.exit(main())

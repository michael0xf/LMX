"""Build and run dev/l3_interp selftests in a private unit-root.

    python tools/run_l3_selftest.py
    python tools/run_l3_selftest.py --test tests/l3_02_selftest.lm1

Default runs L3-01..04, 14 recipes, thread_bind, admit, N9 and N10, and then the
header-type-name budget of the Thread units (tools/l3_type_budget.py).  The budget is part of
the default run because its failure is the one this runner cannot otherwise see coming: a unit
over l1trans's table of 64 type names does not fail a check, it stops translating, and the L2
gate (tools/build_l2src.ps1) does not build dev/l3_interp at all.
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SANDBOX = ROOT / 'dev' / 'l2src_sandbox'
L3 = ROOT / 'dev' / 'l3_interp'
ALL_TESTS = (
    'tests/l3_01_selftest.lm1',
    'tests/l3_02_selftest.lm1',
    'tests/l3_03_selftest.lm1',
    'tests/l3_04_selftest.lm1',
    'tests/l3_recipes_selftest.lm1',
    'tests/l3_thread_bind_selftest.lm1',
    'tests/l3_admit_selftest.lm1',
    'tests/l3_n9_walk_selftest.lm1',
    'tests/l3_n10_walk_selftest.lm1',
    'tests/l3_mail_prim_selftest.lm1',
    'tests/l3_expect_int_selftest.lm1',
)


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_one(translator, l1src, cc, test, output):
    stem = Path(test).name[:-len('.lm1')]
    libc = l1src / 'libc_abi.lm1'
    if not libc.is_file():
        print(f'missing {libc}', file=sys.stderr)
        return 2
    if output.exists():
        shutil.rmtree(output)
    unit_root = output / 'unitroot'
    generated = output / 'generated'
    (unit_root / 'l2src').mkdir(parents=True)
    (unit_root / 'l3_interp' / 'tests').mkdir(parents=True)
    (unit_root / 'l1src').mkdir(parents=True)
    (generated / 'l2src').mkdir(parents=True)
    (generated / 'l3_interp').mkdir(parents=True)
    (generated / 'l1src').mkdir(parents=True)
    manifest = {'translator': str(translator), 'translator_sha256': sha256(translator),
                'l1src': str(l1src), 'test': test, 'sources': {}, 'steps': []}

    def take(source, target):
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        manifest['sources'][str(target.relative_to(unit_root)).replace(os.sep, '/')] = sha256(source)

    for source in sorted(SANDBOX.glob('lmx*.lm1')):
        take(source, unit_root / 'l2src' / source.name)
    take(SANDBOX / 'l2_libc.lm1', unit_root / 'l2src' / 'l2_libc.lm1')
    for source in sorted(L3.glob('l3*.lm1')):
        take(source, unit_root / 'l3_interp' / source.name)
    take(L3 / test, unit_root / 'l3_interp' / test)
    for source in sorted(l1src.glob('*.lm1')):
        take(source, unit_root / 'l1src' / source.name)

    env = os.environ.copy()

    def run(command, label, check=True):
        result = subprocess.run([str(x) for x in command], cwd=str(unit_root), env=env,
                                capture_output=True, timeout=300)
        (output / f'{label}.stdout').write_bytes(result.stdout)
        (output / f'{label}.stderr').write_bytes(result.stderr)
        manifest['steps'].append({'label': label, 'exit': result.returncode})
        if check and result.returncode:
            (output / 'build.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
            err = (output / (label + '.stderr')).read_text(encoding='utf-8', errors='replace')[-2000:]
            print(f'{test} {label} failed ({result.returncode}); {err}', file=sys.stderr)
        return result

    def translate(unit, target, label):
        target.parent.mkdir(parents=True, exist_ok=True)
        return run([translator, '--unit-root', str(unit_root), unit, str(target)], label)

    for folder in ('l2src', 'l3_interp', 'l1src'):
        for header in sorted((unit_root / folder).glob('*.h.lm1')):
            name = header.name[:-len('.h.lm1')]
            result = translate(f'{folder}/{header.name}', generated / folder / f'{name}.lm1.h',
                               f'header-{folder}-{name}')
            if result.returncode:
                return result.returncode
    result = translate(f'l3_interp/{test}', generated / f'{stem}.c', 'translate-selftest')
    if result.returncode:
        return result.returncode
    result = translate('l2src/l2_libc.lm1', generated / 'l2_libc.c', 'translate-l2_libc')
    if result.returncode:
        return result.returncode
    exe = output / (f'{stem}.exe' if os.name == 'nt' else stem)
    command = [cc, '-std=c11', '-Wall', '-Wextra', '-Wpedantic',
               '-Werror=incompatible-pointer-types', '-Werror=discarded-qualifiers',
               '-Werror=implicit-function-declaration', '-Werror=implicit-int',
               '-I', str(generated), '-I', str(unit_root), '-o', str(exe),
               str(generated / f'{stem}.c'), str(generated / 'l2_libc.c')]
    result = run(command, 'gcc')
    if result.returncode:
        return result.returncode
    result = run([str(exe)], 'selftest', check=False)
    manifest['selftest_exit'] = result.returncode
    manifest['selftest_stdout'] = result.stdout.decode('utf-8', errors='replace').strip()
    (output / 'build.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(manifest['selftest_stdout'])
    print(f'exit={result.returncode}; evidence: {output}')
    return result.returncode


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--translator', type=Path, default=ROOT / 'bin' / 'l1trans.exe')
    ap.add_argument('--l1src', type=Path, default=SANDBOX / 'l1src')
    ap.add_argument('--cc', default='gcc')
    ap.add_argument('--test', default=None, help='one selftest relative to dev/l3_interp; default: all')
    ap.add_argument('--output', type=Path, default=None)
    args = ap.parse_args()
    translator = args.translator.resolve(strict=True)
    l1src = args.l1src.resolve(strict=True)
    if args.test:
        tests = [args.test.replace(os.sep, '/')]
    else:
        tests = list(ALL_TESTS)
    failed = []
    for test in tests:
        stem = Path(test).name[:-len('.lm1')]
        if args.output is None:
            output = L3 / 'build' / stem
        elif args.test:
            output = args.output
        else:
            output = args.output / stem
        code = run_one(translator, l1src, args.cc, test, output)
        if code:
            failed.append((test, code))
    budget_failures = []
    if not args.test:
        # A suite over the cliff shows above as a translate failure in some unrelated header;
        # this says which unit, by how much, and says it while there is still room.
        import l3_type_budget
        budget_failures = l3_type_budget.check(translator, l1src)
    if failed:
        for test, code in failed:
            print(f'FAIL {test} exit={code}')
        return failed[0][1]
    if budget_failures:
        print(f'FAIL type budget: {len(budget_failures)} unit(s); python tools/l3_type_budget.py')
        return 1
    if args.test:
        print(f'all {len(tests)} suites ok')
    else:
        print(f'all {len(tests)} suites ok; type budget ok ({len(l3_type_budget.EXPECT)} units)')
    return 0


if __name__ == '__main__':
    sys.exit(main())

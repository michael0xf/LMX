"""Build and run a selftest of dev/l2src_sandbox (by default tests/lmx_walk_selftest.lm1) with an existing L1 translator and GCC.

Nothing under dev/ or the stable roots is edited: the sources are copied into a private unit
root below the output directory, translated there, compiled and run. The output directory
keeps the evidence: per-step stdout/stderr, the test's own output, its exit code and a
manifest with the hashes of the translator and of every source that was used.

    python tools/run_walk_selftest.py
    python tools/run_walk_selftest.py --test tests/lmx_scratch_selftest.lm1
    python tools/run_walk_selftest.py --translator C:/Nyasha_Planet/L1/bin/l1trans.exe \
        --l1src C:/Nyasha_Planet/L1/dev/l2src_sandbox/l1src
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
TEST = 'tests/lmx_walk_selftest.lm1'


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--translator', type=Path, default=ROOT / 'bin' / 'l1trans.exe')
    ap.add_argument('--l1src', type=Path, default=SANDBOX / 'l1src',
                    help='directory holding the libc layer libc_abi.lm1 that declares l1_stdout')
    ap.add_argument('--cc', default='gcc')
    ap.add_argument('--test', default=TEST, help='selftest unit, relative to dev/l2src_sandbox')
    ap.add_argument('--output', type=Path, default=None,
                    help='evidence directory (default: dev/l2src_sandbox/build/<name of the test>)')
    args = ap.parse_args()
    test = args.test.replace(os.sep, '/')
    stem = Path(test).name[:-len('.lm1')]
    if args.output is None:
        args.output = SANDBOX / 'build' / ('walk' if test == TEST else stem)

    translator = args.translator.resolve(strict=True)
    l1src = args.l1src.resolve(strict=True)
    libc = l1src / 'libc_abi.lm1'
    if 'l1_stdout' not in libc.read_text(encoding='utf-8', errors='replace'):
        sys.exit(f'{libc} does not declare l1_stdout; pass --l1src with the sandbox libc layer')

    output = args.output.resolve()
    if output.exists():
        shutil.rmtree(output)
    unit_root = output / 'unitroot'
    generated = output / 'generated'
    (unit_root / 'l2src' / Path(test).parent).mkdir(parents=True, exist_ok=True)
    (unit_root / 'l1src').mkdir(parents=True)
    (generated / 'l2src').mkdir(parents=True)
    (generated / 'l1src').mkdir(parents=True)

    manifest = {'translator': str(translator), 'translator_sha256': sha256(translator),
                'l1src': str(l1src), 'sources': {}, 'steps': []}

    def take(source, target):
        shutil.copyfile(source, target)
        manifest['sources'][str(target.relative_to(unit_root)).replace(os.sep, '/')] = sha256(source)

    for source in sorted(SANDBOX.glob('lmx*.lm1')):
        take(source, unit_root / 'l2src' / source.name)
    take(SANDBOX / 'l2_libc.lm1', unit_root / 'l2src' / 'l2_libc.lm1')
    take(SANDBOX / test, unit_root / 'l2src' / test)
    for source in sorted(l1src.glob('*.lm1')):
        take(source, unit_root / 'l1src' / source.name)

    env = os.environ.copy()
    for key in ('LM_TRANS_REGISTRY', 'LM_TRANS_REGISTRY_VIEW', 'LM_P0_REGISTRY', 'LM_P0_COMPARE_REGISTRY'):
        env.pop(key, None)

    def run(command, label, check=True):
        result = subprocess.run([str(x) for x in command], cwd=unit_root, env=env,
                                capture_output=True, timeout=300)
        (output / f'{label}.stdout').write_bytes(result.stdout)
        (output / f'{label}.stderr').write_bytes(result.stderr)
        manifest['steps'].append({'label': label, 'exit': result.returncode})
        if check and result.returncode:
            (output / 'build.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
            sys.exit(f'{label} failed ({result.returncode}); see {output / (label + ".stderr")}')
        return result

    def translate(unit, target, label):
        run([translator, '--unit-root', unit_root, unit, target], label)

    # Every header unit <dir>/<name>.h.lm1 becomes <generated>/<dir>/<name>.lm1.h, which is
    # what a `predef:` of that unit includes.
    for folder in ('l2src', 'l1src'):
        for header in sorted((unit_root / folder).glob('*.h.lm1')):
            name = header.name[:-len('.h.lm1')]
            translate(f'{folder}/{header.name}', generated / folder / f'{name}.lm1.h', f'header-{folder}-{name}')
    translate(f'l2src/{test}', generated / f'{stem}.c', 'translate-selftest')
    translate('l2src/l2_libc.lm1', generated / 'l2_libc.c', 'translate-l2_libc')

    exe = output / (f'{stem}.exe' if os.name == 'nt' else stem)
    command = [args.cc, '-std=c99', '-Wall', '-Wextra', '-Wpedantic',
               '-Werror=incompatible-pointer-types', '-Werror=discarded-qualifiers',
               '-Werror=implicit-function-declaration', '-Werror=implicit-int',
               '-I', generated, '-I', unit_root, '-o', exe,
               generated / f'{stem}.c', generated / 'l2_libc.c']
    run(command, 'gcc')
    manifest['compiler_command'] = [str(x) for x in command]

    result = run([exe], 'selftest', check=False)
    manifest['selftest_exit'] = result.returncode
    manifest['selftest_stdout'] = result.stdout.decode('utf-8', errors='replace').strip()
    (output / 'build.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(manifest['selftest_stdout'])
    print(f'exit={result.returncode}; evidence: {output}')
    sys.exit(result.returncode)


if __name__ == '__main__':
    main()

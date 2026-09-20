"""Build the dev P0 parser using an existing L1 translator and GCC, without editing stable sources."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--translator', type=Path, required=True)
    ap.add_argument('--cc', default='gcc')
    ap.add_argument('--output', type=Path, default=ROOT / 'dev/l1src_sandbox/build')
    args = ap.parse_args()
    translator = args.translator.resolve(strict=True)
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    (output / 'l1src').mkdir(exist_ok=True)
    env = os.environ.copy()
    for key in ('LM_TRANS_REGISTRY', 'LM_TRANS_REGISTRY_VIEW', 'LM_P0_REGISTRY', 'LM_P0_COMPARE_REGISTRY'):
        env.pop(key, None)
    mapping = [
        ('l1src/p0.h.lm1', 'l1src/p0.lm1.h'),
        ('l1src/own.lm1', 'l1src/own.lm1.c'),
        ('l1src/parser_text.lm1', 'l1src/parser_text.lm1.c'),
        ('dev/l1src_sandbox/parser.lm1', 'l1src/parser.lm1.c'),
        ('dev/l1src_sandbox/printTree.lm1', 'printTree.lm1.c'),
    ]
    manifest = {'translator': str(translator),
                'translator_sha256': hashlib.sha256(translator.read_bytes()).hexdigest(),
                'sources': []}

    def run(command, label):
        result = subprocess.run([str(x) for x in command], cwd=ROOT, env=env,
                                capture_output=True, timeout=120)
        (output / f'{label}.stdout').write_bytes(result.stdout)
        (output / f'{label}.stderr').write_bytes(result.stderr)
        if result.returncode:
            raise RuntimeError(f'{label} failed ({result.returncode}); see {output / (label + ".stderr")}')

    for index, (source, target) in enumerate(mapping):
        run([translator, ROOT / source, output / target], f'translate-{index}')
        manifest['sources'].append({'path': source, 'sha256': hashlib.sha256((ROOT / source).read_bytes()).hexdigest()})
    exe = output / ('printTree.exe' if os.name == 'nt' else 'printTree')
    command = [args.cc, '-std=c99', '-Wall', '-Wextra', '-Wpedantic',
               '-Werror=incompatible-pointer-types', '-Werror=discarded-qualifiers',
               '-Werror=implicit-function-declaration', '-Werror=implicit-int',
               '-I', str(output), '-I', str(ROOT), '-o', str(exe), str(output / 'printTree.lm1.c')]
    run(command, 'gcc')
    manifest['compiler_command'] = command
    manifest['parser_sha256'] = hashlib.sha256(exe.read_bytes()).hexdigest()
    (output / 'build.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(exe)


if __name__ == '__main__':
    main()

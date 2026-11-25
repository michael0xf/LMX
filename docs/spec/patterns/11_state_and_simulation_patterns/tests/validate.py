#!/usr/bin/env python3
"""Execute foreign listings against shared fixtures and independent oracles.

Does not claim to execute or parse LMX. Does not recalculate size statistics.
Builds only inside a temporary directory; no binaries enter the archive.
"""

from pathlib import Path
import argparse
import datetime
import hashlib
import itertools
import json
import os
import random
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
LIMIT = 2147483647


def double_buffer(case):
    cells, steps = case['cells'], case['steps']
    if steps < 0:
        return {'error': 'InvalidSteps'}
    if any(x not in (0, 1) for x in cells):
        return {'error': 'InvalidCell'}
    # Immutable list shifts form an oracle independent of buffer reuse/swap.
    out = list(cells)
    for _ in range(steps):
        left = out[-1:] + out[:-1]
        right = out[1:] + out[:1]
        out = [a ^ b for a, b in zip(left, right)]
    return {'cells': out}


def dirty_flag(case):
    values = list(case['values'])
    dirty, cached, rebuilds, events = True, 0, 0, []
    for op in case['ops']:
        event = {}
        if op[0] == 'G':
            if dirty:
                cached = max(values, default=0)
                rebuilds += 1
                dirty = False
            event['value'] = cached
        elif op[0] == 'R':
            values, dirty = list(op[1]), True
        elif 0 <= op[1] < len(values):
            values[op[1]], dirty = op[2], True
        else:
            event['error'] = 'InvalidIndex'
        events.append(dict(event, dirty=dirty, rebuilds=rebuilds))
    return dict(events=events, values=values, cached=cached, dirty=dirty, rebuilds=rebuilds)


def fixed_timestep(case):
    step, deltas = case['step'], case['deltas']
    if step <= 0:
        return {'error': 'InvalidStep'}
    total = 0
    for elapsed in deltas:
        if elapsed < 0:
            return {'error': 'InvalidElapsed'}
        total += elapsed
        if total > LIMIT:
            return {'error': 'TimeOverflow'}
    # Closed form: each 7 ticks adds 1+2+3+4+5+6+0 = 21 to position.
    # This oracle has no per-tick update loop and checks the actual transitions.
    total, result = 0, []
    for elapsed in deltas:
        total += elapsed
        ticks, lag = divmod(total, step)
        cycles, remainder = divmod(ticks, 7)
        position = (21 * cycles + remainder * (remainder + 1) // 2) % 97
        result.append(dict(ticks=ticks, position=position, velocity=remainder, lag=lag))
    return {'frames': result}


ORACLES = {'double_buffer': double_buffer, 'dirty_flag': dirty_flag, 'fixed_timestep': fixed_timestep}


def encode(kind, case):
    if kind == 'double_buffer':
        values = [case['steps'], len(case['cells']), *case['cells']]
    elif kind == 'fixed_timestep':
        values = [case['step'], len(case['deltas']), *case['deltas']]
    else:
        values = [len(case['values']), *case['values'], len(case['ops'])]
        for op in case['ops']:
            values += ['R', len(op[1]), *op[1]] if op[0] == 'R' else op
    return ' '.join(map(str, values))


def expand_cases(named):
    cases = {kind: list(rows) for kind, rows in named.items()}
    for size in range(9):
        for cells in itertools.product((0, 1), repeat=size):
            for steps in range(5):
                cases['double_buffer'].append(dict(cells=list(cells), steps=steps))
    rng = random.Random(106107108)
    for _ in range(100):
        size = rng.randrange(40)
        cases['double_buffer'].append(dict(cells=[rng.randrange(2) for _ in range(size)], steps=rng.randrange(40)))
        values = [rng.randrange(-100, 101) for _ in range(rng.randrange(12))]
        current_size, ops = len(values), []
        for _ in range(40):
            kind = rng.randrange(4)
            if kind < 2:
                ops.append(['G'])
            elif kind == 2:
                ops.append(['S', rng.randrange(-1, current_size + 2), rng.randrange(-100, 101)])
            else:
                replacement = [rng.randrange(-100, 101) for _ in range(rng.randrange(12))]
                ops.append(['R', replacement])
                current_size = len(replacement)
        cases['dirty_flag'].append(dict(values=values, ops=ops))
        cases['fixed_timestep'].append(dict(step=rng.randrange(1, 30),
                                           deltas=[rng.randrange(60) for _ in range(rng.randrange(30))]))
    return cases


def run(command, **kwargs):
    result = subprocess.run(command, text=True, capture_output=True, timeout=90, **kwargs)
    if result.returncode:
        raise RuntimeError(f'{command!r} failed ({result.returncode})\n{result.stdout}\n{result.stderr}')
    return result.stdout


def check_listing_mirrors():
    manifest = ROOT / 'patterns.json'
    if not manifest.exists():
        return 'NOT_RUN: patterns.json has not been generated yet'
    data = json.loads(manifest.read_text())
    checked = 0
    for pattern in data['patterns']:
        document = (ROOT / pattern['comparison_file']).read_text()
        for entry in pattern['listings']:
            if entry['language'] == 'LMX':
                continue
            source = (ROOT / entry['source_file']).read_text()
            assert entry['code'] == source
            assert source.rstrip() in document
            checked += 1
        common = (ROOT / pattern['lmx_shared_source']).read_text()
        assert common.rstrip() in document
        for variant in pattern['lmx_variants'].values():
            source = (ROOT / variant['source_file']).read_text()
            assert variant['code'] == common + '\n' + source
            assert source.rstrip() in document
            checked += 1
    return f'PASS: {checked} listing/schema/source mirrors; no LMX parser involved'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write-report', action='store_true')
    args = parser.parse_args()
    named = json.loads((ROOT / 'tests/fixtures.json').read_text())
    cases = expand_cases(named)
    checks, skips = [], []
    versions = {}
    with tempfile.TemporaryDirectory(prefix='lmx-state-patterns-') as temp:
        tmp = Path(temp)
        commands = {kind: [] for kind in cases}
        if shutil.which('g++'):
            versions['C++'] = run(['g++', '--version']).splitlines()[0]
            for kind in cases:
                binary = tmp / kind
                run(['g++', '-std=c++17', '-O2', '-Wall', '-Wextra', '-pedantic',
                     str(ROOT / 'tests/adapters' / f'{kind}.cpp'), '-o', str(binary)])
                commands[kind].append(('C++', [str(binary)]))
        else:
            skips.append('C++: compiler unavailable')
        go_probe = (subprocess.run(['go', 'version'], text=True, capture_output=True, timeout=10)
                    if shutil.which('go') else None)
        if go_probe is not None and go_probe.returncode == 0 and go_probe.stdout.startswith('go version '):
            versions['Go'] = go_probe.stdout.strip()
            go_dir = tmp / 'go'
            go_dir.mkdir()
            shutil.copyfile(ROOT / 'examples/go/106_double_buffer.go', go_dir / 'example.go')
            shutil.copyfile(ROOT / 'tests/adapters/double_buffer.go', go_dir / 'main.go')
            binary = tmp / 'go_double_buffer'
            run(['go', 'build', '-o', str(binary), 'example.go', 'main.go'], cwd=go_dir,
                env=dict(os.environ, GO111MODULE='off'))
            commands['double_buffer'].append(('Go', [str(binary)]))
        else:
            skips.append('Go: compiler unavailable; a command named go does not establish that it is the Go toolchain')
        if shutil.which('node'):
            versions['JavaScript'] = run(['node', '--version']).strip()
            for kind in ['dirty_flag', 'fixed_timestep']:
                commands[kind].append(('JavaScript', ['node', str(ROOT / 'tests/adapters' / f'{kind}.mjs')]))
        else:
            skips.append('JavaScript: Node unavailable')
        for kind, rows in cases.items():
            payload = '\n'.join(encode(kind, row) for row in rows) + '\n'
            expected = [ORACLES[kind](row) for row in rows]
            for language, command in commands[kind]:
                actual = [json.loads(line) for line in run(command, input=payload).splitlines()]
                assert len(actual) == len(expected), (kind, language, len(actual), len(expected))
                for i, (got, want) in enumerate(zip(actual, expected)):
                    assert got == want, (kind, language, i, rows[i], got, want)
                checks.append(dict(pattern=kind, language=language, cases=len(rows),
                                   named_cases=len(named[kind]), result='PASS'))
    report = dict(
        date_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        status='PASS' if not skips else 'PARTIAL',
        commands='python3 tests/validate.py --write-report',
        runtime_versions=versions,
        checks=checks,
        lmx_parser='NOT_RUN: no LMX parser supplied in this documentation archive/environment',
        lmx_runtime='NOT_RUN: no LMX runtime supplied in this documentation archive/environment',
        listing_mirrors=check_listing_mirrors(),
        skipped=skips,
        metrics='DEFERRED: existing tables/PDF/XLSX not rebuilt; no size rankings asserted',
        seed=106107108,
        sources={str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in sorted((ROOT / 'examples').rglob('*')) if p.is_file()},
    )
    if args.write_report:
        (ROOT / 'tests/validation_results.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
        expected = {kind: [dict(row, expected=ORACLES[kind](row)) for row in rows]
                    for kind, rows in named.items()}
        (ROOT / 'tests/fixture_expectations.json').write_text(json.dumps(expected, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'sources'}, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()

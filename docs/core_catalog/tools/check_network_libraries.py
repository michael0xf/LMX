#!/usr/bin/env python3
"""Rebuild the retained network group offline; measure selected artifacts."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--project', type=Path, required=True)
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--cmake', default='cmake')
    p.add_argument('--report', type=Path)
    p.add_argument('--generator', default=None)
    p.add_argument('--make-program', default=None)
    a = p.parse_args()
    project, build = a.project.resolve(), a.build.resolve()
    group = project / 'third_party/lmx_c99_compact/extensions/network_extra'
    command = [a.cmake, '-S', str(group), '-B', str(build), '-DCMAKE_BUILD_TYPE=MinSizeRel']
    if a.generator:
        command += ['-G', a.generator]
    if a.make_program:
        command += ['-DCMAKE_MAKE_PROGRAM=' + a.make_program]
    subprocess.run(command, check=True)
    subprocess.run([a.cmake, '--build', str(build), '--parallel', '4'], check=True)
    cmake_path = Path(shutil.which(a.cmake) or a.cmake)
    ctest = cmake_path.with_name('ctest' + cmake_path.suffix)
    subprocess.run([str(ctest), '--test-dir', str(build), '--output-on-failure'], check=True)
    names = ['libcares.a', 'libevent_core.a', 'libevent_extra.a', 'libevent_pthreads.a']
    artifacts = []
    for name in names:
        matches = list(build.rglob(name))
        if not matches and name == 'libevent_pthreads.a':
            continue
        if len(matches) != 1:
            raise SystemExit(f'Expected one selected artifact {name}, got {len(matches)}')
        f = matches[0]
        artifacts.append({'path': f.relative_to(build).as_posix(), 'bytes': f.stat().st_size,
                          'sha256': hashlib.sha256(f.read_bytes()).hexdigest()})
    cares = next(x['bytes'] for x in artifacts if x['path'].endswith('libcares.a'))
    event = sum(x['bytes'] for x in artifacts if 'libevent_' in x['path'])
    example = build / 'lmx_mdns_size_probe'
    if not example.exists():
        example = example.with_suffix('.exe')
    if not example.exists():
        raise SystemExit('mDNS consumer size probe missing')
    if max(cares, event, example.stat().st_size) >= 1_000_000:
        raise SystemExit('Selected library/representative consumer exceeds 1,000,000 bytes')
    report = {'status': 'PASS', 'profile': 'C99 / MinSizeRel; actual compiler/platform follows local build',
              'network_traffic': 'No DNS queries or multicast packets sent by the smoke test',
              'artifacts': artifacts, 'cares_archive_bytes': cares, 'libevent_selected_archives_bytes': event,
              'mdns': {'kind': 'header_only', 'measurement': 'complete upstream example executable; dynamically linked system C library',
                       'bytes': example.stat().st_size, 'run': 'NOT_RUN'},
              'tests': ['DNS packet fields', 'event timer', 'buffer roundtrip', 'HTTP URI', 'mDNS name roundtrip'],
              'upstream_full_suites': 'NOT_RUN', 'cross_platform_builds': 'NOT_RUN'}
    if a.report:
        a.report.parent.mkdir(parents=True, exist_ok=True)
        a.report.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()

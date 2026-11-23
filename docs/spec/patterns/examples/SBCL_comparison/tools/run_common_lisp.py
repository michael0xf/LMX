#!/usr/bin/env python3
"""Run actual SBCL client assertions; no Python emulation is reported as SBCL."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys

sys.dont_write_bytecode = True
from build_common_lisp_tests import build

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sbcl', default=os.environ.get('SBCL', 'sbcl'))
    parser.add_argument('--sbcl-home', default=os.environ.get('SBCL_HOME'))
    args = parser.parse_args()
    assertions = build()
    output = ROOT / 'validation'
    output.mkdir(exist_ok=True)
    inputs = sorted((ROOT / 'source/common-lisp').glob('*.lisp')) + [ROOT / 'tools/test_common_lisp.lisp']
    report = dict(
        kind='actual Common Lisp execution',
        recorded_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        expected_assertions=assertions,
        source_sha256={str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs},
        command='sbcl --script tools/test_common_lisp.lisp',
        lmx_execution='NOT_RUN; this runner executes Common Lisp only',
    )
    executable = shutil.which(args.sbcl)
    if not executable:
        report.update(status='NOT_RUN', reason='SBCL executable not found', passed=0, failed=0)
        (output / 'common_lisp.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
        print('NOT_RUN: SBCL executable not found; install SBCL or supply --sbcl and --sbcl-home.')
        return 2
    environment = dict(os.environ)
    if args.sbcl_home:
        environment['SBCL_HOME'] = args.sbcl_home
    try:
        process = subprocess.run([executable, '--script', str(ROOT / 'tools/test_common_lisp.lisp')],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=environment, timeout=60)
        log = process.stdout
        match = re.search(r'^RESULT passed=(\d+) failed=(\d+)$', log, re.M)
        passed, failed = map(int, match.groups()) if match else (0, 0)
        runtime = re.search(r'^RUNTIME (.+)$', log, re.M)
        report.update(status='PASS' if process.returncode == 0 and failed == 0 and passed == assertions else 'FAIL',
            runtime=runtime.group(1) if runtime else 'unknown', passed=passed, failed=failed,
            exit_code=process.returncode, case_pass_counts={f'S{i:02}': len(re.findall(fr'^PASS S{i:02}\.\d+$', log, re.M)) for i in range(1, 25)})
    except subprocess.TimeoutExpired as error:
        log = (error.stdout or '')
        if isinstance(log, bytes):
            log = log.decode(errors='replace')
        report.update(status='FAIL', reason='SBCL process exceeded 60 seconds', passed=0, failed=0)
    (output / 'common_lisp.log').write_text(log)
    (output / 'common_lisp.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({key: report[key] for key in ['status', 'passed', 'failed', 'expected_assertions']}, ensure_ascii=False))
    return 0 if report['status'] == 'PASS' else 1

if __name__ == '__main__':
    raise SystemExit(main())

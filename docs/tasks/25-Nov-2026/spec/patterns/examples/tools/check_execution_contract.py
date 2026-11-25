#!/usr/bin/env python3
"""Check fixture startup metadata without executing or rewriting any source."""
from pathlib import Path
import hashlib
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'tools'))
from lmx_execution_contract import EXECUTION_CONTRACT, RUNNER_CONTRACT

CATALOGS = (
    'examples/expected_results.json',
    'examples/haskell_comparision/comparison_index.json',
    'examples/variants.json',
    'examples/julia_comparison/examples.json',
    'examples/perl_comparison/examples.json',
    'examples/SBCL_comparison/examples.json',
    '09_functional_computation/patterns.json',
)
ACCEPTANCE = (
    'examples/julia_comparison/validation/semantic_cases.json',
    'examples/perl_comparison/validation/lmx_acceptance_cases.json',
    'examples/SBCL_comparison/validation/lmx_acceptance_cases.json',
    'examples/validation/lazy_completeness_20261123.json',
    '09_functional_computation/acceptance_cases.json',
    '09_functional_computation/style_acceptance_cases.json',
)
COLLECTIONS = ('source_examples', 'additional_fixtures', 'comparison_programs',
               'examples', 'entries', 'patterns', 'records')


def main():
    checks = []
    documents = []

    def check(ok, label):
        checks.append({'check': label, 'passed': bool(ok)})

    for name in CATALOGS + ACCEPTANCE:
        path = ROOT/name
        check(path.is_file(), name+': fixture metadata exists')
        if not path.is_file():
            continue
        document = json.loads(path.read_text())
        documents.append({'path': name, 'sha256': hashlib.sha256(path.read_bytes()).hexdigest()})
        check(document.get('lmx_execution_contract') == EXECUTION_CONTRACT,
              name+': root L3 startup, no DATA or user arguments')
        check(document.get('lmx_runner_contract') == RUNNER_CONTRACT,
              name+': ordinary later operations, no alternative named startup')
        if 'runner_contract' in document:
            check(document['runner_contract'] == RUNNER_CONTRACT,
                  name+': legacy runner-contract field has the same meaning')
        collections = COLLECTIONS + (('cases',) if name in ACCEPTANCE else ())
        for collection in collections:
            for ordinal, row in enumerate(document.get(collection, [])):
                if not isinstance(row, dict):
                    continue
                label = name+': '+collection+'/'+str(row.get('id', ordinal))
                check(row.get('lmx_operation_phase') == 'after_root_startup',
                      label+': operation follows root startup')
                check('lmx_entry_point' not in row,
                      label+': no alternative LMX entry-point field')
                check('lmx' not in row.get('entry_points', {}),
                      label+': foreign entries are not LMX startup')
                if name in ACCEPTANCE:
                    check('entry_point' not in row,
                          label+': acceptance names an operation, not a program entry')

    failed = [item for item in checks if not item['passed']]
    report = {
        'status': 'PASS' if not failed else 'FAIL',
        'scope': 'Current fixture startup metadata; source and runtime behavior are not executed by this check.',
        'lmx_runtime': 'NOT_RUN',
        'documents': documents,
        'checks': len(checks),
        'failures': failed,
    }
    (ROOT/'examples/validation/execution_contract_checks.json').write_text(
        json.dumps(report, ensure_ascii=False, indent=2)+'\n')
    print(json.dumps({key: report[key] for key in ('status', 'checks', 'failures')},
                     ensure_ascii=False))
    return 1 if failed else 0


if __name__ == '__main__':
    raise SystemExit(main())

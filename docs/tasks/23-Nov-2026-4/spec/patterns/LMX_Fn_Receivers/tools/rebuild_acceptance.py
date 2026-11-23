"""Validate the permanent acceptance inventory against current chapter anchors.

The complete cases live in this JSON inventory; the integrated normative
chapter links to it. No deleted draft documents are regeneration inputs.
"""
from pathlib import Path
import json
import re

PACKAGE = Path(__file__).resolve().parents[1]
SPEC = PACKAGE.parents[1]
TARGET = PACKAGE / 'tests/uploaded_spec_acceptance.json'
COUNTS = {'types':58, 'sequences':82, 'patterns':41}
MODES = ('interpreter_interpreter', 'interpreter_native',
         'native_interpreter', 'native_native')


def main():
    old = json.loads(TARGET.read_text())
    current = (SPEC/'CORE_SEQUENCES_REGEX.en.md').read_text()
    output = {'scope': 'Permanent normative acceptance inventory linked to current integrated chapters; no execution',
              'runtime_executed': False, 'specifications': {}}
    for name, count in COUNTS.items():
        if f'<a id="{name}"></a>' not in current:
            raise ValueError('missing normative anchor '+name)
        cases = old['specifications'][name]['cases']
        if len(cases) != count:
            raise ValueError((name, 'original acceptance coverage changed',len(cases),count))
        ids = [x['id'] for x in cases]
        if len(ids) != len(set(ids)):
            raise ValueError((name, 'duplicate acceptance ID'))
        for case in cases:
            if not case['case'] or not case['expected']:
                raise ValueError((name, case['id'], 'missing observation'))
            if set(case['modes']) != set(MODES):
                raise ValueError((name, case['id'], 'missing runtime mode'))
        output['specifications'][name] = {'source':'../../../CORE_SEQUENCES_REGEX.en.md#'+name, 'cases': cases}
    TARGET.write_text(json.dumps(output, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({name: len(x['cases']) for name, x in output['specifications'].items()}))


if __name__ == '__main__':
    main()

"""Synchronize current root-spec acceptance tables. Never execute LMX."""
from pathlib import Path
import json
import re

PACKAGE = Path(__file__).resolve().parents[1]
ARCHIVE = PACKAGE.parents[2]
TARGET = PACKAGE / 'tests/uploaded_spec_acceptance.json'
SPECS = [
    'LMX_Array_Reference_Types_Core.ru.md',
    'LMX_Sequence_Operations.ru.md',
    'LMX_Regex_Operands.ru.md',
]
MODES = ('interpreter_interpreter', 'interpreter_native',
         'native_interpreter', 'native_native')


def main():
    old = json.loads(TARGET.read_text()) if TARGET.exists() else {'specifications': {}}
    output = {'scope': 'Normative acceptance from current root specs; source inventory, no execution',
              'runtime_executed': False, 'specifications': {}}
    for name in SPECS:
        cases = []
        for line in (ARCHIVE / name).read_text().splitlines():
            if not re.match(r'^\|\s*(?:[A-Z]\d{2}|\d{2,3})\s*\|', line):
                continue
            cells = [x.strip() for x in re.split(r'(?<!\\)\|', line.strip())[1:-1]]
            if len(cells) != 3:
                raise ValueError((name, 'expected three acceptance cells', line))
            ident, case, expected = cells
            cases.append({'id': ident, 'case': case, 'expected': expected,
                          'modes': {mode: 'NOT_RUN' for mode in MODES}})
        ids = [x['id'] for x in cases]
        if len(ids) != len(set(ids)):
            raise ValueError((name, 'duplicate acceptance ID'))
        earlier = {x['id'] for x in old['specifications'].get(name, {}).get('cases', [])}
        if not earlier.issubset(ids):
            raise ValueError((name, 'lost earlier acceptance IDs', sorted(earlier - set(ids))))
        output['specifications'][name] = {'source': '../../../../' + name, 'cases': cases}
    TARGET.write_text(json.dumps(output, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({name: len(x['cases']) for name, x in output['specifications'].items()}))


if __name__ == '__main__':
    main()

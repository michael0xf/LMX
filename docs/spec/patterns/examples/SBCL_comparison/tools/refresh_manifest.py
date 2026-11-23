#!/usr/bin/env python3
"""Record the exact local package and the external spec used for its extracts."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT.parents[2]


def main():
    references = {'CORE.md', 'LMX_semantics.en.md', 'LMX_grammar.en.md',
                  'LMX_semantics_guide.en.md', 'CORE_SEQUENCES_REGEX.en.md',
                  'L2_spec_en.md', 'patterns/MESSAGE_HTTP_PROFILE.md',
                  'patterns/LMX_Fn_Receivers/catalog.json',
                  'patterns/tools/throws_metrics.py',
                  'patterns/LMX_Fn_Receivers/src/coreStandardLisp.lmx',
                  'patterns/LMX_Fn_Receivers/CORE_STANDARD_LISP_ADDITIONS.json',
                  'patterns/LMX_Fn_Receivers/CORE_STANDARD_LISP.md',
                  'patterns/LMX_Fn_Receivers/tests/core_standard_lisp_cases.json'}
    data = json.loads((ROOT / 'implementation_data.json').read_text())
    for item in data['implementations']:
        references.update(row['source_spec_relative'] for row in item['production_definitions'])
    dependencies = json.loads((ROOT / 'validation/implementation_dependencies.json').read_text())
    references.update(row['source_spec_relative'] for row in dependencies['definitions'])
    expression = json.loads((ROOT / 'validation/expression_review.json').read_text())
    references.update(row['source_spec_relative'] for row in expression['asOperand']['dependencies'])
    records = [{'path_relative_to_spec': name, 'sha256': hashlib.sha256((SPEC / name).read_bytes()).hexdigest()}
               for name in sorted(references) if (SPEC / name).is_file()]
    (ROOT / 'BASE_REFERENCES.json').write_text(json.dumps({'edition': '2026-11-23', 'files': records,
        'note': 'External spec is read, never replaced by this directory.'}, ensure_ascii=False, indent=2) + '\n')
    rows = []
    for file in sorted(ROOT.rglob('*')):
        if file.is_file() and file.name != 'MANIFEST.sha256' and '__pycache__' not in file.parts:
            rows.append(f'{hashlib.sha256(file.read_bytes()).hexdigest()}  {file.relative_to(ROOT).as_posix()}')
    (ROOT / 'MANIFEST.sha256').write_text('\n'.join(rows) + '\n')
    print(json.dumps({'files': len(rows), 'external_spec_references': len(records)}))


if __name__ == '__main__':
    main()

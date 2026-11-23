#!/usr/bin/env python3
"""Publish the direct-core list from the same catalog used by kernel exports."""
from collections import defaultdict
import json
from pathlib import Path
import re

PACKAGE = Path(__file__).resolve().parents[1]
SPEC = PACKAGE.parents[1]


def family(row):
    src = row['source']
    if 'coreStandard' in src:
        suffix = Path(src).stem.removeprefix('coreStandard')
        return {'Functional':'Finite sequence and set conveniences', 'Objects':'Optional values, results and physical field lookup', 'Lisp':'Association lists, properties and operand adaptation', 'Text':'Sequence processing and explicit encoding profiles', 'Numeric':'Numeric reductions, selection and exact integers'}[suffix]
    if '/regex/' in src:
        return 'Patterns over typed sources'
    if 'corePerlExamples' in src or 'coreJuliaExamples' in src:
        return 'Stable ordering and distinct values'
    if 'coreComparisonExamples' in src:
        return 'Declared-form iteration and ordered ranges'
    if 'coreComparisonGroups' in src:
        return 'Selection, predicates, equality and Message retry'
    if 'sequence' in src or 'collections' in src:
        return 'Universal sequences'
    if 'containers' in src:
        return 'Value containers and trampoline'
    if 'reflection' in src or 'structures' in src:
        return 'Reflection and structure composition'
    return 'Callable construction, composition and lifetime'


def main():
    catalog = json.loads((PACKAGE/'catalog.json').read_text())
    names = [row['name'] for row in catalog]
    assert len(names) == len(set(names)), 'Duplicate public name'
    assert all(re.fullmatch(r'[a-z][A-Za-z0-9]*', n) for n in names), 'Public functions require lowerCamelCase'
    groups = defaultdict(list)
    for row in catalog:
        assert (PACKAGE/row['source']).is_file(), row['source']
        groups[family(row)].append(row)
    target = SPEC/'CORE_FUNCTIONS.md'
    current = target.read_text()
    inventory = current.index('## Function inventory')
    start = current.index('### ', inventory)
    end = current.index('## Integration and acceptance', start)
    lines = []
    for title, rows in groups.items():
        lines.extend(['### '+title, '', '| Function / operand | Contract | LMX source |', '| --- | --- | --- |'])
        for row in rows:
            signature=row['signature'].replace('|',r'\|')
            scope=row['scope'].replace('|',r'\|')
            links = '; '.join(f"{v['family']}: [{Path(v['source']).name}](patterns/LMX_Fn_Receivers/{v['source']})" for v in row['variants'])
            lines.append(f"| `{signature}` | {scope} | {links} |")
        lines.append('')
    # Normative prose is authored in the integrated specification. Regenerate
    # only the canonical tables; never replace those contracts with a template.
    target.write_text(current[:start]+'\n'.join(lines)+'\n'+current[end:],encoding='utf-8')
    print(json.dumps({'public_functions':len(catalog),'families':len(groups),'target':'CORE_FUNCTIONS.md'}))


if __name__=='__main__':main()

#!/usr/bin/env python3
"""Validate the authored core inventory without rewriting its contracts.

The historical command name is retained for publication scripts. Both the
default invocation and --check are read-only. CORE_FUNCTIONS.md contains
per-family contracts and explanatory prose which are more specific than the
catalogue's default scope; regenerating that section from catalog.json would
erase them. New or renamed operations therefore produce explicit diagnostics
until the authored inventory is reconciled. No rows, signatures or links are
silently replaced and no missing operation is assigned a guessed contract.

Use --spec PATH to validate an isolated copy of the complete specification.
This checks inventory coverage and source links, not LMX execution or the
semantic completeness of authored descriptions.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

from identifier_spelling import IDENT, decode

PACKAGE = Path(__file__).resolve().parents[1]
SPEC = PACKAGE.parents[1]
CODE_SPAN = re.compile(r'(`+)(.*?)\1(?!`)', re.S)
CALL_HEAD = re.compile(r'^(' + IDENT + r')\s*\(')
LOCAL_SOURCE = re.compile(r'\]\((patterns/LMX_Fn_Receivers/src/[^)#]+\.lmx)(?:#[^)]*)?\)')


def call_name(code):
    match = CALL_HEAD.match(code.strip())
    return decode(match[1]) if match else None


def validate(spec):
    library = spec / 'patterns/LMX_Fn_Receivers'
    target = spec / 'CORE_FUNCTIONS.md'
    original = target.read_bytes()
    text = original.decode('utf-8')
    catalog = json.loads((library / 'catalog.json').read_text())
    by_name = {row['name']: row for row in catalog}
    errors = []
    if len(by_name) != len(catalog):
        errors.append('Duplicate canonical operation in catalog.json')
    if not all(name == '->' or re.fullmatch(r'[a-z][A-Za-z0-9]*', name) for name in by_name):
        errors.append('Public names require lowerCamelCase or the canonical -> symbol')

    start_marker = '## Function inventory'
    end_marker = '## Integration and acceptance'
    if text.count(start_marker) != 1 or text.count(end_marker) != 1:
        raise ValueError('Expected one authored inventory and one integration section; no file was written')
    start = text.index(start_marker) + len(start_marker)
    end = text.index(end_marker, start)
    inventory = text[start:end]

    # Operand bodies can be linked separately from a receiver's source (then
    # is one example). Resolve actual declared owners instead of collapsing
    # such rows to the first semantic variant's implementation.
    owners = {}
    for path in sorted((library / 'src').rglob('*.lmx')):
        for owner in re.findall(r'(?m)^(?:independent:\s*)?([A-Za-z_]\w*)\s*(?:::|:(?!:))', path.read_text()):
            owners.setdefault(owner, set()).add(path.resolve())

    table_names = []
    prose_lines = []
    source_links = 0
    for line in inventory.splitlines():
        if not line.startswith('|'):
            prose_lines.append(line)
            continue
        cells = re.split(r'(?<!\\)\|', line)[1:-1]
        if not cells or cells[0].strip() in {'Function / operand', '---'}:
            continue
        if len(cells) != 3:
            errors.append('Unrecognized authored inventory row; review without rewriting: ' + line)
            continue
        span = CODE_SPAN.match(cells[0].strip())
        name = call_name(span[2]) if span else None
        if name not in by_name:
            errors.append('Unknown or retired operation in authored table: ' + repr(name))
            continue
        table_names.append(name)
        links = LOCAL_SOURCE.findall(cells[2])
        if not links:
            errors.append('Missing implementation source link for ' + name)
        linked_paths = set()
        for link in links:
            path = spec / link
            source_links += 1
            if not path.is_file():
                errors.append('Missing authored source link: ' + link)
            linked_paths.add(path.resolve())
        applicable = set()
        for variant in by_name[name]['variants']:
            applicable.add((library / variant['source']).resolve())
            for form in ('call', 'operand'):
                owner = variant[form]['target'].split('\\', 1)[0]
                applicable.update(owners.get(owner, ()))
        if links and not linked_paths.intersection(applicable):
            errors.append('Source links do not address a published receiver/operand body for ' + name)

    # Some operations are deliberately introduced in prose beside a family
    # table, including arrayView and element. Keep that authored presentation.
    prose_names = {name for span in CODE_SPAN.finditer('\n'.join(prose_lines))
                   if (name := call_name(span[2])) in by_name}
    covered = set(table_names) | prose_names
    missing = sorted(set(by_name) - covered)
    if missing:
        errors.append('Canonical operations need authored inventory entries: ' + ', '.join(missing))
    for row in catalog:
        for variant in row['variants']:
            if not (library / variant['source']).is_file():
                errors.append('Missing catalogue implementation source: ' + variant['source'])

    # A validation run has no write path. Check the bytes as well so a caller
    # can use the result as a preservation receipt for the reviewed document.
    unchanged = target.read_bytes() == original
    if not unchanged:
        errors.append('CORE_FUNCTIONS.md changed during validation')
    return {
        'mode': 'validate_authored_inventory',
        'target': 'CORE_FUNCTIONS.md',
        'public_functions': len(catalog),
        'authored_table_rows': len(table_names),
        'names_in_table': len(set(table_names)),
        'names_introduced_in_prose': sorted(prose_names - set(table_names)),
        'repeated_authored_names': {name: count for name, count in Counter(table_names).items() if count > 1},
        'source_links_checked': source_links,
        'document_sha256': hashlib.sha256(original).hexdigest(),
        'document_unchanged': unchanged,
        'files_written': [],
        'errors': errors,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--spec', type=Path, default=SPEC, help='specification root; defaults to this package')
    parser.add_argument('--check', action='store_true', help='explicit read-only mode (also the default)')
    args = parser.parse_args()
    try:
        result = validate(args.spec.resolve())
    except (ValueError, KeyError, OSError) as error:
        result = {'mode': 'validate_authored_inventory', 'files_written': [], 'errors': [str(error)]}
    print(json.dumps(result, ensure_ascii=False))
    raise SystemExit(bool(result['errors']))


if __name__ == '__main__':
    main()

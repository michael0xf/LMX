#!/usr/bin/env python3
"""Refresh source inventories after an intentional canonical contract change.

No LMX evaluation, alias creation or semantic inference is performed. Catalog
variants select the actual implementation; source hashes describe these files.
"""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]

def digest(text):
    return hashlib.sha256(text.encode()).hexdigest()

def count(text):
    return sum(not c.isspace() for c in text)

def main():
    catalog = json.loads((ROOT/'catalog.json').read_text())
    names = {row['name']:row for row in catalog}
    migration = json.loads((ROOT/'CANONICAL_MIGRATION.json').read_text())
    rename = {e['old']:e['new'] for e in migration['entries'] if e['old']!=e['new']}
    roots = {}
    for path in sorted((ROOT/'src').rglob('*.lmx')):
        text = path.read_text()
        starts = list(re.finditer(r'(?m)^(?:independent:\s*)?((?:Fx|Rx)\w+)\s*(?:::|:(?!:))', text))
        for i, match in enumerate(starts):
            body = text[match.start():starts[i+1].start() if i+1<len(starts) else len(text)]
            body = re.split(r'\n[ \t]*\n', body, 1)[0].strip()+'\n'
            roots[match[1]] = (path.relative_to(ROOT).as_posix(), body)

    def source_fields(entry, variant):
        owner = variant['api'].split('\\')[0]
        source, text = roots[owner]
        entry.update(api=variant['api'], source=Path(source).stem,
                     source_file=source, definition=owner,
                     characters=count(text), sha256=digest(text))
        entry['family'] = variant['family']
        entry['call'] = variant['call']
        entry['operand'] = variant['operand']
        entry['implementation_contract'] = variant['implementation_contract']

    updated = []
    for path in sorted(ROOT.glob('*ADDITIONS*.json')):
        data = json.loads(path.read_text())
        for entry in data.get('entries', []):
            # pipe's name is deliberately reused for value application; its
            # former composition-building entry follows its original API.
            old = entry['name']
            name = rename.get(old, old)
            if old == 'pipe' and entry.get('api', '').startswith('FxPipe\\'):
                name = 'pipe'
            row = names[name]
            variants = row['variants']
            variant = next((v for v in variants if v['api']==entry.get('api')), None)
            if variant is None and entry.get('api')=='FxJoin\\join':
                variant = next(v for v in variants if v['family']=='text')
            if variant is None and old=='repeatText':
                variant = next(v for v in variants if v['family']=='text')
            if variant is None:
                variant = variants[0]
            entry['name'] = name
            source_fields(entry, variant)
            entry['arguments'] = row['signature'].split('(',1)[1].rsplit(')',1)[0] if '(' in row['signature'] else row['signature']
            entry['scope'] = row['scope']
            if old=='repeatText':
                entry['arguments'] = 'items; count; rejectNegative=1'
                entry['scope'] += '; the former rejecting count profile passes rejectNegative=1 explicitly'
            entry['runtime_status'] = 'NOT_RUN'
        for entry in data.get('support_definitions', []):
            source, text = roots[entry['definition']]
            entry.update(source_file=source, characters=count(text), sha256=digest(text))
        if 'source' in data and (ROOT/data['source']).is_file():
            source = (ROOT/data['source']).read_text()
            data['source_sha256'] = digest(source)
            if 'complete_source_nonwhitespace_characters' in data:
                data['complete_source_nonwhitespace_characters'] = count(source)
        if 'definitions_nonwhitespace_characters' in data:
            data['definitions_nonwhitespace_characters'] = sum(e['characters'] for e in data.get('entries',[])+data.get('support_definitions',[]))
        data['canonical_inventory'] = 'catalog.json'
        data['canonical_migration'] = 'CANONICAL_MIGRATION.json'
        data['runtime_executed'] = False
        path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
        updated.append(path.name)
    print(json.dumps({'updated':updated,'runtime_executed':False}))

if __name__ == '__main__':
    main()

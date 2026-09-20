"""Render paired semantic chapters and retain an auditable copy of both sources."""
from pathlib import Path
import hashlib
import json
import re
import difflib
import argparse

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATHS = {
    'l1': ROOT.parent / 'L1' / 'Lingvamyxa_spec.txt',
    'older': ROOT.parent / 'lingvamyxa' / 'Lingvamyxa_spec.txt',
}
ALIASES = {'fields': 'references', 'callables': 'execution',
           'dynamic': 'publication', 'delivery': 'addressing'}

def build(check=False):
    sources = {}
    inventory = {}
    archive = ROOT / 'provenance' / 'semantics-sources'
    if not check:
        archive.mkdir(exist_ok=True)
    inventory_path = ROOT / 'provenance' / 'semantics-inventory.json'
    saved = json.loads(inventory_path.read_text(encoding='utf-8')) if check else None
    for key, path in SOURCE_PATHS.items():
        snapshot = archive / f'{key}.txt'
        raw = path.read_bytes() if path.is_file() else snapshot.read_bytes()
        if snapshot.exists() and snapshot.read_bytes() != raw:
            raise RuntimeError(f'Source changed; review before replacing snapshot: {path}')
        if check:
            assert snapshot.is_file(), f'Missing source snapshot: {snapshot}'
            assert hashlib.sha256(raw).hexdigest() == saved[key]['sha256'], key
        else:
            snapshot.write_bytes(raw)
        sources[key] = raw.decode('utf-8-sig').splitlines()
        inventory[key] = {'path': saved[key]['path'] if check else str(path),
                          'sha256': hashlib.sha256(raw).hexdigest(),
                          'lines': len(sources[key]), 'snapshot': snapshot.relative_to(ROOT).as_posix()}

    text = (ROOT / 'provenance' / 'semantics-book.md').read_text(encoding='utf-8')
    parts = re.split(r'^@@ (.+)$', text, flags=re.M)
    chapters = []
    for i in range(1, len(parts), 2):
        ident, title_ru, title_en, origin = [x.strip() for x in parts[i].split('|')]
        body = parts[i + 1]
        assert body.startswith('\n[RU]\n') and '\n[EN]\n' in body, ident
        ru, en = body[6:].split('\n[EN]\n', 1)
        chapters.append({'id': ident, 'ru': ru.strip(), 'en': en.strip(),
                         'title_ru': title_ru, 'title_en': title_en, 'origin': origin})
    assert chapters, 'No semantic chapters'
    assert len({x['id'] for x in chapters}) == len(chapters)

    def excerpt(match):
        key, a, b = match.group(1), int(match.group(2)), int(match.group(3))
        assert 1 <= a <= b <= len(sources[key])
        return '```text\n' + '\n'.join(sources[key][a-1:b]) + '\n```'

    def body_text(c, lang):
        body = re.sub(r'\{\{(l1|older):(\d+)-(\d+)\}\}', excerpt, c[lang])
        assert '{{' not in body, f'Unexpanded source excerpt in {c["id"]}'
        if c['id'] == 'admission-recipes':
            nums = re.findall(r'^### (\d+)\.', body, re.M)
            assert nums == [str(n) for n in range(1, 15)], 'All 14 implements cases required'
            body = re.sub(r'^### (\d+)\.',
                          lambda m: f'<a id="admission-case-{m[1]}"></a>\n### {m[1]}.',
                          body, flags=re.M)
        return body

    for c in chapters:
        ru, en = body_text(c, 'ru'), body_text(c, 'en')
        assert len(ru.split('\n\n')) == len(en.split('\n\n')), f'Paragraph mismatch: {c["id"]}'
        assert re.findall(r'(?ms)^```.*?^```', ru) == re.findall(r'(?ms)^```.*?^```', en), f'Code mismatch: {c["id"]}'
        assert re.findall(r'^#+ ', ru, re.M) == re.findall(r'^#+ ', en, re.M), f'Heading mismatch: {c["id"]}'
        assert re.findall(r'<a id="([^"]+)"', ru) == re.findall(r'<a id="([^"]+)"', en), f'Anchor mismatch: {c["id"]}'
        def links(body):
            return [re.sub(r'([._])(ru|en)(?=\.md)', r'\1LANG', x)
                    for x in re.findall(r'\]\(([^)]+)\)', body)]
        for lang, body in (('ru', ru), ('en', en)):
            opposite = 'en' if lang == 'ru' else 'ru'
            assert not re.search(rf'\]\([^)]*[._]{opposite}\.md', body), f'Wrong-language link: {c["id"]}/{lang}'
        assert links(ru) == links(en), f'Link mismatch: {c["id"]}'

    for lang in ('ru', 'en'):
        path = ROOT / 'docs' / f'LMX_semantics.{lang}.md'
        opening = path.read_text(encoding='utf-8').split('<!-- semantics-toc -->', 1)[0]
        opening = opening.split('<a id="scope">', 1)[0].rstrip()
        toc = '\n'.join(f'- [{n}. {c[f"title_{lang}"]}](#{c["id"]})'
                        for n, c in enumerate(chapters, 1))
        output = [opening, '<!-- semantics-toc -->\n\n' + toc]
        for n, c in enumerate(chapters, 1):
            body = body_text(c, lang)
            alias = f'<a id="{ALIASES[c["id"]]}"></a>\n' if c['id'] in ALIASES else ''
            output.append(f'{alias}<a id="{c["id"]}"></a>\n## {n}. {c[f"title_{lang}"]}\n\n{body}')
        result = '\n\n'.join(output) + '\n'
        anchors = re.findall(r'<a id="([^"]+)"', result)
        assert len(anchors) == len(set(anchors)), f'Duplicate anchor: {path}'
        if check:
            assert path.read_text(encoding='utf-8') == result, f'Out of sync: {path}'
        else:
            path.write_text(result, encoding='utf-8')

    inventory['chapters'] = [{'id': c['id'], 'source_sections': c['origin']} for c in chapters]
    inventory['source_examples'] = [
        {'chapter': c['id'], 'source': key, 'start': int(a), 'end': int(b)}
        for c in chapters
        for key, a, b in re.findall(r'\{\{(l1|older):(\d+)-(\d+)\}\}', c['ru'])
    ]
    inventory['older_differences'] = [
        {'operation': tag, 'older_lines': [i+1,j], 'l1_lines': [k+1,l],
         'older_text': '\n'.join(sources['older'][i:j]),
         'l1_text': '\n'.join(sources['l1'][k:l])}
        for tag,i,j,k,l in difflib.SequenceMatcher(None, sources['older'], sources['l1'], autojunk=False).get_opcodes()
        if tag != 'equal'
    ]
    if check:
        assert inventory == saved, 'Semantic provenance inventory is out of sync'
    else:
        inventory_path.write_text(json.dumps(inventory, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    return len(chapters)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Verify without writing files')
    args = parser.parse_args()
    count = build(check=args.check)
    print(f'{"Verified" if args.check else "Rendered"} {count} paired semantic chapters, 14 implements cases and both verbatim source snapshots.')

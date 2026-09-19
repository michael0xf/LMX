"""Check paired grammar, preserved source examples, links, and imported bytes."""
from pathlib import Path
import hashlib
import json
import re
from build_docs import render

ROOT=Path(__file__).resolve().parents[1]

def main():
    data=json.loads((ROOT/'provenance/grammar.json').read_text(encoding='utf-8'))
    for lang in ('ru','en'):
        path=ROOT/'docs'/f'grammar.{lang}.md'
        assert path.read_text(encoding='utf-8')==render(data,lang),f'Out of sync: {path}'
    ids=[s['id'] for s in data['sections']]
    assert len(ids)==len(set(ids))
    source=Path(data['source']['path'])
    lines=None
    if source.is_file():
        assert hashlib.sha256(source.read_bytes()).hexdigest()==data['source']['sha256'],'Source changed since extraction'
        lines=source.read_text(encoding='utf-8-sig').splitlines()
    count=0
    for number,s in enumerate(data['sections'],1):
        assert s['number']==number
        for lang in ('ru','en'):
            assert s[lang]['title'].strip() and s[lang]['text'].strip()
        for e in s['examples']:
            assert e['text'].strip(),f'Empty excerpt: {e}'
            assert '````' not in e['text'],'Fence collision'
            if 'start' in e:
                count+=1
                if lines is not None:
                    assert e['text']=='\n'.join(lines[e['start']-1:e['end']]),f'Altered source excerpt {e["start"]}'
    ru=(ROOT/'docs/semantics.ru.md').read_text(encoding='utf-8').split('\n\n')
    expected=[
        '**Lingvamyxa (далее LMX) — язык, в котором программа — лексический лес примитивных массивов, связанный в динамический граф.** Эта организация самоподобно повторяется на уровне локальных акторов с физической адресацией в памяти и далее — на уровне дальних межмашинных сообщений с комплексной адресацией.',
        '**И данные, и исполняемые тела являются массивами**, представленными одними и теми же простыми универсальными структурами; каждое исполняемое тело — полноценное абстрактное выражение.',
        '**Типизация аналитическая, на уровне лексических ветвей.** Допуск любого кандидата в аргументы любого выражения требует аналитической проверки совместимости и обязательной рантайм-валидации юнит-тестами, заданными принимающим выражением. Протестированные кандидаты и проверяющие выражения однозначно идентифицируются своими физическими адресами.'
    ]
    assert ru[:3]==expected,'Author opening changed'
    assert len((ROOT/'docs/semantics.en.md').read_text(encoding='utf-8').split('\n\n'))==len(ru),'Semantic paragraph counts differ between RU/EN'
    inventory=json.loads((ROOT/'provenance/parser-tests.json').read_text(encoding='utf-8'))
    files=inventory['files']
    for f in files:
        raw=(ROOT/f['path']).read_bytes()
        assert len(raw)==f['bytes'] and hashlib.sha256(raw).hexdigest()==f['sha256'],f'Altered imported file {f["path"]}'
        for origin in f['origins']:
            p=Path(origin['root'])/origin['path']
            if p.is_file():
                assert p.read_bytes()==raw,f'Source no longer matches imported snapshot: {p}'
    for source in inventory['sources']:
        base=Path(source['root'])
        if not base.is_dir():continue
        represented={o['path'] for f in files for o in f['origins'] if o['stage']==source['stage']}
        for p in (base/'tests').rglob('*.lmx'):
            assert p.relative_to(base).as_posix() in represented,f'Missing parser input {p}'
    # Check only authored documentation; historical fixture links belong to their source trees.
    docs=[*ROOT.glob('README*.md'),*ROOT.glob('docs/*.md'),*ROOT.glob('tests/parser/README*.md')]
    for path in docs:
        text=path.read_text(encoding='utf-8')
        text=re.sub(r'(?ms)^(`{3,}).*?^\1\s*$','',text)
        for target in re.findall(r'\]\(([^)]+)\)',text):
            if '://' in target:continue
            file,_,anchor=target.partition('#')
            dest=(path.parent/file).resolve() if file else path
            assert dest.exists(),f'Broken link in {path}: {target}'
            if anchor:
                assert f'id="{anchor}"' in dest.read_text(encoding='utf-8'),f'Missing anchor {target}'
    print(f'OK: {len(ids)} paired grammar sections, {count} verbatim source excerpts, {len(files)} imported files, links, exact semantic opening')

if __name__=='__main__':main()

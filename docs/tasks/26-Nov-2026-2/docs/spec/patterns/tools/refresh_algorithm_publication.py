#!/usr/bin/env python3
"""Refresh existing group10/11 code mirrors and full-size tables in place.

Keep authored contracts, comparisons and common source blocks. A common body
is counted once per complete variant but is not pasted twice into the page.
No LMX or foreign source file is written.
"""
from pathlib import Path
import argparse,json,re
from lmx_style_variants import get_variants,normalize,measure,read_variant,validate_variants

ROOT=Path(__file__).resolve().parents[1]
FENCE=re.compile(r'^```lmx\n(.*?)^```[ \t]*$',re.M|re.S)
STALE='Метрики и победители сейчас не объявляются: пользователь явно отложил пересчёт.'


def source_paths(record,directory,text):
    refs=set(re.findall(r'\]\(([^)#]+\.(?:lm3|lm2|lm1|lmx))(?:#[^)]*)?\)',text))
    for _,variant in get_variants(record):
        for key in ('source_files','common_sources','closure_sources'):
            refs.update(variant.get(key,[]))
        for key in ('source_file','entry_source_file','source'):
            if variant.get(key):refs.add(variant[key])
    return {ref:normalize((directory/ref).read_text()) for ref in refs
            if (directory/ref).is_file() and Path(ref).suffix in {'.lm3','.lm2','.lm1','.lmx'}}


def first_head(text):
    return next((line.strip() for line in text.splitlines() if line.strip() and not line.lstrip().startswith('#')),'')


def refresh(record,directory):
    path=directory/(record.get('comparison_file') or record['source'])
    before=path.read_text();text=before;sources=source_paths(record,directory,text)
    errors=validate_variants(record,directory)
    if errors:raise ValueError((path,errors))
    for _,variant in get_variants(record):
        if normalize(variant['code'])!=read_variant(variant,directory):
            raise ValueError(f'{path}: source/JSON closure differs')
    replacements=[]
    for match in FENCE.finditer(text):
        code=normalize(match[1])
        if code in sources.values():continue
        headings=re.findall(r'^##\s+(.+)$',text[:match.start()],re.M)
        heading=headings[-1] if headings else ''
        style='procedural' if 'процедурный' in heading else 'functional' if 'функциональный' in heading else None
        selected=None
        if style:
            variant=record['lmx_variants'][style]
            ref=variant.get('entry_source_file') or variant.get('source') or variant['source_file']
            selected=sources.get(ref)
        if selected is None:
            candidates={value for value in sources.values() if first_head(value)==first_head(code)}
            if len(candidates)==1:selected=candidates.pop()
        if selected is None:
            raise ValueError(f'{path}: cannot safely match LMX fence beginning {first_head(code)!r}')
        replacements.append((match.start(1),match.end(1),selected))
    for start,end,replacement in reversed(replacements):text=text[:start]+replacement+text[end:]
    # An obsolete empty table and its old deferral statement must not contradict
    # the newly measured complete-source table on the same current page.
    text=re.sub(r'\| Вариант \| Граница \| Символы / строки \| Исполнение \|\n\| --- \| --- \| --- \| --- \|\n\s*','',text)
    text=re.sub(re.escape(STALE)+r'[^\n]*',
                'Полные размеры обеих LMX-форм пересчитаны по текущим исходникам и приведены ниже. '
                'Общие части входят в каждую использующую их границу ровно один раз; все объявления и Throws сохранены.',text)
    text=re.sub(r'## Статистика\n\s*(?=## Проверка)', '', text)
    variants=[('LMX — процедурный',record['lmx_variants']['procedural']['code']),
              ('LMX — функциональный',record['lmx_variants']['functional']['code'])]
    variants += [(item['language'],item['code']) for item in record['listings'] if item['language']!='LMX']
    measured=[(name,measure(code)) for name,code in variants];minimum=min(m['characters'] for _,m in measured)
    lines=['## Размер полного исходника','','| Запись | Непробельные символы | Непустые строки |','| --- | ---: | ---: |']
    for name,m in measured:
        count=str(m['characters'])
        if m['characters']==minimum:count=f'<span style="color:#176233"><u>{count}</u></span>'
        lines.append(f"| {name} | {count} | {m['nonblank_lines']} |")
    lines += ['', 'Для каждой LMX-формы считаются все её source_files, включая общие определения ровно один раз. '
              'Все объявления и Throws входят в размер. Зелёным подчёркнут минимум полного сопоставимого листинга; '
              'равные минимумы выделены вместе.', '']
    section='\n'.join(lines)
    if re.search(r'^## Размер полного исходника\s*$',text,re.M):
        text=re.sub(r'^## Размер полного исходника\n.*?(?=^## |\Z)',lambda _:section,text,flags=re.M|re.S)
    else:text=text.rstrip()+'\n\n'+section
    return path,before,text,{'id':record['id'],'source_blocks_refreshed':len(replacements),
                           'full_characters':{name:m['characters'] for name,m in measured}}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write',action='store_true')
    parser.add_argument('--report',type=Path)
    args=parser.parse_args();rows=[];changed=[]
    for group in ('10_algorithms','11_state_and_simulation_patterns'):
        directory=ROOT/group;data=json.loads((directory/'patterns.json').read_text())
        for record in data['patterns']:
            path,before,after,detail=refresh(record,directory)
            rows.append({'file':path.relative_to(ROOT).as_posix(),**detail})
            if before!=after:
                changed.append(path.relative_to(ROOT).as_posix())
                if args.write:path.write_text(after)
    result={'mode':'SOURCE_MIRRORS_AND_FULL_METRICS_NOT_RUNTIME','write':args.write,'changed':changed,'records':rows}
    if args.report:args.report.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'write':args.write,'changed_files':len(changed),'records':len(rows)},ensure_ascii=False))


if __name__=='__main__':main()

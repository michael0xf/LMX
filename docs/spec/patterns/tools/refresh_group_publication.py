#!/usr/bin/env python3
"""Regenerate groups01--08 from their current JSON; no old-archive migration.

Only source/Markdown/catalog mirrors are written. Statistics/PDF/XLSX have their
own generators. Tiny syntax alternatives remain prose, not duplicate code.
"""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[1]
LANG={'LMX':('lmx','lm3','lmx'),'Java':('java','java','java'),'Go':('go','go','go'),'Python':('python','py','python'),'C#':('csharp','cs','csharp'),'Erlang':('erlang','erl','erlang'),'Rust':('rust','rs','rust'),'TypeScript':('typescript','ts','typescript')}
def order(p):return(p.get('paired_with',p['id']),p.get('kind')=='implementation',p['id'])
def metric(code):return(sum(not c.isspace() for c in code),sum(bool(x.strip()) for x in code.splitlines()))
def link(p):return f"{p['id']:03d}_{p['slug']}_comparision.md"
def related(p,by,lang):
 ids=p.get('usage_ids',[]) if p.get('kind')=='implementation' else p.get('implementation_ids',[])
 if not ids:return ''
 title=('Примеры использования' if p.get('kind')=='implementation' else 'Отдельное сравнение реализации') if lang=='ru' else ('Usage examples' if p.get('kind')=='implementation' else 'Separate implementation comparison')
 return '**'+title+':** '+', '.join(f"[{i:03d}. {by[i]['name']}]({link(by[i])})" for i in ids)
def main():
 count=0
 for f in sorted(ROOT.glob('0[1-8]_*/patterns.json')):
  group=json.loads(f.read_text());directory=f.parent;by={p['id']:p for p in group['patterns']}
  rows=[]
  for p in sorted(group['patterns'],key=order):
   scope='Реализация библиотеки' if p.get('kind')=='implementation' else 'Использование библиотеки' if p.get('implementation_ids') else {'core':'Ядро сценария','protocol':'Протокол и порты','executable':'Самостоятельный пример'}.get(p['scope'],p['scope'])
   out=[f"# {p['id']:03d}. {p['name']}",p['summary_ru'],related(p,by,'ru'),'## Общий сценарий',p['scenario_ru'],'**Ожидаемое наблюдение:** '+p['expected_ru'],'**Граница сравнения:** '+scope+'. '+p['limits_ru']]
   if p.get('implementation_ids'):
    if p.get('comparison_level')=='shared_implementation_client':
     out+=['Все клиенты этой узкой пары используют полностью показанный общий компонент из связанной строки реализации. Он учитывается один раз отдельно; асинхронный библиотечный клиент имеет собственный договор.']
    else:
     out+=['LMX использует существующие средства ядра или явно названную компактную группу, определённую в связанном сравнении реализации. Иностранные клиенты используют настоящие средства языка или установленную библиотеку.']
   if p.get('kind')=='implementation':
    shared=any(by[i].get('comparison_level')=='shared_implementation_client' for i in p.get('usage_ids',[]) if i in by)
    out+=['Это полная общая реализация для связанных клиентов всех трёх языков; её стоимость считается один раз отдельно и в суммарной цене компонента.' if shared else 'Это самостоятельное сравнение реализаций. Весь показанный код считается здесь; связанные иностранные клиенты используют настоящие библиотечные средства. Общие runtime-примитивы и их границы перечислены отдельно.']
   sizes=[]
   if p.get('comparison_level')=='shared_implementation_client':scope='Клиент общего компонента'
   for l in p['listings']:
    code=l['code'].strip()+'\n';folder,ext,fence=LANG[l['language']]
    source=f"examples/{folder}/{p['id']:03d}_{p['slug']}.{ext}"
    (directory/source).parent.mkdir(parents=True,exist_ok=True);(directory/source).write_text(code)
    out += ['## '+l['language'],f'```{fence}\n{code}```',l.get('notes_ru',''),f'[Отдельный листинг]({source})']
    sizes.append(metric(code))
   out += ['## Разбор LMX',p['lmx_notes_ru'],'## Сопоставление',p['comparison_ru']]
   if p.get('extended_comparison'):out+=['## Отдельный расширенный договор','[Обобщённая или асинхронная пара 23-Nov]('+p['extended_comparison']+'). Она сохраняется отдельно и не включается в размер этой основной строки.']
   if p.get('minor_alternatives_note_ru'):out += ['### Небольшие варианты записи',p['minor_alternatives_note_ru']]
   if p.get('post_scope_note_ru'):out += ['### Асинхронная граница',p['post_scope_note_ru']]
   out += ['## Объём показанного исходника','| Язык | Непробельные символы | Непустые строки |\n| --- | ---: | ---: |\n'+'\n'.join(f"| {l['language']} | {m[0]} | {m[1]} |" for l,m in zip(p['listings'],sizes)),'Подсчёт включает весь показанный код и комментарии; исключаются только пробельные символы. Это размер листинга, не скорость или размер полной системы. [Методика](../COMPARISON_METHODOLOGY.ru.md).','Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основные размеры и отношения сохраняют весь текст. Все объявления, аргументы и ссылки на общий банк ошибок учитываются целиком.','## English explanation',p['summary_en'],related(p,by,'en'),'**Scenario.** '+p['scenario_en'],'**Expected observation.** '+p['expected_en'],'**LMX.** '+p['lmx_notes_en'],'**Comparison.** '+p['comparison_en'],'**Scope and limitations.** '+p['limits_en']]
   if p.get('post_scope_note_en'):out += [p['post_scope_note_en']]
   out += ['### Dependencies and execution boundaries','\n'.join('- **'+l['language']+':** '+l.get('notes_en','') for l in p['listings']),'## Источники / Sources','\n'.join(f"- [{s['title']}]({s['url']}) — {s.get('why_ru',s.get('note_ru','Официальный контракт.'))}" for s in p['sources']),'**Норма LMX:** [CORE](../../CORE.md), [семантика](../../LMX_semantics.en.md), [guide](../../LMX_semantics_guide.en.md).','## Проверка','Runtime LMX отсутствует в документационном архиве; его выполнение не заявляется. Применимые отдельные проверки контрольных языков и исходников отмечены в [общем отчёте](../VALIDATION.md).']
   (directory/link(p)).write_text('\n\n'.join(x for x in out if x)+'\n')
   rows.append('| '+f"{p['id']:03d}"+' | '+f"[{p['name']}]({link(p)})"+' | '+' | '.join(f'{m[0]} / {m[1]}' for m in sizes)+' | '+scope+' |')
   count+=1
  # Catalog prose is generated from the same semantic records, without code.
  for lang in ['ru','en']:
   title=group['group_title_'+lang]
   text=[f'# LMX: {title}',group['rationale_'+lang],group['overview_'+lang],'## '+('Файлы' if lang=='ru' else 'Files'),'\n'.join(f'- [{label}](LMX_Comparison_{directory.name}.{ext})' for label,ext in [('Markdown','md'),('Excel','xlsx'),('PDF','pdf'),('CSV','csv')]),'## '+('Каталог' if lang=='ru' else 'Catalog')]
   for p in sorted(group['patterns'],key=order):
    text += [f"### {p['id']:03d}. [{p['name']}]({link(p)})",p['summary_'+lang],related(p,by,lang),('**Сценарий:** ' if lang=='ru' else '**Scenario:** ')+p['scenario_'+lang],('**Наблюдение:** ' if lang=='ru' else '**Observation:** ')+p['expected_'+lang],p['comparison_'+lang]]
   (directory/f'LMX_Design_Patterns.{lang}.md').write_text('\n\n'.join(x for x in text if x)+'\n')
  cmp=directory/f'LMX_Comparison_{directory.name}.md'
  lines=cmp.read_text().splitlines();positions=[i for i,l in enumerate(lines) if re.match(r'^\|\s*\d+\s*\|',l)]
  assert len(positions)==len(rows),(directory,len(positions),len(rows))
  for pos,row in zip(positions,rows):lines[pos]=row
  header=next((i for i,l in enumerate(lines) if l.startswith('| ID |')),None)
  if header is not None:
   lines[header]='| ID | Паттерн | LMX | '+' | '.join(group['languages'])+' | Граница |'
   lines[header+1]='| ---: | --- | ---: | ---: | ---: | --- |'
  cmp.write_text('\n'.join(lines).replace('Дата редакции: 2026-11-22','Дата редакции: 2026-11-23')+'\n')
  readme=directory/'README.md';s=readme.read_text()
  if '## Редакция 23 ноября 2026' not in s:
   s+='\n## Редакция 23 ноября 2026\n\nИностранные clients используют реальные библиотечные средства. Самостоятельные реализации сохранены как отдельные сравнения с ядром LMX. Местные изменения аргументов/return/leaf-вызовов не дублируются целыми листингами. [Реестр этой проверки](../validation/group_library_revision_20261123.json).\n'
   readme.write_text(s)
 # This sole auxiliary file differed only by the same leaf read expression.
 redundant=ROOT/'07_state_coordination/examples/lmx/070_monitor_object_direct_expression.lm3'
 if redundant.exists():redundant.unlink()
 print(json.dumps({'groups':8,'comparison_records':count,'source_mirrors':count*3}))
if __name__=='__main__':
 main()
 from full_source_tables import clean_paths
 clean_paths(path for group in ROOT.glob('0[1-8]_*') for path in group.rglob('*') if path.is_file() and path.suffix in {'.md','.csv'})

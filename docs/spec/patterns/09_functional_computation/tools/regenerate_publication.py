#!/usr/bin/env python3
"""Publish core/real-library usage, paired implementations and real alternatives."""
from pathlib import Path
import csv,json
ROOT=Path(__file__).resolve().parents[1]
import sys
sys.path.insert(0,str(ROOT.parent/'tools'))
from throws_metrics import measure_throws
LANG={'LMX':('lmx','lm3','lmx'),'Haskell':('haskell','hs','haskell'),'Scala':('scala','scala','scala')}
LABEL={'shared_body':'общий алгоритм шага','core_curry':'поэтапный curry','core':'прямой API ядра','local_callbacks':'процедурная композиция с локальным Around','standard':'готовое средство языка/библиотеки','implementation':'самостоятельная реализация'}
def canon(s): return s.strip()+'\n'
def count(s): return sum(not c.isspace() for c in s),sum(bool(x.strip()) for x in s.splitlines())
def supplemental(s):return measure_throws(canon(s),ROOT.parent)['without_complex_throws_characters']
def stem(p): return f"{p['id']:03d}_{p['slug']}"
def link(p): return f"[{p['id']:03d}. {p['name']}]({stem(p)}_comparision.md)"
def variant_path(p,lang,v):
 folder,ext,_=LANG[lang]
 return f'examples/{folder}/{stem(p)}.{ext}' if v==p['primary_variant'][lang] else f'examples/{folder}/variants/{stem(p)}_{v}.{ext}'
def refs(p,idx):
 if p.get('implementation_ids'):return '**Сравнения реализаций:** '+', '.join(link(idx[n]) for n in p['implementation_ids'])+'. Это ссылки для чтения, не импорты самописных модулей в контрольные usage-клиенты.'
 if p.get('usage_ids'):return '**Клиенты готовых средств:** '+', '.join(link(idx[n]) for n in p['usage_ids'])+'. Они не подключают показанные здесь foreign-реализации.'
 return ''
def render_pattern(p,idx):
 impl=p.get('kind')=='implementation'
 lines=[f"# {p['id']:03d}. {p['name']}",p['summary_ru'],refs(p,idx),'## Общий сценарий',p['scenario_ru'],'**Ожидаемое наблюдение:** '+p['expected_ru'],
 '**Граница сравнения.** '+('Полные реализации заявленного компонента сопоставлены отдельно от его использования. Они не заявляются исходниками всего пакета стандартной библиотеки.' if impl else 'LMX вызывает непосредственные операции текущего ядра; контрольные языки используют настоящую библиотеку или собственные средства языка. Самописные аналоги из соседних сравнений сюда не импортируются.')]
 if p.get('foreign_facilities'):
  lines+=['| Язык | Используемое средство |\n| --- | --- |\n'+'\n'.join('| '+k+' | `'+v+'` |' for k,v in p['foreign_facilities'].items())]
 for l in p['listings']:
  lang=l['language'];folder,ext,tag=LANG[lang];v=p['primary_variant'][lang]
  lines+=['## '+lang+' — '+LABEL.get(v,v),'```'+tag+'\n'+canon(l['code'])+'```',l.get('notes_ru',''),'[Исходник]('+variant_path(p,lang,v)+')']
 for lang,variants in p['variants'].items():
  for v,code in variants.items():
   if v==p['primary_variant'][lang]:continue
   _,_,tag=LANG[lang]
   reason=p.get('retained_variant_reasons',{}).get(lang,{}).get(v,'Отдельный подход; не суммируется с основным.')
   lines+=['## '+lang+' — другой подход: '+LABEL.get(v,v),'```'+tag+'\n'+canon(code)+'```',reason,'[Исходник альтернативы]('+variant_path(p,lang,v)+')']
 lines+=['## Подсчёт','| Язык | Непробельные символы | Непустые строки | Без сложного Throws |\n| --- | ---: | ---: | ---: |\n'+'\n'.join(f"| {l['language']} | {count(l['code'])[0]} | {count(l['code'])[1]} | {supplemental(l['code']) if l['language']=='LMX' else '—'} |" for l in p['listings']),
 'Считается только `listings[].code`, включая импорты, объявления и throws. Альтернативный подход не прибавляется к основному. [Выбор](variant_selection.json) сравнивает допустимые варианты одной границы. [Зависимости реализации](IMPLEMENTATION_DEPENDENCIES.md) показывают общие LMX-тела отдельно.',
 'Автор считает явные конечные списки отказов и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод какие исходы порождает. Основная цена включает их полностью. Дополнительная колонка оставляет заголовок и первый написанный аргумент списка; copy/ссылка сохраняется целиком, общий банк учитывается один раз с первым аргументом. Это только другой подсчёт, не сокращение исходника или контракта.',
 '## Удалённые малозначимые повторы',p['dedup_notes_ru'],'## Семантические границы',p['limits_ru'],p.get('failure_note','') if isinstance(p.get('failure_note',''),str) else '',
 '[Политика очистки, ошибок и Message/post](FAILURE_BOUNDARIES.md).',
 '## English explanation',p['summary_en'],'**Scenario.** '+p['scenario_en'],'**Expected.** '+p['expected_en'],'**Limits.** '+p['limits_en'],
 'Usage clients call the real language/library facility. Adjacent foreign implementations are independent comparison subjects and are not imported by usage clients. Only genuinely different approaches remain. The source listings have not been executed by an LMX/Haskell/Scala runtime in this workspace.',
 '## Источники / Sources','\n'.join('- ['+s['title']+']('+s['url']+')' for s in p.get('sources',[])),
 '**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [источники ядра](../LMX_Fn_Receivers/README.md).',
 '## Проверка','[Проверка публикации](VALIDATION_2026-11-23.md) сверяет данные, исходники, отсутствие подмены библиотечных клиентов и границы подсчёта. [Acceptance matrix](acceptance_cases.json) отделяет подготовленные наблюдения от реального запуска.']
 return '\n\n'.join(x for x in lines if x)+'\n'
def main():
 data=json.loads((ROOT/'patterns.json').read_text());items=data['patterns'];idx={x['id']:x for x in items};rows=[];wanted=set()
 for p in items:
  for l in p['listings']:
   lang=l['language'];folder,ext,_=LANG[lang];path=ROOT/'examples'/folder/(stem(p)+'.'+ext)
   path.write_text(canon(l['code']));wanted.add(path)
  for lang,variants in p['variants'].items():
   for v,code in variants.items():
    if v==p['primary_variant'][lang]:continue
    path=ROOT/variant_path(p,lang,v);path.parent.mkdir(parents=True,exist_ok=True);path.write_text(canon(code));wanted.add(path)
  (ROOT/(stem(p)+'_comparision.md')).write_text(render_pattern(p,idx))
  row={'id':p['id'],'pattern':p['name'],'scope':p['scope'],'kind':p.get('kind','pattern'),'layer':'implementation' if p.get('kind')=='implementation' else 'usage','source':stem(p)+'_comparision.md'}
  for l in p['listings']:row[l['language']+'_characters'],row[l['language']+'_nonblank_lines']=count(l['code'])
  row['LMX_without_complex_throws_characters']=supplemental(next(l['code'] for l in p['listings'] if l['language']=='LMX'))
  rows.append(row)
 # Variant files duplicating the primary are no longer separate examples.
 for folder,ext,_ in LANG.values():
  for old in (ROOT/'examples'/folder/'variants').glob('*.'+ext):
   if old not in wanted:old.unlink()
 fields=['id','pattern','scope','kind','layer']+[l+'_characters' for l in LANG]+[l+'_nonblank_lines' for l in LANG]+['LMX_without_complex_throws_characters','source']
 with (ROOT/'LMX_Comparison_09_functional_computation.csv').open('w',encoding='utf-8-sig',newline='') as f:
  w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(rows)
 table=['# Сравнение: Функциональные вычисления','Редакция 2026-11-23. Контрольные языки: Haskell, Scala. Числа — непробельные символы / непустые строки.','Четыре клиента готовых средств и четыре отдельные реализации. Суммы разных уровней не образуют рейтинг языка. Соседние реализации не импортируются в контрольные клиенты.','| ID | Паттерн | LMX | Haskell | Scala | Граница | Без сложного Throws |\n| ---: | --- | ---: | ---: | ---: | --- | ---: |\n'+'\n'.join(f"| {p['id']:03d} | {link(p)} | "+' | '.join(f"{count(l['code'])[0]} / {count(l['code'])[1]}" for l in p['listings'])+' | '+('Реализация библиотеки' if p.get('kind')=='implementation' else 'Использование библиотеки')+' | '+str(supplemental(next(l['code'] for l in p['listings'] if l['language']=='LMX')))+' |' for p in items),'[Зависимости](IMPLEMENTATION_DEPENDENCIES.md) · [Выбор](variant_selection.json) · [Ошибки и Message](FAILURE_BOUNDARIES.md) · [Проверка](VALIDATION_2026-11-23.md)']
 (ROOT/'LMX_Comparison_09_functional_computation.md').write_text('\n\n'.join(table)+'\n')
 for lang,title in [('ru','LMX: Функциональные вычисления'),('en','LMX: Functional computation')]:
  lines=['# '+title,data['rationale_'+lang],data['overview_'+lang],'## Files','[Comparison](LMX_Comparison_09_functional_computation.md) · [Excel](LMX_Comparison_09_functional_computation.xlsx) · [PDF](LMX_Comparison_09_functional_computation.pdf) · [CSV](LMX_Comparison_09_functional_computation.csv) · [Implementations](IMPLEMENTATION_DEPENDENCIES.md)','## Catalog']
  for p in items:lines+=['### '+link(p),p['summary_'+lang],p['scenario_'+lang],p['expected_'+lang]]
  lines+=['## Counting boundary',data['selection_policy'],'Runtime status: LMX, Haskell and Scala NOT_RUN. Prepared edge cases are in [acceptance_cases.json](acceptance_cases.json).']
  (ROOT/f'LMX_Design_Patterns.{lang}.md').write_text('\n\n'.join(lines)+'\n')
 (ROOT/'README.md').write_text('# Функциональные вычисления\n\n'+data['overview_ru']+'\n\n[Каталог](LMX_Design_Patterns.ru.md) · [English](LMX_Design_Patterns.en.md) · [Сравнение](LMX_Comparison_09_functional_computation.md) · [Зависимости](IMPLEMENTATION_DEPENDENCIES.md) · [Проверка](VALIDATION_2026-11-23.md) · [Message и ошибки](FAILURE_BOUNDARIES.md)\n\nКлиенты Haskell используют Maybe, пакет free, Control.Exception.bracket и обычное применение функций. Scala использует Option, TailCalls, Using.resource и Function2.curried. Самописные MaybeValue/Bounce/Around/Partial используются только в сравнениях реализации. Они не нужны для запуска usage-клиентов.\n\nПрофили компиляции: Haskell usage — GHC с base, для 083 установленный free (проверенный контракт 5.2). Реализация 098 включает ScopedTypeVariables; 099 — DataKinds, GADTs, KindSignatures, TypeFamilies и TypeOperators, перечисленные в pragma. Scala-исходники написаны для Scala 3: enum/given/звёздочные импорты и гетерогенные Tuple в 099. Документация scala-library 2.13 подтверждает Using/TailCalls/Function2, но не означает совместимость этих исходников со Scala 2.13.\n\n`patterns.json` — источник листингов и допустимых вариантов. `alternative` пуст: полные исторические повторы убраны. Различающиеся подходы находятся в `variants`; отдельный файл в `variants/` создаётся только для неосновного подхода. Основной исходник не содержит второй полной закомментированной копии.\n\nВоспроизведение: sync_receiver_bodies.py → select_shortest.py → regenerate_publication.py → curry_appendix.py → check_publication.py. PDF/XLSX используют те же данные. Сверка исходников не является исполнением языков.\n')
 print(json.dumps({'patterns':len(items),'lmx_primary_characters':sum(x['LMX_characters'] for x in rows),'current_listings':3*len(items),'variant_files':len(wanted)-3*len(items)}))
if __name__=='__main__':main()

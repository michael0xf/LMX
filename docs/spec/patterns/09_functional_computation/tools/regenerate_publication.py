#!/usr/bin/env python3
"""Publish shortest primary variants and adjacent uncounted alternatives."""
from pathlib import Path
import csv,json
ROOT=Path(__file__).resolve().parents[1]
MARK='# BEGIN ALTERNATIVE LMX (excluded from character counts)'
END='# END ALTERNATIVE LMX'
LANG={'LMX':('lmx','lm3','lmx'),'Haskell':('haskell','hs','haskell'),'Scala':('scala','scala','scala')}
LABEL_RU={'shared_body':'общий алгоритм шага','shared_trace':'общие code и eval','core_curry':'ядро: поэтапное curry','core':'текущее ядро','local_callbacks':'локальный Around целиком','historical_procedural':'исторический процедурный пример','historical_specialized':'исторический специализированный пример','procedural':'процедурный','receivers':'новые обобщённые ресиверы','original':'прежняя реализация','generic':'обобщённая реализация'}
def canon(s):return s.strip()+'\n'
def count(s):return sum(not c.isspace() for c in s),sum(bool(l.strip()) for l in s.splitlines())
def historical_code(other):
 prefix=other.get('context_prefix','')
 return (canon(prefix)+'\n' if prefix else '')+canon(other['code'])
def stem(p):return f"{p['id']:03d}_{p['slug']}"
def link(p):return f"[{p['id']:03d}. {p['name']}]({stem(p)}_comparision.md)"
def variant_path(p,lang,variant):
 folder,ext,_=LANG[lang];return f'examples/{folder}/variants/{stem(p)}_{variant}.{ext}'
def refs(p,idx,en=False):
 lines=[]
 if p.get('implementation_ids'):lines.append(('**Companion implementation:** ' if en else '**Соседнее сравнение реализации:** ')+', '.join(link(idx[n]) for n in p['implementation_ids']))
 if p.get('usage_ids'):lines.append(('**Usage examples:** ' if en else '**Примеры использования:** ')+', '.join(link(idx[n]) for n in p['usage_ids']))
 return '\n\n'.join(lines)
def selection_note(p):
 return 'Основные варианты: '+', '.join(lang+' — **'+LABEL_RU[p['primary_variant'][lang]]+'**' for lang in LANG)+'. Основным считается самый короткий из рассмотренных допустимых алгоритмов текущего контракта; это выбор по символам, а не заявление о большей общности.'
def dependency_note(p,l,idx):
 if not p.get('implementation_ids'):return ''
 if p['id']==84 and l['language']=='LMX' and p['primary_variant']['LMX'] in ('local_callbacks','shared_trace'):
  return 'Локальный Around целиком включён в основной листинг и его размер. Общая реализация bracket в '+link(idx[98])+' относится к сохранённой действующей альтернативе core; основной локальный вариант не вызывает этот компонент.'
 deps=p['implementation_ids'] if l['language']=='LMX' else p['implementation_ids'][:1]
 return 'Тела используемых компонентов показаны рядом: '+', '.join(link(idx[n]) for n in deps)+'. Это описание текущего компонента, а не выбор версии библиотеки. Общая инфраструктура ядра раскрыта в реестре зависимостей.'

def failure_note(p,en=False):
 note=p.get('failure_note')
 if not note:return ''
 return '['+note['en' if en else 'ru']+']('+note['path']+').'

def render_pattern(p,idx):
 chosen=p['primary_variant']['LMX'];alt=p['alternative']['LMX']['variant'];desc=p['variant_descriptions']
 lines=[f"# {p['id']:03d}. {p['name']}",p['summary_ru'],refs(p,idx),'## Общий сценарий',p['scenario_ru'],'**Ожидаемое наблюдение:** '+p['expected_ru'],selection_note(p),'При одинаковом размере сохраняется прежний корректный основной вариант. Импорты, объявления и throws входят в подсчёт. Встроенные операции принадлежат одному текущему ядру; полный локальный helper допустим, когда сохраняет прикладной сценарий и включён в подсчёт. Исторические публикации остаются пояснением. Смена архитектурного механизма допустима при сохранении всей задачи, полей, эффектов и границы учитываемого кода.']
 lines.append(failure_note(p))
 for l in p['listings']:
  lang=l['language'];folder,ext,fence=LANG[lang];v=p['primary_variant'][lang]
  lines+=['## '+lang+' — основной: '+LABEL_RU[v],'```'+fence+'\n'+canon(l['code'])+'```',l.get('notes_ru',''),dependency_note(p,l,idx),f'[Основной листинг](examples/{folder}/{stem(p)}.{ext})']
 for lang in LANG:
  others=[v for v in p['variants'][lang] if v!=p['primary_variant'][lang]]
  if others:
   lines+=['Другие сохранённые '+lang+' варианты: '+', '.join('['+v+']('+variant_path(p,lang,v)+') — '+str(count(canon(p['variants'][lang][v]))[0])+' символов'+(' (допустимый)' if v in p['eligible_variants'][lang] else ' (исторический, вне выбора)') for v in others)+'.']
 for variant in p.get('inline_current_lmx_variants',[]):
  if variant==p['primary_variant']['LMX']:continue
  code=canon(p['variants']['LMX'][variant]);chars,ln=count(code)
  note=p.get('variant_notes',{}).get('LMX',{}).get(variant,{})
  lines+=['## LMX — действующая альтернатива: '+LABEL_RU[variant],
          '```lmx\n'+code+'```',note.get('notes_ru',''),
          f'Полный размер этого варианта: **{chars} непробельных символов / {ln} непустых строк**. Он не прибавляется к выбранному основному листингу; это отдельный допустимый способ выполнить тот же сценарий.',
          '[Исходник текущей альтернативы]('+variant_path(p,'LMX',variant)+')']
 lines+=['## Выбор основного кода и подсчёт','| Язык | Непробельные символы | Непустые строки |\n| --- | ---: | ---: |\n'+'\n'.join(f"| {l['language']} | {count(canon(l['code']))[0]} | {count(canon(l['code']))[1]} |" for l in p['listings']), 'Первичная таблица считает ровно `listings[].code`. Вторые варианты ниже не прибавляются к основным. [Допустимость и выбор алгоритма](variant_selection.json) воспроизводится скриптом. [Реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md) отдельно показывает, какие компоненты текущего ядра использует клиент и сколько стоит общее ядро новых ресиверов.']
 # Historical fences follow any explicitly displayed current alternatives.
 for lang in LANG:
  other=p['alternative'][lang];v=other['variant'];folder,ext,fence=LANG[lang]
  title='сохранённый процедурный вариант целиком' if other.get('context_prefix') and lang=='LMX' else LABEL_RU[v]
  shown=historical_code(other)
  lines+=['## '+lang+' — '+title+'; вне текущего подсчёта','```'+fence+'\n'+shown+'```']
  if p['id']==84 and lang=='LMX':
   chars,ln=count(shown);client_chars,_=count(other['code']);context_chars,_=count(other['context_prefix'])
   lines+=[f'Полный размер сохранённого варианта: **{chars} непробельных символов / {ln} непустых строк**: клиент — {client_chars}, Around — {context_chars} символов.',
           'Ранее здесь был неполный листинг: вызов `Around\\use` без определения `Around`. Теперь перед неизменённым сохранённым клиентом включено точное тело `Around` из сохранённого варианта [098](098_execute_around_implementation_comparision.md). Здесь уже были `throw` и `catch ResourceFailure`; этот синтаксис не отменён. Исходный текст клиента отдельно сохранён в `alternative.LMX.code` и `procedural_lmx`, а добавленное определение — в `alternative.LMX.context_prefix`. Полный сохранённый вариант показан и посчитан отдельно от основного.']
  elif other.get('context_prefix'):
   chars,ln=count(shown)
   lines += [f'Полный размер сохранённого варианта: **{chars} непробельных символов / {ln} непустых строк**.', other.get('reason','')]
  else:
   lines += [other.get('reason',''),'Исторический код сохранён для разбора, но не является другой подключаемой библиотекой и не участвует в выборе алгоритма текущего общего контракта.']
  if lang=='LMX':
   if p['id']!=84:lines+=['Историческая форма сохранена как объяснение исходного алгоритма. Она не объявляется действующей самостоятельной библиотекой или равной по общности заменой текущего ядра.']
   if p['id']!=84:lines+=['Новые реализации доступны также в [LMX_Fn_Receivers](../LMX_Fn_Receivers/README.md). Исторический специализированный пример не ограничивает текущий общий API ядра.']
 lines+=['## Семантические границы','**Честная граница сравнения.** '+p['fairness_notes']['LMX'],'**Основной LMX.** '+desc.get(chosen,desc['receivers']).get('lmx_notes_ru',''),'**Наблюдаемый общий сценарий.** '+p['limits_ru'],'**Возможности общего ядра.** '+desc['core'].get('limits_ru',''),'Универсальный набор новых ресиверов может делать больше специализированного компактного примера. В частности, Maybe/Bounce общего пакета хранят произвольные записи, bracket не фиксирует R, partial принимает произвольный смешанный префикс. Сравнение символов не приравнивает дополнительные возможности к нулевой стоимости. Прямой record-API сообщает FxCallFailure с исходным именем внутри; действующий общий вариант bracket проверяет этот договор явно. Локальный прикладной Around передаёт ResourceFailure напрямую и целиком входит в свой клиентский листинг.','## English explanation',p['summary_en'],refs(p,idx,True),'**Scenario.** '+p['scenario_en'],'**Expected observation.** '+p['expected_en'],'Primary is the shortest eligible complete current-contract algorithm for each language. Its imports, declarations and throws are included. The complete historical listing stays adjacent and is excluded from the primary count. Implementation comparisons retain their full generalized contracts. A usage scenario may instead use a complete counted local helper when it preserves that scenario. This does not select another core library edition; the generic component remains current.','**Primary LMX.** '+desc.get(chosen,desc['receivers']).get('lmx_notes_en',''),'**LMX variant `core`.** '+desc['core'].get('lmx_notes_en',''),'No execution of LMX or the control programs is claimed.','## Источники / Sources','\n'.join(f"- [{s['title']}]({s['url']}) — {s.get('why_ru','')}" for s in p.get('sources',[])), '**Норма LMX:** [семантика](../../LMX_semantics.en.md), [грамматика](../../LMX_grammar.en.md), [guide](../../LMX_semantics_guide.en.md).','## Проверка','[Проверка вариантов и публикации](VALIDATION_2026-11-22.md) отделяет статические сверки от фактического исполнения. [Интеграция в ядро](../../kernel-implementation.en.md#receiver-kernel-integration) описывает требуемую поддержку новых общих ресиверов.']
 lines.append(failure_note(p,True))
 return '\n\n'.join(x for x in lines if x)+'\n'

def main():
 data=json.loads((ROOT/'patterns.json').read_text());items=data['patterns'];idx={p['id']:p for p in items};rows=[]
 for p in items:
  for l in p['listings']:
   lang=l['language'];l['code']=canon(l['code']);folder,ext,_=LANG[lang];src=l['code']
   if lang=='LMX':src+='\n'+MARK+'\n'+'\n'.join('# '+line for line in historical_code(p['alternative']['LMX']).splitlines())+'\n'+END+'\n'
   (ROOT/'examples'/folder/(stem(p)+'.'+ext)).write_text(src)
  for lang in LANG:
   folder,ext,_=LANG[lang]
   for variant,code in p['variants'][lang].items():
    destination=ROOT/variant_path(p,lang,variant);destination.parent.mkdir(parents=True,exist_ok=True)
    destination.write_text(canon(code))
  (ROOT/(stem(p)+'_comparision.md')).write_text(render_pattern(p,idx))
  kind=p.get('kind','pattern');layer='implementation' if kind=='implementation' else 'usage' if p.get('implementation_ids') else 'scenario'
  row={'id':p['id'],'pattern':p['name'],'scope':p['scope'],'kind':kind,'layer':layer,'source':stem(p)+'_comparision.md'}
  for l in p['listings']:
   chars,ln=count(l['code']);row[l['language']+'_characters']=chars;row[l['language']+'_nonblank_lines']=ln
  rows.append(row)
 fields=['id','pattern','scope','kind','layer']+[l+'_characters' for l in LANG]+[l+'_nonblank_lines' for l in LANG]+['source']
 with (ROOT/'LMX_Comparison_09_functional_computation.csv').open('w',encoding='utf-8-sig',newline='') as f:
  w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(rows)
 table=['# Сравнение: Функциональные вычисления','Контрольные языки: **Haskell, Scala**. Редакция: 2026-11-22. Основной — короткий допустимый алгоритм текущего контракта.','Числа — непробельные символы / непустые строки. Альтернативы сохранены и исключены из этой таблицы. Готовые общие компоненты показаны отдельно; в 084 собственный локальный Around целиком включён в клиентский размер. Исторические примеры не задают ещё одну библиотеку. Подробности и отдельные суммы: [реестр зависимостей](IMPLEMENTATION_DEPENDENCIES.md).','| ID | Паттерн | LMX | Haskell | Scala | Граница |\n| ---: | --- | ---: | ---: | ---: | --- |']
 table[-1]+='\n'+'\n'.join(f"| {p['id']:03d} | [{p['name']}]({stem(p)}_comparision.md) | "+' | '.join(f"{count(canon(l['code']))[0]} / {count(canon(l['code']))[1]}" for l in p['listings'])+' | '+('Реализация библиотеки' if p.get('kind')=='implementation' else 'Клиент + локальный helper' if p['id']==84 and p['primary_variant']['LMX'] in ('local_callbacks','shared_trace') else 'Использование библиотеки')+' |' for p in items)
 table += [data['rationale_ru'],'[Варианты и размеры](variant_selection.json) · [Методика](../COMPARISON_METHODOLOGY.ru.md) · [Проверка](VALIDATION_2026-11-22.md) · [Выходы и обработчики](FAILURE_BOUNDARIES.md)','По разным контрактам и разной общности не строится общий рейтинг языка. Более короткий листинг не отменяет существование полной общей реализации рядом.']
 (ROOT/'LMX_Comparison_09_functional_computation.md').write_text('\n\n'.join(table)+'\n')
 for lang,title in [('ru','LMX: Функциональные вычисления'),('en','LMX: Functional computation')]:
  en=lang=='en';lines=['# '+title,data['rationale_'+lang],data['overview_'+lang],'## '+('Files' if en else 'Файлы'),'- [Markdown](LMX_Comparison_09_functional_computation.md)\n- [Excel](LMX_Comparison_09_functional_computation.xlsx)\n- [PDF](LMX_Comparison_09_functional_computation.pdf)\n- [CSV](LMX_Comparison_09_functional_computation.csv)\n- [Current core dependencies and implementation cost](IMPLEMENTATION_DEPENDENCIES.md)\n- [Validation](VALIDATION_2026-11-22.md)\n- [Receiver API](../LMX_Fn_Receivers/API.md)\n- [Declared exits and handlers](FAILURE_BOUNDARIES.md)','## '+('Catalog' if en else 'Каталог')]
  for p in items:
   choices=', '.join(l+': '+p['primary_variant'][l] for l in LANG)
   lines+=['### '+link(p),p['summary_'+lang],refs(p,idx,en),('**Primary variants:** ' if en else '**Основные варианты:** ')+choices+'.',('**Scenario:** ' if en else '**Сценарий:** ')+p['scenario_'+lang],('**Observation:** ' if en else '**Наблюдение:** ')+p['expected_'+lang]]
  lines+=['## '+('Counting boundary' if en else 'Границы подсчёта'),'Only primary listings are measured; each is the shortest eligible current-contract algorithm in its language. Historical LMX source remains beside current code. Current core dependencies and shared infrastructure are accounted separately; the local helper in 084 is counted in full inside its client. Generic implementation requirements are not imposed on a usage scenario beyond its actual contract. No runtime execution is implied.' if en else 'Измеряется только основной вариант — самый короткий рассмотренный допустимый алгоритм текущего контракта. Исторический LMX остаётся рядом с текущим кодом. Компоненты единого ядра и общая инфраструктура считаются отдельно; локальный helper 084 включён в клиентский размер целиком. Требования общей реализации не навязываются прикладному сценарию сверх его действительного контракта. Выбор и подсчёт не означают успешного исполнения.']
  (ROOT/f'LMX_Design_Patterns.{lang}.md').write_text('\n\n'.join(x for x in lines if x)+'\n')
 (ROOT/'README.md').write_text('# Функциональные вычисления\n\n'+data['rationale_ru']+'\n\n'+data['overview_ru']+'\n\n[Каталог](LMX_Design_Patterns.ru.md) · [English](LMX_Design_Patterns.en.md) · [Сравнение](LMX_Comparison_09_functional_computation.md) · [Зависимости](IMPLEMENTATION_DEPENDENCIES.md) · [Проверка](VALIDATION_2026-11-22.md) · [Выходы и обработчики](FAILURE_BOUNDARIES.md)\n\n`patterns.json` хранит допустимые текущие реализации в `variants` и `eligible_variants`, выбор в `primary_variant`, исторический исходник в `alternative`, основной текст в `listings[].code`. Строки реализаций сохраняют полный общий контракт. Для прикладного сценария допустим локальный helper с нужными этому сценарию типами, когда всё его тело включено в клиентский размер: так устроен текущий вариант 084. Он не выбирает старую редакцию ядра, а общий bracket остаётся действующей альтернативой. Исходный сохранённый клиент хранится без изменений в `alternative.LMX.code` и `procedural_lmx`. Для 083 `alternative.LMX.context_prefix` добавляет точные Bounce и BounceRunner из сохранённого 092. Для 084 `alternative.LMX.context_prefix` добавляет перед ним точное тело Around из сохранённого 098: показанный вариант и его отдельный размер включают оба фрагмента. В основные метрики входит только основной текущий листинг. Текущие исходники находятся в `examples/<language>/`; в `.lm3` исторический LMX дополнительно закомментирован рядом. Это не переключаемые версии библиотеки. Для воспроизведения: sync_receiver_bodies.py → select_shortest.py → regenerate_publication.py → check_publication.py. PDF/XLSX используют те же итоговые данные.\n')
 (ROOT/'patterns.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'patterns':len(items),'lmx_primary_characters':sum(r['LMX_characters'] for r in rows),'current_listings':3*len(items)},ensure_ascii=False))
if __name__=='__main__':main()

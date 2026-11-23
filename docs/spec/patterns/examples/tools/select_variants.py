#!/usr/bin/env python3
"""Publish the shortest correct full LMX variant and retain the alternative.

Authoritative algorithms/acceptance data are in examples/variants.json. Run this
again after a syntax migration. It recalculates both variants with one method;
no receiver or procedural implementation is preferred merely for its style.
"""
from pathlib import Path
import json,re,hashlib,copy
ROOT=Path(__file__).resolve().parents[2]
EX=ROOT/'examples'
BEGIN='# BEGIN ALTERNATIVE LMX (excluded from character counts)'
END='# END ALTERNATIVE LMX'
OLD_BEGIN='# BEGIN PROCEDURAL LMX (excluded from character counts)'

def canonical(s):return s.strip()+'\n'
def metric(s):
 s=canonical(s)
 return {'characters':sum(not c.isspace() for c in s),'nonblank_lines':sum(bool(x.strip()) for x in s.splitlines()),'utf8_bytes':len(s.encode()),'sha256':hashlib.sha256(s.encode()).hexdigest()}
def save(path,data):path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
def main():
 registry=json.loads((EX/'variants.json').read_text());expect=json.loads((EX/'expected_results.json').read_text())
 existing_counts=json.loads((EX/'validation/functional_receiver_counts.json').read_text())
 oldrows={r['id']:r for r in existing_counts['rows']};by_case={r['id']:r for r in expect['source_examples']}
 guide=(ROOT/'LMX_examples_and_analogies.ru.md').read_text();selected={};comparisons=[]
 for record in registry['records']:
  ident=record['id'];variants=record['variants']
  for v in variants:
   # Current declarations, with obsolete public keyword removed.
   v['code']=re.sub(r'(?m)^(\s*)fn:\s*([A-Za-z_][\w]*)\s+(.+)$',r'\1\2 :: \3',canonical(v['code']))
   v['metrics']=metric(v['code'])
  valid=[v for v in variants if v['correct_for_scenario'] and v['id'] in record['eligible_variants']]
  chosen=min(valid,key=lambda v:(v['metrics']['characters'],v['id']!='original'))
  alternate=next(v for v in variants if v['id']!=chosen['id'])
  record['selected']=chosen['id'];record['alternative']=alternate['id'];record['selection_metric']='nonwhitespace_characters_of_complete_current_source'
  selected[ident]=chosen
  comment='\n'.join('# '+line for line in alternate['code'].splitlines())+'\n'
  text=chosen['code'].rstrip()+'\n\n'+BEGIN+'\n# '+alternate['label_ru']+' — не входит в подсчёт основной версии.\n'+comment+END+'\n'
  (EX/'lmx'/f'{ident}.lm3').write_text(text)
  row=by_case[ident]
  for key in ('cases','load_before','required_profile'):row[key]=copy.deepcopy(chosen.get(key,[]))
  row['selected_variant']=chosen['id'];row['alternative_variant']=alternate['id']
  row['alternative_cases']=copy.deepcopy(alternate['cases']);row['alternative_load_before']=copy.deepcopy(alternate['load_before'])
  row['variant_cases']={v['id']:copy.deepcopy(v['cases']) for v in variants}
  row['variant_load_before']={v['id']:copy.deepcopy(v['load_before']) for v in variants}
  row['source_regions']={'primary':'Before '+BEGIN,'alternative':{'begin':BEGIN,'end':END,'comment_prefix':'# ','skip_label_line':True,'execute_separately':True}}
  row.pop('procedural_source_region',None)
  row.pop('procedural_cases',None);row.pop('procedural_load_before',None)
  row['core_versions']=1;row['fairness_note']=record['fairness_note']
  if ident=='H07':row['semantic_scope']='Both same-core algorithms are retained: original tests prepared/raw occurrences, receivers tests lazy caching plus two ordinary calls. They share output/count fixtures; the stronger raw-graph test belongs to original only.'
  snippet=f'''<a id="{ident.lower()}"></a>
### {record['title_ru']}

Оба варианта используют одно текущее ядро. Основным выбран более короткий корректный вариант с сопоставимой границей учёта, включая весь написанный код и необходимые объявления исходов. Разная архитектура языка сама по себе не запрещает естественный короткий механизм LMX.

| Вариант | Непробельные символы | Непустые строки | Роль |
| --- | ---: | ---: | --- |
'''
  for v in variants:snippet+=f"| {v['label_ru']} | {v['metrics']['characters']} | {v['metrics']['nonblank_lines']} | {'Основной, сравниваемый' if v['id']==chosen['id'] else 'Альтернативный, отдельно от основного'} |\n"
  snippet+='\n#### Основной вариант LMX\n\n<!-- example: '+ident+' -->\n```lmx\n'+chosen['code'].rstrip()+'\n```\n\n'+chosen['notes_ru']+'\n\n**Ожидается:** '+record['expected_ru']+'\n'
  if record.get('retained_explanation_ru'):snippet+='\n#### Исходный контрольный сценарий и его полный смысл\n\n'+record['retained_explanation_ru']+'\n'
  snippet+='\n#### '+alternate['label_ru']+' — не входит в подсчёт основной версии\n\n<!-- alternative-example: '+ident+' -->\n```lmx\n'+alternate['code'].rstrip()+'\n```\n\n'+alternate['notes_ru']+'\n'
  if record.get('implementation_comparison'):snippet+='\n[Обе реализации библиотеки и их отдельные размеры](examples/'+record['implementation_comparison']+').\n'
  else:snippet+='\n[API общего пакета](LMX_Fn_Receivers/API.md) · [Исходники](LMX_Fn_Receivers/LMX_Receivers.lmx).\n'
  snippet+='\n**Граница сравнения.** '+record['fairness_note']+'\n'
  if len(record['eligible_variants'])<len(variants):snippet+='\nДополнительная запись не участвует в выборе основного, если не сохраняет весь заявленный сценарий; одинаковых чисел demo для этого недостаточно.\n'
  snippet+='\nПроверки обеих записей перечислены раздельно в [expected_results.json](examples/expected_results.json). Каждая запись проверяется отдельно на одном текущем ядре; где процедурный алгоритм требует собственных структур, они видны в листинге. Никаких загружаемых версий ядра или receiver-библиотеки не вводится. Интерпретатор и GHC здесь не запускались.\n\n'
  anchor='<a id="'+ident.lower()+'"></a>';start=guide.index(anchor);next_anchor=re.search(r'<a id="[^\"]+"></a>',guide[start+len(anchor):]);end=start+len(anchor)+next_anchor.start() if next_anchor else len(guide)
  guide=guide[:start]+snippet+guide[end:]
  comparisons.append({'id':ident,'selected':chosen['id'],'alternative':alternate['id'],'variants':{v['id']:v['metrics'] for v in variants},'eligible_variants':record['eligible_variants'],'fairness_note':record['fairness_note']})
 intro='''**Правило основной версии.** Для H01, H02, H03, H04, H06, H07, R01, V02 и V03 рядом сохранены полные варианты реализации: с прямыми вызовами, общими ресиверами текущего ядра либо повторным использованием уже показанного локального метода. Основным является более короткий корректный полный листинг среди вариантов с сопоставимой границей учёта; второй показан рядом и исключён из размера основного. H09 и V02 включают собственные helpers в основной код и его размер. H05/H08 сохраняют непосредственное связывание и место записи, H09 — живую декларацию и выход Stop. [Полный аудит](examples/OPTIMIZATION_REVIEW.md).\n'''
 guide=re.sub(r'\*\*Редакция с общими ресиверами\.\*\*.*?\n',intro,guide,count=1)
 guide=re.sub(r'\*\*Правило основной версии\.\*\*.*?\n',intro,guide,count=1)
 (ROOT/'LMX_examples_and_analogies.ru.md').write_text(guide)
 save(EX/'variants.json',registry)
 expect['receiver_revision']={'date':'2026-11-22','variant_ids':list(selected),'rule':registry['rule'],'metric_boundary':BEGIN,'selected':{i:v['id'] for i,v in selected.items()},'original_and_receivers_cases_preserved':True,'runtime_executed':False}
 save(EX/'expected_results.json',expect)
 rows=[]
 for path in sorted((EX/'lmx').glob('*.lm3')):
  ident=path.stem;current=path.read_text().split(BEGIN)[0].split(OLD_BEGIN)[0]
  previous=oldrows[ident];before=previous.get('historical_before',previous['before'])
  item={'id':ident,'file':'lmx/'+path.name,'changed':metric(current)['sha256']!=before['sha256'],'before':before,'historical_before':before,'after':metric(current),'has_alternative':ident in selected}
  if ident in selected:
   record=next(r for r in registry['records'] if r['id']==ident)
   item.update({'selected_variant':record['selected'],'alternative_variant':record['alternative'],'variants':{v['id']:v['metrics'] for v in record['variants']},'original_source_sha256_at_import':record['original_source_sha256_at_import'],'original_algorithm_preserved':True,'eligible_variants':record['eligible_variants'],'fairness_note':record['fairness_note'],'syntax_normalized':'Name :: DATA; signatureTypes token constructor'})
  rows.append(item)
 changed=[r for r in rows if r['has_alternative']]
 counts={'format':'functional-receiver-counts-v2','date':'2026-11-22','scope':'shortest correct primary source only; complete current-syntax variants compared with the same method','metric_boundary':BEGIN,'metric_definition':{'characters':'Unicode code points excluding whitespace; active comments and strings included','nonblank_lines':'nonempty stripped lines','utf8_bytes':'code.strip()+LF encoded UTF-8'},'source_count':len(rows),'changed_ids':list(selected),'selected_receiver_primary_ids':[i for i,v in selected.items() if v['id']=='receivers'],'variant_comparisons':comparisons,'rows':rows,'totals_changed':{side:{k:sum(x[side][k] for x in changed) for k in ('characters','nonblank_lines','utf8_bytes')} for side in ('before','after')},'totals_all':{side:{k:sum(x[side][k] for x in rows) for k in ('characters','nonblank_lines','utf8_bytes')} for side in ('before','after')},'runtime_executed':False}
 save(EX/'validation/functional_receiver_counts.json',counts)
 save(EX/'validation/primary_listings.json',{'format':'lmx-primary-listings-v2','status':'source_text_not_runtime_receipt','source_prefix_ends_before':BEGIN,'archive_end':END,'counted_source_normalization':'code.strip() + LF','selected':{i:v['id'] for i,v in selected.items()},'listings':{i:v['code'] for i,v in selected.items()}})
 # A current publication report supersedes the former forced-functional counts.
 audit='''# Аудит examples: выбор основной версии по длине

Редакция:22 ноября2026 года. Просмотрены все24 исходных LMX-клиента. Для H01,H02,H03,H04,H06,H07,R01,V02,V03 сохранены полные основные и альтернативные алгоритмы; эквивалентность полного сценария отмечена отдельно. V03 повторно использует уже имеющийся локальный sample. Основной выбран минимальный корректный листинг среди вариантов с честной границей учёта. Все receivers доступны в одном ядре без import fun. Учитываются реальные throws, поля, копии, идентичности и эффекты; языки могут выражать их разными архитектурными механизмами. [Индивидуальный аудит 47 примеров](../validation/reuse_review_gof_examples_20261122.json) охватывает также23 корневых GoF.

| Пример | Первый сохранённый вариант | Второй вариант | Основной |
| --- | ---: | ---: | --- |
'''
 for record in registry['records']:
  a,b=record['variants'];audit+=f"| [{record['id']}](lmx/{record['id']}.lm3) | {a['metrics']['characters']} | {b['metrics']['characters']} | {record['selected']} |\n"
 audit+='''
Остальные15 клиентов сохраняют прямой алгоритм. H05/H08 проверяют непосредственный caller и место записи, H09 — передаваемую декларацию, четыре вызова next и три исполнения тела. Полный Cycles включён в основной H09; полный CharacterRange включён в основной V02. Их прежние клиентские части сохранены без изменений, но размер теперь включает helpers. Остальные случаи относятся к графу, проверке поведения и Message/HTTP; дополнительный функциональный wrapper не уменьшает их проверяемый механизм. R01 получил более короткий эквивалентный derive, с сохранением width/height/depth и видимой реализацией рядом. Pattern-вариант V02 показан отдельно: он сохраняет ASCII-результаты на 8-битном byteText-профиле, но не подменяет собственный between и не получает бесплатного конкурентного regex-контроля. [Проверка всех24 по новой семантике](SEQUENCE_PATTERN_REVIEW.md).

## Границы измерения и зависимости

Основная часть заканчивается перед точной строкой `# BEGIN ALTERNATIVE LMX (excluded from character counts)`. Второй листинг закомментирован, сохранён в том же файле и не исполняется вместе с первым. Обе версии представлены также в русском руководстве. Все типы и объявления приведены к текущей записи `Name :: DATA`; сохраняется алгоритм прежнего варианта, а не устаревшее написание ключевого слова.

[variants.json](variants.json) содержит оба полных исходника, ожидаемые случаи и зависимости. [select_variants.py](tools/select_variants.py) повторно выбирает минимум после изменения синтаксиса. [Точные размеры](validation/functional_receiver_counts.json) включают также историческое значение до этой редакции, отдельно от размеров двух нормализованных вариантов.

Все записи используют одно текущее ядро. Прямые H01/H06 обходятся естественными динамическими вызовами. Прежний механизм захвата H03 и raw/prepared операнды H07 полностью включены в процедурные листинги как пользовательский код; они не требуют другой версии ядра. Общие receivers — уже часть ядра, их исходники и интерфейсы доступны для проверки. Structure/Array<@> сама служит контейнером аргументов и префикса; дополнительного поля items нет.

Все прежние ожидаемые числа сохранены. Ожидания, зависящие от конкретной реализации, тоже сохранены у правильной версии: CapturePrototype.saved у исходной H03; независимость префиксов/p0 у общей H03; реальные raw-occurrences у исходной H07; lazy и два обычных вызова у общей H07. Подготовка обеих версий — в [expected_results.json](expected_results.json).

## Реализации рядом

[Apply](library_comparisons/h01_apply_comparision.md), [Partial/capture](library_comparisons/h03_capture_comparision.md), [Pipe](library_comparisons/h06_pipe_comparision.md), [Lazy/prepared/raw](library_comparisons/h07_evaluation_modes_comparision.md) показывают оба библиотечных алгоритма. Общие LMX-зависимости перечислены полностью и считаются отдельно от клиента. Сравнения не скрывают ядро за импортом и не приравнивают разные области применимости.

[Stop-итератор](library_comparisons/h09_iterator_comparision.md) остаётся прямым. Для [диапазона символов](library_comparisons/v02_character_range_comparision.md) рядом добавлен новый Pattern-вариант с отдельной границей сравнения; исходный междуграницный helper и все11 проверок сохранены. Haskell-модули используют общие типовые параметры; новый Partial совпадает с099, дополнительные проверки pipe2/lazyIO не удаляют прежние assertions.

Статическая проверка исходников, ссылок и размеров не является исполнением LMX или GHC. [Текущий отчёт](validation/receiver_revision.json).
'''
 (EX/'OPTIMIZATION_REVIEW.md').write_text(audit)
 readme=(EX/'README.ru.md').read_text();start=readme.index('## Редакция с общими ресиверами');end=readme.index('## Haskell',start)
 replacement='''## Редакция с общими ресиверами и выбором короткого варианта

Для H01,H02,H03,H04,H06,H07,R01,V02,V03 основной — более короткий корректный полный LMX-код, второй вариант сохранён рядом и исключён из его размера. V03 использует уже объявленный локальный sample; H09 и V02 включают собственные Cycles/CharacterRange в основной блок и размер. Сравниваются только корректные варианты с сопоставимой границей учёта. Естественные динамические вызовы, копирование и связывание LMX не заменяются искусственной архитектурной имитацией. [Аудит и таблица](OPTIMIZATION_REVIEW.md) · [Оба исходника и зависимости](variants.json).

`expected_results.json` указывает `selected_variant`, `alternative_cases`, `variant_cases` и `variant_load_before`. Каждый вариант запускается отдельно. Все общие ресиверы входят в одно текущее ядро и доступны прямо. [LMX_Receivers.lmx](../LMX_Fn_Receivers/LMX_Receivers.lmx) — его видимые исходники, а не отдельная выбираемая версия библиотеки. Старые механизмы, если они нужны процедурному аналогу, явно записаны внутри самого примера. Каталог libraries сохраняет исходники механизмов для чтения, а не набор альтернативных ядер.

В H02 именованное требование записывается `PairOperation :: DATA`. Альтернатива строит такое же семантическое требование через `signatureTypes`, без публичного fn. H05/H08/H09 сохранены прямыми по причинам связывания, места записи и живой декларации/Stop; R07/V02 сохраняют OPERANDS_TEMPLATE первым в DATA.

[Размеры](validation/functional_receiver_counts.json) относятся к основной части перед маркером альтернативы. [Скрипт выбора](tools/select_variants.py) и [проверка](tools/check_receiver_revision.py) воспроизводят это правило. Реализации библиотек показаны рядом и посчитаны отдельно.

'''
 readme=readme[:start]+replacement+readme[end:];(EX/'README.ru.md').write_text(readme)
 print(json.dumps({'selected':{i:v['id'] for i,v in selected.items()},'totals_changed':counts['totals_changed']},ensure_ascii=False))
if __name__=='__main__':main()

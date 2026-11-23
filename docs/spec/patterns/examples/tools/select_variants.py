#!/usr/bin/env python3
"""Publish genuine alternatives; a one-line substitution is a note, not a listing."""
from pathlib import Path
import json,re,hashlib,copy,sys
ROOT=Path(__file__).resolve().parents[2]; EX=ROOT/'examples'
sys.path.insert(0,str(ROOT/'tools'))
from throws_metrics import measure_throws
BEGIN='# BEGIN ALTERNATIVE LMX (excluded from character counts)'; END='# END ALTERNATIVE LMX'
def canonical(s):return s.strip()+'\n'
def metric(s):
 s=canonical(s);return {'characters':sum(not c.isspace() for c in s),'nonblank_lines':sum(bool(x.strip()) for x in s.splitlines()),'utf8_bytes':len(s.encode()),'sha256':hashlib.sha256(s.encode()).hexdigest(),'without_complex_throws_characters':measure_throws(s,ROOT)['without_complex_throws_characters']}
def save(p,d):p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
def main():
 registry=json.loads((EX/'variants.json').read_text()); expect=json.loads((EX/'expected_results.json').read_text())
 baseline=json.loads((EX/'validation/source_baseline_20261123.json').read_text()); oldrows={x['id']:x for x in baseline['records']}
 cases={x['id']:x for x in expect['source_examples']};guide=(ROOT/'LMX_examples_and_analogies.ru.md').read_text();selected={};comparisons=[]
 for r in registry['records']:
  ident=r['id'];variants=r['variants']
  for v in variants:v['code']=canonical(v['code']);v['metrics']=metric(v['code'])
  allowed=[v for v in variants if v['correct_for_scenario'] and v['id'] in r['eligible_variants']]
  chosen=min(allowed,key=lambda v:(v['metrics']['characters'],v['id']!='original'));alternates=[v for v in variants if v is not chosen]
  assert len(alternates)<=1,ident
  alt=alternates[0] if alternates else None;r['selected']=chosen['id'];r['alternative']=alt['id'] if alt else None;selected[ident]=chosen
  text=chosen['code']
  if alt:text+='\n'+BEGIN+'\n# '+alt['label_ru']+' — отдельный подход; вне основного размера.\n'+'\n'.join('# '+x for x in alt['code'].splitlines())+'\n'+END+'\n'
  (EX/'lmx'/f'{ident}.lm3').write_text(text)
  row=cases[ident]
  for key in ('cases','load_before','required_profile'):row[key]=copy.deepcopy(chosen.get(key,[]))
  row['selected_variant']=chosen['id'];row['alternative_variant']=r['alternative'];row['alternative_cases']=copy.deepcopy(alt['cases']) if alt else [];row['alternative_load_before']=copy.deepcopy(alt['load_before']) if alt else []
  row['variant_cases']={v['id']:copy.deepcopy(v['cases']) for v in variants};row['variant_load_before']={v['id']:copy.deepcopy(v['load_before']) for v in variants}
  row['source_regions']={'primary':'Before '+BEGIN}
  if alt:row['source_regions']['alternative']={'begin':BEGIN,'end':END,'comment_prefix':'# ','skip_label_line':True,'execute_separately':True}
  for key in ['embedded_helpers','historical_client','procedural_source_region','procedural_cases','procedural_load_before']:row.pop(key,None)
  row['core_versions']=1;row['fairness_note']=r['fairness_note']
  snippet=f'<a id="{ident.lower()}"></a>\n### {r["title_ru"]}\n\n'
  snippet+='Основной вариант выбирается по полному размеру и договору задачи. Необходимые локальные определения учитываются; вариант с ядром не получает отдельного приоритета. Реально различающиеся способы показаны отдельно, небольшие замены строк — только пояснением.\n\n| Вариант | Непробельные символы | без сложного Throws | Непустые строки | Роль |\n| --- | ---: | ---: | ---: | --- |\n'
  for v in variants:snippet+=f'| {v["label_ru"]} | {v["metrics"]["characters"]} | {v["metrics"]["without_complex_throws_characters"]} | {v["metrics"]["nonblank_lines"]} | '+('Основной' if v is chosen else 'Другой подход')+' |\n'
  snippet+='\n#### Основной вариант LMX\n\n<!-- example: '+ident+' -->\n```lmx\n'+chosen['code'].rstrip()+'\n```\n\n'+chosen['notes_ru']+'\n\n**Ожидается:** '+r['expected_ru']+'\n'
  if r.get('retained_explanation_ru'):snippet+='\n'+r['retained_explanation_ru']+'\n'
  if alt:snippet+='\n#### '+alt['label_ru']+' — вне основного размера\n\n<!-- alternative-example: '+ident+' -->\n```lmx\n'+alt['code'].rstrip()+'\n```\n\n'+alt['notes_ru']+'\n'
  if r.get('inline_variant_note_ru'):snippet+='\n**Вместо повторного листинга.** '+r['inline_variant_note_ru']+'\n'
  if r.get('implementation_comparison'):snippet+='\n[Отдельное сравнение реализаций](examples/'+r['implementation_comparison']+').\n'
  snippet+='\n**Граница сравнения.** '+r['fairness_note']+'\n\n[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.\n\n'
  anchor='<a id="'+ident.lower()+'"></a>';start=guide.index(anchor);n=re.search(r'<a id="[^\"]+"></a>',guide[start+len(anchor):]);end=start+len(anchor)+n.start() if n else len(guide)
  guide=guide[:start]+snippet+guide[end:]
  comparisons.append({'id':ident,'selected':r['selected'],'alternative':r['alternative'],'variants':{v['id']:v['metrics'] for v in variants},'eligible_variants':r['eligible_variants'],'fairness_note':r['fairness_note']})
 intro='**Правило основной версии.** Основной — кратчайший полный вариант при сопоставимом контракте, независимо от локального определения или использования ядра. Локальные helpers входят в листинг и размер. Общие тела и шаблоны переиспользуются; полные альтернативы остаются для разных подходов. Обёртка FxCallFailure не считается равнозначной распространению исходного именованного отказа. Haskell-клиенты используют настоящие библиотеки и обычные операции языка.\n'
 guide=re.sub(r'\*\*Правило основной версии\.\*\*.*?\n',intro,guide,count=1)
 throws_note='**Throws и длина кода.** На мой взгляд, явные списки ошибок — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий Throws и `throws: copy(Throws)` сохраняют эту ясность. Сокращать такие записи ради размера не хочется. Колонка «без сложного Throws» считает заголовки, первый аргумент каждого списка и полные ссылки copy; только аргументы после первого не входят в дополнительный подсчёт. Исходники не меняются.\n'
 if '**Throws и длина кода.**' in guide:
  guide=re.sub(r'\*\*Throws и длина кода\.\*\*.*?\n',lambda _:throws_note,guide,count=1)
 else:guide=guide.replace(intro,intro+'\n'+throws_note,1)
 (ROOT/'LMX_examples_and_analogies.ru.md').write_text(guide);save(EX/'variants.json',registry)
 expect['receiver_revision']={'date':'2026-11-23','variant_ids':list(selected),'rule':registry['rule'],'metric_boundary':BEGIN,'selected':{i:v['id'] for i,v in selected.items()},'scenario_cases_preserved':True,'minor_variants_compacted':True,'runtime_executed':False};save(EX/'expected_results.json',expect)
 rows=[]
 for path in sorted((EX/'lmx').glob('*.lm3')):
  ident=path.stem;current=path.read_text().split(BEGIN)[0];previous=oldrows[ident];before=previous['metrics'];r=next((r for r in registry['records'] if r['id']==ident),None)
  row={'id':ident,'file':'lmx/'+path.name,'changed':metric(current)['sha256']!=before['sha256'],'before':before,'historical_before':before,'after':metric(current),'has_alternative':bool(r and r['alternative'])}
  if r:row.update({'selected_variant':r['selected'],'alternative_variant':r['alternative'],'variants':{v['id']:v['metrics'] for v in r['variants']},'original_source_sha256_at_import':r['original_source_sha256_at_import'],'scenario_preserved':True,'eligible_variants':r['eligible_variants'],'fairness_note':r['fairness_note']})
  rows.append(row)
 changed=[r for r in rows if r['id'] in selected]
 counts={'format':'functional-receiver-counts-v3','date':'2026-11-23','baseline_archive_sha256':baseline['archive_sha256'],'scope':'Primary client, excluding distinct commented alternatives and separately compared implementations','metric_boundary':BEGIN,'source_count':len(rows),'changed_ids':list(selected),'selected_receiver_primary_ids':[i for i,v in selected.items() if v['id']=='receivers'],'variant_comparisons':comparisons,'rows':rows,'totals_changed':{side:{k:sum(x[side][k] for x in changed) for k in ('characters','nonblank_lines','utf8_bytes')} for side in ('before','after')},'totals_all':{side:{k:sum(x[side][k] for x in rows) for k in ('characters','nonblank_lines','utf8_bytes')} for side in ('before','after')},'runtime_executed':False}
 counts['totals_all']['after']['without_complex_throws_characters']=sum(x['after']['without_complex_throws_characters'] for x in rows)
 counts['totals_changed']['after']['without_complex_throws_characters']=sum(x['after']['without_complex_throws_characters'] for x in changed)
 save(EX/'validation/functional_receiver_counts.json',counts);save(EX/'validation/primary_listings.json',{'format':'lmx-primary-listings-v3','status':'source_text_not_runtime_receipt','source_prefix_ends_before':BEGIN,'selected':{i:v['id'] for i,v in selected.items()},'listings':{i:v['code'] for i,v in selected.items()}})
 audit='# Аудит examples: восстановление коротких реализаций\n\nРедакция: 23 ноября 2026 года. Все 24 сценария сохранены. H04 восстановлен на основе прямого merge из 22-Nov; H09 снова содержит целиком исходный короткий Cycles. Вариант с ядром не имеет приоритета перед более простым полным решением.\n\n| Пример | Сохранённые подходы | Основной |\n| --- | --- | --- |\n'
 for r in registry['records']:audit+='| '+r['id']+' | '+', '.join(v['id'] for v in r['variants'])+' | '+r['selected']+' |\n'
 audit+='\nH07 переиспользует sys\\OPERANDS_TEMPLATE через copy/merge. H08 использует один runner и одно тело изменения y, демонстрируя собственную ячейку Own и свободное динамическое место Free. M01.add вызывает уже существующий read. V05 записывает шаг журнала и пару set/observe по одному разу; два вызова пары безусловны. H01/H02/H03/H04/H06 не хранят ненужные промежуточные результаты.\n\nH09 включает полное локальное определение Cycles в основной размер. Его catch обрабатывает только Stop источника; отказ тела распространяется под исходным именем. Отдельный core-адаптер с FxCallFailure показан как иной контракт и не используется для подмены основного примера. V02 сохраняет between; prepared/raw occurrences H07 и lazy сохраняются как разные подходы.\n\nHaskell использует аппликацию, композицию, foldM/replicateM, Data.Ix.inRange и Control.Monad.Loops.whileJust_. Каталог libraries содержит сравниваемые реализации; клиентский Cabal-компонент не добавляет его в hs-source-dirs.\n\n[Ожидания](expected_results.json), [реестр вариантов](variants.json), [размеры](validation/functional_receiver_counts.json). Проверены исходники и согласованность; исполнение LMX/GHC не заявляется.\n'
 (EX/'OPTIMIZATION_REVIEW.md').write_text(audit)
 readme=(EX/'README.ru.md').read_text();start=readme.index('## Редакция с общими ресиверами');end=readme.index('## Haskell',start)
 readme=readme[:start]+'''## Редакция с общими ресиверами и восстановленными короткими примерами

H04 использует прямой merge из 22-Nov. H09 содержит полный короткий Cycles с обычным catch; определение включено в основной размер. V02 сохраняет between. H07 переиспользует общий шаблон операнда, H08 — одно тело изменения y и один runner, M01 — существующий read, V05 — общий шаг журнала и общий цикл set/observe. Динамическое связывание и copy учитываются как обычные возможности языка. При равном договоре выбирается кратчайшая полноценная запись; размещение функции в ядре не даёт её клиенту приоритета.

[Реестр](variants.json) · [Ожидания](expected_results.json) · [Аудит](OPTIMIZATION_REVIEW.md) · [Размеры](validation/functional_receiver_counts.json). Все 24 сценария и их наблюдения сохранены.

'''+readme[end:]
 readme=re.sub(r'runghc -[^\n]*Analogies.hs','cd haskell && cabal run lmx-analogy-clients',readme)
 (EX/'README.ru.md').write_text(readme)
 print(json.dumps({'selected':{i:v['id'] for i,v in selected.items()},'alternatives':sum(bool(r['alternative']) for r in registry['records']),'totals':counts['totals_all']},ensure_ascii=False))
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Publish genuine alternatives; a one-line substitution is a note, not a listing."""
from pathlib import Path
import json,re,hashlib,copy
ROOT=Path(__file__).resolve().parents[2]; EX=ROOT/'examples'
BEGIN='# BEGIN ALTERNATIVE LMX (excluded from character counts)'; END='# END ALTERNATIVE LMX'
def canonical(s):return s.strip()+'\n'
def metric(s):
 s=canonical(s);return {'characters':sum(not c.isspace() for c in s),'nonblank_lines':sum(bool(x.strip()) for x in s.splitlines()),'utf8_bytes':len(s.encode()),'sha256':hashlib.sha256(s.encode()).hexdigest()}
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
  snippet+='Один проект ядра; пользовательские копии библиотек в клиент не вставляются. Реально различающиеся способы показаны отдельно, небольшие замены строк — только пояснением.\n\n| Вариант | Непробельные символы | Непустые строки | Роль |\n| --- | ---: | ---: | --- |\n'
  for v in variants:snippet+=f'| {v["label_ru"]} | {v["metrics"]["characters"]} | {v["metrics"]["nonblank_lines"]} | '+('Основной' if v is chosen else 'Другой подход')+' |\n'
  snippet+='\n#### Основной вариант LMX\n\n<!-- example: '+ident+' -->\n```lmx\n'+chosen['code'].rstrip()+'\n```\n\n'+chosen['notes_ru']+'\n\n**Ожидается:** '+r['expected_ru']+'\n'
  if r.get('retained_explanation_ru'):snippet+='\n'+r['retained_explanation_ru']+'\n'
  if alt:snippet+='\n#### '+alt['label_ru']+' — вне основного размера\n\n<!-- alternative-example: '+ident+' -->\n```lmx\n'+alt['code'].rstrip()+'\n```\n\n'+alt['notes_ru']+'\n'
  if r.get('inline_variant_note_ru'):snippet+='\n**Вместо повторного листинга.** '+r['inline_variant_note_ru']+'\n'
  if r.get('implementation_comparison'):snippet+='\n[Отдельное сравнение реализаций](examples/'+r['implementation_comparison']+').\n'
  snippet+='\n**Граница сравнения.** '+r['fairness_note']+'\n\n[Ожидания и отдельные случаи](examples/expected_results.json). LMX runtime и GHC для этой редакции не запускались.\n\n'
  anchor='<a id="'+ident.lower()+'"></a>';start=guide.index(anchor);n=re.search(r'<a id="[^\"]+"></a>',guide[start+len(anchor):]);end=start+len(anchor)+n.start() if n else len(guide)
  guide=guide[:start]+snippet+guide[end:]
  comparisons.append({'id':ident,'selected':r['selected'],'alternative':r['alternative'],'variants':{v['id']:v['metrics'] for v in variants},'eligible_variants':r['eligible_variants'],'fairness_note':r['fairness_note']})
 intro='**Правило основной версии.** Основной — кратчайший полный вариант при сопоставимом контракте. Полные альтернативы остаются только для разных подходов; небольшие замены строк объяснены без повторения программы. Общие функции LMX входят в проект ядра; Haskell-клиенты используют настоящие библиотеки и обычные операции языка. Реализации сравниваются отдельно.\n'
 guide=re.sub(r'\*\*Правило основной версии\.\*\*.*?\n',intro,guide,count=1)
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
 save(EX/'validation/functional_receiver_counts.json',counts);save(EX/'validation/primary_listings.json',{'format':'lmx-primary-listings-v3','status':'source_text_not_runtime_receipt','source_prefix_ends_before':BEGIN,'selected':{i:v['id'] for i,v in selected.items()},'listings':{i:v['code'] for i,v in selected.items()}})
 audit='# Аудит examples: ядро, настоящие библиотеки и разные подходы\n\nРедакция: 23 ноября 2026 года. Все 24 сценария сохранены. H04, R01 и V03 больше не повторяют целые программы ради нескольких изменённых строк.\n\n| Пример | Сохранённые подходы | Основной |\n| --- | --- | --- |\n'
 for r in registry['records']:audit+='| '+r['id']+' | '+', '.join(v['id'] for v in r['variants'])+' | '+r['selected']+' |\n'
 audit+='\nH09 использует прямой iterateUntilStop, V02 — between. Их полные алгоритмы вынесены в ядро и сравнение реализаций; ни одного значения и проверки источника это не удаляет. Подготовленные/сырые occurrences H07 и lazy — разные подходы, поэтому оба сохранены. Небольшие варианты перечислены в [решениях](validation/dedup_decisions_20261123.json).\n\nHaskell использует аппликацию, композицию, foldM/replicateM, Data.Ix.inRange и Control.Monad.Loops.whileJust_. Каталог libraries содержит только сравниваемые реализации. Клиентский Cabal-компонент не добавляет этот каталог в hs-source-dirs.\n\n[Ожидания](expected_results.json), [реестр вариантов](variants.json), [размеры](validation/functional_receiver_counts.json). Исполнение LMX/GHC не заявляется.\n'
 (EX/'OPTIMIZATION_REVIEW.md').write_text(audit)
 readme=(EX/'README.ru.md').read_text();start=readme.index('## Редакция с общими ресиверами');end=readme.index('## Haskell',start)
 readme=readme[:start]+'''## Редакция с общими ресиверами и без малозначимых дублей

Общие функции входят в проект ядра и доступны прямо. H09 использует iterateUntilStop, V02 — between. Самостоятельные реализации LMX/Haskell сравниваются в library_comparisons; клиентам Haskell они не нужны. Полные альтернативы сохранены только для разных способов решения. H04, R01, V03 объясняют небольшие отличия в комментариях к основному варианту.

[Реестр](variants.json) · [Ожидания](expected_results.json) · [Аудит](OPTIMIZATION_REVIEW.md) · [Размеры](validation/functional_receiver_counts.json). Все 24 сценария и их наблюдения сохранены.

'''+readme[end:]
 readme=re.sub(r'runghc -[^\n]*Analogies.hs','cd haskell && cabal run lmx-analogy-clients',readme)
 (EX/'README.ru.md').write_text(readme)
 print(json.dumps({'selected':{i:v['id'] for i,v in selected.items()},'alternatives':sum(bool(r['alternative']) for r in registry['records']),'totals':counts['totals_all']},ensure_ascii=False))
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Sync the four actual LMX component bodies and audit their shared dependency cost."""
from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
import sys
sys.path.insert(0,str(ROOT.parent/'tools'))
from lmx_style_variants import measure as measure_full
from canonical_operations import definitions
LIB=ROOT.parent/'LMX_Fn_Receivers'
COMPANIONS={91:['FxRecordConstructor','FxRecordAdapterState','FxRecordAdapter','FxCaptureOne','FxBindOperandTail','FxBindChain','FxMaybeActive','FxMaybeBindOperand'],92:['FxRecordConstructor','FxRecordAdapterState','FxRecordAdapter','FxCaptureOne']}
SELECT={91:['FxMaybe','FxSome','FxNone','FxBind'],92:['FxBounce','FxDone','FxMore','FxTrampoline'],98:['FxAround'],99:['FxPartial']}
def canon(s):return s.strip()+'\n'
def metrics(s):
 m=measure_full(s)
 return {'characters':m['characters'],'lines':m['nonblank_lines'],'utf8_bytes':m['utf8_bytes']}
def blocks():
 return definitions(LIB)
def dependencies(names,available):
 seen=set();stack=list(names)
 while stack:
  name=stack.pop()
  if name in seen:continue
  if name not in available:continue
  seen.add(name)
  # FxThrows is a finite table of failure NAMES. A name such as FxPredicate
  # in that table is not a dependency on the same-spelled callable owner.
  # Count the complete shared table once, without linking unrelated bodies.
  refs=set() if name=='FxThrows' else set(re.findall(r'\b(?:Fx|Rx)[A-Za-z0-9_]+\b',available[name]['code']))
  stack.extend(refs-seen)
 return seen
def main():
 available=blocks();data=json.loads((ROOT/'patterns.json').read_text());by={p['id']:p for p in data['patterns']}
 report={'date':'2026-11-26','scope':'Production source definitions, static source/dependency accounting only. Kernel bridge declarations and native implementation cost are not represented as working LMX bodies.','components':[]}
 all_required=set();all_primary=set()
 for ident,names in SELECT.items():
  missing=set(names)-set(available)
  if missing:raise ValueError(missing)
  code='\n'.join(available[n]['code'] for n in names)
  listing=next(x for x in by[ident]['listings'] if x['language']=='LMX');by[ident]['variants']['LMX']['core']=code
  listing['code']=code
  closure=dependencies(names+COMPANIONS.get(ident,[]),available);shared=closure-set(names)
  all_required|=closure;all_primary.update(names)
  definitions=[{'name':n,'source':available[n]['source'],**metrics(available[n]['code']),'sha256':hashlib.sha256(available[n]['code'].encode()).hexdigest()} for n in sorted(closure)]
  unknown=sorted(set(re.findall(r'\b(?:Fx|Rx)[A-Za-z0-9_]+\b','\n'.join(available[n]['code'] for n in closure)))-set(available))
  rec={'id':ident,'primary_definitions':names,'primary':metrics(code),'shared_definitions':sorted(shared),'shared':metrics('\n'.join(available[n]['code'] for n in sorted(shared))),'external_or_failure_identifiers':unknown,'definitions':definitions}
  report['components'].append(rec)
  by[ident]['implementation_sources']=[{'source':'../LMX_Fn_Receivers/'+available[n]['source'],'definition':n} for n in names]
  listing['notes_ru']='Основной листинг — точные определения '+', '.join(names)+' из действующих исходников пакета. Публичные операции являются частью ядра; общие зависимости посчитаны отдельно в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Другая версия библиотеки для этого примера не выбирается. Сам этот фрагмент не объявлен самостоятельной реализацией ядра.'
  listing['notes_en']='The primary listing is the exact production definitions '+', '.join(names)+'. Public operations belong to the single core; shared dependencies are measured separately in the dependency ledger. No alternate library edition is selected. This component fragment is not presented as a standalone kernel implementation.'
  by[ident]['variant_notes']['LMX']['core']={k:v for k,v in listing.items() if k.startswith('notes_')}
 # The selected 085 curry client needs additional real LMX bodies. Account
 # them as an integer-ID usage companion without replacing the client listing.
 extra_names=['FxCurryState','FxLambdaMiddleEngine','FxLambdaStages','FxLambda']
 closure=dependencies(extra_names,available);shared=closure-set(extra_names)
 all_required|=closure;all_primary.update(extra_names)
 definitions=[{'name':n,'source':available[n]['source'],**metrics(available[n]['code']),'sha256':hashlib.sha256(available[n]['code'].encode()).hexdigest()} for n in sorted(closure)]
 code='\n'.join(available[n]['code'] for n in extra_names)
 unknown=sorted(set(re.findall(r'\b(?:Fx|Rx)[A-Za-z0-9_]+\b','\n'.join(available[n]['code'] for n in closure)))-set(available))
 report['components'].append({'id':85,'role':'usage_companion','publication':'CURRY_ADAPTER_VARIANT.md','primary_definitions':extra_names,'primary':metrics(code),'shared_definitions':sorted(shared),'shared':metrics('\n'.join(available[n]['code'] for n in sorted(shared))),'external_or_failure_identifiers':unknown,'definitions':definitions})
 by[85]['usage_implementation_sources']=[{'source':'../LMX_Fn_Receivers/'+available[n]['source'],'definition':n} for n in extra_names]
 report['unique_required_definitions']=sorted(all_required)
 report['unique_required_total']=metrics('\n'.join(available[n]['code'] for n in sorted(all_required)))
 report['unique_shared_excluding_all_primary']=metrics('\n'.join(available[n]['code'] for n in sorted(all_required-all_primary)))
 alias_paths=[p for p in (LIB/'src').glob('*.lmx') if re.search(r'^fun:\s*$',p.read_text(),re.M)]
 report['public_bundle']=[{'source':p.relative_to(LIB).as_posix(),**metrics(p.read_text()),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in alias_paths]
 (ROOT/'patterns.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
 (ROOT/'implementation_dependencies.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 lines=['# Полная стоимость общих зависимостей функциональных примеров',
        'Клиенты082–085 имеют две стилевые записи. Каждая общая реализация091/092/098/099 сохраняет одно точное LMX-тело. Здесь подсчитаны полные транзитивные определения ядра; объявления и Throws не исключаются.',
        '| ID | Основное тело | Общие зависимости | Полная сумма компонента |',
        '| --- | ---: | ---: | ---: |']
 for rec in report['components']:
  a=rec['primary']['characters'];b=rec['shared']['characters']
  lines.append(f"| {rec['id']:03d} | {a} | {b} | {a+b} |")
 total=report['unique_required_total']
 lines += ['',f"Все уникальные необходимые определения: **{total['characters']}** символов / **{total['lines']}** непустых строк. Между компонентами зависимости пересекаются: их нельзя повторно суммировать как разные реализации.",'',
           '## Публичная публикация','']
 for item in report['public_bundle']:
  lines.append(f"- [{item['source']}](../LMX_Fn_Receivers/{item['source']}): {item['characters']} символов. Общая таблица экспортов считается один раз.")
 lines += ['','## Реальная граница ядра','',
           '[KERNEL_REQUIREMENTS](../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [контракты](../LMX_Fn_Receivers/src/kernel_contracts.lmx) описывают отражение сигнатур, построение обычного DATA/CODE, подготовку вызова и выбранных мест без eager capture, lifetime результата и передачу failures. Native реализация этих мостов не объявляется работающей или бесплатной.',
           'Структуры используются непосредственно как последовательности ссылок на фактические типизированные записи. Плотный Array<T> читается через настоящий typed access и не переинтерпретируется как массив указателей. Служебные int для индексов/длин/флагов не ограничивают тип полезных данных.',
           'В099 все реализации поддерживают произвольный типизированный префикс, включая пустой/полный и void/Unit. Haskell использует Args/Callable, Scala — Tuple/Callable. LMX дополнительно сохраняет DATA/defaults и действующий binding-контекст; полная эквивалентность разных систем типов не заявляется.',
           'Функциональный клиент085 использует curry. [Его дополнительные тела](CURRY_ADAPTER_VARIANT.md) и зависимости явно подсчитаны один раз; процедурный клиент полностью показывает собственное окружение.',
           '','## Точные источники','']
 for rec in report['components']:
  lines.append('### '+f"{rec['id']:03d}")
  for item in rec['definitions']:
   lines.append(f"- `{item['name']}` — [{item['source']}](../LMX_Fn_Receivers/{item['source']}), {item['characters']} символов / {item['lines']} строк.")
  lines.append('Внешние границы и имена failures: '+', '.join('`'+n+'`' for n in rec['external_or_failure_identifiers'])+'.')
 lines += ['','## Воспроизведение','',
           '`python3 tools/sync_receiver_bodies.py` извлекает точные тела; `select_shortest.py` сохраняет обе клиентские формы, `regenerate_publication.py` обновляет публикацию. [Машинный реестр](implementation_dependencies.json). LMX runtime: NOT_RUN.']
 (ROOT/'IMPLEMENTATION_DEPENDENCIES.md').write_text('\n'.join(lines)+'\n')
 print(json.dumps({'components':len(report['components']),'unique_definitions':len(all_required),'total':total},ensure_ascii=False))
if __name__=='__main__':main()

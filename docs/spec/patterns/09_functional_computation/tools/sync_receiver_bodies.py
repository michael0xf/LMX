#!/usr/bin/env python3
"""Sync the four actual LMX component bodies and audit their shared dependency cost."""
from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[1]
LIB=ROOT.parent/'LMX_Fn_Receivers'
SELECT={91:['FxMaybe','FxSome','FxNone','FxBind'],92:['FxBounce','FxDone','FxMore','FxTrampoline'],98:['FxAround'],99:['FxPartial']}
def canon(s):return s.strip()+'\n'
def metrics(s):return {'characters':sum(not c.isspace() for c in s),'lines':sum(bool(x.strip()) for x in s.splitlines()),'utf8_bytes':len(s.encode())}
def blocks():
 found={}
 for path in sorted((LIB/'src').glob('*.lmx')):
  text=path.read_text()
  for chunk in text.split('\n\n'):
   match=re.search(r'^((?:Fx|Rx)[A-Za-z0-9_]+):[^\n]*\n',chunk,re.M)
   if match:
    body=canon(chunk[match.start():]);name=match.group(1)
    if name in found:raise ValueError('Duplicate production definition '+name)
    found[name]={'code':body,'source':path.relative_to(LIB).as_posix()}
 return found
def dependencies(names,available):
 seen=set();stack=list(names)
 while stack:
  name=stack.pop()
  if name in seen:continue
  if name not in available:continue
  seen.add(name)
  refs=set(re.findall(r'\b(?:Fx|Rx)[A-Za-z0-9_]+\b',available[name]['code']))
  stack.extend(refs-seen)
 return seen
def main():
 available=blocks();data=json.loads((ROOT/'patterns.json').read_text());by={p['id']:p for p in data['patterns']}
 report={'date':'2026-11-22','scope':'Production source definitions, static source/dependency accounting only. Kernel bridge declarations and native implementation cost are not represented as working LMX bodies.','components':[]}
 all_required=set();all_primary=set()
 for ident,names in SELECT.items():
  missing=set(names)-set(available)
  if missing:raise ValueError(missing)
  code='\n'.join(available[n]['code'] for n in names)
  listing=next(x for x in by[ident]['listings'] if x['language']=='LMX');by[ident]['variants']['LMX']['core']=code
  listing['code']=code
  closure=dependencies(names,available);shared=closure-set(names)
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
 lines=['# Стоимость общих зависимостей функциональных примеров','Редакция 2026-11-22. Текущие общие тела ядра 091/092/098/099 извлечены непосредственно из [пакета ресиверов](../LMX_Fn_Receivers/README.md). Пример использования не оплачивает библиотеку при каждом обращении; сама библиотека также не объявляется бесплатной.','## Что входит в числа','Первичная таблица сравнения содержит клиент или собственное тело компонента. Эта таблица добавляет транзитивно вызываемые LMX-определения. Каждое определение считается целиком один раз внутри своей строки: Unicode-символы без пробелов и непустые строки; комментарии внутри определения включены. Между строками общие определения пересекаются, поэтому складывать столбец зависимостей без устранения повторов нельзя.','| ID | Основное тело, символы / строки | Общие LMX-зависимости, символы / строки | Сумма внутри компонента |\n| ---: | ---: | ---: | ---: |']
 for rec in report['components']:
  a=rec['primary'];b=rec['shared']
  lines[-1]+=f"\n| {rec['id']:03d} | {a['characters']} / {a['lines']} | {b['characters']} / {b['lines']} | {a['characters']+b['characters']} / {a['lines']+b['lines']} |"
 total=report['unique_required_total']
 lines+=['Все перечисленные реализации, включая companion curry для 085, с устранением повторов: **'+str(total['characters'])+' непробельных символов / '+str(total['lines'])+' непустых строк**. Это исходники выбранного набора определений, не размер бинарника или всего runtime.','## Публичный набор имён']
 if report['public_bundle']:
  for a in report['public_bundle']:lines.append(f"- [{a['source']}](../LMX_Fn_Receivers/{a['source']}): {a['characters']} символов / {a['lines']} строк. Общая таблица открывает все публичные имена; её следует считать один раз при загрузке полного набора.")
 else:lines.append('Публичный alias bundle должен быть синхронизирован перед окончательной публикацией; повторно запустить этот инструмент после его добавления.')
 lines+=['## Интерфейсы ядра и границы обобщения','[KERNEL_REQUIREMENTS](../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md) и [контракты](../LMX_Fn_Receivers/src/kernel_contracts.lmx) описывают требуемое семантическое отражение, построение обычного DATA/CODE, обычную подготовку вызова и выбранных мест без eager capture, время жизни результата и передачу failures. Реализация этих интерфейсов не приложена в виде работающего ядра и не получает фиктивный нулевой размер. Подсчёт выше включает алгоритмы, действительно написанные на LMX; для полного системного сравнения добавляется реализация provider и runtime каждого языка.','Структуры используются непосредственно как Array<@>: префикс partial, actuals, списки и последовательности результатов не требуют отдельного поля items. Плотный Array<T> принимается через фактический typed access; он не переинтерпретируется как вектор указателей. Метки состояния контейнеров, индексы и коды типов закономерно имеют тип int; полезные типы и арность этим не ограничены.','В Haskell и Scala обычные вызовы, lambda, generic-типы и исключения являются инфраструктурой языка; их компиляторы и runtime также не входят в размеры листингов. У 099 общий проверяемый случай — A×B→R с привязкой первого аргумента. LMX реализует более широкий произвольный префикс N входов, включая k=0,k=N и void; один итоговый коэффициент «выигрыша» для этих неодинаковых возможностей не строится.','Сценарий 085 также имеет допустимый короткий вариант curry. Его полные тела и отдельный реестр дополнительных зависимостей приведены в [CURRY_ADAPTER_VARIANT.md](CURRY_ADAPTER_VARIANT.md); они не скрыты внутри цены одного partial.','## Точные определения и ссылки']
 for rec in report['components']:
  lines.append('### '+f"{rec['id']:03d}")
  lines.append('Основное тело: '+', '.join('`'+n+'`' for n in rec['primary_definitions'])+'.')
  lines.append('\n'.join(f"- `{x['name']}` — [{x['source']}](../LMX_Fn_Receivers/{x['source']}), {x['characters']} символов / {x['lines']} строк." for x in rec['definitions'] if x['name'] in rec['shared_definitions']))
  lines.append('Внешние интерфейсы и имена failures: '+', '.join('`'+x+'`' for x in rec['external_or_failure_identifiers'])+'.')
 lines+=['## Воспроизводимость','`python3 tools/sync_receiver_bodies.py` извлекает тела и строит этот реестр; `python3 tools/select_shortest.py` выбирает короткий допустимый алгоритм текущего контракта; `python3 tools/regenerate_publication.py` синхронизирует тексты и показатели. Полный машинный отчёт со SHA-256 каждого определения: [implementation_dependencies.json](implementation_dependencies.json). Ни один из этих инструментов не исполняет LMX.']
 (ROOT/'IMPLEMENTATION_DEPENDENCIES.md').write_text('\n\n'.join(x for x in lines if x)+'\n')
 print(json.dumps({'components':len(report['components']),'unique_definitions':len(all_required),'total':total},ensure_ascii=False))
if __name__=='__main__':main()

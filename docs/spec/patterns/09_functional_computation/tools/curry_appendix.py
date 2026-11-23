#!/usr/bin/env python3
"""Account for the current core curry alternative; no language execution."""
from pathlib import Path
import json,importlib.util,hashlib
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('body_sync',Path(__file__).with_name('sync_receiver_bodies.py'))
mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
available=mod.blocks();names=['FxCurryState','FxLambdaMiddleEngine','FxLambdaStages','FxLambda'];closure=mod.dependencies(names,available)
base=json.loads((ROOT/'implementation_dependencies.json').read_text())
partial_component=next(r for r in base['components'] if r['id']==99)
partial={definition['name'] for definition in partial_component['definitions']}
extra=closure-partial
p=next(x for x in json.loads((ROOT/'patterns.json').read_text())['patterns'] if x['id']==85)
report={'scope':'source/dependency accounting only; no runtime proof','runtime_executed':False,'primary_definitions':names,'all_required_definitions':sorted(closure),'additional_to_partial_definition_closure':sorted(extra),'all_required':mod.metrics('\n'.join(available[n]['code'] for n in sorted(closure))),'additional_to_partial':mod.metrics('\n'.join(available[n]['code'] for n in sorted(extra))),'variants':{n:mod.metrics(code) for n,code in p['variants']['LMX'].items() if n in p['eligible_variants']['LMX']},'sources':[{'name':n,'path':'../LMX_Fn_Receivers/'+available[n]['source'],'sha256':hashlib.sha256(available[n]['code'].encode()).hexdigest(),**mod.metrics(available[n]['code'])} for n in sorted(closure)]}
(ROOT/'curry_dependencies.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
lines=['# Curry: дополнительный общий механизм рядом с примером 085','Это исходники того же текущего ядра, а не ещё одна версия библиотеки. Клиент 085 выбирает две независимые ветви одного `curry(Addition\\apply)` вместо двух `partial`; старый корректный partial-вариант и прежний процедурный пример сохранены рядом.','## Сценарий и граница сравнения','Сохраняются add5, add100, переменная saved=1000, повторный вызов add5 и весь результат 6101006. Только способ построения двух closures заменён на общий поэтапный adapter. Haskell/Scala по-прежнему используют показанные соседние generic capture-компоненты; дополнительная универсальность LMX не объявляется бесплатной или тождественной по реализации.','| Допустимый LMX-клиент | Непробельные символы | Непустые строки |\n| --- | ---: | ---: |']
for n,m in report['variants'].items():lines[-1]+=f"\n| [{n}](examples/lmx/variants/085_currying_{n}.lm3) | {m['characters']} | {m['lines']} |"
lines+=['## Полные дополнительные тела','Общие policy, builder, capture и runtime уже приведены в [реестре](IMPLEMENTATION_DEPENDENCIES.md) и [пакете ресиверов](../LMX_Fn_Receivers/ADAPTER_IMPLEMENTATION.md). Ниже показаны все собственные тела curry. Они извлекаются непосредственно из действующего source, а не сокращаются до необъяснённого native вызова.']
for n in names:lines+=['### '+n,'[Источник](../LMX_Fn_Receivers/'+available[n]['source']+').','```lmx\n'+available[n]['code']+'```']
lines+=['## Стоимость общих зависимостей',f"Полное транзитивное множество curry: **{report['all_required']['characters']}** непробельных символов / **{report['all_required']['lines']}** непустых строк. Дополнительно к уже раскрытому closure partial из строки 099: **{report['additional_to_partial']['characters']}** символов / **{report['additional_to_partial']['lines']}** строк. Эти числа не следует прибавлять к клиенту при каждом вызове: это стоимость общей реализации один раз. Интерфейсы FxKernel и реальный runtime остаются отдельной известной границей, а не имеют выдуманную нулевую стоимость.",'| Дополнительное определение | Источник | Символы | Строки |\n| --- | --- | ---: | ---: |']
for n in sorted(extra):
 a=available[n];m=mod.metrics(a['code']);lines[-1]+=f"\n| `{n}` | [{a['source']}](../LMX_Fn_Receivers/{a['source']}) | {m['characters']} | {m['lines']} |"
lines+=['## Проверка','Ни один LMX runtime здесь не запускался. Источник требует пяти обычных call-phase hooks, указанных в KERNEL_REQUIREMENTS, и полного A/B acceptance. Счётчики символов — воспроизводимая проверка публикации, не проверка семантики или скорости. Машинный реестр: [curry_dependencies.json](curry_dependencies.json). Для обновления после source changes: `python3 tools/curry_appendix.py`.']
(ROOT/'CURRY_ADAPTER_VARIANT.md').write_text('\n\n'.join(lines)+'\n')
print(json.dumps({'extra_definitions':len(extra),'client_metrics':report['variants'],'extra_chars':report['additional_to_partial']['characters']},ensure_ascii=False))

#!/usr/bin/env python3
"""Account once for the canonical curry machinery used by the functional style."""
from pathlib import Path
import json,importlib.util,hashlib,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'tools'))
from lmx_style_variants import measure
spec=importlib.util.spec_from_file_location('body_sync',Path(__file__).with_name('sync_receiver_bodies.py'))
mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
available=mod.blocks();names=['FxCurryState','FxLambdaMiddleEngine','FxLambdaStages','FxLambda'];closure=mod.dependencies(names,available)
base=json.loads((ROOT/'implementation_dependencies.json').read_text())
partial={d['name'] for row in base['components'] if row['id']==99 for d in row['definitions']};extra=closure-partial
row=next(x for x in json.loads((ROOT/'patterns.json').read_text())['patterns'] if x['id']==85)
report={'scope':'source/dependency accounting only; no runtime proof','runtime_executed':False,
        'primary_definitions':names,'all_required_definitions':sorted(closure),'additional_to_partial_definition_closure':sorted(extra),
        'all_required':measure('\n'.join(available[n]['code'] for n in sorted(closure))),
        'additional_to_partial':measure('\n'.join(available[n]['code'] for n in sorted(extra))),
        'variants':{s:v['metrics'] for s,v in row['lmx_variants'].items()},
        'sources':[{'name':n,'path':'../LMX_Fn_Receivers/'+available[n]['source'],**measure(available[n]['code'])} for n in sorted(closure)]}
(ROOT/'curry_dependencies.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
lines=['# Curry: общая реализация функционального клиента085',
       'Процедурный клиент полностью показывает сохранённые окружения; функциональный строит две независимые ветви общего curry. Оба клиента считаются полностью и сравниваются с теми же неизменёнными Haskell/Scala программами. Одно ядро обслуживает функциональную форму; второй реализации curry ради стиля нет.',
       '## Полные клиенты','| Стиль | Символы | Строки |','| --- | ---: | ---: |']
for style,variant in row['lmx_variants'].items():
    m=variant['metrics'];lines += [f"| [{style}]({variant['source_file']}) | {m['characters']} | {m['nonblank_lines']} |"]
lines += ['','Все объявления и Throws входят в размер. Сохраняются add5/add100, saved=1000, повторное применение add5 и результат6101006.','',
          '## Полные общие тела','Общие policy, builder, capture и runtime указаны в [реестре](IMPLEMENTATION_DEPENDENCIES.md). Ниже извлечены точные тела того же ядра.']
for name in names:lines += ['', '### '+name,'',f"[Источник](../LMX_Fn_Receivers/{available[name]['source']})",'','```lmx',available[name]['code'].rstrip(),'```']
lines += ['','## Полная стоимость зависимостей','',
          f"Уникальное транзитивное множество curry: **{report['all_required']['characters']}** символов. Дополнительно к partial из099: **{report['additional_to_partial']['characters']}** символов. Общие определения считаются один раз; стоимость native FxKernel и runtime не объявляется нулевой.",'',
          '| Дополнительное определение | Источник | Символы | Строки |','| --- | --- | ---: | ---: |']
for name in sorted(extra):
    item=available[name];m=measure(item['code']);lines += [f"| `{name}` | [{item['source']}](../LMX_Fn_Receivers/{item['source']}) | {m['characters']} | {m['nonblank_lines']} |"]
lines += ['','## Проверка','','Это проверка наличия исходников и их полного размера. Runtime LMX: NOT_RUN. [Машинный реестр](curry_dependencies.json).']
(ROOT/'CURRY_ADAPTER_VARIANT.md').write_text('\n'.join(lines)+'\n')
print(json.dumps({'extra_definitions':len(extra),'client_metrics':report['variants'],'runtime':'NOT_RUN'}))

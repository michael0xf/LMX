#!/usr/bin/env python3
"""Rebuild four receiver comparisons from actual LMX roots and Haskell sources.

This is publication synchronization, not an LMX compiler or an effect checker.
The transitive root-definition closure is deliberately conservative: references
inside generated body strings are included. FxKernel/system primitives are the
explicit provider boundary, not fabricated library implementations.
"""
from pathlib import Path
import re,json,hashlib
ROOT=Path(__file__).resolve().parents[2]
EX=ROOT/'examples'
LIB=ROOT/'LMX_Fn_Receivers'
CONFIG=[
 ('h01_apply_comparision.md','Apply: общий вызов по контейнеру аргументов','H01','apply','FxApply','IntApply.hs','libraries/lmx/Application.lm3',
 'У LMX вход `args` — любая допустимая последовательность по @, включая плотный Array и обычную Structure/@[]. Штатный транспорт читает фактический тип каждого actual, без reinterpretation и предварительного boxing всей последовательности. Результат — запись с реальным типом. Передаются только присутствующие actuals; собственные defaults, required/private и точный результат выбранного callable сохраняются. FxKernel\\attempt открывает штатное исполнение call/catch; библиотечное тело apply оборачивает полученный отказ в FxCallFailure.',
 'Haskell apply полиморфен по a и b. У Haskell последовательная аппликация и каррирование уже являются механизмами языка; эта запись не заявляет отдельный динамический вектор аргументов. Клиентский сценарий одинаков: вызов выбранного действия и замена выбранной ссылки.'),
 ('h03_capture_comparision.md','Partial: общий префикс аргументов','H03','partial','FxPartial','Partial.hs','libraries/lmx/ProceduralCapture.lm3',
 'partial принимает callable с N входами и K готовыми значениями любого подходящего Array через @. Построенный callable имеет N−K остаточных позиций и точный исходный результат R; реальные defaults и required/private исходных деклараций сохраняются, а не заменяются обязательностью всех p0…. K=0 и K=N допустимы; полный префикс создаёт отложенный nullary-callable. Новая функция не исполняет цель при создании. Примитивы захватываются по значению, ссылки сохраняют идентичность цели.',
 'В Haskell partial связывает первый вход уже каррированной функции. Полиморфные a/b/r не фиксируют Int; r само может быть функцией. Для нескольких исходных аргументов Haskell повторяет обычную аппликацию, тогда как LMX принимает явный вектор префикса. Числа 5 и 100 принадлежат клиенту.'),
 ('h06_pipe_comparision.md','Pipe: сохраняемая композиция точных сигнатур','H06','pipe','FxPipe','IntPipe.hs','../../02_architecture_and_boundaries/examples/lmx/093_pipe_implementation.lm3',
 'pipe(first; second) создаёт callable без исполнения стадий. Его входы и их политика совпадают со входами first; second получает один явный actual с результатом first и может иметь дополнительные допустимые optional/default входы. Промежуточный и конечный типы могут отличаться. Сохранённый callable выполняет стадии один раз и в записанном порядке. Два компонента — смысл бинарной композиции, не ограничение арности исходной функции.',
 'pipe2 и pipeIO2 показывают общую композицию a→b→c. Для прежних проверок полностью сохранены также pipe/pipeIO по списку однородных стадий; их типы стали полиморфными. IO-вариант задаёт порядок эффектов, чистый вариант не выдаётся за IO-действие.'),
 ('h07_evaluation_modes_comparision.md','Lazy: общий отложенный результат и повтор эффектов','H07','lazy','FxLazy','Lazy.hs','libraries/lmx/EvaluationModes.lm3',
 'lazy готовит обычный вызов без явных actuals и сохраняет точный тип результата; отсутствие actuals не означает искусственного запрета дополнительных optional/default формалов. До первого исполнения цель не вызывается; успешный результат кешируется, отказ оставляет возможность повторить попытку. Повторный вход в вычисляющийся thunk даёт FxLazyCycle. Здесь один владелец Message; потокобезопасный разделяемый между Message кеш не обещается.',
 'lazyIO — явная общая реализация на IORef для одного потока: Cold/Busy/Ready, сброс после ошибки и вычисление результата до WHNF. Она не объявляется атомарным многопоточным кешем. Void LMX и () Haskell имеют разные представления. Прежний prepared/raw пример сохранён отдельно: lazy не выдаётся за доступ к исходным LMX-occurrences.')
]

def metric(text):
 text=text.rstrip()+'\n'
 return {'characters':sum(not c.isspace() for c in text),'nonblank_lines':sum(bool(x.strip()) for x in text.splitlines()),'utf8_bytes':len(text.encode()),'sha256':hashlib.sha256(text.encode()).hexdigest()}

def root_definitions():
 definitions={};locations={}
 for p in sorted((LIB/'src').glob('*.lmx')):
  # Legacy/specialized examples are excluded; current universal collections are eligible dependencies.
  if p.name in ['functions_specialized.lmx','wrappers.lmx','kernel_contracts.lmx','public.lmx']:continue
  text=p.read_text()
  for block in re.split(r'\n[ \t]*\n',text):
   lines=block.splitlines()
   while lines and (not lines[0].strip() or lines[0].lstrip().startswith('#')):lines.pop(0)
   if not lines:continue
   found=re.match(r'^(?:independent: )?([A-Za-z_][A-Za-z_0-9]*):\s*$',lines[0])
   if not found:continue
   name=found.group(1)
   definitions[name]='\n'.join(lines).rstrip()+'\n';locations[name]=p.relative_to(ROOT).as_posix()
 return definitions,locations

def closure(start,definitions):
 seen=set();ordered=[]
 def visit(name):
  if name in seen:return
  if name not in definitions:raise ValueError('Missing source root '+name)
  seen.add(name)
  # Keep full generated-code strings; only standalone comments are omitted for references.
  code='\n'.join(x for x in definitions[name].splitlines() if not x.lstrip().startswith('#'))
  references=set(re.findall(r'\b(?:Fx|Rx)[A-Za-z_0-9]+\b',code))
  for dep in sorted(references):
   if dep!=name and dep in definitions:visit(dep)
  ordered.append(name)
 visit(start)
 return ordered

def old_listing(pathname):
 p=(EX/'library_comparisons'/pathname).resolve()
 if pathname.startswith('../../'):return p.read_text()
 return (EX/pathname).read_text()

def main():
 definitions,locations=root_definitions();rows=[]
 for filename,title,ident,public,entry,haskellfile,oldfile,contract,control in CONFIG:
  roots=closure(entry,definitions)
  body='\n'.join(definitions[n].rstrip() for n in roots)+'\n'
  # Physical blank line between roots is mandatory in these LMX sources.
  body='\n\n'.join(definitions[n].rstrip() for n in roots)+'\n'
  haskell=(EX/'libraries/haskell'/haskellfile).read_text()
  old=old_listing(oldfile)
  measured=metric(body);hm=metric(haskell);om=metric(old)
  paths=sorted({locations[n] for n in roots})
  sources='\n'.join('- ['+Path(p).name+'](../../'+p+')' for p in paths)
  primary=(EX/'lmx'/f'{ident}.lm3').read_text().split('# BEGIN ALTERNATIVE LMX (excluded from character counts)')[0].split('# BEGIN PROCEDURAL LMX (excluded from character counts)')[0].rstrip()+'\n'
  text=f'''# {title}

Редакция: 22 ноября 2026 года. Клиент: [{ident}](../lmx/{ident}.lm3), [разбор](../../LMX_examples_and_analogies.ru.md#{ident.lower()}).

## Контракт общего ресивера

{contract}

Публичный ресивер `{public}` уже входит в единое текущее ядро и используется прямо. Никаких import или выбираемых версий библиотек нет. Внутренние Fx/Rx-имена ниже обозначают структуры реализации ядра.

Этот документ показывает исходники общего ядрового механизма и локального процедурного приёма. Это разные области контракта, а не две взаимозаменяемые версии ядра: специализированный приём не подменяет весь общий API только потому, что он короче. Основной клиент выбирается отдельно из корректных вариантов по полной длине и границе учёта, см. {ident}.

## Полный алгоритм ресивера ядра LMX

Ниже приведено консервативное замыкание по корневым LMX-определениям от `{entry}`: полные определения перечислены один раз, включая те, которые упомянуты в генерируемом тексте тела. Это видимый исходник текущего ядра; он не подменяется строкой импорта. Общие определения повторно используются другими receivers; одинаковые определения не считаются новой самостоятельной реализацией для каждого клиента.

{sources}

```lmx
{body.rstrip()}
```

Явная граница ядра: `FxKernel`, системные примитивы и стандартные вызовы, описанные в [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). Это требуемые адаптеры к штатным операциям графа/вызова, а не показанный здесь C-код готового ядра. Их реализация не спрятана в цифре «размер библиотеки»: статус и условия приёмки приведены отдельно. Полный [собранный файл](../../LMX_Fn_Receivers/LMX_Receivers.lmx) и [экспорт имён](../../LMX_Fn_Receivers/src/public.lmx) находятся рядом.

## Реализация Haskell

{control}

[Точный исходник модуля](../libraries/haskell/{haskellfile}):

```haskell
{haskell.rstrip()}
```

## Процедурный механизм сценария на том же ядре

Этот обычный пользовательский код показывает явный механизм конкретного сценария. Его int-специализация не является ограничением общего core-ресивера. Он не заменяет весь общий контракт ядра и не является старой библиотечной версией. У клиента он считается, если включён в его выбранный исходник; в таблице ниже его стоимость показана отдельно.

```lmx
{old.rstrip()}
```

## Размеры и границы сравнения

| Показанный код | Непробельные символы | Непустые строки | UTF-8 байты |
| --- | ---: | ---: | ---: |
| LMX: алгоритм и перечисленные LMX-зависимости | {measured['characters']} | {measured['nonblank_lines']} | {measured['utf8_bytes']} |
| Haskell: весь показанный модуль | {hm['characters']} | {hm['nonblank_lines']} | {hm['utf8_bytes']} |
| LMX: процедурный механизм сценария, отдельный контракт | {om['characters']} | {om['nonblank_lines']} | {om['utf8_bytes']} |

Это механические размеры показанных исходников. LMX строит обычные графовые callable с точными сигнатурами; Haskell пользуется собственным типовым и функциональным runtime. Таблица не утверждает равенства стоимости их ядер, минимальности замыкания зависимостей или одинаковой реализации. Реализация ядра показана отдельно от клиента. Исключать её из конкурентного клиентского сравнения допустимо при сопоставимом встроенном/библиотечном/операторном механизме у контроля, либо как естественный механизм языка без скрытого предметного алгоритма. Архитектуры не обязаны совпадать; поля, состояние, копии, идентичности и эффекты обязаны сохраняться. Сравнение по клиентам и исходные сохранённые хеши — в [functional_receiver_counts.json](../validation/functional_receiver_counts.json).

**Проверка:** текст, ссылки и размеры воспроизводятся [скриптом](../tools/update_receiver_comparisons.py). LMX и GHC здесь не запускались; подготовленные assertions в [Analogies.hs](../haskell/Analogies.hs) не являются receipt исполнения.
'''
  (EX/'library_comparisons'/filename).write_text(text)
  rows.append({'file':'library_comparisons/'+filename,'entry':entry,'public':public,'roots':roots,'source_files':paths,'lmx':measured,'haskell':hm,'haskell_source':'libraries/haskell/'+haskellfile,'comparison_scope':'current_core_receiver_contract','eligible_variants':['generic_core'],'procedural_is_client_algorithm_reference':True,'procedural_metrics':metric(old),'core_versions':1,'kernel_provider_excluded_and_disclosed':True})
 report={'format':'receiver-library-comparisons-v1','status':'publication_consistency_not_execution','date':'2026-11-22','source_method':'conservative transitive closure of whole source roots, including names in generated body strings; FxKernel providers explicitly excluded','comparisons':rows}
 (EX/'validation/receiver_library_counts.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'comparisons':len(rows),'roots':[len(x['roots']) for x in rows]},ensure_ascii=False))
if __name__=='__main__':main()

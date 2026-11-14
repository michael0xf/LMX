# M11/M14: место объявления и неоднозначное имя

2026-11-14. Исследование Run/GraphTool при WIP388 после принятого387/9897c99f и последующее уточнение ролей389.
Исходное исследование не меняло код, тесты, index или сборки. Строки маршрутов ниже — по WIP388;
это не дополнительная норма. Реализация389 и текущие gates вынесены в
[свидетельство](../witnesses/m11-place-sites-20261114/notes.md): private36/G2 repeat36 и whole quick прошли;
docs-check прошёл, final index/commit завершаются. Кандидат ниже — история выбора общего механизма389, не новая очередь реализации.

**Уточнение contract audit перед389; прежнее formal-first для CODE declaration отменено.**
Implementation **OPEN**; baseline ещё выполняется root. Следующие правила и числовые оракулы — требования
к реализации, а не полученные результаты.

- CODE receiver declaration `int`/`@` выбирает только сопоставленное место выбранной DATA. Formal или
  dynamic input не заменяет это место. При `holder == frame.data` известен точный физический self-slot;
  наличие одноимённого formal этот identity-case не меняет. Inline CodeBody пользуется DATA текущей
  активации и не создаёт место в собственном holder.
- Bare WORD read/assignment сохраняет formal-first lookup. DATA work row не должна затенять
  `activation.refs`. Наличие двух DATA-x не отменяет formal x, но без formal голое x неоднозначно;
  явное `data\x` при двух вхождениях неоднозначно независимо от formal.
- DATA initialization — отдельная роль: `data_declaration(root,index)` инициализирует свой физический
  slot даже при одноимённом formal. Она не записывает formal по совпадению имени.
- Для Code над другой D source-index/ordinal нельзя переносить в D: два CODE объявления x используют
  единственный допущенный D.x, тогда как self DATA содержит два разных физических x.
  После RHS нельзя повторно выбирать destination writer-ом с другим правилом.
- Подготовка method DATA включает явный CODE declaration site и при совпадении его имени с formal.
  В цепочке `fn_own` → `fn_data` нельзя отбрасывать такой site только из-за имени в args. Поле требует
  именно CODE declaration; одно bare употребление formal или dynamic input DATA-поля не создаёт.

Основания: [книга, части метода](../../provenance/semantics-book.md#method-parts), строки875/877:
CODE declaration — требование к выбранной DATA; её собственные места добавляются при предварительной
подготовке метода. [Рабочее состояние](../../provenance/semantics-book.md#dynamic), строка1095,
и [L2 §11/§18](../../docs/L2_spec_ru.md) отделяют formal activation cell от DATA и задают DATA-назначение
CODE declaration. Старое argument-as-own-cache исключение из OLD сюда не переносится.

Дополнительная будущая приёмка (ещё не выполнялась):

- D=(seen0,pad99,x10), Code=(seen:=x; int:x2; int:x3), caller x90: после call(D;Code)
  получить seen10/x3/pad99/caller90, независимо от physical slot order.
- Args=(x5), Self=(x2,x3,seen0; x:=x+1; seen:=x): call(Args;Self;Self) сохраняет Args.x5
  и physical Self.x2/x3, а seen даёт6: CODE declarations пишут свои DATA-sites, затем bare assignment
  увеличивает formal текущей активации с5 до6. `data\x` остаётся неоднозначным.
- f с formal x, actual7 и явной data.x100, CODE int:x2; return:x: result7/data.x2/caller7.
- Тот же f с CODE x:=2; return:x: result2/data.x100/caller7 — bare store меняет formal, а не DATA.
- У f без явного DATAx, но с formal x и CODE int:x2 предварительно создаётся собственное DATA-место:
  при actual7 результат7, после публикации DATAx2. CODE initializer заранее не исполняется.
- Для обычного call(Args;D;Code) с Args.x7, CODE int:x2 и без DATAx в D — отказ до тела;
  formal не удовлетворяет DATA-требование и не вызывает автозаполнение произвольной D.
- Self=(pad90,x1,seen0; if:1(int:x7); seen:=x): pad90/x7/seen7 без нового scope-data.

## Требование и подтверждённый отказ

[root_occurrence_index.lm2](../../selfbuild/tests/graph/root_occurrence_index.lm2):

```text
int: x 2
int: x 3
int: seen data\[1]x
```

Ожидается успешное исполнение и `seen = 3`; оба DATA-вхождения сохраняются.
Root сообщил runtime3 как на seed387, так и на новом388. Это OPEN реализации,
а не повод менять ожидаемое значение или оборачивать программу в другой callable.
[root_repeat_refused.lm2](../../selfbuild/tests/graph/root_repeat_refused.lm2) с голым
`seen x` должен по-прежнему отказывать3: имя двух DATA-вхождений неоднозначно.

Норма — [имена и пути](../../docs/LMX_semantics.ru.md#fields),
[роли data/code](../../provenance/semantics-book.md#data-code-roles),
[публикация](../../provenance/semantics-book.md#direct-access-cache).
Root и обычная Structure над собой используют общие правила. Нельзя пропускать их
объявления, выбирать первое одноимённое место либо вводить root-specific ветвь.

## Точная причина и существующая карта

В [Run](../../selfbuild/src/l2src/lmx_graph_run.lm2):

- `work_open_data:1060` для обычной Structure вызывает `work_open_parts` с `model = 0`.
  Рабочие строки появляются при сканировании используемого тела.
- `work_scan_body:524` для первого именованного int вызывает `work_require(name=x)`.
  В `work_require:404` `data_slot` выбирает slot0, но `data_twice` обнаруживает второе x
  и возвращает3. Отказ происходит **до чтения occurrence-selector**.
- Если убрать лишь этот отказ, `block_body:2943/2945` всё равно вызывает
  `local_int(name)` и `store_name(name)`: адрес текущего объявления потерян.
  `work_row:36` сейчас возвращает первую строку имени; так нельзя представлять
  разные DATA-вхождения.

Уже есть один настоящий кадр и его карта: `frame.code/data/args/body/lexical_scope`,
`frame.rows/count/capacity`; строка содержит `name`, физический `slot` выбранной data,
`cell`, `expected_kind`, рабочее `number`, `loaded`, `dirty`. `slot = -1` обозначает
вход со своим локальным значением. Это и надо использовать; отдельная карта объявлений,
новый registry, журнал присваиваний, копия графа или фиктивная activation не нужны.

## Минимальный общий следующий код

1. Выделить внутреннее связывание **физического slot выбранной data** с существующей
   рабочей строкой. Повторное связывание того же slot использует ту же строку; два
   разных slot могут иметь одинаковое имя. Сохранить нынешние проверки типа,
   `data_cell`, deferred/uninit различие и отсутствие чтения старого payload при
   write-only доступе. `work_require(name)` остаётся запросом единственного имени
   и после прежней проверки однозначности использует тот же slot-binder.
2. Общий reader места объявления получает явные `holder, index` потребляемого поля,
   а не только canonical name. Когда `holder == frame.data`, это уже точный физический
   self-slot `index`: выбор не требует поиска имени. Это обычный identity-case карты,
   одинаковый для root и любой Structure над собой, **не исключение для root**.
   В остальных случаях использовать соответствие к выбранной data: нынешнюю
   однозначную строку/именную проекцию или общий admission-map, когда он реализован.
   Нельзя считать source-index индексом другого D, выбирать N-е поле кандидата по
   собственной новой эвристике или создавать недостающий slot. Не доказанное
   соответствие остаётся отказом; полный used-interface map ещё OPEN в M11.7.
3. Разделить запрос строки по месту и запрос по голому имени. Bare lookup должен
   сначала учитывать formal текущей активации, затем сохранять неоднозначность DATA:
   если formal нет, наличие двух физических строк имени не даёт права вернуть первую
   или уйти к внешнему fallback. Уже существующая DATA row не затеняет formal.
   Сохранить общий приоритет formal/data/dynamic/lexical и проверки `data_find`, а не
   выводить однозначность только из случайного подмножества загруженных строк.
   Этот приоритет не применяется к CODE declaration site или DATA initializer:
   у них уже определена роль назначения, и formal lookup не заменяет DATA map.
4. Проверка и запись объявления используют выбранную строку. Возможные публичные
   helpers — аналоги `local_int`/`store_name` с `holder,index`; конкретные имена не
   являются требованием. Запись меняет прежнее рабочее значение и dirty этой строки,
   а `work_flush:879` публикует её через `frame.data,row.slot`. Не подменять её
   `store_field`: тот обслуживает явный прямой доступ и пишет граф, не локал кадра.
   Обычный `x := ...` остаётся bare записью: при formal x меняет его локальную ячейку,
   а при двух DATA-x и отсутствии formal отказывает. Явный путь `data\x` не выбирает formal.

Это сохраняет различие: два DATA-объявления x — разные места; повтор `int:x` в CODE
метода или inline-body — запись в одно уже сопоставленное место data, без нового поля.
Для исполнения обычного Code над другим D место выбирается общей картой, независимо
от перестановки полей D; self-case не должен становиться единственным работающим путём.

## Точные routes, которые менять совместно

### Scanner и обходчик

- `lmx_graph_fn_own`/`lmx_graph_fn_own_body` → `lmx_graph_fn_data`: подготовка own DATA
  включает явные CODE int/@ sites и при одноимённом formal. Если такого поля нет в
  явной DATA метода, создать его общим предварительным построением, не исполняя RHS.
  Не создавать поле из одного formal, dynamic input или bare assignment.
- `work_scan_body:524`: точные `body,i` доступны до постановки поля в очередь.
  Именованные materialized int/ref/uninit-поля связывать как declaration sites.
  Retained primitive declarations `int`/`@` также подготовить здесь через общий
  declaration-view и site-reader; не исполнять initializer.
- `work_scan_context:708`: у retained `int`/`@` сейчас вновь выполняется
  `work_require`/`work_capture` по имени. После подготовки site нельзя повторно
  превращать его в bare lookup. Имя аргумента0 по-прежнему не input; RHS сканируется
  по прежним receiving contracts. Для очереди не восстанавливать holder изменением
  `parent`: выбирать declaration place в `work_scan_body`, где holder/index известны.
- `block_body:2943/2945`: materialized int/uninit declaration проверяет/пишет site,
  сохраняя чтение текущего literal из графа при каждом достижении.
- `block_body:3177/3187`: retained `int:name expression` использует тот же site до
  вычисления RHS и для записи после него. `body,i` уже есть в этом цикле.
- Reference-ветки `block_body:3145` и далее также должны пользоваться общим выбором
  declaration place; нынешние `known_place(name)`/`store_reference(name)` теряют site.
  Типизированный writer и snapshots ссылок остаются прежними. Не вводить int-only
  особое правило повторов, выдаваемое за полный механизм объявлений.
- `data_declaration:3673` уже получает `root,index`; собственная data-фаза метода
  сохраняет свой контракт и прямое адресование своего поля, включая совпадение имени
  с formal. Не направлять её через bare writer и не запускать эту фазу у произвольной
  поданной D ради связывания карты.

### Native

В [GraphTool](../../selfbuild/src/l2src/l2_graph_tool.lm2) `lm_graph_emit_block`:

- `1128/1138` — materialized int declaration;
- `1158` и далее — materialized references;
- `1366/1371` — retained int declaration.

Во всех этих местах вместо имени передать общий helper и runtime source-coordinate:
`lm_graph_emit_address(code, body)` плюс индекс `i`. Координаты уже используются
для чтения literal; они относятся к текущему `lmx_call_code`, не к адресу графа
трансляции. Проверка назначения остаётся до RHS, после RHS строка вновь выбирается
по стабильному site/slot, а не через сохранённый указатель в realloc-массив.
Native вычисляет собственный RHS и использует прежний writer/dirty/publication;
helper не становится исполнителем всего выражения. Прежние mode2/visible-slot
ветки нельзя оставить скрытым name-only fallback для declaration sites.

## Короткая будущая приёмка

Результаты ниже ещё не получены; сборки исследователь не запускал.

- Исходный root occurrence: success, seen3, оба DATA-x сохранены.
- Та же пара x в обычной Self, запускаемой через `call(Self)`: indexed read3.
- Bare повторное имя в обоих случаях отказывает3, первое поле не выбирается.
- Метод с двумя CODE `int:x` сохраняет одно место и прежнюю последовательную запись.
- Formal/DATA collision: actual7, DATAx100, CODE int:x2; return:x даёт result7/DATAx2;
  контроль с bare x:=2 даёт result2/DATAx100, caller7 в обоих случаях.
- Явный CODE site не теряется при method auto-DATA и одноимённом formal; отсутствие
  соответствующего места у произвольной D даёт отказ до тела, а не выбор formal.
- call(Args;Self;Self) разделяет formal x и точные self DATA-sites; повторные DATA-x
  не объединяются, `data\x` остаётся ambiguous, bare formal x продолжает отвечать.
- Обычный Code над другой D с переставленными полями пишет сопоставленное поле;
  лишние поля D и исходное Code не меняются. Неоднозначная неподходящая D не
  исправляется неявным выбором occurrence.
- Повторить необходимое для refs и deferred declarations, сохранив отказы до RHS,
  рабочие snapshots, dirty и одинаковый AFTER в interpreter/native/forced.

## Отдельный OPEN: известные reference DATA fields

Root подтвердил прежний run5 на seed387 и новом388 для
`baseline-call-refs.lm2` в private selector pipeline:

```text
fn: a (int: x) int (return: x + 1)
fn: b (int: x) int (return: x + 2)
@: Calls (@: pick a; @: pick b)
int: first Calls\[0]pick(10)
int: second Calls\[1]pick(10)
```

Это допустимая форма; повтор не является причиной. Даже один `@:pick a` идёт по той
же ветке. Written a/b подготовлены `space_open -> space_declarations` текущего
namespace. Но `build_place:601` не материализует такие references, а
`read_received_value:2102` сохраняет written group как raw. `binding_read` готовит
только fn/sub; выбранный `@:pick a` остаётся Frame. `deferred_kind:55` считает
двухпольный `@` с non-int candidate отложенным kind6, и `step:1730` отказывает5.

[Книга](../../provenance/semantics-book.md), строка815, требует сохранять известную
допущенную Structure-кандидат ссылки при построении вне method data, даже без вызова
содержащего тела. Это задача общего construction/admission в текущем namespace.
[R12/R14](../../LMX_blog/q/fable-self-answers-20261110.md) отдельно запрещают исполнять
computed initializer просто из-за потребления supplied DATA; собственная method data
имеет свой контракт входа. Их нельзя смешивать.

**Не исправлять gap внутри `step` или occurrence reader** автоисполнением `@:`.
Это превратит чтение в запуск DATA initializers, включая эффекты, и нарушит R12.
Не сохранять binding от другого обхода или временного preflight. Реализацию известного
reference field согласовать с общим конструктором; её готовность не следует из успеха388.

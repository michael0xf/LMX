# M11.7: Structure-value в допуске и первый source-known preflight

2026-11-14. Read-only исследование после принятого384/62072bca, во время замороженной короткой bootstrap-сборки385.
Измеренный root baseline ниже передан основным writer; помощник сборок и запусков не делал.
Этот handoff не закрывает M11.7/M13/M14.

**Обновление writer после срезов386/387:** consumer-target исправлен в принятом386;
описанный ниже source-known preflight и runtime-first порядок реализованы в387.
Свежий stage без Run headers прошёл whole G1/G2 quick и fixedpoint13; все22 целевых случая приняты
с отдельной миграцией known_assignment по норме публикации. Подробные результаты и границы —
[свидетельство387](../witnesses/m11-construction-shape-20261114/notes.md).
Ниже сохранён исходный исследовательский контекст; его OPEN относится к моменту исследования.
Следующий код — [selector encoding](m11-selector-encoding-20261114.md), не повтор этих двух исправлений.

## Узкая граница текущего допуска

Baseline `@: Model (int: v 0); fn: f (@: value Model) int (return: value\v); int: r f((int: v 7))`
отказывает4. Обычная Structure Point в own data метода проходит. Причина общая, не корневая:

- `selfbuild/src/l2src/lmx_graph_run.lm2`, `lmx_graph_admit`: требование берётся через
  `lmx_graph_formal_model`, затем `lmx_graph_resolve_value(code.parent, requirement, prepare=1)`.
  Значением Model может быть reference-place kind6, включая рабочую snapshot-cell текущей активации.
- `lmx_graph_admit_paths` проверяет `kind(model)==4 && kind(candidate)==4` до обхода путей.
  Поэтому reference-value отвергается до того, как `lmx_graph_step` сможет применить обычную проекцию ссылки.
- `lmx_graph_read_actual`/`lmx_graph_read_received_value` также вправе дать candidate как reference-value,
  а не только непосредственно записанную Structure.

Следующий узкий срез: в `lmx_graph_admit_paths` один раз спроецировать **локальные** model/candidate
через существующий `lmx_graph_target`, затем сохранить прежние kind4 gate и used-path/type checks.
Не менять общий resolver и `lmx_graph_admit` → `out[0] := actual`: место, значение ссылки и её referent
нужны разным потребителям. Не добавлять поиск физического Model-слота или root-ветку.

## Source resolve, снимки и M14

`lmx_graph_resolve_binding_context`/`lmx_graph_resolve_value` уже выбирают binding по текущей цепочке
activation/formal/data/lexical. Для mapped reference возвращается рабочая clone-cell, сохраняющая выбор
ссылки данной активации. Consumer target читает именно это выбранное значение, а не заново физический
`data\Model`. Поздняя перепривязка физического места не должна молча обновлять snapshot ссылки.

Проекция не публикует dirty, не вызывает flush, не копирует Structure и не меняет передаваемое actual.
Referent остаётся тем же общим S; его поля читает прежний `step`. Общий direct cache и публикация M14
этой коррекцией не реализуются. Это предварительное объяснение source resolve для M14, не новый контракт.

`selfbuild/src/l2src/lmx_graph.lm2`, `lmx_graph_target`, имеет ограниченное поведение:

- kind8/9 сначала даёт underlying reference-cell; kind6 читает один payload;
- kind7 читает held slot, учитывает wrapper8/9 и reference-cell6 и возвращает referent только если он kind4;
  если Structure не получена, возвращает исходный kind7, который admission kind4 gate обязан отвергнуть;
- прочие значения возвращаются как есть; NONE/0 не становится Structure.

Не вводить `while target(...)` или рекурсивное раскрытие: граф допускает циклы, а существующая проекция
ограничена и не зацикливается даже при self-reference. Произвольная глубина указателей/void остаётся M13.
Одного успешного `target` недостаточно для утверждения совместимости — сохраняется весь прежний допуск путей.

## Маленькая приёмочная проба для коррекции

```lmx
@: Model (int: v 0)
@: Candidate (int: extra 99; int: v 7)
@: Alias Candidate
fn: f (@: value Model) int
    return: value\v
int: literal f((int: v 7))
int: by_place f(Candidate)
int: by_alias f(Alias)
```

Независимые ожидания:7/7/7; extra не используется, порядок полей не совпадает с моделью, значения
Model/Candidate не меняются. Отдельный negative с candidate без v сохраняет refusal4 до тела f.
Повторить обычный Point и существующие reference/alias cases; не выдавать эту пробу за full implements/map.

## Отдельный первый шаг construction-admission

Root измерил baseline386 на Graph01 SHA7317b6d5: unknown label, duplicate label,
missing required и positional-after-named внутри `if:0` пока завершаются0, effects0.
Это открытая граница construction-admission, не приёмка статического прохода.
Контроли с inert group, deferred computed default и non-int result в недостигнутом
вызове тоже дают0; в первых двух effects0. FREE lexical fallback внутри holder сохраняет result7.
Будущий проход должен различить эти случаи, сохранив последние контроли допустимыми.
Исходные диагностические варианты находятся в ignored pipeline sol-m11-admission-values-20261114-01,
`next-shape-*.lm2/.log`; поддерживаемые fixture будут добавлены вместе с реализацией прохода.

Основной v3 M11.7 требует проход после построения, включая заведомо несовместимый вызов в недостижимой ветви.
Общая точка — `selfbuild/src/l2src/l2_graph_build.lm2`, конец `lm_graph_build_root` после всех полей;
`lm_graph_build_file` затем уничтожает P0. Оба `lm_graph_run_file` и `lm_graph_emit_file` используют этот путь.

Первый отдельный срез можно ограничить **source-known call shape/default preflight**:

- прежний временный `lmx_graph_space_open` готовит written F через `receiver_bind(evaluate=0)`/`receiver_make`;
- `lmx_graph_bind_call` уже проверяет labels, порядок/повторы, число actuals и наличие обязательных defaults;
- сначала отделить чистую проверку формы от исполнительского ограничения `lmx_graph_call_shape`
  «результат только int», чтобы не отклонить допустимые machine-source result descriptions;
- обходить existing CodeBody views, включая недостижимые ветви; не вычислять actuals, initializers, code или test;
  computed/head-expression/dynamic formal не объявлять source-known посредством runtime readers.

Пример: `fn: take (int: value) int (return: value); if: 0 (take(unknown := 1))` должен отказать при построении.
Существующая `selfbuild/tests/graph/named_unknown.lm2` закрепляет binder refusal до touch().

Это не блокирует Structure-value коррекцию выше. `lmx_graph_admit_paths` пока обходит все nested Lmx без
CodeBody-role фильтра; его нельзя объявить универсальным construction pass для inert groups/nested methods.
Общие `lmx_implements_*` интерфейсные workers и slot-map APIs уже существуют, но требуют корректной связи
descriptor/Consumer/мест. Их чистая адаптация, полный used-interface admission и test остаются следующим слоем,
без второго runtime, постоянной SourceName-таблицы или нового каталога моделей.

## Исследование следующего preflight, после принятого385

2026-11-14, база385 `9edf9666`. Ниже — конкретный кандидат следующего кода, **не выполненная
реализация и не новая норма**. Ранний baseline отказа4 выше — исторический замер до consumer-target.
Основной writer передал результаты pure-проб WIP386:7/7/7, shared8; индекс7/8/9;
NONE-slot released1; unused cycle10/self_len3; snapshot9/9/20. Они относятся к локальной
проекции model/candidate через target и не доказывают construction preflight. Помощник этих
проб не запускал. Полный M11.7, used-interface admission и test остаются открытыми.

### Общая форма и отдельные ограничения исполнения

Точные текущие API в [lmx_graph_run.lm2](../../selfbuild/src/l2src/lmx_graph_run.lm2):

```text
call_shape(g, code, actuals)                              # строка2053
call_reading(g, scope, code, expression, scratch)          # 2173
bind_formals(g, formals, expression, bindings, modes, seen) # 2247
bind_fields(g, formals, structure, from)                   # 2303
bind_call(g, scope, code, expression, bindings)            # 2326
```

У bind_call размер bindings — count(expression)+1; последний элемент хранит reading:
0 — обычные actuals, 1 — вычисляемое whole-значение, 2 — написанная whole-Structure.
Сам bind_call сначала вызывает call_shape с width(args). Сейчас call_shape смешивает
method/arity/default checks с исполнительским пределом «результат только int».

Кандидат: выделить общий private binder context/mode и сохранить public bind_call как
runtime-wrapper. Pure mode проверяет форму без int-result guard. Runtime-wrapper сохраняет
свои прежние отказы **до вычисления actuals**; переносить guard только в invoke_data нельзя:
это разрешит побочные эффекты аргументов перед прежним отказом. Существующий native emitter
в l2_graph_tool.lm2 вызывает public bind_call перед actuals, поэтому wrapper сохраняет и его порядок.

Для ordinary actuals уже достаточно bind_formals(..., modes=0, seen): labels по :=,
повторы, unknown label, positional-after-named и физическая карта формалов общие.
Затем unseen проверяются по наличию default. Не нужен второй связыватель по тексту.

### Наличие default через общий declaration-view

Сейчас default трижды узнаётся как kind(formal)==1: хвост call_shape, unseen в bind_call
и missing refs в invoke_data (последний начинается на строке2869). Это только materialized
literal-int default, а не общее наличие default у допустимого описания формала.

Чистый helper следует связать с общим declaration-view385, сохранив его ограниченный
receiving chain и cycle handling. Он отвечает о **наличии**, не читает значение default:

- materialized int kind1 — default есть; uninitialized int kind3 — нет;
- primitive Frame T(name, default) — есть; T(name) — нет;
- reference Frame @(name, model, default) — есть; @(name, model) — нет;
- qualifier продолжает тот же operand-chain, без обхода model/default subtree;
- если Array/иная допустимая composition пока не даёт однозначного default-view,
  нужен ответ unknown, а не ложное объявление формала обязательным.

Наличие default не означает реализованное runtime-вычисление этой формы. Pure pass не
должен отвергать int: x producer() как формал без default и не должен вызывать producer().
Прежние исполнительские пределы default надо отделить явно, сохраняя фазу их отказа;
не объявлять вычисляемые defaults реализованными одним новым shape query.

call_reading уже является чистым selector. При reading0 действует обычная проверка;
при reading1 поля вычисляемого whole actual ещё неизвестны — их полнота не доказана
ни в одну сторону. Для literal reading2 можно использовать bind_fields по настоящим
полям и default-presence, без call_single/admit/evaluation. written_whole сегодня также
проверяет физические family/kind: эту проверку нельзя выдавать за чистую форму вызова.

### CodeBody, namespace и место прохода

В [l2_graph_build.lm2](../../selfbuild/src/l2src/l2_graph_build.lm2) общая точка — конец
build_root:1003, после заполнения всех полей и до out[0] := root. build_file затем уничтожает P0.
Обычные входы frontend/GraphTool строят граф до своего space_open: например,
l2_frontend_graph.lm2:1362/1366. Все проверки должны читать уже общий Lmx, не P0.

Кандидат Run.preflight(g, root) использует нынешние space_open/space_close (строки5951 и далее):
written F готовятся прежними receiver_bind(evaluate=0)/receiver_make. Для выбранного
CodeBody его written declarations готовятся до чтения полей через space_declarations:5830,
сохраняя двустороннюю видимость. Computed receiver остаётся pending; его актуалы не исполняются.
Закрыть таблицу на каждом выходе по opened; не уничтожать чужой активный namespace.
Для вложенного вызова с opened=0 нельзя предполагать, что открылась новая чистая таблица:
существующий lifetime-контракт должен быть сохранён, а не заменён постоянными facts.

Обход использует code_body:484 и code_parent:163 из Run:

- role1 — поля уже выбранного тела;
- role2 — statement0, expression1, statement2 заголовка for;
- role3 — bounded else/finally body, sole written group выбирается ровно один раз.

Корень и code подготовленных written F — code scopes. fn/sub Frame — объявление, не
обычный вызов для shape check; его args/defaults не сканируются как исполняемое тело.
Нельзя рекурсивно считать все nested Lmx кодом. Для временной очереди/visited пригоден
нынешний scan_add, с сохранением role/scope вызывающего потребителя. Sharing/cycles
не разрешают терять различие expression и CodeBody. Physical parent и holder не менять.

work_scan_context:605 содержит подходящие правила ролей, но сам вызывает capture/read:
его целиком нельзя использовать как чистый preflight. Также не вызывать work_open,
data_run, activation push, read_actual, eval_value или test ради ранней проверки.

### Когда target действительно source-known

resolve(..., prepare=0) даёт чистый lexical fallback, но **сам по себе не доказывает**,
что runtime выберет эту F: свободное имя вложенного тела может прийти из dynamic activation.
Не превращать найденную снаружи root F в статическую цель любого одноимённого FREE вызова.

Безопасный первый охват — root/self и доказанный written local binding в текущей CodeBody
chain, при отсутствии более приоритетного одноимённого формала/data-place. Использовать:

- data_find:1562 для однозначности; один space_find с latest row её не доказывает;
- binding_method(g, owner, raw):1501 для совпадения выбранной F с точным raw source;
- work_pending:200 для computed fn/sub shadowing по CodeBody chain. Этот query использует
  body/lexical_scope локального frame; ради него не нужна activation или capture;
- прежние code_parent/code_within для границ видимости, без продвижения локального
  inline binding во внешний или соседний scope.

Computed head, dynamic formal и mutable reference-place на пути остаются runtime-selected.
Не применять target к изменяемому holder, чтобы объявить его нынешний referent статическим.
step с prepare=1 и runtime readers также не являются доказательством неизменности цели.
После обычного pure resolve нужно доказательство происхождения/приоритета, не ещё один поиск.

Для explicit node существующий node_space:1834 зависит от live activation. Если включать
такие path-heads в первый срез, кандидат — выделить общий node_space_from_code и оставить
runtime-wrapper над ним; фиктивная activation для static pass не нужна. Самый малый срез
может отложить expression/path heads, явно сохранив их runtime-проверку.

### Inert groups и receiving contract

Топовый (bad()) в CodeBody — inert data, его не раскрывать. В известном take((bad()))
scalar formal потребляет operand как выражение, а Structure formal сохраняет written group
данными. Здесь нужны прежние actual_contract:2130, written_group, value_contract и binding map.
При неизвестной цели/contract нельзя предположительно считать group кодом. Именованный
actual разворачивается только до своего value; label не свободный вход вызывающего.

### ABI до потребителя и приёмка следующего кода

Builder уже подключает Run.h. Сейчас public Run53 содержит call_shape[4], bind_call[18],
space_open[29], space_close[30], code_body[52], но construction-pass не экспортирован.
Если новый общий вход станет Run54, его header/body нужны **до** нового Builder.
Штатный build_generation сейчас сначала переводит frontend_objects (включая Builder),
а новый runtime/Run header получает следующим шагом. Нужна явная bridge/header-before-consumer
choreography существующей сборки; stale Run53 header/runtime не являются fallback.
Это зависимость кандидата, не поручение вводить новую систему сборки.

**Уточнение dependency review, 2026-11-14.** Ранний путь уже проверен по существующему
[build.lm2](../../selfbuild/tools/build.lm2), без запуска producers:

- Единственный текущий producer `src/l2src/lmx_graph_run.h.lm1` —
  `bld_machine_module(rec, fe, src, base, out, res, "lmx_graph_run", graph_run_names, 53, 1)`
  внутри `bld_kernel_l2` (строка3154), сразу после Graph72. При добавлении export требуется
  согласованно изменить размер списка, имя нового export и count на54.
- `decls_write_all:1998` пишет36 kernel ABI headers и state units; Run.h в этом списке нет.
  Ранний `bld_p0_l2_selected:4076` пишет/удаляет87 frontend/P0 generated files; Run.h там
  также нет, и этот проход его не удаляет. Поэтому его наличие до frontend_objects
  сейчас означает результат другого kernel producer, а не раннюю генерацию самим frontend.
- `bld_headers:678` только преобразует найденные `.h.lm1` в C headers. Он не извлекает
  отсутствующую Run API из L2 и сам проблему отсутствующего Run54 не решает.

Устойчивый минимальный следующий код — переставить два **существующих** блока в
[suite.lm2](../../selfbuild/tools/suite.lm2), `build_generation:1356`, сохранив их аргументы:

```text
bld_runtime(repo, stage, base, previous_fe, txt_path(label, "runtime"))
bld_frontend_objects(repo, stage, base, previous_fe, txt_path(label, "frontend"))
bld_frontend_link(repo, stage, base, previous_fe, txt_path(out, "runtime"), txt_path(label, "frontend"))
```

Runtime использует previous_fe и его backend companion, а не новые frontend objects.
Он выполняет `decls_write_all`, source-profile projection, kernel L2/API generation,
driver L2 generation и общий C-header pass до компиляции driver.o. Kernel/l2_driver
predefs не требуют P0/frontend/application headers. Clock/deadline/schedule сохраняют
прежний hosted `previous_fe --graph` путь; standalone frontend здесь недостаточен.
Следовательно, по зависимостям runtime можно поставить первым даже на новом source stage:
Run54 header и body будут действительно произведены до перевода нового Builder.

Новый G0 Tool должен **реально исполнять** этот порядок: старый executable не меняется
от правки suite.lm2. Его можно получить прежним build-self через принятые FE/runtime:
изменение recipe и списка exports само не требует нового Run entry в процессе G0 Tool.
Далее один и тот же build_generation даёт runtime → frontend objects → link для G1;
фактический G1 Tool выполняет тот же порядок для G2. Link остаётся после обеих фаз и
связывает новый Builder с driver.o того же поколения. Не нужен новый CLI, отдельный
header-generator, копирование старого Run53 или обязательная повторная private Runtime54
перед каждым поколением. Это предлагаемая перестановка, не результат сборки54.

`generation_snapshot:1262` сохраняет четыре producer-каталога: src/l1src, src/l2src,
headers/l1src, headers/l2src. Поэтому после успешного поколения в его
consumed-inputs.list.txt/consumed-inputs.sha256 и retained copy попадают
`src/l2src/lmx_graph_run.h.lm1`, `src/l2src/lmx_graph_run.lm1` и
`headers/l2src/lmx_graph_run.lm1.h`. Maintained `selfbuild/inputs.sha256` содержит
Run.lm2, а не generated Run.h. Snapshot фиксируется в конце поколения; сам по себе
он не доказывает, что header существовал до раннего потребителя, — это обеспечивает
порядок producer steps. Реализация перестановки, Runtime54 и её G1/G2-проверка пока OPEN.

Короткая будущая приёмка: unknown/duplicate/missing actual в if:0 отказывает при построении;
literal/defaulted формы и non-int result descriptions проходят pure stage; actual/default
counters остаются0. Inert group не проверяется; computed/mutable/FREE target не получает
ошибку от своего lexical fallback. В namespace не остаются таблицы прошлого прохода.
Эти пункты пока OPEN и не следуют из успешных consumer-target проб386.

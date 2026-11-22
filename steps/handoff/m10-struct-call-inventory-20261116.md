# M10: опись и план переноса struct call для среза410 (opus, 2026-11-16)

Подготовлено чатом opus по заданию FABLE-O410-A, только чтением кода. Номера строк относятся к дереву
коммита 2799ad1c (Source16:944). Реализация не начата; вопросы нормы В1–В3 решены автором 2026-11-16 (раздел 5а).
Текущее состояние и порядок — [steps/current.md](../current.md).

Исходный отчёт: FABLE-O410-A — результат (opus). Строки — рабочего дерева (Source16 + WIP409); всё ниже прочитано мной в коде, кроме помеченного «haiku».

## 1. Опись (сверено)

Frontend, разбор и план:
- Lower `lm_compiler_struct_call_operands` 7690–7722 (export lower[191]): только голова `call` (иначе 2), трейлер не `end: call` → 4, нет тела → 2. Первый прогон операндов → `code` (`out\operand`), второй → `data`; 0 = один операнд, 1 = два, 3 = лишнее после двух, 5 = второй не операнд. Порядок старый (code первым), трёх частей и `fncall` нет.
- Lower `lm_compiler_struct_call_plan` 7728–7780 (lower[192]): форма только 0/1, иначе 1; `call_body_site` (body/target_ns/oi/inert), затем имя ТОЛЬКО code-операнда (`struct_call_direct_name(operand)` → `ns_exec_named` → `local_ns_callee`/`ns_exec_field` → `resolved_own`→`own_res`→`mres_exec_ns`, иначе `inert`). Поля плана: shape, operand(code), data, extra, ni, target_ns, oi, result, inert (запись — build.lm2 decl_l2_application ~4000–4004, порты Core ~180–215).
- Emit `lm_compiler_check_word_stmt` 5775, ветка `call` 5788–5803: формы 3/4/5 → ошибки «call takes a code and one data operand…», иначе «call needs a code Structure»; затем Core `check_struct_call` 10478–10506 (core[247]: место code-операнда через `structure_operand_place`, `call_body_note`, `admit_site`) и при shape 1 Core `check_call_data` 10509–10535 (core[248]: `site\split := 1`, `data_node`, `data_target_ns`/`data_oi`).
- Helpers `lm_compiler_receiver_word` 690–692 (helpers[178]): 16 слов (send receive adopt call merge table catch throw throws until end sub fm synchronized length cast); `fncall` нет; слова «fncall» нет ни в одном модуле l2_frontend_*.
- Prepared binder Lower `bind_value_actuals` 847–867 / `_into` 872–947: named только через `:=` (или по голове при by_head=1 — части ресиверов), positional до named, «more arguments than … has formals», повтор формала — ошибка, rank = порядок записи, кандидат whole (2), иначе `bind_defaults_check`. Struct call его НЕ использует.
- Запуск по имени: Resolve 1205–1207 — «only a callable contract invokes, never an ordinary Structure head»; `head_structure` 5614 / `head_resolve` = 5. `S()`/`S(D)` в коде рабочий frontend не запускает.

Frontend, эмиссия:
- Walk-режим: Emit `rw_stmt_content` 12725 (ветка `call` 12803–12806) → `rw_struct_call` 15088–15098 → `rw_empty_struct_call` 15028–15048: EXEC ширины 5, кладёт только code в слот 2; `rw_split_data` 15051–15085 при shape 1 кладёт data в слот 1. Контракт (3) и written-count/actuals не пишутся.
- Обычный вызов: Emit `rw_call_arguments` 9974–10322, EXEC на 10116: [exec, data, selected value, contract, written-count, args…], ширина `arg0 + written_count + dynn`; именованные — NAMED-операнды на месте записи.
- Native: Lower `emit_stmts_with_position` 18687 (ветка 18912–18915) → `emit_struct_call` 18571 → `emit_empty_struct_call` 18530 → `emit_empty_struct_at` 18496: `l2_ensK` = code; `l2_endK` = split data либо `lmx_call_unary_data(arena, code)` (18520) → `emit_current_structure` 18467: `lmx_call_selected_structure(l2_call_arena, 0, l2_call_code, l2_cpK, l2_ensK, data, @ l2_svalueK)`.
- Известный native→native: Lower `emit_dyn_tail_origins` 13399 (13428/13430) — `lmx_call_prim_values(_origins)(arena, code, lmx_call_unary_data(arena, code), refs, nargs, …)`: boxed путь. Core `emit_tramp_call` 12600–12617 вызывает typed body `SYM(parent, self, arena, code, refs, values, @ result, <typed formals>, [@ tv], [@ tt])`; `emit_sig` 12192 → `emit_sig_with_position` 12196; `emit_formal` 12125–12189. Body по-прежнему требует refs/values.
- Части DATA: Emit `rw_header_parts` 7297–7444 пишет header-формалы + dyn в слот 0 (args); `rw_fn_parts` 13757–13817 — written var в слот part 2 и body в part 3; Values `part_slot` 3423–3434 (fn 0..3; sub: 0, —, 1, 2). Walk читает контракт как edge0 = args header, edge1 = return. Две физические части подтверждены.
- Пустой legacy: Context `method_part_contains_own` 1672–1678 (context[79]) обрабатывает только parts 2/12/3 → для part 13 всегда 0. Поэтому Emit `rw_body_var_slots` 19041–19088 (не экспортирован; вызов 13785 в `rw_fn_parts`) ничего не делает, и ветка `moved` в Emit ~13598–13605 мертва. Сама `method_part_contains_own` жива (Core 4853, Resolve 2372/2381).

Walk:
- `lmx_walk_call_shape` 5192–5250: EXEC = [op, DATA(1), CODE(2), contract(3), (4), actuals 5…], n = size − 5.
- `lmx_walk_call_in` 7776: ветка `contract = 0 && EXEC && n = 0` (~7833–7840) → `lmx_call_selected_structure`; иначе FN-контракт (edge0/edge1), `input_count != n` без signature → INVALID, `return_count > 1` → INVALID, `lmx_walk_selected_values` → допуск мест → `lmx_walk_dispatch_values` → результат стирается при `rtype = 0 || want_result = 0`.
- `lmx_call_selected_structure` 9459–9545 (walk[150], прототип в decl_walk): для FN code `lmx_walk_call_rows(…, written 0)` и `lmx_call_formal_default` для КАЖДОГО формала — defaults вычисляются при входе (противоречит M14: инициализаторы при входе не исполняются). Затем `call_places_open(code, data)`; при frame ≠ 0 → `dispatch_values(…, split 1, …)`; при frame = 0 (native) → `lmx_call_prim_values_origins(…, result_context 0, …)`; в конце `if: status = OK → lmx_walk_value_clear(out)` — успешный результат стирается.
- Цепочка `selected_values` 7670–7774: `written_names` (без вычисления) → `selected_inputs` → `lmx_callable_bind_written` → `selected_form` (до любого actual) → `written_values` (каждый actual вычисляется и сразу принимается) → `selected_ready_values`; whole — `lmx_walk_whole_values` (slice 307). `dispatch_values` 6628–6699: native entry → `lmx_activation_push` + `activation_origins` + entry(data, refs, n, dest, …, result_context) либо `lmx_walk_activate_values_origins(context, callee, data, …)`.
- Сверх описи: `lmx_call_unary_data` 4184–4199 (walk[88]): FN → часть 2 (f\data — верно для обычного f(A)); обычная Structure → её дочернее поле `var` (LMX_ID_VAR). Это противоречит `call(C) = call(C C)` и «дочернюю data из code не выбирать». Пользователи: Lower 13428/13430 (FN, верно), 18520 (запуск Structure — неверно), Walk 4419, 5528, 6528/6575/6588 (короткий прямой вызов), 9363, 9581, 9655, lmx_implements 4870/4890, driver 1035.
- Образец таблицы форм — чистый граф: `lmx_graph_run.lm2` 7468–7540 (`lmx_graph_receivers_open`): call {1:(code), 2:(data code), 3:(args data code)}, fncall {2:(return code), 3:(data return code), 4:(args data return code)}, launch `()` {0, 1:(data)}; выбор — `lmx_graph_receiver_form_of` 7794.

ABI (haiku, проверил числа): у каждого export-списка три связи — calloc, диапазон присваиваний, литерал в вызове bld_machine_module (call 2246/2830–2848/3273; walk 2263/2616–2806/3313; helpers 4193/4292–4554/6775; values 4195; context 4197; useplan 4202; lower 4203 (427); core 4204/5841–6285/6840; emit 4205 (309)). Других проверок счётчиков нет. Поле записи меняет текст decl_*, генерируемый .h.lm1 и его hash; L2StructCallPlan — decl_l2_application ~4000–4004 (kind 46, l2_application.h.lm1).

## 2. План 410 (каждый шаг — собираемое состояние)

Шаг 1 — части запуска во frontend (Helpers, Lower, Core, Emit-check; запись L2StructCallPlan).
- `receiver_word` + `fncall`.
- `struct_call_operands` (имя и export сохранить) → чтение частей: голова call|fncall, операнды прежними `operand_run`/`skip_span`; форма выбирается по числу позиционных (таблица из шести строк, как в чистом графе); именованная подача `data := D`, `code := C` (и `args :=`, `return :=`) — существующим `bind_value_actuals_into` с именами выбранной формы и by_head 0. Ошибки формы — ошибки этого binder'а, а не shape 3/5.
- В план — поля args, return и вид (call/fncall). Отсутствующая data = code (решается здесь, не в runtime).
- `check_word_stmt`: убрать shape-сообщения, оставить проверку code и data (`check_struct_call`/`check_call_data`, имена и export сохранить).
- Вместе удалить: shape 3/5, «call takes a code and one data operand…».
- ABI: decl_l2_application (поля плана) → l2_application.h.lm1 → полная сборка frontend; число export'ов не меняется.
- Вместе с порядком data-first перевести фикстуры со старым двухоперандным `call: X D` (опись haiku: dyn data_source_cells, held_structure_places, split_copy_bound_data, code_write_words, explicit_data_var_field, immutable_reached_write, sub_parts, тексты в graph_fn_data_typed 585/671/392/396, var_own_nested). Без них шаг не зелёный.

Шаг 2 — один EXEC для всех форм (Emit, Lower native).
- `rw_struct_call`/`rw_empty_struct_call` → EXEC [op, DATA, CODE, contract, written-count, actuals…]; actuals args — тот же код, что в `rw_call_arguments` (written + NAMED); args-имя Structure — существующий WHOLE-операнд (slice 307).
- Native `emit_empty_struct_*` → те же части; вызов общего entry с настоящим result_context (не 0). `lmx_call_unary_data` для запуска Structure больше не вызывается: data = code.

Шаг 3 — Walk/runtime (lmx_walk_values; без новых записей).
- В `call_in` снять ветку `contract = 0 && n = 0`. Все EXEC идут через входы выбранной data → `selected_values` → допуск мест → `dispatch_values`. Результат — по return (fncall), у call нет.
- Удалить `lmx_call_selected_structure` (walk 191 → 190, прототип decl_walk ~1848) вместе с: жадным циклом `lmx_call_formal_default`, `written 0` и стиранием успешного результата; native-ветку перевести на общий worker.
- `lmx_call_unary_data`: оставить ветку FN (f\data обычного вызова), ветку `var`-ребёнка обычной Structure заменить на саму code и проверить всех пользователей (список выше).
- Счётчик Call 19 не меняется.

Шаг 4 — запуск по имени в коде (Resolve, Lower).
- Правило Resolve 1205–1207 для кода: голова — обычная Structure (`head_resolve` = 5) → тот же план, launch {0: (), 1: (data)}. `S()` = call(S S), `S(D)` = call(D S), `S(data := D)` = S(D).
- Отказы: другое имя, два позиционных, не-Structure. В данных ничего не меняется.

Шаг 5 — удалить пустой legacy: `rw_body_var_slots` 19041–19088 с вызовом 13785, мёртвую ветку `moved` ~13598–13605 и комментарии part 13 (Context 2646). Export'ов нет.

Отдельными срезами (рекомендую 411/412, у каждого своя смена ABI всех генерируемых методов):
- (411) Единая физическая DATA. Header-входы (slot 0) и written data (part 2) — одна часть; меняются `rw_header_parts`/`rw_fn_parts`/`part_slot`/`lmx_callable_part`, контракт Walk edge0. Без этого `fncall(A f\data int f\code)` для fn с header-входом не видит формал.
- (412) Прямой typed C-вызов известного native→native. Сигнатура body без обязательных refs/values для доказанных FT (`emit_sig_with_position`/`emit_formal`), скрытые входы по use plan, trampoline (`emit_tramp_call`) остаётся адаптером. Call-сайты Lower `emit_dyn_tail_origins` 13399 зовут body напрямую; неизвестный target — общий worker.

Новый dispatcher, реестр, правила P0 и фиктивные методы не нужны.

## 3. Приёмка (черновик фикстуры — [m10-struct-call-forms-draft-20261116.lm2.txt](m10-struct-call-forms-draft-20261116.lm2.txt), сборкой не проверен)

Один dyn-файл, строка `runs dyn/call_forms_data_first.lm2 7 nf` (native/forced × root0/root1). Ожидания:
- 81 `call(D Step)` → steps 10, D\x 10.
- 82 `call((next()) D Step)` → steps 17, calls 1 (actual 7 подавил default 10, next один раз).
- 83 `call(Self)` → steps 22, Self\n 3 (data = code, исходник сохранён).
- 84 `fncall(int Value)` → 31, Value\y 30.
- 85 `fncall(D int Add)` → 11.
- 86 `fncall((next()) D int Add)` → 8, calls 2.
- 87 `fncall(A D int Add)` → 8 (имя Structure как args — whole), A\x 7, D\x 10.
- 88 `call((x := 7) D Code)` → steps 50, Code\y 20 (локал 28 против исходного 20).
- 89 `Self()` → steps 55.
- 90 `Step(D)` → 65.
- 91 `Step(data := A)` → 72.
- 92 `g(7)` → 8, calls 2 (fn g (int: a next())).
- 93 `g()` → 8, calls 3.
- 94/95 `fncall((7) g\data int g\code)` → 8, calls 3; `fncall(g\data int g\code)` → 8, calls 4 — только после единой DATA (411); до неё — OPEN.
- Отказы (refuses): `Step(D D)`, `Step(other := D)`, `Step(5)`, `fncall(Step)`, `call(A D Step Step)`.
- Graph-тройка: существующий graph/call_frame_local (шесть форм) + случаи `S()`/`S(D)`/`S(data := D)` в том же или профильном graph-фикстуре; interp/native/forced.
- Мутант: вернуть в Lower выбор data = `lmx_call_unary_data(code)` → 83 даёт отказ/иное значение во всех 4 режимах.

## 4. var_own_nested (full-suite:169, строку не трогать, entry 7)

- Удалить отменённые (чтение CODE-локала через `m\var\…` = backfill/публикация): 82, 84, 86 и вторые половины 87, 88, 89, 90, 91.
- Оставить: 81, 83, 85, первые половины 87/88 (5/6), 90 (`node\seen` = 6 — явная запись в граф), 91 (`drive()` = 80); коды не перенумеровывать.
- 89 (`anon`): standalone `---` — см. вопрос В1. Если группа — данные, выразить исполняемое анонимное тело явно через `until: 1` (книга 860: анонимное тело с until — цикл в текущей активации), ожидание 4. Решено автором 2026-11-16: группа исполняется, `until: 1` не нужен, ожидание 4 (раздел 5а).
- 92: `call: one D` → `fncall(D int one\code)` = 3 и `D\b` = 0, `D\r` = 0 (эффект CODE + неизменность D).
- 93: отказ «нет CODE-локала в E» отменён. Тот же `catch: call ()` (r := 9) ставится на настоящий отказ формы/допуска DATA при исполнении: data через место-ссылку (`@: e E`), actual без входа, например `call((5) e Step)`. Точный код отказа — пробой после шага 3. После ответа В3 (раздел 5а) отказа «вход без значения» нет: пересмотреть.
- Шапку файла (ссылки :133…:441) обновить.

## 5. Вопросы нормы

Все три вопроса решены автором 2026-11-16, ответы и следствия — в разделе 5а; текст вопросов сохранён как был.

В1. Standalone `---` в коде без until:
```
fn: anon () int
    int: r 0
    ---
        int: q 4
        r := q
    ---
    return: r
end: anon
```
`anon()` = 4 (группа исполняется в текущей активации) или 0 (безымянная Structure данных, не исполняется)? to_fable.md:283 говорит «DATA»; книга 860 говорит только об анонимном теле с until; грамматика §15 (~496): маркер открывает анонимную Structure и «не является вызовом». Это решает судьбу 251 открывающего `---` в 53 dyn-файлах (счёт haiku) и graph/post_loop.

В2. Callable в позиции code: `sub: s () (int: x 5)` с кодом `Counter\steps := Counter\steps + x`, затем `call(D s)` при D: `int: x 10`. Варианты: steps += 10 (исполняется s\code над D) или отказ (code — исполняемая Structure, нужно `call(D s\code)`)? От этого зависит перевод ~15 фикстур `call: held D`/`call: one D`.

В3. Вход data без значения: `E: int: x` и `call(E Step)` без args. Отказ до тела (как `f()` у `fn: f (int: a)`) или исполнение с непроинициализированным x (uninit:int, M14: чтение не ошибка)? Наблюдаемо: catch r = 9 против изменённого steps.

Решения маршрута принимаю сам: имена `struct_call_operands`/`plan`/`check_*` сохраняются (export не меняются); DATA и прямой C-вызов — отдельные срезы 411/412.

## 5а. Ответы автора 2026-11-16 и следствия для описи

Слова автора записаны дословно в [журнале](../../LMX_blog/2026-11-16.md#answers-20261116); норма — в книге:
[ресиверы `call` и `fncall`](../../docs/spec/LMX_semantics.ru.md#call-receivers),
[безымянная Structure в коде](../../docs/spec/LMX_semantics.ru.md#data-code-roles),
[ресивер `required`](../../docs/spec/LMX_semantics.ru.md#required-receiver). Ниже — выводы исполнителя для плана описи,
не слова автора.

- **В1 → 4.** Безымянная Structure в коде не считается вызовом с аргументами, но её записи исполняются на месте, в
  текущей активации ([журнал](../../LMX_blog/2026-11-16.md#unnamed-structure-executes)): `anon()` возвращает 4, не 0.
  Замечание «Standalone `---` там теперь DATA» (to_fable.md, срез409) для кода отменено. Следствия: var_own_nested 89
  (`anon`) сохраняет ожидание 4 **без** `until: 1`; 251 открывающий `---` в 53 dyn-файлах и graph/post_loop
  сохраняют исполнение, переписывать их не нужно; исполнение безымянной Structure в коде — отдельная работа frontend,
  обходчика и чистого графа ([M10](../../next_core_tasks_v3.md#m10), решения 2026-11-16, п. 4); присваивание между
  безымянными Structure, как `(a b c) := myFn()`, — общий случай присваивания ([M6](../../next_core_tasks_v3.md#m6)).
- **В2 → исполняется сама `s`.** Callable — просто Structure: `call(D s)` исполняет саму `s`, а не `s\code`; тело над
  другими данными — `call(D s\code)`, обычный вызов — `call(A s\data s\code)`
  ([журнал](../../LMX_blog/2026-11-16.md#callable-is-structure)). Следствия: записи `call: held D` и `call: one D`, где
  `held` или `one` — callable, переводятся в `call(D held\code)` (с actuals — `call(A held\data held\code)`, для функции —
  `fncall(… \return … \code)`); `call` над обычной Structure (`Step`, `Code`, `Self` черновика фикстуры из раздела 3) не
  меняется. Шаг 1: `struct_call_operands` не выбирает часть поданной Structure; шаг 3: ветка `var`-ребёнка в
  `lmx_call_unary_data` заменяется самой code (как и было в плане), ветка FN (`f\data` обычного вызова) сохраняется.
- **В3 → исполняется, входы необязательны.** `E: int: x` и `call(E Step)` исполняются, `x` держит «T без
  инициализации»; так же `f()` у `fn: f (int: a)` ([журнал](../../LMX_blog/2026-11-16.md#optional-inputs-required)).
  Новый ресивер `required` пишется где угодно и в любом объявлении, как `private:` — пометкой `required: (int: a)`
  или строкой `required: a`: в `data` запуска поле проверяется при подаче аргументов, в `code` — на своей строке;
  отдельного входного прохода нет (ответы автора 2026-11-16,
  [журнал](../../LMX_blog/2026-11-16.md#required-anywhere)). Вид отказа — OPEN (Р29–Р31 в
  [ответах](../../LMX_blog/q/fable-self-answers-20261110.md)). Следствия: из проверки формы вызова убирается проверка
  наличия значений у входов — искать в Lower `bind_defaults_check` (847–947), Core `check_call_data`/`check_struct_call`,
  Walk (`input_count != n` без signature → INVALID, раздел 1) и в чистом графе; отказа «вход без значения» в
  фикстурах больше нет.
- **Пересмотреть.** Случай 93 (var_own_nested): его `catch: call ()` ждал отказа формы или допуска DATA для «actual без
  входа»; остаётся только отказ **формы** (лишний actual, например `call((5) e Step)` без формала — отказ binder'а
  «more arguments than … has formals», по чтению раздела 1), отказа «вход без значения» нет; естественная проверка
  отказа допуска — `required` после его реализации (код отказа — пробой). Отказы раздела 3 (`Step(D D)`,
  `Step(other := D)`, `Step(5)`, `call(A D Step Step)`, `fncall(Step)`) остаются отказами **формы**; у `fncall(Step)`
  причина — число операндов (нет `return`), а не вход без значения: при написании фикстуры проверить, что отказ вызван
  именно формой.

## 6. Разбиение и сборки

- opus (я): шаги 1, 2 и 4 (frontend: части, план, проверка, эмиссия, запуск по имени).
- sonnet: шаг 3 (Walk/runtime, unary_data, recipe walk 191 → 190 и decl_walk).
- haiku: перевод фикстур старого порядка, var_own_nested, новый фикстур и строки suite.
- Сборок ~11–14: полный frontend (запись плана) + hosted; runtime; targeted; 1–2 итерации frontend/runtime; полный suite (смена порядка задевает много фикстур); Graph + тройки; bootstrap quick G1/G2 + fixedpoint; mutant; docs check.

Дефектов в коде409 не нашёл. Сверх описи — два давних расхождения с нормой (не 409): жадные defaults и стирание результата в `lmx_call_selected_structure`; ветка `var`-ребёнка в `lmx_call_unary_data`.

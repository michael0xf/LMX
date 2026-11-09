# Одна композиция merge и один binder для всех форм fn/sub — 2026-11-09

Исполнитель: opus. Основание — ревью Codex CODEX-OPUS-333-REVIEW-20261109T0937Z-01
([копия](records/pins/codex-333-result-review.txt); моё письмо 333 — [records/pins/opus333-letter-result.txt](records/pins/opus333-letter-result.txt))
и проверка CODEX-OPUS-334-WIP-CHECK-20261109T1003Z-01 по прямому поручению автора ([копия](records/pins/codex-334-wip-check.txt));
технические уточнения автора 2026-11-09 — в [журнале](../../../LMX_blog/2026-11-09.md): именованные формы
`fn: name := "test"; args := (); …` и `fn: name: "test"; args: (); …`, коллизия с существующим вызываемым `name`,
одинаковое дополнение var при любом происхождении структур, ресиверы с разным числом аргументов называются одинаково.
Предыдущий срез: [333](../fn-forms-20261109/notes.md).

## Изменение

1. **merge без особой ветки функций.** `lmx_graph_merge_level`: слот, чьё значение (`lmx_graph_field_value` — одна
   модель Frame) — Structure, которую поздние операнды дают снова как Structure, компонуется тем же уровнем через ту же
   карту, рекурсивно, при любом происхождении операндов. Условие FN pool (`lmx_graph_fn_result(values[0])`, ревью 333
   п. 1) убрано; классификация «код/данные» промежуточного WIP (`lmx_graph_merge_code`, проверка 334 п. 2) убрана тоже —
   ни по происхождению, ни по операторам, которые часть держит. Поздние поля пишутся по своему значению; Frame
   определения заменяется поздним полем (решает `first[i]`: копии заполняются позже).
2. **Контракты ресиверов.** `lmx_graph_receivers_open` при открытии namespace каждого обхода регистрирует в блоке корня
   Lmx `fn` и `sub` — формы-обычные сигнатуры: `fn` [name, args, return, var, body], [name, args, return, body],
   [name, args, return], [name, parts]; `sub` [name, args, var, body], [name, args, body], [name, parts]. `name` и
   `return` — формалы «как написано» (ячейки слова), остальные — Structure (пустые Lmx, `lmx_graph_formal_name`: пустая
   именованная Lmx отвечает своим именем). Освобождаются с таблицами обхода.
3. **Один binder.** `lmx_graph_bind_formals` — общая карта имён вызова (`lmx_graph_bind_call`, by_head 0) и ресивера
   (`lmx_graph_receiver_bind`, by_head 1): позиция; `name := value`; для частей ресивера — Frame, чья голова называет
   формал и не отвечает вызываемому в области, что бы Frame ни держал (ни одного поля, одно, вертикальный блок).
   `lmx_graph_bind_fields` — вся структура аргументов (вызов, `lmx_graph_call_single`, и форма `fn: prepared`). Форма
   выбирается до вычисления любого actual.
4. **Приём.** Написанное для формала стоит как написано, если ничего не применяет (`lmx_graph_applies`: применение —
   `merge` или Frame, чья голова отвечает вызываемому в области; та же проверка в `lmx_graph_frame_value`); применение и
   имя, которое разрешает формал-Structure, вычисляются по порядку, и каждое значение сразу принимается формалом
   (`lmx_graph_receiver_admit`: формал «как написано» — слово или записанная форма, формал-Structure — Structure) до
   следующего actual. Действие одно: `lmx_graph_receiver_make` → `lmx_graph_fn_make` / `lmx_graph_fn_var`; имя — слово (5).
5. **Значение `:=`.** Построитель (`lm_graph_build_assignment`) кладёт операндом `name := …` тело после `:=`, прочитанное
   одной моделью Frame: одно значение (слово, безымянный int, безымянная Lmx) — само, иное тело (ни одного поля,
   несколько, место, Frame) — Structure своих полей, как блок части по голове. Прежде несколько полей — отказ построения
   2 (`args := (int: a; int: b)`), одно место или Frame — само поле (`args := (int: a)` давал место `a`, ресивер — 5).
   Потребители, вычисляющие операнд (`lmx_graph_eval_value`, `lmx_graph_eval_number`, `lm_graph_emit_operand`,
   `lm_graph_emit_number`), уже читали Structure из одного поля как это поле — их поведение то же (ни одна `.expected`
   не печатает `:=` с операндом-Frame). Binder ресивера читает операнд `lmx_graph_frame_value`.
6. **Когда создаётся F.** `lmx_graph_fn_written` — объявление, чьи actuals связываются без вычисления; его F создаётся
   при входе в блок (`lmx_graph_space_declare`; -1/-2 — отложено до места). Иначе — `lmx_graph_fn_apply` там, где обход
   дошёл до Frame, как в 333. `lmx_graph_fn_decl_name` (экспорт [38]; `graph_run_names` 39) — записанное имя: слово на
   первой позиции, `name := word`, `name: word`; им пользуются resolve и транслятор (`collect_methods`,
   `lm_graph_emit_fn_name`), и native-тела ставятся на записанные именованные объявления (fn_named_supply:
   `lm_graph_method0`…`6` на k1–k6 и s1).

## Фикстуры

| Фикстура | Что | graph72 (интерпретатор; native/forced — тот же журнал, SHA ниже) |
|---|---|---|
| merge_nested_part (новая) | A (x 1, P(u 2)), B (P(v 3)); `R: merge(A; B)` | R: x 1, P: u 2, v 3; A и B как написаны |
| merge_code_descriptions (новая) | описания кодом с полем `name`: d1 (one; a, b 1; int; тело), d2 (two; b 4; int; без тела); `fn: h merge(d1, d2)`, `fn: merge(d1, d2)` | h(1) 14 (b 4 от d2), two(2) 24, h(1; 7) 17; d1, d2 как написаны |
| fn_prepared (дополнена) | + `fn: other prepared` на той же prepared (поле `name`, в var только `calls`, `last` — в теле) | triple(5) 19, triple(2) 10, calls 2, last 2; other(3) 13, calls 1, last 3; prepared как написан |
| fn_named_supply (новая) | `name := …`, `name: …`; пять частей через `:=`; `args := ()`; var; вертикальный блок; `sub` через `:=` | k1(4) 5, k2(4) 12, k1(k2(1)) 4, k3(4; 2) 42, k3(b := 1; a := 3) 31, calls 2, k4() 7, k5() 9, k6(9; 4) 10, total 6 |
| fn_name_collision (новая) | при `fn: name (int: x) int`: `fn: name := k3; …` | k3(1) 3, name(2) 200, name\var\calls 1 |
| fn_name_call (новая, отр.) | при том же `name`: `fn: name: 7; …` — вызов name(7), его значение не связывает часть | интерпретатор 5; native/forced — отрицательный R0 |
| fn_bad_args (новая, отр.) | `fn: bad 7 int touch()`, touch пишет `Box\hits` | 5 до `touch()`: в печати отказа `Box: hits 0`, `before 0`, `after` не вычислен |
| прежние | merge_callable, merge_recursion, fn_new_name, descriptor_merge, defined_call_body, defined_call_actuals, fresh_traversals, fn_alias_call, fn_without_name | как на graph64 |

Наблюдаемые поля по поручению (check72, `interp.log` = `native/run.log` = `forced/run.log`):

- **Описания кодом** (merge_code_descriptions, SHA журнала bebd8f953728…): `r1 14`, `r2 24`, `r3 17`; d1 — `name: one`,
  args `a`, `b 1`, `return: int`, тело `return: ((a * 10) + b)`; d2 — `name: two`, args `b 4`, `return: int`, без тела;
  оба печатаются как написаны, функциями не стали.
- **Функции namespace f1/f2** (fn_new_name, 39ae8f6e3006…): `k 5`, `r1 15` (f1(1)), `r2 15` (g(1; 2)), `r3 35` (g(3; 4)),
  `c1 1` / `c2 2` (calls f1 / g), `s1 1` / `s2 3` (seen); merge_callable (a7313ac90902…): `k 5`, 15, 15, 25, calls 1/2.
- **var без `last` в обеих формах** (fn_prepared, e9b3e7d0767c…): `fn: prepared` — `c1 2`, `c2 2` (triple\var\last);
  `fn: other prepared` — `r3 13`, `c3 1`, `c4 3` (other\var\last): поле тела добавлено одинаково, счётчики свои;
  `prepared:` в GRAPH-AFTER — как написан (var только `int: calls 0`).
- **Именованные формы и коллизия**: fn_named_supply (3c6b19e9db68…), fn_name_collision (9f3e2e9c0c60…) — значения выше.

Общность: карта имён binder общая (`lmx_graph_bind_formals`, `lmx_graph_bind_fields`: вызов и ресивер); по голове — только
части ресивера (by_head 1 у ресивера, 0 у вызова); приём у каждой сигнатуры свой — типизированные формалы вызываемого
через `lmx_graph_admit`, формалы контракта ресивера через `lmx_graph_receiver_admit`; полный приём одним механизмом не
объединён.

## Проверки

1. Промежуточные сборки (tool34 = T33 build-self на rt56/driver.o из source22; build.lm2 после не менялся):
   graph66/67 (rt55/56, source20/21) — общая композиция merge (журналы run66/run67); graph68 (rt57, source22) —
   контракты и общий binder; graph69 (rt58, source23) — после проверки 334: merge без классификации кода, немедленный
   приём, имя пустого формала (fn_bad_args — 5 до touch()), но
   fn_named_supply и fn_name_collision — 5 (`run69-*`: операнд `:=` — само место `a`); graph70 (rt59) — операнд `:=` —
   тело: `:=`-формы работают, `args: ()` по голове — 5 (`rundir-probe-full.log`: k5; source24); graph71 (rt60,
   source25; проверки — на source26 с `.expected`) — часть по голове
   при любом числе полей: `checks opus334-graph-check71.tsv` — 79/0, 237 PASS, но производственные `l2_libc`, `text`,
   `winargs` — `run answered 2` (`after71-*`; так же graph68–70, graph67 — exit 0: `rundir-bisect-*`): требование
   результата `@: c.FILE` формал «как написано» не принимал и вычислял.
2. Итог на graph72/tool34/rt61 (`opus334-source27`, 393 входа): `checks opus334-graph-check72.tsv` — `CHECKS 79 lines,
   0 failed`, 237 PASS (10:37:47→10:39:07Z); `mutation` 12/12 (в том числе
   `var-copy-keeps-the-lexical-chain-of-a-reached-structure`); `method-mutation` 8/8; `sub_void_value` — `run answered 5`,
   `emit answered 5`, частичный L1 = graph58; производственные модули (`after72-*`) — журналы совпадают с graph64 после
   строки CWD: primitive и lmxtool — `run answered 3`, остальные exit 0, везде GRAPH-BEFORE = GRAPH-AFTER.
3. source25 → source26 → source27: между 25 и 26 — только фикстуры, `.expected` и inputs.list (сверено по манифестам);
   27 — `lmx_graph_run.lm2` (п. 4). `.expected` пяти положительных записаны из GRAPH-AFTER graph71 (`rundir-exp71-*`) и
   на graph72 совпали во всех трёх режимах.

## Найдено попутно (не изменено этим срезом)

1. Запись поля Frame-ом пути в теле вызываемого, если значение читает локальное имя: `Box\hits: Box\hits + d` —
   `run answered 3` на graph72, graph69 и graph64 (`rundir-probe-sub-a*`, `-e`); `Box\hits := Box\hits + d`
   исполняется (`-f`: `h1 5`). Дефект прежний, к формам fn не относится.
2. Вычисляемое объявление в Structure данных: `A: (int: p f())`, `A\p` — 3; `merge(A)` — 3; `merge(A; B)` с двумя
   такими полями — 5 (оба — слоты с именем `int`), так же на graph64 (`rundir-q-b*`).
3. Именованный оператор тела против одноимённого поля: `merge((int: y 5); add\body)`, где в теле `y: y + x`, — 4 на
   graph72 и graph64 (`rundir-q-a*`). Книга :1219: «безымянные операторы не сопоставляются с полями по имени»; с 332
   операторы — именованные Frame. Нормативный вопрос, не решён.
4. Строка как имя: `fn: name := "test"; …` создаёт функцию с именем-словом `"test"` (с кавычками), `test()` — 3
   (`rundir-q-d2*`); на graph64 — отказ построения 2. Читать ли содержимое строки как имя — вопрос нормы.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus334.

- P/pins/opus334-source27.sha256, 393 входа: 298dd4eb63e1e74ed825eb5cbcd796df48b345ecf908fd4beecb05467cf5da3e.
- T34 = S/tool34/lmxtool-tool.exe: d6bc050516f6145d62647bce2a0d415602dd14a3848697144a038d78f0824950.
- S/rt61/driver.o: 0041f05257d3928b4dc7ad1667ec1fb912b176746a7b24fe931d13d270510209 (source27).
- S/rt61/driver-observe.o: 8e5bdf6f1eba81af86823b3274511bac2a5e5d73c2bba304883205c399789282.
- G72 = S/graph72/graph_trans-prod.exe: 70ead62027042c1202f71efefa0104daa4ed276cc3d84f0591a2ae9f0b45215a (source27).
- Промежуточные: rt58 d4a770bef0039f8d91dd7d0570cdbf8b4270fc2966f5d0cec132ea5f4d226d03 / G69
  610e9c8baa03707d18b2e4fdc15f68547d6d961c071314ffb448ffbf925e3622; rt59 09b01b76033adae1c8c1fbcb2b1c092262bb7b292508a1c4b2a600a281ab6362
  / G70 1361bf206b36ea8cc39f8a36b6050f03e33a84366a9b46cce6ee1b7b599c6080; rt60 abd1c6726a0f26977b7987dab25460b6c50d81a7891988e25de0d08ce2f9d42c
  / G71 124bc95fa6230490fdb8d91da5cdfdf653e27b04048873d7896c2f4f481c614c.

```text
T33 0 entry 0 -- build-self R S B F S/rt56/driver.o tool34
T34 0 entry 0 -- manifest R/selfbuild/inputs.list R/selfbuild P/pins/opus334-source27.sha256
T34 0 entry 0 -- stage-copy P/pins/opus334-source27.sha256 R/selfbuild S
T34 0 entry 0 -- build-runtime R S B F rt61
T34 0 entry 0 -- build-graph R S B F S/rt61 graph72
T34 0 entry 0 -- checks P/pins/opus334-graph-check72.tsv
G72 0 entry 0 -- mutation
G72 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
G72 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G72 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph72/sub-void-refused.lm1 native 1
G72 0 entry 0 -- run S/<production input> 1
```

OUT строк проверки — `S/check72-CASE`. Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA
LF-копий](records-lf.sha256); docs check и архивные журналы — [список](records2.list), [SHA](records2.sha256),
[SHA LF](records2-lf.sha256).

## Граница и следующее

1. Вычисляемое применение ресивера — только в корне; в теле и во встроенном блоке — 5.
2. Требование результата, отличное от слова, хранится как написано: позиционно — сама форма, по голове и через `:=` —
   блок, который её держит; исполнители исполняют результаты `int`.
3. Приём вызова и приём ресивера — разные функции при общей карте имён (п. «Общность» выше).
4. Вопросы нормы: п. 3 и 4 «Найдено попутно»; дефекты п. 1 и 2 — для следующих срезов.
5. Открытые с 329–333: адрес `@` ссылки на Structure, внутренняя ссылка в var письменной формой, C-дверь интерпретатора,
   машинный экспорт из чистого графа.

# K2, S2: фактические значения у структурного вызова `C(args)` — по норме, 2026-11-25

План [29.4](../../../next_core_tasks_v3.md#k2-20261125); порядок S1 → S2 → S3 — Sol и Astra
(`CODER-K2-DESIGN-2-20261125-01-S1-BOUNDARY`, `…-ASTRA-ANSWER`); координаты S2 —
`CODER-K2-S1-RESULT-20261125-01-ASTRA-ANSWER`. S1 — [свидетельство](../k2-s1-input-pass-20261125/notes.md).

## Норма и что было

Норма (`provenance/semantics-book.md`, #structural-call): `C(args)` — написанные фактические по общему алгоритму,
DATA — `parent(C)`; поданный фактический заполняет выбранное место в новом пространстве имён, исходные данные и код не
меняются, вход не исполняет инициализаторы. Пример книги: `Step\add()`, `Step\add(x := 2)`, `call(Step\add)` дают
`Counter\steps` 12.

До S2 (комплект S1) запись с фактическими у обычной Structure шла в `lmx_graph_eval_launch_record` с формами `[]` и
`[data]`: `S(D)` исполнял S над данными D — подстановка данных, которой в книге нет; именованный фактический вне формы
`[data]` отказывал с 5. Пример книги давал отказ 5 (измерен 16:58, `CF/k2s1-01/probe-s2/before`).

## Механизм (`selfbuild/src/l2src/lmx_graph_run.lm2`)

Один вход структурного вызова с фактическими — `lmx_graph_eval_structural` (:7116–7222); из него идут
`lmx_graph_eval_application_value` (:7251; хвост выражения), `lmx_graph_eval_launch_record` (запись в коде) и
`lmx_graph_launch_structure_value` (:7541; запись без фактических).

| Часть | Строки | Что |
| --- | --- | --- |
| `lmx_graph_data_contract` | :3071 | договор входа по данным и номеру формала; `lmx_graph_actual_contract`, `lmx_graph_read_actual_value` (:4684), `lmx_graph_actual_effect` — оболочки над новыми функциями с явными данными |
| `lmx_graph_bind_inputs` | :3290–3394 | связывание полей с входами данных до чтения значений: один обход S1 (`lmx_graph_input_next`) даёт порядок входов и их формальные номера; позиционное поле берёт вход своей позиции, именованное `x := v` — вход внешнего имени; после именованного позиционного нет; вход связывается не более одного раза; `required` без записанного значения по умолчанию обязан быть связан; имя без входа — `reason` 1 (5 до вычисления значения) |
| `lmx_graph_pair_structural` (W) | :6777–6845 | фактические как написаны: приём каждого у входа (`lmx_graph_admit_value`); обход 0 — выбор, ничего не исполняется; обход 1 — вызов: каждый фактический один раз, слева направо |
| `lmx_graph_pair_structural_opened` (E) | :6857–6931 | поля единственной Structure-фактического; группа, написанная в вызове, — по описанию поля; значение Structure — по значению поля |
| `lmx_graph_structure_result` | :7089 | результат, описанный в данных (`return`) |
| `lmx_graph_eval_structural` | :7116–7222 | C, `parent(C)` (`lmx_graph_callee_data`), область вызывающего; W и E взвешиваются как их взвешивает выбор (`lmx_graph_select_whole` вычисляет целое один раз): ровно одна допущенная пара — вызов, больше одной — 3, ни одной после достижения приёма — 4, ни одной по форме — 5; потреблённый результат без описанного `return` — 5 до эффектов |
| `lmx_graph_launch_structure_values` | :7506–7537 | один запуск: кадр, исполнение, результат (`lmx_graph_invoke_data_value`); допущенные Values читаются кадром по номеру формала |
| `lmx_graph_eval_launch_given` | :7283 | прежнее чтение записи запуска — граница для Structure, объявленной внутри `fn`/`sub` |
| `lmx_graph_admit_field` | :4561–4567 | вход-ссылка рода 6 или 9 — место универсальной ссылки — принимает Structure: Value остаётся ссылкой на поданное. Ветка общая с путём вызова callable |

Решения, найденные при реализации:

- Запуск идёт под теми же корнями исполнения, что и выбор: восстановление корней до запуска опустошало
  допущенные Values (род 0 → 5 из `lmx_graph_invoke_data_value`).
- Ветвь «запись без фактических» стоит раньше ветви прежнего чтения: иначе `Twice()` у Structure внутри `fn`/`sub`
  уходила в `lmx_graph_eval_launch_given` и отвечала 2.
- Граница прежних программ. Structure, объявленная внутри `fn`/`sub`, держит прежнее чтение «над собой» и для записи с
  фактическими (`lmx_graph_eval_launch_given`); без этого три зелёные строки (`struct_launch_given`, `_method`,
  `_literal`) падали до 5 (измерено на комплекте `coder-k2s2d`). Нормативный путь — там, где `parent(C)` настоящий.
- Ссылка — универсальная. `@: p Model` — место универсальной ссылки, `Model` — её первое значение, не требование
  (L2_spec, reference places; автор 2026-11-23: требование ссылки пишется только в голове `Model@: p`). Первая моя
  проба ожидала отказа 4 до эффектов у `Add\add(Other)` при входе `@: target Box`; ожидание было выведено из неверного
  чтения записи (модель вторым аргументом), и по указанию Sol проба заменена: `Other` допускается, а путь `target\q`
  без `q` отказывает после входа обычным отказом пути. Требование типизированной головы `Model@` — отдельный долг
  (сегодня вызов отвечает 5: `lmx_graph_declaration_receiver` не относит такую голову ни к одному семейству); не
  подменяется через `@: p Model`.

Нативный эмитент (`selfbuild/src/l2src/l2_graph_tool.lm2`, `lm_graph_emit_application`): запись с фактическими у
обычной Structure испускает `LmxWalkValue` и вызов `lmx_graph_eval_structural(l2_g, lmx_call_code, structure,
<адрес фактических>, 0, @ value)` — один путь с интерпретатором; подстановки данных в образе больше нет. Запись без
фактических — прежний `lmx_graph_call_data(l2_g, 0, structure, 1)`. Экспорт 92 (`selfbuild/tools/build.lm2`,
`graph_run_names`).

## Строки-свидетели

Ожидания записаны до прогонов (`CF/k2s2-01/NORM-S2-ROWS.md`; ожидания четырёх строк ссылки — в заголовках строк, до
прогона на кандидате; `CF` = `build2/codex_fix250generationchain01`). Строки — корневые описания с входом `Main`: у
обычной Structure, объявленной в данных `sub: main`, родителя нет, и там держится прежнее чтение.

| Строка (`selfbuild/tests/graph/`) | Форма | Наблюдаемое | Ответ |
| --- | --- | --- | --- |
| `struct_actual_book_example` | `Step\add()`, `Step\add(x := 2)`, `call(Step\add)` | steps 12, x 5 | 0 |
| `struct_actual_two_inputs` | `Sum\add(7)`, `Sum\add(b := 3)`, `Sum\add(b := 3; a := 4)` | steps 128 (72 + 13 + 43) | 0 |
| `struct_actual_after_structure` | вход `x` после соседней Structure: `Add\add(x := 7)`, `Add\add(9)` | named 7, positional 9 | 0 |
| `struct_actual_after_return` | вход после `return`: результат потреблён | named 8, positional 10 | 0 |
| `struct_actual_opened` | чтение E: `Sum\add(Args)`, `Sum\add((int: b 4))` | steps 87 (73 + 14) | 0 |
| `struct_actual_reference` | `Add\add(Box)`, вход `@: target Box` | `Box\q` 11 | 0 |
| `struct_actual_reference_not_default` | `Add\add(Box2)`: умолчание `Box` называет не модель | `Box2\q` 15, `Box\q` 1 | 0 |
| `struct_actual_reference_other_shape` | `Add\add(target := Other)` — Structure иной формы допущена, тело пишет `target\z` | `Other\z` 11, `Box\q` 1 | 0 |
| `struct_actual_reference_untyped` | `Add\add(Other)`, вход `@: target` без первого значения | `Other\z` 11 | 0 |
| `struct_actual_reference_path_absent` | `Add\add(target := Other)` при входе `@: target Box`; тело читает `target\q`, которого у `Other` нет: отказ пути после входа | `Log\entered` 1, `Log\after` 0 | 3 |
| `struct_actual_default_suppressed` | `Sum\add(7)`, `Sum\add()`; вход `a` вычисляется `bump()` | calls 1, steps 164 | 0 |
| `struct_actual_two_occurrences` | `D1\C1(x := 7)`, `D2\C2(x := 7)`, `D2\alias(x := 7)` | 17, 27, 17 | 0 |
| `struct_actual_named_data` | `Add\add(data := bump())`, вход `data` есть (парный контроль) | before 1, calls 1, q 5, after 2 | 0 |
| `struct_actual_named_unknown_refused` | `Step\add(data := bump())`, входа `data` нет | before 1, calls 0, after 0 | 5 |
| `struct_actual_declaration` | `Sum\add(int: b bump())` | before 1, calls 0, steps 0, after 0 | 4 |
| `struct_actual_kind_refused` | `Sum\add(Box)` | before 1, steps 0, after 0 | 4 |

Ответы 4 и 5 — по ответам Astra (Q4): форма достигла приёма, ни одна не допущена — 4; ни одной пары по форме — 5.
Объявление как фактический — Structure на своей позиции, которую вход `int` не принимает (книга
#declaration-arguments, Р157, Р158; как вызов `fn` в строке `c6_decl_folded`). Ответ 3 строки
`struct_actual_reference_path_absent` — обычный отказ достигнутого пути после входа, не неоднозначность пар.

На комплекте S1 (`CF/k2s2-01/rows05-s1`, 17:57, девять строк) семь строк отвечают 5: book_example (steps 5),
two_inputs (steps 0), after_structure, after_return, default_suppressed, named_data, named_unknown_refused. У
последних двух `bump()` успевает выполниться один раз до отказа (calls 1); после S2 вызовов 0 — имя без входа
отказывает до чтения значения. Две строки завершаются прежним чтением «тело над поданными данными»: `opened` — steps 87
(та же цифра другим механизмом), `kind_refused` — steps 12 и after 2 вместо отказа. `declaration` в итоговой форме на
комплекте S1 отвечает 2 (`rows08-s1`), наблюдаемые те же. `reference` и `two_occurrences` в итоговой форме на
комплекте S1 не прогонялись: `reference` даёт `Box\q` 11 прежним чтением по чтению кода — эту строку наблюдаемые не
различает.

Три строки пришлось исправить после первых прогонов — ошибка была в строках, не в ядре: `declaration` — три формы
(итоговая — отказ 4 по норме; на S1 та же строка даёт 2); `two_occurrences` — без `return: int` в D1 и D2
потреблённое значение отказывает до эффектов; `reference` — переписана на ссылку Structure, поданную целой. Четвёртая
поправка — по указанию Sol (`CODER-K2-S2-WIDE-20261125-01-ASTRA-ANSWER`): проба, ждавшая отказа 4 у `Other` при входе
`@: target Box`, была выведена из неверного чтения записи и заменена строками `other_shape`, `not_default` и
`path_absent`.

Семь прежних строк держат вердикты: `struct_launch_given`, `struct_launch_method`, `struct_launch_literal`,
`ordinary_data_model` — 0; `launch_extra_field_refused`, `launch_required_missing_refused`,
`launch_twice_field_refused` — 5.

## Проверки

Комплект `coder-k2s2g` (цепочка 7, `CF/k2s2-01/chain07`): stage `CF/coder-k2s2g-build-01`, tool `ffa37a31`, frontend
`coder-k2s2g-feh01` `2c00a444`, runtime `coder-k2s2g-rt02` `317ea072` (observe `8a22f7e4`), graph `11534be4`.

- Двадцать три строки (16 новых и 7 прежних) — PASS в interp, native и forced: 69 из 69 (`CF/k2s2-01/rows11`;
  список `CF/k2s2-01/s2-rows.tsv`).
- Широкая проверка (`CF/k2s2-01/wide01`, база — широкая проверка S1, `CF/k2s1-01/wide01`): самопроверки ядра — 16
  строк, 4 отказа — те же четыре строки `graph_call_frames` (случай 122), что на S1; полный список — 235 строк, 52
  отказа, построчно равные S1 (1631 строка PASS и FAIL, различий 0); набор фикстур графа — 665 строк: 655 равных,
  10 изменённых; зелёных 557 → 566, красных 108 → 99.
- Десять изменённых вердиктов. Девять красных строк стали зелёными во всех трёх режимах; ожидания у них записаны
  заранее и не менялись: `declarg_a03_absent_name_alone`, `declarg_a03_absent_name_then_positional`,
  `declarg_a03c_absent_computed_untyped`, `declarg_a05_outer_named_inner_name`,
  `declarg_a17_structure_passed_as_value` (пять строк долга шага 21.9 (а) с пометкой «красные по норме до шага
  21.8 (а)»; ответ интерпретатора был 5 и 4), `declsel_b02` (было 4), `declsel_g03` (было 4), `declsel_g01` и
  `declsel_g02` (интерпретатор отвечал 4 при зелёных native и forced; стало 3 — неоднозначность W и E, как записано
  в строках). Причина — ветка родов 6 и 9 в `lmx_graph_admit_field`: места `@: it`, `@: s`, `@: v`, `@: a`, `@: b`
  без записанного требования принимают Structure. Это результат общего приёма мест-ссылок: пять строк не закрывают
  весь шаг 21.9 (а), четыре — шаг 21.8 (а) (решение Sol и Astra, `CODER-K2-S2-WIDE-20261125-01-ASTRA-ANSWER`).
  Десятая — `computed_body_ordinary`, строка исторической базы с чтением «тело над поданными данными»: ответ 4 → 5,
  красна на обоих комплектах.
- Повтор набора фикстур графа на финальном кандидате (`CF/k2s2-01/wide02`, 21:03): 665 строк построчно равны первому
  прогону, в том числе чтения W и E строк `declsel_g01` и `declsel_g02`. Три изменённых файла ядра в дереве побайтно
  равны стадии комплекта.
- Манифест входов: 1866 файлов, `48c79386` (`selfbuild/inputs.sha256`; было `079aedd5`, 1834 файла); сверка
  репозитория и стадии — 0. P0 трёх изменённых файлов L2 через lmx-dev (связка `accepted`): пройден, диагностик 0.
- Docs check — индекс 306.

## Открыто

- Строка неоднозначности (две допущенные пары → 3) не написана: у скалярных входов W не допускается, и естественной
  программы, где W и E допускаются вместе, не найдено.
- Позиционный фактический старой тройки сохраняет номер позиции среди всех полей; тройку держат прежние строки
  `ordinary_data_model` и `call_frame_local` — до S3.
- Слово `data` в коде — ресивер: вход с именем `data` объявлен, но по имени не читается; парный контроль наблюдает
  поданный фактический по эффекту.
- Запись места вызывающего из тела обычной Structure (проба `CF/k2s2-01/probe-ref/probe_scope.lm3`): `b := 1` голым
  именем отвечает 3, `node\c := 1` отвечает 3, а корневая Structure по имени видна (`Log\a := 1` даёт 1). Решение Sol и
  Astra (`CODER-K2-S2-WIDE-20261125-01-W2-ASTRA-ANSWER`): S2 это не блокирует; `node\c` внутри `Add\add` адресует
  `Add`, где `c` нет, и отказ 3 закономерен; отказ 3 на `b := 1` — отдельный дефект выбора и записи места вызывающего
  (полагается `Main.b` той же записи); локализация — отдельный срез после публикации S2. Поэтому `entered` в строке
  `struct_actual_reference_path_absent` — поле Structure.
- Требование типизированной головы `Model@: p` (вместе с полным Value, через `lmx_graph_source_interface`,
  `skip_unused = 0`, с контролем `meta\leaf`) — отдельный срез; сегодня вызов отвечает 5.
- Самопроверка `graph_call_frames`, случай 122 — отдельный срез с одной трассой.
- Далее S3: для `call` остаются ровно `[code]` и `[args, code]` через общий связыватель.

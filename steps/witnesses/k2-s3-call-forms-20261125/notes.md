# K2, S3: для `call` остаются ровно `[code]` и `[args, code]` — промежуточное состояние (не принято), 2026-11-26

План [29.4](../../../next_core_tasks_v3.md#k2-20261125). Это свидетельство промежуточного коммита по приказу автора
проекта от 2026-11-26 («перед остановкой закоммитить и запушнить промежуточные результаты»): срез **не принят** — три
проверки приёмки, которые запросил автор, закрыты не все. Координаты: дизайн S3 — Sol и Astra
`CODER-K2-S3-DESIGN-20261125-01-ASTRA-ANSWER`; правило перевода — `CODER-K2-S3-STATE-E-20261126-01-SOL-ASTRA`;
разбор A–F — `CODER-K2-S3-RESUME-20261126-01-SOL-ASTRA`; уточнение автора о выборе до вычисления аргументов —
`CODER-S3-STATIC-ADMISSION-AUTHOR-20261126-01` и `…-SEAMS`; прямое машинное ребро —
`CODER-S3-DIRECT-NATIVE-ASTRA-20261126-02`. S1 — [свидетельство](../k2-s1-input-pass-20261125/notes.md), S2 —
[свидетельство](../k2-s2-structural-actuals-20261125/notes.md).

## Норма

`#structural-call`: формы после однозначного выбора — `call(C)`, `call(A C)`, `C()`, `C(args)`; исполняется выбранная
C, DATA — её настоящий `parent(C)`; «call(code := C) explicitly supplies C as code and excludes the unwrapping of that
argument»; «if the whole C suits the form call(code) and its fields suit the form call(args code), the record call(C)
is an error of ambiguity»; «Values already obtained are not evaluated again». `#declaration-selection` (семь шагов;
шаг 4: «Checks available before argument effects occur first»), `#selection-examples` (C11, C12), `#null-parent`,
`#data-code-roles`, `#call-frame-20261115`, `#return-in-data`. Уточнение автора 2026-11-26: поля P известны, только
когда конкретная P есть в лексическом пространстве; аргумент не исполняется ради выяснения, будет ли вызов принят;
неизвестный аргумент, для которого хотя бы одно допустимое будущее значение даёт обе карты чтения, — ошибка
трансляции; интерпретатор применяет ту же проверку при подготовке вызова, до эффекта; явное имя формального исключает
раскрытие.

## Что было (комплект S2, HEAD `c1422be73`)

У ресивера `call` в таблице оставались прежние формы: `[data, code]`, `[args, data, code]` и именованный `data :=` —
подстановка данных, которой в книге нет (пример книги и нормы: «A call cannot supply a replacement parent»). Ядро
держало два пути запуска (`lmx_graph_launch_structure_values`, `lmx_graph_invoke_data_value`), эмитент повторял выбор
форм и чтение операндов в сгенерированном коде.

## Механизм (`selfbuild/src/l2src/lmx_graph_run.lm2`, `l2_graph_tool.lm2`)

| Часть | Строки | Что |
| --- | --- | --- |
| `lmx_graph_receivers_open` | :9646 | две формы `call`: `[code]` и `[args, code]`, оба формала `required`; прежние формы — не форма: связыватель отказывает (5) до всякого операнда |
| `lmx_graph_call_record_reading` | :7536 | чтение записи с одним позиционным актуальным: актуальный без эффекта (имя, путь, написанная группа — конкретная P лексического пространства) читается, и чтения «как написано» и «по полям» (`lmx_graph_receiver_opened`) считаются; актуальный, полученный исполнением, НЕ вычисляется: по описанию не Structure — 5, может быть Structure — 3 (значение из двух полей есть code и (args, code) сразу), до эффекта (уточнение автора) |
| `lmx_graph_eval_explicit_call_value`, `lmx_graph_call_explicit`, `lmx_graph_launch_prepared` | :7615, :7789, :7758 | обе формы — один вызов: выбранная C над физическим `parent(C)`; цель читается один раз в очередь своего операнда и передаётся удержанным адресом; корни GC — три записи в исполнителе (`computed_roots`, `code_roots`, `whole_roots`) и одна в вызове (`values_roots`), одна пара mark/restore на всех выходах; DATA = `parent(C)`, поля A связываются с входами `lmx_graph_pair_structural_opened`; нулевой parent разрешён и на входе не проверяется |
| `lmx_graph_select_whole` | :6577 | целое чтения E читается без эффекта (написанная группа, имя, путь); актуальный с эффектом до выбора не читается — ни в `C(A)`, ни в выборе среди объявлений, ни в запросе описания вложенного вызова (`lmx_graph_described_value` проходит здесь снова) |
| `lmx_graph_eval_structural`, `lmx_graph_select_call` | :7148, :6953 | после того как чтение W допустило единственный актуальный по описанию: вход, принимающий только примитив, исключает E (для каждого значения одно чтение); вход, принимающий Structure, допускает значение из одного поля в обоих чтениях — потенциальная неоднозначность, 3 до выполнения актуального |
| `lmx_graph_call_diagnosis`, `lmx_graph_structural_diagnosis` | :7562, :7275 | те же вопросы для транслятора, ничего не исполняют; экспорт 95 имён (`selfbuild/tools/build.lm2`, `graph_run_names`) |
| `lm_graph_emit_call_diagnosis`, `lm_graph_emit_structural_diagnosis`, `lm_graph_emit_record_diagnosis` | `l2_graph_tool.lm2` :841–:886 | транслятор задаёт вопрос до генерации кода вызова (запись `call(...)` как оператор и как значение, применение `C(A)`); отказ — строка в stderr `graph: call: refused at translation, answer 3: …` (или `answer 5`, или `graph: Name(A): refused at translation …`), ответ эмиттера равен ответу интерпретатора, образ не пишется |
| `lm_graph_emit_explicit_call` | `l2_graph_tool.lm2` :892 | запись `call` в нативном теле читается исполнителем ядра (`lmx_graph_eval_explicit_call`), формы и операнды в эмитенте не повторяются |
| `lm_graph_emit_methods` (адаптер) | `l2_graph_tool.lm2` :2213 | машинное тело идёт только объекту метода; запись-объявление, выбранная целиком (FN-объект как `code`), идёт исполнителем открытого кадра (`lmx_graph_method_run_value`) — как в интерпретаторе; прежде native отвечал 1 из `lmx_graph_work_scope` |

У строки графового набора с pin `3` native отказывает на emit-check со строкой `graph: emit answered N`.
Тестовый инструмент проверяет ответ фазой эмиссии и не продолжает сборку. Отдельный интерпретатор отвечает N
и печатает AFTER. Forced образ запускает тот же интерпретатор и отказывает при запуске до вычисления аргумента.

## Кандидаты

| комплект | стадия | tool | frontend | runtime | graph | состояние |
| --- | --- | --- | --- | --- | --- | --- |
| E `coder-k3se` | `CF/coder-k3s-build-06` | 9f8325e2 | 38f7a988 | 28088165 / be0908a2 | 1cdb6ba2 | проверен 07:21; не принимается: выбирает после вычисления аргумента |
| F `coder-k3sf` | `CF/coder-k3s-build-07` | fb6756ea | a935cf3d | 28088165 / be0908a2 | 98210b0a | native-маршрут не собрался (поле локального кадра в сгенерированном L1) |
| G `coder-k3sg` | `CF/coder-k3s-build-11` | 54ac5c7c | faaef3ed | 2e21b2cf / 92ac2841 | 3687ed3c | интерпретатор отказывает до вычисления, native-диагностика не срабатывает |
| H `coder-k3sh` | `CF/coder-k3s-build-12` | 5bd6cb64 | 5dc11ce4 | 6536f037 / 46bab479 | 7d103cd0 | есть native-отказ с ответом 3 |
| I `coder-k3si` | `CF/coder-k3s-build-13` | a92853bc | 19f17ce7 | 6536f037 / 46bab479 | 04e1f616 | 36/48. Один отказ инструмента и 11 ложных native-отказов на `code :=` |
| J `sol-k3sj` | `CF/sol-k3s-build-14` | a0b0812f | 8c60899a | e28551ab / 85d24d20 | 613bb1a2 | Оба дефекта I исправлены. 48/48 |
| J1 `sol-j1` | `CF/sol-j1-build-15` | a0b0812f | 8c60899a | afbf8fae / 2f8db214 | d22fb9a0 | `length` и `typeof` имеют известный результат `int` при подготовке вызова. 54/54 |

`CF` = `build2/codex_fix250generationchain01`; база всех — принятый комплект S2 `coder-k2s2g`.

## Строки-свидетели (`selfbuild/tests/graph/`)

Новые (23): `call_old_named_form_refused`, `call_old_triple_form_refused` (прежние формы — 5 до эффекта); `call_args_positional`,
`call_args_named`, `call_args_value` (`call(A C)` и `call(args := A; code := C)`, значение по `return: int` данных — 73);
`call_code_statement` (`call(code := Sum\add)` — 12); `call_chosen_target_held` (цель прочитана один раз: first 7, second 0);
`call_code_from_call`, `call_args_from_call` (операнд, полученный исполнением, в обоих порядках: made 1, seen 7, after 1);
`call_in_fn` (то же с входом Main); `call_computed_single_ambiguity` (`call(D\Mk())`: отказ до Mk — made 0, steps 0,
after 0; pin `3 1 3`); `call_producer_once` (положительный контроль: 139, 47, 106, made 2, D\x 99);
`call_point_own_and_parent`, `call_own_place_not_published`, `call_computed_line_parent_place`,
`call_literal_line_parent_place`, `call_parent_place_missing_refused` (собственное и родительское место, класс M1);
пять построения — `construction_path_choice`, `construction_redirect_current`, `construction_index_changed`,
`construction_word_vs_named_path`, `construction_path_ambiguity`; `place_missing_selector_reached` (достигнутое
чтение отсутствующего поля при существующем формальном: 4).

Заменены (25; строки описания HEAD сохранены дословно, добавлена заметка «Step 21.7 K2, S3»): `given_data_structure`,
`var_copy_nesting`, пять `marks_*_supplied`, `declaration_site_projection`, `declaration_site_missing`, `declsel_c09`,
`declsel_c10`, `declsel_launch_calls`, `callable_over_given_data`, `deferred_reference_places`,
`deferred_reference_type_refused`, `frame_computed_description`, `ordinary_data_model`, `ordinary_data_launch`,
`physical_reference_int_refused`, `physical_reference_structure_refused`, `physical_reference_type_only`,
`place_reference_unknown`, `struct_launch_given`, `struct_launch_literal`.

Машинная строка полного списка: `selfbuild/tests/dyn/graph_call_explicit_roots.lm2` (вход `cer_roots_check`): сборка или
новая ссылка во втором операнде и в теле не уносят цель, A и Values — 7 на native и forced. Переведены по правилу Sol:
`frame_description_gc.lm2`, `graph_scalar_working.lm2`, `graph_fn_data_typed.lm2`.

Правило перевода (Sol и Astra): (а) данные — Structure источника: структурная связь, тело записывается внутрь данных и
запускается по пути; (б) тело обязано работать над другими данными: наблюдатель с одним именованным ссылочным входом,
объявленным в родителе; (в) данные строит само тело: Structure-потомок этого объекта; (г) строки-отказы — отказ по норме
с выведенными номером и моментом. Замечания разбора A–D учтены: эффект `touch` виден явной записью с положительным
контролем (четыре строки); метка между проверками p и s; локал после голой записи вынесен явной записью (17/1, 1/2);
«call(D; C) is no form» переписано — два позиционных подходят внешней форме `[args, code]`, снята подстановка DATA
(на этих сценах старый источник отвечает 5).

## Проверки

На E (кандидат E, `CF/k2s3-01/wide04`, `wide06`): список строк среза — 46 из 46 с exit 0; самопроверки ядра — 17 строк,
0 отказов; полный список — 236 строк, 48 отказов (S2: 235/48); набор графа — 686 строк, зелёных на трёх маршрутах 581
(S2: 566 из 665): 21 новая зелёная, 25 заменённых зелёные, 6 исторических зелёных на S2 стали красными
(`callable_data_call`, `code_data_no_var`, `computed_line_publishes`, `construction_index_word`,
`construction_path_ambiguous`, `literal_line_count` — источники и pins сохранены как история), 13 красных на обоих.

На J проверены исходники дерева и стадии по манифесту из 1923 файлов. Выходы rt01 и rt02 совпали побайтно
для обоих объектов runtime. Два исправленных файла прошли P0 (расписки `102525-d1eed7207a72` и
`102527-3c2f87bacc57`). Срез из 48 строк и 17 самопроверок ядра прошли. В полном списке 236 строк и
48 прежних отказов. Все записи PASS/FAIL совпали с S2 после добавления шести результатов новой строки
`graph_call_explicit_roots` (native и forced, сборка и два корня). В графовом наборе J на прежних pins из 688
строк прошли 576. Относительно S2 609 расписок совпали полностью, 56 изменились, 23 строки новые.

Относительно E у четырёх прежних зелёных строк native-отказ переместился в трансляцию. Результат
интерпретатора (3) и AFTER сохранились. Активный pin этих четырёх строк теперь `3 1 3` вместо `1 1 3`:
`computed_body_ambiguous_refused`, `declsel_c02`, `declsel_c11`, `declsel_c12`. Исходники и `.expected` совпадают.
У `computed_data_reentry` транслятор диагностирует поздний `call(outer\data\bump)`, а интерпретатор
уже останавливается с 4 на предыдущем `fncall`. Это разные достигнутые операции.

J1 объявляет скалярный результат `length` и `typeof` при подготовке. `c6_receiver_result` снова выбирает
целочисленный вход и даёт `seen=2`. `select_group_receiver`, четыре строки с новым pin и все 48 строк среза
прошли в трёх режимах. Широкий повтор J1 дал 581/688: 683 расписок полностью совпали с J, изменились
ровно `c6_receiver_result` и четыре pin по фазе. Runtime и Graph пересобраны, tool и frontend взяты из J.
Расписки J и J1 находятся
в `CF/k2s3-01/sol-j-accept-20261126` и его подкаталоге `typed-intrinsics`.

## Три проверки приёмки (запрос автора через Sol, `CODER-S3-THREE-ACCEPTANCE-VERIFY-20261126-02`)

1. На J и J1 native emit-check для `call(D\Mk())` сообщает `graph: call: refused at translation, answer 3` и
   `graph: emit answered 3`. В расписке нет шагов L1→C, компиляции или исполнения native. В отдельном запуске
   J с ожидаемым успехом драйвер завершился кодом 1 при внутреннем статусе 3.
2. На J отдельный interp того же исходника отвечает 3. AFTER показывает made=0, steps=0, after=0.
   Forced с исполнением через интерпретатор даёт тот же AFTER. Однозначный `call_producer_once` проходит
   во всех режимах с plain=139, named=47, positional=106, made=2, base=40 и x=99.
3. Прямое native → native ребро для обычной Structure (определение машинного тела и прямой вызов из другого машинного
   тела в том же L1/C) остаётся отдельным срезом K4. Для первой пробы достаточно однозначного
   `call(code := D\C)` с результатом 139. Нужно предъявить прямой вызов с обычными C-параметрами
   и необходимыми скрытыми связываниями, а также результат исполнения именно этого образа.
   Named и positional в `call_producer_once` сохраняются как контроли общего поведения.

## Открыто

- Проверка 3 (выше). Пять проб разрешения имени на G сохранены в `CF/k2s3-01/helper5-run/on-g`.
- `select_computed_opened` отказывает с 4. По действующему правилу `merge(A; B)` без группы поставляет
  два поля как два позиционных аргумента и здесь должен дать `seen=12`. Для `select_receiver_sole_ref` тот же
  поток не помещается в один вход. J отказывает с 3, требуется отказ формы. Старое `seen=2` применимо к
  явно сгруппированному потоку, поданному под именем входа. Ожидания этих двух строк сохранены.
- 12 предложенных helper источников по 13 строкам, красным на обоих комплектах, проверены на G.
  Совпал `deferred_binding_priority`. Остальные варианты не включены в дерево.
- FN-объект как `code` (`call(code := f)`): открытая граница; `m_fn_object_statement` — диагностический свидетель
  прежнего набора (в CF, не в дереве); форма `fn` снята даже как написание.
- Шесть исторических строк без переподгонки pins; требование типизированной головы `Model@: p` — шаг 21.8; `fncall` — S4.

## Уроки

- Поле локального значения нельзя передавать аргументом: `whole\ref` понижается в `whole, ., ref` в C; сначала
  присвоить локалу `@:`. Ошибки C видны только на шаге `build-runtime` (1,5 минуты цепочки): L2-проверка их не ловит.
- Ручная трансляция модуля (`k2_l2_check_any.py`) берёт исходник из дерева и копирует его в стадию; прежний
  `k2_l2_check.py` транслировал копию стадии.
- Перед сборкой свободный commit должен быть не меньше 2 ГБ; иначе watchdog останавливает сборку (`STOPPED-BY-WATCHDOG`),
  и цепочку повторяют в новой стадии.
- Нулевой счётчик в источнике не различает отсутствие вызова и вызов с локальной записью: эффект должен писать в граф
  явно, с положительным контролем видимости.

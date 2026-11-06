# Срез 285 — `sub` из трёх частей: args, var и body (SUB-OWN-FIELD-CALL)

Опубликован 2026-11-06, Opus. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md#code-data-occurrences). Норма: [семантика](../../../docs/LMX_semantics.ru.md#method-parts), :437 — вызванное `fn`, `fm`, `sub` или `catch` представлено одной Structure, `args`, описание `return` там, где оно есть, `var` и `body` — её адресуемые части; :439 — одноаргументное `call: code` берёт `var` выбранного `code` и без неё не подставляет само `code`; :447 — `sub` не возвращает значение; :451 — собственное поле метода физически принадлежит части `var`. Ответ Codex на два вопроса нормы ([дословно](records/pins/codex-285-norm-answers.txt), CODEX-OPUS-285-NORM-ANSWERS-20261106T002216Z-01): вариант с `var` у `sub` верен; у `sub` без результата три части, фиктивное адресуемое `return` не добавлять; начать с конкретного `sub`, связанных потребителей исправить вместе, `fm` и `catch` проверить в затронутом объёме, остаток честно OPEN. Норма и книга не менялись.

P = build2/codex_fix250generationchain01. Архивные копии в [records](records) приведены к UTF-8 LF без BOM, хвостовых пробелов и цветовых кодов терминала; оригиналы в P связаны с [evidence.sha256](evidence.sha256).

## На опубликованном кортеже 284

Пробы и свидетели на кортеже boot146a ([sep285](records/pins/tp147-probe-sep285.terminal.txt), 04:42:40.2609807Z→04:42:53.2832461Z, 10 отказов в 5 рядах), те же ряды на G2 boot147a — [sep285c](records/pins/tp147-probe-sep285c.terminal.txt), 04:43:12.1695587Z→04:43:37.7979833Z, `SUITE 5 rows, 0 failures`:

| Запись | 284 | 285 |
| --- | --- | --- |
| [p283ah](records/cold-tp140/tests/dyn/p283ah_sub_own_direct.lm2): `sub` с полем `int: w 6`, прямой вызов | native `walk error: UNSUPPORTED`, forced `INVALID` | 7 |
| [p285b](records/cold-tp140/tests/dyn/p285b_sub_parts.lm2): те же формы, что в `sub_parts` | так же, на первом вызове | 7 |
| [p285a](records/cold-tp140/tests/dyn/p285a_fn_baseline.lm2): формы `fn` — поле опубликовано и прочитано путём, свободный вход связан полем вызывающего, объявленный `throws` с полем | 7 | 7 |
| `sub_parts` | отказ трансляции `unknown field path segment`, 164:24, `atom=body`: у плоского `sub` нет части `body` (`direct\body\w`) | 7 |
| `sub_return_refused` | тот же отказ `unknown field path segment`, 6:10 | отказ `unknown field path segment`, 6:10 |

Формы `fn` работали и на 284; у `sub` с собственным полем не работал ни один вызов. `sub_return_refused` не разделяет кортежи: у плоского `sub` 284 частей не было вовсе, и `s\return` уже читалось как неизвестное имя. Ряд держит другое — что у `sub` трёх частей нет части результата; без него выжил бы мутант `noshift` (таблица ниже). Первый замер p283ah на этом кортеже — [e01](records/pins/tp146-probe-e01.terminal.txt), p285b — [b02](records/pins/tp147-probe-b02.terminal.txt); в [b01](records/pins/tp147-probe-b01.terminal.txt) сама проба ещё не транслировалась (50:9, `node\seen` в `Subs\s`, где `node` — `Subs` без поля `seen`).

## Где был дефект

Транслятор строил `sub` плоской Structure обычной роли: слот 0 — `args`, слот 1 — пустая часть с именем `return`, дальше ячейки собственных полей и операторы тела вперемешку, затем трейлер. `var` не было. `lmx_call_unary_data` искал часть `var` по имени и не находил, данные вызова — 0. Тело native читало своё поле через данные и карту code→data (`lmx_call_index`): при `self` = 0 — UNSUPPORTED. Обходчик активировал весь `sub` как его собственное тело без данных — INVALID. У `fn` роль FN и четыре части, поля он читает из своих частей.

Попутно найдено: `lmx_activation_input_cell` со среза 258 считал `sub` любую Structure обычной роли ровно из трёх полей. Под это попадал `sub` с одним оператором; `sub` с двумя операторами или с полем свой свободный вход по цепочке не находил.

## Механизм

- **Производитель.** Ресивер `sub` даёт результату ту же роль пула, что и `fn` (вызываемое, произведённое ресивером), и тот же построитель частей: три части `args`, `var`, `body`, части результата нет. Роль ставит производитель, форма Structure ничего не классифицирует.
- **Фронтенд.** `lm_compiler_fn_parts_on` включает `sub`. Номер части во всех записях транслятора — номер контракта: 0 `args`, 1 `return`, 2 `var`, 3 `body`. Физический слот даёт новая экспортируемая `lm_compiler_part_slot`, у `sub` `var` и `body` на слот ниже, `return` нет. Её спрашивают: части заголовка (у `sub` контейнера результата нет), построитель частей (слоты `var` и `body`), имена частей, ширина головы `lm_compiler_m_head`, шаг-часть пути (`lm_compiler_path_step_slot`) и его ребро в обходимых кадрах, адрес собственного поля в части (`lm_compiler_own_from_expr`). `lm_compiler_method_part_seg`: части, которой у метода нет, нет и в пути, `s\return` отказывает как любое неизвестное имя.
- **Ядро.** Новая экспортируемая `lmx_callable_part(arena, code, part)`: роль FN и четыре поля — номер как есть, три поля — `args` 0, `var` 1, `body` 2, `return` нет; иначе SIZE_MAX. Её спрашивают активация обходчика (`var`, `body`), данные унарного вызова (`var`), ширина входов обходчика и вход по цепочке (заголовок), объявленный `throws` (тело), обходчиковый вызов (заголовок результата — только там, где есть часть результата), поиск собственного поля над стоящим в месте callable (`var`, `body`). `lmx_callable_headers`: три части — `args` и никакого заголовка результата; выбранный вызов без заголовка результата результата не ждёт; квалификация копии графа принимает три или четыре части. Ветка входа по цепочке для Structure обычной роли из трёх полей снята: у `sub` теперь роль, у обычной Structure заголовка `args` нет.
- **tools/build.lm2.** Два экспорта: `frontend_value_names[148]` `lm_compiler_part_slot`, `implements_names[70]` `lmx_callable_part`. Новый G0: tool147a.

Runner, cache, второй resolver и скрытые корни не вводились.

## Свидетели

[tests/dyn/sub_parts.lm2](../../../selfbuild/tests/dyn/sub_parts.lm2), native и forced, оба roots:

| Код | Что проверяет |
| --- | --- |
| 81 | `sub` с собственным полем, прямой вызов |
| 82 | тот же вызов ресивером `call: grow` |
| 83 | поле опубликовано после вызова и читается путём: `grow\w` = 7 |
| 84 | `sub` с формалом и полем |
| 85, 86 | свободный вход `quote`: лексический в корне, связанный полем вызывающего `bound` |
| 87–89 | объявленный `throws: Bad` у `sub` с полем: без броска и с `catch: Bad (int: value)` |
| 90–92 | `sub` в месте callable (`Subs\s()`), после перепривязки другим `sub`, его поле по имени `Subs\s\w` |
| 93 | поле через часть тела: `direct\body\w` |
| 94 | тело `sub` в свободном держателе заменено по имени `held\body: from\body`: слово уходит, обходчик исполняет новое тело |
| 95 | явные данные — своя часть: `call: direct direct\var` |
| 96 | `sub` с машинной операцией остаётся native при `--walk-methods`: обходимый вызывающий ловит его `Bad` по ключу из `throws` в части тела |
| 97 | `immutable: merge(Holder)`, где в `Holder` лежит `sub`: квалификация копии принимает вызываемое трёх частей |
| 98 | `sub`, определённый в теле `fn`, с собственным полем |

[sub_return_refused](../../../selfbuild/tests/dyn/sub_return_refused.lm2): `int: n s\return` — отказ трансляции `unknown field path segment` на `return`: у `sub` трёх частей нет части результата.

## Мутанты

Каждое место отдельно: 12 мутантов ядра — каждый своей сборкой runtime на fe147a, 14 мутантов фронтенда — каждый своей сборкой FE на rt147a, инструмент tool147a. Шесть рядов `mut285-list.tsv` (`sub_parts`, `sub_return_refused`, `callable_place_fields`, `code_write_words`, `free_pointer_paths`, p285a) в обоих режимах; после каждого мутанта стадия восстанавливается из варианта ([mut285.txt](records/pins/mut285.txt)). Мутант возвращает на своём месте поведение 284: только четыре части, без сдвига, без ветки для `sub`. Происхождение: мутанты ставил и снимал scratch-скрипт (таблица замен на Python и циклы bash), что запрещено правилом о вспомогательных скриптах; его вывод — данные этой записи, сам скрипт в запись не входит. Рецепты `.command` этого среза получены из рецептов 284 заменой имён тем же способом; каждый проверен своим прогоном.

| Мутант | Место | Итог |
| --- | --- | --- |
| kpart3 | `lmx_callable_part`: у трёх частей нет ни одной | убит: `sub_parts`, `callable_place_fields`, `code_write_words`, `free_pointer_paths` |
| kheaders | `lmx_callable_headers` только для четырёх частей | убит: `sub_parts`, все режимы (native: `call: grow` — `walk error: UNSUPPORTED`) |
| kheaders3 | без заголовка результата ответа нет | убит: `sub_parts` |
| kownpart | поле над местом callable ищется только в четырёх частях | убит: `sub_parts`, `callable_place_fields` |
| kthrows | `throws` ищется только в теле четырёх частей | выжил на кодах 81–95; убит кодом 96: бросок native-`sub` через границу в forced не пойман |
| kwidth | ширина входов обходчика только у четырёх частей | убит: четыре ряда |
| kactivate | обходчик активирует только четыре части | убит: четыре ряда |
| kunary | данные короткого вызова только у четырёх частей | убит: `sub_parts` |
| kinputcell | вход по цепочке только по заголовку четырёх частей | убит: `sub_parts` (код 86), `free_pointer_paths`, `code_write_words` |
| kresult | обходчиковый вызов читает часть 1 заголовком результата всегда | выжил |
| kselected | выбранный вызов считает записи отсутствующего заголовка | убит: `sub_parts` |
| kqualify | квалификация копии — только четыре части | выжил на кодах 81–96; убит кодом 97: `immutable: merge` от Structure с `sub` — `walk error: INVALID` |
| returnpart | шаг пути берёт часть, которой у метода нет | убит: `sub_return_refused` |
| retname | слот 1 всегда называется `return` | убит: построитель программы не проходит, четыре ряда |
| ownslot | адрес поля без записанного держателя — номер части | выжил |
| stepslot | шаг-часть пути — номер части | убит: `sub_parts` в native-корне, `invariant: a field path met no Structure` |
| edgeslot | ребро шага-части в обходимых кадрах — номер части | убит: `sub_parts` в обходимом корне, `walk error: INVALID` |
| partnames | имена `var` и `body` переставлены | убит: `sub_parts` (код 94), `code_write_words` |
| noshift | части `sub` стоят как у `fn`, с пустым `return` | убит только `sub_return_refused` |
| subparts | `sub` снова без частей | убит: три ряда |
| headwidth | голова метода с частями — четыре | убит: четыре ряда |
| noresult | у `sub` строится контейнер результата | выжил |
| varslot | `var` на слоте 2 | убит: четыре ряда |
| bodyslot | `body` на слоте 3 | убит: четыре ряда |
| fillwidth | ширина удержанного callable с частями — четыре | выжил на кодах 81–98 |
| occwidth | ширина вхождения метода с частями — четыре | убит: четыре ряда |

Выжившие оставлены в коде и строками не доказаны:

- **kresult.** `var` у `sub` пока без полей, поэтому прочитанная как заголовок результата она даёт «результата нет» — то же, что правильное чтение. Прежний текст читал бы `var` заголовком результата, как только в ней появятся поля (VAR-PATH-OF-SHORT-FN).
- **ownslot.** Ветка `lm_compiler_own_from_expr` для поля без записанного держателя: поля частей держатель имеют, ни один ряд сюда не доходит. Прежний номер части у `sub` указывал бы не на тот слот.
- **noresult.** Без проверки у `sub` строится заголовок результата, а слот 1 затем занимает `var`: фрейм остаётся, его не держит ни одна часть. Наблюдаемой разницы нет.
- **fillwidth.** Заполнение удержанного callable (`lm_compiler_source_callable_fill`) вызывается только для представлений `merge`, дающего вызываемое, и тела результата `merge`; `sub` там ни в одном ряду нет, и локальный `sub` в методе (код 98) этим путём не строится.

Порядок прогонов. Вторая цепочка повторяла `kthrows` и `kqualify` с занятыми метками: сборка и проба отказали (`exists`), строки SUITE в журнале — старые терминалы первой цепочки, а восстановление стадии после каждого тоже отказало. Две мутации ядра стояли на стадии во время сборки FE `returnpart`; убил его отказ трансляции, к ядру не относящийся, и восстановление после него вернуло все файлы. Повторы `kthrows`, `kqualify` и `fillwidth` — третья цепочка с метками `…b`.

## Приёмка на замороженных байтах

Вход: 216 файлов (65 source, 34 tools, 117 tests), manifest `fa0b57ac7593be73799ed93d70e34bffe48c342601c37fb3f1376be0af597068`, `P/cold-boot147a`.

| Проверка | Результат | Receipt |
| --- | --- | --- |
| Focus на итоговом кандидате до whole | 01:14:03.1967844Z→01:30:14.9838130Z, SuiteExit 0, `SUITE 66 rows, 0 failures`; fe147a `ba285f6e…`, rt147a `c7140bdb…`, tool147a. Свидетель тогда с кодами 81–95; коды 96–98 добавлены позже и на том же кандидате прошли в d04, 03:45:45.3809873Z→03:45:58.7440237Z: `sub_parts` native и forced, оба roots — 7 (`sub_return_refused` стоял там строкой `runs` ради текста отказа и отказал при сборке, как должен) | [f01](records/pins/tp147-probe-f01.terminal.txt), [d04](records/pins/tp147-probe-d04.terminal.txt) |
| Whole boot147a | 03:57:21.2680811Z→04:10:52.1796326Z, BootstrapExit 0, 810.91 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях | [terminal](records/pins/boot147a-quick.terminal.txt), [log](records/pins/boot147a-quick.log), [G2](records/cold-boot147a/quick147a/g2-build.log) |
| Сверка | source 216/0; producers g1 и g2: frontend 33, runtime 39, tool 6 шагов, все exit 0; 248/248, 496 хэшей, 0 stale; 245 raw-equal; 3 равных по размеру PE отличаются только смещениями 136, 137, 216, 217; consumed 306/306 равны; working tool и bundle равны G2; driver и driver-observe G1 и G2 равны рантайму кандидата rt147a | [сверка](records/pins/boot147a-compare.txt) |
| G2 focus | 04:12:11.4579529Z→04:25:18.7230643Z, SuiteExit 0, `SUITE 66 rows, 0 failures` | [terminal](records/pins/tp147a-suite-g2.terminal.txt), [log](records/pins/tp147a-suite-g2.log) |
| G2-наблюдение | `sub285g2` 04:26:19.3783367Z→04:26:33.8658143Z, 52 PASS: `direct` 2, `grow` 1, `note` 1, `bump` 2, `risky` 2, `other_s` 1, `put_sub_body` 1. WitnessExit 0, forced в обоих roots с точными счётчиками, native не обходит ни одно: 7 тел. До запуска по forced L1 кандидата (d04) проверено, что ни одно из семи тел не держит native-слова; оно остаётся только у кода самого юнита (`l2_m22`, как `l2_m11` на 284) и у `risky_machine` с машинной операцией (код 96). Вложенные `Subs\s`, `Holder\hs` и `inner` в spec не входят | [sub285g2](records/pins/tp147a-obs-sub285g2.terminal.txt) |
| Полный список на G2 | 04:29:44.0623000Z→04:42:12.1786977Z, SuiteExit 0, `SUITE 83 rows, 0 failures` | [terminal](records/pins/tp147-probe-fullg2.terminal.txt) |
| Разделение на кортеже 284 | см. выше | [sep285](records/pins/tp147-probe-sep285.terminal.txt), [sep285c](records/pins/tp147-probe-sep285c.terminal.txt) |

Tuple G2, `P/cold-boot147a/quick147a`:

| Артефакт | SHA-256 |
| --- | --- |
| `lmxtool.exe`, `g2/tool/lmxtool-tool.exe` | `71b27bef93940cd613f94ff337b3bc1f9d27033e990401e86082596c70d38426` |
| `g2/frontend/l2trans.exe` | `34391f355af45d6b8378539d358b9e180e05a9bb72508fd2766becf1b7000012` |
| `g2/frontend/l1trans.exe` | `30818d62fb6ec43d75d2bde337ee9f56b52b63e73dded47916b5ed2d2c8d50f3` |
| `g2/frontend/l2_libc.o` | `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37` |
| `g2/runtime/driver.o` | `c7140bdb478b5b1c8b6fcb7627633d16582283064f0e8fcfdf2330e321c06591` |
| `g2/runtime/driver-observe.o` | `e339eef6dd9a18ede5dd027336eddaf8d267ebf47034cdc831f35510dcf86d16` |

G0: `P/cold-tp140/tool147a/lmxtool-tool.exe` `0a8e456d0fdec6c74ff44eb185027ba737b4a0cd46c309d7ba46b750c125d660`, собран `rebuild tool` из инструментов этого пакета ([receipt](records/pins/tp147-tool-a01.terminal.txt)): `tools/build.lm2` получил два экспорта. Предыдущий frontend — G2 среза 284, boot146a. Новый стенд не создавался: рабочий стенд `cold-tp140` совпадал с опубликованным selfbuild, изменения шли через `variants/tp147` и `pins/source-tp147.sha256`.

Посадка [land285](records/pins/land285.command): 8 шагов exit 0 ([terminal](records/pins/land285.terminal.txt)), 216 файлов, оба подмножества consumed (65 строк) равны frozen, `selfbuild/inputs.sha256` равен frozen.

## Что не сделано и записано

- **Собственные поля тела лежат в части `body`**, у `fn` как и прежде, теперь и у `sub`: `var` у `sub` пуста, `s\var\w` — `unknown field path segment`. Книга :437 и :451 относят их к `var`; это VAR-PATH-OF-SHORT-FN, теперь и для `sub`. Ячейка одна, порядок тела сохранён.
- **`fm`** транслятор не строит: `fm is not supported yet` (`lm_compiler_check_word_value`), фикстур `fm` нет. **`catch`** не менялся: обработчик, не вызываемое (:572).
- **CALLABLE-PLACE-FREE-SIGNATURE** — следующий срез, по ответу Codex, п. 3–4.
- **ROOT-POINTER-INDEX-WALKED** — разбор: индекс типизированного указателя корня `px[0U]` уходит в машинный путь по `lm_compiler_path_machine_index` (`lm_compiler_rw_prepared_value`, l2_frontend_emit.lm2), а в методе то же `px` — свободное имя и идёт общим INDEX среза 271. Codex, п. 5: отделить L3 INDEX над настоящим place от подлинной L2-операции.

## Границы и находки

- **`catch` в затронутом объёме.** Обработчик исполняется в кадре своего метода (`lmx_walk_catch_bind` → `lmx_walk_body`), а не активацией, поэтому снятая ветка 258 его не обслуживала. Коды 87–89 и 96 ловят `Bad` из `sub` в обоих исполнителях; код 96 — через границу native–обходчик.
- **Вызываемый `merge` двух `sub`** (представление T7, `lm_compiler_source_callable_fill`) ни в одном ряду не встречается; выживший `fillwidth` это и показывает. Ширина головы там спрашивается у `lm_compiler_m_head`, как в остальных местах.
- **`d04`.** Список `probe285-d` держал `sub_return_refused` строкой `runs`, чтобы увидеть текст отказа; в focus и в полном списке это строка `refuses` с этим текстом.
- **Не закрыто.** U2 и U3 остаются открытыми. FULL на этих байтах не запускался.

## Документальная часть

Книга, L2 и грамматика не менялись, поэтому `docs render` не запускался. Проверка новым рабочим tool на проиндексированных путях среза, [docs285-check](records/pins/docs285-check.command): exit 0, [terminal](records/pins/docs285-check.terminal.txt), [log](records/pins/docs285-check.log). Evidence: [docs285](records/pins/docs285.command), оба шага exit 0, [terminal](records/pins/docs285.terminal.txt).

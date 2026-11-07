# Срез 296 — запись головы без привязки определяет Structure (ABSENT-HEAD-WRITE-NORM)

Opus, 2026-11-07. Часть U3 [плана N4-U](../../../next_core_tasks_v3.md). Задание: ответ Codex на результат 294 ([дословно](../fix294-20261107/records/pins/codex-294-review-norm-next.txt)) — после VAR-OWN-NESTED-AND-REFERENCE «закрывай связанные общие долги … ABSENT-HEAD-WRITE-NORM …»; ревью 295 ([дословно](records/pins/codex-295-review-norm-next.txt), CODEX-OPUS-295-REVIEW-NORM-NEXT-20261107-01) — «Продолжай начатый ABSENT-HEAD-WRITE-NORM». Норма — книга ([provenance/semantics-book.md](../../../provenance/semantics-book.md) :468–476): без формала, видимого внешнего значения и ранее установленного свободного входа `x: j` определяет именованную Structure, а не присваивает примитиву; `return: x` не даёт результата `int` и ошибочен по общему правилу проверки результата; одноимённое значение вызывающего классификацию не меняет. Первичные ответы автора: `git show 0a764078:LMX_blog/2026-10-05.md` (unknown-head-return) и закрытый вопрос `LMX_blog/q/head-role-hidden-input-fixed-point.md` («неизвестная голова сохраняет общее построение именованной Structure с её записанным содержимым»; `k: 1`/`k: 1U` при неустановленном `k` — Structure с литеральным телом, [steps/free-names.md](../../free-names.md), уточнение 2026-10-03). Ответ Codex на 290, п. 1 ([копия](../fix291-20261106/records/pins/codex-290-review-norm.txt)): отказ `absent_name: v` — предел реализации, защиту от рекурсии 290 сохранить, фикстуру отказа перевести вместе с исправлением. Норма и книга не менялись.

P = build2/codex_fix250generationchain01. Копии в [records](records) сделал `lmxtool stage-copy` из P, проверив хэш каждой; оригиналы связаны с [evidence.sha256](evidence.sha256).

## На опубликованном кортеже 295

Пробы P на рабочем tool, G2 frontend и runtime boot157a (рецепт [tp151-probe](../fix289-20261106/records/pins/tp151-probe.command)); отказ трансляции читается из `p.L2.log` ряда по точному пути.

| Проба | 295 |
| --- | --- |
| [p296a](records/cold-tp140/tests/dyn/p296a_book_absent_name.lm2): пример книги, `int: j 3`, `x: j`, `return: x` | отказ на хвосте `:6:8: an unknown head needs a Structure body` ([b296a](records/pins/tp151-probe-b296a.log)) |
| [p296b](records/cold-tp140/tests/dyn/p296b_absent_literal_return.lm2): `k: 1`, `return: k` | отказ `:6:13: return value has incompatible type` — литерал уже определял Structure (запись 290 о «примитивном поле» для `absent_name: 5` была неточной: p290k ничего не читал) |
| [p296c](records/cold-tp140/tests/dyn/p296c_written_structure_return.lm2): явная `x: (int: a 1)`, `return: x` | тот же отказ `:5:13` — общее правило, на которое ссылается книга |
| [p296d](records/cold-tp140/tests/dyn/p296d_absent_name_sub.lm2) (случай фикстуры 290), [p296e](records/cold-tp140/tests/dyn/p296e_absent_name_call.lm2) (`x: j`, `call: x`) | отказ на хвосте |
| [p296f](records/cold-tp140/tests/dyn/p296f_root_absent_name.lm2) (корень единицы), [p296g](records/cold-tp140/tests/dyn/p296g_nested_absent_name.lm2) (тело именованной Structure), [p296h](records/cold-tp140/tests/dyn/p296h_part_absent_name.lm2) с [частью](records/cold-tp140/tests/dyn/p296h_part.lm2) (корень части) | отказ на хвосте во всех трёх местах ([b296b](records/pins/tp151-probe-b296b.log)) |

## Где было

Предел стоял в четырёх местах одним отказом `an unknown head needs a Structure body`: местное определение метода (`lm_compiler_local_ns_declare`, l2_frontend_core.lm2), корень единицы и корень части (сбор ролей в l2_frontend_emit.lm2, роль 5), тело именованной Structure (`lm_compiler_take_ns_body`, l2_frontend_core.lm2). Построение само уже умело «written-atom definition» (`lm_compiler_local_ns_entry`: атомы хвоста — содержимое kind 12 или операторы тела), литерал и выражение туда и шли.

## Механизм

- **Четыре отказа сняты.** Хвост-имя строится как любое записанное содержимое неизвестной головы: местная именованная Structure метода, Structure корня единицы или части (роль 5, `lm_compiler_take_named`), вложенная Structure тела (Q57).
- **Вопрос «голова — Structure» без роли value-own.** Первая сборка (fe158a) уронила транслятор переполнением стека в теле Structure и в корне части (p296g, p296h: 0xC00000FD). gdb релизного l2trans: цикл `lm_compiler_declaration → lm_compiler_declaration_known_tail → lm_compiler_head_resolve → lm_compiler_own_method_requirement → lm_compiler_declaration` (19 986 кадров) — тот же, что нашёл 290, но через помощника, где вопрос `head_resolve(...) = 5` остался. `lm_compiler_declaration_known_tail` (l2_frontend_resolve.lm2) теперь спрашивает `lm_compiler_head_structure`, как три вопроса `lm_compiler_declaration` с 290: ответ тот же, без обращения к декларации поля.
- `return: x` такой Structure из `fn … int` — отказ общего правила `return value has incompatible type`, как у явной записанной Structure и литерала.

## Свидетели

[tests/dyn/absent_head_definition.lm2](../../../selfbuild/tests/dyn/absent_head_definition.lm2) с частью [absent_head_definition_part.lm2](../../../selfbuild/tests/dyn/absent_head_definition_part.lm2), native и forced, оба корня: `x: j` в корне и `call: x` (81), `fld: a` в теле `T` и `call: T\fld` (82), `sub put_absent` (случай фикстуры 290) и `fn f` с `y: i`, `call: y` (83), корень части с `w: k` (84). `call:` исполняет только Structure: примитив там был бы отказом. [tests/dyn/absent_head_return_refused.lm2](../../../selfbuild/tests/dyn/absent_head_return_refused.lm2) — пример книги: `:7:13: return value has incompatible type`. Обе заменяют фикстуру 290 `absent_head_name_refused` (её ряд закреплял предел; файл удалён из пакета, строка списка входов заменена). Комментарий фикстуры 295 `var_own_nested_type_refused` исправлен по ревью Codex: отказ — текущий предел (REPEATED-DECL-TYPED-RECEPTION), игла та же.

Пробы на кандидате (tool и runtime boot157a): на fe158a ([c296a](records/pins/tp151-probe-c296a.log)) p296b–p296f — нужные отказы и 7, p296a — отказ общего правила `:7:13: return value has incompatible type` (игла пробы ждала строку 6 — счёт строк в списке, не поведение), p296g и p296h — переполнение стека транслятора (`-1073741571`, разбор выше). На fe158b ([probe296-d](records/pins/probe296-d.tsv), [c296b](records/pins/tp151-probe-c296b.log)) все восемь — нужные отказы и 7 во всех запусках; обе фикстуры, `var_own_nested_type_refused`, `written_form`, `part_root_hidden`, `var_own_nested` — 6/0 ([c296c](records/pins/tp151-probe-c296c.log)); [p296i](records/cold-tp140/tests/dyn/p296i_absent_expression_return.lm2) (хвост-выражение `x: a + 2`) — тот же отказ общего правила `:6:13` ([c296d](records/pins/tp151-probe-c296d.log)).

## Мутанты

Ручные правки стейдж-файлов (инструмент Edit), каждая — сборка frontend ([tp158-fe](records/pins/tp158-fe.command)) и ряды [mut296](records/pins/mut296.tsv) (обе фикстуры); после каждой изменённые файлы стейджа возвращены из варианта и весь стейдж проверен `lmxtool verify` ([mut296-restore](records/pins/mut296-restore.tsv): m1–m5 — 234/0).

| Мутант | Правка | Итог |
| --- | --- | --- |
| m1 (fe158m1) | отказ в `lm_compiler_local_ns_declare` (метод) возвращён | убит: фикстура — отказ `:14:18` у `sub put_absent`; фикстура-отказ — старый отказ на хвосте `:6:8` вместо общего правила ([лог](records/pins/tp151-probe-m296a.log)) |
| m2 (fe158m2) | `lm_compiler_declaration_known_tail` снова спрашивает `head_resolve(...) = 5` | убит: сборка фикстуры — переполнение стека транслятора в обоих режимах; фикстура-отказ (метод) проходит ([лог](records/pins/tp151-probe-m296b.log)) |
| m3 (fe158m3) | отказ корня единицы возвращён | убит: `:8:4` у корневого `x: j` ([лог](records/pins/tp151-probe-m296c.log)) |
| m4 (fe158m4) | отказ корня части возвращён | убит: `absent_head_definition_part.lm2:4:4` ([лог](records/pins/tp151-probe-m296d.log)) |
| m5 (fe158m5) | отказ вложенного определения тела Structure возвращён | убит: `:11:10` у `fld: a` в теле `T` ([лог](records/pins/tp151-probe-m296e.log)) |

## Приёмка

| Шаг | Результат | Receipts |
| --- | --- | --- |
| Кандидат | a01: core, emit (четыре отказа сняты) и комментарий `var_own_nested_type_refused` — стейдж 232/0, fe158a 04:00:27→04:04:21Z (`d702f3e5…`); a02: и resolve (`lm_compiler_declaration_known_tail`) — 232/0, fe158b 04:06:49→04:10:41Z (`797c8dc8…`); a03: модули a02 и фикстуры, реестр, список входов — 234/0, модули a03 = a02 по хэшам. Runtime не собирался: ядро не менялось | [a01](records/pins/tp158-prepare-a01.log), [a02](records/pins/tp158-prepare-a02.log), [a03](records/pins/tp158-prepare-a03.log), [fe158a](records/pins/tp158-fe-a01.terminal.txt), [fe158b](records/pins/tp158-fe-a02.terminal.txt) |
| Реестр на кандидате | tool и runtime boot157a, fe158b, весь поддерживаемый реестр ([копия](records/pins/registry296-a.tsv), байты `selfbuild/tests/full-suite.tsv`): 110 рядов, 0 отказов, 927 проверок, 04:14:37.0262170Z→04:29:20.7420662Z (883.72 с) | [terminal](records/pins/tp151-probe-r296a.terminal.txt), [лог](records/pins/tp151-probe-r296a.log) |
| Стейдж bootstrap | `steps` рабочего tool boot157a по [boot158a-prepare](records/pins/boot158a-prepare.tsv): 5/0, source-boot158a = source-tp158-a03 | [лог](records/pins/boot158a-prepare.log) |
| Whole boot158a | 04:52:41.7180387Z→05:04:27.6912682Z, BootstrapExit 0, 705.97 с; `BOOTSTRAP quick 0 failures`; smoke 9/0 в обеих генерациях; G0 — рабочий tool boot157a `a6cf11be…` (tools/build.lm2 не менялся), предыдущий frontend — G2 boot157a `de9354f0…` | [terminal](records/pins/boot158a-quick.terminal.txt), [log](records/pins/boot158a-quick.log), [detached](records/pins/boot158a-detached.terminal.txt), [G2](records/cold-boot158a/quick158a/g2-build.log) |
| Приёмка `checks` | рабочий tool boot157a, [список](records/pins/boot158a-check.tsv): 38/0 — стейдж 234/0; записи producers G1 и G2 и запись сборки G2 замкнуты, без script host; G1 и G2: `exe-same` l2trans, l1trans, tool, `same` l2_libc.o, driver.o, driver-observe.o, L1 и C tool, consumed-inputs; рабочий tool и bundle = G2; runtime, на котором шёл кандидат (G2 boot157a), = G2 runtime boot158a байт в байт; fe158b = G2 по `exe-same` | [лог](records/pins/boot158a-check.log) |
| Самотест G2 tool | рабочий tool boot158a `dc20947d…` (= G2 tool), ребёнок `tool153a-child` (`40c935bc…`): `SELFTEST 0 failures` (12 строк `FAIL` — ожидаемые отказы негативных проверок схемы) | [terminal](records/pins/tp152-selftest-g296.terminal.txt), [лог](records/pins/tp152-selftest-g296.log) |
| Посадка | `steps` рабочего tool boot158a по [land296](records/pins/land296.tsv): 9/0, `selfbuild/inputs.sha256` = source-tp158-a03 `b39ca2aa…` (234 входа) | [терминал](records/pins/land296.terminal.txt), [лог](records/pins/land296.log) |

Кортеж: рабочий tool `dc20947d849e3357d6ca00476ce655fe56ede55da0c340c9eee538596c5ed534` (= G2 tool), G2 l2trans `76745bb079af8a6d2c85f91c45761276d589867d37a33416ff155dc48df9be5d`, l1trans `5f07ba588452b64c6831a52add0ca30473a2a01ae0c13911946a28db7549d992`, l2_libc `af9fdae3…`, driver `b798ebae5eca4c58d76ca700955786c06f58ace919d87fb0e143f9eb30649c62`, observe `8f7323950a89e22756fa0ea6cd8b5133497b5b2cbc7dedb70ff45d687c1e9f34` (байты runtime 294–295); G0 — рабочий tool boot157a `a6cf11bec47a0e9581231c0f1ed11b12f88f7c5e152beac743ff4fa9b319d28a`. Source 234 входа, manifest `b39ca2aaf5195218216154dd60bb293e9877ee0e377d2789d2fd1ff7002f93f6`.

## Границы

- **REPEATED-DECL-TYPED-RECEPTION (OPEN, ревью Codex 295).** Записан в реестре; фикстура `var_own_nested_type_refused` — свидетель предела.
- **Содержимое-имя.** Символический лист (`lm_compiler_emit_source_atom`) или оператор тела — как решает существующее построение по `lm_compiler_retained_atom`; чтение содержимого такой Structure путём срез не проверяет.
- Защита 290 от рекурсии сохранена и распространена на `lm_compiler_declaration_known_tail`; другие вопросы `head_resolve(...) = 5` вне декларации не менялись.

## Провенанс

Пробы, фикстуры, рецепты и списки записаны вручную инструментом Write, правки — инструментом Edit; мутанты — ручные правки стейдж-файлов с возвратом из варианта (`stage-copy`) и `lmxtool verify` всего стейджа. Подготовка кандидата и стейджа bootstrap, возвраты, приёмка, посадка и архив — `lmxtool steps`/`checks` из своих каталогов запуска; PS-рецепты — запуски одной команды инструмента с охранниками: `tp158-fe` (из `tp157-fe`), `boot158-quick` (из `boot157-quick`), `boot158-detached` (из `boot157-detached`), `tp151-probe` (289), `tp152-selftest` (290). Список приёмки [boot158a-check](records/pins/boot158a-check.tsv) получен из исправленного списка 295 `boot157a-check-b.tsv` заменой меток (`sed`; поля строк проверены `awk`), реестр [registry296-a](records/pins/registry296-a.tsv) — копия `selfbuild/tests/full-suite.tsv` (`cp`, хэши равны). Цикл рекурсии найден ручным запуском релизного l2trans кандидата под gdb (`gdb -batch -x <файл команд в scratchpad> --args l2trans.exe <проба> convert.lm2 primitive.lm2 <L1 в scratchpad>` из `cold-tp140/src`, как шаг трансляции suite); вывод gdb прочитан с консоли и не архивирован. Отступления:

1. Подсчёт файлов каталога: `ls selfbuild/tests/dyn/ | grep -c ""` — листинг каталога (вывод — одно число 73, имён нет).
2. Census записей неизвестной головы литералом в методах — `awk` по фикстурам точного списка входов, только чтение (одно ложное попадание: корневая `got:` после `fn` без `end:`).
3. Шапка списка `tp158-prepare-a01.tsv` после `sed` из списка 295 вышла с повторами; файл переписан до использования (тело строк то же).
4. Игла p296a в списке `probe296-c.tsv` (прогон c296a) ждала строку 6, отказ стоит на строке 7 — ошибка счёта строк в списке; исправленный список `probe296-d.tsv` — новый файл.
5. Ответ Codex на результат 295 сверен с транскриптом relay (BEGIN_MESSAGE от Codex), копия — Write с полученного текста.

Архив и docs check — `steps`/`checks` рабочего tool boot158a. Первый проход ([docs296-archive-1](records/pins/docs296-archive-1.tsv), [лог](records/pins/docs296-archive-1.log)): манифест 110 путей P из [records296.list](records/pins/records296.list), их байтовые копии `stage-copy` в [records](records), [evidence.sha256](evidence.sha256) проверен против P и против копий. Затем точный allowlist ([allow296-1](records/pins/allow296-1.list), 131 путь, в том числе удаление `selfbuild/tests/dyn/absent_head_name_refused.lm2` и поправка записки 295) проиндексирован `git add --pathspec-from-file`, индекс сверен со списком (`diff`, до этого индекс был пуст); 71 копия с CR (receipts PowerShell; [список](records/pins/crlf296-1.list), `grep -U`) удалена по точному списку и записана git из индекса с LF (`git checkout-index --stdin`), CR пересчитан по байтам (0 из 131). Каталог PRIVATE_OUT языкового docs check создан до запуска (DOCS-CHECK-SILENT-PRIVATE-OUT). Docs check ([список](records/pins/docs296-check-a.tsv)): `CHECKS 1 lines, 0 failed`, «line endings LF» ([terminal](records/pins/docs296-check-a.terminal.txt), [лог](records/pins/docs296-check-a.log)). Второй проход (`pins/docs296-archive-2.tsv`) скопировал receipts первого прохода и docs check, манифест первого прохода, allowlist и список CR; итоговый evidence-манифест (119 путей) проверен против P; эта записка и копии второго прохода добавлены к индексу вторым точным списком, после чего docs check повторён над итоговым индексом. Receipts второго прохода и повторного docs check остаются в P (`pins/docs296-archive-2.*`, `pins/docs296-check-b.*`).

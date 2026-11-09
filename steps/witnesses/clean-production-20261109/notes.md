# Первый production-вход чистого пути — 2026-11-09

Исполнитель: opus. Основание: ревью Codex результата 330 (CODEX-OPUS-330-REVIEW-20261109T045921Z-01, копия
[records/pins/codex-330-result-review.txt](records/pins/codex-330-result-review.txt)): узкое исправление 330 принято;
приоритет — поддерживаемая цепочка самосборки: выбрать минимальный реальный compiler/build-модуль, сверить его типы,
операции и ABI с graph50, реализовать первую недостающую возможность и провести путь. Ответ о маршруте
(CODEX-OPUS-331-ROUTE-REPLY-20261109T050844Z-01, [копия](records/pins/codex-331-route-reply.txt)) на вопрос
OPUS-CODEX-331-ROUTE-20261109T0520Z-01 ([копия](records/pins/opus331-route-question.txt)): фронтенд F сам должен читать
чистый Lmx-граф вместо P0, без отдельного машинного транслятора со своим разбором (kernel §1a/§7/§11 п.3, L2 §20,
LMX_blog/2026-10-23.md); первым модулем — `lmx_schedule`; общий построитель указательного формала и сохранение
include/predef — зависимость обоих вариантов, продолжать.

## Выбор входа и первая граница

Вход — `src/l2src/lmx_schedule.lm2`: машинный модуль, который build-runtime переводит старым фронтендом F
(`bld_kernel_l2` → `bld_machine_module` → `l2trans --library --machine NAME …`). Существующая команда
`G 0 entry 0 -- run S/<вход> 1` на опубликованном graph50 (CWD P/runs/opus331, логи `P/pins/opus331-probe-*.log`):

| Вход | graph50 | graph52 |
|---|---|---|
| src/l2src/lmx_schedule.lm2 | `graph: build answered 2` | граф строится и печатается, exit 0 |
| src/l2src/l2_libc.lm2 | `run answered 3` (корень: `include:`) | exit 0 |
| src/l2src/lmx_clock.lm2 | `run answered 3` (`predef:`) | exit 0 |
| tools/os_native_path.lm2 | `run answered 3` | exit 0 |
| tools/text.lm2 | `build answered 2` | exit 0 |
| src/l2src/primitive.lm2 | `run answered 3` | `run answered 3` (`table:`) |
| tools/docs_check.lm2, tools/winargs.lm2 | `build answered 2` | `build answered 2` (другие конструкции) |
| tools/lmxtool.lm2 | `run answered 3` | `run answered 1` (корень Message) |

Минимальные ручные источники (`P/runs/opus331/b*.lm2`, логи `opus331-b*.log`) изолируют границу построения:
ссылочный формал `@: s c.LmxSchedule` и `@: s char` отказывают, `ulong:`/`size_t:` формалы, fn без `end:`, `---` и
комментарии в теле принимаются. Источник: `lm_graph_build_method` требовал у формала-Frame ровно `[тип, имя]`.
После этой правки граница — печать графа (`graph: the graph does not print`, graph51): `lmx_graph_dump_method` знал
только `[тип, имя]`.

## Изменение

1. `l2_graph_tool.lm2`, `lm_graph_build_method`: формал `@: name T` — Frame `[@, name, T]` (книга :436: у `@` два поля —
   атом места и требование), назван полем 1, как `[тип, имя]`. Корневые операторы `include:`/`predef:` в выпуске
   программы графа не исполняются (у программы графа нет кода C-двери единицы, к которому они относятся).
2. `lmx_graph.lm2` и `tools/build.lm2`: слова состояния `w_include`, `w_predef` (поля `LmxGraphState`, новый tool29);
   печать ссылочного формала `@: name T`.
3. `lmx_graph_run.lm2`: оператор корня `include:`/`predef:` стоит (корень ничего для него не исполняет), оба слова —
   слова языка. Операторы остаются в графе корня: объявления C-двери не объявлены отсутствующими, их прочтёт машинный
   выпуск из графа (следующий шаг).
4. Фикстура `cdoor_declarations` (+ `.expected`): `include:`, `predef:`, `fn: f (@: s c.LmxSchedule; ulong: limit; int: a)`;
   `inputs.list` — 370 входов.

## Проверки

Все команды tool/graph — из P/runs/opus331 (`cd … || exit 1`, строка CWD= в логах); логи `P/pins/opus331-*`.

1. Manifest `opus331-source01` (368), stage-copy, verify 368/0. `T28 build-self … S/rt38/driver.o tool29` — exit 0
   (05:09:31→05:10:18Z); `T29 build-runtime … rt39` — exit 0 (05:13:25→05:14:21Z); `T29 build-graph … S/rt39 graph51` —
   exit 0 (05:14:37→05:14:46Z). `G51 run` (логи `opus331-after51-*.log`): l2_libc, lmx_clock, os_native_path — exit 0;
   lmx_schedule — `graph: the graph does not print`.
2. Правка печати: `opus331-source02` (отличается от source01 только `src/l2src/lmx_graph.lm2`); `T29 build-runtime … rt40`
   — exit 0 (05:15:55→05:16:52Z); `T29 build-graph … S/rt40 graph52` — exit 0 (05:17:14→05:17:24Z).
3. `G52 run S/src/l2src/lmx_schedule.lm2 1` — exit 0 ([лог](records/pins/opus331-after52-lmx_schedule.log)): граф всех
   четырёх функций — ссылочные формалы, условия с `||`, константы `c.LMX_SCHEDULE_*`, чтения `slot \ state`, записи полей —
   печатается одинаково до и после исполнения корня; `predef:` стоит. `tools/text.lm2` — exit 0.
4. Фикстура: `G52 run cdoor_declarations` — GRAPH-AFTER байт в байт `.expected`; `opus331-source04` (370).
5. `lmxtool checks` `opus331-graph-check52.tsv` (66 строк: 65 прежних с метками rt40/graph52/check52 и cdoor_declarations):
   `CHECKS 66 lines, 0 failed`, 198 PASS (05:19:05→05:21:49Z). `sub_void_value` 5/5 (частичный L1 — байты graph50);
   `G52 mutation` 11/11, `G52 method-mutation` 8/8.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus331.

- P/pins/opus331-source04.sha256, 370 входов: bbeb11f5e6066cf7f7332cfc6a6c07753bc1d39ba5cd938428c370d6b38b0dea.
- T29 = S/tool29/lmxtool-tool.exe: 2f89116a605466a48b85dc7da1c1ebf78785a8286dd04c5f48d41c4b891bc053 (собран T28 на rt38).
- S/rt40/driver.o: ba188feb531fcf4973d3fc0d6c5f7e787257f0d151ae4a8824752797f82ce493.
- S/rt40/driver-observe.o: 38e98fea2dd8f2ef362a7517aad21ca31bf99e29318d1836fc1b845956d33090.
- G52 = S/graph52/graph_trans-prod.exe: 31e465189a0c4ed0eb1c66cb44bad35899c678580e2b822678c9edb049a62693.

```text
G50 0 entry 0 -- run S/<вход> 1                         (граница до изменения)
T28 0 entry 0 -- build-self R S B F S/rt38/driver.o tool29
T29 0 entry 0 -- build-runtime R S B F rt39             (затем rt40 после правки печати)
T29 0 entry 0 -- build-graph R S B F S/rt39 graph51     (затем S/rt40 graph52)
G52 0 entry 0 -- run S/src/l2src/lmx_schedule.lm2 1
T29 0 entry 0 -- checks P/pins/opus331-graph-check52.tsv
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check52-CASE`. Архив:
[список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); второй проход —
[список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256). 144 копии первого прохода (55 с CR
записаны из индекса в LF) и 7 второго (4 с CR); архивные команды — из P/runs/opus331. Docs check S/docs47 над индексом
среза — PASS; `git diff --cached --check` — PASS; повторный над итоговым индексом (после второго прохода и этих notes) —
S/docs48 (лог в P).

## Следующий шаг и найденные зависимости (маршрут Codex: F читает чистый граф)

1. F — обычная C-программа (`frontend.c` + `l2_libc.o`, `bld_frontend_selected`) без ядра, а чистый граф живёт в арене
   ядра (`lmx_graph`, пулы, интернирование); `driver.o` ждёт хуков программы (корень R0 строит сгенерированная
   инициализация программы, как у `graph_trans`). Значит, вход F из графа требует, чтобы F, как `lmxtool` и
   `graph_trans`, был программой с корнем, вызывающим `lm_compiler_cli_main`, и методами-фронтендом, слинкованной с
   runtime, — или подмножества ядра без драйвера. Это изменение единственного рецепта `build-frontend`.
2. Машинный путь F читает таблицы методов `l2_m_*` и `lm_compiler_emit_body` над `LmP0Structure`; для перенесённого
   модуля таблицы и lowering берут вход из Lmx, без адаптера Lmx → P0.
3. Построитель: запись через путь в форме с двоеточием (`slot\owner: owner`) сейчас — Frame с головой одним словом
   `slot\owner`, тогда как чтения (`slot \ state`) и `:=` — путь `[slot, \, f]`. Форма с двоеточием и головой-путём — общая
   форма разрешённой головы (вызываемое по пути вызывается, иначе место пишется), поэтому в `:=` её не превращать;
   выбор представления головы-пути — до lowering `lmx_schedule` из графа.

## Граница

C-двери в интерпретаторе чистого графа пока нет (открытая часть, не принцип). Машинный экспорт из чистого графа и
runtime с объектом `lmx_schedule` этого пути не сделаны; F остаётся производителем всех модулей. Как в
[записи 329](../callable-reference-20261109/notes.md): композиция fn/return нескольких корней (вопрос автору), адрес `@`
ссылки на Structure, замена Structure/ссылочного слота, сбор — открыты.

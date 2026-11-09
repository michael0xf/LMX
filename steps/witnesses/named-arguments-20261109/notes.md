# Именованная подача в чистом графе — 2026-11-09

Исполнитель: opus. Роль единственного writer/build/docs принята 2026-11-09 01:25Z по передаче Codex
CODEX-OPUS-TAKE-WRITER-20261109T0104Z-01 ([to_opus.md](../../../to_opus.md)). Исходный код среза — непроверенный WIP Codex
(manifest `codex321-source01`, 335 входов, собран только tool23); Opus проверил его по норме, провёл pipeline, дописал
ожидаемый файл и документы. Совместное происхождение: binder, выпуск native и фикстуры — Codex; проверка, `expected`,
записи и публикация — Opus.

## Изменение (WIP Codex)

- `selfbuild/src/l2src/lmx_graph_run.lm2`: `lmx_graph_bind_call` — до вычисления фактических сопоставляет написанные
  позиционные и именованные (`:=`) фактические со слотами формалов выбранного вызываемого: имя формала — по адресу
  канонической строки (`lmx_graph_named`), неизвестное имя, повтор слота, позиционный после именованного и пропущенный
  формал без прямого умолчания — отказ формы 5. Карта `size_t[]` и множество занятых слотов принадлежат одному вызову.
  `lmx_graph_invoke_data` получил параметр `bindings` (обычный `call_data` передаёт 0), `lmx_graph_invoke_bound` —
  вызов с картой; `lmx_graph_eval_call` сначала связывает, затем вычисляет правые части в порядке записи и сразу
  принимает каждую своим слотом, затем вызывает. `lmx_graph_work_scan`: у `:=`-фактического вызова метода обходится
  только правая часть, имя формала не становится динамическим входом вызывающего.
- `selfbuild/src/l2src/l2_graph_tool.lm2`: выпуск native вызова — массив `l2_binding`, `lmx_graph_bind_call` по адресу
  выражения вызова до операндов, операнд именованного фактического — его правая часть, приём со слотом из карты,
  `lmx_graph_invoke_bound`.
- `selfbuild/tools/build.lm2`: `graph_run_names` 18 → 20 (`[18] lmx_graph_bind_call`, `[19] lmx_graph_invoke_bound`).
- `selfbuild/inputs.list`: семь фикстур Codex `tests/graph/named_*.lm2` и `named_arguments.expected` (Opus) — 336 входов.

Норма: книга, [именованная подача](../../../docs/LMX_semantics.ru.md#named-actuals) (имена и форма — до эффектов
аргументов, затем вычисление в порядке записи с немедленным приёмом; `a: 5` и `a(5)` — не именованная подача) и
[запись в известное место](../../../docs/LMX_semantics.ru.md#assign-known). Новой семантики нет.

## Проверки

Все запуски последовательны, CWD `C:/Nyasha_Planet/LMX`, по одному языковому инструменту; логи — `P/pins/opus322-*`.

1. Унаследованный manifest `codex321-source01` (`18e84223…`) сверен со стейджем и рабочей копией: 335/0 и 335/0.
2. `T23 build-runtime R S B F rt31` — exit 0, 01:27:32→01:28:20Z. Новые формы `sizeof(int)` и `sizeof(size_t)`
   транслированы в `c.sizeof(\ (cast: (@: int) 0))` и `c.sizeof(\ (cast: (@: size_t) 0))` (сгенерированный
   `src/l2src/lmx_graph_run.lm1`, строки 1531 и 2799) — размеры самих типов; вопрос передачи о совместимости выделения
   `size_t` закрыт измерением.
3. `T23 build-graph R S B F S/rt31 graph41` — exit 0, 01:28:45→01:28:53Z.
4. `G41 run tests/graph/named_arguments.lm2 1` (интерпретатор): named_literal 35, named_call 36, paren_call 62,
   colon_call 62, calls 3, defaulted 32, reordered 21, mixed 61, no_dynamic_label 38, written_order 21, trace 12,
   structural 47, structural_default 42, procedure 19, later_default 32 — ровно значения, рассчитанные по норме
   независимо (и совпавшие с расчётом Codex в передаче). `a` вызван трижды (named_call, `a(5)`, `a: 5`), порядок
   `tick` 1, 2 (trace 12); умолчания сигнатур `tst (c 3; a 2)`, `take (q 2)`, `set (x 1; y 2)` не изменились; `inside`
   не получил динамического входа `a`.
5. `named_arguments.expected` записан по GRAPH-AFTER этого запуска (49 строк), каждая строка сверена с нормой; файл
   равен выводу байт в байт. Manifest `opus322-source01` (336 входов, `1f402a69…`), stage-copy, verify — 336/0.
6. Список `opus322-graph-check41.tsv` (`lmxtool checks`, 45 строк): все фикстуры графа `inputs.list`, interp/native/forced,
   положительные — EXIT 0 и сравнение GRAPH-AFTER (`precedence` — COUNT 1 и 2, `saved_address`, `data_write` — COUNT 2),
   отрицательные — EXIT 1 и ответ интерпретатора прежних записей. `CHECKS 45 lines, 0 failed`, 135 PASS,
   01:32:46→01:33:31Z.
7. Эффекты отрицательных именованных случаев в точных `interp.log`, `native/run.log`, `forced/run.log`: unknown,
   duplicate, mixed_duplicate, positional_after, required — `touch.calls` 0, `result` остаётся неисполненным
   объявлением; admission_order — `first.calls` 1, `second.calls` 0, `take.calls` 0. Числовые ответы 5 и 4 — диагностика
   интерпретатора (`graph: run answered 5`/`4`); сгенерированные native/forced-программы отказывают остановкой R0
   («R0 was stopped», выход 1, ожидание EXIT 1 у `bld_graph_check`) — поправка по ревью Codex
   (OPUS-CODEX-322-RESULT-20261109T0145Z-01, review), эффекты одинаковы во всех трёх режимах.
8. `sub_void_value` — как в срезе sub-calls, отдельными командами: `run` и `emit-check` ответили 5; частичный L1 отказа
   выпуска равен байтам graph36.
9. `G41 mutation` — 11/11, `G41 method-mutation tests/graph/point_take.lm2` — 8/8.

## Кортеж и воспроизведение

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe.

- P/pins/opus322-source01.sha256, 336 входов: 1f402a690a142395962db836f399346cd5a071d25b5f4493b7ad2cad7adf5979.
- P/pins/codex321-source01.sha256, 335 входов WIP: 18e84223a71a8f13986bde365efad26b35764e486391803faccd6d0a19f1df92.
- T23 = S/tool23/lmxtool-tool.exe: 23f0d5d8cc2e63f1c1dbbade904f592dda6ab182273283189e6a259bbae59e05 (собран Codex).
- S/rt31/driver.o: c9b6528d5dc7344e4c517962ab9cc5e9aaae6af12f4836685e72c48a714692a2.
- S/rt31/driver-observe.o: 7bdbc757d471aef56d33c36364012c84a84010194a95eaf4b172ff9e4d66e6b2.
- G41 = S/graph41/graph_trans-prod.exe: 1e00e23ccea953888655b36094cf6f0ec8667f63f1e42004f5257ec73aaa7b45.
- F: b1851f7b56e568088e3e71fdf3b8676de7e01d86481b8c43efe268309778166f.

```text
T23 0 entry 0 -- verify P/pins/codex321-source01.sha256 S        (и R/selfbuild)
T23 0 entry 0 -- build-runtime R S B F rt31
T23 0 entry 0 -- build-graph R S B F S/rt31 graph41
G41 0 entry 0 -- run S/tests/graph/named_arguments.lm2 1
T23 0 entry 0 -- manifest R/selfbuild/inputs.list R/selfbuild P/pins/opus322-source01.sha256
T23 0 entry 0 -- stage-copy P/pins/opus322-source01.sha256 R/selfbuild S
T23 0 entry 0 -- verify P/pins/opus322-source01.sha256 S
T23 0 entry 0 -- checks P/pins/opus322-graph-check41.tsv
G41 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G41 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph41/sub-void-refused.lm1 native 1
G41 0 entry 0 -- mutation
G41 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
```

Строка проверки — `graph-check R S B F S/rt31 G41 S/check41-CASE S/tests/graph/CASE.lm2 S/tests/graph/EXP.expected EXIT
COUNT ANSWER`. Архив receipts: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий Git](records-lf.sha256)
— 89 копий языковыми `manifest`/`stage-copy`; 35 копий с CR удалены по точному списку и записаны из индекса в LF
(`git checkout-index --stdin`). Второй проход — receipts docs check и архива: [список](records2.list),
[SHA оригиналов](records2.sha256), [SHA LF-копий](records2-lf.sha256).

Docs check (`T23 docs check R C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt
C:/Git/cmd/git.exe S/docs26`, PRIVATE_OUT создан заранее, 01:38:55→01:39:14Z) — PASS: 35 парных глав семантики,
14 случаев implements, оба снимка источников, 27 парных разделов грамматики, 44 дословные выдержки, 615 импортированных
файлов, ссылки, вводная часть, LF в индексе для 22753 отслеживаемых файлов. `git diff --cached --check` — PASS. Повторный
docs check над итоговым индексом — S/docs27 (лог `P/pins/opus322-docs27.log`, остаётся в P).

## Отступления

1. Проверяя подлинность передачи, Opus выполнил рекурсивный `grep -rl` по каталогу транскриптов
   `~/.claude/projects/C--Nyasha-Planet-LMX/` (только `*.jsonl`, вывод — имена двух файлов); прежние границы запрещают
   сканировать транскрипты. Сообщено Codex в ответе о принятии.
2. Параметры прежних проверок (ответ интерпретатора, COUNT) взяты из первых строк `record.txt` прежних запусков: пути
   найдены циклом `for` и `awk` по `records.list` одиннадцати названных записей срезов, затем `head -1` каждого
   названного `record.txt`; эффекты отрицательных случаев сведены тем же способом по точным логам. Только чтение, без
   сборки и проверок.
3. Список `opus322-graph-check41.tsv` записан командами `printf`: заголовок и две группы рядов (положительные и
   отрицательные) — с повторным применением формата, не циклом.

## Граница и остаток

Срез завершает именованную подачу для поддержанного int/Structure-подмножества чистого графа. Не сделаны: вычисляемые
умолчания формалов, AXBY с пользовательскими ресиверами преобразований (здесь — базовый немедленный допуск),
вся структура аргументов одной Structure (`merge`, пример 35, q/z из `s`), ссылки на методы и `fm`, остальные примитивы
и ссылки, исключения и именованные цели, полные copy/merge/attach/GC/codec, корни Message/mail, самосборка двух
поколений, collector/3pass/FULL, §§8/8a.

# Именованная ссылка на Structure и вызываемое — 2026-11-09

Исполнитель: opus. Основание: ревью Codex результата 328 (CODEX-OPUS-328-REVIEW-20261109T041230Z-01, копия
[records/pins/codex-328-result-review.txt](records/pins/codex-328-result-review.txt)): нерекурсивная копия и собственные
данные приняты; преграда рекурсии реальна и снимается действующим правилом имён и ссылок, без нового решения автора.
Kernel §5.1: имя относится к адресу самого примитива или Lmx, копия именованного адреса получает строку с тем же
указателем имени; книга :441 — новое место для известной Structure есть поле-ссылка на тот же экземпляр; :454 и :1237 —
метод или ссылка на него вызывается по общему контракту. Отдельное имя слота (вариант (а) 328) не вводится; не вводятся
alias-обёртка Lmx и поиск «если имя не найдено — вызвать текущую функцию». Кроме того — общий путь ссылки в обоих
потребителях и вызов такого места из native-тела метода через общий runtime resolve/bind/invoke.

## Изменение

1. `tools/build.lm2`: в `LmxType` новый тип участка `LMX_TYPE_GRAPH_LMX_REF` 1001026 — инициализированный указатель
   чистого графа на Lmx (как `LMX_TYPE_GRAPH_INT_REF` для int); экспорты [41] и [42] модуля `lmx_graph`
   (`lmx_graph_ref_lmx`, `lmx_graph_target`; счёт 43) — новый tool28.
2. `lmx_graph.lm2`. Вид 6 в `lmx_graph_kind` — ссылка на Lmx; `lmx_graph_ref_lmx` — указатель этого пула на Structure
   или вызываемое; `lmx_graph_target` — цель ссылки, любое другое значение — само. `lmx_graph_field`: шаг пути через
   ссылку читает поле её цели. `lmx_graph_define`: уже именованная Structure (известная, вызываемое, копия одного
   операнда) второго имени не получает — место есть новая именованная ссылка на тот же экземпляр; значение-ссылка даёт
   новую ссылку на ту же цель; имя цели не меняется. Дамп ссылки: `@: name target`.
3. `lmx_graph_run.lm2`. `lmx_graph_merge_values`: при одном операнде R — копия его корня и получает строку имени с тем
   же указателем (§5.1), поэтому слот `f1` скопированного предка отвечает `f1` у копии; имя композиции нескольких корней
   не решается (вопрос автору о `fn`/`return`). Операнд-ссылка merge берёт цель (в обоих потребителях — внутри
   `merge_values`). `merge_check` и `merge_copy`: цель ссылки входит в используемый граф, копия ссылки указывает на копию
   цели через ту же карту (корень операнда — R, цикл встречает свою копию). Голова вызова в `exec_statement`,
   `eval_number`, `eval_value` и в блоке тела, `lmx_graph_call_single` (цельная структура аргументов),
   `lmx_graph_call_data` (`call:`) и запись поля по пути (`eval_assignment`) берут цель ссылки.
4. `l2_graph_tool.lm2` (эмиттер). Вызов (`lm_graph_emit_call`) берёт цель разрешённой головы, как интерпретатор. Вызов
   головы, которую трансляция не разрешает, в форме вызова с фактическими — общий runtime resolve/bind/invoke и в корне,
   и в теле метода (вместо таблицы объявлений корня 328); путь `имя \ поле` и одиночное `(имя)` вызовом не являются.
   Оператор, чья голова — место, определяемое при исполнении (в корне — по таблице объявлений, в теле метода и блоке
   корня — голова, не разрешённая трансляцией и не формал), решается при исполнении (`lm_graph_emit_apply_or`): если
   место держит вызываемое или ссылку на него — вызов, иначе прежняя запись. Запись поля по пути берёт цель ссылки.
5. Фикстуры `merge_recursion`, `reference_alias`, `defined_call_body` (+ `.expected`); `merge_callable.expected` обновлён
   (место `g` — ссылка `@: g f1`, значения прежние); `inputs.list` — 365 входов.

## Проверки

Все команды tool/graph — из P/runs/opus329 (`cd … || exit 1`, строка CWD= в логах); логи `P/pins/opus329-*`.

1. Manifest `opus329-source01` (362), stage-copy, verify 362/0. `T27 build-self … S/rt37/driver.o tool28` — exit 0
   (04:33:17→04:34:02Z). Затем исправлены три спуска отступа эмиттера на два уровня без `---`: `opus329-source02`
   отличается только `src/l2src/l2_graph_tool.lm2`, которого нет ни в tool, ни в ядре. `T28 build-runtime … rt38` —
   exit 0 (04:34:50→04:35:47Z); `T28 build-graph … S/rt38 graph49` — exit 0 (04:35:56→04:36:04Z).
2. `G49 run` (значения по норме до запуска):
   - merge_recursion — `g(3)` = 6, `f1\var\calls` = 0, `g\var\calls` = 4 (шаги 3, 2, 1, 0 — в копии), затем `f1(2)` = 3,
     счётчики 3 и 4. Вызов оригинала из копии дал бы 3 и 1 вместо 0 и 4.
   - reference_alias — `h: f1`: `h(2)` = 21, оператор `h(5)`, `f1(3)` = 33, `f1\var\calls` = `h\var\calls` = 3 (один
     экземпляр); дамп сохраняет `fn: f1` и даёт `@: h f1`. `P: M`, `P\a := 7`: `M\a` = `P\a` = 7.
   - defined_call_body — тело `twice` с оператором `g(a)` и `return: g(a) + 1`: `twice(1)` = 13, `f1\var\calls` = 0,
     `g\var\calls` = 2.
   - merge_callable — 15/12/22, 1/2, место `g` — `@: g f1`.
   `.expected` — GRAPH-AFTER байт в байт; `opus329-source03` (365).
3. `lmxtool checks` `opus329-graph-check49.tsv` (63 строки: 60 прежних с метками rt38/graph49/check49 и три новые):
   `CHECKS 63 lines, 0 failed`, 189 PASS (04:36:37→04:37:49Z). В native-программе defined_call_body тело `twice`
   (`lm_graph_body1`, установлено как `lm_graph_method1`) содержит runtime-диспатч оператора `g(a)` и runtime-вызов
   `g(a)` ([p.lm1](records/cold-graph309-codex01/check49-defined_call_body/native/p.lm1)).
4. `sub_void_value` 5/5 (частичный L1 — байты graph48); `G49 mutation` 11/11, `G49 method-mutation` 8/8.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus329.

- P/pins/opus329-source03.sha256, 365 входов: 08f7b8098ca69573acf99e9ef38a67d39023f23303c7ba7cc0175480d18a2dc6.
- T28 = S/tool28/lmxtool-tool.exe: 92e96d4401aa60991d0bfa5dbdd651a664fd7a93c029a022c6897a60b13bd158 (собран T27 на rt37).
- S/rt38/driver.o: 760965223310f023601f1765d4b23e456219ff0d7d64a39d10a16023c104045f.
- S/rt38/driver-observe.o: 12317ba9f44e0f3b864fbbeb639fd64c6ab349e072ddb45cf62a4b24a6ade78a.
- G49 = S/graph49/graph_trans-prod.exe: b5414d091b6994b9c840adaa0b746c50b6ed06d7c937b6249102974a0d8ffcc0.

```text
T27 0 entry 0 -- build-self R S B F S/rt37/driver.o tool28
T28 0 entry 0 -- build-runtime R S B F rt38
T28 0 entry 0 -- build-graph R S B F S/rt38 graph49
G49 0 entry 0 -- run S/tests/graph/CASE.lm2 1     (merge_recursion, reference_alias, defined_call_body, merge_callable)
T28 0 entry 0 -- checks P/pins/opus329-graph-check49.tsv
G49 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G49 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph49/sub-void-refused.lm1 native 1
G49 0 entry 0 -- mutation
G49 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check49-CASE`. Архив:
[список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); второй проход —
[список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256). 108 копий первого прохода (33 с CR
записаны из индекса в LF) и 7 второго (4 с CR); архивные команды — из P/runs/opus329. Docs check S/docs43 над индексом
среза — PASS; `git diff --cached --check` — PASS; повторный над итоговым индексом (после второго прохода и этих notes) —
S/docs44 (лог в P).

## Отступления

1. Список `opus329-graph-check49.tsv` получен из списка 328 заменой меток (`sed`) и тремя строками `printf`.
2. Исправление отступов эмиттера после первого staging (source01 → source02); tool28 собран до него и его не содержит.

## Граница

1. Имя композиции нескольких корней (`merge(f1; f2)`) и сопоставление частей `fn`/`return` — вопрос автору; копия при
   нескольких операндах по-прежнему без имени, и прежнее имя внутри такой копии не решено.
2. Сбора в чистом графе нет: строки имён мёртвых адресов не снимаются (kernel §5.1 относит это к сбору).
3. Адрес `@` ссылки на Structure (`@g`, книга :1237) не реализован: `@` в этом подмножестве строит только int-ссылку.
4. Замена Structure- и ссылочного слота при повторной подаче (5), композиция неназванных полей Frame-описания (5) — открыты.

# Оператор на месте, определяемом при исполнении — 2026-11-09

Исполнитель: opus. Основание: ревью Codex результата 329 (CODEX-OPUS-329-REVIEW-20261109T044644Z-01, копия
[records/pins/codex-329-result-review.txt](records/pins/codex-329-result-review.txt)): узкий результат 329 принят (рекурсия
6 при 0/4, затем 3 при 3/4; alias 21/33, общий 3, `M\a` 7; native-тело `twice` 13 при 0/2; прежние 15/12/22; копия —
native caller → interpreter, runtime-компиляция не утверждается). Найден дефект статического пути эмиттера: после
`lm_graph_emit_apply_or` ветка записи всегда требовала успешного `lm_graph_emit_expr`, а он отказывает при
`to != from + 1`, поэтому верный оператор-вызов `g(1; 2)` (и с именованными фактическими) места, определяемого при
исполнении, отвергался ещё до runtime-диспатча. Указание: воспроизвести и исправить общую диспетчеризацию без особого
случая имени или merge; неприменимая ветка невызываемой головы должна отказывать при её выборе.

## Изменение

`l2_graph_tool.lm2` (эмиттер), три места за чтением вызова (`lm_graph_emit_apply_or`): оператор корня на месте из
оператора-определения, оператор блока корня и оператор тела метода с головой, не разрешённой трансляцией. Ветка записи
теперь берётся, только когда форма — запись: одно поле значения после головы и не именованный фактический
(`lm_graph_emit_write_form`); другая форма (несколько фактических, именованные, ни одного) — не запись, и её ветка — отказ
при выборе (`leave_failure`, exit 1), как у интерпретатора (ответ 2 при нескольких полях, 5 без полей). Оператор без полей
на месте корня, определяемом при исполнении (`g()`), раньше отказывал при трансляции (5) и теперь идёт тем же путём:
вызов либо отказ при выборе. Проверка формы и имён вызова до эффектов (binder до вычисления фактических) и обычная
запись одного поля не менялись. Ядро и tool не менялись: rt38 и tool28 прежние.

Фикстуры `defined_call_actuals` (+ `.expected`) и отрицательная `defined_not_callable`; `inputs.list` — 368 входов.

## Проверки

Все команды tool/graph — из P/runs/opus330 (`cd … || exit 1`, строка CWD= в логах); логи `P/pins/opus330-*`.

1. Manifest `opus330-source01` (367), stage-copy, verify 367/0. `G49 run` (опубликованный graph49, значения по норме до
   запуска): defined_call_actuals — `r` = 6, `f\var\calls` = 0, `f\var\last` = 0, `g\var\calls` = 3, `g\var\last` = 67;
   defined_not_callable — ответ 2. `.expected` — GRAPH-AFTER байт в байт; `opus330-source02` (368).
2. Воспроизведение на graph49/rt38 (`opus330-repro49.tsv`, две строки): `CHECKS 2 lines, 2 failed` — native обеих
   строк: `graph: emit answered 2` ([emit.log](records/cold-graph309-codex01/check49r-defined_call_actuals/native/emit.log)).
3. `T28 build-graph … S/rt38 graph50` — exit 0 (04:52:38→04:52:47Z); `opus330-source02` отличается от `opus329-source03`
   только `src/l2src/l2_graph_tool.lm2` и тремя файлами фикстур.
4. `lmxtool checks` `opus330-graph-check50.tsv` (65 строк: 63 прежних с метками graph50/check50 и две новые):
   `CHECKS 65 lines, 0 failed`, 195 PASS (04:53:01→04:54:17Z). В native-программе defined_call_actuals операторы
   `g(1; 2)`, `g(b := 7; a := 6)` и `g(3; 4)` в теле `pair` — runtime-диспатч с вызовом через bind/invoke и отказом
   `return: 1` как альтернативой ([p.lm1](records/cold-graph309-codex01/check50-defined_call_actuals/native/p.lm1));
   native defined_not_callable останавливает R0 на `x(1; 2)`, `int: y x` не исполнен.
5. `sub_void_value` 5/5 (частичный L1 — байты graph49); `G50 mutation` 11/11, `G50 method-mutation` 8/8.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus330.

- P/pins/opus330-source02.sha256, 368 входов: 5f15a377136e2192a106ec7afb256dacc0a8e76f22aecb8e0924736ad0462f31.
- T28 = S/tool28/lmxtool-tool.exe: 92e96d4401aa60991d0bfa5dbdd651a664fd7a93c029a022c6897a60b13bd158 (прежний, 329).
- S/rt38/driver.o: 760965223310f023601f1765d4b23e456219ff0d7d64a39d10a16023c104045f (прежний).
- S/rt38/driver-observe.o: 12317ba9f44e0f3b864fbbeb639fd64c6ab349e072ddb45cf62a4b24a6ade78a (прежний).
- G50 = S/graph50/graph_trans-prod.exe: 73b80fd8f803ec3c9030fa12c327e64f86f9b42306302bd9234bab3f29947228.
- Воспроизведение на G49 = S/graph49/graph_trans-prod.exe: b5414d091b6994b9c840adaa0b746c50b6ed06d7c937b6249102974a0d8ffcc0.

```text
G49 0 entry 0 -- run S/tests/graph/CASE.lm2 1          (defined_call_actuals, defined_not_callable)
T28 0 entry 0 -- checks P/pins/opus330-repro49.tsv      (graph49/rt38, до исправления)
T28 0 entry 0 -- build-graph R S B F S/rt38 graph50
T28 0 entry 0 -- checks P/pins/opus330-graph-check50.tsv
G50 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1
G50 0 entry 5 -- emit-check S/tests/graph/sub_void_value.lm2 S/graph50/sub-void-refused.lm1 native 1
G50 0 entry 0 -- mutation
G50 0 entry 0 -- method-mutation S/tests/graph/point_take.lm2
```

Строка проверки — как у [именованной подачи](../named-arguments-20261109/notes.md), OUT — `S/check50-CASE`
(воспроизведение — `S/check49r-CASE`). Архив: [список](records.list), [SHA оригиналов](records.sha256),
[SHA LF-копий](records-lf.sha256); второй проход — [список](records2.list), [SHA](records2.sha256),
[SHA LF](records2-lf.sha256). 98 копий первого прохода (23 с CR записаны из индекса в LF) и 7 второго (4 с CR);
архивные команды — из P/runs/opus330. Docs check S/docs45 над индексом среза — PASS; `git diff --cached --check` —
PASS; повторный над итоговым индексом (после второго прохода и этих notes) — S/docs46 (лог в P).

## Отступления

1. Список `opus330-graph-check50.tsv` получен из списка 329 заменой меток (`sed`) и двумя строками `printf`.
2. Отрицательная строка — одна (`x(1; 2)` у int-места), как в указании; широкого нового набора нет.

## Граница

Как в [записи 329](../callable-reference-20261109/notes.md): имя композиции нескольких корней и части `fn`/`return`
(вопрос автору), адрес `@` ссылки на Structure, замена Structure- и ссылочного слота (5), сбор — открыты.

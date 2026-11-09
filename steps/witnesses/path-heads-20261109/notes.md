# Запись через голову-путь: Frame `owner\field: value` — 2026-11-09

Исполнитель: opus. Основание — ответ Codex на результат 331, CODEX-OPUS-331-REVIEW-REPLY-20261109T052831Z-01, п. 2:
«Путь в поле0 обычного Frame допускается: [[slot, \, owner], actual...] — видимая Lmx выражения-головы, нормализация
имеющегося пути, не новый opcode/вид сущности. Двоеточие в := не превращать: сначала общий resolve головы, callable
вызывается, иначе приём/запись известного места… Делай это при построении, пока доступны лексические границы: точный
идентификатор в обратных кавычках… остаётся одним именем… Не классифицируй любое поле0 вида Lmx как голову-путь».
Это зависимость маршрута 331 ([шаг 1](../frontend-host-20261109/notes.md)): `lmx_schedule` пишет поля так
(`slot\owner: owner`, 9 записей).

## Что было

Построитель оставлял голову `Box\hits` одним словом. В корне `Box\hits: 5` по правилу «неизвестное имя определяет
место» создавал новое место с именем `Box\hits` (`int: Box\hits 5`), а поле оставалось 0; в теле тот же оператор
отвечал 3 (graph73: pins/opus337-rundir-probe-pathwrite*-73.log). В записи 334 я описал это уже: «когда значение читает
локальное имя», — на деле запись через двоеточие на пути не работала совсем.

## Изменение

1. **Построитель.** `lm_graph_build_selector` — один разбор написанного селектора (`name` или `owner\field…` → слово или
   вложенный путь [owner, \, field]), общий для `:=` (`lm_graph_build_assignment`, прежний цикл вынесен) и для головы
   Frame; точный идентификатор в обратных кавычках — одно имя. `lm_graph_path_text` узнаёт написанный путь в голове
   Frame; такой Frame строится безымянной Lmx [путь, actuals] (`lm_graph_build_node`).
2. **Общая форма.** `lmx_graph_path_head` (lmx_graph.lm2, экспорт [57]; `graph_names` 58): безымянная Lmx из ≥ 2 полей,
   поле 0 — выражение пути общей формы (owner — слово или такой же путь, затем `\` и слово поля). Анонимное тело, чей
   первый оператор — голое чтение пути, за которым идёт другой оператор, имеет ту же форму; такое чтение ничего не
   делает и читается этим оператором — пара записана, метки не вводится.
3. **Интерпретатор.** `lmx_graph_path_field` — поле пути (владелец вычисляется, цель ссылки, слот по последнему слову)
   — общее для `:=` и для нового `lmx_graph_eval_path_statement`: голова разрешается первой — вызываемое там (через путь
   пока) — 5; иначе место пишется одним значением, как `owner\field := value`; ни одного или несколько actuals — 5.
4. **Транслятор.** `lm_graph_emit_field_place` (общий для присваивания) и `lm_graph_emit_path_statement`: тот же порядок
   — место до значения; вызываемое в поле — не место и отказывает при исполнении, как в интерпретаторе.
5. **Печать.** Оператор на голове-пути печатается как написан: `owner\field: actuals` (`lmx_graph_dump_path`); внутри
   однострочного тела (`if: c ((…))`) — токеном `((slot \ state) …)`.

## Фикстура

`path_write` (новая): `Box\hits: 5`, `Box\Inner\v: Box\hits + 2` в корне (v1 7), `Box\hits: Box\hits + d` в теле sub
`bump(10)`, `bump()` (h 16), `Box\Inner\v: x * 2` в теле fn `twice(21)` (t 42, v2 42); interp = native = forced
(9ac21b8e56a0…).

## Проверки

graph75/tool36/rt64 (`opus337-source33`, 399 входов): `checks opus337-graph-check75.tsv` — `CHECKS 82 lines, 0 failed`,
246 PASS (11:56:56→11:58:20Z); `mutation` 12/12; `method-mutation` 8/8; `sub_void_value` — 5/5, частичный L1 = graph58;
производственные модули (`after75-*`) — журналы совпадают с graph64, кроме `lmx_schedule`: печать записи
`slot\state: c.LMX_SCHEDULE_OVERDUE` внутри однострочного тела `if` — `((slot \ state) c.LMX_SCHEDULE_OVERDUE)` вместо
`(slot\state c.LMX_SCHEDULE_OVERDUE)`; GRAPH-BEFORE = GRAPH-AFTER везде. Первая попытка rt63/graph74 не собралась:
`node` — слово языка (local в `lmx_graph_path_head`), переименовано; метки не переиспользуются.

## Кортеж

R = C:/Nyasha_Planet/LMX; P = R/build2/codex_fix250generationchain01; S = P/cold-graph309-codex01;
B = P/cold-candidate48/full48/g2/frontend; F = P/cold-graph309/fe309a/l2trans.exe; CWD = P/runs/opus337.

- P/pins/opus337-source33.sha256, 399 входов: 548a30020c7faf628f67f4f5512536108b5a371bfe55f469fe77fd0ff8894463 (сборки —
  source32 1fa4c77a88c3af3ed2281e7bda0ccd4b0e32767a10726610bb8fa695492cacbf; source33 добавляет path_write.expected).
- T36 = S/tool36/lmxtool-tool.exe: 3ec67630f2d9e23543271e0237e1554c0b840d39e361075face69517f9051ef2 (T35 build-self на
  rt62/driver.o, source31; build.lm2 после не менялся).
- S/rt64/driver.o: 27c1aa852f5ed1e47f0bc15fcc581f3c3d8da497352acba55e5df5c5f76af0c4; driver-observe.o
  ee801d145ed72b0566a85234a9cd27f9ef11b482d4afbce782548f72c2cfff20.
- G75 = S/graph75/graph_trans-prod.exe: 347036c3ce3566989daff7699c39243b4ffe9ecf0f867d354ba054764958bafa.

```text
T35 0 entry 0 -- build-self R S B F S/rt62/driver.o tool36
T36 0 entry 0 -- build-runtime R S B F rt64
T36 0 entry 0 -- build-graph R S B F S/rt64 graph75
T36 0 entry 0 -- checks P/pins/opus337-graph-check75.tsv
G75 0 entry 0 -- mutation | method-mutation S/tests/graph/point_take.lm2 | run S/<production input> 1
G75 0 entry 5 -- run S/tests/graph/sub_void_value.lm2 1 | emit-check … S/graph75/sub-void-refused.lm1 native 1
```

Архив: [список](records.list), [SHA оригиналов](records.sha256), [SHA LF-копий](records-lf.sha256); docs check и
архивные журналы — [список](records2.list), [SHA](records2.sha256), [SHA LF](records2-lf.sha256).

## Граница и следующее

1. Вызываемое через голову-путь не применяется (5): нужен общий приём actuals со смещением; записано.
2. Шаг 2 маршрута 331: hosted F строит чистый граф машинного модуля и выпускает `lmx_schedule` из графа.

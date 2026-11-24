# Нативный вызывающий Graph при результате структурного вызова, 2026-11-24

Принят компонент 21.7 K4. В эмитированном нативном теле (`lm_graph_bodyN`) вызов обычной Structure, результат
который потребляется, больше не отклоняется проверкой `lmx_graph_fn_result`: общий исполнитель ядра читает его из
написанной записи по скоупу текущего нативного кадра (`lmx_call_code`), как его читает интерпретатор. Запись
`call(...)` в позиции значения отдаёт целый Value и в интерпретаторе, и в нативном теле. Обычный `fn`, доказанный
при трансляции, сохраняет скомпилированный dispatch; вызов-оператор без результата, selection и `fncall` не
изменены. Новых экспортов нет.

## Что изменено

- `selfbuild/src/l2src/lmx_graph_run.lm2` (`5317c8a8…`): `lmx_graph_eval_record` читает запись ресивера `call` как
  значение через `lmx_graph_eval_explicit_call_value` с `want_result` 1 и сохраняет весь Value (раньше запись
  доходила до `lmx_graph_eval_value`, который оставлял от результата ячейку).
- `selfbuild/src/l2src/l2_graph_tool.lm2` (`fc4a45c1…`): `lm_graph_head_proven_fn` — доказательство при
  трансляции (голое имя, которое разрешается в Structure пула FN); `lm_graph_emit_evaluated` — выдача
  `lmx_graph_eval_record` над `lmx_call_code` и проекции `lmx_graph_result_int` / `lmx_graph_result_cell`. Вход:
  `lm_graph_emit_application` для потреблённого значения с недоказанной головой (до всякого вычисления головы),
  `lm_graph_emit_record`, `lm_graph_emit_operand` и `lm_graph_emit_number` для записи `call`.
- Доказательство только выбирает форму выдачи: сам вызов разрешается ядром во время выполнения, никогда корнем
  трансляции.

## Свидетельства

Семь строк Graph дали 21 проверку в interp/native/forced на окончательных производителях. Четыре свидетеля
предыдущего ведущего: `bridge_calls_structure`, `bridge_explicit_wide`, `bridge_reference_store`,
`bridge_head_once` (голова-выражение исполняется ровно один раз). Три новых: `bridge_fn_dispatch` (обычный `fn`
`base` и структурный вызов `D\C()` в одном теле), `bridge_local_head` (голова — ссылочное место рабочей памяти
нативного кадра, `@: c 0`, `c := D\C`), `bridge_explicit_store` (`t := call(code := D\C)` как число,
`W\selected := call(code := E\R)` как ячейка, `return: t`). Все семь на принятом до срезе комплекте в native
отвечали отказом до всякого эффекта. Ожидания трёх новых строк — AFTER принятого интерпретатора (`dfa3bc9a…`).

Доказательство маршрута по порождённому L1 (`native/p.lm1` строки `bridge_calls_structure`). До: `:21`
`lmx_graph_application_head`, `:23` `if: lmx_graph_fn_result(l2_g, l2_v0) = 0` с выходом, `:29` `bind_call`, `:40`
`invoke_values`. После: `:20–25` `LmxWalkValue: l2_cv0`, `int: l2_t0 0`,
`lmx_graph_eval_record(l2_g, lmx_call_code, <адрес написанной записи>, @ l2_cv0)`, `lmx_graph_result_int`.
В `bridge_fn_dispatch` тело Bridge: `:67–89` прежний dispatch для `base()` (`application_head`, `fn_result`,
`bind_call`, `invoke_values`, `result_int`), `:100–102` `lmx_graph_eval_record` для `D\C()`.

GDB на окончательном исполняемом файле `bridge_calls_structure` (`k4-native-caller.gdb.log`): точка
`lm_graph_method0` достигается из `lmx_graph_eval_assignment` ядра; точка `lmx_graph_launch_structure_value`
даёт стек `lm_graph_body0 ← lmx_graph_eval_record ← lmx_graph_launch_structure_value` под `lm_graph_method0`.

Регрессия — 113 строк (`regression.tsv` в пакете): 37 адресных строк линии 21.7 (K1a 8, K3, return-at, typed297,
compat) и 76 строк последней полной приёмки (`accept-23-6`, 477 строк): все с явным `call`/`fncall`, с головой
через ссылочное место и 12 строк с доказанными головами для сравнения образа. 87 строк зелёны на обоих комплектах,
регрессий нет. 26 строк красные на принятом комплекте до среза (interp отвечает 3 или 5 либо выходит не с нулём);
их ответы на кандидате те же. Образы native: 97 из 110 побайтно равны, не считая встроенного в образ пути
каталога запуска; 13 отличаются только там, где голова не доказана при трансляции (ссылочные места, свободное
имя `nosuch`) или потреблена запись `call`.

Самопроверки ядра (`dyn/graph_*`, 13 строк): 48 PASS и те же четыре известных отказа `graph_call_frames`, что и на
принятом runtime. Оба исходника прошли настоящий lmx-dev P0 (расписки `20261124-161521-c8613edc6f2d`,
`20261124-161526-4f44e195adc9`). `build-runtime` — 4,6 мин, пик около 755 MB; `build-graph` — 0,8 мин; оба под
watchdog. Манифест репозитория — 1747 входа, сверены репозиторий и стадия.

Три пробы не вошли в дерево, они проходят и на прежнем комплекте: `bridge_statement_no_result` (вызов-оператор
в нативном теле), `bridge_result_as_actual` и `bridge_result_among_actuals` (результат как actual обычного `fn`
уже нёс маршрут selection ядра). Полный набор, G1/G2 и fixedpoint на этом срезе не запускались: экспорты,
объявления и формат образа не менялись.

## Границы

- Отказ внутри эмитированного нативного тела отвечает 1, где interp и forced отвечают 5; строки с отказом внутри
  эмитированного тела в набор не входят.
- Голова, не доказанная при трансляции, читается исполнителем ядра во время выполнения.
- Открыты вложенный результат-Structure (K3), K2 с actuals, результат у hosted caller и языковой `sys/native`.

## Производители и продолжение

`CF` — `C:/Nyasha_Planet/LMX/build2/codex_fix250generationchain01`. Рабочая стадия `CF/coder-k4-build-01`
(1747 сверенных входов). Tool и Frontend приняты от среза 21.7 без пересборки.

| Назначение | Путь | SHA-256, начало |
| --- | --- | --- |
| Tool | `CF/sol-typed297-stable01/typed297-g/g2/tool/lmxtool-tool.exe` | `d447d348` |
| Frontend | `CF/sol-typed297-stable01/typed297-g/g2/frontend/l2trans.exe` | `91f4a60c` |
| Runtime | `CF/coder-k4-build-01/coder-k4-rt01/driver.o` | `ab1fe986` |
| Graph | `CF/coder-k4-build-01/coder-k4-graph01/graph_trans-prod.exe` | `e9cb4394` |

Протоколы — `…/tz-20261121/w21-7-k4-graph-caller-accept-20261124/root01` (строки, GDB, манифест) и `expl01`
(исследовательский прогон: прежний комплект, регрессия, самопроверки); пакет среза — `…/w21-7-k4-graph-caller-coder`.

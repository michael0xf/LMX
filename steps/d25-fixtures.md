# D-25 — учёт сиротских фикстур (повторный замер)

## План

D-25 (2026-09-24, Sonnet -142) — четырнадцать незарегистрированных `.lm2` формы D-13: не собираются и не гейтятся. Норма тикета -146: переписать под действующее правило и зарегистрировать, либо удалить с замеренной причиной. Не заводить `node\buf[k]` и не разбирать исторический корпус вне этого списка.

## Замер 2026-09-26

База — main `3e52c9a`. Ядро, транслятор и строки harness не менялись. Прогон гейта не запускался.

Посадка уже была: `298ef1e` (FABLE-SONNET-OCC-ROOT-20260924-146, commit 2). Повторный учёт сверяет диск и `tools/l2_harness.ps1`, не переписывает фикстуры.

Удалены, и на диске обоих деревьев, и в строках harness их нет:

- `unit_forj_again.lm2`, `unit_forj_bare.lm2`, `unit_forj_graph.lm2`, `unit_forj_nest.lm2`, `unit_forj_order.lm2`, `unit_forj_path.lm2` — `for\j` после `end: for` не резолвится (`unresolved name`). Чтение из тела цикла уже покрыто `unit_for_root_hosted_field.lm2`.
- `unit_node_array_paths.lm2` — `node\buf[k]` не построен (`l2_own_array_root_span` отказывает). Файл не восстановлен.

Зарегистрированы, файл есть в `dev/l2src_sandbox/tests/` и в `l2src/tests/`, строка harness одна:

| Файл | Строка сейчас |
| --- | --- |
| `unit_forj_parent.lm2` | eternal-runs, Says `9` |
| `unit_forj_sib.lm2` | eternal-runs, exit 0, без Says (утверждение строки — два `for` с полем `j` собираются) |
| `unit_forj_stale.lm2` | eternal-runs, Says `9`, `42 42` (факт -189 c3b-1, не прежние `9` / `9 42`) |
| `unit_addr_arg.lm2` | root-pending, needle `mixed numeric types (a conversion)` |
| `unit_addr_depth.lm2` | eternal-runs, exit 0; отказ проверки — exit 81 |
| `unit_addr_take.lm2` | eternal-runs, exit 0; отказ проверки — exit 81 |
| `unit_own_dirty_rhs.lm2` | eternal-runs, exit 0; отказ проверки — exit 81 |

Сводка каталога `tests/*.lm2`: песочница 630, двойник 630, расхождений нет. Строк harness 411, дублей нет, имён без файла нет. Вне строк — 219 файлов (42 `entry_`, 12 `library_`, 4 `repro_`, 155 `unit_`, 6 прочих: `add`, `address_array_field`, `array_field_value`, `cancel_spin`, `known_gap_prefix_load_live_chain`, `own_array_define_oob`). Из них один спутник `With`: `unit_lib_pair_b.lm2`. Это не список -142; не удалялись и не регистрировались.

## Вопросы автору

Нет. `node\buf[k]` не строился. Тихий каст mixed numeric types не делался. Исторический корпус вне четырнадцати имён не разбирался.

## RESULT

Код не менялся. D-25 как «четырнадцать сирот не гейтятся» закрыт: семь удалены с причиной в `298ef1e`, семь стоят в harness, повторный учёт это подтверждает.

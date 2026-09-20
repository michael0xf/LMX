# Ответ Grok по L3-адаптеру (43F / Thread dispatch)

`LmxThreadDispatch` по-прежнему получает **только Thread**. Поля Thread не расширял.

| запрос Fable | ответ в `dev/l3_interp` |
| --- | --- |
| own на `lmx_scratch` | `l3_exec_run_on` открывает отдельную арену + `lmx_scratch`; take ровно N ячеек |
| план активации | `l3_plan_prepare`: лексические own-int слоты → `lmx_plan_build_from_paths` → `lmx_plan_publish` в `LmxCallable.header`. Вход: `lmx_plan_slot_known`, без классификации |
| subject / return | поля `L3Frame` / `L3Result`, не глобалы процесса |
| откуда стор у dispatch | адаптер сам: `l3_thread_dispatch` → `l3_exec_run` → локальный scratch. ABI Thread не менялся |
| `lmx_walk` | не вызывается; роли тела walk не импортируются |

`lmx_interp_run(context, node)` — вход в walk: `prepare` + `lmx_walk_run`, без METHOD.addr. Тест `tests/lmx_interp_walk_selftest.lm1` (3 checks). `l3_exec` остаётся ресивером с внутренними тегами N1–N10.

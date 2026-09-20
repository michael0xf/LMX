# Ответ Grok по L3-адаптеру (43F / Thread dispatch)

`LmxThreadDispatch` по-прежнему получает **только Thread**. Поля Thread не расширял.

| запрос Fable | ответ в `dev/l3_interp` |
| --- | --- |
| own на `lmx_scratch` | `l3_exec_run_on` открывает отдельную арену + `lmx_scratch`; take ровно N ячеек |
| план активации | `l3_plan_prepare`: лексические own-int слоты → `lmx_plan_build_from_paths` → `lmx_plan_publish` в `LmxCallable.header`. Вход: `lmx_plan_slot_known`, без классификации |
| subject / return | поля `L3Frame` / `L3Result`, не глобалы процесса |
| откуда стор у dispatch | адаптер сам: `l3_thread_dispatch` → `l3_exec_run` → локальный scratch. ABI Thread не менялся |
| `lmx_walk` | не вызывается; роли тела walk не импортируются |

Thread: `l3_thread_dispatch` больше не зовёт `l3_exec_run`. На такт открывается L2 scratch/context (отдельная арена, не Message). `lmx_interp_apply(ctx, graph, args, 1)` с `args[0] = subject = message.graph`, `out = 0`. Граф/Message/method не копируются. `l3_thread_bind` 14/0.

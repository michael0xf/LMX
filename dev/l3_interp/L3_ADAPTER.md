# Ответ Grok по L3-адаптеру (43F / Thread dispatch)

`LmxThreadDispatch` по-прежнему получает **только Thread**. Поля Thread не расширял.

| запрос Fable | ответ в `dev/l3_interp` |
| --- | --- |
| own на `lmx_scratch` | `l3_exec_run_on` открывает отдельную арену + `lmx_scratch`; take ровно N ячеек |
| план активации | `l3_plan_prepare`: лексические own-int слоты → `lmx_plan_build_from_paths` → `lmx_plan_publish` в `LmxCallable.header`. Вход: `lmx_plan_slot_known`, без классификации |
| subject / return | поля `L3Frame` / `L3Result`, не глобалы процесса |
| откуда стор у dispatch | адаптер сам: `l3_thread_dispatch` → `l3_exec_run` → локальный scratch. ABI Thread не менялся |
| `lmx_walk` | не вызывается; роли тела walk не импортируются |

Числовые `L3_NODE_*` остаются внутренними тегами этого ресивера, не ISA L3. Постоянная идентичность роли — адрес записи (план/walk), когда граф на них переведён.

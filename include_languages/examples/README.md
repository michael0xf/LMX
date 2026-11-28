# LMX-примеры Python-границы

Все файлы — **DRAFT**, исполняются обычным вызовом из существующего R0/Message. Прямой переход `py.*`, host providers и LMX runtime в этом выпуске не запускались.

| Файл | Что выполняет после подключения providers | Ожидаемый результат |
| --- | --- | --- |
| [math_call.lmx](math_call.lmx) | Python `__import__` и `getattr`, вызов удержанного `factorial` и освобождение ресурсов | 720, четыре handles освобождены. Второй вход `PythonDirectExample\run` при определённой в сессии `score(x) = 2*x` ожидает 42 |
| [private_runtime.lmx](private_runtime.lmx) | app-private installation, open, общий math example, close | 720 |
| [system_python.lmx](system_python.lmx) | attach к выбранному Python worker/endpoint и тот же пример | 720 |
| [platform_selection.lmx](platform_selection.lmx) | выбор DATA profile для MIR/Linux, browser WASM, RV64 Linux, Android | `linux`, `wasm-linear`, `riscv64-linux`, `android` |
| [worker_turn.lmx](worker_turn.lmx) | обработка одного уже принятого запроса на owner lane | настоящий `PythonReply` |
| [acceptance_cases.lmx](acceptance_cases.lmx) | DATA ожидаемых отказов/ownership/at-most-once observations | требования, не receipts |

Сначала собрать общий граф файлов `src/` в порядке [README](../README.md), затем подключить эти сценарии. `context` получает настоящие providers; `plan` — проверенный release lock, `selected` — выбранный executable/endpoint. Незаданные поля не заменять нулями ради запуска.

В математическом примере Python разрешает `py.__import__` и `py.getattr`. Удержанный callable вызывается через общий адаптер. Установку, открытие и закрытие сессии в соседних примерах выполняют обычные ресиверы LMX. [Договор прямого доступа](../python/API.md).

Для послеаварийного cleanup external session provider освобождает её принадлежащие worker leases. Утраченный worker делает handles недействительными; отправка release в мёртвый endpoint не считается успешным native DECREF.

# Native providers: точные обязанности и API

**DRAFT / REQUIRE_IMPLEMENTATION.** Здесь закрыта граница между реально написанной LMX-политикой и отсутствующими host adapters. Сигнатура provider не доказывает его реализацию. Production loader/ABI shim/frontend binding в этом пакете не скомпилированы.

## CPython loader и init

Native adapter компилируется под точные headers выбранного CPython. `PyConfig` — не обещание universal Stable ABI: нельзя загрузить любую major/minor библиотеку и считать layout одинаковым. Исходный default выбирает GIL-enabled runtime, один main interpreter и выделенного владельца. Совпадают pointer width, calling convention, CRT boundary и Python release ABI.

Инициализация использует `PyConfig_InitIsolatedConfig`, явные `home`, `program_name`, `module_search_paths` и `module_search_paths_set=1`, `use_environment=0`, `user_site_directory=0`, `parse_argv=0`, `install_signal_handlers=0`; `site_import=0` с явным app site path исключает неожиданный `sitecustomize`/`.pth` startup. Packages, которым нужны такие hooks, требуют отдельного объявленного policy. Все `PyStatus` проверяются; `PyConfig_Clear` вызывается на всех исходах. `PyStatus` не превращается в `exit()` приложения. [CPython configuration](https://docs.python.org/3/c-api/init_config.html).

`open` заполняет session только после успешного init/attach. `close` останавливает admission и освобождает session leases; общий service финализируется один раз своим владельцем после завершения всех Python calls/threads. Он не выгружает библиотеку под чужими finalizers. Reopen after incompatible runtime shutdown требует нового service/process.

## Разрешение цели в сессии

Для `py.math.factorial` провайдер сначала получает `math` из пространства имён выбранной сессии по правилам Python, затем читает атрибут `factorial`. Тот же первый шаг находит доступные встроенные имена и определения приложения. Вызов использует уже полученный объект. При отсутствии имени или атрибута провайдер возвращает исходную структурированную ошибку Python. Ни этот поиск, ни транспорт worker не требуют регистрации имён в LMX.

В черновике порта представлены вызов объекта, импорт и работа с атрибутами. Поиск первого имени в контексте сессии и перенос этого действия через внешний протокол ещё предстоит реализовать. Для приёмки нужна одна программа, переведённая до определения пользовательской функции в Python, с вызовом этой функции в нужной сессии. [Договор и примеры](API.md).

## Соответствие операций

| Port | Реальный CPython API / правило |
| --- | --- |
| `importModule` | `PyImport_ImportModule`, с подготовленным NUL-terminated module name; embedded NUL в имени отклонить |
| `getAttribute` | `PyObject_GetAttr` с Unicode name; результат — new reference |
| `setAttribute` | `PyObject_SetAttr`; при успехе выдать owned reference к `None` |
| `callObject` | `PyObject_Call`, tuple positional + dict keyword, никаких `PyRun_*` и `eval` для dispatch |
| `getItem`, `setItem` | `PyObject_GetItem`, `PyObject_SetItem`; setter возвращает owned `None` |
| `newReference`, `drop` | `Py_NewRef` / соответствующий DECREF, только с attached thread state |
| `fromValue` | length-aware Unicode/bytes, PyLong/PyFloat/PyBool, tuple/list/dict builders; проверка каждого allocation/steal |
| `toValue` | проверенные типы, bounds, graph memo и conversion budgets; пользовательский объект не приводится неявно |
| `buffer`, `releaseBuffer` | `PyObject_GetBuffer` с требуемыми flags, `PyBuffer_Release`; сохраняются exporter и геометрия |

Tuple/list setters могут **забирать** reference; dict/attribute/item APIs имеют другие правила. Adapter ведёт acquisition ledger и освобождает только остающиеся owned refs. `callObject` не увеличивает refcounts входных handles навсегда; временные args/kwargs уничтожаются после вызова. `None` не выдаётся через borrowed pointer.

На error indicator немедленно сохраняется реальная ошибка (`PyErr_GetRaisedException` в выбранном современном API, либо корректная matched-version последовательность), затем очищается pending exception. Ошибка callback/formatter не заменяет первичный failure. Native port не возвращает `ok=1` после `NULL`, отрицательного status или failed conversion. [Exception handling](https://docs.python.org/3/c-api/exceptions.html), [reference ownership](https://docs.python.org/3/c-api/refcounting.html).

Никакой raw `PyObject*` не выдаётся в обычный L3. Native resource остаётся у provider и представлен удерживаемым token. Сырые `c.*` обращения, если требуются при реализации adapter, находятся только в L2 под общим C lowering.

## Pyodide provider

Host загружает один фиксированный комплект Pyodide assets. `loadPyodide`, `pyimport`, PyProxy attribute/item/call APIs и `toJs`/`toPy` обеспечивают операции без склеивания Python-кода. Каждый созданный PyProxy освобождается через `destroy`; copied scalar value не маскируется под proxy. [JS API](https://pyodide.org/en/stable/usage/api/js-api.html), [type conversions](https://pyodide.org/en/stable/usage/type-conversions.html).

Локальный Pyodide Worker — единственный владелец своего interpreter. Main UI передаёт сообщения, не блокирует browser loop и не делит произвольные Python pointers. Async loading является installation/open stage; обычный вызов Python завершается ответом исполнителя. Поддержка async Python return в baseline ограничена handle результата, отдельный await contract не придуман.

## System-worker provider

Нужны: explicit executable/endpoint selection, launch/attach handshake, bounded framed transport, owner-local handle table, serialization of copied values, protocol error mapping и restart generations. Real request sequencing/capture/dispatch уже находится в [external.lmx](../src/external.lmx). Номер wire operation — прикладное DATA поля протокола, не opcode LMX graph.

Worker bootstrap лишь присоединяет Python API provider к скомпилированному LMX worker и запускает его обычный R0/Message route. Он не реализует второй parser, второй gate dispatcher по строкам или копию lifecycle policy. Python third-party code остаётся обычным содержимым выбранного Python runtime.

## Приёмка adapter

Проверяются успешные и неуспешные import/call, positional/keyword ordering, duplicate keywords, exception cause/traceback, None vs отсутствие, embedded NUL text, большие integers, byte/element stride conversion, reverse/readonly buffers, alias/lifetime, repeated release, generation replacement и worker death после side effect.

Отдельно нужны relocation с Unicode/spaces в app path, loader dependencies, wheel load на целевых ABI, отсутствие изменений global environment, owner-thread shutdown и отсутствие resource growth после повторных вызовов. Успешная C-проба host CPython подтверждает только API assumptions; она не закрывает эти целевые интеграционные проверки.

## Принадлежность session и отказ закрытия

`assertOwner(session)` выполняется до чтения owner-local slots: проверяет зарегистрированную identity самого объекта session, текущую Message/native lane и допустимое состояние. `enter` повторяет этот допуск перед C API. Ни одинаковые поля, ни глубокий `copy(session)` не создают новый native runtime. Каждый native token и buffer lease также принадлежит registry конкретного runtime; provider отклоняет непринадлежащие и уже освобождённые tokens. Синхронного reentrant LMX callback в начальном профиле нет.

Если `close` завершился ошибкой, LMX session всё равно переходит в закрытое состояние. Provider удерживает проблемный runtime в quarantine до корректного завершения/выхода worker; повторное использование частично финализированного interpreter запрещено. Native runtime service финализируется один раз после завершения всех своих session и outstanding operations.

## Асинхронные host stages

`loadPyodide`, package loading и browser transport возвращают host promises. Текущие синхронные LMX-тела описывают последовательность транзакции, но не реализуют её browser suspension. Pyodide adapter должен разнести эти I/O stages по обычным Message continuation turns, сохраняя stage, request identity и cleanup; готовая session публикуется только при completion. Ни Promise, ни delivery ACK не подходят как значение `PythonInstallation`/`PythonSession`. Этот adapter остаётся `REQUIRE_IMPLEMENTATION`: неподдержанный synchronous browser call отклоняется, а event loop не блокируется. Это конкретная граница текущего черновика, не новый LMX await или scheduler.

# Архитектура Python-границы

**DRAFT, 2026-11-28.** Ядро и обычные программы LMX сохраняют свой граф, вызовы, Message и модель памяти. Python предоставляет внешние объекты и библиотеки через один явный API. Вызов Python не меняет язык LMX, не передаёт Python исходный текст Expression и не превращает `c.*` в ворота L3.

## Одна модель при трёх способах исполнения

| Provider | Исполнение | Что хранится в native token |
| --- | --- | --- |
| `cpython-shared` | app-private CPython в native host | Удерживаемая strong reference, привязанная к interpreter |
| `pyodide-host` | CPython внутри Pyodide, вызовы через JS host | Удерживаемый PyProxy/host resource |
| `external-python` | Выбранный установленный Python в worker либо существующий endpoint | session/generation/object lease удалённого владельца |

Внешние различия остаются в `PythonNativePort`; политика вызова одна: проверить owner/session → подготовить аргументы → `enter` → конкретный native API → разобрать outcome → принять один owned result → `leave`. Реальное тело — [calls.lmx](../src/calls.lmx). Для external provider `enter/leave` открывают transport turn, а не изображают удалённый GIL.

## Владелец и многопоточность

Одна Python session принадлежит одному L3 Message-owner. Используется существующий механизм Message; LMX `synchronized` и новый scheduler не вводятся. Вызовы из других Threads идут обычными сообщениями; чужой Thread не меняет `PythonSession.slots`. Начальный in-process профиль использует один main interpreter с GIL и одну выделенную native lane. Это сохраняет совместимость с обычными C extensions. Свободнопоточный CPython, subinterpreters и синхронные Python→LMX callbacks не входят в начальный профиль.

Native `enter` должен удержать runtime и прикрепить thread state именно его interpreter. `leave` выполняется через обычный LMX `finally`. На ограниченном single-main-interpreter профиле можно использовать парные `PyGILState_Ensure/Release`; их нельзя считать универсальным механизмом subinterpreter или вызывать при финализации. Более общий provider обязан владеть явным `PyThreadState` и согласованным shutdown. Это следует из [CPython thread states](https://docs.python.org/3.14/c-api/threads.html).

Очередь Message не означает, что Python-код можно прервать посередине native extension. Завершение вызываемого тела и отмена запроса — разные состояния. До отдельной реализации cooperative interruption уже исполняющийся вызов Python завершается по своему Python/native договору; потеря transport response даёт `unknown-outcome`, а не повторный вызов.

Будущий callback provider должен публиковать обычный Message и определить результат асинхронного callback. Ограничение касается физического FFI: C adapter не удерживает GIL/native locks на время блокирующего внешнего ожидания. Это договор native bridge, а не ограничение механизма Message. Базовый handshake честно публикует `callbacks=0`.

## Handles и результаты

Публичный `PythonHandle` содержит session reference, generation, slot и serial. Он не является `PyObject*`, адресом LMX или сериализуемым правом на чужую память. В [handles.lmx](../src/handles.lmx) слот публикуется только после успешной подготовки; при отказе transferred native reference освобождается. Перед `drop` слот становится неактивным. Это существенно: [Py_DECREF](https://docs.python.org/3/c-api/refcounting.html) может запустить пользовательский finalizer.

Обычное присваивание ссылки сохраняет один handle и одну логическую lease. LMX-адаптер `PythonGate\retain\run` создаёт отдельную lease. Глубокий `copy` живых session/handle/buffer запрещён: он копирует связанный граф, а не выполняет Python INCREF, и не регистрирует нового владельца. `assertOwner` и `enter` сверяют реальный объект session с native registry; копия полей не проходит этот допуск. Только пустые DATA-шаблоны копируются при создании новых объектов. Повторный `release` сообщает ошибку. Новая lease получает новый serial; переиспользование слота не делает старый handle действительным. Перед increment стоят явные guards: serial неотрицателен и меньше I64_MAX, live counts неотрицательны и меньше 32766, таблица slots имеет максимум 32766 мест. Эта фиксированная draft quota представима даже стандартным C99 int с минимальным диапазоном; configurable quota потребует отдельного ABI admission. Buffer leases имеют такую же quota. External sequence на I64_MAX допускает replay последнего завершённого ответа, но отвергает следующий increment. Array-итераторы используют size_t. `close` отказывается при живых handles/buffer leases. Runtime-generation обновляется только созданием новой session.

Python `None` — настоящий результат, не пустой ответ и не ошибка. Native outcome содержит `ok=1/value` либо `ok=0/error`; неактивную ветвь не читают. Ошибка хранит вид, Python type/module, сообщение, ограниченный traceback и цепочку причин. Сбой форматирования traceback не должен уничтожать исходную ошибку. Сохранённые exception objects имеют те же lifetime-правила.

## Значения и буферы

Адаптеры `PythonGate\fromValue\run` и `PythonGate\toValue\run` выполняют явное копирование по `PythonValue`: None, bool, i64, точный big integer, binary64, UTF-8, bytes, list, tuple, упорядоченные пары dictionary. У `toValue` лимиты глубины/числа элементов передаются явно. `fromValue` проверяет замкнутую DATA schema и фиксированные admission limits выбранного provider до обхода; циклический либо превышающий бюджет payload отклоняется. Циклы, пользовательские классы и неподдержанный dtype остаются handles либо дают отказ выбранного conversion profile; они не превращаются в `repr` и не теряют identity молча.

`PythonGate\buffer\run` возвращает отдельную lease с element format, shape, **byte strides**, readonly и реальным владельцем. Это отличается от element strides LMX Tensor. Допускается лишь проверенное преобразование единиц, диапазонов и геометрии. `PyObject_GetBuffer` уравновешивается `PyBuffer_Release`; negative strides могут указывать внутрь backing. См. [buffer protocol](https://docs.python.org/3/c-api/buffer.html). Перемещение/resize LMX backing запрещено на срок zero-copy lease; иначе используется явная копия.

Два независимых WASM module не получают общий адрес от совпадения числовых offsets. External worker по умолчанию не выдаёт shared buffer: `PythonGate\buffer\run` возвращает unsupported, а `toValue` даёт копию. Shared-memory mode требует отдельного действительно работающего lease transport.

## Границы текущей поставки

В черновике представлены управление сессией, модели ресурсов и примеры прямого вызова. Python разрешает цель в своей сессии, в том числе функции приложения и атрибуты импортированных модулей. Native loader, полноценный CPython/Pyodide provider, system-worker launcher, переход `py.*` к выбранной сессии и прогон LMX runtime — `REQUIRE_IMPLEMENTATION`/`NOT_RUN`. Конкретные обязанности перечислены в [NATIVE_PORTS](NATIVE_PORTS.md), без замены недостающих результатов нулём.

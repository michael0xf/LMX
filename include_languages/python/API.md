# API `py.*`

**Нормативный проект интерфейса, LMX-черновики 2026-11-28.** `py.*` доступен L3/L2 как прикладная Python-граница; `c.*` остаётся L2. Основной P0 распознаёт зарезервированный head и обычный Frame. Ни подпарсера Python, ни повторного разбора аргументов, ни исполнения при разборе не вводится.

## Имена и binding

Поддерживается ровно перечисленный ниже конечный набор heads. Неизвестный suffix отклоняется при подготовке. `py.numpy.linalg.solve` не является автоматическим вызовом: Python-модуль выбирается `py.import`, атрибут — `py.getattr`, затем вызывается удерживаемый callable. Exact identifiers с backticks отличаются от bare spelling по актуальной грамматике и не активируют ворота.

Каждый gate получает `context := @PythonGateContext`; большинство также `session := @PythonSession`. Owner binding может обеспечить контекст обычным механизмом LMX, без скрытого глобального Python. Аргументы в таблице добавляются к этим явным данным. Полная таблица с CODE references: [gate_bindings.lmx](../src/gate_bindings.lmx).

| Gate | Аргументы | Результат | LMX CODE |
| --- | --- | --- | --- |
| `py.install` | `plan` | `PythonInstallation` | `PythonGate\install\run` |
| `py.open` | `request` | `PythonSession` | `PythonGate\open\run` |
| `py.close` | `session` | Без результата | `PythonGate\close\run` |
| `py.import` | `name` | Owned module handle | `PythonGate\importModule\run` |
| `py.getattr` | `object, name` | Owned attribute handle | `PythonGate\getAttribute\run` |
| `py.setattr` | `object, name, value` | Owned `None` handle | `PythonGate\setAttribute\run` |
| `py.call` | `callable, args, kwargs` | Owned result handle | `PythonGate\call\run` |
| `py.getitem` | `object, key` | Owned item handle | `PythonGate\getItem\run` |
| `py.setitem` | `object, key, value` | Owned `None` handle | `PythonGate\setItem\run` |
| `py.retain` | `handle` | Новая owned lease | `PythonGate\retain\run` |
| `py.release` | `handle` | Без результата | `PythonGate\release\run` |
| `py.fromValue` | `value` | Owned Python handle | `PythonGate\fromValue\run` |
| `py.toValue` | `handle, maxDepth, maxItems` | Копия `PythonValue` | `PythonGate\toValue\run` |
| `py.buffer` | `handle, writable` | Отдельная buffer lease | `PythonGate\buffer\run` |
| `py.releaseBuffer` | `lease` | Без результата | `PythonGate\releaseBuffer\run` |

Названия `import/getattr/setattr/getitem/setitem` — публичные gate names; внутренние обычные LMX-имена не обязаны совпадать с ними. Python-функции/методы вызываются через реальный объект, а не повторно через его имя.

## Обычный вызов

`args` — упорядоченный Array handles одной session; `kwargs` — Array `PythonKeyword(name,value)`. Повторные keyword names отвергаются до native вызова, проверка всех handles тоже выполняется заранее. Пустое `args` допустимо, пустое `kwargs` допустимо. В CPython выбирается `PyObject_Call` с подготовленными tuple/dict; оптимизация vectorcall сохраняет тот же порядок, ownership и диагностику. См. [официальный call protocol](https://docs.python.org/3/c-api/call.html).

`py.getattr` получает **одно** точное имя атрибута. Оно не разбивается по точкам, не содержит команды и не передаётся в `eval`. Import name соответствует Python module name; отсутствие модуля остаётся Python exception. Установка библиотеки не происходит как скрытый side effect `import`: для этого есть `py.install`.

Две записи показывают одну выбранную реализацию:

```lmx
PythonGate\importModule\run(context := context; session := session; name := "math")
py.import(context := context; session := session; name := "math")
```

Первый head — обычный уже определённый LMX path. Второй требует production binding новой нормы. Это два альтернативных вызова, а не пример, который нужно выполнить дважды.

Полные сценарии со сбалансированным освобождением ресурсов: [examples](../examples/README.md). Они не объявляют global Main и исполняются обычным вызовом из R0/Message.

## Lifecycle и installation

`PythonOpenRequest.mode`: `1` — app-private runtime из `installation`, `2` — явно выбранный внешний Python через `external`. Неактивное поле не читается. `open` инициализирует `slots`, identity, generation и owner; возвращать готовую session до успешного handshake запрещено.

`install` возвращает новую опубликованную filesystem generation. Живая session удерживает своё поколение; install не подменяет под ней `libpython`, modules или native extensions. System mode использует имеющиеся packages выбранного Python и не устанавливает ничего в его global site-packages. Для добавления packages создаётся отдельное app-owned окружение/worker; его изменение является отдельной установкой.

Установка failure не является Python call failure: причина отражается в `PythonProblem.reason` (`digest`, `target`, `python-abi`, `no-compatible-wheel-tag`, `probe`, `publication-conflict`). Загрузка/вызов передают реальную структурированную ошибку. Все recoverable границы имеют объявленный `PythonBridgeFailure`.

## External wire contract

Wire передаёт обычные ограниченные DATA и opaque `(sessionId,generation,objectId,lease)`; адреса не пересылаются. Header содержит protocol `1`, sequence и hash принятых bytes. `PythonExternalTurn` проверяет generation, последовательность и повтор уже завершённого запроса. Повтор с другим payload даёт conflict. Пропавший результат не делает side effect безопасным для повторного выполнения.

В начальном worker-профиле есть import/getattr/call/getitem/setitem/setattr/retain/release/toValue/fromValue. Open/close обслуживаются lifecycle channel, install — локальным installer выбранного владельца. Shared buffers и callbacks в handshake равны нулю. Живой proxy, coroutine и generator не превращаются в завершённое значение: их тип/lifetime сохраняется; отдельный await/stream API потребует будущего расширения capabilities.

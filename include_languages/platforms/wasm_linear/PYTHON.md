# WASM linear: private Pyodide

**Выбор: Pyodide, то есть CPython для Emscripten/JavaScript host.** Он выбран ради доступности готовых scientific packages и обычных pure-Python wheels. Это app-owned runtime assets в browser/Node host, не Python в произвольном WASI module. [Deployment](https://pyodide.org/en/stable/usage/downloading-and-deploying.html).

При первом использовании host устанавливает согласованный immutable набор `.wasm`/JS/stdlib/package-lock в собственный cache/storage приложения; exact Pyodide release и hashes фиксируются. Persistence зависит от host filesystem/browser storage и учитывает возможную eviction; ни ОС, ни системный Python не меняются.

`pyodide.loadPackage` используется для packages данного Pyodide release; `micropip` — для совместимых wheels. Native extensions требуют соответствующего Pyodide/Emscripten ABI, desktop `.so/.pyd` не подходят. Не обещается сборка произвольного `sdist` в браузере. [Loading packages](https://pyodide.org/en/stable/usage/loading-packages.html).

`py.*` проходит через JS host bridge и реальные PyProxy operations. Каждый owned PyProxy освобождается, включая failure paths; значения между LMX linear memory и Python memory не становятся zero-copy от совпадения offset. [Type translations](https://pyodide.org/en/stable/usage/type-conversions.html).

В текущем documented Pyodide профиле нельзя обещать обычные `fork`, Python threads, `multiprocessing` и `subprocess`. Browser networking идёт через host APIs и его ограничения; длинные вызовы переносятся в worker. Возможность импортировать module не доказывает работоспособность его background execution. [Pyodide FAQ](https://pyodide.org/en/stable/usage/faq.html).

**Альтернатива:** host соединяется с уже установленным Python service через explicit external endpoint. Browser сам не может запускать системный executable или читать его site-packages. Node/native host может запустить выбранный worker и передать тот же протокол. Требуемые origins/permissions и транспорт задаются host, не обходятся WASM.

Для **WASI-only** без JS host selected private Pyodide недоступен; используются host Python bridge либо честный `unsupported`. Это не скрытая вторая выбранная реализация Python. [platform_selection.lmx](../../examples/platform_selection.lmx) различает эти условия. Pyodide provider и browser end-to-end run: `REQUIRE_IMPLEMENTATION`/`NOT_RUN`.

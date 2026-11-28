# Section 2 — WASM linear, цель L1, L1/L2 #1

**Цель L1 с линейной памятью. Production build: NOT_RUN.** Python описан отдельно в [PYTHON.md](PYTHON.md).

Нормативные источники — [W3C WebAssembly Core](https://www.w3.org/TR/wasm-core-2/) и [binary format](https://webassembly.github.io/spec/core/binary/index.html). Runtime module получает явные imports, linear memory и C-compatible lowering. Это не новая LMX VM с собственным объектным графом.

Начальный профиль — wasm32 linear memory. LMX pointers внутри module представлены offsets его собственной памяти; host pointers и offsets другого module нельзя смешивать. Memory64, SIMD и shared memory/threads — отдельные negotiated build features, а не обязательные требования к каждому wasm32 host.

C99 compilation требует соответствующего libc/host-service слоя. **WASM core не предоставляет filesystem, network, process launch или Python.** Emscripten/JS host и WASI — разные ABI/environment profiles. Backend должен фиксировать свой вариант, imports и error behavior. Подстановка WASI module в Pyodide/Emscripten не является совместимым linking.

Array volume, span и offset arithmetic проверяются до вычисления адреса; linear-memory bounds trap не заменяет LMX error contract. После `memory.grow` host views обновляются по договору своего runtime; LMX/Python buffer lease не удерживает устаревший JS view. Данные между независимыми memories копируются либо передаются через действительно общий admitted memory region.

Начальная Message lane кооперативна внутри worker/event loop. Browser main loop нельзя блокировать ожиданием самого себя. Threads/shared memory добавляются только с поддержкой host, соответствующей сборкой и проверенной синхронизацией; C99-ядро не получает обязательного SharedArrayBuffer.

Приёмка: wasm validation/instantiate, imports без скрытой ОС, source/graph round-trip, bounds/overflow, grow/lifetime, Message ordering, browser worker и отдельно выбранный server host. Наличие корректного `.wasm` файла не подтверждает Pyodide integration.

# Платформы LMX и единственная языковая интеграция Python

**Редакция 28 ноября 2026. Статус кода: DRAFT.** Здесь заданы целевые платформы, переносимые договоры ядра и конкретные LMX-заготовки Python-границы. Успешная сборка всех перечисленных целей этим документом не заявляется.

Подключаемый язык — **Python через `py.*`**. `c.*` сохраняется как собственная машинная/ABI-граница L2. MIR, WebAssembly и RISC-V — цели L1, а не дополнительные подключаемые языки и не операционные системы.

Эта страница задаёт действующие целевые профили. Прежние материалы в `jvm/`, `vm/` и верхнеуровневых исследованиях оставлены для существующих ссылок и воспроизведения прошлых опытов. Они не расширяют список подключаемых языков. [Очередь реализации](../next_core_tasks_v3.md#mix-python-message-after-kernel).

## По одной директории на платформу

В каждой директории `README.md` описывает платформу LMX, а отдельный `PYTHON.md` — выбранную реализацию Python, установку внутрь приложения и альтернативный доступ к уже установленному Python.

| Цель | Справка платформы | Отдельная справка Python | Основной private runtime |
| --- | --- | --- | --- |
| Windows | [README](platforms/windows/README.md) | [PYTHON](platforms/windows/PYTHON.md) | CPython, python-build-standalone |
| Linux, тестируем на Ubuntu | [README](platforms/linux_ubuntu/README.md) | [PYTHON](platforms/linux_ubuntu/PYTHON.md) | CPython, python-build-standalone |
| macOS | [README](platforms/macos/README.md) | [PYTHON](platforms/macos/PYTHON.md) | CPython, python-build-standalone |
| Android NDK | [README](platforms/android_ndk/README.md) | [PYTHON](platforms/android_ndk/PYTHON.md) | CPython Android embeddable, python.org |
| section 1: MIR, L1, L1/L2 #2 | [README](platforms/mir/README.md) | [PYTHON](platforms/mir/PYTHON.md) | CPython выбранного native host |
| section 2: WASM linear, L1, L1/L2 #1 | [README](platforms/wasm_linear/README.md) | [PYTHON](platforms/wasm_linear/PYTHON.md) | Pyodide, CPython/Emscripten |
| section 3: RISC-V ISA, L1, L1/L2 #5 | [README](platforms/riscv/README.md) | [PYTHON](platforms/riscv/PYTHON.md) | CPython, python-build-standalone для RV64 Linux |
| Остальные C99-совместимые платформы | [README](platforms/c99_other/README.md) | [PYTHON](platforms/c99_other/PYTHON.md) | CPython конкретного hosted ABI при наличии порта |

Номер section сохранён только для трёх перечисленных L1 targets. Он не создаёт новую нумерацию уровней LMX. Связка «ISA + ABI + libc + ОС/host services» фиксируется явно; одной надписи «C99» для запуска CPython недостаточно.

## Что читать и подключать

1. [Архитектура Python-границы](python/ARCHITECTURE.md): владелец, Message, GIL, handles, callbacks и ошибки.
2. [API `py.*`](python/API.md): точные имена ворот, аргументы, результаты и общий binding.
3. [Установка и обновление](python/DEPLOYMENT.md): app-private поколения, wheels, rollback и system mode.
4. [Договор native providers](python/NATIVE_PORTS.md): конкретные CPython/Pyodide API, обязательная оставшаяся интеграция.
5. [Примеры](examples/README.md) и [проверки](validation/README.md).
6. [Первичные источники](SOURCES.md), проверенные 28 ноября 2026.

Порядок сборки единого LMX-графа: `src/models.lmx`, `src/ports.lmx`, `src/profiles.lmx`, `src/install.lmx`, `src/handles.lmx`, `src/calls.lmx`, `src/conversions.lmx`, `src/gates.lmx`, `src/external.lmx`, `src/gate_bindings.lmx`; затем нужный пример. Имена верхнего уровня объединяются обычной подготовкой проекта, а не текстовой подстановкой файлов.

`PythonGate\...\run` — действительные LMX-тела по текущим примерам. Нормативные формы `py.*` выбирают эти CODE references через общий механизм подготовки вызова. Binding в production frontend и native providers пока имеют статус `REQUIRE_IMPLEMENTATION`; `ports.lmx` не содержит фиктивных успешных реализаций.

Алгоритмы установки, допуска ABI, упаковки аргументов, владения handles и защиты от повторного исполнения запроса написаны на LMX. Узкие границы загрузчика, Python C API, сети и файловой системы оформлены явными contracts. C-проба в `validation/` проверяет только реальные свойства host CPython, а не исполнение LMX.

Перенос `com.mtk.map` находится в документации: [LMX DRAFT](../docs/com.mtk.map/). JVM-исполнение map не является частью платформенной архитектуры LMX.

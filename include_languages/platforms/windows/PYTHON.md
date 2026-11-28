# Windows: Python внутри приложения

**Выбор: CPython GIL-enabled из python-build-standalone, shared DLL.** Этот runtime поддерживает обычный CPython package ecosystem и app-private установку. Version/architecture/release фиксируются в `PythonInstallPlan`; «последний Python» не используется как плавающая зависимость. Указанный проект поставляет pip, но на Windows не обещает отдельный `pip.exe`; package installation не должна зависеть от него. [Distributions](https://docs.astral.sh/python-build-standalone/distributions/), [quirks](https://docs.astral.sh/python-build-standalone/quirks/).

Runtime распаковывается в доступный приложению каталог поколений. Если установленный `.exe` лежит в read-only `Program Files`, runtime может находиться в app-owned пользовательском data-каталоге; это по-прежнему private install. Никаких записей Python в registry, ассоциаций файлов и глобального `PATH`.

Выбрать matching-architecture `pythonXY.dll`, stdlib и native wheel dependencies. Полный PyConfig adapter собирается под выбранный CPython ABI; `python3.dll` и Limited API не объявляются достаточными для произвольного PyConfig layout. На границе MinGW/MSVC не передавать `FILE*`, allocator ownership и CRT-private objects; освобождение выполняет тот же runtime, который выделил память. Вызов Python идёт через [общие LMX gates](../../src/gates.lmx).

**Альтернатива:** явный путь к уже установленному `python.exe`; отдельный worker использует его packages и сообщает version/ABI/возможности в handshake. Не загружать его DLL в процесс с другим Python. Global site-packages не изменяются. Если нужны дополнительные библиотеки, создать app-owned environment для нового worker.

Пример сценария: [private_runtime.lmx](../../examples/private_runtime.lmx), [system_python.lmx](../../examples/system_python.lmx). Проверить native wheels, path relocation, отказ неверной архитектуры и отсутствие global changes. Статус Windows provider: `REQUIRE_IMPLEMENTATION`.

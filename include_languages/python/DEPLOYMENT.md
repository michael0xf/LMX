# Установка Python внутрь приложения

**DRAFT 2026-11-28.** Установка означает app-owned runtime и packages. Она не изменяет системный `PATH`, registry, shell profile, default Python, настройки ОС или global site-packages.

## Основной путь

Для Windows/Linux/macOS/RV64 Linux выбран CPython из python-build-standalone, GIL-enabled shared-runtime профиль. Поставка проекта фиксирует конкретный release, target triple, ABI и SHA-256. Наличие нужного `libpython` и dynamic extension loader проверяется по реальному artifact, а не предполагается из имени. Full archive содержит `PYTHON.json` и build metadata; install-only его не содержит, поэтому для него проект поставляет собственный проверенный descriptor. См. [формат distribution](https://docs.astral.sh/python-build-standalone/distributions/).

Релизный lock — обычная `PythonInstallPlan`: artifact URL/hash/size, CPython identity, app root, install ID, ожидаемое активное поколение, полная замкнутая последовательность wheels и smoke imports. Здесь не подставлены вымышленные release URLs, номера patch releases или контрольные суммы. До приёмки конкретного artifact его поля остаются обязательными входами, а не значениям «latest».

## Алгоритм на LMX

Реальное тело [PythonInstall\apply](../src/install.lmx):

1. Создаёт закрытый staging под app root.
2. Получает runtime artifact и проверяет digest/size.
3. Распаковывает с проверкой containment, duplicate/case collisions и ссылок.
4. Читает реальную identity и сравнивает implementation/version/ABI/target/libc/data model/GIL/API/extension loader.
5. Для каждого locked wheel проверяет пересечение tags с фактическими supported tags, получает и проверяет bytes, устанавливает в staging.
6. Проверяет предусмотренные import/load smoke cases.
7. Публикует готовое поколение атомарно, только если `expectedActiveId` ещё совпадает.
8. При любом отказе `finally` удаляет только собственный staging. Старое активное поколение остаётся рабочим.

Artifact и wheel metadata проверяются до исполнения их кода. Lock должен содержать все зависимости; native payload нельзя пропустить под видом pure wheel. Источники (`sdist`) не собираются скрытно на устройстве: для них нужен отдельный явный build pipeline. Проверка wheel filename tags сама по себе не проверяет системные DLL/so, ISA, минимальную ОС или код package — они входят в native admission/probe.

Для Pyodide тот же plan соответствует согласованной поставке runtime assets, Pyodide lock и совместимых wheels. `pyodide.loadPackage` загружает packages данного набора, `micropip` — поддерживаемые wheels; произвольный manylinux `.so` не становится WASM-модулем. [Официальная загрузка packages](https://pyodide.org/en/stable/usage/loading-packages.html).

Android использует собственный delivery profile: базово runtime/ELF поставляются с приложением, stdlib/packages извлекаются при первом использовании. Для установки native code из сети нужен явно допущенный канал доставки; подробные ограничения приведены в [Android/PYTHON](../platforms/android_ndk/PYTHON.md).

## Runtime generations

Путь поколения определяется identity и lock, не пользовательским module name. Новая установка создаёт новый каталог. Пока session удерживает runtime lease, этот каталог и его native libraries не удаляются. Успешное изменение active marker влияет только на следующие `openPython`.

Повторная загрузка CPython и многократные `Py_Initialize`/`Py_Finalize` внутри процесса не используются как механизм обновления. Native service удерживает библиотеку до своего согласованного shutdown; новый incompatible runtime запускается в новом worker/process или после перезапуска владельца.

## Альтернатива: установленный Python

Приложение получает явный путь к Python executable либо явно выбранный endpoint. Диагностическое discovery может показать кандидатов, но не выбирает случайный `python` из `PATH` при каждом вызове. Native desktop/RV64 worker запускается без shell с отдельным argv и app-owned bootstrap; тот загружает фиксированный bridge module, содержащий LMX worker policy. User command/имя функции никогда не интерполируются в Python source string.

Bootstrap и native bridge module являются обязательной integration work в [NATIVE_PORTS](NATIVE_PORTS.md). Их наличие не симулируется LMX-кодом. Worker использует Python среды, от которой его запустили; handshake сообщает actual implementation/version/ABI/capabilities. Не надо загружать несовместимый системный `libpython` в уже работающий процесс LMX.

Android связывается с Python, предоставившим отдельный service/endpoint; каталог другого приложения и executable Termux не считаются доступными автоматически. Browser связывается через разрешённый host transport с уже работающим Python service; прямого доступа к системному Python у WebAssembly нет.

Транспорт может работать с LMX DATA, если worker включает общий LMX codec; `fromLmx` получает только допустимую request schema, не произвольный исполняемый граф. Реальные limits, framing, authentication endpoint и backpressure задаёт host port. Выходные Python handles остаются у worker; restart меняет generation и инвалидирует их.

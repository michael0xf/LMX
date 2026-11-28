# Прочие C99 hosts: выбран CPython при наличии hosted port

**Единственная выбранная реализация — CPython**, в app-private сборке конкретного target. Если для host есть совместимый python-build-standalone artifact, используется он; иначе проект собирает CPython и фиксирует ABI/dependency descriptor. Это один interpreter с разными distribution artifacts, а не расширение списка подключаемых языков.

Сам факт C99 compilation LMX недостаточен: CPython и выбранным packages нужны соответствующий port, libc/OS services, allocator, loader либо static extension build, threads/lifecycle и доступное storage. Список возможностей проверяется до `py.open`. Отсутствующая возможность даёт конкретный unavailable status.

Установка идёт в supplied app-owned directory; настройки ОС не меняются. Static CPython допускается лишь как отдельно принятый профиль с заранее встроенными extensions и без обещания загрузить любую native wheel. Shared runtime предпочтителен там, где нужен обычный CPython package ecosystem.

**Альтернатива:** подключение к уже работающему Python на этом или доступном host через тот же external protocol. Transport provider должен действительно существовать; отсутствие network/process services не компенсируется декларацией порта.

На freestanding без CPython host services ядро LMX остаётся доступным, а private Python — unsupported. Нельзя предлагать MicroPython как незаметную замену CPython для произвольных scientific libraries.

[Общая архитектура](../../python/ARCHITECTURE.md), [installer](../../src/install.lmx), [profile selection](../../examples/platform_selection.lmx). Приёмка проводится по каждому target отдельно; в этой работе она не выполнялась.

CPython собирается по собственным требованиям его выбранного release/toolchain. Они не повышают C99-минимум переносимого ядра LMX: Python adapter является отдельно допускаемой зависимостью hosted профиля.

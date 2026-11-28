# RISC-V: Python для hosted RV64 Linux

**Выбор: CPython GIL-enabled shared build python-build-standalone для `riscv64-unknown-linux-gnu`.** Официальная документация этого проекта указывает для такого target минимум glibc 2.28. Наличие точного нужного release artifact всё равно проверяется в lock; выбранные ISA/psABI должны соответствовать устройству. [Running distributions](https://docs.astral.sh/python-build-standalone/running/), [первичный running.rst](https://github.com/astral-sh/python-build-standalone/blob/main/docs/running.rst).

Это обычная private установка в app-owned runtime generation с теми же LMX gates, что на Linux. Никакой системный Python, package manager или PATH не меняются. Готовность библиотеки определяется наличием compatible pure/native wheel; desktop x86-64/ARM wheels на RISC-V не подходят. При отсутствии wheel проект делает явный target build и сохраняет его точный artifact, не скрытый runtime cross-compile.

Если exact PBS artifact недоступен, результат — `artifact-unavailable/build-required`; возможна проектная сборка **того же CPython** под тот же ABI. Она проходит такую же admission и не объявляется эквивалентной без receipts.

**Альтернатива:** явный уже установленный Python на RV64 Linux в отдельном worker. Он предоставляет имеющиеся native packages через handles/копируемые значения; LMX не загружает его произвольный libpython в процесс.

Для RV32, bare-metal или другого RISC-V OS нет автоматической private CPython гарантии. Требуется отдельный CPython port с нужными host services либо bridge к Python на доступном host. «RISC-V ISA поддержана» и «CPython с scientific packages доступен» — различные проверяемые факты.

Ссылки: [profile DATA](../../src/profiles.lmx), [private scenario](../../examples/private_runtime.lmx), [system scenario](../../examples/system_python.lmx). RV64 binary download/install, native wheels и end-to-end LMX execution в этой работе не выполнялись.

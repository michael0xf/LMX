# Linux/Ubuntu: app-private Python

**Выбор: CPython GIL-enabled shared build из python-build-standalone.** Для обычной Ubuntu используется matching `*-unknown-linux-gnu`. Фактические minimum glibc, ISA и extensions loader читаются из artifact/descriptor и проверяются; portable не означает статически независимый от всех системных библиотек. [Running distributions](https://docs.astral.sh/python-build-standalone/running/).

Runtime устанавливается в app-owned runtime root, packages — в отдельное immutable поколение site. Не используются `sudo`, системный package manager, user-site Python или изменение shell profile. Изолированный `PyConfig` получает только явные app paths. LD_LIBRARY_PATH всей ОС не меняется.

Для максимальной доступности native wheels выбран динамический shared профиль. Полностью static musl CPython не является равноценной заменой: он ограничивает загрузку dynamic extension modules. Совместимость `manylinux`, `musllinux`, host libc и bundled dependencies проверяется по реальному target. Для missing wheel нужен явный build pipeline, а не незаметная попытка сборки `sdist` при импорте.

**Альтернатива:** пользователь/host указывает существующий Python executable; запускается отдельный worker, сохраняя его package environment. Handshake отличает distribution Python, virtualenv и иной interpreter. Для несовместимого ABI app использует копируемые значения/handles worker, не загружает системный libpython в свой процесс.

[Installer LMX](../../src/install.lmx), [private example](../../examples/private_runtime.lmx), [system example](../../examples/system_python.lmx). Приёмка: import stdlib и locked native wheel, relocation, Unicode path, missing-so diagnostic, generation rollback, worker restart. Полный Linux Python provider в этом выпуске не реализован; отдельная host CAPI-проба не заменяет его.

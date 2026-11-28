# Linux: платформа LMX, тестовая ОС Ubuntu

**Целевая платформа. Полная сборка этого выпуска: NOT_RUN.** Python: [PYTHON.md](PYTHON.md).

Общая C99-ветвь ядра собирается GCC/Clang. Для native acceptance используются Ubuntu и явно записанные compiler, libc, ISA, bitness и minimum runtime versions. Проверка на Ubuntu не означает бинарную совместимость со всеми Linux distributions.

POSIX API, `dlopen`, threads, monotonic clock и executable memory принадлежат Linux host adapter. Ядро не требует glibc-specific API там, где достаточно C99/общего host contract. musl — другой libc-профиль; он не подменяется файлом glibc runtime. Для bare/embedded Linux отдельно определяется доступный loader, filesystem и process lifecycle.

Форматы графа/Message не зависят от ELF virtual addresses. Typed loads/stores, size arithmetic, alignment и byte order проверяются общим code path. Никакой обязательной машинной генерации кода нет у программы, которая исполняется допустимым interpreter-профилем.

Приёмка Linux: native C99 build и реальный runtime smoke на Ubuntu; невалидный вход/Array boundaries; Message stress с одним writer на arena; loader dependencies; read-only install root с app-data store; отсутствие утечки file descriptors и handles. Для библиотек обязательно проверять реальную `DT_NEEDED` цепочку и собственные ABI.

Внешний CPython — optional provider; отсутствие Python не мешает собирать или запускать ядро LMX. Поддержка [RISC-V](../riscv/README.md) и [MIR](../mir/README.md) имеет свои дополнительные условия.

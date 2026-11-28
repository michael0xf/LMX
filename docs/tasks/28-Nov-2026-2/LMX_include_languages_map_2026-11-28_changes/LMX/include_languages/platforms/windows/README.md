# Windows: платформа LMX

**Целевая платформа. Сборка этого выпуска: NOT_RUN.** Python описан отдельно в [PYTHON.md](PYTHON.md).

Базовый профиль — native Windows C ABI, сначала x86-64; ARM64 и 32-bit требуют своих toolchain/ABI receipts. C99-ядро собирается C-компилятором с полным необходимым subset, например Clang; использование Windows SDK/MSVC ABI не означает, что код можно ограничить историческим C-subset конкретного MSVC. MinGW — отдельный toolchain-профиль с проверяемой CRT-границей.

В ядре не фиксировать `sizeof(long)=sizeof(void*)`: Windows x64 использует LLP64. Размеры Array, индексы, pointer transport и форматы файла не выводить из `long`. Для serialized графа фиксировать representation, а native pointer/thread/handle остаётся локальным ресурсом. Filesystem paths проходят Unicode-aware Windows adapter.

Службы ОС находятся за общими host contracts: файл, время, native threads/wait, Message admission, загрузка DLL, executable memory. Ядро не включает POSIX headers без выбранного adapter. Нативная синхронизация не переносится как `volatile`-поля. Доступ L3 к memory/Array остаётся общими проверяемыми операциями.

DLL загружать по выбранному абсолютному пути с контролируемым поиском dependencies. `LoadLibraryEx`/`AddDllDirectory` изменяют loader context данного процесса; изменение системного `PATH` и registry не требуется. Зависимая DLL не обязана искаться в каталоге первого полного пути автоматически. [Microsoft: DLL search order](https://learn.microsoft.com/en-us/windows/win32/dlls/dynamic-link-library-search-order).

Приёмка: C99 build без POSIX leakage; корректные LLP64 размеры/выравнивания; пути с Unicode/пробелами; relocation каталога приложения; строгие boundary/error tests; native DLL загрузка; owner/thread shutdown. Режим MIR проверяется отдельно и не является заменой Windows ABI.

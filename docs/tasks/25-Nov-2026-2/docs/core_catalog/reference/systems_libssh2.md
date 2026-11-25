# systems:libssh2

[Первичный LMX-каталог](../catalog/systems_libssh2.lmx) · [Тела LMX](../bindings/systems_libssh2.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `libssh2-1.11.1`.
Записей: **219**; кандидатов вызова: **138**; scalar prototypes: **2**.

Пакеты: `net\ssh`.
CMake: `LMX::libssh2`.

| Категория | Записи |
|---|---:|
| callback | 3 |
| function | 138 |
| function_macro | 78 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# base:sqlite3

[Первичный LMX-каталог](../catalog/base_sqlite3.lmx) · [Тела LMX](../bindings/base_sqlite3.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `3.54.1`.
Записей: **476**; кандидатов вызова: **367**; scalar prototypes: **14**.

Пакеты: `db\sql`.
CMake: `LMX::sqlite3`.

| Категория | Записи |
|---|---:|
| callback | 107 |
| function | 367 |
| function_macro | 2 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

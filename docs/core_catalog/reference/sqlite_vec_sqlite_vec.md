# sqlite_vec:sqlite_vec

[Первичный LMX-каталог](../catalog/sqlite_vec_sqlite_vec.lmx) · [Тела LMX](../bindings/sqlite_vec_sqlite_vec.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v0.1.9`.
Записей: **28**; кандидатов вызова: **3**; scalar prototypes: **0**.

Пакеты: `db\sql\vector`.
CMake: `LMX::sqlite_vec`.

| Категория | Записи |
|---|---:|
| function | 3 |
| sql_api | 25 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

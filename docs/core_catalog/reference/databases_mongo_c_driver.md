# databases:mongo_c_driver

[Первичный LMX-каталог](../catalog/databases_mongo_c_driver.lmx) · [Тела LMX](../bindings/databases_mongo_c_driver.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.5.9`.
Записей: **2410**; кандидатов вызова: **1258**; scalar prototypes: **2**.

Пакеты: `db\document`, `document\bson`.
CMake: `LMX::bson`, `LMX::mongoc`.

| Категория | Записи |
|---|---:|
| alias | 1 |
| callback | 38 |
| function | 1991 |
| function_macro | 247 |
| static_inline | 123 |
| template | 10 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

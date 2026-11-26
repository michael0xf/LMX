# storage_extra:flashdb

[Первичный LMX-каталог](../catalog/storage_extra_flashdb.lmx) · [Тела LMX](../bindings/storage_extra_flashdb.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.2.99 header version at pinned snapshot`.
Записей: **44**; кандидатов вызова: **32**; scalar prototypes: **0**.

Пакеты: `db\flash`.
CMake: `LMX::flashdb`.

| Категория | Записи |
|---|---:|
| callback | 5 |
| function | 31 |
| function_macro | 7 |
| static_inline | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

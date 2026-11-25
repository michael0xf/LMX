# kann:kann

[Первичный LMX-каталог](../catalog/kann_kann.lmx) · [Тела LMX](../bindings/kann_kann.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `r557 (Kautodiff r556); pinned snapshot 2025-06-06`.
Записей: **138**; кандидатов вызова: **120**; scalar prototypes: **1**.

Пакеты: `ml`.
CMake: `LMX::kann`.

| Категория | Записи |
|---|---:|
| callback | 1 |
| function | 119 |
| function_macro | 17 |
| static_header_function | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# databases:hiredis

[Первичный LMX-каталог](../catalog/databases_hiredis.lmx) · [Тела LMX](../bindings/databases_hiredis.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v1.5.1`.
Записей: **488**; кандидатов вызова: **288**; scalar prototypes: **3**.

Пакеты: `db\redis`.
CMake: `LMX::hiredis`.

| Категория | Записи |
|---|---:|
| alias | 4 |
| callback | 29 |
| function | 164 |
| function_macro | 54 |
| static_header_function | 110 |
| static_inline | 124 |
| template | 3 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# systems:lz4

[Первичный LMX-каталог](../catalog/systems_lz4.lmx) · [Тела LMX](../bindings/systems_lz4.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v1.11.1`.
Записей: **133**; кандидатов вызова: **113**; scalar prototypes: **9**.

Пакеты: `archive`.
CMake: `LMX::lz4`.

| Категория | Записи |
|---|---:|
| callback | 4 |
| function | 113 |
| function_macro | 15 |
| template | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

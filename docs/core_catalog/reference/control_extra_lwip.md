# control_extra:lwip

[Первичный LMX-каталог](../catalog/control_extra_lwip.lmx) · [Тела LMX](../bindings/control_extra_lwip.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.2.2 development snapshot (header 2.2.2, exact commit below)`.
Записей: **1256**; кандидатов вызова: **505**; scalar prototypes: **24**.

Пакеты: `net`.
CMake: `LMX::lwip`.

| Категория | Записи |
|---|---:|
| alias | 20 |
| callback | 35 |
| function | 505 |
| function_macro | 692 |
| template | 4 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# tensors:mint

[Первичный LMX-каталог](../catalog/tensors_mint.lmx) · [Тела LMX](../bindings/tensors_mint.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `pinned upstream snapshot 2025-07-19`.
Записей: **116**; кандидатов вызова: **51**; scalar prototypes: **0**.

Пакеты: `tensor`.
CMake: `LMX::mint`.

| Категория | Записи |
|---|---:|
| callback | 2 |
| function | 40 |
| function_macro | 17 |
| static_header_function | 7 |
| static_inline | 50 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

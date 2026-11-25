# media:jo_mp1

[Первичный LMX-каталог](../catalog/media_jo_mp1.lmx) · [Тела LMX](../bindings/media_jo_mp1.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.00 (upstream date 2014-26-1)`.
Записей: **2**; кандидатов вызова: **1**; scalar prototypes: **0**.

Пакеты: `audio`.
CMake: `LMX::jo_mp1`.

| Категория | Записи |
|---|---:|
| function | 1 |
| static_header_function | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

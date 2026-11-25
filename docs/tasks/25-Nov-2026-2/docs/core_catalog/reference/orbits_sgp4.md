# orbits:sgp4

[Первичный LMX-каталог](../catalog/orbits_sgp4.lmx) · [Тела LMX](../bindings/orbits_sgp4.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `pinned upstream snapshot 2025-10-03`.
Записей: **14**; кандидатов вызова: **14**; scalar prototypes: **1**.

Пакеты: `orbit`.
CMake: `LMX::sgp4`.

| Категория | Записи |
|---|---:|
| function | 14 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

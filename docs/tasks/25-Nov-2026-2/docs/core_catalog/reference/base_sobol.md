# base:sobol

[Первичный LMX-каталог](../catalog/base_sobol.lmx) · [Тела LMX](../bindings/base_sobol.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `upstream-snapshot-2026-11-25`.
Записей: **18**; кандидатов вызова: **18**; scalar prototypes: **5**.

Пакеты: `random`.
CMake: `LMX::sobol`.

| Категория | Записи |
|---|---:|
| function | 18 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

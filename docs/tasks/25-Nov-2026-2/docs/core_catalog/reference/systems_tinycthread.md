# systems:tinycthread

[Первичный LMX-каталог](../catalog/systems_tinycthread.lmx) · [Тела LMX](../bindings/systems_tinycthread.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v1.1`.
Записей: **28**; кандидатов вызова: **24**; scalar prototypes: **2**.

Пакеты: `os\thread`.
CMake: `LMX::tinycthread`.

| Категория | Записи |
|---|---:|
| alias | 1 |
| callback | 2 |
| function | 25 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

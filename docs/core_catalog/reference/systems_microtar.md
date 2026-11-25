# systems:microtar

[Первичный LMX-каталог](../catalog/systems_microtar.lmx) · [Тела LMX](../bindings/systems_microtar.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v0.1.0`.
Записей: **18**; кандидатов вызова: **14**; scalar prototypes: **0**.

Пакеты: `archive`.
CMake: `LMX::microtar`.

| Категория | Записи |
|---|---:|
| callback | 4 |
| function | 14 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

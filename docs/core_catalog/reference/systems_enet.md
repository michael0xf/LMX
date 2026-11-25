# systems:enet

[Первичный LMX-каталог](../catalog/systems_enet.lmx) · [Тела LMX](../bindings/systems_enet.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v1.3.18`.
Записей: **105**; кандидатов вызова: **75**; scalar prototypes: **2**.

Пакеты: `net`.
CMake: `LMX::enet`.

| Категория | Записи |
|---|---:|
| callback | 3 |
| function | 75 |
| function_macro | 27 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

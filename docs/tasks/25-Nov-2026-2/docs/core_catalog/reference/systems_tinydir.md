# systems:tinydir

[Первичный LMX-каталог](../catalog/systems_tinydir.lmx) · [Тела LMX](../bindings/systems_tinydir.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.2.6`.
Записей: **14**; кандидатов вызова: **8**; scalar prototypes: **0**.

Пакеты: `os\path`.
CMake: `LMX::tinydir`.

| Категория | Записи |
|---|---:|
| function | 3 |
| function_macro | 3 |
| static_header_function | 8 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

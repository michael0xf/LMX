# systems:miniz

[Первичный LMX-каталог](../catalog/systems_miniz.lmx) · [Тела LMX](../bindings/systems_miniz.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `3.1.2`.
Записей: **165**; кандидатов вызова: **134**; scalar prototypes: **0**.

Пакеты: `archive`.
CMake: `LMX::miniz`.

| Категория | Записи |
|---|---:|
| alias | 1 |
| callback | 10 |
| function | 121 |
| function_macro | 14 |
| static_header_function | 19 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

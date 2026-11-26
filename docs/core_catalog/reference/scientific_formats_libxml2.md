# scientific_formats:libxml2

[Первичный LMX-каталог](../catalog/scientific_formats_libxml2.lmx) · [Тела LMX](../bindings/scientific_formats_libxml2.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.15.4`.
Записей: **1574**; кандидатов вызова: **1380**; scalar prototypes: **72**.

Пакеты: `document\html`, `document\schema`, `document\xml`, `document\xpath`.
CMake: `LMX::libxml2`.

| Категория | Записи |
|---|---:|
| alias | 9 |
| callback | 90 |
| function | 1406 |
| function_macro | 69 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

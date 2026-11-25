# base:stc

[Первичный LMX-каталог](../catalog/base_stc.lmx) · [Тела LMX](../bindings/base_stc.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `5.0`.
Записей: **561**; кандидатов вызова: **140**; scalar prototypes: **2**.

Пакеты: `seq`.
CMake: `LMX::stc`.

| Категория | Записи |
|---|---:|
| alias | 6 |
| callback | 4 |
| function | 49 |
| function_macro | 234 |
| static_header_function | 3 |
| static_inline | 225 |
| template | 40 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# base:curl

[Первичный LMX-каталог](../catalog/base_curl.lmx) · [Тела LMX](../bindings/base_curl.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `8.23.0`.
Записей: **318**; кандидатов вызова: **156**; scalar prototypes: **1**.

Пакеты: `net`.
CMake: `LMX::curl`.

| Категория | Записи |
|---|---:|
| callback | 85 |
| function | 104 |
| function_macro | 77 |
| static_inline | 52 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

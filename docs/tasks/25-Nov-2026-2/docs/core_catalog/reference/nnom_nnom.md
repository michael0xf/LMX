# nnom:nnom

[Первичный LMX-каталог](../catalog/nnom_nnom.lmx) · [Тела LMX](../bindings/nnom_nnom.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.4.3 API, pinned post-release snapshot 2024-04-08`.
Записей: **267**; кандидатов вызова: **244**; scalar prototypes: **1**.

Пакеты: `ml`.
CMake: `LMX::nnom`.

| Категория | Записи |
|---|---:|
| callback | 15 |
| function | 245 |
| function_macro | 5 |
| static_inline | 2 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

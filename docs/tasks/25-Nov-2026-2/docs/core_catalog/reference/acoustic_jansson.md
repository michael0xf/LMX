# acoustic:jansson

[Первичный LMX-каталог](../catalog/acoustic_jansson.lmx) · [Тела LMX](../bindings/acoustic_jansson.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.15.1`.
Записей: **125**; кандидатов вызова: **98**; scalar prototypes: **2**.

Пакеты: `document\json`.
CMake: `LMX::jansson`.

| Категория | Записи |
|---|---:|
| callback | 5 |
| function | 83 |
| function_macro | 22 |
| static_inline | 15 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

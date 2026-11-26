# bundles_extra:gb

[Первичный LMX-каталог](../catalog/bundles_extra_gb.lmx) · [Тела LMX](../bindings/bundles_extra_gb.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `gb.h 0.33 + gb_ini.h 0.93`.
Записей: **585**; кандидатов вызова: **294**; scalar prototypes: **0**.

Пакеты: `document\config`, `fs`, `hash`, `os`, `os\memory`, `os\path`, `os\thread`, `os\time`, `random`, `seq`, `text`, `text\unicode`.
CMake: `LMX::gb`.

| Категория | Записи |
|---|---:|
| callback | 35 |
| function | 422 |
| function_macro | 102 |
| static_inline | 11 |
| template | 15 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

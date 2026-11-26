# platform_extra:apr

[Первичный LMX-каталог](../catalog/platform_extra_apr.lmx) · [Тела LMX](../bindings/platform_extra_apr.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.7.6`.
Записей: **756**; кандидатов вызова: **558**; scalar prototypes: **0**.

Пакеты: `document\binary`, `fs`, `net`, `net\event`, `os`, `os\memory`, `os\thread`, `os\time`, `random`, `seq`, `text`.
CMake: `LMX::apr`.

| Категория | Записи |
|---|---:|
| alias | 10 |
| callback | 15 |
| function | 559 |
| function_macro | 166 |
| template | 6 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

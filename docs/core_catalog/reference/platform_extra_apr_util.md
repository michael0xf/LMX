# platform_extra:apr_util

[Первичный LMX-каталог](../catalog/platform_extra_apr_util.lmx) · [Тела LMX](../bindings/platform_extra_apr_util.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.6.6`.
Записей: **405**; кандидатов вызова: **315**; scalar prototypes: **0**.

Пакеты: `crypto`, `db`, `db\redis`, `db\sql`, `document\binary`, `document\xml`, `hash`, `net`, `os`, `os\memory`, `os\thread`, `os\time`, `random`, `seq`, `text\search`, `text\unicode`.
CMake: `LMX::apr_util`.

| Категория | Записи |
|---|---:|
| callback | 16 |
| function | 315 |
| function_macro | 66 |
| template | 8 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

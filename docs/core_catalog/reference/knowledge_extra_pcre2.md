# knowledge_extra:pcre2

[Первичный LMX-каталог](../catalog/knowledge_extra_pcre2.lmx) · [Тела LMX](../bindings/knowledge_extra_pcre2.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `10.49`.
Записей: **255**; кандидатов вызова: **241**; scalar prototypes: **0**.

Пакеты: `text\regex`.
CMake: `LMX::pcre2`, `LMX::pcre2_posix`.

| Категория | Записи |
|---|---:|
| alias | 8 |
| callback | 3 |
| function | 241 |
| function_macro | 3 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

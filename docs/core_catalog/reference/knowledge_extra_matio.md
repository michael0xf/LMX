# knowledge_extra:matio

[Первичный LMX-каталог](../catalog/knowledge_extra_matio.lmx) · [Тела LMX](../bindings/knowledge_extra_matio.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.6.0`.
Записей: **67**; кандидатов вызова: **65**; scalar prototypes: **0**.

Пакеты: `document\matrix`.
CMake: `LMX::matio`.

| Категория | Записи |
|---|---:|
| callback | 1 |
| function | 65 |
| function_macro | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# base:sljit

[Первичный LMX-каталог](../catalog/base_sljit.lmx) · [Тела LMX](../bindings/base_sljit.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.95 header API; untagged snapshot`.
Записей: **135**; кандидатов вызова: **96**; scalar prototypes: **1**.

Пакеты: `code\jit`.
CMake: `LMX::sljit`.

| Категория | Записи |
|---|---:|
| function | 78 |
| function_macro | 39 |
| static_inline | 18 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

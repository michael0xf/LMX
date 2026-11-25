# numeric_extra:fp16

[Первичный LMX-каталог](../catalog/numeric_extra_fp16.lmx) · [Тела LMX](../bindings/numeric_extra_fp16.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `snapshot 782eea126dc5`.
Записей: **10**; кандидатов вызова: **10**; scalar prototypes: **0**.

Пакеты: `number\float`.
CMake: `LMX::fp16`.

| Категория | Записи |
|---|---:|
| function | 4 |
| static_inline | 6 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

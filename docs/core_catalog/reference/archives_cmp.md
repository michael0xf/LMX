# archives:cmp

[Первичный LMX-каталог](../catalog/archives_cmp.lmx) · [Тела LMX](../bindings/archives_cmp.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v20`.
Записей: **178**; кандидатов вызова: **170**; scalar prototypes: **0**.

Пакеты: `document\binary`.
CMake: `LMX::cmp`.

| Категория | Записи |
|---|---:|
| alias | 5 |
| callback | 3 |
| function | 170 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

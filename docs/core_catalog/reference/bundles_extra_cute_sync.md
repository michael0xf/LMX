# bundles_extra:cute_sync

[Первичный LMX-каталог](../catalog/bundles_extra_cute_sync.lmx) · [Тела LMX](../bindings/bundles_extra_cute_sync.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.02`.
Записей: **54**; кандидатов вызова: **42**; scalar prototypes: **0**.

Пакеты: `os\thread`.
CMake: `LMX::cute_sync`.

| Категория | Записи |
|---|---:|
| callback | 2 |
| function | 44 |
| function_macro | 4 |
| static_header_function | 4 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

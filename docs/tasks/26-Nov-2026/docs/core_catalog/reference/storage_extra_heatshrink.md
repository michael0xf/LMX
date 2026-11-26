# storage_extra:heatshrink

[Первичный LMX-каталог](../catalog/storage_extra_heatshrink.lmx) · [Тела LMX](../bindings/storage_extra_heatshrink.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.4.1`.
Записей: **18**; кандидатов вызова: **12**; scalar prototypes: **0**.

Пакеты: `archive`.
CMake: `LMX::heatshrink`.

| Категория | Записи |
|---|---:|
| function | 12 |
| function_macro | 6 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

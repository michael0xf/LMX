# storage_extra:littlefs

[Первичный LMX-каталог](../catalog/storage_extra_littlefs.lmx) · [Тела LMX](../bindings/storage_extra_littlefs.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.11 (LFS_VERSION 0x0002000b; disk 2.1)`.
Записей: **66**; кандидатов вызова: **49**; scalar prototypes: **0**.

Пакеты: `fs`.
CMake: `LMX::littlefs`.

| Категория | Записи |
|---|---:|
| callback | 6 |
| function | 35 |
| function_macro | 11 |
| static_inline | 14 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

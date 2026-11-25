# base:zlib

[Первичный LMX-каталог](../catalog/base_zlib.lmx) · [Тела LMX](../bindings/base_zlib.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.4`.
Записей: **120**; кандидатов вызова: **96**; scalar prototypes: **0**.

Пакеты: `archive`.
CMake: `LMX::zlib`.

| Категория | Записи |
|---|---:|
| alias | 7 |
| callback | 4 |
| function | 96 |
| function_macro | 13 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

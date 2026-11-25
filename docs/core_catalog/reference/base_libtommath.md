# base:libtommath

[Первичный LMX-каталог](../catalog/base_libtommath.lmx) · [Тела LMX](../bindings/base_libtommath.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.3.0`.
Записей: **197**; кандидатов вызова: **166**; scalar prototypes: **1**.

Пакеты: `number\bigint`.
CMake: `LMX::tommath`.

| Категория | Записи |
|---|---:|
| callback | 4 |
| function | 166 |
| function_macro | 27 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

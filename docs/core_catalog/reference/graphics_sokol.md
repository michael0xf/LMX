# graphics:sokol

[Первичный LMX-каталог](../catalog/graphics_sokol.lmx) · [Тела LMX](../bindings/graphics_sokol.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `09558a100857`.
Записей: **2287**; кандидатов вызова: **448**; scalar prototypes: **4**.

Пакеты: `image\gpu`.
CMake: `LMX::sokol`.

| Категория | Записи |
|---|---:|
| callback | 128 |
| function | 1689 |
| function_macro | 64 |
| static_header_function | 244 |
| static_inline | 126 |
| template | 36 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# base:tinyspline

[Первичный LMX-каталог](../catalog/base_tinyspline.lmx) · [Тела LMX](../bindings/base_tinyspline.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.6.0`.
Записей: **106**; кандидатов вызова: **89**; scalar prototypes: **0**.

Пакеты: `math\spline`.
CMake: `LMX::tinyspline`.

| Категория | Записи |
|---|---:|
| function | 89 |
| function_macro | 10 |
| template | 7 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

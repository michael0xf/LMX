# geospatial:h3

[Первичный LMX-каталог](../catalog/geospatial_h3.lmx) · [Тела LMX](../bindings/geospatial_h3.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `4.6.0`.
Записей: **84**; кандидатов вызова: **80**; scalar prototypes: **0**.

Пакеты: `geo`.
CMake: `LMX::h3`.

| Категория | Записи |
|---|---:|
| function | 80 |
| function_macro | 3 |
| template | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

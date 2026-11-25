# geospatial:minmea

[Первичный LMX-каталог](../catalog/geospatial_minmea.lmx) · [Тела LMX](../bindings/geospatial_minmea.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.0.0`.
Записей: **21**; кандидатов вызова: **21**; scalar prototypes: **0**.

Пакеты: `geo`.
CMake: `LMX::minmea`.

| Категория | Записи |
|---|---:|
| function | 17 |
| static_inline | 4 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

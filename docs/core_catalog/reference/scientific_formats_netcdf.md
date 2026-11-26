# scientific_formats:netcdf

[Первичный LMX-каталог](../catalog/scientific_formats_netcdf.lmx) · [Тела LMX](../bindings/scientific_formats_netcdf.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `4.10.1`.
Записей: **631**; кандидатов вызова: **514**; scalar prototypes: **0**.

Пакеты: `document\json`, `document\netcdf`, `seq`.
CMake: `LMX::netcdf`.

| Категория | Записи |
|---|---:|
| callback | 85 |
| function | 462 |
| function_macro | 31 |
| static_header_function | 53 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

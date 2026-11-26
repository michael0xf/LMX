# scientific_formats:hdf5

[Первичный LMX-каталог](../catalog/scientific_formats_hdf5.lmx) · [Тела LMX](../bindings/scientific_formats_hdf5.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.3.0`.
Записей: **1525**; кандидатов вызова: **1047**; scalar prototypes: **0**.

Пакеты: `document\hdf5`, `document\table`, `image\hdf5`.
CMake: `LMX::hdf5`, `LMX::hdf5_hl`, `LMX::scientific_hdf5`.

| Категория | Записи |
|---|---:|
| alias | 39 |
| callback | 122 |
| function | 1047 |
| function_macro | 317 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

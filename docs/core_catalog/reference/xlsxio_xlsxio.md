# xlsxio:xlsxio

[Первичный LMX-каталог](../catalog/xlsxio_xlsxio.lmx) · [Тела LMX](../bindings/xlsxio_xlsxio.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.2.37`.
Записей: **40**; кандидатов вызова: **35**; scalar prototypes: **0**.

Пакеты: `document\sheet`.
CMake: `LMX::xlsxio_read`, `LMX::xlsxio_write`.

| Категория | Записи |
|---|---:|
| callback | 3 |
| function | 35 |
| function_macro | 2 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

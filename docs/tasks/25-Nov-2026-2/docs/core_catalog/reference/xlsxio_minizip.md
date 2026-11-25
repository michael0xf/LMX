# xlsxio:minizip

[Первичный LMX-каталог](../catalog/xlsxio_minizip.lmx) · [Тела LMX](../bindings/xlsxio_minizip.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `classic MiniZip 1.1 Zip64 as shipped in zlib 1.4`.
Записей: **82**; кандидатов вызова: **60**; scalar prototypes: **0**.

Пакеты: `archive`.
CMake: `LMX::minizip`.

| Категория | Записи |
|---|---:|
| callback | 15 |
| function | 60 |
| function_macro | 7 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

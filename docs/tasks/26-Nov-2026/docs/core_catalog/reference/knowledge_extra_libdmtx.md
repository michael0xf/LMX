# knowledge_extra:libdmtx

[Первичный LMX-каталог](../catalog/knowledge_extra_libdmtx.lmx) · [Тела LMX](../bindings/knowledge_extra_libdmtx.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.7.9 snapshot`.
Записей: **82**; кандидатов вызова: **81**; scalar prototypes: **3**.

Пакеты: `image\barcode`.
CMake: `LMX::dmtx`.

| Категория | Записи |
|---|---:|
| function | 81 |
| function_macro | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

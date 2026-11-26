# storage_extra:qcbor

[Первичный LMX-каталог](../catalog/storage_extra_qcbor.lmx) · [Тела LMX](../bindings/storage_extra_qcbor.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.7.0 header/CMake version at pinned snapshot`.
Записей: **450**; кандидатов вызова: **437**; scalar prototypes: **0**.

Пакеты: `document\binary`.
CMake: `LMX::qcbor`.

| Категория | Записи |
|---|---:|
| alias | 1 |
| callback | 2 |
| function | 114 |
| function_macro | 7 |
| static_header_function | 264 |
| static_inline | 59 |
| template | 3 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

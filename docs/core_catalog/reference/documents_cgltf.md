# documents:cgltf

[Первичный LMX-каталог](../catalog/documents_cgltf.lmx) · [Тела LMX](../bindings/documents_cgltf.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v1.15`.
Записей: **206**; кандидатов вызова: **39**; scalar prototypes: **0**.

Пакеты: `image\scene`.
CMake: `LMX::cgltf`.

| Категория | Записи |
|---|---:|
| callback | 4 |
| function | 39 |
| function_macro | 20 |
| static_header_function | 143 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

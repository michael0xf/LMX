# systems:jsmn

[Первичный LMX-каталог](../catalog/systems_jsmn.lmx) · [Тела LMX](../bindings/systems_jsmn.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v1.1.0`.
Записей: **6**; кандидатов вызова: **2**; scalar prototypes: **0**.

Пакеты: `document\json`.
CMake: `LMX::jsmn`.

| Категория | Записи |
|---|---:|
| function | 2 |
| static_header_function | 4 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# documents:tomlc99

[Первичный LMX-каталог](../catalog/documents_tomlc99.lmx) · [Тела LMX](../bindings/documents_tomlc99.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `62ce93ceb713`.
Записей: **38**; кандидатов вызова: **38**; scalar prototypes: **0**.

Пакеты: `document\config`.
CMake: `LMX::tomlc99`.

| Категория | Записи |
|---|---:|
| function | 38 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

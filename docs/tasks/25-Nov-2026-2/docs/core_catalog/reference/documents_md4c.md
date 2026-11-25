# documents:md4c

[Первичный LMX-каталог](../catalog/documents_md4c.lmx) · [Тела LMX](../bindings/documents_md4c.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v0.6.0`.
Записей: **9**; кандидатов вызова: **2**; scalar prototypes: **0**.

Пакеты: `document\markup`.
CMake: `LMX::md4c`, `LMX::md4c_html`.

| Категория | Записи |
|---|---:|
| callback | 7 |
| function | 2 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

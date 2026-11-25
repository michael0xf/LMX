# systems:dyad

[Первичный LMX-каталог](../catalog/systems_dyad.lmx) · [Тела LMX](../bindings/systems_dyad.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `915ae4939529b9aaaf6ebfd2f65c6cff45fc0eac`.
Записей: **31**; кандидатов вызова: **29**; scalar prototypes: **7**.

Пакеты: `net`.
CMake: `LMX::dyad`.

| Категория | Записи |
|---|---:|
| callback | 2 |
| function | 29 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

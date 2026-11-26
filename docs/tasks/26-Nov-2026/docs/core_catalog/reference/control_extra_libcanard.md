# control_extra:libcanard

[Первичный LMX-каталог](../catalog/control_extra_libcanard.lmx) · [Тела LMX](../bindings/control_extra_libcanard.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `5.0.0`.
Записей: **32**; кандидатов вызова: **26**; scalar prototypes: **0**.

Пакеты: `net\can`.
CMake: `LMX::canard`.

| Категория | Записи |
|---|---:|
| callback | 6 |
| function | 25 |
| static_inline | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

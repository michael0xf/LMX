# science_extra:liblsoda

[Первичный LMX-каталог](../catalog/science_extra_liblsoda.lmx) · [Тела LMX](../bindings/science_extra_liblsoda.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `master snapshot retrieved 2026-11-25`.
Записей: **8**; кандидатов вызова: **7**; scalar prototypes: **0**.

Пакеты: `math\ode`.
CMake: `LMX::lsoda`.

| Категория | Записи |
|---|---:|
| callback | 1 |
| function | 7 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

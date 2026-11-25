# base:wavelib

[Первичный LMX-каталог](../catalog/base_wavelib.lmx) · [Тела LMX](../bindings/base_wavelib.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `snapshot 2025-12-12`.
Записей: **69**; кандидатов вызова: **69**; scalar prototypes: **1**.

Пакеты: `math\transform`.
CMake: `LMX::wavelib`.

| Категория | Записи |
|---|---:|
| function | 69 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

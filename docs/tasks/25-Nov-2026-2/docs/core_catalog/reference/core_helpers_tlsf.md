# core_helpers:tlsf

[Первичный LMX-каталог](../catalog/core_helpers_tlsf.lmx) · [Тела LMX](../bindings/core_helpers_tlsf.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `3.1 header API; pinned snapshot 2020-03-29`.
Записей: **21**; кандидатов вызова: **20**; scalar prototypes: **6**.

Пакеты: `os\memory`.
CMake: `LMX::tlsf`.

| Категория | Записи |
|---|---:|
| callback | 1 |
| function | 20 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

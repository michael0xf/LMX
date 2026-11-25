# channel_codes:libcorrect

[Первичный LMX-каталог](../catalog/channel_codes_libcorrect.lmx) · [Тела LMX](../bindings/channel_codes_libcorrect.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `pinned snapshot 2026-02-04; upstream has no release/tag`.
Записей: **42**; кандидатов вызова: **42**; scalar prototypes: **1**.

Пакеты: `code\channel`.
CMake: `LMX::correct`, `LMX::correct_fec`.

| Категория | Записи |
|---|---:|
| function | 41 |
| static_inline | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

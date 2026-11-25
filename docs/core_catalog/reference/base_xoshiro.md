# base:xoshiro

[Первичный LMX-каталог](../catalog/base_xoshiro.lmx) · [Тела LMX](../bindings/base_xoshiro.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `author source snapshot 2026-11-25`.
Записей: **8**; кандидатов вызова: **8**; scalar prototypes: **0**.

Пакеты: `random`.
CMake: `LMX::rng`.

| Категория | Записи |
|---|---:|
| function | 7 |
| static_inline | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

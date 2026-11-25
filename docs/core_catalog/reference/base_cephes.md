# base:cephes

[Первичный LMX-каталог](../catalog/base_cephes.lmx) · [Тела LMX](../bindings/base_cephes.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `Netlib Cephes double suite (release 2.8-era sources; primary archives verified 2026-11-25)`.
Записей: **135**; кандидатов вызова: **135**; scalar prototypes: **101**.

Пакеты: `math`.
CMake: `LMX::cephes`.

| Категория | Записи |
|---|---:|
| function | 135 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

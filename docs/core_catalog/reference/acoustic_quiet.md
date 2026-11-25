# acoustic:quiet

[Первичный LMX-каталог](../catalog/acoustic_quiet.lmx) · [Тела LMX](../bindings/acoustic_quiet.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `pinned snapshot 2019-11-15`.
Записей: **82**; кандидатов вызова: **82**; scalar prototypes: **0**.

Пакеты: `audio\modem`.
CMake: `LMX::quiet`.

| Категория | Записи |
|---|---:|
| function | 73 |
| static_header_function | 9 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

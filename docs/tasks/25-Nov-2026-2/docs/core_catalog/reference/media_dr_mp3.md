# media:dr_mp3

[Первичный LMX-каталог](../catalog/media_dr_mp3.lmx) · [Тела LMX](../bindings/media_dr_mp3.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.7.5`.
Записей: **180**; кандидатов вызова: **29**; scalar prototypes: **0**.

Пакеты: `audio`.
CMake: `LMX::dr_mp3`.

| Категория | Записи |
|---|---:|
| callback | 7 |
| function | 29 |
| function_macro | 51 |
| static_header_function | 88 |
| static_inline | 5 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

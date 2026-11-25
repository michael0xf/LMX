# media:dr_flac

[Первичный LMX-каталог](../catalog/media_dr_flac.lmx) · [Тела LMX](../bindings/media_dr_flac.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.13.5`.
Записей: **297**; кандидатов вызова: **31**; scalar prototypes: **0**.

Пакеты: `audio`.
CMake: `LMX::dr_flac`.

| Категория | Записи |
|---|---:|
| alias | 1 |
| callback | 7 |
| function | 31 |
| function_macro | 22 |
| static_header_function | 92 |
| static_inline | 142 |
| template | 2 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

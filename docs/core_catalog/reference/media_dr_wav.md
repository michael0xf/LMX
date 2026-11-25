# media:dr_wav

[Первичный LMX-каталог](../catalog/media_dr_wav.lmx) · [Тела LMX](../bindings/media_dr_wav.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.14.7`.
Записей: **260**; кандидатов вызова: **94**; scalar prototypes: **0**.

Пакеты: `audio`.
CMake: `LMX::dr_wav`.

| Категория | Записи |
|---|---:|
| callback | 8 |
| function | 209 |
| function_macro | 15 |
| static_inline | 28 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

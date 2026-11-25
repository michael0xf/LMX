# media:miniaudio

[Первичный LMX-каталог](../catalog/media_miniaudio.lmx) · [Тела LMX](../bindings/media_miniaudio.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.11.26`.
Записей: **3675**; кандидатов вызова: **934**; scalar prototypes: **0**.

Пакеты: `audio`.
CMake: `LMX::miniaudio`.

| Категория | Записи |
|---|---:|
| alias | 9 |
| callback | 302 |
| function | 1297 |
| function_macro | 332 |
| static_header_function | 1052 |
| static_inline | 663 |
| template | 20 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

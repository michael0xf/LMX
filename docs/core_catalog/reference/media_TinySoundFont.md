# media:TinySoundFont

[Первичный LMX-каталог](../catalog/media_TinySoundFont.lmx) · [Тела LMX](../bindings/media_TinySoundFont.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `header v0.9; pinned commit`.
Записей: **109**; кандидатов вызова: **51**; scalar prototypes: **0**.

Пакеты: `audio`.
CMake: `LMX::tinysoundfont`, `LMX::tsf`.

| Категория | Записи |
|---|---:|
| callback | 4 |
| function | 51 |
| function_macro | 6 |
| static_header_function | 47 |
| template | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

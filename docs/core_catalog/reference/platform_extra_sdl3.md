# platform_extra:sdl3

[Первичный LMX-каталог](../catalog/platform_extra_sdl3.lmx) · [Тела LMX](../bindings/platform_extra_sdl3.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `3.4.20`.
Записей: **9217**; кандидатов вызова: **4731**; scalar prototypes: **110**.

Пакеты: `audio`, `code\test`, `document\binary`, `fs`, `hash`, `image`, `image\capture`, `image\gpu`, `io`, `io\device`, `io\input`, `math`, `os`, `os\memory`, `os\thread`, `os\time`, `random`, `sensor`, `seq`, `text`, `text\unicode`, `ui`, `ui\window`.
CMake: `LMX::sdl3`, `SDL3::SDL3-static`.

| Категория | Записи |
|---|---:|
| alias | 301 |
| callback | 4004 |
| function | 4723 |
| function_macro | 164 |
| static_inline | 22 |
| template | 3 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# base:stb

[Первичный LMX-каталог](../catalog/base_stb.lmx) · [Тела LMX](../bindings/base_stb.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `snapshot 6b5799bae8a1`.
Записей: **1563**; кандидатов вызова: **273**; scalar prototypes: **1**.

Пакеты: `image`, `math`, `seq`, `text`, `text\font`.
CMake: `LMX::stb`.

| Категория | Записи |
|---|---:|
| alias | 12 |
| callback | 26 |
| function | 292 |
| function_macro | 538 |
| static_header_function | 649 |
| static_inline | 30 |
| template | 16 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

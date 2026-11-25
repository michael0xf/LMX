# systems:libvterm

[Первичный LMX-каталог](../catalog/systems_libvterm.lmx) · [Тела LMX](../bindings/systems_libvterm.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v0.3.3`.
Записей: **111**; кандидатов вызова: **71**; scalar prototypes: **1**.

Пакеты: `ui\terminal`.
CMake: `LMX::vterm`.

| Категория | Записи |
|---|---:|
| alias | 1 |
| callback | 29 |
| function | 66 |
| function_macro | 10 |
| static_inline | 5 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

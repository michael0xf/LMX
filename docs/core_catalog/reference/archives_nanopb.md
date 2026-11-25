# archives:nanopb

[Первичный LMX-каталог](../catalog/archives_nanopb.lmx) · [Тела LMX](../bindings/archives_nanopb.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `nanopb-0.4.9.3`.
Записей: **212**; кандидатов вызова: **39**; scalar prototypes: **0**.

Пакеты: `document\binary`.
CMake: `LMX::nanopb`.

| Категория | Записи |
|---|---:|
| alias | 1 |
| callback | 5 |
| function | 39 |
| function_macro | 122 |
| template | 45 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

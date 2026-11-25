# genann:genann

[Первичный LMX-каталог](../catalog/genann_genann.lmx) · [Тела LMX](../bindings/genann_genann.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.1.1`.
Записей: **17**; кандидатов вызова: **15**; scalar prototypes: **0**.

Пакеты: `ml`.
CMake: `LMX::genann`.

| Категория | Записи |
|---|---:|
| callback | 1 |
| function | 15 |
| function_macro | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

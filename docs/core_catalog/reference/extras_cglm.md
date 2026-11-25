# extras:cglm

[Первичный LMX-каталог](../catalog/extras_cglm.lmx) · [Тела LMX](../bindings/extras_cglm.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v0.9.7`.
Записей: **2530**; кандидатов вызова: **2333**; scalar prototypes: **34**.

Пакеты: `math\linear`.
CMake: `LMX::cglm`.

| Категория | Записи |
|---|---:|
| callback | 2 |
| function | 753 |
| function_macro | 123 |
| static_inline | 1652 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

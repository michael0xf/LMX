# science_extra:erfa

[Первичный LMX-каталог](../catalog/science_extra_erfa.lmx) · [Тела LMX](../bindings/science_extra_erfa.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.0.1`.
Записей: **259**; кандидатов вызова: **254**; scalar prototypes: **48**.

Пакеты: `astro`.
CMake: `LMX::erfa`.

| Категория | Записи |
|---|---:|
| function | 254 |
| function_macro | 5 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

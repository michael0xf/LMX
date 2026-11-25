# archives:mpack

[Первичный LMX-каталог](../catalog/archives_mpack.lmx) · [Тела LMX](../bindings/archives_mpack.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v1.1.1`.
Записей: **450**; кандидатов вызова: **400**; scalar prototypes: **0**.

Пакеты: `document\binary`.
CMake: `LMX::mpack`.

| Категория | Записи |
|---|---:|
| callback | 11 |
| function | 254 |
| function_macro | 34 |
| static_inline | 146 |
| template | 5 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

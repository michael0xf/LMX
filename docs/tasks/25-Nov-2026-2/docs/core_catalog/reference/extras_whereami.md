# extras:whereami

[Первичный LMX-каталог](../catalog/extras_whereami.lmx) · [Тела LMX](../bindings/extras_whereami.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `pinned upstream HEAD`.
Записей: **4**; кандидатов вызова: **2**; scalar prototypes: **0**.

Пакеты: `os\path`.
CMake: `LMX::whereami`.

| Категория | Записи |
|---|---:|
| function | 2 |
| function_macro | 1 |
| template | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

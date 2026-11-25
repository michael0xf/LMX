# base:kissfft

[Первичный LMX-каталог](../catalog/base_kissfft.lmx) · [Тела LMX](../bindings/base_kissfft.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `131.1.0`.
Записей: **20**; кандидатов вызова: **16**; scalar prototypes: **3**.

Пакеты: `math\transform`.
CMake: `LMX::kissfft`.

| Категория | Записи |
|---|---:|
| function | 16 |
| function_macro | 4 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

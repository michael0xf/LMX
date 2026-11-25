# base:cquadpack

[Первичный LMX-каталог](../catalog/base_cquadpack.lmx) · [Тела LMX](../bindings/base_cquadpack.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.1.1`.
Записей: **75**; кандидатов вызова: **36**; scalar prototypes: **3**.

Пакеты: `math\integrate`.
CMake: `LMX::quadpack`, `LMX::quadrature`.

| Категория | Записи |
|---|---:|
| callback | 4 |
| function | 69 |
| function_macro | 2 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

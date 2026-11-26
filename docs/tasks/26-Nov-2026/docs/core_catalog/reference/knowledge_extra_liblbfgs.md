# knowledge_extra:liblbfgs

[Первичный LMX-каталог](../catalog/knowledge_extra_liblbfgs.lmx) · [Тела LMX](../bindings/knowledge_extra_liblbfgs.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.10.0 snapshot`.
Записей: **7**; кандидатов вызова: **5**; scalar prototypes: **0**.

Пакеты: `math\optimize`.
CMake: `LMX::lbfgs`.

| Категория | Записи |
|---|---:|
| callback | 2 |
| function | 5 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# control_extra:fusion

[Первичный LMX-каталог](../catalog/control_extra_fusion.lmx) · [Тела LMX](../bindings/control_extra_fusion.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `snapshot a8d7224f36a0`.
Записей: **56**; кандидатов вызова: **56**; scalar prototypes: **4**.

Пакеты: `sensor`.
CMake: `LMX::fusion`.

| Категория | Записи |
|---|---:|
| function | 24 |
| static_inline | 32 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

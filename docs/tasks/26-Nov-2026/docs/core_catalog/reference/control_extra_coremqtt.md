# control_extra:coremqtt

[Первичный LMX-каталог](../catalog/control_extra_coremqtt.lmx) · [Тела LMX](../bindings/control_extra_coremqtt.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `5.0.2`.
Записей: **116**; кандидатов вызова: **108**; scalar prototypes: **0**.

Пакеты: `net\mqtt`.
CMake: `LMX::coremqtt`.

| Категория | Записи |
|---|---:|
| callback | 8 |
| function | 108 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

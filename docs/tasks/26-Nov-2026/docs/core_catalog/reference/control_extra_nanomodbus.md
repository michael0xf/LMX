# control_extra:nanomodbus

[Первичный LMX-каталог](../catalog/control_extra_nanomodbus.lmx) · [Тела LMX](../bindings/control_extra_nanomodbus.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `snapshot 91d6782930ee`.
Записей: **51**; кандидатов вызова: **29**; scalar prototypes: **0**.

Пакеты: `net\modbus`.
CMake: `LMX::nanomodbus`.

| Категория | Записи |
|---|---:|
| callback | 16 |
| function | 29 |
| function_macro | 6 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

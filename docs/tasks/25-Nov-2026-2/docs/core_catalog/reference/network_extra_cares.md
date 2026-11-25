# network_extra:cares

[Первичный LMX-каталог](../catalog/network_extra_cares.lmx) · [Тела LMX](../bindings/network_extra_cares.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.34.9`.
Записей: **206**; кандидатов вызова: **139**; scalar prototypes: **4**.

Пакеты: `net\dns`.
CMake: `LMX::cares`.

| Категория | Записи |
|---|---:|
| callback | 21 |
| function | 139 |
| function_macro | 46 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

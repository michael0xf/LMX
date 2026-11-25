# network_extra:libevent

[Первичный LMX-каталог](../catalog/network_extra_libevent.lmx) · [Тела LMX](../bindings/network_extra_libevent.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `2.1.13-stable`.
Записей: **579**; кандидатов вызова: **461**; scalar prototypes: **21**.

Пакеты: `net\event`.
CMake: `LMX::event`.

| Категория | Записи |
|---|---:|
| alias | 1 |
| callback | 41 |
| function | 463 |
| function_macro | 58 |
| template | 16 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

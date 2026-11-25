# base:mbedtls

[Первичный LMX-каталог](../catalog/base_mbedtls.lmx) · [Тела LMX](../bindings/base_mbedtls.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `3.6.7`.
Записей: **1341**; кандидатов вызова: **1051**; scalar prototypes: **40**.

Пакеты: `crypto`, `crypto\certificate`, `net`, `net\tls`, `random`.
CMake: `LMX::mbedtls`.

| Категория | Записи |
|---|---:|
| alias | 28 |
| callback | 69 |
| function | 955 |
| function_macro | 193 |
| static_header_function | 29 |
| static_inline | 67 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

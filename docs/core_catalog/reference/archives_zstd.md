# archives:zstd

[Первичный LMX-каталог](../catalog/archives_zstd.lmx) · [Тела LMX](../bindings/archives_zstd.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `v1.6.0`.
Записей: **197**; кандидатов вызова: **186**; scalar prototypes: **18**.

Пакеты: `archive`.
CMake: `LMX::zstd`.

| Категория | Записи |
|---|---:|
| callback | 3 |
| function | 186 |
| function_macro | 8 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

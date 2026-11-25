# text_hash_extra:libunibreak

[Первичный LMX-каталог](../catalog/text_hash_extra_libunibreak.lmx) · [Тела LMX](../bindings/text_hash_extra_libunibreak.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `8.0`.
Записей: **21**; кандидатов вызова: **19**; scalar prototypes: **3**.

Пакеты: `text\unicode`.
CMake: `LMX::unibreak`.

| Категория | Записи |
|---|---:|
| callback | 1 |
| function | 18 |
| function_macro | 1 |
| static_inline | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

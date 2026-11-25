# text_hash_extra:xxhash_modern

[Первичный LMX-каталог](../catalog/text_hash_extra_xxhash_modern.lmx) · [Тела LMX](../bindings/text_hash_extra_xxhash_modern.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.8.4`.
Записей: **202**; кандидатов вызова: **135**; scalar prototypes: **0**.

Пакеты: `hash`.
CMake: `LMX::xxhash_modern`.

| Категория | Записи |
|---|---:|
| alias | 4 |
| callback | 5 |
| function | 50 |
| function_macro | 34 |
| static_header_function | 23 |
| static_inline | 85 |
| template | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# text_hash_extra:isocline

[Первичный LMX-каталог](../catalog/text_hash_extra_isocline.lmx) · [Тела LMX](../bindings/text_hash_extra_isocline.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.1.0`.
Записей: **87**; кандидатов вызова: **85**; scalar prototypes: **8**.

Пакеты: `ui\terminal`.
CMake: `LMX::isocline`.

| Категория | Записи |
|---|---:|
| callback | 2 |
| function | 85 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

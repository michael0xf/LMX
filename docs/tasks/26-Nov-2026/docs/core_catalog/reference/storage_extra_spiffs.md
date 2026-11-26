# storage_extra:spiffs

[Первичный LMX-каталог](../catalog/storage_extra_spiffs.lmx) · [Тела LMX](../bindings/storage_extra_spiffs.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `0.3.7 README version at pinned snapshot`.
Записей: **53**; кандидатов вызова: **42**; scalar prototypes: **0**.

Пакеты: `fs`.
CMake: `LMX::spiffs`.

| Категория | Записи |
|---|---:|
| callback | 5 |
| function | 42 |
| function_macro | 6 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

# tensors:utensil

[Первичный LMX-каталог](../catalog/tensors_utensil.lmx) · [Тела LMX](../bindings/tensors_utensil.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `pinned upstream snapshot 2026-07-13`.
Записей: **137**; кандидатов вызова: **103**; scalar prototypes: **0**.

Пакеты: `tensor`.
CMake: `LMX::utensil`.

| Категория | Записи |
|---|---:|
| function | 87 |
| function_macro | 1 |
| static_header_function | 38 |
| static_inline | 11 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

## Матричный профиль — проверка 2026-11-28

`ut_matmul`: dense float rank2 либо rank3 equal batch, без общего batch broadcasting. Реальный target INTERFACE принудительно CPU-only и требует одного TU для header definitions. Native owner/refcount и ut_free не заменяются обычным free.

[Точные ограничения, альтернативы и существующее подключение](../matrix/README.ru.md#dense-tensors) · [LMX-профили и ссылки на CODE](../matrix/backend_profiles.lmx) · [Результаты ограниченных native-проб](../matrix/validation_report.json).

Статус `[op]`/LMX runtime остаётся `NOT_RUN`; native host probe и проверка CMake-adapter учитываются отдельно. Полные C-сигнатуры выше сохраняются без переименования.

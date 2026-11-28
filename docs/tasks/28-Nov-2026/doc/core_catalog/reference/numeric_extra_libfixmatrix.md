# numeric_extra:libfixmatrix

[Первичный LMX-каталог](../catalog/numeric_extra_libfixmatrix.lmx) · [Тела LMX](../bindings/numeric_extra_libfixmatrix.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `snapshot a8d583e4fe1f`.
Записей: **53**; кандидатов вызова: **53**; scalar prototypes: **0**.

Пакеты: `math\linear`.
CMake: `LMX::fixmatrix`.

| Категория | Записи |
|---|---:|
| function | 51 |
| static_inline | 2 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

## Матричный профиль — проверка 2026-11-28

`mf16`: Q16.16, padded row-major, build max default8. `void` методы диагностируются по errors; QR/solve full-column-rank, solve принимает Q,R,B. C host probe подтвердил overflow flag.

[Точные ограничения, альтернативы и существующее подключение](../matrix/README.ru.md#fixed) · [LMX-профили и ссылки на CODE](../matrix/backend_profiles.lmx) · [Результаты ограниченных native-проб](../matrix/validation_report.json).

Статус `[op]`/LMX runtime остаётся `NOT_RUN`; native host probe и проверка CMake-adapter учитываются отдельно. Полные C-сигнатуры выше сохраняются без переименования.

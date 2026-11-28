# base:linmath

[Первичный LMX-каталог](../catalog/base_linmath.lmx) · [Тела LMX](../bindings/base_linmath.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `snapshot 2022-06-19`.
Записей: **65**; кандидатов вызова: **64**; scalar prototypes: **0**.

Пакеты: `math\linear`.
CMake: `LMX::linmath`.

| Категория | Записи |
|---|---:|
| static_inline | 64 |
| template | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

## Матричный профиль — проверка 2026-11-28

`mat4x4`: float/column-major/4×4; `mul` использует temp, `transpose` требует раздельного выхода. Target INTERFACE экспортирует generated C99 view, не `.a`. `invert` без singular status не закрывает общий solve.

[Точные ограничения, альтернативы и существующее подключение](../matrix/README.ru.md#small-float) · [LMX-профили и ссылки на CODE](../matrix/backend_profiles.lmx) · [Результаты ограниченных native-проб](../matrix/validation_report.json).

Статус `[op]`/LMX runtime остаётся `NOT_RUN`; native host probe и проверка CMake-adapter учитываются отдельно. Полные C-сигнатуры выше сохраняются без переименования.

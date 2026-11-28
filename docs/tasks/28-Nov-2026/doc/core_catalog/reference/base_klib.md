# base:klib

[Первичный LMX-каталог](../catalog/base_klib.lmx) · [Тела LMX](../bindings/base_klib.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `snapshot 97a0fcb790b4`.
Записей: **440**; кандидатов вызова: **149**; scalar prototypes: **9**.

Пакеты: `seq`.
CMake: `LMX::klib`.

| Категория | Записи |
|---|---:|
| callback | 3 |
| function | 119 |
| function_macro | 172 |
| static_header_function | 3 |
| static_inline | 30 |
| template | 113 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

## Матричный профиль — проверка 2026-11-28

`ke_eigen_sd` реально входит в STATIC LMX::klib: real symmetric double, рабочая A изменяется, iteration status обязателен. Общие complex/generalized eig и Schur не заявляются. Нужны явные eps/limits, result ordering и residual policy.

[Точные ограничения, альтернативы и существующее подключение](../matrix/README.ru.md#klib) · [LMX-профили и ссылки на CODE](../matrix/backend_profiles.lmx) · [Результаты ограниченных native-проб](../matrix/validation_report.json).

Статус `[op]`/LMX runtime остаётся `NOT_RUN`; native host probe и проверка CMake-adapter учитываются отдельно. Полные C-сигнатуры выше сохраняются без переименования.

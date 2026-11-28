# numeric_extra:cminpack

[Первичный LMX-каталог](../catalog/numeric_extra_cminpack.lmx) · [Тела LMX](../bindings/numeric_extra_cminpack.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.3.15 / 49a7ea4e6edf`.
Записей: **33**; кандидатов вызова: **25**; scalar prototypes: **1**.

Пакеты: `math\fit`.
CMake: `LMX::cminpack`.

| Категория | Записи |
|---|---:|
| callback | 5 |
| function | 25 |
| function_macro | 2 |
| template | 1 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

## Матричный профиль — проверка 2026-11-28

`qrfac`/`qform` дают путь к rectangular Householder QR; compact column-major result и 1-based ipvt требуют явного adapter. `qrsolv` принимает R,P,Qᵀb,D, а не A,B. Текущий STATIC target: default double, CMINPACK_NO_DLL, без внешнего LAPACK.

[Точные ограничения, альтернативы и существующее подключение](../matrix/README.ru.md#cminpack) · [LMX-профили и ссылки на CODE](../matrix/backend_profiles.lmx) · [Результаты ограниченных native-проб](../matrix/validation_report.json).

Статус `[op]`/LMX runtime остаётся `NOT_RUN`; native host probe и проверка CMake-adapter учитываются отдельно. Полные C-сигнатуры выше сохраняются без переименования.

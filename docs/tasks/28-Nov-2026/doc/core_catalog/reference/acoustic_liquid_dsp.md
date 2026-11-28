# acoustic:liquid_dsp

[Первичный LMX-каталог](../catalog/acoustic_liquid_dsp.lmx) · [Тела LMX](../bindings/acoustic_liquid_dsp.lm3) · [Формат и shim по запросу](../CATALOG_FORMAT.ru.md)

Версия: `1.8.3`.
Записей: **2610**; кандидатов вызова: **2390**; scalar prototypes: **0**.

Пакеты: `audio\dsp`.
CMake: `LMX::liquid_dsp`.

| Категория | Записи |
|---|---:|
| callback | 12 |
| function | 2393 |
| function_macro | 194 |
| template | 11 |

Имена легко искать в секции `Entries`; первый элемент вложенного `spec` даёт индекс полной C-сигнатуры в `Signatures` (таблицы сгруппированы по 32 записи; формула поиска описана в формате). Все исходные позиции и варианты сохранены. Компонентные таблицы являются DATA, а не аргументами callable. Статус LMX runtime: `NOT_RUN`.

Для одной функции: `python3 tools/build_c_catalog.py --catalog-root . --emit-shim <capi_id> --shim-output /tmp/lmx_one.c` (из `docs/core_catalog`).

## Матричный профиль — проверка 2026-11-28

Dense real/complex и sparse families реально включены в `LMX::liquid_dsp`. У pinned версии `matrixcf_trans` выполняет adjoint, `matrixcf_hermitian` — transpose без conjugation. `div` считает правое произведение с inverse; HTML-описание порядка устарело. Solver/QR/LU ограничения и воспроизведённая потеря status описаны в обзоре.

[Точные ограничения, альтернативы и существующее подключение](../matrix/README.ru.md#liquid) · [LMX-профили и ссылки на CODE](../matrix/backend_profiles.lmx) · [Результаты ограниченных native-проб](../matrix/validation_report.json).

Статус `[op]`/LMX runtime остаётся `NOT_RUN`; native host probe и проверка CMake-adapter учитываются отдельно. Полные C-сигнатуры выше сохраняются без переименования.

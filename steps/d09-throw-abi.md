# D-09 — throw-channel ABI (remeasure)

## План

D-09 (2026-09-23) называл два симптома одного рассинхрона: callable-формал на throw-канале вызывается plain ABI через `lmx_call0`; библиотечная обёртка зовёт throw-канальный метод plain ABI, и метод с `throws:` / `merge` не компилируется.

Перемерять, не заводить новый канал. Публичная C-сигнатура библиотеки throw-канала не имеет (`next_core_tasks.md`, остаток S1.2: «у C API нет throw-канала»). Третий граф и новый ABI не добавлять.

## Замер 2026-09-26

Транслятор — `build/l2_harness/d24/bin/l2trans.exe`. `l2trans.lm1` с посадки D-24 (`3ef5e07`) не менялся.

- `unit_dyn_call_throw_caught.lm2` переводится. Вызов формала — `lmx_call_prim(...)`, не `lmx_call0`. Это F-38: статус броска отдельно от значения. Строка harness — Entry 10.
- `lmx_call0` сам уже на prim ABI (`lmx_call.lm1`): ненулевой статус трамплина отмечается для хода. Селфтест `lmx_call_selftest` проверяет статус 2.
- Библиотека, `fn: boom () int` / `throws: Oops` / `throw: Oops(5)`: exit 1, `unsupported library ABI`, frame=fn. Обёртка не эмитируется.
- Библиотека, `Q: merge: P` внутри `fn: m`: exit 1, тот же `unsupported library ABI`. Тот же текст без `--library` переводится (exit 0): отказ даёт профиль библиотеки, не форма merge.
- Библиотека без throw-канала (`return: 41`): exit 0.

## Вопросы автору

Нет нового вопроса. Публичный экспорт метода на throw-канале не делался: у C API этого канала нет, отказ уже located. Пока автор не назовёт публичный статус, отказ остаётся.

## RESULT

Код не менялся. D-09 как «plain ABI / не компилируется» закрыт замером: формал — F-38; библиотека — located `unsupported library ABI`.

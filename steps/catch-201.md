# FABLE-GROK-CATCH-20260925-201

STARTED: `671a161` на `grok/catch-201`, влит `6bde045`, база main `78878ce`. План к.2 — `steps/catch-role-201-k2.md`. Ревью среза 1 — REVIEW `6bde045`.

## Срезы

1. **Раскладка — ПОСАЖЕНО** (`671a161` / `6bde045`). CALL `[call, code, data, rtype, catch, args…]`, PRIM `[prim, rec, catch, ops…]`. Слот `catch` есть и в этом срезе остаётся 0: таблица не читается. `LMX_WALK_OP_PAD` 28, `OP_COUNT` 29. В кадре поля `landing` и `payload`. Шесть эмиттеров `l2_rw_*` и пины harness на новую ширину. Селфтесты walker'а и граф `l3_mail_prim_selftest` сдвинуты. Twin `l2src/` синхронизирован.
2. Таблица сайта на месте (без `LmxCatchRow` и без alloc) + `f\landing` / `f\payload` + перенумерация `k_out` + payload walked callee через `*out` у `lmx_walk_activate` при THROWN. Неявный бросок — payload 0 (REVIEW 29e6d74).
3. Арм PAD и посадка в `lmx_walk_body`.
4. Транслятор: таблицы сайтов, узлы PAD, статически «ближайший покрывающий pad», «свой обработчик исключён».
5. Строки harness: 8 throw/catch + свидетели §7 плана к.2 + `unit_s1_merge_uncaught_entry` (D-55).

## RESULT среза 1

Только раскладка. Существующие броски не меняются: слот 0, pad не спрашивается.

Гейт: build 276/276 (`build/l2src/20260925_091609`), harness 398/398 (`build/l2_harness/20260925_092834`), L3 11/11, check_docs OK.

Мутанты сняты на дереве среза 1 и откатены. Свидетель — `lmx_walk_fresh_call_selftest` (база `OK 7 checks`).

| Что снято | Результат |
| --- | --- |
| `code\len < 5` у CALL | не RED: селфтест снова `OK 7 checks`, exit 0. Узел CALL из 2 детей по-прежнему `INVALID`: `n = len - 5` для `len < 5` — беззнаковое переполнение, и проверка арности walked-callee отказывает. Строка «CALL without data/rtype» доказывает не сам порог `< 5`. |
| `code\len < 3` у PRIM | не RED на этом селфтесте (`OK 7`). Фикстуры PRIM короче 3 детей нет: ближайшие узлы уже ширины 3, порог их не режет. |

Пороги в ядре оставлены. Срез 2 их не снимает.

# FABLE-GROK-CATCH-20260925-201

STARTED: `671a161` на `grok/catch-201`, влит `6bde045`, база main `78878ce`. План к.2 — `steps/catch-role-201-k2.md`. Ревью среза 1 — REVIEW `6bde045`.

## Срезы

1. **Раскладка — ПОСАЖЕНО** (`671a161` / `6bde045`). CALL `[call, code, data, rtype, catch, args…]`, PRIM `[prim, rec, catch, ops…]`. Слот `catch` есть и в этом срезе остаётся 0: таблица не читается. `LMX_WALK_OP_PAD` 28, `OP_COUNT` 29. В кадре поля `landing` и `payload`. Шесть эмиттеров `l2_rw_*` и пины harness на новую ширину. Селфтесты walker'а и граф `l3_mail_prim_selftest` сдвинуты. Twin `l2src/` синхронизирован.
2. **Таблица и посадка — в этом срезе вместе с 3.** Скан Structure на месте (без `LmxCatchRow` и без alloc). `k_in`/`k_out` — size-ячейки, `pad` — ссылка. `f\landing` / `f\payload`. `pad = 0` перенумеровывает в `THROWN + k_out`. При THROWN `lmx_walk_activate` копирует `frame\payload` в `*out`. Неявный бросок — payload 0. Запись броска — в арене, не в scratch (REVIEW 29e6d74).
3. **Арм PAD и посадка — вместе со срезом 2.** PAD, дойденный по порядку, ничего не делает. Посадка: тело-владелец — `pad\parent`; числовой параметр — типизированная запись (несовпадение типа — инвариант, `abort`); Structure — указательная ячейка, ядро только кладёт ссылку на аргумент. Admission — не здесь: транслятор (срез 4, пока BLOCK) эмитирует PRIM `admit` первым statement обработчика, со своей таблицей сайта. Перед телом обработчика `landing` обнуляется. Если обработчик бросает на другой pad того же тела, цикл сажает и его. Продолжение — со statement после PAD.
4. **Транслятор — ПОСАЖЕНО** этим срезом. Таблица сайта на CALL и на PRIM `admit`/`merge`. PAD — ребёнок тела, параметр — ячейка кадра `catch` (`l2_b`). Ближайший покрывающий pad — `l2_catch_find` по стеку областей. Свой обработчик в этот стек не входит.
5. **Строки — ПОСАЖЕНО** вместе со срезом 4: 8 throw/catch бегут своими Entry. `unit_s1_catch_user_break` остаётся «break and continue». D-55 (`unit_s1_merge_uncaught_entry`) не закрыт: строка перенумерации без pad ещё не эмитируется.

## RESULT среза 1

Только раскладка. Существующие броски не меняются: слот 0, pad не спрашивается.

Гейт: build 276/276 (`build/l2src/20260925_091609`), harness 398/398 (`build/l2_harness/20260925_092834`), L3 11/11, check_docs OK.

Мутанты сняты на дереве среза 1 и откатены. Свидетель — `lmx_walk_fresh_call_selftest` (база `OK 7 checks`).

| Что снято | Результат |
| --- | --- |
| `code\len < 5` у CALL | не RED: селфтест снова `OK 7 checks`, exit 0. Узел CALL из 2 детей по-прежнему `INVALID`: `n = len - 5` для `len < 5` — беззнаковое переполнение, и проверка арности walked-callee отказывает. Строка «CALL without data/rtype» доказывает не сам порог `< 5`. |
| `code\len < 3` у PRIM | не RED на этом селфтесте (`OK 7`). Фикстуры PRIM короче 3 детей нет: ближайшие узлы уже ширины 3, порог их не режет. |

Пороги в ядре оставлены. Срез 2 их не снимает.

## RESULT срезов 2 и 3

Сделаны одним шагом: без таблицы посадка не на чем проверяется, без арма PAD узел в теле нечем исполнить.

Свидетель `lmx_walk_catch_selftest`, 19 проверок, exit 0 (после правки REVIEW `6e38e7b`):

- слот catch пуст: `THROWN+1`, литерал 7 после броска не исполняется;
- числовой параметр принимает 41, после pad исполняется литерал 7;
- PAD по порядку пропускается, литерал 7 исполняется;
- Structure: ядро кладёт ссылку на аргумент и не вызывает admit; отдельный `lmx_walk_admit` на ту же пару даёт `THROW_IMPLEMENTS`;
- строка `(1, pad 0, 4)` даёт `THROWN+4`;
- продолжение, не перезапуск: `gcount = 1` и литерал 7;
- два параметра по позиции: 4 затем 9;
- бросок из обработчика садится на внешний pad, литерал 7;
- бросок внутри IF садится на pad блока, литерал 7;
- бросок из обработчика без своего pad уходит как `THROWN+1`, этот pad не входит снова;
- walked callee перенумеровывает через pad 0, caller связывает payload 41 и исполняет 7.

Мутанты на этом селфтесте, каждый откатан. Полный `build_l2src` на мутант не гонялся: переводился и линковался только `lmx_walk_catch_selftest`.

| Что снято | Результат |
| --- | --- |
| проверка `f\landing\parent = body` | RED, exit 1: `throw in the handler lands on the outer pad`, `throw inside IF lands on the block pad`. Числовая посадка в том же теле остаётся зелёной. |
| `i: j` заменён на `i: 0U` | RED, exit 1: `body before the pad runs once` (`gcount` становится 2). |
| не обнулять `f\landing` перед обработчиком | RED, проверка `handler throw with no pad propagates` (обработчик бросает только с первого входа, второй возвращает OK, обход заканчивается вместо распространения). |
| не копировать payload в `lmx_walk_activate` | RED, exit 3, stderr `lmx: invariant: catch payload`. |
| снять ветку `pad = 0` | RED, exit 1: `pad 0 renumbers to THROWN+4`, `walked callee payload is bound`. |
| аргумент параметра берётся с конца (`pcount - 1 - i`) | RED, exit 1: `two parameters bind by position`. Однопараметрические проверки остаются зелёными. После отката селфтест снова `checks=19 failures=0`, exit 0. |

## RESULT среза 4 и строк

Транслятор пишет слот `catch`. Числовой параметр `catch` — ячейка кадра `catch`, не поле корня: чтение и запись идут через `l2_b`, ссылка на ячейку лежит в PAD. `admit` и `merge` ставят строку с фиксированным `k_in` (2 и 1). Вызов ставит `k_in` номера callee. `throw` и `throws` в корне по-прежнему отказ. Голый `return:` со значением в корне по-прежнему отказ; у `unit_s1_catch_t2` выход — письмо `exit`, код тот же 103.

Строки, Entry: declared_vs_merge 27 (MergeFail 1), declared_vs_merge_ok 8, t2 103, sibling 3, rethrow 1011, nested_while 122, publish 7, implements 42. Отказы: duplicate, merge params, param, shadow, unhandled. `user_break` — «break and continue».

Свидетель селфтеста добавлен: «throw onto a sibling pad of the same body lands once» (20 проверок, exit 0). Не обнулять `f\landing` на этом селфтесте — RED по проверке `handler throw with no pad propagates`, не по таймеру. Мутант эмиттера не измерялся.

Гейт: селфтест `checks=20 failures=0` (быстрая пересборка на `build/l2src/20260925_104032`; полный `build_l2src` после этого среза не гонялся). Harness 398/398 (`build/l2_harness/20260925_112130`). L3 11/11. `check_docs` OK.

Гейт ответа: build 277/277 (`build/l2src/20260925_104032`; в том прогоне селфтест ещё на 18 проверках, ядро после него не менялось). После 19-й проверки и после отката мутанта обратного порядка быстрая пересборка того же селфтеста: `checks=19 failures=0`, exit 0. Harness 398/398 (`build/l2_harness/20260925_104719`). L3 11/11. `check_docs` OK.

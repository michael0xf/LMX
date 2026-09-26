# Тикет fable 2026-09-26-04 — §7: обход admission у не-атомных актуалов (полчаса молчания)

Статус: OPEN. Написан по правилу `steps/tickets/README.md`: последний коммит ведущего на main — `e0bf8ac` в 13:36 UTC, к 14:15 UTC ни коммита, ни ANSWER, ни TAKEN. Пункт очереди — `next_core_tasks.md` §7 :447 «Устранить обход admission в own/local/formal/primitive fast paths»; срез 2 плана (таблица преобразований) по-прежнему ждёт формы от автора, очередь не ждёт.

## Измерено в облаке (2026-09-26 14:17 UTC, транслятор main `e0bf8ac`)

Точка admission аргумента — `dev/l2src_sandbox/l2trans.lm1` :14263–:14266: `l2_admit_consumer_uses` зовётся только при `actual_span = 1 && a0\value\kind = ATOM && l2_nsty_get(idx, actual_i) >= 0 && l2_m_node[idx] != 0`. Всё, что не голый атом, минует точку:

1. **Результат вызова как актуал — ложный допуск.** `fn: mk () Plain` (`Plain{toString}`), `fn: take (Equatable: slot) int` с телом `slot\equals: 1U`, вызов `take(mk())` — переводится, exit 0, в переводе ни одного `admit`/`implements` (проба `arg_call.lm2`, knob off и `--walk-methods`). Тот же `take(Plain)` атомом отказывается «implements is false in function argument» (`unit_invalid_implements_used_field`). Это обход §7 :447 и нарушение нормы автора (`LMX_blog/2026-09-22.md` :55: присвоение известных всегда вызывает `implements`).
2. **Путь поля как актуал — неlocated падение.** `take(h\p)` при `Holder{Plain: p}` — «translation failed with no located diagnostic», exit 1 (проба `arg_fieldpath.lm2`). Не обход, но дефект диагностики: отказ обязан быть located (фраза + строка + кадр), как у всех прочих.
3. **`return:` не-атома в объявленный Structure-тип** (`fn: pick (Holder: h) Equatable` / `return: h\p`) — не измерено: пробу остановил более ранний fail-closed отказ на `e: pick(h)` («graph assignment admission requires receiving-expression tests», :5924). Точка return :15172–:15176 имеет тот же атомный guard, что и аргумент — измерить и закрыть тем же срезом или записать located-отказ.
4. Guard `l2_m_node[idx] != 0` (:14263): callee без кадра (нативный/библиотечный) — actual Structure-типа сегодня не допускается и не отказывается. Измерить; если такой вызов вообще проходит, нужен located-отказ или admission по дескриптору (`l2_admit_implements` без кадра уже есть, :10314).

Присваивание `e: h\p` отказывается located («a field path must end at a primitive field», :5924 выше) — не в этом тикете.

## Сделать (транслятор; ядро не трогается)

- Результат вызова как актуал Structure-типного формала идёт в ту же точку `l2_admit_consumer_uses` с `cand` = объявленный тип результата callee (`l2_nsty_get(cand_mi, -1)`), тем же `varb`/кадром callee — один механизм, без второго предиката и без имён-исключений. Путь поля как актуал — либо та же точка с `cand` = тип поля (`l2_nsf_ref`), либо located-отказ; «no located diagnostic» уходит в любом случае.
- Свидетели (в обоих `tests/`, строки `tools/l2_harness.ps1`): `unit_s7_arg_call_refused` (текст пробы 1) — «implements is false in function argument»; `unit_s7_arg_call_ok` — `mk` возвращает не-identity Structure с `equals` и лишним полем → Entry 7; `unit_s7_arg_path` — located исход для `take(h\p)` (допуск или фраза отказа, по норме §uses); return-проба п.3 — свидетель по измерению.
- Мутант: admission результата вызова снят (прежний guard) — `unit_s7_arg_call_refused` переводится (RED); откат — отказ.
- Учёт: `steps/implements-s7.md` (раздел с числами гейта), `grok_next.md` §4 п.9, `next_core_tasks.md` §7 :447 — что закрыто, что остаток (primitive fast path `l2_colon_types_compatible` против `l2_primitive_leaf_implements` :9868 — параллельный предикат §7 :445, отдельной строкой, если не в этом срезе). Близнецы `l2src/` включая `tests/`.

## Критерий готовности

`take(mk())` с несовместимым результатом отказывается той же фразой, что `take(Plain)`; совместимый не-identity результат — Entry 7; `take(h\p)` даёт located исход; корпус прежних фикстур не сдвигается кроме перечисленных; harness зелёный; мутант RED.

Дальше — продолжать `next_core_tasks.md`.

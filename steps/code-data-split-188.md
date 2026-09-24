# CODE-DATA-SPLIT -188 — FABLE-GROKBOT-CODE-DATA-SPLIT-20260925-188

Норма: next_core §3, q27, L2 §10–11, CORE §3. WIP `13b27d4` — только замер.

## (a) Старая модель (к.2 снимает)
| Место | Роль |
|-------|------|
| `lmx_walk.h.lm1` LmxWalkOwn value/ref/dirty | working copy |
| `lmx_walk.lm1` publish_slot → store_slot | typed cell store |
| checkpoint 21.6 | no-op в к.2 |
| enter 21.5 load | только `from` из plan |
| OWN/SET | ячейка экземпляра (слот как сегодня) |
| `lmx_own`/`lmx_dirty` | остаются до Opus -189 c3 |

## (b) Экземпляр / слот
Прототип данных зеркалит код; слот родителя = отдельное поле прототипа юнита. `node\x=data\parent\x`; слот=последний; рекурсия=свой. Формалы→поле только L3 §12/merge.

## (c) Порядок / deps
к.2 → **-186 PUT_REF** → к.3 → к.4 (+ Opus -189 c4 native word). D-63 → -170 c2 first. Defects **D-64+**.

## (d) Фикстуры
Есть: walk_selftest publisher/reader/counter/outer; ref_put; sticky units. Новые: `tests/lmx_walk_off_instance_selftest.lm1` (SET→AT M\x; mutant off-instance RED).

## (e) Коммиты
| К | Что | Гейт |
|---|-----|------|
| к.2 | dirty/cp/publish/enter-load off; OWN/SET/PUT/PUT_OF→cell; mutant; этот addendum | GATE?→build_l2src+harness+L3 |
| к.3 | nested data; кадр | walk |
| к.4 | call self=data; Lmx.native dispatch; без child[0] | harness+L3 с Opus c4 |

## ACK к.1
Слот=поле прототипа данных юнита; две Structure. Без -186 не BLOCKER. own/dirty не в -188.

## Addendum к.2 — Callable/Method → к.4
`lmx.h.lm1`:180 Method / :193 Callable; `lmx_value_owned.lm1`:45/:53 new_owned; `lmx_call.lm1`+`.h` addr/header; `lmx_plan.*` publish; `lmx_graph_copy_owned.lm1`:372/:498; `lmx_implements.lm1`:151; pool+selftests; walk child[0] descriptor; fixtures mk_m/`callable_new` (walk/call/plan/app/root/thread); `l2trans.lm1`~21734. к.2 не трогает. c146481/acb00d4: Lmx.native после parent; sig=graph field; interpreted iff native empty (root = execution pair too).

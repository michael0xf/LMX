# CODE-DATA-SPLIT -188 — FABLE-GROKBOT-CODE-DATA-SPLIT-20260925-188

Норма: next_core §3, q27/Q28/Q29 (b7b7b99), L2 §10, L3 §11/12, CORE §3. WIP 13b27d4 — только замер.

## (a) Старая модель (к.2 снял)
| Место | Было → стало в к.2 |
|-------|-------------------|
| LmxWalkOwn value/ref/dirty | только rom (plan membership) |
| publish_slot / checkpoint 21.6 | store_slot; checkpoint no-op |
| enter 21.5 load | plan → rom only |
| OWN/SET | ячейка графа (+ own_in membership) |
| lmx_own/lmx_dirty | остаются до Opus -189 c3 |

## (b) Модель после b7b7b99 (автор)
1. Один граф может быть и code, и data: обычный вызов = (M, M); корень = (R0, R0). Неизменность кода = исполнение не пишет узлы-операторы, литералы и слово 
ative — только объявленные поля.
2. **Q28:** свежий экземпляр прототипа **только** при повторном входе (рекурсия в стат. графе / динамический вызов по ссылке) или явных данных; живёт в кадре, снаружи не виден; M\x снаружи читает поля самого M (без мусора на каждый вызов).
3. **Q29:** одна ячейка там, где объявление; повторное голое присваивание пишет туда же (не вхождение); [N] нумерует только объявления.
4. Формалы→поле только L3 §12 / merge. interpreted iff Lmx.native empty (acb00d4).

## (c) Порядок / deps
к.2 (done) → **-186 PUT_REF** → к.3 → к.4 (+ Opus -189 c4). D-63 → -170 c2 first. Defects **D-64+**.

## (d) Фикстуры
lmx_walk_selftest (publisher/reader/counter/outer r=2); lmx_walk_off_instance_selftest (SET→AT M\x; mutant off-instance RED).

## (e) Коммиты
| К | Что | Гейт |
|---|-----|------|
| к.2 | dirty/cp/publish/enter-load off; OWN/SET/PUT/PUT_OF→cell; mutant; addendum | GREEN 086f978 |
| к.3 | **не** fresh в слот родителя по умолчанию; OWN/SET/PUT на own-ячейках вхождения; fresh instance **только** для помеченных translator'ом реентрантных CALL; кадр для fresh (Q28); Q29 same-cell | walk+harness |
| к.4 | call: self=data=(M,M); Lmx.native dispatch; без child[0]; стык -186 | harness+L3 с Opus c4 |

## Addendum к.2 — Callable/Method → к.4
lmx.h.lm1:180/:193; lmx_value_owned.lm1:45/:53; lmx_call.*; lmx_plan.*; copy :372/:498; implements :151; fixtures mk_m/callable_new; l2trans~21734. к.2 не трогал.

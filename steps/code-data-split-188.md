# CODE-DATA-SPLIT -188 к.1 — FABLE-GROKBOT-CODE-DATA-SPLIT-20260925-188

База `14472de`. Норма: next_core §3 «Пара code/data», q27, L2 §10–11, CORE §3. WIP `13b27d4` (WALK-CELLS) — только замер.

## (a) Старая модель (снять)

| Место | Роль |
|-------|------|
| `lmx_walk.h.lm1` :109–111, :250–259 | `LmxWalkOwn{from,value,ref,dirty}` |
| `lmx_walk.lm1` :359 `publish_slot` | working→слот |
| `lmx_walk.lm1` :801–821 `checkpoint` | 21.6 dirty→граф |
| `lmx_walk.lm1` :1726–1784 `enter` | 21.5 load plan→owns |
| `lmx_walk.lm1` :548–637, :723–772, :1793+ | скан OWN + order |
| `lmx_walk.lm1` ~1190–1360 | OWN/SET через working+dirty |
| `lmx_plan.*` | пути own **вхождения** M, не прототипа данных |
| `lmx_own.*` / `lmx_dirty.*` | нативный sticky/dirty precursor |
| `lmx_call.*` | `(node,self)=(M.parent,M)` — self≠data instance |

Цель: активация `(code,data)`; plan=прототип данных; fresh instance в слот родителя; OWN/SET/PUT(/OF)/ELEMPUT→ячейка экземпляра; кадр=args/temps/result; dirty/checkpoint/publish/скан own — удалить.

## (b) Экземпляр и слот родителя

Прототип = поля тела (+ вложенные field-only Structure). Вызов: fresh instance в слот данных лексического родителя (callable). `node\x=data\parent\x`. Слот = **последний** экземпляр (`M\x` снаружи); рекурсия — свой на активацию. Код неизменяем. Формалы/result — машинный кадр (L3 §12/merge→поле).

## (c) Зависимости

**-186 PUT_REF:** Structure в слот экземпляра; binding-фикстуры после него. **D-63** (char table vs Array): первый коммит -170 c2; к.1 не блокирует. Дефекты Grok с **D-64**.

## (d) Фикстуры `M\x`/`node\x`

Есть: `lmx_walk_selftest` (publisher/reader, counter, outer/inner ~403–753); `lmx_walk_ref_put_selftest`; `unit_arg_addr_sticky`, `unit_occ_sticky_selector`, `unit_own_dirty_rhs`, `unit_char_own_publish`; §5/-67; `unit_field_path_method`.

Новые: (1) CALLee пишет → `M\x` после CALL; (2) INVALID mid-body оставляет ранние записи; (3) **мутант** запись мимо экземпляра → `M\x` RED. Замер §3.п7: неисполненное объявление = init прототипа.

## (e) Коммиты (после ACK к.1)

| К | Что | Гейт |
|---|-----|------|
| к.1 | этот md | push |
| к.2 | снять dirty/cp/publish/enter-load; OWN/SET→ячейка; plan+fresh (unit) | build_l2src |
| к.3 | вложенные data; кадр; `(code,data)` + мутант | walk selftests |
| к.4 | `lmx_call` self=data; стык -186 | harness+L3 |
| далее | -186 → -187 (после Sonnet c4) → -170 c2 (D-63 first) | по очереди |

Один гейт/машина. К.2+ только после ACK к.1.

## Вопросы

1. Слот родителя: ранг вхождения unit или отдельное поле прототипа юнита?
2. Без -186: temp pointer-cell для Structure-binding или BLOCKER?
3. `lmx_own`/`lmx_dirty` в -188 или ждать Opus -189?
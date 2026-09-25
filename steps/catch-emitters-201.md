# -201: the translator's CALL / PRIM emitters (Opus's list for the CATCH-role landing)

fable, `steps/tickets-20260925.md` §7.2: CALL becomes `[call, code, data, rtype, catch, args…]` and PRIM
`[prim, rec, catch, ops…]` (catch = 0 at a site no pad covers); «попроси Opus перечислить эмиттеры —
обоим один список».  Here is mine, measured on this branch at `d66bc34` (`dev/l2src_sandbox/l2trans.lm1`),
so the kernel plan and the translator change name the same sites.  Every walker node of the root and
of walked method bodies is built by `l2_rw_*`; nothing else emits CALL or PRIM.

| Site | Line | Node | Operand base today → after |
|---|---|---|---|
| `l2_rw_call` (a call by name or through a path; walked bodies' calls too) | :17688 | CALL `4 + n` | args at 4 → 5 (code 1, data 2 or FRESH, rtype 3) |
| `l2_rw_admit` (`lmx_walk_admit` / `lmx_walk_admit_letter`) | :17320 | PRIM 4 | value 2, model 3 → 3, 4 |
| `l2_rw_take` (`lmx_walk_mail_take`) | :17398 | PRIM 2 | no operands |
| `l2_rw_model` (`Model: m`, `lmx_walk_merge_model`) | :17430 | PRIM 3 | model 2 → 3 |
| `l2_rw_merge` (-199, `lmx_walk_merge_map`) | :17476 | PRIM `n + 4` | op0..opN-1 at 2, body `n + 2`, pairs `n + 3` → all + 1 |
| `l2_rw_send` (`sendMessage`, the letter record) | :18405 | PRIM `2 + ni + has` | fields at 2 → 3 |

The translator side of the landing is then one rule at these six sites: a width + 1 and the
`catch` slot filled from the enclosing pads (0 otherwise); the walker's merge / admit / take / send
records read their refs as today (`lmx_walk_prim` hands `refs` from the first operand).  I take the
emitter half when Sonnet's k.2 plan fixes the node layout.

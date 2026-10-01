# K01 — occurrence selector identity: witness probes and slice plan

Status 2026-10-01: **OPEN**. Witness-first investigation on the frozen merge slice
(`8359a59f67b87382c55eb402e9f09f9a4b1ce954`, HEAD `d1cf209`; translator raw SHA256
`8E7FA6854C4E120F…` from `build/l2_harness/merge_value_final_focus_20261001_02`, whose 17
source files were reconciled byte-for-byte with the 25-file manifest and the live tree).
No code changed yet. This is implementation evidence, not a language specification.

## 1. Scope (v2 plan, K01)

Required `x,x` and candidate `x,x,x` make bare last-`x` and explicit `[1]x` coincide in the
required layout but differ in the candidate layout. Preserve each source use's selector
(LAST, explicit occurrence N, or an already physical runtime path) from common resolution
to the used-edge plan; admission, read, write, address and capture use the same edge; the
correspondence cache stays distinct from the current Consumer's permission; replace the
fixed-size compiler use-path storage. Acceptance: native and genuinely walked
read/write/address/capture of candidate values 10/20/30; LAST selects 30 and `[1]` selects
20; unused incompatible field passes last-only consumption, fails a Consumer using it; both
admission orders and repeated calls; old runtime-permutation tests preserved; the old
65-use refusal fixture replaced by 65-plus-use success.
Defect: [ADMISSION-OCCURRENCE-SELECTOR-COLLAPSE](defects.md#admission-occurrence-selector-collapse).

## 2. Confirmed current behaviour (probe fixtures, frozen translator)

Probe directory (untracked): `build/l2_harness/occsel_probe_20261001_01` (staged src of the
final focus run + its `bin/l2trans.exe`; chain in §7). P0 dump shape: in value position a
path is an atom run — `v\x` = `v` `\` `x`; `v\[1]x` = `v` `\` `[` `1` `]` `x`
(`build/fable127_part1b/printTree.exe`).

1. **Bare read on a repeated name is refused** — `Model: (size_t: x 10U; size_t: x 20U)`,
   then `got: v\x` through a formal AND `got: r\x` on a root value:
   `l2trans error: …:5:12: unresolved name / detail: atom=x`. (probes `unit_occ_sel_e`,
   `unit_occ_sel_d`, `unit_occ_sel_a`.) The exact predicate is not yet pinned: two field
   lookups exist with different repeat semantics — `l2_ns_field_ix` (14092, first match)
   and `l2_ns_slot_named` (16976, returns `-2` "ambiguous"). K01a replaces both with
   occurrence-exact lookups and pins the site with a re-run.
2. **`[N]` through a formal is refused at the emitter stage** — same model,
   `got: v\[1]x`: `…:5:10: unknown field path root / detail: atom=v` (probe
   `unit_occ_sel_f`, `unit_occ_sel_g1`), i.e. the check lets the shape through and the
   emitter cannot resolve it (`l2_emit_path_to` → `l2_path_root`).
3. **`[N]` on a root value passes the check but is lowered as invalid C** — same model,
   root `got: m\[0]x` translates (exit 0) and the generated C contains
   `l2_q0 = l2_q2 ->[0] x;` (gcc: `expected identifier before '[' token`). Recorded as
   [NAMED-MODEL-OCCURRENCE-PATH-LOWERING](defects.md#named-model-occurrence-path-lowering).
4. **The traced collapse cannot yet manifest as a wrong value**: neither selector reaches
   the correspondence today (1–2 are refusals; 3 dies in C). What does work: bare-last
   through an admitted formal with a SINGLE-name requirement — `unit_merge_value_repeat`
   (`read (Last: value)` reads `value\x` of the merged `copy{x,x}` and gets 33 = the
   actual's LAST x). That green row is the LAST↔LAST half of the correspondence; the
   ordinal half has no coverage because the spelling cannot be written.

## 3. Where the selector dies today

- **Uses text.** `l2_uses_scan_follow` (14545) builds the used-path string from the atom
  run; on `[` it appends `\` + the bracket atom and the loop stops at the digit (it
  continues only while the next atom is a slash) — the recorded path is `\[`; the ordinal
  is lost before `l2_uses_path_add` (14503) stores it in the fixed 64×128 grid
  (`l2_uses_full` at 64 entries → "a uses list is full", 14791).
- **The check is already selector-aware** where it gets readable segments:
  `l2_admit_consumer_at` (14770) → `l2_admit_paths` → `l2_descriptor_used` parses
  `[N]name` (14680–14726: `l2_schema_named(ri, name, occurrence)` vs
  `l2_schema_named(ci, name, occurrence)`, occurrence −1 = LAST).
- **Value-position path recognizers**: `l2_actual_path` (19276) via `l2_ns_field_ix`;
  `l2_emit_actual_path` (19332) via `l2_ns_slot_named`; `l2_path_contract` (17490) via
  `l2_ns_slot_named`; native `l2_emit_path_to` (17620, segment at 17761) and the
  admitted-first-field remap — `l2_d105_sub` gate + `l2_d105_emit_slot` (17769, 25292),
  which emits the req field slot with no selector.
- **Walker**: `l2_rw_path` (24440) decodes `[N]` via `l2_occ_head` only for merge-result
  roots (24559/24592); namespace fields go to `l2_ns_slot_named` (24599). The admitted
  crossing (path[0]=6) sets `view_model` (24540) and the emitted OF carries the model
  child (24731–24737); `lmx_walk.lm1:951-953` then remaps the slot with
  `lmx_implements_slot(arena, root, model, index, &index)` — one slot in, one slot out.
- **Correspondence**: `l2_d105_table` (24823) maps req field j: occurrence r_j → cand occ
  r_j for non-last fields, LAST→LAST for the name's last field — one target per req field;
  `l2_d105_emit_tables` (25303) writes one `size_t` per req field; `LmxImplEntry` +
  `lmx_implements_at` (lmx_implements.lm1:251) read that one slot; registration
  (`lmx_implements_register`, :352) requires `n == req\array.size`.
- **Capture**: `l2_cap_scan_struct` (29501) reads the member atom as the field name and
  `l2_cap_add` (29466) resolves it via `l2_ns_slot_named` — a `[N]` atom run is not
  expressible; `lmx_walk_capture` (lmx_walk.lm1:2235) copies req-width cells and registers
  the copy as req's own layout with holes (identity).

## 4. Repair design (proposed; the defect leaves the layout open)

**Resolution rule** (general, no new syntax): a named path step resolves occurrence-exact
against the schema it is written on — bare = the name's LAST occurrence; `[N]name` = its
occurrence N. One new helper (`l2_ns_slot_occ(ni, name, occ)`, occ −1 = LAST) replaces
first-match and ambiguous lookups at every consumer; the atom-run readers rebuild the
`[N]name` segment from the bracket atoms; `l2_uses_scan_follow` records the same segment
text so uses and emission agree.

**Edge convention.** The correspondence map is doubled: edge `e ∈ [0, 2n)` — `e < n` is
the ORDINAL target of req field `e` (cand occurrence r_e); `e ≥ n` is the LAST target of
req field `e − n` (cand occurrence of that name's LAST). `n = req` width stays the
registration extent (`lmx_implements_register` untouched); the map array carries `2n`
cells, first half ordinal, second half last. Use sites emit `j` (ordinal) or `j + width`
(last) — the width is static (`l2_schema_width(req)`); the walker needs no new operand
(the OF index is the edge).

**Runtime.** `lmx_implements_at` keeps its ordinal contract; a sibling
`lmx_implements_at_last(e, j)` reads frame cell `e\at + e\n + j`, map cell `e\map[e\n + j]`,
or identity `j`; `lmx_implements_slot` takes EDGES (≥ n → at_last; n from the req model
instance). The hole test becomes: after resolving the target slot, an entry with `holes`
whose target cell is absent/empty gives SIZE_MAX — identical to today's tail for identity
entries, and now usable by captures with explicit maps. `lmx_implements_same_map` compares
both halves.

**ADMIT_AS.** Blocks grow to `2n` cells (ord then last), stride `2n+1`; the instruction's
`default_n` field keeps the semantic `n` and the runtime doubles when advancing/measuring;
compiler extent math (`l2_rw_admit_project`, `l2_rw_map_inline`, `l2_d105_emit_tables`,
`l2_d105_declare_maps`) is updated on both sides in the same slice.

**Capture.** `lmx_walk_capture` copies up to `2n` cells — for each edge the nested body
uses, the cell at that edge, read from src through the same edge — and registers the copy
with an explicit edge-identity map (a static `2n` array emitted per req like the pair maps)
plus holes; a later Consumer's use of an unread edge hits the hole exactly as today.

**Uses storage.** The 64×128 grid and `l2_uses_full` give way to a growable list (K01e);
counts are not language limits.

## 5. Slices (each one bounded, gated, committed)

- **K01a** — occurrence-exact resolution and emission for selector paths that need no
  correspondence (identity layouts: root values, same-type formals): `l2_actual_path`,
  `l2_emit_actual_path`, `l2_path_contract`, `l2_emit_path_to`, `l2_rw_path`,
  `l2_cap_*`; fixes `NAMED-MODEL-OCCURRENCE-PATH-LOWERING` (3). Witnesses: reads,
  writes and `@` of `x,x` values at root and through a same-type formal, native and
  walked; harness rows.
- **K01b** — correspondence edges: `l2_d105_table` (two halves), `l2_d105_declare_maps`,
  `l2_d105_emit_tables`, `l2_d105_emit_slot`, `l2_rw_admit_project`/`l2_rw_map_inline`,
  `lmx_implements.lm1` (`at_last`, `slot` edges, `same_map`, hole rule),
  `lmx_walk.lm1` (ADMIT_AS stride/extent, OF/PUT_OF lookup). Witness:
  `unit_occ_selector_read` — LAST→30, `[1]`→20, native + walked; permutation fixtures
  (`unit_d105_perm_native`, `unit_walk_d105_perm`) stay green.
- **K01c** — capture and the admitted write/`@` edge: `lmx_walk_capture` doubled copy +
  map; `l2_cap_fields`/`l2_cap_scan_struct`/`l2_cap_add` edge-aware. Witnesses:
  write through bare and `[1]` of an admitted actual; `@v\x` identity; a nested body
  reading through the capture.
- **K01d** — negatives and both orders: unused incompatible first field passes
  (`unit_occ_selector_unused_first`), a Consumer using it is refused
  (`unit_occ_selector_first_refused`), both admission orders, repeated calls; mutant
  witnesses per plan §16.4 (collapse present null into absence, substitute the required
  schema, mis-map LAST↔ordinal).
- **K01e** — growable uses storage; replace `unit_s7_uses65`'s "sixty-fifth used path is a
  located refusal" row with 65-plus-use success plus a failure on an actually used
  incompatible edge (not by deleting the witness).

## 6. Witness fixtures added (red until their slice)

`dev/l2src_sandbox/tests/unit_occ_selector_read.lm2` — Pair{10,20} / Triple{10,20,30};
`off (Pair: v)` reads `v\x` and `v\[1]x` and returns their difference; `off(p)` = 0,
`off(t)` = 10; success 7. Today: refused (probe 1).
`dev/l2src_sandbox/tests/unit_occ_selector_unused_first.lm2` — candidate `int x 7; size_t x
20U; size_t x 30U` read bare (last is size_t) must pass and give 30. Today: refused.
`dev/l2src_sandbox/tests/unit_occ_selector_first_refused.lm2` — a `[0]x` consumer (required
occurrence-0 is size_t) must refuse the same candidate (`implements is false in function
argument`). Today: refused earlier, for the resolution reason.
Rows are added with the fixing slice; unregistered fixtures are not gate coverage.

## 7. Probe chain (reproduction)

```
# l2trans from the probe dir (cwd = its src/), then l1trans, gcc, link, run:
P=build/l2_harness/occsel_probe_20261001_01
(cd $P/src && $P/bin/l2trans.exe <fixture>.lm2 convert.lm2 primitive.lm2 $P/gen/<fixture>.lm1)
(cd $P/src && build/opus_wt/bin/l1trans.exe $P/gen/<fixture>.lm1 $P/gen/<fixture>.c)
(cd build/opus_wt && <gcc from the run's compile log> -c $P/gen/<fixture>.c -o $P/gen/<fixture>.o)
(cd build/opus_wt && gcc -o $P/bin/<fixture>.exe $P/gen/l2_eternal_driver.o $P/gen/<fixture>.o $P/gen/l2_libc.o)
$P/bin/<fixture>.exe 0 entry 7
```
P0 dump: `build/fable127_part1b/printTree.exe <file.lm2>`.

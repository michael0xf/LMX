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

**ADMIT_AS.** Blocks grow to `2n` cells, laid out as `[ordinal n][last n]`, stride `2n+1`.
The instruction's `default_n` operand becomes the PHYSICAL cell count (`2n`): the walker's
validation (`default_n == 2*width`), `at += default_n`, and `stride = 2*width+1`, while the
entry's `n` for registration stays the semantic `width` (`v\n: width`). The compiler side
(`l2_rw_admit_project`: `default_n: 2*width`, `extent = 9 + default_n + count*(1 + 2*width)`;
`l2_rw_map_inline` writes `t[j]` at `j` and `t[width+j]` at `width+j`) is updated in the same
slice. `lmx_implements_at`'s frame read keeps `cell = e\at + j` (ordinal, first half) and the
new `lmx_implements_at_last` reads `e\at + e\n + j` / `e\map[e\n + j]`, identity `j`.

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

## 5a. K01a implemented — occurrence-exact resolution and lowering

In the tree (uncommitted at the time of writing; the full harness gate is running):

- `l2_seg_split` + `l2_after_bracket` (near `l2_name_is_seg`): one parser for a
  path segment `[N]name` / `name`; `l2_ns_slot_named`, `l2_mrs_slot_named` and
  `l2_own_seg_scan` all resolve occurrence-exact through it — bare is the name's
  LAST occurrence, `[N]` its occurrence N, absent -1 (the `-2` ambiguity reply is
  gone). This one change serves the checker (`l2_path_contract`, `l2_path_kind`),
  the native emitter (`l2_emit_path_to`), the walker's namespace step
  (`l2_rw_path`) and the capture scan (`l2_cap_add`) because they share these
  lookups.
- `l2_join_path` assembles the `[` digits `]` name atom run into one segment
  `[N]name`; `l2_uses_scan_follow` records the same segment text for the
  used-edge list; the fixed-size uses grid is untouched (K01e).
- `unit_own_last_occurrence` and `unit_merge_occurrence_range_refused` keep their
  located refusals: the joined-path check branch reports `no such occurrence`
  (at the name atom) when an explicit occurrence resolves to nothing, and
  `merge occurrence index out of range` for a bound merge result
  (`l2_check_fields`); the messages and positions match the existing rows.
- `l2_d105_table` with holes: an absent field or one of ANOTHER KIND is a hole
  (`-1`, not carried) — the used-edge check owns refusing a Consumer that reads
  it (`unit_occ_selector_first_refused`: "implements is false in function
  argument"). A nested crossing of another named type stays the slice-1
  translation boundary (`why = 2`), unchanged.
- Probes (frozen chain, rebuilt translator): bare `v\x` on a two-`x` model
  through a formal and at the root = 20 (LAST); `v\[0]x` = 10; `v\[1]x` = 20;
  the root-value `m\[0]x` case that used to emit invalid C now lowers correctly;
  `unit_occ_selector_unused_first` runs green native and walked (30);
  `unit_occ_selector_read` translates but is RED at runtime (exit 82): both
  selectors still map through the one slot — the K01b remnant.
- A method whose body returns `(cast: (int) ...)` stays outside the walkable
  subset (`l2_rw_may`), so under `--walk-methods` its native word remains; K01
  witnesses return their number directly.

Follow-up inside K01a — the value-position walking emitter. `unit_occ_selector_ident_formal`
(a same-type formal, `return: v\[0]x`) first failed in gcc: the generated C held
`l2_p0_0 ->[0] x`. The trailer/return value of a number result goes
`l2_emit_ret_tr` → `l2_emit_ret_convert` → `l2_eval_fields` → `l2_emit_fields`, and
that emitter's atom-splitting walk appends an unrecognized run atom by atom into an
L1 expression — the raw member chain (instrumented trace: `l2_prep` saw `v`, `0`,
`x`). Fix: `l2_emit_fields` now tries the common joined path first — `l2_join_path`
+ `l2_path_root` + `l2_path_kind`; a number leaf (kinds 0/1/7/8/9) is emitted by
`l2_emit_path` and loaded (`lmx_*_value_known(l2_pxp[0])`), any other leaf keeps the
walk below. One general route, so returns, call actuals and value positions share
it. With that, `unit_occ_selector_root` and `unit_occ_selector_ident_formal` run
green native and walked (the walks move, writes and `@` per selector).

Ordering rule the first full gate caught (4 new reds: `unit_body_path_for`,
`unit_body_path_while`, `unit_pathwrite_cell_kept`, `unit_cache_for_call`): a path
read used as a CALL ACTUAL must be materialized into a typed temp where the path
is evaluated, not inlined into the marshalling. The book's program
(`pair(acc for\j)`) reads `for\j` from its published cell BEFORE the call's
pre-call publication; an inlined `lmx_int_value_known(l2_pxp[0])` in the actual
list read it after the checkpoint had published the working value (9 instead of
0 — exit 65/99 where 7/90 was required). The branch now emits
`<type>: l2_tN` + `l2_tN: lmx_*_value_known(l2_pxp[0])` and uses the temp. With
that all four rows are green again (focused re-run `k01a_regress4`).

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

## 8. DS-CODEX-003 review — what it changes in the K01b design

A document check (relay `lmx_uds`, 2026-10-01) returned four obligations. Its own
framing: it fixes implementation obligations the documents already state; it is not
approval of the design, and it explicitly does not accept the capture proposal (§4
"Capture") as written. Claims below were re-checked in the tree, not taken on report.

**Verified independently before use.**

- Dictionary §2: "`[N]name` counts only occurrences of that name … Current unqualified
  named paths select the last occurrence; old first-occurrence wording is superseded."
  `LMX_blog/q/q24.md` (author, closed state dated 2026-09-25): "мы только недавно поменяли
  на lastIndex по умолчанию (было 0)" — the LAST reading is the author's, not a reading of
  the code.
- `l2_descriptor_used` (l2trans.lm1:14683) resolves the source segment on **both** schemas
  with the *same* occurrence selector — `l2_schema_named(ri, @name, occurrence, …)` and
  `l2_schema_named(ci, @name, occurrence, …)`. Slice 1 already had the semantic rule right;
  what the collapse loses is that the correspondence map is keyed by the req field alone.
  So the edge must be chosen by the **source use's selector**, not by "the req's last field
  ordinal" — the map's ordinal half answers `[N]name`, its last half answers bare.
- `lmx_implements_walk_view` (lmx_implements.lm1:156-173) iterates the CONSUMER's fields and
  resolves each through `lmx_implements_at(view, index)`. With a doubled map this loop still
  visits edges `[0, n)`; that is correct for what it is — the declared-layout check — and is
  **not** the used-edge check.
- `docs/L1_spec_en.md` §15: "A fresh capture occupies the required model's positions with
  holes: when its schema is known, its producer supplies that schema's key, not the source
  value's key; without such evidence the key remains null."
- `docs/L2_spec_en.md` §13-14: a cached map does not replace the current Consumer's
  requirements; failed reception publishes neither correspondence nor layout evidence.
- Runtime selftests are clients of the same API and carry `n`-cell maps:
  `tests/lmx_implements_table_selftest.lm1:170-181` (`perm` two cells; :173 asserts
  `lmx_implements_slot(..., 2U, …) != 0`, i.e. `j = n` has no slot),
  `:198`/`:289` (`lmx_implements_is_map(…, perm, 2U)`), `tests/lmx_gc_selftest.lm1:305`
  (one-cell map for a one-field model).

**Obligations that amend §4.**

1. `default_n` stays "0 **or** 2·width": zero is the justified compact identity case (no
   static map, no frame), not an error. `stride = 2·width + 1`; the registered entry's `n`
   remains the semantic width.
2. Edge IDs are metadata, not physical child indices. A raw/manual physical path keeps using
   the supplied permutation unchanged; only a *semantic* use (bare or `[N]`) carries the
   selector end to end. LAST = identity `j` is valid only for an entry with neither frame nor
   map — where the layout proved positional equality — not as a general answer for a LAST
   edge on a non-last `j`. In the translator the rule has exactly two sites: **edge =
   `slot + width` only when the crossing carries a correspondence and the written segment is
   bare**, `slot` otherwise — the native formal read/write (l2trans:17932, width already in
   hand as `l2_d105_width(l2_input_model(view_mi, view_key))`) and the walked OF/PUT_OF index
   (l2trans:24967, `req = path[8 + 3·(level−1)] ≥ 0` marks the correspondence crossing). Where
   no correspondence is carried (`req < 0`: a same-type formal, a local, a root value) the
   model IS the value's layout and K01a's occurrence-exact lookup already gives the right
   physical slot — no edge is involved.
3. Migrate **every** producer and consumer in one ABI slice, not `l2_d105_*` alone: static
   maps (`l2_d105_declare_maps`, `l2_d105_emit_tables`), inline frames (`l2_rw_map_inline`,
   `l2_rw_admit_project` extent), `lmx_implements_register`/`same_map`/`is_map`/`at`/`slot`,
   walker `lmx_walk_admit_op`, the native use site (`l2_d105_emit_slot`, l2trans:17932), the
   walked use site (`l2_rw_path` level selector → the OF index, l2trans:24967), capture
   (`lmx_walk.lm1:2260`), `lmx_implements.h`/`lmx_walk.h` comments, and the two selftests
   (the `:173` boundary moves to `2·width`, and the maps double — the physical-permutation
   rows stay, they are not deleted).
4. Capture (K01c) is **not** a per-edge fresh cell. Two edges may name the same source
   target (req `x` / source `x`: ORDINAL(0) and LAST are one cell), and the copy must keep
   them one cell — equal source targets map to one copied target, different targets stay
   distinct. Sharing is a property of the source relation, not of the number of spellings.
   A 2n physical copy is not req's layout: it must not carry req's schema token as
   provenance (L1 §15). Witnesses: one-`x`-each aliasing (address equality, a write through
   one selector seen through the other); req two `x` / actual three `x` staying distinct.
5. The used-edge check and execution must use the **same** edges, on every route (native,
   walker, full receiver, nested crossing). Compile side that is `l2_descriptor_used`; the
   runtime `lmx_implements_walk_view` remains the declared-layout check it is today, and a
   client-supplied permutation's second half is that client's contract exactly as its first
   half is today. The hole test moves after target resolution; a present-but-null reference
   cell must stay distinguishable from an absent cell (K01c witness).

**Scope of the analytical stage, as relayed (lmx_uds, 2026-10-01).** The author's words, as
the relay reports them: "Мы проверяем на данном этапе *вероятность* того что varA подходит на
место varB в Consumer"; "фактически мы проверяем только что кандидат не упадет при
потреблении и имеет все поля -- этого достаточно"; the second stage, Consumer unit tests, "в
плане работ еще нет". I read the passages myself before using them: `docs/LMX_semantics.en.md`
§7 states the predicate is Consumer-relative over `uses(Consumer, bVar)`, that unused fields
and unselected occurrences are not compared, that the analysis executes nothing, and that
final admission additionally requires the Consumer's own graph unit tests. So:

- K01's obligation is *the same used edge selected and checked as the one executed* — nothing
  wider. No exhaustive runtime revalidation, no checking of unused fields or of both halves
  "just in case", no universal proof engine, no implementation of the future Consumer-test
  stage.
- A compile-time proof for a used edge need not be re-run at every access; the compiler's
  table (holes) is that proof for a static correspondence, on both halves.
- The two halves of the map are one possible encoding of selector identity, not a strong
  admission law: what is fixed is that a bare use and an explicit `[N]` use of the same name
  must reach the targets the value's own model gives them, and that read, write, address and
  capture use that same edge.

# Slice247 — the draft79 line in build2: V63, the bare return, the split pointer, and the native DEREF's status channel and null holder

Base main/origin `12d16510` (slice246). Opus sole writer/build; Codex consults. R=`C:/Nyasha_Planet/LMX`;
P=`R/build2/codex_fix250generationchain01`. Every tool CLI and every gdb run from a fresh private CWD.

## The V63 edge (DRAFT79-OWNER-POINTER-CONTEXT-STACK-POINTEE)

Program: owner73c on FE87 + RT87, `P/owner-values73c-hidden55-fe87-rt87-suite-01/lib_owner-native/p-prod.exe`
`849354BF…`, argv `0 entry 7` (the suite record's native root0 line); fixture
`P/variants/runtime-callable73c/lib_owner.lm2`, `try_dynamic_m` = `l2_m15`.

Run 09's backtrace already showed the shape: the status-3 store `lmx_copy_value`+1440 ← `lmx_copy_reference_fill` ←
`lmx_copy_value` returning at +753 ← `lmx_copy_process`. The refused `arena` cell is a CHILD of a Structure the copy was
processing, so the edge that first reached that Structure is not on the stack. The prepared frame-walk run was
replaced before it ran.

Run 10 (`pins/gdb87-owner-v63-10.gdb`/`.log`): breakpoints enabled only inside `l2_m15`; every `lmx_copy_process` src
(kind, type, parent, children) and every `lmx_copy_value` / `lmx_copy_reference_fill` entry with its caller; 4552
events, then `UNSUPPORTED v=` the copy's own source arena (a thread-stack address). The copy of `context_root`
follows child 0 `context_outer_cell` (type 1042): its payload (`context_owner_cell` → the runtime graph), then
`lmx_copy_value_context`, whose +211 stores the copied `model` (offset 0x38) and +423 the copied `references`
(0x40) — read from the disassembly. `context_outer_cell` carries model = the Model declaration (a child of the
parentless 44-child program root) and references = node N. N's structural parents climb a code subtree whose
application has the program root as an operand; the root's declarations include S, `try_dynamic_m`'s own-place
Structure (`l2_gp3923`, 382 children; `owner_address` is its child 128); N sits under S's child [3]. S's child [6] is
the own cell `arena` (type 1125, `@: arena c.LmxArena (cast: (@: c.LmxArena) c.l2_call_arena)`, `lib_owner.lm2:211`),
whose content is the stack arena → kind NONE → UNSUPPORTED.

## The 84→87 producer: a stale pointer companion

Run 13 (`pins/gdb87-owner-v63-13.gdb`/`.log`): every own store through `lmx_walk_value_store_with_writer` and every
`lmx_walk_place_load` inside `l2_m15` up to the copy (56 stores, 31 loads):

- `p` (`@: p Model runtime_graph()`): ref = the runtime graph, model = the Model declaration, references = N.
- `value_graph` `(cast: (@: c.Lmx) p)` and `box` `(cast: (@: void) value_graph)`: same ref, same model/references.
- `box_cell` `@ box`: ref = box's published arena cell, referent = that cell's context companion.
- `lmx_walk_value_materialize(arena, from_value, box_cell)` writes a new cell into that arena cell each time; every
  later `\box_cell` place load reads the new raw content while the companion still holds `present=0 ref=nil`
  model = the Model declaration, references = N — so the V59 number/graph/null/descriptor/text/immutable cells,
  `context_owner_cell` and `context_outer_cell` all receive p's model and references.
- `owner_address` `(cast: (@@: void) context_owner_cell)` stores that stale context (FE87:
  `lmx_walk_value_ref_context` with the source's working Value, then `lmx_walk_value_store_with_writer`);
  `address_value` is loaded from its cell and materialized as `context_outer_cell`.

FE84 stored `owner_address` with `lmx_value_cell_store(…, context 0, …)`, which hid the stale companion.

Withdrawn: runs 11, 12, 12b and 12c assigned the gdb name `$cx`, which is the CX register (the low 16 bits of RCX =
the `arena` argument of `lmx_walk_place_load` at its entry); that corrupted the argument and produced a SIGSEGV in
`lmx_range_entry_at` that the program never has. Runs 12d (silent place-load stop), 12e (store stop with reads),
12f (silent store stop) and 13 reach the V63 copy. Their store lines before the first place load are valid; nothing
after it is evidence.

## Codex's decision

CODEX-OPUS-V63EDGE-20261031-ANSWER01 ([records](records/CODEX-OPUS-V63EDGE-20261031-ANSWER01.txt)): (a) bind the
physical pointer cell's metadata to the reference it was stored with, in the common physical store/load mechanism:
record the stored reference after a successful managed store; a load attaches the companion's metadata only when it
matches the reference read once through the typed accessor (`lmx_walk_value_load` and `lmx_walk_place_load`); a
mismatch is an ordinary typed REF without model/references/referent; companion addresses and owner identity stay; no
stamp checks on context-only temporaries; no refresh of earlier working snapshots (norm470). (b) N is legitimate
reference-contract data; no code-ancestry rule; a full-used closure is witnessed through the existing
`lmx_graph_copy_many_used_staged` with all V63 checks; V63's `lmx_graph_copy_owned` failure stays recorded as that
stronger operation's.

## Candidates

- candidate90 (`pins/candidate90-prepare-02.command`; attempt 01 stopped at an over-broad check of FE87's invariant
  manifest: 6 kernel declarations RT87 regenerated): stage87 + coherent89's Emit `B9580244` (the bare-return
  checker refuses only a machine function with a result, the exact complement of what Lower/Core lower by
  `emit_empty_return`; the Emitter graph producer emits `LMX_WALK_OP_RET`) + green89's resolve `25769A60`;
  `source-candidate90.sha256` `2470ADC3…`. FE90 = ONLY Emit and resolve, host85, producer 49c, BASE full48/g2.
- companion91 (mechanism (a), kernel only, no new export or writer change): `lmx_value_owned` `16CDC14E`
  (`lmx_value_cell_fill` stamps present/kind/ref after a successful write), `lmx_walk_values` `83EAE52A` (internal
  `lmx_walk_loaded_context`; validated value load; place load snapshots the context's recorded reference before the
  load and overlays only on a match), `lmx_reparent` `70F9C0A5` (a committed relocation re-stamps).
- splitptr92 (prepared, not built): Coords `E6D90C71`, `split_data_row` admits a typed reference to non-graph data
  (pointer, not Array, not graph). The 65 consumers in six modules are type-agnostic.

companion91 left one native physical read uncovered: Lower's `lm_compiler_emit_indirect_value` copied
`lmx_value_address_context`'s metadata into each deref step before `\NAME` was loaded. Codex
(CODEX-OPUS-V63A-20261031-ANSWER01, [records](records/CODEX-OPUS-V63A-20261031-ANSWER01.txt)): route (1), ONE exported
pure helper in `lmx_value_owned` through the existing `value_names`/writer route, used by both walker loads and the
native step; keep the exact typed single dereference; snapshot metadata and the identity stamp before it; no place-load
replacement, no inlined second predicate; `lmx_implements_low_model` stays declaration-only and unchanged; the reparent
re-stamp and the split-pointer predicate pass static review. The runtime-only chain91 records were superseded before
they ran.

- coherent92 (`variants/coherent92`): `lmx_value_owned` `875B594B` (the stamp in `lmx_value_cell_fill`; exported
  `lmx_value_loaded_context(context, raw)`), `lmx_walk_values` `9347AD82` (both loads through it), `lmx_reparent`
  `70F9C0A5`, writer92 `tools/build.lm2` `C46B3A57` (`value_names` 61 → 62), Lower `9A4F013A` (the native step snapshots
  the full record of the address context, dereferences once, and builds the step with
  `ref_context(…, lmx_value_loaded_context(…))`), Coords `E6D90C71` (splitptr92).
- chain92 (`pins/chain92-detached.command`): generator92 = source-generator85 + writer92, GEN62 `build-self` as for
  generator85 (BASE full48/g2, FE 49c, RT49j); stage92 = source-candidate90 + coherent92 with FE90's other 19 modules
  reused by exact manifests; FE92 = ONLY Lower and Coords (host generator92); RT92 = `build-runtime` in stage92 (host
  generator92, kernel by 49c); suites held78, computed-absence79, no-candidate79, owner73c on FE92 + RT92.

## Chain92 results

FE90 (`pins/candidate90-frontend-parts-terminal.txt`): exit 0, 71 min, host85 `D7D72390`; reuse inputs 195/0 and
artifacts 40/0 before, artifacts 40/0 after; `fe90/l2trans.exe` `E3B3B114`; resolve `.lm1` `3C445A64` = boot89 G1's.
Chain92 (`pins/chain92-detached.terminal.txt`, 00:47:13Z → 01:36:36Z): generator92 prepare (8 steps) and build-self,
candidate92 prepare (12 steps), FE92, RT92 and suites92 — every record exit 0. Suites on FE92 + RT92
(`pins/*-fe92-rt92-suite-01.log`):

- held78: 0 failed (native and forced built; root0/root1 give 7).
- computed-absence79: 0 failed — the bare return gives 7 in native and forced, root0/root1.
- owner73c: 0 failed; in all four modes `V63 copy values y=43 source-y=42 x-slot=1 y-slot=2 refs=1 owner-alias=1` and
  `V63 typed places absent=0 null=1 plain-null=1 write=1 address=1 missing=1 failed=0` (mechanism (a) with route (1)).
- no-candidate79: forced built, root0 7, root1 7 (the split pointer is admitted); native `FAIL ... step 3 kind 0 exit 1
  [CC]`: `p.c:485: 'l2_out_throw' undeclared` in `l2_m3`, the split `Code`.

## The split pointer's status channel

`unit_no_candidate_selected_pointer-native/p.lm1`: `l2_m3` has the signature without `l2_out_throw`, and its body
dereferences `p`, the split data row's cached working value (`l2_q1_p` / `l2_wv1_p`), through
`lmx_walk_value_deref_place` with `if: l2_ids2 = c.LMX_WALK_THROWN + c.LMX_WALK_NAME_INTERPRETER` →
`l2_out_throw[0]: 0` / `return: 4`. Lower's `lm_compiler_emit_indirect_span_full` takes that checked walker DEREF when
the method is not a machine function, every step is a walker input value and the operand has a full value
(`lm_compiler_own_load_context_full` gives one for a cached own); `lmx_walk_value_deref_place` returns THROWN +
INTERPRETER for a null holder (LMX_semantics #exceptions). `m_throws` is `lm_compiler_body_throws`, and its effects never
classify a prefix dereference: in the field scan `path_steps_operand` refuses an operator atom at a run's root (status
2) and a bare `p` is no run; the two prepared-value scans recurse only into the operand. The gap is not split-specific.
The tracked fixtures with such dereferences in ordinary methods are already marked by index or reference-path
effects; the fnptr/order witnesses are `--machine` modules, which the route and the marking both exclude.

## Coherent93 and chain93

- coherent93 (`variants/coherent93`): Lower `C5358793` — ONE classification `lm_compiler_indirect_managed(levels,
  source_type, mi)`, the former availability probes of `emit_indirect_span_full`, which now asks it; Emit `7887932D` —
  the effects mark every such dereference: the field scan at a `\` that starts no run
  (`lm_compiler_fields_indirect_raises`: `value_span_prepare` of the one operand) and both prepared-value scans at a `\`
  operand span (`lm_compiler_indirect_span_raises`: `lm_compiler_indirect_span`, then the classification); writer93
  `1C6A9974` — `frontend_lower_names` 442 → 443. The classification is conservative: Lower's checked route also needs a
  full operand and a full-value consumer, and where it takes the raw route the method carries an unused channel. All new
  functions are appended at their module's end. Header parameter names `l2_p<N>` count every function of a module, so
  Emit's `.h.lm1` stays byte-identical (it stays in the ABI manifest), and Lower's gains one prototype.
- chain93 (`pins/chain93-detached.command`, launched 02:04:45Z): generator93 = source-generator85 + writer93 (GEN62
  `build-self` as for 85/92); stage93 = source-candidate92 + coherent93, the other 19 modules' outputs from stage92 by
  exact manifests (`candidate93-reuse-*`; stage92's 159 sources verified first, `pins/check93-verify92.log`); FE93 = ONLY
  Lower and Emit (host generator93, producer 49c, BASE full48/g2; Lower's `.h.lm1` out of the ABI manifest); suites on
  FE93 + RT92 with stage92 (no runtime change): no-candidate79, held78, computed-absence79, owner73c.
- Asked (OPUS-CODEX-THROWDEREF93-20261101T0215Z, item 4): the raw native route of the same managed dereference
  (`lm_compiler_emit_indirect_value`: `DECL NEXT \NAME`) has no holder check, so a null holder is a C fault there, not
  `interpreter`. Codex (`pins/CODEX-OPUS-THROWDEREF93-20261101-ANSWER01.txt`): let chain93 finish unchanged; the raw
  encoding of the same language DEREF checks its actual holder before each physical dereference, the final read
  included, with the existing implicit `interpreter` throw; a null loaded from a valid holder stays a value until it
  is itself dereferenced; the `--machine` branch and raw C ABI operations keep their machine-storage contract; the
  effect scan reuses the one classification; one small witness. That is coherent94 below.

## Chain93 results

Chain93 (`pins/chain93-detached.terminal.txt`, 02:04:46Z → 04:03:16Z): every record exit 0. generator93 `build-self`
`DF3B7ED0` (02:17:07Z). FE93 (`pins/candidate93-frontend-parts-terminal.txt`): exit 0, 99 min, host `DF3B7ED0`; reuse
inputs 195/0 and artifacts 39/0 before, artifacts 39/0 after; `fe93/l2trans.exe` `042DE10C`; Lower `.lm1` `64EA7E5F`,
Emit `.lm1` `BEB117BC`. Lower's `.h.lm1` (stage92 `C2FC3E56` → stage93 `04D779F2`) gains exactly one line, the
appended prototype `lm_compiler_indirect_managed (int: l2_p549_0_levels; ...)`; Emit's `.h.lm1` `3A007B19` is
unchanged. Suites on FE93 + RT92 (`pins/*-fe93-rt92-suite-01.log`), each 0 failed:

- no-candidate79: native built, root0/root1 give 7 — the former CC failure is gone; forced root0/root1 give 7. All four
  runs print `V79 no-candidate first=11 second=13 preserved=1`. Its native `p.lm1` (`AB14DA6B`; FE92's `5FF97988`)
  differs in three places: `l2_m3` (the split `Code`) has `@@: Lmx l2_out_throw` in its prototype and definition with
  the status locals, its trampoline passes and publishes `l2_tt`, and the unit declares one more pointer-cell prototype
  `pc102_write`, with no definition and no use. `lm_compiler_emit_pointer_cell_contracts` declares one per type code
  below `100 + l2_foreign_n`, so one more foreign code existed when that list was written; inferred, not traced: the
  effect scan now resolves the dereference (`lm_compiler_indirect_span`, then `lm_compiler_indirect_managed`, whose
  `lm_compiler_indirect_type` can intern a foreign code) before the list, where only lowering did so after it.
- held78, computed-absence79: native and forced built; root0/root1 give 7.
- owner73c: all library and main builds pass; in all four runs `V63 copy values y=43 source-y=42 x-slot=1 y-slot=2
  refs=1 owner-alias=1` and `V63 typed places absent=0 null=1 plain-null=1 write=1 address=1 missing=1 failed=0`.

## Coherent94 and chain94: the raw route's holder

- coherent94 (`variants/coherent94`, base coherent93): Lower `99605615` — `lm_compiler_emit_indirect_value` takes `mi`
  and `checked` (the caller's `lm_compiler_indirect_managed` of the whole DEREF) and, when checked, emits
  `if: <holder> = 0` + `lm_compiler_emit_null_use(mi)` + `---` right before every step's read, the final expression's
  included; `lm_compiler_emit_indirect_span` and the raw fallback of `emit_indirect_span_full` pass the classification;
  `lm_compiler_emit_indirect_location` checks the written place's holder after its location and before the value (the
  walker's PUT forms its DEREF place before its value). Emit `C35CE51A` — `head_path_effect` classifies a raw
  dereference write head the same way (`lm_compiler_indirect_head_raises`: `indirect_head` + `indirect_resolve` + the
  classification), appended at the module end. No writer change (writer93 exports every function used). Left
  unchanged, explicitly: the raw index place (`p[i]`, kind 8, address arithmetic, passes 0) and the deref-word route
  `lm_compiler_prefix_deref` (an atom whose text begins with `\`; P0 emits `\` as its own atom).
- Witness `variants/working-value94/unit_no_candidate_selected_pointer.lm2` (`205BCBC9`, `pins/no-candidate94.tsv`):
  no-candidate79's fixture plus `read_null_raw` (`@: hole int 0`; `if: \hole = 0` in a block whose
  `catch: interpreter` gives 4) and `read_null_checked` (`node\seen: \hole`, handler 8); 7 needs both and the split
  pointer's values.
- RED (`pins/red94.command`, FE93 + RT92, stage92; `pins/no-candidate94-fe93-rt92-suite-01.log`): native built; native
  root0/root1 `driver exit -1073741819` (0xC0000005) before any output; forced root0/root1 give 7 with `null-raw=4
  null-checked=8`. Native `p.lm1` (`37E5A864`): `read_null_raw` (`l2_m1`) reads the condition's operand raw —
  `@: int l2_t18 l2_t17` / `int: l2_nv19 \l2_t18` with no holder test — while `read_null_checked` (`l2_m2`) takes
  `lmx_walk_value_deref_place`. Both methods carry the channel (coherent93's classification marks the condition too).
- chain94 (`pins/chain94-detached.command`, launched 04:04:40Z): red94 → candidate94-prepare (stage94 = stage93 +
  coherent94, the other 19 modules' outputs from stage93 by exact manifests `candidate94-reuse-*`) → FE94 (ONLY Lower
  and Emit, host generator93, producer 49c) → suites on FE94 + RT92 with stage92: no-candidate94, no-candidate79,
  held78, computed-absence79, owner73c.

## Chain94 results

Chain94 (`pins/chain94-detached.terminal.txt`, 04:04:40Z → 05:52:45Z): every record exit 0. FE94
(`pins/candidate94-frontend-parts-terminal.txt`): exit 0, 101 min, host generator93 `DF3B7ED0`; reuse inputs 195/0 and
artifacts 39/0 before, artifacts 39/0 after; `fe94/l2trans.exe` `4FF3DB52`; Lower `.lm1` `5746B3F6`, Emit `.lm1`
`594F1EB8`. Lower's `.h.lm1` (stage93 `04D779F2` → stage94 `6B63EB53`) differs in exactly one line, the
`lm_compiler_emit_indirect_value` prototype with `mi` and `checked`; Emit's `.h.lm1` `3A007B19` is unchanged. Suites on
FE94 + RT92 (`pins/*-fe94-rt92-suite-01.log`), each 0 failed:

- no-candidate94: native and forced built; root0/root1 give 7 in both; all four runs print `V79 no-candidate first=11
  second=13 preserved=1 null-raw=4 null-checked=8`. Its native `p.lm1` (`2569AF8D`; FE93's `37E5A864`) differs in one
  hunk ([diff](l1-no-candidate94-native-fe93-fe94.diff)): in `read_null_raw` (`l2_m1`), `if: l2_t18 = 0` with the
  block's local throw (`l2_pl0: 0`, `l2_at0: 1`, `continue`) right before `int: l2_nv19 \l2_t18`. The forced `p.lm1`
  gains the same guard.
- no-candidate79, held78, computed-absence79: native and forced built; root0/root1 give 7. Their native and forced
  `p.lm1` are byte-identical to FE93's.
- owner73c: all library and main builds pass; in all four runs the V63 lines are unchanged (`V63 copy values y=43
  source-y=42 x-slot=1 y-slot=2 refs=1 owner-alias=1`, `V63 typed places absent=0 null=1 plain-null=1 write=1 address=1
  missing=1 failed=0`). Its native `p.lm1` (`9B5659D7` → `8C8A70D0`, [diff](l1-owner73c-native-fe93-fe94.diff)) gains
  eight holder guards and nothing else (8 hunks, 97 added lines, none removed), each before a raw read of a managed
  pointer (`required_cell`, `box_cell`, `context_answer_cell`, `x_cell`, `y_cell`, `holder_required_cell`; intermediate
  steps and final reads) in methods that already carried the channel; the forced `p.lm1` gains the same eight. The
  outputs are unchanged.

## The raw store: chain95

No suite of chain94 emitted the write route's guard (owner73c's eight are reads, no-candidate94 only reads its null
holder), so coherent94's `lm_compiler_emit_indirect_location` check and Emit's `lm_compiler_indirect_head_raises` had
no witness. Chain95 (`pins/chain95-detached.command`, 05:59:37Z → 06:00:03Z, every record exit 0) adds one and reuses
FE93 and FE94, with no translation:

- `variants/working-value95/unit_no_candidate_selected_pointer.lm2` (`8759BCC5`, `pins/no-candidate95.tsv`,
  [diff](working-value95.diff)): no-candidate94 plus `write_null_raw` (`@: hole int 0`; `\hole: 5`; no handler of its
  own), called by `write_null_caught`, whose `catch: interpreter` gives 16; it runs before the reads; 7 needs
  `null-write=16` too.
- red95 (`pins/red95.command`, FE93 + RT92, stage92; `pins/no-candidate95-fe93-rt92-suite-01.log`): native built; native
  root0/root1 `driver exit 3`, run log `lmx: walk error: INVALID` — the unguarded store reaches its walk-fail checks with
  the null address and ends the run instead of raising `interpreter`; forced root0/root1 give 7 with `null-write=16
  null-raw=4 null-checked=8`.
- suites95 (`pins/suites95.command`, FE94 + RT92; `pins/no-candidate95-fe94-rt92-suite-01.log`): 0 failed; native and
  forced root0/root1 give 7; all four runs print `V79 no-candidate first=11 second=13 preserved=1 null-write=16
  null-raw=4 null-checked=8`. The native `p.lm1` (FE93 `523652F6` → FE94 `1A80D3B1`,
  [diff](l1-no-candidate95-native-fe93-fe94.diff)): `write_null_raw` (`l2_m1`) gains `@@: Lmx l2_out_throw` and the
  status locals (Emit's head classification) and, after the location `@: int l2_t4 l2_t3` and before the range-write
  check and the store, `if: l2_t4 = 0` → publish, `l2_out_throw[0]: 0`, `return: 4`; `write_null_caught` (`l2_m2`)
  gains the channel too, and its call of `l2_m1` passes status 4 to its block's handler where FE93 emitted the
  `invariant: a callable that cannot throw reported a status` abort; `read_null_raw` has its read guard as in
  no-candidate94; both trampolines pass and publish `l2_tt`. The forced `p.lm1` (FE93 already gives every method the
  channel there) gains only the two guards.

## Result

In build2 (not released), on FE94 + RT92 with stage92, FIXED: DRAFT79-OWNER-POINTER-CONTEXT-STACK-POINTEE (coherent92),
DRAFT79-BARE-RETURN-CHECKER (coherent89 Emit), SPLIT-POINTER-PLACE-NOT-ADMITTED (coherent92 Coords; its channel
coherent93), NATIVE-DEREF-RAISE-WITHOUT-STATUS-CHANNEL (coherent93) and NATIVE-RAW-DEREF-NULL-HOLDER-UNCHECKED
(coherent94): no-candidate95, no-candidate94, no-candidate79, held78, computed-absence79 and owner73c pass native and
forced. Not closed here: (b)'s used-closure witness through `lmx_graph_copy_many_used_staged` with all V63 checks (V63's
`lmx_graph_copy_owned` failure stays that stronger operation's); the raw index place and the deref-word route, left
unchanged; the unused `pc102_write` prototype (cause inferred, not traced); the line's bootstrap and its landing.

## Incidents

Two directory listings enumerated the protected basename `l2_driver_launch.err`: a `find` with `-name '*.err'` under
`no-candidate79-fe92-rt92-suite-01`, and an `ls` of `owner-values73c-hidden55-fe92-rt92-suite-01/lib_owner-native`
(filtered after the listing). It was never read, hashed or copied. Reported to Codex (THROWDEREF93 item 5).
During finalization a plain `git status --porcelain` (untracked files included) listed it at the repository root; it
was not read, hashed, copied or staged. The remaining checks use exact paths and `-uno`.

## Evidence and checks

[evidence.list](evidence.list) names the originals under P that these notes cite (Codex's answers and the questions,
the gdb command files and logs, the variants and working fixtures, the generator/candidate/chain/suite records with
their manifests and logs, the built tools and frontends, the stage outputs, the generated `p.lm1` and run logs);
`P/pins/docs247.command` computed [evidence.sha256](evidence.sha256) and verified it, and
`P/pins/docs247-check.command` ran the full docs check with the slice in the Git index — both with the promoted
working tool `7FD2E824…`. `records/` holds LF copies (trailing blanks removed). The `.diff` files are `diff -U0` of
the named files: the variants against their bases, the working fixtures against their bases, and the generated
`p.lm1` FE93 → FE94 under their P-relative paths.

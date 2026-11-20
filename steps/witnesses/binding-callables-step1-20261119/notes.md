# Binding and callables, step 1: the code against the norm of 2026-11-19

Written 2026-11-20 by Fable, the coordinator and the single writer of main. The map below is by the peer session
opus (2026-11-19, read-only work); the English text is a translation of its report by the peer session haiku. This
is step 1 of the plan `next_core_tasks_v3.md#binding-callables-20261119`: no code was changed and nothing was built.

What Fable checked:

- the translation against the report, by script: the headings, the table lines, the code blocks, every backticked
  span and every number are the same;
- the 59 probe programs, re-run on the interpreter of the working set (Graph `ps-graph-x105`, a7222f8e): every exit,
  observed value and message is equal to the delivered summary (`probes.tsv`);
- `graph-check` for three of the 15 native probes (`b02_free_write`, `b24b_inner_same_type`, `sel10`), re-run with
  the tool `ps-tool-x102`: PASS in interp, native and forced. The expected file of such a probe is the interpreter's
  own dump, so PASS means that the three modes observe the same, not that the probe conforms to the norm.

The line numbers in the map are those of the sources at `846c5363`; they were not re-checked one by one.

Result. Of the 61 rows -- B01-B27, C01-C19 and the 15 examples of section 9.8 of the TZ -- 31 already conform, 16
differ and 14 cannot be expressed today. The order of the code slices taken from this map is 4, 3, 2, 6, 5, 7
(section C): the place seen by slice 2 is set by slice 4; the filter of slice 3 goes into the function that slice 2
extends; slice 6 depends on slice 2 by one row; step 5 waits for the author's answer about the root of a unit
(`LMX_blog/q/current/unit-root-roles-20261119.md`). The cases D1-D6 are open: the map found no answer in the TZ; each
is derived from the norm or asked of the author before the rows it touches are pinned.

Files beside these notes:

- `probes.tsv`: the 59 programs -- exit, the observed value after the run, the message (`probes/out/SUMMARY.tsv` in
  the text below; an empty message is written `-`);
- `probes-native.tsv`: the 15 probes run through `graph-check` in the three modes (`probes/out/NATIVE.tsv` below).

The probe programs themselves (`probes/` in the text below) are receipts outside the repository:
`build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable/tz-20261119/step1`; Fable's
re-run is in `verify/` there.

## The report

Executor: opus, 2026-11-19, on the assignment of fable. Read-only work: nothing in the repository was changed.
Norm: `docs/new_parts/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md` (ed. 2, R01–R18), read in full.

Section letters: A, B, C, D, E stand for the Russian А, Б, В, Г, Д of the original report; cases D1-D6 are
the cases Г1-Г6.

**Which code was read.** `selfbuild/src` and `selfbuild/tools` in the working tree equal HEAD (`501733cb`),
except for someone else's edit to `selfbuild/tools/build.lm2` (slice "the refusal row compares the dump");
between `846c5363` (the stage `sol-m14-field-values-01` was built from it, manifest 1329 / 488665a5) and HEAD
the sources did not change — the commits after it are documents only. So the code that was read and the set
that was run are one version. I did not use the edit to `build.lm2`: `graph-check` ran with the accepted
`ps-tool-x102`, which does not compare the dump of the refusal row (see E).

**Two execution paths.**

- **The clean graph** — builder `l2_graph_build.lm2`, kernel `lmx_graph.lm2`, the interpreter and the shared
  binder `lmx_graph_run.lm2` (the native image calls its functions too), emitter `l2_graph_tool.lm2`. The rows
  of `tests/graph` run on it. The project itself is built on it only by three modules of route 331 —
  `lmx_clock`, `lmx_process_deadline`, `lmx_schedule` (`tools/build.lm2:3316–3323`); they are translated by
  `l2_frontend_graph.lm2`, which reads `fn:` as an executable method (`l2_frontend_graph.lm2:1260–1266`); in
  the three modules there are 15 root `fn:`.
- **The former path** — frontend `l2_frontend_*` (lower/emit/resolve/…) and walker `lmx_walk_values.lm2`. On it
  the other 69 modules of `selfbuild/src/l2src` and the whole tool are built. By the rule "one graph" it is
  removed, not repaired; it is described below briefly, just so that it is visible what holds up the self-build.

The words "by code, not run" mean: the conclusion was drawn by reading, without a probe.
All probes are in `probes/`, the outputs in `probes/out/`, the summary is `probes/out/SUMMARY.tsv`
(59 programs), the native runs are in `probes/out/NATIVE.tsv`.

## Main points

1. Today there is one implicit channel — the former fallback: a name without its own declaration gets a **copy**
   in the frame row of the callee (`lmx_graph_work_capture_context`, `lmx_graph_run.lm2:749`). There is no
   transparent place of the caller and no autofill of an empty formal.
2. Lookup order: `node` → the activation chain from the current one to the callers (frame rows, formals, the
   data of the launch) → the lexical levels of the graph (`lmx_graph_select_binding`, `:2372`). Dynamics comes
   before lexics.
3. `private` filters only the source in dynamics. A visible lexical `private` declaration of the callee does not
   stop dynamic lookup: the pinned row `private_binding` waits for `public_result 2121`; by R05 it should be 2110.
4. A nested declaration does not create shadowing: `int: x 9` in a nested block writes the outer place
   (`lmx_graph_work_site`, `:958`, branch `:976–983`); a declaration of another type is refused with answer 4.
5. `call(C)`, `C()`, R0 execute `C` over itself (`data := code`, `:6228`; R0 — `:5494`); `call(D C)` and `C(D)`
   substitute the data `D`; the special name `data` answers with the data of the launch, and for R0 — with the
   root itself.
6. `fn`/`sub` are executable declarations: each traversal creates a Structure of role FN with the parts `data`,
   `return`, `code` and copies the native pointer from the declaration (`lmx_graph_fn_make`, `:7882`, `:7937`).
7. Declaration selection implements the rule of 2026-11-18 "a signature with one argument opens nothing"
   (`:5790–5793`), which according to the documents has been replaced by the TZ; effectful actuals are computed
   before the shape is checked.
8. `catch`/`throw` is not executed by the clean graph at all; `catch` exists only in the former path.
9. The native image of the clean graph keeps places in the same kernel frame rows as the interpreter and resolves
   names with the same resolver at run time; there are no C locals for LMX variables. In all 15 native runs the
   dump of native and forced equals the dump of the interpreter.

## A. Map "mechanism → code"

### A1. Name binding

| What | Where | Path | What it does today |
|---|---|---|---|
| Source selection | `lmx_graph_run.lm2:2372` `lmx_graph_select_binding` | clean graph | 1) `node` → `lmx_graph_node_space` (`:2397`); 2) loop over the activations from the current one (`dynamic = 0`) to the callers (`dynamic = 1`): frame row `lmx_graph_input_row` (`:2403`), the special `data` of the current activation (`:2423`), formals of a native activation without a frame (`:2429–2442`), registry of the data of the launch (`:2448–2464`), namespace of data and methods (`:2465–2470`); 3) `data` of the root launched over itself (`:2476`); 4) lexical levels up via `parent`: rows of live activations of this lexical point (`:2495–2512`), registry of the fields of the level (`:2513–2528`), namespace (`:2529`), the `data` part of the callee (`:2533–2569`). |
| Own working copy (the former fallback) | `:749` `lmx_graph_work_capture_context`, `:287` `lmx_graph_work_snapshot` | clean graph | A name that the consumer takes as a place or reads (`lmx_graph_input_take`, `:884`) gets a frame row; the value is copied: int — a new cell; uninitialized — a new empty wrapper (`:322–331`); reference — a copy of the reference (`lmx_graph_reference_value`, `:241`). |
| Bare-name write | `:1469` `lmx_graph_place_name`, `:1582` `lmx_graph_place_store_int` | clean graph | Writes the frame row of the current activation; without a row — 3. The source does not change: probe `b02_free_write` → 509 (TZ: 909). The `const` check reads the record of the row's declaration (`:1515–1518`) — and for a copy this is the record of the source. |
| Write to the caller's place | — | — | None in any execution path of the clean graph. |
| Autofill of an empty formal | — | — | No. A formal without an actual gets a snapshot of its own declaration (`lmx_graph_work_open_row`, `:1288–1292`); probe `b01_autofill_read` → answer 5. |
| Chain A → B → C | `:2400–2473` | clean graph | The loop over activations reaches A if B does not hold the name: `dynamic_inputs` (`formal_value 12`), probe `b19_chain` → 506. There is no static accumulation: the body is not scanned on entry (`:1349`). |
| `var` | — | — | The word `var` is absent both in the clean graph (`w_var` is not interned) and in the former path (`LMX_ID_VAR`, `"var"` not found). |
| Former path | `lmx_walk_values.lm2:10138` `lmx_activation_resolve_input`, `:3947` `lmx_walk_entry_resolve`; frontend `l2_frontend_core.lm2:4917`, `l2_frontend_emit.lm2:16513` | former | The frontend marks hidden inputs of a method `LMX_WALK_VALUE_FREE`; on entry the callee first looks up the name in the root of its own data (`:10186`), then upward through the activation records (`:10188`), copies the value into its own input record and remembers the private flag (`:10199–10200`). |

Difference from the norm: R03 (autofill) and R04 (transparent place) are missing; R01, R02 (copy, variant A) and
R07 (chain) are present.

### A2. `private`

| What | Where | Path | What it does today |
|---|---|---|---|
| Reading the receiver's record | `lmx_graph_run.lm2:175` `lmx_graph_record_private`, `:183` `lmx_graph_field_private`, `:187` `lmx_graph_row_private` | clean graph | The mark is taken from the record `private:` in the graph through `lmx_graph_receiving_view` and `lmx_graph_record_mark`; the graph is not rewritten (B27). |
| Source side | `:132`, `:148`, `:159` (frame rows), `:733` (data fields), `:2025` (registry), `:658` (namespace), `:2431` (formals) | clean graph | When `dynamic != 0`, private rows and private fields are skipped and the search continues: `b17_skip_private_continue` → 1; without another source — 3 (`marks_code_dynamic_private`). |
| Receiver side | — | — | None. A visible lexical `private x = 7` of the callee is overridden by the dynamic `x = 11`: probe `b11_private_receiver` → 11; pinned `private_binding`: `public_result 2121`. |
| Lexics and the explicit path | the lexical part `:2492–2572` has no such filter | clean graph | Nested lexics and `S\x` read private: `private_binding` (`private_result 2110`, `library_source 10`). |
| Former path | `lmx_walk_values.lm2:10200` (`input_private`), `l2_frontend_context.lm2:611` `lm_compiler_own_dynamic_visible` | former | The private mark of the found source. |

### A3. Declarations and scopes

| What | Where | What it does today |
|---|---|---|
| Reached declaration | `lmx_graph_run.lm2:4256` `lmx_graph_block_declaration` → `:1526` `lmx_graph_place_site` → `:958` `lmx_graph_work_site` | Takes the visible row of this name from any enclosing scope of the frame (`:976–983`) — it does not create a new row in a nested scope. A new row only if there is no visible one (`:1003–1033`). The check of the kind of place (`:1049`) gives 4 for another type. |
| Visibility by scopes | `:117` `lmx_graph_work_row_scope` (bit 16), `lmx_graph_block` `:4214` (the bit of body rows is reset on entry and exit, `:4231–4247`) | Sequential visibility exists; the search goes from the inner scope to the outer one. |
| Repeat at the same level | the same `lmx_graph_work_site` | The same place; without a right-hand side the value is not reset: `b25_same_level_repeat` → 57. |
| Use before its own declaration | `:607` `lmx_graph_work_local_declared`, `:562` `lmx_graph_work_pending` | A future declaration does not close the outer source before its own row: `b26_before_own_decl` → 507. |
| Native image | `l2_graph_tool.lm2:1116` emits a call to the kernel's `lmx_graph_place_site` | The same behaviour (`b24b`, `b24c`, `ctl74` — native and forced equal the interpreter). |

Difference: R16 — a nested declaration does not shadow (probes `b24b_inner_same_type` → 9, `b24c_inner_read` → 99,
`b24_inner_other_type` → answer 4). Control §7.4: `ctl74_inline_new_local` → 5, but not by autofill, but because
there is no inner place (this is the outer place); Р106 expects `uninit:int`.

### A4. Call

| What | Where | Path | What it does today |
|---|---|---|---|
| Receiver forms | `lmx_graph_run.lm2:7990` `lmx_graph_receivers_open` (`:8026–8054`) | clean graph | `call`: [code], [data code], [args data code]; `fncall`: [return code], [data return code], [args data return code]; record `S(…)` (key `()`): [] and [data]; `fn`: [name args return data code], [name args return code], [name args return], [name parts]; `sub`: [name args data code], [name args code], [name parts]. |
| `call` | `:6134` `lmx_graph_eval_explicit_call`, `:6193` `lmx_graph_call_data`, `:6212` `lmx_graph_launch_value` | clean graph | Without data `data := code` (`:6228–6229`): `C` runs over itself (`c05b_self_data` → `data\y` = 1, the own `y` of `C`); [data code] substitutes the data (`c02_call_data_code` → `a=3`); [args data code] — `lmx_graph_launch`. `call` has no result: `call(f)` in a value → 2 (`c01c_call_value`). |
| `fncall` | `:6291` `lmx_graph_eval_fncall_value`; emitter `l2_graph_tool.lm2:869` | clean graph | A launch with a result by the description of `return`. |
| `S(D)`/`S()` | `:6012` `lmx_graph_eval_launch_record` | clean graph | `S()` — over itself; `S(D)` and `S(data := D)` — over `D` (`c02b_name_data` → `a=3`). |
| Call of a callable `f(…)` | `:5966` `lmx_graph_eval_application_value` → `:5062` `lmx_graph_eval_call_value` → `:4775` `lmx_graph_invoke_data_value` | clean graph | The data is the callee's own part `data` (`lmx_graph_method_data`), not `parent`; the body is the part `code`. |
| `parent` of an activation | `lmx_call.lm2:105–116` `lmx_activation_push` | shared | `record\parent` — the calling activation (dynamics). The lexical parent — `parent` of the code node; `node` — `lmx_graph_node_space` (`lmx_graph_run.lm2:2306`): for an ordinary Structure `code\parent`, for a callable — the block of its declaration. |
| R0 | `:5512` `lmx_graph_call`, `:5474` `lmx_graph_run` (`:5494` `lmx_graph_work_open_data(g, root, root, …)`); emitter `l2_graph_tool.lm2:1803` (`lm_graph_body` opens a frame with the data `owner`) | clean graph | R0 — launch of the root over itself: data = root = code. `data` of the root answers with the root (`:2476`): `c05_root_data` → `v=5`. On this rests the observation technique `@: shared data[0]` in 310 programs of `tests/graph`. |
| Former path | `lmx_walk_values.lm2:6374` `lmx_walk_select_call_in`, `:8102–8148`; `l2_frontend_lower.lm2:7760`, `:18593` | former | `call(D C)` evaluates `D` first and substitutes it as the data; `call(C) = call(C C)` (`lmx_walk_values.lm2:4134`, `:9612`). |

Difference: R09 (data = `parent(C)`), R10 (R0 without data), R12 (`call(A C)` = args), and the result of
`call`/Structure.

### A5. The special name `data`

| Place | What is done |
|---|---|
| `l2_graph_build.lm2:966` (builder) | A frame with the head `data` and the trailer `end:` counts as a data block, not as a receiver call. |
| `lmx_graph.lm2:112`, `:211`, `:277` (kernel) | `data` — a word of the language in the list of receivers; it is interned in the state. |
| `lmx_graph.lm2:778–796` (kernel) | `lmx_graph_method` requires the parts `data` and `code`; `lmx_graph_method_data` — the part with the name `data`. |
| `lmx_graph.lm2:2032` (kernel) | `lmx_graph_code_uses` skips the field with the name `data`. |
| `lmx_graph_run.lm2:2423` (interpreter) | `data` in the current activation without a row of this name — the data of the frame. An ordinary place named `data` wins (the row is searched first): `c16b_data_own` → 4. A free `data` in the callee gives its data, not the place of the caller: `c16_data_free` → answer 4. |
| `lmx_graph_run.lm2:2476` | `data` of the root launched over itself is the root. |
| `lmx_graph_run.lm2:6170`, `:6339`, `:8042–8054` | A formal `data` of `call`, `fncall`, the record `S(…)`. |
| `lmx_graph_run.lm2:7774`, `:8549–8563` | The part `data` of the callee from `fn`/`sub`. |
| `l2_graph_tool.lm2:838`, `:925` (emitter) | A formal `data` of `call`/`fncall` in the native image. |
| Former path | `lmx_walk_values.lm2:10179` (reserved reference `data`, code `LMX_ID_DATA`), `l2_frontend_context.lm2:788`, `l2_frontend_lower.lm2:2871`, `l2_frontend_resolve.lm2:2267`, `l2_frontend_values.lm2:1695`, `l2_frontend_emit.lm2:17129`. |

### A6. `fn`, `sub`, signature, `implements`, `return`

- Creation: `lmx_graph_space_declare` (`lmx_graph_run.lm2:8651`, on entry to a block) or `lmx_graph_fn_apply`
  (`:8739`, where the traversal reached the record) → `lmx_graph_receiver_bind` → `lmx_graph_receiver_make`
  (`:8515`) → `lmx_graph_fn_make` (`:7882`). What results is a Structure of role FN; its `parent` is the record
  `fn:`/`sub:`. Fields: `data` (a copy of the header and of the recorded data, `lmx_graph_fn_data`, `:7717`),
  `return` (only for `fn`: a word or a reference), `code` (a reference to the body); `made\native := decl\native`
  (`:7937`). Each traversal creates it anew.
- The signature lies in the part `data` (the formals in the recorded order, with declarations under modifiers —
  `lmx_graph_formal_width`, `:1154`) and in the part `return` (`lmx_graph_method_return`, `lmx_graph.lm2:802`).
  `sub` is `fn` without a result. The form of `fn` without `code` ([name args return], `:8030`) gives a callable
  without a body (`:1961–1963`), but with a name and in the namespace — this is not a data template from TZ §8.1.
- `implements` in the clean graph: admission of an actual by a formal — `lmx_graph_admit` (`:4072`),
  `lmx_graph_admit_value` (`:4078`): an int formal reads an int; a formal with a model is checked by the first
  part of `implements` over the used paths (`lmx_graph_admit_paths`, `:3986`, `:3952`) and
  `lmx_graph_source_interface` (`:3657`) → `lmx_implements_source_interface`. A comparison of the callable with
  the signature requirement does not exist in the clean graph. In the library there is a directed check
  `lmx_implements_call_takes` (`lmx_implements.lm2:2887`, "not equality of signatures", `:1938`), which is called
  only by `lmx_implements_place_callable` (`:7671`) — a write to the callable place of the former path.
- `return`: the result is declared in the third position of the header `fn: name (args) int`; in the frame it is
  `frame\result` (`lmx_graph_run.lm2:1328`); `return: value` — `lmx_graph_return_value` (`:4200`) →
  `lmx_graph_result_receive`; the end of a body without `return` in a launch with a result gives 5
  (`:4766–4769`), that is, `return` is not synthesized (as §8.4). The builder appends a `return` recorded at the
  opening level as a trailer at the end of the body (`l2_graph_build.lm2:399–452`). An ordinary Structure in a
  value gives 5 (`:5986`; `c14_struct_return`).
- Difference: R11, R13, R14 (fn — a data template, `return` — a data field, `sub` removed).

### A7. Declaration selection

- Candidates: `lmx_graph_call_candidates` (`lmx_graph_run.lm2:5625`) — all `fn`/`sub` of the name in the nearest
  block and outward.
- If there is one candidate and no single Structure argument — the former path `lmx_graph_eval_call_value`
  (`lmx_graph_eval_selected` answers −1, `:5940–5942`): binding `lmx_graph_bind_formals` (`:2834`, `required` —
  `:2893`) before evaluation, then the actuals in order.
- Otherwise selection: `lmx_graph_select_actuals` (`:5678`) — **all effectful actuals are computed before the
  shape is checked** (`:5684–5690`); `lmx_graph_pair_written` (`:5706`) — W; `lmx_graph_pair_opened` (`:5767`) —
  E; rule R89: "if a candidate accepted a Structure as written and its one field would take the same formal —
  E is not built" (`:5790–5793`); `lmx_graph_select_call` (`:5818`) — the count of admitted pairs, more than one —
  3. There is no preference by arity.
- Execution of the selected one: `lmx_graph_call_selected` (`:5883`): for W the pair is built anew (the pure
  actuals are read a second time); for E — `lmx_graph_call_single_record` (`:4956`), which matches the fields
  anew and, on failure, passes the Structure as the first argument (`:5024–5031`).
- Receivers of `call`/`fncall`: `lmx_graph_receiver_reading` (`:6110`), `lmx_graph_receiver_opened` (`:6069`, a
  Structure of one field is not opened — `:6088`); both readings — 3.
- The native image hands the selection over to the interpreter (`l2_graph_tool.lm2:2632`
  `lm_graph_emit_selected_call`).
- During selection the effectful actuals are executed (`c11_multi`: `ticks 1` on a refused shape); with one
  candidate they are not (`c11_single`: `ticks 0`).

### A8. `catch`

- Clean graph: there is no execution. `catch`, `throw`, `throws` are only in the word list (`lmx_graph.lm2:112`);
  in `lmx_graph_run.lm2` there is no branch (the search for `w_catch|w_throw` is empty); probe `c15_catch` →
  answer 3; in `tests/graph` there are no rows with `catch`.
- Former path: the frontend finds and checks the handlers (`l2_frontend_context.lm2:1501`,
  `l2_frontend_helpers.lm2:1994–2042`, `l2_frontend_emit.lm2:3929`, `:3987`, `:9781`); the walker puts the payload
  into the cells of the landing pad by position (`lmx_walk_values.lm2:5054` `lmx_walk_catch_bind`, fields of the
  pad from the second one). I did not study it in more detail.

### A9. Native code and the interpreter

- The place in the interpreter is a frame row of `LmxGraphWork` (name, lexical scope, position in the data, arena
  cell, number cache, `LmxWalkValue` record, `loaded` bits: 1 — value present, 2 — visible to the callee, 4 —
  deferral allowed, 8 — admitted on entry, 16 — visible in the scope, 32 — supplied as an actual, 64 — being
  computed; `:783–790`, `:1286`, `:431`). **The initialization state is bit 1 of the row, not of the cell**
  (`:455`, `:1621`): two rows over one cell can have different states.
- Native image: the method `lm_graph_method%d` opens the same kernel frame `lmx_graph_work_open_data`
  (`l2_graph_tool.lm2:1722`); the name is read at run time by `lmx_graph_operand_name` (`:521–525`), `@x` —
  `lmx_graph_input_take` + `lmx_graph_resolve` (`:489–500`), a declaration — `lmx_graph_place_site` (`:1116`).
  C locals are emitted only for intermediate values (`l2_vN`, `l2_tN`).
- Call: the emitted code → `lmx_graph_invoke_values` (`:363`) → `lmx_graph_invoke_data_value`; if
  `code\native != 0` — `lmx_call_prim_values` (the native entry), otherwise an activation and the interpreter
  (`lmx_graph_run.lm2:4870–4892`). Combinations: native→native — through this kernel boundary; there is no direct
  C call; native→interpreter — the callee without a native entry (an ordinary Structure, a callee from
  `fn_apply`); interpreter→native — in the native image, when an interpreted Structure calls a `fn` with an entry;
  interpreter→interpreter — forced mode (`l2_graph_tool.lm2:1798`, methods are not set, `:1774`) and the command
  `run`. Since the place in all four is one frame row of the kernel, the behaviour is one (15 native runs,
  section E).
- The native pointer lies in the node header (`code\native`, `made\native`, emission of `l2_method\native`,
  `l2_graph_tool.lm2:1713`) — it diverges from the final check of the plan, item 4; this is an open item of the
  plan, not of the TZ.
- Forbidden by §11–12: there is no copy on output (a write goes straight into the cell of the row); there is no
  publication (`lmx_graph_run.lm2:1312–1314`); there are no caches of links between traversals (`:2370–2371`);
  there is no hidden compilation (without an entry — the interpreter).

### A10. Scale in the sources of the kernel and the tool

| Directory | Files | Root `fn:` | Root `sub:` | `fncall` | `call(…)` | `data\…` |
|---|---|---|---|---|---|---|
| `selfbuild/src/l2src` | 72 | 4899 | 158 | 20 lines, all comments or the kernel's word | 10 lines, all comments | 24 lines, not one form of the language |
| `selfbuild/tools` | 37 | 371 | 2 | 0 | 0 | 20 lines, not one form of the language |

- Root `fn:` are most numerous in `l2_frontend_lower.lm2` (608), `l2_frontend_core.lm2` (512), `l2_frontend_emit.lm2`
  (407), `lmx_walk_values.lm2` (283), `lmx_graph_run.lm2` (261). Examples: `l2_frontend_context.lm2:611`
  `fn: lm_compiler_own_dynamic_visible (int: mi; const: (@: t c.LmP0Text)) int`; `lmx_graph_run.lm2:7882`
  `fn: lmx_graph_fn_make (…) int`; `lmx_call.lm2:105` `fn: lmx_activation_push (…) int`.
- `sub:`: `l1_backend_state_helpers.lm2:1257` `sub: l1_imp_pop ()`, `:1269` `sub: l1_imp_reset ()`,
  `l1_backend_text.lm2:1042` `sub: l1_path_text_delete (@: text c.LmP0Text)`, `lmx_graph_run.lm2:4309`
  `sub: lmx_graph_place_declared (…)`.
- `fncall`: `lmx_graph.lm2:254` (interning), `lmx_graph_run.lm2:6285–6287` (comment on the forms),
  `l2_graph_tool.lm2:862`, `lmx_walk_values.lm2:7783` — there are no uses of the form.
- `call(`: `l2_frontend_lower.lm2:7760`, `:18593`, `lmx_graph_run.lm2:2283`, `lmx_walk_values.lm2:4134`,
  `:5946` — all comments.
- `data\…`: `l2_driver.lm2:792` `data\native := word`, `l2_receiving_source.lm2:15` `data\atom = word`,
  `lmx_implements.lm2:4678` `data\array` — ordinary L2 variables named `data`.
- For step 8 the more significant one is `tests/graph` (537 programs in the working tree: 533 in HEAD and 4
  untracked): 496 with a root `sub:`/`fn:`, 310 with `data[` (the technique `@: shared data[0]`), 169 with `data\`
  (707 lines), 67 with `call(` (115 lines), 16 with `fncall` (44 lines), 1 with `catch` (a comment).

## B. Table of acceptance rows

Probes were run by the interpreter: `graph_trans-prod.exe 0 entry 0 -- run probes/NAME.lm3`; the answer is the exit
code and the line `graph: run answered N`; the values are the `Observed` block of the dump after the launch
(`probes/out/SUMMARY.tsv`). "Three modes" — `graph-check` of the same probe in interp/native/forced, with the dump
of the interpreter as the expectation (`probes/out/NATIVE.tsv`). The TZ entry for a probe is given in the probe's
header.

### B1. B01–B27

| ID | TZ requirement | State | Basis |
|---|---|---|---|
| B01 | An empty declaration gets autofill; a write of 9 does not change the caller's 5 | differs: no autofill, reading an empty formal is refused | `b01_autofill_read` → answer 5 (three modes); `b01_autofill_write` → 509 (the write goes to its own place, as in the TZ) |
| B02 | Without its own declaration a write changes the caller's `x` to 9 | differs: a copy is written, the caller stays 5 | `b02_free_write` → 509 (three modes); `dynamic_inputs`: `unchanged 5` |
| B03 | Former fallback: the copy changes, the source stays 5 | already conforms | `b02_free_write` → 509 |
| B04 | One type T in B01–B03 | not expressible today: there is no autofill and no transparent place | By code, not run: the copy of B03 is a cell of the type of the source (`lmx_graph_work_snapshot`, `:287`) |
| B05 | `@x`: B01/B03 — own place, B02 — the caller's place | not expressible today (B02) | `dynamic_inputs`: `local_address 7` — `@x` of the copy; for B02 there is no place |
| B06 | Reference: a transparent place changes the caller's reference, a copy does not | not expressible today | By code, not run: the copy of the reference `lmx_graph_reference_value` (`:241`) |
| B07 | A caller without a value sees 9 and initialized | differs: the caller stays without a value | `b07_uninit_caller` → answer 5 |
| B08 | The write of B02 is visible at once, no copy-out | not expressible today | There is no transparent place |
| B09 | A private source does not give autofill | not expressible today: there is no autofill | By code; skipping a private source for a copy is present (`:132`) |
| B10 | A private source is skipped by all implicit channels | already conforms (for the single channel — copies) | `marks_code_dynamic_private` → answer 3; `private_binding`: `private_result 2110` |
| B11 | A visible lexical private 7, the caller 11 → 7 | differs: 11 | `b11_private_receiver` → 11 (three modes); `private_binding` is pinned at `public_result 2121` |
| B12 | A private formal is empty, the caller 11 → without a value | not expressible today: no autofill; the outcome matches | `b12_private_formal_empty` → answer 5 |
| B13 | An explicit passing from a private place is allowed | already conforms | `b13_private_source_explicit` → 5 |
| B14 | A private formal explicitly gets 20 | already conforms | `b14_private_formal_explicit` → 20 |
| B15 | Nested lexics and the explicit path read private | already conforms | `private_binding`: `private_result 2110`, `library_source 10` |
| B16 | One's own `x` shadows an outer private | already conforms | `b16_inner_shadows_private` → 3 |
| B17 | The near private is skipped, the far one is found | already conforms | `b17_skip_private_continue` → 1 (three modes) |
| B18 | A write to const through a transparent place or a path is refused | already conforms for the path; there is no transparent place | `b18_const_path` → answer 4; `b18_const_free_write` → answer 4 (the copy inherits const — see D1) |
| B19 | A → B → C: reachability; the copy of C does not write to A | already conforms | `b19_chain` → 506 |
| B20 | B's own copy (autofill), C changes B.x, A.x is intact | not expressible today: B has no copies through autofill | `b20_copy_in_b` → answer 5 |
| B21 | B is linked to A.x, C writes A.x | differs: each writes its own copy | `b21_chain_free` → 50509, per the TZ 90909 (three modes) |
| B22 | One's own default is not replaced by the caller's local | already conforms | `b22_default` → 703 |
| B23 | A computed default is not executed by the entry pass, nor in place of the actual | already conforms | `b23_computed_default` → `ticks 0 seen 3 unused 1` |
| B24 | An inner declaration of another type is its own place | differs: refusal | `b24_inner_other_type` → answer 4; the same type: `b24b` → 9, `b24c` → 99 (three modes) |
| B25 | A repeat without RHS: the same cell, without zeroing | already conforms | `b25_same_level_repeat` → 57 |
| B26 | A use before its own declaration — outer resolution | already conforms | `b26_before_own_decl` → 507 |
| B27 | The graph keeps private/required as written | already conforms | Dump of `private_binding` before and after: `private: ((int x 10))` |

Control §7.4 (a separate row, not counted in the total): **differs** — `ctl74_inline_new_local` → 5 in all three
modes, because there is no inner place (`b24c` → 99); by Р106 it should be `uninit:int`.

### B2. C01–C19

| ID | TZ requirement | State | Basis |
|---|---|---|---|
| C01 | The direct form and `call` with the same actuals coincide in everything | differs: `call` has no result | `c01_direct_and_call` → `count 2`; `c01b_call_data` → `count 6` (the data `g` are the same); `c01c_call_value` → answer 2 |
| C02 | `call(D C)`: D is args | differs: D is substituted as data | `c02_call_data_code` → `a=3` (three modes); `c02b_name_data` → `a=3` |
| C03 | Two occurrences with a shared native implementation take their own data | not expressible today: one native method per declaration; the data — its own copy of the part `data` | By code: `l2_graph_tool.lm2:1711–1713`, `lmx_graph_fn_data` `:7717` |
| C04 | `NewContainer: ExistingCode` does not change the parent | already conforms | `c04_colon_declares`: in the dump `New (H \ Existing)` is the path, `Existing` is in `H` |
| C05 | R0 without data | differs: R0 over itself | `c05_root_data` → `v=5` (three modes); `lmx_graph_run.lm2:5494`, `:2476` |
| C06 | `fn` with return and without — templates | not expressible today | `fn` — an executable declaration with a name (A6) |
| C07 | `sumPtr` per §8.3 | not expressible today | There is no `@:` with the requirement `fn(…)`; `implements` of a callable is absent in the clean graph (A6) |
| C08 | All examples of §9.8 | differs: No. 6 and No. 10 | Table B3 |
| C09 | W is chosen — the whole Structure | already conforms | `sel07` → 34 |
| C10 | E is chosen — the selected map without repeated opening | already conforms by observation; by code the map is built anew | `sel08` → 9, `sel09` → 34; `lmx_graph_call_single_record` `:4956` |
| C11 | An impossible passing of actuals is refused before the effect | differs with two declarations | `c11_single` → `ticks 0`; `c11_multi` → `ticks 1` (native and forced: `ticks 1`) |
| C12 | A refusal of admission: the next actuals and the body are not executed | differs with two declarations | `c12_single` → `ticks 1`; `c12_multi` → `ticks 2` (native and forced: `ticks 2`) |
| C13 | An assignment in an actual expression | not expressible today | `c13_assign_in_actual` → answer 2 |
| C14 | A Structure with return in an expression | differs: refusal | `c14_struct_return` → answer 5; `call(f)` in a value → 2 |
| C15 | catch with the former semantics | not expressible today in the clean graph | `c15_catch` → answer 3; A8 |
| C16 | `node` built in, `data` ordinary | differs: `data` is special | `c16_data_free` → answer 4; `c16b_data_own` → 4; `node_vs_dynamic` → 2510 |
| C17 | The adapter keeps the mode of the place | not expressible today: there are no place modes | A9 |
| C18 | Without a native entry — the existing path, without hidden compilation | already conforms | By code `:4870–4892`; `c02_call_data_code` in native: an ordinary Structure is run by the interpreter, the dump is equal |
| C19 | Copy/merge keep parent and records; a stack address is not portable | already conforms — by code, not run | The places are arena cells, there are no C locals (A9); copies carry parent and names (`lmx_graph_copy_with_names`, `:265`). The weakest basis in the table |

### B3. Examples of §9.8

| No. | Requirement | State | Basis |
|---|---|---|---|
| 1 | `f(int a)`, `f(int a; int b)`, `f(5)` → error | already conforms | `sel01` → answer 3 |
| 2 | required b, b of the caller, `f(5)` → the first | already conforms | `sel02` → 1 |
| 3 | the same, `f(5; 6)` → the second | already conforms | `sel03` → 2 |
| 4 | only `f(required b)`, `f()` → no variant | already conforms | `sel04` → answer 5 |
| 5 | `f(required b = 9)`, `f()` → default | already conforms | `sel05` → 9 |
| 6 | `f(a; b)`, b of the caller, `f(5)` → autofill of b | differs: b without a value | `sel06` → answer 5 |
| 7 | W as a whole | already conforms | `sel07` → 34 |
| 8 | `h(int x)`, `Arg(int: x 9)` → 9 | already conforms | `sel08` → 9 |
| 9 | E, the selected fields | already conforms | `sel09` → 34 |
| 10 | W and E of one declaration → error | differs: one variant (rule R89) | `sel10` → 1 (three modes); `:5790–5793` |
| 11 | W for one, E for another → error | already conforms | `sel11` → answer 3 |
| 12 | `f(a := S)` → only W | already conforms | `sel12` → 1 |
| 13 | the whole C — one form of `call`, the fields — another → error | already conforms (the fields are taken by today's form [data code]) | `sel13` → answer 3 |
| 14 | `call(code := C)` is not opened | already conforms | `sel14` → `r 1` |
| 15 | `fn(…)` with a nested Structure — the data role | not expressible today | There is no template `fn(…)`; the arguments of `fn` are not opened today either: `lmx_graph_receiver_reading` is called only for `call` and `fncall` (`:6157`, `:6314`) — by code |

### Summary of the table

| Group | already conforms | differs | not expressible today |
|---|---|---|---|
| B01–B27 | 14 | 6 | 7 |
| C01–C19 | 5 | 8 | 6 |
| §9.8 | 12 | 2 | 1 |
| Total (61) | 31 | 16 | 14 |

## C. Split of steps 2–7 into slices

Build — by the table `to_fable2_fast_build.md`: a change of `lmx_graph.lm2`/`lmx_graph_run.lm2` → `build-runtime`,
then `build-graph` (a new `driver.o`); a change of `l2_graph_build.lm2`/`l2_graph_tool.lm2` → `build-graph`; new
exports of the kernel → a change of `tools/build.lm2` → `build-self` first. `build-frontend-host` is needed if the
translation of route 331 changes (`l2_frontend_graph.lm2` or its output for the three modules). The minimal
examples are the probes of this step; the expectations in them come from the TZ; re-pinning existing rows — only
by the norm and with a named reason.

**Proposed order: 4 → 3 → 2 → 6 → 5 → 7.** Reasons: slice 2 chooses "the visible place of the caller" — which
place is visible is set by slice 4 (today the outer row becomes visible instead of the inner one); the receiver
filter of slice 3 goes into the same `lmx_graph_select_binding` as the new channel of slice 2, and it is easier to
put it first on one existing channel; slice 6 depends on slice 2 only through row No. 6; step 5 waits for the
author's answer about the root of the unit.

### Slice 4 (step 4): nested declaration — a new place

- What changes: `lmx_graph_work_site` (`lmx_graph_run.lm2:958`): reuse a row only from the same lexical scope
  (`row\scope = frame\lexical_scope`) or the data place when `holder = frame\data`; otherwise a new row in the
  current scope. The search from the inner scope (`lmx_graph_work_row_scope`) and the reset of visibility on
  leaving a block (`lmx_graph_block`, `:4231–4247`) already exist. The emitter emits the kernel's
  `lmx_graph_place_site` (`l2_graph_tool.lm2:1116`) — no edit is needed (to be checked by emission).
- Build: `build-runtime` → `build-graph`.
- Example: `b24b_inner_same_type` (5), `b24c_inner_read` (95), `b24_inner_other_type` (5), `ctl74_inline_new_local`
  (by Р106 — refusal on reading, answer 5), `b25`, `b26` unchanged.
- Small list: `scan_*`, `computed_body_*`, `declaration_site_*`, `marks_*_code*`, `dynamic_inputs`, `literal_line`.
- Closes: B24, control §7.4 (fixture by Р106); B25, B26 stay green.
- Depends on: nothing; if the author reads §7.4 otherwise (5) — one fixture changes.
- Removal in the same slice: the branch that reuses the outer row (`:976–983`).
- D5 (a repeat at the same level with another type) is not decided here: the slice keeps today's refusal.

### Slice 3 (step 3): `private` on the receiver side

- What changes: `lmx_graph_select_binding` (`:2372`): before taking the source from the calling activation
  (`dynamic != 0`), find the visible lexical declaration (the same lexical part `:2492–2572`, without `prepare`)
  and, if it is private (`lmx_graph_record_private` by its record), take the lexics; the same condition in
  `lmx_graph_work_capture_context` (`:812`).
- Build: `build-runtime` → `build-graph`.
- Example: `b11_private_receiver` (7). The pinned `private_binding`: `public_result` 2121 → 2110 by R05 — the
  reason is to be recorded in the slice.
- Small list: `private_binding`, `private_data_write`, `private_path_write`, `construction_private_ref`,
  `marks_*_dynamic_*`, `node_vs_dynamic`, `dynamic_inputs`.
- Closes: B11; B10, B13–B17 stay green.
- Depends on: nothing.

### Slice 2 (step 2): the caller's place and autofill

- Transparent place: in `lmx_graph_work_capture_context` (`:749`) for a name without its own active declaration,
  if the **directly calling** activation has a visible non-private row of this name (its own place, its own copy,
  or its own link), the row of the callee becomes a link to this row, not a snapshot; otherwise — today's copy
  along the chain. Reading, `x :=` (`lmx_graph_place_name`, `:1469`; `lmx_graph_place_store_int`, `:1582`;
  `lmx_graph_place_store_reference`, `:1636`) and `@x` (`:489–500` of the emitter through `lmx_graph_resolve`)
  go to the cell of the owner; `const` of the owner is checked (`:1515`).
- State of initialization: today it is bit 1 of the row (`:455`, `:1621`), not of the cell. For B07 the link must
  read and set the state of the owner's row (or the state is moved to the place) — an implementation decision; do
  not keep a `row\number` cache in the link.
- Autofill: in `lmx_graph_work_open_row` (`:1246`) a formal without an actual and without an initializer (kinds 3,
  8, 9) gets a copy of the value of the visible non-private row of the caller, if the formal itself is not private.
  This happens after selection (selection comes before `lmx_graph_invoke_*`), so it does not take part in the
  selection.
- Build: `build-runtime` → `build-graph`.
- Example: `b01_autofill_read` (5), `b01_autofill_write` (509), `b02_free_write` (909), `b07_uninit_caller` (909),
  `b21_chain_free` (90909), `b20_copy_in_b` (50909), `b19_chain` (506 unchanged), `sel06` (56, together with
  slice 6); new fixtures B05, B06, B08 with reference variables.
- Small list: `dynamic_inputs`, `node_vs_dynamic`, `caller_data_dynamic`, `computed_body_dynamic`,
  `computed_body_fallback`, `scan_free_name_*`, `marks_*_dynamic_*`, `private_binding`.
- Closes: B01–B08, B12, B18 (transparent part), B20, B21; No. 6 §9.8.
- Depends on: slices 4 and 3; for calls from the root (`dynamic_inputs`: `local()` is called in the root) — on the
  author's answer about the root of the unit: the place of the root `int: x 5` is the place of the R0 activation
  (then a transparent channel) or a field of the root in the graph (then lexics). Answers D1–D4 are needed before
  the corresponding rows are pinned.

### Slice 6 (step 6): W/E are equal, the shape before the effects, execution of the selected map

- What changes: remove rule R89 — `same` in `lmx_graph_select_call`/`lmx_graph_pair_opened` (`:5821`,
  `:5853–5855`, `:5790–5793`) and `n < 2` in `lmx_graph_receiver_opened` (`:6088`); `lmx_graph_select_actuals`
  (`:5678`): first the shape stage (`lmx_graph_bind_formals` and `lmx_graph_bind_fields` for each pair), then the
  effectful actuals in order, each one accepted by the remaining pairs before the next one; if no pair remains —
  stop; `lmx_graph_call_selected` (`:5883`) executes the saved map instead of `lmx_graph_call_single_record` with
  re-binding and the switch to "the first argument" (`:5024–5031`).
- Build: `build-runtime` → `build-graph`; the emitter (`lm_graph_emit_selected_call`, `:2632`) still hands the
  selection to the interpreter.
- Example: `sel10` (answer 3), `c11_multi` (`ticks 0`), `c12_multi` (`ticks 1`), `sel01`–`sel14` unchanged.
- Re-pinning by the norm: `declsel_c11`, `declsel_c12` are pinned as "`call(C)` for C from one field-Structure
  executes C as it is" by R89. By TZ §9.3 and §9.5, for such C, W gives `call(code := C)`, E gives
  `call(code := Inner)`; both pairs of one form are admitted — an ambiguity error. This is a consequence of the
  general TZ rule, not a new question; when re-pinning, name the reason.
- Small list: `declsel_*`, `receiving_whole_read`, `receiving_whole_read_list`, `receiving_group_roles`,
  `callable_part_names*`.
- Closes: C08 (No. 10; No. 6 — with slice 2), C10, C11, C12.
- Depends on: slice 2 only through row No. 6.

### Step 5: structural call — four slices, all after the answer to the author

- **5a. Forms of `call` and data = `parent(C)`.** `lmx_graph_receivers_open` (`:8040–8054`): `call` [code],
  [args code]; remove [data code], [args data code] and [data] of the record `S(…)`; `lmx_graph_launch_value`
  (`:6228`): the data is `parent(C)`; `lmx_graph_eval_launch_record` (`:6012`) — `S(args)` by the common call; the
  result of `call` and of an ordinary Structure by the field `return` (`:5986`); emitter
  `lm_graph_emit_explicit_call` (`:797`). Build: `build-runtime` → `build-graph`. Example: `c02_call_data_code`
  (refusal), `c05b_self_data`, `c14_struct_return` (4), `c01c_call_value` (4). Closes C01, C02, C14. It depends on
  the question about the root: "the own records of the executed C are read in the role of code" concerns any `C`,
  not only the root.
- **5b. R0 without data.** `lmx_graph_run` (`:5494`), `lmx_graph_call` (`:5512`), `lm_graph_body`
  (`l2_graph_tool.lm2:1803`), `data` of the root (`:2476`). Closes C05. Migration: 310 programs with
  `@: shared data[0]`, 359 with `sub: main`. Entirely depends on the answer to the author.
- **5c. Remove the special `data`, `fncall`, `sub`.** The places of item A5, `lmx_graph_eval_fncall*`
  (`:6291–6364`), `lm_graph_emit_fncall` (`l2_graph_tool.lm2:869`), the branches `w_sub` (`lmx_graph_work_pending`,
  `lmx_graph_binding_method`, `lmx_graph_fn_decl_name`, `lm_graph_collect_methods`, `:1677`), the words in
  `lmx_graph.lm2:112`, the exception of the builder `l2_graph_build.lm2:966`. Closes C16. Migration: 16 programs
  with `fncall`, 169 with `data\`. The former path is not touched.
- **5d. `fn` — a template, `return` in the data.** `lmx_graph_fn_make`, `lmx_graph_receiver_make`, the forms of
  `fn`. It touches the self-build: route 331 reads `fn:` of the three modules as methods
  (`l2_frontend_graph.lm2:1260–1266`). So the slice also translates these three modules (15 `fn`) and
  `l2_frontend_graph.lm2` → `build-frontend-host`, and a change of the self-build chain is the basis for a full
  self-build at the border. Closes C06, No. 15 §9.8.
- **5e. `implements` of the callable (C07).** The form `@: p fn(…) X` and the check of the candidate against the
  requirement with account of `parent` — in the library `lmx_implements.lm2` (`lmx_implements_call_takes`,
  `:2887`, now for the former path). The ABI of the library changes → `tools/build.lm2`, `build-self`, a full
  self-build at the border. Depends on 5d.
- In the slices of step 5, make the consistent removals: the forms `fncall`, [data code], [args data code],
  [data]; the `sub` branches; the special `data`; the executable `fn`. The former path is not touched: the project
  is built on it.

### Step 7

- **7a. `catch` in the clean graph.** It is absent there altogether (A8), so this is not an "adaptation" but the
  first implementation of `throw`, `catch`, `throws` in the interpreter and the emitter, per §15 of the book and
  §10.2 of the TZ. Closes C15. Independent of 2–6; the size is large.
- **7b. Variants of native entries.** Not needed today: the native image holds places in the frame rows of the
  kernel (A9), the place mode is decided by the kernel at run time; C17 is closed by slice 2 by construction. A
  direct native→native call (§11.1) does not exist today — there is nothing to keep; introducing it is a separate
  optimization, not this step. The native pointer in the node header is an item of the plan "Native descriptors
  and call tables", not of the TZ.

### What can be prepared in parallel outside the tree

- Independent by code: slice 4 (`lmx_graph_work_site`, `lmx_graph_block`), slice 3 (`lmx_graph_select_binding`,
  `lmx_graph_work_capture_context` — the filter), slice 6 (selection, `:5625–6125`), slice 7a (new branches).
- Slices 3 and 2 edit the same functions — 2 is prepared after 3 or on top of its diff.
- Step 5 can be described in advance (the inventory of places — item A5, migration of the tests), but not pinned
  before the answer to the author.

## D. What the TZ does not define, and what the code will force to decide

Only cases with a program and observable variants; no decision is given. The question about the root of the unit
is already with the author (`LMX_blog/q/current/unit-root-roles-20261119.md`) and is not repeated here.

**D1. May the copy of the fallback be written if the source is `const`.** TZ §6.3: "Bare assignment changes this
working copy"; R06: "Write restrictions, including the applicable const/immutable, are preserved"; B18 speaks only
of a transparent place and the explicit path. Program (`probes/g01_const_fallback_chain.lm3`):

```text
fn: c () int
    x := 6
    return: x
fn: b () int
    return: c()
fn: a () int
    const: int: x 5
    int: r b()
    return: x * 100 + r
```

B does not hold `x`; C has a copy of the former fallback. Variants: (a) the write is refused, answer 4 — as it is
today: the copy keeps the record of the source's declaration (`lmx_graph_run.lm2:1515`); (b) the copy accepts 6,
`a()` = 506.

**D2. Does autofill search beyond the immediate caller.** R03 and §6.1 item 3: "from the allowed local context of
the caller"; §5.3: after a private source "the permitted search continues"; §6.1, last paragraph: the former
mechanism does not extend to omitted formals.

```text
fn: c (int: x) int
    return: x
fn: b () int
    private: int: x 2
    return: c()
fn: a () int
    int: x 1
    return: b()
```

Variants for `a()`: (a) 1 — the search goes to A; (b) `x` of C has no value, and reading is refused. The same
question arises if B has no `x` at all.

**D3. Autofill from a place of another type.** A formal `int: x`; at the caller `x` is a reference or a Structure.

```text
fn: callee (int: x) int
    return: 1
fn: caller () int
    int: y 7
    @: x int @y
    return: callee()
```

Variants: (a) the call is refused, as an explicit actual of such a type would be refused; (b) autofill does not
happen, `x` has no value, `caller()` = 1; (c) the search continues to the next source.

**D4. Transparent reading of a computed place of the caller, not yet evaluated.**

```text
fn: tick () int
    shared\Observed\ticks := shared\Observed\ticks + 1
    return: 40
fn: callee () int
    return: x
fn: caller (int: x tick()) int
    int: a callee()
    return: a + x
```

`caller()` without an actual. Variants: (a) the reading in `callee` evaluates the initializer of the caller's place
once; the place becomes initialized, `ticks 1`; (b) each reading evaluates it anew, `ticks 2`. Today the frame row
evaluates the deferred declaration once and keeps the result (`lmx_graph_work_load`, `:426–453`), while the explicit
path to a computed field evaluates it at each reading (`lmx_graph_declared_value`, `:2188`).

**D5. A repeat of a declaration at the same level with another type.** §7.2: "A repeat of an own declaration of one
level works with the same place under the common contract of the receiver. A new RHS is computed and assigned by
the usual rules."

```text
fn: f () int
    int: y 7
    int: x 5
    @: x int @y
    return: 1
```

Variants: (a) refusal, answer 4 — as today (`probes/g14_same_level_other_type.lm3`); (b) the same place changes its
type to a reference to `int` by the author's rule of 2026-11-17 "an assignment changes the type of the record"; this
rule is written for a place of the graph, not for a place of an activation.

**D6. Time of autofill: entry or first reading.** Distinguishable only if the value of the caller's place changes
between entry and first reading. An example with an explicit address (I did not check the form of writing through
`\p` in L3):

```text
fn: callee (int: x; @: p int) int
    \p := 7
    return: x
fn: caller () int
    int: x 5
    return: callee(p := @x)
```

Variants: (a) 5 — the copy is taken on entry; (b) 7 — at the first reading.

## E. What was checked and how

**Read:** the TZ in full; `to_fable2_fast_build.md`; `LMX_blog/q/current/unit-root-roles-20261119.md`; Р104–Р107 in
`LMX_blog/q/fable-self-answers-20261110.md`; `next_core_tasks_v3.md` — the start (`#one-graph-plan`, `#final-check`)
and the section `#binding-callables-20261119`; `steps/current.md` — the start; `docs/kernel-implementation.ru.md:14–73`;
`steps/witnesses/one-graph-declaration-selection-20261118/notes.md`, the start of
`steps/witnesses/one-graph-expression-analysis-20261118/notes.md`. Code: `lmx_graph_run.lm2` — lines 1–1105,
1109–1690, 1940–2640, 2762–3006, 3529–3668, 3890–3955, 4200–4340, 4737–5116, 5474–6372, 7700–8075, 8515–8870;
`lmx_graph.lm2:100–190`; `l2_graph_build.lm2:955–1185`; `l2_graph_tool.lm2:225–565`, `1640–1880`, `2420–2545`;
`lmx_call.lm2:100–149`; `lmx_implements.lm2:100–129`, `1930–1969`, `7655–7681`; `lmx_walk_values.lm2:3930–3990`,
`5030–5099`, `10040–10208`; `tools/build.lm2:1075–1114`, `3700–3819`; separate lines of the frontend found by
search. Tests: `dynamic_inputs`, `private_binding`, `node_vs_dynamic`, `marks_code_dynamic_private`, `declsel_c11`,
`declsel_c12` and their `.expected`.

**Launched** (one process at a time; there were no builds):

1. `graph_trans-prod.exe 0 entry 0 -- run FILE` (Graph `ps-graph-x105`), CWD `probes/out`: 59 programs — 55 probes
   and 4 copies of `tests/graph` rows (`base_*`). Generator `probes/gen_probes.py`, run `probes/run_probes.py`;
   summary `probes/out/SUMMARY.tsv`, full outputs `probes/out/NAME.interp.txt`. A repeated full run gave the same
   values.
2. `lmxtool-tool.exe 0 entry 0 -- graph-check R S B FE RT GRAPH OUT SOURCE EXPECTED EXIT 1 ANSWER` (tool
   `ps-tool-x102`, FE `ps-feh-x102/l2trans.exe`, RT `ps-rt-x105`, Graph `ps-graph-x105`, B
   `cold-candidate48/full48/g2/frontend`, CWD — the stage) for 15 probes: `b02_free_write`, `b11_private_receiver`,
   `b24b_inner_same_type`, `b24c_inner_read`, `ctl74_inline_new_local`, `c02_call_data_code`, `c05_root_data`,
   `c05b_self_data`, `sel10`, `b21_chain_free`, `b17_skip_private_continue`, `b18_const_free_write`,
   `b01_autofill_read`, `c11_multi`, `c12_multi`. The expectation is the interpreter's dump of the same probe, so
   PASS means "native and forced observe what the interpreter observes", not "conforms to the norm". All 15: interp,
   native, forced — PASS; each about a second (`probes/run_native.py`, `probes/out/NATIVE.tsv`, logs
   `probes/out/gc-NAME.log`, images `probes/out/gc-NAME/{native,forced}`).
3. For the four refusal rows (`b18_const_free_write`, `b01_autofill_read`, `c11_multi`, `c12_multi`) the accepted
   `ps-tool-x102` does not compare the dump: this comparison appeared in an uncommitted edit of `build.lm2`. I read
   their native and forced dumps from `run.log`: the values are the same as those of the interpreter
   (`c11_multi` — `ticks 1`, `c12_multi` — `ticks 2`).
4. `git diff --stat`, `git log`, `git status` — read only; the counts — `Select-String` over `selfbuild/src`,
   `selfbuild/tools`, `selfbuild/tests/graph`.

**Not established:**

- The former path was not run (hosted FE was not called): its behaviour is described only by code, and only to the
  extent that it holds up the self-build.
- C19 (copy/merge and parent of the callee) — only by code. C03 — by code.
- The combination interpreter→native was not isolated by a separate probe; the conclusion about the four
  combinations is by code (the common frame row of the kernel) and by the equality of the three modes on 15 probes.
- The form `\p :=` (D6) was not checked.
- The count of `tests/graph` (537) differs from the number 524 in the question to the author: I counted
  `.lm2`/`.lm3` in the working tree (533 in HEAD and 4 untracked); I did not find out what 524 was counted by.
- `haiku_chat.py` was not run: the samples turned out shorter than the assignment.

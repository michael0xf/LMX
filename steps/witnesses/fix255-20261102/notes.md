# Slice 255 (fix255-20261102): B2a -- the runtime-typed free value (design 4.5, revision 13)

Writer/build: fable_pc (handover CODEX-FABLE-TAKE-WRITER-20261101T1943Z-01; Opus waits).  Step B of the optimization =
B1 (slice 254, landed a81173e1, accepted by Codex) + B2; this slice is B2a, the transport and the consumers of a
runtime-typed free value; B2b (the closure's removal) follows; C after both.  Records under
`P = build2/codex_fix250generationchain01` (pins/, variants/tp117, cold-tp117); copies in `records/`.

## Codex's directive (lmx_uds, 2026-11-02 ~09:15Z, the acceptance of B1; verbatim, the part about B2)

> Продолжай B2 сейчас, как уже делаешь: обязательный runtime-typed free value, реальные собственные free names без dyn/type closures, все consumers через общие kernel value/operation/admission helpers, static ARG witness не требовать для runtime-typed free input. Никакого lexical-only ban, угадывания типа по использованию, приведения всего к int/size_t и перевода положительных caller-only fixtures в refusals. Реальные receiving/C ABI contracts проверяются runtime в момент операции с действительным именованным отказом; не generic INVALID/UNSUPPORTED. Свидетель B2: один callee с разными допустимыми actual types, caller-only bindings через forwarders, write/actual/return, native↔walker. Только focused существующие средства, FULL финал.
>
> Общая готовность B=B1+B2, C после actual B2 transport. B1 PASS не закрывает collector/трёхпроходность/S8 и всю оптимизацию. Вопросы мне, без автора/разрешительного ревью/ACK; следующий обычный RESULT по B2.

## The design (optimization_design_from_fable.md, revision 13: §4.5 «Реализация B2: B2a / B2b»)

- **The free input.** A hidden input without a schema or capture (the predicate of the caller's FREE mark of B1:
  `input_schema = -1`, not a capture host) is runtime-typed: its type is the type of the value its binding holds, read where
  the value is used.  In the frontend its type code is FREE (own 45, dynamic 46: `lm_compiler_free_own/free_dt`,
  `lm_compiler_own_is_free/ft_is_free` in helpers; `input_ft` reads 45 through `own_of_dt(46)`); the kind of an expression
  over it is FREE (-20, `value_type_kind`/`value_expr_type`, absorbing).  A name with a numeric lexical source is FREE from
  its registration (`scan_ident` -> `dyn_source_dt`); a caller-only name becomes FREE after the closure (`dyn_typed`,
  `dyn_free`).  Schema/capture inputs (Structures, models, A3) keep the typed path.
- **The kernel (lmx_walk_values, 3 new exports; tool117).** `lmx_walk_value_bin(op, a, b, out)`: the one binary operation of
  both executors (the walker's `lmx_walk_eval` calls it; native code calls it for a runtime-typed operand): presence, EQ of
  references, numeric projections, C99 promotions, an int operation through `lmx_walk_native_int_bin_apply`; two numbers of
  different types are the implicit `convert` throw (THROWN + LMX_WALK_NAME_CONVERT; was INVALID -- the frontend's static word
  for the same case is "mixed numeric types (a conversion)").  `lmx_walk_value_receive(value, ty, out)`: the reception of a
  value by a typed place -- same base type (after a contextual literal takes the place's type), or a reference of the same
  type; else the `convert` throw, never INVALID; `lmx_walk_value_store_with_writer` receives through it.
  `lmx_walk_value_lit(out, magnitude, usuf)`: the contextual literal (LMX_TYPE_NONE, magnitude in `wide`, U in `natural`),
  typed by the operand or place it meets, int alone (U: unsigned) -- the rule `rw_unify` applies to literals statically,
  applied when the type is known; `lmx_walk_value_number` reads NONE as `wide`; the walker makes a LIT operand beside a
  non-literal operand contextual (`lmx_walk_value_contextual`; a no-op for statically typed programs, whose literals the
  frontend unified already).  `lmx_walk_values_arg_place` with `ty = LMX_TYPE_NONE` (no static witness): the type of the
  present value, else of the input cell (`lmx_walk_value_cell`); an absent input without a value is a missing input
  (INVALID, as documented); the walker's ARG default types the place by the default's value.
- **The walked header and ARG.** A free input's header entry has two fields and no witness cell (`rw_signature_free`);
  the ARG node's witness slot (child 3) stays empty (`rw_input_witness`, `rw_signature_input`): `lmx_walk_witness_type` of
  the empty slot is NONE.  `rw_bin` over a FREE operand types its literals int and notes no retained integer site.
- **The native side (lower).** `emit_native_input_read` of a free input: the complete record `l2_cvN` (after the lexical
  default, as every input), no typed raw projection; a raw consumer is a located limit.  The default
  (`emit_native_input_default`, `hid_own_lex` without the type comparison) reads the lexical source as it is; its store and a
  write through the name type the place by the record (`emit_native_input_store` -> `emit_native_input_place_text` with
  `l2_isvN.type`).  The dynamic expression `emit_dyn_values_full` (operands as records, literals contextual, the kernel's
  `lmx_walk_value_bin`, `!=`/`<=`/`>`/`>=` as in `rw_bin`, the operation's faults as the implicit throws `interpreter` and
  `convert`); the receiving funnel `numeric_receive_prepare` (kind -20: no static compatibility) and
  `emit_numeric_receive_full` -> `emit_dyn_receive_full` -> `lmx_walk_value_receive(record, <type>, out)`, the typed C view
  of the received record -- the funnel of typed declarations and stores, returns, method actuals and indices; a condition
  (`eval_test` for `if`, `eval_cond` for `while`): the number of the record, zero or not.
- **The closure in B2a.** It keeps running (D-105, captures, callable formals); `dyn_add` refuses no type conflict,
  `dyn_site_callee` no "incompatible entry signature" for a free input; `dyn_typed` keeps "unresolved name" for a name bound
  nowhere (B2b removes it with the closure); `check_value_convert_core` checks nothing for a target without a primitive type
  word.
- **Located limits of B2a** (translation refusals with a place, not runtime): an untyped local from a runtime-typed value
  (`twice: quote + quote` -- a type word is needed; FREE-typed own cells are B2b), a runtime-typed value as a C-call actual,
  in a logical connective, in a machine (bitwise, shift) operation, under a prefix sign.  None of these is in the corpus (the
  only fixtures with hidden inputs: the twins hidden_input and dyn/free_name_chain; the self-build sources read no free name
  -- census of the landed generation's outputs).
- **The witness** `tests/dyn/free_value_types.lm2` (full-suite.tsv `runs dyn/free_value_types.lm2 7 nf`): `leaf` writes
  through the name (`quote: quote + quote`) from `outer` (int 3 -> 6) and from `outer2` through the forwarder `mid2` (size_t
  65U -> 130U); `leaf_int` returns into int, `leaf_local` into a typed local, `leaf_arg` into a typed formal, `leaf_cond`
  compares with a contextual literal, from `outer3` (int) and `outer4` (size_t: `leaf_size` returns into size_t,
  `leaf_cond`); `outer5`: a size_t value at `leaf_int`'s int return -- the implicit `convert`, caught by `catch: convert ()`.

## The candidate tp117 (variants/tp117, stage cold-tp117)

The variant = fresh copies of `selfbuild/` patched by the scratchpad scripts `tp117_patch.py` (tools/build.lm2: the export
lists `walk_value_names` 141 -> 144 and `frontend_names` 257 -> 261; lmx_walk_values), `tp117_patch2.py` (seven frontend
modules, the fixture, the suite row, inputs.list) and `tp117_patch2b.py` (six tail cutters, below).  Changed inputs:
`tools/build.lm2`, `src/l2src/lmx_walk_values.lm2`, `src/l2src/l2_frontend_{helpers,values,resolve,context,core,emit,lower}.lm2`,
`tests/full-suite.tsv`; new `tests/dyn/free_value_types.lm2`; `inputs.list` 161 lines.

| record | what | result |
|---|---|---|
| `pins/tp117-prepare.command` | stage cold-tp117 = selfbuild (source-tp116) + the kernel-first changed set (`tp117-changed.list`: lmx_walk_values, build.lm2) | 6 steps exit 0; 4 manifest differences |
| `pins/tp117-reuse.command` | the 232 generated inputs of boot116c's stage into cold-tp117 (`tp117-reuse.list` = tp116-reuse.list) | 5 steps exit 0 |
| `pins/tp117-tool.command` | `rebuild tool` -> tool117 `cold-tp117/tool117/lmxtool-tool.exe` **`cfd04412bc01bae832d39b2fc77b70e27f363e6758e5ca9b3ff78b6fe3475723`** (host 18C898AC, fe 25EDB0D0, rt boot116c G2) | RebuildExit 0 (10:00:29-10:02:09Z), smoke list passed |
| `pins/tp117-rt.command` (TP_LABEL rt117, TP_TRY 01) | isolated `build-runtime` of the kernel with tool117 | exit 0; HEADERS 84 regenerated; driver.o `76c8474b…`; 60 checks |
| `pins/tp117-prepare-fix01.command` (TP_TRY fix01) | the full changed set (`tp117-changed-full.list`, 11 lines) over the stage | 4 steps exit 0; 21 differences; source-tp117 `7feffdd1…` |
| `pins/tp117-fe.command` (fe117, TP_TRY 01) | isolated `build-frontend` with tool117 | **exit 1**: `l2_frontend_lower.lm2:8221:9: source level decrease must be one step unless a tail cutter is used` -- an L2 `else:` after an if-body two levels deeper needs `---` before it (six such places of part 2: the literal's sign, the swap, the negation, the reference view, the write through a free name, the free header entry) |
| `pins/tp117-prepare-fix01.command` (TP_TRY fix02) | the fixed set over the stage | 4 steps exit 0 |
| `pins/tp117-fe.command` (fe117b, TP_TRY 02) | isolated `build-frontend` with tool117 after the cutters | exit 0 (10:20:01-10:24:11Z); `cold-tp117/fe117b/l2trans.exe` `73d1d74e…`; the helpers header `8262c79f…` (the FREE codes) |
| `pins/tp117-suite.command` (TP_FE fe117b, TP_RT rt117, TP_TRY 01; list `pins/focus117.tsv`) | the focus list on the isolated frontend and runtime objects | **exit 1**: forward_header twins, os_walk_values and the hidden_input twins **native** pass (`return: base + d` runs through `lmx_walk_value_bin` and the int reception); the hidden_input twins **forced** fail `driver exit 3`, `lmx: walk error: INVALID`; `free_name_chain` and `free_value_types` refused at translation `:11:13` / `:15:13: return value has incompatible type, atom=quote` |

## The first suite's two findings

- **The walker refused the free input at its entry.** gdb on `hidden_input_unit-forced/p-prod.exe` (command files
  `gdb_invalid.txt`, `gdb_trace117.txt`, `gdb_trace117b.txt`: breakpoints on the kernel's value functions, `finish` and
  `bt` after each): the backtrace of the failure note is `lmx_call_note_walk_fail <- lmx_walk_call_prim_dispatch <-
  lmx_call_prim_values <- l2_m1` (the native root calling the walked `os_get`); after the callee's entry
  (`lmx_walk_entry_resolve -> lmx_activation_resolve_input -> lmx_activation_resolve -> lmx_activation_record_find ->
  lmx_walk_value_load` of the unit field's int) no value function ran before INVALID -- not `lmx_walk_values_arg_place`, not
  `lmx_walk_value_bin`.  The walked graph of os_get differs from B1's only by the three witness cells no longer created
  (the header entry's slot 1, the ARG's slot 3, the signature input's slot 1).  The reader: `lmx_walk_entry_node` (the
  entry collection of ARG entries, `lmx_walk_values.lm2:1899`) refuses an ARG entry whose witness type is 0 -- `index >=
  f\nargs || f\args = 0 || entries = 0 || current_type = 0`.  Fix03 drops the `current_type = 0` condition (a witness type of
  NONE is a runtime-typed free input; two entries of one input must still agree) -- the one entry-time reader of the witness
  the B2a design missed.
- **The static return-kind check refused the free value.** `lm_compiler_check_ret_kind` (core) refuses a `return:` of one
  value whose `colon_value_ty` is not a primitive, a literal, an opaque C value or void: a FREE value (45) hit the refusal.
  The hidden_input twin passed natively because its `return: base + d` has three fields (the check applies to one).  Fix03
  adds the FREE case (received by the result place at run time).
- `pins/tp117-prepare-fix01.command` (TP_TRY fix03): the fixed set over the stage, 4 steps exit 0.

## The second suite

| record | what | result |
|---|---|---|
| `pins/tp117-rt.command` (rt117b, TP_TRY 02) | the isolated runtime build after fix03 (the entry-node check) | exit 0 (10:32:38-10:33:27Z); driver.o `efa2fc54…`, driver-observe.o `cab21253…` |
| `pins/tp117-fe.command` (fe117c, TP_TRY 03) | the isolated frontend build after fix03 (`check_ret_kind`) | exit 0 (10:33-10:37Z); l2trans `b9a30c65…` |
| `pins/tp117-suite.command` (fe117c, rt117b, TP_TRY 02) | the focus list | **exit 1, SUITE 5 rows, 4 failures**: the hidden_input twins pass in **both** modes now, forward_header and os_walk_values pass, `free_name_chain` **forced passes** (chain65 walked end to end on the runtime-typed input); `free_name_chain` native and `free_value_types` native fail at the C compile: `'l2_out_throw' undeclared` (p.c:333; :623, :1546); `free_value_types` forced runs and exits 81 (`outer() != 6`) |

- **The status channel.** `lm_compiler_emit_implicit_throw` writes `l2_out_throw[0]: 0` and returns the implicit status; the
  method has that out-parameter only when it is marked as throwing (`m_throws`, set once by `lm_compiler_body_throws` before
  the closure: declared `throws:`, a path effect, or a retained int operation's implicit `interpreter`); the dynamic
  expression and the reception emit the implicit `interpreter`/`convert` throws in methods never marked.  Fix04 (emit):
  `lm_compiler_body_free_inputs(mi)` -- a hidden input without a schema and not a capture (the predicate of the free input,
  computed from the inputs registered by the scan, before the closure) -- marks the method as throwing in `body_throws`;
  the callers take the channel through `throws_close` as for every throwing callee.
- **A bare write through a free name is activation-local (Q52).** The first witness expected `leaf`'s `quote: quote + quote`
  to double the caller's `quote`; by the author's Q52 («0 — меняется лишь скрытый вход s»; the comment of `scan_ident`) a
  bare write to a free name changes only that activation's input value -- which is exactly what both executors do (the
  native store into `l2_input_values[k]`'s place, the walker's SET_ARG of its own arg place), so the forced run returned 3,
  not 6.  Fix04 (the fixture): the written value is observed through the writer's own return -- `leaf_twice () int` and
  `leaf_twice_size () size_t` (the latter reached through the forwarder `mid2`, which binds nothing) write and return;
  `outer`/`outer2` check that their own `quote` is unchanged after `leaf()`; `leaf_cond` stays the one callee reached with
  both types.  No kernel or frontend semantics changed for this.
- `pins/tp117-prepare-fix01.command` (TP_TRY fix04): the fixed set over the stage, 4 steps exit 0.

## The third suite and the observed walk

| record | what | result |
|---|---|---|
| `pins/tp117-fe.command` (fe117d, TP_TRY 04) | the isolated frontend build after fix04 (`body_free_inputs` in `body_throws`) | exit 0 (10:40:43-10:44:56Z); l2trans `6a34bcf5…` |
| `pins/tp117-suite.command` (fe117d, rt117b, TP_TRY 03) | the focus list | **exit 1, SUITE 5 rows, 2 failures** (10:44:57-10:45:21Z): the twins pass in both modes, os_walk_values and `free_name_chain` pass in both modes, `free_value_types` **native passes** (the whole witness: the writes, the typed receptions, the convert catch); `free_value_types` **forced** fails root0/root1 `driver exit 3`, run log `lmx: walk error: INVALID` |
| gdb on `focus117-03/free_value_types-forced/p-prod.exe 0 entry 7` (command files `gdb_fvt2.txt`, `gdb_fvt3.txt`) | the failure note's backtrace; the sequence of the kernel's value operations (`commands` breakpoints: `lmx_call_prim_values`, `lmx_walk_value_receive` with its type and the value's kind/type, `lmx_walk_value_bin` with its op and operand types, `lmx_walk_values_arg_place`, `lmx_walk_value_store_with_writer`, `lmx_call_note_walk_fail`) | one `lmx_call_prim_values` (the root `m` walked as a whole: `lmx_call_note_walk_fail <- lmx_walk_call_prim_dispatch <- lmx_call_prim_values <- l2_m16`, status 1); 13 walked entries; every reception and binary operation up to the failing activation agrees with the fixture (ADD int+int, the EQ/SUB pairs of the `!=` checks, LT on int and on size_t with the contextual literal, the SET_ARG receptions of `quote: quote + quote` in int and in size_t); the failing activation makes its ARG place and fails without any reception or operation |
| `pins/tp117-obs.command` (TP_SOURCE dyn/free_value_types.lm2, TP_SPEC m=1, TP_ENTRY 7, fe117d, rt117b, TP_TRY 01; [record](records/tp117-obs.command), [terminal](records/tp117-obs-01.terminal.txt)) | `lmxtool os-walk-witness`: the fixture built natively and `--walk-methods`, each linked with the production and the observed runtime, run at root 0 and 1 -- the observed runtime says `LMX_OBSERVE WALK_BODY <name>` at every walked body's entry | exit 1 as expected (10:57:03-10:57:12Z: the four forced runs `driver exit 3`, the native runs pass, `m` walked once in both forced runs); `obs117-01/forced/run-obs-root0.log`: `m, outer, leaf, leaf_twice, outer2, leaf, mid2, leaf_twice_size, outer3, leaf_int, leaf_local, leaf_arg, show, leaf_cond, outer4, leaf_size, leaf_cond, outer5, leaf_int` then `lmx: walk error: INVALID` -- the failing activation is `leaf_int` called by `outer5` (a size_t value returned into an int result: the implicit `convert` that `outer5` catches) |

### The third suite's finding: the walker has three receiving places for a number

- The native twin receives the free value at its `return:` (`emit_dyn_receive_full`: `lmx_walk_value_receive(record, int)`
  -> THROWN+CONVERT -> the implicit `convert`, caught in `outer5`).  The walker's RET (`lmx_walk_eval_result`) evaluated the
  value into `f\result` and admitted nothing -- the size_t number travelled to the caller as the call's result; the caller's
  `got: leaf_int()` is a SET of a working cell (an own local), whose number branch compared the value's type with the cell's
  type raw (`a != work\ty` -> INVALID).  B2a had routed only the input/field place (`lmx_walk_value_store_with_writer`:
  SET_ARG, PUT) through the one admission; `m`'s `r: outer3()` passed the SET because int met int.
- Fix05 (kernel, `lmx_walk_values.lm2`): (1) `lmx_walk_result_receive(f, value)`, defined before `lmx_walk_eval_result` --
  for a present NUMBER it reads the declared result witness of the frame's code as the call site does
  (`lmx_implements_exec_slot(arena, f\code, 1U)` -> the return part -> `lmx_callable_source_count` = 1 ->
  `lmx_callable_source_entry` -> `lmx_walk_witness_type`) and, for a numeric type, receives the value through
  `lmx_walk_value_receive`; a reference result, a code without a readable one-witness return part and a void part pass as
  before; (2) RET calls it after the value's evaluation -- a mismatch is the implicit `convert` raised in the callee's frame
  (its pads first, then the caller's), as the native twin raises it; (3) SET's number branch receives the value in place
  through `lmx_walk_value_receive(@ value, work\ty, @ value)` -- a mismatch is the statement's implicit `convert`, not
  INVALID.  The formals' reception (`lmx_walk_receive`: SET_ARG of SOURCE_RECEIVING -> `lmx_walk_arg_write` ->
  `store_with_writer`) was already the one admission.  No frontend change; no export (an internal kernel fn;
  `walk_value_names` stays at 144 of the module's 180 fns), so tool117 stays the G0.  Design revision 14 records the three
  places.

| record | what | result |
|---|---|---|
| `pins/tp117-prepare-fix01.command` (TP_TRY fix05) | the fixed set over the stage (the kernel module changed) | 4 steps exit 0 (11:06:40Z); source-tp117 `fc9659df…`, changed set `51b5e066…` |
| `pins/tp117-rt.command` (rt117c, TP_TRY 03) | the isolated runtime build after fix05 | exit 0 (11:06:40-11:07:29Z); module `cc110e46…`; driver.o `8b66e720…`, driver-observe.o `3e9b4e28…`; `lmx_walk_values.h.lm1` `3b441cdf…` (the new internal fn) |
| `pins/tp117-suite.command` (fe117d, rt117c, TP_TRY 04) | the focus list on the fixed runtime | **exit 0, SUITE 5 rows, 0 failures** (11:07:30-11:07:55Z): the twins, os_walk_values, `free_name_chain` and `free_value_types` in both modes; the forced witness walks every body end to end -- the write through the free name from the int and the size_t binding, the receptions into int/size_t results, locals and the formal, the contextual literal of `leaf_cond` in both types, and `outer5`'s implicit `convert` caught (89) |

## boot117a, the fixed point, the focus suite on G2, the landing

| record | what | result |
|---|---|---|
| `pins/boot117-prepare.command` (TP_TRY a; [record](records/boot117-prepare.command), [terminal](records/boot117a-prepare.terminal.txt)) | the fresh source-only stage cold-boot117a with exactly source-tp117's 161 inputs (verify, stage-copy, manifest, verify by the working tool 18C898AC of boot116c) | 4 steps exit 0 (11:10:29Z); `source-boot117a.sha256` = `source-tp117.sha256` = `fc9659df…` |
| `pins/boot117-quick.command` through `pins/boot117-detached.command` (TP_TRY a; [record](records/boot117-quick.command), [terminal](records/boot117a-quick.terminal.txt), [log](records/boot117a-quick.log)) | the whole short bootstrap: G0 = tool117 (`cfd04412…`), BASE full48/g2/frontend, the previous frontend = boot116c's G2 (`25edb0d0…`); runtime, frontend, the smoke list, G1 built by G0, G2 built by G1, the working binary | **exit 0**, 11:10:30 → 11:24:28Z (838 s): `SUITE 9 rows, 0 failures` in both generations, `PASS bootstrap: G0 builds and tests whole G1`, `PASS bootstrap: actual G1 builds and tests whole G2`, `PASS G2: the tested whole bundle is working`, `BOOTSTRAP quick 0 failures`; G1 l2trans `b7491fd4…`, G2 l2trans `1113ee3b…`; driver.o `8b66e720…` in both generations -- byte-equal to the isolated rt117c's; working tool `quick117a/lmxtool.exe` **`4E1D96D4C939CEAA2721ABD1413EFAA93FEB4CC5BB7E318EEAFF87BB3AF5AA68`** (G2's) |
| `pins/boot117-compare.command` (TP_TRY a; [record](records/boot117-compare.command), [report](records/boot117a-compare.txt)) | G1 and G2 compared from the receipts | `in both 248 raw-equal 245 differ 3 only-G1 0 only-G2 0`; the three PE images differ at bytes 136-137 and 216-217 only (the link stamp).  The fixed point G1 = G2 holds |
| `pins/tp117-suite-g2.command` ([record](records/tp117-suite-g2.command), [terminal](records/tp117-suite-g2.terminal.txt)) | the focus list on boot117a's G2 frontend and G2 runtime objects, run by the promoted working tool from cold-boot117a | **exit 0, SUITE 5 rows, 0 failures** (11:28:57-11:29:22Z; tool `4e1d96d4…`, fe `1113ee3b…`, prod `8b66e720…`): the twins, os_walk_values, `free_name_chain` and the witness `free_value_types` in both modes |
| `pins/land255.command` ([record](records/land255.command), [terminal](records/land255.terminal.txt)) | the landing of source-tp117 into the tracked `selfbuild/` by the rule of Codex's answer to FABLE-RESULT-S3 (the whole tested set after the actual quick PASS): verify in cold-boot117a, stage-copy over selfbuild/, the variant's `inputs.list` (161 lines) by a one-line manifest, the package manifest rewritten and verified, the 65 sources of G1's and G2's consumed-input snapshots verified against the landed files | 8 steps exit 0 (11:29:23-11:29:25Z); G1 and G2 consumed inputs 306 each, the two 65-source subsets identical and each line in source-tp117; `selfbuild/inputs.sha256` `FC9659DF3F4E572FE13FDC3D23488FCFA9EBD41F423A39850B78157CA52D001B` = `source-tp117.sha256` |

The package: `selfbuild/` = source-tp117 -- the landed source-tp116 with the 10 changed files of tp117 (`src/l2src/lmx_walk_values.lm2`,
`l2_frontend_helpers/values/resolve/context/core/emit/lower.lm2`, `tools/build.lm2`, `tests/full-suite.tsv`) and the new fixture
`tests/dyn/free_value_types.lm2`; `selfbuild/README.md` names the snapshot, `steps/current.md` gets the slice-255 entry.

## Evidence and the docs check

- `evidence.list` (225 originals under P: the pins records, terminals, logs and manifests of tp117/boot117a/land255, the variant's
  sources, tool117, the previous generation's binaries, boot117a's receipts and binaries, the isolated builds' records and logs,
  the suites' and the observed walk's receipts) and `evidence.sha256` by `pins/docs255.command` ([record](records/docs255.command):
  manifest + verify, 2 steps exit 0, 11:32:31Z, working tool `4e1d96d4…`); `records/` holds 184 LF copies of the text records
  (the gdb command files `gdb_fvt2.txt`, `gdb_fvt3.txt` and the compact trace `gdb_fvt3-trace.txt` among them).
- The full docs check `pins/docs255-check.command` ([record](records/docs255-check.command)) over the Git index with the slice's
  files staged: exit 0 (11:33:09-11:33:29Z) -- `OK: 35 paired semantic chapters, 14 implements cases, both source snapshots; 27
  paired grammar sections, 44 verbatim source excerpts, 615 imported files, links, exact semantic opening; line endings LF`.
- Memory of the session (`frontend-slice-coding-pitfalls`): the observed-walk record as the way to name a failing walked body,
  the walker's three receiving places, the result witness inside an activation, no export for an internal kernel fn.

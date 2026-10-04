# Fable continuation ledger — 2026-10-03

Working evidence of the continuation that follows [the handoff](../to_fable.md)
and [the v2 plan](../next_core_tasks_v2.md). It is not a specification and not a
release record. Earlier evidence stays in
[the namespace source-layout ledger](critical-graph-namespace-source-layout-20261003.md).
Both critical tickets and stages 8/8a remain OPEN. Stable `l2src/` is unchanged.

Roles: Fable is the single writer/build owner; Codex answers questions through
`lmx_uds`. Every gate below ran alone, one compiler chain at a time.

<a id="takeover"></a>
## 1. Takeover checks and baseline

Read-only checks at takeover: `HEAD = origin/main = 4114628c`; no staged paths;
no compiler process; `lmx_uds` and the Codex inbound bridge answer; hashes of
the translator `BFF213AC…`, harness `DF38FC1D…`, driver `E30B6004…` and pinned
`bin/l1trans.exe` `601D350E…` equal the handoff. A plain file copy of the
315 inherited uncommitted paths is kept in the ignored
`build/fable_backup/handoff_wip_4114628c.tar`.

| Run | Result | Scope |
| --- | --- | --- |
| `build/l2_harness/fable_focus_01` | GREEN 7/7 | The handoff's four persistent-oracle rows, reproduced. |
| `build/l2_harness/fable_full_01` | RED 126/1395 | Full generated harness on the unchanged handoff bytes. |

`fable_full_01` against `critical_graph_fix_full_32`: the same 1395 targets;
exactly four FAIL→OK (`unit_named_struct_call`, `unit_ref_local_path`,
`unit_site_layout_local`, `unit_capture_struct_nofield_write_refused`); no
OK→FAIL; the other 126 failure details are byte-identical after normalizing the
output directory name. This is the baseline every later comparison uses.

<a id="legacy-setup-migration"></a>
## 2. Legacy construction setups (K03 migration debt)

**Norm.** An existing ordinary named Structure has a body and no arguments;
`Model: x` in an executable body is an erroneous argument-bearing call
([construction](../docs/LMX_semantics.en.md#construction), Q59). Explicit
`merge` is the copy mechanism. A nested Structure that must exist at
construction is a nested definition with its written body.

**Implementation.** No translator change. Twenty-eight fixtures whose setup
still used the implicit `Model: x` copy were migrated: 26 of the 27 rows that
refused with `a Structure-typed field in a method` (since namespaces and local
definitions became source-counted procedures), and two refusal rows hidden
behind the same setup. The forms used:

- `Model: x` → `x: merge Model`;
- a nested `Inner: in` inside a definition → the nested definition written in
  place (`in:` with its body);
- `@S` used as S's descriptor in an actual or a rebinding → `S`; unary `@`
  depth is the pointer ticket's subject, not these rows';
- `unit_ns_ref_field_general` uses the unit-level `Holder` directly;
- `graph_shape_method_ref` keeps its int then a nested written Structure, with
  an exact oracle (`$criticalMethodRefShape`) instead of the stale coarse one
  and two new INIT-erasure mutants;
- three stale generated-text pins now name the explicit merge call
  (`lmx_merge_profiles_owned(…, self, …)`, operand read through `node`).

The interim rebinding spelling `r: mo` is retained where Codex's earlier
migrations use it; the accepted explicit form `@: r mo` is not lowered yet and
belongs to the reference-application stage.

**Verification.** `fable_mig_03` RED 7/37 (focused): 20 migrated rows, the two
new mutants and five unchanged neighbouring controls are green. The seven red
rows are not migration errors; each now stops on a real open mechanism instead
of the obsolete setup:

| Row | Diagnostic after migration | Mechanism it needs |
| --- | --- | --- |
| `unit_capture_struct_own` | `a field path` on captured `loc` | capture of a merge-result local (capture closure) |
| `unit_d112_nested_return`, `unit_d113_nested_expr`, `unit_s7_nested_shape` | `an admission to a Structure type through a Structure field of another type` | nested correspondence maps across distinct nested definitions |
| `unit_empty_type_call_method` | `executing a named Structure is not supported yet` | held/copied-call boundary |
| `unit_bind_method_thin_other` | runs, implements throw, exit 1 instead of 7 | receiving-use contract (§3) |
| `unit_eternal_shape` | unchanged, not migrated | needs the reference binding `kept: E` (reference-application stage) or the merge-in-named-body defect below |

Two refusal rows hidden behind the same setup
(`unit_field_path_struct_rebind_refused`,
`unit_matrix_path_struct_rebind_refused`) were migrated the same way and refuse
again with their pinned text. That text (`a Structure assigned through a path`)
is an implementation wording: by the norm `o\inner: a` is an application of the
held Structure and an arity error. It stays recorded as debt of the
reference-application stage.

<a id="receiving-use-contract"></a>
## 3. Resolved rule: receiving-use contract (Codex, FABLE-CODEX-20261003-01)

**Question.** Is a candidate received by an explicit typed reference
declaration or store (`@: Model b o`; a store into `@: Model r`) admitted by the
used paths of that reference in its visible body, or by Model's whole shape?

**Answer (no author question needed; the norm is explicit).** Consumer-relative
used paths: [three-argument implements](../docs/LMX_semantics.en.md#three-argument-implements)
and L2 §implements. A genuinely known-thin Consumer admits a candidate lacking
unused fields; a field the Consumer reads is required. The full-receiver
behaviour described in `CORE_L2_L3_v2.md` §9.3 is Implementation, not authority.

**Consequences, OPEN implementation work:**

- The shared receiving/admission contract must distinguish proven-empty uses,
  specific required paths and unknown analytical coverage, in native and
  walker routes. Passing the model itself as the complete requirement is wrong
  for an unused local. Unknown coverage is not known-thin; no YES from unknown
  provenance, no reuse of a prior thin map for another Consumer.
- `unit_bind_method_thin_other` stays a required positive on the explicit
  initializer (red until the mechanism exists). `unit_bind_root_thin_other`
  keeps its thin intent when its legacy `Model: b o` setup is migrated.
- `unit_ref_rebind_other_refused` and `unit_struct_return_ref_admit_refused`
  read no field of the received reference; their whole-shape refusal
  expectations are wrong and must become known-thin positives with real
  runtime observations, on the accepted explicit forms. They are still green
  as refusals today: false greens, to migrate with the mechanism, not by
  flipping flags.
- `unit_ref_formal_rebind_other_refused` and
  `unit_formal_spelling_rebind_other_refused` read `v\value`; their refusal is a
  real missing-used-field rejection and stays.
- Explicit rebinding is `@: r o`; the plain `r: o` route is legacy
  implementation pending the reference-application stage.

<a id="machine-locals"></a>
## 4. Native-only source producers: machine locals, foreign member paths, forward headers

**Norm.** The retained graph keeps every source occurrence in source order,
also in native-only bodies ([L2 interpretable tree](../docs/L2_spec_en.md#interpretable-tree)).
Names are absent from the graph; an activation-local C value lives in machine
activation storage and no graph pointer may outlive a stack object.

**Implementation** (`dev/l2src_sandbox/l2trans.lm1`, symbols):

- `l2_rw_machine_declaration`: `TYPE: name [initializer]` for an imported C
  function-pointer or by-value record local is one `SOURCE_MACHINE` node named
  by the type head; its body holds one source leaf for the declared name and
  each initializer span through the ordinary resolved actual producer. No cell
  is allocated.
- `l2_ml_rw` / `l2_rw_machine_local`: every later use of that name borrows the
  declaration's own leaf (a shared reference, not an owning edge and not a new
  symbol). Reached from the operand, machine-actual, machine-word and indirect
  producers.
- `l2_rw_foreign_path`, `l2_rw_machine_word`, `l2_rw_machine_store`: a member
  path rooted at foreign C storage (`x\length`, `av\alloc`, two-hop) is a
  `SOURCE_MACHINE` node named by the written path with its resolved root, as a
  read operand (atom or field span) and as a store with its assigned value.
  `l2_rw_span_ty` types it by the native path contract.
- A same-unit forward header (`l2_fn_defined = 0` and a defining occurrence
  found by `l2_unit_defined_fn`) is retained at its written unit slot as an
  inert description; no body is fabricated.
- A string literal operand is retained as its char Array source value; its
  consumption as a raw character pointer marks the body native-only.

**Defect found and fixed with it — stale machine-local table.**
`l2_local_ns_shape` asks `l2_ml_find`, but the declaration-role collection pass
(`l2_collect_asgn_binds`) and both walker passes never rebuilt the table for
the method being read. A statement `f: n` with `f` a function-pointer local was
therefore registered as a spurious local named Structure (an extra procedure
and an extra unit child) once its declaration stopped refusing. The table is
now rebuilt per method in those three places. In the early collection pass only
locals classified by an imported type name alone are read
(`l2_ml_imported_only`): a full early read refused
`@: Model Model @Other` with `unknown type` before the local definition existed
(two OK→FAIL rows in the intermediate `fable_full_02`, repaired before any
claim).

**Verification.**

- `fable_ml_02` (focused) RED 1/33: all 18 function-pointer/record-local rows
  and 8 foreign-member rows pass; the remaining row
  (`unit_uniform_foreign_results`) moved on to the separate foreign by-value
  call producer.
- New witness `graph_shape_machine_local`: 124 checks, native method that
  really allocates through the local, root also walked. Path oracle: unit and
  method widths, the declaration's name, its name leaf and initializer names,
  identity of the leaf with the comparison's operand (`samepath`), the separate
  call application. Three mutants (`…_leaf_mutant`, `…_init_mutant`,
  `…_use_mutant`) null one real field each: baseline matches, the structural
  comparison fails, the program result stays 7.
- `fable_str_01`/`fable_str_02` (focused): the seven string rows translate and
  five run green; `parser_alloc_port` and `parser_trailer_role` moved on to
  other producers.

<a id="oracle-triage"></a>
## 5. Expectation triage done in this slice

| Row | Old expectation | Finding | Now |
| --- | --- | --- | --- |
| `unit_native_activation` | refused: `L2 operation outside a method body` | That rule is withdrawn ([scope](../docs/LMX_semantics.en.md#scope)): the root is compiled like every body. | runs, entry 7 |
| `unit_arg_addr_pointer` | `root-pending` | The pending operation is built; the row had been reporting ACCEPTED. | runs, says `P local is null` |
| `unit_discard_calls` | `root-pending`, entry 11112 | Translates now, but its counters used bare `hits: hits + N` in methods and a bare read at the root. A bare name in a method is its hidden input (Q52); the root's bare own value is not reloaded after a call ([working state](../docs/LMX_semantics.en.md#dynamic)). | callees write `node\hits`, the root reads the published cell through `@hits`; entry 11112 |

<a id="full-gates"></a>
## 6. Full gates of this continuation

| Run | Result | Against `fable_full_01` |
| --- | --- | --- |
| `fable_full_02` | RED 82/1401 | 46 FAIL→OK, 6 added (all OK), 2 OK→FAIL caused by the early machine-local read; intermediate, superseded. |
| `fable_full_03` | RED 71/1401 | 55 FAIL→OK, 0 OK→FAIL, 6 added (all OK), 0 removed. `unit_discard_calls` still red there; its fixture was corrected afterwards (focused `fable_str_02` GREEN 6/6). |
| `fable_full_04` | RED 70/1401 | Final bytes of this slice: 56 FAIL→OK, 0 OK→FAIL, 6 added (all OK), 0 removed. Against `fable_full_03` only `unit_discard_calls` changes, FAIL→OK. |

Bytes of `fable_full_04` (the same translator and harness as `fable_full_03`):
translator SHA256
`D7807F2A3E85860C8BF96E7D706BDC3F44F1F5B1489A2D6ECF22A06435FEF70A`
(staged Git blob `de4f149012260335753a947ba8e083ae0193df34`), harness
`F30F7DC5896168ABDC4588CB89BF6F37265D9DFD1B5E74D5060467BA94CD23D0`, driver
unchanged `E30B6004…`, raw executable
`0CCF305DA88C67C10303D7A9D57C44A192DEB785F39159386850C11AAC00D45C`.

Other gates on the same tree (the kernel and L3 sources were not edited by this
continuation; the runs establish that the tree as a whole is where the handoff
said it was):

| Run | Result |
| --- | --- |
| `build/l2src/fable_kernel_01` (`build_l2src.ps1 -Run -KeepAll`) | GREEN, 292 targets; 109 selftests executed: 108 ran with exit 0, the expected-fatal close-watchdog selftest exited 3 as required. |
| `build/l3_selftest/fable_l3_01` (`run_l3_selftest.py`) | all 11 suites exit 0; four type-budget units 75/128 names, 1070/8192 bytes. |

A red generated harness is not a release: 70 rows remain, classified below.

<a id="remaining"></a>
## 7. Remaining red rows by mechanism (after `fable_full_04`)

Later state: sections [11](#machine-operators) and [12](#foreign-value)
recover the two groups marked below; [section 14](#full-05) has the gate.

Translator refusals:

| Group | Rows | Next mechanism |
| --- | --- | --- |
| held/copied nullary call | `unit_named_until_copy_call`(+walk), `graph_shape_ns_source_nested_copy`(+walk_methods), `unit_named_struct_exec_instance`, `…_two_types`, `unit_model_var_call`, `unit_empty_type_call_method`, `unit_held_nullary_source_field` | actual-call boundary (design question FABLE-CODEX-20261003-02 sent) |
| foreign by-value call (recovered, section 12) | `unit_uniform_foreign_results`, `unit_uniform_aggregate`, `parser_trailer_role` | CALL producer for foreign by-value inputs/results |
| nested admission maps | `unit_d112_nested_return`, `unit_d113_nested_expr`, `unit_s7_nested_shape` | correspondence through nested fields of distinct definitions |
| capture of a merge-result local | `unit_capture_struct_own`, `unit_capture_struct_call_arg` | capture closure |
| C99 common arithmetic | four `1U`-in-`int` rows (`unit_callable_forward`, `unit_callable_nullary_forms`, `unit_callable_returning_two_contracts`, `unit_callable_sub_transport`), `unit_indent_stack_field_index` (missing `int`→`size_t` conversion receiver) | K08 conversions in the producer and walker |
| head role of a dynamically supplied name | `unit_free_conv`(+walk), `unit_colon_hidden_update`, and from the single rows `unit_own_dirty_rhs`, `unit_arg_addr_dyn_types` | triaged in [section 13](#head-role): one decidable, one to audit, three behind an author question |
| pointer arithmetic / raw address forms (recovered, section 11) | `unit_addr_own_array_arith`, `unit_rhs_compound_admission_refused`, `unit_rhs_reference_admission`, `unit_addr_own_array_element`, `parser_alloc_port` | native-only producers for address arithmetic and raw index of a record pointer |
| Array in a nested body | `unit_address_array_descriptor`, `unit_array_index_shadow`, `unit_array_value_projection` | Array cell constructor in a hosted body |
| letter/mainArgs element contract | `entry_index`, `entry_strcmp`, `unit_charpp_return`, `unit_l2_puts_library`, `entry_arg_len` | Array-of-Array element contract (K06/K07) |
| reception into a model | `unit_receive_letter_model`, `unit_send_ref_method`, `unit_send_ref_driver_tap` | admission producer for a received letter |
| Structure value in return/argument | `unit_s7_ret_field`, `unit_s7_ret_deep`, `unit_s7_arg_deep` | Structure-valued operand producer |
| single rows | `unit_t7_convert`, `unit_named_actual_whole` (unary minus), `entry_array_leading_zero`, `unit_arg_addr_dyn_types`, `unit_own_dirty_rhs`, `unit_eternal_shape` | individual triage |

The table covers the 50 translator refusals of `fable_full_04`. The other 20
red rows are oracle rows: 19 stale negative expectations or generated-text pins
(seven `ACCEPTED a fixture that must be refused`, eight `refused, but not with`,
four missing text pins) and the runtime row `unit_bind_method_thin_other` (§3).
Each needs the same normative triage as §5 before its expectation changes;
`unit_capture_struct_whole_refused` in particular pins an implementation limit
(a captured Structure used whole), which the norm does not forbid.

<a id="defects-found"></a>
## 8. Defects and gaps recorded by this continuation

Details are in [defects](defects.md): `MACHINE-LOCAL-TABLE-STALE` (fixed in the
sandbox), `MERGE-DECL-IN-NAMED-BODY-INTERNAL`,
`MERGE-RESULT-REFERENCE-FIELD-PATH`, `RECEIVING-USE-FULL-RECEIVER`.

<a id="held-call-ruling"></a>
## 9. Resolved boundary: the actual call of a held Structure (Codex, FABLE-CODEX-20261003-02)

The question proposed to select, at the call of a held or copied ordinary
Structure, one compile-time alternative by the registered layout token of the
actual value, and to raise the ordinary admission failure for an unlisted
origin. Codex answered without escalating to the author. The ruling:

- **Selection by the actual value's token is a bounded lowering optimization,
  not the universal boundary.** Layout is physical-origin evidence
  ([core map](../CORE_L2_L3_v2.md), sections 9.2 and 9.4), not a certificate
  of the callable interface. For every alternative the producer and schema
  facts must determine the executed body **and** its complete ordered input
  contract: required hidden names, pass modes and types, applicable exits.
  The interface is not inferred from ABI arity or from the `ARG` nodes of a
  convenient witness. The selected occurrence supplies its own lexical
  fallback and parent; an original model instance does not. A constructor's
  token is never restamped onto a replacement, a required model or identity
  map is not origin proof, and equal physical maps do not mean equal
  interfaces. No origin registry, method or signature record, `Lmx` member,
  atom metadata or companion graph is added; the written call and actual nodes
  keep their order.
- **Unknown provenance is not proven incompatibility.** The rule "token absent
  or unlisted, therefore the ordinary `implements` throw" is rejected: a valid
  received value must not fail because this call site did not enumerate it.
  A site whose actual interface or input formation cannot be represented yet
  keeps a located CHECK diagnostic and is recorded as an OPEN positive
  implementation failure, never as an expected negative. A statically known
  inadmissible call is refused normally; a supported runtime-selected call
  with genuinely missing inputs uses the ordinary runtime admission boundary.
  The ban on the source-name table for execution binding stays
  ([author question, answered 2026-10-04](../LMX_blog/q/graph-hidden-input-name-binding.md));
  zero arguments are not manufactured.
- **Order for a supported, proved alternative.** Evaluate the target once and
  keep that occurrence. Prepare only its selected complete inputs, once, in
  the established lexical order, into typed temporaries. Source priority: the
  caller's nearest current local, then the inherited dynamic input, then the
  actual callee's eligible lexical source. Argument evaluation may itself run
  user code; stop and throw propagate at once. Then the required pre-call
  dirty publication, then dispatch of the same selected occurrence through
  the common route. The reference cell is not re-read after its inputs are
  prepared, and publication does not move before argument evaluation
  ([working state](../docs/LMX_semantics.en.md#dynamic)).
- **Witnesses required with the mechanism:** two interchangeable actual
  bodies that need `x` versus `y` at identical ABI positions and types; the
  actual copied lexical parent; a genuinely missing input; replacement of the
  same resolved reference cell; cleared and replaced native-word dispatch. A
  copied loop without hidden inputs is not sufficient evidence.

This does not close the unknown-origin route described in
[the namespace source-layout ledger](critical-graph-namespace-source-layout-20261003.md);
the critical ticket stays OPEN.

<a id="checkpoint"></a>
## 10. RED development checkpoint of the sandbox

Codex confirmed in the same reply that no author instruction forbids a clearly
disclosed red development checkpoint; leaving the inherited sandbox
uncommitted had been provenance discipline. The sandbox dependency closure is
therefore committed to `main` as preservation of work in progress.

- **Scope:** 345 paths, each listed with its SHA256, origin and gate in the
  [manifest](fable-checkpoint-20261003.md): the sandbox sources and fixtures
  under `dev/l2src_sandbox/`, one L3 selftest, and four tool files. 312 are
  the tree received at the takeover, byte for byte; 32 were changed and one
  was created by this continuation.
- **Not included:** stable `l2src/` (unchanged), `build/`, binaries, backup
  archives, and the stray `l2_driver_launch.err`.
- **Byte tie:** before staging, every path was hashed and compared with the
  copies the gates had staged. 315 paths have a byte-identical staged copy in
  `fable_full_04`, `fable_kernel_01` or `fable_l3_01`; no staged copy differs.
  The 30 paths without a staged copy are 26 inherited fixtures that no harness
  row names (UNGATED: their edit removes the old `L2:` wrapper and no gate
  executed it) and four tool files. No path contains a carriage return or a
  control byte, so the `eol=lf` filter leaves the blobs equal to the tested
  bytes; the index blobs were re-verified after `git add`.
- **Evidence attached to exactly these bytes:** `fable_full_04` RED 70/1401
  against the baseline `fable_full_01` RED 126/1395 (56 FAIL→OK, 0 OK→FAIL,
  six added targets pass, none removed); `fable_kernel_01` GREEN 292 targets
  with 109 executed selftests; `fable_l3_01` 11 suites and four budgets;
  `tools/test_l2_walk_graph_facts.ps1` 21 controls.
- **Retained failures:** the 70 rows are listed by name in the
  [manifest](fable-checkpoint-20261003.md) and by mechanism in
  [section 7](#remaining). Every one stays a required row; none was removed
  or relabelled to make the checkpoint.

The checkpoint is not a release, not a green kernel, not a ticket closure and
not self-build readiness. Both critical tickets and stages 8/8a remain OPEN.
Later slices are committed separately with their own evidence.

<a id="machine-operators"></a>
## 11. Native-only machine operators: address arithmetic, raw element address, foreign record index

**Norm.** `@array[i] + n` and `@array[i] - n` are the element's address, C
address arithmetic ([D-24](d24-addr.md): in a method this is C pointer
arithmetic, not a walker node). L2 operations that need a machine address or
raw memory are absent from an interpreted body
([levels](../docs/LMX_semantics.en.md)); the retained graph still keeps every
written occurrence in source order.

**Implementation** (`dev/l2src_sandbox/l2trans.lm1`, symbols):

- `l2_rw_machine_operator`: a written machine operator is one
  `SOURCE_MACHINE` node named by the operator's own spelling, holding exactly
  its operand places in source order. It marks the body native-only.
- `l2_rw_machine_offset` (from `l2_rw_bin`): `+` or `-` whose result is a
  reference is retained with both operands, each built by its own static
  type. The former refusal `arithmetic on a reference` is gone for `+`/`-`;
  `* / %` on a reference stays refused.
- `l2_rw_address_rest`, `l2_rw_span`, `l2_rw_span_ty`: `@ p[i]`, the address
  of a raw element, is the address operator over the existing machine index;
  its type is a pointer to the element type.
- `l2_foreign_record_pointer`, `l2_raw_index_text`, `l2_raw_index_span`: the
  element of a pointer to a foreign by-value record (`structure[0]` under
  `c.sizeof`) is a raw index whose element is C storage without an L2 value
  type. A Structure reference and a void pointer are not such storage, and
  nothing indexes the element further.

No check was loosened: `@: int q 1 + 2` and `q: 1 + @ buf[0]` are still
refused by the native check, and
`unit_addr_own_array_arithmetic_refused` keeps its refusal.

**Verification.**

- `fable_ptr_01` (focused) GREEN 39/39: `unit_addr_own_array_arith`,
  `unit_addr_own_array_element`, `unit_rhs_reference_admission` and
  `unit_rhs_compound_admission_refused` translate and run; the neighbouring
  address and receiving rows are unchanged.
- New witness `graph_shape_machine_address` (288 checks, both methods really
  store through the computed addresses) and its twin under the method-walk
  knob. Path oracle: the `@` operator over the `[` index with the formal and
  the literal; the `+` operator over the element address and the count; both
  native words. Three shape mutants null one operand each.
- Translator mutant (`fable_fbv_mut_01`): with the native-only mark removed
  from `l2_rw_machine_operator`, `graph_shape_walk_machine_address` goes red
  (`tested method l2_m1 has no native implementation word`). The live file was
  restored and its hash re-verified.

**Gap seen, not changed.** A pointer difference `q - r` is typed as a
reference by the shared expression typing and is refused where a number is
asked. No row needs it; it belongs to the K08 arithmetic typing.

<a id="foreign-value"></a>
## 12. Foreign by-value inputs and results

**Norm.** A foreign by-value actual or result uses the exact declared C type
([core map](../CORE_L2_L3_v2.md), section 8.2); the graph has no cell type
for it. A method's own declared part already represents such an input as one
named empty place.

**Defect found — the graph producer failed without a diagnostic.** A read of a
formal of foreign by-value type built an `ARG` whose witness asks for a typed
cell. The count pass accepted it; the fill pass returned an error from
`l2_rw_witness` with nothing said (`internal: a refusal said nothing`). It had
been hidden behind earlier located refusals in `parser_alloc_port`.

**Implementation.**

- `l2_foreign_value_ft`: a foreign C type held by value, by its formal code.
- `l2_rw_input_witness`: the witness place of such an input stays empty, as
  its place in the method's declared part does, and the body is native-only.
- `l2_rw_call`: a call whose result is a foreign value (trampoline class 6) or
  that has a foreign by-value input is retained whole, with every written
  actual at its place, and marks the caller native-only. The refusals
  `a call whose result is not a number` and `a call with an input that is not
  a number` remain for anything else.
- Driver: a new path fact `nullpath` (the holder exists and the named place
  holds no object).

**Verification.**

- `fable_fbv_01` (focused): `unit_uniform_foreign_results`,
  `unit_uniform_aggregate`, `parser_alloc_port` and `parser_trailer_role` pass.
- New witness `graph_shape_foreign_value` (363 checks) and its twin under the
  method-walk knob: the empty declared input place, the empty `ARG` witness,
  `kind(41)` as a `CALL` of kind's own occurrence with its literal, the nested
  `read(echo(make()))` with each callee identity, five native words. Four
  shape mutants; the witness mutant moves the input ordinal into the witness
  place and carries only the `nullpath` fact, so that fact is shown to fail.
- Translator mutant (`fable_fbv_mut_02`): with the three native-only marks of
  the by-value transport removed, `graph_shape_walk_foreign_value` goes red
  (`tested method l2_m3 has no native implementation word`): `probe`, whose
  only machine operation is the by-value call, would have been handed to the
  interpreter. A first version of the fixture did not reach this witness (its
  caller was native-only for another reason); the method was added for it.
- The first version of the fixture also met the known OPEN defect
  [NONTHROW-AGGREGATE-STOP-ABI](defects.md#nonthrow-aggregate-stop-abi)
  (`return 0` in a C function returning an aggregate). The fixture declares
  `throws:` on the aggregate method, as `unit_uniform_aggregate` does; the
  defect is not repaired here.

<a id="head-role"></a>
## 13. Head role of a name that only a caller supplies (Codex, FABLE-CODEX-20261003-04)

Five red required positives share one implementation cause:
`l2_collect_asgn_binds` runs before any dynamic input exists, so
`l2_local_ns_shape` makes `h: tail` a local named Structure definition and
the later read finds that local row. I proposed that a caller's same-named
binding makes the head known. Codex rejected it: that conclusion was
withdrawn on 2026-10-03 ([free names](free-names.md)), and
`unit_free_write` / `unit_free_write_literal_refused` keep the opposite
(`k: 1` stays a definition although the caller has `int: k 5`). The split:

| Row | Status |
| --- | --- |
| `unit_own_dirty_rhs` | Decidable: an executable free read of `quote` precedes both writes and is an independent input-use fact. The early definition row must not suppress it. Needs the deferred head-role decision described in [the pointer-fix ledger](critical-graph-pointer-fix-20261002.md). |
| `unit_arg_addr_dyn_types` | First audit its `setnull(@: dp)` spelling against the current unary `@` / `@:` receiver contract; the pointer ticket is OPEN. |
| `unit_colon_hidden_update`, `unit_free_conv`, `unit_walk_free_conv` | No independent preceding use. Both readings are self-consistent; the tie-break is [asked of the author](../LMX_blog/q/current/head-role-hidden-input-fixed-point.md). Expectations stay as they are, red. |

A body reached through a callable formal or a path follows the same rule as a
directly called one. Once a name is established as a required input, each call
supplies it by the ordinary priority, and only absence from every eligible
source is a missing input.

<a id="full-05"></a>
## 14. Full gate after sections 11 and 12

`fable_full_05` completes **RED 62/1412** on translator SHA256
`51C6CFF48C86F262D8023E151AE477769E0F150B5E9CD5D90943935E4061EB69`
(staged Git blob `bbc7737b847cd2a8e53e6fddc5eff6ba032463ec`), driver
`44A72173A401DB4B68F16BA3300D42422FD7A16977396CAFE9CC4AE200140E0C`, harness
`4CD9EEA8EF9CE9F3668DC680CE9E686486461B8B2D616C3BCA052A0D46C296C7`.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_04` (RED 70/1401) | 8 | 0 | 11, all OK | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 64 | 0 | 17, all OK | 0 |

The eight recovered rows are `parser_alloc_port`, `parser_trailer_role`,
`unit_addr_own_array_arith`, `unit_addr_own_array_element`,
`unit_rhs_compound_admission_refused`, `unit_rhs_reference_admission`,
`unit_uniform_aggregate` and `unit_uniform_foreign_results`. No retained
failure changed its message. The kernel and L3 gates were not rerun: no kernel
source changed, the driver is harness code, and the kernel gate does not build
the translator. A red generated harness is not a release; 62 rows remain.

Other triage recorded while the gate ran, no code change:

- `unit_indent_stack_field_index`: the native composite typing reads an
  unknown foreign raw index as an untyped literal and then asks for an
  `int` to `size_t` converter ([defect](defects.md#native-raw-index-literal-type)).
- `entry_array_leading_zero`: `08` is not a C99 integer literal; the earlier
  ledger already records the row's expectation as invalid. It needs a located
  literal diagnostic and a migrated expectation, not the old index shortcut.
- `unit_s7_ret_field`, `unit_s7_ret_deep`, `unit_s7_arg_deep` still carry the
  legacy `Rich: p` setup inside a definition and need the same deliberate
  migration as section 2 before their producer is judged.

<a id="nested-array"></a>
## 15. Arrays in nested bodies, an opaque foreign index, a located literal

**An Array declared in a nested body.** The one layout (`l2_layout_owns`)
already gives every field of a nested body a child place in that body, an
Array's descriptor included, and the native emission reads it there. The
graph producers named only method-level Arrays. `l2_rw_array_placed` is the
single relation "this own field has a physical place for a descriptor"; the
declaration statement and the element producers use it, and the element
operations name the nested body as the holder of their `AT`. The interpreter
capability follows: such an Array no longer keeps its method out of the walk
(`l2_rw_may`), so under the method-walk knob the body really runs in the
interpreter.

- Recovered: `unit_array_index_shadow`, `unit_address_array_descriptor`,
  `unit_array_value_projection`.
- New witness `graph_shape_nested_array` (206 checks) and its walked twin
  (`WalkedMethods`): the nested body's descriptor at its child 0, the store's
  `AT` holding that very body (`samepath`), the method-level store's `AT`
  with no holder (`nullpath`), the two descriptors distinct, and the same at
  the root, which is walked in both rows. Two shape mutants null a holder.

**An unknown foreign raw index is opaque** (`NATIVE-RAW-INDEX-LITERAL-TYPE`,
fixed in the sandbox). The native span typing returned "literal" for a raw
index whose element type L2 does not know, so `return: stack\columns[idx]` in
a `size_t` method asked for an `int` to `size_t` converter. It is now untyped
there, as every other foreign path is; the C compiler checks it. Recovered:
`unit_indent_stack_field_index`.

**A located literal diagnostic.** `08` is not a C99 integer literal
([grammar](../docs/LMX_grammar.en.md)); the earlier ledger already records
that the old index-only decimal reading must not come back. The refusal was
the generic `unsupported body`. It is now said at the literal: an invalid
octal digit, a valid octal literal without a producer (debt, not a rule), or
another token that starts as a number. `entry_array_leading_zero` is migrated
from a positive to that refusal.

<a id="held-call-step-one"></a>
## 16. Held-call boundary, step one: one proved alternative

This is the bounded lowering the ruling of [section 9](#held-call-ruling)
allows, for one case only.

**The case.** `R: merge S`, with exactly one named Structure and no body,
then a call of `R` in the body that declares it.

**Proof that the declaration determines the executed body.** For a merge of
one operand without composition the kernel returns the copier's completed
occurrence (`lmx_merge_profiles_owned`): S's body, its nested occurrences and
its native word (`lmx_graph_copy_owned` carries `native` verbatim). The merge
record keeps that operand's layout (`l2_mres_source`, set only for this
form).

**Proof that the row still holds that value at the call.** Measured on the
current translator: a second `R: merge T` is an argument-bearing call of the
existing R and is refused; `@: R other` is not a rebinding form; a
`receiveMessage: R` after it is a new occurrence whose call stays refused;
whole-Structure assignment through a path is refused. The one remaining way
to the reference cell is its address. Every address-of that names a merge
result row is recorded (`l2_address_target`), every call of such a row is
recorded (`l2_copy_call_note`), and when all bodies are read a called row
that is addressed is refused at the call (`l2_copy_calls_verify`) with
`the called Structure's reference cell is addressed: calling its current
value is not supported yet`.

**Proof of the input contract and of the lexical parent.** The inputs are
the hidden inputs of S's procedure, formed in order from the caller's
bindings and then S's lexical source, as for a call of S. The copy's lexical
parent is the body the merge is reached in; the row is accepted only when
that body is the one that lexically owns S (`l2_own_copy_origin`), so both
parents are the same Structure. The call dispatches the value the row holds
(`lmx_call_prim` over the slot, `EXEC` over the row's own output operand),
never the prototype.

**What is not done.** Selection among several alternatives, a body reached
through a callable formal or a path, a copy of a copy, a copy of a method's
own Structure, a copy declared in another body than its Structure's owner, a
method calling an outer copy by a free name, an addressed row. Each keeps a
located diagnostic and is a required positive, red by design:
`unit_copy_call_from_method`, `unit_copy_call_other_owner`,
`unit_copy_call_local_structure`, `unit_copy_call_of_copy`,
`unit_copy_call_addressed`. The universal route still waits for
[the author's answer](../LMX_blog/q/graph-hidden-input-name-binding.md).
The critical ticket stays OPEN.

**Verification.**

- Recovered: `unit_named_until_copy_call` (+ walk),
  `graph_shape_ns_source_nested_copy` (+ walk_methods: the copied child runs
  over the copied parent, the prototype's tag stays 9),
  `unit_named_struct_exec_instance`, `unit_named_struct_exec_two_types`,
  `unit_model_var_call`, `unit_empty_type_call_method` (a copy of an empty
  Structure runs nothing).
- New witness `unit_copy_call_hidden_inputs` and its walked twin: A needs the
  free name x, B the free name y, same type and position; each call hands its
  copy the caller's current value of the right name, a changed working value
  included. Path oracle: each `EXEC` targets the very output operand its
  row's declaration produced and carries the caller's cell of that name as
  its one hidden input; two shape mutants.
- Translator mutant (`fable_held_mut_03`): every copy takes the first merge
  result's layout. Both hidden-input rows go red (rb receives x). The older
  `unit_named_struct_exec_two_types` stays green under the same mutant: it
  has no hidden input, so it cannot see a wrong contract. The live file was
  restored and its hash re-verified.
- `unit_copy_call_missing_input_refused`: the copied body needs z, which
  nothing supplies; refused at the name (`unresolved name`).

<a id="full-06"></a>
## 17. Full gate after sections 15 and 16

`fable_full_06` completes **RED 54/1426** on translator SHA256
`02EA78FD4C25A942C5FCB9B0899CEA99E39C2F6E066455D58DE1875F9CA282F4`
(staged Git blob `37a45a8f3d8dc8f8270144b6e0ea4db4208cf18b`), harness
`4A55E9C1D4D8C2A5E99E13239F611499AE36CA5548E81B41053D7339D79F94B1`, driver
unchanged from section 14.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_05` (RED 62/1412) | 13 | 0 | 14: 9 OK, 5 open positives red by design | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 77 | 0 | 31 | 0 |

No retained failure changed its message. The kernel and L3 gates were not
rerun: no kernel source changed.

The 54 red rows: the five open held-call positives above and
`unit_held_nullary_source_field`; nested admission maps (3); capture of a
merge-result local (2); the `1U` rows (4, K08); the head-role family (5 and
`unit_asgn_fallback`, [section 13](#head-role)); the letter Array-of-Array
element contract (5); reception into a model (3); a Structure value in a
return or argument (3); `unit_t7_convert`, `unit_named_actual_whole`,
`unit_eternal_shape`; `unit_bind_method_thin_other`; and 18 stale oracle
rows. A triage of those 18 against the norm was prepared while this gate ran
and is applied as the next slice.

<a id="triage"></a>
## 18. Normative triage of the stale oracle rows

No translator, walker or driver byte changes in this slice: fixtures and
harness rows only. Each row's expectation was compared with the norm before it
was changed; a red row was never repinned to what the translator happens to
say.

**Norms used.**

- Head resolution ([dictionary](../next_core_tasks_dictionary_v2.md#head)):
  an unknown ordinary head in definition position defines a named Structure
  and retains its tail without executing it. The earlier reading "an absent
  head with a literal tail is an unresolved call" is historical
  ([status note](free-names.md), [section C](generated-diagnostic-migration-20260930.md#unknown-head-10)).
- The root is compiled like every body
  ([scope](../docs/LMX_semantics.en.md#scope)); `L2 operation outside a method
  body` is withdrawn.
- For an existing named Structure `A`, `A: b` in a body selects the call
  route and is a call error (a named Structure has no arguments); it declares
  nothing. The setups now say what they mean: a copy `b: merge A`, and for the
  letter a typed reference, `@: MainLetter m`.
- A refusal that pins an implementation limit is not a rule. The valid program
  becomes a required positive and stays red until its mechanism exists.

**Rows that are green now.**

| Row | Was | Decision |
| --- | --- | --- |
| `unit_next_message_word_refused` → `unit_next_message_word_definition` | refusal `6:18: unresolved name` | `nextMessage` is not a language word: `nextMessage: m` defines a named Structure, nothing runs. Entry 7. |
| `entry_ret_tr_bad` | refusal `1:1: unresolved name` | `idle: 1` at the root defines `idle`. Entry 7. |
| `unit_s7_part_root_below_refused` → `unit_s7_part_root_below_definition` | refusal `4:5: unresolved name` in the part | `bump` stands above the part's field `k` and has no established `k`: its `k: 7` defines a Structure, the field keeps 5 (read by `peek` below the declaration). The same rule as `unit_free_write`. New part file; the old part stays with `unit_site_part_caller`. |
| `unit_puts_main_beside_method` | refusal `L2 operation outside a method body` | The line is printed (`Says`), exit 0. |
| `unit_addr_slot_structure_projection` | the same withdrawn refusal | Positive again, unchanged text. |
| `unit_addr_entry_name_collision` | the same withdrawn refusal | Positive with `fresh: merge Model`; the five locals print `1 2 3 4 5`. |
| `unit_root_model_field` | three generated-text pins of the legacy `Model: m` lowering | `m: merge Model`, `n: merge Model`; the behaviour (entry 15) is the witness, one text pin names the merge primitive. |
| `unit_field_path_unit_colon` | two text pins of the legacy lowering | `fresh: merge Model`; behaviour and the merge primitive. |
| `unit_matrix_callable_struct_identity` | one text pin of an `OWN` frame | `m: merge Model`; three `samepath` facts: each call admits the very output operand `m`'s declaration produced. |
| `unit_make_adder_activation` | pin `lmx_arena_ref_store(l2_madc, 2U, …)` | The copied host field `k` stands at its source slot 3: the statement before its declaration is a retained child too. The pin follows the source-faithful layout. |
| `unit_occ_selector_last_refused` | red: refused first at `16:30`, for a `size_t` to `int` conversion of its own result that the program does not supply | The fixture's own defect repaired (the method returns `int` through an explicit cast), setup `c: merge Cand`; it now refuses with its intended admission message. |
| `unit_occ_selector_first_refused` | green | Setup migrated to `t: merge Tri`; refuses as before. |

The `samepath` facts of `unit_matrix_callable_struct_identity` can fail: on the
staged binary of `fable_triage_01` the same pair claimed `differentpath` is
red, and the admitted operand compared with the neighbouring operand `(2,2)` is
red as `samepath` and green as `differentpath`. The program itself exits 90
when a call receives a copy.

**Required positives that stay red** (setup migrated, mechanism open):

| Row | Refusal now | Mechanism |
| --- | --- | --- |
| `unit_arr_path_read` | `16:5: an indexed field path needs a root of a declared Structure type` | an indexed field path whose root is a merge result |
| `unit_array_write_general_root_real_field` (redesigned: a store into the copy, the model's Array and an own Array as controls) | `12:5: unsupported index` | the same |
| `unit_capture_struct_whole_refused` → `unit_capture_struct_whole` (redesigned: `probe(loc)` reads the captured copy, 40 + 2) | `20:23: … not walkable yet: this operand` | capture closure for a merge-result local |
| `entry_arg_len`, `entry_parse_min`, `unit_charpp_return`, `unit_l2_puts_library` (setup `@: MainLetter m`) | `the Array element has no supported value contract` | the letter's Array-of-Array element contract (K06/K07) |

**Left as they are.** `unit_arr_path_variable_index_refused`,
`unit_arr_path_inner_value_refused`, `unit_arr_path_three_refused` belong to
the letter element contract and change with it. `unit_asgn_fallback` waits for
[the author](../LMX_blog/q/current/head-role-hidden-input-fixed-point.md).
`unit_bind_method_thin_other` is a runtime failure, not an oracle question.

**A control for section 15's literal row.** Mutant M4 (`fable_lit_mut_04`)
makes `l2_num` accept a leading zero as decimal again.
`entry_array_leading_zero` goes red and `entry_array` stays green. The literal
is still refused under the mutant, by the `size_t` representability check
(`5:8: literal not representable as size_t`), so the row witnesses the located
message; a decimal reading of `08` is closed in two places. The live file was
restored and its hash re-verified.

<a id="full-07"></a>
## 19. Full gate after section 18

`fable_full_07` completes **RED 43/1426**. Translator, walker and driver are
the bytes of section 17 (staged translator blob
`37a45a8f3d8dc8f8270144b6e0ea4db4208cf18b`); harness SHA256
`A0472D5C50ACE10713D12011F50D157C0D41E3EC54EB1C5661CF9602F5D1F107`. Every
changed fixture was hashed before the run, and the staged copy and the
committed file have that hash.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_06` (RED 54/1426) | 9 | 0 | 3 renamed: 2 OK, 1 open positive | 3 (their old names, all red) |

Three retained failures changed their message, by design: `entry_parse_min`,
`unit_arr_path_read` and `unit_array_write_general_root_real_field` were
`refused, but not with …` and are now positives the translator refuses. The
kernel and L3 gates were not rerun: no kernel source changed.

The 43 red rows by mechanism:

| Mechanism | Rows |
| --- | --- |
| held-call boundary, the rest | five `unit_copy_call_*` open positives, `unit_held_nullary_source_field` |
| letter Array-of-Array element contract | `entry_arg_len`, `entry_index`, `entry_strcmp`, `entry_parse_min`, `unit_charpp_return`, `unit_l2_puts_library`; the three `unit_arr_path_*_refused` rows |
| head role of a dynamically supplied name | `unit_free_conv`, `unit_walk_free_conv`, `unit_colon_hidden_update`, `unit_own_dirty_rhs`, `unit_arg_addr_dyn_types`, `unit_asgn_fallback` |
| C99 common arithmetic (K08) | `unit_callable_forward`, `unit_callable_nullary_forms`, `unit_callable_returning_two_contracts`, `unit_callable_sub_transport` |
| nested admission maps | `unit_d112_nested_return`, `unit_d113_nested_expr`, `unit_s7_nested_shape` |
| capture of a merge-result local | `unit_capture_struct_own`, `unit_capture_struct_call_arg`, `unit_capture_struct_whole` |
| reception into a model | `unit_receive_letter_model`, `unit_send_ref_method`, `unit_send_ref_driver_tap` |
| Structure value in a return or argument | `unit_s7_ret_field`, `unit_s7_ret_deep`, `unit_s7_arg_deep` |
| indexed field path with a merge-result root | `unit_arr_path_read`, `unit_array_write_general_root_real_field` |
| single rows | `unit_t7_convert`, `unit_named_actual_whole`, `unit_eternal_shape`, `unit_bind_method_thin_other` |

No stale negative expectation is left among them except the three letter rows
and `unit_asgn_fallback` named above.

<a id="merge-result-array"></a>
## 20. An indexed field path whose container is a merge result

**Cause.** The general Array place (`l2_array_place_contract`) takes the
element contract from the declaration of the path's leaf.
`l2_path_resolve_contract` found that declaration for a field of a declared
Structure and for a hosted own field, and not for a slot of a merge result:
the slot map (`l2_mrs_*`) kept each slot's name, kind and type and not the
field that contributed it. So `a\buf[i]` with `a: merge Holder` had no
contract, while `o\inner\buf[1]` already worked: after the first segment the
container is a declared Structure (measured before the change).

**Mechanism.** Each slot of a merge result keeps the field row that
contributed it (`l2_mrs_row`): the model's row for a slot that later operands
went into (the merge rule makes their types equal), the same row through a
result used as an operand (a copy of a copy), and none for a copied step or
a body pair of a new name. `l2_mrs_slot_row(res, slot)` is the one reader.
Consumers:

- `l2_path_resolve_contract`: the leaf's declaration, hence the element
  contract of the general Array place, for reads, stores and their graph
  twins;
- `l2_path_arr_leaf` and `l2_arr_operand`, which `length(P)` still goes
  through: a merge-result container is a typed one, and a nested result is
  followed as `l2_path_resolve_contract` follows it.

**The address of an element through a path, `@ P[i]`, in the retained
graph.** The native emission had it; the graph producer refused it
(`this operand`), which was the hidden second failure of
`unit_arr_path_read` even with its legacy setup. `l2_rw_array_place_address`
builds `ADDRESS` over the very `ELEM` operand a read of that place has, typed
as a pointer to the element, as the own-Array form does (`l2_rw_indexed`).
The interpreter's `ADDRESS` already resolves any `ELEM` place.

**Verification.**

- Recovered: `unit_arr_path_read` (at the root: reads, `length()`, the
  address of an element, a typed formal, the model unchanged) and
  `unit_array_write_general_root_real_field`.
- New `unit_arr_path_merge_result` and its walked twin (`WalkedMethods`
  0, 1, 2): a merge of two operands with an `int` Array from the model and a
  `char` Array from the later operand, a variable index, a copy of a copy,
  the address of an element; every store lands in the copy and the operands
  keep their contents.
- Translator mutant `fable_mres_mut_first` (every slot answers with the
  result's first row): `unit_array_write_general_root_real_field` and both
  new rows red (`18:14: the program has no method lm_stg_convert_char_int`:
  the `char` Array took the `int` Array's contract). Mutant
  `fable_mres_mut_nocopy` (a row taken from another result loses its field
  row): both new rows red (`32:5: unsupported index` at `p\buf[1]`).
  `unit_arr_path_read` stays green under both: its Array is the first row of
  its Structure and it has no copy of a copy, so it cannot see either. The
  live file was restored and its hash re-verified after each.
- Probes, not gated: a path naming no field of the result next to an
  unrelated own Array of that name is refused (`unsupported index`), and so
  is an index after a body pair of a new name.
- Focused `fable_mres_01`: 48 targets, 0 failed, with all 36 `unit_merge*`
  rows unchanged.

<a id="capture-copy"></a>
## 21. A nested method captures a whole copy

`loc: merge Model` in the host, and a nested method that reads `loc\value`.
The capture record took the host field's declared type
(`l2_own_nsty_get`); a merge result has none, the name stayed unrecorded and
the walk of the nested method refused `a field path`.
`l2_own_capture_ns` is the type a capture has: the declared type, or for a
whole copy `x: merge S` the Structure S it copies (`l2_own_copy_layout`, the
relation of [section 16](#held-call-step-one): one named Structure, no body,
so the copy is S's completed occurrence with S's fields at S's slots).

- Recovered: `unit_capture_struct_own` (two readers, 42 and 9) and
  `unit_capture_struct_call_arg` (82). Before the change both refused at the
  captured read; focused `fable_cap_01`, 46 targets with every capture,
  callable-merge and copy-call row, shows only the six open positives red.
- `unit_capture_struct_whole` now reaches its own limit:
  `20:23: a captured Structure used whole (item 738: its fields are read)`.
  The node a host's return builds carries a copy of the fields the method
  reads, with holes; a whole use needs the complete value. Open, with the
  capture closure.
- Not covered, measured: a host copy of two operands (`loc: merge A B`) has
  no single Structure to name and is still refused at the read
  (`a field path`). It is a valid program and becomes a required positive
  with the next slice.

<a id="full-08"></a>
## 22. Full gate after sections 20 and 21

`fable_full_08` completes **RED 39/1428** on translator SHA256
`FF719E8C7F7A41CFE2F7C4F4C5D5CA4B7FC5755BCCE2DE34534BDA632474083A`
(staged Git blob `90b6d8724052ff1a1f5fba88dfd2cc3204c8d7ee`), harness
`B198DE9366FA0F5D2D3A5ADD8A80605D8A2EECEA71C6FE96A37A23112E30B9BF`,
walker and driver unchanged.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_07` (RED 43/1426) | 4 | 0 | 2, both OK | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 90 | 0 | | |

The kernel and L3 gates were not rerun: no kernel source changed.

<a id="receive-model"></a>
## 23. Reception into a letter model, `receiveMessage: m T`

**The form.** The two-name receive types `m` with the synthesized letter
model `{sender; payload: T}` and `m` holds the whole letter. The native
emission takes the next letter and admits the whole letter to that model.
The graph producer (`l2_rw_take`) built the one-name form only, where a
pre-typed `m` receives the letter's payload, and refused the two-name form
as `an admission to a Structure type`.

**The producer.** The same two steps as natively:
`PUT(m, admit(take, letter model))`. The kernel already has both admissions,
of a whole value (`lmx_walk_admit`) and of a letter's payload
(`lmx_walk_admit_letter`); the form selects one. No kernel change.

**A defect found by the first interpreter run**
([RECEIVE-MODEL-ROOT-STEP-DROPPED](defects.md#receive-model-root-step-dropped),
fixed in the sandbox). At the root the statement was absent from the retained
graph. The synthesized model is a unit-level Structure whose recorded place
is the receive statement that first names it; the root's statement list took
that statement for the model's definition, stored the model's instance at the
statement's source child and built no step. The native root ran correctly;
the interpreter, run over the same root with its native word cleared, read an
`m` nothing had assigned. Two smaller probes passed by accident (`m = 0` and
`m\sender = 0` read the Structure that happened to stand at that child); the
read of `m\payload\mainArgs` failed with `walk error: INVALID`. A synthesized
letter model is not a source definition (`l2_ns_synthesized`): the statement
keeps its own child and step, and the model's instance stands in the unit's
tail, as it already did for a receive written in a method.

**Verification.**

- Recovered: `unit_receive_letter_model`, `unit_send_ref_method`,
  `unit_send_ref_driver_tap` (natively).
- The interpreter runs the new step: `unit_receive_letter_model_walk`
  (`WalkedMethods` 0), `unit_send_ref_driver_tap_walk` (the reply reaches the
  sender, `reply-to-sender 1`), and the new `unit_receive_letter_model_root`,
  where the root takes the letter, reads `m\sender` and
  `m\payload\mainArgs`, and posts its exit to the sender explicitly
  (`sendMessage: m\sender exit(...)`, entry 7). That row is the first
  positive of an explicit addressee at the root; the harness comment that
  none was possible is now out of date and is kept as history.
- Translator mutant `fable_recv_mut_payload` (the two-name form admits the
  payload, as the one-name form does): the three interpreter rows red, exit
  1; the native rows stay green, they do not run the graph. Mutant
  `fable_recv_mut_source` (a synthesized model is a source definition again):
  the root row red, `walk error: INVALID`, exit 3; the method rows stay
  green, their statement was never a root child. The live file was restored
  and its hash re-verified after each.
- Focused `fable_recv_02`: 26 targets with every receive, send-reference and
  letter row; the two open letter-contract rows red, nothing else.

**Also in this slice.** `unit_capture_struct_merge_two` is the required
positive promised in [section 21](#capture-copy): a captured copy of two
operands, refused at the read (`a field path`), red by design.

<a id="full-09"></a>
## 24. Full gate after section 23

`fable_full_09` completes **RED 37/1432** on translator SHA256
`EBCBFF5821200A5F8B417A2CD70EEE562754A5FFF1524682CF42EA5A96A4E781`
(staged Git blob `397083c9a74a4cef24ed0fb2e102410e716e9405`), harness
`07DFB656A269C6C0534BF8C11916D67AF48BDABD1B9553F1B9C389EB4A2B3481`,
walker and driver unchanged.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_08` (RED 39/1428) | 3 | 0 | 4: 3 OK, 1 open positive red by design | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 93 | 0 | | |

The kernel and L3 gates were not rerun: no kernel source changed.

<a id="structure-path-value"></a>
## 25. A field path that ends at a Structure field, as a value

`return: h\p` and `take(h\a\p)`, where the leaf field is a Structure and the
receiver is a reference of another model. Three rows; their setups still used
the withdrawn `Rich: p` field form and were migrated first, as
[section 2](#legacy-setup-migration) does it: the nested definition is written in
place.

**What the migration showed.** With a nested written leaf the checker refused
the program before the graph was reached: `a field path must end at a
Structure`. The route for a Structure-valued path (`l2_actual_path`, its
one-atom spelling and the native `l2_emit_actual_path`) accepted a field of a
named Structure type only (kind 3). A nested written Structure field (kind 2)
is a Structure field with its own declared type; the three places take both.

**The value's source.** The admission of a reference needs to know what the
value is (`L2ReferenceSource`). For a path it said nothing, so no pair map was
prepared for the leaf's type and the receiving model.
`l2_reference_path_leaf` gives the Structure the leaf field declares, which
is also what the field physically holds: a whole Structure is never assigned
through a path. One reader, `l2_path_field_leaf`, now walks a typed path for
both its Array leaf (section 20) and its Structure leaf. The check, the
native emission and the graph take the source from the same call, so the pair
is prepared once and both engines use it.

**The graph.** Where a reference is received, a path is read as the path's
reference (`l2_rw_path_reference`, the producer callable paths already use);
a number is still never read from a Structure (`l2_rw_path_read` keeps
`a Structure value`).

**Verification.**

- The three rows were strengthened while they were migrated. They used to
  call a callee that wrote a field and returned a constant, so nothing
  observed which Structure had arrived. Now the leaf has an unread `extra`
  before its `equals`, Equatable has `equals` alone, the callee writes
  `equals` through the admitted reference and returns what it reads, and the
  root checks the callee's value, the leaf's `equals` in `Holder` itself and
  the untouched `extra`. A positional admission would write `extra`.
- Recovered: `unit_s7_ret_field`, `unit_s7_ret_deep`, `unit_s7_arg_deep`
  (`NativeMethods` 0, 1, 2), each with a walked twin (`WalkedMethods` 0, 1,
  2 and the root).
- Translator mutant `fable_sval_mut_noschema` (the path's leaf gives the
  admission no source): all six rows red at run time, natively exit 3 and
  walked exit 1; the neighbouring negatives and `unit_s7_ret_rich` unchanged.
- New negative `unit_s7_ret_nested_refused`: a nested leaf without the
  required field is refused, `15:1: implements is false in return value`.
  Two checks hold it: the one at the return statement and the check of the
  sources that reach a result place. A mutant of the first alone
  (`fable_sval_mut_retadmit`) does not reach it, the row stays green; with
  both off (`fable_sval_mut_retadmit2`) the translator accepts the program
  and the row is red, with `unit_s7_ret_name`. The live file was restored and
  its hash re-verified after each mutant.
- Focused `fable_sval_01`: 85 targets around Structure-valued paths, D-105
  and callable rows; the seven red rows are the known open ones.

**Not migrated.** The negative neighbours `unit_s7_ret_path`,
`unit_s7_arg_deep_refused` and their kin keep the `Plain: p` field form and
their pinned refusals. They go with the head-classifier cutover.

<a id="full-10"></a>
## 26. Full gate after section 25

`fable_full_10` completes **RED 34/1436** on translator SHA256
`8EB5C2A9DE87409A2A05C6F5F9EC0FA7CF97BC843E916D1F3FA09EAB3D7BA9D0`
(staged Git blob `866c1780af8ceb86d4393f9d5798ea46ebb509f0`), harness
`858534AC6FED0CA2CCB290BEA3702F9324C4CBE6F525E9B2BFA6AE409D277903`,
walker and driver unchanged.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_09` (RED 37/1432) | 3 | 0 | 4, all OK | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 96 | 0 | | |

The kernel and L3 gates were not rerun: no kernel source changed.

<a id="merge-result-reference-field"></a>
## 27. A reference field of a merge result

Two defects of one cause. The path walkers follow a reference field
`@: T q` into its pointee by asking the declared Structure for the field's
type word; for a slot of a merge result they asked nothing.

- **Read** ([MERGE-RESULT-REFERENCE-FIELD-PATH](defects.md#merge-result-reference-field-path)):
  `h\q\value` with `h: merge Holder` was refused, `unknown field path
  segment`.
- **Store** ([MERGE-RESULT-REFERENCE-STORE-UNCHECKED](defects.md#merge-result-reference-store-unchecked),
  found by a probe of this slice): `h\q: o` stored an `o` of another shape
  into `@: Model q` with no admission and the program ran on; the same store
  through the declared Structure, `Holder\q: o`, is refused by the method's
  implicit throw `implements`.

**Mechanism.** `l2_mrs_ref_pointee(res, slot)` reads the pointee from the
field row that contributed the slot (section 20's `l2_mrs_row`). The three
walkers use it where the container is a merge result: the contract walk
(`l2_path_resolve_contract`, a step and the leaf's receiving model), the
native walk (`l2_emit_path_to`) and the graph walk
(`l2_rw_path_resolve_sized`).

**Verification.**

- New `unit_mres_ref_field_path` and its walked twin: in a method the
  reference is stored, read and written through, the write is seen in the
  Structure the reference holds and not in Model; at the root the same
  through a copy of a copy.
- New `unit_mres_ref_field_store_refused` and its walked twin: the store of
  another shape stops R0 with the implicit throw (`Fails 1`, `Stopped 1`,
  `Thrown 2`), natively and in the interpreter. On the committed translator
  the same program ran to its exit 7 (probe).
- Translator mutant `fable_mref_mut_nopointee` (a merge result's reference
  slot names no pointee): the two path rows do not translate and the two
  store rows run on, all four red. Mutant `fable_mref_mut_noleaf` (the leaf
  model of such a store is unknown again): the two store rows red, the path
  rows green. `unit_ref_rebind_same` and `unit_ref_rebind_other_refused`
  unchanged under both. The live file was restored and its hash re-verified.
- Focused `fable_mref_01`: 77 targets with every merge, reference and path
  row; the three letter rows red, nothing else.

<a id="full-11"></a>
## 28. Full gate after section 27

`fable_full_11` completes **RED 34/1440** on translator SHA256
`3876FDD16BCC02C7097378773B7C9E2EF9E9307078922BC56CE4FFF49F88D634`
(staged Git blob `d8ac3c131071f3509f1913084aee2bf989cdc2c4`), harness
`3B44DE1A907D379A0C009A31A97075D6096609D89422CF5B801C72DA1E57BE45`,
walker and driver unchanged.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_10` (RED 34/1436) | 0 | 0 | 4, all OK | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 96 | 0 | | |

The kernel and L3 gates were not rerun: no kernel source changed.

<a id="receiving-use-mechanism"></a>
## 29. Resolved boundary: the mechanism of the receiving-use contract (Codex, FABLE-CODEX-20261004-01)

[Section 3](#receiving-use-contract) fixed the rule. Before implementing it I
asked about the mechanism and proposed to mark, in the correspondence map, a
required field that the candidate lacks and that this receiving instruction
does not use, with a second "not carried" cell value. Codex answered without
escalating to the author. Nothing is implemented yet; this section is the
boundary the implementation must keep.

**The proposal is not approved as the whole mechanism.** Two gaps:

- An unused field that is present is not compared either. A candidate whose
  ignored field exists with another kind is admissible for a Consumer that
  reads only another field. A marker for missing unused fields leaves that
  case to the full interface walk; turning every unused mapping into a marker
  loses physical positions that exist.
- "Unused by this instruction" must not become a permission attached to the
  cached pair of value and model. The walk takes cached views, nested ones
  included, and the unselected path of the instruction checks a cached
  receiver with no new pending map: an old waiver could skip a newly required
  field, and an erased present field could conflict with a later complete
  map of the same unchanged value.

**Direction.** The shared walk receives both the correspondence's model as
its index space and the current receiving-use projection. The projection may
borrow the instruction's or the compiler's use data. No Structure made per
view, no base field, no name registry, no second graph. A packed map
annotation stays possible only if it shows all of: real physical positions
kept; unused expressed for present and for missing fields; only the current
instruction's coverage consulted; absence normalized for every read, store
and address accessor; ORDINAL and LAST kept apart; nested paths with their
own child index spaces.

**Coverage facts** (the translator's, for a bounded first slice):

- proven uses, empty, unknown. Unknown is never empty; a later Consumer
  applies its own requirements.
- The resolved place and its source occurrences are analysed, not matches of
  a name: shadows, repeated declarations, explicit occurrence paths and the
  exact receiving statement. A rebinding in a loop cannot ignore a read
  written earlier in the body that the next iteration reaches. Visible
  alternative branches are included. No analysis of the algorithm or of
  predicted values.
- A comparison of the reference's identity consumes the reference and none of
  its fields: proven root consumption with no field requirement, by the
  general comparison contract, not by a special case for one spelling.
- Prefixes keep the actual nested leaf consumption and the selector's
  identity; `b\x` as a held reference and `b\x()` as an invocation do not
  require the same of a callable. A flat bitmap of root fields is not the
  arbitrary-depth mechanism.
- A pass as an actual or a return whose downstream receiving contract is not
  composed yet may be unknown in the bounded implementation. That is a
  documented conservative limit, not a rule of the language and not a new
  expected negative. Unknown origin or layout and unknown Consumer coverage
  are different facts.

**Timing.** The executed receiving operation keeps conversion, then the
reached admission, then the store: the candidate is evaluated once with its
effects, the current Consumer's used requirements are checked, and a genuine
failure is the existing implicit throw `implements` before the destination or
its dirty state changes. The failure does not move to translation because
formal call sites are checked statically; the two are different observations.

**Required verification**, natively and actually walked: a known-empty or
root-identity thin positive observing the exact candidate; a missing unused
field accepted; a present incompatible unused field accepted; a missing used
field throwing at the reached binding with the candidate's side effect seen
once and the previous destination kept; one candidate admitted thin, then
received by a Consumer that requires the omitted field and refused; one
candidate with a present compatible field admitted thin, then consumed more
fully with no spurious map conflict; a nested partial path with distinct bare
and `[N]` selectors; unknown coverage never promoted to empty.

<a id="named-actual-order"></a>
## 30. Named actuals: written order of evaluation, kept in the graph

**The defect** ([NAMED-ACTUAL-FORMAL-ORDER](defects.md#named-actual-formal-order)).
The binding of named actuals rewrote the call's body into the formals' order
before any pass read it, and both producers worked from the rewritten list.
Native code evaluated `f(b: mark(1); a: mark(2))` as `mark(2)`, then
`mark(1)`; the interpreter did the same; the retained call held the two
actuals at the formals' places with neither the names nor the written order.
The norm keeps a graph's fields in lexical order and evaluates them in that
order ([fields](../docs/LMX_semantics.en.md#fields),
[callables](../docs/LMX_semantics.en.md#callables)); the core map called the
rewriting a debt. Measured on the committed translator by a probe: the trace
of the two calls was 21, natively and walked.

**Mechanism.** No table of permutations exists at run time and no second
graph: the coordinate is a cell of the operand itself.

- *Binding.* `l2_bind_call_in` records, before it installs the bound list, the
  rank of every formal's actual among the actuals as written and the Frame
  that named it (`l2_bound_add`, read by `l2_bound_rank`, `l2_bound_formal`,
  `l2_bound_wrap`). The record belongs to the call's body.
- *Native code.* `l2_emit_call` counts the actuals, then prepares them in
  written order (`l2_bound_formal`), each into the place of its formal. The
  emitted call is unchanged: values travel by formal position.
- *Graph.* `l2_rw_call` puts every operand at its written place
  (`l2_bound_rank`). A named one is `NAMED [coordinate, payload]`
  (`LMX_WALK_OP_NAMED`, 47) whose source name is the written name of the
  formal; a positional one stands as before.
- *Interpreter.* `lmx_walk_actuals` evaluates the operands in the order they
  stand. A `NAMED` operand hands its payload's value to the formal of its
  coordinate, any other to the formal of its own position. A coordinate past
  the formals, a `NAMED` of another width or with no coordinate cell, and a
  coordinate supplied twice are `LMX_WALK_INVALID`. "Supplied" is a mark in the
  references array, not the presence of a value: an empty actual supplies its
  coordinate too. Outside a call's operands `NAMED` is not an expression.
- The driver's shape grammar reads the word `NAMED`.

**What is not done.** The call's P0 body still holds the bound projection
(the actuals in the formals' order, fresh field cells over the same value
nodes) once the binding pass has run; every later pass of the translator
reads that list. The written cells are untouched and the written order and
the naming Frames are reachable from the binding record, so nothing is lost,
but the P0 body itself is not the written list. Making the body keep the
written list and every reader go through the projection is a refactor of all
call readers and is not part of this slice. The interpreter does not run the
invocation of a callable formal with named actuals: `--walk-methods` excludes
callable formals, so that `EXEC` is witnessed natively and as retained source
only.

**Verification.**

- New `unit_named_actual_order` and its walked twin (root and six methods
  walked): two named actuals against the formals' order, a positional prefix
  followed by two names out of order, and the root's own call; the trace is
  1234567 and every result is the bound one. Path facts on both rows: each
  operand's role, written name, coordinate and payload, in `h`, in `k` and at
  the root. Two shape mutants: the two named operands of `h` exchanged, a
  named operand's payload emptied.
- New `unit_named_actual_order_forms` and its walked twin (root and ten
  methods walked): a sub called as a statement, a call in a condition, an
  operand of an expression, a named actual of another named call, a method's
  `return:` trailer and a sub called by the root.
- New `unit_named_actual_order_callable`: the invocation of a callable formal,
  natively, with path facts on the `EXEC` and a shape mutant.
- Shape oracle changed with the mechanism: `graph_shape_callable_own_init`
  describes `f(x: 3)` as `NAMED [0, LIT 3]` named `x`. Its mutant row is
  unchanged.
- New kernel selftest `lmx_walk_named_actual_selftest` (43 checks), over
  hand-built graphs the translator never writes: four bound calls, and the
  refusals of a coordinate past the formals, of one coordinate supplied by two
  names, by a name and a position in either order, by an empty named actual
  and a name, of a `NAMED` of width 2 and 4, of a missing coordinate cell and
  of a `NAMED` as a returned expression. The "twice" graphs call a callee that
  reads only the doubled coordinate: with `sub2` the refusal was the callee's
  read of the formal left without a value, and the first version of the
  selftest stayed green under the mutant that allows a coordinate twice.
- Kernel mutants, each on a copy of the gate's staged sources, rebuilt with
  the gate's own command lines: a `NAMED` operand supplies its own position —
  8 of 43 checks fail; a coordinate may be supplied twice — the 4 "twice"
  checks fail; "supplied" read from the value's presence — the empty-actual
  check alone fails.
- Translator mutants through a focused harness run, live file restored and its
  hash re-verified after each; the control run of the same 11 rows is green.
  Native evaluation in the formals' order (`fable_named_mut_formalorder`): the
  native rows red, the walked half of the walked twin still exit 0. No `NAMED`
  operand (`fable_named_mut_nowrap`): the order rows, `unit_walk_named_actuals`
  and `graph_shape_callable_own_init` red. Every operand at its formal's place
  (`fable_named_mut_norank`): the order rows red, `unit_walk_named_actuals`
  green, since the coordinates still carry the values. The kernel mutant that
  ignores the coordinate (`fable_named_mut_nocoord`): the native row green,
  the walked twin and `unit_walk_named_actuals` red. The first two translator
  mutants repeated on the forms and callable rows
  (`fable_named_mut2_formalorder`, `fable_named_mut2_norank`) redden them the
  same way.
- Focused `fable_named_01` (235 targets: every named-actual, call and
  graph-shape row) before the oracle change: red only the two
  `graph_shape_callable_own_init` rows and the known `unit_named_actual_whole`.
  Focused `fable_named_02` after it: 17 targets green.

<a id="full-12"></a>
## 31. Full, kernel and L3 gates after section 30

`fable_full_12` completes **RED 34/1448** on translator SHA256
`4CB8CECA9DDCECD083296C302B5E5825EAE36DC2D887D450193FA428B6BF5840`
(staged Git blob `ff9d6951b31d256c9fc9ddaf5d7fa8e5be6e8d55`), walker
`662B61A7C85EC5C241C94E9A092B64221B95E966954DD3CEEC0609BC8EA43B3F`, walker header
`2EA3CEFA10A9B9D76A08D89471BF8B0438CC09A2180EF5DD266346C4B0DA4C36`, driver
`D2869B3342B5D4C15812EC3B5BA918E1ED7FA067D2CE9732DCBA1C4857E24D27`, harness
`61CE02B84231F2723630D0F992DFC240EED108CDEE8EDF769AEF493F233309B5`.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_11` (RED 34/1440) | 0 | 0 | 8 | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 96 | 0 | | |

The kernel sources changed, so both kernel gates were rerun on the same
bytes before the full gate:

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_03` (`build_l2src.ps1 -Run -KeepAll`) | GREEN, 293 targets; 110 selftests executed: 109 ran with exit 0, the expected-fatal close-watchdog selftest exited 3 as required. One target and one selftest more than `fable_kernel_01`: `lmx_walk_named_actual_selftest`. |
| `build/l3_selftest/fable_l3_02` (`run_l3_selftest.py`) | all 11 suites exit 0; four type-budget units 75/128 names, 1070/8192 bytes. |

<a id="written-body-and-prefix-ruling"></a>
## 32. Resolved boundary: the written call body, prefix minus, chains of copies (Codex, FABLE-CODEX-20261004-02)

After section 30 I asked whether the binding record is enough, and whether
the prefix minus of `unit_named_actual_whole` is a language operator. Codex
answered without escalating to the author.

**The nondestructive binding stays REQUIRED before G5.** The binding record
supports the measured written-order evaluation and the retained `NAMED`
operands. It does not meet "preserve original P0 wrappers/order" while the
call's body is rebound to another list: untouched detached cells do not make
the source tree reachable through its original body. Section 30 is kept and
not reverted; its acceptance is separate from this open item. Before the
complete G1/G5 graph checkpoint:

- the original call body keeps its written fields, wrappers and order;
- call readers consume one common checked binding, the projection,
  explicitly: checking, dependency and free-name scanning, native evaluation,
  graph COUNT/PLACE/FILL. The projection is temporary compiler bookkeeping
  over borrowed source nodes, not another persistent graph. Source traversal
  and formal-coordinate traversal are two views and neither silently replaces
  the other;
- a generic walker need not read a naming Frame as a call or a declaration:
  the call's resolved receiving context tells the shared actual traversal
  that the Frame names an actual, and its payload is consumed as the receiver
  specifies;
- SourceSite, original parents and spans and a named actual's comments stay
  with the written nodes; the projection is never the source for diagnostics,
  preservation or an independent oracle;
- the decoder recovers the source from the retained graph and the external
  name and comment service after P0 and the binding records are gone, and may
  not depend on the binding record. `NAMED` may stay if it meets that test.

It is not to be moved past a claimed green graph release because the harness
has no row for literal P0 intactness.

**Prefix minus is a documented operator.**
[Grammar, operators](../docs/LMX_grammar.en.md#operators) lists the prefixes
`@`, `\`, `++`, `--`, `+`, `-`, `!`, `~` and says that writing a prefix
adjacent to its operand is style, not a P0 boundary. `- 1` is valid; the
missing support in `l2_value_spans` and `l2_operand_run` is a translator gap
([PREFIX-MINUS-NOT-AN-OPERAND](defects.md#prefix-minus-not-an-operand)), and
`unit_named_actual_whole` stays as it is. Direction:

- a retained unary operator with ONE source operand; a backend role such as
  NEG may encode it. No `SUB(LIT 0, x)` in the retained graph, no collapse
  into a signed literal when P0 has an operator and an operand, no repair of
  named actuals alone;
- one recognition of prefix operands and spans, precedence, typing and
  emission for ordinary expressions, returns, positional and named actuals
  and bounded forms; repeated prefixes with no depth limit; the operand
  evaluated once, throw and stop propagated before a result; binary minus,
  prefix minus and decrement told apart by expression context, not by spacing
  or by the expected signature;
- machine primitive types keep the C99 promotions of the target
  ([low-level scope](../docs/L2_spec_en.md#lowlevel-scope)); the negated
  result is not forced back to the unpromoted operand type; other numeric
  domains stay scoped debt;
- witnesses: the original `- 1` actual, `-x`, `-(a + b)`, a binary minus
  followed by a prefix-minus operand, an effectful operand evaluated once,
  native and cleared-word graph execution, and a source-shape mutant that
  rejects an invented zero subtraction although the number still matches.

**Chains of copies** are within the bounded actual-call work of
[section 9](#held-call-ruling), with its conditions unchanged. Every link and
the exact call place must justify the actual body's complete input contract.
The actual copy's real lexical links are followed, not a unit prototype
substituted as fallback. The absence of an address alone is no proof against
explicit reference rebinding, path or alias writes or opaque effects. An
addressed or unproved chain stays a located unsupported positive; taking an
address is not a prohibition on calling. The universal, several-caller and
addressed positives stay OPEN, not expected refusals.

<a id="held-call-step-two"></a>
## 33. Held-call boundary, step two: a chain of copies, a method's own Structure

[Section 16](#held-call-step-one) proved one case: a copy of a named
Structure called in the body that owns that Structure. Two more are proved by
declarations now, still one alternative per call and no selection at run
time.

**The cases.** `rb: merge ra` where `ra` is itself a proved whole copy, to
any depth (`unit_copy_call_of_copy`); `x: merge A` where A is the calling
method's own Structure (`unit_copy_call_local_structure`).

**The link.** A merge of one operand without a body whose operand is an own
row records that row (`l2_mres_from`). `l2_own_copy_chain` follows the links
inside one body until it reaches a whole copy of a named Structure
(`l2_own_copy_layout`) or the definition row of a method's own named
Structure (`l2_own_layout`). The admission source of such a merge is
unchanged, it stays without a layout: nothing but the origin of a call reads
the chain.

**Proof that the body is the one executed.** As in section 16, for each link:
the kernel returns the copier's completed occurrence for a one-operand merge
without composition, so each row holds what its operand held when the merge
ran.

**Proof that no row of the chain was replaced.** Measured on these bytes by
probes, for a copied row `ra` between its declaration and `rb: merge ra`, and
for the definition row of a method's own `C` before `xc: merge C`:

| Form | Copied row `ra` | Definition row `C` |
| --- | --- | --- |
| a second `ra: merge B`, `C: merge B` | refused, `more arguments than ra has formals` | refused, the same for C |
| `ra: o`, `C: o` | refused, the same | refused, the same |
| `@: ra o`, `@: C o` | refused, `unknown type` | declares `o`, a reference of type C; C's row is untouched and the copy's call returns C's own result |
| `receiveMessage: ra`, `receiveMessage: C` | a new occurrence; the merge after it is refused, `unknown merge operand` | the same |
| the row passed to a method as an actual | the method receives the Structure, not the row; the copy's call returns A's result | not measured |
| `@ra`, `@C` | the call of the copy is refused, below | the same |

The address is the one way to the reference cell. Every address of a merge
row was already recorded. The address of an own row that is no merge result
is recorded now too (`l2_own_addr_note`), and `l2_copy_calls_verify` refuses
a called copy when any row of its chain is addressed
(`l2_copy_chain_addressed`), with the diagnostic of section 16. That is an
implementation limit on a valid program, not a language refusal, and has no
expected-refusal row.

**Proof of the input contract and of the lexical parent.** Unchanged from
section 16 and for the same reason. Every row of the chain is declared in the
calling body and the accepted origin is owned by that body
(`l2_own_copy_origin`), so the copy's parent is the parent its Structure's
procedure was checked against. Measured: C's body reads `node\base`, the
calling method's own field, and the copy's call returns the method's value.

**What is not done, and why `unit_copy_call_other_owner` stays open.** I
tried to accept a copy of a unit-level Structure declared and called in a
method. The first witness failed. The copied body's `node\seen` is compiled
as slot 0 of the unit, and over a copy whose parent is the method's
occurrence it read and wrote slot 0 of that occurrence. The natively emitted
procedure of a unit-level Structure reaches the unit itself through the same
`node` (`l2_unit_ref`), so its calls of unit methods and its uses of unit
Structures depend on the parent too. A copy in another body needs the actual
parent's own resolution of those names, which is the universal route. The
relaxation was removed before any gate; the row is red by design and its
header states this reason. Also open: a method calling an outer copy by a
free name (`unit_copy_call_from_method`, where several callers may bind the
name), an addressed row (`unit_copy_call_addressed`), selection among
alternatives, a body reached through a callable formal or a path, and the
fixed-arity held call (`unit_held_nullary_source_field`).

**Verification.**

- Recovered: `unit_copy_call_of_copy` and `unit_copy_call_local_structure`,
  each with a new walked twin.
- New `unit_copy_call_chain_inputs` and its walked twin: three links (`rc` of
  `rb` of `ra` of A) and a method's own C. A reads the free `x` and writes the
  unit's `seen` through `node`; C reads the free `x` and its method's `base`
  through `node`. Each call hands the copy its caller's current `x`, the
  method's local 4 and the root's changed 5, and runs the called copy alone.
  Path oracle: each merge of the chain takes the very output operand of the
  previous declaration, the three rows are distinct objects, each `EXEC`
  targets the called row's own operand and carries the caller's cell of `x`.
  Two shape mutants: the source operand of `rc`'s declaration emptied, the
  target of the method's `EXEC` emptied.
- Under `--walk-methods` the procedure of a method's own Structure keeps its
  native word. The walked twins state it (`NativeMethods`): the method's
  `EXEC` runs in the interpreter and C's body natively. A's procedure and the
  root are walked.
- Translator mutants through quick builds, the live file restored and its
  hash re-verified after each; the control build translates the three
  witnesses and refuses both addressed probes. No link recorded: the three
  witnesses are refused. Only the called row's own address looked at: both
  addressed probes translate. The address of a definition row not recorded:
  that probe alone translates.
- Focused `fable_chain_01` (148 targets: copy-call, named-Structure
  execution, capture, merge-result and address rows): red only the six open
  positives of those groups and two walked twins whose assertion I had
  written wrong (the native word above). Focused `fable_chain_02` (21
  targets, every copy-call row): red only the three open positives.

<a id="full-13"></a>
## 34. Full gate after section 33

`fable_full_13` completes **RED 32/1454** on translator SHA256
`6CBFA5BA473888BF950752E7EB0ACB1C5975B3DA280F20C8E46897DC107B843D`
(staged Git blob `544b103a892f4da02e1640ab38540cc1a115e530`), harness
`26622232DCD5C3414E2448C293A784DD1FB6B07D5185DDD9FF13BCE02DA2FA29`,
walker and driver unchanged.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_12` (RED 34/1448) | 2 | 0 | 6 | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 96 | 0 | | |

The kernel and L3 gates were not rerun: no kernel source changed.

<a id="prefix-sign"></a>
## 35. Prefix signs: one retained operator with one operand

The defect ([PREFIX-MINUS-NOT-AN-OPERAND](defects.md#prefix-minus-not-an-operand))
and its direction are in [section 32](#written-body-and-prefix-ruling). Before
this slice a sign was no operand anywhere but in native text. Measured by
probes on the committed translator: the declarations `int: c -b`,
`int: g 2 * -b` and `int: f - 1` were refused as an unsupported body,
`int: d -(b + 1)` as an unknown method, and the store `h: -b`, which the
check pass let through, was refused by the graph producer.

**Mechanism.** One recognition, read by every pass.

- *Where a sign is a prefix.* `l2_prefix_sign` knows `-` and `+`.
  `l2_operand_run` takes a sign and the operand after it as one operand, to
  any depth. It is asked only where an operand begins (`l2_expr_span`, the
  even places of `l2_value_spans`), so a `-` between two operands stays the
  binary operator whatever the spacing: `a - -b` is a minus and a sign.
  `l2_prefix_rest` gives the operand of such a span. A sign written against a
  group, `-(a + b)`, is a Frame headed by the sign in P0; `l2_prefix_frame`
  reads it as the same prefix over the group.
- *Typing.* The result has the operand's type promoted as C promotes it
  (`l2_rw_unify` of the type with itself): a char gives an int, every other
  type stays, a literal alone stays a literal and takes its place's type. The
  same rule in native typing (`l2_native_span_ty`, `l2_native_leaf_ty`,
  `l2_colon_simple_ty` for a group taken as a whole value) and in graph typing
  (`l2_rw_span_ty`, `l2_rw_opty`).
- *The kind rule.* A reference or a text under a sign is refused where it
  stands, with the messages of every other operation (`l2_prefix_native_ty`;
  `l2_check_value_kinds` now reaches an operation of two fields;
  `l2_prefix_kind_refused` for the group form, in the check of an operand and
  of an assigned value).
- *Native code.* The field form already went out as text. The group form is
  the group's value, prepared as any group is, under the sign (`l2_prep`). C
  promotes and negates.
- *Graph.* `NEG [operand]` and `POS [operand]` (`LMX_WALK_OP_NEG` 48,
  `LMX_WALK_OP_POS` 49), width 2, at the operand's place
  (`l2_rw_prefix`, `l2_rw_prefix_group`). Nothing else stands for a sign: no
  subtraction from a zero the source does not have, no signed literal made of
  an operator and its operand. `- 1` is `NEG [LIT 1]`.
- *Interpreter.* The operand is evaluated once; the C99 integer promotion
  comes first, as for the binary operations; `NEG` negates in the promoted
  width (an unsigned type wraps, the least int is its own negation), `POS`
  leaves the value. A reference operand, no operand and a width other than 2
  are `LMX_WALK_INVALID`.
- The driver's shape grammar reads the words `NEG` and `POS`.

**What is not done.**

- The prefixes `!`, `~`, `++` and `--` are not built, as before.
- A sign written against a call head, `-mark(3)`, is one Frame headed
  `-mark` in P0: the parser does not split an operator from a call head. The
  same holds for `2+mark(3)`. It is a parser gap, older than this slice
  ([P0-OPERATOR-BEFORE-CALL-HEAD](defects.md#p0-operator-before-call-head));
  the witness writes `- mark(3)`.
- An operand whose type the native typer does not know (a raw pointer) is
  left to the C compiler, as in every binary operation.
- The sign of a char stored into a char needs the conversion's receiver, like
  any int stored into a char; the retained graph has no conversion of its own.

**Verification.**

- Recovered: `unit_named_actual_whole` (`f(a: 8; b: - 1)`), now with path
  facts on the named actual and a new walked twin.
- New `unit_prefix_sign` and its walked twin (root and ten methods walked):
  `-x`, `-(a + b)`, `- -x`, `a - -b`, `- mark(3)` with the trace 3, `+x`, a
  sign in a condition, in a declaration, under `*` in a store, over a literal
  in an actual, over a group as a whole stored value, and `-n + 2U` over a
  size_t that wraps. Path facts hold every sign as `NEG` or `POS` of width 2
  over its operand, and the literal under the sign of the actual as 1. One
  shape mutant empties a sign's operand.
- New refusals: `unit_prefix_sign_ref_refused` and
  `unit_prefix_sign_group_ref_refused` (a Structure under a sign, located at
  the operand), `unit_prefix_sign_text_refused`,
  `unit_prefix_sign_char_promoted_refused` (the sign of a char is an int:
  storing it into a char asks for the conversion's receiver).
- New kernel selftest `lmx_walk_prefix_sign_selftest` (29 checks): int,
  size_t, unsigned and ulong operands, the promotion of a char and of an
  unsigned char for `NEG` and for `POS`, a sign over a sign, the least int,
  and the refusals of a reference operand, of no operand and of a width other
  than 2.
- Kernel mutants on a copy of the live kernel sources, built with a kernel
  gate's flags: a char keeps its type (2 checks fail), `NEG` leaves the value
  (6), a sign of any width is run (1), `POS` negates (2).
- Translator mutants through a focused harness run, the live file restored
  and its hash re-verified after each. `-x` retained as a subtraction from an
  invented zero (`fable_prefix_mut_zerosub`): the native rows still run to
  their exit 7 and fail 23 and 3 shape facts with no other failure; the walked
  twin stops on the invalid subtraction of an int zero from a size_t. A sign
  that begins no operand (`fable_prefix_mut_norun`): the positive rows are
  refused and the field-form refusals fail with another message. No kind rule
  under a sign (`fable_prefix_mut_nokind`): the reference and the text row of
  the field form are red. The group row stayed green under it: its group was
  `b + 1`, and the binary rule inside the group refused the reference before
  the sign was asked. The witness now holds the reference alone, `-(b)`, and a
  probe under the same mutant shows the other message (`assignment value has
  unknown type`). The result keeps the operand's type
  (`fable_prefix_mut_nopromote`): the char row alone is red.
- Focused `fable_prefix_01` (74 targets: the prefix rows, every named-actual,
  value-kind, conversion and literal row): red only the known
  `unit_t7_convert`.

<a id="full-14"></a>
## 36. Full, kernel and L3 gates after section 35

`fable_full_14` completes **RED 31/1462** on translator SHA256
`5FFE807D07F4206656D2BB77EF15EE4A2674ABEA3CCBFAEA3FEB60E62AA73367`
(staged Git blob `964c3012bb38dfe5c0967c2a440e98bb66c39137`), walker
`2CB95DC8582FA05BE37B4C99EC5962E69AA0BB2F482087C12E2B88C30A9C411E`, walker header
`D101FEAEE6D4701A711B94CCAB7B89748B361ED81BBFD9B9A0DF7E0085DA8E1D`, driver
`C34DCAB3FEA5C06CA732BFFE842C742D2EACF62EC944C61A59F18D005BC26BDB`, harness
`894F1D77F661B1759A23AA460D50E198606A529F95A9F21C4B0D7968BEB1B723`.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_13` (RED 32/1454) | 1 | 0 | 8 | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 97 | 0 | | |

The kernel sources changed, so both kernel gates were rerun on the same
bytes before the full gate:

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_04` (`build_l2src.ps1 -Run -KeepAll`) | GREEN, 294 targets; 111 selftests executed, all but the expected-fatal close-watchdog selftest with exit 0, that one with exit 3 as required. One target and one selftest more than `fable_kernel_03`: `lmx_walk_prefix_sign_selftest`. |
| `build/l3_selftest/fable_l3_03` (`run_l3_selftest.py`) | all 11 suites exit 0; four type-budget units 75/128 names, 1070/8192 bytes. |

<a id="held-call-arity"></a>
## 37. The held call takes the arguments of its header

`unit_held_nullary_source_field` is a required positive of
[to_fable](../to_fable.md): `w: wrap 5` holds a callable whose header is
`fn: () int`, and `w()` calls it. It was refused as `root operation not
walkable yet: this call's inputs`. Measured on the committed translator: the
same words for a nullary held call in a method, and for a one-argument held
call whose argument is more than one field, `add5(x + 1)`. The native call
site carried the same limit in other words (`...is not one number to a
number`), which no program reached, the graph producer refusing first.

**Where "exactly one number" was written.** In four places of the held-call
route, none of them a rule of the language:

- the header reader `l2_mad_held_sig` took the Structure of formals only when
  it had one field;
- the native call site `l2_prep_held_call` evaluated one argument and built
  the references `[node, argument, hidden...]`;
- the graph producer `l2_rw_mad_call` took a body of exactly one field and
  built `PRIM_PUB` with one argument place;
- the generated adapter `l2_mad_call` refused fewer than two references. Its
  copy of the inputs was already positional.

**Mechanism.** No zero-input adapter and no shim: the same route, counted by
the header.

- `l2_mad_held_arity`, `l2_mad_held_arg_ty` and `l2_mad_held_ret_ty` read the
  header the host declared, `fn: (formals) T`, at any count of formals, each
  formal and the result a number.
- Native code evaluates the declared arguments once each in the order they
  are written (`l2_expr_span` gives each argument its fields), each into a
  cell of its formal's type: `[node, declared..., hidden...]`.
- The graph keeps `PRIM_PUB` of width 4 + declared + hidden: the held
  callable's own row, the declared arguments in their written places, each
  built as an expression of its formal's type, then the model's hidden
  inputs. The primitive contract has one witness per declared argument.
- The adapter takes every reference after the node as an input, in order.
- The check pass compares the count of actuals with the header and refuses
  another count where the call stands (`a held callable takes the arguments
  of its header`).

**What is not done.** The header is still numbers to a number (item 739). A
callable formal, a Structure or a reference in a held callable's header keeps
its refusal. A held callable named bare, without parentheses, is not a call
of this route. The universal actual-call boundary of
[section 9](#held-call-ruling) is not this slice.

**Verification.**

- Recovered: `unit_held_nullary_source_field`, with a new walked twin (the
  two unit methods walked; the host keeps its native word).
- New `unit_held_call_arity` and its walked twin: held callables of no
  formal, of two ints and of a size_t, an int and a size_t, called at the
  root and in a method, as values and under `+`. `mark` shows each argument
  evaluated once in written order (trace 1234), the middle argument of the
  three is an expression of three operands. Path facts on the root's three
  calls: width, the held row as the target, each argument in its place with
  its literal or its role, the empty hidden place. Two shape mutants: the two
  arguments of a call exchanged, an argument emptied.
- New `unit_held_call_count_refused`: one actual for a header of two.
- Changed with the mechanism: `unit_t6_root_held_arity_refused` pinned the
  words of the old limit (`...is not one number to a number`) for a program
  that passes one actual to a header of two. The program is still refused;
  the row now requires the located count refusal.
- Translator mutants through a focused harness run, the live file restored
  and its hash re-verified after each. The graph takes one argument only
  (`fable_held_mut2_oneonly`): the nullary and the arity rows are refused.
  The graph puts the arguments in reverse (`fable_held_mut2_graphswap`): the
  arity rows red, natively by their path facts and the walked root. Native
  code puts them in reverse (`fable_held_mut2_nativeswap`): the native arity
  row red, the walked half of its twin still exit 0. No count check
  (`fable_held_mut2_nocount`): both count refusals fail with another
  message. The adapter asks at least one declared argument
  (`fable_held_mut2_adapterone`): the nullary rows stop on its invariant; the
  arity rows stay green, which is the measure that the adapter's copy was
  positional before.
- Focused `fable_held_10` (125 targets: every held, make-adder, callable and
  capture row): red the seven known open rows of those groups and
  `unit_t6_root_held_arity_refused`, whose pinned words changed as above.

<a id="full-15"></a>
## 38. Full gate after section 37

`fable_full_15` completes **RED 30/1468** on translator SHA256
`ECCAF2B02E277A7E91C5B6B76634A5EE2DD64FECAEF5CEE73E61322DE64FB823`
(staged Git blob `2d595f6d4eac41d7d0482392f2cd142c712cf823`), harness
`428A4E8FA507D56E6E00C4A7E40FEC1C3E54154D22DA7EF51AF99C0E0E049EA1`,
walker and driver unchanged.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_14` (RED 31/1462) | 1 | 0 | 6 | 0 |
| `fable_full_01` (RED 126/1395, baseline) | 98 | 0 | | |

The kernel and L3 gates were not rerun: no kernel source changed.

<a id="receiving-use-coverage"></a>
## 39. The receiving-use contract: the coverage of a method's own typed reference

[Section 3](#receiving-use-contract) fixed the rule and
[section 29](#receiving-use-mechanism) the boundary of its mechanism. This
slice builds the mechanism in the kernel and the walker, and its first,
bounded producer in the translator.

**What was.** A typed reference received every candidate by the whole shape
of its model: native code and the walked instruction asked
`lmx_implements_receiver_view(…, candidate, Model, Model, …)`.
`unit_bind_method_thin_other`, a required positive, threw `implements`, and
two rows whose reference is never read were green as refusals.

**Kernel: the coverage of one receiving instruction.** `LmxImplUses`
(`lmx_implements.h.lm1`) holds what the Consumer of the place being received
into reads through that place. It is the argument of one call: non-owning,
read while the instruction runs, never kept with the pair. No Structure is
made for it. Its cells are levels packed flat: cell 0 is the count of cells,
the root level starts at cell 1, and a level is a count of pairs followed by
`(edge, below)` per field the Consumer reads.

- An edge is a field of the model at that level in the model's own index
  space, with its half: `j` below the width is field `j` through the ORDINAL
  half (an explicit `[N]name` use), `width + j` its LAST half (a bare `name`
  use). This is the edge numbering of `lmx_implements_slot` (K01).
- `below` is 0 for a field consumed and not entered (a number, a reference
  that is held), `SIZE_MAX` for a field consumed whole (the full interface
  from there), otherwise the cell where the nested level starts, in the
  nested model's index space.
- A root level of no pair is a Consumer that reads no field: the identity of
  the reference is all it consumes.

`lmx_implements_receiving_use(arena, value, model, model, pending, uses)` is
the shared walk with that argument. The model stays the index space.

- A field the coverage does not name is not looked at: not required when it
  is missing, not compared when it is there with another type.
- A field it names is required whatever the walk's `skip_unused` says, and
  each edge reads its own half of the correspondence.
- A nested level is walked in the nested model's index space through the
  nested pair's own correspondence.
- Null coverage is unknown coverage: the full reception, as before.
- A coverage that cannot be read, a level longer than its cells, an edge past
  both halves of the model, or an edge that lands on an empty place of the
  model answers UNKNOWN, which no reception takes for YES.
- The answer changes nothing in the table. The record of the pair, pending or
  kept, gives physical places and no permission: a later instruction brings
  its own coverage.

**Walker.** `ADMIT_AS` child 8 is the reception mode: 0 as before, 1 the full
reception, 2 a reception by the instruction's own coverage. With mode 2 the
coverage stands in the instruction's cells from child 9, self-delimited by
its first cell; the maps and the catch rows follow it. The coverage is used
where the candidate's layout selected a map and where the candidate already
has a record; a record alone never answers.

**Translator: the analysis.** `l2_ruse_of(own)` gives the coverage of an own
typed reference of a method: known with its entries, or unknown. It reads the
method's body as written and classifies every spelling of the name where it
stands. A spelling it cannot classify makes the coverage unknown, which is
the full reception and never an empty one. The classes:

- the place being received into: the name atom of its declaration, a store
  into it written with its colon;
- an operand of an identity comparison (`=`, `!=`), which consumes the
  reference and none of its fields;
- the root of a path below the place, in value position or as the head of a
  frame. The path is resolved on the model level by level: a number or a
  reference cell is consumed as it stands; a nested Structure the path goes
  on through gets a level of its own; a Structure or a callable the path
  ends at is consumed whole. The selector is kept: a bare name and `[N]name`
  are different edges of one required field;
- the whole candidate of another typed reference of the method, whose own
  receiving instruction admits the value by that reference's coverage.

The analysis runs once per row and is the same fact for the flow of types,
for native emission and for both passes of the graph producer. The cells are
computed where the layout is known: an edge is the field's placed slot, plus
the model's width for a bare name's half.

- Native code declares the cells and the view at the instruction and calls
  `lmx_implements_receiving_use` in the two branches named above.
- The graph producer writes mode 2 and the same cells into `ADMIT_AS`.
- `l2_d105_receiving_flow` does not prune the sources of a place of known
  coverage. Such a place is then marked, and its fields are read at the slot
  the candidate's record gives. What the place refuses is decided where it
  is reached.

**Bounds of this slice.** These are limits of the implementation, not rules
of the language.

- Coverage is known only for an own typed reference of a plain method, with a
  named Structure as its model, in a program. A reference of the root or of
  a named Structure's procedure is a field reached by path and by bare name
  from other bodies; a library unit does not see its users.
- A pass as an actual, a return, a copy, an address of the place and any
  application of it without its colon are unknown: their downstream
  receiving contract is not composed.
- A spelling of the name as a segment below another root anywhere in the
  program is unknown (`while\b`, `m\b`, `node\b`). So is a spelling inside a
  definition within the method, a nested callable or a named Structure.
- Same-named declarations of one method are not told apart: the uses of all
  are the coverage of each, which only asks for more.
- A formal that is rebound, a field store, an element store and a return
  have no place of this kind and keep the full reception.
- A candidate whose layout is unknown and that has no record is still
  received by the full positional check.
- A Structure or a callable at the end of a path is consumed whole: held and
  invoked are not told apart yet. The cells and the walk already express the
  difference (`below` 0).
- A nested level is produced and run for a nested Structure of the model's
  own definition. A candidate whose nested Structure is another definition
  is refused at translation as before: the nested correspondence maps are a
  separate open item.
- The explicit rebinding `@: r o` is not built (measured: `unknown type`).
  The store is written `r: o`.
- The bound rests on a measured fact: the occurrence of a plain method is not
  a value in this translator (`merge m` is an unknown merge operand, `y: m`
  an unresolved name). When it becomes one, a spelling of the method's name
  as a value is a use of every reference the method owns.

**A defect found on the way, fixed.** A path rooted at another method's name
that goes through that method's admitted reference (`keep\held\value`)
produced C that did not compile: `l2_dslot` was declared only in a method
with an admitted place of its own. It is declared in every method of a
program that has such a place
([PATH-FROM-METHOD-SLOT-TEMP](defects.md#path-from-method-slot-temp)).

**Verification: kernel.** `lmx_implements_use_selftest` (47 checks) and
`lmx_walk_admit_use_selftest` (20 checks). Mutants, each selftest rebuilt
against the mutated kernel source:

| Mutant | Checks that fail |
| --- | --- |
| a named field passed over when not carried | 6 |
| every edge reads the ORDINAL half | 3 |
| a nested level ignored | 2 |
| a held reference entered | 1 |
| cell 0 does not bound the reads | 4 |
| a named field of another type admitted | 2 |
| an edge on an empty place of the model passed over | 1 |
| walker: the coverage not handed to the reception | 5 |
| walker: a recorded candidate received in full | 1 |
| walker: a recorded candidate received by its record | 2 |

**Verification: programs.** Each program is a native row and a row with its
methods walked.

| Witness of [section 29](#receiving-use-mechanism) | Row |
| --- | --- |
| Root identity, the exact candidate | `unit_recv_use_identity` (declaration and store), `unit_bind_method_thin_other` |
| A missing unused field | `unit_recv_use_unused_field`, method `missing` |
| A present unused field of another type | `unit_recv_use_unused_field`, method `another` |
| A missing used field: thrown where reached, the candidate evaluated once, the destination kept | `unit_recv_use_used_field_refused` (a read, and a store through the place) |
| Thin, then a Consumer that needs the omitted field | `unit_recv_use_later_consumer`, method `needs` |
| Thin, then consumed more fully, one correspondence | `unit_recv_use_later_consumer`, method `fuller` |
| A nested partial path, bare and `[N]` selectors | `unit_recv_use_nested_path` (a nested level, with path facts on every cell), `unit_recv_use_selectors` (`[1]` refused where the bare name is received) |
| Unknown coverage never empty | `unit_recv_use_unknown_refused`, `unit_recv_use_nested_reader_refused`, `unit_recv_use_path_from_method_refused` |

- Native rows require `lmx_implements_receiving_use(` in the generated text;
  the four unknown-coverage programs forbid it.
- Path facts hold the instruction's mode and cells for the empty coverage,
  for the nested coverage and for the full reception. Three shape mutants:
  the mode emptied, an edge emptied, the start of the nested level emptied.
- `unit_recv_use_path_from_method` is the positive of the fixed defect: the
  other method reads both fields through the reference's correspondence.
- Migrated: `unit_ref_rebind_other_refused` is now
  `unit_ref_rebind_other_thin`, and `unit_struct_return_ref_admit_refused` is
  `unit_struct_return_ref_admit_thin`. The programs are the same with a real
  observation added: the reference is the candidate, and a reference to
  `Other` received from it reads what the callee wrote into its result.
  `unit_ref_formal_rebind_other_refused` and
  `unit_formal_spelling_rebind_other_refused` read `v\value` and stay
  refusals.
- Four more rows of the same class, found by the first full gate
  ([section 40](#full-16)): `unit_local_init_graph_ref_admit_refused`,
  `unit_rhs_returned_model_refused`, `unit_rhs_void_admission_assign_refused`
  and `unit_rhs_void_admission_init_refused` refused a candidate through a
  reference that was never read. Their subject is the route of the
  right-hand side, so they stay refusals: each method now reads the field
  its candidate lacks, and the refusal is by that field.
- `unit_ref_local_path` spells the native text of a local reference's
  reception; its pattern names `lmx_implements_receiving_use` with the
  coverage view now.

Translator mutants through a focused harness run of 26 rows, the live file
restored and its hash re-verified after each (`fable_use_mut_<name>`):

| Mutant | Red rows |
| --- | --- |
| `emptyunknown`: unknown recorded as known empty | `unit_recv_use_unknown_refused` (not translated), `unit_recv_use_nested_reader_refused` (by the forbidden text) |
| `wholeignored`: a whole-value use passed over | `unit_recv_use_unknown_refused` (not translated) |
| `nopath`: a path in value position not recorded | `used_field_refused`, `later_consumer`, `selectors`, `nested_path` |
| `nohead`: a path that heads a frame not recorded | `used_field_refused` |
| `noselector`: every edge a bare name's | `selectors`, `nested_path` |
| `nonested`: a nested Structure consumed whole | `nested_path` |
| `flowfull`: sources pruned by the whole model | `unused_field`, `later_consumer`, `selectors` |
| `norecv`: the place as a candidate not classified | `later_consumer`, `unit_struct_return_ref_admit_thin` |
| `noidentity`: an identity comparison not classified | every row that compares its reference by identity |
| `nodefs`: a definition inside the method read as body | `nested_reader_refused` (by the forbidden text only: the read is found either way) |
| `nosegscan`: paths below another root not looked for | `path_from_method`, `path_from_method_refused` |
| `nativefull`: native code never carries a coverage | the nine native thin rows |
| `graphfull`: the graph never carries a coverage | the walked thin rows, and the native rows with path facts |
| `nativestore`: the native store site names no place | `identity`, `unit_ref_rebind_other_thin`, `unit_struct_return_ref_admit_thin` |
| `nativedecl`: the native declaration site names no place | `unit_bind_method_thin_other`, `identity`, `unused_field`, `later_consumer`, `selectors`, `nested_path` |
| `nodslot`: the slot temporary only where the method has a place | `path_from_method` (gcc fails) |

Focused `fable_use_03` (35 rows: every row above with the neighbouring
reference rows): all green.

<a id="full-16"></a>
## 40. Full, kernel and L3 gates after section 39

The first full gate, `fable_full_16`, completed RED 34/1494 with five rows
from OK to FAIL and none of them a regression of behaviour: the four
never-read refusals named in section 39 received their candidates, and
`unit_ref_local_path` no longer found its native text. The rows were
corrected as that section says and the gate was run again on the same kernel
and translator bytes.

`fable_full_17` completes **RED 29/1494** on translator SHA256
`E58A8F18BDD8F2DD6DAA16DBA664B6CD144B07196AA14FE4B411C346162071A5`
(staged Git blob `af2bbd93bd5505c3d14df1b051948cde4a3f0459`), harness
`B32C33BA08F6026F48A1177E9B6682D438292F2B038ABF307DD25296FDCEF32D`,
walker `15327217577E09F2B5F0D00C08A4F6520C818E04103DF32A74A87D6A92917460`,
admission kernel `DED5518EFB6A1BCBDE05E033E73548729D4FB63A10389A9ADB6C0994AA6184BF`.

| Against | FAIL→OK | OK→FAIL | Added | Removed |
| --- | --- | --- | --- | --- |
| `fable_full_15` (RED 30/1468) | 1 | 0 | 28 | 2 |
| `fable_full_01` (RED 126/1395, baseline) | 97 | 0 | | |

The two removed rows are the two migrated ones, present under their new names
among the added. Against the baseline they were recoveries in
[section 38](#full-15) and are added rows here, so the count there is one
less with one more recovery (`unit_bind_method_thin_other`).

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_05` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_05` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |

The first L3 run, `fable_l3_04`, had every suite at exit 0 and failed its
type budget: the new header type `LmxImplUses` took the Thread units' closure
from 75 to 76 names against a pinned count. `tools/l3_type_budget.py` records
the new count with its reason, as that tool requires; the capacities stay
128 names and 8192 bytes. The kernel gate ran before that change on the same
kernel bytes.

<a id="written-body-mechanism"></a>
## 41. Resolved boundary: how the written call body is kept (Codex, FABLE-CODEX-20261004-03)

[Section 32](#written-body-and-prefix-ruling) requires the call's P0 body to
keep its written fields, wrappers and order. I asked which mechanism may do
it and gave the measure of the readers: the only destructive write is in
`l2_bind_call_in`, and `l2trans.lm1` has 538 reads of `frame\body`, 323 of
`\body\first_field` and 903 calls of the field iterator `l2_next_active`.
Codex answered without escalating to the author. Nothing of it is
implemented yet; this section is the boundary the implementation must keep.

**Refused: a redirect inside the iterator.** I proposed to leave the written
list in the body and to make `l2_next_active` yield the projection when it is
handed the first written cell of a bound body, with a second iterator for the
source. That is not explicit: the switch of list happens by the address of a
field, the caller supplies no receiver and no context, and direct reads of
first, last and count, suffix scans and diagnostics could then describe
different lists. No lookup by field address and no ambient current view in
the iterator.

**Direction.** The view is chosen once, where a Frame's body is entered, from
its resolved role and its call or binding context:

- a source traversal takes the written body;
- an analysis by formal coordinate takes the checked projection where it
  needs it;
- a traversal of the payload of a named actual knows it stands inside an
  actual's wrapper, not at a declaration of the caller's scope.

A shared accessor may give the bounds of the chosen list, borrowing the
compiler's binding record. After that the iterator only advances and filters.
The work is to centralise the choice at the real shared entry points and to
inventory the direct reads of a body that bypass them: the count of iterator
calls is not the count of changes. Two iterator names are fine while each
stays honest. No list-kind tag in the language graph, no runtime registry, no
permanent helper graph, no assertion per field; a check at the choice may
validate the migration.

**Order stays as written.** The check by formal coordinate may use the
projection. Evaluation of the actuals and the retained graph keep the written
order, with resolved coordinates for transport, and COUNT, PLACE and FILL
agree on that one plan with its `NAMED` wrappers. The fix of
[section 30](#named-actual-order) is not to be undone by an accessor.

**Staging is allowed.** First the formal checks, native preparation and the
graph passes; then the generic scanners, the shared recursion and the
remaining direct readers. The body's storage need not change at the first
checkpoint. While the rewrite stays it is to be named OPEN and destructive,
with the whole written list, its wrappers and spans kept before the
replacement as borrowed compiler references and not as a second source
graph. No intermediate stage claims G1 or the ticket closed.

**End state.** When every dependent reader chooses its view, the rewrite is
removed: the P0 first, last, count, links, wrappers and containment stay as
written, and the compiler's binding data is disposed before the independent
decoder runs. No hidden fallback.

**Verification asked.** Side effects in named order, whole-Structure actuals,
empty payloads, nesting, mixed positional and named actuals, source
diagnostics, and unchanged neighbouring rows. Semantic checks stay in the
ordinary resolved algorithm; assertions do not make up for a confused view.

**On [section 39](#receiving-use-coverage).** Codex takes it as a progress
report. The distinction stands: unknown coverage is not empty and is not a
proven incompatibility of the candidate. Where the full reception refuses a
candidate that fits its actual Consumer, that is an OPEN limit of the
coverage, not a new normative `implements` refusal, and the absence of rows
that expect it does not show the limit absent.

<a id="receiving-use-follow-up"></a>
## 42. Follow-up to section 39 (Codex, FABLE-CODEX-20261004-04)

Codex inspected `c67cc0b7` and asked for a bounded follow-up of tests and
evidence. The implementation is unchanged.

**The four strengthened refusals keep their thin programs.** In
[section 39](#receiving-use-coverage) four rows that refused a candidate
through a never-read reference were made to read the field the candidate
lacks. That makes each a legitimate refusal, but it is another program: a
new negative subject, not the old refusal recovered. The original
expectations were wrong, and the original programs are valid. Each now has
its thin counterpart, with the same production of the candidate, the same
receiving route, no field read through the reference, and the reference
observed to be the candidate:

| Refusal by a used field | Thin positive |
| --- | --- |
| `unit_local_init_graph_ref_admit_refused` | `unit_local_init_graph_ref_admit_thin` |
| `unit_rhs_returned_model_refused` | `unit_rhs_returned_model_thin` |
| `unit_rhs_void_admission_assign_refused` | `unit_rhs_void_admission_assign_thin` |
| `unit_rhs_void_admission_init_refused` | `unit_rhs_void_admission_init_thin` |

Each thin positive is a native row and a row with its methods walked. In the
two opaque-pointer programs the walked row walks `check`; `raw`, whose result
is a machine cast, keeps its native word, and the row says so. The table of
[section 40](#full-16) with no OK→FAIL compares the revised fixtures; it is
not evidence that the semantics of those rows were unchanged.

**The needles of the limit left the semantic rows.** The rows of
`unit_recv_use_unknown_refused`, `unit_recv_use_nested_reader_refused`,
`unit_recv_use_path_from_method` and `unit_recv_use_path_from_method_refused`
forbade the coverage call in the generated text, and one held reception
mode 1 by a path fact. Those needles hold today's conservative mode, not the
contract: a correct composition may give such a reference a coverage and
still refuse the same incompatible candidate. The rows now hold behaviour
only. The text needle moved to four rows named `..._limit_probe`, of the kind
`translates-with-debt`, labelled temporary implementation-coverage probes;
the mode-1 path fact is dropped. Of the mutants of section 39, `nodefs` is
killed by a probe alone, and `emptyunknown` and `nosegscan` by behaviour as
well.

**OPEN positives of the limit.** Two valid programs this implementation
refuses, added as required positives that stay red:

- `unit_recv_use_nested_dormant`: a definition inside the method reads the
  field the candidate lacks, and stays dormant, because the method returns
  another definition. Nothing that runs needs the field. The presence of a
  definition is not its execution, and the reception does not predict it.
  The counterpart where the reading definition is returned and invoked is
  `unit_recv_use_nested_reader_refused`.
- `unit_recv_use_passed_thin`: the reference is passed whole to a callee
  whose formal reads no field.

Both are measured against a control with a `Model` candidate, which runs to
exit 7 natively and with methods walked.

**The type budget.** The update for `LmxImplUses` stands. The capacities of
128 names and 8192 bytes are defects of the pinned L1 translator, not limits
of L2 or L3; K09 already covers fixed header capacities, and the probe stays
until they are really removed.

**Measured for [section 41](#written-body-mechanism).** With the destructive
rewrite of a bound call body turned off and nothing else changed, the full
harness (`fable_exp_written_01`) has 26 rows from OK to FAIL against
`fable_full_17` and no other change: every row whose program binds a named
actual to a method, 25 of them not translated and
`unit_named_actual_formal_name` failing at run time. That is
the cohort the migration must carry. It is a diagnostic, not an acceptance
oracle and not proof that every reader is migrated: a green exit does not
show the source body intact or cover syntax no row reaches. The run changed
the live translator and restored it, hash verified; Codex asks that such
experiments run on isolated bytes, and the next ones will.

**Evidence.** Focused `fable_use_06`, the whole cohort of sections 39 and 42
(52 rows): red only the two OPEN positives. No full gate was run for this
follow-up, as Codex said; the cohort is part of the next ordinary gate, where
the expected count is 1508 targets with the 29 red rows of `fable_full_17`
and these two.

<a id="written-body-kept"></a>
## 43. The written call body is kept: the end state of section 41

The destructive rewrite is removed. `l2_bind_call_in` no longer writes the
body of a call: its first and last field, its count, the links between its
fields and the Frames that name its actuals stay as P0 parsed them. The
projection, the actuals as one list in the order of the callee's formals with
a named actual's payload in its formal's place, is kept in the binding record
(`l2_bnd_first`, `l2_bnd_count`) beside the written rank and the naming Frame
of each formal that [section 30](#named-actual-order) added.

**The choice of view.** One accessor gives the actuals of a call:
`l2_call_actuals(body)`, with `l2_call_actual_fields(body)` for their count.
For a bound body it is the projection; for any other body it is the body's
own fields. A reader calls it where it enters a body. The iterators only
advance and filter; no field address is looked up and there is no ambient
view.

| Reader | View it takes |
| --- | --- |
| The binding's own recursion, `l2_bind_struct` | The written body. A naming Frame is passed through to its payload (`l2_bound_is_wrap`); it is not walked as a statement of the caller's scope. |
| The call check, the native call and the graph call: `l2_check_call`, `l2_emit_call`, the three callers of `l2_rw_call` | The actuals. Evaluation and the retained operands keep the written order through the record's ranks, as in section 30. |
| The free-name scan: a method's call, a callable formal's call, a call written as a statement (`l2_scan_node`, `l2_scan_body`) | The actuals. |
| The walkers that pass any Frame and give it a meaning: the merge scan, the throw-channel scan, the receiving-use scans, the method's locals, receives, the room for own rows, the mentions and returns of a callable merge, the capture scan, the uses of `implements`, the node of a free name for its diagnostic | The actuals. |
| The declaration reader `l2_declaration`, asked first by every statement classifier | Neither: a Frame the binding resolved as a call declares nothing. |
| Containment by node address (`l2_node_in`), a test that a body has no field, the retained source nodes (`l2_rw_source_node`) | The written body. |

The last row is not migrated on purpose. Containment is about the source
tree; it serves the file of a diagnostic. The compiler's own nodes of a
projection, a named body kept whole and the empty Structure, are not in that
tree: a diagnostic at one is said in the file its pass hands it, and a probe
with such a call inside a program part names the part's file. A union of the
two views in containment had no witness and was not added. A bound call has a
written actual for every formal, so "no field" is false in both views. A
retained source node is a source traversal, and no bound call stands inside
one: a machine operand goes through the ordinary expression walker and its
calls through `l2_rw_call`.

**What a raw reader did.** Each of these was measured before its reader was
moved, by a program in which a formal of the callee has the name of something
in the caller:

- The free-name scan read the head of a naming Frame as a name of the
  caller's scope. With nothing of that name: `unresolved name`. With a unit
  field of that name the method takes it as a hidden input in silence: a
  method that only names `a` and `b` gained two hidden inputs.
- The merge scan and the throw-channel scan read `Model: x`, where the formal
  is named like a Structure, as a declaration of `x` by `Model`. The caller
  got merge machinery and a throw channel it does not have.
- The receiving-use scan read a naming Frame whose name is the caller's typed
  reference as a store to it. For a field read through the reference the
  coverage came out the same by accident. For the reference handed whole it
  came out known and empty where it is unknown.
- The statement classifiers read the naming Frames of a call written as a
  statement as a type, a name and a candidate. The answer did not change,
  because a call's head is not a type; the work did.

**The binding's memory.** Every block the binding allocates beside the
source, the projections and the Structures that keep a named body whole,
comes from `l2_bound_alloc` and is released by `l2_bound_free`: in the
finaliser of `l2_translate`, after the procedures' shells and before the
document is destroyed, and at the start of a unit. The blocks borrow the
source's nodes and own none. It is an arena of the binding, not a list of
all allocations. The translator's allocation log (`L2_ALLOC_LOG`) reads
`live=0` for the programs with named actuals; with the release taken out it
reads the blocks live (control `nofree` below).

**Census on isolated bytes.** The live tree was not changed for any of this.
Three tools, kept in the session's scratchpad:

- *Replay.* A harness evidence directory records the translator command of
  every row. The replay runs each command with another translator and keeps
  the exit, the messages, the generated L1 and the allocation count. It takes
  25 seconds for a full gate's rows and no gcc.
- *Variants.* A copy of the translator built beside the live one with one
  change: `empty`, the written body of a bound call holds no field after the
  binding; `rewrite`, it holds the projection, as the old code left it.
- *Controls.* A copy in which one migrated reader enters the written body
  again.

**Results.** The rows are the 1493 recorded translations of `fable_full_17`,
the 54 of the focused cohort `fable_bind_04` (every row that binds a named
actual, old and new) and 13 stress programs, each natively and with its
methods walked: 26 runs.

- The working translator gives the same exit, messages and generated L1 as
  the committed one on every row. The change is not visible in one generated
  byte.
- The `empty` and the `rewrite` variant give the same output as the working
  translator on every row: no reader's result depends on what the written
  body of a bound call holds.
- The allocation count is the same for the working translator and `rewrite`
  on every row. Against `empty` it differs on two rows, a callable formal's
  call, by the test of `l2_empty_call_shape` for a body with no field, which
  the written body of a bound call never is.

The allocation count found what the output could not. Before
`l2_declaration` passed over bound calls, 25 rows had the same output and
another count; a debugger trace of the allocations put every difference under
`l2_declaration`, reached from the statement classifiers.

An earlier run of the controls is discarded. I had stopped it with the
tool's stop; its shell chain ran on and built in the shared variant stage
while other builds ran there, and one of its results was an artifact of that
race. Everything below is from one sequential rerun with nothing else
running, and a variant build now fails if its staged source changes under it.

**Integrity of the source.** A variant hashes every bound body when its
record is made, with its first, last and count, every field, value, flag and
kind and the same of each Frame among its fields, and hashes it again when
the translation ends. It reports nothing on the 1547 replayed
translations. Its two controls report on every row that binds: with the old
rewrite on top, 26 of the gate's rows and 45 of the cohort's; with one link of the written list cut,
20 and 37. A third diagnostic says a call bound a second time; it says nothing
on the same rows, so one record per body holds without a guard.

**Controls.** One reader each goes back to the written body. "Output" is a
difference in exit, messages or generated L1; "allocations" is a difference
in the allocation count only.

| The reader that enters the written body again | Gate rows, of 1493 | Cohort rows, of 54 | Stress runs, of 26 |
| --- | --- | --- | --- |
| The call check | output 25 | output 44 | output 26 |
| The native call, each actual by its formal | output 26 | output 42 | output 21 |
| The native call, the count of actuals | none | none | none |
| The graph call of a method, as an operand | output 24 | output 41 | output 24 |
| The graph call, as a statement | output 4 | output 6 | output 2 |
| The graph call through a path the head resolver does not take | none | none | none |
| The free-name scan, a method's call | output 17 | output 31 | output 17 |
| The free-name scan, a callable formal's call or a path call | output 6 | output 7 | output 3 |
| The free-name scan, a call written as a statement | output 4 | output 6 | output 2 |
| The merge scan | allocations 22 | output 3 | output 2 |
| The throw-channel scan, a body's fields | allocations 20 | output 3; the library row is refused, `unsupported library ABI` | output 2 |
| The throw-channel scan, a statement's inner fields | allocations 8 | allocations 16 | allocations 10 |
| The receiving-use scan | none | none | output 2 |
| The receiving-use mentions and the scan for a path's segment | none | none | none |
| The binding's recursion, a naming Frame walked as a statement | allocations 1 | output 2: `more arguments than h has formals` | output 2 |
| `l2_declaration` | allocations 25 | allocations 44 | allocations 26 |
| The room for own rows | allocations 22 | allocations 41 | allocations 24 |
| The method's locals, receives, the node of a free name, the uses of `implements` | none | none | none |
| The callable merge's mentions, value mentions, returns; the capture scan | none | none | none |
| The binding's memory never released (`nofree`) | allocations 26, `live` above 0 | allocations 45 | allocations 26 |
| The binding's memory released when the binding pass ends (`earlyfree`) | output 26 | output 45 | output 26 |

The receiving-use scan had no witness in the cohort of 54. The fixture
`unit_named_actual_reference_whole` and its probe row were added for it
afterwards: under that control the generated text gains the coverage call the
probe forbids.

The readers with no witness are equivalent by construction today: a naming
Frame's head is one identifier, never a path below a capture, a `return` or a
name with a field path, and a bound call has the same number of written
actuals as of formals. They take the actuals for the one rule, not for a
measured difference, and this table says so.

**Rows.** New fixtures, each natively and with the root and its methods
walked unless noted; the walked rows name the methods they walk:

| Fixture | What it holds |
| --- | --- |
| `unit_named_actual_scope_names` | The formals' names are also unit fields, locals and hidden inputs of the callers, in every position a call stands. A method that names them and reads neither takes no hidden input. |
| `unit_named_actual_method_names` | Formals named like methods; a payload that is a call of the method; the written order. |
| `unit_named_actual_reference_name`, `unit_named_actual_reference_whole` | A formal named like the caller's typed reference. A field read through it is no store, so the reference receives the thinner candidate. The reference handed whole is a use by another Consumer; a temporary probe row holds that it gets no coverage today. |
| `unit_named_actual_structure_name`, `..._lib` | A formal named like a Structure: no declaration, no construction. The library row links: a method on the throw channel has no library ABI. |
| `unit_named_actual_capture` | A definition inside a method names its host's names. |
| `unit_named_actual_callable_names` | A callable formal invoked with colliding names. Native only: the walked profile excludes callable formals. |
| `unit_named_actual_facts` | A read through `node`, an admitted formal passed on, a whole typed reference and a store's right side stand only inside named actuals. |
| `unit_named_actual_forms`, `unit_named_actual_machine` | A body kept whole, the empty Structure, a loop's condition and body, a block with its catch, a message field; a cast operand, a throw's payload, the colon form, an element store, a size. |
| `unit_named_actual_free_name_refused` | A free name inside a named actual is said at its own place, not at the naming Frame of the same name. |

**OPEN, found on the way.** All three reproduce on the committed translator
and none is a matter of the written body.

- `unit_named_actual_head_index`: a named actual inside the index of a
  store's head. The head is parsed apart and the binding does not walk it:
  `unknown method`.
- `unit_named_actual_held`: a held callable called with named actuals. Its
  head resolves to an own field, not to a method, and the binding does not
  bind it: `unknown method`.
- `unit_throw_nested_actual_walk`: with the methods walked, a throwing call
  that is an actual of another call loses its payload and the run stops at
  the kernel's `catch payload` invariant. Written as `return: boom(3 3)` or
  through a local, the same throw reaches its handler. Natively it runs.

They are required positives and stay red. One more observation, recorded and
not changed: translation time grows faster than the program.
A generated unit of 300 methods with ten named calls each translates in
25 seconds and one of 600 in 90; the committed translator takes 32 and 147,
with the same output. The cost is older than this slice. The accessor finds a
record by its body's address with a linear search, which did not show in that
measure.

**Evidence.**

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_06` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_06` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_19` (full harness) | RED 34 of 1534. Against `fable_full_17` (RED 29 of 1494): FAIL→OK 0, OK→FAIL 0, removed 0, added 40. Of the added, 14 are the rows of section 42 with its two OPEN positives, and 26 are this slice's with the three OPEN positives above. |
| `build/l2_harness/fable_bind_05` (focused) | 57 rows, every row that binds a named actual: red only the three OPEN positives. |

The full gate ran twice. `fable_full_18` (RED 34 of 1531) ran with the kernel
and L3 gates on the same translator bytes; the fixture
`unit_named_actual_reference_whole` and its three rows were added after it,
and `fable_full_19` is the gate of the committed bytes. Between the two: three
rows added, all green, nothing else changed. The pre-gate hashes of the
translator, the 15 fixtures and the harness equal the live files and every
staged copy (`tie.py`).

<a id="operand-throw"></a>
## 44. A throw raised while an operand is evaluated; the order after section 43 (Codex, FABLE-CODEX-20261004-05)

Codex inspected `3e5db011` and took it as a bounded development checkpoint:
it closes neither G5 nor the decoder and comments obligations. Its reply,
given without escalation to the author:

- **Views.** Semantic readers stay on the actuals. Source order,
  containment, source diagnostics and the codec's traversal stay on the
  written body. A count of fields and the bounds of a traversal refer to the
  same chosen view, and neither the physical field count nor the count of
  written actuals is by itself a callable's arity.
- **The role in `l2_declaration`.** The early answer for a resolved call is
  right. Its criterion is the established call role, not the named syntax,
  and an earlier cached classification must not override a later resolved
  role: today the cache lookup stands before the test. The phase and cache
  invariant is to be verified, not covered by guessed checks per field or by
  an exception for named calls.
- **The binding's memory** is an exact owner: compiler-owned binding storage,
  with one reset and release boundary on success and on failure.
- **Containment** stays source-only. A synthetic projection operation is
  diagnosed through the written wrapper, payload or span it comes from.
- **Both binding-reach positives are required before G5**, through the shared
  expression and body entry and the resolved actual signature of the
  callable: no reparser for indexes alone, no branch by name, not the
  constructor's own prototype, no invented adapter of no inputs. Written
  evaluation order and transport by formal coordinate are kept.
- **Order.** First
  [WALK-THROW-PAYLOAD-NESTED-ACTUAL](defects.md#walk-throw-payload-nested-actual)
  and the expression-head reach, as separate bounded slices. Then the held
  call's named binding through its actual signature; a real capture or
  signature prerequisite is to be named exactly and done first. Then the
  receiving-use remainder with [section 42](#receiving-use-follow-up)'s OPEN
  positives, then nested admission and the capture closure in dependency
  order. UNKNOWN does not become EMPTY or a claimed normative
  incompatibility. No pointer implementation, stable promotion or self-build
  on RED34/1534. The super-linear translation time stays a measured debt.
- **Process.** A stop request is not proof that descendants stopped: they are
  verified to have exited before the stage is reused.

This section is the first of those slices.

**The defect.** With the methods walked, `return: f(boom(3 3) 0)` lost the
payload of boom's `Oops(3)` and the run stopped at the kernel's
`catch payload` invariant. Written as `return: boom(3 3)` or through a local,
the same throw reached its handler, and natively all three ran.

**The cause is in the kernel.** `lmx_walk_call` (CALL, EXEC) and
`lmx_walk_prim` (PRIM, PRIM_PUB) evaluate their operands and then run their
callee. After both they asked one question, whether the operation ended in a
throw, and took the answer for the callee's throw: the frame's payload was
set from the operation's own result, and the operation's catch rows were
applied to the number. A throw raised while an operand was evaluated is not
the callee's. The callee did not run and the operation's result is empty:
that is the lost payload. The operation's rows are keyed by its callee's
throw numbers, while the number that arrives from the operand is already the
caller's: the operand's own rows mapped it to a pad of the caller or
renumbered it to the caller's exit. Applied to it, the rows of another
callee send the throw to another handler or renumber it once more.

**The fix.** Each of the two operations notes that it reached its callee and
takes the payload and applies its rows only then. An operand's throw leaves
the operation as the operand set it: the same number, the same landing, the
same payload. No operation is added and none is special:
`lmx_walk_actuals` already stopped at the first operand that did not return
OK, so the remaining operands and the callee were already not run. The third
place that sets a payload and scans rows, the admission check, raises only
its own throw and returns an operand's status before that. The translator is
unchanged.

**Witnesses.** The kernel selftest `lmx_walk_catch_selftest` gains nine
checks, 34 in all. With a PRIM and with a CALL as the outer operation: an
operand's throw lands on its pad, the handler reads the operand's payload,
the outer callee is not run; with no pad the operand's renumbered throw
passes the outer operation's rows unchanged, though a row for that number
stands there; an operand written after the one that threw is not evaluated.

The fixture `unit_throw_nested_actual` holds nine cases, natively and with
the root and the methods walked:

| Case | What it holds |
| --- | --- |
| 1, 2 | Controls: the throwing call returned directly and through a local. |
| 3, 4 | The throwing call as an actual, and as an actual of an actual. |
| 5 | The throwing call as a named actual of a call that is itself named. |
| 6 | The throwing call between two actuals with an effect: the first runs, the second and the callee do not. The trace is 1. |
| 7 | The same places with no throw. |
| 8 | An actual of a held callable's call, a PRIM: the callable does not run. |
| 9 | An actual of a callee with a throw name of its own, in a block that catches both names. Both names are the first of their methods; taken for the callee's, the throw would reach the other handler. |

The walked row walks every method but `boom` and `wide`, whose throw with a
payload is machine text; the row names them.

**Mutants.** Six mutants of the kernel, three for each operation. Each was
run against the kernel selftest, and against the fixture's walked row in an
isolated copy of the tree with nothing else running there.

| Mutant | Kernel selftest | The fixture's walked row |
| --- | --- | --- |
| None | 34 checks, no failure | green |
| CALL as before the fix: the payload and the rows taken for any throw | exit 3, `lmx: invariant: catch payload` | exit 3, the same invariant |
| CALL: the payload kept, the rows applied to an operand's throw | 1 of 34 fails: `operand throw is not renumbered by the CALL's rows` | exit 89: case 9 reaches the other handler |
| CALL: the rows kept apart, the payload replaced | exit 3, the invariant | exit 3, the invariant |
| PRIM as before the fix | exit 3, the invariant | exit 3, the invariant |
| PRIM: the payload kept, the rows applied to an operand's throw | 1 of 34 fails: `operand throw is not renumbered by the outer PRIM's rows` | green: the translator emits a held call's PRIM with no catch rows, and the selftest alone tells |
| PRIM: the rows kept apart, the payload replaced | exit 3, the invariant | exit 3, the invariant |

The native row is green under every mutant: a method's native code raises
and catches its throws without these operations, and the walked root's calls
there have no throwing operand. The first focused run of the mutants had no case
that told the CALL's rows applied: its two-name case stood in a method with
no handler, where a wrong renumbering is not seen. Case 9 replaced it.

**Evidence.**

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_07` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. `lmx_walk_catch_selftest`: 34 checks, no failure. |
| `build/l3_selftest/fable_l3_07` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_20` (full harness) | RED 33 of 1534. Against `fable_full_19` (RED 34 of 1534): FAIL→OK 1, `unit_throw_nested_actual_walk`; OK→FAIL 0; no row added or removed; no red row's message changed. |

The 33 red rows are the 29 of `fable_full_17` and four labelled OPEN
positives: `unit_recv_use_nested_dormant`, `unit_recv_use_passed_thin`,
`unit_named_actual_head_index`, `unit_named_actual_held`. The pre-gate hashes
of the kernel source, its selftest, the fixture, the translator and the
harness equal the live files and every staged copy (`tie.py`).

**Next, in the order of the reply.** The expression-head reach, with the
phase and cache invariant of `l2_declaration`; the held call's named binding;
the receiving-use remainder; nested admission and the capture closure.

<a id="head-binding-reach"></a>
## 45. The binding reaches an indexed head; the reader of declarations answers by the call role (Codex, FABLE-CODEX-20261004-06)

**Codex's reply to the checkpoint of section 44.**

- The operand-throw repair is accepted as a bounded checkpoint. The limit
  stays documented: the mutant that applies a PRIM's rows is told by the
  kernel selftest and not by the translator's fixture. Not every throw
  producer and not the graph checkpoint are closed by it.
- The head reach goes through the single cached head-expression tree and the
  ordinary recursion of the binding. No second head parser and no rule for a
  call in an index.
- A correction of what I reported as part of the author's open question. A
  formal declared with a callable signature is not the head-role question in
  `LMX_blog/q/current/`: that one is about a head with no formal, no visible
  binding and no earlier read. For a declared callable formal `p`, the
  statement `p: x` is the ordinary call of what `p` carries. Equivalent
  completed spellings choose one operation. The category comes from the
  declared callable contract, not from a pointer-shaped transport, and
  lexical shadowing is kept. A classifier or collector that selects a store
  before this role is a defect of resolution order: the common decision
  (`l2_call_head_method`, `l2_head_is_call`) is to be reused, with no
  exception by name, by colon form or for formals only. It is recorded below
  as an OPEN required positive and goes with the held-call slice or right
  after it.
- The hidden-input examples that wait for the author stay as they are.

### The reach

`l2_head_expression` already parsed the head of `row[i]: v` apart, once per
statement, and kept the tree by the statement: the free-name scan, the array
place, the check, the native text and the graph all take that one tree. The
binding did not walk it, so a call there with a named actual was read with no
record and refused as `unknown method`.

`l2_bind_node_content` now asks for the statement's head expression and walks
its body through `l2_bind_struct`, the recursion that walks any body. A head
that does not parse is said by `l2_head_expression`, as it was at the first
reader that asked. Nothing else changed for the head: the check, both
emissions and the diagnostics already read a call's actuals through
`l2_call_actuals`.

### The role and the cache

Codex asked for the phase and cache invariant of `l2_declaration` to be
verified. It was measured on isolated bytes, by replay of the
1533 translator commands that `fable_full_20` recorded.

**The invariant "no Frame is classified before it is bound" does not hold,
and cannot.** A diagnostic variant reports, when a call's record is made,
every declaration already cached for the call's Frame or for a Frame that
names one of its actuals. It reports on 8 of them, four fixtures: on 2 rows the call's own Frame was
read and kept (`unit_named_actual_scope_names` and its walked twin), on 6 a
Frame that names an actual (`unit_named_actual_facts` and its twin,
`unit_named_actual_formal`, `unit_named_actual_reference_whole` with its twin
and its probe row). A debugger
trace puts every one of them on one path: the collector of own rows
(`l2_collect_decls`, `l2_own_decl_ty`). It runs before the binding and has
to, because the binding resolves a call's head against those rows. It reads
each statement by its shape, and `l2_declaration` reads a Frame that holds a
single Frame through that Frame: for `r: f(v: v)` the Frame `v: v` is read
and kept as "type v, name v", and for a call whose first actual is a name
and whose later ones are named, `f(x b: 1)`, the call itself is kept as
"type f, name x".

**What has to hold is that the cache is transparent**: with the cache
switched off, the reader gives the same answers. A second variant never
answers from the cache. On the 1533 rows it gives the output
of its cached twin, for the committed translator and for this slice's. One
program is not transparent on the committed translator:

```text
fn: use (int: x) int
    @: f(x b: 1)
    return: x
```

It is refused either way, as it should be: the address of a call is no
statement. But the committed translator names `f` an unknown type at the
call (the kept reading, "a pointer to f named x"), and with the cache off it
says `unsupported body` at the statement. The test in `l2_declaration` that a
bound call declares nothing stood after the cache lookup, and it looked at
the Frame alone, not at a Frame read through it.

**The fix.** `l2_declaration` asks the role first, before the cache, through
`l2_declaration_meets_call`: the Frame itself, or a Frame its reading passes
through, has a record of the binding. The path is the one the reader itself
takes, the single field of a Frame when that field is a Frame. With it the
program above is refused in the same words with and without the cache, and
the row `unit_named_actual_address_statement_refused` holds that. The row
holds the independence from the cache, not the wording.

Two things are left as they are and said here. A Frame that names an actual
keeps its cached shape; no reader of the actuals reaches it and the readers
of the written body do not classify, and the transparency holds on every
row. And the role is recorded for a call with a named actual only, so the
positional `@: f(x 1)` is still refused as an unknown type `f`: the two
spellings are both refused, in different words. The role of a positional
call is decided where the statement is classified, by the common decision
named in Codex's correction above; that is the follow-up, not this slice.

**The index.** Asking the role before the cache put the lookup of a record
on every call of the reader, and the lookup was a linear search over the
records. That cost was measured before it was kept:

| A generated unit, each method with ten named calls | Committed translator | Role asked first, linear lookup | This slice |
| --- | --- | --- | --- |
| 300 methods, 3000 records | 9.8 s, 9.3 s | 11.9 s, 11.4 s | 9.4 s, 9.2 s |
| 600 methods, 6000 records | 44.5 s | 51.8 s | 41.9 s |

The generated L1 is the same from all three.


The records are now found by their body's address through an index, an
open-addressed table of record numbers that starts at 64 places and is kept
at most half full (`l2_bound_place`, `l2_bound_index_grow`), as the kernel's
copy map does it. It is the binding's own storage and is released with it.
Every reader of a call's actuals goes through the same lookup, so the debt
recorded in [section 43](#written-body-kept) for the accessor's linear
search is paid with it; the growth of translation time with the size of a
program stays a debt.

### Replay and census

The slice's translator against the committed one, on the 1533 recorded
translations:

- Exit, messages and generated L1 are the same on 1532 rows. The one other is
  `unit_named_actual_head_index`, which now translates.
- The allocation count differs on 130 rows. The binding asks every Frame for
  its head expression, and the head `[]` of an Array declaration is parsed
  and found to be no indexed head: one allocation, released at once. A
  measuring variant that does not ask a head that starts with `[` leaves 5
  rows of the 130: the head-index fixture; `unit_named_actual_machine` and
  its walked twin, higher by 5, the working arrays of binding the positional
  call in `row[g(1U 1U)]`; and `unit_named_actual_scope_names` and its twin,
  lower by 169, the role asked before the cache. The other 125 rows are
  higher by 1 to 6 and by nothing else.
- No body is bound a second time: the diagnostic variant says nothing on any
  row or new fixture.
- With the index and with the role asked of the Frame alone, the output and
  the allocation counts are those of the slice on every row. The reading
  path shows only in the program above.


### Rows

| Fixture | What it holds |
| --- | --- |
| `unit_named_actual_head_index`, natively and walked | Rewritten. Its callee was `a + b`, which gives one result bound by name and by place. It is `a * 2 + b` now: bound by place every case writes another cell. Seven cases: the call alone as the index; named calls as the named actuals of the index; the call beside an operator, on either side; actuals with an effect, in written order (the trace is 12); payloads that read the caller's locals of the formals' names; an indexed field of a Structure; a store of the root. |
| `unit_named_actual_head_index_name_refused` | A name that is no formal, inside the head: the ordinary refusal, at its own column. |
| `unit_named_actual_head_index_free_refused` | A free name inside a named actual of the head: said at the read, not at the naming Frame of the same name. |
| `unit_named_actual_address_statement_refused` | The transparency of the cache, above. |
| `unit_named_actual_index_growth`, natively and walked | 90 named calls in one unit: the index grows twice. |
| `unit_callable_formal_statement` | OPEN, red, required: see below. |
| `unit_callable_formal_statement_controls` | The neighbours that run today, see below. |

### Mutants

Each is a copy of the slice's translator with one change, built apart; the
rows' verdicts follow from the translator's exit and message.

| Mutant | What the slice's fixtures say |
| --- | --- |
| The binding does not walk an indexed head | `unit_named_actual_head_index` is refused, natively and walked, as `unknown method`; the two refusals in the head get that message in place of their own. |
| The cache is asked before the role | `unit_named_actual_address_statement_refused`: `unknown type` at 12:8. |
| The role is asked of the Frame alone, not along the reading path | The same row, the same refusal. |
| The index grows without placing the earlier records again | `unit_named_actual_index_growth` is refused, natively and walked, as `unknown method`: a record is not found. |
| The index does not search past an occupied place | The head-index and the index-growth fixtures are refused, each run in another way: a body is given another body's record. |


### OPEN: a callable formal called as a statement

Measured on the committed translator, and unchanged by this slice:

```text
fn: note (int: a) int ...
fn: colon (note: p; int: x) int
    p: x            # 20:5 assignment value has incompatible type
fn: paren (note: p; int: x) int
    p(x)            # the same tree, the same refusal
fn: named (note: p; int: x) int
    p(a: x)         # assignment value has unknown type
```

`p` is a formal declared by the signature of the method `note`, and each
statement is the call of what `p` carries. The statement is taken for a
store to the formal. The same call in an expression, `r: p(x)` and
`return: p(a: x)`, translates and runs. When the unit also has a method
named `p`, the statement translates and calls what the formal carries, not
the method: the classification of the statement depends on whether a method
of that name exists, though the callee does not. A formal of a number type
of that name is stored to, as it should be.

The positive `unit_callable_formal_statement` is red and required. The
controls are in `unit_callable_formal_statement_controls`: the call in an
expression by place and by name, the number formal that is stored to, the
callable formal named like a method of the unit, and a method called as a
statement. They are native rows: the walked profile excludes callable
formals ([defects](defects.md#callable-formal-statement-store)).

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_08` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_08` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_21` (full harness) | RED 33 of 1542. Against `fable_full_20` (RED 33 of 1534): FAIL→OK 1, `unit_named_actual_head_index`; OK→FAIL 0; added 8, of which one is red, the OPEN positive `unit_callable_formal_statement`; no row removed; no red row's message changed. |

The 33 red rows are the 29 of `fable_full_17` and four labelled OPEN
positives: `unit_recv_use_nested_dormant`, `unit_recv_use_passed_thin`,
`unit_named_actual_held`, `unit_callable_formal_statement`. The pre-gate
hashes of the translator, the seven fixtures and the harness equal the live
files and every staged copy (`tie.py`).


**Next.** The held call's named binding through the header of its declared
callable type, with the statement call of a callable formal in the same
resolution work or right after it; then the receiving-use remainder.

<a id="held-named-binding"></a>
## 46. A held callable's call is bound by the header of its declared type (Codex, FABLE-CODEX-20261004-07)

**Codex's reply to the checkpoint of section 45.**

- The indexed-head slice is accepted as a bounded checkpoint. The index over
  the records is compiler-owned acceleration of the existing records: no
  runtime registry, no atom metadata, no permission. 64 is a first capacity,
  not a cap of the language. Full address equality, probing, re-placing on
  growth and release with the translation stay.
- **A cached shape of a Frame that names an actual** may remain while no
  semantic reader consults it, it owns no field or value of the language and
  it is released at its owner's boundary: no lookup of wrappers on every
  read of a declaration. But "the cache is never read again" does not undo a
  side effect: the provisional readings must not have published phantom own
  rows, hidden inputs, capture or merge state or throw channels. That is
  checked below.
- **The reading path** is the declaration reader's own nesting, not a rule
  that an outer Structure holding a call becomes a call. A named Structure
  keeps a nested application in its body; an enclosing receiver follows its
  own contract.
- **The two refusals of an address statement** need not share their words.
  The transparency of the cache is a probe of the implementation, not a
  requirement on the wording or on a record for a positional call. But the
  absence of a record is no evidence that a head is not callable: the call
  role comes from the shared resolved binding, category and contract for
  every form, and the statement classifier is to use it.
- **The held call.** The declared result header is the static description
  of the returned callable: its names resolve the names and coordinates of
  the call. It is not proof that every actual has the same complete formals,
  hidden inputs, defaults, exits or native body: the selected actual callable
  supplies its own execution contract. No truncation of a signature, no
  invented empty list of hidden inputs, no jump to a prototype's native
  body. Valid wider cases that are not supported stay OPEN positives.
- **The uniform request for a head expression** is kept. A saving, if wanted,
  belongs at the common boundary under the grammar, not in a rule of the
  binding about `[`.

### What the provisional readings published

A diagnostic variant asks, when the binding pass ends and again after the
assignment binds are collected under the established roles, of every own
row, every named Structure with its statement, and every method: is its
declaring node the Frame of a bound call, or a Frame that names an actual?
On the 1541 translations recorded by `fable_full_21` it says
nothing. Its control plants the first naming Frame as the declaring node of
own row 0 and reports on 53 rows.

The passes that run before the binding are the collection of each method
with its own rows and formals, the local named Structures, the assignment
binds and the references of named Structures; their products are the own
rows, the named Structures and the methods asked above. The scans that make
hidden inputs, merge results and throw channels (`l2_dyn_local`,
`l2_merge_scan`, `l2_body_throws`) run after the binding and read a call's
actuals.

The neighbour of the reading path is `unit_named_actual_structure_body`: a
named Structure whose body is one call with named actuals runs that call
each time it is executed, and one with a second statement beside the call
does too. It ran before the slice of section 45 and runs after it.

### The binding

A held callable, `h2: make2 100`, is called by the formals of the header of
its declared type: `make2` declares its result as `fn: (int: x; int: y) int`,
and `x` and `y` are the names of a call of `h2`. They are not `make2`'s own
input `n`. Where the header says `p` and `q` and the returned definition
says `x` and `y`, the implementation binds the call by `p` and `q`.
**Corrected in [section 47](#site-role):** that last sentence says what the
translator does, not an approved rule; it is an OPEN discrepancy and the
case left the positive fixture.

- `l2_bind_node_content`: a Frame whose head is no method and is a held
  callable (`l2_mad_held`, the test the check and both emissions use) is
  bound by `l2_bind_call` with the header's formals
  (`l2_mad_held_formals`, `l2_mad_held_arg_name`). The binding itself is the
  one a method's call gets; `l2_bind_call_in` takes the names and no longer
  asks which callee they come from.
- The check reads the actuals of the held call through `l2_call_actuals`.
- Native code (`l2_prep_held_call`) evaluates the actuals once, in written
  order, each into its formal's place (`l2_bound_formal`).
- The retained `PRIM_PUB` (`l2_rw_mad_call`) keeps each operand at its
  written place; a named one stands under `NAMED` with its written name and
  its coordinate among the primitive's inputs, where the callable is input 0
  and formal j is input 1 + j. The kernel is unchanged: its PRIM reads
  operands through the reader a CALL uses.

The header is used for names and coordinates only. The call still runs
through the held value: the callable in the holder, its hidden inputs from
the model, the contract of the primitive. The limits of that route are the
ones it had: the header is numbers to a number.

### Diagnostics

Every held call is bound now, a positional one too, so a wrong count is
refused by the binding in the words a method's call gets:

| Program | Before | Now |
| --- | --- | --- |
| `h2(1)`, two formals | 8:8 `a held callable takes the arguments of its header` | 8:8 `h2 has no argument y` |
| `(p5: 1)`, two formals | 10:9 the same words | 10:9 `p5 has no argument y` |
| `h2(1 2 3)` | at the call, the same words | at the third actual, `more arguments than h2 has formals` |

The rule is the one those rows held and the place of the first two is the
same. The needles of `unit_held_call_count_refused` and
`unit_t6_root_held_arity_refused` follow the words, and
`unit_held_call_more_refused` is new. The check and the emissions keep their
own test of the count; no row reaches it now.

### Replay

The slice's translator against the committed one, on the 1541 recorded
translations:

- Exit, messages and generated L1 are the same on 1538 rows. The other three
  are `unit_named_actual_held`, which now translates, and the two count
  refusals of the table above.
- The allocation count differs on 90 rows: 5 more for each held call the
  binding binds, its working arrays, and 2 more for each formal of a header
  read for its name, the declaration and its contract, made once.
  `unit_held_call_arity` has eight held calls and five header formals, and
  its count is higher by 50.
- With the binding of held calls switched off and the rest of the slice in
  place, the output and the allocation counts are the committed translator's
  on every row: nothing else in the slice shows.


### Rows and mutants

`unit_named_actual_held` is rewritten, natively and walked: the root's call;
both actuals named against their order; one by place and one by name;
actuals with an effect in written order (the trace is 12); a held call as a
named actual of a held call; payloads that read the caller's locals of the
formals' names; and the header whose names differ from the returned
definition's. Four refusals: a name that is no formal, a formal given by
place and again by name, a formal left out, and the names of the returned
definition. (The case of differing names and the last refusal became two
labelled probes in [section 47](#site-role).)

| Mutant | The native row | The walked row |
| --- | --- | --- |
| The binding does not bind a held callable's call | refused, `unknown method` | the same |
| The header's names taken in reverse | refused, `given by position and again by name` | the same |
| The check reads the written body | refused, `unknown method` | the same |
| Native code evaluates the actuals in the formals' order | exit 84, the trace | green |
| The graph puts each operand at its formal's place | green | exit 84, the trace |
| `NAMED` carries the formal's index, not its coordinate among the inputs | green | the walk refuses the graph, `INVALID`, exit 3 |
| The graph puts a named actual with no `NAMED` | green | exit 87, a wrong value |

The last four change generated code only where that code runs: natively
for the native call, walked for the graph.


### OPEN, found on the way

Both are older than this slice and both are the statement and head role
decided without the binding of the site, the family of
[CALLABLE-FORMAL-STATEMENT-STORE](defects.md#callable-formal-statement-store).

- A local that is no callable and has the name of the root's held callable
  does not hide it: with `int: h2 5` in a method, `h2(1 2)` is accepted and
  the generated C does not compile (`l2_q2_from` undeclared). A method
  hidden by such a local is refused as `unknown method`
  ([defects](defects.md#held-call-ignores-site-binding)).
- A store to a number formal or local escapes the check of its value when
  the unit has a method of that name: `p: "text"` into `int: p` is refused
  as `assignment value has incompatible type` in a unit with no method `p`
  and accepted in a unit with one
  ([defects](defects.md#store-unchecked-under-method-name)).

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_09` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_09` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_22` (full harness) | RED 32 of 1550. Against `fable_full_21` (RED 33 of 1542): FAIL→OK 1, `unit_named_actual_held`; OK→FAIL 0; added 8, all green; no row removed; no red row's message changed. The two count refusals stay green under their new needles. |
| `build/l2_harness/fable_heldcall_01` (focused, before the gate) | 156 rows of held callables, captures and named actuals: red only seven rows of the baseline and the OPEN positive `unit_callable_formal_statement`. |

The 32 red rows are the 29 of `fable_full_17` and three labelled OPEN
positives: `unit_recv_use_nested_dormant`, `unit_recv_use_passed_thin`,
`unit_callable_formal_statement`. The pre-gate hashes of the translator, the
seven fixtures and the harness equal the live files and every staged copy
(`tie.py`). No log of the gate holds the words
`a held callable takes the arguments of its header`.


**Next.** The statement and head role from the binding of the site: the
statement call of a callable formal, the store under a method's name, the
held callable hidden by a local. Then the receiving-use remainder.

<a id="site-role"></a>
## 47. The role of a statement and of a call head from the binding of the site (Codex, FABLE-CODEX-20261004-08)

**Codex's reply to the checkpoint of section 46.**

- The changed wording of the count refusals is accepted: the shared binding
  reports a missing or an excess actual, and keeping the old words by a
  branch on the callee's kind would have been wrong. The lower count tests
  go in the ordinary cleanup once an inventory of their callers proves them
  redundant; "no row reaches the old words" is not that proof.
- The probe of published state stands as bounded evidence, with its limit of
  depth: its silence is not the absence of every side effect inside a
  payload.
- **A known held callable applied by a statement is not the author's open
  question.** The semantics, section 9 (`#construction`): "An existing
  callable Structure, directly or through its held reference, is called; a
  call error does not become declaration or assignment." Where the binding
  of the site is the held callable, `h: v` is its application; it does not
  turn into a reassignment because the value lives in an own row. A binding
  of a number or a reference follows its own contract, and a local `int: h2`
  blocks the root's held `h2`. `l2_call_head_method`'s -1 is not a verdict
  "assignment": it leaves other callable categories to later routes. One
  decision from the binding of the site to the category and the operation,
  not a method-only classification beside a lookup of a held name by name.
- **The differing header and definition names are not an approved
  positive.** The earlier approval was for the returned callable's
  description against the constructor's own inputs. It did not approve a
  renaming of formals. The semantics: the named supplies of the actual use
  must be accepted by the candidate's actual interface, with its canonical
  names, and an exemplar signature does not replace that interface
  (`#three-argument-implements`); the declared result type checks the
  resulting callable and is not a third operand of the composition
  (`#composition`, returned nested methods). The case is to be an OPEN
  discrepancy with its reproducer kept, not a positive and not the evidence
  of an aliasing rule.

### The correction of section 46

Section 46 stated that a held call binds by the names of the declared header
"and not the names of the definition the constructor returns", and its
fixture held a case with the header `(p, q)` over the definition `(x, y)`.
That was the implementation's behaviour written as a rule. The case left
`unit_named_actual_held`; the two programs are kept as labelled probes that
hold only what the translator does today:

| Probe | Today |
| --- | --- |
| `unit_named_actual_held_header_names_limit_probe`: `h3(q: 2; p: 1)` | bound by the header's names, reaches the definition by coordinate, 212 |
| `unit_named_actual_held_definition_names_limit_probe`: `h3(y: 2; x: 1)` | refused, `unknown method` |

Either the named use is not admitted by the interface the callable actually
has, or a mechanism that forms an interface with the header's names exists
and has to be shown. Neither is decided here
([defects](defects.md#held-header-names-not-actual-interface)).

### A regression of section 46, repaired here

The held slice bound every Frame whose head has the name of a held callable
of the root, with no look at the site. In a method with a local of that name
the store `h2: h2 + 2` was bound as a call of the root's callable and
refused, `h2 has no argument y`. No row of the gate had the shape, so the
gate of section 46 did not see it; the fixture `unit_held_call_shadow` does.

### One decision

**The statement classifier takes its site.** `l2_is_asgn(stmt, mi)` asked
the unit's methods by name: a statement was a call exactly when a method of
the unit had its head's name. It now asks the head's role at the site, the
one a call head has there (`l2_call_head_method`): a head that calls, a
method or what a callable formal carries, is no assignment; a binding of the
site that is no callable is assigned to, though a method of the unit has its
name. That one change answers two defects that were each other's mirror: the
statement call of a callable formal was a store, and a store under a method's
name escaped the check of its value.

**The held callable takes its site.** `l2_call_head_held(mi, head)` gives
the held callable a head names in a method: a formal, another own row, a
slot or a machine local of the name blocks it, as such a binding blocks a
method of its name. The binding, the check, both emissions and the graph ask
it where they asked `l2_mad_held` by name.

**A held callable applied by a statement is its call.** `l2_is_asgn` and
`l2_head_is_call` ask `l2_head_is_held`; the statement that stores the
callable merge is that binding's own and is kept apart. The check and the
native emission then take the ordinary route of a call statement, and the
graph gets the branch beside the method's (`l2_rw_mad_call`).

**The provisional reading had published a row.** With only the above, a
method's statement `h2: 7 8` was still refused, `more arguments than h2 has
formals`. The collector of assignment binds visits the methods before the
root, so at its first pass the root's row for `h2` did not exist; the
statement was read as a definition local to the method and got an own row
there, and that row then stood between the method and the root's callable (a
diagnostic print shows the name resolving to a row of the method in every
later pass). This is the side effect Codex's reply to section 45 asked about,
one level away from where the probe of section 46 looked: the declaring node
was the statement itself, not a call's Frame. `l2_head_is_held` therefore
asks the unit's source when the row is not collected yet
(`l2_unit_holds_callable`, the statement that stores a callable merge under
the name), as `l2_unit_declares` and `l2_unit_names_method` already do for
the unit's other declarations. **Replaced in
[section 48](#site-selection):** that lookup answered for the whole unit,
whatever the site, and is removed; the roots are collected first and the
ordinary rows answer.

**What is not changed.** `l2_local_ns_shape` is untouched; it receives the
method index its caller already had. The heads the author's open question is
about, with no formal, no visible binding and no earlier read, resolve as
before: every one of the 1549 recorded translations but the
one fixed positive gives the same output. Two callers of the classifier have
no site and ask the unit's methods alone, as before: `l2_empty_call_shape`
and `l2_merge_atom_settle`. A second store of a callable merge under a name
that already holds one, `h2: make2 200`, is still a store. (A defect, fixed
in [section 48](#site-selection): it is the application of the callable.)

### Replay

The slice's translator against the committed one, on the 1549 translations
recorded by `fable_full_22`:

- Exit, messages and generated L1 are the same on 1548 rows. The other is
  `unit_callable_formal_statement`, which now translates.
- The allocation count differs on 4 rows: that fixture; its controls, higher
  by 2; `unit_local_source_binding_context` and its walked twin, higher by 8.
  In that program a scalar `f` of a local Structure is stored to in a unit
  with a method `f`: the store is an assignment for the classifier now, and
  its value is checked.
- The site rule of the held callable alone, without the classifier's change,
  gives the committed output and allocation counts on every row.


### Rows

| Fixture | What it holds |
| --- | --- |
| `unit_callable_formal_statement` | Green now. `p: x`, `p(x)`, `p(a: x)` and the nullary `q()` of a callable formal, in a unit with no method of those names. |
| `unit_store_method_name_refused`, `unit_store_local_method_name_refused` | A store of a string into an int formal, and into an int local, under a method's name: refused as any such store. |
| `unit_held_call_statement`, natively and walked | A held callable applied by statements at the root and in a method, in the paren and the colon form and by name; the method's first statement is such a call. The callable notes its actuals: the trace is 1234567890. |
| `unit_held_call_shadow`, natively and walked | A number formal and a number local of the held callable's name are read and stored to; a method with neither calls the held callable. |
| `unit_held_call_local_shadow_refused` | The call of a number local that hides the held callable: `unknown method`, as for a local that hides a method. |
| `unit_named_actual_held` | The case of differing names removed: six cases. |
| The two `..._limit_probe` rows | The OPEN discrepancy above. |

### Mutants

Each is a copy of the slice's translator with one change, built apart, and
compared with the slice on its fixtures, natively and walked.

| Mutant | What the slice's fixtures say |
| --- | --- |
| The statement classifier asks the unit's methods by name | `unit_callable_formal_statement` is refused, `assignment value has incompatible type`; the two stores under a method's name are accepted. |
| A callable formal is a call, but a method's name still makes a statement a call | The two stores under a method's name are accepted. |
| The held callable is found by its name alone | `unit_held_call_local_shadow_refused` is accepted; `unit_held_call_shadow` is refused, `h2 has no argument y`. |
| No statement role for a held callable | `unit_held_call_statement` is refused, `more arguments than h2 has formals`. |
| The held role asked of the collected rows only, not of the unit's statement | The same refusal: the method's statement gets a row of its own before the root is collected. |
| The graph has no branch for a held callable applied by a statement | `unit_held_call_statement` is refused, `not walkable yet`. |
| The statement that stores the callable merge is not kept apart | Every fixture with a held callable is refused, `unresolved name`. |


### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_10` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_10` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_23` (full harness) | RED 31 of 1558. Against `fable_full_22` (RED 32 of 1550): FAIL→OK 1, `unit_callable_formal_statement`; OK→FAIL 0; added 9, all green; removed 1, the refusal row renamed to a probe; no red row's message changed. |
| `build/l2_harness/fable_role_01` (focused, before the gate) | 301 rows of held callables, callables, stores, local sources and named Structures: red only nine rows of the baseline. |

The 31 red rows are the 29 of `fable_full_17` and two labelled OPEN
positives: `unit_recv_use_nested_dormant`, `unit_recv_use_passed_thin`. The
pre-gate hashes of the translator, the nine fixtures and the harness equal
the live files and every staged copy (`tie.py`).


**Next.** The receiving-use remainder with section 42's OPEN positives, then
nested admission and the capture closure. Recorded for the ordinary cleanup:
the count tests of a held call below the binding, after an inventory of
their callers.

<a id="site-selection"></a>
## 48. The held callable is the row its head selects at the site (Codex, FABLE-CODEX-20261004-09)

**Codex's reply to the checkpoint of section 47.**

- The matching-interface positive, the two probes of differing names and
  the OPEN discrepancy of section 47 stay as they are, and G5 stays blocked
  on it.
- **The second statement of the storing shape is a defect now.** "After h2
  has an established callable binding, h2:make2 200 is ordinary application
  of that binding, not another initialization solely because the RHS looks
  like a callable-producing factory. Its actuals must undergo the ordinary
  call/arity/type/admission rules; it may be an invalid call, but MUST NOT
  silently replace h2." The shape predicate `l2_mad_store_stmt` must not
  exempt every later statement before role resolution: "Review each
  interception point that does so; fix the shared criterion, not just the
  final emitter."
- **Whole-unit name presence is not the resolved role.**
  `l2_unit_holds_callable` and `l2_head_is_held` of section 47 search every
  statement of the unit for the storing shape under the name; a known row of
  another kind and a row not collected yet both look like "no held row", and
  an earlier source occurrence can supply an unjustified answer. "The common
  source-site selector must choose the eligible declaration
  occurrence/category with lexical host, source order, repeated-name
  selection, formal/own/hidden/local shadows and excluded initializer
  context; then the held-call route consumes that result." "Apply the
  established visibility of the DECLARATION CATEGORY; do not guess a new
  blanket forward/backward rule for every reference." Completing the
  ordinary scoped declaration metadata before the dependent decisions is
  preferred. "A held-only source scan standing beside collected-row
  resolution is still bounded implementation debt, not a new normative
  second resolver. Keep it labelled accordingly until the common selector
  replaces it."
- The two callers of the classifier that have no site may remain a bounded
  open audit if no failing program is known; they are to be inventoried
  without widening the work.
- This follow-up closes first, as a bounded slice; then the two receiving-use
  positives, whole-value composition, nested admission and the capture
  closure.

### What section 47 left wrong

**The second store replaced the callable.** After `h2: make2 100` the
statement `h2: make2 200` declared a second row, and the program ran to 200.
The storing shape was taken for a declaration wherever it stood: by the
collector, by the check, by the graph, by the native emission and by the
classifier's exemption.

**A regression of section 47.** `l2_unit_holds_callable` answered for the
whole unit. After `h2: make2 100` and a later `int: h2 5`, a method's
`h2: 7` was refused, `unknown method`: the name was still "a held callable
of the unit" for the classifier and no callable for the call. The translator
before section 47 stored the number. No row of the gate had the shape.

### The decision

**The roots are collected first.** The collector of assignment binds
visited the methods in their order and the entry last, so a method's
statement was classified before the root's rows existed; section 47 covered
that with the source-level lookup. The collector now visits the roots first
(the entry, and the root procedure of a program part) and then the other
methods. It is the same collector reserving the same rows; nothing is
executed and no field is added. The source-level lookup and its fallback are
removed. One effect reaches the output: the global index of an own row
appears in generated names, and it changes where a root's assignment bind
used to be numbered after a method's (see the replay).

**The store of a callable merge declares its head only where the head has
no binding at the site.** The collector reserves the row under that
condition (`l2_colon_bound_ty` finds nothing for the head, or the statement
already has its row from an earlier pass). Every later pass asks the
statement's own row, `l2_mad_declaring(stmt, mi)`: the storing shape and a
row whose declaring node is this statement. The check, the graph, the native
emission and the classifier ask it where they asked the shape. Under a head
that has a binding the same shape is a use of that binding: a held callable
is applied, a number is stored to.

**The held callable is the row the name selects.**
`l2_call_head_held(mi, head)`: a formal, a slot or a machine local of the
name is that binding. Otherwise the name selects a row as any name of the
site does (`l2_own_visible`): the site's own row declared last before the
site, within its lexical host; in a method, the field of the unit visible
from the method, which is the one declared above the method, the last of the
name. The head names a held callable when the store of a callable merge
declared the selected row. A selected row of another kind is that binding. A
later declaration does not reach back to an earlier site, and the row's
own initializer does not see it.

**The owner of the row does not matter.** A method's local declared by the
store of a callable merge holds its callable as a field of the root does.
Before, a held callable was looked for among the root's fields alone, and
the call of such a local was refused.

**The caller's binding decides at the call.** A method under the store calls
`h2`; the root calls that method after `int: h2 5`. The caller's `h2` is the
int there, and the call of the method is refused, `incompatible entry
signature`. The superseded callable is not called in its place. A number
field behaves the same way: the caller's current value is what the method
reads.

### Debt, labelled: HELD-FORWARD-LOOKUP

**Removed in [section 49](#no-forward-lookup):** the lookup is gone, and
`unit_held_call_above` with it.

A method that stands above every declaration of the name selects no row.
The kernel map, section 13.3, makes a parent declaration that precedes the
callee's definition eligible as its lexical fallback, and says nothing of
one that follows. For such a method the callable is still found by the
entry's last declaration of the name (`l2_mad_held`): a lookup of held
callables alone, beside the ordinary selection, kept because every earlier
translator answered so and programs run by it. `unit_held_call_above` holds
those programs (a call in an expression and a statement in the paren form);
it is no rule of visibility. The colon form under such a head, `h2: 5 6` in
a method above the declaration, is held by no row: an unknown head with
nothing established is the author's open question. The lookup goes when the
role of a call head that is a free name is decided
([defects](defects.md#held-forward-lookup)).

### The same decision at three more sites

Found by the probes of this slice; each was refused by every translator
measured, back to `fable_full_17`.

- **The value typer.** `r: h2(1 2)`, a held callable's call standing alone
  at the right of a store, was refused, `assignment value has unknown type`:
  the typer of a single value knew a method's call and a predefined
  function's, not a held callable's. It now gives the type of the header's
  result (`l2_mad_held_value_ty`), and a wrong target is refused as for any
  int.
- **The empty statement.** `p0()` under a nullary held callable was sent to
  the execution of a named Structure and refused, `executing a named
  Structure is not supported yet`. The test that sends an empty statement
  there (`l2_empty_struct_assign_shape`) asks the site's held callable, as
  it asks the site's formals.
- **The method's local**, above.

### Open, recorded

- **The bare name.** `p0` alone as a statement, for a nullary held callable,
  is refused the same way through another route (`l2_check_struct_call`).
  The semantics makes a bare name the nullary entry. A labelled probe holds
  the refusal ([defects](defects.md#held-bare-name-statement)). (Fixed in
  [section 49](#no-forward-lookup).)
- **The factory's actuals in the store are positional.**
  `h2: make2(n: 100)` is not read as the store: the shape asks an atom after
  the head. Every translator measured answers so; no row holds it
  ([defects](defects.md#held-store-factory-actuals-positional)).
- **An application of the storing shape that is valid cannot be written
  today.** It needs a callable formal that takes a callable-returning
  method, and a signature with such a formal is refused, `incompatible entry
  signature`. So the invalid later application is refused at translation
  and no program runs to show the callable unchanged. The control that does
  run is an application that fails at run time:
  `unit_held_call_failed_application`.

### The callers of the classifier that have no site

`l2_is_asgn(stmt, -1)` answers by the names of the unit's methods. Seven
places reach it, six through `l2_empty_call_shape`.

| Caller | Site at hand | What the answer decides | Finding |
| --- | --- | --- | --- |
| `l2_empty_struct_assign_shape` | yes | whether an empty statement executes a named Structure | A failing program was found, `p0()` above, and fixed: the function resolves the head at its site after the shape test. |
| `l2_reference_descriptor` | yes | an empty call shape given as a single reference value | The name is then resolved at the site (`l2_address_name`). No failing program known. |
| `l2_colon_bound_before` | yes | whether an earlier statement of the body declared the name | A declaration's shape. No failing program known. |
| `l2_ns_exec_scan` | no | which named Structures a body executes | A role, asked by name. No failing program known. |
| `l2_body_calls_name` | no | whether a body executes a given name | A role, asked by name. No failing program known. |
| `l2_colon_decl_room` | no | whether a node holds a declaring form | Shape only. |
| `l2_merge_atom_settle`, through `l2_merge_frame` | no | whether `x: merge a b` is a binding's statement | A role, asked by name. No failing program known. |

The shape tests still ask the method-name classifier where shape alone is
wanted, and three roles are still asked without a site. That stays a bounded
open audit; no code was changed for it beyond the one failing program.

### Replay

The slice's translator against the committed one (`af3b907e`), on the 1557
translations recorded by `fable_full_23`:

- Exit and messages are the same on every row, and so is the allocation
  count.
- The generated L1 is the same on 1111 of the 1141 rows that translate. On
  the other 30 it differs by the numbering of own rows alone. The roots-first
  order changes the global index of a root's assignment bind where a method's
  rows used to precede it, and that index appears in generated names
  (`l2_own<N>`, `l2_q<N>`) and in the texts `own field N`. For each of the 30
  files a one-to-one renumbering was found through its index lines
  (`# const: @(char l2_own<N>) "<name>"`), under which the two outputs are
  equal byte for byte. The positions of fields inside their Structures are
  not touched by that renumbering and are equal as they stand.
- The 30 rows: `graph_shape_t7_local_callable_field`,
  `graph_shape_t7_local_definition`, `unit_copy_call_chain_inputs`,
  `unit_held_nullary_source_field`, `unit_mres_ref_field_path`,
  `unit_named_actual_facts`, `unit_recv_use_nested_reader_refused`, each with
  its walked twin; the source and the target mutant of
  `unit_copy_call_chain_inputs`; `unit_capture_struct_call_arg`,
  `unit_capture_struct_own`, `unit_field_path_terminal_checklist`,
  `unit_merge_hidden_forward`, `unit_merge_hidden_input`,
  `unit_merge_hidden_position`, `unit_next_message_in_method`,
  `unit_receive_else_body`, `unit_recv_use_nested_dormant`,
  `unit_recv_use_nested_reader_refused_limit_probe`, `unit_struct_int_field`,
  `unit_throwing_callable`, `unit_walk_merge_hidden_input`,
  `unit_walk_receive_else_body`.
- The steps after the first (the selected row, any owner, the value type,
  the empty statement) each give the replay of the step before it on every
  row: they change only programs no recorded row holds.


### Rows

| Fixture | What it holds |
| --- | --- |
| `unit_held_call_reapplied_refused`, `unit_held_call_reapplied_method_refused` | `h2: make2 200` after the store, at the root and in a method: the application of h2, refused as that call. |
| `unit_store_callable_over_number_refused`, `..._over_local_refused`, `..._over_formal_refused` | The storing shape under a number field, local and formal of the name: a store to the number, refused. |
| `unit_held_call_failed_application`, natively and walked | An application by a statement whose first actual throws; the callable does not run, and is the stored one afterwards. |
| `unit_held_call_superseded`, natively and walked | `int: h2 5` after the store. The root calls h2 between the two, by its formals' names; a method between them calls it; a method below both reads the int and stores to it. |
| `unit_held_call_superseded_refused` | The call of h2 in a method below the superseding declaration: `unknown method`. |
| `unit_held_call_superseded_caller_refused` | A method under the store called from a site whose h2 is the int: refused at the call of the method. |
| `unit_held_call_block`, natively and walked; `unit_held_call_block_refused` | A callable held by a field of a nested body: called there; no binding after the body. |
| `unit_held_call_method_local`, natively and walked; `unit_held_call_other_method_refused` | A method's local holds a callable, one per activation and one per branch; another method does not see it. |
| `unit_held_call_formal_shadow_refused`; `unit_held_call_shadow` with a store to the formal | A number formal of the name hides the root's callable for a call and for a store. |
| `unit_held_call_assigned`, natively and walked; `unit_held_call_assigned_type_refused` | The call assigned alone, int and unsigned, at the root and in a method; an int result stored to a reference is refused. |
| `unit_held_call_nullary_statement`, natively and walked | `p0()` as a statement, at the root and in a method. |
| `unit_held_call_above`, natively and walked | The debt above: methods standing above the store. |
| `unit_held_call_bare_name_limit_probe` | The OPEN bare name: the refusal as it is today. |

### Mutants

Each is a copy of the slice's translator with one change, built apart, and
compared with the slice on its fixtures and those of section 47, natively
and walked.

| Mutant | What the fixtures say |
| --- | --- |
| The collector visits the other methods before the roots | `unit_held_call_statement` is refused, `more arguments than h2 has formals`; `unit_held_call_failed_application`, `unhandled throw: Oops`; `unit_held_call_nullary_statement`, `unknown method`; `unit_held_call_reapplied_method_refused` is accepted; `unit_held_call_above` translates and runs to 82. |
| The collector reserves a row for every statement of the storing shape | The two reapplied stores and the store over a number field are accepted; over a local and over a formal the refusal moves to the `return`. |
| Every pass takes the storing shape for the declaration | `callable result field was not reserved` for the reapplied stores and for those over a local and a formal. |
| The check alone intercepts by shape | `root operation not walkable yet` for the same five rows, or `unknown method` at the later call. |
| The classifier alone exempts by shape | The reapplied stores are refused in other words, `more arguments than h2 has formals`. |
| The graph alone, and the native emission alone, intercept by shape | Did not reach a witness: the same output on every fixture. No program the check accepts carries the storing shape under a bound head. |
| In a method the callable is the entry's last declaration of the name | `unit_held_call_superseded` is refused, `unknown method`; `unit_held_call_method_local` is refused. |
| The row is selected without the site | `unit_held_call_superseded` is refused at the root's call, `unknown method`. |
| A selected row of another kind does not block the callable | `unit_held_call_local_shadow_refused` is accepted; `unit_held_call_shadow` is refused, `h2 has no argument y`. |
| No lookup where the selection finds no row | `unit_held_call_above` is refused, `unknown method`. |
| A formal of the name does not block the callable | `unit_held_call_formal_shadow_refused` is accepted; `unit_held_call_shadow` is refused. |
| Only a field of the root holds a callable | `unit_held_call_method_local` is refused, `more arguments than h has formals`. |
| The typer of an assigned value does not know a held callable's call | `unit_held_call_assigned`, `unit_held_call_method_local` and the type refusal: `assignment value has unknown type`. |
| An empty statement under a held callable goes to the Structure route | `unit_held_call_nullary_statement` is refused, `executing a named Structure is not supported yet`. |


### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_11` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_11` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_24` (full harness) | RED 31 of 1584. Against `fable_full_23` (RED 31 of 1558): FAIL→OK 0; OK→FAIL 0; added 26, all green; removed 0; no red row's message changed. |
| `build/l2_harness/fable_role2_01` (focused, before the gate) | 197 rows: the 26 new ones, the 30 renumbered ones and the rows of held callables, callables, stores and named actuals. Red only five rows of the baseline. |

The 31 red rows are the 29 of `fable_full_17` and the two labelled OPEN
positives `unit_recv_use_nested_dormant` and `unit_recv_use_passed_thin`. Of
the 30 renumbered rows 29 ran green in the gate; the other is
`unit_recv_use_nested_dormant`, red before. The pre-gate hashes of the
translator, the 20 fixtures and the harness equal the live files and every
staged copy (`tie.py`).


**Next.** The receiving-use remainder with section 42's OPEN positives, then
whole-value composition, nested admission and the capture closure. Recorded
for the ordinary cleanup: the count tests of a held call below the binding,
after an inventory of their callers; the audit of the classifier's callers
above.

<a id="no-forward-lookup"></a>
## 49. No lookup ahead of the declaration; the bare name is the call (Codex, FABLE-CODEX-20261004-10)

**Codex's reply to the checkpoint of section 48.**

- Collecting the roots first and the renumbering are accepted. The index of
  an own row is a private symbol of the translator: nothing is executed at
  collection, the source order and the positions of fields are unchanged, and
  every generated reference is renumbered alike. The row that was red before
  is to be kept apart from "ran green".
- The three repairs of section 48 that were found on the way fit that slice.
- The refusal of the superseded caller is the established rule: "At the
  actual call, the caller's current same-name binding wins. An int cannot
  satisfy that callable use/contract. It is incompatibility, not absence
  permitting fallback to the old callable". Two controls are asked beside
  it: a compatible caller's override and the eligible lexical fallback.
- The second-store correction is accepted as a bounded fix.
- **The bare name and the named actuals of the factory block G5.** "Known p0
  and p0() denote the same nullary execution/discard route. A limit probe
  documenting the valid bare form's current refusal is not a replacement for
  its REQUIRED positive native/actually-walked witness."
- **The forward lookup is an implementation gap, not debt to keep.** "'Every
  earlier translator did it' is not justification for retaining the entry's
  last-declaration fallback. A site with incomplete/unresolved metadata must
  not secretly acquire a callable from that global answer." The paired forms
  go together: "The completed surface forms follow the SAME resolved head
  and receiving context; parentheses are not a call marker". "If no binding
  is established, apply the unknown-head/value-position rules; do not infer
  a hidden input just because a later/global factory has the same name."
- **The rule for a dormant definition by its name is rejected:** "no
  textual-name liveness heuristic". Resolved definition identity and the
  existing use and call facts decide; where consumption cannot be proven
  absent, the coverage stays unknown and the positive stays OPEN.
- Composing a whole pass from the callee's uses is right in principle.

### The forward lookup is removed

`l2_mad_held`, the lookup by the entry's last declaration of the name, is
deleted. `l2_call_head_held(mi, head)` is the shadows and then the row the
name selects at the site; a head that selects no row names no held callable,
and without a site there is none to select at.

A method that stands above every declaration of the name has no binding of
it. The head is an unknown head there:

- in a value position the call is refused, `unknown method`;
- the statements `h2(5 6)` and `h2: 7 8` are one form in two spellings: each
  defines a Structure of the method with the written contents, and neither
  calls the callable the root holds. The fixture's trace holds the root's own
  call alone.

Section 47 (`af3b907e`) had made both statements calls, by the lookup this
section removes; the translator before it defined the Structures, as now. No
read of the name follows in those methods, so this is the established case
of `unit_free_write` (`k: 1` defines a Structure though the caller has a
`k`), not the author's open question, which is about a later read.

Of the 1583 translations recorded by `fable_full_24`, only
`unit_held_call_above` and its walked twin change, to that refusal. Nothing
else depended on the lookup or on the answer without a site.

### The bare name is the call

A nullary held callable named alone as a statement is its call with no
actuals, on the route of `p0()`.

- The held-call routines take the call's body from its node
  (`l2_call_node_body`): a Frame's own, or none for the bare name. The check
  of a held call is one function for both (`l2_check_held_call`).
- The three statement routes ask the held callable of the site for a bare
  name where they ask a method: the check (`l2_check_discard`), the native
  emission (`l2_eval_discard`), the graph (`l2_rw_stmt_content`). A body
  whose only statement is that name is not inert (`l2_body_inert`).
- The placer needed nothing: a variant with a branch for it gives the same
  output on every fixture, so none was added.

A value position is unchanged: there the translator takes the bare name for
the callable's reference, at the root and in a method alike (`int: r p0` is
refused, `a reference where a number is asked`). **Corrected in
[section 50](#result-receipt-open):** that is what the translator does, not
the rule; where a result is received the callable executes, and the refusal
is an OPEN defect.

### The caller's binding: the two controls

`unit_held_call_caller_binding`. `mid` stands under the store and calls
`h2`. A caller that holds a callable of its own under the name is called
through (300 + 12). A caller with no binding of the name leaves the
declaration `mid` sees (100 + 12), as the root's own call does. Together
with `unit_held_call_superseded_caller_refused` (the caller's binding is an
int) the three rows tell the priority of sources from a ban on the method.
Both the committed translator and this one run the control; it is a new
witness, not a change.

### The named actuals of the factory: not implemented, a conflict of readings

Codex named `h2: make2(n: 100)` as the store with named actuals. That
spelling already has a meaning, by the author's ruling Q58 (2026-10-01): a
head that resolves to nothing, with a tail of one known call, declares a
named Structure that **retains** the call, which runs when the Structure is
executed. Two gated rows hold it, `unit_q58_batch_retained`
(`Batch: (put: 7)`) and `unit_named_struct_call_body_retained` (the block
form, whose header says: "one P0 shape, one resolution").

Measured:

- On the committed translator, after `h2: make2(n: 100)` the factory has
  not run; the bare `h2` then runs it once, with its named actual bound.
- Reading that tail as the call's value turns
  `unit_named_struct_call_body_retained` and `unit_named_actual_structure_body`
  (natively and walked) from OK to refused when only the compact spelling is
  read so, and `unit_q58_batch_retained` with its walked twin as well when
  any spelling is.
- The store is the short form of T6, `h2: make2 100`
  (`steps/callable-merge-t6.md`): the tail starts with the method's atom. A
  naming Frame in that tail, `h2: make2 n: 100`, and a parenthesized tail,
  `h2: make2 (n: 100)`, are refused, `unknown method` at `n`.

So the named actuals of a store have no accepted spelling today, and the one
Codex named is taken. The question which spelling carries them went back to
Codex with these anchors; nothing was implemented for it, and the defect
stays OPEN and blocks G5
([defects](defects.md#held-store-factory-actuals-positional)). Codex's
answer is in [section 50](#result-receipt-open): the spelling is withdrawn
and the question is the author's.

### Replay

The slice's translator against the committed one (`a96d43c3`), on the 1583
translations recorded by `fable_full_24`: exit, messages, generated L1 and
allocation counts are the same on 1580 rows. The three others are the rows
this slice replaces: `unit_held_call_above` and its walked twin, refused now,
and `unit_held_call_bare_name_limit_probe`, which translates now. Removing
the lookup alone changes only the first two; the bare name alone, only the
third.


### Rows

| Fixture | What it holds |
| --- | --- |
| `unit_held_call_above_refused` | A method above every declaration of the name calls it in a value position: `unknown method`. |
| `unit_held_call_above_unknown_head`, natively and walked | The paired statements `h2(5 6)` and `h2: 7 8` in such methods define Structures and call nothing. |
| `unit_held_call_caller_binding`, natively and walked | A compatible caller's own callable is called through; a caller without the name leaves the lexical declaration. |
| `unit_held_call_bare_name`, natively and walked | Bare `p0` and `p0()` at the root and in a method, and bare `p0` as the only statement of a nested body: five calls. |

Removed: `unit_held_call_above` with its walked twin (the lookup it held is
gone) and `unit_held_call_bare_name_limit_probe` (the positive replaces it).

### Mutants

Each is a copy of the slice's translator with one change, built apart, and
compared with the slice on its fixtures and those of sections 47 and 48,
natively and walked.

| Mutant | What the fixtures say |
| --- | --- |
| A head that selects no row falls back to the entry's last declaration | `unit_held_call_above_refused` is accepted; `unit_held_call_above_unknown_head` runs to 81, natively and walked. |
| The check does not take a held callable's bare name for its call | `unit_held_call_bare_name` is refused, `executing a named Structure is not supported yet`. |
| The native emission does not | It runs to 81 natively. |
| A body whose only statement is that bare name counts as inert | It runs to 81 with the methods walked. |
| The graph does not | It runs to 81 with the methods walked. |

A branch of the placer for the bare name was tried and dropped: with it and
without it the output is the same on every fixture.


### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_12` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_12` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_25` (full harness) | RED 31 of 1588. Against `fable_full_24` (RED 31 of 1584): FAIL→OK 0; OK→FAIL 0; added 7, all green; removed 3, the rows this slice replaces; no red row's message changed. |
| `build/l2_harness/fable_role3_01` (focused, before the gate) | 308 rows of held callables, callables, stores, named Structures and their execution, free and hidden names. Red only seven rows of the baseline. |

The 31 red rows are the 29 of `fable_full_17` and the two labelled OPEN
positives `unit_recv_use_nested_dormant` and `unit_recv_use_passed_thin`. The
pre-gate hashes of the translator, the four fixtures and the harness equal
the live files and every staged copy (`tie.py`).


**Next.** The spelling of a store with named actuals, when Codex answers.
Then the receiving-use remainder: the composition of a whole pass; the
dormant definition stays OPEN until resolved facts of use decide it. Then
whole-value composition, nested admission and the capture closure.

<a id="result-receipt-open"></a>
## 50. Codex's reply FABLE-CODEX-20261004-11: one question to the author, one correction

No gated byte changes with this section.

**The store of a factory's result is an open question of the author's.**
Codex accepts the Q58 evidence of section 49 and withdraws
`h2: make2(n: 100)` as the store: "Do NOT implement option (b), and do NOT
branch by compact flag or by 'returns a callable' to reverse Q58." The short
form too is not settled by its code and its old gates: "There is a real
unresolved boundary between the historical short factory-result binding and
the later general dormant named-body rule." Codex asked the author whether
`add5: makeAdder 5` keeps its meaning of binding the call's result, with
`add5: makeAdder n: 5` as its named form, or follows the definition of a
dormant named body with the result received explicitly. Until the author
answers, neither spelling of named actuals is implemented, Q58 and the rows
of the short form stay as they are, and the question stands in
[`LMX_blog/q/current/held-factory-initialization-versus-body-definition.md`](../LMX_blog/q/current/held-factory-initialization-versus-body-definition.md)
with the two author sources, the anchors, the P0 trees and what was
measured.

**Correction of section 49: a bare held name where a result is received.**
Section 49 said that in a value position the bare name of a held callable is
its reference. That is the translator's behaviour written as a rule. Codex:
"A known value-returning held callable is not universally reference-valued
merely because it is held." The semantics, `#callables`: "In argument
position the receiving contract selects a result or the reference itself: an
explicitly declared callable formal receives a reference to the callable
occurrence, not the result of executing it; when a result is received, a
value-returning callable is executed; a callable with no returned value,
including `sub`, is passed by reference."

So an int that receives known nullary `p0` gets what `p0()` gives: in
`r: p0` after `int: r`, in `return: p0` of an int method, and as the actual
of an int formal. Where the receiving contract asks for the occurrence, the
callable is not executed. The translator refuses the three receiving forms
today: `assignment value has incompatible type`, `return value has
incompatible type`, `a reference where a number is asked`. That is an OPEN
defect with a required positive, to be repaired
through the common decision of the receiving contract and the category of
the site, not by executing every reference
([defects](defects.md#held-bare-name-result-receipt)). Its red row comes
with the next gate.

**Also from that reply.** The removal of the forward lookup and the bare
statement are accepted as bounded changes. For the receiving-use remainder:
the facts of a definition's identity prove it unconsumed only as far as the
routes that set them are modelled, and an unmodelled route leaves the
coverage unknown; the flow of types prunes a source only where the
incompatibility is structurally proven, and a rejected store must not
delete the value the place held before it.

<a id="coverage-composed"></a>
## 51. The coverage composed across a call; the definition nothing consumes (Codex, FABLE-CODEX-20261004-11)

[Section 42](#receiving-use-follow-up) left two valid programs red:
`unit_recv_use_passed_thin`, where a reference is handed whole to a callee
that reads nothing through it, and `unit_recv_use_nested_dormant`, where a
definition inside the method reads through the reference and never runs.
Both are green with this slice. Three things changed in the translator, all
in the analysis of a typed reference's coverage and in the static flow that
uses it. The kernel and the walker are not touched.

### What Codex ruled

On the definition that does not run (reply -10 rejected a test by the
definition's name; reply -11, point 3):

> Replacing textual names with resolved definition identities is correct.
> But I cannot certify that three existing flags are an exhaustive
> escape/consumption proof merely from their names. Inventory what actually
> sets them: indirect/forwarded calls, qualified or ordinal paths,
> copied/merged hosts, reference/address/Array storage, whole-host transport
> and opaque receiving consumers. If a route is unmodeled, absence of a flag
> is UNKNOWN, not proof of no consumption.

On the composition and the flow (reply -11, point 4):

> Composing the resolved callee formal's uses into the source reference,
> keeping the same model/index spaces and ORDINAL/LAST distinct, is
> appropriate for the bounded slice. Preserve every visible alternative and
> further receiving use; propagate UNKNOWN when incomplete.
>
> Prune flow only for structurally PROVEN incompatibility under that precise
> coverage/contract, not for unknown source, unknown coverage or a
> conversion/admission whose result is still unknown. A failed store does
> not publish its candidate; the prior destination remains a possible value,
> especially on the handler path. Add a caught rejected store followed by
> consuming the old valid value to ensure pruning does not delete it or
> cause a false static callee refusal.

### The whole pass is composed

An own typed reference of a plain method, handed whole to a method as one
whole actual, takes on what the callee reads through that formal
(`l2_ruse_compose`). The reads go into the same list of entries as the
reads of the caller's own body: the same model as the index space, the same
level, row and half. The ordinal half and the last half stay apart.

The use is composed only when all of this holds:

- the head of the call selects a method at the site
  (`l2_call_head_method`), and not through a callable formal;
- the reference is one whole actual and the call gives every formal its
  actual; the place is read from the call's projected actuals
  (`l2_ruse_actual_index`), so a named actual is found at its formal;
- the callee is a plain method: no procedure of a named Structure, no host
  of a callable merge, no definition inside one, no method of a part;
- the formal receives by the same model as the reference;
- nothing else in the callee bears the formal's name, and no path in the
  program names it.

The callee's body is then read by the same scan (`l2_ruse_scan_method`).
What that scan cannot place in the callee leaves the caller's coverage
unknown, exactly as in the caller's own body: the formal returned, stored
or taken by address, or named inside a definition of the callee. A formal
handed on to another callee is composed in turn. A chain of calls that
comes back to a formal already being read adds nothing to that formal, so a
method that hands its formal to itself ends.

If a condition fails the use stays unclassified: the coverage is unknown and
the reception is full, as before.

A callee that reads nothing gives a coverage that is known and empty. That
is `unit_recv_use_passed_thin`.

### The definition nothing consumes

A definition inside the method that names the reference made the coverage
unknown. It still does, unless the definition is unconsumed
(`l2_ruse_unconsumed`), by the facts of its own identity that the check of
every body has established:

- no call edge leads to it from any method (`l2_m_edge`: a call by name or
  by a path, or through a callable formal's contract);
- it is no callable actual and no model of a merge (`l2_m_value_used`);
- no host returns it (`l2_mad_model`).

The inventory Codex asked for, measured on this translator with a reading
definition `read` inside `make`:

| Route to the definition | What the translator does |
| --- | --- |
| `make` calls it | A call edge. Consumed: `unit_recv_use_nested_called_refused`. |
| A definition beside it calls it, and `make` returns that one | A call edge from the sibling. Consumed: `unit_recv_use_nested_sibling_refused`. |
| `make` returns it | `l2_mad_model`. Consumed: `unit_recv_use_nested_reader_refused`. |
| `make` returns it on one branch and another definition on another | Refused, `assignment value has incompatible type`, at the return that differs from the method's last. |
| A path from outside, `make\read()` | Refused, `unknown field path segment`. Held by a tripwire row. |
| A copy of the method, `c: merge make` | Refused, `unknown merge operand`. Held by a tripwire row. |
| In `make`: a callable actual, the bare name where a value is received, the bare name as a statement, a comparison, the short store `q: read` | Refused, `a callable merge host names a nested method outside the return`. |
| In `make`: a reference declared to it, `@: k read` | Refused, `unknown type`. |
| A definition inside a method that returns no callable | Refused, `unsupported body`. |

So on this translator a definition inside a method is reached only by a
call in its host or beside it, or by the host's return, and the three facts
cover those routes. That is a property of what the translator accepts
today, not a rule of the language. The two outside routes are held by the
labelled rows `unit_recv_use_nested_path_reach_limit_probe` and
`unit_recv_use_nested_copy_reach_limit_probe`: a row that goes red means the
route opened, and the analysis must model it before the row changes.

A consumed definition that reads through the reference is still another
Consumer that this analysis does not compose: the coverage is unknown and
the reception full. That is a limit, held by the `..._limit_probe` rows of
the three consumed cases.

### The flow of types at a place of known coverage

The static flow of candidates (`l2_d105_receiving_flow`) passed every
candidate through a place of known coverage. With the composition that
gave a false refusal: in `unit_recv_use_passed_reads_refused` the reference
refuses the candidate at its declaration, the handler takes the throw, and
the call under it is never reached; the translator still carried the
candidate on to the callee's formal and refused the program, `implements is
false in function argument`.

Now a place of known coverage prunes a candidate by the fields its coverage
names at the root, each by the half it names, with the tests the full
reception already applied to every field: the candidate has no field of
that name at that occurrence, or the field there is provably of another
kind or model. A place of unknown coverage requires every field, as before.
Nothing else prunes: an unknown candidate layout, a coverage entry below
the root and a conversion are passed on as they were.

A pruned candidate is one the place refuses when it is reached, so it is no
value of the place afterwards. The value the place held before a refused
store stays: `unit_recv_use_rejected_store_keeps` holds a Wide, refuses a
store of an Other under a handler, and then hands the reference to a callee
that reads the Wide's value.

The comment above `l2_d105_receiving_flow` still describes the earlier
behaviour ("A place whose Consumer's coverage is known is not pruned
here"); the comment inside the function is the current one. The stale lines
go with the next change of the translator: the gated bytes are not edited
after their gate. (Corrected in [section 52](#result-receipt).)

### Replay

The slice's translator against the committed one (`3e7a2f28`), on the 1587
translations recorded by `fable_full_25`: exit, messages and allocation
counts are the same on every row. The generated L1 differs on 25 rows, of
two kinds, told apart by counting the reception calls and the coverage
arrays in each text.

- 19 rows gain a coverage where the reference had none, and their reception
  goes by coverage: `unit_recv_use_passed_thin`,
  `unit_recv_use_nested_dormant`, `unit_recv_use_unknown_refused` with its
  walked twin and its probe, `unit_named_actual_reference_whole` with its
  walked twin and its probe, `unit_named_actual_facts`,
  `unit_opaque_reference_ordinal_flow`, `unit_opaque_reference_source_chain`
  and `unit_colon_graph_update_admission_blocked`, each with its walked twin,
  `unit_pointer_raw_c_admission`, `unit_rhs_reference_admission`,
  `unit_rhs_returned_model`.
- 6 rows keep their coverage and lose one lookup of a field by name: the
  candidate the place refuses is no longer a possible source of the read
  under it. `unit_recv_use_selectors` with its walked twin,
  `unit_local_init_graph_ref_admit_refused`,
  `unit_rhs_returned_model_refused`,
  `unit_rhs_void_admission_assign_refused`,
  `unit_rhs_void_admission_init_refused`.

Every one of these rows keeps its verdict in the gate.

### Rows

| Fixture | What it holds |
| --- | --- |
| `unit_recv_use_passed_thin`, natively and walked | The callee reads nothing: the Other is received. Was the OPEN positive. |
| `unit_recv_use_nested_dormant`, natively and walked | The reading definition is neither called nor returned: the Other is received. Was the OPEN positive. |
| `unit_recv_use_passed_reads`, natively and walked | The routes of a callee's reads: directly, handed on, in a branch, handed to itself, by the formal's name. A Wide, which carries the field at another place and lacks the unread one, is received on each. |
| `unit_recv_use_passed_reads_refused`, natively and walked | The same routes with an Other: each reference refuses at its declaration, before the call, under a handler. |
| `unit_recv_use_rejected_store_keeps`, natively and walked | A refused store under a handler leaves the value held before; the later Consumer reads it. |
| `unit_recv_use_passed_refused`, natively and walked | `unit_recv_use_unknown_refused` renamed: the refusal is by the composed coverage now, and the row pins the reception by coverage. |
| `unit_recv_use_nested_called_refused`, `unit_recv_use_nested_sibling_refused`, natively and walked, each with its `_limit_probe` | A definition the host calls, or a sibling calls, is consumed: full reception, the Other refused. |
| `unit_recv_use_nested_path_reach_limit_probe`, `unit_recv_use_nested_copy_reach_limit_probe` | Tripwires of the two refused outside routes to a nested definition. |
| `unit_named_actual_reference_whole` | Pins the reception by coverage: the naming Frame is no store to the reference. |
| `unit_held_call_bare_name_result` | OPEN required positive of [section 50](#result-receipt-open): red. |

Removed: `unit_recv_use_unknown_refused_limit_probe` and
`unit_named_actual_reference_whole_limit_probe`. Their limit, a whole pass
that is not composed, is closed.

### Mutants

Each is a copy of the slice's translator with one change, built apart, and
compared with the slice on the fixtures of the family, natively and walked.

| Mutant | What the fixtures say |
| --- | --- |
| A whole pass is never composed | `unit_recv_use_passed_thin` and `unit_recv_use_passed_reads` are refused at run time: R0 stops. |
| A whole pass is classified without reading the callee | `unit_recv_use_passed_reads_refused`, `unit_recv_use_passed_refused` and `unit_recv_use_rejected_store_keeps` are refused by the translator, `implements is false in function argument`. |
| The flow does not prune at a place of known coverage | The same three rows are refused by the translator with the same words. |
| The flow prunes there by every field of the model | `unit_recv_use_passed_thin`, `unit_recv_use_passed_reads`, `unit_recv_use_selectors` and `unit_recv_use_later_consumer` fail, natively and walked. |
| The composition does not notice a formal already being read | `unit_recv_use_passed_reads` is refused at run time: R0 stops. |
| A definition the method calls counts as unconsumed | `unit_recv_use_nested_called_refused` aborts: "a captured Structure was not admitted as itself". |
| Only a call from the definition's own host counts | `unit_recv_use_nested_sibling_refused` fails with a walk error; the called and the dormant rows are as the slice's. |
| A definition its host returns counts as unconsumed | `unit_recv_use_nested_reader_refused` aborts: "a Structure capture could not be copied". |
| A definition formed into a value by a callable actual counts as unconsumed | Did not reach: no accepted program forms a nested definition so (the inventory above). The line stays as a guard without a witness. |

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_13` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_13` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_26` (full harness) | RED 30 of 1603. Against `fable_full_25` (RED 31 of 1588): FAIL→OK 2, the two former OPEN positives; OK→FAIL 0; added 19, of which 18 green and the labelled OPEN `unit_held_call_bare_name_result` red; removed 4, the renamed row with its walked twin and the two closed probes; no red row's message changed. |
| `build/l2_harness/fable_ruse_01` (focused, before the gate) | 239 rows of receptions, admissions, opaque and returned references, named actuals and captures. Red only two rows of the baseline and the new OPEN row. |

The 30 red rows are the 29 of `fable_full_17` and the labelled OPEN positive
`unit_held_call_bare_name_result`. The pre-gate hashes of the translator,
the eleven fixtures and the harness equal the live files and every staged
copy (`tie.py`).

**Next.** The bare name of a held callable where a result is received
([section 50](#result-receipt-open)), through the receiving contract of the
place. Then whole-value composition, nested admission and the capture
closure. The store of a factory's result waits for the author.

<a id="result-receipt"></a>
## 52. The bare name of a held callable where a number is received (Codex, FABLE-CODEX-20261004-11 and -12)

The OPEN positive of [section 50](#result-receipt-open) is green. The
kernel and the walker are not touched.

### The rule and the rulings

The semantics, `#callables`: "In argument position the receiving contract
selects a result or the reference itself: an explicitly declared callable
formal receives a reference to the callable occurrence, not the result of
executing it; when a result is received, a value-returning callable is
executed; a callable with no returned value, including `sub`, is passed by
reference."

Codex's reply -12 on the bounds of this slice:

> Implementation boundary for the whole-value slice: request the result
> under the ordinary receiving contract, then apply the ordinary conversion
> to it (e.g. int -> size_t). Do not require every input type to be numeric
> just because the requested result is numeric. Preserve the actual
> occurrence/self, dynamic and lexical inputs, defaults, effects and throws.
> A bare call has no explicit actuals, but ordinary input formation may
> still supply defaults/hidden inputs; do not replace that with an
> unconditional arity>0 refusal or an invented zero-input wrapper. Any valid
> route not supported in this bounded slice remains an OPEN positive, not a
> language prohibition.

### One decision, asked by the place

`l2_held_result_receive` is asked by a place whose receiving contract is a
number, about the whole value it is given. When that value is one bare name
that selects a held callable at the site (`l2_call_head_held`) and the
callable's header gives a number, the place receives what the call gives:
the call is checked by the check every held call has
(`l2_check_held_call`), and the value site, its P0 node, is recorded. A
place that receives a reference does not ask.

The places that ask:

- the common edge of a consumed value (`l2_check_value_convert_field`): a
  typed initializer, a number formal's actual, the value a number method
  returns, an Array element's initializer;
- a store (`l2_check_receiving_value`): to a field, a local, an element;
- the return's kind check (`l2_check_ret_kind`);
- a number field written through a path (`l2_check_path_write`);
- the graph's typed place (`l2_rw_texpr`): an own field's, a formal's, a
  message field's.

The readers of the record, four, each at the one value:

- the typer of one value (`l2_colon_simple_ty`) gives the header's result;
  every native typer of a value reads a leaf through it;
- the native emission (`l2_prep`) emits the call as `name()` is emitted;
- the graph's typer of an operand (`l2_rw_opty`) and the graph's operand
  (`l2_rw_operand`) do the same for the walked root and walked methods.

Nothing else is special. The place's conversion is the ordinary edge,
because the typer gives the result's type: an int result into a `size_t`
place calls the conversion's receiver, whose own formal receives the bare
name in its turn. The record is emptied with every translation of a unit.

A site that is recorded and whose callable is not selected when it is
emitted is an internal error in both emissions; no program reaches it.

### What the reference places keep

`unit_held_call_bare_name_occurrence`: an opaque reference declared with the
name, the actual of an opaque formal, a cast. The trace stays 0, the three
received the same occurrence, and it is not null. The committed translator
and this one both run it: it is a control, not a change.

### What is refused, and whose refusal it is

- A header whose formals have no defaults, named bare where a number is
  received: `a held callable takes the arguments of its header`, from the
  held call's own check. The call written `h2()` is refused earlier, by the
  binder: `h2 has no argument x`. Both say that required arguments are
  missing. This is not a rule that a held callable with formals cannot be
  named bare.
- Default values of formals: the spelling `(int: x 5)` is refused for every
  callable today, a unit method too, `incompatible entry signature`, at the
  header. So the formation of inputs from defaults cannot be shown with
  either spelling of a held call. It is a limit that stood before this
  slice; when a header can carry a default, the held call's check must form
  the inputs for the bare name and for `name()` alike.
- A header with a formal that is no number, `(Model: m) int`: the bare name
  is the call, and the call is refused by its own limit, as `hm(Model)` is:
  `a held callable whose header is not numbers to a number`.
- A definition that throws is not accepted as a callable merge today (`a
  callable merge needs a walkable body`), so the throw of a held call
  received by a bare name has no witness.

### OPEN after reply -12

**Operands.** Codex: "arithmetic and numeric ordering operands are
result-receiving places. This is the same receiving-contract rule as the
whole-value edge, not a special held-name rule." And for the equalities:
"For your p0, whose accepted header is () int, p0 = 0 and p0 != 0 compare
the returned int with numeric zero, just as the corresponding unit-method
expressions do. Do NOT choose occurrence/null comparison merely because the
callable is held in a reference or the other operand happens to be zero."
The translator refuses `p0 + 1` and `p0 < 500` today and compares the
occurrence in `p0 = 0`. Required positive, red:
`unit_held_call_bare_name_operand`, with a callable whose occurrence is not
null and whose result is 0, the short-circuit controls and the explicit
reference comparison
([defects](defects.md#held-bare-name-operand-result)).

**A held callable given to a callable formal.** Codex: "Record
HELD-CALLABLE-TO-CALLABLE-FORMAL as a REQUIRED positive OPEN defect,
separately from result receipt and blocking G5. An explicitly declared
callable formal receives the entire actual callable occurrence by
reference, without executing it on reception." The translator refuses
`run(p0)`, `incompatible entry signature`. Required positive, red:
`unit_held_call_to_callable_formal`
([defects](defects.md#held-callable-to-callable-formal)).

### Tried and dropped

A branch that counted a recorded site as a value that calls
(`l2_node_has_call`) changed nothing on any fixture: a whole value is
evaluated by the call path in every place of this slice. It is not in the
slice. It belongs to the operands, where a short-circuit reaches it.

### Replay

The slice's translator against the committed one (`cb7b1e03`), on the 1602
translations recorded by `fable_full_26`: exit, messages, generated L1 and
allocation counts are the same on 1601 rows. The one other is the OPEN row
itself, `unit_held_call_bare_name_result`, refused before and translated
now.

### Rows

| Fixture | What it holds |
| --- | --- |
| `unit_held_call_bare_name_result`, natively and walked | A store, an int formal's actual, an int method's return, and `p0()` beside them: four calls. Was the OPEN positive. |
| `unit_held_call_bare_name_places`, natively and walked | A local's initializer and store, a number field through a path, an element, a `size_t` initializer and a `size_t` field through a path with the conversion, a field's initializer at the root: eight calls. |
| `unit_held_call_bare_name_message` | A number field of a message: the exit code is the result. |
| `unit_held_call_bare_name_occurrence`, natively and walked | The reference places take the occurrence and call nothing. Its method holds machine operations and stays native under the knob; the root's receipts are walked. |
| `unit_held_call_bare_name_args_refused` | A header with two formals and no defaults, named bare at an int place: refused where the name stands. |
| `unit_held_call_bare_name_operand` | OPEN required positive: red. |
| `unit_held_call_to_callable_formal` | OPEN required positive: red. |

### Mutants

Each is a copy of the slice's translator with one change, built apart, and
compared with the slice on the fixtures of the family, natively and walked.

| Mutant | What the fixtures say |
| --- | --- |
| The common edge of a consumed value does not ask | `unit_held_call_bare_name_result` and `unit_held_call_bare_name_places` are refused by the translator. |
| A store does not ask | The same two are refused. |
| A store asks whatever it receives, a reference too | `unit_held_call_bare_name_occurrence` is refused by the translator. |
| The return's kind check does not ask | `unit_held_call_bare_name_result` is refused. |
| A write through a path does not ask | `unit_held_call_bare_name_places` is refused. |
| The graph's typed place does not ask | `unit_held_call_bare_name_message` is refused. |
| The graph's typed place asks whatever it receives | `unit_held_call_bare_name_occurrence` is refused. |
| The typer of one value does not read the record | `unit_held_call_bare_name_result` and `unit_held_call_bare_name_places` are refused. |
| The native emission does not read it | Natively `unit_held_call_bare_name_result` and `unit_held_call_bare_name_places` each fail one check; walked, both run. |
| The graph's typer does not read it | `unit_held_call_bare_name_result`, `unit_held_call_bare_name_places` and `unit_held_call_bare_name_message` are refused. |
| The graph's operand does not read it | The same three are refused. |

The two internal errors of a recorded site without its callable have no
witness: no program reaches them.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_14` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_14` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_27` (full harness) | RED 31 of 1612. Against `fable_full_26` (RED 30 of 1603): FAIL→OK 1, the former OPEN positive; OK→FAIL 0; added 9, of which 7 green and the two labelled OPEN positives red; removed 0; no red row's message changed. |
| `build/l2_harness/fable_hres_01` (focused, before the gate) | 106 rows of held callables, callable formals and conversions. Red only the two new OPEN rows. |

The 31 red rows are the 29 of `fable_full_17` and the two labelled OPEN
positives `unit_held_call_bare_name_operand` and
`unit_held_call_to_callable_formal`. The pre-gate hashes of the translator,
the seven fixtures and the harness equal the live files and every staged
copy (`tie.py`).

**Next.** The operands: arithmetic, orderings, equalities and conditions
receive the result of a held callable named bare, with the short-circuit
controls. Then the held callable given to a callable formal. Then
whole-value composition, nested admission and the capture closure. The
store of a factory's result waits for the author.

<a id="operand-receipt"></a>
## 53. The operands of an operation and the condition receive the result (Codex, FABLE-CODEX-20261004-12)

The first OPEN positive of [section 52](#result-receipt) is green, and a
native miscompilation of a group that calls, found by its witness, is
repaired. The kernel and the walker are not touched.

### The ruling

Codex's reply -12:

> Yes: arithmetic and numeric ordering operands are result-receiving places.
> This is the same receiving-contract rule as the whole-value edge, not a
> special held-name rule. A known value-returning nullary callable used
> there supplies its result, through the ordinary call and conversions.

> For your p0, whose accepted header is () int, p0 = 0 and p0 != 0 compare
> the returned int with numeric zero, just as the corresponding unit-method
> expressions do. Do NOT choose occurrence/null comparison merely because
> the callable is held in a reference or the other operand happens to be
> zero. Its physical storage cannot change the meaning of an otherwise
> equivalent callable expression.

> Reference/null comparison remains available under an explicitly
> reference-receiving contract: for example, the opaque reference value
> retained by @: void k p0 can be compared with null without calling p0.

### The same decision, more kinds of place

The decision of section 52 (`l2_held_result_receive`) takes a run of several
fields as an operation: the run is read as the typers read it, operands and
operators in turn (`l2_held_result_operands`), and each operand is a place
of its own that receives a number. The operand of a prefix sign is the
operand; a group is the expression its fields make, and a group of one
value is that value. An operand of several fields, a path, an address, an
indexed place, is no bare name and is left alone. So `@ p0` is not
reinterpreted.

Three places ask:

- the field check of every operation (`l2_check_value_kinds`), before it
  types the operation;
- a store's composite value (`l2_check_receiving_value`): the store is
  checked before its fields are, and it notes its conversion edge from the
  type the operation has;
- the check of a condition's one value: `if` and `while`, `for`, `until`.

The second was dropped once and came back. With it removed every fixture of
the day gave the same result, because none stored an operation into a place
of another number type. A probe that does went out without its conversion
edge: gcc, `'l2_out_throw' undeclared`. The gate that was running on that
text was stopped, and the probe is now the row
`unit_held_call_bare_name_operand_convert`.

The graph asks nothing more. Every operation and every condition is checked
before a graph is built, for the root as for a method, so the record is
complete when the graph reads it. Hooks of the same question in the graph's
conditions and in a path write's composite value were tried: with each
removed, every fixture gave the same result, the converting path write
included, so they are not in the slice.

The readers of the record are the four of section 52. The reader that
counts a recorded site as a value that calls was tried again and dropped
again: a run with a logical operator is always evaluated arm by arm, in a
group too (`l2_emit_fields` hands it to the lazy splitter), so a
short-circuit does not depend on it. With it and without it the generated
text is the same. Section 52 expected a short-circuit to reach it; it does
not.

### A group that calls lost its parentheses (NATIVE-GROUP-CALL-PARENTHESES)

Found by the witness of the group operand, and no matter of held callables.
In native code a group whose fields contain a call went out as the bare
text of its evaluation: `(u() + 1) * 2` was emitted as `l2_t1 + 1 * 2` and
gave 102 for u = 100. The walked graph gave 202. A group whose fields call
nothing was always written in parentheses. Now the group's text is in
parentheses on both routes (`l2_prep`). The committed translator has the
error for a unit method called or named bare and for a held call alike
([defects](defects.md#native-group-call-parentheses)).

### Found on the way: a held call from a nested definition (OPEN)

A probe of the conditions inside a definition that a method returns found a
defect that this slice neither makes nor repairs. A definition `g0` inside
`makeUse`, returned by it, calls another held callable, `p0()`:

- called from the root, the program is refused: `root operation not
  walkable yet: a caller's binding of a held callable's free name is of
  another type`;
- called from a method alone, the program is accepted and stops at run time,
  natively and walked: `lmx: invariant: a callable merge was called outside
  its header`.

The committed translator does the same with the call written `p0()`. With
this slice the bare name in such a definition, called from a method,
reaches the same stop. An accepted program that aborts is worse than a
refusal, so the
defect is OPEN with a required positive, red:
`unit_held_call_from_nested_definition`
([defects](defects.md#held-call-from-nested-definition)).

### A note on the witnesses

The factory's formal is named `n`, and the callables read it as a free
name. By the rule of the caller's binding (section 48) a caller's own `n`
is the callable's `n` at that call. A first draft of the operand witness had
a local `n` in the calling method: `p0 = z0` was then true, both callables
giving the caller's value. The witness names no local `n`.

### What stays as it was

- A held callable whose header gives no number is not received as a result
  anywhere: its bare name is the occurrence, in an operation too.
- The limits of section 52 stand: formals without defaults, default values,
  a header with a formal that is no number, a definition that throws.

### Replay

The slice's translator against the committed one (`471b145c`), on the 1611
translations recorded by `fable_full_27`: exit and messages are the same on
1610 rows, and the one other is the OPEN row, refused before and translated
now. The generated L1 differs on 66 more rows, in every one of them only by
added parentheses: the group repair. No row keeps more memory than before;
the allocation counts rise on most rows, because the field check now reads
the spans of each operation once more and frees them.

### Rows

| Fixture | What it holds |
| --- | --- |
| `unit_held_call_bare_name_operand`, natively and walked | Arithmetic, an ordering, equalities with a zero result and a non-null occurrence, two short-circuits, a short-circuit in a group, a prefix sign, a group, a group of one value, an operation in an actual, in a store, in a field through a path, in a returned value, a lazy group as an operand of arithmetic; an opaque reference compared without a call; the root's operations. Was the OPEN positive. |
| `unit_held_call_bare_name_condition`, natively and walked | The one value of `if`, of `while`, of `until` and of `for`, with callables that give 0 at chosen calls; each loop breaks after ten turns, so a reading by the occurrence fails and does not hang. |
| `unit_held_call_bare_name_message_operand` | An operation in a number field of a message. |
| `unit_held_call_bare_name_operand_convert`, natively and walked | An operation given to a place of another number type, where that conversion is the method's only one: a store, a field through a path, an initializer, and the bare name stored by itself. |
| `unit_group_call_parentheses`, natively and walked | A group that calls, on either side of the operator, with the method called and named bare, beside a group that calls nothing. |
| `unit_held_call_to_callable_formal` | OPEN required positive: red. |
| `unit_held_call_from_nested_definition` | OPEN required positive: red. |

### Mutants

Each is a copy of the slice's translator with one change, built apart, and
compared with the slice on the five new fixtures, natively and walked.

| Mutant | What the fixtures say |
| --- | --- |
| An operation's operands are never asked about | `unit_held_call_bare_name_operand`, `unit_held_call_bare_name_message_operand` and `unit_held_call_bare_name_operand_convert` are refused by the translator. |
| The field check's operation does not ask | The same three are refused. |
| A store's composite value does not ask | `unit_held_call_bare_name_operand_convert` does not compile: `'l2_out_throw' undeclared`. |
| The check of `if` and `while` conditions does not ask | `unit_held_call_bare_name_condition` fails with a walk error, natively and walked. |
| The check of a `for` condition does not ask | It fails one check natively and with a walk error walked. |
| The check of an `until` condition does not ask | The same. |
| The operand of a prefix sign is not an operand | `unit_held_call_bare_name_operand` is refused. |
| A group is not read | `unit_held_call_bare_name_operand` is refused. |
| A group that calls goes out without its parentheses | `unit_group_call_parentheses` fails one check natively. |

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_16` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_16` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_29` (full harness) | RED 31 of 1621. Against `fable_full_27` (RED 31 of 1612): FAIL→OK 1, the former OPEN positive; OK→FAIL 0; added 9, of which 8 green and the labelled OPEN `unit_held_call_from_nested_definition` red; removed 0; no red row's message changed. |
| `build/l2_harness/fable_oper_02` (focused, before the gate) | 140 rows of held callables, groups, callable formals, conversions and loops. Red only the two OPEN rows. |

The 31 red rows are the 29 of `fable_full_17` and the two labelled OPEN
positives `unit_held_call_to_callable_formal` and
`unit_held_call_from_nested_definition`. The pre-gate hashes of the translator, the six fixtures and the
harness equal the live files and every staged copy (`tie.py`).

A gate started earlier on a text without the store's question was stopped in
its kernel stage, when the probe of a converting store failed; its partial
directory `build/l2src/fable_kernel_15` is no evidence of anything.

**Next.** The held callable given to a callable formal
([defects](defects.md#held-callable-to-callable-formal)) and the held call
from a nested definition. Then whole-value composition, nested admission
and the capture closure. The store of a factory's result waits for the
author.

<a id="formal-free-names"></a>
## 54. A call through a callable formal forms the actual's free names from the contract's list (OPEN)

No gated byte changes with this section. It records a defect found while
reading the call path for the held callable given to a callable formal
([section 52](#result-receipt)). The defect needs no held callable.

```text
int: base 5
int: other 9
fn: f0 () int
    return: base
end: f0
fn: g1 () int
    return: other + 1
end: g1
fn: run (f0: q) int
    return: q()
end: run
int: r run(g1)
```

Measured on `69d3d9a5`, natively:

| Program | By the rules | The translator |
| --- | --- | --- |
| As written | 10: `run` has no `other`, the lexical source gives 9 | 6: `g1` received the value of `base` in the place of `other` |
| With `int: other 40` inside `run` | 41: the caller's binding | 6 |
| `run(f0)` with `int: base 40` inside `run` | 40 | 40 |
| An actual with two free names, the contract with one | its value | accepted; stops at run time, `a trampoline was called outside its method's signature` |
| An actual with no free name, the contract with one | its value | accepted; the same stop |
| A contract with no free name, an actual with one | its value | accepted; the same stop |

With the methods walked each of these is refused: `a callable result or a
callable formal is outside the walkable subset`.

What the generated code does: `run` takes the contract's free name as a
hidden input of its own and calls the occurrence with that one cell. The
actual is admitted by `l2_method_sig_compatible`: arity, result, throws and
the types of the declared formals. The free names of the actual are neither
compared nor formed.

The semantics, where it defines the complete signature: "`formed` the
inputs after the defaults of omitted formals, permitted conversions and the
ordinary sources of free names". The ordinary sources of a free name are
the caller's binding, then a permitted lexical source.
So the actual's own free names are to be formed, by name, where the call is
made.

`run` is translated once and does not know its actuals. Forming each
actual's free names by name needs a mechanism that the translator does not
have: the question is with Codex, with these measurements
(FABLE-CODEX-20261004-12, addendum). Until it is settled nothing in this
area is changed. The held callable given to a callable formal is one more
actual whose free names, the factory's captured formal, differ from the
contract's; it waits for the same mechanism
([defects](defects.md#callable-formal-free-names-by-contract)). Red rows for
the first two programs come with the next gate.

<a id="actual-inputs-ruling"></a>
## 55. Codex's replies -12 and the author's answer: the actual occurrence supplies its own inputs; no name table at run time

No translator byte changes with this section. Fixtures, harness rows and
records only.

**A duplicate record, folded.** The defect of [section 54](#formal-free-names)
was already in the ledger of defects as
[CALLABLE-FORMAL-HIDDEN-CONTRACT](defects.md#callable-formal-hidden-contract)
(Codex, 2026-10-01), traced in the source and never run, and it is item K04
of the plan. I recorded it a second time under a new name without searching
for it. The second entry is folded into the first, which now carries the
measurements; the anchor of the second is kept.

**The semantics, confirmed for every actual.** Codex, second reply:

> The ACTUAL selected occurrence supplies its own complete ordered
> explicit/hidden/default/result/throws/ABI contract. The callable formal's
> exemplar describes the Consumer's expectations; its hidden-input list is
> not the argument vector of an unrelated actual. Resolve the target once,
> form its actual inputs, perform the ordinary conversions/admission, then
> dispatch that same occurrence through its actual native word or retained
> body.

> For an actual free name, source priority is the caller's nearest current
> binding, then its already inherited dynamic input, then the actual
> occurrence's eligible lexical source.

> A missing required actual input is an ordinary call/admission refusal
> before entry, not an invariant abort. A present incompatible caller
> binding is not absence and must not silently fall back to the lexical
> value.

And what the repair must not be: "Do NOT repair l2_method_sig_compatible by
requiring identical hidden names/counts to the exemplar, or by accepting a
prefix and padding arbitrary missing cells."

**The mechanism: the author's answer.** The second reply left the mechanism
to the author's open question. The third and fourth replies carry his answer
of 2026-10-04. It is archived word for word in the
[journal of clarifications](../LMX_blog/2026-10-04.md#no-runtime-name-table),
and the question is answered and moved to
[`LMX_blog/q/`](../LMX_blog/q/graph-hidden-input-name-binding.md). The rule:
no name table at run time under any conditions; names serve translation and
`toLmx` only; the addresses of existing objects do not move.

What Codex draws from it, third reply: "Resolve source-level
identities/correspondences at translation. Runtime follows the resulting
physical references, selected declaration places and ordinary input
coordinates." No text lookup, no use of `lmx_source_names` for the binding
of a call, no registry of hashed names in its place, no METHOD record, Lmx
member, atom metadata or permanent auxiliary graph. A specialization made at
translation is allowed where it is proved; the enumeration of every future
actual is not to become a requirement of the language, and an unknown
provenance is not an incompatibility. "If today's retained graph/ABI has
lost the ordinary references needed for this, that is the
representation/formation defect to fix." Fourth reply: "Identify where
that existing resolved relation is lost or ignored and repair that path."

The normative texts are synchronized in both languages: sections 1 and 4 of
the semantics (through the book), L2 section 2.1, `CORE_L2_L3_v2.md`,
`L2_L3_CODING_INSTRUCTION.md`, `to_fable.md` and the plan. They forbade
execution through the table before. What changes: the table is said to serve
translation and `toLmx` only, and the formation of a call's inputs is named
among the things that never consult it.

**Where the resolved relation is lost.** Lines on `69d3d9a5`.

- The relation exists for a callee the translator knows. `l2_hidden_from`
  (:26333) chooses the source of hidden input `k` of `callee` in caller
  `mi`: the caller's formal or inherited input of that name, the caller's
  own field of that name it uses, then the declaration in the callee's
  lexical context. A Structure is reached through the parent of the selected
  occurrence, `l2_c<self>\parent` (:26374). A number's cell is reached as a
  field place from the caller's own containing Structures
  (`l2_own_from_expr`, :11419), not through the occurrence. The name is
  resolved at translation; run time gets an address or a value.
- A call through a callable formal ignores it. `l2_emit_call` (:27958) takes
  the counts of declared and hidden inputs from the method that declares the
  formal (:28014, :28015) and asks `l2_hidden_from` about that method
  (:28114). The actual's list never enters the call.
- The actual's trampoline checks the count alone (:29209) and reads every
  cell it is given.
- The actual occurrence does carry its inputs physically: the argument part
  of its signature holds a cell per declared formal and per through-name
  (`l2_emit_parts`, :43400 and :43428).
- A walked body already reads the lexical source of an absent hidden input
  through `node` (`l2_rw_arg_fb`, :34271; `l2_mad_inputs`, :38827). A native
  trampoline has no such reading.

How the call through a formal is to learn which actual it holds is not
decided here. The design goes to Codex under the same ID before any
translator byte changes.

**The nested definition.** Codex, second reply: "HELD-CALL-FROM-NESTED-DEFINITION is
G5-blocking. Keep it a REQUIRED positive and cover both root and method
callers, native and genuinely walked." It belongs to the same dependency,
the formation of an actual call's inputs and the capture closure (K04), and
is not to be repaired by an environment special to held callables: "A
captured callable is an ordinary nonprimitive reference; the
source-faithful copied occurrence and necessary lexical dependencies must
survive composition. At invocation the ordinary caller-source priority
still applies. Copying lexical data does not freeze a free name against a
later caller override."

Measured beside it on `69d3d9a5`, with a definition `g0` returned by its
method:

| Free name of `g0` | From a method that does not name it |
| --- | --- |
| A number of the unit, `base` | Read at the call: 5 + 5, and 5 + 7 after `base: 7` |
| A Structure of the unit read by a path, `m\v` | Accepted; `walk error: INVALID` |
| A held callable, `p0()` | Accepted; `a callable merge was called outside its header` |
| The same held callable, when the calling method names `p0` itself | 105 |

So the formation of a held call's free names has the caller's own binding
for every kind of value and a lexical fallback for numbers alone.

**Rows.** All are required positives; none may become an expected failure.

| Fixture | Now |
| --- | --- |
| `unit_callable_formal_free_names_other` | red: 6 where the rules give 10 |
| `unit_callable_formal_free_names_override` | red: 6 where the rules give 41 |
| `unit_callable_formal_free_names_extra` | red: accepted, stops at run time |
| `unit_callable_formal_free_names_none` | red: accepted, stops at run time |
| `unit_callable_formal_free_names_forward` | red: 6 through a forwarded formal |
| `unit_callable_formal_free_names_self` | green: the actual is the declaring method; lexical 5, caller's 40 |
| `unit_callable_formal_free_names_self_walk` | red: a callable formal is outside the walkable subset; debt of the implementation |
| `unit_held_call_from_nested_definition_root`, natively and walked | red: refused |
| `unit_held_call_from_nested_definition_method`, natively and walked | red: accepted, stops at run time |

`unit_held_call_from_nested_definition` of section 53 is replaced by the two
rows by caller.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2_harness/fable_full_30` (full harness) | RED 40 of 1631. Against `fable_full_29` (RED 31 of 1621): FAIL→OK 0; OK→FAIL 0; added 11, of which `unit_callable_formal_free_names_self` green and ten labelled OPEN positives red; removed 1, the red `unit_held_call_from_nested_definition` the two rows by caller replace; no red row's message changed. |
| Kernel and L3 | Not run again: the translator is the bytes of `fable_kernel_16` and `fable_l3_16`, verified by hash before the run. |

The 40 red rows are the 29 of `fable_full_17` and eleven labelled OPEN
positives: `unit_held_call_to_callable_formal`, the four rows of the nested
definition by caller, and six of the callable formal's free names. The
pre-gate hashes of the translator, the eight fixtures and the harness equal
the live files and every staged copy (`tie.py`).

**Next.** The design of the common formation of an actual call's inputs from
references resolved at translation, for Codex. Then the bounded step Codex
allowed: references among the free names of a definition its method returns,
as far as their source and contract are proven by existing graph references;
the capture closure (`unit_capture_struct_whole`,
`unit_capture_struct_merge_two`); whole-value composition and nested
admission. No adapter special to a formal or to a held callable, and no
names at run time.

<a id="nested-references"></a>
## 56. A reference among the free names of a definition its method returns; Codex's review of the design

### The bounded step

Codex allowed this step before the common route (second reply -12): "The
immediate scalar/named-Structure-only preparation gap may be repaired as a
bounded step of that common dependency if its actual source and contract
are proven using existing physical graph references."

A hidden input of a definition its method returns may be left absent by the
caller. For a number the definition then read its lexical source: its `ARG`
carries a fallback, a name of the host's body read through `node`, else the
declaration of the unit field (`l2_rw_arg_fb`). For a reference it had no
such reading. Three places change, in `dev/l2src_sandbox/l2trans.lm1`:

| Place | Before | Now |
| --- | --- | --- |
| `l2_rw_mad_call`: the held callable a walked body calls is its hidden input | plain `ARG`: absent, the call stopped, `a callable merge was called outside its header` | `ARG` with the fallback |
| `l2_rw_path_value`: the root of a path is a hidden input | plain `ARG`: absent, `walk error: INVALID` | `ARG` with the fallback |
| `l2_rw_held_binding`: a walked caller's own row under the free name | a number only; a reference was refused as "of another type" | a reference too, when it is the very declaration the definition's lexical source names |

The third row is narrow on purpose. The caller's own reference of another
declaration is another value, and whether it fits the definition's use is
decided by the ordinary admission, which this path does not have. It is
refused where it stands with words of its own: `a caller's own reference
under a held callable's free name is not admitted to its use yet`. That is
a limit of the implementation and no rule
([HELD-FREE-REFERENCE-OTHER-DECLARATION](defects.md#held-free-reference-other-declaration)).

Measured on the committed translator and on this one, natively and with the
methods walked (the same in both):

| Program | Before | Now |
| --- | --- | --- |
| A held callable called from a returned definition, from a method that names it nowhere | stops at run time | 105 |
| The same from the root | refused | 105 |
| A held callable with an argument; two in one expression | stops; refused from the root | 12; 135 |
| Two levels of returned definitions; the held callable named bare | stops | 106; 208 |
| A Structure of the unit read by a path, from a method | `walk error: INVALID` | 9; 35 after `m\v: 30` |
| The same from the root | refused | 9; 35 |
| A number, the caller's own first | 55, 10, 12 | the same |
| The caller's own Structure with no field the definition reads | refused | refused |
| The caller's own Structure of the same type, another declaration | refused | refused: OPEN |

Two things measured and left: a local `p0: make0 200` in a method of a unit
that has `p0` is an application of that `p0`, so it is refused as a call
with too many arguments, by the rule of the bound name; and a pointer read
through `\pp` in such a definition is an `unresolved name` before and
after.

### Replay

The step's translator against the committed one (`0840b44c`), on the 1630
translations recorded by `fable_full_30`: exit, messages and the generated
L1 are the same on 1626 rows. The four others are the rows of the held call
by caller: the two from the root were refused and translate now, the two
from a method change their L1.

### Mutants

Each is a copy of the step's translator with one change, built apart and run
on the eight fixtures, natively and walked. The two modes agree in every
cell.

| Mutant | What the fixtures say |
| --- | --- |
| The held callable a walked body calls keeps the plain `ARG` | `unit_held_call_from_nested_definition_method`, `_args` and `_chain` stop at run time: `a callable merge was called outside its header`. |
| A path root keeps the plain `ARG` | `unit_nested_definition_structure_path` fails with `walk error: INVALID`. |
| A caller's own reference is refused as before | `unit_held_call_from_nested_definition_root`, `_args`, `_chain` and `unit_nested_definition_structure_path` are refused by the translator. |
| A caller's own reference of any declaration is supplied | `unit_nested_definition_structure_other_refused` translates and gives 6: the definition read another field of the caller's Structure in the place of `v`. |

Under the last mutant the OPEN row `unit_nested_definition_structure_override`
gives its 45. So what that row lacks is the admission and nothing else.

### Codex's review of the design (fifth reply -12)

The design of [section 55](#actual-inputs-ruling) went to Codex as items a
to g. The review keeps the direction and corrects five things.

1. No last branch through the declaring method's list. "An unmodeled actual must NEVER be called using the exemplar's
hidden-input vector." Where the formation cannot yet be produced the valid
program stays an OPEN required positive with a located limit. And all
inputs absent is not the universal route: "Absence is correct only
when the caller really supplies no available binding."
2. Propagation. I had read "already inherited" as a ban on new inheritance.
Codex: ""Already inherited dynamic input" describes SOURCE PRIORITY at
execution. It does not forbid the translator from propagating statically
known requirements." Once the translator knows that an actual reaches a
formal, the actual's free names enter the ordinary fixed point; the
declaring method's names do not stay as an artificial requirement; and no
caller is asked for the names of a candidate it does not pass. The chain
witness: an outer caller has `other` 40 as its own formal, `run` has none,
`run` calls `g1` through `q`: 41.
3. Identity is exact. An address comparison is valid only for the very
occurrence supplied at the call; "Do not compare native words, input
widths or positional type witnesses as proxies for occurrence identity."
An incomplete flow is UNKNOWN, never a closed set.
4. `l2_hidden_from` is a starting point. Its fallback for a number reaches
the cell from the caller's own containing Structures (`l2_own_from_expr`),
not from the selected occurrence. The cell must be in the actual
occurrence's lexical tree.
5. One formation for plain, forwarded and held actuals, every kind of value
and both engines.

### The design, corrected

- **What the translator proves.** Which methods reach each callable formal:
  a source where an actual names a unit method, an edge where a formal is
  handed on, and, for a callee that is itself the value of a formal, the
  actual goes to that formal of every method that reaches it. A merge built
  as an actual, a held callable and a library entry are not followed yet:
  such a formal is UNKNOWN.
- **Measured: which occurrences exist.** A callable field of a named
  Structure names a unit method and shares its one occurrence (`a callable
  field needs a method name` otherwise); the unit is not copied. So the only
  occurrences of a method other than the unit's own are the nodes a merge
  builds: held callables and merge actuals. Those carry their copied lexical
  context and are called with absent inputs falling back through `node`.
- **First slice: formation classes, no identity test.** Where every method
  that reaches a formal forms its inputs alike (the same free names, types
  and lexical declarations), the call through the formal forms that list
  with the existing `l2_hidden_from`, the selected occurrence as its callee.
  Nothing is compared at run time, so no claim about identity is made.
  Where the methods differ, or the formal is UNKNOWN, the call is refused
  where it stands with a limit of the implementation, and the valid program
  stays a red required positive. The declaring method's list is used by no
  path.
- **Propagation.** At the call through the formal the fixed point of
  dynamic inputs (`l2_dyn_site`) takes the reaching methods in the place of
  the declaring method. The consumer inherits what they need and it does
  not bind; its callers supply it by the ordinary rule.
- **The lexical fallback** of a number is emitted through the parent of the
  selected occurrence, as a Structure's already is.
- **Second slice.** Methods that form their inputs differently and reach
  one formal: a branch per exact occurrence, and an inherited input that
  only some of them need. That input must be able to be absent in the
  consumer's activation. Today a hidden input of a native method is a
  machine argument by value with no absent state; absence exists only as an
  empty entry of `refs` at `lmx_call_prim`, which a walked body's `ARG`
  reads through its fallback. The plan is to keep such an input as that
  entry, with no new record.
- **Then** the same formation for held callables and merge nodes as actuals
  and as callees (the admission the limit above waits for), and the walked
  consumer.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_17` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_17` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units 76/128 names, 1082/8192 bytes. |
| `build/l2_harness/fable_full_31` (full harness) | RED 38 of 1642. Against `fable_full_30` (RED 40 of 1631): FAIL→OK 4, the held call by caller, natively and walked; OK→FAIL 0; added 11, of which 9 green and the two labelled OPEN rows of the caller's own Structure red; removed 0; no red row's message changed. |
| `build/l2_harness/fable_nest_01` (focused, before the gates) | 120 rows of nested definitions, held calls, captures, merges and callable formals. Red only baseline and labelled OPEN rows. |

The 38 red rows are the 29 of `fable_full_17` and nine labelled OPEN
positives: `unit_held_call_to_callable_formal`, six of the callable formal's
free names and the two of the caller's own Structure. The pre-gate hashes of
the translator, the eight fixtures and the harness equal the live files and
every staged copy (`tie.py`).

**Next.** The first slice of the common route, with the chain witness, the
controls and the mutants; then the second.

<a id="formal-formation"></a>
## 57. A call through a callable formal forms the inputs of the methods that reach the formal (first slice)

### Codex's sixth reply -12

It answers the corrected design of [section 56](#nested-references).

- The transport of the second slice is confirmed: "YES: keeping a
  forward-only inherited input as the existing refs entry, possibly absent,
  during this synchronous activation is the intended ordinary activation/ABI
  transport." With its conditions: absence is preserved across
  consumers that only forward; a present zero or boxed null is not absent; a
  consumer that reads or assigns the name itself uses the ordinary
  working-input rule; a box of the activation is never a persistent cell.
- The first slice is accepted "as the stated bounded optimization: only
  proven reaching actuals whose FULL formation is the same, target evaluated
  once, actual-relative physical sources, ordinary fixed-point propagation,
  and no exemplar fallback." Its boundary is to be recorded "as
  implementation coverage, never a language restriction."
- One correction, taken before any byte was written: ""no flow reaches
  the formal" does not itself authorize an X1 invariant. An unused definition
  can legitimately contain q() even when no current call supplies q." So
  a dormant definition is neither refused nor given an abort.
- The limit of the caller's own reference stays
  ([section 56](#nested-references)): "do not remove that limit guard
  merely to obtain 45 while a missing-field candidate reads 6."

### What changed

All in `dev/l2src_sandbox/l2trans.lm1`.

| Step | Where | What |
| --- | --- | --- |
| Facts | `l2_check_call`, where an actual meets a callable formal (`l2_cfl_note`) | The formal receives a named unit method, the caller's own formal handed on, or an occurrence not followed (a merge built as the actual). The callee is a method, or the value of a formal. |
| Closure | `l2_cfl_close`, at the head of `l2_dyn_close` | Which methods reach each formal of each consumer; an unfollowed occurrence reaches as such. Finite; repeated whenever the fixed point is. |
| Propagation | `l2_dyn_site` | At a call through a formal the reaching methods stand in the place of the declaring method. The consumer inherits what they need and it does not bind. The declaring method's names are asked of no one. |
| Formation | `l2_cfl_formation`, in `l2_emit_call` and `l2_rw_call` | The call forms the list of the reaching methods through the existing `l2_hidden_from`, the selected occurrence as its callee. |
| Dormant | the same | No flow reaches the formal: the call forms no hidden input, asks nothing and is not refused. |
| Limits | the same | Methods whose inputs are formed differently, an unfollowed occurrence, a library unit: refused where the call stands. |
| Lexical cell | `l2_hidden_from` | A number's cell in the unit is reached through the parent of the selected occurrence of a unit method, as a Structure's was. |

Nothing is compared at run time in this slice, so no claim about the
identity of an occurrence is made. Methods form their inputs alike when
their free names, in order, their types, their lexical declarations and
their receiving schemas are the same; their declared formals, result and
exits are those of the one contract each was admitted to.

The tables are compiler metadata. Nothing of them exists at run time: no
name, no table, no record.

### Measured

On the committed translator (`375b6309`) and on this one, natively.

| Program | Before | Now |
| --- | --- | --- |
| `run(g1)`, `g1` reads `other`, the formal is declared by `f0` | 6 | 10 |
| The same with `int: other 40` in `run` | 6 | 41 |
| An actual with two free names; with none; a formal declared without any | stops at run time | their values |
| A formal handed on | 6 | 10 |
| `outer (int: other)` calls `run(g1)`, 40 given | a wrong value | 41 |
| The same with one more method between them | a wrong value | 41 |
| Mutual recursion handing the callable on; `pong` has its own `other` 70 | wrong values | 10, 71, 71, 71 |
| The callee is the value of a formal (`apply2 (run: h; f0: q)`: `h(q)`) | wrong values | 10, and 41 from `outer` |
| `int: other 0` in `run`; 0 given to `outer` | wrong values | 1; 1 |
| A free name no one supplies and the unit does not declare | accepted; 6 | refused before entry: `unbound dynamic input zz` |
| A consumer no call supplies | translates | translates |
| One formal receives `g1` and `f0` | wrong values | refused: OPEN |
| One formal receives two callables with one name, declared twice in the unit | 2 and 2 | refused: OPEN |
| A library unit with a callable formal | translates | refused: OPEN |

The last three are the cost of the slice's boundary. The second of them
translated and gave the right values before; no row of the harness had that
shape. Each is a red required positive now.

### What is not built

Coverage of the implementation, no restriction of the language.

- **Inputs formed differently on one formal.** A branch per exact occurrence
  and an inherited input that may be absent: the second slice.
- **The lexical fallback at the top of a chain.** Where no caller up the
  chain binds the name, the cell read is the one the called method's lexical
  lookup names. For a unit method that is the actual's own cell. For an
  occurrence with a lexical context of its own, a node a merge builds, the
  absence has to travel to the actual: the second and third slices. That is
  why two callables whose lexical declarations differ are refused on one
  formal now.
- **Occurrences not followed.** A merge built as the actual
  (`unit_t7_convert`, a baseline red row, now fails at the call through the
  formal, 17:13, with the limit; before it failed at 20:19 in the walk) and
  every caller of a library unit.
- **A held callable as the actual**, with the copied lexical values Codex's
  witnesses ask for; **the walked consumer**; **the caller's own reference of
  another declaration**.

### Replay

The slice's translator against the committed one (`375b6309`), on the 1641
translations recorded by `fable_full_31`: exit, messages and the generated
L1 are the same on 1630 rows. The eleven others:

- five rows of the callable formal's free names, whose L1 changes: the
  consumer's hidden input is the actual's name, and its callers supply that;
- five rows whose root reads a unit cell for a callee in its native code,
  now through the parent of the selected occurrence: `unit_decl_order_u2`,
  `unit_walk_decl_order_u2`, `unit_held_call_guarded`,
  `unit_walk_held_call_guarded`, `unit_site_parent_fallback`. One expression
  changes in each; the cell is the same;
- `unit_t7_convert`, a baseline red row, refused with another message.

### Mutants

Each is a copy of the slice's translator with one change, built apart and run
natively on the fourteen fixtures of the callable formal.

| Mutant | What the fixtures say |
| --- | --- |
| A unit method named as the actual is not recorded | Every row that calls through a formal stops at run time: `a trampoline was called outside its method's signature`. |
| A formal handed on is not recorded | `_forward`, `_higher` and `_mutual` stop at run time the same way. |
| A callee that is a formal's value does not pass its actual on | `_higher` stops at run time. |
| The fixed point keeps the declaring method | `_chain`, `_higher`, `_mutual` and `_zero` give wrong values. |
| The emitted call keeps the declaring method's list | Nine rows give wrong values or stop at run time. |
| The formations of the reaching methods are not compared | The OPEN row `_differ` translates and gives wrong values in place of the located limit; `_lexical_differ` translates and gives its 2 and 2. |
| The lexical declarations are not compared | `_lexical_differ` translates and gives its 2 and 2. |
| A library unit's formals are taken as followed | `unit_lib_callable_formal` translates. |
| The number's cell keeps the caller's route | No value changes. The generated text of `unit_decl_order_u2` has the old expression twice and the new one nowhere: the row's two pins fail. |
| A merge built as the actual is not recorded as unfollowed | No row changes its verdict. `unit_t7_convert` is red either way: with the fact it is refused at the call through the formal (17:13), without it at the walk of the merge (20:19). |

Three of these are not kills by a value, and are said as they are. The
comparison of lexical declarations refuses a program that this slice would
run right, since the root binds the name; no program was constructed in
which that comparison prevents a wrong value. It stays because the
formation's lexical source is not yet the actual's own in every chain, and
goes with the second slice. The cell's route is the same cell today: nothing
copies the unit, so the pins are of the text only. And the fact of an
unfollowed merge cannot be reached by a running program: a merge built as
an actual does not translate at all yet.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_18` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_18` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_32` (full harness) | RED 36 of 1651. Against `fable_full_31` (RED 38 of 1642): FAIL→OK 5, the callable formal's free names; OK→FAIL 0; added 9, of which 6 green and three labelled OPEN rows red; removed 0. |
| `build/l2_harness/fable_cfl_01` (focused, before the gates) | 152 rows of callable formals, hidden inputs, held calls and library units. Red only baseline and labelled OPEN rows. |

The 36 red rows are the 29 of `fable_full_17` and seven labelled OPEN
positives: `unit_held_call_to_callable_formal`,
`unit_callable_formal_free_names_self_walk`, `_differ`, `_lexical_differ`,
`unit_lib_callable_formal` and the two of the caller's own Structure. The
pre-gate hashes of the translator, the sixteen fixtures and the harness
equal the live files and every staged copy (`tie.py`).

**Next.** The second slice: an inherited input kept as its entry of `refs`,
possibly absent, through a consumer that only forwards it; the native entry
reading its lexical source for an absent input as the walked body does; a
branch per exact occurrence where formations differ. With Codex's five
transport witnesses. Then held callables and merge nodes as actuals and the
common admission.

<a id="absent-input"></a>
## 58. An input no caller binds travels absent to the method that reads it (second slice, part one)

### Codex's seventh reply -12

It reviews `5afcb650`, the disclosures of [section 57](#formal-formation)
and the plan of the second slice.

- "Proceed with S2a then S2b on the existing ABI." No new decision
  of the author is needed.
- The native fallback: "An absent hidden input that the selected actual
  READS is resolved by that actual's eligible lexical path from its own
  occurrence. A forwarding-only Consumer keeps it absent and does not eagerly
  read its own lexical source. If the Consumer itself reads or changes that
  input, its resulting current working value is supplied downstream
  normally." And: "Present zero/null and present-but-incompatible
  are not absence."
- The comparison of lexical declarations of the first slice is "a
  conservative proof boundary, not a language restriction"; it is to go
  "when the actual-entry fallback makes it unnecessary". The row it
  refused stays a required positive, and the refusal is to be disclosed:
  ""OK->FAIL 0" is only a statement about the previous harness rows, not
  absence of all newly discovered regressions."
- The library: "Do not make library mode itself a semantic exception."
  And: "If the currently exposed library ABI makes every such formal
  externally reachable, document that concrete boundary and mark those
  entries UNKNOWN."
- No flow: "No flow is not a zero-hidden-input contract for a future
  actual and not permission to dispatch it through the exemplar."
- The branch of the next part: "Use address comparisons only for
  identities actually proved by the flow and the supplied/current unit
  reference, with target evaluated once." Copies, held nodes and foreign
  unit references stay open positives until built.
- The mutants: "Do not weaken guards simply to manufacture a killed
  mutant."
- The order: "native absent-input reading -> forwarding-presence transport
  and per-actual formation -> known differing alternatives -> held/merge
  actuals and walked consumer".

### The regression of the first slice

The first slice refused `unit_callable_formal_free_names_lexical_differ`, a
program the translator before it (`375b6309`) ran right: 2 and 2. It was
reported to Codex with that slice. The gate's figure "OK→FAIL 0" could not
show it: no row of the earlier harness had the shape. This slice removes the
comparison that refused it, and the row is green again, natively. The
fixture's own comment still calls it an open positive; it is corrected with
the next gated change, since the bytes the gate ran are the bytes committed.

### What changed

All in `dev/l2src_sandbox/l2trans.lm1`. The interface of a call is the one
that was: `refs[k] = 0` is an absent input, a nonzero entry that holds zero
is a present zero.

| Step | Where | What |
| --- | --- | --- |
| Who reads | `l2_dyn_reads`, `l2_dyn_fwd` | A number among a method's hidden inputs is forward-only when no statement of the method's body or return trailer reads or assigns its name: the method has it only because something it calls needs it. |
| Who takes an absent entry | `l2_hid_own_lex`, `l2_hid_takes_absent` | A method that only forwards the number; and a method of the unit that reads a number whose lexical declaration is a field of the unit. |
| The caller | `l2_hidden_from`, `l2_emit_hidden_ref` | A caller with no binding of the name hands the entry absent where the callee takes it. A caller that only forwards its own input hands its entry on as it is (`l2_hidden_forward`). |
| The typed body | `l2_emit_formal` | A forward-only input enters the typed body as the entry itself, a pointer that may be zero, and no longer as a value. |
| The native entry | `l2_emit_tramp_lex` | A reader with a lexical source of its own reads a present entry as before; for an absent one it reads the unit's cell through the parent of its own occurrence. |
| The walked body | `l2_rw_arg_fb`, `l2_rw_dyn_arg` | The same rule in the walker's terms: the reader's ARG carries the fallback, a forward-only input is a plain ARG, and a caller with no binding puts no operand. |
| Held calls | `l2_held_binding`, `l2_prep_held_call`, `l2_emit_ns_exec_at` | The same forms through the same writer of an entry. |
| Callees that cannot take it | `l2_hidden_lex` | Where the callee has no entry code that reads its own source (a definition inside a method, a reference, a name whose lexical declaration is not a plain field of the unit), the caller reads the callee's lexical source through the selected occurrence, as before. A forwarding caller does that only when its own entry is absent. |
| A broken promise | `l2_emit_tramp_lex` | A number a method reads and cannot resolve itself is required of its callers. The translator writes both sides, so an absent entry there is said and stopped: `lmx: invariant: a required input arrived absent`. Before, the entry read an absent number as zero (`lmx_int_value_known` of no cell). |
| Alike | `l2_cfl_alike` | The lexical declarations are no longer compared: each reader resolves its own. |
| Library ingress | `l2_cfl_close`, `l2_cfl_formation` | The formation no longer tests the mode. The closure records, for every callable formal of a library unit, that an occurrence not followed reaches it. |

The concrete boundary of the library, as Codex asked it to be recorded:
`l2_emit_library_wrappers` writes an exported wrapper for every method of a
library unit, so another translation can call any of them and hand any
callable formal an occurrence this translation never saw. That is a fact
about the exported interface of today, written as a flow fact. A library
whose exported set is narrower would get fewer such facts and the same
algorithm.

An entry, absent or handed on, lives for one synchronous activation. The
typed body of a forwarding method puts the pointer only into the entries of
the calls it makes; a reader copies the value into its own working storage.
Codex's witness of a returned value that outlives its transport is not
measured by this slice.

### Numbers only

A reference among the hidden inputs keeps its transport: always present, and
a caller with no binding reads the callee's lexical source through the
selected occurrence. Nothing copies the unit, so the source is the same one.
The absence of a reference has to travel where a copied lexical context
makes the difference observable: the third slice, with Codex's witnesses of
the copied lexical value.

### Measured

On the committed translator (`5afcb650`) and on this one, natively and with
the methods walked.

| Program | Before | Now |
| --- | --- | --- |
| `unit_absent_input_forward`: `inner` names no `other` and calls a definition its method returned; that calls `hop`, which calls `g1`; only `g1` reads `other` | natively a wrong value (the fixture's exit 81); walked `walk error: INVALID` | 15; after `other: 20` in the root 26; from `over`, which has `int: other 0`, 6 |
| `unit_absent_input_reader`: `twice` reads `other` and calls `g1`; `setter` assigns `other: 3` and calls `g1` | natively a wrong value; walked `walk error: INVALID` | 2409, and the unit's `other` is still 9 |
| `unit_absent_input_decl_order`: the root calls `hop` above the declaration of `other`, then below it | 1 and 10 | 1 and 10 |
| `unit_callable_formal_free_names_lexical_differ` | refused | 2 and 2, natively |
| `unit_lib_callable_formal` | refused | refused, by the recorded ingress |

Of Codex's five transport witnesses these rows carry two. A supplied zero is
present: `over`, through two forwarding hops; the first slice's `_zero` holds
it for a formal. Forwarding over more than one hop keeps presence and value:
the definition and `hop` in `_forward`, natively and walked; mutual recursion
is the first slice's `_mutual`, natively only, since a consumer of a callable
formal is not walked yet. The witness of alternatives with different names
waits for the next part; the two of a copied lexical value and of a returned
value outliving its transport wait for the third slice, where a held
callable or a merge node is the actual.

### Replay

The slice's translator against the committed one (`5afcb650`), on the 1650
translations recorded by `fable_full_32`: exit, messages and the generated
L1 are the same on 1562 rows. Of the 88 others, 87 translate as before with
another L1, and `unit_callable_formal_free_names_lexical_differ`, refused
before, translates. What the new L1 files contain:

| In the generated L1 | Files |
| --- | --- |
| An entry that reads the unit's cell for an absent input | 53 |
| An entry that stops on an absent required input | 37 |
| A typed body that takes a forward-only entry | 19 |
| A native call that hands an entry absent | 5 |
| A forwarding caller that reads the callee's lexical cell when its own entry is absent | 3: `unit_s7_part_callable_field`, `unit_s7_part_root_field` and its walked twin |

The 88 rows were run before the gates (`fable_abs_01`): 87 pass; the one
failure was the text pin of `unit_decl_order_u2`, written for the first
slice's expression, which this slice moves from the caller into the entry.
The pin is rewritten: no read of those cells in the caller by either route,
and the read in the entry.

### Mutants

Each is a copy of the slice's translator with one change, built apart and run
natively and with the methods walked on ten fixtures: the three new ones,
`_lexical_differ`, `_chain`, `_zero`, `unit_decl_order_u2`,
`unit_site_parent_fallback`, `unit_held_call_guarded` and
`unit_nested_definition_number_override`. The three part rows that take the
hand-off path were run under the last three mutants as well.

| Mutant | What the rows say |
| --- | --- |
| The native entry reads its input without the absent case | `unit_absent_input_forward` and `_reader` give a wrong value natively, as on the committed translator. |
| The walked body's ARG of a unit method has no fallback | Five rows stop walked with `walk error: INVALID`: the three new ones, `unit_decl_order_u2` and `unit_site_parent_fallback`. |
| The lexical declarations are compared again | `_lexical_differ` is refused. |
| A library unit's formals are not recorded as an ingress | `unit_lib_callable_formal` translates in the library profile; with the fact it is refused where the call stands. Nothing is run: a library row links and reads symbols only. |
| A forwarded entry goes as it is to a callee that cannot take it absent | `unit_s7_part_root_field` stops natively with `lmx: invariant: a required input arrived absent`; its walked twin gives a wrong value. |
| No input is forward-only | None of the thirteen rows changes. A probe outside the gate does: a definition that only forwards the name, whose host method has a local of that name, called above the unit's declaration. The slice gives 6 and 15 in both modes; the mutant stops with `walk error: INVALID` in both; the committed translator gives a wrong value natively and stops walked. |
| A caller with no binding reads the callee's cell itself | None of the thirteen rows changes. |

The last two are not kills by a gated row, and are said as they are. The
probe of the forward-only input is not gate evidence: it enters the harness
as a row with the next gated change. The last mutant reads the lexical
source in the caller's activation in place of the reader's. That is the
same cell wherever the callee is the reader, and nothing copies the unit;
it would differ where the callee only forwards and its lexical source is
another declaration than the reader's. Two program parts with roots of
their own can give an ordinary call that shape; that witness is owed. The
mutant's text is pinned on `unit_decl_order_u2` and by nothing else. No
guard was weakened to make a kill.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_19` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_19` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_33` (full harness) | RED 35 of 1657. Against `fable_full_32` (RED 36 of 1651): FAIL→OK 1, `unit_callable_formal_free_names_lexical_differ`; OK→FAIL 0; added 6, all green; removed 0. |
| `build/l2_harness/fable_abs_01` (focused, before the gates) | The 88 rows the replay shows changed: 87 pass, one text pin superseded. |
| `build/l2_harness/fable_abs_02` (focused, before the gates) | Ten rows: the six new ones, `_lexical_differ` and `unit_decl_order_u2` green; the two labelled OPEN rows red. |

The 35 red rows are the 29 of `fable_full_17` and six labelled OPEN
positives: `unit_held_call_to_callable_formal`,
`unit_callable_formal_free_names_self_walk`, `_differ`,
`unit_lib_callable_formal` and the two of the caller's own Structure. The
pre-gate hashes of the translator, the seven fixtures and the harness equal
the live files and every staged copy (`tie.py`).

A figure corrected. The plan's head carried "110 FAIL→OK against that
baseline" for `fable_full_32`. It was the running sum of each gate's count
against the gate before it, so it counted rows this continuation added red
and repaired later. Counted directly against `fable_full_01` (RED 126 of
1395), `fable_full_32` has 97 and `fable_full_33` has 97: the row repaired
here was added after the baseline. Of the baseline's 126 red rows 97 are
green, 24 are red and five were replaced; 267 rows were added, 11 of them
red. The head now carries these figures.

**Next.** The second part of the slice: requirements by call site, so that
a caller is asked only for the names of the callables its own actual can
denote and the entries of the others stay absent; a branch per exact
occurrence where the alternatives on one formal have different names, only
for occurrences the flow proves, with no branch for the declaring method.
`unit_callable_formal_free_names_differ` is its required positive. Then the
third slice: held callables and merge nodes as actuals and as callees, the
library's ingress, the walked consumer.

<a id="site-requirements"></a>
## 59. A call site asks only for the names of the callable it gives; a formal with several formations selects by exact occurrence (second slice, part two)

### Codex's eighth reply -12

It reviews `a5171eb3` and the plan of this part, and corrects the plan in
four places before any byte of it was written.

- No limit on conditions. "The proposed truncation after four conditions is
  rejected, even if dropping conjuncts conservatively over-requires rather
  than under-requires." And: "Represent the complete finite
  source-derived conditions with the ordinary
  dynamic-container/set/worklist machinery."
- The unknown. "UNKNOWN is not an unconditional requirement." And:
  "Do not issue ordinary "unbound dynamic input" for a requirement
  invented by truncation or uncertainty." And: "Do not make "it is a
  reference" a semantic reason to demand an input."
- The last branch. "When alternatives and exact identities really are
  complete, the last class may be the proven remaining class: no redundant
  fatal check is needed merely for defensive programming." And:
  "Never reintroduce the exemplar or a "default actual" as a
  fallback."
- The abort of the first part. "A valid source call whose selected
  actual cannot obtain a required input must be refused through ordinary
  call formation/admission before body execution, not advertised as handled
  by a process abort." And: "Do not accumulate blanket defensive
  checks in generated core code on the rationale that "the translator wrote
  both sides"."
- The transport of the first part stands: "The completed absence
  transport is the right foundation."

So the plan sent with the last checkpoint is withdrawn in four points: the
row of at most four conditions; "not known" counted as "holds"; a reference
counted as needed because it is a reference; a stop in the last branch. And
one thing of the committed first part goes: the entry's abort on an absent
required input.

### What changed

All in `dev/l2src_sandbox/l2trans.lm1`.

| Step | Where | What |
| --- | --- | --- |
| A fact keeps its site | `l2_cfl_note`, `l2_cfl_site_fact` | What reaches a callable formal is recorded with the call node, so what one site's actual can denote is asked per site. |
| The tables grow | `l2_vec_grow`, `l2_cfl_reserve`, `l2_cfr_reserve`, `l2_dyr_reserve` | The facts, the closure and the reasons are blocks that double. The two fixed sizes of the first slice, 256 facts and 512 reaching rows, are gone with their refusals. |
| Reasons | `l2_dyr_add` | For a name a method only hands on, the fixed point keeps why the method has it: a row is the complete set of conditions "the method's callable formal t holds method a"; no condition means always. One condition per formal; a set that asks one formal to hold two methods is no row; a row whose conditions are among another's says all the other would. |
| What a site's actual is | `l2_site_denotes` | A named unit method decides a condition. The caller's own formal handed on turns it into a condition on the caller. No fact of the site, or an occurrence the translation does not follow: not known. |
| What a site needs | `l2_site_needs`, in `l2_dyn_site_callee` | An input the callee reads is the callee's own requirement. An input it only hands on is needed where one of its rows holds for the site's actuals. An input not needed is asked of no one: no inheritance, no check, no refusal. |
| Not known | the same | Where a row would hold but for a condition that cannot be told, the call is refused where it stands, as a limit: `which inputs this call needs depends on a callable this translation does not follow`. Never an invented requirement. |
| A reference left out | the same | Needing is the same for every kind of input. A number not needed is handed absent. A reference not needed is not handed absent yet, and the call is refused where it stands, as a limit. |
| Hard rows | `l2_reader_source`, `l2_dyr_add` | A row is hard when an absent entry would reach a method that reads the name and has no source of its own: no field of the unit it sees, and, for a definition inside a method, no name of its host kept in its node. |
| The refusal | `l2_dyn_site_callee` (the root), `l2_held_unbound` (a held call) | The root, with nothing to give, calls a chain whose hard row holds: `unbound dynamic input`, at translation, where the chain starts. A name the callee only hands on is no longer looked up in the callee's own lexical source. |
| The abort goes | `l2_emit_tramp_lex` | The entry of a reader that cannot resolve a number itself reads it as it stands. The abort `a required input arrived absent` is no longer written. |
| The native call | `l2_emit_call`, `l2_emit_call_hides`, `l2_emit_call_go`, `l2_emit_call_classes` | An input not needed at the site is handed absent and nothing of the caller is evaluated for it. A call through a formal that one formation reaches is as before. More than one: see below. |
| The walked call | `l2_rw_call` | The walked caller takes the same rule. A walked body that calls through a formal with more than one formation is native only: the walk has no such operation yet. |
| The old formation goes | `l2_cfl_classes`, `l2_cfl_class_of` | `l2_cfl_formation`, which refused callables formed differently, is removed. |

### The formation by exact occurrence

Where the methods that reach a formal form their inputs in more than one
way, the call selects the formation by the occurrence the formal holds. The
occurrence is read once. It is compared with the unit's own occurrence of
each reaching method of every class but the last; the last class is the
remainder. Each class then forms its own list through the same
`l2_hidden_from` and calls. No class serves the method that declares the
formal.

What makes the last class the remainder, and not a guess:

- **Every way a callable formal is given a value is one statement of the
  translator.** A unit method becomes a value in one place only, as the
  actual of a callable formal (`l2_cf_actual_emit`); the same loop of
  `l2_check_call` writes the fact, or refuses the actual. A formal handed on
  and a callee that is a formal's value pass through the same loop.
- **The other forms of call do not translate.** Measured by probes: a held
  definition with a callable formal is refused at its call (`a held
  callable whose header is not numbers to a number`); a consumer bound by
  merge is refused (`run has no argument`, `unknown method`). A merge built
  as the actual is recorded as not followed, and so is every formal of a
  library unit; the call through such a formal is refused.
- **The formal's value does not leave its formal or change in it.** Measured
  by probes: rebinding the formal, storing it in a local reference,
  declaring a local of the contract's type from it, and returning it are
  each refused today (`unknown type`, `more arguments than … has formals`,
  `a callable merge needs one model`). So the value read at the call is the
  value the call site gave.
- **Both sides are one expression.** The caller names the method's
  occurrence in the unit; the consumer compares with the same expression
  through its own reference to the unit. They are the program's one unit.

This is a statement about the routes of today, and the probes are not gate
rows. A route added later, a held consumer, a merge-bound one, a formal's
value stored or returned, has to write its fact or the row "not followed",
or the remainder stops being proved. That is the third slice's to keep.

### Measured

On the committed translator (`a5171eb3`) and on this one, natively.

| Program | Before | Now |
| --- | --- | --- |
| `unit_callable_formal_free_names_differ`: `run` receives `g1`, which reads `other`, and `f0`, which reads `base`; from the root, from `outer (int: other)` with 40, from `under (int: base)` with 77 | refused: `callables whose inputs are formed differently` | 10 and 5; 4105; 1077 |
| `unit_callable_formal_site_names`: `g1` reads `other`; `fz` reads `zz`, which the unit does not declare; the root has no `zz` and gives `g1`; `withzz` has `zz` 30 and gives `fz`; `outer` has `other` 40 and gives `g1` | refused at the root's call that gives `g1`: `unbound dynamic input zz` | 10; 32; 41 |
| `unit_callable_formal_site_names_forward`: the same through two formals handed on, and through a callee that is a formal's value | refused the same way | 10 by each route; 32 by each; 41 by each |
| `unit_callable_formal_site_names_mutual`: the same through mutual recursion; `pong` has its own `other`, 70 | refused the same way | 10, 71, 71; 32 and 32 |
| `unit_callable_formal_site_conditions`: `zz` is needed only while six formals hold six methods; the root has no `zz` | refused the same way | 7 with a callable that reads nothing at the end; 5 with a link that never calls it; 31 where the chain is whole and a caller has `zz` |
| `unit_callable_formal_site_names_missing_refused`: the root gives `fz` and no one has `zz` | refused at 25:8, the root's call that gives `g1` | refused at 27:8, the call that gives `fz` |
| `unit_absent_input_unavailable_refused`: the root calls a held definition that only hands `zz` on to a reader with no source; the method that made the definition has a local `zz` | translates; at run time the process stops, `a required input arrived absent`; walked `walk error: INVALID` | refused at translation, 23:8: `unbound dynamic input zz` |
| `unit_held_call_required_input_from_caller`: the same held call from a method whose caller has `zz` | translates; the same stop at run time | refused where the call stands, as a limit: OPEN |
| `unit_callable_formal_site_names_reference`: one alternative reads a number, the other a Structure | refused at the call through the formal | refused at the site that leaves the reference out, as a limit: OPEN |
| `unit_callable_formal_unfollowed_actual`: a merge built as the actual reaches a formal handed on | refused at the call through the formal | refused at the site whose callable cannot be told, as a limit: OPEN |
| `unit_absent_input_forward_host_local` | 6 and 15, natively and walked | the same; now a gated row |
| `unit_absent_input_parts`: a forwarder of one program part, the reader of another, a source with no such name | 5 and 3, natively and walked | the same; now a gated row |

The last two are the witnesses the first part owed. On `5afcb650`, before
the transport, `unit_absent_input_parts` gives the forwarder's 8 in place of
the reader's 5.

### Replay

The slice's translator against the committed one (`a5171eb3`), on the 1656
translations recorded by `fable_full_33`: exit, messages and the generated
L1 are the same on 1618 rows. Of the 38 others, 37 differ by the three
lines of the removed abort and by nothing else, and
`unit_callable_formal_free_names_differ`, refused before, translates. No row
that translated is refused, and no message of a refusal changes.

Before the gates the new rows, the 38 and the rows of callable formals,
parts and the absent input were run together (`fable_site_01`): 77 rows, 68
pass; the nine red ones are the labelled OPEN positives and the baseline row
`unit_t7_convert`.

### Mutants

Each is a copy of the slice's translator with one change, built apart and run
natively on thirteen fixtures. `differ` and `site_names_forward` were run
again under every mutant after they gained `under` and `far`.

| Mutant | What the fixtures say |
| --- | --- |
| Every condition holds at every site | `site_names`, `_forward`, `_mutual` and `site_conditions` are refused: `unbound dynamic input zz`. |
| The first class's list serves every occurrence | `differ`, `site_names`, `_forward` and `_mutual` give a wrong value; `site_conditions` stops at run time: `a trampoline was called outside its method's signature`. |
| A formal handed on denotes nothing | `site_names_forward` and `site_conditions` are refused (`unresolved name`); `site_names_mutual` and the first slice's `_higher` and `_mutual` give wrong values. |
| A condition on the callee's formal is not carried over to the caller's | `site_names_forward`, `site_names_mutual` and `site_conditions` are refused: `unbound dynamic input zz`. |
| No reason is hard | The three refusal rows translate and run: `site_names_missing_refused`, `unit_absent_input_unavailable_refused` and the first slice's `_missing_refused`. The OPEN row of the held call translates and gives a wrong value. |

The mutants the first part left without a gated kill were run again, on the
new rows, as copies of the first part's translator.

| Mutant of the first part | What the new rows say |
| --- | --- |
| A caller with no binding reads the callee's cell itself | `unit_absent_input_parts` gives 8 in place of 5, natively and walked. |
| No input is forward-only | `unit_absent_input_parts` gives 8 in place of 5 in both modes; `unit_absent_input_forward_host_local` stops with `walk error: INVALID` in both. |
| A forwarded entry goes as it is to a callee that cannot take it absent | `unit_absent_input_parts` stops natively and gives a wrong value walked. |

Every mutant of the two parts is now killed by a value or a refusal of a
gated row. One thing is not behaviour and has no mutant: an input not
needed at a site is handed absent in place of the caller's value, and no
reader exists to tell the two apart. No row pins it; it is visible in the
generated L1 of `differ`, where the callers write a zero entry. The row's
one text pin is the selection of the class in `run`.

### What is not built

Coverage of the implementation, no restriction of the language. Each is a
red required positive.

- **A reference left out** (`unit_callable_formal_site_names_reference`).
- **A held call's names asked of the callers' callers**
  (`unit_held_call_required_input_from_caller`).
- **An occurrence not followed** (`unit_callable_formal_unfollowed_actual`,
  `unit_t7_convert`, `unit_lib_callable_formal`).
- **The walked consumer**, **a held callable as the actual**, **the caller's
  own reference of another declaration**: as before.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_20` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_20` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_34` (full harness) | RED 37 of 1670. Against `fable_full_33` (RED 35 of 1657): FAIL→OK 1, `unit_callable_formal_free_names_differ`; OK→FAIL 0; added 13, of which 10 green and three labelled OPEN rows red; removed 0. |
| `build/l2_harness/fable_site_01` (focused, before the gates) | 77 rows: 68 pass; red only the labelled OPEN rows and `unit_t7_convert`. |

Against the baseline `fable_full_01` (RED 126 of 1395), counted directly:
97 FAIL→OK, OK→FAIL 0, five red rows replaced, 280 added of which 13 red.
The 37 red rows are 24 of the baseline and 13 added: the five that
`fable_full_17` had above the baseline and eight labelled OPEN positives,
`unit_held_call_to_callable_formal`,
`unit_callable_formal_free_names_self_walk`, `unit_lib_callable_formal`,
the two of the caller's own Structure, and the three of this slice. The
pre-gate hashes of the translator, the fifteen fixtures and the harness
equal the live files and every staged copy (`tie.py`).

**Next.** The third slice: held callables and merge nodes as actuals and as
callees through this same formation, with the ordinary admission; the
absence of a reference; a held call's names asked along the chain of
callers; the library's ingress; the walked consumer.

<a id="held-chain"></a>
## 60. A held call asks its model's names along the chain of callers (third slice, step one)

### Codex's ninth reply -12

It answers the one edge asked with the last checkpoint.

- "YES: a captured FREE name does not stop at the immediate caller. It
  remains a free/dynamic input of the returned callable; the copied value is
  its lexical fallback, not a frozen binding."
- The sources at each call: "1. the caller's nearest current
  local/working binding; 2. that caller's already inherited PRESENT dynamic
  input; 3. the selected actual occurrence's eligible lexical source."
- "There is no stack/name-table search: translation resolves the
  relations, activation/ABI references carry the values or absence."
- The boundary: ""One model per own today" is a measured provenance
  boundary, not a new language rule; unproved/rebound alternatives remain
  UNKNOWN until their actual formation is implemented."
- What is not free: "A formal of the SELECTED returned method is not
  free: omitted explicit formals use their declared defaults, not a
  same-named inherited value."
- Another type: "A present zero/null or present incompatible candidate
  is not absence. Conversion/admission failure must not silently choose the
  captured value."
- Its authorities are the book: the priority of sources and the forwarding to
  a fixed point in [§12](../docs/LMX_semantics.en.md#dynamic), and the two
  subsections of [composition](../docs/LMX_semantics.en.md#composition) on
  returned nested methods and on the lexical fallback.

### What changed

All in `dev/l2src_sandbox/l2trans.lm1`.

| Step | Where | What |
| --- | --- | --- |
| A held call is a site | `l2_check_held_call`, `l2_dyn_site`, `l2_dyn_site_held` | The check notes the call as a site of the fixed point of dynamic inputs, its callee the model of the held name. A number the model needs that the calling method does not bind becomes the method's own input, which it only hands on, with the reasons and the hardness of the second slice. |
| The formation | `l2_held_binding`, `l2_rw_held_binding` | Unchanged: the held call takes the caller's input of the name as it takes any binding of the caller, the entry itself where the caller only hands it on. |
| The root | `l2_held_unbound` | Unchanged: the root has no caller; a name it cannot give is left to the model's readers, or refused where one of them has no source. |
| What can be present | `l2_dyp_mark`, `l2_dyp_has`, in `l2_dyn_site_callee` and `l2_dyn_site_held` | Each site records whether it hands a value for an input of its callee: the caller's own field or formal of the name, its own input that it reads or assigns, or its own handed-on input that can itself be present; the root's reading of a callee's lexical source. An input with no record is absent at every call. A library unit's inputs can all be present. |
| One name, two types | `l2_held_never` | See below. |

The model of a held name is the one definition its store statement's method
returns: one per held name today, and that is the site's callee. Measured by
probes, not gate rows: rebinding a held name to another held definition is
refused (`unknown type`), and a name stored from a held name is not
callable (`unknown method`). A route that lets a held name change its
definition has to make the site's callee not known.

The reference is not in this step. A Structure among a held definition's
free names keeps the calling method's own binding or the node's copy, with
the located limit of
[section 56](#nested-references) for another declaration.

### One name, two types

A method hands on one input of a name, with one type. Two held definitions
called by one method can require the name as two numeric types:
`unit_held_call_arity` calls three, made by methods whose formal `n` is an
`int`, an `int` and a `size_t`. Before this step the method had no input
`n` at all and each definition read its own copy.

By the norm a caller's value of another type is a present candidate, to be
converted, never passed over. The conversion of a handed-on input is not
built. What is built is the distinction that keeps the working program
working and the other one honest:

- where the method's input can never arrive present, since no caller of it,
  up the chain, has a value to give, the definition of the other type
  receives nothing and its readers resolve the name: the program runs as
  before;
- where it can be present, the call is refused where it stands, as before
  this step a caller's binding of another type was: a limit, with the red
  required positive `unit_held_call_free_name_converted`.

### A fixture's expectation changed

`unit_a3_caller_binding` and its walked twin expected 6 for `plain()`
called by the root below the root's `int: n 100`: the copy, since `plain`
has no `n` of its own. That was the reading in which a held call asks only
the method that makes it. By the book and Codex's ninth reply the root's
`n` reaches the definition through `plain`, which only hands it on: 101.
The fixture now calls `plain()` twice: above the root's declaration, where
no caller has an `n`, 6, the copy; below it, 101. The committed translator
gives 6 for both.

### Measured

On the committed translator (`3d67e69d`) and on this one, natively and with
the methods walked.

| Program | Before | Now |
| --- | --- | --- |
| `unit_held_call_required_input_from_caller`: `outer` has `zz` 30 and calls `inner`; `inner` calls a held definition that hands `zz` on to a reader with no source | refused where the held call stands, the limit of section 59 | 36; and 41 from a method that calls the reader itself |
| `unit_held_call_free_name_chain`: two copies of one definition, of `n` 5 and `n` 9; the root has no `n`; `outer` has `n` 40 and calls through `hop`; `over` has `n` 7 between `outer2` and the call; `zero` has `n` 0 | a wrong value (the fixture's exit 81) | 6 and 10; 41 and 41; 8; 1 |
| `unit_held_call_free_name_working`: the definition reads the unit's `v`, 9; `hopf` only hands it on; `work` adds 2 to its `v` and calls `hopf` | a wrong value | 109; 111; the unit's `v` still 9; 109 |
| `unit_held_call_free_name_node`: the definition reads `n` and its node's `n`; built with 5; `outer` has `n` 40 | a wrong value | 505; 4005 |
| `unit_held_call_required_input_unavailable_refused`: no one has `zz` | refused at the held call in `inner`, as the limit | refused at 27:8, the root's call of `inner`: `unbound dynamic input zz` |
| `unit_a3_caller_binding`, with `plain()` above and below the root's `n` 100 | 6 and 6 (exit 72) | 6 and 101 |
| `unit_held_call_arity`: three held definitions whose `n` is an `int`, an `int` and a `size_t`, called by one method; no caller has an `n` | runs | runs |
| `unit_held_call_free_name_converted`: the same shape, and a caller with an `int` `n` 40 | translates and gives a wrong value: the `size_t` definition reads its copy | refused where its call stands, as a limit: OPEN |

Of Codex's witnesses for this step the rows carry all but one. The chain
`outer` to `inner` to the held definition to the reader; a second
forwarding method and a nearer binding between; a working value assigned and
handed on; a present zero; no value anywhere, with two copies each reading
its own; an explicit `node` read keeping the copy under a supplied value; a
required input no one can give, refused at the root's call that starts the
chain. Each natively and with every method walked. The one not carried:
structural candidates of another shape, which belong to the reference.

### Replay

The step's translator against the committed one (`3d67e69d`), on the 1669
translations recorded by `fable_full_34`: exit, messages and the generated
L1 are the same on 1606 rows. Of the 63 others, 62 translate as before with
another L1, in each of which a method gains a handed-on input, and
`unit_held_call_required_input_from_caller`, refused before, translates. No
row that translated is refused.

A first form of the step refused four of them, the rows of
`unit_held_call_arity`: its method came to hand on `n` as an `int` and then
met the definition whose `n` is a `size_t`. That is the case of one name and
two types above; the replay showed it before any gate.

The 63 rows and the new ones were run before the gates
(`fable_heldp_01`): 84 rows, 77 pass. Of the seven red ones five are
labelled OPEN or baseline rows. The other two were `unit_a3_caller_binding`
and its walked twin, with the expectation recorded above; they were changed
after that run.

### Mutants

Each is a copy of the step's translator with one change, built apart and run
natively and with the methods walked on nine fixtures.

| Mutant | What the fixtures say |
| --- | --- |
| The held call is not noted as a site | As the committed translator: `required_input_from_caller` is refused; `free_name_chain`, `_working`, `_node` give wrong values; `unit_a3_caller_binding` gives 6 for 101; the unavailable input is refused in the wrong place, as the limit. |
| The calling method records no reason for the name it takes | Every row with a held call from a method is refused at the root: `unbound dynamic input`, for the definition's own `n` or `k`. |
| Every entry can be present | `unit_held_call_arity` is refused: `a caller's binding of a held callable's free name is of another type`. |
| No entry is ever recorded as present | No gated row changes. The OPEN row `unit_held_call_free_name_converted` translates and gives a wrong value in place of the located limit. |

The last is not a kill by a gated row, and is said as it is. The record of
presence decides one thing only: whether a method's handed-on input of one
type may be passed over for a definition that requires the name as another
type. Where it may not, the right behaviour is the conversion, which is not
built, so the only program that tells the two apart is a red required
positive. It becomes a gated kill with the conversion.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_21` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_21` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_35` (full harness) | RED 37 of 1679. Against `fable_full_34` (RED 37 of 1670): FAIL→OK 1, `unit_held_call_required_input_from_caller`; OK→FAIL 0; added 9, of which 8 green and one labelled OPEN row red; removed 0. The two rows of `unit_a3_caller_binding`, with the changed expectation, pass. |
| `build/l2_harness/fable_heldp_01` (focused, before the gates) | 84 rows, 77 pass; see the replay above. |

Against the baseline `fable_full_01` (RED 126 of 1395), counted directly:
97 FAIL→OK, OK→FAIL 0, five red rows replaced, 289 added of which 13 red.
The 37 red rows are 24 of the baseline and 13 added: the five that
`fable_full_17` had above the baseline and eight labelled OPEN positives.
The pre-gate hashes of the translator, the nine fixtures and the harness
equal the live files and every staged copy (`tie.py`).

**Next.** Held callables and merge nodes as actuals, with their own exact
identity, through the same formation; the reference: its absence, its
admission, and its asking along the chain; the conversion of a handed-on
input; the library's ingress; the walked consumer.

<a id="held-actual"></a>
## 61. A held definition as the actual of a callable formal (third slice, step two)

### Codex's tenth reply -12

It accepts the last checkpoint, with the open conversion case and the
presence mutant no gated row kills kept visible, and answers the question
sent with it: may the class of a definition's node be told, where a formal
is called, by the address of the signature part the node shares with its
model.

- The answer: "YES as an existing, proved physical witness of a
  FORMATION CLASS in this bounded flow analysis; NO as an unconditional
  identity of the callable occurrence, or as a universal language rule that
  every copy shares its signature."
- What is called: "The selected q remains self; its own parent
  supplies lexical fallback and its own native word selects native/walk
  dispatch. Never replace q by the model occurrence or read the model's
  captured cells."
- The remainder: "The last branch is allowed only as the previously
  proved exhaustive remainder; UNKNOWN never means the last model."
- The obligation under that selector: "There is a concrete copy
  obligation you must NOT freeze to keep the proposed selector working.
  l2_mad_emit currently shares slots 0/1 and executable parts while copying
  cells." And: "Do not bless partial MAD construction as
  complete copying, or preserve a wrong alias solely to tag model
  provenance. If the class witness survives the correct existing
  representation, use it; if correcting the copy removes that relation, do
  not add a tag/registry to recreate it or pretend the relation remains
  proved. Keep that route explicitly OPEN until its actual physical contract
  route is implemented."
- The merge built as an actual: "A measured MAD relation does not
  automatically establish a T7 relation."
- The presence record of section 60: "The never-present optimization
  is sound only under a complete, closed presence proof. No recorded PRESENT
  mark must not mean NEVER_PRESENT when an external/unfollowed ingress or
  incomplete closure remains possible."
- The order of work: "Proceed through the existing common dependency:
  held/merge actual formation, reference absence/admission and transitive
  forwarding, receiving-edge conversion, external ingress, genuinely walked
  consumers."

### What changed

All in `dev/l2src_sandbox/l2trans.lm1`.

| Step | Where | What |
| --- | --- | --- |
| The actual | `l2_cf_held`, `l2_check_call` | An actual of a callable formal that is a held name whose model is known is admitted by the model's signature against the method that declares the formal (`l2_method_sig_compatible`), as a method of the unit is. |
| The flow fact | `l2_cfl_note` with kind 4, `l2_cfl_bring`, `l2_site_denotes` | The fact says: a node of model M. The closure brings M to the formal as it brings a method, so the fixed point of dynamic inputs asks M's names of the consumer and up its chain, and the site knows which callable it gives. |
| What is handed | `l2_cf_actual_emit`, `l2_rw_callable_actual` | The node the name holds: the caller's own field, or, where the held name is a name of the unit read in a method, that method's hidden input of the name. Nothing is called. |
| The call through the formal | unchanged | `q` is the node itself. Its hidden inputs are formed by the one formation of its class; its own parent gives the lexical fallback; its own native word selects the dispatch. |
| The limit | `l2_cfl_classes` | Where more than one class of formation reaches a formal and one of the reaching callables is a definition's node, the call is refused where it stands. |

### The class of a node

With more than one class of formation at a formal, the call tells, when it
runs, which class the occurrence it holds belongs to. For a method of the
unit that is the comparison of the occurrence itself
([section 59](#site-requirements)): a method of the unit has one
occurrence. A definition's node is made anew by every return of its method;
no one address is the definition.

One relation exists today between a node and its model. `l2_mad_emit`
stores the model's args part and return part into the node by address, so
the args part of `q` is the args part of the model's occurrence for every
node of that model and for no node of another. A variant of this step's
translator selects by it. It was built and measured:
`unit_held_actual_among_methods` and `unit_held_actual_two_models` pass on
it, and with the comparison put back to the occurrence itself they fail.

It is not landed. The relation exists because the node is a partial copy:
slots 0 and 1 are the model's by address, a number is a fresh cell, and
everything else, the steps and the nested bodies, is the model's by address
(`lmx_walk_cell_copy`). L2 [§13](../docs/L2_spec_en.md#copy-merge) requires
a copy of the complete used closure with references and `parent` links
rewritten, and retains by address only a reusable native implementation and
an admitted `independent: const: immutable` branch. A selector that reads
the shared part would freeze the sharing. So the route stays open, as Codex
rules, with the two fixtures as red required positives
([HELD-ACTUAL-NODE-CLASS](defects.md#held-actual-node-class)), and the copy
is recorded as an obligation of its own
([RETURNED-NODE-PARTIAL-COPY](defects.md#returned-node-partial-copy)). No
program is known that gives a wrong value through the shared parts.

What needs no telling works. Two copies of one definition are one class
(`unit_held_actual_free_names`). A definition and methods of the unit that
form their inputs alike are one class (`unit_held_actual_alike`).

### The presence record, closed

`l2_held_never` ([section 60](#held-chain)) lets a held call pass over a
method's handed-on input of another type only where that input can never
arrive present. "No record" may mean "never present" only if every
hand-over is recorded. That was checked in two ways.

By enumeration. A hidden input is formed in six places: the native call
(`l2_emit_call_hides`), the native execution of a named Structure
(`l2_emit_ns_exec_at`), the walked call (`l2_rw_call`), the walked execution
(`l2_rw_ns_hidden`), the native held call (`l2_prep_held_call`) and the
walked held call (`l2_rw_mad_call`). Each stands at a site the check phase
records for the fixed point: a call of a method, an execution of a named
Structure and a conversion edge by `l2_note_call`; a call through a formal
by `l2_check_call`; a held call by `l2_check_held_call`. A callable this
translation does not follow, reaching a formal, makes the call a refusal
(`l2_cfl_classes`), so a translated program has no entry the fixed point did
not see. A library unit's methods are entered from other translations:
every input of a library unit counts as one that can be present
(`l2_dyp_has`).

By an instrument. A scratch copy of this step's translator, never landed,
stops at each of the six places where a number input the callee only hands
on receives an entry that can be present while the fixed point recorded no
presence for that callee and name.

Replayed over the 1678 translations recorded by `fable_full_35`: 57 rows have
at least one such hand-over (649 counting every emission pass: 277 entries
handed on and 372 values), and none stops. Four of this step's fixtures have
them too, and none stops. On every row the exit, the messages other than the
instrument's own lines, and the generated L1 equal the uninstrumented
translator's.

The instrument's control is the same instrument over a translator whose
fixed point records no presence at all. It stops on 44 of the 58 rows that
then have a hand-over, and on the four fixtures of this step. The other 14
rows hand on only entries of a caller whose own presence is equally
unrecorded, which the instrument has to read as never present.

This is a census of the corpus and a reading of the code. It is no proof
for a program the corpus lacks.

### Measured

On the committed translator (`f3c46518`) and on this one, natively.

| Program | Before | Now |
| --- | --- | --- |
| `unit_held_call_to_callable_formal`: `run`'s formal takes a held definition and calls it twice | refused where the name is given: `incompatible entry signature` | 200; the trace is 0 on entry to `run` and 2 after |
| `unit_held_actual_free_names`: two copies of one definition, of `n` 100 and 900, reading `n` and the unit's `other`, 9; given to `run`, through `mid`, and from a method; `withn` has `n` 40 two methods above the call; `withother` has `other` 2 | refused the same way | 109 and 909; 109 and 909; 49 and 49; 102 |
| `unit_held_actual_node`: the definition reads `n`, reads `node\n`, then adds 1 to its node's `n`; `p0`, `p9`, `p0` again, then `p0` under a caller's `n` 7 | refused the same way | 100 and 100; 900 and 900; 101 and 101; 7 and 102 |
| `unit_held_actual_local`: a definition made in a method, kept in that method's own name and given from there; `localn` has `n` 3 | refused the same way | 109; 909; 12 |
| `unit_held_actual_alike`: a definition and two methods of the unit, each reading only `other`, at one formal; `under` has `other` 20 | refused the same way | 109, 10 and 9; 120, 21 and 20 |
| `unit_held_actual_signature_refused`: a definition that takes an `int`, given to a formal declared by a method that takes nothing | refused at 20:8: `incompatible entry signature` | the same refusal, now by the model's signature: see the mutants |
| `unit_held_actual_among_methods`: a definition reading `n`, a method reading `other` and a method reading nothing, at one formal | refused the same way | refused where the formal is called, as a limit: OPEN |
| `unit_held_actual_two_models`: definitions made by two methods, one reading `n` and one reading `m`, and two copies of the first, at one formal | refused the same way | refused where the formal is called, as a limit: OPEN |

Of the witnesses Codex names for this step the rows carry: two copies of
one model with different captured values; a caller's value against an
explicit read of the node; independent change of the copied state; a
definition among callables of the same signature, formed alike and formed
differently, the second red. Not carried: execution with the consumer
walked. With the methods walked the translation is refused at the method
that declares the formal (`a callable result or a callable formal is outside
the walkable subset`), as before this step, so there is no walked twin, and
the branch of `l2_rw_callable_actual` for a held name that is a walked
method's hidden input cannot run yet. It has the form of the branch for a
formal handed on, which waits for the same walked consumer.

### Measured by scratch probes, not gated

These are no rows yet. They become rows with the next step.

- Two definitions made by two methods that form alike, each reading the one
  name `n`, at one formal: 105 and 60, and 6 and 2 under a caller's `n` 1.
  One class; nothing is told apart.
- A reference among the definition's free names. `g0` reads `m\v`, where `m`
  is a field of the unit made from `Model`. Through the formal the reference
  travels as any method's input does: 9 from the root. Under a caller with
  its own `m` of the same declaration and `v` 40: 45. Under a caller whose
  `m` is of another declaration, with `v` at another position: 45, admitted
  by the field it reads. Under a caller whose `m` is of a declaration
  without `v`: refused at translation where the formal is called,
  `implements is false in function argument`. The direct held call of such
  a definition under a caller's own `m` is still the located limit of
  [section 56](#nested-references).
- Ahead of the next step, a defect found: a merge whose model reads a free
  name. `add` reads the unit's `other`; `w: wrap 5` holds
  `merge(y: k; add)`; `(w: 1)` stops the process when it runs: `lmx:
  invariant: a callable merge was called outside its header`. The held call
  hands the model's hidden input after the declared argument. The node the
  merge builds has no place for it in its header, and its body reads the
  name at the model's own position. The committed translator does the same
  ([T7-MODEL-FREE-NAME](defects.md#t7-model-free-name)).

### Replay

The step's translator against the committed one (`f3c46518`), on the 1678
translations recorded by `fable_full_35`: exit, messages and the generated
L1 are the same on 1677 rows. The one other,
`unit_held_call_to_callable_formal`, refused before, translates. The replay
ran on a build of the translator whose generated C equals, byte for byte,
that of the source committed with this step.

The eight rows of the step were run before the gates (`fable_hactp_02`): six
pass, the two labelled OPEN rows are red.

### Mutants

Each is a copy of the step's translator with one change, built apart and run
natively on the eight fixtures.

| Mutant | What the fixtures say |
| --- | --- |
| The held actual writes no flow fact | `unit_held_call_to_callable_formal`, `unit_held_actual_free_names`, `_node` and `_local` end in `walk error: INVALID`: the call through the formal forms nothing for the definition. `_alike` is refused: what the call needs depends on a callable not followed. |
| A held definition is admitted whatever its signature | `unit_held_actual_signature_refused` translates and ends in `walk error: INVALID`. |
| The native caller never reads the held name as its hidden input | `unit_held_actual_free_names`, `_node` and `_alike`, where a method gives a held name of the unit, do not compile: the generated C names a cell the method does not have. |
| The native caller never loads the held name as its own field | Every row that gives a held name is refused: `internal: a refusal said nothing`. |
| The walked caller does not know a held name as an actual | Every row that gives a held name is refused where the root gives it: `an unresolved callable occurrence`. |
| The limit fires for one class too | The five rows that run are refused with the limit's message. |
| The limit removed, a node's class compared as a method's occurrence is | No gated row changes. The two OPEN rows translate and end in `walk error: INVALID` and in a wrong value in place of the located limit. |
| The limit replaced by the selection on the part shared with the model | Every row passes, the two OPEN rows too. Not landed, for the reason above. |

The seventh is not a kill by a gated row, and is said as it is. As with the
presence mutant of section 60, the only programs that tell the limit from
its absence are red required positives; they become gated kills when a node
has its own contract route. The sixth shows the other direction is gated:
the limit does not reach a formal with one class.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_22` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_22` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_36` (full harness) | RED 38 of 1686. Against `fable_full_35` (RED 37 of 1679): FAIL→OK 1, `unit_held_call_to_callable_formal`; OK→FAIL 0; added 7, of which 5 green and two labelled OPEN rows red; removed 0. |
| `build/l2_harness/fable_hactp_02` (focused, before the gates) | 8 rows, 6 pass; see the replay above. |

Against the baseline `fable_full_01` (RED 126 of 1395), counted directly:
97 FAIL→OK, OK→FAIL 0, five red rows replaced, 296 added of which 14 red.
The 38 red rows are 24 of the baseline and 14 added: the five that
`fable_full_17` had above the baseline and nine labelled OPEN positives.
The pre-gate hashes of the translator, the eight fixtures and the harness
equal the live files and every staged copy (`tie.py`).

**Next.** A merge built as the actual, from the graph it really makes; the
reference: its absence, its admission, and its asking along the chain; the
conversion of a handed-on input; the library's ingress; the walked
consumer; the complete copy of a returned definition's node and a node's
own contract route.

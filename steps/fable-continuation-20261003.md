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
  ([open author question](../LMX_blog/q/current/graph-hidden-input-name-binding.md));
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
[the author's answer](../LMX_blog/q/current/graph-hidden-input-name-binding.md).
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

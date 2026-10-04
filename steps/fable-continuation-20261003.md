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

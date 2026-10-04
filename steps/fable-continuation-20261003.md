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

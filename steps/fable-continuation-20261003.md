# Fable continuation ledger — 2026-10-03

Working evidence of the continuation that follows [the handoff](../to_fable.md)
and [the v2 plan](../next_core_tasks_v2.md). It is not a specification and not a
release record. Earlier evidence stays in
[the namespace source-layout ledger](critical-graph-namespace-source-layout-20261003.md).
Both critical tickets and stages 8/8a remain OPEN. Stable `l2src/` is unchanged.

Roles: Fable was the single writer/build owner through section 71; from
section 72 Opus is (the author's assignment, 2026-10-05). Codex answers
questions through `lmx_uds`. Every gate below ran alone, one compiler chain at
a time.

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
| `unit_colon_hidden_update`, `unit_free_conv`, `unit_walk_free_conv` | No independent preceding use. Both readings are self-consistent; the tie-break is [asked of the author](../LMX_blog/q/head-role-hidden-input-fixed-point.md). Expectations stay as they are, red. |

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
[the author](../LMX_blog/q/head-role-hidden-input-fixed-point.md).
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
[`LMX_blog/q/held-factory-initialization-versus-body-definition.md`](../LMX_blog/q/held-factory-initialization-versus-body-definition.md)
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

<a id="merge-actual"></a>
## 62. Formation against transport; a merge's node and its contract; a merge as the actual (third slice, step three)

### Codex's eleventh reply -12

It answers the question sent with the last checkpoint: a method that reads
a free name and receives no value for it resolves the name from its own
lexical source; what do its own callees receive?

- "Answer to your measured question: B." And the reason:
  "The lexical source is how g forms ITS missing input n. Once g's
  own input is resolved to 70, that is g's activation-local value of n.
  Calling f then supplies that value."
- Transport: "A method that only transports an absent entry and has no
  consuming binding for that name forwards absence, so the eventual reader
  can use its OWN lexical fallback."
- Formation: "A method whose contract consumes the name forms its
  activation-local hidden argument from the ordinary available sources. That
  formed value is available to its callees. No assignment is required to
  make a value exist."
- No flag: "Do not introduce a runtime "has this expression read n
  yet?" flag or make the rule depend on incidental native evaluation
  order."
- The text: "Mark this as a clarification derived from the existing
  norm, NOT a verbatim author quotation or a newly accepted language
  feature."
- The merge whose model reads a free name: "Fix the common
  actual-input formation and graph's input coordinates rather than changing
  the language, treating the additional hidden input as an extra explicit
  argument, dropping it, or padding a special T7 header. The reusable body
  must receive the selected node's complete contract and sources." And:
  "No invariant abort is acceptable as the successful behavior of
  this valid call."
- The copy: "Preserve RETURNED-NODE-PARTIAL-COPY as an architectural
  obligation: absence of a wrong-value example is not proof of full
  copying."

The implementation already gave B, natively and walked, since
[section 58](#absent-input). Nothing of it changed. The three fixtures Codex
asks for are one fixture, `unit_held_call_formed_input`: the forming reader,
the control that only transports, and the assignment. The third needed the
first change below.

### The book

[§12](../docs/LMX_semantics.en.md#dynamic) lists three sources of a free
name. Its compressed wording could be read as saying that a value a method
read from its own lexical source is nothing its callees can receive. Three
sentences are added to that paragraph, in both languages, beginning "It
follows that": a method that consumes the name forms its activation's value
from those same sources and its callees receive it; a method that only
forwards it forms nothing; an assignment changes that activation's value
only and an explicit `node\x` read forms no binding. This is a
clarification derived from the existing norm by Codex's reply. It is no
quotation of the author and no new feature of the language, and it is not
archived in `LMX_blog/`. The kernel map carries the same sentence at its
existing place.

### What changed

All in `dev/l2src_sandbox/l2trans.lm1`.

| Part | Where | What |
| --- | --- | --- |
| An assignment in a definition | `l2_local_ns_shape` | A head that names a formal, or a field declared at method level, of the method that holds the definition is a binding the head resolves to. The statement assigns the definition's own value of that free name. Before, it was read as the declaration of a Structure of the definition, and the definition was refused. |
| A merge's node: its contract | `l2_t7_write`, `l2_mad_max_inputs` | The node's args part is the node's complete contract: the formals the merge leaves unbound, then the model's hidden inputs, a cell of each one's type made by the emitter a method's own args part uses (`l2_emit_cell_new_ty`). The widest input list of a held node counts a merge's node. |
| A merge's node: its body | `l2_rw_arg_pos`, `l2_rw_arg`, `l2_rw_arg_fb`, `l2_rw_arg_lex` | The body reads each input at its place in the node's contract. Before, a hidden input was read at the model's own place, past the end of what the call hands. A formal the merge binds, reached by its place among the model's inputs, is the field of the node that holds its value. |
| A merge's node: what it cannot name | `l2_rw_cell` | A cell held in a nested body of the unit is named, where the unit is built, by that constructor's own alias. A merge's node is built by a constructor of its own. Such a read is a located limit at the merge. |
| The tables of merges | `l2_t7_reserve`, `l2_t7b_reserve`, `l2_t7h_reserve` | They grow with the program. Before: 8 merges, 16 bindings, 16 entries of declared headers, and the ninth merge refused as `out of memory`. |
| A merge as the actual: the fact | `l2_check_call`, `l2_t7_actual_model`, `l2_cfl_note` with kind 5 | The fact says: a node the merge builds of model M. It is followed as a held definition's node is. One merge is one site, however often its call is checked. |
| Nodes built at run time | `l2_cfr_built`, `l2_cfr_any_built`, `l2_cfl_classes` | The closure records whether a method reaches a formal as a node built when the program runs: by a return or by a merge. The limit of [section 61](#held-actual) is set by that record, with new words, and no longer by the method's being a definition's model. |
| The hidden inputs of the selected callable | `l2_emit_call_hides`, `l2_emit_call_go`, `l2_rw_call` | They are found at that callable's own arity. Before, they were looked up after the call's declared actuals: the same place for a method and for a definition, another one for a merge's node, whose model has more formals than the call gives. |
| The written merge in the graph | `l2_rw_merge_actual`, `l2_rw_callable_actual` | The merge given as an actual is retained in the graph of the method that gives it as a machine operation: each binding under its name with its value resolved as any actual's, and the model as the occurrence it names. The method is native-only. Before, the pass that builds every method's graph refused the method. |
| The root | `l2_t7_from_actual` | The root's merge given as an actual is refused as the limit it is, no longer as `incompatible entry signature`. |

The node a merge builds keeps the header its method declares: nothing is
added to what a caller writes. What changed is the node's own args part,
which every callable has for all its inputs, and the places its body reads.

### Defects met on the way

Each was there before this step; each is recorded in `steps/defects.md`.

- Fixed: [T7-MODEL-FREE-NAME](defects.md#t7-model-free-name), and with it a
  merge that leaves two formals unbound, a model that reads a reference, and
  a model that calls a reader of its bound formal;
  [NESTED-DEFINITION-ASSIGNS-HOST-NAME](defects.md#nested-definition-assigns-host-name);
  [T7-TABLES-FIXED-SIZE](defects.md#t7-tables-fixed-size).
- Open, each a located limit with a red required positive:
  [T7-ACTUAL-REFERENCE](defects.md#t7-actual-reference);
  [T7-ACTUAL-FROM-ROOT](defects.md#t7-actual-from-root).
- `unit_t7_convert`, red since the baseline, is green.

### Measured

On the committed translator (`5c492ca7`) and on this one, natively; the
rows that have a walked twin give the same with the methods walked.

| Program | Before | Now |
| --- | --- | --- |
| `unit_held_call_formed_input`: `f` reads `n`, its copy 5; `g`, with its own copy 70, reads `n` and calls it; `h` only calls it; `w` adds 2 to its `n` and calls it, twice; then `f` alone | refused: the assignment in `w` was read as a declaration (`a reference where a number is asked`) | 70 and 71; 6; 72 and 73, twice; 6 |
| `unit_nested_definition_assigns_free_name`: a definition adds to a formal of its method, twice; to a field its method declares, twice; sets the formal before reading it; reads it into a local and then assigns it | refused: `return value has incompatible type` | 72 and 72; 141 and 141; 7; 75 |
| `unit_held_actual_two_alike`: two definitions of two methods, each reading `n`, at one formal; then under a caller's `n` 1 | 105 and 60; 6 and 2 | the same; now a row |
| `unit_held_actual_reference`: a definition reading `m\v` at a formal; from the root, under a caller's `m` of the same declaration, under one of another declaration with `v` elsewhere | 9; 45; 45 | the same; now a row |
| `unit_held_actual_reference_refused`: under a caller's `m` of a declaration without `v` | refused at 27:13: `implements is false in function argument` | the same; now a row |
| `unit_t7_free_name`: a held merge whose model reads the unit's `other`, 9; two copies; under a caller's `other` 20 | the process stops: `a callable merge was called outside its header` | 15 and 110; 26 |
| `unit_t7_two_formals`: a held merge that leaves two formals unbound, the only callable result of its unit | the process stops, the same way | 215 |
| `unit_t7_reference_held`: a held merge whose model reads `m\v` | the process stops, the same way | 10 |
| `unit_t7_model_calls_reader`: the model calls a method that reads, as free names, the formal the merge binds and the one it leaves | `walk error: INVALID` | 507 and 1000 |
| `unit_t7_convert`, red since the baseline: `passed` gives `take` a merge | refused: at the baseline the merge had no place in the graph of `passed` (`an unresolved callable occurrence`); since section 57 the call through the formal, as one not followed | 6, 101, 6 and 5 |
| `unit_t7_actual_free_name`: a merge given as an actual whose model reads `other`; bound to a literal and to the giving method's formal; under a caller's `other` 20; a model reading a `size_t` | refused: not followed | 14; 16 and 109; 25 and 27; 6 |
| `unit_t7_actual_alike`: a merge and a method of the unit, each reading only `other`, at a formal handed on; under a caller's `other` 20 | refused: not followed | 10 and 14; 25 and 21 |
| `unit_t7_actual_typed_reference`: the model reads `r\v`, `r` a typed reference of the unit | refused: not followed | 9 by name; 9 through the formal |
| `unit_t7_many`: 26 merges, 26 bindings, 18 entries of declared headers | refused at the ninth merge: `out of memory` | 153 and 1935 |
| `unit_t7_actual_reference`: the model reads `m\v`, `m` a merge result of the unit, and the merge is given as an actual | refused: not followed | refused at the merge, as a limit: OPEN |
| `unit_t7_actual_from_root`: the root gives a merge as an actual | refused: `incompatible entry signature` | refused at the merge, as a limit and in those words: OPEN |
| `unit_callable_formal_unfollowed_actual`: a merge's node and a method formed differently at one formal handed on | refused: what the call needs cannot be told | refused where the formal is called: the class of a node built at run time is not told. Still OPEN |

What a merge's node reads where no caller gives the name is the unit's
cell, the lexical source of its model, baked into the node's body where the
node is built. Whether the node's own parent, the method that built it,
should come before the unit in that lookup is not settled here: no row
depends on it, and it belongs with the complete copy of a built node.

Not carried: a walked consumer. With the methods walked a method with a
callable formal is refused whole, as before.

### Replay

The step's translator against the committed one (`5c492ca7`), on the 1685
translations recorded by `fable_full_36`: exit, messages and the generated
L1 are the same on 1681 rows. Of the four others three are refused as
before with the limit's new wording, and `unit_t7_convert`, refused before,
translates. No L1 of any other row changes: a merge's node whose model has
no hidden input is built as it was, byte for byte.

The replay, the mutants and the focused run used a build whose generated C
equals, byte for byte, that of the source committed with this step; the two
sources differ in two comments.

The step's rows and the four refusals of the merge forms were run before
the gates (`fable_s3cp_01`): 29 rows, 24 pass, the five labelled OPEN rows
are red.

### Mutants

Each is a copy of the step's translator with one change, built apart and run
natively on the sixteen new fixtures and on five rows that were there.

| Mutant | What the fixtures say |
| --- | --- |
| A definition's assignment to a name of its method is read as before | `unit_held_call_formed_input` and `unit_nested_definition_assigns_free_name` are refused. |
| The body of a merge's node reads an input at the model's own place | Nine rows end in `walk error: INVALID`: `unit_t7_convert`, `_free_name`, `_two_formals`, `_reference_held`, `_model_calls_reader`, `_actual_free_name`, `_actual_alike`, `_actual_typed_reference`, `_many`. |
| A formal the merge binds, reached by its place among the model's inputs, is read as an input | `unit_t7_model_calls_reader` ends in `walk error: INVALID`. |
| The args part of a merge's node holds the declared formals only | `unit_t7_free_name` and `_reference_held` stop the process: `a callable merge was called outside its header`. |
| The widest input list of a held node does not count a merge's node | `unit_t7_free_name`, `_two_formals`, `_reference_held` and `_many` stop the process the same way. |
| The tables of merges keep their fixed sizes | `unit_t7_many` is refused: `out of memory`. |
| A merge given as an actual writes the fact "not followed" | `unit_t7_convert`, `_actual_free_name`, `_actual_alike`, `_actual_typed_reference` and `_many` are refused. |
| The written merge is not retained in the graph of the method that gives it | The same five rows are refused: `an unresolved callable occurrence`. |
| A hidden input of the selected callable is looked up after the call's declared actuals | `unit_t7_actual_typed_reference` ends in `walk error: INVALID`: the reference is handed as the `int` the merge binds. |
| A node built at run time reaches a formal as if it were the unit's occurrence of its model | No gated row changes. Of the three OPEN rows of the limit two end in `walk error: INVALID` and in a wrong value, and `unit_callable_formal_unfollowed_actual` gives the right values by the order of its classes. |
| A merge's node names a holder only the unit's constructor can name | No gated row changes. The OPEN row `unit_t7_actual_reference` translates into C that does not compile, in place of the located limit. |

The last two are not kills by gated rows, and are said as they are. Each is
a limit whose only witnesses are red required positives; they become gated
kills when the route is built.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_23` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_23` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_37` (full harness) | RED 39 of 1707. Against `fable_full_36` (RED 38 of 1686): FAIL→OK 1, `unit_t7_convert`, a row of the baseline; OK→FAIL 0; added 21, of which 19 green and two labelled OPEN rows red; removed 0. |
| `build/l2_harness/fable_s3cp_01` (focused, before the gates) | 29 rows, 24 pass; see the replay above. |

Against the baseline `fable_full_01` (RED 126 of 1395), counted directly:
98 FAIL→OK, OK→FAIL 0, five red rows replaced, 317 added of which 16 red.
The 39 red rows are 23 of the baseline and 16 added: the five that
`fable_full_17` had above the baseline and eleven labelled OPEN positives.
The pre-gate hashes of the translator, the sixteen fixtures and the harness
equal the live files and every staged copy (`tie.py`).

**Next.** The reference: its absence, its admission through a held call,
and its asking along the chain; the conversion of a handed-on input; the
library's ingress; the walked consumer, and with it a merge's node built in
a walked body; the complete copy of a node built at run time and a node's
own contract route.

<a id="twelfth-reply"></a>
## 63. Codex's twelfth reply -12, and what is recorded at once

No translator, fixture or harness byte changes with this section, and no
gate is claimed for it. The gates of [section 62](#merge-actual) stand for
the same bytes.

### The reply

It accepts the checkpoint of section 62 as development evidence, and makes
two points of the norm explicit.

- The root: "L2 #call expressly says that every statically compiled
  executable body, including the file root, has a native implementation,
  with no special interpreter-only root." The refusal of the
  root's merge and the comment that the root is walked "describe
  CURRENT DEBT, not a permitted architectural root distinction". And:
  "Keep the same positive at the root and in methods, native and
  genuinely walked; do not add a root-only constructor or change semantics
  by position."
- What a merge's node reads where no caller gives the name, which section
  62 left as unsettled: "Point 12 is not a new semantic choice.
  #composition fixes the new root's lexical parent from the merge
  expression's location; #dynamic uses the selected occurrence's eligible
  lexical links, after caller/local and inherited inputs." And:
  "An address baked into generated code is correct only if it denotes
  the source that those real links select for THAT occurrence; a model's
  unit cell is not automatically the source of every constructed/captured
  copy."
- The fact of kind 5: "keep the distinction between the source MODEL
  and the constructed actual CONTRACT", and "Validate the
  complete constructed contract before treating differently built nodes as
  one formation class, retaining the actual q/self/parent/native."
- What to gate once a method can declare a field before it returns a merge:
  "distinct model-unit, construction-context and copied-context
  values with no caller-supplied input, caller override, explicit node
  access and lifetime/mutation independence".

Section 62 said of the node's fallback that it "is not settled here". That
sentence is withdrawn: the norm settles it, and the implementation does not
meet it. It is recorded as a defect, not as an open choice.

### Recorded

Four entries in `steps/defects.md`, each measured on `0a52fe7d` by a
scratch probe, none gated yet; each gets its row with its repair.

| Entry | What was measured |
| --- | --- |
| [T7-HOST-BODY](defects.md#t7-host-body) | A method with a statement before `return: merge(...)` is refused at the merge: `assignment value has unknown type`. Only a method whose whole body is that return is taken as returning a merge. |
| [T7-NODE-LEXICAL-LINKS](defects.md#t7-node-lexical-links) | A merge's node is built under the `node` of the method that gives the merge, and its body reads a free name's fallback at the unit's cell, baked in. By the norm the node's parent follows the place of the merge and the fallback follows the node's own links. Not observable while the entry above stands. |
| [T7-ACTUAL-FROM-ROOT](defects.md#t7-actual-from-root), made two obligations | With the limit taken off, the artifact runs its root natively and then through its graph. The native root stops the process (`a callable merge could not be built`): the root's `node` is empty. The walked root gives `walk error: UNSUPPORTED`: the retained machine operation is not executed by the walk. |
| [HELD-REFERENCE-NOT-ASKED-ALONG-CHAIN](defects.md#held-reference-chain) | A wrong value with no refusal. `outer` has its own `m`, with `v` 40, and calls `inner`, which calls a held definition reading `m\v`: 9, the unit's, where the norm gives 45. Natively and with the methods walked. Section 60 said in words that a reference is not asked along the chain; the wrong value was not in the record. |

A correction to what went in with section 62. The fixture
`unit_t7_actual_from_root`, the comment of its row and the translator's
comment at the refusal say that the root's body is walked. The artifact
runs the root natively as well, and the rows marked `WalkRoot` run it both
ways: the root has a native body. What the root lacks is this one
construction, in both of its bodies. Those three comments are corrected
with the repair, since their files are inputs of the gates.

**Next.** A method that does something before it returns a merge; the place
and the links of a merge's node, with the root's native body building it as
a method's does, and a walked body building it too; then the reference: its
absence, its admission through a held call, and its asking along the chain;
the conversion of a handed-on input; the library's ingress; the walked
consumer; the complete copy of a node built at run time and a node's own
contract route.

<a id="thirteenth-reply"></a>
## 64. Codex's thirteenth reply -12: the node's lexical source goes to the author; the written shape of a callable merge, audited

No translator, fixture or harness byte changes with this section, and no
gate is claimed for it. The gates of [section 62](#merge-actual) stand for
the same bytes.

### The reply

It answers the question of reading A against reading B, sent after section
63, and it corrects what section 63 took from the twelfth reply.

- "Do NOT default to reading A. There is a genuine documentary
  conflict at #composition that my previous reply did not resolve."
- "My twelfth reply's demand to use real selected links was not
  authorization to rebind all copied-body lexical references by names at the
  new construction site."
- "Nor does reading B authorize a newly invented persistent
  "context" graph. A genuine copy of existing reachable source
  Structures is ordinary graph copying; a newly fabricated side
  data/environment structure is not."
- Of `node\x`: "it is an explicit path through the selected node
  Structure, not an ancestor-search spelling for a free name. Where that
  particular Structure is proved to lack x, ordinary path resolution fails;
  do not search its ancestors as a fallback."
- Of the written shape: "Your merge(y:k; add) must be reconciled with
  those exact rules. Do not silently swap operands, promote the inner
  callable to the outer root, strip formals or treat the receiving header
  as construction. Record the exact emitted/source shape and distinguish it
  from model-first merge(add; y:k). Do not change tests solely to
  manufacture either reading."
- What goes on: "Continue the independent producer/earlier-statement
  and common native/walk construction work, but hold the disputed lexical
  reparenting/re-resolution and do not change normative texts or
  expectations to choose A."

### Withdrawn

Section 63 said of the node's fallback: "the norm settles it, and the
implementation does not meet it. It is recorded as a defect, not as an open
choice." That is withdrawn. What the fallback of a merge's node denotes,
the model's copied lexical state or a field of the place where the merge is
performed, is a question to the author. Codex asks it; its anchors, the
author's own words, what is measured and the two readings are in
[the question's file](../LMX_blog/q/merge-lexical-copy-and-root-placement.md).
The entry [T7-NODE-LEXICAL-LINKS](defects.md#t7-node-lexical-links) is
rewritten: its first wording named reading A as the norm.

What is not disputed stays a defect. The body of a merge's node reads the
live cell of the unit's field at a baked address. No copy of the model's
used lexical state is made at the merge, and the node sees a later change
of the field. That meets neither reading.

### What the question can be measured with

On `0781bf65`, translator `b450f0c014fde9c2`, scratch probes, none gated.

| Probe | Today |
| --- | --- |
| `make (int: other)` returns `merge(add)`, `add` reads the unit's `other`, 9; the root holds the result and calls it | 9 |
| the same, with `other: 11` in the root before the call | 11 |
| `make` with `int: other 50` before `return: merge(add)` | refused, [T7-HOST-BODY](defects.md#t7-host-body) |
| a returned nested definition reads the activation's own field `other`, 9; the root has no `other` and calls it | 9, the copy |
| the same with `other` a formal of the activation | 9, the copy |
| `merge(g)`, `g` holding a returned nested definition | refused: `a callable merge binds a name that is not a formal` |

The first two rows do not tell the readings apart. In a program of one
unit whose model stands in the root, the root owns the model's lexical
`other` and is the first caller of every chain: it gives the name, and a
caller's value comes before any fallback. The condition "no caller gives
`other`" needs a model whose lexical place is outside the chain of callers.
In one unit that is a held callable as the model of a merge, which is
refused today:
[T7-MODEL-ONLY-UNIT-METHOD](defects.md#t7-model-only-unit-method).

### The written shape, audited read only

`l2_t7_fill` takes as the model the one operand that names a method of the
unit, at any position. Every other operand must be `name: value` and binds
an int formal of the model. The header of the receiving place gives the
node's argument count, the formals it lacks must be bound, and a bound
formal leaves the node's interface.

| Written | Today |
| --- | --- |
| `return: merge(y: k; add)` and `return: merge(add; y: k)` | 6 and 6; the L1 of the two programs is the same byte for byte |
| `take: merge(y: 5; five)` and `take: merge(five; y: 5)` | 5 and 5; the L1 differs only in the order of two operands in the record of the actual retained for the walk |
| `(w: 1; y: 25)`, both shapes | refused: `unknown method` |
| `add5(1; y: 25)`, both shapes | refused: `more arguments than add5 has formals`; the book's illustration gives 26 |
| `q: merge(y: 5; add)` then `q\add(1; 2)` | refused: `unknown field path segment`; there is no wrapper with a nested method |

The book's `#composition` says otherwise at three places: the first
operand is the model; `merge((n: 5); addN)` puts the method inside the
Structure and calling the Structure does not run it; the declared header is
the type of the receiving place and a formal with a default stays passable.
The implementation is the rule the book had when T7 landed, and the plan of
`steps/merge-callable-r48.md`, section 4, to move the fixtures to the model
first and to refuse the data first was not carried out. The shape with the
data first is what the fixtures of `0a52fe7d` are written in, as the T7
rows before them. Nothing is changed by this audit. It is recorded as
[T7-DATA-FIRST-SHAPE](defects.md#t7-data-first-shape), and new rows are
written with the model first, where the value agrees with the book.

**Next.** A method that does something before it returns a merge, and one
construction of a merge's node for a native and a walked body, the root's
bodies included, with the node's parent and fallback left as they are
until the author answers. Then the reference: its absence, its admission
through a held call, and its asking along the chain; the conversion of a
handed-on input; the library's ingress; the walked consumer; the complete
copy of a node built at run time and a node's own contract route.

<a id="fourteenth-reply"></a>
## 65. Codex's fourteenth reply -12: the shape needs no author decision; a merge keeps the model's interface; the witness of one unit

No translator, fixture or harness byte changes with this section, and no
gate is claimed for it.

### The reply

It answers the audit of [section 64](#thirteenth-reply).

- The shape with the data first: "The data-first question does NOT need
  a new author decision under the current explicit #composition rules. But
  do NOT implement a general "data-first merge is forbidden"
  branch." And: "The existing code that picks the sole unit method
  at any operand position and turns the result into that method's root is
  the defect. A receiving callable place applies ordinary
  conversion/admission to the value actually constructed."
- The interface: "Model-first merge(add; y:5) must keep add's full
  callable interface." The three calls `add5(1; y: 25)`, `add5(1; y: 0)`
  and then `add5(1)`, giving 26, 1 and 6, "are REQUIRED positives.
  Therefore the T7 constructor/formation route you just measured still has
  interface debt when it strips a bound formal and builds only the unbound
  inputs."
- The fixtures: "do not silently swap operands and claim the original
  program now works. Where an old fixture intended specialization, introduce
  or migrate its explicit model-first spelling with a stated
  source/expectation change; keep direct tests for the original data-first
  shape and its actual wrapper/nested path". And of this slice:
  "Keep the new independent slice's model-first fixtures, but call
  default-only success a bounded case, not complete callable-merge
  support."
- The witness: "The statement that no caller-provided other is
  impossible in one unit is too broad." And: "Do not confuse a
  materialized graph field with an eligible caller binding at that source
  position."

### Withdrawn

Section 64 said that in a program of one unit whose model stands in the
root the condition "no caller gives `other`" cannot be met. That is
withdrawn. A variable is visible only forward: a call the root makes above
its own declaration of `other` has no caller's binding. The gated row
`unit_a3_caller_binding` already calls so.

### The witness, measured

On `0781bf65`, a scratch probe, not gated. `prep` and `bump` write the
unit's field by the explicit path `node\other`, 9 and 11. `make (int:
other)` returns `merge(add)` and is called with 50. `plain` only hands the
name on. The root calls `plain` twice above its own `int: other 9`, with
`bump` between, and once below.

| Call | Today | The model's copied state | The place of the merge |
| --- | --- | --- | --- |
| above the declaration, after `prep` | 9 | 9 | 50 |
| above the declaration, after `bump` | 11 | 9 | 50 |
| below the declaration | 9 | 9 | 9 |

The same natively, with the methods walked and with the root walked. The
11 shows by a run what section 64 had only read in the generated code: the
node reads the live cell of the unit's field. No expectation is set for
either reading: the probe becomes a row with the author's answer. Its
`other` at `make` is a formal; the variant with a field of `make`'s own
waits for [T7-HOST-BODY](defects.md#t7-host-body).

### Recorded

- [T7-DATA-FIRST-SHAPE](defects.md#t7-data-first-shape) now says what is to
  be done: the wrapper is ordinary composition and gets its producer and
  its path positive; a callable place admits the value actually built; no
  refusal by operand order; the fixtures that meant a specialization move
  to the model first with the change named.
- [MERGE-KEEPS-MODEL-INTERFACE](defects.md#merge-keeps-model-interface),
  new: the three required positives, refused today, and the node of a merge
  that keeps only the unbound formals.
- [T7-NODE-LEXICAL-LINKS](defects.md#t7-node-lexical-links) and the
  question's file carry the witness in place of the withdrawn sentence.

**Next.** Unchanged from section 64. The rows of that step are written
with the model first and are a bounded case: they call the node with the
defaults only.

<a id="merge-node-construction"></a>
## 66. One construction of a merge's node; a body before the returned merge; the root gives a merge (third slice, step four)

Codex's replies twelve to fifteen under -12 direct this step. It builds
what does not depend on the author's answer
([section 64](#thirteenth-reply)): under what the node hangs, and what its
body reads where no caller gives a name, are left exactly as they were.

### What is built

**One constructor.** The node of a merge is built by one function of the
generated module, `l2_t7_make_<site>`, for a native body and for a walked
one. A native body calls it with its own occurrence and the value each bound
formal has there (`l2_t7_write`). A walked body builds a step, `[prim,
record, contract, self, bound values]`, whose record names the primitive
entry over the same function, `l2_t7_construct_<site>` (`l2_rw_t7_build`).
Before this step the node was written inline into the native body only, and
a walked body kept the written merge as a machine operation it could not
execute.

**Where the node hangs.** As before: in the lexical space above the
performing body, which is that body's `node`. A body with nothing above it,
the root, is that space itself. At the root this chooses no reading of the
author's question: the model's lexical parent, the place of the merge and
the unit are one Structure there.

**A body before the returned merge**
([T7-HOST-BODY](defects.md#t7-host-body)). A method recorded with the merge
it returns runs the statements of its body and builds the node once, where
the body ends, with the value each bound name has there. Its `return` is
taken as a statement of the body by the merge recorded
(`l2_t7_return_stmt`): the check passes it by as it passes `return: model`,
the native body ends with the construction, and the walked body builds it
as the step of the return. Such a method is walked under `--walk-methods`
now. It stayed native before, without a word.

**A host's nested body**
([HOST-BUILDS-IN-NESTED-BODY](defects.md#host-builds-in-nested-body)),
found on the way and there before this step. A method that returns a nested
definition built its node at the end of the first nested body of its body,
a loop or an if, and returned it from there: a wrong value natively, with
no refusal, and the right one walked. `l2_emit_body_in` routed every body
of a host as the host's body. The host's body is the method's own now, and
a nested body of it is its statements.

**The root** ([T7-ACTUAL-FROM-ROOT](defects.md#t7-actual-from-root)). The
limit is taken off. The root's native body calls the constructor as a
method's does, and its walked body builds the step. Both obligations of the
twelfth reply are met by the one construction, with no constructor of the
root's own.

**A body that is always walked.** A definition nested in a method and
returned by it has no native body when it reads the method's names. It can
give a merge as an actual now. Before, its graph kept the merge as a
machine operation and the definition was refused: `a callable merge needs a
walkable body: retained machine operation has no interpreted
implementation`.

**A limit said in its own words**
([T7-HOST-NESTED-RETURN](defects.md#t7-host-nested-return)). A merge
returned from a nested body of its method is refused where it stands as
what it is, not as a value without a type.

### Measured

| Program | Before, on `0781bf65` | Now |
| --- | --- | --- |
| `unit_t7_host_body`: a field, a loop and an if before `return: merge(add; y: k)`; two nodes; under a caller's `other` 20; the first node again | refused: `assignment value has unknown type` | 18 and 10; 29; 19. Natively and with the method walked |
| `unit_t7_host_bound_field`: a field named like the bound formal, 7 | refused the same way | 8 and 8 |
| `unit_nested_definition_host_loop`: a loop and an if before the nested definition and its return | natively 7 where 9 is due, no refusal; walked 9 | 9 and 1, natively and walked |
| `unit_t7_actual_from_root`, moved to the model first: the root and a method give the same merge; under a caller's `other` 20; a second merge of the root; the first again | refused at the root's limit | 14 and 14; 25; 109; 14. The root natively and through its graph |
| `unit_t7_actual_in_definition`: a returned nested definition gives a merge as an actual; under a caller's `other` 20 | refused: the retained machine operation | 114 and 116; 125 |
| `unit_t7_host_nested_return`: a merge returned from an if of its method | refused: `assignment value has unknown type` | refused as a limit, in its own words: OPEN |
| The four `_walk` rows of the merges held and called | the method that returns the merge is native | it is walked: `WalkedMethods` names it |

The step's rows are written with the model first and call the node with
its bound formal left at its default. That is a bounded case, not the whole
of a callable merge:
[MERGE-KEEPS-MODEL-INTERFACE](defects.md#merge-keeps-model-interface)
stays open. `unit_t7_actual_from_root` was written with the data first and
was red; its source is changed to the model first and extended, and the
change is named in the fixture and in
[T7-DATA-FIRST-SHAPE](defects.md#t7-data-first-shape). No other row's
source is changed.

### The witness of the author's question, again

The probe of [section 65](#fourteenth-reply) gives 9, 11, 9 with this
step's translator as before it. Its variant with a field of `make`'s own,
`int: other 50` before `return: merge(add)`, can be run now: 9, 11, 9,
natively, with the root walked and with every method walked, `make` among
them. The calls come after `make` has returned. Both programs are kept
byte for byte in
[T7-NODE-LEXICAL-LINKS](defects.md#t7-node-lexical-links). The 11 is not
an expectation, and no row is made of either before the author answers.

### Replay

The step's translator against the committed one, on the 1706 translations
recorded by `fable_full_37`: exit, messages and the generated L1 are the
same on 1680 rows. Of the 26 others, 21 are units that build a merge's node
and differ in L1 only, by the constructor; four are hosts with a nested
body, `unit_make_adder_char`, `unit_walk_make_adder_char`,
`unit_recv_use_nested_dormant` and its `_walk`, whose nested body no longer
carries a construction; and `unit_t7_actual_from_root`, refused before,
translates.

The replay, the mutants and the focused runs used a build whose generated C
equals, byte for byte, that of the source committed with this step; the two
sources differ in one comment.

The changed and the new rows were run before the gates
(`fable_s4p_01`, `fable_s4p_02`): 81 rows and 2 rows; 79 pass, and the four
red ones are labelled OPEN rows, three of them known and
`unit_t7_host_nested_return` new.

### Mutants

Each is a copy of the step's translator with one change, built apart and
run on the step's fixtures three ways: natively, with the root walked too,
and with the methods walked too.

| Mutant | What the fixtures say |
| --- | --- |
| A nested body of a host is routed as the host's body again | `unit_t7_host_body` and `unit_nested_definition_host_loop` give a wrong value natively; with the methods walked they pass. |
| The native body hands 0 for a bound formal | `unit_t7_host_body` and `unit_t7_host_bound_field` fail natively and pass with the methods walked. `unit_t7_actual_in_definition` passes: no native body builds its merge. |
| The native body hands the formal as it was received | `unit_t7_host_bound_field` fails natively and passes walked. |
| The walked step hands 0 for a bound formal | `unit_t7_host_body` and `unit_t7_host_bound_field` fail with the methods walked and pass natively. `unit_t7_actual_in_definition` fails. |
| The walked step hands the formal as it was received | `unit_t7_host_bound_field` fails with the methods walked. |
| The primitive entry gives no node | With the methods walked the two host rows stop the process: `a callable merge was called outside its header`. `unit_t7_actual_from_root` stops with the root walked, `a dynamic call of a value that is not a Structure`, and passes natively. `unit_t7_actual_in_definition` stops the same way. |
| No place for a body with nothing above it | `unit_t7_actual_from_root` stops in the root's native body: `a callable merge could not be built`. The rows whose merges stand in methods pass. |
| The root's limit back | `unit_t7_actual_from_root` is refused. |
| The walked body of a method builds its returned merge as a statement too | The two host rows are refused: `root operation not walkable yet: merge`. |

Every mutant is killed by the fixture of a gated row, in the body it changes.

### Evidence

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_24` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_24` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_38` (full harness) | RED 39 of 1715. Against `fable_full_37` (RED 39 of 1707): FAIL→OK 1, `unit_t7_actual_from_root`, an OPEN row of the step before; OK→FAIL 0; added 8, of which seven green and the labelled OPEN row `unit_t7_host_nested_return` red; removed 0. |
| `build/l2_harness/fable_s4p_01`, `fable_s4p_02` (focused, before the gates) | 83 rows, 79 pass; see the replay above. |

Against the baseline `fable_full_01` (RED 126 of 1395), counted directly:
98 FAIL→OK, OK→FAIL 0, five red rows replaced, 325 added of which 16 red.
The 39 red rows are 23 of the baseline and 16 added: the five that
`fable_full_17` had above the baseline and eleven labelled OPEN positives.
The pre-gate hashes of the translator, the six fixtures and the harness
equal the live files and every staged copy (`tie.py`).

### Not claimed

- Under what the node hangs and what its body reads where no caller gives
  a name are unchanged:
  [T7-NODE-LEXICAL-LINKS](defects.md#t7-node-lexical-links) is open, and
  the author is asked.
- The interface of a merge's node still holds the unbound formals only,
  and the shape with the data first is still read as the one with the
  model first in the rows written so:
  [MERGE-KEEPS-MODEL-INTERFACE](defects.md#merge-keeps-model-interface),
  [T7-DATA-FIRST-SHAPE](defects.md#t7-data-first-shape).
- The method that receives a merge through a callable formal is native in
  every row: a method with a callable formal is outside what
  `--walk-methods` walks. The walked consumer is a later step.
- A merge binds a literal or a formal of the performing method. A field of
  that method as the bound value is still refused, as a limit.
- The body of a node is built anew at each construction, in the program's
  arena, as it was.

**Next.** The reference: its absence, its admission through a held call,
and its asking along the chain; the conversion of a handed-on input; the
library's ingress; the walked consumer; the complete copy of a node built
at run time and a node's own contract route. The node's lexical source
follows the author's answer.

<a id="constructor-guards"></a>
## 67. The constructor of a merge's node checked again what its step establishes: removed (Codex's sixteenth reply -12)

### The reply

"l2_t7_emit_construct ... emits `if: nargs != <site count> || refs
= 0 || refs[0] = 0 ... c.abort()` for the generated internal constructor
primitive. This is not an ordinary language/admission refusal. When the
constructor's transport shape/presence is established by the common
translator/step contract, rechecking it in this per-site helper and
aborting is redundant defensive programming". And: "Remove that
compiler-proven duplicate guard in the next safely bounded slice; do not
replace it with another per-site safety layer, shim or special error
policy." And: "Keep allocation/resource-failure contracts separate;
this is not an instruction to blindly remove every error check in the
repository."

### What was wrong, and what is changed

[Section 66](#merge-node-construction) introduced two checks that repeat
what the translator itself establishes. Both are mine, of that step.

- The primitive entry `l2_t7_construct_<site>` stopped the process when its
  operand count was not the site's, or its first operand was absent. The
  count and the presence of each operand are what the step naming the entry
  is built with (`l2_rw_t7_build`) and what the primitive's contract says.
- The constructor `l2_t7_make_<site>` stopped the process when the occurrence
  it was given was empty. A native body gives its own occurrence, which it
  has, and the walked step gives the occurrence of its activation.

Both are removed, with nothing in their place. The checks of a node or a
cell that could not be allocated stay: they are the contract of a failed
allocation, as before this step. I had copied the first check from the
constructor of a returned nested definition, `l2_mad_construct_<method>`,
which was there before and carries the same check still. It is not touched
by this section: the reply bounds the correction, and that guard is named
here so that it is decided on its own.

Coding instruction 12.2: "Do not add defensive runtime validation after
compiler metadata has already established an invariant merely to compensate
for missing type propagation."

### Measured

The translator against the committed one, on the 1714 translations recorded
by `fable_full_38`: exit, messages and the generated L1 are the same on
1687 rows; the 27 others are the units that build a merge's node, and
differ in L1 only, by the lines removed. No refusal changes: the refusals of
a merge that has no model, two models or a header that does not match stand
where they stood, at translation.

The route is pinned by the rows it had. Three mutants were built again on
this translator and run natively, with the root walked and with the methods
walked, on `unit_t7_host_body`, `unit_t7_actual_from_root` and
`unit_t7_actual_in_definition`: the native body handing 0 for a bound
formal fails the first natively and passes it walked; the walked step
handing 0 fails the first walked and the third, and passes the first
natively; the primitive entry giving no node stops the first walked, the
second with the root walked and the third, and passes the first two
natively. As in section 66.

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_25` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_25` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_39` (full harness) | RED 39 of 1715. Against `fable_full_38`: FAIL→OK 0, OK→FAIL 0, added 0, removed 0, no message of a red row changed. |
| `build/l2_harness/fable_s5p_01` (focused, before the gates) | 33 rows, 31 pass; the two red ones are labelled OPEN rows. |

The pre-gate hashes of the translator and the harness equal the live files
and every staged copy (`tie.py`).

### Kept in view

The reply names what the step of section 66 does not show. Passing a formal
that has a default is legal and not built
([MERGE-KEEPS-MODEL-INTERFACE](defects.md#merge-keeps-model-interface)).
A node built when the program runs is not necessarily walked. The root's
native body is shown for these witnesses, and that does not certify every
construct of a root. The obligations of the body and field producer, of
mixed formation, of the reference, of conversion, of ingress and of the
complete copy stand.

**Next.** As in section 66.

<a id="reference-among-free-names"></a>
## 68. The reference among the free names: asked along the chain, left out where a site does not need it, admitted by the declaration it carries (Codex's seventeenth reply -12)

### The reply

"YES: apply the same compiler-proven invariant cleanup to
l2_mad_construct_<method> in the next safely bounded slice. The older
origin of identical redundant header/parent guards is not an exemption from
the author's general rule. Verify the source/host relation at translation
and preserve the walked returned-definition witnesses."

"YES: ADMIT_AS should preserve an ABSENT evaluated operand at this
forwarding edge." And: "An absent result has no candidate value to admit:
return ordinary OK with the result still absent, without creating a view,
registering correspondence, throwing implements-NO, storing a value or
fabricating null. A PRESENT non-reference retains the existing
receiving-contract behavior; this is not permission to admit arbitrary
scalar values as Structures. A present reference whose payload is null
remains PRESENT under the existing null-reference route. Do not use payload
zero to infer absence."

"The reference plan follows the same universal value/presence rule as
numbers: pure forwarding preserves absence; the consuming reader forms its
value from ordinary sources; current caller bindings precede the actual
occurrence's lexical fallback; a present incompatible binding is an
admission failure, not absence."

The reply lists seven required witnesses. They are named with their rows
under [Witnesses](#reference-witnesses) below.

### What is changed

Whether an input is formed does not depend on how its value is
represented. Before this step that held for a number only.

1. **A method that does not read a name only hands it on, a reference as a
   number** (`l2_dyn_fwd`). The input stays its entry of the call's
   references through the method's activation and goes on as it is,
   possibly absent. Before, a reference was formed where the chain starts,
   from the lexical source of the method called there, and travelled
   present.
2. **An entry handed on is admitted as the value it carries, where it
   carries one** (`l2_admit_entry`). The generated text admits under a test
   of the entry itself; an absent entry is admitted to nothing.
3. **A call site leaves out a reference it does not need**, as it leaves
   out a number. The limit `an input that is a reference, of a callable
   this call does not give, is not left out yet` is removed
   (`l2_site_needs`).
4. **A held call asks its model's references along the chain of callers**
   (`l2_dyn_site_held`). A name the model needs that the calling method
   does not bind becomes the method's own handed-on input. A named
   Structure of the unit, or an eternal branch, is reached through the unit
   and asked of no one, as at a call of a method.
5. **What the calling method gives is admitted to the model's use**, as a
   call of a method admits a hidden input: natively (`l2_prep_held_call`)
   and walked (`l2_rw_mad_call`), with its source recorded in the fixed
   point. A reference of another declaration than the one the model's
   lexical source names is a candidate and no longer a limit. The limit `a
   caller's own reference under a held callable's free name is not admitted
   to its use yet` stays only where the model's input has no schema to
   admit to: a held callable under the name.
6. **A Structure a returned definition takes from its host is a free name
   as any other.** It was never asked along the chain: a caller's binding
   two methods above the held call was lost with no refusal. Given as a
   Structure of the capture's own type it is admitted as itself, as before
   (`l2_held_cap_same`); anything else the method gives, a Structure of
   another declaration or an input it only hands on, goes through the
   ordinary admission.
7. **An input with no declaration in the method's sight has no schema, and
   the declarations that reach it are recorded.** Such an input is one the
   method can only hand on. The fixed point records what each site gives it
   (`l2_dyn_site_callee`, `l2_input_undeclared`), and where its value
   reaches a reader's schema it is admitted by the declaration it carries,
   among those recorded (`l2_hidden_emit_admit`, `l2_d105_place_sources`),
   natively and walked. Where nothing is recorded the value carries no
   layout to tell and the positional admission stands, as before.
8. **The walker's admitting instruction keeps an absent operand absent**
   (`lmx_walk_admit_op`). Before, an absent operand and a present value
   that is no reference were one refusal, INVALID. They are split: absent
   returns ordinary OK with the result absent; a present value that is no
   reference stays INVALID; a present reference that holds nothing stays
   present.
9. **The constructor of a returned nested definition does not check again
   what the translation establishes** (`l2_emit_mad_construct_one`). The
   check of the count and presence of its operands and the check of the
   source occurrence's parent are removed, with nothing in their place. The
   relation it relied on, that the model is recorded under the method that
   returns it, is verified once where the constructor is written. The
   checks of a node or a cell that could not be allocated stay.
10. **A merge's node reaches a cell the unit holds in a nested body along
    the unit's own edges** (`l2_rw_cell`, `l2_emit_graph_unit_place`). The
    node's constructor has none of the aliases the unit's constructor names
    its holders by. The unit is complete when a merge runs. This is
    [T7-ACTUAL-REFERENCE](defects.md#t7-actual-reference), and item 5 needs
    it: with the admission recorded at a held call the model reads the name
    through its schema's own Structure, which is such a cell.

### What the step got wrong on the way

These were measured on bytes of this step that were never committed.

- The first version of item 4 refused a capturing definition called from a
  method that binds nothing: `a caller's binding of a held callable's free
  name is of another type`. The committed translator translates that
  program, and no gated row has its shape, so the replay of every recorded
  translation showed nothing. A probe of the smallest program of each kind
  of name the rule newly reaches found it. Row `unit_held_capture_chain`
  now has the shape.
- With the chain built and item 7 not yet, the last method before the
  reader admitted the handed-on Structure by position. A Structure with the
  field at another position gave 6 for 45: its first field was read. A
  Structure with no such field was accepted and gave 6. Both are refused or
  right now, and the rows below pin both.
- Recording the admission at a held call made
  `unit_t7_reference_held` stop at the limit of item 10. The replay showed
  it; item 10 is the repair.

<a id="reference-witnesses"></a>
### Witnesses

| The reply's witness | Rows |
| --- | --- |
| An absent reference through at least two forwarding methods and an ADMIT_AS edge reaches the actual reader's lexical source. | `unit_held_capture_chain`, `unit_held_capture_chain_walk`: no caller has the name, two methods hand it on, the definition reads its node's copy, 35. With the committed kernel the walked row stops at INVALID. |
| A present null reference is not replaced by that lexical value. | `unit_site_hidden_null_chain`, `unit_site_hidden_null_chain_walk`: 7, where the unit's Structure would give 11. `lmx_walk_admit_selftest`, six new checks. |
| A supplied compatible candidate of a different declaration/layout reaches its own selected field, native and genuinely walked. | `unit_held_reference_chain` and `_walk`: 45, 65 through two methods, 75 at the held call itself. `unit_held_capture_chain` and `_walk`: 25 and 45. `unit_nested_definition_structure_override` and `_walk`: 45. |
| A supplied incompatible candidate fails by ordinary Consumer-relative admission before use. | `unit_nested_definition_structure_other_refused` and `unit_held_capture_chain_other_refused`: `implements is false in function argument`, at translation. |
| A site which does not supply that alternative's reference preserves absence. | `unit_callable_formal_site_names_reference`, `unit_callable_formal_site_reference_forwarded`, `unit_callable_formal_site_reference_unasked`. |
| An unavailable required input with no eligible fallback is still refused at its real formation boundary. | `unit_reference_required_unbound_refused`: `unbound dynamic input box`, at the root's call. |
| Existing thrown/stop/admission-failure behavior remains unchanged. | `lmx_walk_admit_selftest`: a throw of the operand goes on with its own status; a present number is still no candidate. The full gate, row for row. |

### Mutants

Each was built from the bytes of this step and run natively (N), with the
root walked (R) and with the methods walked (W).

| Mutant | Changes | Result |
| --- | --- | --- |
| kernel `nullabsent` | a present null reference is taken for absent | `unit_site_hidden_null_chain` W stops; selftest: two checks fail |
| kernel `fabricate` | an absent operand becomes a present null | `unit_held_capture_chain` W stops; selftest: one check fails |
| kernel `numberok` | a present value that is no reference passes | selftest: one check fails |
| `nochain` | a held call asks only a number along the chain | `unit_held_reference_chain` and `unit_held_capture_chain` red in N, R, W |
| `noflow` | what reaches an undeclared input is not recorded | `unit_held_capture_chain` red in N, R, W; `unit_held_capture_chain_other_refused` translates |
| `natpos` | the native body admits an undeclared input by position | `unit_held_capture_chain` red in N and R |
| `walkpos` | the walked body admits it by the positional primitive | `unit_held_capture_chain` W stops |
| `nullabs` | a method handing an entry on takes a present null for absent | `unit_site_hidden_null_chain` red in N and R |
| `natnoadmit` | the native held call hands a reference unadmitted | `unit_held_reference_chain` and `unit_nested_definition_structure_override` stop in N and R |
| `walknoadmit` | the walked held call hands it unadmitted | the same two rows stop in W |
| `capsame` | every capture a caller gives is taken for its own type | `unit_held_capture_chain` red in N, R, W |
| `t7unit` | a merge's node names the unit itself for a held cell | `unit_t7_actual_reference` and `unit_t7_reference_held` stop |
| `sitegive` | a reference a site does not need is formed all the same | `unit_callable_formal_site_reference_unasked` does not translate |
| `refabsent` | a required reference with no source is handed absent | `unit_reference_required_unbound_refused`: another message |

Three results are narrower than they look. `sitegive` passes
`unit_callable_formal_site_names_reference` and
`unit_callable_formal_site_reference_forwarded`: the callable given there
does not read the reference, so a reference formed all the same changes no
value. It is told only by the third row, where the caller's own Structure
does not fit, and there the mutant fails at translation, by an internal
error, and not by a wrong value. `natnoadmit` and `walknoadmit` pass the
shapes where the candidate came through a method that admitted it to the
same schema: the earlier admission serves the reader. They are told by the
shapes where the method that makes the held call has the candidate itself.
`natpos`, `nullabs` and `natnoadmit` pass the walked variant, and `walkpos`
and `walknoadmit` the native ones: each route has its own mutant.

### Measured

The translator against the committed one, on the 1714 translations recorded
by `fable_full_39`: exit, messages and the generated L1 are the same on
1545 rows; 164 differ in L1 only; five change their message. Four of the
five are the rows that turn green, and the fifth is the refusal that now
names the ordinary admission.

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_26` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. `lmx_walk_admit_selftest`: 46 checks, none failed. |
| `build/l3_selftest/fable_l3_26` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_40` (full harness) | RED 35 of 1725. Against `fable_full_39`: FAIL→OK 4 (`unit_callable_formal_site_names_reference`, `unit_nested_definition_structure_override` and its `_walk`, `unit_t7_actual_reference`), OK→FAIL 0, added 10, all green, removed 0, no message of a red row changed. |
| `build/l2_harness/fable_s6p_05` (focused, before the gates) | 180 rows, every row the replay showed changed and the new ones; one red, the labelled OPEN `unit_t7_host_nested_return`. |
| `build/l2_harness/fable_s6p_06` (focused, before the gates) | The seven rows touched after it; all pass. |

The pre-gate hashes of every changed path equal the live files and every
staged copy (`tie.py`).

The committed translator on the new rows, outside the gate, natively, with
the root walked and with the methods walked: `unit_held_capture_chain`
gives 83, the caller's Structure lost with no refusal;
`unit_held_reference_chain` is refused by the limit item 5 removes.

### Kept in view

- **A reference read with no declaration in sight is not built.** The
  method of `unit_reference_required_unbound_refused` that has the name and
  calls down the chain would give 31; with the root's call removed the unit
  is refused at the read, `a field path`. So the row shows the refusal
  where the chain starts and not the positive beside it
  ([FREE-REFERENCE-NO-DECLARATION](defects.md#free-reference-no-declaration)).
- **Three kinds of name the chain rule newly reaches are probed and are not
  rows yet.** A Structure field of the host itself (35, and 55 with a
  caller's own); a typed reference of the unit, with a caller's reference
  to another declaration two methods above (9 and 65); a definition that
  writes through the reference (the caller's Structure is written, the
  unit's is not). Each passes natively, with the root walked and with the
  methods walked, on the translator of `fable_full_40`; the committed
  translator gives a wrong value on each, with no refusal. Outside the gate
  they are no coverage: they become rows in the next slice.
- **A consumer with a callable formal is not walked.** The three site rows
  run natively and with the root walked. With the methods walked they are
  outside the walkable subset, as before.
- **A captured Structure used whole is refused**, as before (item 738). The
  witness of a present null therefore uses a reference of the unit, which a
  method can compare with nothing.
- **An incompatible candidate is refused where it is admitted to the
  reader's use**, the held call, and not where its caller gives it.
- **A by-name admission that fails when the program runs** stops the
  process natively and throws `implements` walked. That is as before this
  step for a hidden input with a declaration in sight
  (`l2_d105_emit_source`); the step adds a route to it and not the
  difference. Whether a program reaches it was not measured.
- The lexical source of a merge's node waits for the author. G5 stays OPEN.

**Next.** The receiving-edge conversion of a handed-on input; the library
ingress; walked consumers with a callable formal; the complete copy of a
node built when the program runs and its own contract route; then the open
merge obligations of sections 64 to 66.

<a id="dynamic-admission"></a>
## 69. The admission of a dynamic candidate where an input is formed is the forming method's implicit `implements` (Codex's eighteenth reply -12)

### The reply

"Q2: build the reachability witness NOW as connected admission work, not
parked behind receiving-edge conversion. I read l2_d105_emit_source and
l2_emit_model_admit: implicit_throw=0 leads to the exact invariant abort
you reported. A genuinely runtime-failable ordinary admission must follow
the same implicit implements failure in native and walked execution."

"First distinguish YES/NO/UNKNOWN and prove which supported source can
reach that branch. Do not build an invalid-memory witness merely to force a
failure, and do not reinterpret UNKNOWN as proved incompatibility or assume
positional acceptance without proof. If a particular admission is genuinely
compile-time guaranteed, a duplicate invariant abort is unnecessary;
document that proof rather than retaining defensive validation."

"Do not mechanically flip implicit_throw 0 to 1 while passing the CALLEE
index as the failure context. l2_d105_emit_source currently passes idx into
l2_emit_model_admit. Input formation happens in the CURRENT caller before
callee entry; failure must use that activation's correct result/status ABI,
catch location and cleanup/publication path. Keep the receiving-model
context distinct from the executing failure context."

"Q1: YES, the program is valid when the callers supply an admissible
Structure under box. Add the positive returning 31 beside
unit_reference_required_unbound_refused, native and genuinely walked; keep
FREE-REFERENCE-NO-DECLARATION OPEN/G5-blocking until it passes." That is the
next slice; this section is Q2 and the three probe rows.

### What reaches the branch

The admission of a value to a Structure input, as the native body writes
it (`l2_emit_model_admit`), has three outcomes when the program runs.

- The value carries a layout that is among those the translation records
  for the place it was read from: the correspondence of that layout is
  recorded. YES.
- The value carries a layout that is not among them: UNKNOWN. I have no
  program of one translation that reaches this. An ingress from another
  translation would.
- The value carries no layout. A letter is such a value. It is checked
  against the whole receiving model by position: YES or NO.

Before this step every outcome but the first stopped the process:
`lmx: invariant: an admission by name was refused`. The walked instruction
throws `implements` there. Three supported programs reach the third
outcome, measured on the committed translator `43140744`.

| Program | Native | Walked |
| --- | --- | --- |
| A letter given through an opaque formal to a Structure formal, with a handler in the forming method. | the process stops | the handler takes it |
| The same with no handler. | the process stops | the process stops: `a callable that cannot throw reported a status`. The forming method was not recorded as one that can throw. |
| A letter under a free name, through two methods that only hand it on, beside a caller whose Structure of a known declaration reaches the same input. This is the route section 68 added. | the process stops | the handler takes it |

### What is changed

1. **The admitting text takes the method whose activation executes it**
   (`l2_emit_model_admit`, its last input). Its first input stays the
   context the receiving model is found in, which for a hidden input is
   the callee. Where the candidate is a dynamic one a refusal is the
   implicit `implements` of the executing method, with that method's
   statuses, handlers and publication.
2. **Which candidate is a dynamic one is said in one place**
   (`l2_d105_place_dynamic`, `l2_d105_dynamic`). A reference place holds
   what was given to it: an input of the method, an own reference, a field
   bound when the program runs, a call's result, a candidate with no
   evidence at all. A Structure a merge or a declaration made, held by
   value, is that one and no other; so is direct producer evidence, a
   named Structure or the leaf of a path.
3. **The method that forms an input from a dynamic candidate is recorded
   as one that can throw**: for an explicit actual in the check of the
   call, for a hidden input in the fixed point, at a call of a method and
   at a held call. This also repairs the walked uncaught case.

A candidate that is not dynamic keeps the text it had, the stop of the
process included. For such a place the stop is unreachable: the place
holds the Structure its declaration or merge made, and the layouts of that
Structure are the ones the translation records for it. The text is one
emitter's for both kinds and I have not split it in this step. That stop is
a duplicate of the proof and is the next cleanup; it is named here so that
it is not taken for a decision to keep it.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_admit_dynamic_actual_catch`, `_walk` | The handler of the forming method takes the refusal, 42. The callee is not entered. The candidate is produced once for each call, before it is admitted. A refused admission records nothing: a second call is refused as the first, and the letter is then admitted to a formal of its own declaration. |
| `unit_admit_dynamic_actual_context`, `_walk` | The callee declares a throw of its own. The refusal is the forming method's `implements`, taken by its handler of that name and not by its handler of the callee's name: 43, not 44. |
| `unit_admit_dynamic_actual_uncaught`, `_walk` | With no handler the refusal leaves the forming method and the root; the Message is stopped with no value, its failure counted, thrown 2. The process is not stopped. |
| `unit_admit_dynamic_hidden_catch`, `_walk` | Under a free name through two methods that only hand it on: refused where the last of them forms the definition's input, taken by the handler of the method that received the letter, 42. The definition is entered twice, by the two calls that are admitted. |

Where the methods are walked, a method that declares a throw and the
method that receives the letter stay native; the forming methods are
walked, and the rows pin which is which.

Three rows that section 68 left as probes are rows now, natively and with
the methods walked: `unit_held_capture_host_field`,
`unit_held_reference_typed_chain`, `unit_held_reference_write_chain`.

### Mutants

| Mutant | Changes | Result |
| --- | --- | --- |
| `abort` | a dynamic candidate's refusal stops the process again | the three catch rows and the uncaught row stop natively; the walked variants pass |
| `calleectx` | an explicit actual's refusal is thrown in the callee's context | `unit_admit_dynamic_actual_context` red natively: the handler does not take it |
| `hiddenstatic` | a hidden input's candidate is never dynamic | `unit_admit_dynamic_hidden_catch` stops natively |
| `actualstatic` | an explicit actual's candidate is never dynamic | `unit_admit_dynamic_actual_catch` and the uncaught row stop natively |
| `nomark` | the forming method is not recorded as one that can throw | the uncaught row does not compile |

`calleectx` is told by behaviour only where the callee can throw too: on
the other rows the emitter's own check refuses the translation, which is a
check of the translator and not of the program. `nomark` passes the rows
whose forming method has a handler: a refusal taken inside the method needs
no way out of it. The walked variants have their own route, which this step
does not change.

### Measured

The translator against the committed one, on the 1724 translations recorded
by `fable_full_40`: exit and messages are the same on every row; 76 rows
differ in the generated L1 only, by the methods that can now throw.

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_27` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_27` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_41` (full harness) | RED 35 of 1739. Against `fable_full_40`: FAIL→OK 0, OK→FAIL 0, added 14, all green, removed 0, no message of a red row changed. |
| `build/l2_harness/fable_s7p_02`, `_03`, `_05` (focused, before the gates) | The 76 changed rows and the new ones; all pass after two corrections of the walked pins. |

### Found beside it, measured, not repaired

- **A letter held in a typed place is refused where it should be
  admitted.** A letter received into a reference of its own declaration and
  given to a consumer of another declaration that reads only a field both
  have is refused: by position against the whole receiving model. Its
  correspondence should come through the declaration of the place it is
  held in. Natively and walked alike, and since this step an ordinary
  `implements` in both
  ([TYPED-PLACE-LETTER-READMISSION](defects.md#typed-place-letter-readmission)).
- **Four refusals at translation whose class I have not settled**, put to
  Codex: the result of a call of opaque type given directly to a Structure
  formal (`implements is false in function argument`, while the same value
  through a local or a formal is admitted when the program runs); a
  candidate chosen when the program runs among two declarations, one of
  which does not fit, refused for the possibility; a caller's opaque
  reference under a free name the reader declares as a typed one
  (`incompatible entry signature`); a letter returned through an opaque
  formal as a typed result (`implements is false in return value`).

**Next.** A path through a free name that nothing in the method's sight
declares ([FREE-REFERENCE-NO-DECLARATION](defects.md#free-reference-no-declaration)),
with the rows the reply names; the duplicate stop of a candidate that is
not dynamic; then the receiving-edge conversion and the rest of the order of
section 68.

<a id="free-name-path"></a>
## 70. A path through a free name that nothing in the method's sight declares (Codex's eighteenth and nineteenth replies -12)

> Corrected by [section 71](#no-ceiling). The search of this section had fixed ceilings, which are gone. The
> refusal where two declarations give a used field different types is a limit and no rule: its two rows are
> required positives now, under other names.

### The replies

The eighteenth: "Q1: YES, the program is valid when the callers supply an
admissible Structure under box." "#dynamic:702-704 applies to a FREE NAME
irrespective of whether its value is consumed directly or is the root of a
structural path. #admission/#fields then govern the used box\v path and its
exact field/type. Requiring a lexical declaration just for a
reference/path, while allowing the same caller-supplied mechanism for a
number, would be an invented type-specific exception." "This does NOT
authorize guessing a new contextual type, adding a hidden interface
Structure or finding field names during execution. Obtain the input's
physical type/source/layout evidence through the existing fixed point and
supplied typed Structures; record the Consumer's used path and resolve its
source/field correspondence during translation. Do not mistake a receiving
requirement for actual layout."

I put the design to Codex before building it: among the declarations that
reach such a name, take one as the coordinate space of the method's paths
(A), or give the method an instruction of its own that finds each field in
the value's own layout (B). The nineteenth reply: "A is within the earlier
ruling as an EXISTING COORDINATE SPACE ONLY, under proof; B is not mandatory
and a new opcode is not needed merely to duplicate existing correspondence
machinery." It adds that this does not mean picking any first candidate and
declaring its entire type the requirement. "Resolve r's used paths first.
Choose a
reachable existing declaration which supplies a proved coordinate/type
witness for those paths, then use the existing Consumer-relative
correspondence. Unused fields/methods of that anchor impose no
requirements. Selection must not make accepted programs/results depend on
unit order, unused extra fields, or which admissible candidate happened to
be chosen as anchor. If the first reaching declaration lacks v, that is not
permission to make r or every other candidate invalid; find a suitable
existing coordinate witness or retain an honest implementation limit where
none is established." "The chosen declaration is not the actual candidate's
layout. The current supplied value and its verified correspondence
determine its physical field, LAST versus explicit ordinal and primitive
type; existing conversion rules apply, not the anchor's bytes reinterpreted
as another type. A missing field or incompatible consumed type is ordinary
admission failure."

### What is built

1. **The coordinate space of a method's paths through such a name**
   (`l2_anchor_close`). The name is a hidden input with no schema of its
   own. Once the fixed point has closed what each site hands, the
   translation collects the named declarations that reach the input
   (`l2_anchor_reach`): what a merge of one Structure made in a caller's
   own field, what a site records for a place, and what reaches every
   place handed on to it, along the edges the fixed point recorded,
   against their direction. Among them, one that has every path the method
   uses, each to its end (`l2_anchor_covers`), is the coordinate space of
   those paths. The input's schema is that declaration
   (`l2_input_schema`), and the sites are visited once more, so that what a
   site records by the schema of the input it hands to is recorded: the
   edge, the admission, the method that can throw.
2. **It is a coordinate space and no type.** A Structure of another
   declaration is admitted to it by the paths the method uses, as to a
   declared requirement: the existing admission by the consumer's uses and
   the existing correspondences of fields. Fields of the chosen
   declaration that the method does not use ask nothing of a candidate.
   The model of the input is not changed (`l2_input_model`): a copy of the
   Structure under such a name is refused as before, and nothing reads the
   chosen declaration as the type of the name. Nothing of this exists when
   the program runs.
3. **Which declaration is taken does not matter.** Those that have every
   path are admitted to one another by those paths the same way in either
   direction, as long as they agree in each. The first in the unit's order
   is taken. Where two of them disagree, a field the method reads being of
   one type in one and of another in the other, none is taken: the path is
   refused where it stands, with the same words in either order of the
   declarations. Taking the first there would refuse the second by the
   first's type, and the other order would refuse the other.
4. **A declaration that has not a path the method uses is no coordinate
   space.** It is refused by the ordinary admission where it is handed to
   the reader. Where no coordinate space is established the path is
   refused where it stands (`l2_free_path_refused`), at each of the four
   sites that check a path: a read in an expression, a path that is the
   whole of a value, a path of more than one step, a write.
5. **A write through the path is checked once its root is typed.** The
   check of a written path ran in the first pass, before the fixed point,
   and refused such a root. It waits now as an assignment's check does
   (a wait record of its own, `l2_wait_run`).
6. **The root of a written path is read.** In value position the root of a
   path is an atom and the scan of free names meets it; the head of a
   statement is one text, and its root was read only in the model of a
   callable merge. A method that only writes through a name therefore took
   no such name from its caller. For a name nothing declares the write was
   refused, `unknown field path root`. For a name the unit declares the
   write went to whichever declaration of that spelling the path's
   resolution found: with a caller that has a Structure of that name of its
   own, the resolution found that caller's own field, the generated code
   named a variable of another function, and the C compiler refused it. The
   root of a head is now read as the atom would be
   (`l2_scan_head_root`), and the record of the name knows the head as the
   place it is read (`l2_source_text`); without the second the input was
   taken for one the method only hands on.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_free_path_read`, `_walk` | The program of the defect: 31 through a method that only hands the name on, 41 with the field at another position, 51 from a caller that calls the reader itself. |
| `unit_free_path_order`, `unit_free_path_order_swapped`, `_walk` | The same results, 21 and 31, with the declaration that has unused fields first and the callers above the reader, and with the reader above the declarations and the thin declaration first. A candidate that lacks the unused fields of the chosen declaration is admitted. |
| `unit_free_path_first_lacks`, `_walk` | A declaration without the field, declared first, reaches another method's name only and decides nothing for this one: 31 and 52. |
| `unit_free_path_other_refused`, `unit_free_path_other_chain_refused` | A Structure without the field is refused by the ordinary admission, `implements is false in function argument`: at its giver's call of the reader, and at the call of the method that hands it on. |
| `unit_free_path_write`, `_walk` | A write changes the caller's Structure, through a forwarder and with the field at another position: 4142, 808. A method that only writes: 13, 14. |
| `unit_field_path_write_only`, `_walk` | The same defect for a name the unit declares. The root's call writes the unit's Structure; a caller's own Structure is written from a caller that has one, and the unit's is as the root left it. |
| `unit_free_path_null`, `_walk`; `unit_free_path_null_read_walk` | A reference that is present and holds nothing stays present: 11, 22, and 7 where the reader asks. A read through it stops where a read through a declared reference does. Walked, that is the walker's stop, exit 3; natively the row pins the text of the same boundary in the reader. |
| `unit_free_path_types_differ_refused`, `_swapped_refused` | Two declarations give the field different types: the same refusal at the same statement in either order. |
| `unit_free_path_none_refused`, `_write_none_refused`, `_deep_none_refused` | No declaration that reaches the name has the field: the words of the limit, at a read, at a write that waited, at a path of two steps. |
| `unit_free_path_letter`, `_walk` | A letter under the name beside a caller whose Structure fits: refused when the program runs, where the reader's input is formed, as the forming method's `implements`; the reader is entered once. |
| `unit_free_path_typed_place`, `_walk` | Through an opaque formal and a typed reference: a letter is refused where the reference takes it, 42; a Structure made from a declaration reaches the name by that declaration, 9. |
| `unit_free_path_two_readers`, `_walk` | A method that hands the name on and reads another field of it has its own coordinate space: 341, and 31 for a reader given a Structure without that field. |
| `unit_free_path_argument`, `_walk` | The path as the argument of a call and by its address: 9135, 12145. |
| `unit_free_path_deep`, `_walk` | A path of two steps: 31, 42. |

Where the methods are walked every method of these fixtures is walked,
except the one that receives the letter and the one with the typed
reference; the rows pin which.

`unit_reference_required_unbound_refused` stands as it was: with no caller
that has the name the chain is refused where it starts.

### Mutants

Each is a copy of this translator with one change, built apart. Its
translations of the 34 rows of the slice (`fable_s8_02`) are compared with
this translator's, and every fixture whose generated text changed is run
natively, with the root walked and with the methods walked.

| Mutant | Changes | Result |
| --- | --- | --- |
| `coversany` | any declaration that reaches the name is its coordinate space | the two `other` rows and the three `none` rows are refused with other words at other places |
| `nodiffer` | declarations that disagree are not told apart | the two `types_differ` rows are refused with other words: in one order `implements is false` at the other caller's call, in the other order the read asks for a conversion from the first declaration's type |
| `noedges` | what reaches a place handed on is not followed | every positive is refused with the words of the limit |
| `noown` | what a merge makes in a caller's own field is no candidate | the same |
| `nosecond` | the sites are not visited again once the coordinate spaces are found | `_letter`, `_null` and `_null_read` do not compile |
| `nowait` | a write is checked before its root is typed | `_write` is refused, `unknown field path segment` |
| `noreplay` | the waited write is never checked | `_write_none_refused` is refused with other words |
| `nohead` | the root of a written path is not read | `_write` is refused; `unit_field_path_write_only` does not compile |
| `nosource` | the head is not where the name is read | `_write` and `unit_field_path_write_only` do not compile |
| `norefuse` | a path with no coordinate space is not refused by the common words at any site | the three `none` rows and the two `types_differ` rows are refused with other words |
| `nochain` | the same at a path of more than one step only | `_deep_none_refused` is refused, `unknown field path segment` |
| `novalue` | the same at a path that is the whole of a value only | the two `types_differ` rows are refused, `unknown field path root` |

`bestlast` is a control and no mutant to kill: it takes the last
declaration that has every path where the translator takes the first. The
generated text of 14 rows changes; every one of the seven fixtures passes
natively, with the root walked and with the methods walked.

`coversany` can be told only by a refusal's words and place. In a program
that is accepted every named declaration that reaches the name has every
path, so taking any of them is taking one that has. `nodiffer`,
`noreplay`, `norefuse`, `nochain` and `novalue` are told by words too: the
programs are refused either way, and what the rows hold is which refusal is
said, and where.

One check is reached by no row: the fixed point runs again after the waited
checks, the rows of the coordinate spaces are found again, and a coordinate
space lost between the two is an internal error. I have no program in which
the second run finds less than the first.

### Measured

The translator against the committed one (`bfeef8cc`), on the 1738
translations recorded by `fable_full_41`: exit, messages and the generated
L1 are the same on every row.

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_28` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_28` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_42` (full harness) | RED 35 of 1771. Against `fable_full_41`: FAIL→OK 0, OK→FAIL 0, added 32, all green, removed 0, no message of a red row changed. |
| `build/l2_harness/fable_s8_01`, `_02` (focused, before the gates) | 189 rows with the neighbours of the slice, then the 34 rows of the slice on the final bytes: the new rows pass; the six red rows of the first run are red in `fable_full_41` with the same words. |

### What is not built

Coverage of the implementation, no restriction of the language. Each is a
refusal at translation, located.

- **A value with no layout alone.** Where only a letter, or only a typed
  place whose value arrives opaque, reaches the name, no coordinate space
  is established: `a path through a free name that no declaration reaching
  it gives its fields to is not built yet`. A place's own declaration, a
  typed reference's or a formal's, is not taken for one: what the place
  holds was given to it, and a formal's value was admitted by its method's
  uses only. With a letter that route is the next item below.
- **A Structure a declaration makes in a method** (`Model: box`) as the
  giver is not followed as a candidate: the path is refused with the words
  of the limit. The declared analogue is refused too, at that declaration:
  `a Structure-typed field in a method`. Measured on `bfeef8cc`.
- **A path of two steps where the candidates' inner Structures are of two
  declarations**: `an admission to a Structure type through a Structure
  field of another type`, as for a declared formal reached through a
  forwarder. Measured on `bfeef8cc`.
- **A copy of the Structure under such a name** (`c: merge box`): `unknown
  merge operand`. The words are an older refusal's and read as a rule;
  it is a limit. Handing the whole Structure on to a declared formal works,
  and each declaration that reaches the name is admitted there by that
  formal's uses; measured by two probes outside the gate, a positive and a
  refusal.
- **A returned definition that itself reads a name nothing declares**: `a
  callable merge binds a name that is not a formal`, for a number as for a
  reference. A definition that calls a unit method which reads such a name
  works (`unit_held_call_required_input_from_caller`). Measured on
  `bfeef8cc`
  ([HELD-DEFINITION-UNDECLARED-NAME](defects.md#held-definition-undeclared-name)).

### Found beside it, measured, not repaired

- **A Structure of a known declaration given through an opaque formal to a
  Structure formal stops the translation**: `internal: a pair map of D-105
  was asked for after the maps were declared`. The admitting text
  enumerates the declarations recorded at the opaque formal; the closure
  that reserves the correspondences does not follow the explicit actual
  from an opaque formal. Every translator since `fable_full_30` at least
  does this; no row has the shape
  ([OPAQUE-ACTUAL-KNOWN-LAYOUT](defects.md#opaque-actual-known-layout)).
- **A Structure that merely may reach a reader is refused for the
  possibility under a free name too.** A Structure without the field,
  given through an opaque formal into a typed reference and on under a
  free name, is refused at translation where the name is handed to the
  reader; with the reader's formal declared, the same program runs and
  the reference refuses it when the program runs. This is the class the
  nineteenth reply names in (d) below.

### The nineteenth reply on the refusals of section 69

Codex classified the five things section 69 left measured. All are debts
of the implementation.

- The letter held in a typed place: "b) TYPED-PLACE-LETTER-READMISSION:
  YES, the observe(m) program is valid by the Consumer's use of mainArgs,
  and this is G5-blocking shared admission/correspondence debt.
  Reuse/compose an ACTUALLY ESTABLISHED value->MainLetter correspondence
  with the translation-resolved MainLetter->Long used-path mapping. Merely
  declaring the source place MainLetter is not such a proof."
- The result of an opaque call given directly, (c): "implementation
  LIMIT/defect, not a language rule requiring a named result model.
  Ordinary result reception must apply the same conversion/admission,
  evaluating the producer once."
- The candidate chosen when the program runs: "d) A merely POSSIBLE
  incompatible dynamic source is not proof that every call is
  incompatible. Keep the actual runtime selection and ordinary admission:
  the good branch succeeds, the incompatible branch fails catchably at the
  receiving edge." With a caution about my probe: "verify your @Good/@Other
  spelling FIRST: unary @Structure adds a level and addresses its reference
  cell. It is NOT ordinary Structure reception."
- The opaque reference under a free name of a typed reference: "e) An
  opaque reference supplied as a hidden input to a typed reference use has
  the same receiving-edge conversion/admission as the explicit analogue,
  provided actual reference depth/type is correct."
- The letter returned as a typed result, (f): "absence of a named source
  schema is not proved implements-false. Classify the premature refusal as
  implementation debt if the actual value satisfies the result's consuming
  contract and permitted conversion."

And on the duplicate stop of a candidate that is not dynamic: "remove the
duplicate stop for genuinely compiler-proven static producer/admission
cases." That a Structure was constructed by a declaration or a merge is not
alone proof that a reference read later still denotes that origin; the
routes of rebinding, of a taken address and of escape are to be checked.
"If current origin is not proved, use the common dynamic admission rather
than a defensive abort or assumed YES."

They are recorded as
[RECEPTION-EDGE-DEBTS](defects.md#reception-edge-debts).

**Next.** The reception debts in the reply's order: the letter held in a
typed place, with the route of a letter alone under a free name; the
result of an opaque call given directly; the possible source, with the
internal error above; the opaque reference under a typed free name; the
letter as a typed result; the duplicate stop. Then the receiving-edge
conversion by the twentieth reply, and the rest of the order of section 68.

<a id="no-ceiling"></a>
## 71. No ceiling on the route of a path through a free name (Codex's twenty-first reply -12)

### The reply

"NEWLY OBSERVED BOUNDEDNESS DEFECT — FIX BEFORE EXTENDING THIS SLICE. The new
anchor route has hard-coded ceilings in the committed code". "These are
precisely the arbitrary length/count limits the author has already
forbidden, including in translation metadata. They are not justified by
being compile-time-only, nor by diagnosing the result as an implementation
limit. Use storage sized from the actual finite graph/metadata counts, or
the existing dynamically sized work-list/span machinery. Cycle tracking
remains ordinary algorithm state; an arbitrary maximum is not the cycle
algorithm." A genuine allocation failure, the reply goes on, remains an
allocation failure and is never a result that says no coordinate space
was found. "Add witnesses beyond 64 reaching
declarations, beyond 256 reached (method,input) places including a cycle,
and beyond 127 bytes in a path component; each should produce its real
positive result rather than a limit refusal. Also inspect this anchor
addition for any other fixed ceilings introduced with it."

The reply is right, and the fault is mine: section 70's search held its
candidates in 64 cells and its places in 256, and compared a step of a path
through a copy of 128 bytes. A program past any of the three was refused
with the words of a limit that named another cause.

### What the witnesses met

Removing my three ceilings was not enough for the witnesses to pass. Each
one met an older ceiling on the same route.

| Witness | Section 70's ceiling | What it met next |
| --- | --- | --- |
| Seventy declarations reach one name | 64 candidates | 64 pairs of types admitted by name: `too many pairs of types admitted by name (D-105)` |
| The name passes through 262 methods, two in a cycle | 256 places | 128 edges: `too many formals passed on to Structure formals (D-105)`; then 256 sources |
| A field's name of 141 bytes | a step copied into 128 bytes | the uses of a method were joined in 128 bytes, and a path that did not fit was left out; the check of a candidate by those uses copied a step into 128 bytes |

The middle column of the last row was more than a ceiling. A read through a
declared formal whose path did not fit was not among the method's uses at
all, so a candidate without that field was admitted, and the process
stopped at the read. No program of the gates had such a name
([LONG-USE-LEFT-OUT](defects.md#long-use-left-out)).

### What is changed

1. **The search for a coordinate space** (`l2_anchor_close`,
   `l2_anchor_reach`). Its candidates are named declarations of the unit,
   each once, and its places are the place asked about and the giving ends
   of recorded edges: the two blocks are sized from those counts. The
   places reached are the list of work, each visited once, so a cycle of
   methods ends without a maximum. No list can be full; a failed allocation
   is reported as one.
2. **A step of a path is compared where it stands**, at its own length, in
   the list of a method's uses (`l2_anchor_covers`, `l2_descriptor_used`):
   no copy.
3. **A used path is joined at its own length** (`l2_uses_scan_follow`): the
   block grows with the path, as the list of paths already did.
4. **The tables of the admission by name grow with the program**: formals
   admitted by name (were 64), sources (256), edges (128), pairs of types
   (64). The cells of one correspondence while it is built or written out
   are sized by the required declaration's width (were 128, a declaration
   of at most 64 fields).

### Witnesses

| Row | Past which ceiling | Shows |
| --- | --- | --- |
| `unit_free_path_many_declarations`, `_walk` | 64 candidates, 64 pairs | Seventy declarations reach one name at one call that forms the reader's input; each caller reads its own Structure, 101 to 170. |
| `unit_free_path_many_places`, `_walk` | 256 places, 128 edges, 256 sources | The name passes through 260 forwarders in a chain and two in a cycle; 31, and 41 with the field at another position. |
| `unit_free_path_long_step`, `_walk`; `_long_step_other_refused` | 128 bytes of a step | A field's name of 141 bytes read and written through the name: 31, 41, 13. A field whose name is that and one byte more is another field: refused by the ordinary admission. |
| `unit_formal_long_field`, `_walk`; `_long_field_other_refused` | 128 bytes of a method's uses | The same for a declared formal: 31, 41; a candidate without the long field is refused. The second row translated before this step. |
| `unit_formal_many_admitted`, `_walk` | 64 formals admitted by name | Seventy formals each filled with another declaration than its own. |
| `unit_formal_wide_model`, `_walk` | 128 cells of a correspondence | A declaration of seventy fields admitted to one with the same fields in the opposite order. |

The two largest fixtures give their callers a reference to the Structure of
a declaration and make no copy: see the cost of a copy below.

### Mutants

Each puts one old ceiling back into this translator. Method as in section
70, on the 51 rows of `fable_s9_01`.

| Mutant | Puts back | Result |
| --- | --- | --- |
| `cap64` | more than 64 declarations establish nothing | `unit_free_path_many_declarations` and its walked twin are refused with the words of the limit |
| `cap256` | the search stops joining places at 256 | `unit_free_path_many_places` and its walked twin are refused with the words of the limit |
| `step127` | a step of 128 bytes or more is in no declaration | `unit_free_path_long_step` and its walked twin are refused; `_long_step_other_refused` is refused with other words at another place |
| `used127` | the check of a candidate refuses such a step | `unit_formal_long_field` and its walked twin are refused, `implements is false`; `unit_free_path_long_step` is refused |
| `usesdrop` | a step that does not fit 128 bytes is left out of a method's uses | `unit_formal_long_field_other_refused` translates, and the program stops when it runs: `a field of a formal admitted by name is not carried by its value`; `unit_free_path_long_step` is refused |
| `edges128` | 128 edges | `unit_free_path_many_places` and its walked twin are refused |
| `sources256` | 256 sources | the same two rows are refused |
| `pairs64` | 64 pairs of types | `unit_free_path_many_declarations` and its walked twin are refused |
| `marks64` | 64 formals admitted by name | `unit_formal_many_admitted` and its walked twin are refused |
| `cells128` | 128 cells of a correspondence | `unit_formal_wide_model` and its walked twin are refused |

`usesdrop` is the old behaviour of the uses, and its result is what the
committed translator did with that fixture: the candidate without the field
was admitted, and the process stopped at the read.

A cycle of methods has no mutant of its own. Without the list of places
visited the search would not end; the row with the cycle shows that it
does.

### Measured

The translator against the committed one (`752f87c8`), on the 1770
translations recorded by `fable_full_42`: exit, messages and the generated L1 are the same on 1768 rows. The two others are the rows of the disagreement, refused as before with the new words.

| Gate | Result |
| --- | --- |
| `build/l2src/fable_kernel_29` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/fable_l3_29` (`run_l3_selftest.py`) | All 11 suites exit 0; four type-budget units. |
| `build/l2_harness/fable_full_43` (full harness) | RED 39 of 1788. Against `fable_full_42`: FAIL→OK 0, OK→FAIL 0, added 19, of them 15 green and the four required positives red; removed 2, the two rows renamed; no message of a red row changed. |
| `build/l2_harness/fable_s9_01` (focused, before the gates) | 51 rows: the new rows pass; the four red rows are the required positives below. |

### What the reply reclassified

- **Declarations that give a used field different types** (Q1). "Do not
  promote the symmetric disagreement refusal into a language rule.
  Semantics #three-argument-implements requires
  leaf_consumption_admitted(actual.p, Consumer, p), not equality of the
  anchor's primitive field spelling. The anchor supplies coordinates; it
  must not silently supply an additional requirement." And: "YES, the same
  criterion applies to the DECLARED analogue." The refusal stays where it
  was and says that it is a limit: `the declarations reaching a free name
  give a field the method uses different types; reading it by conversion
  is not built yet`. Its two rows are no expected refusals any more: the
  programs are required positives, `unit_free_path_field_converted` and
  `_swapped`, with the declared analogue `unit_formal_field_converted`, red
  until a field is read at its own type and converted at the receiving
  edge
  ([FIELD-CONSUMPTION-CONVERSION](defects.md#field-consumption-conversion)).
  With the rows goes the hold on that refusal's words: no row pins them
  now.
- **A returned definition that itself reads a name nothing declares**
  (Q2). "Confirm HELD-DEFINITION-UNDECLARED-NAME is a valid OPEN positive
  and G5 debt." "The old T7 prohibition concerns unsupported/invalid
  BINDING operands of a callable specialization; it does not prohibit a
  model body's free name." The required positive is a row now, red:
  `unit_held_definition_free_name`.
- **A typed place's declaration as the coordinate space** (Q3): to be
  settled with the letter held in a typed place, "using a genuinely
  established value -> MainLetter correspondence and a live native/walk
  positive".

`unit_free_path_value_none_refused` is added: the limit of a name that
nothing gives its fields to, where the path is the whole of a value. That
site had its words held only by the two rows that are positives now.

### Found beside it, measured, not repaired

- **The cost of a copy in a method grows steeply with the unit.** N named
  Structures and N methods that each copy one and read its field, with no
  free name anywhere, on the translator of `bfeef8cc`: 3 seconds of run
  for N = 8, 43 for N = 16. With a free name, on this translator: 4, 20, 65
  seconds for N = 8, 12, 16, and more than 120 for N = 20. The time is in
  the kernel's copy of the graph under `lmx_merge_profiles_owned`. The
  first form of the seventy-declaration witness made seventy copies and
  did not finish in eleven minutes; it gives references now. This is a
  defect of its own and no part of this route
  ([MERGE-COST-GROWS-WITH-UNIT](defects.md#merge-cost-grows-with-unit)).
- **Fixed blocks remain elsewhere in the translator.** `l2trans.lm1` has
  200 fixed character blocks and 14 fixed blocks of ints in its functions,
  and 29 fixed blocks at unit level. One that a program meets: a path whose
  text is longer than 255 bytes is refused, `unresolved name`, through a
  declared formal as through a free name (measured with a field's name of
  300 bytes; 250 passes). They are older than this work and outside this
  route; they are listed for the order to be decided
  ([FIXED-BLOCKS-AUDIT](defects.md#fixed-blocks-audit)).

**Next.** The letter held in a typed place, with the declaration of a
typed place as coordinate space and the route of a letter alone under a
free name; then the order of section 70, with the read of a field by
conversion joined to the receiving-edge conversion, and the returned
definition's own free name on the route of the required inputs.

<a id="letter-typed-place"></a>
## 72. A letter held in a typed place, admitted to another declaration through the record of its reception (Opus; Codex's nineteenth reply (b), the twenty-second reply, OPUS-HANDOFF-20261005-103112)

> Opus continues from this section. Fable's session ended at its quota after
> `045d6ea2` and Codex's reply to it; the author made Opus the single
> writer/build owner on 2026-10-05, and Codex's handoff to Opus
> (OPUS-HANDOFF-20261005-103112) set this slice first. Codex answers questions
> through `lmx_uds` as before.

### The rulings

The nineteenth reply, (b): the program is valid "by the Consumer's use of
mainArgs", and the repair is to "Reuse/compose an ACTUALLY ESTABLISHED
value->MainLetter correspondence with the translation-resolved MainLetter->Long
used-path mapping. Merely declaring the source place MainLetter is not such a
proof." The twenty-second reply checked the existing records and accepted the
design as a read of them: "Reading an actually completed positional
correspondence and composing it with the translator-resolved declaration ->
receiving-model pair map is within the earlier ruling." And: "For your bounded
fast route, no frame, no map and no holes mean an established positional
correspondence. It is NOT proof that the actual value's source layout equals
that declaration."

The reply to Opus's start corrected two points of the design before it was
built. On holes: "Do not let SIZE_MAX mean "unused" without that exact use
proof." On several anchors: "Giving-place-first is defensible only where that
precise current source view is established by an actual completed
correspondence, not by the place's annotation alone." Otherwise "Agreement is
about the current Consumer's USED selectors/paths and their resulting physical
targets", and "If two qualifying proofs differ on a target the Consumer
actually uses, do not silently choose one by registration/list order." "Nor may
disagreement simply disappear into positional success." On the case of a letter
given before any reception recorded it: "A before case that the implementation
cannot yet establish must be labelled an evidence/coverage limit, not a
normative required negative".

### Fable's draft, audited

Fable left `patch_s10.py` in its scratchpad, written and never applied or
built. Its kernel query is kept. Two gaps were found before anything was
built:

1. It offered the identity through the giving place's default map with no
   proof of the current Consumer's uses. That map is reserved for every
   modeled edge without a consumer check (`l2_d105_prepare_pair`), and an
   admission by the Consumer's uses (fullReceiver 0) skips its `SIZE_MAX`
   cells as proved unused when it registers. A consumer that reads a field the
   place's declaration has not would have admitted the letter and stopped the
   process at the read, the shape `LONG-USE-LEFT-OUT` had.
2. It covered only the giving place's own declaration. A typed place's
   declaration is no source of D-105 -- only the layouts of producers are --
   so nothing reached a consumer through a place with no declaration.

### The record that is read

A reception into a place of a declaration checks a value with no layout of its
own against the whole declaration by position and registers
`lmx_implements_register_map(value, declaration, 0, 0U, 0)`: a record of
(value, declaration) with neither frame nor map and no holes. The receptions
that do so are `receiveMessage:` into a typed place, the binding of a typed
reference (`m: @raw`), and the admission of a letter to a formal of its own
declaration. That record is what is reused. The declaration's own record --
its self-registration with its layout token -- is read only to recognise the
declaration by that token; it certifies no other value. No record is made by
the new route except the ordinary one of the admission it ends in, and the
value's layout stays unknown.

### What is built

1. **The query** (`lmx_implements_identity`, kernel). 1 when a record of
   (value, declaration) with neither frame nor map and no holes exists for the
   declaration whose own record carries the token, else 0. A value's record
   with itself is never asked. It reads the arena's records under their
   existing lifetime (they are pruned where storage leaves) and hands no
   record out.
2. **Possible anchors** (`l2_d105a_close`). After the checks, the declaration
   of each giving place reaches the place it hands to, and so does every
   anchor of the giving place, along the edges of D-105 and along anchor edges
   (`l2_d105x_add`): the way a held value comes from a place of the caller to a
   Structure formal, recorded where the checks see the site, apart from the
   edges of D-105 so that the layouts and their static checks do not change.
   The tables grow with the program; a cycle of methods ends because an
   anchor joins a place once. An anchor is no source, no layout and no
   admission.
3. **Identity entries of a reception** (`l2_identity_list`). Where a
   candidate the translation has no layout for (`l2_d105_dynamic`), read from
   a place, is formed into a formal or a hidden input admitted by the
   Consumer's uses (fullReceiver 0) along a recorded edge: the giving place's
   own declaration first, then the anchors that reach the giving place. A
   declaration is offered only where it gives every path that Consumer reads
   (`l2_anchor_offer`: `l2_uses_walk_frame` and `l2_descriptor_used`, the check
   D-105 applies to recorded sources) and its correspondence to the model can
   be built; one that does not is left out and condemns no value. The giving
   place's own declaration is class 0; the others share a class where they
   give every first step the Consumer reads the same place. The list is
   computed once per site, once the model's width is known, and its pair maps
   are reserved in `l2_d105_close` before the maps are declared.
4. **The native text and ADMIT_AS select the same way.** Only for a value
   with no layout of its own: the giving place's own declaration decides when
   its record answers; otherwise the first entry that answers is taken, and an
   entry of another class that answers too refuses the reception (native
   `l2_idsel` 2, walked `ambiguous`) -- neither the order of the entries nor
   the positional check decides. ADMIT_AS carries the entries after its
   alternatives as (token, class, map), their count given by the cells up to
   the catch rows (`lmx_walk.h`). A value with a layout of its own keeps its
   layout's route. The selected map registers as any map does.
5. **A typed reference as a coordinate witness** (`l2_anchor_reach`). The
   declaration of a typed reference that hands a free name on is among the
   declarations that reach the name (the twenty-first reply, Q3). It is no
   type of the name and no evidence of the value: the reader's admission asks
   the value's own record.

### Found beside it and repaired

The walked call admitted a candidate the translation could not name twice: a
whole-model structural admission (`l2_rw_struct_arg` ->
`l2_rw_reference_receive`) before the site's admission by the Consumer's uses,
which the native text alone makes. Through an opaque formal the first one
refused what the second admits, walked only. The first admission is now made
only where the site has no admission of its own, and for a letter named as the
actual, which that reception takes as its payload (D-57), as the native text
does
([WALKED-UNKNOWN-ACTUAL-DOUBLE-ADMISSION](defects.md#walked-unknown-actual-double-admission)).
A first form of the repair dropped the letter case too and three rows went
red walked (`unit_admit_dynamic_actual_catch` and its twin,
`unit_site_constructor_reception`); the focused run caught it before any gate.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_letter_place_other`, `_walk` | The letter held in a MainLetter reference given to a Long formal that reads only mainArgs: 2 + n; the same letter again, and once through a MainLetter formal that hands it on. observe entered three times. |
| `unit_letter_place_hidden`, `_walk` | The same into a hidden input whose lexical source is a Long reference, from a reference and from a MainLetter formal of that name. |
| `unit_letter_place_forward`, `_walk` | Through two opaque formals in a chain, a method that hands it to itself and two that hand it to each other; then the root's Long Structure through the same sites, admitted by its own layout: 2. |
| `unit_letter_place_missing_field`, `_walk` | A consumer that reads Long's size, after the letter was admitted to Long by one that does not: refused where the input is formed and caught, 42; the consumer not entered; no process stop. |
| `unit_letter_place_free_name`, `_walk` | The letter alone under a free name, directly and through a method that only hands the name on: the typed reference's declaration is the coordinate space. |
| `unit_letter_alias_after`, `_walk` | An untyped alias after a binding: the reference through an opaque formal, and the alias to a MainLetter formal that takes it as its payload. |
| `unit_letter_place_two_anchors`, `_walk` | The letter bound to a MainLetter and to an Other reference, both handed to one opaque formal: both declarations reach it, both records answer, one class, the first taken: 2 + n both times. |
| `unit_letter_alias_before` | OPEN required positive, red: the letter given untyped to the Long formal before any reception recorded it. |

Where the methods are walked, the consumers that read a formal admitted by name
and the methods that receive the letter stay native, and the methods that form
the inputs are walked; the rows pin which.

The reply to Opus's start asked for "a fixture probing multiple available
anchors: unused-target disagreement must not impose an extra requirement;
used-target disagreement must not produce an arbitrary positional success."
`unit_letter_place_two_anchors` has two anchors that both answer. Neither kind
of disagreement can be built today: the only value with no layout of its own is
the argv letter, of one field, a declaration identical with it by position has
that one field, and two such declarations place every path a consumer reads,
and every target it does not, alike. The refusal of two classes has the
walker's selftest; the native branch is reached by no program.

`unit_letter_place_free_name` does not need the identity route: its reader's
coordinate space is MainLetter itself, so the letter's record answers the
ordinary query of a record (`lmx_implements_find`), and its generated L1 is the
same without identity entries. It witnesses the coordinate space alone.

### Mutants

Translator mutants are built each in its own stage, replayed over the
recorded translations of the focus set, and run on the slice's fixtures
natively, with the root walked and with the methods walked. Kernel mutants
are run against the two selftests on a copy of the kernel gate's staged
sources; the control without a mutant is green there (88 and 58 checks).

| Mutant | Takes away | Result |
| --- | --- | --- |
| `noid` | no identity entry is offered | `other`, `hidden`, `forward`, `alias_after`: R0 stopped, exit 1, in all three modes; `missing_field`: 81, the admission to `first` refused too. `free_name` green, see above. `two_anchors` was written after this run. |
| `noconsumer` | an anchor is offered without the current Consumer's uses | `missing_field`: the process stops, exit 3, `lmx: invariant: a field path met no Structure`, in all three modes. Six other rows of the focus set change their L1; not run under the mutant. |
| `noanchors` | the anchors of a giving place do not travel on along an edge | `forward`: exit 1 in all three modes. The first form put `i < 0` after the call that adds the anchor: the anchor was still added, no row changed, and it was corrected and run again. |
| `noxedge` | the way a held value comes to a Structure formal from an opaque place is not recorded | `forward` and `alias_after`: exit 1 in all three modes. |
| `innerkeep` | the walked call admits an unknown candidate twice again | `forward` and `alias_after`: exit 1 with the methods walked only; the six `unit_admit_dynamic_actual_*` rows get back their old L1. |
| `nowitness` | a typed reference that hands a free name on is no coordinate witness | `free_name` is refused at translation: `length requires one known primitive own array`. |
| `nos` | the giving place's own declaration is not offered | `other`, `hidden`, `alias_after`: exit 1; `missing_field`: 81. `forward` and `free_name` green: at their consumers' sites the giving place has no declaration of its own. |
| `nosameclass` | every anchor that answers is a class of its own | `two_anchors`: exit 1 in all three modes; the other fixtures green. |
| `k_mapok` | the identity takes a record admitted through a map | table selftest: `a value admitted through a map was identical by position`. |
| `k_self` | the identity takes the declaration's own record | table selftest: `the declaration's own record was taken for its identity with itself`. |
| `k_never` | no record answers | table selftest 2 failures; walker selftest 4. |
| `k_noclass` | the walker does not tell classes apart | walker: `two classes that both answer refuse, with no positional success and nothing recorded`. |
| `k_noown` | the giving place's own declaration does not decide | walker: `the giving place's own declaration decides when its entry answers`. |
| `k_rescue` | a value with a layout of its own is asked for its identity too | walker: `a value with a layout of its own is not admitted through an identity entry`. |
| `k_fallthrough` | two classes that answer fall through to the record and the positional check | walker: the refusal of two classes and the selection within one class fail. |

No mutant reaches the native refusal of two classes: no program builds it.

### Measured

The translator against the committed one (`045d6ea2`), on the 1787
translations recorded by `fable_full_43`: exit and messages are the same on
every row, and the generated L1 on 1756. Of the 31 others, 25 gain identity
entries in the native text and in ADMIT_AS -- at sites where a candidate with
no layout the translation knows is formed into an input admitted by the
Consumer's uses; a value with a layout of its own there keeps its layout's
route -- and six (`unit_admit_dynamic_actual_*`) lose the walked whole-model
admission.

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_01` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. `lmx_implements_table` 88 checks (73 before), `lmx_walk_admit_selftest` 58 (46 before). |
| `build/l3_selftest/opus_l3_01` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_02` (full harness) | RED 40 of 1803. Against `fable_full_43`: FAIL→OK 0, OK→FAIL 0, added 15, of them 14 green and `unit_letter_alias_before` red, the OPEN required positive; none removed; no message of a red row changed. The staged translator is the committed blob `d5a9a7a9`; every declared path is the same before and after the run. |
| `build/l2_harness/opus_focus_b2` (focused, before the gates) | 130 rows: the new rows pass; the three red rows are `unit_letter_alias_before` and the two required positives of section 71 (`unit_free_path_field_converted`, `_swapped`). |

The first full run, `opus_full_01`, was stopped by Opus a few minutes after it
began, to add `unit_letter_place_two_anchors`; its directory was removed. The
kernel and L3 gates are not repeated: the kernel and translator bytes are the
same, hash for hash, in both runs.

### What is not built

- **A reception that receives in full or by coverage** (fullReceiver 1 and 2:
  the binding of a typed reference of another declaration, a return value) is
  offered no identity entry. A letter held in a MainLetter place and bound to
  a Long reference is refused as before.
- **A value no reception recorded** is admitted by position against the whole
  model, not by the Consumer's uses: `unit_letter_alias_before`
  ([UNRECORDED-LETTER-WHOLE-MODEL](defects.md#unrecorded-letter-whole-model)).
- **Only a record by position serves.** A letter admitted to a declaration
  through a map is not composed again; along a chain of typed places the
  anchors of the earlier places carry it.
- **A site with no recorded edge** offers no entries.
- **A Structure of a known layout through an opaque formal** still stops the
  translation ([OPAQUE-ACTUAL-KNOWN-LAYOUT](defects.md#opaque-actual-known-layout));
  the anchor edge now recorded at that site carries possibilities only.

<a id="author-decisions-20261005"></a>
## 73. The author's three decisions of 2026-10-05: what they supersede here, what they leave to build

No translator, fixture or harness byte changes with this section. The author
answered the three open questions, and Codex relayed the answers
(AUTHOR-MERGE-PARENT-20261005-114321, AUTHOR-FACTORY-REF-20261005-114610,
DOC-BATON-AUTHOR-20261005-115300). The author's words are archived in
[the blog of 2026-10-05](../LMX_blog/2026-10-05.md), and the three questions
are closed in `LMX_blog/q/`. The quotations below are Codex's, from those
messages. Earlier sections are not rewritten: what they measured stands, and
what they said of the norm is superseded as marked here.

### The parent of a merge's copy

The author's words: [blog](../LMX_blog/2026-10-05.md#merge-parent); the rule:
[semantics #composition](../docs/LMX_semantics.en.md#composition). Codex: "merge copies the USED part of the existing tree and rewrites parent
links INSIDE THE COPY, preserving the copied source relationships. The place
that executes merge does not supply/redefine its lexical parent or trigger
free-name resolution in that place." In the question's example, where no
caller gives `other`, "the copied lexical value is 9, not the merge-site's 50;
later mutation of the original is not observed". "Ordinary dynamic input
priority is unchanged." And: "Do not infer that every copied node gets
parent=0: rewrite the actual source links under the existing source-to-copy
relation, respecting the established qualified immutable/native retention
rules."

Superseded: the twelfth reply's sentence quoted in
[section 63](#twelfth-reply), "#composition fixes the new root's lexical
parent from the merge expression's location", and that section's table cell
"By the norm the node's parent follows the place of the merge". The choice
that [section 64](#thirteenth-reply) left between the place of the merge and
the model's copied state is decided for the copy
([the closed question](../LMX_blog/q/merge-lexical-copy-and-root-placement.md)).

What was measured stands, and it is the defect: the node hangs under the
`node` of the method that gives the merge, and its body reads the live cell
of the unit's field, 9, 11, 9 where the copy gives 9, 9, 9.
[T7-NODE-LEXICAL-LINKS](defects.md#t7-node-lexical-links) stays OPEN and no
longer waits for the author. Its witness is the entry's second program,
asymmetric: the model's lexical `other` 9, the executing method's own `other`
50, no caller giving it; the copy reads 9 before and after the original is
changed to 11, and a read of the original sees 11. `node\other` in the copy
follows the copied lexical link. The rows come with the repair, natively and
walked, with a shared target, a cycle and the ordinary priority of a caller's
input beside them.

### The receiver of a factory's result

The author's words: [blog](../LMX_blog/2026-10-05.md#factory-reference-result);
the rule: [semantics](../docs/LMX_semantics.en.md#factory-reference-result).
Codex: "the old result-binding example must be REWRITTEN using the explicit @:
receiver. The general dormant named-body rule remains; do not preserve a
magic factory-initialization meaning for an unknown ordinary head just because
its tail starts with a known method name, nor distinguish
short/parenthesized/block spellings to rescue it." Codex's rewriting of the
example, which it calls "NOT a verbatim author quote and NOT a new
unary-address rule", receives the results as `@: add5 makeAdder(5)` and
`@: add100 makeAdder(100)`; `[add5(1); add100(1); add5(1)]` gives `[6 101 6]`.

Superseded: the question that [section 50](#result-receipt-open) sent to the
author, whether the short form `add5: makeAdder 5` keeps its meaning of
binding the call's result, and with it the hold on a factory's named actuals:
they are the named actuals of the call in `@: h2 make2(n: 100)`
([the closed question](../LMX_blog/q/held-factory-initialization-versus-body-definition.md)).

Measured on this ledger's translator (`f8ef5d8b…`), translation only, outside
any gate: `@: add5 makeAdder(5)` is refused at the root and in a method,
`unsupported body` (frame `@`). The short form still translates with its old
meaning: the factory is called where the statement stands. The rows of T6 and
of held callables are built on it
([FACTORY-RESULT-RECEIVER](defects.md#factory-result-receiver)).

### A head that no binding established

The author's words: [blog](../LMX_blog/2026-10-05.md#unknown-head-return).
Codex: "return: x is plainly a type-conversion error in the supplied
example." And: "The example's x: j has no established primitive/free-input
binding, so it defines named Structure x; later return: x does not
retroactively make x a hidden primitive input. There is no valid int result."
And: "A caller's same-name variable alone cannot change the source head's
role."

Superseded: the tie-break that [section 13](#head-role) asked of the author
for `unit_colon_hidden_update`, `unit_free_conv` and `unit_walk_free_conv`,
and the note of [section 18](#triage) that `unit_asgn_fallback` waits for the
author ([the closed question](../LMX_blog/q/head-role-hidden-input-fixed-point.md)).
`unit_free_conv` and its walked twin have the question's shape in `target`
(`k: j`, then `return: k`): by the decision a refusal at the return, no
required positive. `unit_colon_hidden_update` reads its head in its own tail
(`hidden: hidden + 1`, then `return: hidden`); whether the decision covers
that read is put to Codex before its expectation changes. The expectations
change with the step that carries the rows into a gate
([HEAD-ROLE-UNESTABLISHED-ROWS](defects.md#head-role-unestablished-rows)).

**Next.** The rows of these three decisions and the order of the plan come
from Codex's reply to this checkpoint. Codex's handoff order stands until
then: the ceilings of path and admission text, the cost of a merge in a large
unit, the receiving-edge debts (c) to (f), the duplicate stop of a static
producer and the numeric conversion at the receiving edge.

<a id="path-text-any-length"></a>
## 74. The text of a path or a name of any length; a walked path of any number of names (Codex's reply OPUS-CODEX-20261005-01, (2) B)

The reply set the order after section 72: "B. FIXED-BLOCKS-AUDIT: remove
actual path/admission text ceilings end-to-end, beginning with the measured
300-byte refusal. Program-sized spans/worklists, no larger fixed cap, silent
clipping, syntax-depth ceiling, runtime name table or change to genuine fixed
machine-format constants. Native/root-walk/method-walk and long-path positive
plus true missing-field controls, mutant that restores the ceiling."

### What was measured

On the translator of `12ab4488`, by scratch probes outside any gate:

- A path whose text is longer than 255 bytes is refused: through a declared
  formal or a free name `unresolved name` at its first long name, and as the
  head of a store `unsupported body`. 250 bytes pass. The cut was in the
  capacities handed to the builders of a path's text (255) and in the length
  gates of a head (256, and 1024 for a path write).
- A path of more than twelve names is refused where it is walked: `root
  operation not walkable yet: a field path`. The root is walked in both modes,
  so a root that reads such a path is refused natively too. The resolver of a
  walked path was asked for twelve names, and its callers' tables held 42
  cells, six and three for each name.
- A wrong translation beside them. The static check of a return value
  (`l2_descriptor_implements`) copied each name of the model's fields into 128
  bytes and passed a longer one over. A method declared to return a Model that
  returned a Structure without Model's field of 146 bytes translated, and the
  process stopped when it ran: `lmx: invariant: an admission by name was
  refused`, exit 3. With a short name the same program is refused at
  translation, `implements is false in return value`
  ([RETURN-CHECK-LONG-NAME](defects.md#return-check-long-name)).

### What is built

1. **Text of any length** (`l2_text_room`, `l2_atoms_len`). A function that
   joins a path or copies a name into a buffer of its own keeps its local
   buffer for what fits it and takes storage of exactly the text's size for
   what does not, kept until the translation is released (`l2_ltx`,
   `l2_release`). The size is the bytes of the atoms the text is made of: no
   builder writes more (`l2_join_path`, `l2_path_chain`, `l2_ruse_follow`,
   `l2_arr_operand`), since the separators it writes are atoms of the list
   too. The sites: the check and the emission of an expression's fields
   (`l2_check_fields`, `l2_emit_fields`), a statement's path (`l2_emit_stmts`),
   the uses of a typed reference (`l2_ruse_scan_struct`), a callable actual's
   path (`l2_cf_actual`), an indexed path and an Array's length
   (`l2_arr_operand`, `l2_arr_len_shape` and its three callers,
   `l2_rw_length_of`), a path of one name and one field
   (`l2_field_path_check`, `l2_field_path_read`), the test of an eternal
   branch's address (`l2_addr_names_eternal`), the names the static check of
   a candidate compares (`l2_descriptor_implements`) and those of an actual's
   path (`l2_actual_path`, `l2_emit_actual_path`, `l2_actual_ns`).
2. **No length gate on a head.** A head of any length is a path or a call
   head (`l2_head_is_call`, `l2_head_method`, `l2_is_path_head`,
   `l2_check_primary`, `l2_check_body`, `l2_prep`, `l2_check_path_write`,
   `l2_native_path_ty`): the functions it is handed to take a byte span.
3. **A walked path of any number of names** (`l2_rw_seg_cap`,
   `l2_rw_path_room`). The resolver's capacity is the path's own count of
   segments, and each of the nine callers' tables has a record for every one:
   in its local 42 cells when they hold them, else in storage of that size.

Nothing is clipped. On the 1802 translations recorded by `opus_full_02` the
generated L1, the exit, the messages and the count of allocations are the same
as the committed translator's: no program of the gates has a text longer than
the local buffers.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_path_long_names`, `_walk` | Names of 600 bytes, the path of two of them over 1200: read and written through a declared formal, through a free name and in the method that made the copy; a field of one such name, read also by its occurrence; an Array field of such a name, an element written through its address and read through a formal, and its length; the path read through a typed reference of such a name and stored into a declared field. |
| `unit_path_long_call`, `_walk` | A call through a path to a method's occurrence held by a named Structure of a 600-byte name: in an initializer, inside an expression and as a statement. |
| `unit_path_deep_names`, `_walk` | A path of twenty names, read and written through a formal, read through a free name, written and read where the copy was made. |
| `unit_reference_long_path_coverage` | A typed reference that reads a path of a 600-byte name receives by that use and admits a Structure without the field it does not read. Its method receives natively, so the row has no walked twin. |
| `unit_path_long_names_other_refused` | A candidate without the formal's field of such a name: `implements is false in function argument`, as with a short name. |
| `unit_return_long_field_other_refused` | A returned Structure without the result model's field of such a name: `implements is false in return value`. |
| `unit_free_path_write_long_none_refused` | A write through a free name of a path over 1200 bytes that nothing reaching the name gives its fields to: refused where it stands, in the words a short path has. |

On the translator of `12ab4488` the four positive rows are refused at
translation (`unresolved name`, `unknown method`, `root operation not walkable
yet: a field path`, `unsupported body`). Two of the controls are refused
there by the ceiling's words, `unresolved name` and `unsupported body`, and
not by their own. The return-value control translates.

### Mutants

Each mutant puts one ceiling back into this translator, in a stage of its
own. The seven witnesses are translated natively and with the methods walked,
and a positive one that still translates both ways runs natively, with the
root walked and with the methods walked.

| Mutant | Puts back | Result |
| --- | --- | --- |
| `cap255` | no text over 254 bytes is given room, for every builder | `path_long_names` refused, `unresolved name`; `reference_long_path_coverage` translates, and its admission refuses when it runs: R0 stopped, exit 1, in all three modes |
| `chaincheck255` | the check's chain of a path in 255 bytes | `path_long_names` refused, `unresolved name` |
| `checkf255` | the check's joined path in 255 bytes | `path_long_names` refused at the store into a declared field, `unknown field path root` |
| `fp256` | a path of one name and one field over 254 bytes | `path_long_names` refused at its field of one name, `unresolved name` |
| `arr250` | an indexed path's field over 250 bytes | `path_long_names` refused at the Array's length, `length requires one known primitive own array` |
| `rwlen250` | the same for the walked length of an Array path | `path_long_names` refused, `root operation not walkable yet: an array` |
| `ruse256` | the uses of a typed reference joined in 256 bytes | `reference_long_path_coverage`: R0 stopped, exit 1, in all three modes -- the reference received in full |
| `desc128` | a model's field of 128 bytes or more passed over by the descriptor check | `return_long_field_other_refused` translates |
| `depth12` | twelve names for a walked path | `path_deep_names` refused, `root operation not walkable yet: a field path` |
| `g_is_path_head` | a store's head of 256 bytes or more is no path | `path_long_names` and `reference_long_path_coverage` refused, `unknown field path root` |
| `g_head_method` | a call head of 256 bytes or more names no method | `path_long_call` refused, `a call path must end at a callable field` |
| `g_prep` | the emission of a call through a path of 256 bytes or more | `path_long_call` refused, `internal: a call the emitter does not know` |
| `g_path_write` | the check of a path write passes a head of 1024 bytes or more over | `free_path_write_long_none_refused` refused with other words at the same place, `root operation not walkable yet: a field path` |

### Not reached by a witness

Eight mutants change no witness:

- `stmts255`, `emitf255`, `chainemit255`, `twoseg255` put 255 back into a join
  or a chain that a general route stands behind: a statement's own path, an
  expression's whole path and its chain, the two-name path of the check. That
  route takes a long text as well: the store into a declared field, the read
  by an occurrence and the field of one name in `path_long_names` go through
  it.
- `g_is_call`, `g_primary`: the calls of `path_long_call`, in an initializer,
  inside an expression and as a statement, take other routes.
- `g_body`: that gate chose only the words of a refusal, `unknown field path
  root` against `unsupported body`.
- `g_native_ty`: the type of a composite with a long path is found by another
  route.

Their edits are the same change as the witnessed ones and are kept; no row
tells them apart. A ninth, `proot64`, put back the 64 bytes into which the
name of a machine local rooting a path was copied. No witness reached it: a
machine local is a value of the C door. That edit was taken out, and the
limit is listed below.

The fields of a path as an actual (`l2_actual_path`, `l2_emit_actual_path`,
`l2_actual_ns`) are reached by no witness either. The shapes that reach them
are refused by older limits with short names as well: a merge result's field
as an actual (`unresolved name`), and a Structure-typed field of a
declaration copied in a method (`root operation not walkable yet: a
Structure-typed field in a method`). Their edits are kept.

### What still has a fixed size

Off the route of a path, older than it, each a located refusal; listed in
[FIXED-BLOCKS-AUDIT](defects.md#fixed-blocks-audit) for their own step:

- The emitter's text of one expression, 1023 bytes (`l2_cat`, `expression too
  long`), and the buffers that feed it: a raw C path (`l2_emit_raw_path`), a
  pointer dereference (`l2_prefix_deref`), a `sizeof` (`l2_emit_sizeof`), a
  field path actual written as nested reads of a Structure
  (`l2_emit_actual_path`, at most 32 names), the members of a raw C record.
- The name of a machine local that roots a path, copied into 64 bytes
  (`l2_emit_path_to`).
- The names of methods, of formals and of declared throws: 62 bytes (`name
  too long`).
- Counts: eight callable formals written in place in one method (`too many
  callable formals written in place`); 32 captured fields (`l2_mad_cap_emit`).
- The words of some refusals cut a long name short (`snprintf` into 240 or 256
  bytes): the words, not the refusal.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_02` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/opus_l3_02` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_03` (full harness) | RED40/1813: against `opus_full_02` FAIL→OK 0, OK→FAIL 0; the ten added rows all pass; the 40 red rows and their messages are unchanged. The staged translator is the git blob `7dc142e4` of the bytes committed with this section. |
| `build/l2_harness/opus_focus_pathB1` (focused, before the gates) | The ten new rows pass. |
| Replay of the 1802 translations recorded by `opus_full_02` | Generated L1, exit, messages and the count of allocations the same on every row. |

**Next.** The order Codex's reply set after this step: HEAD -- the rows that
hold the reading the author rejected for a head no binding established
([HEAD-ROLE-UNESTABLISHED-ROWS](defects.md#head-role-unestablished-rows));
FACTORY -- the receiver `@:` of a factory's result
([FACTORY-RESULT-RECEIVER](defects.md#factory-result-receiver)); T7 -- the
copy's lexical links by the author's rule, with the complete copy it needs
([T7-NODE-LEXICAL-LINKS](defects.md#t7-node-lexical-links)); A -- the cost of
a merge in a large unit, diagnosed and repaired over the correct copy
([MERGE-COST-GROWS-WITH-UNIT](defects.md#merge-cost-grows-with-unit)); then
the receiving-edge debts (c) to (f), the duplicate stop under its real proof,
the numeric conversion at the receiving edge, the outstanding K/G5
dependencies, the clean kernel and stages 8 and 8a.

<a id="head-role-established"></a>
## 75. The role of a head: a read before the statement establishes the input (Codex's reply OPUS-CODEX-20261005-01, HEAD)

The reply set this step after B: "HEAD-ROLE-UNESTABLISHED-ROWS: migrate/check
the three obsolete unestablished-input rows, audit unit_asgn_fallback, and
verify the common role resolver with established-input positives. If this
exposes a real translator defect, repair its universal classification path,
not a test-spelling branch." On the self-reading row it answered: "Reading
hidden in that definition's own tail does not circularly establish a
primitive input, and the later return does not retroactively change the
head's role." Its review of the repair, before the gates: "independently
preceding free VALUE read may establish the input; the statement's own tail,
later reads or caller homonym do not. Apply the same resolved role across
declaration collection, free-input collection, checking, native emission and
retained-graph emission."

### What was measured

On the translator of `849ea1b5`, by scratch probes outside any gate:

- A method that reads a name as a free name and then writes it -- `int: was
  hidden`, then `hidden: hidden + 1` -- is refused at its return, `return value
  has incompatible type`: its statement was taken for the definition of a
  named Structure. The cause is the order of the passes. The declarations of
  a unit are collected (`l2_collect_asgn_binds`, which asks
  `l2_local_ns_shape`) before the scan of free names (`l2_dyn_local`) has made
  any input, so a head the method had read looked established by nothing; the
  passes after the scan see the input and answered the other way.
  `unit_own_dirty_rhs` (`if: quote = 65` before `quote: 88`) and
  `unit_arg_addr_dyn_types` (`setnull(@: dp)` before `dp: dp`) were red on it:
  `more arguments than quote has formals`, `more arguments than dp has
  formals`.
- The rows that held the reading the author rejected: `unit_colon_hidden_update`
  ran and expected 5 from `hidden: hidden + 1`; `target` in `unit_free_conv` and
  `unit_walk_free_conv` wrote `k` without reading it; `unit_asgn_fallback`
  expected the root's call refused for an input `x` of `inc`.

### What is built

1. **The role of a head asks for a read before its statement.** After its
   existing checks, `l2_local_ns_shape` asks whether the method read the head
   as a free name before the statement (`l2_head_read_before`). The scan of
   free names answers it (`l2_scan_body`), run as a probe from the method's own
   environment, as `l2_own_lexical` reads it: the source site saved, the scopes
   cleared, the method's visibility. The probe ends at the statement, before
   its tail is read. A read counts where the scan meets the name as a name
   that no declaration in sight gives (`l2_scan_ident`): what the scan would
   make an input.
2. **Under the probe the scan makes nothing.** Its declaration routes call
   neither `l2_own_add` nor `l2_own_output_add`; `l2_scan_bound`, the marks of
   a unit field and the captures (`l2_scan_node_use`) do nothing;
   `l2_scan_ident` returns before any input. No declaration is published and
   then taken back.
3. **A statement before keeps the role its collection gave it.** Inside the
   probe the role of an earlier head is the row its statement declares
   (`l2_own_by_decl`). Collection runs in source order, so each earlier
   statement is collected when a later one asks, and the probe never asks
   inside itself: the dependency follows the order of the statements.
4. **A call before it is bound.** The probe runs at collection, before
   `l2_bind_calls`. It reads a call as its binding will (`l2_scan_actuals`,
   `l2_actual_formal`): a Frame among the actuals whose head names a formal of
   the callee is that formal's argument (`l2_bind_actuals`); its head is the
   label, and only its body is read. A bound call is read by its projection,
   as before.
5. **One answer for every pass.** The answer is kept for each statement until
   `l2_release` (`l2_head_read_kept`). Collection, the scan of free inputs,
   the check, native emission and the walker ask the same question and get
   the answer collection found; no prefix is scanned twice.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_head_established_read`, walked twin | A read before the statement makes the head the method's input; the update stays in its activation. `outer` says `OUTER 5 4`. |
| `unit_head_established_lexical`, walked twin | A declaration in sight establishes the head; neither the caller's value nor the unit's changes: `OUTER 5 4 0`. |
| `unit_head_block_read`, walked twin | A read in an anonymous block that runs before the statement counts. |
| `unit_head_initializer_read`, walked twin | `int: x x` in a block reads the free `x` -- an initializer never reads the row it declares (Q24) -- and that read establishes `x` for the method after the block. |
| `unit_head_chain_read`, walked twin | The role of each head follows the statements before it: an assignment whose head was read runs, and its tail reads the next head. `OUTER 13 4 4`. |
| `unit_head_unestablished_return_refused` | The author's example, `x: j` then `return: x`: refused at the return. |
| `unit_head_later_read_refused` | A read after the statement establishes nothing: the later read finds the Structure where a number is asked. |
| `unit_head_label_refused` | The label of a named actual and a dormant body (a field `x` of `S` and `S`'s update of it) establish nothing: refused at the return. |
| `unit_head_shadow_refused` | A read of a block's own declaration is no free read; after the block `x: v` defines a Structure: refused at the return. |

The walked twins walk the method whose head is written (`WalkedMethods`); its
caller prints, since a C door keeps a method native under `--walk-methods`.
On `849ea1b5` four of the five positives are refused at translation; the
lexical one already passed, the declaration in sight being the rule it had.
The four refusals are refused there with the same words.

### Migrations

- `unit_colon_hidden_update`: refused at 12:13, `return value has incompatible
  type`, the decision named in its header.
- `unit_asgn_fallback`: `inc` has no input `x` now, so neither call of it needs
  one. The tail of `x: x + 1` is the body of the Structure `x`, checked whether
  `x` runs or not, and the `x` it reads is a free name nothing binds: refused
  where it stands, 17:8, `unresolved name`, as `unit_local_ns_stmt_unresolved`
  is.
- `unit_free_conv`, `unit_walk_free_conv`: `target` reads `k` before writing it
  (`size_t: was k`, which must be 5). Section 73 planned a refusal at the
  return instead; the row's purpose, an assignment to an input across a
  conversion, needs an established input, and the question's own shape is now
  `unit_head_unestablished_return_refused`. The rows now stop at `ret_expr`:
  16:17, `root operation not walkable yet: a U literal in a signed type`, an
  older limit of the retained graph's producer that the refusal at `target`
  hid. Measured on `849ea1b5`: the same program without `target` is refused by
  it ([FREE-CONV-U-LITERAL-WALK](defects.md#free-conv-u-literal-walk)). They
  stay red, required positives.
- `unit_own_dirty_rhs` and `unit_arg_addr_dyn_types`, red on the defect, are
  green: the latter says its eleven lines exactly.

### The probe makes nothing

- The 1812 translations recorded by `opus_full_03`, replayed with this
  translator: the generated L1, the exit and the messages are the same on
  every row but the two that now translate. The count of allocations differs
  on 104 rows: the kept answers and the probes' own copies of the scope stack.
- A cross-check build, kept in the scratchpad and never committed, finds the
  answer again every time a role is asked and compares it with the kept one.
  No answer differs on the 1812 translations or on the new rows, and its L1 is
  this translator's on all 1812: the scan run again on every ask makes no row,
  capture or input and changes no field order.

### Mutants

Each mutant is built in a stage of its own from this step's translator. The
witnesses are translated natively and with the methods walked; a positive that
still translates both ways runs natively, with the root walked and with the
methods walked; and the 1812 recorded translations are replayed with the
mutant.

| Mutant | Puts back | Result |
| --- | --- | --- |
| `m_nohit` | no read is found: the defect of the order of the passes | `unit_head_established_read`, `_block_read`, `_initializer_read`, `_chain_read`, `unit_own_dirty_rhs` and `unit_arg_addr_dyn_types` refused at translation again |
| `m_rhs` | the statement's own tail is read before the probe ends | `unit_colon_hidden_update` translates; `unit_asgn_fallback` is refused at the root's call, `unbound dynamic input x`: the reading the author rejected |
| `m_selftail` | the statement itself is read, its head as a target and its tail | `unit_head_unestablished_return_refused`, `_later_read_refused`, `_shadow_refused` and `unit_colon_hidden_update` translate; `_label_refused` and `unit_asgn_fallback` are refused elsewhere; 91 recorded translations change |
| `m_nostop` | the probe reads past the statement: a later read counts | the same six rows; 94 recorded translations change |
| `m_anyread` | any spelling of the name counts, resolved or not | `unit_head_shadow_refused` translates |
| `m_role1` | inside the probe an earlier head is always a definition | `unit_head_chain_read` refused, `unresolved name` |
| `m_role0` | inside the probe an earlier head is always an assignment | `unit_head_label_refused` translates: the dormant body is read |
| `m_labels` | a named actual's label is read before the call is bound | `unit_head_label_refused` translates |
| `m_norestore` | the probe leaves its environment behind | `unit_local_ns_node_nested` refused, `unit_site_local_model_scope_refused` translates, `unit_local_ns_node_outer_refused` refused otherwise; 11 recorded translations change |

### Not reached by a witness

Six mutants take a gate off the probe and change no witness and no recorded
translation: `m_bound` (`l2_scan_bound`), `m_add` and `m_out` (the routes
that would call `l2_own_add` and `l2_own_output_add`), `m_marks_asgn` and
`m_marks_at` (the marks of a unit field) and `m_use` (a capture). The marks
are those the scan of free inputs makes for the same statements, and a mark
set twice is one mark. The rows of a colon, a binding and a letter
declaration already exist when the probe meets them: collection made them.
Only the empty Structure `f()` has its row made by the scan, and no program of
the gates writes one before a head of its method. These gates keep the probe
from writing anything; no row tells their absence. `m_nokeep`, which finds the
answer again on every ask, changes nothing either: keeping it saves scans, and
the cross-check above shows the answers equal.

### A boundary

A declaration whose type does not resolve -- `@: Model ref` before the local
`Model` is declared (`unit_site_local_model_future_refused`) -- is read by the
scan as names, and the probe follows the scan: there `Model: (int: value 1)`
is now an assignment. The program is refused at that declaration first, in the
same words; it makes fewer allocations, since no local Structure is
registered.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_03` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/opus_l3_03` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_04` (full harness) | RED36/1827: against `opus_full_03` FAIL→OK 4 (`unit_own_dirty_rhs`, `unit_arg_addr_dyn_types`, `unit_colon_hidden_update`, `unit_asgn_fallback`), OK→FAIL 0; the fourteen added rows pass; the other red rows and their messages are unchanged. The staged translator is the git blob `ae30500a` of the bytes committed with this section. |
| `build/l2_harness/opus_focus_headrole1` (focused, before the chain rows were added) | 95 of 97 rows pass; the two red rows are `unit_free_conv` and its walked twin, on FREE-CONV-U-LITERAL-WALK. |
| Replay of the 1812 translations recorded by `opus_full_03` | As in [the probe makes nothing](#head-role-established) above. |

**Next.** FACTORY: the receiver `@:` of a factory's result
([FACTORY-RESULT-RECEIVER](defects.md#factory-result-receiver)); then T7, A
and the remainder in the order of section 74. Before G5, the fixed sizes that
step B left are bounded cleanup subtasks of the plan.

<a id="factory-receiver"></a>
## 76. The receiver of a factory's result; a dormant body's free names (Codex's reply OPUS-CODEX-20261005-01, FACTORY, and its review of the HEAD checkpoint)

The reply set FACTORY after HEAD: "implement the ordinary @: receiver's
evaluated value/result route and explicit reference store in both native and
retained-graph execution. [...] @: takes the returned ordinary reference; do
not insert unary @, collapse reference depth, introduce a factory
object/registry, or add args to ordinary named Structures. Explicit
named-actual calls follow the same path. With the implementation, migrate old
short-form factory-result fixtures to @:, and gate dormant plain named-body
controls so an unknown ordinary definition does NOT execute its body. [...] A
new incompatible outcome outside those identified migrations remains a real
regression." Its review of the HEAD checkpoint repeated it -- "Continue FACTORY
through the common @: receiver/result/value/reference-store route and
documented migrations, with dormant-body controls and ordinary named actual
binding" -- and opened the question of the body of `x` in
`unit_asgn_fallback`, answered [below](#dormant-body-free-input).

FACTORY did not need T7 first: the receiver stores the reference that the
existing construction of the returned callable gives.

### What is built

1. **The receiver.** `@: h f(a)` is a statement whose head is `@`, whose
   first field is the name `h` and whose second is the Frame of a call of a
   method (`l2_receiver_call`). The call is an ordinary Frame: the binding
   binds its actuals, a named one among them; the check is `l2_check_call` of
   that Frame; native code is `l2_emit_call` and the store into `h`; the walk
   builds the same call (`l2_rw_mad_store`). The machinery of a callable
   merge's store, which recognized the shape `h: f a`, recognizes the receiver
   now (`l2_mad_store_stmt`, `l2_store_host`, `l2_store_name`).
2. **The receiver's field is a reference.** `h` is declared by `@`, so its
   slot holds a pointer cell (q26), and the cell holds the callable the call
   returned. No unary `@` is inserted. The test driver's physical paths cross
   such a cell only by an explicit step, `deref` (`ref N` is the driver's own
   option); `graph_shape_t7_local_definition` observes the copies through it.
3. **The short form is a definition.** `l2_call_value` is gone from
   `l2_unit_role` and `l2_local_ns_shape`: an unknown head whose tail begins
   with a method's name defines a named Structure and calls nothing (Q58). A
   bare method name in its body is the method's application with no actual.
4. **The unit's order.** A receiver above an item of the root declares its
   name for that item (`l2_head_absent`): `h2: 3 4` below `@: h2 make2(100)`
   applies `h2`. A method above the receiver has no binding of `h2`
   (`unit_held_call_above_unknown_head`). A first version put the receiver in
   `l2_unit_declares`, which `l2_local_ns_shape` asks over the whole unit; it
   gave the methods above the receiver a binding, and the focused run caught
   that row.

### Migrations

171 fixtures -- 233 rows of the gate, 246 receivers -- are rewritten from
`h: f a` to `@: h f(a)`, and the first line of each names the migration. The
census was taken by the translator's own classification (an instrumented
build), not by a text search. It counted the unit's top-level statements and
the statements of methods; two fixtures with the store in a nested body of
the root (an `if:` block), `unit_held_call_block` and
`unit_held_call_block_refused`, were found by replaying the 1826 translations
recorded by `opus_full_04` with this translator: outside the census only
their three rows changed. Needles with a line number moved down by the header
line. The seven rows that were red at `opus_full_04` are red with the same
words.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_factory_receiver_named`, walked twin | `@: h make2(n: 100)` in a method: the call binds its named actual as any call; `h(1)` is 101; `OUTER 101 7`. |
| `unit_factory_short_dormant`, walked twin | `s: shout` and `t: shout()` define `s` and `t` and call nothing: only `DONE` is printed, natively, with the root walked and with the methods walked (the parenthesized spelling joined in the next commit). |
| `unit_factory_short_args_refused` | `add5: makeAdder 5`: the bare `makeAdder` in the body is an application with no actual, refused where it stands, 11:7, as any call that misses a required argument (`l2_check_body` -> `l2_check_discard` -> `l2_check_call`). |
| the migrated rows | `unit_make_adder*`, `unit_held_call_*`, `unit_t6_*`, `unit_named_actual_held*` and the rest receive the factory's result through `@:`. |

### Mutants

Each is built from this step's translator in a stage of its own; the
translations recorded by the focused run `opus_focus_factory3` are replayed
with it.

| Mutant | Puts back | Rows that change |
| --- | --- | --- |
| `f_short` | the short form stores the call's result again | `unit_factory_short_dormant` and its twin: refused, `unresolved name` at `s` |
| `f_norecv` | the receiver is not recognized | 219 rows refused, `unsupported body` (frame `@`) |
| `f_noscan` | the receiver's call is not read by the scan of free names | 203 rows refused, `unresolved name` at the receiver's name |
| `f_nodecl` | a receiver above declares nothing for the root's items | `unit_held_call_statement`, `_nullary_statement`, `_bare_name` and their twins refused |

<a id="dormant-body-free-input"></a>
### A dormant body's free names

Codex, on `unit_asgn_fallback`: "the author's return:x answer ALONE does not
make unit_asgn_fallback a normative negative. [...] Defining a named body does
not execute it; the spec permits unresolved/free names to be retained and
resolves required inputs at actual calls (semantics #construction and
#dynamic)." And: "If it is a potentially supplied free value and only the
current translator cannot lower that generic body, record a located
implementation/coverage limit, not an author-approved language prohibition. A
later explicit call without an admissible source is a CALL failure; don't
hoist it onto inc's inert definition."

Measured with a debug build of this step's translator, by the stack at
`l2_error`. The body of a named Structure defined in a method gets a callable
row of its own, after the root's row, and a free name of the body is an input
of that row. Nothing calls the body, so no source gives the input a type, and
the closure of the inputs (`l2_dyn_close` -> `l2_dyn_typed`) requires a type
for every input of every row: `unresolved name` at the free name. In
`unit_asgn_fallback` it is row 4 of 5 (the Structure `x` in `inc`), input
`x`, 17:8 at `01ecd69b`; in `unit_local_ns_stmt_unresolved` row 2 of 3 (`S`
in `m`), input `nosuch`, 7:12. The name is neither unresolved by the norm nor
the Structure itself: it is a free input of the nested callable, which a
caller of it could give.

The same trace over the 38 rows of the gate that expect `unresolved name`:

| Class | Rows | Reading |
| --- | --- | --- |
| a body nothing calls | 2 | the two above: the limit ([DORMANT-BODY-FREE-INPUT](defects.md#dormant-body-free-input)) |
| a free name of the root | 4 | no caller can exist: refused by the norm |
| an untyped input of a method or of a unit Structure (`l2_dyn_typed`) | 18 | mostly called with no source: refused by the norm, but at the use of the name, not at the call that starts the chain. `broken` in `unit_colon_graph_unknown_value_refused` is never called: the class of the bodies above. `Counter` in `unit_named_struct_dead_tail_refused` is called, and reads its name only after a bare `return`: not that class (Codex's answer below; the first version of this table put the two together). |
| a path segment that names nothing (`l2_check_fields`, `l2_check_primary`) | 14 | another mechanism |

The rows. `unit_asgn_fallback` and `unit_local_ns_stmt_unresolved` were
expected refusals; they are required positives now, with an observable
result: `inc` returns 7 to both of its callers, `m` returns 7. Two controls
are new: `unit_dormant_free_body` (`y: z + 1` in `make`, nothing binds `z`,
nothing calls `y`; the root says `MADE 7`) and
`unit_dormant_free_body_call_refused` (`y()` called with no source of `z`:
refused at the root's call of `make`, where the chain starts, 13:10,
`unbound dynamic input z`, as
`unit_held_call_required_input_unavailable_refused`; today it is refused at
`z`, 8:8). The four are red until the limit is built.

Codex's answer to the question this section sent (the review of the FACTORY
checkpoint): "Yes: use one admission rule for typed and still-untyped free
inputs. A required input with no admissible source makes the CALL
inadmissible. A type learned elsewhere must not decide whether this failing
call is reported as an unresolved use or a missing binding." The rows of the
third class move their expected primary location to the inadmissible call
"after the SAME completed source/requirement closure used for typed inputs";
an original read may be a secondary location. On the two rows: `broken` is
never called, "the same dormant-callable problem", and becomes a required
positive with an observable host result beside an explicit call without a
source, refused; of `Counter`, "Do NOT convert it to a positive merely
because the read is after return. Counter IS explicitly called. Its written
callable body contains g; #dynamic says free names change the interface." Its
call with no source of `g` is refused at that call, and two witnesses go
beside it: a caller that gives `g` (the call is admitted, the tail does not
run, the retained graph holds it) and an intrinsically invalid dead tail.
These migrations come with the repair; the locations measured at `1b86feaf`
stay as dated evidence
([DORMANT-BODY-FREE-INPUT](defects.md#dormant-body-free-input)).

### The probe makes nothing, before the real scan

Codex asked for "a focused compiler-level before/after probe check with that
empty definition preceding a later queried head; assert no
declaration/input/capture/use-mark publication, even BEFORE the real scan".
A build kept in the scratchpad and never committed counts, around every probe,
the own rows, the inputs of every row, the captures and the use marks of the
method, and says any difference; a second instrumentation says when a probe
starts and when the scan reaches the declaration of an empty definition.

- `unit_head_after_empty_decl` (`note()` before the queried head
  `hidden: hidden + 1`; `OUTER 5 4`, with a walked twin) shows that section
  75 said too much: `note()` is a named Structure whose row collection makes,
  before it asks the role of `hidden`, so the probe meets an existing row.
- The scan's own declaration of an empty definition (`l2_empty_struct_decl_shape`
  in `l2_scan_body`) is reached by none of the 1826 translations of
  `opus_full_04` and none of the 260 of `opus_focus_factory3`. It is reached
  where the head of `f()` was read before as a free name -- `int: k f`, then
  `f()`, then the queried head -- and there inside the probe, before the real
  scan; that program is refused afterwards, `unsupported body` at `f()`.
- On that program the gated probe changes nothing (`own 0 dyn 0 cap 0 uses
  0`), and the mutant `m_add`, which takes the gate off the declaration routes,
  adds one own row during the probe (`own 1`). Over the 145 probes of the
  1826 translations and the 6 of the focused run no count changes, with the
  gate or with `m_add`: no gated program reaches that route.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_04` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/opus_l3_04` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_05` (full harness) | RED40/1836: against `opus_full_04` FAIL→OK 0; OK→FAIL 2, `unit_asgn_fallback` and `unit_local_ns_stmt_unresolved`, the two expected refusals that are required positives now; nine rows added, seven green and the two controls of the dormant body red; the other red rows and their words unchanged. The staged translator is the git blob `5c15e0d6` of the bytes committed with this section; the 182 declared paths were hashed before the run, and the live and the staged bytes are those. |
| `build/l2_harness/opus_focus_factory3` (focused) | 260 rows, 11 red: the seven red at `opus_full_04`, with the same words, and the four rows of the dormant body. |
| Replay of the 1826 translations recorded by `opus_full_04` | The migrated rows and the three rows of the two fixtures with the store in a block change; no other row. |
| `build/l2_harness/opus_full_06` (the next commit: the parenthesized spelling `t: shout()` in `unit_factory_short_dormant`) | RED40/1836, against `opus_full_05` no row changed. The translator and the driver are the bytes of the gates above. The mutant `f_paren`, the parenthesized spelling the call's value again, refuses the row at `t`, 17:1. |

**Next.** T7: the source-copy rule of the author for a merge's lexical links
([T7-NODE-LEXICAL-LINKS](defects.md#t7-node-lexical-links)); then A and the
remainder in the order of section 74, with
[DORMANT-BODY-FREE-INPUT](defects.md#dormant-body-free-input) among the G5
blockers.

<a id="t7-copy"></a>
## 77. A merge's node under the copy of its model's lexical tree (Codex's reply OPUS-CODEX-20261005-01, T7)

The reply: "T7-NODE-LEXICAL-LINKS (and directly necessary complete-copy
dependency): implement the AUTHOR's source-copy/remapped-parent rule, not
merge-site reparenting or re-resolution. Required asymmetric 9 / 50 / original
mutation 11 witness: with no dynamic input the copy reads 9 before and after
original mutation; the original observes 11; explicit node follows its copied
source relation. Also test shared targets/cycles, immutable/native retention,
actual graph address targets and native/walker parity. Include the full
necessary used mutable lexical closure, not an extra environment graph." The
author: "merge делает копию используемой части дерева, при этом parent
переписываются *внутри копии*, какое это имеет отношение к месту копирования?"
([the author's words](../LMX_blog/2026-10-05.md#merge-parent)).

### What was measured

On `62ef45df`, the two programs of the defect entry, written with the receiver
`@:`, natively, with the root walked and with the methods walked: the copy
reads `9 11 9` where the original reads 11 (`T7 9 11 9 11`), and through
`node\other` `T7 9 11 11`. The node was built under the `node` of the method
that performed the merge (`l2_t7_at\parent`), and its body was a view built
over the live unit (`l2_view_build_<site>(l2_program_unit, node)`): the
fallback of a free name was an `AT` of the unit's own cell. A merge of a model
nested in a method is refused at translation ("a callable merge needs one
model"): every model is a method of the unit.

### What is built

1. **The copy.** The node's constructor (`l2_t7_make_<site>`) copies the
   model's lexical tree at every merge. The model is a method of the unit, and
   its lexical tree is the unit's: `l2_t7_emit_lex_copy` copies it with the one
   traversal merge and Message creation share (`lmx_graph_copy_profiles_owned`).
   Shared targets and cycles keep their shape; every copied Structure's parent
   is the copy of its own; a reference field's cell is copied and its pointee
   shared (-186 k3); the program's qualified branches are retained by their
   exact profiles, as a merge retains its operands'.
2. **The node under the copy.** The node hangs under the copy of the unit, not
   at the place of the merge. Its view is built over the copy: the fallback of
   a free name and `node\x` read the state of the merge.
3. **The models are the program's.** A model operand of the view -- the model
   of an `OF` or a `PUT_OF`, of an admission, a witness of an input -- is read
   from the program's unit (`l2_nst`, `l2_rw_model_own` under
   `l2_rw_type_base`). The kernel keys a record of admission by the
   requirement's address: a value admitted before the merge has its record
   against the program's Structure and none against the copy's. That this is
   the right source of every model operand is not shown (corrected after
   Codex's review, [section 78](#t7-trailer-only);
   [T7-MODEL-OPERAND-SOURCE](defects.md#t7-model-operand-source)). The
   first build took the models from the copy too, and the three rows whose node
   reads a reference the caller gives (`unit_t7_reference_held`,
   `unit_t7_actual_reference`, `unit_t7_actual_typed_reference`) stopped with
   `walk error: INVALID`: `lmx_implements_slot` found no record of the caller's
   value against the copy of its model. The focused run caught it.
4. **The test driver.** A physical path climbs to a Structure's parent by the
   step `up`. A row with qualified roots may carry post paths: the root facts
   skip `postpaths ... endpostpaths`.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_t7_copy_lexical_formal`, walked twin | `make`'s own formal `other` is 50; the copy reads the unit's 9 before and after `bump` writes 11, and the original `add` reads 11: `T7 9 9 9 11`. |
| `unit_t7_copy_lexical_node`, walked twin | The same through `node\other`, the node's parent: `T7 9 9 11`. |
| `graph_shape_t7_copy_parent`, walked twin | From `w`'s cell (`deref`, `up`): the node's parent is a distinct copy of the unit; its `other` and `m` are distinct objects, `other` 9 and `m\v` 4; the copied `m`'s parent is the copy, as the original's is the unit; the qualified branch `E` is the same object. |

### Mutants

Each is built on this step's translator and driver, in a stage of its own.

| Mutant | Puts back | Result |
| --- | --- | --- |
| `t_live` | the view over the live unit | `T7 9 11 9 11` |
| `t_site` | the node at the merge's place | `T7 9 11 11`; the copy's paths fail |
| `t_nokeep` | no qualified branch retained | `samepath` of `E` fails |

### Limits

- The whole lexical tree of the unit is copied, not only what the body uses:
  the cost of a merge grows with the unit, step A
  ([MERGE-COST-GROWS-WITH-UNIT](defects.md#merge-cost-grows-with-unit)).
- A failed copy stops the program, as every other failure of this
  constructor does: the throw named `merge` from building a node is not built.
- Records of admission are not copied with values. The reads probed do not
  need one (scratch programs outside the gate, on this step's stage).
  `node\m\v` in a node reads 4 from the copy natively, with the root walked
  and with the methods walked: its steps go through own slots, without a
  model. A letter the unit received stays shared, its cell copied: the node
  gives the copy's `m` to a typed formal, and the letter is admitted to the
  program's `MainLetter` by the record of its reception -- natively. With the
  root walked the same program stops at `walk error: UNSUPPORTED` with no
  merge in it too, on `62ef45df` as well.
- A method whose body is only its `return:` crashes the translator as the
  model of a callable merge, before this step as after it
  ([T7-TRAILER-ONLY-MODEL-CRASH](defects.md#t7-trailer-only-model-crash)):
  the next checkpoint.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_05` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/opus_l3_05` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_07` (full harness) | RED40/1842: against `opus_full_06` FAIL→OK 0, OK→FAIL 0; six rows added, all green; the other red rows and their words unchanged. The staged translator is the git blob `177ba95d` of the bytes committed with this section; the six declared paths were hashed before the run, and the live and the staged bytes are those. |
| `build/l2_harness/opus_focus_t7c` (focused) | The 28 rows whose translation changes and the six added: 34 green. |
| Replay of the 1835 translations recorded by `opus_full_06` | The 28 rows that build a merge's node change their L1, and only their L1: no exit and no message differs. |

**Next.** A: the cost of a merge, diagnosed and repaired over this copy
([MERGE-COST-GROWS-WITH-UNIT](defects.md#merge-cost-grows-with-unit)); then
the remainder in the order of section 74.

<a id="t7-trailer-only"></a>
## 78. A trailer-only model of a callable merge; the source of the view's model operands (Codex's review OPUS-CODEX-20261005-01)

Codex's review of section 77: "The 9/50/11 controls and physical parent
witnesses support closure of the specific live-source/merge-site-parent defect
in the supported unit-method route. [...] Keep T7-MODEL-ONLY-UNIT-METHOD and
the other disclosed producer/reception limits OPEN. Do not erase those limits
under the broad T7 FIXED label." On the crash found while probing it: "This is
an ordinary legal source representation, not malformed input requiring
defensive recovery. Count zero body steps when there is no body, and process
the written trailer by the same optional-body/trailer contract as
l2_pap_steps/l2_rw_methods_count. Count and emission must agree on the same
source identities and ordering. Do not manufacture a body, require a trailer
generally, rewrite the source spelling, return zero, or turn the crash into an
"unsupported body" refusal." And: "Keep a truly descriptor-only fn with
neither executable body nor trailer distinct: its direct invocation still
gains no invented implementation."

### What was measured

A method whose only line is its trailer `return:` (`fn: r () int`, then
`return: k` at column 0) has no body Structure: `l2_m_body[r]` is 0. As the
model of a callable merge it crashed the translator (SIGSEGV), whether or not
anything called the merge, on `62ef45df` and on `f6a3d277` alike. A debug
build under gdb stops in `l2_t7_count`, at the source container it builds from
`l2_m_body[model]\as\structure`; `l2_t7_emit_frames` builds one the same way.
The passes that walk a merge result's steps (`l2_pap_steps`) and a method's
own steps (`l2_rw_methods_count`) take the same method: no body, the trailer
alone. With the return indented the program translated. A descriptor with
neither a body nor a trailer crashed as a model too, in both its spellings
(`fn: d () int`; `fn: test3 () int` with `end: test3`); its direct call is
refused, "not callable".

### What is built

1. **The trailer alone.** The count and frame passes take a model with no body
   Structure as the two other passes do: no source container, zero body steps,
   the written trailer walked. Both passes decide by the one condition,
   `l2_m_body[model]`, and the existing check of `l2_t7_steps` compares the
   number of steps they made. No body is made, no trailer is required, the
   source is not respelled.
2. **A descriptor stays without an implementation.** With neither a body nor a
   trailer the model makes no step, and the merge is refused where it stands,
   "a callable merge needs a walkable body"; the direct call stays "not
   callable".

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_t7_trailer_only_never_invoked`, walked twin | The defect's program translates and runs. |
| `unit_t7_trailer_only_copy`, walked twin | `make`'s own `k` is 50; the copy reads the unit's 9 before and after `bump` writes 11, and the original `r` reads 11; no caller gives `k`. |
| `unit_t7_trailer_only_copy_indented`, walked twin | The same program with the return in `r`'s body: the same values. |
| `unit_t7_trailer_only_formals`, walked twin | A bound and a given formal beside the free name: 5 + 1 + 9 in the copy, 5 + 1 + 11 in the original. |
| `unit_t7_descriptor_model_refused` | `merge(test3)` of a descriptor, invoked through `w`, is refused at 9:13. |

Each positive row runs natively, with the root walked and with the methods
walked.

### Mutants

Each is built on this step's translator in a stage of its own and run over the
five programs, natively, with the root walked and with the methods walked.

| Mutant | Puts back | Result |
| --- | --- | --- |
| `f6a3d277` itself | no fix | every trailer-only program and the descriptor: the translator crashes (139); the indented twin runs |
| `tr_refuse` | the crash turned into a refusal | the three trailer-only programs refused; the indented twin runs |
| `tr_invent` | an empty step made where there is no trailer | `unit_t7_descriptor_model_refused` translates and runs |
| `tr_emit_skip` | the frame pass skips a body-less model's trailer | "internal: a method's steps changed between the passes" on the trailer-only programs |

A replay of the 1841 translations recorded by `opus_full_07`, with the fixed
translator and with the fixed translator whose comments were corrected: no
exit, message or L1 byte differs.

### The source of the view's model operands

Codex: "Please replace "A model is a type; a copy is state" in your
commentary/ledger with the precise distinction you actually implement. L2
#copy-merge/#type-by-range/#lowlevel-address: model names denote ordinary
Structures used as requirements, not a separate nominal type category.
#composition copies ordinary used targets and rewrites their links; retained
native implementations and admitted qualified eternal branches are the stated
sharing contracts. Merely being used as a model is not another semantic
sharing exemption. [...] Absence of a record is an implementation/proof issue,
not evidence that the copy is inadmissible or that the source model must be
selected. [...] If that boundary is not yet demonstrated, record the
model-source/provenance obligation OPEN separately rather than claiming that
INVALID plus an L1 hand edit proved the language design."

What section 77 built is this, and no more: in a merge's view the model of a
path's crossing, the model of an admission and an input's witness are read
from the program's unit, not from the copy. The kernel keys a record of
admission by the requirement's address, so a value a caller admitted before
the merge has its record against the program's Structure and none against the
copy's; that is why the three rows reading a caller's reference stopped with
`INVALID` while the models came from the copy. Section 77's item 3, CORE,
`steps/defects.md`, `steps/current.md` and the translator's comments now say
this, without "a model is a type". That the program's Structure is the right
source of every such operand is not shown. It is registered OPEN on its own,
with the sites, the three categories Codex named -- the receiving
declaration's schema witness, a value read from the copied lexical graph, the
actual candidate -- and the paired control
([T7-MODEL-OPERAND-SOURCE](defects.md#t7-model-operand-source)). The sharpest
case is a merge result used as a requirement: its place was read when the
operation runs, in the view's unit, which is now the copy, while the operand
is read from the program's.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_06` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest), gate exit 0. |
| `build/l3_selftest/opus_l3_06` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_08` (full harness) | RED40/1851: against `opus_full_07` FAIL→OK 0, OK→FAIL 0; nine rows added, all green; no red row's words changed. The staged translator is the git blob `2bc78137` of the bytes committed with this section; the seven declared paths were hashed before the run, and the live and the staged bytes are those. |
| `build/l2_harness/opus_focus_trl` (focused) | The nine added rows and `unit_callable_descriptor_direct_refused`: 10 green. |

**Next.** A: the cost of a merge, measured first -- block-list pushes and
their walked lengths, array-list comparisons, copied nodes, edges and bytes,
allocations, separated by initial arena size, unit size and number of merges
-- then the list link made constant-time under its ownership invariant, with
every entry path audited
([MERGE-COST-GROWS-WITH-UNIT](defects.md#merge-cost-grows-with-unit)).

<a id="merge-cost-a1"></a>
## 79. The cost of a merge measured; the arena links in constant time (Codex's reply OPUS-CODEX-20261005-01, A1)

Codex's reply on A: "The repeated list scan in lmx_arena_blocks_push is real
[...]. The ordinary list-link operation should be constant-time under the
established exclusive-ownership/fresh-detached-node invariant; it does not need
a protective framework. But I have not independently measured that it accounts
for ALL observed merge cost. lmx_arena_array also scans arena->arrays before
linking a descriptor. Count actual push calls, tail/cycle traversal steps,
block count at each call, array-list comparisons, copied nodes/edges/bytes and
allocations [...]. Separate initial arena size, unit/closure size and number
of repeated merges so the causal claim is not inferred from one elapsed-time
curve." And: "The existing malformed-list selftests are implementation
history, not automatic language requirements; migrate any defensive-only
expectations explicitly and replace them with valid ownership/ordering/lifetime
witnesses."

### How it was measured

Counters in a module of their own, compiled into staged copies of the kernel
and never into the tree, printed at the start and the end of every staged
graph copy and of every collection pass: copies, Structures and child slots
copied, values visited, block pushes and the steps their list walk made, the
block list's length, array-list comparisons, lookups of an array by kind, type
and profile and their comparisons, the chunk walk after the range bisection,
chunks and arrays made, payload bytes; in the sweep, blocks visited and
dropped and the steps of each per-block scan. A generator keeps the factors
apart: N named Structures with a method each that copies one of them
(`loc: merge D<i>`) -- the size of the unit; K of the methods called per round
and R rounds -- the number of merges; P fields of an independent const
immutable branch -- storage of the arena a copy should not copy; F fields per
named Structure. The defect's own program is N = K, R = 1, P = 0, F = 1.
Stacks of the running program were sampled by attaching gdb.

### What was measured

**The copy.** A merge copies its operand with its lexical ancestors, so a
data merge in a method copies the whole unit, its code frames included: 64,
90, 142 and 246 Structures a copy for N = 2, 4, 8 and 16 (K = 1, R = 4), 846 to
1039 for F = 64. Repeated merges do not grow it: with N = 4 and R = 16 the
first merge's copy holds 150 Structures and each of the fifteen others 154 --
the method's latest result, and only that, is copied with the unit.
Each copied Structure costs about 5.6 block pushes.

**The block list.** Nothing is freed during the root's turn, so the list grows
by every copy's pushes, and every push walked the whole list: N = 4, R = 16
makes 2.1M steps in the first merge's copy and 17.1M in the sixteenth; the
defect's program at N = 16 makes 822M.

**The sweep.** The stack samples of the defect's program stand in the
collection pass at the end of the turn. At N = 16 it visits 33,232 blocks and
drops about 25,500: `lmx_gc_block_live` scans every array and every chunk for
each block (397M steps), `lmx_gc_block_unlink` scans them again for each dropped
block (286M), `lmx_gc_drop_arrays_in_block` and `lmx_arena_array_drop` scan the
array list (140M each), `lmx_range_drop` finds the interval by a linear scan
and shifts the index (227M), and `lmx_arena_blocks_remove` walks to the tail
with its cycle check (779M) before it searches the member (71M): about 2.04G
steps against the pushes' 822M. Beside them in the copies: 46M comparisons of
the array lookup by kind, type and profile, 19M chunk-walk steps after the
range bisection, 15M comparisons of the array list's duplicate scan.

**The qualified branch.** A qualified branch E of P fields is not a Structure
the merge's operand names, yet with it every copy grew: P = 512 made 3636
pushes a copy against 526 at P = 0, and four merges took 8.6 s against 0.17 s
(the counters compiled in).
The trace: the data merge passes the profiles of its operands only, so the
copy of the unit copies E as well; a callable merge's node copy keeps every
qualified branch of the program by its profile (section 77). A probe that
passes the program's qualified branches to the data merge too made the copy
independent of P -- 526 pushes and 94 Structures a copy at P = 0, 64 and 512,
four merges in 0.74 s at P = 512 -- registered
([DATA-MERGE-COPIES-QUALIFIED-BRANCH](defects.md#data-merge-copies-qualified-branch)).
Each copied field of E cost about three chunks: its value's cell -- an array
made by a request for one cell keeps that count as the size of every chunk it
grows by, so every cell is a chunk of its own, two blocks and an interval --
and the copy of the field's name with the place (`lmx_copy_names`).

Corrected the same day: no program sees the copied E. With one operand, no
body and no map, the data merge's result is the copy of its operand, and the
kernel gives it the container -- the place that executes the merge -- for its
parent (`result\parent: container`), so the copied lexical chain, the unit with
E, is unreachable at once. Driver path facts on a root-level `loc: merge D`
whose D holds a nested Structure: the result is a distinct copy of D with a
distinct copy of the nested one, hanging under the unit itself, and the E it
reaches is the original. Whether the result should hang under the copy of
its operand's lexical parent, as section 77 hangs a callable merge's node, is
asked of Codex: the semantics' composition section, the author's words and
CORE 10.2 do not say the same.

| N = K, R = 1 | time before | push steps | sweep steps |
| --- | --- | --- | --- |
| 4 | 156 ms | 8.0M | |
| 8 | 1308 ms | 68.6M | |
| 12 | 7052 ms | 285.5M | 0.70G |
| 16 | 21844 ms | 822.2M | 2.04G |

### What is built (A1)

1. **A push links in constant time.** `lmx_arena_blocks_push` links a node
   at the head without walking the list. Every production push links a node
   its caller has just made, linked into no list: `lmx_pool_add_chunk` (the
   payload's and the chunk's blocks), `lmx_pool_make_profiled` (the payload's
   block), and the descriptor record `lmx_arena_array` takes from
   `lmx_pool_make_profiled`. The other list operations keep their walk and
   their cycle check: `lmx_arena_blocks_remove` (from `lmx_arena_drop`: a
   revert, the sweep, a pool's rollback), `lmx_arena_blocks_move_all` (an
   arena attached after `lmx_arena_blocks_can_move`: a child arena, a
   delivered post), `lmx_arena_blocks_dispose_all` (a release). No production
   path pushes a node that was ever linked: the sweep disposes what it drops,
   and a revert leaves it detached.
2. **An array joins the arena in constant time.** `lmx_arena_array` links the
   descriptor without scanning the array list. Its entries: a pool
   `lmx_pool_make_profiled` has just made; `lmx_pool_open_profiled`, which
   already refuses an array that holds a chunk -- a linked one -- and takes one
   never opened or released, which unlinks it; `lmx_pool_over`, which only
   selftests call, with records of their own. The sweep unlinks every array of
   a block it frees (D-43), and `lmx_post_sweep_selftest` keeps that witness
   ("D-43 embedded pool left the arena").
3. **The selftest's expectations.** `lmx_arena_blocks_selftest` no longer
   expects a push of the list's own tail ("duplicate tail rejected") or a push
   onto a cyclic list ("push into cycle rejected") to be refused: both are
   outside the push's contract, and only a walk of the list could see them.
   The refusals a push makes in constant time stay ("linked node rejected",
   "missing nonempty payload rejected"), and so do the transfer's and the
   disposal's refusals of a cyclic list. Added: after 32 and 33 pushes onto two
   lists, each list holds every node pushed to it once, newest first. 143
   checks, as before.

A message relayed as OPUS-CODEX-20261005-02 said the two expectations "stay as
registered"; it carried a figure I had not sent, and keeping them needs either
the walk or a mark on the node, which the reply above excludes. I asked Codex
which it means; this section follows the reply.

### Measured after

On the exact bytes of the tree, with the counters compiled in: the copies make
the same work -- 5377 Structures and 406,581 bytes at N = 16 -- with 0 push
steps and 0 duplicate-scan comparisons; the sweep makes the same work but its
own list walks.

| N = K, R = 1 | time before | time after |
| --- | --- | --- |
| 4 | 156 ms | 138 ms |
| 8 | 1308 ms | 1052 ms |
| 12 | 7052 ms | 5632 ms |
| 16 | 21844 ms | 17577 ms |

The rest of the cost is the sweep's per-block scans (A2, held until the
qualified branch is traced -- done above -- and Codex has reviewed it), the
array lookup by kind, type and profile, the chunk walk after the bisection,
and the size of the copy itself.

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_07` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest); `lmx_arena_blocks_selftest` 143 checks, 0 failures. |
| `build/l3_selftest/opus_l3_07` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_09` (full harness) | RED40/1851: against `opus_full_08` FAIL→OK 0, OK→FAIL 0, no row added or removed, no red row's words changed. The three declared paths were hashed before the run; the kernel the gates staged is those bytes, with no counter in it. |

**Next.** The data merge keeps the program's qualified branches
([DATA-MERGE-COPIES-QUALIFIED-BRANCH](defects.md#data-merge-copies-qualified-branch)),
then A2 by Codex's review.

<a id="one-admission-rule"></a>
## 80. One admission rule at the call (DORMANT-BODY-FREE-INPUT, part 1)

Codex's answer, recorded with the defect: "use one admission rule for typed
and still-untyped free inputs. A required input with no admissible source
makes the CALL inadmissible. A type learned elsewhere must not decide whether
this failing call is reported as an unresolved use or a missing binding." The
rows of the third class move their primary location to the inadmissible call
that starts the chain; `Counter`'s call with no source of `g` is refused at
that call, with two witnesses beside it.

### What was measured

On `b9f880fd`: from the root, a callee's input that no one can give (need 2)
was refused at the call only when a type had been learned for it somewhere
("unbound dynamic input"); without one, the closure said "unresolved name" at
the original read. A held call asked its caller only for the inputs of its
model that had a type, and skipped the others: the same program with nothing
to type the name was refused at the read, with a type at the root's call.

### What is built

1. **The root's call.** `l2_dyn_site_callee` refuses, from the root, a
   required input no one can give at that call, whether or not it has a type.
2. **The held call.** `l2_dyn_site_held` asks the caller for every input of
   the model, with a type or not, so a method that calls a held definition
   hands an untyped input on as a typed one; from the root, an untyped input no
   one can give refuses the held call itself, with the word
   `l2_held_unbound` says for a typed one where the call is formed.

### The migrations

A replay of the 1850 translations recorded by `opus_full_09` changes exactly
17 rows, all refusals before and after, none of them a running program.

| Row | Before (at the read) | After (at the call) |
| --- | --- | --- |
| `unit_body_path_bare_refused`, walked twin | 11:13 unresolved name | 14:4 unbound dynamic input j |
| `unit_colon_unknown_value_refused` | 2:10 | 6:1 missing_value |
| `unit_copy_call_missing_input_refused` | 6:11 | 8:1 z |
| `unit_dormant_free_body_call_refused` | 8:8 (red) | 13:10 z, its registered needle |
| `unit_dyn_hidden_from_cross_method` | 15:39 | 21:1 shared |
| `unit_dyn_hidden_from_undeclared_refused` | 7:39 | 17:1 shared |
| `unit_named_actual_free_name_refused` | 9:24 | 12:30 a |
| `unit_named_struct_dead_tail_refused` | 7:12 | 9:1 g, the root's call of Counter |
| `unit_s2_vis_branch_refused` | 5:9 | 15:1 cfg |
| `unit_s7_part_free_refused` | the part's 4:9 | 8:6 k |
| `unit_s7_part_ns_hidden` | the part's 4:9 | 9:6 Counter |
| `unit_s7_part_root_hidden` | 6:9 | 8:4 k |
| `unit_site_future_only_refused` | 2:9 | 11:30 p |
| `unit_sizeof_unknown_refused` | 4:16 | 8:1 unknownName |
| `unit_unresolved_name_located_refused` | 5:8 | 8:5 g |
| `unit_upper_undeclared_refused` | 6:8 | 10:30 NOPE |

The locations measured at `1b86feaf` and `b9f880fd` stay as dated evidence;
seven fixtures' header comments say the new place, with their line counts
kept. Unchanged: the free names of the root and of a program part's root
(refused by the norm), the path segments that name nothing (another
mechanism), and `unit_colon_graph_unknown_value_refused`, whose `broken` is
never called (part 2).

### New rows

| Row | Shows |
| --- | --- |
| `unit_named_struct_dead_tail_given`, walked twin | The root gives `g`, declared above its call of `Counter`: the call is admitted, the tail after the bare `return` does not run (`Counter\n` stays 0), and the retained graph holds it -- `Counter` has five children, four without the tail. |
| `unit_named_struct_dead_tail_invalid_refused` | `n\nosuch` in the dead tail, 7:10: refused by the check, though it never runs. |
| `unit_held_call_untyped_input_refused` | Nothing types `zz`: the root's call of `inner`, which calls the held definition, is refused, 21:8; before, 7:13 at `r`'s read. |
| `unit_held_call_untyped_root_refused` | The root's own held call, 14:9; before, 4:13. |

### Mutants

| Mutant | Puts back | Result |
| --- | --- | --- |
| both parts out (`b9f880fd`'s translator) | the type decides at the root's call; the held call skips untyped inputs | the 16 migrated rows and `unit_dormant_free_body_call_refused` say "unresolved name" at the read; both held rows too |
| the held part out | the held call skips untyped inputs | `unit_held_call_untyped_input_refused` 7:13 and `unit_held_call_untyped_root_refused` 4:13, "unresolved name" |

### Open: part 2

A body nothing calls cannot be compiled without a type for its free input:
with the closure's refusal taken out (a probe), `unit_dormant_free_body` and
`unit_asgn_fallback` stop at the procedure's signature ("dynamic input type has
no formal spelling"), `unit_local_ns_stmt_unresolved` at its statement
("assignment value has unknown type"), a called body under the walk at "a call
with an input that is not a number". What a dormant body compiles to is asked
of Codex; the four positives stay registered OPEN.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_08` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_08` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_10` (full harness) | RED39/1856: against `opus_full_09` FAIL→OK 1 (`unit_dormant_free_body_call_refused`), OK→FAIL 0, added 5, all green, removed 0, no red row's words changed. The 13 declared paths were hashed before the run; the staged translator is their bytes. |

**Next.** Part 2 by Codex's answer; A2 and the data merge's parent by his
review.

<a id="inline-opaque-result"></a>
## 81. The result of a call of opaque type given directly to a Structure formal (RECEPTION-EDGE-DEBTS (c))

Codex's classification, recorded with the debts: "implementation
LIMIT/defect, not a language rule requiring a named result model. Ordinary
result reception must apply the same conversion/admission, evaluating the
producer once." His order names the step "(c) inline opaque result vs named
temp".

### What was measured

On the translator of section 80: `get(same(base))`, where `same` returns
`@: void` and `get` takes `Model: x`, was refused at translation,
"implements is false in function argument". The check took the actual's type
from the callee's result, and a result with no Structure was refused whatever
it was. The same value through a local reference, `@: void q same(base)` and
then `get(q)`, was admitted when the program ran.

At the other receiving places the two spellings already agreed. An assignment
to a typed reference admits both. A return of result Model refuses both,
"implements is false in return value": the class of (f). A typed binding
refuses both: `Model: y same(base)` with "a typed binding whose candidate is
not a name is not built yet", `Model: y q` with "a typed binding's candidate
is not a Structure value", the interim admission of item 474.

### What is built

1. **The actual.** `l2_actual_ns` says that a call whose result is of opaque
   type (`@: void`) is not a Structure actual by its type (2), as it says of
   a name of that type. The check then takes the call as it takes the name:
   it checks the call itself, and the candidate is a dynamic one -- the
   callee's result place (`l2_reference_source`) -- so the forming method is
   recorded as one that can throw. The emission evaluates the call once, into
   its temporary, and admits that temporary (`l2_emit_model_admit`), natively
   and in the walk.
2. **The sources.** The callee's result place reaches the formal
   (`l2_d105_note`). The declarations its returns give
   (`l2_d105_note_return`) are the formal's sources, and the formal's reads
   take them by name.

A result of any other type keeps its refusal: a number, and a reference one
level deeper than the formal.

The same edge reaches a pointer cast given directly to a Structure formal,
`get((cast: (@: void) p))`. The check already took it as a candidate of no
Structure. The cast keeps its operand's sources, but they did not reach the
formal, and the formal was read by position. An Other held by `p` then gave
its first field, 1, where its `value` is 9. That was a wrong value with no
refusal, on the committed translator, natively and walked
([CAST-ACTUAL-READ-BY-POSITION](defects.md#cast-actual-read-by-position)). The
note of item 2 is taken for every actual that is a Frame and no Structure
actual by its type, so the cast's sources now reach the formal as a call's
result does.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_recv_call_result_actual`, `_walk` | A Model given through `same`: 4. An Other whose `value` is its second field: 9, read by name; a read by position would give its first field, 1. The Model through a local reference: 4. `same` is entered once for each of its three calls. |
| `unit_recv_call_result_actual_catch`, `_walk` | `unit_admit_dynamic_actual_catch` with `get(same(p))`: the letter's admission is refused where `pass` forms the input, 42 for both calls, and `get` is not entered. `same` is entered three times. The refusal of `strict(same(p))` is `pass2`'s own `implements`: 43, not 44. |
| `unit_recv_cast_actual_by_name`, `_walk` | A pointer cast of an opaque formal holding an Other: 9, by name; a Model: 4. Where the methods are walked, `run`, which holds the cast, keeps its native word, and `get`, which reads the formal, is walked. |
| `unit_recv_call_number_result_refused` | A result that is a number: refused where it is given, 10:11. |
| `unit_recv_call_depth_result_refused` | A `@@: void` result: refused, 11:11. |

### Mutants

| Mutant | Changes | Result |
| --- | --- | --- |
| the translator of section 80 | the call's result refused by its type | both positives refused at translation, 29:11 and 39:8 |
| `noedge` | the result place does not reach the formal | `unit_recv_call_result_actual` exits 82 and `unit_recv_cast_actual_by_name` 61, natively, with the root walked and with the methods walked: the Other's first field is read |
| `anyresult` | every result with no Structure is received when the program runs | the number row says "root operation not walkable yet: mixed numeric types (a conversion)" at 10:15; the depth row translates, runs and stops at the read, "lmx: invariant: a field path met no Structure" |

### Measured beside, not repaired

- **A Structure of another declaration through an opaque formal is read by
  position.** `fn: run (@: void p)` with `get(p)` inside, where the root
  calls `run(good)` with a Model and `run(wide)` with an Other whose `value`
  is its second field: the second call gives 1, the Other's first field, with
  no refusal. Measured on the committed translator `14e8d29f`, natively, with
  the root walked and with the methods walked. The sources of `p` are
  recorded, and the admission in `run` finds the Other's layout and its pair
  table. But nothing leads from `p`'s place to `get`'s formal, so `get` is
  not marked as one that reads by name and reads by position. With a Thin
  that lacks the field the same program meets the internal error of
  OPAQUE-ACTUAL-KNOWN-LAYOUT: a pair that cannot be built is asked for at
  emission. One cause: an actual that is a name of opaque type records no
  D-105 edge to the formal. The cast's form of it is repaired above; the
  name's goes with (d)
  ([OPAQUE-ACTUAL-KNOWN-LAYOUT](defects.md#opaque-actual-known-layout)).
- **A Structure of another declaration through a local reference of opaque
  type.** `@: void q same(wide)` and then `get(q)` is refused when the
  program runs, as the forming method's `implements`: a handler takes it, 42,
  natively and with the methods walked, while `get(same(wide))` in the same
  program reads 9. The local reference records no source from its
  initializer and gives none to the formal. The admission therefore meets a
  layout the translation has no record of, UNKNOWN, and takes it as a
  refusal. Section 69 had found no program of one translation that reaches
  UNKNOWN; this is one. The same declaration passes, by its record of
  construction. This is the class of OPAQUE-ACTUAL-KNOWN-LAYOUT, a known
  layout through an opaque place, and it goes with (d)
  ([OPAQUE-ACTUAL-KNOWN-LAYOUT](defects.md#opaque-actual-known-layout)).
- **The argument edge does not check the reference type of a name.** A
  local `@@: void` or `@: char` is admitted to a Structure formal at
  translation. An assignment to a typed reference refuses the same pair,
  "assignment value has incompatible type". The `@@: void` one stops the
  process at the read, "lmx: invariant: a field path met no Structure",
  exit 3
  ([ARGUMENT-EDGE-REFERENCE-TYPE](defects.md#argument-edge-reference-type)).

### Measured

A replay of the 1850 translations recorded by `opus_full_09` with this
translator changes no row: exit, messages and generated L1 are the same.

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_09` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_09` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_11` (full harness) | RED39/1864: against `opus_full_10` FAIL→OK 0, OK→FAIL 0, added 8, all green, removed 0, no red row's words changed. The seven declared paths were hashed before the run; the staged translator is their bytes. |

**Next.** (d): dynamic alternatives, with the pair-map reservation of
OPAQUE-ACTUAL-KNOWN-LAYOUT and the local reference measured above.

<a id="possible-candidate"></a>
## 82. A possible candidate the formal cannot admit is refused when the program runs (RECEPTION-EDGE-DEBTS (d))

Codex's ruling, recorded with the debts: "d) A merely POSSIBLE incompatible
dynamic source is not proof that every call is incompatible. Keep the actual
runtime selection and ordinary admission: the good branch succeeds, the
incompatible branch fails catchably at the receiving edge." His order puts
the pair-map reservation of OPAQUE-ACTUAL-KNOWN-LAYOUT with it. Section 81
found two more forms of that defect, both measured on the committed
translator `14e8d29f`. Through an opaque formal, a fitting Structure of
another declaration was read by position: a wrong value, with no refusal.
Through an opaque local reference, the same Structure was refused when the
program ran.

### What was measured

On the translator of section 81, in every mode (natively, with the root
walked, with the methods walked, with both):

| Program | Before |
| --- | --- |
| `get(pick(k))`, where `pick` returns a Model or a Thin as `@: void` | refused at translation at the call, "implements is false in function argument" |
| `get(p)` in `run (@: void p)`, called with a Model and with a Thin | "internal: a pair map of D-105 was asked for after the maps were declared" |
| the same with a Model and an Other whose `value` is its second field | the Other's first field, 1 |
| `@: void q same(wide)`, then `get(q)` | the Other refused when the program ran, 42 by a handler |
| OPAQUE-ACTUAL-KNOWN-LAYOUT's own program | the internal error |
| `unit_free_path_typed_place` with a Thin in the letter's place (the class section 70 measured under a free name) | refused at translation at `far`'s call of `r` |

The spelling Codex asked to verify first: the probes give a Structure as
`@: void` by its name (`return: good`, `run(good)`), a reference of depth
one. None writes the unary `@`, which would add a level and address the
reference cell.

Three causes:

- An actual that is a name of opaque type recorded no D-105 edge to the
  Structure formal. The formal therefore had no source but its own model:
  it was not marked as one that reads by name, and the pair of another
  declaration was first asked for at emission.
- A local reference of opaque type recorded no source of its initializer.
- `l2_d105_close` refused, at translation, every source of an input that
  the input's Consumer cannot admit, whatever brought it there.

### What is built

1. **The name's edge.** The edge that section 81 takes for a Frame actual
   with no Structure type is taken for a name too (`l2_check_call`).
2. **The local's sources.** An opaque reference place holds what was given
   to it: the sources of its initializer, and of a value assigned to it,
   are the place's (`l2_check_receiving_value`), as an opaque formal's and
   an opaque result's are.
3. **The possible candidate.** At an input, a source the Consumer does not
   admit (`l2_d105_fits`, which answers without saying anything) is a
   *possible* candidate when every edge that brings it brings, from the same
   place, a candidate the Consumer admits (`l2_d105_possible`). No call
   through such an edge is proved incompatible. A possible candidate gets
   no pair map and marks nothing (`l2_d105s_no`). The admissions formed into
   that input offer it no alternative, natively (`l2_emit_model_admit`) and
   walked (`l2_rw_admit_project`); `l2_d105_refused` says which. When the
   program runs, its value meets no record and no alternative, and the
   admission refuses it as the forming method's `implements`, which section
   69 built. Any other source the Consumer does not admit is definite and is
   refused at translation, as before. That covers a source no edge brings
   (the checks recorded it at the input and refused it there) and a source
   an edge brings with nothing admissible beside it (every call through
   that edge is incompatible).

The rule is per edge, not per input. An input that receives one fitting
Structure from one caller, and an unfitting one from another caller
directly, still refuses the second call at translation:
`unit_free_path_other_refused` stays at 25:13.

Section 70's class with the Thin alone is still refused at translation, at
`far`'s call of `r`. That program is `unit_free_path_typed_place` with a Thin
in the letter's place and no Model; it is a probe, not a row. The coverage of
`typed`'s reference `box` is known and does not name `value`, so the record
lets the Thin through the reference: the D-105 dump shows it at `box`, at
`far`'s input and at `r`'s. The edge from `far` to `r` brings the Thin alone,
so every call of `r` through it is incompatible. With the Model beside it,
the same program runs (`unit_free_path_typed_place_thin`).

A first draft also exempted the sources the checks recorded at the input.
That exemption changed nothing: no row of 1855 and no witness. The check of
the call refuses such a source before the close sees it. It was taken out.

### The migration

A replay of the 1855 translations recorded by `opus_full_10` changes exactly
one row, `unit_free_path_other_chain_refused`. `has` gives a Model and `bad`
gives an Other, both through `mid`, to `r`'s free `box`. The edge from `mid`
to `r` brings both, so the Other is a possible candidate there. Until this
step the translation refused it at 17:13. Now `has` gives 31, and `bad`'s
call is refused when the program runs, where `mid` forms `r`'s input. With
no handler the refusal leaves the root: the Message is stopped, its failure
counted, thrown 2. The row expects that now, and it has a walked twin. Its
three header lines say so, with the line count kept.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_recv_possible_result_catch`, `_walk` | `pick` returns either: the Model 4; the Thin refused where `run` forms the input, taken by `run`'s handler, 42. `pick` is entered twice, `get` once. |
| `unit_recv_possible_result_uncaught`, `_walk` | No handler: the Message is stopped, thrown 2. The process is not stopped. |
| `unit_recv_possible_result_only_refused` | `pick` returns only the Thin: every call through the edge is incompatible, refused at translation, 22:8. |
| `unit_recv_possible_formal_catch`, `_walk` | The same choice through an opaque formal: 4, 42. |
| `unit_recv_opaque_formal_by_name`, `_walk` | A Model 4 and an Other 9 through an opaque formal, by name. |
| `unit_recv_opaque_local_by_name`, `_walk` | An Other through an opaque local: 9, as through the call directly. |
| `unit_opaque_actual_known_layout`, `_walk` | OPAQUE-ACTUAL-KNOWN-LAYOUT's program: 5. |
| `unit_free_path_other_chain_refused`, `_walk` | The migrated row: 31 for `has`, then `bad`'s refusal uncaught. |
| `unit_free_path_other_chain_catch`, `_walk` | The same with a handler in `bad`: 31, 42. |
| `unit_free_path_typed_place_thin`, `_walk` | The class section 70 measured under a free name: `unit_free_path_typed_place` with a Structure made from Thin in the letter's place. The edge to `r` brings the Model too: the Thin is refused when the program runs, 42, and the Model gives 9. Before, the translation refused the Thin at `far`'s call of `r`. |

Where the methods are walked, every method of these fixtures is walked, the
forming ones included. Their first drafts converted the result with a cast,
which kept the forming method native; they use `size_t` instead.

### Mutants

| Mutant | Changes | Result |
| --- | --- | --- |
| `noposs` | no candidate is a possible one | `unit_recv_possible_result_catch` 38:8, `unit_recv_possible_formal_catch` 21:8 and `unit_free_path_other_chain_catch` 16:13 refused at translation |
| `place` | a source is possible when anything at its input fits, whatever edge brings it | `unit_free_path_other_refused` translates, and its run stops: "lmx: invariant: a field of a formal admitted by name is not carried by its value (no record, or a hole)" |
| `noskip` | the admissions offer a refused candidate its alternative | `unit_recv_possible_result_catch` exits 84 (`get` entered for the Thin), `unit_recv_possible_formal_catch` 82, `unit_free_path_other_chain_catch` stops at the same invariant |
| `noname` | no edge for a name | `unit_recv_possible_formal_catch` and `unit_opaque_actual_known_layout` meet the internal error; `unit_recv_opaque_formal_by_name` exits 61 |
| `nolocal` | an opaque local records no source | `unit_recv_opaque_local_by_name` exits 62 |

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_10` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_10` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_12` (full harness) | RED39/1882: against `opus_full_11` FAIL→OK 0, OK→FAIL 0, added 18, all green, removed 0, the one migrated row green under its new expectation, no red row's words changed. The 12 declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_d2` (focused, before the gates) | The 21 rows of the step and its neighbours, all green. |

**Next.** (e): an opaque reference under a free name of a typed reference,
with ARGUMENT-EDGE-REFERENCE-TYPE.

<a id="hidden-opaque-typed"></a>
## 83. An opaque reference under a free name its reader uses as a typed reference (RECEPTION-EDGE-DEBTS (e))

Codex's ruling, recorded with the debts: "e) An opaque reference supplied as
a hidden input to a typed reference use has the same receiving-edge
conversion/admission as the explicit analogue, provided actual reference
depth/type is correct." Section 81 registered the depth and type side at the
explicit edge as ARGUMENT-EDGE-REFERENCE-TYPE, with this step.

### What was measured

On the translator of section 82, in every mode:

| Program | Before |
| --- | --- |
| `caller (@: void p)` declares `@: void shared p` and calls `relay`, which only hands `shared` on to `observe`, which reads `shared\value`; the unit declares `@: Model shared` | refused at translation at `caller`'s call of `relay`: "incompatible entry signature" |
| the same with `@@: void shared @p` | the same refusal |
| a local `@@: void q` given to a Structure formal | admitted; the run stops at the read, "a field path met no Structure", exit 3 |
| a local `@: char q` given to a Structure formal | admitted |

Three causes:

- The call site compared the types of the caller's binding and of the
  callee's input exactly (`l2_dyn_site`). An opaque reference against a
  graph reference was a mismatch, whatever the value held.
- Even past that check, an input formed from a place with no schema was
  admitted by position against the whole model (`l2_hidden_emit_admit`,
  natively, and two walked forms of it), not by the declaration the value
  carries. The explicit analogue admits it by that declaration.
- The argument edge took a name of any reference type to a Structure formal.
  The assignment to a typed reference refuses the same pairs.

### What is built

1. **The signature.** A caller's `@: void` against an input its reader uses
   as a graph reference is accepted at the call site, at depth one only. A
   `@@: void` is still refused there.
2. **The admission by the record.** A place that holds what was given to
   it, an opaque reference or an opaque formal (`l2_d105_opaque_place`), has
   the declarations that reached it in the record since section 82. Its
   value is admitted by the one it carries, natively (`l2_hidden_emit_admit`)
   and walked (the call of a method and the held call). A place of that kind
   with no record keeps the admission by position.
3. **The reference type of a name.** At the argument edge, a name whose
   reference is a level deeper than the formal's, or of a type no Structure
   is held in (`@: char`), is refused where it is given, with the words a
   call's result of that type has: "implements is false in function
   argument". An opaque `@: void` and a graph reference pass.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_recv_hidden_opaque_typed`, `_walk` | The Model: 11. An Other whose `value` is its second field: 9, by name. A Thin: refused where `caller` forms `relay`'s input, taken by `caller`'s handler, 42. Where the methods are walked, all three are. |
| `unit_recv_hidden_opaque_depth_refused` | A `@@: void` binding: refused at the call, 11:9. |
| `unit_recv_name_depth_refused` | A local `@@: void` given to a Structure formal: refused, 13:11. |
| `unit_recv_name_char_refused` | A local `@: char`: refused, 13:13. |

A replay of the 1855 translations recorded by `opus_full_10` changes no row.

### Mutants

| Mutant | Takes out | Result |
| --- | --- | --- |
| `nosig` | the signature's exception | `unit_recv_hidden_opaque_typed` refused at translation, 22:8 |
| `nonative` | the admission by the record, natively | the Other is not read by name natively: 82 |
| `nowalk` | the admission by the record, walked | the Other is not read by name where the methods are walked: 82 |
| `notype` | the name's reference type | `unit_recv_name_depth_refused` and `unit_recv_name_char_refused` translate |

### Measured

This step and the next one, (f), are one checkpoint with one run of the
gates: [section 84](#opaque-return).

<a id="opaque-return"></a>
## 84. A value of opaque type returned as a typed result (RECEPTION-EDGE-DEBTS (f))

Codex's ruling, recorded with the debts: "absence of a named source schema is
not proved implements-false. Classify the premature refusal as
implementation debt if the actual value satisfies the result's consuming
contract and permitted conversion."

### What was measured

On the translator of section 83, in every mode: `back (@: void p) Model` with
`return: p` was refused at translation at the return, "implements is false in
return value". So was `via () Model` with `return: same(good)`, where `same`
returns `@: void`. The check took the value's type from its declaration or
its call, and a value with no Structure was refused whatever it held. The
emitted return already admits a Structure result when the program runs, by
every field of the result's type (`l2_emit_model_admit`, full receiver). But
a refusal there stopped the process, since only proved values reached it.

### What is built

1. **The check** (`l2_admit_return`). A returned value of opaque type, a name
   of `@: void` or a call whose result is one (`l2_return_opaque`), is a
   dynamic candidate. The declarations that reach it are the result's
   sources (`l2_d105_note`), and the method is recorded as one that can
   throw `implements` (`l2_admit_site`).
2. **The admission.** Such a return's admission, by every field of the
   result's type, refuses as the returning method's implicit `implements`.
   That holds at a trailer's return (`l2_emit_ret_tr`) and at a `return:`
   statement inside the body (the statement's emission), which are two
   emitters. It is formed into the result place, so a candidate the result
   refused has no alternative there (`l2_d105_refused`). Every other return
   keeps its admission as it was.
3. **The result place.** At a result, a source the result's type does not
   admit is a possible candidate on the terms of section 82: every edge that
   brings it brings an admissible one beside it. In addition, every such
   edge must come from a place of opaque type, an opaque reference or a
   call's opaque result, because only those returns refuse with
   `implements`. Any other source is definite and refused at translation,
   as before.

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_recv_opaque_return_typed`, `_walk` | `back` returns its opaque formal as a Model by its trailer: a Model 4; an Other 9, by name; a Thin refused where `back` returns it, taken by `run`'s handler, 42. `back2` returns it by a statement inside its body: the Other 9, the Thin 42. `via` returns a call's opaque result: 4. Where the methods are walked, all of them are. |
| `unit_recv_opaque_return_only_refused` | `back` is given only the Thin: refused at translation at the return, 13:1. |

A replay of the 1855 translations recorded by `opus_full_10` changes no row,
and the final translator of this checkpoint changes none of the 1881
recorded by `opus_full_12`, which hold the rows of (c) and (d).

The first run of the gates of this checkpoint was stopped when its full
harness had begun (`opus_kernel_11`, `opus_l3_11` and the start of
`opus_full_13` remain, incomplete): a probe found that the return statement
inside a body still stopped the process, because only the trailer's emitter
had been changed. The witness's `back2` is that form.

### Mutants

| Mutant | Takes out | Result |
| --- | --- | --- |
| `nocheck` | the check's admission of an opaque value | `unit_recv_opaque_return_typed` refused at translation, 29:1 |
| `notrailer` | the trailer's refusal as `implements` | natively the run stops at "lmx: invariant: an admission by name was refused", at `back` |
| `nobody` | the body statement's refusal as `implements` | natively the run stops at the same invariant, at `back2` |
| `noresult` | the possible candidate at a result | `unit_recv_opaque_return_typed` refused at translation, 29:1: the Thin at `back`'s result |

### Measured beside, not repaired

**A letter through an opaque place is not admitted to its own declaration.**
`fn: pass (@: void p) int` with `return: count(p)`, where
`count (MainLetter: l)`, called as `pass(m)` with the received letter: R0 is
stopped by an uncaught throw. The same holds on the translator of section
80. Its form at the return, `back (@: void p) MainLetter` returning the
letter, is the program Codex classified under (f). Before this step it was
refused at translation; now it translates and stops the same way. Given
directly, `count(m)` admits the letter by its payload (D-57). Through an
opaque place the value is the letter's record, and the admission checks that
record against the model. Whether an opaque reference to a letter is
admitted to the letter's declaration by its payload is asked of Codex
([LETTER-THROUGH-OPAQUE-PLACE](defects.md#letter-through-opaque-place)).

### Measured

The gates of sections 83 and 84, one checkpoint.

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_12` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_12` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_14` (full harness) | RED39/1890: against `opus_full_12` FAIL→OK 0, OK→FAIL 0, added 8, all green, removed 0, no red row's words changed. The eight declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_ef2` (focused, before the gates) | The 40 rows of (c) to (f) and their neighbours, all green. |

**Next.** The duplicate stop under its real proof, then the numeric
conversion at the receiving edge; LETTER-THROUGH-OPAQUE-PLACE by Codex's
answer.

<a id="duplicate-stop"></a>
## 85. The duplicate stop: where an admission's origin is not proved, the common dynamic admission

Codex's ruling with the debts: "remove the duplicate stop for genuinely
compiler-proven static producer/admission cases. But 'constructed by this
declaration/merge' is not alone proof that a subsequently READ reference
still denotes that origin." And: "If current origin is not proved, use the
common dynamic admission rather than a defensive abort or assumed YES."

### The census

A diagnostic build tags every emitted stop, "lmx: invariant: an admission
by name was refused", with the facts of its admission. It replayed the 1881
translations recorded by `opus_full_12` on the translator of section 84:
296 sites in 147 rows.

| Sites | Edge | The candidate's source | Origin |
| --- | --- | --- | --- |
| 218 | an input (an actual or a hidden input) | an own Structure held by value, or a merge result | static |
| 34 | an input | direct producer evidence: a named Structure, the leaf of a path | static |
| 21 | a full reception | direct producer evidence | static |
| 13 | a full reception | an own static place | static |
| 3 | a return | a typed formal (`unit_d105r_formal`, `unit_d105r_chain`, `unit_struct_return`) | dynamic |
| 1 | a return | a call's result place (`unit_d105r_chain`) | dynamic |
| 6 | a return | an own typed reference (`unit_merge_value_schema`) | dynamic |

Every one of the ten dynamic sites is a return: a place that holds what was
given to it, returned as the result's type. Before each, the value was
admitted into the same model where the place received it, so none of these
stops is reached by a program the gate has. The origin is not proved by the
place, though, so by the ruling the admission there is the common dynamic
one.

The probes for the static ones: rebinding a by-value Structure place
(`base: wide`) is refused as an application (Q59), as is a second
`o: merge Other` on a merge result. Taking the address of such a place, or
of its reference cell (`@@: void cell @o`, `@@: Model cell @o`), is refused:
"assignment value has incompatible type". No probed route makes such a
place denote another value.

### What is built (the dynamic part)

- **The check** (`l2_admit_return`). A returned value whose source is
  dynamic (`l2_d105_dynamic`: a formal, an own reference, a call's result
  place) records the returning method as one that can throw `implements`.
- **The admission.** At both return emitters, a trailer's and a body
  statement's, such a value is admitted by every field of the result's type
  as the method's implicit `implements`, as section 84 made it for a value
  of opaque type. Every other return keeps its admission.

### Witnesses and mutants

A replay of the 1881 translations recorded by `opus_full_12` changes the
generated L1 of exactly four rows: `unit_d105r_chain`, `unit_d105r_formal`,
`unit_merge_value_schema` and `unit_struct_return`. No exit or message
changes, and each runs as before. In `unit_merge_value_schema` all six stops
were at such returns; the row now pins the absence of the stop's text. The
other three keep their static stops.

| Mutant | Takes out | Result |
| --- | --- | --- |
| `noemit` | the returns' `implements` | `unit_merge_value_schema` holds six stops again: its pin is red |
| `nocheck` | the check's record of the method as one that can throw | `unit_d105r_formal`, `unit_struct_return` and `unit_d105r_chain` stop at translation: "internal: the admission of a dynamic candidate was not checked" |

`nocheck` passes `unit_merge_value_schema`: its method can throw already, by
its merges.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_13` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_13` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_15` (full harness) | RED39/1890: against `opus_full_14` FAIL→OK 0, OK→FAIL 0, added 0, removed 0, no red row's words changed. Its generated L1 differs from `opus_full_14`'s in the four rows above, and in three library rows only by the module hash their path gives. The two declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_dup1` (focused, before the gates) | The four changed rows and their neighbours, twelve, all green. |

### Open: the static part

At a static site the refusal is a duplicate of the translation's proof.
What remains when it is removed is the record the admission writes
(`lmx_implements_register_map`), which the reads by name need. It answers
other than YES only for a broken invariant of the translator, or when the
arena's table of records cannot grow. The form of that remainder is asked of
Codex: drop the check, keep a stop that says what failed, or route it to a
status.

<a id="duplicate-stop-static"></a>
## 86. The duplicate stop, the static part: a stop that says what failed

At a static site of section 85 (an own Structure held by value, a merge
result, direct producer evidence) the translation has proved the admission.
The emitted text "lmx: invariant: an admission by name was refused" named an
outcome that such a program cannot have. What the site still does is write
the record that the reads by name need (`lmx_implements_register`,
`lmx_implements_register_map`). That call answers other than YES only in
two cases:

- NO, for a broken invariant of the translator: a second correspondence of
  the same value to the same type, or a layout that contradicts the value's
  record. A broken pair map gives this; the `n3` mutant of the native D-105
  step stopped here.
- UNKNOWN, when the arena's table of records cannot grow
  (`lmx_arena_impl_room`), or for a null argument.

The question to Codex offered three forms: drop the check, keep a stop that
says what failed, or route the failure to a status. The default, stated to
Codex with the question, was the second unless Codex chose otherwise. No
answer has come yet, so that form is built.

- **The translator** (`l2_emit_model_admit`). At a site with no implicit
  throw and no dynamic candidate, the check and the stop stay. The stop's
  text is now "lmx: invariant: the record of a proved admission was not
  kept". CORE_L2_L3_v2 §8.2 says of the tables of the admission by name:
  "A failed allocation is reported as one and is never a refusal of the
  program." The old text reported it as a refusal.
- **Why not drop the check.** Without it, a lost record would surface at
  the first read by name of that value. That read checks the record itself
  (`l2_d105_emit_slot`), and stops at "a field of a formal admitted by name
  is not carried by its value (no record, or a hole)". The program would
  still stop, but farther from the cause.
- **Why not a status.** The walker refuses the same non-YES answer through
  `implements`, because there the admission itself is decided when the
  program runs. At a static site nothing is undecided. Routing an exhausted
  table to `implements` would make every method with such a site one that
  can throw, from a fact of memory and not of the program.

### Witnesses and mutants

A replay of the 1889 translations recorded by `opus_full_15` changes the L1 of
150 rows, all by the stop's text alone. No exit or message changes.

- `unit_site_model_shadow` now pins the new text (`Debt`). In that row a
  formal is given a declared Structure, a static site.
- `unit_merge_value_schema` pins its absence (`Absent`): its six dynamic
  returns of section 85 have no such stop. Its earlier pin on the old text
  could no longer fail, because no translator path emits that text now.

The two pins were checked on the replayed L1 of both rows, under the build
and under three mutants:

| Translator | `unit_site_model_shadow` (new text) | `unit_merge_value_schema` (new text) | Pins |
| --- | --- | --- | --- |
| the build | 1 | 0 | green |
| the old text (the tree of section 85) | 0 | 0 | the `Debt` pin is red |
| no check at a static site (form (a)) | 0 | 0 | the `Debt` pin is red |
| form (b) without section 85's dynamic part | 1 | 6 | the `Absent` pin is red |

These are text pins. The stop is reached only through an exhausted table or
a broken translator. No row can exhaust the table, and the kernel has no
hook to make an allocation fail.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_14` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 296 targets, 113 selftests ran (112 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_14` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_16` (full harness) | RED39/1890: against `opus_full_15` FAIL→OK 0, OK→FAIL 0, added 0, removed 0, no red row's words changed. Its generated L1 differs from `opus_full_15`'s in the 150 rows of the replay, by the stop's text alone, and in three library rows only by the module hash their path gives. The two declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_dupb1` (focused, before the gates) | The two pinned rows and six rows with static sites, all green. |

**Next.** The numeric conversion at the receiving edge
(FIELD-CONSUMPTION-CONVERSION); LETTER-THROUGH-OPAQUE-PLACE and the form of
this remainder by Codex's answers.

<a id="held-conversion"></a>
## 87. A value handed on is converted by the call that gives it to a definition reading another type (HELD-FREE-NAME-OTHER-TYPE)

### The ruling

Codex's handoff OPUS-HANDOFF-20261005-103112, item 5: "Receiving numeric
conversion: a reached present value invokes the ordinary converter; absent
stays absent without calling it. A small GENERAL internal presence-guard
operation is acceptable (evaluate source once, conditional continuation
reuses its value in activation storage). No sentinel equality trick
(present NaN is not absence) or conversion-only CALL flag. Pure forwarders
must preserve ORIGINAL resolved type + presence losslessly: first-seen
consumer type is not an unobservable carrier (untaken size_t narrowing must
not throw on int -1, nor untaken int narrowing on a wide size_t).
Conversion/failure belongs to the executing forming caller; ordinary CALL
still requires its explicit formals."

### What is built

- **The check** (`l2_check_held_convert`, a waited check of kind 8). A
  held call hands each name its definition reads from the calling method's
  binding of it. Once the inputs are typed, a binding that is a number of
  another type than the definition's, and that can arrive present, gets the
  edge to its conversion row's receiver (`l2_check_value_convert_core`, the
  words of every conversion edge). The calling method is then one that can
  throw `convert`. A binding of another kind is refused where the call
  stands, as before.
- **The native formation** (`l2_held_convert_emit`, `l2_emit_convert_raw`).
  The binding is evaluated once. An entry the method only hands on is tested
  for presence. A present value is read at its own type and given to the
  receiver, and the receiver's result goes into a cell of the definition's
  type in this activation, whose address the held call takes. A refusal of
  the receiver is the calling method's implicit `convert`. An absent entry
  stays absent and calls nothing, and the definition reads its own copy.
- **The walk** (`l2_rw_held_convert`): `GUARD [guard, the binding, CALL
  receiver [GUARDED]]`. Two new walker operations (`lmx_walk.h.lm1`,
  `lmx_walk_eval`). GUARD evaluates its source once. Absent, its value is
  absent and the continuation does not run. Present, the continuation runs,
  and GUARDED in it reads that value, which the activation holds while the
  continuation runs (the frame's `guarded`). A guard inside the continuation
  gives the outer value back when it ends. The receiver's CALL is the
  ordinary conversion edge's, with its catch rows. Its one operand is the
  GUARDED, which `l2_rw_call` takes in place of an expression of the source.
- **The type of a value handed on** (`l2_dyn_site_held`, `l2_dyk_note`,
  `l2_dyk_close`). A method that gains an input only to hand a name to a
  held definition reading a number no longer takes the definition's type.
  Its callers' bindings type it. Before, `pick`, called by a method with an
  int `n`, was refused at that call with "incompatible entry signature",
  because its only consumer reads a size_t. An input that no binding types
  can never arrive present; it takes the definition's type once the sites
  change nothing, and the sites are visited again.

### Witnesses

| Row | What it shows |
| --- | --- |
| `unit_held_call_free_name_converted` (+`_walk`) | From the root, with no `n`: each definition reads its copy, 7 and 1001. `outer` has an int `n` of 40: `h0` reads 40, and `h3` reads it converted, 40U, so 41 + 100. |
| `unit_held_call_free_name_untaken` (+`_walk`) | Not asked to call the definition: no conversion and no throw, for an int -1 handed to a size_t and for a size_t 2^32 + 40 handed to an int. Asked: the row refuses, the forming caller's `convert`, caught by its caller. A present zero is converted and read: 1, not the copy's 1001. |
| `unit_held_call_free_name_own_binding` (+`_walk`) | A binding of the calling body's own. The root calls `h3` above its own int `n`, where it has none yet: the copy, 1001; and below it: 40 converted, 41. A method with its own int `n` of 40: 41. One with -1: the row refuses it, that method's `convert`, caught by the root, 9. Natively the value the body holds is converted; walked, its own cell under the guard. |
| `lmx_walk_guard_selftest` (kernel) | 24 checks: a present source, an absent one, the continuation not run on absence, the source evaluated once, a guard inside a guard, and the shapes that are refused. |

The walked twins pin the methods that run walked (`WalkedMethods`), so the
GUARD the rows exercise is the interpreter's.

### Mutants

| Mutant | Takes out | Result |
| --- | --- | --- |
| `G` | the native presence test | `unit_held_call_free_name_converted`: exit 81; from the root an absent entry is read as 0 and converted |
| `N` | the native conversion | `_converted`: 81; `_untaken`: 83, the size_t 2^32 + 40 read as an int's 40; `_own_binding`: 81 |
| `F` | the forwarder's type from its callers | `_untaken` refused at translation in both modes: "incompatible entry signature" |
| kernel `absent` | the guard's test of absence | `_converted_walk`: 81 |
| kernel `nokeep` | the outer guard's value given back | the guard selftest's guard-in-a-guard check fails |
| kernel `twice` | the source evaluated once | the guard selftest's source-once check fails |

A replay of the 1889 translations recorded by `opus_full_15`, against the
translator of section 86, changes one row: `unit_held_call_free_name_converted`,
refused before as a limit. That row and the new ones name
`convert_impl.lm2` among their parts, as every conversion row does, since
the receivers are methods of the program.

### Registered: a forwarder whose callers give two types

A method that only hands a name on still has one type for it. Where two of
its callers bind the name with two types, the second call is refused:
"incompatible entry signature". By Codex's words above the forwarder keeps
each caller's value with that caller's type; then the forming caller would
convert by the type the value arrived with. That needs the type of the entry
when the program runs, or a translation that knows it per call. It is asked
of Codex. The red required positive is `unit_held_call_free_name_two_types`:
`small` gives an int 40 and `wide` a size_t 7 through one `hop`, by the norm
41 and 8 ([FORWARDER-BINDINGS-OF-TWO-TYPES](defects.md#forwarder-bindings-of-two-types)).

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_16` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest), `lmx_walk_guard_selftest` among them: 24 checks, 0 failed. |
| `build/l2src/opus_kernel_15` | Stopped in its kernel phase, before the harness, to add the own-binding rows; the partial directory remains. |
| `build/l3_selftest/opus_l3_15` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_17` (full harness) | RED39/1896: against `opus_full_16` FAIL→OK 1, OK→FAIL 0, added 6, removed 0. The declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_hc1` (focused, before the gates) | 15 rows: those of this section and the held-call rows beside them, all green but the registered red positive `unit_held_call_free_name_two_types` and the two walked twins, whose method pins named definitions (which have no trampoline); with the pins corrected both ran green in `opus_focus_hc2`, the own-binding rows in `opus_focus_hc3`. |

**Next.** FIELD-CONSUMPTION-CONVERSION: a field read at the type of its
cell's own range, converted at the consuming edge.

<a id="fixed-counts"></a>
## 88. Two counts the program did not choose, and the words that cut a name (FIXED-BLOCKS-AUDIT)

Codex's reply OPUS-CODEX-20261005-01, (2) B, on the fixed blocks: "the
prohibited issue is an arbitrary program length/count/depth ceiling or
silent truncation." Two such counts stood outside the route of a path.

| Count | Where | Before | Now |
| --- | --- | --- | --- |
| callable formals written in place in one method | `l2_collect_method` (`cf_fn`, `cf_j`) | eight, then "too many callable formals written in place" | a place for each formal the method has: the eight local places serve where they suffice, beyond them memory of exactly that size (`l2_text_room`) |
| fields a capture of a Structure copies | `l2_mad_cap_emit`, `l2_mad_cap_emit_walk` (`fl`); the constructor's `l2_capf` | 32, then "a captured Structure has too many fields read"; the array the generated code declares, 32 | as many places as the captured Structure has (`l2_ns_width`); the constructor declares as many as its widest captured Structure (`l2_mad_capf_room`) |

### Witnesses

| Row | Shows |
| --- | --- |
| `unit_callable_formals_many_in_place` | ten callable formals written in place, each given `inc` and called on 1: 20. Natively only: a callable formal is outside the walkable subset, as for `unit_callable_anon`. |
| `unit_capture_many_fields` (+`_walk`) | a definition reading 40 fields of a captured Structure sums them, 820; the root's write after the node is made is not seen. |

The translator before this step is the mutant that restores the sizes. It
refuses both rows: the first with "too many callable formals written in
place" at the ninth formal, the second with "a captured Structure has too
many fields read". Measured at the boundary: 32 fields are copied, 33 were
refused; eight formals were taken, nine were refused.

### The words of a refusal

Refusals that name what they refuse formatted the words into a fixed number
of bytes, so a long name was cut from them; three formatted them with no
bound at all:

| Words | Where | Before |
| --- | --- | --- |
| "unbound dynamic input <name>" | `l2_dyn_site_callee`, `l2_dyn_site_held`, `l2_held_unbound`, `l2_rw_lex_operand`, `l2_hidden_lex` | cut at 256 bytes |
| "more arguments than <name> has formals" | `l2_struct_arity_error` | cut at 240 bytes |
| "the program has no method `<name>`, the receiver of this conversion" | `l2_convert_norecv` | cut at 256 bytes |
| the binding's eight refusals: "the argument <a> of <f> is given twice", "<a> is not an argument of <f>", "<f> has no argument <a>" and the others | `l2_bind_actuals`, and the callee's name it is given (`l2_bind_call_in`) | the words cut at 200 bytes, the callee's name at 160 |
| "duplicate catch: <name>", "unhandled throw: <name>", "unhandled throw in entry: <name>" | `l2_check_catch`, `l2_check_throws_handled` | `sprintf` into 160 bytes, no bound |
| "duplicate definition (the other at <path>:<line>:<column>)", "two source tables have this name (the other at ...)" | `l2_dup_method`, `l2_table_twice` | cut at 1400 bytes |

They are now made in memory of their own size: `l2_error_words` says up to
three names between fixed words, `l2_error_name` one, both with
`l2_text_room`. The callee's name is copied whole the same way.

A catch's name has no length check, so the unbounded `sprintf` was reachable:
two catches of one name of 300 bytes in one block crashed the translator,
exit 139, by a write past the 160 bytes on its stack. A name of 150 bytes
already wrote eight bytes past them and the run went on. Registered and fixed
as [DUPLICATE-CATCH-LONG-NAME](defects.md#duplicate-catch-long-name). The
name of an unhandled throw is a declared throw's, at most 62 bytes, so that
`sprintf` stayed inside its buffer; it is made the same way now.

Rows, each with a name of 300 bytes and a needle that holds the whole name:

| Row | The translator before this step |
| --- | --- |
| `unit_unbound_input_long_name_refused`: a free name no caller binds | cuts the words at 256 bytes; the needle is not found |
| `unit_struct_arity_long_name_refused`: a named Structure given an argument | cuts at 240 |
| `unit_catch_duplicate_long_name_refused`: two catches of one name | crashes, exit 139 |
| `unit_named_actual_long_unknown_refused`: a named actual that names no formal | cuts at 200 |
| `unit_held_call_long_name_count_refused`: a held callable under a long name, given one argument of two | cuts the callee's name at 160 bytes |

Not witnessed: the fifth "unbound dynamic input" (`l2_hidden_lex`), said
while a call's hidden input is emitted and its callee has no lexical cell
for it, is reached by no row measured; and the other definition's or
table's path, which would need a source path of more than 1400 bytes.

A replay of the 1895 translations recorded by `opus_full_17`, with this step's
translator against that gate's, changes the L1 of 21 rows, in the size of the
constructor's `l2_capf` alone; no exit or message changes. The number of
allocations grows in four rows, by three or four: `unit_named_actual_many`
and its walked twin declare a method of 17 formals, whose places for callable
formals are now taken in memory of their size, and `unit_path_long_call` and
its walked twin call through heads longer than 160 bytes, whose callee's name
is now copied whole.

### Found beside it: the names of methods, formals and declared throws

The third count of the audit is the 62 bytes of a method's, a formal's or a
declared throw's name ("name too long"). Without those three checks the
translator takes names of 300 bytes on every route probed: a throwing method
with a long formal and a long throw caught by name, natively and with the
methods walked. One route then fails: a method used as a value gets a public
C wrapper under its source name, and `l1trans` keeps function names in
64-byte slots (`l1_fn_ensure`), refusing a longer one with "too many
functions". The limit is the L1 translator's. The step that removes it is
`l1trans`'s, with its own self-build. Until then the translator's check is
the honest place for the refusal, so it stays.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_17` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_16` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_18` (full harness) | RED39/1904: against `opus_full_17` FAIL→OK 0, OK→FAIL 0, added 8, removed 0. The declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_fb1` (focused, before the gates) | 31 rows: the eight of this section and the capture, callable-formal, binding, catch, throw and duplicate rows beside them, all green. |

<a id="ref-field-value-read"></a>
## 89. A reference field read as a value into a reference local (REF-FIELD-VALUE-READ)

Found while probing a chain of Structures for the collector's depth (K09):
`q: a\next`, where `next` is a reference field `@: Node next` and `q` a
reference local `@: Node q`, was translated into code that does not parse.
The statement's path branch -- a path stored into a declared own field --
read number leaves only (kinds 0, 1, 7, 8, 9). For any other leaf it stored
whatever its value buffer last held: `(cast: (@: Lmx) (())`, `(cast: (@: Lmx)
())`, or bytes never written (gcc: "stray '\345' in program").

The general store already reads a reference leaf (`l2_path_text_read`: the
reference cell's pointer, typed by the field's pointee) and stores a
reference with its admission, as it converts a number of another type. The
path branch now leaves both to it: `l2_path_store_converts` became
`l2_path_store_general`, which answers 1 for a reference leaf too.

| Form | Before | Now |
| --- | --- | --- |
| `q: a\next`, in the root and in a method | the L1 does not parse | the reference `a\next` holds |
| `q: a\next\next` | gcc refuses the C | the second hop's reference |
| `p: p\next` in a loop to the chain's end | gcc refuses the C | the chain counted, `p` 0 at its end |
| `c\next: a\next`, then `q: c\next` | the L1 does not parse | the reference written |
| `@: Node q a\next`, a declaration's initializer | translated | unchanged |

Row `unit_ref_field_value_read` (+`_walk`, its method walked): the readings
in a method and the root's read; success 7. The previous translator is its
mutant: its C does not compile.

Observed, asked of Codex: with `q` a reference of another model
(`@: Other q`) that nothing uses, `q: a\next` now stops the forming method
by its implicit `implements` when the program runs -- as `n: a\next` and
then `q: n` already did, a candidate known only when the program runs.
`q: b`, with `b` a copy of `Node` (`b: merge Node`), is admitted. The book
decides admission "by the analytical check of used paths" (:808). No row
pins either until the norm is said.

A replay of the 1903 translations recorded by `opus_full_18`, with this step's
translator against that gate's, changes nothing: every row keeps its L1, exit,
messages and number of allocations. No row before this step stored a
reference field into an own field.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_18` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_17` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_19` (full harness) | RED39/1906: against `opus_full_18` FAIL→OK 0, OK→FAIL 0, added 2, removed 0. The declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_rf1` (focused, before the gates) | 17 rows: the two of this section, the reference-path rows beside them and the rows of a path stored with a conversion -- all green but `unit_free_path_field_converted` (+`_swapped`), the red required positives of FIELD-CONSUMPTION-CONVERSION, refused in the words they have in `opus_full_18`. |

<a id="sprintf-past-buffer"></a>
## 90. No write past a buffer, and sizeof's operand of any length (SPRINTF-PAST-BUFFER, FIXED-BLOCKS-AUDIT)

Probing the audit's remaining sizes with long names and deep nesting, two
writes past a fixed buffer of the translator were reached by programs:

| Write | Where | Reached by | Before |
| --- | --- | --- | --- |
| a counter's step, indented one level below its loop's body: `%s    ` of the body's indentation | `l2_emit_stmts`, 64 bytes on the stack (`l2_dind`) | about nine nested `for:` loops | at twenty the L1 does not parse ("source level decrease must be one step"); at forty the step's indentation is 324 spaces, 261 bytes past the buffer |
| `c.sizeof(<operand>)` with the operand's own text | `l2_emit_sizeof`, into the expression's text: here the global `l2_tok`, 1024 bytes | `sizeof(c.<name>)` with a long name: an atom with `c.` is a type word (`l2_prim_type_word`), and that branch wrote it | a name of 20000 bytes overwrote 19 KB of the translator's globals with exit 0 |

A diagnostic build of the translator with `-O2 -D_FORTIFY_SOURCE=2` stops at
the first ("*** buffer overflow detected ***") from ten nested loops, and
crashes on the second. Over the 1903 translations recorded by
`opus_full_18` that build gives the same L1, messages and exits as the
ordinary one and detects nothing: no row reached either write.

Now the step's indentation is in memory of its own size (`l2_text_room`).
An operand `sizeof` writes as it stands -- a type word, the C door's name, a
machine local's name -- and that the expression's text cannot hold is the
expression's located refusal, "expression too long", as every other writer
of that text says it (`l2_cat`). The size of the expression's text itself
stays on the audit's list.

The same probes found a cap of the audit's kind: `sizeof(<name>)` of a
declared local whose name is longer than 200 bytes was refused as
"unresolved name". The lowering (`l2_sizeof_name_bytes`) took 200 bytes of a
name at most and answered "not lowered here" for a longer one, and its
caller refused the operand in the words of a name it could not find:
200 bytes translated, 201 were refused. The cap is gone; that lowering
writes no name into the expression's text (a scalar's size is its typed
temp's, a formal's its parameter's).

| Row | Shows | The previous translator |
| --- | --- | --- |
| `unit_for_nested_deep` (+`_walk`, its method walked) | twenty nested `for:` loops stepping their counters; the innermost body runs 4 times; success 7 | its L1 does not parse |
| `unit_sizeof_long_name` | `sizeof` of a scalar, a reference and an array local of 300 bytes each, against `sizeof(int)`, `sizeof(@: void)` and three `int`s; success 7. Natively only: a method with `sizeof` keeps its native word under `--walk-methods` | "unresolved name" |

Not pinned by a row: `sizeof(c.<name>)` past the expression's room is now
the located refusal of a size the audit still lists, so a row would expect
the limit itself. Measured with probes: names of 1500, 3000 and 20000 bytes
are refused at their place; a short one translates.

Found beside it and kept on the audit's list: loops and catch blocks nested
more than 64 deep are refused, "loops and catch blocks nested too deeply"
(`l2_lp_push`), with no place (1:1); a C door's name of 3000 bytes in a
constant, a call or an expression is refused as "internal: a refusal said
nothing" -- the expression's limit without its words; a count of an own
array written with more than 300 digits is refused, "unsupported own array
declaration"; the route of `l2_emit_path_to` that roots a path at a machine
local (`l2_proot`, 64 bytes) is taken by none of the 1903 translations -- a
diagnostic stage printed a line there and the replay printed none.

A replay of the 1905 translations recorded by `opus_full_19`, with this step's
translator against that gate's, changes nothing: every row keeps its L1, exit,
messages and number of allocations. No row before this step reached either
write or a sizeof operand over 200 bytes.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_19` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_18` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_20` (full harness) | RED39/1909: against `opus_full_19` FAIL→OK 0, OK→FAIL 0, added 3, removed 0. The declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_ovf1` (focused, before the gates) | 21 rows: the three of this section, the `for:` and `sizeof` rows beside them and the reference-field rows of §89, all green. |

<a id="emission-stacks"></a>
## 91. The emission's stacks hold as many as the program nests (FIXED-BLOCKS-AUDIT)

Three stacks of the emission had 64 places, and the program met each of them
with the wrong words or none:

| Stack | Where | The 65th entry was |
| --- | --- | --- |
| the loops and catch pads enclosing the point emitted | `l2_lpk`, `l2_lpp` (`l2_lp_push`) | "loops and catch blocks nested too deeply", at 1:1 |
| the open pads | `l2_padb`, `l2_padi` | "catch blocks nested too deeply", at 1:1 |
| the walker's pads of one emission -- every catch of a method or the root, siblings as well | `l2_rw_pcf`, `l2_rw_pid` (`l2_rw_pad_new`) | "root operation not walkable yet: a catch parameter that is not a number", natively too |

Measured with the translator before this step: 64 nested `for:` or
`while:` loops translate and 65 are refused; 65 nested blocks with a catch
each, or 65 sibling ones in a method or in the root, are refused in the
walker's words.

Each stack now keeps the unit's 64 places while they suffice, and beyond
them memory of twice the entries (`l2_lp_room`, `l2_pad_room`,
`l2_rw_pad_room`), released with the translation (`l2_release`). Running
out of that memory is said as such. A diagnostic build with
`-O2 -D_FORTIFY_SOURCE=2` translates 150 nested blocks with a catch each --
two growths, the second releasing the first -- in both modes, and the
translation's allocation log ends with no live allocation.

Row `unit_catch_nested_many` (+`_walk`, its method walked): seventy nested
blocks, each catching after the block inside it; the innermost catch takes
the throw; success 7. Each catch's block is a pad and a pad is a loop, so
the row fills all three stacks. The previous translator refuses it in the
walker's words, and each of three mutants that restores one of the caps
refuses it (out of memory at its cap), natively and walked.

Found beside it: the generated L1 grows faster than the square of the
nesting. Twenty nested `for:` loops give 1.4 MB of L1, forty 6.8 MB, sixty
18.5 MB, seventy 27.5 MB (9.3 MB of C). Not a ceiling of the language, but a
cost of the emission the author counts (build memory); registered on the
audit's list.

A replay of the 1908 translations recorded by `opus_full_20`, with this step's
translator against that gate's, changes nothing: every row keeps its L1, exit,
messages and number of allocations. No row before this step nested or wrote
more than 64 of the three stacks' entries.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_20` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_19` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_21` (full harness) | RED39/1911: against `opus_full_20` FAIL→OK 0, OK→FAIL 0, added 2, removed 0. The declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_stk1` (focused, before the gates) | 16 rows: the two of this section, the nested `for:` rows of §90 and the catch rows beside them, all green. |

<a id="source-tables-any-size"></a>
## 92. Source tables as many, as wide and as large as the program writes them (FIXED-BLOCKS-AUDIT)

The receiver `table` kept the program's source tables in places of fixed
size, and refused what did not fit, at its place:

| Size | Where | Refused as |
| --- | --- | --- |
| 8 tables of one translation (two are the conversion and primitive tables) | `l2_tb_*` | "too many source tables" |
| 32 columns of one table, 128 of all | `l2_tbc_name` | "a table has too many columns" |
| 4096 cells of all (the conversion table alone holds several hundred) | `l2_tbx_arg`, `l2_tbx_name` | "a table is too large" |
| a cell's text of 127 bytes | the cell's copy | "a table cell is too long" |

The tables, their columns and their cells now keep the unit's places while
they suffice and beyond them memory of twice the entries (`l2_tb_room`,
`l2_tbc_room`, `l2_tbx_room`), released with the translation; a cell's text
is made in memory of its own size: its bytes and the terminator, and for a
triple-quoted cell, written as an L1 string, at most four bytes for each of
its bytes (an escape) and its quotes. The per-table cap of 32 columns is
gone with the total.

`unit_s7_conv_wide` pinned the 33rd column's refusal: a conversion table of
33 columns, 27 of other names, whose rows held only the six cells the
conversion reads. It is now a positive: each row has a cell for each column
(`n` for the 27), the conversion reads the six it knows and holds the others
in the row unread, and the program converts as `unit_s7_prim_cross` does
(Entry 7). The holding of a column of another name had no gated witness of
its own until now (the review log's M40: the wide row caught that mutant only
through the column cap).

Row `unit_s7_tbl_many`, over the part `unit_s7_tbl_many_part.lm2`: twelve
tables in all, one of 130 columns, one of 5000 cells and one cell of 300
bytes, and the conversion still finds `primitive.convert` by its name: a
`size_t` given to an `int` place is converted; Entry 7. The previous
translator refuses the part, "too many source tables", and each of five
mutants that restores one size -- the tables, the columns of one table, the
columns of all, the cells, the cell's text -- refuses it at that size.
Translated with the part, the allocation log ends with no live allocation,
natively and with the methods walked.

A replay of the 1910 translations recorded by `opus_full_21`, with this step's
translator against that gate's, changes one row: `unit_s7_conv_wide`, recorded
with its old table, is now refused at its first row, "table rows are not whole
rows of its columns", where the 33rd column was refused before; this step
rewrites that table. Every other row keeps its L1, exit, messages and number
of allocations.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_22` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l2src/opus_kernel_21` | Stopped in its kernel phase, before the harness: the replay had shown `unit_s7_conv_wide` pinning the 33rd column's refusal and long cells taking memory; the partial directory remains. |
| `build/l3_selftest/opus_l3_21` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_23` (full harness) | RED39/1912: against `opus_full_21` FAIL→OK 0, OK→FAIL 0, added 1, removed 0. The declared paths were hashed before the run; the staged translator is their bytes. |
| `build/l2_harness/opus_focus_tbl2` (focused, before the gates) | 22 rows: the two of this section, the receiver `table` rows and the conversion-table rows beside them, all green. |

<a id="send-sites-any-count"></a>
## 93. Send sites and letter fields as many as the program writes (SEND-SITE-ARTIFICIAL-CAPS)

Codex's entry SEND-SITE-ARTIFICIAL-CAPS (2026-09-30, `steps/defects.md`): the
translator described the program's send sites in places of fixed size -- 64
sites (`l2_msend_at`, `l2_msend_owner`, `l2_msend_inputs` and the `calloc(64)`
counts) and 16 fields a site (`calloc(1024)` kinds and texts, indexed
`k * 16 + j`) -- and refused beyond them: "more than 64 sends in method
bodies", "a message of more than 16 fields". Nothing released that
description.

A site is now one record -- its statement, owner, inputs, number of fields,
offset, and whether it names a destination -- and the fields of all sites are
one array, site k's from its offset (`l2_msend_off[k]`). The records and the
fields keep the unit's 64 and 1024 places while they suffice and beyond them
memory of twice the entries (`l2_msend_room`, `l2_msend_froom`), released and
reset with the translation (`l2_release`). The check (`l2_check_body`), the
native and walked emission (`l2_emit_msend`, `l2_rw_send`) and the shared
sender (`l2_emit_send`, which now takes the offsets) read the one record. It
is compiler metadata only: nothing new reaches the runtime. The fifth reader
in Codex's list, `l2_send_copies_text`, has had no caller since 6ea06df8
(`<string.h>` is in every preamble); it is removed rather than rewritten, and
the comment that named it says so.

The witnesses use the driver's existing tap of every post,
`l2_driver_service_post`, as Codex proposed. A new driver fact, `postlog 1`,
says each post there before its delivery, as one line: "post N:" and the
letter's payload fields in order, an int by its value, a text in quotes. The
row's `Says` pins the lines.

| Row | What it pins |
| --- | --- |
| `unit_send_sites_many` (+`_walk`) | 70 sites at the root: 69 letters of 17 fields (k, 3k, the text "sk", then k·100+4 … k·100+17) and the exit, 1176 fields in all. All 70 posts, in order, with every field, natively and walked; Entry 7. |
| `unit_send_fields_many` (+`_walk`) | A method's letter of 24 fields (`x * j + j`, texts at 3, 9, 15, 21; the method is native, as every method that sends) and the root's of 20 (`b + 10 j`, a text at every fifth), then the exit. |
| `unit_send_site_kinds_refused` | The check reads each site's own fields: the second letter's field that indexes a number is refused by the check (6:31, "an index on a number: only an Array field is indexed"), where the first letter's field is a text. |

The previous translator refuses both positives at their 17th field, "a
message of more than 16 fields". Nine mutants were each built as their own
translator and run on both positives, natively and walked; the refusal row
was translated by the two that change the check:

| Mutant | Killed by |
| --- | --- |
| the 64 sites restored (`l2_msend_room` fails at 64) | `unit_send_sites_many`: "out of memory" at the 65th site |
| the 16 fields of a site restored | both positives: refused at the 17th field |
| the 1024 field places restored (`l2_msend_froom` fails at 1024) | `unit_send_sites_many`: "out of memory" at the 1025th field (site 61, its fifth) |
| every site's offset 0 | all four runs: the program builder fails and the host cannot make R0 (exit 1); `unit_send_site_kinds_refused` is accepted |
| the field count not advanced | all four runs: the send aborts (exit 3; walked, `walk error: INVALID`) |
| `l2_emit_send` reading site 0's fields | all four runs: a letter takes the first site's texts, then a send whose inputs no longer match aborts (exit 3) |
| `l2_rw_send` reading site 0's kinds | all four runs: the program builder fails (exit 1) |
| `l2_emit_msend` reading site 0's kinds | `unit_send_fields_many` natively: the root's letter is other fields (exit 0, the second line differs) |
| the check reading site 0's kinds | `unit_send_site_kinds_refused`: refused by the walker instead (6:30, "root operation not walkable yet: a field path") |

The `l2_emit_msend` mutant survives the other three runs: the walked runs do
not use it, and `unit_send_sites_many`'s letters share one pattern of kinds.
Translating the two positives, the allocation log ends with no live
allocation.

A replay of the 1911 translations recorded by `opus_full_23`, with this
step's translator (the focused stage's, from these bytes) against that gate's,
changes nothing: every row keeps its L1, exit, messages and number of
allocations -- a translation within the unit's places takes no memory for
its sites.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_23` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_22` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_24` (full harness) | RED39/1917: against `opus_full_23` FAIL→OK 0, OK→FAIL 0, added 5, removed 0. The declared paths were hashed before the run; the staged translator and driver are their bytes. |
| `build/l2_harness/opus_focus_msd1` (focused, before the gates) | 25 rows: the five of this section, the other send rows, the rows of the driver's post-path tap and the reception rows, all green. |

<a id="expression-text-slice-1"></a>
## 94. The text of one expression as long as the program writes it: slice 1 (FIXED-BLOCKS-AUDIT)

Codex's decision of 2026-10-06 (OPUS-CODEX-20261005-01, Decision 2): one
compiler-only owned text builder -- data, current length, capacity -- under
the existing `l2_xmalloc`/`l2_xfree` discipline, migrated in slices by real
dependency, each gated; a route is migrated only when its writers and its
readers use the unbounded text, and a route not migrated yet stays OPEN. The
text of one expression was 1023 bytes (`l2_cat` into 1024-byte buffers,
"expression too long"): a sum of about a hundred operands was refused, and
two ordinary shapes were refused with no located diagnostic ("internal: a
refusal said nothing", exit 3) -- a literal operand of 256 bytes or more
through the C door (`l2_tok_text(..., 256U)` in `l2_prep`) and a C call of
300 actuals.

The text, `L2Tx` (the translator's header `l2_application.h.lm1`), is `data`
holding `len` bytes and a NUL in `cap` bytes. It starts on a 1024-byte buffer
of its owner, so a text that fits there takes no allocation; beyond it the
text takes storage of the translation twice the room (`l2_tx_room` through
`l2_text_room`, released by `l2_release`). A grown text's earlier storage
stays until then, so no pointer into it dangles; a reader takes `data` after
the last write. The functions: `l2_tx_open`, `l2_tx_len`, `l2_tx_room`,
`l2_tx_cat`/`l2_tx_catn`, `l2_tx_clear`, `l2_tx_set`, `l2_tx_join`,
`l2_tx_temp`, and `l2_tok_tx`, an atom's text of any length (a
triple-quoted text as an L1 string) in place of `l2_tok_text`'s 256 bytes.

Migrated, writers and readers: the evaluation of an expression
(`l2_eval_fields`, `l2_eval_and`, `l2_eval_cond`), the joining of its operands
(`l2_emit_fields`), the preparation of an operand (`l2_prep`: atoms, groups,
prefix signs, casts, unit references, function-pointer calls), the C door
(`l2_emit_ccall`) with the destination of a C call used as a value
(`l2_ccall_into`), the statement's text `l2_tok` (its record in
`l2_translate`'s frame) with every reader of it, and a letter's field texts
(`l2_emit_msend`). The type carries the contract: a migrated writer's
destination is `@: L2Tx`, so gcc's `-Werror=incompatible-pointer-types` named
every site that still passed it a fixed buffer.

The routes not migrated yet stay OPEN. None of them cuts a text: each takes it
whole or refuses it in its own words.

- 33 writers still on a 1024-byte buffer are handed the text's room for it
  (`l2_tx_fixed`) and keep their own bounds and refusals -- among them
  `l2_emit_call`, `l2_emit_indexed`, `l2_own_load`, `l2_emit_raw_path`,
  `l2_prefix_deref`, `l2_emit_sizeof`, `l2_emit_address`, `l2_path_text_read`,
  `l2_emit_reference_value`, `l2_emit_init_convert`, `l2_emit_ret_convert`;
- two writers rewrite the statement's text in place (`l2_tx_fixed_keep`):
  `l2_payload_expr`, which still refuses a letter's value of 256 bytes ("a
  letter's value expression too long"), and `l2_emit_receiving_admit`, which
  reads the text whole;
- eight routes take a migrated writer's text into a fixed 1024-byte buffer
  (`l2_eval_fields_fixed`, `l2_emit_fields_fixed`, `l2_prep_fixed`): the
  actual slots of `l2_emit_call`, `l2_prep_held_call`, `l2_emit_indexed`,
  `l2_prep_addr`, `l2_emit_actual_path` (at most 32 names),
  `l2_emit_indirect_span`, `l2_emit_reference_value_at` and
  `l2_emit_fnptr_call`. The text is copied there when it fits, else refused
  where it stands, "expression too long" (`l2_tx_to_fixed`). The three
  wrappers were put between `l2_emit_formal` and its leading comment, which
  they now separate; the next slice moves what remains of them;
- atoms copied by `l2_tok_text` into buffers of a constant size: a raw C path's
  root and a dereferenced name (256 bytes), an index's base and pieces, a
  foreign type's name in a cast and a declared reference's name (256), and the
  machine-local path root (64 -- its own item, after its two producers); the
  joins of `l2_emit_fnptr_call` and `l2_pointer_decl_text` (`l2_cat`).

A defect found and fixed with the slice, C-CALL-VALUE-TEXT-CUT: a C call used
as a value had its text copied into its destination in 256 bytes
(`memcpy(into_buf, buf, 256U)`). `int: r c.abs(a + ... + a)` of 40 operands
(a text between 256 and 1023 bytes) translated, exit 0, into L1 that `l1trans`
refused, "unclosed parenthesized form" (`c.abs(l2_p0_0 + ... + )`); of 120
operands it was refused "expression too long". The destination is now the
text itself.

| Row | What it pins |
| --- | --- |
| `unit_exprtext_sum` (+`_walk`) | A sum of 300 operands of a formal (3010 bytes of text: one text grows twice, 1024 to 4096 bytes), 110 nested groups around one operand and a sign over a group of 120; Entry 7. The twin walks the method and the root. |
| `unit_exprtext_while` (+`_walk`) | A while condition of 151 operands; the loop ends at r = 7. |
| `unit_exprtext_if` (+`_walk`) | An if condition of 150 operands; the branch is taken. |
| `unit_exprtext_letter` (+`_walk`) | A letter's field of 150 operands: `postlog 1` says "post 1: 150", then the exit. |
| `unit_exprtext_literal` | A literal of 3000 bytes as the operand of `c.puts`, printed whole (Says). |
| `unit_exprtext_actuals` | `c.printf` of 301 actuals: the values 1 ... 300 (four of them written a + k) printed in their order (Says). |
| `unit_exprtext_c_value` | `c.abs` used as a value, of 40 and of 120 operands; Entry 7. |

The last three are native only: a raw C call keeps its method native under
`--walk-methods` (the walked translation keeps `l2_m0`'s native word), and no
walked twin is made of them -- no interpretation of raw `c.*` is invented for
one. The previous translator refuses every row: "expression too long" at the
long expression (sum 6:420, c_value 7:426, while 5:420, if 5:417, letter
4:434); literal and actuals with no located diagnostic, exit 3.

The sizes are what the witnesses need and no more: the harness reads each
program's graph in a time that grows faster than the graph -- the first
draft's sum, 1451 operands in all, took 210 s a row, a condition of 301
operands 13 s.

Translating the seven fixtures, natively and with `--walk-methods`, the
allocation log ends with no live allocation. An allocation failed at a growth
(`L2_FAIL_MALLOC` at each of the sum's first three) refuses the translation at
the expression, "out of memory" (6:420, 6:830, 6:1208), writes no L1 and ends
with no live allocation. Both translators follow a failed allocation in the
emission with a second line, "1:1: out of memory": not this step's, it is
registered as ALLOC-FAILURE-SAID-TWICE (`steps/defects.md`, OPEN).

Mutants, each built as its own translator; the seven fixtures translated,
compiled and run natively, the posts and the printed lines compared:

| Mutant | Killed by |
| --- | --- |
| a text refused past 1024 bytes (`l2_tx_room`) | all seven fixtures: "out of memory" at the long expression |
| an atom refused at 256 bytes (`l2_tok_tx`, the old bound of `l2_tok_text`) | `unit_exprtext_literal` and `unit_exprtext_actuals`: "out of memory" at the literal |
| a C call's value copied in 256 bytes (the old `memcpy`) | `unit_exprtext_c_value`: L1 that `l1trans` refuses, "unclosed parenthesized form" |
| a growth that does not copy the text | `unit_exprtext_sum`, `_c_value` and `_if`: the entry returns another value (exit 1); `_literal` and `_actuals`: L1 that `l1trans` refuses; `_while`: the loop does not end (stopped at 60 s); `_letter`: "post 1: 48" |
| the C door's join refused at 1023 bytes | `unit_exprtext_literal`, `_actuals` and `_c_value`: "out of memory" |
| `l2_tx_fixed_keep` emptying the text | the replay changes the L1 of `unit_bind_root_letter` and `unit_bind_root_letter_refused` alone: a cast with no operand, which gcc refuses ("expected expression before ')' token") |
| `l2_tx_fixed` not emptying the text | nothing: the replay keeps the L1 of all 1916 rows and changes the number of allocations of 1340 -- the emptying only spares growth |

A replay of the 1916 translations recorded by `opus_full_24`, with the
translator of this section's full gate against that gate's, changes nothing:
every row keeps its L1, exit, messages and number of allocations -- a text
that fits in its owner's buffer takes no memory.

The comment on the preamble's `<string.h>` in `l2_emit_unit`, and the header
of `unit_send_text`, said the header was named only where the program's own
emission uses it; it is one common header of every program's preamble since
6ea06df8 (Codex 2026-10-06), and they say so.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_24` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_23` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_25` (full harness) | RED39/1928: against `opus_full_24` FAIL→OK 0, OK→FAIL 0, added 11, removed 0. The declared paths were hashed before the run; the staged translator, its header and the fixtures are their bytes. |
| `build/l2_harness/opus_focus_tx2` (focused, before the gates) | 14 rows: the eleven of this section, `unit_send_text` and the two rows the `l2_tx_fixed_keep` mutant changes, all green. |

<a id="expression-text-fixed-routes"></a>
## 95. The routes that took a text into a fixed buffer: slice 2 of the expression text (FIXED-BLOCKS-AUDIT)

Slice 1 left eight routes that took a migrated writer's text into a buffer of
1024 bytes, copied when it fit and refused "expression too long" where it
stood when it did not (`l2_eval_fields_fixed`, `l2_emit_fields_fixed`,
`l2_prep_fixed`). Seven of them now write into a text of their own:

- a call's actuals (`l2_emit_call`). One block still holds them, now the
  actuals' texts (`L2Tx` records) and then a 1024-byte slot for each, where its
  text starts (`l2_act_tx`); a text grows past its slot into storage of the
  translation. The joiner writes into the actual's text (`l2_emit_fields`);
  the writers still on the 1024-byte contract are handed the slot's room
  (`l2_tx_fixed`: `l2_t7_emit_actual`, `l2_cf_actual_emit`,
  `l2_emit_empty_actual`, `l2_emit_value_convert_field`,
  `l2_emit_actual_path`); `l2_payload_expr` keeps the text it rewrites; the
  admissions and `l2_emit_call_go`'s refs (through `l2_emit_call_classes`
  too) read its data. The one actual of a conversion receiver's call
  (`l2_emit_convert_raw`) is a text on the frame, and its refusal "internal: a
  converted value's text does not fit its actual" went with its 1024-byte
  block;
- a held callable's actuals (`l2_prep_held_call`);
- an own array's index: the index of an array place
  (`l2_emit_array_place_operand`, through `l2_emit_received_span`), and the
  value an indexed operand loads (`l2_emit_indexed`), whose index is one name,
  call or literal and so never long;
- the actuals of a call through a function-pointer local
  (`l2_emit_fnptr_call`), joined in a text whose growth failing is said where
  the call stands -- the joins on a 1024-byte buffer returned with no located
  diagnostic past it;
- the value a reference takes (`l2_emit_reference_value`,
  `l2_emit_reference_value_at`, `l2_emit_received_span`): its callers hand the
  statement's text itself, or a text of their own
  (`l2_emit_reference_declaration`, `l2_emit_array_place_operand`'s index);
- a pointer's dereference (`l2_emit_indirect_span`);
- the address of a C field (`l2_prep_addr`), whose destination is a text: its
  `@ ` and a field text of 1023 bytes could pass the 1024 bytes it was handed
  by two.

`l2_eval_fields_fixed` and `l2_emit_fields_fixed` have no caller left and are
removed. `l2_prep_fixed` stays for the eighth route, the path actual
(`l2_emit_actual_path`, at most 32 names), OPEN; slice 1 had put the three
between `l2_emit_formal` and its leading comment, and the one left now stands
before that comment.

The residual routes of section 94 are now 32 writers on the 1024-byte
contract, `l2_payload_expr`'s 256 bytes, the path actual, the `l2_tok_text`
atoms and `l2_pointer_decl_text`'s joins.

| Row | What it pins |
| --- | --- |
| `unit_exprtext_call` (+`_walk`) | g of one actual of 150 operands, h of two (a, then 150 operands), so that an actual in another's place changes h's u * 1000 + v; Entry 7. The twin walks g, h, f and the root. |
| `unit_exprtext_held` (+`_walk`) | A held callable (`@: h make(1)`, x + 1) called on 150 operands; Entry 7. The twin walks make, f and the root. |
| `unit_exprtext_index` (+`_walk`) | An own array read at an index of 150 operands less 148 (the index of an array place), then again with 1 added; Entry 7. |
| `unit_exprtext_fnptr` | `c.malloc` through a function-pointer local, called as a statement and as a value on 150 operands less 146; Entry 7. |
| `unit_exprtext_reference` | A reference declared, and another assigned, with `c.strchr` over a literal of 1500 bytes; both read past it; Entry 7. |

The last two are native only: a raw C call keeps its method native. Slice 1
refuses every row "expression too long", at the long actual, index or value
(call 12:14, held 12:14, index 8:16, fnptr 13:14, reference 6:15). A long
dereference and a long C field address have no positive: the check refuses a
dereference of a call before the emission ("root operation not walkable yet:
this operand"), and a C field's address is written of its names.

Mutants, each its own translator; the five fixtures translated, compiled and
run natively:

| Mutant | Killed by |
| --- | --- |
| every actual the first's text (`l2_act_tx` answering the block's first record) | `unit_exprtext_call`: the entry returns another value (exit 1) |
| a call's actual refused past 1023 bytes again | `unit_exprtext_call` refused |
| a held callable's actual refused past 1023 bytes again | `unit_exprtext_held` refused |
| a function-pointer call's join refused past 1023 bytes again, with no diagnostic, as before | `unit_exprtext_fnptr` refused |
| the value a reference takes refused past 1023 bytes again | `unit_exprtext_index` (the array place's index), `unit_exprtext_fnptr` (the value `got` takes) and `unit_exprtext_reference` refused |
| the slots laid over the records | in this run `unit_exprtext_index`, whose L1 came out broken ("unindent does not match any outer indentation level"); the other four were right. The damage is to the heap and depends on where the block lies: a row sees it only by chance, a checked build would always (the fortified test build is its own item) |
| an indexed operand's value refused past 1023 bytes again | not reached: an indexed operand's index is one name, call or literal; a long index goes by the array place |
| a converted value refused past 1023 bytes again | not reached: `l2_emit_convert_raw`'s callers hand it a value from a 1100-byte buffer (`l2_held_convert_emit`, OPEN); the replay changes no row |

Each length mutant refuses by returning 1, which the translator's guard says
as "internal: a refusal said nothing" (exit 3).

A replay of the 1916 translations recorded by `opus_full_24`, with the
translator of this section's full gate against section 94's: every row keeps
its L1, exit and messages; six make two allocations fewer (the held calls'
conversions, whose actual is no longer allocated).

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_25` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_24` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_26` (full harness) | RED39/1936: against `opus_full_25` FAIL→OK 0, OK→FAIL 0, added 8, removed 0. The declared paths were hashed before the run; the staged translator and the fixtures are their bytes. |
| `build/l2_harness/opus_focus_tx3` (focused, before the gates) | 32 rows: the eight of this section, three of section 94, the held calls' conversion rows, the function-pointer, reference, array, letter and send rows, all green. |

<a id="expression-text-path-actual"></a>
## 96. A path actual of any number of names: slice 3 of the expression text (FIXED-BLOCKS-AUDIT)

The path actual (`l2_emit_actual_path`: `take(h\a\p)`, a Structure path handed
to a Structure formal, admitted at its leaf) was the last route that took a
migrated text into a fixed buffer. It held at most 32 names (`[]: int slots
32`) and wrote the path in 1024 bytes (`cur`/`nxt`, refused when the text and
one more name could pass them), each refused "expression too long" where the
call stands. The names now go into an array of twice the room when it is full
(storage of the translation, released by `l2_release`), the path is a text --
each name wraps the text so far, written into the other of two texts, which
then change places -- and the destination is a text: the call hands the
actual's own text, a `return:` the statement's. `l2_prep_fixed` and
`l2_tx_to_fixed` lose their last callers and are removed: no route of the
expression text copies a migrated text into a fixed buffer any more.

| Row | What it pins |
| --- | --- |
| `unit_exprtext_path` (+`_walk`) | `take(h\s1\...\s40)`: the leaf of 40 nested Structures, not `Equatable` (an unread `extra` before its `equals`); `take` writes `equals` through the admitted argument and the write is seen in `Holder`'s own leaf, `extra` unchanged; Entry 7. The twin walks `take`, `pass`, `go` and the root. Slice 2 refuses it at 61:9, "expression too long". |

Paths of 3 and 31 names, below the old bound, translate and run as before.

Mutants, each its own translator; the fixture translated, compiled and run:

| Mutant | Killed by |
| --- | --- |
| the 33rd name refused again | refused at 61:9, "expression too long" |
| the path's text refused past 1023 bytes again | refused at 61:9, "expression too long" |
| each name wrapping the root's text, not the text so far (the texts not changing places) | the run stops: "lmx: invariant: the record of a proved admission was not kept" (exit 3) |
| the names found so far not kept when their room grows | the run stops: "lmx: invariant: a field path met no Structure" (exit 3) |

A replay of the 1916 translations recorded by `opus_full_24`, with the
translator of this section's full gate against section 95's: every row keeps
its L1, exit, messages and number of allocations.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_26` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_25` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_27` (full harness) | RED39/1938: against `opus_full_26` FAIL→OK 0, OK→FAIL 0, added 2, removed 0. The declared paths were hashed before the run; the staged translator and the fixtures are their bytes. |
| `build/l2_harness/opus_focus_tx4` (focused, before the gates) | 12 rows: the two of this section, the long sum and call of sections 94 and 95, the admitted path actuals beside them (`unit_s7_*`, `unit_named_actual_path`), all green. |

<a id="alloc-failure-rows"></a>
## 97. A failed allocation said once, and rows that fail one (ALLOC-FAILURE-SAID-TWICE)

Codex's reply of 2026-10-06 (OPUS-CODEX-20261005-01) to Question A of
section 94: a generic per-row translator environment and a self-calibrating
allocation-failure probe -- no literal `L2_FAIL_MALLOC=N` in a fixture, no
failure mode of the translator that knows a helper, a source or a fixture --
and the small common correction of ALLOC-FAILURE-SAID-TWICE in a bounded
checkpoint of its own.

**The correction.** `l2_translate` said a failed allocation of the emission
again after `l2_emit_unit`, at 1:1, whenever `l2_alloc_err` was set -- after a
located refusal too. It now takes `l2_diag_n` just before `l2_emit_unit` and
says the allocation failure only when the emission said nothing since then
(`l2_said_or` against that count). An allocation failure left unsaid is still
said, and a refusal of another kind is untouched.

**The trace.** `L2_ALLOC_TRACE=<file>` (test instrumentation, opt-in): every
allocation `l2_text_room` makes -- the tracking vector's (`l2_vec_grow`) and the
room's own -- is written there before it is made, as the ordinal
`L2_FAIL_MALLOC` counts, what makes the room (`text-growth` for a text's
growth, `room` else) and which of the two it is. The file is opened by the C
library, outside `l2_xmalloc`: a traced translation makes the same counted
allocations and writes the same L1 as an untraced one (`unit_exprtext_sum`:
52069 allocations both ways).

**The rows.** `TranslatorEnv` sets a row's translator environment for that one
invocation and restores it after it, failed or not (`Invoke-WithEnv`).
`FaultAlloc = '<what made the room> <vector|buffer> <which>'` names an
allocation by what the trace says it is: the same translator, source, parts,
arguments and directory translate once with the trace, the event is looked up,
and the translation runs again failing exactly that allocation, traced too. The
row requires the allocation log to say the failure was there (`fail_at` the
found ordinal, `err=1`); the failing translation's own trace to have, at
`fail_at`, the named event -- the same kind and the same one of its kind, so a
trace numbering otherwise names another allocation and fails the row rather
than becoming another valid out-of-memory test; nothing live after the
release; the exit of a refusal (1, not the silent refusal's 3); no L1; and --
the refusal branch as for every refusal row -- one `l2trans error:` line
(`ErrorLines = 1`) located at the expression (`Needle`). An event the trace
does not have fails the row. The environment is restored after each of the two
translations, whatever happens in them.

| Row | What it pins |
| --- | --- |
| `unit_exprtext_sum_fault_growth1` | The first growth of the long sum's text fails: 6:420, "out of memory". |
| `unit_exprtext_sum_fault_growth2` | Its second growth: 6:830. |
| `unit_exprtext_sum_fault_growth3` | The statement's text grown for the sum: 6:1208. |
| `unit_exprtext_sum_fault_vector1` | The first growth of the rooms' tracking vector during a text's growth (the nested groups): 7:127. |

`unit_exprtext_sum` itself is the control that translates and runs.

Mutants, each run by the harness of an isolated shared clone of HEAD with
this checkpoint laid over it, its own evidence directory, one after another;
`unit_exprtext_sum`, the control, passed in each:

| Mutant | Killed by |
| --- | --- |
| the allocation failure said again whatever the emission said (the old `l2_alloc_or` after `l2_emit_unit`) | all four rows: "refused with 2 "l2trans error:" lines -- one cause, one line" |
| `L2_FAIL_MALLOC` not read | all four: "did not fail where it was named" (`fail_at=0`, `err=0`; the translation succeeds) |
| the trace numbering each allocation one before the ordinal the failure counts | all four: "allocation N failed, but the failing translation's trace does not have it as ..." -- in `_growth2` the allocation that failed was the first growth of the same text, a valid out-of-memory refusal at its own place, and the row refuses it |

A replay of the 1937 translations recorded by `opus_full_27`, with the
translator of this section's full gate against section 96's: every row keeps
its L1, exit, messages and number of allocations.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_27` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_26` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_28` (full harness) | RED39/1942: against `opus_full_27` FAIL→OK 0, OK→FAIL 0, added 4, removed 0. The declared paths were hashed before the run; the staged translator and the fixtures are their bytes. |
| `build/l2_harness/opus_focus_fault1` (focused, before the gates) | 12 rows: the four of this section, their control `unit_exprtext_sum` (+`_walk`), the long literal, actuals and path of sections 94 and 96, the `sizeof` and literal refusals beside them, all green. |

<a id="expression-text-owner-groups"></a>
## 98. The writers whose callers already hand a text: owner groups 1 and 2 of the expression text (FIXED-BLOCKS-AUDIT)

After slice 3 no route copies the expression's text into a fixed buffer;
what remained were 33 writers that still wrote a `@: char` destination and
were handed the text's room for 1023 more bytes (`l2_tx_fixed`, or
`l2_tx_fixed_keep` for the two that read the text they rewrite), at 65 call
sites. A writer's destination moves to the text with its owners: a caller's
buffer handed to it becomes a text, so the buffer's other writers move too,
and a destination the writer hands on moves the writer it is handed to.
Over the translator's calls that closure splits the 33: 13 form twelve
groups of their own whose callers already hand texts or buffers of their own
(fourteen writers with `l2_sizeof_name_bytes`, to which `l2_emit_sizeof`
hands its destination) -- group 1; 10 belong to one group of 15 writers
around the method call, the conversions and the array elements -- group 2;
10 to a group of 34 around tokens, places and declarators, `l2_tok_text`'s
atoms and `l2_pointer_decl_text`'s joins among them -- group 3, the next
step. Codex (2026-10-06) let groups 1 and 2 form one gated checkpoint; each
keeps its own measurements below.

**Group 1.** `l2_emit_array_desc`, `l2_emit_array_place_operand`,
`l2_emit_empty_actual`, `l2_emit_indirect_span`, `l2_emit_receiving_admit`,
`l2_mrs_occ_read`, `l2_payload_expr`, `l2_prep_held_call`,
`l2_prep_implements`, `l2_t7_emit_actual`, `l2_emit_sizeof` with
`l2_sizeof_name_bytes`, and `l2_field_path_read` with `l2_path_text_read`
write the text. Their 22 call sites hand the text itself, and
`l2_tx_fixed_keep` loses its last callers and is removed. The buffers their
callers had of their own become texts on those buffers
(`l2_emit_array_place`'s target, the descriptor of `l2_emit_array_ptr` and
`l2_emit_array_length`, the walk's `implements` answer in `l2_rw_operand`).
One helper is added, `l2_tx_wrapn`: a text, n bytes, a text. The bounds that
go with them: `sizeof` of a type frame was written in at most 256 bytes
("expression too long" at the sizeof, for a pointer about 240 levels deep);
`sizeof` of a type word, a C door's name or a method in 1024 (the located
refusal of section 90), an own array's count with them; a letter's payload
in 256 ("a letter's value expression too long" -- a letter's value is a name
or a load in every program the gates translate, and no row reached it);
`l2_emit_indirect_span` wrote its indirections into the 1024 bytes
unchecked (as many as the operand's type is deep).

**Group 2.** The method call (`l2_emit_call`), the conversions
(`l2_emit_value_convert`, `_n`, `_field`, `l2_emit_ret_convert`,
`l2_emit_init_convert`, `l2_emit_convert_raw`), a new int temporary
(`l2_new_temp`) and the array elements and lengths (`l2_emit_arr_operand`,
`l2_emit_array_length`, `l2_emit_array_load_at`, `l2_emit_own_index`,
`l2_emit_indexed`) write the text: 24 more call sites hand it. What they
write is a name -- a temporary, an element, a literal index -- so no bound a
program meets goes with them; what goes is the room they were handed.
`l2_tok_temp` loses its callers to `l2_tx_temp` and is removed;
`l2_emit_array_load`, which nothing calls, is removed. The callers' own
buffers handed to them become texts: `l2_emit_ccall`'s boxed temporary,
`l2_emit_stmts`' loop flags and own-array index, `l2_emit_indexed`'s index,
`l2_held_convert_emit`'s result. 19 adapter sites remain, all in group 3.
Removing an adapter does not show that the writers downstream take a text
of any length: every bound group 3 still holds stays listed in
FIXED-BLOCKS-AUDIT until its own migration and witness.

| Row | What it pins |
| --- | --- |
| `unit_exprtext_sizeof_frame` | `sizeof(@@...@: int)`, a pointer 1100 levels deep, is the size of a pointer; Entry 7. The previous translator refuses it at 5:11, "expression too long". Natively only, as `unit_sizeof_long_name`: a walked root stops at its `sizeof` ("lmx: walk error: UNSUPPORTED"), already at depth 2 -- the walker's existing behaviour, not a bound of this step. |

Not pinned by a row: `sizeof(c.<name>)` past 1024 bytes now translates (a
name of 1500 bytes; the previous translator refuses it at its place), but
`l1trans` refuses a C type name of 64 bytes or more (`l1_hdr_type_add`,
"type name too long", measured at 100) -- a debt of the bootstrap toolchain,
recorded in FIXED-BLOCKS-AUDIT for `l1trans`'s own step; not a reason to
shorten, hash or treat C names specially.

Reach, measured with coverage builds over the recorded translations (group 1
over the 1935 of `opus_full_26`, groups 1 and 2 over the 1937 of
`opus_full_27`): every writer of group 1 runs but `l2_mrs_occ_read`
(`merged\[N]x` of a bound merge result). Of group 2, `l2_emit_array_load_at`
never runs, `l2_emit_own_index` runs only to answer "not this shape" (56270
times), `l2_emit_arr_operand`'s element branches and `l2_emit_indexed`'s
load branch never run. They are migrated by the same rule. No coverage, no
unchanged replay and no "not this shape" shows them dead: they stay for the
producer and reachability audit before any removal (Codex 2026-10-06).

Mutants, each its own translator, run by the harness of an isolated shared
clone of HEAD with the group laid over it, its own evidence directory, one
after another; the rows named are among those whose L1 the mutant changes in
the replay, and all of them pass without it. Group 1's, over group 1:

| Mutant | Killed by |
| --- | --- |
| the type frame's text bounded at 256 bytes again | `unit_exprtext_sizeof_frame`: refused at 5:11, "expression too long" |
| `l2_tx_wrapn` not writing the text after the bytes | `unit_exprtext_sizeof_frame` (gcc), `unit_sizeof_long_name` and `unit_sizeof_array_bytes` (l1trans), `unit_sizeof_type_frame` (its L1 pin) |
| one indirection fewer | `unit_addr_depth`, `unit_addr_take`, `unit_address_reference_cell` (exit 1) |
| a letter's value not rewritten into its payload | `unit_admit_letter_formal`, `unit_admit_rebind_read`, `unit_bind_root_letter` (exit 1) |
| `implements` always 0 | `unit_implements_admission`, `unit_implements_argument`, `unit_implements_primitives` (exit 1) |
| an array place's element without its index | `graph_shape_array_place_selectors` (exit 1) |
| an array's length read from a descriptor not its own | `graph_shape_nested_array`, `unit_array_value_projection`, `unit_field_path_array_dispatch` (gcc) |
| a reference taking the value it was given, not the temporary that value was admitted in | only `unit_ref_local_path`'s text pin of the native relationship -- a text pin, not behaviour. Of the 161 rows whose L1 it changes, run, the others pass (one was red before): the value handed to the receiving admission is a temporary or a read in each of them. The behaviour stays untested (FIXED-BLOCKS-AUDIT). |

Group 2's, over groups 1 and 2:

| Mutant | Killed by |
| --- | --- |
| an addressed element without its address (`l2_emit_indexed`) | `graph_shape_machine_address`, `graph_shape_walk_machine_address`, `graph_shape_pointer_index`, `unit_addr_own_array_arith`: the program crashes |
| a new temporary named by its neighbour (`l2_new_temp`) | `graph_shape_for_body`, `graph_shape_for_no_init`, `graph_shape_array_place_selectors` (+`_walk`) (gcc) |
| the postcondition loop clearing its first-turn flag where it clears its keep flag (`l2_emit_stmts`' loop texts) | `unit_body_path_until_pt`, `unit_named_until_canonical_copy` (no end: the program was stopped from outside, the harness has no time limit), `unit_held_call_bare_name_condition` (exit 1); its `_walk` twin passes |
| a conversion's result named by the receiver's temporary (`l2_emit_convert_raw`) | `unit_held_call_free_name_converted`, `unit_held_call_free_name_own_binding` (+`_walk`) (gcc) |
| an indexed path array's length named by the next temporary (`l2_emit_arr_operand`) | `entry_argc_if`, `graph_shape_ns_source_array_read` (+`_walk_methods`), `graph_shape_ns_source_constructors` (gcc) |
| a callable without a result leaving the destination's text as it was (`l2_emit_call`) | changes no translation of the corpus |
| a literal own index spelled 0 (`l2_emit_own_index`); an own array element named by the next temporary (`l2_emit_array_load_at`) | change no translation: the routes no recorded translation takes (above) |

**The scoped environment** (Codex's spot-check of section 97):
`Invoke-WithEnv` set its variables before entering the `try` whose
`finally` restores them, so a setup failing after an earlier variable was
set left that variable set. They are now set inside the `try`, each saved
before it is set. A script takes the function from the harness by its text
and runs three cases -- a block that succeeds, a block that throws, a setup
that sets one variable and then fails on a name that cannot be set: the
function of section 97 leaves the first variable set in the third case
(`WE_K2='x'`, was `'prior'`); this one restores it, and the other two cases
pass with both.

Replays, with each group's translator against the one before it: group 1
against section 97's over the 1935 translations of `opus_full_26` and the
1937 of `opus_full_27`, group 2 against group 1 over the 1937 -- every row
keeps its L1, exit, messages and number of allocations. So does the
translator of this section's full gate against section 97's over the 1937.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_28` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_27` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_29` (full harness) | RED39/1943: against `opus_full_28` FAIL→OK 0, OK→FAIL 0, added 1, removed 0. The declared paths were hashed before the run; the staged translator and the fixtures are their bytes. |
| `build/l2_harness/opus_focus_g12` (focused, before the gates) | 39 rows: this section's row, the rows its mutants are killed by and the controls of sections 94, 96 and 97, all green. |

<a id="expression-text-owner-group-3"></a>
## 99. Tokens, places and declarators of any length: owner group 3 of the expression text (FIXED-BLOCKS-AUDIT, ADDRESS-TYPE-PAST-BUFFER)

After groups 1 and 2 (section 98), 19 call sites still handed a writer the
text's room for 1023 more bytes (`l2_tx_fixed`), all of them into one group
of 34 writers around tokens, places and declarators -- the closure over the
translator's calls in which a caller's buffer handed to a writer moves with
it. Codex (2026-10-06): group 3 next, with the remaining adapters removed
and long-input witnesses for the limits a program still reaches.

**The group.** 31 of the 34 write the text: `l2_cast_type`,
`l2_cast_resolve`, `l2_pointer_decl_text`, `l2_value_decl_text`,
`l2_tok_formal`, `l2_tok_slot`, `l2_own_load`, `l2_own_cell_load`,
`l2_own_addr`, `l2_own_from_expr`, `l2_emit_graph_field_value`,
`l2_model_inst`, `l2_type_inst`, `l2_occ_expr`, `l2_tok_method_occ`,
`l2_cf_actual_emit`, `l2_emit_address`, `l2_emit_raw_path`,
`l2_prefix_deref`, `l2_deref_load`, `l2_capture_indirect_place`,
`l2_emit_index_base`, `l2_emit_index_place`, `l2_emit_path_load`,
`l2_emit_array_ptr`, `l2_held_binding`, `l2_held_convert_emit`,
`l2_hidden_forward`, `l2_hidden_from`, `l2_hidden_lex` and
`l2_cap_host_src`; with them `l2_emit_index_expression` and
`l2_num_read_text`, which fed their texts. `l2_cat` -- the join of at most
1023 bytes -- is removed; `l2_tok_text` and `l2_fmt_l1_string` keep their
buffer, whose room their callers size from the atom (`l2_tok_tx`, a table
cell's text, a source literal). A call's hidden inputs are one block of
texts, as its actuals (`l2_emit_call_hides`): the 1024-byte slots and
`l2_act_at` go. The 59 buffers the callers had become texts on those
buffers (`l2_tx_local`: the buffer is the text's first room, and the text
grows past it), and the 19 adapter sites hand the text; `l2_tx_fixed` is
removed, and `l2_index_token`, which nothing called. One helper is added,
`l2_prefix_levels` (levels of `\`, then a text).

**What a program met.** With the translator of section 98 (`opus_full_29`,
the bytes of `247a6339`):

- a dereference word -- `\...\p`, its levels and its pointer's name
  together -- was taken in at most 255 bytes (`l2_prefix_deref`), and a
  longer one was refused as an assignment target ("assignment target must
  be a declared typed mutable value");
- a raw C path was written in at most 256 bytes (`l2_emit_raw_path`) and a
  raw index in at most 1024 (`l2_emit_index_expression`,
  `l2_emit_index_place`); past them the translation was refused with no
  place ("internal: a refusal said nothing");
- the address type -- a pointer one level deeper than the target -- of a
  path target's address (`l2_emit_address`) and of a place captured before
  it is written through (`l2_capture_indirect_place`) was joined by
  `l2_cat` into 256-byte buffers on the stack, its text and its
  declaration, and written past them (ADDRESS-TYPE-PAST-BUFFER,
  `steps/defects.md`): with a target 241 levels deep the address's L1 is
  already wrong at exit 0 -- a cast with no type, `(cast: () l2_pxp[0])`,
  which `l1trans` refuses; at 245 `(cast: (2_t1) l2_pxp[0])`, which
  `l1trans` takes and gcc refuses --; at 300 the translator crashes (139),
  for the address and for the capture alike; at 1100 the join's 1023 bytes
  refuse it with no place.

| Row | What it pins | The previous translator |
| --- | --- | --- |
| `unit_exprtext_deref_deep` (+`_walk`) | a write and a read through a pointer 260 levels deep, handed down a chain of 260 methods as `unit_addr_depth` hands it down two | refused at 6:5 |
| `unit_exprtext_deref_name` (+`_walk`) | a write and a read through a pointer local named with 300 bytes | refused at 7:5 |
| `unit_exprtext_address_deep` (+`_walk`) | the address of a path target whose type is a pointer 300 levels deep, and of one 1100 deep, each handed to a formal one level deeper | crashes (139) |
| `unit_exprtext_capture_deep` (+`_walk`) | a write through one level of a pointer 300 levels deep, and of one 1100 deep: the place is captured in a temporary first | crashes (139) |
| `unit_exprtext_raw_path` | a write through a raw C path of 61 members over a chain of C records (`LmP0Field`) the program links | refused with no place |
| `unit_exprtext_raw_index` | a raw pointer index of 160 terms, written and read | refused with no place |

Every row's success is 7. The twins walk every method, and the root under
its walk; the raw path's and the raw index's rows run natively only: under
`--walk-methods` their methods keep their native words (the C door in
`chain_read` and `far`, the raw pointer index in `work`). The deep
dereference's two rows are the gate's slowest compiles, about 1 m 45 s
each, with cc1 at 222.5 MB -- under the previous gate's peak, 232.7 MB of
another row.

Not pinned by a row. A foreign type's word in a declarator was cut at 255
bytes, silently (`l2_pointer_decl_text`), and a foreign type's name in a
cast was copied in 256 (`l2_cast_resolve`): measured on translation only --
for a cast to `c.T` named with 300 bytes the previous translator writes the
name cut to 255 bytes in four places of the L1 and whole in one, this one
whole in all five -- because `l1trans` takes no C type name of 64 bytes or
more (the toolchain debt of section 98). Migrated by the same rule but
reached by no recorded translation and not probed for length: `l2_tok_slot`;
`l2_emit_reference_declaration`, whose declared name was copied in 256 bytes
(a pointer local declared with a name of 300 or 1100 bytes is an own field,
`l2_q`, and its L1 is the same with both translators); a machine local as a
raw index's base and a define name as one of its pieces, copied in 1024
(`l2_emit_index_base`, `l2_emit_index_expression`); the machine-local path
root's name, copied in 64 (`l2_emit_path_to`), which only the programs of
its producers reach (DECLARATION-CANDIDATE-ROLE, OWN-TYPE-CODE-BANDS). No
coverage, no unchanged replay and no "not this shape" shows them dead: they
stay for the producer and reachability census (Codex 2026-10-06). The held
call's converted value (`l2_held_convert_emit`, 1100 bytes) is a read of a
generated name, `l2_hcr<n>`; a bound value's text (`l2_emit_stmts`, 1100
bytes) was reached by no probe: what is bound is a name, a path read into a
temporary or a letter's payload.

Reach, measured with a coverage build of this translator over the 1937
recorded translations of `opus_full_27`: every writer of the group runs but
`l2_tok_slot`; `l2_emit_reference_declaration` never runs; in
`l2_emit_index_base` the slot and machine-local branches never run, and in
`l2_emit_index_expression` the own-array and define-name branches.

Mutants, each its own translator, run by the harness of an isolated shared
clone of HEAD with the step laid over it, its own evidence directory, one
after another; the rows named are run, and all of them pass without it:

| Mutant | Killed by |
| --- | --- |
| a dereference word of 256 bytes or more refused again (`l2_prefix_deref`) | `unit_exprtext_deref_deep`, `unit_exprtext_deref_name` (no L1) |
| a raw C path past 255 bytes refused again (`l2_emit_raw_path`) | `unit_exprtext_raw_path` (no L1) |
| an index past 1023 bytes refused again (`l2_emit_index_expression`) | `unit_exprtext_raw_index` (no L1) |
| the address type's text bounded at 256 bytes (`l2_emit_address`) | `unit_exprtext_address_deep` (no L1); `unit_exprtext_capture_deep` passes |
| the captured place's declaration bounded at 256 bytes (`l2_capture_indirect_place`) | `unit_exprtext_capture_deep` (no L1); the other five rows pass |
| a declarator joined in at most 1022 bytes again (`l2_pointer_decl_text`) | `unit_exprtext_address_deep`, `unit_exprtext_capture_deep` (no L1); the other four, `unit_exprtext_sizeof_frame` and `unit_sizeof_type_frame` pass |
| one indirection fewer (`l2_prefix_levels`) | `graph_shape_machine_address`, `unit_addr_arg`, `unit_addr_take` (no L1), `unit_addr_depth` (the program crashes) |
| a raw C path's members after its root not written | `unit_exprtext_raw_path` (exit 1), `unit_c_member_len`, `unit_c_member_twohop` (the program crashes) |
| a pointer declarator without its type's word | `entry_argc`, `entry_array`, `entry_dyn_array_index` (`l1trans`) |
| an index of its first piece only | `unit_exprtext_raw_index`, `unit_raw_pointer_index_expression` (exit 1) |
| an input the site does not need handed as an empty text, not `ABSENT` (`l2_emit_call_hides`) | `unit_callable_formal_site_names_reference`, `unit_callable_formal_site_reference_forwarded`, `unit_callable_formal_site_reference_unasked` (gcc); the other 5 of the 8 rows whose L1 it changes pass |
| a held call's converted binding left as it was given (`l2_held_convert_emit`) | `unit_held_call_free_name_converted` (exit 1, natively and walked) |
| an indirect place kept as written, not the temporary it was captured in (`l2_capture_indirect_place`) | only `unit_arg_decl_oldptr`'s text pin of the native relationship -- a text pin, not behaviour. Of the 58 rows whose L1 it changes, run, the other 57 pass: in none of them does the place change between its capture and the write. The behaviour stays untested (FIXED-BLOCKS-AUDIT). |
| a slot's load without the type it is cast to (`l2_own_cell_load`) | only `unit_ref_local_path`'s text pin; of a fixed sample of 60 of the 493 rows whose L1 it changes, run, the other 59 pass. The behaviour stays untested (FIXED-BLOCKS-AUDIT). |

Found beside it. A pointer about 950 levels deep, handed down a chain of
methods as in `unit_exprtext_deref_deep` -- one interned foreign type for
each level --, is refused "invalid raw dereference": past 900 interned
types the pointer codes reach the own array band (OWN-TYPE-CODE-BANDS, its
own step). And `@: size_t p1 @v`, then `@@: size_t p2 @p1`: `\p2` reads
`p1`'s cell, which holds no value while `p1`'s value is its working value
(L2 section 18.2) -- a null read at run time, the same with both
translators; asked of Codex, not this step's.

Replay, with this section's gate translator (`opus_full_31`) against
section 98's (`opus_full_29`) over the 1937 recorded translations of
`opus_full_27`: every row keeps its L1, exit, messages and number of
allocations.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_31` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_29` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_31` (full harness) | RED39/1953: against `opus_full_29` FAIL→OK 0, OK→FAIL 0, added 10, removed 0. The declared paths were hashed before the run; the staged translator and the fixtures are their bytes. |
| `build/l2_harness/opus_focus_g3b` (focused, before the gates) | 40 rows: this section's six rows and their four twins, the rows its mutants are killed by and the controls of sections 94, 96, 97 and 98, all green. |

<a id="declaration-one-value"></a>
## 100. A declaration's candidate is one value (DECLARATION-CANDIDATE-ROLE)

The defect (`steps/defects.md`, found by the producer census of the
machine-local path root): a declaration with a declaration word whose
candidate is one value and one more -- `@: Model m @ Model 3`,
`const: @(Model m @ Model 3)`, `@: size_t p @w 3` in a method -- was turned
away by the own classifier (`l2_own_decl_ty` gave 0 when the operand reader
did not span the candidate) and taken by the machine-local collector for a
machine local with the model. What the program then met depended on what
read the name: a read was refused at its path ("root operation not walkable
yet: a field path"), a sum at its root ("unknown field path root"), the
`const:` form at its start ("root operation not walkable yet: this
statement"); with nothing reading the name the translation passed, and its
L1 joined the extra value to the address (`lmx_arena_ref_struct(node,
0U)3`) or to the cell (`(cast: (@: size_t) l2_q0_from[0])3`).

The repair, by Codex's terms (2026-10-06: one truth of classification and
check for the own collector, the machine-local one and the check with the
emission; "not a declaration" apart from "a recognized but invalid
declaration"; the candidate checked by the ordinary rules of the receiving
place and the operand, neither a new parse nor a general refusal of a
candidate of several atoms; the refusal located at the declaration, read or
not, in the `const:` form too; a call, an arity and a type keep their own
reasons):

- one value is one predicate, `l2_fields_one_value`: what the operand
  reader spans -- one atom, one operator run (a path, a sum, a unary
  address), one Frame --, or a call, whose first item names a callable and
  whose actuals follow it (book section 9, the rule `l2_tail_is_structure`
  reads a tail by);
- a declaration word -- `[]`, `@`, `const`, `immutable`, `independent` --
  makes the Frame a declaration whatever its candidate: the own classifier
  no longer turns it away on the candidate, so the own collector takes an
  invalid declaration where it takes a valid one, and the machine-local
  collector does not see it (`l2_own_decl_ty`). Under a type word alone a
  tail the operand reader does not span still declares nothing -- a call,
  a statement --, as before;
- the reference check and the own check (`l2_check_reference_init`,
  `l2_check_decl_candidate`) refuse a candidate that is not one value at
  its first extra value: "a declaration takes one value"
  (`l2_check_one_value`).

| Row (+`_walk`, the same under `--walk-methods`) | The declaration | The previous translator |
| --- | --- | --- |
| `unit_decl_one_value_refused` | `@: Model m @ Model 3`, m not read | translates; the L1 joins the 3 to the address |
| `unit_decl_one_value_read_refused` | the same, m\value read | refused at the read's path |
| `unit_decl_one_value_const_refused` | `const: @(Model m @ Model 3)` | refused at the statement's start, "root operation not walkable yet: this statement" |
| `unit_decl_one_value_two_refused` | `@: Model m (@ Model) (@ Model)` | translates |
| `unit_decl_one_value_name_refused` | `@: Model m @ Model z` | translates |
| `unit_decl_one_value_prim_refused` | `@: size_t p @w 3` | translates; the L1 joins the 3 to the cell |
| `unit_decl_one_value_call_tail_refused` | `@: Model m make 3`: one value, a call | "incompatible entry signature" at `make`, the same now |

Each refusal of the first six is "a declaration takes one value", at the
extra value. The last row pins that a call keeps its own reason: the call
check reads `make` with no actuals and refuses its arity -- as it does for
`r: twice 3`, an assignment (asked of Codex: whether a call written as its
callable's name and its actuals is a call with those actuals in a value
position; the declaration does not decide it). The legitimate candidates --
a path (`@ Data\number`), an element (`@values[0]`), `make(1)`, a
factory's receipt `@:`, `(@ Model)` -- are the existing rows'; none of them
changes (below).

Measured beside the rows. A diagnostic build that reports each machine
local added from a declaration whose candidate the operand reader does not
span: with the previous translator 2 to 6 reports for each probe program in
a method (the collection runs more than once), with this one none. At the
root a `const: @(T m ...)` declaration is read as the entry's signature and
refused "incompatible entry signature" valid or not -- the invalid one was
"root operation not walkable yet: a Structure-typed field"; a root
`@: Model m @ Model 3` is refused "a declaration takes one value" at the 3,
as in a method. Not changed: a declaration under a type word alone whose
candidate is one value and one more -- `int: v 3 4`, `int: seen values[i] 7`
(`unit_indexed_initializer_extra_refused`) -- is still refused "unsupported
body" at the declaration. It never took another role; its words are not
the declaration's.

Replay, with this checkpoint's translator against section 99's over the
1952 recorded translations of `opus_full_31`: every row keeps its L1, exit,
messages and number of allocations -- no recorded translation has such a
declaration (the census over the 1942 of `opus_full_29`: the own
classifier's span test turned away Frames under a type word only, and the
machine-local collector added none of them).

Mutants, each its own translator, run by the harness of an isolated shared
clone of HEAD with the checkpoint laid over it, its own evidence directory,
one after another; without a mutant every row named passes (30 rows: the
fourteen above, section 101's four and twelve of the rows the one-field
mutant changes):

| Mutant | Killed by |
| --- | --- |
| a candidate taken as written, no one-value check (`l2_check_one_value`) | the six refusal rows and their twins: the own collector now has the declaration, and `l2_check_fields` refuses it at the candidate's first field with other words ("root operation not walkable yet: this expression") |
| the refusal said at the candidate's first field, not at the value too many | the same twelve rows (the place) |
| a call written with its actuals after the callable's name not one value (`l2_fields_one_value`) | `unit_decl_one_value_call_tail_refused` and its twin: "a declaration takes one value" at the 3 takes the call's own reason |
| one value taken for one field, a general refusal of a candidate of several atoms | the twelve rows sampled from the 148 whose translation it changes in the replay -- `unit_address_path_actual_span`, `unit_address_reference_cell`, `unit_array_value_pointer_elements` and the others: no L1 |
| the own classifier turning a declaration word's Frame away on its candidate again (`l2_own_decl_ty`) | no row: the check refuses at the same place on the machine-local route too. The classification is seen only by the diagnostic build above (no machine local added from such a declaration); kept because the classification is one truth for both collectors (Codex), not because a row tells it apart. |
| (section 101) the native publication skipping the pointer fields (`l2_emit_publish`) | `unit_pointer_cell_publish_call` (exit 1: p1's cell is not `@v`); its walked twin and both store rows pass -- the walker publishes on its own, and the store does not need a boundary |

<a id="pointer-cell-publication-controls"></a>
## 101. A pointer to a pointer's cell: the publication controls (Codex 2026-10-06)

Section 99 asked whether `size_t: v 0U`, `@: size_t p1 @v`,
`@@: size_t p2 @p1`, `\\p2: 5U` -- a null store at run time -- is a
defect. Codex (OPUS-CODEX-20261005-01): no. After the first declarations
the working p1 holds @v and is dirty, while its published cell still holds
what it held; p2 is the address of that cell (L2 section 18.2: an own
field's `@` is its real published cell, not its working cache; semantics
section 12: publication happens at the defined boundaries, and taking an
address is not one). The first load of the double dereference reads the
unpublished cell. Nothing about two levels is a language restriction, and
no rejection, publication on `@`, flush of pointer initializers,
checkpoint before a dereference or reload after a pointer write is to be
added. The one-level observation (`\p1: 5U`, then the bare v still 0) is
the norm, as L2 section 18.2's example. A real defect would be p1's cell
still null after its dirty publication, or an explicit store through the
pointer losing a level or a value.

The two controls Codex asked for, natively and walked, checking values and
the address:

| Row (+`_walk`) | What it pins |
| --- | --- |
| `unit_pointer_cell_publish_call` | A: an ordinary user call (`int: done publish()`, a method that does nothing) after the declarations publishes p1 -- `\p2` is then `@v` --, and `\\p2: 5U` changes v's cell: `\\p2` and `\p1` read 5, the bare v keeps 0. |
| `unit_pointer_cell_store_first` | B: the store `\p2: @v` writes p1's physical cell -- `\p2` is `@v` --, and `\\p2: 5U` changes v's cell as in A. |

In the twins every method is walked (`publish` and `check`). Without the
call or the store the program is the observation above -- with this
checkpoint's translator it stops with 139 natively; it is not a test
outcome. A native publication that skips the pointer fields (a mutant of
`l2_emit_publish`) fails control A natively; see the table above.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_32` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_30` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_32` (full harness) | RED39/1971: against `opus_full_31` FAIL→OK 0, OK→FAIL 0, added 18, removed 0. The declared paths were hashed before the run; the staged translator and the fixtures are their bytes. |
| `build/l2_harness/opus_focus_dcr` (focused) | 30 rows on the gated bytes: the eighteen rows of sections 100 and 101 and the twelve the one-field mutant changes, all green; the same rows ran green on an isolated clone of these bytes before the gates. |

<a id="declaration-call-tail-answer"></a>
## 102. A call is its Frame: the call tail answered (the author, 2026-10-06)

Section 100 left `@: Model m make 3` refused for make's arity: its one-value
check read a tail whose first atom names a callable as that call's value.
The question went to the author
([`LMX_blog/q/value-tail-prefix-call.md`](../LMX_blog/q/value-tail-prefix-call.md)),
and he answered the same day
([blog](../LMX_blog/2026-10-06.md#explicit-call-frame)): a call needs its
Frame, `r: twice: 3` or `r: twice(3)`; `r: twice 3` is no call. Codex: no
implicit prefix call and no declaration-only call normalization; a bare
method name keeps its rule (its application without actuals), and so does
a receiver's consumption of its tail.

The author also asked whether we have a call without `:` anywhere. The
translator's answer:

| Where | What it did | Now |
| --- | --- | --- |
| `l2_fields_one_value` (section 100) | a tail whose first atom names a method, a C door or a predefined function was one value, that call's | removed: `make 3` is two values |
| `l2_tail_is_structure` | the same reading, from T6: such a tail was the call's value, not a Structure | removed: it is a Structure like any other |
| `l2_unit_role` | T6's store `add5: makeAdder 5` ran the factory | gone since FACTORY-RESULT-RECEIVER (2026-10-05): a definition |
| a receiver word written as an atom | `b: merge A C`: `l2_merge_frame` settles it into the merge Frame (`l2_merge_atom_settle`), and the classifiers take the atom for the receiver's application | kept at this checkpoint; a crutch by the author's word the same day, to go with its rows ([RECEIVER-ATOM-CRUTCH](defects.md#receiver-atom-crutch)) |
| a bare method name in a value | its application without actuals (`i: findValue`) | kept |

No route turns `r: twice 3` into `twice(3)`: the bare twice is checked as
its application without actuals and refused, at twice, for its missing n.

The receiver atom was no exception either. Later the same day the author
([blog](../LMX_blog/2026-10-06.md#explicit-receiver-frames)): no exceptions -- `b: merge: A C` or
`b: merge(A C)`; `b: merge A C` is a crutch, and everything like it goes.
Measured on `178508a1`: a translator without the atom readings changes 264
of `opus_full_34`'s 1980 recorded translations, 231 of them from accepted to
refused -- the fixtures that write `x: merge Y`. Their removal and migration
is [RECEIVER-ATOM-CRUTCH](defects.md#receiver-atom-crutch), the plan's
[K03-EXPLICIT-RECEIVER-FRAMES](../next_core_tasks_v2.md#explicit-receiver-frames), the step after
OWN-TYPE-CODE-BANDS.

After FACTORY-RESULT-RECEIVER `l2_tail_is_structure`'s reading lived on at
two places: the nested definition of a named Structure (Q57,
`l2_ns_nested_def`) and the forward check of an ident-only head
(`l2_struct_defined_below`). A nested `C: tick 7` (tick a method without
formals) was refused "internal: an own declaration has no physical field"
([CALLABLE-FIRST-TAIL](defects.md#callable-first-tail)); now C is a nested
definition, and running S runs nothing. A forward `A: b` above `A: tick 7`
took `A: b` for A's definition and the line below for A's application
("more arguments than A has formals"); now `A: tick 7` defines A and
`A: b` is the forward-typed name, refused "unresolved name" at it --
measured, neither a norm nor a row. `l2_tail_decl_first` and
`l2_tail_field_body`, which nothing calls, are deleted.

Replaying the 1970 translations recorded by `opus_full_32` with this
checkpoint's translator: two change, the call-tail row and its twin, now
refused at 3. With the declaration's half alone the same two; the
classifier's half and the deleted helpers change none.

| Row (+`_walk`) | What it pins |
| --- | --- |
| `unit_decl_one_value_call_tail_refused` | `@: Model m make 3` refused at 3 (13:21), "a declaration takes one value"; it said make's arity at 13:16 |
| `unit_value_tail_prefix_call_refused` | the author's `r: twice 3`: refused at twice (8:4), "incompatible entry signature" -- unchanged by this step |
| `unit_value_tail_call_explicit` | `r: twice: 3` and `s: twice(3)` each give 6 |
| `unit_nested_def_method_tail_dormant` | `C: tick 7` nested in S: running S prints nothing; the program says only DONE |

Mutants, each on an isolated clone of these bytes, run on these rows,
section 100's call controls and the factory dormancy rows (15 rows, all
green without a mutant):

| Mutant | Rows that go red |
| --- | --- |
| `l2_fields_one_value` reads a callable-first tail as one value again | the call-tail row and twin: the arity reason again |
| `l2_tail_is_structure` reads it as the call's value again | the nested dormant row and twin: the internal error |
| a bare method name in a value is not checked as its application | the `r: twice 3` row and twin: "root operation not walkable yet: this expression" instead |

The row's make returns `Model`, the Structure reference its `@: Model`
result names; it returned `@ Model` before, and both read 7 today because
unary `@` of a Structure gives its descriptor
([critical_pointer_to_struct_bug](defects.md#critical-pointer-to-struct-bug)).
That depth is the pointer debt's, not this step's.

The vertical spellings. The author proposed two vertical forms of the same
call ([blog](../LMX_blog/2026-10-06.md#vertical-call-fence)). Measured with
this checkpoint's translator and with `opus_full_32`'s, the same (Codex
measured them first, read-only):

| Spelling (lines) | Result |
| --- | --- |
| `r: twice:` / `---` / `. . 3` / `---` | P0 error 13, "source level increase must be one step", at the level-2 item |
| `r: twice:` / `. ---` / `. . 3` / `---` | P0 gives r two fields, twice with an empty body and an anonymous sibling holding 3; the translator refuses "twice has no argument n" |
| `r: twice:` / `. . 3` / `---` | P0 error 13 at the level-2 item |
| `r:` / `. twice:` / `. . 3` / `---` | translates; L1 byte-identical to `r: twice: 3` and `r: twice(3)` |

The author first held that the level-2 body is twice's (r at level 0,
twice at level 1 even on one physical line), and two old printTree
binaries of `lingvamyxa_old_worked_version` give the same tree as today's
parser: both reset the per-line level to 0 at a new line, and both
delimiter resolvers truncate to the delimiter's level before choosing the
parent (Codex, read-only). The author cancelled the fix, and then
corrected himself ([blog](../LMX_blog/2026-10-06.md#vertical-call-fence)):
the old parser is right -- the line's level reset closes the short form,
and the fence makes a sibling Structure. So `. ---` gives r a sibling of
twice, and that tree is not a defect. The deferred research is removed
from the plan and its [ticket](tickets/parser_level_forms_research.md)
closed: no parser change and no new parser expectation; the measurements
above are the record.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_34` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_32` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_34` (full harness) | RED39/1981: against `opus_full_32` FAIL→OK 0, OK→FAIL 0, added 10, removed 0. The declared paths were hashed before the run; the staged translator and the fixtures are their bytes. |
| isolated clones (scratchpad, before the gates) | 15 rows -- this section's, section 100's call controls and the factory dormancy rows -- all green on these bytes; each of the three mutants red on its own two rows only. |

<a id="own-type-code-bands-fixed"></a>
## 103. Own codes without bands; the graph reference's formal code (OWN-TYPE-CODE-BANDS)

The defect ([defects](defects.md#own-type-code-bands)): an own field's
code carried kind and type in one number by bands -- a pointer 1000 + ft,
an Array of pointers 2000 + ft, ft = 100 + the foreign type's index -- so
from the 901st interned foreign type a pointer's code fell in the Arrays'
band. And the graph reference's code was the dynamic-input code of
`Lmx *`'s pointer own (1101 when `Lmx *` is foreign 0), stored in formal
tables and read back by decoders that guessed the space by the number's
interval (Codex: compiler-only kind and the existing formal type behind
common helpers; formal tables hold formal codes only; no wider bands and
no new limit).

Four stages, the first three replayed over `opus_full_34`'s 1980 recorded
translations, the fourth over `opus_full_35`'s 1992 (stage 2b's gate):

| Stage | What | Replay |
| --- | --- | --- |
| 1 | every own-code literal and range test behind `l2_oc_pointer`, `l2_oc_parray`, `l2_oc_is_pointer`, `l2_oc_is_parray`, `l2_oc_is_ref`, `l2_oc_ft` -- with `l2_ret_cell_ty`'s literal own codes 1012, 1016, 1003 and 1017, found by a census of every literal from 1000 to 2999, not by the two band words | identical: L1, exit, messages, allocations |
| 2a | the graph reference has a code in each space: the formal code `l2_graph_code()`, 42, one named code of the formal space as the Message reference's 29 is; its own storage `l2_graph_own()`, the pointer own of `Lmx *`; its dynamic-input code `l2_graph_dt()`. The producers ask `l2_graph_ft`, which interns `Lmx *` where the old code did, so the foreign types keep their order; a reader compares with the code and interns nothing. `l2_formal_raw` spells 42 as `Lmx *`, `l2_pointer_depth` and `l2_own_ty_of_param` read it; `l2_colon_is_graph_ty` reads formal codes only (its two callers holding an own code ask `l2_own_is_graph`); the five recoveries of "dt_of_own(1000+foreign)" in `l2_colon_ret_ty`, `l2_emit_call_result`, `l2_emit_formal`, `l2_sig_ret` and `l2_emit_public_sig` are `l2_formal_raw`. `l2_colon_graph_ty` is gone | 7 rows change, below |
| 2b | the reference own code without bands: a pointer to formal type ft is 1000 + 2 ft, an Array of pointers 1001 + 2 ft; above the one partition of the own space the kind is the low bit | identical to 2a |
| 3 | stage 1's replay-compatibility branch is gone (below): a null literal received into a reference place is the pointer cell of the place's value type, `l2_value_ft_of_own` | identical to 2b, allocations too |

The seven rows of stage 2a. Codex: the old -1-versus-2101 decode is not
kept for an identical replay; each difference is tied to its contract and
executed.

- `unit_recv_use_passed_thin` (+`_walk`): the null literal compared with
  the Structure formal v gets the pointer cell of `Lmx *`
  (`LMX_TYPE_POINTER_BASE + 100`) instead of `+ 1101` -- the graph code had
  been read as the own code 2101 of an Array of pointers. Both run green;
  the type code shows in the L1 only.
- `unit_ref_formal_rebind_same`, `unit_ref_formal_rebind_other_refused`,
  `unit_formal_spelling_rebind`, `unit_formal_spelling_rebind_other_refused`,
  `unit_site_model_header_context`: the retained walker graph builds the
  admission (ADMIT_AS) of the value rebound into the Structure formal; the
  band decode had given the formal no cell (`l2_own_ty_of_param` -1). The
  four rebinding rows, walked with the committed translator, stop with
  "lmx: walk error: INVALID" (exit 3); with this one they say what their
  native rows say. Their walked twins are new rows.
  `unit_site_model_header_context` is walked in the harness and green with
  both translators.

Witnesses. Distinct foreign pointer types are made of C's own type names at
growing depth -- (name, depth) is the interner's key; typedefs through
header units stop at l1trans's 128 header type names a translation unit,
`too many header type names` (FIXED-BLOCKS, l1trans's own step).

| Row (+`_walk`) | What it pins | With the committed translator |
| --- | --- | --- |
| `unit_oc_types_below` | 899 types, then a Structure reference m: m\value reads 7 | green, the control |
| `unit_oc_types_above` | 950 types, then m: `Lmx *` is the 951st | refused at the 901st C declaration, "assignment value has incompatible type" |
| `unit_oc_types_far` | 1101 types; the 1102nd (`double` at depth 138, formal code 1201) as a pointer z holding an address, an Array of two such pointers and the formal and result of a method; m last: the addresses and the Array's length compared | refused at the 901st C declaration |
| `unit_oc_rebind_pointer_second` | another interning order: `Lmx *` first, a foreign pointer second, then `v: w` rebinding the Structure formal: 7 | refused at `v: w`, "a reference where a number is asked" |
| walked twins of the four rebinding rows | the walked rebinding with its admission | "lmx: walk error: INVALID", exit 3 |

Mutants, each on an isolated clone of the stage-2b bytes over the 19 rows (the
seven above, the four twins, the eight witness rows), all green without
one: without stage 2a, the four walked twins, `unit_oc_rebind_pointer_second_walk`
and the above and far rows are red; without stage 2b, only the above and
far rows and their twins; without either (the committed translator), every
new row but the control.

Stage 3, the null literal. Stage 1 had kept one branch for an identical
replay: in `l2_rw_reference_value` an Array-of-pointers code gave its
element's own code, and that own code went to `l2_ptr_cell_type` as a
formal one -- the old decode. Codex (OTCB-NULL-PROJECTION): the branch goes
before the commit; the null literal received into a reference place is the
pointer cell of the place's value type, the common projection
`l2_value_ft_of_own` -- a pointer's held formal code, an Array's descriptor
reference. A census build (each null literal said on stderr its own code,
its kind, its value type and the old branch's choice; a diagnostic, never a
gate input), replayed over `opus_full_35`'s recorded translations: the
builder ran 19040 times in 204 translations, every time for a pointer own
code, never for an Array of pointers, and the old branch and the projection
named the same type every time -- no translation reached the branch's own
case. Four controls run natively and walked, exit 0: a pointer (own code
1022, value type 11), a graph reference (1200, 100), an Array's descriptor
compared with zero (1200, 100), an Array's element (1022, 11).

Mutants. The branch put back is stage 2b itself: identical on all 1992
recorded translations. The own code fed in as the formal one
(`l2_ptr_cell_type(ty, ...)`) changes the L1 of 201 translations (the other
three of the 204 are refusals): the literal's cell is
`LMX_TYPE_POINTER_BASE + 1022` for `+ 11`, `+ 1200` for `+ 100`. Over those
201 rows on an isolated clone it changes no verdict: the walker reads a
literal's cell by its class (`lmx_walk_value_load`: at or above
`LMX_TYPE_POINTER_BASE`, a reference), and stores, argument contracts and
comparisons of a reference read its class or its address. The wrong code
shows in the arena: each of the 14 runs among those rows that print their
arena has a pointer domain of type 2224 (1024 + 1200) that the program
never declared. No row reads an arena's domain types; the cell's exact type
is metadata no execution consults today.

What stays outside. The kernel's pointer cell code
`LMX_TYPE_POINTER_BASE + ft` (1024 + ft) meets
`LMX_TYPE_ARRAY_OF_POINTER_BASE` (1048576) at ft = 1047552: a range of the
kernel's own encoding, now
[KERNEL-POINTER-TYPE-RANGE](defects.md#kernel-pointer-type-range), before
G5. `l2_path_root`'s method encoding (at or below -1000, `i < 990`) belongs
to the machine-local route's step, after the renewed census.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_36` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_34` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_36` (full harness, the final bytes) | RED39/1993: against `opus_full_35` FAIL→OK 0, OK→FAIL 0, added 0, removed 0; against `opus_full_34`, before this step, FAIL→OK 0, OK→FAIL 0, added 12, removed 0. The declared paths were hashed before the run; the staged translator, harness and fixtures are their bytes. |
| `opus_kernel_35`, `opus_l3_33`, `opus_full_35` (stage 2b, the branch still in) | GREEN: 297 targets, 114 selftests; all 11 suites; RED39/1993: against `opus_full_34` FAIL→OK 0, OK→FAIL 0, added 12, removed 0. Stage 3 replays its 1992 recorded translations identically. |
| isolated clones (scratchpad) | The mutants above: the three of stage 2 over the 19 rows on the stage-2b bytes; the own code as formal over its 201 rows on the stage-3 bytes. |

<a id="null-literal-exact-type"></a>
## 104. The null literal's exact cell type, witnessed (OWN-TYPE-CODE-BANDS follow-up)

Section 103's mutant -- the own code fed in as the formal one at the null
literal -- changed 201 L1s and no verdict: the kernel reads a pointer
cell's type by its class. Codex (OTCB-EXACT-NULL-TYPE-WITNESS-20261006-01):
a wrong exact storage type is a representation-contract failure even when
present consumers accept its class; a killing witness reads the
compiler-generated payload through the existing address and type services
and compares it with an independent contract witness -- no dump text, no
number the row supplies, no registry of declared types.

The harness driver gets two physical path facts beside `samepath` and
`cellpath`, read through the arena (`lmx_domain_kind`, `lmx_domain_type`,
`lmx_pointer_value_known`):

| Fact | Holds when |
| --- | --- |
| `typepath P Q` | the addresses at the two paths belong to one exact typed arena domain: kind and type equal |
| `nullrefpath P` | the address at the path is an actual pointer cell, present, holding the null reference |

The row `unit_oc_null_literal_type` (+`_walk`): at the root `@: int p 0`
and `@@: int q 0`, one pointer depth and the next; the init SET of each
holds a LIT whose payload is the null literal's cell. For each declaration
the payload and the declared cell it initializes are one exact typed
domain, and the payload is a present null pointer -- at the build and again
at the exit post; `check` compares both with 0 and gives 7. The expected
type is the declared cell's, which the unit's cell builder makes, not the
literal's emitter. The row runs its root natively and then walked; the twin
walks `check` too.

| Translator | `unit_oc_null_literal_type` | `_walk` |
| --- | --- | --- |
| `a71009cc` | OK, 103 checks, the root native and walked | OK, 103 checks |
| the own code fed in as the formal one at the null literal | red: the four `typepath` facts, at the build and at the post, both runs | red: the same four |

The facts fail on their own: `typepath` between p's cell and q's payload,
or between p's cell and an OWN's slot cell, is red; `nullrefpath` on an
OWN's slot cell is red, and on p's cell at the post after `p: @x`. The
Array-of-pointers branch stage 3 removed keeps its census (reached by none
of 19040 null literals, section 103); no source form is invented for it.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_37` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_35` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_37` (full harness) | RED39/1995: against `opus_full_36` FAIL→OK 0, OK→FAIL 0, added 2, removed 0. The declared paths (the driver, the harness, the fixture) were hashed before the run; the staged copies are their bytes. |
| isolated clones (scratchpad) | The two rows on these bytes: OK with `a71009cc`'s translator; red with the own code fed in as the formal one, on the four `typepath` facts only. |

<a id="explicit-receiver-frames-removal"></a>
## 105. A receiver's application is its Frame: the atom collectors removed (K03-EXPLICIT-RECEIVER-FRAMES)

The author (2026-10-06, [blog](../LMX_blog/2026-10-06.md#explicit-receiver-frames)): `b: merge: A C` or
`b: merge(A C)`; `b: merge A C` is a typo, and the code that reads it is a crutch to remove whole. Plan:
[K03-EXPLICIT-RECEIVER-FRAMES](../next_core_tasks_v2.md#explicit-receiver-frames); stage request
K03-EXPLICIT-FRAME-REMOVAL-20261006-01 (Codex).

The census, frozen before any change, on the baseline after OWN-TYPE-CODE-BANDS: a diagnostic build in which each
reading said "RCV <reader> <word> <line>:<column>" on stderr, and a build without the readings, both replayed over
`opus_full_36`'s 1992 recorded translations.

| Census | Count |
| --- | --- |
| translations that change without the readings | 268: 235 accepted -> refused, 33 refusals with another message, 0 refused -> accepted; each has a site |
| site readings | 441, all of the word `merge`: the settle 441, `l2_receiver_value`'s atom branch 102 of them; the atom branches of `l2_tail_is_structure` and `l2_fields_one_value` 0 (the settle had rewritten the tree first) |
| sites | 282 in 188 fixtures (two pairs of fixtures are byte-identical files) |
| a site, the outcome unchanged | 4 rows, refused earlier for their own reason |
| the text census `x: merge Y` in tests | 289 lines: 281 of the sites, and 8 `catch: merge (...)` -- catch's arguments, no application of merge; one site, the vertical `fresh:` / `merge Model`, the text pattern misses |

Removed from `l2trans.lm1`:

| What | Its callers now |
| --- | --- |
| `l2_merge_atom_settle`, which rewrote `b: merge A C` in the tree into a merge Frame, and its call from `l2_merge_frame` | `l2_merge_frame` returns the Frame or 0; its 8 callers (`l2_emit_stmts` 2, `l2_scan_body` 2, `l2_merge_body`, `l2_merge_declaration`, `l2_rw_merge`, `l2_rw_stmt_content`, `l2_src_merge`) took 0 already for a statement that is no merge |
| `l2_receiver_value`'s receiver-word atom branch | `l2_unit_role`, `l2_local_ns_shape`: a receiver's value is its Frame |
| `l2_tail_is_structure`'s receiver-word atom branch | `l2_ns_nested_def`, `l2_struct_defined_below` |
| `l2_fields_one_value`'s receiver-word atom branch | `l2_check_one_value` |

No read of a receiver word by name in an atom's position is left. `l2_receiver_word` keeps six uses: the head
(`l2_head_absent`, `l2_local_ns_shape`), a Frame's head (`l2_receiver_value`, `l2_tail_is_structure`), and two
reserved-role exclusions of a tail atom that assemble nothing (`l2_ident_only_tail`: a receiver word is no plain
identifier content; `l2_retained_atom`: it is no retained atom).

The migration ([manifest](k03-receiver-frame-migration.tsv): fixture, old line:column, the old and the new line,
the recorded translations): each of the 282 sites gets its colon, `x: merge Y` -> `x: merge: Y`, and no other code
changes; 26 comment lines of 9 of those files follow it (five spelled the site; the four K03d rows pinned the atom
spelling itself and say now what they keep, in as many lines, so no position moves). Every changed line of the 188
files is a site or a comment line. The K03 translator on the migrated sources equals `a71009cc`'s on the originals
for all 272 recorded translations of those fixtures: L1 bytes, exit, and the messages with the moved columns mapped
back. One harness needle moves: `unit_recv_use_nested_copy_reach_limit_probe` 30:10 -> 30:11.

Controls, each with a twin that walks every method; the root runs native and walked:

- `unit_explicit_frame_method`: in a method, merge's short, compact and completed vertical spellings with one
  operand and with two, each result its own copy; a merge nested in an if body; merge's Frame returned from a
  factory, short and compact; another receiver's Frames, `length: arr` and `length(arr)`.
- `unit_explicit_frame_root`: at the root, short, compact and the dotted vertical spelling with two operands,
  `u: (merge: Model)` (an anonymous Structure's sole content) and `w: merge: (Model)`, read by methods as their hidden
  inputs.

The vertical and the compact spellings translate byte for byte as the short ones do.

Located limits met on the way, the same with `a71009cc` (not this step's): a merge Frame as an actual,
`rdx(merge(Model))`, "merge expression is not lowered in this receiving context"; `Model: mm merge: Model`, "a typed
binding whose candidate is not a name is not built yet"; a method `() Model` returning `merge: Model`, "implements is
false in return value".

Mutants: each removed collector put back alone into an isolated build of these bytes, replayed. Over
`opus_full_38`'s 1998 recorded translations -- the migrated sources -- neither the settle nor `l2_receiver_value`'s
atom branch changes any: the corpus depends on no collector, and no gated row catches one put back yet (the bare and
prefix witnesses below are remaining acceptance). Over `opus_full_37`'s 1994 -- the atom sources -- K03 changes 268;
the settle put back returns 196 of them to `a71009cc`'s outcome (59 stay as K03, 13 neither) and changes no other;
`l2_receiver_value`'s atom branch put back alone returns 1 (7 stay, 260 neither) and changes 4 others.

The bare head. Asked what a bare receiver atom is, the author answered (2026-10-06, relayed by Codex as
K03-BARE-RECEIVER-ANSWER-20261006-01 with K03-UNIVERSAL-CONSUMPTION, K03-ONE-NAMESPACE-ONE-RESOLVER and
K03-MODEL-BEFORE-ROLE; archived in the [author's log](../LMX_blog/2026-10-06.md), the rule in
[semantics](../docs/LMX_semantics.en.md#resolved-head-consumption)): one namespace for merge,
fn, int, a Structure and a method alike; first the complete head/arguments model, then one resolution of what the
head is; a bare resolved head is its application with zero written arguments, through the same consumer as `H()`,
diagnosed where it stands, never a free or dynamic input, never collecting its neighbours -- for every head, not
merge alone. This checkpoint does not implement that route. Measured on its bytes ([matrix](k03-bare-head-matrix.txt):
23 heads in 6 positions, each bare and as `H()`), the two spellings agree in 33 of 138: the bare receiver atoms go
the name path -- `x: merge` and `x: merge Model` are refused "unresolved name" at merge (with `a71009cc`, through
the deleted settle, "merge needs at least one operand"), a bare `merge` statement "unbound dynamic input merge" at
the method's call site (so with `a71009cc` too) -- while `H()` meets per-category handlers (`merge()` as a statement
"internal: a source definition has no owning producer", `x: sendMessage()` "unknown method"). The translator
dispatches by spelling: tests `l2_frame_head(node, "<word>")` on 317 lines over about 30 words, beside `l2_receiver_word`,
`l2_prim_type_word` and the atom name path. The universal route, the bare and prefix negative witnesses, and a gated
row that a reintroduced collector reddens, are K03's remaining acceptance.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_38` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_36` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_38` (full harness) | RED39/1999: against `opus_full_37` FAIL→OK 0, OK→FAIL 0, added 4 (the controls), removed 0, red rows whose message changed 0. The 192 declared paths were hashed before the run; the staged copies are their bytes. |
| `opus_full_37` against `opus_full_38`, generated L1 | Of the 1493 rows both translate, every L1 is byte-identical -- atom sources with `a71009cc`'s translator, migrated sources with this one -- but three library-mode rows, which differ only in the unit hash `l2_u<hex>` of their evidence directory (as between `opus_full_36` and `opus_full_37`). |

<a id="unified-head-s1"></a>
## 106. One head resolution: the census, the application view and the resolver (K03-UNIFIED-HEAD S1)

Codex's request K03-UNIFIED-HEAD-IMPLEMENT-20261006-01 (parent OPUS-CODEX-20261005-01) accepts the design of
the bare head (§105, the author's answer: one namespace, the head/arguments model first, one resolution, one
consumer) as a translation-only structural application view, then a common resolution in the one namespace, then
the resolved entity's contract, with five corrections: real hidden inputs stay (Q52); visibility selects the
declaration and then its category, with no global priority of categories; the written view comes before any role
and never regroups a neighbour; the census of P0 writers, of each pass's model and of admission readers comes
first; duplicate call formation folds into the common call entry as the phases move. S1 is the census and the two
pieces, with no change of behavior.

The census. P0 writers of the translation (`l2trans.lm1`, every write through an `LmP0*` node, field or
structure, and every `mem*` call):

| Writer | What it writes | On the head route? |
| --- | --- | --- |
| `l2_mad_take_nested` (two sites) | `frw\trailer: 0`: the written trailer of a nested `fn:` in a callable merge's model -- its self-return `return: f`, or its `return: merge(...)` -- is erased from the source tree | No (callable merge); a violation of the source graph: [MAD-TRAILER-WRITE](defects.md#mad-trailer-write) |
| `l2_tables_in` | `n\flags | LM_P0_NODE_INACTIVE` on a `table: source ...` statement after its projection at translation (Q46): no later pass reads it as a statement | No (statement enumeration, the table's own contract); the same follow-up could keep the fact in the table registry |
| `l2_head_rebase_node` | spans of the translator's own document for an indexed head `row[i]: v` (`l2_head_expression` parses the head text, one cached document per statement) | No (a place head, not an application's name); not the source tree |
| `l2_make_entry`, `l2_translate_unit`, `l2_ns_proc_add`, `l2_ns_loop_body`, `l2_part_root` | new shells -- E's node over the root statements, a named Structure's procedure, a part's root -- whose fields borrow the source nodes | No: no source node is written |
| `l2_bind_calls` (`l2_bind_call_in`, `l2_bind_whole`) | a call with named actuals gets its projection in formal order in a side record (`l2_call_actuals`); "the body stays as written" | No: the record is new memory, the call's Frame is unchanged |
| `l2_emit_value_convert(_n)`, `l2_rw_convert`, `l2_rw_held_convert` | local copies of a field list | No |
| about 40 `LmP0Text` slices | text views over source bytes | No node |

Each pass's model: every pass reads the method's registered body -- `l2_m_body[mi]`, a `fn:`'s body field as P0 made
it, E's shell, a procedure's shell -- and `l2_m_node[mi]`, 33 readers: the binding (`l2_bind_calls`), the scan
(`l2_dyn_local`, `l2_head_read_before`), the check, the native emission (`l2_emit_unit`, `l2_emit_body_in`), the walker
(`l2_rw_methods_count`, `l2_rw_methods_emit`, `l2_rw_stmts`) and the root's source (`l2_src_method`); an indexed head
adds its cached head document. No pass reads a reconstructed tree, and since `4e922c80` no translation-time writer
touches a head or an actual. Admission: no `lmx_*` kernel source compares a head with a word (the only such
comparison outside `l2trans.lm1` is the harness driver's own command word `merge`,
`harness/l2_eternal_driver.lm1:2080`); in `l2trans.lm1` the admission family (`l2_admit_*`, `l2_emit_admit`, the
anchors) reads no head spelling, and the receiving readers that do are in the census below.

The spelling census ([k03-head-census.tsv](k03-head-census.tsv)): every comparison of a head, an atom or a text with
a word -- `l2_frame_head(node, "w")`, `l2_text_eq(x, "w")`, `l2_payload_eq(x, "w")` -- 769 sites in 157 functions, each
with its function's class and the slice that moves it:

| Class | Sites | Slice |
| --- | --- | --- |
| stmt: statement dispatch in an evaluation body (`l2_scan_body`, `l2_check_body`, `l2_emit_stmts`, `l2_rw_stmt_content`, `l2_src_one`, ...) | 283 | S2+S3 |
| name: the free-name scan (`l2_scan_ident`, `l2_scan_node`) | 18 | S2+S3 |
| value: value, return and actual positions | 54 | S4 |
| call: the two call checks/emissions | 2 | S4 with S6 |
| def: unit items, declaration and definition shapes | 148 | S5 |
| merge: merge's operand reader | 2 | S7 |
| contract: a receiver's own contract, chosen after resolution | 59 | - |
| set: the defined word sets | 38 | - |
| boundary: P0 trailers (`end: t`, `until: c`, terminal return) | 9 | - |
| descriptive: signatures, a callable formal's header, throws lists | 4 | - |
| lexical: operators, type words in declarations, paths, indices, addresses | 122 | - |
| file: predef, library and profile files | 30 | - |

The two pieces, in `l2trans.lm1`, unused by any reader in S1:

- `l2_app_head(n)` and `l2_app_actuals(n)`: the written application at a node -- a Frame's head and its argument
  Structure, an atom's text and no written argument (0). `H()`, `H: ()` and an empty block are already one empty
  Structure in P0. A literal, a path, an operator or a quoted text is no head; nothing is classified, regrouped or
  written.
- `l2_head_resolve(mi, t, *index, *outside)`: the binding the site sees first, and it blocks every outer category of
  its name, as `l2_call_head_method` already has it -- an own field the site sees (the method's own, or a unit field
  seen from a method), a formal, an input the method already has, a slot, a body local, a name of the host's
  activation; then a method (both ways, by name or path) or a named Structure; then a word of the language; then a
  define, the C door or a declared function; else unknown. The kinds: unknown, word, method, held callable, value,
  named Structure, external, define (and "no name" for a path or an operator). `*outside` says that a value or a held
  callable found is not this activation's own -- a unit field a method sees, an input it has, its host's name: the
  hidden input of Q52, whose value the caller gives. The words (`l2_head_word`): the receivers of `l2_receiver_word`
  and the words its comment names as the language's others -- the statement words, `sizeof`, `const`, the six
  primitive type words of `l2_ptr_type_word`'s table; nothing a predef or the C door declares, and no `test`
  (TEST-RECEIVER-DOCS, a later migration). A word comes before a define and the C door: a receiver's name is the
  language's, never discovered from a header (dictionary :454).

The cross-check: a scratch build (never committed) in which the free-name scan (`l2_scan_ident`), the check of a
value-position atom (`l2_check_primary`) and every frame-head spelling test (`l2_frame_head` with a word) also ask
the resolver and log both answers, replayed over `opus_full_38`'s 1998 recorded translations (its L1 and messages
equal the committed translator's on all 1998). The pairs that agree: a method, a word, a named Structure, the C door,
a define never become an input (16 694 scan readings); values and held callables from outside the activation become
or are inputs (627 + 547 + 208 readings, Q52 kept); unknown names become inputs (358); the check's branches name what
the resolver names (17 213 readings). The pairs that differ, each explained:

| Readings | Rows | What |
| --- | --- | --- |
| `sub`, 126 frame-head readings | `unit_recursion` | `sub: direct(next)` assigns the method's local `size_t: sub`; the spelling readers take it for the `sub` receiver (`l2_bind_node` skips it as a nested method), the resolver gives the local. The readers move to the resolver (S2+S3, S5) |
| `table`, 3 scan readings and 2 frame-head readings | `unit_s7_tbl_runtime`, `unit_s7_tbl_runtime_src_refused`, `unit_s7_part_tbl_runtime_refused` | the scan makes the head of a run-time `table:` statement a dynamic input -- the defect K03 removes -- and the resolver then finds that input. S2 |
| `p0`, `p7`, `z0`, 24 check readings | 14 rows `unit_held_call_bare_name_*` | the check takes the bare name of a held callable for an own value; the resolver gives the held callable, which the emitter executes (those rows assert it). S4 routes it to the held call's consumer |

Measured on the side: a program can bind most receiver words today -- `int: merge 3`, `fn: table () int`,
`int: size_t 3` are accepted at the root and in a method; only `l2_ident`'s words (`fn int return if else while for
node`) are refused as names. The corpus binds three: `size_t: sub` (`unit_recursion`), `fn: until` (`unit_continue`,
`unit_while`), and `fn: receiveMessage` (`unit_next_message_method_first`, which asserts that "receiveMessage is a
receiver of the profile, not a reserved word: a declared method of that name takes precedence"). The resolver keeps
visibility first, so such a binding wins where it is visible, as today
([RESERVED-NAME-BINDINGS](defects.md#reserved-name-bindings)).

Equivalence: the S1 translator, replayed over the same 1998 translations, gives byte-identical L1 and messages and
the same allocation count in every row (the pieces are not called).

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_39` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_37` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_39` (full harness) | RED39/1999: against `opus_full_38` FAIL→OK 0, OK→FAIL 0, added 0, removed 0, red rows whose message changed 0. The one declared path (`l2trans.lm1`) was hashed before the run; both staged copies are its bytes. |
| Replay of `opus_full_38`'s 1998 recorded translations | The S1 translator: L1, exit and messages byte-identical in all 1998, allocation counts identical in all 1998. The cross-check build: L1 and messages identical in all 1998. |

<a id="unified-head-s2-s3"></a>
## 107. Statements and the free-name scan through the one resolution (K03-UNIFIED-HEAD S2+S3)

Slice S2+S3 of Codex's request K03-UNIFIED-HEAD-IMPLEMENT-20261006-01: the statement, scan, native and walker routes
read the written application and the one resolution of §106; real hidden inputs stay; the parallel atom and Frame
handling of one resolved contract collapses into one consumer; `break()`/`continue()` and the internal failures are
fixed in their common handlers and said at the occurrence.

The route. A statement whose head -- an atom's text or a Frame's head (`l2_app_head`) -- resolves at its site to a word
of the language (`l2_head_resolve`, kind word; `l2_stmt_word_head`, `l2_stmt_word`) is that word's application, its
written arguments the Frame's body or none (`l2_app_actuals`): `break` and `break()`, `merge` and `merge()` are one
application each.

- The check: one consumer, `l2_check_word_stmt`, meets the word's statement contract for both spellings and says it at
  the word -- `break`/`continue` (no argument, inside a loop), the trailer words (a stray trailer), a run-time `table`,
  `catch` (`l2_check_catch`), `throw` (`l2_check_throw`), `throws` (the first item of a method head), `fm` and
  `synchronized` (not supported yet), `merge`/`length`/`cast`/`sizeof` (with no operand the operator's own refusal;
  with operands a statement receives no value, a located limit), `return` with no value, `sendMessage`
  (`l2_msend_register`), `receiveMessage` (binds one or two names), `for`. A word whose written arguments the existing
  branches read -- a condition, a declaration, a letter, a return value -- goes on to them. In `l2_check_body` the
  atom-only branches (`break`, `continue`, `return`) and the Frame-only branches (`end`/`until`, `throws`, `throw`,
  `catch`, `table`, `break()`/`continue()`, `return()`) are gone.
- The native emission (`l2_emit_stmts`), the walker (`l2_rw_stmt_content`) and the root's source (`l2_src_one`) take
  `return`, `break` and `continue` with no written argument through `l2_stmt_word` -- one consumer for the bare word and
  its empty Frame. The four `return()` branches of `l2_emit_stmts` (publish, poll, empty return) repeated the atom's
  code and are gone. `catch`, `throw`, `sendMessage` and `receiveMessage` read their arguments through the view; a bare
  word has none.
- The scan (S2). `l2_scan_ident`: a word of the language the site does not bind is never a free input (`merge`,
  `table`, `catch` became "unbound dynamic input" at the call site). The resolver's order holds: a binding the site
  sees -- an own field, a formal, a unit field a method sees -- decides first, and Q52's hidden input stays.
  `l2_empty_struct_decl_shape`: `f()` declares a Structure named f only when f resolves to nothing, and a word never
  does (`break()` at the root declared a Structure named break; `merge()`, `fm()`, `length()` reached "internal: a
  source definition has no owning producer"). This test reads the word alone (`l2_head_word`), as the rest of the
  shape does: the row the statement would declare must not count (a resolver test there found that row, and the
  refusal of `break()` in a loop said nothing). `l2_head_absent` and `l2_local_ns_shape`: a word is no absent head.
- The call entry (correction 5: the duplicate folds as the phase moves). `l2_bind_call_in` binds through the view, a
  bare head as its empty application; in `l2_check_call` a formal that a bare head leaves without an argument is said
  by the one binding (`l2_bind_call`), as for `f()` -- "twice has no argument n" for `twice` as for `twice()`, where a
  second arity test said "incompatible entry signature". No third bare-call adapter.

The census after the slice (the S1 census script over these bytes): 761 sites (769). Statement dispatch 283 → 254
(`l2_check_body` 83 → 67, `l2_emit_stmts` 119 → 107, `l2_src_one` 21 → 19, `l2_rw_stmt_content` 28 → 29: one test names
the three words); contract 59 → 80 (`l2_check_word_stmt`: 21 comparisons of a word already resolved, the word's own
contract). The remaining statement sites dispatch Frames with written arguments (`if:`, `while:`, `return: v`,
declarations, letters, merge with operands); each reads a head that spells a word, which is the resolved word once no
program can bind a word ([RESERVED-NAME-BINDINGS](defects.md#reserved-name-bindings), the next slice); S6 proves them
site by site.

The matrices (translation only, scratchpad, no gate weight). Statement in a method, 23 heads (the receivers, the
trailer and statement words, two type words, a callable with a formal, a nullary callable, a named Structure): on the
S1 bytes the bare word and `H()` agreed in 6 of 23 -- the others said "unbound dynamic input merge" at the call site,
"unresolved name", "internal: a source definition has no owning producer", "root operation not walkable yet: this cast
contract", or accepted `sizeof()`; now in 23 of 23, each the word's own contract at the word. Statement at the root and
inside a loop, 10 heads each: 4 and 4 of 10 agreed (inside a loop `break()` was refused, "unsupported loop", and at the
root accepted; the bare `break` the other way round); now 10 and 10, `break`/`continue` accepted inside the loop and
refused at the root in both spellings. The positions that are not statements -- `x: H`, `w: H + 1`, `return: H`, an
actual `take(H)` -- keep their differences: S4.

The replay of `opus_full_38`'s 1998 recorded translations with these bytes: 1990 byte-identical (L1, exit, messages);
8 differ in the message alone, each a bare call or a held reapplication whose callee has a formal, "incompatible entry
signature" → "<callee> has no argument n" at the same line and column: `unit_factory_short_args_refused`,
`unit_held_call_reapplied_method_refused`, `unit_held_call_reapplied_refused`,
`unit_store_callable_over_formal_refused`, `unit_store_callable_over_local_refused`,
`unit_store_callable_over_number_refused`, `unit_value_tail_prefix_call_refused` and its `_walk` twin. Their needles
move with them. No corpus row changes its L1.

The witnesses: 13 new fixtures, 26 rows after the explicit-Frame controls. Refused at the word, natively and under
`--walk-methods`: the bare `merge` in a method, at the root and in a loop body; `merge()`; the prefix line `merge
Model` (two statements: the bare `merge`, refused by merge's own contract, and `Model`, which is no operand of it);
`break()` at the root ("unsupported loop"; it was accepted); `sizeof()`; `length()`; a bare `twice`; a bare `table`;
`fm()`. Run natively and walked (WalkRoot clears the root's native word; in the walked twins every method is walked --
only the entry keeps a native word in the `--walk-methods` L1): `unit_k03_nullary_stmt` -- `break`/`break()` and
`continue`/`continue()` inside loops, a callable called bare and as `tick()`, a named Structure run bare and as
`Model()`, `return`/`return()` in a sub (ticks 222, loops 12, entry 7); `unit_k03_hidden_input_q52` -- `s` and `s()`
leave the unit's y at 0 and `node\y` writes the unit's cell (correction 1).

The focused run on these bytes (`build/l2_harness/opus_focus_s23_01`): 71 targets, 0 failed -- the 26 new rows, the 8
rows whose message moved, the explicit-Frame controls, the catch/throw/throws rows (`unit_s1_*`), the receiveMessage
rows, `unit_recursion`, the continue rows, the held bare-name condition rows, the caller-binding rows, the run-time
table rows, `unit_void_return_abi` and `graph_shape_if_body`.

Not in this slice: the value, return and actual positions (S4: `x: sizeof` is accepted bare and refused as
`sizeof()`, `return: merge` says "unresolved name"), with the row that the reintroduced collector must turn red (a
receiving prefix `x: merge Model` and its walked twin); definition bodies (S5); the reserved-name validator and its four
migrations (RESERVED-NAME-BINDINGS, Codex K03-RESERVED-NAME-ANSWER-20261006-02), next. Until that slice a program's
binding of a word -- a local `size_t: sub`, a method `fn: until` -- is what the resolver finds where it is visible.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_40` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_38` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_40` (full harness) | RED39/2025: against `opus_full_39` FAIL→OK 0, OK→FAIL 0, added 26 (the witnesses, all OK), removed 0, red rows whose message changed 0. The 15 declared paths were hashed before the run; every staged copy is their bytes. |
| Replay of `opus_full_38`'s 1998 recorded translations | 1990 byte-identical; 8 messages moved, as above. |

<a id="reserved-name-bindings-slice"></a>
## 108. A word of the language binds nothing: one admission of every binding's name (RESERVED-NAME-BINDINGS)

Codex's answers K03-RESERVED-NAME-ANSWER-20261006-02 and -03 (parent K03-UNIFIED-HEAD-IMPLEMENT-20261006-01) to the
question of §106: no new language choice -- the author already decided that the receivers and operators of the
language are reserved and unshadowable, exactly like `if` (CORE.md :648-652, the dictionary :128 and :475, the plan
:1657); a method, a formal or any other binding of a program with a reserved name is invalid; there is no profile
exception (`receiveMessage` is a receiver, docs/LMX_semantics.en.md :1824); quoting escapes no reservation (grammar
§5). The fix is one admission of binding creation, said at the name. A name's reservation follows its defined contract,
never whether its lowering exists (-03). Visibility-first resolution stays for ordinary names; descriptive positions
stay legal (`catch: merge ()` names a failure; `fn: mytest ()` gives fn an ordinary name).

The defined set (`l2_head_word`, what the resolver calls a word), each group by its document:

| Group | Words | Source |
| --- | --- | --- |
| receivers heading a statement | sendMessage receiveMessage merge table catch throw throws until end sub fm synchronized length cast | `l2_receiver_word` (S1) |
| statement words, `node` | fn int return if else while for node break continue | S1 (`l2_ident`'s words and the loop controls) |
| operators | sizeof | S1 |
| receiving expressions | const immutable independent | docs §10 (`l2_declaration` reads all three as qualifier kinds) |
| receivers with a contract and no lowering yet | implements, test, post, external | docs §7 (implements; test adopted at :500), §28 :1489 ("post remains an ordinary protocol receiver"), L2 §18 :273 |
| machine types | char size_t int void unsigned ulong (lowered); short long float double signed `_Bool` (no by-value lowering) | `l2_ptr_type_word`; L2 §17 :187 (exactly their C99 meaning) |
| unit instructions | predef define include profile prototype os | L2 §18 :275, docs/L1_spec_en.md :172-174; `l2_unit_word`, one list that `l2_unit_role` now reads |

Not words, by their contracts: a named Structure, the C door, a name a predef or a header declares, a table alias
(`u8`, `Boolean`), an argument label (`source`, `ask`, `answer`, `default`). Recorded open classifications (no
document makes them a compiler receiver, and none is claimed shadowable either): `RuntimeImmutable` and `toLmx`
(operations in prose, docs :746 and :1142); `llong`, `ullong`, `uint`, `wchar_t` (named only by
`l2_unimpl_numeric`'s refusal); `ifdef` and the heads `C`, `L1`, `L2`, `L3` (the L1 profile, docs/L1_spec_en.md :174);
`_Complex` (never a type on its own).

The admission (`l2trans.lm1`):

- `l2_bind_admit(t, at, path)`: the one admission of a name a program binds. A plain identifier that is a word is
  refused at the name -- "<word> is a word of the language: a program cannot bind it" (`l2_bind_reserved`); an exact
  spelling (`` `merge` ``) is decoded first (`l2_exact_ident`) and refused the same way; an exact spelling of another
  name says "an exact identifier cannot name a binding yet" (bindings are keyed by their plain spelling: a located
  limit where "unsupported body" was said).
- `l2_bind_spelling(t)`: what a binding's shape reads in its name position -- any identifier, plain or exact -- so a
  word, a statement word (`int: if 3` failed `l2_ident` and was "unsupported body") and an exact spelling all reach the
  admission: `l2_declaration` (every declaration's name: own fields, pointer cells, formals, const and
  machine locals), `l2_fnptr_local`, `l2_struct_local`, `l2_receive_msg_shape` (the bound name; the model stays a reference),
  `l2_slot_decl_ty`, `l2_ns_arrarr_field`, `l2_take_ns_body` (ten field shapes), `l2_take_eternal`, `l2_typed_formal`
  (a callable formal), `l2_collect_method_body` (a method's name).
- The creations admit: `l2_own_add` and `l2_ml_add` (they tested `l2_ident`: "incompatible entry signature",
  "unsupported body"), a method's name, a formal (both forms), each of the twelve field registrations of
  `l2_take_ns_body`, a qualified branch's name. The slot branch of `l2_scan_body` takes none: it is dead -- `@: char x`
  and `@: size_t x` always have an own pointer code (`l2_own_decl_ty` is 1000 + 2 ft, never 0), so `l2_own_add`
  admits them; a marker build reached it in none of 2024 translations (left for S6). `l2_bind_at` finds the name's atom in the binding
  statement, so the refusal is said at the name.
- The words with no lowering get their own located contract as statements, never an accidental one: `test`, `post`,
  `external` "<word> is not supported yet" (beside fm and synchronized, `l2_check_word_stmt`); a unit instruction in a
  body "<word> is a unit instruction: it stands at the root of the unit"; `short`, `signed`, `_Bool` declarations
  "by-value <type> local not yet implemented" (beside float, double, long, `l2_unimpl_numeric`). Before, `test: 1`
  and `short: x 3` were accepted (an assignment and a named Structure `short`), bare `test` was "unbound dynamic input".
- The profile exception is gone: `l2_receive_msg_shape` and the walker no longer ask whether a method named
  receiveMessage exists.

The binding matrix (translation only; 12 kinds -- a field at the root, plain and quoted, a local in a method, plain,
quoted and `size_t`, a nested body's local, a reference local, a method, a sub, a formal, a named Structure's field,
the name receiveMessage binds -- by 39 words): on the S2+S3 bytes every word but `l2_ident`'s eight was accepted in
every kind (a method named sendMessage shadowed the receiver at its call site); now all 408 cells of the 34 words of
the matrix that are in the set say "<word> is a word of the language" at the name's line and column; the ordinary
names are accepted, and their exact spellings say the located limit.

The migrations (every program of the tree that bound a word; the replay of `opus_full_40`'s 2024 recorded translations
with the new translator differs in exactly 64 rows, each refused at its binding, nothing else changed):

| Fixture | Binding | Renamed to | Gate |
| --- | --- | --- | --- |
| 60 fixtures of the body-path, cache, call-argument, formal, occurrence, q24 and walk families ([manifest](k03-reserved-name-migrations.tsv)) | the method `test` | `mytest` (method, trailer, calls, paths `mytest\x`, the callable type of `test2 (mytest: f)`, comments) | GATED (60 rows) |
| `unit_recursion` | the local `size_t: sub` | `recursiveResult` | GATED |
| `dev/l2src_sandbox/parser_text_heap.lm2`, `parser_trailer_role.lm2` | the formal `size_t: length` | `textLength` (never the C field `result\length`) | GATED (RootSource) |
| `unit_next_message_method_first` | the method `receiveMessage` | refused at its name now; the program runs as `unit_next_message_method_ordinary` (method `nextValue`), native and walked | GATED |
| `unit_continue`, `unit_while` | the method `until` | `loopCondition` | UNGATED (no row names them) |
| `unit_paren_long` | the method `long` | `nestedSum` | UNGATED |

Two refusal needles moved two columns (`mytest` is longer, left of the refused place): `unit_occ_root_named` 18:13 →
18:15, `unit_own_last_occurrence` 28:20 → 28:22. The migrated programs keep their behavior: their translations with the
new translator, the new names read back as the old, equal the old translations byte for byte (the name's length in
`lmx_source_name_set` aside); the three library rows differ only in the unit hash of the evidence directory. The root
`l2src/` twins of the two parser ports keep `length` (the twin is read by no gate).

The witnesses: 27 new fixtures and 54 new rows after the K03 S2+S3 rows, the `unit_next_message_method_first` row now a
refusal. Refused at the name, natively and under `--walk-methods`: a field at the root (`merge`, `external`), a local
(`size_t`, `post`), a nested body's local (`break`), a method (`table`, `test`, `long`), a sub (`until`), a formal
(`merge`, `double`), a callable formal (`length`), a named Structure's field (`sub`, `include`), a char pointer cell
(`sizeof`), an imported function-pointer local (`merge`), a reference local (`cast`), a qualified branch (`merge`), the
name receiveMessage binds (`catch`), a local named `if`, and the exact spellings `` `merge` `` and `` `node` ``. Refused
at the word by their own contracts: bare `test` and `post` ("not supported yet"), `include: "stdio.h"` in a method
(the unit instruction). Run natively and walked (WalkRoot; methods 0-3 walked, the entry native until WalkRoot clears
it): `unit_rn_word_prefixed_names` -- merged, Holder's casting, tables, lengthy, untilDone, subtotal, testCount are
other names, bound and used; `unit_next_message_method_ordinary` (method 0 walked).

Mutants (each built from the patched bytes, the 26 witnesses translated; a witness is red when its first diagnostic is
no longer its needle):

| Mutant | Red witnesses |
| --- | --- |
| a word admitted like any name (`l2_bind_admit`'s two word tests) | 23 of 23 binding refusals (the three statement contracts stay) |
| the exact spelling not decoded | the two exact spellings |
| `l2_declaration`'s name read by `l2_ident` again | `if` and the two exact spellings |
| no admission in `l2_own_add` | 11: the root fields, the locals, the nested local, the pointer cell, the reference local, the receiveMessage name |
| no admission in `l2_ml_add` | the function-pointer local |
| no admission of a method's name | the methods `table`, `test`, `long`, the sub `until`, `unit_next_message_method_first` |
| no admission of a formal (both forms) | the formals `merge`, `double`, the callable formal `length` |
| no admission of a qualified branch's name | the branch `merge` |
| no admission of the twelve field registrations | none alone: a named Structure's field is admitted again as its procedure's own field (`l2_own_add`) |
| the twelve field registrations and `l2_own_add` | 13: the two fields with the eleven of `l2_own_add` |
| the set without implements, test, post, external, immutable, independent | the method `test`, the local `post`, the field `external`, the two statement contracts |
| the set without the C99 machine types | the method `long`, the formal `double` |
| the set without the unit instructions | the field `include`, the `include` statement |
| the statement contracts of the words with no lowering removed | the three statement contracts |

The unmutated control: 0 of 26 red. Focused runs on the patched bytes: `opus_focus_rn_02` 180 targets, 0 failed (the
witnesses, every migrated row, the K03 S2+S3 rows, the catch, implements, eternal and receiveMessage controls);
`opus_focus_rn_03` 58 targets, 0 failed (the witnesses after the function-pointer witness was added and the dead slot
edit removed).

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_41` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest). |
| `build/l3_selftest/opus_l3_39` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_41` (full harness) | Stopped by the low-memory reaper of Claude Code at 1344 logs (about 3.1 GB of 15.8 GB free on the machine); run again on the same 96 hashed paths as `build/l2_harness/opus_full_42`: RED39/2079, against `opus_full_40` FAIL→OK 0, OK→FAIL 0, added 54 (the witnesses and the ordinary-name program, all OK), removed 0, red rows whose message changed 0; the migrated rows stay OK. Every staged copy is the declared bytes. |
| Replay of `opus_full_40`'s 2024 recorded translations | 1960 byte-identical; 64 refused at the binding (60 `test`, 2 `length`, `sub`, `receiveMessage`); the migrated sources translate as before but for the renamed name. |

<a id="unified-head-s4"></a>
## 109. A word of the language in a value position: one contract for the bare word and its application (K03-UNIFIED-HEAD S4)

Codex's ticket K03-UNIFIED-HEAD-IMPLEMENT-20261006-01, slice S4 with the S6 work of the same positions: the receiving,
value, return and actual positions read the application view and the one resolution; a bare resolved head and its
empty application reach the same consumer wherever the contexts are equivalent; an ordinary name's reference or data
stays contextual. The author's rule (2026-10-06): a receiver is an instruction to the translator and a call is run
time, but their syntax is common -- the language has no exception for any name.

What reads the resolution now (`l2trans.lm1`):

- `l2_check_word_value(node, w, mi, path)`: the value contract of every word of the language, one consumer for the
  bare word and its Frame -- the written arguments are `l2_app_actuals` -- said at the word:

| Word | Applied to nothing (bare or `w()`) | With operands |
| --- | --- | --- |
| merge | "merge needs at least one operand" | "merge expression is not lowered in this receiving context" (merge's receiving limit: the callable-result and callable-formal contracts construct it before this check) |
| cast, sizeof, length | "unsupported cast", "sizeof: requires one operand", "length requires one known primitive own array" | the operator's branch |
| implements | "implements expects candidate, required, consumer" | its branch (`l2_check_implements`) |
| while, for, continue, break | "unsupported loop" | the same |
| if, else, return, fn, node | "unsupported body" | the same |
| fm, synchronized, test, post, external | "<word> is not supported yet", as in a statement | the same |
| a unit instruction | "<word> is a unit instruction: it stands at the root of the unit", as in a statement | the same |
| every other word (sendMessage, receiveMessage, table, catch, throw, throws, until, end, sub, the machine types, const, immutable, independent) | "<word> has no value" | the same |

- Its consumers: `l2_check_primary` -- an operand, an actual, a return value, a condition -- for the bare word (before
  the names and before `l2_ident`'s refusal of the statement words) and for the word's Frame (before the operators'
  branches, which take over with their operands; its merge-only branch is now the contract's);
  `l2_check_receiving_value` -- a value received by a declared name -- before the value is typed (it was "assignment
  value has unknown type", said at the statement); `l2_colon_simple_ty` -- sizeof and length applied to nothing have no
  type (they were size_t, and `return: length()` asked for the converter `lm_stg_convert_size_t_int`).
- A named Structure (the resolution's kind 5) in a value position. Its name is the Structure, a reference: a number
  place refuses it, "a reference where a number is asked", as the call's actuals already did (K04) -- an operand
  (`l2_native_leaf_ty` gives the kind rule's -5), one value given to a number place (a return value, an initializer:
  `l2_check_value_convert_field`), a received value (`l2_check_receiving_value`). Its application runs its body and
  gives no value, "a callable without a result has no value", as a sub's does -- an operand, an actual, a return value
  (`l2_check_primary`), a received value (`l2_check_receiving_value`). These were "root operation not walkable yet: a
  Structure value", "unknown method" and "assignment value has unknown type".
- A held callable called bare meets the one binding (`l2_bind_call`), which says which header formal it leaves
  without an argument, as for `h2()`: "h2 has no argument x" (it was "a held callable takes the arguments of its
  header").
- The comments that efbc2926 put on `l2_check_primary`'s callable branch and on `l2_check_value_call` are back to the
  c0e3fc5e text. They said that a callable formal of this method named bare is given as its occurrence (it runs:
  `l2_check_value_call`), that `m()` is checked there and that it reads `l2_app_actuals` (only a bare name reaches it;
  `m()` is the Frame branch's `l2_check_call`), and that the statement slices use it (none does). The translator's text
  is now c0e3fc5e's with this slice's patch and nothing else.

The census's S4 sites ([k03-head-census.tsv](k03-head-census.tsv), 54 and two S4+S6, line numbers of the S1 bytes):
nine of `l2_check_primary`'s fourteen -- the loop words, the body words and merge -- are gone into the contract; the
five left there (the address Frame `@`, cast, sizeof, implements, length) and those of `l2_check_receiving_value`
(sizeof, length) and `l2_colon_simple_ty` (sizeof, length, cast) are the operators' branches with operands, reached only
when the word's contract hands the application on (2) or, applied to nothing, typed as no value. The emission and
walker sites -- `l2_prep` (6), `l2_reference_source`, `l2_rw_operand` (6), `l2_rw_opty` (2), `l2_rw_source_node` -- run
on a program the check accepted, so they meet a word only as an operator with its operands (and the walker's located
limit for merge). merge in `l2_check_ret_convert`, `l2_check_call`, `l2_emit_call` (the two S4+S6 sites) and
`l2_rw_callable_actual` is the callable-result and callable-formal contracts' construction of merge, which comes before
the value check. The `[`, `]` and `@` of `l2_check_fields`, `l2_emit_fields` and `l2_scan_fields` and `node` in the
last are lexical, no head. Left for S6: `l2_rw_operand`'s refusal of a named Structure's name ("a Structure value")
looks unreachable now that the check refuses that name in a number place -- a probe in both modes decides between
deleting it and witnessing it.

The matrices (translation only; bare and `H()` with the final translator against the RESERVED-NAME-BINDINGS bytes): a
value received by a declared name 22 of 23 heads agree (21 before), a return value 22 of 23 (4), an actual 9 of 10
(3), an operand 9 of 10 (3). The one head left in each is a named Structure, whose two spellings are two contracts: its
name is a reference, its application has no value. The remaining differences of the head matrix (95 of 138 agree,
70 before) are `x: H` with x absent, at the root, in a method and in a nested body: a definition (Q58), slice S5 --
there the bare word still says its statement contract or "unsupported body", and `x: sizeof` and `x: size_t` are
accepted where `x: sizeof()` and `x: size_t()` are refused.

The witnesses: 21 refusal fixtures and two positive programs, 46 rows after the RESERVED-NAME-BINDINGS rows, each
refusal natively and under `--walk-methods` (the walked translation says the same as the native one in every row):

| Witness (method `m`, the refused place) | The committed translator (c0e3fc5e) | Now |
| --- | --- | --- |
| `return: merge` | unresolved name | merge needs at least one operand |
| `return: merge Model` -- the bare merge, Model no operand of it | unresolved name | merge needs at least one operand |
| `return: take(merge)` | unresolved name | merge needs at least one operand |
| `x: merge Model`, x absent -- the row the reintroduced collector turns red | merge needs at least one operand | the same |
| `return: merge()`, `return: take(merge())` | merge expression is not lowered in this receiving context | merge needs at least one operand |
| `w: merge(Model) + 1` | merge expression is not lowered in this receiving context | the same, by the contract |
| `w: sizeof()` | sizeof: requires one operand | the same, by the contract |
| `w: sizeof` | assignment value has unknown type (at the statement) | sizeof: requires one operand |
| `return: length()` | the program has no method `lm_stg_convert_size_t_int`, the receiver of this conversion | length requires one known primitive own array |
| `w: length + 1` | unresolved name | length requires one known primitive own array |
| `return: table` | unresolved name | table has no value |
| `return: post` | unresolved name | post is not supported yet |
| `if: post() = 1` | unknown method | post is not supported yet |
| `w: include` | assignment value has unknown type (at the statement) | include is a unit instruction: it stands at the root of the unit |
| `w: implements` | assignment value has unknown type (at the statement) | implements expects candidate, required, consumer |
| `return: Model`, `w: Model + 1` | root operation not walkable yet: a Structure value | a reference where a number is asked |
| `w: Model` | assignment value has unknown type (at the statement) | a reference where a number is asked |
| `w: Model()` | assignment value has unknown type (at the statement) | a callable without a result has no value |
| `w: Model() + 1` | unknown method | a callable without a result has no value |

The positive controls, natively and walked (methods 0-4 walked): `unit_k03_nullary_value` -- a callable called bare
and as `tick()` is one application as an operand, an actual of a number formal and a return value (w is 3, 6, 8, 10,
14 and tick runs six times); `unit_k03_data_value` -- names that hold data, a local, a formal and an own field, are
read as data as an operand, an actual, a return value, a received value and in a condition, and a named Structure's
name where a reference is asked, a formal of its type and merge's operand, is the Structure itself (w is 30, r is 5,
`Model\value` stays 7). Two rows moved their needle to the new contract: `unit_held_call_bare_name_args_refused`
13:4 "h2 has no argument x", and `unit_merge_atom_assign_refused` (`w: merge: Model` received by a declared int: merge's
receiving limit, now said at the merge) 10:5 "assignment value has unknown type" -> 10:8 "merge expression is not
lowered in this receiving context"; its comment says so, its line count kept.

Mutants (each removes one rule whole, built from the final bytes, one gcc at a time; the 256 rows of the focused run
`opus_focus_s4_03` replayed with it; a refusal row is red when its first diagnostic is no longer its needle, a
translating row when it refuses; no mutant changed the L1 of a translating row, so none had to be run):

| Mutant | Red rows (beyond the three red without it) |
| --- | --- |
| the collector of the atom spelling reintroduced (`l2_merge_atom_settle`, called by `l2_merge_frame`) | `unit_k03_prefix_merge_recv_refused` and its walked twin: `x: merge Model` is accepted as `x: merge: Model` |
| `l2_check_primary`: a bare word is no application | 12: `return: merge`, `return: merge Model`, `return: take(merge)`, `w: length + 1`, `return: table`, `return: post`, each native and walked -- "unresolved name" |
| `l2_check_primary`: a word's Frame does not meet the contract | 8: `return: merge()`, `return: take(merge())`, `w: merge(Model) + 1`, `if: post() = 1` -- "unknown method" |
| `l2_check_receiving_value`: a received word typed before its contract | 9: `w: sizeof`, `w: sizeof()`, `w: include`, `w: implements` (native and walked), `unit_merge_atom_assign_refused` -- "assignment value has unknown type" |
| `l2_colon_simple_ty`: sizeof and length applied to nothing typed | `return: length()` (2) -- the missing converter |
| the receivers with no lowering, the unit instructions, out of the contract | `return: post`, `if: post() = 1` (4); `w: include` (2) -- "<word> has no value" |
| implements applied to nothing goes on to be typed; implements with operands refused | `w: implements` (2); the seven positive `unit_implements_*` rows |
| a named Structure: the operand, one value to a number place, the received name, the received application, the application in `l2_check_primary` | 2 each: `w: Model + 1`, `return: Model`, `w: Model`, `w: Model()`, `w: Model() + 1` |
| the bare held callable without the one binding | `unit_held_call_bare_name_args_refused` |
| the control (one comment changed) | none |

Two commits of another session came in between c0e3fc5e and this slice: cd6aa536 and efbc2926, made in the main
checkout by the relay session under a slice ID Codex never issued, with no gate (Codex, K03-S4-CLEANUP-S5-20261007-01:
not authorized). cd6aa536 added `unit_recv_prefix_merge_model.lm2` with a native and a walked row, and
`steps/k03-s4-implementation-spec.md`. The program is not valid -- it binds `test` (a word of the language, §108) and
writes `Model: int` then `Model: 42` -- and has no `x: merge Model` line, so no collector can reach it: it was refused
at 11:15 "unknown merge operand" and both rows were red. The spec named Opus its owner and listed a callable formal's
occurrence in a value position as a positive control, which the code does not do (it runs the formal); efbc2926 put
the same claim into the two comments restored above. By Codex's decision the program, its rows and the spec are
removed in this slice: `unit_k03_prefix_merge_recv_refused` and its walked twin, which the reintroduced collector turns
red, and the two positive controls carry the coverage the program claimed.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_42` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest); the staged `l2trans.lm1` is the declared bytes. |
| `build/l3_selftest/opus_l3_40` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_46` (full harness, the cleaned bytes) | RED39/2125: against `opus_full_42` FAIL→OK 0, OK→FAIL 0, added 46 (all OK), removed 0, red rows whose message changed 0; against `opus_full_45` (this slice before the cleanup, RED41/2127) exactly the two rows of cd6aa536 removed, every other target's verdict and message the same but for two identifiers that change in every run: the translator's sha256 (its PE build stamp; the two executables are equal with TimeDateStamp and CheckSum masked) and the unit hash of the two library rows (derived from the evidence directory of each run). The kernel and L3 gates read no fixture and no row, and the cleanup changed no `.lm1`. `opus_full_43` was stopped at its start to add the data control; `opus_full_44` was stopped by the low-memory reaper of Claude Code at 5020 logs and run again on the same 26 hashed paths as `opus_full_45`. Every staged copy is the declared bytes; the removed program is absent. |
| Replay of `opus_full_42`'s 2078 recorded translations | 2076 byte-identical (L1 included); 2 refusals moved to their new contract (`unit_held_call_bare_name_args_refused`, `unit_merge_atom_assign_refused`). |

<a id="unified-head-s5"></a>
## 110. A definition retains its tail: a word there is an item of the body under its statement contract (K03-UNIFIED-HEAD S5)

Codex's ticket K03-UNIFIED-HEAD-S5-20261007-02 (a child of K03-UNIFIED-HEAD-IMPLEMENT-20261006-01) and its answer
K03-S5-DEFINITION-TAIL-20261007-03: in every scope a known word bare in a definition tail and its empty application meet
the same contract and the same located error; a known word never becomes an unknown dynamic input or a dormant
same-named definition because of its spelling; an unknown head keeps its Structure construction; a known callable stays
in the retained dormant body in source order. The answer chose the first reading: with x absent, `x: sendMessage:
exit(...)` defines x with the written sendMessage application in its body -- defining x sends nothing, an explicit
execution of x reaches that operator. The role inference that made a receiver's application the outer name's value
(`l2_receiver_value`) and its duplicate classifiers go through the application, resolution and consumption route; the
receiving construction stays where its resolved contract defines it (#construction :703, `b: merge: A C`), downstream of
the common resolution; no whitelist, no new syntax kind, no parser flag, no declaration-time execution.

What reads the resolution now (`l2trans.lm1`):

- `l2_merge_construction(fr)` replaces `l2_receiver_value`: 1 only when the tail's first item is merge's application,
  the atom or its Frame (`l2_app_head`), the word read by the defined set (`l2_head_word`). Its readers: `l2_unit_role`
  and `l2_local_ns_shape` (the construction is the statement, not a definition), `l2_tail_is_structure` (it is the
  head's value) and `l2_ns_decl_first` (it declares no field). The check refuses merge's construction with no operand
  at the merge, whatever the outer name: `x: merge`, `x: merge()` and `x: merge Model` say "merge needs at least one
  operand" (`x: merge()` said it at x).
- Any other word's application in the tail of an absent head -- bare, applied to nothing or to names -- is an item of
  the retained body under its ordinary statement contract (`l2_check_word_stmt`, S2): a word is never retained content
  (`l2_retained_atom`), never an identifier of an identifier-only tail (`l2_ident_only_tail`), never the one value of
  the tail (`l2_tail_is_structure`, whose clause "a receiver's call stays the head's value" was `l2_receiver_value`'s
  twin), and heads no reference field (`l2_ns_decl_first`: `catch: e` in a body is catch's application, not a field e
  of a type named catch -- refused in the second phase, "unknown nested Structure reference", at the unit or at 1:1).
- A field word applied to nothing -- `size_t`, `int`, `unsigned`, `ulong`, `char`, `fn`, `[]`, `()`, bare or empty --
  is that field's declaration and says what it lacks at the word (`l2_ns_field_needs`; the set `l2_ns_field_word` is
  the one `l2_ns_decl_first` and `l2_take_ns_body` read).
- In the procedure of a method's own named Structure a name the method sees is no new definition: the nested head,
  the empty declaration shape and the local Structure shape resolve at the host method's site (`l2_ns_host_of`,
  `l2_head_resolve`; `l2_ns_take_mi` while `l2_take_ns_body` reads such a body). `x: j()` with j the method's int was
  a nested Structure j.
- A unit item is read by its application (`l2_unit_role`, the directives of `l2_translate_unit`): `include`, `fn`,
  `sub`, `os` and `independent` written bare are the directive, the method header, the os block and the qualified
  branch with no argument, and their contracts say what is missing: "unsupported argument", "incompatible entry
  signature", "unsupported body", "independent takes one qualified construction" (they were told they stand at the
  root of the unit where they stood, or "unsupported body").
- receiveMessage declares the name it binds by its own contract (`l2_receive_msg_shape`) in `l2_unit_declares`, one
  name or two: after `receiveMessage: got Model`, `got()` is got's call (it was a new empty Structure got); the
  one-name form was declared only through its likeness to `Model: name`, which no word has any more.
- A located limit: a named Structure's procedure lays its top-level declarations out as the Structure's fields
  (`l2_own_mslot`), and the name receiveMessage binds there has none: "receiveMessage in the body of a named Structure
  is not supported yet", at the statement (it was a field of a type named receiveMessage; with the statement reading
  alone it reached the layout, "internal: an own declaration has no physical field"). In a block of the body it has
  the block's place, as before.
- The spelling lists that stood for the resolution are gone: `l2_is_asgn` (16 words -> `l2_head_word`; `@` is no
  identifier), `l2_unit_role` (const, immutable, merge, end: `l2_head_absent` below), `l2_local_ns_shape` (fn by
  `l2_ident` above, const, immutable, independent and the receiver words by `l2_head_word` below), `l2_ns_body_stmt`
  (the control words by `l2_ns_decl_first`, a bare `return` -- any item that is no Frame -- by its caller),
  `l2_unit_declares` (the control words -> `l2_head_word`), `l2_head_absent` (the receiver words are words).
  `l2_receiver_word` is read only inside `l2_head_word` now.

The census's S5 sites ([k03-head-census.tsv](k03-head-census.tsv), 148 in 27 functions, line numbers of the S1 bytes):

| Function (sites) | Disposition |
| --- | --- |
| `l2_is_asgn` (16) | the resolution: a word heads no assignment (`l2_head_word`); `@` is no identifier (`l2_ident`, above it) |
| `l2_unit_role` (13) | fn, sub, independent, os and the five unit instructions (9): the item's contract chosen by its application, bare as empty; const, immutable, merge, end (4): removed, a word resolves (`l2_head_absent`) |
| `l2_unimpl_numeric` (15) | kept and recorded: the language numeric types with no owned domain are refused by name; whether i8-i64, u8-u64, uint, llong, ullong and wchar_t are words of the language (float, double and long are) is not decided by the documents -- an unresolved classification, a recorded dependency |
| `l2_collect_decls` (14), `l2_collect_asgn_body` (13) | kept: the control words' contracts -- the bodies of catch, if/else, while and for are scopes the collectors enter, `[]` declares an own array -- read from the word's Frame once the statement route has resolved it; a bare control word has no body and meets its statement contract |
| `l2_take_ns_body` (10), `l2_ns_arrarr_field` (4) | kept: the field words' declaration shapes; applied to nothing they say what they lack at the word |
| `l2_ns_decl_first` (8) | moved into `l2_ns_field_word`, the set it shares with `l2_take_ns_body`; no other word heads a declaration |
| `l2_ns_body_stmt` (6) | removed: a word's Frame is a statement because it declares nothing; a bare `return` is a statement at the caller |
| `l2_unit_declares` (5) | the resolution: a word's application declares no name (`l2_head_word`); receiveMessage's binding by its contract |
| `l2_local_ns_shape` (5) | fn, const, immutable, independent (4) removed; the trailer's spelling `end` (1) kept, a boundary |
| `l2_collect_method_body` (5) | kept: the method header and its close (`fn`/`sub`, `return`/`end` trailers); a bare `fn`/`sub` meets the header's count |
| `l2_translate_unit` (4) | the directives taken by the item's application; bare, their takers refuse the missing argument |
| `l2_take_eternal` (4) | kept: the qualified branch (`independent`'s one construction, `const`/`immutable`, `()`); a bare `independent` has none |
| `l2_declaration` (4), `l2_contract_type` (4), `l2_emit_loc_stmt` (1) | kept: the declaration model's qualifiers and array word, and their emission |
| `l2_slot_decl_ty` (3), `l2_receiver_frame` (1) | kept: lexical -- a slot's type words, the address of `@: t f(a)` |
| `l2_unit_names_method`, `l2_bind_node`, `l2_bind_node_content`, `l2_fn_defined`, `l2_unit_defined_fn` (2 each), `l2_bind_same_unit_forward` (1) | kept: the method definition's header word |
| `l2_retained_atom` (1), `l2_ident_only_tail` (1) | removed: `return` was the one word they named; no word is content or an identifier of a tail |

In all: 37 sites removed into the resolution, 8 moved into the field words' set, 13 read from the application, 75
kept as the contracts that follow resolution, 15 kept as recorded unresolved classifications.

The matrices (translation only; bare and `H()` with the final translator against 4a8e1d8d's; `x` absent):

| Matrix | Agree before | Agree now | What differs, by resolved contract |
| --- | --- | --- | --- |
| `x: H` at the root, in a method and in a block (34 heads) | 39 of 102 | 99 of 102 | j, a local int, at each: bare it is the datum (a definition holding it), `j()` applies a number |
| a unit item `H` (40 heads) | 29 of 40 | 38 of 40 | j as above; Foo unknown: bare an unresolved name, `Foo()` the empty Structure's declaration |
| `x: W: j` at the root, in a method and in a block against the statement `W: j` (36 words) | 3 of 36 | 27 of 36 | merge: the definition is merge's construction (`unknown merge operand` at j); until, end: P0's trailers; fn, int, size_t, char: field declarations in x; return: x's procedure has no result; receiveMessage: the limit |
| `x: H` in a named Structure's body, at the root and in a method (34 heads, bare against `H()`) | 6 of 68 | 58 of 68 | tick, twice, Model, j, Foo bare: the field shape `Type: name` (Q57: one atom is a field of that type), recorded below |

Every word and every known callable in the first two now meets one contract written bare and applied to nothing. The
word's refusal is said at the word in all four (the field words' said at x before).

The witnesses: 27 refusal programs and 5 positive programs, 64 rows after the S4 block, each refusal natively and
under `--walk-methods` (the walked translation says the same as the native one in every row); every refusal row is
red against 4a8e1d8d's translator:

| Witness (the refused place) | 4a8e1d8d | Now |
| --- | --- | --- |
| root `x: catch()`, method `x: sendMessage()`, block `x: throw()`, root `x: receiveMessage()` | "<word> has no value" | catch's, sendMessage's ("this sendMessage"), throw's and receiveMessage's statement contracts, at the word |
| root `x: sizeof`, method `x: include`, block `x: predef`, method `x: size_t`, root `x: break` | accepted | "sizeof: requires one operand", the unit instruction's refusal, "a named Structure field needs a name", "unsupported loop" |
| method `x: fn()`, block `x: merge()` | said at x | "a callable field needs a method name", "merge needs at least one operand", at the word |
| root `x: break: j`, method `x: catch: j`, block `x: continue: j`, method `x: include: j` | a field j of a type named by the word, "unknown nested Structure reference" at 8:1 or 1:1; catch "has no value" | the word's statement contract at the word |
| named Structure body: `x: catch`, `x: merge` (in a method's), `x: merge()`, `x: throw()` (in a method's), `break: k` | "catch/merge is a word of the language: a program cannot bind it", "internal: an own declaration has no physical field", "throw has no value", a field k of a type named break | catch's contract, "merge needs at least one operand", throw's contract, "break takes no argument", at the word |
| unit items `include`, `fn`, `independent` | "include is a unit instruction: it stands at the root of the unit", "unsupported body" | "unsupported argument", "incompatible entry signature", "independent takes one qualified construction" |
| method `x: j()`, j its int | accepted (a nested Structure j) | "assignment target must be a declared typed mutable value" |
| root `x: size_t` above a Structure x the unit declares below | "size_t has no value": the word read as an identifier, the line a use of the x below | "a named Structure field needs a name": a word is no name, the line defines x by source order as every other tail does |
| `receiveMessage: got Model`, then `got()` | accepted (a new empty Structure got) | "executing a named Structure is not supported yet", as for the one-name letter (`unit_letter_call_refused`) |
| root `x: receiveMessage: msg` -- the limit | "unresolved name" | "receiveMessage in the body of a named Structure is not supported yet" |

The positive controls, natively and walked (every method walked but the root's native word): `unit_k03_def_send_body`,
`unit_k03_def_send_root` and `unit_k03_def_send_block` -- s, absent, retains `sendMessage: exit(exit_code: count(); ...)`
in a method, at the root and in a block: the definition sends nothing (exit 4 if it did), three ticks run, s() sends in
source order and count() is read then, exit 7 (81 if s() sent nothing); 4a8e1d8d refused each, "sendMessage has no
value". `unit_k03_ns_send_body`: x, absent in the body of Outer, retains `sendMessage: exit(exit_code: 4; ...)` as a
nested Structure, and `Outer()` runs none of it: exit 7 (4a8e1d8d: "sendMessage has no value"). `unit_k03_def_callable_body` (Q58, green before too): `b: tick` and `c: tick()` run nothing at their
definitions and once each when b and c run. The driver checks the exit: the same artifacts run with 4 or 81 expected
fail.

Mutants (each removes one rule whole or restores the classifier it replaced, built from the final bytes, one gcc at a
time; the 32 witness programs translated natively and under `--walk-methods`, and the 2124 recorded translations of
`opus_full_46` replayed; a refusal row is red when its first diagnostic is no longer its needle, a positive row when
it is refused):

| Mutant | Red rows |
| --- | --- |
| `l2_merge_construction` back to `l2_receiver_value` (a receiver's Frame gives the outer name a result) | 22: catch/sendMessage/throw/receiveMessage applied to nothing ("<word> has no value"), `x: catch: j`, the limit, `unit_k03_ns_throw_app_refused`, and the four positives refused ("sendMessage has no value") |
| `l2_retained_atom`: a bare word is content again (only `return` and the receiver words excluded) | 12: bare sizeof, include, predef, size_t, break, and `x: size_t` above a Structure x (accepted or another contract) |
| `l2_ident_only_tail`: a bare word an identifier of a tail again | 2: `x: size_t` above a Structure x, "size_t has no value" (the line read as a use of the x below) |
| merge's construction with no operand unrefused | 4: block `x: merge()`, body `x: merge()` |
| a field word applied to nothing unrefused at the word | 6: `x: size_t`, `x: fn()`, `x: size_t` above a Structure x |
| the nested head of a method's own named Structure, the empty declaration shape, the local Structure shape -- each without the host's resolution (three mutants) | 2 each: method `x: j()` |
| unit items by the Frame alone | 6: unit items `include`, `fn`, `independent` |
| `fn` written bare no longer the header with no field | 2: unit item `fn` |
| `independent` written bare no longer the branch with no construction | 2: unit item `independent` |
| a word heads a reference field again (`l2_ns_decl_first`) | 12: `x: break: j`, `x: catch: j`, `x: continue: j`, `x: include: j`, the limit (a field of a type named receiveMessage), `break: k` in a body |
| a bare word the one value of a tail (`l2_tail_is_structure`) | 2: `x: catch` in a body (a field named catch again) |
| `l2_tail_is_structure`'s receiver clause restored | 2: `unit_k03_ns_send_body` -- the line becomes a statement of Outer's procedure, "internal: an own declaration has no physical field"; every refusal witness stays green (that route refuses the same way) |
| merge's construction a field in a body again | 2: `x: merge` in a body ("merge is a word of the language: a program cannot bind it") |
| the receiveMessage limit removed | 2: the limit ("internal: an own declaration has no physical field") |
| `l2_unit_declares` without receiveMessage's contract | 2: `got()` after the two-name form (accepted), and the corpus row `unit_letter_call_refused` |
| every spelling list the resolution replaced, restored at once | none: the lists were the resolution's duplicates for every reached input |
| the control (unchanged bytes) | none |

No mutant changed the L1 of a translating corpus row (the replay of the 2124 translations is byte-identical to
4a8e1d8d's for every mutant but `l2_unit_declares`'s, whose one changed row is the refusal named above).

Two debts of this checkpoint, ruled by Codex (K03-S5-NS-ROLES-20261007-04) and taken next, each its own bounded
checkpoint in this lane before S6 (next_core_tasks_v2.md, K03):

- K03-S5-NS-ROLES. In a named Structure's body a one-atom tail that is no word -- `x: tick`, `x: j`, `x: Model`,
  `x: Foo`, x absent -- is still the shape `Type: name`, a field x of a type named by the head, refused in the second
  phase when no Structure has that name; at the root and in a method the same line defines x. Codex: a body is not a
  signature -- the same ordinary role resolution applies there ([docs](../docs/LMX_semantics.en.md#resolved-head-consumption):
  an existing ordinary named Structure takes no arguments, an unknown head constructs, for absent b `b: A` and
  `@: b A` introduce b; next_core_tasks_dictionary_v2.md §3: the `Model: fresh` and named-model shortcut recognizers
  cannot stay beside the new classifier). The culprit is `l2_ns_decl_first`'s last one-atom branch (`l2_ident(head)`,
  `l2_ident(tail)`) with its second-phase consumers: census the registrations that depend on it, compare root,
  method, named and anonymous bodies (later names included), and remove that role decision through the common route.
- K03-S5-RECEIVE-OUTPUT. The limit above is a temporary implementation limit, not a rule of the language. The name
  receiveMessage binds is a computed output (LMX_blog/q/q53.md:95-97: `receiveMessage: m` is like `int: i getValue()`,
  not `int: i 5` -- no data reachable as `struct\m`): it takes the ordinary computed-output binding and storage
  (`l2_own_output_add`, `l2_receiver_output_place`) and `l2_own_mslot` stops assuming that every top-level name of a
  named Structure's procedure has a public field slot -- never a synthetic data field.

Recorded, not changed here:

- The second phase says "unknown nested Structure reference" and "unknown callable field" at the unit's node (1:1, or
  the item that opened the pass) for a Structure that is no part's root; a part's is said at the field
  (`unit_s7_part_root_type_refused_part` 4:8).
- `l2_tail_is_structure` keeps the C door's Frame the head's value in a named Structure's body (a known callable);
  at the root and in a method the tail is retained.
- `x: j()` with j a method's int says "assignment target must be a declared typed mutable value" in a method and in a
  block (the procedure's check of the host's name), "unsupported body" at the root, as the statement `j()` does in a
  method.
- A number field written with its name and no literal (`x: int: j`) is told "a named Structure field needs a name".

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_43` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest); the staged `l2trans.lm1` is the declared bytes. |
| `build/l3_selftest/opus_l3_41` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_47` (full harness) | RED39/2189: against `opus_full_46` FAIL→OK 0, OK→FAIL 0, added 64 (all OK: the 64 rows of this slice), removed 0, and no target's verdict or message changed but two identifiers that change in every run (the translator's sha256 and the unit hash of the two library rows). The 34 declared paths were hashed before the run; every staged copy is the declared bytes. |
| Focused runs on the same bytes | `opus_focus_s5_01` 71 targets and `opus_focus_s5_02` 82 targets, 0 failed (the slice rows, the S4 controls, Q58 and retained-body rows, `unit_letter_call_refused`). |
| Replay of `opus_full_46`'s 2124 recorded translations | 2124 byte-identical (L1, exit, messages). |

<a id="ns-roles-3"></a>
## 111. The old `Model: m` declaration leaves the root and methods; a named Structure is visible both ways (K03 NS-ROLES-3)

Codex's answers under K03-S5-DEBTS-20261007-05 (children of K03-UNIFIED-HEAD-IMPLEMENT-20261006-01):
K03-S5-MIGRATION-20261007-06 (a) -- migrate each legacy `Model: m` whose intent is a fresh independent instance to the
written construction `m: merge: Model`, preserving the copy, the reference relocation, the lexical parent, the source
order and the observed behavior, tracking each classified path; K03-S5-ALIAS-VISIBILITY-20261007-07 Q2 -- a direct named
callable definition is visible throughout its lexical unit or block in both directions, by the general visibility of
callables (docs/LMX_semantics.en.md:768, a named Structure is a callable procedure; :937, a callable is visible
throughout its block in both directions), for the root too, while ordinary data and receiver outputs keep forward
visibility and a sibling block is not covered; K03-S5-VISIBILITY-GUARD-20261007-08 -- `Model: fresh` above `Model:`
becomes Model's source-located call refusal, never an acceptance through the old declaration, and the forward branch
read becomes a positive observed in both execution paths. The removal comes first in the NS-ROLES lane for that reason:
the visibility alone would have accepted that line through the old declaration.

What changed in `l2trans.lm1`:

- `l2_colon_decl_shape` is read only for a named Structure body's reference field (`l2_take_ns_body`'s kind 3, the new
  `l2_ns_ref_field_stmt`): the one remaining dependent route, isolated until NS-ROLES-2 migrates and removes it. At the
  root and in a method `Model: m` with Model existing is Model's call: "more arguments than Model has formals", where
  it stands (docs :668: an ordinary named Structure takes no argument; an unknown m is neither declared nor cloned).
- `l2_unit_declares` no longer reads `Model: name` as a declaration of name at the unit (that clause also took `x: Foo`
  for a field Foo typed by x, so a definition of Foo below it was no definition).
- `l2_ns_find`: a named Structure defined at the unit (parent < 0 -- a root definition, a qualified branch's root) is
  visible from every method and every statement of the unit, above it too; a nested Structure keeps its place's
  visibility, and a program part's code sees none (`l2_vis_ok`).
- A signature may name a Structure the unit defines below its method: `l2_contract_formal` takes one the source
  defines (`l2_unit_defines_struct`, read from the source as `l2_unit_names_method` reads a method, before
  registration), and `l2_sig_models_refresh` reads each formal's and result's model again once every named Structure
  of the unit is registered -- the same reading (`l2_ref_formal_ns`, `l2_contract_model`), not another.
- The root's forward rule (`l2_struct_defined_below`: an identifier tail above a later Structure definition of its
  head) stays: it is the both-way rule at the unit role -- the line is that Structure's application, a statement --
  and its consequence is now the call refusal, no longer the declaration.
- The typed binding `T: b c` (the pending family) reads its candidate by its schema, as a call's actual is read
  (`l2_own_schema`, -1 none): a merge result is a Structure value, so the migrated `c: merge: Model` keeps the
  binding's admission. The binding itself is untouched (LMX_blog/q/current/model-constrained-null-reference.md).

The migration (`steps/k03-colondecl-migration.tsv`): every item the recorded translations of `opus_full_47` reached
through `l2_colon_decl_shape` at the root (80) and in a method (31) -- 111 items in 92 programs -- rewritten in place as
`m: merge: Model` (same line, same indentation). Their intent is a fresh instance, the old declaration's copy of the
model; the explicit merge is that copy. The 16 items in named Structure bodies (12 programs) are NS-ROLES-2's. Six
headers that quoted the old line were reworded, line counts kept.

Evidence of the migration:

- The replay of the 2188 recorded translations of `opus_full_47` with the final translator over the migrated sources,
  against the committed translator over the old ones: 3 rows change their message -- exactly the visibility rows below
  -- and 64 rows of the migrated programs keep their verdict and message while their L1 differs (the construction is
  now the merge); no other row changes. Before the candidate reading, 4 typed-binding rows changed (the binding refused
  a merge result: "a typed binding's candidate is not a Structure value"); with it, none.
- The rows of the 125 programs touched (the migrated ones, the body programs whose old route is isolated, the S2 rows,
  the witnesses), natively and walked: green but for three rows already red in `opus_full_47` with the same message
  (`unit_arr_path_inner_value_refused`, `unit_arr_path_three_refused`, `unit_eternal_shape`).
- Three rows pinned the path of a Structure formal that receives a value exactly of its model:
  `unit_a3_capture_direct_vs_copy` (the capture registered as itself), its walked twin (the CALL/ADMIT_AS shapes) and
  `unit_walk_struct_formal` (OF(ARG j, slot)). With the actual now a merge result, the formal is admitted by name
  (`lmx_implements_slot` through the admission's record) and each program still exits 7 natively and walked (run). The
  migrated rows keep their run and walk checks -- the A3 row now pins the by-name read -- and the exact path's pins moved
  unchanged to `_exact` twins that pass the named Structure itself (in the walked A3 twin the actual's shape is AT/3,
  the named Structure, where it was the own field OWN/2).
- `unit_s1_merge_uncaught_entry` (`translates-with-debt`, the walker's merge primitive whose failure the driver's tap
  did not reach): E's merge is now the written construction, the native merge the tap fails -- the implicit throw
  reaches the root (Thrown 1), the entry has no value, R0 stops; the row runs (`eternal-runs`, controls: Thrown 2 and
  Stopped 0 each fail). No recorded translation reaches the walker's merge primitive (`lmx_walk_merge_model`) any more
  (61 rows before): its emission is reached by no row until NS-ROLES-2 removes the old route.

The S2 visibility rows (FABLE-OPUS-S2-UNIT-IS-ENTRY took a named Structure and a qualified branch for non-callables):
`unit_s2_vis_structure_below_refused` -- `Model: fresh` above `Model:` -- is Model's call, "3:1: more arguments than
Model has formals" (it said "unresolved name"); `unit_s2_vis_signature_refused` and `unit_s2_vis_branch_refused` are
replaced by `unit_s2_vis_signature_below` (a signature naming Point defined below: take reads the formal's field, 7)
and `unit_s2_vis_branch_below` (a method above a qualified branch reads `cfg\e`, 7), natively and walked;
`unit_s2_vis_dynamic` (a unit int below a method is its dynamic input) is unchanged. The pending typed-binding row
`unit_root_struct_call2_forward_refused` (`Model: Other extra` above `Other:`) is now Model's call with two arguments,
"11:1: more arguments than Model has formals" (it was "a typed binding's candidate is not a Structure value").

Witnesses, natively and under `--walk-methods` (16 rows): `unit_k03_cd_root_call_refused`, `_method_`, `_block_`
(`Model: fresh` with Model existing: Model's call, at the line); `unit_k03_vis_later_struct_method` (a method above
Later reads and writes `Later\v`: 4, then 6) and `unit_k03_vis_later_struct_root` (a root statement above Later reads
it); `unit_k03_vis_unit_declares_tail` (`x: Foo` above `Foo:` keeps Foo a definition; m reads `Foo\v`);
`unit_k03_vis_later_data_refused` (an int read above its declaration: "unresolved name" -- data stays forward);
`unit_k03_vis_nested_sibling_refused` (a nested Structure is no name of the unit: `Inner\v` refused, `Outer\Inner\v`
is the path).

Mutants (each removes one rule whole, built from the final bytes one gcc at a time; the witnesses translated natively
and walked, the recorded translations replayed over the migrated sources):

| Mutant | Red |
| --- | --- |
| m01 the old declaration read everywhere again | the three `unit_k03_cd_*` (accepted: "root operation not walkable yet: a Structure-typed field in a method"), and the corpus row `unit_s2_vis_structure_below_refused` |
| m02 `Model: name` declares name at the unit again | `unit_k03_vis_unit_declares_tail` ("unsupported trailer" at Foo's definition) |
| m03 a unit-level Structure visible only below it | the two `later_struct` witnesses, `unit_s2_vis_branch_below`, and three corpus rows |
| m04 the typed binding's candidate by its named type only | the corpus rows `unit_bind_root_ref`, `unit_bind_root_thin_other` (positive) and two refusals' messages |
| m05 a signature's type not taken from the source | `unit_s2_vis_signature_below` ("unknown type") |
| m06 the signature's models not read again | `unit_s2_vis_signature_below` ("unknown field path root") |
| m07 the old shape read nowhere, the body's isolated route too | four corpus rows of the body programs (NS-ROLES-2's) |
| m00 control | none |

Recorded, not changed here: a frame with a tail that is not an identifier written above a later definition of its
head (`Later: 3` above `Later:`) is still classified by source order at the root; a method's own named Structure is
still visible only after its definition (both kinds belong to NS-ROLES-1's both-way rule for every block); the walker's
merge primitive keeps its emission code until NS-ROLES-2.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_44` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest); the staged `l2trans.lm1` is the declared bytes. |
| `build/l3_selftest/opus_l3_42` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_48` (full harness) | RED39/2210: against `opus_full_47` FAIL→OK 0, OK→FAIL 0, added 23 (all OK: the rows of this slice), removed 2 (`unit_s2_vis_signature_refused`, `unit_s2_vis_branch_refused`, replaced by their `_below` positives); of the 2187 common targets exactly three changed their message -- `unit_s2_vis_structure_below_refused` and `unit_root_struct_call2_forward_refused` (the call refusal above) and `unit_s1_merge_uncaught_entry` (now run) -- besides the two identifiers that change in every run (the translator's sha256, the unit hash of the two library rows). The 111 declared paths were hashed before the run; every staged copy is the declared bytes. |
| Replay of `opus_full_47`'s 2188 recorded translations | Final translator over the migrated sources against 23974ec7 over the old ones: 3 rows change their message (the visibility rows), 64 rows of migrated programs only their L1. |

<a id="ns-roles-1a"></a>
## 112. `b: A` binds b to a Structure; a head resolves before its tail is read (K03 NS-ROLES-1a)

Codex's answers under K03-UNIFIED-HEAD-IMPLEMENT-20261006-01: K03-S5-MIGRATION-20261007-06 (b) -- for absent b, `b: A`
with A an existing Structure introduces b as a reference to A, uniformly; K03-S5-ALIAS-VISIBILITY-20261007-07 -- the
same rule for a method (Q1, NS-ROLES-1b) and the both-way visibility of named callable definitions (Q2); and
K03-NS-ROLES-NEXT-20261007-09 -- 1a reuses the existing reference-cell storage downstream of the common resolution (no
source Frame made, no second resolver, no wrapper, no clone or reparent: the same referent in a cell of its own,
@b != @A, ordinary admitted writes and application); a merge-result referent may be its own measured sub-step; the
method tail's present reading stays only as disclosed debt until 1b; and the root's recorded `Later: 3` above `Later:`
closes now -- once the head is known, no spelling of the tail makes it an unknown definition.  The rule itself:
docs/LMX_semantics.en.md:666 ("For absent b, b: A and @: b A are equivalent assignment forms introducing b.
Subsequently b: args applies the Structure, while @: b B reassigns the reference."), :835, L2_spec_en.md:206.

What changed in `l2trans.lm1`:

- The binding is recognized after the one resolution at its site (`l2_ref_bind_site`, `l2_ref_tail_kind` over
  `l2_head_resolve`): b's head resolves to nothing there and its tail is one atom A that is a named Structure (5) or a
  value of a named model -- an own field or a formal (4); its kind and its model come from that resolution only.  In a
  method and its blocks the head's absence is the definition route's own test (`l2_local_absent_def`, the former body
  of `l2_local_ns_shape`); in a block of the root it is the resolution at the statement's place.  A root item's role
  must be read from the source before anything is registered (the lexical pass's count and fill walks agree):
  `l2_unit_ref_bind` reads it as the unit role does -- A a named Structure or a qualified branch's root the unit defines
  (both ways), or a Structure value bound above it -- and the collection stops with an internal error if that reading
  and the site's resolution ever disagree.
- The statement is kept by node in a registry (`l2_rb_at` / `l2_rb_model`, released with the translation), filled by
  the collection: for E before its rows are made (`l2_collect_decls`), for a method by `l2_collect_asgn_body`, once every
  Structure it may name is registered.  The declaration reader gives such a statement the reference contract of A's
  model with A its one candidate (`l2_rb_declaration`) -- the record every reader of a reference declaration already
  reads -- so b's row is made, checked (`l2_check_reference_init`), stored natively and walked exactly as a reference
  declaration's: a pointer cell, never a slot (`l2_own_is_slot`).  No source Frame is made.
- After the binding `b: args` is the application of the bound Structure, never a rebinding: `l2_colon_check_assignment`
  gives a head bound by `b: A` the arity refusal it gives a head holding a constructed Structure ("more arguments than
  box has formals"); explicit reassignment is `@: b B` (docs :836), which the pending typed-reference question still
  holds.
- A merge result as A (`a: merge: Model`, then `b: a`) is "a reference binding to a merge result is not built yet",
  said at A -- NS-ROLES-1c.  A method or a held callable as A keeps its present reading (S5's definition) until
  NS-ROLES-1b: disclosed debt, no alias support claimed.
- One visibility reading for a definition of the unit (`l2_def_visible`): `l2_ns_find`'s twins -- the payload lookup
  `l2_ns_find_payload` and the qualified branch's `l2_ebr_find` -- kept the source order after NS-ROLES-3; a merge
  operand or a reference binding naming a branch or a Structure defined below was refused ("unknown merge operand",
  "assignment value has unknown type").
- The root's head resolves before its tail is classified (`l2_head_absent`, `l2_struct_defined_below`): a frame whose
  tail is no Structure -- one value: an atom, a literal, an operator run, merge's construction is data -- applies a
  definition of its head written below it, whatever the tail is written as (`Later: 3`, `Later(3)`, `Later: x` above
  `Later:` are Later's application, refused: "more arguments than Later has formals"); the identifier-only clause of
  NS-ROLES-3 is gone from the unit role and from l2_head_absent.  A definition below is a frame whose tail is a
  Structure (book section 9, :563) that no data binding of the name precedes -- a receiver `@: t f(a)`, merge's
  construction, a reference binding; between frames whose tails are Structures, the first defines.  With no
  definition elsewhere, `Later: 3` defines Later (S5).

Evidence:

- Replay of the 2209 recorded translations of `opus_full_48` with the final translator against 64ebf1f0's: 3 rows
  differ.  `unit_k03_vis_unit_declares_tail` and its walked twin change their L1 (`x: Foo` above `Foo:` is now the
  binding of x to Foo, no definition of x) and still exit 7 natively and walked (run) -- the walked twin's pin of
  walked methods is (0,1) now, x being no procedure; `unit_ref_absent_colon` (`b: A`
  with A the merge result `A: merge: Model`, the NS-ROLES-3 migration of `Model: A`) said "unknown field path segment"
  at `b\value` and now says the 1c limit at A ("6:4: a reference binding to a merge result is not built yet"): its pin
  is re-pointed and disclosed.  Every other row: L1, exit and messages byte-identical.
- Witnesses, natively and under `--walk-methods`, 38 rows: the binding at the root, in a block of the
  root, in a method, in a block of a method, to a Structure defined below (root and method), to a method's own
  Structure, along a chain of bindings in a method and through a formal (`q: p`, the caller's Model written), at the
  root along a binding above (`a: Model`, `b: a`) and through a typed reference above (`@: Model h Model`, `b: h`), to
  a qualified branch's root defined below -- each writes through b and reads the write through A (exit 7; 81 if b were
  a copy; `@box = @Model` is false: a cell of its own); a merge operand naming a branch below, in a method and at the
  root; `Later: 3` alone defining Later; the refusals: `box: Model` again in a method and `box: 3` at the root (the
  application), `Later: 3` and `Later(3)` above `Later:`, and the 1c limit in a method and at the root.  The walked
  twins pin the methods they walk; `unit_k03_ref_local`'s own Structure's procedure keeps its native word.
- Mutants: each removes one rule whole, built from the final bytes one gcc at a time (m01-m11 from the bytes before a
  comment-only correction, whose replay is byte-identical), the witnesses translated natively and walked, the recorded
  translations replayed:

| Mutant | Red |
| --- | --- |
| m01 the declaration reader ignores the binding's record | 20 witness rows (every binding: "unbound dynamic input", "unresolved name") and the two `unit_k03_vis_unit_declares_tail` rows |
| m02 the unit role ignores the binding (a root `b: A` a definition again) | 10 witness rows ("unknown field path segment"; the root merge limit accepted) and 3 corpus rows |
| m03 a root block's statement never the binding | `unit_k03_ref_root_block` and its twin ("unresolved name") |
| m04 a value referent excluded | 6 witness rows (the chains, the method's own Structure, the method's merge limit accepted) and `unit_ref_absent_colon` |
| m05 the binding's row a slot | 16 witness rows ("root operation not walkable yet: a Structure-typed field in a method") and 2 corpus rows |
| m06 `b: args` a rebinding again | the two application refusals (accepted; "assignment value has incompatible type") |
| m07 the payload lookup in source order | 4 witness rows ("assignment value has unknown type"), 4 more whose L1 changes, 2 corpus rows |
| m08 a branch's root in source order | the two branch merge witnesses and twins ("unknown merge operand") |
| m09 E's bindings kept after its rows are made | 6 witness rows ("unresolved name") |
| m10 a one-value tail does not defer to a definition below | the two `Later:` refusals ("duplicate named Structure") and `unit_s2_vis_structure_below_refused` |
| m11 the identifier-only clause back in l2_head_absent | the two `Later:` refusals ("unsupported trailer") |
| m12 a merge result known only by its schema | the root merge limit and its twin (the internal disagreement error) and `unit_ref_absent_colon` |
| m13 the root misses a typed reference above | `unit_k03_ref_root_typed` and its twin |
| m14 the root misses a binding above | `unit_k03_ref_root_chain` and its twin |
| m15 the root misses merge's construction above | the root merge limit and its twin (accepted as a definition) and `unit_ref_absent_colon` |
| m00 control | none |

Recorded, not changed here: a method or held callable as A (NS-ROLES-1b); a merge result as A (NS-ROLES-1c); the
nullary application through b (`box()`, bare `box`) keeps the present refusal "executing a named Structure is not
supported yet" until the held-reference route of 1b; a method's own named Structure visible only after its definition
(V2); between two frames whose tails are Structures (`Later(3 4)` or `Later()` above `Later:`) the first defines.

Provisional (Codex K03-NAMED-DEFINITION-BOUNDARY-20261007-10): which occurrence of an unknown head defines -- a
one-value tail applying a definition below, the first of the Structure-tailed frames defining -- and the both-way
visibility of the unit's ordinary named Structures it rests on (Codex -07 Q2) are Codex's earlier interpretation and
this implementation, not an author decision.  The open question, the measured readings and the 12 dependent fixtures
(22 rows): `LMX_blog/q/named-definition-boundary.md`.

Decided by the author the same day (`LMX_blog/q/named-definition-boundary.md`, relayed by Codex in
K03-VISIBILITY-AUTHOR-CLOSE-20261007-12): both-way visibility belongs to the callables the receivers fn, fm and sub
create; an ordinary named Structure is not under that rule.  The lookahead above and the both-way visibility of
ordinary named Structures and qualified branches' roots go (K03 NS-ROLES-VIS).

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_45` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest); the staged `l2trans.lm1` is the declared bytes. |
| `build/l3_selftest/opus_l3_43` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_49` (full harness) | RED39/2248: against `opus_full_48` FAIL→OK 0, OK→FAIL 0, added 38 (all OK: the rows of this slice), removed 0; of the 2210 common targets one changed its message -- `unit_ref_absent_colon`, the 1c limit above -- besides the two identifiers that change in every run (the translator's sha256, the unit hash of the two library rows). The 22 declared paths were hashed before the run; every staged copy is the declared bytes. |
| Focused runs on the same bytes | `opus_focus_n1a_01` 97 targets: 2 red on walked-method pins (corrected: `unit_k03_ref_local`'s own Structure's procedure keeps its native word; `unit_k03_vis_unit_declares_tail`'s twin walks two methods now) -- `opus_focus_n1a_02` 7 targets, 0 failed. |
| Replay of `opus_full_48`'s 2209 recorded translations | 3 rows differ, named above; the rest byte-identical. |

<a id="ns-roles-1b"></a>
## 113. `b: tick` binds b to a method's whole occurrence; the application through a binding (K03 NS-ROLES-1b)

Codex's K03-S5-ALIAS-VISIBILITY-20261007-07 Q1 -- a method is a callable Structure, and `b: tick` (b absent) binds b to
tick's whole occurrence by the same reference rule as a Structure's: its signature, native code and body are tick's,
the cell is b's own, there is no wrapper, and nothing runs at the binding -- and K03-NS-ROLES-NEXT-20261007-09 (no final
alias claim while the method tail kept S5's wrapper reading; ordinary application through the binding).  The rule:
docs/LMX_semantics.en.md:666 ("Subsequently b: args applies the Structure"), :722 ("Applying b: args to a callable
Structure remains a call"), L2_spec_en.md:206.  The scope is NS-ROLES-1a's: the root, a block of the root, a method and
its blocks.

What changed in `l2trans.lm1`:

- What A is, at its site (`l2_ref_tail_kind`): a method (the one resolution's kind 2) is a referent -- the binding keeps
  the method in its registry entry (`l2_rb_meth`); at the root the source reading takes a method the unit names, both
  ways, as a genuine `fn`/`sub` declaration is visible (`l2_unit_ref_bind`).  A held callable as A -- a callable
  formal, a held callable merge, a C function local, or a binding `c: b` whose b holds a method (kind 3) -- is "a
  reference binding to a held callable is not built yet", said at A: the occurrence such a name holds is known only
  when it runs (a formal's is the caller's, and a call through it forms its hidden inputs by the formal's classes, K04),
  which a binding does not carry yet.
- The binding's row is a reference cell (`l2_own_decl_ty`: the graph reference type; `l2_own_decl_name`: b); no
  declaration record is made for it (`l2_rb_declaration` gives none: there is no model to admit).  Its store is the
  method's occurrence, as a callable formal receives one -- natively `l2_tok_method_occ`, walked
  `l2_rw_callable_actual` -- and nothing is called.  Two bindings of one occurrence are two cells (`@b != @c`).
- A call through the binding: `l2_head_resolve` reads b as a held callable (3) -- b's own field, or the unit's binding
  seen from a method; `l2_call_head_method` gives the method for b's head through `l2_call_alias_own` (the check is
  then the method's call, by its signature: "b has no argument n"); natively the call's self is the occurrence b
  holds (`l2_emit_alias_self`: b's working value or a load of its cell; in a method that sees the unit's binding, the
  method's hidden input, as for a held callable -- Q52, `l2_prep_held_call`), walked an EXEC on b's own field or on
  that input (`l2_rw_call`).  `b: args`, `b(args)`, `b()` (`l2_empty_struct_assign_shape` leaves b to the call) and
  the bare b, as a statement (`l2_eval_discard`) or a value (`l2_prep`, the walker's operand; its type the method's
  result: `l2_native_cf_ty`, `l2_rw_opty`), are that call.
- A binding to a named Structure itself executes it (`l2_own_call_origin`: the registry's -2): `box()` and the bare
  box run Model's body over the Structure box holds, as `Model()` does -- natively over the load of box's cell
  (`l2_emit_local_exec`), walked the EXEC the root's fields already take.  A binding to a value of a named model holds
  what that value holds, possibly a Structure admitted by name: its execution keeps the refusal a Structure formal's
  has, until executing an admitted value is settled.
- `b: args` after a Structure's binding stays the application's arity refusal (NS-ROLES-1a); after a method's binding it
  is the method's call.
- The bare method name as a definition's tail is gone with it (S5's wrapper reading, the debt NS-ROLES-1a disclosed):
  `b: tick` is the binding wherever 1a's `b: A` is; a definition whose tail applies a method (`c: tick()`, Q58) still
  retains that application and runs nothing.

Scope recorded (Codex K03-NAMED-DEFINITION-BOUNDARY-20261007-10, K03-DEFINITION-PAUSED-SCOPE-20261007-11): which
occurrence of an unknown head defines a named Structure is an open author question
(`LMX_blog/q/named-definition-boundary.md`); until the answer, new work on forward ordinary Structures and on
qualified branches' roots below their use is paused with it (a receiver-declared `(): cfg` settles its defining
occurrence, not its visibility above its declaration), and the 12 provisional fixtures listed there (22 rows) stay in
the gate, disclosed.  No 1b witness uses a definition below its use: every method and Structure a binding names is
declared above it.  (The question was answered the same day -- both ways only for fn, fm and sub -- and the pause ended:
section 112's closing note, K03 NS-ROLES-VIS.)

Evidence:

- Replay of the 2247 recorded translations of `opus_full_49` with the final translator against 234bb50f's (the bytes of
  83db2d4a): 4 rows differ, all in their L1 only.  `unit_k03_def_callable_body` and `unit_factory_short_dormant` with
  their walked twins: `b: tick` and `s: shout` are bindings now, no definitions -- one procedure fewer, the walked
  twins' pins re-pointed ((0,1,3,4) -> (0,1,3); (2,3) -> (2)); both programs still give 7 natively and walked (run),
  and the second still says only DONE: nothing runs at a binding, and `c: tick()` / `t: shout()` keep Q58's dormant
  application.  Their header comments are reworded, line counts kept.  Every other row -- the 12 provisional rows of
  the open definition question among them -- byte-identical in L1, exit and messages.
- Witnesses, natively and under `--walk-methods`, 24 rows: a method's binding in a method (`b(3)` = 4, then `b: 2`,
  tick's counter 5), at the root (`got: b(3)`), at the root seen from a method (the hidden input), in a block of a
  method; the bare binding as a statement, empty-applied and as a value (two's counter 30 after three calls); the
  occurrence's own state through both names (`tick\last` after `b(5)`, `c(6)`) and two bindings in two cells
  (`@b = @c` false); `box()` and the bare box after `box: Model` (Model's body twice in a method, once at the root);
  the refusals: `b()` without tick's n ("12:5: b has no argument n"), a callable formal as A and the chain `c: b` in a
  method and at the root (the held limit, at A).  Every positive runs to 7 natively and walked; nothing runs at a
  binding (81 if it did).  The pins count one match per call through a binding: natively the self from b's working
  value (`l2_q`) or from the method's hidden input (`l2_p`), the Structure's execution over box's working value;
  walked an EXEC whose operand frame is b's own field (OWN, OWN_OF in a block) or the hidden input (ARG); the walked
  twins pin their walked methods.
- Mutants: each removes one rule whole, built from the final bytes one gcc at a time; the witnesses translated natively
  and walked, the pins evaluated, the witnesses whose L1 changed and whose pins held run, the recorded translations
  replayed.  Where only a pin is red the run cannot tell the routes apart: b holds tick's own occurrence, and the root's
  binding read as the hidden input or from its cell is the same occurrence; the pin keeps the route the call takes.

| Mutant | Red |
| --- | --- |
| b01 the root reads no method as A (a root `b: tick` a definition again) | 6 witness rows (`unit_k03_alias_root`: "tick has no argument n"; `_root_seen`: "a callable without a result has no value"; the root chain limit) and the two `unit_factory_short_dormant` rows (their L1 back to the wrapper) |
| b02 a method as A no binding (S5's wrapper reading) | 18 witness rows (every method binding and both chains: "unknown method", "more arguments than b has formals", the internal disagreement at the root, ...) and 4 corpus rows |
| b03 a held callable as A no limit | the held limit (accepted natively; walked the walker's callable-formal limit instead) and the 4 chain rows |
| b04 a call through b not on b's occurrence (natively and walked) | 12 pin rows (every call site's self and EXEC); `unit_k03_def_callable_body`'s two L1 |
| b05 b's call head resolves to no method | 14 witness rows ("unknown method", "unsupported body", ...) and 2 corpus rows |
| b06 the binding's row no reference cell | 18 witness rows and 4 corpus rows |
| b07 the bare binding as a value its cell | `unit_k03_alias_bare` and its twin ("root operation not walkable yet: a Structure-typed field") |
| b08 `b()` read as a Structure's execution | `unit_k03_alias_bare` and its twin ("executing a named Structure is not supported yet") and 2 corpus rows |
| b09 a Structure's binding not executed through b | the 4 Structure-execution rows ("executing a named Structure is not supported yet") |
| b10 nothing stored at the binding | the 12 method-binding runs (natively "invariant: a reference binding holds no callable occurrence", walked "walk error: INVALID") and 4 corpus rows |
| b11n natively the root's binding in a method read from its cell, not as the hidden input | `unit_k03_alias_root_seen`'s pin; its walked twin runs to 7 |
| b11w the same, walked | `unit_k03_alias_root_seen_walk`'s pin; its native twin runs to 7 |
| b12 the bare binding as a statement called on tick's own occurrence | `unit_k03_alias_bare`'s pin (3 selves -> 2); its walked twin runs to 7 |
| b13 a call through b has no value type | `unit_k03_alias_bare` and its twin ("a reference compared with a number other than 0") |
| b14 the one resolution reads a binding as a value | the 4 chain rows (in a method accepted, at the root the internal disagreement); no other witness reaches it -- calls through b resolve before it.  It first survived the 20 rows; the chain witnesses were added for it |
| b00 control | none |

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_46` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest); the staged `l2trans.lm1` is the declared bytes. |
| `build/l3_selftest/opus_l3_44` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_50` (full harness) | RED39/2272: against `opus_full_49` FAIL→OK 0, OK→FAIL 0, added 24 (all OK: the rows of this slice), removed 0; of the 2248 common targets none changed its message besides the identifiers that change in every run (the translator's sha256, the unit hash of the two library rows); the 39 red are the same rows with the same messages. The 16 declared paths were hashed before the run; every staged copy is the declared bytes. |
| Focused run on the same bytes | `opus_focus_n1b_01` 121 targets, 0 failed (the 24 rows of this slice, the two corpus programs and their twins, the K03 ref/vis/def rows). |
| Replay of `opus_full_49`'s 2247 recorded translations | 4 rows differ in their L1, named above; the rest byte-identical. |

<a id="ns-roles-vis"></a>
## 114. An ordinary named Structure is visible from its place on; fn, fm and sub both ways (K03 NS-ROLES-VIS)

The author's decision of 2026-10-07 (`LMX_blog/2026-10-07.md#method-declaration-visibility`; the question
`LMX_blog/q/named-definition-boundary.md`; the norm `docs/LMX_semantics.en.md#declaration-visibility`, written by Codex in
442600ec; Codex K03-VISIBILITY-AUTHOR-CLOSE-20261007-12): both-way visibility belongs to the callables the receivers fn,
fm and sub create; an ordinary named Structure is not under that rule -- its declaration, like an ordinary binding of a
value, is visible from its place on, forward and down, and a qualified branch's root with it.  A definition below makes
no head above it known; the shape of a tail, the number of arguments, parentheses or a trailer choose no later
declaration.  This is a forward correction of NS-ROLES-3 (64ebf1f0, section 111) and NS-ROLES-1a (83db2d4a, section
112), whose both-way reading of named Structures rested on Codex's -07 Q2 interpretation, not on the author.

What changed in `l2trans.lm1`:

- `l2_head_absent`: an earlier frame headed t binds t whatever its tail is written as -- its definition (the first
  written occurrence of an unknown head), merge's construction or a reference binding; nothing looks below.
  `l2_struct_defined_below` and the item's own deferral to a definition below are gone.
- The lookups by name (`l2_ns_find`), by payload (`l2_ns_find_payload`) and of a branch's root (`l2_ebr_find`) read the
  definition's place again (`l2_vis_ok`); `l2_def_visible`, the both-way reading 1a shared among them, is gone.
- A signature reads the Structures visible where its method stands: the late refresh of signature models
  (`l2_sig_models_refresh`, NS-ROLES-3) and the type position's whole-unit clause in `l2_contract_formal` are gone.
- The root's source reading of `b: A` (`l2_unit_ref_bind`) and of a typed reference above a binding
  (`l2_unit_value_above`) take a named Structure or a branch's root only when it is defined above
  (`l2_unit_defines_struct`, `l2_unit_defines_branch` take the stop item now).  A method stays visible both ways
  (`l2_unit_names_method`).  fm is not built: an fm application is "fm is not supported yet"
  (`unit_k03_empty_fm_stmt_refused`), so fm's both-way visibility has no runnable witness until fm exists.

Implementation debt, pinned as such (Codex K03-VIS-CALL-CLASSIFICATION-20261007-16): with Model existing, `Model: Other
extra` is Model's call by the language (docs :668), whatever Other is; with Other invisible above its definition the
translator takes the old typed receiving route (`l2_colon_bind_shape`, `l2_check_bind`) and refuses the candidate
(`unit_root_struct_call2_forward_refused`, its header says so).  The call classification is the next step,
NS-ROLES-CALL.

Evidence:

- Census: the replay of the 2271 recorded translations of `opus_full_50` with this translator against 156eefc7's
  (1b's) changes 24 rows of 13 fixtures; every other row is byte-identical in L1, exit and messages.  The 22 rows of
  the census of 234bb50f, and `unit_s2_vis_signature_below` with its twin, which that census (a forward-off variant that
  kept the signature refresh) did not see:

| Fixture (and its walked twin) | Before | Now |
| --- | --- | --- |
| `unit_k03_vis_later_struct_method` | exit 7 (m above Later reads Later) | "15:30: unbound dynamic input Later" |
| `unit_k03_vis_later_struct_root` | exit 7 | "4:5: unresolved name" |
| `unit_s2_vis_branch_below` | exit 7 | "20:30: unbound dynamic input cfg" (the S2 reading) |
| `unit_s2_vis_signature_below` | exit 7 | "5:11: unknown type" (the S2 reading) |
| `unit_k03_vis_branch_merge_above` | exit 7 | "6:15: unknown merge operand" |
| `unit_k03_vis_branch_merge_root_above` | exit 7 | "5:11: unknown merge operand" |
| `unit_k03_ref_later` | exit 7 (1a: a binding to a Structure below) | "12:5: unknown field path segment" -- box and inner above Later each define a Structure of their own |
| `unit_k03_ref_branch_later` | exit 7 (1a) | "7:11: unresolved name" |
| `unit_k03_vis_later_frame_call_refused` | "5:1: more arguments than Later has formals" | "6:1: ..." -- `Later(3)` defines Later, the block is its application |
| `unit_k03_vis_later_literal_call_refused` | "6:1: ..." | "7:1: ..." |
| `unit_s2_vis_structure_below_refused` (no twin) | "3:1: more arguments than Model has formals" | "4:1: ..." |
| `unit_root_struct_call2_forward_refused` (no twin) | "11:1: more arguments than Model has formals" | "11:1: a typed binding's candidate is not a Structure value" -- the implementation debt above |
| `unit_k03_vis_unit_declares_tail` | exit 7, x a binding | exit 7, x a definition again (run); walked pin (0,1) -> (0,1,2) |

- Fixtures: the eight positives in the first rows become their refusal rows in place; the headers of fifteen programs
  are reworded with their line counts kept (the twelve above with headers, `unit_s2_vis_signature_below`,
  `unit_k03_vis_literal_tail_defines` and `unit_k03_vis_nested_sibling_refused`, whose texts named the both-way
  reading); the needles re-pointed as measured.  New rows: `unit_vis_method_below` (the root and a method above twice,
  an fn, and bump, a sub, call them: exit 7 natively and walked), `unit_vis_typed_ref_below_refused` (`@: Later h Later`
  above `Later:`, then `b: h`: "5:4: unknown type"), and the two S2 refusals NS-ROLES-3 had replaced, re-added from
  64ebf1f0^ with their measured needles: `unit_s2_vis_branch_refused` ("15:1: unbound dynamic input cfg") and
  `unit_s2_vis_signature_refused` ("3:11: unknown type"), each with a walked twin now.  Every witness, natively and
  under `--walk-methods`, gives its needle as the first diagnostic or runs to 7.
- Mutants: each puts one removed rule back (or drops one place restriction) in the final bytes, built one gcc at a
  time; the 19 witness programs translated natively and walked, the changed positives run, the recorded translations
  replayed:

| Mutant | Red |
| --- | --- |
| v01 an earlier frame binds its head only by its tail's shape | the two lookahead refusals and `unit_s2_vis_structure_below_refused` with their twins ("duplicate named Structure"); 5 corpus rows |
| v02 the lookup by name both ways for a unit's Structure | 18 witness rows (every reader of a later Structure or branch root is accepted or changes its refusal; the call row's debt message reverts to the arity refusal); 15 corpus rows |
| v03 the lookup by payload both ways | none: not reached -- every reader classifies the name by `l2_ns_find`, or as a dynamic input, before the payload lookup; probes (a merge operand, a Structure actual, `@Point`, a binding in a method above the definition) refuse identically under both builds |
| v04 a branch's root found both ways | the two branch-merge rows and their twins |
| v05 a type position takes a Structure defined anywhere | the two signature rows and their twins |
| v06 the root's source reading takes a Structure defined anywhere | `unit_k03_ref_later` and `unit_k03_vis_unit_declares_tail` with their twins (the internal disagreement error) |
| v07 a typed reference above a binding takes a Structure defined anywhere | `unit_vis_typed_ref_below_refused` and its twin (the internal disagreement); it first survived, a probe reached it, the witness was added for it |
| v00 control | none |

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_47` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest); the staged `l2trans.lm1` is the declared bytes. |
| `build/l3_selftest/opus_l3_45` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_51` (full harness) | RED39/2280: against `opus_full_50` FAIL→OK 0, OK→FAIL 0, added 8 (all OK: the new rows of this slice), removed 0; of the 2272 common targets 25 changed their message -- the 22 re-pointed rows of the census above (the `unit_k03_vis_unit_declares_tail` pair keeps its message: it still runs) and the identifiers that change in every run (the translator's sha256, the unit hash of the two library rows); the 39 red are the same rows with the same messages.  The 21 declared paths were hashed before the run; every staged copy is the declared bytes. |
| Focused run on the same bytes | `opus_focus_vis_02` 134 targets, 0 failed (the visibility rows, the K03 ref/alias/def/vis rows, the S2 rows); `opus_focus_vis_01` stopped before running: its list named two walked twins that do not exist. |
| Replay of `opus_full_50`'s 2271 recorded translations | 24 rows of 13 fixtures differ, named above; the rest byte-identical. |

<a id="ns-roles-call"></a>
## 115. A known ordinary named Structure head is its call, whatever its actuals are (K03 NS-ROLES-CALL)

The rule (`docs/LMX_semantics.en.md:668`, `docs/L2_spec_en.md:155`; Codex K03-VIS-CALL-CLASSIFICATION-20261007-16 and
K03-NS-ROLES-CALL-20261007-17): with A an existing ordinary named Structure, `A: args` in an executable body is A's
call whatever the actuals are -- their number, their spelling, and whether an actual is known, unknown or defined
below.  An ordinary named Structure has no arguments, so any actual is the general arity error at the call; an
unknown actual is neither declared nor cloned; an unknown head still defines a named Structure with its written
contents.  Until this step the translator kept OPUS-TYPED-BINDING-20260930-20's typed receiving route: `T: b c`, b
absent there, declared b typed T and bound it to c after c's admission to T.  Whenever b was invisible -- unknown, or
a named Structure defined below -- the route took the line instead of the call; section 114 pinned one such row as
implementation debt (`unit_root_struct_call2_forward_refused`).

What changed in `l2trans.lm1` (2da89f5d):

- The route is gone: `l2_colon_bind_shape` (its shape), `l2_check_bind` and `l2_bind_untyped` (its admission) and
  `l2_rw_model_bind` (its walked binding).
- So is every consumer: `l2_colon_bound_before`'s clause (a typed binding's b above counted as bound), the collection
  (`l2_collect_asgn_body`), the scan (`l2_scan_body`), `l2_colon_decl_room`, the root's source placement of
  `Model: b c` in `l2_src_one`, the checker's branch in `l2_check_body`, the walked statement (`l2_rw_stmt_content`;
  `T: b` keeps `l2_rw_model`), the throws reading (`l2_body_throws`), the emission (`l2_emit_stmts`) and
  `l2_admit_finish`'s "implements is false in a typed binding", whose only caller was `l2_check_bind`.  Thirteen
  locals left without a reader are dropped; gcc's `-Wall -Wextra` list is the same 75 warnings before and after.
- Nothing is added.  Without the route the line meets the common resolution: a known head, its call -- the arity
  refusal Q59 made general (`l2_struct_arity_error`); an unknown head, its definition.  No refusal reads the source's
  shape or a name.

The rows the route carried (Codex -17's migration guard; fixture bodies untouched, headers rewritten with their line
counts kept, so no needle moves):

- `unit_bind_candidate_not_name_refused` (`Model: b mk()` in a method) pinned the route's own limit, "a typed binding
  whose candidate is not a name is not built yet"; no purpose outlives the route.  It is the call's refusal now.
- `unit_bind_root_ref`, `unit_bind_root_thin_other`, `unit_bind_root_used_other_refused`,
  `unit_bind_method_used_other_refused`, `unit_bind_root_letter` and `unit_bind_root_letter_refused`: the written
  `Model: b c` (`MainLetter: b raw`) is the known head's call, so each row is that refusal; two positives and the
  letter's run-time refusal become translation refusals.  Their purpose -- b constrained by a model and bound to a
  candidate, admitted by b's uses at translation or at run time -- is a model-constrained reference with a value, the
  `@: T name value` family that the author's open question lists as dependent
  (`LMX_blog/q/current/model-constrained-null-reference.md`, not touched).  It is exact debt, not reinterpreted:
  [TYPED-BINDING-PURPOSE-DEBT](defects.md#typed-binding-purpose-debt) names each row and its old verdict.  No helper
  method with a typed formal replaces a root receiving place; the formal side keeps its own rows
  (`unit_formal_thin_other`, `unit_formal_used_other_refused`, `unit_admit_letter_formal`, `unit_admit_letter_not_model`,
  `unit_admit_formal_refused`), and the explicit `@: Model b c` rows in methods (`unit_bind_method_ref`,
  `unit_bind_method_formal`, `unit_bind_method_thin_other`, `unit_recv_use_*`) are unchanged, inside the question's
  frozen family.
- `unit_root_struct_call2_forward_refused`: the debt of section 114 is resolved -- the line is Model's call however
  Other stands; its header states the rule.
- Stale explanatory text corrected, rows unchanged: `unit_bind_known_b_call_refused` and `unit_root_struct_call_refused`
  ("until a named Structure's call with an argument is built" -- an ordinary named Structure has no arguments, the
  refusal is the language's), `unit_root_struct_call2_refused` ("declares only by `T: name`"), `unit_formal_thin_other`
  and `unit_formal_used_other_refused` ("the same admission `Model: b o` takes"); in the harness the comment over the
  root call rows (disclosed at the VIS checkpoint) and the route's comment over the `unit_bind_*` rows.

Not in this step: in a named body the one-atom `Model: zz` is still the old reference-field reading (a probe: "5:5:
root operation not walkable yet: a Structure-typed field in a method") -- NS-ROLES-2's branch in the plan (Codex -07
Q3).  Every other count and spelling in a named body resolves as the call here.  Found while this step was gated:
three harness comments that NS-ROLES-VIS left stale -- the S2 visibility block and the NS-ROLES-3 and NS-ROLES-1a
blocks still describe NS-ROLES-3's both-way reading of named Structures and branch roots; they are corrected with
NS-ROLES-1c, the harness bytes of this step being gated already.

Evidence:

- Census: a diagnostic variant of 147a9e16's translator in which `l2_colon_bind_shape` never gives its shape (the route
  closed for every head), replayed over the 2279 recorded translations of `opus_full_51`, changes 8 rows of 8
  fixtures; every other row is byte-identical in L1, exit and messages.  The translator of this step replays
  identically to that variant on all 2279 rows, so the removal moves exactly the census:

| Fixture | Before | Now |
| --- | --- | --- |
| `unit_bind_root_ref` | exit 7 (a write through b read through c) | "16:1: more arguments than Model has formals" |
| `unit_bind_root_thin_other` | exit 7 (an Other admitted to a Model-typed b nothing uses) | "15:1: ..." |
| `unit_bind_root_used_other_refused` | "14:1: implements is false in a typed binding" | "14:1: ..." |
| `unit_bind_method_used_other_refused` | "14:5: implements is false in a typed binding" | "14:5: ..." |
| `unit_bind_root_letter` | exit 2 (the letter admitted to MainLetter at run time, b its payload) | "9:1: more arguments than MainLetter has formals" |
| `unit_bind_root_letter_refused` | run: Fails 1, Stopped 1, Thrown 2 (the run-time admission refused) | "13:1: more arguments than Model has formals" |
| `unit_bind_candidate_not_name_refused` | "18:5: a typed binding whose candidate is not a name is not built yet" | "18:5: more arguments than Model has formals" |
| `unit_root_struct_call2_forward_refused` | "11:1: a typed binding's candidate is not a Structure value" (section 114's debt) | "11:1: more arguments than Model has formals" |

- New witnesses, twelve programs, each with a `--walk-methods` twin.  Ten refusals, all "more arguments than Model
  has formals" at the call: at the root the first actual unknown (`unit_call_root_unknown_refused`, 11:1), defined
  below (`unit_call_root_below_refused`, 11:1), three unknown actuals (`unit_call_root_three_refused`, 10:1), the Frame
  spelling `Model(zz 3)` (`unit_call_root_frame_refused`, 10:1); in a method unknown, below and declared above
  (`unit_call_method_unknown_refused` 12:5, `_below_` 12:5, `_known_` 15:5); in a named body Outer, never called, whose
  retained application is checked as the call it is: unknown, below and declared above (`unit_call_named_unknown_refused`
  12:5, `_below_` 12:5, `_known_` 15:5).  Two positives: `unit_call_nullary_runs` (`Model()` and `Model: ()` at the root,
  the bare `Model` in a method and `Model()` retained in Outer and run by `Outer()`: four runs of Model's body, exit 7;
  defining Outer runs nothing) and `unit_call_unknown_head_defines` (`Fresh: zz extra` at the root, `Inner: zz extra` in
  Outer, `Local: zz extra` in a method, each head unknown: definitions, exit 7), natively, with the root walked and with
  the methods walked (pins (0,1,2) and (0,1,2,3,5), read from the twins' L1).
- The route put back: the removal deletes the route and nothing else, so its mutant is 147a9e16's own gated
  translator (`opus_full_51/bin/l2trans.exe`, built from 7a6f7f39).  Under it the root's unknown, below
  and Frame witnesses, the method's unknown and below and the named body's unknown give the route's messages, natively
  and walked ("a typed binding's candidate is not a Structure value"; the Frame "a typed binding whose candidate is not
  a name is not built yet") -- twelve rows red; the three-actual row and the method's and the named body's declared-above
  and the named body's below rows are the common route's controls (the same arity refusal under both); the positives'
  L1 is byte-identical under both.  So the witnesses separate the shared call check from the old typed receiving.
- Probes, not rows: the one-atom `Model: zz` in a named body is still the old reference-field reading ("5:5: root
  operation not walkable yet: a Structure-typed field in a method"), NS-ROLES-2's.

### Measured

| Gate | Result |
| --- | --- |
| `build/l2src/opus_kernel_48` (`build_l2src.ps1 -Run -KeepAll`) | GREEN: 297 targets, 114 selftests ran (113 at exit 0 and the one expected-fatal watchdog selftest); the staged `l2trans.lm1` is the declared bytes (2da89f5d). |
| `build/l3_selftest/opus_l3_46` (`run_l3_selftest.py`) | All 11 suites exit 0; type budget ok, four units. |
| `build/l2_harness/opus_full_52` (full harness) | RED39/2304: against `opus_full_51` FAIL→OK 0, OK→FAIL 0, added 24 (all OK: the twelve witnesses and their twins), removed 0; of the 2280 common targets 11 changed their message -- the 8 census rows above and the identifiers that change in every run (the translator's sha256, the unit hashes of the two library rows); the 39 red are the same rows with the same messages.  The 27 declared paths were hashed before the gates and again before this run; the staged `l2trans.lm1` is the declared bytes.  `opus_full_52` (the same bytes) was stopped at 5434 logs by Claude Code's low-memory reaper; this is its rerun. |
| Focused run on the same bytes | `opus_focus_call_01` 40 targets, 0 failed (the 37 declared stems with the translator's build and the driver's). |
| Replay of `opus_full_51`'s 2279 recorded translations | 8 rows of 8 fixtures differ, named above; identical to the closed-route census variant on all 2279. |

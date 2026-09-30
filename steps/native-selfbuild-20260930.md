# Native compilation and the route to §§8–8a

Status: 2026-09-30, runtime checkpoint ca2f1cd on main; translator WIP in build/opus_wt.
Implementation evidence and remaining work, not a language specification.

## Resumed after Q56/Q57 documentation correction

The author has resumed implementation through §§8 and 8a after a separate
documentation checkpoint. The earlier research HOLD is withdrawn. Use the
current semantic book construction/dynamic chapters and next_core_tasks §3:
no implicit Model:fresh clone, no unknown-argument declaration fallback,
explicit reference binding with conversion before structural admission,
nonexecuting signatures, and Q57 as definition containing an empty named
Structure rather than an immediate or delayed call. Earlier typed-binding
and empty-reference experiments are not the accepted declaration contract.

The preserved worktree was fast-forwarded to 6538898 without discarding its
code WIP. That documentation checkpoint is on main and origin/main. Current
code has not passed one exact-byte full generated/kernel/L3 gate. The old
full harness s7b108 had 105 failures; those include obsolete root-only text
expectations and real defects, not permission to weaken the harness.

Fresh diagnostics after the documentation checkpoint:

| Run | Scope and result |
| --- | --- |
| `build/l2src/resume_q57_20260930_01` | Optional `-Strict` run: 280 targets, 136 failures, primarily warnings promoted to errors; not the standard runtime gate |
| `build/l2src/resume_q57_20260930_02` | Standard `build_l2src.ps1 -Run -KeepAll`: **280 targets, zero failures**; includes the corrected deep-holder witness |
| `build/l2_harness/resume_ref_20260930_01` | Focused signature run: 8 targets, one failure exposed inconsistent raw/encoded formal types |
| `build/l2_harness/resume_ref_20260930_02` | Focused signature run after normalization: **8 targets, zero failures**, including existing primitive/reference controls |
| `build/l2_harness/address_name_20260930_09` | Common Structure/reference-cell address acquisition: **15 targets, zero failures**; 12 fixtures including depth refusals and existing controls; two deliberately inverted positive witnesses fail |
| `build/l2src/mapped_cycles_20260930_01` | Standard kernel after mapped-cycle repair: **280 targets, zero failures**, 104 selftests; runtime implements 55 checks (25 new), table 59 checks, zero failures in both |
| `build/l2_harness/resumed_full_20260930_01` | Full frozen WIP diagnostic: **966 targets, 854 OK, 112 failed**; not a clean-kernel certificate |
| `build/l3/resumed_l3_20260930_01` | **11 runtime suites / 295 checks pass**; overall exit 1 because four header-inventory expectations still require 72 names instead of the measured 73 after adding the operation-local LmxImplementsFrame; capacity remains 128 names / 8192 bytes |
| `build/l2_harness/formal_address_20260930_final` | Corrected static formal-address slice: **13 targets, zero failures**, ten fixtures; all three deliberately inverted positive controls fail at execution, then are restored before this final run |
| `build/l3/formal_address_20260930_final` | **Full L3 gate exit 0**: 11 runtime suites / 295 checks; all four header inventories 73/128 names and 1043/8192 bytes. Updated only the expected count for LmxImplementsFrame, not the capacity |
| `build/l2src/runtime_checkpoint_20260930_01` | **278 targets, zero failures**, 104 selftests, on isolated main ca2f1cd without translator WIP or its new metadata header; implements 55/55 and table 59/59 |
| `build/l3/runtime_checkpoint_20260930_01` | Isolated ca2f1cd: **11 suites / 295 checks, exit 0**; four inventories 73/128 and 1043/8192. Full console, including inventory results: `build/l3/runtime_checkpoint_20260930_01.log` |
| `build/l2_harness/native_gate_migration_20260930_02` | Translator WIP only: **15 targets, zero failures**, twelve migrated native/graph witnesses; separate 60-check graph-observer audit includes 40 negative mutations and eight valid temporary-renumbering cases. Not a full harness gate |

The first kernel run predates the subsequent reference-translator edits. The
focused harness does not replace a full gate. The stopped audit run
`build/l2_harness/20260930_144410` has no verdict and is not evidence.

The first signature experiment used existing Model and Other, not the withdrawn
implicit `Model: fresh` construction. Its claim that signature synonymy also
proved a local rebinding policy was not justified and has been withdrawn.
The current witness proves only reference transmission and descriptor identity.
Native named-value address acquisition now
distinguishes an actual Structure descriptor from an explicit reference's
cell. Flat and Frame forms use the same classification; an extra reference
level is not erased. Translator blob for the focused green run:
acec2a68ed3402c73bd72a4065e9057e2631a7fc. This does not yet prove unified
field/index paths or interpreted portable references. The full generated
harness and L3 runner must be repeated.

Independent review found that the new `unit_address_formal_depth_refused`
expectation was wrong under L2 §18.2–18.3: a reference-transmitted nonprimitive
formal denotes its descriptor, not the machine parameter's address. The
15/15 result remains execution evidence, not proof of that expectation.
The corrected WIP uses a shared logical input category derived from existing
signature/callable metadata, not the backend pointer spelling. The final
13/13 run above proves descriptor identity for both Structure-formal spellings
and callable formals, retaining primitive cell-address and genuine explicit
body-reference depth controls. The wrong refusal fixture was replaced by
positive descriptor witnesses. `unit_ref_signature_synonyms` now tests
transmission/identity, not a new formal rebinding policy. Formal call/rebind
classification has not been changed by this address fix. Array formals and
dynamic-input category propagation remain implementation gaps; no guessed
fallback category was added and no interpreted-reference coverage is claimed.
Final translator SHA256:
C2A8D284160E459FDE3A251F79B5DA1E6BFFA80962941CE6BD264711F8564D4B;
Git blob aa03bb62d38c6b4cafdcba205706656133f33d6b. Code remains uncommitted
WIP in build/opus_wt, not a main/stable-source promotion. The last full
generated run predates this final address correction and remains red; no
clean-kernel, §8 or §8a completion is implied by the focused and L3 successes.

### Latest full generated diagnostic (before char-storage repair)

`build/l2_harness/after_return_full_20260930_01`: **973 targets,
882 OK, 91 FAIL**, exit 1. Compared by row identity with
`resumed_full_20260930_01`, 21 formerly failing rows now pass; no formerly
green row regresses and no new row fails. Eight new rows pass; the former
incorrect negative formal-address row was removed/replaced, so the total
grows by seven, not eight. The repaired rows cover the twelve native/graph
witnesses, eight diagnostic migrations and the restored root FOR graph.

Remaining failures group by their observed harness reason: 43 mismatched
diagnostics, 29 generated-text assertions, 12 former refusals now accepted,
six missing-L1 rows, one missing native-note assertion. These are categories
for investigation, not a claim that every failure is a stale test: the six
missing-L1 rows retain real admission/construction dependencies described
below; graph observers must not be weakened to hide missing operations.

The [43-row diagnostic inventory](generated-diagnostic-migration-20260930.md#scope-evidence)
now distinguishes 34 masking void-root returns from nine other refusals.
Its bounded implementation groups are 14 current-contract fixture repairs,
13 raw-C/string witnesses, ten withdrawn unknown-head assumptions and six
production/construction dependencies. In particular, the Message addressee
test exposes a pre-layout semantic type check incorrectly using walker-layout
metadata; changing its expected text would hide the defect.

Frozen source is translator blob `9d5fc38fed49153379a3718493cf0d2a5f6cc79e`,
SHA256 `7A4A380C00FB2F55750329C1CC32BDE6E85818696ACE26AD9C635860712A14D1`;
harness SHA256 `4BD1F5CAE3E9A43ECA89E728EB4DBC3AF5A12F4A429548BA8998B4B6EC07DF20`.
The source hashes still matched after the terminal verdict, before the next
writer started. Source editing/build ownership then passed to the bounded
CHAR-DECLARED-CELL-IDENTITY repair. This result is not a clean-kernel gate,
a source promotion to stable, or a §8/§8a completion claim.

<a id="char-declared-cell-identity-verified-wip"></a>
### CHAR declared-cell identity: verified WIP

Mutable CHAR declarations, captures, publication targets and result destinations
now use fresh typed arena cells and in-place stores. Immutable literals and
expression transport remain interned. Copy uses the ordinary source-address
map: different equal-valued cells stay different, repeated references stay
aliased. Explicit pointer-pointee sharing and retained profiles are unchanged.
The first fresh CHAR constructor initializes the existing first-chunk literal
table before taking a mutable cell from the same typed pool.

Final exact-byte gates, all under repository `build/`:

| Evidence directory | Terminal result |
| --- | --- |
| `l2src/char_identity_20260930_final2` | 280/280 targets; 104 executed selftests; copy 270, call destinations 14, catch 23 |
| `l3/char_identity_20260930_final2` | 11 suites, 295 runtime checks; all four inventories pass at 73 types |
| `l2_harness/char_identity_20260930_final3` | 19/19 targets, 16 fixtures |
| `l2src/char_identity_mutants_20260930_02` | Six intended mutation failures; scripts `run.ps1`, `run_publication.ps1`, `run_held.ps1` |

Old-byte `char_declared_old_20260930_03` compiled and ran both address witnesses
red, exit 81 instead of 7. Earlier `_01/_02` were preempted by declaration/type
refusals and are not storage-failure evidence. The six final mutants cover
interned declarations, value-based copy collapse, missing copy memo, mutation
of literal CHAR, publication rebinding, and a held-call result in stack scratch.
For the last case, a generated-C observer proves both returned results belong
to the owner arena's CHAR range; restoring the exact stack-spare branch fails
86 while that stack object is still alive. The ordinary d/e fixture only proves
copied result values; it does not alone prove returned-reference lifetime.

The first L3 `char_identity_20260930_final` had six link failures for missing
`lmx_chars_init`. The correction is the actual module dependency: value_owned
imports existing `lmx_chars.lm1`, not a per-suite linker workaround. Every final
gate above includes it. Eight changed implementation/header files match both
final kernel and harness staging; 227 directly mapped kernel inputs match.

Final SHA256:

```text
l2trans.lm1             C9E583C67D00A37319A441EB7227270BB825DF2907F9002A8E4E7DAFA1260D82
lmx_value_owned.lm1     C0A37ABB9CE8B920D35382EECBBCF2EAEB5FE1C5530BEE720A4F31A690957A86
lmx_walk.lm1            D11276E1CE2693E9E681A0C28B8C8425468C0B882FAFBBC0947363BED07C34D9
lmx_graph_copy_owned.lm1 7CA9BF29625DBE97F8F3E33DBA98EF766FF67C7A4004CA8D7DA715CB436C008F
tools/l2_harness.ps1    F6F3F34BD7B872103326982A481294D6ED70A2807E7DA5A4DAE51225BA368E7F
```

This is verified source WIP, not a published translator or clean-kernel gate.
The full generated corpus still needs a fresh delta. No generated walker
primitive-pointer or held-root walker coverage is claimed. Remove unused
`dst_chars` from five public copier APIs and five forwarding merge APIs together
with callers before clean-kernel; private threading is already gone. Correct
the remaining old field-rebinding introduction in `lmx_chars.lm1` in that cleanup.

<a id="catch-pointer-verified-wip"></a>
### Catch scope and pointer contracts: verified WIP

`build/l2_harness/catch_pointer_20260930_final2`: **47/47**, 44 selected
fixtures and three build/scope rows. Parent independently checked the terminal
summary, source hashes and clean diff. All writer commands ended before the
next source/build owner started. No production runtime or driver change in
this slice; the earlier CHAR kernel/L3 results remain separate evidence,
not a claim that the full generated corpus has passed.

Hosted catch declarations now use the ordinary eligibility and formal binding
paths. `l2_rw_catch_stmt` restores scope with common enter/leave; native scope
recognizes direct P0 Structure operands without a catch-name branch. Numeric
catch cells stay uncached. The original catch/break/continue witness gives 105;
new payload and repeat witnesses prove 3→7, 3/5→7/9 and restored outer formal
(final 20), with real walker execution and PAD aliasing its canonical cell.

Legacy pointer slots retain the type from `L2Declaration/contract` and emit
through `l2_pointer_decl_text`. Machine-local assignments use the common
checker and existing model metadata. Opaque raw-C results no longer masquerade
as integer literals; C checks their machine receiving type, while Structure
targets still execute runtime admission. Compatible/incompatible `c.memmove`
descriptor candidates and the old `entry_index`/`entry_strcmp` pass their
positive/negative expectations. Ordinary numeric zero bindings, nonzero
literals, wrong primitive pointer types, lost const and wrong depth refuse.

Three deliberate source mutants fail: lost catch scope restores the wrong
value (83 rather than 20); the old slot type refuses legal char* assignment;
removing the shared checker accepts int*←char*. Mutations were restored before
the final gate; evidence is in `catch_pointer_20260930_mutant`. The first
`catch_pointer_20260930_final` stopped on an L1 nested-body cutter syntax error
before building; it is not a successful gate. The final2 restart includes the
correction. All twelve new fixtures match its staged bytes.

```text
translator blob 3c3dc506b53c0feec78f375b6f85d261560a1503
translator SHA256 24ABDF253083192AC34DC0FEF9165FC4D1969FD45676EC9136B258174F23D0F5
harness blob 3403e78cf6be0ef22e933aba0f63416814f11f6b
harness SHA256 4474122C95A930B4E269C2EAC99A4C52FB97CED72D3BAFBFD3A00FEDD6AF0E5D
```

Still open: full canonical body/copy identity, explicit `once\catch\x` walker
path, direct initializer `@: char p @a`, and complete C99 integer constant
expressions/literal forms. The null witnesses cover `0`, `0U`, `(0)` and `-0`
using the existing literal decoder, not a new constant-folding engine. Two old
unregistered sources are not positive coverage: `unit_ptr_local_scope` still
has a valued void-root return and `unit_unsigned_ptr` lacks its int→size_t
receiver; `_04` records those independent diagnostics.

<a id="observer-migration-verified-boundary"></a>
### Graph observers: migrated, one production failure exposed

The safe 19 stale observer rows and two root-merge rows now check relations in
the executable graph. Eight fixtures have success 7 rather than a zero that
could also result from skipped execution; their negative checks remain.
`Get-WalkGraphFacts` uses executable statements, final effective writes and
opcode-directed operand/body traversal. A value stored inside LIT is not code;
allocation parenthood does not prove attachment. CALL/EXEC use their respective
runtime code-selection contracts. Void calls explicitly require no result;
valued calls still require their real result-cell reference.

Final evidence under `build/l2_harness/`:

- `observer_migration_20260930_final02`: **24 targets, one failure**;
  20 of 21 selected fixtures pass. `unit_root_merge_three_operands` remains red:
  native exits 3 at stale generated check 72; the real walker half exits 0
  after satisfying the expected language result 7. Do not turn this into an
  expected failure or weaken parity.
- `observer_consumers_20260930_01`: **14/14**, including eleven existing
  GraphCalls/PadAliases/WalkedMethods consumers.
- `observer_migration_20260930_04/observer_mutants.txt`: **15/15 observer
  checks** (four baseline checks, valid ordinal renaming, ten negative
  mutations). Detached/orphan, CALL-inside-LIT, commented attachment, late
  overwrite, code/receiver/result/argument edge, opcode and next-role changes
  are detected.

Harness SHA256 `B0586F5141D02F22E043BFDA00A29AB7CEC70147501E37612FDB1C38D75B10C5`.
Production translator remains blob `3c3dc506b53c0feec78f375b6f85d261560a1503`;
no production edits were part of observer migration. The reported executable
hash `601D350E…2196` is the pinned **L1 bootstrap translator**, not a freshly
self-built L2 executable. Parent verified terminal summaries/hashes and clean
diff before handing source/build ownership to the merge-emission repair.

Next repair removes the unconditional merge post-success self-tests and their
dead declaration-literal metadata, while preserving real merge failure,
admission and result binding. Nine existing result-check pins need actual
runtime identity/value observations. Reading live value 6 in the unchanged
root witness after removal is required; the static audit alone does not prove
the native merge result correct. Full generated and clean-kernel gates remain
pending.

### Bounded runtime checkpoint ca2f1cd

The independently verified runtime slice is separated from translator WIP:
`lmx_chars`, `lmx_value_owned` and its corrected accessor-contract header,
`lmx_graph_copy_owned`, `lmx_walk`,
`lmx_implements` and its header; the three affected runtime selftests;
`tools/l3_type_budget.py`. All nine kernel source/test files were rechecked
byte-for-byte against `mapped_cycles_20260930_01` before staging. The final
L3 run above uses the same executable runtime bytes; the corrected header
comment is included in both fresh isolated ca2f1cd gates above. The isolated
kernel count is 278 rather than the WIP's 280 because the translator-only
metadata header is absent; all 104 runtime selftests still run.
The changes remove the admission
depth-32 and holder-depth-256 cutoffs, retain mapped correspondences across
cycles, and separate C99 numeric char reading from intern-table byte indices.
This development checkpoint does not promote stable `l2src`, publish the
unfinished translator, or certify the full generated harness. Mixed C99
arithmetic and the representation repairs below remain open.

The twelve migrated generated tests remain with translator WIP, not in this
runtime commit. They replace obsolete root-only refusals/global temporary
ordinals with actual output, argument/result/receiver graph relationships,
and a non-null native root. In-memory mutants fail for the missing property;
renumbering temporary variables remains valid. The root FOR row was expressly
left red because it lacks the graph, despite its correct native result.

The full harness's 112 failures split initially into 37 generated-text
assertions, 51 diagnostic-text mismatches, 17 newly accepted former-refusal
rows, one missing expected note and six missing-L1 results. This is a failure
classification, not permission to rewrite expectations wholesale. Of the
51 diagnostic mismatches, 42 are preempted by a void-callable return-with-value
diagnostic. Read-only source review confirmed the root really has no result
and the common guard is correct; this is not permission to replace all 42
expectations. One is a genuine root-return negative, thirteen are raw-C/string
tests with invalid legacy tails, four put a range check in a void root, ten
involve unknown-head/withdrawn construction semantics, and fourteen require
purpose-specific repairs. Remove invalid test scaffolding while retaining
the original observation; do not weaken the common void-result guard.
Four no-L1 cases reach the real `graph assignment admission requires
receiving-expression tests` gap. The other two encounter static admission
failure and also contain withdrawn implicit-copy setup.

Even green old rows are not proof of current semantics: the `unit_bind_*`
family still includes executable `Model: b c` / `Model: fresh` construction.
Conversely, do not migrate by fixture name alone: the current
`unit_fresh_instance_skipped_decl` and `unit_recursive_fresh_instance` exercise
activation/reentry, not the withdrawn model constructor. Preserve their
behavioral purpose. The 1503-source frozen diagnostic aggregate is
cf124130a927ed68474da7462f3a904b45649509ee5aa015e965b122c8befa9f.

Mapped admission uses one operation-local traversal with pending/cached
correspondences for both providers. Back-edges retain those correspondences;
unvisited siblings still undergo admission, and failure does not publish a
cache entry. All 231 staged kernel source files match the live bytes in the
green runtime run. Aggregate staged-source SHA256:
5475b1c099ed630510914065122925ced8dad2888e5b840b8bd8d23dd774ac3d.

## Definition/body role clarification

[Q58](../LMX_blog/q/current/q58.md) asks about an already known ordinary
callable nested in a new named Structure. The earlier audit suggestion that
a generic `definition contents` label alone resolves Q57 was insufficient:
the rule deriving that role is the missing fact. Ignoring outer bindings
would also destroy Q52 hidden-input assignment and ordinary saved calls.
Do not decide using empty/nonempty tails, argument count or surface syntax.
The author has been asked; no speculative resolver replacement is authorized
by this note. Independent gates and repairs with settled semantics continue.

## Pending regression migrations and runtime defects

- Verified WIP negative-fixture batch: `entry_puts_after_return`,
  `unit_lit_range_arg_int_overflow`, `unit_s1_throws_entry_unhandled_refused`,
  `unit_bare_unknown_refused`, `unit_discard_unknown_refused`,
  `unit_callable_descriptor_direct_refused`, `unit_callable_formal_sig_refused`,
  `unit_colon_unknown_value_refused`. Only the first changes to the common
  void-callable diagnostic; the others discard the tested call/expression or
  remove the invalid valued root-return tail, retaining their own intended
  rejection. `native_diagnostics_20260930_final` passed 11/11 targets; eight
  valid counterparts in `native_diagnostics_20260930_mutants_03` passed the
  same frozen L2 → L1 → C syntax/constraint pipeline. All eight negative
  fixtures were restored exactly; 128 staged L2 source files match live bytes.
  Translator SHA256 remains
  `691E7F9D74DEDB3AF26F91FFC214DDF6730AAA5ED32FD256375EF588E5BD2F0B`;
  harness SHA256 at this gate is
  `9EFC527FA99EA015E487A68A24E58E5473327FAC7C22A46924BB2AACB667FC07`.
  This is diagnostic specificity, not runtime acceptance of the positive
  counterparts. The first catch-based positive attempt exposed separate
  RETURN-ABI-EMPTY-HANDLER defects, recorded in defects.md; the final
  unhandled-throw counterpart removes the callee's throw instead of asserting
  catch correctness. Those generator defects were repaired in the next slice
  below, independently of the negative-fixture migration.

### Void return ABI and empty generated bodies

`build/l2_harness/return_abi_empty_20260930_final2` is GREEN 27/27:
24 fixtures plus build/scope rows; all 142 staged inputs and all fixture bytes
match live. It includes the eight diagnostic rows and four root-hosted controls.
The three new fixtures cover ordinary and status-ABI exits, publication,
fallthrough, real throw/handler effects and empty or pure-discard bodies.
They require `-Werror=return-type`, native attachment and native/walk-root
execution; the plain sub witness also executes with method natives cleared.

`l2_emit_empty_return` chooses the resolved ABI success return. Empty output
ranges are materialized as an L1 empty Structure only when the generated
control/handler scope needs a body. A native prelude already contains code;
putting an extra `()` after its declaration instead triggers L1 repeated-
declaration inheritance. The output-layout requirement is not source syntax
or an E-specific language rule.

Both old-emitter mutants fail the intended C/L1 constraints. Removing the
early return or the actual throw gives exact exit 81 instead of 7 in both
modes; requiring 81 in a control row then passes. Reproduction and logs:
`return_abi_empty_20260930_runtime_mutants/run.ps1` and sibling mutant runs.
Final translator SHA256
`7A4A380C00FB2F55750329C1CC32BDE6E85818696ACE26AD9C635860712A14D1`,
blob `9d5fc38fed49153379a3718493cf0d2a5f6cc79e`; harness SHA256
`4BD1F5CAE3E9A43ECA89E728EB4DBC3AF5A12F4A429548BA8998B4B6EC07DF20`.

The earlier expanded run was 27/28: `unit_s1_catch_user_break` repeats the
pre-existing missing-text assertion from `resumed_full_20260930_01:244`.
That row was not relaxed; the final bounded run excludes this unrelated
text-observer debt. Empty `sub` trailer attachment is also still OPEN in
defects.md; the final tests do not claim to exercise that parser behavior.
The new full generated diagnostic `after_return_full_20260930_01` has the
terminal result recorded above; it remains red for the remaining dependencies.

### Remaining regression migration

- Frozen audit of the 29 generated-text failures distinguishes real graph
  omissions from names that merely shifted. `unit_root_merge_three_operands`
  and `unit_root_merge_body` each contain both ordinary native merge calls
  and two retained PUT_REF(PRIM_PUB(`lmx_walk_merge_map`)) sites. Their
  `l2_mops` is a native activation-local operands array, not a forbidden
  permanent data graph; old Absents came from interpreter-only entry
  lowering. Replace those Absents with relation-aware native/walker merge
  site/order/result/identity checks, not a ban on ordinary native scratch.
- `unit_s1_catch_user_break` instead has no retained operator graph at all:
  shared walkability classification rejects supported catch-parameter
  storage. See CATCH-FORMAL-RETAINED-GRAPH in defects.md; preserve its
  failing graph observation until the common path is repaired. This is an
  independent prerequisite, not a reason to wait for canonical-body merging:
  numeric catch fields already use the same PAD/canonical cells, and the
  common cache policy already makes them direct OF/PUT_OF accesses. Remove
  the eligibility exclusion and restore catch scope with the existing
  enter/leave mechanism; require native/actual-walker payload mutation,
  repeated delivery and scope-restoration witnesses. Graph-copy identity
  is still a separate dependency.
- `unit_make_adder` needs a captured-cell identity witness: an ARG/OF/NODE
  graph and a correct numeric result alone cannot replace its former AT
  claim. Tie this to the capture/copy repair rather than substituting one
  observed opcode for another.
- Six other rows still use withdrawn implicit-copy setup: `unit_a3_capture_direct_vs_copy`,
  `unit_walk_struct_formal`, `unit_root_model_field`,
  `unit_colon_method_lexical_model`, `unit_field_path_unit_colon`,
  `unit_matrix_callable_struct_identity`. Migrate setup to explicit merge
  while retaining their capture, snapshot, formal and path invariants;
  coordinate with settled head resolution, not a mass expected-output edit.
- Nineteen text-observer rows have matching operators/roles/typed inputs
  under different temporary or slot identifiers. Replace literal `l2_rwN`
  and slot pins with opcode/arity/edge relationships plus their runtime
  results. Require attachment to the tested executable sequence, not merely
  the presence of an orphan frame. The legacy `unit_walk_inputs`,
  `unit_walk_recursion`, `unit_walk_loop`, `unit_walk_trailer` and
  `unit_walk_mixed` still use success exit 0: their migration must also change
  the success witness to a nonzero result/explicit marker while preserving
  failure branches, so a skipped body cannot pass. This extends the necessary
  scope beyond harness text alone. The make-adder native-note exists, but its reason changed;
  assert a stable located boundary plus the actual native word, not the
  transient mixed-arithmetic refusal as a language requirement.
- Raw-C bad argument/arity/nested-call fixtures must not run. Preserve their
  emitted C and verify its constraint diagnostic with the target compiler
  (`-fsyntax-only -Werror=int-conversion`), not name-specific L2 validation.
  Current generic `toolchain-refuses` flags can leave an object after an
  integer-to-pointer warning, so they do not yet prove this property.
- `unit_discard_calls` needs explicit `node\hits` writes and graph observation
  to prove discarded-call side effects. Bare hidden-input writes correctly do
  not update the root; do not change language semantics to satisfy its old
  expected number. `unit_addr_slot_structure_projection` still demands obsolete
  `Lmx**` semantics and is not eligible for a mechanical success flip.
- `unit_value_call_sub_refused` asserts an obsolete no-result-callable argument
  policy. Current semantics passes that occurrence by reference; receiving an
  int still requires compatible conversion/admission. Do not retain the blanket
  value-call rejection as proof of the current argument rule.

- Remove the old callable-versus-reference distinction in
  `unit_value_formal_call_refused`; `(Model: v)` and `(@: Model v)` are
  reference-transport synonyms in signatures only.
- Migrate executable implicit-copy setup `Model: fresh` to explicit
  `fresh: merge Model`, retaining copy independence and per-activation tests.
  Do not mechanically change the identical spelling inside signatures.
- Old `A: b c` alias/admission fixtures must use explicit `@: A b c`, not
  merge: a copy would destroy the identity property those fixtures test.
  Keep known-head calls with unknown arguments as call errors, not fallback
  declarations. Add Q57 graph-and-effect witnesses at multiple positions.
- Mapped-cycle admission is published at the intermediate runtime checkpoint
  `ca2f1cd` and gated above; it is not a clean-kernel checkpoint. Preserve the positive and negative
  cycle/sibling/cache witnesses when integrating the remaining translator work.
- Built-in mixed machine arithmetic must follow target C99 promotions and
  operations. The walker still rejects some different promoted types. Fix
  common operand typing separately from receiving-place conversion/admission;
  do not silently use host widths or the Message conversion table as an
  arithmetic operator dispatcher. Native/interpreted parity is required.

## Acceptance

§8 requires maintained L3/L2 sources for runtime, parser, both translators,
build/test/finalize tooling. Generated L1 is allowed before C. Bootstrap once
from tracked generated C; build, test and replace the binary; repeat with the
successor. Two actual successful generations, no handwritten L1 dependency,
historical binary fallback or PowerShell/Python stage in the accepted cycle.
The old run_self_build 8/8 is only a handwritten-L1 fixed point.

§8a follows §8: post through ordinary call/admission/result semantics over the
same mailbox. T01–T26; one ask to three routes = 1 execution/1 reply/3 deliveries;
three asks to three routes = 3/3/9. No second queue, resolver or graph.

## Current repairs and evidence

- E now has the ordinary void native body/trampoline/native word.
- Native compilation does not erase the executable graph. Supported E bodies
  use l2_rw_methods_count/emit, l2_occ_expr and l2_m_width. No separate E loop.
- Send metadata is keyed by owner and source statement. Graph/native emission
  use one l2_msend helper; the root-only registry/counters were removed.
- Callable-result initializers use l2_check_call, restoring D105 admission maps.
- Typed own-reference binding uses admission, as locals/formals do. Letter
  payload extraction follows grouping and explicit reference expressions.
- Dynamic calls and named-Structure hidden inputs share typed arena-cell
  materialization. A stack pointer is not a typed address for the walker.
- Literal/dynamic size_t array indices share native load/store emission.
- The implemented-body predicate includes callable-result constructors whose
  return is attached to the result-signature Frame.

Focused evidence under build/l2_harness:

| Run | Result |
| --- | --- |
| s7b102 | 9 fixtures; reference admission still failed |
| s7b103 | 7 reference/capture fixtures passed; 10 targets including infrastructure |
| s7b104 | 5 of 6 fixtures passed; held char remained |
| s7b105 | Unknown focused-fixture name rejected; no fixture evidence |
| s7b106 | 9 graph/native/reference/capture fixtures passed; 12 targets |
| s7b107 | Dynamic index and T7 constructor passed; held char exposes Q55 |
| s7b108 | Full harness: 959 targets, 105 failed; stale root-only expectations and genuine remaining gaps must be separated |
| s7b110 | 6 focused fixtures, 9 targets passed: C99 char capture/results and range checks, signed int/size_t controls |
| s7b112 | 4 focused fixtures, 7 targets passed: char callable formal, dynamic index, two L2 OOB translation-only witnesses |
| s7b113 | Full Windows runtime kernel gate: 278 targets, 103 self-tests, no failures |
| s7b114 | Full L3 runner: 11 suites and 4-unit type budget passed |

OnlyFixture is labelled diagnostic scope and cannot certify a full gate.
The full generated/kernel/L3/docs/diff gates remain mandatory.

Changed expectations: unit_next_message_loop expects 5 by answered Q53 (inner
receiver declares another m); unit_throwing_callable expects 1,1,2 by Q44
(merge copies mutable occurrence/state, shares only the native implementation).
The s7b101 null-instance experiment was an overbroad declaration skip through
l2_root_ref_row, not proof that Model:m construction itself was broken.

## Remaining clean-kernel dependencies

### C99 primitive meaning and Array indexing (Q55 answered)

The author requires C99 target types, including plain char signedness. Remove
unsigned numeric reads of char, but retain byte-index normalization for the
intern table. Check native/walker arithmetic, admission and captured results.
Array length comes from its descriptor. L2 performs no bounds checks. L3
checks only the final flattened index against total length, not each axis;
do not add runtime dimension lengths to the base descriptor. A rectangular
Array and an Array of Arrays remain distinct. See LMX_blog/q/q55.md.

Initial Q55 WIP witness: q55_char_kernel_s2 compiles the kernel and links
lmx_walk_lt_signed_selftest; direct execution of its Windows .exe passes
268 checks, 0 failures, 0 construction errors. The Python diagnostic runner
reports a missing extensionless output even though GCC creates .exe; its
aggregate verdict is NOT a green gate. The standalone older run_walk_selftest
runner lacks lmx_call linkage and is also not a green gate. Required Windows
kernel/generated/L3 gates remain pending. Numeric getter, cross-arena intern
copy and char arithmetic promotion are tested; full conversion/call coverage
and profile range admission remain work, not a completed Q55 checklist.

Read-only source audit: length already reads the descriptor. Walker ELEM and
ELEMPUT check the final index. Native lowering currently loses the source
operation's L2/L3 level and always emits unchecked access; the test knob is
not a language-level selector. Retain the actual level before adding native
L3 checks. Rectangular flattening is absent; two nested ELEM nodes currently
mean two separate Array descriptors. l2_array_literal and l2_arr_operand also
reject static OOB indices in L2. Translation-only witnesses must not execute
undefined C accesses. Do not remove Structure-slot validation as an Array fix.

### General receiver composition (Q56)

The author's clarification supersedes the proposed Array-specific residual-type
scanner. Ordinary nested receiving expressions must share one resolution path;
`[]: []:` is not a special grammar or another Array kind. Replace the existing
shape recognizers, not just their depth limit. `length` consumes the ordinary
resolved operand. The author settled sequential paths as `a[i]\[j]\[k]`,
distinct from flat C-like `a[i][j][k]`; do not recover or infer rectangular
shape. Detailed code boundaries and
acceptance: [general receiver resolution](receiver-resolution-20260930.md).

<a id="c99-expression-types-versus-arena-storage-domains"></a>
### C99 expression types versus arena storage domains

Q55 already determines machine-type semantics; distinct arena pools do not
introduce distinct C types. In particular, `size_t` must resolve to its target
C-compatible base type for integer promotions and usual arithmetic conversions,
while a declared size_t cell can retain the `LMX_TYPE_SIZE_T` storage domain.
Canonical-equal C types take compatible assignment, before consulting the
primitive conversion table. Do not use equal widths as proof of type identity.

The current profile has widths/spellings, not a verified alias/rank relation.
The implementation route is target-compiler compatibility probes over the
ordinary C99 integer declarations, consumed by one arithmetic type resolver
shared by translator and walker. No header scanner or C-name registry. A target
using an extended integer type needs corresponding toolchain metadata, not
a guessed standard rank. This is implementation work, not a request to change
the author's rule. The already determined int/unsigned/ulong and char promotions
can be repaired independently; evaluate after casting both operands to the
resolved C type, not in a size_t scratch type. Pin result domain and value in
native/walker witnesses, including unsigned wrap and signed/unsigned comparison.

<a id="one-complete-lexical-graph"></a>
### One complete lexical graph

Common E graph emission restores the supported subset, NOT full acceptance.

First bounded repair is now verified WIP: E uses the existing hosted numeric
field and `l2_rw_enter/leave` paths, with the duplicate root-only
`l2_rw_cblk[64]`, its catch search and comments removed. The previous
`unit_root_for_refused` omission did not justify accepting a native-only
success: the updated test requires retained FOR/OWN_OF/SET_OF frames.

`build/l2_harness/root_hosted_graph_20260930_final`: 30/30 targets GREEN,
27 fixtures including all twelve preceding native-gate migrations. Four
fixtures (`unit_root_for_refused`, `unit_root_hosted_controls`,
`unit_root_deepif70`, `unit_root_hosted_catch`) run the same generated binary
twice. The test-only driver first asserts a nonzero compiled root native word
and a nonempty physical operator graph, then clears only the native word for
the second run; ordinary dispatch selects the walker. Observations cover sum6,
nested counters/break/continue, sibling scopes, size_t 4294967296, actual
hosted-field path reads/writes, nested catch and 70 nested if bodies.

Four assertion inversions in `root_hosted_graph_20260930_mutants` failed with
the intended value mismatch in both modes. All were restored before the final
gate. Translator, driver and four source fixtures match the staged evidence
byte-for-byte. Translator blob `1e2a3d4dbad948777a58cd4b3b5d0820a4a364ae`,
SHA256 `691E7F9D74DEDB3AF26F91FFC214DDF6730AAA5ED32FD256375EF588E5BD2F0B`;
driver blob `7fec045240d613ce05cfa16b6021ad8c2b22b32e`;
harness at this run `919668593c4fe2e475918b0683286938ac97239a`.
These are focused WIP results, not a full generated-suite verdict or a pushed
translator checkpoint. Genuine root no-formal/no-lexical-parent distinctions
remain. This repairs one omission, not the duplicate-body/layout defects below.

1. l2_m_kids + l2_m_steps still puts data before an operator tail. Consolidate
   unit_base+i/ns_base+rank/mres_base+r formulas into physical location helpers,
   then assign existing own_uchild/own_fchild/for_uchild metadata in source order.
   Root source is l2_cur_unit, not filtered l2_e_fields.
2. l2_emit_unit/l2_emit_local_bodies allocate canonical source control bodies,
   while l2_rw_body allocates another step-only lmx_walk_plain. Populate and
   execute the same canonical body. No field-only or step-only companion.
3. lmx_walk_body already scans mixed children and skips non-operator cells.
   No runtime execution-order/name index is needed.
4. Implement missing operator representations instead of deleting the graph
   on quiet walker refusal. Preserve lone string expressions too.
5. Capture/merge/T7 consumers must stop assuming that a prefix contains all
   data. Use common graph-copy identity handling for canonical body references.

Witnesses: lexical ordering, retained operator/literal graph after native
execution, same L3 graph executed with its native word cleared in a test, and
M\while\j resolving to the exact body executed by WHILE.

#### Next dependency-closed identity slice

Canonical body identity can precede lexical-order reallocation, but it cannot
be a translator-only pointer substitution. Preserve current field slots while
recording body-step counts in existing compiler body metadata; allocate the
single `l2_for_node` body with space for its existing children and operators.
Both `l2_emit_local_bodies` and unit-builder allocations must use that width.
Replace `l2_rw_body`'s step-only `lmx_walk_plain` with population of, and a
reference to, that exact source body. Top-level method/T7 bases need not move
in this bounded slice; their eventual lexical-order migration remains open.

The same slice must repair `lmx_walk_load_code/load_node`: preload only
executable operator children and the body operands defined by IF/WHILE/UNTIL/
FOR/PAD, plus ordinary owned expression operands. Do not walk arbitrary
lexical descendants or preload an uncalled nested callable. A canonical
body's structural parent is not the operator referencing it, so the old
`child.parent == operator` test alone misses its working cells.

`lmx_copy_value` currently retains a whole Structure whenever its head is an
OP/ROLE record. Remove this extra terminal shortcut: ordinary frames use the
existing operation-local copy map, while bare OP/ROLE records remain admitted
terminals. Require copied operator.body == copied path-selected body, both
different from the original, and a copied hosted cell; native implementation
and bare role identity remain reusable. Update obsolete K-OT1 shared-frame
expectations by name. Capture constructors (`l2_mad_emit`,
`l2_emit_mad_construct_one`) and T7 frame-pack reconstruction are separate
bypasses not certified by ordinary-copy tests; they must then use the same
complete instance construction/copy contract before global graph acceptance.

### Every statically known executable body compiled

Capturing nested methods are still stubbed by l2_emit_body_in and excluded
from native-word/trampoline emission. Existing explicit+hidden ABI suffices:

1. Emit actual bodies using l2_cap_dyn_add/l2_dyn_add and l2_emit_sig.
2. In native trampolines share l2_rw_arg_fb's resolution: supplied hidden input
   wins; absent input reads its lexical declaration through self.parent.
   Explicit formals do not acquire this fallback.
3. Share captured Structure type/admission-map lookup with native paths:
   l2_cap_arg_ns, l2_node_seg, l2_d105_emit_slot.
4. l2_mad_emit and l2_emit_mad_construct_one preserve the matching native
   implementation for unchanged bodies. Remove walker-subset prerequisites.

Use make_adder, a3_caller_binding, a3_node_path/direct, capture_struct_* and
typed-result twins, with actual native-pointer assertions. Existing success
can still be walker-only success.

PAP/T7 additionally needs the already-decided steps/merge-callable-r48.md
S2 → S4 → S3 repair: preserve full formal interface; merged values are defaults,
not removed formals. Receiving signature is an admission constraint, not
another operand. Do not attach the original native address to today's reduced
incompatible signature. Explicit y=25, y=0 and a later omitted y must give
26, 1 and the original default result 6.

lmx_graph_copy_owned preserves native, but lmx_merge_owned still clears the
result root unconditionally. Current L2 §13 and the semantics book/Q44 already
require preserving the applicable implementation. Preserve the matching
unchanged body's implementation, never blindly the first operand's address
after code replacement.

## Concrete §8 route after clean-kernel

1. Make separately compiled L2 libraries actually executable: current
   l2_emit_library_wrappers sets l2_library_unit=0 and fails open.
   unit_lib_pair_a/b prove LINK/SYMBOLS only; require actual 41/42 results.
2. Fix the common runtime construction ABI: library open currently opens a
   root, root needs List, and a ported List would open another root.
   profile:runtime only suppresses polling. No List-name exception.
3. Replace lmx_list_owned and declarations with L2; link without its old body;
   run growth/removal and child/root/mail consumers.
4. Port dependency-closed runtime groups: storage/arenas/pools →
   values/arrays/graph → copy/merge/admission/calls → mail/Thread/root →
   walker/L3 interpreter. Maintained .h.lm1 also counts as handwritten L1.
5. Port current P0/owner/text; existing .lm2 fragments are not a complete parser.
   Large failed ports were removed in 01f56f3. Gate without the L1 parser oracle.
6. Port both l2trans and the L1-to-C translator; test successor translation.
7. Port buildCore/make/finalize and gate logic, not old shell-script generation.
8. Prove two self-replacements from the tracked generated-C bootstrap.
9. Implement §8a on ported ordinary call/mail/admission layers, T01–T26.

ALL LANGUAGE RULES ARE UNIVERSAL WITHIN THEIR DOMAIN. Do not invent special cases; report a genuine contradiction to the author in Russian before choosing new semantics.

# Remaining kernel work through stages 8 and 8a

This is the restart plan requested on 2026-10-01. It replaces the **active queue**
of [next_core_tasks.md](next_core_tasks.md), not its historical evidence. It stops
at full L3/L2 self-build and ordinary calls over Message transport. Application
development is outside this document. The original documentation handoff paused
code work; its subsequent resumption is recorded in [steps/current.md](steps/current.md).
The author's 2026-10-02 list below stands in front of `critical_graph_bug`. That ticket stays the first implementation defect after those steps.

This is a plan, not a language specification or a claim that unchecked features
work. Norms are in [L3 semantics](docs/LMX_semantics.en.md),
[L2](docs/L2_spec_en.md), [L1](docs/L1_spec_en.md) and
[grammar](docs/LMX_grammar.en.md). Read it with the
[v2 dictionary](next_core_tasks_dictionary_v2.md),
[kernel map](CORE_L2_L3_v2.md), and
[porting guide](L2_L3_CODING_INSTRUCTION.md).

<a id="before-critical-graph-bug"></a>
## Before critical_graph_bug — acceptance still required

Author's list, 2026-10-02, inserted in front of the ticket. These are the
missing acceptance steps. They do not replace the ticket and do not mark it
closed.

- [x] В harness нет декодера графа, который сверяет структуру с исходником и не зависит от временных имён и старых номеров слотов.
  Driver fact `shape … endshape` names roles, primitive cells, `spell`, `add A B`, `body`/`endbody`, and `fields`/`endfields`. It does not read `l2_rwN` names or old slot numbers. Witnesses: `graph_shape_unknown_atom`, `graph_shape_add`, `graph_shape_value`, and `graph_shape_fields` (Holder's ints 1 then 3, native and walked, `regress_ns_19`).
- [x] Нет прогонов, где успех виден по значению, а не только по тому, что перевод прошёл. Сюда же входят нативное исполнение и проход через walker.
  `graph_shape_value` on `graph_shape_14`: `n: 2 + 2` then `exit_code: n`. Both the native run and the walked root exit 4.
- [x] Нет контрольных поломок: стереть выражение, передвинуть объявление, схлопнуть два вхождения. Каждая должна ломать структурную проверку даже при том же коде выхода.
  Shown on `graph_shape_12`: `graph_shape_mut_erase` (`mutate erase-add`), `graph_shape_mut_move` (declaration after the expression), `graph_shape_mut_collapse` (two `SET` nodes aliased). Each driver exit is 1 because the shape check fails, and the launch exit stays 0.
- [ ] Не запускались ворота из раздела 6: полный l2_harness, build_l2src, run_l3_selftest, check_docs. Прежняя полная прогонка была красной, 36 из 1149.
  `l2_harness` `critical_graph_bug_full_08`, uncommitted translator: RED 37 of 1159. The 36 baseline texts match `full_05`; the extra pin is green in `regress_ns_47`. `build_l2src` `critical_graph_bug_04`: GREEN 286, after the short direct call. `run_l3_selftest` `critical_graph_bug_02`: all 11 suites exit 0. The `LmxUseLeaf` type is withdrawn; the budget pin is back to 74 names and has not been re-measured. The harness row stays red, so this acceptance item stays open.
- [ ] В тикете нет строки DONE. Правка транслятора не закоммичена.

<a id="first-critical-graph-bug"></a>
## First action — critical_graph_bug (CRITICAL / P0, OPEN)

- [ ] **Complete [critical_graph_bug](steps/tickets/critical_graph_bug.md)
  before choosing another remaining implementation item in this plan.**

Author's explicit priority, 2026-10-02. This promotes the concrete graph-loss
defect from K10 to the front of the active queue; it is not deferred until the
later K10 section and does not repeat already completed K01–K04 slices.

Required result: the source determines the graph's structure and field order,
and that source structure is recoverable from the retained graph. Receivers
may create initialized typed cells at their source-defined places; this does
not permit moving declarations ahead of instructions or removing expression
contents such as `(2 + 2)` because their results are discarded.

The ticket owns the detailed evidence, repair boundaries and acceptance.
Closure requires independent structural assertions and mutation controls in
addition to native/walker execution checks. Correct exit values alone do not
close it. Respect the current writer/build owner and preserve their WIP;
arrange a safe handoff, not a second writer or an interrupted gate. Only after
this ticket is closed take the pointer-depth repair below, then the reference
application refactoring, before resuming the remaining dependency queue.

Active slice of this ticket, not a detour:
[2026-10-02-01-known-call-layout](steps/tickets/2026-10-02-01-known-call-layout.md).
A direct `A: b` stores the callee once. The argument is the ordinary `OWN` of
`b`, not a leaf on `int: b 5` (`regress_ns_48`, exit 5). Unknown `A: b` stays a Structure. The
node is still a `CALL`, and the contract still hangs on the method. The slice
stays open. `critical_graph_bug_full_07` is RED 36 of 1159, the same 36 texts
as `full_05`. `build_l2src` `critical_graph_bug_04` is GREEN 286 on the short direct call.
`graph_shape_call` after both call layouts still exits 5 (`regress_ns_43`).
A direct call with fewer than three arguments and no catch is only the callee
and those arguments (`regress_ns_46`).
`critical_graph_bug_full_08` is RED 37 of 1159: the same 36, plus one stale
width pin that `regress_ns_47` then matched. Those 36 stay the baseline; they
are not a second ticket.

<a id="critical-pointer-to-struct-bug"></a>
## Second action — critical_pointer_to_struct_bug (CRITICAL / P0, OPEN)

- [ ] Complete [critical_pointer_to_struct_bug](steps/tickets/critical_pointer_to_struct_bug.md)
  after critical_graph_bug and before any reference-application refactoring.

A is held as a reference (conceptually Lmx*); @A addresses the real cell holding
it (conceptually Lmx**). Remove the descriptor-specific address-level erasure
from native and walker lowering, including formals, paths and Array descriptor
references. No C-valued language Structures, temporary address targets or hidden
ABI boxes. Migrate the false A/@A argument-synonym tests and exact-depth admission.
This is an existing bug, independent of the following new rules. The ticket
owns source anchors, positive/negative/mutant witnesses and full release gates.

<a id="structure-reference-application"></a>
## Third action — Structure/reference application refactoring (OPEN)

- [ ] Complete [structure_reference_application_refactor](steps/tickets/structure_reference_application_refactor.md)
  only after the preceding pointer ticket closes.

For absent b, b: A and @: b A are equivalent assignment forms. Afterwards
b: args applies the selected Structure under its actual callable contract;
@: b B explicitly reassigns the reference. Preserve repeated declarations and
the source-body construction rule; do not infer object identity from reference
storage or erase source occurrences. No extra nominal Type entity or implicit
merge. Unary @A still adds an address level; it is not the @: receiver.
Ordinary named Structures acquire no formal arguments. Resolve once and migrate
all consumers; a call failure never becomes assignment. This stage is a
refactoring to accepted rules, not a claim that the current code supports them.

<a id="snapshot"></a>
## 0. Snapshot and what must not be called complete

The starting documentation/source baseline is `f980dce`, containing the
native-dispatch repair `621e8af`. The last complete pre-merge generated-program
run has **1,100 targets: 1,052 OK and 48 FAIL**. Its kernel run has 286/286
targets and 106 self-tests; the separate L3 run has 11 suites and 295 checks.
Those are different suites, not contradictory counts. Green kernel unit tests
do not make the 48 generated-program failures disappear.

The final status of the released `MERGE-RESULT-VALUE-PROJECTION-20261001` slice
is recorded in [its release record](steps/native-selfbuild-20260930.md#merge-result-value-release).
That record, including the exact source hashes, final counts and commit, is
the authority for the handoff boundary; intermediate focused runs are not a
replacement for it. A passing focused run does not certify a full clean kernel.

The source checkpoint is now `8359a59`: focused and restored runs 48/48;
full generated run 1110 targets, 1062 OK, the exact same 48 failures; kernel
286/286; L3 11 suites/295 checks plus four budget controls. Ten new generated
rows pass, with no regressions. This is the starting code snapshot for the v2
handoff, not completion of the clean-kernel dependencies below.

Already repaired bounded mechanisms include actual declared-cell addressing,
whole-Array descriptor projection, common reference initialization/rebinding,
source-site visibility, reference-value transport, re-entry publication, and
dispatch/stop handling for the tested native/walker call routes. Their detailed
boundaries are in [the source/evidence ledger](steps/native-selfbuild-20260930.md).
Do not implement these again from an older checked box; extend the shared
mechanism where a remaining case fails.

The 2026-10-02 pointer ticket explicitly reopens the descriptor-address
exemption: previous bounded gates do not establish that @Structure adds the
required reference level. The two new front stages remain unchecked.

The current merge slice removes the phantom global result namespace for its
supported static operands, stores results at ordinary declaration places,
preserves composed schemas and real expression-host parentage, and corrects
retained-result provenance. It does **not** close arbitrary held/formal/dynamic
operands, general expression receivers, or all Consumer selector projection.

Still not established:

- A full generated-program run with no unexplained failures.
- Complete support for current declaration/call/reference and receiver rules.
- Source-complete executable graphs and native compilation of every required
  body, with no singleton/module-context shortcut.
- General unbounded receiver composition and all Array paths in both engines.
- Executable, independently instantiated L2 libraries suitable for the kernel.
- A kernel and toolchain whose maintained sources contain no handwritten L1.
- Two language-driven self-replacements with tests.
- The complete stage-8a `post` and shared-mail acceptance matrix.

<a id="workflow"></a>
## 1. Restart protocol and acceptance discipline

1. Read `AGENTS.md`, `READ.ME`, `steps/current.md`, this plan and the dictionary.
   Inspect HEAD/upstream, status and worktree ownership. Preserve unrelated WIP.
2. Read the current merge release record. Reconcile its exact file manifest
   with Git before assuming it landed. No second writer/build beside a live one.
3. Follow the mandatory front queue: critical_graph_bug, then
   critical_pointer_to_struct_bug, then structure_reference_application_refactor.
   Afterwards choose one dependency-closed remaining item below. Name files,
   symbols, witnesses and exit conditions. Independent
   read-only review may run in parallel.
4. First reproduce the defect or record it honestly as source-traced only.
   A translator crash is not a language diagnostic; a compiler error is not a
   runtime negative; clearing only root `native` does not prove a nested method
   ran in the walker.
5. Repair the common resolver/projection/operation, then migrate every caller.
   Remove superseded helpers in that same bounded slice. No parallel fallback
   path, source-name exception, or extra persistent graph.
6. Run focused positive and negative witnesses with meaningful observations.
   Counterfactual/mutant checks must fail for the intended reason; record
   observer-only checks separately from actual runtime-mechanism mutants.
7. Run the relevant full generated, kernel, L3, documentation and whitespace
   gates on the exact bytes to be committed. Compare failures by exact fixture
   ID, stage and diagnostic, not just aggregate counts.
8. Commit explicitly listed paths and push. Record implementation, evidence,
   residuals and the next dependency. A bounded improvement may be published
   with the disclosed old red baseline; it is not the clean-kernel checkpoint.

No destructive Git shortcuts and no `git add -A`. Local generated binaries,
scratch manifests and ownership markers do not belong in source commits.
Do not silently promote dev into stable while full gates remain red.

<a id="projection"></a>
## 2. Semantic-use projection dependencies

### K01 — Preserve selector identity through admission and access

**Problem:** `ADMISSION-OCCURRENCE-SELECTOR-COLLAPSE` in
[defects](steps/defects.md#admission-occurrence-selector-collapse).
Required `x,x` and candidate `x,x,x` make bare last-`x` and explicit `[1]x`
coincide in the required layout but differ in the candidate layout. A map keyed
only by required physical slot cannot encode both.

Work:

- Preserve each source use's selector (LAST, explicit occurrence N, or an
  already physical runtime path) from common resolution to the used-edge plan.
- Make analytical admission, read, write, address and capture use that same
  resolved edge. Do not repair reads while leaving admission on another edge.
- Keep correspondence caching distinct from the current Consumer's permission
  to use an edge. Unused incompatible fields must not reject a legal Consumer;
  a later Consumer using them must still be checked.
- Preserve explicit physical permutations supplied by runtime clients. A
  physical path is not a same-index or same-name shortcut.
- Replace fixed-size compiler use-path storage with ordinary growable metadata,
  not a larger constant or a runtime name registry.

Read first: `l2_uses_path_add`, `l2_cap_fields`, `l2_d105_pair`,
`l2_d105_emit_slot`, walker OF/PUT_OF, `LmxImplEntry`, and the common
`L2SchemaField`/`L2ReferenceSource` projection. The precise metadata layout is
an implementation decision still to be validated, not a new language rule.

Acceptance: native and genuinely walked read/write/address/capture of candidate
values 10/20/30; LAST selects 30 and `[1]` selects 20. A candidate with an unused
incompatible first field passes last-only consumption but fails a Consumer
using that first field. Test both admission orders and repeated calls. Preserve
the old explicit runtime-permutation tests. Replace the old 65-use refusal
fixture by successful 65-plus-use coverage and a failure on an actually used
incompatible edge, not by deleting the witness.

### K02 — Finish ordinary merge values on top of K01

- Project the **actual operand**, not an explicit reference's declared model.
  `A{x}`, `B{pad,x}`, reference-to-A holding B must copy/project B's real fields.
- Support formal operands, runtime-selected B/C operands and prior results
  through the same value path. No hidden Structure representing a compiler
  schema and no permanent registry for merge instances.
- Restore caller-local → inherited input → lexical fallback for a free merge
  result. A global result-name lookup must not bypass a dynamic input.
- Support the existing `b: merge A C` form and merge in ordinary receiving
  expressions, including return, under the general receiver mechanism. A
  destination name is not a first operand, and a `return` receiver is not an
  own-field declaration.
- Finish unchanged-code native retention and actual-body replacement rules;
  data changes alone must not force interpretation or retain mutable originals.
- Preserve copy graph cycles/sharing, real host parent, one evaluation per
  operand, qualifiers and all-or-no-result publication on merge failure.

Acceptance: different actual layouts, reads/writes/@, subsequent admission and
merge, formal and hidden inputs, caller priority and lexical fallback, native
and walker. Include a correctly typed structural return and a genuinely
incompatible primitive return. The present “merge expression is not lowered in
this receiving context” is an implementation gap, not normative prohibition.
Do not treat the historical `unit_t7_from_int` shape-parser diagnostic as proof
of either argument order or result-type correctness.

<a id="calls"></a>
## 3. Complete the common head, callable and reference routes

### K03 — Definition, application and assignment everywhere

Implement the already accepted Q56/Q57/Q58 roles uniformly at file root, in
methods, nested Structures, anonymous bodies, formals and receiving expressions:

- Reserved receiver → its general contract; it cannot be shadowed.
- Unknown ordinary head in definition position → named Structure containing
  the written body, not inference of a primitive and not an immediate call.
- Existing callable Structure head → ordinary call; an unknown actual or failed
  admission remains a call failure, never a declaration fallback.
- The general call check uses the **resolved value's** contract, not the spelling
  `A: B`. An ordinary named Structure has only a body and no arguments, so
  supplying B to that value is an arity error; fn/fm/sub use their declared
  signatures. Do not add explicit arguments to an ordinary named Structure.
  See the author's [Q59 clarification](LMX_blog/q/q59.md).
- Existing primitive → assignment after conversion/admission. A held Structure
  reference permits ordinary application b: args; explicit reassignment uses
  @: b B. For absent b, b: A and @: b A are equivalent.
- Explicit dereference → referent value, then ordinary operation on that value.
- Signature descriptions do not execute; structural reference formals are not
  a construction shortcut in executable bodies.

Remove the old `Model: fresh`/`T: b c` implicit-construction recognizers only
after migrating their legitimate setup consumers to explicit definitions,
references or merge. Do not replace them with name-specific refusals.

Acceptance includes equivalent completed surface forms; unknown `f()` defining
empty f versus known f() calling; `C: makeA()` with both names unknown; Q58's
known nested `put: 7` retained without definition-time execution; method arguments
and ordinary rejection of arguments to a resolved argumentless Structure;
empty and nonempty definition bodies; explicit @: reference assignment versus
ordinary application through the reference; declarations without return/trailer;
no source-name or root-only branch.

The current diagnostic “a call of a named Structure with an argument is not
built yet” records a real refusal but gives the wrong reason after Q59. Replace
it through the common resolved-call contract check, not a new syntax-specific
ban and not implementation of invented arguments. The frozen merge slice's
negative fixture is category evidence only until that diagnostic is migrated.

### K04 — Callable actuals and hidden inputs

Complete `CALLABLE-FORMAL-HIDDEN-CONTRACT`, `SUB-ACTUAL-REFERENCE-CLASSIFICATION`,
`CAPTURED-STRUCTURE-ADDRESS-CATEGORY`, and related cases in
[callable projection](steps/callable-actual-projection-20260930.md).

- A selected actual callable supplies its own explicit/hidden/default/result/
  throws contract. Do not marshal the required exemplar's hidden-argument list
  into an incompatible actual adapter.
- Apply caller-source precedence to each actual free input, including ordinary
  Structure, Array, pointer and callable references, not only numeric inputs.
- Preserve callable-formal receipt by reference; a no-result `sub` is not
  coerced to an integer result or automatically executed as an argument.
- Preserve descriptor-only `fn` as a legal signature anchor with no fabricated
  body; direct invocation refuses appropriately. No new descriptor registry.
- Formed arguments, defaults, Consumer uses, result and declared exits use one
  admission path. Do not require equality of unrelated unprepared interfaces.

Acceptance: actual with an extra free input; equal counts but different hidden
names; caller override and lexical fallback; defaults do not persist a previous
call's supplied value; compatible/incompatible callable formals; whole callable
identity and exact self; both execution engines and stopped-call propagation.

### K05 — Remaining reference/path/address defects

Close `LOCAL-REFERENCE-PATH-ROOT`, `NESTED-CALLABLE-OWN-FIELD-PATH`, omitted
primitive-initializer handling, and remaining local declaration-site identity
cases. Do not infer zero/null primitive initialization from compiler storage
convenience. Recheck current code before replaying any old defect description.

Addresses must select real value storage: the cell holding a Structure/Array
reference, primitive cell, Array element or pointer-value cell as appropriate.
`@p` adds
depth to p, not to the referent silently. Address-taking does not newly dirty a
working cache. Complete ordinary explicit paths at arbitrary depth, without
special root/body/node routes or a copied return value as address destination.

<a id="arrays"></a>
## 4. Receiver composition, Arrays and C99 semantics

### K06 — General receiver composition, not a nested-Array recognizer

Replace positional recognizers in declaration collection, own/named/formal
typing and lowering with one application result consumed by later phases.
Read [receiver resolution](steps/receiver-resolution-20260930.md).

Required invariants:

1. `a: b: c: d: ...` has no fixed language depth. A receiver consumes its own
   arguments; `int: i 5` is not automatically synonymous with `int: i: 5`.
2. `[]: []:` is ordinary receiver composition, **not** a separate two-dimensional
   or array-of-arrays construct, special runtime kind, parser scanner or type
   table. What an Array stores does not alter the algorithm of `length`.
3. C-like `[][][]` flat rectangular construction remains distinct.
4. `a[i][j]` selects in one flat rectangle using the source-known stride;
   `a[i]\[j]` selects the Array value from the previous step, then indexes it.
   `s\[N]name` selects a named occurrence; `a\[i]` has no name and is Array access.
5. Interim typed bindings `[]: []: b a[i]` and `[]: c: b[j]` also follow general
   receiver rules. They are not compiler macros for two particular depths.

Acceptance: depth 1, 2, 3 and a deeper generated case; varied receiver and
element kinds, declarations/formals/returns/paths/@/length; mixed Structure
fields and Array hops; literal and computed indices; compiler phase agreement;
native/walker equivalence. Testing a larger depth is a witness, not permission
to add a new hard maximum there.

### K07 — Preserve the minimal Array and level boundary

- Base typed Array is `{size_t len; T *data}`; `VoidArray` uses `size` and
  `void *data`. Lmx embeds the actual `VoidArray` first, then parent/native.
- No capacity, resize, append, backing replacement or growth policy is added
  to base Array. DynamicArray/List is a distinct implementation using it.
- Rectangular `length` is total elements. The descriptor holds no rank/shape
  vector; no `shape(array)` or `rank` promise is being postponed to the future.
- L2 access is unchecked C99-like access. L3 checks the final linear element
  against the selected descriptor. It does not validate every coordinate or
  store every dimension length for bounds checks. Repeated `\` hops each use
  the newly selected Array, not a guessed rectangularity flag.
- Built-in numerical element types retain target C99 meaning. Char is not
  silently redefined as unsigned. A typed Array of references still has ordinary
  elements; it is not a flat matrix.
- Strings/mainArgs are char Arrays of exact logical length, **without** a
  trailing NUL. Conversion to a C string is explicit at the raw-C boundary.
  Process letters have an ordinary declared Structure contract, not a contextual
  type or a table recognized only by the launcher.

Acceptance: flat `[2,3]` linear equivalence `[0,3]`/`[1,0]` in L3; final index
outside total length rejected; no dimension-wise rule substituted. Vary row
lengths in separately referenced Arrays, length at each selected descriptor,
empty Arrays, direct element addresses in L2, primitive/reference storage and
char exact-length/C-string boundary. Do not execute undefined L2 out-of-bounds
behavior just to claim that bounds checks are absent; inspect lowering instead.

### K08 — C99 expressions, foreign values and pointer cells

Close `C99-COMMON-ARITHMETIC`, `RAW-C-TYPE-PROVENANCE`,
`C99-POINTER-CELL-ALIASING`, `FOREIGN-VALUE-MEMBER-PROJECTION` and
`NONTHROW-AGGREGATE-STOP-ABI` through common typing/ABI operations:

- C99 promotions and usual arithmetic conversions precede typed operations.
  Arena storage kinds do not replace the C type system. A size_t typedef is
  compatible with its target base type, not simply with every equally wide type.
- Pointer-value conversion does not license incompatible pointer-cell aliasing:
  converting `int *` to `void *` does not make one cell both `int **` and `void **`.
- Foreign aggregate value member projection uses the correct value category,
  not `->` solely because ordinary Lmx Structures travel by reference.
- A stopped call's result is not consumed; a nonthrow C aggregate return must
  not emit invalid `return 0`, invent a language throw or fabricate a dummy value.
- Every `c.*` token passes to C as a raw identifier. Ordinary arguments still
  follow L2 lowering. No header-derived raw-C-name allowlist, semantic C-name
  dictionary or special
  puts/sizeof/array handling. `sizeof:` is the separate language receiver.

Ordinary processing of explicitly written `.h.lm1` ABI declarations and import
dependencies remains necessary. It is not the forbidden attempt to discover
and authorize raw C names by scanning platform headers.

Acceptance: mixed numeric types and signedness native/walker; comparisons,
arithmetic and short-circuit effects; pointer cell read/write/@ identity under
the actual C optimizer; foreign by-value access; stopped aggregate callees;
unrelated arbitrary raw-C identifiers; no name-specific hidden fallback.

### K09 — Remove compiler limits as semantic restrictions

Inventory fixed method/formal/field/path/uses/send-site/header capacities.
Replace compiler metadata storage through an ordinary reusable dynamic
container. Do not just increase 64 to 128, suppress budgets, split a unit to hide
the limit or turn overflow into a language refusal. Real allocation/resource
failure is distinct from an invented language limit. Keep regression witnesses
above each former threshold. L3 budget checks remain useful until the limits
are genuinely removed; adjust expected source inventories with evidence.

Include runtime traversal limits in the same inventory: current
`LMX_GC_DEPTH = 64` and legacy `L3_DEPTH_MAX = 64` are not language graph-depth
rules. Replace fixed-depth traversal with the appropriate ordinary cycle-aware
mechanism and verify a graph deeper than the old bound, cycles and shared
targets. Do not merely raise constants, create another graph or drop those tests.

<a id="graph"></a>
## 5. Complete graph, working state and admission infrastructure

### K10 — One complete lexical graph, one occurrence-based dispatch

**Priority override:** its confirmed graph-loss defect is now
[the first task](#first-critical-graph-bug), not a later cleanup. Record the
ticket's evidence here when closed; other K10 obligations remain independently
subject to their acceptance below.

- Declarations, typed value storage and executable operators retain lexical
  placement; no pure-data companion, callable-context graph, permanent load
  graph or a graph generated only for root.
- Definitions of named Structures are inert until called. Anonymous executable
  bodies run under their receiver. If/loops are control bodies in the current
  activation, not separate procedure calls or new node bindings.
- `node` remains the above-method lexical space, not nearest control parent.
  Ordinary structural parent links can differ inside a method.
- Compile every statically known body intended for execution. Dispatch always
  examines the selected occurrence's native word; absent native uses its real
  L3 body. A complete interpreted body remains useful when native is absent.
- Preserve the complete binary/operator tree and diagnostic source-name/comment
  information. Do not claim this is done solely because current walker ops run.
- Headless expressions, atoms, anonymous multi-field bodies and empty Structures
  are consumed in order. Unused results go to the existing typed temporary
  `l2_tN`/equivalent expression destination, not a new persistent discard ring.

Audit both current interpreter surfaces: generated typed `lmx_walk` and the
older `dev/l3_interp/l3_exec.lm1` immediate-write subset. A green suite for the
latter does not prove the former's cache/checkpoint behavior, or vice versa.
Remove obsolete semantic divergence through the shared implementation; do not
port an old subset as if it were the complete current interpreter.

Acceptance: Q58, named/anonymous distinction, root and nested bodies, complete
retained tree before/after execution, mixed `(f: 1; f: 2; 2 * 2; f)` witness with
normal name resolution, empty/literal expressions, skipped branches, no fabricated
return/trailer requirement, calls through copied/merged occurrences, native and
walker status/result/state equivalence. Test source retention separately from
successful execution.

### K11 — Working-state and publication matrix

Keep declaration storage distinct from an activation's cached working value.
Only admitted bare writes dirty the applicable own field. Assignments to
explicit/hidden inputs remain local and create no graph field. Direct paths or
addresses modify the real selected cell without secretly reloading the cache.
Checkpoints publish only pending admitted fields; they do not redo admission,
publish clean fields or turn a failed turn into successful outgoing mail.

Recheck call/foreign boundaries, argument evaluation order, recursion, re-entry,
cleanup, return/throw/diagnostic/yield, and non-checkpoint loop transfers. Retain
the approved ordering and no automatic reload. Separate field write-back,
construction-result availability and Message publication in tests and docs.

### K12 — Full implements/conversion/table path

Use Consumer-relative used paths, ordinary primitive conversions and actual
candidate structure. Conversion to a pointer is primitive; structural fit is
implements. Do not create per-user-model primitive types or conversion rows.

Port the complete previously specified primitive-conversion direction table and
ordinary L2 table construction, not merely the subset current examples need.
Inventory old implementation against the accepted current contract before porting;
old code is evidence, not permission to restore superseded semantics. Tables are
ordinary Structures; columns are formal descriptions and rows argument chains,
not a private CSV format, hardcoded filename or root-only input path.

Keep analytical admission distinct from Consumer unit-test execution and from
cached correspondence. Cover the fourteen documented admission recipes and
remaining unit_colon/unit_eternal cases by a current manifest: count actual
reachable fixtures, do not reuse the historical number 17 as proof. No separate
RuntimeImplements decision tree and no test result masking analytical failure.

<a id="clean-gate"></a>
## 6. Clean-kernel checkpoint — mandatory before stage 8

The three front stages (critical_graph_bug, critical_pointer_to_struct_bug,
structure_reference_application_refactor) must be closed first.
All of K01–K12 are dependencies,
not necessarily twelve large commits. Split them
into bounded shared-mechanism slices, with exact witness matrices. The remaining
48 generated failures must each be classified and resolved against current norms;
use [the diagnostic ledger](steps/generated-diagnostic-migration-20260930.md).
Changing an expectation requires a cited accepted rule; do not weaken runtime
observations into compile-only successes.

Acceptance checklist:

- [ ] No unexplained generated failures or silent skipped source operators.
- [ ] Focused negative tests diagnose the intended category; positive tests
  visibly execute and observe the actual state, identity and dispatch route.
- [ ] Full L2 kernel, L3 suites, generated harness and type-budget checks green.
- [ ] No old parallel resolver, header-derived raw-C allowlist, special name, arbitrary depth
  cap, hidden graph or stale documentation/test expectation remains in scope.
- [ ] `check_docs`, generated-source checks and `git diff --check` green.
- [ ] Stable/dev convergence uses the tested dependency closure, not a partial
  file copy that silently combines different ABI generations.
- [ ] Exact commit pushed; source/artifact manifests identify the tested bytes.

Current validation tools, until replaced by language-owned tooling:

```powershell
python tools/check_docs.py
git diff --check
# Supply a verified absolute L1 translator and its actual SHA256; no guessed pin.
powershell -NoProfile -ExecutionPolicy Bypass -File tools/l2_harness.ps1 -Translator <exe> -ExpectedTranslatorSha256 <sha256> -Provenance -KeepAll -OutDir <absolute-evidence-dir>
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_l2src.ps1 -Translator <exe> -ExpectedTranslatorSha256 <sha256> -Run -Strict -KeepAll -OutDir <absolute-evidence-dir>
python tools/run_l3_selftest.py --translator <exe> --output <absolute-evidence-dir>
```

Angle-bracket arguments are placeholders, not runnable shell values. Run one
build chain at a time from the intended checkout. The harness stages dev sources;
verify that staging and predef resolution in its evidence. A named output folder
without a completed manifest is not proof. The tools above build/check the
current transition; running them alone is **not** stage-8 self-build.

<a id="stage8"></a>
## 7. Stage 8 — full L3/L2 self-build without handwritten L1

### S8.1 — Executable library and ownership boundary

Existing separately compiled library tests prove LINK/SYMBOLS, not a running
independent unit. Finish construction in an explicit owner arena and invocation
of the selected unit instance using ordinary dispatch. The investigated
[owner-supplied construction ABI](steps/native-selfbuild-20260930.md#proposed-owner-supplied-library-construction)
is a proposed implementation route to validate, not a new language abstraction.

Remove generated singleton arena/unit dependencies through existing invocation
context and ordinary resolved free/captured references. No temporary root whose
arena dies after wrapper return, nested `lmx_root_open`, replacement of
`current.message.graph`, invisible module field, or unit inferred from the
topmost parent. Carry the existing owner arena through native invocation where
needed; do not create a library-only execution class.

Run one owner with A1/A2 instances of the same library and B1 of another, mutable
state and interleaved expected results such as 41/41/42/42/43/42. Require separate
unit identities, persistence, unchanged owner graph and one final owner close.
Include a copied callable using a sibling/qualified reference. Mutants for
singletons, constant stubs, shared instance state, nested root and premature
release must be detected.

### S8.2 — List/DynamicArray in L2

Port the existing distinct dynamic container, its declarations and consumers.
Do not add growth to base Array. Build/link without the old L1 List body; run
allocation, growth, removal, address/lifetime and child/root/mail consumers.
This step depends on S8.1 because a List library cannot initialize by opening
another root whose own construction needs List.

### S8.3 — Dependency-closed runtime ports

Inventory every maintained body **and header** in `dev/l2src_sandbox`, relevant
`l1src`, and `dev/l3_interp`. Group by actual dependencies:

1. Storage, common dynamic containers, address ranges, arenas and pools.
2. Primitive cells, typed Arrays, Structure construction and qualifications.
3. Copy/merge, common admission/conversions, callable invocation and exits.
4. Mail, Message/Thread, routing, scheduler, roots, collection and close.
5. Walker and L3 interpreter/profile implementations.

For each group keep an inventory row: old source → maintained L2/L3 source,
generated L1/C outputs, imports, tests, old-body removal and exact checkpoint.
No handwritten `.h.lm1` left out of the count, disguised C in generated strings,
link against old hidden object/archive, or dual authoritative implementations.
L2 supplies only necessary machine primitives; ordinary algorithms should be
expressed in L3 when its contract suffices. Port semantics, not C control-flow
accidents, and keep native/walker conformance for all L3 portions.

### S8.4 — Parser and both translation stages

- Port current P0, ownership/text/token storage and diagnostics as a complete
  dependency closure. Existing parser fragments are not the full port.
- Gate parser conformance against current goldens, historical agreement as a
  separate result, and exact empty/container normalization. Do not use the L1
  parser executable as the final self-build oracle.
- Port the L2/L3 compiler and generated-L1-to-C stage themselves. Common
  resolution/schema/use plans must survive the port; do not recreate ad hoc
  declaration recognizers in a new source language.
- Build successor translators and run the same source programs through them,
  including errors, native/walker routes and complete graph preservation.

### S8.5 — Language-owned build and test orchestration

Port buildCore/make/check/finalize, dependency ordering, tool invocation,
artifact checks and internal test orchestration to maintained L3/L2 sources.
Generating a PowerShell/Python script and letting it own the build does not
satisfy this step. The platform C compiler/linker and OS are legitimate external
tools; the language program must orchestrate the ordinary build/test cycle.

Keep the minimal tracked generated-C snapshot and one-time platform bootstrap
separate. It may build the first binary on a new platform; it must not recur
inside ordinary successor builds or kernel edits. No untracked old binary,
downloaded translator, seed archive or developer-local path is an undeclared
dependency. The previous worked buildCore is a reference to investigate, not
evidence that today's tree already does this.

### S8.6 — Two actual self-replacements

1. From the documented platform bootstrap, build generation G0.
2. G0 builds the whole language toolchain/kernel from maintained L3/L2, runs
   the required tests and safely replaces the working executable with G1.
3. G1 repeats that complete process and tests, replacing itself with G2.
4. Record source commit, tool identities, generated intermediates, commands,
   test results and actual executable replacement for both generations.

Generated `.lm1` remains allowed. Maintained handwritten `.lm1` in the kernel,
translator, parser, header closure or internal orchestration does not. Artifact
comparison is useful additional evidence; byte-identical executable files are
not an invented mandatory condition. Retain logs proving which generation did
the work. Windows results establish Windows only; Unix or other targets remain
unverified until actually exercised.

<a id="stage8a"></a>
## 8. Stage 8a — ordinary calls over the existing Message transport

Begin after the accepted S8 checkpoint. The normative contract is
[ordinary transported calls](docs/LMX_semantics.en.md#thread-message-api);
the detailed implementation assignment and its existing test IDs are
[threadMessageAPI](docs/new_parts/threadMessageAPI.en.md) and
[send/receive migration](docs/new_parts/threadMessageAPI_migration.en.md).

### S8a.1 — Common substrate, dependencies only downward

Keep explicit `sendMessage`/`receiveMessage`, their arguments, status/iterator
behavior and terminal 0. They and `post` reuse existing mail enqueue/take,
ownership/attach/publication and ordinary call/admission. No send→post→send
cycle, second queue, second resolver or postal type system. Receive binding
follows the general receiver/declaration contract, not a special visibility law.
Preserve direct-mail tests and prevent the same queued letter being consumed by
two independently invented paths.

### S8a.2 — Preparation and sender-owned wait state

Prepare `ask`, `answer`, `timeout`, `undelivered`, `unanswered`, `catch` through
ordinary Structures and conversion/admission. Waiting state belongs to the
sender and references the original letter/arena, not invented request IDs.
`answer` adds a wait/result route, never a public callable API entry. Validate
answer destinations at preparation using the Message conversion context.
Nested `ms: int: time` must work through common receiver/formal support, with
data path `timeout\ms\time`, not a special timeout type or `int` data node.

### S8a.3 — Calls, results and explicit multiplicity

Invoke the addressed Structure once under ordinary LMX rules. Unrelated
compatible methods are not enumerated. Distribute the one original result to
the explicit answer destinations. One request/three destinations gives **one
execution, one original reply, three deliveries**. Three requests gives
**three executions, three original replies, nine deliveries**. No synthetic
reply for an intentionally no-result sub. Preserve out-of-order correlation
through original identity; no reply ordinal/total protocol.

### S8a.4 — Events, lifetime and scheduling

Use existing clock/deadline operations, starting timeout at actual sending,
not preparation. Sender-side handlers execute on the sender's ordinary lane;
the recipient performs the ordinary call. `undelivered` sees the already formed
original arguments. `unanswered` may merely log; timeout neither cancels the
call, drops a late result nor frees its live wait automatically. Declared
failures go to ordinary matching catch. Preserve Message success and outgoing
publication; no extra timer thread, global listener registry or new call mode.

### S8a.5 — Required T01–T26 observations

| IDs | What must be observed, not merely linked |
| --- | --- |
| T01–T03 | Local/transported result, selection, admission and empty/bodyless-call parity |
| T04–T06 | Wait-only answer preparation, independent live instances, owner-local lifetime |
| T07–T09 | No compatible-method scan; sender-side route failure; real conversion failures |
| T10–T12 | 1/1/3 and 3/3/9 counters; out-of-order original-message correlation |
| T13–T14 | Original undelivered arguments and declared failure payload |
| T15–T19 | General nested receiver typing; no unit/name exceptions; timeout setting distinct from handler input |
| T20–T22 | Timeout from send, late result retained, one mailbox take, correct event trigger |
| T23–T24 | Final-send publication and execution-path parity |
| T25–T26 | Explicit multiplicity without hidden target enumeration; no-result sub without synthetic ACK |

Keep the detailed expected observations in the linked matrix; do not replace
them with this summary. Count executions, original replies, deliveries and wait
entries separately. Mutants for a second source execution, answer-as-method
publication, timeout-from-preparation, double-take and dropped late reply must
be rejected. Rerun self-build and ordinary-call/mail regressions after the port.

<a id="done"></a>
## 9. Completion record and stop condition

The requested destination is reached only when the clean-kernel checkpoint,
S8.1–S8.6 and S8a.1–S8a.5 each have exact pushed implementation and runtime
evidence. A large document, a green parser, a linked library, a kernel-only gate,
or an L1 compiler rebuilding handwritten L1 is not that result.

For each completion record state: source revision and owned paths; norm used;
implementation symbols; exact positive/negative/mutant commands and outputs;
native versus genuinely interpreted coverage; source/staging/commit hashes;
remaining unsupported cases; successor dependency. Update this plan's status
without erasing the historical counterexamples. On a real unresolved language
contradiction, file a minimal Russian question in `LMX_blog/q/current/`; completed
questions move one level up. Plan tickets are not questions to the author.

The original documentation-only pause is historical; the resumed work follows
the current ownership instructions and the first-task priority above. This
priority update does not start another writer/build or claim that stages 8 and
8a have already been achieved.

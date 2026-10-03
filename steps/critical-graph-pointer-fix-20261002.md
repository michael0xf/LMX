# Critical graph / Structure-address repair: implementation evidence

Date: 2026-10-02. Owner: Codex, sole writer/build.
Baseline: `main` / `origin/main` at `84181df8` when implementation resumed.
Scope: the author's request to implement the two repairs described in
[the repair plan](../plan_critical_graph_bug_critical_pointer_to_struct_bug_fix.md).
This is implementation evidence, not normative language semantics.

**Both critical tickets remain OPEN.** Development changes are in
`dev/l2src_sandbox/`; the stable twins have not been updated. Grok's inherited
uncommitted changes have been preserved. There is no graph release, pointer
release, clean-kernel certificate or self-build claim.

## 1. Completed bounded changes

### G0: the merge handler witness actually enters its handler

`unit_body_path_merge_pt` now uses the existing harness `MergeFail=1` injection,
as `unit_s1_catch_merge_local` already did. No merge-language rule was changed.
The previous value 64 meant that a successful merge had not entered the catch;
it did not establish a defect in the handler's field storage.

Fresh gate `build/l2_harness/critical_graph_fix_g0_01`:
7 targets, 0 failed. It includes `while_pt`, `until_pt`, the existing local
merge catch and the corrected `merge_pt`. The first two execute 13 checks;
the catch witnesses execute 14 each. This closes that witness problem only.

### G1 subset: structural assertions and genuine graph mutations

The driver's old four-level stack and sixteen-object observation cache have
been replaced with storage sized from the expectation token count. This is
a bound on one test's storage, not a language nesting/occurrence limit.

New assertions read actual typed values and operand slots before execution.
`shape exact ... endshape` disables the old search-ahead inside call, publish,
method and nested containers. `fields/endfields` inspect each selected
Structure's ordered physical children, including operation heads, null slots,
OWN targets and literal candidates. A close fails when unread children remain.
These expectations do not use generated L1 temporary names.

The new mutations alter the constructed graph, not the source fixture:

- swap same-type declaration values;
- erase an initializer's source role;
- redirect its OWN operand to another existing int field;
- move the initializer across a later ordinary assignment;
- change its literal candidate from 5 to 77;
- alias the nineteenth empty occurrence to the eighteenth in a 24-child body.

The mutated programs still send their expected constant exit letters. Their
structural assertions fail, so an unchanged effect/result cannot pass them.
Harness `Source` aliases reuse the positive fixture's exact source bytes.

This is **not** the complete canonical decoder required by G1/G4. Legacy
coarse `shape` rows still exist and are not certified exact. Name/comment
reconstruction, complete Array contents, shared/cyclic reference comparison
and P0-to-canonical-source comparison remain to be implemented.

### Initializer identity without a primitive wrapper

Removing declaration initializer actions would change established order,
skipped-declaration and re-entry behavior. Existing typed storage is retained;
the existing executable operation gets a shared source-role head distinguishing
an explicit initializer, an implicit declaration action and ordinary assignment.
Its execution opcode and operands are unchanged. The existing `LmxOp.code`
word encodes the source family and the dispatch projection uses the base
opcode. No per-cell metadata, extra primitive leaf, Lmx member, second data
graph, copied initializer value or history is created.

The common `l2_rw_stmt` wrapper applies this to nested statement emission too,
including a for initializer. The receiving declaration must own the exact
original name token of the resolved own row; deriving a possible syntactic
contract is not enough. Ordinary named bodies own their head token, not that
receiving-name token, and are not passed to the operation marker.

This still leaves a materialized cell and its initializer action as physical
pieces of one declaration. A canonical decoder must group them by the actual
target/source placement, not report two independent source fields or guess
by spelling/type. The exact witness verifies their present targets and
candidates; it does not establish universal declaration grouping.

### Owned zero-operand returns

All three generated empty-return producers now build the ordinary width-one
RET operation Structure: a bare return statement, an empty return Frame, and
a return trailer. They no longer insert the shared RET role directly into
the containing body's first slot. The operation-count result is unchanged.
`l2_rw_put` uses the existing root-aware container-name helper for both root
and nested parents.

A plain body beginning with a bare RET role was previously misclassified as
an operation by head-based consumers. Graph copy could consequently share the
whole body as code, and physical field access could reject its holder. The
new kernel witness checks distinct copied bodies/cells, an addressable later
field, and a graph-side mutation restoring the former bare-role shape.
An operation Structure is not a wrapper around a primitive declaration cell.

### B0: one hosted-body address relation for both backends

`L2GraphPlace` is translation-owned information: a stable linked child edge,
its method, and a parent edge. It is seeded once after the existing final
layout. Native emission follows those edges into machine pointer aliases;
`l2_rw_host_at` emits its existing AT/OF expressions from exactly the same
edges. The selected occurrence remains the root, not its lexical parent.

The old `-2/-3` shell encoding is decoded only by this seed adapter for these
two consumers. Other old layout consumers and the shell objects themselves
still exist. This step neither moves source fields nor claims to have removed
the old graph layout. All rows and the fid index use counted allocation and
are freed through `l2_for_free`, including partial-allocation failure cleanup.
No runtime object, permanent source metadata or duplicate data graph is added.

### B1: own cells and external body paths use the same places

Translation-only `L2GraphField {holder, child}` now feeds native own-cell
addresses/cache, walker reads/writes/cache, static cells and catch parameter
aliases, schema/capture slots, and external paths through hosted bodies.
The backends no longer independently decode the `-2/-3` placement encoding.
Initial packed layout is seeded before source analysis because that analysis
itself resolves paths; the relation is reseeded after source placement.

This does not repair the old constructors. They still produce packed bodies
and shell objects; the adapter describes those actual objects without inventing
new graph nodes. The existing fixed path-vector limit is also not removed by
B1. General source topology and elimination of the old producers remain G2.

### B1 constructor dependency: use the already allocated physical holder

The new catch regression exposed a real build-order error, not only an old
temporary-name assertion. Manual execution of the unchanged generated artifact
from `critical_graph_shared_fields_03` failed with INVALID in both backends:
the PAD fetched a catch cell through its final graph path before the enclosing
WHILE edge was linked into the graph. The actual catch object already existed.

`l2_emit_graph_build_place` now projects that construction-time reference to
the existing allocated holder alias selected by the common GraphPlace identity.
It does not traverse unassembled ancestor edges or create another object.
The existing catch canonical-cell assertion remains strict. Local named-body
procedures are not global-constructor allocations and are not falsely treated
as available here.

### Predefined result types: inverse projection into value types

`l2_result_value_ty` converts the result-contract codes into the established
expression-value codes when an outer predef lookup succeeds. Recursive header
parsing keeps contract codes unchanged. The former mutable `char *` result
was mistaken for the expression code of `const char *`.
The unchanged `unit_lm_own_actual_span` manually links its actual `own.lm1`
support object and now exits 10 with 13 checks. The harness row is explicitly
translation-only until the harness can link that dependency; it is not reported
as a runtime harness gate. Structure/void/unknown result refusals are preserved.

### B2: the file root is not erased by a source name

`l2_unit_from_root` returns the actual parsed file Structure. It no longer
unwraps a sole Structure named `L2` or refuses ordinary names `L1`/`L3`.
The outer profile comes from the source file, not these names. Forty-six
current sandbox fixtures have been mechanically converted from obsolete
profile wrappers to the already normative wrapperless form. Historical and
stable sources are unchanged. Grammar source and both generated languages
now describe this same rule; quoted historical examples stay intact.

The sole `L2` fixture checks the exact retained container and int value 7.
It has an empty executable root and deliberately uses the established empty
program convention (`EmptyEntry`, expected host exit 1). It is a construction
witness, not execution-parity evidence. Separate `L1`/`L3` fixtures execute a
field read and exit 7 in native and genuinely driver-cleared root walking.

### G2 first content axis: one recursive source-container traversal

`l2_source_inert_container` replaces the former one-expression/child-zero
filler. COUNT, PLACE and FILL use its identical traversal of the actual P0
Structure. Each expression span occupies its next normalized source place;
each nested anonymous container occupies its own next place and recurses.
PLACE determines widths and links for the existing physical container objects.
FILL reuses their existing aliases and gives new expression applications the
actual containing object as parent. It neither uses execution-step counts as
source width nor allocates a second body or fixed-depth buffer.

The native inertness optimization now conservatively excludes every body with
a trailer. It may omit machine work only when there is no trailer to consume;
it is not a structural decoder and cannot erase a nested UNTIL/return through
this filler. Full trailer construction remains with its existing handlers.

Exact witnesses compare multiple expressions, nested empty/nonempty bodies,
six expression-bearing nesting levels, and the same body inside a method and
after its return. Both method fixtures really use `--walk-methods` for method
zero, not only a cleared root. The erase-expression mutant has a good baseline,
successful setup and structural failure while its program still exits 7.

This is a common content constructor in the migrated domain, not completion
of G2. Selection of source placement is still conditional; native-only/local
named procedures, other control bodies, definition placement, CALL protocol
containers, names and comments have not all migrated. Their old producers
must still be removed, not hidden behind this green subset.

### G4 bounded copy repair: operation Structures are not terminals

`lmx_copy_value` no longer shares an entire Structure merely because its
first child is an OP/ROLE record. Every reached ordinary Structure now uses
the existing allocation/map traversal. Bare terminal records, qualified
profile retention and the existing opaque pointer-cell pointee policy are
unchanged; `native` remains a shared implementation address carried verbatim.

The same-arena counter and explicit-holder witnesses check fresh operation
Structures, rewritten immediate parents and distinct typed cells. Executing
the copied explicit writer changes the copied target to 42, not the original.
The interpreter witness also copies across owners, preserves two aliases and
two explicit-holder edges to one copied target, releases the source owner,
then executes the copied graph again. Interpretation gives 43; a real nonzero
native entry gives 44 and observes the copied `self` and lexical parent.
Role records belong to a separate still-live owner imported into both arenas.
This is not evidence that releasing the owner of borrowed roles is safe.

The witness stops if its own copy-isolation assertions fail, before executing
or releasing potentially shared source applications. This makes restoration
of the old sharing branch a deterministic negative control, not a permitted
use-after-free. It also checks that two distinct equal index cells are not
collapsed. These are test checks, not new production defensive mechanisms.

This repairs ordinary graph copy, not the whole G4 stage: source-name/comment
codec, merge/capture reconstruction and full topology are still open. It does
not implement the pointer-depth ticket.

## 2. Focused evidence

All gates were executed from `C:/Nyasha_Planet/LMX`, sequentially, with fresh
absolute output paths and PowerShell's actual `OnlyFixture` array.

| Evidence directory | Verdict | What was measured |
| --- | --- | --- |
| `critical_graph_fix_g1_02` | 8 targets, 0 failed | Different int values, a true value-swap mutation, depth-six containment/copy, existing method shape rows |
| `critical_graph_fix_source_roles_02` | 10 targets, 0 failed | Source roles, implicit/explicit declarations, declaration order, re-entry and references |
| `critical_graph_fix_source_roles_03` | 12 targets, 0 failed | Common statement wrapper, for initializer, named/nested bodies and prior witnesses |
| `critical_graph_fix_source_exact_02` | 9 targets, 0 failed | Exact declaration target/order/candidate plus three independent graph mutants |
| `critical_graph_fix_oracle_01` | 15 targets, 0 failed | Combined exact/mutation/depth/order/re-entry subset |
| `critical_graph_mutant_contract_01` | 16 targets, 0 failed | Separate baseline/setup/comparison phases; missed-setup control cannot count as detected mutation |
| `critical_graph_ret_ownership_01` | 15 targets, 0 failed | Owned RET shapes and execution; root cleared, but nested methods were NOT yet forced through the walker |
| `critical_graph_shared_places_01` | 34 targets, 0 failed | Shared native/walker body locations; nested paths, loops/catches, exact shapes/mutations and genuinely walked nested RET cases |
| `critical_graph_shared_fields_01` | Build RED | New indexed member assignment was rejected by pinned L1; fixed by using an actual `L2GraphField` pointer |
| `critical_graph_shared_fields_02` | Aborted, no verdict | Diagnostic fixture filter selected zero rows and unintentionally started a full run; stopped, not counted as evidence |
| `critical_graph_shared_fields_03` | RED, 1 of 35 | Previous 34 targets passed; added catch row stopped on a generated-variable pin. Separate manual native/walker execution proved a real INVALID caused by fetching a catch cell before enclosing edges were linked |
| `critical_graph_copy_closed_01` (kernel) | 286 targets, 0 failed; 106 selftest rows executed | Universal ordinary-copy repair, including cross-owner interpreted/native execution after source release; before the later test safety guard |
| `critical_graph_copy_closed_02` (kernel) | 286 targets, 0 failed; 106 selftest rows executed | Cross-owner copy, alias/parent/native behavior and the negative-control safety guard; also includes result-type projection |
| `critical_graph_copy_mutant_01` (isolated kernel test) | Expected RED: exit 1, 7 failed of 26 | Restoring operation-Structure sharing fails ownership/edge/parent/cell assertions before unsafe execution; not a compiler failure |
| `critical_graph_constructor_copy_01` | RED, 1 of 12 | Correct result typing accepted own-span while the old row still demanded root-pending refusal; no runtime harness proof claimed |
| `critical_graph_constructor_copy_02` | 12 targets, 0 failed | Actual catch-holder allocation, nested/walked catch regressions, graph copy, negative predef results and translation-only own-span |
| `critical_graph_root_container_01` / `_04` | Aborted, no fixture verdict | Unknown names in explicit diagnostic filters; these are not gates |
| `critical_graph_root_container_02` / `_03` | RED, 1 of 14 each | First missing EmptyEntry marker, then incorrect empty-root exit/nonempty-walk expectation; exact container assertions already passed |
| `critical_graph_root_container_05` | 14 targets, 0 failed | Sole-container exact comparison (22 checks), L1/L3 name native/walker parity (17 each), and migrated-wrapper regressions |
| `critical_graph_b2_01` (L3) | All 11 suites exit 0; four type budgets pass | Fresh L3 gate after B2; not a full graph release |
| `critical_graph_source_container_01` | Build RED | A new source-level decrease lacked its required multi-level cutter; fixed without changing the parser |
| `critical_graph_source_container_02` | RED, 1 of 11 | Both new method executions exited 7; the shorthand exact CALL expectation had not consumed its children |
| `critical_graph_source_container_03` | 12 targets, 0 failed | Explicit exact CALL/holder comparison, recursive source contents, real erase mutant and prior regressions |
| `critical_graph_source_container_04` | 14 targets, 0 failed | Adds deep retained containers (192 checks) and unreachable body after return (283); method-body row also executes 283 checks, root multi-expression row 99 |

The exact declaration witness executes 171 checks across native and
driver-cleared physical root walking. The 24-occurrence witness executes 491;
the depth-six witness executes 126, including graph copy. The callable carry
witness also forces the two selected nested methods through the walker in its
registered harness mode; root-only clearing is not evidence for those calls.

Earlier red trial directories remain intact. The errors corrected were the
missing exported marker prototype, test-expression generation, and an erroneous
expectation of a pre-execution root cell's value. Red trials are not green proof.

Earlier focused translator executable, `critical_graph_fix_oracle_01`:
SHA256 prefix `C192C2B4A4333FC1` (the full digest is recorded in the gate's
provenance). Historical source digests before `critical_graph_fix_full_01`
(not the current working bytes):

```text
l2trans.lm1
  B708242FF97A1B438E33080824157D72E28F840CDC1E6AD1FDF5F2F21BF9061F
lmx_walk.h.lm1
  A93F6F6DD57528904FEFAAFB68430E12145781FF0C830A90B57348FCF4ABB1F4
lmx_walk.lm1
  5226476277FC8C99519A547F9CBC1A8F7BF9E7693B6BA8A4298549C59F749DD1
harness/l2_eternal_driver.lm1
  4751E88D20201A51A26D4DB47F749C0CA04CF715ADE35D8D6F842AB1583FA6D0
tools/l2_harness.ps1
  E686F17F71D3FC64492073055257AF6D11DFB584D960E215E7BDA59E09F53C42
```

All source paths above except the explicitly named tool are relative to
`dev/l2src_sandbox/`. These hashes include inherited Grok WIP; they do not
identify a committed release.

The later shared-place executable is SHA256
`775F5F5584E935964F8F93E99F62E14434DAEF69B7B08B4C60298686B793AC29`.
Its 24-occurrence witness executes 522 checks, the exact declaration 186,
and depth-six 140. Both new RET fixtures use `WalkMethods = true` plus
`WalkedMethods = [0]`; their logs confirm `--walk-methods`, and the harness
checks the selected method's dispatch. An array containing only ordinal zero
must not be used as the Boolean flag: it coerces to false in PowerShell.

The B2 focused translator executable (`critical_graph_root_container_05`) is
SHA256 `22611FE5AAE8F6C0F2DC7AEAC37BEA42CF5CD136869A2BCA3B3896A97D1BCF91`.
Later source-container work is a different staged snapshot and is recorded
separately; none of these executables identifies a committed code release.

`critical_graph_source_container_04` is the last focused staged snapshot:
translator executable prefix SHA256 `11C839DE3FBB0ED5`.
The subsequent full run uses these current source bytes with a fresh directory.
The frozen translator source in that focused run, in `critical_graph_fix_full_02`,
and in the development tree has SHA256
`E81F563C25AD601C05CD2A7AC8270C9CFEBE4160C7C42461F54C3D049258F3CD`.

The 106 kernel selftest rows comprise 105 ordinary exit-0 runs and one
expected-fatal watchdog exit-3 run. The latter is an intentional successful
negative test, not a silently skipped selftest. Earlier notes incorrectly
reported 103; this count is taken from the retained summary rows.

Mutation classification now requires one structured result with separately
successful baseline and setup, a failed structural comparison, no unrelated
driver failure, and the unchanged program exit. The missed-setup control
requires the opposite setup result and cannot pass as a detected mutation.
The old `graph_shape_mut_move` changes input source order; it is retained as
a source-order negative control, not misreported as a graph-side mutation.

## 3. Remaining graph work: the next implementation boundary

The universal topology must start from the original unit returned by
`l2_unit_from_root`, plus original program-part roots. `l2_e_struct` is already
filtered to executable root statements and cannot recover source positions of
method/named definitions. Source pointers can be borrowed while the P0 document
lives; another persistent AST is neither necessary nor allowed.

The one physical placement relation must distinguish actual source container
and occurrence from lexical scope. In the current code, for/catch scopes
combine different source components, and IF may consume its following ELSE.
`l2_rw_stmt.made` counts effects, not source occurrences: declarations can make
zero effects, and a for can make two. It cannot be the topology counter.

Migrate widths, construction, own/path addresses, native body bindings,
schema field slots and merge/capture projections together to that one relation.
Then remove selective `l2_src_eligible`, packed fallback, shell drop/trim,
`-2/-3` placement and native-only shell anchors. Merely removing eligibility
guards would redirect existing field indices to unrelated slots.

Unit/namespace/method positions, native-only and library bodies, unreachable
tails and all receiver-created storage must participate. Source preservation
must not depend on whether the walker can execute the body. Name/comment
codec and copy/merge metadata remapping are also still open.

## 4. Pointer repair inventory; implementation not started

The existing `L2Address.type` mixes stored value and address type, and ordinary
descriptor receiving calls the address resolver. Split that resolved view
before projecting `+1`; otherwise deleting exemptions also adds a level to
ordinary value reads. Native and walker then address the real place and load
its held value separately. A descriptor flag must not suppress ADDRESS.

Real graph/reference-array cells are `void *`; native formal cells have their
declared C pointer type; walker formal storage is `argown[k].ref`. The latter
belongs to the scratch arena. Cross-dispatch access must respect actual C99
storage types and lifetimes. Casting `void **` to `Lmx **` and dereferencing,
or copying a different pointer representation without conversion, is not a
general repair. No additional holder or permanent graph is justified.

The existing reversible non-owning range registration can describe actual
already-existing machine cells if needed. That route still requires a concrete
storage contract and retirement on every exit; it has not been implemented
or adopted as a new language rule. Exact-depth actual/formal/return tests,
cross-native/walker writes and alias/lifetime witnesses remain P0–P3 work.

## 5. Full gate / release status

Full harness `build/l2_harness/critical_graph_fix_full_01`: **RED, 36 of 1222**.
Exact FAIL lines equal the 36 lines in Grok's `critical_graph_bug_full_15`
(36 of 1175); all 47 added targets passed. This full run predates the final
mutation classifier and RET/shared-place changes and is not a full verdict
for those later bytes. No old expectation was changed to remove a failure.

Optional `-Strict` kernel run `critical_graph_ret_ownership_01`: **RED,
138 of 286**, with blanket `-Werror -O2` diagnostics in existing modules and
one new selftest's L1 dotted-field argument syntax error. The latter was fixed
with the established parenthesized member form. This red evidence is retained;
do not describe it as a green gate. The ordinary repository kernel command
retains its four hard C guards. `critical_graph_ret_ownership_02` finished
**RED, 1 of 286**: the new selftest incorrectly passed a null parent to
`lmx_walk_plain`. The test now supplies the existing unit as the holder's
ordinary parent. The fresh `critical_graph_ret_ownership_03` run finished
**GREEN, 286 targets**, with all 106 selftest rows executed. This is a kernel
verdict for the staged bytes before B1, not for later translator changes.
Stable twins and the final L3/full-harness release remain unverified.

Do not mark either critical ticket DONE from these focused results. Keep the
pointer stage behind graph acceptance and the separate Structure/reference
application refactor behind both repairs.

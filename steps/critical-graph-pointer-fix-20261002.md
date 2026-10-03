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
support object and exits 10 with 13 checks. The earlier constructor gate's row
was explicitly translation-only. `critical_graph_post_full_01` subsequently
runs that same source with a generic per-fixture `LinkSources` dependency list:
the staged `l1src/own.lm1` is translated by the pinned translator, compiled
with the fixture's existing C guards, and linked into the fixture executable.
There is no prebuilt-object or implicit-library fallback. That fresh harness
run records 13 checks and the required entry result 10.
Structure/void/unknown result refusals are preserved.

### B2: the file root is not erased by a source name

`l2_unit_from_root` returns the actual parsed file Structure. It no longer
unwraps a sole Structure named `L2` or refuses ordinary names `L1`/`L3`.
The outer profile comes from the source file, not these names. Forty-six
current sandbox fixtures have been mechanically converted from obsolete
profile wrappers to the already normative wrapperless form. Historical and
stable sources are unchanged. Grammar source and both generated grammar documents
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

### G2 construction-boundary preparation, not an ownership cut-over

All eight `l2_rw_body` callers now pass the actual P0 Structure, rather than
only its first field. Empty-body identity and the distinction between a body
and its FOR/CATCH lexical scope are therefore available at the common API.
Body allocation uses the existing `l2_rw_plain` constructor instead of a
second handwritten copy of that constructor's output. Twenty-six direct
attachments in statement emission, catch, trailers and Structure calls now
use `l2_rw_put`. Unused native-name buffers were removed from those paths.
No new runtime storage or compiler ledger was added in this preparation.

`critical_graph_constructor_boundary_02` is GREEN: 29 targets, comprising
26 fixtures plus translator/driver/scope checks. Twenty-five successfully
generated fixture L1 files are byte-for-byte identical to their `full_03`
counterparts; the remaining fixture requires the unchanged refusal. The gate
includes exact source/mutation assertions, walked nested methods, catch,
merge, callable return/partial-application cases and actual own-span linkage.
This proves the tested output was preserved, not that source topology became
universal. The first boundary attempt aborted on an unknown filter name
`unit_deepif`; it has no fixture verdict and is not counted as evidence.

That preparation is now followed by the bounded committed-producer cut-over
below. Its green result does not remove the remaining mixed-body storage shells.

### G2 committed source-container ownership: inert containers

`L2SourceContainer` records the original P0 body and its actual METHOD/PAP/T7
construction view. COUNT accepts or discards a speculative view; PLACE records
the common constructors and owning attachments, including delayed operation
attachments and actual PADs; FILL constructs each accepted row exactly once.
Borrowed operands do not acquire an owning edge. These are temporary compiler
records, not runtime fields, a second AST or primitive-cell metadata.

The source-owned inert rows no longer use the former GLOBAL allocation,
attachment or prefix width. Surviving prefixes and top-level ranks are repacked;
their `GraphPlace` is bound to the actual containing body after PLACE. No own
declaration cell is moved in this slice. The original field/span traversal is
shared by the committed GLOBAL and SOURCE_OWNED producers; a positive original
fid on a projected row is not a second construction owner.

Focused gates `critical_graph_source_producer_03`, `_04`, `_05` are GREEN:
10, 12 and 13 targets respectively. The final run tests the single common
traversal, not only the earlier two wrappers. It covers complete owned nested
containers and empty bodies, depth-six contents, catch/merge, native and cleared
root execution, both explicitly walked nested methods, and two distinct retained
model/PAP and model/T7 construction occurrences. The T7 check does not certify
ownership of its subsequently returned runtime copies; that remains G4 work.

An exact `owned` assertion checks each container's actual parent. The new
parent-only mutation changes the parent of the unique container containing
`3 + 4`: its unmodified baseline matches, the applied mutation fails the graph
check, and execution still has the expected exit. The setup-miss control changes
nothing and is explicitly rejected as a structural detection result.

Latest focused translator source SHA256:
`219FE430ED834322E7D9F1318B56E2CAC831AA9D707A9B97269011607E08AB98`.
Header SHA256:
`F672942D82A6E43E237F380376355D319167587C8E0EBF6E97B86130A30FB4C4`.
Driver SHA256:
`6E34CBB59F5B924CF36162E3A79B46E919A9AD561FA9E5BAD70F97EB7AD37289`.

Next connected cut-over: declarations must occupy their original mixed-body
fields rather than a separate packed shell. Locate their physical owner by the
exact original body field and declaration identity, not its lexical scope fid:
FOR header counters and body locals, and CATCH parameters and handler locals,
can share a lexical fid without sharing a physical source container. Field-path
consumers must preserve `GraphField.holder`, not only its child number. General
mixed placement, native-only bodies, source/name/comment reconstruction and
removal of all legacy producers remain OPEN; neither critical ticket is DONE.

### G2 mixed-body producer cut-over: real declaration cells in source order

The next bounded cut is implemented in the development tree. A committed
source body now allocates its real own cells at the fields found by the common
source traversal. Its FILL aliases that one preallocated object; it does not
allocate a second data shell. Compiler-only `L2SourceField.place` carries the
actual holder and child for each construction view. It is not runtime atom
metadata. Primary and projected views do not overwrite each other's places.

FOR's existing operation owns its counter at field 4; the actual nested body
owns body-local declarations. PAD owns its parameter cells and its actual
handler. Neither header parameters nor the FOR counter are packed into the
body merely because their declarations share one lexical fid. No new method
activation, Lmx member, language rule or companion graph is introduced.

Native and interpreted path lowering preserve the whole resolved field place,
including the owning edge chain, rather than just the old child number. Old
transferred producer reservations are removed with a prefix projection of
surviving source slots, so skipping an allocation leaves no vacant sibling.
Projected FILL requires its own committed binding and unchanged producer width.

`critical_graph_mixed_scope_06`: **GREEN, 20 targets**. It includes exact
mixed declaration order (1537 checks per row), FOR/header/body/step ownership
and operands (697 checks), nested ELSE/FOR native and genuinely walked methods,
ELSE/WHILE/FOR publication/readbacks, and repeated CATCH parameter/local use.
Stale generated factory-name/shell-path pins were replaced by exact graph
relationships; execution values and forced-walk requirements were not weakened.

Frozen translator source SHA256:
`D624F3B80308CBC7449424345ABA7AC2A3516B868C256D7582F9968903A6A35A`.
Executable:
`DBA79E4659BD8E2B74B92D83434296D669315418082914E8317070EFB07F2ACD`.

An additional independent boundary witness found a compulsory FOR-initializer
assumption: `for: int(i) (0) i++` had been admitted by checking but refused
silently by native emission, and source placement reserved an action even
when none existed. Native emission now delegates that header declaration to
the ordinary statement emitter. Source placement counts explicit candidate,
implicit input carry, or no action from the resolved receiving contract.
`critical_graph_no_init_01` is retained **RED** evidence, not a successful run.
`critical_graph_no_init_02`: **GREEN, 9 targets**, including the no-initializer
source sequence without a hole, initialized FOR's 697-check exact tree,
native/walker hosted fields, and nested FOR/ELSE paths.

Its frozen source SHA256:
`B2DA7AD235A3E81AB9C6CF6A51707FFADA2B262D240960857B53CC1EC40E52E2`.
Executable:
`B03022A59811B8717916B4043570732C6AA4D1D87025DC02600A2A589C1C4250`.

This is not the universal graph release. Root/method occurrence construction,
PAP/T7 dense action suffixes, native-only/library retention, MAD tails/nested
declarations, source names/comments and the complete decoder remain OPEN.
The pointer implementation is still unstarted behind graph acceptance.

### Full-run witness corrections, with stronger execution acceptance

Five additional failures in `critical_graph_fix_full_02` were pre-execution
assertions, not observed runtime regressions. Wrapper removal moved the
unchanged no-result/value-return refusal in `entry_puts_after_return` to
line 1, column 1. The corrected row still requires that exact refusal.
`unit_walk_trailer` previously required the next sibling to be a bare RET
role; the new generic `NextShape` check instead requires exactly one incoming
sequence edge and its next physical sibling to be a RET/1 Structure. The
ARG/ADD/LIT3 and SET_ARG/OWN operand checks remain. All five invoked methods
are explicitly checked to have no native word under `--walk-methods`.

The three `unit_nested_body_{else,while,for}` rows pinned obsolete native
temporary spellings. Their replacements compare SET_OF destinations and
initializer literals, plus PUT through OF(NODE, field), without naming
generated temporaries. These are exact transitional holder relationships,
not a complete source-topology oracle. Original readbacks 21/31/41 remain;
new ordinary external paths read hosted fields 2/3/4, the finished WHILE
flag is 0 and FOR index is 1, and the root's bare working `shared` remains 3.
Success is now explicit entry result 7 rather than fall-through 0.
Each source has a native-method variant and an alias forcing both producer
and reader methods through the walker, with driver-cleared root parity.
No production branch was introduced for these three fixtures.

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
| `critical_graph_post_full_01` | 8 targets, 0 failed | Exact return-refusal location, strict owned RET sibling, actual own-span support link/runtime (13 checks), prior graph regressions |
| `critical_graph_nested_acceptance_01` | 10 targets, 0 failed | Three unchanged control contracts with added actual field-path/publication assertions; native and genuinely walked producer/reader methods, plus all five walked trailer methods; each positive row executes 17 driver checks |
| `critical_graph_constructor_boundary_01` | Aborted, no fixture verdict | Unknown focused filter `unit_deepif`; not a full or focused acceptance gate |
| `critical_graph_constructor_boundary_02` | 29 targets, 0 failed | Actual P0-body API, common constructor/26 attachments, source mutants, nested methods/catches/merge/callable-return regressions; 25 emitted L1 files exactly equal to full_03 |

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
checks the selected method's dispatch. Successful fixture logs can be pruned
by the standard harness unless `-KeepAll` is supplied; the retained summary
and fixture rows record that acceptance. An array containing only ordinal zero
must not be used as the Boolean flag: it coerces to false in PowerShell.

The B2 focused translator executable (`critical_graph_root_container_05`) is
SHA256 `22611FE5AAE8F6C0F2DC7AEAC37BEA42CF5CD136869A2BCA3B3896A97D1BCF91`.
Later source-container work is a different staged snapshot and is recorded
separately; none of these executables identifies a committed code release.

`critical_graph_source_container_04` records the source-container snapshot:
translator executable prefix SHA256 `11C839DE3FBB0ED5`.
The frozen translator source in that focused run, in `critical_graph_fix_full_02`
and in `critical_graph_fix_full_03` has SHA256
`E81F563C25AD601C05CD2A7AC8270C9CFEBE4160C7C42461F54C3D049258F3CD`.
Later construction-boundary edits are a different development snapshot and
must not borrow that full-run verdict.

The frozen translator source in `critical_graph_constructor_boundary_02`
matches the current development source and has SHA256
`983243C9ED34326C811542BD973E41CB9A9567DA5D1D9D8FD6B6F253C2BDCA85`.
Its translator executable has SHA256
`3FD5CAB8528A98073C5ADA7E5CBC6DDEF1016C07C936460964156E5800CA1C97`.
This later snapshot has focused acceptance only; no full green release.

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

### Projected returned bodies and execution-root construction

T7 projected occurrences now have their own committed source producer. The
generated `l2_view_build_<site>` builds the actual returned occurrence and
its cells directly. The former `l2_t7_base`, `l2_t7_bases`, `l2_t7_extra`,
`l2_t7s` and `l2_t7k` packed anchor/suffix allocation is removed. The lexical
anchor remains translation information, not another allocated body. This
does not settle the older T7 formal-default/type projection debt: merge
defaults do not remove or bind a formal under the normative contract.

The file's **filtered executable** E body also uses an existing root
occurrence as its source-container producer: actual cells are created once
at their recorded places, and the old own-cell allocation skips precisely
those committed declarations. Empty roots participate without a dummy body.
This is not yet original-unit preservation: `l2_make_entry` still filters out
method/named definitions, directives and OS declarations.

Forty-five native/walker/construction lookup lines now use the common
`l2_occ_slot`, `l2_ns_unit_slot` and `l2_ebr_unit_slot` boundaries instead of
recomputing positions from table ordinals. Physical declaration placement
is not yet moved by this lookup migration; the remaining base arithmetic is
confined to those producers and tail-size calculations.

New evidence, all focused rather than complete release gates:

| Directory | Verdict | Scope |
| --- | --- | --- |
| `critical_graph_t7_own_05` | RED, 3 of 14 | T7 and control-body runtime witnesses pass; three stale generated-layout assertions fail |
| `critical_graph_root_source_02` | GREEN, 14 | Filtered-root constructor, T7, mixed/control bodies, own/formal regressions |
| `critical_graph_root_source_03` | RED, 4 of 15 | Overstated returned-model reachability and trampoline expectations; two obsolete holder paths |
| `critical_graph_root_source_04` | RED, 1 of 15 | One remaining obsolete PUT holder path, before runtime execution |
| `critical_graph_root_source_05` | GREEN, 15 | Corrected exact holder paths; no admission/exit expectation weakened; native and root-walker runs |
| `critical_graph_unit_slots_01` | GREEN, 17 | Common slot helpers, 1537-check mixed tree, T7/IF/WHILE/root FOR/catch/control regression witnesses |

The static `GraphShapes` checker follows execution-reachable relationships,
not every returned object. Removing a too-strong RET assertion from
`unit_make_adder` does not establish a source reconstruction oracle. Its
independent nonzero execution witness remains. Likewise the native-note row
checks the genuinely walked host, not a nonexistent trampoline for its nested
model. The two holder assertions now follow the actual shared graph places:
SET_OF targets `OF(AT(4),2)`, and the admission PUT targets
`OF(OF(AT(10),2),1)`; the source/reference tests and admission operands remain.

Current focused snapshot:

```text
l2trans source SHA256
  AC1BE69317AD36CB4342C4F8A2209CC7E0030FBD429B52482F4136ABE0F8D6B9
critical_graph_unit_slots_01 executable SHA256
  770A338A632B41329860742551F38D6106C467B14231275DA2C43BB436F8C617
```

`critical_graph_fix_full_06` staged that exact source and completed **RED,
32 of 1249 targets**. Its executable SHA256 is
`601BB0B7E5CDBBFD9FD314D556E13FE5C2AB53C57F7367353E509617E98BFA29`.
Nine failures from `full_05` are absent and no new failure identity appeared.
The remaining 32 are not waived: several rows still prescribe the removed
root-pending limitation or temporary names, while the nested unused-field
admission and whole captured-Structure transport have genuine implementation
debts. Positive fixtures using obsolete implicit `Model: fresh` cloning need
valid explicit-merge setup and actual observed success before their generated
text assertions may be migrated. Earlier `full_05` is RED, 41 of 1248: the historical
35 failures plus six pre-execution layout assertions; it predates this cut.
Neither critical ticket is closed, and stable twins remain untouched.

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

Existing declaration objects can be attached at their exact P0 sites using
`l2_m_node`, `l2_ns_at` and `l2_ebr_at`, with COUNT-only slot registration and
compact ranks for genuinely unplaced producers. Do not merely feed original
root fields to executable lowering: OS/directives need their actual retained
source bodies, and a forward signature currently discarded by
`l2_bind_same_unit_forward` needs its own nonexecuting contract occurrence,
not an alias containing the later implementation. OS alternatives must retain
their separate source bodies even though only the first is registered as a
method row. No silent skip or fake empty body satisfies this boundary.

Migrate widths, construction, own/path addresses, native body bindings,
schema field slots and merge/capture projections together to that one relation.
Then remove selective `l2_src_eligible`, packed fallback, shell drop/trim,
`-2/-3` placement and native-only shell anchors. Merely removing eligibility
guards would redirect existing field indices to unrelated slots.

Unit/namespace/method positions, native-only and library bodies, unreachable
tails and all receiver-created storage must participate. Source preservation
must not depend on whether the walker can execute the body. Name/comment
codec and copy/merge metadata remapping are also still open.

### Concrete codec gap; name-service implementation status

The initial inspection found no runtime address-to-source-name table. A bounded
external service now exists in the sandbox; its ownership tests are described
below. This does not establish complete producer integration or a source codec.
`toLmx`/`fromLmx` and retained comments are still absent. Compiler P0 text/name
arrays and generated diagnostic comments are translation-lifetime evidence, not
those missing facilities. `l2trans` destroys its P0 document immediately after
`l2_emit_unit`. Inline comments are skipped by `lm_p0_skip_field_space`;
raw comment blocks are scanned and skipped by the field parser. The original
document owns the complete source only during translation. Merely walking P0
fields therefore cannot recover every retained comment later.

G1/G4 must explicitly implement independently owned name/comment payloads
bound to actual source occurrence places before document disposal. Repeated
declarations or applications sharing a target must not collapse their source
occurrence identities. Copy/merge must remap those place keys through the
same graph-copy relation and retain payload ownership when source storage is
released. Names are not an execution resolver; comments are not executable
nodes. No Lmx member, per-primitive wrapper, second AST or saved whole source
may substitute for the missing mechanism. The roundtrip must reconstruct
from the actual graph plus only these retained payloads.

### G4 bounded external-name ownership and transactional publication

Fresh kernel gate `build/critical_graph_source_names_06`: **GREEN, 290 targets**.
All 107 selftest rows ran, including the normal expected-fatal watchdog. The new
`lmx_source_names_selftest` executes **81 checks, 0 failures**. A separately staged
focused executable in `critical_graph_source_names_focus_07` has the same count.
These are ownership/lifetime tests, not the complete graph/source codec.

The independent service stores only `{key, text}`: an actual occurrence or
owning-child-cell address, and its owned length-bearing CHAR text. It does not
duplicate a value, type, execution binding or Lmx header field. Same-spelling
publication is idempotent; an alias place can keep `left` or `right` without
renaming a common referent. Foreign lookup uses the actual range owner; creating
an unnamed foreign key in a borrower is refused. Transfer and copy use normal
arena ownership. Weak marking prunes all dead keys before marking surviving
spelling chunks, preventing spelling bytes from resurrecting another key.
Range retirement cancels affected key, record and text entries.

Copy prepares names through the existing closure map, but does not publish them
until its enclosing operation succeeds. Merge owns the complete pending batch,
including final result-place names. A later merge allocation failure cancels
every pending row before ordinary arena reversion. The selftest injects this
late failure and both initial pending-map allocation failures, then proves a
successful retry and exact same-destination batch deduplication. No arena
allocation/GC protocol or language failure semantics was changed.

Earlier red evidence is retained: `_04` failed the new selftest's duplicate-body
link closure; `_05` linked but its test used uninitialized stack arenas; the
focused `_06` ran 70 checks with one failed chunk-sharing test setup. The live
test now zero-initializes arenas and seeds CHAR chunk capacity before the
weak-key contamination witness. Do not cite any earlier red run as green.

Fresh full harness `build/l2_harness/critical_graph_fix_full_08`: **RED,
34 of 1256 targets**. Frozen translator source SHA256:
`76B60C794882CC0AFB5B719EAB717204B1996E34B8C24B78C08A814FA0DD5D68`;
executable SHA256:
`E256E3BEC74A4CCA9932B51C0EB21529098692AB00E57BA6BF2A02AAF90633A0`.
Its exact failure rows are in `summary.txt`; they are not waived. This frozen run
predates subsequent producer-name integration and common source-atom emission.
It is not a verdict for those later live bytes.

In the current uncommitted translator, source retention and interpreter
capability are separate compiler facts: retained machine operations contribute
source width without clearing a method's native word. The MAD helper-generation
gate follows retained construction, not the host's interpreter capability.
The new common atom emitter replaces the three legacy kind-12 CHAR_PTR spelling
producers, including qualified allocation profiles. Namespace fields name their
actual owning places using `l2_nsf_fname`; `l2_nsf_name` is not a substitute,
because it can name the referent or written atom. Primitive own cells, ordinary
method occurrences, namespace descriptors and formal owning places use the
same external service. Exact `namepath` and `placenamepath` assertions inspect
only the selected key, without neighboring-name/text fallback. These producer
  changes require their own focused/full gates; names alone do not close G1/G2/G4.

### Common source atoms: symbolic identities are not opcode records

`critical_graph_names_atom_01`: **RED, 2 of 13**. Both retained `A: b`
witnesses reached UNSUPPORTED because the first symbolic leaf was incorrectly
allocated as OP/UNKNOWN, making its otherwise dormant holder look like an
executable frame. `names_atom_02` remained **RED, 2 of 13** after splitting
the leaf domain: walking and exact-name assertions passed, but ordinary copy
had no leaf constructor. These are real failed probes, not green evidence.

The common atom producer now uses real typed primitive cells, CHAR Array
descriptors and identity-only symbolic cells. A symbolic occurrence has one
inert identity byte in SOURCE_SYMBOL kind23/type36; no opcode/value/name/type
payload is added. Its name resides externally. Generic atom handles are
`void*`, so adjacent byte cells are not misaligned conversions to `Lmx*`.
Source-name service type35 avoids colliding with existing Message domain21;
no existing ABI number moved. Walker classification itself needed no special
symbol-name skip: only genuine OP/ROLE addresses determine operation roles.

Symbol copying allocates a destination identity, registers the normal copy
map and remaps external spelling. Equal spellings do not collapse distinct
occurrences; repeated edges to one occurrence remain shared. No symbol is
added to the shared opcode-terminal policy.

`build/l2_harness/critical_graph_names_atom_03`: **GREEN, 13 targets**.
Ten selected fixtures plus three build/scope rows passed. Exact unknown/known
`A: b` names, same-arena copy and native/cleared-root walking give 96/84
checks respectively. Frozen translator source SHA256:
`92FD6184D3C9CF73ABE421EFB8F7F90797264E17BD43F5574B2AE467FF2B4A5F`;
executable SHA256:
`A14784883A61DAA3B866540CF78CA0CB0978491BF618EB1D67AD6C3F60AD3A19`.

`build/critical_graph_source_names_07`: **GREEN, 290 targets**, all 107
selftest rows executed. Its external-name witness gives **93 checks, 0
failures**, including cross-arena distinct/shared symbolic identities and
their spelling after releasing the source arena. Existing genuine unknown-OP
refusal tests still run in `lmx_walk_selftest`. This frozen kernel gate
predates the subsequent atom/expression GraphField constructor factoring.

Neither focused result implements comments or the canonical full decoder.
The full graph and pointer tickets remain OPEN; stable twins are unchanged.

### Runtime ownership without implicit source fields — 2026-10-03

The author's placement confirmation and subsequent R0-stub clarification
are archived verbatim in [the technical journal](../LMX_blog/2026-10-03.md#thread-runtime-placement).
Launch/settings still live in the existing preparation parent stub; no new
storage location or companion data/context graph was introduced. The translator
no longer appends their duplicate reference or membership to PROGRAM.

Each existing `Thread.children` holds the sole owned List directly. The common
`children_open` constructor replaces source-graph scanning in ordinary child/root
preparation. Existing Thread layout, binding type/owner/empty/single-bind contract,
close order and explicit application-data constructors remain. Fresh root/source
graphs permit exactly zero source fields. Host-only R0/settings/launch slots remain
explicit profile data, not programmer source. Root/library construction and the
shape oracle consume exact source counts; neither oracle skips implicit protocol
fields. GC marks the membership edge from the actual Thread root, including an
unregistered externally allocated Thread.

`build/critical_graph_source_names_11`: **GREEN, 290 targets**, all **107**
selftest/cselftest rows executed. The external-name witness gives **98 checks,
0 failures**, including a cold arena where spelling is allocated before a CHAR
value; GC gives **51 checks, 0 failures**. CHAR initialization uses the existing
canonical table initialization guard before name/string backing allocations.
The staged 247-file kernel digest is
`d91fcd76aa239cd60e5b74a8165c8b20ffbb0aa46ca015d1fe064187c925d69d`.
Earlier `_09` was RED4/290 (L1 dotted operands and stale host-slot expectation);
`_10` was RED1/290 (reserved L1 identifier `external` in the new GC test).
Those runs are preserved, not relabeled as green.

Independent frozen negative controls, with live sources unchanged:

- `critical_graph_gc_membership_mutant_01` removes only the direct children GC
  mark from names11 generated C. The isolated witness has no scheduler, registration,
  mailbox or slot retaining the membership. It finishes exit2, **50 checks,
  exactly two failures**: descriptor and backing retention. Potentially reclaimed
  values are checked by saved range addresses before dereference; no crash/timeout
  is accepted as detection. Mutant C SHA256:
  `D0B1C8AA65C06CECA0209CC109BE181312C629D82EE5E91A6B1FE012371F10D8`.
- `critical_graph_source_names_mutant_01` publishes staged copied names immediately
  before the outer merge result is allocated. The existing injected late allocation
  failure finishes exit1, **98 checks, exactly one failure**: `failed outer merge
  publishes no intermediate names`. Mutant C SHA256:
  `600D3B1027974BBF4AA4477166B2B8259BCC6A1DA5D7E36A2D8AF9BBA853F226`.
  Its first runner assertion used the wrong summary spelling; the recorded runner
  now checks the actual `source names: 98 checks, 1 failures` line as well as
  the exact assertion and exit. No live implementation was altered for either mutant.

`critical_graph_protocol_01`: **RED, 23 of 25 targets**. One driver compile
error split an unparenthesized dotted-member operand inside an L1 call; the other
22 failed fixture rows consequently did not execute. Fixing the driver expression
to use its existing size local produced `critical_graph_protocol_02`: **RED,
1 of 25 targets**. All 21 positive fixtures execute successfully, including
mail handling, CHAR/address identity, exact atom/source-boundary/ELSE placement,
portable reference arrays, real root native attachment and physical cleared-root
walking. The remaining ELSE mutant deleted a whole body-place container, so native
entry correctly aborted before it could emit isolated same-exit comparison evidence.
The control was subsequently narrowed in full10 to damage only its source
operator head while retaining the runtime body place; protocol02 itself remains
failed-run evidence, not a green mutant verdict.
Protocol02 staged translator source SHA256:
`9C6B6142F2361C883793C097C135603BD697109922B98048AEE1D2E1396DDCDD`;
executable SHA256:
`DC585759E7C481F466AAA4BC5BD574EB16BB8F49A0242C4D1EC60498B0AE6CB3`.

The previous completed full `critical_graph_fix_full_09` is **RED, 81 of 1263**.
It predates the subsequent ELSE/contract-tail,
canonical CHAR and runtime/source placement repairs. Frozen translator source:
`4251E2CF9CE6A417AFC8E298C97E90EB3C075C6C5332AF2C4EB18FDA77EFC4F1`;
executable:
`BF1A75EF88F5086C1DB54EF4C5D6F7803498FBD26DA1E27201B6384C6898152F`.
The full source codec, remaining producer/resolution defects, full graph release
and pointer implementation are still open; kernel/focused green subsets do not
substitute for those acceptance gates.

### Full10 and independent L3 closure, 2026-10-03

`build/l2_harness/critical_graph_fix_full_10`: **RED, 91 of 1266 targets**.
Frozen translator source SHA256:
`9C6B6142F2361C883793C097C135603BD697109922B98048AEE1D2E1396DDCDD`;
staged Git blob: `47e7c63eb91dca276e6742cc501ec4e1ab12fd37`;
executable SHA256:
`A17841433EA73BCAAF4384A68BF53E131C1AF3BCCC91841BC1DAF467CAC262AB`.
It started at c734e6cf; only the bounded docs checkpoint e74985b3 was published
during this frozen run. No code release or stable-tree promotion occurred.

The narrowed ELSE source mutant uses `null-path 2 5 0` rather than removing
the body container. It records mutation=1, baseline=1, setup=1, compared=1,
setup_failures=0, shape_failures=1, other_failures=0, actual/expected exit7;
the sole shape assertion is the missing shared application head. Thus it is
independent graph-loss evidence despite identical execution. Full10 also runs
`unit_eternal_shape`: 33 checks, two roots, exit0, with source width20 rather
than old width22 including hidden children/settings.

Failures are not waived: they include genuine closure/path/type/admission
debts, old physical-slot assertions and omissions in the generated-header
oracle. Read-only comparison proved nine SET/PUT destination assertions
need the source-place indices (not the old storage-prefix indices); all
other operation widths, edges and runtime checks remain required. Existing
descriptor-as-address and implicit-Model-clone fixtures still encode later
pointer/application migration debt and do not establish the current norm.

`build/l3_selftest/critical_graph_protocol_01`: all 11 suites fail to link
because the runner omits the external `lmx_source_names` link unit; no suite
executes. The four header budget probes also detect the added LmxSourceName
type (75 names, expected74). The runner now translates/links the actual
module, and the explicit expected budget is rebaselined for this one new
header declaration, leaving the 128-name/8192-byte capacities unchanged.
`critical_graph_protocol_02`: **RED, one of 11 executed suites**. Ten pass;
N9 has two IF-false assertions because its manually built fixture still
puts a naked else body in the IF slot instead of the retained ELSE
application plus its body. The four budget probes pass at 75/128 names,
1070/8192 bytes. The fixture was corrected without changing the runtime's
condition or iteration rules. Fresh `critical_graph_protocol_03` is **GREEN:
all 11 executed suites and all four budget probes**; N9 executes 43 checks.
These are L3 kernel suites, not the absent full source codec or L3+L2
self-build chain.

### Resolved receiver and contract-oracle slices, 2026-10-03

`l2_predef_receiver` reuses the existing structural `.h.lm1` lookup with its
type-or-function-pointer mode. Head absence, assignment classification and
unit declaration collection now use that same receiver-presence fact. It is
not a C-header scanner, C-name registry or a name-specific native-call rule.
`critical_graph_predef_receiver_01` stopped before fixture verdicts because
the new helper lacked its forward declaration; this is retained failed
build evidence. Fresh `_02` is **GREEN, 27 targets**: 13 foreign-function-pointer
shape rows, two executed RHS positives, three unknown-head opposites and six
merge destination rows. Frozen translator source SHA256:
`9B50129B48ABEBCB22CCB1F54909ACFEBFA5A42DBE42E4276373D8A54CC06678`;
executable SHA256:
`FFE54E75E775680068693EE82E0C0D914761373555BABAE91422ED84342D3377`.
This does not prove complete native-only source construction.

The graph oracle now records even empty real method-input header parts and
descriptor stores through `l2_fkid`. CALL argument boundaries follow the
actual header or explicit contract, not a guess from the first argument's
shape. Nine old SET/PUT destination pins were replaced by independently
observed source-place indices; operation widths, edges and execution remain
checked. Exact method/source-order rows no longer require hidden service
fields or a duplicated contract after the source body. Fresh
`critical_graph_contract_oracle_02` is **GREEN, 24 targets**, including
descriptor-first three-argument CALL, empty input, callable signature kinds,
six exact source-body rows, merge/PUT places and the independent ELSE mutant.
Its source SHA256 equals `_predef_receiver_02`; executable SHA256:
`7AC3A0AFA051B4B4F50CC7DF5720493D89372D5240CB4CDE1041698FB6AC2BA3`.
The first `_01` attempt rejected misspelled fixture selectors and supplies
no fixture verdict.

Subsequent oracle review requires actual signature-part allocation provenance
and the explicit contract's observed parent chain. Ordinary source-body
Structures cannot impersonate method headers. The separate AST-only negative
control `build/critical_graph_call_header_oracle_mutant_02/RunReviewed.ps1`
accepts the baseline and rejects a one-line real-header kind mutation, a
missing empty header, an incidental body shaped like a header and a wrong
contract owner. Its reviewed harness SHA256 is
`34995E6A33D5B3C1796DE456E89AA5BE36B527912E026BF29F1D4A0885C7A9A4`.
It executes no constructor or compiler and cannot certify runtime behavior.

Full `critical_graph_fix_full_11` is **RED, 45 of 1266 targets** against
the same frozen translator source as the two focused green slices. Its
executable SHA256 is
`56A3487FC720491ED212AE59D3277BCC321CEF9013541A70A56AB714EECCD6A1`.
It staged at doc HEAD e74985b3; the later published changes were docs only.
Its harness predates
the later provenance review and the five added genuine hidden/formal-input
witness rows. A completed full11 verdict cannot certify those later edits;
a fresh focused run is required for them. Exact remaining identities and
diagnostics are retained in its `summary.txt`; no blanket waiver or code
promotion occurred. Full10's 91 failures remain historical evidence.

Fresh `critical_graph_binding_oracle_03` is **GREEN, 17 targets**. Both genuine
unsigned hidden-input and explicit-formal cases execute natively, with the
physical root forced through the walker, and with both methods' native words
cleared. The callee sees caller5, returns its internal1, and neither caller5
nor lexical source3 changes. Reading `peek\\k` refuses at the missing name;
the input did not become a graph field. Real unknown-RHS, incompatible-value
and void-result negatives remain required. CALL/header probes also exercise
the later allocation-provenance oracle. `_01` rejected unknown fixture names
before builds; `_02` was RED2/17 on an old x-slot pin and the new refusal's
guessed diagnostic. Independently observed x at source slot5 and the exact
located missing-name diagnostic were then pinned, leaving runtime behavior
and all type/kind/arity assertions unchanged. This closes only those measured
input/opposite witnesses, not universal source-environment closure.

Fresh `critical_graph_literal_definition_01` is **GREEN, 17 targets**, with
the same frozen translator source and executable SHA256
`3CAFC03A58E2BA33E357EDA8E2C8629D9ADF0120346B31F7EA7193FF0B11C6DA`.
Nine former refusal rows now check their actual current semantics: four root
unknown-head literal definitions, three method-local literal definitions and
two unknown unsigned definitions in peek. Historical filenames are retained,
but obsolete comments/Expect values are corrected. Each requires program exit7
and an exact whole-tree assertion, external names, parent links, literal values
and callable target identity. The four root cases run 95 checks, method-local
cases 282 and unsigned cases 813; native and cleared-root walking both execute.
The unsigned twin also clears the native words of peek and m. Real unknown-RHS,
incompatible assignment and no-result-as-value negatives still refuse.

The driver adds only `numvalue TYPE VALUE`, reusing its existing exact numeric
type/value accessors; it does not introduce a new core value category or loosen
the tree decoder. An independent frozen generated-C mutant in
`build/critical_graph_unsigned_value_mutant_01` changes exactly the retained
unsigned source cell initializer1 to0, not the native constructor or program
logic. Baseline C SHA256:
`DC4406C97004117D19001BE294D5467A90488DCF0B38B79F0EE8C67C03CB4D5E`;
mutant SHA256:
`AFFD8A492BE3FD8FCE546B9A150A6E8FD808331676728E75791228E3DE844DC1`.
Baseline exits0; mutant exits1, with compared=1, shape_failures=1,
other_failures=0 and actual/expected program exit7. The primitive domain/type
checks still pass; the exact unsigned value assertion detects the defect.
This is an actual constructor mutation, not changing the expected value or
removing an assertion. It does not make the earlier full11 green or close the
source codec, universal layout or pointer repair.

Runtime CALL representation remains an explicit implementation debt.
`lmx_walk_call` still guesses compact versus explicit-contract layout from
ordinary Structure widths. A source body's first two fields can have the
same shapes as an input/result header, and a compact CALL argument can itself
be such a Structure. Existing arena domain facts do not distinguish these
cases. Oracle builder provenance is not a runtime representation and must
not become a hidden registry or another shape fallback. The next runtime
slice must consume an unambiguous common executable/receiving contract,
retaining the source operands and ordinary parentage; no new language rule
or per-name exception is implied. Neither critical ticket is closed.

### Next bounded producer dependency: resolved external-native calls

Read-only full11 inspection confirms that the native receiver correction above
does not supply a retained application producer. `l2_is_known` recognizes raw
`c.*` and functions from the unit's parsed-predef declarations; `l2_rw_operand`
and `l2_rw_stmt_content` retain the former but omit the latter. `entry_parse_min`
refuses at source line21, frame `lm_p0_parse_file`, with `this operand`.
`unit_define_ccall` emits real native strlen calls and size_t cells, yet its
quiet walker-eligibility refusal discards the source-view body. Neither native
success nor a complete method header makes that omitted body acceptable.

The bounded repair must reuse the resolved external-native category and
`l2_predef_result_ty`, and retain actual operands through ordinary spans/place
projections. Merely adding `l2_is_known -> l2_rw_source_node` is insufficient:
the current raw recursive writer materializes known variable atoms as new
SOURCE_SYMBOL leaves. It must not duplicate their real value cells or bind
source names at runtime. Original body counting/placement must remain
independent of interpreter capability. No code for this next substep has been
added, and no C-name allowlist or unknown-call fallback is authorized.

### Actual signature-header oracle negative control

`build/critical_graph_call_header_oracle_mutant_01` retains the protocol02
generated PAP L1, a separate one-line mutant and a frozen harness. Its runner
extracts only `Get-WalkGraphFacts`, `Get-WalkWitnessKind`,
`Get-WalkCallContractNode` and `Test-WalkCallContract` from the PowerShell AST;
it does not source or execute the build script. The compact CALL `l2_rw45`
has width3, points to real callee root slot1 and has no copied contract tail.
Explicit input int/result int/arity1 is accepted; changing only the actual
input-header allocator to CHAR is rejected. The only changed parsed witness
key is `signature-part:3:0` (physical generated line299). Baseline L1 SHA256:
`89BE9A5324545D0D0B3DDAFCDBFDEFF780481A4D42E2158C3BBBFF2FE9D146AF`;
mutant:
`B3CFE7122F925BC0D1C170C06568F10F26F50EFD9A591E90361B4F4B388B9BEA`;
frozen harness:
`40A99535BBF8F216EEAC8C571335D17A6FFCD0A90A7C8B76EB817048B697032B`.

This is generated-header-contract **oracle** evidence, not runtime graph
construction/mutation evidence: no compiler or constructor runs. A first
ambiguous patch hit a different cell; the runner rejected it before any claim,
and the final mutation is verified as exactly one line and one signature key.
The helper's old slot3 width2-tail heuristic remains a separate migration debt;
this width3 probe cannot exercise it and does not certify all CALL layouts.

### Connected source resolution and indexed-operand debts

These read-only findings guide the next code slice; none is claimed implemented.

`l2_parse_unit` currently collects assignment/declaration bindings before
`l2_dyn_local`; `l2_collect_asgn_body` and `l2_scan_body` can therefore register
a source head as its own Structure before a real caller supplies the hidden
input of that name. The later checker records callsites too late to undo that
role without losing source meaning. `l2_local_ns_shape` already queries dynamic
formals: replacing one lookup or reordering two passes does not fix the second
registration route when an existing input is actually established. An earlier
audit incorrectly called `unit_free_write_literal_refused` a hidden-int
mismatch: peek has no visible/formal/input k, and its caller's unrelated local
k does not retroactively establish one. Current construction semantics make
`k: 1U` there a named Structure holding the unsigned literal. A genuine hidden
input witness must first establish the outer binding, return the changed
internal value1 while the caller keeps5 and the lexical source keeps3, and
refuse `peek\k` as a graph field. Explicit-formal and truly unknown-head cases
are separate opposites; a zero-only exit is insufficient evidence.

Required shared boundary: reuse existing `L2SourceSite`, source save/restore,
ordinary binding resolution and dynamic worklist; factor caller-source selection
and generalize `l2_colon_bound_before` to the exact saved scope/source prefix.
Defer unresolved head decisions, not preallocate own fields and delete them
later. Close real callsite/receiving-contract facts and newly discovered local
callable bodies without a fixed pass count before absent-head materialization.
Callable atoms passed as references are not callsites; the existing checker
actual-contract traversal must supply that distinction. A nested expression's
source context must retain its enclosing statement/prefix, so a missing direct
stop identity cannot accidentally expose future declarations. This is compiler
environment bookkeeping, not a runtime binding/name registry or data graph.

Qualified indexed borrowed spans currently join source text but route it through
plain `l2_rw_path/read`, whereas single-atom paths use indexed helpers. Both
indexed helpers also cut at the first `[` and mistake `s\[N]name`'s selector
for an Array index. One allocation-free terminal suffix projection must serve
typing/emission and preserve the complete field-prefix; a name after `]`
distinguishes the occurrence selector. Adjacent flat-Array `[][]` groups and
unnamed `\[i]` steps cannot be conflated. The old kind5/kind6, two-index and
fixed-buffer helpers are debt to replace, not authority for new restrictions.
Native checking/preparation and retained ELEM/OF/index nodes must consume the
same original bounded operand view. Distinguished descriptor identity for
duplicate selected Array fields and native/cleared-method walking are required;
zero-filled Array output alone does not prove preserved indexed source.

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

The ordinary value contract and address-result contract must remain distinct
in `l2_reference_descriptor/source` too; they currently reuse the same
`L2Address.type`. Raw C-type interning can collapse a language model reference
onto the foreign spelling `Lmx *`, so the stored C-type code alone is not
enough to select a typed native cell versus a CHILDREN `void *` cell.
Use the resolved declaration/signature contract and actual storage-range
projection; do not deduce the effective C cell type from an aliased cast.

Null adds a concrete coordinated boundary: current AT/OWN/OF reference code
classifies `slot[0]` and defaults a null to LMX. CHILDREN/TYPE_REFS range
membership does not distinguish an Array-null from a Structure-null contract.
The producer's existing declaration/signature contract must supply that type,
without a per-cell metadata record or a pointee probe. Exact-depth actuals
must be checked before consumer-relative implements, including null values.
These are read-only findings for P0–P3, not implemented pointer fixes.

The existing reversible non-owning range registration can describe actual
already-existing machine cells if needed. That route still requires a concrete
storage contract and retirement on every exit; it has not been implemented
or adopted as a new language rule. Exact-depth actual/formal/return tests,
cross-native/walker writes and alias/lifetime witnesses remain P0–P3 work.

The source-loss and pointer-depth parts of address lowering are coupled:
`l2_rw_span` reaches `l2_address_operand` only for source unary `@`, but
`l2_address_name` suppresses depth addition for descriptors and
`l2_rw_address` omits their ADDRESS application. Native `l2_emit_address`
and runtime `lmx_walk_place` likewise substitute the descriptor for its cell.
Just inserting ADDRESS can change its type witness while leaving the wrong
reference level; adding a compatibility branch would preserve the defect.
Integrate source ADDRESS retention and general value/place/depth projection
atomically at the shared address boundary after universal placement. No such
code or compatibility branch has been added, and neither ticket is closed.

### Concrete C99 storage dependency, not another language rule

The source/address split alone cannot manufacture a genuine `Lmx **` out of
a `void *` object. The current CHILDREN backing has actual `void *` cells,
and `ref_cell/ref_value/ref_store` access them through `void **`. If native
typed code must address a genuine `Lmx *` binding object, its one real place
must be allocated with that storage type. One shared typed arena pool can
hold these cells, exactly as it holds primitive cells; the existing
heterogeneous child edge points to the cell. A cell is the language binding,
not a companion Structure, copied descriptor, per-model array or synchronized
shadow. Ordinary acquisition loads its held reference; unary address-taking
returns that cell. Rebinding updates the cell, not its parent edge.

This is a connected representation migration, not implemented here. The
resolved source/declaration/place contract determines which edges denote
language-addressable values. Named bindings alone are insufficient: exposed
Structure body paths such as `M\\for` also need the real place. Internal
operation/callee wiring is not promoted to a new language variable merely
because it contains a Structure pointer. Pool kind/type later distinguishes
the actual storage without a per-cell record or name lookup.

`lmx_arena_ref_store` remains raw edge construction; it has no arena argument
and must not silently allocate a binding. Existing producers have the owner
and can explicitly allocate and initialize the real cell. Generic logical
acquisition, walker place resolution, native reads/address emission, own
publication, implements, graph copy, merge, GC and the codec must migrate
together. An activation's addressable formals need their own genuine typed
cells, not the transport `LmxWalkValue.ref` member.

`LMX_KIND_REF/LMX_TYPE_LMX` and `/LMX_TYPE_DESC` already back Array and List
elements. `lmx_array_ref_new_owned` and `lmx_list_grow` currently create/use
those cells through `void **`; reusing the pools for genuine typed bindings
requires coordinated backing access, copy and GC migration. Mixing different
C effective object types in one pool or adding a second ad hoc pool to avoid
that work is not this repair. Arbitrary closed-unit C pointer storage likewise
must preserve its actual declared storage contract, not be reinterpreted as
`void **` because object pointers happen to have equal sizes on this host.

Required additional observations: two bindings may hold the same descriptor
but have distinct addresses; a real `Lmx **` C store changes only the selected
binding and is visible in both backends; null values retain the declared depth
without a pointee probe; copy preserves binding/alias topology independently
of the existing opaque machine-pointer pointee policy. These remain future
P0–P3 acceptance, not measured successes.

### Original unit order and hosted callable-field continuation

The E producer now reads the original P0 unit, rather than using the filtered
executable body as the source-order authority. Original method/named-definition
identity selects its existing constructor and source slot. Compact tail ranks
exclude definitions already placed there. The execution body remains a separate
compiler projection; it is not a second retained graph. E counting is mandatory:
an absent source producer is a located refusal, not permission to filter the
source again. OS/directives, discarded forward signatures and native-only
operations still need their real generic producer. This bounded change does not
claim that all source forms are preserved.

| Evidence directory under `build/l2_harness/` | Verdict | Scope |
| --- | --- | --- |
| `critical_graph_original_root_01` | GREEN, 8 | First original-unit order witnesses |
| `critical_graph_original_root_02` | No fixture verdict | Incorrect selection filter; not evidence |
| `critical_graph_original_root_03` | RED, 15 of 17 | Driver L1 member-argument spelling error; corrected by a local width variable |
| `critical_graph_original_root_04` | GREEN, 17 | Original source order, actual parents, copy and root-order mutants |
| `critical_graph_original_root_05` | RED, 1 of 14 | Dormant fixture placed `return: ()` at column zero; that is a root operation, not a sub trailer |
| `critical_graph_original_root_06` | GREEN, 11 | Eight fixtures, native/cleared-root order, dormant DIV/MOD, order mutants and translation-only zero-divisor pin |
| `critical_graph_raw_c_01` | RED, 12 of 20 | Twelve safe native C-operation positives expose the missing retained source producer; five located root-return refusals pass |
| `critical_graph_local_callable_place_01` | RED, 2 of 7 | Old root-order shape plus an unsupported hosted field-call fixture setup |
| `critical_graph_local_callable_place_02` | RED, 1 of 4 | Scalar-read hosted fixture reaches the actual invalid flat-slot constructor |
| `critical_graph_local_callable_place_03` | RED, 1 of 7 | Hosted effect and two local-procedure regressions pass; old root-order shape still fails before execution |

`original_root_06` staged translator source SHA256
`01E8CA6C22C41DF67580F26608855A834E6E0BCDD5F7E8D1DB9FD661C70C51C6`
and executable SHA256
`49B543680ACA74A33C38B04B167E9DAEE3A958E813AC4C0725B6184141CB849E`.
Its root-order mutants actually swap two distinct fields, fail graph assertions
and retain the expected program exit 7. Dormant literal-zero DIV/MOD operations
remain present but are never executed; no C undefined behavior is used as proof.
The fixture trailer was corrected without changing the parser.

The raw-C positive fixtures use the ordinary exit message and retain their
original literal payloads. Empty output is checked as one empty program line,
not discarded by a truthiness check or invented from a trailing newline. The
positive-output assertions have not passed yet: mandatory original-source
counting refuses the missing C-operation producer. These failures must be
fixed by retaining native-only source generally, not by a C-name allowlist,
an OP_NONE substitute or restoring the filtered-root fallback. The five
passing negative rows pin located valued-root-return diagnostics; they do not
prove a C-argument validator and do not execute invalid raw C calls.

`local_callable_place_03` staged translator source SHA256
`97CF90B9326E748EE41656EA65C05142B18B680CA99EEBCBD35ED3632AE5FA35`
and executable SHA256
`75B003A2F630B7949814AB37A1277685437F89B0647B96694CA517BAEFD57F91`.
The connected field constructor now uses the completed GraphField holder/child,
not a fabricated root slot and `own_uchild = -1`. Deferred Structure/callable
fields consume their actual ordinals before later numeric fields. The obsolete
local-namespace flat-index patch pass is removed. Local procedures still build
their real objects in their reached runtime constructor; no substitute unit
object is allocated. After this measured run, the constructor pass moved after
unit reference wiring to avoid copying an incompletely wired global model;
that new ordering is not certified by `_03`. Exact field-identity/parent and
post-callable-field tests are being added. Effect 7 alone is insufficient.

### Latest completed frozen full gate

`critical_graph_fix_full_06`: **RED, 32 of 1249**. Nine `_05` failures disappear,
and no new failure identity occurs. It staged translator source SHA256
`AC1BE69317AD36CB4342C4F8A2209CC7E0030FBD429B52482F4136ABE0F8D6B9`
and executable SHA256
`601BB0B7E5CDBBFD9FD314D556E13FE5C2AB53C57F7367353E509617E98BFA29`.
It predates the original-unit and hosted-constructor changes above and is not
a current-source verdict. Its complete remaining identities and diagnostics
are in that directory's `summary.txt`. No failed row has been waived wholesale;
stable twins, graph release and pointer implementation remain pending.

## 5. Full gate / release status

Full harness `build/l2_harness/critical_graph_fix_full_01`: **RED, 36 of 1222**.
Exact FAIL lines equal the 36 lines in Grok's `critical_graph_bug_full_15`
(36 of 1175); all 47 added targets passed. This full run predates the final
mutation classifier and RET/shared-place changes and is not a full verdict
for those later bytes. No old expectation was changed to remove a failure.

The subsequent full harness `critical_graph_fix_full_02` is **RED, 40 of
1233**. Relative to that earlier 36-failure list, own-span ceased failing its
old translation-only row and five new pre-execution pins failed: the return
location, owned RET sibling, and three control-body native temporary names.
All five were individually reviewed and then migrated as described above;
fresh focused runs are green. This does not turn the old full run green.
The earlier remaining failures have not been waived or changed wholesale.

Fresh full harness `critical_graph_fix_full_03`, staged from document HEAD
`0c3ee212`, is **RED, 35 of 1236 targets**. All five reviewed pre-execution
failures above are absent; the other 35 FAIL texts are exactly unchanged from
`full_02`. The three additional walked control-body aliases pass. Its translator
executable has SHA256
`653078EAC0BA3C6B76F637F639B73514CE68898254F889CDB204AB6A1D998F36`.
This verdict applies to the frozen source hash above, not to the subsequent
construction-boundary edits. None of the remaining rows has been waived.

Exact remaining fixture identities (their complete diagnostic texts are in
that evidence directory's `summary.txt`):

```text
entry_puts_empty
entry_puts_bad_arg
entry_puts_extra_arg
entry_puts_nested
entry_puts_triple
entry_puts_triple_lead
entry_puts_triple_lead_sq
entry_puts_triple_long
entry_puts_triple_runs
entry_puts_triple_seven
entry_puts_triple_seven_sq
entry_puts_triple_single
entry_ret_tr_puts
entry_ret_tr_two
unit_arr_path_read
entry_parse_min
unit_make_adder
unit_capture_struct_whole_refused
unit_walk_make_adder_native_note
unit_walk_d105_nested
unit_walk_struct_formal
unit_root_model_field
unit_root_div_zero_refused
unit_discard_calls
unit_arg_addr_pointer
unit_puts_main_beside_method
unit_colon_method_lexical_model
unit_field_path_unit_colon
unit_field_path_struct_rebind_refused
unit_addr_slot_structure_projection
unit_addr_entry_name_collision
unit_ptr_grow
unit_native_activation
unit_matrix_callable_struct_identity
unit_matrix_path_struct_rebind_refused
```

Fresh full harness `critical_graph_fix_full_04` is **RED, 35 of 1245 targets**.
Its complete 35 FAIL texts equal `full_03`; all nine newly added targets pass.
It staged translator source
`14FB2F82CE54EBB06D7217D4B65418AA5D6044CC54EAE249BD42C9B23087D68F`
and built executable
`B236C7165D1012BCF95D86D0A6C614D350F3A3B3E6ECF7E3D861F8A23EA8BE42`.
The subsequent common traversal cleanup has the `_05` focused verdict above,
not a full current-source verdict. No old failed row was waived to obtain this
unchanged failure list. Stable twins remain untouched.

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

# critical_pointer_to_struct_bug — address-taking collapses a Structure reference level

Date: 2026-10-02. Priority: **CRITICAL / P0**. Status: **OPEN**.
Owner: Codex (single writer/build slot). Work in progress, not an implementation release.

## 1. Order and authority

Take this ticket **after critical_graph_bug**, before
[structure_reference_application_refactor](structure_reference_application_refactor.md)
and the remaining [v2 plan](../../next_core_tasks_v2.md). Preserve the current
writer's source and active gate; do not start a competing writer/build.

The author identifies this as a pre-existing bug, independent of the new
application/reassignment proposal. The exact clarification is in
[the journal](../../LMX_blog/2026-10-02.md#structure-reference-address).
Norms: [L2 §18](../../docs/L2_spec_en.md#lowlevel-address),
[L3 §12](../../docs/LMX_semantics.en.md#dynamic), and
[L1 projection](../../docs/L1_spec_en.md).

## 2. Required invariant

A language Structure is held by reference, not as a C by-value aggregate.
Reading addressable A yields its held reference, conceptually `Lmx *`.
Unary `@A` addresses the actual cell holding that reference, conceptually
`Lmx **`. It must not return A's descriptor again. Every address level is
preserved; declaration provenance, callable status, root position, pointer
spelling or native versus interpreted execution creates no exception.

For a graph-declared LMX Structure `x`, distinguish descriptor `D`, its graph `void *` slot
`S` holding `D`, and an explicit reference binding's typed pointer-pool cell
`P` holding `S` when `@x` is retained there. `x` reads `D` from `S`; `@x`
addresses `S`, not a second descriptor. Following `@x` reaches the same
referent while keeping the distinct reference depth; under current path
precedence literal `@x\field` means `@(x\field)`. A checked write through
`@x` changes `S` and subsequent reads of `x`, not the old descriptor.

The same storage rule applies to Array descriptor references, reference-valued
elements/fields, own values, formals and dynamic inputs. Primitive `@x` still
addresses its primitive cell. `@array[i]` addresses the selected element cell,
not the element's pointee when that element holds a reference.

For a graph declaration the target is its real stable reference place. For an
activation-owned formal it is that formal's own stable cell, not the caller's
variable, a transient ABI argument box or a cached graph value. Address-taking
does not extend lifetime or create a permanent companion graph.

`A` and `@A` differ in depth. In particular, `test(A)` and `test(@A)` cannot
be made synonyms by silently stripping an address level during admission.
Signature descriptions are not executed, but that does not erase actual
argument operations. Preserve primitive C99 behavior and L3's prohibition on
numeric address manipulation, not on portable references to reference cells.

Reading a Structure name obtains its already held descriptor reference.
Assignment to a reference place addresses the destination's real cell and
stores that admitted reference there; a C value such as `Lmx *` and the
address of its storage (conceptually `Lmx **`, physically `void **` for a graph
slot) have distinct roles. Any actual pointer-value conversion needed by
assignment belongs to the directed, Message-local primitive conversion
contract, followed by `implements` for the referent, not to a table of
Structure-model pairs. The present `primitive.convert` lowering only handles
numeric primitive codes: pointer-depth conversion is implementation debt, not
an already functioning table row. A mere graph-slot load/store must not be
mistaken for a semantic conversion or implemented by dereferencing `void **`
as `Lmx **`.

## 3. Confirmed source evidence, not a runtime claim

Inspected the live development translator on 2026-10-02 while Grok owns its
graph-repair WIP. These are symbol anchors, not a frozen tested checkpoint:

- `dev/l2src_sandbox/l2trans.lm1`, `l2_address_name`: descriptor branch selects
  `l2_formal_raw` instead of adding the address level with `l2_address_type`.
- `l2_emit_address`: descriptor formals use `l2_tok_formal`; named Structures
  use `l2_type_inst`, which emits `lmx_arena_ref_struct`, a descriptor load.
- `l2_own_addr`: an own Structure slot returns its held/cached reference;
  the comment explicitly calls `@mo` the slot value.
- `l2_rw_address`: ADDRESS is emitted only when `descriptor == 0`; descriptor
  cases return the ordinary value projection instead.
- `lmx.h.lm1`, `lmx_arena_refs.lm1` and generated C already store child values
  as references. The bug is address projection, not general by-value storage.

The former docs claimed `@Structure` meant its descriptor and that `A`/`@A`
could supply the same actual. Those assertions are withdrawn. Existing tests
that enshrine them must be migrated, not cited as authority to keep the bug.
No new code build or runtime reproduction is claimed by this ticket creation.

### 3.1 Additional generic pointer-consuming ABI evidence (2026-10-03)

Read-only review of the still-unreleased development walker found another
representation gap at the same consuming boundary:

- `lmx_walk_actuals` accepts any `LMX_WALK_VALUE_REFERENCE` when
  the witness is CHAR_PTR, POINTER_BASE, LMX or DESC, without establishing
  its actual representation/depth for that witness.
- `lmx_walk_call_prim_dispatch` returns any reference result as
  `result.ref` without establishing the receiving return contract.

A char-Array datum is a real descriptor reference with exact length and no
implicit NUL. Its descriptor address is not its character backing and cannot
be supplied as a primitive `char *` just because both are references.
The ordinary conversion/admission contract must select the representation;
no Array-specific reinterpret cast, inferred depth stripping or untyped
reference box is permitted. The same principle covers Structure and other
reference-valued actuals/results.

This is source evidence, not a claimed runtime repair. Retaining quoted data
in the graph must not mark the datum machine-only. A genuinely raw C access
is separately native-only. Native success of a quoted-to-pointer fixture
does not certify walker consumption or close this ticket. Before adding a
forced-walker pointer-literal acceptance row, establish this generic
consuming contract with positive and incompatible-representation witnesses.
The ordering in §1 remains unchanged; if graph acceptance depends on this
consuming repair, record that dependency explicitly rather than waive the
gate or silently introduce a conversion.

### 3.2 Current native/walker witness (Codex, 2026-10-12)

`unit_output_named_receive_address` is an existing positive fixture: a
method-local `receiveMessage: m` is executed twice, first with a letter and
then with an empty inbox. In both cases `@m` must be the nonzero address of
the same slot even when its stored reference is zero. The full harness
`codex_used_closure_full_156` reports exit 82, not 7, in both native and
walked modes. The generated native expression for `@m = 0` compares the
working descriptor `l2_q4` itself with zero. This locates the collapse in
the shared address projection, not in mailbox delivery.

The exact live code path still has four linked halves: `l2_address_name`
marks a Structure-own slot as `descriptor` and suppresses the added address
level; `l2_own_addr` returns the cached Structure for that slot;
`l2_rw_address` omits `LMX_WALK_OP_ADDRESS` for `descriptor`; and even if it
emitted the op, `lmx_walk_place` currently sets `place.address` to the
Structure stored in a graph slot rather than to that slot. Fixing only one
half cannot satisfy native/walked parity. Preserve the distinct read-place
and address-of-place semantics in one resolved-place route, including a null
reference whose storage exists. The same audit must cover formals, namespace
fields and Array elements as §5 requires; this witness does not close the
ticket.

### 3.3 Work in progress (Codex, 2026-10-12; not a release)

The translator now distinguishes a graph/reference slot's address from the
descriptor stored there, and the walker carries the physical storage place
separately from its read/write value. The shared Structure-reception path was
also corrected to consume the stored descriptor rather than the newly exposed
slot address. Focused evidence: `codex_pointer_descriptor_180` (7/7),
`codex_pointer_migration_182` (17/17), `codex_pointer_manydecl_184` (4/4),
and `codex_pointer_c_audit_185` (5/5), all under `build/l2_harness`.
The kernel gate `codex_pointer_place_kernel_167` was 304/304 for the walker
change. These focused gates do not close the ticket or certify the later
fixture edits as a full set.

The C99 storage audit remains open. In the generated
`codex_pointer_c_audit_185/gen/unit_address_reference_cell.c`, `takeCell` has
an `Lmx **` formal and executes `(*l2_t0) = l2_t1`, while the actual storage
comes from a pointer cell represented in the kernel as `void *`. Passing its
address as `Lmx **` works on the tested compiler but is not a C99 aliasing
proof; a cast does not change the effective type or guarantee all pointer
representations coincide. Graph child slots are likewise `void *` elements.
Resolve this generally for typed pointer cells and graph slots,
including Array and foreign-pointer depths, before checking the C99 box in
§5. The generic walker actual/result type check in §3.1 also remains open.

Some old fixtures use `r: @m` to assign a descriptor through a known
reference. That form is superseded by the *later* explicit reassignment rule
`@: r m`; it must not be retained by stripping one pointer level or by a
failed-call fallback. Keep those failures visible until the dependent
application/reassignment stage is implemented.

### 3.4 Hidden Structure input witness (Codex, 2026-10-13; not a release)

The first full post-slot run, `build/l2_harness/codex_pointer_full_196`, is
RED: 377/3082. One diagnosed family was not an address failure: the walker
evaluated the hidden `cfg` input of `unit_s2_vis_branch_below_walk` as a
Structure value (`LMX_TYPE_LMX`), while its method-part input witness still
described the native `Lmx *` transport cell (`LMX_TYPE_POINTER_BASE + 100`).
The native adapter already receives the ordinary address of the activation's
reference storage. At this intermediate checkpoint, the method-part graph and
walker call contract used the Structure value category for such a hidden input;
this did not introduce a new language conversion or an ABI box. That category
lost the exact pointer type of a stored null and was later replaced by the
closed pointer-cell witness described below. Focused `codex_pointer_hidden_203`
passed the witness in both native and forced-walk modes;
`codex_pointer_hidden_204` also passed its direct-after variant and a held
call, while four other selected failures remained. The seven existing
address/reference fixtures in `codex_pointer_preserve_205` stayed GREEN.
`codex_pointer_full_206` completed RED, 350/3082. It was a diagnostic
snapshot, not a release: 61 former failures passed and 34 other rows
regressed against `codex_pointer_full_196`. A later focused boundary repair
made `codex_pointer_hidden_216` GREEN (15 targets): its selected rows cover
a named Structure, a typed empty reference, method-hidden inputs, and the
rejection of an extra address level. The latter run is not a full-gate
certificate. Its graph-reference type witness has subsequently been made
self-contained inside its contract, and a direct walker test was added;
those newer bytes still require their own gate. None of this closes §5 or
the C99 storage debt.

### 3.5 Common path actuals and full checkpoint (Codex, 2026-10-13; OPEN)

The ordinary path contract now supplies the terminal model of a Structure or
typed reference field used as an actual or return value; native lowering reads
the reference field's held Structure and snapshots each actual before evaluating
the next one. The old route remains only as an unresolved-path diagnostic
fallback; it must not become a second semantic resolver. Focused
`codex_path_actual_225` ran 13 targets: the four `unit_ns2_ref_arg` and
`unit_ns2_ref_return` native/walked rows passed, while the two nested
`unit_ns2_ref_admit` rows still fail in the distinct recursive correspondence
map path. The T7 constructor and method-rooted path rows pass in the full run.

Full `build/l2_harness/codex_pointer_full_226` tested translator blob
`4942c5cf4174f9d39ad9aa0ecadd0b32af7ede04`: RED 102/3084 versus
`codex_pointer_full_220` RED 110/3082. Comparing failed identities gives
exactly eight FAIL→OK and no OK→FAIL: `unit_recv_use_path_from_method` and
`_refused`; `unit_ns2_ref_arg` and `_walk`; `unit_ns2_ref_return` and `_walk`;
`unit_t7_nested_model_source` and `_walk`. The required `@m` receive-address
rows pass in native and forced walk. The separate kernel gate
`build/l2src/codex_pointer_kernel_227` is GREEN 304/304. L3
`build/l3_selftest/codex_pointer_l3_229` passes all 11 suites and four type
budgets after accounting for the five reparent transaction records already in
the shared header (83/128 names on Windows). The first L3 run `_228` failed
only the stale expected count, not an executable suite.

After the three passing witness comments were corrected, the exact final
fixture bytes ran in `build/l2_harness/codex_pointer_full_230`: RED 102/3084,
with the identical failed-ID set as `_226`. The translator blob remained
`4942c5cf4174f9d39ad9aa0ecadd0b32af7ede04`.

This is a non-release checkpoint. `unit_ns2_ref_capture` still stops at the
explicit item-738 refusal to copy a captured Structure field; nested admission
still needs general recursive maps. Several other pre-existing red rows belong
to the later reference-application rule. Most importantly, §5's C99 typed
pointer-cell storage and exact-depth retained-address witnesses remain open;
passing C99 compilation alone is not their proof.

### 3.6 Physical graph-slot decision and bounded native repair (Codex, 2026-10-13)

The author confirmed the general storage rule: a Structure/Array reference in
an LMX child slot is physically `void *`; `@@: Model` accessing that slot must
use its real `void **` type. A machine C99 `T **` remains typed and requires a
real `T *` cell. Logical admission and source reference depth do not change.
The existing `unit_address_reference_cell` witness now
also writes through the root graph slot and through an activation-local formal,
checking that the latter does not write back to its caller. A trial which
rewrote every interned `Lmx`/`VoidArray` native type to `void *` passed the
focused `codex_graph_slot_matrix_237` gate (12/12), but was withdrawn before
release: `l2_foreign_intern` strips the `c.` door and collapses raw `c.Lmx`
with the language's graph projection, and raw `c.VoidArray` with an internal
Array descriptor. A global type-name rewrite would incorrectly change C99
machine storage. The two interrupted full gates `_235` and `_238` tested only
discarded intermediate bytes. No full gate on the final bytes is claimed.

Native lowering must carry the *resolved place's physical storage provenance*
through address and call generation: `void **` for a graph child or generic
reference cell, typed `T **` only for an actual machine `T *` cell. The
semantic type and its admitted model remain separate; neither `Lmx` nor
`VoidArray` spelling alone supplies this proof. This applies to Structure and
Array alike and needs one common place/address route, not a name-specific
fix. The checked-in translator still has the C99 aliasing defect.

The separate machine-pointer debt is still open: `lmx_pointer_new_profiled`
currently allocates generic `void *` pointer cells, and `c.VoidArray **` or
`int **` must not be used to dereference such a cell as though it were a typed
`T *` object. That requires exact typed construction/load/store across all
machine C99 pointer kinds, not a cast or a special case for one model.

### 3.7 Graph-slot native representation, verified intermediate slice (Codex, 2026-10-13)

The translator now retains the source `c.` door in its compile-time foreign
type identity. This prevents raw `c.Lmx` / `c.VoidArray` from being collapsed
with the language's Structure / Array projections merely because the C word
is the same. Native declarations, formals, return types and typed temporaries
for the language's graph references use `void *` and `void **` at the actual
graph-slot depth. The explicit C99 door keeps its native `T *` / `T **`
spelling. `unit_address_reference_cell` shows `void ** l2_p1_0` for
`@@: Model`; `unit_address_array_descriptor` still shows a typed
`VoidArray **` for its explicit `c.VoidArray` binding. Focused gates
`codex_storage_probe_245` (9/9) and `codex_storage_oracles_247` (7/7)
passed; the latter updates four L1-text expectations from logical `Lmx *`
to the new physical `void *` without reducing their runtime assertions.
The first full gate `codex_storage_full_246` had 106/3084 failures: exactly
four new failures were stale L1-text expectations for the new native spelling,
not runtime failures. After correcting those expectations, the full gate
`codex_storage_full_248` had 102/3084 failures. Its failed-ID set is
identical to the previous exact-byte baseline `codex_pointer_full_230`
(102/3084; zero additions or removals). The translator source SHA-256
`2C77E399B4A2B5EE01B8F2F9A5222F213CD65C616B5708E894167F0C650EAF2A`
matches the staged source tested by `_248`. This intermediate slice is
regression-neutral against that baseline, not a clean-kernel certificate.

This is *not* ticket closure. In the generated
`unit_address_array_descriptor.c`, `l2_q10_from[0]` is a generic pointer
cell allocated through `lmx_pointer_new_profiled` (`void *` storage), but
`@p` is still formed as `(VoidArray **)l2_q10_from[0]`. That cast does not
turn the arena cell into a C99 `VoidArray *` object. The native, walker and
copy routes must share one exact physical-place contract for such generic
cells and for genuine machine `T *` cells. Runtime success and C compilation
do not establish C99 effective-type correctness for this remaining case.
The author's 2026-10-13 answer ([verbatim record](../../LMX_blog/2026-10-13.md))
confirms the graph-slot `void *` choice; it does not license a `T **` cast
over that slot. Keep raw C99 `T **` only when the addressed cell really has
the machine `T *` type. The next repair must establish that fact at allocation
and carry it through native access, walker access, Array elements and full
copy; changing only the declaration spelling cannot close this witness.

### 3.8 Physical pointer-pool groundwork (Codex, 2026-10-13; intermediate)

An arena pointer pool now records its physical C99 cell stride and read/write
operations once in its descriptor, not in each graph cell. A newly created
`T *` cell can therefore be initialized and accessed through a real `T **`
inside type-specific operations, while ordinary graph/transport `void *` cells
keep `void **` operations. Reusing one `(type, profile)` pool with a different
physical contract is refused. The graph copier carries the source pool's
contract into the destination, and the walker uses that contract for graph
pointer primitives while keeping activation scratch transport distinct.
`lmx_pointer_typed_selftest` uses a real `int *` cell and copies its reachable
value to another arena, then releases the source. The exact-byte kernel gate
`codex_pointer_common_254` is GREEN 305/305.
The full translator harness `codex_pointer_common_full_255` reports 102/3084
failures, with exactly the same failed-ID set as the prior
`codex_storage_full_248` baseline: zero new or removed failures. After that
staging, the self-test was strengthened to check the copied pointee address
and the destination pool's exact callbacks; the final exact-byte kernel gate
`codex_pointer_common_final_256` is GREEN 305/305.
The first L3 run exposed two raw `LMX_TYPE_MSG_REF` witness allocations in
`l3_thread.lm1` and its mail-primitive self-test that bypassed this common
pointer-pool constructor. Both now use `lmx_pointer_new_profiled` in their
existing profile; `codex_pointer_common_fixed_259` passes all 11 L3 suites
and the four header-type budgets. The budget expectation rose by precisely
two for `LmxPointerCellRead/Write` (85/128 names on Windows).

This is infrastructure, not closure: generated machine-pointer declarations
still call the generic `void *` constructor, pointer Array backing is still
generic, and the native `c.VoidArray **` witness has not been repaired. The
generator must select exact typed construction/access for genuine C99 pointer
cells before any `T **` dereference; graph child slots remain `void *`.

### 3.9 Arena-cell reads and GC use the pool contract (2026-10-13)

The next bounded slice makes selected arena pointer-cell reads and writes use
the owning pool's read/write contract rather than the legacy `void **`
helpers. A lexical hidden-input fallback boxes the held value before crossing
the generic ABI; this is value transport, never the address target of a
language `@` or `@@`, and it does not expose a typed arena cell as a `void *`
transport box. Add an own-pointer lexical-fallback `@`-formal witness before
closing the ticket. GC invokes the same pool read operation when marking pointer primitives.
A self-test places an actual `int *` cell in a typed pool and observes that
marking calls its exact C99 reader. The ordinary child slot of `Lmx.array`
remains physically `void *`; `@@: Model` must access that slot through its
`void *` storage, not through an `Lmx **` cast. A machine `T **` is appropriate
only when the cell itself physically stores `T *`.

This slice does **not** close the ticket. The translator still has generic
pointer constructors; pointer Array backing, native paths, walker and kernel
record traversal need their own exact-storage audit. Never infer a C99 proof
from matching pointer sizes or from a green test on one machine.

Before generated per-type callbacks are admitted, close the cross-unit pool
case: foreign FT numbers are currently unit-local, while the allocator finds
a pool by numeric `(kind, type, profile)` and compares callback addresses.
Two units can use the same number for different physical C99 types, or
different callback functions for the same type. Neither equal stride nor
equal numeric FT proves interchangeable access. The cell address already
selects its owning range and pool; any repair must preserve that physical
contract without a runtime name registry or metadata on individual cells.

Measured checkpoint on exact source SHA256
`CC9F616DC80C5DF46D35FF103345E0C86A8DA008FBC7961A67175310521F3AB9`:
`codex_pointer_access_full_266` is RED 102/3084; the 102 failed target IDs
are exactly those of `codex_pointer_common_full_255` (no new regression).
`codex_pointer_access_final_267` is GREEN 305/305, including the typed GC
reader self-test. `codex_pointer_access_268` passes all 11 L3 suites and four
type-budget probes. The docs checker and whitespace check pass. The next
slice must not call this ticket complete merely because those gates pass:
generator constructors, pointer-Array backing and its copy/walk/reparent
consumers are still open.

### 3.10 Physical pool identity and lexical pointer fallback (2026-10-13; intermediate)

The arena must identify a primitive pointer pool by its full physical
contract: kind, unit-local numeric type, profile, stride, and exact C99
read/write callbacks. A coincident numeric type or pointer size is not proof
that two cells have the same C representation. The generic `void *` allocation
and lookup routes select only their own canonical pool; typed `T *` cells use
the same allocator with a different physical contract. The cell address and
its owning range/pool select the access operation; no name registry or
per-cell tag was added.

An absent primitive pointer input can use the same lexical fallback rule as
an absent numeric input. At call time its source is the lexical occurrence's
physical cell, not a stale caller working-cache value or an ABI transport
box. `unit_pointer_lexical_fallback.lm2` exercises a stable activation-local
`@p`, rebinding through `@@`, and both native/walked roots and methods.
The cross-unit pool and attach self-tests run in the kernel gate. On exact
translator SHA256 `D16D78345C410E9B0202E056E6835C424A0D1369DC1F2022B6D9E9B34DA96031`,
`codex_pointer_pool_collision_282` is GREEN 305/305. The full harness
`codex_pointer_pool_full_284` is RED 102/3088: all 102 failed target IDs are
identical to `codex_pointer_access_full_266`, with no new failed ID. All four
native/walked variants of the new lexical-pointer fixture pass. The staged
translator and arena source hashes match the live sources; L3 is checked
separately. `codex_pointer_pool_285` passes all 11 L3 suites and all four
type-budget checks. The docs checker and whitespace check pass.

Remaining debt includes exact typed construction in generated native code,
typed `Array<@T>` backing and all copy/walk/reparent consumers of that backing.
There is also a separate timing gap to test: a native entry forms an absent
hidden input at activation entry, while the walked `ARG` fallback may form it
at first use after an explicit path mutates the source cell. Preserve the
distinction between value reading and a forwarding-only ARG when repairing
that gap; do not add a new runtime name table or auxiliary source graph.

### 3.11 Physical `Array<@T>` backing and copy aliases (2026-10-13; intermediate)

The kernel has a typed constructor for fixed `Array<@T>` whose backing is
actual `T *` cells. The arena pool owns their exact stride and C99 read/write
operations; the `void *` member of the Array descriptor is not a license to
read those cells through `void **`. Array qualification, coverage traversal,
graph copying and walker element access use the backing's physical pool.
Graph copy registers the descriptor and every backing-cell address in its
shared address map before copying pointee values. An alias to `@array[i]`
encountered before the descriptor resolves its owning Array by physical
range, and both encounter orders select the same copied cell. A negative
pre-fix witness failed at exit 19 (`codex_typed_array_alias_red_287`);
the kernel gate `codex_typed_array_physical_final_290` was GREEN 305/305,
including both alias orders and source-arena release. After the Array element
lookup was strengthened to reject a claimed span beyond the issued backing
chunk before pointer arithmetic, the final exact-byte gate
`codex_typed_array_bounds_final_293` is also GREEN 305/305.
The full L2 gate `codex_typed_array_bounds_full_294` has 102/3088 failures,
exactly the same 102 fixture IDs as `codex_pointer_pool_full_284`; no new
failure ID appeared. `codex_typed_array_bounds_295` passes all 11 L3 suites
and four type-budget checks. The full gate remains RED, so this is an
intermediate checkpoint, not ticket closure.

This is not ticket closure. Generated native declarations still select the
generic constructor, and Message reparent edge scanning/publication still
needs exact typed-cell access. The separate absent-hidden-input activation
timing gap remains. Do not infer those properties from the kernel-only gate.
The present pointer-first owner lookup scans issued Array descriptors in the
source arena. Before calling that path complete, constrain it to descriptors
reachable in the selected copy closure (including used/partial-copy and
retained-profile boundaries): an unrelated malformed descriptor must not
capture a cell or cause an ambiguity refusal. The existing pool index knows
issued chunk cells, not original per-Array allocation boundaries. Fixed
Array `data/size` must remain stable, or issuance provenance must be proven
by arena bookkeeping; merely finding the same pool is not that proof.
For the reparent path, keep only operation-local scratch edge records: each
record carries the real cell address and its physical read/write operations.
Graph `void *` slots use the canonical operations, actual `Lmx *` members use
a typed pair, and pointer primitives/`Array<@T>` elements use their pool's
pair. Stage and publish compare/read/write through that pair, never by
casting all cells to `void **`; test a typed element redirected during an
`independent: msg newParent` preparation and then `adopt: msg newParent`.

## 4. Bounded repair route

1. Snapshot exact HEAD/source hashes after graph repair release; reproduce one
   Structure-address witness and record its native and walker behavior.
2. Trace common resolved value/place/depth metadata through declaration,
   formals, paths, Array elements, nested/returned Structures and admission.
3. Repair the shared address projection, then all native/walker consumers.
   Remove descriptor exemptions rather than add a new parallel address route.
4. Preserve source graph shape, occurrence order, reference lifetime, parent,
   actual-callable selection, and the absence of implicit merge/C-valued copies.
5. Audit exact C storage types. A `void **` to `Lmx **` cast is not proof of
   C99 aliasing correctness. Do not suppress strict aliasing or invent a
   descriptor wrapper/name registry to conceal the mismatch.
6. Update fixtures, normative examples and evidence together. Do not implement
   the later receiver/application change incidentally in this address slice.

## 5. Required witnesses

- [ ] `A` reads the descriptor reference; `@A` addresses its real reference
  cell. Observe both levels, not just matching generated strings.
- [ ] An admitted write through that cell changes the selected held reference,
  not the old descriptor, its parent, native entry or unrelated holders.
- [ ] Named/root/method-local Structures, callable formals, hidden inputs,
  nested paths and repeated same-name declarations follow the same rule.
- [ ] Array descriptor references and reference-valued elements add one level;
  primitive elements and existing flat/nested indexing contracts remain right.
- [ ] Positive exact-depth formals/returns work; incompatible depth is refused
  without implicit dereference. Null stored references remain present values.
- [ ] The generic actual/result ABI does not accept an Array descriptor or
  arbitrary reference as primitive pointer storage. Available conversions
  and structural admission are checked at their ordinary consuming place.
- [ ] Stable repeated address-taking, re-entry and recursion do not leak an
  ABI box, temporary, working cache or a previous activation's cell.
- [ ] Native and genuinely exercised walker paths agree; clearing only a root
  native word is insufficient evidence of a nested interpreted call.
- [ ] Mutant returning the descriptor instead of the cell fails a witness.
- [ ] The critical_graph_bug structural decoder/mutants still pass.

## 6. Gates and closure

Run from the repository root, sequentially, using fresh absolute evidence paths
and the repository's verified toolchain. The harness changes working directories;
a relative `-OutDir` must not be interpreted relative to its staged source tree.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/l2_harness.ps1 -OutDir C:/Nyasha_Planet/LMX/build/l2_harness/critical_pointer_to_struct_bug_01 -KeepAll
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_l2src.ps1 -Run -OutDir C:/Nyasha_Planet/LMX/build/l2src/critical_pointer_to_struct_bug_01 -KeepAll
python tools/run_l3_selftest.py --output C:/Nyasha_Planet/LMX/build/l3_selftest/critical_pointer_to_struct_bug_01
python tools/check_docs.py
git diff --check
```

Record exact fixture IDs, native/walker observations, mutations, source hashes,
full-gate failures compared by identity, and committed/pushed bytes. A focused
green probe is not a clean-kernel gate. Add `TAKEN <branch>@<sha> <UTC time>`
on ownership; `DONE <sha> <UTC time>` only after all acceptance is established.

Next: structure_reference_application_refactor, then the v2 dependency queue.

Дальше — продолжать `next_core_tasks.md` (активная очередь — `next_core_tasks_v2.md`).

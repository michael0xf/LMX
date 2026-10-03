# critical_pointer_to_struct_bug — address-taking collapses a Structure reference level

Date: 2026-10-02. Priority: **CRITICAL / P0**. Status: **OPEN**.
Owner: unclaimed. This documentation change is not an implementation release.

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

# Working state without load/cache/dirty publication

**Status:** applied documentation requirement, updated in English through 2026-11-21.
The former load-dirty mechanism and its publication rules are withdrawn. This file retains its name for existing
references and states the current [call-frame contract](../LMX_semantics.en.md#call-frame-20261115);
it is not evidence of completed runtime migration.

## 1. What remains

A normal independent call prepares its namespace from root DATA/CODE declarations under the common modifier
rules. Required contributions of `import`, `copy`, and `merge` are consumed through their specified CODE sources in the namespace, without an arbitrary DATA-body execution pass or P0 expansion. Its DATA is the selected executable Structure's actual parent; R0 has no DATA or user arguments.
All receivers stay as written in the source graph. Computation, binding, transformations, and acceptance of
field streams occur in the namespace. Terminal primitive declarations use the direct `{type value}` representation.
These leaves are included in the complete literal source graph at the addresses held by Structure cells.
Ordinary explicit graph assignment can replace any receiver structure, including `for`, `if`, `merge`,
`copy`, and `import`; executable updates use the existing compile/endturn boundary when required.
No separate uneditable code representation or restricted graph-mutation protocol follows from removing dirty.

An ordinary supplied actual suppresses its initializer. An unused computed input does not execute, and entry
has no general initializer pass. A supplied place-declaration form remains DATA and preserves its initializer
for later execution; its root declaration can supplement the receiving execution's namespace under the
[declaration-argument contract](../TZ/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md).

Variables/const become visible sequentially; user Structure/callable declarations retain bidirectional visibility.
Bare x and `@x` select the bound logical place. Explicit actuals, autofill, and the preserved fallback produce own
places; a write changes that place without copy-out. Transparent caller binding instead targets the caller's
real cell, so a write changes it immediately. Two-way private filters every implicit dynamic channel.
Own selected values/descriptions remain independent of later source-field replacement, without deep-copying
referenced objects. A demanded computed input initializes its activation-local place; later reads reuse the
place's current value. Reaching the declaration again may evaluate and assign a new RHS. Removal of dirty
publication does not require recomputation on every read, and this local state is not a permanent cache stored
in the source graph.

Explicit `D\x` and `C\x` paths inspect the source graph. For `int: field getValue()`, `@(D\field)` addresses the original
declaration record and does not evaluate `getValue()`. For a computed namespace input x, `@x` obtains the value as
required and addresses its local place. A ready terminal primitive already has its typed value record.
Reserved node selects lexical context and is not replaced by `parent(C)` or by a field-stream recipient.

Call entry does not copy the executable graph or build another program environment. Its ordinary frame
values and selected places do not form a working graph under another name. Native and interpreter execution
share the same place behavior; native locals have no arena tag immediately before their machine cell.
Graph edits do not automatically clear native. Explicit compilation followed by the ordinary endturn boundary
governs updated machine code; before that boundary executable edit timing is unspecified.
[Compilation](../LMX_semantics.en.md#explicit-compilation).

## 2. What is withdrawn

There is no load-dirty publication, automatic write-back at calls/exits, publication table, shared direct-access
value cache, or flush receiver. A transparent write through a caller place must not be replaced by temporary
state copied out at exit, and the fallback's own copy must not be turned into an alias.

`S[n] := p` writes a reference slot under the common Structure/`Array<@>` contract; it does not require the replaced
slot's former field requirement. Named `S\x := value` follows the target field's ordinary admission and write
contract and replaces the selected graph fragment. A subsequent access to that structural place observes the
new fragment; references to the previous fragment are not automatically retargeted. `uninit:T` has zero payload,
so replacing it with `{T value}` cannot preserve a preexisting T-cell address. Frame-local writes remain local.
[Author clarification](../TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).

## 3. What publication still means

Message publication and exposure of a construction result retain their own contracts; they are not local-frame
write-back. Ordinary local values, GC, typed storage, copying maps, and admission remain necessary.
Accepting import/copy/merge output in DATA is namespace work, not an implicit publication of computed fields
into the clean source Structure. `import`, `copy`, and `merge` always consume CODE arguments, even in DATA placement: bare references and anonymous Structures remain values; explicit source calls execute when consumed. Import preserves original references and parents; copy/merge preserve their
own operation's graph relationships.

## 4. Where checks belong

Clean-graph checking uses the common preparation/admission mechanisms without executing candidate bodies,
initializers, or `test`. Reached interpreter calls use standard `implements`, with admission facts scoped to their operation/reception;
prepared native calls do not automatically run runtime `implements`. Explicit `implements` executes in either
path, and actual receiving/value checks retain their contracts. `sys\compile` separately runs its required
post-clean-graph, pre-C build/test phase through ordinary receiving contracts; it does not scan all DATA tests
or launch the application's entry. `sys\check`, `sys\checkL3`, and `sys\translate` execute neither application
code nor tests. Translation returns L1 text and diagnostics, not a second authoritative LMX graph.
No speculative infrastructure, universal wrapper, hidden compiler, or permanent environment cache follows
from removal of dirty state.
Record actual native/interpreter and bridge results separately from these documentation requirements.

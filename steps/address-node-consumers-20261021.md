# Address nodes consume the complete prepared path

Four direct node consumers now use the common address result instead of
trying the legacy single-index adapter first. The receiving typer, native
leaf typer, address check and native preparation preserve the complete path,
its selected types, field maps and original index expressions. Two language
programs pass 16 actual native/walker runs, including writes through captured
addresses into reordered implements layouts. This is a private compiler
slice, not closure of all path consumers or public-dev.

Base main is `e92662aca3e18eec9265c987607e7dd41863260a`. The candidate is
`build/codex_address_nodes_148`; final frontend is
`build/codex_address148_build_05`, with unchanged frozen144 headers.
The [patch](witnesses/used-scope-20261020/address-nodes148-u0.patch) replays
over [Private147](receiving-value-type-20261021.md) using
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.

## Node consumers and index validation

`l2_colon_simple_ty`, `l2_native_leaf_ty`, `l2_check_addr` and
`l2_prep_context` no longer directly call `l2_indexed_node`. The address check
also loses its three-field/one-step retry and separate bare-name retry.
`l2_prep_addr_context` no longer emits a foreign address by reparsing a
three-field body. The common address result owns the selected path until its
consumer releases it.

`l2_check_resolved_indices` validates the original index spans for Array
places and addresses. An Array step receives size_t through the ordinary
receiving rule; a machine-pointer step keeps its resolved machine contract.
The helper checks capacity, the first-index prefix and actual index count.
`names` means the number of steps before the first index, not all name steps:
the valid mixed grammar `p[0]\x[0]\y` has n4, names0 and indexed2.
Initial14801 used the wrong equality and refused 12 of 85 units; corrected
geometry restores all 85 without changing their generated L1 bytes.

The [instrumented fixture](witnesses/used-scope-20261020/address-nodes148-nodes-test.c)
uses real P0 nodes and generated frontends. Published147 fails 56 of the 210
shared assertions; final148 passes all 216, including six additional geometry
checks. Ranks1,2,6,65,129 and qualified/unqualified pointer cells exercise all
four consumers. Each selects its root and enters the common semantic fold
once, with no direct node-client call to the old adapter. Exact type checks
compare the declared C type and qualification, not incidental interner IDs.

The fixture separately reports total adapter entries. In final148 CHECK,
index expressions still enter the legacy field-span package: at rank129 it
records129 legacy entries and517 total grammar-adapter entries, although the
outer path has one root selection and one semantic fold. Native preparation
has130 total adapter entries. These are explicit remaining consumers, not
evidence that every expression now has one parse. Native leaf kind also keeps
its existing unknown result for these nonprimitive pointer expressions; the
receiving query, rather than that category, retains their exact address type.

## Actual values and observed interpretation

The [mixed positive](witnesses/used-scope-20261020/address-nodes148-mixed-frame.lm2)
changes the existing deep path's address spelling to an actual `@` Frame.
It traverses two indices, references and reordered models, checks7 then67,
writes71 through the captured address and verifies71 through the original
objects. Both index functions must execute exactly four times. Unrelated
sentinels29,31,13,19,17 and original model values remain unchanged.

The [mapped Array positive](witnesses/used-scope-20261020/address-nodes148-mapped-frame.lm2)
selects a field through a reordered Need/Have map, stores19, captures an
element address, writes31 through it and reads31 through the formal and
original Have. The sentinel remains23 and Array length remains3.

Together these programs pass16 actual runs: native/forced methods,
native/walked root and production/observed runtime. Four fresh strict-O2
unit objects and eight fresh links are used. The unchanged production143
runtime and the existing observation-only runtime are pinned by SHA.
Observed walked-body entries for mixed are0/1 in native mode and10/11 in
forced mode; mapped has0/1 and1/2. Thus the intended language bodies really
execute in the walker, not merely a native method behind a forced option.

The [mixed counterfactual](witnesses/used-scope-20261020/address-nodes148-mixed-drop.lm2)
writes67 instead of71 through the address. The
[mapped counterfactual](witnesses/used-scope-20261020/address-nodes148-mapped-drop.lm2)
writes19 instead of31. All assertions stay unchanged. All16 actual runs
exit1 as required, detecting the incorrect value after the address write.
These failures are not counted as positive language passes.

## Foreign C addresses use the existing projector

A refused opaque C member path with an already selected foreign root keeps
that complete record in the address result. Native emission uses
`l2_emit_raw_steps`; it does not retry the parser or invent a member type.
A successfully resolved language path or semantic Array contract does not
enter this representation. The old three-token native fallback is deleted.

The existing retained machine-path constructor now projects the selected
root and every ordered name/index step; its names-only base slicer is removed.
Addressing opaque C storage retains the written address operation and the
same selected path through the existing native-only constructor, without an
invented graph-cell witness, new runtime opcode or C-header field dictionary.
COUNT and EMIT use that same constructor.

The [C boundary positive](witnesses/used-scope-20261020/address-nodes148-foreign-value.lm2)
passes L2DispatchPair by value, takes its actual value-field address, writes
through memset and checks the nonzero value16843009 and unchanged wide member
using the explicit test header. The
[wide-corruption counterfactual](witnesses/used-scope-20261020/address-nodes148-foreign-wide-drop.lm2)
additionally clears the wide member while retaining the original nonzero
value and all assertions. Its four actual runs exit1, proving that the
neighbour check detects corruption independently of the value check.
Four root-native production/observed and
native/forced-option runs exit0. This C-only method remains native in both
options. Its exact positive executable is recovered from its verified archive
for croot11: the walked root actually exits3 UNSUPPORTED. That result
is preserved and remains an open capability, not converted to a green oracle.
The earlier [zero-value observation](witnesses/used-scope-20261020/address-nodes148-foreign-frame.lm2)
is retained as historical input,not proof of the wide member: zero masked
the test header's own failed-wide result. Final values09/10 use the nonzero
oracle instead; their source differs from the older values07 root experiment.
Earlier exploratory div_t examples also exposed unrelated L1 foreign-type
declaration and large-literal failures; they are not positive witnesses.

Runtime ABI, graph fields and opcode inventory are unchanged. Existing
SOURCE_MACHINE/typed-op storage still belongs to the open generic written-head
migration K03; this slice does not claim its replacement or a fully
interpreted C boundary or conversion receiver.

## Verification inputs and remaining work

Final05 passes336 source-linked metadata assertions,420 common pointer-index
assertions,200 dispatch assertions and the same two located Array binding
refusals. The85-unit source matrix verifies152 selected input pins and emits
L1 byte-identical to published143. It is not a fresh85-unit C/runtime gate;
the inherited162 GREEN plus the same8 copy RED results retain their original
runtime scope.

The terminal recipe is `build/codex_address148_terminal_03.ps1`; its receipt
and summary are `build/codex_address148_terminal_03.inputs.sha256` and
`build/codex_address148_terminal_03/summary.json`. The compiler source is
`2AEFC15C592CBA35F6C8A858CA9C69655CE6031BD6166710FF6751305F9E6822`,
generated frontend C is
`42FC59516C7FDFFC4526B18EA28FF63388B4383045345B48EF6F6DD12C89447B`,
and executable is
`A69DA48365E8570E84830A1B9981ED0D722C95344AE784CC253CB376F6E7435A`.
Terminal03 rehashes all14620 parent147 pins, verifies exact U0 replay and
streams all28 archived executed members again. Its15733-pin receipt SHA256 is
`6629C6A90A74865445DB8621D6D75905A34D2F50CA1E47F64DAB008281597CEB`.
The [summary](witnesses/used-scope-20261020/address-nodes148-evidence.json)
keeps the exact counts and capability boundaries with the published witnesses.
Both documentation generators, check_docs and diff checks pass. A separate
post-documentation pass rehashes all15733 inputs again without changes.
Quoted SDK/preprocessor closure remains uncertified.

Twenty-eight executed EXEs remain recoverable from seven verified archives,
including the earlier zero-value observation. Their bytes are streamed back
to SHA256 before redundant raw copies are removed. Sources, objects and logs
remain. Closed older inputs are compressed in place without changing bytes;
no broad project tree or protected launch log is read for this operation.

The legacy field-span/indexed package and its callers remain the next common
consumer migration. Local Model/Shelf, pointer-kind classification, generic
machine execution, public-dev/full kernel, L3/L2 self-build and mail remain
open. The explicit cast, not char eligibility, makes the147 conversion witness
native-only; clearing that capability flag or adding a cast opcode would not
implement it. The full v3 goal remains active and unchanged.

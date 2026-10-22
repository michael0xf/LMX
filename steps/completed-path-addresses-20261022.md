# Address consumers project completed path results

Address consumers now project the ordinary operand's completed path result.
They retain its selected root, exact types and field maps instead of
reparsing the path or searching the root's name again. Physical reference
loads and stores share a cell-access selector in native and walked code.
The selected corpus and focused value tests pass with their existing
oracles; the remaining common-path consumers and full kernel stay open.

Base main is `4b9fa159bbecb37fd155e13c242e7118bb98a6d3`. The live candidate
is `build2/codex_places152_runtime_11`, a coherent281-file source/header
snapshot. The [source patch](witnesses/used-scope-20261020/operand-places152-u0.patch)
replays over the preserved Private151 snapshot. Both snapshots, fixtures
and recipes are in the [bounded input archive](witnesses/used-scope-20261020/operand-places152-inputs.tar.xz),
with a [per-file manifest](witnesses/used-scope-20261020/operand-places152-inputs.json).
These are private bootstrap witnesses, not public-dev integration or the
supported L3/L2 self-build closure.

## Completed records and address ownership

`l2_address_target` prepares an ordinary operand at a raw P0 boundary.
Prepared prefix operands instead lend their existing child result through
`l2_address_span`. Both enter `l2_address_record`, the single completed-path
address projector. Native value emission, retained value emission and
their type queries use `l2_address_value_span`; the displaced retained
Array-address and raw-index address branches are removed.

An address may outlive its temporary operand wrapper. `l2_path_record_copy`
owns a copy of the completed step array and text without another grammar
adapter, root selection or semantic fold. Source coordinates and contracts
remain in the source arena. Failure releases partial ownership instead of
leaving a borrowed text buffer dangling.

A zero-step address projects the root's binding coordinate and exact type.
The compiler-only `root_own` preserves that physical binding when ordinary
method-value projection clears its value-view `oi`. `l2_address_name` now
uses common root selection and the same address projector; it no longer
maintains its own own/formal/local/namespace name classifier. Address-taking
still records merge-result and split-data effects.

The398-assertion [owned-record fixture](witnesses/used-scope-20261020/operand-places152-owned-test.c)
covers ranks1,2,6,65,129, qualification,
prefix and address lifetimes, formal/root coordinates and allocation
refusals. Instrumentation checks that held results do not reenter the
grammar adapter, root selection or semantic fold. This covers the migrated
operand/address routes, not every CHECK, grouped or callable client.

## Physical cell access and current callable values

Logical referent types do not determine the C object stored at an address.
A graph field and a reference-Array element are physical `void *` cells;
a typed pointer pool contains its declared pointer objects. The shared
`lmx_value_cell_access` selects accessors from the exact live storage domain.
It uses the canonical accessors for CHILDREN/REF slots, the pool's callbacks
for typed pointer objects, and typed adapters for `char *`. Unowned or
activation storage keeps the caller's proven raw accessor. Numeric,
descriptor and field-address-map storage cannot masquerade as pointer cells.

`lmx_value_cell_store` uses this selector for native and walked stores.
`lmx_walk_value_load`, also used by native prepared-reference loads, uses
the same selector and existing current pointer context. The walker no
longer repeats its own pointer-pool classifier. Physical projection does
not reapply a logical implements map to an already selected address.

The first selector incorrectly required a REF pool's logical type to be
REFS. Nested reference Arrays legitimately have Lmx/descriptor logical
types with the same physical pointer-cell ABI. Corpus unit58 caught this
regression. Crossing old/new units with old/new runtimes isolated the
selector; removing that logical-type requirement fixes the common access
operation, rather than adding an Array or backend exception. The75-assertion
[physical fixture](witnesses/used-scope-20261020/operand-places152-cell-test.c)
covers those Arrays, reordered graph slots, typed double
pointers, char pointers, current context, bounds and invalid cell domains.

The [method-address witness](witnesses/used-scope-20261020/operand-places152-method-address.lm2)
exposed a separate pre-existing defect. After
the physical load fix, reading and rebinding the callable succeeded, but
the walker still called the original descriptor and returned7 instead
of9. Direct retained calls now use the existing method-occurrence value
producer through EXEC, just as passing the callable as a value does. The
declared signature supplies the receiving contract, not a frozen callee.
The former direct saved-descriptor emission is removed. This introduces
no new runtime opcode, name lookup table or graph metadata.

## Actual values and comparative checks

The final compiler source SHA256 is
`6D6CDA0D5CB1AAD6F1C389A8FBFE70749C6EFD392ACA6C9416BB1B3D221E25B8`;
the freshly generated production runtime C SHA256 is
`67392EFA7EA1A1C3A95F45382F9A5C4D1758E39B51C1E87285F836D4EA957584`.
The [receipt](witnesses/used-scope-20261020/operand-places152-evidence.json)
records tool, header, fixture and output identities. Detailed terminal
observations are in the [results](witnesses/used-scope-20261020/operand-places152-results.json).

All85 selected programs are freshly translated and strict C99/O2-built
against the corrected runtime, then actually executed170 times. Their
162 GREEN and the same8 copy-related RED observations match the relocated
Private151 baseline, as do all native-binding counts. The final attempt
contains222 new executions and118 previously completed baseline executions
whose exact L1/C/object/executable and tool/runtime bytes were rehashed.
It does not claim340 fresh executions in that final attempt or replay of
the deleted historical binary corpus.

The mixed path observes a reordered implementation through both references
and indices. It reads7, writes67, reads through the taken address, writes71
through that address, then checks the final value, index-call counts and
unchanged neighboring fields. The mapped Array case writes19 then31
through its address and preserves the sentinel23. The hidden-input case
also observes actual writes through the selected address. These cases
pass native and forced methods, with both native and interpreted roots.
Observed forced method-body entries remain10,1,2 plus the interpreted root.
Pointer-offset and opaque C operations retain their explicit native-only
boundary; they are not represented as walked implementations.

There are32 auxiliary positive executions and12 write-drop executions
with unchanged assertions and the expected RUN1. The new method-address
case passes4 production and4 independently observed executions, with native
body counts0/1 and forced counts2/3. Both legitimate Array level/value
mismatches remain located CHECK refusals. Seventeen compiler profiles pass:
398 owned-record,336 metadata,420 common INDEX,200 COUNT/EMIT dispatch and
114 receiving-value assertions.

## Storage and remaining work

The author is deleting the old `build` directory after its accumulated
artifacts exhausted the disk. New work uses `build2`; it does not recreate
or write into the directory being deleted. The original small backup is
`buold_temp`. The new source archive is independently extracted and checked
against every input hash, and the five-file patch is replayed and compared
with the actual source closure. Old historical receipts are not claimed
rehashable after the authorized cleanup.

CHECK's names-only routes, grouped/Frame child lifetimes and remaining
callable/text entry points still require migration to the same owned
result. Mixed machine-index/graph projection and redundant declaration
queries remain explicit audit work. A shared helper alone is not evidence
that every consumer has abandoned its old route.

Public-dev integration, full kernel, Model/Shelf, K03, L3/L2 self-build and
mail remain open under the unchanged v3 goal. The next slice must remove
the remaining preparation and search routes, not preserve them as fallback
resolvers or weaken positive witnesses into accepted refusals.

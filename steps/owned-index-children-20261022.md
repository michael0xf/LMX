# Owned INDEX expression children — private157

Implementation checkpoint,not a new language rule. Base main
7e32669f6400da9e967a47bcd219b95684a702bc; working snapshot
`build2/codex_index_children157`. All new work stays in build2; the old build
directory being deleted externally is neither restored nor written.

## Common ownership operation

The common path adapter prepares an INDEX operand as an ordinary owned value
list. Its expression wrapper keeps the complete field range and does not turn
the first node's sign or address role into an operation on the whole range.
Groups,prefix operands and nested index paths have the same recursive owner.
No runtime graph tag,opcode,name-binding namespace or new depth limit is added.

One path clone operation serves fresh semantic views,completed record views
and independently owned copies. Semantic views clear every nested path's
root/type/map verdict; completed copies preserve the entire current result.
Root text stays borrowed for a view and is independently terminated for an
owned copy. Child path text is independently owned. A clone never invokes
the adapter,including for schema-only metadata with unprepared coordinates.
Such coordinates do not become executable merely because they were copied.

The binding arena still owns fact records,text and step arrays at stable
addresses. Updating a fact with child owners first constructs a complete
independent replacement. A failed allocation leaves the exact old children,
root type,step metadata and geometry intact. Only a successful replacement
releases old children and transfers new owners into existing arena storage.
Metadata-only updates do not allocate. Arena teardown releases child owners
before releasing the arena blocks. Partial path construction releases the
allocated capacity,not merely the count of completed semantic steps.

The slot/schema-only use-plan edge does not retain an executable index owner.
The unused names-prefix slicing helper is removed,not repaired as a fallback.

## Consumers and current boundary

Direct CHECK and physical machine-path native projection borrow the retained
INDEX expression list. Retained machine-path COUNT/EMIT borrow that same
list and its selected child paths. Neither reconstructs a raw index field
list after the adapter. Ordinary address projection and source-fact copies
carry the same child ownership operation.

This is NOT complete consumer closure. Array INDEX receiving/conversion
helpers still receive raw fields; lexical/effect INDEX traversal also still
receives raw fields. General receiving/conversion/call-actual plans,
own-storage/descriptor/leaf producers,pointer-type spelling and remaining
indirect/callable/text clients stay open. A new wrapper around one of these
raw helpers would not close its reparse. Conversion receiver capture must
stay before argument effects; replacing it with a late cast is not allowed.

## Verification

Final frontend07 source SHA256:
`C26C92DC3C946175AD99D83FBA100A08C5E4D1C74868C5269E9FFE4F8E8CBE32`.
Generated C:
`CE6A9F383B1F1EDB7A7CE20D8A3FAE57C6D9A6F3E6DA76FD872389DF669B1ED3`.
Executable:
`DE13A666D4D864272F836B348B4F33D69F056351B8690400363C5A55B0BF2737`.
Application C header is byte-identical156; only the compiler and its source
header's ownership comment differ within the281-file source/header closure.

New INDEX fixture:61 checks/0 failures. Nested depths1/4/16 exercise source
preparation,semantic views,completed copies,CHECK,native and retained machine
COUNT/EMIT. After name+FT poison,the tested closed child paths require no
adapter,root search or type fold. All7 measured recursive record-copy and6
transactional fact-replacement allocation positions are actually refused;
every partial owner balances. Tests also cover explicit-length borrowed text,
metadata-only coordinates,stable arena addresses and nested verdict reset.
These are actual frontend/projection checks,not runtime depth16 claims.

Compatibility:owned2026,child281,root124,native134,CHECK159,all0 failures;
the native and CHECK fixtures actually refuse all15 and13 measured allocation
positions respectively. All17 compiler profiles
pass,including common INDEX420,dispatch200 and receiving114. The old owned
fixture's32-allocation measurement ceiling is removed: every measured site
still has its original refusal,balanced-owner and no-reparse assertions.
Common420 no longer compares owned allocation addresses as semantic fields:
it compares every nonownership field plus recursively independent complete
child verdicts. All420 assertions remain; no positive oracle became a refusal.

All85 source outputs are literal L1-identical156. All85 were nevertheless
freshly compiled with O2/strict aliasing and actually executed170 times:
162GREEN and the same8 pre-existing copy-family RED rows,native eligibility
unchanged. Auxiliary mapped/mixed/hidden/address witnesses add16 fresh units
and44 actual executions:32 positives in native/forced modes and12 unchanged
expected runtime write-drop refusals. Both genuinely walked method-entry
counts and final values are checked;2 legitimate Array CHECK refusals remain.
Constants add8 old/new units32 runs;method-address rebinding4 units16 runs.

The new [nested physical-index program](witnesses/used-scope-20261020/index157-machine-values.lm2)
checks the concrete sequence31→37 through a taken address→41 through the
indexed alias. It includes a nested index-of-index expression and a signed
Frame index. Old152 and current157,native/forced,production/observer and
root0/1 all pass:4 fresh units16 actual executions. The C-pointer method
stays native-only even under forced mode;the observer confirms0 interpreted
method bodies,not a fabricated walker success. The separate graph-path
witnesses above provide genuine interpreted-body coverage. An initial test
draft used obsolete pointer-formal order;the accepted source uses the current
declaration contract `@: p int`.

Selected final phases therefore contain117 fresh C compilations and278
actual runtime executions,including8 explicitly old152 comparison units and
32 old comparison executions.12 located diagnostic oracles are unchanged
across24 actual translator observations.7 additional source classifications
also remain identical;their previous refusals are not claimed as successes.

## Replay and publication boundary

[Receipt](witnesses/used-scope-20261020/index157-evidence.json),
[source patch](witnesses/used-scope-20261020/index157-u0.patch),
[281 input pins](witnesses/used-scope-20261020/index157-inputs.json) and
[exact results](witnesses/used-scope-20261020/index157-results.json) preserve
the final bytes and the failed intermediate attempts' boundaries. The
[INDEX fixture](witnesses/used-scope-20261020/index157-test.c),
[owned compatibility fixture](witnesses/used-scope-20261020/index157-owned-test.c)
and [complete verdict comparison](witnesses/used-scope-20261020/index157-common-test.c)
are published with16 recipes. The final recipe phases are frontend07,
fixtures04,profiles04,routes03,root/native/check/negatives/extra/values/aux/
constants/method/machine01 and receipt02. Fresh replay destinations must use
new labels;recipes deliberately refuse overwriting an existing attempt.

The two exact source-file patches replay byte-for-byte over frozen156.
The source header regenerates exactly the consumed C header. All281 inputs,
7 evidence files,16 recipes and340 corpus L1/C/object/executable hashes were
independently rechecked after execution. No deleted historical binary is
claimed rehashed or rerun;old comparisons use the separately rebuilt and
pinned build2 runtime152 artifacts.

This is a verified private bootstrap slice,not public-dev integration,
full kernel,Model/Shelf/K03,self-build or mail completion. Goal remains active.

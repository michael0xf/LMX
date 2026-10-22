# Prepared application arguments

Private slice161 binds formal coordinates to already owned argument values
and uses that projection in lexical analysis. It builds on
`ac5d8540b496f31426831654cb9d4dfea04073da` in
`build2/codex_application_values161`. This closes the binding algorithm and
its lexical consumer, not the remaining CHECK/native/retained call-body
consumers or default arguments. The compiler and application source and
generated header change within the281-file closure;278 inputs stay unchanged.

## One borrowing projection

`L2ApplicationActuals` owns only a formal-ordered metadata vector. Each
`L2ApplicationActual` borrows its existing value, original written occurrence
and optional named wrapper, and records the written evaluation rank. A path
keeps the owner's exact root/per-step verdict; an expression borrows its
existing operand/operator list. No source field or P0 node is copied.

Argument extents are projected from that held list without `l2_expr_span`,
a path adapter, type lookup or namespace search. The signature alone gives
a Frame its named-argument role. Empty named bodies retain an empty
structural value; a nonexpression body retains all its fields, not a zero or
its first value. A prefix in a named payload stays within that payload.

Publication is all-or-no. A duplicate, missing, unknown or misplaced
argument releases partial projection storage without releasing source
owners. The one measured projection allocation is actually refused. A plan
must be released before the grammar it borrows; its release does not recurse
through borrowed values.

The raw `l2_bind_actuals` entry constructs syntax once and calls the same
engine. It projects source coordinates for old clients rather than retaining
a second binding algorithm. A caller with owned values enters the engine
directly. Neither a binding refusal nor an allocation failure retries raw
fields.

Lexical analysis visits the projection in written order. It no longer
independently recognizes each named formal with `l2_actual_formal`. When the
source position has not resolved a signature, no named roles have been
selected: analysis visits the same written grammar rather than treating a
refused binding as permission for a fallback parser. Type-only head roles
remain with the ordinary head-role visitor.

These records are compiler metadata. They add no opcode, name or binding
table to a runtime graph and do not freeze a callable's current value.

## Verification

The application fixture passes197 assertions, including129 reversed formal
coordinates, exact nested-child sharing, empty/nonexpression named bodies,
transactional errors and the allocation refusal. Instrumentation checks
zero old expression-span/path-adapter calls in the prepared binding route
and exactly one common binder with zero private formal recognition in the
lexical route. A named prefix retains the source's exact4/5 field counts,
including `1 + child.count`, without synthetic wrapping.

CHECK/native and retained COUNT/EMIT project the resulting argument values
after their original names and types are poisoned. Independent INDEX child
verdicts are first closed by CHECK/native; outer type inference alone is not
misrepresented as complete child evaluation. COUNT/EMIT geometry agrees.

All17 compiler profiles pass, as do owned2026, receiving61, analysis82,
INDEX61, child281, root124, native134, CHECK159 and inherited primary199.
All85 corpus L1 outputs remain literal-identical160; they were freshly
strict-O2 compiled and run:162 positive runs and the same8 copy-family
failures, with unchanged native eligibility. The deep mapped/mixed/hidden
write/address corpus, write-drop counterfactuals, constants, method rebinding
and physical-pointer cases retain their earlier results. Physical-pointer
methods that stay native-only are not counted as walked methods.

The original named-order program and a separate named-prefix program are
also freshly compiled by frozen160 and current161, in native and forced
modes, with production and observed runtimes and root0/1:8 units/32 actual
runs. Written side effects and final values agree. Forced execution observes
28 method-body entries for the order program and3 for the prefix program,
plus the separately requested walked root. Another22 argument/refusal
sources retain exact old exit codes and diagnostics across44 translations;
these comparisons introduce no new normative refusal oracle.

Selected phases total137 fresh strict-O2 units and358 actual executions.
The independent audit verifies281 inputs,24 recipes,19 published sources
and821 artifact pins, including340 corpus L1/C/object/executable pins.
Two-source U0 replay and regenerated application header match exactly.
Earlier timeout, fixture-precondition and source-count observations remain
in the fixture history; they are not counted as passing runs.

The [source patch](witnesses/used-scope-20261020/application161-u0.patch),
[input manifest](witnesses/used-scope-20261020/application161-inputs.json),
[prepare recipe](witnesses/used-scope-20261020/application161-prepare.ps1),
[build recipe](witnesses/used-scope-20261020/application161-build.ps1) and
[verification recipe](witnesses/used-scope-20261020/application161-verify.ps1)
preserve the slice. [Evidence](witnesses/used-scope-20261020/application161-evidence.json),
[results](witnesses/used-scope-20261020/application161-results.json),
[fixture history](witnesses/used-scope-20261020/application161-fixture-history.json)
and [audit](witnesses/used-scope-20261020/application161-audit.ps1) bind its
observations to exact bytes.

## Remaining consumers

`l2_bind_call_in` still synthesizes formal-ordered P0 fields and repeatedly
parses them until named payloads do not join their neighbours. That loop is
not removed by the new binding engine. Its CHECK/native/retained consumers
must use the borrowing projection before the compatibility fields and loop
can be deleted. Their receiving, callable and source/admission projections
must also consume held typed/map results, not raw source coordinates again.

Defaults, complete required/selected callable contracts, Structure/body-level
trailers, nonnumeric receiving, own-storage ABI/descriptor/leaf projection,
pointer spelling and indirect/callable/text clients remain open. This is
not all-path, public-dev/kernel/Model/Shelf/K03, self-build or mail closure.
The full §§8/8a goal remains active; the old build directory and unrelated
protected files remain untouched.

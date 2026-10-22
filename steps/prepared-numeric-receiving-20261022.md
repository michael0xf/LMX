# Prepared numeric receiving

Private implementation slice159 builds on main
`b3e98cb7bc35cf99936bd32d8e61647675d6e499` in
`build2/codex_numeric_receiving159`. It closes numeric receiving over a held
expression, including graph Array indices; it does not close general
application bodies or nonnumeric receiving. The compiler and its application
source/generated header change within the281-file closure;278 inputs remain
unchanged. The old build directory being deleted externally is untouched.

## One receiving result

`L2NumericReceive` is a compiler-only borrowed result: the prepared value,
source and target contracts, contextual literal, and selected converter
signature. CHECK, native projection and retained COUNT/EMIT use this result.
The Array index consumers no longer reconstruct a receiving expression from
its original fields. Exact primitive identity needs neither a new path query
for the type word nor a compatibility allocation.

Native captures the current converter occurrence before evaluating the
argument. Retained conversion uses the ordinary call producer with a borrowed
prepared argument, rather than copying P0 fields to manufacture another
argument list. That producer likewise selects the current callable before
argument effects. A signature is not a frozen substitute for its current
value. Raw call entry still exists for unmigrated clients; it is not a retry
after a refused prepared numeric argument.

Implicit inputs use the ordinary hidden-input records and admission too.
The declared numeric argument is frozen before those inputs are formed;
there is no zero-hidden-input restriction for a converter.

The receiver's own declared formal also receives the argument. Nested
conversion uses the same held value; its selected outer receiver survives
the nested table query. An explicit foreign by-value formal uses its exact
C ABI and typed call record, rather than being assigned a guessed language
numeric type.

Transparent single-value groups preserve contextual literal reception.
Character and decimal literals use the same typed range/storage projector
in the retained graph. This removes the former char/int-only projection rule,
not merely its symptom in an Array index. Composite and prefix expressions
retain their ordinary expression types.

Grouped and prefix-child evaluation uses a pure borrowed-value projector,
not another receiving operation. A storage context used to emit a group does
not invent a numeric contract for an untyped external actual. Actual numeric
receiving sites still perform the common admission once.

Explicit opaque C results retain their existing machine contract(-12) through
the common single/group/composite/prefix type result. Numeric receiving projects
that contract without rediscovering the source head. An unresolved language
value cannot acquire this role. The actual C receiving type still checks a
machine expression; this is not a C-name allowlist or a runtime binding table.

## Verification

Final frontend16 source SHA256:
`6D27FA4E3023CC219B082360EEFC75D122AC0425CE4F956393004B3C5572552F`;
C:`C841E862F6EADC4816ED0AC3F8DCD4729D44A655D2566C64CB79ADAFDF3231DC`;
executable:`FC697791882741AF3ED774C9AA169FD995BAE513317F8D4E5BAAC3E6D3D8D68F`.

The receiving fixture passes61 assertions. Its held typed arithmetic,
groups, prefix and literal projections survive formal name+FT poison with
zero source adapters, root walks or step folds in CHECK/native/COUNT/EMIT.
COUNT and EMIT retain equal geometry. Both measured raw-entry constructor
allocation refusals are exercised and release partial owners; identity
receiving allocates nothing. Separate primary C cases verify the opaque
contract, not zero-adapter ownership of their still-open bodies.

The actual value witness checks37 through the converter captured before its
argument rebinds that converter, then41 through its replacement. Indexed
write43 and an address-mediated write47 reach the same physical cell; the
original cell remains37 and the argument executes exactly once. Character
indices, including nested groups, read53. Raw C arithmetic/grouped results
also execute. A refused negative index conversion is caught as `convert`,
without reading the Array. Native and forced modes, production and body-observing runtimes,
and native/walked roots give8 successful runs from2 fresh strictO2 units.
The observer confirms6 actual source-method body entries in forced mode;
the original cast converter and raw-C helper remain native-only, not claimed
interpreted coverage.

A second program supplies the converter's implicit `bias=7`. Its index0
therefore selects physical element7; read61, write67 and address-mediated
write71 reach that same cell. Both backends and both root modes give another
8 actual executions from2 fresh units, with a genuinely walked caller in
forced mode. The converter's cast body remains native-only.

Two more programs compare old158 and the candidate with the same source and
value oracles. A converter whose formal is char must invoke int-to-char
admission for a typed index300: the refusal is caught, not silently narrowed
to44. Frontend11's native regression(exit0,expected7) is retained; current
native and forced runs match the old compiler's7. An explicit c.int formal
preserves read61→write67→address-mediated71 too. That caller remains
native-only in both old and current forced modes; only its root can actually
be walked. These pairs add8 fresh units/32 executions,16 of them old158
comparisons.

All17 compiler profiles pass. Root124, native134, CHECK159, analysis82,
INDEX61, child281 and owned2026 assertions pass. All85 corpus units were
freshly compiled with strictO2/strict-aliasing and run170times:162GREEN and
the same8 copy-family RED rows, with unchanged native eligibility.14 L1
outputs differ from158. Deep mixed/permuted/hidden/address auxiliary cases
add16 units44 executions:32 positive native/forced values and12 unchanged
write-drop refusals;2 genuine Array CHECK refusals remain. Constants add8
old/new units32runs, method-address rebinding4units16runs, and nested physical
pointer indices4units16runs. That physical-pointer method remains native-only.

Selected final phases contain129 fresh C units and326 actual executions,
including12 old comparison units/48 executions.12 located negative oracles
remain unchanged across24 translator observations;7 additional source
classifications remain identical. These counts exclude exploratory attempts.

The [receipt](witnesses/used-scope-20261020/receive159-evidence.json),
[two-source patch](witnesses/used-scope-20261020/receive159-u0.patch),
[281 input pins](witnesses/used-scope-20261020/receive159-inputs.json),
[actual results](witnesses/used-scope-20261020/receive159-results.json) and
[61-check fixture](witnesses/used-scope-20261020/receive159-test.c) identify
the exact bytes. The fixed native formal-admission regression retains its
[actual failed result](witnesses/used-scope-20261020/receive159-actual-open-results.json)
alongside old/current positive comparisons of the same source.

Receipt02 replays both changed source files byte-exactly over158 and
regenerates the exact consumed application C header. Independent audit
checks281 inputs,18 recipes,340 corpus L1/C/object/executable pins, the
other actual-value artifacts, toolchain, runtimes and source archive.
Receipt/audit require PowerShell7: PS5's nested array serialization produced
value/Count wrappers. LF serialization also keeps published SHA256 stable
after Git normalization; the observed diagnostics and values are unchanged.

Final labels are frontend16,fixtures09,profiles05,routes05,root/native/check04,
negatives04,extra04,values04,aux04,constants/method/machine03,receive-values08,
hidden02,actual03,foreign01 and receipt02. Recipes reject overwriting an old
attempt; fresh replay destinations need fresh labels. Run the published
build recipe with `-Label frontend-16`, routes with `-Label routes-05`, then
the verification recipe in a reconstructed stage. Prior frozen source/test
closures remain dependencies; deleted binaries are not claimed replayed.

## Remaining boundary

General primary/Frame/application bodies and call actual ownership remain
open, as do nonnumeric receiving plans, own-storage/descriptor/leaf ABI
projection, pointer-type spelling, indirect heads and callable/text clients.
The parent158 compact-primary82/2 RED witness remains preserved and open;
this slice does not rerun or promote it. Public-dev integration, the full
kernel gate, Model/Shelf/K03, self-build and mail are not complete. Goal
remains active.

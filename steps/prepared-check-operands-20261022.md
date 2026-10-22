# CHECK consumes prepared operand records

CHECK now shares one owned operand list between its kind fold and place
validation. Its old whole-path retry, indexed reparse and names-only path
branch are removed. A failed prepared path cannot retry a root-name or
Array resolver. This closes that CHECK route, not every path consumer or
the full kernel.

Base main is `b792b8d1f09cf68be5c1a6528ab612b803fe54dd`. The
[source patch](witnesses/used-scope-20261020/check153-u0.patch)
replays over the candidate snapshot in the
[Private152 source archive](witnesses/used-scope-20261020/operand-places152-inputs.tar.xz).
The live source is `build2/codex_check_records153`. Its
[281-file manifest](witnesses/used-scope-20261020/check153-inputs.json)
differs in the compiler and a comment in its application source header.
All279 other source/header inputs are unchanged, and regenerating the
application header produces exactly the previous C header bytes. These
remain private bootstrap sources, not public-dev or
the supported L3/L2 self-build closure.

## Operand lifetime and receiving roles

`l2_value_fields` constructs ordinary operand spans and their existing
prefix/path children. It also retains preparations for foreign argument
lists that are not binary expressions. Binary-expression consumers apply
`l2_value_spans_expression` to those coordinates; checking a receiving
role does not run another path adapter. An unprepared borrowed operand
cannot silently masquerade as an operator; CHECK refuses it without
starting a replacement lookup.

`l2_check_fields` owns and releases the list on every exit.
`l2_check_prepared_kinds` and `l2_check_value_span` borrow its common
semantic results. Field, index and reference paths retain their original
steps, types, maps and refusal. Address checking uses the completed-path
projector added in Private152. Original index expressions still receive
their ordinary checks from the resolved steps.

The first integration rejected two hidden Array values through the old
primitive-kind filter. The final checker asks the completed result's exact
type instead. It does not add an exception for the Array descriptor kind
or revive the removed indexed route. All85 selected source outputs then
match Private152 literally.

An additional C-constant control caught a separate regression before
publication. A declared external constant is not an unresolved graph field
and has no addressable L2 cell. Common root selection now retains that
source role after checking every lexical binding. CHECK, native projection
and retained COUNT/EMIT consume it without another name lookup, even after
the declaration table is poisoned. Its type remains C's, and its native-only
representation uses existing source constructors. This adds neither an
Lmx graph field nor a runtime opcode; a same-named formal still wins.

## Measured resolution and ownership

The [source-linked fixture](witnesses/used-scope-20261020/check153-test.c)
passes153 assertions on the current compiler and40 shared assertions on
Private152. Ranks1,2,6,65,129 cover qualification and signed prefixes.
Whole-expression CHECK root selection and semantic folding each fall from
two entries to one. At rank129, total adapter entries fall from526/529 to131.
The remaining129 entries prepare the independent literal-index operands;
they are not reported as zero.

A held result remains usable after the source type table is poisoned.
Its later CHECK projection performs no root selection, semantic fold or
binding-name query and does not shorten or relabel the path. First-fold
type interning still performs declaration queries; these measurements do
not establish that every remaining declaration projection is redundant-free.

All10 measured CHECK allocation points are individually forced to refuse.
Each refusal is terminal, and partial operand, path and bound-use records
release with their owners. Compilation-owned type interning is populated
before the operand-lifetime checkpoint; bound-use metadata and application
contracts are released through their own destructors. The initial fixture
omitted those enclosing owners and failed on both old and new compilers;
the corrected fixture does not claim a production leak was fixed.

## Unchanged actual values and diagnostics

Final compiler source SHA256 is
`38BFC05E7ED1BE7A8ACDDA546ED3B58A57D35688F76523C3C41F46F306B9B947`,
and generated frontend C SHA256 is
`FA9DFB84538847AC4EE172F6E4C59188D0C9897AFC31B0614F19A3B3F263B134`.
The [receipt](witnesses/used-scope-20261020/check153-evidence.json) and
[terminal results](witnesses/used-scope-20261020/check153-results.json)
record exact inputs, tools, observations and remaining boundaries.

The85 corpus inputs and18 additional native/forced inputs produce103
literal L1/C pairs identical to Private152. Their unchanged279 dependencies
and the byte-identical regenerated application C header are also checked.
The exact previously strict-O2-built
executables are rehashed and actually rerun222 times:202 positive passes,
the same8 copy-related RED observations and12 expected write-drop failures.
This is222 new executions, not103 fresh C compilations. Reusing verified
identical units avoids another collection of duplicate build artifacts;
one generated C buffer checks all103 current translations.

Deep mixed/permuted paths, values after stores, writes through taken
addresses and method-slot rebinding retain their actual observations in
native and forced walker/root modes. The observer still counts real body
entries, not native eligibility alone. Pointer-offset and opaque C
operations retain their explicit native-only boundary.

Two additional constant programs are freshly strict-O2-built in old/new,
native/forced configurations:8 units and32 actual production/observed
executions. String constants reach strlen without an integer staging
temporary and produce11. The [shadowed formal](witnesses/used-scope-20261020/check153-constant-shadow.lm2)
produces7 instead of the constant's74; its forced body is actually walked.
The foreign-string method remains native-only, including forced mode.
Seven extra old/new source controls retain all their classifications;
their five pre-existing refusals are not counted as new successes.

Twelve committed located CHECK oracles match both compilers in24 actual
translator runs, including absent fields, Array level/value mismatches,
scalar index shadowing and reference-depth mismatch. No expected refusal
or positive witness is rewritten. Seventeen source-linked compiler
profiles pass398 owned-record,336 metadata,420 common INDEX,200 dispatch
and114 receiving-value assertions. The recipes are preserved beside the
receipt, including the [build](witnesses/used-scope-20261020/check153-build.ps1),
[probe](witnesses/used-scope-20261020/check153-probe.ps1),
[negative controls](witnesses/used-scope-20261020/check153-negatives.ps1)
and [actual value replay](witnesses/used-scope-20261020/check153-values.ps1).

## Remaining consumers

Independent index, group and Frame children still need preparation
ownership through every consumer. The native raw-expression names-only
route, indirect/callable/text clients and redundant contract projections
remain explicit work. A common CHECK result does not prove that those
other clients already abandoned their previous routes.

Public-dev integration, full kernel, Model/Shelf, K03, supported L3/L2
self-build and mail remain open under the unchanged v3 goal. New work
continues in `build2`; the old `build` directory being deleted by the author
is neither recreated nor written.

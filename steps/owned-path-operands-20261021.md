# Ordinary operands own prepared path records

Ordinary expression operands now retain their prepared path grammar and
share one method-bound semantic result for the expression lifetime. Type
checking, native value emission and retained value emission can borrow that
result without reparsing its path or selecting its root again. This closes
the operand ownership slice, not all path consumers or the clean kernel.

Base main is `4da494cbced30dccf2e0d0e7b8af89f863abca40`. The
[two-file compiler patch](witnesses/used-scope-20261020/operand-records151-u0.patch)
replays over [Private150](prepared-path-heads-20261021.md), with its unchanged
Private149 application source as the second base input. The candidate is
`build/codex_operand_records_151`; final frontend06 has source SHA256
`95950ACD2514F4DC6CCE010B195BFBF6388769331E3217E23364300F17212D0F`.
These remain private compiler sources and witnesses, not an integrated
public-dev compiler or an accepted full-kernel checkpoint.

## Expression ownership and borrowed results

The existing compiler-only `L2ValueSpan` owns a prepared path or an
authoritative nonpath result. Prefix operands own their child span.
`l2_value_spans` constructs the expression operands; one recursive release
destroys the complete owned tree. Prefix, indirect and index views borrow
the original span rather than owning another parse. All token-array release
sites use the recursive release, including partially constructed arrays.

Readiness and method context belong to the shared `L2Path`, not to copied
span flags. The first semantic use walks its prepared grammar. Later uses
of that same operand borrow its completed root, per-step types, field maps,
qualification and refusal. An independent new operand resolves against the
current source tables; a different method gets a fresh semantic view of
the retained grammar. No global cache, runtime graph field, runtime opcode
or new binding namespace is introduced.

Zero-step paths select the existing root value producer. A carried root
requirement distinguishes a language Array descriptor from opaque C storage;
its C pointer representation does not make it an opaque C aggregate.
Names-only slicing invalidates the old semantic readiness when it changes
the record geometry.

The [owned-record fixture](witnesses/used-scope-20261020/operand-records151-owned-test.c)
passes225 assertions. Ranks1,2,6,65,129 cover both qualifications and signed
prefixes. The first held type use enters one root selection and one semantic
fold, without a grammar adapter. Subsequent retained/type queries enter none
of those functions. Source-table poisoning cannot relabel a held result,
but a newly constructed operand observes the changed incompatible contract.
Zero-step records need no fictitious step allocation.

The fixture also injects refusal at every measured constructor allocation
and at semantic-view allocation. Partial prefix/path/token construction
returns no partial expression and balances its owned allocation count.
A failed semantic view cannot retry a parser or root selection, and its
held refusal remains authoritative. The initial204 assertions and the
expanded225 assertions both pass on the final frontend bytes.

## Value consumers use completed physical places

| Consumer | Projection of the common operand result |
| --- | --- |
| Type fold | Exact machine type and arithmetic kind, including nested prefixes |
| Native value | Existing root producer, resolved graph cursor or typed physical place |
| Retained value | Existing binding, graph cursor or explicit native-only machine representation |

The native arithmetic leaf and retained span visitor consume the owned
result before their separate nonpath interfaces. A held path refusal is
final; it does not fall through to a text or namespace lookup.

An Array index selects a typed physical place, not a scalar graph-pool cell.
The common record reader now loads that place through the ordinary value
and context operation. The older Array-place value entry delegates to this
same reader, instead of maintaining another indexed value implementation.
Numeric and reference Array elements therefore use the existing typed place
contract, including reference metadata.

An address Frame is handled by the ordinary P0 operand visitor before
native-only classification. Its written `@` head alone is not evidence that
the operation lacks a walked implementation.

The preserved intermediate attempts expose both integration errors rather
than hiding them. Attempt04 left one mixed-program method native, producing
9 observed method-body entries instead of10. Attempt05 restores10 but still
refuses indexed Array reads through `box`; the generic reader was sending
an indexed leaf to the old scalar-cell loader. Final06 restores both the
typed place load and the unchanged positive oracles.

## Actual values and unchanged regressions

All85 corpus inputs translate with final06. Sixty-two generated L1 files
differ from143, so the literal current85 outputs are rebuilt with fresh
strict C99/O2 units and a freshly compiled runtime C object. All170 actual
exit codes and native-binding counts match the previous corpus result:
162 GREEN and the same8 copy-related RED observations. Debug symbols alone
are omitted from this complete rebuild to limit disk use; strict aliasing
and the warning/error flags remain enabled. This is a complete rebuild of
that selected corpus, not the full kernel gate.

Four additional programs check deep mixed reference/index paths, reordered
Array maps, pointer offsets and hidden inputs. All16 root0 executions pass
with production and independently observed runtimes, native and forced
methods. Twelve root1 runs replay those exact archived mixed/mapped/hidden
executables. Observed forced method-body counts are10,1,2 respectively,
plus one when the root is interpreted. Pointer-offset methods remain native.

The mapped/hidden cases observe stores, values after taking an address and
writes through that address, not only successful translation. The hidden
case writes41, reads it through the address, writes43 through that address
and checks the reordered candidate's unchanged7/29 fields. Four fresh
C-boundary runs check nonzero16843009 and its wide neighbor; that machine
operation remains native even in forced mode. Twelve write-drop mutants
retain the assertions and all produce the expected RUN1.

Current source-linked controls pass336 metadata,420 common INDEX,200 dispatch
and114 receiving-value assertions. The two legitimate Array level/value
mismatches remain located CHECK refusals. Results, exact input hashes and
the remaining boundaries are recorded in the
[evidence receipt](witnesses/used-scope-20261020/operand-records151-evidence.json).

Completed C/object/EXE artifacts are retained in SHA-verified archives.
The85 rebuilt units occupy two solid bundles after255 member streams are
reverified. Metadata and value executables are likewise recoverable; only
redundant unpacked copies or superseded containers were removed. Identical
immutable generated L1 outputs share storage while retaining every original
path and hash. Neither source WIP nor logs were removed.

## Remaining common path work

CHECK's names-only route and raw address/dereference child preparation still
need to borrow the common expression result throughout their lifetime.
Grouped/nonpath and callable/text-only clients need the same audit. The
current root contract still has redundant declaration projections, and
machine-index paths crossing back into graph Array storage need a complete
per-step physical projection rather than a whole-path machine shortcut.
The measured operand reuse is not proof that every consumer already uses
one preparation and one semantic resolution.

Model/Shelf, source-machine operations without walked implementations, K03
lowered-operation migration, public-dev integration, the full kernel gate,
L3/L2 self-build and mail remain open under the unchanged v3 goal. The next
slice removes displaced preparation/search routes; it must not preserve
them as fallbacks or add backend-specific exceptions.

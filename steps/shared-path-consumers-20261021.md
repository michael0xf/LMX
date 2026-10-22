# Shared path consumers and exact expression types

The private compiler now removes the legacy indexed-operand family and
uses the existing expression fold to carry both value kind and exact type.
Ordinary pointer expressions preserve their contract through grouping and
precedence. Deep mapped paths still read, write and expose the correct
address in actual native and walked executions. Repeated entries into the
common path adapter remain; this is not all-path unification.

Base main is `b027edf1973ca1146c1c011ed5a40adeaa8f9fa0`. The candidate is
`build/codex_path_consumers_149`, final frontend
`build/codex_paths149_build_10`. The
[two-file patch](witnesses/used-scope-20261020/path-consumers149-u0.patch)
replays over [the previous address-consumer snapshot](address-node-consumers-20261021.md)
with `git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
It changes the private compiler and removes one unused compiler record;
runtime graph fields, runtime operations and runtime ABI are unchanged.

## One expression fold supplies kind and exact type

`l2_value_expr_type` is the existing precedence fold, renamed from its
native-specific name and extended with an exact-type output. Its operands
use `l2_value_span_type`; parenthesized expressions preserve that same
result through `l2_value_group_type`. Native receiving conversion projects
the exact type; `l2_rw_tyof` projects its storage representation instead of
running an independent binary type fold.

Pointer addition and subtraction consume these ordinary typed operands.
The former recognizer for the special shape `@ own[i] + number` is deleted,
along with its integer-span and landing-type recognizers. An object pointer
can retain its declared type through `p + 2U * 3U`, `2U + p` and grouped
subtraction without an own-array lookup. Graph Structure and Array references
are not machine arithmetic pointers. A void pointer has no object cell to
offset; a pointer to a pointer cell is different.

The [comparative fixture](witnesses/used-scope-20261020/path-consumers149-types-test.c)
tests five expression shapes at ranks1,2,6,65,129, both qualified and
unqualified. It checks exact types and actual entries into the shared fold
from native and retained consumers. Four invalid operations preserve their
kind refusals. Five additional current-compiler checks distinguish void,
double-pointer, graph and Array capabilities. Old148 has304 checks with200
failures; current149 has309 checks with zero failures. These are compiler
metadata assertions, not executions of rank129 programs.

The first comparison used the new header with the old compiler and failed
to compile because the obsolete record was correctly absent. Each version
now uses its own pinned headers. A subsequent fixture accidentally wrote
C-style `==` instead of L2 `=`; its single negative-test failure is retained
in the exploratory logs. The corrected fixture changes only that spelling.

## Complete path results replace indexed consumers

The definitions and clients of `l2_indexed_clear`, `l2_indexed_type`,
`l2_indexed_node`, `l2_indexed_operand`, `l2_emit_indexed`,
`l2_emit_indexed_context` and `l2_rw_indexed` are removed. The unused
`L2IndexedOperand` declaration is removed from the application source and
its generated header. No replacement runtime marker or opcode is added.

`l2_path_value_type` extends the previous zero-step root query to complete
value paths. An incomplete grammar run is rejected before resolution; a
failed named path does not retry namespace classification. Indirect reads
retain the resolved path, exact type and contract while the correct method
context is selected. Foreign actuals use the ordinary expression preparation
route instead of the old indexed emitter.

CHECK validates the original index expressions from the retained record,
including the address-operand fast path. Raw indexed places use the common
dispatch result and consume its exact run count. The machine projector's
size guard checks integer representability before adding root/assignment
steps; it is not a language depth limit.

Retaining a bare pointer's completed zero-step record exposed an actual
regression: its common read was sent to a field cursor that requires a
nonempty path. The fix is the zero-step base case in
`l2_path_record_read_context`, projecting the selected binding value.
No caller-specific fallback was added. The first strict candidate silently
refused36 of the85 source programs; the corrected common base case restored
all85, and final build10 again generates byte-identical L1 to the143 corpus.
This comparison does not rerun the85 C/runtime programs or close their
inherited eight copy failures.

## Actual values and observable failures

The existing [mixed-reference witness](witnesses/used-scope-20261020/address-nodes148-mixed-frame.lm2)
combines mapped references and two effectful indices, writes through the
deep path and its captured address, and checks71 plus unchanged sentinels
and index-call counts. The existing
[mapped Array witness](witnesses/used-scope-20261020/address-nodes148-mapped-frame.lm2)
checks31 in a reordered implements layout and preserves sentinel23.
Current149 freshly translates and compiles both modes. Their eight root0
runs pass; eight more root1 runs re-execute the exact archived executables.
Production and independently observed runtime variants are kept separate.
Observed method/root entry counts are mixed0/1 or10/11 and mapped0/1 or1/2.
The graph methods genuinely execute through the walker in forced mode.

The [new pointer witness](witnesses/used-scope-20261020/path-consumers149-offsets.lm2)
passes a raw pointer formal through multiplication, addition, grouping and
subtraction. Stores through the two selected addresses must leave backing
values11,43,37,71 and reads43/71. Old148 refuses its first return; current149
has four actual root0 RUN0 results. The pointer-offset methods remain native
even with forced-method selection; observed method-body entries are zero.
They are not counted as interpreted pointer arithmetic.

The final nonzero C-boundary witness from148 is rebuilt with current149:
four actual root0 RUN0 results check value16843009 and the neighboring wide
field. Its methods remain native. The earlier unsupported walked C-root
result remains open and is not converted to a passing refusal oracle.

The existing address-write mutants for the mixed and mapped witnesses,
plus the [new pointer-write mutant](witnesses/used-scope-20261020/path-consumers149-offsets-drop.lm2),
retain the positive assertions but omit the required stores. All12 actual
root0 runs exit1 as required. The [void-pointer](witnesses/used-scope-20261020/path-consumers149-void-offset-refused.lm2)
and [graph-reference](witnesses/used-scope-20261020/path-consumers149-graph-offset-refused.lm2)
offset negatives retain their located CHECK refusal in both versions.

## Regression evidence and remaining routes

The unchanged source-linked controls pass336 metadata,420 common-path,
200 dispatch and114 receiving-type assertions. The receiving fixture only
updates the renamed span-query call, retaining all114 assertions. The
[node fixture](witnesses/used-scope-20261020/path-consumers149-nodes-test.c)
passes216 assertions in both versions, including mixed-record geometry.
Its legacy instrumentation is conditionally absent only because the named
functions no longer exist; their removal is checked in source and header,
not inferred from a zero runtime counter.

The same node fixture still measures517 grammar-adapter entries during
CHECK and130 during native preparation at rank129. Removing the legacy
family did not reduce those repeated common-adapter entries. Each outer
node consumer still selects one root and one semantic fold. These are
different observations; the latter does not prove single preparation of
all nested operands.

`L2ValueSpan` still retains source span coordinates rather than a prepared
path and completed semantic result. CHECK still has a names-only branch
after indexed dispatch. The next dependency is to carry prepared grammar
and resolved types/maps through every consumer, with audited ownership,
copy and release, and remove the remaining re-entry routes. Adding a shared
helper while callers reparse after it does not satisfy that dependency.
Native-only machine operations and numeric `LmxOp` execution also remain
outside the final written-head K03 model. Public-dev integration, the full
kernel, Model/Shelf scope, L3/L2 self-build and mail T01–T26 remain open.

The [evidence index](witnesses/used-scope-20261020/path-consumers149-evidence.json)
records the final bytes, recipes, measurements and terminal receipt. The
selected snapshot contains281 source/header files; only the two changed
sources and their generated application header differ from the pinned
inputs. Runtime objects are reused by SHA, not claimed as fresh builds.
Executed executables are recoverable from seven verified archives; only
redundant raw copies were removed after member-by-member SHA verification.
Sources, failures and logs remain. SDK closure and the full85 runtime gate
are not certified by these checks.

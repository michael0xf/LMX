# Slice 265 — selected Structure calls

Development baseline on published slice 264, commit `fb7bbc2ede0c0e311e4a92bed560d842c0f6d9ca`. The three probes used that commit's promoted G2 frontend, runtime and tool. The terminal record is `build2/codex_fix250generationchain01/pins/tp127-call-base-01.terminal.txt`. The suite recorded three rows and six failures.

| Input | Native and forced results |
| --- | --- |
| Direct call of S with D missing a declaration inside an untaken branch | Both roots returned 7. Admission reached the caller's call handler and D.x retained 10. |
| Same source with S selected only through a held reference | Both roots stopped in both modes with walk error UNSUPPORTED and driver exit 3. The caller's handler should run before any write. |
| Call of the copied Inner through a free Copy root inside a method | Both translations refused the field path at line 11, column 11, atom Copy. The test expects the copied Inner to see the caller's ticket and the original Inner to retain its own value. |

Next, trace how the selected Structure obtains its required data places when its only use is through a reference. Then check how a resolved free root is carried into the existing field-path lowering for the copied Inner. Preserve the direct-call control and the caller-local meaning of hidden inputs.

## Candidate and first bootstrap

The first frontend built successfully. Eight selected call controls passed in native and forced execution, including the new held-only case. The cleaned candidate removes the recursive direct-call mark scan and the unused predicted-write list. Its initial bootstrap `boot127a` built G1 frontend and runtime with all 33 and 39 producer steps succeeding. G1 smoke stopped on one of nine rows. At line 13 of the M library the declared `next` reference had no data place in the generated walker. The remaining place classification still excluded a typed graph reference. G2 was not started from those bytes.

The next candidate includes the graph reference in the same declared pointer-place path. The existing linked library smoke row and a held-code control using a correctly typed field and an incompatible numeric field are the immediate checks.

## Graph reference and seed

The graph-reference candidate restored the linked library row on both roots in both modes. In the extended held-call fixture, translation stopped while emitting a model reference seed. The debugger located the unexpected late copy-dependency registration in the D105 catalog called by the seed emitter. The next candidate collects that dependency at the executable receiving record which owns it. The seed emitter still builds the actual reference records, typed templates and receiving operation.

The explicit-data copied-path control independently reproduced the frontend refusal. Its captured root had input slot 1 and runtime type FREE, with no static schema for the first path segment. The stop is in the prepared-path walker emission. Passing the copied occurrence as both code and data isolates this failure from unary data selection.

## Published result

The interface for an ordinary named Structure comes from its own declarations.
The scan for a direct two-operand call used to decide whether the compiler
emitted that interface. The same declaration producer now applies when the
only call is through a held value. Both executors use the physical place map
prepared by the common admission kernel.

The held-only fixture supplies two different data objects. Missing `y` (a
declaration inside the untaken branch) reaches the caller's `call` handler
while `D.x` still equals 10. On the success path the same held code changes
`Good.x` to 1, preserves `Good.y` at 33 and leaves the padding at 27.
Both root settings passed in native and forced execution. The first component suite passed eight rows. After the graph reference and construction-seed fixes,
the component suite passed all nine rows including the linked M library.
Passing a numeric slot in place of the declared graph reference is caught
before the first data write. Constructing a seed preserves its actual typed model
references. A dependency of executable code is recorded while that receiving
operation is collected. The final package drops the recursive scans for direct calls,
the per-namespace split flags and the unused list of predicted data writes.

The bootstrap built and tested G1 and G2 in 749.81 seconds, nine smoke rows
in each. G2 passed all 27 focused rows. The two inventories contained
248 artifacts each, 245 byte-identical and 3 differing only in PE
timestamp/checksum fields. The frozen, promoted and installed source manifest
covers 179 files. [G2 focus](records/tp127-suite-g2.terminal.txt).
[Generation comparison](records/boot127b-compare.txt).

| Artifact | SHA-256 |
| --- | --- |
| Input list | `24E8E7551475522126ECE5EE7C4537298092DAEDB2AEA67EB929DE5974E3FFC8` |
| Input manifest | `41ACDB1666CB7AD4A4FFFE5984CE801DEDE6A4C17B4CC47444BD83240E326DF7` |
| Working tool | `FF07ECBB0C65FE965380ED54A155CF9132514A1F5A13E31F26EE80AEFFEE5177` |
| G2 frontend | `BBCABDAC2CBB98EB9E23F725843E95AD50A1091B1639A4760F84CF206D77EAB2` |
| Production runtime | `1DB4884783710CD4424F2FCF23A32A7A015BEB77EBD88BFB371B23BD7F4DBB1A` |
| Observation runtime | `F4EAFB53512301BFB64BAA0CC53D1884CB87D014ECBAF8DC0BD10B94803FB756` |

The promoted G2 documentation check verified 35 paired semantic chapters, 14 implements cases, 615 imported files and index line endings for 15444 tracked files. [Documentation check](records/docs265-check.log).

## Remaining call semantics

The refusal at `Copy\\Inner` is reproducible in the frontend's prepared-path
lowering of the code operand. The original positive probe also depended on a
unary call writing the code's own `seen` field with no `var`. That expected
write is inconsistent with the [method-parts rule](../../../provenance/semantics-book.md).
The independent path control must explicitly pass the chosen instance as
data. Separately, `lmx_call_unary_data` still returns the code for an
ordinary occurrence and looks up the fixed var slot only for the FN role.
Resolving the selected ordinary var and representing absent data remain open.

The remaining compiler closures, shared collector, three compiler passes,
final FULL and sections 8/8a remain open.

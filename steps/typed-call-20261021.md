# Private121: carry computed values into the same activation

Baseline `4046c318`, exact private120 source/header snapshot in
`build/codex_typed_call_121`. Codex is the sole writer/build; goal ACTIVE.

This dependency slice keeps the typed array already produced by actuals,
instead of trying to recover its Model/reference sheet from a raw pointer
box. An explicit optional typed-input span enters the SAME activation and
argument-place workers. Old raw-storage APIs are wrappers with no such span.
No field is added to the program graph, no native ABI pointer cell is widened,
and no global current-call registry or physical-layout Model inference is used.

## Same workers and a connected coordinate dependency

`actuals_values` returns the typed array it already evaluated once. CALL/EXEC
passes that array to `activate_values`; raw actuals/activation APIs wrap the
same workers with a null optional span. Entry verifies storage correspondence
and snapshots values into callee-owned input places before entry/body effects.
An input/output record alias is copied before clearing the result. ARG reads,
rebinding, defaults, nested calls and RET use those same stable typed places.

The first regression replay exposed an existing connected dependency: a
successful empty scoped Consumer labels the result with its receiving Model
but legitimately retains no field map. Passing that Model through the next
call made its first actual consumption fail. Read-only GDB on a separately
built O0 runtime confirmed mode2 success with no exact map, followed by
UNKNOWN for the SAME explicit Current/required Model. It was not a type-width
failure, nor permission to substitute a different historical namespace.

The kernel now extracts its existing exact physical-template projection into
`lmx_implements_direct_view`. Both unqualified resolution and an explicitly
supplied Current Model lacking a retained map consume that same helper. The
Model comes from the typed value, NOT from the candidate's physical token.
Only templates from the actual physical layout TO THAT explicit declaration
can provide its missing correspondence; all matching rows are joined, conflicts
refuse, and no old admission is selected as a replacement. Actual Consumer
checking and atomic publication remain in the existing common operation.
Empty coverage still creates no fake full proof or guessed map. No extra
merge/capture/path-specific resolver, graph field or opcode is introduced.

## Exact final inputs

| Input | SHA256 |
| --- | --- |
| walker source | 258AE7E87FF5D81E663749E8E05387397FD3D25CC67788A719108E3AD39B79D6 |
| walker header source | CC49A5A09C39489957B1CC13D3FA23B6EED0D4EC06D7469CB8BB0EB5878B907B |
| implements source | 007CAC180E502B449793EF897AC1C0411DA72AFF68A8F827585B92E2E1994C74 |
| generated driver C, build03 | EE07CB6EF7D5ACF664A5FBAC40BBD67E5B3ADBC4B8F9F2C0FFB945E397EC0026 |
| normal-main runtime object | 81080E1D886E87CF89D50FA6D60D698AFC03DDF1AD45E2F0FB97E098E4A7FFBD |
| renamed runtime object | 3819CA0C66BB8D02F4021E958916D6368316A96E9D84A9262BD4CC05448FEC47 |
| newly translated kernel C | 18E5462D3A2865C30E8953F9FB6BE65713A43754C8EAE28F7D90B67B17F6E929 |

The [exact120→121 source patch](witnesses/used-scope-20261020/typed-call121-u0.patch)
has SHA256 `90D05420B7E40F115F4A719CD0A408FF1689EFA3D6EAF03808DDDA5B879177FF`;
`git apply --unidiff-zero --check` passes against exact120. No public-dev
promotion is performed; all unrelated source/header bytes must match120.

Terminal12155 pins are in `build/codex_call121_terminal_01.inputs.sha256`,
SHA256 `005F418DFD6D8B7407C91F88646A782987E0DC5D17524D5D1FCC3ED90901EFBF`.
All10848 upstream pins and unchanged source/header bytes were reverified;
archived executable SHA values were independently checked after decompression.
All listed compiler/replay/test workers are terminal.

## Actual execution, not translation-only

The [executed final fixture](witnesses/used-scope-20261020/typed-call121-test.c)
has SHA256 `B7A5087E93C5CF94D102864F8F843944BCCAED66D811E14598343326B0FCA4CA`.
It includes and executes the unchanged35 checks of120 and37 new assertions:
72/0 under the production runtime. It exercises ordinary native C callers
of the typed activation API and real walked CALL/EXEC, nested and named
actuals, exactly-once effects, four-part fn selection, callee-local address/
rebinding, defaults, absence/present null, malformed context/span, exact int/
size_t widths, input/output alias, empty-coverage first use and conflicting
direct maps. Actual reordered reads distinguish9 from7. Native C and walked
stores observe41 and43; the walked ADDRESS/DEREF/PUT route changes the real
mapped cell without changing its neighbor. This is NOT generated-native L2
producer/adapter annotation.

Three generated-C loss controls execute the IDENTICAL final72 fixture:
drop-call-span10 FAIL, drop-entry-pair21 FAIL, drop-direct-source1 FAIL;
all exit1 from assertions, not setup failure or crash. Production bytes
are unchanged. These are explicit mutants, not an old incompatible ABI run.

`codex_call121_values_03.ps1`, session19056, is TERMINAL0:85 actual relinks,
170 actual RUN observations. Original154 plus target4 remain GREEN; copy12
still has8 RED/4 GREEN with the same actual exits and unchanged7 oracles.
Every10848 upstream120 pin was reverified. Frontend/generated C stay118;
unit objects are the exact120 recompiled objects, not freshly built121 units.
Reuse is justified by exact generated-header equality after removing only
the two new prototypes: internal layouts and existing signatures are unchanged.
This runtime replay is not a new frontend translation or full language gate.

Unlike120's legacy-C recompile, kernel02 freshly translates the kernel source
with121 implements, then runs unchanged62 context,57+20 copy,789 templates,
54 pending and48 priority checks, all GREEN. The rebuilt runtime is O2/strict.

## Preserved failed attempts and storage

Fixture01 could not link primitive constructors absent from the driver;
02 translated their module with duplicate predef bodies and also failed link.
03 constructs the intended typed primitive record and passes62. Expanded
fixture04 executes68/3 FAIL because the test supplied raw numeric cells where
PUT requires executable operands;05 repairs those two constructors to LIT,
without changing any oracle, and passes68.06 adds the four empty/conflicting
coordinate checks and passes72;07 repeats72 on final status-corrected bytes.

Replay01 records48 observations before the old positive deep-capture walker
regresses; all failed bytes/logs and GDB scripts remain. Replay02 with the
common direct helper finishes170/162 GREEN/8 old RED, but kernel01 finds
4/789 failures: conflicting coordinates returned NO rather than UNKNOWN.
GDB confirms all four are the same conflict under frame/catalog adapters.
Only that status is corrected; unchanged kernel02 and final replay03 pass.

Final/new replay executables are retained in per-unit ZIPs, with actual-RUN
SHA, archive SHA and decompressed byte-stream roundtrip checks recorded in
each `artifacts.json`. To restore one into a NEW directory, use
`Expand-Archive` on its explicitly named ZIP; do not overwrite old evidence.
Only the new loose replay executables were removed after verified archival.
No old input was deleted. NTFS compression of the85 completed120 binaries
keeps every path and raw SHA unchanged, freeing69,496,832 physical bytes;
the bounded receipt is `build/codex_call121_compress_01/results.json`.

## Still open

Generated-native producers/adapters and primitive raw-ABI result metadata,
all physical field/index context producers, and relocation/lifetime of these
components through the final copy map remain open. A raw storage pointer is
not reinterpreted as a containing typed value. Copy positives remain8 RED;
last full112 gate remains1011 FAIL/3754, not rerun here. Public dev remains
compiler56/runtime69/reader76. Full native/walker unification, clean kernel,
self-build §§8/8a and T01–T26 are not complete. Goal ACTIVE; next work must
extend the SAME computed-value result through native/path/copy consumers,
not add a merge-only fix, repeated parse, guessed Model or bounds guard.

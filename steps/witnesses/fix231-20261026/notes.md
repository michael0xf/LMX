# Fix231 driver helpers in ordinary L2

Date: 2026-10-26. Base main is d1fd3b53c3749723d6874d5790277f37c7b463b4.
Twenty-five explicit-argument driver helpers now have maintained ordinary L2
bodies. The corrected source-only cold bootstrap completes with exit0 and
smoke9/0; G1 really builds G2 and both start, hash and replace the working tool.
This remains the mixed bootstrap, not source-closed S8.6.

## Maintained source and ABI

The module is dev/l2src_sandbox/l2_driver_shape.lm2. Executed candidate SHA256 is
a80877dfd328d381af732a75220716877f04f09cde8a55932738575dcca9ac20:
25 functions,22 unchanged public machine entries and3 private helpers.
Its old25 definitions are removed from the maintained harness, leaving32
bodies in driver5e217a00. The original58 process-observation declarations,
assertions and caller ABI are unchanged. No new globals, context, graph,
language syntax, parser or admission rule were introduced.

Recipe dba55676 translates the module after kernel L2 and before common C
headers and driver translation. It deletes generated helper L1/API/C-header
targets first and stops on translation failure. The old helper bodies are
not a fallback. runtime.list selects the new source; the ordinary inventory
is47+1+1+8+17 =74 inputs. Three promoted canonical paths remain raw-equal
to their checked candidates, including inventory22491748. Final helper
00d3332a77a9cf625c82c6e92e95a5ea5cd5592a0a2fa922ff16ca0048ca74c7 removes
three trailing LF bytes from executed A808:22166 versus22169 bytes, prefix cmp0,
removed bytes10,10,10. The canonical file retains one terminal LF.
No statement or consumed input changed.

The actual generated API preserves const char pointers, pointer depth,
argument order, int/size_t results and explicit arena arguments. Named
VoidArray views address the same inline C field; loop bounds still read
its live size. Guarded LmxOp views remain after the old domain checks.
This is machine-C execution, not proof that all25 bodies were exercised
or that their bodies were walked.

## Preserved failures and corrected cold chain

The combined initial capsule used old L1 declaration surface. Warm seed
41567 completed0, executable554432be, but that compiles the new recipe,
not the helper body. Its58 explicit generated kernel declarations are
bound separately from maintained source inputs.

Initial cold02/session68188 exits1 at runtime step5: the helper refuses
at12:19, unknown type, frame=const. Its completed frontendc71ed29c remains
an explicit preceding frontend, not a successful whole bootstrap.
The separate diagnostic03 is warm L2-only investigation: declarations37aa,
alpha-renames616c, physical views c16b and final local-const form a808.
The first three refuse; the last translates to L1/API with exit0. No C,
runtime or cold-source-closure success is attributed to diagnostic03.

Fresh cold04 receives only74 maintained source files, final manifest3c7187a7;
no seed headers or diagnostic variants are copied. Before launch its
generated L1/C headers and output label are absent. Session54130 runs once,
12:04:39.1753563 to12:40:08.1844116 UTC, actual exit0,2129.0090553 seconds.
The new frontendc3e59a84 actually translates final helpera808; generated
L1 dfe5db5b and API2c990c18 precede the runtime consumer. Frontend source/C
remain2331696c/52d5f679. Runtime C872481fe compiles strict production1152eb1a
and observed8297472c with both compiler exits0.

Serial post-terminal dependency-only GCC readback uses the actual component
flags and include order. It selects13 frontend and40 runtime C headers,
all below cold04/headers; the new helper API is actually selected. The64
regenerated-header count is not a consumption count. No second C build or
additional smoke campaign was run for this readback.

## Actual values and generations

The same nine existing smoke rows pass. All four native/forced root0/1
S8.1 logs were read, preserving these values:

```text
calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
counts A1=42 A2=42 B1=43
after A1 count100 A1=101 A2=43
runtime r=142 p.y=42 p.x=1 p.pad=9 q.w=10
refusals C=30 Thin=33 Far=34 y=2
seven unused=3 called-plus1=8
```

Forced library commands use --walk-methods. A native callee reached from
a walked root is not counted as walking its body. These values preserve
the existing witnesses, not complete common interface admission.

G1 executable4b545d80 actually builds G27e9586d4. Both start, hash and
replace the working tool. G1/G2 L1 aab53135 and C eb70cd2c match the two
expected pins frozen from completed G1 before G2 completion. Objecte5514831
equality is observed after completion, not predicted. Working/G2 rawcmp0;
the existing EXE-SAME command returns1 with exit0.

G2 language verification confirms source74 and expected2 with0 failed;
independent GNU verification also returns0. Source74 retains the inherited
native_closure_values snapshot already distinguished225–229; all74 equality
with canonical is not claimed. No consumed output was normalized.

Initial raw-equal canonical4 passes G2 language and independent GNU
verification. Final canonical4 has a separate manifest after the formatting
cleanup; the original pins and executed source patch remain unchanged.
Both source patches replay from the exact published229 base with GNU
--fuzz=0 and reproduce their respective four expected hashes. Two preparation
commands needed corrected old-driver and null-device path spellings;
neither altered a source or ran a compiler.

The first diff-check reports four files with extra EOF blank lines: the
canonical helper and three packet copies. The first cleanup leaves the
helper and views snapshot RED; the final cleanup removes the remaining blanks.
Intermediate1eded7fc pins/logs are retained, not the final canonical pins. Packet text
uses LF/terminal-blank-line formatting; original stage records and snapshots
are bound separately from their copies. The consumed stage bytes remain unchanged.

The228-file bounded artifact manifest has SHA256
d69a371ef581c699b9bc2d748cd732ed5dcb17ca9d4e500bfb6b4d7ddf73ff88.
It binds raw and published records separately, actual FE/runtime/G1/G2 bytes,
the four final canonical paths and53 selected generated headers. Existing G2
manifest/verify and independent GNU verification record the result separately.
The first documentation check caught CRLF in five new packet copies; only
those copies were formatted. Corrected check_docs and staged diff-check pass.

## Remaining work

Common used-interface narrowing/UNKNOWN handling, general immutable/native
effects, runtime-callable/Q49, compiler/backend/driver/libc/tooling closure,
S8.6 and mailT01–T26 remain OPEN. The next source-only232 capsule combines
these25 helpers and all32 remaining driver bodies in ordinary L2, with
declaration-only L3 writers and one owner/cleanup for the former four VLAs.
Its source review and warm recipe preparation are not body execution or a
verified complete driver port, and none of that source is promoted here.

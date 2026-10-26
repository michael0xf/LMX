# Fix228 shared CALL and NAMED shape readers

Date: 2026-10-26. Base main is72579fbcfa8d2f08d59c56ecc4a5a295308394dc,
with Verified227 code. One whole SHORT on fresh interface03 completed
with exit0, nine smoke rows and0 failures. G1 built G2; both generations
started, hashed their own L1 and replaced the working tool.
This remains the current mixed bootstrap, not source-closed S8.6.

## Source change

The only maintained code change is
`dev/l2src_sandbox/lmx_walk_values.lm2`, SHA256
`b4d3c2d50322a5b13dd4ea29978fa752a568195f4ea72f016cb516f82ad90715`.
Three arena-only readers expose written OP, CALL/EXEC envelope and one
NAMED operand. Ordinary execution uses the same readers. They do not
select a provider, evaluate a body or perform admission.

Short CALL keeps its existing distinction at every arity. Long CALL and
EXEC retain raw contract presence until validation after selector effects.
Their selected callee/data are reread after effects, and dispatch still
follows actual-argument evaluation and publication. NAMED operands decode
in their original per-operand order; null still occupies its coordinate.
Bounds checks reject invalid operand/order extents and scratch overflow.

Two observable error/instrumentation details are explicit: pure readers do
not increment the execution classification counter; malformed NAMED/order
may leave refs_out null rather than partially populated. Both existing
callers consume that output only on OK. The source review found no
material execution regression.

The unaccepted private228/02 activation-home/resolver/cache draft is not
included. The common implements checker is unchanged: using recorded
Consumer calls for used-interface narrowing and handling uncertainty
without declaring incompatibility remain OPEN. Additional analysis stays
in the programmer's explicit test; this extraction adds no result proof
or speculative gate.

## One completed bootstrap

The source-only copy contains78 selected inputs from frozen private01;
no generated header or body was copied into fresh interface03 before the
bootstrap. G2's final language verification and independent GNU verification
both confirm all78 files. The inherited native_closure_values fixture
snapshot still differs from canonical as already225–227; all78 equality
with the checkout is not claimed.

The existing recipe regenerated declarations before their consumers.
Frontend L1 is2331696c, C52d5f679 and executable92a598a0.
Runtime C is95174491, production objectb3f3e7c7 and observer7313600d.
Strict compile/link phases returned0. The generated values module is
ff0af667 and its APIbe6c12d3. Runtime objects match frozen private01, but
this bootstrap generated its own declarations rather than copying that
stage's seed header.

All four existing S8.1 native/forced root0/1 logs were read:

```text
calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
counts A1=42 A2=42 B1=43
after A1 count100 A1=101 A2=43
runtime r=142 p.y=42 p.x=1 p.pad=9 q.w=10
refusals C=30 Thin=33 Far=34 y=2
seven unused=3 called-plus1=8
```

Forced library translation actually uses --walk-methods; a native callee
from a walked root is not counted as walking its body. Existing tests were
reused without a new matrix, compiler variant or repeated smoke.

G1 executable is56920713 and G2/working isee945db9. Both L1 and C match the
expectations saved before G2 completed:
4573ebd43b425b5d152a9ebdcfeb74cd7d427dcb78404ea0284bff823920ae78 and
44d76acb66ee24593a8ea677684f2af93834fc969a93e0605e72096683899498.
Both objects are7b1faf85; that object equality was observed after completion,
not recorded as an earlier prediction. Working/G2 GNU raw comparison
returns0; the existing G2 EXE-SAME command reports1 with exit0.

The launch began09:20:14 UTC and terminal0 was observed before09:55:18 UTC.
Unified session45474 was never restarted. Its buffered console stayed at
an old smoke line while child G1/G2 progressed; completed child records and
the terminal result establish completion. Near the last compile,
free virtual memory was311952KiB; no competing compiler was started.

After terminal, serial dependency-only GCC readback selects13 frontend
and39 runtime C headers, all from this stage's generated headers.
Frontend01 matches its normal include order. Runtime01 used frontend
flags and is preserved; runtime02 uses actual -O2/-fstrict-aliasing and
runtime include order. Both return0; runtime02 is the selected trace.
No additional C compilation or smoke was run for dependency readback.

## Byte binding and preserved failures

The exact one-file patch replays from the canonical base with GNU
--fuzz=0 and compares raw-equal to the executed source. Canonical source
promotion has the same B4D3 bytes.

The first final3 language verifier used absolute manifest entries with a
root-relative reader and reported3 failures. GNU checked the same bytes
successfully. The corrected relative manifest changes no expected hash;
G2 verifies3 files with0 failed and13 checks/0 roots. GNU also returns0.
The original absolute manifest and failed log are retained. An additional
GNU command initially named its manifest relative to the wrong cwd and
checked no bytes; the explicit-path invocation returns0.

Private01 runtime01's earlier missing-generated-header failure and
runtime02's explicit old seed preparation are retained in that stage.
They are not cold bootstrap evidence. Fresh interface03 completes the
whole chain without that preparation.

The next source-only229 draft moves all five remaining compiler
declaration headers into ordinary L3 literal writers. Its generation and
consumption have not yet run; it is not part of Verified228.
Remaining compiler/backend/driver/libc/tooling source closure, uniform
native/qualified callable work, S8.6 and mail T01–T26 remain OPEN.

## Artifact binding

The existing G2 manifest command binds143 explicit files: raw stage records,
their mechanically LF-formatted packet copies,52 selected C headers,
compiler/runtime/tool artifacts and both owner program variants. Its
LF-formatted manifest SHA256 is
fff63f02a94b87e6fa20ffe54433871703fd67057ad5da7cf8df7ef786400dc2.
Generation and G2 verification both return0 with143 files/0 failed;
independent GNU verification also returns0. No expected artifact value is
changed by newline formatting of the manifest. Notes and the verifier's
own log are outside that binding.

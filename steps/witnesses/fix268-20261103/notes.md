# Slice 268 — typed bitwise and shift operations share the runtime kernel

Typed language bitwise and shift expressions now call the existing
lmx_walk_value_bin before the machine operation, just like runtime-typed
inputs and the walker. The existing typed receive adapter provides the C
result view. There is no second count/overflow algorithm in the emitter.
Nested shifts under another bitwise operator take the same operand path.

The general implicit-throw emitter returns the named status for every
ordinary language body. It clears the payload output only when that
parameter exists in the current ABI; it does not predict another body or
add a throws closure. Existing explicit payload handling remains intact.

The fixture checks valid unsigned/int/size_t results, width32/64 and negative
counts, negative signed left operands and signed overflow, plus a nested
shift. Catches observe interpreter before the invalid C operation.
The actual G2 focus passed 29 rows with zero failures on native/forced and
both roots. The following records preserve the initial failed candidate
and its correction; the final verification below is authoritative.

## Development sequence

Baseline: published slice 266, 01a7e3a8ff7d95c1427ceb45f6d73c0174b8339a.
This independent candidate uses maintained source266. Pending ordinary-var
work stays in tp129/WIP267 and is not included.

The measured baseline typed_shift_guards probe returns native81/forced7.
Typed native emission currently performs a C shift before kernel checking.
The candidate emits the existing shared lmx_walk_value_bin and receives its
result through the existing typed receive adapter. Count/overflow logic is
not copied to the emitter. Nested shifts under bitwise operators use the
same recursive operand path. Machine/opaque foreign ABI expressions retain
their existing explicit contract.

Changed inputs: lower, full-suite, new typed_shift_guards fixture.
Expected focus: native/forced, both roots return7, including width32/64,
negative count, signed negative/overflow and nested shift. Unary ~ remains
open. No whole-bootstrap/publication or full ledger closure is claimed.

Frontend fe130a passed (845b8e54706ae9e6911ed7330e25774f644584aeeab75d762cd5926792133eac).
Focus01 completed 29 rows with 2 native C-compilation failures:
free_machine_ops and typed_shift_guards referred to undeclared l2_out_throw.
Their forced runs pass. All other rows pass. This is not a runtime success
for the new native path. Generated C calls the common operation correctly;
the existing implicit-throw emitter unconditionally wrote a payload parameter,
though ordinary bodies already have a status result independently of it.
Fix02 keeps named status propagation unconditional and clears payload only
when that parameter exists in the current ABI. It adds no throws forecast.
The candidate now has four changed inputs (also useplan).

Fix02: fe130b completed successfully, SHA
65e8ef8e11987fe8ed1d705964cea2c0cbc80231decaf1ecc62360b0c8d44c87.
tp130-suite-02 ran 05:26:21.1010208Z--05:26:42.6806153Z, SuiteExit0,
2 rows/0 failures: free_machine_ops and typed_shift_guards both give7
in native/forced and root0/root1. Width32/64, negative count, signed
overflow/negative left and a nested shift all execute their checks.

The 181-input package is frozen into cold-boot130a. Source-tp130 and
source-boot130a have identical manifests:
cf7ad03769104512f36ca96148097ae665ec54fddaa596292da38eaee4bd883d.
All 181 frozen files were independently hashed with zero mismatches.
boot130a-quick is the current single pipeline, launched with the published
boot128a G2 tool/frontend. It has not been restarted. The execution handle
at this checkpoint is exec session39399; pins/boot130a-quick.terminal.txt
and pins/boot130a-quick.log are the named receipts.

Next: observe that exact bootstrap to its real terminal result, then run
the prepared boot130-compare.command with TP_TRY=a and tp130-suite-g2.command.
Inspect real producer records/inventories and G2 focus29. Landing/docs268
commands have NOT yet been prepared or executed. Maintained selfbuild and
HEAD are still published266. Pending tp129 ordinary-var WIP267 is separate.
Unary ~, ordinary-var U3, FREE-root paths and the rest of C/§§8/8a stay open.

## Verified result

Bootstrap ran 2026-11-03T05:27:02.5208379Z to 2026-11-03T05:39:42.4297091Z, 759.91 seconds,
BootstrapExit0. Each generation passed 9 smoke rows. The real G1 frontend
was the producer of G2, and each generation's frontend built its own
runtime and tool. Producer records contain 33 frontend, 39 runtime and
6 tool steps per generation, all kind 0/exit 0.

All 181 frozen and all 181 landed source files match the source manifest.
The independently rehashed inventories contain 248 paths each: 245 raw-equal,
3 equal-size PE executables differing only in their actual timestamp and
checksum fields. No stale hash was found. All 306 consumed inputs match,
and the promoted working bundle and tool are G2.

[Bootstrap](records/boot130a-quick.terminal.txt),
[comparison](records/boot130a-compare.txt),
[G2 focus](records/tp130-suite-g2.terminal.txt).
The eight-step language-owned landing verified both consumed source subsets
and copied the same package into selfbuild.

| Artifact | SHA-256 |
| --- | --- |
| Input list | `99f9bae8af2197dfee3801f04220dea30570b0642964f1807579a3c2edc4d4fb` |
| Input manifest | `cf7ad03769104512f36ca96148097ae665ec54fddaa596292da38eaee4bd883d` |
| Working tool | `31d55441805a79a36a93e6bb7ff842370b034fbc6d1f440c3a9ecc9702e46f43` |
| G2 frontend | `ec3e0ae8a19f8f61114b425fc6374d9e46291b95891fe77029d2703dc7434e18` |
| Production runtime | `e617e95da4019c90a4b47adcb62ddfc79d9818d0729c4bb43b7ba7164a581c96` |
| Observation runtime | `84ef7a8471496a0225482985e773f856cf89f075b29ffcd0ff12409dc68bc774` |


## Remaining work

Unary ~ remains OPEN in the bitwise ledger. Ordinary-var WIP267 stays
separate from this source package while U3 is pending. FREE-root paths,
the remaining body/throws/D105 closures, shared collector and three compiler
passes, final FULL and sections 8/8a remain open. This slice does not claim
completion of the whole optimisation or goal.

## Documentation check

The first docs268-check ended with exit 1: 22 archival working-copy files
had CRLF line endings. Only these new repository copies were normalized to LF.
Original receipts under build2 are unchanged; evidence.sha256 hashes those
original artifacts. The archived logs preserve their text, not their original
line-ending bytes. A separate docs268-check02 uses fresh output and CWD paths.

The second check ran 05:46:41.2309132Z--05:47:00.9356694Z and exited 0.
It verified 35 paired semantic chapters, 14 implements cases, 27 paired
grammar sections, 44 verbatim excerpts, 615 imports, links and LF/index
checks (15585 tracked files at that check); driver: 60 checks.
See [terminal](records/docs268-check02.terminal.txt) and [log](records/docs268-check02.log).

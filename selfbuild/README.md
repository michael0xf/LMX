# Maintained L3/L2 source package

This is the selected repository source root for the existing language-owned
`manifest`, `stage-copy`, `rebuild`, and `bootstrap` route. Keep its relative
layout: `src/l2src/`, `tools/`, and `tests/`. In particular, the full suite's
`../tools/sha256.lm2` extra input is relative to `tests/`; moving that list to
`tests/l2/` without an explicit source change would break its resolution.

The selected package contains 189 inputs (65 source files, 34 tools and
90 tests). Slice273 makes a C pointer parameter receive a free value by its own
contract: a leaf the kernel has a type for is judged by the actual pointee, another
C type by the pointer code the value carries, and only a `void` leaf is opaque. A
wrong pointer is `convert` before the call; a null, a void pointer and an explicit
cast pass.

Slice272 gives a free value its remaining known consumers. A C call
with a declaration in a predef document takes it as an actual and gives its
declared result beside it; cast, `c.sizeof`, index and `length` read the actual
value. A field selected by name from a free holder is written after the ordinary
admission: a Structure against the model the slot declares, `implements` when it
does not fit and the slot keeps its value; a number is `convert`, the literal 0 a
present null; a slot holding a Structure or an Array directly is rebound by a
value of the same kind. Native and walker share `lmx_walk_value_field_store`.

Slice271 keeps a written INDEX on a held free value until the
reached operation. Native and walker select its actual place through the one
kernel operation `lmx_walk_value_index_place`: an Array uses its descriptor's
metadata, a machine pointer uses the same actual classification as DEREF. Read,
write and `@` consume the selected place, and the index is an ordinary `size_t`
receive. An own Array is an ordinary activation binding, so a callee's free name
reaches its caller's Array even when the caller never reads it.

Slice270 binds ordinary written data declarations to existing
physical source cells. The reserved var input starts as selected data;
ordinary assignment replaces that same binding, and subsequent explicit
paths follow its current reference. A distinct data/var field and held
bare fields stay separate. Structure assignment does not execute its body.

Native and walker share actual named-place selection, reception and store.
A consumed numeric receiver uses one prepared expression and the common
runtime value receiver. There is no separate var parser or hidden graph.

The whole quick bootstrap took 1044.82 seconds; G1 and G2 each passed 9 smoke
rows. G2 passed 37 focused rows. Separate G2 observation checked 13 genuinely
walked bodies with exact counts on both roots, and native walks none of them.
All 189 published source hashes equal the frozen tested input byte for byte. The
248 generation inventories are identical: 245 raw-equal files and 3 PE files
differing only in link metadata.
[Sources and checks](../steps/witnesses/fix273-20261103/notes.md).

| Artifact | SHA-256 |
| --- | --- |
| Input list | `cbe2a92eab355e30fc48808075e63f9a4baf4f0daf02e5b8ed5c996cafe1c41e` |
| Input manifest | `985904fd0bf0d09b9011fd9b9c594484c3d1ede2474c489becfe16336ac16378` |
| Working tool | `edbba01de59e68f74038d6c67cd5d3d618357159189554c5c2f7011c19c307c2` |
| G2 frontend | `e53a3b0142b1306a6a55c0bbfb628a4acaebc7277723c39ec85c1d0c68da8518` |
| Production runtime | `2417e433153a9b4a7ffb6531d1dbdb92800a228cb9e01ec68abb90d3171a0248` |
| Observation runtime | `5ba219c73c9724c620de322e4dbba98ac4340213d53bd26b37fcba16f5970c0c` |

[Slice 270](../steps/witnesses/fix270-20261103/notes.md) contained 184 inputs,
manifest `B9AF771A…`, tested on the frozen `E4D1E376…`: 182 files raw-equal,
l2_driver.lm2 with its CRLF endings normalized to LF, l2_frontend_views.lm2
without one extra blank line at EOF. Its working tool is `2E936543…`.

[Slice 268](../steps/witnesses/fix268-20261103/notes.md) supplied typed-native
bitwise/shift guards and the common implicit status return.

[Slice 266](../steps/witnesses/fix266-20261103/notes.md) preserves absent data
for an ordinary unary call with no var and admits required data fields
before dispatch. Slice270 reconciles that earlier private candidate with the exact author rule.

[Slice 265](../steps/witnesses/fix265-20261103/notes.md) collected the declared-place interface independently of direct call sites.

[Slice 264](../steps/witnesses/fix264-20261103/notes.md) contained 178 inputs and introduced admission of the actual code/data pair at Structure calls.

[Slice 263](../steps/witnesses/fix263-20261103/notes.md) contained 173 inputs,
manifest `48951CA2…`, and established the shared dispatch of unary Structure calls.

The preceding packages were [slice 262](../steps/witnesses/fix262-20261102/notes.md)
(170 inputs, manifest `A148F03F…`) and [slice 261](../steps/witnesses/fix261-20261102/notes.md)
(167 inputs, manifest `CB155E7E…`).

The previous packages: boot122a is slice260 (manifest `8F34D77F…`; 6 files
over boot121a and one new fixture); boot121a is slice259 (manifest `BBCCB259…`; 6 files
over boot120a and one new fixture); boot120a is slice258 (manifest `55C1CC2D…`; 7 files
over boot119a and one new fixture); boot119a is slice257 (manifest `900AB284…`; 4 files
over boot118a and one new fixture); boot118a is slice256 (manifest `1016F41D…`; 4 files
over boot117a and one new fixture); boot117a is slice255 (manifest `FC9659DF…`; 10 files
over boot116c and one new fixture); boot116c is slice254 (manifest `DC4E8C62…`; 9 files
over boot115f and one new fixture); boot115f is slice253 (manifest `48F66AF0…`; 19 files
over boot114, the input list unchanged); boot114 is slice252 (manifest `FE3FDA29…`; 6 files
over boot112 — tp113 and tp114), boot112 is slice251 (manifest `7FA43F9E…`; 15 files
over boot89 — 9 inherited from full100, 8 of tp112), boot89 is
[slice246](../steps/witnesses/fix246-20261031/notes.md)
(its tested source [slice245](../steps/witnesses/fix245-20261031/notes.md));
the original unchanged publication is [slice239](../steps/witnesses/fix239-20261029/notes.md);
candidate48 and its FULL48 run are [slice240](../steps/witnesses/fix240-20261029/notes.md)
and [slice241](../steps/witnesses/fix241-20261029/notes.md).

## Normal source selection

Choose an explicit working G0 tool and its matching previous frontend,
backend and libc tuple; retain their provenance. Run each language CLI in a
fresh separate working directory, never the repository or source root.
STAGE is a new empty output root; do not prefill generated headers or bodies.
Using absolute substituted paths, the existing commands are:

```text
TOOL 0 entry 0 -- verify REPO/selfbuild/inputs.sha256 REPO/selfbuild
TOOL 0 entry 0 -- stage-copy REPO/selfbuild/inputs.sha256 REPO/selfbuild STAGE
TOOL 0 entry 0 -- bootstrap quick REPO STAGE BASE PREVIOUS_FRONTEND LABEL STAGE/tests/smoke-kernel225.tsv
TOOL 0 entry 0 -- bootstrap full REPO STAGE BASE PREVIOUS_FRONTEND OTHER_LABEL STAGE/tests/smoke-kernel225.tsv STAGE/tests/full-suite.tsv
```

Quick and full are separate requested modes, not an instruction to run both
automatically. One invocation of either builds/tests G1 and then G2 using the
actual G1 tool, promoting both. Normal generation reads staged inputs;
missing generation is a failure, not permission to reuse the older repository
headers or a cached object. Generated headers come before their consumers: the
runtime step writes the kernel's generated L1 and C headers that the smoke
list and the tool then read. The source package is authoritative; older
`dev/l2src_sandbox/`, `tools/l2/inputs/` selections and PS/Python gates are
historical inputs/routes, not an alternative fallback for this route.

boot135a selected, under the ignored `build2/codex_fix250generationchain01/`:
G0 `cold-tp135/tool135a/lmxtool-tool.exe` (`CA6B3282…`, built by `rebuild tool`
from this package's tool sources with boot134b's G2 frontend and runtime),
previous frontend `cold-boot134b/quick134b/g2/frontend/l2trans.exe`
(`C2EA29AC…`, the G2 frontend of slice272) with its adjacent backend
(`098EB511…`) and libc (`AF9FDAE3…`), and BASE
`cold-candidate48/full48/g2/frontend`. Its promoted working tool is
`cold-boot135a/quick135a/lmxtool.exe` (`EDBBA01D…`), the G2 tool, with
`working-bundle.sha256` equal to the G2 bundle.

## Current acceptance boundary

boot135a passed whole QUICK on these bytes from a fresh source-only stage
(2026-11-03, 16:00:57–16:18:22Z, 1045 s): `BOOTSTRAP quick 0 failures`. G0
built and tested G1 (frontend, runtime, the 9-row smoke list with 0 failures,
tool) and promoted it; the actual G1 tool built and tested G2 the same way,
and G2 was promoted. Every program of the smoke list runs the driver's
start-up self-check of the code links on a private arena before its own main.
Quick runs neither the full list, the OS walk witness nor the self-test, and
does not compare the generations. The focused G2 list and one OS walk witness
ran separately; FULL has not run on these bytes.
Compared from the receipts, 245 of the 248 paths hashed in both generations
are byte-equal — every frontend, backend and kernel L1, both C translation
units, the runtime objects, libc and the tool's L1 and C — and the three
executables differ only in the PE link stamp (TimeDateStamp, CheckSum). That
comparison is its own evidence, not a reproducibility gate. The draft79
line's open items (V63, the split-pointer place, the bare return) are not
closed by this result.

Publishing these bytes removes their sole residence in ignored WIP. It does
not by itself provide a clean-clone platform G0, prove every consumed include
or close S8.6, the clean/native/admission/source-profile debts, or the mail
API. Those remain the current [plan](../next_core_tasks_v3.md) and
[handoff](../to_opus.md).

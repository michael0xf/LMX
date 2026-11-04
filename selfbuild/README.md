# Maintained L3/L2 source package

This is the selected repository source root for the existing language-owned
`manifest`, `stage-copy`, `rebuild`, and `bootstrap` route. Keep its relative
layout: `src/l2src/`, `tools/`, and `tests/`. In particular, the full suite's
`../tools/sha256.lm2` extra input is relative to `tests/`; moving that list to
`tests/l2/` without an explicit source change would break its resolution.

The selected package contains 203 inputs (65 source files, 34 tools and
104 tests). Slice279 keeps a written form as the source occurrence of its head: the
definition stands at that occurrence with its fields, `S\[1]t\x` reads and writes them through
a static path, a free path, a model, `node\[N]` and a `merge` copy, and the assignment after
it is no occurrence. The role is on the nodes, not in a spelling, so `l2_written_N` is an
ordinary name of a program.

Slice278 makes a written Structure two acts: the definition stays in the body
and reaching the line assigns a reference to it to the place of its head after the
admission, with no copy and no merge. `t: (int: x 2); t: (int: x 5)` works in a method, in a
named Structure, at the root, at a formal and for `var:`; a rebinding changes the place,
not the body. A short `call: code` over two root heads `var:` is the implicit `call`. An
immutable value passes to a formal of its model's ordinary type.

Slice277 assigns a Structure through a path and through an evaluated holder:
the tail is given to the place after the admission and nothing that stood there runs, a
refusal keeps the old value. `Outer\Model()` and `Outer\Model: ()` give the place one
empty Structure, a bare read does not run it and `call:` does. `First: @: First: 0` is a
present null of the place. A map step with no record receives only the edge it uses.

Slice276 counts the root heads of a Structure in a registry beside its place
names. A repeated head makes no second field: a bare name at two or more heads refuses
on every route, and `s\[N]field` selects a source occurrence and reads what stands in
its slot now. A map step tells no pair, an unfilled edge and a negative answer apart,
and composes the records already made before any new admission.

Slice275 gives a place one map: a named root and a nested field declare a
layout on their slot, and a Structure of another layout admitted there is read, written,
addressed and published through the map of the admitted pair, at any depth. All writers
of a slot use one rebinding, and its refusal is the statement's implicit throw.

Slice274 makes a write drop only the native words it really touches. A
generated word holds no named Structure, named Array or callable: it reads such a
slot when it runs and calls a callable through that callable's own word, so replacing
one is data and keeps every word. A write of code drops the words of the code that holds
the place, not of code that only refers to its holder. A word over a machine operation
cannot be dropped, so such a write is the implicit `interpreter` before it changes the
graph or a word. A slot holding a Structure holds the node itself in both executors.

Slice273 makes a C pointer parameter receive a free value by its own
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

The whole quick bootstrap took 846.95 seconds; G1 and G2 each passed 9 smoke
rows. G2 passed 53 focused rows. Separate G2 observation checked 30 genuinely
walked bodies with exact counts on both roots, and native walks none of them.
All 203 published source hashes equal the frozen tested input byte for byte. The
248 generation inventories are identical: 245 raw-equal files and 3 PE files
differing only in link metadata.
[Sources and checks](../steps/witnesses/fix279-20261104/notes.md).

| Artifact | SHA-256 |
| --- | --- |
| Input list | `fc99357667647ab744df802a7c4bcb0e8b1e380f456f6f9782709a4bf62342e0` |
| Input manifest | `f1cdb8230f094af59dc0153ca03117e7a5cc2307fb346f9afd03ab92cfaf404f` |
| Working tool | `f67e809b29ce15997e4cff532688530bbfc85bc84a7ba7118f8eb30eaf2d4324` |
| G2 frontend | `0b97a5e2a1690626b4d5a9b138ebdae5ee4a637f1d64cac6b7e4eb392ca8b078` |
| Production runtime | `9b314600b2e3a8c9c27f8f16629ff113399f2916e5d8e2b615e205834862bab0` |
| Observation runtime | `a9cde4bfce12718bd03a675ece547110c0359bddcb6d89602297d78a2e4150c4` |

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

boot141a selected, under the ignored `build2/codex_fix250generationchain01/`:
G0 `cold-tp140/tool141a/lmxtool-tool.exe` (`AD653A65…`, built by `rebuild tool`
from this package's tool sources with boot140c's G2 frontend and runtime),
previous frontend `cold-boot140c/quick140c/g2/frontend/l2trans.exe`
(`3B12E554…`, the G2 frontend of slice278) with its adjacent backend
(`42E32326…`) and libc (`AF9FDAE3…`), and BASE
`cold-candidate48/full48/g2/frontend`. Its promoted working tool is
`cold-boot141a/quick141a/lmxtool.exe` (`F67E809B…`), the G2 tool, with
`working-bundle.sha256` equal to the G2 bundle.

## Current acceptance boundary

boot141a passed whole QUICK on these bytes from a fresh source-only stage
(2026-11-04, 15:59:23–16:13:30Z, 847 s): `BOOTSTRAP quick 0 failures`. G0
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

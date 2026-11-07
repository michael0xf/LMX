# Maintained L3/L2 source package

This is the selected repository source root for the existing language-owned
`manifest`, `stage-copy`, `rebuild`, and `bootstrap` route. Keep its relative
layout: `src/l2src/`, `tools/`, and `tests/`. In particular, the full suite's
`../tools/sha256.lm2` extra input is relative to `tests/`; moving that list to
`tests/l2/` without an explicit source change would break its resolution.

The selected package contains 229 inputs (65 source files, 34 tools and
130 tests). Slice293 takes a formal's written default when a call gives no argument for it: a literal of
the formal's own primitive type is its current default, a cell in its args entry, and a call takes the
default of the callable it selected -- by position or by name, through a callable place, by the `call`
receiver or through a callable formal; a supplied argument (zero too) is taken as before and never becomes
the default, and a caller's same-named value is no argument. One kernel function reads it for both
executors (`lmx_call_formal_default`, exported in tools/build.lm2, so a new G0). A default written in
another form is not built.

Slice292 lays the own fields a `fn` or `sub` body declares out in its var part, one place
each after the written var's fields; their statements and initializers stay in the body and run when
reached, and a read before the declaration stays a hidden input (`m\var\a` reads and writes the place,
`m\body\a` is refused). Native code reaches a var place through the selected data, as the walker does,
so `call: m D` writes D's fields.

Slice291 passes every word of a list line to its command (slice290 split a line into nine
words and dropped the rest without a refusal), and the full list `tests/full-suite.tsv` holds every
landed fixture through slice290: 101 rows.

Slice290 makes a field of a program part's root the lexical source of a hidden input in both
executors: a method of the part called from outside the part takes its free name from the dynamic input
first, then from the part root's field. Native code types the absent input's place by the selected
default, as the walker's ARG does; the walker holds at the entry also the source of an input the body only
writes, as native code does. A bare write changes only the activation's value; `node\x` writes the root's
field. A head with no binding and no earlier read written with a name tail (`h: v`) is now refused at the
tail instead of overflowing the translator's stack. The tool runs a list of its own commands: `checks LIST`
runs every line, `steps LIST` ends at the first failure; each line's output is followed by
`CHECK <exit> <words>`, the list by `CHECKS <lines> lines, <failed> failed`.

Slice289 receives an index of another numeric type at that L3 INDEX by the ordinary numeric
reception: the index's type does not choose the route, CHECK admits the reception as at an Array level,
and native and walked code call the program's converter (`lm_stg_convert_int_size_t` for an `int`), whose
refusal is the implicit `convert` before the place is selected; a program without it is refused at
translation. No program here defines converters: the tools' methods are a machine library (genuine L2),
and the tool parts that L3 programs use (`tools/text.lm2` in the self-test's child, `tools/sha256.lm2` in
`tests/sha/sha256_vectors.lm2`) index by `size_t`.

Slice288 checks the same L3 INDEX in native code: the place is selected by
`lmx_walk_value_index_place` over the pointer's current value, the index received as `size_t`, and an
index out of the place's interval or an overflow is the implicit `interpreter`; read, write and `@` are
the walker's, under one predicate (`lm_compiler_index_l3_path`). `tests/sha/sha256_vectors.lm2` counts
with `size_t: i`.

Slice287 makes the index of a machine pointer held by an own field or a formal the
L3 INDEX of slice271 in walked code too: ELEM, or ELEMPUT for a store, over the place's value,
the index received as `size_t`. A walked root with `px[0U]` no longer fails at run time, and such
methods are walked under `--walk-methods`. What the route does not take (a C ABI member, a machine
local, a C constant, a `void` or foreign pointee, an index that reaches `size_t` only by a conversion)
keeps the native-only machine path: a limit of the implementation, not a genuine L2 operation (corrected
by slice288).

Slice286 gives a callable's place its declaration: the callable its definition put there.
Every write there, by any path, is admitted against it before anything changes; a fn or sub of
another signature, result or declared throws is the implicit `implements`, in native and walked code
alike, and the old callable still answers.

Slice285 makes a `sub` one Structure of the parts `args`, `var` and `body`, as a `fn` is
with its return part: a short call's data is its var, and a sub with an own field can be called in
every form.

Slice284 makes a separator the end of an operand: `add(x, \px)` and `two(x, -y)` are
two actuals, and `@: p T \q` is the path in any spacing, whatever `T` holds; a requirement and a
dereference are written `@: p T, \q`.

Slice283 reads a path below a callable's place by name over the callable standing
there, a value in that place takes the selected call's admission (a missing place is the implicit
`call`), a reached write into an immutable value is the implicit `interpreter`, and `Box\k: (int:
a 8)` is the two acts a simple head has.

Slice282 makes `@: Box\f two` the write of a place through a path: it calls nothing,
for a callable, a Structure and a reference field, with null and `Model: value`. `@: x a\b` holds
what the path reads, its leaf being the requirement, and `got: var\i` with a declared `got` takes the
value at run time. A callable place takes what a named method reference takes.

Slice281 writes a declared reference field by the store a Structure field uses:
`Holder\p: X` asks of the value what the place's known Consumers read, a refusal keeps the old
value and the field keeps its cell. A path stopping at a reference no longer asks all of its
Structure. A received letter stays on the route of its payload.

Slice280 admits a value to a slot by what the known Consumers of that place
read: a field nobody reads is not asked of the value, a value lacking a read field refuses at
the write and the old value stays. An unknown use takes nothing from what is known and asks
nothing itself. A write through a head path reads nothing that stood there, so a null in the
field does not refuse it, and a walked `NullBox\k: 0` stores its one present cell. A candidate
read from a slot refuses by a named `implements`, not by an invariant.

Slice279 keeps a written form as the source occurrence of its head: the
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

The whole quick bootstrap took 1155.00 seconds; G1 and G2 each passed 9 smoke
rows. G2 passed 68 focused rows and the 85 rows of the full list. All 218
published source hashes equal the frozen tested input byte for byte. The 248
generation inventories are identical: 245 raw-equal files and 3 PE files
differing only in link metadata. The runtime objects equal slice286's G2 runtime.
[Sources and checks](../steps/witnesses/fix287-20261106/notes.md).

| Artifact | SHA-256 |
| --- | --- |
| Input list | `6e31cd27e3d105cd326c122b738d019480e8e23b79646bd90cbeca5c63776840` |
| Input manifest | `4314254336205dfd382f17ccbd96a1a212a84a5bb8c3348fdb2826f0fa341fc5` |
| Working tool | `3ffac1a49ddc133799bf13bd63f766e3ffb6c2de383825b815be7c3214161792` |
| G2 frontend | `8e415dadbf1e2e6bc14e8551d342719fed0ab999f526ebdfc2b8af28a8e1c4bb` |
| Production runtime | `2cab6a2717653d4e89f87fb977ce61e75bf60b6c406917ddf4cde8c2d4f66b9a` |
| Observation runtime | `47f74b3b39de2cd98aa1103d515b511840035df6e90247c776ce9e8b5b2d43cf` |

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
TOOL 0 entry 0 -- checks LIST
TOOL 0 entry 0 -- steps LIST
```

`checks` and `steps` (slice290) run the lines of LIST, each one command of this tool with its words
separated by tabs, in order; `checks` runs every line, `steps` ends at the first command that answers
other than 0. A list that names `checks` or `steps` is refused. Every word of a line reaches its
command, however many (slice291).

Quick and full are separate requested modes, not an instruction to run both
automatically. One invocation of either builds/tests G1 and then G2 using the
actual G1 tool, promoting both. Normal generation reads staged inputs;
missing generation is a failure, not permission to reuse the older repository
headers or a cached object. Generated headers come before their consumers: the
runtime step writes the kernel's generated L1 and C headers that the smoke
list and the tool then read. The source package is authoritative; older
`dev/l2src_sandbox/`, `tools/l2/inputs/` selections and PS/Python gates are
historical inputs/routes, not an alternative fallback for this route.

boot155a selected, under the ignored `build2/codex_fix250generationchain01/`:
G0 `cold-tp140/tool155a/lmxtool-tool.exe` (`082779F9…`, the tool this package's
tools/build.lm2 rebuilt with the boot154a tuple), previous frontend
`cold-boot154a/quick154a/g2/frontend/l2trans.exe` (`F43E1878…`, the G2
frontend of slice292) with its adjacent backend (`759E3BB9…`) and libc
(`AF9FDAE3…`), and BASE `cold-candidate48/full48/g2/frontend`. Its promoted
working tool is `cold-boot155a/quick155a/lmxtool.exe` (`179F0B3D…`), the G2
tool, with `working-bundle.sha256` equal to the G2 bundle.

## Current acceptance boundary

boot155a passed whole QUICK on these bytes from a fresh source-only stage
(2026-11-06/07, 23:57:33–00:08:41Z, 668 s): `BOOTSTRAP quick 0 failures`. G0
built and tested G1 (frontend, runtime, the 9-row smoke list with 0 failures,
tool) and promoted it; the actual G1 tool built and tested G2 the same way,
and G2 was promoted. Every program of the smoke list runs the driver's
start-up self-check of the code links on a private arena before its own main.
Quick runs neither the full list, the OS walk witness nor the self-test, and
does not compare the generations. The comparison ran after it as one list of
the previous working tool's own commands (`checks`): the stage against its manifest, every
producer record closed on its files and free of script hosts, G1 against G2
(`exe-same` for the three executables, which differ only in the PE link stamp,
`same` for libc, the runtime objects, the tool's L1 and C and the consumed
inputs), the working tool and bundle against G2, the candidate runtime against
G2's runtime objects (byte-equal), and the candidate frontend against G2 (`exe-same`). The whole
full list ran on that candidate (106 rows, 0 failures) and the G2 tool's
self-test on G2; FULL has not run on these bytes. That comparison is its own evidence, not a reproducibility
gate. The draft79 line's open items (V63, the split-pointer place, the bare
return) are not closed by this result.

Publishing these bytes removes their sole residence in ignored WIP. It does
not by itself provide a clean-clone platform G0, prove every consumed include
or close S8.6, the clean/native/admission/source-profile debts, or the mail
API. Those remain the current [plan](../next_core_tasks_v3.md) and
[handoff](../to_opus.md).

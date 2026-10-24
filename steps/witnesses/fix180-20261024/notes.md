# Slice 180: the arena's index of its arrays in L2 (S8.3, first step); the header replaces its file by the module's publication

Opus, 2026-10-24, sole writer/build. The slice follows Codex's postfactum review of Verified179,
CODEX-OPUS-REVIEW179-20261024T024436Z:
- the next step: «range тела -> L2 machine через текущий генератор, старые типы пока в .h.lm1 с честным OPEN source
  closure, старое тело без fallback; затем pool/arena малыми dependency-closed шагами»;
- Q3: «:45039 сначала remove(old header), затем rename(tmp,header), уже ПОСЛЕ commit модуля. Поэтому при ошибке именно
  финального rename прежний заголовок не сохраняется, а модуль уже новый; фраза «любой failed translation leaves both
  as they were» шире факта. Не строй транзакционный framework/кампанию: отметить точную границу, использовать обычное
  существующее замещение файла при компактном исправлении»;
- Q1: «Общую поддержку defaults/receiver conversions пока не объявлять завершённой: на order нет такого свидетельства, а
  нынешний bind_value_actuals_into:11608 отказывает отсутствующему аргументу.»

Verified180 is a bounded slice: the runtime and the frontend were built by the runner, its smoke ran, a targeted corpus
replay ran and the witnesses below ran. The tool was NOT compiled with the new recipe and the quick bootstrap was NOT
run, for memory. Verified180 does not close S8.3 or §8 and is not the L3+L2 self-build.

The stage is `build2/opus_fix180`, a copy of Verified179's stage sources (`build2/opus_fix179`).
- Two inputs change. Each has a -U0 delta here, and GNU patch applied to the Verified179 input gives the stage's bytes
  (`u0-same.out`: `SAME 1` twice; the commands in `u0-same.command`).
- `src/l2src/lmx_range.lm1` is now the build's product: the frontend writes it from `lmx_range.lm2` (`gen-range-01`),
  and `fe-01` regenerates it byte for byte (`regen-01`). The hand-written body is gone.
- The recipe (`tools/l2/build.lm2`, copied into the stage's `tools`) changes in the repository.

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `B8F0FE1E31211D12F3D28F2D6429B0549922D08AF3EDA6767B69CBB0195AC2AA` | `l2trans.lm1.patch` |
| `src/l2src/lmx_range.lm2` | `2C080F1FFFC42B3B8EDEF1BA8A0F6D78E7110D0932B884180333AC3BC5A4ED35` | `lmx_range.lm2.patch` (new) |

The generated `lmx_range.lm1` is `B35D71C44F5C701ABFB76C45F70EB5C32665C27CD226F9DAADE898E0E5FA8BD5`; the hand-written
one it replaces is `1D70C72EEAB247A04E752B22DE3448BF7CA22B75CD7C11F0EDCF79DF281E32C6`. The list's module and header do
not change.

## What changed

### The arena's index of its arrays is a machine module of L2

`src/l2src/lmx_range.lm2` is the maintained source of the index (Lingvamyxa_spec.txt 2, 6.5): the sorted table that
maps an address to the descriptor of the array containing it, its bisection, insertion and retirement, the live-cell
classification, the write barrier's overlap test and the imports of views. Its 26 functions are those of the
hand-written `lmx_range.lm1`, in the same order, with the same doc comments; the build names 24 of them as exports and
`lmx_range_entry_chunk` and `lmx_range_import_selected` stay the module's own.
- It is translated by the existing generator as a machine module, without `--header`: the module declares all its
  functions at its top. The kernel's code calls the 22 that `lmx_arena.h.lm1` declares through those prototypes, as
  before; `lmx_range_keep_chunk` (pool) and `lmx_range_cell_chunk` (collector) are reached as before, after the module in
  the kernel's translation unit. gcc sees the two declarations of each prototype together and they agree.
- The records it reads and writes (`LmxArena`, `LmxRange`, `LmxPool`, `LmxChunk`) and those prototypes stay in the
  kernel's L1 headers (`lmx.h.lm1`, `lmx_arena.h.lm1`): the machine C layout of types waits for the author, so they are
  not declared ported (source closure OPEN). A generated header for the index cannot simply replace those prototypes:
  they need `LmxArena`, which `lmx_arena.h.lm1` defines, so `lmx_arena.h.lm1` and such a header would import each
  other, which l1trans refuses (an import cycle), and the alternative — every consumer and the generated programs
  importing the new header — is the header restructuring that the types' layout belongs with.
- The accessors of the arena's index (`lmx_arena_index_data`, `_len`, `_cap`, `_set_*`), of a chunk (`lmx_chunk_data`,
  `_cells`, `_room`) and `lmx_source_names_drop` are the kernel's C functions, called through the C door; `realloc` is
  C's.
- The port needed no change of the translator. Two spellings differ from the L1: `profile` is a word of the language
  (a unit word), so the five bindings of that name are `p_profile`, `array_profile` and `wanted`; and a C member has no
  L2 type yet (C-DOOR-MEMBER-ACTUAL-UNTYPED), so the seven returned members and the four members passed to
  `lmx_range_add_view` are cast to their C types. A by-value local used only for `c.sizeof` is `c.sizeof(c.LmxRange)`.
- `pool\pointer_read(cell)`, the call of the C function pointer a pool record holds, is the expression's C span, as a
  C-door expression is.

### The header replaces its file by the module's publication (Q3)

The header is written beside its file (`FILE.tmp`) and, once the module is published, replaces `FILE` by the same
publication as the module (`l2_pub_commit`: the old file stays aside until the rename succeeded). Slice 179 removed the
old header before its rename, so a failure of that rename lost it beside the new module. The exact boundary: a failure
before the module's publication leaves both files as they were; a failure of the header's own replacement after it
leaves the new module beside the old header and names the header's path («the machine module is published but its
header cannot be replaced»). The function's comment says so instead of «a failed translation leaves both as they were».

### Corrected claims

Codex's review limits two claims of slice 179's records, corrected in the current state and the defects: the common
binding does not give defaults (a missing argument is refused), and support of defaults and receiver conversions is not
declared; the header's boundary is the one above.

## Real runs

The tool is Verified176's `build2/opus_fix176/tool-01/lmxtool-tool.exe`. The runs are its commands and direct
invocations of the frontend and `bin/l1trans.exe`; no probe script was written, and the commands are kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `gen-range-01` | Verified179's `fe-04`, the recipe's command for the index | the stage's `lmx_range.lm1`, exit 0 |
| `rebuild-runtime-01` (`rt-01`) | the generated index, smoke with Verified179's `fe-04` | `SUITE 6 rows, 0 failures` |
| `rebuild-frontend-01` (`fe-01`) | `rt-01` | `SUITE 6 rows, 0 failures`; the final frontend |
| `regen-01` | `fe-01` | the index's module, and the list's module and header over existing copies, byte for byte; no `.tmp` or `.bak` left |

Final builds: `fe-01/l2trans.exe` `B2417A8D…` (its source is the stage's `l2trans.lm1`), `rt-01/driver.o` `9762D86A…`
and `rt-01/driver-observe.o` `4484DE62…`. `rt-01`'s compile log has the warnings of Verified179's `rt-01`, the same
381 lines by kind and text: the generated index adds none. Its `driver.c` holds the generated definitions where the
hand-written ones stood (from line 274), and the module's own prototype block declares `lmx_range_keep_chunk` and
`lmx_range_cell_chunk` before their first calls (lines 7937 and 8404).

### Targeted corpus replay

`replay180-01` (`fe-01` + `rt-01`) runs Verified178's list (276 fixtures, both modes, 1121 checks): PASS 750, and every
line of its output equals Verified179's `replay179-02` (stage paths normalized). Its `failures.tsv` holds the same 370
inherited failures by class, check, reason and log (replay directory normalized). The L1 and C of every row are
byte-equal to `replay179-02`'s: the tool's `manifest` hashed the same 576 relative paths in both replays and its `same`
compared the two manifests (`l1same/`, `SAME 1`).

### The index runs in the runtime

| Mutant (`build2/opus_mut180`) | Change | Witness |
| --- | --- | --- |
| `rt-mutE` | the bisection of `lmx_range_entry_at` takes `p <= entry\lo` for `p < entry\lo` (`mutants/mutE.patch`), regenerated by `fe-01` | smoke `SUITE 6 rows, 20 failures`: every launch of the five runtime rows, both modes and both roots, exits 1 for 7 («lmx: the host could not open»); the translation-only row passes |

The mutant stage is a copy of the final stage's src, headers, tools and tests; its generated module differs from the
final one in that comparison alone.

### The header's boundary (Q3)

`q3/`: a directory stands where the list's header goes, and the old module file holds other bytes. With `fe-01`
(`q3-new`) the translation fails at the header's path («the machine module is published but its header cannot be
replaced»), the module is the new one, the directory is untouched and no temporary file is left. Verified179's
frontend (`q3-old`) fails the same way with its message. The case where moving the old header aside succeeds and the
rename then fails was not provoked: it is the publication's own code (`l2_pub_commit`), shared with every output.

### The tools with the new recipe

`tooltrans-01`: the stage's tools sources, as `bld_self` lists them, translated by `fe-01` (L2 → L1, exit 0, 188 s,
631 504 lines) and by `bin/l1trans.exe` (L1 → C, exit 0, 15 s, 802 315 lines; its first attempt ran outside the
stage's `src` and could not read its imports). The tool was not compiled.

## Evidence

`evidence-180.list` names 68 files: the stage's inputs and their Verified179 parents, the replayed copies, the final
builds and their runs, the replays compared and their manifests, the witnesses, the mutant and the tools' translation.
`evidence-180.sha256` holds their SHA-256, written by the tool's `manifest` (`runs/manifest-01`: `MANIFEST 68 files, 0
failed`); `sha256sum -c` checks all 68 OK. The packet's copies have LF line ends and no trailing blanks; the manifest
hashes the original bytes in `build2`.

## Not run (an explicit OPEN checkpoint)

- The tool compiled with the new recipe, the runtime built through it, and the quick bootstrap: memory, as in
  Verified178 and Verified179.
- LATER: the kernel gate, the gate, `bootstrap full`, the full corpus replay, broad tests of the index.

## OPEN

- The storage layer's source closure: the records and the index's prototypes stay in hand-written `lmx.h.lm1` and
  `lmx_arena.h.lm1` until the machine C layout of types is decided (asked of the author by Codex).
- C-DOOR-MEMBER-ACTUAL-UNTYPED: the index casts the C members it returns or passes to a machine call.
- MACHINE-STATUS-CHANNEL: a declared exit of a machine function has no C ABI.
- PUBLICATION-FAILURE-UNSAID: `l2_pub_commit` fails without a located diagnostic for ordinary outputs.

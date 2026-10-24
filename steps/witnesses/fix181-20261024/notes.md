# Slice 181: the typed service arrays in L2 (S8.3, second step); a machine module's header holds only header predefs

Opus, 2026-10-24, sole writer/build. The slice follows Codex's consultation on Verified180,
CODEX-OPUS-REVIEW180-20261024T032525Z: «Дальше продолжай пулы, затем арену тем же временным (б), по одному
dependency-closed шагу. ... Явный @ вложенного C-члена и запись через его адрес относятся к существующему C ABI; не
нужно привносить L1 разбор desc\array.size в L2. Если выявится реальная недостающая форма — общий механизм и конкретный
вопрос сюда.»

Verified181 is a bounded slice: the frontend and the runtime were built by the runner, its smoke ran, a targeted corpus
replay ran and a mutant ran. The tool was NOT compiled with the new recipe and the quick bootstrap was NOT run, for
memory. Verified181 does not close S8.3 or §8 and is not the L3+L2 self-build.

The stage is `build2/opus_fix181`, a copy of Verified180's stage sources (`build2/opus_fix180`).
- Two inputs change. Each has a -U0 delta here, and GNU patch applied to the Verified180 input gives the stage's bytes
  (`u0-same.out`: `SAME 1` twice; the commands in `u0-same.command`).
- `src/l2src/lmx_pool.lm1` and `src/l2src/lmx_pool.h.lm1` are now the build's products: the frontend writes both from
  `lmx_pool.lm2` (`gen-pool-01`), and `fe-02` regenerates them byte for byte (`regen-01`). The hand-written module and
  header are gone.
- The recipe (`tools/l2/build.lm2`, copied into the stage's `tools`) changes in the repository.

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/l2trans.lm1` | `2E03E0DC1114E54504B5A444E34766DF33DDC199C88DC1F95AD2A97EEBBFC12E` | `l2trans.lm1.patch` |
| `src/l2src/lmx_pool.lm2` | `2B2E016D093BDD49C03DD0F7615D4A1EFE3552981678DD6B44FF75B0C021E506` | `lmx_pool.lm2.patch` (new) |

The generated `lmx_pool.lm1` is `B701714B0415E1AE074FBCC6A2BF1481740A86A75FF142FC46D33640743A3B80` and its header
`lmx_pool.h.lm1` `A2AB022DBF2F5F3AAEE5B2966BFE9680E06AE7E122F38F21136D8A729968F66F`; the hand-written ones they replace
are `CABAB7C0C77CA614F5725CD192F6422BC773E88F3BB85487597A047A164CFE05` and
`D5FF176A18EAEBA7FEEA86CB45269821B844195ABB3B5915942B28E30ECCAB62`. The index's and the list's generated files do not
change.

## What changed

### The typed service arrays are a machine module of L2

`src/l2src/lmx_pool.lm2` is the maintained source of the arena's typed arrays (Lingvamyxa_spec.txt 2, 6.5; ABI 14.8,
14.9): chunks and their cell arithmetic, growth by adding a chunk, opening, making over the arena's own blocks or the
caller's records, taking cells, sealing, the chain of chunks and an Array descriptor. Its 21 functions are those of the
hand-written `lmx_pool.lm1`, in the same order; all 21 are exports, the prototypes the hand-written header declared.
The module's and the header's doc comments stand together above each function.
- It is translated with `--header`: the build writes `lmx_pool.h.lm1` in place of the hand-written header, so the
  kernel's modules and the generated programs import it as before. The header holds `<stddef.h>`, `lmx_arena.h.lm1`,
  `<stdlib.h>` and the 21 prototypes; the records (`LmxPool`, `LmxChunk`, `LmxArena`, `LmxArenaBlock`) stay in the
  kernel's L1 headers until the machine C layout of types is decided (source closure OPEN).
- The module predefs the index's module (`l2src/lmx_range.lm1`) after its header, as the L1 did: the pools call
  `lmx_range_keep_chunk`, which has no other declaration, so the index must come before them in the kernel's
  translation unit (the arena's module predefs it too). The L1's predef of
  `l1src/libc_abi.lm1` is gone: the machine functions call C's `calloc` and `free` through the C door, and the libc
  layer is already in the unit long before the pools.
- The arena's acts (`lmx_arena_*`), its block list's (`lmx_arena_blocks_*`) and the index's (`lmx_range_*`) are the
  kernel's C functions, called through the C door; `@ arena\blocks` passes the address of the arena's list.
- Spellings that differ from the L1:
  - the bindings named `profile` (a word of the language) are `pool_profile`;
  - C members returned, passed to a machine call or read into a typed local are cast to their C types
    (C-DOOR-MEMBER-ACTUAL-UNTYPED), mostly `(cast: (size_t) pool\stride)`;
  - the L1's `desc\array.size: len` writes the Lmx header's by-value `VoidArray` through its address
    (`array: @ desc\array`, then `array\size: len`), the existing C ABI Codex named;
  - the L1 computed byte offsets on `void *` (`lmx_chunk_data(chunk) + n`, a GNU extension, not C99); L2 gives `void *`
    no offset («void has no cell through either door»), so the port computes them on `char *`;
  - `(cast: (@: char) chunk) + c.sizeof(c.LmxChunk)` is refused (MACHINE-OFFSET-OPAQUE-OPERAND, OPEN): the port writes
    the same addresses as `chunk + 1` and `pool + 1` (C99 6.5.6).

### A machine module's header holds only the predefs of headers

A header may predef only headers: l1trans refuses a header that predefs a code module. With `--header` the generator
now puts the unit's `.h.lm1` predefs into the header and the others into the module, after the predef of its header
(`l2_pd_is_header`, `l2_emit_machine_own_predefs`). Without a header the module keeps them all, as before. The list's
and the index's generated files do not change (`regen-01`).

## Real runs

The tool is Verified176's `build2/opus_fix176/tool-01/lmxtool-tool.exe`. The runs are its commands and direct
invocations of the frontend and `bin/l1trans.exe`; no probe script was written, and the commands are kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-frontend-01` (`fe-01`) | the stage's translator, Verified180's `rt-01` | `SUITE 6 rows, 0 failures` |
| `gen-pool-01` | `fe-01`, the recipe's command for the pools | the stage's `lmx_pool.lm1` and `lmx_pool.h.lm1`, exit 0 |
| `rebuild-runtime-01` (`rt-01`) | the generated pools, smoke with `fe-01` | `SUITE 6 rows, 0 failures` |
| `rebuild-frontend-02` (`fe-02`) | `rt-01` | `SUITE 6 rows, 0 failures`; the final frontend |
| `regen-01` | `fe-02` | the pools' module and header, the index's module, and the list's module and header, over existing copies, byte for byte; no `.tmp` or `.bak` left |

Final builds: `fe-02/l2trans.exe` `9F716C54…` (its source is the stage's `l2trans.lm1`), `rt-01/driver.o` `5F63EFF8…`
and `rt-01/driver-observe.o` `C5DD0134…`. `rt-01`'s compile log has Verified180's warnings and one more: the discarded
result of the machine call `lmx_pool_release(arena, pool)`, a statement of `lmx_pool_open_profiled`, is held in a local
nothing reads (`-Wunused-but-set-variable`), the kind of unused local the generated code already has elsewhere.

### Targeted corpus replay

`replay181-01` (`fe-02` + `rt-01`) runs Verified178's list (276 fixtures, both modes, 1121 checks): PASS 750, and every
line of its output equals Verified180's `replay180-01` (stage paths normalized). Its `failures.tsv` holds the same 370
inherited failures by class, check, reason and log (replay directory normalized). The L1 and C of every row are
byte-equal to `replay180-01`'s: the tool's `manifest` hashed the same 576 relative paths in both replays and its `same`
compared the two manifests (`l1same/`, `SAME 1`).

### The pools run in the runtime

| Mutant (`build2/opus_mut181`) | Change | Witness |
| --- | --- | --- |
| `rt-mutT` | `lmx_pool_take_n` refuses an unsealed array: `pool\sealed = 0U` for `pool\sealed != 0U` (`mutants/mutT.patch`), regenerated by `fe-02` | smoke `SUITE 6 rows, 20 failures`: every launch of the five runtime rows, both modes and both roots, exits 1 for 7 («lmx: the host could not open»); the translation-only row passes |

The mutant stage is a copy of the final stage's src, headers, tools and tests; its generated module differs from the
final one in that comparison alone, and its header is the final one.

### The tools with the new recipe

`tooltrans-01`: the stage's tools sources, as `bld_self` lists them, translated by `fe-02` (L2 → L1, exit 0, 207 s,
633 910 lines) and by `bin/l1trans.exe` (L1 → C, exit 0, 15 s, 805 397 lines). The tool was not compiled.

## Evidence

`evidence-181.list` names 74 files: the stage's inputs and their Verified180 parents, the replayed copies, the final
builds and their runs, the replays compared and their manifests, the mutant and the tools' translation.
`evidence-181.sha256` holds their SHA-256, written by the tool's `manifest` (`runs/manifest-01`: `MANIFEST 74 files, 0
failed`); `sha256sum -c` checks all 74 OK. The packet's copies have LF line ends and no trailing blanks; the manifest
hashes the original bytes in `build2`.

## Not run (an explicit OPEN checkpoint)

- The tool compiled with the new recipe, the runtime built through it, and the quick bootstrap: memory, as in
  Verified178 to Verified180.
- LATER: the kernel gate, the gate, `bootstrap full`, the full corpus replay, broad tests of the pools.

## OPEN

- MACHINE-OFFSET-OPAQUE-OPERAND: a pointer offset by an explicitly opaque C operand (`c.sizeof`) is refused; the
  proposed general fix is a question for Codex.
- The storage layer's source closure: the records stay in hand-written `lmx.h.lm1`, `lmx_arena.h.lm1` and
  `lmx_arena_blocks.h.lm1` until the machine C layout of types is decided (asked of the author by Codex).
- C-DOOR-MEMBER-ACTUAL-UNTYPED: the pools cast the C members they return, pass to a machine call or read into a typed
  local.
- MACHINE-STATUS-CHANNEL: a declared exit of a machine function has no C ABI.
- PUBLICATION-FAILURE-UNSAID: `l2_pub_commit` fails without a located diagnostic for ordinary outputs.

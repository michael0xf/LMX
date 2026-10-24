# Slice 189: the temporary-frame store in L2, its header written by the L3 generator (S8.3, above the storage layer)

Opus, 2026-10-24, sole writer/build. The order (Codex, CODEX-OPUS-ROUTE185-20261024T085140Z) and the author's
instruction (CODEX-AUTHOR-CORE-CONTINUE-20261024T091641Z) as in slice 188. Codex reviewed Verified188 post factum and
found no defect (CODEX-OPUS-REVIEW188-20261024-5117AA87).

The stage is `build2/opus_fix189`, from Verified188's stage. Its inputs:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/lmx_scratch.lm2` (new) | `7F4F759E…` | `lmx_scratch.lm2.patch` |
| `tools/l2/build.lm2` (the recipe, in the repository) | `5D71E05E…` | the commit |

GNU patch gives the stage's bytes (`u0-same.out`: `SAME 1`). The generated files replace the hand-written ones:

| File | hand-written (Verified188) | generated |
| --- | --- | --- |
| `lmx_scratch.lm1` | `A28356B7…` | `FE32E6B1…` |
| `lmx_scratch.h.lm1` | `7B499B2F…` | `7B499B2F…`, the same bytes |
| `headers/l2src/lmx_scratch.lm1.h` | `A56DCB87…` | `A56DCB87…`, the same bytes |

## What changed

- `src/l2src/lmx_scratch.lm2`: the five functions of the hand-written module, in the same order, all exports: open,
  take, mark, rewind and close. The pool's acts (`lmx_pool_*`, `lmx_chunk_*`) are reached through the C door. Their
  pointer results are cast to their C types, and the C members read at a use (`s\at`, `s\used`, `chunk\next`,
  `s\cells\stride`) are cast to the type of the place or actual that takes them. A C call whose later actual calls is
  given that value in a typed local first: `issued`, the chunk's cell count, before `lmx_pool_take_n`
  (C-DOOR-ACTUALS-UNORDERED). Each local has its declared initial value.
- The module is translated without `--header` and declares its functions itself, as the arena's does. Its header,
  `lmx_scratch.h.lm1` (the answers `LMX_SCRATCH_*`, the records `LmxScratch` and `LmxScratchMark`, the prototypes the
  kernel calls), is written by the L3 generator: `decl_scratch`, the fourth header of `decls_write_all`, which writes
  its C header before every consumer. The header predefs the pools' header, which the pools' module step writes later,
  and `lmx_implements.h.lm1`; `bld_headers` translates their C headers again after them, as for every header.
- `bld_kernel_l2` names the module's exports and translates it last.

## Real runs
The runs are the tools' commands and direct invocations of the frontend; no probe script was written, and the
commands are kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `gen-189-01` | Verified188's frontend with the recipe's command | the stage's module, exit 0 |
| `rebuild-runtime-01` (`rt-01`) | Verified188's tool on the stage | `SUITE 6 rows, 0 failures` in 585 s; the C differs from Verified188's only in the module (lines 14144-14379; the lines before and after are byte-equal) |
| `rebuild-tool-01` (`tool-01`, the seed G0) | Verified188's tool; the stage's tools by Verified188's frontend, linked with `rt-01` | built in 576 s; its smoke `SUITE 6 rows, 0 failures` |
| `bootstrap-quick-01` (`boot-quick-01`) | G0 runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 854 s; the runtime's record shows the generator writing the header and its C header (`trace/runtime-record.txt` lines 22-28) and the recipe translating the module (lines 143-152) into `gen-189-01`'s bytes; the smoke 6/0; G1 and G2 built and working |
| `checks-01` | the bootstrap's tool: `same`, `exe-same` | G0, G1 and G2's L1 (`F1504614…`) and C (`AD67F8D0…`) `SAME 1`; G1 and G2 `EXE-SAME 1`; the bootstrap's `driver.c` (`AC8DFCAA…`), `driver.o` and `driver-observe.o` are `rt-01`'s bytes; the generated header and its C header are the hand-written ones' bytes (`SAME 1` twice), and the bootstrap's module `gen-189-01`'s |

Memory (`chain-memory.log`): cc1 at most 1 588 MB, the free commit at least 1.94 GiB while cc1 ran and 1.66 GiB
at its lowest (09:29:41, no cc1: a translation step of the bootstrap). Nothing else ran beside the chain but short
reads; the check of the author's const forms (`steps/witnesses/const-forms-20261024`) ran after the bootstrap ended.

## Evidence

`evidence-189.list` names 70 files; `evidence-189.sha256` holds their SHA-256, written by the tool's `manifest`
(`manifest/manifest-189.out`: `MANIFEST 70 files, 0 failed`; `sha256sum -c` checks all 70 OK). The packet's copies
have LF line ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the corpus replays, a mutant (the author: «Не увлекайтесь тестами»).
Whether the smoke's programs reach this module is not measured.

## OPEN

The L3+L2 self-build (plan section 8): 24 more kernel modules of the runtime's translation unit, the driver and both
translators are L1. Next: a translator slice for function-pointer locals' addresses (FNPTR-LOCAL-NO-ADDRESS, Codex's
route CODEX-OPUS-VALUE-OWNED-ROUTE-20261024-A), then the values module (`lmx_value_owned`).

# Slice 187: the owned character tables and the Arrays of references in L2 (S8.3, above the storage layer)

Opus, 2026-10-24, sole writer/build. The order (Codex, CODEX-OPUS-ROUTE185-20261024T085140Z): the next small kernel
modules by dependencies above the ported storage layer; the author (CODEX-AUTHOR-CORE-CONTINUE-20261024T091641Z):
«Пусть Opus продолжает перенос оставшегося ядра на L3 + L2 небольшими шагами через короткий bootstrap, не ожидая
ревью. Все вопросы — тебе. Не увлекайтесь тестами: цель — работающая самосборка». Codex reviewed Verified186 post
factum and found no defect (CODEX-OPUS-REVIEW186-20261024-7A6E7152).

The stage is `build2/opus_fix187`, from Verified186's stage. Its inputs:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/lmx_chars_owned.lm2` (new) | `BF5CEE52…` | `lmx_chars_owned.lm2.patch` |
| `src/l2src/lmx_array_ref_owned.lm2` (new) | `53EEE2AF…` | `lmx_array_ref_owned.lm2.patch` |
| `tools/l2/build.lm2` (the recipe, in the repository) | `ECD7FCAB…` | the commit |

GNU patch gives the stage's bytes (`u0-same.out`: `SAME 1` twice). The generated files replace the hand-written ones:

| File | hand-written (Verified186) | generated |
| --- | --- | --- |
| `lmx_chars_owned.lm1` | `9723C205…` | `6BA5D84A…` |
| `lmx_chars_owned.h.lm1` | `0DF5636C…` | `B455DD34…` |
| `lmx_array_ref_owned.lm1` | `9EA71123…` | `31437124…` |
| `lmx_array_ref_owned.h.lm1` | `97A2E01E…` | `4A27CAC9…` |

## What changed

- `src/l2src/lmx_chars_owned.lm2`: the two functions of the hand-written module (`lmx_chars_new_owned`,
  `lmx_char_cell_known`), in the same order, both exports. The L1's binding named `table` is `chars`: `table` is a word
  of the language (the first generation refused it: `runs/gen-187-01-first.out`).
- `src/l2src/lmx_array_ref_owned.lm2`: the five functions of the hand-written module, in the same order; four are
  exports, and `lmx_array_ref_new_physical_profiled` is the module's own, as before (the generator prototypes it at the
  module's top). The bindings named `profile` are `array_profile`; the descriptor's by-value `VoidArray` is written
  through its address, as `lmx_array_desc_new` does.
- Both are translated with `--header`: the build writes their L1 and headers in place of the hand-written ones. The
  prototypes keep their C types; the generated headers also include `<stddef.h>`, `<stdlib.h>` and predef
  `lmx_pool.h.lm1`, which the modules read.
- `bld_kernel_l2` names their exports and translates them after the interned table.

## Real runs

The runs are the tools' commands and direct invocations of the frontend and `bin/l1trans.exe`; no probe script was
written, and the commands are kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `gen-187-01` | Verified186's frontend with the recipe's commands; l1trans for the C headers | first refused (`table`), then (`gen-187-02.out`) the stage's two modules, headers and C headers, exit 0 |
| `rebuild-runtime-01` (`rt-01`) | Verified186's tool on the stage | `driver.c` differs from Verified186's only in the two modules' functions; `SUITE 6 rows, 0 failures` |
| `rebuild-tool-01` (`tool-01`, the seed G0) | Verified186's tool; the stage's tools by Verified186's frontend, linked with `rt-01` | built in 550 s; it hashes a file as the old tool does; its smoke `SUITE 6 rows, 0 failures` |
| `bootstrap-quick-01` (`boot-quick-01`) | G0 runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 502 s; the runtime's record shows the recipe translating both modules (`trace/runtime-record.txt` lines 88-111) into the same bytes; the smoke 6/0; G1 and G2 built and working. cc1 at most 1 596 MB, free commit at least 2.16 GiB |
| `checks-01` | the bootstrap's tool: `same`, `exe-same` | G0, G1 and G2's L1 (`912182AD…`) and C (`134A2EA5…`) `SAME 1`; G1 and G2 `EXE-SAME 1`; the bootstrap's `driver.c` (`FEA59115…`), `driver.o` and `driver-observe.o` are `rt-01`'s bytes |

Not measured: whether the smoke's programs reach these two modules. The programs do not call them; the runtime's
code does. No mutant was run (the author: «Не увлекайтесь тестами»).

## Evidence

`evidence-187.list` names 78 files; `evidence-187.sha256` holds their SHA-256, written by the tool's `manifest`
(`manifest/manifest-187.out`: `MANIFEST 78 files, 0 failed`); `sha256sum -c` checks all 78 OK. The packet's copies have LF line ends and no trailing blanks; the manifest hashes the
original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the corpus replays, a mutant.

## OPEN

The L3+L2 self-build (plan section 8): 27 more kernel modules of the runtime's translation unit, the driver and both
translators are L1. Next by the order: the arena's references (`lmx_arena_refs`, 14 exports) and the owned scalar
Arrays (`lmx_array_owned`, 7), whose headers hold prototypes only.

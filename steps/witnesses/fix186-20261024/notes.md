# Slice 186: the interned character table in L2 (S8.3, above the storage layer)

Opus, 2026-10-24, sole writer/build. Codex's order (CODEX-OPUS-ROUTE185-20261024T085140Z): «Выбирай (а): следующий
небольшой модуль ядра по зависимостям над перенесённым storage, S8.3 → values/graph → copy/merge/call → mail/Thread →
walker, как уже записано в плане §8.» The author (CODEX-AUTHOR-CORE-CONTINUE-20261024T091641Z): «Пусть Opus продолжает
перенос оставшегося ядра на L3 + L2 небольшими шагами через короткий bootstrap, не ожидая ревью. Все вопросы — тебе.
Не увлекайтесь тестами: цель — работающая самосборка».

The stage is `build2/opus_fix186`, from Verified185's stage. Its inputs:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/lmx_chars.lm2` (new) | `9E623142…` | `lmx_chars.lm2.patch` |
| `src/l2src/lmx_range.lm2`, `lmx_pool.lm2`, `lmx_arena_blocks.lm2`, `lmx_arena.lm2` (comments only) | in the manifest | `<name>.patch` |
| `tools/l2/build.lm2` (the recipe, in the repository) | `85AC6CA9…` | the commit |

GNU patch applied to Verified185's files gives the stage's bytes (`u0-same.out`: `SAME 1` five times; the commands in
`u0-same.command`). The generated `lmx_chars.lm1` (`9E7ED319…`) and `lmx_chars.h.lm1` (`286BFC28…`) replace the
hand-written ones (`FEBFD6D9…`, `AC694DD6…`).

## What changed

- `src/l2src/lmx_chars.lm2` is the maintained source of the interned character table: its three functions
  (`lmx_chars_init`, `lmx_char_cell`, `lmx_char_value`) are those of the hand-written `lmx_chars.lm1`, in the same
  order, with its comments; all three are exports. The arena's acts and the chunk's are the kernel's C functions,
  called through the C door: their pointer results are cast to their C types before a comparison
  (C-DOOR-POINTER-RESULT-INT-OPERAND), and a C member is cast where it is passed (C-DOOR-MEMBER-ACTUAL-UNTYPED).
- It is translated with `--header`: the build writes `lmx_chars.h.lm1` in place of the hand-written header. The
  prototypes have the same C types; the generated header also predefs `lmx_pool.h.lm1`, which the module reads.
- `bld_kernel_l2` names the three exports and translates the module last, above the storage layer.
- The comments of the four ported storage modules no longer say their records stay hand-written «until the machine
  C layout of types is decided»: those headers are the L3 generator's (Verified185). The generated L1 carries no
  module comment, so no output changes.

## Real runs

The runs are the tools' commands and direct invocations of the frontend and `bin/l1trans.exe`; no probe script was
written, and the commands are kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `gen-chars-01`, `gen-chars-header-01` | Verified185's frontend with the recipe's command for the module; l1trans for its C header | the stage's `lmx_chars.lm1`, `lmx_chars.h.lm1` and `lmx_chars.lm1.h`, exit 0 |
| `rebuild-runtime-01` (`rt-01`) | Verified185's tool on the stage | the runtime with the generated module: `driver.c` differs from Verified185's only in the module's functions (lines 13082-13158); `SUITE 6 rows, 0 failures` |
| mutant `rt-mut01` (`build2/opus_mut186`) | `lmx_chars_init` refuses every arena (`mutants/mutant.diff`), regenerated the same way | `SUITE 6 rows, 20 failures`: every program's run exits 1, so the smoke runs through the module |
| `rebuild-tool-01` (`tool-01`, the seed G0) | Verified185's tool; the stage's tools (the recipe names the module) by Verified185's frontend, linked with `rt-01` | built in 553 s, cc1 at most 1 578 MB, free commit at least 1.84 GiB (2.04 while cc1 ran); it hashes a file as the old tool does; its smoke `SUITE 6 rows, 0 failures` |
| `bootstrap-quick-01` (`boot-quick-01`) | G0 runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 472 s: the frontend; the runtime, whose record shows the recipe translating `lmx_chars.lm2` (`trace/runtime-record.txt` lines 76-87: the module and header it writes are `gen-chars-01`'s bytes, unchanged); `HEADERS 51 regenerated`; the smoke `SUITE 6 rows, 0 failures`; G1 and G2 built and working. cc1 at most 1 555 MB, free commit at least 1.9 GiB (2.22 while cc1 ran) |
| `checks-01` | the bootstrap's tool: `same`, `exe-same` (`checks/commands.txt`) | G0, G1 and G2's L1 (`B71A5BB4…`) and C (`4577AC0C…`) `SAME 1`; G1 and G2 `EXE-SAME 1`; the bootstrap's `driver.c` (`619E24F3…`), `driver.o` and `driver-observe.o` are `rt-01`'s bytes |

## Evidence

`evidence-186.list` names 93 files: the stage's new and changed sources and their Verified185 parents, the generated
module, header and C header and the hand-written ones they replace, the recipe and the tools sources, the patches and
their replay, the generation, the runtime build, the mutant, the seed build, the bootstrap's records, products and
memory log, and the checks. `evidence-186.sha256` holds their SHA-256, written by the tool's `manifest`
(`manifest/manifest-186.out`: `MANIFEST 93 files, 0 failed`); `sha256sum -c` checks all 93 OK. The packet's copies have LF line ends and no trailing
blanks; the manifest hashes the original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the full corpus replay and a targeted replay (the author: «Не увлекайтесь
тестами»).

## OPEN

The L3+L2 self-build (plan section 8): the frontend, `bin/l1trans.exe`, the driver and 29 more kernel modules of the
runtime's translation unit are L1. Next by the order: the owned char tables and reference arrays
(`lmx_chars_owned`, `lmx_array_ref_owned`), whose headers hold prototypes only.

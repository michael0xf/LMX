# Slice 194: the physical mark and sweep of the graph in L2 (S8.3, the graph), with the collection's header L3 code of the recipe writes

Opus, 2026-10-24, sole writer/build. The order (Codex, CODEX-OPUS-ROUTE185-20261024T085140Z): above the storage layer,
values and the graph. Codex found no defect in Verified193 (CODEX-OPUS-REVIEW193-20261024-3C125717) and set this route
(CODEX-OPUS-ROUTE194-AND-CONST-GROUP-20261024-A): «Продолжай194 с lmx_gc_graph»; `lmx_gc.h.lm1` is generated with
ordinary L3 strings of L1 as the recipe's sixth header, in the same bytes; the old stage copies are removed before
generation, with no fallback to the hand-written header; the bodies of `lmx_gc` and mail/Thread stay L1.

The stage is `build2/opus_fix194`, from Verified193's stage. Its inputs:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/lmx_gc_graph.lm2` (new) | `1DA4D344…` | `lmx_gc_graph.lm2.patch` |
| `tools/build.lm2` (the recipe, in the repository) | `841AC4A5…` (Verified193: `A5CA54F2…`) | the commit |

GNU patch gives the stage's bytes (`u0-same.out`: `SAME 1`). The translator does not change. The generated files replace
the hand-written ones:

| File | hand-written (Verified193) | generated |
| --- | --- | --- |
| `lmx_gc_graph.lm1` | `E205899F…` | `FF809232…` (the module) |
| `lmx_gc.h.lm1` | `3640F547…` | `3640F547…` (L3 code of the recipe, the same bytes) |
| `lmx_gc.lm1.h` | `77DD5D17…` | `77DD5D17…` (l1trans of it) |

## What changed

- `src/l2src/lmx_gc_graph.lm2`: the eleven functions of the hand-written module, in the same order; five are the
  exports the kernel calls (`lmx_gc_note`, `lmx_gc_cells`, `lmx_gc_mark_value`, `lmx_gc_mark_pool`, `lmx_gc_sweep`),
  six are the module's own. The arena's, pools', implements' and C library's acts are reached through the C door; the C
  members read at a use are cast to their C types. The hand-written local `node` (a block of the arena's list) is
  `block`: `node` is a word of the language (`gen-194-01`).
- A block is disposed through its disposer, a C function pointer the record holds: the module reads it into a
  function-pointer local declared with its value (`c.LmxArenaBlockDisposer: disposer block\dispose`) and calls the
  local. A function-pointer member is not a call head (`gen-194-04`). The disposer's type is declared in
  `lmx_arena_blocks.h.lm1`, which the translator does not reach through `lmx_arena.h.lm1`'s bare nested predef
  (PREDEF-BARE-NESTED-PATH-FROM-CWD, `gen-194-02`, `gen-194-03`); the module predefs it directly
  (`predef: "l2src/lmx_arena_blocks.h.lm1"`), as the block list's own module does.
- The recipe: `decl_gc` writes `lmx_gc.h.lm1` -- the collection's answers (`LMX_GC_OK`, `LMX_GC_INVALID`,
  `LMX_GC_PARTIAL`), its depth (`LMX_GC_DEPTH`) and the prototypes of the physical mark and sweep and of the Thread
  collector (`lmx_gc_mark`, `lmx_gc_collect`, still L1 in `lmx_gc.lm1`) -- as L1 text, the sixth header of
  `decls_write_all` (kind 5 of `decl_write`), whose stage copy and C header are removed first, like the other five.
  `bld_kernel_l2` translates the module last, without `--header`: it declares its functions itself, and the kernel
  reads the prototypes from that header.

## Real runs

The tool is Verified193's `build2/opus_fix193/boot-quick-01/lmxtool.exe`, with its frontend. The runs are its commands
and direct invocations of the frontends; no probe script was written, and the commands are kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `gen-194-01` … `gen-194-06` (`gen/`) | Verified193's frontend with the recipe's command | 01: `node` refused (a word of the language); 02, 03: the disposer local refused «unresolved name»; 04: the member called directly refused; 05: exit 0, the module the recipe then writes; 06: the same, timed (300 s), with three gdb samples |
| `rebuild-runtime-01` (`rt-01`) | Verified193's tool and frontend, the generated module in the stage | `SUITE 6 rows, 0 failures` in 837 s; the C differs from Verified193's only in the module (lines 10181-10793; the lines before and after are byte-equal, `checks/runtime-diff.out`) |
| `rebuild-tool-01` (`tool-01`, the seed G0) | Verified193's tool; the stage's tools (the new recipe) linked with `rt-01` | built in 605 s; it runs the smoke list (`REBUILD tool 0 failures`) |
| `bootstrap-quick-01` (`boot-quick-01`) | G0 runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 2 298 s (Verified193: 1 933 s; the module's step took 295 s, from its log's creation to its L1's publication); the runtime's record shows the generator writing the header (`trace/runtime-record.txt` lines 36-42) and the recipe translating the module last (lines 189-198); the smoke 6/0; G1 and G2 built and working |
| `checks-01` (`checks/`) | the bootstrap's tool: `same`, `exe-same` | G0, G1 and G2's L1 (`0DB48C33…`) and C (`0782622E…`) `SAME 1`; G1 and G2 `EXE-SAME 1`; the bootstrap's `driver.c` (`26F4E99A…`), `driver.o` and `driver-observe.o` are `rt-01`'s bytes; the module is `gen-194-05`'s; the header and its C header are the hand-written bytes |

The translation of the module by the recipe's command takes 300 s (`gen-194-06`): every query of a predef header parses
it again (PREDEF-HEADER-REPARSED-PER-QUERY; the three gdb samples, `gen/gdb-sample.out`, are all in `lm_p0_parse_bytes`
under `l2_snap_parse`). Whether the smoke reaches the module is not measured (no mutant). Memory (`chain-memory.log`,
its watchdog `chain-memory.command`): cc1 at most 1 610 MB; the free commit at least 1.93 GiB while cc1 ran (1.81 GiB
overall); nothing was stopped. Nothing else ran beside the chain.

## Evidence

`evidence-194.list` names 87 files; `evidence-194.sha256` holds their SHA-256, written by the tool's `manifest`
(`manifest/manifest-194.out`: `MANIFEST 87 files, 0 failed`; `sha256sum -c` checks all 87 OK). The packet's copies
have LF line ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the corpus replays, a mutant (the author: «Не увлекайтесь тестами»).

## OPEN

The L3+L2 self-build (plan section 8): 21 more kernel modules of the runtime's translation unit, the driver and both
translators are L1. The translator's predef readers parse a header on every query (PREDEF-HEADER-REPARSED-PER-QUERY)
and do not resolve a bare nested predef beside its includer (PREDEF-BARE-NESTED-PATH-FROM-CWD).

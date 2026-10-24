# Slice 183: the arena's manager in L2 (S8.3, fourth step)

Opus, 2026-10-24, sole writer/build. The slice follows Codex's direction on Verified181, «Продолжай к arena_blocks и
arena малыми шагами» (CODEX-OPUS-ROUTE181-20261024T040603Z), and the author's clarification of 2026-10-24
(CODEX-AUTHOR-L3-DECLARATIONS-20261024T054617Z, [verbatim](../../../LMX_blog/2026-10-24.md)): «объявления арены и
пулов генерировать на L3 как строки L1, без нового механизма в L2». This slice ports the arena's functions; their
declarations stay hand-written, and the L3 code that writes them as L1 text is the next step (source closure OPEN).

Verified183 is a bounded slice: the runtime was built by the runner with Verified182's final frontend, its smoke ran,
a targeted corpus replay and a runtime mutant ran. The translator does not change. The tool was NOT compiled with the
new recipe and the quick bootstrap was NOT run, for memory. Verified183 does not close S8.3 or §8 and is not the L3+L2
self-build.

The stage is `build2/opus_fix183`, a copy of Verified182's stage sources (`build2/opus_fix182`).
- One input changes: the new `src/l2src/lmx_arena.lm2`. Its -U0 delta is here, and GNU patch gives the stage's bytes
  (`u0-same.out`: `SAME 1`; the commands in `u0-same.command`).
- `src/l2src/lmx_arena.lm1` is now the build's product: Verified182's frontend `fe-06` writes it from `lmx_arena.lm2`
  (`gen-arena-01`) and regenerates it byte for byte from the final source (`regen-03`). The hand-written module is
  gone; its header `lmx_arena.h.lm1` does not change.
- The recipe (`tools/l2/build.lm2`, copied into the stage's `tools`) changes in the repository: `bld_kernel_l2` builds
  the manager after the block list.

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/lmx_arena.lm2` | `CDEF1FF41935F723A6482E80D3CC7EC4892F2705CD83677F37E4484EC9C40252` | `lmx_arena.lm2.patch` (new) |

| Generated file | Verified183 | Verified182 |
| --- | --- | --- |
| `lmx_arena.lm1` | `F27D55F4533F7A2E430285773330A3E5D9E73B5E98401271ABC00917ECF36660` | hand-written `97FC2D1363908D83A99FDD77580CF4D7F5B23297DC21B91CFBDAE86EA57F7E3C` |

The other generated files (the block list, the pools and their header, the index, the list and its header) are
Verified182's; `regen-01` regenerates all seven generated files byte for byte.

## What changed

### The arena's manager is a machine module of L2 (S8.3, fourth step)

`src/l2src/lmx_arena.lm2` is the maintained source of the arena's manager: the 35 functions of the hand-written
`lmx_arena.lm1` in their order, 34 exports (the `--machine` names of `bld_kernel_l2`); its one internal function,
`lmx_arena_rehome_primitive_owners`, is internal in the L1 as well. Translated without a header, it declares its
functions itself, as the index and the block list do: the arena's record `LmxArena`, the rows of its index, the records
of its `implements` table and the prototypes the kernel calls stay in `lmx_arena.h.lm1`, and the kernel calls the
manager through those prototypes as before. The pools', the block list's and the index's acts and the graph's
`lmx_graph_node_in` are reached through the C door; the block list's and the index's generated L1 are predef'd, and
their modules come before the manager in the kernel's translation unit.

Spellings that differ from the L1:
- the formals named `profile` and `node` (words of the language) are `pool_profile` and `block`;
- addresses are compared as `size_t`, as the index's module does: a system header's typedef names no L2 local
  (`c.uintptr_t: lo 0` is an unresolved name), while the L1 used `uintptr_t`;
- 18 C members are cast where they are returned, passed to a machine call or read into a typed local (C members have
  no L2 type, C-DOOR-MEMBER-ACTUAL-UNTYPED), and a by-value member (the arena's index, a contract's facts) is reached
  through its address and a cast;
- `lmx_arena_pointer_cells_profiled` takes its access callbacks as formals of the ABI's function-pointer types and calls
  `write(...)` through them (Verified182).

The generated module is 1500 lines; the hand-written one was 772. Comments do not reach the generated L1: two
comment-only edits of the source (`regen-02`, `regen-03`) leave its bytes unchanged.

## Real runs

The tool is Verified176's `build2/opus_fix176/tool-01/lmxtool-tool.exe`. The runs are its commands and direct
invocations of the frontend, `bin/l1trans.exe` and the stage's gcc; no probe script was written, and the commands are
kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `gen-arena-01` | `fe-06`, the stage's source before its two comment edits | exit 0; writes `src/l2src/lmx_arena.lm1` |
| `rebuild-runtime-01` (`rt-01`) | the generated manager, the other modules Verified182's; smoke with `fe-06` | `SUITE 6 rows, 0 failures` |
| `regen-01` | `fe-06` over copies of the five modules' sources (the index's read in place) | `SAME 1` seven times (`regen-01.out`); no `.tmp` or `.bak` left |
| `regen-02` | `fe-06` over a copy of the source after the first comment edit | `SAME 1` |
| `regen-03` | `fe-06` over a copy of the final source | `SAME 1` |

Final builds: `rt-01/driver.o` `CD74DA26…` and `rt-01/driver-observe.o` `49E7073A…`, with Verified182's frontend
`fe-06/l2trans.exe` `59576AB8…`. `rt-01`'s compile log has Verified182's warnings and one more of the same kind: the
discarded result of `lmx_arena_array_drop(arena, pool)`, a statement of `lmx_arena_drop`, is held in a local nothing
reads.

### The mutant

| Mutant (`build2/opus_mut183`) | Change | Smoke |
| --- | --- | --- |
| `rt-mutA2` | `lmx_arena_take_n_profiled` refuses a request whose stride equals its array's (`mutants/mutA.patch`), regenerated by `fe-06` | `SUITE 6 rows, 20 failures`: every launch of the five runtime rows, both modes and both roots, exits 1; the translation-only row passes |

The mutant's C differs from `rt-01`'s in that one comparison (`mutants/driver-c.diff`). Its first build, `rt-mutA`,
stopped at the kernel's C headers: the mutant stage's copy had left out the stage's `headers`, where the step writes
them; `rt-mutA2` is the same command after that directory was copied. The mutant stage's source was restored and
checked equal to the final stage's (`M/src` equals `S/src`).

### Targeted corpus replay

`replay183-01` (`fe-06` + `rt-01`) runs Verified178's list (276 fixtures, both modes, 1121 checks): PASS 750, and every
line of its output equals Verified182's `replay182-01` (stage paths and runtime labels normalized). Its `failures.tsv`
holds the same 370 inherited failures. The L1 and C of every row are byte-equal to `replay182-01`'s: the tool's
`manifest` hashed the same 576 relative paths and its `same` compared that manifest with Verified182's (`l1same/`,
`SAME 1`).

### The tools with the new recipe

`tooltrans-01`: the stage's tools sources, as `bld_self` lists them, translated by `fe-06` (L2 → L1, exit 0, 161 s,
638 610 lines) and by `bin/l1trans.exe` (L1 → C, exit 0, 20 s, 811 403 lines). The tool was not compiled.

## Evidence

`evidence-183.list` names 91 files: the stage's input and the hand-written module it replaces, the generated modules,
the replayed patch, the build and its runs, the replays compared and their manifests, the mutant and the tools'
translation. `evidence-183.sha256` holds their SHA-256, written by the tool's `manifest` (`runs/manifest-01`:
`MANIFEST 91 files, 0 failed`); `sha256sum -c` checks all 91 OK. The packet's copies have LF line ends and no
trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run (an explicit OPEN checkpoint)

- The tool compiled with the new recipe, the runtime built through it, and the quick bootstrap: memory, as in
  Verified178 to Verified182. The tool's L1 (`tooltrans-01`) is 638 610 lines, of which one function,
  `l2_program_build`, is 336 639 (GENERATED-CODE-SIZE).
- LATER: the kernel gate, the gate, `bootstrap full`, the full corpus replay, broad tests of the arena.

## OPEN

- The storage layer's declarations: the records and prototypes in `lmx.h.lm1`, `lmx_arena.h.lm1` and
  `lmx_arena_blocks.h.lm1` are still hand-written; L3 code of the build is to write them as L1 text, with no
  hand-written header left as a fallback (the author's direction, CODEX-AUTHOR-L3-HEADER-REVIEW-20261024T062211Z).
- C-DOOR-ACTUALS-UNORDERED (rest), C-DOOR-MEMBER-ACTUAL-UNTYPED, FNPTR-LOCAL-NO-ADDRESS, MACHINE-STATUS-CHANNEL,
  PUBLICATION-FAILURE-UNSAID.

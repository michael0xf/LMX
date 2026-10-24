# Slice 188: the arena's references and the owned scalar Arrays in L2 (S8.3, above the storage layer)

Opus, 2026-10-24, sole writer/build. The order (Codex, CODEX-OPUS-ROUTE185-20261024T085140Z) and the author's
instruction (CODEX-AUTHOR-CORE-CONTINUE-20261024T091641Z) as in slice 187. Codex reviewed Verified187 post factum and
found no defect (CODEX-OPUS-REVIEW187-20261024-811B4063).

The stage is `build2/opus_fix188`, from Verified187's stage. Its inputs:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/lmx_arena_refs.lm2` (new) | `5DDB5D2E…` | `lmx_arena_refs.lm2.patch` |
| `src/l2src/lmx_array_owned.lm2` (new) | `63BD4D08…` | `lmx_array_owned.lm2.patch` |
| `tools/l2/build.lm2` (the recipe, in the repository) | `64A47804…` | the commit |

GNU patch gives the stage's bytes (`u0-same.out`: `SAME 1` twice). The generated files replace the hand-written ones:
| File | hand-written (Verified187) | generated |
| --- | --- | --- |
| `lmx_arena_refs.lm1` | `A797D1E9…` | `A8492582…` |
| `lmx_arena_refs.h.lm1` | `C7E4133F…` | `DF4EDE16…` |
| `lmx_array_owned.lm1` | `9238EEC7…` | `135050E2…` |
| `lmx_array_owned.h.lm1` | `301F5E76…` | `64A4CACA…` |

## What changed

- `src/l2src/lmx_arena_refs.lm2`: the fourteen functions of the hand-written module, in the same order, all exports:
  a graph header selected by its pool, a backing cell's address, a field's and an element's cell and value, the
  contiguous binding of fields, the references' stores, and opening a Structure's child-pointer array. The bindings
  named `node` and `profile` (words of the language) are `graph_node` and `refs_profile`. A Structure's or an
  Array's by-value `VoidArray` is read and written through its address (`va: @ x\array`, then `va\data`, `va\size`).
  The pointer results of the index's and the arrays' acts are cast to their C types; a C call whose later actual
  calls is given that value in a typed local first (C-DOOR-ACTUALS-UNORDERED).
- `src/l2src/lmx_array_owned.lm2`: the eight functions of the hand-written module, in the same order; seven are
  exports, and `lmx_array_new_physical_profiled` is the module's own. Its two function-pointer formals take the
  callbacks' C types (`c.LmxPointerCellRead`, `c.LmxPointerCellWrite`), as the arena's module does. The element size
  of an Array of `unsigned long` is `c.sizeof` of a `ulong` local, as the L1 had it: `ulong` is an existing machine
  type word of L2 (`l2_ns_field_word`, the scalar contract `ty36`), which l1trans spells `unsigned long`
  (`l1src/l1trans.lm1:743-744`); L2 section 17 gives the machine types C99's representation but does not list their
  spellings (Codex, CODEX-OPUS-REVIEW187-20261024-811B4063: a gap of the description, not of the mechanism).
- Both are translated with `--header`, the references before the Arrays, which read their header. The prototypes
  keep their C types (`gen-188-01`: the names, return and parameter types of every prototype equal the hand-written
  headers').
- `bld_kernel_l2` names their exports and translates them after the Arrays of references.

## Real runs
The runs are the tools' commands and direct invocations of the frontend and `bin/l1trans.exe`; no probe script was
written, and the commands are kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `gen-188-01` | Verified187's frontend with the recipe's commands; l1trans for the C headers | the stage's two modules, headers and C headers, exit 0 |
| `rebuild-runtime-01` (`rt-01`) | Verified187's tool on the stage | the C differs from Verified187's only in the two modules (the references' functions at lines 3356-3936 and the Arrays' module from its first line); `SUITE 6 rows, 0 failures` |
| `rebuild-tool-01` (`tool-01`, the seed G0) | Verified187's tool; the stage's tools by Verified187's frontend, linked with `rt-01` | built in 548 s; it hashes a file as the old tool does; its smoke `SUITE 6 rows, 0 failures` |
| `bootstrap-quick-01` (`boot-quick-01`) | G0 runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 551 s; the runtime's record shows the recipe translating both modules (`trace/runtime-record.txt` lines 112-135) into the same bytes; the smoke 6/0; G1 and G2 built and working |
| `checks-01` | the bootstrap's tool: `same`, `exe-same` | G0, G1 and G2's L1 (`517E0E64…`) and C (`D7EF8D10…`) `SAME 1`; G1 and G2 `EXE-SAME 1`; the bootstrap's `driver.c` (`FFCDCC18…`), `driver.o` and `driver-observe.o` are `rt-01`'s bytes |

Memory (`chain-memory.log`): cc1 at most 1 549 MB, free commit at least 2.57 GiB while cc1 ran. At 07:57:39 the
free commit fell to 0.51 GiB for about 15 s with no cc1 running: the runtime's translation of the pools ran while
direct frontend translations of the next slice's drafts ran beside it. They are not run beside a build any more.

## Evidence

`evidence-188.list` names 77 files; `evidence-188.sha256` holds their SHA-256, written by the tool's `manifest`
(`manifest/manifest-188.out`: `MANIFEST 77 files, 0 failed`; `sha256sum -c` checks all 77 OK). The packet's copies
have LF line ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the corpus replays, a mutant (the author: «Не увлекайтесь тестами»).
Whether the smoke's programs reach these two modules is not measured: the runtime's code calls them.

## OPEN

The L3+L2 self-build (plan section 8): 25 more kernel modules of the runtime's translation unit, the driver and both
translators are L1. Next: the temporary-frame store (`lmx_scratch`: its header's codes and records by the L3
generator, the module without a header), then a translator slice for function-pointer locals' addresses
(FNPTR-LOCAL-NO-ADDRESS, Codex's route CODEX-OPUS-VALUE-OWNED-ROUTE-20261024-A) before the values module
(`lmx_value_owned`).

# Slice 193: the source names of the graph in L2 (S8.3, the graph), with the header L3 code of the recipe writes

Opus, 2026-10-24, sole writer/build. The order (Codex, CODEX-OPUS-ROUTE185-20261024T085140Z): above the storage layer,
values and the graph. Codex found no defect in Verified192 (CODEX-OPUS-REVIEW192-20261024-7223180D) and took this route
as the author's: «Маршрут193 с заголовком source_names из обычных L3-строк L1 соответствует решению автора». The
module's `const char *` formals are written in the author's form (CODEX-AUTHOR-CONST-FORMS-20261024-A; Codex,
CODEX-OPUS-SOURCE-NAMES-CONST-20261024-A: `const` is not dropped from the interface).

The stage is `build2/opus_fix193`, from Verified192's stage. Its inputs:

| Input | SHA-256 | Delta |
| --- | --- | --- |
| `src/l2src/lmx_source_names.lm2` (new) | `939835D2…` | `lmx_source_names.lm2.patch` |
| `tools/build.lm2` (the recipe, in the repository) | `A5CA54F2…` (Verified192: `5E53F5FA…`) | the commit |

GNU patch gives the stage's bytes (`u0-same.out`: `SAME 1`). The translator does not change. The generated files replace
the hand-written ones:

| File | hand-written (Verified192) | generated |
| --- | --- | --- |
| `lmx_source_names.lm1` | `3171044C…` | `F2ED04BF…` (the module) |
| `lmx_source_names.h.lm1` | `640E3D16…` | `640E3D16…` (L3 code of the recipe, the same bytes) |
| `lmx_source_names.lm1.h` | `89D269A6…` | `89D269A6…` (l1trans of it) |

## What changed

- `src/l2src/lmx_source_names.lm2`: the eight functions of the hand-written module, in the same order; seven are the
  exports the kernel calls, and `lmx_source_name_local` is the module's own. The arena's, pools', interned table's and
  C library's acts are reached through the C door; their pointer results and the C members read at a use are cast to
  their C types. The row's by-value `VoidArray` is read and written through its address held in a typed local
  (`va: @ row\text`; `spelling: @ row\text` before `return: spelling`). Addresses are compared as `size_t`, as the
  arena's module does.
- The formal `text` is `const: (@: text char)`, the author's form 2 with its body in parentheses: in a formal list on
  one line `;` ends only the innermost frame, so without them the next formal is the const frame's second field and
  the signature is refused (`const/`); the parenthesized form gives `const: @(char l2_p2_2_text)` and the same C
  prototype as the hand-written header. The formal `length` (a word of the language, a receiver) is `text_length`.
- The recipe: `decl_source_names` writes `lmx_source_names.h.lm1` -- the row record `LmxSourceName` and the seven
  prototypes -- as L1 text, the fifth header of `decls_write_all` (kind 4 of `decl_write`), whose stage copy and C
  header are removed first, like the other four. `bld_kernel_l2` translates the module last, without `--header`: it
  declares its functions itself, and the kernel reads the prototypes from that header.

## Real runs

The tool is Verified192's `build2/opus_fix192/boot-quick-01/lmxtool.exe`, with its frontend. The runs are its commands
and direct invocations of the frontends; no probe script was written, and the commands are kept as text.

| Run | Inputs | Result |
| --- | --- | --- |
| `gen-193-01` … `gen-193-04` (`gen/`) | Verified192's frontend with the recipe's command | 01: the const formal refused; 02 and 03: `return: @ row\text` refused «assignment value has unknown type»; 04: exit 0, the module the recipe then writes |
| `const-shapes-01` … `03` (`const/`) | the two forms as a formal among others | last or alone: exit 0; followed by another formal: refused; with its body in parentheses: exit 0, the right signature |
| `rebuild-runtime-01` (`rt-01`) | Verified192's tool and frontend, the generated module in the stage | `SUITE 6 rows, 0 failures` in 761 s; the C differs from Verified192's only in the module (lines 19197-19697; the lines before and after are byte-equal, `checks/runtime-diff.out`) |
| `rebuild-tool-01` (`tool-01`, the seed G0) | Verified192's tool; the stage's tools (the new recipe) linked with `rt-01` | built in 601 s; it runs the smoke list (`REBUILD tool 0 failures`) |
| `bootstrap-quick-01` (`boot-quick-01`) | G0 runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 933 s; the runtime's record shows the generator writing the header (`trace/runtime-record.txt` lines 29-35) and the recipe translating the module (lines 172-180); the smoke 6/0; G1 and G2 built and working |
| `checks-01` (`checks/`) | the bootstrap's tool: `same`, `exe-same` | G0, G1 and G2's L1 (`9862C4AF…`) and C (`DC66BBC3…`) `SAME 1`; G1 and G2 `EXE-SAME 1`; the bootstrap's `driver.c` (`620BD11A…`), `driver.o` and `driver-observe.o` are `rt-01`'s bytes; the module is `gen-193-04`'s; the header and its C header are the hand-written bytes |

Whether the smoke reaches the module is not measured (no mutant). Memory (`chain-memory.log`): cc1 at most 1 615 MB;
the free commit at least 1.29 GiB, while cc1 ran. Nothing else ran beside the chain.

## Evidence

`evidence-193.list` names 98 files; `evidence-193.sha256` holds their SHA-256, written by the tool's `manifest`
(`manifest/manifest-193.out`: `MANIFEST 98 files, 0 failed`; `sha256sum -c` checks all 98 OK). The packet's copies
have LF line ends and no trailing blanks; the manifest hashes the original bytes in `build2`.

## Not run

The kernel gate, the gate, `bootstrap full`, the corpus replays, a mutant (the author: «Не увлекайтесь тестами»).

## OPEN

The L3+L2 self-build (plan section 8): 22 more kernel modules of the runtime's translation unit, the driver and both
translators are L1. Next in the graph: the physical mark and sweep (`lmx_gc_graph`), whose prototypes are in
`lmx_gc.h.lm1` beside the Thread collector's (`lmx_gc`).

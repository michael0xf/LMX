# Slice 185: the storage layer's declarations written by L3 code of the recipe; the quick bootstrap with them

Opus, 2026-10-24, sole writer/build. The author's route (LMX_blog/2026-10-24.md,
CODEX-AUTHOR-L3-DECLARATIONS-20261024T054617Z): «объявления арены и пулов генерировать на L3 как строки L1, без нового
механизма в L2». The author's order relayed by Codex (CODEX-AUTHOR-L3-GENERATOR-NOW-20261024T073829Z): «Проверь,
собрался ли новый инструмент. Если да, пусть Opus сразу делает L3-генератор объявлений и продолжает к самосборке
через короткий bootstrap, без ожидания ревью.» Codex on the scope (CODEX-OPUS-HEADER-SCOPE184-20261024T074034Z):
«печатай ВЕСЬ lmx.h.lm1 тем же обычным L3-кодом генератора. Выносить записи пулов в отдельный заголовок сейчас не
нужно.» The review the author asked of Codex (CODEX-AUTHOR-L3-HEADER-REVIEW-20261024T062211Z): «Когда Opus сделает
генератор, проверь сам, что сборка использует сгенерированные на L3 объявления, а старые рукописные L1-заголовки не
остались запасным маршрутом и L2 ради этого не расширяли.»

## What changed

One file, `tools/l2/build.lm2` (the recipe, an existing part of the tool):
- `decl_lmx`, `decl_arena_blocks`, `decl_arena` (lines 711-798): ordinary L3 code; each writes the whole text of one
  header -- `l2src/lmx.h.lm1`, `l2src/lmx_arena_blocks.h.lm1`, `l2src/lmx_arena.h.lm1` -- with `c.fputs` of string
  literals (21, 2 and 13 blocks of at most 24 lines). The literals are the headers' maintained source; the files
  the build writes are output, and the build reads or copies no older header.
- `decl_write` (802-816) opens one header "wb", writes it whole and closes it.
- `decls_write_all` (828-870) removes the three headers of the stage (`STAGE/src/l2src`) and their C headers
  (`STAGE/headers/l2src/<name>.lm1.h`) first; then, in the order of their predefs (`lmx_arena.h.lm1` predefs the other
  two), it writes each header, notes its SHA-256 in the runtime's record and translates its C header with
  `bin/l1trans.exe` as a recorded step (`decls-<name>.log`). A header or C header that cannot be produced is
  removed and the runtime's build stops (`bld_runtime` returns 5): no consumer runs.
- `bld_kernel_l2` calls it first (line 893), before the machine modules, `bld_headers`, the driver and every
  program; its comment no longer says the prototypes stay hand-written «until the machine C layout of types is
  decided» (Codex, CODEX-OPUS-ROUTE183-20261024T064656Z).

No L2 form, no translator, no kernel source, no runner and no test changes. The headers' names, their predefs and
the consumers' imports are the bytes they were: the generated files are Verified184's hand-written bytes.

The first attempt (`rebuild-tool-g0`) put the generator into a new part, `tools/l2/decls.lm2`, with `bld_self`
naming it. The running tool builds a tool from the parts its own compiled `bld_self` names, so the seed build refused
the recipe's call (`tool-g0-lmxtool.L2.log`: `build.lm2:729:9: unknown method`, `frame=decls_write_all`). The code
moved into the existing part.

## Real runs

The stage is `build2/opus_fix185`, from Verified184's stage (`src`, `tests`, `tools`, `headers`); its tools sources
are the published ones. The runs are the tool's commands; no probe script was written, and the commands are kept as
text.

| Run | Inputs | Result |
| --- | --- | --- |
| `rebuild-tool-g0` | Verified184's tool `tool-01`, the stage's tools with `decls.lm2` as a new part | refused at step 1 (L2): `unknown method`, `decls_write_all` |
| `rebuild-tool-g0b` (`tool-g0b`, the seed G0) | the same tool; the stage's tools (the generator in `build.lm2`) by Verified184's frontend `fe-03`, linked with Verified183's runtime `rt-01` | built in 574 s; cc1 at most 1 483 MB, free commit at least 2.23 GiB (2.59 while cc1 ran); the tool hashes a file as the old one does; its smoke: `SUITE 6 rows, 0 failures` |
| `headers-before-01` | the three names, `.h.lm1` and `.lm1.h`, in every directory the build looks them up in (`analysis/headers-commands.txt`) | in the stage: Verified184's bytes; in the repository root's `l2src`: the older `.h.lm1` (below); nowhere else |
| `headers-removed-01`, `headers-before-02` | the stage's three `.h.lm1` and three `.lm1.h` removed before the bootstrap | none in the stage; only the repository root's three `.h.lm1` |
| `bootstrap-quick-01` (`boot-quick-01`) | G0 runs `bootstrap quick` on the stage | `BOOTSTRAP quick 0 failures` in 1 738 s: the frontend; the runtime (the generator, the five machine modules, `HEADERS 51 regenerated`, the driver); the smoke `SUITE 6 rows, 0 failures`; G1 built and hashing a file as G0 does; G2 built by G1 and hashing too. cc1 at most 1 488 MB, free commit at least 2.0 GiB (2.25 while cc1 ran) |
| `checks-01` | the bootstrap's tool (G2): `same`, `exe-same`, `verify-record` (`checks/commands.txt`) | each generated header and C header `SAME 1` with Verified184's; the runtime's `driver.c`, `driver.o`, `driver-observe.o` `SAME 1` with Verified183's `rt-01`; G0, G1 and G2's L1 and C `SAME 1` (`7c146e25…`, `1b902b8a…`), their executables `EXE-SAME 1` (one image apart from the link stamp); `RECORD 38 hashes, 0 failed` for the runtime's record |
| `deps-01` | gcc with each recorded compile's flags and cwd, `-MM -MF` in place of `-c`/`-o` (`checks/deps-commands.txt`) | every header the driver (both modes: 38) and G1's tool (29) include, besides the system's, is in `STAGE/headers/l2src`, the three generated ones among them |

## The trace: which code wrote the headers, and which bytes the chain read

`trace/runtime-record.txt` (the bootstrap's `runtime/record.txt`), its first 21 lines, is `decls_write_all` running
inside G0, compiled from `tools/l2/build.lm2` into `tool-g0b/lmxtool.lm1`: for each header the SHA-256 of the file just
written, then the l1trans step translating it, the same hash as its input and its C header as its output.

| Header | written (`.h.lm1`) | its C header (`.lm1.h`) | Verified184's hand-written bytes |
| --- | --- | --- | --- |
| `lmx` | `f7de7589…` | `fd09c663…` | the same, both |
| `lmx_arena_blocks` | `54a218bf…` | `13a8ad42…` | the same, both |
| `lmx_arena` | `e0afb63c…` | `80036b03…` | the same, both |

Next in the record: the machine modules, whose L1 predefs these headers; `bld_headers` (`trace/runtime-headers-record.txt`
lines 25-42: each header translated again from the same input hash, its C header unchanged); the driver's L1 → C and
its two compiles.

How the chain finds them. Every translation step runs in `STAGE/src` (`bld_step` with `src` in `build.lm2` and
`suite.lm2`). l1trans resolves a predef with a directory (`"l2src/lmx.h.lm1"`) against that cwd and a bare one
(`"lmx_arena_blocks.h.lm1"`) against the predefing file's directory (`l1src/l1trans.lm1`: `l1_import_path_text`,
`l1_resolve_bare_import`); it has no search list. gcc looks a quoted `"l2src/<name>.lm1.h"` up in the including file's
directory and then in `bld_cflags`' `-I` list, in order: `STAGE/headers`, `BASE/codex_header98_source_control_06/includes`,
`REPO/build2/includes` (programs and the frontend), `REPO`, `REPO/lm1/build`, `STAGE/src`. Before the bootstrap
(`headers-before-02.out`) none of the three C headers was in any of them, and of the `.h.lm1` only the repository
root's older copies, which no step reaches: no l1trans step runs in the repository root, and gcc looks up `.lm1.h`.
gcc's own listing (`checks/deps-*.d`) names the generated C headers and no other copy; `verify-record` finds the
record's 38 hashes on disk.

## The older hand-written copies in the repository

`l2src/lmx.h.lm1`, `l2src/lmx_arena.h.lm1`, `l2src/lmx_arena_blocks.h.lm1` (last changed 2026-09-27, 2026-09-28,
2026-09-20) and `dev/l2src_sandbox/lmx.h.lm1`, `lmx_arena.h.lm1`, `lmx_arena_blocks.h.lm1` (2026-10-19, 2026-10-20,
2026-09-20) are tracked snapshots of other trees. In both sets `lmx.h.lm1` and `lmx_arena.h.lm1` differ from
Verified184's stage, and `lmx_arena_blocks.h.lm1` has its bytes. The runner's build never reads them. The old PowerShell and Python gate scripts read `dev/l2src_sandbox`
(`tools/build_l2src.ps1`, `tools/build_l2src.py`, `tools/gate_*.ps1`). This slice leaves them; whether to remove them is
a question to Codex.

## Evidence

`evidence-185.list` names 75 files: the recipe and its Verified184 parent, the stage's other tools sources and smoke
list, Verified184's hand-written headers and C headers, the runner, frontend and runtime of G0's build, both G0
builds, the header checks, the bootstrap's frontend, runtime (records, driver, objects), the generated headers and C
headers, the smoke, G1 and G2 (records, L1, C, executables), the memory logs, and the checks. `evidence-185.sha256`
holds their SHA-256, written by the tool's `manifest` (`manifest/manifest-185.out`: `MANIFEST 75 files, 0 failed`);
`sha256sum -c` checks all 75 OK. The packet's copies have LF line ends and no trailing blanks; the manifest hashes
the original bytes in `build2`.

A slip: `wc -l` over a glob of `build2/opus_fix185/runs/checks-01` opened the empty `l2_driver_launch.err` that the
tool's launches had left in that cwd (it counted 0 lines); nothing hashed, copied or staged it, and the evidence
names its files one by one.

## Not run (an explicit OPEN checkpoint)

- No mutant and no new failure path: the producer's failure removes what it wrote and stops the runtime's build, in
  the code above; Codex asked for no new gate or check system for this dependency.
- LATER: the kernel gate, the gate, `bootstrap full`, the full corpus replay.

## OPEN

- The L3+L2 self-build (plan section 8): the frontend (`l2trans.lm1`), `bin/l1trans.exe`, the driver and the rest of
  the kernel are L1 sources; per the author (LMX_blog/2026-10-24.md) both translators are to be written in L3.
- GENERATED-CODE-SIZE's rest, C-DOOR-ACTUALS-UNORDERED (rest), C-DOOR-MEMBER-ACTUAL-UNTYPED, FNPTR-LOCAL-NO-ADDRESS,
  MACHINE-STATUS-CHANNEL, PUBLICATION-FAILURE-UNSAID.

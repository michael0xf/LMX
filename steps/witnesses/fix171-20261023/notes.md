# Slice 171: os selection before translation, runner corrections, bootstrap quick|full

Opus, 2026-10-23, sole writer/build (to_opus.md).

The stage is `build2/opus_fix171`, made from the 281 Verified170 inputs. Two inputs change:
- `src/l2src/l2trans.lm1`: `l2trans.lm1.patch` (-U0) against Verified170's `5B29BF14…`;
- `src/l2src/lmx_arena.lm1`: `lmx_arena.lm1.patch` against Verified170's `E855CE26…` (ARENA-RELEASE-QUADRATIC).

The runner (`tools/l2`) and its lists and fixtures (`tests/l2`) change. The runtime is built by the bootstrap from
the stage (`boot-quick-02/runtime`). Before the kernel fix, Verified170's `runtime-04` built `tool-25` and the
control frontends.

## What changed

**os selection** (L2 §20; the author: `CODEX-AUTHOR-OS-SELECT-20261023T103338Z` and
`CODEX-AUTHOR-OS-NO-LATE-IFDEF-20261023T104249Z`).
- `l2_translate` selects the branch for the target right after the P0 parse:
  - `l2_os_target` is an L1 os block of the translator itself, i.e. the `_WIN32` of the C configuration that
    builds the frontend and the programs;
  - `l2_os_branch_for` gives 1 win, 2 default (for every platform without its own branch) or 3 none.
- The unselected branch is checked as structure only. Its names, types, contracts and directives are never read,
  and no code is generated for it.
- Removed: the per-branch passes, the L1 composer (`l2_os_compose`, `l2_os_copy_indented`, `l2_os_pass_path`) and
  the comparator (`l2_os_contracts`, `l2_os_missing` and the 171 key). R170-1 is withdrawn with them.
- An os program's L1 carries a target guard (`l2_emit_os_target_guard`). The other platform's section declares a
  cell initialised by an identifier no header declares, so that C does not compile for another target.
- The retained root graph keeps the unselected branch only as inert source text (string literals). This is
  allowed.

**Kernel** (ARENA-RELEASE-QUADRATIC). `lmx_arena_release` frees the arena whole: blocks, index and implements
table. It no longer retires interval after interval; each such retirement searched the index, scanned every
source-name row and shifted the index. A block that leaves a living arena still retires its interval
(`lmx_arena_drop`).

**C door** (ASSIGN-VOID-TO-TYPED-REF). `l2_consumed_type_value` no longer reads `p: c.f(x)` as the type receiver
`c.f` consuming x. The 13 workaround casts in `tools/l2` are gone.

**Q-F snapshot.** Every file of a translation is read once (`l2_snap_bytes`) and compared again before
publication (`l2_snap_verify`). The flag `--snap-touch FILE` is its witness.

**Runner corrections:**
- R170-2: strict suite schema; ENTRY is a full signed C int;
- R170-3: failure classes and controls by reason;
- R170-4: streaming hashes and text limits;
- RUNNER-SILENT-CUTS fixed;
- `bld_step` binds each step to its bytes (exe/in/out/log hashes; `verify-record`).

**bootstrap and rebuild** (the author: `CODEX-AUTHOR-QUICK-BUILD-20261023T111132Z`,
`CODEX-AUTHOR-BOOTSTRAP-BUILD-ONCE-20261023T112215Z`). This is today's chain, a BOOTSTRAP. It is not the L3+L2
self-build: the runtime and the frontend are L1 sources lowered by `bin/l1trans.exe`, and only the tool is L2.

`lmxtool bootstrap quick|full REPO STAGE BASE LABEL SMOKE-LIST [FULL-LIST]` builds the whole chain in both modes:

| Step | What it builds or runs |
| --- | --- |
| runtime | `driver.o` and `driver-observe.o`: one L1 step and two compiles |
| frontend | `l2trans.exe`: the header, L1 and one compile |
| tests | quick: the smoke list (`tests/l2/smoke.tsv`, 5 rows). full: the full list instead, plus the os walk witness and the self-test |
| G1 | this tool, built by G0 from the stage's tools sources with the new frontend and runtime |
| G1 check | G1 runs `sha256` and must print G0's digest |
| install G1 | G1 becomes `label/lmxtool.exe` |
| G2 | G1, run as a child, runs `build-self` |
| G2 check | G2 runs `sha256` the same way |
| install G2 | G2 becomes `label/lmxtool.exe` |
| full only | G2's L1 and C are G1's bytes; `exe_same(G1, G2)` |

The chain stops at the first failure.

`lmxtool rebuild frontend|runtime|tool|none …` is the incremental step: it builds one component and runs the
smoke list. It is no bootstrap.

**Compile once** (Codex's findings E5 on 170's gate-03):
- the os walk witness builds `os_walk_values`, and no suite row builds it again;
- the wrong-exit control reruns the suite's `os_bodies-native/p-prod.exe` with entry 8 (`run_expect`);
- the os selection step inspects the suite's L1 and C (`gate_os_selection` `built`) instead of translating again;
- `bootstrap full` runs the full list in place of the smoke list, which is a subset of it.

These patterns already held: one build per variant before the root0/1 runs, and one object linked with prod and
obs. The gate's mutant and missing-input controls are distinct inputs, so they still build.

## Results

Frontend `frontend-03`, built by tool-23:
- source = the stage's l2trans.lm1 `3CD010A2…`;
- C `2437E461…`;
- EXE `1CD872EA…`.

Its os probes:
- `runs/fe03-probe-01` (all os fixtures);
- `runs/fe03-probe-02` (os_select_only: C without the sentinel include, one `#ifdef _WIN32`; the header poison);
- `runs/fe03-probe-03` (the translate-then-hide frontend refuses `os_select_only.lm2:23:12: unknown method`).

Patch replay (`u0-same.out`): GNU patch applied each -U0 delta to a copy of its base, and the tool's `same` gives
`SAME 1` five times:

| Patch | Applied to | Gives |
| --- | --- | --- |
| a: l2trans.lm1.patch | Verified170 | the stage's l2trans.lm1 |
| b: census-control.patch | the census mutant | the stage's l2trans.lm1 |
| c: native-substitute-mutant.patch | the stage's l2trans.lm1 | osnative-04's |
| d: translate-then-hide-mutant.patch | the stage's l2trans.lm1 | osboth-03's |
| lmx_arena.lm1.patch | Verified170 | the stage's lmx_arena.lm1 |

Tool `tool-25` `954FC75B…`: built by tool-23 with frontend-03 and runtime-04. `tool-24` failed at the link (see
Process).

Control frontends, built for the gate, which has not run:
- census-04 `7DCFED55…`;
- osnative-04 `29D10E1D…`;
- osboth-03 `B4D5F113…`.

`bootstrap quick`, run 1: `boot-quick-01`, G0 = tool-25, with Verified170's runtime:
- runtime, frontend and smoke passed (`SUITE 5 rows, 0 failures`);
- G1 was built; its check printed the right digest and then exited 3 at the close deadline
  (ARENA-RELEASE-QUADRATIC);
- `BOOTSTRAP quick 1 failures` (`bootstrap-quick-01.out`).

`bootstrap quick`, run 2: `boot-quick-02`, after the kernel fix, G0 = tool-25. It ran 08:49–09:16.
- The runtime was rebuilt from the stage. Its driver.c no longer holds the release loop.
- The frontend C is frontend-03's bytes.
- Smoke: `SUITE 5 rows, 0 failures`.
- G1 `sha256` gave the digest, then `l2_eternal_driver: 13 checks, 0 roots` and exit 0.
- G1 built G2. G2's L1 is 18 bytes longer: G2 read the final tools sources, with the record-name fix below; G1
  had read them one line earlier.
- G2 `sha256`: exit 0.
- `BOOTSTRAP quick 0 failures` (`bootstrap-quick-02.out`).
- G0's own exit is still the close abort, because tool-25 links Verified170's runtime.

The order of the build and run steps is in `build-run-trace.txt`:
- each smoke program is translated, lowered and compiled once per variant and linked once;
- that one executable then runs at the root and with walkroot 1;
- refusal rows only translate.

In this run G0 wrote the G2 build's outer step and G2's check to the same record, `g2-record.txt`, so the check
replaced it. G2's own build record is `tool-g2/record.txt`. The committed source names the build record
`g2-build-record.txt`.

`rebuild frontend` (`runs/rebuild-frontend-01`; the tool is boot-quick-02's working binary, G2), 09:16–09:21:
- the frontend was built;
- the smoke list gave `SUITE 5 rows, 0 failures` and `REBUILD frontend 0 failures`;
- the tool's own exit was 0, after `l2_eternal_driver: 13 checks, 0 roots` (`rebuild-frontend.out`).

The complete run of the committed runner (Codex, CODEX-REVIEW-BOOTSTRAP171-20261023T123103Z): `boot-quick-03`,
09:31–09:58.
- G0 = boot-quick-02's working binary `BF05306E…`, which is the committed runner. It was built from exactly the
  committed `tools/l2` and linked with the fixed runtime.
- The stage was not touched during the run.
- The command is in `bootstrap-quick-03.command`.
- `BOOTSTRAP quick 0 failures`; smoke `SUITE 5 rows, 0 failures`.
- G1 and G2 exit 0 after their checks. Their L1 is one digest, `F4E2BE77…`, the same as boot-quick-02's G2.
- G1's `build-self` step has its own `g2-build-record.txt`.
- G0's own terminal exit is 0, after `l2_eternal_driver: 13 checks, 0 roots` (`bootstrap-quick-03.out`).
- Its trace: `build-run-trace-03.txt`. Its hashes: `evidence-171-03.sha256` (26 files, written by its working
  binary's `manifest`, re-checked by GNU sha256sum).

Hashes: `evidence-171.sha256` (`lmxtool manifest` by G2 over `evidence-171.list`).

## Not run (LATER, by the author's priority of 2026-10-23)

- the gate (`lmxtool gate`) with its controls;
- `bootstrap full`;
- a full corpus replay of frontend-03.
  - An earlier candidate of this slice, frontend-02 (before the os selection), replayed 3,735 rows with 0 DIFF
    against frontend-06 (`runs/replay-171-0[1-3]`).
  - The corpus has two os rows:
    - unit_s7_part_os_refused: frontend-03 refuses it with frontend-06's diagnostic;
    - unit_os_prologue: it translates (`runs/os-corpus-rows-01`), and its L1 halves because the program is
      translated once.
- the walker live-tree evidence (`CODEX-AUTHOR-WALKER-LIVE-TREE-20261023T105337Z`). This slice adds no stored
  preparation for the walker.

## Defects (steps/defects.md)

| Defect | Status |
| --- | --- |
| OS-UNSELECTED-BRANCH-TRANSLATED | fixed |
| SUITE-ROWS-NOT-FAIL-CLOSED | fixed |
| CONTROLS-ACCEPT-ANY-FAILURE | fixed |
| HASH-SIZE-NARROWED | fixed |
| RUNNER-SILENT-CUTS | fixed |
| ASSIGN-VOID-TO-TYPED-REF | fixed |
| C-DOOR-MEMBER-ACTUAL-UNTYPED | OPEN; reproductions in `defects/` |
| ARENA-RELEASE-QUADRATIC | fixed (`lmx_arena.lm1.patch`); `defects/close_gdb.txt` |

## Process

- A cmp loop touched slice 170's protected `l2_driver_launch.err`: it was compared by name only, a 0-byte file,
  never hashed or copied. Every loop now excludes the name.
- `tool-24` failed at the link: `build-self` was given the runtime directory instead of `driver.o`. Its label is
  kept; `tool-25` is the next attempt.

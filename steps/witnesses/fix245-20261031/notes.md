# Slice245 — the green-line bootstrap: boot88's G1 runtime blocker fixed in the arithmetic fold, boot89 passed

Base main/origin `4f5bf2872f31fd470ff936741759020e23ca59b7`. Opus sole writer/build; Codex consults
(CODEX-OPUS-87V63-20261031-ANSWER option B; CODEX-OPUS-85FIND-20261031-ANSWER: a blocker in the required
compiler/runtime/tool source path is fixed and the run continues). Sources stay in ignored `build2` variants;
nothing in `selfbuild/` changes in this slice.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`. Every tool CLI runs from a fresh private
CWD; long launches go through detached launcher records (`P/pins/*-detached.command`). Producer 49c
`P/cold-candidate49c/fe49c/l2trans.exe` `F646DD07…` (backend `B68E4DD2…`, libc `AF9FDAE3…`); BASE
`P/cold-candidate48/full48/g2/frontend`; G0 `P/cold-generator84/tool84-parts/lmxtool-tool.exe` `B9A2D857…`.

## boot88 stopped in the G1 runtime

boot88 (`pins/boot88-quick.command`): fresh source-only stage cold-boot88 = source-candidate84 + walker86
(`source-boot88.sha256` `37BC7643…`), `bootstrap quick` with G0 tool84, BASE full48/g2/frontend, previous frontend
49c, smoke225; 13:56:46Z → 16:32:59Z exit 1. G0 built the G1 frontend (`quick88/g1/frontend/l2trans.exe`); the G1
runtime stopped at step 5: `lmx_pool.lm2:150:12: assignment value has unknown type` (atom=capacity), the line
`bytes: capacity * pool\stride` (`pins/boot88-quick.log`: `FAIL generation: the runtime is built, its kernel's L2
modules and C headers with it: failing step 5`).

Census with that G1 frontend (`pins/census88-kernel.command`: the 36 kernel/driver l2trans commands of RT86w3's
record — the same kernel sources — with only the executable replaced and the outputs redirected into a private
directory; one diagnostic per module): 6 of 36 refused, one class — arithmetic over a member of a `c.*` struct
pointer in a machine method:

| module | line | statement |
|---|---|---|
| lmx_pool | 150:12 | `bytes: capacity * pool\stride` |
| lmx_range | 620:19 | `used: cells * array\stride` |
| lmx_implements | 2926:20 | `index: current\level + 1U + index * 2U` |
| lmx_graph_copy_owned | 540:23 | `capacity: spans\capacity * 2U` |
| lmx_reparent | 202:23 | `capacity: edges\room * 2U` |
| lmx_walk_values | 715:12 | `d: fields\size - 1U` |

The tool sources (`pins/census88-tools.command`: generator85's two tool l2trans commands on boot88's tools)
translate with the same frontend (methods part 695 s, `lmxtool.lm2` 0 s, both exit 0).

## Cause

Own numeric fields take the numeric receive route since 80b (`lm_compiler_emit_received_span_full` →
`lm_compiler_numeric_receive_prepare`; 48 and 49c used plain `lm_compiler_eval_fields`). prepare types the value
through `lm_compiler_value_span_type` → the `lm_compiler_value_expr_type` fold, which keeps an expression an
opaque C one (exact -12) only when each side is a number or has the explicit opaque contract — the fold's own
rule: "Unknown language names do not acquire this role". A path on an opaque C root (`pool\stride`,
`lm_compiler_path_root_raw_c`) was typed -99 with no exact type (`lm_compiler_path_value_type` status 2),
although the receiver (prepare's single-path rule, Lower84 :7994–8001), CHECK (Emit :4799–4801) and emission
(Lower84 :11971) all give that same path alone the opaque C contract. The product was "unknown" and refused.

## Fix

[resolve89.diff](resolve89.diff), `variants/green89/src/l2src/l2_frontend_resolve.lm2` (source84 `4553D128…` →
`25769A60…`), body only: in the fold's single-operand base, an operand typed -99 with no exact type whose prepared
path (the borrowed verdict, `lm_compiler_value_span_path` status 0/2) has members on a raw-C root gets exact -12.
Single paths keep their routes; unknown language names still get no role; no machine-only branch.

## Verification before the relaunch

- FE89g (`pins/candidate89g-prepare.command`, `pins/candidate89g-frontend-part.command`): stage89g = source-boot88
  with green89's resolve (`source-candidate89g.sha256` `9A5C12AC…`); `build-frontend-part` ONLY
  `l2_frontend_resolve`, host tool84, producer 49c, BASE full48/g2/frontend; the other 20 frontend modules reused
  from boot88's G1 build by exact manifests (all 42 module outputs in cold-boot88 equal that record's out
  hashes); resolve's regenerated `.h.lm1` is byte-equal (`4EABD272…`, ABI manifest verified before and after),
  so its declarations do not change. 17:05:23 → 17:08:00Z exit 0, `fe89g/l2trans.exe` `5E50AA8A…`.
- `pins/census89g-kernel.command` (the census88 commands with FE89g): 36/36 translate. The 38 outputs of the 30
  modules that translated under the G1 frontend are byte-identical; the six sites emit native C99 arithmetic as
  49c did, e.g. `l2_q14_bytes: ((l2_q15_capacity * l2_p5_1_pool\stride))`,
  `l2_q49_used: ((l2_q48_cells * l2_q53_array\stride))`, `l2_q61_d: ((l2_q62_fields\size - 1U))`.

## boot89

Fresh source-only stage cold-boot89 = source-candidate84 + walker86 + green89's resolve (`pins/boot89-prepare.command`;
`source-boot89.sha256` `9A5C12AC…`, 159 inputs, differs from source-boot88 only in resolve). `timeout 172800
tool84 bootstrap quick R P/cold-boot89 P/cold-candidate48/full48/g2/frontend P/cold-candidate49c/fe49c/l2trans.exe
quick89 P/cold-boot89/tests/smoke-kernel225.tsv` (`pins/boot89-quick.command`, launcher
`pins/boot89-detached.command`), start 17:13:40Z, single pipeline. RESULT OPUS-CODEX-89START-20261031T1715Z
delivered to Codex.

## boot89 passed: two whole source-built generations, both promoted

`pins/boot89-detached.terminal.txt`: `BOOT89 exit=0`, `BOOT89-QUICK EXIT=0 2026-10-31T22:49:33Z`;
`pins/boot89-quick.terminal.txt`: `BootstrapExit 0`; `pins/boot89-quick.log` (and `quick89/bootstrap.txt`) ends
`BOOTSTRAP quick 0 failures`. 17:13:40Z → 22:49:33Z, 20153 s. Q=`P/cold-boot89/quick89`; step ends are the receipts'
file times.

G1, built by G0 tool84 with previous frontend 49c (`pins/boot89-quick.log`):

| step | end (UTC) | s | receipt |
|---|---|---|---|
| frontend | 19:46:34 | 9174 | `PASS generation: the frontend is built`; l2trans `B2B17F95…`, l1trans `99A29C43…`, l2_libc.o `AF9FDAE3…` (49c's bytes) |
| runtime | 19:50:08 | 214 | `PASS generation: the runtime is built, its kernel's L2 modules and C headers with it` (the six census88 modules among them); driver.o `B3063DBA…`, driver-observe.o `FEEBEC32…` |
| smoke225 | 19:51:04 | 56 | `SUITE 9 rows, 0 failures` (native and forced, root0 and root1) |
| tool | 20:02:05 | 661 | `PASS generation: its tool is built`; lmxtool-tool.exe `3B247A80…`, `lmxtool.lm1` `20204CD9…`; it hashes a file as G0 does; 306 consumed inputs retained (`MANIFEST`/`STAGED 306 files, 0 failed`) |

Then `PASS bootstrap: G0 builds and tests whole G1` and `PASS G1: the tested whole bundle is working`
(`Q/g1/bundle.sha256`).

G2, built by the actual G1 tool. `Q/g2-build-record.txt`: `$ Q/g1/tool/lmxtool-tool.exe 0 entry 0 -- build-generation
quick R P/cold-boot89 P/cold-candidate48/full48/g2/frontend Q/g1/frontend/l2trans.exe quick89/g2
P/cold-boot89/tests/smoke-kernel225.tsv`, exe `3B247A80…`, in `B2B17F95…` (the G1 frontend) and `32EAD2C4…` (smoke225),
`kind 0 exit 0`, log `Q/g2-build.log` `E9258932…`:

| step | end (UTC) | s | receipt |
|---|---|---|---|
| frontend | 22:33:44 | 9096 | `PASS generation: the frontend is built`; l2trans `AA54323A…`, l1trans `08092D50…`, l2_libc.o `AF9FDAE3…` |
| runtime | 22:37:19 | 215 | `PASS generation: the runtime is built, …`; driver.o `B3063DBA…`, driver-observe.o `FEEBEC32…` |
| smoke225 | 22:38:15 | 56 | `SUITE 9 rows, 0 failures` |
| tool | 22:49:30 | 675 | `PASS generation: its tool is built`; lmxtool-tool.exe `7FD2E824…`; 306 consumed inputs retained |

Then `PASS bootstrap: actual G1 builds and tests whole G2`; `Q/g2-record.txt`: G2's tool hashes its `lmxtool.lm1`
to `20204CD9…`, exit 0 (`PASS … the same digest`); `PASS G2: the tested whole bundle is working`: the working
`Q/lmxtool.exe` is `7FD2E824…` (G2's tool) and `Q/working-bundle.sha256` is `Q/g2/bundle.sha256` byte for byte.

### G1 and G2 compared

Quick mode does not compare the generations; this comparison is computed from the receipts. Raw sha256 first: of
the 248 paths hashed in both generation logs, 220 are raw-equal, among them `l2_libc.o`, `driver.o`,
`driver-observe.o`, `driver.c`, the tool's `lmxtool.lm1` and `lmxtool.c`, and every kernel output hashed in the
runtime step (42 `.lm1`, 46 `.h.lm1`; G1's kernel translated by the G1 frontend, G2's by the G2 frontend). 28 differ
raw:

- the 23 frontend/backend module `.lm1` (G1's translated by 49c, G2's by the G1 frontend), `frontend.c` and
  `backend.c`: each pair has equal line counts and is byte-equal after deleting `(` and `)` — the grouping
  parentheses the numeric receive route adds, the class census89g found in the kernel (compared from
  `Q/g1/consumed-inputs` and `Q/g2/consumed-inputs`, where each generation's bytes are retained);
- the three PE images l2trans, l1trans and lmxtool-tool: equal sizes; the only differing bytes are TimeDateStamp
  (offset 136) and CheckSum (offset 216), i.e. one image apart from the link stamp.

The G2 frontend image is G1's apart from the stamp, so a further generation would run the same code on the same
sources (an inference, not a run). Neither generation ran the full list, OSWALK or the self-test (quick mode).

## Boundaries

This is the green line (source84 + walker86 + green89's resolve) in ignored `build2`; nothing in `selfbuild/` or
the published package changed, and the working tool for checks stays FULL48's `A6D5EC40…` until a landing is
decided. The draft79 line is not part of this result: V63 (DRAFT79-OWNER-POINTER-CONTEXT-STACK-POINTEE), the
split-pointer place (SPLIT-POINTER-PLACE-NOT-ADMITTED) and the bare return (DRAFT79-BARE-RETURN-CHECKER) stay OPEN.
green89's resolve is not yet in that line. The mail §8a/T01–T26 work has not started.

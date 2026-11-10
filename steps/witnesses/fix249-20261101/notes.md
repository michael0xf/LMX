# Slice249 — the draft79 line's short bootstrap: boot98 passed, G2 is the line's first self-built generation

Base main/origin `e633b39b86c935abc66774a7d84dbc4a76af5dc8` (slice248). Opus sole writer/build; Codex consults
(CODEX-OPUS-RESOURCE-LINK-20261101-01: "continue the draft line's short bootstrap as planned, with the single
writer/build staying yours"). Sources stay in ignored `build2`; nothing in `selfbuild/` changes in this slice.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`; Q=`P/cold-boot98/quick98`. Every tool CLI runs
from a fresh private CWD; the long run went through a detached launcher record. Producer 49c
`P/cold-candidate49c/fe49c/l2trans.exe` `F646DD07…` (backend `B68E4DD2…`, libc `AF9FDAE3…`); BASE
`P/cold-candidate48/full48/g2/frontend`; G0 `P/cold-generator93/tool93-parts/lmxtool-tool.exe` `DF3B7ED0…` (the
line's tools sources with writer93, the host of FE93/FE94); gcc `920A4FC6…`.

## The stage

`pins/boot98-prepare.command` (tool `7FD2E824…`, verify/stage-copy/manifest only): a fresh source-only stage
cold-boot98 = source-candidate94, the 159 inputs of `selfbuild/inputs.list` that FE94 + RT92 were built from.
07:32:00 → 07:32:01Z, four steps exit 0; `source-boot98.sha256` = `source-candidate94.sha256` = `1F374773…`; no
generated header, body, object or reuse set. Against the released package (`source-boot89` `9A5C12AC…`) it differs in
9 files: frontend coords/core/emit/lower/useplan, kernel lmx_reparent/lmx_value_owned/lmx_walk_values and
`tools/build.lm2` (writer93 `1C6A9974…`).

## boot98

`timeout 172800 tool93 bootstrap quick R P/cold-boot98 P/cold-candidate48/full48/g2/frontend
P/cold-candidate49c/fe49c/l2trans.exe quick98 P/cold-boot98/tests/smoke-kernel225.tsv`
([command](records/boot98-quick.command), launcher [boot98-detached](records/boot98-detached.command)); the record
re-checks every input pin and that no pipeline is live. Start 07:32:15Z (PreVMKiB 11329848), one pipeline; STARTED
was reported in [RESULT248](records/OPUS-CODEX-RESULT248-20261101T0735Z.md) §3.

[boot98-detached.terminal](records/boot98-detached.terminal.txt): `BOOT98 exit=0`, `BOOT98-QUICK EXIT=0
2026-11-01T12:35:32Z`; [boot98-quick.terminal](records/boot98-quick.terminal.txt): `BootstrapExit 0`;
[the log](records/boot98-quick.log) (and [`Q/bootstrap.txt`](records/boot98-bootstrap.txt)) ends `BOOTSTRAP quick 0
failures`. 07:32:15Z → 12:35:32Z, 18196 s (boot89: 20153 s). Step ends are the receipts' file times.

G1, built by G0 tool93 with previous frontend 49c (`pins/boot98-quick.log`):

| step | end (UTC) | s | receipt |
|---|---|---|---|
| frontend | 09:48:47 | 8192 | `PASS generation: the frontend is built`; l2trans `267B1010…`, l1trans `BEE9E364…`, l2_libc.o `AF9FDAE3…` (49c's bytes) |
| runtime | 09:52:01 | 194 | `PASS generation: the runtime is built, its kernel's L2 modules and C headers with it`; driver.o `40B84ECF…`, driver-observe.o `16A0C54A…` |
| smoke225 | 09:52:53 | 52 | `SUITE 9 rows, 0 failures` (native and forced, root0 and root1) |
| tool | 10:03:22 | 629 | `PASS generation: its tool is built`; lmxtool-tool.exe `C9CEBC8B…`, `lmxtool.lm1` `CE10AF15…`; it hashes a file as G0 does; 306 consumed inputs retained (`MANIFEST`/`STAGED 306 files, 0 failed`) |

Then `PASS bootstrap: G0 builds and tests whole G1` and `PASS G1: the tested whole bundle is working`
([`Q/g1/bundle.sha256`](records/boot98-g1-bundle.txt)).

G2, built by the actual G1 tool. [`Q/g2-build-record.txt`](records/boot98-g2-build-record.txt): `$ Q/g1/tool/lmxtool-tool.exe 0
entry 0 -- build-generation quick R P/cold-boot98 P/cold-candidate48/full48/g2/frontend Q/g1/frontend/l2trans.exe
quick98/g2 P/cold-boot98/tests/smoke-kernel225.tsv`, exe `C9CEBC8B…`, in `267B1010…` (the G1 frontend) and
`32EAD2C4…` (smoke225), `kind 0 exit 0`, log [`Q/g2-build.log`](records/boot98-g2-build.log) `24D8AC6E…`:

| step | end (UTC) | s | receipt |
|---|---|---|---|
| frontend | 12:21:17 | 8273 | `PASS generation: the frontend is built`; l2trans `8E56C1F3…`, l1trans `6C880975…`, l2_libc.o `AF9FDAE3…` |
| runtime | 12:24:30 | 193 | `PASS generation: the runtime is built, …`; driver.o `40B84ECF…`, driver-observe.o `16A0C54A…` |
| smoke225 | 12:25:23 | 53 | `SUITE 9 rows, 0 failures` |
| tool | 12:35:30 | 607 | `PASS generation: its tool is built`; lmxtool-tool.exe `B8B01381…`; 306 consumed inputs retained |

Then `PASS bootstrap: actual G1 builds and tests whole G2`; [`Q/g2-record.txt`](records/boot98-g2-record.txt): G2's
tool hashes its `lmxtool.lm1` to `CE10AF15…`, exit 0 (`PASS … the same digest`); `PASS G2: the tested whole bundle is
working`: the working `Q/lmxtool.exe` is `B8B01381…` (G2's tool) and `Q/working-bundle.sha256` is
[`Q/g2/bundle.sha256`](records/boot98-g2-bundle.txt) byte for byte.

G1 is FE94 again: its l2trans and l1trans have FE94's sizes, and the only differing bytes are TimeDateStamp (offsets
136–138) and CheckSum (216–217), so the bootstrap's G1 frontend runs FE94's code, the frontend every check of slices
247/248 ran with (narrowed in slice250: those checks ran on RT92's runtime; their run results stay RT92's). Its runtime
is not RT92's (`0728B3EB…`): RT92's kernel was translated by 49c, the boot's by the line's own frontend. That runtime
passed the smoke list in both generations, and G1's and G2's runtimes are raw-equal.

## G1 and G2 compared

Quick mode does not compare the generations; this comparison is computed from the receipts. Raw sha256 first: of
the 248 paths hashed in both generation logs (none only in one), 220 are raw-equal: all 63 `.lm2`, all 84 `.h.lm1`,
13 C headers `.lm1.h`, 54 `.lm1` (L1 sources and outputs), `l2_libc.c/.o`, `driver.c`, `driver.o`,
`driver-observe.o` and `lmxtool.c`. Among them are every kernel output of the runtime step (42 `.lm1`, 46 `.h.lm1`;
G1's kernel translated by the G1 frontend, G2's by the G2 frontend) and the tool's `lmxtool_methods.lm1` and
`lmxtool.lm1`. 28 differ raw, in the same 28 places as boot89: the 23 frontend/backend module `.lm1` (G1's
translated by 49c, G2's by the G1 frontend), `frontend.c` and `backend.c`, and the three PE images. The text pairs
were compared from `Q/g1/consumed-inputs` and `Q/g2/consumed-inputs`, where each generation's bytes are retained:

- 6 modules (l2_consumer_uses, l2_copy_uses, l2_receiving_source, p0_own, p0_scan, p0_text) have equal line counts
  and are byte-equal after deleting `(` and `)`. These are the grouping parentheses of the numeric receive route,
  the class boot89 had.
- The other 17 modules, and `frontend.c` and `backend.c`, are equal after deleting the parentheses and the lines G2
  lacks. G2 adds no line. It lacks 1640 L1 lines, each a store of a typed 0 into a named local,
  `l2_qN_x: (cast: (T) (0))`, e.g. `l2_q7_p: (cast: (@: void) (0))` in `lm_compiler_xmalloc`
  ([diff](g1-g2-frontend-alloc.diff)). In C these are 1389 lines `x = (T *) 0;` in `frontend.c` and 368 in
  `backend.c`. Both translators contain p0_parser, so its 117 stores count in both.

  | modules | stores |
  |---|---|
  | frontend: alloc 9, context 31, coords 29, core 323, emit 243, helpers 77, intern 16, lower 245, resolve 90, types 61, useplan 56, values 53, views 39 | 1272 |
  | backend: l1_backend_emit 139, l1_backend_state_helpers 75, l1_backend_text 37 | 251 |
  | p0_parser | 117 |

The cause is the line's Lower, which came with draft79 (`variants/coherent85` Lower `3965C9C2…`) and is unchanged
in this respect through coherent94 (`99605615…`, the stage's). In `lm_compiler_emit_stmts_with_position`, a
declaration without a written or implicit candidate is skipped before any store: `# No written or implicit
candidate means no body write, including the first declaration.` The released Lower (source89) skipped only a
repeat (`own_decl_cell[0][oi] != stmt`, `# A candidate-free repeat retains the existing pointer value.`), so the
first declaration wrote its typed 0 ([diff](lower-candidate-free.diff), release `a/` → stage98 `b/`). This is M3
(`next_core_tasks_v3.md` "M3 — Первое объявление и повторная форма"). The first `@: ptr` "не обещает начального
адреса", only `@: ptr 0` explicitly writes zero, and "Однополевая форма без кандидата при уже известном месте только
сверяет требование и ничего не записывает". The local's 0 at activation entry stays: the hoisted `@: T l2_qN_x 0` is
in both generations.

Behaviour check, on G1's L1 (`Q/g1/consumed-inputs`). Before every one of the 1640 stores, the local appears only in
its declaration with 0, or (twice: `l2_q88_tfield` and `l2_q93_tfield` in l1_backend_emit) also in an earlier typed-0
store of the same local.
- **Once per activation (1627).** 1622 stores sit at a function's top level and 5 (p0_parser) in a branch outside any
  loop. Each writes 0 over 0.
- **Inside a loop (13, all p0_parser).** Here a later iteration would find the previous iteration's value. In each,
  every path from the store reaches a write before any read:
  - 8 are followed directly by the write;
  - 3 first pass a `return` or `continue` (and an if/else that does not touch the local);
  - `l2_q302_text` and `l2_q337_text` are read only after unconditional writes in the same iteration.

  Nothing reads any of the 13 after its loop.

So the dropped stores change no behaviour in these modules. The generations agree with that: the G1 frontend (49c's
translation, with the stores) and the G2 frontend (G1's translation, without them) gave byte-identical kernel,
driver and tool outputs and passed the same smoke list.

The PE images:
- **lmxtool-tool.** Equal sizes; only 4 bytes differ, TimeDateStamp (136–137) and CheckSum (216–217): one image apart
  from the link stamp.
- **l2trans.** Equal sizes, but 522595 bytes differ.
- **l1trans.** 482730 → 479146 bytes.

The frontend images are different code because their C differs by the stores above.

## What this shows

Two whole source-built generations of the draft79 line, each built and tested whole (smoke list only). G2 is the
first generation built by the line's own frontend, and its working tool is promoted (`Q/lmxtool.exe` `B8B01381…`).
Unlike boot89, G1 and G2 frontends are not one image, so this run does not show the fixed point. A third generation,
built by the G2 frontend from these sources, would be translated by a frontend that behaves like G1's on everything
observed here. That its L1 equals G2's is an inference, not a run. A further generation from G2 tests it directly: G0
`Q/lmxtool.exe`, previous frontend `Q/g2/frontend/l2trans.exe`, the same 159 sources. Its G1 must then equal this G2
(raw-equal L1, PE apart from the stamp). Neither generation ran the full list, OSWALK or the self-test (quick mode).

## Boundaries

This is the draft79 line (the sources of FE94 + RT92) in ignored `build2`. Nothing in `selfbuild/` or the published
package changed, and the working tool for checks stays boot89's `7FD2E824…` until a landing is decided. Left as in
slice248:
- the raw index place and the deref-word route;
- the unused `pc102_write` prototype (cause inferred, not traced).

The line's FULL and its landing have not been run; the mail §8a/T01–T26 work has not started.

## Evidence and checks

[evidence.list](evidence.list) names the originals under P that these notes cite:
- the prepare and bootstrap records with their logs and terminals, both source manifests and the smoke list;
- the stage's Lower and coherent85's Lower;
- FE94's two images and RT92's `driver.o` (how RT92 was built: slice247's notes, chain92);
- `Q/bootstrap.txt`, the G2 build and sha256 records and logs, both bundles and consumed-input manifests, and the
  working bundle and tool;
- each generation's frontend, backend, libc, `frontend.c`, `backend.c`, driver objects, tool `.lm1`/`.c`/image and the
  23 retained module `.lm1`;
- RESULT248.

`P/pins/docs249.command` computed [evidence.sha256](evidence.sha256) and verified it, and
`P/pins/docs249-check.command` ran the full docs check with the slice in the Git index — both with the working tool
`7FD2E824…`. `records/` holds LF copies (trailing blanks removed). [g1-g2-frontend-alloc.diff](g1-g2-frontend-alloc.diff)
is `diff -U0` of the two retained `l2_frontend_alloc.lm1` under their P-relative paths;
[lower-candidate-free.diff](lower-candidate-free.diff) is the one `diff -U0` hunk of
`selfbuild/src/l2src/l2_frontend_lower.lm2` → `P/cold-boot98/src/l2src/l2_frontend_lower.lm2` that carries the rule.

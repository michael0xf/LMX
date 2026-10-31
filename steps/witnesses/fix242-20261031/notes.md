# Slice242 — component80b, Lower81/82 and the hidden-input entry/suffix route (83)

Base main/origin `d5a9e5f0f2592bb3ab7e09fcc40f661db39a3ee6`. Opus is the sole writer/build
since CODEX-OPUS-HANDOFF-20261031T004230Z ([handoff](../../../to_opus.md)); Codex consults.
Sources stay in ignored `build2` variants; nothing in `selfbuild/` changes in this slice.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`. Every tool CLI runs
from a fresh private CWD; each launch is a text record `P/pins/<name>.command` run by the
existing pwsh7, with start/terminal pins beside it. Host tool for 80b–82 is GEN62
`P/cold-generator62/tool62-parts/lmxtool-tool.exe` `351D933F…`; the explicit producer is 49c
`P/cold-candidate49c/fe49c/l2trans.exe` `F646DD07…`; BASE `P/cold-candidate48/full48/g2/frontend`.

## 80b and Lower81

- Component80b (Lower+Core, handed over live): start 00:25:34Z, terminal 2026-10-31T01:39:28Z
  exit0; `fe80b/l2trans.exe` `9FE386EC54CC82A9B68B1DF23C35071AD2FEED7CFAC3C57E95DA4F1AFC24F360`.
- Source81 = source80 + Lower `36D27AAA…` only; manifest `source-candidate81.sha256`
  `2B9D83A2…`; reuse284+4 Core80b outputs `C8D18D2C…`, invariants135+3 `028C95C5…`.
  ONLY Lower81: start 01:40:40Z, terminal 02:07:55Z exit0; `fe81/l2trans.exe`
  `D50DAA3A51BF40FF13C98BACFFE7581565D30FFAC47527DE42F5519B83C73EE5`.
- Existing machine-module witness `variants/frontend81/unit_machine_c_member_receiving.lm2`
  `EF5C1D50…` (`pins/witness81-c-member.command`): FE81 exit0, outputs `.lm1` `2FB2A2DF…`,
  `.h.lm1` `F5262E2D…`; the same command through fe80b exit1, outputs absent (the old
  translation failure). This is a translation check only, not values.

## Suites81 on support stage71/RT71 and Lower82

Existing rows `pins/owner-values73-callable-hidden55.tsv` `69046AA3…` (`variants/runtime-callable73/
lib_owner.lm2` `737D5698…`) and `pins/held-forward78.tsv` `14171ED1…`
(`unit_hidden_entry_merged_forward.lm2` `E7CE56B4…`), runtime71 `P/cold-candidate71/rt71/driver.o`
`2F4A95B0…`, observe `F3CE1D16…` (`pins/suites81-stage71-02.command`; attempt 01 of that record
shadowed `$R` by the case-insensitive loop variable `$r`, passed shifted arguments and is kept as
my record error, not a result):

- FE81 owner73: `lib_a native` L1 exit1 — defect NATIVE-DEFAULT-SENTINEL-MEMBER-TARGET.
- FE81 held78: L2 `internal: a refusal said nothing` (native and forced) — defect
  PLACE-VALUE-GRAPH-CODE-SPELLING.

From FE82 on, the owner row is `pins/owner-values73b-callable-hidden55.tsv` `9BDC85A7…`: owner73
with the two local observation bridges agreed in CODEX-OPUS-81ANS (`variants/runtime-callable73b/
lib_owner.lm2` `E906139D…`, a typed local at :143 and :591 for the two actuals hit by the OPEN
BARE-DEREF-ACTUAL-MERGED); the defect itself stays OPEN.

Lower82 `474BA716…` ([lower82.diff](lower82.diff)); source82 `88B34119…`, the same 81 reuse
manifests. ONLY Lower82: start 02:35:11Z, terminal 03:03:48Z exit0; `fe82/l2trans.exe`
`4DE162FE08F6261ED39A8CB99A4C2D8C6CCEE2E52E75A86931F987C8C8C2526E`. The witness above through
FE82 (`pins/witness82-c-member.command`): exit0, outputs equal FE81.

Suites82 (`pins/suites82-stage71.command`, FE82 + stage71/RT71):

- owner73b: libraries lib_a/b/c/m L1 and CC with 0 errors (first defect closed). Both
  `lib_owner` compiles (native, forced) reached the expected
  `p.c:26072:21` / `26084:21` `error: implicit declaration of function
  'lmx_callable_source_receiving'` and were then stopped by the ordinary 900 s step bound:
  `INFRA step 3 kind 2 exit 900000` (03:04:55→03:20, 03:20:15→03:35:15Z). p.c 16543281 bytes,
  p.lm1 115697 lines, `-O2 -fstrict-aliasing`; see PUBLISH-CALL-CODE-SIZE. No owner73 values.
- held78: native and forced build (second defect closed). native root0
  `V78 held-forward result=2 copied=2 original=1`, exit82 (expected7): the hidden default is
  read after `node\source: 2`. native root1, forced root0/root1: `lmx: walk error:
  UNSUPPORTED` — the walker refuses the hidden suffix.

## 83: hidden input held at entry, hidden suffix bound by name, Q4 declaration

Sources (ignored `P/variants`, exact diffs here): Lower83 `F5CE4741…` ([lower83.diff](lower83.diff)) adds
`lm_compiler_emit_native_input_entry`: semantics RU §9 (`docs/LMX_semantics.ru.md:464-466`), the
consumed hidden input is held from the activation's entry by the same default reader and filters
(forward-only stays unread, a supplied one keeps its value; no eager read, no flags; CODEX-OPUS-81ANS).
Emit83 `9A020D4C…` ([emit83.diff](emit83.diff)) calls it before the own entry loads and the body.
implements83 `C664E069…` ([implements83.diff](implements83.diff)): `lmx_callable_bind_written` binds
the normalized suffix after the written prefix by the Consumer contract input's name at the same
SOURCE ordinal through `lmx_callable_named_formal`; admission (`source_binding`) passes no contract.
walker83 `0598E0FB…` ([walker83.diff](walker83.diff)): the suffix is evaluated once after the written
operands, scattered with occupancy2, and an absent one travels as an absent full Value with ref0
(CODEX-OPUS-83SUFFIX). Writer83b `F63B1084…` ([writer83b.diff](writer83b.diff)): the Lower and
implements exports, the `lmx_callable_source_receiving` prototype, the `bind_written` prototype with
`contract_inputs`, and the program compile in `bld_program_k` bounded by the existing `bld_step_t`
3600000U (CODEX-OPUS-83CCTIME-20261031-ANSWER; the suite constants bound only L2).

Builds, all exit0, fresh CWDs, records `P/pins/{generator83b-prepare,generator83b-self,
candidate83-prepare,candidate83b-writer,candidate83-frontend-parts,candidate83-runtime}.command`:

- generator83 (writer83, before the bound was added) exit0 03:50:08Z, tool83 `D6228282…` —
  superseded, unused. generator83b = source-generator62 + writer83b (`source-generator83b.sha256`
  `7E2BC482…`, the same 56 bridge headers): exit0 04:02:34Z, tool83b
  `36C2F7E1195227832C8AE880FAB5E90B2295F5631D245CF1ADB34906DE90D0D1`.
- Stage83 = source82 with the five sources (`source-candidate83b.sha256` `9C4F7821…`); reuse284
  `0700159E…`/invariants135 `41237C3A…` = the 81 manifests without the Emit outputs.
- FE83 = ONLY Lower83 + Emit83, explicit 49c, host tool83b: 04:02:56→05:42:31Z (Lower 26 min, Emit
  72 min), invariants135/0 before and after; `fe83/l2trans.exe`
  `C7D9129C8DC6DD0F1F8F94474D8145A798D20B5925B25BAB8D74BC48EF0D53E2`. The regenerated Lower header
  declares the new function (`l2_frontend_lower.h.lm1:220`).
- RT83 (host tool83b, FE49c): 05:42:47→05:46:31Z, 39 steps; `rt83/driver.o`
  `BEFDAC71E9B152CF2B989BAF0ABEDD466D8EEADB10D1DF8134FEBCD6BAF20A`, observe `FF21C1AA…`.
  `lmx_callable_source_receiving` is declared now (`src/l2src/lmx_implements.h.lm1:406`,
  `headers/l2src/lmx_implements.lm1.h:140`). The symbol was already a global `T` in `rt71/driver.o`,
  as every machine-module function is: the defect was the missing public declaration only.

Suites83 (`pins/suites83.command`, runner tool83b, stage83 with FE83 + production RT83):

- held78: SUITE 1 rows, 0 failures. native root0, native root1, forced root0, forced root1 each print
  `V78 held-forward result=7 copied=2 original=1`; build/link/run status0. In the forced build only
  `observe_values` (the C door) and the root keep a native word; `invoke` and `probe` reach walked
  bodies through the common dispatch (Codex checked this independently). `schema` is the receiving
  descriptor here, and no separate claim is made for the `Model` body. The rows link the PRODUCTION
  runtime; the four logs carry no walk-event trace and are not observed-runtime runs. They confirm the
  copied callable's consumed hidden-entry snapshot and the values 7/2/1 — not wider ownership,
  runtime-signature admission or the whole goal.
- owner73b: native CC 0 errors (the implicit declaration is gone), 1046 warnings, but stopped by the
  3600 s bound (05:47:37→06:47:38Z), `p.o` empty. cc1 private grew ~145 MB/min to a peak 5.1 GB
  (06:20–06:21Z; system commit grew 19047→21109 MB), fell to 0.93 GB when `l2_m15` finished (the last
  CC log write 06:22:26Z is a warning inside `l2_m15`), and grew again for the next giant function.
  Forced the same: CC 0 errors, stopped by the bound 06:47:53→07:47:53Z, `p.o` empty (peak above
  4.3 GB, again past the `l2_m15` drop near 36 min). Row result `SUITE 1 rows, 2 failures`, both
  `INFRA lib_owner … step 3 kind 2 exit 3600000`; all four libraries pass in both variants. No owner73
  values are confirmed; the timeout/empty object stays OPEN evidence.

## Measured producer expansion (PUBLISH-CALL-CODE-SIZE)

FE83 `lib_owner` p.lm1: 115697 lines, 166 fns, 16969548 bytes; p.c 16543281 bytes. The 7061 publish
calls are 10614945 bytes (63%, 1503 bytes each). `l2_m15` (`try_dynamic_m`, `lib_owner.lm2:207-603`)
is 36192 L1 lines with 705 boundaries × 9 group helpers = 6345 calls; its walker graph builder
`frames15` is 29888 lines. owner60 for comparison: p.c 3762794 bytes, CC 34 s. Each call passes per
place `(@ l2_qK_dirty), l2_qK_from, (@ l2_qK)[, (@ l2_wvK)]` — the same addresses at every boundary
of the activation. The chosen local improvement (84, CODEX-OPUS-84PUBLISH-20261031-REVIEW: no
semantic objection) passes one activation-local table instead; it does not reduce `frames15`.

## Evidence and checks

[evidence.list](evidence.list) `C7208101…` names 125 originals under P (records, terminals, logs,
manifests, sources, outputs). The working G2 tool `P/cold-candidate48/full48/lmxtool.exe`
`A6D5EC40…` computed [evidence.sha256](evidence.sha256) `6D4382F5…` (MANIFEST 125/0) and verified it
(125/0), `P/pins/docs242.command`. `records/` holds LF copies of the records, terminals and docs logs;
their raw bytes are the originals pinned there (the docs logs below by their own hashes).

The ordinary full docs check with the same tool: attempt 01 exit1 after 18 s with no diagnostic —
its PRIVATE_OUT did not exist (defect DOCS-CHECK-PRIVATE-OUT-SILENT); `docs verify semantics` alone
exit0. Attempt 02 (`docs242-check-02.command`, fresh empty `P/docs242-out-02` created first, as
slice241 had done) 07:54:24→07:55:51Z exit0, log `92BBA5E1…`: `OK: 35 paired semantic chapters,
14 implements cases, both source snapshots; 27 paired grammar sections, 44 verbatim source excerpts,
615 imported files, links, exact semantic opening; line endings LF in the index for all 12241 tracked
files`. `git diff --cached --check` is clean. No broad corpus or FULL run belongs to this slice.

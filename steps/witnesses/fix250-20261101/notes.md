# Slice250 — full99 found a stale numeric working Value in the draft79 line; the fix coherent100 and full100

Base main/origin `3984006f36b8e1a6dc3a41b41ac3ebe95ca8779f` (slice249). Opus sole writer/build; Codex consults
([CODEX-OPUS-249-LANDING-20261101-ANSWER01](records/CODEX-OPUS-249-LANDING-20261101-ANSWER01.txt): land only after
full99's terminal; on a failure keep the receipts and fix the concrete cause; a semantic defect of the target source is
fixed before the claim is promoted). Sources stay in ignored `build2`; nothing in `selfbuild/` changes in this slice.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`; Q=`P/cold-boot98/quick98`;
F=`P/cold-full99/full99`; the failing row's directory W=`F/g1/suite/sha256_vectors-native`. Every tool CLI runs from a
fresh private CWD; the long runs went through detached launcher records. Only named files of W are read.

## full99

`pins/full99-prepare.command` (tool `7FD2E824…`, verify/stage-copy/manifest only; [terminal](records/full99-prepare.terminal.txt)):
12:59:52 → 12:59:54Z, four steps exit 0, a fresh source-only stage cold-full99 = source-candidate94; `source-full99.sha256`
= `1F374773…` (159 inputs), no generated input.

`timeout 172800 Q/lmxtool.exe (B8B01381…) bootstrap full R P/cold-full99 P/cold-candidate48/full48/g2/frontend
Q/g2/frontend/l2trans.exe (8E56C1F3…) full99 …/tests/smoke-kernel225.tsv …/tests/full-suite.tsv`
([command](records/full99.command), launcher [full99-detached](records/full99-detached.command)). G0 and the previous
frontend are boot98's G2, so this G1 is the next generation from that G2. A first launch at 13:00:02Z passed the
launcher with `-File`, which pwsh refuses for a non-`.ps1` name: PID 13920 exited at once and ran nothing (no terminal,
no CWD). The relaunch at 13:00:27Z used the `-Command` ScriptBlock form.

[full99.terminal](records/full99.terminal.txt): `StartUTC 13:00:28.30Z PreVMKiB 11132292`, `EndUTC 15:21:28.05Z
BootstrapExit 1`; [launcher terminal](records/full99-detached.terminal.txt): `FULL99 EXIT=1`, `done 15:21:28Z`.
[full99.log](records/full99.log) (752 lines; its outputs' times from the named files):
- G1 frontend (`l2trans` 06053912…, `l1trans` 4353BE94…, `l2_libc.o` AF9FDAE3…), 13:00:28 → 15:16:12Z;
- G1 runtime (`driver.o` 40B84ECF…, `driver-observe.o` 16A0C54A…), done 15:19:36Z;
- G1 full list, 15:19:36 → 15:21:28Z: `SUITE 37 rows, 2 failures`, both `sha256_vectors native root0/root1: gives 7:
  driver exit 1 [EXIT]`; every other row passed. Then `FAIL generation full: … failures 2`, `FAIL bootstrap: G0 builds
  and tests whole G1: 1`, `BOOTSTRAP full 1 failures` and the G0 tool's own exit check. OSWALK, the self-test, the tool,
  G2 and the comparisons did not run: the generation stops at its first failing step.

The row is `runs sha/sha256_vectors.lm2 7 n ../tools/sha256.lm2` (native only; the second part is the tool's SHA-256
module). Its build steps all exit 0 and both runs end `kind 0 exit 1`
([record lines 3315–3351](records/sha256_vectors-native-record-3315-3351.txt)). Both run logs
([root0](records/sha256_vectors-native-run-root0.log), [root1](records/sha256_vectors-native-run-root1.log)) say
`exit 81, expected 7` and `sha256 case 81: got 6bda23f4bb67ae853c6ef372a54ff53a52de900c9b05688c1f83d9ab5be0cd19 want
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`: the first case, the empty message, one padded block.
FULL48 passed this row in G1 and G2 (`steps/witnesses/fix241-20261029/bootstrap.log:718`, `g2-build.log:717`).

## The cause

The digest is the SHA-256 initial value except H0 and H4, which both exceed theirs by `0x01D03D8D`. That is what the
round loop gives when every shift copy and every `e`/`a` argument reads the entry Value 0: each round leaves a = e =
K[i] + W[i] and every other word 0. (W[63] was not computed separately.) The row's L1 (`W/p.lm1` `846BD3D9…`, by full99
G1 `l2trans` 06053912) shows the route; [windows](records/l1-full99-sha_block.txt) of its method `l2_m8` = `sha_block`:
- the line's native methods receive inputs as walk Values and keep each cached own field as a payload `l2_qK` plus a
  working Value `l2_wvK`, loaded at entry;
- `a: h[0]` (:10553) and `e: d + t1` (:14655) write only `l2_qK` and its dirty mark;
- `sha_rotr(e, 6)` passes a copy of `l2_wv10_e` as its argument (:13623–13624), and `hh: g` stores the Value
  `l2_wv12_g` into `hh` (:14548–14575);
- publication reads the payload (`lmx_publish_unsigned(…, l2_pt[5] = @ l2_q6_a …)`, :270).

FULL48's L1 of the same row ([windows](records/l1-full48-sha_block.txt); its G1 and G2 `p.lm1` are one file,
`35F97B65…`) has native typed parameters and `l2_q13_hh: (l2_q12_g)`, `l2_q10_e: (l2_q9_d + l2_q16_t1)`. The Value
channel is new in the line.

In the stage's Lower (`l2_frontend_lower.lm2` `99605615…`):
- `lm_compiler_own_load_context_full`, cached branch (:2217–2241), takes the payload and forwards `c.memcpy(@ l2_cvT,
  @ l2_wvK)` (:2233) as the full Value;
- `lm_compiler_own_work_store_value` (:2379–2389) stores a Value and copies it into `l2_wvK`;
- the pointer arm of `lm_compiler_own_work_store_context` hands `(@ l2_wvK)` to the cell store as owner
  (`lmx_value_cell_store` → `lmx_value_cell_fill`, `lmx_value_owned.lm2:480–517`, which gives a non-companion owner the
  stored context);
- its number and char arms (:2319–2322) wrote only `l2_qK: (val)` and `l2_qK_dirty: 1`.

`lm_compiler_emit_work_decl` (`l2_frontend_core.lm2:4057–4129`) declares the payload, the Value and the dirty mark of
every cached own field together. The address of a numeric own field in a non-machine method is its cell
(`lm_compiler_own_addr` :2458–2467), so the context store is the only other native writer of `l2_qK`. This is a semantic
defect of the target source, so 1F374773 is not landed.

## The fixed point: full99 G1 against quick98 G2

[fixedpoint.command](records/fixedpoint.command) joins every `<sha256>  <path>` line of `pins/full99.log` (G1) and of
`Q/g2-build.log` (G2), the stage prefix removed and the generation directory written GEN
([table](records/fixedpoint-full99g1-quick98g2.txt)). Results:
- all 242 paths full99 hashed are hashed by quick98's G2, and 240 of them are raw-equal: every generated module L1,
  `frontend-source.lm1`, `backend-source.lm1`, `frontend.c`, `backend.c`, `l2_libc.c` and `.o`, the 37 + 83
  regenerated headers, the runtime's `driver.c`, `driver.o` 40B84ECF and `driver-observe.o` 16A0C54A;
- the two others are the images: `l2trans.exe` 06053912 vs 8E56C1F3 (1543068 bytes each) and `l1trans.exe` 4353BE94 vs
  6C880975 (479146). In each pair the only differing bytes are 136–137 and 216–217
  ([cmp](records/pe-cmp-full99g1-quick98g2.txt)); with e_lfanew 128 and a PE32+ optional header at 152, they are the
  COFF TimeDateStamp and the CheckSum;
- the 6 paths only quick98 G2 has are its tool's, which full99 never reached.

So quick98's G2 translator, without the 1640 typed-0 stores of slice249, generated exactly the frontend and runtime
bytes its G1 translator generated. This observes, for these 159 sources, the next-generation result that slice249
left as an inference. It is a fixed point of the old source's translation only: full99 is not a successful FULL, and
nothing of it transfers to a changed Lower. The tool's own G1/G2 comparison remains quick98's.

## The fix: coherent100

`P/variants/coherent100/src/l2src/l2_frontend_lower.lm2` `47EF085E…` (base coherent94 `99605615…`;
[diff](coherent100.diff)), one hunk in `lm_compiler_own_work_store_context`, non-machine branch:
1. the number or char store as before;
2. then the existing packer `lm_compiler_emit_call_value_record(value_ft_of_own(ty), 0, l2_qK, -1, ind, "(@ l2_wvK)")`.
   It emits `lmx_walk_value_num`, which clears the record and makes it a present NUMBER of the field's type. Every own
   number type maps to a value type that `lm_compiler_emit_input_value_type` accepts (int 0, char 1, size_t 2,
   unsigned 34, ulong 36);
3. its open failure arm closed by `return: 0` / `---`, as `lm_compiler_emit_material_value_full` closes it;
4. then the dirty mark.

The machine branch (frontend, kernel, tool) is unchanged. No function, export or header changes, and no test or tool
of the stage pins the old store text. In the row's L1 every context store (`_dirty: 1`) is in a native method body
(`l2_mN`), where a noted walk failure returns 0. Codex: the hunk "follows the right producer boundary"
([pointer answer](records/CODEX-OPUS-250-POINTER-20261101-ANSWER01.txt), line 20).

## full100

`pins/full100-prepare.command` ([record](records/full100-prepare.command), [terminal](records/full100-prepare.terminal.txt);
tool `7FD2E824…`): 15:47:16 → 15:47:17Z, seven steps exit 0. It makes a fresh source-only stage cold-full100 =
source-candidate94 plus coherent100's Lower (`pins/candidate100-coherent.list`). `source-full100.sha256` = `AA841167…`
(159 inputs); exactly one line differs from `1F374773…`: the Lower `99605615…` → `47EF085E…`.

[full100.command](records/full100.command): the same G0, previous frontend and BASE as full99, label full100;
launcher [full100-detached](records/full100-detached.command), 15:47:52Z. The chain is launcher pwsh 14352 → pwsh 8060
→ timeout 11788/3340 → `lmxtool.exe` 9196 → `l2trans` 9796; StartUTC 15:47:53.73Z, PreVMKiB 11037332 (free physical
8280 MB, free virtual 10828 MB). STARTED was reported in [RESULT250](records/OPUS-CODEX-RESULT250-20261101T1550Z.md) §5.

Result: STARTED; this section is completed at full100's terminal.

## The working-place sibling (OPEN)

RESULT250 §6 asked about pointers. Codex ([answer](records/CODEX-OPUS-250-POINTER-20261101-ANSWER01.txt)) confirms
the source route: a pointer context store gives the non-companion owner `l2_wvK` only the stored context (model,
references, referent), and a whole-Value read forwards `l2_wvK` with its entry present/kind/ref. A consumer that
rebuilds the reference from the payload hides this: the reads found here do (`hex[…]`, `check(a, …)`), an own copy does
not. The rest of the answer:
- keep full100 unchanged;
- record the gap OPEN now;
- run one small witness as the next serial step after full100;
- repair only if it fails, at the working own assignment producer: after a successful store, the payload and the whole
  working Value are coherent (present, REFERENCE, field type, committed ref, the store's context); a failed store
  blesses nothing; absence stays absence and a stored null is a present null;
- leave `lmx_value_cell_fill` and its non-companion semantics alone (norm470).

Prepared, not yet run (P, ignored):
- the witness `variants/working-pointer101/unit_pointer_context_copy.lm2` `30EA66CE…`
  ([copy](records/unit_pointer_context_copy.lm2)) and its list `pins/pointer-copy101.tsv` `53E12702…`
  ([copy](records/pointer-copy101.tsv); `runs … 7 nf`). It checks a pointer own reassigned by a literal and by a
  pointer step, then copied (`y: x`) and passed as an argument. It also checks a number formal and a pointer formal,
  assigned and then copied into an own. In a non-machine method a formal's assignment goes through
  `lm_compiler_emit_native_input_store` (:7815): it snapshots the RHS Value and stores it into the input's place
  (`lmx_walk_values_arg_place`), which both formal read routes (`lm_compiler_emit_native_input_read`) load. Only
  machine methods and exact C by-value formals use the plain `l2_pK: value` of `lm_compiler_formal_store_context`. So
  the formal cases are expected to hold, and they bound the gap to owns. Exit 7 = all hold; 81/91/101/111 name the
  case;
- [`pins/red101.command`](records/red101.command): the red side with source-full100's own frontend and runtime (full100
  G2), nothing rebuilt;
- the draft repair `variants/coherent101` (base coherent100, [diff](coherent101-draft.diff)):
  `lm_compiler_emit_pointer_cell_store` gains one optional
  success statement, emitted in an `else:` arm of the store. The other three callers pass 0, so their text is
  unchanged. The own store passes `lmx_walk_value_ref_context((@ l2_wvK), TYPE, (cast: (@: void) l2_qK), (@ l2_wvK))`;
  the packer saves the context before it writes, so the aliasing is safe. It applies to non-slot pointer fields only,
  and it is staged only if the red side fails.

source-full100 is not claimed coherent for pointers or formals.

## Correction to slice249's notes

Slice249's notes said "the bootstrap's G1 runs the code every check of slices 247/248 ran". That holds for the frontend
only: those checks ran on RT92's runtime `0728B3EB…`, the boot's runtime is `40B84ECF…`. The sentence now reads "the
bootstrap's G1 frontend runs FE94's code, the frontend every check of slices 247/248 ran with (narrowed in slice250:
those checks ran on RT92's runtime; their run results stay RT92's)".

## Boundaries

- No landing: `selfbuild/` and the published package are unchanged, and the working tool for checks stays boot89's
  `7FD2E824…`.
- full99 is a failed FULL of the old source; its fixed point is a statement about that source's translation, not
  about full100's.
- The working-place sibling is OPEN until the witness runs.
- Left as in slice248: the raw index place and the deref-word route; the unused `pc102_write` prototype.
- The mail §8a/T01–T26 work has not started.

## Evidence and checks

[evidence.list](evidence.list) names the originals under P that these notes cite:
- the prepare, bootstrap and launcher records with their logs and terminals, and the source manifests;
- the stage's list, test, SHA module and tool sources (`suite.lm2`, `build.lm2`), and the stage's Lower, core, values,
  helpers, useplan, walk-values and value-owned modules;
- the failing row's named outputs (`p.lm1`, `p.c`, `p-prod.exe`, both run logs) and the suite record;
- G1's frontend and runtime outputs, quick98's G2 log and frontend images, and FULL48's L1 of the row;
- the coherent100 variant and the full100 stage records;
- the witness and the draft coherent101;
- RESULT249, RESULT250 and Codex's two answers.

`records/` holds LF copies (trailing blanks removed); [coherent100.diff](coherent100.diff) is `diff -U0` of
`P/cold-candidate94/src/l2src/l2_frontend_lower.lm2` → the variant, labelled `a/`/`b/`.

# Slice 257 (2026-11-02): P1-RET of the optimization line -- the result place admits every value through the one receive (tp119, boot119a)

Writer/build: fable_pc (Opus waits; Codex coordinates, no ACK gate).  Previous slice: [256](../fix256-20261102/notes.md)
(B2b-1: the consumers of a runtime-typed value, landed 82fc7a19; RESULT TP118 sent 13:15Z).  Design:
`optimization_design_from_fable.md` revision 17 (the P1-RET paragraph of §4.5 «Реализация B2b-1», the header note).

## Codex's finding (lmx_uds, the answer to FABLE-RESULT-TP118, 2026-11-02 ~13:25Z, verbatim; the whole answer is archived in the slice-256 notes)

> Новый P1-RET по actual selfbuild lmx_walk_values: 5230–5233: NUMBER&&reference_witness возвращает OK для ЛЮБОГО числа, не только подтверждённого typed-null; REFERENCE&&reference_witness=0 также возвращает OK (даже при известном типе). Поэтому runtime free quote с ненулевым числом -> объявленный pointer RET и pointer quote -> объявленный int RET обходят lmx_walk_value_receive, тогда как native receive возвращает named convert; ошибка может всплыть позднее у caller или остаться пропущенной. Это реальная дельта кода, не старое закрытое A/B1 замечание. Для известного result contract проведи все actual NUMBER/REFERENCE через общий receive; если есть действительное null-правило, его точное условие должно быть общей kernel semantics обоих путей, не blanket OK. Добавь малый focused witness обоих несовместимых направлений с catch:convert в callee/caller; текущий positive pick проверяет только совместимую ссылку. Codex тесты не запускал, finding из кода. Не объявлять reference RET целиком закрытым до исправления; safe независимые шаги продолжать, историю опубликованного среза не reset.

## The step

The P1-RET fix first, as a small slice of its own, before B2b-2 (now slice 258: FREE own cells, the machine operators, the
runtime-typed deref/address of a free pointer) and B2b-3 (259: the closures).  The facts read before the change: the walked
graph's null literal where a reference is declared is a **typed pointer cell** (`lm_compiler_rw_reference_span`: a
`LMX_WALK_OP_LIT` frame storing `lmx_pointer_new_profiled(<the place's pointer code>, …)`; the walker's `lmx_walk_value_cell`
loads it as a REFERENCE of that pointer code), so no number ever stands where a reference is declared and no "number into
reference" exception exists -- none is written; `lmx_walk_value_receive` already answers a typed number into a pointer witness
and a reference into a numeric witness with `LMX_WALK_THROWN + LMX_WALK_NAME_CONVERT` (a base-type mismatch after `adopt`).
The frontend modules of this slice: `l2_frontend_emit` (the receiving check), `l2_frontend_lower` (the native reference
receive); the kernel: `lmx_walk_values` (the result place).  `tools/build.lm2` unchanged: boot118a's G2 working tool
`3E5F1A18…` is the tool of every step and the G0 of the bootstrap; the previous frontend is boot118a's G2 `2A279AE6…`.

### What the slice changes

- **Kernel** (`lmx_walk_result_receive`): the two blanket passes are gone -- a NUMBER into a reference witness and a REFERENCE
  into a numeric witness (or without a type) no longer return OK before the receive; every present NUMBER or REFERENCE value
  of a code with a readable one-witness return part goes through `lmx_walk_value_receive` with the witness type; a mismatch is
  the implicit `convert` raised at the RET (the callee's pads first, then the caller's).  A code without a static witness
  (`LMX_TYPE_NONE`) receives nothing, as before.
- **emit** (`lm_compiler_check_value_convert_span`): a runtime-typed value (kind -20) where a pointer is declared is not
  compared statically -- the free name's lexical default (int) was refused against the pointer result ("assignment value has
  incompatible type"); its type is its binding's value type, admitted by the runtime receive.
- **lower** (`lm_compiler_emit_reference_receive_span_full`): a span of kind -20 received by a pointer place without a
  receiving model goes through `lm_compiler_emit_dyn_receive_full` -- `lmx_walk_value_receive(record, <the place's pointer
  code>, @ l2_rvN)`, the implicit `convert` on a mismatch, the typed view `(cast: (@: T) l2_rvN.ref)` -- as a numeric place
  receives it (slice 255); a place with a receiving model keeps its admission path (B2b-2).
- **Fixture** `tests/dyn/free_result_convert.lm2` (`runs … 7 nf`): `as_pointer () @: int: return: quote`, `as_int () int:
  return: quote`, `nothing () @: int: return: 0`, `as_pointer_pad` / `as_int_pad` (the same returns inside a `---` pad with
  `catch: convert ()` setting a local flag; the callee then returns `@ other` / 99 -- values only the handler's path produces);
  `outer_number` binds `int: quote 5` and checks the int result (5), the caller-caught `convert` of the pointer result (`got` 1,
  `q` null), the callee-caught one (`\q` = 2), the int pad's compatible return (5); `outer_pointer` binds `@: quote int 0;
  quote: @ marks` and checks the compatible pointer result (`\q` = 1), the caller-caught `convert` of the int result (`got` 2),
  the callee-caught one (99), the pad's compatible pointer (`\q` = 1), the typed null literal (`nothing()` = 0).  Entry 7;
  81..93 name the failing check.  Found by the fixture: a handler's bare write to a free name (the root global `pads`) is
  activation-local (Q52) -- not a channel to the caller; the sentinel returns replaced it.

## The candidate's records (P = build2/codex_fix250generationchain01)

| record | what | result |
|---|---|---|
| `pins/tp119-prepare.command` ([record](records/tp119-prepare.command), [terminal](records/tp119-prepare.terminal.txt)) | the fresh stage cold-tp119 = selfbuild (source-tp118 `1016F41D…`) + the 3 files of `pins/tp119-changed.list` (the kernel module, the fixture, full-suite.tsv); the variant's inputs.list (163 lines) names the fixture | 6 steps exit 0 (13:42:00Z); source-tp119 `1f7b4d61…` (the first candidate), changed `b44f7618…` |
| `pins/tp119-reuse.command` ([record](records/tp119-reuse.command)) | the 232 generated inputs of boot118a's stage into cold-tp119 (the names of tp118-reuse.list) | 5 steps exit 0 (13:42:02Z); manifests `ac4222d5…` equal |
| `pins/tp119-rt.command` (rt119, TP_TRY 01; [record](records/tp119-rt.command), [terminal](records/tp119-rt-01.terminal.txt)) | the isolated runtime build with the working tool and boot118a's G2 frontend (`lmx_walk_values.lm2` `3e9f0d71…`) | exit 0 (13:42:18-13:43:15Z); driver.o `83295baf…`, driver-observe.o `eaeb5f99…` |
| `pins/tp119-suite.command` (rt119, TP_TRY 01; the frontend = boot118a's G2 `2a279ae6…`, the frontend sources being unchanged; list `pins/focus119.tsv` = focus118 + the witness; [record](records/tp119-suite.command), [terminal](records/tp119-suite-01.terminal.txt)) | the focus list | **exit 1, SUITE 7 rows, 2 failures**: the six rows of focus118 pass in both modes; the witness refuses at translation in both: `free_result_convert.lm2:13:13: assignment value has incompatible type, atom=quote` -- `return: quote` where `@: int` is declared, the free name's lexical default (int) compared statically with the pointer result (`lm_compiler_check_value_convert_span` → `check_receiving_types`).  Fix01: the check admits kind -20 at a pointer place; the native reference receive routes a kind -20 span through `emit_dyn_receive_full` |
| `pins/tp119-prepare-fix01.command` (TP_TRY fix01; the 5-line `pins/tp119-changed-fix01.list`; [record](records/tp119-prepare-fix01.command)) | the changed set over the stage | 4 steps exit 0 (13:50:40Z); source-tp119 `e4cec65a…` |
| `pins/tp119-fe.command` (fe119, TP_TRY 01; [record](records/tp119-fe.command), [terminal](records/tp119-fe-01.terminal.txt)) | the isolated frontend build (lower `f606f354…`) | exit 0 (13:50:55-13:57:04Z); l2trans `dfdec5c9…` |
| `pins/tp119-suite2.command` (fe119, rt119, TP_TRY 02; [record](records/tp119-suite2.command), [terminal](records/tp119-suite-02.terminal.txt)) | the focus list on the isolated builds | **exit 1, 4 failures**: the witness builds in both modes and exits **85** in both -- `pads != 1` after the callee's pad caught the `convert`: the handler's `pads: pads + 1` is a bare write to a free name (the root global's lexical default), activation-local by Q52, so the caller read 0.  The compiler was right; fix02 is the fixture: the handler sets a local flag, the callee returns a sentinel (`@ other`, 99) |
| `pins/tp119-prepare-fix01.command` (fix02); `pins/tp119-suite2.command` (fe119, rt119, TP_TRY 03; [terminal](records/tp119-suite-03.terminal.txt)) | re-stage (the fixture only; source-tp119 `900ab284…`); the focus list | **exit 0, SUITE 7 rows, 0 failures** (13:59:32-14:00:12Z): the twins, os_walk_values, free_name_chain, free_value_types, free_value_consumers and the witness free_result_convert in both modes |
| `pins/tp119-obs2.command` (fe119, rt119, TP_TRY 01, TP_SOURCE dyn/free_result_convert.lm2, TP_SPEC m=1; [record](records/tp119-obs2.command), [terminal](records/tp119-obs-01.terminal.txt), [log](records/tp119-obs-obs119-01-forced-run-obs-root0.log)) | the observed walk of the witness | exit 0 (14:00:47Z): the forced program walks all eight bodies -- `as_int`, `as_int_pad`, `as_pointer`, `as_pointer_pad` twice each, `nothing`, `outer_number`, `outer_pointer`, `m` once -- and exits 7: both incompatible directions were raised by `lmx_walk_result_receive` in the walker and caught by the callee's and the caller's pads; the compatible pointer, int and null results passed the receive |

## boot119a, the fixed point, the focus suite on G2, the landing

| record | what | result |
|---|---|---|
| `pins/boot119-prepare.command` (TP_TRY a; [record](records/boot119-prepare.command), [terminal](records/boot119a-prepare.terminal.txt)) | the fresh source-only stage cold-boot119a with exactly source-tp119's 163 inputs (verify, stage-copy, manifest, verify by boot118a's G2 working tool) | 4 steps exit 0 (14:01:22Z); `source-boot119a.sha256` = `source-tp119.sha256` = `900ab284…` |
| `pins/boot119-quick.command` through `pins/boot119-detached.command` (TP_TRY a; [record](records/boot119-quick.command), [terminal](records/boot119a-quick.terminal.txt), [log](records/boot119a-quick.log)) | the whole short bootstrap: G0 = boot118a's G2 working tool (`3e5f1a18…`; tools/build.lm2 unchanged), BASE full48/g2/frontend, the previous frontend = boot118a's G2 (`2a279ae6…`); runtime, frontend, the smoke list, G1 built by G0, G2 built by G1, the working binary | **exit 0**, 14:01:25 → 14:20:25Z (1140 s): `SUITE 9 rows, 0 failures`, `PASS bootstrap: G0 builds and tests whole G1`, `PASS bootstrap: actual G1 builds and tests whole G2`, `PASS G1: the tested whole bundle is working`, `PASS G2: the tested whole bundle is working`, `BOOTSTRAP quick 0 failures`; G1 l2trans `46b20f26…`, G2 l2trans `1249db48…`; driver.o `83295baf…` in both generations -- byte-equal to the isolated rt119's; working tool `quick119a/lmxtool.exe` **`64AE29A0D4E8B2EE22EEC82724BCC410C4A4FFCE906650698B9BE52CCC660D01`** (G2's) |
| `pins/boot119-compare.command` (TP_TRY a; [record](records/boot119-compare.command), [report](records/boot119a-compare.txt)) | G1 and G2 compared from the receipts | `in both 248 raw-equal 245 differ 3 only-G1 0 only-G2 0`; the three PE images (l1trans, l2trans, lmxtool-tool) differ at bytes 136-137 and 216-217 only (the link stamp).  The fixed point G1 = G2 holds |
| `pins/tp119-suite-g2.command` ([record](records/tp119-suite-g2.command), [terminal](records/tp119-suite-g2.terminal.txt)) | the focus list on boot119a's G2 frontend and G2 runtime objects, run by the promoted working tool from cold-boot119a | **exit 0, SUITE 7 rows, 0 failures** (14:21:44-14:22:25Z; tool `64ae29a0…`, fe `1249db48…`, prod `83295baf…`): the twins, os_walk_values, free_name_chain, free_value_types, free_value_consumers and the witness free_result_convert in both modes |
| `pins/land257.command` ([record](records/land257.command), [terminal](records/land257.terminal.txt)) | the landing of source-tp119 into the tracked `selfbuild/` by the rule of Codex's answer to FABLE-RESULT-S3 (the whole tested set after the actual quick PASS): verify in cold-boot119a, stage-copy over selfbuild/, the variant's `inputs.list` (163 lines) by a one-line manifest, the package manifest rewritten and verified, the 65 sources of G1's and G2's consumed-input snapshots verified against the landed files | 8 steps exit 0 (14:22:26-14:22:29Z); `selfbuild/inputs.sha256` `900AB2840A04C4DBDF7E616A0246C035AE82933C848C80DA0FF1089C42C82321` = `source-tp119.sha256` |

The package: `selfbuild/` = source-tp119 -- the landed source-tp118 with the 4 changed files of tp119 (`src/l2src/lmx_walk_values.lm2`,
`l2_frontend_emit.lm2`, `l2_frontend_lower.lm2`, `tests/full-suite.tsv`) and the new fixture `tests/dyn/free_result_convert.lm2`;
`selfbuild/README.md` names the snapshot, `steps/current.md` gets the slice-257 entry.

The reference RET is now closed in the stated scope: every present NUMBER or REFERENCE value of a known result contract goes through
the one receive, both incompatible directions witnessed with the callee's and the caller's `catch: convert ()`.  Outside it, as before:
a free value received by a place with a receiving model (B2b-2), and the native receive of a free value by non-return pointer places
other than the span-level reference receive (the same divert serves assignments through `emit_reference_receive_span_full`; not
witnessed here).

## What B2b still owes (the next slices)

- **B2b-2 (slice 258):** FREE-typed own cells (`twice: quote + quote` without a type word -- an `LmxWalkValue` record in the native
  code; the walker's working row without a type, typed by its first value) and the machine (bitwise, shift) operators over a
  free operand (a shared kernel operation with the C99 promotions, as `lmx_walk_value_bin`); the deref `\x` and the address
  `@ x` of a free pointer by Codex's norm (the kernel derives the pointee type from the actual pointer type/descriptor at the
  reached deref and gives an `LmxWalkPlace`, `lmx_walk_value_deref_place`; `@x` is the address of the real place with its actual
  type/depth, norm 470; an opaque `void*` keeps the existing runtime refusal or an explicit contract/cast); a free value received
  by a modelled reference place (`implements` at the reception).
- **B2b-3 (slice 259):** the closures -- no forwarding of a callee's free input to its callers (`dyn_site_callee` /
  `dyn_site_held`), no static typing of free names, the translation refusal "unbound dynamic input" replaced by the runtime
  inadmissibility of the call (book :727/:777), the `wait_*` / `note_call` / `dyk` paths for free names removed as dead.

## Evidence and the docs check

`pins/docs257.command` ([record](records/docs257.command)): the raw manifest of the 149 listed originals under P
(`evidence.list` → `evidence.sha256`) and its verify, exit 0 (14:24:08Z).  Commit `862a8244` «Land the boot119a-tested tp119
result-place admission in selfbuild (slice257)».  `pins/docs257-check.command` ([record](records/docs257-check.command)): the
ordinary full docs check with the slice files in the Git index, exit 0 (14:24:50-14:25:19Z): `OK: 35 paired semantic chapters,
14 implements cases, both source snapshots; 27 paired grammar sections, 44 verbatim source excerpts, 615 imported files,
links, exact semantic opening; line endings LF`.

## Codex's confirmation (lmx_uds, 2026-11-02 ~14:25Z, during the docs check, verbatim)

> P1-RET ЗАКРЫТ в заявленном объёме actual NUMBER/REFERENCE при известном result contract. Codex прочитал frozen cold-boot119a: walk_values SHA 3e9f0d71, remove blanket OK, общий receive; native lower 16122→emit_dyn_receive_full и emit check_value_convert_span kind-20 без статического сравнения. Прочитал frozen fixture 958c344f: оба несовместимых направления, catch у callee через проверяемые sentinel и у caller, compatible пары и typed null nothing. Сам compiler/tests не запускал.
>
> Independently подтвердил tp119-suite-03 7/0 и новый G2 tp119-suite-g2: End 14:22:25.5898662Z SuiteExit 0, free_result_convert native/forced root0/root1=7, SUITE 7/0. boot119a actual exit 0 14:01:25.213→14:20:25.545Z, 1140.33 s; whole G1 и actual G1→G2, smoke 9/0 каждый; producer records frontend/runtime/tool 33/39/6 exits каждый все 0. Actual все inventory 248/248 сверены: 0 stale, 245 raw-equal/3 PE лишь TimeDateStamp/CheckSum. Source 900AB284 frozen stage 163/0 и selfbuild 163/0, land 2578 steps 0 прочитаны. Docs257/push на последнем чтении ещё не подтверждены — обычное завершение среза твоим pipeline без ACK, не новый gate.
>
> Дельта rev17 SHA 204395cb83d5e53bba0111bd01f4e1a8866f1582297b06f135603a3fe222055d повторно совпала, прежние A/B1 findings не открываются. После обычного завершения 257 продолжай обязательные B2b-2 (теперь 258)/B2b-3 (259): FREE own cells, bit/shift, runtime-typed deref/address, actual model admission и removal closures. C только после реального завершения B2. Opus ждёт, нового ACK/автора/дизайн-цикла не требуется. Не повторять уже зелёные прогоны.

Taken: the slice closes in the ordinary way (docs records, push, RESULT); B2b-2 is slice 258 (FREE own cells, bit/shift, the
runtime-typed deref/address, the actual model admission) and B2b-3 slice 259 (the closures); C only after B2 is really done;
no green run is repeated.

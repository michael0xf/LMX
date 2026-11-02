# Slice252 — tp113: the method-name index (S3b), built and measured on the landed package

Base main/origin `2c7ec075` (slice251: S1–S3 landed as source-tp112, boot112 G1 = G2). fable_pc sole writer/build; Codex
consults; Opus waits. R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`. Every tool CLI from a fresh
private CWD; long runs through detached launcher records; one pipeline.

## What tp113 changes

Target: the fe112 Emit sample (`lm_compiler_text_same` under `lm_compiler_site_method` from `scan_ident`) and the
`find_method` scans — both linear over the `l2_m_n` method rows per call. Sources `P/variants/tp113` = `variants/tp112` +
G1's `l2_frontend_emit.lm2`, patched by `tp113_patch.py` (slice251 notes, "tp113 (S3b)" for the census of the writers):
- `l2_frontend_context.lm2`: `lm_compiler_site_method` walks the chain of `t`'s bucket (`lm_compiler_mix_first/step`),
  same `text_same`/`method_visible_at` filters and selection, row order; `-2` (allocation failure) → the old scan;
  helpers `lm_compiler_mix_hash/insert/sync/first/step` appended (internal).
- `l2_frontend_values.lm2`: `lm_compiler_find_method` over `lm_compiler_vmix_*` (the values copy of the five helpers).
- `l2_frontend_core.lm2`: `lm_compiler_meth_free` bumps `l2_m_gen`; `l2_frontend_emit.lm2`: the per-unit reset in
  `lm_compiler_translate_unit` bumps it before `l2_m_n` returns to 0.
- `tools/build.lm2`: +8 cells (`l2_m_gen`, `l2_mix_n/cap/rows/gen`, `l2_mix_bucket/tail/next`; 57 in all).
Hashes (source-tp113 `3EF3C94D…`): context `F6704B7C…`, values `BAF941CA…`, core `67BF35DB…`, emit `B839DBA3…`,
build.lm2 `6BD2DBF4…`.

## Stage, self-checks (slice251, 01:13–01:19Z)

`pins/tp113-prepare.command`: cold-tp113 = source-full100 + the nine tp113 files, 233 reused generated inputs from
cold-tp112 (18 manifest differences, 10 steps exit 0). `pins/tp113-selfcheck.command` (fe112 standalone, G1's record
argv): context 0.8 s, values 0.7 s, core 105.7 s, emit 156.6 s — exit 0, all four headers byte-equal to G1, bodies new
(`pins/tp113-selfcheck-*-01.terminal.txt`).

## tool113, fe113, measurements

tool113 (`pins/tp113-tool.command` through `tp113-tool-detached.command`, frozen tool `E8150E60`, G1 full100's frontend
`BF6D713E…` and runtime objects): 01:23:37–01:44:07Z, `RebuildExit 0`, `REBUILD tool 0 failures` (smoke 9 rows);
`cold-tp113/tool113/lmxtool-tool.exe` `10257E58…` (1842914 bytes), `lmxtool.lm1` `6AAFCE16…`, `lmxtool.c` `928A1692…`.
fe113 (`pins/tp113-frontend-part.command` + detached, host tool113, producer fe112 `46F3A974…`, parts context, values,
core, emit; reuse 233 inputs / ABI 233 artifacts verified before and after, `VERIFIED 233 files, 0 failed` x3):
01:44:54–01:50:16Z, `PartExit 0`; `cold-tp113/fe113/l2trans.exe` `6038F156…` (1561921 bytes), `l1trans.exe` `D9F88C39…`,
`l2_libc.o` `AF9FDAE3…`, `frontend.c` `672F66C5…` (10216601 bytes), `l2_frontend_state.lm1` `A331CF51…` (17733 bytes, 57
cells). The four regenerated bodies are byte-equal to the standalone self-check outputs (context `EC7B97F2…`, values
`4A3BBCBB…`, core `142DEEEF…`, emit `155B52C1…`); the four headers are G1's.

## Measurements (pins/tp110-measure.command, tree P/tp110-tree-01/src, argv of G1's record lines 193/205/241/253)

Try 01 of each module with fe113 ran with gdb stack sampling (3 Lower, 3 Core, 4 Emit attaches of about a second each;
kernel CPU 1.2–1.7 s against 0.3 s without): useplan 6.6 s (fe111 7.9), Lower 100.0 s (fe112 95.9), Core 121.3 s (fe112
106.4), Emit 141.8 s (fe112 133.5); every output byte-equal to G1. Slower than fe112 in all three long modules, more
than the attaches explain in Core — so Lower, Core and Emit are measured again without sampling, fe113 and fe112 back
to back (tries fe113-02 / fe112-04, fe113-02 / fe112-03, fe113-02 / fe112-02), 01:58–02:12Z, no sampling:

| module | fe113 wall s (cpu user) | fe112 wall s (cpu user), run right after | fe113 / fe112 | peak WS MiB fe113 / fe112 | outputs |
|---|---|---|---|---|---|
| l2_frontend_lower | 94.6 (93.3) | 111.7 (111.1) | 0.85 | 324.4 / 324.3 | both same-as-G1, both runs |
| l2_frontend_core | 122.4 (121.7) | 135.9 (135.1) | 0.90 | 367.5 / 367.5 | both same-as-G1, both runs |
| l2_frontend_emit | 154.4 (153.5) | 165.4 (164.4) | 0.93 | 293.1 / 292.4 | both same-as-G1, both runs |

The method-name index saves 7–15 percent of each module's translation. The machine itself is slower in this hour than at
00:42Z (fe112's Lower: 95.9 s then, 111.7 s now, the same binary and inputs — the laptop after an hour of back-to-back
builds), so a frontend's time is only comparable with the other frontend's run next to it; from here on each candidate is
measured as such a pair. Peak memory is unchanged (the index is a few hundred KiB).

Stack samples of try 01 (`records/samples/sample-{lower,core,emit}-fe113-*`), one `bt` each:
- 4 of 10 in `lm_compiler_node_in`/`struct_has` under `lm_compiler_contract_source_begin_at` — the owner memo's
  re-check of a remembered owner (`node_in(source, site)`, a walk of the owning method's whole tree per query) from
  `contract_formal` ← `contract_own` ← `is_asgn` ← `scan_body` ← `dyn_local`, and from `typed_formal` ←
  `collect_method_body` (lower-01, core-02, emit-01, emit-02);
- 2 in `lm_compiler_predef_file_define` (`text_eq` over every `define`/`predef` item of each predef file, recursive
  imports) under `define_name` ← `path_root_select` ← `path_walk` ← `path_resolve_contract` ← `head_is_call` (core-03
  from `node_path_effects_value`, emit-03 from `m2_direct` in `m2_close`);
- 1 in `lm_compiler_predef_file_result_ty` (the same walk over `prototype` items) under `predef_result_ty` ←
  `colon_simple_ty` ← `check_receiving_value_at` ← `colon_check_assignment` ← `check_body` (emit-04);
- 1 in `lm_compiler_source_parent_body` under `method_source_scope` ← `method_duplicate` ← `collect_method_body` (core-01);
- 1 in `lm_compiler_use_fact_find` (linear over `l2_path_facts`) under `use_receiver` ← `check_call_arguments` (lower-02);
- 1 in `lm_compiler_path_fact_note_bytes` under `path_walk_selected` in emission (lower-03).
None in `site_method`/`find_method`: the method-name index removed that class from the samples.

## tp114 (S3c): three exact replacements from the fe113 samples — sources and records written

`variants/tp114` = `variants/tp113` + G1's `l2_frontend_resolve.lm2` (unchanged, `25769A60…`), patched by `tp114_patch.py`:
- `l2_frontend_context.lm2`: `lm_compiler_contract_source_begin_at` trusts the owner memo's entry; `lm_compiler_omemo_get`
  empties the memo when the method table's count `l2_m_n` or generation `l2_m_gen` or the document generation `l2_doc_gen`
  changed (cells `l2_omemo_gen`, `l2_omemo_doc_gen`). The tree walk `node_in(source, site)` that tp111 re-checked each
  remembered owner with (4 of the 10 fe113 samples) is gone: an entry is the current owner of the node at that address
  because every document destroy of the frontend bumps `l2_doc_gen` (the only path that frees P0 nodes — the frontend's
  P0 API use is document_root x24, document_destroy x22, parse_bytes x3, parse_string x1, mutable_root x1, diagnostics).
- `l2_frontend_core.lm2` (8 sites), `l2_frontend_emit.lm2` (12), `l2_frontend_types.lm2` (1), `l2_frontend_values.lm2`
  (1): `c.lm_p0_document_destroy(` → `lm_compiler_<module>_doc_destroy(`, an internal helper per module that bumps
  `l2_doc_gen` and destroys; emit's `lm_compiler_snap_free` uses `lm_compiler_emit_snap_destroy`, which also bumps
  `l2_snap_gen`. core's `lm_compiler_bound_free` bumps `l2_pf_gen` where it frees the path-fact list.
- `l2_frontend_types.lm2`: the predef file index `lm_compiler_pfx_*` — for each snap document first asked about, its root
  items as rows in document order (kind 1 `define` with a body, kind 2 `fn`/`sub` declaration inside a `prototype` frame,
  kind 3 `predef` item), bucketed by (document, name bytes), predef rows by the document; `lm_compiler_predef_file_define`
  and `lm_compiler_predef_file_result_ty` merge the name's chain and the predef chain by row ordinal
  (`lm_compiler_pfx_define`, `lm_compiler_pfx_result_ty`), so they meet the same items in the same order and recurse into
  the same imports at the same points as the scan of every root item, which stays as the path when the index could not be
  built (allocation failure drops the whole index). Valid per `l2_snap_gen`.
- `l2_frontend_values.lm2`: the fact index `lm_compiler_pfi_*` behind `lm_compiler_use_fact_find` — the appended
  `l2_path_facts` list as rows, bucketed by (method, source node), built incrementally from the last indexed fact
  (`l2_pfi_last`), valid per `l2_pf_gen`; the reader keeps its predicate and its two-matches rule; `-2` → the list walk.
- `tools/build.lm2`: +28 cells (85 in all).
Records `pins/tp114-*` (prepare: cold-tp114 from source-full100 + nine files, 232 reused inputs from cold-tp113; tool114;
fe114 = fe113 translating types, values, context, core, emit; selfcheck by fe113), written, run after the tp113
measurements.

## Codex, read-only monitoring (relayed by lmx_uds, 2026-11-02 about 02:15Z)

Relayed text, kept verbatim:

> Read-only мониторинг: продолжаешь tp114, формальной остановки нет, ревью/автора не жди. Нашёл конкретный лишний расход
> времени: pins/tp113-tool.command строки 4/10/11/31 всё ещё задают host cold-full100/full100/lmxtool.exe и producer
> cold-full100/full100/g1/frontend/l2trans.exe (BF6D713E); tool113 поэтому строился старым медленным frontend, несмотря на
> опубликованный boot112. Завершённый tool113 НЕ пересобирать, текущий paired measurement сохранить.
>
> Для СЛЕДУЮЩЕГО tool build используй уже проверенный coherent boot112 G2 bundle как быстрый предыдущий producer:
> P/cold-boot112/quick112/g2/frontend/l2trans.exe (6A66B24E…, exact hash в его record), matching g2/runtime; host — promoted
> quick112/lmxtool.exe (0E3ACE61…). G1/G2 прошли quick, 248 inventories совпали кроме 3 PE служебных полей, ABI и runtime
> этой линии проверены; это обычный выбор протестированного seed, не новая архитектура. Actual hashes/CWD/reuse/ABI манифесты
> проверяй штатно. BASE старого bootstrap/другие параметры не менять наугад. Обновляй только новые command/pins/records
> следующего кандидата, исторические receipts не переписывать. Если есть конкретная проверенная несовместимость, требующая
> BF6D713E, укажи её обычным вопросом мне; автора/разрешения не ждать.
>
> fe113 try01 slower с gdb не означает регрессию: вижу твой корректный paired repeat без sampling, Lower 94.6 vs fe112 111.7,
> Core 122.4 vs 135.9, Emit ещё заканчивался. Не добавляй широкую кампанию только ради сравнения. Текущий tp114
> C-predef/owner lookup доводи в пределах причинных общих операций; далее приоритет согласованных semantic slices — удаление
> M2/preflight и общий runtime-код, не бесконечная индексация механизмов, назначенных к удалению. Самый быстрый одиночный
> запуск не замена actual корректности. Один writer/pipeline, все вопросы Codex, обычный следующий результат без отдельного ACK.

Applied: `pins/tp114-tool.command` (not yet run) now names host `cold-boot112/quick112/lmxtool.exe` `0E3ACE61…`, frontend
`quick112/g2/frontend/l2trans.exe` `6A66B24E…` and runtime `quick112/g2/runtime` (`driver.o` `40B84ECF…`, `driver-observe.o`
`16A0C54A…`, hashes checked by the record); BASE and the rest unchanged; tool113's record and receipts untouched. After
tp114, the next slices are the agreed semantic ones (M2 and walker preflight removal, the kernel's shared code), not more
indexes of mechanisms slated for removal.

## tp114: stage, self-checks, tool114

`pins/tp114-prepare.command` 02:13Z, 10 steps exit 0 (cold-tp114 = source-full100 + the nine tp114 files, 232 reused inputs
from cold-tp113, 18 manifest differences). Self-checks by fe113 (`pins/tp114-selfcheck-*`): types 0.7 s, context 0.8 s,
core 102.7 s, emit 127.2 s — exit 0, headers byte-equal to G1, bodies new. values was refused twice, both times an actual of
an L2 call written as a bare path: `lm_compiler_pfi_first(mi, first\value)` (1496:34, "assignment value has unknown type,
atom=first") and `lm_compiler_values_doc_destroy(expression\document)` (1786:40, atom=expression) — the C-door call it
replaced took the bare path, an L2 call needs the explicit cast the other call sites use. Fixed in the variant (two casts,
`fact\method` in the fact hash cast too), re-staged through `pins/tp114-prepare-fix01.command` and `-fix02.command`
(stage-copy of the nine files over the stage, manifests recomputed and verified, 18 differences; the fix02 record's final
echo still says `FIX01` — a copied label), self-check try 03 exit 0, header byte-equal to G1 (`records/`). Stage manifest
after fix02: `source-tp114.sha256` = (terminal `after:` line).

tool114 (`pins/tp114-tool.command`, repointed before its run per Codex above: host `quick112/lmxtool.exe` `0E3ACE61…`,
frontend `quick112/g2/frontend/l2trans.exe` `6A66B24E…`, runtime `quick112/g2/runtime`): 02:20:15–02:21:47Z (92 s; tool113
with full100's G1 frontend took 1230 s), `RebuildExit 0`, `REBUILD tool 0 failures`; `cold-tp114/tool114/lmxtool-tool.exe`
`46D20AA9…` (1843426 bytes), `lmxtool.lm1` `1C789C5B…`, `lmxtool.c` `E5FE3EEB…`. fe114 (`pins/tp114-frontend-part.command`,
host tool114, producer fe113 `6038F156…`, parts types, values, context, core, emit; reuse 232 inputs / ABI 232 artifacts
`VERIFIED 232 files, 0 failed` x3): 02:22:16–02:26:49Z, `PartExit 0`; `cold-tp114/fe114/l2trans.exe` `0DB4B5D1…` (1569873
bytes), `l1trans.exe` `2C4D9B0D…`, `l2_libc.o` `AF9FDAE3…`, `frontend.c` `9E1F05FC…` (10292961 bytes),
`l2_frontend_state.lm1` `9431A005…` (18338 bytes, 85 cells). The five regenerated bodies are byte-equal to the self-check
outputs (types `D703FD2A…`, context `8A442B9F…`, values `DFD7F436…`, core `7BC79CD4…`, emit `F4DB8B55…`); the five
headers are G1's.

## tp114 measured: paired with fe113 (02:27–02:40Z, no sampling)

| module | fe114 wall s (cpu user) | fe113 wall s (cpu user), run right after | fe114 / fe113 | peak WS MiB fe114 / fe113 | outputs |
|---|---|---|---|---|---|
| l2_frontend_useplan | 3.1 (3.1) | — (try 01: 6.6) | 0.47 | 79.7 / 79.0 | both same-as-G1 |
| l2_frontend_lower | 70.8 (69.4) | 92.4 (91.6) | 0.77 | 325.7 / 324.3 | both same-as-G1, both runs |
| l2_frontend_core | 74.5 (73.9) | 105.0 (104.2) | 0.71 | 368.8 / 367.4 | both same-as-G1, both runs |
| l2_frontend_emit | 55.5 (55.1) | 129.2 (128.2) | 0.43 | 277.2 / 293.1 | both same-as-G1, both runs |

Every output byte-equal to G1 in all seven runs (`pins/tp110-measure-*-fe114-01.terminal.txt`, `*-fe113-03.terminal.txt`).
The owner memo's re-check and the predef file scans were the bulk of Emit's time; Emit now takes 55.5 s where fe111 took
139.8 s and fe112 133.5 s in their own hours. Chained ratios against the G1 frontend in the same tree (G1 1426.8 s for
Lower; fe112 14.9x at 00:42Z; fe113 0.85 of fe112; fe114 0.77 of fe113): Lower about 23x, with the machine's hour-to-hour
drift as the uncertainty.

Stack samples with fe114 (`records/samples/sample-{lower,emit}-fe114-*`, taken during Lower try 02 (71.8 s) and Emit try 02
(57.0 s), both outputs byte-equal to G1): lower-01 `own_local_at` under `call_alias_own` ← `call_head_method` in the
recursive `bind_node_content`; lower-02 the owner SEARCH of `contract_source_begin_at` (a memo miss: `node_in` over every
method's tree); lower-03 `app_head` ← `root_names_method` ← `unit_names_method` ← `local_absent_def` (a scan of the unit's
names per local); emit-01/02 `head_source_node` misses (`struct_has` over the head-expression documents) under
`own_source_visible` from `own_host_at`/`own_local_at`; emit-03 `path_fact_note_bytes` in `body_path_effects`. The
remaining time is spread over many short lookups; the two miss paths would be one-pass node → owner and node → head-document
maps. Per Codex (above), the indexing stops here: the next slices are the agreed semantic ones.

## boot114: the short bootstrap of the tp110–tp114 sources passed, G1 = G2 apart from the link stamps

`pins/boot114-prepare.command` (frozen tool `E8150E60`, 02:41:05Z, four steps exit 0): fresh source-only stage `cold-boot114`
= exactly `source-tp114.sha256` (159 inputs, `FE3FDA29…`; `source-boot114.sha256` byte-equal to it), no generated input.
`pins/boot114-quick.command` through `boot114-detached.command` (launcher pid 7660): `timeout 172800 tool114 (46D20AA9)
bootstrap quick R P/cold-boot114 P/cold-candidate48/full48/g2/frontend P/cold-tp114/fe114/l2trans.exe (0DB4B5D1) quick114
P/cold-boot114/tests/smoke-kernel225.tsv`, log `pins/boot114-quick.log`. `StartUTC 02:41:07.56Z`, `EndUTC 02:57:16.34Z
BootstrapExit 0` (969 s; boot112 1159 s, boot98 18196 s); `BOOTSTRAP quick 0 failures`; smoke `SUITE 9 rows, 0 failures` in
both generations ([terminal](records/boot114-quick.terminal.txt), [log](records/boot114-quick.log)).

| generation | frontend (l2trans, l1trans) | runtime (driver.o) | tool (lmxtool-tool.exe, lmxtool.lm1) |
|---|---|---|---|
| G1 (by tool114 + fe114) | 02:46:31 `AE4F34A8…`, `8FCD9A69…` (324 s from StartUTC) | 02:47:05 `40B84ECF…` | 02:49:15 `78C04046…`, `CAE8E1E7…` |
| G2 (by the actual G1 tool + G1 frontend) | 02:54:31 `17DFEEA9…`, `93113080…` | 02:55:05 `40B84ECF…` | 02:57:13 `6619A503…`, `CAE8E1E7…` |

The working `quick114/lmxtool.exe` is `6619A503…` (G2's tool); `working-bundle.sha256` is `g2/bundle.sha256` byte for byte
([g1](records/boot114-g1-bundle.txt), [g2](records/boot114-g2-bundle.txt), [g2-record](records/boot114-g2-record.txt)).

`pins/boot114-compare.command` ([output](records/boot114-compare.txt), 02:58:14Z; the boot112 record with the names
changed): 248 receipt paths in both generations, 245 raw-equal (63 `.lm2`, 84 `.h.lm1`, 77 `.lm1`, 13 `.lm1.h`, 5 `.c`, 3
`.o`), the 3 PE images differ at exactly the 4 stamp bytes (136–137, 216–217). `g1`/`g2` `consumed-inputs.sha256` raw-equal
(29713 bytes). fe114's `frontend.c` and G1's are byte-equal (10292961 bytes); fe114's `l2trans.exe`/`l1trans.exe` and G1's
differ only at the same 4 stamp bytes. The fixed point G1 = G2 holds on these sources as on source-tp112.

## The landing: source-tp114 is the selfbuild package

By the rule of Codex's answer to FABLE-RESULT-S3 (the whole tested set after an actual quick PASS, the ordinary
verify/stage-copy/manifest/verify route, only the actually changed sources and the manifest in the commit):
`pins/land252.command` ([record](records/land252.command), [terminal](records/land252.terminal.txt); the land251 record
with the names, the manifest hash `FE3FDA29…` and the tool changed; its final echo still says `LAND251`, a copied label) with
the promoted working tool of boot114 (G2's, `6619A503…`), 02:58:44–02:58:45Z: the two subsets
`land252-g1/g2-consumed-sources.sha256` (65 lines each, identical, every line in `source-tp114.sha256`), then

| step | command | result |
|---|---|---|
| 01 | `verify P/pins/source-tp114.sha256 P/cold-boot114` | `VERIFIED 159 files, 0 failed` |
| 02 | `stage-copy P/pins/source-tp114.sha256 P/cold-boot114 R/selfbuild` | `STAGED 159 files, 0 failed` |
| 03 | `manifest R/selfbuild/inputs.list R/selfbuild R/selfbuild/inputs.sha256` | `MANIFEST 159 files, 0 failed` |
| 04 | `verify R/selfbuild/inputs.sha256 R/selfbuild` | `VERIFIED 159 files, 0 failed` |
| 05 | `verify P/pins/land252-g1-consumed-sources.sha256 R/selfbuild` | `VERIFIED 65 files, 0 failed` |
| 06 | `verify P/pins/land252-g2-consumed-sources.sha256 R/selfbuild` | `VERIFIED 65 files, 0 failed` |

`selfbuild/inputs.sha256` is byte-equal to `source-tp114.sha256` (`FE3FDA29B2B6029DB640717BAF88E812F75F6AD3B8E64C54FF5BCF27BF31D6CF`);
`selfbuild/inputs.list` is unchanged (`E6FFBCFB…`). Git sees 7 changed paths under `selfbuild/`: `inputs.sha256` and the six
sources of tp113/tp114 — `l2_frontend_types`, `_values`, `_context`, `_core`, `_emit`, `tools/build.lm2` (all this slice's
work over the landed source-tp112). `selfbuild/README.md` names the package, the G0/previous-frontend tuple (tool114
`46D20AA9…`, fe114 `0DB4B5D1…` with `2C4D9B0D…`/`AF9FDAE3…`), the promoted working tool and the acceptance boundary (quick,
not FULL).

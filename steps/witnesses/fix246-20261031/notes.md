# Slice246 — the boot89-tested source package landed in selfbuild/

Base main/origin `47575bdd` (slice245). Opus sole writer/build; Codex consults. Codex answered slice245's Q1 with
choice B ([CODEX-OPUS-245LAND-20261031-ANSWER](records/CODEX-OPUS-245LAND-20261031-ANSWER.txt), the verbatim row
the relay received from Codex at 23:03:29Z): land the actually tested green89 source package in tracked
`selfbuild/` now, with the whole-quick evidence; no additional FULL before this normal landing; the exact 159
inputs bound by `source-boot89.sha256` through the existing manifest/stage-copy/verify route; nothing generated,
no writer85/full-Work79/draft87 changes.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`.

## The landing

`P/pins/land245.command` (named after the tested package of slice245), run by the existing pwsh7 with the promoted
working tool of boot89, `P/cold-boot89/quick89/lmxtool.exe` `7FD2E824…` (G2's tool; the record checks its hash and
the hash of `source-boot89.sha256` first), each step from a fresh private CWD; 23:07:34Z → 23:07:36Z:

| step | command | result |
|---|---|---|
| 01 | `verify P/pins/source-boot89.sha256 P/cold-boot89` | `VERIFIED 159 files, 0 failed` |
| 02 | `stage-copy P/pins/source-boot89.sha256 P/cold-boot89 R/selfbuild` | `STAGED 159 files, 0 failed` |
| 03 | `manifest R/selfbuild/inputs.list R/selfbuild R/selfbuild/inputs.sha256` | `MANIFEST 159 files, 0 failed` |
| 04 | `verify R/selfbuild/inputs.sha256 R/selfbuild` | `VERIFIED 159 files, 0 failed` |
| 05 | `verify P/pins/land245-g1-consumed-sources.sha256 R/selfbuild` | `VERIFIED 65 files, 0 failed` |
| 06 | `verify P/pins/land245-g2-consumed-sources.sha256 R/selfbuild` | `VERIFIED 65 files, 0 failed` |

The rewritten `selfbuild/inputs.sha256` is byte-equal to `source-boot89.sha256`
(`9A5C12AC46199B8038F39496846D4B3D91113C2CF838D601468648EB810C5FA5`). `selfbuild/inputs.list` is unchanged
(`E6FFBCFB…`): the same 159 paths in the same order. Steps 05/06 use the lines of the generations' own
consumed-input snapshots (`quick89/g1/consumed-inputs.sha256`, `quick89/g2/consumed-inputs.sha256`) whose paths are
in `inputs.list` — the 65 sources; both subsets are identical and every line is in `source-boot89.sha256`. Tools and
tests are not in those snapshots; step 01 binds them to the bytes the stage was prepared from. All 159 tested
inputs are LF.

Git sees 26 changed paths: `inputs.sha256` and 25 selected files — 9 frontend (`l2_consumer_uses`,
`l2_frontend_coords`, `_core`, `_emit`, `_lower`, `_resolve`, `_useplan`, `_values`, `_views`), 13 kernel
(`lmx_arena`, `lmx_call`, `lmx_gc_graph`, `lmx_graph_copy_owned`, `lmx_implements`, `lmx_merge_owned`, `lmx_pool`,
`lmx_range`, `lmx_reparent`, `lmx_root`, `lmx_thread`, `lmx_value_owned`, `lmx_walk_values`), `tests/lib/lib_owner.lm2`,
`tools/build.lm2` and `tools/lmxtool_methods.lm2`. No compiler or test pipeline ran for the move: the bytes are the
ones boot89 built and tested ([slice245](../fix245-20261031/notes.md)).

`selfbuild/README.md` now names this package: the boot89 source, candidate84 (Codex's source80 with the 81–84 fixes)
with walker86 and green89's resolve; the selected G0/previous-frontend/backend/libc/BASE tuple and the promoted
working tool; the unchanged commands, both modes and the generated-header-before-consumer route.

## Boundaries

The package is tested whole QUICK89: both generations built, smoke-tested (9 rows, 0 failures each) and promoted.
FULL, the OS walk witness and the self-test did not run on these bytes; quick does not compare generations. The
FULL48 results are evidence for candidate48's bytes, not a FULL acceptance of this package. The G1/G2 comparison of
slice245 (byte-equal runtime objects, libc and tool L1/C; executables differing only in the PE link stamp) is its
own evidence, not a reproducibility gate; the parenthesis-free comparison of the frontend outputs is a diagnostic
observation, not raw identity or a proof of semantic equivalence. The draft79 line is not in this package; its
OPEN items (DRAFT79-OWNER-POINTER-CONTEXT-STACK-POINTEE, SPLIT-POINTER-PLACE-NOT-ADMITTED,
DRAFT79-BARE-RETURN-CHECKER) stay open. The landing does not close a clean-clone platform G0, S8.6, the
clean/native/admission/source-profile debts or the mail API.

## Evidence and checks

[evidence.list](evidence.list) names the originals under P (the landing record, terminal and logs, the two subset
manifests, the generations' consumed-input manifests, `source-boot89.sha256`, the working tool and Codex's answer);
`P/pins/docs246.command` computed [evidence.sha256](evidence.sha256) and verified it, and
`P/pins/docs246-check.command` ran the full docs check with the slice in the Git index — both with the promoted
working tool `7FD2E824…`. `records/` holds LF copies.

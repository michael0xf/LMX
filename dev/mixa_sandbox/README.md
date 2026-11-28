# mixa_sandbox — active C→L1 migration workspace for mixa_manager

## Status: ACTIVE (ticket 20260917-080230)

Work directory for ongoing mixa_manager C→L1 migration. Merged from the short-lived
`L1\dev\mixa_migration\` tree into this existing sandbox (2026-09-17).

## Paths

| role | path |
| --- | --- |
| Work dir (this sandbox) | `C:\Nyasha_Planet\L1\dev\mixa_sandbox\` |
| Source of truth for edits | `C:\Nyasha_Planet\L1\dev\mixa_sandbox\mixa_manager\` |
| Publish target (after green build) | `C:\Nyasha_Planet\L1\mixa_manager\` (project root — **not** `L1\dev\mixa_manager\`) |
| L2 core | `C:\Nyasha_Planet\L1\l2src` — do not move |
| lingvamyxa | **frozen** — do not read/enter/write except work_chat grok_bot inbox/outbox/seen/HEARTBEAT |

## Structure

- `mixa_manager\` — working tree (migration C→L1 copy; 689 files after merge)
- `conflicts_wtb5_snapshot\` — 47 prior sandbox (wtb5_l2trans_cand) files that differed from migration; preserved for peer review
- `tools\` — `build_mixa.ps1`, `gen_headers_*.py`
- `evidence\`, `build\`, `header_srcs\` — migration build artifacts
- `REPORT.md` — status + metrics + DEFECT/QUESTION list
- `mixa_manager\CONVERSION.md` — conversion notes
- `go.sh` — **legacy**; may still reference old wtb5 worktree paths — needs revisit
- `README.md` — this file

## Build

The legacy build uses [`tools/build_mixa.ps1`](tools/build_mixa.ps1) and the
saved [`tools/legacy/l1trans.exe`](tools/legacy/l1trans.exe). From the LMX
repository root, run:

```powershell
$mixa = Join-Path $PWD 'dev/mixa_sandbox/tools'
$legacy = Join-Path $mixa 'legacy'
$inputs = @{
    Translator = Join-Path $legacy 'l1trans.exe'
    ExpectedTranslatorSha256 = 'E3E9B25846A11E0641B7805613BECE4203BD1A654DE45DE46311B5CBABA43B4B'
    KernelEvidenceDir = $legacy
}
& (Join-Path $mixa 'build_mixa.ps1') @inputs -BuildOnly
```

Use `-ExactChainGuardOnly` in place of `-BuildOnly` to verify the input paths
and hashes without compiling. A build uses the current sandbox sources and
the checkout's `dev/l2src_sandbox` and `lm1/build` inputs. It also requires
`gcc` and `nm` on `PATH`. Keep the old `L1\mixa_manager` publish target as
described in [REPORT.md](REPORT.md).

| Saved input | Provenance |
| --- | --- |
| `tools/legacy/l1trans.exe` | The accepted LMX producer's `l1trans.exe` (SHA-256 `E3E9B25846A11E0641B7805613BECE4203BD1A654DE45DE46311B5CBABA43B4B`), taken from the accepted stage `build2/coder-grammar-20261127/stage-assign-02b/coder-assign02-feh01/`; producer commit `bbad344aaabac8af6b6e1bbbc0ed44043c13a72a` (28 Nov 2026), stage `stage-assign-02b`, closure `hosted-assign-assign02`. Same `l1trans` name and CLI as before: `[--unit-root DIR] <source.lm1> <output>`. |
| `tools/legacy/headers/l2src/` | 46 generated headers preserved from the Mixa build `20260922_004742`, recorded in Git commit `fc0dbbf11`. The accepted producer consumes this header set unchanged: the run `build/20261128_helper5.log` reports the header-set digest `5B983970B6A09A1F4E6C0DDDFFE0F579D1670AD8D30FAB7B7FD093B480D8407D` (Windows PowerShell 5.1 hashing of the linked set; an older pwsh 7 guard printed `D3931C398E9A4469A06530BD09254C773FE016FBE3928938088DBA377A2A5B55` over the same 46 files — the two shells order/hash the names differently). |

The sandbox `.lm1` sources are written for this producer after two mechanical
source templates (applied 28 Nov 2026, verified green): blank lines inside
function bodies carry a `#` comment line, and bare named pointer parameters use
the `@: T name` spelling (`const: @(char name)` stays as is). The September 22
gate recorded in `fc0dbbf11` was produced by the B2 executable with SHA-256
prefix `571fa34e`. The previous saved `l1trans.exe` (`601D350E…`, Git commit
`7bb8962fab7ad94be01efc266c725500857e696b`, 2026-09-27) is what the 28 Nov
verification `build/20261128_helper2.log` ran before this replacement; that old
kit stays available in Git commit `bb3dbb7c3`. The first full run on this
producer is `build/20261128_helper5.log` (378 targets, no failures, exit 0);
the control run from this saved kit is `build/20261128_helper6.log`
(`-BuildOnly` with this kit's binary and headers: 378 targets, no failures,
exit 0).

## History

- Pre-merge sandbox held a 130-file wtb5_l2trans_cand snapshot + `go.sh`.
- Migration tree held frozen-tree C→L1 work (689 files under mixa_manager).
- All 130 sandbox paths overlapped migration; 47 had different SHA256 — wtb5 copies
  saved under `conflicts_wtb5_snapshot\`, migration versions installed as working tree.
- `L1\dev\mixa_migration\` removed after merge.

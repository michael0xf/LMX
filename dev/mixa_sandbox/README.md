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
    ExpectedTranslatorSha256 = '601D350E853CA16A35EC4B7ED7C2B5B82248A63E96B72A545329B1D8C6AA2196'
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
| `tools/legacy/l1trans.exe` | Byte-for-byte copy of `bin/l1trans.exe` from Git commit `7bb8962fab7ad94be01efc266c725500857e696b` (2026-09-27). The SHA-256 above matches that revision's `L1_PIN.txt`. |
| `tools/legacy/headers/l2src/` | 46 generated headers preserved from the Mixa build `20260922_004742`, recorded in Git commit `fc0dbbf11`. The build script reports the header-set digest `D3931C398E9A4469A06530BD09254C773FE016FBE3928938088DBA377A2A5B55`. |

The September 22 build recorded in `fc0dbbf11` used a different B2 executable
with SHA-256 prefix `571fa34e`. The command above checks the current sandbox
with the saved September 27 executable.

## History

- Pre-merge sandbox held a 130-file wtb5_l2trans_cand snapshot + `go.sh`.
- Migration tree held frozen-tree C→L1 work (689 files under mixa_manager).
- All 130 sandbox paths overlapped migration; 47 had different SHA256 — wtb5 copies
  saved under `conflicts_wtb5_snapshot\`, migration versions installed as working tree.
- `L1\dev\mixa_migration\` removed after merge.

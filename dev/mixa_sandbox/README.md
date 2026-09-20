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

Prefer `tools\build_mixa.ps1` from this sandbox (see REPORT.md). Do **not** sync to
`C:\Nyasha_Planet\L1\mixa_manager\` until build is green.

## History

- Pre-merge sandbox held a 130-file wtb5_l2trans_cand snapshot + `go.sh`.
- Migration tree held frozen-tree C→L1 work (689 files under mixa_manager).
- All 130 sandbox paths overlapped migration; 47 had different SHA256 — wtb5 copies
  saved under `conflicts_wtb5_snapshot\`, migration versions installed as working tree.
- `L1\dev\mixa_migration\` removed after merge.
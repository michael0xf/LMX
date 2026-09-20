# Mixa / myxa_manager run audit — GROK-BOT-MANAGER-RUN-20260920-61B

Date: 2026-09-20 23:07 UTC  
Repo: `C:\Nyasha_Planet\LMX` (dev/mixa_sandbox)  
Scope: read-only inspection + new paths only. Did **not** edit `build_mixa.ps1`, `mixa_event_source*`, ingress vendor, `mtk_*`, translator/seed/pin, l3, lmx_walk, ownership, or VM files.

## Question

What is the minimal **headless** command chain that produces and executes the **real** myxa/mixa manager after the large compile gate is green?

## What exists today

| Piece | Location | Role |
|-------|----------|------|
| Compile/run gate | `dev/mixa_sandbox/tools/build_mixa.ps1` (DeepSeek-owned; not modified) | `-Run` / `-RunOnly <stamp>` → evidence under `dev/mixa_sandbox/build/<stamp>/` with `bin/*_selftest.exe` + fixtures |
| Latest evidence (probe) | `dev/mixa_sandbox/build/20260920_192235/bin` | **66** `.exe` files (selftests/fixtures) |
| Earlier evidence | `dev/mixa_sandbox/build/20260920_073442/bin` | **63** `.exe` files |
| Interactive entry source | `dev/mixa_sandbox/mixa_manager/mixa_app_main.lm1` | Real `main()`; comments state it opens a **Win32 window** and is a **build-only** check — **never** executed by automated suites |
| L2 parity runner | `mixa_manager/run_mixa_app_main_l2_parity.ps1` | Links a real `mixa_app_main.exe` for build-only oracle; explicitly **does not run** it |
| Headless orchestration proxy | `tests_mixa_app_controller_e2e_selftest.exe` (in evidence `bin/`) | Drives `mixa_app_controller` headless e2e — **not** the manager shell binary |
| Legacy selftest runner | `mixa_manager/run_mixa.ps1` | Translates/runs a fixed list of unit selftests via `stg\l1_baseline` translator; not the 363-style sandbox gate |

Observed gate sizes in existing stamps were **63–66** linked probe exes, **not** 363. The string `363` does not appear in `build_mixa.ps1`. Treat “363-target gate” as an external/expected figure not encoded in that script as inspected.

## Executable search (this slice)

Commands (cwd `C:\Nyasha_Planet\LMX`):

```
Get-ChildItem -Recurse -Filter mixa_app_main.exe build,dev\mixa_sandbox\build
Test-Path dev\mixa_sandbox\build\20260920_192235\bin\mixa_app_main.exe
Get-ChildItem -Recurse -Filter '*myxa*manager*.exe'
```

Results captured under ignored `build/grok_bot_manager/probe_*.txt`:

- **0** `mixa_app_main.exe` hits under `build/` + `dev/mixa_sandbox/build/`
- **0** `*myxa*manager*.exe` / `*mixa_manager*.exe` product hits
- Evidence `bin/` contains selftests/fixtures only (no non-selftest manager shell)

## First exact missing target

**Missing product path (after a green `build_mixa` evidence stamp):**

`dev/mixa_sandbox/build/<stamp>/bin/mixa_app_main.exe`

(or an equivalently documented headless manager executable named in the gate and placed in that `bin/`).

**Why this is the blocker for “run the real manager headless”:**

1. Source entrypoint `mixa_app_main.lm1` / `main()` exists but is **interactive Win32**, not a headless smoke product.
2. `build_mixa`’s published evidence `bin/` does **not** currently ship that shell exe (probes only).
3. The closest headless runnable already in evidence is `tests_mixa_app_controller_e2e_selftest.exe` — controller e2e, **not** the manager `main` shell.

**Command that exposes the gap** (no rebuild required):

```
powershell -NoProfile -Command "Test-Path 'dev/mixa_sandbox/build/20260920_192235/bin/mixa_app_main.exe'"
```

Expected today: `False` (exit 0 from Test-Path meaning “path missing” → `False`).

Optional after DeepSeek’s gate (Grok must not invoke `build_mixa` while that WIP is owned elsewhere unless asked):

```
powershell -NoProfile -ExecutionPolicy Bypass -File dev\mixa_sandbox\tools\build_mixa.ps1 -RunOnly 20260920_192235
# then again:
Test-Path dev\mixa_sandbox\build\20260920_192235\bin\mixa_app_main.exe
```

## Minimal chain *when* the product exists

Intended future chain (not runnable until the missing exe is a gate product):

1. Green compile gate → evidence `dev/mixa_sandbox/build/<stamp>/`
2. Headless manager binary present at `...\bin\mixa_app_main.exe` **or** a dedicated headless twin documented beside it
3. `dev\mixa_sandbox\tools\run_manager_smoke.ps1 -Stamp <stamp>` consumes that bin (see companion script)

Until then the smoke script **fails closed** with this same missing-path message and may optionally run the **controller e2e** only as a labeled proxy (not claiming manager-shell success).

## Ownership fences respected

Not modified: `build_mixa.ps1`, `mixa_event_source*`, `vendor/lmx_msg_host_ingress_v0`, ingress harness, `mtk_*`, translator/seed/pin, l3/VM, lmx_walk, manager sources.

## Deliverables (this commit)

- `steps/mixa-manager-run-audit.md` (this file)
- `dev/mixa_sandbox/tools/run_manager_smoke.ps1` (new; evidence-only; no `build_mixa` logic copy)
- Probe logs under ignored `build/grok_bot_manager/`

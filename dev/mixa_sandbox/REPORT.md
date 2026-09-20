# REPORT.md — merge mixa_migration → mixa_sandbox (тикет 20260917-080230)

## Итог: DONE (merge) / build still RED

Работа перенесена из `C:\Nyasha_Planet\L1\dev\mixa_migration\` в существующий
`C:\Nyasha_Planet\L1\dev\mixa_sandbox\`. Каталог `mixa_migration` удалён.
Publish target после зелёной сборки: `C:\Nyasha_Planet\L1\mixa_manager\` (корень проекта,
не `L1\dev\mixa_manager\`). Синхронизация туда ещё не делалась (build RED).

## Пути после merge

| роль | путь |
| --- | --- |
| Work dir | `C:\Nyasha_Planet\L1\dev\mixa_sandbox\` |
| Source of truth | `sandbox\mixa_manager\` |
| Publish (после green) | `C:\Nyasha_Planet\L1\mixa_manager\` |
| L2 core | `C:\Nyasha_Planet\L1\l2src` (не трогать) |
| wtb5 conflict copies | `sandbox\conflicts_wtb5_snapshot\mixa_manager\` (47 файлов) |
| lingvamyxa | frozen |

## Числа (из прежнего REPORT 073447 — не пересчитывались)

| метрика | значение |
| --- | --- |
| Новые `.h.lm1` (фокус) | 26, translate OK |
| `include:`→`predef:` | 117 замен в 74 файлах |
| `build_mixa` (первый `-Run`) | **RED 70/282**, evidence `build\20260917_075522` (теперь под sandbox) |
| `build_l2src` до | **GREEN 115**, evidence `build\l2src\20260917_073736` |
| Новый пин L1 | `32F3018CD0261E4CAC97B3E6D02C84673A2E9D17F46C8498D0148572E11B2576` |
| Self-build | PASS, `build\self_build\20260917_075202_514` |
| Файлов в sandbox\mixa_manager после merge | 689 |

## DEFECT / QUESTION — 47 content conflicts (wtb5 snapshot vs migration)

Sandbox до merge: 130 файлов (снимок wtb5_l2trans_cand). Migration: 689 файлов
(frozen-tree C→L1). Все 130 путей пересекались; **47 имели разный SHA256**.

**Решение при merge:** версии из migration установлены как working tree; копии wtb5
сохранены в `conflicts_wtb5_snapshot\mixa_manager\`. Peers: решить, нужно ли
повторно накатить какие-либо дельты wtb5 поверх migration-версии.

Список (относительные имена под `mixa_manager\`):

mixa_app_controller.lm1
mixa_app_controller_l2.h.lm1
mixa_app_fmpanel.lm1
mixa_app_main.lm1
mixa_app_path.lm1
mixa_app_window.h.lm1
mixa_app_window.lm1
mixa_backend_ctors_headless.lm1
mixa_backend_ctors_headless_l2.h.lm1
mixa_backend_ctors_win32.lm1
mixa_backend_ctors_win32_l2.h.lm1
mixa_backend_headless.lm1
mixa_backend_headless_l2.h.lm1
mixa_backend_table.lm1
mixa_backend_table_l2.h.lm1
mixa_backend_win32.lm1
mixa_backend_win32_l2.h.lm1
mixa_buttons.lm1
mixa_cmdline.lm1
mixa_cmdline_dispatch.lm1
mixa_cmdline_dispatch_l2.h.lm1
mixa_composite.lm1
mixa_composite_glyphs.lm1
mixa_composite_glyphs_l2.h.lm1
mixa_console_window.h.lm1
mixa_console_window.lm1
mixa_console_window_l2.h.lm1
mixa_draw.lm1
mixa_event_fifo.lm1
mixa_file_manager.h.lm1
mixa_file_win32.lm1
mixa_fm_copy.h.lm1
mixa_fm_copy_l2.h.lm1
mixa_help.lm1
mixa_help_l2.h.lm1
mixa_highlight.lm1
mixa_pointer.lm1
mixa_process_win32.lm1
mixa_process_win32_l2.h.lm1
mixa_pump.lm1
mixa_pump_l2.h.lm1
mixa_selection.lm1
mixa_selection_walk.h.lm1
mixa_share_action_l2.h.lm1
mixa_share_button.h.lm1
mixa_text_rect.lm1
mixa_tiles.lm1

## Прежние дефекты (из 073447)

1. `mixa_backend.h:126` enum `MixaButton` ↔ `mixa_buttons.h:16` struct `MixaButton` — конфликт имён в C; в L1 enum мыши = `MixaMouseButton`.
2. Дубли типов между `*_l2.h.lm1` и новыми реальными `.h.lm1` при совместном `predef:`.
3. `mixa_console_window.c` / `mixa_event_source.c` ещё на C рядом с `.lm1`.

## Что дальше

1. Починить build_mixa из sandbox (`tools\build_mixa.ps1`).
2. Peers: просмотреть 47 conflicts — re-apply wtb5 deltas если нужны.
3. Продолжить C→L1; после green — sync только в `C:\Nyasha_Planet\L1\mixa_manager\`.
4. `go.sh` может ссылаться на старые wtb5 paths — пересмотреть.
5. Не создавать `L1\dev\mixa_manager\`.
## Decision — ticket 20260917-081239 (Mikhail / peer 08)

**No conflict diff** over the 47 wtb5-vs-migration content conflicts. Migration tree wins as the working tree; `conflicts_wtb5_snapshot\` remains archive-only. Do not raise or re-apply a wtb5 delta pass unless a later ticket explicitly authorizes it. Recorded 2026-09-17 08:20:46 (ticket 20260917-081239).

## build_mixa re-run — ticket 20260917-081239 (2026-09-17 08:26:28)

- Evidence: `build\20260917_082100` (full log `build_mixa_081239_run.txt`)
- Verdict: **RED 42 of 282** (was RED 70/282 on `build\20260917_075522`)
- Delta this run: skip handC when `.lm1` twin exists; skip `mixa_event_source.c` pending convert; tableref forward-decl already in tree → backend/console/pump/help/fm_copy family largely greened.
- Remaining blockers (top): `duplicate type name in header unit` (`mixa_app_controller_l2` / controller / fmpanel / cmdline family); `mixa_share_win32` / `mixa_file_win32` / `mixa_highlight` / `mixa_process_win32` compile; cascading selftest link/run fails.
- Counts under `mixa_manager` (excl. vendor/recovery): .c=42 .h=29 .lm1=279
- **Not published** to `L1\mixa_manager\` (not green).

## Ticket 20260917-083000 (Mikhail lifted no-diff ban)

**Diff ban lifted.** Full conflict report written to `C:\Nyasha_Planet\work\DIFF_wtb5_47files.md`.

### Diff summary (47/47 SHA differ; 0 substantive body deltas)
- All 47: `include: .h` → `predef: .h.lm1` (C→L1 migration).
- A few: drop `c.` door (composite/tiles).
- Size outliers (buttons/highlight/text_rect): CRLF (wtb5) vs LF (migration) only.
- After normalize (strip predef/include + `c.` prefix): **bodies identical**.
- Recommendation: keep migration; do **not** re-apply wtb5.

### C→L1 greening work this ticket
Fixes in `mixa_sandbox\mixa_manager` (+ `tools\build_mixa.ps1` idirafter for WinRT):
1. Duplicate-type: removed colliding `type:` forwards; same-file `type:`+`struct:` completion in `*_impl` / `*_win32.h.lm1` (l1trans drops struct bodies across predef).
2. `mixa_app_fmpanel.h.lm1`: predef file_manager; sync `open()` arity with `.lm1`.
3. `mixa_highlight.h.lm1`: `MIXA_HIGHLIGHT_OK/ERR`; `mixa_highlight.lm1` predefs `mixa_draw.h.lm1`.
4. `mixa_cmdline.h.lm1`: drop spurious `len` on `char_position`.
5. `mixa_app_panel.lm1`: `stdio.h`; predef `mixa_app_window.h.lm1` not `.lm1` body.
6. `mixa_app_main.lm1`: forward `mixa_backend_default_table`.
7. `build_mixa.ps1`: `-idirafter` Windows Kits winrt path for `share_win32`.

### Build status (ticket 20260917-083000)
- Prior 081239: RED **42/282** (`build\20260917_082100`)
- Best this ticket: RED **29/282** (`build\20260917_085557`, log `build_mixa_083000_run2.txt`) — **all production units OK**; remaining fails are selftests + `tests_mixa_console_window_minimal_test`.
- Experimental predef-body cleanup (run3 `build\20260917_091315`) regressed to RED 40 — **reverted** window/console/panel body-predefs to the RED29 shape.
- **Not published**. Residual `.c/.h` **not** deleted.


## Ticket 20260917-103358 (guard) — 2026-09-17 11:18

**Five rules absorbed.** Build still **RED** — **NOT published** to root `L1\mixa_manager` (no delete/overwrite of Mikhail's restore).

### Progress this ticket
- `tests/mixa_console_window_minimal_test.lm1`: `MixaU8 buf` (peer) / prior `unsigned char` fix — unit greened on run1.
- `mixa_backend.h.lm1`: prototypes `table_by_name`, `default_table`, `tables`.
- `highlight_restore_selftest`: greened on run1 (8160 checks, 0 failures) after decls; now uses `mixa_text_rect.h.lm1`.
- `tools/build_mixa.ps1`: link adds `-lwinmm -lole32 -luuid -lshell32` (audio_native links; still runtime fail).
- Peer mid-morning: `mixa_text_rect.h.lm1`, `mixa_composite.h.lm1`, draw/composite/buttons/... switch body-predef→header; `MODULE_PLAN.md` copied into dev.

### Evidence
- Prior best full: RED **29/282** `build\20260917_085557` (all production units OK).
- Run1 `build\20260917_104006` + `build_mixa_103358_run.txt`: contaminated (peer edits at 10:48 during header-already-done build); highlight_restore OK; many text_rect.lm1.h misses.
- Run2 `build\20260917_110902` + `build_mixa_103358_run2.txt`: headers include text_rect/composite; aborted mid-selftests after e2e link fails (stdout truncated; process exited).

### Remaining blockers (not green)
- e2e family: multiple-definition link (body-predef / tile symbols).
- Runtime: app/copy/dir/fileio/fm_copy/process* behavioral fails; app_panel AV.
- Compile: help/app_loop duplicate type in `mixa_file_win32.h.lm1`; backend_table/share_button/remove_confirm still open.

### MODULE_PLAN / publish method
- `MODULE_PLAN.md` now in **both** root and dev (copied into dev ~10:36).
- Dev also has extra `mixa_text_rect.h.lm1` + `mixa_composite.h.lm1` not yet in root.
- Publish deferred until green; when done will use **file-by-file** copy (or ensure MODULE_PLAN preserved) + commit+push same action, named paths only, never `git clean`.


## Ticket 20260917-103358 (guard — five hard rules)

- Rules absorbed; root `L1\mixa_manager` not deleted; no git clean; no publish (not green).
- MODULE_PLAN.md already identical in root+dev; future publish = file-by-file (+ new `mixa_text_rect.h.lm1` / `mixa_composite.h.lm1`).
- Best build: RED **21/284** evidence `build\20260917_111845` (was RED 29/282). Log `build_mixa_103358_runC.txt`.
- Wins: minimal_test unit OK; all 8 fmpanel e2e selftests ran exit 0; console/window/panel/draw/composite units compile after body→header predef thin.
- Remaining: 21 selftest fails (runtime + a few selftests needing text_rect.h / duplicate-type / residual multi-def).
- NOT published.


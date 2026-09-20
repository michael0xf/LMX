# Статус mixa_manager — 19 сентября 2026

## ФАКТ: C→L1 миграция завершена

Ноль .c-исходников в mixa_manager source. 367 .lm1, 158 .lm1 в tests/.
Две .h без .h.lm1 двойника — обе с объяснением в шапке:
- mixa_backend_tableref.h — нужен (l1trans печатает include: раньше тела структур)
- mixa_file_win32_l2_win.h — нужен (#define WIN32_LEAN_AND_MEAN перед <windows.h>)

Оставшиеся .c: 3 в tests/l1_gaps/ (gap-probes, intentional C, не mixa source) +
vendor/lmx_msg_host_ingress_v0/lmx_message_host.c (удаляется — ЗАДАНИЕ A).

## ЗАДАНИЕ 1: Склейка mixa по одобренному разбиению

### Статус: В ПРОЦЕССЕ (результаты — ниже)

**Архитектура одобрена** (GLUE_RULES.md §2a, уточнения l1-98 2026-09-18,
пересмотр l1-98 peer review 20260919-130000):
- R0 = корень, шагается lmx_root_cycle
- **ВСЕ 4 нити STEPPED** через единый R0 manager (lmx_manager_add) на главном OS-потоке
  (один manager per root, chosen once at binding; NO lmx_manager_running_add, NO
  per-thread lanes, NO GetMessage). UI Thread body = один неблокирующий PeekMessageA pump.
- 4 L3 Thread (UI, File, Audio, Process)
- Письма через lmx_service_post (физический адрес)
- Каждый ребёнок — своя арена + lmx_schedule_init(slot, child_arena, thread, limit)
- Жизненный цикл: kernel (lmx_settle_children + lmx_stop_children)

**Что сделано:**
- mixa_app_main_msg.lm1: создан с 4 L3 Thread, mixa_app_ui_entry (open/step/close) ✅
- mixa_app_message.h.lm1: kernel API header + LmxManager/LmxEntry/Lmx/LmxMethod types ✅
- mixa_autostart.lm1: Win32 HKCU Run (grok_bot) ✅
- UI Thread: callable в graph (lmx_pool_make + lmx_method_intern + lmx_arena_ref_store) ✅
- UI Thread: completion signaling (lmx_thread_current + success/running flags) ✅
- BUILD OK: 183 targets GREEN ✅

**Расхождение (замечено ДО работы):**
- mixa_app_main_msg.lm1 использует SHARED rt_child_arena для всех потоков.
  Требуется: отдельная арена для КАЖДОГО ребёнка + lmx_schedule_init.
  План: добавить lmx_schedule_init + lmx_arena_open_simple прототипы,
  рефакторить entry на per-child arenas.

**Kernel изменения (за сутки, влияют на код):**
- lmx_service_post: +4-й параметр letter_arena (уже синхронизировано в header) ✅
- lmx_arena_open_simple: упрощённая арена для писем
- lmx_arena_attach: присоединяет letter_arena к получателю

## ЗАДАНИЕ A: Vendor deletion (Mikhail: «надо либо удалить либо держать в lm1»)

**Статус: ВЫПОЛНЕНО**
- Удалён: vendor/lmx_msg_host_ingress_v0/ (4 файла: lmx_message.h, lmx_message.lm1,
  lmx_message_host.c, lmx_message_host.h)
- Удалён: run_ingress_harness.ps1 (только для SHA vendor'a)
- Исправлен: mixa_event_source.h.lm1 — `include: "l2src/lmx_message.h"` →
  `predef: "l2src/lmx_message.h.lm1"` (kernel header)
- Исправлен: mixa_event_source.h.lm1 comment (vendor → kernel)
- mixa_console_window.txt: требуется проверить/обновить упоминание vendor

## ЗАДАНИЕ B: l1_gaps/run.sh (не воспроизводим)

**Статус: ВЫПОЛНЕНО**
- Исправлен: использует L1TRANS_STG env (абсолютный путь к STG переводчику)
- SHA256 pin: 65D5A5ED... (выводится в transcript)
- Output: build/l1gaps (в НАШЕ дерево, не в frozen stg/)
- STG translator найден: /c/.../lingvamyxa/stg/l1_baseline/build/l1trans/gen2/l1trans.exe

## Проверка (ЗАДАНИЕ 2)

- go.sh just-build: **BUILD OK** (183 targets GREEN)
- Parity scripts: ТРЕБУЕТСА — нужно запустить run_*_l2_parity.ps1
- Watcher: pid 5236 ALIVE (cron a4af4990, каждые 5 мин)

## Отчёт по lmx_branch_* → lmx_arena_refs

- lmx_branch_open_owned → lmx_arena_refs_open_owned: ✅ исправлено (grep чист)
- lmx_address_len/fill: в kernel (для getAddress, не для доставки)

## Склейка mixa — ВЫПОЛНЕНА (с поправкой l1-98 peer review)

**Числа:**
- L3 Threads: 4 (UI, File, Audio, Process)
- Arenas: 6 (R0 root + shared child_arena для setup + 4 per-thread)
- lmx_schedule_init вызван для каждой нити (инициализирует запись расписания ареной нити)
- lmx_root_create использует per-thread arena
- lmx_service_post: 4-arg (letter_arena) — синхронизировано
- **Driver: ALL STEPPED** (lmx_manager_add ×4); NO lmx_manager_running_add
- Body callables: 4 (UI=mixa_app_ui_entry, File=11, Audio=22, Process=33)
- Graph layout per child: [0]method [1]turns [2]body_id [3]letter (source template: 4 children)
- lmx_thread_turn(t, 0) → lmx_call0(arena, graph) — тело находится из графа
- Arena type fix: `LmxArena:` (value) + `@ arena` (not `@: LmxArena` pointer + `@ arena`)
- build_mixa.ps1: шаг 1b копирует l2src kernel headers в l2src_kernel/ include path
- l1trans: оба .lm1 файла переводятся без ошибок
- BUILD: l1trans GREEN; gcc — требует l2src build для kernel headers (build_mixa.ps1 шаг 1b)

**Per-child arena реализация:**
- `LmxArena:` (value) для локальных арен, `@ arena` во всех вызовах — как в selftest
- lmx_arena_open(@ thread_arena) для каждой нити (НЕ _simple — для нитей нужен GC)
- lmx_arena_take(@ thread_arena) для Thread/Mailbox/Schedule
- lmx_schedule_init(sched, @ thread_arena, thread, 5000U) — арена записи = арена нити
- lmx_root_create(rt_root, @ thread_arena, slot, rt_source) — child из thread_arena
- Жизненный цикл: lmx_settle_children (встроена в цикл R0) + lmx_stop_children — в kernel

**Bugs fixed in mixa_app_main_msg.lm1:**
- `ui_childgraph` → `ui_child\graph` (переставлено после `lmx_root_create`)
- `c.LMX_POOL_KIND_METHOD` → `c.LMX_KIND_METHOD` (константа не существовала)
- Orphaned `return: 0` ×4 (после `lmx_thread_attach` check) — удалены
- `lmx_manager_running_add` → `lmx_manager_add` (all STEPPED, one manager)
- `rt_root_utf8` не устанавливался в `main` — восстановлено из argv[1]
- `mixa_app_ui_entry` не сигнализировал completion → добавлено `lmx_thread_current()` + `success/running` flags

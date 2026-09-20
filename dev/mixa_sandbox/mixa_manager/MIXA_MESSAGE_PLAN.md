# Mixa Manager → Message API: Plan

## Цель
Подключить модули mixa_manager к новому L1 Message kernel (l2src/lmx_*.lm1),
заменив старый vendor host-ingress API (lmx_msg_runtime_new/create/send).

## Архитектура (ОДОБРЕНА l1-98, 2026-09-18)

R0 — корень, шагается циклом (lmx_root_cycle). Создаёт L3 Threads.

**УТОЧНЕНИЕ 1**: UI Thread + R0 = ОДНА нить. Win32 GetMessage и lmx_root_cycle
выполняются на создавшей окно OS-нити. Нет отдельного "R0 driver" — lmx_root_cycle
это и есть драйвер. Воркеры — отдельные полосы через lmx_manager_running.

L3 Threads:
- UI Thread (бегущий, OS thread = R0 cycle): mixa_backend_win32 + все UI модули
- File Thread (бегущий): mixa_file_manager, file_win32, cmdline_dispatch
- Audio Thread (бегущий): mixa_audio, audio_win32, audio_mp3
- Process Thread (бегущий): mixa_process, process_win32, process_marker

**УТОЧНЕНИЕ 2**: жизненный цикл в ядре — lmx_settle_children / lmx_stop_children.
Не писать running: 0 руками, не освобождать арену ребёнка вручную.

**УТОЧНЕНИЕ 3**: у каждого ребёнка СВОЯ арена + lmx_schedule_init(slot, arena, thread, limit).

Письма между нитями: только через lmx_service_post (физический адрес).
Win32 bridge: тонкий, единственный C-bridge в mixa_backend_win32.

## Этапы

### Этап 1: Инфраструктура ✅
- [x] mixa_app_message.h.lm1 (kernel API header)
- [x] Архитектура одобрена l1-98 (4 уточнения)

### Этап 2: mixa_app_main_msg.lm1 ✅
- [x] 4 L3 Threads (UI + File + Audio + Process)
- [x] mixa_app_ui_entry (open/step/close контроллера)
- [x] lmx_root_open/cycle/close; lmx_root_create + lmx_thread_attach + lmx_child_thread
- [x] BUILD OK

### Этап 3: Миграция C→L1 ✅
- [x] mixa_event_source.c → .lm1 (grok_bot)
- [x] test.c → УДАЛЁН (dead draft, одобрено l1-98)
- [x] 33 .h → .superseded_by_lm1
- [x] 32 ABI probe .c → .lm1 (grok_bot)

### Этап 4: Сборка ✅
- [x] go.sh: kernel bridge, --allow-multiple-definition removed (правильно)
- [x] go.sh just-build → BUILD OK
- [x] Git commit + push

### Этап 5: Win32 message loop (в kernel — не в mixa code)
- Win32 GetMessage + lmx_root_cycle на ОДНОЙ нити (УТОЧНЕНИЕ 1)
- lmx_thread_turn(t, 0) в lmx_manager_running_body (kernel)
- Жизненный цикл: lmx_settle_children / lmx_stop_children (kernel, УТОЧНЕНИЕ 2)
- lmx_service_post для межнитевых писем (физический адрес, УТОЧНЕНИЕ из Михайла)

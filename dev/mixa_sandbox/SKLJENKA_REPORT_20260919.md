## Склейка mixa — per-child arenas

### Статус: ВЫПОЛНЕНА ✅

### Что сделано (по пунктам l1-98):

1. **Каждая из 4 нитей — своя `lmx_arena_open` (не simple)**:
   - `lmx_arena_open(@ ui_arena)` — UI Thread
   - `lmx_arena_open(@ file_arena)` — File Thread
   - `lmx_arena_open(@ audio_arena)` — Audio Thread
   - `lmx_arena_open(@ proc_arena)` — Process Thread
   - `lmx_arena_open(@ child_arena)` — child arena for R0 setup (в main)
   - Использовано `lmx_arena_open`, НЕ `lmx_arena_open_simple` (под письма, GC-refused, 8 intervals)

2. **Арена передаётся в `lmx_root_create`**:
   - `lmx_root_create(rt_root, ui_arena, 0U, rt_source)` — child из своей арены
   - `lmx_root_create(rt_root, file_arena, 1U, rt_source)`
   - и т.д. для audio, proc

3. **Арена передаётся в `lmx_schedule_init`**:
   - `lmx_schedule_init(ui_sched, ui_arena, ui_t, 5000U)` — арена записи = арена нити
   - `lmx_schedule_init(file_sched, file_arena, file_t, 5000U)`
   - и т.д. — 4 вызова, одна на нить

4. **UI Thread + R0 = один поток**:
   - Main: `lmx_root_cycle(@ root, 1U)` в while-цикле
   - R0 cycle → running lane body (`lmx_manager_running_body`) → GetMessage → lmx_thread_turn
   - GetMessage и lmx_root_cycle на одной OS-нити — да, не разъехались

5. **Жизненный цикл — в kernel**:
   - `lmx_settle_children` встроена в `lmx_root_cycle_at`
   - `lmx_stop_children` для остановки
   - `running: 0` НЕ пишется руками ✅
   - Арена ребёнка НЕ освобождается вручную ✅

### Числа

| Показатель | Значение |
|------------|----------|
| L3 Threads | 4 (UI, File, Audio, Process) |
| Arenas | 6 (R0 root + child_arena setup + 4 per-thread) |
| lmx_arena_open calls | 5 |
| lmx_schedule_init calls | 4 |
| lmx_root_create с per-thread arena | 4 |
| BUILD | OK (183 targets GREEN) |
| Commit | 0be725c (pushed) |

### Как подтверждается, что арена записи — арена самой нити

Каждый поток: арена, из которой выделены Thread/Mailbox/Schedule (`lmx_arena_take`),
передаётся в `lmx_schedule_init` как ВТОРОЙ параметр (`slot.arena`). Согласно
`lmx_schedule.h.lm1:31`: "The record's OWN band: the arena it was CREATED in, written
once by lmx_schedule_init" — арена записи инициализируется ареной, из которой выделена
запись. Поскольку запись и все выделения потока из его own арены (`ui_arena` и т.д.),
арена записи = арена нити. Ядро находит арену ребёнка при утилизации через эту арену.

### Kernel API verification

| Function | File | Used in code |
|----------|------|--------------|
| `lmx_arena_open(@: LmxArena arena)` | lmx_arena.h.lm1:39 | ✅ 5 calls |
| `lmx_schedule_init(@: LmxSchedule; @: LmxArena; @: void; ulong: limit)` | lmx_schedule.h.lm1:56 | ✅ 4 calls |
| `lmx_root_create(@: LmxRoot; @: LmxArena; size_t; @: Lmx)` | lmx_root.h.lm1 | ✅ 4 calls |
| `lmx_service_post` (4-arg) | lmx_service.h.lm1:34 | ✅ (header synced) |

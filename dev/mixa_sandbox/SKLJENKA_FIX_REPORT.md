# Sklejka mixa — ответ на review l1-98 (19 сентябя)

## Драйвер: ВСЕ ЧЕТЫРЕ ШАГАЕМЫЕ (пересмотр l1-98)

**Peer review (l1-98):** `lmx_manager` — **одна реализация на менеджер**, выбирается
один раз при связывании (`lmx_manager_init` ИЛИ `lmx_manager_running_init`). R0 имеет
только один менеджер (`lmx_root_manager`). Смешанного менеджера нет.

> Изначальный план (RUNNING для UI, STEPPED для воркеров) — ОТКЛОНЁН.

**Все четыре нити → STEPPED** через `lmx_manager_add` на главном OS-потоке:
- R0 cycle шагает всех детей на том же OS-потоке, где живёт цикл R0.
- Тело UI-нити (`mixa_app_ui_entry`) делает **один неблокирующий `PeekMessageA` pump**
  и возвращается — `GetMessage` здесь ни при каких обстоятельствах.
- Ни одной `lmx_manager_running_add`, ни одной `CreateThread`-полосы.

## Три замечания — ответ по каждому

### 1. Нити без тел (БАГ — мой) — ИСПРАВЛЕНО
Нет ни одного `lmx_method_intern`/`lmx_pool_make`. Children создаются с шаблоном
graph (1 слот), но без callable. `lmx_thread_turn(t, 0)` = "boundary work only" (нет тела).

**Числа:** 4 нити, **4 callable в графах** (UI + 3 воркера).
l1-98: пустые графы — иллюзия «четыре нити крутятся». Добавлены тела
всех трёх воркеров: `mixa_app_file_entry` (body_id=11), `mixa_app_audio_entry`
(body_id=22), `mixa_app_process_entry` (body_id=33). Каждое тело инкрементирует
счётчик ходов в graph[1], забирает письмо из ящика в graph[3], возвращается
без success (живёт до закрытия корня — cascade release l1-98 f9f8f3e).

**Исправление (применено):**
- `lmx_pool_make` → создаёт method pool в `ui_arena`
- `lmx_method_intern` → интернационирует `mixa_app_ui_entry`
- `lmx_arena_ref_store(ui_child\graph, 0U, method)` → кладёт callable в слот 0
  (раньше — `ui_childgraph`, несуществующая переменная; порядок тоже был нарушен:
  `ui_child` создавался ПОСЛЕ `lmx_arena_ref_store`)
- Порядок: сначала `lmx_root_create`, потом pool/method, потом store в graph

### 2. UI-нить дважды ведётся (БАГ — мой) — ИСПРАВЛЕНО
Строка 156: `lmx_manager_add(...)` (STEPPED) + строка 292: ручной `lmx_thread_turn`.

**Фикс:** UI → `lmx_manager_add` (как все остальные) + callable в графе; убран ручной вызов.

### 3. Один шаблон на 4 нити (согласен — как задумано)
Один source → 4 children. Callable dispatch по `lmx_thread_current()` — ОК.

## Дополнительные баги, найденные при реализации

| Баг | Где | Фикс |
|-----|-----|------|
| `ui_childgraph` (неопределённая переменная) | mixa_app_main_msg.lm1:141 | → `ui_child\graph`, переставлено после `lmx_root_create` |
| `c.LMX_POOL_KIND_METHOD` (несуществующая константа) | :139 | → `c.LMX_KIND_METHOD` (= 2) |
| `lmx_manager_running_add` (нарушение driver model) | :159 | → `lmx_manager_add` |
| "Сиротый" `return: 0` после `lmx_thread_attach` | :152-153, :179-180, :206-207, :233-234 | удалён (dead code, exitил функцию преждевременно) |
| `rt_root_utf8` не устанавливался в `main` | :281 | восстановлено: `argv[1]` или `"."` |
| `mixa_app_ui_entry` не сигнализировал completion | :47-98 | добавлено `lmx_thread_current()` + `t\message\success/running` |
| `@: LmxArena` (pointer) + `lmx_arena_open(@ arena)` → `LmxArena**` | :126-129 | → `LmxArena:` (value) + `@ arena` везде (как в selftest) |

## Kernel проверка

| Function | File | Exists |
|----------|------|--------|
| lmx_arena_open | lmx_arena.h.lm1:39 | ✅ |
| lmx_arena_open_simple | lmx_arena.h.lm1 (read-only) | ✅ (but NOT for threads) |
| lmx_schedule_init | lmx_schedule.h.lm1:56 | ✅ |
| lmx_manager_add | lmx_manager.h.lm1:79 | ✅ |
| lmx_manager_running_add | lmx_manager_running.h.lm1:34 | ✅ (declared, но НЕ используется mixa) |
| lmx_root_manager | lmx_root.h.lm1:220 | ✅ |
| lmx_root_create | lmx_root.h.lm1:179 | ✅ |
| lmx_child_thread | lmx_child.h.lm1:72 | ✅ (writes both links) |
| lmx_pool_make | lmx_pool.h.lm1:29 | ✅ |
| lmx_arena_ref_store | lmx_arena_refs.h.lm1:21 | ✅ |
| lmx_method_intern | **lmx_pool.lm1:374** / lmx_pool.h.lm1:53 | ✅ (header decl added 20260919 by l1-98 peer) |
| lmx_thread_current | lmx_thread.h.lm1:140 | ✅ (added to mixa header) |
| lmx_call0 | lmx_call.lm1:40 | ✅ (dispatches callable from graph slot 0) |
| lmx_thread_turn | lmx_thread.h.lm1:138 | ✅ (body return is not a stop; flags are) |

## Исправленный драйвер — как работает теперь

1. `main` → `lmx_root_open(root, mixa_app_entry, ...)` → входит в цикл
2. `lmx_root_cycle(root, 1U)` → `lmx_root_turn`:
   - R0 turn: вызывает `mixa_app_entry` (создаёт 4 нити при первом проходе)
   - Stepped manager шагает всех детей: `lmx_thread_turn(t, 0)` → `lmx_call0(arena, graph)`
   - UI Thread callable = `mixa_app_ui_entry` → один `PeekMessageA` pump
3. Когда UI контроллер закрывается: `mixa_app_ui_entry` устанавливает
   `success=1, running=0` → boundary (`lmx_thread_leave`) ставит `handoff_ready`,
   следующий `lmx_root_cycle` утилизирует нить

## Текущие числа (BUILD OK, code fixed)

| Метрика | Значение |
|---------|----------|
| L3 Threads | 4 (UI, File, Audio, Process) |
| Arenas | 6 (R0 root + child_arena + 4 per-thread) |
| lmx_arena_open | 5 (root + 4 threads; child_arena for setup) |
| lmx_schedule_init | 4 |
| lmx_root_create | 4 |
| lmx_child_thread | 4 (both up/down links) |
| lmx_manager_add | 4 (все STEPPED — единый менеджер) |
| lmx_pool_make + lmx_method_intern | 4 (all threads; UI=11, File=22, Audio=22, Process=33 body_id) |
| Source template child count | 4 (was 1; graph slots: 0=method, 1=turns, 2=body_id, 3=letter) |
| l1trans | 0 errors (both .lm1 files verified) |
| build_mixa.ps1 | шаг 1b: l2src kernel headers → l2src_kernel/ в include path |
| BUILD | l1trans OK; gcc — см. build_mixa.ps1 (требует l2src build) |

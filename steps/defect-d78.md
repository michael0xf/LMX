# D-78 — свидетель sweep почты не зависит от повторного адреса

База: main `e8daf3a`. Ядро не меняется. Правка — `lmx_post_sweep_selftest.lm1` (песочница и копия `l2src/`).

## Причина

Равенство адресов в селфтесте — ответ malloc, не freelist домена POST.

- Первый `lmx_arena_take` домена создаёт массив ровно на одну ячейку (`lmx_arena_take_n_profiled`, `lmx_arena.lm1`; `lmx_pool_make_profiled` ставит `chunk_capacity = count`). Следующая ячейка при полном чанке — новый `calloc` на одну ячейку (`lmx_pool_take_n` → `lmx_pool_add_chunk`). Отдельного списка свободных ячеек нет.
- Sweep снимает неотмеченный чанк целиком: `lmx_gc_block_live` → `lmx_gc_drop_arrays_in_block` → `free` (`lmx_gc_sweep`, `lmx_gc.lm1`). Чанк сироты не отмечен: маркер идёт от корней (`lmx_gc_mark`), не от `arena\arrays`, а POST не обходится по словам (`lmx_gc_cells`).
- Следующий take снова `calloc(sizeof LmxPost)`. Тот же адрес — только если куча отдала только что освобождённый блок.
- `LmxPost.inbox_head` / `inbox_tail` — `ulong` (`lmx_post.h.lm1`). На Windows `unsigned long` — 4 байта (LLP64), на Linux — 8 (LP64), поэтому `sizeof(LmxPost)` и класс размера кучи разные. Замер fable на main `5bc8ec7`: Linux `recycled=0` при `checks=21 failures=1`; на этой машине тот же селфтест зелёный. Пять раундов подряд без повтора — не шум mmap: в том же проходе освобождаются и другие блоки, и LIFO класса размера отдаёт не ячейку Post.

Что проверяет D-43: до `free` встроенный `LmxPost.nodes` уходит из `arena\arrays` (`lmx_gc_drop_arrays_in_block`). Иначе `lmx_arena_array` находит тот же адрес пула и возвращает отказ, `lmx_pool_open` не открывается, `lmx_post_init` — `LMX_POST_INVALID`. `lmx_post_init` обнуляет поля пула, но не снимает его со списка.

## Свидетель

- После каждого `lmx_gc_collect` адрес `@ orphan\nodes`, снятый до collect, отсутствует в `arena\arrays`. Это наблюдаемо и когда malloc не повторил адрес.
- `lmx_post_init` каждой взятой ячейки — `LMX_POST_OK`. Когда куча повторила адрес, это post_init на переиспользованной ячейке; когда не повторила — ячейка новая, и факт D-43 держит проверка списка.
- `reused=` печатается и не является отказом. Проверка `recycled >= 1` снимается.
- Строки harness не меняются: селфтест не в eternal-runs.

## Мутант

`lmx_gc_drop_arrays_in_block` сразу возвращается (`1 = 1` в условии). Пул остаётся в `arena\arrays`. Селфтест останавливает раунды на первом таком ответе, чтобы следующий take не шёл по уже освобождённому блоку.

Замер на машине: мутант только в копии стейджа, ядро в git не менялось. Условие `lmx_gc_drop_arrays_in_block` заменено на `if: 1 = 1` и сразу `return`. RED: строка `FAIL D-43 embedded pool left the arena`, `checks=9 failures=1 reused=0 post=216`, exit 1. Откат: `checks=25 failures=0 reused=4 post=216`, exit 0. `sizeof(LmxPost)` на этой машине (LLP64) — 216. Повтор адреса здесь есть (4 из 4 сравнений) и в отказ не входит. Полный прогон селфтеста — `build/l2src/20260925_150326`, та же строка `checks=25 failures=0`.

## RESULT

Ветка `grok/d78-post-sweep`, база main `1988903` (REVIEW 8cb73b0 OK, облако 232/233). Ядро не менялось. Свидетель — отсутствие `@ orphan\nodes` в `arena\arrays` после каждого collect и `post_init` OK. `checks=25` (было 21; снята одна проверка равенства адресов, добавлена одна на раунд). `reused=` только печать. Мутант RED exit 1, откат GREEN exit 0. Гейт: build 280/280 (`build/l2src/20260925_150326`), harness 400/400 (`build/l2_harness/20260925_150619`), L3 11/11, имена 69/128, check_docs OK. Класс 3 T4b — следующий код.

## Доктрина

Freelist ячеек ради свидетеля не добавляется. Поле ядра не добавляется. Класс 3 T4b — после этого среза.

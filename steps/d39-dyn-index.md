# D-39 (F-72): индекс own-массива — вычисленный size_t

Вместе с -203. Индекс `ELEM` / `ELEMPUT` больше не сырая ячейка `size`, положенная из десятичного литерала.

## Ядро

`lmx_walk_index` считает ребёнка 2. Годится только `size_t`. `int` не приводится. Сырая ячейка в слоте — не узел, `INVALID`.

Литерал транслятор кладёт как `LIT` size. Поле `size_t` — `AT` этой ячейки. Селфтест: «ELEM dynamic index AT -> 9». Мутант «читать ребёнка как size, не считая» ломает и литерал-`LIT`, и этот AT.

## Корень

`buf[i]` при `size_t: i` — walked `ELEMPUT`/`ELEM`. Свидетель `entry_dyn_array_index` (Entry 7). `int: i` — «mixed numeric types (a conversion)» (`entry_dyn_array_index_int_refused`). Нативный метод по-прежнему требует литерал в границах своего массива: статической проверки границ в рантайме L2 нет, а броска Bounds нет.

## c.*

`stack\columns[idx]` — не own-массив. `l2_own_index_tail` больше не забирает сырой `c.*`-корень под отказ литерала; запись идёт прежним C-индексом (`l2_index_head`), чтение склеивает токены. Каст `(@: c.NAME)` пишется как `(@: NAME)` — та же дверь, C-имя без префикса. `unit_indent_stack_field_index` переводится (`l2_p0_0\columns[l2_p0_1]`, `stack\columns[2]`). Не линкуется в harness: `lm_own_new_zero` не в замыкании ядра. До среза тот же файл отказывал «own array index requires an in-bounds primitive literal» (l2trans сборки `20260925_192542`).

## Гейт

build 282/282 (`build/l2src/20260925_210041`), harness 405/405 (`build/l2_harness/20260925_211143`), L3 11/11, имена 69/128, check_docs OK.

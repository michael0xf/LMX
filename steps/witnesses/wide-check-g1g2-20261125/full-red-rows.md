# Красные строки полного списка против расписки 2026-11-24

Сейчас отказов 56 в 19 программах; в расписке W3 — 52 в 18 программах. Сравнение по строке FAIL целиком (имя, режим, корень, ожидание, класс) и по паре имя–режим.

## Прежние отказы с той же распиской: 48

- `callable_place_fields`: forced root0, forced root1, native root0, native root1
- `explicit_data_var_field`: forced root0, forced root1, native root0, native root1
- `free_c_abi`: forced root0, forced root1, native root0, native root1
- `held_structure_places`: forced root0, forced root1, native root0, native root1
- `immutable_reached_write`: forced, native
- `numeric_unavailable_norow`: forced root0, forced root1, native root0, native root1
- `place_map`: forced root0, forced root1, native root0, native root1
- `place_write_form`: forced root0, forced root1, native root0, native root1
- `source_occurrences`: forced, native
- `structure_path_write`: forced, native
- `sub_parts`: forced, native
- `unit_n4_inline_named_incompatible`: forced root0, forced root1, native root0, native root1
- `var_own_fields`: forced, native
- `var_own_nested`: forced, native
- `written_form`: forced, native
- `written_path_form`: forced, native

## Прежние отказы с изменившейся строкой: 0


## Красные сейчас без сопоставимой расписки: 8

- `FAIL immutable_formal native root0: gives 7: driver exit 3 [RUN]`

- `FAIL immutable_formal native root1: gives 7: driver exit 3 [RUN]`

- `FAIL immutable_formal_cell native root0: gives 7: driver exit 3 [RUN]`

- `FAIL immutable_formal_cell native root1: gives 7: driver exit 3 [RUN]`

- `FAIL graph_call_frames native root0: gives 7: driver exit 1 [EXIT]`

- `FAIL graph_call_frames native root1: gives 7: driver exit 1 [EXIT]`

- `FAIL graph_call_frames forced root0: gives 7: driver exit 1 [EXIT]`

- `FAIL graph_call_frames forced root1: gives 7: driver exit 1 [EXIT]`


## Расписки, зелёные сейчас: 4

- `FAIL free_model_admit native root0: gives 7: driver exit 1 [EXIT]`
- `FAIL free_model_admit native root1: gives 7: driver exit 1 [EXIT]`
- `FAIL free_graph_address native root0: gives 7: driver exit 1 [EXIT]`
- `FAIL free_graph_address native root1: gives 7: driver exit 1 [EXIT]`

## Программы, красные сейчас (19)

`callable_place_fields`, `explicit_data_var_field`, `free_c_abi`, `graph_call_frames`, `held_structure_places`, `immutable_formal`, `immutable_formal_cell`, `immutable_reached_write`, `numeric_unavailable_norow`, `place_map`, `place_write_form`, `source_occurrences`, `structure_path_write`, `sub_parts`, `unit_n4_inline_named_incompatible`, `var_own_fields`, `var_own_nested`, `written_form`, `written_path_form`

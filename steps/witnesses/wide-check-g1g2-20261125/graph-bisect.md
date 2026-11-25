# Красные строки набора графа вне списка регрессии — по комплектам

58 строк (109 красных на G2 минус 51 со списком регрессии малых правок), вход — фикстуры коммита 02e0aced0, прогон на шести прежних комплектах (W3, typed297, K4, K3n часть 1, K3n часть 2, K5a).

## green on every earlier set, red from this border (G2 only): 0



## turned red after W3: 0



## red on W3 too (the same verdict): 44

`admission_structure_index`, `admission_structure_snapshot`, `admission_structure_values`, `anonymous_code_value`, `body_fields`, `bridge_calls_structure`, `bridge_explicit_wide`, `bridge_fn_dispatch`, `bridge_head_once`, `bridge_local_head`, `call_frame_local`, `code_data`, `codebody_boundaries`, `codebody_own`, `computed_body_number_refused`, `control_flow`, `data_declared_method`, `declare_forms`, `declare_merge`, `deferred_binding_priority`, `defined_call_actuals`, `descriptor_merge`, `finally_scope`, `flow_bare_return_ends_body`, `fn_new_name`, `fn_prepared`, `fn_return_forms`, `frame_place_double`, `grouped_actual_contract`, `head_selected`, `inner_write_local`, `level2_record_file`, `level2_record_hidden`, `level2_record_root`, `level2_record_structure_argument`, `level2_record_structure_argument_block`, `marks_ref_code_private`, `merge_arguments`, `merge_code_descriptions`, `merge_held`, `merge_nested_part`, `ordinary_nested_methods`, `own_initializer`, `path_write_double_field`

## red on W3 too (another verdict): 13

`bridge_explicit_store`, `bridge_reference_store`, `r0_exit_text`, `received_assignment_preflight_refused`, `reference_work`, `root_computed_namespace`, `root_occurrence_index`, `selector_colon`, `slot_atom_replace`, `slot_context_reset`, `struct_index_admit`, `sub_calls`, `whole_arguments`

## not finished / not run: 1

`post_loop`

## Таблица

| строка | pin | зелёна последний раз | красна с | вердикт G2 (режимы; ответы) |
| --- | --- | --- | --- | --- |
| `admission_structure_index` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans4 n:stop f:stop = W3 |
| `admission_structure_snapshot` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok = W3 |
| `admission_structure_values` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `anonymous_code_value` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `body_fields` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `bridge_calls_structure` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `bridge_explicit_store` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop |
| `bridge_explicit_wide` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `bridge_fn_dispatch` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `bridge_head_once` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `bridge_local_head` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `bridge_reference_store` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop |
| `call_frame_local` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `code_data` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans5 n:stop f:stop = W3 |
| `codebody_boundaries` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `codebody_own` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans5 n:stop f:stop = W3 |
| `computed_body_number_refused` | 1 1 1 | — | W3 и ранее | i=FAIL n=PASS f=PASS i:ans4 n:stop f:stop = W3 |
| `control_flow` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `data_declared_method` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans4 n:stop f:stop = W3 |
| `declare_forms` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok = W3 |
| `declare_merge` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok = W3 |
| `deferred_binding_priority` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `defined_call_actuals` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok = W3 |
| `descriptor_merge` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `finally_scope` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `flow_bare_return_ends_body` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok = W3 |
| `fn_new_name` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `fn_prepared` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `fn_return_forms` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans5 n:stop f:stop = W3 |
| `frame_place_double` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans4 n:stop f:stop = W3 |
| `grouped_actual_contract` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans4 n:stop f:stop = W3 |
| `head_selected` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `inner_write_local` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok = W3 |
| `level2_record_file` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `level2_record_hidden` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `level2_record_root` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `level2_record_structure_argument` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `level2_record_structure_argument_block` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok = W3 |
| `marks_ref_code_private` | 1 1 3 | — | W3 и ранее | i=FAIL n=PASS f=PASS i:ans4 n:stop f:stop = W3 |
| `merge_arguments` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `merge_code_descriptions` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `merge_held` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `merge_nested_part` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok = W3 |
| `ordinary_nested_methods` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop = W3 |
| `own_initializer` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans5 n:stop f:stop = W3 |
| `path_write_double_field` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans4 n:stop f:stop = W3 |
| `post_loop` | 0 1 0 | — | — | w3:time-out typed297:time-out k4:no verdict k3n:time-out k3n2:time-out k5a:time-out |
| `r0_exit_text` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:? n:? f:? |
| `received_assignment_preflight_refused` | 1 1 4 | — | W3 и ранее | i=FAIL n=PASS f=PASS i:ans3 n:stop f:stop |
| `reference_work` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop |
| `root_computed_namespace` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ok n:ok f:ok |
| `root_occurrence_index` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop |
| `selector_colon` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop |
| `slot_atom_replace` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop |
| `slot_context_reset` | 1 2 4 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:? n:? f:? |
| `struct_index_admit` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans3 n:stop f:stop |
| `sub_calls` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:ans4 n:stop f:stop |
| `whole_arguments` | 0 1 0 | — | W3 и ранее | i=FAIL n=FAIL f=FAIL i:? n:? f:? |

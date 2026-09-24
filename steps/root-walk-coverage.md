# Interpreted root: what `lmx_walk` covers of the fixtures' root bodies (Opus, measure-first)

This is read-only preparation for the translator ticket that follows Grok's -156: plan §3, «Пользовательский код интерпретируется по умолчанию», the «Транслятор» item (`next_core_tasks.md` :254). It was measured on `e67c900`, and nothing in the tree was changed. Re-measure G2 and G3 once -156 lands, because it touches dispatch.

## How it was counted

- **Rows.** The 325 fixture rows of `tools/l2_harness.ps1`. The harness total of 327 is these plus `build:l2trans` and `build:eternal_driver`.
  - By expectation: eternal-runs 193, l2trans-refuses 109, translates-with-debt 20, toolchain-refuses 2, library-links 1.
  - Trees come from printTree built on the current parser (pin AC4A2210). 324 rows parse. `unit_empty_struct_hanging_refused` is refused by P0, as intended.
- **Root body.** Every top-level statement except the `fn`/`sub`/`fm` definitions.
  - `L2:` blocks and anonymous `---` blocks are transparent.
  - The bodies of `if`/`while`/`else`/`catch` are followed.
  - Names resolve against the file's own declarations: methods and named Structures first, then own fields in source order.
  - Paths resolve through the declared Structures' field tables, copies and merges included.
- **Heuristic.** The census is heuristic. Rows it cannot place form their own class, K9, and are listed.
- **Signatures and pins.** Native signatures and Debt pins are read from the generated L1 of the last full harness run. That run used -157 commit 1 (`f8b6fa7`). Commit 2 changed no generated L1 except its own new row.
- **Scripts.** They live outside the tree, in scratch: `n_root/{trees,classify2,classes,sigs,debtloc}.py`.

## What the walker has

- The roles are `ret call lit own arg at put set add sub lt eq if while of prim expect_int` (`dev/l2src_sandbox/lmx_walk.h.lm1` :112–:129, codes :188–:213).
- A value is an int or a reference. Own fields are int only.
- There is no throw, poll, array or dynamic input (:141–:148).
- The translator emits no op tree yet: `LMX_WALK_OP_` occurs 0 times in `l2trans.lm1`.

## Four gaps every walked root meets

### G1. Calls into native methods

`lmx_walk_call` (`lmx_walk.lm1` :516) runs a callee only through the walker: "Never METHOD.addr / lmx_call0 for walk execution" (:575–:576).

- **The one native bridge.** It is `prim`, with the single uniform entry `LmxPrimitiveEntry (owner; refs; nargs; dest; out)` (`lmx_primitive.h.lm1` :67).
- **Native signatures stay typed.** There are two ABIs:
  - value ABI: `(node, self, args…)`, which returns the value;
  - throw ABI: `(node, self, l2_msg, l2_out_result, l2_out_throw)`, which returns a status and also takes the Message.
- **How many rows need it.** 130 of the 193 eternal-runs rows call a method from the root.

The shapes E calls today, with the number of eternal-runs rows using each:

| ABI | result (arguments) | rows |
|---|---|---|
| value | `int ()` | 52 |
| status | `@: int ()` | 20 |
| value | `int (int)` | 19 |
| value | `int (@: Lmx)` | 10 |
| status | `@: size_t ()` | 7 |
| value | `int (int, int)` | 6 |
| status | `@: int (int)` | 5 |
| value | `size_t ()` | 3 |
| 16 other shapes | size_t, char, unsigned, ulong or pointer arguments or results | 1–2 each |

### G2. The root's value

`lmx_walk_body` drops the value of every step (:874). A value leaves only through `ret` with an operand.

The norm is that the root's value is its last evaluated expression, so `7` followed by a bare `return` gives 7. That rule is part of the kernel item (plan :253 (а)).

### G3. Declarations among the root's fields

The root is a Structure. Its fields are its declarations and its steps, in lexical order.

`lmx_walk_body` (:879–:912) handles a Structure child in one of two ways:
- If the child is callable, it activates it (:898, the D-03 bare-statement rule).
- Otherwise, it refuses the child as UNSUPPORTED (:905).

It does not tell a declaration from a statement:
- A declaration is a child whose structural parent is the body.
- A statement is a reference to an occurrence held elsewhere. The selftest builds D-03 that way, as `ref(bare_stmt, 1U, tracer)` (`tests/lmx_walk_selftest.lm1` :603), and it builds the refused plain Structure as a child (:612).

Read as written, the walk stops at the first declaration it meets:
- **A native method** is activated. `lmx_walk_enter` finds a descriptor with no plan and no steps and answers NOT_CALLABLE (:982–:988), so the walk stops there.
- **A callable Structure that has a plan** would run at its declaration.
- **A plain Structure** is UNSUPPORTED.

177 of the 193 eternal-runs rows declare at least one of these at root:
- 154 declare a method;
- 83 declare a named, profile or empty Structure;
- 35 declare a copy or a merge.

The walker already uses the parent test elsewhere. `lmx_walk_order` (:341) says: "a child belongs to that tree when `s` is its immediate structural parent".

A related layout point: once the steps become fields of the root, the field indices that methods use to address the root, `(l2_unit_ref, J)`, must count them. All 29 such sites go through one choke point (`steps/merge-offset-sites.md`).

### G4. `return: V` at root

The norm refuses `return: V` at root, so each one becomes `V` followed by a bare `return`. That includes the early exits inside root `if` bodies, such as `if: ov != 42` / `return: 81`.

There are 509 in 314 rows:

| expectation | statements | rows |
|---|---|---|
| eternal-runs | 372 | 189 |
| l2trans-refuses | 115 | 103 |
| translates-with-debt | 20 | 20 |
| toolchain-refuses | 2 | 2 |

The plan's "~300 строк" counts only the tails.

## Classes

Each row is placed in the highest class it needs.
- Classes K0–K7 are cumulative, and a higher class means more walker work.
- K8 and K9 override that order. K8 takes every row with L2 at root, and K9 every row the census could not place.

| class | the root needs | eternal-runs | translates-with-debt | toolchain-refuses | library-links | l2trans-refuses |
|---|---|---|---|---|---|---|
| K0 | the int core (int own fields, literals, `add`/`sub`/`lt`/`eq`, `if`/`while`) with no call from the root; at most G2–G4 | 16 | 20 | 0 | 1 | 28 |
| K1 | + G1 (calls into native methods) | 78 | 0 | 1 | 0 | 31 |
| K2 | + Structures as graph data: int fields by path (`at`/`put`), a Structure passed by reference | 0 | 0 | 0 | 0 | 2 |
| K3 | + merge (`Model: fresh`, `x: merge: A B`) | 7 | 0 | 0 | 0 | 4 |
| K4 | + non-int values, arrays, `*` `/` `%` and bit operators | 32 | 0 | 0 | 0 | 5 |
| K5 | + throw/catch at root | 9 | 0 | 0 | 0 | 5 |
| K6 | + `nextMessage` / `mainArgs` (S3 mail) | 18 | 0 | 0 | 0 | 4 |
| K7 | + `implements` | 6 | 0 | 0 | 0 | 0 |
| K8 | L2 at root (`c.*`, `@`, `\p`, `sizeof:`, `cast:`, a predef C function): first moves into a method | 19 | 0 | 1 | 0 | 11 |
| K9 | not placed by the census | 8 | 0 | 0 | 0 | 18 |
| total | | 193 | 20 | 2 | 1 | 108 |

Two patterns do not change a row's class:
- **Derived operators** (`!=`, `>`, `<=`, `>=`, `!`, `&&`, `||`) appear in 86 eternal-runs roots. They lower onto `sub`/`eq`/`lt` and nested `if`, so they place no row higher.
- **Structures by path** appear in 19 eternal-runs rows, never alone: every such row also needs something from K3–K9.

## The first batch

K0 and K1 together hold 94 eternal-runs rows. With them come the 20 translates-with-debt rows, the library-links row and one toolchain row.

They need two things:
- an op tree covering int own fields, literals, `add`/`sub`/`lt`/`eq` (derived operators lowered), `if`/`while` and `call`;
- G1–G4.

Within K1:
- **75 of the 78 rows** call only methods that return int (or nothing), with int or Structure arguments.
  - 59 of them use only the value ABI.
  - 16 also use the throw ABI: `unit_colon_method_dynamic_precedence`, `unit_colon_method_fresh_per_activation`, `unit_colon_method_lexical_model`, `unit_field_path_nested_two`, `unit_local_model_arg`, `unit_merge_in_method`, `unit_raw_root_formal_compound`, `unit_raw_root_model_compound`, `unit_s1_catch_merge_local`, `unit_s1_catch_tc`, `unit_s1_implements_uncaught`, `unit_s1_merge_profiles_uncaught`, `unit_s1_merge_uncaught`, `unit_s1_return_callable_throw_abi`, `unit_s1_return_callable_throw_abi_fails`, `unit_s1_trailer_value`.
- **The other 3:**
  - `unit_asgn_fallback` passes a char argument;
  - `unit_ptr_grow` passes pointer arguments;
  - `unit_csizeof_operand_lowered` was not in that run. Its root calls `check () int`, which uses the value ABI.

So the smallest first slice is the 16 K0 rows plus the 60 value-ABI rows of K1: 76 rows. Its bridge needs to carry only int results and int or Structure arguments.

## Refusal rows

- 103 of the 108 parsed refusal rows have a root `return: V`, and 11 have L2 at root.
- Under the norm, both become new located refusals, so the refusal a row reports then depends on check order.
- Every refusal row's needle must therefore be re-verified after its tail rewrite, not only the runnable rows.

## Harness text that moves with the root

- **The statement count.** `# entry statements: N` (`tools/l2_harness.ps1` :469 and :1860) counts E's statements. Eternal-runs rows need N > 0 unless they set `EmptyEntry`, and E goes away.
- **Debt pins.** There are 302 in the rows that run or translate.
  - 112 sit in methods and stay.
  - 34 sit in E and 119 in the entry adapter (the graph build and the call of E). These move with the root.
  - 37 sit in the unit header.
  - By row: 47 eternal-runs rows have every Debt pin in root code, 38 have some there, and 21 have none. The 20 translates-with-debt rows have none.
- **Absent pins.** 105 rows carry at least one. A pin that forbids text in E can no longer fail once E is gone, so each such pin must be re-pointed or dropped (the witness rule).

## Class lists (eternal-runs)

- K0 (16): `entry_return7`, `unit_call_args_refuse_struct`, `unit_eternal_branch`, `unit_eternal_many`, `unit_eternal_num_fields`, `unit_eternal_two`, `unit_field_path_array_dispatch`, `unit_for_root_hosted_field`, `unit_forj_sib`, `unit_matrix_noncall_prim_asgn`, `unit_occ_self_field`, `unit_os_prologue`, `unit_s1_declared_links`, `unit_s1_declared_payload`, `unit_s1_throws_intern`, `unit_s2_empty_program`.
- K1 (78): `unit_addr_own_array_element`, `unit_addr_take`, `unit_anon_block`, `unit_arg_addr_dyn_types`, `unit_arg_addr_dynamic`, `unit_arg_addr_ordinary`, `unit_arg_addr_sticky`, `unit_asgn_fallback`, `unit_bare_fn_stmt`, `unit_bare_sub_stmt`, `unit_c_member_len`, `unit_c_member_twohop`, `unit_c_member_write`, `unit_call_args_control_split`, `unit_call_args_controls`, `unit_call_args_empty_paren`, `unit_call_args_empty_vertical`, `unit_call_args_paren_seq`, `unit_callable_formal_descriptor`, `unit_callable_priority`, `unit_colon_callable_receiver`, `unit_colon_existing_value_update`, `unit_colon_explicit_parent_update`, `unit_colon_formal_update`, `unit_colon_hidden_update`, `unit_colon_method_dynamic_precedence`, `unit_colon_method_fresh_per_activation`, `unit_colon_method_lexical_model`, `unit_csizeof_operand_lowered`, `unit_dyn_hidden_from_cross_method`, `unit_empty_struct_decl`, `unit_eternal_physical_profiles`, `unit_field_path_nested_two`, `unit_field_write_from_method`, `unit_forj_parent`, `unit_forj_stale`, `unit_forward_oneline`, `unit_lit_range_bounds_ok`, `unit_local_model_arg`, `unit_matrix_absent_struct_decl`, `unit_matrix_callable_callable_arg`, `unit_matrix_callable_prim`, `unit_matrix_empty_arglist`, `unit_merge_in_method`, `unit_nested_body_else`, `unit_nested_body_for`, `unit_nested_body_while`, `unit_node_path_nested_own`, `unit_occ_arg_slots`, `unit_occ_snapshot_selector`, `unit_occ_sticky_selector`, `unit_own_dirty_rhs`, `unit_own_find_last_call_arg`, `unit_p0_with_include`, `unit_ptr_grow`, `unit_puts_method_body`, `unit_raw_root_c_control_compound`, `unit_raw_root_formal_compound`, `unit_raw_root_model_compound`, `unit_return_literal_int_max`, `unit_return_trailer_call`, `unit_s1_catch_merge_local`, `unit_s1_catch_tc`, `unit_s1_implements_uncaught`, `unit_s1_merge_profiles_uncaught`, `unit_s1_merge_uncaught`, `unit_s1_return_callable_throw_abi`, `unit_s1_return_callable_throw_abi_fails`, `unit_s1_trailer_value`, `unit_s2_vis_dynamic`, `unit_sizeof_array_bytes`, `unit_sizeof_c_door_arena`, `unit_sizeof_struct_ref`, `unit_sizeof_type_frame`, `unit_sizeof_type_int`, `unit_sub_return_trailer`, `unit_universal_head_resolution`, `unit_value_call_formal`.
- K3 (7): `unit_array_empty`, `unit_colon_model_decl`, `unit_eternal_multi_profile_merge_refused`, `unit_field_path_terminal_checklist`, `unit_merge_last_occurrence`, `unit_s1_merge_uncaught_entry`, `unit_struct_int_field`.
- K4 (32): `entry_array_leading_zero`, `unit_addr_arg`, `unit_addr_depth`, `unit_arg_addr_types`, `unit_arrarr_field`, `unit_array_field`, `unit_bare_in_method`, `unit_bare_literal_stmt`, `unit_c_member_struct_control`, `unit_eternal_shape`, `unit_eternal_xref`, `unit_field_path_formal`, `unit_field_path_formal_value`, `unit_field_path_nested`, `unit_field_path_own_write`, `unit_field_path_unit_colon`, `unit_field_path_unit_qualified`, `unit_matrix_callable_array_elem`, `unit_matrix_callable_struct_identity`, `unit_matrix_path_array_elem`, `unit_matrix_path_prim`, `unit_merge_site`, `unit_model_fresh_synonyms`, `unit_native_activation`, `unit_node_root_unit_field`, `unit_recursion`, `unit_sizeof_own_local`, `unit_struct_num_fields`, `unit_struct_return`, `unit_throwing_callable`, `unit_typed_decl_vertical`, `unit_value_call_result`.
- K5 (9): `unit_empty_assign_admit`, `unit_empty_assign_named`, `unit_s1_catch_declared_vs_merge`, `unit_s1_catch_declared_vs_merge_ok`, `unit_s1_catch_nested_while`, `unit_s1_catch_publish`, `unit_s1_catch_rethrow`, `unit_s1_catch_sibling`, `unit_s1_catch_t2`.
- K6 (18): `entry_argc`, `entry_argc_if`, `unit_admit_formal_refused`, `unit_admit_letter_coarse`, `unit_admit_letter_extra_field`, `unit_admit_letter_formal`, `unit_admit_letter_not_model`, `unit_admit_letter_typed`, `unit_admit_rebind_read`, `unit_admit_rebind_refused`, `unit_charpp_return`, `unit_empty_assign_untyped`, `unit_entry_args`, `unit_next_message_in_method`, `unit_next_message_loop`, `unit_next_message_method_first`, `unit_next_message_twice`, `unit_s1_catch_implements`.
- K7 (6): `unit_implements_admission`, `unit_implements_argument`, `unit_implements_assignment`, `unit_implements_methods`, `unit_implements_namespace`, `unit_implements_return`.
- K8 (19): `entry_array`, `entry_index`, `entry_nul`, `entry_parse_min`, `entry_puts_empty`, `entry_puts_esc`, `entry_puts_hello`, `entry_puts_nl`, `entry_puts_seq`, `entry_strcmp`, `unit_addr_entry_name_collision`, `unit_addr_slot_structure_projection`, `unit_arg_addr_pointer`, `unit_arr_path_read`, `unit_char_own_publish`, `unit_field_path_unit_addr`, `unit_named_addr_gap`, `unit_own_find_last_sizeof`, `unit_puts_main_beside_method`.
- K9 (8): `unit_bare_own_stmt`, `unit_discard_calls`, `unit_discard_codex`, `unit_discard_forms`, `unit_implements_primitives`, `unit_occ_root_field`, `unit_occ_root_named`, `unit_s1_catch_user_break`. These use bare operator statements (the discard forms), occurrence paths (`bump\val`, `test\[N]x`), implements with type words, and a `break` inside a catch block.

# M11, шаг 8: механические списки по selfbuild/tests/dyn и selfbuild/tests/os_twins

Задание: чат fable2, сообщение «Задание от fable2» от 2026-11-11 (опись без правок файлов). Исполнитель: haiku2, помощник. Единственный созданный файл — этот отчёт; правок в репозитории нет.

## 0. Основа описи

- Файлы: `git ls-files 'selfbuild/tests/dyn/*.lm2' 'selfbuild/tests/os_twins/*.lm2'` — 150 файлов (dyn — 128, os_twins — 22).
- Рабочее дерево этих каталогов совпадает с HEAD: `git status -uno -- selfbuild/tests/dyn selfbuild/tests/os_twins` выводит пусто; счёт `git grep --cached` даёт те же числа, что по рабочему дереву.
- Команды только чтения: `git ls-files`, `git grep`, `git status -uno`. Сборок и lmxtool не было; файл `l2_driver_launch.err` не открывался.
- Строки-комментарии (начинаются с `#`) в списки не входят.

## Сводка

| Список | Что | Строк | Команда и её число совпадений |
|---|---|---:|---|
| 1 | двухаргументный `call:` в коде | **67** | `git grep -n -E '^[[:space:]]*call:[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]*$' -- 'selfbuild/tests/dyn/*.lm2' 'selfbuild/tests/os_twins/*.lm2'` → 67 |
| 2 | письмо `exit(exit_code: …; stdout: …; stderr: …)` | **155** (нестандартных 0) | `git grep -n -E 'exit\(exit_code: [^;]+; stdout: [^;]+; stderr: [^)]+\)' -- <те же пути>` → 155; все строки `exit[[:space:]]*\(` → 155 |
| 3 | прочая подача аргумента по голове | **0** (пограничных кандидатов 13) | `git grep -n -E '[A-Za-z0-9_\][[:space:]]*\([^()]*[;(][[:space:]]*[A-Za-z_][A-Za-z0-9_\]*[[:space:]]*:[^:=]' -- <те же пути>`, затем отброшены комментарии, строки `exit(` и строки с `fn:`, `sub:`, `fm:`, `catch:` в начале → 13 |

У списков 1 и 2 длина списка равна числу совпадений. У списка 3 кандидатов 13, а основной список пуст; все 13 разобраны в разделе 3.

Разделы 7–9 добавлены по запросу fable2: 7 — graph (рабочее дерево), 8 — прочие исходники (tools и остальные tests), 9 — сверка счёта 91 и 193/185 по всему selfbuild. Литералы Structure (3б) выделены отдельно, ответы fable2 учтены.

## 1. Список 1 — двухаргументный `call:`

Что считается: строка кода, где после `call:` ровно два токена (имя или путь с `\`), без комментария. Перестановка: `call: A B` → `call: B A`, отступ сохранён.

Не вошло: `call:` с одним аргументом — 23 строки (`git grep -n -E '^[[:space:]]*call:[[:space:]]+[^[:space:]]+[[:space:]]*$'` → 23); `catch: call ()` — 38 строк (пустые скобки, один аргумент); скобочная форма `call(…)` — 0 совпадений; `fncall` — 0.

Пять строк, где оба имени одинаковы, перестановка их не меняет; в таблице они отмечены.

| # | файл | строка | было (как есть) | станет (аргументы переставлены) |
|---:|---|---:|---|---|
| 1 | selfbuild/tests/dyn/code_write_words.lm2 | 72 | `    call: S1 D` | `    call: D S1` |
| 2 | selfbuild/tests/dyn/code_write_words.lm2 | 84 | `    call: S1 D` | `    call: D S1` |
| 3 | selfbuild/tests/dyn/data_source_cells.lm2 | 36 | `call: held D` | `call: D held` |
| 4 | selfbuild/tests/dyn/data_source_cells.lm2 | 37 | `call: T D` | `call: D T` |
| 5 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 27 | `call: held D` | `call: D held` |
| 6 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 73 | `call: WriteNine I` | `call: I WriteNine` |
| 7 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 74 | `call: WriteNine U` | `call: U WriteNine` |
| 8 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 75 | `call: WriteNine W` | `call: W WriteNine` |
| 9 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 78 | `call: WriteWide W` | `call: W WriteWide` |
| 10 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 81 | `call: AddressWide W` | `call: W AddressWide` |
| 11 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 84 | `call: CatchConvert W` | `call: W CatchConvert` |
| 12 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 87 | `call: CatchMissing W` | `call: W CatchMissing` |
| 13 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 102 | `call: WriteTyped I` | `call: I WriteTyped` |
| 14 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 108 | `call: CatchTypedConvert W` | `call: W CatchTypedConvert` |
| 15 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 119 | `call: CatchInnerConvert W` | `call: W CatchInnerConvert` |
| 16 | selfbuild/tests/dyn/held_structure_places.lm2 | 19 | `    call: chosen D` | `    call: D chosen` |
| 17 | selfbuild/tests/dyn/held_structure_places.lm2 | 27 | `call: chosen Good` | `call: Good chosen` |
| 18 | selfbuild/tests/dyn/held_structure_places.lm2 | 48 | `    call: held_link NumberData` | `    call: NumberData held_link` |
| 19 | selfbuild/tests/dyn/held_structure_places.lm2 | 55 | `call: held_link LinkData` | `call: LinkData held_link` |
| 20 | selfbuild/tests/dyn/immutable_reached_write.lm2 | 178 | `        call: held d` | `        call: d held` |
| 21 | selfbuild/tests/dyn/immutable_reached_write.lm2 | 186 | `        call: held_c d` | `        call: d held_c` |
| 22 | selfbuild/tests/dyn/immutable_reached_write.lm2 | 194 | `        call: held_write d` | `        call: d held_write` |
| 23 | selfbuild/tests/dyn/immutable_reached_write.lm2 | 202 | `        call: held_slot d` | `        call: d held_slot` |
| 24 | selfbuild/tests/dyn/place_map.lm2 | 146 | `    call: Writer Box\kid` | `    call: Box\kid Writer` |
| 25 | selfbuild/tests/dyn/place_map.lm2 | 198 | `    call: S1 D` | `    call: D S1` |
| 26 | selfbuild/tests/dyn/place_map.lm2 | 201 | `    call: S1 node` | `    call: node S1` |
| 27 | selfbuild/tests/dyn/place_map.lm2 | 208 | `    call: S1 Holder` | `    call: Holder S1` |
| 28 | selfbuild/tests/dyn/place_write_form.lm2 | 173 | `        call: VarAbsent VarAbsentData` | `        call: VarAbsentData VarAbsent` |
| 29 | selfbuild/tests/dyn/place_write_form.lm2 | 188 | `        call: VarNew VarNewData` | `        call: VarNewData VarNew` |
| 30 | selfbuild/tests/dyn/place_write_form.lm2 | 292 | `    call: VarWork VarData` | `    call: VarData VarWork` |
| 31 | selfbuild/tests/dyn/place_write_form.lm2 | 310 | `    call: VarRebound VarRebound` | `    call: VarRebound VarRebound` (имена равны, строка не меняется) |
| 32 | selfbuild/tests/dyn/source_occurrences.lm2 | 185 | `            call: Writer D` | `            call: D Writer` |
| 33 | selfbuild/tests/dyn/source_occurrences.lm2 | 188 | `            call: Writer Assigned` | `            call: Assigned Writer` |
| 34 | selfbuild/tests/dyn/source_occurrences.lm2 | 191 | `            call: D D` | `            call: D D` (имена равны, строка не меняется) |
| 35 | selfbuild/tests/dyn/source_occurrences.lm2 | 194 | `            call: Writer Copied` | `            call: Copied Writer` |
| 36 | selfbuild/tests/dyn/source_occurrences.lm2 | 197 | `            call: hits_writer node` | `            call: node hits_writer` |
| 37 | selfbuild/tests/dyn/source_occurrences.lm2 | 258 | `    call: D One` | `    call: One D` |
| 38 | selfbuild/tests/dyn/source_occurrences.lm2 | 269 | `    call: D One` | `    call: One D` |
| 39 | selfbuild/tests/dyn/source_occurrences.lm2 | 284 | `    call: Twice One` | `    call: One Twice` |
| 40 | selfbuild/tests/dyn/source_occurrences.lm2 | 287 | `    call: Writer Nest` | `    call: Nest Writer` |
| 41 | selfbuild/tests/dyn/split_copy_bound_data.lm2 | 13 | `    call: B inner_data` | `    call: inner_data B` |
| 42 | selfbuild/tests/dyn/split_copy_bound_data.lm2 | 21 | `    call: A D` | `    call: D A` |
| 43 | selfbuild/tests/dyn/split_copy_bound_data.lm2 | 27 | `    call: Copy D` | `    call: D Copy` |
| 44 | selfbuild/tests/dyn/split_formal_data.lm2 | 10 | `    call: S d` | `    call: d S` |
| 45 | selfbuild/tests/dyn/split_selected_code.lm2 | 17 | `    call: target D` | `    call: D target` |
| 46 | selfbuild/tests/dyn/structure_slot_write.lm2 | 361 | `        call: S1 D` | `        call: D S1` |
| 47 | selfbuild/tests/dyn/sub_parts.lm2 | 171 | `call: direct direct\var` | `call: direct\var direct` |
| 48 | selfbuild/tests/dyn/unary_data_selection.lm2 | 33 | `    call: NoData absent` | `    call: absent NoData` |
| 49 | selfbuild/tests/dyn/unary_data_selection.lm2 | 55 | `    call: held S` | `    call: S held` |
| 50 | selfbuild/tests/dyn/unary_data_selection.lm2 | 61 | `call: held X` | `call: X held` |
| 51 | selfbuild/tests/dyn/unit_n4_inline_named_incompatible.lm2 | 17 | `    call: S D` | `    call: D S` |
| 52 | selfbuild/tests/dyn/unit_n4_inline_named_rebind.lm2 | 19 | `    call: S1 D` | `    call: D S1` |
| 53 | selfbuild/tests/dyn/unit_n4_inline_named_rebind.lm2 | 27 | `    call: S2 D` | `    call: D S2` |
| 54 | selfbuild/tests/dyn/var_own_fields.lm2 | 108 | `call: s s\var` | `call: s\var s` |
| 55 | selfbuild/tests/dyn/var_own_fields.lm2 | 139 | `call: t D` | `call: D t` |
| 56 | selfbuild/tests/dyn/var_own_fields.lm2 | 143 | `call: wv E` | `call: E wv` |
| 57 | selfbuild/tests/dyn/var_own_nested.lm2 | 86 | `        call: one E` | `        call: E one` |
| 58 | selfbuild/tests/dyn/var_own_nested.lm2 | 140 | `call: one D` | `call: D one` |
| 59 | selfbuild/tests/dyn/written_form.lm2 | 133 | `    call: with_var with_var` | `    call: with_var with_var` (имена равны, строка не меняется) |
| 60 | selfbuild/tests/dyn/written_form.lm2 | 214 | `    call: with2 with2` | `    call: with2 with2` (имена равны, строка не меняется) |
| 61 | selfbuild/tests/dyn/written_form.lm2 | 427 | `    call: S D` | `    call: D S` |
| 62 | selfbuild/tests/dyn/written_form.lm2 | 438 | `        call: Twice Twice` | `        call: Twice Twice` (имена равны, строка не меняется) |
| 63 | selfbuild/tests/dyn/written_form.lm2 | 500 | `    call: Hand HandData` | `    call: HandData Hand` |
| 64 | selfbuild/tests/dyn/written_form.lm2 | 510 | `    call: Occ OccData` | `    call: OccData Occ` |
| 65 | selfbuild/tests/dyn/written_form.lm2 | 530 | `    call: Occ OccAgain` | `    call: OccAgain Occ` |
| 66 | selfbuild/tests/dyn/written_form.lm2 | 536 | `    call: Spelled SpelledData` | `    call: SpelledData Spelled` |
| 67 | selfbuild/tests/dyn/written_form.lm2 | 544 | `        call: Spelled SpelledNone` | `        call: SpelledNone Spelled` |

## 2. Список 2 — письмо выхода

Что считается: строка с `exit(exit_code: V; stdout: ""; stderr: "")`. Все 155 строк имеют стандартный вид: три поля в этом порядке, на одной строке. Перевод: двоеточие после каждого из трёх имён полей заменено на ` :=` (`exit_code: V` → `exit_code := V`); значения, префикс `send:` и отступ не менялись. Значения `exit_code` разные (имена, числа, вызовы вроде `m()`, `h\q`, `cells[1U]`, арифметика) — их я не трогал.

Нестандартных строк (другие имена полей, другой порядок, перенос на несколько строк) — 0. Таблица ниже — все 155.

| # | файл | строка | было (как есть) | станет (`:` → ` :=` у трёх полей) |
|---:|---|---:|---|---|
| 1 | selfbuild/tests/dyn/absent_head_definition.lm2 | 38 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 2 | selfbuild/tests/dyn/absent_head_return_refused.lm2 | 11 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 3 | selfbuild/tests/dyn/assign_in_structure_refused.lm2 | 12 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 4 | selfbuild/tests/dyn/assign_known.lm2 | 71 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 5 | selfbuild/tests/dyn/assign_method_name_refused.lm2 | 21 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 6 | selfbuild/tests/dyn/assign_quoted_head_limit.lm2 | 16 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 7 | selfbuild/tests/dyn/assign_typed_known.lm2 | 25 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 8 | selfbuild/tests/dyn/assign_typed_unknown_refused.lm2 | 12 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 9 | selfbuild/tests/dyn/assign_typed_unknown_root_refused.lm2 | 5 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 10 | selfbuild/tests/dyn/assign_typed_unknown_structure_refused.lm2 | 12 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 11 | selfbuild/tests/dyn/assign_unknown_refused.lm2 | 12 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 12 | selfbuild/tests/dyn/bound_order_axby.lm2 | 140 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 13 | selfbuild/tests/dyn/bound_typed_reception.lm2 | 122 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 14 | selfbuild/tests/dyn/callable_place_fields.lm2 | 319 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 15 | selfbuild/tests/dyn/callable_place_signature.lm2 | 261 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 16 | selfbuild/tests/dyn/code_write_words.lm2 | 178 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 17 | selfbuild/tests/dyn/colon_absent_reference_refused.lm2 | 9 | `send: exit(exit_code: h\q; stdout: ""; stderr: "")` | `send: exit(exit_code := h\q; stdout := ""; stderr := "")` |
| 18 | selfbuild/tests/dyn/colon_known_body_refused.lm2 | 9 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 19 | selfbuild/tests/dyn/colon_known_call_refused.lm2 | 12 | `send: exit(exit_code: f(); stdout: ""; stderr: "")` | `send: exit(exit_code := f(); stdout := ""; stderr := "")` |
| 20 | selfbuild/tests/dyn/colon_known_deref_refused.lm2 | 10 | `send: exit(exit_code: f(); stdout: ""; stderr: "")` | `send: exit(exit_code := f(); stdout := ""; stderr := "")` |
| 21 | selfbuild/tests/dyn/colon_known_index_refused.lm2 | 5 | `send: exit(exit_code: cells[1U]; stdout: ""; stderr: "")` | `send: exit(exit_code := cells[1U]; stdout := ""; stderr := "")` |
| 22 | selfbuild/tests/dyn/colon_known_literal_refused.lm2 | 8 | `send: exit(exit_code: f(); stdout: ""; stderr: "")` | `send: exit(exit_code := f(); stdout := ""; stderr := "")` |
| 23 | selfbuild/tests/dyn/colon_known_name_refused.lm2 | 9 | `send: exit(exit_code: f(); stdout: ""; stderr: "")` | `send: exit(exit_code := f(); stdout := ""; stderr := "")` |
| 24 | selfbuild/tests/dyn/colon_known_path_refused.lm2 | 10 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 25 | selfbuild/tests/dyn/colon_known_root_refused.lm2 | 5 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 26 | selfbuild/tests/dyn/comma_boundary.lm2 | 94 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 27 | selfbuild/tests/dyn/comma_path_refused.lm2 | 9 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 28 | selfbuild/tests/dyn/comma_requirement_refused.lm2 | 13 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 29 | selfbuild/tests/dyn/composed_declares_structure.lm2 | 42 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 30 | selfbuild/tests/dyn/composed_field_refused.lm2 | 7 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 31 | selfbuild/tests/dyn/composed_known_refused.lm2 | 10 | `send: exit(exit_code: f(); stdout: ""; stderr: "")` | `send: exit(exit_code := f(); stdout := ""; stderr := "")` |
| 32 | selfbuild/tests/dyn/composed_known_root_refused.lm2 | 5 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 33 | selfbuild/tests/dyn/composed_reference_refused.lm2 | 5 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 34 | selfbuild/tests/dyn/composed_value_method_refused.lm2 | 8 | `send: exit(exit_code: f(); stdout: ""; stderr: "")` | `send: exit(exit_code := f(); stdout := ""; stderr := "")` |
| 35 | selfbuild/tests/dyn/composed_value_refused.lm2 | 6 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 36 | selfbuild/tests/dyn/copy_name_codes.lm2 | 58 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 37 | selfbuild/tests/dyn/data_source_cells.lm2 | 11 | `        send: exit(exit_code: 84; stdout: ""; stderr: "")` | `        send: exit(exit_code := 84; stdout := ""; stderr := "")` |
| 38 | selfbuild/tests/dyn/data_source_cells.lm2 | 16 | `        send: exit(exit_code: 85; stdout: ""; stderr: "")` | `        send: exit(exit_code := 85; stdout := ""; stderr := "")` |
| 39 | selfbuild/tests/dyn/data_source_cells.lm2 | 23 | `        send: exit(exit_code: 86; stdout: ""; stderr: "")` | `        send: exit(exit_code := 86; stdout := ""; stderr := "")` |
| 40 | selfbuild/tests/dyn/data_source_cells.lm2 | 30 | `        send: exit(exit_code: 87; stdout: ""; stderr: "")` | `        send: exit(exit_code := 87; stdout := ""; stderr := "")` |
| 41 | selfbuild/tests/dyn/data_source_cells.lm2 | 41 | `send: exit(exit_code: answer; stdout: ""; stderr: "")` | `send: exit(exit_code := answer; stdout := ""; stderr := "")` |
| 42 | selfbuild/tests/dyn/declaration_site.lm2 | 17 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 43 | selfbuild/tests/dyn/entry_admission_order.lm2 | 286 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 44 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 5 | `        send: exit(exit_code: 84; stdout: ""; stderr: "")` | `        send: exit(exit_code := 84; stdout := ""; stderr := "")` |
| 45 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 14 | `        send: exit(exit_code: 85; stdout: ""; stderr: "")` | `        send: exit(exit_code := 85; stdout := ""; stderr := "")` |
| 46 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 43 | `        send: exit(exit_code: 86; stdout: ""; stderr: "")` | `        send: exit(exit_code := 86; stdout := ""; stderr := "")` |
| 47 | selfbuild/tests/dyn/explicit_data_var_field.lm2 | 123 | `send: exit(exit_code: answer; stdout: ""; stderr: "")` | `send: exit(exit_code := answer; stdout := ""; stderr := "")` |
| 48 | selfbuild/tests/dyn/formal_default_form_refused.lm2 | 13 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 49 | selfbuild/tests/dyn/formal_default_none_refused.lm2 | 10 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 50 | selfbuild/tests/dyn/formal_default_type_refused.lm2 | 10 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 51 | selfbuild/tests/dyn/formal_defaults.lm2 | 213 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 52 | selfbuild/tests/dyn/free_c_abi.lm2 | 167 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 53 | selfbuild/tests/dyn/free_c_pointer.lm2 | 185 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 54 | selfbuild/tests/dyn/free_entry_binding.lm2 | 88 | `send: exit(exit_code: run_entries(); stdout: ""; stderr: "")` | `send: exit(exit_code := run_entries(); stdout := ""; stderr := "")` |
| 55 | selfbuild/tests/dyn/free_field_places.lm2 | 148 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 56 | selfbuild/tests/dyn/free_graph_address.lm2 | 107 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 57 | selfbuild/tests/dyn/free_held_model.lm2 | 50 | `send: exit(exit_code: check_point(); stdout: ""; stderr: "")` | `send: exit(exit_code := check_point(); stdout := ""; stderr := "")` |
| 58 | selfbuild/tests/dyn/free_held_receive.lm2 | 76 | `send: exit(exit_code: run_checks(); stdout: ""; stderr: "")` | `send: exit(exit_code := run_checks(); stdout := ""; stderr := "")` |
| 59 | selfbuild/tests/dyn/free_index_places.lm2 | 153 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 60 | selfbuild/tests/dyn/free_machine_ops.lm2 | 196 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 61 | selfbuild/tests/dyn/free_model_admit.lm2 | 103 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 62 | selfbuild/tests/dyn/free_name_chain.lm2 | 48 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 63 | selfbuild/tests/dyn/free_number_places.lm2 | 9 | `    send: exit(exit_code: quote; stdout: ""; stderr: "")` | `    send: exit(exit_code := quote; stdout := ""; stderr := "")` |
| 64 | selfbuild/tests/dyn/free_number_places.lm2 | 41 | `send: exit(exit_code: result; stdout: ""; stderr: "")` | `send: exit(exit_code := result; stdout := ""; stderr := "")` |
| 65 | selfbuild/tests/dyn/free_pointer_paths.lm2 | 154 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 66 | selfbuild/tests/dyn/free_result_convert.lm2 | 109 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 67 | selfbuild/tests/dyn/free_slot_rebind.lm2 | 107 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 68 | selfbuild/tests/dyn/free_value_consumers.lm2 | 100 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 69 | selfbuild/tests/dyn/free_value_types.lm2 | 114 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 70 | selfbuild/tests/dyn/held_structure_places.lm2 | 59 | `send: exit(exit_code: got; stdout: ""; stderr: "")` | `send: exit(exit_code := got; stdout := ""; stderr := "")` |
| 71 | selfbuild/tests/dyn/immutable_formal.lm2 | 32 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 72 | selfbuild/tests/dyn/immutable_formal_cell.lm2 | 15 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 73 | selfbuild/tests/dyn/immutable_reached_write.lm2 | 276 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 74 | selfbuild/tests/dyn/index_numeric_receive.lm2 | 136 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 75 | selfbuild/tests/dyn/index_numeric_unavailable.lm2 | 61 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 76 | selfbuild/tests/dyn/map_chain.lm2 | 233 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 77 | selfbuild/tests/dyn/merge_args_computed_default_refused.lm2 | 13 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 78 | selfbuild/tests/dyn/merge_args_model_formal_refused.lm2 | 13 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 79 | selfbuild/tests/dyn/merge_args_operand.lm2 | 108 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 80 | selfbuild/tests/dyn/merge_args_unfilled_refused.lm2 | 12 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 81 | selfbuild/tests/dyn/merge_assign_operand_refused.lm2 | 16 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 82 | selfbuild/tests/dyn/merge_named_field_operand.lm2 | 61 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 83 | selfbuild/tests/dyn/merge_named_field_refused.lm2 | 13 | `send: exit(exit_code: f(); stdout: ""; stderr: "")` | `send: exit(exit_code := f(); stdout := ""; stderr := "")` |
| 84 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 405 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 85 | selfbuild/tests/dyn/named_assign_actuals.lm2 | 94 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 86 | selfbuild/tests/dyn/named_assign_positional_after_refused.lm2 | 10 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 87 | selfbuild/tests/dyn/named_assign_quoted.lm2 | 16 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 88 | selfbuild/tests/dyn/named_assign_unknown_refused.lm2 | 10 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 89 | selfbuild/tests/dyn/numeric_unavailable_norow.lm2 | 127 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 90 | selfbuild/tests/dyn/numeric_unavailable_route.lm2 | 110 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 91 | selfbuild/tests/dyn/occurrence_bare_refused.lm2 | 9 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 92 | selfbuild/tests/dyn/occurrence_copy_refused.lm2 | 8 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 93 | selfbuild/tests/dyn/occurrence_glued_refused.lm2 | 4 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 94 | selfbuild/tests/dyn/occurrence_node_refused.lm2 | 8 | `send: exit(exit_code: read(); stdout: ""; stderr: "")` | `send: exit(exit_code := read(); stdout := ""; stderr := "")` |
| 95 | selfbuild/tests/dyn/occurrence_write_refused.lm2 | 7 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 96 | selfbuild/tests/dyn/part_root_hidden.lm2 | 41 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 97 | selfbuild/tests/dyn/place_map.lm2 | 266 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 98 | selfbuild/tests/dyn/place_write_form.lm2 | 338 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 99 | selfbuild/tests/dyn/place_write_number_refused.lm2 | 6 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 100 | selfbuild/tests/dyn/place_write_signature_refused.lm2 | 11 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 101 | selfbuild/tests/dyn/place_write_struct_refused.lm2 | 11 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 102 | selfbuild/tests/dyn/quoted_colon_head_limit.lm2 | 13 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 103 | selfbuild/tests/dyn/receiver_check_statement.lm2 | 50 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 104 | selfbuild/tests/dyn/receiver_check_structure_refused.lm2 | 9 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 105 | selfbuild/tests/dyn/receiver_literal_range.lm2 | 77 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 106 | selfbuild/tests/dyn/receiver_literal_unrepresentable_refused.lm2 | 9 | `send: exit(exit_code: f(); stdout: ""; stderr: "")` | `send: exit(exit_code := f(); stdout := ""; stderr := "")` |
| 107 | selfbuild/tests/dyn/root_pointer_index.lm2 | 137 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 108 | selfbuild/tests/dyn/source_occurrences.lm2 | 419 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 109 | selfbuild/tests/dyn/split_copy_bound_data.lm2 | 34 | `send: exit(exit_code: answer; stdout: ""; stderr: "")` | `send: exit(exit_code := answer; stdout := ""; stderr := "")` |
| 110 | selfbuild/tests/dyn/split_formal_data.lm2 | 17 | `send: exit(exit_code: result; stdout: ""; stderr: "")` | `send: exit(exit_code := result; stdout := ""; stderr := "")` |
| 111 | selfbuild/tests/dyn/split_selected_code.lm2 | 26 | `send: exit(exit_code: result; stdout: ""; stderr: "")` | `send: exit(exit_code := result; stdout := ""; stderr := "")` |
| 112 | selfbuild/tests/dyn/struct_call_selected.lm2 | 34 | `send: exit(exit_code: answer; stdout: ""; stderr: "")` | `send: exit(exit_code := answer; stdout := ""; stderr := "")` |
| 113 | selfbuild/tests/dyn/struct_call_throws.lm2 | 52 | `send: exit(exit_code: answer; stdout: ""; stderr: "")` | `send: exit(exit_code := answer; stdout := ""; stderr := "")` |
| 114 | selfbuild/tests/dyn/structure_path_write.lm2 | 141 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 115 | selfbuild/tests/dyn/structure_slot_write.lm2 | 607 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 116 | selfbuild/tests/dyn/sub_parts.lm2 | 185 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 117 | selfbuild/tests/dyn/sub_return_refused.lm2 | 7 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 118 | selfbuild/tests/dyn/typed_shift_guards.lm2 | 76 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 119 | selfbuild/tests/dyn/typed_value_write.lm2 | 31 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 120 | selfbuild/tests/dyn/unary_complement.lm2 | 106 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 121 | selfbuild/tests/dyn/unary_data_selection.lm2 | 64 | `send: exit(exit_code: answer; stdout: ""; stderr: "")` | `send: exit(exit_code := answer; stdout := ""; stderr := "")` |
| 122 | selfbuild/tests/dyn/unit_n4_inline_named_incompatible.lm2 | 28 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 123 | selfbuild/tests/dyn/unit_n4_inline_named_rebind.lm2 | 40 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 124 | selfbuild/tests/dyn/value_path_number_refused.lm2 | 6 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 125 | selfbuild/tests/dyn/var_own_fields.lm2 | 147 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 126 | selfbuild/tests/dyn/var_own_nested.lm2 | 147 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 127 | selfbuild/tests/dyn/var_own_repeat_receive.lm2 | 67 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 128 | selfbuild/tests/dyn/var_own_repeat_unavailable.lm2 | 60 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 129 | selfbuild/tests/dyn/whole_arguments.lm2 | 202 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 130 | selfbuild/tests/dyn/whole_direct_fields.lm2 | 50 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 131 | selfbuild/tests/dyn/whole_field_refused.lm2 | 23 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 132 | selfbuild/tests/dyn/written_form.lm2 | 561 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 133 | selfbuild/tests/dyn/written_path_form.lm2 | 109 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 134 | selfbuild/tests/os_twins/callable_value_os.lm2 | 26 | `send: exit(exit_code: r1 + seen() + 1; stdout: ""; stderr: "")` | `send: exit(exit_code := r1 + seen() + 1; stdout := ""; stderr := "")` |
| 135 | selfbuild/tests/os_twins/callable_value_unit.lm2 | 16 | `send: exit(exit_code: r1 + seen() + 1; stdout: ""; stderr: "")` | `send: exit(exit_code := r1 + seen() + 1; stdout := ""; stderr := "")` |
| 136 | selfbuild/tests/os_twins/calls_unit_below_os.lm2 | 26 | `send: exit(exit_code: count() + 4 + z; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 4 + z; stdout := ""; stderr := "")` |
| 137 | selfbuild/tests/os_twins/calls_unit_below_unit.lm2 | 15 | `send: exit(exit_code: count() + 4 + z; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 4 + z; stdout := ""; stderr := "")` |
| 138 | selfbuild/tests/os_twins/forward_header_os.lm2 | 19 | `send: exit(exit_code: early(3); stdout: ""; stderr: "")` | `send: exit(exit_code := early(3); stdout := ""; stderr := "")` |
| 139 | selfbuild/tests/os_twins/forward_header_unit.lm2 | 9 | `send: exit(exit_code: early(3); stdout: ""; stderr: "")` | `send: exit(exit_code := early(3); stdout := ""; stderr := "")` |
| 140 | selfbuild/tests/os_twins/hidden_input_os.lm2 | 15 | `send: exit(exit_code: os_get(2); stdout: ""; stderr: "")` | `send: exit(exit_code := os_get(2); stdout := ""; stderr := "")` |
| 141 | selfbuild/tests/os_twins/hidden_input_unit.lm2 | 6 | `send: exit(exit_code: os_get(2); stdout: ""; stderr: "")` | `send: exit(exit_code := os_get(2); stdout := ""; stderr := "")` |
| 142 | selfbuild/tests/os_twins/method_above_os.lm2 | 17 | `send: exit(exit_code: early(3); stdout: ""; stderr: "")` | `send: exit(exit_code := early(3); stdout := ""; stderr := "")` |
| 143 | selfbuild/tests/os_twins/method_above_unit.lm2 | 8 | `send: exit(exit_code: early(3); stdout: ""; stderr: "")` | `send: exit(exit_code := early(3); stdout := ""; stderr := "")` |
| 144 | selfbuild/tests/os_twins/named_call_below_os.lm2 | 28 | `send: exit(exit_code: count() + 4; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 4; stdout := ""; stderr := "")` |
| 145 | selfbuild/tests/os_twins/named_call_below_unit.lm2 | 18 | `send: exit(exit_code: count() + 4; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 4; stdout := ""; stderr := "")` |
| 146 | selfbuild/tests/os_twins/recursion_os.lm2 | 18 | `send: exit(exit_code: os_fact(3) + 1; stdout: ""; stderr: "")` | `send: exit(exit_code := os_fact(3) + 1; stdout := ""; stderr := "")` |
| 147 | selfbuild/tests/os_twins/recursion_unit.lm2 | 7 | `send: exit(exit_code: os_fact(3) + 1; stdout: ""; stderr: "")` | `send: exit(exit_code := os_fact(3) + 1; stdout := ""; stderr := "")` |
| 148 | selfbuild/tests/os_twins/root_colon_above_os.lm2 | 22 | `send: exit(exit_code: count() + 4; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 4; stdout := ""; stderr := "")` |
| 149 | selfbuild/tests/os_twins/root_colon_above_unit.lm2 | 11 | `send: exit(exit_code: count() + 4; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 4; stdout := ""; stderr := "")` |
| 150 | selfbuild/tests/os_twins/root_path_read_os.lm2 | 20 | `send: exit(exit_code: s + 1; stdout: ""; stderr: "")` | `send: exit(exit_code := s + 1; stdout := ""; stderr := "")` |
| 151 | selfbuild/tests/os_twins/root_path_read_unit.lm2 | 9 | `send: exit(exit_code: s + 1; stdout: ""; stderr: "")` | `send: exit(exit_code := s + 1; stdout := ""; stderr := "")` |
| 152 | selfbuild/tests/os_twins/root_vertical_above_os.lm2 | 22 | `send: exit(exit_code: count() + 4; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 4; stdout := ""; stderr := "")` |
| 153 | selfbuild/tests/os_twins/root_vertical_above_unit.lm2 | 13 | `send: exit(exit_code: count() + 4; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 4; stdout := ""; stderr := "")` |
| 154 | selfbuild/tests/os_twins/sub_call_os.lm2 | 20 | `send: exit(exit_code: count() + 5; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 5; stdout := ""; stderr := "")` |
| 155 | selfbuild/tests/os_twins/sub_call_unit.lm2 | 11 | `send: exit(exit_code: count() + 5; stdout: ""; stderr: "")` | `send: exit(exit_code := count() + 5; stdout := ""; stderr := "")` |

## 3. Список 3 — прочая подача аргумента по голове

Что искалось: `имя: значение` внутри скобок вызова, где перед скобками стоит идентификатор вызова; ищутся имена с двоеточием сразу после `(` или `;` внутри таких скобок. Шаблон даёт 87 строк; 74 из них — объявления `fn:` и `sub:` с описанием формалов (исключены), остаются 13. Все 13 — не подача по голове (ресиверы `int` и `cast`, литералы Structure внутри операндов `merge`), поэтому основной список пуст: **0** строк.

Исключено по определению задания: 155 строк `exit(...)` (список 2), строки-комментарии и 74 строки объявлений `fn:` и `sub:` с описанием формалов (таблица 3а, для сверки).

### 3а. Исключённые строки объявления `fn:`

| # | файл | строка | текст (как есть) | почему не подача по голове |
|---:|---|---:|---|---|
| Е1 | selfbuild/tests/dyn/assign_known.lm2 | 27 | `fn: swap (cb(fn: () int)) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е2 | selfbuild/tests/dyn/bound_order_axby.lm2 | 40 | `fn: g (int: u; int: v; char: x; char: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е3 | selfbuild/tests/dyn/bound_order_axby.lm2 | 43 | `fn: gq (int: p; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е4 | selfbuild/tests/dyn/bound_order_axby.lm2 | 46 | `fn: g2 (int: y; int: x) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е5 | selfbuild/tests/dyn/bound_order_axby.lm2 | 50 | `    fn: f (int: x; int: y; char: u; char: v) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е6 | selfbuild/tests/dyn/bound_order_axby.lm2 | 55 | `    fn: f (int: x; int: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е7 | selfbuild/tests/dyn/bound_order_axby.lm2 | 60 | `    fn: f (int: x 1; int: y 2) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е8 | selfbuild/tests/dyn/bound_typed_reception.lm2 | 23 | `fn: g (int: y; char: x) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е9 | selfbuild/tests/dyn/bound_typed_reception.lm2 | 27 | `fn: w (int: y; size_t: x) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е10 | selfbuild/tests/dyn/bound_typed_reception.lm2 | 32 | `    fn: f (int: x; char: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е11 | selfbuild/tests/dyn/bound_typed_reception.lm2 | 37 | `    fn: f (int: x; size_t: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е12 | selfbuild/tests/dyn/callable_place_fields.lm2 | 30 | `fn: var_later () int (int: y 9; int: v 6)` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е13 | selfbuild/tests/dyn/comma_boundary.lm2 | 14 | `fn: add (int: a; int: b) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е14 | selfbuild/tests/dyn/comma_boundary.lm2 | 17 | `fn: two (int: a; int: b) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е15 | selfbuild/tests/dyn/copy_name_codes.lm2 | 16 | `    fn: f (int: x; int: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е16 | selfbuild/tests/dyn/entry_admission_order.lm2 | 34 | `fn: take (Point: p; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е17 | selfbuild/tests/dyn/entry_admission_order.lm2 | 37 | `fn: g (Point: p; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е18 | selfbuild/tests/dyn/entry_admission_order.lm2 | 40 | `fn: num_take (int: n; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е19 | selfbuild/tests/dyn/entry_admission_order.lm2 | 43 | `fn: gn (int: n; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е20 | selfbuild/tests/dyn/entry_admission_order.lm2 | 46 | `fn: ptr_take (@@: pp Point; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е21 | selfbuild/tests/dyn/entry_admission_order.lm2 | 50 | `fn: gp (@@: pp Point; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е22 | selfbuild/tests/dyn/entry_admission_order.lm2 | 55 | `    fn: f (Point: p; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е23 | selfbuild/tests/dyn/entry_admission_order.lm2 | 60 | `    fn: f (int: n; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е24 | selfbuild/tests/dyn/entry_admission_order.lm2 | 65 | `    fn: f (@@: pp Point; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е25 | selfbuild/tests/dyn/formal_default_none_refused.lm2 | 3 | `fn: e (int: x; int: y 7) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е26 | selfbuild/tests/dyn/formal_defaults.lm2 | 10 | `fn: e (int: x; int: y 7) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е27 | selfbuild/tests/dyn/formal_defaults.lm2 | 13 | `fn: w (int: x 4; int: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е28 | selfbuild/tests/dyn/formal_defaults.lm2 | 37 | `sub: s (int: v 3; int: u)` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е29 | selfbuild/tests/dyn/formal_defaults.lm2 | 46 | `    fn: m (int: k 2; int: j) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е30 | selfbuild/tests/dyn/formal_defaults.lm2 | 128 | `fn: apply (f(fn: (int: a 5) int)) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е31 | selfbuild/tests/dyn/free_machine_ops.lm2 | 53 | `fn: typed_walked (unsigned: a; int: n) unsigned` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е32 | selfbuild/tests/dyn/index_numeric_receive.lm2 | 29 | `fn: get (@: p int; int: at) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е33 | selfbuild/tests/dyn/index_numeric_receive.lm2 | 32 | `sub: put (@: p int; int: at; int: v)` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е34 | selfbuild/tests/dyn/index_numeric_receive.lm2 | 41 | `fn: address_of (@: p int; int: at) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е35 | selfbuild/tests/dyn/merge_args_computed_default_refused.lm2 | 6 | `fn: comp (int: c 3; int: a 2 + 3) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е36 | selfbuild/tests/dyn/merge_args_model_formal_refused.lm2 | 6 | `fn: tst (Point: p; int: a) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е37 | selfbuild/tests/dyn/merge_args_operand.lm2 | 15 | `fn: tst (int: c 3; int: a) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е38 | selfbuild/tests/dyn/merge_args_operand.lm2 | 18 | `fn: two (int: c 3; int: a 4) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е39 | selfbuild/tests/dyn/merge_args_operand.lm2 | 21 | `fn: zed (int: c 3; int: z 0) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е40 | selfbuild/tests/dyn/merge_args_operand.lm2 | 24 | `fn: comp (int: c 3; int: a 2 + 3) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е41 | selfbuild/tests/dyn/merge_args_unfilled_refused.lm2 | 5 | `fn: tst (int: c 3; int: a) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е42 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 14 | `fn: g (int: y; int: x) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е43 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 17 | `fn: gd (int: y 6; int: x 8) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е44 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 26 | `fn: gm (int: y; char: x) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е45 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 30 | `    fn: f (int: x; int: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е46 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 35 | `    fn: f (int: x 1; int: y 2) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е47 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 50 | `    fn: f (int: x; char: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е48 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 317 | `fn: f0 (int: x; int: y) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е49 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 371 | `fn: h (int: b; int: a) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е50 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 374 | `fn: h2 (int: b 3; int: a 4) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е51 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 377 | `fn: apply (f(fn: (int: a; int: b) int)) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е52 | selfbuild/tests/dyn/named_actuals_selected.lm2 | 380 | `fn: apply2 (f(fn: (int: a 5; int: b 6) int)) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е53 | selfbuild/tests/dyn/named_assign_actuals.lm2 | 15 | `fn: tst (int: c 3; int: a 2) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е54 | selfbuild/tests/dyn/named_assign_positional_after_refused.lm2 | 3 | `fn: tst (int: c 3; int: a 2) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е55 | selfbuild/tests/dyn/named_assign_quoted.lm2 | 6 | `fn: tst (int: c 3; int: a) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е56 | selfbuild/tests/dyn/named_assign_unknown_refused.lm2 | 3 | `fn: tst (int: c 3; int: a 2) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е57 | selfbuild/tests/dyn/root_pointer_index.lm2 | 23 | `fn: get (@: p int; size_t: at) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е58 | selfbuild/tests/dyn/root_pointer_index.lm2 | 26 | `sub: put (@: p int; size_t: at; int: v)` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е59 | selfbuild/tests/dyn/struct_call_selected.lm2 | 16 | `fn: invoke (int: first_key; int: second_key; int: add_key) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е60 | selfbuild/tests/dyn/struct_call_selected.lm2 | 21 | `fn: invoke_ref (int: first_key; int: second_key; int: add_key) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е61 | selfbuild/tests/dyn/typed_shift_guards.lm2 | 2 | `fn: left (unsigned: value; int: count) unsigned` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е62 | selfbuild/tests/dyn/typed_shift_guards.lm2 | 5 | `fn: right (unsigned: value; int: count) unsigned` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е63 | selfbuild/tests/dyn/typed_shift_guards.lm2 | 8 | `fn: signed_left (int: value; int: count) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е64 | selfbuild/tests/dyn/typed_shift_guards.lm2 | 11 | `fn: wide_left (size_t: value; int: count) size_t` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е65 | selfbuild/tests/dyn/typed_shift_guards.lm2 | 14 | `fn: nested (unsigned: value; int: count) unsigned` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е66 | selfbuild/tests/dyn/whole_arguments.lm2 | 66 | `fn: mytest (int: c 3; int: a) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е67 | selfbuild/tests/dyn/whole_arguments.lm2 | 69 | `fn: g (Point: p; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е68 | selfbuild/tests/dyn/whole_arguments.lm2 | 72 | `fn: h (Point: pp; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е69 | selfbuild/tests/dyn/whole_arguments.lm2 | 78 | `fn: wrong (Point: p; int: q 1) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е70 | selfbuild/tests/dyn/whole_arguments.lm2 | 86 | `    fn: f (Point: p; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е71 | selfbuild/tests/dyn/whole_direct_fields.lm2 | 21 | `fn: k (Q: q; int: z 0) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е72 | selfbuild/tests/dyn/whole_field_refused.lm2 | 16 | `fn: g (Point: p; int: q) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е73 | selfbuild/tests/os_twins/callable_value_os.lm2 | 17 | `fn: placed (os_note: q; int: x) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |
| Е74 | selfbuild/tests/os_twins/callable_value_unit.lm2 | 7 | `fn: placed (os_note: q; int: x) int` | описание формалов в объявлении fn: или sub: (по заданию не подача) |

### 3б. Литералы Structure с записью «имя: значение» внутри (по запросу fable2)

Определение (ответ fable2): написанная в скобках Structure на месте значения — операнд или аргумент вызова. Запись «имя: значение» внутри неё объявляет Structure с таким именем; поле со значением пишется ресивером, например `int: a 5`. Строки без переписывания.

| # | файл | строка | текст (как есть) | почему не подача по голове |
|---:|---|---:|---|---|
| Б1 | selfbuild/tests/dyn/merge_args_model_formal_refused.lm2 | 10 | `    pack: merge(tst\args; (int: a 5))` | литерал Structure с полем a в аргументах merge; не подача по голове |
| Б2 | selfbuild/tests/dyn/merge_args_operand.lm2 | 32 | `    pack: merge(tst\args; (int: a 5))` | литерал Structure с полем a в аргументах merge; не подача по голове |
| Б3 | selfbuild/tests/dyn/merge_args_operand.lm2 | 66 | `    pack: merge(Args; tst\args; (int: a 5))` | литерал Structure с полем a в аргументах merge; не подача по голове |
| Б4 | selfbuild/tests/dyn/merge_args_operand.lm2 | 76 | `    pack: merge(comp\args; (int: a 5))` | литерал Structure с полем a в аргументах merge; не подача по голове |
| Б5 | selfbuild/tests/dyn/merge_named_field_operand.lm2 | 12 | `    pack: merge(Args; (int: a 5))` | литерал Structure с полем a в аргументах merge; не подача по голове |
| Б6 | selfbuild/tests/dyn/merge_named_field_operand.lm2 | 32 | `    pack: merge(Args; (int: a 9))` | литерал Structure с полем a в аргументах merge; не подача по голове |
| Б7 | selfbuild/tests/dyn/merge_named_field_operand.lm2 | 42 | `    pack: merge(Args; (int: a 4); (int: c 2))` | литерал Structure с полем a в аргументах merge; не подача по голове |
| Б8 | selfbuild/tests/dyn/merge_named_field_refused.lm2 | 10 | `    pack: merge(Args; (a: int: 5))` | литерал Structure с полем a в аргументах merge; не подача по голове; отрицательная фикстура, не переводится |
| Б9 | selfbuild/tests/dyn/whole_arguments.lm2 | 109 | `    pack: merge(mytest\args; (int: a 5))` | литерал Structure с полем a в аргументах merge; поле a подаётся формалу a по целой структуре аргументов, сама запись не подача по голове |
| Б10 | selfbuild/tests/dyn/whole_arguments.lm2 | 116 | `    return: mytest(merge(mytest\args; (int: a 5)))` | литерал Structure с полем a в аргументах merge; поле a подаётся формалу a по целой структуре аргументов, сама запись не подача по голове |

Вне списков (по одной фразе на строку):
- `selfbuild/tests/dyn/free_c_pointer.lm2:36` — ресивер cast в аргументе C-вызова, не литерал Lmx и не подача.
- `selfbuild/tests/dyn/merge_args_operand.lm2:40` и `selfbuild/tests/dyn/merge_named_field_operand.lm2:22` — ресивер int прямо в аргументах merge, без скобок-литерала: объявление места, не литерал.
- `selfbuild/tests/dyn/explicit_data_var_field.lm2:93` и `selfbuild/tests/dyn/receiver_literal_range.lm2:35` — ресивер int в скобках справа от `:=`: приведение значения, не литерал Structure.

## 4. Сверка счёта и расхождения с планом

- Список 1 и план M11. Шаг 3 раздела M11 (первое измерение) даёт «91 строку двухаргументного `call: code data`» в `tests/dyn`, `tests/graph` и `tests/os_twins`. Строгий счёт кода в HEAD (он совпадает с рабочим деревом): `selfbuild/tests/dyn` и `os_twins` — 67, `selfbuild/tests/graph` — 20, сумма 87. Разница во времени: 91 — счёт на коммите db4a96d4, см. раздел 9.1. Грубый шаблон без отсева комментариев даёт 95 совпадений, из них 8 — строки-комментарии.
- Список 3 и план M11. В первом измерении шага 3 записано «прочая подача по голове в вызове — 12 вхождений» по `selfbuild/tests`, `tools` и `src` без разбора. В `dyn` и `os_twins` строгий счёт основного списка — 0; где лежат остальные вхождения, не проверял.
- Список 2 и план M11. В первом измерении шага 3 записано «письмо exit(exit_code: …) — 193 в 185» по `selfbuild` целиком; здесь 155 в `dyn` и `os_twins`. Построчно не сверял.
- Одноаргументные `call:` (23) и `catch: call ()` (38) в списке 1 не входят; их переход на форму `call: code` — отдельная опись.

## 5. Вопросы (закрыты ответами fable2: литералы — в 3б; merge_named_field_refused — отрицательная, не переводится)

1. Список 3. Я не считаю подачей по голове ни одну из 13 строк: `int: a 5` внутри `merge(...)` объявляет место `a`, литерал `(int: a 5)` — структура-операнд. Если поля `a` у литералов, которые подаются формалу `a` через целую структуру аргументов (правило whole-arguments), считать подачей по голове, список 3 станет 12 строк (все 13, кроме `free_c_pointer.lm2:36`). Как считать?
2. `selfbuild/tests/dyn/merge_named_field_refused.lm2:10` — `(a: int: 5)`: отрицательная фикстура, форма снята решением 2026-11-10; в список 2 она не попала. Оставить её без перевода как отрицательную фикстуру?

## 6. Что не проверено

- Смысл переставленных строк списка 1 не проверял: это механическая перестановка по заданию, без семантики и без запусков.
- Многострочные вызовы: строк кода, оканчивающихся на `(`, `;` или `,`, нет. Все такие совпадения по шаблону (30) — строки-комментарии.
- Пять строк списка 1 с одинаковыми именами перестановку не меняет; для них перевод не выполнялся и не нужен.
- Интерпретатор и пробы не запускались; сборок и lmxtool не было.

## 7. Graph: selfbuild/tests/graph/*.lm2 (рабочее дерево)

Файлов .lm2: 109. Рабочее дерево здесь уже в новом порядке `call: data code`, поэтому список 1 без перестановки. Кроме .lm2 в каталоге есть 13 строк двухаргументного `call:` в файлах `.expected` (дампы, не исходники) — в списки не входят.

### 7.1. Список 1 — двухаргументный `call:` (без перестановки)

Счёт: `git grep -n -E '^[[:space:]]*call:[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]*$' -- 'selfbuild/tests/graph/*.lm2'` → 20 (= строк таблицы).

| # | файл | строка | текст (как есть; порядок уже data code) |
|---:|---|---:|---|
| 1 | selfbuild/tests/graph/call_data_whole.lm2 | 24 | `call: Data Code` |
| 2 | selfbuild/tests/graph/call_data_whole.lm2 | 40 | `call: Made Step` |
| 3 | selfbuild/tests/graph/call_data_whole.lm2 | 42 | `call: Made Step` |
| 4 | selfbuild/tests/graph/call_returns_value.lm2 | 9 | `call: Vars Body` |
| 5 | selfbuild/tests/graph/code_data.lm2 | 14 | `call: Data Code` |
| 6 | selfbuild/tests/graph/code_data.lm2 | 18 | `call: Code\data Code` |
| 7 | selfbuild/tests/graph/code_data.lm2 | 25 | `call: Self Self` |
| 8 | selfbuild/tests/graph/code_data.lm2 | 31 | `call: Data method` |
| 9 | selfbuild/tests/graph/code_data.lm2 | 35 | `    call: Data Code` |
| 10 | selfbuild/tests/graph/code_data.lm2 | 49 | `call: Data ReadSelected` |
| 11 | selfbuild/tests/graph/code_data_missing.lm2 | 12 | `call: Empty Code` |
| 12 | selfbuild/tests/graph/control_flow.lm2 | 115 | `call: Data Code` |
| 13 | selfbuild/tests/graph/control_missing.lm2 | 13 | `call: Empty Code` |
| 14 | selfbuild/tests/graph/known_assignment.lm2 | 51 | `call: Data Code` |
| 15 | selfbuild/tests/graph/known_assignment_selected.lm2 | 12 | `call: Data Code` |
| 16 | selfbuild/tests/graph/post_loop.lm2 | 16 | `call: Data Repeat` |
| 17 | selfbuild/tests/graph/post_loop.lm2 | 72 | `call: RepeatOwn\data RepeatOwn` |
| 18 | selfbuild/tests/graph/post_loop.lm2 | 78 | `call: Self Self` |
| 19 | selfbuild/tests/graph/sub_calls.lm2 | 17 | `call: Other add` |
| 20 | selfbuild/tests/graph/var_copy_nesting.lm2 | 6 | `    call: data\Box\Code data\Box\Code` |

### 7.2. Список 2 — письмо `exit(exit_code: …)`

Счёт: `git grep -n -E 'exit\(exit_code:' -- 'selfbuild/tests/graph/*.lm2'` → 0. Строк нет.

### 7.3. Список 3 — подача по голове

Основной список: **2** строки. Обе — `имя: значение` прямо внутри скобок merge, без скобок-литерала: `merge(M; f: 3)` и `merge(M; v: 9)`. По правилу `f(arg: v)` это вызов `f` с аргументом 3 (и `v` с 9), то есть та же форма, что подача по голове в аргументе вызова.

Счёт: `git grep -n -F -e 'merge(M; f: 3)' -e 'merge(M; v: 9)' -- 'selfbuild/tests/graph/*.lm2'` → 2.

| # | файл | строка | текст (как есть) | почему подача по голове |
|---:|---|---:|---|---|
| Г1 | selfbuild/tests/graph/merge_call_colon.lm2 | 8 | `int: r merge(M; f: 3)\f` | в скобках merge стоит имя с двоеточием и значением: вызов имени с аргументом (правило f(arg: v)) |
| Г2 | selfbuild/tests/graph/merge_description.lm2 | 4 | `int: r merge(M; v: 9)\v` | в скобках merge стоит имя с двоеточием и значением: вызов имени с аргументом (правило f(arg: v)) |

### 7.4. Список 3б — литералы Structure с записью «имя: значение» внутри

Скобочная Structure на месте значения — операнд или аргумент merge или вызова. Счёт: `git grep -n -E '[A-Za-z0-9_\][[:space:]]*\([^()]*[;,][[:space:]]*\([[:space:]]*[A-Za-z_][A-Za-z0-9_\]*[[:space:]]*:[^:=]' -- 'selfbuild/tests/graph/*.lm2'` → 13.

| # | файл | строка | текст (как есть) | почему не подача по голове |
|---:|---|---:|---|---|
| Б1 | selfbuild/tests/graph/descriptor.lm2 | 6 | `int: v merge(f2\data; (int: q 3))\q` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б2 | selfbuild/tests/graph/descriptor_body.lm2 | 2 | `int: x merge(f2\code; (int: q 1))\q` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б3 | selfbuild/tests/graph/fn_return_forms.lm2 | 11 | `R1: merge(p1; (int: zz 1))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б4 | selfbuild/tests/graph/fn_return_forms.lm2 | 12 | `R2: merge(p2; (int: zz 2))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б5 | selfbuild/tests/graph/fn_return_forms.lm2 | 13 | `R3: merge(p3; (int: zz 3))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б6 | selfbuild/tests/graph/merge_arguments.lm2 | 8 | `    return: mytest(merge(mytest\args; (int: a x)))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б7 | selfbuild/tests/graph/merge_arguments.lm2 | 10 | `int: r mytest(merge(mytest\args; (int: a 5)))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б8 | selfbuild/tests/graph/merge_arguments.lm2 | 11 | `int: both mytest(merge(mytest\args; (int: c 4; int: a 6)))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б9 | selfbuild/tests/graph/merge_arguments.lm2 | 12 | `int: nested mytest(merge(merge(mytest\args; (int: c 2)); (int: a 7)))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б10 | selfbuild/tests/graph/merge_arguments.lm2 | 14 | `int: model mytest(merge(AV; (int: c 1)))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б11 | selfbuild/tests/graph/merge_arguments.lm2 | 16 | `int: appended merge(AV; (int: z 9))\z` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б12 | selfbuild/tests/graph/merge_arguments.lm2 | 17 | `int: kept merge(AV; (int: a 2))\a + AV\a` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |
| Б13 | selfbuild/tests/graph/merge_held.lm2 | 4 | `pack: merge(mytest\args; (int: a 5))` | литерал Structure с полем в аргументах merge или вызова; не подача по голове |

Заметка «формалы ресиверами — не переводятся» (ответ fable2): части `args := (…)`, `data := (…)`, `code := (…)` в объявлениях `fn:` и `sub:` — описание формалов ресиверами. Оно законно и не переводится, поэтому из 3б вынесено: 8 строк. Счёт: `git grep -n -E '(:=|return:)[[:space:]]*\([[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:[^:=]' -- 'selfbuild/tests/graph/*.lm2'` → 8.

| # | файл | строка | текст (как есть) |
|---:|---|---:|---|
| Ф1 | selfbuild/tests/graph/fn_name_collision.lm2 | 8 | `fn: name := k3; args := (int: a); return := int; code := (return: a + 2)` |
| Ф2 | selfbuild/tests/graph/fn_named_supply.lm2 | 11 | `fn: name := k1; args := (int: a); return := int; code := (return: a + 1)` |
| Ф3 | selfbuild/tests/graph/fn_named_supply.lm2 | 16 | `fn: name := k3; args := (int: a; int: b); return := int; data := (int: calls 0); code := (calls := calls + 1; return: a * 10 + b)` |
| Ф4 | selfbuild/tests/graph/fn_named_supply.lm2 | 20 | `fn: name := k4; args := (); return := int; data := (int: n 7); code := (return: n)` |
| Ф5 | selfbuild/tests/graph/fn_named_supply.lm2 | 37 | `sub: name := s1; args := (int: d 1); data := (int: total 0); code := (total := total + d)` |
| Ф6 | selfbuild/tests/graph/fn_named_supply.lm2 | 41 | `fn: name := "t1"; args := (int: a); return := int; code := (return: a + 100)` |
| Ф7 | selfbuild/tests/graph/fn_named_supply.lm2 | 43 | `fn: name := "t\x33"; args := (int: a); return := int; code := (return: a + 300)` |
| Ф8 | selfbuild/tests/graph/fn_return_forms.lm2 | 9 | `fn: name := p2; args := (int: a); return := (@: c.FILE); code := (return: 0)` |

## 8. Прочие исходники: selfbuild/tools/*.lm2 и selfbuild/tests/* вне dyn, os_twins, graph

Файлов: 75 .lm2 (tests: os 17, cdoor 6, lib 5, rr2 3, bits 3, suite 2 — всего 36; tools — 39). Счёт идёт по рабочему дереву. Файлы в рабочем дереве, отличающиеся от HEAD, в этих путях: см. вывод `git status -uno` в конце раздела 9.

### 8.1. Список 1 — двухаргументный `call:`

Счёт: `git grep -n -E '^[[:space:]]*call:[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]*$'` по этим 75 файлам → 0. Строк нет; перестановка не нужна.

### 8.2. Список 2 — письмо `exit(exit_code: …; stdout: …; stderr: …)`

Счёт: `git grep -n -E 'exit\(exit_code: [^;]+; stdout: [^;]+; stderr: [^)]+\)'` → 38; все строки `exit\(exit_code:` → 38; нестандартных 0. Перевод тот же: `exit_code: V` → `exit_code := V`, то же для stdout и stderr.

| # | файл | строка | было (как есть) | станет (`:` → ` :=` у трёх полей) |
|---:|---|---:|---|---|
| 1 | selfbuild/tests/bits/bit_mixed_refused.lm2 | 9 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 2 | selfbuild/tests/bits/bit_reference_refused.lm2 | 7 | `send: exit(exit_code: run("x"); stdout: ""; stderr: "")` | `send: exit(exit_code := run("x"); stdout := ""; stderr := "")` |
| 3 | selfbuild/tests/bits/bit_values.lm2 | 46 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 4 | selfbuild/tests/cdoor/c_call_one_actual.lm2 | 28 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 5 | selfbuild/tests/cdoor/c_call_one_actual_root.lm2 | 26 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 6 | selfbuild/tests/cdoor/clock_machine.lm2 | 31 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 7 | selfbuild/tests/cdoor/deadline_machine.lm2 | 39 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 8 | selfbuild/tests/cdoor/define_struct_tm.lm2 | 22 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 9 | selfbuild/tests/cdoor/schedule_machine.lm2 | 43 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 10 | selfbuild/tests/lib/lib_owner.lm2 | 200 | `send: exit(exit_code: ok; stdout: ""; stderr: "")` | `send: exit(exit_code := ok; stdout := ""; stderr := "")` |
| 11 | selfbuild/tests/os/os_bodies.lm2 | 54 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 12 | selfbuild/tests/os/os_branch_head_refused.lm2 | 12 | `send: exit(exit_code: os_one(); stdout: ""; stderr: "")` | `send: exit(exit_code := os_one(); stdout := ""; stderr := "")` |
| 13 | selfbuild/tests/os/os_branch_twice_refused.lm2 | 12 | `send: exit(exit_code: os_one(); stdout: ""; stderr: "")` | `send: exit(exit_code := os_one(); stdout := ""; stderr := "")` |
| 14 | selfbuild/tests/os/os_callable_result.lm2 | 19 | `send: exit(exit_code: r; stdout: ""; stderr: "")` | `send: exit(exit_code := r; stdout := ""; stderr := "")` |
| 15 | selfbuild/tests/os/os_duplicate_refused.lm2 | 16 | `send: exit(exit_code: os_one(); stdout: ""; stderr: "")` | `send: exit(exit_code := os_one(); stdout := ""; stderr := "")` |
| 16 | selfbuild/tests/os/os_implements.lm2 | 22 | `send: exit(exit_code: os_take(A); stdout: ""; stderr: "")` | `send: exit(exit_code := os_take(A); stdout := ""; stderr := "")` |
| 17 | selfbuild/tests/os/os_implements_refused.lm2 | 21 | `send: exit(exit_code: os_take(A); stdout: ""; stderr: "")` | `send: exit(exit_code := os_take(A); stdout := ""; stderr := "")` |
| 18 | selfbuild/tests/os/os_item_refused.lm2 | 13 | `send: exit(exit_code: os_one(); stdout: ""; stderr: "")` | `send: exit(exit_code := os_one(); stdout := ""; stderr := "")` |
| 19 | selfbuild/tests/os/os_requirements.lm2 | 42 | `send: exit(exit_code: ok; stdout: ""; stderr: "")` | `send: exit(exit_code := ok; stdout := ""; stderr := "")` |
| 20 | selfbuild/tests/os/os_second_block_refused.lm2 | 22 | `send: exit(exit_code: os_one(); stdout: ""; stderr: "")` | `send: exit(exit_code := os_one(); stdout := ""; stderr := "")` |
| 21 | selfbuild/tests/os/os_select_only.lm2 | 24 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 22 | selfbuild/tests/os/os_signatures_differ.lm2 | 34 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 23 | selfbuild/tests/os/os_throws.lm2 | 32 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 24 | selfbuild/tests/os/os_unknown_name_refused.lm2 | 13 | `send: exit(exit_code: os_one(); stdout: ""; stderr: "")` | `send: exit(exit_code := os_one(); stdout := ""; stderr := "")` |
| 25 | selfbuild/tests/os/os_unselected_invalid.lm2 | 24 | `send: exit(exit_code: os_one(); stdout: ""; stderr: "")` | `send: exit(exit_code := os_one(); stdout := ""; stderr := "")` |
| 26 | selfbuild/tests/os/os_walk_values.lm2 | 46 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 27 | selfbuild/tests/os/unit_os_prologue.lm2 | 13 | `send: exit(exit_code: 7; stdout: ""; stderr: "")` | `send: exit(exit_code := 7; stdout := ""; stderr := "")` |
| 28 | selfbuild/tests/rr2/unit_rr2_qualified_merge_callable.lm2 | 25 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 29 | selfbuild/tests/rr2/unit_rr2_qualified_merge_immutable.lm2 | 30 | `send: exit(exit_code: m(); stdout: ""; stderr: "")` | `send: exit(exit_code := m(); stdout := ""; stderr := "")` |
| 30 | selfbuild/tests/rr2/unit_rr2_qualified_merge_root.lm2 | 28 | `send: exit(exit_code: code; stdout: ""; stderr: "")` | `send: exit(exit_code := code; stdout := ""; stderr := "")` |
| 31 | selfbuild/tests/sha/sha256_vectors.lm2 | 59 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 32 | selfbuild/tests/suite/entry_large.lm2 | 8 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 33 | selfbuild/tests/suite/entry_negative.lm2 | 8 | `send: exit(exit_code: run(); stdout: ""; stderr: "")` | `send: exit(exit_code := run(); stdout := ""; stderr := "")` |
| 34 | selfbuild/tools/build.lm2 | 1707 | `    if: c.fputs("r CLOSED.\n    int: state\nend: LmxRoot\n\n# THE HOST ROOT (author 2026-09-24, LMX_blog/2026-09-24.md): R0's parent is a full Thread made by\n# the same mechanisms as every other -- the one lmx_root_open makes, with its arena, mailbox,\n# schedule, manager and service; its own parent is the parentless structural frame, which stands\n# for the OS.  The launch runs in it, and R0 stays pure user code: C main hands the host argc, argv\n# and R0's program; in its first turn the host reserves R0 as its ordinary child (own arena,\n# published into the host's children at the host's end-turn, retained in a result cell of the\n# host's graph), and the host's `independent: const: immutable` settings reach R0 by the eternal\n# rule -- the same physical branch, imported into R0's arena as a view, never copied -- so R0 stays\n# platform-independent.  The host posts the mainArgs letter to R0, R0 takes one turn from the\n# host's cycle, and the host takes its own inbox: a letter from R0 whose payload is\n# `exit(exit_code: <code>; stdout: \"\"; stderr: \"\")` is the exit.  When R0 sent none the host maps\n# R0's `succ", f) < 0` | `    if: c.fputs("r CLOSED.\n    int: state\nend: LmxRoot\n\n# THE HOST ROOT (author 2026-09-24, LMX_blog/2026-09-24.md): R0's parent is a full Thread made by\n# the same mechanisms as every other -- the one lmx_root_open makes, with its arena, mailbox,\n# schedule, manager and service; its own parent is the parentless structural frame, which stands\n# for the OS.  The launch runs in it, and R0 stays pure user code: C main hands the host argc, argv\n# and R0's program; in its first turn the host reserves R0 as its ordinary child (own arena,\n# published into the host's children at the host's end-turn, retained in a result cell of the\n# host's graph), and the host's `independent: const: immutable` settings reach R0 by the eternal\n# rule -- the same physical branch, imported into R0's arena as a view, never copied -- so R0 stays\n# platform-independent.  The host posts the mainArgs letter to R0, R0 takes one turn from the\n# host's cycle, and the host takes its own inbox: a letter from R0 whose payload is\n# `exit(exit_code := <code>; stdout := \"\"; stderr := \"\")` is the exit.  When R0 sent none the host maps\n# R0's `succ", f) < 0` |
| 35 | selfbuild/tools/graph_trans.lm2 | 36 | `send: exit(exit_code: rc; stdout: ""; stderr: "")` | `send: exit(exit_code := rc; stdout := ""; stderr := "")` |
| 36 | selfbuild/tools/l2trans.lm2 | 41 | `send: exit(exit_code: rc; stdout: ""; stderr: "")` | `send: exit(exit_code := rc; stdout := ""; stderr := "")` |
| 37 | selfbuild/tools/lmxchild.lm2 | 184 | `send: exit(exit_code: rc; stdout: ""; stderr: "")` | `send: exit(exit_code := rc; stdout := ""; stderr := "")` |
| 38 | selfbuild/tools/lmxtool.lm2 | 31 | `send: exit(exit_code: rc; stdout: ""; stderr: "")` | `send: exit(exit_code := rc; stdout := ""; stderr := "")` |

### 8.3. Список 3 — подача по голове

Основной список пуст: **0** строк. Кандидатов по шаблону (имя с двоеточием в скобках после идентификатора вызова, без комментариев, без строк `exit(`, без объявлений fn:/sub:/fm:/catch:) — 277. Разбивка по признакам:
- 151 строка с кавычками: `name:` стоит внутри строкового литерала, то есть это текст, который печатают генераторы (`c.fputs`, `c.printf`) или C-формат;
- 125 строк с ресивером `cast:` (в том числе в аргументах C-вызовов `c.memset(…)`, `c.printf(…)` и т. п.): приведение, не формал;
- 1 строка — литерал, см. 8.4.
Проверка: `git grep` по тем же путям, затем отбор строк без кавычек и без `cast:` → 1 (только rr2). Счёт: 151 + 125 + 1 = 277.

### 8.4. Список 3б — литералы Structure с записью «имя: значение» внутри

| # | файл | строка | текст (как есть) | почему не подача по голове |
|---:|---|---:|---|---|
| Б1 | selfbuild/tests/rr2/unit_rr2_qualified_merge_immutable.lm2 | 22 | `    d: immutable: merge(Integer; (int: value 9))` | литерал Structure с полем value в аргументах merge; не подача по голове |

Вне списков: четыре строки `fn:` с формалами в скобках (`selfbuild/tests/os/os_callable_result.lm2:5`, `:11`; `selfbuild/tests/os/os_requirements.lm2:18`, `:22`) — объявления формалов fn:, не литералы значения.


## 9. Сверка счёта с планом M11 (весь selfbuild)

Счета воспроизведены командами `git grep`. Рабочее дерево и HEAD дают одинаковые числа для двухаргументного `call:` и для письма exit; единственная правка рабочего дерева в этих путях вне graph — `selfbuild/tools/build.lm2` (см. 9.3).

### 9.1. Двухаргументный `call:`: план называет 91

| Состояние | всего строк (dyn + os_twins + graph, все файлы) | из них .lm2 | весь selfbuild |
|---|---:|---:|---:|
| коммит db4a96d4 | 91 | 81 | 91 |
| коммит 9c62977a (и bace76d8, e78b1067) | 100 | 87 | 100 |
| сейчас (HEAD = рабочее дерево) | 100 | 87 | 100 |

Команда: `git grep -n -E '^[[:space:]]*call:[[:space:]]+[^[:space:]]+[[:space:]]+[^[:space:]]+[[:space:]]*$' <коммит> -- selfbuild` (для текущего состояния без коммита); пути в скобках для .lm2 — `-- 'selfbuild/tests/dyn/*.lm2' 'selfbuild/tests/os_twins/*.lm2' 'selfbuild/tests/graph/*.lm2'`.

Вывод: 91 — счёт до коммита 9c62977a («Clean graph: the receivers call and fncall launch the parts they are given…»), который добавил 6 строк в graph/*.lm2 и 3 строки в graph/*.expected. Шаблон тот же, разницы в нём нет: расхождение во времени.

Сейчас по каталогам: dyn 67; graph 33 (20 в .lm2, 13 в .expected); в selfbuild/src, tools и остальных tests — 0.

Скобочные `call(…)` по selfbuild: 9 строк. Двухаргументных нет: в graph/*.lm2 шесть строк кода — `call(Args Vars Vars Body)` (4 аргумента), `call(Args Vars Sub)` (3, два раза), `call(bump\args bump\data bump\code)` (3), `call(Self)` (1, два раза); ещё три — комментарии и текст README.md:263.

### 9.2. Письма exit: план называет 193 в 185 файлах — совпадает

`git grep -n -E 'exit\(exit_code:' -- selfbuild` → 193 строки; `git grep -l -E 'exit\(exit_code:' -- selfbuild` → 185 файлов. Недостающих нет: это весь selfbuild, а не только selfbuild/tests.

По каталогам: tests/dyn 133; tests/os_twins 22; tests/os 17; tests/cdoor 6; tests/bits 3; tests/rr2 3; tests/suite 2; tests/lib 1; tests/sha 1; tools 5 (build, graph_trans, l2trans, lmxchild, lmxtool); src 0; graph 0. Сумма 193.

### 9.3. Состояние рабочего дерева

`git status -uno --short -- selfbuild/tests selfbuild/tools` → 61 строка: 60 в `selfbuild/tests/graph` (правки fable2, не закоммичены) и 1 в `selfbuild/tools/build.lm2`. Счёты по graph и tools в этом отчёте сделаны по рабочему дереву; для dyn и os_twins изменений нет.

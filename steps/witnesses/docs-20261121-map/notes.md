# Step 21.1: the documentation edition of 2026-11-21 against the code and the plan

Map made by opus on 2026-11-21, read only: no file of the tree, the stage or the builds was changed and nothing was
built. Base: main `150f01f5` (the author's documents on top of `fa0362a0` and the WIP commit `30001e04`). Probes ran on
the accepted set of slice 4 (`fable-s4-feh01`, `fable-s4-rt02`, `fable-s4-graph02`): `graph_trans-prod.exe 0 entry 0
-- run FILE 1` with the working directory `S/src`, P0 trees with `-- p0 FILE`. The probe programs referenced below
are in [probes](probes/); their logs, the grep table and the full map stay in the receipt directory
`build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable/tz-20261121/opus-map/`.
Counts of rows were made by a helper session (haiku) with a script and checked by eye; G is `selfbuild/tests/graph`
(552 programs), Y is `selfbuild/tests/dyn` (177 programs); `selfbuild/tests/parser` does not exist.

Verdicts: **conforms**, **differs**, **not expressible** (the form is refused or cannot be written today). Steps are
those of the [plan](../../../next_core_tasks_v3.md#docs-20261121). «decided by opus» marks a reading derived from
the norm during the map; fable confirmed the readings of A2.

Requirements: [binding](../../../docs/TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md) (B-TZ),
[declaration arguments](../../../docs/TZ/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md) (D-TZ),
[streams](../../../docs/TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md) (S-TZ),
[author clarification](../../../docs/TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) (U),
[blank line](../../../docs/TZ/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md) (L-TZ).
Code: [lmx_graph.lm2](../../../selfbuild/src/l2src/lmx_graph.lm2),
[lmx_graph_run.lm2](../../../selfbuild/src/l2src/lmx_graph_run.lm2),
[p0_parser.lm2](../../../selfbuild/src/l2src/p0_parser.lm2).

## A. Binding and callables

### A1. What changed in the binding requirement after `923c6fb1`

The plan section «binding callables» and the book were written from `923c6fb1`. The current text differs in one
subject, named in its header: «уточнение от 20 ноября 2026 года: именованная позиционная сигнатура `fn: name data` и
её отдельное правило внутри `implements`». R01–R12 and R15–R18 are unchanged.

- **R13, R14**. Now: `fn: name data`: two DATA arguments, the name and the data template of a C-like signature; a
  separate rule of the common `implements`: number and ordered types of inputs, presence and type of the result. Step:
  21.8.
- **R19 (new)**. Now: a Structure used explicitly as a structural template requires its whole written tree, method
  subtrees too. Step: 21.8.
- **§8.2–§8.5 (new)**. Now: template versus fn requirement; position i ↔ position i, no reordering by names; template
  defaults not carried; public names of fn are labels mapped to positions of the candidate. Step: 21.8, 21.5.
- **§8.6**. Now: `@: sumPtr SumSignature SumContext\sum` replaces `@: sumPtr fn(…) SumContext\sum`. Step: 21.8, 21.21.
- **§9 preface**. Now: a fn requirement of the receiving place is checked before the selection; the label map is fixed
  when the call is prepared. Step: 21.5, 21.20.
- **§13 steps 5, 6, 8**. Now: the named fn as its own kind of requirement; labels in selection; no anonymous fn
  templates in migrated examples. Step: 21.7, 21.8, 21.21.
- **§14**. Now: C06, C07, C14 reworded; C20–C36 new (17 rows). Step: 21.8.

The record of step 1 ([notes](../binding-callables-step1-20261119/notes.md), 61 rows) keeps its verdicts for C06, C07
(not expressible) and C14 (differs; `a_v7_in_group_return` answers 5). C20–C36 are not expressible today: the line
`fn: SumSignature (int: a; int: b; return: int)` alone is refused at build with 5 (`a_fn_sig_alone`); a typed
reference with a Structure requirement and a candidate refuses (`a_r19_min_template` run 5, `a_r19_full_template`
build 2); in G the three-argument `@:` occurs only with a primitive requirement (`@: q int @x`); no row uses
`implements`. With them the record counts 78 rows: 31 conform, 16 differ, 31 not expressible.

### A2. The WIP of slice 3 (`30001e04`) against the edition

All 23 files of the slice's change list are in main byte for byte; the accepted binaries of slice 4 are built from
`fa0362a0`.

- **`lmx_graph_declared_private` reads the record (`lmx_graph_record_mark`)**. Rule: U §1.3: `private` is read from the
  same graph, no marked graph. Verdict: conforms.
- **`lmx_graph_lexical_binding` selects with `prepare = 0`**. Rule: selection runs and prepares nothing. Verdict:
  conforms.
- **`lmx_graph_lexical_private` asks about the declaration the lexical part selects**. Rule: kernel §3.4: «Check the
  actually visible receiver declaration». Verdict: conforms.
- **one check in `lmx_graph_select_binding` before the first source of a calling activation**. Rule: B-TZ R05; it stays
  before both dynamic sources once 21.4 adds the caller place. Verdict: conforms.
- **re-pins 2121 → 2110, 2121 → 2133; selftest 106 → 2110**. Rule: R05, B11. Verdict: conforms.
- **selftest 114 → 3010, 119 → 10**. Rule: kernel §3.4: an explicitly supplied value carries no private history.
  Verdict: conforms, decided by opus.
- **`bind_private_receiver_write`: the write lands in the own copy, 110797**. Rule: kernel §3.4: a bare write to a
  fallback copy changes the copy. Verdict: decided by opus.

The corpus family B-06 calls nested Structures with actuals and becomes runnable after 21.7
(`a_v6_in_group_named` answers 5). Recorded as R113.

### A3. The unit root

[Review notes](../../../docs/REVIEW_NOTES.md), §5, D2: R0 consumes its records under CODE contracts, a fixture
states its entry profile and names the body it calls, there is no automatic `main`. Today `lmx_graph_run` launches
the root over itself (`lmx_graph_work_open_data(g, root, root, …)`), and the word `data` names it. A Structure
declared at the root is refused at build (`a_v1_noreturn` → 2); inside the leading group its nested body takes the
group as DATA (`a_v5_in_group` → seen 5). 314 programs of G have `@: shared data[0]` and 318 a leading anonymous
group: they move to a DATA profile with a named body (step 21.21), after the entry argument of `run` and
`graph-check` (step 21.6). Recorded as R112 item 2.

## B. Declaration arguments and import

- **a place-declaration receiver passed in CODE is kept as a form; passing runs no initializer**. §: D-TZ §3.1. Code
  today: `lmx_graph_bind_formals`, mode 2: the declaration assigns the formal of its name. `b_match_literal` `g(int: b
  5)` → 15; `b_match_unread` `g(int: b producer())` → run 2. Verdict: literal conforms by observation; computed differs.
  Step: 21.9 (a).
- **matched name: the form replaces the description in the call's namespace**. §: D-TZ §3.2. Code today: as above (the
  norm: `b_match_unread` calls 0, seen 1; `b_match_read_twice` calls 1, seen 14). Verdict: differs. Step: 21.9 (a).
- **inner name absent: the whole form is one Structure at the current position, the counter stays**. §: D-TZ §3.2. Code
  today: the name gives no slot → 5, at build too: `b_absent_alone2`, `b_absent_then_pos` → build 5. Verdict: differs.
  Step: 21.9 (a).
- **outer `name := declaration` names the destination**. §: D-TZ §3.2. Code today: mode 1 evaluates the right side.
  Verdict: differs (not probed further). Step: 21.9 (a).
- **positional counter**. §: D-TZ §3.3. Code today: `lmx_graph_bind_formals`: `slot != i || named != 0` gives a
  named supply; `b_on_own_pos` `h(int: x 5; 4)` → 54. Verdict: conforms.
- **executing a held form at the receiving root; the body sees the same place**. §: D-TZ §4. Code today: no formal can
  hold a form; calling it needs 21.7 and catch. Verdict: not expressible. Step: 21.9 (b).
- **an ordinary callable head stays a call**. §: D-TZ §5. Code today: ordinary call path. Verdict: conforms.
- **`import`: root const declarations, user Structures constant, ordinary redeclaration, parents kept**. §: D-TZ §6.
  Code today: no `import` word: in DATA kept as written (`b_import_data` dumps `Use: (import Library)`), in CODE the
  imported name reads 3 (`b_import_code`). Verdict: not expressible. Step: 21.10.

Rows touched: declarations as actuals at most 112 programs of G (163 lines) and 9 of Y — an upper bound, the pattern
also catches Structure declarations in data. No row uses `import`. The arguments draft zh2 is rewritten by 21.9 (a);
zh4 (`for` by the general code) follows 21.9 (b), its question being closed (R112 item 1); zh1 and zh3 are unchanged.

## C. Streams of import, copy and merge

- **arguments always CODE, in every placement; a call source runs once**. §: S-TZ §1, §5.2. Code today:
  `lmx_graph_eval_merge`, `lmx_graph_merge_operand`: operands once, left to right (`c_call_source` calls 1). Verdict:
  conforms in CODE; DATA placement not expressible (`c_data_form` → 3). Step: 21.11.
- **copy one source, merge two or more, import one or more; arity after W/E**. §: S-TZ §4, §7. Code today: merge of one
  source is a real copy (`c_merge_one`, `c_alias_merge`); `copy` is no word: `@: R copy(A)` keeps the written frame, a
  write through it answers 3 (`c_alias_copy`). Verdict: differs. Step: 21.11.
- **results are field streams; one Structure only by an explicit group**. §: S-TZ §6. Code today: one result Structure
  (`c_code_two`: length 2). Verdict: differs. Step: 21.11.
- **the receiving DATA is no source or model; separate operations**. §: S-TZ §3. Code today: no DATA form. Verdict: not
  expressible. Step: 21.11.
- **one copy map per operation: shared targets, cycles, parents**. §: S-TZ §9. Code today: `lmx_graph_merge_*`,
  `lmx_graph_copy_with_names`. Verdict: conforms.
- **group assignment, all right sides before the first write**. §: S-TZ §8. Code today: `c_group_assign` → build 2.
  Verdict: not expressible. Step: 21.12.
- **receivers stay as written**. §: S-TZ §2. Code today: dumps keep `merge: …` records. Verdict: conforms.

Rows touched: merge in 34 programs of G (48 lines) and 20 of Y (part of them inside C strings); a single written
source in 10 of G and 7 of Y; `@: R merge(…)` in 15 of G; the DATA form `Name: merge` in 2 of G; no copy receiver.

## D. The author clarification of 2026-11-21

- **`uninit:T` is a type code without payload**. §: U §2. Code today: `lmx_graph_uninit_int`: a pointer of type
  `UNINIT_INT` to a separate reserved `int` cell; also `lmx_graph_uninit_int_at`. Verdict: differs. Step: 21.17.
- **a graph assignment replaces the fragment; a distinct cell keeps the old one**. §: U §3, §3.1. Code today:
  `d_graph_write_alias`: after `S\novalue := 5` the read gives 5, `typeof(S[0])` stays 1001024, the dump prints `int:
  novalue`; the aliasing cell is unchanged too. Verdict: differs. Step: 21.17.
- **a frame assignment leaves the source unchanged**. §: U §3. Code today: locals are not published. Verdict: conforms.
- **complete graph with primitive leaves; receivers as written**. §: U §1. Code today: typed cells referenced by
  Structure slots; receiver records kept. Verdict: conforms.
- **executable structures replaceable; update by compile and endturn**. §: U §4. Code today: index writes replace slots;
  `sys\compile` and `endturn` are no words of the clean graph. Verdict: replacement conforms; compile not expressible.
  Step: 21.18.
- **graph plus binary of methods; R0 holds the graph pointer locally; the interpreter too**. §: U §1.1. Code today: the
  global anchor `lmx_graph_anchor` and `lmx_graph_find`; the interp route has no program binary. Verdict: differs. Step:
  21.19.

Rows touched by 21.17: the pins with uninit type codes (`struct_index`, `uninit_reference_merge`,
`uninit_reference_places`, `uninit_reference_visibility`) and the 11 programs using `typeof`. The header of
`uninit_reference_places` («an index alias retains that wrapper while native writes publish to its original cell»)
states the withdrawn rule.

## E. The blank line

- **a blank physical line closes the whole block to the document root**. §: L-TZ §1–§3. Code today:
  `lm_p0_parse_stream`: a blank line is skipped like a comment line. `e_factory` (the requirement's Factory) → P0 error
  13 at 15:1; `e_blank_ws_root` → error 13. Verdict: differs. Step: 21.3.
- **the closed form is not resumed by a following indent**. §: L-TZ §3. Code today: `e_blank_then_indent`: the indented
  line stays inside the block. Verdict: differs. Step: 21.3.
- **a comment-only line is no blank line**. §: L-TZ §2. Code today: the same branch handles both; the change must split
  them. Verdict: conforms, at risk. Step: 21.3.
- **blank lines inside literals and raw comments are content**. §: L-TZ §2. Code today: block strings and raw comments
  are scanned as their own events. Verdict: conforms.
- **an open `(` at the blank line is an error at that line**. §: L-TZ §3. Code today: `e_blank_in_paren` → error 5 at
  the opener, 1:4. Verdict: refusal conforms; place differs. Step: 21.3.
- **Mix is its own document with a local root**. §: L-TZ §3. Code today: `lm_p0_parse_nested` calls the same
  `lm_p0_parse_stream`; pending Mix is flushed per event. Verdict: shared mechanism. Step: 21.3.
- **EOF, line widths, coordinates; the printer adds no blank lines inside blocks**. §: L-TZ §3. Code today: existing EOF
  close; no blank line inside a block in any `.expected`. Verdict: conforms.

Blank lines inside blocks of the self-hosting sources, to remove before P0 applies the rule (89 lines):
`selfbuild/src/l2src/p0_parser.lm2` 51, `selfbuild/tools/os_windows_paths.lm2` 12, `selfbuild/src/l2src/convert.lm2`
10, `selfbuild/src/l2src/l1_backend_emit.lm2` 5, `selfbuild/tools/os_paths.lm2` 4, `selfbuild/tools/os_filesystem.lm2`
3, `selfbuild/tools/os_file_open.lm2` 2, `selfbuild/src/l2src/l2_frontend_lower.lm2` 1,
`selfbuild/src/l2src/primitive.lm2` 1.
G and Y have none. `p0_parser` is a part module of `build-frontend-part` (`tools/build.lm2`, `bld_p0_part_known`).

## F. Order of steps and what already conforms

The kernel chain is 21.2 → 21.4 → 21.5 → 21.9 (a); 21.17 comes before 21.11 because the copier copies uninit
records. 21.3 (parse only), 21.6 (tool only) and 21.12 are independent. 21.6 → 21.7, then 21.8, 21.9 (b), 21.11 →
21.10 and 21.20; 21.21 is the last language step; 21.19 goes with `#final-check` after the old execution path is
gone. Rows touched by 21.7 and 21.21: executable `fn:` in 323 programs of G (560 lines) and 151 of Y (1077 lines),
`sub:` in 409 of G and 25 of Y, `fncall` in 15 of G, `call(` in 64 of G and 22 of Y, `call:` in 29 of G and 21 of Y,
paths through `data` in 79 of G and 15 of Y.

Step C drafts (decided by opus, taken into the plan): c1–c4 stay, 21.8 adds the fn branch and the whole-tree rule to
the same library; c5 (native `fncall(F)` to the opening) loses its object with 21.7, its mechanism stays for `C(args)`
in 21.5; c6 and its extension go into 21.5 unchanged; c6z moves onto `return` in DATA after 21.7. The plan's M15 text
on `uninit:T` contradicted U §2–§3 and was corrected with the plan section.

Already conforming, not to be touched by the new steps: the positional counter; an ordinary callable head stays a
call; merge operands evaluated once with calls applied once; one copy map with shared targets, cycles and parents;
receivers kept in the graph and in the dump; locals not published; index writes replace slots; `private` read from
the record (slice 3); P0's protected text, EOF and line widths; the dump printer's layout; the equal W/E readings of
the step C draft c6.

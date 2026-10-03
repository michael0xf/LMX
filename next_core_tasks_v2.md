ALL LANGUAGE RULES ARE UNIVERSAL WITHIN THEIR DOMAIN. Do not invent special cases; report a genuine contradiction to the author in Russian before choosing new semantics.

# Remaining kernel work through stages 8 and 8a

This is the restart plan requested on 2026-10-01. It replaces the **active queue**
of [next_core_tasks.md](next_core_tasks.md), not its historical evidence. It stops
at full L3/L2 self-build and ordinary calls over Message transport. Application
development is outside this document. The original documentation handoff paused
code work; its subsequent resumption is recorded in [steps/current.md](steps/current.md).
The author's 2026-10-02 list below stands in front of `critical_graph_bug`. That ticket stays the first implementation defect after those steps.

This is a plan, not a language specification or a claim that unchecked features
work. Norms are in [L3 semantics](docs/LMX_semantics.en.md),
[L2](docs/L2_spec_en.md), [L1](docs/L1_spec_en.md) and
[grammar](docs/LMX_grammar.en.md). Read it with the
[v2 dictionary](next_core_tasks_dictionary_v2.md),
[kernel map](CORE_L2_L3_v2.md), and
[porting guide](L2_L3_CODING_INSTRUCTION.md).

<a id="before-critical-graph-bug"></a>
## Before critical_graph_bug — acceptance still required

Author's list, 2026-10-02, inserted in front of the ticket. These are the
missing acceptance steps. They do not replace the ticket and do not mark it
closed.

- [ ] В harness нет декодера графа, который сверяет структуру с исходником и не зависит от временных имён и старых номеров слотов.
  Driver fact `shape … endshape` names roles, primitive cells, `spell`, `add A B`, `body`/`endbody`, and `fields`/`endfields`. It does not read `l2_rwN` names or old slot numbers. Witnesses: `graph_shape_unknown_atom`, `graph_shape_add`, `graph_shape_value`, and `graph_shape_fields` (Holder's ints 1 then 3, native and walked, `regress_ns_19`).
  This is partial structural assertion coverage, not the complete independent
  P0-to-retained-graph decoder. The initial `spell` oracle observed forbidden
  graph-resident names. It now also consults the external service, but its
  compatibility/text fallback cannot certify the address-to-name-table contract. The current
  exact assertions and genuine mutation controls improve coverage but leave
  full source/name/comment reconstruction OPEN.
- [x] Нет прогонов, где успех виден по значению, а не только по тому, что перевод прошёл. Сюда же входят нативное исполнение и проход через walker.
  `graph_shape_value` on `graph_shape_14`: `n: 2 + 2` then `exit_code: n`. Both the native run and the walked root exit 4.
- [x] Нет контрольных поломок: стереть выражение, передвинуть объявление, схлопнуть два вхождения. Каждая должна ломать структурную проверку даже при том же коде выхода.
  Shown on `graph_shape_12`: `graph_shape_mut_erase` (`mutate erase-add`), `graph_shape_mut_move` (declaration after the expression), `graph_shape_mut_collapse` (two `SET` nodes aliased). Each driver exit is 1 because the shape check fails, and the launch exit stays 0.
- [ ] Не запускались ворота из раздела 6: полный l2_harness, build_l2src, run_l3_selftest, check_docs. Прежняя полная прогонка была красной, 36 из 1149.
  `l2_harness` `critical_graph_bug_full_13`, uncommitted translator: RED 36 of 1168. The three if-shell slot pins from `full_12` are absent, and no `graph_shape` witness failed. `full_12` was RED 39 of 1164: the same 36 baseline texts as `full_05`, plus those three pins, later green in `regress_ns_65`. `build_l2src` `critical_graph_bug_06`: GREEN 286, after the if operator was placed before its cell shell. `run_l3_selftest` `critical_graph_bug_02`: all 11 suites exit 0. The `LmxUseLeaf` type is withdrawn. `l3_type_budget` is GREEN: 74 names, headroom 54 under 128. The harness row stays red, so this acceptance item stays open. `critical_graph_bug_full_15` is RED 36 of 1175, the same 36 texts as `full_13`. `build_l2src` `critical_graph_bug_07` is GREEN 286. `run_l3_selftest` `critical_graph_bug_03` is 11 suites, exit 0, and the type budget stays 74 names.
- [ ] В тикете нет строки DONE. Правка транслятора не закоммичена.

<a id="first-critical-graph-bug"></a>
## First action — critical_graph_bug (CRITICAL / P0, OPEN)

Codex resumed the inherited sandbox implementation on the author's request.
[Bounded G0/G1 evidence and remaining universal-layout/codec work](steps/critical-graph-pointer-fix-20261002.md)
are recorded separately. Both critical tickets remain OPEN; focused graph
assertions are not a complete reconstruction or clean-kernel checkpoint.

Current bounded implementation, with no DONE claim:

- [x] Fix the merge-handler witness to exercise the existing forced refusal;
  `critical_graph_fix_g0_01`: 7 targets, 0 failed.
- [x] Remove the structural test's fixed depth-four/16-occurrence limits;
  inspect exact child order, values, initializer roles and targets, and reject
  a failed mutation setup instead of mistaking it for a detected graph defect.
- [x] Give all zero-operand RET applications their own ordinary operation
  Structure; do not let a leading bare role misclassify the enclosing body.
- [x] B0: native and walker hosted-body locators consume one temporary
  `L2GraphPlace` child relation. Existing physical layout is preserved for this
  preparatory slice; no extra runtime Structure or source AST is added.
  `critical_graph_shared_places_01`: 34 targets, 0 failed, including explicit
  walked-method return witnesses and nested body-path cases.
- [x] B1: own-cell addresses, hosted external paths, schema and capture use
  the same temporary physical-field relation. Construction references an
  already allocated catch holder rather than traversing unfinished graph edges;
  `critical_graph_constructor_copy_02`: 12 targets, 0 failed.
- [x] B2: retain the actual file root and ordinary containers named L1/L2/L3;
  remove source-name-based profile unwrapping. `critical_graph_root_container_05`:
  14 targets, 0 failed; sole-container construction and actual name-execution
  parity are separate witnesses. Historical/stable inputs are unchanged.
- [x] G4 bounded ordinary-copy repair: copy operation Structures through the
  common closure map, preserve aliases/parents/native implementation, then run
  a copied graph after its source arena is released. Kernel gate
  `critical_graph_copy_closed_02`: 286 targets, all 106 selftest rows executed
  (105 ordinary exit-0 runs and one expected-fatal watchdog exit-3 run).
  Restoring the former sharing branch gives an expected 7-assertion failure.
  This does not close source/name/comment reconstruction or the whole G4 stage.
- [x] G2 first content axis: one recursive COUNT/PLACE/FILL traversal preserves
  multiple expressions and nested original anonymous containers at their actual
  places. `critical_graph_source_container_04`: 14 targets, 0 failed, including
  six expression-bearing levels, a method's unreachable tail and a real erase
  mutant. Conditional source-placement selection and other producers remain;
  this does not close the universal-layout item below.
- [x] Strengthen the migrated body-location witnesses: ELSE/WHILE/FOR now
  check actual external hosted-field paths, publication, and positive exit 7;
  their source aliases exercise both selected nested methods through the
  walker. The owned-RET sibling witness checks all five invoked methods.
  `critical_graph_nested_acceptance_01`: 10 targets, 0 failed. This is not
  proof that the remaining data-shell/source-topology producers are gone.
- [x] G2 construction-boundary preparation: all eight nested-body callers
  pass the original P0 Structure; allocation uses the common plain constructor
  and 26 statement/catch/trailer/call attachments use `l2_rw_put`.
  `critical_graph_constructor_boundary_02`: 29 targets, 0 failed; all 25
  successfully emitted fixture L1 files equal their `full_03` bytes exactly.
  No ownership ledger/cut-over, shell removal or graph release is claimed.
- [x] G2 bounded inert-container producer cut-over: committed COUNT/PLACE/FILL
  owns actual source containers in distinct METHOD/PAP/T7 views, records real
  constructor/attachment edges, removes their former GLOBAL allocation and
  prefix contribution, and shares one original field/span traversal.
  `critical_graph_source_producer_05`: 13 targets, 0 failed, including actual
  parent checks, a parent-only mutant and its setup-miss control. Mixed bodies
  execute in native and explicitly selected walker modes; their declaration
  storage shell had not moved in that gate. This does not close G2/G3 or runtime T7 copy.
- [x] G2 bounded mixed-body producer cut-over: actual body-local cells occupy
  their original source fields; FOR counter and PAD parameters belong to their
  actual headers, not a companion body. Native/walker paths retain holder plus
  child, projected views have independent committed places, and obsolete
  producer slot reservations are removed. `critical_graph_mixed_scope_06`:
  20 targets, 0 failed; exact mixed tree 1537 checks, exact FOR tree 697 checks.
  `critical_graph_no_init_02`: 9 targets, 0 failed; FOR's declaration uses the
  ordinary native emitter and explicit/carry/no-action source cardinality.
  These bounded results do not close G2/G3, names/comments or the pointer ticket.
- [x] G2 bounded projected-body/root and slot-boundary migration: T7 returned
  occurrences are constructed directly from committed source views, without
  the former anchor/suffix pack; the filtered executable root uses its existing
  occurrence as the producer. Forty-five physical lookup lines use common
  method/namespace/qualified slot helpers. `critical_graph_root_source_05`:
  15 targets, 0 failed; `critical_graph_unit_slots_01`: 17 targets, 0 failed.
  These gates do not prove original-unit declaration order, full T7 formal
  defaults, names/comments or pointer depth. Frozen full `_06` completed RED,
  32 of 1249; it predates the continuation below.
  [Exact scope and hashes](steps/critical-graph-pointer-fix-20261002.md).
- [x] G2 bounded original-unit producer: actual method/named definitions take
  their original source slots; compact tail ranks exclude already placed
  definitions. E counting cannot fall back to a filtered graph.
  `critical_graph_original_root_06`: GREEN, 11 targets from eight fixtures,
  including exact order/parents and two effect-preserving order mutants.
  OS/directives, forward signatures and generic native-only source retention
  remain open. Safe raw-C focused positives expose the missing producer:
  `critical_graph_raw_c_01` RED, 12 of 20; this is not permission to omit them.
- [ ] G2 hosted field construction: constructor and callable/Structure links
  must use the actual GraphField holder/child after holder/reference allocation,
  consuming every source ordinal. The old flat-index local patcher is removed
  in sandbox. `_local_callable_place_03` passes the hosted effect and two local
  procedure regressions but is RED, 1 of 7, on an obsolete root-order shape.
  Exact field identity/parents, later fields and the final constructor ordering
  still require fresh measurement; neither critical ticket is closed.
- [ ] G2/G3: construct all source occurrences through one recursive placement
  algorithm, migrate every width/path/schema/copy/capture consumer, then remove
  selective eligibility, packed fallback and data-shell placement. B0 does not
  close this step or make the old graph source-faithful.
  Connected pending substeps discovered by full09/read-only review:
  source-head availability must close over real callsite environments before
  an unresolved head is materialized as a field; qualified indexed expression
  spans must use the same resolved Array/path projection in typing, native
  lowering and retained graph emission. Do not repair the former by banning
  literal tails, or the latter by adding rank/depth-specific Array forms.
  Exact mechanisms and distinguishing witnesses are in the evidence journal;
  these are implementation dependencies, not new language rules.
- [ ] G1/G4: complete the graph decoder and the real name/comment codec;
  compare full source containment, not just selected lowered instructions.
  The development kernel now has a bounded external address-to-source-name
  service; `toLmx`/`fromLmx` and full comment retention are still absent. Preserve independent
  name/comment payloads at actual source places before P0 document disposal;
  do not mistake compiler name arrays or generated diagnostic comments for
  that facility. Copy/merge must remap source-place keys and preserve payload
  ownership through the same copy map; no second AST or saved source replay.
- [x] G4 bounded external-name ownership and transactional copy/merge:
  `critical_graph_source_names_07` GREEN, 290 targets; all 107 selftests ran.
  The name-service witness executes 93 checks, including late merge rollback,
  weak-key marking, retirement, cross-owner transfer and copied symbolic
  occurrences after source release. Symbolic leaves have only a distinct
  address-domain identity; names are external, and atom handles are `void*`,
  not misaligned casts to Lmx headers. `critical_graph_names_atom_03` GREEN,
  13 targets, measures exact selected names and dormant native/root-walker
  parity. This does not close the universal codec or either critical ticket.
- [x] G2 bounded runtime/source placement: the sole membership List is held
  directly by existing `Thread.children`, in its parent-owner arena. Launch
  service data/settings remain in the already described R0 parent stub;
  neither protocol appends implicit source fields. `critical_graph_source_names_11`
  is GREEN, 290 targets, with all 107 selftests executed: external names 98
  checks, GC 51 checks. An isolated frozen GC mutant removes only the children
  mark and fails exactly the descriptor/backing retention assertions, exit 2.
  A frozen premature-name-publication mutant fails the late outer-merge rollback
  assertion alone, exit 1. Both negative controls finish without crash/timeout.
  This is not universal source construction, a codec, or a critical-ticket release.
- [ ] G5: fix or justify each full-gate refusal by the current norm and release
  an actually green graph checkpoint before the pointer implementation.
  Latest completed full `critical_graph_fix_full_09`: RED, 81 of 1263.
  This frozen snapshot predates subsequent ELSE, contract-tail and runtime/source
  placement changes; it is not their full verdict.
  Exact identities/hashes are retained in the evidence journal.
  The remaining failures include obsolete expectations and genuine admission/
  capture implementation debts, not a blanket waiver. Do not
  substitute focused green rows for a full current-source verdict.

- [ ] **Complete [critical_graph_bug](steps/tickets/critical_graph_bug.md)
  before choosing another remaining implementation item in this plan.**

Author's explicit priority, 2026-10-02. This promotes the concrete graph-loss
defect from K10 to the front of the active queue; it is not deferred until the
later K10 section and does not repeat already completed K01–K04 slices.

Required result: the source determines the graph's structure and field order,
and that source structure is recoverable from the retained graph. Receivers
may create initialized typed cells at their source-defined places; this does
not permit moving declarations ahead of instructions or removing expression
contents such as `(2 + 2)` because their results are discarded.

The ticket owns the detailed evidence, repair boundaries and acceptance.
Closure requires independent structural assertions and mutation controls in
addition to native/walker execution checks. Correct exit values alone do not
close it. Respect the current writer/build owner and preserve their WIP;
arrange a safe handoff, not a second writer or an interrupted gate. Only after
this ticket is closed take the pointer-depth repair below, then the reference
application refactoring, before resuming the remaining dependency queue.

Active slice of this ticket, not a detour:
[2026-10-02-01-known-call-layout](steps/tickets/2026-10-02-01-known-call-layout.md).
A direct `A: b` stores the callee once. The argument is the ordinary `OWN` of
`b`, not a leaf on `int: b 5` (`regress_ns_48`, exit 5). Compact `A(b)` is the same application (`regress_ns_51`, exit 5). Unknown `A: b` stays a Structure.
`graph_shape_method_order` (`regress_ns_54`) reads the method: three assignments,
then `(2 + 2)` as `add 2 2`, then return. Entry 7, native and walked.
`graph_shape_repeat` (`regress_ns_55`): two `int: n` stay two occurrences;
the unqualified name exits 2. `graph_shape_occ` (`regress_ns_56`): two fields
`n` stay in order, and `Holder\[0]n` exits 1.
`graph_shape_if_body` is red (`regress_ns_57`). The `if` body holds two
`SET_OF` in source order, but the two cells are a unit child before the `IF`.
The `if` and `while` placer now stores the operator first and the cell shell
after it. `regress_ns_62`: the exit inside the body is `a`, which is 3,
native and walked. `regress_ns_60` kept `entry_argc_if` and `graph_shape_call`
green. The two `SET_OF` stay inside the body in source order. The shell is
still a sibling of the `IF`, not a child of its body. Putting it inside the
body left native `l2_h` undeclared: that local is bound only when the shell
is a direct child of the activation. That attempt was reverted.
`regress_ns_64` is green again, exit 3. `graph_shape_while_body`
(`regress_ns_66`) exits 1: the body writes `a`, then sets `n`, and the cell
shell follows the `WHILE`. `graph_shape_for_body` (`regress_ns_68`) exits 1.
The `for` shell and the initializer `i = 0` precede the operator. The body
then writes `a` and sets `n`. `graph_shape_method_if` (`regress_ns_71`)
exits 7: inside the method, `flag` is set, then the `if`, and `a = 3` stays
in that body. `l2_rw_host_at` still addresses the sibling.
`graph_shape_method_fields` (`regress_ns_73`) exits 7. The method occurrence
keeps its two header structures, then Holder, and Holder's fields are the ints
in source order. The same run kept `graph_shape_fields`, `graph_shape_method_if`,
and `graph_shape_call` green. `regress_ns_76` repeats that shape on a distinct
copy of the unit, and a merge of Holder keeps int 1 then int 3 as copied cells
parented at the unit. 82 checks, exit 7, native and walked.
`critical_graph_bug_full_13` is RED 36 of 1168. Those 36 are the baseline rows.
The three if-shell pins are not among them, and no `graph_shape` witness failed.
`graph_shape_method_nest` (`regress_ns_80`) exits 7. Holder's first field is
the nested Structure Inner, whose field is an int, and `c` follows it. The flat
method Holder and the unit Holder stayed green in that run.
`graph_shape_method_deep` (`regress_ns_81`) exits 7. Mid holds Inner, Inner
holds an int, and `c` follows Mid. The one-level nest and the flat Holder
stayed green. `graph_shape_method_array` (`regress_ns_83`) exits 7: the int
comes first, then an int Array. The flat Holder stayed green.
`graph_shape_method_arrarr` (`regress_ns_84`) exits 7: the int comes first,
then an Array of Arrays. The int Array stayed green.
`graph_shape_method_ptr` (`regress_ns_85`) exits 7: the int comes first, then
`@: int`. The Array of Arrays stayed green. `graph_shape_method_ref`
(`regress_ns_90`) exits 7: the int comes first, then a copy of unit `Point`,
and that copy's field is an int. `Point` itself follows the method. The
pointer field stayed green. `graph_shape_method_fn` (`regress_ns_91`) exits 7:
the int comes first, then the shared method `step`, and that same method is
the next unit child. The Point copy stayed green. The method-local field
kinds the unit already builds are in the graph. `regress_ns_92` puts the
`if` and `while` cell shell at child 0 of the walked body. `l2_h` loads
that child through the operator. `graph_shape_if_body` still exits 3,
`graph_shape_while_body` exits 1, and `graph_shape_method_if` and
`entry_argc_if` stayed green. The `for` shell and its initializer still
precede the operator.
`regress_ns_99` resolves only an unresolved method-local kind 3 or kind 4
field. Letter models stay accepted. `graph_shape_method_fn` and
`graph_shape_method_ref` exit 7 again, and the if and while shells stay
green. A nested count keeps the body's shell.
`regress_ns_101` is green: `unit_body_seg_method`, its walked twin, and
`unit_body_path_while` exit 7, and the if and while shapes stay green.
`regress_ns_102` walks the while and the for. `unit_body_path_deep` still
stops, "a control body has no operator".
`regress_ns_103` stores a one-child operator on an unwalked method whose
body shell is child 0. `unit_body_path_deep` exits 7, and
`unit_body_seg_method`, `unit_body_path_while`, and `graph_shape_if_body`
stay green.
`regress_ns_105` follows that shell. The host is the operator, then the
body, then child 0. The else arm stays an activation child, and the for
shell still precedes its operator. `unit_nested_body_else`,
`unit_nested_body_while`, `unit_nested_body_for`, and
`unit_walk_nested_own` exit 7.
`regress_ns_106` is green. A named Structure declared in a nested body
keeps its operator. `unit_local_ns_nested`, `unit_local_ns_call_nested`,
`unit_local_ns_ctl_loop`, and `unit_local_ns_node_nested` exit 7.
`regress_ns_107` keeps the walked root and the projection. The entry's
while still stopped: its operator was stored on the child list.
`regress_ns_108` stores that operator on the entry occurrence, which is
the unit. `unit_next_message_loop` exits 0, and `unit_body_path_deep`,
`unit_local_ns_nested`, and `unit_root_hosted_controls` stay green.
`regress_ns_109` is green for the site rows, the reentry, and
`unit_root_deepif70`. `regress_ns_110` follows the shelled host of the
reference failure. `unit_own_reference_failure` exits 7.
`regress_ns_111` accepts the letter models again.
`unit_receive_letter_model`, `unit_send_ref_method`, and
`unit_send_ref_driver_tap` close. The 29 rows `full_14` added past the
baseline 36 are green in `regress_ns_101` through `regress_ns_111`.
Those 36 stay. `critical_graph_bug_full_15` is RED 36 of 1175, the same
36 texts as `full_13`. `build_l2src` `critical_graph_bug_07` is GREEN 286.
`run_l3_selftest` `critical_graph_bug_03` is 11 suites, and the type
budget stays 74 names.
`regress_ns_113` puts the else shell at child 0 of the IF's other body,
child 3 of the same operator. `unit_nested_body_else` exits 0.
`unit_nested_body_while` and `unit_walk_nested_own` stay green. The for
shell still precedes its operator.
`regress_ns_114` keeps that for order. `graph_shape_for_body` still reads
the counter shell, then `FOR`. The for path, its walked twin, and
`unit_nested_body_for` stay green.
`regress_ns_116` reads `else\hosted` as 21 after a call publishes the cell.
`unit_body_path_else` and its walked twin exit 7.
`regress_ns_119` keeps the source after return. The exit letter is first.
The string `kept` and the later assignment stay in the graph.
`graph_shape_keep` exits 0, native and walked. `graph_shape_unknown_atom`
stays green.
`regress_ns_121` keeps an empty group, a discarded call, and a nested
group in that order. The nested group sets `n` to 1.
`graph_shape_discard` exits 1, native and walked. `graph_shape_keep`
stays green.
`regress_ns_122` keeps one anonymous group inside another. The inner
group sets `n` to 2. `graph_shape_nest2` exits 2, native and walked.
`regress_ns_126` keeps an unknown Structure inside another. `B` holds
int 1. `graph_shape_unknown_nest` exits 0, native and walked.
`regress_ns_129` copies that unit. The copy keeps `B` inside `A` and
int 1. The same witness stays green.
`regress_ns_131` merges that outer Structure. The result keeps one
copied inner Structure, parented at the result, holding int 1.
`graph_shape_fields` stays green.
`graph_shape_unknown_atom` and `graph_shape_fields` stay green.
`regress_ns_127` reads the parenthesized body as the same Structure.
`A` holds int 1. `graph_shape_unknown_paren` exits 0, native and walked.
`regress_ns_128` keeps `A()`, `B: ()` and the block form as three empty
Structures. `graph_shape_unknown_empty` exits 0, native and walked.
`regress_ns_132` keeps the call, the compact call, the indexed pair, the
repeated names, the method order, the method if, and the known atom.
All seven stay green, native and walked.
`regress_ns_133` still breaks the structural check when an addition is
erased, a declaration is moved, or two occurrences are collapsed. The
launch exit stays the expected one.
`regress_ns_134` replaces the if body by an empty container. The
structural check fails, and the launch exit stays the expected one.
The erase control stays green.
`regress_ns_136` reads one assigned cell twice. Both reads see 5, so
the sum is 10. `graph_shape_repeat_use` exits 10, native and walked.
The working row is the holder's cell slot, not a per-use leaf.
`regress_ns_137` assigns a hosted field and reads it twice in one call,
then through two later calls. The sum is 20.
`graph_shape_hosted_use` exits 20, native and walked.
`regress_ns_138` binds a dynamic input by the same-name declaration.
The working value becomes 4, the place then reads 100, and the bare
name keeps 4. `unit_arg_decl_dyn` and its walked twin exit 7.
`regress_ns_139` copies `Holder` into `box` and assigns `box\a`.
The copy's field reads sum to 20, and `Holder\a` stays 0.
`graph_shape_copy_field` exits 20, native and walked.
`regress_ns_140` keeps walked recursion at exit 7. `regress_ns_141`
publishes the caller's cell before the re-entrant call. The outer read
is 1 and the base read is 1. `graph_shape_reenter` exits 11, native and
walked.
`regress_ns_142` writes 9 through the address of `x`. The bare name
stays 5. `unit_cache_addr_graph` and its walked twin exit 59.
`regress_ns_144` assigns the last `n` and does not add an occurrence.
`[0]n` stays 1 and the last `n` becomes 6. `graph_shape_assign_occ`
exits 16, native and walked.
`regress_ns_145` refuses `Holder: 1` inside a method. The text is
"more arguments than Holder has formals". The known nested call
`Known(1)` stays refused the same way.
`regress_ns_147` does not bind an absent reference. `b: A` reaches
`b\value` and stops, "unknown field path segment". `@: b A` stops on
that line, "unknown type", with detail `atom=b`. The working alias
remains `Model: b c`.
Codex `GROK-DS-CODEX-REF-ABSENT-20261002-01`: absent `b: A` and
`@: b A` bind one admitted reference, destination then value. That
defect waits until after `critical_pointer_to_struct_bug`. This stage
does not add a name-specific exception. `Model: A` is not the setup.
`regress_ns_148` reads `else\hosted` inside a while after a call.
The value is 21. `unit_body_path_else_while` and its walked twin exit 7.
`regress_ns_149` reads `else\hosted` inside a for after a call.
The value is 21. `unit_body_path_else_for` and its walked twin exit 7.
The for shell still precedes its operator.
`regress_ns_161` puts that for inside an else. One-level dedents close
by themselves. `---` jumps out of the inner if and the else.
`for\hosted` is 21. `unit_body_path_for_else` and its walked twin exit 7.
`regress_ns_162` puts a while inside an else the same way. `while\hosted`
is 21. `unit_body_path_while_else` and its walked twin exit 7. No `end:`
is used.
`regress_ns_167` puts `return: 5` on the same column as `fn:`. It is
that function's trailer and closes three nested `if`s. The call exits 5.
An indented `return` inside the method is not that trailer.
`regress_ns_168` keeps unit order `i`, `i: 6`, `j`, `(2 + 2)`.
`graph_shape_unit_order` exits 6, native and walked.
`regress_ns_169` finds the nested Structure with one `---`. The jump
from the inner `return` back to the loop is more than one level. The
copy and the merge stay green.
`regress_ns_170` drops the extra closers in the two-int search. One
`---` covers each multi-level jump. `return: 0` at the `fn` column
closes the loop. `graph_shape_fields` and `graph_shape_unknown_nest`
stay green.
`regress_ns_176` builds a `Point` inside an else of a method the walk
does not enter. The merge scratch is sized for that declaration.
`else\pt\x` is 4. `unit_body_path_else_unwalked` exits 7, and
`unit_body_path_deep` stays green.
`regress_ns_177` builds a `Point` inside an else that is inside a
while. `else\pt\x` is 4. `unit_body_path_else_while_pt` exits 7, and
the unwalked else stays green.
`regress_ns_178` builds a `Point` inside a for. `for\pt\x` is 4.
`unit_body_path_for_pt` exits 7, and the nested else stays green.
`regress_ns_180` counts a `Point` inside a catch, so the method stays
native. The caught value is 1. `return` on the `fn` column is the
trailer. `unit_catch_scope_repeat` stays green.
`regress_ns_181` builds a `Point` in the then arm. `if\pt\x` is 4.
`return` on the `fn` column is the trailer. `unit_body_path_if_pt`
exits 7, and the unwalked else stays green.
`regress_ns_135` keeps the method-local witnesses. A shared callable,
a copied and merged Holder, a nested Structure, a deeper nest, an array,
an array of arrays, a pointer cell, and a Structure reference stay green,
native and walked.
The
node is still a `CALL`, and the contract still hangs on the method. The slice
stays open. `critical_graph_bug_full_07` is RED 36 of 1159, the same 36 texts
as `full_05`. `build_l2src` `critical_graph_bug_05` is GREEN 286 after the int leaf was withdrawn.
`graph_shape_call` after both call layouts still exits 5 (`regress_ns_43`).
A direct call with no catch and no hidden input is only the callee and those
arguments, at any arity (`regress_ns_49`).
`critical_graph_bug_full_11` is RED 37 of 1159: the same 36, plus one witness
that read a Structure argument as a second callee. `regress_ns_50` is green.
`critical_graph_bug_full_12` is RED 39 of 1164: the same 36, plus three slot
pins of the if shell. `regress_ns_65` is green. Those 36 stay the baseline;
they are not a second ticket.

<a id="critical-pointer-to-struct-bug"></a>
## Second action — critical_pointer_to_struct_bug (CRITICAL / P0, OPEN)

- [ ] Complete [critical_pointer_to_struct_bug](steps/tickets/critical_pointer_to_struct_bug.md)
  after critical_graph_bug and before any reference-application refactoring.

A is held as a reference (conceptually Lmx*); @A addresses the real cell holding
it (conceptually Lmx**). Remove the descriptor-specific address-level erasure
from native and walker lowering, including formals, paths and Array descriptor
references. No C-valued language Structures, temporary address targets or hidden
ABI boxes. Migrate the false A/@A argument-synonym tests and exact-depth admission.
This is an existing bug, independent of the following new rules. The ticket
owns source anchors, positive/negative/mutant witnesses and full release gates.

<a id="structure-reference-application"></a>
## Third action — Structure/reference application refactoring (OPEN)

- [ ] Complete [structure_reference_application_refactor](steps/tickets/structure_reference_application_refactor.md)
  only after the preceding pointer ticket closes.

For absent b, b: A and @: b A are equivalent assignment forms. Afterwards
b: args applies the selected Structure under its actual callable contract;
@: b B explicitly reassigns the reference. Preserve repeated declarations and
the source-body construction rule; do not infer object identity from reference
storage or erase source occurrences. No extra nominal Type entity or implicit
merge. Unary @A still adds an address level; it is not the @: receiver.
Ordinary named Structures acquire no formal arguments. Resolve once and migrate
all consumers; a call failure never becomes assignment. This stage is a
refactoring to accepted rules, not a claim that the current code supports them.

<a id="snapshot"></a>
## 0. Snapshot and what must not be called complete

The starting documentation/source baseline is `f980dce`, containing the
native-dispatch repair `621e8af`. The last complete pre-merge generated-program
run has **1,100 targets: 1,052 OK and 48 FAIL**. Its kernel run has 286/286
targets and 106 self-tests; the separate L3 run has 11 suites and 295 checks.
Those are different suites, not contradictory counts. Green kernel unit tests
do not make the 48 generated-program failures disappear.

The final status of the released `MERGE-RESULT-VALUE-PROJECTION-20261001` slice
is recorded in [its release record](steps/native-selfbuild-20260930.md#merge-result-value-release).
That record, including the exact source hashes, final counts and commit, is
the authority for the handoff boundary; intermediate focused runs are not a
replacement for it. A passing focused run does not certify a full clean kernel.

The source checkpoint is now `8359a59`: focused and restored runs 48/48;
full generated run 1110 targets, 1062 OK, the exact same 48 failures; kernel
286/286; L3 11 suites/295 checks plus four budget controls. Ten new generated
rows pass, with no regressions. This is the starting code snapshot for the v2
handoff, not completion of the clean-kernel dependencies below.

Already repaired bounded mechanisms include actual declared-cell addressing,
whole-Array descriptor projection, common reference initialization/rebinding,
source-site visibility, reference-value transport, re-entry publication, and
dispatch/stop handling for the tested native/walker call routes. Their detailed
boundaries are in [the source/evidence ledger](steps/native-selfbuild-20260930.md).
Do not implement these again from an older checked box; extend the shared
mechanism where a remaining case fails.

The 2026-10-02 pointer ticket explicitly reopens the descriptor-address
exemption: previous bounded gates do not establish that @Structure adds the
required reference level. The two new front stages remain unchecked.

The current merge slice removes the phantom global result namespace for its
supported static operands, stores results at ordinary declaration places,
preserves composed schemas and real expression-host parentage, and corrects
retained-result provenance. It does **not** close arbitrary held/formal/dynamic
operands, general expression receivers, or all Consumer selector projection.

Still not established:

- A full generated-program run with no unexplained failures.
- Complete support for current declaration/call/reference and receiver rules.
- Source-complete executable graphs and native compilation of every required
  body, with no singleton/module-context shortcut.
- General unbounded receiver composition and all Array paths in both engines.
- Executable, independently instantiated L2 libraries suitable for the kernel.
- A kernel and toolchain whose maintained sources contain no handwritten L1.
- Two language-driven self-replacements with tests.
- The complete stage-8a `post` and shared-mail acceptance matrix.

<a id="workflow"></a>
## 1. Restart protocol and acceptance discipline

1. Read `AGENTS.md`, `READ.ME`, `steps/current.md`, this plan and the dictionary.
   Inspect HEAD/upstream, status and worktree ownership. Preserve unrelated WIP.
2. Read the current merge release record. Reconcile its exact file manifest
   with Git before assuming it landed. No second writer/build beside a live one.
3. Follow the mandatory front queue: critical_graph_bug, then
   critical_pointer_to_struct_bug, then structure_reference_application_refactor.
   Afterwards choose one dependency-closed remaining item below. Name files,
   symbols, witnesses and exit conditions. Independent
   read-only review may run in parallel.
4. First reproduce the defect or record it honestly as source-traced only.
   A translator crash is not a language diagnostic; a compiler error is not a
   runtime negative; clearing only root `native` does not prove a nested method
   ran in the walker.
5. Repair the common resolver/projection/operation, then migrate every caller.
   Remove superseded helpers in that same bounded slice. No parallel fallback
   path, source-name exception, or extra persistent graph.
6. Run focused positive and negative witnesses with meaningful observations.
   Counterfactual/mutant checks must fail for the intended reason; record
   observer-only checks separately from actual runtime-mechanism mutants.
7. Run the relevant full generated, kernel, L3, documentation and whitespace
   gates on the exact bytes to be committed. Compare failures by exact fixture
   ID, stage and diagnostic, not just aggregate counts.
8. Commit explicitly listed paths and push. Record implementation, evidence,
   residuals and the next dependency. A bounded improvement may be published
   with the disclosed old red baseline; it is not the clean-kernel checkpoint.

No destructive Git shortcuts and no `git add -A`. Local generated binaries,
scratch manifests and ownership markers do not belong in source commits.
Do not silently promote dev into stable while full gates remain red.

<a id="projection"></a>
## 2. Semantic-use projection dependencies

### K01 — Preserve selector identity through admission and access

**Problem:** `ADMISSION-OCCURRENCE-SELECTOR-COLLAPSE` in
[defects](steps/defects.md#admission-occurrence-selector-collapse).
Required `x,x` and candidate `x,x,x` make bare last-`x` and explicit `[1]x`
coincide in the required layout but differ in the candidate layout. A map keyed
only by required physical slot cannot encode both.

Work:

- Preserve each source use's selector (LAST, explicit occurrence N, or an
  already physical runtime path) from common resolution to the used-edge plan.
- Make analytical admission, read, write, address and capture use that same
  resolved edge. Do not repair reads while leaving admission on another edge.
- Keep correspondence caching distinct from the current Consumer's permission
  to use an edge. Unused incompatible fields must not reject a legal Consumer;
  a later Consumer using them must still be checked.
- Preserve explicit physical permutations supplied by runtime clients. A
  physical path is not a same-index or same-name shortcut.
- Replace fixed-size compiler use-path storage with ordinary growable metadata,
  not a larger constant or a runtime name registry.

Read first: `l2_uses_path_add`, `l2_cap_fields`, `l2_d105_pair`,
`l2_d105_emit_slot`, walker OF/PUT_OF, `LmxImplEntry`, and the common
`L2SchemaField`/`L2ReferenceSource` projection. The precise metadata layout is
an implementation decision still to be validated, not a new language rule.

Acceptance: native and genuinely walked read/write/address/capture of candidate
values 10/20/30; LAST selects 30 and `[1]` selects 20. A candidate with an unused
incompatible first field passes last-only consumption but fails a Consumer
using that first field. Test both admission orders and repeated calls. Preserve
the old explicit runtime-permutation tests. Replace the old 65-use refusal
fixture by successful 65-plus-use coverage and a failure on an actually used
incompatible edge, not by deleting the witness.

### K02 — Finish ordinary merge values on top of K01

- Project the **actual operand**, not an explicit reference's declared model.
  `A{x}`, `B{pad,x}`, reference-to-A holding B must copy/project B's real fields.
- Support formal operands, runtime-selected B/C operands and prior results
  through the same value path. No hidden Structure representing a compiler
  schema and no permanent registry for merge instances.
- Restore caller-local → inherited input → lexical fallback for a free merge
  result. A global result-name lookup must not bypass a dynamic input.
- Support the existing `b: merge A C` form and merge in ordinary receiving
  expressions, including return, under the general receiver mechanism. A
  destination name is not a first operand, and a `return` receiver is not an
  own-field declaration.
- Finish unchanged-code native retention and actual-body replacement rules;
  data changes alone must not force interpretation or retain mutable originals.
- Preserve copy graph cycles/sharing, real host parent, one evaluation per
  operand, qualifiers and all-or-no-result publication on merge failure.

Acceptance: different actual layouts, reads/writes/@, subsequent admission and
merge, formal and hidden inputs, caller priority and lexical fallback, native
and walker. Include a correctly typed structural return and a genuinely
incompatible primitive return. The present “merge expression is not lowered in
this receiving context” is an implementation gap, not normative prohibition.
Do not treat the historical `unit_t7_from_int` shape-parser diagnostic as proof
of either argument order or result-type correctness.

<a id="calls"></a>
## 3. Complete the common head, callable and reference routes

### K03 — Definition, application and assignment everywhere

Implement the already accepted Q56/Q57/Q58 roles uniformly at file root, in
methods, nested Structures, anonymous bodies, formals and receiving expressions:

- Reserved receiver → its general contract; it cannot be shadowed.
- Unknown ordinary head in definition position → named Structure containing
  the written body, not inference of a primitive and not an immediate call.
- Existing callable Structure head → ordinary call; an unknown actual or failed
  admission remains a call failure, never a declaration fallback.
- The general call check uses the **resolved value's** contract, not the spelling
  `A: B`. An ordinary named Structure has only a body and no arguments, so
  supplying B to that value is an arity error; fn/fm/sub use their declared
  signatures. Do not add explicit arguments to an ordinary named Structure.
  See the author's [Q59 clarification](LMX_blog/q/q59.md).
- Existing primitive → assignment after conversion/admission. A held Structure
  reference permits ordinary application b: args; explicit reassignment uses
  @: b B. For absent b, b: A and @: b A are equivalent.
- Explicit dereference → referent value, then ordinary operation on that value.
- Signature descriptions do not execute; structural reference formals are not
  a construction shortcut in executable bodies.

Remove the old `Model: fresh`/`T: b c` implicit-construction recognizers only
after migrating their legitimate setup consumers to explicit definitions,
references or merge. Do not replace them with name-specific refusals.

Acceptance includes equivalent completed surface forms; unknown `f()` defining
empty f versus known f() calling; `C: makeA()` with both names unknown; Q58's
known nested `put: 7` retained without definition-time execution; method arguments
and ordinary rejection of arguments to a resolved argumentless Structure;
empty and nonempty definition bodies; explicit @: reference assignment versus
ordinary application through the reference; declarations without return/trailer;
no source-name or root-only branch.

The current diagnostic “a call of a named Structure with an argument is not
built yet” records a real refusal but gives the wrong reason after Q59. Replace
it through the common resolved-call contract check, not a new syntax-specific
ban and not implementation of invented arguments. The frozen merge slice's
negative fixture is category evidence only until that diagnostic is migrated.

### K04 — Callable actuals and hidden inputs

Complete `CALLABLE-FORMAL-HIDDEN-CONTRACT`, `SUB-ACTUAL-REFERENCE-CLASSIFICATION`,
`CAPTURED-STRUCTURE-ADDRESS-CATEGORY`, and related cases in
[callable projection](steps/callable-actual-projection-20260930.md).

- A selected actual callable supplies its own explicit/hidden/default/result/
  throws contract. Do not marshal the required exemplar's hidden-argument list
  into an incompatible actual adapter.
- Apply caller-source precedence to each actual free input, including ordinary
  Structure, Array, pointer and callable references, not only numeric inputs.
- Preserve callable-formal receipt by reference; a no-result `sub` is not
  coerced to an integer result or automatically executed as an argument.
- Preserve descriptor-only `fn` as a legal signature anchor with no fabricated
  body; direct invocation refuses appropriately. No new descriptor registry.
- Formed arguments, defaults, Consumer uses, result and declared exits use one
  admission path. Do not require equality of unrelated unprepared interfaces.

Acceptance: actual with an extra free input; equal counts but different hidden
names; caller override and lexical fallback; defaults do not persist a previous
call's supplied value; compatible/incompatible callable formals; whole callable
identity and exact self; both execution engines and stopped-call propagation.

### K05 — Remaining reference/path/address defects

Close `LOCAL-REFERENCE-PATH-ROOT`, `NESTED-CALLABLE-OWN-FIELD-PATH`, omitted
primitive-initializer handling, and remaining local declaration-site identity
cases. Do not infer zero/null primitive initialization from compiler storage
convenience. Recheck current code before replaying any old defect description.

Addresses must select real value storage: the cell holding a Structure/Array
reference, primitive cell, Array element or pointer-value cell as appropriate.
`@p` adds
depth to p, not to the referent silently. Address-taking does not newly dirty a
working cache. Complete ordinary explicit paths at arbitrary depth, without
special root/body/node routes or a copied return value as address destination.

<a id="arrays"></a>
## 4. Receiver composition, Arrays and C99 semantics

### K06 — General receiver composition, not a nested-Array recognizer

Replace positional recognizers in declaration collection, own/named/formal
typing and lowering with one application result consumed by later phases.
Read [receiver resolution](steps/receiver-resolution-20260930.md).

Required invariants:

1. `a: b: c: d: ...` has no fixed language depth. A receiver consumes its own
   arguments; `int: i 5` is not automatically synonymous with `int: i: 5`.
2. `[]: []:` is ordinary receiver composition, **not** a separate two-dimensional
   or array-of-arrays construct, special runtime kind, parser scanner or type
   table. What an Array stores does not alter the algorithm of `length`.
3. C-like `[][][]` flat rectangular construction remains distinct.
4. `a[i][j]` selects in one flat rectangle using the source-known stride;
   `a[i]\[j]` selects the Array value from the previous step, then indexes it.
   `s\[N]name` selects a named occurrence; `a\[i]` has no name and is Array access.
5. Interim typed bindings `[]: []: b a[i]` and `[]: c: b[j]` also follow general
   receiver rules. They are not compiler macros for two particular depths.

Acceptance: depth 1, 2, 3 and a deeper generated case; varied receiver and
element kinds, declarations/formals/returns/paths/@/length; mixed Structure
fields and Array hops; literal and computed indices; compiler phase agreement;
native/walker equivalence. Testing a larger depth is a witness, not permission
to add a new hard maximum there.

### K07 — Preserve the minimal Array and level boundary

- Base typed Array is `{size_t len; T *data}`; `VoidArray` uses `size` and
  `void *data`. Lmx embeds the actual `VoidArray` first, then parent/native.
- No capacity, resize, append, backing replacement or growth policy is added
  to base Array. DynamicArray/List is a distinct implementation using it.
- Rectangular `length` is total elements. The descriptor holds no rank/shape
  vector; no `shape(array)` or `rank` promise is being postponed to the future.
- L2 access is unchecked C99-like access. L3 checks the final linear element
  against the selected descriptor. It does not validate every coordinate or
  store every dimension length for bounds checks. Repeated `\` hops each use
  the newly selected Array, not a guessed rectangularity flag.
- Built-in numerical element types retain target C99 meaning. Char is not
  silently redefined as unsigned. A typed Array of references still has ordinary
  elements; it is not a flat matrix.
- Strings/mainArgs are char Arrays of exact logical length, **without** a
  trailing NUL. Conversion to a C string is explicit at the raw-C boundary.
  Process letters have an ordinary declared Structure contract, not a contextual
  type or a table recognized only by the launcher.

Acceptance: flat `[2,3]` linear equivalence `[0,3]`/`[1,0]` in L3; final index
outside total length rejected; no dimension-wise rule substituted. Vary row
lengths in separately referenced Arrays, length at each selected descriptor,
empty Arrays, direct element addresses in L2, primitive/reference storage and
char exact-length/C-string boundary. Do not execute undefined L2 out-of-bounds
behavior just to claim that bounds checks are absent; inspect lowering instead.

### K08 — C99 expressions, foreign values and pointer cells

Close `C99-COMMON-ARITHMETIC`, `RAW-C-TYPE-PROVENANCE`,
`C99-POINTER-CELL-ALIASING`, `FOREIGN-VALUE-MEMBER-PROJECTION` and
`NONTHROW-AGGREGATE-STOP-ABI` through common typing/ABI operations:

- C99 promotions and usual arithmetic conversions precede typed operations.
  Arena storage kinds do not replace the C type system. A size_t typedef is
  compatible with its target base type, not simply with every equally wide type.
- Pointer-value conversion does not license incompatible pointer-cell aliasing:
  converting `int *` to `void *` does not make one cell both `int **` and `void **`.
- Foreign aggregate value member projection uses the correct value category,
  not `->` solely because ordinary Lmx Structures travel by reference.
- A stopped call's result is not consumed; a nonthrow C aggregate return must
  not emit invalid `return 0`, invent a language throw or fabricate a dummy value.
- Every `c.*` token passes to C as a raw identifier. Ordinary arguments still
  follow L2 lowering. No header-derived raw-C-name allowlist, semantic C-name
  dictionary or special
  puts/sizeof/array handling. `sizeof:` is the separate language receiver.

Ordinary processing of explicitly written `.h.lm1` ABI declarations and import
dependencies remains necessary. It is not the forbidden attempt to discover
and authorize raw C names by scanning platform headers.

Acceptance: mixed numeric types and signedness native/walker; comparisons,
arithmetic and short-circuit effects; pointer cell read/write/@ identity under
the actual C optimizer; foreign by-value access; stopped aggregate callees;
unrelated arbitrary raw-C identifiers; no name-specific hidden fallback.

### K09 — Remove compiler limits as semantic restrictions

Inventory fixed method/formal/field/path/uses/send-site/header capacities.
Replace compiler metadata storage through an ordinary reusable dynamic
container. Do not just increase 64 to 128, suppress budgets, split a unit to hide
the limit or turn overflow into a language refusal. Real allocation/resource
failure is distinct from an invented language limit. Keep regression witnesses
above each former threshold. L3 budget checks remain useful until the limits
are genuinely removed; adjust expected source inventories with evidence.

Include runtime traversal limits in the same inventory: current
`LMX_GC_DEPTH = 64` and legacy `L3_DEPTH_MAX = 64` are not language graph-depth
rules. Replace fixed-depth traversal with the appropriate ordinary cycle-aware
mechanism and verify a graph deeper than the old bound, cycles and shared
targets. Do not merely raise constants, create another graph or drop those tests.

<a id="graph"></a>
## 5. Complete graph, working state and admission infrastructure

### K10 — One complete lexical graph, one occurrence-based dispatch

**Priority override:** its confirmed graph-loss defect is now
[the first task](#first-critical-graph-bug), not a later cleanup. Record the
ticket's evidence here when closed; other K10 obligations remain independently
subject to their acceptance below.

- Declarations, typed value storage and executable operators retain lexical
  placement; no pure-data companion, callable-context graph, permanent load
  graph or a graph generated only for root.
- Definitions of named Structures are inert until called. Anonymous executable
  bodies run under their receiver. If/loops are control bodies in the current
  activation, not separate procedure calls or new node bindings.
- `node` remains the above-method lexical space, not nearest control parent.
  Ordinary structural parent links can differ inside a method.
- Compile every statically known body intended for execution. Dispatch always
  examines the selected occurrence's native word; absent native uses its real
  L3 body. A complete interpreted body remains useful when native is absent.
- Preserve the complete binary/operator tree and diagnostic source-name/comment
  information. Do not claim this is done solely because current walker ops run.
- Headless expressions, atoms, anonymous multi-field bodies and empty Structures
  are consumed in order. Unused results go to the existing typed temporary
  `l2_tN`/equivalent expression destination, not a new persistent discard ring.

Audit both current interpreter surfaces: generated typed `lmx_walk` and the
older `dev/l3_interp/l3_exec.lm1` immediate-write subset. A green suite for the
latter does not prove the former's cache/checkpoint behavior, or vice versa.
Remove obsolete semantic divergence through the shared implementation; do not
port an old subset as if it were the complete current interpreter.

Acceptance: Q58, named/anonymous distinction, root and nested bodies, complete
retained tree before/after execution, mixed `(f: 1; f: 2; 2 * 2; f)` witness with
normal name resolution, empty/literal expressions, skipped branches, no fabricated
return/trailer requirement, calls through copied/merged occurrences, native and
walker status/result/state equivalence. Test source retention separately from
successful execution.

### K11 — Working-state and publication matrix

Keep declaration storage distinct from an activation's cached working value.
Only admitted bare writes dirty the applicable own field. Assignments to
explicit/hidden inputs remain local and create no graph field. Direct paths or
addresses modify the real selected cell without secretly reloading the cache.
Checkpoints publish only pending admitted fields; they do not redo admission,
publish clean fields or turn a failed turn into successful outgoing mail.

Recheck call/foreign boundaries, argument evaluation order, recursion, re-entry,
cleanup, return/throw/diagnostic/yield, and non-checkpoint loop transfers. Retain
the approved ordering and no automatic reload. Separate field write-back,
construction-result availability and Message publication in tests and docs.

### K12 — Full implements/conversion/table path

Use Consumer-relative used paths, ordinary primitive conversions and actual
candidate structure. Conversion to a pointer is primitive; structural fit is
implements. Do not create per-user-model primitive types or conversion rows.

Port the complete previously specified primitive-conversion direction table and
ordinary L2 table construction, not merely the subset current examples need.
Inventory old implementation against the accepted current contract before porting;
old code is evidence, not permission to restore superseded semantics. Tables are
ordinary Structures; columns are formal descriptions and rows argument chains,
not a private CSV format, hardcoded filename or root-only input path.

Keep analytical admission distinct from Consumer unit-test execution and from
cached correspondence. Cover the fourteen documented admission recipes and
remaining unit_colon/unit_eternal cases by a current manifest: count actual
reachable fixtures, do not reuse the historical number 17 as proof. No separate
RuntimeImplements decision tree and no test result masking analytical failure.

<a id="clean-gate"></a>
## 6. Clean-kernel checkpoint — mandatory before stage 8

The three front stages (critical_graph_bug, critical_pointer_to_struct_bug,
structure_reference_application_refactor) must be closed first.
All of K01–K12 are dependencies,
not necessarily twelve large commits. Split them
into bounded shared-mechanism slices, with exact witness matrices. The remaining
48 generated failures must each be classified and resolved against current norms;
use [the diagnostic ledger](steps/generated-diagnostic-migration-20260930.md).
Changing an expectation requires a cited accepted rule; do not weaken runtime
observations into compile-only successes.

Acceptance checklist:

- [ ] No unexplained generated failures or silent skipped source operators.
- [ ] Focused negative tests diagnose the intended category; positive tests
  visibly execute and observe the actual state, identity and dispatch route.
- [ ] Full L2 kernel, L3 suites, generated harness and type-budget checks green.
- [ ] No old parallel resolver, header-derived raw-C allowlist, special name, arbitrary depth
  cap, hidden graph or stale documentation/test expectation remains in scope.
- [ ] `check_docs`, generated-source checks and `git diff --check` green.
- [ ] Stable/dev convergence uses the tested dependency closure, not a partial
  file copy that silently combines different ABI generations.
- [ ] Exact commit pushed; source/artifact manifests identify the tested bytes.

Current validation tools, until replaced by language-owned tooling:

```powershell
python tools/check_docs.py
git diff --check
# Supply a verified absolute L1 translator and its actual SHA256; no guessed pin.
powershell -NoProfile -ExecutionPolicy Bypass -File tools/l2_harness.ps1 -Translator <exe> -ExpectedTranslatorSha256 <sha256> -Provenance -KeepAll -OutDir <absolute-evidence-dir>
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_l2src.ps1 -Translator <exe> -ExpectedTranslatorSha256 <sha256> -Run -Strict -KeepAll -OutDir <absolute-evidence-dir>
python tools/run_l3_selftest.py --translator <exe> --output <absolute-evidence-dir>
```

Angle-bracket arguments are placeholders, not runnable shell values. Run one
build chain at a time from the intended checkout. The harness stages dev sources;
verify that staging and predef resolution in its evidence. A named output folder
without a completed manifest is not proof. The tools above build/check the
current transition; running them alone is **not** stage-8 self-build.

<a id="stage8"></a>
## 7. Stage 8 — full L3/L2 self-build without handwritten L1

### S8.1 — Executable library and ownership boundary

Existing separately compiled library tests prove LINK/SYMBOLS, not a running
independent unit. Finish construction in an explicit owner arena and invocation
of the selected unit instance using ordinary dispatch. The investigated
[owner-supplied construction ABI](steps/native-selfbuild-20260930.md#proposed-owner-supplied-library-construction)
is a proposed implementation route to validate, not a new language abstraction.

Remove generated singleton arena/unit dependencies through existing invocation
context and ordinary resolved free/captured references. No temporary root whose
arena dies after wrapper return, nested `lmx_root_open`, replacement of
`current.message.graph`, invisible module field, or unit inferred from the
topmost parent. Carry the existing owner arena through native invocation where
needed; do not create a library-only execution class.

Run one owner with A1/A2 instances of the same library and B1 of another, mutable
state and interleaved expected results such as 41/41/42/42/43/42. Require separate
unit identities, persistence, unchanged owner graph and one final owner close.
Include a copied callable using a sibling/qualified reference. Mutants for
singletons, constant stubs, shared instance state, nested root and premature
release must be detected.

### S8.2 — List/DynamicArray in L2

Port the existing distinct dynamic container, its declarations and consumers.
Do not add growth to base Array. Build/link without the old L1 List body; run
allocation, growth, removal, address/lifetime and child/root/mail consumers.
This step depends on S8.1 because a List library cannot initialize by opening
another root whose own construction needs List.

### S8.3 — Dependency-closed runtime ports

Inventory every maintained body **and header** in `dev/l2src_sandbox`, relevant
`l1src`, and `dev/l3_interp`. Group by actual dependencies:

1. Storage, common dynamic containers, address ranges, arenas and pools.
2. Primitive cells, typed Arrays, Structure construction and qualifications.
3. Copy/merge, common admission/conversions, callable invocation and exits.
4. Mail, Message/Thread, routing, scheduler, roots, collection and close.
5. Walker and L3 interpreter/profile implementations.

For each group keep an inventory row: old source → maintained L2/L3 source,
generated L1/C outputs, imports, tests, old-body removal and exact checkpoint.
No handwritten `.h.lm1` left out of the count, disguised C in generated strings,
link against old hidden object/archive, or dual authoritative implementations.
L2 supplies only necessary machine primitives; ordinary algorithms should be
expressed in L3 when its contract suffices. Port semantics, not C control-flow
accidents, and keep native/walker conformance for all L3 portions.

### S8.4 — Parser and both translation stages

- Port current P0, ownership/text/token storage and diagnostics as a complete
  dependency closure. Existing parser fragments are not the full port.
- Gate parser conformance against current goldens, historical agreement as a
  separate result, and exact empty/container normalization. Do not use the L1
  parser executable as the final self-build oracle.
- Port the L2/L3 compiler and generated-L1-to-C stage themselves. Common
  resolution/schema/use plans must survive the port; do not recreate ad hoc
  declaration recognizers in a new source language.
- Build successor translators and run the same source programs through them,
  including errors, native/walker routes and complete graph preservation.

### S8.5 — Language-owned build and test orchestration

Port buildCore/make/check/finalize, dependency ordering, tool invocation,
artifact checks and internal test orchestration to maintained L3/L2 sources.
Generating a PowerShell/Python script and letting it own the build does not
satisfy this step. The platform C compiler/linker and OS are legitimate external
tools; the language program must orchestrate the ordinary build/test cycle.

Keep the minimal tracked generated-C snapshot and one-time platform bootstrap
separate. It may build the first binary on a new platform; it must not recur
inside ordinary successor builds or kernel edits. No untracked old binary,
downloaded translator, seed archive or developer-local path is an undeclared
dependency. The previous worked buildCore is a reference to investigate, not
evidence that today's tree already does this.

### S8.6 — Two actual self-replacements

1. From the documented platform bootstrap, build generation G0.
2. G0 builds the whole language toolchain/kernel from maintained L3/L2, runs
   the required tests and safely replaces the working executable with G1.
3. G1 repeats that complete process and tests, replacing itself with G2.
4. Record source commit, tool identities, generated intermediates, commands,
   test results and actual executable replacement for both generations.

Generated `.lm1` remains allowed. Maintained handwritten `.lm1` in the kernel,
translator, parser, header closure or internal orchestration does not. Artifact
comparison is useful additional evidence; byte-identical executable files are
not an invented mandatory condition. Retain logs proving which generation did
the work. Windows results establish Windows only; Unix or other targets remain
unverified until actually exercised.

<a id="stage8a"></a>
## 8. Stage 8a — ordinary calls over the existing Message transport

Begin after the accepted S8 checkpoint. The normative contract is
[ordinary transported calls](docs/LMX_semantics.en.md#thread-message-api);
the detailed implementation assignment and its existing test IDs are
[threadMessageAPI](docs/new_parts/threadMessageAPI.en.md) and
[send/receive migration](docs/new_parts/threadMessageAPI_migration.en.md).

### S8a.1 — Common substrate, dependencies only downward

Keep explicit `sendMessage`/`receiveMessage`, their arguments, status/iterator
behavior and terminal 0. They and `post` reuse existing mail enqueue/take,
ownership/attach/publication and ordinary call/admission. No send→post→send
cycle, second queue, second resolver or postal type system. Receive binding
follows the general receiver/declaration contract, not a special visibility law.
Preserve direct-mail tests and prevent the same queued letter being consumed by
two independently invented paths.

### S8a.2 — Preparation and sender-owned wait state

Prepare `ask`, `answer`, `timeout`, `undelivered`, `unanswered`, `catch` through
ordinary Structures and conversion/admission. Waiting state belongs to the
sender and references the original letter/arena, not invented request IDs.
`answer` adds a wait/result route, never a public callable API entry. Validate
answer destinations at preparation using the Message conversion context.
Nested `ms: int: time` must work through common receiver/formal support, with
data path `timeout\ms\time`, not a special timeout type or `int` data node.

### S8a.3 — Calls, results and explicit multiplicity

Invoke the addressed Structure once under ordinary LMX rules. Unrelated
compatible methods are not enumerated. Distribute the one original result to
the explicit answer destinations. One request/three destinations gives **one
execution, one original reply, three deliveries**. Three requests gives
**three executions, three original replies, nine deliveries**. No synthetic
reply for an intentionally no-result sub. Preserve out-of-order correlation
through original identity; no reply ordinal/total protocol.

### S8a.4 — Events, lifetime and scheduling

Use existing clock/deadline operations, starting timeout at actual sending,
not preparation. Sender-side handlers execute on the sender's ordinary lane;
the recipient performs the ordinary call. `undelivered` sees the already formed
original arguments. `unanswered` may merely log; timeout neither cancels the
call, drops a late result nor frees its live wait automatically. Declared
failures go to ordinary matching catch. Preserve Message success and outgoing
publication; no extra timer thread, global listener registry or new call mode.

### S8a.5 — Required T01–T26 observations

| IDs | What must be observed, not merely linked |
| --- | --- |
| T01–T03 | Local/transported result, selection, admission and empty/bodyless-call parity |
| T04–T06 | Wait-only answer preparation, independent live instances, owner-local lifetime |
| T07–T09 | No compatible-method scan; sender-side route failure; real conversion failures |
| T10–T12 | 1/1/3 and 3/3/9 counters; out-of-order original-message correlation |
| T13–T14 | Original undelivered arguments and declared failure payload |
| T15–T19 | General nested receiver typing; no unit/name exceptions; timeout setting distinct from handler input |
| T20–T22 | Timeout from send, late result retained, one mailbox take, correct event trigger |
| T23–T24 | Final-send publication and execution-path parity |
| T25–T26 | Explicit multiplicity without hidden target enumeration; no-result sub without synthetic ACK |

Keep the detailed expected observations in the linked matrix; do not replace
them with this summary. Count executions, original replies, deliveries and wait
entries separately. Mutants for a second source execution, answer-as-method
publication, timeout-from-preparation, double-take and dropped late reply must
be rejected. Rerun self-build and ordinary-call/mail regressions after the port.

<a id="done"></a>
## 9. Completion record and stop condition

The requested destination is reached only when the clean-kernel checkpoint,
S8.1–S8.6 and S8a.1–S8a.5 each have exact pushed implementation and runtime
evidence. A large document, a green parser, a linked library, a kernel-only gate,
or an L1 compiler rebuilding handwritten L1 is not that result.

For each completion record state: source revision and owned paths; norm used;
implementation symbols; exact positive/negative/mutant commands and outputs;
native versus genuinely interpreted coverage; source/staging/commit hashes;
remaining unsupported cases; successor dependency. Update this plan's status
without erasing the historical counterexamples. On a real unresolved language
contradiction, file a minimal Russian question in `LMX_blog/q/current/`; completed
questions move one level up. Plan tickets are not questions to the author.

The original documentation-only pause is historical; the resumed work follows
the current ownership instructions and the first-task priority above. This
priority update does not start another writer/build or claim that stages 8 and
8a have already been achieved.

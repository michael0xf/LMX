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

**Mandatory correction, 2026-10-06: receiver applications require explicit
Frames.** `b: merge: A C` and `b: merge(A C)` are ordinary applications;
`b: merge A C` is not one. The earlier conversational spelling was a typo,
not permission for a receiver-specific argument collector. The writer's first
text census found 260 fixtures using receiver-word atoms with following
operands; this is preliminary evidence, not a final classified migration
count. Finish the independent OWN-TYPE-CODE-BANDS checkpoint already in flight,
then close [K03-EXPLICIT-RECEIVER-FRAMES](#explicit-receiver-frames) before
G5 or self-build. Earlier green rows using the prefix path do not certify
this corrected syntax. The copying/operand/result contract is unchanged.

**Historical handoff, 2026-10-03.** The author transferred continuation to
Fable; Codex finishes documentation and then answers Fable's questions, without
starting another code stage. Read [to_fable.md](to_fable.md) before taking the
single writer/build slot. Latest completed full gate: `critical_graph_fix_full_32`,
RED130/1395. The later `critical_persistent_oracle_01` is focused GREEN7/7;
its copy-to-alias mutant fails in native and cleared-root execution. It is not
a new full-gate verdict. Sandbox code/tests are uncommitted and stable `l2src`
is unchanged. Both critical tickets remain OPEN. Exact current evidence:
[persistent occurrence oracles](steps/critical-graph-namespace-source-layout-20261003.md#persistent-occurrence-oracles).

**Current owner, 2026-10-05.** Opus succeeds the quota-exhausted Fable as the
sole kernel writer/build; Codex answers questions and has a bounded documentation
baton. The three author questions below are answered, not language-decision
blockers. Their implementation and gates remain outstanding where listed.
The [author's decisions](LMX_blog/2026-10-05.md) require source-copy parent
rewriting, explicit `@: add5 makeAdder(5)` result receipt, and ordinary result
type checking for an unknown-head Structure returned as int.

**Continuation, 2026-10-05 (Opus).** The first slice of Codex's handoff
(OPUS-HANDOFF-20261005-103112): a letter held in a place of its own declaration
is admitted to an input of another declaration by what the input's method
reads, through the record of its reception and the pair map of the two
declarations ([TYPED-PLACE-LETTER-READMISSION](steps/defects.md#typed-place-letter-readmission)).
Latest gates on its bytes: kernel `opus_kernel_01` GREEN296 with 113 executed
selftests, L3 `opus_l3_01` 11 suites/four budgets, full `opus_full_02`
RED40/1803 — against `fable_full_43` FAIL→OK 0, OK→FAIL 0, fifteen rows added,
fourteen green and one OPEN required positive red
([gates](steps/fable-continuation-20261003.md#letter-typed-place)). What the
author's three decisions of 2026-10-05 supersede in the ledger and leave to
build: [section 73](steps/fable-continuation-20261003.md#author-decisions-20261005).
The second slice, B: the text of a path or a name of any length on the routes
of a read, a write, an address, an indexed field, a call through a path, the
uses of a typed reference and the static check of a candidate, and a walked
path of any number of names. A wrong translation found beside it is
repaired: the static check of a return value passed over a field name of 128
bytes or more ([FIXED-BLOCKS-AUDIT](steps/defects.md#fixed-blocks-audit),
[RETURN-CHECK-LONG-NAME](steps/defects.md#return-check-long-name)). Gates on
its bytes: kernel `opus_kernel_02` GREEN296 with 113 executed selftests, L3
`opus_l3_02` 11 suites/four budgets, full `opus_full_03` RED40/1813 — against
`opus_full_02` FAIL→OK 0, OK→FAIL 0, ten rows added, all green
([section 74](steps/fable-continuation-20261003.md#path-text-any-length)).
HEAD: a read of a head as a free name before its statement establishes the
method's input, and the statement assigns it; a head nothing established
defines a named Structure. The defect it repairs: declarations were collected
before any input existed, so such a head was taken for a definition. The rows
of the rejected reading are migrated, and fourteen rows are added
([section 75](steps/fable-continuation-20261003.md#head-role-established)).
Gates on its bytes: kernel `opus_kernel_03` GREEN296 with 113 executed
selftests, L3 `opus_l3_03` 11 suites/four budgets, full `opus_full_04`
RED36/1827 — against `opus_full_03` FAIL→OK 4, OK→FAIL 0, fourteen rows
added, all green.
FACTORY: the receiver `@: h f(a)` evaluates the written call, binds its
actuals as any call's, and stores the reference to the callable it returns;
`h`'s slot holds a pointer cell. An unknown head whose tail begins with a
method's name defines a named Structure and calls nothing (Q58). 171 fixtures
are migrated from `h: f a` to `@:`, and three fixtures are added (five rows). The bodies that
nothing calls keep their free names by the norm but are refused by this
translator: two former expected refusals are required positives now, and two
controls are added, red until built
([DORMANT-BODY-FREE-INPUT](steps/defects.md#dormant-body-free-input),
[section 76](steps/fable-continuation-20261003.md#factory-receiver)).
Gates on its bytes: kernel `opus_kernel_04` GREEN296 with 113 executed
selftests, L3 `opus_l3_04` 11 suites/four budgets, full `opus_full_05`
RED40/1836 — against `opus_full_04` FAIL→OK 0, OK→FAIL 2 (the two former
expected refusals), nine rows added, seven green.
T7: the node of a callable merge hangs under a copy of its model's lexical
tree, made at the merge by the copier merge and Message creation share, and
its body reads the copy where no caller gives a name; the view's model
operands are read from the program's unit, a boundary not yet shown
([T7-MODEL-OPERAND-SOURCE](steps/defects.md#t7-model-operand-source);
[T7-NODE-LEXICAL-LINKS](steps/defects.md#t7-node-lexical-links),
[section 77](steps/fable-continuation-20261003.md#t7-copy)). Gates on its
bytes: kernel `opus_kernel_05` GREEN296 with 113 executed selftests, L3
`opus_l3_05` 11 suites/four budgets, full `opus_full_07` RED40/1842 — against
`opus_full_06` FAIL→OK 0, OK→FAIL 0, six rows added, all green. A model
whose body is only its `return:` crashed the translator, before T7 too; the
T7 passes now walk its trailer alone, and a descriptor with neither body nor
trailer stays without an implementation
([T7-TRAILER-ONLY-MODEL-CRASH](steps/defects.md#t7-trailer-only-model-crash),
[section 78](steps/fable-continuation-20261003.md#t7-trailer-only)). Gates on
its bytes: kernel `opus_kernel_06` GREEN296 with 113 executed selftests, L3
`opus_l3_06` 11 suites/four budgets, full `opus_full_08` RED40/1851 -- against
`opus_full_07` FAIL→OK 0, OK→FAIL 0, nine rows added, all green.
A1: the cost of a merge measured with the factors apart -- the copy is the
whole unit with its code, and the end-of-turn collection pass, its per-block
scans of arrays, chunks and the list, takes most of the time; a block or an
array joining the arena walked the growing list each time. Both link in
constant time now, the two defensive selftest expectations migrated
([MERGE-COST-GROWS-WITH-UNIT](steps/defects.md#merge-cost-grows-with-unit),
[section 79](steps/fable-continuation-20261003.md#merge-cost-a1)). Found: a data
merge copies the unit's qualified branch
([DATA-MERGE-COPIES-QUALIFIED-BRANCH](steps/defects.md#data-merge-copies-qualified-branch)).
Gates on its bytes: kernel `opus_kernel_07` GREEN296 with 113 executed
selftests, L3 `opus_l3_07` 11 suites/four budgets, full `opus_full_09`
RED40/1851 -- against `opus_full_08` FAIL→OK 0, OK→FAIL 0.
DORMANT-BODY-FREE-INPUT, part 1: one admission rule at the call -- a required
input no one can give makes the call that starts the chain inadmissible, with
a type or without, through a held call too; 17 rows migrated to the call,
each move recorded, and the Counter witnesses added
([DORMANT-BODY-FREE-INPUT](steps/defects.md#dormant-body-free-input),
[section 80](steps/fable-continuation-20261003.md#one-admission-rule)). Part 2,
a body nothing calls, waits for Codex's answer. Gates: kernel `opus_kernel_08`
GREEN296 with 113 executed selftests, L3 `opus_l3_08`, full `opus_full_10`
RED39/1856 -- against `opus_full_09` FAIL→OK 1, OK→FAIL 0.
RECEPTION-EDGE-DEBTS (c): the result of a call of opaque type given
directly to a Structure formal is received as the same value through a local
reference -- a dynamic candidate admitted where the input is formed, the call
evaluated once -- and the result place reaches the formal, which reads it by
name; the same edge repairs a pointer cast given directly, which was read by
position, a wrong value with no refusal
([CAST-ACTUAL-READ-BY-POSITION](steps/defects.md#cast-actual-read-by-position),
[section 81](steps/fable-continuation-20261003.md#inline-opaque-result)).
Found beside and registered: ARGUMENT-EDGE-REFERENCE-TYPE, with (e); in
OPAQUE-ACTUAL-KNOWN-LAYOUT, with (d), a Structure of another declaration read
by position through an opaque formal (a wrong value with no refusal) and
refused through an opaque local reference. Gates: kernel `opus_kernel_09`
GREEN296 with 113 executed selftests, L3 `opus_l3_09`, full `opus_full_11`
RED39/1864 -- against `opus_full_10` FAIL→OK 0, OK→FAIL 0, added 8.
RECEPTION-EDGE-DEBTS (d): at an input, a candidate its Consumer does not
admit is a possible one when every edge that brings it brings an admissible
candidate from the same place beside it -- refused when the program runs, as
the forming method's `implements`; any other is refused at translation as
before. A name of opaque type records its edge to the formal, an opaque local
the sources of its value: OPAQUE-ACTUAL-KNOWN-LAYOUT is fixed in all three
forms. One row migrated: `unit_free_path_other_chain_refused` is refused when
the program runs
([RECEPTION-EDGE-DEBTS](steps/defects.md#reception-edge-debts),
[section 82](steps/fable-continuation-20261003.md#possible-candidate)).
Gates: kernel `opus_kernel_10` GREEN296 with 113 executed selftests, L3
`opus_l3_10`, full `opus_full_12` RED39/1882 -- against `opus_full_11`
FAIL→OK 0, OK→FAIL 0, added 18.
RECEPTION-EDGE-DEBTS (e): a caller's opaque reference under a free name its
reader uses as a typed reference is admitted as the explicit analogue is --
depth one, by the declaration the value carries, when the program runs, where
the input is formed; with it ARGUMENT-EDGE-REFERENCE-TYPE: a name a level
deeper than the formal, or `@: char`, is refused at translation
([RECEPTION-EDGE-DEBTS](steps/defects.md#reception-edge-debts),
[section 83](steps/fable-continuation-20261003.md#hidden-opaque-typed)).
RECEPTION-EDGE-DEBTS (f): a value of opaque type returned as a typed result
is admitted when the program runs by every field of the result's type, as
the returning method's implicit `implements`; a letter through an opaque
place is not admitted to its own declaration, at the explicit edge nor at the
return (LETTER-THROUGH-OPAQUE-PLACE, asked of Codex;
[section 84](steps/fable-continuation-20261003.md#opaque-return)).
Gates of (e) and (f), one checkpoint: kernel `opus_kernel_12` GREEN296
with 113 executed selftests, L3 `opus_l3_12`, full `opus_full_14`
RED39/1890 -- against `opus_full_12` FAIL→OK 0, OK→FAIL 0, added 8.
DUPLICATE-ADMISSION-STOP, the dynamic part: of the 296 emitted stops "an
admission by name was refused" (census over opus_full_12), the ten at a
return of a value from a place that holds what was given to it are now the
returning method's implicit `implements`; the 286 static ones wait for
Codex's answer on the form of what remains when the refusal is removed
([DUPLICATE-ADMISSION-STOP](steps/defects.md#duplicate-admission-stop),
[section 85](steps/fable-continuation-20261003.md#duplicate-stop)).
Gates: kernel `opus_kernel_13` GREEN296 with 113 executed selftests, L3
`opus_l3_13`, full `opus_full_15` RED39/1890 -- against `opus_full_14`
FAIL→OK 0, OK→FAIL 0.
DUPLICATE-ADMISSION-STOP, the static part, in the default form until Codex
answers: at the 286 static sites the check of the admission's record and its
stop stay, and the stop now says what failed -- "the record of a proved
admission was not kept", a broken translator invariant or an arena table
that cannot grow
([section 86](steps/fable-continuation-20261003.md#duplicate-stop-static)).
Gates: kernel `opus_kernel_14` GREEN296 with 113 executed selftests, L3
`opus_l3_14`, full `opus_full_16` RED39/1890 -- against `opus_full_15`
FAIL→OK 0, OK→FAIL 0.
The receiving numeric conversion, part one (HELD-FREE-NAME-OTHER-TYPE): a
value of another numeric type that a held call hands is converted by that
call, by the ordinary row; absent stays absent and calls nothing; walked, a
general presence guard (GUARD/GUARDED); a handed-on input takes its type
from its callers' bindings, not from its consumer
([section 87](steps/fable-continuation-20261003.md#held-conversion)).
Gates: kernel `opus_kernel_16` GREEN297 with 114 executed selftests, L3
`opus_l3_15`, full `opus_full_17` RED39/1896 -- against `opus_full_16`
FAIL→OK 1, OK→FAIL 0, added 6.
The order Codex's reply OPUS-CODEX-20261005-01 set: HEAD -- the rows that
hold the reading the author rejected for a head no binding established;
FACTORY -- the `@:` receiver of a factory's result; T7 -- the copy's lexical
links by the author's rule, with the complete copy it needs; A -- the cost of
a merge, diagnosed and repaired over the correct copy; then the
receiving-edge debts (c) to (f), the duplicate stop under its real proof, the
numeric conversion at the receiving edge, the outstanding K/G5 dependencies,
the clean kernel and stages 8 and 8a.

Historical runs and intermediate task descriptions below are not restart
instructions where a later measured slice supersedes them.

**Continuation, 2026-10-03 (Fable).** Fable held the single writer/build slot.
Baseline rerun on the handoff bytes: `fable_full_01` RED126/1395, exactly the
four persistent-oracle recoveries against full32. Latest full gate on the
continuation bytes: `fable_full_43` RED39/1788 — against that baseline 98
FAIL→OK, OK→FAIL 0, five red rows replaced and 398 added; the 39 red rows
are 23 of the baseline and 16 added; eleven are labelled OPEN positives and
the other 28 were red in `fable_full_17` too; kernel `fable_kernel_29`
GREEN296 with 113 executed selftests; L3 `fable_l3_29`
([gates](steps/fable-continuation-20261003.md#no-ceiling)). The checkpoint gate
was `fable_full_04` RED70/1401; kernel `fable_kernel_01` GREEN292 with 109
executed selftests; L3 `fable_l3_01` 11 suites/four budgets. Those bytes are committed
as a disclosed RED development checkpoint
([scope and byte tie](steps/fable-continuation-20261003.md#checkpoint),
[manifest](steps/fable-checkpoint-20261003.md)). Not a release: stable `l2src`
unchanged, both critical tickets OPEN.
[Exact evidence, bytes and the remaining rows by mechanism](steps/fable-continuation-20261003.md).

Bounded slices of this continuation (each measured, none closes a ticket):

- [x] K03 setup migration: 28 fixtures off the implicit `Model: x` copy
  (explicit `merge`, nested written definitions); no translator change.
- [x] Native-only source producers: activation-local machine values (imported
  C function-pointer and by-value record locals: retained declaration, one name
  leaf borrowed by every use, no cell and no stack address), foreign member
  path read/store, same-unit forward header, string-literal operand. Witness
  `graph_shape_machine_local` with three shape mutants. The per-method
  machine-local table was stale in three passes and is rebuilt now.
- [x] Three withdrawn or pending expectations migrated to runtime positives.
- [x] Native-only machine operators: address arithmetic, the address of a raw
  element, the raw index of a pointer to a foreign by-value record. Witness
  `graph_shape_machine_address` with shape and translator mutants
  ([ledger](steps/fable-continuation-20261003.md#machine-operators)).
- [x] Foreign by-value inputs and results in the retained graph: empty witness
  place, calls retained whole, native-only callers; the silent producer
  failure is fixed. Witness `graph_shape_foreign_value`
  ([ledger](steps/fable-continuation-20261003.md#foreign-value)).

Subtasks discovered, in dependency order with the items below (all OPEN):

- [x] Common head-role implementation for `h: tail`: an executable free read
  that precedes the statement establishes the input; an unknown `x: j` defines
  Structure x and `return: x` is a result type error. The read is found by the
  scan of free names run as a probe; the old positive expectations are
  migrated; `unit_own_dirty_rhs` and `unit_arg_addr_dyn_types` are green
  ([ledger](steps/fable-continuation-20261003.md#head-role-established)).
- [ ] `unit_free_conv` and its walked twin: `ret_expr`'s `k + 1U` is refused,
  `a U literal in a signed type`, a producer limit of the retained graph,
  with the numeric conversion at the receiving edge
  ([defects](steps/defects.md#free-conv-u-literal-walk)).
- [x] `NATIVE-RAW-INDEX-LITERAL-TYPE`: an unknown foreign raw index is opaque,
  not an int literal (`unit_indent_stack_field_index`).
- [x] Arrays declared in nested bodies in the retained graph and in the
  interpreter; witness `graph_shape_nested_array`
  ([ledger](steps/fable-continuation-20261003.md#nested-array)).
- [x] Held-call boundary, step one: one proved alternative for a whole copy
  of S called in the body that owns S; witness
  `unit_copy_call_hidden_inputs` with a contract-confusion translator mutant
  ([ledger](steps/fable-continuation-20261003.md#held-call-step-one)).
- [ ] Held-call boundary, the rest: selection among alternatives, copies of
  copies and of local Structures, another lexical owner, a free name in a
  method, an addressed row (five red required positives `unit_copy_call_*`),
  and `unit_held_nullary_source_field`.
- [ ] Actual-call boundary for a held/copied ordinary Structure. Codex ruling
  FABLE-CODEX-20261003-02: selection by the actual value's token only as a
  bounded optimization with a proved complete input contract per alternative;
  unknown origin is a located CHECK diagnostic and an OPEN positive, never an
  admission failure
  ([ruling](steps/fable-continuation-20261003.md#held-call-ruling)). Proved by
  declarations so far: a copy called in the body that owns its Structure, a
  chain of copies, a copy of a method's own Structure
  ([step one](steps/fable-continuation-20261003.md#held-call-step-one),
  [step two](steps/fable-continuation-20261003.md#held-call-step-two)). The
  held call of a callable merge takes the arguments of its header at any
  count ([ledger](steps/fable-continuation-20261003.md#held-call-arity)).
  Three required positives stay red: `unit_copy_call_other_owner` (the
  procedure reaches its unit and `node` through the occurrence's parent),
  `unit_copy_call_from_method`, `unit_copy_call_addressed`. The
  unknown-origin case no longer waits for the author: his answer of
  2026-10-04 forbids a name table at run time
  ([record](LMX_blog/2026-10-04.md#no-runtime-name-table)), and the case
  belongs to K04's formation of the actual's inputs from references resolved
  at translation.
- [x] Receiving-use contract, the mechanism and its first producer (Codex
  rulings FABLE-CODEX-20261003-01 and -20261004-01): the shared walk takes
  the model as index space and the coverage of the instruction being run;
  nothing of the answer is kept with the pair; the walker carries the
  coverage in the instruction's cells; the translator gives it for an own
  typed reference of a plain method. The eight witnesses run natively and
  walked; the two false-green refusal rows are migrated
  ([ledger](steps/fable-continuation-20261003.md#receiving-use-coverage)).
- [x] Receiving-use contract, the whole pass and the unconsumed definition
  (Codex ruling FABLE-CODEX-20261004-11): a reference handed whole to a
  plain method takes on what the callee reads through its formal; a
  definition inside the method that nothing calls and nothing returns asks
  for nothing; the static flow at a place of known coverage prunes by that
  coverage. `unit_recv_use_nested_dormant` and `unit_recv_use_passed_thin`
  are green
  ([ledger](steps/fable-continuation-20261003.md#coverage-composed)).
- [ ] Receiving-use contract, the rest. Coverage is unknown, and the
  reception full, for: a reference of the root or of a named Structure's
  procedure; a reference used whole in another way than one whole actual of
  a plain method (a return, a copy, an address, a call through a callable
  formal); a definition inside the method that reads through it and is
  called or returned; a rebound formal, a field store, an element store, a
  return; a candidate of unknown layout. Held and invoked are not told apart
  for a callable at the end of a path. These are limits of the
  implementation, not rules, and no row expects them as refusals of valid
  programs. The `..._limit_probe` rows hold the present conservative mode by
  generated text, and two more hold the refused outside routes to a nested
  definition; they are temporary implementation probes
  ([follow-up](steps/fable-continuation-20261003.md#receiving-use-follow-up),
  [composition](steps/fable-continuation-20261003.md#coverage-composed)).
- [ ] Merge-result declaration inside a named Structure body (internal error)
  ([defects](steps/defects.md#merge-decl-in-named-body-internal)).
- [x] Named actuals: evaluated once in written order, transported by the
  resolved formal coordinate; the retained call keeps each named actual at
  its written place as `NAMED [coordinate, payload]` with its written name;
  no runtime permutation table, no second graph
  ([ledger](steps/fable-continuation-20261003.md#named-actual-order)).
- [x] Named actuals, the written body (Codex rulings FABLE-CODEX-20261004-02
  and -03): the call's P0 body keeps its written fields, wrappers and order;
  the projection by formal coordinate lives in the binding record and every
  reader of a call's actuals takes it through one accessor where it enters
  the body; the binding's memory is released when the translation ends
  ([ledger](steps/fable-continuation-20261003.md#written-body-kept)).
- [x] Named actuals inside the index of a store's head: the binding walks the
  head expression kept by its statement, the tree every reader of the head
  takes. The reader of declarations asks the call role before its cache and
  for a Frame its reading passes through; the binding's records are found
  through an index
  ([ledger](steps/fable-continuation-20261003.md#head-binding-reach)).
- [x] Named actuals of a held callable's call: bound by the formals of the
  header of its declared type, by the binding a method's call gets; written
  order kept in native code and in the retained `PRIM_PUB`
  ([ledger](steps/fable-continuation-20261003.md#held-named-binding)). The
  interpreter does not yet run a callable formal's invocation
  (`--walk-methods` excludes callable formals).
- [x] The role of a statement and of a call head from the binding of the
  site (Codex rulings FABLE-CODEX-20261004-06 and -08): a callable formal
  called as a statement is its call; a store to a number binding is checked
  under a method's name too; a local hides the root's held callable; a held
  callable applied by a statement is its call
  ([ledger](steps/fable-continuation-20261003.md#site-role)).
- [x] The held callable is the row its head selects at the site (Codex
  ruling FABLE-CODEX-20261004-09): the storing shape declares its head only
  where the head has no binding, and is an application or a store under a
  bound one; the roots are collected first and the unit-wide lookup of the
  storing shape is removed; a method's local holds a callable; a held call
  assigned alone is typed; `p0()` as a statement is the call
  ([ledger](steps/fable-continuation-20261003.md#site-selection)).
- [x] No lookup of a held callable ahead of its declaration: a method above
  every declaration of the name has an unknown head there; the bare name of
  a nullary held callable as a statement is its call (Codex ruling
  FABLE-CODEX-20261004-10)
  ([ledger](steps/fable-continuation-20261003.md#no-forward-lookup)).
- [ ] Factory-result reception and its named actuals through the general
  reference receiver: `@: add5 makeAdder(5)`, and `@: h2 make2(n: 100)`.
  The author has settled the rule; ordinary unknown-head `add5: makeAdder 5`
  defines a dormant body and must not use the legacy eager factory shortcut.
  Migrate factory-result fixtures explicitly, retain Q58 dormant-body controls,
  and gate both native and genuinely walked execution. This is implementation
  debt, not an unanswered language question
  ([answer](LMX_blog/q/held-factory-initialization-versus-body-definition.md),
  [defects](steps/defects.md#factory-result-receiver)).
- [x] The bare name of a held callable where a number is received as a
  whole value (a store, an initializer, a number formal's actual, a number
  method's return, a field through a path, an element, a message field)
  executes the callable, and the place's conversion applies to the result;
  a place that receives a reference takes the occurrence (Codex rulings
  FABLE-CODEX-20261004-11 and -12)
  ([ledger](steps/fable-continuation-20261003.md#result-receipt)).
- [x] The same for operands: arithmetic, orderings, equalities, logical
  operations and the one value of a condition receive the result;
  `p0 = 0` compares the result, not the occurrence; a short-circuit does not
  execute the operand it skips. A native group that calls keeps its
  parentheses
  ([ledger](steps/fable-continuation-20261003.md#operand-receipt)).
- [x] A held call from a definition that a method returns: a reference among
  its free names reads its lexical source where the caller supplies none, as
  a number did. The bounded step Codex allowed; the positives by caller are
  green natively and walked
  ([ledger](steps/fable-continuation-20261003.md#nested-references)).
- [ ] A caller's own reference of another declaration under a held callable's
  free name is refused where it stands, a limit of the implementation; by
  the rules it comes first. A G5 blocker with a red required positive; it
  waits for the admission of K04's common formation
  ([defects](steps/defects.md#held-free-reference-other-declaration)).
- [x] A call through a callable formal forms the inputs of the methods that
  reach the formal, never the declaring method's list (K04,
  CALLABLE-FORMAL-HIDDEN-CONTRACT, first slice). Flow facts at the call
  check, their closure, the reaching methods' free names in the ordinary
  fixed point, the formation at the call. Chain, mutual recursion, a callee
  that is a formal's value, a supplied zero, a dormant definition and the
  refusal of a missing input are gated
  ([ledger](steps/fable-continuation-20261003.md#formal-formation)).
- [x] The second slice, part one: the transport of an absent input. A
  number no caller binds is handed absent; a method that only forwards it
  hands its entry on as it is; the method that reads it takes its own
  lexical source, the native entry as the walked body. The comparison of
  lexical declarations is gone and `_lexical_differ` is green. The library's
  ingress is a flow fact
  ([ledger](steps/fable-continuation-20261003.md#absent-input)).
- [x] The second slice, part two: a call site asks only for the names of the
  callable it gives, the other entries absent; the conditions kept whole,
  with no limit on their number; the formation selected by exact occurrence
  where one formal has several, the last class the proven remainder; a
  required input no one can give refused at translation where the chain
  starts, and the entry's abort removed
  ([ledger](steps/fable-continuation-20261003.md#site-requirements)).
- [x] The third slice, step one: a held call asks its model's number names
  along the chain of callers; a name of the method that made a definition
  stays the definition's free name, the copied value its own source
  ([ledger](steps/fable-continuation-20261003.md#held-chain)).
- [x] The third slice, step two: a held definition as the actual of a
  callable formal, admitted by its model's signature, handed as the node
  itself, its free names formed where the formal is called; the presence
  record of step one closed by enumeration and by an instrument over the
  corpus ([ledger](steps/fable-continuation-20261003.md#held-actual)).
- [x] The third slice, step three: formation against transport, with the
  book's §12 clarified from the existing norm; a definition's assignment to
  a name of its method; a merge's node with its complete contract, its body
  reading each input at its place; a merge given as the actual followed as a
  node of its model; the tables of merges growing with the program;
  `unit_t7_convert` green
  ([ledger](steps/fable-continuation-20261003.md#merge-actual)).
- [x] The third slice, step four, a merge's node: one constructor for a
  native and a walked body; a method that does something before it returns
  a merge ([T7-HOST-BODY](steps/defects.md#t7-host-body)); the root's two
  bodies build the node as a method's do
  ([T7-ACTUAL-FROM-ROOT](steps/defects.md#t7-actual-from-root)); a body
  that is always walked gives a merge as an actual; a host's nested body is
  its statements, a wrong native value found and repaired
  ([HOST-BUILDS-IN-NESTED-BODY](steps/defects.md#host-builds-in-nested-body),
  [ledger](steps/fable-continuation-20261003.md#merge-node-construction)).
  A bounded case: the rows call the node with its bound formal at its
  default.
- [ ] A merge returned from a nested body of its method
  ([T7-HOST-NESTED-RETURN](steps/defects.md#t7-host-nested-return)); the
  consumer of a merge given as an actual, walked.
- [x] Repair copied lexical links under the author's settled rule: merge
  copies the used source tree and rewrites parent links inside that copy.
  The execution site supplies no lexical parent or re-resolution of names.
  Gate a source value 9 against merge-site value 50 with no dynamic input:
  the copy reads 9 before and after mutation of the original to 11; explicit
  node paths use the copied source relation. Keep dynamic-input priority,
  shared targets/cycles and native/walk parity
  ([answer](LMX_blog/q/merge-lexical-copy-and-root-placement.md),
  [T7-NODE-LEXICAL-LINKS](steps/defects.md#t7-node-lexical-links)).
- [ ] Show the source of every model operand in a merge's view -- a path's
  crossing, an admission, an input's witness: the receiving declaration's
  schema witness, a value read from the copied lexical graph, or the actual
  candidate. A paired control with and without an earlier admission record
  observes the physical model source and the candidate's field; a genuinely
  dynamic requirement takes its physical source
  ([T7-MODEL-OPERAND-SOURCE](steps/defects.md#t7-model-operand-source)).
- [ ] The written shape of a callable merge: the translator reads
  `merge(y: k; add)` as `merge(add; y: k)`, against three rules of
  `#composition`. By Codex's fourteenth reply no author decision is needed:
  the wrapper with a nested method gets its producer and its path positive,
  a callable place admits the value actually built, there is no refusal by
  operand order, and fixtures that meant a specialization move to the model
  first with the change named
  ([T7-DATA-FIRST-SHAPE](steps/defects.md#t7-data-first-shape)). Only a
  method of the unit can be the model
  ([T7-MODEL-ONLY-UNIT-METHOD](steps/defects.md#t7-model-only-unit-method),
  [ledger](steps/fable-continuation-20261003.md#fourteenth-reply)).
- [ ] A merge keeps the model's whole callable interface: `add5(1; y: 25)`
  26, `add5(1; y: 0)` 1, then `add5(1)` 6 are required positives, refused
  today; the node a merge builds keeps only the unbound formals
  ([MERGE-KEEPS-MODEL-INTERFACE](steps/defects.md#merge-keeps-model-interface)).
- [ ] The third slice, the rest: the reference: its absence
  (`unit_callable_formal_site_names_reference`), its asking along the chain
  through a held call, which gives a wrong value today
  ([HELD-REFERENCE-NOT-ASKED-ALONG-CHAIN](steps/defects.md#held-reference-chain)),
  its admission through a held call
  (`unit_nested_definition_structure_override`), and through a Structure the
  unit holds, read by a merge's node (`unit_t7_actual_reference`); a
  handed-on name its callers give two types
  (`unit_held_call_free_name_two_types`, FORWARDER-BINDINGS-OF-TWO-TYPES; the
  conversion of a handed-on input is built,
  [section 87](steps/fable-continuation-20261003.md#held-conversion));
  the library unit's callable formal (`unit_lib_callable_formal`); the walked
  consumer (`unit_callable_formal_free_names_self_walk`) and a merge's node
  built in a walked body (`unit_t7_actual_from_root`); the complete copy of
  a node built at run time against L2 §13 and a node's own contract route,
  by which its class is told among callables formed differently
  (`unit_held_actual_among_methods`, `unit_held_actual_two_models`,
  `unit_callable_formal_unfollowed_actual`). Any new route that makes an
  occurrence a value writes its flow fact or the row "not followed".
- [ ] A held callable given to an explicitly declared callable formal is
  received as its occurrence; the translator refuses it today. A G5 blocker
  with a required red positive
  ([defects](steps/defects.md#held-callable-to-callable-formal)).
- [ ] The audit of the statement classifier's callers that have no site
  ([ledger](steps/fable-continuation-20261003.md#site-selection)).
- [ ] A held callable whose declared result header and returned definition
  name their formals differently: the binding takes the header's names
  today; whether that named use is admitted by the callable's actual
  interface is OPEN, and G5 stays open with it (Codex ruling
  FABLE-CODEX-20261004-08)
  ([defects](steps/defects.md#held-header-names-not-actual-interface)).
- [x] With the methods walked, a throw raised while an operand is evaluated
  leaves the outer CALL or PRIM with its own number, landing and payload: the
  outer operation takes the payload and applies its catch rows only for its
  callee's throw
  ([ledger](steps/fable-continuation-20261003.md#operand-throw)).
- [x] Prefix signs `-` and `+` in the shared expression producer: a retained
  unary operator with one source operand (`NEG`, `POS`), for expressions,
  returns and actuals; no invented zero subtraction
  ([ledger](steps/fable-continuation-20261003.md#prefix-sign),
  [ruling](steps/fable-continuation-20261003.md#written-body-and-prefix-ruling)).
- [ ] The other prefixes of the grammar (`!`, `~`, `++`, `--`), not built; and
  the P0 parser's split of an operator written against a call head
  ([defect](steps/defects.md#p0-operator-before-call-head)).
- [x] A path through a merge result's reference field, read and store, with
  the store admitted to the field's model
  ([ledger](steps/fable-continuation-20261003.md#merge-result-reference-field)).
- [x] A reference field read as a value into a reference local: `q: a\next`,
  `p: p\next` along a chain (REF-FIELD-VALUE-READ)
  ([ledger](steps/fable-continuation-20261003.md#ref-field-value-read)).
  Gates: kernel `opus_kernel_18` GREEN297 (114 selftests), L3 `opus_l3_17`,
  full `opus_full_19` RED39/1906 -- against `opus_full_18` FAIL→OK 0,
  OK→FAIL 0, added 2.
- [ ] Nested correspondence maps across distinct nested definitions; capture of
  a merge-result local; foreign by-value call producer; address-arithmetic and
  nested-body Array producers; C99 common arithmetic (K08) for the `1U` rows.
- [x] Normative triage of the stale negative/text-pin rows
  ([ledger](steps/fable-continuation-20261003.md#triage)). Left: the three
  `unit_arr_path_*_refused` letter rows (with K06/K07) and `unit_asgn_fallback`
  (author question).
- [x] Indexed field path whose container is a merge result, and the address
  of an element through a path in the retained graph; witness
  `unit_arr_path_merge_result` with two translator mutants
  ([ledger](steps/fable-continuation-20261003.md#merge-result-array)).
- [x] Capture of a whole copy of S by a nested method
  ([ledger](steps/fable-continuation-20261003.md#capture-copy)).
- [ ] Capture closure, the rest: a captured Structure used whole
  (`unit_capture_struct_whole`), a captured copy of several operands
  (`unit_capture_struct_merge_two`).
- [x] Reception into a letter model, `receiveMessage: m T`, in the retained
  graph and in the interpreter, with the root statement no longer dropped
  ([ledger](steps/fable-continuation-20261003.md#receive-model)).
- [x] A field path that ends at a Structure field, as a returned value and as
  an argument: nested written leaves, the admission source, the graph
  reference ([ledger](steps/fable-continuation-20261003.md#structure-path-value)).
- [ ] Letter Array-of-Array element contract for a typed letter reference
  (`entry_arg_len`, `entry_index`, `entry_strcmp`, `entry_parse_min`,
  `unit_charpp_return`, `unit_l2_puts_library`).

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
- [x] G2 bounded resolved external-native application producer: raw `c.*` and ordinary
  functions admitted by the existing parsed-predef mechanism must use one
  retained statement/expression construction route. Carry ordinary actuals
  through their resolved spans and real declared places, not fresh symbolic
  leaves or a second AST. COUNT/PLACE/FILL must retain the complete method
  source even when its operations require native dispatch. A method whose
  body is omitted after a quiet walker-eligibility refusal is not source-faithful.
  Positive native effects, exact graph/target/value assertions, an independent
  erase mutant, an ordinary LMX-call opposite and unknown-head definitions
  are measured by `critical_graph_external_producer_07` and `_08`: ordinary
  source-bearing method COUNT no longer quietly discards native-only bodies.
  `_07` RED1/29 was only a new mutant command omission; `_08` GREEN18 verifies
  the corrected real mutation and local-field/throw/macro regressions. External
  statement/assignment/return actuals, conditional and post-return operations,
  lexical shadowing, and unchanged native words have exact graph assertions.
  This is not the complete source codec: library/local procedure/PAP/MAD routes
  and general method-source producers still have open gaps. The G2/G3 and full-
  gate items remain open.
- [x] G2 bounded field-constructor reuse: placed field Structures are filled
  through their actual source holder/child after namespace references exist,
  without another owning node or an old late duplicate fill. The exact Holder
  oracle now requires its source method RET as well as ordered values/names/
  parents; `_08` passes native, cleared-root, native-retention and real erase
  controls. That historical run returned94 on repeated calls. The later
  whole-local-source producer preserves the persistent declared occurrence,
  removes reached-declaration cloning and measures99, with genuine walked
  coverage (`critical_local_source_12` GREEN24 and later context controls).
  Do not restore a fresh-instance producer from this superseded observation.
  Actual copied/held-call input formation remains separately OPEN.
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
- [x] G4 bounded valid explicit-copy witness:
  `critical_graph_explicit_copy_01` GREEN10, including the actual runtime merge
  return, not a surrogate P0/unit copy. The new witness passes61 checks:
  distinct primitive/INIT/OWN objects, complete original INIT, forced walking
  of the actual result after mutation and native execution of the original
  retain independent values. It uses explicit `merge` and a typed reference
  field, not obsolete `Point: box` or the still-open `@Structure` address route.
  This does not close whole-body/source-codec G4 or release the critical fix.
- [x] G2 bounded namespace/execution-entry field-contract join: native lookup
  reuses the exact original namespace via `l2_m_nsof`/`l2_ns_source_body`;
  existing own/formal priority and actual current-self projection remain.
  `critical_graph_namespace_read_02` RED2/26: both additive read witnesses
  pass108 checks each with Array/borrowed-method identity and lexical parent,
  length and physical increment verified; selected prior controls pass.
  The only failures are the two unchanged indexed-STORE witnesses. No full
  gate has run on these later bytes; this does not close the connected item.
- [x] G2 bounded constructed-field indexed places: the original namespace
  contract, existing NSF row and completed physical slot supply the shared
  CHECK/native/walker route, including `Shelf\values[0]: 4`.
  `critical_graph_array_place_08` GREEN16 closes the two indexed-STORE
  refusals recorded above; [exact scope](steps/critical-graph-namespace-source-layout-20261003.md#array-place-evidence)
  remains distinct from arbitrary nested/imported Array coverage.
  The descriptor supplies actual storage, not a fabricated own row, raw-pointer
  substitute, nested-Array special case, depth cap or rank inferred from length.
- [ ] Before G5, the fixed sizes step B left, each a bounded cleanup subtask
  with a long positive and a mutant that restores the size; a located refusal
  is evidence of the implementation, not leave to keep a language limit
  ([FIXED-BLOCKS-AUDIT](steps/defects.md#fixed-blocks-audit)):
  - [x] sizeof's operand name, 200 bytes; with it SPRINTF-PAST-BUFFER, two
    unbounded writes past a fixed buffer reached by programs (a nested
    loop's step, `sizeof(c.<name>)`)
    ([section 90](steps/fable-continuation-20261003.md#sprintf-past-buffer)).
    Gates: kernel `opus_kernel_19` GREEN297 (114 selftests), L3 `opus_l3_18`,
    full `opus_full_20` RED39/1909 -- against `opus_full_19` FAIL→OK 0,
    OK→FAIL 0, added 3.
  - [x] loops and catch blocks nested more than 64 deep, open pads, and
    more than 64 catches of one emission (refused in the walker's wrong
    words): as many as the program nests and writes
    ([section 91](steps/fable-continuation-20261003.md#emission-stacks)).
    Gates: kernel `opus_kernel_20` GREEN297 (114 selftests), L3 `opus_l3_19`,
    full `opus_full_21` RED39/1911 -- against `opus_full_20` FAIL→OK 0,
    OK→FAIL 0, added 2.
  - [x] source tables: 8 tables, 32 columns of one and 128 of all, 4096
    cells, a cell's text of 127 bytes
    ([section 92](steps/fable-continuation-20261003.md#source-tables-any-size)).
    Gates: kernel `opus_kernel_22` GREEN297 (114 selftests), L3 `opus_l3_21`,
    full `opus_full_23` RED39/1912 -- against `opus_full_21` FAIL→OK 0,
    OK→FAIL 0, added 1.
  - [x] send sites: 64 sites and 16 fields of a letter
    (SEND-SITE-ARTIFICIAL-CAPS,
    [section 93](steps/fable-continuation-20261003.md#send-sites-any-count)).
    Gates: kernel `opus_kernel_23` GREEN297 (114 selftests), L3 `opus_l3_22`,
    full `opus_full_24` RED39/1917 -- against `opus_full_23` FAIL→OK 0,
    OK→FAIL 0, added 5.
  - [ ] the size of the L1 emitted for nested loops, faster than the square
    of the nesting (seventy nested `for:` loops: 27.5 MB) -- an implementation
    cost subtask, not a nesting cap (Codex 2026-10-06): a publication helper
    keeps the ordinary machine activation, dirty-only timing, the
    call/exit/yield/cleanup order and one graph; no loop procedures, extra
    activations or state graph;
  - [x] the text of one expression in the emitter, 1023 bytes
    (`l2_cat`), and the buffers that feed it, the path of an actual of at most
    32 names among them. Ordinary programs meet it: a sum of about a hundred
    operands is refused, and two shapes refuse with no located diagnostic
    (D-112, exit 3): a literal operand of 256+ bytes and a C call of 300
    actuals. Codex 2026-10-06: the growable text directly -- one compiler-only
    owned text builder (data, length, capacity; `l2_xmalloc`/`l2_xfree`),
    migrated in dependency slices, each gated; a route is done only when its
    writers and readers use it; no new cap, larger buffer or permanent
    "expression too long". Required positives: the long sum well beyond the
    old boundary, a 260+ byte literal operand through the C-door
    preparation, a C call of 300+ actuals through the ordinary join, with
    more than one growth, nested and parenthesized preparation, live=0.
    Slice 1 done
    ([section 94](steps/fable-continuation-20261003.md#expression-text-slice-1)):
    the text `L2Tx`; evaluation and joining, operand preparation, the C door
    and a C call's value, the statement's text and its readers, a letter's
    fields; an atom of any length; C-CALL-VALUE-TEXT-CUT fixed with it.
    Gates: kernel `opus_kernel_24` GREEN297 (114 selftests), L3 `opus_l3_23`,
    full `opus_full_25` RED39/1928 -- against `opus_full_24` FAIL→OK 0,
    OK→FAIL 0, added 11. Slice 2 done
    ([section 95](steps/fable-continuation-20261003.md#expression-text-fixed-routes)):
    seven routes that took a migrated text into a 1024-byte buffer write into
    a text of their own. Gates: kernel `opus_kernel_25` GREEN297 (114
    selftests), L3 `opus_l3_24`, full `opus_full_26` RED39/1936 -- against
    `opus_full_25` FAIL→OK 0, OK→FAIL 0, added 8. Slice 3 done
    ([section 96](steps/fable-continuation-20261003.md#expression-text-path-actual)):
    a path actual of any number of names. Gates: kernel `opus_kernel_26`
    GREEN297 (114 selftests), L3 `opus_l3_25`, full `opus_full_27`
    RED39/1938 -- against `opus_full_26` FAIL→OK 0, OK→FAIL 0, added 2.
    Owner groups 1 and 2 done
    ([section 98](steps/fable-continuation-20261003.md#expression-text-owner-groups)):
    the 27 writers whose callers already hand a text write it themselves;
    `sizeof` of a type frame of any depth. Gates: kernel `opus_kernel_28` GREEN297 (114 selftests), L3 `opus_l3_27`, full `opus_full_29` RED39/1943 -- against `opus_full_28` FAIL→OK 0, OK→FAIL 0, added 1.
    Owner group 3 done
    ([section 99](steps/fable-continuation-20261003.md#expression-text-owner-group-3)):
    tokens, places and declarators of any length; no writer of the
    expression text is handed a fixed room, `l2_cat` is gone;
    [ADDRESS-TYPE-PAST-BUFFER](steps/defects.md#address-type-past-buffer)
    fixed with it. Gates: kernel `opus_kernel_31` GREEN297 (114 selftests), L3 `opus_l3_29`, full `opus_full_31` RED39/1953 -- against `opus_full_29` FAIL→OK 0, OK→FAIL 0, added 10.
  - [ ] the expression text's residuals (FIXED-BLOCKS-AUDIT, Codex
    2026-10-06): the migrated routes no recorded translation reaches
    (`l2_mrs_occ_read`, `l2_emit_array_load_at`, `l2_emit_own_index`'s
    literal and loaded index, `l2_emit_arr_operand`'s element branches,
    `l2_emit_indexed`'s load branch, `l2_tok_slot`,
    `l2_emit_reference_declaration`, a machine local or a define name in a
    raw index) wait for the producer and reachability census -- no removal
    on coverage, an unchanged replay or "not this shape"; the held call's
    converted value and the indexed operand's value route have unreached
    mutants; behaviour pinned only by text (the receiving admission's
    temporary, the captured indirect place, a slot load's cast) needs
    behavioural witnesses; a foreign C name past 63 bytes is measured on
    translation only until `l1trans`'s step;
  - [ ] a checked build, or a test-only witness, that a call's actual records
    and their slots do not overlap (Codex 2026-10-06): slice 2's overlap
    mutant is killed only by chance; the existing toolchain where it serves;
    no defensive check in the translator to kill a test mutant;
  - [x] a failed allocation in the emission said twice, located and again at
    1:1 ([ALLOC-FAILURE-SAID-TWICE](steps/defects.md#alloc-failure-said-twice)):
    said once now; harness rows fail one allocation, found afresh by the
    allocation trace (Codex 2026-10-06, Question A,
    [section 97](steps/fable-continuation-20261003.md#alloc-failure-rows)).
    Gates: kernel `opus_kernel_27` GREEN297 (114 selftests), L3 `opus_l3_26`, full `opus_full_28` RED39/1942 -- against `opus_full_27` FAIL→OK 0, OK→FAIL 0, added 4.
  - [ ] the machine-local path root (`l2_path_root`'s branch with
    `i < 990`, `l2_proot` 64 in `l2_emit_path_to`): two producers reach it
    ([DECLARATION-CANDIDATE-ROLE](steps/defects.md#declaration-candidate-role),
    [OWN-TYPE-CODE-BANDS](steps/defects.md#own-type-code-bands)). Order
    (Codex 2026-10-06): shared declaration/candidate validation -> kind and
    type kept apart in the own-storage code -> a renewed producer/read census
    with the reference-path controls, native and walked -> removal of the
    route and its readers; legitimate foreign by-value and function-pointer
    machine locals stay. The shared validation is done
    ([section 100](steps/fable-continuation-20261003.md#declaration-one-value)):
    a declaration's candidate is one value, the extra value refused at the
    declaration, no machine local made of it. Gates: kernel `opus_kernel_32` GREEN297 (114 selftests), L3 `opus_l3_30`, full `opus_full_32` RED39/1971 -- against `opus_full_31` FAIL→OK 0, OK→FAIL 0, added 18.
    A call is its Frame (the author, 2026-10-06,
    [section 102](steps/fable-continuation-20261003.md#declaration-call-tail-answer)):
    `make 3` in a candidate is two values, refused at 3; the callable-first
    reading is gone from both classifiers
    ([CALLABLE-FIRST-TAIL](steps/defects.md#callable-first-tail)). Gates: kernel `opus_kernel_34`
    GREEN297 (114 selftests), L3 `opus_l3_32`, full `opus_full_34` RED39/1981 -- against
    `opus_full_32` FAIL→OK 0, OK→FAIL 0, added 10.
    Kind and type are kept apart in the own-storage code
    ([section 103](steps/fable-continuation-20261003.md#own-type-code-bands-fixed);
    [OWN-TYPE-CODE-BANDS](steps/defects.md#own-type-code-bands) fixed): no bands, the graph
    reference's own formal code 42, the null literal the pointer cell of the place's value
    type. Next in this item, after [K03-EXPLICIT-RECEIVER-FRAMES](#explicit-receiver-frames):
    the renewed producer/read census. Gates: kernel `opus_kernel_36`
    GREEN297 (114 selftests), L3 `opus_l3_34`, full `opus_full_36` RED39/1993 -- against
    `opus_full_34` FAIL→OK 0, OK→FAIL 0, added 12.
  - [ ] the names of methods, formals and declared throws, 62 bytes: a
    method used as a value gets a public C wrapper under its source name,
    and `l1trans` keeps function names in 64-byte slots (`l1_fn_ensure`) --
    the limit moves with `l1trans`'s own step
    ([section 88](steps/fable-continuation-20261003.md#fixed-counts)). After
    the expression route (Codex 2026-10-06): the bounded `l1trans`
    storage/self-build step, its pin refreshed through the existing verified
    chain; no truncated or renamed source identities, no downstream L2/L3
    self-build before G5 is green;
  - [ ] a fortified translator as an additional test build (Codex 2026-10-06):
    distinct from the canonical binary and its pin, its source bytes tied to
    the same checkpoint, no installed dependency, its aborts never in place
    of a located diagnostic; its overhead measured before it would become the
    sole harness compiler;
  - [x] eight callable formals written in place in one method, 32 captured
    fields: as many as the method's formals and the captured Structure's
    fields ([section 88](steps/fable-continuation-20261003.md#fixed-counts)).
    Gates: kernel `opus_kernel_17` GREEN297 (114 selftests), L3 `opus_l3_16`,
    full `opus_full_18` RED39/1904 -- against `opus_full_17` FAIL→OK 0,
    OK→FAIL 0, added 8;
  - [x] the words of refusals that cut a long name: made in memory of their
    own size, every refusal that names a name or a path. Two catches of one
    name of 300 bytes crashed the translator (an unbounded `sprintf` into
    160 bytes, DUPLICATE-CATCH-LONG-NAME)
    ([section 88](steps/fable-continuation-20261003.md#fixed-counts)).
- [ ] G5: fix or justify each full-gate refusal by the current norm and release
  an actually green graph checkpoint before the pointer implementation.
  Earlier full `critical_graph_fix_full_12`: RED, 204 of 1284,
  source SHA256 `8A4841BA2B8130EB6E6081B77644A072849F6E488A2C666EDDE2386047908C2D`.
  Mandatory method retention exposes previously skipped source producers;
  relative to full11, ten old failure identities disappear and 169 new ones
  occur. Repair context-aware callable resolution, method Structure receiver
  places, executable local definitions, proven foreign-member paths and local
  admission before retrying the full gate. Do not restore quiet source discard.
  Subsequent focused external-producer09 is GREEN39, including migrated hosted
  field paths and a real erase mutant; it is not a replacement full verdict.
  Focused `critical_graph_callable_producer_05` is GREEN25 on source
  `C1EA155D8CEEDBED8F0F4E9EB058A448457BF066255C2AD9EF08FB23BE4E24CB`:
  source calls retain the explicitly selected actual formal and signature,
  forwarded/path occurrences are transported without execution, and no-result
  callable actuals use their occurrence schema. The exact new source witness
  passes 1189 assertions; erasing its actual EXEC ARG fails shape checks with
  unchanged exit7. Own/formal shadow ordering, upstream path-buffer limits,
  two `int`/`1U` producer refusals and the absent-occurrence diagnostic remain
  audited debts. Existing walker exclusions are not waived. Earlier completed
  full `critical_graph_fix_full_13` is RED185/1286 on the same C1EA source:
  19 old failure identities disappear relative to full12, with no new failure
  identity. Its executable SHA256 is
  `2B3089FEC181A1B1BFC5793F8A868F0343F17CB4FC4B56A8D9A37F844316F802`.
  The later own/formal ordering, source-site binder, rootless occurrence and
  local-model producer edits are measured by `_callable_producer_07` (RED1/23)
  and `_08` (RED1/26), source
  `DBF576ACB2E50F39FC69849C9EF25E32B37549E0232F9EA7D1D5F89D3A33E7D0`.
  All their bounded callable/binding/occurrence/model witnesses pass; the sole
  failing row remains the unimplemented raw-pointer indexed-store source
  producer. Three full own/formal source-shape witnesses pass 329/869/489
  assertions; genuine erase mutants fail shape with unchanged positive result3.
  Full14 completed RED178/1292 on those frozen bytes, executable
  `048C0659DE0C6755E0D5C75E58ACC77F090556B57AF43C564C78AEA75FE25D15`:
  seven failures disappear relative to full13 and no new identity appears.
  The connected raw-pointer index producer now has bounded evidence: original
  borrowed base/index views, all native index groups, real retained OWN/ARG
  operands and truthful native-only SOURCE_MACHINE capability, never fake ELEM.
  `_pointer_index_producer_08` is GREEN18 on source C4BD8508 (full identities
  in the journal). Its 1088-assertion full-method shape passes native and
  cleared-root runs; erasing the actual ARG index fails shape alone while
  keeping program result7. Compound actual-index boundaries, repeated groups,
  typed C99 elements and prior indexed-expression/callable regressions pass.
  Earlier producer01–07 failures/aborted runs remain recorded. Full15 completed
  RED175/1297 on those frozen bytes: three pointer/site/Array-shadow failures
  disappear, all five added fixtures pass, no former green regresses and no
  fixture is removed. The subsequent null-input `unit_ptr_grow` execution
  passes; its obsolete refusal expectation is replaced by the measured
  positive row. This does not exercise successful allocation or raw-pointer
  interpretation. Cast04 is GREEN19 with the complete 919-assertion nested
  cast/type/value oracle and four genuine source-erasure mutants. Full16 is
  RED174/1302 on source511F8AA6: only `unit_ptr_grow` changes FAIL to OK;
  the five new cast rows pass, no former green regresses, no row is removed,
  and the remaining translator diagnostics are unchanged. The next bounded
  metadata-selection preparation is RED2/16: all three new LAST/explicit
  reference-contract witnesses pass; the two failures are unchanged
  method-local Structure-constructor debts. Full17 completes RED174/1305:
  the three added reference-contract rows pass; no existing outcome or
  failure detail changes. The next bounded source-trailer slice is GREEN15:
  original namespace return is shared by CHECK, graph construction and native
  emission; actual namespace interpretation and source-erasure mutants pass.
  Full18 completes RED174/1310 on those trailer bytes: all five new rows
  pass; no existing outcome or failure detail changes. Later metadata/physical
  resolver preparation is a separate RED11/56 focused snapshot: the eleven
  old selected failures are unchanged, four new dormant/order-mutant controls
  pass, and35 overlapping emitted L1 files are byte-identical to full18.
  Full19 on those preparation bytes completes RED174/1314: four new controls
  pass, shared outcomes/details do not change; one already-failing nested
  diagnostic becomes unlocated. The subsequent original-root namespace
  source-layout cutover is implemented but not accepted: cutover04 is RED7/32,
  all seven new namespace rows pass. Five old producer refusals and two real
  merge runtime regressions remain. The merge pair cannot be waived as old
  oracle expectations; full interface reception must ignore source applications
  without ignoring missing real fields. The subsequent shared interface adapter
  repairs both merge rows: cutover06 is GREEN31, kernel recheck GREEN290 with107
  executed selftests (67 runtime-implements assertions, including missing and
  nested-field negatives). The explicit Consumer predicate stays unchanged.
  The earlier five method-construction rows use legacy implicit-construction
  setup and remain K03 migration debt; do not restore that obsolete rule.
  Fresh L3 passes11 suites and4 budget units. Full20 completed RED252/1321:
  seven added rows pass; one old failure resolves;79 shared green rows regress.
  These include real constructor/capture defects and stale physical-slot
  oracles, not a permission to waive the full gate. The later constructor
  identity/capture projection repair is bounded cutover09 RED11/96; the four
  capture regressions pass, but copy construction order, legacy setup and
  Array-path witnesses still require work. Exact frozen hashes and all scopes
  are in the connected layout evidence; no full current-byte green is claimed.
  The later cutover10 is RED10/99: the shared structural-path classifier now
  leaves `values[0]` to pointer indexing, restoring the formal-shadow row;
  three additional raw-pointer controls pass, with no shared green regression.
  Valid explicit copy is independently GREEN10; legacy implicit-copy rows
  remain migration debt, not a reason to restore the rejected rule.
  Full21 then completes RED182/1324 on the same B54A source:72 shared failures
  recover relative to full20, no shared green regresses, no target is removed
  and remaining shared failure details do not change. Three added targets
  are the passing actual-copy witness and both still-refused Array stores.
  The later field-contract join is a separate slice, not covered by full21.
  Its original Array STORE and read witnesses subsequently pass through one
  declaration-derived descriptor place shared by CHECK/native/walker.
  `critical_graph_array_place_08` is GREEN16 on source9589D74D:
  original witnesses108 checks each, selector witness44 native/48 cleared
  method/root checks, exact ELEM/ELEMPUT operand shapes, and one isolated
  index-erasure mutant with unchanged exit7. This is a bounded one-descriptor
  index route, not closure of all nested Array/rectangular/formal producers
  or old fixed-path consumers. Full22 completes RED188/1329: two old failures
  recover, five added rows pass, eight shared rows regress. Normative triage
  must distinguish obsolete witnesses from missing shared producers, not
  waive either. The subsequent resource/diagnostic slice is focused14
  GREEN20 on B7AFC2FB; full23 completes RED185/1329 on those frozen bytes.
  Four diagnostic/bounds rows recover; the sole new failure is the obsolete
  lazy Array-load spelling oracle, not an observed unguarded load.
  Connected remaining work: preserve ordinary descriptor-reference element
  contracts through nested Array paths (without depth/literal-only bans);
  migrate obsolete implicit-copy fixtures to explicit merge; recognize valid
  C99 integer bases in the shared literal producer, never in an index-specific
  decoder. The counted text-view allocation residue has a separate
  [ownership repair](steps/defects.md#compiler-text-view-ownership) in work;
  successful source retention is not a heap-cleanup certificate.
  The subsequent Text-ownership slices are GREEN41 on source865F7E6E and
  GREEN41 on source3B903EC6, with an additional GREEN11 until/trailer gate
  on3B903EC6. Exact pointer tracking on the latter source frees all2296
  counted baseline allocations and all1453 counted allocations when the
  second retained head-cache allocation fails. This is bounded compiler
  ownership evidence, not a certificate for uncounted P0/CRT storage.
  Full24 completes RED199/1329 on3B903EC6: the lazy-load oracle recovers,
  but15 exact unknown-name diagnostics regress; the184 old failure details
  are unchanged. The dynamic table now owns its Text view while borrowing
  original source bytes, preserving source-occurrence identity rather than
  copying those bytes. The foreign interner still owns independent copies.
  Provenance08 is GREEN64 on6E4E0FD8 and recovers all15 exact locations.
  Full25 completes RED184/1329 on that frozen source: all15 exact locations
  recover, the184 remaining failure details are unchanged, and no target is
  added, removed or newly regressed relative to full24. This is not release.
  Fresh exact traces on frozen6E4E0FD8 independently repeat zero outstanding
  counted addresses:2296/2296 baseline and1453/1453 on the later cache
  allocation failure. The older3B903EC6 certificate is not silently
  transferred to these later bytes; uncounted P0/CRT remains outside scope.
  [Ownership mechanisms and hashes](steps/critical-graph-namespace-source-layout-20261003.md#compiler-ownership-evidence).
  [Exact scope and hashes](steps/critical-graph-namespace-source-layout-20261003.md#array-place-evidence).
  Neither focused green nor full red releases either ticket.
  Earlier runtime recheck of the pre-cutover staged bytes is GREEN290 with107 executed
  selftests; L3 passes11 suites and4 budget units. The connected namespace
  layout journal records those completed bounded source-order/constructor/
  schema/trailer slices separately from the
  [next nested-source cut](steps/critical-graph-namespace-source-layout-20261003.md#nested-source-next):
  preserve original nested INIT occurrences and actual parent-instance/EXEC
  projection; not a guard-only fix. The bounded implementation now passes
  `critical_graph_nested_source_04` GREEN102 on source85E54097: nested
  original definitions are retained whether called or dormant, an erased
  inner INIT fails shape without changing exit7, and child invocation uses
  the executing parent's own slot. The child `node` witness changes its
  lexical parent's tag while preserving the same-named root value; both
  native and genuinely cleared procedures are tested. Bare own Array access
  is retained. This does not yet certify a copied parent, repeated nested
  sibling identities, local/qualified/synthetic producers or full acceptance.
  The subsequent builder-observer repair passes27 pure mutation/equivalence
  controls. Focused05 is RED2/106: all previous102 rows and both added
  depth-three repeated-sibling rows pass, while invoking the explicit merge
  result is refused before output. That does not prove copied-child routing
  wrong; the required copied-parent language call remains unimplemented.
  Full26 completes RED188/1343 on frozen85E54097: all184 old failure details
  are unchanged; two old strict observers omit the now-retained INIT, and
  two new copy-call rows refuse before runtime. The observer repair now
  requires the exact declaration/INIT operand order, source facet and copied
  parents; eight init/body/facet mutations fail shape with unchanged exit7.
  A DBED8A61 trial passes focused06 GREEN106 and focused07 GREEN116, but its
  immutable merge-source origin can become stale after reception/rebinding;
  that extension is withdrawn, not released or treated as closure. Focused08
  RED2/116 on E7F4BC2E retains the two honest positive copy-call refusals.
  Current070B6123 shares the receiver output-place projection across prepass,
  CHECK, native take and walker take; focused09 is RED5/124 (the same two
  copy rows plus three additionally selected old failures). Full27 completes
  RED189/1351 on frozen070B6123: the two strict INIT observers recover; three
  shared explicit-copy call rows now refuse before runtime;186 other failure
  details are unchanged. This is not a release.
  Later source9DD7E13A orders output bindings by exact source site, not table
  registration order. Binding05 is RED7/139; six added output/order fixtures
  and two actual-cell mutation controls pass in native/cleared-root modes.
  Expanded `critical_merge_root_output_01` is RED7/152 with the same seven
  failures; all13 additional merge controls pass. The one-operand runtime
  identity fix returns the actual copied root, preserving closure edges,
  aliases, native and names, without reparenting retained profile addresses.
  `critical_merge_root_fix_02` is ordinary GREEN291 with108 executed selftests;
  `l3_critical_merge_root_01` passes11 suites and four budget units. Three
  adverse runtime mutations are rejected. General multi-operand native/body
  selection, current callable origin and the full current-source gate remain
  open; no stable twin is promoted.
  Connected layout cut is saved on translator5CDEF70B: computed outputs now
  belong to child1 of their existing OWN/AT operand, not synthetic siblings.
  Focused compact02 is GREEN13, with width8 instead of10, distinct output
  operands/parents/borrow aliases/names and four shape mutations at exit7.
  Ordinary kernel compact02 is GREEN292 with109 executed selftests; the new
  runtime witness passes16 checks, including copied physical writes and
  exact immutable no-store. Kernel compact01 was RED1/292 due solely to a
  malformed new L1 test, not a runtime verdict. Compact03/04 RED10/154 expose
  three static merge-oracle gaps; compact05 RED7/154 recovers them through
  OWN2/FILL-alias observation. Later shared line-time/last-store observer
  refinements pass21 pure controls; two runtime mutations are rejected.
  L3 compact01 passes11 suites and four budget units. Full28 completes
  RED203/1361 on intermediate harness F9F42142; its15 newly failing rows
  recover in compact06 GREEN33 on7ADBFE22. Four historical-fixture migrations
  pass GREEN14 while preserving copy/shared-reference/permuted-field/call
  controls; no implicit merge is restored. Full29 is terminal RED184/1361 on
  observer821DF2F1:19 recoveries and no new failures against full28. Later45
  setup migrations first give RED11/57; common own/body/schema path,
  registered-body ABI/receive planning and CHECK diagnostics repair seven
  failures. Three stale text pins become observable copy/recursion oracles.
  `critical_path_schema_03` is GREEN43 on source5A70F7CB/harness8A013A1D.
  A full current-source green and L3 rerun remain required. No stable promotion.
  Keep distinct output occurrences and shared working-place identity, copy
  isolation, explicit typed targets and source-name publication. A new pointer
  cell or hidden companion graph must not replace the ordinary descriptor edge.
  [Runtime identity evidence](steps/critical-graph-namespace-source-layout-20261003.md#merge-root-integrity)
  and [compact-output boundary](steps/critical-graph-namespace-source-layout-20261003.md#compact-output-place).
  Implement the common actual-call input formation/admission boundary for
  copied/received/current held callables: exact visible place, current target
  evaluated once, receiving interface plus selected candidate's complete
  ordered inputs/defaults/dynamic requirements, caller activation and lexical
  fallback, actual native-word dispatch or walk. Mandatory interprocedural
  constructor-origin replay is not a language prerequisite and is no longer
  the required implementation design. Static constructor evidence must not
  substitute a prototype after replacement. No new METHOD/sig record, Lmx
  member, native registry, atom metadata or hidden companion graph.
  Complete the foreign nested-namespace actual owner-root projection separately
  from its inside-owner GraphField suffix. [Connected interfaces, witnesses and evidence](steps/critical-graph-namespace-source-layout-20261003.md#current-value-call-origin).
  [Latest evidence and connected next slices](steps/critical-graph-namespace-source-layout-20261003.md#path-schema-closure):
  retain a local definition at its exact GraphField, run the complete body
  through COUNT/PLACE/FILL and retire its fields-only constructor, not its
  refusal guard alone. Native/walker NODE needs one proved lexical owner,
  scope and GraphPlace stop. Capture schema, stable required-model instance
  and complete physical place must flow together; never flatten child1
  captures or reload a later factory result. Primitive-only MAD copies and
  all-host-formal reconstructed roots are not accepted graph-copy evidence.
  Saved r40/r50, two-holder and direct/copy mutation tests must discriminate
  replacement, collision and sharing. The following pointer stage must
  separate held value from address and close real C pointer-cell storage,
  native/walker depth consumption, copy/GC and raw C boundaries together.
  A cast or a new synchronized shadow cell is not a repair.
  [Full30 delta and local source producer](steps/critical-graph-namespace-source-layout-20261003.md#full30-local-source-next):
  RED138/1364,47 common recoveries plus three new positives; one root/tail
  diagnostic regression restored by shared root resolution. Finish exact local
  registration before sizing passes, dependency-ordered source shells and
  source-field attachment, then retire reached-declaration cloning. Dormant S
  persists; its literal initializer runs only when S is explicitly executed.
  [Measured whole-local-source cut](steps/critical-graph-namespace-source-layout-20261003.md#local-source-producer-measured):
  focused12 GREEN24, exact local registration and ordinary source-body
  COUNT/PLACE/FILL now cover original/T7 roots; reached-declaration cloning
  is removed. Local freshness witness measures99. Native/actually walked
  local source and one-formal callable-field twins pass; nullary held call
  stays an open positive, not an expected refusal. Exact initializer/copy/
  merge oracles now retain source operations. Run14 RED2/23 exposes local
  explicit-copy schema phase order; the common registration/reference-before-
  merge correction is measured in run18 GREEN19, with independent original/
  copied callable counters1/1/2/2 and genuine native/walker selection.
  [Full31 and local source contexts](steps/critical-graph-namespace-source-layout-20261003.md#full31-source-context):
  RED135/1380,15 common recoveries and11 new discrepancies, no removed rows;
  15 of16 added controls pass. The subsequent exact-source callable boundary
  and late binding pass make all four new local shadow/named-actual/hosted-merge
  native/walker controls pass; context02 remains RED11/22 on the same11
  discrepancies. [Later canonical-cell/admission scope](steps/critical-graph-namespace-source-layout-20261003.md#canonical-cell-opaque-admission)
  is context10 GREEN24/24: borrowed UNTIL declarations reuse their real cell,
  explicit copies have independent state, opaque casts/returns/formals retain
  possible source facts, and every receiving instruction prepares its maps.
  Indirect and caught failed admission preserve the target; UNKNOWN is not
  mislabeled INVALID or promoted to YES. ORDINAL and LAST remain distinct.
  Kernel292/109 selftests and L3 eleven suites/four budgets are green; two
  admit-status mutants fail. Full32 on later identity-request cleanup is
  RED130/1395: all1380 former targets remain, seven recover and no former
  green regresses;13 of15 new targets pass. The two new copied-Structure
  call positives remain failures. Required copied-Structure R() and
  nullary held calls are still open positive failures. Synthetic UNTIL/local
  owner projection, compiler numeric caps and pointer storage are not closed.
  Next close original UNTIL ownership,
  exact call/declaration classification, actual signature/argument formation and capture closure;
  then rerun the full frozen-source harness. No pointer fix or release is claimed.
  G1 additionally requires non-destructive named-actual projection, distinction
  of written versus inferred signature inputs, full comment retention and a
  genuine graph-side canonical decoder. Existing source cells need no new
  name/leaf metadata; correct execution alone cannot recover erased source.
  Full11 remains RED history (45/1266), as does full10 (91/1266). Full11 includes the shared predef
  receiver correction and repaired source/header assertions. Its ELSE-head mutant
  detects graph loss with unchanged execution; `unit_eternal_shape` runs 33
  checks successfully without implicit launch/membership fields. The independent
  L3 gate runs all 11 suites and four type-budget probes successfully. Full09
  remains earlier RED evidence (81/1263), not the latest verdict.
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

Historical inherited slice of this ticket (2026-10-02), not current topology
instructions. The observations below preserve their original run boundaries;
later COUNT/PLACE/FILL and canonical-cell evidence above supersedes sibling
shells, old slot pins and reached-declaration cloning. Do not reconstruct those
old layouts in the current implementation:
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
## 0. Historical starting snapshot and what must not be called complete

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

The October1 released source checkpoint was `8359a59`: focused and restored runs 48/48;
full generated run 1110 targets, 1062 OK, the exact same 48 failures; kernel
286/286; L3 11 suites/295 checks plus four budget controls. Ten new generated
rows pass, with no regressions. This was the starting code snapshot for the
original v2 handoff, not the current critical-graph WIP or completion of the
clean-kernel dependencies below. The current handoff is identified at the top
of this file; retain the frozen older counts as history, not a current verdict.

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

The October1 released merge slice removed the phantom global result namespace for its
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
- Support `b: merge: A C`, `b: merge(A C)` and equivalent explicit Frame
  forms, including merge in ordinary receiving expressions and return,
  under the general receiver mechanism. Do not gather operands from an atom
  `merge` followed by neighboring fields. A destination name is not a first
  operand, and a `return` receiver is not an
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

The October1 diagnostic “a call of a named Structure with an argument is not
built yet” was stale after Q59. The current shared `l2_struct_arity_error`
already checks the resolved formal contract and diagnoses excess arguments;
do not reopen that diagnostic migration or implement invented arguments.
This does not close execution of a copied/held nullary Structure or its actual
hidden-input preparation: the two positive copy-call refusals remain OPEN.

<a id="explicit-receiver-frames"></a>
### K03-EXPLICIT-RECEIVER-FRAMES — Remove implicit receiver-word operand grouping

Status: **OPEN, mandatory before G5/self-build**. The author confirmed that
the old `x: merge Y` spelling is a typo and its implementation is a shim to
remove, not a language exception. This stage follows the independent
OWN-TYPE-CODE-BANDS checkpoint already being verified. Keep one writer/build.
Authority: [the author's exact clarification](LMX_blog/2026-10-06.md#explicit-receiver-frames)
and the [general grammar rule](docs/LMX_grammar.en.md#no-inference).

1. Census the actual semantic dependency, not only matching text. Replay the
   frozen `opus_full_34` translation corpus with the receiver-word atomic
   collectors removed in an isolated translator. Record every changed row,
   source location, old classification, intended explicit Frame, and native/
   walked twin. The preliminary text census is 260 fixtures, mostly
   `x: merge Y`; do not treat that as a verified final count. Inventory other
   receiver words through their common role, not an implementation allowlist.
   The subsequent writer-reported classifier replay changes 264 of 1980
   recorded translations, 231 from accepted to refused. Translation runs
   are not distinct fixture files; retain the exact corpus/hash/partition
   artifacts and reconcile the counts in the migration manifest.
   Classify the actual enclosing receiver and argument roles before deciding
   that a fixture depends on this defect. The actual Frame supplies the
   head/tail boundary; general resolution selects the head's role and its
   contract determines the arguments. A receiver is a translator instruction,
   a callable call is a runtime action; they share syntax, not a role.
   An argument name does not invent another application. Thus
   `catch: merge ()` and `fn: test ()` already are ordinary applications of
   their respective heads, not missing nested calls. These are consequences
   of the common rule, not special protected spellings or an exception list.
   Do not blindly insert punctuation after matching receiver words.
2. Remove the atomic operand-collecting routes in `l2_receiver_value`,
   `l2_fields_one_value`, `l2_tail_is_structure`, and any remaining emitter,
   schema, construction, or walker route that reconstructs a call from such
   atoms. `l2_receiver_word` must not decide that neighboring atoms belong to
   a call. Retain any legitimate reserved-name classification needed by the
   general resolver; delete dead helpers after removing their callers.
   Delete `l2_merge_atom_settle` entirely and the atomic fallback from
   `l2_merge_frame` that calls it. Delete the reconstruction subsystem itself:
   do not keep it behind a colon check, rename it, insert punctuation before
   passing to it, or feed it synthetic Frames as a compatibility shim.
   Enumerate every removed branch/helper and verify that surviving callers
   consume the common path. See [RECEIVER-ATOM-CRUTCH](steps/defects.md#receiver-atom-crutch).
3. Use the existing explicit Frame route for all receiver applications:
   `x: merge: Y`, `x: merge(Y)`, arbitrary argument counts and equivalent
   completed vertical forms. Preserve operand order, one evaluation each,
   result receipt, admission, source graph, and native/walker parity.
   Do not change the parser to infer Frames or add a merge-specific parser.
   Consume the actual P0 Frame; no later local parser may recreate a call
   by scanning receiver words or regrouping an atomic expression tail.
4. Migrate every classified fixture and its walked twin explicitly. Preserve
   the behavioral assertion, ownership/reference-depth setup, and failure
   oracle; do not obtain green by deleting rows, weakening checks, or
   reinterpreting old gates as proof of the corrected source bytes. Keep a
   named old-to-new migration manifest and count its exact coverage.
5. Add positive colon/compact/vertical controls and prefix non-application
   witnesses for one and several operands. Test root, method, nested and
   anonymous/receiving positions, including return. A prefix sequence must
   not execute merge or create a merge result. Apply ordinary semantic rules
   to the actual enclosing head: an unknown head may define a dormant body;
   do not impose a special global parse refusal for the word `merge`.
   Preserve bare nullary callable evaluation without consuming later fields.
   Verify the same head/tail contract for arbitrary receiver arguments and
   nonexecuting descriptions across names, nesting and source positions.
   `catch: merge ()` and `fn: test ()` can witness that universal mechanism;
   they do not define exemptions. No name allowlist or protected-case branch
   may preserve them while breaking other instances of the same rule.
6. Mutate a removed atomic collector back in: at least one non-application
   witness and its walked twin must fail. Replay the frozen corpus, explain
   every changed row, and run focused migrated/control rows in native and
   genuinely walked modes. Then run the normal full L2, kernel, L3, generated
   and docs gates, plus scoped `git diff --check`, on the checkpoint bytes.
   The exact acceptance commands/artifact paths follow the existing gate
   protocol in §1 and must be recorded in the writer's stage ledger.
7. Commit/push the exact named source/test/harness/document paths. Release
   this stage only after its own acceptance is met; unresolved baseline
   failures remain named debts, and do not constitute a green G5 checkpoint.

Acceptance: no receiver-word operand collector, no name-specific fallback;
all classified prefix-dependent fixtures migrated with unchanged intended
behavior; explicit Frame forms agree; non-application and nullary controls
survive both engines; the reintroduced-collector mutant is caught; exact
corpus comparison and normal gates are recorded. No downstream clean-kernel
or self-build checkpoint may retain this shim.

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
full-gate failures must each be classified and resolved against current norms
(latest frozen full32: RED130/1395, not the historical48);
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

# Maintained L3/L2 source package

Current owner (2026-11-09 01:25Z): Opus, the sole writer/build/docs, by Codex's handoff
(CODEX-OPUS-TAKE-WRITER-20261109T0104Z-01); Codex is the instructor and reviewer, Fable is stopped.
Owner on 2026-11-08 (history): Codex, the sole writer/build/docs; Fable and Opus were stopped. The clean-graph migration
uses the existing language-owned build route. The current graph06/tool09/rt05 slice passes 24 interp/native/forced
cases and 10 mutation checks, including a second traversal after a computed declaration is published. Data writes
preserve native; shared code changes clear the affected entries before publication. This is a flat int/reference
slice, not completion of the kernel, Message/mail roots, or §§8/8a. Exact commands, hashes and limits are in
[Codex's continuation](../steps/witnesses/fix309-20261108/codex-continuation.md); the older slice descriptions below
are historical. The current input manifest has 342 entries.

The method slice graph10/tool11/rt07 passed 24 execution checks and 18 graph-mutation checks.
Point/take, reordered candidate fields, used-field-only candidates, int defaults and nested calls execute in
interpreter/native/forced modes. Methods keep explicit args/return/var/body Lmx parts; each call owns temporary
argument places. This still supports a single return expression, int results and empty var, not the full call model.
[Commands, receipts and remaining work](../steps/witnesses/clean-call-20261108/notes.md).
graph-check accepts optional EXPECTED-EXIT COUNT INTERPRETER-ANSWER after EXPECTED: the final argument checks the
interpreter's exact diagnostic status (0..6); native/forced process success remains 0 or1.

The graph11/tool11/rt08 tuple normalizes supported expressions to nested ordinary Lmx during construction.
Neither execution consumer parses operator precedence. Compound arguments, nested paths and both a(5)/a:5 call forms
pass with the same results: 36 execution cases and 18 mutation checks. General bodies/local places and the remaining
operators, primitives and call forms are still open. [Evidence](../steps/witnesses/clean-expr-20261108/notes.md).

The current graph12/tool11/rt09 tuple preserves the internal pointer and slot on every assignment. The language place
remains `int`, including expression reads and argument admission. Direct initialized storage and indirect storage
without an initializer remain distinct, including mandatory/default signature fields. 21 execution checks and
19 mutation checks passed. The former pre-write refusal was Codex's superseded interpretation; current checks take an
address without reading unpromised bytes. The diagnostic dump is not a full state codec.
[Evidence and remaining work](../steps/witnesses/stable-indirection-20261108/notes.md).

The graph15/tool12/rt12 tuple executes sequential fn bodies with explicit int var. Temporary activation working
values publish only dirty fields, after argument evaluation before calls and on return/error. Native computes
its body using the same working-place/publication boundary; it does not call an interpreter body.
Both a(5)/a:5 invoke a exactly once, formal int writes keep the caller's value, computed var initializers run once,
and failed execution publishes completed own writes. 24 execution checks and19 graph-mutation checks passed.
[Sources, tuple, receipts and limits](../steps/witnesses/working-var-20261108/notes.md).

The current graph18/tool13/rt15 tuple adds body-declared int places to var during construction. All own fields of an
auto-filled var are visible from the body's first line; body initializers still run at their statements. Dynamic int
inputs snapshot the nearest activation before var executes; their writes and local references do not change the source.
Nested methods impose no transitive input requirements. The translator collects method addresses once from the completed
graph, reuses that temporary list for native emission/installation and discards it; no constructor inventory is retained.
30 execution checks and19 graph-mutation checks passed. Control flow, remaining place types, full admission and general
call:code data were still open at that point. [Sources, receipts and limits](../steps/witnesses/body-inputs-20261108/notes.md).

The current graph21/tool15/rt20 slice uses the shared activation map for ordinary Structures and fn with int places. Explicit data
is matched by canonical names, never extended, and receives dirty values at publication. Shorthand selects var;
code=data follows the same dispatch and write path. Ordinary native bodies compute their operations directly.
36 execution checks and19 graph-mutation checks passed. This is still a partial N4 migration; remaining types,
control flow and full admission/conversion are open.
[Current tuple, results and limits](../steps/witnesses/code-data-20261108/notes.md).

The graph24/tool16/rt22 slice implements if/else, while, for and nearest-loop break/continue/redo through the clean graph.
Inline bodies keep the same activation; construction collects their int fields into the shared var, visible from the
first statement. Comparisons, ! and short-circuit &&/|| work in both consumers; native emits direct conditions and jumps.
27 execution checks and19 graph-mutation checks passed.
[Commands, source manifest, receipts and limits](../steps/witnesses/control-flow-20261108/notes.md).

The current graph28/tool17/rt23 adds until in anonymous bodies and named Structures, retaining own fields and var.
It uses ordinary Lmx [until, condition, body]; continue tests the condition, redo repeats the body without testing.
Native graph construction preserves shared cells through a temporary source-address map discarded by the translator.
33 execution checks and19 graph-mutation checks passed. Named transfers, cleanups, remaining types/admission and the
general graph-state codec were still open. [Evidence](../steps/witnesses/post-loop-20261108/notes.md).

The current graph34/tool19/rt26 executes reached finally registrations in reverse order on scope exit, including
return, nearest-loop transfers and supported errors. The return value is held before cleanup; own dirty fields are
published before activation-exit cleanup and again afterwards. A transfer or failure inside a cleanup does not rerun
it and does not omit outer cleanups. Native emits these paths directly; traversal state is not retained in the graph.
42 execution checks and19 graph-mutation checks passed. Named targets, throws/catch, stop/yield, other types and
the complete activation/codec/selfbuild migration remain open. [Current evidence](../steps/witnesses/finally-20261108/notes.md).

The current graph36/tool21/rt28 adds sub through the same clean-graph callable path: args/var/body, with no return
part. Root and nested calls, defaults, explicit code/data, dynamic inputs, fallthrough, bare return and finally use
the shared activation and publication rules. A sub used as a number is refused before argument effects.
42 execution checks, two result-refusal checks and19 graph-mutation checks passed.
[Sources, receipts and limits](../steps/witnesses/sub-calls-20261108/notes.md). This does not complete fm, other
primitive/result types, full admission, exceptions, graph-state operations or §§8/8a.

The current graph40/tool22/rt30 preserves := as ordinary Lmx and writes known int places: root, own/formal,
selected data and nested paths. Bare writes use working values; explicit paths write the graph without refreshing
the working snapshot. Unknown destinations fail before RHS effects. All30 execution and19 graph-mutation checks passed.
[Sources, receipts and limits](../steps/witnesses/known-assignment-20261108/notes.md). Other primitive/reference writes,
named := arguments, full admission and §§8/8a remain open.

The current graph41/tool23/rt31 (Opus, finishing Codex's WIP) supplies named arguments `a := v`: one temporary call
binder checks names, repeats, order and required formals against the selected callee's formal slots before any
argument effect, then evaluates the right operands in the written order and receives each at once; `a(5)` and `a: 5`
stay ordinary calls. All 45 graph fixtures pass interp/native/forced, mutation 11/11 and method-mutation 8/8.
[Sources, receipts and limits](../steps/witnesses/named-arguments-20261109/notes.md). Computed defaults, AXBY with user
conversions, q/z, merge35, other types and §§8/8a remain open.

The current graph42/tool24/rt32 gives the whole argument structure of one Structure: a single positional actual without
effects (a name or a path) whose direct fields name formals of the same kind, every other formal having its default, is
supplied by its fields, otherwise it is the ordinary first argument; one kernel function `lmx_graph_call_single` serves
the interpreter and native. q/z from `s` gives 15, `k(q := s)` 50; 48 graph-check runs × interp/native/forced,
mutation 11/11 and method-mutation 8/8 passed. [Sources, receipts and limits](../steps/witnesses/whole-arguments-20261109/notes.md).
`merge` in the clean graph (example 35), effectful Structure producers and two methods of one name remain open.

The current graph43/tool24/rt33 replaces the field/formal kind check by the common admission of the subset and makes an
empty Structure the empty field chain (a nullary or default-only call); the builder does not yet construct an empty
named Structure. 49 graph-check runs passed. [Sources, receipts and limits](../steps/witnesses/whole-empty-20261109/notes.md).

This is the selected repository source root for the existing language-owned
`manifest`, `stage-copy`, `rebuild`, and `bootstrap` route. Keep its relative
layout: `src/l2src/`, `tools/`, and `tests/`. In particular, the full suite's
`../tools/sha256.lm2` extra input is relative to `tests/`; moving that list to
`tests/l2/` without an explicit source change would break its resolution.

The selected package contains 264 inputs (66 source files, 34 tools and
164 tests). Slice303 (the operator `:=`, the author's decisions of 2026-11-07; fable_pc) makes `:=` one operator token of
P0 -- a Frame of its left and its right side flagged `LM_P0_FRAME_ASSIGN`, `a := 5` and `a:=5` one form -- that writes a
place already known through the general assignment path (a local, a formal, a field through a path, the conversion of the
reception, a reference place holding a method: `target := two` without a call of the bare right side, natively and in the
walker's program) and refuses an unknown left side at translation (`:= writes a place already known: its left side is not
one here`, in a method body and in a named Structure's body, no field defined; the places are the declared formals, a
visible own field, a slot, a method-level local and a nested method's host activation, not the hidden input the collection
makes of a free name for `x: v`); in a call's argument Structure `:=` supplies a named argument (`f(a := v)`: the binder
names a formal by that Frame only), while `f(a: 5)` and `f(a(5))` are the ordinary call of a visible callable `a` with a
positional result (NAMED-BINDING-BY-HEAD closed; the `table:` receiver's parts use the same binder in its `by_head` mode); a
`merge` operand written name first, `(a: int: 5)` and `a: int: 5`, is the typed field the declaration form `(int: a 5)` is.
Fixtures `assign_known`, `assign_unknown_refused`, `assign_in_structure_refused`, `assign_method_name_refused`,
`named_assign_actuals`, `named_assign_unknown_refused`, `named_assign_positional_after_refused`,
`merge_named_field_operand`; five fixtures that asserted the by-head binding moved to `:=`. The whole argument Structure
from one Structure (`mytest(merge(mytest\args; (a: int: 5)))`) is held: the author's decision of 2026-11-07 names the one
error case -- two fitting methods, one with the Structure as its arguments, the other with the full set of its fields --
and no special unfolding (CALL-WHOLE-ARGUMENTS-STRUCTURE), and Codex asked the author how those two methods are written;
303 left the kernel unchanged. The review of 303 added: an exact identifier before `:=` is the same operator in P0 (the
translator's own limit on exact identifiers as statement heads stays, "unsupported body", pinned with its colon control);
`:=` declares nothing in any shape -- `zz := int: 5` is refused in a method, at the root, in a Structure and as a merge
operand, while a known place takes the typed right side by the general admission. Slice304 (the `merge` operand `f\args`,
the author's example `merge(f\args; (a: int: 5))`; fable_pc) reads the args part of a callable as the Structure of its
formals -- one field per formal, in the formals' order, holding the formal's current default; a formal with no current
default holds no value (its slot stays empty, and the operand is admitted only when a later operand of the same merge
writes that field, else refused at the operand -- Codex's review of 304) -- by one kernel function of both executors
(`lmx_callable_args_value`; the walker's primitive `lmx_walk_args_value_map`, both exported from `lmx_walk_values`),
recognized by the common path resolution (the operand's last step is the `args` part of a method,
`lm_compiler_merge_args_callee`) and lowered as the fourth form of a `merge` operand (the result's fields are the typed
fields of the formals' declarations; natively the kernel call before the merge, in the walker's program a PRIM over the
callable's occurrence). `merge(tst\args; (a: int: 5))` reads `a` = 5 and `c` = 3; `merge(tst\args)` alone is refused
since Codex's review of 304 (no later operand writes the required `a`); `tst\args` is not written. Limits: a formal that
is not a number is refused at the operand (`a formal that is not a number is not lowered as a field of the args part
yet`); a path into the args part (`tst\args\c`) is not resolved. The call of the merge result as the whole argument
Structure stays held (above). Fixtures `merge_args_operand`, `merge_args_unfilled_refused`,
`merge_args_computed_default_refused`, `merge_args_model_formal_refused`. Slice305 (CALL-ARGUMENT-ORDER-AXBY, the author's
decision of 2026-11-07; fable_pc) makes the bound call check its names and form against the selected callable before any
actual is evaluated and receive each actual right after its evaluation: the kernel binder in three phases
(`lmx_call_bind_form`, `lmx_call_bind_receive`, `lmx_call_bind_finish`, exported in tools/build.lm2 in place of
`lmx_call_bind_actuals`), the walker's selected call restructured the same way (`lmx_walk_written_names`,
`lmx_walk_selected_form`, `lmx_walk_receive_written`), the native emitter of a bound call in the same three phases; the
fixture `bound_order_axby` (from the probe p301b): the effects run 1323, not 1233, a refusing receiver leaves the later
actual unevaluated, a name the selected callable lacks and a missing input refuse before `touch()` runs. This was the
numeric part of the author's rule; Slice306 (CALL-ENTRY-ADMISSION-ORDER, the rest of it; fable_pc) receives every other
actual by its formal right after its evaluation too: the kernel's `lmx_call_receive_formal` (one function of both executors)
receives a value at a Structure formal as the graph reference (a number or a foreign value is the implicit `convert`) and
admits it against the selected callable's own entry reception by its own record (`lmx_call_formal_reception` finds the
SET_ARG frame of the RECEPTION source in the callable's body; a graph without the model's fields is the implicit
`implements`), and a value that is no number at a number formal by `lmx_walk_value_receive` (the implicit `convert`); the
walker's call through the signature path -- every call of a fn or a sub, static and bound alike
(`lmx_walk_receive_written`) -- and the kernel binder of a native bound call (`lmx_call_bind_receive`) call it before the
next actual runs, and the callee's entry then finds the value admitted. The native emitter binds every call through a callable place by the kernel (the callee is what the place
holds) and no longer emits the declared signature's model admission for a bound call, which read the declared callee's
model off the selected occurrence (`l2_c\parent\parent` of another callable: a kernel INVALID at every bound call with a
Structure formal, native). The fixture `entry_admission_order`: a free name bound to a Shape, a Slim (no `y`) and a number
at `take (Point: p; int: q)`, at `Places\f` holding `g` positionally and by name, at `num_take (int: n; int: q)` and `Nums\f`,
and its address at `ptr_take (@@: pp Point; int: q)` and `Ptrs\f`, each followed by `touch()`: the Shape reads 29 with
`touch()` run once, the Slim is the implicit `implements` and the number the implicit `convert` with `touch()` not run,
in both executors (before: a walker INVALID for a number at a modelled formal of a static call, `touch()` run before the
entry's refusal). Slice307 (CALL-WHOLE-ARGUMENTS-STRUCTURE; the book's whole-arguments rule, the author's decisions of
2026-11-07 and 2026-11-08; fable_pc; two passes, the second after Codex's review): a call with one Structure argument does
not differ from a call with the chain of its fields. The binder marks one actual written by position that may evaluate to a
Structure -- a name, a path, a merge, a call -- as a candidate (`L2ApplicationActuals.whole` 2) and defers the check of the
omitted formals; CHECK decides on the static shape of the actual (`lm_compiler_whole_shape`) and the formals of the selected
callable (`lm_compiler_whole_fields`: every field names a formal of its kind's class, every other formal has a built
default): the fields are the arguments (`whole` 1), or the ordinary positional reading stands with the binder's refusal of a
missing formal; the Structure also fitting the first formal, a Structure formal, by the first part of implements with every
other formal defaulted, is not a question the rule asks: the direct fields that name the formals are the arguments by the
basic rule (the author, 2026-11-08: no search for arguments deeper in the Structure; `whole_direct_fields`: `k (Q: q; int: z 0)`
given `QZ (int: z 5; Q: q)` takes `q` and `z` from `QZ`, no default, 15, and `k(q := QZ)` is 50); the first pass's refusal of
that case as ambiguous and the second pass's hold were my own additions and are withdrawn; the author's case of two really applicable methods
stays unimplemented). A whole call binds in the kernel, in both executors: first the names and the form before the actual is
evaluated (`lmx_call_bind_whole_form`: the codes of the static fields' names against the args part of the callable selected
now and the defaults of the other formals, else the implicit `call` -- natively `l2_wn`/`l2_wfs` before the evaluation, the
walker's WHOLE operand `[whole, payload, names, name*, (formal, witness, occurrence)*]`; a callable held with other formal
names given the result of a producer with a counter is the `call` with the counter still 0, `early_form`), then the actual
evaluated once and the form against the value (`lmx_call_bind_whole`: every named cell a formal, every other formal its
current default), then each formal receives the field of its name as a written actual is received since slices 305-306 (a
number through the route of its type or the implicit `convert`, a graph by the formal's own entry reception; an omitted
formal its default). The merge written in the call itself, the author's canonical `mytest(merge(mytest\args; (a: int: 5)))`,
is 35 in both executors: the translation lifts a `merge` written as a call's actual (the call a statement, or the value of a
declaration, an assignment or a `return`) into a hidden declaration `l2_lift_<method>_<offset>: merge(...)` before the
statement, in the registration round of `lm_compiler_parse_unit` before the owns are collected and the calls bound
(`lm_compiler_merge_lift_walk`; the hidden declaration takes the host's span so that the own is visible from the call), and
from there it is a written `pack: merge(...)`; the operands of such a merge evaluate before the call's form is checked, as a
written `pack`'s do (a native statement's prologue reads the owns before its code, so the hidden declaration cannot be
deferred to the call site -- a bound of the record); a merge in a merge operand, deeper in an expression, in a control
statement or in the actual of a callable held under a bare name is not lifted (the former refusal). The applicability of the
single-argument reading and the admission of Structure fields go by the general projection of the requirements relative to
the Consumer (`lm_compiler_whole_applicable`: the uses of the input selected, the requirement's paths projected into the
candidate), kind-strict at the leaves as the ordinary admission and the executors' entry reception are (the probe
`whole_leaf_convert`: a candidate admitted by the conversion table stopped R0 at run time in both executors -- the table at
nested leaves is a shared remainder). The kernel reads the fields of a value as its named cells (the native layout of a
declared Structure keeps a step cell beside each place). The fixture `whole_arguments` (entry 7, both executors, both roots):
`pack` 35, the inline merge 35, `mytest(a := 5)` 35, `Args (c 4, a 6)` 46 and not written, `Only (a 9)` 39, a Structure field
at a Structure formal 10, a char field at an int formal through the program's receiver once 505, the callable place `Places\f`
10 and the implicit `call` for a callable of other names, `early_form` 28 with `Made\n` 0, the ordinary reading for
`take(Point)`, `take(p := Point)` and a Structure with extra fields. The export lists of the kernel in `tools/build.lm2` count
their names (`bld_kernel_l2`: lmx_implements 73, lmx_walk_values 176). Acceptance of the second pass (candidate a25): the probe p307n on the a25 tuple (tool170e `91da2e20…`, rt170f `b6a65587…`, fe170r `1ff71021…`): 7 rows, 42 PASS, 0 failures, native and forced, both roots; the whole maintained registry on a25 139 rows / 1102 checks / 0 failures; five mutants killed (the walker's and the native names-and-form check before the actual by the forced and the native run, exit 98; the lift and the field applicability in both directions by the translation of the fixtures); whole boot170b 678 s with 0 failures (74 PASS, smoke 0 failures; G0 = the stage's tool170e, the previous frontend the G2 of boot169a); checks 38/0 (rt170f the same bytes as the G2 runtime, fe170r exe-same as the G2 frontend; G2 tool `41fe7cbe…`); the G2 tool's self-test 0 failures; landing 9/0 (manifest `36930663…`, 264 inputs); docs render/verify 3/0; docs check 0 (the repeat docs307c-check after the normalization from the index of the 160 CRLF copies of receipts in the working copy on which the first run failed; the final index checked once more before the commit, receipts in P).
Acceptance of the first pass (ce01c206, candidate a11): the maintained registry 139 rows / 1102 checks / 0 failures, six
mutants killed, whole boot170a 677 s with 0 failures and smoke 9/0, checks 38/0, landing 264 inputs, docs check 0; Codex's
review (CODEX-FABLE-307-REVIEW-20261108094230Z-01) did not accept its closure and asked for the second pass. Slice308 (IDENTIFIER-CODES
in the translator; fable_pc) was STOPPED by the author's directive of 2026-11-08 (relayed by Codex; verbatim in
LMX_blog/2026-11-08.md) before landing: nothing of it is in this package; its candidate a15 is kept as WIP in
steps/witnesses/fix308-20261108 (the patch records/wip308-a15.patch, the receipts). The directive replaces the numeric-codes
direction by a kernel implementation specification first (docs/kernel-implementation.ru.md, .en.md) and a rebuild after it.
The stopped candidate moved the translator's internal comparisons to codes: `LmP0Text`
carries the code of its spelling, the one text boundary is `lm_p0_text_code` (P0 gives a code to every atom and head but a
number, a string and an empty text; an exact identifier in backticks gets the code of its value -- the grammar's exact
identifiers), every text the frontend builds gets its code and a copy carries its source's code (`lm_compiler_text_clone`;
the first candidates computed the copy's code before its bytes were written: the code 0 of NUL bytes on a fresh heap, a
code of garbage on a reused one, found with gdb on a debug twin); `lm_compiler_text_same` compares codes and a spelling
without a code at a comparison is an invariant of the translator (`l2trans: invariant: ...`, exit 3, no byte fallback), the
~900 literal comparisons go through the word table `l2_words` (`LM_W_*`, 129 words filled once through `lmx_ids_code`, the
kernel's 20 first), the implicit throws are the walker's numbers, path segments are read with their codes at the split
(`lm_compiler_seg_text`/`seg_same`/`seg_word`), primitive codes are compared as codes (`lm_compiler_prim_same`, `prim_code`),
the `primitive.description`/`primitive.convert` tables are read by the codes of their cells (`lm_compiler_tbx_code`), the
signature intern stores the codes of the formal and hidden-input names (`l2_it_nc`, `l2_it_hc`), the CLI's machines and
providers are matched by codes; `lmx_ids` is a part of the l2trans and l1trans builds (its own instance per translator
process). The L1 translator and the RESULT tests remain the rest of the transition. Slice302 (an intermediate result of IDENTIFIER-CODES, the author's directive of 2026-11-07; begun by Opus,
finished by fable_pc) represents every identifier the kernel, the walker and an emitted unit execute with by the code of
its spelling: the process service `lmx_ids` (a new machine module, `src/l2src/lmx_ids.lm2`) holds the one pair of
informational tables code -> name and name -> code with one counter, the words of the language get the first codes in the
order of the `LMX_ID_*` constants (the implicit throws 1..7 are `LMX_WALK_NAME_*`); a `LmxSourceName` row binds an
occurrence's address to a code, not to text; an emitted unit turns its spellings into codes once at its load
(`l2_ids_load`, the first statement of its builder, its table `l2_ids`) and from then on writes only `l2_ids[K]` -- the
registration of occurrence names, the place tables `[m, SIZE_MAX, (code, type)...]` without token text, the activation
bindings, the names `l2_bn` of the binder, the selectors of OF/PUT_OF and of the native field place (code, selected
occurrence, prefix, read from the written step at translation) and the throw keys; the kernel and the walker compare codes
(`receiving_head_is` against the constants, `receiving_reference_head` by the mark a reference head's code was given with,
`lmx_implements_same_name`, the activation resolver), a copy carries the code without reading a spelling, the driver and
the observed walk print through `lmx_ids_name`, the recipe's `l1_binds_native` knows a method's name in an emitted L1 by
its code. The fixture `copy_name_codes` kills the mutant that copied an occurrence without its code (the nine earlier rows
over copies did not: a copied data field is still found by its root-head row). The translator's internal comparisons (P0,
scopes, resolve, signature interning, throw keys), the L1 translator, AXBY and the RESULT tests (one spelling in several
units and arenas, shadowing, a copy into another arena without text) remain the rest of the transition; no RESULT is
claimed. Slice301 receives a typed number written by name at a formal of another number type of the callable a call
selected when it ran by the program's direct receiver of that pair: the call site resolves the routes as a static
reception in that caller resolves them (natively arrays handed to `lmx_call_bind_actuals`, walked pairs after the
payload of the NAMED operand), and the one kernel reception of both binders, `lmx_walk_receive_selected`, reads only the
route of the selected formal's type and calls the receiver before the body -- its refusal, and a pair without a route,
is the implicit `convert`. The author decided on 2026-11-07 that a call's names and form are checked before its arguments
and each argument is received at once (AXBY); the bound call does that for the form and the numbers since slice305
(CALL-ARGUMENT-ORDER-AXBY in part; the admission of every other value right after its actual is the required rest,
CALL-ENTRY-ADMISSION-ORDER, for the static and the bound call alike), and since slice302 it finds the selected
formal by the code of the written name (IDENTIFIER-CODES, the rest of the transition open); slice301 is an intermediate
result and claims no named call of the required architecture. Slice300 takes a pair the conversion table has no row of by the same unavailable route, and a single-field
repeat (`int: z 5; char: z`) checks its place where it is reached in both executors: the kernel's reception of a zero of
the written type at the place's type -- an unavailable route is the implicit `convert`, an available receiver passes
without being called, the place is never written; Codex's review of 299 narrowed slice299's claim (its single-field
repeat passed unconditionally). Slice299 receives a number of another type whose conversion row names a receiver the program does not
define by an unavailable route: in language code the translation admits it and the reached reception is the implicit
`convert` in both executors (natively the source is packed and received by the kernel's `lmx_walk_value_receive`; the
walker evaluates the value as its own type) -- a write, an argument, a result, a declaration, an L3 INDEX index, a path
write and a repeat leave the place's old value, a reception in a branch that does not run raises nothing, and a method
with such a reception is on the status channel. A machine function keeps the static refusal. The refused rows of slices
289 and 297 became `index_numeric_unavailable` and `var_own_repeat_unavailable`; `numeric_unavailable_route` is new.
Slice298 reads the named actuals of a path call of the unit's own fn place, `node\f0(x: 3; y: 4)`, as
labels: the collection of hidden inputs resolves a call's head with its method current, as the binding pass does, so the
labels no longer become hidden inputs of the caller (R0 had stopped in both executors). Slice297 carries a literal a call writes by name contextual to the formal of its name in the callable
the call selects, in both executors: that formal receives it, and a contextual literal outside a number place's type
is the implicit `convert` (300 at a char formal), never a silent truncation; a negated literal is negated in its C99
type (no U: an int; U: its unsigned type). A repeated declaration of another number type gives its candidate, formed
by the written receiver, to the known place by the ordinary numeric reception (the conversion table's receiver, else
the ordinary refusal of a conversion without its receiver); a single-field repeat checks the place and writes
nothing, and no longer gets a slot. Repeats of references, Structures and arrays keep the refusal
(REPEATED-DECL-OTHER-KINDS); a typed value bound by name to a selected formal of another type is still the implicit
`convert` (CALLABLE-PLACE-TYPED-RECEPTION).

Slice296 lets a head that no formal, no visible outer value and no established free input binds
define a named Structure with a name as its written content too (`x: j`) -- in a method, at the unit's and a
part's root and inside a named Structure -- as a literal or an expression already did; the refusal `an unknown
head needs a Structure body` was a limit, and the last "is the head a Structure" question of a declaration now
goes through slice 290's guard. `return: x` of such a Structure from an int fn is refused by the general rule.

Slice295 gives a declaration that an inline statement of a fn or sub body holds -- in an `if`, an
`else`, a `while`, a `for`, an anonymous body, at any depth -- the activation's one place of its name, in the
method's var: the depth shadows nothing, another declaration of the name is that place again (another written
type is refused where it is written), and under explicit data the place is a requirement the call's admission
checks before the body. A catch keeps its own host. Machine functions, the file's root and `fm` keep their
nested hosts for now (MACHINE-NO-SHADOW, ROOT-FILE-INLINE-DATA, VAR-OWN-NESTED-AND-REFERENCE).

Slice294 binds what a call writes to the formals of the callable it selected before its
actuals: a positional actual the formal of its ordinal, a named one the formal of its own name -- never the
formal the place's or callable formal's declared signature puts there -- and a formal no written actual binds
takes the selected callable's default; a name the selected callable has no formal of is the call's implicit
`call`. One kernel binder serves the walker's frame and native calls (`lmx_callable_bind_prefix`, reached by
`lmx_call_bind_actuals`, exported in tools/build.lm2, so a new G0); a formal the call omits has no frame slot.

Slice293 takes a formal's written default when a call gives no argument for it: a literal of
the formal's own primitive type is its current default, a cell in its args entry, and a call takes the
default of the callable it selected -- by position or by name, through a callable place, by the `call`
receiver or through a callable formal; a supplied argument (zero too) is taken as before and never becomes
the default, and a caller's same-named value is no argument. One kernel function reads it for both
executors (`lmx_call_formal_default`, exported in tools/build.lm2, so a new G0). A default written in
another form is not built.

Slice292 lays the own fields a `fn` or `sub` body declares out in its var part, one place
each after the written var's fields; their statements and initializers stay in the body and run when
reached, and a read before the declaration stays a hidden input (`m\var\a` reads and writes the place,
`m\body\a` is refused). Native code reaches a var place through the selected data, as the walker does,
so `call: m D` writes D's fields.

Slice291 passes every word of a list line to its command (slice290 split a line into nine
words and dropped the rest without a refusal), and the full list `tests/full-suite.tsv` holds every
landed fixture through slice290: 101 rows.

Slice290 makes a field of a program part's root the lexical source of a hidden input in both
executors: a method of the part called from outside the part takes its free name from the dynamic input
first, then from the part root's field. Native code types the absent input's place by the selected
default, as the walker's ARG does; the walker holds at the entry also the source of an input the body only
writes, as native code does. A bare write changes only the activation's value; `node\x` writes the root's
field. A head with no binding and no earlier read written with a name tail (`h: v`) is now refused at the
tail instead of overflowing the translator's stack. The tool runs a list of its own commands: `checks LIST`
runs every line, `steps LIST` ends at the first failure; each line's output is followed by
`CHECK <exit> <words>`, the list by `CHECKS <lines> lines, <failed> failed`.

Slice289 receives an index of another numeric type at that L3 INDEX by the ordinary numeric
reception: the index's type does not choose the route, CHECK admits the reception as at an Array level,
and native and walked code call the program's converter (`lm_stg_convert_int_size_t` for an `int`), whose
refusal is the implicit `convert` before the place is selected; a program without it is refused at
translation. No program here defines converters: the tools' methods are a machine library (genuine L2),
and the tool parts that L3 programs use (`tools/text.lm2` in the self-test's child, `tools/sha256.lm2` in
`tests/sha/sha256_vectors.lm2`) index by `size_t`.

Slice288 checks the same L3 INDEX in native code: the place is selected by
`lmx_walk_value_index_place` over the pointer's current value, the index received as `size_t`, and an
index out of the place's interval or an overflow is the implicit `interpreter`; read, write and `@` are
the walker's, under one predicate (`lm_compiler_index_l3_path`). `tests/sha/sha256_vectors.lm2` counts
with `size_t: i`.

Slice287 makes the index of a machine pointer held by an own field or a formal the
L3 INDEX of slice271 in walked code too: ELEM, or ELEMPUT for a store, over the place's value,
the index received as `size_t`. A walked root with `px[0U]` no longer fails at run time, and such
methods are walked under `--walk-methods`. What the route does not take (a C ABI member, a machine
local, a C constant, a `void` or foreign pointee, an index that reaches `size_t` only by a conversion)
keeps the native-only machine path: a limit of the implementation, not a genuine L2 operation (corrected
by slice288).

Slice286 gives a callable's place its declaration: the callable its definition put there.
Every write there, by any path, is admitted against it before anything changes; a fn or sub of
another signature, result or declared throws is the implicit `implements`, in native and walked code
alike, and the old callable still answers.

Slice285 makes a `sub` one Structure of the parts `args`, `var` and `body`, as a `fn` is
with its return part: a short call's data is its var, and a sub with an own field can be called in
every form.

Slice284 makes a separator the end of an operand: `add(x, \px)` and `two(x, -y)` are
two actuals, and `@: p T \q` is the path in any spacing, whatever `T` holds; a requirement and a
dereference are written `@: p T, \q`.

Slice283 reads a path below a callable's place by name over the callable standing
there, a value in that place takes the selected call's admission (a missing place is the implicit
`call`), a reached write into an immutable value is the implicit `interpreter`, and `Box\k: (int:
a 8)` is the two acts a simple head has.

Slice282 makes `@: Box\f two` the write of a place through a path: it calls nothing,
for a callable, a Structure and a reference field, with null and `Model: value`. `@: x a\b` holds
what the path reads, its leaf being the requirement, and `got: var\i` with a declared `got` takes the
value at run time. A callable place takes what a named method reference takes.

Slice281 writes a declared reference field by the store a Structure field uses:
`Holder\p: X` asks of the value what the place's known Consumers read, a refusal keeps the old
value and the field keeps its cell. A path stopping at a reference no longer asks all of its
Structure. A received letter stays on the route of its payload.

Slice280 admits a value to a slot by what the known Consumers of that place
read: a field nobody reads is not asked of the value, a value lacking a read field refuses at
the write and the old value stays. An unknown use takes nothing from what is known and asks
nothing itself. A write through a head path reads nothing that stood there, so a null in the
field does not refuse it, and a walked `NullBox\k: 0` stores its one present cell. A candidate
read from a slot refuses by a named `implements`, not by an invariant.

Slice279 keeps a written form as the source occurrence of its head: the
definition stands at that occurrence with its fields, `S\[1]t\x` reads and writes them through
a static path, a free path, a model, `node\[N]` and a `merge` copy, and the assignment after
it is no occurrence. The role is on the nodes, not in a spelling, so `l2_written_N` is an
ordinary name of a program.

Slice278 makes a written Structure two acts: the definition stays in the body
and reaching the line assigns a reference to it to the place of its head after the
admission, with no copy and no merge. `t: (int: x 2); t: (int: x 5)` works in a method, in a
named Structure, at the root, at a formal and for `var:`; a rebinding changes the place,
not the body. A short `call: code` over two root heads `var:` is the implicit `call`. An
immutable value passes to a formal of its model's ordinary type.

Slice277 assigns a Structure through a path and through an evaluated holder:
the tail is given to the place after the admission and nothing that stood there runs, a
refusal keeps the old value. `Outer\Model()` and `Outer\Model: ()` give the place one
empty Structure, a bare read does not run it and `call:` does. `First: @: First: 0` is a
present null of the place. A map step with no record receives only the edge it uses.

Slice276 counts the root heads of a Structure in a registry beside its place
names. A repeated head makes no second field: a bare name at two or more heads refuses
on every route, and `s\[N]field` selects a source occurrence and reads what stands in
its slot now. A map step tells no pair, an unfilled edge and a negative answer apart,
and composes the records already made before any new admission.

Slice275 gives a place one map: a named root and a nested field declare a
layout on their slot, and a Structure of another layout admitted there is read, written,
addressed and published through the map of the admitted pair, at any depth. All writers
of a slot use one rebinding, and its refusal is the statement's implicit throw.

Slice274 makes a write drop only the native words it really touches. A
generated word holds no named Structure, named Array or callable: it reads such a
slot when it runs and calls a callable through that callable's own word, so replacing
one is data and keeps every word. A write of code drops the words of the code that holds
the place, not of code that only refers to its holder. A word over a machine operation
cannot be dropped, so such a write is the implicit `interpreter` before it changes the
graph or a word. A slot holding a Structure holds the node itself in both executors.

Slice273 makes a C pointer parameter receive a free value by its own
contract: a leaf the kernel has a type for is judged by the actual pointee, another
C type by the pointer code the value carries, and only a `void` leaf is opaque. A
wrong pointer is `convert` before the call; a null, a void pointer and an explicit
cast pass.

Slice272 gives a free value its remaining known consumers. A C call
with a declaration in a predef document takes it as an actual and gives its
declared result beside it; cast, `c.sizeof`, index and `length` read the actual
value. A field selected by name from a free holder is written after the ordinary
admission: a Structure against the model the slot declares, `implements` when it
does not fit and the slot keeps its value; a number is `convert`, the literal 0 a
present null; a slot holding a Structure or an Array directly is rebound by a
value of the same kind. Native and walker share `lmx_walk_value_field_store`.

Slice271 keeps a written INDEX on a held free value until the
reached operation. Native and walker select its actual place through the one
kernel operation `lmx_walk_value_index_place`: an Array uses its descriptor's
metadata, a machine pointer uses the same actual classification as DEREF. Read,
write and `@` consume the selected place, and the index is an ordinary `size_t`
receive. An own Array is an ordinary activation binding, so a callee's free name
reaches its caller's Array even when the caller never reads it.

Slice270 binds ordinary written data declarations to existing
physical source cells. The reserved var input starts as selected data;
ordinary assignment replaces that same binding, and subsequent explicit
paths follow its current reference. A distinct data/var field and held
bare fields stay separate. Structure assignment does not execute its body.

Native and walker share actual named-place selection, reception and store.
A consumed numeric receiver uses one prepared expression and the common
runtime value receiver. There is no separate var parser or hidden graph.

The whole quick bootstrap took 1155.00 seconds; G1 and G2 each passed 9 smoke
rows. G2 passed 68 focused rows and the 85 rows of the full list. All 218
published source hashes equal the frozen tested input byte for byte. The 248
generation inventories are identical: 245 raw-equal files and 3 PE files
differing only in link metadata. The runtime objects equal slice286's G2 runtime.
[Sources and checks](../steps/witnesses/fix287-20261106/notes.md).

| Artifact | SHA-256 |
| --- | --- |
| Input list | `6e31cd27e3d105cd326c122b738d019480e8e23b79646bd90cbeca5c63776840` |
| Input manifest | `4314254336205dfd382f17ccbd96a1a212a84a5bb8c3348fdb2826f0fa341fc5` |
| Working tool | `3ffac1a49ddc133799bf13bd63f766e3ffb6c2de383825b815be7c3214161792` |
| G2 frontend | `8e415dadbf1e2e6bc14e8551d342719fed0ab999f526ebdfc2b8af28a8e1c4bb` |
| Production runtime | `2cab6a2717653d4e89f87fb977ce61e75bf60b6c406917ddf4cde8c2d4f66b9a` |
| Observation runtime | `47f74b3b39de2cd98aa1103d515b511840035df6e90247c776ce9e8b5b2d43cf` |

[Slice 270](../steps/witnesses/fix270-20261103/notes.md) contained 184 inputs,
manifest `B9AF771A…`, tested on the frozen `E4D1E376…`: 182 files raw-equal,
l2_driver.lm2 with its CRLF endings normalized to LF, l2_frontend_views.lm2
without one extra blank line at EOF. Its working tool is `2E936543…`.

[Slice 268](../steps/witnesses/fix268-20261103/notes.md) supplied typed-native
bitwise/shift guards and the common implicit status return.

[Slice 266](../steps/witnesses/fix266-20261103/notes.md) preserves absent data
for an ordinary unary call with no var and admits required data fields
before dispatch. Slice270 reconciles that earlier private candidate with the exact author rule.

[Slice 265](../steps/witnesses/fix265-20261103/notes.md) collected the declared-place interface independently of direct call sites.

[Slice 264](../steps/witnesses/fix264-20261103/notes.md) contained 178 inputs and introduced admission of the actual code/data pair at Structure calls.

[Slice 263](../steps/witnesses/fix263-20261103/notes.md) contained 173 inputs,
manifest `48951CA2…`, and established the shared dispatch of unary Structure calls.

The preceding packages were [slice 262](../steps/witnesses/fix262-20261102/notes.md)
(170 inputs, manifest `A148F03F…`) and [slice 261](../steps/witnesses/fix261-20261102/notes.md)
(167 inputs, manifest `CB155E7E…`).

The previous packages: boot122a is slice260 (manifest `8F34D77F…`; 6 files
over boot121a and one new fixture); boot121a is slice259 (manifest `BBCCB259…`; 6 files
over boot120a and one new fixture); boot120a is slice258 (manifest `55C1CC2D…`; 7 files
over boot119a and one new fixture); boot119a is slice257 (manifest `900AB284…`; 4 files
over boot118a and one new fixture); boot118a is slice256 (manifest `1016F41D…`; 4 files
over boot117a and one new fixture); boot117a is slice255 (manifest `FC9659DF…`; 10 files
over boot116c and one new fixture); boot116c is slice254 (manifest `DC4E8C62…`; 9 files
over boot115f and one new fixture); boot115f is slice253 (manifest `48F66AF0…`; 19 files
over boot114, the input list unchanged); boot114 is slice252 (manifest `FE3FDA29…`; 6 files
over boot112 — tp113 and tp114), boot112 is slice251 (manifest `7FA43F9E…`; 15 files
over boot89 — 9 inherited from full100, 8 of tp112), boot89 is
[slice246](../steps/witnesses/fix246-20261031/notes.md)
(its tested source [slice245](../steps/witnesses/fix245-20261031/notes.md));
the original unchanged publication is [slice239](../steps/witnesses/fix239-20261029/notes.md);
candidate48 and its FULL48 run are [slice240](../steps/witnesses/fix240-20261029/notes.md)
and [slice241](../steps/witnesses/fix241-20261029/notes.md).

## Normal source selection

Choose an explicit working G0 tool and its matching previous frontend,
backend and libc tuple; retain their provenance. Run each language CLI in a
fresh separate working directory, never the repository or source root.
STAGE is a new empty output root; do not prefill generated headers or bodies.
Using absolute substituted paths, the existing commands are:

```text
TOOL 0 entry 0 -- verify REPO/selfbuild/inputs.sha256 REPO/selfbuild
TOOL 0 entry 0 -- stage-copy REPO/selfbuild/inputs.sha256 REPO/selfbuild STAGE
TOOL 0 entry 0 -- bootstrap quick REPO STAGE BASE PREVIOUS_FRONTEND LABEL STAGE/tests/smoke-kernel225.tsv
TOOL 0 entry 0 -- bootstrap full REPO STAGE BASE PREVIOUS_FRONTEND OTHER_LABEL STAGE/tests/smoke-kernel225.tsv STAGE/tests/full-suite.tsv
TOOL 0 entry 0 -- checks LIST
TOOL 0 entry 0 -- steps LIST
```

`checks` and `steps` (slice290) run the lines of LIST, each one command of this tool with its words
separated by tabs, in order; `checks` runs every line, `steps` ends at the first command that answers
other than 0. A list that names `checks` or `steps` is refused. Every word of a line reaches its
command, however many (slice291).

Quick and full are separate requested modes, not an instruction to run both
automatically. One invocation of either builds/tests G1 and then G2 using the
actual G1 tool, promoting both. Normal generation reads staged inputs;
missing generation is a failure, not permission to reuse the older repository
headers or a cached object. Generated headers come before their consumers: the
runtime step writes the kernel's generated L1 and C headers that the smoke
list and the tool then read. The source package is authoritative; older
`dev/l2src_sandbox/`, `tools/l2/inputs/` selections and PS/Python gates are
historical inputs/routes, not an alternative fallback for this route.

boot163a selected, under the ignored `build2/codex_fix250generationchain01/`:
G0 `cold-boot162a/quick162a/lmxtool.exe` (`C6DEABF9…`, the working tool of
slice300; this package's tools/build.lm2 is unchanged), previous frontend
`cold-boot162a/quick162a/g2/frontend/l2trans.exe` (`089896A8…`, the G2
frontend of slice300) with its adjacent backend (`F6E31A5E…`) and libc
(`AF9FDAE3…`), and BASE `cold-candidate48/full48/g2/frontend`. Its promoted
working tool is `cold-boot163a/quick163a/lmxtool.exe` (`3AC5C8BA…`), the G2
tool, with `working-bundle.sha256` equal to the G2 bundle.

## Current acceptance boundary

boot163a passed whole QUICK on these bytes from a fresh source-only stage
(2026-11-07, 12:54:36–13:16:46Z, 1330 s): `BOOTSTRAP quick 0 failures`. G0
built and tested G1 (frontend, runtime, the 9-row smoke list with 0 failures,
tool) and promoted it; the actual G1 tool built and tested G2 the same way,
and G2 was promoted. Every program of the smoke list runs the driver's
start-up self-check of the code links on a private arena before its own main.
Quick runs neither the full list, the OS walk witness nor the self-test, and
does not compare the generations. The comparison ran after it as one list of
the previous working tool's own commands (`checks`): the stage against its manifest, every
producer record closed on its files and free of script hosts, G1 against G2
(`exe-same` for the three executables, which differ only in the PE link stamp,
`same` for libc, the runtime objects, the tool's L1 and C and the consumed
inputs), the working tool and bundle against G2, the runtime the candidate ran on (slice301's
runtime built from the changed kernel) against G2's runtime objects (byte-equal), and the candidate frontend
against G2 (`exe-same`). The whole full list ran on that candidate (113 rows, 0 failures) and the G2 tool's
self-test on G2; FULL has not run on these bytes. That comparison is its own evidence, not a reproducibility
gate. The draft79 line's open items (V63, the split-pointer place, the bare
return) are not closed by this result.

Publishing these bytes removes their sole residence in ignored WIP. It does
not by itself provide a clean-clone platform G0, prove every consumed include
or close S8.6, the clean/native/admission/source-profile debts, or the mail
API. Those remain the current [plan](../next_core_tasks_v3.md) and
[handoff](../to_opus.md).

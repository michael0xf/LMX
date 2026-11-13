# LMX implementation and migration notes

This file **does not define language semantics**. Current rules are in
[L3](LMX_semantics.en.md), the [grammar](LMX_grammar.en.md),
[L2](L2_spec_en.md), and [L1](L1_spec_en.md). The active queue, exact
failures, commands, and dated results belong to the [v3 plan](../next_core_tasks_v3.md),
[defects](../steps/defects.md), and tickets. The earlier route remains in the
[archived v2 plan](https://github.com/michael0xf/LMX/blob/0e0a2978eb237e145e54715de805a88e65264ba4/next_core_tasks_v2.md).
An old passing run does not prove a newer rule.

## Addition of 2026-11-13: common native code and publication — OPEN

[M14](../next_core_tasks_v3.md#native-structures) requires native code for ordinary C through the same mechanism
as methods, without data = code, artificial fn or a new runtime. One entry works with different admitted D
through the existing frame and place map. Dirty code and data, standard publication and continuation
after it must agree between native and a walker optimized with frames.

Reading main cde574b8 shows `lm_graph_collect_methods` still selects fn/sub results, with separate root emission.
`lm_graph_emit_methods` installs an emitted address on the declaration; `lmx_graph_fn_make` transfers it
to the constructed function. This neither compiles inside fn nor provides native for arbitrary nested C.
This documentation clarification changes no code. The new rule does not establish M14 readiness;
earlier direct-write witnesses do not specify publication timing for the new implementation.

<a id="source-migration"></a>
## 1. Sources and migration boundary

The maintained source language for the kernel, parser, translators, and
ordinary build is L3 with L2 insertions. L1 is only a generated
L3/L2→L1→C stage; platform bootstrap is one-time. While the closure still
contains maintained handwritten L1 sources or external build/test scripts
organize the regular cycle, §8 is incomplete. Each ported body and header
needs a dependency manifest, test, and removal of the old authoritative body.

<a id="l1-status"></a>
## 2. Translator-L1

The old L1 seed/pin and historical translator self-build are transition
tools, **not** L3/L2 self-build. M4 requires the same flat-declaration
order — name, requirement, initial value — in generated L1: first a
temporary translator accepting both orders, then migration of all emission
paths, sources, and tests, finally removal of the old order and fresh
seed/pin verification. A type expression `@: T` is not a declaration
`@: name T`. Investigate the former bare-statement nullary-call branch
separately; it does not become L3 semantics. The
[migration ticket](../steps/tickets/unique-name-reference-migration-20261014.md)
holds locations and measured starting evidence.

The current L1 `[]:` route still lowers the bare form to a raw C array.
That is a transitional mismatch with [target L1 §20](L1_spec_en.md#lowlevel-array):
ordinary `[]:` must build an `Lmx`-based graph Array, while only explicit
`c.array:` remains a machine C array. Migration must coordinate lowering,
constructors, classification, and copying instead of adding another
spelling-specific `[]:` branch.

Do not claim old `C:`, `c.struct`, `c.union`, or `synchronized` is
implemented on the strength of historical examples without checking the
handler. Old `throw` payload machine limits are not L2/L3 limits.

<a id="l2-status"></a>
## 3. Translator-L2 and kernel

The current generator already defines `Lmx` with `parent`, `native` and
an embedded `VoidArray array`; `LmxArray` is an alias of `Lmx`. The old
description of a separate Array without a header does not describe this state.
The [approved layout](L2_spec_en.md#lmx) has flat fields `parent`,
`native`, `length`, `storage` in that order, without `Lmx.array`.
Migration of the generator and all header accesses remains open in
[M13](../next_core_tasks_v3.md#flat-lmx-descriptor).

The latest M13 clarification defines ordinary non-declaring parent/native/length/storage receivers:
one argument S, or the current data when omitted. They read header values directly without
constructing descriptor. Same-headed data forms remain ordinary Structures.
`length(S)` for a Structure already exists in the clean graph; the other receivers, the no-argument
variant and renamed fields still require implementation. data/code remain launch arguments;
node and its ABI do not change. [Norm](LMX_semantics.en.md#header-receivers).

An ordinary Structure and `Array<@>` have `void *` backing elements;
such a slot's address is `void **`. A numeric Array stores typed T
elements directly. Element count is chosen at creation; published
backing neither grows nor moves. Migration preserves typed storage,
address-copy maps and `parent` for Arrays and nested Structures.
Common operations must accept Structure and `Array<@>` interchangeably,
without refusal based solely on the header category. `descriptor`
is not implemented yet: it must select an explicit S or the current data when no argument is supplied:
`descriptor() = descriptor(data)`, including inside nested control bodies.
Both variants return actual field addresses with writes through ordinary dereferencing and standard frame publication
([contract](L2_spec_en.md#get-descriptor)). Arbitrary finite pointer depth
and Array rank use the existing general algorithms; the old parser is
not rewritten. Typed arena arrays remain storage, not standalone
language objects. Growing `Thread.children` is a **separate**
List/DynamicArray, not an extension of Lmx or a program field. Launch
service data belongs to the R0 stub. See [L2](L2_spec_en.md#lmx) and
[Thread](L2_spec_en.md#thread).

`LmxThread` embeds `LmxMsg message` by value as its first field; a
plain `LmxMsg` does not expose the Thread tail. The sole child List,
arena ownership, and close follow the common Thread path. Historical
fixed root slots, `LmxLink`, a second child registry, and `settings`
appended to the source graph are rejected designs. Old emergency-slice
measurements live in [migration history](../steps/voidarray-migration.md),
not in today's gate criteria.

[critical_graph_bug](../plan_critical_graph_bug_critical_pointer_to_struct_bug_fix.md)
and [critical_pointer_to_struct_bug](../steps/tickets/critical_pointer_to_struct_bug.md)
remain open. In particular, typed machine-pointer cells, `Array<@T>`,
common `void **` graph-slot access, and full inter-arena copying require
verification. A positive test of one cell does not establish every
generator route, native/walker parity, or safety after freeing the source
arena. `implements` builds address correspondence from actually required
fields; a numeric position alone is not its contract. Current failures
and checks are in the [current kernel gate](../next_core_tasks_v3.md).

The accepted P0 package (slice 359, 2026-11-13) uses one stream parser inside `()`, `[]` and `{}` and post-processes a nested document once; it recognizes lost closing brackets, the end of a comment at the Mix document boundary, and marks attached to an intact string atom. The L2 `parser-suite` command passed 139 cases, including five saved changes to historical inputs; 11 end-to-end graph cases passed interp/native/forced. Exact builds, bootstrap acceptance and limits are in the [witness](../steps/witnesses/p0-unified-documents-20261113/notes.md). M8 remains open: P0 unwraps a sole anonymous Structure and rejects bare `f:`. The working frontend still retains the former M11 semantics; the P0 fix does not migrate it.

Slice 360 starts M8: the graph groups command records actual normalization events; 487 maintained .lm2 inputs contain 24,723 events. The working frontend gained a borrowed view of description groups, and L2 group-migrate can convert declaration sites selected from the report. General reception of the whole argument Structure is still pending, so normalization remains enabled. Exact inputs, commands and limits are in the [M8 witness](../steps/witnesses/m8-preparation-20261113/notes.md).

Slice 361 extends the clean-graph binder of a computed argument Structure: a named field selects its formal by name and an unnamed field by its own position. New parts of the existing whole_arguments case produce 23 and 46. The L2 command `graph-same LOG EXPECTED` compares a completed log's AFTER section using the same comparison as graph-check, without rebuilding. Written Structure values in the working frontend and general reception of preserved groups remain unimplemented; P0 has not been switched. [Evidence and next step](../steps/witnesses/m8-argument-fields-20261113/notes.md).

Copying a description preserves evidence of its address layout. A later
argument can compose already known correspondences to that layout; the
result is cached as an address map, not as a new full reception check
of the description or Consumer.

Returned-method constructors stage captured value references and copy
that context together with the selected method through one graph map.
Repeated references to one captured Structure still denote one fresh
object, rather than one independent copy per name. Retention follows
the same admitted `independent: immutable` profiles as ordinary copying.
Current verification and remaining work are in [the work log](../steps/current.md).

Identifier codes (IDENTIFIER-CODES; the author's decision of 2026-11-07,
[the book](LMX_semantics.en.md#fields)). The process service `lmx_ids` --
the kernel's machine module `src/l2src/lmx_ids.lm2` -- holds the single
pair of tables code → name and name → code with one counter; the words of
the language the kernel compares against get the first codes in the order
of the `LMX_ID_*` constants of its header (the implicit throws 1..7
coincide with the walker's numbers). An emitted unit declares its table
`l2_ids` and its load `l2_ids_load`: as the first statement of its builder
it turns each written name into its code once (`lmx_ids_code`) and
publishes the table (`lmx_ids_unit_publish`, once per process); from then
on the unit holds only `l2_ids[K]`. A `LmxSourceName` row binds an
occurrence's address to a code, not to text; the registration of names,
the place tables `[m, SIZE_MAX, (code, type)...]`, the activation bindings,
the binder of named actuals, the path selectors `(code, occurrence,
prefix)` and the throw keys of native code and the walker work by codes; a
copy carries the code without reading a spelling (slice 302, an
intermediate result). Slice 308 (the translator's internal comparisons by
the same codes) was stopped by the author's directive of 2026-11-08 before
landing in selfbuild -- its candidate is kept as WIP in the
[record](../steps/witnesses/fix308-20261108/notes.md). The author's decisions
of 2026-11-08 18:00–18:20Z ([journal](../LMX_blog/2026-11-08.md)): a distinct type
"T without initialization" for every primitive, told apart by the region of the
cell's address -- a pointer onto the pre-existing cell of the place. Every write,
including the first, goes into that same cell. The [later clarification](../LMX_blog/2026-11-08.md#uninit-pointer-preserved)
preserves the Structure field and internal pointer: neither is replaced or redirected on the first write.
This corrects the executor's earlier explanation rather than introducing a new language rule.
Every verification goes by arena addresses, addresses are
immovable; service operators and receivers have no separate codes; the term
"primitive" replaces "atom". The directive
([journal](../LMX_blog/2026-11-08.md)) replaces the numeric-codes
direction: the Lmx graph suffices to describe everything, the only
non-Structure is the primitive (its address gives its type, name and value), the
interpreter needs no parallel hidden structures of the program -- its
service traversal tables are left to the implementers; a name is read from
the address → name table; identifiers are single reused strings with stable
addresses compared by pointer; the arena attaches typed regions without
moving cells. The design is the [kernel implementation
specification](kernel-implementation.en.md); the present `lmx_ids`,
`LmxSourceName`, place tables and codes are a transitional state to be
replaced by it ([defect register](../steps/defects.md)).

<a id="l3-status"></a>
## 4. L3 interpreter and admission

The interpreter executes the constructed graph. [Admission](LMX_semantics.en.md#admission) has two steps:

1. Used-interface checking through `implements`, once per candidate: at graph construction when the
   candidate is known, otherwise when it is actually received at run time. This step executes neither
   the candidate, the Consumer nor future bodies. Without a Consumer, it checks the explicitly stated
   requirements of `bVar`, not full structural equality.
2. Programmer-written `test` checks at actual run-time admission. Graph construction does not run them.
   The first result of `0` stops admission immediately; remaining checks do not run.

Knowing the candidate at construction neither removes the second step nor requires repeating the first.
An established address correspondence survives value changes. Branch replacement admits the new
candidate **before storage**; mutation itself does not rerun the test set.
A numeric conversion's range check remains a check of the particular received value;
performing `implements` once does not remove it.

**Implementation status:** moving the first step to clean-graph construction is still unfinished —
step 7 of [M11](../next_core_tasks_v3.md#m11). Updating the rule does not complete that step.
Native/walker parity, publication and the full graph remain in [K01–K12](../next_core_tasks_v3.md).
Details: [place correspondence](LMX_semantics.en.md#correspondence-stability),
[argument reception](LMX_semantics.en.md#argument-compatibility-stage).

<a id="test-receiver-proposal"></a>
### 4.1 test: adopted rule, unfinished implementation

`test` is an adopted receiver; see its [contract](LMX_semantics.en.md#test-receiver-contract).
Checks belong to the receiving expression. Without an explicit Consumer they come from `bVar`, not `aVar`.
The candidate's suitability for the checker's own accesses is established before the check runs.
A check completes admission already in progress; it does not restart that same admission.
Successful admission requires every check to succeed; the first `0` stops the list.

A direct pass over `data` executes only root-level declaration receivers. An executing receiver may
reach code supplied to it, including `test`. A `test:` form does not run merely because it is present
among the data; no separate recursive pass is needed to run tests.
This is [general receiver behavior](LMX_semantics.en.md#data-root-declaration-execution).

**Implementation is still unfinished.** Use common P0, head resolution, addressing and ordinary
native/walker dispatch. Do not introduce a hidden test catalogue, runtime name table or `skip_tests`.
The name `test` is reserved: an ordinary user method with exactly that name migrates to `mytest`;
do not rename `test2`, `test3`, strings or historical quotations by substring.
Move selfbuild component checks into the language as the components themselves are migrated.

<a id="assign-named-merge"></a>
### 4.2 `:=`, named arguments, a `merge` of arguments and the whole argument Structure: adopted rule, implemented by slices 303 and 304, partly by 307 (the remainders of Codex's review of 307 are the next slice)

The author's decision of 2026-11-10 ([book](LMX_semantics.en.md#receiver-args-only)): a place is declared only by
the form `receiver: arguments`, and a field written "name: type: value" (`a: int: 5`) is withdrawn. The slices below
are described as they ran: with the field of a `merge` operand in the former form, which the translators still
accept; under the norm it is written `(int: a 5)`. The same holds for the name that holds the result of a `merge`
(`pack: merge(...)`) and for a formal or a field written as a structural form (`Q: q`): under the norm of 2026-11-11
([book](LMX_semantics.en.md#data-code-roles)) they are declared `@: pack merge(...)` and `@: q Q`. Migrating the
fixtures and changing the reading is in [plan M9](../next_core_tasks_v3.md#m9) and [M11](../next_core_tasks_v3.md#m11).

The rules are [writing a known place](LMX_semantics.en.md#assign-known),
[named arguments](LMX_semantics.en.md#named-actuals) and
[the whole argument Structure](LMX_semantics.en.md#whole-arguments)
(the author's decisions of 2026-11-07). A probe on the published 301
tuple ([record](../steps/witnesses/named-assign-20261107/notes.md)) found
the implementation did not carry them out: `:=` was not recognized,
`f(a: 5)` and `f(a(5))` bound the formal `a` because the head's name
matched it (35 and no call of `a`), the `merge` operands of the forms
`callable\args`, `a: int: 5` and `(a: int: 5)` were not lowered, and a
single Structure was not received as the whole argument Structure.
Slice 303 ([record](../steps/witnesses/fix303-20261107/notes.md); native
and the walker, both roots) carries out the first two rules and a part
of the third:

- `:=` is one operator token of P0: a Frame of its left and its right
  side flagged `LM_P0_FRAME_ASSIGN`; `a := 5` and `a:=5` are one form,
  `a:` does not become a Frame head.
- Writing a known place is the general assignment path: a local, a
  formal (the activation's value), a field through a path, the
  conversion of the reception, a method reference (`target := two`
  redefines the reference without calling the bare right side --
  natively and in the walker's program, whose dispatch had read a binding
  holding a callable as a call of the method held). An unknown left side
  is the translation refusal ":= writes a place already known: its left
  side is not one here", in a method body and in a named Structure's
  body; it defines no field. The places are the declared formals, a
  visible own field (a unit field a method sees is its hidden input,
  Q52), a slot, a method-level local and the host activation of a nested
  method; the hidden input the collection makes of a free name for
  `x: v` (the rule is the one head resolution and the book;
  steps/free-names.md is the mechanism's history, its section 7 was
  withdrawn by the clarification of 2026-10-03) is no place for `:=`.
  A method's name as the left side inside a method (`one := two`) meets
  the existing implementation limit of writing a hidden input that has
  no activation value ("writing a hidden input that has no activation
  value is not supported yet"), the same as for `x: v`; it is not a rule
  of the language. Under the norm of 2026-11-11 such a form is an error by
  the rule of the language as well: the name of a function does not stand
  to the left of `:=` ([book](LMX_semantics.en.md#data-code-roles)).
- A named argument is `f(a := v)` only: the left side selects the formal
  of the selected callable, the right side is evaluated in the ordinary
  way. `f(a: 5)` and `f(a(5))` with a callable `a` visible are its
  ordinary call with a positional result (62 and exactly one call of
  `a`); an unknown name ("zz is not an argument of tst") and a positional
  argument after a named one are translation refusals. The parts of the
  `table:` receiver are bound by the heads of its grammar by the same
  binder in its `by_head` mode.
- A `merge` operand written name first -- `(a: int: 5)` and the bare
  `a: int: 5` -- is the typed field the declaration form `(int: a 5)`
  is: it writes the model's slot of its name, keeps the other fields and
  does not write the model; the parentheses of the second operand are
  optional.
- The `merge` operand "a part of a callable", `f\args` (slice 304,
  [record](../steps/witnesses/fix304-20261107/notes.md); native and the
  walker, both roots): the `args` part of a callable is read as the
  Structure of its formals -- one field per written formal, in the
  formals' order, holding the formal's current default (the value the
  formal takes when a call omits it); a formal with no current default --
  a required one, or one whose written default this translation does not
  build -- holds no value: its slot stays empty, no zero is invented, and
  the operand is admitted only when a later operand of the same `merge`
  writes that field, else refused at the operand (Codex's review of 304;
  an explicit zero `int: z 0` is a value). The kernel reads it -- one function of both executors
  (`lmx_callable_args_value`; the walker's program takes it as a
  primitive over the callable's occurrence); the operand is recognized by
  the common path resolution (its last step is the `args` part of a
  method), the result's fields are the typed fields of the formals'
  declarations. `merge(tst\args; (a: int: 5))` reads `a` = 5 and `c` = 3,
  the bare form `a: int: 5` the same, `merge(tst\args)` reads `c` = 3 and
  `a` = 0; `tst\args` is not written. Implementation limits, not rules of
  the language: a formal of another type than a number has no field kind
  in the result's map -- a refusal at the operand ("a formal that is not
  a number is not lowered as a field of the args part yet"); a path into
  the args part (`tst\args\c`) is not resolved ("unknown field path
  segment").
- The whole argument Structure from one Structure (slice 307,
  [record](../steps/witnesses/fix307-20261108/notes.md); native and the
  walker, both roots): a call with a single Structure argument does not
  differ from a call with the chain of its fields. The binder marks one
  positional actual that may evaluate to a Structure (a name, a path, a
  `merge`, a call) as a candidate and defers the check of the omitted
  formals; the check decides on the static shape of the actual and the
  formals of the selected callable (`lm_compiler_whole_decide`): every
  field a formal of its name and of its kind's class, every other formal
  with a built default -- the fields are the arguments; otherwise the
  ordinary positional reading stands; when the Structure also fits the
  first formal, a Structure formal, by the first part of `implements` at
  translation, as the author instructed on 2026-11-08, with every other
  formal defaulted, both readings apply and ce01c206 refuses the call as
  ambiguous ("the Structure given to k is its argument q and its
  arguments: an ambiguous call", the fixture `whole_ambiguous_refused`);
  Codex's review of 307 established
  this as my own extension of the rule, not the author's decision (the
  author spoke of two really applicable methods; two `fn` of one name in
  one unit are refused at definition): the refusal is withdrawn by the
  next slice, the ordinary unambiguous call stands, no new priority of
  readings, the two-methods case stays a remainder. The binding is one kernel function of both
  executors after the evaluation of the single actual
  (`lmx_call_bind_whole`): the form against the current `args` part of the
  selected callable -- every field a formal, every other formal holding
  its current default, else the implicit `call`; then each formal, in its
  own order, receives the field of its name as a written actual of slices
  305-306 is received (a number through the route of its type or the
  implicit `convert`, a graph by the formal's own entry reception, an
  omitted formal by its default). The fields of the value are its named
  cells: the native layout of a declared Structure keeps a step cell
  beside each place (`Args: int: c 4; int: a 6` has four cells, `c` and
  `a` at 0 and 2). `pack: merge(mytest\args; (a: int: 5)); mytest(pack)`
  is 35, as `mytest(a := 5)` is; the declared `Args (c 4, a 6)` at
  `mytest` is 46 and `Args` is not written; `Only (a 9)` is 39; a
  Structure field at a Structure formal, a char field at an int formal
  through the program's receiver (one call), the callable place
  `Places\f` (a callable of other formal names held there: the implicit
  `call`); the ordinary reading at `take(Point)`, `take(p := Point)` and
  a Structure with extra fields (the fixture `whole_arguments`). The
  second pass of 307 (after Codex's review; the same record): the `merge`
  written in the call itself -- `mytest(merge(mytest\args; (a: int: 5)))`
  -- is lifted by the translation into a hidden declaration
  `l2_lift_<method>_<offset>: merge(...)` before the statement
  (`lm_compiler_merge_lift_walk`, before the owns are collected and the
  calls bound: the actuals of a call, the value of a declaration or of a
  `return`; the operands of a merge stay its operands) and gives 35 in
  both executors (`by_inline`); the names and the form of the whole are
  checked before the actual is evaluated -- the kernel
  `lmx_call_bind_whole_form` takes the codes of the static fields' names
  against the callable selected now (native `l2_wn`/`l2_wfs` before the
  evaluation, the WHOLE operand carries the names): a callable held with
  other formal names is the implicit `call` and a producer with a counter
  does not run (`early_form`, `Made\n` = 0); the applicability of the
  single-argument reading and the admission of the fields go by the
  general projection of the requirements relative to the Consumer
  (`lm_compiler_whole_applicable`: the uses of the input selected, the
  requirement's paths projected into the candidate), kind-strict at the
  leaves as the ordinary admission and the executors' reception are (the
  probe `whole_leaf_convert`: a candidate admitted by the conversion table
  stopped R0 in both executors -- the table at nested leaves stays a
  shared remainder); the refusal of two readings is withdrawn, and so is
  the hold (the author's answer of 2026-11-08, the journal): a Structure
  whose direct fields name the formals is given by its fields by the
  basic rule -- whether it would also fit the first formal as a value is
  not a question the rule asks (the fixture `whole_direct_fields`:
  `k (Q: q; int: z 0)` given `QZ (int: z 5; Q: q)` takes `q` and `z` from
  `QZ`, no default, 15; the explicit supply `k(q := QZ)` is 50); a
  Structure field without a leaf the callee reads is refused at
  translation (the fixture `whole_field_refused`), a field of another
  model with the leaves is admitted (`SArgs` with `Shape (x, y, w)` at `g`,
  10). Bounds: the operands of a
  `merge` written in the call evaluate before the call's form is checked,
  as a written `pack`'s do (a native statement's prologue reads the owns
  before its code -- the hidden declaration cannot be deferred to the call
  site); a `merge` in the actual of a callable held under a bare name, or
  deeper in an expression or in a control statement, is not lifted (the
  former refusal). The precedence of `:=` among operations and a value of
  the written form as an expression are not defined by the rule; the
  compound assignments are [4.3](#compound-assign-notes).

The defects are recorded in the [registry](../steps/defects.md).

<a id="compound-assign-notes"></a>
### 4.3 Compound assignments and `**`: adopted rule, unfinished implementation

The rules are [compound assignments and the power](LMX_semantics.en.md#compound-assign)
and [grammar §21](LMX_grammar.en.md#operators) (the author's directive of
2026-11-07, with the clarification that `**` groups as in Python). The
implementation does not carry them out yet: P0 does not single out the
tokens `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=`
and `**`; neither native code nor the walker lowers a compound assignment
to a write of a known place or has a power operation. The intended route
is the one of `:=`: one token in P0, the lowering of `a op= b` as
`a := (a op b)` with the left place evaluated once (not a macro
substitution), `**` as a common numeric operation of the kernel for both
executors. To be clarified before the implementation: evaluating a place
with effects once, the types and conversions of `**`/`**=`, a negative or
fractional exponent, `0 ** 0`, the precedence of the assignments among
operations ([plan M5](../next_core_tasks_v3.md#m5-assign-operators)).

<a id="open-design"></a>
## 5. Open decisions

- Exact form of whole-`test`-set failure and its relation to declared
  `throw`.
- Unloading a later module whose `independent: immutable` branches are
  retained by physical address in consumers; until decided, ownership
  is explicit and there is no hidden global store.
- Implementation details of the approved `args`/`return`/`data`/`code`
  layout and `call: data code`: read-before-write, hidden inputs,
  `node`, `catch`, and native ABI compatibility. These are N1–N6 work
  items, not a reason to return the model to optional research status.

<a id="grammar-extraction"></a>
## 6. Grammar versus implementation

Grammar specifies P0 shape but does not prove translator support. By the
author's decision of 2026-11-10, P0 does not unwrap the sole anonymous
Structure of an argument list: `f()`, `f:`, and `f:` with explicit `---`
have one empty Frame/body shape, while `f: ()` is the same as `f(())`: one
field, an empty Structure ([grammar](LMX_grammar.en.md#empty-colon)). At
present P0 still unwraps a sole Structure and rejects bare `f:`; the fix is
[section M8 of the plan](../next_core_tasks_v3.md#m8), which stands in the
queue right after the package of parser fixes of the second part of
sub-step 5б. Bare `f` is an atom, not a call.
Historical goldens are not automatically normative. Remaining
parser/consumer gaps and exact witnesses are in
[parser fix](../next_parser_fix.md) and [v3 plan](../next_core_tasks_v3.md).
Mix-mark diagnostics: a mark with an error inside is a parse error outside
strings (inside a string it does not fail the string), and `{#...}` is a mark
with a comment, not an error ([grammar §19](LMX_grammar.en.md#mix)); exact
error codes must not be guessed from old source text.

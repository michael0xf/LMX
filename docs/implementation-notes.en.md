# LMX implementation and migration notes

This file **does not define language semantics**. Current rules are in
[L3](LMX_semantics.en.md), the [grammar](LMX_grammar.en.md),
[L2](L2_spec_en.md), and [L1](L1_spec_en.md). The active queue, exact
failures, commands, and dated results belong to the [v3 plan](../next_core_tasks_v3.md),
[defects](../steps/defects.md), and tickets. The earlier route remains in the
[archived v2 plan](https://github.com/michael0xf/LMX/blob/0e0a2978eb237e145e54715de805a88e65264ba4/next_core_tasks_v2.md).
An old passing run does not prove a newer rule.

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

The current C record to migrate is `Lmx {VoidArray array, Lmx *parent,
LmxEntry native}`; a separate Array is still allocated as `VoidArray {size,
data}` without `parent` or `native`. This inverts the target architecture
in [L2 §2](L2_spec_en.md#lmx): a graph Array must derive from the shared
`Lmx` base and have a structural parent and native entry. The exact new
C99 layout is not yet selected; constructors' and copier's current
`sizeof(VoidArray)` cannot simply be reinterpreted as `sizeof(Lmx)`.
Current `Lmx.array` contains `void *` child slots; a graph-slot address
has type `void **`. Instance slot count is chosen at creation; published
backing neither grows nor moves. Migration must preserve typed Array
backing, address-copy maps, and reconstruction of `parent` for Arrays and
nested Structures; typed arena arrays remain storage, not standalone
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

The current kernel distinguishes selected code from supplied data; `fn`
has four parts, `args/return/var/body`. The `call: code data` form is
partly implemented: arbitrary actual code sources and admission of their
data remain limited by M2/N4 in the [v3 plan](../next_core_tasks_v3.md).
Fixed slot counts are computed in advance; full admission of required
fields must finish before execution. Do not guess an initialization change.

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
intermediate result). The translator's internal comparisons (P0, scopes,
resolve, signature interning, throw keys) and the L1 translator still
compare strings -- the rest of the transition ([defect
register](../steps/defects.md)).

<a id="l3-status"></a>
## 4. L3 interpreter and admission

The interpreter executes the constructed graph, not a second tree. The
admission contract first analyzes accesses explicitly needed by a
Consumer, then executes that Consumer's explicit behavioral checks.
Without a Consumer, full structural suitability is checked. A successful
address correspondence remains valid after values change; branch
assignment admits the replacement candidate **before storage**. Do not
invalidate correspondence or automatically rerun every check after each
mutation. Translation checks only what correct C emission and explicit throws/catch
obligations require. Actual values are admitted by the common runtime mechanism
when the call or assignment is reached; no body or future-branch preflight
substitutes for that admission.
See [correspondence stability](LMX_semantics.en.md#correspondence-stability)
and the [argument stage](LMX_semantics.en.md#argument-compatibility-stage).

Native/walker parity, publication, and the full source graph remain
within [K01–K12](../next_core_tasks_v3.md); partial guarantees and old
host/root workarounds do not close them.

<a id="test-receiver-proposal"></a>
### 4.1 test: adopted rule, unfinished implementation

The `test` receiver is **adopted**, not a new proposal awaiting approval;
see the [rule](LMX_semantics.en.md#test-receiver-contract). Without an
explicit Consumer, checks come from receiving description `bVar`, not
candidate `aVar`. Analytical suitability of necessary accesses is
checked before running a test; behavioral success exists only on its
completion. A test completes admission already in progress, not a
restart of that same admission.

Code and checks are not yet complete. The exact name `test` is reserved;
ordinary user bindings with that name migrate to `mytest`. Do not rename
`test2`/`test3`, strings, or verbatim historical quotations by substring.
Implementation uses common P0, head resolution, addressing, and
native/walker selection, without a hidden test catalogue, runtime names,
`skip_tests`, or all-tests reruns after mutation. Representation of
failure of the **whole** test set remains undecided.

<a id="assign-named-merge"></a>
### 4.2 `:=`, named arguments and a `merge` of arguments: adopted rule, implemented by slices 303 and 304, the whole-arguments supply held

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
  of the language.
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
  walker, both roots): the args part of a callable is read as the
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
- Not done: the whole argument Structure from one Structure --
  `mytest(merge(mytest\args; (a: int: 5)))` = 35 and the same Structure
  in a variable. Slice 303 held it on Codex's answer (a collision with the
  rule "a signature is not executed"); the author's decision came on
  2026-11-07 ([journal](../LMX_blog/2026-11-07.md)): the positional
  passing of one Structure errs only because of an ambiguity -- two
  methods, one with the one Structure as its arguments, the other with
  the full set of its fields; every other case is computed by the
  general matching, nothing is unfolded specially; `f(v := s)` is a
  separate case. Slice 304 held the implementation on Codex's answer
  (CODEX-FABLE-304-CHOICE-HOLD): today a call selects one callable by its
  name before the arguments and there are no overloads of one name, and
  Codex affirms neither the reading "two callables of one name" nor the
  reading "two readings of one callable's requirement" and asked the
  author how these two methods are written; the call's binder still puts
  the `merge` result into the first position and refuses ("has no
  argument a"). The precedence of `:=` among operations and a value of
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
- Implementation details of the approved `args`/`return`/`var`/`body`
  layout and `call: code data`: read-before-write, hidden inputs,
  `node`, `catch`, and native ABI compatibility. These are N1–N6 work
  items, not a reason to return the model to optional research status.

<a id="grammar-extraction"></a>
## 6. Grammar versus implementation

Grammar specifies P0 shape but does not prove translator support. The sole
anonymous container occupying an entire argument list is transparent
already in P0; completed `f()`, `f: ()`, and `f:` with explicit `---`
have one empty Frame/body shape. An unfinished bare `f:` is invalid; bare
`f` is an atom, not a call. Historical goldens are not automatically
normative. Remaining parser/consumer gaps and exact witnesses are in
[parser fix](../next_parser_fix.md) and [v3 plan](../next_core_tasks_v3.md).
Malformed Mix-mark and `{#...}` diagnostics must not be guessed from old
source text.

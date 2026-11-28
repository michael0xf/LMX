# Square-form subparser of the common LMX parser

**Normative implementation design, reviewed 28 November 2026. Production implementation and execution: NOT_RUN.** This document specifies the additional source-parsing component; it does not supply or claim an implemented production parser. The semantic contracts are [tensor expressions](TENSOR_EXPRESSIONS.md), [operation depth](OPERATOR_DEPTH.en.md), [slices](TERNARY_AND_SLICES.en.md), and [type forms](TYPE_DECLARATION_FORMS.md).

## 1. Responsibility and stage boundary

**Original author requirement, translated:**

> Add a component that parses the grammar inside square brackets and also understands the existing Python-like forms var[arg:arg2:arg3]. As soon as it identifies the start of any expression, it must call the main parser. It must do the same for text in braces {}, ignoring that text itself and not even trying to locate the closing delimiter, just as for expressions: the main parser must return control at a determined position. This is a subparser of the main parser activated from "["; the compact form "[op", without spaces, must be a trigger for calling it.

The component is inside **one main parser**. Ignoring a delegated region means not inspecting it in the square subparser; the main parser consumes it and returns its graph node and continuation position. There is also **one shared semantic grouper**. Duplicate expression parsers, boundary scanners and independent grouping implementations are removed; all consumers use the common code.

The common P0 delegates every structural `[` to one square subparser. This covers TYPE, VALUE and DATA, the symbolic head `[]:`, indexing, slicing, field occurrence selection and compact matrix operations. Shielded bracket bytes belong to their string, comment or exact name. An explicit call such as `` `[]`(…) `` starts with one identifier.

The subparser owns the separators of its current production and its `]`. The common P0 reads every full expression and Mix region. Nested structural `[` uses the same entry. The grouper receives a clean graph with spans and contexts. Method resolution and argument evaluation follow parsing.

## 2. Production recognition and context validation

| Enclosing form | Square production | Examples |
| --- | --- | --- |
| TYPE | Unspecified axis extent or full expression; a rank or extent-vector argument stays outside the pair | `[]int`, `[rows() + 1][cols()]int`, `[](sizes())int` |
| VALUE / DATA / initializer | Element stream with ordinary group and field boundaries | `[]`, `[arr2]`, `[1 2; 3 4]` |
| Declaration head | Empty pair with external name and initializer when present | `[]: pending`, `[](pending)`, `[]: [1 2]` |
| INDEX / PLACE | Index, slice fields or occurrence expression before the external NAME | `a[i()]`, `v[lo():hi():step()]`, `struct\[myIndex()]field` |
| Compact operation | Full designator, axis rules, permutation and ordinary named options | `A [*1:0] B`, `A [**] n`, `A .(d())[op …] B` |

The compact `[op …]` production takes recognition precedence. The subparser uses common tokens, the full designator and the configuration structure. The initial sign alone does not identify the production. A spaced `[ op]` uses the same entry and retains ordinary group grammar. Production recognition precedence and operator priority in the surrounding Expression are separate.

The common P0 checks whether the recognized production is admissible at its position. `A [*1:0] B` and `[rows() * cols()]int: a` are syntactically admissible; `[*1:0]int: a` fails on the matrix form in TYPE in P0 itself, for both file and buffer input. In `[(length(A [*1:0] B))]int: a` the operation is admitted inside the argument and the outer TYPE receives an extent expression. The common structural mechanism resolves residual ambiguity among admissible readings before effects. The consumer validates values.

`[arr2]` in VALUE yields an Array with one whole element. `[]` in VALUE gives a present empty Array; in TYPE it gives an unspecified extent. In `[]: pending` an absent initializer leaves the place uninitialized.

## 3. Interface and cursor ownership

The integration contract has two entries of one parser. Their concrete native binding has not been supplied; the table defines data and responsibility, not new public `sys` functions.

| Entry | Receives | Returns |
| --- | --- | --- |
| Square subparser | Source, `openPosition`, enclosing role, connections to adjacent nodes and the actual common parser | Ordinary square-form graph, `nextPosition` after its closer and source span |
| Common region parser | The same source, start position, receiving context and structural boundary policy | Ordinary region graph when present, exact `nextPosition` and recognized current-level boundary; absence of a region is retained separately from a present empty graph |

`openPosition` points to the `[` owned by this invocation. A successful square-subparser entry returns `nextPosition` **immediately after its matching `]`**. It never consumes a following operator, TYPE base, adjacent suffix or caller delimiter. The caller resumes from that exact position. A missing closer is an error with its source location, not successful EOF completion.

The common region parser returns before an **unconsumed current-level boundary** belonging to the caller. It consumes all nested regions completely and returns their graphs. Its boundary policy is structural, not “stop at any matching character”. Strings, exact identifiers, comments, nested groups, nested square forms, complete Mix regions and conditional arms shield their internal delimiters. A bounded expression can contain a complete declaration, call or any other form admitted by its normal receiving role. The helper passes the start position directly; it does not pre-scan for an expression end or a matching delimiter before calling the common parser.

In particular, when the next region begins with `{`, the square helper passes that position to the **common parser**. The common parser owns the whole Mix form, its local source context and matching `}`. A separately delegated Mix region returns `nextPosition` after that `}`; if it is part of a larger delegated expression, the common parser also consumes the rest of that expression up to the caller boundary. The helper resumes only from the returned position. The helper must not scan ahead for `}`, count its nested braces, inspect its contents, or discard its graph. The same delegation applies to `(`, nested `[`, and protected lexical forms.

An omitted field remains an ordinary absent field. This does not introduce a new LMX value, sentinel integer, required boolean field, or a request for dynamic autofill. An explicitly supplied empty expression has a present graph and must not be confused with an omitted slice field or absent axis list.

<a id="bracket-boundaries"></a>
## 4. Boundary policies

All productions use one delegation interface. The current production supplies its boundaries.

The common lexer/parser recognizes complete tokens before testing a current-level boundary. `:=`, `.:`, `->`, `<=` and other compound tokens are never split to obtain a separator. There is one contextual rule already required for Python-like slicing: at the current INDEX level, `::` supplies two slice separators. In a nested ordinary group, `::` retains its signature-operand meaning.

| Policy | Boundaries owned at this level | Work still performed by the common parser |
| --- | --- | --- |
| INDEX field | An unpaired slice `:` or final `]` | Full expression; a pending `?` consumes its own matching `:` first |
| TYPE extent | Final `]` | Full extent expression, including calls, groups and ternaries |
| VALUE / initializer | Final `]` and ordinary current-level element/row boundaries | Complete fields, short forms, nested Arrays and groups; `;` first closes a current short form |
| Indexed rule | Current rule separators `:`, `=`, `*`, comma, `;`, `->`, final `]` according to rule position | Full axis expressions; nested expression groups shield their operators |
| Options or output order | Their ordinary current-level option/list boundaries and final `]` | Complete named actuals, method references and permutation expressions |

The rule grammar owns a relation token only in the position where that relation is expected. To use a relation token as part of an axis expression, enclose that expression in an ordinary group: `A [* (axis * 2):(other + 1)] B`. The group is parsed by the full common parser; no special arithmetic evaluator is introduced. Options such as `reduce := min` are ordinary named arguments, so their `:=` is not an axis colon.

`a[flag ? 1 : 2:6]` has start expression `flag ? 1 : 2` and stop expression `6`. `a[(f :: int -> int):end]` preserves the nested signature syntax if its receiving contract admits the resulting value; parsing alone does not make it a valid integer bound. A bound expression beginning with `{` similarly delegates the complete Mix region; its type is checked by the receiving contract after parsing. More than two top-level slice colons is a slice syntax error.

## 5. Slice algorithm

1. Start the first field with no value and no slice separators. Pass its current position to the common parser with the INDEX-field receiving context and slice boundary policy; the common parser also recognizes an immediate boundary.
2. Retain the returned field graph when a region is present. If the parser returns at an immediate boundary without a region, retain an absent field. Continue strictly from its returned `nextPosition`.
3. On a current-level slice colon, require fewer than two prior separators, consume exactly that one token and start the next field. A third colon is a slice syntax error.
4. On the owned `]`, finish the body without consuming the closer. With no colons, require one present index expression. With colons, retain start/stop/step including omitted trailing fields; do not obtain their values.
5. Any other returned boundary in that position is a source-located syntax error. Only the shared outer wrapper in §7 consumes the final `]`.

`Index` and `Slice` here name ordinary graph descriptions passed to the existing consumers. They do not allocate a View, read an Array or normalize a numeric bound during parsing. `a[::]` keeps three omitted fields; `a[()]` keeps one present expression. On INDEX entry the common lexer can deliver the two colon events in `::` separately, preserving their positions; the helper does not split raw strings itself.

The outer wrapper consumes the returned `]` once and returns after it. Normalizing negative bounds, rejecting a zero step, preserving source identity and performing assignment are described in [the slice contract](TERNARY_AND_SLICES.en.md), not this source algorithm.

## 6. Operation configuration algorithm

The common parser first consumes the ordinary operation designator. The subparser starts an ordinary empty configuration Structure **without an `axisRules` field**. It then handles only forms at its own current level:

| Next form | Action |
| --- | --- |
| Explicit empty list `()` | The common parser consumes the complete group; retain a present empty rule list. Do not silently replace a previously supplied list |
| Axis rule | Delegate each expression region to the common parser; retain the relation and returned graphs in an ordinary rule Structure appended to the present list |
| Output-order arrow | Consume the owned arrow and delegate the complete permutation region; retain its graph in the configuration |
| Named option/actual | The common parser consumes the complete ordinary region; retain its result without evaluating it |
| Owned `]` | Finish the body and return the closer's position to the shared outer wrapper |

The common parser supplies recognition of current-level forms/tokens. This does not authorize textual lookahead to balance nested regions. Both absent-list and explicit-list variants are parsed without executing methods. Complete axis rules and options obey [the indexed-family contract](TENSOR_EXPRESSIONS.md#indexed-family).

The following distinctions must survive graph construction:

| Source | `axisRules` | Selected contract after normal method resolution |
| --- | --- | --- |
| `A [*] B` | Absent | Whole/default matrix multiplication |
| `A [* -> 1 0] B` | Absent | The same multiplication, then its output permutation |
| `A [* ()] B` | Present empty list | Indexed outer product |
| `A [* 1:0] B` | Present rule list | Indexed multiply-and-sum |
| `A [+ 1:0; reduce := min] B` | Present rule list | Indexed addition with explicit minimum reduction |
| `A [/] B` | Absent | Declared right solve |
| `A [/ 0=0] B` | Present rule list | Declared indexed scalar/cell division |
| `[+ 1:] A` | Present rule list | Unary sum along axis 1 |
| `[* 1:] A` | Present rule list | Unary product along axis 1 |

An arrow or named options alone do not manufacture an axis list. Presence is an ordinary Structure-field property. The exact identifier `` `[* 1:0]` `` is one literal name and is not reparsed into a method and rules. The grouper receives a prepared designator/configuration graph, not a bracket string.

## 7. Shared outer wrapper

The wrapper accepts `[` and the enclosing context. The selected production reads its body, leaving its closing `]` for the wrapper. The wrapper validates and consumes that delimiter once, retains the span and returns the position after the bracket. A different token or EOF in place of `]` is an error. A blank line cannot synthesize a delimiter. In `struct\[myIndex()]field` the returned position points to `field`; the common P0 attaches that name to the same step.

Actual LMX forms accepted by this contract:

```lmx
[8]int: a [0 1 2 3 4 5 6 7]
int: flag 1
@: selected a[flag ? 1 : 2:6]
# [1 2 3 4 5]
@: alternating a[::2]
# [0 2 4 6]
@: reversed a[::-1]
# [7 6 5 4 3 2 1 0]
```

This is LMX source for project acceptance. The documentation does not create a second parser: subsequent indexed operations use the [shared LMX bodies](patterns/LMX_Fn_Receivers/src/array_expression_ops.lmx), while concrete source-to-clean-graph integration is not claimed as completed.

## 8. Required acceptance observations

- Record one entry per structural pair and one return after its own `]` on success. Exercise distinct `[op` and `[ op]` productions through that entry.
- `A [*] B`, `A [* ()] B` and `A [* -> 1 0] B` keep their three different configuration states.
- `a[lo():hi():step()]` stores three complete expression occurrences without evaluating them.
- `a[flag ? lo() : mid():hi()]` does not split the conditional's colon.
- `a[::2]`, `a[::-1]`, `a[(f :: int -> int):end]` and `a[index := 2]` keep their contextual token boundaries.
- Strings/exact names containing `]`, `:`, `;` or `}` and nested Mix forms do not close the caller's region.
- A nested `{...}` is delegated once; its returned `nextPosition` is used without rescanning its interior or its closing brace.
- `[n + size()][m]int`, `a[n + size()]`, `[n + size()]` and an operation configuration retain their distinct surrounding roles.
- On success the returned position is after the owned `]`; a following suffix/operator/base type remains unread. On failure no invented closing token is returned.

These are implementation requirements. Host-model slice or graph tests do not prove that this source subparser is implemented. The production parser, translator and runtime acceptance of these forms remains **NOT_RUN** until checked in the project.

<a id="square-rejections"></a>

### Rejections by production and position

For each production, test admissible positions and rejection at every inadmissible position where that production can be recognized. Apply one category check to all productions and designators. P0 rejects a recognized but inadmissible production at its source location without rereading it as a different form. Compare phase, span or coordinate, and boundary owner on files and on the same bytes in memory.

| Rejection class | Distinguishing test |
| --- | --- |
| Recognized production is inadmissible at its position | A compact operation in an axis-extent position, with different full designators. Pair with an operation in Expression, a full extent expression and an admissible nested operation inside an extent expression. |
| Body does not match its production | A required region of a simple index or occurrence number is absent. Omitted slice fields are allowed. Test excess slice separators and malformed axis rules and options. |
| Error in a delegated expression or bounded region | Retain the common P0's original failure. Test a missing or foreign delimiter, EOF before closure and malformed nesting. Shielded `]` and `:` stay inside their tokens. Test errors within Mix and the separate recovery rule for a string mark, including preservation of neighboring marks. |
| Multiple grammatically admissible readings | If common structural resolution yields no unique reading, reject the ambiguity before effects. |
| Value fails the selected contract | A computed zero slice stride, invalid occurrence number or invalid extent is checked by the consumer. Record successful source parsing and the separate consumer rejection for syntactically admissible input. |

<a id="square-receiver"></a>

## 9. Shared receiver and arguments

The explicit call uses the exact key `60 5B 5D 60` (`` `[]` ``). With equivalent arguments, bracket notation and the explicit call share preparation and select the same method and body for the contract. Field occurrence selection, TYPE, slicing and matrix operations may have different contracts. Method declarations supply the formal parameter names.

| Source | Target explicit call |
| --- | --- |
| `a[i()]` | `` `[]`(source := a; index := i()) `` |
| `struct\[myIndex()]field` | `` `[]`(source := struct; occurrence := myIndex(); name := field) `` |
| `v[lo():hi():step()]` | `` `[]`(source := v; slice := (start: lo(); stop: hi(); step: step())) `` |
| `[]` | `` `[]`(items := ()) `` |
| `[extent()]int` | `` `[]`(base := int; extent := extent()) `` |
| `A [*1:0] B` | `` `[]`(op := "*"; left := A; right := B; axisRules := (contract: 1 0)) `` |

The graph preserves internal argument order, absence separately from present emptiness, external operands, depth, TYPE, NAME and the receiving role. `name := field` supplies the written key even if a variable shares the name. Occurrences are counted from zero among the owner's same-named fields. Physical slot access `S[i]` and dense Array coordinates have their own contracts. Reads, writes and address-taking use the selected place.

Arguments can be computed. Parsing, printing and clean graph construction retain their expressions without running them. The consumer obtains each demanded argument once in contract order. A slice obtains the source and each present start, stop and step. A named occurrence obtains the owner and index before selecting by name. User matrix methods are installed by ordinary declarations.

Acceptance compares targets, arguments, effects, results and rejection phase for each pair. [End-to-end checks](#square-acceptance) · [v3 schedule](../../next_core_tasks_v3.md#square-bracket-receiver-20261128).

<a id="square-acceptance"></a>

## 10. End-to-end acceptance of bracket notation and explicit calls

Run each pair from the same initial state. Compare its selected method and argument map or actual body, then its place, TypeRef, result and effects. Record the rejection phase separately using the [rejection classes](#square-rejections).

| Check | Distinguishing observation |
| --- | --- |
| P0 entry and return | `v[cond ? a[j] : hi():stop()]` has two structural pairs. Each owner consumes its `]`, and the conditional retains its colon. Repeat with nested Mix and a shielded `]`, using file and buffer input. |
| Same-named occurrence number | D has fields `field=10, a=100, field=20, field=30, b=200, field=40, field=50, field=60` in order. `D\[5]field`, `D\[myIndex()]field` and the explicit call with index 5 select 60 at physical slot 7. A write through the selected place changes the sixth occurrence. `D\field` is ambiguous; `D\[6]field` is absent even though physical slot 6 exists. An outside variable of the same name does not affect NAME. |
| Occurrence expression effects | Two calls to `myIndex()` return 0 and 5. Observe reads of 10 and 60 with two evaluations. Repeat writes and address-taking. A skipped branch makes zero calls. An evaluation error propagates before writing. |
| Slice | For `v[startFn():stopFn():stepFn()]` obtain the source, start, stop and step once each in order. A failing `stopFn()` prevents `stepFn()`. Read backing after the bounds' effects. Cover omissions, `[::2]`, `[::-1]` versus `[:-1:-1]`, zero stride and overlapping `v[::-1] := v`. |
| Value, TYPE and declaration | `[]` gives an empty Array; `[arr2]` gives one element. `[]T` has an unknown extent, `[0]T` a zero extent and `[](2)T` two axes. Compare uninit in `[]int: v` with explicit empty Array in `[]int: v []`. In `[rows() + 1][cols()]int: a makeValues()` parsing makes no calls, and consumption evaluates each demanded expression once. Cover compatible groups and the ambiguous initializer under the [Array contract](ARRAY_STORAGE.en.md). |
| Place and access chain | In `[2][2][2]int` linear index 5 and `[1][0][1]` select the same place. Compare with successive `\` steps in Structure, `plane[i][:]`, and `v[-1]` versus `v[-1:]`. Do not execute an invalid physical access in native L2. |
| Recognition and configuration | Test full designators in `A [\] B`, `A [/] B`, `A [*] B` and `A [**] n`. Distinguish axis-rule, slice and conditional colons. In `A [* (axisA()):(axisB())] B` and a computed named actual, parsing has no effects and consumption evaluates each demanded expression once. |
| Method and result | For `A=[1 2; 3 4]` and `B=[5 6; 7 8]` the bracket product and explicit call give `[19 22; 43 50]`. Elementwise `A * B` gives `[5 12; 21 32]`. Explicit `()` gives an outer product with 16 elements. Test permutation without axisRules, `i:j`, `i=j`, `i*j`, unary reduction and explicit depth. A user designator with a path or exact name takes both forms through its declared profile. |
| Codec and routes | Compare boundaries and roles in the original and restored `fromLmx(toLmx(S))` graphs, including NAME and the source occurrence expression. Compare target, result, effect order and cause of failure in the interpreter and native routes. The explicit receiver has a four-byte key; `` `[* 1:0]` `` remains one exact name. |

The source parser and shared graph preparation belong to grammar acceptance. Execution of access and codec state restoration are checked in the kernel stage. Numerical profiles follow tensor acceptance.

# Square-form subparser of the common LMX parser

**Normative implementation design, reviewed 28 November 2026. Production implementation and execution: NOT_RUN.** This document specifies the additional source-parsing component; it does not supply or claim an implemented production parser. The semantic contracts are [tensor expressions](TENSOR_EXPRESSIONS.md), [operation depth](OPERATOR_DEPTH.en.md), [slices](TERNARY_AND_SLICES.en.md), and [type forms](TYPE_DECLARATION_FORMS.md).

## 1. Responsibility and stage boundary

**Original author requirement, translated:**

> Add a component that parses the grammar inside square brackets and also understands the existing Python-like forms var[arg:arg2:arg3]. As soon as it identifies the start of any expression, it must call the main parser. It must do the same for text in braces {}, ignoring that text itself and not even trying to locate the closing delimiter, just as for expressions: the main parser must return control at a determined position. This is a subparser of the main parser activated from "["; the compact form "[op", without spaces, must be a trigger for calling it.

The component is inside **one main parser**. Ignoring a delegated region means not inspecting it in the square subparser; the main parser consumes it and returns its graph node and continuation position. There is also **one shared semantic grouper**. Duplicate expression parsers, boundary scanners and independent grouping implementations are removed; all consumers use the common code.

The common parser delegates an opening `[` to the square-form subparser for an INDEX suffix or a compact operation occurrence beginning `[op`, retaining the current syntactic context. TYPE prefixes and ordinary VALUE/initializer groups keep the common bounded-form path. The subparser recognizes its own current-level separators and final `]`. It delegates **every expression and nested source region** to the common parser. It is not a second expression parser, numeric-expression parser, brace scanner, or implementation of tensor operations.

Compact `[op` **with no space between `[` and the operation designator** is the trigger in a position admitting an operation. Examples are `A [*] B`, `A [*1:0] B`, `A [+1:0; reduce := min] B` and `A [* ()] B`. A spaced `[ op]` stays on the ordinary square-group path; it is not automatically an alternative spelling of the special operation. This does not forbid ordinary square groups with spaces. An operation designator is the ordinary permitted name, exact name, path or symbolic designator, not a fixed one-character whitelist.

Source parsing produces the ordinary LMX graph and retains the necessary boundaries and occurrence contexts. The later Expression grouper consumes this **clean graph**; it neither searches source brackets nor repeats square parsing. Operation selection, actual types, operation depth, axis sizes, numerical algorithms, and whether a `fuse` plan is supported belong to the existing consumers after parsing.

## 2. Context selects the square form

| Context supplied by the common parser | Meaning and parser route | Examples |
| --- | --- | --- |
| TYPE prefix | Unspecified/computed axis extent; common bounded-form path | `[]int`, `[rows + 1][cols]int`, `[](rankValue)int` |
| INDEX suffix of an existing value or place | Index expression or up to three slice fields; square subparser | `a[i + 1]`, `a[start:stop:step]`, `a[::2]` |
| VALUE / admitted initializer | Array element stream and ordinary row/group boundaries; common path | `[1 2 3]`, `[[1 2] [3 4]]`, `[1 2; 3 4]` |
| Compact operand designator with configuration | Whole/default or indexed operation; square subparser triggered by `[op` | `[*]`, `[* ()]`, `[/ 0=0]`, `[* -> 1 0]` |

The enclosing grammar first supplies the prefix, suffix, value or operation context. Within an operation context the designator must immediately follow `[` to select the delegated operation path. This trigger does not override an already established TYPE, INDEX or VALUE role. The component must not try a callable, inspect an initializer's runtime elements, or guess a type in order to choose a source parse. Where the enclosing syntax alone leaves competing interpretations, retain the ordinary unresolved graph description for the normal structural role resolution; it must establish one interpretation before effects or report ambiguity. A declared operator name is resolved by the same method/operand mechanism as outside brackets, not by a new registry.

`[arr2]` in VALUE is one Array containing one whole value; it is not an Expression grouping wrapper. Empty `[]` is a present empty Array in VALUE and an unspecified extent in TYPE. Neither means an absent actual. The common parser preserves these receiving contexts without adding a permanent “square bracket” flag to runtime Array values.

## 3. Interface and cursor ownership

The integration contract has two entries of one parser. Their concrete native binding has not been supplied; the table defines data and responsibility, not new public `sys` functions.

| Entry | Receives | Returns |
| --- | --- | --- |
| Square subparser | Source, `openPosition`, established INDEX/OPERATION context and the actual common parser | Ordinary square-form graph, `nextPosition` after its closer and source span |
| Common region parser | The same source, start position, receiving context and structural boundary policy | Ordinary region graph when present, exact `nextPosition` and recognized current-level boundary; absence of a region is retained separately from a present empty graph |

`openPosition` points to the `[` owned by this invocation. A successful square-subparser entry returns `nextPosition` **immediately after its matching `]`**. It never consumes a following operator, TYPE base, adjacent suffix or caller delimiter. The caller resumes from that exact position. A missing closer is an error with its source location, not successful EOF completion.

The common region parser returns before an **unconsumed current-level boundary** belonging to the caller. It consumes all nested regions completely and returns their graphs. Its boundary policy is structural, not “stop at any matching character”. Strings, exact identifiers, comments, nested groups, nested square forms, complete Mix regions and conditional arms shield their internal delimiters. A bounded expression can contain a complete declaration, call or any other form admitted by its normal receiving role. The helper passes the start position directly; it does not pre-scan for an expression end or a matching delimiter before calling the common parser.

In particular, when the next region begins with `{`, the square helper passes that position to the **common parser**. The common parser owns the whole Mix form, its local source context and matching `}`. A separately delegated Mix region returns `nextPosition` after that `}`; if it is part of a larger delegated expression, the common parser also consumes the rest of that expression up to the caller boundary. The helper resumes only from the returned position. The helper must not scan ahead for `}`, count its nested braces, inspect its contents, or discard its graph. The same delegation applies to `(`, nested `[`, and protected lexical forms.

An omitted field remains an ordinary absent field. This does not introduce a new LMX value, sentinel integer, required boolean field, or a request for dynamic autofill. An explicitly supplied empty expression has a present graph and must not be confused with an omitted slice field or absent axis list.

<a id="bracket-boundaries"></a>
## 4. Boundary policies

TYPE and VALUE rows below state the existing common-parser policies for comparison; they are not additional triggers for the operation subparser. The delegated INDEX and operation paths use the same complete-region interface.

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

The wrapper checks its opening `[` token and the supplied INDEX/OPERATION context. In OPERATION, the designator starts immediately after `[`, without whitespace. The body selected by that context from §5 or §6 receives the position after the opening token and returns its graph with the position of its own closing boundary. The wrapper validates the returned `]`, consumes it exactly once and returns the graph, source span and position after the closing token. Another token or EOF instead of that `]` is an error.

TYPE and VALUE regions stay with the common parser and its existing bounded-region algorithms. When a delegated expression contains another square region, the common parser selects its role again and can recursively invoke this component for a nested INDEX or compact operation. No helper searches for the “next `]`”; only its own returned top-level closer is accepted. Blank-line closure still cannot synthesize a missing bounded delimiter.

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

- Compact `[op` starts the operation subparser in an admitted operation position; `[ op]` keeps the ordinary square-group path and is not silently normalized into the same operation/configuration graph.
- `A [*] B`, `A [* ()] B` and `A [* -> 1 0] B` keep their three different configuration states.
- `a[lo():hi():step()]` stores three complete expression occurrences without evaluating them.
- `a[flag ? lo() : mid():hi()]` does not split the conditional's colon.
- `a[::2]`, `a[::-1]`, `a[(f :: int -> int):end]` and `a[index := 2]` keep their contextual token boundaries.
- Strings/exact names containing `]`, `:`, `;` or `}` and nested Mix forms do not close the caller's region.
- A nested `{...}` is delegated once; its returned `nextPosition` is used without rescanning its interior or its closing brace.
- `[n + size()][m]int`, `a[n + size()]`, `[n + size()]` and an operation configuration retain their distinct surrounding roles.
- On success the returned position is after the owned `]`; a following suffix/operator/base type remains unread. On failure no invented closing token is returned.

These are implementation requirements. Host-model slice or graph tests do not prove that this source subparser is implemented. The production parser, translator and runtime acceptance of these forms remains **NOT_RUN** until checked in the project.

# Square-form subparser of the common LMX parser

**Normative implementation design, 27 November 2026. Production implementation and execution: NOT_RUN.** This document specifies the additional source-parsing component; it does not supply or claim an implemented production parser. The semantic contracts are [tensor expressions](TENSOR_EXPRESSIONS.md), [operation depth](OPERATOR_DEPTH.en.md), [slices](TERNARY_AND_SLICES.en.md), and [type forms](TYPE_DECLARATION_FORMS.md).

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

These names are pseudocode integration interfaces, not proposed LMX system functions:

```text
parseSquare(source, openPosition, context, commonParser)
    -> SquareResult(graph, nextPosition, sourceSpan)

commonParser.parseRegion(source, position, receivingContext, boundaryPolicy)
    -> RegionResult(graph, nextPosition, boundary, consumedNoRegion)
```

`openPosition` points to the `[` owned by this invocation. Successful `parseSquare` returns `nextPosition` **immediately after its matching `]`**. It never consumes a following operator, TYPE base, adjacent suffix or caller delimiter. The caller resumes from that exact position. A missing closer is an error with its source location, not successful EOF completion.

`parseRegion` returns before an **unconsumed current-level boundary** belonging to the caller. It consumes all nested regions completely and returns their graphs. Its boundary policy is structural, not “stop at any matching character”. Strings, exact identifiers, comments, nested groups, nested square forms, complete Mix regions and conditional arms shield their internal delimiters. A bounded expression can contain a complete declaration, call or any other form admitted by its normal receiving role. The helper passes the start position directly; it does not pre-scan for an expression end or a matching delimiter before calling the common parser.

In particular, when the next region begins with `{`, the square helper passes that position to the **common parser**. The common parser owns the whole Mix form, its local source context and matching `}`. A separately delegated Mix region returns `nextPosition` after that `}`; if it is part of a larger delegated expression, the common parser also consumes the rest of that expression up to the caller boundary. The helper resumes only from the returned position. The helper must not scan ahead for `}`, count its nested braces, inspect its contents, or discard its graph. The same delegation applies to `(`, nested `[`, and protected lexical forms.

`ABSENT` in the pseudocode denotes the ordinary absence of a field. It is not a new LMX value, sentinel integer, required boolean field, or a request for dynamic autofill. An explicitly supplied empty expression has a present graph and must not be confused with an omitted slice field or absent axis list.

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

`a[flag ? 1 : 2:6]` has start expression `flag ? 1 : 2` and stop expression `6`. `a[(f :: int -> int):end]` preserves the nested signature syntax if its receiving contract admits the resulting value; parsing alone does not make it a valid integer bound. `a[{ ... }:end]` similarly delegates the complete Mix region. More than two top-level slice colons is a slice syntax error.

## 5. Slice algorithm

```text
parseIndexBody(cursor, context):
    fields = []
    separators = 0
    repeat:
        # The common parser identifies an immediate caller boundary as well.
        part = common.parseRegion(cursor, INDEX_FIELD, sliceBoundaryPolicy)
        fields.append(ABSENT if part.consumedNoRegion else part.graph)
        cursor = part.nextPosition
        if part.boundary is RBRACKET:
            if separators == 0:
                require fields[0] is present
                return Index(fields[0]), cursor
            pad omitted trailing fields to three without reading their values
            return Slice(fields.start, fields.stop, fields.step), cursor
        require part.boundary is SLICE_COLON
        require separators < 2
        cursor = consumeOneBoundaryToken(cursor, SLICE_COLON)
        separators += 1
```

`Index` and `Slice` here name ordinary graph descriptions passed to the existing consumers. They do not allocate a View, read an Array or normalize a numeric bound during parsing. `a[::]` keeps three omitted fields; `a[()]` keeps one present expression. On INDEX entry the common lexer can deliver the two colon events in `::` separately, preserving their positions; the helper does not split raw strings itself.

The outer wrapper consumes the returned `]` once and returns after it. Normalizing negative bounds, rejecting a zero step, preserving source identity and performing assignment are described in [the slice contract](TERNARY_AND_SLICES.en.md), not this source algorithm.

## 6. Operation configuration algorithm

```text
parseOperationBody(cursor, context):
    method, cursor = common.parseDesignator(cursor, ordinary designator rules)
    config = ordinary empty configuration Structure
    # No axisRules field is supplied yet.
    while next current-level boundary is not RBRACKET:
        if next form is the explicit empty rule list ():
            require no previous axisRules list
            config.axisRules = present empty ordinary list
            cursor = common.parseRegion(cursor, DATA, completeGroupPolicy).nextPosition
        else if next form is an axis rule:
            parse its left/right expression regions through common.parseRegion
            retain relation and expressions in an ordinary rule Structure
            append rule to the present config.axisRules list
        else if next token is output arrow:
            consume arrow and delegate the complete output-order region
            retain its graph in the ordinary permutation field
        else:
            delegate the ordinary named option/argument region
            retain it in config without computing it
    return operation occurrence(method, config), cursor
```

The common parser supplies form/token recognition at the current level. This pseudocode is not permission for textual lookahead to balance nested regions. Both absent-list and explicit-list variants are parsed without executing methods. Complete axis rules and options obey [the indexed-family contract](TENSOR_EXPRESSIONS.md#indexed-family).

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

```text
parseSquare(source, openPosition, context, common):
    require common.tokenAt(openPosition, context) is LBRACKET
    require context is INDEX or OPERATION
    cursor = common.positionAfterToken(openPosition)
    if context is OPERATION:
        require operation designator starts exactly at cursor, without whitespace
    body, closePosition = dispatchBySuppliedContext(cursor, context, common)
    require common.tokenAt(closePosition, context) is RBRACKET
    return SquareResult(body,
                        common.positionAfterToken(closePosition),
                        span(openPosition, closePosition))
```

`dispatchBySuppliedContext` selects the INDEX or operation algorithm above. TYPE and VALUE regions stay with the common parser and its existing bounded-region algorithms. When a delegated expression contains another square region, the common parser selects its role again and can recursively invoke this component for a nested INDEX or compact operation. No helper searches for the “next `]`”; only its own returned top-level closer is accepted. Blank-line closure still cannot synthesize a missing bounded delimiter.

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

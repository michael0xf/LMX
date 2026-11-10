# LMX grammar

1. **GROSS ERROR IN THE PREVIOUS REVISION — REQUIREMENT TO FIX P0 CODE.** The rule that P0 removes a sole non-empty anonymous Structure and substitutes its fields was wrong. P0 must preserve every explicitly written non-empty anonymous container in every context. Generic flattening damages non-call Structures as well as calls. Remove any implementation that unwraps a sole non-empty anonymous Structure during parsing or syntactic normalization. Preserve the container, its children, delimiter kind, and source span. Unwrapping a supplied non-empty Structure is permitted only by function/method invocation semantics after P0; it must not mutate the retained source tree. An empty Structure is outside this requirement: expanding it in P0 is not an error ([the author's clarification of 2026-11-09](../LMX_blog/2026-11-09.md)), and P0 indistinguishability concerns only the non-call records of an empty Structure: `A{}`, the short form `A: {}` ended by a line break and a return to the previous level, and the block record of `A` with an empty body (for example `A:` followed by `---` or `end: A`) are three forms with the same meaning, an empty Structure, and one tree (so is the short `A: ()`). This follows from the general rules of levels and of how short and block forms end, not from a parser exception: `A: {}` followed by `end: A` is a block record of `A` whose only field is an empty Structure, that is `A{{}}`. P0 marks `A()` as a call (the author's clarifications, ibid.).

2. **REQUIREMENT TO REMOVE TWO-ARGUMENT RECEIVER FORMS FROM CODE.** Remove the two-argument forms of built-in data/type receivers from semantic validation, dispatch, implementation, examples, and any backward-compatible fallback. The removed forms include `int: i 5`, `@: ptr 0`, `@: ptr Model`, `@: ptr Model: Other`, and `int(v, j)`; they must not remain accepted as legacy alternatives. Put the declared or assigned place outside the receiver's operand, for example `i{ int: 5}`, `i: int: 5`, `ptr: @: 0`, and `ptr: @: Model`. Unary `int: x` and `@: ptr` remain admitted. This requirement does not ban multiple arguments of arbitrary functions, `merge`, `fn`, `print`, `if`, or message operations. P0 still parses their common structural form without receiver-name-based arity inference; the removed built-in interpretations must be rejected by their semantic consumer.

**Revision 4: 2026-11-09.** All names are visible in both directions within their admitted scope. The latest applicable preceding definition or accumulated update takes precedence; when none exists, the name may be found ahead. Future writes do not execute early. This is a semantic rule after P0. Direct selection by `struct\(index)`, named-occurrence selection by `struct\(index)field`, expressions as Structures, curly descriptions and grouping, square Mix, round calls and Array indices, and both initial code-correction requirements remain in force. Implementation requirements are in the [fix list](new_bugs_for_fixing.md). This revision takes precedence over incompatible older rules.

**Writing calls and declarations (the author's decisions of 2026-11-09, [journal](../LMX_blog/2026-11-09.md)).** A call is only the round form right after a name: the main `f(args)` and the nullary `f()`; inside the parentheses everything admitted inside `{}` is admitted, blocks included. `f(): args` and the block `f():` are a rarely needed additional layout of the same call. P0 marks a call form as a call. The colon Frame `f: args` is not a call even when `f` is a function. The call rule does not apply to receivers and operators: `fn:`, `int:`, and other receivers keep their forms and contracts and admit parentheses without any change of meaning (`int(5)` is the same as `int: 5`). Parentheses without an identifier are an alternative spelling of the anonymous Structure `{...}`; the symbolic head `():` allocates an Array. Declarations: `name: fn: return args <var body>`, `name: sub: args <var body>`, `Name: catch: args <var body>`; the parts of a function are `{return args var body}`. Not every level needs closing (sections 15 and 17).

- [1. Scope and sources](#scope)
- [2. Structures, fields, and Frames](#structure)
- [3. Source bytes, lines, and coordinates](#positions)
- [4. Numeric literals](#numbers)
- [5. Bare and exact identifiers](#identifiers)
- [6. Ordinary strings and character constants](#c-strings)
- [7. Triple quotes](#raw-quotes)
- [8. Block text and encodings](#block-text)
- [9. Comments and disabled blocks](#comments)
- [10. Compact, short, and vertical forms](#frames)
- [11. Comma, semicolon, and positional skips](#separators)
- [12. Anonymous Structures](#anonymous)
- [13. No hidden signature-based grouping](#no-inference)
- [14. Bounded forms: brackets](#bounded)
- [15. Source levels and indentation](#levels)
- [16. Dotted delimiters and dash fences](#markers)
- [17. Named closure and terminal forms](#close)
- [18. Missing arguments and an empty vertical body](#empty-colon)
- [19. Square brackets and Mix anchoring](#mix)
- [20. Spelling intersecting marks](#mix-overlay)
- [21. Operator tokens and expression boundaries](#operators)
- [22. Address, index, and path forms](#paths)
- [23. Explicit C surface and profile boundaries](#foreign)
- [24. The single P0 automaton](#automaton)
- [25. Surface-form EBNF](#ebnf)
- [26. Structural-result EBNF](#normal-form)
- [27. Original literal-boundary examples](#fixtures)

<a id="scope"></a>

## 1. Scope and sources

This grammar specifies P0 lexing and structural parsing: fields, Frames, levels, closers, and Mix. Revision 4 of 2026-11-09 adds bidirectional visibility for all names and precedence for the latest applicable preceding definition or accumulated update; these are semantic rules after P0, not changes to structural parsing. Direct positional Structure selection, expressions as Structures, the Structure/Mix delimiters, removal of two-argument built-in data/type receiver forms, and the assignment, invocation, array-representation, and P0 corrections above remain in force. These explicit rules supersede conflicting older text, including the linked [L3 semantics](new_LMX_semantics.en.md); those links do not restore the removed rules. Value and kernel semantics not changed here remain outside P0.

The old `Lingvamyxa_spec.txt` and [source comparison](source-comparison.en.md) preserve provenance, not a parallel norm. Examples labelled **Adapted example** have been updated by syntactic role and are not verbatim historical quotations. Unchanged **Source excerpts** preserve their quoted text. The EBNF in §§25–26 is the current grammar and structural result, not an immutable excerpt of the former specification.

Related worked examples are in the updated [semantics guide](new_LMX_semantics_guide.en.md).

<a id="structure"></a>

## 2. Structures, fields, and Frames

Sources: §§0, 3.2–3.4, 4.0, 4.8–4.9, 5, 15, revised by the author's decisions of 2026-11-09.

A grammar rule is universal within its domain: a name, type, nesting level, or translator convenience creates no separate syntax branch. A proposed exception or contradiction between rules requires explicit discussion and must not be hidden by special-case parsing.

P0 builds ordered Structures, named Frames, atoms, and Mix nodes with source spans. A Frame has a head and one body Structure. Field order and every explicit non-empty anonymous container are preserved, even when the container is the only field; expanding an empty Structure is not an error ([§18](#empty-colon)). A physical line is not an abstract-tree container. P0 never replaces a non-empty anonymous container with its children.

Expressions are Structures. An expression has ordered fields, which may include atoms, operator fields, Frames, and nested Structures; P0 retains the written order and explicit containers. `{a + b}` is an explicitly bounded expression Structure, not a separate non-Structure expression object. Operator roles, precedence, and evaluation are determined by the expression profile after P0. Being an expression Structure does not imply immediate execution or add a runtime wrapper or fixed operator-slot layout.

A colon separates a head or an addressed place from its following body. `fn:`, `if:`, `int:`, `():`, and user heads use this common structural form. The same `:` spelling supplies a named actual argument, applies a receiver, and writes to an admitted existing place; context and the consuming semantics determine the role after parsing. The colon form never calls a callable: a call is the round form after a name. There is no separate `:=` operator. Nesting alone does not execute a Structure.

Built-in data/type receivers no longer admit their former two-argument place-and-value forms. Use an outer named description or colon Frame: `i{ int: 5}`, `i: int: 5`, `ptr: @: 0`, or `ptr: @: Model`. Unary `int: x` and `@: ptr` remain admitted. This is a receiver-semantic restriction, not a universal restriction on the number of fields or on calls such as `f(x, y)` and `merge(A, C)`; the removed branch must not remain in code as a legacy fallback.

Curly braces describe or group a Structure: `{i: int: 1}`, `{i: int}`, and `{}`. They also replace the former non-call expression grouping: `{a + b}`. A name followed by a brace-delimited body is a bounded named description, as in `arr{ (): @}`; it is not indexing. Round brackets right after an identifier form the common attached application form used for method calls, ordinary-Structure execution, Array indexing, and a receiver application with the same meaning as its colon form, as in `f(1)`, `arr(2)`, and `int(5)`; P0 marks it as a call form. Without an identifier, `(...)` is an alternative spelling of the anonymous Structure `{...}` with the same admitted contents, as in `(1)` and `(i: 1)`. These roles are resolved after P0 without changing the written nesting.

A method Structure has the ordered addressable parts `return`, `args`, `var`, and `body`; `sub` and `catch` have `args`, `var`, and `body`. The declared name stands outside: `name: fn: return args <var body>`. Direct selection and its representation as an Array of `@` use that order at zero-based indices 0, 1, 2, and 3: `f\(0)` selects the `return` Structure of method `f`, and `f\(1)` selects `args`. `var` follows `args` and precedes the body of every `fn`/`sub`/`catch`. There is no separate `fm`: several named results are described by a Structure in the `return` position. These are ordinary field roles: P0 does not populate `var` from the body.

An ordinary Structure has no formal argument list. It is executed by `s()` or with one Structure selected as `data`, `s(data)`. A method uses its declared formals, so `f(1)` is a method call. A Structure element is selected directly by `struct\(index)`; the index counts all immediate fields from zero. `struct\(index)field` instead selects the zero-based occurrence of the specified root-level head `field:`. Representation as an Array of `@` remains another available access route, as specified in [§22](#paths). The operator `call` is removed.

Positional fields retain their order. In a function/method invocation, `f(i: 1)` supplies the named actual `i`; P0 retains its ordinary nested colon Frame, and invocation semantics gives it the named-argument role. Parameter names, table meaning, column count, validation, and execution are not inferred by P0 from visual alignment. There is no separate anonymous-function or label grammar; `outerLoop:` with a body is an ordinary Frame.

**Current examples.**

```lmx
f(a, b, c)
f(i: 1)
{i: int: 1}
{i: int}
arr{ (): @}
struct\(index)
struct\(index)field
f\(1)
{a + b}
```

<a id="name-visibility"></a>
### Semantic name visibility

**All names are visible in both directions within the applicable binding scope.** This applies equally to methods, ordinary Structures, reference places, and other named places; there is no remaining restriction that an ordinary name is visible only after its declaration. At a given position, the latest applicable preceding definition or accumulated update takes precedence: look backward and use the latest. Applicability here concerns the name and binding scope, not successful value validation: the selected value undergoes ordinary admission, and incompatibility does not authorize silently falling back to an earlier value. If no such preceding source exists, the name and prepared place may be found ahead. There is no selection by proximity among several candidates: within a code scope a name has one prepared place, and several same-named data occurrences without an index are an ambiguity error ([the author's clarification of 2026-11-09](../LMX_blog/2026-11-09.md)).

Bidirectional visibility does not move execution of a future initializer or assignment backward. The walker accumulates reached changes in sequence; a later write does not replace the value at every earlier position. Repeated assignments to one place update that place and do not create competing same-named fields. Visibility of a name or an allocated place does not itself promise an initial value: the ordinary initialization, conversion, and admission contracts apply.

Preliminary automatic population of `var` provides the complete set of a method's own fields before layout and execution. It prepares places; it is neither an exceptional source of bidirectional visibility nor early execution of `body` statements. Native lowering must account for the complete field set and address correspondences while preserving the walker's name selection and observable write order; layout cannot depend only on fields already encountered during linear code emission.

**P0 does not resolve visibility.** It preserves all source occurrences, their order, levels, containers, and spans; semantic selection neither removes an earlier occurrence from the tree nor changes the EBNF. The rule applies inside an already admitted scope and source: it does not extend the `parent` chain, the meaning of `node`, `independent` boundaries, dynamic-versus-lexical source precedence, or access to another owner's data. Explicit-path ambiguity in `data\field`, indexing by `\(index)` and `\(index)field`, and Mix activity rules remain unchanged. Implementation requirements are collected in the [fix list](new_bugs_for_fixing.md).

<a id="positions"></a>

## 3. Source bytes, lines, and coordinates

Source: §15.0.

P0 positions and spans refer to original bytes. For diagnostics, CRLF is one line break of width two bytes; LF and lone CR are breaks of width one byte. The buffer is not rewritten to normalize lines. In `a`, CR, LF, `b`, byte `b` has offset 3 and coordinates 2:1 with a 1:1 base. A position on the LF of a CRLF pair has the coordinates after its CR. Slice ends are exclusive: a CRLF cut between CR and LF counts as a lone CR within that slice.

String-value decoding is separate from source coordinates. Generated text files use LF; input may contain LF, CRLF, and lone CR. Line breaks within a shielded literal do not produce outer Structure level events.

<a id="numbers"></a>

## 4. Numeric literals

Source: §3.4.1.

Integer and floating literal forms follow ANSI C/C99: decimal, octal, and hexadecimal integers, integer suffixes, decimal and hexadecimal floating constants, exponents, and floating suffixes. Whitespace separates neighboring numeric fields; operator spelling remains in the common token stream according to lexer rules, rather than introducing a new naming form. Numeric-looking text in backticks is an exact identifier.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2187–2194.

````text
    0
    123
    0123
    0x7B
    123u
    123UL
    123ll
    0xffULL
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2198–2206.

````text
    1.0
    .5
    1.
    1e9
    1.25e-3
    1.0f
    1.0L
    0x1.8p+2
    0x1p-4
````

<a id="identifiers"></a>

## 5. Bare and exact identifiers

Sources: §§3.4.2–3.4.3.

A portable bare identifier has the form `[A-Za-z_][A-Za-z0-9_]*`. It contains no spaces. An exact identifier is delimited by backticks; a doubled backtick inside denotes one literal backtick. Other bytes, spaces, punctuation, line breaks, and indentation are preserved. An empty name is allowed; NUL before the closing delimiter is an error. Backslash introduces no separate escape mechanism here.

The identifier value is its content after delimiter removal and doubled-backtick unescaping. If that value is valid unquoted, both spellings denote the same name. An exact token is atomic in head, argument, and expression positions; operators, comments, and levels are not recognized inside it. Quoting does not escape semantic name reservation: in the old language profile, `node` and `` `node` `` are equally reserved. The general grammar itself does not prescribe that name's runtime meaning.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2224–2224.

````text
    [A-Za-z_][A-Za-z0-9_]*
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2297–2297.

````text
    `exact name`
````

<a id="c-strings"></a>

## 6. Ordinary strings and character constants

Sources: §§3.4.4, 3.4.4.2.

Double-quoted strings and single-quoted character constants follow ANSI C/C99, including wide forms `L"..."`, `L'...'`, escapes, and splicing of a backslash immediately followed by a physical line ending. An unescaped physical newline before an ordinary string closes is an error. A spliced newline contributes no value character; spaces on the following physical line remain inside the literal rather than becoming outer indentation.

An octal escape consumes up to three digits, `\x` consumes following hexadecimal digits under the C rule, and `\uXXXX` and `\UXXXXXXXX` are universal character names. A character constant has a numeric value; multicharacter and wide constants follow the selected C profile.

A closing quote must be followed by a field boundary: horizontal space, newline, comma, semicolon, `(`, `)`, `{`, `}`, `[`, `]`, or the end of the item. Another character is a missing-separator error. Adjacent string literals are separate fields, not implicit C concatenation. A string and an exact identifier are distinct.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2365–2376.

````text
    "hello"
    "line one\nline two"
    "tab\tseparated"
    "quote: \""
    "backslash: \\"
    "question: \?"
    "alert\a backspace\b formfeed\f newline\n carriage\r tab\t vertical\v"
    "octal A: \101"
    "hex A: \x41"
    "lambda: \u03BB"
    "grinning face: \U0001F600"
    L"wide text"
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2380–2381.

````text
"physical\
line break"
````

<a id="raw-quotes"></a>

## 7. Triple quotes

Source: §3.4.4.1.

Three double quotes or three single quotes in token position open a raw string literal. It closes at a run of exactly three matching quotes. A run of N ≥ 4 matching quotes remains content and contributes N − 1 quotes to the value; one or two are ordinary content. The opposite quote character is always ordinary. Backslash does not escape; there are no C escapes, line splicing, or implicit concatenation.

Newlines, NUL, comment-looking text, brackets, and colons inside are content of a length-bearing literal. Its internal lines do not produce outer level events. After closure, the field sequence continues on the same line when separated by space, newline, `,`, `;`, `(`, `)`, `{`, `}`, `[`, `]`, or item end.

P0 preserves the source spelling including triple delimiters. Quote-run shortening and value-newline normalization belong to decoding. A multiline literal is one atom, not a source-level block of its own; it needs the ordinary child level within a vertical body.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2422–2423.

````text
    """text"""
    '''text'''
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2450–2452.

````text
    text: """line one
    line two # not a comment
    line three: not a frame"""
````

<a id="block-text"></a>

## 8. Block text and encodings

Source: §3.4.4.3.

A column-0 line of 3–80 `=` characters with optional trailing spaces/tabs opens block text. Only a matching pure line with exactly the same number of `=` closes it. Leading indentation, titles, and comments on a fence line are not allowed. A different-length fence inside is content; fences do not nest. Opening and closing lines are excluded from the value. An unclosed fence is an error.

The content is raw and length-bearing: NUL is allowed, backslash does not escape, and quote runs are not shortened. Interline value breaks are preserved after newline normalization. A fence does not itself change the level and supplies its value to the current open body, including the innermost open short Frame.

All three raw forms can carry bytes of a selected text representation. `utf8`, `utf16`, `utf32`, and width markers are ordinary data/receivers, not special P0 rules. Encoding validation and transcoding belong to the consumer.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2495–2496.

````text
    ===
    ====
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2549–2552.

````text
===
line one
line two
===
````

<a id="comments"></a>

## 9. Comments and disabled blocks

Source: §4.10.

Outside a shielded literal, `#` starts a comment through physical line end; preceding code is parsed normally. `%` at the start of an item after its indentation zone disables that item and its vertical body. Space after `%` is optional; the marker does not affect the level. P0 retains an inactive placeholder rather than the body's ordinary subtree. Lightweight validation still checks levels, admitted closers, balanced bounded forms, and literal closure. Ordinary semantic processing and definition registration are not performed for the disabled body.

A raw file-comment fence is a column-0 line of 3–80 `*` characters with only optional trailing spaces/tabs. Its closing fence must have the same length. Interior lines are not parsed as code, including malformed syntax; levels and closers are not checked. Ignoring a comment during parsing does not discard its text from the retained representation; a comment is not an executable operator. Fences do not nest; a different-length run is content. A missing closing fence is a file error. A title or `#` comment cannot be added to such a fence.

**Source excerpt** — `Lingvamyxa_spec.txt`, 4016–4017.

````text
print: count # print the current value of count
# this whole physical line is a comment
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4061–4063.

````text
    ***
    ****
    *****
````

<a id="frames"></a>

## 10. Compact, short, and vertical forms

Sources: §§4.0–4.3, revised by the author's decisions of 2026-11-09.

`f(a, b, c)` is a compact Frame with a bounded round argument Structure. `f: a b c` opens a short form at level N; its tail is at implicit level N + 1. `name{...}` is a bounded named description with a brace-delimited body. P0 preserves these forms and their delimiters; semantic equivalence in an admitted invocation does not make their syntax trees identical. An empty opening-line tail may continue with vertical children. A colon admits a bare, exact, or symbolic head, or an addressed place admitted by the expression profile.

Horizontal whitespace and commas separate fields of the current tail. A physical newline resets the counter to the completed physical line's level but does not by itself complete the Frame. Implicit levels of nested inline heads do not persist across the newline. The next item or marker determines continuation or closure under the shared [level model in §15](#levels); this model distinguishes the physical line's level from the depth of its open inline tail.

The composed `i: int: 5`, `i{ int: 5}`, `new_var: int()`, `ptr: @: 0`, and `ptr: @: Model` use ordinary nested Frames. The outer head names the place, and the built-in receiver contains its operand. The removed two-argument data/type receiver forms are not alternative descriptions or assignments. Unary `int: x` and `@: ptr` remain valid. P0 neither parses these forms by receiver name nor assigns semantic roles to their fields; the semantic consumer rejects the removed two-argument built-in interpretation. `arr: (): int` and `arr{ (): int}` describe an Array; in both, `(): int` is a nested symbolic-head Frame, not an empty anonymous Structure followed by a colon.

An ordinary Structure is explicitly executed by `code()` or `code(data)`, where `data` is a Structure; `code()` is the former `call(code)`. The removed `call` operator has no current spelling as a separate receiver. A method call such as `f(1)` supplies actuals to its formals, and P0 marks this round form as a call; the short form `f: 1` does not call the method. The same call may be laid out as `f(): 1` or as a block `f():` with the arguments on the next level; this rarely needed additional layout assembles its body under the same level rules as any short and vertical form. P0 does not infer these categories from names.

When an indented body follows existing inline arguments, the down/up level transition preserves a new Structure-field boundary. Vertical tokens must not simply be flattened into the inline tail. Ordinary P0 neither infers argument counts from head signatures nor unwraps a sole anonymous child.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2606–2606.

````text
    head: tail
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2770–2770.

````text
    f: a b c
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2901–2904.

````text
    receiver:
    . arg0
    . arg1
    . arg2
````

<a id="separators"></a>

## 11. Comma, semicolon, and positional skips

Sources: §§4.1, 4.2.1–4.2.1.1, 15.

A comma separates fields and does not terminate an open short tail. A semicolon at the current scan depth immediately terminates the current short form, then separates the next item/segment at that depth. A separator inside deeper brackets belongs to those brackets. With no open short tail, comma is an ordinary separator and semicolon an item separator; a single trailing separator is allowed, including at file root.

A neighboring headless segment after `;` may be represented as a separate anonymous Structure. P0 does not append it to the completed tail or decide whether it repeats a declaration. The consuming profile decides that.

Repeated separators `a,,c`, `a;;c`, `a,;c`, `a;,c` denote a positional skip where the context admits empty positions; a leading separator may skip the first position. P0 preserves the skip without shifting the other arguments. A consumer admits it only for an argument with an allowed default, otherwise reporting an error. `{}` and `()` are a present empty Structure, not a positional skip; `()` right after a name is the nullary call form.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2950–2950.

````text
    head: arg0, arg1
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2958–2958.

````text
    head: arg0; arg1
````

<a id="anonymous"></a>

## 12. Anonymous Structures

An argument list is a Structure. Every explicitly written non-empty anonymous container is itself a field of its surrounding Structure. P0 preserves that field without regard to the number of its siblings, the head's name, or an eventual invocation; expanding an empty Structure is not an error, and the general level rules determine the result ([§18](#empty-colon)). Round brackets without an identifier are an alternative spelling of the same anonymous Structure as braces, with the same admitted contents. Headless atoms and Structures, including expression Structures and empty Structures, are also valid in a body. P0 preserves order and nesting but does not decide whether a field is executed, discarded, or accepted as a value.

Function/method invocation semantics alone may consume a sole supplied Structure, as in `f({a b c})` or `f(x)`, as the actual-argument Structure. That is an invocation operation over the retained tree, not a parsing rewrite. A non-call consumer never inherits generic argument unwrapping. Nested data, descriptions, arrays, grouping, and Mix keep their explicit boundaries.

**Current examples adapted from** `Lingvamyxa_spec.txt`, 2709–2714; they are structural examples of non-call Frames. These spellings are not asserted to have identical P0 trees.

```lmx
f: a b c
f: (a b c)
f: {a b c}
f:
    a
    b
    c
```

The second form contains one anonymous Structure in round spelling with fields `a`, `b`, and `c`; the third contains the same anonymous Structure in brace spelling. The first lists the three fields directly. The vertical form follows the explicit level events; no field is removed to make it match another spelling.

**Adapted example** — `Lingvamyxa_spec.txt`, 2729–2729.

```lmx
f: a {1 2 3} b
```

The brace-delimited container remains one field between `a` and `b`.

In nested anonymous Structures, expressions included, round and curly brackets alternate where possible for readability: start preferably with curly brackets, use curly ones next to the parentheses of a call as well, and round ones inside curly ones, for example `{a * (b + {c - d})}` and `f({a b})` ([the author's wishes of 2026-11-09](../LMX_blog/2026-11-09.md)). This is a style recommendation, not a parsing rule: the number, boundaries, and nesting of containers do not change, and the brackets of a call `f(...)` stay round.

<a id="no-inference"></a>

## 13. No hidden signature-based grouping

Sources: §§4.2.2–4.2.3, 4.4, 6.1–6.3, revised by the author's decisions of 2026-11-09.

Whitespace separates fields. `print: getTypedValue values(i)` does not turn into `getTypedValue(values(i))`. Nesting requires an explicit bounded form, a compact Frame, or a vertical Structure. `args: merge(A, C)`, `args: {v: int: 5}`, and the vertical nested form all express nesting, but they retain their distinct written containers; they are not interchangeable P0 trees. The `int` receiver in the description has the single operand `5`; `v` is the outer place name. A call to `merge` can still have multiple arguments.

Application with explicit actual arguments requires its own Frame: short `merge: A C`, compact `merge(A C)`, or an admitted vertical form. This rule applies to all heads without name-based exceptions. In `b: merge A C`, the body of Frame `b` contains neighboring atoms `merge`, `A`, and `C`, not a nested `merge` Frame. P0 forms the complete written structural model without knowing the head's role or consulting its availability, signature, or category. A bare identifier remains an atom and captures no neighboring fields. Head resolution and invocation consumption follow parsing; they do not authorize flattening the source tree.

Expressions are Structures whose ordered fields can contain atoms, operators, Frames, and nested Structures. `print: a+b c` and `print: a + b c` produce the same structural split. Curly braces explicitly bound an expression Structure: `{a + b}`. P0 retains the fields and the bounded Structure itself; it does not replace that Structure with its fields or invent a separate expression wrapper. The expression consumer interprets the retained Structure in expression position. A round form right after a name remains the common application/index form, and a standalone round form is an anonymous Structure; an indexed path such as `struct\(index)` is a written path form inside the same structural model.

An expression's structural identity does not cause it to run merely because it is nested, stored, selected, or described. An executing semantic consumer determines whether and how to evaluate it. This revision does not assign a fixed ABI layout to expression fields.

The expression profile determines prefix, postfix, or infix roles, precedence, and operation meaning after P0. The C projection preserves its established operator precedence and associativity except where this revision explicitly changes the surface spelling; other backends use a profile, not a new structural grammar.

**Source excerpt** — `Lingvamyxa_spec.txt`, 3105–3105.

````text
    print: 1 + 2
````

**Adapted example** — `Lingvamyxa_spec.txt`, 3140–3140.

```lmx
print: {a + b}
```

<a id="bounded"></a>

## 14. Bounded forms: brackets

Sources: §§4.4, 4.5.2.1, 15, revised by the author's decisions of 2026-11-09.

`{...}` bounds a Structure, including a description or an expression Structure; empty `{}` is allowed. `{a + b}` retains its expression fields and explicit outer Structure in P0. A named description `name{...}` has a head and a brace-delimited body. `arr{ (): @}` is therefore a bounded named Array declaration, not an index operation.

A standalone `(...)`, including `(1)`, `(i: 1)`, and `()`, is an alternative spelling of the anonymous Structure `{...}` with the same admitted contents. Attached right after a preceding target, the same round bounded form is the common compact application form, which P0 marks as a call form: a method call, an ordinary-Structure execution, an Array index, or a receiver application with the meaning of its colon form (`int(5)` is `int: 5`). `f(): args` and the block `f():` are the rarely needed additional layout of the same call. `f()` has no argument fields and carries the call mark; the short `f: ()` ended by a line break and a return to the previous level is not a call but the same empty Structure as `f{}` and `f: {}` ([§18](#empty-colon)). The call mark preserves this difference.

`(): value` is a symbolic-head Frame whose head is `()`. It is the current Array-construction form, as in `arr: (): int` or `arr{ (): @}`. The lexer/parser recognizes the complete symbolic head followed by `:`; it does not turn it into an empty round Structure followed by a write. The former Array head `[]:` and former square index suffix are not current Array forms; square brackets now delimit Mix.

The same short forms, separators, and levels apply inside round and brace-delimited forms. A matching `)` or `}` completes that bounded form and any short form still open inside it. It does not remove a non-empty anonymous container. After a physical newline, a continuation of either form must remain deeper than the opening line: at the corresponding dotted level or a deeper indentation column. A line whose next token is the matching closer may return to the opener level. `end:` and terminal closers do not replace missing delimiters.

Square Mix forms follow [§19](#mix): their contents are parsed in a local level-0 context, and the opening column does not become an indentation base. Their matching closer is `]`; a bracket inside shielded content does not close the form. The opening-line indentation rule for round and brace-delimited forms does not replace this Mix rule.

Indexing by the unprefixed round suffix is admitted for an Array target, as in `arr(1)`. A method target in `f(1)` is called; an ordinary Structure target in `s(data)` is executed with Structure `data`. Direct positional Structure selection is written `struct\(index)`, with an explicit backslash; `struct\(index)field` is the distinct named-occurrence selector. P0 preserves the written suffix and optional path name without consulting the target's type or a method signature. This does not reinterpret ordinary `s(1)` as an index. Contents use the same P0 and may contain nested calls, paths, expression Structures, strings, and operators.

**Current examples.**

```lmx
{a b c}
{}
(1)
(i: 1)
f()
f: ()
arr: (): int
arr{ (): @}
print: {a + b}
```

**Current multiline actual-argument example.**

```lmx
f(
. 1
. i: 2
)
```

<a id="levels"></a>

## 15. Source levels and indentation

Sources: §§4.2–4.6, 15.0 of the former specification.

### One stream of structural events

A source level is a position in the tree being built, not the language level L1/L2/L3 or an indentation number detached from the rest of the syntax. P0 reads a stream of items and structural events. Colons, brackets, separators, newlines outside shielded literals, and visible markers participate in one model; they do not start independent grammars. A physical line is an input fragment, not a tree container. Several nested Frames can therefore occur on one line, and one Frame can continue over several lines.

The canonical leading zone contains dots, spaces, and tabs; the dot count gives the absolute level, while spaces and tabs do not affect depth. In relaxed notation, an indentation-column stack maps to the same integer levels. The first deeper column creates one next level regardless of the number of added spaces. Dotted delimiters remain valid in relaxed notation. Both spellings describe one tree, not two ways of deciding body ownership.

### An increase opens; a cut completes

| Level event | Structural action |
| --- | --- |
| K → K + 1 | Open a Structure field under the current parent. |
| K → K | The next sibling, subject to the open short or bounded context. |
| K → K − 1 | Complete the current vertical Structure before reading the next item at its own level. |
| Increase exceeding one level | Invalid jump; inline nesting cannot replace a missing visible level on the next line. |
| Decrease exceeding one level | Not an ordinary cut: an admitted tail cutter is required. |

These are universal structural actions, not special rules for `if`, `match`, calls, or declarations. An increase explicitly requests a nested Structure field; a scalar item does not become its named head merely because deeper indentation follows. An ordinary cut completes the open field without turning the following item into a special closing receiver. For example, a sibling declaration closes the preceding Frame by its level, not by its declaration semantics. Naming a Frame does not require `end:`.

The “head — primary body Structure — trailer” envelope describes opening, contents, and completion. A trailer is a completion event, not a mandatory source word. The head and structural close are not appended as ordinary fields of the primary body. Terminal receiver roles and preservation of their executable action are defined in [§17](#close).

### Short forms and the next physical level

`f:` at level N opens an argument Structure at implicit level N + 1. Inline fields live inside it. Whitespace and comma separate fields without changing the level; semicolon completes the current short form at its scan depth. After an existing inline tail, the down/up transition to vertical children preserves a new Structure-field boundary instead of flattening all tokens into the tail ([§10](#frames)).

A newline in an open short form resets the counter to the level of **the physical line that just ended**, not to the deepest head written inside its tail. Inline nesting does not carry its implicit level across a newline. The next leading zone supplies the next visible level; an increase from the completed physical line's level can be only one step. The number of colons on the preceding line therefore does not permit skipping several levels on the next line.

The newline itself is a separator, not a trailer. It means neither unconditional closure of all Frames nor preservation of the deepest inline body through any following line. The next level, visible marker, and open context determine ownership of the next item. The asymmetry is intentional: an increase opens a Structure, whereas completion requires a visible next item/marker, `;`, a matching bracket, or an admitted tail cutter.

The following two spellings have different structures:

```text
r:
. twice:
. . 3
---
```

Consecutive physical levels 0 → 1 → 2 explicitly place `3` in `twice`'s body and `twice` in `r`'s body. This describes syntactic ownership of fields, not a decision to execute the heads.

```text
r: twice:
. ---
. . 3
---
```

The marker is written at level 1, in `r`'s body. It completes the empty short form `twice` and, with the following level 2, opens **an anonymous sibling field under r**, not a continuation of `twice`'s body. The body of `r` has two fields: the empty Frame `twice` and a separate anonymous Structure containing `3`. P0 does not move a field into `twice` to satisfy a signature or an expected argument count. Only the first spelling agrees with `r: twice: 3` and `r: twice(3)` in the ownership of `3`.

### Visible markers and closing scope

Anonymous sibling sections at the same level require a visible marker: without a smaller level between them, indentation does not show their boundary. A dotted line or `---` materializes **its own** level K, not the level of the last inline head. When children at K + 1 follow, the marker opens an anonymous Structure at K; the same marker may close the preceding section and open the next. It is not a call and carries no arguments ([§16](#markers)).

An ordinary one-level cut requires no explicit closing word. A deeper close uses an admitted tail cutter: `end: target`, a fence, or a terminal form in its admitted position. A body-level `return` does not become a universal tail cutter by spelling; terminal `return` closes its own executable definition in the position described in [§17](#close). A tail cutter does not close unmatched `(`, `{`, or `[`.

### Brackets, literals, and empty lines

Within a round or brace-delimited form, a newline itself neither closes the delimiters nor performs the short-form step outwards. Continuation stays inside that bounded context; returning to the opening line's level before the matching closer is permitted only for the matching closer itself ([§14](#bounded)). Square Mix forms use their own local level-0 context under [§19](#mix); the opening column does not become their indentation base. Newlines inside shielded strings, exact identifiers, and other lexical payload do not produce outer level events ([§24](#automaton)).

An empty physical line outside shielded payload is a separate level-0 boundary event. It may close a level-1 tail by ordinary decrease but does not replace a visible delimiter between anonymous sibling sections at deeper levels. Such an empty line must not be confused with a single newline character between two non-empty items.

**Correct consecutive transitions** — `Lingvamyxa_spec.txt`, 3085–3088.

````text
ShortForm1: 1
. ShortForm2: 2
. . ShortForm2_arg2
. ShortForm1_arg3
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3417–3421.

````text
    .                               # head: open anonymous positional Structure
    . . body1                       # body
    .                               # trailer of previous + head of next anonymous Structure
    . . body2                       # body
    .                               # trailer
````

**Adapted example** — `Lingvamyxa_spec.txt`, 3428–3432; the declarations use the form `name: fn: return args` with the arguments in an anonymous round Structure. The terminal `return` at level 0 closes several levels at once.

````text
outer: fn: int ()
    inner: fn: int (a: int)
        return: a + 1
    a{ int: 1}
return: inner(a)
````

<a id="markers"></a>

## 16. Dotted delimiters and dash fences

Sources: §§4.5.1–4.5.3.

A dotted line contains only a leading zone with at least one dot and an admitted comment. At level K it denotes an anonymous Structure when children at K + 1 follow; otherwise it separates or closes the section. One marker may close the preceding anonymous Structure and open the next. Anonymous sibling sections at the same level require a visible marker.

A fence of 3–80 dashes after the leading zone has the same role. Only horizontal whitespace and a `#` comment may follow it. It calls no receiver, has no argument, and cannot prefix `else:`, `return:`, or another item. On a decrease, it admits closing several open levels down to its own level K; a following K + 1 item may open a new anonymous Structure.

An anonymous Structure continues until another marker at K, an ordinary item at K − 1, an admitted named/terminal close, or EOF. Replacing a named close with a fence depends on profile admission and lack of ambiguity. Matrix rows and nested arrays use the same rules, without separate table syntax.

An explicitly formed empty vertical body yields a Frame with an empty Structure-body and its recorded closure: zero fields, the same empty Structure as `f{}` and the completed short `f: {}` or `f: ()`. It is not a call, unlike `f()`, which P0 marks as a call. This does not authorize removing any explicit non-empty anonymous field. Bare `f:` without arguments or explicit closure remains invalid. See [empty bodies](#empty-colon).

**Source excerpt** — `Lingvamyxa_spec.txt`, 3496–3504.

````text
match: value
.
. . 1
. . print: World
.
. . 2
. . print: Hello
.
end: match
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3623–3630.

````text
match: value
    ---
        1
        print: World
    ---
        2
        print: Hello
---
````

<a id="close"></a>

## 17. Named closure and terminal forms

Sources: §§4.6, 7.5, 8.1–8.4, 15.

`end: target` is a checked structural close. Its argument is a literal target, not an evaluated expression. The receiver supplies admitted targets: normally its head name and the canonical name from a `name` argument or name position. The name must be one admitted atom; exact spelling is compared as an atom value. With no valid name, the head is used. The close-target table may admit string/operator atoms as well as executable identifiers.

`end: matrix` closes the Array-head form `(): matrix`; not `end: () matrix`. A bounded named description such as `matrix{...}` still requires its matching `}`. `end: fn` may be an alternative to `end: square` for the corresponding open function. Closure may cross several open implicit levels where position and profile admit it, but not unmatched bounded brackets. A named Frame does not require explicit `end:`: an ordinary admitted level cut also closes it. As in Python, levels need not be closed; the general means are needed only to close several levels, and most often a terminal `return` serves as the trailer while keeping its executable action ([the author's reminder of 2026-11-09](../LMX_blog/2026-11-09.md)). Bare `end` and `end <target>` are forbidden.

`return`, `return: value`, and `until: condition` are terminal-form candidates only in admitting contexts. Terminal `return` at the opening level of a named executable Structure, including an ordinary Structure without `fn`/`sub`, appends a return to its body and closes its Frame. The same receiver at body level or deeper is an internal return, not definition closure. `until:` may close a postcondition-loop body: an anonymous body closed by `until:` is an inline postcondition loop in the enclosing activation, and a named Frame closed by `until:` is an ordinary named Structure whose executable body is that loop — declaring it does not run it; only an explicit invocation such as `outerLoop()` does. No construct requires any of these trailers: they are P0 boundaries, not a condition of declaration. A named Structure closed by an ordinary level cut is declared by the same general resolution ([L3 §9](new_LMX_semantics.en.md#construction)); reaching the end of the body of a named Structure or a `sub` completes it without a result, and no return is synthesized there. Their spelling alone does not make these words universal tail cutters.

When identical targets occur at different levels, the closing line’s level participates: a parent-level close selects the parent target and cuts its open tail; an inner-level close selects the inner target. Ambiguous, invisible, or positionally invalid targets are rejected. `end:` in an ordinary body position is not executable and is rejected by close validation unless a profile explicitly defines another non-runtime meaning.

**Adapted example** — `Lingvamyxa_spec.txt`, 6622–6623; the declaration uses the form `name: fn: return args` (2026-11-09), with the arguments written as an anonymous round Structure.

````text
square: fn: int (x: int)
return: x * x
````

The terminal `return` at the opening level appends a return to the body of `square` and closes its Frame under the rule above.

**Source excerpt** — `Lingvamyxa_spec.txt`, 6393–6398.

````text
if: condition
    bodyCall()
end: if
else:
    fallbackCall()
end: else
````

<a id="empty-colon"></a>

## 18. Missing arguments and an empty vertical body

The correction of 2026-11-09 replaces the former generic P0 normalization rule. The former rule was a **gross error**: a non-empty anonymous container cannot be removed merely because it is the only field.

A Frame's body is itself a Structure. Every explicit non-empty anonymous Structure inside that body remains a separate field. P0 does not unwrap it, whether it is round, brace-delimited, the only field, or one of several fields. The same invariant holds outside invocations, including descriptions, data, expression grouping, arrays, and Mix. Expanding an empty Structure in P0 is not an error ([the author's clarifications of 2026-11-09](../LMX_blog/2026-11-09.md)); the general level rules determine the resulting tree.

Only function/method invocation semantics may consume a sole supplied anonymous Structure as the actual-argument Structure. A computed Structure supplied as the whole argument Structure is likewise an invocation-semantic case. This consumption operates on the retained tree; it is not a destructive normalization pass and does not change the number of syntactic fields. It is not a general rule for ordinary-Structure `data` or Array indexing.

| Source | P0 result | Function/method invocation consumption |
| --- | --- | --- |
| `f()` | Compact Frame with an empty argument body and the call mark | No actual arguments |
| `f{}`, and the short `f: {}` and `f: ()` ended by a line break and a return to the previous level | An empty Structure `f` with zero fields; not a call | None: not a call |
| `f:` with an empty block body, for example `---` or `end: f` on the next line | The same empty Structure; the close adds no empty child field | None: not a call |
| `f: {}` followed by `end: f` | A block `f` whose only field is an empty Structure (`f{{}}`) | None: not a call |
| `f(a b)` | Compact Frame with fields `a` and `b` and the call mark | Two actual arguments |
| `f({a b})` | Compact Frame containing one anonymous Structure with fields `a` and `b`, with the call mark | The supplied Structure may yield the actuals `a` and `b` |
| `f: (a b)`, `f: {a b}` | Colon Frame containing one anonymous Structure with fields `a` and `b` | None: not a call |

These rows follow from the general rules of levels and of how short and block forms end, not from a name-based parser exception, a special block node, or a rule that `end` always adds a wrapper. A call is written only in the round form after a name. P0 must not consult the eventual consumer in order to erase the call mark. An anonymous Structure among other fields or a named field remains distinct during ordinary argument collection; no recursive parser flattening is permitted.

The round compact form is explicit application syntax. Resolution determines whether the target is a method, an ordinary executable Structure, an Array, or a receiver written in round form with the meaning of its colon form. `f(): args` and the block `f():` are the rarely needed additional layout of the same call. A bare name remains an atom and reads its resolved value or reference without executing a Structure. Ordinary Structure execution is written `s()` or `s(data)` with Structure `data`; `call` is removed, and `code()` is the former `call(code)`. Ordinary Structures have no formal argument lists, so their data contract must not be confused with method actual-argument expansion.

P0 rejects bare `f:` without arguments, a vertical body, or an explicit `---`. An empty inline tail followed by a nonempty vertical body is valid. An explicitly closed empty vertical body has no extra anonymous field unless one was actually written. Bare `end` remains forbidden.

**Current examples.**

```lmx
f()

A{}
A: {}
A:
---

A: {}
end: A
```

The first record is a call with an empty body. The next three are one and the same empty Structure `A`: the short form `A: {}` ends with a line break and a return to the previous level, and the block `A:` is closed by `---` with an empty body. The last is a block `A` whose only field is an empty Structure (`A{{}}`).

<a id="mix"></a>

## 19. Square brackets and Mix anchoring

Sources: §§0.0.2, 3.4.4.4, 15.0.

`[...]` is a bounded Mix form. Outside a shielded literal/comment, `[` enters the same P0 in a local level-0 context; the opener column does not become the indentation base. Ordinary quotes, comments, levels, and nested forms apply inside. A `]` within shielded content does not close the outer form. The result is immediately retained as a Structure node with a Mix flag and source span. Internal newlines do not produce outer level events.

Inline or tail Mix belongs to the current field sequence. Leading Mix before an ordinary item is placed before it at that item's level. In relaxed notation, prefix width may occupy part of indentation; in dotted notation, dots still determine the level. Column-0 lines containing only Mix forms are queued in order and anchored to the next ordinary item, or to the current/document-end context at EOF. Other standalone Mix lines use ordinary levels.

An ordinary consumer may skip Mix nodes; a document consumer may build intervals. This is not automatic execution or substitution. The outer string payload is delimited first; its internal marks are then considered in their own bounded context. They must not alter the outer string's bounds or enter its surrounding active index. The presence of marks does not change the original string value.

**Adapted example** — `Lingvamyxa_spec.txt`, 212–213.

````text
    item: [color: red] value
    item: value [color: red]
````

**Adapted example** — `Lingvamyxa_spec.txt`, 218–218.

````text
    [color: red]    item: value
````

<a id="mix-overlay"></a>

## 20. Spelling intersecting marks

Source: §0.0.2. This section retains the Mix document-profile rules needed to read the examples; it does not define the new executable kernel's semantics.

`[color: red]` opens an entry with head `color` and close value `red`. `[end]` closes the latest active explicit mark; `[end: name]` closes the latest active mark with that close value regardless of head. Closing one mark does not close later marks with other values, so intervals can intersect. Duplicate values are selected latest-first. Unclosed entries remain tracked until the document/profile boundary; diagnostics or an interval extending to the end are profile choices.

P0 does not reduce active entries to one flat table of winning values. A renderer may choose the latest value, but the full chain/set retains the others. Internal string marks have their own isolated context. `[end]` belongs to this Mix profile; the ban on bare `end` in ordinary LMX source must not be mechanically applied to it.

**Adapted example** — `Lingvamyxa_spec.txt`, 253–257.

````text
    [color: red]
    [color: green]
    text
    [end: red]
    [end: green]
````

<a id="operators"></a>

## 21. Operator tokens and expression boundaries

Sources: §§4.2.2, 4.7, 6.1–6.4, 20.3, revised by the author's decisions of 2026-11-09.

Operation characters are not bare identifiers. P0 splits compact unquoted spellings such as `a+b*c=d` into ordinary fields and operation tokens. Exact identifiers are not split. An operator field is not by itself a named head and does not require a colon.

An expression is a Structure containing its ordered expression fields. `{a + b}` explicitly bounds such a Structure. P0 preserves its fields, nested containers, and source spans; operator roles, precedence, and evaluation belong to the later expression profile. The label `ExpressionStructure` in §26 describes this use of Structure and does not introduce a second representation or a fixed operator ABI.

The established expression profile includes brace grouping `{expr}`; prefixes `@`, `\`, `++`, `--`, `+`, `-`, `!`, `~`; postfixes `++`, `--`; infixes `+`, `-`, `*`, `/`, `%`, `=`, `!=`, `<`, `<=`, `>`, `>=`, `&&`, `||`, `&`, `|`, `^`, `**`; and the round application/index suffix. Writing a prefix adjacent to its operand is style, not a mandatory P0 boundary.

`=` is comparison only. `!=`, `<=`, and `>=` remain comparisons. Assignment uses `:`, including an addressed destination such as `arr(2): value`; named actuals use the same colon form, for example `f(i: 1)`. The former `:=` operator is removed. A simple `a: 5` is retained as a colon Frame; declaration, assignment to an existing place, and named actual supply are roles determined by its context and consumer. P0 does not invent a separate named-argument tree or infer a declaration from the identifier's availability.

The compound-assignment tokens are `+:`, `-:`, `*:`, `/:`, `%:`, `<<:`, `>>:`, `&:`, `^:`, `|:`, and `**:`. Each is one token: `a+:b` and `a +: b` have the same left side, compound token, and right side. The final colon is part of that token, not a separate Frame opener. The older `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, and `**=` are not current assignment spellings. The tokenization rule must distinguish `**:` from `**` followed by a separate colon.

`**` groups to the right and binds tighter than `*`, `/`, `%`, `+`, and `-`, but looser than application, indexing, and field access. On its left it binds tighter than unary `+`, `-`, and `~`; on its right it admits a unary operand. In the current grouping notation, `-2 ** 2` is `-{2 ** 2}`, `2 ** -2` is `2 ** {-2}`, and `2 * 3 ** 2` is `2 * {3 ** 2}`. `^` remains bitwise exclusive or.

Assignment precedence and associativity beyond the stated structural rules, effect ordering, conversions, and runtime failures are semantic matters not invented here. P0 must implement the current spellings and preserve their source spans; this document does not claim that the required implementation work has already been completed.

A comma still does not close a short tail opened by `:`. Two neighboring named actuals are written `f(x: 1; y: 2)`. In `f(x: 1, y: 2)`, the latter Frame remains inside the open tail of `x:`; P0 does not reinterpret it as a neighboring actual according to a signature.

**Current examples.**

```lmx
i: 1
arr(2): value
i +: 1
mask &: allowed
power **: 2
print: i = 1
print: {1 + 2} * 3
```

<a id="paths"></a>

## 22. Address, index, and path forms

Heads `@:`, `@@:`, `@@@:`, and further depths share one structural form. `ptr: @: 0` and `ptr: @: Model` put the place name outside the receiver and its single address/reference operand inside. Unary `@: ptr` remains admitted. The former two-argument pointer-receiver interpretation is removed from the semantic and implementation branches; it must not survive as a compatibility path. P0 neither reorders operands nor invents a receiver-specific argument order. Typing, declaration, assignment, and rejection of a removed built-in form follow construction of the complete Frame.

Prefix `@x` and `\x` differ from heads `@:` and paths `x\field`. Field and index chains bind tighter than prefix operators. Expression grouping uses curly braces: `{\ptr}()` invokes the explicitly dereferenced target; `\ptr()` applies `\` to the result of the application under the ordinary precedence rule.

The Array forms `a(i)(j)(k)` and `a(i)\(j)\(k)` retain their meanings: the first addresses a multidimensional Array, and the second follows references to separate Arrays. The explicit backslash-index path form also admits direct Structure selection as described below. Its syntax is parsed without type- or name-specific branches; semantic admission determines the operation on the resolved target.

### Direct Structure selection and named occurrences

`struct\(index)` directly selects the element at the zero-based position `index` among all immediate fields of that Structure. No field name is required. It does not search descendants, count only fields of one name, or execute the selected element merely by selecting it.

`struct\(index)field` retains the other meaning: select the zero-based `index`-th source occurrence of the specific root-level head `field:`. The index here counts occurrences of that head, not the overall immediate-field positions. Bare `struct\field` is admitted only when that head has one such occurrence. This occurrence-selector rule does not change the existing admission rules for duplicate data fields.

The optional path name uses the existing path-token and field-boundary rules. It is not captured according to a receiver signature or the target's runtime category; an independent following field stays independent. This revision introduces no new whitespace rule. P0 preserves the written path and optional name. Fields do not use C `.` or `->`.

| Form | Meaning |
| --- | --- |
| `struct\(index)` | Immediate Structure element at overall zero-based position `index` |
| `struct\(index)field` | Zero-based occurrence `index` of the root-level head `field:` |
| `struct\field` | The sole admitted root-level occurrence of `field:` |
| `f(1)` | Method invocation with actual argument `1` |
| `arr(1)` | Array index `1` |

For method `f`, the immediate parts are ordered `{return args var body}` (return first, the author's decision of 2026-11-09). Therefore `f\(0)` selects its `return` Structure and `f\(1)` its `args` Structure. It does not invoke `f` or select the value that executing `f` might return. Direct execution of an ordinary Structure remains `s()` or `s(data)`, with Structure `data` and no formal argument list. A numeric argument such as `s(1)` is not reinterpreted as an index and does not satisfy this Structure-data requirement.

**Current direct-selection examples.**

```lmx
struct\(index)
struct\(index)field
f\(1)
```

### Array representation remains available

A Structure can also be represented by an Array of void references, declared as `arr: (): @` or in the bounded named form `arr{ (): @}`. Access through that Array remains available alongside direct backslash-index selection; it is no longer the only route to a Structure's elements.

**Retained Array-representation example.**

```lmx
arr{ (): @}; arr: f; arr(1)
```

For a method `f`, its representation slots follow the same `{return args var body}` order. The final `arr(1)` returns the reference to `f`'s `args` Structure, which is also selected directly by `f\(1)`. The assignment `arr: f` supplies the Array representation of `f`; this syntactic rule does not choose an aliasing, copying, or ownership implementation.

| Position | Method part | Direct selection | Array access after `arr: f` |
| ---: | --- | --- | --- |
| 0 | `args` | `f\(0)` | `arr(0)` |
| 1 | `return` | `f\(1)` | `arr(1)` |
| 2 | `var` | `f\(2)` | `arr(2)` |
| 3 | `body` | `f\(3)` | `arr(3)` |

`typeof(p)` accepts a pointer and returns the code of the type arena of its target object. Thus `typeof(arr(index))` uses the reference stored at the selected Array slot; it does not report only the carrier type `@` or use the element index as an arena code. For `arr(1)` in the retained method example, the target is the `args` Structure, so `typeof(arr(1))` reports that Structure's type-arena code, not the type of a value returned by executing `f`. Concrete arena-code values and rules for invalid pointers are not supplied by the grammar.

**Source excerpt** — `Lingvamyxa_spec.txt`, 7458–7460.

````text
    @
    @@
    @@@
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 8215–8215.

````text
    result\harvest
````

<a id="foreign"></a>

## 23. Explicit C surface and profile boundaries

Sources: §§6.6.6, 20.2.2–20.3.

`c.name` is an explicit C-surface form, not an ordinary LMX field. A compact token beginning with `c.` continues to an LMX boundary: horizontal space, newline, `,`, `;`, `(`, `)`, `{`, `}`, `[`, `]`, `:`, comment start, or item end. Dotted continuations remain C surface; calls and indices use round bounded forms in the common LMX stream. Brace grouping and named descriptions follow the current LMX rules. Raw C text explicitly passed as a string is not rewritten by these surface rules. Names following `c.` pass through the common raw C door; particular C names have no separate registration or special parsing ([L2](new_L2_spec_en.md#lowlevel-abi)).

In an evaluated call, C functions and macros receive already evaluated L2 values, not L2 expression text for substitution. Literal `c.sizeof` has the role of a C operator rather than a function call; expanding an arbitrary macro into `sizeof` does not give it this role. This is a semantic distinction after common expression preparation, not special parsing of a C name; the evaluation contract is specified in [L2 §20](new_L2_spec_en.md#lowlevel-abi) (author clarification of 2026-10-22).

Type heads such as `int`, `char`, and `size_t` do not require `c.`. An unresolved ordinary name does not automatically become a C name. `c.` is not universal declarator, label, or C-tag syntax. `C:` separately accepts explicitly supplied string text; a string does not become code merely by appearing within `L1:`, `L2:`, or `L3:`.

The file extension selects the outer profile, and the file itself is a Structure ([semantics](new_LMX_semantics.en.md#scope)). In L2/L3, `L1`, `L2`, and `L3` do not select a profile and resolve as ordinary names; a container with one of these names is neither erased from the source tree nor executed in place of the root. The previous direct L1 profile takes wrapperless `.lm1` input ([L1](new_L1_spec_en.md#scope)). The historical outer `L2:` wrapper does not establish automatic profile selection and is omitted from the adapted example below. A catalog of library receivers is not grammar.

**Source excerpt** — `Lingvamyxa_spec.txt`, 5150–5150.

````text
    c.name
````

**Adapted example** — `Lingvamyxa_spec.txt`, 5196–5198.

````text
c.boxes(1).value: 7
return: c.boxes(1).value != 7
````

<a id="automaton"></a>

## 24. The single P0 automaton

Source: §15.0, revised by the author's decisions of 2026-11-09. This is the normative recognition model, and the EBNF below is its projection.

`P0 = (S, E, delta, O)`. State S contains source position/span base, lexical mode, normalized level, form stack, and output insertion cursor. Modes are `SOURCE`, `C_STRING`, `EXACT_IDENTIFIER`, `PYTHON_RAW_QUOTE`, `BLOCK_STRING`, `RAW_COMMENT`, and `LINE_COMMENT`. Stack forms are the level-0 root, vertical form K, short head N with body N + 1, round argument/application or indexed-path forms with base B, brace-delimited Structure/grouping or named-description forms with base B, and square Mix forms with local base 0.

Events E are `LEVEL(K)`, `ATOM(value)`, `HEAD(value)`, `COLON`, `NEWLINE`, `COMMA_SEPARATOR`, `SEMICOLON_SEPARATOR`, operator tokens, opening/closing round, brace, and square Mix delimiters, a `TAIL_CUTTER` candidate, and `EOF`. A compound-assignment token containing `:` is one operator event; it does not generate a separate `COLON`. The symbolic Array head `()` followed by `:` is recognized as a head, not as an empty anonymous field.

Transitions follow the preceding sections. There is no separate P0 line, bracket, brace, or expression parser: all bounded forms enter recursive contexts of the same automaton. An attached round form has one syntactic shape, and P0 marks it as a call form; the layout `f(): args` and the block `f():` carry the same mark, and a colon Frame never does. P0 does not inspect the target type to choose between method invocation, ordinary-Structure execution, Array indexing, and a receiver applied in round form. A named brace form is a description, not an index suffix. The explicit `\(index)` path suffix retains its optional following path name; P0 neither invents that name nor selects the path interpretation using the target's type or a signature. No-name Structure paths select immediate fields; named paths select occurrences of the specified head under §22.

In a shielded lexical mode, brackets, separators, colons, dots, and closer words are content until the mode closes. Matching-delimiter search must use those same modes; a separate character counter is insufficient. Passive mark inspection within an already delimited string payload is a separate bounded context, not removal of this shielding.

EOF completes the root after all forms admitting EOF closure. Unclosed bounded forms or lexical modes remain errors. Output O retains Structures, including expression Structures, Frames, paths with their optional names, delimiter and closure kinds, atoms, Mix flags, and spans. P0 does not execute code, resolve functions, assign types, or remove explicit non-empty anonymous containers; expanding an empty Structure is not an error ([§18](#empty-colon)). Every close operation must preserve a sole non-empty anonymous child exactly as it preserves one among several children. Argument expansion, when admitted, is performed later by function/method invocation semantics without rewriting O.

<a id="ebnf"></a>

## 25. Surface-form EBNF

The following is the current EBNF projection of this revision. It replaces the former historical notation; EBNF metacharacters are not LMX source characters. In particular, unquoted `[ ... ]` means an optional part, and `{ ... }` means repetition. Quoted `"{"` and `"}"` delimit an ordinary Structure; `"["` and `"]"` delimit Mix. EBNF metacharacters do not change with the language's bracket roles. Explanatory text inside the notation is not a language token.

Read the EBNF together with the automaton in §24, lexical modes, short-tail rules, and source-level rules. `name`, `atom_or_value`, `symbolic_head`, `place_expression`, and `profile_path` denote common-stream forms described above, not arbitrary characters or signature-based parsing. A bare short form `f:` with no arguments, vertical body, or explicit closure is invalid; an explicitly closed empty body is valid. A bare identifier is an atom, not an implicit nullary call.

`compact_frame` describes the common attached round form; P0 marks it as a call form. After P0 it is consumed as a method call, ordinary-Structure execution, an Array index, or a receiver application with the meaning of its colon form, according to the resolved target object. These are not different grammars. `call_layout_frame` is the rarely needed additional layout of the same call: `f(): args` or `f():` with a block on the next level. `colon_frame_body` forms no call. `index_access_suffix` names a role of the same `round_suffix`, not a competing parse. Without a backslash this suffix does not index a Structure. Direct Structure access is written as the path `s\(index)` through `indexed_path_suffix`; `s\(index)field` preserves the field name when it is written as part of the path.

`named_description` is a bounded description with a head, such as `arr{ (): @}`, and is not indexing. `argument_structure` without an identifier is an alternative spelling of the anonymous Structure `bounded_structure` with the same contents. Non-empty `argument_structure` and `bounded_structure` remain distinct nested fields, even when such a field is the only field; P0 never expands them into their parent's sequence, and expanding an empty Structure is not an error ([§18](#empty-colon)). Invocation arguments are prepared only after parsing, without rewriting the source tree. An expression is also a Structure: its fields and nested containers are retained, while operator roles, precedence, and evaluation are determined by the expression profile after P0.

````text
    program             ::= { empty_line | physical_item }

    physical_item       ::= raw_file_comment_block
                          | block_string_literal
                          | logical_line

    raw_file_comment_block
                        ::= raw_comment_fence(N) trailing_horizontal_space newline
                              raw_ignored_line*
                            raw_comment_fence(N) trailing_horizontal_space newline
                            where 3 <= N <= 80

    raw_comment_fence(N)
                        ::= exactly N "*" characters at column 0

    block_string_literal
                        ::= block_string_fence(N) trailing_horizontal_space newline
                              block_string_content_line*
                            block_string_fence(N) trailing_horizontal_space newline
                            where 3 <= N <= 80

    block_string_fence(N)
                        ::= exactly N "=" characters at column 0

    trailing_horizontal_space
                        ::= { " " | tab }

    horizontal_space    ::= " " | tab

    logical_line        ::= source_level line_content newline

    indentation         ::= { "." | " " | tab }

    source_level        ::= integer source level assigned by the
                            source-level normalization prepass

    source-level normalization prepass:
                            maps the physical source spelling to item/level
                            events; it never removes Structure containers;
                            in canonical dotted notation the level is the
                            count of leading dots; relaxed indentation uses
                            the indentation-stack rule.

    empty_line          ::= trailing_horizontal_space newline
                            level-0 structural boundary event;
                            closes an open level-1 vertical tail by ordinary
                            source-level decrease, but is not a same-level
                            delimiter below level 1

    line_content        ::= dot_only_marker [ comment_body ]
                          | comment_body
                          | disabled_body [ comment_body ]
                          | line_item_sequence [ comment_body ]

    dot_only_marker     ::= empty content after indentation
                            valid only if source_level > 0;
                            may delimit/open an anonymous Structure at that level

    comment_body        ::= "#" ignored_until_newline

    disabled_body       ::= "%" enabled_line_body
                            the item-initial disabling marker is recognized
                            under the lexical context rule of section 9

    enabled_line_body   ::= line_item_sequence

    compact_frame       ::= postfix_target round_suffix
                            P0 marks it as a call form; after P0 it is a call,
                            ordinary-Structure execution, an Array index, or
                            a receiver application with the colon-form meaning

    round_suffix        ::= "(" [ argument_list | vertical_argument_list ] ")"
                            written immediately after its target; the contents
                            admit everything admitted inside "{" "}",
                            including blocks

    call_layout_frame   ::= postfix_target "(" ")" ":" [ line_arguments ]
                            the rarely needed additional layout of the same
                            call postfix_target(args): the inline tail and the
                            following vertical children at N+1 form its
                            argument Structure under the level rules; P0 marks
                            it as a call; it is distinct from symbolic_head ()

    named_description   ::= name "{" [ argument_list | vertical_argument_list ] "}"

    indexed_path        ::= postfix_target indexed_path_suffix

    indexed_path_suffix ::= "\" round_suffix [ path_field_name ]
                            the optional name is present only as a written
                            continuation of this path under existing path
                            boundaries; a separate following field/argument
                            is never captured according to a signature

    path_field_name     ::= name
                            for a Structure target, omitting this name selects
                            an immediate field in overall zero-based order;
                            including it selects the zero-based source
                            occurrence of that named head; the same suffix
                            retains existing Array/reference-path semantics

    postfix_target      ::= name
                          | symbolic_head
                          | bounded_structure
                          | compact_frame
                          | indexed_path
                          | profile_path
                          | atom_or_value
                            a written target expression, independent of its
                            resolved type; grouped targets include {\ptr};
                            profile_path covers the other existing path forms

    line_frame          ::= source_level line_item_sequence newline

    line_item_sequence  ::= source_item
                            { semicolon_segment_separator source_item }
                            [ semicolon_segment_separator ]

    source_item         ::= call_layout_frame
                          | colon_frame_body
                          | structural_value

    colon_frame_body    ::= head ":" [ line_arguments ]
                            inline tail and following vertical children at
                            N+1 form the assembled body under the level rules;
                            no written non-empty child container is flattened;
                            zero fields require an admitted explicit empty
                            closure or a valid explicitly formed empty body;
                            bare f: without such a body/closure is invalid;
                            a colon Frame is never a call, even for a callable
                            head; a short A: {} ended by a newline and a
                            return to the previous level equals A{}, whereas
                            A: {} followed by end: A is a block whose only
                            field is the empty Structure (A{{}}) under the
                            same general level rules

    semicolon_segment_separator
                        ::= ";"

    head                ::= name
                          | symbolic_head
                          | place_expression
                            includes written field/index/dereference targets;
                            arr(2): value is not restricted to an atomic name
                          | bounded_structure
                            a nameless Structure head, as in {a, b, c}: myFn();
                            its places are resolved after P0, and the received
                            Structure fills them by field names

    name                ::= bare_identifier | exact_identifier

    symbolic_head       ::= symbolic_head_token
                            includes the token () before the head separator :;
                            (): type is an array description/allocation form,
                            not an empty anonymous Structure followed by a value

    line_arguments      ::= short_tail

    short_tail          ::= short_field
                            { short_tail_field_separator short_field }
                            [ "," ]

    short_tail_field_separator
                        ::= horizontal_space+
                          | ","

    short_field         ::= colon_frame_body
                          | structural_value

    // Comma separates fields of the current tail and does not close it.
    // Semicolon closes the current short form at the current scan depth.
    // A physical newline is not a short-form trailer: subsequent level
    // events decide continuation and closure. Operator-token consumption
    // and expression precedence belong to the later expression consumer.
    // An expression is an ordinary Structure with ordered written fields,
    // including operator tokens and child Structures. No additional
    // expression-wrapper node or fixed operator/operand slots are implied.
    // There is no name-first two-operand primitive-receiver production
    // or fallback. A place name is written outside that receiver. General
    // multi-argument Frames for methods and other constructs remain valid;
    // receiver admission follows the common structural parse.

    argument_list       ::= bounded_item_sequence

    bounded_item_sequence
                        ::= bounded_item { bounded_item_separator bounded_item }
                            [ bounded_item_separator ]

    bounded_item_separator
                        ::= horizontal_space+
                          | comma_field_separator
                          | semicolon_segment_separator
                          | newline/source-level composition

    comma_field_separator
                        ::= ","

    bounded_item        ::= colon_frame_body
                          | structural_value

    // A comma inside an open short form still belongs to that form's tail.
    // A semicolon closes it before separating the next bounded item.
    // Continuation after a physical newline stays deeper than the opening
    // line. Only a line starting with the matching RPAREN/RBRACE may
    // return to the opener level. The matching closer also completes any
    // short form still open inside that bounded context.
    // Closing a bounded context preserves its node and all non-empty child
    // nodes; a sole non-empty child is never removed. Expanding an empty
    // Structure is not an error (section 18).

    bounded_structure   ::= "{" [ argument_list | vertical_argument_list ] "}"

    argument_structure  ::= "(" [ argument_list | vertical_argument_list ] ")"
                            without a preceding identifier: an alternative
                            spelling of the anonymous Structure bounded_structure
                            with the same admitted contents; not a call

    source_fragment     ::= P0 source parsed in a local level-0 context

    mix_structure       ::= "[" source_fragment "]"
                            parsed by the same P0 source/token rules and
                            retained as a Mix-flagged Structure node with its
                            matching RBRACKET; brackets in shielded payload
                            do not close the Mix form

    index_access_suffix ::= round_suffix
                            the same attached syntax as compact_frame;
                            an array target gives it its index meaning after P0;
                            this unprefixed suffix does not index a Structure;
                            direct Structure access uses indexed_path_suffix

    vertical_argument_list
                        ::= newline source_line { source_line }
                            each contained source_line follows the same
                            source-level rules as ordinary vertical composition

    structural_value    ::= compact_frame
                          | indexed_path
                          | named_description
                          | bounded_structure
                          | argument_structure
                          | mix_structure
                          | atom_or_value

    compound_assignment_token
                        ::= "+:" | "-:" | "*:" | "/:" | "%:"
                          | "<<:" | ">>:" | "&:" | "^:" | "|:" | "**:"

    // Each compound assignment is one token. Longest matching operator
    // spelling is selected before treating a colon as a separate separator.
    // Simple assignment and named binding use the common colon form;
    // there is no separate := operator. Comparisons =, !=, <=, >= remain.
````

<a id="normal-form"></a>

## 26. Structural-result EBNF

This is the current description of the parse result, not a second surface grammar or execution semantics. `Structure(...)` and `Frame(...)` denote result construction. The formal notation is identical in RU/EN; source spans and other retained attributes are omitted for brevity.

`FrameTrailer` is separate from argument fields. A comma separates tail fields; a semicolon first completes the short form at the current scan depth. Bounded closure, level transitions, and admitted named/terminal closure preserve their own completion causes. A named description `arr{...}` has a brace-delimited bounded trailer; an attached form `f(...)`/`arr(...)` has a round trailer. Their common parsing does not choose meaning from the target's name or type. Mix has a square bounded trailer and retains its existing Mix flag. `IndexedPath` describes the existing path form: it retains the target, the index Structure, and the explicitly written optional field name. That name is not reconstructed from the target's type or neighboring arguments.

**An expression is a Structure.** `ExpressionStructure` below denotes an ordinary Structure in the expression role, not a separate non-Structure object or an additional IR wrapper. `{a + b}` retains its explicitly bounded Structure node with ordered fields; P0 neither assigns fixed ABI slots to its operator and operands nor executes the expression.

**No result rule replaces a sole non-empty child Structure with its contents.** In the call `f(a b)` the Frame body has two fields; in `f({a b})` it has one field, an anonymous Structure. These are different source trees. Expanding an empty Structure is not an error: `f{}`, the completed short `f: {}`, and an empty block `f` yield one tree ([§18](#empty-colon)); `CompactFrame` carries the call mark. Any equality of the prepared invocation arguments is established by the subsequent semantic stage, which does not rewrite the P0 tree.

````text
    SourceFile
        ::= RootBlock

    RootBlock
        ::= Block(0)

    Block(K)
        ::= Structure({ BlockElement(K) })

    BlockElement(K)
        ::= FrameElement(K)
         |  ValueElement(K)
         |  ExpressionElement(K)
         |  AnonymousStructure(K)
         |  MixStructure

    FrameElement(K)
        ::= Frame(Head, BodyStructure, FrameTrailer)

    Head
        ::= BareIdentifier
         |  ExactIdentifier
         |  SymbolicHead
         |  ProfileHeadPath
         |  PlaceExpression
         |  BoundedStructure
         |  CompactFrame
         |  IndexedPath

    BodyStructure
        ::= Structure({ Field })

    Field
        ::= FrameElement(current)
         |  ValueElement(current)
         |  OperatorToken
         |  ExpressionElement(current)
         |  BoundedStructure
         |  ArgumentStructure
         |  CompactFrame
         |  IndexedPath
         |  NamedDescription
         |  AnonymousStructure(current)
         |  MixStructure

    ValueElement(K)
        ::= NumericLiteral
         |  StringLiteral
         |  BareIdentifier
         |  ExactIdentifier

    ExpressionElement(K)
        ::= ExpressionStructure

    ExpressionStructure
        ::= Structure({ ExpressionField })

    ExpressionField
        ::= Field

    IndexedPath
        ::= ProfileHeadPath(Target, IndexStructure, [PathFieldName])

    IndexStructure
        ::= Structure({ Field })

    CompactFrame
        ::= Frame(Head, BodyStructure, RPAREN_BOUNDED, CALL_MARK)
         |  Frame(Head, BodyStructure, FrameTrailer, CALL_MARK)
            the second alternative is the call layout f(): args or
            f(): with a block; the same call as f(args)

    NamedDescription
        ::= Frame(Head, BodyStructure, RBRACE_BOUNDED)

    BoundedStructure
        ::= Structure({ BoundedElement }, RBRACE_BOUNDED)

    ArgumentStructure
        ::= Structure({ BoundedElement }, RPAREN_BOUNDED)

    BoundedElement
        ::= FrameElement(bounded)
         |  ValueElement(bounded)
         |  OperatorToken
         |  ExpressionElement(bounded)
         |  CompactFrame
         |  IndexedPath
         |  NamedDescription
         |  BoundedStructure
         |  ArgumentStructure
         |  MixStructure

    MixStructure
        ::= Structure({ BlockElement(0) }, RBRACKET_BOUNDED, MIX_FLAG)

    AnonymousStructure(K)
        ::= Structure({ BlockElement(K + 1) })

    // All written non-empty child containers are retained, including a sole
    // one; an empty one may be expanded (section 18). The argument envelope
    // of a Frame is not an extra child field.
    // Invocation argument preparation is absent from the P0 result grammar.
    // MIX_FLAG denotes the existing Mix flag, not another wrapper node.
    // CALL_MARK is the P0 call mark of a round form written right after
    // its target (and of its f(): layout); a colon Frame never has it.
    // ExpressionStructure is the expression role of an ordinary Structure;
    // it does not add a second wrapper to a written bounded Structure.
    // P0 preserves its fields and containers. Operator roles, precedence
    // and evaluation are determined after P0, without a fixed slot layout.
    // OperatorToken is admitted directly in ordinary and bounded fields,
    // so {a + b} needs no nested expression wrapper to retain its operator.
    // IndexedPath preserves the written optional field name. For a
    // Structure target, an absent name selects an overall immediate-field
    // index. Existing Array/reference-path semantics remain available for
    // the same suffix. P0 never infers a missing path name from a target
    // type, arity or neighboring arguments.
````

<a id="fixtures"></a>

## 27. Original literal-boundary examples

Historical parser examples witness lexical boundaries, not independent rules. Current expectations are in the [test corpus](../tests/parser/README.en.md); preserved source fixtures are not rewritten to match the new language.

**Source excerpt** — `Lingvamyxa_spec.txt`, 9297–9303.

````text
    f("""a
    ) # not syntax
    """" stays data
    b""", '''c
    ( # not syntax
    '''' stays data
    d''', tail)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 9315–9321.

````text
    doc:
    ====
    alpha
    === literal content
    beta
    ====
    end: doc
````

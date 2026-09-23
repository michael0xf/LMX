# LMX grammar

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
- [12. Anonymous containers and repeatable forms](#anonymous)
- [13. No hidden signature-based grouping](#no-inference)
- [14. Bounded forms: brackets](#bounded)
- [15. Source levels and indentation](#levels)
- [16. Dotted delimiters and dash fences](#markers)
- [17. Named closure and terminal forms](#close)
- [18. Missing arguments and an empty vertical body](#empty-colon)
- [19. Braces and Mix anchoring](#mix)
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

This document collects LMX spelling and structural parsing rules from the previous `Lingvamyxa_spec.txt`: lexing, forms, levels, separators, closers, Mix, and grammatical profile boundaries. Message internals, arenas, graph copying, invocation, and typing are not imported. The new semantics are in the [adjacent document](LMX_semantics.en.md).

The primary source is `lingvamyxa/Lingvamyxa_spec.txt`; the `L1/Lingvamyxa_spec.txt` copy was compared separately. Previous section and line numbers identify provenance, not new semantic rules. The [source comparison](source-comparison.en.md) lists changes. RU/EN have identical sections and source excerpts.

The rules below consolidate repeated source explanations. Examples and normal forms are copied, including whitespace, comments, strings, and names: code is not translated between RU/EN. Some excerpts show only part of a construct or schematic notation, not a standalone program. The common four-space indent in source-spec illustrations is presentation indentation; column-0 fence requirements apply after removing that presentation indent.

This document does not invent rules for unspecified profiles. EBNF is a projection of the P0 automaton; automaton and lexical-mode constraints apply together with it.

<a id="structure"></a>

## 2. Structures, fields, and Frames

Sources: §§0, 3.2–3.4, 4.0, 4.8–4.9, 5, 15.

A grammar rule is universal within its domain: a name, type, nesting level, or translator convenience creates no separate syntax branch. A proposed exception or contradiction between rules requires explicit discussion and must not be hidden by special-case parsing.

P0 builds ordered Structures, named Frames, atoms, and Mix nodes with source spans. A Frame has a head and one argument Structure. Field order is preserved; an anonymous Structure is also a field. A physical line is not an abstract-tree container.

The colon separates a head from its argument Structure. It does not by itself mean assignment, a key–value pair, or a type annotation. `fn:`, `if:`, `int:`, `[]:`, and user heads use the same form. A consuming profile determines the head's meaning and field roles after parsing. Nesting alone does not make a Structure executable.

Positional fields retain their order. Named inputs are ordinary nested Frames. Parameter names, table meaning, column count, named-argument validation, and execution are not inferred by P0 from visual alignment. There is no separate anonymous-function or label grammar; `outerLoop:` with a body is an ordinary Frame.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2148–2148.

````text
    f(a, b, c)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2152–2159.

````text
    Frame(
      name(f),
      args(
        field0(a),
        field1(b),
        field2(c)
      )
    )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2630–2636.

````text
    fn: ...
    if: ...
    return: ...
    int: ...
    []: ...
    model: ...
    operator: ...
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2644–2644.

````text
    x: value
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2653–2653.

````text
    Type: x
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2662–2662.

````text
    name: Alice
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3949–3952.

````text
model:
    name: PlantBed
    condition: plantBedCondition
end: model
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3956–3959.

````text
    model(
      name(PlantBed),
      condition(plantBedCondition)
    )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3971–3974.

````text
branch: a
    doSomething
    doOtherThing
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3980–3985.

````text
branch: a
    first:
        doSomething
    second:
        doOtherThing
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3991–3994.

````text
config:
    batchSize: 500
    reportMode: Daily
end: config
````

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

**Source excerpt** — `Lingvamyxa_spec.txt`, 2210–2210.

````text
    print: 1 2 3
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2214–2214.

````text
    print(1, 2, 3)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2273–2273.

````text
    1 2 3
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2277–2277.

````text
    fields `1`, `2`, `3`
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

**Source excerpt** — `Lingvamyxa_spec.txt`, 2228–2230.

````text
    PlantBed
    branch
    very_long_name
````

**Not one bare name** — `Lingvamyxa_spec.txt`, 2243–2243.

````text
    red apples
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2249–2251.

````text
    `red apples`
    `estimate harvest`
    `2 dim example`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2258–2259.

````text
    variable
    `variable`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2281–2281.

````text
    head: PlantBed `2 dim`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2285–2286.

````text
    PlantBed
    `2 dim`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2297–2297.

````text
    `exact name`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2320–2327.

````text
    `a,b`
    `x.y`
    `return`
    `1 2`
    `a  b`
    `line
        continued`
    ``
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2331–2331.

````text
    `a``b`
````

**Identifier value** — `Lingvamyxa_spec.txt`, 2335–2335.

````text
    a`b
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2339–2340.

````text
    int: `a``b`
    `a``b`: 10
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2350–2351.

````text
    `line
        continued`
````

<a id="c-strings"></a>

## 6. Ordinary strings and character constants

Sources: §§3.4.4, 3.4.4.2.

Double-quoted strings and single-quoted character constants follow ANSI C/C99, including wide forms `L"..."`, `L'...'`, escapes, and splicing of a backslash immediately followed by a physical line ending. An unescaped physical newline before an ordinary string closes is an error. A spliced newline contributes no value character; spaces on the following physical line remain inside the literal rather than becoming outer indentation.

An octal escape consumes up to three digits, `\x` consumes following hexadecimal digits under the C rule, and `\uXXXX` and `\UXXXXXXXX` are universal character names. A character constant has a numeric value; multicharacter and wide constants follow the selected C profile.

A closing quote must be followed by a field boundary: horizontal space, newline, comma, semicolon, `(`, `)`, or the end of the item. Another character is a missing-separator error. Adjacent string literals are separate fields, not implicit C concatenation. A string and an exact identifier are distinct.

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

**Source excerpt** — `Lingvamyxa_spec.txt`, 2393–2393.

````text
    print: "hello" "world"
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2397–2397.

````text
    print("hello", "world")
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2401–2403.

````text
    []: labels
    . "red" "green" "blue"
    . "cyan" "magenta" "yellow"
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2410–2410.

````text
    "hello"
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2414–2414.

````text
    `hello`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2479–2483.

````text
    'A'
    '\n'
    '\101'
    '\x41'
    L'A'
````

<a id="raw-quotes"></a>

## 7. Triple quotes

Source: §3.4.4.1.

Three double quotes or three single quotes in token position open a raw string literal. It closes at a run of exactly three matching quotes. A run of N ≥ 4 matching quotes remains content and contributes N − 1 quotes to the value; one or two are ordinary content. The opposite quote character is always ordinary. Backslash does not escape; there are no C escapes, line splicing, or implicit concatenation.

Newlines, NUL, comment-looking text, brackets, and colons inside are content of a length-bearing literal. Its internal lines do not produce outer level events. After closure, the field sequence continues on the same line when separated by space, newline, `,`, `;`, `(`, `)`, `[`, `]`, or item end.

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

**Source excerpt** — `Lingvamyxa_spec.txt`, 2454–2456.

````text
    text: '''single-quote form
    four quotes produce three: ''''
    still text'''
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2468–2471.

````text
    doc:
    . """text child
    still text"""
    end: doc
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

**Source excerpt** — `Lingvamyxa_spec.txt`, 2521–2527.

````text
    @: u32 utf32:
    ===
    текст utf32
    ===

    @: u16 utf16: '''текст utf16'''
    @: u32 utf32: """текст utf32"""
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2531–2537.

````text
    String: u32 utf32:
    ===
    текст utf32
    ===

    String: u16 utf16: '''текст utf16'''
    String: u32 utf32: """текст utf32"""
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2549–2552.

````text
===
line one
line two
===
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2558–2560.

````text
====
This line may contain === without closing the block.
====
````

<a id="comments"></a>

## 9. Comments and disabled blocks

Source: §4.10.

Outside a shielded literal, `#` starts a comment through physical line end; preceding code is parsed normally. `%` at the start of an item after its indentation zone disables that item and its vertical body. Space after `%` is optional; the marker does not affect the level. P0 retains an inactive placeholder rather than the body's ordinary subtree. Lightweight validation still checks levels, admitted closers, balanced bounded forms, and literal closure. Ordinary semantic processing and definition registration are not performed for the disabled body.

A raw file-comment fence is a column-0 line of 3–80 `*` characters with only optional trailing spaces/tabs. Its closing fence must have the same length. Interior lines are ignored completely, including malformed syntax; levels and closers are not checked. Fences do not nest; a different-length run is content. A missing closing fence is a file error. A title or `#` comment cannot be added to such a fence.

**Source excerpt** — `Lingvamyxa_spec.txt`, 4016–4017.

````text
print: count # print the current value of count
# this whole physical line is a comment
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4033–4039.

````text
%branch: mode = debug
    first:
        print: debug branch
    ---
    second:
        print: release branch
    ---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4046–4052.

````text
branch: mode = debug
    %first:
        print: disabled first branch
    ---
    second:
        print: active second branch
    ---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4061–4063.

````text
    ***
    ****
    *****
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4073–4077.

````text
***
This text is ignored by the parser.
Broken Lingvamyxa source may appear here:
    if (
***
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4081–4085.

````text
*****
This line is ignored.
***       # ignored raw comment content, because the opener has length 5
****      # also ignored raw comment content
*****
````

<a id="frames"></a>

## 10. Compact, short, and vertical forms

Sources: §§4.0–4.3.

`f(a, b, c)` is a compact Frame with a bounded argument Structure. `f: a b c` opens a short form at level N; its tail is at implicit level N + 1. An empty opening-line tail may continue with vertical children. A colon admits a bare, exact, or symbolic head.

Horizontal whitespace and commas separate fields of the current tail. A physical newline resets the counter to that physical line's level but does not by itself complete the Frame. A following item at N + 1 continues the body, at N completes the current form and becomes a sibling, and below N completes it under the closing rules. A deeper item requires a predecessor admitting nesting and a valid level transition.

When an indented body follows existing inline arguments, the down/up level transition preserves a new Structure-field boundary. Vertical tokens must not simply be flattened into the inline tail. Ordinary P0 does not infer argument counts from head signatures.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2606–2606.

````text
    head: tail
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2744–2744.

````text
    f(a, b, c)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2753–2756.

````text
    include: "<direct.h>";
===
...
===
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2760–2764.

````text
    f(
      field0(a),
      field1(b),
      field2(c)
    )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2770–2770.

````text
    f: a b c
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2774–2774.

````text
    f(a, b, c)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2784–2791.

````text
L2:
. []: `1 dimension variable`
. . 1 2
. . 3 4
. []: `2 dimension variable`
. . []: 1 2
. . []: 3 4
end: L2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2795–2803.

````text
L2:
    []: `1d variable`
      1 2
      3 4
    ---
    [][]: `2d variable`
      []: 1 2
      []: 3 4
---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2807–2815.

````text
L2:
    []: `1d variable`
      1 2
      3 4
 .  ---
    [][]: `2d variable`
      []: 1 2
      []: 3 4
---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2819–2826.

````text
L2:
    []: `1d variable`
      1 2
      3 4
    [][]: `2d variable`
      []: 1 2
      []: 3 4
---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2841–2841.

````text
    head: arg0 arg1 arg2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2845–2845.

````text
    head(arg0, arg1, arg2)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2849–2849.

````text
    head: PlantBed `2 dim`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2853–2853.

````text
    head(PlantBed, `2 dim`)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2896–2896.

````text
    receiver: arg0 arg1 arg2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2901–2904.

````text
    receiver:
    . arg0
    . arg1
    . arg2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2910–2913.

````text
    fn: test (int: arg) (int)
    . body
    . body
    end: test
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2932–2935.

````text
    L1: utf8:
    ===
    raw text
    ===
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2939–2943.

````text
    L1:
    . utf8:
    ===
    raw text
    ===
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3194–3198.

````text
f:
. a
. b
. c
end: f
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3202–3202.

````text
    f(a, b, c)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3208–3211.

````text
    f: a
    . b
    . c
    end: f
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3215–3215.

````text
    f(a, b, c)
````

<a id="separators"></a>

## 11. Comma, semicolon, and positional skips

Sources: §§4.1, 4.2.1–4.2.1.1, 15.

A comma separates fields and does not terminate an open short tail. A semicolon at the current scan depth immediately terminates the current short form, then separates the next item/segment at that depth. A separator inside deeper brackets belongs to those brackets. With no open short tail, comma is an ordinary separator and semicolon an item separator; a single trailing separator is allowed, including at file root.

A neighboring headless segment after `;` may be represented as a separate anonymous Structure. P0 does not append it to the completed tail or decide whether it repeats a declaration. The consuming profile decides that.

Repeated separators `a,,c`, `a;;c`, `a,;c`, `a;,c` denote a positional skip where the context admits empty positions; a leading separator may skip the first position. P0 preserves the skip without shifting the other arguments. A consumer admits it only for an argument with an allowed default, otherwise reporting an error. `()` is a present empty Structure, not a skip.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2950–2950.

````text
    head: arg0, arg1
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2958–2958.

````text
    head: arg0; arg1
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3027–3027.

````text
    call(int: a b; ret: int)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3031–3031.

````text
    call(int(a, b), ret(int))
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3035–3035.

````text
    call(int: a; b)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3039–3039.

````text
    call(int(a), (b))
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3045–3045.

````text
    print: a b; c
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3049–3050.

````text
    print(a, b)
    (c)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 9167–9167.

````text
        call(cast: Type value, other)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 9173–9173.

````text
        call(cast: Type value; other)
````

<a id="anonymous"></a>

## 12. Anonymous containers and repeatable forms

Sources: §§4.0.1, 4.2.1, 4.6.1.

An argument list is itself a Structure. P0 normalizes a sole anonymous container of the entire positional sequence into the list's own fields, independently of the head and emptiness. An anonymous Structure among other fields remains one field. A named argument can explicitly retain a Structure as one value.

A declaration profile may consume neighboring headless Structures as repetitions of the preceding template. A pointer template includes depth and base type; an array template includes the head shape and type prefix. The next segment may replace the type with its own valid storage type. This is a P0 normalization rule, not name lookup or profile-specific grouping; neighboring expressions do not disappear.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2709–2714.

````text
    f: a b c
    f: (a b c)
    f:
        a
        b
        c
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2719–2719.

````text
    int: x, 5; y, 10
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2723–2723.

````text
    int: (x, 5); (y, 10)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2729–2729.

````text
    f: a (1 2 3) b
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2735–2735.

````text
    f( arg: 1 2 3 )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2970–2970.

````text
    int: x, 5; y, 10; z, 15
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2974–2976.

````text
    int: x, 5
    int: y, 10
    int: z, 15
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2980–2980.

````text
    int(x, 5) (y, 10) (z, 15)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2989–2990.

````text
    @: int px 0; py 0
    @@: char ppa 0; ppb 0
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2998–2999.

````text
    []: int arr 3 1 2 3; other 3 4 5 6
    [n][m]: int matrix; matrix2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3003–3003.

````text
    [n][m]: (int matrix); (matrix2)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3011–3012.

````text
    @: int px; char pc
    [n][m]: int matrix; char matrix2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3852–3854.

````text
branch: a
. doSomething
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3858–3863.

````text
    branch(
      a,
      (
        doSomething
      )
    )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3869–3871.

````text
branch: a
    doSomething
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3875–3880.

````text
branch: a
    ---
        doSomething
    ---
        doOtherThing
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3884–3892.

````text
    branch(
      a,
      (
        doSomething
      ),
      (
        doOtherThing
      )
    )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3896–3901.

````text
branch: a
. first:
. . doSomething
. second:
. . doOtherThing
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3905–3910.

````text
branch: a
    first:
        doSomething
    second:
        doOtherThing
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3916–3916.

````text
    branch: a doSomething
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3924–3925.

````text
    f: a (1 2 3) b
    f( arg: 1 2 3 )
````

<a id="no-inference"></a>

## 13. No hidden signature-based grouping

Sources: §§4.2.2–4.2.3, 4.4, 6.1–6.3.

Whitespace separates fields. `print: getTypedValue values[i]` does not turn into `getTypedValue(values[i])`. Nesting requires parentheses, a compact Frame, or a vertical Structure. `args: int(v, j)`, `args: (int: v j)`, and the vertical nested form express nesting explicitly.

Expression-like sequences consist of atoms and operator fields. `print: a+b c` and `print: a + b c` produce the same structural split. The expression profile determines prefix, postfix, or infix roles, precedence, and operation meaning after P0. The C projection preserves ANSI C precedence and associativity; other backends use a separate profile, not a new structural grammar.

**Source excerpt** — `Lingvamyxa_spec.txt`, 3105–3105.

````text
    print: 1 + 2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3109–3109.

````text
    print(1, +, 2)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3115–3115.

````text
    print: a + b c
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3119–3119.

````text
    print(a, +, b, c)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3123–3123.

````text
    print: a+b c
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3127–3127.

````text
    print(a, +, b, c)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3136–3136.

````text
    print: `a+b`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3140–3140.

````text
    print: (a + b)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3150–3150.

````text
    print: getTypedValue values[i]
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3154–3154.

````text
    print(getTypedValue, values[i])
````

**Not the normalization of the preceding example** — `Lingvamyxa_spec.txt`, 3158–3158.

````text
    print(getTypedValue(values[i]))
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3166–3166.

````text
    args: int(v, j)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3172–3172.

````text
    args: (int: v j)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3176–3177.

````text
    args:
    . int: v j
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3294–3294.

````text
    route( i = 1, print(choose, hello), print(choose, world) )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3298–3306.

````text
    field0 -> <expression Structure for `i = 1`>
    field1 -> (print(choose, hello))
    field2 -> (print(choose, world))

Receiver-signature roles:

    field0 -> selector
    field1 -> onTrue
    field2 -> onFalse
````

<a id="bounded"></a>

## 14. Bounded forms: brackets

Sources: §§4.4, 4.5.2.1, 15.

`(...)` bounds a Structure; empty `()` is allowed. `f()` is an empty compact Frame. `(): value` is a distinct form with head `()`, like `[]:`; it is not an empty Structure with an added value. The same short forms, separators, and levels apply inside brackets. A matching `)` or `]` completes both the bounded form and any short form still open inside it.

After a physical newline, a bounded continuation must remain deeper than the opening line: at the corresponding dotted level or a deeper indentation column. A line whose next token is the matching closer may return to the opener level. `end:` and terminal closers do not replace missing `)`/`]`.

`target[...]` is an attached index suffix. `[]:` is a symbolic head. Standalone `[a b]` is not a portable replacement for `(a b)` without explicit profile admission. Index contents use the same P0 and may contain nested calls, brackets, strings, and operators.

**Source excerpt** — `Lingvamyxa_spec.txt`, 3227–3228.

````text
    (a b c)
    ()
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3232–3234.

````text
    (a b c)
    (a, b, c)
    (a b c,)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3253–3253.

````text
    call(int: a b; ret: int)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3257–3260.

````text
    call(
    . int: a b
    . ret: int
    )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3273–3275.

````text
    value (1
    . +
    . 1)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3279–3281.

````text
    value (1
        +
        1)
````

**Invalid continuation** — `Lingvamyxa_spec.txt`, 3286–3288.

````text
    value (1
    +
    1)
````

<a id="levels"></a>

## 15. Source levels and indentation

Sources: §§4.2.1.1, 4.5–4.5.2.1, 15.0.

The canonical leading zone contains dots, spaces, and tabs; the dot count gives the absolute level, while spaces and tabs do not affect depth. In relaxed notation, an indentation-column stack maps to the same integer levels. The first deeper column creates one next level regardless of the number of added spaces. Dotted delimiters remain valid in relaxed notation.

An atomic increase K → K + 1 opens a Structure field, K → K creates a sibling subject to the current short/bounded context, and K → K − 1 closes the current vertical Structure. An increase exceeding one level is forbidden. An ordinary decrease exceeding one level is forbidden; it requires an admitted tail cutter. A scalar item does not become a head merely because deeper indentation follows.

An empty physical line is a level-0 boundary event. It may close a level-1 tail by ordinary decrease but does not replace a visible delimiter between anonymous sibling sections at deeper levels. A newline after nested short forms resets the counter to the physical line's level, not the deepest inline receiver.

**Invalid level jump; source expects P0 error 13 at 2:5** — `Lingvamyxa_spec.txt`, 3076–3079.

````text
ShortForm1: 1 ShortForm2: 2
. . ShortForm2_arg2
. ShortForm1_arg3
---
````

**Correct consecutive transitions** — `Lingvamyxa_spec.txt`, 3085–3088.

````text
ShortForm1: 1
. ShortForm2: 2
. . ShortForm2_arg2
. ShortForm1_arg3
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3320–3322.

````text
    ....call
    . . . . call
    .	. .	.     call
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3407–3409.

````text
    head
    body Structure
    trailer
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3417–3421.

````text
    .                               # head: open anonymous positional Structure
    . . body1                       # body
    .                               # trailer of previous + head of next anonymous Structure
    . . body2                       # body
    .                               # trailer
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3428–3432.

````text
fn: outer () (int)
    fn: inner (int: a) (int)
        return: a + 1
    int: a 1
return: inner(a)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3439–3445.

````text
fn: outer () (int)
    fn: inner (int: a) (int)
        return: a + 1
    end: inner

    int: a 1
return: inner(a)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3463–3469.

````text
.
. . block0
. . block0
. trailer_word
. . block1
. . block1
.
````

<a id="markers"></a>

## 16. Dotted delimiters and dash fences

Sources: §§4.5.1–4.5.3.

A dotted line contains only a leading zone with at least one dot and an admitted comment. At level K it denotes an anonymous Structure when children at K + 1 follow; otherwise it separates or closes the section. One marker may close the preceding anonymous Structure and open the next. Anonymous sibling sections at the same level require a visible marker.

A fence of 3–80 dashes after the leading zone has the same role. Only horizontal whitespace and a `#` comment may follow it. It calls no receiver, has no argument, and cannot prefix `else:`, `return:`, or another item. On a decrease, it admits closing several open levels down to its own level K; a following K + 1 item may open a new anonymous Structure.

An anonymous Structure continues until another marker at K, an ordinary item at K − 1, an admitted named/terminal close, or EOF. Replacing a named close with a fence depends on profile admission and lack of ambiguity. Matrix rows and nested arrays use the same rules, without separate table syntax.

An explicitly formed empty vertical body preserves a Frame with an empty Structure-body. P0 normalizes it exactly like `f()` and `f: ()`: there is no extra anonymous empty field. Bare `f:` without arguments or explicit closure remains invalid. See [empty bodies](#empty-colon).

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

**Source excerpt** — `Lingvamyxa_spec.txt`, 3508–3518.

````text
    match(
      value,
      (
        1,
        print(World)
      ),
      (
        2,
        print(Hello)
      )
    )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3524–3529.

````text
match: value
. 1
. print: World
. 2
. print: Hello
end: match
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3533–3533.

````text
    match(value, 1, print(World), 2, print(Hello))
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3564–3566.

````text
    ---
    ----
    -----
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3601–3605.

````text
    ---
    ----
    --- # anonymous branch delimiter
    .---
    . ---- # automatically rewritten dotted separator
````

**Invalid fence lines** — `Lingvamyxa_spec.txt`, 3609–3613.

````text
    ---else:
    ----else:
    --- return: x
    --- int: x
    --- trailer word
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

**Source excerpt** — `Lingvamyxa_spec.txt`, 3634–3644.

````text
    match(
      value,
      (
        1,
        print(World)
      ),
      (
        2,
        print(Hello)
      )
    )
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3652–3657.

````text
branch: condition
    ---
        firstBody
    ---
        secondBody
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3671–3676.

````text
match: value
    1
    print: World
    2
    print: Hello
---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3680–3680.

````text
    match(value, 1, print(World), 2, print(Hello))
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3684–3689.

````text
branch: condition
    ---
        firstBody
    ---
        secondBody
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3695–3700.

````text
branch: a
. first:
. . doSomething
. second:
. . doOtherThing
end: branch
````

**Original empty-body example** — `Lingvamyxa_spec.txt`, 3704–3709.

````text
branch: condition
    ---
        # doSomething
    ---
        # doOtherThing
end: branch
````

**Original empty-body example** — `Lingvamyxa_spec.txt`, 3711–3716.

````text
branch: condition
    ---
        # doSomething
    second: # This named receiver is at the correct level and therefore automatically closes the previous block.
        # doOtherThing
end: branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3724–3732.

````text
outerLoop:
    for: int(i, 1) (i <= 3) i++
        for: int(j, 1) (j <= 3) j++
            if: i = 2 && j = 2
                System\out\println: "--- continue outerLoop ---"
                continue: outerLoop
            ---
            System\out\println: "i: " + i + ", j: " + j
end: outerLoop
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3736–3744.

````text
outerLoop:
. for: int(i, 1) (i <= 3) i++
. . for: int(j, 1) (j <= 3) j++
. . . if: i = 2 && j = 2
. . . . System\out\println: "--- continue outerLoop ---"
. . . . continue: outerLoop
. . .
. . . System\out\println: "i: " + i + ", j: " + j
end: outerLoop
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3754–3756.

````text
[]: `2 dim example`
. 1 2
. 3 4
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3760–3763.

````text
[]: `2 dim example`
    1 2
    3 4
---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3767–3767.

````text
    [](`2 dim example`, (1, 2), (3, 4))
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3773–3775.

````text
[]: `2 dim example`
. a b
. 3 4
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3779–3779.

````text
    [](`2 dim example`, (a, b), (3, 4))
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3783–3788.

````text
[]: matrix
. []: row1
. . 1 2
. []: row2
. . 3 4
end: matrix
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3661–3665.

````text
    level 0: branch
    level 1: explicit marker
    level 2: first anonymous body
    level 1: explicit marker
    level 2: second anonymous body
````

<a id="close"></a>

## 17. Named closure and terminal forms

Sources: §§4.6, 7.5, 8.1–8.4, 15.

`end: target` is a checked structural close. Its argument is a literal target, not an evaluated expression. The receiver supplies admitted targets: normally its head name and the canonical name from a `name` argument or name position. The name must be one admitted atom; exact spelling is compared as an atom value. With no valid name, the head is used. The close-target table may admit string/operator atoms as well as executable identifiers.

`end: matrix` closes `[]: matrix`; not `end: [] matrix`. `end: fn` may be an alternative to `end: square` for the corresponding open function. Closure may cross several open implicit levels where position and profile admit it, but not unmatched bounded brackets. A named Frame does not require explicit `end:`: an ordinary admitted level cut also closes it. Bare `end` and `end <target>` are forbidden.

`return`, `return: value`, and `until: condition` are terminal-form candidates only in admitting contexts. Terminal `return` at an executable Frame's opening level appends a return to its body and closes the Frame. The same receiver at body level or deeper is an internal return, not definition closure. `until:` may close a postcondition-loop body. Their spelling alone does not make these words universal tail cutters.

When identical targets occur at different levels, the closing line’s level participates: a parent-level close selects the parent target and cuts its open tail; an inner-level close selects the inner target. Ambiguous, invisible, or positionally invalid targets are rejected. `end:` in an ordinary body position is not executable and is rejected by close validation unless a profile explicitly defines another non-runtime meaning.

**Source excerpt** — `Lingvamyxa_spec.txt`, 3802–3802.

````text
    end: <target>
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3808–3808.

````text
    end: matrix
````

**Incorrect close target** — `Lingvamyxa_spec.txt`, 3812–3812.

````text
    end: [] matrix
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3837–3842.

````text
outerLoop:
. for: int(i, 1) (i <= 3) i++
. . for: int(j, 1) (j <= 3) j++
. . . if: i = 2 && j = 2
. . . . continue: outerLoop
end: outerLoop
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6554–6557.

````text
readLoop:
    readNext: record
    process: record
until: endOfInput(record)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6622–6623.

````text
fn: square (int(x)) (int)
return: x * x
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6627–6627.

````text
    return(x * x)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6631–6634.

````text
fn: factorial (int(n)) (int)
    if: n <= 1
        return: 1
return: n * factorial(n - 1)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6660–6661.

````text
fn: square (int(x)) (int)
return: x * x
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6665–6667.

````text
fn: square (int(x)) (int)
    return: x * x
end: square
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6393–6398.

````text
if: condition
    bodyCall()
end: if
else:
    fallbackCall()
end: else
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6402–6405.

````text
if: condition
    bodyCall()
else:
    fallbackCall()
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6410–6412.

````text
fn: myFunc (int(i)) (int(r))
    return: i
end: myFunc
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6417–6427.

````text
fn:
    name: myFunc
    args:
        int: i
    ---
    ret:
        int: r
    ---
    body:
        return: i
end: myFunc
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6432–6442.

````text
fn:
    args:
        int: i
    ---
    name: myFunc
    ret:
        int: r
    ---
    body:
        return: i
end: myFunc
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6451–6454.

````text
hello: name: world
. "!"
. "!"
end: world
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6461–6466.

````text
hello: name: world  # world #1, opened at level 0
. "1"
. hello: name: world  # world #2, opened at level 1
. . "2"
. . "!"
end: world  # closes world #1 and also closes its still-open tail
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 6471–6477.

````text
hello: name: world  # world #1
. "1"
. hello: name: world  # world #2
. . "2"
. . "!"
. end: world  # closes world #2
end: world    # closes world #1
````

<a id="empty-colon"></a>

## 18. Missing arguments and an empty vertical body

Source: §§4.0.1, 4.1 and 15 of the previous specification; the author's direct correction of 2026-09-23.

A Frame's argument list is itself a Structure. If a sole anonymous Structure field occupies the whole positional sequence, P0 replaces it with its fields exactly once, independently of the head and emptiness. Thus `f()`, `f: ()`, and `f:` with an explicitly empty vertical body closed by `---` yield the same Frame with an empty Structure-body; `f(a b)` and `f: (a b)` likewise yield one list. An anonymous Structure among other fields or a named field remains a distinct field. A separate empty Structure value requires such a nontransparent position.

Parentheses are not a call marker. P0 does not label `f()` as a call or decide whether `f` exists: the same normalized Frame from `f()` and `f: ()` is passed to general head resolution. Calling, assignment, and declaration are defined by [semantics](LMX_semantics.en.md#construction), not by this spelling.

P0 rejects bare `f:` without arguments, a vertical body, or an explicit `---`. Bare `f` is an ordinary admitted atomic expression; resolved as callable, it has the same nullary effect, although P0 may retain it as an atom. The translator does not distinguish Frame forms by COLON/COMPACT or source spelling. An empty inline tail followed by a nonempty vertical body is valid. Bare `end` remains forbidden.

**Valid: the same empty P0 Frame; parentheses do not select a call** — author / автор, 2026-09-23.

````text
f()
````

**Valid: an empty container, zero arguments** — author / автор, 2026-09-19.

````text
receiver:
---
````

**Valid: the same empty container, zero arguments** — author / автор, 2026-09-19.

````text
receiver: ()
````

**Valid nonempty vertical return body** — `Lingvamyxa_spec.txt`, 8985–8987.

````text
    fn: test () int
    return:
    . 5 + 5
````

<a id="mix"></a>

## 19. Braces and Mix anchoring

Sources: §§0.0.2, 3.4.4.4, 15.0.

`{...}` is a bounded Mix form. Outside a shielded literal/comment, `{` enters the same P0 in a local level-0 context; the opener column does not become the indentation base. Ordinary quotes, comments, levels, and nested forms apply inside. A `}` within shielded content does not close the outer form. The result is immediately retained as a Structure node with a Mix flag and source span. Internal newlines do not produce outer level events.

Inline or tail Mix belongs to the current field sequence. Leading Mix before an ordinary item is placed before it at that item's level. In relaxed notation, prefix width may occupy part of indentation; in dotted notation, dots still determine the level. Column-0 lines containing only Mix forms are queued in order and anchored to the next ordinary item, or to the current/document-end context at EOF. Other standalone Mix lines use ordinary levels.

An ordinary consumer may skip Mix nodes; a document consumer may build intervals. This is not automatic execution or substitution. The outer string payload is delimited first; its internal marks are then considered in their own bounded context. They must not alter the outer string's bounds or enter its surrounding active index. The presence of marks does not change the original string value.

**Source excerpt** — `Lingvamyxa_spec.txt`, 212–213.

````text
    item: {color: red} value
    item: value {color: red}
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 218–218.

````text
    {color: red}    item: value
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 226–227.

````text
    {color: red}
        item: value
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 242–242.

````text
    {color: red}
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2572–2572.

````text
    SQL: "select * from users where id = {userId}"
````

<a id="mix-overlay"></a>

## 20. Spelling intersecting marks

Source: §0.0.2. This section retains the Mix document-profile rules needed to read the examples; it does not define the new executable kernel's semantics.

`{color: red}` opens an entry with head `color` and close value `red`. `{end}` closes the latest active explicit mark; `{end: name}` closes the latest active mark with that close value regardless of head. Closing one mark does not close later marks with other values, so intervals can intersect. Duplicate values are selected latest-first. Unclosed entries remain tracked until the document/profile boundary; diagnostics or an interval extending to the end are profile choices.

P0 does not reduce active entries to one flat table of winning values. A renderer may choose the latest value, but the full chain/set retains the others. Internal string marks have their own isolated context. `{end}` belongs to this Mix profile; the ban on bare `end` in ordinary LMX source must not be mechanically applied to it.

**Source excerpt** — `Lingvamyxa_spec.txt`, 253–257.

````text
    {color: red}
    {color: green}
    text
    {end: red}
    {end: green}
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 267–270.

````text
    {style: red}
    {color: red}
    text
    {end: red}
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 99–123.

````text
dataset: harvest
    meta:
        title: "Regional harvest report"
        season: 2026
        source:
            organization: `Field Bureau`
            system: `manual survey`
        ---
        location:
            country: Uruguay
            region: `north field group`
        ---
        note:
            "This part is XML-like tree data: nested named Structures."
    ---

    table:
        columns: (serial "id") region           crop    (real "tons") (decimal "moisture")
        rows:
                 1             "north field"    wheat   12.50         0.14
                 2             "south field"    corn    8.75          0.19
                 3             "east ridge"     barley  10.00         0.16
                 4             "river lowland"  rice    21.30         0.22
        ---
end: harvest
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 292–325.

````text
{style: system}
dataset: harvest
    meta:
{style: title} {color: blue}
        title: "Regional harvest report"
{style: date}
        season: 2026
{end: title}
        month: April
{end: date}
        source:
            organization: `Field Bureau`
            system: `manual survey`
        ---
        location: {color: green}
            country: Uruguay
            region: `north field group`
        ---
        note:
            "This part is {red} marked {end} document data over ordinary Structures."

    --- {end: blue}

    table:
        columns: (serial "id") region           crop    (real "tons") (decimal "moisture")
{end: green}
        rows:
{gray}           1             "north field"    wheat   12.50         0.14
{cyan}           2             "south field"    corn    8.75          0.19
{gray}           3             "east ridge"     barley  10.00         0.16
{cyan}           4             "river lowland"  rice    21.30         0.22
        ---
end: harvest
{end: system}
````

<a id="operators"></a>

## 21. Operator tokens and expression boundaries

Sources: §§4.2.2, 4.7, 6.1–6.4, 20.3.

Operator symbols are not bare identifiers. P0 splits compact unquoted spellings such as `a+b*c==d` into ordinary fields and operator tokens. Exact identifiers are not split. An operator field is not by itself a named head and requires no colon.

The previous minimal L2 profile lists grouping `(expr)`; prefixes `@`, `\`, `++`, `--`, `+`, `-`, `!`, `~`; postfixes `++`, `--`; infixes `+`, `-`, `*`, `/`, `%`, `=`, `!=`, `<`, `<=`, `>`, `>=`, `&&`, `||`, `&`, `|`, `^`; and the index suffix. Writing a prefix adjacent to its operand is style, not a mandatory P0 boundary.

In this profile, `=` is comparison, not assignment syntax or a named field. Updates use the ordinary head form `i: newValue`, whose meaning is determined later. The grammar does not invent a complete operation set, conversions, evaluation errors, or effect ordering.

**Source excerpt** — `Lingvamyxa_spec.txt`, 4242–4251.

````text
    =
    !=
    <
    >
    <=
    >=
    +
    -
    *
    /
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4259–4259.

````text
    i = 1
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4263–4263.

````text
    (i, =, 1)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4271–4271.

````text
    print: 1 + 2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4275–4275.

````text
    print(1, +, 2)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4285–4285.

````text
    print: 1 + 2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4289–4289.

````text
    print(1, +, 2)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4293–4293.

````text
    print: 1+2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4299–4299.

````text
    print(1, +, 2)
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4307–4308.

````text
    `1+2`
    `a+b`
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4350–4350.

````text
    --i
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4355–4355.

````text
    decBefore("i")
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4365–4365.

````text
    i: newValue
````

<a id="paths"></a>

## 22. Address, index, and path forms

Sources: §§11.2–11.3, 12–13, 20.1–20.3. This section records spelling and form distinctions, not value internals.

In L3, the `@:` head has the sole reference-declaration form `@: Type var`: `Type` and `var` are two separate tail fields. The spelling `@: Type: var` builds the different structure `@(Type(var))`, is not a synonym, and is not flattened by translation. The prefix expression `@x`, heads `@@:`, `@@@:`, and machine-address operations are invalid in L3.

In L2, `@ⁿ:` remains the reserved machine-address-depth head family: `@:`, `@@:`, `@@@:`, and so on; there is no arbitrary limit on n. Base type and name are separate tail fields. `@x` is the L2 prefix address-of form; further levels use slot declarations and addresses of those slots, not an invented interpretation of repeated `@` in expressions. The shared `@` head spelling does not make L3 reuse the L2 machine receiver.

The two backslash positions are distinct: `\address` is L2 prefix load, while `value\field` is field follow. `value\[occurrence]field` specifies the matching-name ordinal, whereas `value\field[index]` indexes the selected value. These are different bracket positions. In the previous profile, an omitted ordinal means `[0]`.

`target[index]` differs from heads `[]:`, `[][]:`, and `[n][m]:`. Expression parentheses and bounded index arguments use the same structural mechanism. Ordinary LMX paths do not acquire C `.` or `->` spelling; the explicit `c.` door is separate. Concrete address, type, and operation mappings belong to the semantic profile.

Field-follow and index chains bind tighter than prefix `@` and `\`. `*` remains multiplication, `&` is not address-of, and `^` is not dereference. `.` specifies a level only in the leading zone and is not ordinary field access; `->` is not an LMX field-follow operator.

**Source excerpt** — `Lingvamyxa_spec.txt`, 7458–7460.

````text
    @
    @@
    @@@
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 7479–7481.

````text
    @: BaseType name
    @@: BaseType name
    @@@: BaseType name
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 7485–7487.

````text
    @: int p
    @@: int pp
    @@@: int ppp
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 7497–7497.

````text
    @@@: int ppp
````

**Semicolon ends the tail before the name** — `Lingvamyxa_spec.txt`, 7501–7501.

````text
    @@@: int; ppp
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 7507–7514.

````text
    int: x 5
    @: int p
    @@: int pp
    @@@: int ppp

    p: @x
    pp: @p
    ppp: @pp
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 8215–8215.

````text
    result\harvest
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 8238–8238.

````text
    value\[occurrence]field
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 8251–8252.

````text
    \address      raw L2 load from an address expression
    value\field   typed field follow/access
````

<a id="foreign"></a>

## 23. Explicit C surface and profile boundaries

Sources: §§6.6.6, 20.2.2–20.3.

`c.name` is an explicit C-surface form, not an ordinary LMX field. A compact token beginning with `c.` continues to an LMX boundary: horizontal space, newline, `,`, `;`, `(`, `)`, `:`, comment start, or item end. Dotted continuations remain C surface; calls and indices use bounded forms in the common stream. An exact registered head such as `c.struct:`, `c.union:`, `c.enum:`, or `c.array:` takes precedence in head position over the generic form.

Type heads such as `int`, `char`, and `size_t` do not require `c.`. An unresolved ordinary name does not automatically become a C name. `c.` is not universal declarator, label, or C-tag syntax. `C:` separately accepts explicitly supplied string text; a string does not become code merely by appearing within `L1:`, `L2:`, or `L3:`.

The `.lm1` file suffix in the previous direct L1 profile selects an implicit root L1 body; an explicit `L1:` wrapper is invalid in that profile. `L2:` and `L3:` are ordinary profile-selecting receivers of the second translator. These are specific profile boundaries, not changes to general P0 structure. A catalog of all library receivers is not grammar.

**Source excerpt** — `Lingvamyxa_spec.txt`, 5150–5150.

````text
    c.name
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 5169–5169.

````text
    c.tree.branch
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 5173–5175.

````text
---ANSI C---
tree.branch
---ANSI C---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 5196–5198.

````text
L2:
    c.boxes[1].value: 7
    return: c.boxes[1].value != 7
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 5202–5205.

````text
---ANSI C---
boxes[1].value = 7;
return boxes[1].value != 7;
---ANSI C---
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 5215–5224.

````text
L2:
    fn: main () int
        c.printf: "Hello C\n"
        c.printf: "%s\n" "message"
        size_t: n c.strlen("abc")
        FILE: file
        c.puts: "Hello C"
        return: 0
    end: main
end: L2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 5258–5264.

````text
    int: x
    char: ch
    @: int p
    @@: char pp
    []: int values 16
    \p
    p\field
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 5285–5288.

````text
C:
===
printf("Hello C\n");
===
````

<a id="automaton"></a>

## 24. The single P0 automaton

Source: §15.0; this is the normative recognition model, and the EBNF below is its projection.

`P0 = (S, E, delta, O)`. State S contains source position/span base, lexical mode, normalized level, form stack, and output insertion cursor. Modes are `SOURCE`, `C_STRING`, `EXACT_IDENTIFIER`, `PYTHON_RAW_QUOTE`, `BLOCK_STRING`, `RAW_COMMENT`, and `LINE_COMMENT`. Stack forms are the level-0 root, vertical form K, short head N with body N + 1, parenthesized/index forms with base B, and Mix with local base 0.

Events E are `LEVEL(K)`, `ATOM(value)`, `HEAD(value)`, `COLON`, `NEWLINE`, `COMMA_SEPARATOR`, `SEMICOLON_SEPARATOR`, opening/closing parenthesis, index, and Mix delimiters, a `TAIL_CUTTER` candidate, and `EOF`. Transitions follow the preceding sections. There is no separate P0 line, bracket, brace, or expression parser: all bounded forms enter recursive contexts of the same automaton.

In a shielded lexical mode, brackets, separators, colons, dots, and closer words are content until the mode closes. Matching-delimiter search must use those same modes; a separate character counter is insufficient. Passive mark inspection within an already delimited string payload is a separate bounded context, not removal of this shielding.

EOF completes the root after all forms admitting EOF closure. Unclosed bounded forms or lexical modes remain errors. Output O retains Structures, Frames, atoms, Mix flags, and spans; P0 does not execute code, resolve functions, or assign types.

<a id="ebnf"></a>

## 25. Surface-form EBNF

Source: §15.0. The formal notation and its original annotations are retained verbatim below. This is the same immutable source excerpt in both language versions; all constraints are explained in the preceding sections. `name`, `atom_or_value`, `symbolic_head`, and level events are read with the lexical rules, not as permission for arbitrary characters. English annotations within the notation are not language tokens.

This EBNF does not replace the automaton: bare `f:` without an argument and explicit closure is invalid; `newline/source-level composition` denotes the stated transitions, not arbitrary whitespace separation.

Under the general §4.0.1 rule, P0 normalizes the sole anonymous Structure occupying the whole list before consumption: `f()`, `f: ()`, and an explicitly empty vertical form yield the same Frame with an empty Structure-body. The rule also applies to a nonempty container. Read the historical notation below with this clarification.

**Source excerpt** — `Lingvamyxa_spec.txt`, 8760–8946.

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
                            maps the physical source spelling to source-level
                            item/level events
                            before the structural grammar consumes it;
                            in canonical dotted notation, source_level is the
                            count of leading dot characters;
                            in relaxed indentation notation, source_level is
                            computed by the indentation-stack rule.

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

    enabled_line_body   ::= line_item_sequence

    compact_frame       ::= name "(" [ argument_list ] ")"

    line_frame          ::= source_level line_item_sequence newline

    line_item_sequence  ::= source_item
                            { semicolon_segment_separator source_item }
                            [ semicolon_segment_separator ]

    source_item         ::= colon_frame_body
                          | nullary_line_body
                          | structural_value

    colon_frame_body    ::= head ":" [ line_arguments ]
                            inline tail and following vertical children at
                            N+1 together form the assembled body; a colon
                            Frame with zero argument fields after that
                            assembly is a current-P0 syntax error. Compact
                            `name()` and `()` are not this production.
                            Historical 620db86 P0 allowed the empty form.

    semicolon_segment_separator
                         ::= ";"

    // Semicolon terminates the current open short form/source item at the
    // current scan depth and separates the next source item or argument
    // segment. Comma is an ordinary field separator and never terminates the
    // current open short form.

    head                ::= bare_identifier
                          | exact_identifier
                          | symbolic_head

    nullary_line_body   ::= name
                            valid in executable statement position only when
                            `name` resolves to a zero-argument consumable binding:
                            registered nullary operator/receiver or visible zero-argument fn/sub

    line_arguments      ::= short_tail

    short_tail          ::= short_field
                            { short_tail_field_separator short_field }
                            [ "," ]

    short_tail_field_separator
                         ::= horizontal_space+
                          | ","

    short_field         ::= colon_frame_body
                          | structural_value

    // In ordinary physical short-line form, comma separates fields in the
    // current short form. Semicolon is not a short-tail field separator: it
    // terminates the current short form and exposes the following segment at
    // the surrounding scan depth.
    // Physical newline is not a short-form trailer; after newline, the next
    // source-level event decides whether the open frame receives more fields
    // or is completed by level rules.
    // Operator-token consumption is deferred to a later consumer.

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
                          | nullary_line_body
                          | structural_value

    // Inside bounded Structures, short colon-forms may appear inline.
    // Horizontal whitespace separates simple bounded fields only when no
    // short colon-form is open. Inside an open short colon-form it remains
    // the short-tail field separator. Comma is also a short-tail field
    // separator and never closes the short form. Semicolon terminates an open
    // short form at any scan depth and then separates the following bounded
    // item/argument segment.
    // Newline/source-level composition is not a short-form
    // trailer by itself; the following source level determines continuation
    // or closure. Inside a bounded form that continues across a physical
    // newline, the next physical line must remain inside that bounded form:
    // it must be at the corresponding deeper dotted source level or, in
    // relaxed notation, at an indentation column deeper than the line that
    // opened the bounded form. A line whose next source token is the matching
    // RPAREN/RBRACKET is the closing line and may return to the opener level.
    // The matching RPAREN/RBRACKET closes the bounded Structure; if a short
    // form is still open inside it, that short form is completed as part of
    // closing the bounded context.

    bounded_structure   ::= "(" [ argument_list | vertical_argument_list ] ")"

    source_fragment     ::= P0 source parsed in a local level-0 context

    mix_structure       ::= "{" source_fragment "}"
                            parsed by the same P0 source/token rules in a
                            local level-0 context and stored as a Mix-flagged
                            Structure node

    index_access_suffix ::= "[" [ argument_list | vertical_argument_list ] "]"
                            attached to a preceding target by an expression,
                            update or receiver profile that admits index/access
                            syntax

    vertical_argument_list
                         ::= newline source_line { source_line }
                            where each contained source_line follows the same
                            source-level rules as ordinary vertical composition

    structural_value
                         ::= compact_frame
                          | bounded_structure
                          | mix_structure
                          | atom_or_value
````

<a id="normal-form"></a>

## 26. Structural-result EBNF

Source: §15.1. This describes the parse result, not a second surface grammar or execution semantics. `Structure(...)` and `Frame(...)` denote result construction. The original formal notation is retained identically in RU/EN.

`FrameTrailer` is separate from argument fields. Comma appends/separates tail fields; semicolon first completes the short form at the current depth. A bounded closer closes its matching context; level transitions and receiver-admitted closers retain their distinct completion reasons. An ordinary item at a smaller level remains ordinary after the preceding form closes; its text does not automatically become a closing receiver.

**Source excerpt** — `Lingvamyxa_spec.txt`, 9051–9109.

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

    FrameElement(K)
        ::= Frame(Head, BodyStructure, FrameTrailer)

    Head
        ::= BareIdentifier
         |  ExactIdentifier
         |  SymbolicHead
         |  ProfileHeadPath

    BodyStructure
        ::= Structure({ Field })

    Field
        ::= FrameElement(current)
         |  ValueElement(current)
         |  ExpressionElement(current)
         |  BoundedStructure
         |  CompactFrame
         |  AnonymousStructure(current)

    ValueElement(K)
        ::= NumericLiteral
         |  StringLiteral
         |  BareIdentifier
         |  ExactIdentifier

    ExpressionElement(K)
        ::= ExpressionStructure

    CompactFrame
        ::= Frame(Head, BoundedBody, RPAREN_BOUNDED)

    BoundedStructure
        ::= Structure({ BoundedElement }, RPAREN_BOUNDED | RBRACKET_BOUNDED)

    BoundedElement
        ::= FrameElement(bounded)
         |  ValueElement(bounded)
         |  ExpressionElement(bounded)
         |  CompactFrame
         |  BoundedStructure

    AnonymousStructure(K)
        ::= Structure({ BlockElement(K + 1) })
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 9113–9149.

````text
    ShortTail
        ::= Field { (HorizontalSpace+ | COMMA_FIELD_SEPARATOR) Field }
            [ COMMA_FIELD_SEPARATOR ]

    BoundedBody
        ::= [ BoundedElement { BoundedSeparator BoundedElement }
             [ BoundedSeparator ] ]

    BoundedSeparator
        ::= HorizontalSpace+
         |  COMMA_FIELD_SEPARATOR
         |  SEMICOLON_SEGMENT_SEPARATOR
         |  NewlineSourceComposition

    COMMA_FIELD_SEPARATOR
        ::= COMMA_SEPARATOR

    SEMICOLON_SEGMENT_SEPARATOR
        ::= SEMICOLON_SEPARATOR

    SEMICOLON_SHORT
        ::= SEMICOLON_SEPARATOR

    FrameTrailer
        ::= SEMICOLON_SHORT
         |  RPAREN_BOUNDED
         |  RBRACKET_BOUNDED
         |  LEVEL_DROP
         |  DELIM_NAMELESS
         |  RECEIVER_TRAILER
         |  EOF_TRAILER

    RECEIVER_TRAILER
        ::= END_NAMED
         |  UNTIL_CLOSE
         |  TERMINAL_RETURN
         |  ProfileTrailer
````

<a id="fixtures"></a>

## 27. Original literal-boundary examples

Source: §16.4. These examples come from the parser tests named there. They check payload boundaries, not method behavior. Remove the common four-space presentation indent when copying them into a source file.

In order: `python_string_in_paren.lmx` checks brackets and comment-looking text within raw strings; `python_string_inline_multiline_tail.lmx` checks fields continuing after literal closure; `block_string_equals_fence.lmx` checks a shorter fence as content; `raw_comment.lmx` checks malformed code inside an ignored comment; `string_continuation_indent.lmx` checks preservation of four spaces after C line splicing.

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

**Source excerpt** — `Lingvamyxa_spec.txt`, 9308–9311.

````text
    print: """hello
    """ world
    print: '''hello
    ''' world
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

**Source excerpt** — `Lingvamyxa_spec.txt`, 9326–9331.

````text
    root: before
    ****
    ignored " bad
    . broken:
    ****
    root: after
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 9336–9339.

````text
    doc:
        text: "alpha\
        beta"
    end: doc
````

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
- [12. Anonymous Structures](#anonymous)
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

This grammar specifies P0 lexing and structural parsing: fields, Frames, levels, closers, and Mix. Value, call, and kernel semantics belong to [L3](LMX_semantics.en.md). The accepted author clarifications through 2026-11-22 govern this revision. The field-stream rule makes `import`, `copy`, and `merge` consume ordinary CODE arguments everywhere, including when a DATA context accepts their results ([composition](LMX_semantics.en.md#composition)). The full source representation, including terminal typed leaves with zero payload for uninit, and ordinary replacement of graph fragments are stated in [program representation](LMX_semantics.en.md#program-representation) and [graph assignment](LMX_semantics.en.md#graph-fragment-assignment). [Source comparison](source-comparison.en.md) records provenance. Extracts attributed to the former `Lingvamyxa_spec.txt` illustrate unchanged lexical rules or are explicitly historical; they do not establish an alternative current language.

<a id="structure"></a>

## 2. Structures, fields, and Frames

Sources: §§0, 3.2–3.4, 4.0, 4.8–4.9, 5, 15.

A grammar rule is universal within its domain: a name, type, nesting level, or translator convenience creates no separate syntax branch. Apply the current requirements by their specific subject and revision, and correct superseded prose directly. Only an explicit contradiction that remains between current governing requirements is referred to the author with both provisions and a minimal differing example. Deriving a result from the common rules requires no separate permission and must not be replaced by special-case parsing.

P0 builds ordered Structures, named Frames, atoms, and Mix nodes with source spans. A Frame has a head and one argument Structure. Field order is preserved; an anonymous Structure is also a field. A physical line is not an abstract-tree container. The clean graph fully reflects the written source. All receivers remain as written; terminal primitive leaves are included in their direct `{type value}` representation at the address held by the Lmx cell. An uninitialized leaf contains only its type code and zero value bytes. Computations, transformations, and DATA acceptance of emitted fields occur in the namespace; they do not evaluate or expand receivers away in the source graph. Explicit graph assignment can replace those written fragments under the [semantics](LMX_semantics.en.md#graph-fragment-assignment). The typed-leaf representation licenses no eager computation of a nonterminal RHS.

The colon separates a head from its argument Structure. It does not by itself mean assignment, a key–value pair, or a type annotation. `if:`, `int:`, `[]:`, and user heads use the same form. Named signature declarations use the ordinary expression operand `::`, described below; it is not another colon-Frame form. A consuming profile determines the head's meaning and field roles after parsing. Nesting alone does not make a Structure executable.

`name :: data` uses the ordinary expression operand `::` to declare a signature. The left occurrence is the declaration identifier and the defined single-template form receives one complete DATA description on the right. The right side describes ordered input types and, when present, a `return` result. The left identifier is consumed as a name to declare, not resolved as an existing value. `::` is recognized as one operator token before the single colon. Common expression rules form its operands: `Name :: A B` has two right arguments; `Name :: (A B)` has one Structure argument. The single-colon Frame rule is unchanged, and neither short-form nor compact-call argument interpretation is substituted for the expression contract. This is the only current named-signature spelling; the former named receiver is removed without an alias. For example, `SumSignature :: (int: a; int: b; return: int)` creates a named signature description, not executable code. A selected callable is an ordinary Structure `C`, and its actual `parent(C)` supplies DATA. `sub`, executable `fn`, `fncall`, and a separately supplied call-data parameter are withdrawn. `catch` retains its handler contract under this common data/call model. P0 preserves every written receiver and group; it does not resolve a signature, prepare a namespace, or execute initializers. Qualified helper heads such as `sys\check(S)` and `sys\translate(S)` use ordinary paths and Frames. See [named signatures](LMX_semantics.en.md#fn-signature) and [structural calls](LMX_semantics.en.md#call-receivers).

Positional fields retain their order. A nested Frame stays an ordinary Frame and does not by itself name a formal; a named argument of a callable is written with the operator `:=` ([§21](#operators)), whose meaning the semantics defines after P0. Parameter names, table meaning, column count, named-argument validation, and execution are not inferred by P0 from visual alignment. There is no separate anonymous-function or label grammar; `outerLoop:` with a body is an ordinary Frame.

The left side of `:=` may be an unnamed Structure of places: `(a b c) := (c, a, b)` and `(a b) := (copy(Pair))`. A nonempty bounded Structure followed by `:=` is the left side of the write; the right side is parsed by the common expression rules. This does not introduce a nonempty Structure as a Frame head before a colon: `(): value` remains a distinct empty-head form ([§14](#bounded)). Group positional assignment, including `(a b) := (copy(Pair))`, follows [semantics](LMX_semantics.en.md#group-assign): values are obtained before the first write, and the receiver's field-stream contract does not change P0.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2148–2148.

````text
    f(a, b, c)
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

<a id="identifiers"></a>

## 5. Bare and exact identifiers

Sources: §§3.4.2–3.4.3.

A portable bare identifier has the form `[A-Za-z_][A-Za-z0-9_]*`. It contains no spaces. An exact identifier is delimited by backticks; a doubled backtick inside denotes one literal backtick. Other bytes, spaces, punctuation, line breaks, and indentation are preserved. An empty name is allowed; NUL before the closing delimiter is an error. Backslash introduces no separate escape mechanism here.

The identifier value is its content after delimiter removal and doubled-backtick unescaping. If that value is valid unquoted, both spellings denote the same name. An exact token is atomic in head, argument, and expression positions; operators, comments, and levels are not recognized inside it. Quoting does not escape semantic name reservation: in the language profile, `node` and `` `node` `` are equally reserved (the norm of 2026-11-19 keeps `node`, decision R08; the name `data` has no special meaning -- [what is withdrawn](LMX_semantics.en.md#removed-builtins)). The general grammar itself does not prescribe that name's runtime meaning.

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

Outside a shielded literal, `#` starts a comment through the end of the physical line or of the document; preceding code is parsed normally. `%` at the start of an item after its indentation zone disables that item and its vertical body. Space after `%` is optional; the marker does not affect the level. P0 retains an inactive placeholder rather than the body's ordinary subtree. Lightweight validation still checks levels, admitted closers, balanced bounded forms, and literal closure. Ordinary semantic processing and definition registration are not performed for the disabled body.

A raw file-comment fence is a column-0 line of 3–80 `*` characters with only optional trailing spaces/tabs. Its closing fence must have the same length. Interior lines are not parsed as code, including malformed syntax; levels and closers are not checked. Ignoring a comment during parsing does not discard its text from the retained representation; a comment is not an executable operator. Fences do not nest; a different-length run is content. A missing closing fence is a file error. A title or `#` comment cannot be added to such a fence.

A comment `#` acts through the end of the physical line or of the current document, whichever comes first. The main document ends at input end; a Mix document ends at its closing `}` ([§19](#mix)). Thus `x: a {#)} b` ends the comment at `}` and closes the mark without a lost-parenthesis error. A physical line containing `#` is not a blank-line boundary, even if comment stripping would leave whitespace. Implementation status remains separate from this normative grammar; the [implementation notes](implementation-notes.en.md) are not evidence that every current requirement has been tested.

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

Sources: §§4.0–4.3.

`f(a, b, c)` is a compact Frame with a bounded argument Structure. `f: a b c` opens a short form at level N; its tail is at implicit level N + 1. An empty opening-line tail may continue with vertical children. A colon admits a bare, exact, or symbolic head.

Horizontal whitespace and commas separate fields of the current tail. A single physical newline resets the counter to the completed physical line's level but does not by itself complete the Frame. A blank physical line is the separate full-block boundary defined in [§15](#levels). Implicit levels of nested inline heads do not persist across the newline. The next item or marker determines continuation or closure under the shared [level model in §15](#levels); this model distinguishes the physical line's level from the depth of its open inline tail.

The two-field `int: i 5` and three-field `@: ptr Model Other` are ordinary Frames. P0 assigns no special field roles based on their head names. `@: ptr Model: Other` instead contains atom `ptr` and nested Frame `Model: Other`; it is not the flat three-argument requirement/candidate form. The receiver contract and the consuming DATA or CODE role determine subsequent meaning. The named signature form preserves its declaration contract: write `SumSignature :: (int: a; int: b; return: int)`, then use `@: sumPtr SumSignature SumContext\sum`. The second field names the requirement and the third names the candidate. A Structure call can provide a value where its actual DATA declares a compatible `return`. `i: int: 5`, `new_var: int()`, and `ptr: @: Model: 0` remain ordinary nested Frames but do not declare places named `i`, `new_var`, or `ptr`: place receivers enumerate their own arguments. In DATA, `ms: int: time` declares Structure `ms` containing the terminal primitive declaration `time`. `call: args code` has two positional fields, with no separate DATA argument. See [roles](LMX_semantics.en.md#data-code-roles) and [place declarations](LMX_semantics.en.md#receiver-args-only).

The same frames describe field-stream receivers. `import` has one or more admitted sources, `copy` exactly one, and `merge` at least two. All three read their source arguments as CODE, regardless of where the receiver is written. The common translator/consumer algorithm performs ordinary W/E selection and then checks admitted source arity. P0 must therefore not reject `merge(S)` merely for one written Structure: E may supply multiple sources. In DATA, `Struct: merge(A B)` is an ordinary declaration of `Struct`, with a receiver in its body. Its namespace consumes the result; `Struct` is not an implicit source or model. Several such operations retain their written order and separate operation maps.

```lmx
Struct:
    merge(A B)
    merge(C D)
    copy(E)
```

A CODE place-declaration actual such as `int: item next()` is read as DATA under the resolved declaration contract. P0 preserves it as one Frame: semantics decides whether its inner name matches receiving DATA or the complete form occupies the current position. Passing it does not execute the initializer. This specific declaration contract does not turn an ordinary `Producer()` into a nonexecuted declaration: it remains an explicit call in the CODE arguments of `import`, `copy`, or `merge`, including in DATA placement. Bare Structure references and anonymous Structures remain values, not implicit calls. Thus both `merge(A B)` and `merge((int: x 1) (int: y 2))` provide structural source values. An anonymous container is not itself an implicit call, but its contents may contain explicit calls or computed initializers processed by ordinary contracts. Grouping neither quotes away those operations nor requires eager evaluation of every initializer. See [declaration arguments](LMX_semantics_guide.en.md#declaration-arguments).

When an indented body follows existing inline arguments, the down/up level transition preserves a new Structure-field boundary. Vertical tokens must not simply be flattened into the inline tail. Ordinary P0 does not infer argument counts from head signatures.

The forms of a structural call use the same Frame and ordinary argument parsing: `call(C)`, `call(A C)` and the by-name records `C()` and `C(args)` (`C` is the executed Structure, `A` the Structure of actual arguments). The consumer binds positional and named parts after P0. `args` is the Structure of actual supplied values, as in an ordinary call; the input places and the result are described by the data `parent(C)`. This introduces neither special signature syntax nor a call parser branch. The forms and the common execution path are defined by [semantics](LMX_semantics.en.md#call-receivers); the six former forms of `call` and `fncall` are listed in [what is withdrawn](LMX_semantics.en.md#removed-builtins).

`private:` is also an ordinary P0 receiver form. The effect of the marked field on implicit dynamic binding -- two-way `private` -- belongs to the consumer and changes neither direct visibility nor name parsing ([semantics](LMX_semantics.en.md#private-binding)).

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

Repeated separators `a,,c`, `a;;c`, `a,;c`, `a;,c` denote a positional skip where the context admits empty positions; a leading separator may skip the first position. P0 preserves the skip without shifting the other arguments. A consumer admits it only for an argument with an allowed default, otherwise reporting an error. `()` is a present empty Structure, not a skip.

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

An argument list is a Structure. An anonymous field keeps its boundary both among other fields and when it is the only one in the list: P0 does not unwrap a sole anonymous Structure ([empty bodies](#empty-colon)). Headless atoms, expressions, and empty Structures are also valid in a body. P0 preserves order and nesting but does not decide whether a field is executed, discarded, or accepted as a value. A semantic consumer cannot retroactively change tree boundaries.

**Source excerpt** — `Lingvamyxa_spec.txt`, 2709–2714.

````text
    f: a b c
    f: (a b c)
    f:
        a
        b
        c
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 2729–2729.

````text
    f: a (1 2 3) b
````

<a id="no-inference"></a>

## 13. No hidden signature-based grouping

Sources: §§4.2.2–4.2.3, 4.4, 6.1–6.3.

Whitespace separates fields. `print: getTypedValue values[i]` does not turn into `getTypedValue(values[i])`. Nesting requires parentheses, a compact Frame, or a vertical Structure. `args: int(v, j)`, `args: (int: v j)`, and the vertical nested form express nesting explicitly.

Application with explicit actual arguments requires its own Frame: short `merge: A C`, compact `merge(A C)`, or an equivalent vertical form. This rule applies to all heads without name-based exceptions. In `b: merge A C`, the body of Frame `b` contains neighboring atoms `merge`, `A`, `C`, not a nested `merge` Frame. P0 forms the complete written structural model without knowing the head's role or consulting its availability, signature, or category. A bare identifier remains an atom and captures no neighboring fields. Subsequent common resolution and consumption belong to [semantics](LMX_semantics.en.md#resolved-head-consumption), not additional P0 grouping rules.

Expression-like sequences consist of atoms and operator fields. `print: a+b c` and `print: a + b c` have the same structural split. One P0 parses expressions and every other form; name resolution, operator roles, priorities, and value dependencies are analyzed after this parse. An operator application is a receiver application with a left occurrence and a right sequence: `(1 + 2 + 3 + 4)` preserves the written chain corresponding to `(1 plus: 2 plus: 3 plus: 4)`, while `(+ 1 2 3 4)` has no written left occurrence. Bare names used as ordinary values do not capture neighbors or execute code. The common expression mechanism applies C-like relative priorities and Python-like power grouping ([§21](#operators)), with assignment at the lowest priority. It obtains necessary values on demand: a dependent receiver can run before a stronger-priority consumer without shortening its RHS or changing the written graph. All execution plans and intermediate values belong to namespace processing.

**Source excerpt** — `Lingvamyxa_spec.txt`, 3105–3105.

````text
    print: 1 + 2
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3140–3140.

````text
    print: (a + b)
````

<a id="bounded"></a>

## 14. Bounded forms: brackets

Sources: §§4.4, 4.5.2.1, 15.

`(...)` bounds a Structure; empty `()` is allowed. `f()` is an empty compact Frame. `(): value` has the distinct head `()`, like `[]:`, rather than an empty Structure with an added value. The same P0, short forms, separators, level transitions, and closers apply inside round, square, and Mix contexts. An ordinary decrease exceeding one level requires an admitted tail cutter; a matching `)` or `]` completes its bounded form and its open short forms. A tail cutter does not synthesize missing delimiters. In particular, a blank physical line closes to the current document root and reports an error if an internal paired form is still unmatched ([§15](#levels)); it cannot be ignored so that the form continues below the boundary. The outer `{...}` shell of the current Mix document is not such an internal unmatched form.

After a physical newline, a bounded continuation must remain deeper than the opening line: at the corresponding dotted level or a deeper indentation column. A line whose next token is the matching closer may return to the opener level. `end:` and terminal closers do not replace missing `)`/`]`.

Deeper lines and dots inside brackets read as outside brackets. A deeper line opens a nested anonymous Structure instead of continuing a flat field list. A dot after indentation spaces/tabs is an ordinary atom `.`, while dots in the canonical leading zone still provide levels ([§15](#levels)). The content is parsed like the same lines outside brackets. In form A below, `y` has atom `a` and an anonymous Structure containing `b`; `z` is a sibling.

```text
D: (
    y: a
        b
    z
)
```

Form B: the fields of the content are the atoms `a` and `b`, an anonymous Structure with the atom `c`, and the atom `d`.

```text
D: (
    a
    b
        c
    d
)
```

Form C: a dot after the indentation spaces is the atom `.`, so `call` has four fields: the atom `.`; the Frame `int` with the fields `a` and `b`; the atom `.`; and the Frame `ret` with the field `int` — as for `call:` with the same lines.

```text
call(
    . int: a b
    . ret: int)
```

A closing bracket without an opener is a parse error in the main document and in a Mix document. `x: a ) b` and `x: a {)} b` are errors; the Mix's unmatched `)` cannot close an outer pair. Marks embedded in strings have their separate non-fatal error contract ([§19](#mix)). Brackets inside shielded literal/comment content are not structural delimiters.

Implementation status is separate from this normative grammar; consult the [implementation notes](implementation-notes.en.md) without treating earlier build records as acceptance of these requirements.

`target[...]` is an attached index suffix. `[]:` is a symbolic head. Standalone `[a b]` is not a portable replacement for `(a b)` without explicit profile admission. Index contents use the same P0 and may contain nested calls, brackets, strings, and operators.

A non-empty `(...)` whose closing parenthesis is followed by `:=` is the left side of a write ([§2](#structure)); `(): value` with empty parentheses remains the separate head form `()`.

**Source excerpt** — `Lingvamyxa_spec.txt`, 3227–3228.

````text
    (a b c)
    ()
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 3257–3260.

````text
    call(
    . int: a b
    . ret: int
    )
````

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
| Blank physical line outside shielded payload | Complete all open short/vertical forms to the current document root at virtual level −1; retain that root and create no field. |

These are universal structural actions, not special rules for `if`, `match`, calls, or declarations. An increase explicitly requests a nested Structure field; a scalar item does not become its named head merely because deeper indentation follows. An ordinary cut completes the open field without turning the following item into a special closing receiver. For example, a sibling declaration closes the preceding Frame by its level, not by its declaration semantics. Naming a Frame does not require `end:`.

The “head — primary body Structure — trailer” envelope describes opening, contents, and completion. A trailer is a completion event, not a mandatory source word. The head and structural close are not appended as ordinary fields of the primary body. Terminal receiver roles and preservation of their executable action are defined in [§17](#close).

### Short forms and the next physical level

`f:` at level N opens an argument Structure at implicit level N + 1. Inline fields live inside it. Whitespace and comma separate fields without changing the level; semicolon completes the current short form at its scan depth. After an existing inline tail, the down/up transition to vertical children preserves a new Structure-field boundary instead of flattening all tokens into the tail ([§10](#frames)).

A newline in an open short form resets the counter to the level of **the physical line that just ended**, not to the deepest head written inside its tail. Inline nesting does not carry its implicit level across a newline. The next leading zone supplies the next visible level; an increase from the completed physical line's level can be only one step. The number of colons on the preceding line therefore does not permit skipping several levels on the next line.

The newline itself is a separator, not a trailer. It means neither unconditional closure of all Frames nor preservation of the deepest inline body through any following line. The next level, visible marker, and open context determine ownership of the next item. The asymmetry is intentional: an increase opens a Structure, whereas completion requires a visible next item/marker, `;`, a matching bracket, an admitted tail cutter, a blank-line full boundary, or EOF.

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

**Closing blocks.** A one-level decrease closes the preceding block without a closing word. An ordinary decrease of more than one level requires an admitted tail cutter: `end: name`, `---`, or a terminal form in a permitted position. A blank physical line supplies full closure at virtual level −1, so no additional visible cutter is needed at that boundary. EOF also closes ordinary open forms under [§24](#automaton). The same mechanism applies inside bounded forms, subject to matching delimiters: no cut can replace a missing `)`, `]`, or inner `}`. The distinction is between an ordinary level transition and an explicit completion event, not between kinds of receiver.

One level — no closing is needed:

```text
Point:
    int: x 4
int: after 1
```

Two levels — a cutter is needed (the fence `---` may stand in place of `end: Point` if the profile admits it and the position is unambiguous, [§16](#markers)); without the line `end: Point` the jump from `int: x 4` to `int: y 2` is a parse error:

```text
D:
    Point:
        Inner:
            int: x 4
    end: Point
    int: y 2
```

Anonymous sibling sections at the same level require a visible marker: without a smaller level between them, indentation does not show their boundary. A dotted line or `---` materializes **its own** level K, not the level of the last inline head. When children at K + 1 follow, the marker opens an anonymous Structure at K; the same marker may close the preceding section and open the next. It is not a call and carries no arguments ([§16](#markers)).

A body-level `return` does not become a universal tail cutter by spelling; terminal `return` closes its own executable definition in the position described in [§17](#close). A tail cutter does not close unmatched brackets (`(`, `[` or `{`); a closing bracket without an opening one is a parse error ([§14](#bounded)). The adapted example below uses ordinary executable Structures to illustrate levels; named signatures are descriptions written with `::`.

### Brackets, literals, and empty lines

Within a bounded form, a newline itself neither closes the brackets nor performs the short-form step outwards. Continuation stays inside the bounded context; returning to the opening line's level before the matching bracket is permitted only for the matching closer itself ([§14](#bounded)). Newlines inside shielded strings, exact identifiers, and other lexical payload do not produce outer level events ([§24](#automaton)).

A blank physical line outside shielded payload contains zero characters or only spaces/tabs. It is equivalent to a closing `---` at virtual level −1, above the current document's level-0 root. It immediately completes every open short and vertical form of that block, independently of its indentation; the root itself remains and subsequent items join it normally. The virtual level is an internal parser event, not a writable source level, graph node, receiver or level of L1/L2/L3. Structures already built are neither deleted nor merged with one another. Consecutive, leading, and already-root blank lines are idempotent. The event creates no field, anonymous Structure, call, executable instruction, return, or value. The next line is checked from the reset root context; its indentation is not discarded and cannot reopen the closed form.

Blankness is determined from the original physical line and lexical mode, before whitespace or comment removal. A line containing `#`, level dots, or other source text is not blank. Blank lines inside allowed string/exact-identifier payloads, block text, or raw comments remain content; ordinary unterminated-literal errors still apply. Syntax validation of a `%`-disabled body uses this same blank-line rule. CRLF, LF, and lone CR all produce the same structural event while retaining their original byte spans ([§3](#positions)). A single newline between nonempty lines, or one final LF after the last item, does not itself create a blank line.

For example, the blank line below closes all three nested bodies before `Next`:

```lmx
Root:
    Child:
        Leaf:
            int: value 1

Next:
    int: value 2
```

The first block needs no additional trailer. By contrast, omitting that blank line and jumping directly from `int: value 1` to `Next:` without another admitted cutter remains an invalid multi-level dedent. Pretty-printers may insert blank lines only where full block closure is intended; visual spacing inside a continuing block must not change its tree.

### Required observations of blank-line closure

| № | Input or condition | Expected property |
| --- | --- | --- |
| 1 | The Factory of the [guide](LMX_semantics_guide.en.md#factory-result) | The root has exactly three declarations `Product`, `add1`, `Demo`; the last two do not get inside `Product`. |
| 2 | A blank line after three or more open vertical/short levels, then a new root declaration | All former forms are completed; there is no «an additional trailer is needed» error. |
| 3 | A line of only spaces/tabs instead of the blank line | The same tree and the same boundary. |
| 4 | Several blank lines in a row, at the start and at the end of the document | There are no superfluous fields and anonymous structures. |
| 5 | One newline between nonblank lines | The former rules of continuation and indentation work; one newline gives no full closure. |
| 6 | A blank line before a line with the former nested indentation | The closed form does not resume; the line passes the ordinary check of levels from the new root context. |
| 7 | A line `# comment` between lines of a block | It is not classified as blank; the former rules of comments act. |
| 8 | A blank line inside an admitted multiline literal or a raw comment | The outer tree is not closed; the content is kept. |
| 9 | A blank line with an open inner `(` or `[` | An error at the full boundary; the delimiter is not supplied and the blank line is not skipped. |
| 10 | Two blocks inside a Mix separated by a blank line, with a correct closing `}` | The first local block is closed; the second stays in the same Mix document; the outer form is not closed. |
| 11 | The last correct block ends with EOF, with a final LF and without it | Both variants are admissible and give the same tree. |
| 12 | LF, CRLF and lone CR; different portions of the input in streaming reading | The tree is the same; the coordinates take into account the source width of the line break; the event does not depend on the buffer boundaries. |
| 13 | Parse → output of the source → reparse | The structure of the tree is kept; formatting inserts no blank lines that break a block. |
| 14 | A deferred line with only Mix, then a blank line and a new declaration | The binding is completed before the full boundary and does not pass to the next declaration. |
| 15 | An empty `f:`, then a blank line and a new root declaration | `f` has an empty body equivalent to `f()`; the new declaration does not get into it. |
| 16 | A deep block, then a jump down by more than one level without a blank line and without another admissible cutter | The former jump error is kept; the novelty does not allow arbitrary dedent. |

Compare the Factory of the guide with the equivalent variant with `---` in which both return operations are also written `return: (copy(Product))`: when only the ways of completion differ, the structure of the graph and the behavior must be kept. If the kernel is available, `Demo\run()` must return `32`; the products kept after `small` and `large` must read `10` and `20`. Behavioral tests complement the check of the tree and do not replace it.

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

**Current-syntax adaptation** of the level example from `Lingvamyxa_spec.txt`, 3428–3432.

````text
OuterData:
    int: a 1
    return: int
    inner:
        return: a + 1
    outer:
        return: inner(a)
````

<a id="markers"></a>

## 16. Dotted delimiters and dash fences

Sources: §§4.5.1–4.5.3.

A dotted line contains only a leading zone with at least one dot and an admitted comment. At level K it denotes an anonymous Structure when children at K + 1 follow; otherwise it separates or closes the section. One marker may close the preceding anonymous Structure and open the next. Anonymous sibling sections at the same level require a visible marker.

A fence of 3–80 dashes after the leading zone has the same role. Only horizontal whitespace and a `#` comment may follow it. It calls no receiver, has no argument, and cannot prefix `else:`, `return:`, or another item. On a decrease, it admits closing several open levels down to its own level K; a following K + 1 item may open a new anonymous Structure.

An anonymous Structure continues until another marker at K, an ordinary item at K − 1, an admitted named/terminal close, a blank-line full boundary, or EOF. A blank line closes the entire current block to its document root; it neither acts as a visible marker at K nor opens a following anonymous sibling. Replacing a named close with a fence depends on profile admission and lack of ambiguity. Matrix rows and nested arrays use the same rules, without separate table syntax.

An explicitly formed empty vertical body preserves a Frame with an empty Structure-body. P0 normalizes it exactly like `f()` and `f:`: there is no extra anonymous empty field; `f: ()`, by contrast, holds one field — an empty Structure. See [empty bodies](#empty-colon).

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

`end: matrix` closes `[]: matrix`, not `end: [] matrix`. The expression operand in `SignatureName :: DataTemplate` does not itself open a colon Frame or introduce a special `end: SignatureName` target. Its right occurrences obey the ordinary expression, grouping and source-level boundaries. An explicitly written named Frame inside its description retains only its own ordinary close rules; a left identifier does not turn the operator application into that Frame. Closure may cross open implicit levels but never synthesize a missing bounded delimiter. A named Frame may also end by an admitted level cut, a blank-line full boundary, or EOF. Bare `end` and `end <target>` are forbidden.

`return`, `return: value`, and `until: condition` are terminal-form candidates only in admitting contexts. Terminal `return` at the opening level of a named executable Structure, including any ordinary Structure (there are no executable `fn`/`sub`), appends a return to its body and closes its Frame. The same receiver at body level or deeper is an internal return, not definition closure. `until:` may close a postcondition-loop body: an anonymous body closed by `until:` is an inline postcondition loop in the enclosing activation, and a named Frame closed by `until:` declares, in data, an ordinary named Structure whose executable body is that loop — declaring it does not run it; only an explicit call does — by the receiver `call` or, in code, by a form whose head is this Structure; in code the same Frame is a call of its head: the selected Structure is executed, its data are its `parent`, and the tail of the form is the actual arguments, which the common declaration selection accepts ([choosing the declaration](LMX_semantics.en.md#declaration-selection)); it is an error when the head names neither a callable nor a Structure ([semantics](LMX_semantics.en.md#data-code-roles)). No construct requires any of these trailers: they are P0 boundaries, not a condition of declaration. A named Structure closed by an ordinary level cut is declared the same way, by a form of data ([L3 §9](LMX_semantics.en.md#construction)); reaching the end of the code of a named Structure does not create `return`: no return is synthesized there ([`return` in data](LMX_semantics.en.md#return-in-data)). Their spelling alone does not make these words universal tail cutters. The adapted example below uses an ordinary callable to illustrate terminal return; a signature declaration written with `::` has no executable body.

When identical targets occur at different levels, the closing line’s level participates: a parent-level close selects the parent target and cuts its open tail; an inner-level close selects the inner target. Ambiguous, invisible, or positionally invalid targets are rejected. `end:` in an ordinary body position is not executable and is rejected by close validation unless a profile explicitly defines another non-runtime meaning.

**Current-syntax adaptation** of the terminal-return example from `Lingvamyxa_spec.txt`, 6622–6623.

````text
SquareData:
    int: x
    return: int
    square:
    return: x * x
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

<a id="empty-colon"></a>

## 18. Missing arguments and an empty vertical body

Source: §§4.0.1, 4.1 and 15 of the previous specification; the author's direct correction of 2026-09-23; the author's decision of 2026-11-10.

A Frame's argument list is itself a Structure. P0 retains every anonymous group, even a sole or empty one: `s(a b)` has two fields; `s((a b))` has one Structure field. `f()`, bare `f:`, and `f:` with an explicitly empty vertical body have the same empty Frame-body; a blank physical line after `f:` completes that empty body without creating a return or anonymous field. `f: ()` is instead `f(())`, one field containing an empty Structure. In DATA, `A: (int: x 1)` retains its anonymous inner Structure, whereas `A(int: x 1)` and `A: int: x 1` directly describe the field `x`. A receiver whose contract takes DATA arguments accepts them as written. A receiver whose arguments are CODE may consider the equal readings W (whole) and E (one-level expansion of one Structure not assigned to a named formal). Exactly one accepted declaration/reading/map is used, with no second expansion; zero candidates fail and multiple candidates are ambiguous. For `import`, `copy`, and `merge`, the source argument role is always CODE; placement inside DATA does not suppress W/E. This is semantic admission, never a P0 unwrapping pass. See [whole arguments](LMX_semantics.en.md#whole-arguments) and [selection](LMX_semantics.en.md#declaration-selection).

Parentheses are not a call marker. P0 gives `f()` and an empty `f:` the same Frame without checking whether `f` exists. A resolved ordinary head declares a Structure in DATA and calls it in CODE. The callable `C` itself executes over its actual `parent(C)`; the path used to obtain it does not substitute another parent. A head with its own receiver contract follows that contract. These forms perform no assignment merely because a colon is present. See [construction](LMX_semantics.en.md#construction) and [structural calls](LMX_semantics.en.md#call-receivers).

Written grouping is also significant for field streams:

```lmx
f(copy(A))
f((copy(A)))
f(arg0 := (copy(A)))
```

The first supplies result fields; the second forms one Structure before `f` applies ordinary W/E; the third supplies that whole Structure explicitly to real formal `arg0`, suppressing E. `copy(Empty)` emits zero fields, while `(copy(Empty))` is one empty structural result. P0 preserves the grouping in every case, including `struct := (merge(A B))` and `return: (copy(A))`; the namespace performs the computation. The same distinction applies to nested `import`: its surrounding consumer receives the stream, with no duplicate hidden import into the caller. See [field streams](LMX_semantics_guide.en.md#field-streams).

Bare `f:` without arguments and without a vertical body is the short form without arguments: a Frame with an empty body, like `f()`. Bare `f` is an ordinary admitted atomic expression; P0 retains it as an atom and does not create a call Frame. Under [semantics](LMX_semantics.en.md#resolved-head-consumption), a bare name reads the resolved value or reference without executing the Structure; its launch is written `call: f` or, in code, `f()`. The translator does not distinguish Frame forms by COLON/COMPACT or source spelling. An empty inline tail followed by a nonempty vertical body is valid. Bare `end` remains forbidden.

**Valid: the same empty P0 Frame; parentheses do not select a call** — author, 2026-09-23.

````text
f()
````

**Valid: an empty container, zero arguments** — author, 2026-09-19.

````text
receiver:
---
````

**Valid: one field, an empty Structure, as in `receiver(())` (author's decision of 2026-11-10; formerly the same empty container, zero arguments)** — author, 2026-09-19.

````text
receiver: ()
````

<a id="mix"></a>

## 19. Braces and Mix anchoring

Sources: §§0.0.2, 3.4.4.4, 15.0.

`{...}` is a bounded Mix form. Outside shielded content, `{` enters the same P0 with its own local level-0 root; the opener's column does not become the indentation base. Quotes, comments, levels, and nested forms use the common rules. A `}` within a shielded literal does not close the mark. A `#` comment in the mark ends at newline or the document's closing `}`, so `{#)}` is valid. The parsed result is retained as a Mix-flagged Structure with its source span. Internal newlines do not produce outer level events. A blank line completes the current local block only; it neither closes the outer document nor replaces the Mix wrapper's required `}`.

Braces are not comments. Their content is parsed by the same automaton, so a malformed mark is an error and its internal delimiter cannot pair with an outer one. `x: a {)} b`, `x: a {(} b`, and `f(a {)} b)` are errors. The separately described string-mark exception below does not change ordinary Mix parsing.

Inline or tail Mix belongs to the current field sequence. Leading Mix before an ordinary item is placed before it at that item's level. In relaxed notation, prefix width may occupy part of indentation; in dotted notation, dots still determine the level. Column-0 lines containing only Mix forms are queued in order and anchored to the next ordinary item, or to the current/document-end context at a blank-line full boundary or EOF. A pending queue is resolved before a blank-line boundary and is never carried into the following block. Other standalone Mix lines use ordinary levels.

An ordinary consumer may skip Mix nodes; a document consumer may build intervals. This is not automatic execution or substitution.

Marks inside a string use the same Mix scanner after the outer string payload has been delimited. They do not change the string's bounds, remove text from its value, or join the outer active-mark context. A valid mark gives a separate mix-tree associated with its string atom and displayed-character position. Positions count a non-BMP character such as 🙂 as one character, not two UTF-16 code units. An invalid string mark gives no tree and does not fail the string: `x: "text{)}text{mix}"` remains one whole string with one mix-tree, for `{mix}`. These contracts retain the author's 2026-11-11, 2026-11-13, and 2026-11-15 clarifications as stated here without requiring external journal files.

Implementation status is separate from this normative grammar; consult the [implementation notes](implementation-notes.en.md) without treating earlier build records as acceptance of these requirements.

**Source excerpt** — `Lingvamyxa_spec.txt`, 212–213.

````text
    item: {color: red} value
    item: value {color: red}
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 218–218.

````text
    {color: red}    item: value
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

<a id="operators"></a>

## 21. Operator tokens and expression boundaries

Sources: §§4.2.2, 4.7, 6.1–6.4, 20.3.

Operator symbols are not bare identifiers. P0 splits compact unquoted spellings such as `a+b*c==d` into ordinary fields and operator tokens. Exact identifiers are not split. An operator field is not by itself a named head and requires no colon.

`::` is one ordinary expression-operator token, recognized before a single `:`. It
keeps the written left identifier and complete right-hand signature description
in the common graph. P0 does not turn it into nested colon Frames, look up the
left name, open the description as actual call arguments, or execute its fields.
The signature consumer applies its declaration contract through the common operand mechanism after parsing, including the ordinary raw-occurrence mode and a ready priority. The
single-colon Frame grammar and ordinary expression/group boundaries remain in
force; `::` is not an assignment with a different spelling.

The previous minimal L2 profile lists grouping `(expr)`; prefixes `@`, `\`, `++`, `--`, `+`, `-`, `!`, `~`; postfixes `++`, `--`; infixes `+`, `-`, `*`, `/`, `%`, `=`, `!=`, `<`, `<=`, `>`, `>=`, `&&`, `||`, `&`, `|`, `^`; and the index suffix. Writing a prefix adjacent to its operand is style, not a mandatory P0 boundary.

In this profile, `=` is comparison, not assignment syntax or a named field. An update is written with the operator `i := newValue`; P0 still parses `i: newValue` as an ordinary head form, but in translation and interpretation it no longer serves as an assignment (author's decision of 2026-11-10, [semantics](LMX_semantics.en.md#forms-declare-or-call)).

`:=` is one operator token: P0 neither splits it into `:` and `=` nor makes a Frame head `a:` from `a:=5`. Compact and spaced assignments have the same fields. The operator writes a resolved place or supplies a named actual according to its structural position ([semantics](LMX_semantics.en.md#assign-known)). Assignment receivers remain tied to their written left places; `1 + v := 2 * 3` does not become a C-style assignment to `1 + v`. Assignment has the lowest relative priority, groups right, and keeps the expression on its right through the enclosing group boundary. The stronger operations appear above weaker ones in the table. Necessary values are obtained on demand: `1 + v := 2 + 3` gives 6 with `v = 5`; `10 * v := 2 + 3` gives 50; `1 + v := 2 * 3` gives 7 with `v = 6`. Explicit `1 + (v := 2) + 3` instead leaves `v = 2`. `a := b := 10` assigns both places; `v := 2 - 3` and the existing receiver form `(+ 2 - 3)` give −1. This is value-dependency execution, not temporary promotion of assignment priority or graph regrouping. Effects and result admission follow [semantics](LMX_semantics.en.md#assignment-inside-expression).

| level | operations | associativity |
|---|---|---|
| postfix | call, index, field access; postfix `++` and `--` | left to right |
| unary | prefix `+`, `-`, `!`, `~`, `++`, `--`; the address operations | right to left |
| multiplication | `*`, `/`, `%` | left to right |
| addition | `+`, `-` | left to right |
| shifts | `<<`, `>>` | left to right |
| relations | `<`, `<=`, `>`, `>=` | left to right |
| equality | `=`, `!=` | left to right |
| bitwise and | `&` | left to right |
| bitwise exclusive or | `^` | left to right |
| bitwise or | `\|` | left to right |
| logical and | `&&` | left to right |
| logical or | `\|\|` | left to right |
| assignment | `:=` and the compound assignments, `**=` included | right to left |

The logical `&&` and `||` obtain their right operand only when needed. A user operand is an ordinary method discovered through its DATA's explicit structural header: `left` is a reference, `right` is an Array of references, and `PASS_ARGS_AS_IS` and `PRIORITY` are required constant integer fields. Mode must be `0` or `1`; priority must be ready before grouping. No `sys\operand` registration, separate implementation name, or implicit default property is used. The method's ordinary `return` describes its result; an operator application does not add a hidden dereference. Mode `0` supplies prepared values by reference; mode `1` supplies original occurrences and their live source context, evaluated only when the method calls `sys\eval`. Arrays and strings remain single operands. A lexical identifier can therefore have operator, ordinary-call, or reference use after P0 without a spelling-specific parser branch. `sys\name(identifier)` reads the identifier spelling without resolving or executing it; `sys\priority(name)` reads an accessible operand's ready priority by string content. The full contracts are in [semantics](LMX_semantics.en.md#operand-receiver), the [worked guide](LMX_semantics_guide.en.md#operand-templates).

Compound assignments `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=` and power `**` are single operator tokens; spacing does not alter them. Power groups right and binds above multiplication/addition but below call, index, and field access. On its left it binds above unary `+`, `-`, and `~`; on its right it admits a unary operand. Thus `-2 ** 2` is `-(2 ** 2)`, `2 ** -2` is `2 ** (-2)`, `2 ** 3 ** 2` is `2 ** (3 ** 2)`, and `2 * 3 ** 2` is `2 * (3 ** 2)`. `^` stays bitwise exclusive-or. Numeric admission and the result of negative powers follow LMX's numeric contract, not all of Python's semantics. [Compound assignment semantics](LMX_semantics.en.md#compound-assign) also govern effects; implementation acceptance verifies the common token and expression mechanisms.

**Source excerpt** — `Lingvamyxa_spec.txt`, 4259–4259.

````text
    i = 1
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 4271–4271.

````text
    print: 1 + 2
````

<a id="paths"></a>

## 22. Address, index, and path forms

Heads `@:`, `@@:`, `@@@:` and further depths share one structural form. Flat `@: ptr Model Other` has three neighboring fields; `@: ptr Model: Other` has atom `ptr` and a nested Frame. Their subsequent roles follow the resolved receiver contract and DATA/CODE context, not special P0 parsing. `ptr: @: Model: 0` is a nested Frame rather than a declaration of the place `ptr`. A named signature requirement uses the same flat form, `@: ptr Signature Candidate`. A CODE call can yield a value when its actual DATA declares a compatible `return`. `import`, `copy`, and `merge` always read their source arguments as CODE, including inside DATA declarations; anonymous Structures and bare references remain values. P0 neither reorders arguments nor resolves types, declarations, or assignments.

Prefix `@x` and `\x` differ from heads `@:` and paths `x\field`. `@x` explicitly obtains a numeric address; ordinary references do not require it. `\x` dereferences and does not execute code. Reserved `node` is lexical and stays fixed across nested bodies; it is not a synonym for the current DATA/stream recipient or a dynamically selected namespace. Field and index chains bind tighter than prefix operators. L2 indexing of any rank computes an offset without checks, including negative indexes. L3 reduces adjacent indexes to one linear index with one length check; this is common index-path semantics, not a separate P0 parse. `a[i][j][k]` addresses a multidimensional Array; `a[i]\[j]\[k]` follows references to separate Arrays. P0 also parses `s\[N]field`: in a Structure in the role of data, it is the zero-based Nth occurrence of the name `field` at its root level, not an Array field; bare `s\field` is allowed only with one occurrence. A repeated declaration in data, including repeated declarations accepted from separate receiver streams, neither replaces the former one nor writes into it — it is one more occurrence of the name: after it the name is addressed only with the index of an occurrence, and access without an index is an error ([semantics](LMX_semantics.en.md#fields)). Fields do not use C `.` or `->`. Address and type semantics are in [L3](LMX_semantics.en.md) and [L2](L2_spec_en.md). The index suffix on a Structure, `S[i]`, is the same attached form; it reads a Structure's slot as an `@` reference ([semantics](LMX_semantics.en.md#structure-index)).

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

`c.name` is an explicit C-surface form, not an ordinary LMX field. A compact token beginning with `c.` continues to an LMX boundary: horizontal space, newline, `,`, `;`, `(`, `)`, `:`, comment start, or item end. Dotted continuations remain C surface; calls and indices use bounded forms in the common stream. Names following `c.` pass through the common raw C door; particular C names have no separate registration or special parsing ([L2](L2_spec_en.md#lowlevel-abi)).

In an evaluated call, C functions and macros receive already evaluated L2 values, not L2 expression text for substitution. Literal `c.sizeof` has the role of a C operator rather than a function call; expanding an arbitrary macro into `sizeof` does not give it this role. This is a semantic distinction after common expression preparation, not special parsing of a C name; the evaluation contract is specified in [L2 §20](L2_spec_en.md#lowlevel-abi) (author clarification of 2026-10-22).

Type heads such as `int`, `char`, and `size_t` do not require `c.`. An unresolved ordinary name does not automatically become a C name. `c.` is not universal declarator, label, or C-tag syntax. `C:` separately accepts explicitly supplied string text; a string does not become code merely by appearing within `L1:`, `L2:`, or `L3:`.

The file extension selects the outer profile, and a file is itself a Structure ([semantics](LMX_semantics.en.md#scope)). `L2` is a receiver: `L2: (...)` remains written in the graph, and the consumer uses its contract to determine the code level. An `.lm2` file is treated as wrapped in that receiver. `L1` and `L3` do not themselves select profiles and resolve as ordinary names. The former direct L1 profile accepted wrapperless `.lm1` input; that historical profile is outside this archive. A receiver catalog does not add grammar.

**Source excerpt** — `Lingvamyxa_spec.txt`, 5150–5150.

````text
    c.name
````

**Source excerpt** — `Lingvamyxa_spec.txt`, 5196–5198.

````text
L2:
    c.boxes[1].value: 7
    return: c.boxes[1].value != 7
````

<a id="automaton"></a>

## 24. The single P0 automaton

Source: §15.0; this is the normative recognition model, and the EBNF below is its projection.

`P0 = (S, E, delta, O)`. State S contains source position/span base, lexical mode, normalized level, form stack, and output insertion cursor. Modes are `SOURCE`, `C_STRING`, `EXACT_IDENTIFIER`, `PYTHON_RAW_QUOTE`, `BLOCK_STRING`, `RAW_COMMENT`, and `LINE_COMMENT`. Stack forms are the level-0 root, vertical form K, short head N with body N + 1, parenthesized/index forms with base B, and Mix with local base 0.

Events E are `LEVEL(K)`, `BLANK_LINE`, `ATOM(value)`, `HEAD(value)`, `COLON`, `NEWLINE`, `COMMA_SEPARATOR`, `SEMICOLON_SEPARATOR`, opening/closing parenthesis, index, and Mix delimiters, a `TAIL_CUTTER` candidate, and `EOF`. Transitions follow the preceding sections. There is no separate P0 line, bracket, brace, or expression parser: all bounded forms enter recursive contexts of the same automaton.

In a shielded lexical mode, brackets, separators, colons, dots, and closer words are content until the mode closes. The line-comment mode (`LINE_COMMENT`, `#`) ends at the end of the line or of the document, and for the document of a Mix mark that end is its closing `}` ([§9](#comments), [§19](#mix)). Matching-delimiter search must use those same modes; a separate character counter is insufficient. Braces are neither a comment nor a lexical mode: a mark is a bounded form, its content is parsed by the same automaton, and a closing bracket inside a mark with an error does not become the pair of an outer opening bracket (`f(a {)} b)` is an error). The content of an already delimited string payload passes the Mix scanner as a separate bounded context: it does not remove this shielding, does not alter the string's bounds, and an error in a mark does not fail the string ([§19](#mix)).

`BLANK_LINE` is recognized from the original physical line and lexical mode before whitespace/comment removal. It enters the common completion mechanism at virtual level −1, completes the current block immediately, resolves pending Mix-only anchors, and resets continuation to the local document root. It adds no output field or instruction. If an internal paired form is unmatched, it reports an error at the boundary with the opener location; it does not synthesize a delimiter. The current Mix document's own wrapper is excluded from this internal-pair check. Source spans record the actual boundary rather than an inserted textual `---`. Repeated boundaries are idempotent. The same event is used in disabled-body syntax validation.

EOF completes the root after all forms admitting EOF closure. No final blank line or trailer is required, and one final LF need not be treated as a blank line. Unclosed bounded forms or lexical modes remain errors, as does a closing bracket without an opening one ([§14](#bounded)). Output O retains Structures, Frames, atoms, Mix flags, and spans; P0 does not execute code, resolve functions, or assign types.

<a id="ebnf"></a>

## 25. Surface-form EBNF

Source: §15.0 of the former specification, revised here to express the current recognition rules. This projection is subordinate to the single automaton and the preceding sections. `name`, `atom_or_value`, `symbolic_head`, and level events use the lexical rules; annotations are explanations, not language tokens. This archive revision concerns the English grammar.

This EBNF does not replace the automaton. `newline/source-level composition` means the stated transitions, not arbitrary whitespace separation. A blank physical line is a full-document-root completion event; it is recognized before generic whitespace skipping.

P0 never unwraps the sole anonymous Structure occupying an argument list ([empty bodies](#empty-colon)). `f()`, `f:`, and an explicitly empty vertical form have the same empty Frame-body; `f: ()` has one empty Structure field. The EBNF below is read with these retained group boundaries.

Comments stop at newline or document end, including the closing `}` of Mix. Round and square bounded content uses the same source-level rules: a deeper line opens an anonymous Structure, a dot after indentation spaces is an atom, and an unmatched closer is an error. Blank-line full closure follows the local-document and delimiter rules in [§14](#bounded), [§15](#levels), and [§19](#mix).

A bare identifier in `nullary_line_body` remains an atom. Availability, role, arity, and operand discovery are consumer checks after construction of the complete model. P0 performs no registered-nullary-receiver lookup and does not turn a bare callable reference into a call.

**Current EBNF projection** — derived from `Lingvamyxa_spec.txt`, 8760–8946, with the accepted corrections incorporated.

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

    logical_line        ::= source_level line_content (newline | EOF)

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
                            BLANK_LINE: full closure at virtual level -1;
                            completes current short/vertical block to this
                            document's root; emits no field; preserves lexical
                            shielding and rejects unmatched internal pairs

    line_content        ::= dot_only_marker [ comment_body ]
                          | comment_body
                          | disabled_body [ comment_body ]
                          | line_item_sequence [ comment_body ]

    dot_only_marker     ::= empty content after indentation
                            valid only if source_level > 0;
                            may delimit/open an anonymous Structure at that level

    comment_body        ::= "#" ignored_until_newline_or_document_end

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
                            N+1 together form the assembled body; zero fields
                            give the same empty Frame-body as name(). A blank
                            physical line completes the entire current block.

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
                            an ordinary atom; semantic resolution does not
                            introduce a P0 call or consume neighboring fields

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
    // or is completed by level rules. A blank physical line is a distinct
    // full boundary at virtual level -1, not ordinary newline composition.
    // Operator-token consumption is deferred to a later consumer.
    // The token :: keeps its left identifier and right DATA fields; it is
    // not two colon_frame_body separators and does not unwrap a group.

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

Source: §15.1. This describes the parse result, not a second surface grammar or execution semantics. `Structure(...)` and `Frame(...)` denote result construction. This English projection uses the current completion rules; it does not imply an updated parallel translation.

`FrameTrailer` is separate from argument fields. Comma appends/separates tail fields; semicolon first completes the short form at the current depth. A bounded closer closes its matching context; level transitions, blank-line full closure, EOF, and receiver-admitted closers retain their distinct completion reasons. An ordinary item at a smaller level remains ordinary after the preceding form closes; its text does not automatically become a closing receiver.

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

<a id="fixtures"></a>

## 27. Original literal-boundary examples

These preserved lexical examples illustrate literal boundaries. They do not override the current automaton or establish implementation test results; validation expectations are specified in this grammar, in particular in the [observations of blank-line closure](#levels).

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

<!-- receiver-integration-2026-11-22 -->
<a id="receiver-library-syntax"></a>
## Receiver-library syntax, 22 November 2026

The general receiver library adds no new delimiters, node kind, argument
parser or P0 unwrapping. Its direct names resolve through the existing namespace
from the single current kernel. The current spelling of the admission receiver is
`satisfies`; it has the existing receiver argument structure.

Both signature-description forms describe the same signature kind. The type-token operand is
consumed through the standard `OPERANDS_TEMPLATE`; the named declaration
`Name :: DATA` retains its existing DATA contract and its current relationship
with `call`. All other uses accept both descriptions interchangeably. Parameter
labels do not alter positional type compatibility. Dispatch on the resolved
receiver's contract follows structural parsing and does not change written
boundaries. The named declaration uses the ordinary expression operand `::`; it does not add a special signature delimiter or argument parser. The old named receiver is removed. The core type-token constructor `signatureTypes` is another entry to the same signature kind.

The sole operand-opening rule has three simultaneous conditions: `left` is
an unnamed Structure, `right` has exactly one argument, and that argument is
an unnamed Structure. Only that RIGHT container loses one outer level when
preparing the operand arguments. `left` remains whole, the rule is not repeated,
and P0 never performs this operation. With `Name :: (...)`, the identifier on
the left does not satisfy the condition, so the right Structure remains one
argument. Ordinary callable W/E selection has a separate defined scope.

Generated LMX must preserve written anonymous groups, the current operand rule,
blank-line root termination and explicit tail cutters. A reference sequence is
already a Structure; it needs no additional grammar for a List container.
See the complete [receiver contract](LMX_semantics.en.md#functional-receivers)
and the [integration task](tasks/TZ_Receivers_Satisfies_2026-11-22.md).

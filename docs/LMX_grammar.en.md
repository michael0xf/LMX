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

This grammar specifies P0 lexing and structural parsing: fields, Frames, levels, closers, and Mix. Value, call, and kernel semantics belong to [L3](LMX_semantics.en.md). The old `Lingvamyxa_spec.txt` and [source comparison](source-comparison.en.md) preserve provenance, not a parallel norm. Only representative excerpts remain below; old examples do not extend the current rules.

<a id="structure"></a>

## 2. Structures, fields, and Frames

Sources: §§0, 3.2–3.4, 4.0, 4.8–4.9, 5, 15.

A grammar rule is universal within its domain: a name, type, nesting level, or translator convenience creates no separate syntax branch. A proposed exception or contradiction between rules requires explicit discussion and must not be hidden by special-case parsing.

P0 builds ordered Structures, named Frames, atoms, and Mix nodes with source spans. A Frame has a head and one argument Structure. Field order is preserved; an anonymous Structure is also a field. A physical line is not an abstract-tree container.

The colon separates a head from its argument Structure. It does not by itself mean assignment, a key–value pair, or a type annotation. `fn:`, `if:`, `int:`, `[]:`, and user heads use the same form. A consuming profile determines the head's meaning and field roles after parsing. Nesting alone does not make a Structure executable.

The target method Structure has addressable `args`, `return`, `var`, and `body` parts. `var` follows the result of `fn`/`fm` where present and precedes the body of every `fn`/`fm`/`sub`/`catch`. These are ordinary field roles: P0 does not populate `var` from the body.

Positional fields retain their order. Named inputs are ordinary nested Frames. Parameter names, table meaning, column count, named-argument validation, and execution are not inferred by P0 from visual alignment. There is no separate anonymous-function or label grammar; `outerLoop:` with a body is an ordinary Frame.

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

Sources: §§4.0–4.3.

`f(a, b, c)` is a compact Frame with a bounded argument Structure. `f: a b c` opens a short form at level N; its tail is at implicit level N + 1. An empty opening-line tail may continue with vertical children. A colon admits a bare, exact, or symbolic head.

Horizontal whitespace and commas separate fields of the current tail. A physical newline resets the counter to the completed physical line's level but does not by itself complete the Frame. Implicit levels of nested inline heads do not persist across the newline. The next item or marker determines continuation or closure under the shared [level model in §15](#levels); this model distinguishes the physical line's level from the depth of its open inline tail.

The composed `i: int: 5`, `ptr: int: 5`, `new_var: int()`, and `ptr: @: Model: 0` use ordinary nested Frames. The two-field `int: i 5` remains a Frame with two neighboring fields, while `@: ptr Model: Other` is a Frame with atom `ptr` and nested Frame `Model: Other`; P0 neither parses them by receiver name nor assigns semantic roles to their fields. `call: code data` is an ordinary Frame with two positional fields; code selection and data admission follow P0.

When an indented body follows existing inline arguments, the down/up level transition preserves a new Structure-field boundary. Vertical tokens must not simply be flattened into the inline tail. Ordinary P0 does not infer argument counts from head signatures.

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

An argument list is a Structure. P0 makes its sole anonymous container transparent; an anonymous field among other fields keeps its boundary. Headless atoms, expressions, and empty Structures are also valid in a body. P0 preserves order and nesting but does not decide whether a field is executed, discarded, or accepted as a value. A semantic consumer cannot retroactively change tree boundaries.

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

Expression-like sequences consist of atoms and operator fields. `print: a+b c` and `print: a + b c` produce the same structural split. The expression profile determines prefix, postfix, or infix roles, precedence, and operation meaning after P0. The C projection preserves ANSI C precedence and associativity; other backends use a separate profile, not a new structural grammar.

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

`(...)` bounds a Structure; empty `()` is allowed. `f()` is an empty compact Frame. `(): value` is a distinct form with head `()`, like `[]:`; it is not an empty Structure with an added value. The same short forms, separators, and levels apply inside brackets. A matching `)` or `]` completes both the bounded form and any short form still open inside it.

After a physical newline, a bounded continuation must remain deeper than the opening line: at the corresponding dotted level or a deeper indentation column. A line whose next token is the matching closer may return to the opener level. `end:` and terminal closers do not replace missing `)`/`]`.

`target[...]` is an attached index suffix. `[]:` is a symbolic head. Standalone `[a b]` is not a portable replacement for `(a b)` without explicit profile admission. Index contents use the same P0 and may contain nested calls, brackets, strings, and operators.

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

An ordinary one-level cut requires no explicit closing word. A deeper close uses an admitted tail cutter: `end: target`, a fence, or a terminal form in its admitted position. A body-level `return` does not become a universal tail cutter by spelling; terminal `return` closes its own executable definition in the position described in [§17](#close). A tail cutter does not close unmatched `(` or `[`.

### Brackets, literals, and empty lines

Within a bounded form, a newline itself neither closes the brackets nor performs the short-form step outwards. Continuation stays inside the bounded context; returning to the opening line's level before the matching bracket is permitted only for the matching closer itself ([§14](#bounded)). Newlines inside shielded strings, exact identifiers, and other lexical payload do not produce outer level events ([§24](#automaton)).

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

**Source excerpt** — `Lingvamyxa_spec.txt`, 3428–3432.

````text
fn: outer () (int)
    fn: inner (int: a) (int)
        return: a + 1
    int: a 1
return: inner(a)
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

`end: matrix` closes `[]: matrix`; not `end: [] matrix`. `end: fn` may be an alternative to `end: square` for the corresponding open function. Closure may cross several open implicit levels where position and profile admit it, but not unmatched bounded brackets. A named Frame does not require explicit `end:`: an ordinary admitted level cut also closes it. Bare `end` and `end <target>` are forbidden.

`return`, `return: value`, and `until: condition` are terminal-form candidates only in admitting contexts. Terminal `return` at the opening level of a named executable Structure, including an ordinary Structure without `fn`/`sub`, appends a return to its body and closes its Frame. The same receiver at body level or deeper is an internal return, not definition closure. `until:` may close a postcondition-loop body: an anonymous body closed by `until:` is an inline postcondition loop in the enclosing activation, and a named Frame closed by `until:` is an ordinary named Structure whose executable body is that loop — declaring it does not run it; only an explicit invocation does. No construct requires any of these trailers: they are P0 boundaries, not a condition of declaration. A named Structure closed by an ordinary level cut is declared by the same general resolution ([L3 §9](LMX_semantics.en.md#construction)); reaching the end of the body of a named Structure or a `sub` completes it without a result, and no return is synthesized there. Their spelling alone does not make these words universal tail cutters.

When identical targets occur at different levels, the closing line’s level participates: a parent-level close selects the parent target and cuts its open tail; an inner-level close selects the inner target. Ambiguous, invisible, or positionally invalid targets are rejected. `end:` in an ordinary body position is not executable and is rejected by close validation unless a profile explicitly defines another non-runtime meaning.

**Source excerpt** — `Lingvamyxa_spec.txt`, 6622–6623.

````text
fn: square (int(x)) (int)
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

Source: §§4.0.1, 4.1 and 15 of the previous specification; the author's direct correction of 2026-09-23.

A Frame's argument list is itself a Structure. If a sole anonymous Structure field occupies the whole positional sequence, P0 replaces it with its fields exactly once, independently of the head and emptiness. Thus `f()`, `f: ()`, and `f:` with an explicitly empty vertical body closed by `---` yield the same Frame with an empty Structure-body; `f(a b)` and `f: (a b)` likewise yield one list. An anonymous Structure among other fields or a named field remains a distinct field. A separate empty Structure value requires such a nontransparent position.

Parentheses are not a call marker. P0 does not label `f()` as a call or decide whether `f` exists: the same normalized Frame from `f()` and `f: ()` is passed to general head resolution. Calling, assignment, and declaration are defined by [semantics](LMX_semantics.en.md#construction), not by this spelling.

P0 rejects bare `f:` without arguments, a vertical body, or an explicit `---`. Bare `f` is an ordinary admitted atomic expression; P0 retains it as an atom and does not create a call Frame. Under [semantics](LMX_semantics.en.md#resolved-head-consumption), a bare name reads the resolved value or reference without executing the Structure; its explicit call is written `call: f`. The translator does not distinguish Frame forms by COLON/COMPACT or source spelling. An empty inline tail followed by a nonempty vertical body is valid. Bare `end` remains forbidden.

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

The previous minimal L2 profile lists grouping `(expr)`; prefixes `@`, `\`, `++`, `--`, `+`, `-`, `!`, `~`; postfixes `++`, `--`; infixes `+`, `-`, `*`, `/`, `%`, `=`, `!=`, `<`, `<=`, `>`, `>=`, `&&`, `||`, `&`, `|`, `^`; and the index suffix. Writing a prefix adjacent to its operand is style, not a mandatory P0 boundary.

In this profile, `=` is comparison, not assignment syntax or a named field. Updates use the ordinary head form `i: newValue`, whose meaning is determined later. The grammar does not invent a complete operation set, conversions, evaluation errors, or effect ordering.

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

Heads `@:`, `@@:`, `@@@:` and further depths share one structural form. The composed `ptr: @: Model: 0` builds nested Frames by the same rules as `i: int: 5`; two-field `@: ptr Model: Other` leaves two fields in `@`'s tail, the second being a nested Frame. P0 neither reorders arguments nor gives `@` a special order. Typing, declaration, and assignment follow construction of the complete Frame.

Prefix `@x` and `\x` differ from heads `@:` and paths `x\field`. Field and index chains bind tighter than prefix operators. `a[i][j][k]` addresses a multidimensional Array; `a[i]\[j]\[k]` follows references to separate Arrays. P0 also parses `s\[N]field`: in a Structure used as data, it is the zero-based Nth source occurrence of a root-level `field:` head, not an Array field; bare `s\field` is allowed only with one such occurrence. This does not permit duplicate data fields. Fields do not use C `.` or `->`. Address and type semantics are in [L3](LMX_semantics.en.md) and [L2](L2_spec_en.md).

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

Type heads such as `int`, `char`, and `size_t` do not require `c.`. An unresolved ordinary name does not automatically become a C name. `c.` is not universal declarator, label, or C-tag syntax. `C:` separately accepts explicitly supplied string text; a string does not become code merely by appearing within `L1:`, `L2:`, or `L3:`.

The file extension selects the outer profile, and the file itself is a Structure ([semantics](LMX_semantics.en.md#scope)). In L2/L3, `L1`, `L2`, and `L3` do not select a profile and resolve as ordinary names; a container with one of these names is neither erased from the source tree nor executed in place of the root. The previous direct L1 profile takes wrapperless `.lm1` input ([L1](L1_spec_en.md#scope)). The source excerpts below containing `L2:` describe the previous specification, not a rule of automatic profile selection. A catalog of library receivers is not grammar.

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

Events E are `LEVEL(K)`, `ATOM(value)`, `HEAD(value)`, `COLON`, `NEWLINE`, `COMMA_SEPARATOR`, `SEMICOLON_SEPARATOR`, opening/closing parenthesis, index, and Mix delimiters, a `TAIL_CUTTER` candidate, and `EOF`. Transitions follow the preceding sections. There is no separate P0 line, bracket, brace, or expression parser: all bounded forms enter recursive contexts of the same automaton.

In a shielded lexical mode, brackets, separators, colons, dots, and closer words are content until the mode closes. Matching-delimiter search must use those same modes; a separate character counter is insufficient. Passive mark inspection within an already delimited string payload is a separate bounded context, not removal of this shielding.

EOF completes the root after all forms admitting EOF closure. Unclosed bounded forms or lexical modes remain errors. Output O retains Structures, Frames, atoms, Mix flags, and spans; P0 does not execute code, resolve functions, or assign types.

<a id="ebnf"></a>

## 25. Surface-form EBNF

Source: §15.0. The formal notation and its original annotations are retained verbatim below. This is the same immutable source excerpt in both language versions; all constraints are explained in the preceding sections. `name`, `atom_or_value`, `symbolic_head`, and level events are read with the lexical rules, not as permission for arbitrary characters. English annotations within the notation are not language tokens.

This EBNF does not replace the automaton: bare `f:` without an argument and explicit closure is invalid; `newline/source-level composition` denotes the stated transitions, not arbitrary whitespace separation.

Under the general §4.0.1 rule, P0 normalizes the sole anonymous Structure occupying the whole list before consumption: `f()`, `f: ()`, and an explicitly empty vertical form yield the same Frame with an empty Structure-body. The rule also applies to a nonempty container. Read the historical notation below with this clarification.

The annotation on historical `nullary_line_body` is not a P0 check of name availability, role, or arity: a bare identifier is parsed as an atom by the common grammar. Those checks follow construction of the complete model under [the single semantic rule](LMX_semantics.en.md#resolved-head-consumption). The immutable excerpt below is retained as a source, not permission for a separate nullary-receiver parser.

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

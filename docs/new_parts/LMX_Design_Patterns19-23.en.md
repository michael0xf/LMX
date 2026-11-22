# Design patterns in Lingvamyxa: 19–23

English edition. 21 November 2026.

This covers the five remaining patterns in the list of 23: Singleton, Abstract Factory, Flyweight, Mediator and Interpreter. The first eighteen appear in the preceding parts of the series. The order is instructional, not a popularity ranking. A concise Python implementation is the architectural starting point: related LMX methods share DATA, with demo placed in the same natural group.

Each pattern has a common scenario in LMX, Python, Java, C++, C#, TypeScript, Go and Rust. The individual comparison files contain all eight programs and their measurements. This guide reproduces exactly the same LMX programs and explains how they work.

## Reading the examples

Each example is an independent program. A callable's DATA is its actual parent. A method need not use every field of the group's DATA. `@: selected method` stores a method reference; `selected()` invokes it. A separate `fn` contract is needed only when a separately declared signature is part of the task.

An uninitialized declared input may receive a same-named value from the immediate caller. A free name with no own declaration may refer to a writable place in that caller. Autofill does not replace an existing default. Passing an established alias preserves its original place; the older transitive fallback does not turn a copy into an alias. `private` blocks implicit dynamic binding in both directions, not all explicit access.

`node\` selects lexical stored data; it is not a parent operator. Explicit paths are used for state that must survive separate calls. `copy` and `merge` copy source graph material under their respective contracts. A local working value and stored graph data are distinct. Data overlays provide the settings of the copy. Activation-local values do not enter the copy automatically.

A physical blank line closes the entire root syntax block. An inner `---` is used when the enclosing structure must continue after a nested structure ends. EOF can close the final block.

[Binding rules](../LMX_semantics.en.md#binding-places) · [Import][D] · [Block boundaries][E] · [Operand contract](../LMX_semantics.en.md#operand-receiver)

**Copying and field streams.** `import`, `copy`, and `merge` use ordinary CODE arguments in every placement. `copy` accepts one admitted source, while `merge` accepts at least two; both emit field streams. When one object is required, an explicit group collects that result: `(copy(Product))` or `(merge(Model Settings))`. The receiving structure is not an additional merge source. Written receivers remain in the source graph; namespace processing consumes their results. Ordinary W/E rules still apply after grouping. [Copying, composition and grouping][S]

## Comparison table

[Excel with formulas](LMX_Comparison_19-23.xlsx) · [PDF](LMX_Comparison_19-23.pdf)

The main metric counts non-whitespace characters in each main application program, including declarations, imports, necessary wrappers and demo. External invocation, main, printing, test harnesses and runtime code are excluded. Identifiers are not normalized; Python omits optional type annotations. Ratios are calculated from language totals, not averaged across patterns. The separate explanatory kernel template in Interpreter is excluded; its application-side copy line is counted.

| Language | Total non-whitespace characters, 19–23 | Relative to LMX |
|---|---:|---:|
| LMX | 1393 | 1.00× |
| Python | 1627 | 1.17× |
| Java | 1970 | 1.41× |
| C++ | 1778 | 1.28× |
| C# | 2144 | 1.54× |
| TypeScript | 1957 | 1.40× |
| Go | 1848 | 1.33× |
| Rust | 2165 | 1.55× |

## 19. Singleton

One provider repeatedly returns references to the same settings object.

```lmx
Settings:
    int: value 0
    return: @
    get:
        return: Settings

Demo:
    return: int
    run:
        @: first Settings\get()
        @: second Settings\get()
        first\value := 7
        return: second\value
```

**Invocation:** `Demo\run()`. **Expected result: 7.**

Both get calls return the same Settings. The direct write through first changes its field, so second reads 7. Each demo explicitly writes 7, making repeated runs deterministic. An additional check writes through the second reference and reads through the first.

Uniqueness is scoped to one provider in one serial execution context; in LMX this is one Message. The example supplies one object rather than forbidding a user from deliberately constructing or copying another object. Cross-process uniqueness and concurrent initialization are outside the scenario. Rust represents the context with thread_local; cloning Rc copies the reference, not Settings, and Cell provides the mutable scalar without locks. The other programs likewise operate in one serial context.

**LMX: 141** non-whitespace characters. [Eight-language comparison](19_singleton_comparison.md).

[Refactoring.Guru — Singleton](https://refactoring.guru/design-patterns/singleton) · [Refactoring.Guru — Singleton in Python](https://refactoring.guru/design-patterns/singleton/python/example)

## 20. Abstract Factory

One consumer obtains two matching products from the selected factory family.

```lmx
Button:
    int: value
    return: int
    render:
        return: value

Frame:
    int: value
    @: button
    return: int
    render:
        return: value + button\render()

Light:
    return: @
    button:
        return: (merge(Button; (int: value 1)))
    frame:
        return: (merge(Frame; (int: value 10)))

Dark:
    return: @
    button:
        return: (merge(Button; (int: value 2)))
    frame:
        return: (merge(Frame; (int: value 20)))

Client:
    @: factory
    return: int
    render:
        @: button factory\button()
        @: frame factory\frame()
        return: frame\render()
    demo:
        return: render(factory := Light) + render(factory := Dark)
```

Each factory method explicitly groups its merge stream before returning one product. The factory DATA is not a source of that composition.

**Invocation:** `Client\demo()`. **Expected result: 33.**

Client\render(factory := Light) obtains button 1 and frame 10; Frame.render calls Button.render and returns 11. The same Client\render(factory := Dark) obtains 2 and 20 and returns 22. One factory argument selects the family, and both products are created through it. Repeated factory-method calls produce independent products.

Two configuration families and two product roles; the selected factory and the consumer’s workflow keep the family consistent. Products share a representation and differ in configuration, so this scenario needs no LightButton/DarkButton subclasses. No language here forbids a caller from deliberately mixing families. This does not compare GUI libraries or automatic proofs of compatibility. C++ expresses the factory interface with two function pointers, preserving the same runtime choice of family.

**LMX: 462** non-whitespace characters. [Eight-language comparison](20_abstract_factory_comparison.md).

[Refactoring.Guru — Abstract Factory](https://refactoring.guru/design-patterns/abstract-factory) · [Refactoring.Guru — Abstract Factory in Python](https://refactoring.guru/design-patterns/abstract-factory/python/example)

## 21. Flyweight

Repeated requests for a kind return one shared object; each use supplies its own external state.

```lmx
glyphs:
    int: kind
    return: @
    immutable: thin: int: width 2
    immutable: thick: int: width 3
    get:
        if: kind = 0
            return: thin
        return: thick
    drawing:
        @: glyph
        int: position
        return: int
        render:
            return: glyph\width * 10 + position
        demo:
            @: first get(0)
            @: second get(0)
            @: third get(1)
        return: render(first 3) + render(second 7) + render(third 1)
```

**Invocation:** `glyphs\drawing\demo()`. **Expected result: 81.**

`first` and `second` refer to the same `thin`; `third` refers to the distinct `thick` object. `render` reads the named `width` field and receives a separate position: `23 + 27 + 31 = 81`. Python uses the same named-field model through `@dataclass(frozen=True)` with `width: int`, replacing the one-element tuple.

`drawing` is nested in `glyphs`, so `get` is lexically visible. The DATA of `render` and `demo` is `drawing`; the DATA of `get` is `glyphs`. There are no blank lines inside the root block. The terminal `return` at the declaration level of `demo` closes its body; `render(first 3)` supplies two positional arguments.

`immutable` protects the shared width from changes; a const binding alone does not make its contents immutable. All eight versions use two prebuilt flyweights, without dynamic caching or eviction. The `width` field stands for a potentially larger set of shared properties. This demonstrates state sharing and identity, rather than a measured memory saving. In Go, keeping shared data unchanged remains an API contract.

**LMX: 281**, **Python: 309** non-whitespace characters. [Eight-language comparison](21_flyweight_comparison.md).

[Refactoring.Guru — Flyweight in Python, conceptual example](https://refactoring.guru/design-patterns/flyweight/python/example)

## 22. Mediator

Two components report their actions to a mediator; only the mediator determines the other component’s response.

```lmx
Room:
    control:
        int: enabled 0
        toggle:
            node\enabled := 1 - node\enabled
            notify(event := 1)
    ---
    fan:
        int: running 0
        stop:
            node\running := 0
            notify(event := 2)
    ---
    int: event
    notify:
        if: event = 1
            fan\running := control\enabled
        if: event = 2
            control\enabled := 0

Demo:
    return: int
    run:
        @: room (copy(Room))
        room\control\toggle()
        int: first room\fan\running
        room\fan\stop()
        return: first * 10 + room\control\enabled
```

**Invocation:** `Demo\run()`. **Expected result: 10.**

After toggle, both flags equal 1, so first = 1. Calling stop clears running and makes the mediator clear enabled. The result is 1 × 10 + 0 = 10. The reverse reaction demonstrates coordination in both directions through the mediator.

This synchronous example has two fixed components and two events. Each event identifies its sender, so no general subscriber registry is needed. The mediator’s direct writes do not raise further events and cannot create a notification loop. Rust uses a local mediator closure and Cell for the same links without cyclic ownership. Copying an already wired C++ Room and moving components between mediators are outside the scenario.

**LMX: 350** non-whitespace characters. [Eight-language comparison](22_mediator_comparison.md).

[Refactoring.Guru — Mediator in Python, conceptual example](https://refactoring.guru/design-patterns/mediator/python/example)

## 23. Interpreter

One retained expression, `(x + 3) + x`, is evaluated with two values of its variable. LMX stores it in the graph of `calculate`, where the variable is named `n`; Python retains the same composition in the `tree` closure.

### Application code — included in the count

<!-- counted-code: LMX -->
```lmx
operands:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    add:
        return: \left + \right[0]
    example:
        int: n
        return: int
        calculate:
            return: (n add 3) add n
        demo:
            return: calculate(2) + calculate(5)
```

**Invocation:** `operands\example\demo()`. **Expected result: 20.** The external invocation is excluded from the count.

`calculate(2)` evaluates `(2 + 3) + 2 = 7`; `calculate(5)` evaluates `(5 + 3) + 5 = 13`; `demo` adds the results. Both methods use the nested `example` group as DATA. That group sees `add` lexically, so no separate import is needed. The DATA of `add` itself is `operands`.

`copy: sys\OPERANDS_TEMPLATE` supplies the common operand header. `PASS_ARGS_AS_IS 0` passes references to prepared values. `\left` reads the left value and `\right[0]` reads the first right value. For the outer `add`, the left value is already the result of the inner operation. The operation has its method's name; no separate `sys\operand` registration is needed. [Operand contract](../LMX_semantics.en.md#prepared-operands)

### Kernel template — explanatory code excluded from the count

<!-- uncounted-code: kernel-reference -->
```lmx
sys:
    OPERANDS_TEMPLATE:
        @: left
        []: @ right
        const: int: PASS_ARGS_AS_IS 0
        const: int: PRIORITY priority("+")
```

The template uses general `@` references rather than constraining the arguments to `int`. Inside `sys`, the priority method is available as `priority("+")`. The template supplies no `return`: the concrete result is declared once in the application's `operands` as `return: int`. No repeated DATA declaration needs overriding, and no special copy rule is introduced.

The application count includes the line that uses the template. Its definition belongs to the kernel and is excluded just as Python's and other languages' standard-library internals are excluded. It is shown here to make the origins of `left`, `right`, and the settings visible.

Mode `PASS_ARGS_AS_IS 1` passes original occurrences for explicit evaluation through `sys\eval`; this example only needs mode `0`. Dereferencing alone does not execute code. The comparison demonstrates a retained computation and two execution contexts. A separate text parser, printing traversal, and a general runtime expression-tree builder are outside the scenario.

**LMX: 159** non-whitespace characters, **266** characters including whitespace/LF, **12** lines. **Python: 185** non-whitespace characters. LMX is **14.05%** shorter by the primary metric in this pair. [Eight-language comparison](23_interpreter_comparison.md).

[GoF — Interpreter, intent, grammar, participants and sample code (MIT-hosted text)](https://people.csail.mit.edu/addy/pattern/pat5c.htm)

## Verification

The LMX listings are identical to the individual comparison files. They are aligned with the current rules and the author’s clarifications. Execution and review status for the other languages is recorded in each comparison file. The Excel and PDF figures were calculated from these same listings.

[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md


[S]: ../LMX_semantics.en.md#merge-two-forms

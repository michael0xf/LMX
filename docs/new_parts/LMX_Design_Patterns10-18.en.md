# Design patterns in Lingvamyxa: 10–18

English edition. 21 November 2026.

This continues the first nine examples with State, Chain of Responsibility, Composite, Proxy, Facade, Builder, Prototype, Memento and Bridge. The order is instructional, not a popularity ranking. A concise Python implementation is the architectural starting point: related LMX methods share DATA, with demo placed in the same natural group.

Each pattern has a common scenario in LMX, Python, Java, C++, C#, TypeScript, Go and Rust. The individual comparison files contain all eight programs and their measurements. This guide reproduces exactly the same LMX programs and explains how they work.

## Reading the examples

Each example is an independent program. A callable's DATA is its actual parent. A method need not use every field of the group's DATA. `@: selected method` stores a method reference; `selected()` invokes it. A separate `fn` contract is needed only when a separately declared signature is part of the task.

An uninitialized declared input may receive a same-named value from the immediate caller. A free name with no own declaration may refer to a writable place in that caller. Autofill does not replace an existing default. Passing an established alias preserves its original place; the older transitive fallback does not turn a copy into an alias. `private` blocks implicit dynamic binding in both directions, not all explicit access.

`node\` selects lexical stored data; it is not a parent operator. Explicit paths are used for state that must survive separate calls. `copy` and `merge` copy source graph material under their respective contracts. A local working value and stored graph data are distinct. Product and snapshot examples write their intended values into the graph before copying it.

A physical blank line closes the entire root syntax block. An inner `---` is used when the enclosing structure must continue after a nested structure ends. EOF can close the final block.

[Binding rules](../LMX_semantics.en.md#binding-places) · [Import][D] · [Block boundaries][E]

**Copying and field streams.** `import`, `copy`, and `merge` use ordinary CODE arguments in every placement. `copy` accepts one admitted source, while `merge` accepts at least two; both emit field streams. When one object is required, an explicit group collects that result: `(copy(Product))` or `(merge(Model Settings))`. The receiving structure is not an additional merge source. Written receivers remain in the source graph; namespace processing consumes their results. Ordinary W/E rules still apply after grouping. [Copying, composition and grouping][S]

## Comparison table

[Excel with formulas](LMX_Comparison_10-18.xlsx) · [PDF](LMX_Comparison_10-18.pdf)

The main metric counts non-whitespace characters in each complete displayed program, including declarations, imports, necessary wrappers and demo. External invocation, main, printing, test harnesses and runtime code are excluded. Identifiers are not normalized; Python omits optional type annotations. Ratios are calculated from language totals, not averaged across patterns.

| Pattern | LMX | Python | Java | C++ | C# | TypeScript | Go | Rust |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| State | 152 | 250 | 326 | 307 | 267 | 283 | 325 | 340 |
| Chain of Responsibility | 295 | 297 | 549 | 361 | 461 | 437 | 441 | 434 |
| Composite | 301 | 295 | 480 | 453 | 469 | 499 | 312 | 379 |
| Proxy | 191 | 181 | 346 | 209 | 274 | 256 | 217 | 220 |
| Facade | 170 | 204 | 274 | 236 | 286 | 316 | 244 | 235 |
| Builder | 355 | 499 | 574 | 436 | 581 | 514 | 543 | 565 |
| Prototype | 226 | 209 | 280 | 165 | 273 | 219 | 199 | 225 |
| Memento | 333 | 396 | 460 | 381 | 450 | 440 | 450 | 456 |
| Bridge | 276 | 320 | 645 | 399 | 487 | 490 | 413 | 425 |
| **Total** | **2299** | **2651** | **3934** | **2947** | **3548** | **3454** | **3144** | **3279** |
| **Total / LMX** | 1.000× | 1.153× | 1.711× | 1.282× | 1.543× | 1.502× | 1.368× | 1.426× |

## 10. State

The current state chooses the behavior of the next call.

```lmx
machine:
    return: int
    closed:
        state := opened
        return: 0
    opened:
        state := closed
        return: 1
    demo:
        @: state closed
        int: result state()
        result += state()
        result += state()
        return: result
```

**Invocation:** `machine\demo()`. **Expected result: 1.**

demo starts with state = closed. The first call returns 0 and selects opened, the second returns 1 and selects closed, and the third returns 0. Three statements make effect order explicit. Their sum is 1.

States are callable behaviors; a separate State class hierarchy is not required. Every demonstration creates a fresh context. Marking state private in LMX would block this implicit binding; the example does not do so.

**LMX: 152** non-whitespace characters. [Eight-language comparison](10_state_comparison.md).

[Refactoring.Guru — State in Python, conceptual example](https://refactoring.guru/design-patterns/state/python/example)

## 11. Chain of Responsibility

Two replaceable handlers: the second receives a request only if the first declines.

```lmx
chain:
    int: value
    @: first negative
    @: second even
    return: int
    negative:
        if: value < 0
            return: 1
        return: 0
    even:
        if: value % 2 = 0
            return: 2
        return: 0
    dispatch:
        int: result first()
        if: result
            return: result
        return: second()
    demo:
        int: result dispatch(-2)
        result += dispatch(4)
        result += dispatch(3)
        result += dispatch(-2; even; negative)
        return: result
```

**Invocation:** `chain\demo()`. **Expected result: 5.**

With the default order, requests -2, 4, 3 yield 1, 2, 0. An explicit reversed order yields 2 for the same -2. Their sum is 5. Once the first handler accepts a request, the second is not invoked.

A minimal chain of exactly two configurable handlers. The first accepting handler ends processing; if both decline, the result is 0. Arbitrary chain length, an empty chain and asynchronous handlers are outside this scenario.

**LMX: 295** non-whitespace characters. [Eight-language comparison](11_chain_of_responsibility_comparison.md).

[Refactoring.Guru — Chain of Responsibility in Python, conceptual example](https://refactoring.guru/design-patterns/chain-of-responsibility/python/example)

## 12. Composite

A leaf and a binary composition expose the same total operation; Pair recursively adds its children’s results.

```lmx
Leaf:
    int: value
    return: int
    total:
        return: value

Pair:
    @: left
    @: right
    return: int
    total:
        return: left\total() + right\total()
    demo:
        @: a (merge(Leaf; (int: value 2)))
        @: b (merge(Leaf; (int: value 3)))
        @: c (merge(Leaf; (int: value 5)))
        @: inner (merge(Pair; (@: left b; @: right c)))
        @: tree (merge(Pair; (@: left a; @: right inner)))
        return: tree\total()
```

Each merge has two explicit sources; grouping its output stream constructs one object for the corresponding reference variable.

**Invocation:** `Pair\demo()`. **Expected result: 10.**

Leaves a=2, b=3, c=5 are created; inner pairs b with c, and tree pairs a with inner. inner.total yields 8 and tree.total yields 10. The same operation works for further nesting of Pair.

A finite acyclic binary tree: every internal node has exactly two children and depth is arbitrary. LMX merge copies the used graph and redirects references, rather than sharing mutable a/b/c objects. Other versions use references or borrows. The comparison covers construction and reading without later leaf changes; copying costs and tree-editing semantics are not equated.

**LMX: 301** non-whitespace characters. [Eight-language comparison](12_composite_comparison.md).

[Refactoring.Guru — Composite in Python, conceptual example](https://refactoring.guru/design-patterns/composite/python/example)

## 13. Proxy

The proxy and service share one interface. The proxy rejects a negative request and delegates an admitted one.

```lmx
requests:
    int: value
    return: int
    real:
        return: value * 2
    proxy:
        if: value < 0
            return: 0
        return: real()
    demo:
        @: request proxy
        int: denied request(-3)
        int: allowed request(7)
        request := real
        return: denied + allowed + request(-3)
```

**Invocation:** `requests\demo()`. **Expected result: 8.**

Through proxy, request(-3) returns 0 without calling real. request(7) delegates and returns 14. After request is replaced by real, the same negative request returns −6. The demo totals 0 + 14 − 6 = 8.

This is a minimal protection proxy with a fixed service and a numeric admission rule. It preserves rejection and delegation; authentication, caching and a general proxy constructor are outside the scenario. The example defines the policy, not the language.

**LMX: 191** non-whitespace characters. [Eight-language comparison](13_proxy_comparison.md).

[Refactoring.Guru — Proxy in Python, conceptual example](https://refactoring.guru/design-patterns/proxy/python/example)

## 14. Facade

An order quote combines product pricing and shipping; the client calls one quote operation.

```lmx
checkout:
    int: quantity
    int: price
    int: weight
    int: zone
    return: int
    subtotal:
        return: quantity * price
    fee:
        return: weight * 2 + zone * 5
    quote:
        return: subtotal() + fee()
    demo:
        return: quote(3; 10; 2; 1)
```

**Invocation:** `checkout\demo()`. **Expected result: 39.**

quote(3; 10; 2; 1) obtains subtotal = 30 and fee = 9, then returns 39. The additional case quote(1; 8; 3; 2) returns 24.

The facade coordinates two independently callable operations for product pricing and shipping. They need no separate namespace or class to remain separate operations: as in Python, they share one group. Payment, inventory transactions and rounding rules are outside the task.

**LMX: 170** non-whitespace characters. [Eight-language comparison](14_facade_comparison.md).

[Refactoring.Guru — Facade in Python, conceptual example](https://refactoring.guru/design-patterns/facade/python/example)

## 15. Builder

Stepwise rectangle construction that returns an independent finished product.

```lmx
Rectangle:
    int: width 0
    int: height 0
    return: int
    area:
        return: width * height
    builder:
        int: value
        return: Rectangle
        set_width:
            node\width := value
        set_height:
            node\height := value
        finish:
            return: (copy(Rectangle))
    ---
    demo:
        builder\set_width(3)
        builder\set_height(4)
        @: first builder\finish()
        builder\set_width(5)
        builder\set_height(2)
        @: second builder\finish()
        return: first\area() + second\area()
```

**Invocation:** `Rectangle\demo()`. **Expected result: 22.**

After the first two steps, first has dimensions 3 and 4. Updating the workpiece to 5 and 2 does not change first: finish creates a separate graph. The areas are 12 and 10. Every demo sets both dimensions before its first finish, so repeated runs also return 22.

One product type, two steps, builder reuse and independent results. A separate Director and multiple product representations are outside the example. Dimensions are ordinary integers; geometric validation is not added in any language.

**LMX: 355** non-whitespace characters. [Eight-language comparison](15_builder_comparison.md).

[Refactoring.Guru — Builder](https://refactoring.guru/design-patterns/builder) · [Refactoring.Guru — Builder in Python](https://refactoring.guru/design-patterns/builder/python/example)

## 16. Prototype

Copy an already configured instance, preserving its behavior and independent fields.

```lmx
Point:
    int: x 3
    int: y 4
    return: int
    score:
        return: x * 10 + y
    demo:
        @: original (copy(Point))
        original := parent(original\score)
        original\x := 7
        @: replica (copy(original))
        replica := parent(replica\score)
        replica\y := 9
        return: original\score() + replica\score()
```

**Invocation:** `Point\demo()`. **Expected result: 153.**

original remains (7,4), while replica becomes (7,9). Both retain score, which reads their own instance data. Changing the copy’s y does not change the original’s y; later changes to original.x likewise do not affect replica.x.

After each grouped copy, the reference explicitly selects the actual parent of the copied score method. Field writes and method execution therefore use the same owner; neither grouping-wrapper identity nor a stable old primitive-field address is assumed.

One concrete type with two scalar fields is cloned. The example does not compare deep copying of nested mutable objects, external resources or arbitrary subtype hierarchies. copy has a broader graph contract; this comparison exercises only the scenario shared by all programs.

**LMX: 226** non-whitespace characters. [Eight-language comparison](16_prototype_comparison.md).

[Refactoring.Guru — Prototype](https://refactoring.guru/design-patterns/prototype) · [Refactoring.Guru — Prototype in Python](https://refactoring.guru/design-patterns/prototype/python/example)

## 17. Memento

The state owner creates two snapshots and restores them when the caretaker requests it.

```lmx
Editor:
    int: value
    int: state 0
    return: int
    set:
        node\state := value
    read:
        return: state
    history:
        @: snapshot
        return: Editor
        save:
            return: (copy(Editor))
        restore:
            node\state := snapshot\state
    ---
    demo:
        set(5)
        @: first history\save()
        set(9)
        @: second history\save()
        set(13)
        history\restore(snapshot := first)
        int: low read()
        history\restore(snapshot := second)
        return: low * 10 + read()
```

**Invocation:** `Editor\demo()`. **Expected result: 59.**

The first save captures 5 and the second captures 9. set(13) changes only the current Editor. restore(first) restores 5, retained in low; restore(second) restores 9. The result is 5×10+9. The caretaker uses only save, restore and the current object’s ordinary read operation.

This is a minimal Memento with a cooperative API contract: the caretaker neither reads nor changes snapshot internals. Protection against deliberate access, snapshot immutability, owner validation and history limits are not claimed for any version. LMX private controls implicit binding and would not provide that protection. State consists of one number; no external resources are copied.

**LMX: 333** non-whitespace characters. [Eight-language comparison](17_memento_comparison.md).

[Refactoring.Guru — Memento](https://refactoring.guru/design-patterns/memento) · [Refactoring.Guru — Memento in Python](https://refactoring.guru/design-patterns/memento/python/example)

## 18. Bridge

Two controls combine with two device implementations. The control and device can change independently.

```lmx
bridge:
    int: level
    @: output
    return: int
    radio:
        return: level * 2
    speaker:
        return: level * 3
    basic:
        return: output()
    boost:
        level += 1
        return: output()
    demo:
        @: control basic
        @: output radio
        int: total control(4)
        output := speaker
        total += control(4)
        control := boost
        total += control(4)
        output := radio
        return: total + control(4)
```

**Invocation:** `bridge\demo()`. **Expected result: 45.**

At level = 4, basic/radio returns 8, basic/speaker 12, boost/speaker 15 and boost/radio 10. Their sum is 45. Replacing output does not require replacing control, and vice versa.

This is a functional Bridge: independently varying abstractions and implementations are functions, not mandatory class hierarchies. The demo exercises both axes, rather than only one operation with a replaceable strategy. Returned numbers model device output; no real drivers are implemented.

**LMX: 276** non-whitespace characters. [Eight-language comparison](18_bridge_comparison.md).

[Refactoring.Guru — Bridge in Python, conceptual example](https://refactoring.guru/design-patterns/bridge/python/example)

## Verification

The LMX listings are identical to the individual comparison files. They were reviewed against the agreed rules and the author’s clarifications; the LMX kernel was not run here. Actual execution and static-review status for the other languages is recorded in each comparison file. The Excel and PDF figures were calculated from these same listings.

[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md

[S]: ../LMX_semantics.en.md#merge-two-forms

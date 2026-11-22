# Design Patterns in Lingvamyxa

English edition · Revised 21 November 2026 · Aligned with docs

This edition starts from the Python programs in the companion comparisons and expresses their organization through LMX structures, shared DATA, and ordinary calls. The author's compact Decorator is reproduced exactly. Related methods, including `demo`, belong to a natural group; separate demonstration containers and standalone signatures are introduced only when the program actually needs them.

The accepted language changes are assumed to apply. These are documented LMX examples with expected results; **they have not been executed on the LMX kernel**. Each section is independent, and its main source block matches the corresponding comparison file exactly.

## Contents

The order follows the companion files and serves navigation, rather than ranking industry popularity.

| No. | Pattern | Scenario | Result |
|---|---|---|---:|
| 1 | [Iterator](#iterator) | A user-defined loop and a local accumulator | 12 |
| 2 | [Strategy](#strategy) | Replace doubling with tripling | 25 |
| 3 | [Factory](#factory) | Copy a prepared prototype | 32 |
| 4 | [Adapter](#adapter) | Reconcile parameter order | 5 |
| 5 | [Observer](#observer) | Notify two stored subscribers | 11 |
| 6 | [Decorator](#decorator) | Compose a fixed wrapper chain | 63 |
| 7 | [Command](#command) | Modify the caller's local state | 4 |
| 8 | [Template Method](#template-method) | Replace steps in a fixed sequence | 35 |
| 9 | [Visitor](#visitor) | Obtain node actions from the caller's context | 12 |

## Reading the programs

**Structures group data and methods.** An executed structure uses its actual parent as DATA. Several methods can therefore share declarations of inputs, state, references, and `return`. Each method uses the fields it needs; this does not require an artificial container for `demo`. Working places belong to individual activations. A method invoked only for effects need not manufacture a numeric result merely because the group's DATA also describes the result used by another method. Its caller does not consume a result. [Calls and binding](../LMX_semantics.en.md#structural-call)

**References are ordinary values.** `@: selected twice` initializes a reference with the method value `twice`; it does not call it. `selected := thrice` changes that reference. Normal call admission and the selected method's DATA still govern invocation. `fn: Name Data` remains available for an explicitly requested standalone signature requirement. None of these nine programs needs that additional contract.

**Autofill and writable context serve different purposes.** A declared, uninitialized input can receive a copy of a same-named value from its immediate caller. A free name without its own declaration can identify an immediate caller's local place. An established alias can be forwarded without changing that place. The older transitive fallback must not be mistaken for such an alias; Command deliberately establishes the intermediary's connection before executing its action. A ready own default is retained unless explicitly replaced.

**Lexical access is explicit.** `node\` selects lexical binding; it is not a parent operator. The examples use it for state that must persist in the graph. Bare assignments act on the place selected for the current execution. `private` restricts implicit dynamic binding in both directions: private sources are not supplied, and private lexical declarations are not dynamically replaced. Explicit passing and ordinary lexical visibility retain their rules. [Binding rules](../LMX_semantics.en.md#binding-places)

**Syntax preserves structure.** A blank physical line, including a whitespace-only line, ends the whole ordinary syntactic block at the virtual level −1 above root. Inner `---` remains useful for closing a nested structure while retaining its enclosing root; Visitor uses it. EOF closes the final ordinary block. Protected lexical forms retain their own rules. [Block boundaries][E]

**Declarations and imports retain their roles.** A supplied declaration form can be executed repeatedly while its body uses the resulting place, as in Iterator. `import` exposes const root declarations from DATA, including user structures; it neither imports ordinary mutable variables nor changes a method's actual parent. Factory uses it to expose `create`. [Declarations and import][D]

**Copying and field streams.** `import`, `copy`, and `merge` use ordinary CODE arguments in every placement. `copy` accepts one admitted source, while `merge` accepts at least two; both emit field streams. When one object is required, an explicit group collects that result: `(copy(Product))` or `(merge(Model Settings))`. The receiving structure is not an additional merge source. Written receivers remain in the source graph; namespace processing consumes their results. Ordinary W/E rules still apply after grouping. [Copying, composition and grouping][S]

<a id="iterator"></a>

## 1. Iterator — a user-defined loop

```lmx
numbers:
    int: position 0
    return: int
    next:
        throws: Stop
        if: node\position >= 3
            throw: Stop()
        node\position += 1
        return: node\position
    demo:
        node\position := 0
        int: total 0
        cycles\iterate: int: item numbers\next()
            item *= 2
            total += item
        return: total

cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()
```

**Call:** `numbers\demo()`. **Expected result: 12.**

The iterator owns its position, while `cycles\iterate` repeatedly executes a supplied declaration and body. The demonstration belongs alongside `next` in `numbers`.

`node\position` selects the lexical graph field, so successive calls observe the updated position. `demo` resets it and creates local `total`. Passing `int: item numbers\next()` preserves the declaration form; each `iteration()` executes it and establishes or updates the place used by `body()`.

The body doubles 1, 2, and 3 and accumulates 2 + 4 + 6. The next request raises `Stop`. `catch` covers the whole loop body, so a `Stop` raised by the processing body also ends the loop. Zero remains a possible element value; it is not an end marker.

The qualified call `cycles\iterate:` avoids importing a single name. The local accumulator requires no graph publication.

[Eight-language comparison: 01_iterator_comparison.md](01_iterator_comparison.md).

<a id="strategy"></a>

## 2. Strategy — a replaceable operation

```lmx
strategy:
    int: value
    @: operation twice
    return: int
    twice:
        return: value * 2
    thrice:
        return: value * 3
    apply:
        return: operation()
    demo:
        @: selected twice
        int: first apply(5; selected)
        selected := thrice
        return: first + apply(5; selected)
```

**Call:** `strategy\demo()`. **Expected result: 25.**

The Python functions `twice`, `thrice`, `apply`, and `demo` become methods of one group. Its DATA describes the numeric input, the default operation reference, and the result.

`@: selected twice` initializes the driver's reference. `apply(5; selected)` explicitly fills `value` and `operation`; `operation()` then invokes the chosen method. That method receives its own copy of `value` through autofill from `apply`.

After `selected := thrice`, the second call returns 15 instead of 10, giving 25 overall. The ordinary default remains meaningful: `apply(5)` uses `twice`. A same-named local does not silently replace that ready default.

The reference changes, the consumer stays fixed, and no separate signature declaration is required for this concrete scenario. The group's extra fields need not be used by every arithmetic method.

[Eight-language comparison: 02_strategy_comparison.md](02_strategy_comparison.md).

<a id="factory"></a>

## 3. Factory — products copied from a prototype

```lmx
Product:
    int: payload
    return: int
    read:
        return: payload
    create:
        return: Product
        small:
            node\payload := 10
            return: (copy(Product))
        large:
            node\payload := 20
            return: (copy(Product))

add1:
    @: product Product
    return: int
    execute:
        return: product\read() + 1
    demo:
        import: Product
        int: first execute(create\small())
        return: first + execute(create\large())
```

**Call:** `add1\demo()`. **Expected result: 32.**

The author's `Product` structure supplies the prototype, its reader, and two factory methods. The consumer and its demonstration share `add1`.

Inside `create`, `node\payload` selects the lexical field in `Product`, even though it is outside the factories' immediate parent. Each factory sets its value before `(copy(Product))` creates a separate product. `execute` reads the supplied product and adds one: the two calls return 11 and 21.

If both products are retained, their readers continue to return 10 and 20 after the second creation; the prototype itself contains 20. `import: Product` exposes `create`, while `execute` is already available in its own group.

This combines factory methods and prototype copying. The comparison concerns one numeric payload and usable product methods; it does not equate other languages' shallow copies with every behavior of a general LMX graph copy.

[Eight-language comparison: 03_factory_method_node_prototype_comparison.md](03_factory_method_node_prototype_comparison.md).

<a id="adapter"></a>

## 4. Adapter — reconciling argument order

```lmx
legacy:
    int: right
    int: left
    return: int
    subtract:
        return: left - right

adapter:
    int: left
    int: right
    return: int
    subtract:
        return: legacy\subtract(right; left)
    demo:
        return: subtract(8; 3)
```

**Call:** `adapter\demo()`. **Expected result: 5.**

The legacy method declares `right` before `left`. The adapter presents `left` before `right`, retaining two DATA descriptions because the different orders are the interface mismatch being resolved.

`subtract(8; 3)` gives the adapter `left = 8` and `right = 3`. It delegates `legacy\subtract(right; left)`, sending 3 to the legacy first input and 8 to the second. The result is 5.

Calling `legacy\subtract(8; 3)` directly would instead produce −5. Equal primitive types do not establish the intended meanings of positions.

`demo` directly calls the adapter. The unused intermediate callable variable and its extra type declaration have also been removed from the other languages. The adapter still performs real delegation; the arithmetic has not been replaced with a different standalone implementation.

[Eight-language comparison: 04_adapter_comparison.md](04_adapter_comparison.md).

<a id="observer"></a>

## 5. Observer — two subscribers and shared state

```lmx
observer:
    int: value
    int: last 0
    int: total 0
    @: first remember
    @: second accumulate
    return: int
    remember:
        node\last := value
    accumulate:
        node\total += value
    notify:
        first()
        second()
    demo:
        node\last := 0
        node\total := 0
        notify(3)
        notify(8)
        return: node\total
```

**Call:** `observer\demo()`. **Expected result: 11.**

The state, handlers, stored references, notifier, and demonstration form one `observer` group, following the Python scenario's two handlers over one state.

`first` initially refers to `remember`; `second` refers to `accumulate`. Each `notify` receives an explicit event value, and its two calls autofill the handlers' own `value` places by copy. The handlers write persistent state through lexical `node\last` and `node\total`.

After event 3, both state fields are 3. After event 8, `last` is 8 and `total` is 11. `demo` resets them before the sequence, making another run repeatable. Notifications and handlers are effect-only calls; their results are not consumed.

The two stored subscription slots and delivery order remain explicit. Dynamic subscriber collections, unsubscription, queues, and failure policies are beyond this example.

[Eight-language comparison: 05_observer_comparison.md](05_observer_comparison.md).

<a id="decorator"></a>

## 6. Decorator — wrappers with shared DATA

```lmx
transform:
    int: value
    return: int
    base:
        return: value * 2
    with_one:
        return: base() + 1
    with_three:
        return: with_one() * 3
    demo:
        return: with_three(10)
```

**Call:** `transform\demo()`. **Expected result: 63.**

This is the author's 128-character example. The methods share one declaration of `value` and the numeric result.

`demo` supplies 10 to `with_three`. The calls `with_one()` and `base()` autofill the next method's declared input from the immediate caller. Each activation has its own working value. Results return through the chain as 20, 21, and 63.

The wrappers genuinely delegate and extend the preceding result. No state is written to the graph. The outer call is direct, so neither a separate callable variable nor an additional signature is needed; the comparison makes the same simplification in the other languages.

The chain is fixed in these definitions. Building an arbitrary chain at runtime would require additional representation and logic, which this scenario does not include.

[Eight-language comparison: 06_decorator_comparison.md](06_decorator_comparison.md).

<a id="command"></a>

## 7. Command — actions on a caller-local place

```lmx
commands:
    @: command add_two
    return: int
    add_two:
        value += 2
    twice:
        value *= 2
    invoke:
        required: value
        command()
    demo:
        int: value 0
        invoke()
        invoke(command := twice)
        return: value
```

**Call:** `commands\demo()`. **Expected result: 4.**

The driver creates local `value = 0`. `invoke()` executes its default `add_two`, then an explicit command selects `twice`; both modify that same variable, producing 4.

`value` is declared in `demo`, not in the common DATA. It is therefore a free name in the intermediary and command bodies. `required: value` checks the visible place and establishes `invoke`'s connection to the immediate caller before `command()` runs. It does not declare another counter. The action receives that already established alias and retains the original place.

This step matters: mere transitive reachability through the older fallback can supply a copy instead. Sharing a lexical group alone does not turn that copy into a writable alias.

The example executes synchronously while the caller's context exists. The method reference does not itself own or extend the counter's lifetime. Queues, undo, and serialization are outside the scenario.

[Eight-language comparison: 07_command_comparison.md](07_command_comparison.md).

<a id="template-method"></a>

## 8. Template Method — a fixed sequence of chosen steps

```lmx
pipeline:
    int: value
    return: int
    increment:
        return: value + 1
    twice:
        return: value * 2
    square:
        return: value * value
    execute:
        value := prepare()
        return: finish()
    demo:
        @: prepare increment
        @: finish twice
        int: first execute(4)
        finish := square
        return: first + execute(4)
```

**Call:** `pipeline\demo()`. **Expected result: 35.**

The arithmetic steps, `execute`, and `demo` share one group. The driver declares ordinary references `prepare` and `finish`, then changes only the latter between runs.

`execute(4)` has its own numeric place. Its free names `prepare` and `finish` obtain the references from the immediate caller's context. `prepare()` gives `increment` a copy of 4 through autofill and returns 5. The assignment updates the current `execute.value`; `finish()` receives its own copy of 5.

With `twice`, the result is 10. After `finish := square`, the next run returns 25, making 35 overall. Each run begins with its explicit input 4, and the source graph's numeric field is unchanged.

The sequence remains preparation followed by finishing. Context binding supplies the selected steps; autofill separately supplies their declared numeric inputs.

[Eight-language comparison: 08_template_method_comparison.md](08_template_method_comparison.md).

<a id="visitor"></a>

## 9. Visitor — actions supplied by the caller context

```lmx
Nodes:
    return: int
    on_number:
        throws: NoAction
        throw: NoAction()
    on_pair:
        throws: NoAction
        throw: NoAction()
    Number:
        int: value 3
        return: int
        accept:
            throws: NoAction
            return: on_number()
    ---
    Pair:
        int: left 4
        int: right 5
        return: int
        accept:
            throws: NoAction
            return: on_pair()

Actions:
    return: int
    on_number:
        return: value
    on_pair:
        return: left + right
    demo:
        int: result 0
        result := Nodes\Number\accept()
        result += Nodes\Pair\accept()
        catch: NoAction ()
            result := -1
        return: result
```

**Call:** `Actions\demo()`. **Expected result: 12.**

`Actions` directly contains `on_number`, `on_pair`, and `demo`. The method names are available in the caller's root namespace; creating extra reference variables for them is unnecessary.

`Number\accept` calls the external name `on_number`. The caller context selects `Actions\on_number`, which reads `value` from its immediate `accept` context and returns 3. `Pair\accept` similarly supplies `left = 4` and `right = 5` to the selected pair action, returning 9. The driver adds them to obtain 12.

Fallback actions remain in `Nodes`, below caller-context selection in priority. Removing `Actions\on_pair` makes the lexical fallback raise `NoAction`; the driver's handler sets the result to −1.

The inner `---` keeps `Number` and `Pair` inside `Nodes`. Both fallback behavior and two-stage choice remain: node kind selects an action name, and context selects its implementation. The example visits two nodes rather than implementing general tree traversal.

[Eight-language comparison: 09_visitor_comparison.md](09_visitor_comparison.md).

## Expected distinguishing checks

These are expected behaviors for checking an implementation, not a report of LMX execution.

| Case | Expected behavior |
|---|---|
| Nine main entry calls | 12, 25, 32, 5, 11, 63, 4, 35, 12 |
| Repeat Iterator | Returns 12 again after resetting position and creating local total |
| Pass the iteration form | No element is obtained until `iteration()` executes it |
| Strategy: `apply(5)` | Uses the ready `twice` default |
| Strategy: change `selected` | Explicitly supplying `thrice` changes the result to 15 |
| Retain both Factory products | Readers return 10 and 20; the prototype contains 20 |
| Bypass Adapter with the same argument order | Legacy calculation returns −5 |
| Two Observer events | Four handler calls; `last = 8`, `total = 11` |
| Decorator input 10 | Delegated results are 20, 21, then 63 |
| Command's two invocations | One original local place changes 0 → 2 → 4 |
| Repeat Command demo | A new local counter produces 4 again |
| Replace Template Method's finishing step | Sequence is unchanged; results are 10 and 25 |
| Remove `Actions\on_pair` | Visitor fallback raises `NoAction`; result is −1 |
| Private source or protected lexical declaration | Disallowed implicit dynamic binding does not occur |

## Complete source-length comparison

[Excel](LMX_Comparison_2026-11-20.xlsx) · [PDF](LMX_Comparison_2026-11-20.pdf)

The metric is **non-whitespace characters**, calculated as `sum(not ch.isspace() for ch in code)`. Each measured program includes declarations, imports, necessary language wrappers, and its demonstration method. The separate external entry call, printing, test harness, Markdown, and runtime implementation are excluded. Whitespace is omitted only from the measurement, not from the usable source.

The following figures come from all 72 programs in the nine companion files. The LMX blocks above are identical to their measured counterparts. The ratio row divides each language's combined total by 2097; a value above 1 means a longer combined listing.

| Pattern | LMX | Python | Java | C++ | C# | TypeScript | Go | Rust |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Iterator | 285 | 363 | 524 | 375 | 389 | 413 | 391 | 424 |
| Strategy | 201 | 204 | 428 | 304 | 360 | 345 | 318 | 305 |
| Factory | 306 | 328 | 411 | 297 | 395 | 394 | 390 | 364 |
| Adapter | 163 | 160 | 203 | 165 | 209 | 217 | 179 | 165 |
| Observer | 220 | 425 | 565 | 469 | 552 | 543 | 468 | 662 |
| Decorator | 128 | 140 | 197 | 153 | 203 | 213 | 176 | 151 |
| Command | 152 | 185 | 317 | 252 | 250 | 210 | 214 | 281 |
| Template Method | 228 | 305 | 543 | 376 | 458 | 478 | 397 | 381 |
| Visitor | 414 | 482 | 717 | 627 | 597 | 619 | 716 | 713 |
| **Total** | **2097** | **2592** | **3905** | **3018** | **3413** | **3432** | **3249** | **3446** |
| **Total / LMX** | 1.000× | 1.236× | 1.862× | 1.439× | 1.628× | 1.637× | 1.549× | 1.643× |

These numbers describe the displayed programs. Names are not normalized, Python omits optional annotations, and identical static guarantees are not claimed. The examples compare concrete scenarios: two Observer subscriptions, a fixed Decorator chain, two Visitor visits, and one numeric field in Factory products.

Command's other versions use local callbacks or a local receiver; LMX obtains the caller's place through its context rules. This preserves the demonstrated effect while using a different representation of context. The shortened Adapter and Decorator omit their unused callable indirection in every language. Factory inlines the once-used second result in every language.

Foreign-language execution and static-review details are recorded in the individual comparisons. Source counting does not establish LMX execution or runtime performance.

## Sources and agreement

- [Binding and structural calls](../LMX_semantics.en.md#structural-call): actual parent DATA, ordinary references, defaults, autofill, caller places, and two-way `private`.
- [Supplied declarations and import][D]: the declaration/body behavior of `iterate` and root const imports.
- [Blank-line block termination][E]: complete root termination and retained inner `---` boundaries.

The current examples also follow the author's lexical `node` clarification and the instruction to use the Python programs as architectural prototypes. Each section links to its full eight-language comparison. The Russian edition contains the same nine LMX programs, entry calls, expected results, and comparison figures.

[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[E]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md

[S]: ../LMX_semantics.en.md#merge-two-forms

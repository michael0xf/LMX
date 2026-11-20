# Design Patterns in Lingvamyxa

English edition · Revised 20 November 2026 · Nine independent examples

This edition uses the same LMX programs as the nine revised comparison documents. It incorporates named `fn` signatures derived from DATA, caller-context binding, declaration forms supplied as arguments, const imports, lexical `node`, and the blank-line block terminator. The accepted documentation changes are assumed to be applied. The LMX examples were reviewed against those rules; they were **not executed by an LMX compiler**.

## Contents and expected results

The order is instructional, not a statistical ranking of pattern popularity. Each example gives a concrete, limited use of a familiar pattern. The source arrangement follows LMX's structures, calls, and binding rules.

| No. | Pattern | Scenario | Result |
|---|---|---|---:|
| 1 | [Iterator](#iterator) | User-defined `iterate`, with a local accumulator | 12 |
| 2 | [Strategy](#strategy) | Replace doubling with tripling | 25 |
| 3 | [Factory](#factory) | Create products by copying a modified prototype | 32 |
| 4 | [Adapter](#adapter) | Reconcile two parameter orders | 5 |
| 5 | [Observer](#observer) | Notify two stored subscribers | 11 |
| 6 | [Decorator](#decorator) | Apply a fixed chain of operation wrappers | 63 |
| 7 | [Command](#command) | Execute actions against a caller-local variable | 4 |
| 8 | [Template Method](#template-method) | Keep the sequence and replace its steps | 35 |
| 9 | [Visitor](#visitor) | Supply number and pair handlers through context | 12 |

## Reading rules

**Independent programs.** Each section has its own namespace. Repeated `Demo` and other names belong to separate examples. The main source block provides definitions; the stated call belongs in an executable context. Results are returned values, with no assumed printing library.

**Block boundaries.** A blank physical source line ends the entire ordinary syntactic block, as a synthetic `---` at virtual level −1 above root. Whitespace-only lines have the same effect. Consequently, blank lines separate root declarations here; they cannot be inserted freely inside them. An inner `---` closes a nested structure while retaining its enclosing root. The Observer and Visitor programs require that distinction. EOF closes the last ordinary block. A final line-ending LF alone is not an additional blank line; literal and raw lexical modes retain their own rules. See the [block-termination requirements][E].

**Lexical access and method DATA are different concepts.** In these examples, a method is an ordinary nested Structure, and its DATA is its actual `parent(code)`. **`node\` selects lexical binding; it is not a parent operator.** It may address a field declared farther out in the lexical structure. This is essential for both Factory and Observer. An imported method keeps its original DATA. [Binding and call requirements][B]

**Signatures.** `fn: Name Data` creates a named call signature, not an executable body. The supplied DATA may be an existing structure that also contains methods. Signature matching extracts the declared input shape and result; it does not compare those method bodies as a structural tree. All declared inputs still count, including inputs with defaults. By contrast, an ordinary structural requirement checks the whole tree it describes. This is why handler DATA in Observer is separate from publisher state and callback fields. [Signature rules][B]

An fn requirement compares input count, ordered input types, and result. Its labels name explicit actuals through that reference; candidate labels may differ. For example, a signature declared as `fn: Public (int: x; return: int)` can admit an implementation whose corresponding input is named `value`: an explicit `x := 5` then selects that input position. It does not rename the implementation's hidden dependencies. In these programs, signatures extracted from DATA already use the implementation's declared labels, so no illustrative renaming is needed.

**Copies and places.** A declared, uninitialized callee input may be autofilled by a same-named caller-local value; it receives its own value. A free identifier that is not declared in the callee's own code or DATA may bind to a caller-local place, subject to the ordinary binding and write rules. An already established alias can be forwarded while retaining its original place. The older transitive fallback must not be treated as an automatic writable alias: it may supply a copy. Command makes the intermediary's binding explicit through `required: value` before invoking the action. [Binding rules][B]

**Defaults and privacy.** A ready own default is retained unless an applicable explicit actual replaces it. A same-named caller local does not automatically displace that default. `private` acts in both directions: a private caller field is not an implicit dynamic source, and a private lexical declaration is not dynamically replaced. Explicit passing and permitted lexical access remain available. The examples assume that their implicit sources are available and writable where required.

**Imports and supplied declarations.** `import` adds const declarations that count as root declarations in DATA; user structures are constant without an explicit `const`. It does not import ordinary mutable variables. A declaration receiver supplied to `iterate` retains its DATA form, and its execution establishes or updates the shared place used by the supplied body. Passing that form is distinct from executing it. [Declaration and import requirements][D]

Bare assignments operate on the selected place of the current execution. Graph accesses and lexical graph accesses are shown where state must persist between separate calls. The drivers explicitly establish the persistent state their scenarios observe.

<a id="iterator"></a>

## 1. Iterator — a user-defined iterate

**Intent:** separate obtaining an element from processing it. `numbers\next()` owns the position, `cycles\iterate` controls repetition, and the caller supplies the declaration and body.

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

cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()

use:
    import: cycles
    int: total 0
    return: int
    run:
        numbers\position := 0
        iterate: int: item numbers\next()
            item *= 2
            total += item
        return: total
```

**Call:** `use\run()`.

**Expected result: 12.**

| Step | Obtained | `item` after the body | `total` |
|---|---:|---:|---:|
| 1 | 1 | 2 | 2 |
| 2 | 2 | 4 | 6 |
| 3 | 3 | 6 | 12 |
| 4 | `Stop` | Body is not executed | 12 |

The first supplied argument preserves `int: item numbers\next()` as a declaration form. Passing it does not obtain an element. Each `iteration()` executes that form, obtains the next value, and establishes or updates `item` in the shared execution namespace. The subsequent `body()` uses the same place; reading `item` does not call `next` again.

The body's `total` binds to the local place of the current `use\run` activation. Its initial zero comes from `int: total 0`; the accumulator needs no graph write. Position must survive separate `next()` calls, so `node\position` explicitly selects the lexical field in `numbers`. The driver resets that graph field before traversal.

`import: cycles` exposes the constant method name `iterate`; mutable `iteration` and `body` remain in the original DATA. `Stop` terminates the sequence, allowing zero to be an ordinary element. The shown `catch` covers the entire loop body, including both calls: a `Stop` from the processing body also ends the loop. This scope follows ordinary handler rules.

This is a concrete three-element iterator and a reusable user-defined loop. It does not depend on a new built-in `iterate` receiver.

**Companion comparison:** [01_iterator_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-deebbfaa6f888191bd2042ed38a66dae_bbe92b09b62881918d17958175103ded&account_id=personal).

<a id="strategy"></a>

## 2. Strategy — a replaceable algorithm

**Intent:** keep a consumer and change the algorithm it invokes. `Processor\apply` uses either doubling or tripling through a constrained reference.

```lmx
Algorithms:
    int: value
    return: int
    twice:
        return: value * 2
    thrice:
        return: value * 3

fn: Transform Algorithms

Processor:
    int: value
    @: operation Transform Algorithms\twice
    return: int
    apply:
        return: operation()

StrategyDemo:
    return: int
    run:
        import: Algorithms Processor
        @: operation Transform twice
        int: first apply(5; operation)
        operation := thrice
        return: first + apply(5; operation)
```

**Call:** `StrategyDemo\run()`.

**Expected result: 25**, from `10 + 15`.

`fn: Transform Algorithms` extracts the `int → int` signature from the existing DATA. Its public input label is `value`; the bodies of `twice` and `thrice` are not compared as a tree.

`apply(5; operation)` explicitly fills `Processor.value` and `Processor.operation`. This preserves an important distinction: `operation` has a ready default, so a caller-local variable of the same name does not silently replace it. Calling `apply(5)` uses `Algorithms\twice`; the displayed calls explicitly choose the current reference.

When `operation()` runs, the selected algorithm has its own declared, uninitialized `value`. Autofill copies the immediate caller's value into that input. The algorithm returns its result without modifying the caller's argument or the source graph.

The driver first selects `twice`, then assigns `thrice` to the same typed local reference. The consumer and its operation contract remain unchanged. `import` exposes the constant method names while retaining their original DATA.

The example retains a default implementation, a replaceable operation, and one consumer. It uses one input and one result; it does not imply that all algorithms with a matching signature have equivalent meaning.

**Companion comparison:** [02_strategy_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-0e0ce4352cc08191a0479cd79d37d32e_bbe92b09b62881918d17958175103ded&account_id=personal).

<a id="factory"></a>

## 3. Factory — products copied from a prototype

**Intent:** create an independent product from a prototype and pass it directly to a consumer. `small` and `large` set different prototype values, then copy `Product`.

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
            return: merge(Product)
        large:
            node\payload := 20
            return: merge(Product)

add1:
    @: product Product
    return: int
    execute:
        return: product\read() + 1

Demo:
    return: int
    run:
        import: Product add1
        int: first execute(create\small())
        int: second execute(create\large())
        return: first + second
```

**Call:** `Demo\run()`.

**Expected result: 32**, from `(10 + 1) + (20 + 1)`.

`node\payload` selects the lexical field declared in `Product`. Although the factory methods are nested inside `create`, `node` is not limited to the immediate parent. `small` stores 10, `large` stores 20, and each `merge(Product)` returns a separate product.

`import: Product add1` exposes `create` and `execute`. The client passes the result of `create\small()` or `create\large()` directly as `product`; it needs no intermediate factory reference. `execute` reads that product through its method and adds one.

`@: product Product` is an ordinary structural requirement, not an fn signature. It concerns the described product structure, including its methods. `merge` copies the structure with the relationships needed for the copied product's methods to use its data.

If both products are retained, creating the second must not change the first product's numeric payload: their `read()` results remain 10 and 20, while the original prototype contains 20. Each factory writes its value before copying, so the initial payload is not observed by this scenario.

This combines factory methods with prototype copying. It does not introduce a Creator inheritance hierarchy. The cross-language comparison reproduces independence for one numeric field; it does not equate a shallow numeric copy with every graph-copying behavior of LMX `merge`.

**Companion comparison:** [03_factory_method_node_prototype_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-5c77d48e83f8819183ffacb1650ba71c_bbe92b09b62881918d17958175103ded&account_id=personal).

<a id="adapter"></a>

## 4. Adapter — reconciling interfaces

**Intent:** call a legacy method through the parameter order expected by its consumer. Both inputs have the same type, so the adapter must preserve their meanings explicitly.

```lmx
Legacy:
    int: right
    int: left
    return: int
    subtract:
        return: left - right

Adapter:
    int: left
    int: right
    return: int
    subtract:
        return: Legacy\subtract(right; left)

fn: Difference Adapter

Demo:
    return: int
    run:
        import: Adapter
        @: operation Difference subtract
        return: operation(8; 3)
```

**Call:** `Demo\run()`.

**Expected result: 5.**

`Legacy` declares `right` before `left`. `Adapter` declares `left` before `right`, and `fn: Difference Adapter` extracts that public signature. The driver supplies 8 and 3 in the adapter's order.

`Legacy\subtract(right; left)` then sends 3 to the legacy method's first input and 8 to its second. The legacy computation is therefore `8 − 3`.

The adapter cannot be removed merely because the two methods have the same fn shape `(int, int) → int`. If `operation` directly refers to `Legacy\subtract` under the `Difference` requirement, admission succeeds, but `operation(8; 3)` sends 8 to the actual first parameter, `right`, and 3 to `left`. The result becomes **−5**. Candidate parameter labels do not reorder signature positions.

The adapter performs one concrete operation: it delegates after rearranging arguments. Its DATA is also sufficient to describe the public signature, avoiding a duplicate interface declaration. Unlike the Decorator example, the purpose here is to reconcile interfaces, not to add a processing stage.

**Companion comparison:** [04_adapter_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-f2dde03b7e948191a345c2c727f55793_bbe92b09b62881918d17958175103ded&account_id=personal).

<a id="observer"></a>

## 5. Observer — two event subscribers

**Intent:** deliver an event to independent handlers. One remembers the latest value; the other accumulates a total. The publisher stores two callback references.

```lmx
Observer:
    int: last 0
    int: total 0
    Actions:
        int: value
        remember:
            node\last := value
        accumulate:
            node\total += value
    ---
    fn: ListenerSignature Actions
    Publisher:
        int: value
        @: first ListenerSignature Actions\remember
        @: second ListenerSignature Actions\accumulate
        notify:
            first()
            second()

Demo:
    return: int
    run:
        import: Observer\Publisher
        Observer\last := 0
        Observer\total := 0
        notify(3)
        notify(8)
        return: Observer\total
```

**Call:** `Demo\run()`.

**Expected result: 11**, with graph state `last = 8` and `total = 11`.

| Event | `last` | `total` |
|---|---:|---:|
| 3 | 3 | 3 |
| 8 | 8 | 11 |

`Actions` supplies one input, `value`, and no result. `fn: ListenerSignature Actions` extracts precisely that call shape. Persistent state is declared outside this DATA in `Observer`; callback fields are in the separate `Publisher`. Neither becomes an extra handler parameter.

`notify(3)` fills `Publisher.value` while preserving its default callbacks. Each `first()` and `second()` invocation autofills its own handler input from the immediate caller. Those inputs are copies. Persistent writes use `node\last` and `node\total`, which select the outer lexical state in `Observer`.

The driver resets the two state fields before notification. The first event sets `last` to 3 and the total to 3; the second sets them to 8 and 11. Replacing a callback uses ordinary explicit argument passing or a permitted update of the stored field.

The inner `---` closes `Actions` while keeping `ListenerSignature` and `Publisher` inside `Observer`. A blank line at that location would end the whole root block.

This is a synchronous Observer with exactly two subscription slots. Dynamic subscription lists, unsubscription, queues, and callback-failure policies are outside this example.

**Companion comparison:** [05_observer_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-aeb3a2b17e5481918d999d7b7bca2ca8_bbe92b09b62881918d17958175103ded&account_id=personal).

<a id="decorator"></a>

## 6. Decorator — wrappers with one interface

**Intent:** add behavior around an operation while preserving its call interface. The base doubles a number, the first wrapper adds one, and the second multiplies the result by three.

```lmx
Transforms:
    int: value
    return: int
    base:
        return: value * 2
    withOne:
        return: base() + 1
    withThree:
        return: withOne() * 3

fn: TransformSignature Transforms

Demo:
    return: int
    run:
        import: Transforms
        @: transform TransformSignature withThree
        return: transform(10)
```

**Call:** `Demo\run()`.

**Expected result: 63**, following `10 → 20 → 21 → 63`.

All three methods use `Transforms` as their DATA description. `fn: TransformSignature Transforms` extracts one `int` input and an `int` result. Each activation still has its own working `value`; sharing the DATA description does not combine their local variables into one mutable place.

`transform(10)` selects `withThree`. Its call to `withOne()` autofills the latter's declared input with a copy of 10. `withOne()` likewise supplies 10 to `base()`, then adds one to its returned 20. `withThree()` multiplies the returned 21 by three.

Selecting `base` for `transform` would return 20; selecting `withOne` would return 21. The public interface remains `int → int`, with label `value`. The implementation uses ordinary nested calls and autofill, with no argument renaming or duplicate DATA structure per layer.

The shown chain is fixed. It demonstrates delegation and added processing; an arbitrary runtime chain builder would additionally need to represent and manage links between layers. The comparison does not assume such a builder.

**Companion comparison:** [06_decorator_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-fd7f166cb38c8191ab4cd5adb66f1074_bbe92b09b62881918d17958175103ded&account_id=personal).

<a id="command"></a>

## 7. Command — an action against a caller-local place

**Intent:** separate the code that triggers an action from the action itself. Two commands modify the caller's local counter through context binding.

```lmx
fn: Command ()

Commands:
    addTwo:
        value += 2
    twice:
        value *= 2

Invoker:
    @: command Command Commands\addTwo
    execute:
        required: value
        command()

Demo:
    return: int
    run:
        import: Commands Invoker
        int: value 0
        execute()
        execute(command := twice)
        return: value
```

**Call:** `Demo\run()`.

**Expected result: 4**, with local `value` changing `0 → 2 → 4`.

`fn: Command ()` describes zero explicit inputs and no result. `Commands` declares no `value` of its own: the two bodies consume a place supplied by their calling context. The hidden dependency does not add an explicit fn parameter.

`required: value` checks the already visible place according to ordinary binding rules; it does not declare another `value`. Before `command()`, this use binds `Invoker\execute` to the immediate caller's local counter. The command then receives an already established alias from `Invoker`, retaining the original place. Zero is a present initialized value and passes this requirement.

The instruction is significant. If the intermediary never consumes `value`, the retained transitive fallback can supply a copy instead; modifying such a copy would not update the original local. Declaring `int: value` in the intermediary would also introduce its own input place.

The first `execute()` uses its ready default, `Commands\addTwo`. The second explicitly supplies the reference `twice`, without `()`, so the action runs when `command()` is reached. Two-way `private` still governs implicit binding.

This is synchronous execution while the needed caller context exists. It does not turn a bare method reference into a detached closure that owns the counter, or provide a queue, undo, serialization, or extended lifetime. The comparison's other languages use local callbacks or an equivalent local receiver for this specific scenario.

**Companion comparison:** [07_command_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-86796758ae508191bafcf952e04fa362_bbe92b09b62881918d17958175103ded&account_id=personal).

<a id="template-method"></a>

## 8. Template Method — a fixed sequence with replaceable steps

**Intent:** keep the order of an algorithm while selecting its individual steps. `execute` always prepares the value and then finishes it.

```lmx
Pipeline:
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

fn: Step Pipeline

Demo:
    return: int
    run:
        import: Pipeline
        @: prepare Step increment
        @: finish Step twice
        int: first execute(4)
        finish := square
        return: first + execute(4)
```

**Call:** `Demo\run()`.

**Expected result: 35.** The first pass returns `(4 + 1) × 2 = 10`; the second returns `(4 + 1)² = 25`.

`fn: Step Pipeline` extracts the common `int → int` call shape. The methods `increment`, `twice`, `square`, and `execute` are not compared as an implementation tree.

`execute(4)` creates its own working `value = 4`. The names `prepare` and `finish` are not declared in its DATA or code, so they obtain the selected references from the immediate `Demo\run` context. These hidden references do not expand the step's explicit signature.

`prepare()` autofills `increment` with a copy of the current 4 and returns 5. The assignment updates `execute`'s local `value` to 5. `finish()` then receives its own copy of 5 and returns 10 or 25. No write to the source graph's `Pipeline.value` is required.

Between calls, `finish := square` changes the selected finishing step. The implementation of `execute` and its step order remain unchanged; two-way `private` applies as usual to the implicit sources and protected lexical declarations.

The example expresses a template algorithm with two extension points. Its structure uses contextual references and shared DATA; it does not require a class-inheritance hierarchy. Strategy chooses an operation as a whole, whereas this example fixes a sequence containing independently replaceable operations.

**Companion comparison:** [08_template_method_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-1f97a8b4ecf0819181ad26155a9d96c4_bbe92b09b62881918d17958175103ded&account_id=personal).

<a id="visitor"></a>

## 9. Visitor — actions for different node kinds

**Intent:** provide actions for node kinds while retaining the nodes. Each node chooses an action name; the caller supplies its implementation through context.

```lmx
fn: ActionSignature (return: int)

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
            int: n value
            return: on_number()
    ---
    Pair:
        int: left 4
        int: right 5
        return: int
        accept:
            throws: NoAction
            int: a left
            int: b right
            return: on_pair()

Actions:
    return: int
    number:
        return: n
    pair:
        return: a + b

Demo:
    return: int
    run:
        @: on_number ActionSignature Actions\number
        @: on_pair ActionSignature Actions\pair
        int: result 0
        result := Nodes\Number\accept()
        result += Nodes\Pair\accept()
        catch: NoAction ()
            result := -1
        return: result
```

**Call:** `Demo\run()`.

**Expected result: 12**, from the number's 3 and the pair's `4 + 5`.

1. `Number\accept` establishes local `n = 3`, then calls `on_number`.
2. The selected `Actions\number` receives `n` from its immediate caller, `accept`.
3. `Pair\accept` establishes `a = 4` and `b = 5`, then invokes the selected pair action.
4. The driver adds both results.

`ActionSignature` declares only `return: int`, hence zero explicit inputs. The hidden dependencies `n`, `a`, and `b` do not increase that arity; the concrete `accept` calls supply them. A compatible fn signature alone does not create those values.

Fallback actions live in `Nodes`, lexically above the immediate DATA of `Number` and `Pair`. They therefore remain external names eligible for the described dynamic substitution. Without a suitable caller-local `on_pair`, the original action raises `NoAction`, and the driver returns **−1**. A ready own handler field would not be replaced in the same way. Private caller sources do not participate implicitly, and private lexical receiving declarations resist dynamic replacement.

The inner `---` preserves both node structures inside `Nodes`. The `catch: NoAction` scope covers both visits. Root-level blank lines separate `Nodes`, `Actions`, and `Demo`.

The two choices remain visible: node kind selects the action name, and context selects its implementation. This example visits two nodes; it does not implement traversal or storage of an arbitrary tree.

**Companion comparison:** [09_visitor_comparison.md](https://chatgpt.com/library?file_id=libfile_fde3_f-84c88e716f748191854ae5bd8ef38d51_bbe92b09b62881918d17958175103ded&account_id=personal).

## Shared mechanisms

| Mechanism | Examples |
|---|---|
| An fn signature extracted from existing DATA | Strategy, Adapter, Observer, Decorator, Template Method |
| A typed method reference | Strategy, Adapter, Observer, Decorator, Command, Template Method, Visitor |
| Autofill of a declared input by value | Strategy algorithms, Observer callbacks, Decorator layers, Template Method steps |
| A caller-local place or an already established alias | Command; local accumulation in Iterator under the supplied-form rules |
| External action names supplied through context | Template Method, Visitor |
| A preserved declaration form and a shared body namespace | Iterator |
| An ordinary structural requirement and `merge` | Factory products |
| Persistent lexical graph state | Iterator position, Observer state, Factory prototype |
| Activation-local working state | Iterator total, Command counter, Template Method value |

These mechanisms provide recurring ways to connect code and data. Each program still specifies what an element is, whom to notify, what to create, which steps to perform, and what a missing action means. Signature compatibility checks a call shape; the Adapter example shows why it cannot establish the semantic meaning of the argument order.

## Expected distinguishing checks

The following are expected semantic checks for an implementation, **not a report of LMX test execution**.

| Case | Expected behavior |
|---|---|
| All nine main calls | Results match the contents table |
| Repeat Iterator | Returns 12 again; position resets explicitly and local total begins at zero |
| Supply the iteration declaration before the first step | `next` has not yet run; traversal obtains three elements and then `Stop` |
| `Stop` from the Iterator body | The shown handler ends the loop |
| Strategy: `apply(5)` | Uses default `twice`, even if the caller has a different same-named local operation |
| Strategy: `apply(5; operation)` | Explicitly chooses that operation; `thrice` returns 15 |
| Factory: retain both products | Their `read()` values are 10 and 20; the prototype is 20 |
| Adapter: substitute `Legacy\subtract` directly | Fn admission succeeds; the result becomes −5 |
| Observer: two events and two subscribers | Four handler calls; `last = 8`, `total = 11` |
| Decorator: select `base`, `withOne`, or `withThree` | Input 10 produces 20, 21, or 63 |
| Command: initialized local `value = 0` | `required` accepts its presence; both commands modify that same place |
| Command: declare an own `int: value` in the intermediary | Introduces a distinct own input rather than preserving the original free-place binding |
| Template Method: replace only `finish` | `prepare` stays first; the two passes return 10 and 25 |
| Visitor: remove local `on_pair` | Fallback raises `NoAction`; result is −1 |
| Private implicit source or protected lexical receiver | The disallowed dynamic binding does not occur |
| Fn: reverse inputs of different types | Matching labels do not make the ordered type shapes compatible |

## Complete source-length comparison

The table counts **non-whitespace characters** in the complete programs shown in the nine companion comparison files. The LMX code is identical to the code above; each separate entry-point call is excluded from the measured program.

| Pattern | LMX | Python | Java | C++ | C# | TypeScript | Go | Rust |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Iterator | 307 | 363 | 524 | 375 | 389 | 413 | 391 | 424 |
| Strategy | 335 | 204 | 428 | 304 | 360 | 345 | 318 | 305 |
| Factory | 338 | 341 | 428 | 314 | 412 | 413 | 404 | 381 |
| Adapter | 241 | 179 | 303 | 227 | 258 | 303 | 247 | 231 |
| Observer | 368 | 425 | 565 | 469 | 552 | 543 | 468 | 662 |
| Decorator | 225 | 159 | 295 | 209 | 248 | 285 | 232 | 211 |
| Command | 215 | 185 | 317 | 252 | 250 | 210 | 214 | 281 |
| Template Method | 280 | 305 | 543 | 376 | 458 | 478 | 397 | 381 |
| Visitor | 546 | 482 | 717 | 627 | 597 | 619 | 716 | 713 |
| **Total** | **2855** | **2643** | **4120** | **3153** | **3524** | **3609** | **3387** | **3589** |
| **Total / LMX** | 1.000× | 0.926× | 1.443× | 1.104× | 1.234× | 1.264× | 1.186× | 1.257× |

The ratio row divides each language's total by the LMX total. A ratio above 1 means a longer combined listing. In this collection, LMX totals 2,855 characters: 9.45% less than C++, 30.70% less than Java, and 8.02% more than Python. These are measurements of these particular examples, not a general size prediction for applications.

### Counting method and scope

- The metric is `sum(not ch.isspace() for ch in code)`. Source is normalized to LF with one final line ending. Whitespace remains in the usable programs; its exclusion is only a measurement convention.
- The measured code includes its imports, declarations, required language wrappers, methods, and demonstration function. External `main`, printing, test harnesses, Markdown, and the implementation of a language's runtime or standard library are excluded.
- Names are not reduced to single letters. Python omits optional annotations; equivalent static guarantees are not claimed. Each companion file also gives the full character count and physical line count.
- Iterator uses a concrete step protocol. Observer has two subscription slots. Decorator has a fixed chain. Visitor visits two nodes. Queueing, arbitrary containers, runtime chain construction, and general tree traversal are not hidden in those labels.
- Factory compares products with one numeric payload. Its copying requirement does not establish equivalence between a general LMX graph merge and the other languages' copying mechanisms for arbitrary nested mutable objects.
- Command compares the demonstrated synchronous effect. Other versions form local callbacks or a local receiver; LMX's separate `Invoker` obtains context through binding. The architectural scope differs even where the demonstrated behavior agrees.

The companion documents distinguish executed checks from static review for the other languages. No execution of the LMX examples is claimed by this guide.

## Sources and rules used

- [Binding, signatures, and structural calls][B]: named `fn`, ordered signature matching, ordinary structural requirements, defaults, caller-context places, and two-way `private`.
- [Declaration receivers in arguments and `import`][D]: preserved supplied declarations and root const imports.
- [Operands, strings, arguments, and expressions][O]: the agreed argument and expression rules.
- [Blank lines as complete block terminators][E]: virtual root-level termination and the retained use of inner `---`.
- [Design Patterns: Elements of Reusable Object-Oriented Software][G]: the source catalog for the familiar pattern names. The scenarios and their LMX organization are described explicitly above.

The lexical interpretation of `node\` and the final Factory, Iterator, and Visitor forms follow the author's accepted clarifications. Each pattern links to its revised comparison document for the complete programs in the seven other languages and the detailed counting and validation notes.

The Russian edition contains the same nine source programs, calls, expected results, and comparison figures.

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[O]: https://chatgpt.com/library?file_id=libfile_fde3_f-4209984646f48191a308cc70eac738ae_bbe92b09b62881918d17958175103ded&account_id=personal
[E]: https://chatgpt.com/library?file_id=libfile_fde3_f-9d15a59bc5d881918724924fcef45b04_bbe92b09b62881918d17958175103ded&account_id=personal
[G]: https://www.informit.com/store/design-patterns-elements-of-reusable-object-oriented-9780321770462

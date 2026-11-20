# Design Patterns in Lingvamyxa

English edition · 20 November 2026 · Nine independent examples

This document incorporates the latest agreed requirements: named `fn` signatures, their positional `implements` rule, transparent binding to caller-local places, supplied declaration forms, and imports of root const declarations. These changes are assumed to have been applied. The examples were checked against the documented rules; they were not executed by an LMX compiler.

## Order and coverage

The three previously discussed examples—Iterator, Strategy, and Visitor—are retained, with six further familiar patterns. Their names come from the classical GoF catalog; the implementations below are written for LMX and do not copy the class arrangements of the book's examples. [G][G]

The order is my approximate assessment of practical prevalence and teaching usefulness, **not an industry-wide statistical ranking**. The first four cover traversal, algorithm selection, creation, and adaptation; the next four organize interactions and processing steps; Visitor comes last as a more specialized example involving different node kinds. The order within those groups is instructional.

| No. | Pattern | Example | Result |
|---|---|---|---:|
| 1 | [Iterator](#iterator) | User-defined iterate and a local accumulator | 12 |
| 2 | [Strategy](#strategy) | Replacing doubling with tripling | 25 |
| 3 | [Factory Method](#factory) | A replaceable product-creation step | 32 |
| 4 | [Adapter](#adapter) | Reconciling legacy parameter meanings | 5 |
| 5 | [Observer](#observer) | Two event subscribers | 11 |
| 6 | [Decorator](#decorator) | A sequence of operation wrappers | 63 |
| 7 | [Command](#command) | Executing two supplied actions | 4 |
| 8 | [Template Method](#template-method) | A fixed sequence with replaceable steps | 35 |
| 9 | [Visitor](#visitor) | Context-supplied number and pair handlers | 12 |

## How to read the examples

- Each section is independent and has its own namespace. Repeated `Demo` names, signature names, and other declarations should not be concatenated into one module without renaming.
- The definitions block is read in the DATA role. The separate short “Call” block belongs in an executable context. Results are return values; no unspecified printing library is assumed.
- A method is an ordinary nested Structure. Its data is its actual `parent(code)`; input places and the `return` description belong there. `fn` creates a named signature description, not a body. [B, §§4, 8][B]
- `@: p Signature Implementation\method` explicitly separates reference name, requirement, and candidate. An fn requirement compares input count, ordered input types, and result. Fn labels name explicit actuals supplied through that reference; implementation names may differ. An explicitly supplied ordinary structural model checks its entire described tree. [B, §8][B]
- Defaults, `required`, and hidden binding belong to the chosen implementation. Fn labels do not rename hidden dependencies. Two-way `private` follows its ordinary rules. [B, §§5–6, 8.4–8.5][B]
- A bare assignment works with the selected place of the current execution. An explicit path such as `numbers\position` accesses the graph. This is why the Iterator accumulator and persistent Observer state use different kinds of writes.
- `import` brings in root const declarations from data; user Structures are constant without an explicit `const`. It does not import ordinary variables or change an imported method's parent. [D, §6][D]

Each example supplies its own source graph. Where the demonstration changes persistent state, its driver explicitly establishes the initial state so that the same expected result can be obtained on another run.

<a id="iterator"></a>

## 1. Iterator — a user-defined iterate

**Intent:** separate obtaining the next element from processing it. `numbers\next()` owns the traversal position, `cycles\iterate` controls repetition, and the caller supplies the body. This retains the agreed compact example with a local `total`; the entry method is named `run`.

```lmx
numbers:
    int: position 0
    return: int
    next:
        throws: Stop
        if: numbers\position >= 3
            throw: Stop()
        numbers\position += 1
        return: numbers\position
end: numbers

cycles:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()
end: cycles

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
end: use
```

**Call:**

```lmx
use\run()
```

**Expected result: 12.**

| next call | Obtained | item after the body | total |
|---|---:|---:|---:|
| 1 | 1 | 2 | 2 |
| 2 | 2 | 4 | 6 |
| 3 | 3 | 6 | 12 |
| 4 | Stop | Body is not executed | 12 |

The first argument of `iterate` preserves the declaration form `int: item numbers\next()`. Passing it does not call `next`: each element is obtained when `iteration()` executes that form. Execution establishes or updates `item`, and `body()` uses the same place. Reading `item` or entering the body does not call `next` again. This applies the supplied declaration-receiver rules in [D, §§3–4][D].

Within the supplied body, `total` binds to the local place of the current `use\run` activation. Its initial 0 comes from `int: total 0`; neither `use\total := 0` nor another local reset is needed. The iterator position must persist between separate calls to `next`, so it is changed through the explicit path `numbers\position`. The driver explicitly resets it before another complete traversal.

`import: cycles` imports the constant name of the user Structure `iterate`. The variables `iteration` and `body` remain in the original `cycles`, which continues to provide data for `iterate`.

`Stop` is the named completion exit. It permits 0 to remain an ordinary element value. In this compact form, `catch` covers the entire iteration, including the body: a `Stop` from the body would also end the loop. That is the existing handler scope, not a special rule of the user-defined `iterate`.

**LMX mechanisms used:** the step protocol, a supplied declaration form, and its shared execution context with the body. This example needs no new built-in loop.

<a id="strategy"></a>

## 2. Strategy — a replaceable algorithm

**Intent:** replace an algorithm while keeping its consumer. `Processor\apply` receives an operation by reference: it first doubles the number, then triples it.

```lmx
fn: Transform (int: x; return: int)

Algorithms:
    int: value
    return: int
    twice:
        return: value * 2
    thrice:
        return: value * 3
end: Algorithms

Processor:
    @: operation Transform Algorithms\twice
    int: input
    return: int
    apply:
        return: operation(x := input)
end: Processor

StrategyDemo:
    return: int
    run:
        @: selected Transform Algorithms\twice
        int: first Processor\apply(operation := selected; input := 5)
        selected := Algorithms\thrice
        int: second Processor\apply(operation := selected; input := 5)
        return: first + second
end: StrategyDemo
```

**Call:**

```lmx
StrategyDemo\run()
```

**Expected result: 25** — the first call produces 10 and the second produces 15.

`fn: Transform ...` describes one `int` input and an `int` result. The implementations, `twice` and `thrice`, are ordinary Structures; their data is `Algorithms`. The signature names its parameter `x`, while the implementations use `value`. They match because `fn` compares types by position.

`operation(x := input)` uses label `x` from the `Transform` interface. It identifies the first position and sends the value to the implementation's actual parameter `value`. This is explicit argument passing. It neither renames implementation fields nor establishes aliases for hidden binding. [B, §8][B]

`selected := Algorithms\thrice` changes the local reference while retaining its fn requirement. Both calls to `Processor\apply` supply that reference explicitly, replacing the ready default of `operation` with the actual argument.

**The Strategy roles remain:** a consumer, an operation contract, and a choice of implementation. Expressing those roles does not require inheritance or a separate class for each algorithm.

<a id="factory"></a>

## 3. Factory Method — a replaceable creation step

**Intent:** a shared algorithm decides when to create a product, while the concrete creation step can be replaced. This example expresses the factory-method role through an LMX context rather than reproducing the classical class-inheritance structure.

```lmx
fn: FactorySignature (return: @)

ProductTemplate:
    int: payload 0
    return: int
    read:
        return: payload
end: ProductTemplate

Factories:
    return: @
    small:
        return: merge(ProductTemplate; (int: payload 10))
    large:
        return: merge(ProductTemplate; (int: payload 20))
end: Factories

Workflow:
    return: int
    execute:
        @: product ProductTemplate create()
        return: product\read() + 1
end: Workflow

FactoryDemo:
    return: int
    run:
        @: create FactorySignature Factories\small
        int: first Workflow\execute()
        create := Factories\large
        int: second Workflow\execute()
        return: first + second
end: FactoryDemo
```

**Call:**

```lmx
FactoryDemo\run()
```

**Expected result: 32** — the first workflow returns 11 and the second returns 21.

`Workflow\execute` retains the sequence “create a product → read its value → add one.” It declares no `create` in its own data or code, so that name binds to the caller's local reference. Changing `create` selects another factory while preserving the workflow. This is an extension point inside a larger operation; the example is not merely a stand-alone `switch` that returns different objects.

`FactorySignature` specifies no explicit inputs and a reference result. Both factories return a fresh composition using `merge`. The second operand contains a declaration of `payload`, replacing its corresponding model slot. Parentheses preserve that operand as a separate Structure.

`product` has the ordinary structural requirement `ProductTemplate`. That requirement includes the model's whole described tree, including `read`; both factories satisfy it by composing the same model. This differs from checking `FactorySignature`, which examines only the factory's call type shape. [B, §§8.2–8.3][B]

`merge` preserves and redirects the relationships of copied occurrences: the resulting product's `read` uses that product's data. The original `ProductTemplate` remains the model. Merely referring to an existing body would not change its parent in this way.

**LMX provides:** a replaceable method through the context and ordinary composition to build a product. The factories still determine which product is created.

<a id="adapter"></a>

## 4. Adapter — reconciling interfaces

**Intent:** expose an existing operation through the interface its consumer needs. Both inputs are `int`, but the legacy method declares their semantic roles in the opposite order. The example deliberately separates type compatibility from correct argument assignment.

```lmx
fn: Difference (int: left; int: right; return: int)

Legacy:
    int: right
    int: left
    return: int
    subtract:
        return: left - right
end: Legacy

DifferenceAdapter:
    int: minuend
    int: subtrahend
    return: int
    subtract:
        return: Legacy\subtract(right := subtrahend; left := minuend)
end: DifferenceAdapter

AdapterDemo:
    return: int
    run:
        @: operation Difference DifferenceAdapter\subtract
        return: operation(left := 8; right := 3)
end: AdapterDemo
```

**Call:**

```lmx
AdapterDemo\run()
```

**Expected result: 5.**

`Difference` specifies `left` followed by `right`. Through that interface, 8 reaches the adapter's first position, `minuend`, and 3 reaches its second, `subtrahend`. The adapter explicitly supplies `right = 3` and `left = 8` to the legacy method, which computes 8 − 3.

If `operation` refers directly to `Legacy\subtract` instead of `DifferenceAdapter\subtract`, fn admission succeeds: both type shapes are `(int, int) → int`. However, calling through `Difference` then sends 8 to the real first parameter, `right`, and 3 to the second, `left`, producing **−5**. Candidate parameter names do not rearrange signature positions. [B, §8.5][B]

The adapter therefore performs real work: it explicitly reconciles argument meanings. `fn` preserves type compatibility; it does not infer what `left` and `right` mean.

**Difference from Decorator:** Adapter reconciles interfaces; the Decorator example below preserves the interface and augments the processing.

<a id="observer"></a>

## 5. Observer — multiple event subscribers

**Intent:** deliver one event to several independent handlers. One remembers the latest value; the other accumulates a sum. Two fields hold the two subscribers, keeping the example independent of a container API.

```lmx
ObserverState:
    int: last 0
    int: total 0
end: ObserverState

fn: ListenerSignature (int: value)

Remember:
    int: observed
    accept:
        ObserverState\last := observed
end: Remember

Accumulate:
    int: amount
    accept:
        ObserverState\total += amount
end: Accumulate

Publisher:
    @: first ListenerSignature Remember\accept
    @: second ListenerSignature Accumulate\accept
    int: event
    notify:
        first(value := event)
        second(value := event)
end: Publisher

Demo:
    return: int
    run:
        ObserverState\last := 0
        ObserverState\total := 0
        Publisher\notify(event := 3)
        Publisher\notify(event := 8)
        return: ObserverState\total
end: Demo
```

**Call:**

```lmx
Demo\run()
```

**Expected result: 11; the graph contains `last = 8`, `total = 11`.**

| Delivered event | last | total |
|---|---:|---:|
| 3 | 3 | 3 |
| 8 | 8 | 11 |

`ListenerSignature` specifies one int input and no result. The implementations use parameter names `observed` and `amount`, but each call through a constrained reference uses the public label `value`. It directs the event to the selected handler's first position.

The publisher stores references and notifies both recipients in order. Replacing one handler does not require changing the other. `ObserverState` deliberately lives in the graph because it must survive two independent notifications. The driver explicitly resets it before the demonstration sequence; the handlers do not perform hidden resets.

This is a minimal synchronous Observer with two subscription slots. A dynamic list, unsubscription, queues, and handler-failure policies are not implemented here; they are additional publisher logic, not consequences of having two references.

**LMX provides:** storage and admission for callable references, with events passed through ordinary calls. The rule to notify every subscriber is still written explicitly.

<a id="decorator"></a>

## 6. Decorator — wrappers with the same interface

**Intent:** augment processing while preserving the operation interface. The base method doubles a number; one wrapper adds 1 to its result, and another multiplies that result by 3.

```lmx
fn: TransformSignature (int: x; return: int)

Base:
    int: value
    return: int
    apply:
        return: value * 2
end: Base

WithOne:
    int: input
    return: int
    apply:
        return: Base\apply(value := input) + 1
end: WithOne

WithThree:
    int: argument
    return: int
    apply:
        return: WithOne\apply(input := argument) * 3
end: WithThree

Demo:
    return: int
    run:
        @: transform TransformSignature WithThree\apply
        return: transform(x := 10)
end: Demo
```

**Call:**

```lmx
Demo\run()
```

**Expected result: 63**, following `10 → 20 → 21 → 63`.

All three methods have fn shape `[int] → int`. Their inputs are named `value`, `input`, and `argument`, while the public interface uses `x`. Positional typing admits each implementation. Direct nested calls use their target methods' actual parameter names and explicitly forward the current value.

Choosing `Base\apply` for `transform` would produce 20; choosing `WithOne\apply` would produce 21. The public call `transform(x := 10)` stays unchanged. Each wrapper delegates work to the previous operation and then adds its own step; the original method is not rewritten.

This example composes functions in a fixed chain. An arbitrary runtime chain builder would additionally need to represent references between layers. No such library is hidden inside the word Decorator here.

**Difference from Strategy:** Strategy selects an algorithm; Decorator adds behavior around an existing operation. The two techniques can be combined.

<a id="command"></a>

## 7. Command — an action as a supplied value

**Intent:** separate the place that triggers an action from its implementation. `Invoker` receives and executes a command without knowing whether it adds to or multiplies the counter.

```lmx
Counter:
    int: value 0
end: Counter

fn: CommandSignature ()

AddTwoCommand:
    execute:
        Counter\value += 2
end: AddTwoCommand

DoubleCommand:
    execute:
        Counter\value *= 2
end: DoubleCommand

Invoker:
    @: command CommandSignature AddTwoCommand\execute
    run:
        command()
end: Invoker

Demo:
    return: int
    run:
        Counter\value := 0
        Invoker\run(command := AddTwoCommand\execute)
        Invoker\run(command := DoubleCommand\execute)
        return: Counter\value
end: Demo
```

**Call:**

```lmx
Demo\run()
```

**Expected result: 4**, with the counter changing `0 → 2 → 4`.

`fn: CommandSignature ()` specifies no explicit inputs and no result. Both `execute` methods match: their parents contain only the user methods themselves, which do not become variable inputs.

The actual argument is the reference `AddTwoCommand\execute`, without `()`. The command therefore runs inside `Invoker\run` when `command()` is reached, not while the reference is being supplied. The ready value of `command` is the first command; the second call explicitly replaces it with another actual.

`Counter` is the common receiver of the actions. The implementations refer to it lexically, and their effects persist between calls through the explicit path `Counter\value`. The driver resets it before the sequence to make the demonstration repeatable.

This minimal Command stores an action in a reference. A queue, per-command arguments, a log, or undo can be added as ordinary data and methods; none is automatically supplied by the command representation itself.

**Difference from Strategy:** the caller supplies a request to perform an action, and the Invoker controls when it runs. Strategy primarily chooses which algorithm processes a supplied input.

<a id="template-method"></a>

## 8. Template Method — a fixed sequence with replaceable steps

**Intent:** retain an algorithm sequence while allowing individual steps to be replaced. `Pipeline\run` always calls `prepare` first and `finish` second. Both steps come from the caller context.

```lmx
fn: StepSignature (int: x; return: int)

Steps:
    int: value
    return: int
    increment:
        return: value + 1
    twice:
        return: value * 2
    square:
        return: value * value
end: Steps

Pipeline:
    int: input
    return: int
    run:
        int: intermediate prepare(x := input)
        return: finish(x := intermediate)
end: Pipeline

Demo:
    return: int
    run:
        @: prepare StepSignature Steps\increment
        @: finish StepSignature Steps\twice
        int: first Pipeline\run(input := 4)
        finish := Steps\square
        int: second Pipeline\run(input := 4)
        return: first + second
end: Demo
```

**Call:**

```lmx
Demo\run()
```

**Expected result: 35.** The first pass computes `(4 + 1) × 2 = 10`; the second computes `(4 + 1)² = 25`.

`Pipeline\run` declares neither `prepare` nor `finish` in its own data or code. These names can therefore bind to the caller's local references. Changing `finish` preserves the Pipeline algorithm: preparation still precedes completion.

Both steps have fn shape `[int] → int`. Their implementations use actual parameter `value`, while calls through the references use public label `x`. The step references are obtained through hidden binding; each step's numeric input is supplied explicitly as an ordinary actual.

Classical object-oriented presentations commonly express such steps as overridable methods. Here an ordinary Structure and context binding express the template operation and its extension points. The example introduces no inheritance mechanism to reproduce those roles.

**Difference from Strategy:** Strategy replaces the operation being used; here a fixed overall sequence contains several independently selected operations. Factory Method above is a particular creation-related replaceable step.

<a id="visitor"></a>

## 9. Visitor — operations for different node kinds

**Intent:** supply operations for different node kinds while retaining the nodes themselves. A node selects the corresponding handler name; the caller supplies its implementation through the context. This is an LMX Visitor variant without a separate visitor argument.

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
    end: Number
    Pair:
        int: left 4
        int: right 5
        return: int
        accept:
            throws: NoAction
            int: a left
            int: b right
            return: on_pair()
    end: Pair
end: Nodes
Actions:
    return: int
    number:
        return: n
    pair:
        return: a + b
end: Actions
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
end: Demo
```

**Call:**

```lmx
Demo\run()
```

**Expected result: 12** — the number contributes 3, and the pair contributes 4 + 5 = 9.

1. `Number\accept` declares local `n = 3` and calls external name `on_number`.
2. The name binds to the local reference in `Demo\run`; the selected `Actions\number` obtains `n` from its immediate caller, `accept`.
3. `Pair\accept` similarly provides local `a = 4`, `b = 5`; `Actions\pair` returns 9.
4. The driver adds the two visit results.

`ActionSignature` specifies no **explicit** inputs and an int result. `n`, `a`, and `b` are hidden handler dependencies; they do not increase fn arity. Matching the signature does not itself supply those values: the particular call from accept supplies them. [B, §§6, 8][B]

The fallback methods live in `Nodes`, above the immediate data Structures `Number` and `Pair`. They are therefore external names for accept and admit dynamic replacement. Removing the local `on_pair` declaration from `Demo\run` selects `Nodes\on_pair`, raises `NoAction`, and makes the driver return **−1**.

A ready handler field declared directly in `Number` or `Pair` would not be automatically replaced by a caller local. `private` matters in both directions: a private source is not supplied implicitly, and a private lexical receiving declaration is protected from dynamic replacement.

**Two stages of selection remain:** the node kind chooses the action name, and the context chooses its implementation. This example visits two nodes; it does not claim to implement recursive traversal or a node collection.

## What these examples show about LMX

The same mechanisms recur: Structures and their parents, method references, fn requirements, explicit actuals, context binding, supplied forms, and merge. There is no separate language construct for every pattern.

| Shared mechanism | Where it is visible |
|---|---|
| A reference with an fn requirement | Strategy, Adapter, Observer, Decorator, Command, Template Method steps |
| An external name obtained from the context | Factory Method, Template Method, Visitor |
| A preserved declaration form and the body's shared place | Iterator |
| An ordinary structural model and merge | Factory Method product creation |
| Explicit persistent graph state | Iterator position, Observer, the Command receiver |
| Activation-local state | Iterator total, intermediate values, and results |

The program still supplies the substance of each pattern: whom to notify, what the next element means, which steps to run, what to create, and how to handle a missing action. A compatible signature confirms a call shape; it does not establish the semantic argument arrangement in Adapter or the correctness of an algorithm.

## Distinguishing checks

These are expected implementation checks, not a report of executed tests.

| Case | Expected behavior |
|---|---|
| All nine main calls | Results match the opening table |
| Repeat Iterator | Returns 12 again: position is explicitly reset, and total receives a fresh local default |
| Iterator: supply the form before the first step | next has not run yet; a full traversal makes three successful steps and one Stop |
| Strategy: fn x, implementation value | Admission succeeds; explicit x reaches the first position, value |
| Adapter: substitute Legacy\subtract directly | Types match; the result is −5 rather than 5 |
| Factory Method: change create | The product changes while the workflow stays the same |
| Observer: two events and two subscribers | Four handler calls; last = 8, total = 11 |
| Decorator: select Base / WithOne / WithThree | Input 10 produces 20 / 21 / 63 |
| Command: supply a reference without () | The action runs at command(), not when supplied |
| Template Method: replace only finish | prepare remains first; the two passes return 10 and 25 |
| Visitor: remove local on_pair | NoAction is raised; the result is −1 |
| Fn: reverse inputs of different types | Matching parameter names do not make the signature compatible |

## Basis

- **[B]** [Requirements: binding, signatures, and structural calls][B], positional-fn revision of 20 November 2026, §§4–6 and 8–11. The main source for callable, fn, and binding rules.
- **[D]** [Requirements: declaration receivers in arguments and import][D], clarified revision of 20 November 2026, §§3–8. The main source for user-defined iterate and imports.
- **[O]** [Requirements: operands, strings, arguments, and expressions][O], revision 5 of 20 November 2026. Coordination of fn, named actuals, and ordinary expressions.
- **[G]** [Gamma, Helm, Johnson, Vlissides — Design Patterns: Elements of Reusable Object-Oriented Software][G], the original catalog's publisher page. This supplies pattern names and classification, not popularity statistics or LMX rules.

The Russian edition contains the same examples, code, and expected results.

[B]: https://chatgpt.com/library?file_id=libfile_fde3_f-a38201c30fb88191b7207c0e48955c30_bbe92b09b62881918d17958175103ded&account_id=personal
[D]: https://chatgpt.com/library?file_id=libfile_fde3_f-02443abbc4508191b7c8fd7894e3ac24_bbe92b09b62881918d17958175103ded&account_id=personal
[O]: https://chatgpt.com/library?file_id=libfile_fde3_f-4209984646f48191a308cc70eac738ae_bbe92b09b62881918d17958175103ded&account_id=personal
[G]: https://www.informit.com/store/design-patterns-elements-of-reusable-object-oriented-9780321770462

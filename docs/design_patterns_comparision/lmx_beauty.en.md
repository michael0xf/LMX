# The Beauty of LMX: Why the “Worst” Example Turned Out to Be the Most Expressive

21 November 2026. [Русская версия](lmx_beauty.ru.md).

In the comparison of 23 design patterns, the Interpreter example gave LMX its least favorable length result relative to Python: **232 non-whitespace characters versus 185, or 25.41% more**. Yet this very example shows a strength of the language that a character count misses: how much of the program’s structure is visible directly in the notation, and how much the reader must reconstruct mentally. The original listings and measurement method are in [23_interpreter_comparison.md](23_interpreter_comparison.md).

The task is very simple: retain the expression `(x + 3) + x`, evaluate it at `x = 2` and `x = 5`, then add the results. These are `7`, `13`, and finally `20`. In LMX, the variable is named `n`; the computation is the same.

## The Operation Above, the Expression Below

Here is the complete LMX listing from the [Interpreter comparison](23_interpreter_comparison.md):

```lmx
operands:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    add:
        return: \left + \right[0]

Example:
    int: n
    return: int
    calculate:
        import: operands
        return: (n add 3) add n
    demo:
        return: calculate(2) + calculate(5)
```

The upper section shows the contract of the user-defined operand: which values it accepts, in what form it receives arguments, what its precedence is, and what it returns. The addition itself is written directly:

```lmx
return: \left + \right[0]
```

The lower section shows this operation in use:

```lmx
return: (n add 3) add n
```

The formula remains recognizable. To see the two additions, there is no need to translate nested constructors into arithmetic notation first.

The `PASS_ARGS_AS_IS 0` field specifies that the operation receives references to prepared values. `\left` and `\right[0]` read them. `PRIORITY sys\priority("+")` sets the precedence to that of built-in addition, while `return: int` declares an ordinary numeric result. A method’s suitability for use as an operand is determined by its DATA; `import: operands` makes the name available in the expression. These rules are described in the [specification for operands, arguments, and precedence, revision 6](reference/to_fable_operands_arguments_priorities.md).

All the user-written parts of the new operation’s definition and its connection to the expression are visible here. The language’s shared expression mechanism provides parsing and execution. The example shows how to connect to this mechanism using an ordinary method.

## Why the Short Python Version Takes Mental Unpacking

The Python version in the [same comparison](23_interpreter_comparison.md) looks like this:

```python
def number(value):
    return lambda x: value

def variable():
    return lambda x: x

def add(left, right):
    return lambda x: left(x) + right(x)

def demo():
    v = variable()
    tree = add(add(v, number(3)), v)
    return tree(2) + tree(5)
```

The reading difficulty comes from familiar names referring to things at a different level:

| Notation | What it means in this example |
|---|---|
| `number(3)` | Create a function that will return `3` when called later. |
| `variable()` | Create a function that will return the argument passed to it when called later. |
| `add(left, right)` | Create a function that will later call `left` and `right` and add their results. |
| `tree(2)` | Run the assembled computation with the argument `2`. |

So `v` here is a function. `number(3)` also returns a function. When the expression is being built, `add(...)` does not yet add anything. There is no separate, explicit “tree” object in this Python listing: `tree` is a composite function that retains connections to other functions.

The compact `lambda` creates a function object; its body runs when the function is called later. The [Python reference](https://docs.python.org/3/reference/expressions.html#lambda) relates this form to an ordinary function definition that returns the value of an expression.

To see how our `add` works, we can expand this notation:

```python
def add(left_calculator, right_calculator):
    def calculate(x):
        left_value = left_calculator(x)
        right_value = right_calculator(x)
        return left_value + right_value

    return calculate
```

A new function is created, retaining access to two other functions. After `add` returns, the new function continues to use them. This is how the closure works in this example.

Now the line:

```python
tree = add(add(v, number(3)), v)
```

reads as follows: assemble a sum evaluator; on the left, place another sum evaluator that combines reading the variable with producing the constant three; on the right, place another reading of the variable.

The entire algorithm is present in the listing. However, the reader needs to keep both **building the future computation** and **running it later** in mind at the same time. The names `number`, `variable`, and `add` do not, on their own, reveal this distinction. The compact notation encompasses creating functions, retaining connections to names in the enclosing scope, and deferred execution.

An experienced Python reader may recognize this construction immediately. Nevertheless, the character count does not tell us how much prior knowledge that recognition requires.

## What the Extra 47 Characters Provide

The difference between the complete listings is:

```text
232 − 185 = 47
47 / 185 × 100 ≈ 25.41%
```

Yet just these two LMX lines:

```lmx
const: int: PASS_ARGS_AS_IS 0
const: int: PRIORITY sys\priority("+")
```

occupy **61 non-whitespace characters**:

| Explicitly specified property | Non-whitespace characters |
|---|---:|
| `const: int: PASS_ARGS_AS_IS 0` | 26 |
| `const: int: PRIORITY sys\priority("+")` | 35 |
| **Total** | **61** |

Describing two properties of the user-defined operand already takes more space than the entire difference in length. The Python listing does not specify rules for incorporating a new name into infix expression syntax: `add` follows the ordinary rules of function calls.

These lines remain in the count: they are mandatory for a complete LMX example. The numbers show what occupies the space: **an explicit mode for receiving arguments and explicit operation precedence**. The listing also includes constraints on the values and the result type.

That is why the statement “LMX is a quarter longer” says very little on its own about this example’s expressiveness. All the numbers refer to the specific listings in [23_interpreter_comparison.md](23_interpreter_comparison.md), including their declarations and demonstration methods.

## Why the Other Versions Look Different Too

In the selected implementations, the same expression is represented in different ways:

| Languages | How the computation is represented |
|---|---|
| Python, C++, Go | Functions that retain connections to child computations and call them. |
| Java, C# | `Number`, `Variable`, and `Add` objects with an `eval` / `Eval` method. |
| TypeScript | Objects with an `eval` method that uses retained connections. |
| Rust | `enum` variants and recursive evaluation through `match`. |
| LMX | An ordinary language expression with an imported user-defined operand. |

This describes the specific listings in the [comparison file](23_interpreter_comparison.md). Java, C#, and Rust show the nodes and traversal quite explicitly. However, the formula itself must still be reconstructed from constructors and supporting notation. In Python, C++, and Go, building the computation is additionally expressed through returned functions.

Python also allows an ordinary arithmetic formula to be written directly. In this collection, its example implements a separate representation of the expression to be evaluated. LMX uses its own expression mechanism for the task shown: a new method becomes part of familiar notation.

## Architectural Beauty: A Shared Mechanism Works for the User

For this example, LMX did not require separate user-written constructs for “a number as an evaluator,” “a variable as an evaluator,” and “a sum as an evaluator factory.” The graph of the `calculate` body already retains the structure of the computation. Two calls pass different input values while preserving the written expression.

The shared expression mechanism handles parsing, argument preparation, and operation execution. The user defines a method, specifies its contract, and uses it in an expression. The complexity is handled once in the shared model and made available through ordinary language notation.

This fits the intent behind LMX: to derive different capabilities from a small number of shared mechanisms. In this example, an ordinary method, its DATA, name resolution, and the expression mechanism together provide a user-defined operand. To read an expression that uses this operand, it is enough to see the formula itself.

The contract also provides for `PASS_ARGS_AS_IS 1`: this mode allows the operation to receive the original argument occurrences and explicitly evaluate them through `sys\eval`. The addition shown uses mode `0`. Both modes are described by the same mandatory field; precedence remains a separate property. Extending the capabilities in this way preserves the operation’s visible contract. [Rules for the two modes](reference/to_fable_operands_arguments_priorities.md).

## Brevity, Clarity, and Substance

A character count answers one precise question: how many characters a particular piece of notation takes. Two further questions help assess an example:

- How directly does the notation reveal the flow of the computation?
- Which properties and conventions are explicitly expressed in those characters?

Interpreter shows why the answers can differ. Python provides the shortest of the listings presented. LMX explicitly describes the user-defined operand’s contract and keeps its use in ordinary mathematical form.

An LMX reader can work through the example from top to bottom: see the inputs, the rules for receiving arguments, the precedence, the result, and the operation’s body, then read the expression and its two calls. These parts sit next to one another and explain each other.

**The operation is defined above. An expression using that operation is written below. The extra characters make the structure visible.**

That is why the “worst” example by one numerical measure can turn out to be the most expressive explanation of the language’s intent.

## References

- [Interpreter: complete examples in eight languages and the counting method](23_interpreter_comparison.md).
- [Operands, arguments, and precedence: revision 6](reference/to_fable_operands_arguments_priorities.md).
- [Binding, DATA, and structural calls](reference/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md).
- [General overview of the language comparison](about_languages_comparision.en.md).
- [Python Language Reference: Lambdas](https://docs.python.org/3/reference/expressions.html#lambda).

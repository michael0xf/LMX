# The Beauty of LMX: The Operation Above, the Expression Below

21 November 2026. [Русская версия](lmx_beauty.ru.md).

The revised [Interpreter example](23_interpreter_comparison.md) uses **159 non-whitespace characters against Python’s 185**. Its common operand header now comes from a kernel template. The application retains what makes the example readable: the operation’s definition and an ordinary expression using it appear together.

The task is to retain `(x + 3) + x`, evaluate it at `x = 2` and `x = 5`, and add the results. These are `7`, `13`, and finally `20`. The LMX input is called `n`; the computation is the same.

## The Operation Above, the Expression Below

The complete application listing from the [Interpreter comparison](23_interpreter_comparison.md):

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

The external call is `operands\example\demo()` and is excluded from the count.

The upper part shows the shared header through `copy`, the concrete `int` result, and the addition body. Below it are `(n add 3) add n` and two calls with different inputs. The nested `example` sees `add` lexically, so no additional import is needed.

`return: \left + \right[0]` does look mechanical. It shows where the values come from: `left` refers to the left argument, `right` is the common array of references to right arguments, and `[0]` selects its first element. These names do not appear through a special parser branch: the method is preceded by an explicit `copy` of a known template.

### What the Template Contains

This kernel definition is shown for understanding and **is excluded from the application-source count**:

```lmx
sys:
    OPERANDS_TEMPLATE:
        @: left
        []: @ right
        const: int: PASS_ARGS_AS_IS 0
        const: int: PRIORITY priority("+")
```

`PASS_ARGS_AS_IS 0` requests references to prepared values. `PRIORITY priority("+")` inside `sys` uses the precedence of built-in addition. The mandatory fields remain present in the operand’s effective DATA: ordinary `copy` supplies them through the namespace. The source graph retains the written `copy` record.

The template has no `return`: the result belongs to the concrete operation, which declares `return: int` in `operands`. No result declaration is replaced by another. `example` separately describes its own methods’ result in its own DATA. [Operand contract](newdocs/TZ/to_fable_operands_arguments_priorities.md) · [Field streams](newdocs/TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md).

The formula remains recognizable. Seeing the two additions requires no translation of nested constructors into arithmetic notation. The language’s common expression mechanism provides parsing and execution; the user supplies the new operand’s body and uses its ordinary name.

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

The compact `lambda` creates a function object; its body runs when the function is called later. The [Python reference](https://docs.python.org/3/newdocs/expressions.html#lambda) relates this form to an ordinary function definition that returns the value of an expression.

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

## What the Size Includes

| Main listing | Non-whitespace characters | All characters | Lines |
| --- | ---: | ---: | ---: |
| LMX | 159 | 266 | 12 |
| Python | 185 | 247 | 13 |

By the primary metric, LMX is **26 characters, or 14.05%, shorter**. Including indentation and line endings makes its full size **7.69% larger**. These measures answer different questions; both listings use the same normalization.

The complete `copy: sys\OPERANDS_TEMPLATE` line is counted in LMX. The separate template definition belongs to the supplied kernel and is excluded, just as internal standard-library implementations are excluded for the other languages. Showing it alongside the application explains the contract without making it code rewritten by every application.

The size change comes from ordinary reuse of a description. `left`, `right`, `PASS_ARGS_AS_IS`, and `PRIORITY` remain part of the contract. They no longer need to be repeated in each example. The count measures this application and its use of the shared mechanism.

## Why the Other Versions Look Different Too

In the selected implementations, the same expression is represented in different ways:

| Languages | How the computation is represented |
|---|---|
| Python, C++, Go | Functions that retain connections to child computations and call them. |
| Java, C# | `Number`, `Variable`, and `Add` objects with an `eval` / `Eval` method. |
| TypeScript | Objects with an `eval` method that uses retained connections. |
| Rust | `enum` variants and recursive evaluation through `match`. |
| LMX | An ordinary language expression with a lexically available user-defined operand. |

This describes the specific listings in the [comparison file](23_interpreter_comparison.md). Java, C#, and Rust show the nodes and traversal quite explicitly. However, the formula itself must still be reconstructed from constructors and supporting notation. In Python, C++, and Go, building the computation is additionally expressed through returned functions.

Python also allows an ordinary arithmetic formula to be written directly. In this collection, its example implements a separate representation of the expression to be evaluated. LMX uses its own expression mechanism for the task shown: a new method becomes part of familiar notation.

## Architectural Beauty: A Shared Mechanism Works for the User

For this example, LMX did not require separate user-written constructs for “a number as an evaluator,” “a variable as an evaluator,” and “a sum as an evaluator factory.” The graph of the `calculate` body already retains the structure of the computation. Two calls pass different input values while preserving the written expression.

The shared expression mechanism handles parsing, argument preparation, and operation execution. The user copies the common header, defines the method’s result and body, and uses it in an expression. The complexity is handled once in the shared model and made available through ordinary language notation.

This fits the intent behind LMX: to derive different capabilities from a small number of shared mechanisms. In this example, an ordinary method, its DATA, name resolution, and the expression mechanism together provide a user-defined operand. To read an expression that uses this operand, it is enough to see the formula itself.

The contract also provides for `PASS_ARGS_AS_IS 1`: this mode allows the operation to receive the original argument occurrences and explicitly evaluate them through `sys\eval`. The addition shown uses mode `0`. Both modes are described by the same mandatory field; precedence remains a separate property. Extending the capabilities in this way preserves the operation’s visible contract. [Rules for the two modes](newdocs/TZ/to_fable_operands_arguments_priorities.md).

## Brevity, Clarity, and Substance

A character count answers one precise question: how many characters a particular piece of notation takes. Two further questions help assess an example:

- How directly does the notation reveal the flow of the computation?
- Which properties and conventions are explicitly expressed in those characters?

In this revision, LMX has both the shortest listing by non-whitespace count and recognizable mathematical notation. Its readability still comes from the arrangement: the operation, its shared header, and the expression using it are explicitly connected.

An LMX reader can work from top to bottom: see the source of the shared fields, the result and operation body, then the expression and its two calls. If `left`, `right[0]`, or the settings need explanation, the complete template is shown alongside.

**The operation is defined above. An expression using it is written below. Ordinary `copy` connects the short notation to a visible description of its structure.**

The shorter version continues to explain the language’s intent: a shared mechanism is available to the user, while its application remains a readable expression.

## References

- [Interpreter: complete examples in eight languages and the counting method](23_interpreter_comparison.md).
- [Operands, arguments, and precedence: revision 6](newdocs/TZ/to_fable_operands_arguments_priorities.md).
- [Binding, DATA, and structural calls](newdocs/TZ/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md).
- [General overview of the language comparison](about_languages_comparision.en.md).
- [Python Language Reference: Lambdas](https://docs.python.org/3/newdocs/expressions.html#lambda).

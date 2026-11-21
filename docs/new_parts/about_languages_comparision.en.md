# LMX and other languages: brevity, typing and execution model

Updated **21 November 2026**.

**In this collection, LMX is usually shorter than Python while providing typing, actor-style concurrency, low-level operations, and both interpretation and native execution.** Across the expanded set of 23 patterns, LMX is shorter than Python in 19 cases, with 15.92% less source overall. Some exceptions are substantial: “occasionally only a few percent longer” accurately describes the first 18 examples, but no longer describes the entire collection.

This discussion concerns the language model and the cost of the operations it provides. Performance comparable to optimized JVM execution is an architecturally reasonable possibility for the native path: typed computations and known calls can become ordinary C, with machine-code optimization handled by an external compiler.

## Comparison materials

Each comparison contains LMX, Python, Java, C++, C#, TypeScript, Go and Rust. The summary tables use formats that preserve column alignment:

- Patterns 1–9: [Excel](LMX_Comparison_2026-11-20.xlsx), [PDF](LMX_Comparison_2026-11-20.pdf).
- Patterns 10–18: [Excel](LMX_Comparison_10-18.xlsx), [PDF](LMX_Comparison_10-18.pdf).
- Patterns 19–23: [Excel](LMX_Comparison_19-23.xlsx), [PDF](LMX_Comparison_19-23.pdf).

The [first guide](LMX_Design_Patterns.en.md), [guide to patterns 10–18](LMX_Design_Patterns10-18.en.md) and [guide to patterns 19–23](LMX_Design_Patterns19-23.en.md) explain the LMX designs. Individual comparison files provide complete listings and the boundaries of each shared scenario.

## What is measured

The main metric counts non-whitespace characters in the complete displayed source. Necessary imports, declarations, wrappers and `demo` are included. Spaces, indentation and line endings are excluded. For the additional total-size and line-count metrics, the text uses LF, no leading or trailing blank lines, and one final LF. External launch commands, an added launch-only `main`, result printing, verification tests and the runtime implementation are outside the count.

These are specific implementations of agreed tasks. Names are not normalized; different names or architectural choices can change the totals. Python is shown without optional type annotations. Each language uses appropriate functions, closures, records, interfaces, structures or enum variants. An extra facility of one representation is not imposed on the others unless the shared task requires it.

The LMX examples use shared DATA, autofill and ordinary method references. Written `int` declarations, `return` fields and explicit requirements already contribute to their size. A general `@` reference is not presented as a complete statically checked signature for every callable.

## Documentation and verification status

The examples apply the agreed clarifications for [binding and callables](reference/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), [declaration arguments and import](reference/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md), [block boundaries](reference/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md), and [operands, revision 6](reference/to_fable_operands_arguments_priorities.md). These change specifications refine the relevant sections of the base documents. The [README](README.md) contains the complete catalogue and the LMX techniques used.

The LMX examples were reviewed statically against the agreed model. Python examples 21 and 23 were executed again for this revision; the individual Verification sections record execution or static review of the other listings. Preserved verification of unchanged code is not reported as a new run. Character counts come from the current listings. This collection contains no comparative runtime benchmark: the performance discussion below concerns the design of the model.

## Results for the first 18 examples

The previous conclusion remains exact for the original two collections:

- LMX is shorter than Python in **16 of 18 cases — 88.89%**, with no ties.
- The totals are **4319 LMX characters and 5243 Python characters**, a **17.62%** reduction relative to Python.
- **Adapter:** 163 versus 160; LMX is **1.88%** longer.
- **Proxy:** 191 versus 181; LMX is **5.52%** longer.
- Substantial reductions include **Observer: 48.24%, State: 39.20%, Builder: 29.06%, Template Method: 25.25%**.

LMX is shortest among all eight languages in 15 of those 18 cases. Python has the smallest total among the other seven, but is their per-row minimum in only 14 cases. C++ is shorter than Python for Factory, Builder, Prototype and Memento. For Factory, C++ is also shorter than LMX: 297 versus 304 characters.

## What the five additional patterns change

Singleton, Abstract Factory, Flyweight, Mediator and Interpreter expand the collection. After the Flyweight and Interpreter revisions, these five total **1457 LMX characters versus 1627 Python characters**: LMX is **10.45%** shorter overall and shorter in three individual examples.

There are two exceptions in this group:

- **Singleton:** 141 versus 127 — LMX is **11.02%** longer.
- **Interpreter:** 232 versus 185 — **25.41%** longer.

[Flyweight](21_flyweight_comparison.md) now uses a named `width` field in both versions: an `immutable` structure in LMX and a `@dataclass(frozen=True)` in Python. Two requests for `thin` return the same object; position remains an external argument. LMX uses **281** characters versus Python's **309**, a **9.06%** reduction. The nested `drawing` group sees `get` lexically, so no extra imports or copies of shared objects are needed. This demonstrates shared state rather than measuring memory savings.

For [Interpreter](23_interpreter_comparison.md), the shared scenario retains the expression `(x + 3) + x`, evaluates it with `x = 2` and `x = 5`, and adds the results. Python retains the form through composed closures; LMX retains it in the graph of `calculate`, whose input is called `n`. The short LMX listing demonstrates repeated evaluation of this expression; it does not include a universal API for building arbitrary trees at runtime. Other representations may additionally provide that facility.

The LMX method `add` is recognized by its structural DATA contract and resolved by its ordinary name, without registration in `sys\operand`. Its description explicitly includes the mandatory `PASS_ARGS_AS_IS 0` and `PRIORITY sys\priority("+")` fields. The common executor prepares the values, `\left` and `\right[0]` read them, and `return: int` produces an ordinary number. `PASS_ARGS_AS_IS 1` instead passes original argument occurrences for explicit evaluation through `sys\eval`; this example does not use that mode. Separate `number` and `variable` methods and copying through `merge` are unnecessary for this notation. See the [operand contract, §§2–3](reference/to_fable_operands_arguments_priorities.md).

Across **all 23 examples**:

- LMX is shorter than Python in **19 cases — 82.61%**.
- LMX is shortest among all eight languages in **18 cases**.
- LMX and Python total **5776 and 6870**, a **15.92%** reduction.
- The other totals are Java **9809**, C++ **7743**, C# **9105**, TypeScript **8843**, Go **8241**, and Rust **8890**.

Python still has the smallest total among the other seven languages and is their minimum in **17 of 23** rows. The exceptions relative to Python are Adapter, Proxy, Singleton and Interpreter. Frequent LMX brevity remains supported, while the frequency and size of exceptions must refer to a defined collection and its current listings.

## Typing and structural contracts

The LMX model provides physical value types, descriptions of admissible values, a conversion context, and structural compatibility checks through `implements`. A shared physical representation of structures does not remove requirements on the fields and operations actually used. Contracts can differ even when representations coincide: admissible ranges and usage matter alongside cell size.

It is therefore accurate to say that compact notation coexists with typing and checkable contracts. This does not say that every requirement is statically known: some data and call targets are selected dynamically, with checking attached to the relevant consumption. See [value descriptions](reference/LMX_semantics.en.md#descriptions), [the type and conversion context](reference/LMX_semantics.en.md#conversion-context), [used-interface checking](reference/LMX_semantics.en.md#admission), and [the binding and signature contract](reference/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md).

## Actors, low-level operations and two execution paths

The Erlang comparison concerns the organization of concurrency: participants have their own state, communicate through messages, and execute serially within each participant while different participants may run concurrently. In LMX, a Message owns its graph; a running Thread has mail and at most one active turn. A logical Thread does not require a dedicated OS thread. See [Messages and actors](reference/LMX_semantics.en.md#messages) and [arenas](reference/L2_spec_en.md#arena). Erlang also bases concurrency on separate processes and asynchronous messages, making “an actor model architecturally close to Erlang” more precise than the broad word “multithreading.” See the [Erlang documentation](https://www.erlang.org/doc/system/ref_man_processes.html).

Low-level address operations, raw memory access and machine interfaces belong to L2. A structural representation of the high-level program is compatible with such a layer. [Language scope and levels](reference/LMX_semantics.en.md#scope) also define graph interpretation and native execution: the appropriate native variant or graph body determines the path for a particular call. Parts of one system can use both paths under a common behavioral contract.

## Why a simple translator can produce fast native code

A unified program graph does not require a native graph traversal for every arithmetic operation. Typed native locals have ordinary machine representations, and numeric arrays store their elements densely. When implementation, types and binding are known, the model provides a direct C call without graph packaging of arguments, call-table lookup or a universal dispatcher. See [value representation](reference/L2_spec_en.md#value-record), [native binding](reference/L2_spec_en.md#binding-executors), and [direct calls](reference/L2_spec_en.md#explicit-compilation).

For example, with a shared `int: value` declaration and an `int` result:

```lmx
with_one:
    return: base() + 1
```

Autofill of `value` can be expressed as an ordinary C parameter:

```c
int with_one(int value) {
    return base(value) + 1;
}
```

This illustrates value transport; service ABI parameters are omitted from the incomplete fragment. A mutable caller place is transported as its cell’s address while retaining the variable’s own type in LMX. The [executor-binding semantics](reference/LMX_semantics.en.md#binding-executors) distinguish that transport from the user-visible type.

The external C compiler can then perform inlining, constant propagation, removal of redundant computations and loop optimization. Such passes are among [GCC’s ordinary optimization facilities](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html). The LMX translator must express operations and binding while retaining the information that the C compiler needs. “Without a complex optimizer of its own” thus has a concrete technical meaning.

## What comparison with JVM performance means

For the native path, comparable performance is an architecturally grounded possibility. Typed operations, direct calls and ordinary memory accesses do not inherently require a penalty relative to other machine code. Having an interpreter does not force native sections to execute through it; [compilation and native selection](reference/LMX_semantics.en.md#explicit-compilation) are separate mechanisms.

Dynamic implementation selection, checking an unknown type, structural traversal and copying through `merge` retain the cost of work actually performed. An optimizer can remove redundancy when the necessary information is available. HotSpot also eliminates some abstraction costs: it inlines calls, including some virtual calls, and uses escape analysis to eliminate some allocations. See the [HotSpot architecture](https://www.oracle.com/java/technologies/whitepaper.html) and [JVM optimization documentation](https://docs.oracle.com/en/java/javase/24/vm/java-hotspot-virtual-machine-performance-enhancements.html).

The resulting characterization is: **LMX often expresses the examined tasks more compactly than Python while retaining typing, structural contracts, actor-style concurrency and low-level facilities. Interpretation coexists with direct native execution through C99, whose architecture permits performance comparable to an optimized JVM through the capabilities of an external C compiler. Across the expanded collection, brevity is not universal and individual Python advantages can be substantial.**

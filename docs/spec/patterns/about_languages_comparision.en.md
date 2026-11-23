# LMX and other languages: brevity, typing and execution model

Updated **21 November 2026**. [Русская версия](about_languages_comparision.ru.md).

**In this collection, LMX is shorter than Python in 19 of 23 examples**, with **17.41%** less application source overall. The model combines compact notation with typing, actor-style concurrency, low-level operations, and interpretation or native execution. These figures describe the current programs and the stated application/kernel counting boundary.

The discussion concerns the model and the cost of its operations. Native performance comparable to optimized JVM execution is an architectural possibility: typed calculations and known calls can lower to ordinary C, while an external compiler performs machine-code optimization.

## Comparison materials

Every comparison uses the same language order: LMX, Python, Java, C++, C#, TypeScript, Go, Rust. The summary formats preserve alignment:

- Patterns 1–9: [Excel](LMX_Comparison_2026-11-20.xlsx), [PDF](LMX_Comparison_2026-11-20.pdf), [guide](LMX_Design_Patterns.en.md).
- Patterns 10–18: [Excel](LMX_Comparison_10-18.xlsx), [PDF](LMX_Comparison_10-18.pdf), [guide](LMX_Design_Patterns10-18.en.md).
- Patterns 19–23: [Excel](LMX_Comparison_19-23.xlsx), [PDF](LMX_Comparison_19-23.pdf), [guide](LMX_Design_Patterns19-23.en.md).

Individual comparisons contain complete listings, expected results and scenario boundaries; the catalogue is in [README](README.md). Readability is discussed separately in the [Interpreter essay](lmx_beauty.en.md).

## What is measured

The primary metric counts non-whitespace characters in the **main application listing**. Necessary imports, use of library facilities, declarations, wrappers and demo are included. Whitespace is excluded only from this metric. Full size and line count use LF, no blank lines at either edge and one final LF.

The external launch, a launch-only main, printing, test harness and kernel/standard-library source are excluded. In example 23, `copy: sys\OPERANDS_TEMPLATE` is counted; the separately displayed definition of the supplied DATA fragment is not. This is the explicit counting boundary used for all languages.

Names are not normalized; Python omits optional type annotations. Each language uses suitable functions, closures, structures, interfaces or enum variants. A general LMX @ is not presented as a full static signature of every callable. Written types, results and requirements are included in the measured code.

## Documentation and verification

Normative links now target [docs](../README.md): [semantics](../LMX_semantics.en.md), [grammar](../LMX_grammar.en.md) and [L2](../L2_spec_en.md).

Import, copy and merge use standard CODE arguments in every placement. Copy accepts one admitted source; merge accepts two or more. Their field streams are explicitly grouped where one structural result is needed. The receiving context is not an implicit merge source. Written receivers remain in the graph and results are accepted through the namespace. The examples and counts apply these rules.

LMX was reviewed against the model and its results are expectations. All 161 listings in the other seven languages are preserved from the uploaded archive. Earlier execution statements describe previous checks. This revision recounts source and reconciles documents without claiming a new LMX execution or comparative runtime benchmark.

## Results for the current collection

| Examples | LMX | Python | Overall LMX reduction | LMX shorter than Python |
| --- | ---: | ---: | ---: | --- |
| 1–9 | 2081 | 2592 | 19.71% | 8 of 9 |
| 10–18 | 2248 | 2651 | 15.20% | 7 of 9 |
| 19–23 | 1345 | 1627 | 17.33% | 4 of 5 |
| All 1–23 | 5674 | 6870 | 17.41% | 19 of 23 |

The first 18 examples total **4329 versus 5243**, a **17.43%** reduction. LMX is shorter than Python in 15 of 18 cases and shortest among eight languages in 13. Python has the smallest total among the other seven; C++ is shorter than Python for Factory, Builder, Prototype and Memento. In Factory, C++ is also shorter than LMX: **297 versus 306**.

Across the full collection, LMX is shortest among eight languages in **17 of 23** cases. Python is the minimum among the other seven in **17 of 23** rows. Other language totals are Java **9809**, C++ **7743**, C# **9105**, TypeScript **8843**, Go **8241**, and Rust **8890**.

There are four exceptions relative to Python:

| Example | LMX | Python | LMX longer |
| --- | ---: | ---: | ---: |
| Adapter | 163 | 160 | 1.88% |
| Composite | 296 | 295 | 0.34% |
| Proxy | 191 | 181 | 5.52% |
| Singleton | 141 | 127 | 11.02% |

Substantial reductions include Observer **48.24%**, State **39.20%**, Builder **28.86%**, and Template Method **25.25%**. Explicit stream grouping enlarged several LMX listings. Prototype now uses the shorter bindFields operation of the single current kernel; its procedural equivalent remains beside it. These are alternative algorithms, not different library versions. Interpreter became shorter through reuse of a common header.

## Flyweight and Interpreter

[Flyweight](21_flyweight_comparison.md) uses a named width field in both versions: an immutable LMX structure and a Python dataclass(frozen=True). Two requests for thin return the same object; position is supplied separately. LMX uses **281** non-whitespace characters against **309**, a **9.06%** reduction. Nested drawing sees get lexically. This is a shared-state scenario; the table does not measure memory savings.

[Interpreter](23_interpreter_comparison.md) retains `(x + 3) + x` and evaluates it at 2 and 5. Python assembles closures; LMX retains the expression in calculate’s graph. Both demonstrations return 20. The short LMX listing shows this repeated evaluation without a separate universal API for constructing arbitrary trees at runtime.

Method add obtains its common header through `copy: sys\OPERANDS_TEMPLATE`; nested example sees add lexically. The supplied DATA fragment provides general left/right references, PASS_ARGS_AS_IS 0 and addition precedence. It has no return: the concrete operand declares return:int in its own DATA. Mandatory fields are supplied by copy, not omitted. The body reads prepared values through `\left` and `\right[0]` and returns a number. Mode 1 and explicit sys\eval are unnecessary here.

The LMX application uses **159** non-whitespace characters against Python’s **185**, **14.05% fewer**. Full formatted size is **266 versus 247**, **7.69% larger**, with **12 versus 13** lines. The template definition is shown for understanding and excluded from the application count; its copy line is included. The external call `operands\example\demo()` is excluded too.

## Typing and structural contracts

The LMX model provides physical value types, descriptions of admissible values, a conversion context, and structural compatibility checks through `satisfies`. A shared physical representation of structures does not remove requirements on the fields and operations actually used. Contracts can differ even when representations coincide: admissible ranges and usage matter alongside cell size.

It is therefore accurate to say that compact notation coexists with typing and checkable contracts. Some data and call targets are selected dynamically. The interpreter applies the common admission mechanism at reached calls; prepared native execution has no additional automatic runtime `satisfies` layer. Explicitly written checks execute on either path. See [value descriptions](../LMX_semantics.en.md#descriptions), [the type and conversion context](../LMX_semantics.en.md#conversion-context), [used-interface checking](../LMX_semantics.en.md#admission), and [the binding and signature contract](../LMX_semantics.en.md#binding-places).

## Actors, low-level operations and two execution paths

The Erlang comparison concerns the organization of concurrency: participants have their own state, communicate through messages, and execute serially within each participant while different participants may run concurrently. In LMX, a Message owns its graph; a running Thread has mail and at most one active turn. A logical Thread does not require a dedicated OS thread. See [Messages and actors](../LMX_semantics.en.md#messages) and [arenas](../L2_spec_en.md#arena). Erlang also bases concurrency on separate processes and asynchronous messages, making “an actor model architecturally close to Erlang” more precise than the broad word “multithreading.” See the [Erlang documentation](https://www.erlang.org/doc/system/ref_man_processes.html).

Low-level address operations, raw memory access and machine interfaces belong to L2. A structural representation of the high-level program is compatible with such a layer. [Language scope and levels](../LMX_semantics.en.md#scope) also define graph interpretation and native execution: the appropriate native variant or graph body determines the path for a particular call. Parts of one system can use both paths under a common behavioral contract.

## Why a simple translator can produce fast native code

A unified program graph does not require a native graph traversal for every arithmetic operation. Typed native locals have ordinary machine representations, and numeric arrays store their elements densely. When implementation, types and binding are known, the model provides a direct C call without graph packaging of arguments, call-table lookup or a universal dispatcher. See [value representation](../L2_spec_en.md#value-record), [native binding](../L2_spec_en.md#binding-executors), and [direct calls](../L2_spec_en.md#explicit-compilation).

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
This illustrates value transport; service ABI parameters are omitted from the incomplete fragment. A mutable caller place is transported as its cell’s address while retaining the variable’s own type in LMX. The [executor-binding semantics](../LMX_semantics.en.md#binding-executors) distinguish that transport from the user-visible type.

The external C compiler can then perform inlining, constant propagation, removal of redundant computations and loop optimization. Such passes are among [GCC’s ordinary optimization facilities](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html). The LMX translator must express operations and binding while retaining the information that the C compiler needs. “Without a complex optimizer of its own” thus has a concrete technical meaning.

## What comparison with JVM performance means

For the native path, comparable performance is an architecturally grounded possibility. Typed operations, direct calls and ordinary memory accesses do not inherently require a penalty relative to other machine code. Having an interpreter does not force native sections to execute through it; [compilation and native selection](../LMX_semantics.en.md#explicit-compilation) are separate mechanisms.

Dynamic implementation selection, checking an unknown type, structural traversal and copying through `copy`/`merge` retain the cost of work actually performed. An optimizer can remove redundancy when the necessary information is available. HotSpot also eliminates some abstraction costs: it inlines calls, including some virtual calls, and uses escape analysis to eliminate some allocations. See the [HotSpot architecture](https://www.oracle.com/java/technologies/whitepaper.html) and [JVM optimization documentation](https://docs.oracle.com/en/java/javase/24/vm/java-hotspot-virtual-machine-performance-enhancements.html).

The resulting characterization is: **LMX often expresses the examined tasks more compactly than Python while retaining typing, structural contracts, actor-style concurrency and low-level facilities. Interpretation coexists with direct native execution through C99, whose architecture permits performance comparable to an optimized JVM through the capabilities of an external C compiler. This collection defines the scope of that conclusion: 18 shorter LMX examples, five exceptions, and one explicit counting method.**

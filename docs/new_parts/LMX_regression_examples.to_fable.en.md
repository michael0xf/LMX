# LMX: renewed examples and regression cases for Fable

**Date:** 21 November 2026.  
**Purpose:** give Fable concrete programs, expected observations, negative controls, and execution checks for the current language revision.  
**Verification status:** the examples have been reviewed against the attached documents and their stated arithmetic/state transitions checked. They have **not** been executed on an LMX kernel. These are acceptance inputs and expected results, not passing implementation receipts.

## Contents and coverage

| Section | Case families | Main observations |
|---|---:|---|
| [Binding, declarations, and import](#binding) | 18 | Defaults, alias/copy distinction, private, fn labels, repeated declaration arguments |
| [Typing](#typing) | 7 | Physical field maps, complete models, fn contracts, behavior, nil and conversions |
| [Operands and evaluation](#operands) | 18 | Prepared/raw modes, effect counts, argument boundaries, precedence, source graph |
| [Validation and integration](#validation) | 5 | String checker, mock, catch, command/feedback, separate admission/test phases |
| [All 23 patterns](#patterns) | 23 | Complete independent source programs and distinguishing observations |
| [Graph, arrays, and persistence](#graph) | 13 | Local/source separation, copies, cycles, schema composition, references, returned method, zero-payload uninit |
| [Native and interpreter execution](#native) | 6 | Four path combinations, compilation/turn boundary, dispatch, cleanup |
| [Messages](#messages) | 4 | Serial ownership, fan-out, timeout arguments, storage transfer |
| [Phase contract Q01](#author-question) | — | Current construction, build-test, runtime and dispatch boundaries |

There are **94 case families**. Most contain several positive, negative, or repeated-call variants;
the table does not claim 94 executed tests. V05 uses the current separated-phase contract.
C-01 derives the no-RHS inline-local result from the current caller-source and shadowing rules: a distinct uninitialized place, not implicit copying of the outer local.

## 1. Authority, scope, and how to use this document

This corpus updates the earlier discussions of `add5`, defaults and free inputs, nested actions, code/data roles, lexical copying, native reuse, local state, structural typing, `test`, `catch`, RegEx-like validation, mocks, and integration self-testing. It also supplies a new complete scenario for each of the 23 attached design patterns and focused cases for the integrated change requirements.

### Governing sources

The normative model is the supplied `docs/` packet. The current author's operand-template convenience is applied to P23. Pattern guides are companion examples of that model; a stale example does not establish a competing rule. The stream requirement fixes `import`, `copy` and `merge` as ordinary CODE-argument consumers in every placement.

| Code used below | Document / package path | Role |
|---|---|---|
| O / OPERAND | [to_fable_operands_arguments_priorities.md](../tasks/to_fable_operands_arguments_priorities.md), revision 6, updated 20 November | Structural operand discovery, prepared/raw inputs, priorities, assignments, `sys\eval`, names |
| B / BIND | [LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md](../tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md) | Binding places, two-way private, actual parent, ordinary call, named `fn` requirements |
| M / STREAM | [LMX_semantics.en.md#composition](../LMX_semantics.en.md#composition) | Ordinary CODE sources in every placement; streams, explicit grouping, one-source copy and multi-source merge |
| BLANK | [LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md](../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md) | Blank-line block completion by the common parser |
| D / DECL | [LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md](../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md) | Declaration arguments and their repeated execution; const-root import; fn label mapping |
| UNINIT | [LMX_semantics.en.md#uninit-zero-payload](../LMX_semantics.en.md#uninit-zero-payload) | Code-only `uninit:T`, zero value payload, local writes versus explicit graph-fragment replacement |
| P1 / DP1 | [LMX_Design_Patterns.en.md](LMX_Design_Patterns.en.md) | Current examples 1–9 and explanatory corrections |
| P2 / DP2 | [LMX_Design_Patterns10-18.en.md](LMX_Design_Patterns10-18.en.md) | Current examples 10–18 |
| P3 / DP3 | [LMX_Design_Patterns19-23.en.md](LMX_Design_Patterns19-23.en.md) | Current examples 19–23, updated 21 November |
| S / SEM | [LMX_semantics.en.md](../LMX_semantics.en.md) | Current normative semantics with the supplied requirements integrated |
| G / GRAMMAR | [LMX_grammar.en.md](../LMX_grammar.en.md) | Current common parsing and lexical rules |
| [GUIDE] | [LMX_semantics_guide.en.md](../LMX_semantics_guide.en.md) | Worked explanations; superseded examples do not override the directives |
| L2 | [L2_spec_en.md](../L2_spec_en.md) | Runtime/representation contracts and machine-level boundaries |
| [CORE] | [CORE.md](../../CORE.md) | Architecture; historical implementation descriptions remain historical |
| [CODING] | [L2_L3_CODING_INSTRUCTION.md](../../L2_L3_CODING_INSTRUCTION.md) | Existing implementation, validation, and source-style workflow |
| README | [README.md](README.md) | Pattern inventory and verification scope |

Document links are relative to this file. Pattern comparisons, pattern guides and README are beside it; the normative documents are under `docs/`, their current requirements under `docs/TZ/`, and accepted supplements under `docs/Old_TZ/`. Section names and anchors identify the current contracts. Obsolete exported-file line numbers have been removed. The final snapshot records the exact normative files bundled with this revision.

### Required handling of contradictions

**Infer the behavior from the current TZ and their general rules, then repair inconsistent explanations and examples. Ask the author only if the governing current TZ explicitly prescribe incompatible outcomes.** In that case, present both passages and the smallest distinguishing example, and continue independent corrections. Missing wording in an old example is not by itself a new language decision; neither the existing implementation nor an old passing test overrides the current rules.

An explicitly superseded statement is different: apply the accepted replacement and repair the stale documentation. Do not ask the author again whether to remove `sys\operand`, preserve the actual callable parent, or publish locals through `dirty`: the current directives already answer those questions. Q01 at the end records the now-separated admission/test phases. C-01 is resolved by the current immediate-caller autofill and nested-shadowing rules; it no longer waits for a separate author decision.

### Running the examples

- Each full source listing is an independent fixture. Do not concatenate the entire document into one program; many fixtures deliberately reuse small names.
- Invoke the stated method from the existing test runner. Source-root loading and an R0 boot protocol are not invented here. A table of call variants uses the source fixture named immediately above it.
- Preserve physical blank lines. Under the current design-pattern documents a blank line closes the whole ordinary root block. There is no blank line inside a root that is intended to continue. `---` is used only where a genuine multi-level closure is needed.
- Start with a fresh graph unless a case explicitly specifies a sequence. A second run within one case is intentional where it tests state retention or reinitialization.
- A **source case** provides language code; a **graph/backend/protocol fixture** specifies construction and observations for the existing L2/L3 harness where public setup syntax is not fully specified. These descriptions are not new language APIs. Short expression blocks are probes or substitutions, not complete modules.
- Run negative variants separately. Record where rejection occurs when the governing text specifies a phase; otherwise assert the required refusal without inventing a diagnostic spelling. A successful translation alone does not establish a positive runtime result.
- Observe the numeric result, call counts, selected write destinations, source-graph preservation, and reference relationships relevant to the case. A matching final number can conceal wrong binding or an extra effect.
- Use the existing **L2/L3** test/harness path from [CODING]. This handoff introduces no maintained Python/C test runner and no blanket full-self-build requirement. Run the affected component and dependent cases first; use the existing broader gates when their conditions apply.

### Current decisions the examples intentionally encode

An executable Structure uses its actual parent as data. A call does not substitute another data graph. `fn: Name Data` creates a positional signature requirement, not an executable function. Named actuals through that requirement use its public labels and then map by position to the real candidate.

An own declared input receives an explicit value, its ready/default description, or permitted autofill into its own place. A free name can instead designate the immediate caller's existing local place. The older transitive fallback remains an own local copy. Their different write destinations are tested separately. No local write-back/flush/dirty protocol is reinstated by these examples.

A source primitive without a value is a code-only `uninit:T` record with `sizeof(value) = 0`: it does not contain preallocated T storage or a complete inner T record. An ordinary local assignment changes the active place only. An explicit graph assignment replaces the selected fragment, for example `{uninit_int}` with `{int 5}`. This supplies no invariant that an old raw value address survives that replacement. G13 checks these distinctions without imposing an allocation strategy.

`copy` copies one admitted structural source; `merge` composes at least two. Both emit field streams using one graph-copy map per operation. A grouped result, such as `(copy(Source))` or `(merge(Model Values))`, gives one Structure before the next consumer applies its ordinary rules. Both retain the required lexical closure. Neither silently captures all locals of the calling activation or turns free names into bound formals. The receiving DATA Structure is never an implicit merge source; separate operations retain separate maps and normal DATA redeclaration behavior. `import` uses the same standard CODE source processing but selects root constant declarations by reference, including ordinary user Structures. A returned method in G12 has explicitly prepared copied state. Data copying and native-entry registration are separate operations; code-update tests use explicit compilation and a turn boundary.

An explicitly supplied ordinary structural template keeps all its written requirements. A named `fn` requirement instead compares the ordered input types and result contract. Behavior is checked by ordinary checker code. The direct checker programs and the phase-specific cases in Q01 exercise separate parts of the documented admission process.

### Earlier discussion → current regression case

| Earlier question or example | Cases |
|---|---|
| `add5(1; y := 25)` versus a genuine saved lexical value | B-01, B-02, G12 |
| Nested action changing `y`; copy versus communication with the caller | B-03–B-05, P07, P10 |
| `int: i findValue()` and organized code/data editing | B-07–B-08, G01–G02, G11 |
| `uninit:T`, zero payload, `nil` versus zero, explicit graph initialization | G13, B-06, C-01, T05 |
| Local variables and the former `dirty` discussion | B-03–B-08, G01–G02, N01, N06 |
| Dynamic binding after copying; explicit `node\` | B-02, G12, P22 |
| Copying, aliases, cycles, immutable sharing and prototype changes | G03–G06, P03, P12, P15–P17, P19–P22 |
| Native execution, interpretation, reuse and modified code | N01–N05, OP18 |
| Complete inspectable graph and serialization | OP17, G01, G10–G11 |
| Arrays as Structures; mutable backing and references | G07–G09, OP02, OP16 |
| Typing, `implements`, callable contracts and value guarantees | T01–T07, B-10–B-13, V01–V04 |
| RegEx analogue | V01 |
| Where a mock goes; actual candidate validation | V02, T02 |
| Nearby `catch`, cleanup and recoverable failures | V03, P01, P09, N06 |
| Interpreted integration stand / activation self-test | V04–V05, Q01 |
| Concurrency, Message ownership and remote calls | M01–M04 |
| The new operator and declaration-argument rules | OP01–OP18, D-01–D-04, P01, P23 |
| All 23 supplied design patterns | P01–P23: complete independent programs |

<a id="binding"></a>
## B. Binding, defaults, signatures, declaration arguments, and import

B-01–B-13 cover binding/callables, D-01–D-04 cover declaration arguments and import, and C-01 checks the derived uninitialized state of a new no-RHS local in an inline nested scope.

### B-01 — `add5`: compose a real default, retain the explicit argument

```lmx
Addition:
    int: x
    int: y
    return: int
    add:
        return: x + y

Checks:
    return: int
    demo:
        int: y 100
        @: fiveContext (merge(Addition; (int: y 5)))
        @: add5 fiveContext\add
        int: omitted add5(1)
        int: overridden add5(1; y := 25)
        int: zero add5(1; y := 0)
        return: omitted * 10000 + overridden * 100 + zero
```

Run `Checks\demo()`. Expect **62601**, encoding `6`, `26`, `1`. The copied data still declares both `x` and `y`; explicit `y := 25` remains admissible. The caller's `y = 100` cannot replace the ready default 5. Zero is explicitly supplied, not omitted. The original `Addition\y` remains uninitialized; changing the copied default must not initialize it.

This replaces the historical ambiguous `merge(add; y: 5)` illustration: here the source explicitly composes the data containing the formal, and then selects its nested implementation. It does not compose a body and silently invent an input.

**Basis:** [B] §6.1; [B] §4.2; [S] §20 (model slots and callable parts). Optional formal positions remain part of a signature: [B] §8.3.

### B-02 — Free dynamic input and explicit lexical input remain distinguishable after `copy`

```lmx
Source:
    int: y 5
    methods:
        int: x
        return: int
        dynamic:
            return: x + y
        lexical:
            return: x + node\y

Checks:
    return: int
    demo:
        @: copied (copy(Source))
        Source\y := 8
        int: y 25
        int: a copied\methods\dynamic(1)
        int: b copied\methods\lexical(1)
        return: a * 100 + b
```

With a fresh source, `Checks\demo()` returns **2606**. The free `y` gets the immediate caller's local 25; `node\y` reaches the copy's lexical value 5. Afterwards `Source\y = 8` and `copied\y = 5`. `node\` is lexical selection, not “one parent hop.”

Also reject `copied\methods\dynamic(1; y := 25)` as an explicit call with an unknown formal: `y` is a free name here; the actual data of `dynamic` only declares `x`. A dynamic source is not silently added to the explicit signature.

**Basis:** [B] §§4.2 and 6.2–6.5; [S] §20; [P1] “Reading the programs,” lexical-access paragraph.

### B-03 — Original nested action, now with the two deliberately different bindings

```lmx
Own:
    int: y
    step:
        y += 3

Free:
    step:
        y += 3

Checks:
    return: int
    own_copy:
        int: y 0
        Own\step()
        return: y
    caller_place:
        int: y 0
        Free\step()
        return: y
```

| Call | Expected result | Actual write destination |
|---|---:|---|
| `Checks\own_copy()` | 0 | Own working place of `Own\step`, initially autofilled with 0 |
| `Checks\caller_place()` | 3 | The caller's existing local `y` |

Do not preserve the old “every external write is a local copy” reading for `Free\step`: B adds a higher-priority transparent caller-place rule. Conversely, do not turn the declared `Own.y` into an alias. Both variables retain type `int`; neither source needs explicit dereferencing.

Variant: pass `Own\step(y := 10)` from caller `y = 0`; caller remains 0. This tests ordinary explicit copy semantics separately from autofill.

**Basis:** [B] §6 and acceptance B01–B05; [P1] §7.

### B-04 — A transit-only intermediary and an intermediary that establishes a place

```lmx
Actions:
    change:
        value += 3
    transit:
        change()
    connected:
        required: value
        change()

Checks:
    return: int
    through_fallback:
        int: value 5
        Actions\transit()
        return: value
    through_place:
        int: value 5
        Actions\connected()
        return: value
```

Expect **5** from `through_fallback()` and **8** from `through_place()`. `transit` never consumes `value`, so the retained older transitive channel gives `change` an own local copy. `required: value` in `connected` consumes and checks the visible local place; its call forwards the established alias. It does not declare a new variable.

The harness must also inspect write identity in both cases, not merely allow these two numbers to arise from delayed copy-out.

**Basis:** [B] §6.4; B acceptance B19–B21; [P1] §7 explicitly explains the role of `required: value`.

### B-05 — Retarget a caller-local reference without exposing a pointer-to-pointer type

```lmx
First:
    int: marker 4

Second:
    int: marker 9

Actions:
    replace:
        selected := Second

Checks:
    return: int
    demo:
        @: selected First
        Actions\replace()
        return: selected\marker
```

Expect **9**. `selected` remains an ordinary reference variable in LMX; the hidden native address must address that variable's cell, not merely the previously selected Structure. `First\marker` remains 4. A second fixture giving `replace` an own declared `selected` input must leave the caller pointing at `First`.

**Basis:** [B] §3; [B] §6.2; acceptance B06.

### B-06 — Two-way `private`: omitted supply and explicit supply

```lmx
Sink:
    int: x
    return: int
    has_value:
        return: x != nil

PrivateSink:
    private: int: x
    return: int
    has_value:
        return: x != nil

Checks:
    return: int
    private_source:
        private: int: x 7
        return: Sink\has_value()
    explicit_private_source:
        private: int: x 7
        return: Sink\has_value(x := x)
    private_receiver:
        int: x 7
        return: PrivateSink\has_value()
    explicit_private_receiver:
        int: x 7
        return: PrivateSink\has_value(x := x)
```

Expect **0, 1, 0, 1**, respectively. No other `x` source is present in each isolated fixture. `private` filters implicit binding in both directions; it does not reject explicit supply. The comparisons use the existing uninitialized-value `nil` rule; do not replace an uninitialized integer with 0.

Separate positive source-access check: the actual graph path through the modifier remains `PrivateSink\private\x`; binding must not flatten it into `PrivateSink\x`. An explicit write through a permitted graph path follows the ordinary mutability rules.

**Basis:** [B] §5; [B] §6.1; [S] §12 `private` path rule.

### B-07 — A computed local is not overwritten code

```lmx
Producer:
    int: calls 0
    return: int
    make:
        node\calls += 1
        return: 9

LocalCode:
    return: int
    demo:
        int: i Producer\make()
        i := 12
        return: i
```

Starting with `Producer\calls = 0`, run `LocalCode\demo()` twice. Both calls return **12** and the persistent counter becomes **2**. The source declaration in `LocalCode\demo` continues to contain the call `Producer\make()`. Neither call publishes 12 into the source code or replaces the initializer. The second call must therefore still execute `make` once.

Compare the written code occurrences, initializer expression and their reference identities before and after the two runs using the existing graph inspector. Do not recursively equate all external pointee state: the explicitly mutated `Producer\calls` is an expected change. If serialization traverses that external graph, compare the relevant syntax fragment rather than asserting equality of the whole serialization. No dirty flags, writeback phase, automatic initializer destruction, or extra source graph is required to explain the behavior.

This is the current analogue of the earlier `int: i findValue()` concern. The new accepted semantics make it an activation-local computation; its assignment no longer edits the code occurrence.

**Basis:** [B] §§7.2–7.3; [B] §10.1; [B] §§11.3–12; [D] §4.3.

### B-08 — Unused and explicitly replaced computed defaults remain unevaluated

```lmx
Producer:
    int: calls 0
    return: int
    make:
        node\calls += 1
        return: 9

Deferred:
    int: value Producer\make()
    return: int
    ignore:
        return: 4
    twice:
        return: value + value
```

Run these as independent cases from counter 0:

| Call | Result | `Producer\calls` afterwards |
|---|---:|---:|
| `Deferred\ignore()` | 4 | 0 |
| `Deferred\twice(value := 6)` | 12 | 0 |
| `Deferred\twice()` | 18 | 1 |

No entry pass executes every initializer. Two reads of the established working value do not run its initializer twice. A new independent call of `twice()` creates its ordinary new activation and runs the source initializer once again.

**Basis:** [B] §§6.1 and 7.3; [B] §10.1; [D] §4.1; [S] §12.

### B-09 — A callable's actual parent survives reference placement and import

```lmx
Original:
    int: value 4
    return: int
    read:
        return: value

Other:
    int: value 90
    @: alias Original\read
    return: int
    demo:
        return: alias()
```

Expect **4** from `Other\demo()`, even though the caller's data has a ready value 90. `Original\read` has its own ready input default 4 and its original parent. Storing its reference in `Other` does not reparent it. With the explicit call `alias(value := 90)`, expect 90 through ordinary actual supply, still without changing either graph value.

Also compare direct `Original\read()` with the unambiguous explicit dispatcher form `call(code := Original\read)`: same actual parent, same default, same result 4.

**Basis:** [B] §§4.1–4.2; [B] §6.1; [D] §6.1.

### B-10 — `fn` external labels map by position, even when candidate names are swapped

```lmx
fn: PairSignature (int: left; int: right; return: int)

Backend:
    int: right
    int: left
    return: int
    encode:
        return: right * 10 + left

Checks:
    return: int
    demo:
        @: chosen PairSignature Backend\encode
        return: chosen(left := 2; right := 7)
```

Expect **27**, not 72. The signature's `left` is external position 1, which maps to candidate `right`; signature `right` maps to candidate `left`. A direct `Backend\encode(left := 2; right := 7)` returns **72** because it uses the candidate's own labels.

This is deliberately a noncommutative operation; addition would conceal the incorrect name-based remapping.

**Basis:** [B] §8.3; [B] §8.5; [D] §5.1.

### B-11 — A signature supplies type shape and public labels, not its default

```lmx
fn: ValueSignature (int: publicValue 1; return: int)

Backend:
    int: actualValue 8
    return: int
    read:
        return: actualValue

Checks:
    return: int
    demo:
        @: chosen ValueSignature Backend\read
        int: a chosen()
        int: b chosen(publicValue := 0)
        return: a * 10 + b
```

Expect **80**. The first call uses the candidate's default 8; the second explicitly supplies 0. The default 1 in the `fn` description is not installed in the candidate. Reject `chosen(actualValue := 3)` as an unknown external label, while direct `Backend\read(actualValue := 3)` returns 3.

Variant with `required: int: actualValue` and no default: signature compatibility can still be positive, but `chosen()` is inadmissible even if the caller has a local `actualValue`. The call's missing required actual is decided before autofill. Supplying `publicValue := 3` passes the positional actual explicitly.

**Basis:** [B] §§8.4–8.5; [B] §9.7; [D] §5.1.

### B-12 — Type order matters; optional positions do not vanish

```lmx
fn: SelectionSignature (int: count; []: char text; return: int)

Compatible:
    int: n
    []: char s
    return: int
    choose:
        return: n

Reordered:
    []: char text
    int: count
    return: int
    choose:
        return: count
```

- Accept `@: selected SelectionSignature Compatible\choose`.
- `selected(text := "abc"; count := 6)` returns 6.
- Reject `@: selected SelectionSignature Reordered\choose`: the candidate type order is `Array<char>, int`.
- Direct `Reordered\choose(count := 6; text := "abc")` remains valid and returns 6.
- Reject candidates with one fewer declared input, including a missing optional input, or a different presence/type of result.

This is a compatibility test, not an assertion that two algorithms with the same signature return the same result.

**Basis:** [B] §§8.3 and 8.5.

### B-13 — Whole-Structure and field-expansion selection

```lmx
Arg:
    int: x 9

Numeric:
    int: x
    return: int
    read:
        return: x

Model:
    int: x

Structural:
    @: object Model
    return: int
    read:
        return: object\x
```

| Call | Selection and expected result |
|---|---|
| `Numeric\read(Arg)` | W cannot supply a Structure to int; E supplies its single `x = 9`; result 9 |
| `Numeric\read(x := Arg)` | Explicit supply disables E; reject incompatible whole Structure |
| `Structural\read(object := Arg)` | W only; accept whole Arg; result 9 |
| `Structural\read(Arg)` | W accepts whole Arg; E has no matching input `x`; result 9 |

At invocation, use the already selected map. Do not expand the chosen actual a second time.

**Harness-level ambiguity fixtures:** additionally construct exactly the situations [B] §9.8 describes, without introducing an undocumented overload syntax. When W and E both fit one declaration, reject; when they fit different declarations, reject. A callable `C` whose whole value fits `call(code)` and whose fields fit `call(args code)` must make `call(C)` ambiguous. `call(code := C)` excludes E and selects only the one-argument form. This last assertion concerns selection; the harness must separately supply an executable body when it also wants to test the subsequent execution.

**Basis:** [B] §§9.2–9.8; [B] §4.1.

### D-01 — Repeated declaration arguments: negative, zero and positive elements

```lmx
stream:
    int: calls 0
    return: int
    next:
        throws: Stop
        node\calls += 1
        if: node\calls = 1
            return: -2
        if: node\calls = 2
            return: 0
        if: node\calls = 3
            return: 4
        throw: Stop()
    demo:
        node\calls := 0
        int: total 0
        cycles\iterate: int: item stream\next()
            item += 3
            total += item
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

Run `stream\demo()`. Expect **22** and `stream\calls = 4`.

| Step | `next` result | Body's `item` after `+= 3` | Added to `total` |
|---|---:|---:|---:|
| 1 | −2 | 1 | 2 |
| 2 | 0 | 3 | 6 |
| 3 | 4 | 7 | 14 |
| 4 | `Stop` | No body execution | 0 |

The initializer runs once per executed step; two reads in the body do not run it again. Zero is a data value. The accepted declaration remains executable for the next step; the body sees the established receiving-activation place. Calling `demo()` again starts a fresh total and repeats the result; the definition of `cycles` gains no persistent `item` field.

Repeat after systematically renaming `iteration/body/item` to `advance/action/element`. The results must be unchanged; no name-specific special branch is permitted.

**Basis:** [D] §§3–4 and §7; [P1] §1 (the local accumulator and iterator arrangement).

### D-02 — Reorder named declaration arguments without reordering execution

Reuse D-01 and replace only its loop invocation with:

```lmx
cycles\iterate(
    body := (item += 3; total += item; total += item);
    iteration := int(item stream\next())
)
```

Expect the same **22**, four `next()` calls and three body executions. Passing `body` first does not execute it first; `iterate` controls that order.

The following on-position named actual followed by a positional actual is also admissible:

```lmx
cycles\iterate(iteration := int(item stream\next()); (item += 3; total += item; total += item))
```

Reject this off-position named actual followed by an unnamed actual:

```lmx
cycles\iterate(body := (); int(item stream\next()))
```

The rejection precedes initializer execution. With the valid empty-body variant below, expect four `next()` calls and no body effects; empty Structure is a supplied value:

```lmx
cycles\iterate(body := (); iteration := int(item stream\next()))
```

**Basis:** [D] §3.3 and §8.

### D-03 — A matched declaration is retained, while an ordinary callable actual still executes

```lmx
Producer:
    int: calls 0
    return: int
    make:
        node\calls += 1
        return: 7

Receiver:
    int: first
    int: second
    return: int
    ignore:
        return: 4
    read:
        return: second + second
```

Run from counter 0 in separate fixtures:

| Call | Result | Producer calls | Meaning |
|---|---:|---:|---|
| `Receiver\ignore(int: second Producer\make())` | 4 | 0 | Found name `second` receives its declaration form, which is unused |
| `Receiver\read(int: second Producer\make())` | 14 | 1 | First consumed value evaluates the retained description once |
| `Receiver\ignore(second := Producer\make())` | 4 | 1 | Ordinary callable actual executes under the ordinary call contract |

The first declaration does not fill position `first`; the name exists in the callee data, so the named branch applies. Unlike D-01, this is not the unknown inner-name positional branch. Passing the declaration form must not overwrite `Receiver`'s source graph. Do not apply blanket quotation to every callable actual.

**Basis:** [D] §§3.1–3.2; [D] §5; [B] §10.1.

### D-04 — Import ordinary structure names and signature names, preserve parents

```lmx
Library:
    const: int: factor 3
    int: mutableValue 90
    Inputs:
        int: n
        return: int
    fn: TransformSignature Inputs
    Transform:
        int: n
        return: int
        apply:
            return: n * 3
    ---
    @: selected TransformSignature Transform\apply

Use:
    import: Library
    return: int
    demo:
        @: chosen TransformSignature Transform\apply
        return: chosen(4) + factor
```

Expect **15**. `factor`, `Inputs`, `TransformSignature` and `Transform` become imported names. `mutableValue` and `selected` do not. Nested `n`, `return` and `apply` are not lifted into `Use`; the actual parent of the chosen callable remains `Library\Transform`. This is namespace import, not graph copying or parent replacement.

Negative fixtures directly reading bare `mutableValue` or `selected` in `Use\demo`, with no other source in scope, must fail at the ordinary reached name resolution. Do not claim a negative test from a dead branch.

Multi-source variant: supply another Structure containing `const: int: bias 2`, replace the import with `import(Library Extra)`, and add `bias` to the final expression. Expect `17`, with the original imported parents preserved. Exercise the import both in `Use`'s DATA and as reached code in `demo`; its source arguments use ordinary CODE processing in both placements. The written import record stays in the source graph.

In a nested-consumer harness, `f(import(Library Extra))` supplies its stream to `f` only; it must not also install the imported names in the caller as an extra effect. For a one-written-source fixture whose W and E readings both admit the sources, require ordinary ambiguity, not an import-specific preference for W. The multi-source example above is not such an ambiguity fixture.

**Basis:** [D] §§6–6.1; D acceptance I01–I09; [import](../LMX_semantics.en.md#import-receiver); [streams and W/E](../LMX_semantics.en.md#composition).

### C-01 — A no-RHS local in an inline nested scope remains uninitialized

This follows from [B] §§6.1 and 7.2–7.4. Autofill uses the immediate caller's local context; lexical nesting alone does not create another callable invocation or make the outer inline area a new caller. The inner declaration creates its own place and shadows the outer one.

```lmx
Worker:
    return: int
    work:
        int: x 5
        if: x = 5
            int: x
            required: x
        return: x
```

Invoke `Worker\work()` from a caller with no local `x`. **Expected:** the inner place is `uninit:int`, and the reached `required: x` refuses; there is no normal numeric result. Do not read an uninitialized integer to test this rule and do not silently substitute either 0 or the outer value 5. The outer place retains 5.

**Positive control:** change only the inner declaration to `int: x 9`. The required check then succeeds and `Worker\work()` returns **5**, because leaving the inline block reveals the unchanged outer place. Inspect distinct place identities while the block is active. This derives the earlier bounded control example without adding lexical-area autofill, an entry initialization pass or publication of inner locals.


<a id="typing"></a>
## T. Typing, explicit structural requirements, and behavior

These are current LMX analogues of the earlier typing discussion. They test explicit structural requirements, ordered callable requirements, initialization state, and concrete value validation.

### T01 — A model's physical field order need not match the candidate's

```lmx
CoordinateModel:
    int: x
    int: y

Scrambled:
    int: y 7
    int: extra 91
    int: x 4

CoordinateProbe:
    return: int
    run:
        @: view CoordinateModel Scrambled
        int: before view\x * 10 + view\y
        view\x := 9
        return: before * 100 + view\x * 10 + view\y
```

Run `CoordinateProbe\run()` from the written initial graph. Expect **4797**.
Afterward `Scrambled\x = 9`, `Scrambled\y = 7`, and `Scrambled\extra = 91`.
The typed reference transports the same candidate, without an implicit copy.

The harness must inspect the established correspondence: model `x` resolves to
the candidate's actual `x` place, despite its different physical position; model
`y` resolves to the candidate's `y`. Taking addresses and writing through the
correspondence must select those same places. Do not sort the source fields or
mistake the model's slot zero for the candidate's slot zero.

Run the public code in interpreted and native execution where supported. Test
the presence/absence of any automatic admission invocation separately under the
phase-specific cases in V05/Q01; this result oracle checks the admitted program's values and places.

**Basis:** [B] §8.2 (all explicit requirements, extra candidate fields
permitted); [S] §7 (physical correspondence); [L2] §14
(correspondence belongs to the reception/traversal, not a persistent arena map).

### T02 — Same fn signature, different behavior

```lmx
fn: UnaryNumber (int: input; return: int)

Increment:
    int: value
    return: int
    apply:
        return: value + 1

Decrement:
    int: argument
    return: int
    apply:
        return: argument - 1

Checker:
    @: candidate
    return: int
    at_zero:
        return: candidate(0) = 1

BehaviorProbe:
    return: int
    run:
        @: first UnaryNumber Increment\apply
        @: second UnaryNumber Decrement\apply
        int: good Checker\at_zero(candidate := first)
        int: bad Checker\at_zero(candidate := second)
        return: good * 10 + bad
```

Run `BehaviorProbe\run()`. Expect **10**. Both reference initializations satisfy
the same positional fn requirement: one integer input and an integer result.
The methods have different formal names and different bodies. The ordinary
checker returns 1 for the first and 0 for the second.

This source calls the checker explicitly, so its expected behavior does not
depend on an implicit invocation of `test`. A single successful
test of `Increment` is a statement about the performed check; it is not a proof
about all possible inputs or a reason to accept the decrementing implementation.

**Basis:** [B] §§8.1–8.5, especially; [S] §7
(ordinary checker candidate, integer verdict). This is the direct analogue of
distinguishing a type-correct function from a function with the required behavior.

### T03 — An explicit ordinary model checks every requirement written in it

Use graph fixtures corresponding to these ordinary declarations:

```lmx
Minimal:
    int: x

Richer:
    int: x
    int: y

OnlyX:
    int: x 12

Both:
    int: y 5
    int: x 12
    int: spare 100
```

Invoke the public `implements` receiver explicitly in the harness, preserving
the distinction between success and the receiver's implementation-specific
representation of its result:

| Direct check | Required outcome |
|---|---|
| `implements(OnlyX, Minimal)` | Success |
| `implements(OnlyX, Richer)` | Failure: missing `y` |
| `implements(Both, Richer)` | Success: order and extra `spare` do not invalidate the model |
| `implements(OnlyX, Richer, ConsumerReadingOnlyX)` | Failure for the explicitly supplied richer model; do not delete its `y` requirement |

If an ordinary model explicitly contains a method and requirements within its
body subtree, include them in the structural comparison. A matching pair of
input/result types does not justify dropping that subtree. An actual `fn`
requirement instead uses the positional callable rule illustrated by T02.

**Scope:** current [SEM] §7 distinguishes a Consumer-derived used interface from an explicitly selected structural template. The latter retains every stated requirement. A Consumer that happens to read only `x` does not delete `y` from an explicitly supplied `Richer` model.

No check above materializes a missing `y` or fills it from a default in the model.
Constructing a richer candidate is a separate explicit composition operation.

**Basis:** [B] §8.2; operand directive §2.3
(checking does not insert missing fields).

### T04 — A consumer can use a small interface without inventing a larger model

```lmx
Point:
    int: x 12

LargerPoint:
    int: unused 99
    int: x 27

XReader:
    @: object
    return: int
    read:
        return: object\x

UseProbe:
    return: int
    run:
        return: XReader\read(object := Point) * 100 + XReader\read(object := LargerPoint)
```

Run `UseProbe\run()`. Expect **1227**. `XReader` consumes the field it actually
uses. No full `Richer` requirement from T03 has been supplied here, so the
program does not demand an unrelated `y`. The extra candidate field has no
effect on the read.

Negative fixture: supply a Structure with no `x`, reach the read, and require
ordinary refusal of the unsatisfied used access. Do not assign a default zero or
reinterpret an arbitrary physical slot as `x`. Keep admission timing and whether
a statically known failure is diagnosed before that execution in the separate
phase-specific tests.

**Basis:** [S] §§6–7 (structural genericity and used accesses), scoped
by [B] §8.2's rule for an explicitly supplied ordinary model. This example has no
larger explicit model whose requirements could be removed.

### T05 — Zero, an omitted input and an explicit nil are distinguishable

```lmx
Presence:
    int: value
    return: int
    is_set:
        return: value != nil
    require_value:
        required: value
        return: value

PresenceProbe:
    return: int
    missing:
        return: Presence\is_set()
    zero:
        return: Presence\is_set(value := 0)
    autofilled:
        int: value 7
        return: Presence\is_set()
    explicit_nil:
        int: value 7
        return: Presence\is_set(value := nil)
```

Run `missing` from a context with no other available `value` source. Expected
results are respectively **0, 1, 1, 0**. Explicitly supplied zero is initialized;
explicit nil is supplied and must not be replaced through omitted-input autofill.

`Presence\require_value(value := 0)` returns **0**. Calling `require_value()`
without any value source reaches `required: value` and refuses. The receiver is
inside reached code, rather than a `required` modifier at signature selection.
An uninitialized integer must not become an initialized zero merely because a
machine representation happens to contain zero bits.

**Basis:** [B] §6.1; [S] §9; [S] §12; [L2] §2 (typed nil and comparison). No arithmetic on nil is asserted here.

### T06 — Representation compatibility is not actual-value range validation

**Kind:** explicit-converter fixture. Supply ordinary `u16` and `u8` descriptions
and the explicitly reachable converter prescribed by the chosen Message's
conversion context. Invoke that converter directly; do not guess a new source
spelling for its registration or rely on automatic `test` scheduling.

| Value received through the selected conversion | Expected |
|---|---|
| `u16(0)` to `u8` | `0` |
| `u16(255)` to `u8` | `255` |
| `u16(256)` to `u8` | Range refusal, never wrapping to `0` |

Instrument the converter. Pure interface checking invokes it **zero** times.
The explicit conversion invokes it once for the selected value. A positive
structural comparison cannot be used to skip the concrete `256` check. Where
the conversion is absent from the supplied context, report the missing route;
do not search a hidden process-wide chain.

For `1.5` to an integer, require an explicitly selected rounding policy before
assigning an expected numeric result. This corpus does not silently borrow a
numeric policy from ML, Ada, C or Python.

**Basis:** [S] §5; [S] §6; [S] §8 case 11.
The test concerns an explicit converter's behavior; it does not settle whether
the runtime automatically executes admission checks in other contexts.

### T07 — Stable symbolic type bindings belong to the supplied Message context

**Kind:** context fixture. Construct Message A with one symbolic type description
`Element` bound to an integer contract. Construct Message B with its own supplied
`Element` bound to a character-array contract. Use the same Consumer graph in
both, selecting matching operations/conversions explicitly through each context.

Within A, two occurrences of `Element` must denote the same chosen type
relationship; a later call must not instantiate the name afresh merely to admit
a conflicting actual. B may legitimately use its different binding. A message
created or sent without A's explicit context does not acquire it simply through
parenthood or delivery.

Check semantic type requirements, not just C sizes or identical raw `@` tags.
Conversely, add no nominal class-name equality where the given structural
requirements suffice. The Message fixture controls the context; the test does
not propose a global registry or new generic syntax.

**Basis:** [S] §6; [B] §8.3.


<a id="operands"></a>
## OP. Operands, expression evaluation, and argument boundaries

These cases follow OPERAND revision 6. In their source citations, P23 means the Interpreter section of source P3. Mandatory header fields are checked in the actual DATA; no registration receiver is used.

### OP01 — An ordinary method acquires operand use from its actual DATA

```lmx
numeric_ops:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    subtract:
        return: \left - \right[0]

arithmetic:
    return: int
    precedence:
        import: numeric_ops
        return: 30 subtract 4 * 3
    association:
        import: numeric_ops
        return: 30 subtract 4 subtract 3
```

Expected:

| Entry | Result | Distinguishing requirement |
|---|---:|---|
| `arithmetic\precedence()` | 18 | Multiplication supplies `12` to `subtract`; a fabricated right-tail group must not swallow unrelated operations. |
| `arithmetic\association()` | 23 | Equal addition-level operations associate left to right. |

There is no registration call. `subtract`'s DATA is `numeric_ops`, including when
its name is imported into `arithmetic`.

Source: [O] §§2.1–2.5, 3.1, 6.1; P23.

### OP02 — Left is separate; the right array preserves its occurrences

```lmx
several_ops:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    weighted:
        return: \left * 1000 + \right[0] * 100 + \right[1] * 10 + \right[2]

several:
    return: int
    demo:
        import: several_ops
        return: (2 weighted 3 5 7)
```

`several\demo()` returns **2357**. The actual operand invocation has two input
places: `left` addresses `2`, and `right` is an array of three references addressing
`3`, `5`, `7`, in that order. It is not four positional method inputs, and `2` is
not duplicated in `right`.

For a separate inspection fixture whose method returns `length(right)` and does
not require/read `left`, test the following applications:

| Application | Number of right occurrences |
|---|---:|
| `(count_right 2 3 5 7)` | 4 |
| `(2 count_right 3 5 7)` | 3 |
| `(count_right A)`, with one Array `A` of length 17 | 1 |
| `(A count_right B C)`, all three being containers | 2 |

The prefix cases use the ordinary contract that permits the omitted left actual;
they must not shift the first right occurrence into `left`. For the container
cases, provide genuine Array/Structure fixtures through the harness rather than
changing `Array<T>` into `Array<@>` by reinterpreting its backing.

Source: [O] §§2.3–2.4, 3.1–3.3.

### OP03 — Reading a prepared value twice versus evaluating source twice

Shared fixture for the next two independent modes:

```lmx
meter:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: node\calls

prepared_ops:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: int
    twice:
        return: \left + \left

raw_ops:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    return: int
    twice:
        int: first sys\eval(left)
        int: second sys\eval(left)
        return: first + second

evaluation:
    return: int
    prepared:
        import: prepared_ops
        return: (meter\next() twice 0)
    raw:
        import: raw_ops
        return: (meter\next() twice 0)
```

| Sequence, beginning with `meter\calls = 0` | Returned values | Final calls |
|---|---|---:|
| `evaluation\prepared()` twice | `2`, then `4` | 2 |
| `evaluation\raw()` twice, in a fresh fixture | `3`, then `7` | 4 |

Prepared mode obtains one value per reached evaluation and reads that value twice.
Raw mode explicitly starts two evaluations of the same source occurrence. Neither
mode installs a persistent result cache into the source graph.

Source: [O] §§3.1, 3.6–3.7, 5.3.

### OP04 — A raw operand chooses which source occurrence to execute

```lmx
meter:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: node\calls

selection_ops:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    return: int
    select_value:
        if: sys\eval(left)
            return: sys\eval(right[0])
        return: sys\eval(right[1])

selection:
    return: int
    first:
        import: selection_ops
        return: (1 select_value 19 meter\next())
    second:
        import: selection_ops
        return: (0 select_value meter\next() 23)
```

`selection\first()` returns **19**; `selection\second()` returns **23**.
Both leave `meter\calls = 0`. The unused right occurrence remains unexecuted,
including when a walker later visits its physical record.

Source: [O] §§3.6–3.7, 5.4.

### OP05 — Forwarding a raw occurrence preserves its original context

```lmx
helpers:
    @: fragment
    int: n 900
    return: int
    evaluate:
        return: sys\eval(fragment)

origin_ops:
    @: left
    []: @ right
    const: int: PASS_ARGS_AS_IS 1
    const: int: PRIORITY sys\priority("+")
    int: n 700
    return: int
    original:
        return: helpers\evaluate(fragment := right[0])

origin:
    int: n
    return: int
    read:
        import: origin_ops
        return: (0 original n)
```

`origin\read(6)` returns **6** and `origin\read(11)` returns **11**. Neither
the operator's `n = 700` nor the helper's `n = 900` captures the source name.
The source context must identify the particular live invocation, not just its
graph address.

Additional harness case: keep the raw reference after `origin\read` has returned.
Do not accept an implementation that silently resurrects the completed activation
or substitutes another invocation with the same code address. The directive gives
no lifetime extension; use the existing invalid-lifetime behavior rather than
inventing a new exception name in this corpus.

Source: [O] §3.7, §10.7 R05–R08/R13.

### OP06 — An operand returning a reference still returns a reference

```lmx
reference_ops:
    @: left int
    []: @(int) right
    const: int: PASS_ARGS_AS_IS 0
    const: int: PRIORITY sys\priority("+")
    return: @
    keep_left:
        return: left

references:
    return: int
    demo:
        import: reference_ops
        @: selected (17 keep_left 99)
        return: \selected
```

`references\demo()` returns **17**. Before the explicit dereference, `selected`
is a reference to the prepared left value. The operand application must not
automatically turn a `return: @` into an arbitrary logical value, nor add a second
reference layer absent from an ordinary call of the same method.

The harness should also invoke `keep_left` directly with equivalent prepared
`left` and `right` reference fixtures. The returned logical type and addressed
value must match the operator application. Do not rewrite it as `keep_left(17; 99)`:
the actual second input is an array of references.

Source: [O] §§3.1, 3.3–3.4.

### OP07 — Ordinary callable references do not execute their targets

```lmx
actions:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: node\calls
    demo:
        @: selected next
        int: before node\calls
        int: result selected()
        return: before * 100 + result
```

With a fresh graph, `actions\demo()` returns **1** and `actions\calls` becomes
**1**. Capturing the reference performs no first call. An ordinary dereference
of a callable reference likewise does not execute its body.

Separate address-expression probe, with a graph Structure `S` supplied:

```lmx
(@S + 1) - @S
```

Expected numeric result: **1**, under the explicit numeric-address rule of this
directive. `@: p S` instead creates an ordinary reference. This probe does not
dereference the fabricated address `@S + 1`.

Source: [O] §§2.1, 3.3. The explicit numeric-address decision
overrides older contradictory text; it is not a request for implicit pointer
arithmetic on ordinary L3 references.

### OP08 — Embedded assignment changes the receiving activation's place

```lmx
sink:
    int: x
    int: scratch 100
    return: int
    inspect:
        return: x * 100 + scratch

expressions:
    int: scratch 77
    return: int
    ungrouped:
        int: result sink\inspect(2 + scratch := 3 * 4)
        return: result * 100 + scratch
    grouped:
        int: result sink\inspect(2 + (scratch := 3) * 4)
        return: result * 100 + scratch
```

| Entry | `sink.inspect` receives | Its `scratch` | Caller `scratch` | Result |
|---|---:|---:|---:|---:|
| `expressions\ungrouped()` | one actual, `x = 14` | 12 | 77 | 141277 |
| `expressions\grouped()` | one actual, `x = 14` | 3 | 77 | 140377 |

The same final value of the positional argument does not imply the same effects.
The embedded assignment neither adds a named actual nor writes the caller's
separate same-named place. Its receiver demands the result of this particular
assignment even though `scratch` previously had the ready value `100`.

Source: [O] §§4.1–4.5, 5.1–5.2; [B] §10.1.

### OP09 — A standalone named actual still obeys the positional cursor

Reusing the `sink` declaration from OP08:

| Call | Expected |
|---|---|
| `sink\inspect(x := 14; 12)` | Accepted; `x` is named at its current first position, then `scratch` receives `12`; result 1412. |
| `sink\inspect(scratch := 12; x := 14)` | Accepted; two named actuals; result 1412. |
| `sink\inspect(scratch := 12; 14)` | Rejected: a positional actual follows an out-of-position named actual. |
| `sink\inspect(2 + scratch := 3 * 4)` | Accepted; one positional actual, not the preceding rejected two-actual form. |

Put a visible producer call into the second actual of the rejected form. A shape
error available before effects must reject it before executing that producer.
For the two accepted named actuals, instrument their RHS and verify written-order
evaluation; mapping destinations must not reorder their effects.

Source: [O] §§2.5, 4.1–4.4; [B] §§9.4, 10.1.

### OP10 — Demand evaluation performs the producing operation once

```lmx
source:
    int: reads 0
    return: int
    next:
        node\reads += 1
        return: node\reads

sink:
    int: x
    int: scratch 100
    return: int
    inspect:
        return: x * 100 + scratch

demand:
    return: int
    demo:
        return: sink\inspect(10 * scratch := source\next() + 3)
```

From a fresh graph, two successive `demand\demo()` calls return **4004** and
**5005**; `source\reads` becomes **2**. Each call calculates its whole assignment
RHS, records `4` or `5`, and supplies `40` or `50` as its one positional actual.
Neither late walker traversal nor native lowering repeats the source call.

Source: [O] §§4.5, 5.1–5.3, 6.3–6.4.

### OP11 — Short circuit skips a whole effectful application

```lmx
effects:
    int: calls 0
    return: int
    tick:
        node\calls += 1
        return: 1
    demo:
        int: a 0 && tick()
        int: b 1 || tick()
        return: a * 10 + b
```

`effects\demo()` returns **1**, leaving `effects\calls = 0`.

Add two source-level expression cases with an existing local `x = 8`:

| Expression | Result | Final x |
|---|---:|---:|
| `0 && (x := 41)` | 0 | 8 |
| `1 \|\| (x := 41)` | 1 | 8 |

Also place the entire OP01 operand application with an effectful argument inside
the skipped right side. Neither the operand method nor its argument producer may
run. Parentheses alone are not an eager-evaluation instruction.

Source: [O] §5.4, §10.3 D06–D08/D13.

### OP12 — A while condition repeats evaluation, not a cached first result

```lmx
stream:
    int: reads 0
    return: int
    next:
        node\reads += 1
        if: node\reads <= 3
            return: node\reads * 5
        return: -1

scanning:
    return: int
    demo:
        int: c 0
        int: total 0
        while: (c := stream\next()) != -1
            total += c
        return: total * 100 + stream\reads * 10 + (c = -1)
```

With a fresh stream, `scanning\demo()` returns **3041**:
three body executions add `5 + 10 + 15 = 30`; four condition evaluations call
`next`; the final `c` is `-1`. Each condition evaluation performs one assignment
and one read. `c` is the surrounding callable's activation-local place; the loop
does not publish it into the callable's parent graph.

Source: [O] §5.5.

### OP13 — Adjacent precedence levels must be distinguished

Evaluate these in a profile that supports the written operations. Assertions are
external harness expectations, not a proposed new LMX assertion syntax.

| Expression | Expected | Boundary tested |
|---|---:|---|
| `3 + 4 * 5` | 23 | Multiplication before addition |
| `(3 + 4) * 5` | 35 | Written group |
| `7 - 2 - 1` | 4 | Left-associative subtraction |
| `48 / 4 / 3` | 4 | Left-associative division |
| `3 << 1 + 1` | 12 | Addition before shift |
| `1 < 2 << 2` | 1 | Shift before relation |
| `1 = 3 > 2` | 1 | Relation before equality |
| `2 & 1 = 0` | 0 | Equality before bitwise AND |
| `6 ^ 3 & 1` | 7 | Bitwise AND before XOR |
| `1 \| 3 ^ 1` | 3 | XOR before bitwise OR |
| `2 \| 0 && 0` | 0 | Bitwise OR before logical AND |
| `1 \|\| 0 && 0` | 1 | Logical AND before logical OR |
| `-3 ** 2` | -9 | Power before its left unary minus |
| `(-3) ** 2` | 9 | Written negative-base group |
| `3 ** 2 ** 3` | 6561 | Right-associative power |
| `2 * 3 ** 3` | 54 | Power before multiplication |
| `3 ** -2` | Group as `3 ** (-2)` | Right unary operand; numeric result is not specified by this precedence rule |

With known writable `a`, `b`, `c`, test `a := b := 7`: both places become 7.
Test `c := (a := 4) + (b := 6) * 3`: the final values are `a = 4`, `b = 6`,
`c = 22`. The integer examples avoid overflow and division-domain differences.

Source: [O] §§6.1–6.3; [G] §21.

### OP14 — sys\name consumes spelling, not the value of the identifier

| Expression / setup | Expected string contents | Required absence of effects |
|---|---|---|
| `sys\name(not_declared_here)` with no declaration | `not_declared_here` | No lookup failure |
| `sys\name(sample)` with `sample = 52` | `sample` | No integer-to-string conversion |
| Exact identifier `sample` (see source below) | `sample` | Same contents as the bare identifier |
| Exact identifier with a space (see source below) | `two words` | No case/whitespace normalization |
| Exact identifier containing a backtick (see source below) | `a` followed by one backtick and `b` | Exact-identifier unescaping only |
| Empty exact identifier (see source below) | empty string | Length 0 |
| `sys\name(selected)` where selected points to `actions\next` | `selected` | No invocation and no lookup of the target's name |

The actual LMX spellings for the exact-identifier cases are:

```lmx
sys\name(sample)
sys\name(`sample`)
sys\name(`two words`)
sys\name(`a``b`)
sys\name(``)
```

Each result is one ordinary `Array<char>`, with its exact length and no additional
NUL element. Passing the result as an actual passes one array, not one actual per
character. Do not assert address identity between independently obtained strings;
this directive promises their contents, not a new identity guarantee.

Negative cases: `sys\name(52)` and `sys\name("sample")` do not supply the single
written identifier required by this receiver. `sys\name` is not a general
stringification operation.

Source: [O] §§7.1–7.4.

### OP15 — sys\priority consults the same operand description without invoking it

With OP01's `numeric_ops` imported:

```lmx
sys\priority("subtract") = sys\priority("+")
```

Expected **1**. Repeat the right query as
``sys\priority(sys\name(`+`))``; the result must be the addition priority, not a
unary-plus priority guessed from query context.

Create a separate `Array<char>` with the content `subtract` and use it as the
query argument: the result must be identical even though its address differs
from the canonical identifier string. The query must not execute `subtract` or
need usable `left/right` values. Instrument a variant method body to record any
invocation; the count must remain zero.

Negative cases:

| Query target | Expected |
|---|---|
| Undeclared `no_such_operand` | Ordinary resolution failure; no default priority |
| An ordinary callable missing the operand header | No invented operand priority |
| Visible unresolved alternatives with different priorities/modes | Ambiguity before argument effects |

Source: [O] §§8.1–8.4.

### OP16 — Structural discovery and fn compatibility are distinct checks

Start with a working copy of OP01. Apply one mutation per independent fixture:

| Mutation | Expected behavior |
|---|---|
| Remove `PASS_ARGS_AS_IS` | Reject operand contract; do not insert 0 |
| Remove `PRIORITY` | Reject operand contract; do not assign a hidden level |
| Set mode to 2 | Reject invalid mode |
| Make either mandatory property unavailable as a ready constant | Reject that application before executing user arguments |
| Rename `left/right` to `lhs/rhs` only | No structural operand role, even if a separate positional fn requirement accepts the method |
| Keep the header but remove its result contract, then consume application as a numeric value | Header alone does not make the procedure supply an expression result |
| Add an irrelevant extra field | Extra presence alone must not reject the minimal structural template |
| Put a default for a missing candidate field only in the requirement template | Checking does not add the field to the candidate |
| Explicitly compose a missing field into the actual DATA using `merge` before checking | Check the resulting real DATA; composition and conformance remain separate operations |
| Present only an `fn` signature as the implementation | Signature gains no executable body |

Separate positive fn test:

```lmx
fn: OperandPair (@: first; []: @ rest; return: int)
```

A candidate whose input types are `@`, then `Array<@>`, whose real names are
`lhs/rhs`, and whose result is `int`, may satisfy this positional requirement.
Through an accepted fn reference, `rest := makeRest(); first := makeFirst()` maps
to positions 2 and 1 but retains that written RHS effect order. The same candidate
does not become an operand until its actual DATA also satisfies the separate
name-sensitive operand header. Its DATA remains its actual parent.

Source: [O] §§2.2–2.5, 9.3, 10.1, 10.8.

### OP17 — The clean graph remains the written graph

Use OP08 and OP10 as semantic probes, with a harness snapshot of their parsed
source before execution. Compare after each of two executions:

1. Existing written container boundaries, direct field counts, order and parent
   relationships are unchanged.
2. OP08's ungrouped assignment does not acquire an invented parenthesized
   container; its explicitly grouped sibling retains the written container.
3. A reached assignment's saved working result is not appended as a permanent
   field to the clean graph.
4. Subsequent execution repeats demanded effects; an earlier result does not
   replace an executable source occurrence.
5. A skipped operand occurrence remains skipped in its current execution.

Compare logical structure, not incidental allocator addresses or caches outside
the source representation. The program's explicit graph writes remain observable
and are not grounds for rejecting a correct implementation; choose snapshots of
the code occurrences, not of the deliberately mutated meter state.

Source: [O] §§1, 4.2, 5.3–5.4, 6.3–6.4, 9.1; [G] §§12–14.

### OP18 — Native/interpreted equivalence includes types and effects

Run OP01, OP03–OP06, OP08 and OP10 through the interpreter and every applicable
prepared native path. Compare returned logical type/value, actual count,
assignment target and producer-call count. Do not add runtime admission checks
to native paths whose contract already performed them at construction.

For the nested numeric operation, inspect the reference presented to the next
operand. It must address a real value with the ordinary four-byte type tag
immediately preceding that value; it must not be a naked C temporary represented
as a typed graph cell by assumption. An existing suitable record may be reused:
the test must not demand allocation or copying of every intermediate result.

For OP06's reference result, compare the same logical reference behavior in both
dispatch paths. Interpreter-internal result records must not change the public
number of dereferences.

Source: [O] §§3.3–3.4, 3.7, 6.4, 10; [B] §11.


<a id="validation"></a>
## V. Validation, mocks, catch, and integration self-testing

The four complete checker programs have explicit result oracles. V05 checks the current separated construction, build-test and reached-admission phases summarized in Q01.

### V01. Full-string validation: the earlier RegEx question

The requirement is exactly two uppercase ASCII letters, a hyphen and two decimal digits. The entire string is consumed. This is an ordinary value checker; no RegEx subsystem or altered meaning of `implements` is introduced.

```lmx
TicketCode:
    []: char candidate
    return: int
    accepts:
        if: length(candidate) != 5
            return: 0
        if: candidate[0] < 'A' || candidate[0] > 'Z'
            return: 0
        if: candidate[1] < 'A' || candidate[1] > 'Z'
            return: 0
        if: candidate[2] != '-'
            return: 0
        int: position 3
        while: position < 5
            if: candidate[position] < '0' || candidate[position] > '9'
                return: 0
            position += 1
        return: 1
```

| Direct invocation | Expected result | What it distinguishes |
|---|---:|---|
| `TicketCode\accepts("AB-09")` | 1 | Accepted shape and values |
| `TicketCode\accepts("QZ-70")` | 1 | Second positive input |
| `TicketCode\accepts("")` | 0 | Length checked before indexing |
| `TicketCode\accepts("AB-9")` | 0 | Missing digit |
| `TicketCode\accepts("AB-090")` | 0 | Trailing character is not ignored |
| `TicketCode\accepts("ab-09")` | 0 | Letter range is explicit |
| `TicketCode\accepts("AB-0X")` | 0 | Final digit is actually checked |
| `TicketCode\accepts("XAB-09Y")` | 0 | No implicit substring search |
| `TicketCode\accepts("AB\00009")` | 0 | Length-bearing string; embedded NUL is data and fails the separator check |

Fixtures use the ASCII target text profile. The structural interface of these strings is the same; their contents produce different checker verdicts. `implements` establishing a suitable character-array input does not by itself establish the required character values. This checker is checked through direct ordinary calls in this suite; its association with automatic `test` scheduling is a separate case below.

**Basis:** [B] §8.2 example uses `[]: char`; [G] §6 gives character constants and string rules; [S] §§7–8 distinguishes interface checks and concrete value tests; [S] §17 gives `length` and indexing.

### V02. A mock is an ordinary dependency of the actual candidate

The real candidate computes a reading multiplied by a supplied gain. The checker substitutes only the source of readings and verifies both the result and the number of reads.

```lmx
Measurement:
    int: gain
    @: read
    return: int
    sample:
        return: read() * gain
    biased:
        return: read() * gain + 1
    reads_twice:
        int: discarded read()
        return: read() * gain

SamplingCheck:
    @: candidate
    int: calls 0
    return: int
    fixed_read:
        node\calls += 1
        return: 7
    check:
        node\calls := 0
        @: read fixed_read
        int: result candidate(gain := 4)
        return: result = 28 && node\calls = 1
```

| Direct invocation | Verdict | `SamplingCheck\calls` afterward |
|---|---:|---:|
| `SamplingCheck\check(candidate := Measurement\sample)` | 1 | 1 |
| `SamplingCheck\check(candidate := Measurement\biased)` | 0 | 1 |
| `SamplingCheck\check(candidate := Measurement\reads_twice)` | 0 | 2 |
| Repeat the first call | 1 | 1 |

The actual candidate is invoked. Its uninitialized declared `read` receives the checker's ordinary local reference through autofill. Its own `gain` receives the explicit actual 4. The mock's count is explicit stored state accessed through `node\calls`; the test does not depend on an accidental transitive writable alias.

The third candidate deliberately returns the correct number while doing the wrong amount of work. Checking the return value alone would miss it. The checker does not replace the candidate with a mock candidate; it replaces a dependency of that candidate.

**Basis:** [B] §§6.1, 6.4, 6.5; P1 Strategy and Observer; [S] §7. These are direct ordinary calls, so their verdicts follow their written invocations.

### V03. Expected recoverable failure is an explicit checker branch

```lmx
UnavailableSensor:
    return: int
    read:
        throws: NoSample
        throw: NoSample()
    zero:
        return: 0

FailureCheck:
    @: candidate
    return: int
    check:
        candidate()
        return: 0
        catch: NoSample ()
            return: 1
```

`FailureCheck\check(candidate := UnavailableSensor\read)` returns **1**. Replacing the candidate by `UnavailableSensor\zero` returns **0**: a normal return is not the expected failure. A different declared failure is not silently treated as success; test it through the normal failure/exit contract.

The handler is adjacent to the code it checks. There is no wrapping `try` construct, and a diagnostic assertion is not used for ordinary candidate rejection.

**Basis:** [S] §7 and §15; P1 Iterator and Visitor show the same handler style under current callable notation.

### V04. Integration self-test: command, feedback, reset, feedback

This checker can be passed either a deterministic test device or the actual connected device implementation. It exercises the supplied device through its real methods. The deterministic device below makes the test itself reproducible; it is not a claim that real hardware was exercised here.

The requested scenario is: turn the indicator on, observe it on, turn it off, observe it off. Commands acknowledge receipt separately from the observed state. The test performs the final off command even when the first observed state is wrong, since this is explicitly part of this scenario.

```lmx
Indicator:
    int: command
    int: fault 0
    int: commanded 0
    int: sensed 0
    int: writes 0
    int: reads 0
    int: trace 0
    return: int
    set:
        node\commanded := command
        node\writes += 1
        node\trace := node\trace * 10 + command
        if: node\fault = 0
            node\sensed := command
        if: node\fault = 1
            node\sensed := 0
        if: node\fault = 2
            node\sensed := 1
        return: 1
    observe:
        node\reads += 1
        node\trace := node\trace * 10 + 2
        return: node\sensed

Commissioning:
    @: candidate
    return: int
    check:
        int: on_ack candidate\set(command := 1)
        int: on_seen candidate\observe()
        int: off_ack candidate\set(command := 0)
        int: off_seen candidate\observe()
        return: on_ack = 1 && on_seen = 1 && off_ack = 1 && off_seen = 0
```

For each row, create a fresh candidate with `@: device (merge(Indicator; (int: fault F)))`, where F is the row's fault value, and call `Commissioning\check(candidate := device)` with that reference.

| Fault | Meaning in this fixture | Verdict | Final `commanded` | Final `sensed` | Writes / reads | Trace |
|---:|---|---:|---:|---:|---|---:|
| 0 | Feedback follows the command | 1 | 0 | 0 | 2 / 2 | 1202 |
| 1 | Feedback remains off | 0 | 0 | 0 | 2 / 2 | 1202 |
| 2 | Feedback remains on | 0 | 0 | 1 | 2 / 2 | 1202 |

Trace digits mean command-on, observation, command-off, observation. Both faulty candidates acknowledge both commands with 1. The checker still rejects them because it validates feedback. This catches a misleading implementation that validates command acceptance alone.

The check's visible side effects are intentional. There is no implicit rollback, hidden device clone, or mandatory mock layer. After success the explicitly requested final state is off. An alternative scenario that must preserve an earlier state must explicitly read and restore that state; it is a different test.

For a connected implementation, bind `candidate` to the real supplied object with compatible `set` and `observe` operations. The same test then checks those real operations and their returned observations. Whether the observation comes from a physical sensor or merely a software command register is part of that implementation's stated contract; the language cannot turn an ACK into physical feedback.

**Basis:** P1 Observer, P2 State/Bridge, P3 Mediator; [S] §7 actual-candidate checking and §8 foreign-resource validity. The exact four-action scenario and numeric fault model are test data proposed here, not new language rules.

### V05. `test` association and the current execution phases

The ordinary receiver `test: op checkIncrement` associates the receiving place with an ordinary checker. The checker receives the actual candidate and returns `int` 1/0. The current [SEM] §7 and `explicit-compilation` contract separate interface construction, the pre-C build-test stage, and reached runtime admission. Q01 below records those phases; the old list of contradictory source-snapshot quotations is no longer the governing contract.

Use one fresh visible counter per independent fixture. Instrument the existing build/admission harness rather than inventing a new language API:

| Fixture | Required observation |
|---|---|
| Construct a graph containing a candidate/checker association, with no executing code | Checker count `0`; no candidate body or computed default is run by interface matching |
| In the explicit build-test stage, reach one ordinary successful checker invocation | Count `1`; its effects are real and failure would prevent accepting that build |
| Put a `test` record in an unconsumed nested DATA branch | Its mere presence causes no checker call and no recursive test-discovery pass |
| Explicitly invoke the same direct checker twice | Count `2`, with ordinary execution and no invented permanent behavioral-result cache |
| Enter a prepared native path with no written explicit `implements` | No added automatic runtime `implements` layer |
| Execute a reached interpreted call | Uses the standard `implements` mechanism; unexecuted branches are not pre-walked |
| Receiving admission has checkers returning `1`, then `0`, then `1` | Only the first two run; the receiving admission fails |
| Candidate advertises a different permissive checker | It does not replace the receiver's required checks |

An empty set of checks supplies no behavioral evidence. Running a checker completes the admission already in progress; recursively encountering that same unfinished admission is not a pass. Expected recoverable failures use ordinary `catch`; arbitrary exceptions and diagnostic failures are not successes. The checker's own calls use ordinary native/walker dispatch, so a build-test entry through the interpreter does not force every candidate/dependency call through the walker.

Report build-test calls, reached runtime admission events and explicit checker invocations separately. Their counts come from the exercised fixture's specified events; the phrase “two uses” alone does not identify two new admission events. Effects such as V04's device commands are not automatically cloned or rolled back.


<a id="patterns"></a>
## P. Twenty-three complete design-pattern scenarios

Each program is independent and gives a new scenario, entry, and exact expected observations. The source references P1/P2/P3 designate the attached pattern guides.

### P01 — Iterator: zero is an element

```lmx
EvenSamples:
    int: position 0
    int: requests 0
    return: int
    next:
        throws: Stop
        node\requests += 1
        if: node\position >= 3
            throw: Stop()
        node\position += 1
        return: node\position - 1
    demo:
        node\position := 0
        node\requests := 0
        int: total 0
        LoopTools\iterate: int: item EvenSamples\next()
            item *= 2
            total += item
        return: total

LoopTools:
    @: iteration
    @: body
    iterate:
        while: 1
            iteration()
            catch: Stop ()
                break
            body()
```

**Entry:** `EvenSamples\demo()` → **6**, on repeated runs as well. Three body executions receive 0, 1, 2 before doubling; final stored `position=3`, `requests=4`, including the exhaustion call. Passing the declaration must not eagerly execute `next`. **Basis:** [P1] §1; declaration-argument directive §3.

### P02 — Strategy: explicit selection versus a ready default

```lmx
Pricing:
    int: amount
    @: operation twice
    return: int
    twice:
        return: amount * 2
    thrice:
        return: amount * 3
    apply:
        return: operation()
    demo:
        @: operation thrice
        int: ordinary apply(4)
        int: explicit apply(4; operation)
        int: ordinary_again apply(4)
        return: ordinary * 100 + explicit * 10 + ordinary_again
```

**Entry:** `Pricing\demo()` → **928**, encoding results **8, 12, 8**. The caller's local `operation=thrice` affects the explicit actual; it does not implicitly replace `apply`'s ready `twice` default. **Basis:** [P1] §2; binding directive §6.1.

### P03 — Factory Method: retained products outlive prototype changes

```lmx
Packet:
    int: payload
    return: int
    read:
        return: payload
    create:
        return: Packet
        small:
            node\payload := 6
            return: (copy(Packet))
        large:
            node\payload := 14
            return: (copy(Packet))

PacketClient:
    @: product Packet
    return: int
    consume:
        return: product\read() + 1
    demo:
        import: Packet
        @: first create\small()
        @: second create\large()
        Packet\payload := 99
        return: consume(first) + consume(second)
```

**Entry:** `PacketClient\demo()` → **22**. The retained products read **6** and **14**, despite the prototype's final payload **99**; another demo call repeats the same result. **Basis:** [P1] §3; explicit store before copy, ordinary const-declaration import.

### P04 — Adapter: equal types do not erase positional meaning

```lmx
OldDifference:
    int: subtrahend
    int: minuend
    return: int
    calculate:
        return: minuend - subtrahend

Difference:
    int: minuend
    int: subtrahend
    return: int
    calculate:
        return: OldDifference\calculate(subtrahend; minuend)
    demo:
        int: adapted calculate(13; 5)
        int: direct OldDifference\calculate(13; 5)
        return: adapted * 10 + direct
```

**Entry:** `Difference\demo()` → **72**, from adapted **8** and direct **−8**. The adapter delegates with reversed actual positions; it must not be optimized into forwarding the original positional list unchanged. **Basis:** [P1] §4.

### P05 — Observer: duplicate subscriptions remain two calls

```lmx
Events:
    int: value
    int: last 0
    int: total 0
    @: first remember
    @: second accumulate
    int: deliveries 0
    return: int
    remember:
        node\deliveries += 1
        node\last := value
    accumulate:
        node\deliveries += 1
        node\total += value
    notify:
        first()
        second()
    demo:
        node\last := 0
        node\total := 0
        node\deliveries := 0
        node\first := remember
        node\second := accumulate
        notify(-2)
        notify(5)
        int: subtotal node\total
        node\second := remember
        notify(7)
        return: subtotal * 100 + node\last * 10 + node\total
```

**Entry:** `Events\demo()` → **373**. After the first two events, `(last,total,deliveries)=(5,3,4)`; after notifying two stored `remember` references, the final state is **(7,3,6)**. There is no implicit deduplication of equal callable references. **Basis:** [P1] §5.

### P06 — Decorator: copied inputs along a wrapper chain

```lmx
Filters:
    int: sample
    return: int
    base:
        return: sample * 2
    plus_one:
        return: base() + 1
    finish:
        return: plus_one() * 3
    demo:
        int: first finish(4)
        return: first + finish(4)
```

**Entry:** `Filters\demo()` → **54**; `Filters\finish(4)` → **27**. Each chain yields **8 → 9 → 27**, using immediate-caller autofill, with no publication of activation-local `sample` into the graph. **Basis:** [P1] §6.

### P07 — Command: a writable caller place through an intermediary

```lmx
Edits:
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
        int: value 5
        invoke()
        invoke(command := twice)
        return: value
```

**Entry:** `Edits\demo()` → **14**, again on repeat. One original caller-local place changes **5 → 7 → 14**; `required: value` establishes the intermediary's connection before it calls the action. **Basis:** [P1] §7; binding directive §§6.2–6.4.

### P08 — Template Method: replace one step, preserve the sequence

```lmx
Transform:
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
        int: first execute(2)
        finish := square
        return: first + execute(2)
```

**Entry:** `Transform\demo()` → **15**. The two calls prepare **3**, then return **6** and **9**; the second call begins with explicit **2**, not the first call's modified local value. **Basis:** [P1] §8.

### P09 — Visitor: caller action and lexical fallback

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
        int: value 6
        return: int
        accept:
            throws: NoAction
            return: on_number()
    ---
    Pair:
        int: left 2
        int: right 7
        return: int
        accept:
            throws: NoAction
            return: on_pair()

Summing:
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

**Entry:** `Summing\demo()` → **15**, from 6 + 9. In a separate negative fixture remove only `Summing\on_number`; the same entry then returns **−1** through the lexical `NoAction` fallback, without substituting `on_pair`. **Basis:** [P1] §9.

### P10 — State: the state is a caller-local callable reference

```lmx
Gate:
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
        result += state()
        return: result
```

**Entry:** `Gate\demo()` → **2**. Four separate calls yield **0,1,0,1**, and the local reference ends at `closed`; another demo has a fresh local state and repeats the sequence. **Basis:** [P2] §10.

### P11 — Chain of Responsibility: prove the skipped call

```lmx
Router:
    int: value
    @: first negative
    @: second even
    int: trace 0
    return: int
    negative:
        node\trace := node\trace * 10 + 1
        if: value < 0
            return: 1
        return: 0
    even:
        node\trace := node\trace * 10 + 2
        if: value % 2 = 0
            return: 2
        return: 0
    dispatch:
        int: result first()
        if: result
            return: result
        return: second()
    demo:
        node\trace := 0
        int: a dispatch(-6)
        int: b dispatch(-6; even; negative)
        int: c dispatch(7)
        return: a * 100 + b * 10 + c
```

**Entry:** `Router\demo()` → **120**, encoding **1,2,0**; final stored trace is **1212**. The first two requests enter only their first selected handler, while the final request enters both. **Basis:** [P2] §11.

### P12 — Composite: changing the original leaf does not change the tree

```lmx
Weight:
    int: value
    return: int
    total:
        return: value

Bundle:
    @: left
    @: right
    return: int
    total:
        return: left\total() + right\total()
    demo:
        @: a (merge(Weight; (int: value 1)))
        @: b (merge(Weight; (int: value 4)))
        @: c (merge(Weight; (int: value 6)))
        c := parent(c\total)
        @: inner (merge(Bundle; (@: left b; @: right c)))
        @: tree (merge(Bundle; (@: left a; @: right inner)))
        c\value := 100
        return: tree\total()
```

**Entry:** `Bundle\demo()` → **11**, while the separately retained local `c` reads **100**. Before insertion, `c` is explicitly set to its copied `total` method's actual parent; the later write therefore changes the original leaf's real DATA, not only a grouping-wrapper slot. Copying the used graph redirects the tree's links to copies; an implementation that keeps its mutable leaf link pointing at original `c` would incorrectly return 105. **Basis:** [P2] §12; semantics §20's common source-to-copy map.

### P13 — Proxy: refusal must skip delegation

```lmx
Requests:
    int: value
    int: real_calls 0
    return: int
    real:
        node\real_calls += 1
        return: value * 2
    proxy:
        if: value < 0
            return: 0
        return: real()
    demo:
        node\real_calls := 0
        @: request proxy
        int: denied request(-4)
        int: allowed request(6)
        request := real
        return: denied + allowed + request(-4)
```

**Entry:** `Requests\demo()` → **4**, from **0 + 12 − 8**; final `real_calls=2`. Its intermediate count is **0** after refusal and **1** after the accepted proxy call. **Basis:** [P2] §13.

### P14 — Facade: explicit zero remains a supplied input

```lmx
DeliveryQuote:
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
        int: first quote(2; 7; 4; 2)
        return: first + quote(0; 7; 4; 2)
```

**Entry:** `DeliveryQuote\demo()` → **50**, from quotes **32** and **18**. In the second call, quantity is explicitly zero; the subtotal is zero and the fee remains 18. **Basis:** [P2] §14; binding directive §6.1.

### P15 — Builder: finished results keep their dimensions

```lmx
Panel:
    int: width 0
    int: height 0
    return: int
    area:
        return: width * height
    builder:
        int: value
        return: Panel
        set_width:
            node\width := value
        set_height:
            node\height := value
        finish:
            return: (copy(Panel))
    ---
    demo:
        builder\set_width(2)
        builder\set_height(7)
        @: first builder\finish()
        builder\set_width(5)
        builder\set_height(3)
        @: second builder\finish()
        builder\set_width(99)
        return: first\area() + second\area()
```

**Entry:** `Panel\demo()` → **29**, from retained areas **14** and **15**. The workpiece ends at width99, height3; its own area297 must not replace either result's area. **Basis:** [P2] §15.

### P16 — Prototype: original and replica diverge in both directions

```lmx
Coordinate:
    int: x 2
    int: y 8
    return: int
    score:
        return: x * 10 + y
    demo:
        @: original (copy(Coordinate))
        original := parent(original\score)
        @: replica (copy(original))
        replica := parent(replica\score)
        replica\y := 1
        original\x := 9
        return: original\score() + replica\score()
```

**Entry:** `Coordinate\demo()` → **119**. The original ends at **(9,8)** and returns98; the replica ends at **(2,1)** and returns21; source `Coordinate` remains **(2,8)**. **Basis:** [P2] §16.

After each grouped copy, the reference is deliberately set to the copied method's actual parent. Graph writes and `score` therefore use the same copied owner. The stream-collecting wrapper is a different Structure with its own cells; replacement of its primitive slot does not update the owner's slot.

### P17 — Memento: restore in reverse order

```lmx
Cursor:
    int: value
    int: state 0
    return: int
    set:
        node\state := value
    read:
        return: state
    history:
        @: snapshot
        return: Cursor
        save:
            return: (copy(Cursor))
        restore:
            node\state := snapshot\state
    ---
    demo:
        set(4)
        @: first history\save()
        set(8)
        @: second history\save()
        set(12)
        history\restore(snapshot := second)
        int: restored_second read()
        history\restore(snapshot := first)
        return: restored_second * 10 + read()
```

**Entry:** `Cursor\demo()` → **84**; final source state is4. Restoring the second snapshot produces8, then the first produces4; the snapshots retain their saved4 and8 rather than following later source writes. **Basis:** [P2] §17.

### P18 — Bridge: independently vary both selected behaviors

```lmx
Audio:
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
        int: total control(2)
        output := speaker
        total += control(2)
        control := boost
        total += control(2)
        output := radio
        return: total + control(2)
```

**Entry:** `Audio\demo()` → **25**, from **4,6,9,6**. The four calls supply level2 separately; boost modifies its own local value, and replacing one selected behavior does not replace the other. **Basis:** [P2] §18.

### P19 — Singleton: both references observe direct writes

```lmx
Configuration:
    int: value 0
    return: @
    get:
        return: Configuration

SharedConfiguration:
    return: int
    demo:
        @: first Configuration\get()
        @: second Configuration\get()
        first\value := 11
        int: seen_from_second second\value
        second\value := 4
        return: seen_from_second * 10 + first\value
```

**Entry:** `SharedConfiguration\demo()` → **114**, from observations11 and4; source `Configuration\value` ends at4. Returning and storing the reference does not implicitly copy its referent. **Basis:** [P3] §19; one provider in one Message is the fixture's scope.

### P20 — Abstract Factory: family selection and independent products

```lmx
Badge:
    int: value
    return: int
    render:
        return: value

Border:
    int: value
    @: badge
    return: int
    render:
        return: value + badge\render()

Day:
    return: @
    badge:
        return: (merge(Badge; (int: value 3)))
    border:
        return: (merge(Border; (int: value 30)))

Night:
    return: @
    badge:
        return: (merge(Badge; (int: value 4)))
    border:
        return: (merge(Border; (int: value 40)))

Screen:
    @: factory
    return: int
    render:
        @: badge factory\badge()
        @: border factory\border()
        return: border\render()
    demo:
        int: total render(factory := Day) + render(factory := Night)
        @: first Day\badge()
        @: second Day\badge()
        first\value := 9
        if: second\value != 3
            return: -1
        return: total
```

**Entry:** `Screen\demo()` → **77**, from Day33 and Night44. Two retained Day badges start at3; explicitly changing the first to9 leaves the second at3. **Basis:** [P3] §20.

### P21 — Flyweight: shared intrinsic data, distinct use positions

```lmx
Glyphs:
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
            return: render(first; -1) + render(second; 4) + render(third; 2)
```

**Entry:** `Glyphs\drawing\demo()` → **75**, from **19,24,32**. `first` and `second` have the same referent, `third` has a different one; a separate negative fixture attempting `first\width := 99` must be rejected by the immutable contract. **Basis:** [P3] §21; negative position is ordinary arithmetic, not an array index.

### P22 — Mediator: copied wiring and two independent rooms

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

Rooms:
    return: int
    demo:
        @: first (copy(Room))
        @: second (copy(Room))
        first\control\toggle()
        int: on first\control\enabled * 10 + first\fan\running
        first\control\toggle()
        first\fan\stop()
        if: second\control\enabled != 0 || second\fan\running != 0
            return: -1
        return: on
```

**Entry:** `Rooms\demo()` → **11**. First room flags are **(1,1)** after the first toggle and **(0,0)** after the second and stop; second room and prototype remain **(0,0)**. Mediator path stores cause no new notifications or recursive notification loop. **Basis:** [P3] §22.

### P23 — Interpreter: copied header, one expression, several activation contexts

The [Interpreter comparison](23_interpreter_comparison.md) shows the kernel's `sys\OPERANDS_TEMPLATE` separately. It supplies generic `left` and `right` reference inputs and the ready constant mode/priority properties, with **no result declaration**. The concrete parent below declares `return: int` once. For this independent fixture, provide that same kernel header; neither an extra result occurrence nor a general DATA last-declaration-wins rule is implied.

```lmx
Operands:
    copy: sys\OPERANDS_TEMPLATE
    return: int
    add:
        return: \left + \right[0]
    Calculation:
        int: n
        return: int
        calculate:
            return: (n add 4) add n
        demo:
            int: zero calculate(0)
            int: negative calculate(-3)
            int: positive calculate(8)
            int: repeated calculate(8)
            if: positive != repeated
                return: -999
            return: zero + negative + positive
```

**Entry:** `Operands\Calculation\demo()` → **22**. The calls yield **4, −2, 20, 20**. The calculated expression is the regression variant `(n + 4) + n`; the compact comparison's `(n + 3) + n` with inputs `2` and `5` yields `7 + 13 = 20`.

The nested calculation finds `add` through the ordinary lexical namespace. `copy` consumes the header reference through the same CODE-source algorithm as elsewhere and contributes its fields through namespace; its written record remains in the source graph. Prepared mode supplies the computed numeric operands by reference. `left` is the left reference; `right[0]` is the first right reference; explicit dereferencing obtains their values. There is no separate operand registration and no permanent cache of one activation's `n` in the expression graph.

Also check the effective operand DATA: exactly one concrete result declaration, both reference inputs, `PASS_ARGS_AS_IS = 0` and the addition priority. OP01–OP16 deliberately retain expanded headers because their tests mutate or inspect individual properties. **Basis:** [P3] §23; [OPERAND] §§2–3; [composition](../LMX_semantics.en.md#composition).


<a id="graph"></a>
## G. Source graph, local state, copying, arrays, and persistence

These cases extend the earlier discussions about `int: i getValue()`, one representation for code and data, `merge`, array/Structure identity, and image-like persistence. The current binding norm governs: own locals have no write-back, and explicit graph paths mutate graph places. Source snippets are independent unless a case says to reuse a fixture.

### G01 — A computed input survives writes to the local variable

**Kind:** source case. **Sources:** [SEM] §12, `call-frame-20261115`, `path-reads-no-execution`, `flush-receiver-contract`; [BIND] §11.3.

```lmx
ReadSource:
    int: calls 0
    return: int
    next:
        node\calls += 1
        return: 40 + node\calls

ComputedInput:
    int: value ReadSource\next()
    return: int
    changeLocal:
        int: seen value
        value := 99
        return: seen

ComputedProbe:
    return: int
    run:
        ReadSource\calls := 0
        int: first ComputedInput\changeLocal()
        int: second ComputedInput\changeLocal()
        return: first * 100 + second
```

**Invoke:** `ComputedProbe\run()`.

**Expected:** `4142`; `ReadSource\calls = 2`. Each call has its own `value`. The written initializer `ReadSource\next()` remains in the source graph, and neither local assignment stores `99` into that initializer. Compare the written declaration, executable bodies and their source reference identities before and after. A serializer may follow the reference to `ReadSource`, whose counter intentionally changes: do not require equality of that entire reachable serialization. Ignore native registration metadata when comparing source forms.

**Distinguishing mutation:** publish the local `value` back into the declaration on return. The second invocation would cease to evaluate the original initializer; this test must catch that.

### G02 — Explicit initialization adjacent to use

**Kind:** source case; reuses `ReadSource` from G01. **Sources:** [SEM] §§9, 12; [BIND] §§6–7.

```lmx
LocalInitialization:
    return: int
    run:
        ReadSource\calls := 0
        int: i
        i := ReadSource\next()
        i += 3
        return: i
```

**Expected:** `LocalInitialization\run()` returns `44`; the producer runs once. No field named `i` is added to `LocalInitialization`, to `ReadSource`, or to a hidden persistent data graph. The source already contains the declaration and assignment forms; inspecting them does not reveal an activation's stored `44`.

**Negative variant:** remove `int: i` and provide no valid own, caller, or fallback place named `i`. `i := ...` must not invent a field or declaration. Refuse the unresolved assignment under the ordinary rules.

### G03 — Shared targets are copied once, and the original is independent

**Kind:** source case plus identity observation. **Sources:** [SEM] §20; [L2] §13.

```lmx
SharedValue:
    int: value 7

SharedPair:
    @: left SharedValue
    @: right SharedValue

SharingProbe:
    return: int
    run:
        @: copied (copy(SharedPair))
        copied\left\value := 21
        return: copied\right\value * 100 + SharedValue\value
```

**Expected:** `SharingProbe\run()` returns `2107`. In the copied graph, `left` and `right` designate the same copied target. That target is distinct from `SharedValue`; `SharedValue\value` remains `7`.

Preserving the internal relationship does **not** mean retaining a reference to the original mutable target. This case rejects both a shallow copy and two unrelated copies of the shared target.

### G04 — A cycle is redirected into the copy

**Kind:** source case plus identity observation. **Sources:** [SEM] §20; [L2] §13.

```lmx
Ring:
    int: value 3
    @: self

RingProbe:
    return: int
    run:
        Ring\self := Ring
        @: copied (copy(Ring))
        copied\self\value := 8
        return: copied\self\value * 10 + Ring\value
```

**Expected:** `RingProbe\run()` returns `83`; `copied\self` designates the copied Ring node and a second self traversal returns to that same copied node, never to the mutable original. The write follows `copied\self` to the copied Ring descriptor, so it replaces that owner's `value` fragment directly. The explicit grouping wrapper is a distinct Structure with its own cells: its separate `copied\value` remains **3**, while `copied\self\value` becomes **8**. The original self-reference still designates `Ring`. Traversal terminates and allocates one copy per copied source node. Grouping neither deep-copies the completed graph again nor reparents its existing relationships.

### G05 — Composition replaces a model field and appends new material

**Kind:** source case plus layout observation. **Sources:** [SEM] §20, “Model slots, field matching and ordering”; DP3, DP16–18.

```lmx
RecordModel:
    int: width 2
    int: height 3

RecordPatch:
    int: height 5
    int: depth 7

RecordProbe:
    return: int
    run:
        @: result (merge(RecordModel; RecordPatch))
        return: result\width * 100 + result\height * 10 + result\depth
```

**Expected:** `RecordProbe\run()` returns `257`; the original fields remain `2`, `3`, `5`, and `7` in their respective source Structures. In the composed model, `width` retains its model position, `height` replaces the matching model field, and `depth` is appended. There is no second competing `height` created by the override.

**Historical analogue:** the case establishes copied composition and replacement of the matching model field. Installing this new Structure into an application branch requires a separate explicit reference assignment; independently retained copies elsewhere do not silently update.

**Field-stream variants:** retain G05's values and add the following independent observations under [composition](../LMX_semantics.en.md#composition):

| Variant | Required observation |
|---|---|
| Write `merge(RecordModel RecordPatch)` inside an ordinary DATA declaration | Its namespace receives `width = 2`, `height = 5`, `depth = 7`; its source graph still contains the written merge, not substituted expanded fields |
| The receiving DATA already declares `height = 99` | That place is not merge's model slot; the merge's own `height = 5` is received through ordinary DATA redeclaration/occurrence rules, without a hidden overwrite of `99` |
| Two separate copy/merge operations receive material referring to one mutable source | Each operation has its own copy map; common targets are shared inside one operation, not automatically across both |
| A source is computed by an explicit producer call | It runs once when that operation consumes the source, including when the operation is written in DATA; P0 and source inspection run it zero times |
| An anonymous source contains a call or computed declaration | Its contents obey their ordinary contracts; grouping neither quotes away the call nor starts a blanket eager-initializer pass |
| `copy(Empty)` versus `(copy(Empty))` | No output fields versus one explicitly grouped empty Structure; no missing source in either case |
| One written `merge(S)` whose E reading supplies two admitted sources | Do not reject by written arity before W/E; retain ordinary ambiguity rules when more than one reading succeeds |

Use an explicit real formal such as `f(arg0 := (copy(Source)))` when a variant needs to force whole delivery without E. A grouping wrapper by itself does not disable the next consumer's ordinary selection. Keep input-source arity separate from output-field count.

### G06 — The qualified immutable branch is the sharing exception

**Kind:** graph fixture. **Sources:** [SEM] §§20, 22–23.

Build an admitted `independent: immutable` branch `E` and a mutable template `T` with a reference to `E` and an ordinary mutable numeric field `count = 2`. Construct `A = (copy(T))` and `B = (copy(T))`.

**Expected:** both references to `E` are the original physical reference. `A.count` and `B.count` are distinct mutable places: writing `A.count = 8` leaves `B.count = 2` and `T.count = 2`. Repeat with the additional `const` qualification: the same identity rule applies. Repeat with only `independent`, or only `immutable`: those alone do not establish this retention exception.

Use the implementation's ordinary qualification construction in the harness; the letters and dotted paths in this paragraph are fixture notation, not additional LMX syntax. Reject a falsely qualified branch containing an impermissible mutable reachable target rather than silently treating it as eternal.

### G07 — A Structure and an Array of references expose the same slots

**Kind:** graph/representation fixture. **Sources:** [SEM] §§2, 17; [L2] §§2–4.

Construct one reference-array descriptor containing three distinguishable field references. Observe it through an Array<@> reference and through an admitted Structure view. Write the second slot through one reference, then read it through the other.

**Expected:** same descriptor identity, same length `3`, same three physical slot positions, and the newly stored reference visible through both. No conversion copy, wrapper descriptor, duplicated element backing, or new parent is produced merely by the view. A field that *contains* an Array reference remains a separate containing field.

**Companion negative check:** a dense `Array<int>` is not reinterpreted as an array of references. Its numeric elements are stored as numeric elements.

### G08 — Multidimensional indexing checks the final linear index

**Kind:** typed-array fixture. **Sources:** [SEM] §17; [L2] §18.

Use a rectangular `2 × 3` integer Array with row-major contents `10, 11, 12, 13, 14, 15` and the declared strides. Verify reads and writes using the implementation's existing typed-Array constructor.

| Access | Linear index | Expected |
|---|---:|---|
| `[0][0]` | 0 | 10 |
| `[1][0]` | 3 | 13 |
| `[0][3]` | 3 | 13, the same element as `[1][0]` |
| `[1][2]` | 5 | 15 |
| `[2][0]` | 6 | L3 implicit failure `interpreter` |
| coordinates whose mathematical linear index overflows the machine index | out of range | failure; no wrap into an in-range element |

For native L2, test offset calculation only within deliberately allocated backing that makes the selected address valid; native L2 has a different checking contract. Do not use an invalid raw pointer dereference as a portable negative test.

### G09 — An L3 element reference survives backing relocation

**Kind:** typed-array/lifetime fixture. **Sources:** [SEM] §17, `l3-array-reference`; [L2] §§2, 18.

Create a numeric Array of length `3`, retain an L3 reference to element `1`, and force a reserve/resize that moves its backing while keeping element `1` within the new length. Store `27` through the retained reference.

**Expected:** the Array descriptor is unchanged and the current backing's element `1` becomes `27`. The L3 reference resolves through descriptor plus index; it does not retain the old storage address. Reserve alone changes no length. After shrinking the Array below index `1`, dereferencing the retained element reference follows the ordinary L3 bounds-failure rule.

No assertion promises to repair an old raw L2 storage address.

### G10 — Serialization saves the current graph and its relationships

**Kind:** codec fixture; use G03 and G04. **Sources:** [SEM] §21, `source-codec`; [L2] §2.1.

Serialize and restore a graph containing: one explicitly changed ready field, one unchanged computed declaration from G01, two references to a shared mutable target, a self-cycle, and an Array. Compare the restored graph by structure, values, and relationships.

**Expected:** the explicit changed value is restored; the unchanged initializer remains a declaration/expression; the two references still share one restored target; the cycle closes within the restored graph; Array length/order/element types survive. Do not compare absolute process addresses. Local `99` from G01 is absent from the saved source declaration.

For a selected Thread, add a same-platform restart case for its serializable call/native tables and binary module/entry identifiers. An arbitrary selected subtree must not silently acquire all external arena tables. A file descriptor or address of a temporary native local is not reconstructed by treating its old numeric value as a portable resource.

### G11 — Taking an address does not turn a source expression into its value

**Kind:** source fixture observation; use G01. **Sources:** [SEM] §12, `computed-field-address`; [L2] §11.

In one active call to `ComputedInput\changeLocal`, obtain `@value`; separately obtain `@(ComputedInput\value)` from an external inspection call before executing the producer.

**Expected:** under [OPERAND] §3.3 the explicit `@` operation produces a numeric address. In the first observation that address identifies the selected activation-local integer place, obtaining its value under the ordinary demand rules. In the second it identifies the written source declaration, not the result of `ReadSource\next()`, and does not run that producer. These address observations must not be relabelled as implicit ordinary reference construction. A native local is tested through its declared place/type contract; do not inspect four bytes before an arbitrary C local as if it were an arena record.

### G12 — A factory returns a method of an explicitly prepared copy

**Kind:** source case. **Sources:** [BIND] §4.2; [SEM] §20; [DP1] §3; [DP3] “Reading the examples”.

```lmx
AdderPrototype:
    int: saved 0
    inputs:
        int: x
        return: int
        add:
            return: x + node\saved

AdderFactory:
    int: increment
    return: @
    create:
        AdderPrototype\saved := increment
        @: instance (copy(AdderPrototype))
        return: instance\inputs\add

ReturnedMethodProbe:
    return: int
    run:
        @: plus5 AdderFactory\create(5)
        @: plus9 AdderFactory\create(9)
        AdderPrototype\saved := 99
        int: saved 1000
        int: a plus5(1)
        int: b plus9(1)
        return: a * 100 + b
```

**Expected:** `ReturnedMethodProbe\run()` returns `610`, encoding `6` and `10`. The two returned methods retain their respective copied lexical graphs after both factory activations have ended. The prototype now holds `99`, and the caller's unrelated `saved = 1000` does not override explicit `node\saved`.

`saved` is outside the methods' immediate input data. Consequently `plus5(1; saved := 40)` is an unknown-explicit-input rejection, unlike the true formal-default example B-01. The reference returned by `create` is not an address of its temporary local variable `instance`. The state entered the copy through the explicit `AdderPrototype\saved := increment`; `copy` did not capture the factory activation automatically.

<a id="uninit-graph"></a>
### G13 — Literal graph, zero-payload uninit, and explicit graph replacement

**Kind:** standalone source case plus representation observations by the existing harness. **Sources:** [UNINIT]; [SEM] primitive declarations and activation-local places; [L2] primitive storage.

```lmx
UninitializedGraph:
    int: novalue
    @: noReference
    int: zero 0
    @: nullReference 0
    return: int
    numberReady:
        return: novalue != nil
    referenceReady:
        return: noReference != nil
    localWrite:
        novalue := 5
        noReference := 0
        return: novalue
    storeGraph:
        node\novalue := 5
        node\noReference := 0
        return: node\novalue
    requireNumber:
        required: novalue
        return: novalue
    checkZero:
        required: zero
        return: zero = 0 && zero != nil
    checkNull:
        required: nullReference
        return: nullReference != nil
```

The harness invokes the listed methods without supplying unrelated same-named caller locals. Keep the graph fresh for the main sequence; run rejection variants separately.

| Step | Required observations |
|---|---|
| Construct the clean graph without calling its methods | `novalue` has the `uninit:int` code and no value payload; `noReference` has the corresponding uninitialized-reference code and no value payload. In both records, `sizeof(value) = 0`. Neither record contains an allocated ordinary T cell, a hidden zero, or a complete inner T record. |
| Call `numberReady()` and `referenceReady()` | Both return **0**. |
| Call `checkZero()` and `checkNull()` | Both return **1**: the integer zero and null reference are initialized values, distinct from typed absence. |
| Call `localWrite()` | Returns **5**. Its local integer is 5 and its local reference is null; the two source declarations remain their original zero-payload uninitialized records. |
| Call `numberReady()` and `referenceReady()` again | Both still return **0**; neither assignment was published on return. |
| Call `storeGraph()` | Returns **5**. Fresh inspection through the graph paths observes `{int 5}` for `novalue` and the ordinary initialized null-reference record for `noReference`. These are explicit graph-fragment replacements. |
| Call `numberReady()`, `referenceReady()`, and `requireNumber()` afterward | Return **1**, **1**, and **5**, respectively. `zero` and `nullReference` remain their original initialized zeros. |

On a fresh graph, `numberReady(novalue := 0)` returns **1**, while `numberReady(novalue := nil)` returns **0**; neither explicit actual initializes the source field. After `storeGraph()`, omission selects the ready value 5, explicit zero remains an initialized override, and explicit `nil` selects absence for that call rather than falling back to 5. A fresh `requireNumber()` refuses at the reached CODE `required`; `requireNumber(novalue := 0)` succeeds and returns **0**, while explicit `nil` refuses. Likewise `referenceReady(noReference := 0)` returns **1** without initializing the source reference.

Inspect the source record's code and value-payload extent through the existing representation fixture. `sizeof(value) = 0` is the payload-size oracle, not a claim that a type code occupies zero bytes or a proposed new spelling of a public `sizeof` receiver. A native frame's local value is tested through the local-place contract; it is not required to contain an arena record before its machine storage.

The clean graph keeps the written declaration and executable forms, with the ordinary terminal primitive representation `{type value}`. Only the explicit graph stores above replace their selected fragments. Do not require in-place retagging, a stable old raw value address, a particular allocator/reallocation path, or automatic repair of a pointer taken before replacement. Do not dereference such a raw pointer as a positive test. The author's clarification resolves the former physical-uninit question; this case does not leave it open.

Add a graph fixture with two distinct Lmx structure cells initially pointing at the same `{uninit_int}` fragment. Assign **5** to one selected cell. Fresh observation sees `{int 5}` there while the other cell still refers to `{uninit_int}`; sharing an old fragment did not make those cells one destination. In the positive alias variant, two paths identify the same structure cell, so both see its replacement. This distinguishes structural-place identity from raw fragment-address identity and guards the copied-owner fixes in P12/P16 and G04.

**Import versus deep copy and merge.** Use `Source` with a ready `value = 7` and a method `read` that returns its own DATA value, without an explicit overriding actual. Import that eligible method and separately obtain `(copy(Source))` and `(merge(Source; Empty))`, where `Empty` is an empty source Structure. The merge therefore has two admitted sources and no overlay that changes the initial value. The imported method and its parent are the original objects. Each copied method has its corresponding deeply copied parent. Each grouping wrapper is a distinct Structure with its own cells, different from the original or copied owner's cells. Change the original owner's `value` to **9**: the imported method returns **9**, and the copied methods still return **7**. Replace a grouped result's outer `value` slot with **50**: that group reads **50**, but its copied method still returns **7**. Replace that method's actual copied owner's `value` with **12**: the method now returns **12**, while the group's separate slot stays **50** and the original remains **9**. As a separate positive control, follow two references into one shared nested Structure and verify that paths selecting its same inner cell observe the same replacement. Distinct outer cells must not destroy the common copy map's shared-target relationships.

**Literal graph and receiver replacement.** Use the existing parser/graph fixture to inspect ordinary valid written `for`, `if`, `merge`, `copy`, and `import` occurrences, including their receiver records, arguments, groups and source order. Each remains exactly its written form: processing a receiver produces namespace results without replacing its source occurrence with an expanded result. The same source-fidelity rule covers terminal primitives; `{type value}` is their direct literal representation, not permission to drop them from the graph. In the clean graph, `parent` and `length` are obtained logically from the source structure; the remaining written material is represented by the pointers in the ordinary Lmx structure array. There is no second hidden graph of program data or callable bodies.

Use this additional standalone source to distinguish legal graph replacement from execution of the old receiver:

```lmx
EditableBranch:
    int: ticks 0
    return: int
    act:
        if: 1
            node\ticks += 1
        return: node\ticks
```

On a fresh graph, `EditableBranch\act()` returns **1**. In a separate fresh fixture, replace the written `if` occurrence in `act` with the terminal integer fragment `{int 5}` through the ordinary graph operations. The whole selected fragment is now that integer; the old conditional and increment are absent at that position. After the normal explicit compilation and reset/endturn restart for the changed unit, `act()` returns **0**, because an ordinary standalone integer statement does not increment `ticks`. There is no rule that reserves graph replacement for a separate narrow debugger-only API or forbids replacing a receiver merely because it used to be executable.

Repeat the representation-level replacement with each selected receiver kind and with an ordinary data Structure, using a differently shaped valid graph fragment. Structural replacement itself is allowed; subsequent interpretation, admission or compilation applies the ordinary rules of the new consumer context. A replacement that makes a required argument incompatible can be rejected when consumed without redefining the graph operation as “only replace with the old shape.” Do not execute a stale compiled unit before its specified update boundary or invent automatic repair of old native/raw pointers.

**Program and R0 inspection.** Inspect the resulting program representation and generated entry method, rather than inventing a new source-level boot protocol. The complete written program is the Lmx graph. The accompanying native binary contains methods, not a second repository of program data. Its R0 is an ordinary C method with a **local** pointer to the R0 graph. Running user bodies through the interpreter still uses a binary R0; “interpreted program” does not mean the absence of that binary entry. Reject a separate hidden callable graph, a persistent mirrored data graph, or a fabricated global R0-data object introduced to satisfy this fixture. This does not add `main`, input DATA or automatic root execution to the source R0 contract, and does not mistake ordinary temporary execution locals for another stored program graph.

Trace the interpreter's actual program input and the lifetime of structures it creates while executing and repeating the fixture. Reject a parallel **working graph**, an expanded execution graph, a callable graph, or a materialized namespace graph used in place of the complete written graph, whatever the implementation calls it. Renaming that extra representation a cache or preparing it for each activation does not satisfy the rule. Ordinary ephemeral local values and execution bookkeeping are allowed; graphs explicitly requested by the program's `copy`/`merge` operations remain their ordinary semantic results. Neither is permission to maintain another executable version of the program.

Use B-06's `private` declarations as a concrete negative control. The interpreter and translator encounter the ordinary written `private` receiver in the complete graph; the source path still passes through that receiver, such as `PrivateSink\private\x`. Both executor configurations retain B-06's **0,1,0,1** behavior. Reject an implementation that flattens `private` away and executes a second binary/marked graph carrying equivalent flags instead. Correct result flags alone are insufficient if the implementation obtains them through the forbidden duplicate representation. Ordinary binding decisions or generated method code are not a new flagged program graph.

<a id="native"></a>
## N. Execution paths, native entries, explicit recompilation, and cleanup

These are harness cases because selecting a backend, observing machine-entry registration, or advancing a turn is an execution-environment operation. They require no new L3 receiver.

### N01 — One binding result in all four executor combinations

**Kind:** backend matrix. **Sources:** [BIND] §§11–12; [CORE] §3.3; [CODING] §§13–14.

Run representative cases for explicit own values, autofill copies, direct caller aliases, transitive fallback copies, private sources/receivers, supplied declaration plus body, and imported method parent identity in all four combinations:

| Caller | Callee | Required observation |
|---|---|---|
| interpreter | interpreter | baseline values, places, and effects |
| interpreter | native | identical selected logical places and effects |
| native | interpreter | identical selected logical places and effects |
| native | native | identical selected logical places and effects; direct C call where statically known |

Record `@x` relationships while the activations are alive, not unstable absolute address numbers. Reject a result where a bridge's own locals become the language caller, an alias is replaced by exit-time copy-out, or a fallback copy becomes an alias. This parity claim concerns successful program behavior; the phase-specific admission/test observations in Q01 are kept separate.

Use G13's program/R0 inspection on both interpreted and native configurations: the binary entry remains an ordinary R0 method with a local graph pointer, and the complete source program remains in its graph rather than a hidden parallel data representation.

### N02 — Executable graph edits require explicit compilation and a turn boundary

**Kind:** source fixture plus turn driver. **Sources:** [SEM] §12, `explicit-compilation`, `endturn-receiver`; [L2] §11.1–11.2.

```lmx
RevisionUnit:
    return: int
    target:
        return: 7
    replacement:
        return: 9
    caller:
        return: target() + 1
```

1. Explicitly compile `RevisionUnit` and enter through `caller`; expect `8`.
2. Through ordinary graph editing, replace `target`'s executable return expression with the expression returning `9`. Keep the target occurrence and compatible call contract. Record that the graph changed.
3. Verify that this write itself neither clears native entries nor invokes compilation. **Do not assert an intermediate call result:** the documents leave pre-boundary executable-edit timing unspecified.
4. Successfully execute `sys\compile(RevisionUnit)`, then reach `sys\endturn()` through the ordinary exit mechanism.
5. Enter `RevisionUnit\caller()` on the next scheduled turn; expect `10`.

No hidden code snapshot or automatic reverse-dependency invalidation is needed to satisfy the case.

### N03 — Recompiling a target alone does not rewrite an old direct caller

**Kind:** compilation dependency fixture; use N02. **Sources:** [SEM] §12, `explicit-compilation`; [CORE] §8.

Keep the old compiled direct caller, change `target`, and compile only the target occurrence. Check generated/registered code: this operation does not rewrite the direct call embedded in old `caller`. Then explicitly compile the common unit containing both and cross the turn boundary; the next call must use the update.

The test must not claim that replacing one target table entry retroactively patches all generated C callers. It also must not require an invented per-dispatch freshness check.

### N04 — Copying a graph containing methods is not a compilation or registration request

**Kind:** native table observation. **Sources:** [SEM] §20, “Native implementation reuse and copied callable occurrences”.

Compile a source Structure containing methods, record the call-table registrations, and obtain `(copy(Source))` from that graph as a new grouped result.

**Expected:** distinct mutable graph/state for the new occurrence; any ordinary retained link to reusable native implementation material follows its documented terminal contract. The copy operation invokes no compiler and installs no new call-table entry for that new graph. Explicit compilation or restoration can subsequently register a suitable native binding. Sharing an implementation address does not make the two lexical/state graphs identical.

Do not reintroduce the obsolete rule “every merge clears native” or assume “every merged method is immediately registered as native”.

### N05 — Missing native entry and failed compilation

**Kind:** dispatch fixture. **Sources:** [SEM] §§1, 12; [L2] §11.1.

Call admissible L3 code with no suitable native entry: expect its ordinary interpreter result and zero implicit compiler invocations. Separately request explicit compilation of a malformed/incompatible edited graph: expect compilation diagnostics and no newly registered successful entry for the failed attempt. Do not report failure as a successful interpreter retry of a partially executed native call.

### N06 — Cleanup, return, and endturn have distinct effects

**Kind:** control-flow fixture. **Sources:** [SEM] §§14–15; [L2] §11.2.

Register two cleanups in order A then B; each appends its letter to an explicit observable log. Use a nested caller with its own cleanup C.

- On an ordinary return from the inner call, expect B then A; C runs only when its own scope exits.
- On an exit crossing both activations, including `sys\endturn()`, expect B, A, C. The endturn call never returns to its next statement, and ordinary catch does not intercept it.
- A value-return expression is evaluated once before cleanup. If cleanup changes an explicitly addressed variable afterward, it does not recompute that returned scalar.
- A reference result retains target identity; cleanup effects on that same target remain ordinary observable mutations.
- No cleanup, return, or endturn implicitly publishes unrelated local variables into source graph fields.

Use the existing `finally` construction and logging fixture; this is a control contract, not a proposal for extra exception syntax.

<a id="messages"></a>
## M. Message isolation and real integration boundaries

These cases are protocol harnesses. They provide small deterministic scenarios without inventing a new spelling for transport setup that is not fixed by the current documentation packet.

### M01 — A complete update is one owner operation

**Sources:** [SEM] §§24–25; [CORE] §7.

An owner starts with `total = 0`. Two senders submit complete `add(4)` and `add(9)` operations. Deliver both in either admitted order.

**Expected:** `total = 13` in both orders, each operation executed once, no simultaneous active turns in that owner. Distinct owners may run concurrently. No L3 lock is added to the counter code.

**Counterexample test:** two split clients each read `10`, compute `11`, and then send a write. A final `11` is allowed by that split protocol. Serial execution alone must not be advertised as an atomic read-modify-write spanning separate messages.

### M02 — Fan-out multiplies deliveries, not source executions

**Sources:** [SEM] §28; [GUIDE] “post: one call, multiple deliveries”.

Prepare two independent asks, each with three answer destinations. Each source call increments its own execution counter and returns a distinguishable value.

**Expected:** two source executions, two original results, six answer deliveries. Bind all answer routes before publishing requests. One failed answer delivery does not reclassify its already completed source call as an undelivered request. A no-result source call creates neither a synthetic result nor an automatic application ACK.

### M03 — Stored arguments and the dispatch clock

**Sources:** [SEM] §28, “Events and time”.

Form an argument with a side effect, prepare a request, change the source variable, and then dispatch. Delay dispatch deliberately before starting an explicit timeout.

**Expected:** argument side effect exactly once; `undelivered`/`unanswered` receive the stored formed arguments, not a reevaluation after the variable changed. Timeout is measured from actual sending. Expiry alone does not cancel execution or automatically discard a later reply. Use a controlled clock in the harness and assert the threshold rule; do not demand an exact wall-clock scheduler delay.

### M04 — Copy, reference passing, and storage transfer stay distinguishable

**Sources:** [SEM] §§20, 22, 24–26; [L2] §§8, 13, 15.

Test the same small graph under three operations:

| Operation | Identity and ownership observation |
|---|---|
| ordinary reference passing within one owner | same graph; same structural parent |
| `(copy(Template))` or a new executing Message from an explicitly supplied template | copied mutable graph; internal relations redirected; only admitted terminal exceptions shared |
| supported transfer of a non-executing letter's storage | storage/addresses preserved; one owner after transfer; structural parent unchanged |

Retain a result reference across an ordinary function return and confirm it stays reachable without an implicit return-time copy. After all ordinary roots are released, test collection at the specified end-of-turn boundary. Do not infer lifetime of an escaped pointer to a completed native activation from graph reachability.

<a id="author-question"></a>
## Q01. Current admission and test phases

This retained section ID now records the current phase contract. The older corpus's automatic-scheduling question cited a superseded document snapshot; the supplied `docs/` edition separates the stages. See [normative admission](../LMX_semantics.en.md#admission), [test receiver](../LMX_semantics.en.md#test-receiver-contract) and [explicit compilation](../LMX_semantics.en.md#explicit-compilation).

| Stage or event | Contract to observe |
|---|---|
| Structural graph construction | Known candidate interfaces are checked; candidate bodies, computed defaults and analytical tests do not execute merely for matching |
| Explicit pre-C build-test phase | The interpreter executes the build's reached tests on the clean graph; a failed test prevents acceptance/compilation of that build |
| DATA namespace preparation | Root declarations and required stream receivers are interpreted; an arbitrary nested `test` record is not executed merely because it exists |
| Prepared native execution | No additional automatic runtime `implements` layer; written explicit checks remain ordinary code |
| Reached interpreted operation | Standard admission through the common mechanism; no pre-walk of unexecuted branches |
| Admission requiring analytical checks | The receiving expression's specified checkers execute against the actual candidate; the first `0` stops the sequence |
| Calls made by a checker | Ordinary native/walker dispatch; no hidden forced-walker mode, rollback or mock candidate |

V05 instruments these distinct events rather than assigning one global count to every possible use of a candidate. A build stage and a later dynamic reception are separate events; a native dispatch by itself is not an instruction to rerun every test in the graph. Explicit checker programs V01–V04 retain their concrete expected results.

## Documentation reconciliation applied in this revision

| Earlier corpus form or claim | Current contract used here |
|---|---|
| `reference/` document paths and old exported-file line numbers | Bundled `docs/` and `docs/TZ/` paths; stable sections/anchors |
| Single-source `merge(Source)` intended to make one object | `(copy(Source))` |
| Multi-source `merge(Model Values)` intended as one reference or returned Structure | `(merge(Model Values))` |
| DATA placement gives import/copy/merge DATA arguments | All three consume ordinary CODE sources and use normal W/E in every placement |
| Copying or merging directly overwrites the receiving source graph | The receiver remains written; its result stream is consumed through namespace |
| Separate streams overlay the destination using merge's model-slot rule | Only one merge's explicit sources participate in its overlay; normal DATA repetition governs separate streams |
| Inline-local initialization left as an open choice or based on old answer R106 | C-01 follows current caller-only autofill and nested own-place rules: uninit without a caller source, checked safely by required |
| Nested/preallocated T storage under uninit, in-place retagging, or a stable raw address after graph initialization | Author clarification: code-only `uninit:T`, zero value payload; local writes stay local, explicit graph assignment replaces the fragment; G13 |
| Old automatic-test scheduling question | Current separated phases, V05 and Q01 |
| User operands require a private registry or an input-template result type | Ordinary method/header discovery; P23 copies the shared header and declares its concrete result once |
| Grouping a copied stream forces its wrapper to be the source-root copy | The wrapper and copied root are distinct Structures with distinct cells; mapped shared targets and cycles remain preserved; G04/G13 |

An explicitly supplied full structural template still requires its complete stated tree. A named `fn` requirement compares ordered input types and the result; a Consumer-derived used interface is a different stated requirement. These are current branches of one admission mechanism. The old load-dirty publication, source initializer replacement, automatic native clearing and fixed-Array/separate-List rules are not restored.

## Suggested implementation sequence and evidence

This order groups dependencies; it adds no new project gate and does not require rebuilding everything after a small edit.

1. **Common parse and source preservation:** block boundaries, declaration/call roles, named-actual boundaries, OP17. Keep the written graph while resolving roles later.
2. **Ordinary call, places, and signatures:** B-01–B-13, C-01, T01–T05. Establish that the right place is read and written before using richer scenarios as evidence.
3. **Declaration arguments and import:** D-01–D-04, then P01 and P07. Check counts and visibility, not only final totals.
4. **Expression operations:** OP01–OP16, then P23. Exercise skipped and repeated effects as well as arithmetic.
5. **Graph composition and the complete pattern scenarios:** G01–G13 and P01–P23. Check aliases, retained copies, actual parents, source preservation and zero-payload uninitialized records.
6. **Explicit checker programs:** V01–V04 and T02/T06. Use V05/Q01 to distinguish construction, build-test and reached-admission events.
7. **Backend parity and explicit update lifecycle:** the relevant N/OP18 matrix and generated-code observations; native-local places must preserve language semantics without being treated as arena records.
8. **Codec, Message and integration fixtures:** G10, T07 and M01–M04 on the affected runtime components.

For each executed variant, preserve at least:

| Receipt item | Required content |
|---|---|
| Identity | Case ID, variant, source bytes/hash, repository revision and relevant selected profile |
| Invocation | Actual command/entry, actual arguments, initial graph state |
| Execution | Caller/callee modes; whether the intended body/handler was reached |
| Expected | Return/verdict, effects/counters, identities/write targets, and specified failure phase |
| Actual | Observed counterparts, exact diagnostic if any, relevant trace |
| Result | PASS / FAIL / NOT RUN; use BLOCKED BY TZ CONFLICT only for quoted explicit contradictions between current governing TZ |

Use the project's existing L2/L3 runners. For an implementation slice, run its minimal changed case and affected dependencies; choose full self-build and broader suites under [CODING]'s existing conditions. Preserve the difference between a source reviewed here, a program that translates, and a program whose required path actually ran.

Do not weaken a negative control to make the implementation pass. Examples especially worth preserving are the alias-versus-copy distinction in B-03/B-04, named-interface permutation in B-10, the two `scratch` stores in OP08, repeated raw evaluation in OP03, the candidate that reads twice in V02, successful ACK with failed feedback in V04, and a tree wrongly retaining its original mutable leaf in P12.

## Snapshot record

These SHA-256 values identify the bundled normative documents used for this revision. They are provenance, not execution receipts. Companion pattern guides and reports are regenerated in the same archive from their source examples; they do not receive stale hashes copied from an earlier package.

| Bundled source document | SHA-256 |
|---|---|
| [CORE.md](../../CORE.md) | `a1bd40c16303ddb368335f6dc8ce36b5b97fb80b0db11f413455e94ecc2fdb6c` |
| [L2_L3_CODING_INSTRUCTION.md](../../L2_L3_CODING_INSTRUCTION.md) | `21d848ca8469c1a841380947c8a5ec2f63f66535a1c06d1489fd43585e5d7810` |
| [L2_spec_en.md](../L2_spec_en.md) | `fae448565904f3602d999e3e05a5f8b774b123a1ac05ff813fed8874106a93b1` |
| [LMX_grammar.en.md](../LMX_grammar.en.md) | `a09f46cfbbc9a2135aa5ffba88e61ad489b15a7f5fbf7aaa8241a6210ee9af7d` |
| [LMX_semantics.en.md](../LMX_semantics.en.md) | `a4cba3b213fd383b274be4e547816bccbd43703cba396428a6f3a0f2dc5a8741` |
| [LMX_semantics_guide.en.md](../LMX_semantics_guide.en.md) | `d88aa052d208c8d962b49126b803e7b910e2407926ea905ebf89eae44e493459` |
| [README.md](../README.md) | `13caa6dbe3ec29afab17cebec3f04a26c6c707d7aeb55fef3a38a3427980dc6e` |
| [REVIEW_NOTES.md](../REVIEW_NOTES.md) | `95310dd90b1ef5379359728eb0b3a3450a94c9103f37ab616279a94681279fa3` |
| [implementation-notes.en.md](../implementation-notes.en.md) | `a8891acb7e4636c33a8c9c798121fd3f38154074adea26efa641330aa0c01e70` |
| [kernel-implementation.en.md](../kernel-implementation.en.md) | `ee49134e1c41dd675fe8f37b3049c01a5faa4fc2a6a4a7a88eb8d121a6d3c2b5` |
| [source-comparison.en.md](../source-comparison.en.md) | `0f97c42f17912ce4c5bf88eef2a5114943a27717d36b2602f1eb34d9d36b2b91` |
| [LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md](../tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md) | `8b6476a7b32d4e72065f21c5075fef2f6a846a81f4a2d4130e32b9ad0ee55099` |
| [LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md](../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md) | `cfb0dafcfc7d0f86339946e88b55b4d78b58cf22d64bc6c478d0b0683074b33f` |
| [LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md](../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md) | `48c8a29ace16ca79ae2b5b4c6b85f8dca5b61a4dfee9bb41d19987e540f90992` |
| [to_fable_operands_arguments_priorities.md](../tasks/to_fable_operands_arguments_priorities.md) | `ed8926c864b52f528d4339f3c66e3e7b84cee13645054091894f3113f2e880a6` |

<!-- Relative source links for the package layout. -->
[O]: ../tasks/to_fable_operands_arguments_priorities.md
[OPERAND]: ../tasks/to_fable_operands_arguments_priorities.md
[B]: ../tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md
[BIND]: ../tasks/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md
[D]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[DECL]: ../tasks/LMX_Fable_TZ_Declaration_Arguments_and_Import_v2_2026-11-20.md
[P1]: LMX_Design_Patterns.en.md
[DP1]: LMX_Design_Patterns.en.md
[P2]: LMX_Design_Patterns10-18.en.md
[DP2]: LMX_Design_Patterns10-18.en.md
[P3]: LMX_Design_Patterns19-23.en.md
[DP3]: LMX_Design_Patterns19-23.en.md
[S]: ../LMX_semantics.en.md
[SEM]: ../LMX_semantics.en.md
[G]: ../LMX_grammar.en.md
[GRAMMAR]: ../LMX_grammar.en.md
[L2]: ../L2_spec_en.md
[GUIDE]: ../LMX_semantics_guide.en.md
[CORE]: ../../CORE.md
[CODING]: ../../L2_L3_CODING_INSTRUCTION.md
[BLANK]: ../tasks/LMX_Fable_TZ_Blank_Line_Block_Terminator_2026-11-20.md
[UNINIT]: ../LMX_semantics.en.md#uninit-zero-payload

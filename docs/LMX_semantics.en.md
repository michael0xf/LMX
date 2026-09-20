**Lingvamyxa (hereafter LMX) is a language in which a program is a lexical forest of primitive arrays connected into a dynamic graph.** This organization repeats self-similarly at the level of local actors with physical memory addressing and further at the level of remote intermachine messages with composite addressing.

**Both data and executable bodies are arrays**, represented by the same simple universal structures; every executable body is a complete abstract expression.

**Typing is analytical, at the level of lexical branches.** Admitting any candidate as an argument to any expression requires analytical compatibility checking and mandatory runtime validation by unit tests specified by the receiving expression. Tested candidates and checking expressions are uniquely identified by their physical addresses.

LMX is also a grammar capable of representing both data in a complex, uniquely structured hierarchical and tabular form with intersecting sets and, in principle, any language. See the [complete grammar specification](LMX_grammar.en.md).

**Language levels.**

- **L0** is native code: microprocessor instructions or virtual-machine instructions. For a microprocessor, the translation chain is **L3 → L2 → L1 → C99 → L0**; for a virtual machine, it is **L3 → L0** directly. Arrows denote translation stages.
- **L1** is the level of the L1 language and C99, described in [L1_spec_en.md](L1_spec_en.md) and [L1_spec_ru.md](L1_spec_ru.md).
- **L2** is LMX itself with low-level operations, described in the [L2 specification](L2_spec_en.md).
- **L3** is pure, hermetic LMX. Its semantics are the subject of this main specification.

<a id="scope"></a>
## 1. Scope and related specifications

This specification defines L3 values, relationships and execution. Source notation is defined by the [grammar](LMX_grammar.en.md); machine operations and implementation are covered by [L2](L2_spec_en.md) and [L1](L1_spec_en.md). A particular memory implementation does not introduce language rules by itself. The origins of the rules presented here and open discrepancies are recorded in the [research map](../steps/l3-semantics.md).

<a id="values"></a>
## 2. Values and Structures

A **Structure** is an ordered collection of direct fields. A field contains a reference to a value: a primitive, another Structure, an Array or a method record. Structure nesting forms lexical trees; additional references connect them into a graph. Multiple fields may reference the same value, and graph edges may form cycles.

An **Array** contains elements of one type. Its length counts Array elements; a Structure's direct-field count counts Structure fields. These quantities differ. The typed representation of primitives, Arrays and references is described in L1/L2; it does not require turning each primitive into a separate Structure.

An **empty Structure** is a present value with zero fields. It differs from an absent argument and from numeric zero. An explicit empty vertical body supplies the same empty argument as `()`; its notation is defined by the [empty-body rule](LMX_grammar.en.md#empty-colon).

<a id="identity"></a>
## 3. Identity and lexical relationships

A live value retains its physical identity: growing storage does not change the addresses of existing objects. Creating a copy creates distinct objects. Equal contents alone do not make two objects the same object.

A lexical parent determines a Structure's position in the lexical tree. A root has no lexical parent. Arena ownership and lexical ancestry are different relationships: transferring storage ownership does not by itself rewrite lexical links.

The `independent` qualifier constructs a Structure without an external lexical parent. Internal lexical links remain intact. This restriction on lexical dependence does not prohibit explicit arguments, dynamic call inputs or mutation of accessible mutable values.

<a id="fields"></a>
## 4. Fields and repeated occurrences

Field order is significant. When a source name occurs more than once, `name` selects its first occurrence, equivalent to `[0]name`; `[1]name` selects the second, and so on. The occurrence number of a particular name differs from the physical field index among all fields of a Structure.

Names serve source-level resolution. Execution uses resolved references and positions. Auxiliary names for textual lookup and diagnostics neither create values nor determine their identity.

A Structure's field count is fixed at construction. Updating an existing field replaces the reference stored in it. Constructing a different set of fields creates a new Structure; composition is defined in [section 6](#composition).

<a id="references"></a>
## 5. Value passing and mutation

A primitive argument is passed by value. Locally assigning to the argument inside a call does not change the calling expression's variable.

For a Structure or Array, the reference value is passed. Locally replacing that reference does not replace the caller's reference. Writing through a reference to a field or element changes the accessible mutable object itself; the change is visible through other references to that object within the local ownership context. Ordinary argument passing does not copy the graph.

Immutability protects the qualified value itself against mutation through any alias. Constancy of a variable holding a reference and immutability of its referent are different properties. Neither by itself proves the correctness of a value or an expression's behavior; candidate admission is defined in [section 7](#admission).

<a id="composition"></a>
## 6. Composition and graph copying

`merge` evaluates operands from left to right and constructs a result containing their direct fields in sequence, followed by the composition body's fields. Operand roots are not added as separate visible fields. Repeated names follow the [general occurrence rule](#fields).

The used graph is copied, including required data, references and lexical ancestors up to the root. Unknown use does not justify excluding potentially used parts. Source objects remain unchanged; references in the copy point to their corresponding copied objects.

One copying operation uses a single mapping from source objects to copies across all its operands. Repeated references to one source object therefore point to one copy; cycles are preserved as well. Mutating a copied mutable cell does not mutate its source cell.

Immutable method records and explicitly published eternal branches retain their addresses within one process. Ordinary immutability does not by itself declare an arbitrary object an eternal branch. Transferring ownership of existing storage is a separate operation and does not perform this copying.

<a id="admission"></a>
## 7. Analytical compatibility and candidate admission

The two admission conditions established in the opening serve different purposes. Analytical checking establishes conformance to the requirements of a use; the receiving expression's unit tests validate the candidate during execution. Establishing a primitive type, the presence of fields or a matching signature does not replace the second part of admission.

Analytical compatibility concerns the receiving expression's particular use of the candidate. One expression's requirements do not establish the candidate's suitability for all other expressions. Checking the available requirements does not certify unknown properties.

<a id="execution"></a>
## 8. Data and execution

A Structure's presence in the graph or in an argument position does not execute it by itself. The receiving expression determines how the supplied Structure is used. An executable body remains a value of the same structural language.

A callable Structure has its own identity and state. Multiple such Structures may use one immutable method record while retaining distinct own fields. Separate recursive calls have separate working values even when they refer to the same callable Structure.

A call targets the selected callable Structure. Its lexical parent and shared method record serve other roles and do not replace that Structure as the holder of the invoked expression's state.

<a id="publication"></a>
## 9. Working values and publication of changes

An executable body loads its used own fields into the current call's working values. A working value and its corresponding graph field may subsequently differ. An assignment actually executed on an own field's working value marks it as changed (`dirty`).

Before an outbound LMX call, body exit or suspension, only changed own values are published. A boundary with external code capable of invoking LMX or exposing state beyond the current call also requires publication. A successful field store clears its dirty mark. Publication does not imply rollback of completed writes upon a later failure.

Working values are not automatically reloaded after a nested call returns. An explicit graph path observes the current field, while the local working value retains its snapshot. If a nested call changed the field, the outer call's unchanged local snapshot must not overwrite that change on exit.

Ordinary formal and dynamic arguments do not become own fields merely by being passed. They follow the [value-passing rule](#references); publication applies to values bound to the body's own fields.

<a id="addressing"></a>
## 10. Addressing scales

Addressing follows the scale of interaction. At the intermediate level of local actors, an address is a physical memory address. It identifies the local recipient within the corresponding address space.

Starting at the third level of WorldWideMix organization, a chain of indices provides composite addressing. This is the level of remote links, including intermachine links. An index chain does not replace physical addressing at the intermediate local level.

Addressing scales and language levels L0–L3 describe different aspects of the system: the former describe the scope of interaction, the latter the program representation and available operations.

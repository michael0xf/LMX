# Author clarification: complete program graph, methods binary, zero-payload uninit, and graph assignment

Date: 2026-11-21. Status: accepted author clarification, incorporated into this documentation review.

This note records the author's direct answers during the review. It resolves the former physical-layout question P01. It has priority over older prose that reserves a future `T` value cell inside `uninit:T`, describes a nested `T` record, or treats execution as replacing written source forms with their computed results.

<a id="complete-source-graph"></a>
## 1. The clean graph represents the complete written program

The clean graph is a complete reflection of the source, **including terminal primitive leaves**. A terminal primitive is already represented in its own physical form, `{type value}`, at the address referenced by an `Lmx` structure cell. This physical encoding does not exclude that leaf from the source graph.

**All receivers remain as written.** This includes `for`, `if`, `merge`, `copy`, and `import`, together with their argument forms and nested structures. Construction and execution do not erase these receiver records and substitute their computed outputs into the clean graph. Namespace processing follows the receiver's ordinary contract; it is not an implicit rewrite of the source graph.

The complete graph is available for interpretation, inspection, explicit editing, and compilation. No separate persistent callable graph, expanded replacement graph, or hidden data structure is introduced to hold the missing parts of the program.

<a id="graph-and-methods-binary"></a>
### 1.1. The graph and the binary are the program representation

The clean graph's `parent` and `length` are determined logically from the source structure. The remaining contents of an `Lmx` structure are its array of pointers to the graph's constituent structures and primitive records. This describes the same complete source graph, not a partial graph supplemented by hidden program fields.

Alongside the graph is the binary containing the compiled native methods. **The binary contains methods, not a second store of the program's graph data.** No additional persistent program representation is introduced between these parts.

R0 is an ordinary C method with a **local pointer to the R0 graph**. Interpretation also operates using the binary: an interpreted program still has a binary R0. It does not need a separate binary-free startup model, a global replacement for that local graph pointer, or artificial DATA for the source root.

Ordinary execution frames, registers, and the already specified runtime services serve execution of this representation. They are not extra hidden parts of the user's program, and their existence must not be used to move source-defined state or executable forms out of the complete graph.

<a id="no-working-graph"></a>
### 1.2. Removing the working graph is the primary requirement

There is no second working graph for execution. Renaming it does not satisfy this requirement: an expanded execution graph, separate callable graph, graph-shaped namespace replica, hidden program-data graph, or automatic copy of the executable program at entry would still be a working graph.

Both the walker and compiled methods use the complete program graph and the ordinary current execution places. A frame may hold local values and bindings; it must not become a disguised reconstruction of the program graph. The rule is not satisfied merely by discarding such a reconstruction at the end of a call.

An explicitly requested `copy` or `merge` still creates the result prescribed by that operation. That ordinary graph value is not a licence to insert a second, implicit execution representation for every program or call.

<a id="private-without-marked-graph"></a>
### 1.3. `private` is read from that same graph

The receiver `private:` is present in the clean graph. The interpreter and translator can identify it there and apply its ordinary binding rules. The translator expresses those rules in the generated methods; it does not need to place a second graph of access marks in the binary.

An additional marked graph for privacy or equivalent source properties is a working graph under another name and violates the primary requirement. Keeping the visible `private:` record while actually relying on such a hidden graph does not satisfy source-graph completeness.

<a id="uninit-zero-payload"></a>
## 2. `uninit:T` has no value payload

`uninit:int` is itself a type code. An uninitialized primitive does not contain a value of its eventual initialized type:

```text
{uninit_int}             sizeof(value) = 0
{int 5}                  initialized integer record
```

There is no inner `{int ...}` record, no reserved `int` value cell, and no unspecified integer stored behind the `uninit_int` code. The same rule applies to other uninitialized type codes: their value payload is empty. A ready numeric zero and a ready null reference remain initialized values; neither is an encoding of absence.

The type-code family can contain the required uninitialized types. This rule requires no new wrapper representation or mandatory indirection mechanism.

<a id="frame-and-graph-assignment"></a>
## 3. Assignment in a frame and assignment to the graph

Assignment to a place in the execution frame changes that local runtime value. It does not change the source graph, initialize its corresponding source record, or replace an initializer in that graph. The local value may be held by the executor in an ordinary frame or register under the existing activation rules.

An explicit assignment to a graph place assigns a new graph fragment to that place. In the author's example:

```lmx
struct\novalue := 5
```

the selected structure cell changes from referring to `{uninit_int}`, which has no value storage, to referring to `{int 5}`. This is graph-fragment replacement. It is not a write into a previously allocated `int` value cell, and it carries no promise that a former raw record or value address remains the address of the replacement.

Two paths selecting the same structure cell see its replacement. Two distinct structure cells that happened to refer to the same old fragment are not thereby one assignment destination. Replacing one cell's fragment does not implicitly replace the other cell's fragment. Existing graph-copying rules for shared targets, cycles, and lexical parents continue to determine those relationships.

This clarification does not change the separate contracts for a stable `Lmx` descriptor or an L3 Array reference represented by descriptor and index. Those contracts are not a requirement to preserve a primitive payload address across graph-fragment replacement.

<a id="import-copy-merge-identity"></a>
### 3.1. Import, deep copying, and distinct receiving cells

The author further clarified that the grouping container and the copied lexical owner **have different cells**. This is a fixed relationship, not an implementation option expressed as “may differ” or “need not be identical.” Deep graph copying was already the intended meaning of merge.

| Operation | Graph material supplied | Method identity and owner |
| --- | --- | --- |
| `import` | References to the eligible original root constant declarations | Original declaration and original DATA/lexical owner are retained |
| `copy` | Deep copy of the used graph of one admitted source, emitted as fields | Copied method and corresponding copied owner, related through the operation map |
| `merge` | Deeply copied composition of the admitted sources, emitted as fields | Copied method and corresponding copied owner under one common composition map |

The established retention contracts for reusable native implementation references and properly qualified `independent: immutable` branches remain in force. The mutable owners in the examples are copied under the ordinary deep-copy contract.

An explicit group collecting any of these streams is a distinct Structure with its own storage cells. Its cells refer to the emitted original or copied material. They are distinct from the referenced owner's cells; grouping does not reparent a method or deep-copy the emitted graph again.

Replacing a group's slot changes that slot. A state write intended for the method follows the method's actual DATA or lexical-owner link and changes the selected slot there. Shared references inside the result keep their ordinary meaning: if both routes lead into the same nested Structure, they can select that nested Structure's same cell. Distinct outer containers do not imply independent copies of every reachable target.

<a id="receiver-replacement"></a>
## 4. Executable structures can also be replaced

The graph structures representing receivers and their arguments can be replaced with other graph fragments. There is no special unreplaceable representation for `for`, `if`, `merge`, `copy`, or `import`; their presence as executable forms does not prevent graph editing.

Where an edit requires rebuilding the machine implementation, use the existing [explicit compilation and endturn mechanism](../LMX_semantics.en.md#explicit-compilation). Prepare the required update by explicit compilation, then pass through the specified `endturn` boundary so that the subsequent entry uses that update. Graph assignment does not introduce automatic native invalidation, and `endturn` alone is not a new implicit compiler.

The existing rule for execution before the update boundary is retained. This note introduces neither a mandatory snapshot of executable code at call entry nor a new promise about the result of running stale native code before the specified update sequence completes.

<a id="regression-obligations"></a>
## 5. Required regression observations

1. Inspect an uninitialized primitive leaf and confirm its type code and zero value-payload size. Reject an implementation that reserves a hidden future `T` cell or nests a `T` record there.
2. Assign the corresponding local place during execution. Observe the new frame value and verify that the source record remains uninitialized.
3. Explicitly assign the graph field. Observe the new `{int 5}` fragment at that structural place without requiring old/new raw address equality.
4. Distinguish uninitialized `int` from initialized `0`, and an uninitialized reference from an initialized null reference (`0`). `nil` denotes typed absence under the existing receiver contract.
5. Inspect the source graph before and after ordinary execution. Written `for`, `if`, `merge`, `copy`, and `import` receiver forms and their argument structure remain present; terminal primitive leaves are present in their typed representation.
6. Explicitly replace a receiver structure with another fragment. Inspect the edited graph. Where the change requires a machine update, compile the relevant unit and cross `endturn`; check the next entry against the edited program.
7. When a copied field stream is collected into a new grouping container, verify that the group and copied lexical owner are distinct Structures with distinct cells. Replacing a group slot leaves the owner's corresponding slot unchanged. Use the actual owner when a write is intended to change a copied method's DATA or lexical state. For import, verify original declaration/owner identity; for copy and merge, verify the corresponding deeply copied graph relationships.
8. Inspect the generated program representation: graph contents remain in `Lmx` structures and primitive records; the binary contains the native methods. Verify that binary R0 uses a local pointer to its R0 graph and is also present for interpreted execution. Do not introduce hidden source-data tables, a second callable graph, or a separate interpreter-only program representation to satisfy this check.
9. Trace both interpreted and native execution and verify the absence of a second working program graph, including a renamed or per-entry reconstruction. Local values, binding metadata, and explicit user-requested graph copies are checked by their own contracts; none may silently substitute for the complete program graph.
10. Use a source `private:` receiver as a concrete control: its implicit-binding restrictions and allowed explicit accesses follow the existing receiver contract in both execution paths. The receiver remains in the clean graph, and no additional marked graph in the binary supplies its meaning.

No author decision remains pending on the former P01 question. Older anchors named `uninit-layout-conflict` or `uninit-record-control` may remain as stable links, but their content must state this resolved rule.

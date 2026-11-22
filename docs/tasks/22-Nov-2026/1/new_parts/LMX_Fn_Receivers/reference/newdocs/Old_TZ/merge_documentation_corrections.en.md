# Composition and graph-copying requirements

**Status:** applied documentation requirement, reconciled with the 2026-11-21
[field-stream requirements](../TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md).
The [composition contract](../LMX_semantics.en.md#composition) and
[L2 copying mechanics](../L2_spec_en.md#copy-merge) define implementation behavior.
This note records required behavior rather than a report that a build passes it.

`copy` accepts exactly one admitted source; `merge` accepts two or more; `import` accepts one or more. All three always consume ordinary CODE arguments, including when a DATA context accepts their output. Copy and merge emit result fields; import emits selected root constant declarations by original reference. Source arity follows ordinary W/E selection in every placement: one written Structure may expand to several admitted sources. Bare Structure references and anonymous groups are values, not implicit calls. An explicit `Producer()` is called when its argument is consumed, without eager P0 execution or source-graph replacement.

The operation's current receiving Structure is never an implicit source or model. `Struct: merge(A B)` is an
ordinary Structure declaration whose namespace consumes the stream of `merge(A B)`; A is that merge's model.
Separate merge/copy operations in one DATA body retain separate copy maps and ordinary DATA collision handling.
Only the arguments of one merge participate in its model-slot overlay. `merge(A B)` and `merge((int: x 1) (int: y 2))` both use the common CODE argument algorithm; anonymous Structures need no separate DATA-argument receiver form. A container is not itself a call, but its contents can contain explicit calls or initializers; grouping does not suppress their ordinary processing or force an eager initializer pass.

Explicit grouping expresses one structural result: `(copy(A))`, `(merge(A B))`, `return: (copy(A))`, or a compatible
reference assignment `result := (merge(A B))`. Without that group, the receiver emits fields for its ordinary
consumer. A group at an argument boundary still participates in CODE W/E; named supply to a real formal,
`f(arg0 := (copy(A)))`, passes the whole Structure without E.

Import preserves original eligible declaration and owner identity. Copy and merge deeply copy
the used graph, including required lexical owners, through their common operation map. The
explicit grouping container has its own storage cells, distinct from the copied owner's cells.
Replacing one container's slot does not replace the other's slot. Shared references can still
lead to one nested Structure and therefore to the same slot inside that nested Structure.
Grouping introduces no second deep copy and does not become a received method's lexical owner.

The essential copying guarantees remain:

- One common source-to-copy map spans every source of the operation. Shared targets and cycles are preserved;
  ordinary references and parent links point to corresponding copies, including needed lexical chains.
- A mutable method occurrence and its environment are graph material. Reusing a compatible native implementation
  address is not permission to retain a mutable source occurrence or bind it to unrelated data.
- A properly qualified independent: immutable branch retains its original physical reference under the existing
  preflight, ownership, and lifetime contract. Additional const is allowed but is not required for this retention.
  Independent alone, immutable alone, and a null parent alone are insufficient.
- Copying does not bind formals, capture a live caller frame, or override binding priority. Explicit node paths
  retain lexical meaning; the stream recipient does not redefine node.
- A copied data declaration such as int: y 5 may provide the actual candidate's ordinary default.
  Fn comparison does not copy defaults from a signature template, and explicit zero is not omission.
- The existing source domain, including admitted reference Arrays, and native implementation reuse remain in force.
  Copying does not trigger compilation or register a new native implementation.

All written receivers remain in the source graph. Computation, merging, filtering, grouping, and DATA acceptance
happen in the namespace; terminal primitive declarations remain part of the complete source in their direct
`{type value}` representation at the address held by the Structure cell.
A read of an original receiver path neither executes it nor exposes an automatically substituted output container.
Explicit program writes keep their normal contract.

The [follow-up decision index](merge_documentation_corrections_next.en.md) explains how the surviving earlier
decisions fit these current rules.

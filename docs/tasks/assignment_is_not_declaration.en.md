# Assignment is not declaration

**Status:** applied documentation requirement, reconciled with the accepted rules through 2026-11-21.
The directory name Old_TZ does not make its surviving contracts optional. This revision states the current rule;
it does not claim that a runtime or native/walker test has passed.
See [assignment](../spec/LMX_semantics.en.md#assign-known),
[binding](../spec/LMX_semantics.en.md#binding-places), and [addressing](../spec/L2_spec_en.md#lowlevel-address).

An assignment updates an already resolved place. It creates no declaration or second field, and executing it
does not implicitly replace its own receiver record. All receivers remain as written; computations and
transformations occur exclusively in the namespace. Terminal primitive declarations are represented directly
as `{type value}` at the address referenced by their Structure cell and remain part of the complete source graph.
This does not permit evaluation of an arbitrary initializer during graph construction.

An explicit graph assignment can replace any selected source structure, including a `for`, `if`, `merge`,
`copy`, `import`, or assignment receiver. There is no special unreplaceable executable representation.
Where a replacement needs recompilation, use the existing explicit compile/endturn restart boundary.

The write target is determined by the ordinary binding contract:

- An explicit ordinary actual, autofill, or preserved fallback supplies an own namespace place; writing it does
  not write back to its source.
- Transparent binding of a free name to a caller local uses that actual place; a write changes it immediately.
  This is neither publication nor copy-out on exit.
- An explicit graph assignment replaces the fragment at its selected structural place subject to the applicable
  type, const, immutable, ownership, and lifetime rules. A typed machine-storage dereference retains its own
  ordinary storage-write contract.

Thus a bare assignment to an outer name y does not create a field `M\y` in the method's source Structure.
A native hidden pointer transports a selected logical place without adding a pointer level to y's LMX type.
Address-taking selects that place's real storage and does not extend its lifetime.
An uninitialized graph leaf has no T-value storage to address: `uninit:T` is its type code alone,
with `sizeof(value) = 0`. `struct\novalue := 5` replaces that graph fragment with `{int 5}`;
it does not retag or preserve an already allocated raw T cell. Frame-local assignment still
leaves the source graph unchanged. [Latest author clarification](LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md).
Reserved node remains lexical; it is not a synonym for a dynamically selected namespace or the current stream
recipient. Explicit `@Structure` is a numeric address, not a request for a copied descriptor.

Declarations and assignment remain distinct. A reached same-level CODE redeclaration uses the existing place:
a new RHS is evaluated and admitted, while absence of a new RHS preserves its current value. A real nested
declaration shadows with a distinct place. In DATA, repeated declarations remain separate occurrences selected
by `S\[N]field`; a bare path is ambiguous when more than one occurrence matches.

The former argument-to-own-field promotion, load/cache/dirty publication, shared direct-access cache, and flush
are withdrawn. Message publication and explicit graph mutations keep their own contracts. Import and DATA
acceptance of copy/merge streams do not mutate the clean source graph. All three receivers always consume ordinary CODE arguments, including in DATA placement; this does not call bare references or anonymous Structures.
[Current frame contract](../spec/LMX_semantics.en.md#call-frame-20261115),
[field-stream requirements](LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md).

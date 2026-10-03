# Namespace source layout: connected next slice

Status: implementation plan, **not an accepted fix**. Read-only audit of the
current sandbox follows full harness `critical_graph_fix_full_15` RED175/1297.
No stable twin has been changed. This is part of
[critical_graph_bug](tickets/critical_graph_bug.md), before the pointer repair.

## 1. Existing object, original order

For `Holder: (int: x 1; x: 2; int: y 3)` the current namespace constructor
reserves two declaration cells before its executable steps:

```text
actual:   [x-cell, y-cell, INIT(x,1), SET(x,2), INIT(y,3)]
required: [x-cell, INIT(x,1), SET(x,2), y-cell, INIT(y,3)]
```

Both have width5; exit-only tests cannot distinguish them. The existing
namespace object must become the shared source container. There must not be
a second object containing either its data or a reconstruction of its body.
Construction fills declared initial values but does not execute `x: 2`.
An explicit invocation executes the stored body by the ordinary dispatcher.

`l2_ns_procs` currently creates source/procedure bookkeeping only for root
definitions that are called, have statements, or belong to a part. Registration
for source construction must not depend on whether someone calls a definition.
The bookkeeping does not give an ordinary Structure a signature or arguments.

## 2. Distinct compiler coordinates

Keep these concepts separate in translation-only adapters:

| Operation | Result |
| --- | --- |
| `ns_named_row` | Selected global NSF row, using LAST or explicit `[N]` |
| `nsf_ordinal` | Declaration ordinal within that row's owner |
| `nsf_slot` | Actual physical child in the existing source container |
| `ns_row_at_slot` | Valid child plus its NSF row, or valid unnamed child |

For a source-owned namespace, project by original P0 token identity, not by
spelling or model equality: `nsf_fname == own_name`, then its existing
`L2SourceField.slot`. An absent/duplicate mapping is an implementation error,
not permission to substitute a dense ordinal. Unnamed source operations remain
valid physical children. They are not missing named fields.

The old genuinely dense constructor may use declaration ordinal until it is
migrated; its producer must be explicit. Do not change a helper's coordinate
meaning silently depending on `rw_emit`: PLACE also has `rw_emit=0`.

`l2_ns_field_ix` already returns a **global NSF row**, used to read kind/ref;
it must not be changed to return a child slot. Factor its lexical selection
through the same selected-row resolver. `l2_ns_ref_pointee` currently selects
the first independent spelling match; it must use that same LAST/`[N]` row or
the selected cell and its model can disagree.

## 3. COUNT, PLACE, FILL

CHECK and initial COUNT validate names/types from selected NSF rows. Root
COUNT precedes the appended namespace procedure COUNT, so it cannot require
the future physical child3 of `Holder\y` before that layout exists.
PLACE/FILL use the completed physical projection after all source counts.

The current implementation rebuilds path tuples, inline maps and pending-call
caches each pass; it does not persist those initial ordinal constants into
FILL. Construction edges are recorded in phase1 only. Merge source-coordinate
rows **do** persist: retain `l2_mrs_rebuild_all` after final PLACE/binding.

For the common source body, header width is0. Native lowering may have ordinary
machine temporaries, but must not create a signature header in the Structure.
Its real return trailer must come from its original namespace frame:
`l2_rw_trailer` currently checks only `m_node`, which is0 for namespace
procedures. A named `until` currently borrows a synthetic loop wrapper;
source ownership must not identify that wrapper as the author's original body.
That loop boundary requires connected handling, not simply removal of a guard.

## 4. One constructor per actual field

Choose one actual cell/object constructor for every source-owned declaration.
Reusing the existing NSF constructors is possible, but shared source allocation
may skip a field only when it proves all three facts:

1. The namespace is that own row's owner.
2. NSF and own metadata retain the identical original declaration token.
3. That existing constructor really fills this projected child.

Use the same proof in `l2_source_cells_emit` and `l2_source_fields_emit`.
An own declaration inside IF/FOR has the same method but no top-level NSF row;
it must still be constructed. Nested/callable NSF fields must reuse their real
already-created objects, not clone them again in the shared source-field pass.
Unnamed atom rows have no named own-token match and need their real source
occurrence-position producer; do not compress them into a declaration prefix.

Existing constructor holes remain defects: `l2_emit_one_nest` counts some NSF
kinds without emitting their cells. Changing its counter cannot silently hide
those holes or pretend to implement the absent constructors.

## 5. Connected consumers

Current symbols are in `dev/l2src_sandbox/l2trans.lm1`; anchors are deliberately
symbols rather than mutable line numbers.

- Physical paths/publication: `l2_ns_field_in_parent`, `l2_own_mslot`,
  `l2_ns_slot_named`, `l2_emit_path_to`, `l2_emit_actual_path`, `l2_rw_path`,
  and emitting `l2_cap_add`.
- Physical inverse: `l2_ns_field_kind`, `l2_ns_field_len`, `l2_ns_field_ref`.
- Metadata-only validation: `l2_path_in_eternal`, `l2_path_contract`,
  `l2_path_arr_leaf`, `l2_rw_index_ty`, validation-only `l2_cap_add`, and
  consumer interface/admission checks.
- Constructors: global NSF leaf/reference passes, `l2_emit_one_nest`,
  `l2_emit_local_ns`, `l2_emit_method_fields_at`, `l2_emit_method_atom_at`,
  `l2_rw_atom_ns`, and `l2_emit_ns_names`.
- Schema/copy: namespace `l2_schema_field` enumerates physical children;
  `l2_schema_placed` must not project a namespace twice. Method schemas keep
  their declared-own ordinal and existing method projection. `l2_mrs_take_entry`
  scans physical source order, not named fields followed by a code suffix;
  `l2_msrc_fld` must hold the real copied source child.

## 6. Required evidence

Add a full width5 Holder shape oracle, including parent ownership, real int
cells, and SET/OWN/LIT operand order. Initializer SET has source facet1;
assignment SET has facet0. OWN addresses actual children0 and3. No method
signature is added. Names are published on real declaration places, not on
the initializer/assignment nodes.

The runtime witness reads `Holder\x=1`, `Holder\y=3` before invocation and
`2,3` afterward, through native and genuinely forced-interpreted execution.
The ordinary Structure invocation is EXEC, not a METHOD-style CALL. Pin its
target identity instead of using a CALL-only oracle.

Independent controls:

- A dormant Holder with positive constant entry7 isolates a nested source-order
  mutation; moving its y-cell into the old prefix must fail shape while keeping
  the observed program result. A runtime witness may also fail because its y
  address changed: that is useful, but not an isolated oracle control.
- Redirect y's name/path/schema to ordinal1: the runtime witness must reject it.
- Repeated `int: x 1; int: x 7; x: 2`: LAST and `[0]x` select distinct cells.
- `copy: merge Holder`: copied source order, projected y, isolated mutation,
  and operation operands remapped to the copy's actual cells.
- Called and uncalled pure-data definitions retain the same topology.
- Return and named-until boundaries retain their actual source occurrence.

Run fresh focused harness evidence first, then a full harness and ordinary
kernel/L3 gates on final bytes. None of this research closes either ticket.

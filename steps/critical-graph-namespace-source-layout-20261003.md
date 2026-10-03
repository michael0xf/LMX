# Namespace source layout: connected next slice

Status: connected layout implementation plan, **not an accepted fix**.
The latest completed full harness `critical_graph_fix_full_19` is RED174/1314
on the earlier resolver-preparation bytes. The subsequent original-root namespace
source-order cutover is implemented but incomplete: cutover04 is RED7/32.
Its seven new rows pass; its two merge regressions are repaired by the subsequent
interface-reception slice (cutover06 GREEN31). Full current-byte acceptance is
still outstanding.
No stable twin has been changed. This is part of
[critical_graph_bug](tickets/critical_graph_bug.md), before the pointer repair.

## 1. Existing object, original order

Before this cutover, the namespace constructor for
`Holder: (int: x 1; x: 2; int: y 3)` reserved two declaration cells before
its executable steps:

```text
actual:   [x-cell, y-cell, INIT(x,1), SET(x,2), INIT(y,3)]
required: [x-cell, INIT(x,1), SET(x,2), y-cell, INIT(y,3)]
```

Both have width5; exit-only tests cannot distinguish them. The existing
namespace object must become the shared source container. There must not be
a second object containing either its data or a reconstruction of its body.
Construction fills declared initial values but does not execute `x: 2`.
An explicit invocation executes the stored body by the ordinary dispatcher.

Before this cutover, `l2_ns_procs` registered root definitions selectively.
It now registers ordinary original root definitions independently of invocation.
Local, qualified and synthetic named-UNTIL producers are still separate migration
debts; the original-body identity test does not pretend to migrate them.
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

`l2_ns_field_ix` returns a **global NSF row**, used to read kind/ref;
it must not become a child slot. It and `l2_ns_ref_pointee` now share
`l2_ns_named_row` with LAST/`[N]` selection. The old independent first-match
model lookup is removed. `l2_nsf_ordinal` explicitly identifies the current
dense producer, not a fallback for a completed source-layout map.

## 3. COUNT, PLACE, FILL

CHECK and initial COUNT validate names/types from selected NSF rows. Root
and method traversal must not require the future physical child3 of `Holder\y`
before all source layouts exist. The minimal root-namespace fixture currently
registers Holder as method0 and the entry as method1; ordinary fn rows can
precede namespaces, and discovered local procedures can be appended later.
Do not rely on one fixture's registration order as a layout guarantee.
PLACE/FILL use the completed physical projection after all source counts.

The current implementation rebuilds path tuples, inline maps and pending-call
caches each pass; it does not persist those initial ordinal constants into
FILL. Construction edges are recorded in phase1 only. Merge source-coordinate
rows **do** persist: retain `l2_mrs_rebuild_all` after final PLACE/binding.

`l2_rw_admit_project` also invokes `l2_rw_map_inline` during COUNT. That
helper computes physical D105 correspondence cells but creates no rw temp
or owning edge. Defer only that physical-map computation in construction
phase0; retain model/type resolution and normal frame counting. PLACE and
FILL must compute it from the completed layout. `rw_emit=0` is not the
boundary, because non-emitting PLACE still needs real coordinates.

For the common source body, header width is0. Native lowering may have ordinary
machine temporaries, but must not create a signature header in the Structure.
Its real return trailer comes from its original namespace frame through
`l2_callable_source_node/frame`, shared by CHECK, graph and native emission;
bounded evidence is below. A named `until` currently borrows a synthetic loop wrapper;
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

Skipping an existing typed-cell allocator must not lose its external name:
`l2_emit_cell_new` publishes on the actual typed cell at `slot[0]`, whereas
`l2_emit_ns_names` now publishes on both the owning reference slot and the
already-created typed value cell where applicable, without allocating another
cell. Borrowed Structure/callable aliases still name their own place,
not their shared referent.

Existing constructor holes remain defects: `l2_emit_one_nest` counts some NSF
kinds without emitting their cells. Changing its counter cannot silently hide
those holes or pretend to implement the absent constructors.

## 5. Connected consumers

Current symbols are in `dev/l2src_sandbox/l2trans.lm1`; anchors are deliberately
symbols rather than mutable line numbers.

- Physical paths/publication: `l2_ns_field_in_parent`, `l2_own_mslot`,
  `l2_ns_slot_named`, `l2_emit_path_to`, `l2_emit_actual_path`, `l2_rw_path`,
  and emitting `l2_cap_add`.
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

### 5.1 Audited name/path call sites

The audit found eight name/path selection consumers. Four metadata calls now
use `l2_ns_named_row` directly; four producer calls still use `l2_ns_slot_named`.
The selected NSF row carries kind/model metadata; a physical slot is needed
only by a completed-layout consumer.

| Consumer | Required coordinate |
| --- | --- |
| `l2_path_in_eternal` | Selected row: existence/kind/model only |
| `l2_path_contract` | Selected row: type/model only |
| `l2_emit_path_to` | Projected physical child |
| `l2_path_arr_leaf` | Selected row; count comes directly from `nsf_val` |
| `l2_emit_actual_path` | Projected physical child |
| `l2_rw_path` | Split metadata resolution from physical production |
| `l2_rw_index_ty` | Selected row: type only |
| `l2_cap_add` | Selected row for validation; projection for emitted capture list |

`l2_rw_path` serves metadata callers (`l2_src_path_write`, `l2_rw_opty`,
`l2_rw_span_ty`, `l2_rw_index_ty`) as well as actual path/address/index
producers. Expose distinct resolution/projection entry points. Neither a
bare `rw_emit` check nor substituting an ordinal for a missing physical map
defines that distinction. Physical D105 edge/width projection also belongs
only to the completed-layout route.

The two CHECK capture callers discarded local `capf[32]` arrays; those arrays
are now removed and validation explicitly uses `out=0`, no capacity. The actual
capture-list consumers remain `l2_mad_cap_emit_walk` and `l2_mad_cap_emit`.
At that preparation checkpoint the physical capture list still used the
explicit dense-producer adapter. After the connected source-layout cutover,
actual capture emission uses the projected physical slot, as verified below;
metadata-only CHECK remains non-projecting.

`l2_path_arr_leaf` now reads count/kind directly from its selected NSF row.
Dead `l2_ns_field_len`, `l2_ns_field_kind` and `l2_ns_field_ref` accessors are
removed. Metadata-only `l2_path_in_eternal`, `l2_path_contract`,
`l2_rw_index_ty` and validating `l2_cap_add` use the selected row. Actual
emitters still use the old physical producer. The mixed `l2_rw_path` route is
now split as described below; completed source projection remains connected
cutover debt.

<a id="ns-metadata-evidence"></a>
### 5.2 Metadata-selection prerequisite evidence

Fresh `critical_graph_ns_metadata_selection_02` is **RED2/16**, source SHA256
`EE290DF836B0D178B98D268D1357343B523FC718BB1275F0F56E86C23D9EB0DF`,
executable SHA256
`DB1A4853C1BA884D542A70B015904735B8C20642FE63F555D53DBBCF7236F82D`.
The positive dormant reference-contract witness passes16 checks in native and
cleared-root modes; both opposite-field negative witnesses refuse with the
correct unknown-field diagnostic. They do not dereference null references and
do not certify the future physical layout. Existing repeated declarations,
merge, named Structure execution, reference reception, sizeof, cast graph,
pointer graph and raw-C graph rows pass. Both failures exactly match full16:
`unit_ns_ref_field_general` and `unit_cache_struct_ref` lack the reached
method-local Structure constructor. No expectation is waived. `_01` failed
L1 parsing at an accidental multi-level dedent in the new helper; `_02` fixes
the helper's source layout without changing the parser. Failed evidence stays.
Full17 on these bytes completes **RED174/1305**, executable SHA256
`816E0410EB2ED0B8105C55FD6C19206CC3ACE6936E811A3D0BA5E9A3E706C712`.
All three new rows pass; independent full16/full17 comparison finds no shared
outcome change, removed row or failure-detail change. The two extra diagnostic
lines are the new expected opposite-field refusals. This is a frozen
metadata-only certificate, not a test of the following trailer edits.

### 5.3 Connected path-resolution boundary

There are ten operational `l2_rw_path` callers: four type-only callers above,
and six producers (`l2_rw_path_read`, `l2_rw_path_write`, `l2_rw_indexed_path`,
`l2_rw_length_of`, `l2_rw_path_reference`, `l2_rw_address`). `say=0` means
diagnostic silence, not metadata: `length_of` immediately builds a value
operand. Keep shared lexical resolution with explicit metadata/producer
entry points; thread that choice through `path_occ`, `path_bodies` and a
resolution/projection adapter for `l2_node_seg`, not only the namespace branch.

A selected own ID establishes field existence even before it has a physical
slot. Metadata must not query `l2_graph_field_child` or compute
`l2_m_width(host)+formal` to establish existence. Kind15 remains a body ID;
kind16 remains an own ID. The actual operand producer projects these semantic
handles through the real graph place. Preserve method-use checks and source
occurrence selection. Physical D105 offsets apply only to completed layout.
Producer COUNT still traverses graph-place ancestry to count its AT/OF
operation topology; this is not the same as a type-only metadata resolver.

The initial registration proof (`l2_ns_proc_add`) and layout seed
(`l2_layout_owns`) are the only `l2_own_mslot` consumers. Their namespace route
may use exact NSF-row identity plus an explicit declaration ordinal; they do
not need the future physical projection and must not recursively read the
GraphField relation while creating it. Actual emission later uses GraphField.

The explicit resolver split is implemented and verified by the preparation
scope below. `l2_rw_path_meta` and the existing producer
`l2_rw_path` wrap one `l2_rw_path_resolve(project,...)`; that mode continues
through `path_occ`, `path_bodies` and `l2_node_seg_resolve`. All four type-only
callers use metadata; all six operand producers keep physical mode, including
non-emitting COUNT. Own/formal/NSF rows establish metadata existence; the
D105 physical half-offset is producer-only. `l2_path_contract` now uses the
metadata node resolver instead of substituting child0 for an unplaced field.
No emitted layout is intentionally changed by this preparation. Physical
projection's missing-map handling remains a cutover obligation, including
the hidden-input fallback producer `l2_rw_arg_fb`; it may not turn a missing
projection into a size_t(-1) operand or a different fallback.

`l2_rw_map_inline` now defers only construction phase0's physical map
resolution and its projection-boundary check. ADMIT's extent/count and
map offset advancement remain outside this helper and unchanged. PLACE
(`rw_emit=0`, phase1) still resolves and checks the table; FILL writes the
same constants. Consumer/schema checks are not waived. This preparation
does not remove the older fixed-capacity map buffers; that separate bounded
implementation debt remains, and no arbitrary size limit becomes a norm.

Namespace source registration must prove an original declaration, not just
nonlocal parent flags: receiveMessage's generated letter model also has an
NSF entry whose `ns_at` is the receiver statement. The ordinary declaration's
original `ns_name == ns_at.frame.head` token identity distinguishes it without
name-specific rules; part roots keep their explicit existing producer.
Registering all real dormant definitions also cannot demand a type for the
retained unknown atom in `A: b`. Source-atom construction must share its actual
original-node/NSF producer identity with traversal and executable analysis,
without interpreting that inert symbol as an unresolved dynamic input.
Neither a generated letter tail nor a second data graph is a source body.

An existing constructor classification collision also requires care:
anonymous retained atoms use NSF kind12 with no `fname`, but the old reference
depth encoding can produce kind12 for a named depth3 pointer. A numeric kind
range does not prove a cell was constructed. The ownership proof must establish
the actual source/constructor contract, including anonymous atom identity;
missing higher-depth reference constructors remain defects, not prefilled cells.

<a id="ns-projection-preparation-evidence"></a>
### 5.3.1 Resolver/map preparation and generic order mutation

Fresh `critical_graph_ns_projection_preparation_02` is **RED11/56**, source
SHA256 `1A09F18E89BE6DCFCEF49C372A647C05B71E760B1D063D8CB54542E86FE86B51`,
executable SHA256
`50D0E9F718FF43EE22E1CA5DD729D4F194AE28214B79DB9B2831A61B503D6FEB`.
All eleven failures already exist in full18: six `unit_body_path_*_pt` rows,
`unit_capture_struct_own`, `unit_d105n_arg/write/passon`, `unit_d105r_formal`.
No shared outcome, failure detail or translator diagnostic changes. All35
overlapping successful generated L1 files are byte-identical to full18; three
other overlapping successes are expected refusals without generated L1.
This certifies preparation, not source-order namespace layout.

The generic driver `move-path-field` moves one actual reference inside the
selected existing container without changing its size, parent or value cells.
Its dormant positive carrier checks the complete IF/IF/trailer body, in
native-root and cleared-root modes (127/131 assertions, language exit7).
Both actual moves yield baseline1/setup1/shape_failures1/other_failures0/exit7.
The out-of-range setup control yields baseline1/setup0/setup_failures1/
shape_failures0/other_failures0/exit7, so setup failure is not defect detection.
The original called/forced-interpreted return witness is unchanged.

Preparation01 is retained **RED13/55**. Its two applied order moves also
damaged native body-holder lookup in the invoked task, causing invariant
exit3 before the final graph comparison. They did not meet the shape-only
same-exit control; no expectation was relaxed. Preparation02 uses a genuinely
uncalled carrier to isolate that control. Full19 on preparation02's frozen
sources completes **RED174/1314**, executable SHA256
`B70ED58979D811B72A4F2E4B23A84BEBC8C4CCB95BAC954D5BF32BA4D1E90BE7`.
All four added controls pass; no shared outcome or failure-detail change.
The already-failing `unit_walk_d105_nested` diagnostic loses its location.
This full snapshot does not certify the subsequent namespace cutover.

<a id="ns-source-trailer-evidence"></a>
### 5.4 Original namespace return trailer

`l2_callable_source_node/frame` selects the original method frame, or the
original namespace frame for a registered ordinary Structure. Both CHECK
loops, `l2_rw_trailer` and native `l2_emit_ret_tr` use that same selection.
The existing method-only `l2_fn_frame` contract is unchanged. No signature,
runtime metadata or companion graph is introduced; named UNTIL's distinct
source-boundary debt remains open.

`critical_graph_ns_source_trailer_02` is **GREEN15**, source SHA256
`B712672334B56BF9C1921B04F85EBFE226818830381C09145237E7B00E0F7990`,
executable SHA256
`58D9EF0DE905D49AFAD5BF5858142E51B108FF3B86A65C1E28CE5850B1ECB0AF`.
The Counter witness checks its complete width4 source container and root
width6 (354 assertions), actual initial value1, explicit invocation changing
only its real x-cell to2, and positive result7. Two positive rows exercise
native/cleared-root execution with Counter native, and native/cleared-root
execution with Counter genuinely interpreted by `--walk-methods`. Two real
RET-erasure mutants preserve native result7 but fail the graph assertion.
Column-0 `return: 1` on a void Structure is refused by the ordinary return
contract diagnostic, not silently admitted. Previous return, named execution,
UNTIL, cast and reference-contract rows pass. `_01` had only an incorrect
negative diagnostic expectation (`unsupported body`); refusal itself was
correct. Its evidence is retained. Full18 on these bytes completes
**RED174/1310**, executable SHA256
`F17D7448A8520C365C4D6C8D5E39470E4D30C8FA7F228392E8851DACC35E5E47`.
All five added rows pass. Independent full17/full18 comparison finds no shared
outcome change, removed row or failure-detail drift; the sole added diagnostic
is the expected valued-return refusal. This is not evidence for the later
metadata/producer split or phase0 map deferral. Neither this focused green nor
the full red closes either critical ticket.

<a id="ns-source-layout-evidence"></a>
### 5.5 Original root namespace source-layout cutover

`critical_graph_namespace_cutover_04` is **RED7/32**, source SHA256
`931F1F5F58D8CA079831F0E1209923920CB7F1BF9E606B19D01446C3C5C366DD`,
executable SHA256
`C223141DFA205912156FAA9151A1A5F1482D85FD73E7272BEFE33F3706740450`.

The existing namespace object now uses its original source-body container;
declaration rows resolve to actual source slots through original-token identity.
COUNT/CHECK use declaration metadata explicitly; PLACE/FILL, path resolution,
schema enumeration and final MRS tables use the physical source coordinates.
Already-constructed typed, nested and callable children are not allocated again.
The shared bounded-operand path also handles explicit `[N]name` native operands.
Primitive pointers beyond the old shallow spelling cases use the existing
type interner at the requested depth; no new depth cap is introduced.

All seven new namespace rows pass: ordered/repeated native and genuinely
interpreted bodies, dormant retention, the actual old-prefix mutant, and depth3
pointer construction. The mutant has baseline1/setup1/shape_failures2/
other_failures0/exit7. Five existing method-Structure producer refusals remain.
`unit_walk_d105_nested` again has its expected located refusal; nested admission
has not thereby been implemented.

Two existing rows regress from full19 success to genuine native and cleared-root
runtime failure: `unit_merge_value_schema` and `unit_merge_value_repeat`.
Their named-field pair coordinates are correct, but full reception attempts to
consume retained INIT applications as interface fields. A hole alone does not
identify an unused application: missing typed fields use the same sentinel.
The connected repair must project only existing OP-headed source applications
out of declaration/interface reception, preserve every real field requirement,
and leave the explicit physical Consumer used-tree predicate unchanged.
No name sidecar, second graph, new map sentinel or namespace-only exemption is
permitted. Native and walker selected-map/fallback receptions share that repair.

No full current-cutover verdict or `@Structure` repair is claimed. These real
merge regressions cannot be waived as stale oracles. Both critical tickets remain
open. The subsequent evidence below repairs this bounded regression; it does
not certify all remaining producer and reconstruction routes.

<a id="ns-interface-reception-evidence"></a>
### 5.6 Shared interface reception, without comparing source algorithms

`lmx_implements_walk_project` is the common operation-local DFS. Its explicit
interface projection ignores only a Structure whose first child is in the
already registered OP address domain. No source name or extra metadata is
needed. `lmx_implements_receiver_view` requires all remaining actual fields;
its hole policy is strict. The existing public `walk_view`/`runtime_implements`
used-tree predicate retains its physical Consumer contract, and sparse-through
retains its separate proved-unused-hole policy. Plain nested Structures,
typed cells, unknown cells and nested cached holes are not silently admitted.

Native and walker selected-map and unknown/cached-layout receptions, Thread
receive and root payload reception use that one interface adapter. No parser
change, namespace exception, signature redesign, auxiliary graph or new source
map is introduced.

`critical_graph_namespace_cutover_05` is retained **RED7/37** on source SHA256
`CD71E46D00E005C3F4ECE481AB0B23E8C40F7AE5D1368C6779BF2AAFC329FA00`,
executable SHA256
`A2916DCC2E5FCB084A86B8D496471C592E0B1378394343DA8BDA4ECF31CC4524`.
Relative to04, only the two shared merge rows change FAIL to OK. Their own
methods are genuinely interpreted under `--walk-methods`; both native-root
and cleared-root runs return7. All seven new namespace rows still pass.
The depth3 oracle now checks the actual IMPLICIT facet and typed-null literal
write, not merely an opaque SET (193 assertions).

Of the five added selected rows, three wrong-value/shape receptions still stop
with the expected `implements` throw. The compound-reference arithmetic refusal
already existed in full19. `unit_site_layout_failure` did not execute in05
because its generated-root index assertion was stale: ordinary registration
moves the actual root from3 to8, without changing the tested methods0–2.
Correcting that exact index yields the later positive runtime witness; no
expected refusal, store/provenance assertion or walk forcing was removed.

`critical_graph_namespace_cutover_06` is **GREEN31** on that same translator
source, executable SHA256
`33A772D794031F7C1B52BD3287A1D811C91919A9296EB6B6F369270D41EC3D78`.
This bounded set includes the seven namespace rows, genuine old-prefix mutant,
both repaired merge rows, source trailers, restored located nested refusal and
strict failed store/provenance/runtime receptions. The six earlier legacy or
unrelated translation refusals are retained as separate debt in05, not changed
to success or deleted from the full harness.

Fresh ordinary kernel `build/l2src/critical_graph_namespace_interface_01` is
**GREEN290**, all107 selftest rows executed. `lmx_runtime_implements_selftest`
runs67 checks with zero failures: twelve added checks distinguish interface
projection from explicit used-tree checking and exercise required field holes,
real type mismatches, unknown/unset cells and ordinary nested Structure fields.
Existing cached partial/capture/nested-hole admission witnesses still pass
(`lmx_walk_admit_selftest`:34 checks, zero failures). Fresh L3
`build/l3_selftest/critical_graph_namespace_interface_01` passes all11 suites
and four type-budget units (75/128 names, 1070/8192 name bytes). Full20 then
completed **RED252/1321**; its frozen result is recorded below, not superseded
by a focused green. Neither critical ticket is closed.

The five method-Structure refusals in05 still use obsolete implicit construction
forms such as `Other: o` and `Model: loc`. Do not restore that implicit merge or
delete its guard to make those fixtures green. Their legitimate setup must be
migrated explicitly under the existing K03 plan; use explicit-merge witnesses
to isolate the current producer and preserve the original evidence. Callable
capture from a tagged merge schema is a separate consumer debt, not permission
to invent a new data graph.

<a id="ns-full20-constructor-evidence"></a>
### 5.7 Full20 and the shared constructor/capture repair

`build/l2_harness/critical_graph_fix_full_20` is **RED252/1321** on source
SHA256 `CD71E46D00E005C3F4ECE481AB0B23E8C40F7AE5D1368C6779BF2AAFC329FA00`,
executable SHA256
`9097991C9E6DCFBB54B44615BE52175AE7A40B15807F65AFD5F255183607D1E9`.
Against full19, seven added namespace rows pass, one old nested diagnostic
failure resolves,79 shared green rows regress, and no row is removed. The79
include27 stale root pins,31 constructor failures, five previously expected
negative cases masked by those constructors, four real capture failures,
six exact namespace-shape mismatches, four merge-width assertions, one
repeated-model slot assertion and one obsolete native-projection pattern.
The root pins are method indices, not Booleans: update them only from the
actual frozen root installation. Retain exact field order, values, fresh-copy
identity, parent and native/walk assertions when migrating an oracle.

The general constructor fix stores the original declaration node in each
existing compiler NSF row (`l2_nsf_source0`, the `source` argument of
`l2_nsf_push`). `l2_ns_constructed_row` joins that identity to the original
direct body and owner, rather than reinterpreting an already transformed P0
shape. Nested fields, Arrays and borrowed callable fields reuse the one
existing constructor; source emission registers their actual physical places
before omitting duplicate construction. No runtime field, atom wrapper,
second graph or name-based constructor rule is introduced.

`critical_graph_namespace_cutover_08` is **RED20/94**, source SHA256
`FDAEFEA6D8E082D1DF045671D0EEB71CCC37B93D3D9CFBBA236443ACB19A9D12`.
This bounded set contains the79 full20 regressions, seven namespace controls,
strict reception failures, negative RHS witnesses and own-reference failure.
The constructor regression group and masked-negative group recover; strict
namespace/merge oracles retain their exact structural checks. This is not a
full-harness verdict.

The capture fix is the same selector for native and walked emission:
`l2_cap_add` uses `l2_nsf_slot(row)` for an actual capture list, never the
declaration ordinal. CHECK with `out=0` validates metadata without requiring
a completed slot. Missing physical projection is an internal error, not an
ordinal fallback. INIT applications are not captured in place of the declared
cells. The repaired locations are `[2]` instead of `[1]`, or `[0,2]` instead
of `[0,1]`; these are consequences of actual source order, not special fields.

`critical_graph_namespace_cutover_09` is **RED11/96**, source SHA256
`D50639AC7391E54A8C134CA10951805CD6987930CD2E5753BF27D0245FE7429A`,
executable SHA256
`39303332CCC3E47B60CAF984525C2DF5BC0B8DB4C44452DA8096CF9DAEC30157`.
It retains all08 selected fixtures and adds two Array/borrowed-method source
witnesses. All four previous capture failures pass, as do the corrected exact
own-reference and constructor-reception assertions. Eleven failures remain:
`graph_shape_method_ref`, `unit_eternal_shape`,
`unit_capture_struct_write_only`, `unit_capture_struct_write_root`,
`unit_array_index_formal_shadow`, `unit_field_path_struct_rebind_refused`,
`unit_matrix_path_struct_rebind_refused`, `unit_s7_nested_ok`,
`unit_s7_nested_shape`, and both `graph_shape_ns_source_constructors` rows.
Neither new Array witness is accepted: translation refuses the field-indexed
write. Their failure must not be hidden by removing the access assertion.

The copied-Point case exposes retained-graph loss in addition to its old
literal shape oracle: the legacy kind3 constructor copies Point before
original source INIT/body fields are filled. The copier follows lexical
parents and therefore copies the whole reachable closure, not merely Point.
Exit7 in both modes does not certify retention of that copied INIT. However,
`Point: box` is itself obsolete implicit-construction setup under the current
rules. Do not make a Point-only early FILL, a namespace-name topological sort,
or a new cyclic initialization protocol to restore that rule. Migrate the
fixture to valid explicit `merge`/reference construction under K03 first;
verify the complete original and actual copy independently. A valid producer
must copy a completed closure (holders/cells, edges, headers and source
bodies), not publish a partial object. The existing copier's handling of
cycles in a completed graph is distinct from inventing semantics for pending
legacy copy-result fields. The latter is not an accepted language feature.

No full gate has run on09 bytes; kernel/L3 interface01 certify only their own
earlier frozen slices. Both critical tickets and stable promotion remain open.

<a id="ns-explicit-copy-evidence"></a>
### 5.8 Pointer operand classification and valid explicit copy

`critical_graph_namespace_cutover_10` is **RED10/99**, source SHA256
`B54ADEBE9B5875338EE6734B071BBA33D13640A85CD51AD3DE0CBE2D4E7B036C`,
executable SHA256
`E404B0C944DCE6A1662614FFCE88AF7EC3DDCDB4EF6C102646AF0220E79720E9`.
The only shared outcome change from09 is `unit_array_index_formal_shadow`
FAIL to OK; three added raw-pointer index-expression/type/chain controls pass.
`l2_path_chain_check` now distinguishes actual structural paths from operands
with no structural step. `values[0]` is left to the existing pointer binding
and index route; a real `\field` path retains all its checks and projections.
No name-specific exception or new pointer semantics is introduced.

The old `Point: box` setup is not restored. A fresh translation-only probe
under `build/critical_graph_explicit_copy_probe_01` establishes the supported
explicit combination: method `copied: merge Point`, local Holder with
`@: Point point`, then ordinary `Holder\point: copied`. The subsequent
development fixture `graph_shape_method_explicit_copy.lm2` tests this combination
at runtime without using `@Point`/`@copied` before the pointer repair.

`build/l2_harness/critical_graph_explicit_copy_01` is **GREEN10**, on the same
B54A translator source and executable SHA256
`66DBDDCFAF4A44F12972B127CAE8984618144203B92DC5565A947655F1847409`.
The new fixture executes61 driver checks. Before the turn, Point has exactly
two source fields, int cell0 and source INIT at1 (SET opcode8, facet1).
Existing merge observations check the actual returned width2, initialized
int value1, distinct primitive cell, distinct non-null INIT and distinct OWN
operand. The test-only existing reentry observer captures this exact merge
return; it does not rebuild source or identify it by name.

The source writes the copy's x=9 and original x=11, then forces ordinary
interpreter dispatch on that returned copy: its retained INIT resets only
copy.x to1; original.x stays11. Holder's typed reference observes the same
copy. Writing copy.x=13 then calling the native original resets only
original.x to1. Language exit7 and the observed independent values pass.
The merged aggregate is already zero-native (logged before forced clearing);
this test does not require every aggregate result to inherit a native entry.
The native-original assignment is separately required by the harness.

This bounded slice also retains both repaired merge-interface rows, callable
merge/native lexical-parent witness,466-check native/walk namespace-order
twins and the actual old-prefix mutant with unchanged positive exit7. The
source SHA matches cutover10; executable hashes differ between fresh builds
and are recorded separately. Complete G4 body/name/comment reconstruction,
full final gate, stable promotion and both critical tickets remain open.

Remaining Array witness work is not parser repair. A registered execution
procedure must not hide the original namespace's Array/callable field
contract from native lookup (`l2_path_root` versus walker
`l2_rw_path_resolve`). Reuse original NSF metadata and `l2_nsf_slot`; do not
invent a parallel own row. The already parked indexed STORE needs a shared
resolved typed-field place for CHECK/native/walker, actual descriptor access
and ordinary ELEMPUT. It is neither a raw-pointer substitute nor a special
two-level Array type. The two failing source-constructor rows stay registered.

<a id="ns-full21-evidence"></a>
### 5.9 Full21: bounded repairs recovered, release still red

`build/l2_harness/critical_graph_fix_full_21` completed **RED182/1324**,
source SHA256
`B54ADEBE9B5875338EE6734B071BBA33D13640A85CD51AD3DE0CBE2D4E7B036C`,
executable SHA256
`6C966AC2225AA9F968A512A3FFA18026A4BF3C6AE1F5244866947589A36119A6`.
Against full20,72 shared failures recover, no shared green regresses, no
target is removed and no remaining shared failure detail changes. Three
targets are added: the valid explicit-copy witness passes61 checks and both
constructed-Array write witnesses still refuse at their indexed STORE.

Eight namespace-cutover regressions remain relative to full19:
`graph_shape_method_ref`, `unit_eternal_shape`,
`unit_capture_struct_write_only`, `unit_capture_struct_write_root`,
`unit_field_path_struct_rebind_refused`,
`unit_matrix_path_struct_rebind_refused`, `unit_s7_nested_ok`, and
`unit_s7_nested_shape`. The remaining172 full19 failure identities also
remain, in addition to the two new Array witnesses. The dominant refusal
group still lacks generated L1; legacy construction setups and genuine
source/admission gaps require individual normative triage, not a blanket
test waiver. All complete rows are retained in `summary.txt`.

This full gate predates the subsequent namespace/execution-entry field
contract join and its additive read witness. It does not certify those later
bytes. Kernel/L3 interface01 likewise certify their recorded earlier bytes,
not a current all-green release. Stable promotion and both critical tickets
remain open.

<a id="ns-array-read-evidence"></a>
### 5.10 Original namespace field contract through its execution entry

`l2_path_root` now joins the already selected execution method to its exact
original namespace with `l2_m_nsof` and `l2_ns_source_body`. Own/formal
precedence is unchanged. The existing source-body predicate excludes local,
parented, qualified and synthetic-wrapper producers. Metadata uses the
original NSF rows; emission uses their completed `l2_nsf_slot` projection.
`l2_path_current` retains current `self` where appropriate; external access
uses the original namespace occurrence. No own row or runtime graph is added.

`build/l2_harness/critical_graph_namespace_read_02` completes **RED2/26**,
source SHA256
`4F08DC6789B382F7DC88A5DC8B9CA570F11E484FD2B39F6D35DD08FAC8BAA241`,
executable SHA256
`396E9F7A729DED7354A78C2C589B88A2AFE4E6272B680E775E3FEF6938CB9BB9`.
The two additive Array/borrowed-method read witnesses pass108 checks each:
exact six source fields, cells0/4, INIT1/5, Array2, method3, names, alias
identity and unchanged lexical parent; length2, nullary Shelf execution and
the borrowed method's result9/physical parent-field increment all pass.
Native and cleared-method variants retain the actual method-index pin3.
Existing projection, merge, source-order/mutant and raw-pointer controls pass.
Only the original two indexed-STORE witnesses remain red and unchanged.

Read01 is preserved **RED4/26** on the same translator source, executable
`B4D665A463AC50076217CAEC51BC9F95DB32112D70F659F703B056CF21CDDBEC`.
Its new witness wrongly expected bare `calls` to refresh after an explicit
`node\calls` write. Under [L3 working-state rules](../docs/LMX_semantics.en.md#dynamic)
the clean working snapshot remains0. The corrected witness uses an ordinary
`readCalls` method's explicit lexical path to assert the real field becomes1;
it does not remove that assertion or change caching semantics. Both original
write witnesses remain intact. Read02 is focused evidence, not a full gate;
whole-body reconstruction, indexed STORE and both critical releases are open.

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

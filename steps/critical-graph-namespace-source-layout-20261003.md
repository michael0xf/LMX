# Namespace source layout: connected next slice

Status: connected layout implementation plan, **not an accepted fix**.
The latest completed full harness `critical_graph_fix_full_29` is RED184/1361
on frozen7ADBFE22 and observer821DF2F1:19 recoveries, no new failures against
full28, with identical target identities. A later45-fixture migration first
exposes11 failures; the connected path/body/literal repair and stronger copy
oracles pass `critical_path_schema_03` GREEN43. Neither critical ticket closes.
Actual-call input formation, local source occurrences, capture placement and
typed pointer storage remain incomplete. [Current evidence](#path-schema-closure).
Earlier focused merge/output01 is RED7/152 on9DD7E13A,
ordinary kernel fixed02 GREEN291 and L3 passes11 suites plus four budget units.
[Latest bounded evidence and remaining work](#merge-root-integrity).
Earlier full24 RED199/1329 on3B903EC6 and full23
RED185/1329, full22 RED188/1329, cutover04 RED7/32 and cutover06
GREEN31 remain historical bounded evidence, not whole-kernel acceptance.
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
It now registers ordinary original definitions, including parented global
occurrences, independently of invocation; see the bounded nested evidence below.
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

<a id="array-place-evidence"></a>
### 5.11 One descriptor place for indexed reads and writes

The common Array contract now serves CHECK, native lowering and retained
walker operands. A compact statement head is parsed from its exact original
bytes by P0; the cached compiler document retains topology and source
coordinates until application cleanup. Bindings and contracts are resolved
afresh in the original method environment. This is not an atom metadata
table or another runtime graph.

The existing structural path parser consumes `\[N]name` as a field
occurrence. Its next bracket group is the element-expression span. The
contract comes from the actual declaration, not a kind5/6 int/char guess or
an already allocated physical slot. Native lowering captures the selected
descriptor and backing before evaluating the index and RHS, then uses the
ordinary receiving/conversion machinery. The walker retains ELEMPUT/4 and
ELEM/3, with the same field projection and index span. It does not classify
ordinary typed field-array access as raw C. L2 gains no bounds guard; L3
keeps its existing final-element checking. The established immutable-branch
write restriction and descriptor-path failure handling are shared, not new
fallbacks.

The new walker place allocates its path workspace from the actual segment
count. Legacy fixed42 path consumers still exist elsewhere; this does not
claim that all old depth limits have been removed. Likewise, one descriptor
index is established here, not a complete producer for Array formals,
following independent descriptors, or all rectangular adjacent groups.

Fresh `build/l2_harness/critical_graph_array_place_08` is **GREEN16**:
translator source SHA256
`9589D74D371C8D49D3ACB6770D1C27AAF5ABCA0B2CB60F81BC91F9FAEC256814`,
executable SHA256
`A9BD3916A5625A13F91F0EA9C35714B43444B94899F7F353DA63A8AD70F44FB9`.
Both original Array STORE witnesses now pass108 checks, as do the two
additive read witnesses. The original STORE witness now reads the physical
increment through ordinary `readCalls`, preserving its Array writes,
reads, source-order/name/cell assertions, method identity and parent checks.
This corrects the same clean-cache expectation identified in read01; it
does not change working-state semantics.

The new selector witness passes44 checks natively and48 with the actual
method and root native entries cleared. It independently selects the first
and last same-name Array fields (physical slots2 and5), evaluates
`i+1U`/`i+2U`, rejects substitution by a same-name own Array, and
checks both values and untouched scalar cells. Four generated graph-shape
assertions require the exact OF/ARG/ADD/LIT edges in both ELEM and ELEMPUT.
An isolated runtime mutant erases the first stored index operand:
baseline1/setup1/compared1, setup_failures0, shape_failures1,
other_failures0, with unchanged program exit7. It proves that the retained
index is actually checked, not merely that native execution succeeds.

The int-index negative still refuses the missing selected
`lm_stg_convert_int_size_t` receiver. Its obsolete generic diagnostic
needle and comment were corrected, not the refusal removed.
Raw-pointer/index and existing method-array controls remain green.

Attempts01,03 and04 retain compiler-build failures;02 and05 preserve
RED3/13;06 preserves RED1/15;07 preserves RED1/16 (its first mutant omitted
the comparison of the mutated operand). None is a release. Full22 on these
bytes completes as recorded below; neither focused green nor an earlier
kernel/L3 gate closes either critical ticket or permits stable promotion.

<a id="array-place-full22"></a>
### 5.12 Frozen full22 and normative triage

`build/l2_harness/critical_graph_fix_full_22` completes **RED188/1329**,
translator source SHA256
`9589D74D371C8D49D3ACB6770D1C27AAF5ABCA0B2CB60F81BC91F9FAEC256814`,
executable SHA256
`F6DBE046E041AE348AA5BD144F82CAF8E339AE7203F1176E4C47232B46ECBB14`.
Relative to full21, both original namespace Array STORE rows recover.
All five added rows pass: the two namespace read rows, native/cleared selector
rows, and index-erasure mutant. No row is removed.

The eight shared OK-to-FAIL rows are not one undifferentiated implementation
regression:

- `entry_array_leading_zero` uses invalid C99 octal `08`. The former
  index-only decimal accumulator accepted it incorrectly. Do not restore
  that shortcut. Valid octal `010` is also unsupported by the shared
  numeric producer; base-aware recognition/value/range support is genuine
  common literal debt, not an Array rule.
- `unit_arr_path_inner_value_refused`, `unit_arr_path_three_refused`,
  and `unit_arr_path_variable_index_refused` encode withdrawn length-only,
  depth-two or literal-only restrictions. The current earlier refusal at an
  Array operand lacking a common value contract is also not an acceptable
  final implementation. Establish descriptor-reference production; migrate
  independent nested indexing to `\[index]`, leaving adjacent brackets to
  one flat rectangular Array. Preserve any actual receiving-converter duty.
- `unit_array_write_general_root_real_field` is a historical negative,
  not a positive store test. Its unsupported-index refusal formerly masked
  obsolete `Model: fresh` setup and an invalid value-return from the root.
  Replace its setup deliberately with explicit merge and independently prove
  that the copied field changes while its model and unrelated own Array do
  not. Merely re-pinning the new diagnostic would not prove that behavior.
- `unit_array_write_root_out_of_range` translates correctly; only its old
  `[5U]` generated spelling pin fails. The changed remaining failure
  `unit_arr_path_bounds_refused` similarly fails only an old `[3U]` pin.
  Preserve translation-only status: executing either native out-of-bounds
  access is C undefined behavior, not a safe acceptance run.
- `unit_elem_store_norow_refused` and its walker twin still reject the
  absent `lm_stg_convert_int_size_t`; their diagnostic shifted from RHS
  `:7:11` to head `:7:5`. Restore the receiving value's exact diagnostic
  place rather than loosen the promised refusal check.

These results leave both critical tickets open. Eight older namespace rows
that regressed relative to full19 were also inspected individually:
`graph_shape_method_ref`, `unit_eternal_shape`, both
`unit_capture_struct_write_*` rows, both
`unit_*path_struct_rebind_refused` rows, and both `unit_s7_nested_*`
rows. Seven refuse at obsolete known-Structure receiver declaration setup
before reaching capture/admission/rebinding. The method-ref row exits7 in
both dispatches and fails only its old Point-width1 oracle, but also retains
obsolete `Point: box` setup. The valid explicit-copy row is already
GREEN61 in full22. Migrate these deliberately without restoring implicit
construction or accepting whole-Structure assignment through a path.

Actual unknown-head nested definitions are an independent remaining source
retention gap. `l2_ns_source_body` excludes parented namespaces and
`l2_ns_procs` registers only root occurrences; nested `in: (int: x 1;
int: y 3)` still needs width4 with both original INIT occurrences, not
just two readable cells. Connect the existing nested source identity and
actual instance/parent projection through constructor, native/EXEC and NSF
consumers. Removing a parent guard alone is unsafe while EXEC still assumes
a unit-root slot. Add native/cleared source-width/order witnesses and an
independent dormant missing-INIT mutant before claiming this slice.

<a id="array-place-resource-evidence"></a>
### 5.13 Resource refusal, exact receiving diagnostics and dormant source oracle

Cached compact-head parsing and joined path/workspace allocation now propagate
an already diagnosed failure instead of falling through to an old producer.
The workspace checks its actual segment-count arithmetic. A bare Atom needs
no joined path allocation: its original Text view is borrowed, then the same
value contract classifies an own Array versus a raw pointer. Non-Atom roots
outside this name/path producer are not misreported as out-of-memory.
No runtime guard, field, atom metadata or new graph is added.

The receiving checker locates STORE conversion failure at the actual RHS.
The two absent-converter twins again refuse exactly at `:7:11`. The two
translation-only out-of-bounds rows now pin the captured index and actual
typed backing relationship instead of an old decimal spelling.
The write row additionally requires the exact retained ELEMPUT/AT/LIT/LIT
edges and values at its original source statement place.

The general oracle's optional `StoredAt {Method, Path}` scope follows
the selected method's actual stored source edges. Its default executable
reachability scope is unchanged. The dormant `broken` method is not
pretended executed merely to inspect its source body, and its unsafe access
is never run.
Read-only in-memory controls accept its baseline and reject a null or removed
index edge, index5 changed to6, and relocation of the stored operator from
source slot3 to2. All native text relationships stay unchanged; removing only
the optional scope restores the original executable-reachability rejection.
These are pure oracle controls, not executions of the out-of-bounds program.

Fresh `critical_graph_array_place_14` is **GREEN20**:
translator source SHA256
`B7AFC2FBB49C02C534B83869A734ABFAF39BCB57CC8E8168F54409B9B7CB1B17`,
executable SHA256
`F675C01E63FB2109D9144C937E9A9803C72CD73C290376F1D8A96F2A0FC689FF`.
All original STORE/read witnesses, repeated-name selector native/cleared
variants, independent index-erasure mutant, raw-pointer controls, missing
converter twins, and both translation-only bounds witnesses pass.

Intermediate evidence remains:09 RED7/16 misclassified borrowed bare roots
as allocation failures;10 failed compiler build on an invalid L1 dereference;
11 GREEN18;12/13 RED1/20 had an incorrect then incorrectly scoped dormant
oracle, not a failed STORE. Their evidence is retained.

Targeted `critical_graph_array_fault_01` uses frozen13 on the identical
B7AFC2FB source, executable
`E152743E2CE315DA6003B133B896A7A96217069655F513B2E105A7EA72FE5577`.
Before-call debugger probes identify cache allocations1448/1453 and COUNT
path-workspace allocation1643. All three injected failures give exit1 with a
located out-of-memory diagnostic; no public L1, temporary or backup exists.
The second failure occurs after an earlier cache was successfully retained.

This probe does **not** establish whole-compiler heap cleanup. The ordinary
baseline reports counted live1068, and each injected run retains live1065.
Existing allocated Text-view/type-cache ownership must be investigated and
repaired separately; do not describe that residue as zero or attribute all
of it to one site without pointer evidence. P0's own allocations are outside
the counted fault injector. Full23 completes RED185/1329 on frozen B7AFC2FB,
executable SHA256
`E0F314B94A7A313F1DB97C16D27AA06738D0822C1F30CF0B4667BCC078B96931`.
Compared with full22, both missing-converter diagnostic rows and both bounds
spelling rows recover; no row is added or removed. The sole OK-to-FAIL row is
`unit_indexed_lazy_reads`: its old standalone-load matcher counts zero after
loads move inside the received comparison expressions. Read-only inspection
finds all five loads under lazy guards. Focused14 and full23 do not certify
full acceptance or permit stable promotion; neither tests the later Text
ownership edits.

The corrected lazy-load matcher accepts both frozen full22 and full23 native
artifacts. Its strengthened form also rejects deleting/commenting one real
load, substituting an address expression or inline-comment substring,
duplicating one captured place instead of another, moving a load outside
its lazy guard, and replacing the guard with `if: 1`. All these pure controls
change the actual artifact. This lexical count is not a complete use-def
proof: replacing the real guard with an unrelated lazy-shaped temporary
still passes. Do not claim that it proves result-temp identity or every
source RHS arm independently. Full24 uses this strengthened oracle.

<a id="compiler-ownership-evidence"></a>
### 5.14 Compiler ownership: exact retained owners, no runtime metadata

The transient Text views used for type classification now borrow their
original bytes. The existing foreign-type interner clones one Text-plus-bytes
block only for a genuinely new retained entry. Its truncate/free boundary
releases discarded entries before restoring the row count. Dynamic names
likewise belong to their existing method table. The three existing literal-
backed Lmx/sender/payload views are freed/reset at translation release.
No runtime field, new allocation registry, atom wrapper or type-name table
is introduced. This does not change callable or Array semantics.

Exact debugger tracing after the first repair explains the residual1068
addresses:1065 table-cell name copies, two namespace procedure adapter
objects, and one foreign-type name discarded by row-count rollback.
The final repair releases the table names through `l2_tbx_name`, frees the
compiler's synthetic procedure/UNTIL shells without traversing borrowed
source bodies, and truncates foreign names through their retained owner.
Procedure shells are freed **before** destroying the original P0 document,
while source-identity comparisons are still valid. Partial shell allocation
and namespace-registration failures use the same ownership boundary.
Owned address-path buffers now use the matching counted free operation.

Preserved attempts01/02 fail on a global valued foreign Text before the
pinned L1 predef registration;03 fails on duplicate explicit registration.
04 builds but selects a misspelled fixture stem. None is accepted evidence.
05 is GREEN41 on source SHA256
`865F7E6E7434633C27E8B17C8CE41DDCB811375743EE595DD78CB78E142961FC`,
executable SHA256
`87C88224F275828AE77D1EB55F11EDD6A88B59FBC10BEB08A635EDE00B999FDB`.
Its exact trace still has2296 allocations,1228 frees,1068 outstanding;
05 alone does not establish cleanup. No L1 or parser was changed.

Final `critical_graph_text_ownership_06` is **GREEN41** on source SHA256
`3B903EC67045EA5A378C228A4F535B124EE81374ECEAD106AEDF7C68B83D7309`,
executable SHA256
`F1A380BF9B8631E0671C66834A2570884A63BC13F629F6798CE649D71F5001F6`.
The independent until/trailer07 gate is **GREEN11** on the same source,
executable SHA256
`72C63893D32318A49917AED322917C31C55DAA0F67ED49F5C2DE71A990EC2A23`.
It includes native/cleared trailer shape checks and effect-preserving
trailer-erasure mutants; the existing value-return refusal remains intact.

`critical_graph_array_fault_02` retains the exact pointer trace scripts and
logs. On frozen06, the ordinary selectors witness gives2296 counted
allocations,2296 actual frees, **zero outstanding counted addresses**.
The second retained-cache failure gives1453 counted allocations,1453 actual
frees, **zero outstanding counted addresses**. These are address-set results,
not a live counter floored at zero. Three additional existing frees concern
uncounted objects; P0 and other uncounted CRT allocation are outside this
certificate.

Injected failures1449/1454/1644 exercise the first cache, a later cache after
an earlier retained one, and COUNT path workspace respectively. All exit1
with a located allocation diagnostic and leave no public output, temporary
or backup. The COUNT failure additionally emits a generic1:1 diagnostic;
it is not evidence of a single precise diagnostic. All three aggregate
counted live results are zero, but exact address tracking was run only for
the baseline and the retained-second-cache failure. These frozen06 results
do not automatically certify a later source revision.

Full24 completes **RED199/1329** on source3B903EC6, executable SHA256
`DC874E7A4D7166090F44E452E2AA8C30B702FB590D14D18195CD6166980CD626`.
The target identities are unchanged from full23: the repaired lazy-load
oracle recovers,184 previous failures retain exactly the same details, and
15 previously green negative rows lose the expected source position. They
still refuse the unresolved name, but report the enclosing declaration or
1:1 instead of the actual atom. This is a diagnostic regression, not a
reason to relax the location assertions or a claimed runtime regression.

`l2_dyn_add` had cloned bytes as well as the retained Text view, whereas
`l2_source_text` identifies the original source occurrence by byte address.
The repair lets the existing dynamic-name table own only its Text view and
borrow the original P0 bytes. Original/part documents and retained parsed
head documents remain alive through translation and diagnostics; transient
views point into those bytes, not into stack byte arrays. The foreign-type
interner still owns its independent Text-plus-bytes clone. No spelling-only
fallback, additional source registry or runtime atom metadata is introduced.

`critical_graph_text_ownership_provenance_08` is **GREEN64** on source SHA256
`6E4E0FD8C2EDB3F3B5D840F3FADD15CE9B42AD0D72EE47E6784208F038F0EA2C`,
executable SHA256
`1C575FEC79DDFC3682BE1D5BEB1ABD42CD51F66F7591C00D8FB9A9FAB9208959`.
All15 exact diagnostics recover, with the previous ownership, Array-place,
raw-pointer and until/trailer controls retained. Fresh exact address-set
traces on frozen08 independently give2296 allocations/2296 actual frees
for the baseline and1453/1453 for the retained-second-cache failure, both
with zero outstanding counted addresses. The latter still refuses at14:5
and publishes no output. The three uncounted frees remain outside the
certificate. Scripts/logs use the `provenance08_` prefix in the same fault
evidence directory; this result is not merely inherited from frozen06.
Full25 completes **RED184/1329** on the same frozen source, executable SHA256
`802C15DAFAB39E3C8E39E2B4A78F9E21F3A0009B4A00448BFBA4AC9AE9D45174`.
The same1329 target identities remain: all15 located diagnostic regressions
from full24 recover and184 failure details are byte-for-byte unchanged.
No shared OK-to-FAIL row or removed target hides a regression. These are
the completed frozen full25 bytes, not the later nested-source slice.
Neither focused gate closes
graph reconstruction or the pointer ticket; stable promotion remains
blocked by full acceptance.

<a id="nested-source-next"></a>
### 5.15 Connected source slice: real nested definitions, bounded evidence

A parented original namespace already has one NSF object allocated with
its actual parent. Its original source body must be registered and filled
through that object rather than packed into declaration-only cells. Register
ordinary original definitions independently of calledness; retain exact
source identity and make width/slot projection consume the completed source
container. Do not merely remove the root-only guard while consumers still
assume one unit-root slot.

Connect builder aliases, native/EXEC targets and `node` to the actual parent
chain through existing `ns_parent` and physical NSF slots. A child invoked
from an explicit copy of its parent must target that copy's child, not the
original module object. Record the already constructed source binding in
the existing own table or shared scoped NSF lookup; do not expose nested
same-name fields through global first-match `ns_find`. Source occurrence
identity, not an implicit-copy recognizer, proves construction. Avoid a new
depth ceiling from concatenating nested paths into fixed small buffers.

Decisive dormant witness: `Outer: (int: tag 9; in: (int: x 1;
int: y 3); int: after 11)`, positive entry7. Outer width5 has `in` at2;
inner width4 is cell0/INIT1/cell2/INIT3 with the actual Outer parent.
Deleting only inner INIT1 must fail shape with unchanged exit7. The called
variant adds inner `x: 2` and parent bare `in`: require widths5/6, exact
EXEC target, observed values before/after and genuinely cleared procedures.
Include real `node\tag`, a copied parent and depth-three sibling identities.
Legacy `(): name`, qualified/local and synthetic UNTIL body adapters require
their connected original-body normalization; do not certify them by removing
their source-identity guards. This is pending work, not new language syntax.

Preparatory construction projection must be separate from runtime selection:
stream a builder's existing `l2_nsp[ni]` alias or actual unit occurrence
instead of assembling a nested expression into a fixed-size text buffer.
The alias exists only after the global namespace allocation phase. COUNT
does not emit that projection. A method-local namespace has no global alias;
do not substitute a unit slot or silently omit its source-fill obligations.
Its reached constructor still needs the connected retained-body migration.

In particular, `l2_emit_kx` emits `l2_rw_expr` inside a runtime function with
an existing `host` argument, outside the unit builder. `l2_rw_emit=1` does
not prove builder scope. A foreign-holder projection there cannot use the
builder-local `l2_nsp` array. Audit that existing latent owner-selection gap
when migrating runtime paths; a construction-only streaming helper does not
close it and must not be advertised as such.

#### Completed bounded nested-source checks

The sandbox now separates `l2_ns_original_body` from its execution adapter:
the original P0 body is identified before procedure registration, regardless
of whether the global occurrence has a parent or will be invoked. Width and
source fields then use that same registered body and existing `nsp` object.
Construction projections stream the allocated builder handle, not a guessed
unit slot or a fixed-depth concatenated path. Local/qualified/synthetic
normalization and the runtime foreign-holder route remain open.

An existing own-table row binds a retained nested declaration only when its
original declaration/name tokens and namespace model match. That proof
distinguishes the constructed child from an assignment to a same-spelled
reference. Only the retained Structure constructor skips the old declaration
collector; bare Array/foreign/reference bindings keep their ordinary path.
The stored EXEC target uses the executing parent's OWN slot, including the
existing cached working binding, not the first same-named module definition.

`critical_graph_build_occurrence_01` is RED6/98: the old95 fixtures retain
their result but the six new nested witnesses expose missing registration.
`critical_graph_nested_source_01` is RED2/98 on sourceB88D7CF8: all dormant
and inner-INIT erasure rows pass; the two called rows exit7 in both modes,
but the new oracle incorrectly expects AT where the existing binding uses
OWN. Source02 retains ordinary bare Array declarations and corrects that
oracle without changing the call rule. It is **GREEN98** on source SHA256
`D8270E5A43F3BDEC363182882DA047F46EA2928ABA762CF009E4680375AC63D5`,
executable SHA256
`DF2F4DFC28D0B3374873EEE6208BB56479008C0197EAA95942C6640398C6ED82`.

For an original nested callable, `node` selects its declared lexical parent
procedure's source layout. MAD and method-local routes keep their existing
host selection; no control-body parent is substituted for the method's
lexical parent. The native trampoline passes that occurrence's actual parent.
The source witness deliberately gives root and parent different `tag` slots
and values, and requires only the parent value9 to become10 while root77
stays unchanged. Both read and write select actual parent child2.

Source03 is RED2/102 solely because its new shape oracle expects opcode22
(MOD) instead of the emitted PUT7; all four native/walked logs exit7 with
one shape failure and no other failure. Source04 corrects this assertion
and additionally checks PUT -> OF -> NODE. It is **GREEN102** on source SHA256
`85E54097097B97F55B845C641C2A93764D2727280EB6268808A8131A50C0568D`,
executable SHA256
`748A36ED7606799FA827508B21A0655E91E9DD441FABD503B86230AF992BC2C2`.
The four added rows cover node and bare Array reads in native and genuinely
cleared procedure dispatch. These focused results do not close either
critical ticket or certify copied-parent/depth-three sibling behavior.

The later harness observer correction is recorded separately in
[GRAPH-BUILDER-OBSERVER-IDENTITY](defects.md#graph-builder-observer-identity).
Its25 pure controls preserve all four measured reachable sets under equivalent
namespace spelling. Two further controls reject an earlier unresolved native
slot after its final zero/replacement write, bringing the pure total to27.
Those observer tags are transient test facts, not fields or atom metadata.

Source05 uses the same85E54097 translator and completes **RED2/106**.
The earlier102 rows and both new depth-three repeated-sibling rows pass;
native and cleared procedures separately call `First\mid\in` and
`Second\mid\in`, changing only the correct parent's tag. Both copied-parent
rows refuse bare `copied` from `copied: merge Outer` at4:1 with
`executing a named Structure is not supported yet`, before publishing L1.
This locates missing value-call resolution; it is not a runtime witness of
bad copy parents, and the test is not converted to a refusal acceptance.
The current generic copied-parent language call remains open.
Full26 subsequently completes RED188/1343 on these source bytes with the
final27-control observer. Frozen04 or05 cannot certify it by implication;
the exact delta and subsequent repair are recorded below.

<a id="sleep-checkpoint"></a>
### 5.16 Sleep/resume checkpoint — 2026-10-03 12:43 UTC

All edits are saved on disk. Root Codex is the only writer/build; no external
writer, watcher or queue has been restarted. The stable `l2src` twin remains
untouched. Both critical tickets are OPEN, as is the larger8+8a goal.
This checkpoint is not a release of the inherited dirty sandbox.

Current saved translator SHA256:
`85E54097097B97F55B845C641C2A93764D2727280EB6268808A8131A50C0568D`.
Current saved harness SHA256:
`B1310B66A25B0E64413ED375E3DFAB7C0376C160D3283ED995E4D76C0A352AC1`.
The27 pure builder-observer controls pass without building the compiler.
Focused04 is GREEN102; focused05 is RED2/106, as recorded above.
Completed full25 is RED184/1329 on the older6E4E0FD8 source.
Full26 is the sole running build in
`build/l2_harness/critical_graph_fix_full_26`; at this checkpoint it has no
final summary. The current local terminal session is38302, but that handle
may not survive an app restart. Evidence paths, frozen source and actual
process state are authoritative, not a remembered terminal handle.

Resume in this order:

1. Read `AGENTS.md`, `READ.ME`, `steps/current.md` and this checkpoint; inspect
   HEAD/upstream/status without replacing inherited WIP. These four edited
   documentation files are a separate bounded checkpoint; source is uncommitted.
2. Inspect full26's summary/logs and actual running process before starting any
   build. If still active, let it finish. If terminated without verdict, retain
   its evidence and use a fresh output directory for the next single build.
   Compare target identities and detailed results with full25; fourteen added
   nested/node/Array/copy/sibling identities predict1343 targets, but only the
   completed actual manifest determines that count. Do not waive the two
   positive copy-call rows or call a queued/running test green.
3. Complete the common own-value callable-origin route. Current refusal:
   `copied: merge Outer` followed by bare `copied`, source4:1. The existing
   own row is allocated and `l2_mres_source` has constructor provenance, but
   `l2_own_nsty_get(copied)` is absent and `l2_local_ns_callee` accepts only an
   original named constructor layout. Use existing source proof to identify
   applicable procedure/input metadata while dispatching the actual copied
   occurrence. Do not overwrite the merge-result schema with a namespace
   type, select the original module object, introduce an arity-shaped call
   special case or bypass the language witness through a test-only C door.
   A shared translation-only `l2_own_call_origin` can consume proven existing
   `l2_mres_source[res].layout`, not the possible-source catalogue used for
   admission. Its consumers include `l2_local_ns_callee`, `l2_ns_exec_field`,
   `l2_check_struct_call`, walker Structure calls and `l2_emit_local_exec`.
   Keep ordinary hidden-input preparation and `lmx_call_prim(actual, actual)`;
   a constructor's past origin is not proof after reception or rebinding.
   Propagation through copied values, changed/composed bodies and hidden-input
   preparation must be proved explicitly, not guessed from a familiar shape.
4. The related runtime native-reuse debt is already required by K02, not a
   request for a new language rule. Current semantics§20 (native reuse) and
   L2 copy/merge retain an unchanged selected body's implementation. The older comment
   at `lmx_merge_owned.lm1`265–271 still says every fresh result is interpreted;
   allocation of the extra result root loses the `native` which the ordinary
   copier already preserves at `lmx_graph_copy_owned.lm1`842–845. A narrow
   identity composition is straightforward, but it is not the whole fix:
   current multioperand translation/runtime append unnamed operations instead
   of proving selected executable-body identity. Reuse must consume existing
   operation/initializer/source-place provenance and preserve the selected
   native body's real own-slot and argument/result contract. Neither 'last
   nonzero native wins' nor source spelling is a proof. Existing copy observer
   clears native deliberately; add a real native-retention witness and changed-
   body/reordered-layout controls rather than claiming it tests this contract.
5. Continue remaining local/qualified/synthetic retained-source producers and
   independent source/name/comment reconstruction. After the final connected
   repair, run fresh focused, full harness, ordinary kernel and L3 gates
   sequentially. No blanket Strict switch, fixed depth cap, atom metadata,
   hidden companion graph, stable promotion or DONE before acceptance.

The R0 placement clarification is already saved: launch/settings belong to
the preparation stub; Thread children to existing `Thread.children`. Do not
redo that audit or add either as invisible program-source fields.

<a id="current-value-call-origin"></a>
### 5.17 Full26 delta, exact INIT observer and current-value call origin

Full26 is terminal **RED188/1343** on source85E54097, executable SHA256
`C40E74667F3666664E244277C347F9FA6C113FCB9D819AE67AB0A2C4240AA13D`.
All1329 old identities remain. All184 old failure details are unchanged;
none recovers. Of14 added identities,12 pass and the two copied-parent calls
refuse at4:1 before output. The two shared OK-to-FAIL rows are stale exact
observers: `graph_shape_depth6` omits Level5's initializer, and
`graph_shape_unknown_nest` omits B's initializer. Actual programs still
finish both modes with their then-declared exit0, not a runtime regression.

The repaired observers require exact widths and source order: Level5 is
`[int37, INIT SET(OWN0,LIT37)]`; B is `[int1, INIT SET(OWN0,LIT1)]`.
No trailing fields are ignored. The nested merge finder requires A width1
and B width2; it verifies the copied initializer and OWN/LIT operands have
the copied owners and the initializer is not borrowed from the original B.
Root/method shape selection remains strict. Both positive fixtures now end
with7, so a silent zero exit is not success. Eight mutation rows erase the
deep initializer, erase B's initializer or B itself, or change INIT's facet;
each is checked natively and with the same artifact's root cleared. Baseline
must match, mutation must be applied, shape must fail, and program exit7
must remain unchanged. Copies and the nested merge remain in those checks.

`critical_graph_nested_source_06` is **GREEN106** on trial source SHA256
`DBED8A61AC474C510B83A23DA5F0DAFD3AE28C2476295F21E5AFEF9DC1BE99AE`,
executable `62D99E74F0166C0769EB15D14BF2DAEE2F1CDC0356A0C6FCFEC28099D17FC203`.
Source07 is **GREEN116** on that same trial source with the stricter driver
and eight mutations, executable
`7150D356D352B9B1E3DADA138390B7855FE28E4DF86BF86A94FD34202DC7EF6E`.
These are bounded experiments, not current release evidence: the trial
shared `l2_own_call_origin` used immutable merge-constructor `.layout` to
choose input/procedure metadata while dispatching the actual own value.
After reception or rebinding that value can change, but the constructor
record does not. The extension was removed rather than shipped as a
guard-only fix. No namespace type was attached to the tagged merge schema,
and no original prototype was substituted for the held value.

Source08 is **RED2/116** on E7F4BC2E, executable
`EFA29C52E98ABEFF87EE90AF24A731B20703A04748E343A0A4778E884B16519B`:
the exact observers and all eight mutants pass, while both positive copy
rows honestly retain the unsupported-call diagnostic. The helper now
selects only the prior constructed-body producer route; neither it nor
`own_layout` alone proves a later value after replacement.

Current source09 SHA256:
`070B612392702FFCCDF2D509ACE54BE4F304DB8E6C15CCF44E58A2CDEEC6758D`.
Harness SHA256:
`D355D76924974E1597E944F2ACE843410B7946BB2D0182152D9CC1E81F4A917D`.
Driver SHA256:
`91FCB5FE5C9D538B694E14A6194BB23C929C0FB5F02FDAD5CA8ED30811A3A166`.
It adds stack-only `l2_storage_own_place` and `l2_receiver_output_place`,
using existing `L2Address`. Prepass, receiving CHECK, native take and
walker take consume the same source-site resolved own index. Previously
`own_add` could reuse the first same-host occurrence while native
`own_visible` selected the last visible one. The view itself has no runtime
field, AST clone, binding registry, physical-slot guess or atom metadata.
Receiver classification still respects a declared method's shadowing;
origin analysis must consume the resulting place, never scan its spelling.

Focused09 completes **RED5/124**, executable SHA256
`3C8355B740F03CF3C1608E6035C3E10E0979D99B38D1A24B2B0634C3ACE0D2D9`.
The three additionally selected translation failures are existing full26
rows `unit_receive_letter_model`, `unit_native_typed_receive` and
`entry_index`, alongside the two copy-call rows. Full27 subsequently completes
RED189/1351 on this frozen source. Both strict INIT observers recover;
`unit_named_struct_exec_instance`, `unit_named_struct_exec_two_types` and
`unit_model_var_call` newly refuse their migrated explicit-copy calls before
output.186 other failure details are unchanged. All eight added INIT/body/
facet mutations pass. This gate is terminal, not a pending process or release.

#### Actual-call boundary, not a mandatory whole-program origin analysis

The earlier implementation proposal to require an interprocedural replay of
all mutations is superseded here. Constructor identity is not a language
prerequisite for calling a runtime-selected value. The existing norms under
[call admission](../docs/LMX_semantics.en.md#admission-case-7) and
[transported callable](../docs/LMX_semantics.en.md#admission-case-8) already
require the actual selected callable's interface and available dynamic inputs
to be checked at its call. A receiving contract and a current value are
different facts; a contract may stay fixed while its compatible value changes.

Implement one native/walker call boundary: resolve the exact visible place,
evaluate its current target once, form the selected callable's ordered inputs
from the current caller activation and its lexical fallback, apply directed
admission, then dispatch that occurrence's actual native word or graph. The
existing native dispatch already selects the actual word; the missing piece
is common input formation/admission, not choosing a constructor's prototype.
Native preparation currently relies on prototype procedure metadata; walker
EXEC currently checks call-site witnesses only. Neither proves the selected
candidate's complete hidden-input/default contract. Zero-argument dispatch
is not a repair: it would lose caller-supplied hidden inputs.

Use existing `L2SourceSite`/`L2Address` views for source-visible resolution.
Keep constructor `mres_source` evidence for fresh merge production and D105,
but never treat it as proof of a later value's executable origin. Do not add
a METHOD record, sig word, native registry, Lmx member, hidden companion graph
or atom metadata. Do not infer the declared interface from operands or only
the ARG nodes that happened to execute. A static optimization may prove an
exact body, but the universal runtime-selected route cannot depend on that
optimization succeeding. Its complete interface representation is still an
open implementation gap, not a new semantic exception. The explicit normative
ban on source-name-table execution conflicts with using that already existing
table for hidden-input identity. The bounded representation clarification was
[asked of the author](../LMX_blog/q/current/graph-hidden-input-name-binding.md);
do not silently repeal that ban or invent a new persistent registry. This
does not pause unrelated graph/projection/test repairs.

The paired prefixes `copied: merge Outer / copied / receiveMessage: copied`
and `copied: merge Outer / receiveMessage: copied / copied` require exact
declaration identity: Q53 makes a separately written computed output a new
occurrence unless it targets a real explicit typed contract. Do not describe
the second prefix as replacement of the first merge cell without proving it.
It does show that the later shadow must not borrow the earlier merge's origin.
An actual replacement witness must target the same resolved storage place;
a later replacement must not erase an earlier call's proof. Add an unrelated
primitive write, distinct same-name declarations, a proved effect-free sub,
an opaque external call, branch joins and loop/catch controls. Resolution
must prove that each write really targets the queried occurrence: merely
repeating its name inside another scope does not manufacture that witness.
These controls must exercise the actual-value boundary, not a normative ban
on calls after an opaque effect, a silent skip or stale constructor identity.

Both critical tickets and8+8a stay OPEN. Code is saved but uncommitted;
stable twins remain untouched. Native root reuse after merge and the general
multioperand body-selection/ABI proof remain the separate known debt from
the sleep checkpoint, not closed by these source-site views or focused tests.

<a id="merge-root-integrity"></a>
### 5.18 Source-ordered output bindings and one-root merge integrity

Translator SHA256 at the source-ordered binding/merge checkpoint:
`9DD7E13A5FEC4F994F9F32AA0517E6CF0D8E0EF7E7C3513D9AAE5003684A5E31`.
Harness:
`E0D29C346519B8C4422DA1E69C1FF21FB0730A73DBE01C63509F1FD1CA45BA34`.
Driver:
`A3B2276FD210333B68A0F18324733303FC16C217EFD67174CA9341C5E9438C90`.

`l2_own_source_after`, binding/ordinal selection and exact-host output selection
now consume source order rather than own-registration order. The output route
first recognizes the same written declaration, then the nearest earlier
same-body occurrence; only its actual typed contract permits target reuse.
A nearer computed shadow does not silently reach past itself to an older
typed declaration. Native and walker consume the same stack-only L2Address
projection. No persistent binding row is added to the language graph.

`critical_output_binding_05` is RED7/139, executable
`F61885808168D366605AD200862C9B6B39606DB63036D39F1B4E6D9FB9969A3D`.
Six added output/order fixtures pass both native and same-artifact cleared-root
walk; two mutants redirect actual SIZE_T target storage and fail shape while
the program still succeeds with7. Typed reception and entry_argc_if recover.
The typed output fixture explicitly receives argc3 (exe plus two arguments),
then observes a second receive returning null; no guessed argc2 expectation.

The runtime identity subcase of merge previously copied an operand closure,
then assembled a second root from the copied root's children. Against frozen
baseline1F950CA7 the new witness exits1 with four failures among12 checks:
self edge, nested backedge, ordinary native word and empty-body native word.
The fix in `lmx_merge_owned` returns `copies[0]` directly only after successful
copy with count1, body0 and no active override map. Fresh copies are parented
to the supplied execution container; exact retained-profile occurrences keep
their address, parent and native. Staged names are published on the returned
copy. General multioperand/body native selection is unchanged and unresolved.

Exact merge implementation/header SHA256:
`96BFEBD2CE745DADEA461D473825D3F21EDF1F458F25FD0327E55578D2B4ECD2` /
`1C15C1BDC34EF33D82B3803C389DD1625FD665EB53490820448EA620DE350F6F`.
New `lmx_merge_root_identity_selftest.lm1`:
`10074065C8DA1844AA3465EE076624391ABA5D56D5A3527F5FC681C75D25435B`.
It observes actual native dispatch with copied self/parent and independent
mutation41->42, self/back edges, repeated aliases, empty native and no invented
native. The names witness keeps post-copy allocation failure coverage on two
operands and separately checks one-root names; retained-profile coverage uses
a distinct nonzero container and native word.

`build/l2src/critical_merge_root_fix_02` is ordinary GREEN291 with108 executed
selftests. New root identity:15 checks; names:102; qualified range:44, all0
failures. Frozen generated-C mutations under `build/critical_merge_root_mutants_01`
are rejected: original-object substitution exits3 with failed isolation checks
and the dynamic-call invariant; unpublished names exits1 with three failures;
retained reparenting exits1 with its new assertion. These are actual mutations,
not a claim that a compile failure proves semantic detection.

Expanded `critical_merge_root_output_01` is RED7/152, executable
`D49AE02AEBC9C29A27F3E482C2E71EBDFDA4D35A54CB012366F5ACC3E10C7F4E`.
It retains binding05's complete scope and adds13 passing merge controls, without
a new failure. The seven remaining failures are `unit_receive_letter_model`,
`entry_index`, `unit_named_struct_exec_instance`, `unit_named_struct_exec_two_types`,
`unit_model_var_call` and the native/walk-method nested-copy shape pair.
`build/l3_critical_merge_root_01` passes all11 suites and four budget units
(75/128 names,1070/8192 bytes). Read-only independent review finds no defect
in the bounded one-operand branch; it is not another execution certificate.
No full gate on these later bytes or stable promotion is claimed.

#### Connected cut: output storage inside the written operation

Before the connected cut, the repeated-output fixture has width10 where its source body requires8:
two synthetic null-storage siblings precede the written SET operations. Removing
them must not remove the output's actual stable storage or introduce a wrapper
graph. Place a computed reference in the existing output operand's ordinary
descriptor edge; keep explicitly declared typed targets in their real cells.
All reads/writes of that occurrence must borrow the same operand/storage place,
not copy its initial payload or create an independent working row.

Use existing compiler-only SourceField/construct-place machinery to reserve
and fill that operand before borrows; no runtime names, leaf metadata, pointer
registry or fixed depth cap. An explicit primitive pointer cell is not a
substitute for an ordinary Structure edge: the copier treats pointer storage
as a terminal, so that substitution would lose closure isolation. Extend the
shared runtime place decoder and native/walker producers together. Preserve
actual copied-instance routing, dirty publication, independent repeated
outputs, typed-target reuse, exact source widths/parents/order and names.

This is graph placement, not closure of the pointer ticket. A void** cast does
not create a genuine C99 Lmx* effective-type cell; all address levels and
generic consuming contracts still require the subsequent connected repair.
Do not claim that compact storage repairs @Structure or callable current-value
proof. Both critical tickets and8+8a stay OPEN.

<a id="compact-output-place"></a>
### 5.19 Compact computed-output places — bounded verification

Translator `5CDEF70B12C5CCAB8D786142D4ECBA5A3BA980469F6F87D619B84E419DBE0EDB`
and compiler-only application header
`4463ECAE7370510F4ECF644B7B55A70966236F8FAA2D34B8824A5BCEE6B5307E`
now place computed output storage in child1 of its actual OWN/AT operand.
The SourceField retains the written operation's logical source position;
its L2GraphField targets the physical operand child1. Explicit typed targets
keep their existing declared cells. No synthetic storage sibling, pointer
cell, new wrapper graph or runtime atom metadata is introduced.

Only the exact declaration registers a ConstructionTemp. A borrow creates
no storage, enters no construction ownership ledger and never reparents the
operand. Preallocation declares the saved PLACE handle explicitly; FILL
aliases that handle rather than assuming COUNT/PLACE/FILL temporary numbers
coincide. Reads and writes use this same real edge. Descriptor copy still
follows ordinary graph edges, not terminal primitive-pointer storage.

`lmx_walk_slot_place` shares place decoding among cached OWN publication and
physical PUT_REF. Compact OWN/AT's intrinsic child1 and explicitly supplied
holder/index select the same slot. Arbitrary executable holders remain
refused; exact immutable-profile classification applies to the resolved
holder before a write. The existing unequal code/data ABI follows only the
accessed owned child chain into the selected occurrence. A missing chain
refuses rather than writing the original; external holders retain identity.
This creates neither a context graph nor a mapping registry.

Runtime SHA256:
`B8013230B211A2611F0E675E15E51A8B35C0F5614B8642E5CADB35AB8D400855`.
New runtime witness `lmx_walk_output_place_selftest.lm1`:
`C2EC23A13990DC33AF07E1309DB31626EF2C28371CC3E55BFD1C7491B8633D00`.
It executes16 checks: independent repeated cached outputs, dirty publication,
copy/borrow alias and isolation, unequal-occurrence cached and physical writes,
missing-edge refusal, foreign-holder identity, immutable compact no-store,
and arbitrary-OP refusal. It does not certify typed @ or RHS side effects.

Ordinary kernel `build/l2src/critical_output_compact_01` is RED1/292:
the new witness failed C compilation because its L1 valued-field argument
expressions lacked explicit grouping. That was not a runtime verdict.
After correction and the physical-copy/immutable witnesses, fresh
`build/l2src/critical_output_compact_02` is GREEN292,109 selftests run;
the new witness reports16 checks,0 failures. Independent review finds no
additional defect in this bounded route and confirms staged/live identity;
source review is not another execution certificate.

Focused `build/l2_harness/critical_output_compact_02` is GREEN13
(ten fixtures plus build/scope rows). Repeated output now has source width8,
not10; its two OWN operands have distinct addresses, correct parents/names,
and later reads borrow the corresponding operand. Four native/walk mutations
are detected with unchanged program result7: append a hidden null body field
or change an output operand's source facet. The append mutation replaces the
array backing and slot addresses while preserving child values; it proves
width sensitivity, not saved-address preservation. Harness/driver hashes:
`D46980B1C9D9EED7D7CE544AB4FC85D1E88EFF26AD55A44E70F73CF1322CA69C` /
`3E5D161C3157265203883273BC7ADA27D95C7E63439DE45B7F086F9DAEE95716`.
The driver hash includes a subsequent comment-only clarification of that
mutation; the fresh expanded run must establish its own artifact identity.

Expanded compact03/04 finish RED10/154: the previous seven no-L1 refusals and
three static SET/OWN shape failures stopped before runtime. The three merge
rows still expected OWN3 with hidden coordinates; after migration to OWN2,
the observer also had to follow the preallocated rw-to-rw FILL alias and role.
Compact05 finishes RED7/154, executable
`5BD88253D7A03BFCE87DAE8DE99F1C757FD1B8702906CC3B7251E24BC82D9922`:
the three merge rows recover in native/walk; the same seven no-L1 debts remain.
No shape or program-result requirement is dropped. Some old merge controls
still equate @copy with a descriptor: those expectations must migrate with
the pointer ticket and do not certify its corrected contract.

Further read-only observer review identifies preexisting false-positive
routes. The shared builder pass now snapshots every graph, parent and numeric
write at its own source line. Alias reassignment cannot rewrite a stored edge;
allocated stable-handle rebinding is refused by the observer. Reference stores
and typed-cell helper stores compete in one last-writer event stream. Final
explicit child0 writes override constructor/deferred roles; only an actual
shared role-record lookup proves an opcode, not a numeric opcode cast. Empty
identities produce no graph object; opaque primitive-cell expressions are
values, not inferred Lmx allocations. These are testing-tool corrections,
not changes to the language or runtime representation.

`tools/test_l2_walk_graph_facts.ps1` loads only observer definitions through
the PowerShell AST, never the harness build body. Twenty-one positive/damage
controls pass (aliases, attachment, real parent, final role, width/edge,
line-time identity, numeric identity, typed-helper replacement and same-line
write order, stable sc aliases and snapshot identity after rebind). Current
harness/observer SHA256:
`821DF2F1BC7284DDC99ABC4E84378AEADB95196F01768C36797660C029024FB1` /
`89D4C15A6C2F570BBF7CD6D2E0522470FC38915979918E04F47447412A11B801`.
These refinements are later than compact05 staging. Full28 completed
RED203/1361 on intermediate harness F9F42142. Its source5CDEF70B and executable
`84DF0E2D5AB13BBF728DB60B01D879FACB181888B14605FC777504316B6403AF`
do not certify the current observer. Ten added identities pass;15 shared rows
regress, one migrated typed-receive row recovers, and188 previous failures
retain their verdicts. Four structural failures stop before execution, not
proof that SET/PUT/CALL disappeared. Full29 subsequently finishes RED184/1361
on the final observer; no full later-source success is claimed.

The compact06 source `7ADBFE227BD81ABFE6E6567F825E0298F7E85E0FBE8B3556399FFD7B535AF864`
projects a foreign field through its actual owning occurrence and ordinary
GraphField parent/child edges instead of a local l2_gp alias belonging to
another activation. It also distinguishes explicit typed pointer-cell
declarations from computed receiver output operands by the existing storage
category. Six hidden-merge C compile failures and two local @: producer
failures recover. Four strict structural oracles now demand compact OWN2,
retaining all surrounding SET/PUT/CALL/admission edges. Three old receiving
fixtures now declare an explicit typed target; negative thrown2 expectations
are unchanged. These15 rows plus output/order/merge controls and four real
shape mutants pass `critical_output_compact_06` GREEN33, executable
`5372D44614F3DF7C4CCF9B81A2D08FC08F3C5F5D6EDBAC9737DA994472DE7AE4`.

`critical_fixture_migration_01` GREEN14 (11 fixtures plus build/scope) migrates
four historical fixtures deliberately: fresh values use explicit merge,
shared candidates use explicit references, and signatures remain unchanged.
It preserves copy independence, nested int paths, formal sharing, admitted
permuted-field read10 rather than20, actual named calls and typed-receive
opposites. Executable:
`3C6E486E5645C12FBBC399BEE39444D5B7E2DE358015BDB554C28EDB05B29099`.
These are migrated-fixture results, not same-byte recovery certificates.
The remaining foreign nested-namespace owner-root fallback in l2_own_ctr is
not repaired by the inside-owner GraphField suffix; it remains a connected
actual lexical-owner projection debt, pending its own witness.

Two actual generated-C mutations in `build/critical_output_place_mutants_01`
compile and exit1 after16 executed checks: original-holder substitution
causes five copy/isolation failures; bypassing immutable guarding causes one
no-store failure. They link frozen kernel compact02's libc/source-name objects.
No compile failure is counted as semantic detection.
`build/l3_critical_output_compact_01` passes11 suites and four budget units
(75/128 names,1070/8192 bytes). No stable promotion or full green gate is claimed.
The known @computed-descriptor path still
returns the held Structure rather than the address of its pointer storage;
that is the connected pointer-ticket debt, not fixed by compact placement.
Current callable-origin/capture and multioperand body selection remain OPEN.
No code release or stable promotion is claimed.

Read-only full27 classification:157 no-L1 refusals,20 diagnostic mismatches,
seven old negatives accepted, four text pins, one graph-shape failure.139/157
refusals report non-walkable root operations, not measured runtime crashes.
Its three instance fixtures still use old `Model: fresh`/`Other: o` setup;
only later focused sources migrated to explicit merge. `graph_shape_method_ref`
reaches Entry7 but its old constructor copies Point before filling INIT and
uses obsolete `Point: box`: migrate to valid explicit copy and inspect full
original/copy topology, not weaken the oracle. Preserve the forward-visibility
control `unit_s7_part_root_below_refused` rather than repinning its acceptance.

Actual-call target selection must distinguish cached working descriptor from
physical cell. Explicit path/address writes do not reload l2_q; own-store
changes it. Intervening calls do not justify substituting a constructor's
prototype for the value held now. Runtime admission must use that value. Root
ns-exec must resolve the source-visible binding, not whole-body own_find_last.

<a id="path-schema-closure"></a>
### 5.20 Full29 and the common own/body/schema path

`critical_graph_fix_full_29` is terminal RED184/1361. Executable:
`85C32ABED67C51E092CE1BA19BA1C7CDBBE373A5CA0011F70E24180BED039D48`;
translator source7ADBFE22, harness821DF2F1. Independent row comparison finds
19 FAIL-to-OK, zero OK-to-FAIL, zero added/removed/duplicate targets. All184
retained failures keep the same normalized reason and translator log. Seven
recoveries include deliberately migrated fixtures; eight unchanged fixtures
recover through translator repair, four through compact-source observation.
Do not describe all19 as same-byte code recovery.

The45-file second migration changes51 setup lines to explicit merge; no
runtime expectations are weakened. `critical_fixture_migration_02` is
RED11/57, executable
`63739FE4E369AA7174A9CA6F48A6BA17F4D66F31F0A5B3DC560630DCA088F105`.
Thirty-four migrated fixtures recover. Remaining failures: three method-root
paths through a computed own value; two registered frame-owned bodies; one
captured merge schema; two masked diagnostics; three obsolete generated-text
pins. Twenty-nine other setup fixtures remain unmigrated pending precise
reference, nested-definition, identity or call semantics. This is not a
blanket replacement of every known-head form.

The connected repair removes `l2_rw_path_occ`/`l2_rw_path_bodies` as a
competing traversal. Literal method roots use the common resolver: exact
own declaration or body, then complete schema. Physical kind16 retains an
own row until GraphField holder/child projection; compiler row numbers never
masquerade as runtime child indices. NODE requires a proved lexical stop,
not silent reinterpretation. Semantic leaf classification is recovered
from the recorded declaration when a physical coordinate is used.

Merge scanning, throws/ABI planning and receive scratch planning now all
visit a registered frame's actual statement list when it is the existing
lexical body. Selection uses body identity, not an ELSE-only spelling branch.
The common update checker invokes the existing path-chain validator and
primitive literal check before value production. Foreign members keep their
existing binding classification; no raw-C name check is introduced.

Three historical copy rows now observe copied values, unchanged models,
independent reached merges, and recursive123 at exit7. Obsolete temporary/
frame-width substrings are not storage oracles. An initial strengthened
fixture requested an unprovided size_t-to-int converter; that attempt is
`critical_fixture_observable_01`, not a measured kernel failure. Final witnesses
compare like-typed values without requesting that converter.

`critical_path_schema_01` is RED5/27: the new scan exposes missing throws ABI,
and three attempted text pins still name the wrong merge entrypoint.
`critical_path_schema_02` is RED1/33 solely on the unchanged, already-red
local named-definition control. It fails at S's declaration, before NODE
projection, identically to full29. Neither attempt is green.
`critical_path_schema_03` is GREEN43 (40 fixtures plus build/scope): native/
walked body paths, cache read25, path writes/conversion refusal, visibility
negatives, both diagnostics, copy/recursion observations, native/walked
receive inside a frame-owned body, and repeated-output152 checks with actual
cleared-root walking. Source:
`5A70F7CB747E36B3F89ECE24DDC1B1A214699C3752B0577A5A85A69E6407B181`;
harness:
`8A013A1D7A8375881A256C40ECB9F4A9330D03FD1258D8FDD2CAC5733C90B274`;
executable:
`7FC8E76630A080180A7585F04AE12C90CEA306159911E9E7C77EA1F9A0F0D059`.
No runtime/header change accompanies this translator/harness slice. A full
gate on the exact later bytes remains required.

`critical_path_schema_04` is GREEN9 (six fixtures plus build/scope). An
identical-source method-chain twin now clears all five nested native words
and verifies they are absent; cache twin clears all three. Both preserve the
same observed results as native execution. Receive twins also assert their
actual native/cleared method selection. Translator source remains5A70F7CB;
harness:
`AADE22D03A5A94D7284E295DC9CD812A23E2E359F1889C8EB838F6934AB60539`;
executable:
`3D4AC5014DC2EBC2E401F4A1C2201E6545A8B6AC99E1283108166EB0A926B84D`.

<a id="local-source-capture-closure"></a>
### 5.21 Local definitions and returned captures: remaining source closure

Read-only audits identify omissions, not new semantics. `l2_ns_original_body`
excludes local definitions; their native constructor enumerates fields and
control shells but never fills the complete original body. Body production,
eligibility and parts emission then exclude that procedure. Removing its
refusal or inventing a unit slot is not a fix. Resolve the exact declaration
and GraphField; retain its complete body through COUNT/PLACE/FILL; share one
actual occurrence across cell/name/native/walk producers; retire the
competing fields-only constructor. Definition does not execute the named
body. Reconcile old fresh-on-reach test claims against the approved re-entry
norm, not against implementation comments.

NODE already denotes the actual callable's parent. Native/walker projection
must share one compiler-only lexical context: owner procedure, exact source
scope and GraphPlace stop. A hosted local definition's exact constructor row
supplies that stop. NULL stop is a proved source root, not lookup failure.
Project only the suffix below NODE; never traverse its enclosing body twice.

Capture collection records only namespace ids. Existing complete schema,
schema-field lookup and layout tokens must flow through typing, used-field
admission, construction, ARG fallback and both emitters. Receiving schema,
actual required-model instance and physical captured place are distinct roles.
Do not replace a merge schema with its first model, or reload the factory's
latest result after re-entry instead of the selected callable's lexical copy.
Computed captures can share child1 but have different GraphField holders:
constructor and fallback must retain the complete place, not flatten it.

Older MAD constructors create sparse C of host-width plus all host formals,
then N whose nonprimitive body descriptors are shared by `lmx_walk_cell_copy`.
That helper copies only five primitive cell types; operation parents, edges
and source names are not relocated through the verified graph-copy closure.
This is not accepted source-copy evidence. [Response48 §§3.3–6](../LMX_blog/q/response48.md)
and L3§20 compose actually used values through ordinary merge; they do not
authorize an all-host-arity tail, hidden environment, blanket operator sharing
or rewriting free inputs as formals. Existing input witness cells describe
contracts/defaults; they are not activation storage to overwrite for capture.
Partial Structure capture remains valid: do not copy every unused field as
a shortcut. This audit does not prescribe a new physical capture layout.

Required controls: make r40 and r50 before reading either; observe82/102/84;
capture two outputs with equal child ordinals under different holders; retain
direct-versus-copy mutation, alias/parent/operator relocation, source-name
and unchanged-signature checks. Walk returned readers and constructor twins
genuinely on identical bytes. Actual-call input formation is a separate debt.
The [external-name binding question](../LMX_blog/q/current/graph-hidden-input-name-binding.md)
is unanswered; its normative ban is not silently removed.

<a id="pointer-connected-storage-boundary"></a>
### 5.22 Pointer ticket: value, place, depth and actual C storage

Pointer implementation follows the green graph checkpoint; no fix is claimed.
`@A` addresses A's existing reference-holding cell and adds one level; a null
reference still has its nonnull place. Named/computed/Array/nested/formal
places share this distinction. Primitive addresses select real typed payload
or backing cells. Separate held-value extraction from address extraction:
current `l2_reference_descriptor`/`l2_emit_reference_value` reuse ADDRESS for
the ordinary held value, and walker descriptor production erases @.

A graph reference slot is real void* storage. A pointer-to-pointer cast does
not turn its stored C object into an Lmx* cell. Close native indirect loads/
stores, formals, pointer Array backing, walker transport and raw C boundaries
against actual storage lvalues; convert loaded pointer values where allowed.
Neither a cast-only patch nor a synchronized shadow formal/temporary repairs
the existing cell. Imported C storage retains its real typed route. CHAR_PTR
arena payloads and canonical void* ABI boxes similarly need storage-aware
access at their producer/place, not one blanket load-helper replacement.

Walker DEREF must preserve object-referent witnesses and distinguish a
reference-cell referent. Existing witness kind can express the distinction;
no new Lmx field/registry is authorized. Any encoding must close pointer
construction/classification, work/copy/GC, depth normalization, actuals,
stores and returned values together. Logical type equality does not prove
actual C pointer-cell storage compatibility.

Acceptance: stable unequal addresses of two holders of one object; independent
write-through; null places; real formal cells, not transport boxes; nested/
repeated declarations; Arrays versus backing elements; copied-slot isolation;
depth/ABI negatives; genuine nested walker execution. Compare a
descriptor-as-address mutant with an independently selected arena ref-cell
address before dereferencing: detection must be an assertion, not incidental
undefined access. Existing descriptor-comparison positives need migration.

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

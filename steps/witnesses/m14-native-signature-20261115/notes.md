# M14 step404: explicit signature header reader

This is the first reader prerequisite of the planned native-signature transfer,
not completion of step404 or M13/M14. Baseline code403 is0bf49bf9; the preceding
plan is495e8435. Work is directly on main with one sequential producer.

## Actual change

`lmx_callable_headers_at` reads two explicitly selected physical fields of an
ordinary metadata Structure. Additional fields do not grant FN role or change
the selected headers. A required unavailable header stays UNKNOWN; an explicit
void return is SIZE_MAX. Known args/return survive independently.

The existing callable adapter first resolves its SOURCE coordinates, then uses
this reader. Its older FN role/count selection is unchanged and does not claim
support for the replacement unified-data/native-field model.

The existing PRIM consumer uses the same reader for its physical signature.
Inner counts, entries and actuals retain their physical ABI semantics. Review
caught a tentative SOURCE-policy mismatch before the first build; no fake
receiver, extra coordinate mode or new environment state was introduced.

Implements76→77; Walk189 unchanged. Only the shared C declaration and normal
export recipe were added. No generated L1/C body was edited by hand.

## Frozen inputs and normal producers

Stage reused with fresh labels:
build2/codex_fix250generationchain01/sol-m14-field-values-01.
Logs and source manifests:
build2/codex_fix250generationchain01/runs/sol-m14-native-signature-20261115-01.

Source02 has935 inputs, SHA
`8d3bf91a3892f49f6765fdde441e320de595608b4ef67771adda77a9c877a730`.
The source01 fixture used a private probe; before its first test build this was
replaced by the existing public Graph.fn_result API. Tool inputs did not change.
The accepted previous runtime/frontend objects and earlier receipts are retained.

Tool-native-01 normal PASS:
`6e7d3350ec1a020f9cec86817216c1e6f0786c628502afc67af7029ff6e21faf`.
Runtime-native-01 normal PASS,98 headers, unchanged actual G2 frontend:

- driver C `16e403b22b5adbd0161e2d6251a48556ff190711cdef76cf0ac55a8842759ccd`.
- production `ee05d323c183126c05d39583897113eef10485626a2e207760dda634516a6639`.
- observed `35e9e5485a02936d1b9b9e810db3bfacd2570b57d92fabf2054ca6b42ed4bb14`.

## Focused verification

Focused01 PASS4/0, native/forced and root0/root1:

- exact_scalar_storage: ordinary five-field metadata, explicit reordered fields,
  no FN role, exact SOURCE/witness, missing args with retained return, out-of-range
  field5, explicit void and missing required return. Previous scalar assertions remain.
- execution_gc_roots: real PRIM0/2-input calls, pending arguments, collection and cleanup.
- callable_place_signature: existing callable signature admission.
- sub_parts: existing void/sub part selection.

No frontend source or runtime record layout changed. No new whole bootstrap is
claimed for this focused reader change. The old Source12 whole/fixedpoint of403
remains historical evidence for its own inputs, not a receipt for Source02.

## Remaining implementation

Construct ordinary native descriptors/variants and arena call tables in the
builder. Select entry, compiled signature and existing static place_spec before
binding/admission/result allocation; keep original code/data separate. Do not
read an edited live return as the ABI of an older binary. Then remove both
freshness mechanisms with their tables, transfers and generator branches.

Use existing CallPlaces requirements for the selected spec. Null spec of a
selected native is distinct from the walker's live fallback. Physical receiving
slot metadata retains its meaning. Audit internal compiled ordinal bindings
separately from explicit live data/code paths; no whole-code/exec-map snapshot.

No call-specific grow/List/chain or alternate registry was added. Dynamic table
growth must use M13's common resize/capacity. All those tasks remain OPEN.
Source02 is canonical; repo and stage verification both pass935/0. Docs-index01
passes35/14/27/44/615, links/opening and LF28303. Author commit c7f2825f is accepted:
args means actual values, with formal declarations only in unified data; private
excludes a field from dynamic binding while preserving lexical/explicit access.
This physical transport reader does not restore a separate language formal-args part.
The author's normal semantic/grammar generation and docs check are recorded in c7.
Fresh final indexed docs-index02 on the reconciled tree passes35/14/27/44/615,
links/opening and LF28303; exit0. Working and indexed diff checks pass. All producers
are terminal. The nine-file reader slice is committed separately from c7; the two
unrelated untracked files remain excluded.

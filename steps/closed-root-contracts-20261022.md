# Selected roots retain their type and carried contract

The common root boundary now closes the exact binding FT and carried
declaration contract together. Their later getters project the retained
record instead of reading current source tables. This closes those getters
and the formal pointer-value producer, not every storage-ABI or leaf
projection in the compiler.

Base main is64f658212eb98db37aa41fd697fef8caf9ecf109.
The [two-source patch](witnesses/used-scope-20261020/root155-u0.patch)
applies over the Private154 snapshot. Its compiler-only application source
header is regenerated into C; both source replay and generated-header replay
are byte-exact. Of the
[281 inputs](witnesses/used-scope-20261020/root155-inputs.json),278 are unchanged.
The live source is build2/codex_root_contract155. It remains a private
bootstrap snapshot, not the public-dev/L3+L2 self-build closure.

## One selected-root boundary

l2_path_root_close is shared by ordinary root selection, selected-root walks
and canonical source-fact bindings after input insertion/remapping.
L2Path.root_ft distinguishes an unclosed record(-2) from a closed root with
no L2 storage type(-1). Namespace/method roots and declared external constants
do not acquire an invented integer type. This is transient compiler metadata,
not an Lmx graph field, opcode or runtime binding namespace.

l2_path_root_binding_ft and l2_path_root_contract return the held result.
Record views and owned copies preserve it; prepared views for a different
semantic use reset type and contract together. Refreshed whole-source facts
publish their physical root coordinate, FT and carried contract together.

Native formal-value projection now receives the held FT through
l2_tok_input_type_context. Its pointer declaration and companion Value context
cannot silently change because a source type row was reread. Other ordinary
input producers still enter that same implementation with their explicitly
selected current input type.

The initial profile exposed a source fact with a known schema but no primitive
FT row. The common selected-type reader preserves unknown; the schema still
governs legitimate field steps. A hidden source exposed an absent outer
dynamic-type table. The shared l2_dt query now accepts that absent table like
its existing absent-row state. Neither change guesses a replacement type or
adds a backend-specific path fallback.

## Poisoning, copies and allocation refusal

The [source-linked root fixture](witnesses/used-scope-20261020/root155-test.c)
passes124 assertions. Formal cases cover ranks0,1,2,6,65,129 and qualification.
After CHECK completes a result, both its source name and formal FT row are
changed. Native projection performs no selected-root, declaration, input-type
or formal-declaration reread. The emitted L1 expression AND pointer-context
setup remain byte-identical, not merely successful to generate.

Independent new queries reject the removed name before closing a type;
after the name is restored, they see the changed current FT. The fixture
counts selection separately from type closing, so a failed selection is not
mistaken for a type-table query.

Borrowed and owned record copies retain the original type. Prepared views
start without a root verdict. Own-root getters retain the actual parsed
declaration contract after its source/type rows are poisoned. Machine-local,
activation-slot and external-constant roots use the same closing boundary.
These own-root assertions test the shared getters, not all own-storage
backend ABI emitters.

All3 measured allocation sites in root closing are individually forced to
refuse. A refusal publishes neither a stale FT nor a partial contract;
the real declaration/application owner releases its partial state.
The first own-contract fixture lacked lexical source context; it now supplies
the builtin declaration's actual no-inherited-source context rather than
adding a production workaround.

Compatibility fixtures also pass: native126,CHECK153,owned398,metadata336,
common INDEX420,dispatch COUNT/EMIT200 and receiving114. All17 compiler
profiles finish with their unchanged oracles and zero failures, including
canonical input remapping, whole Model anchors and deep semantic cursors.

## Current units and actual values

Final compiler source SHA256 is
3D05379F7C427062B961A3BEC02A261E0EB097EC8A45DDDFDABC6CC1F50ECE40.
Generated application C header SHA256 is
ADA0E81C7126C28D6C393C3925AB9CD4367E0CED811C282D0AB84ECC3374C848.
The [receipt](witnesses/used-scope-20261020/root155-evidence.json) and
[terminal records](witnesses/used-scope-20261020/root155-results.json)
pin the exact sources, frontend, headers, units and observations.

All85 selected L1 outputs are literally identical to154. Nevertheless,
because the consuming header changed, all85 are freshly built strict-O2
units and actually run170 times. Native eligibility is unchanged:
162 passes and the same8 copy-related RED observations, not a full GREEN.
Twelve located negative oracles also retain their exact classifications
over24 translator runs;seven additional source pairs keep their prior
results. Prior refusals are not reported as new positive passes.

Sixteen fresh auxiliary units add44 actual observations:32 positive
native/forced runs and12 expected write-drop failures. Deep mixed paths,
reordered implements layouts, hidden inputs, values after writes and
writes through taken addresses retain actual values and observed method-body
counts. Two legitimate Array contract mismatches still refuse.
Pointer-offset and opaque-C cases remain native-only.

Constant/string controls add8 old/new units and32 runs(result11,shadow7).
Method-address rebinding adds4 old/new units and16 runs, including two
actual forced method bodies. In total:113 fresh strict-O2 C units and262
runtime executions. Six comparison units and24 runs belong to explicitly
labelled old152 baselines; this is not262 new final155 programs.

The receipt lists13 recipes and their hashes. Reproduction starts with the
published152 source archive, then153,154 and155 patches/manifests.
It also requires the pinned runtime objects/module inputs and unchanged
153/154 compatibility fixtures. Header replay uses the replay source unit
root and its real unchanged l1src/p0.h.lm1 predef import. No deleted historical
binary tree is restored, and this is not yet language-owned self-build.

## Still open

Own-storage ABI, descriptor and leaf projections need further tracing.
Pointer-type spelling queries remain; closing a root getter does not remove
those. Group/Frame/index-child ownership, raw indirect heads and callable/text
clients remain open, as do public-dev,the clean kernel,Model/Shelf/K03,
L3+L2 self-build and mail.

All work stays in build2. The author's deletion of old build is untouched.
Protected log/117 files are neither read nor staged. Only one GCC pipeline
runs at a time; goal remains active with its full original objective.

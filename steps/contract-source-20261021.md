# Carried contracts retain their declaring namespace

Stored Array-element contracts now project their machine type and structural
model in the namespace that declared the contract. A later consumer's
unrelated same-name value no longer changes that requirement. Ordinary
word/value queries keep their current namespace. This closes one source-loss
mechanism, not every path consumer, public-dev or the kernel gate.

Base main `022aa6d264b84b7eb163e86b777d41673a92a3ad`. Candidate
`build/codex_type_origin_145` contains compiler/application sources only;
unchanged headers and L1 working-directory inputs are explicitly reused from
frozen144. Final frontend is `build/codex_origin145_build_03`.
The [compiler patch](witnesses/used-scope-20261020/contract-source145-u0.patch)
replays over [Private144](array-binding-path-20261021.md) with
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
Replay `build/codex_origin145_replay_03` reproduces the exact source.
Application header, production runtime C, graph/Value/Place/uniform ABI
remain unchanged. No new compiler record, graph field or runtime opcode.

## Explicit contract queries, not word-role inference

`l2_contract_source_node` selects the declaration owning the actual contract
node by pointer identity through existing declaration/operand records.
It does not select a declaration by type spelling, inspect candidate.parent
or create an origin registry. `l2_contract_source_begin/end` reuse the existing
source cursor and ordinary binding resolver. The cursor selects that source's
owner, visibility, exclusion and scopes; it restores the caller's method,
current/source method, node, visibility, exclusion, complete active scope
sequence and exact source horizon, including its explicit enabled flag.

Both `l2_contract_formal` and structural `l2_contract_model_depth` use that
same cursor. The unchanged word/name `l2_type_model` API stays in the current
namespace; a value name is not moved before its own declaration. Synthetic
contracts without a declaring source retain their explicit current context.
Depth, qualifiers and element projection still use the existing contract
tree. The common path's completed types/maps reach the existing native and
walker consumers; no backend-specific shadow-name workaround was added.
Other legacy consumers and repeated-resolution routes remain OPEN.

In the actual positive, `Box.values` was declared as references to global
`Need`. Work's local numeric `Need` must not reinterpret that existing
contract. Old144 refuses both the direct and bound paths. Final03 executes
them through reordered `Have` storage: `x` becomes43 through the captured
address, while sentinel17 is unchanged. This is structural admission and its
physical map, not a nominal-tag requirement or an ancestor-graph recovery.

## Independent context and mutant observations

The [generated-C observer](witnesses/used-scope-20261020/contract-source145-context-observer.h)
wraps the real contract APIs, not a replacement resolver. It observes
**2128 queries:1829 formal and299 model**, with zero caller-context failures.
This includes a nonempty control-body scope. Six positive observer outputs
are byte-identical to their uninstrumented final03 L1; the separate newly
declared Array under a numeric type-name shadow still correctly refuses.

The same generated-C source-drop mutant bypasses the source cursor for every
contract query. All three shadow-contract positives then fail CHECK; the
other three positives still translate, and the legitimate negative remains
negative. These are compiler controls, not new interpreter behavior.
Results: `build/codex_origin145_contract_observe_03/results.json`.

Exploratory builds01/02 wrapped a general word-query API. Final03 makes the
contract role explicit instead of inferring it from a word's registration.
Both earlier source/C snapshots and observations remain preserved. Observer
attempt01's added scope example was invalid P0 because it lacked explicit
body ends; attempt02 used valid P0 and exposed a later value-role defect.
No invalid parse or expected refusal is counted as a passing positive.

## Actual values and honest reuse boundaries

Six sources run with production and observed runtime, native and forced
methods, root0 and root1: **48 actual runs, all exit0**, entry7 and 13/17
driver checks. The observed runtime adds only the already verified print on
`lmx_walk_load_body`. Each source gives actual body-entry counts0/1 for
native/forced methods with native root, and1/2 with walked root. This proves
the forced work body is interpreted; total native bindings or m0 are not
used to infer that role.

There are12 new L2/L1 translations. For ten units, both new L1 and generated
C are byte-identical to the prior02 units, so the exact existing O2 objects
are reused. The two new scoped-store units are freshly strict-O2 compiled.
All24 executables are freshly linked and actually run. Production143 runtime
object and the independently observed runtime object are reused by exact
SHA; neither a fresh-all-unit-C nor fresh production-runtime claim is made.
Build/object decisions, link/run logs and hashes are in
`build/codex_origin145_values_03/{builds,results,summary}.json`.

Fresh final03 regressions: metadata336/0, common machine-step record420/0,
indexed dispatch200/0 and two located legitimate binding mismatch refusals.
The exact85 prior inputs undergo85 new L2 translations, all L1 byte-identical
to published143/144, with152 input pins checked. No new C/runtime run of
those85 units: their full143 result remains inherited162 GREEN plus8copyRED.

## Positives still open

The [full scoped positive](witnesses/used-scope-20261020/contract-source145-scope_shadow_02.lm2)
still fails at bare `Need != 91` after the contract-store issue is fixed.
The [minimal value-only control](witnesses/used-scope-20261020/contract-source145-scope_value_control_01.lm2)
fails the same way in both144 and14503 without any Array or new source query.
It is a pre-existing value-role consumer defect, not a valid reference/number
refusal. The full positive was not removed or changed into a negative.
The separate scoped-store control proves only its stated map/address result.
NEXT: current-root value/type selection through the common record, replacing
namespace-first and other spare value-classification routes in all consumers.

The [local binding](witnesses/used-scope-20261020/contract-source145-local_01.lm2)
and [direct local case](witnesses/used-scope-20261020/contract-source145-local_direct_01.lm2)
also remain normative positives, RED in both144 and14503. The typed Array in
locally constructed Shelf is not closed; provider readiness and local model
closure require further diagnosis. No candidate-parent inference was added.
Remaining path/role consumers, capture/lifetime, public-dev, full kernel,
L3/L2 self-build and mail remain OPEN. Goal ACTIVE.

## Storage and exact evidence

Disk headroom fell to about4MB. Only this slice's closed executable copies
were moved into solid tar.xz archives. Before removing each redundant copy,
every member was streamed back and SHA-verified. Sources, generated C,
objects and logs remain. All68 archived executed files across10 containers
were independently streamed and rehashed again at terminal verification;
they are recoverable with `tar.exe -xJf archive -C destination`. No older
pinned artifact, protected log or unrelated WIP was removed.

The initial metadata03 32MB resource preflight did not launch GCC; its recipe
snapshot is preserved. The bounded repeat used24MB based on observed11MB
compressed profiles plus one transient compiler output, without changing any
assertion or oracle. It completed all336 checks before its EXEs were archived.

Source `497F398F0980990CCDAEC30A2CF4BFA7C8F422CB915E07FFF98981B07211C991`;
generated C `FAF6060B63A836FBE99920A79D86019A74B99FE2CBEFC72A1651CF90A46E42A9`;
frontend EXE `6F99202444E7A38EA3252D3B1CA0B76C17476B1C7F9B88D6AAE9EEBBE453ACF9`.
Application remains `CF6648189ECA39C4E348A167AB4015C462DDF476C40144DCE5FEEB98AE4FC08A`;
production runtime C remains `471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9`.

Receipt `build/codex_origin145_terminal_03.inputs.sha256`:13763 pins,
SHA `0C54681A1B6E7FC43E2D685F32DF3CA024C955C231C63D4A55DCC145E584E4AE`.
All13000 parent144 inputs rehashed. SDK/preprocessor closure is not certified;
the inherited unresolved quoted include `decNumber.h` remains a boundary.
Full evidence and source witnesses are listed in the
[evidence record](witnesses/used-scope-20261020/contract-source145-evidence.json).

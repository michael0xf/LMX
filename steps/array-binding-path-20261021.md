# Array bindings carry the common path's selected contract

Array bindings no longer have their own bare-name/one-index getter. The
collector asks the common value adapter for the complete candidate and
keeps its selected Array leaf contract. Deep index sequences, Array fields
and fields reached through an admitted reordered Structure now work in this
slice. This is not closure of every path consumer or of contract provenance.

Base main `062547459e95b092b2dbd09082dac5622f4a5bfc`; candidate
`build/codex_array_contract_144`, frontend `build/codex_array144_build_01`.
The [compiler patch](witnesses/used-scope-20261020/array-binding144-u0.patch)
replays over [Private143](index-dispatch-20261021.md) with
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
Replay `build/codex_array144_replay_01` reproduces the exact compiler bytes.
Application header, runtime C, graph/Value/Place/uniform ABI are unchanged.
No graph field, descriptor wrapper, runtime opcode or per-rank mechanism.

## One adapter and one selected leaf

`l2_path_steps_operand` is the existing run adapter with an explicit
zero-step-root mode. Path-only `l2_path_steps_run` keeps its previous
interface; complete-value `l2_path_resolve_value` permits a bare root.
Both enter the same root dispatcher and the same semantic step fold.
`l2_path_root_contract` reads the selected own/formal coordinate, never
relooks up its name. A zero-step query carries its Array contract and
qualification; it is not a complete whole-value Consumer or a new
`source_use=2` permission. No zero-step query fact is promoted into one.

`l2_ab_collect` requires the complete candidate span and an Array leaf,
then carries the exact `leaf_level` pointer. It does not subtract one
fixed rank, split the source again or infer a model from candidate.parent.
The contract is declaration/compiler-owned and survives temporary path
release. Ordinary level/value mismatch refusals and the separate flat-Array
construction boundary remain. Later native and retained operations use the
existing common path record with types and maps; neither backend gained a
binding-specific selector.

The [actual function-entry fixture](witnesses/used-scope-20261020/array-binding144-dispatch-test.c)
includes the real generated frontend and uses GCC function instrumentation.
Across six complete translations it observes ten collector calls. Old143
has ten dispatch-contract failures: bare roots do not use the common root
entry, and nontrivial new positives refuse. New144 has ten root entries,
eight step-fold entries and zero failures. The two bare aliases naturally
have no step to fold. Every invocation has one root, at most one fold and
no `l2_indexed_operand` entry. The 129-index positive is a type/dispatch
check only: its uninitialized nested descriptors are not executed.

## Actual values, addresses and walker entry

Published143 refuses the deep two-index binding, the Structure-field
binding and the formal mapped-field binding with “an Array binding needs
an Array value”. New144 executes these positives, not convenient negative
expectations. Nine sources run in native/forced-method modes and both root
modes: **36 actual runs, all exit0**, with 13/17 driver checks and entry7.

The sample includes the existing staged alias test, its direct deep-path
control, deep/field/mapped bindings, deep/mapped addresses, an Array of
`int` pointers, and an Array of references to a receiving Structure.
The address tests write through the captured address and verify the original
storage. In the last test, `Need` declares `x,sentinel`, while `Have` stores
`sentinel,x`; the selected reference's `x` becomes43 and its sentinel stays17
through native and walker. The mapped Array-field test likewise keeps its
sentinel23 while writing31 through the selected element address.
The [source witnesses](witnesses/used-scope-20261020/array-binding144-evidence.json)
and exact logs remain linked from the evidence record.

The ordinary runs reuse the exact freshly verified143 runtime object;
they do not claim a fresh144 production runtime build. A separate generated-C
diagnostic adds only a print on actual `lmx_walk_load_body` entry, strictly
builds that runtime copy, links the same unit objects and repeats all36 runs.
Actual body-entry counts are native0/forced1 with a native root, and
native1/forced2 with a walked root, in every source. All values still pass.
This independently demonstrates the forced work body is really interpreted.

Earlier baseline records' total-binding check was too strict: E retains its
native binding. Their later `WorkNativeBindings` field counts m0, which is
not necessarily work in units containing Structure definitions. Neither
field is used as the walker proof; the actual entry-count pairs above are.
Diagnostic attempt01 failed before compilation because its CRLF-only
definition anchor did not match generated LF text. Attempt02 handles both
line endings; this is not a production runtime change or a hidden passing run.

## Regression boundary and remaining defect

Fresh unchanged checks: metadata336/0, common machine-step record420/0,
indexed dispatch200/0 and two located legitimate binding mismatch refusals.
On the exact prior85 sources the new frontend performs85 L2 translations;
every generated L1 is byte-identical to published143. It verifies152 input
pins, including the inventory, original source/imports, prior result file
and85 actual old L1 files. No new C build or runtime run of those85 units is
claimed. Their last full143 result remains inherited:162 GREEN plus8copyRED.

An additional normative positive remains RED in both old143 and new144:
[direct path](witnesses/used-scope-20261020/array-binding144-shadow_direct_02.lm2)
and [binding](witnesses/used-scope-20261020/array-binding144-shadow_binding_02.lm2).
`Box.values` was declared as references to global `Need`; an unrelated local
numeric `Need` makes the common contract query lose that original model.
Both direct versions refuse the same earlier `Box.values[1]` store. This is
not a new alias-only defect and is not accepted as a correct refusal. NEXT:
resolve type/model provenance from its declaring source in the common
contract mechanism, then repeat both engines and address/map checks.
Other legacy indexed consumers, mixed/opaque roles, capture/lifetime,
public-dev, full kernel gate, self-build and mail remain OPEN.

## Exact inputs

Compiler source `C0768F54D2DE9BB5DCFFD036C1C79A50AE54BA07C8C27B5AD6A3ECFAD8A46024`;
application header `CF6648189ECA39C4E348A167AB4015C462DDF476C40144DCE5FEEB98AE4FC08A`;
generated frontend C `1AFBBBCEA622B1739D1533B0A7BF0474701CA52F9AA99C891143459B454A5D0A`;
frontend EXE `2E83220DC2447BD4E098E11FFEA420F1B831A550B47F4C3C2F5FA30BDD6C556F`.
Production runtime C remains `471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9`.

Receipt `build/codex_array144_terminal_01.inputs.sha256`:13000 pins,
SHA `FD4E1320B680050CE0D28D59CEB63A8EA39558081DDAB018DF4E1F874421F54F`.
All12086 parent143 inputs were independently rehashed. Exact frozen outputs
were compressed with before/after SHA preserved, without deleting artifacts.
The inherited quoted-include boundary still contains unresolved `decNumber.h`;
this is not SDK/preprocessor closure. No full gate or goal-completion claim.

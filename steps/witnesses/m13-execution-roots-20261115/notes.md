# Slice395: runtime/native execution GC roots

Baseline394 is committed/pushed as2972b4970e5a5afb59f9ad38e71437f7ce293d3a in main.
395 uses the same main checkout; commit/push follows its final indexed gate. Full M11/M13/M14 and v3 remain OPEN.

Pipeline: build2/codex_fix250generationchain01/runs/sol-m13-execution-roots-20261115-01.
Artifact stage: build2/codex_fix250generationchain01/sol-m13-execution-roots-01.
The stage is an ignored build directory, not another git worktree.

Final Source27:927 SHA6bb032864e6a71e911c4e63ad6d286d62c9da21329b1be3a1f474ef3772e6b6c;
canonical equality and source verification927 in repo/stage PASS. Hosted Frontend04 SHA77e9efc379f128ac6d6c322092c92d96ab30ac4c9b9e32655f5abc1dc10af139;
Tool06 SHA77175da3336c215de1378dc66bab90f41df5b0f6339dbf9e33a48311fbe1dc7a, unchanged Runtime02 below.
Private unit11 and ordinary native11 PASS native/forced x root0/root1. The ordinary fixture includes pending
actual collection, repeated callsite, short-circuit, catch/reclamation and a working snapshot after clearing
its physical DATA slot. Its first/run/take/hold/broken bodies genuinely execute in the walker when forced.
Setup/observations use the existing machine support, allocators and opaque void* transport.
The current normal frontend's legacy hold.p projection is used; general data/code migration remains OPEN.

Actual whole01 quick PASS: G0 builds/tests whole G1 and actual G1 builds/tests whole G2, each9 smoke.
Actual G2 fixedpoint01 PASS31, including runtime prod/observe equality with private Runtime02, full consumed
closure348 equality/verification, headers, canonical/source927, generated L1/C and normalized PE comparisons.
Actual G2 targeted01 PASS4 rows, each native/forced x root0/root1: execution_gc_roots, execution_gc_native,
os_callable_result and whole_arguments. This is the real whole-G2 compiler/runtime variant, not a private substitute.
The legacy replay route was refused before translations because its required historical convert_impl.lm2
is absent from the current maintained closure; no placeholder source or alternate runner was introduced.

Private native-return09 is NOT a successful whole suite: GC fixture setup failed there before the final fix;
os_callable_result and whole_arguments passed4 each. callable_place_fields refused4 in that run and also4
under exact accepted394 frontend/runtime/header control. This preexisting M11/M14 task stays OPEN with unchanged expected.
The final GC acceptance is native11, not native-return09 or the earlier native-only native08.
Actual G2 frontend SHA52622a40303bfd690daf8ff2a093176882499cf05b7e0a4ec7cea385e7370478;
G2 Tool SHAf80f0a460102adb97267978677764a0c13158b2103dea723d7a66c91f381fc82.
G2 Graph01 SHAe4e054cf1200b88021ebd5a02ff293b185107aa2591c1c5102e631bee82182c4 passes
declared_model_interface, construction_paths_owned_data and declared_model_missing in interp/native/forced;
the missing Model refuses at build4. G2 semantics render01 PASS35 paired/14 cases/both verbatim snapshots;
Generated semantics are unchanged, and grammar was not edited. Fresh docs-check01 PASS35/14/27/44/615,
links and LF/index28273. Final indexed01 also PASS35/14/27/44/615, links and LF/index28277.
Diff checks pass. These result annotations were added after the indexed gate as outputs, not semantic inputs.
Commit/push use26 explicit owned paths directly in main; the two foreign untracked files retain their SHA and stay excluded.
Full public resolver/typed Run/receiving/FFI/Foreign-Array,
shared direct cache/flush, other receiving/stop/yield and complete M11/M13/M14 remain OPEN.

## Private build and oracle history

Runtime mark/sweep now includes the existing activation chain, native bindings, WalkFrame Values/work,
GraphFrame cells/prior frames and call_places. Transient typed borrows use arena.execution_roots;
they also cover operations before the first activation. Local spans unlink without dropping younger
pending scratch vectors. Checkpoints close before scratch rewind/free. Scratch chunks stay alive through
their actual owner, but their words are never scanned as graph edges. Every live pool's physical profile
is an explicit graph dependency, separate from semantic Model/source identity.

Toolhost01 translation passed; its first CC lacked the copied seed394 C-header closure. Only CC/link
were resumed after restoring that exact closure. An invalid startup command `hash` was rejected;
the correct `sha256` startup passed. Runtime01 on Source02:925 compiled prod5d1eb9fd/observe93c8b825.
Adding the scratch-owner borrow changed the next descriptor ABI. Toolhost02, built against exact Runtime01
headers/object, has SHAb0855229d655d9048a61b5f8facaf8c3913eb8b36413340915f9b5ef2f3802f9.

Runtime02 is the genuine changed ABI/code build on frozen Source04:926, with93 regenerated headers.
Prod SHA81a35bb1314bfb9691c1f618eceba2bef00898c1bbe4ff4e012b70a2625e4e0e;
observe SHA3c587331eac0299c444ca121231851b1aed8ba88820109e2e0f1d1056cbafe26.
Source05 only corrects the unit frame's nwork invariant. Source06 only renames a reserved local node.
Source07 strengthens that unit by removing an extra parent edge and checking physical-profile owners.
No runtime rebuild was performed for those fixture-only changes.

Initial runtime-only source snapshot: Source07:926,
SHA5822ef0a307acdc0ca3138e95113f9922b04da09d464012782b5e924bc80a9ee; verify926 PASS.
The execution_gc_roots fixture SHA is14208a3a981149ed8de230428b7c1ea03369f56e9522f769f31428e7f3c4f7fc.
Unit01's one-off TSV was rejected before a build due to PowerShell comma/+ precedence in preparation.
Unit02 passed the unchanged exact_scalar_storage n/f/root0/root1, then refused the new fixture's reserved local.
Corrected execution_gc_roots unit03 and strengthened unit04 pass n/f/root0/root1.
The C ABI assertion body is native; its ordinary L2 owner runs in both modes. Inside the unit, real old-walker
PRIM graphs execute both through a normal Walk activation and a public standalone Frame. The first actual
captures an owned exact-double snapshot/box and detaches its giving field; the second collects. The receiver
checks the old exact value and Model/source/profile dependencies. A pointer-looking scratch metadata word
does not retain an orphan, and a subsequent sweep after operation exit frees snapshot/box. A separate real
native callback collects with code distinct from data. Nothing manually marks the observed snapshots.

These gates establish the bounded runtime/C ABI lifetime route, not native expression-root emission or
ordinary FP/FFI. Native emitted current/pending roots remain the next required work in the main v3.
Whole G1/G2, final canonical manifest, semantics/docs/index checks and commit/push395 have not run yet.
All current producers are terminal; diff-check PASS. The two foreign untracked files retain their prior hashes.

Continue [the common pipeline](../../current.md) and [main v3](../../../next_core_tasks_v3.md#native-structures).

## Native continuation history before final Source27 acceptance

Source16:927 extends the existing emitter, without a separate runtime table: full current/pending Values,
selected physical Places and captured graph addresses use C-stack spans. Statement ranges and the existing
loop/pad coordinates restore live baselines; inner expression arms keep their outer result rooted while
detaching inner locals. The trampoline detaches returned typed-body locals before polling.

The added ordinary execution_gc_native fixture depends explicitly on the machine support module generated
by the preceding execution_gc_roots suite row. Its observer stores watched addresses in opaque C-heap state,
requires isolated unsealed header chunks, and checks real collection through the ordinary current Thread.
The extended machine support/unit09 passes n/f/root0/root1; the new ordinary fixture has not yet run.

Toolhost05, SHA2374cffc548310bef8e055a23790510d65338b2fdaf8b6e11bd4c58fea819260, supports an explicit optional
REUSE-BUNDLE in the existing partial frontend recipe. Unchanged backend/libc companions are recorded,
copied and checked for equality; selected modules and headers still use the standard generators. The whole
recipe is unchanged. Current reuse manifests cover111 files and24 declaration invariants, based on exact394
consumed inputs; kernel Runtime02 headers were not replaced by old kernel headers.

FE-native01/02 located source cutter errors, not behavior acceptance: Values/Useplan now translate successfully.
FE-native03 resumes only Lower/Core; no unchanged backend/libc or passed selected module is rebuilt.
Whole, canonical, documentation checks, commit395 and push remain pending.

The partial FE03 and hosted link pass, SHA9f80684b5ead0458934d8193897b21508202dbac6d0dd74a9ba50e4c090ca532.
Only Lower/Core resumed after Values/Useplan succeeded;94 headers regenerated,24 ABI checks remain equal.
Source23:927 changes only the test/support after compiler Source16. Extended unit11 passes n/f/root0/root1.
Ordinary native08 passes native/root0/root1, including pending collection, repeated callsite, skipped RHS,
post-catch and post-run reclamation. Forced08 still stops with an uncaught refusal and is not accepted.

Earlier test producers were not valid transient-lifetime oracles: inline merge created a real lifted own place;
the profiled forest copy also carried an admission from the live original Shape to the copied requirement.
A bounded GDB run on existing native05 caught the first watched mark in mark_impl(entry.req), matching
copy-owned's copied-requirement carry branch. Neither copy semantics nor GC was changed to erase this edge.
The final producer uses existing profiled header/int/refs allocation without copying a registered Model.
The opaque Cdoor-to-typed-Shape return also located the existing FFI/admission limitation; the void* test
does not claim to implement that bridge. A separate working-snapshot case and genuine n/f acceptance remain required.

Forced08's first actual refusal is now localized by GDB: RET from first returns a correct REFERENCE/type1040,
but the generated return witness is a self Structure, classified LMX8. Three legacy writer checks inferred
descriptor from raw C return ABI16, also used by opaque void*. Source24/25 repairs this through the common
input_is_descriptor(mi,-1) semantic predicate and a shared borrowed header_source coordinate reader (resolve125).
Header, selected-call contract and trampoline share the predicate; runtime receive is unchanged.
Tool06 passes. FE04 resumes only Resolve/Core/Emit with reuse106/ABI24; its acceptance remains pending.

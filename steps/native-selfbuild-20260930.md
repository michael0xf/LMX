# Native compilation and the route to §§8–8a

Status: 2026-09-30, runtime checkpoint ca2f1cd on main; translator WIP in build/opus_wt.
Implementation evidence and remaining work, not a language specification.

## Resumed after Q56/Q57 documentation correction

The author has resumed implementation through §§8 and 8a after a separate
documentation checkpoint. The earlier research HOLD is withdrawn. Use the
current semantic book construction/dynamic chapters and next_core_tasks §3:
no implicit Model:fresh clone, no unknown-argument declaration fallback,
explicit reference binding with conversion before structural admission,
nonexecuting signatures, and Q57 as definition containing an empty named
Structure rather than an immediate or delayed call. Earlier typed-binding
and empty-reference experiments are not the accepted declaration contract.

The preserved worktree was fast-forwarded to 6538898 without discarding its
code WIP. That documentation checkpoint is on main and origin/main. Current
code has not passed one exact-byte full generated/kernel/L3 gate. The old
full harness s7b108 had 105 failures; those include obsolete root-only text
expectations and real defects, not permission to weaken the harness.

Fresh diagnostics after the documentation checkpoint:

| Run | Scope and result |
| --- | --- |
| `build/l2src/resume_q57_20260930_01` | Optional `-Strict` run: 280 targets, 136 failures, primarily warnings promoted to errors; not the standard runtime gate |
| `build/l2src/resume_q57_20260930_02` | Standard `build_l2src.ps1 -Run -KeepAll`: **280 targets, zero failures**; includes the corrected deep-holder witness |
| `build/l2_harness/resume_ref_20260930_01` | Focused signature run: 8 targets, one failure exposed inconsistent raw/encoded formal types |
| `build/l2_harness/resume_ref_20260930_02` | Focused signature run after normalization: **8 targets, zero failures**, including existing primitive/reference controls |
| `build/l2_harness/address_name_20260930_09` | Common Structure/reference-cell address acquisition: **15 targets, zero failures**; 12 fixtures including depth refusals and existing controls; two deliberately inverted positive witnesses fail |
| `build/l2src/mapped_cycles_20260930_01` | Standard kernel after mapped-cycle repair: **280 targets, zero failures**, 104 selftests; runtime implements 55 checks (25 new), table 59 checks, zero failures in both |
| `build/l2_harness/resumed_full_20260930_01` | Full frozen WIP diagnostic: **966 targets, 854 OK, 112 failed**; not a clean-kernel certificate |
| `build/l3/resumed_l3_20260930_01` | **11 runtime suites / 295 checks pass**; overall exit 1 because four header-inventory expectations still require 72 names instead of the measured 73 after adding the operation-local LmxImplementsFrame; capacity remains 128 names / 8192 bytes |
| `build/l2_harness/formal_address_20260930_final` | Corrected static formal-address slice: **13 targets, zero failures**, ten fixtures; all three deliberately inverted positive controls fail at execution, then are restored before this final run |
| `build/l3/formal_address_20260930_final` | **Full L3 gate exit 0**: 11 runtime suites / 295 checks; all four header inventories 73/128 names and 1043/8192 bytes. Updated only the expected count for LmxImplementsFrame, not the capacity |
| `build/l2src/runtime_checkpoint_20260930_01` | **278 targets, zero failures**, 104 selftests, on isolated main ca2f1cd without translator WIP or its new metadata header; implements 55/55 and table 59/59 |
| `build/l3/runtime_checkpoint_20260930_01` | Isolated ca2f1cd: **11 suites / 295 checks, exit 0**; four inventories 73/128 and 1043/8192. Full console, including inventory results: `build/l3/runtime_checkpoint_20260930_01.log` |
| `build/l2_harness/native_gate_migration_20260930_02` | Translator WIP only: **15 targets, zero failures**, twelve migrated native/graph witnesses; separate 60-check graph-observer audit includes 40 negative mutations and eight valid temporary-renumbering cases. Not a full harness gate |

The first kernel run predates the subsequent reference-translator edits. The
focused harness does not replace a full gate. The stopped audit run
`build/l2_harness/20260930_144410` has no verdict and is not evidence.

The first signature experiment used existing Model and Other, not the withdrawn
implicit `Model: fresh` construction. Its claim that signature synonymy also
proved a local rebinding policy was not justified and has been withdrawn.
The current witness proves only reference transmission and descriptor identity.
Native named-value address acquisition now
distinguishes an actual Structure descriptor from an explicit reference's
cell. Flat and Frame forms use the same classification; an extra reference
level is not erased. Translator blob for the focused green run:
acec2a68ed3402c73bd72a4065e9057e2631a7fc. This does not yet prove unified
field/index paths or interpreted portable references. The full generated
harness and L3 runner must be repeated.

Independent review found that the new `unit_address_formal_depth_refused`
expectation was wrong under L2 §18.2–18.3: a reference-transmitted nonprimitive
formal denotes its descriptor, not the machine parameter's address. The
15/15 result remains execution evidence, not proof of that expectation.
The corrected WIP uses a shared logical input category derived from existing
signature/callable metadata, not the backend pointer spelling. The final
13/13 run above proves descriptor identity for both Structure-formal spellings
and callable formals, retaining primitive cell-address and genuine explicit
body-reference depth controls. The wrong refusal fixture was replaced by
positive descriptor witnesses. `unit_ref_signature_synonyms` now tests
transmission/identity, not a new formal rebinding policy. Formal call/rebind
classification has not been changed by this address fix. Array formals and
dynamic-input category propagation remain implementation gaps; no guessed
fallback category was added and no interpreted-reference coverage is claimed.
Final translator SHA256:
C2A8D284160E459FDE3A251F79B5DA1E6BFFA80962941CE6BD264711F8564D4B;
Git blob aa03bb62d38c6b4cafdcba205706656133f33d6b. Code remains uncommitted
WIP in build/opus_wt, not a main/stable-source promotion. The last full
generated run predates this final address correction and remains red; no
clean-kernel, §8 or §8a completion is implied by the focused and L3 successes.

### Bounded runtime checkpoint ca2f1cd

The independently verified runtime slice is separated from translator WIP:
`lmx_chars`, `lmx_value_owned` and its corrected accessor-contract header,
`lmx_graph_copy_owned`, `lmx_walk`,
`lmx_implements` and its header; the three affected runtime selftests;
`tools/l3_type_budget.py`. All nine kernel source/test files were rechecked
byte-for-byte against `mapped_cycles_20260930_01` before staging. The final
L3 run above uses the same executable runtime bytes; the corrected header
comment is included in both fresh isolated ca2f1cd gates above. The isolated
kernel count is 278 rather than the WIP's 280 because the translator-only
metadata header is absent; all 104 runtime selftests still run.
The changes remove the admission
depth-32 and holder-depth-256 cutoffs, retain mapped correspondences across
cycles, and separate C99 numeric char reading from intern-table byte indices.
This development checkpoint does not promote stable `l2src`, publish the
unfinished translator, or certify the full generated harness. Mixed C99
arithmetic and the representation repairs below remain open.

The twelve migrated generated tests remain with translator WIP, not in this
runtime commit. They replace obsolete root-only refusals/global temporary
ordinals with actual output, argument/result/receiver graph relationships,
and a non-null native root. In-memory mutants fail for the missing property;
renumbering temporary variables remains valid. The root FOR row was expressly
left red because it lacks the graph, despite its correct native result.

The full harness's 112 failures split initially into 37 generated-text
assertions, 51 diagnostic-text mismatches, 17 newly accepted former-refusal
rows, one missing expected note and six missing-L1 results. This is a failure
classification, not permission to rewrite expectations wholesale. Of the
51 diagnostic mismatches, 42 are preempted by a void-callable return-with-value
diagnostic; resolve the source-role cause before updating the expected error.
Four no-L1 cases reach the real `graph assignment admission requires
receiving-expression tests` gap. The other two encounter static admission
failure and also contain withdrawn implicit-copy setup.

Even green old rows are not proof of current semantics: the `unit_bind_*`
family still includes executable `Model: b c` / `Model: fresh` construction.
Conversely, do not migrate by fixture name alone: the current
`unit_fresh_instance_skipped_decl` and `unit_recursive_fresh_instance` exercise
activation/reentry, not the withdrawn model constructor. Preserve their
behavioral purpose. The 1503-source frozen diagnostic aggregate is
cf124130a927ed68474da7462f3a904b45649509ee5aa015e965b122c8befa9f.

Mapped admission uses one operation-local traversal with pending/cached
correspondences for both providers. Back-edges retain those correspondences;
unvisited siblings still undergo admission, and failure does not publish a
cache entry. All 231 staged kernel source files match the live bytes in the
green runtime run. Aggregate staged-source SHA256:
5475b1c099ed630510914065122925ced8dad2888e5b840b8bd8d23dd774ac3d.

## Definition/body role clarification

[Q58](../LMX_blog/q/current/q58.md) asks about an already known ordinary
callable nested in a new named Structure. The earlier audit suggestion that
a generic `definition contents` label alone resolves Q57 was insufficient:
the rule deriving that role is the missing fact. Ignoring outer bindings
would also destroy Q52 hidden-input assignment and ordinary saved calls.
Do not decide using empty/nonempty tails, argument count or surface syntax.
The author has been asked; no speculative resolver replacement is authorized
by this note. Independent gates and repairs with settled semantics continue.

## Pending regression migrations and runtime defects

- Remove the old callable-versus-reference distinction in
  `unit_value_formal_call_refused`; `(Model: v)` and `(@: Model v)` are
  reference-transport synonyms in signatures only.
- Migrate executable implicit-copy setup `Model: fresh` to explicit
  `fresh: merge Model`, retaining copy independence and per-activation tests.
  Do not mechanically change the identical spelling inside signatures.
- Old `A: b c` alias/admission fixtures must use explicit `@: A b c`, not
  merge: a copy would destroy the identity property those fixtures test.
  Keep known-head calls with unknown arguments as call errors, not fallback
  declarations. Add Q57 graph-and-effect witnesses at multiple positions.
- Mapped-cycle admission is repaired in WIP and runtime-gated above; it is not
  yet a published clean-kernel checkpoint. Preserve the positive and negative
  cycle/sibling/cache witnesses when integrating the remaining translator work.
- Built-in mixed machine arithmetic must follow target C99 promotions and
  operations. The walker still rejects some different promoted types. Fix
  common operand typing separately from receiving-place conversion/admission;
  do not silently use host widths or the Message conversion table as an
  arithmetic operator dispatcher. Native/interpreted parity is required.

## Acceptance

§8 requires maintained L3/L2 sources for runtime, parser, both translators,
build/test/finalize tooling. Generated L1 is allowed before C. Bootstrap once
from tracked generated C; build, test and replace the binary; repeat with the
successor. Two actual successful generations, no handwritten L1 dependency,
historical binary fallback or PowerShell/Python stage in the accepted cycle.
The old run_self_build 8/8 is only a handwritten-L1 fixed point.

§8a follows §8: post through ordinary call/admission/result semantics over the
same mailbox. T01–T26; one ask to three routes = 1 execution/1 reply/3 deliveries;
three asks to three routes = 3/3/9. No second queue, resolver or graph.

## Current repairs and evidence

- E now has the ordinary void native body/trampoline/native word.
- Native compilation does not erase the executable graph. Supported E bodies
  use l2_rw_methods_count/emit, l2_occ_expr and l2_m_width. No separate E loop.
- Send metadata is keyed by owner and source statement. Graph/native emission
  use one l2_msend helper; the root-only registry/counters were removed.
- Callable-result initializers use l2_check_call, restoring D105 admission maps.
- Typed own-reference binding uses admission, as locals/formals do. Letter
  payload extraction follows grouping and explicit reference expressions.
- Dynamic calls and named-Structure hidden inputs share typed arena-cell
  materialization. A stack pointer is not a typed address for the walker.
- Literal/dynamic size_t array indices share native load/store emission.
- The implemented-body predicate includes callable-result constructors whose
  return is attached to the result-signature Frame.

Focused evidence under build/l2_harness:

| Run | Result |
| --- | --- |
| s7b102 | 9 fixtures; reference admission still failed |
| s7b103 | 7 reference/capture fixtures passed; 10 targets including infrastructure |
| s7b104 | 5 of 6 fixtures passed; held char remained |
| s7b105 | Unknown focused-fixture name rejected; no fixture evidence |
| s7b106 | 9 graph/native/reference/capture fixtures passed; 12 targets |
| s7b107 | Dynamic index and T7 constructor passed; held char exposes Q55 |
| s7b108 | Full harness: 959 targets, 105 failed; stale root-only expectations and genuine remaining gaps must be separated |
| s7b110 | 6 focused fixtures, 9 targets passed: C99 char capture/results and range checks, signed int/size_t controls |
| s7b112 | 4 focused fixtures, 7 targets passed: char callable formal, dynamic index, two L2 OOB translation-only witnesses |
| s7b113 | Full Windows runtime kernel gate: 278 targets, 103 self-tests, no failures |
| s7b114 | Full L3 runner: 11 suites and 4-unit type budget passed |

OnlyFixture is labelled diagnostic scope and cannot certify a full gate.
The full generated/kernel/L3/docs/diff gates remain mandatory.

Changed expectations: unit_next_message_loop expects 5 by answered Q53 (inner
receiver declares another m); unit_throwing_callable expects 1,1,2 by Q44
(merge copies mutable occurrence/state, shares only the native implementation).
The s7b101 null-instance experiment was an overbroad declaration skip through
l2_root_ref_row, not proof that Model:m construction itself was broken.

## Remaining clean-kernel dependencies

### C99 primitive meaning and Array indexing (Q55 answered)

The author requires C99 target types, including plain char signedness. Remove
unsigned numeric reads of char, but retain byte-index normalization for the
intern table. Check native/walker arithmetic, admission and captured results.
Array length comes from its descriptor. L2 performs no bounds checks. L3
checks only the final flattened index against total length, not each axis;
do not add runtime dimension lengths to the base descriptor. A rectangular
Array and an Array of Arrays remain distinct. See LMX_blog/q/q55.md.

Initial Q55 WIP witness: q55_char_kernel_s2 compiles the kernel and links
lmx_walk_lt_signed_selftest; direct execution of its Windows .exe passes
268 checks, 0 failures, 0 construction errors. The Python diagnostic runner
reports a missing extensionless output even though GCC creates .exe; its
aggregate verdict is NOT a green gate. The standalone older run_walk_selftest
runner lacks lmx_call linkage and is also not a green gate. Required Windows
kernel/generated/L3 gates remain pending. Numeric getter, cross-arena intern
copy and char arithmetic promotion are tested; full conversion/call coverage
and profile range admission remain work, not a completed Q55 checklist.

Read-only source audit: length already reads the descriptor. Walker ELEM and
ELEMPUT check the final index. Native lowering currently loses the source
operation's L2/L3 level and always emits unchecked access; the test knob is
not a language-level selector. Retain the actual level before adding native
L3 checks. Rectangular flattening is absent; two nested ELEM nodes currently
mean two separate Array descriptors. l2_array_literal and l2_arr_operand also
reject static OOB indices in L2. Translation-only witnesses must not execute
undefined C accesses. Do not remove Structure-slot validation as an Array fix.

### General receiver composition (Q56)

The author's clarification supersedes the proposed Array-specific residual-type
scanner. Ordinary nested receiving expressions must share one resolution path;
`[]: []:` is not a special grammar or another Array kind. Replace the existing
shape recognizers, not just their depth limit. `length` consumes the ordinary
resolved operand. The author settled sequential paths as `a[i]\[j]\[k]`,
distinct from flat C-like `a[i][j][k]`; do not recover or infer rectangular
shape. Detailed code boundaries and
acceptance: [general receiver resolution](receiver-resolution-20260930.md).

<a id="c99-expression-types-versus-arena-storage-domains"></a>
### C99 expression types versus arena storage domains

Q55 already determines machine-type semantics; distinct arena pools do not
introduce distinct C types. In particular, `size_t` must resolve to its target
C-compatible base type for integer promotions and usual arithmetic conversions,
while a declared size_t cell can retain the `LMX_TYPE_SIZE_T` storage domain.
Canonical-equal C types take compatible assignment, before consulting the
primitive conversion table. Do not use equal widths as proof of type identity.

The current profile has widths/spellings, not a verified alias/rank relation.
The implementation route is target-compiler compatibility probes over the
ordinary C99 integer declarations, consumed by one arithmetic type resolver
shared by translator and walker. No header scanner or C-name registry. A target
using an extended integer type needs corresponding toolchain metadata, not
a guessed standard rank. This is implementation work, not a request to change
the author's rule. The already determined int/unsigned/ulong and char promotions
can be repaired independently; evaluate after casting both operands to the
resolved C type, not in a size_t scratch type. Pin result domain and value in
native/walker witnesses, including unsigned wrap and signed/unsigned comparison.

<a id="one-complete-lexical-graph"></a>
### One complete lexical graph

Common E graph emission restores the supported subset, NOT full acceptance.

First bounded repair: `unit_root_for_refused` has a native loop but no graph
FOR. The hosted numeric declaration in `l2_rw_stmt` rejects E specifically;
`l2_rw_methods_count` then leaves its step count negative and emission drops
the entire root body. Use the existing hosted-field and `l2_rw_enter/leave`
paths for every executable occurrence, removing the duplicate root-only
`l2_rw_cblk[64]` scope stack. Do not merely accept the old refusal fixture
because its native result is correct. Require the same positive result with
the root's native word cleared by the test driver, retained FOR/OWN_OF/SET_OF
nodes, and nested control-scope witnesses. This removes one omission, not the
separate duplicate-body/layout defects listed next.

1. l2_m_kids + l2_m_steps still puts data before an operator tail. Consolidate
   unit_base+i/ns_base+rank/mres_base+r formulas into physical location helpers,
   then assign existing own_uchild/own_fchild/for_uchild metadata in source order.
   Root source is l2_cur_unit, not filtered l2_e_fields.
2. l2_emit_unit/l2_emit_local_bodies allocate canonical source control bodies,
   while l2_rw_body allocates another step-only lmx_walk_plain. Populate and
   execute the same canonical body. No field-only or step-only companion.
3. lmx_walk_body already scans mixed children and skips non-operator cells.
   No runtime execution-order/name index is needed.
4. Implement missing operator representations instead of deleting the graph
   on quiet walker refusal. Preserve lone string expressions too.
5. Capture/merge/T7 consumers must stop assuming that a prefix contains all
   data. Use common graph-copy identity handling for canonical body references.

Witnesses: lexical ordering, retained operator/literal graph after native
execution, same L3 graph executed with its native word cleared in a test, and
M\while\j resolving to the exact body executed by WHILE.

### Every statically known executable body compiled

Capturing nested methods are still stubbed by l2_emit_body_in and excluded
from native-word/trampoline emission. Existing explicit+hidden ABI suffices:

1. Emit actual bodies using l2_cap_dyn_add/l2_dyn_add and l2_emit_sig.
2. In native trampolines share l2_rw_arg_fb's resolution: supplied hidden input
   wins; absent input reads its lexical declaration through self.parent.
   Explicit formals do not acquire this fallback.
3. Share captured Structure type/admission-map lookup with native paths:
   l2_cap_arg_ns, l2_node_seg, l2_d105_emit_slot.
4. l2_mad_emit and l2_emit_mad_construct_one preserve the matching native
   implementation for unchanged bodies. Remove walker-subset prerequisites.

Use make_adder, a3_caller_binding, a3_node_path/direct, capture_struct_* and
typed-result twins, with actual native-pointer assertions. Existing success
can still be walker-only success.

PAP/T7 additionally needs the already-decided steps/merge-callable-r48.md
S2 → S4 → S3 repair: preserve full formal interface; merged values are defaults,
not removed formals. Receiving signature is an admission constraint, not
another operand. Do not attach the original native address to today's reduced
incompatible signature. Explicit y=25, y=0 and a later omitted y must give
26, 1 and the original default result 6.

lmx_graph_copy_owned preserves native, but lmx_merge_owned still clears the
result root unconditionally. The L2 spec repeats that stale blanket claim,
contrary to the semantics book/Q44. Preserve the matching unchanged body's
implementation, never blindly the first operand's address after code replacement.

## Concrete §8 route after clean-kernel

1. Make separately compiled L2 libraries actually executable: current
   l2_emit_library_wrappers sets l2_library_unit=0 and fails open.
   unit_lib_pair_a/b prove LINK/SYMBOLS only; require actual 41/42 results.
2. Fix the common runtime construction ABI: library open currently opens a
   root, root needs List, and a ported List would open another root.
   profile:runtime only suppresses polling. No List-name exception.
3. Replace lmx_list_owned and declarations with L2; link without its old body;
   run growth/removal and child/root/mail consumers.
4. Port dependency-closed runtime groups: storage/arenas/pools →
   values/arrays/graph → copy/merge/admission/calls → mail/Thread/root →
   walker/L3 interpreter. Maintained .h.lm1 also counts as handwritten L1.
5. Port current P0/owner/text; existing .lm2 fragments are not a complete parser.
   Large failed ports were removed in 01f56f3. Gate without the L1 parser oracle.
6. Port both l2trans and the L1-to-C translator; test successor translation.
7. Port buildCore/make/finalize and gate logic, not old shell-script generation.
8. Prove two self-replacements from the tracked generated-C bootstrap.
9. Implement §8a on ported ordinary call/mail/admission layers, T01–T26.

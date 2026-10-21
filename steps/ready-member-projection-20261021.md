# Prepared C member paths in native consumers

Base main `2e8b33194e46b310fe1e71dc310c4cbb551301ea`.
Final candidate `build/codex_ready_member_139e`, frontend
`build/codex_member139_build_05`. The [compiler-only U0 patch](witnesses/used-scope-20261020/ready-member139e-u0.patch)
applies over [Private138](pending-index-contracts-20261021.md):
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
Replay `build/codex_member139_replay_02` reconstructs the exact compiler source.
Runtime, application source and graph/value/ABI layouts are unchanged.
This closes native representation re-entry in three C-member consumers,
**not all path resolution, the full kernel gate or self-build**.

## Selected records reach their native consumers

`l2_native_member_path` obtains a view of the cached complete P0 head for a
Frame, or the common text adapter's record for a text-only atom. It resolves
the root and classifies its selected binding's closed contract. A successful
consumer receives that same record and releases it after use; it does not
request another parse or look up the root by spelling again.

The removed `l2_emit_raw_path` was a second text entry after classification.
Native atom reads now project the selected record. `l2_emit_ccall_ready`
accepts the already selected callee; its ordinary wrapper selects once for
callers without such a record. A C-member store keeps its selected record
across RHS preparation and projects it without another lexical lookup.
The call's destination is taken and cleared before nested preparation, as
before; nested calls cannot consume the outer call's destination.

`l2_emit_raw_steps` projects an explicit range of the adapter's existing
steps. NAME uses the closed root's value/pointer representation for its first
selector. INDEX evaluates its retained P0 span through ordinary expression
preparation, so local indices use selected emitted bindings, not raw source
names. Mixed NAME/INDEX sequences have no fixed depth. Opaque intermediate
C member types are not guessed from C headers or adjacent declarations.

The prefix wrapper `l2_emit_raw_members` intentionally projects only the
leading NAME range for the existing typed index-place emitter: that consumer
then folds each INDEX's recorded type and freezes its physical cell/context.
Whole C callees and the scalar member-store consumer ask for the full range.
There is no indexed-callee text fallback and no special case for a particular
member name, rank or source method. The existing body-empty structural guard
no longer performs an unused head resolution for nonempty call Frames.

Earlier callable-role resolution is still separate from this representation
selection. This is **not a claim that the whole call resolves exactly once**.
The [counter-only fixture](witnesses/used-scope-20261020/ready-member139-query-test.c)
measures calls to the actual `l2_path_root_resolve`: old138 atom2/call5,
intermediate139a atom1/call3,139b and final139e atom1/call2. The atom is a deliberately
constructed compact atom; the call is actual P0 `p\tick(5)`. These are query
observations, not a language limit or a substitute for source-value tests.
Final profiles03 complete on the exact frontend C with only the counter added;
both old/new fixtures compile and return0. No query-count threshold replaces
source or semantic admission.

## Indexed callees and observed source values

The old138 compiler successfully translates and executes the literal-index
C function-pointer call. Intermediate139b accidentally restricted its Frame
selector to `indexed=0` and refused this valid source at emission. That
candidate was **not published**. Its patch and2096-pin terminal receipt remain
separate evidence;139e removes the narrowing and projects the full prepared
step sequence. A later139d frontend preparation also failed strict C compilation
because a local Structure field was written with pointer rather than dot
syntax;139e corrects that source error, without relaxing diagnostics.

The following three independent positive sources execute the selected C
function, assert result12 and count1, and request exit7:

- [Literal index](witnesses/used-scope-20261020/ready-member139-literal-probe.lm2):
  old138 GREEN,139b emission refusal; final139e GREEN in both root modes.
- [Local index](witnesses/used-scope-20261020/ready-member139-dynamic-probe.lm2):
  old138 writes undeclared C identifier `k`,139b emission refusal;139e uses
  the actual selected local binding and executes successfully in both modes.
- [Deep mixed path](witnesses/used-scope-20261020/ready-member139-mixed-binding-probe.lm2):
  six pointer/member/index transitions followed by an indexed callable.
  Old138 emits unbound `k`/`j`;139b refuses;139e performs the actual call.

Fixtures [steps ABI](witnesses/used-scope-20261020/member139_steps.h) and
[predef](witnesses/used-scope-20261020/member139_steps.h.lm1) are test-only C
declarations. Index0 deliberately selects a different behavior; the sources
use index1 and the observed count/value distinguish the selected function.
This is not merely successful L2 or C translation.

The [nonindexed call source](witnesses/used-scope-20261020/ready-member139-call-probe.lm2)
also observes by-value isolation, function effects and pointer persistence:
result12/count1/global0, then result17/count2/global17. The published136
aggregate and138 hidden pointer/index programs are rerun unchanged.

## Positive cases that remain open

The [statement call](witnesses/used-scope-20261020/ready-member139-statement-open.lm2)
is a real native semantic RED. Old138 and139b strictly compile but emit
`t->tick = 5` rather than invoke the C field. Actual execution requests exit80
instead of required7 in both root modes. Old/new generated C is byte-identical,
including the final139e observation02 with the fresh matrix runtime.
It requires a common callable/receiving-role contract, not a parenthesis or
statement-only permission. Its original positive expectation remains open.

The [effectful index](witnesses/used-scope-20261020/ready-member139-mixed-probe.lm2)
retains required result12/count1/index-count1. P0 actually retains the index's
C-call Frame; the head-shape probe confirms this. Old138 and139e still fail
strict C compilation because the generated opaque L1 bracket leaves
`c.member139_steps_index()` unlowered. This is a downstream index-expression
projection defect, **not evidence that P0 lacks the call**, and is not fixed
by the successful mixed-local-index source.

The [mixed member write](witnesses/used-scope-20261020/ready-member139-store-probe.lm2)
requires an actual persistent value23, observed through an independent getter.
Old138 and139e both refuse during CHECK with `unsupported index` for the
NAME-after-INDEX receiving path. Its positive expectation is unchanged; the
native full-range projector does not close this earlier checking gap.
[Cells ABI](witnesses/used-scope-20261020/member139_cells.h) and
[predef](witnesses/used-scope-20261020/member139_cells.h.lm1) preserve the source.

None of these three REDs is an accepted negative language test. Opaque member
target/callee freezing, index-effect ordering against later RHS/actual effects,
remaining atom/index/deref readers, shared per-step contracts/maps and foreign
capture/value transport remain open. No invented C-field type, `typeof`,
native-only protection or runtime name registry is added.

<a id="l2-and-walker-scope"></a>
## L2 and walker scope

[L2 scope](../docs/L2_spec_en.md#scope) explicitly assigns stored L3 to the
interpreter and machine L2 operations to native lowering; the
[ABI contract](../docs/L2_spec_en.md#lowlevel-abi) governs C boundaries.
The earlier138 direct-C-factory forced-root `UNSUPPORTED`/exit3 observation is
retained, but it does **not** create a requirement to interpret arbitrary C.
Forcing an L2-only root out of its native implementation measures this coverage
boundary. It is distinct from a real L3 native/walker mismatch or the incorrect
native statement-call behavior above. The successful programs' C bodies remain
native even under a walked root. The separate field/Array36 tests exercise
genuinely forced-walker source operations and actual mapped values/addresses.

## Regression execution and identities

Final139e session89061 completed frontend84/0 (same old13584/30 assertion FAIL),
indexed82/0 and field/Array/read/write/taken-address36/0 **each native and forced
walker**, then stopped at metadata's stale139b source-hash preflight before
creating its output or starting a metadata test. Session48057 resumes only
metadata with the correct final139e source pin and completes336/0. Its next
matrix preparation stops before translation/compilation at a separate stale
executable pin. Both guarded attempts are terminal1, not test timeouts; their
earlier completed phases are not duplicated.

Session67745 (`verify_05`) is **terminal0**. It builds a fresh runtime and
all85 L2/L1/C/GCC/link units, then performs170 actual runs: **162 GREEN and
the same8 copy-positive REDs**, with unchanged modes, binding counts and exits.
Worker16724,startUTC `2026-10-21T20:37:09.6125610Z`;341 selected prior inputs
are independently checked. Four foreign runs13/17/13/17 and the three
published aggregate/hidden-pointer/member-call programs link that fresh object.
The three indexed-callee sources separately run13/17 each on the same object.
Final query profiles03 repeat atom2→1/call5→2; the statement and two additional
open sources retain their actual RED observations.

Exact final generated indexed-unit loss controls each compile/link and finish
SAME82 with2 assertion FAIL,exit1 for wrong owner or late target reselection.
The additional callee control changes exactly the `ticks` callee selector
from index1 to index0 in the final generated literal unit, leaving argument5
and the source oracle unchanged. Both root modes
then actually request80 instead of7, driver exit1. Thus actual function/value
selection is observed, not just a syntactically accepted call.

```text
compiler source E7A031C9E8F3FD3EEA0AE21BA79A100732EDCC6166C15CF7EF81D406BF8EB32B
frontend C     8029B1EF8DBB8AAC9A1EAD15B00292D4B148F0FAB345D989BE5F264D5F4F95EB
frontend EXE   C02764111A45E12F0EA76B8C6081AA103B74DB49B90FFCAEE7A951D33BFFE737
runtime C      471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh object   F4ACE0E43220E0265EEEAE333B4C72E5327AB5436C7E25381623A742CF456636
one-source U0  7BCDF7F593204775AFD6111A71EE67D788A755F320C1FBDCA98C5EA768D1C23E
```

Final receipt `build/codex_member139_terminal_03.inputs.sha256` contains
**2751 pins**, SHA256
`9D10B29A154B6856079E31E47BE15C48F69BF7FA02695C7EB95AB25EC195307E`.
The [evidence summary](witnesses/used-scope-20261020/ready-member139-evidence.json)
records the exact identities and boundaries. Named source/output/fixture roots,
original positive and RED witnesses, recipes, tools, local quoted dependencies,
intermediate observations and parent receipt digests are pinned. The conservative
scan still reports `decNumber.h`; full system/preprocessor closure is not certified.
Receipt02 is retained;03 adds the explicit test include roots to the scanner.

Recipes retain exact commands: `build_05` → `verify_03` (first3 focuses) →
`verify_04` (metadata) → `verify_05` (`values_03`, foreign/controls/published/
statement, `steps_05`, `queries_03`) → `callee_control_01` → `terminal_03`.
These are transitional PowerShell tests and test-only C ABI predefs, not
the handwritten-L1-free, language-owned self-build required by §8.

Earlier139b verification stopped at a separate disk-space preflight after its
first three focuses.1219 explicit frozen generated C/object/executable files
from four named receipts were NTFS-compressed; every before/after SHA matched.
No deletion, move, directory/system compression or protected diagnostic access.
Free space rose262774784→1094156288 bytes; the operation ledger is preserved.
Only the unstarted phases were then run, on139b. Those results remain historical,
not final139e evidence.

Public dev, last full1121011 FAIL/3754, the same eight copy-positive REDs, clean
kernel, two actual L3/L2 self-built generations and mail T01–T26 remain OPEN.
Goal ACTIVE; Codex sole writer/build. No pause, replacement goal, new timer,
branch/worktree/PR. Unrelated WIP and protected diagnostics are excluded.
Both documentation generators pass; staged check_docs7144 and diff checks pass.
All2751 terminal inputs were independently rehashed after regeneration/staging.

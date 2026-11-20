# LMX core architecture

**Binding and callable norm of 2026-11-19: accepted, not implemented yet.** The author accepted a new norm for
binding, `private`, the structural call, `return` in data, and `fn` signatures
([TZ](docs/new_parts/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), decisions R01–R18). The translator,
the clean-graph interpreter, the kernel, the examples, and the tests do not execute it yet; the work is recorded in the
plan section [binding-callables-20261119](next_core_tasks_v3.md#binding-callables-20261119). Sections 3, 4, 5.1,
and 9 keep apart the **norm of 2026-11-19** and the **current representation (former norm)** that the code still
implements; §3.4 compares them. The dated slice notes between this status and §1 describe the implementation of
the former norm. `private:` acts in both directions for all implicit dynamic binding; it is a filter of one place,
not an access-control system, and the common binder is used
([private-binding](docs/LMX_semantics.en.md#private-binding), [private-examples](docs/LMX_semantics.en.md#private-examples)).
The former one-way wording ("`private:` excludes the field from dynamic binding of calls") and its
[M14 task](next_core_tasks_v3.md#private-binding-plan) belong to the former norm.

**2026-11-15 replacement:** [call frames without write-back](docs/LMX_semantics.en.md#call-frame-20261115),
[M14 and sys tools](next_core_tasks_v3.md#native-structures) replace load-dirty, local publication,
shared caching, flush, and frozen physical-slot requirements. Dated receipts below remain implementation history.

**Dated implementation notes (slices 376–402).** The paragraphs between here and §1 record what particular slices built
and measured. Each of them describes the implementation of the former norm (before 2026-11-19); the norm in force is
[binding-places](docs/LMX_semantics.en.md#binding-places), [structural-call](docs/LMX_semantics.en.md#structural-call),
[private-binding](docs/LMX_semantics.en.md#private-binding), and [fn-signature](docs/LMX_semantics.en.md#fn-signature);
the replacement is the plan section [binding-callables-20261119](next_core_tasks_v3.md#binding-callables-20261119).
Where a note speaks of the special name `data`, `fncall`, `sub`, executable `fn`/`sub`, substitution of data by
`call(D C)` or `C(D)`, one-way `private`, or the former binding of free names, that is history of the former norm,
not the current rule. The words "current" and "previous" in the note titles refer to the dates of those slices.

Slice402 (2026-11-15), bounded code gates PASS: frozen index requirements and their tables/transfers/emission
are removed. Structure/pointer-Array index operations use actual cells and exact callbacks through the common
ValueOwned store. Invalidation is prepared before the store and completed only after success. Future execution
is not prechecked by a code write; reached machine code still returns UNSUPPORTED. Source09:935, genuine G1/G2
quick, fixedpoint38, actual G2 targeted2 and Graph7 triple PASS. Whole namespace/path/Array receiving and the
replacement call-frame model remain OPEN. [Evidence402](steps/witnesses/m14-raw-index-20261115/notes.md).
The complete author documentation package is accepted as92902ada; final G2 docs/index checks pass35/14/27/44/615,
with LF28297. The full replacement execution model remains OPEN.
Work and commits stay directly on main.


Slice393 (2026-11-14), bounded code acceptance and docs-check PASS, on main after accepted392/b2899ec9: the existing implements resolver borrows an optional
Graph SourceReader. Physical facts retain their meanings; exact source descriptions and receiving chains are
separate borrowed evidence. One named mapper preserves unknown masks through all four routes. The generic pure
interface entry owns require_root/drain/close(published0); @3 construction retains raw Model/default and never
runs test or reads reference payloads. All33 cell rows/qualifiers/names/refs/index-ref7 passed private L2 n/f root0/1,
private23 triple/negative AFTER15 PASS. Actual G1/G2 quick/fixedpoint15, G2 interp23/AFTER22/image48 and legacy2 PASS.
Source09 only strengthens the unit oracle; actual G2 Unit08/final canonical2 PASS without rebuilding unchanged artifacts.
Render35/14 and fresh docs-check01 PASS35/14/27/44/615, links/LF28263; the final index is the precommit gate.
Full storage/runtime/ABI and M11/M13/M14 remain OPEN.
See [evidence393](steps/witnesses/m11-declared-facts-20261114/notes.md).

Current slice391 (2026-11-14; lexical actual-DATA fix, code gates and docs-check PASS), accepted/pushed base390/78041191 on main:
only Run changes. Its private pure projector reuses step_index/occurrence and binding_method for the exact selected fn;
Graph75/Run58, APIs and layouts are unchanged. A numeric index preserves the immediate Frame and does not reinterpret
a selected WORD as an atom/F. Lexical atoms audit pending DATA/CODE scopes, not EXPR; mutable kind6 stays deferred.
Actual F.data is direct kind4 and follows the generic Structure rule, without a field-name exception.
Source03/private48 triple/AFTER39 PASS was interim. Bootstrap01 was stopped after actual F.data pending scopes gave raw4 instead of2.
The new read-only construct_data_scope proves lexical DATA by FN-result owner and exact data identity, including bodyless descriptors.
Actual DATA is not a materialization queue and is not executed; the source blueprint stays untouched.
Runtime03 SHA6a610534/Graph03 SHA7aad957d PASS: method/descriptor now give raw2/2 and data width2/2.
Six sources/five expected files now include construction_paths_owned_data; the combined18-context/31-leaf-oracle probe,
FnData runs2(initial11/bare8/9/held11/current9), runtime refusals3/4 and build4 remain.
Private02:49 triple/negative AFTER39 PASS; the previous43 expected files are unchanged. Whole boot-m11-construction-paths-02
on Source05 PASS: genuine G1/G2, nine smoke rows each; fixedpoint15/verify907/Runtime03==G2driver PASS.
Final frozen Source07:907 SHA329fba48883be5014759e1fc74c4236873286c6050b69567c4ce3206f23ce9c3:
intermediate06 removed extra end markers from two fixtures after bootstrap ended;07 only removed EOF blank lines from six new sources.
Full AFTER2, ten exact generated native/forced programs matching actual G2 case outputs and the build4 control PASS;
fixedpoint03: all15 comparisons/verify907 PASS. Code/compiler inputs are unchanged, with no extra rebuild or whole bootstrap.
The genuine G2 Graph was rebuilt:
SHA0cc869f7c12b9b3d7ae57aec8957602fcfaabe0750759ab9f5a131195f17b5a5. G2 repeat49 triple/negative AFTER39 PASS.
Render35/14 and fresh docs-check01 PASS35/14/27/44/615, links/LF28142; generated content/grammar unchanged, final staged index follows.
Typed/qualified lowering, the future borrowed typed/name/fact bridge to the shared worker and interface admission
M11.7/M13, runtime merge/fromLmx construction and full M11/M14 remain OPEN. See [evidence391](steps/witnesses/m11-construction-paths-20261114/notes.md).
Work and commits remain directly on main.

Current slice390 (2026-11-14; bounded constructor code acceptance and docs-check passed): Builder explicitly runs owned construction
after filling P0 fields and before pure preflight; Graph75 fresh-push/Run58 construct. A stored F remains an ordinary
current value; the next walk creates a fresh F, without transplanting temporary bindings. SOURCE references materialize
outside fn args/method DATA. Visit the CODE of every actually created F, including DATA copies, without rewriting its blueprint.
Mutable aliases/FREE/formals/pending values remain deferred, without fixedpoint/backfill. Native images preserve FN role
through the existing map, profiled node role, fields/parents, with no host pointer. Runtime03 SHA0633c73b/Graph02 SHA1c7ea326,
frozen Source05:896 SHAfe85448c:18 standalone interpreter probes and2 FN-image cases in interp/native/forced PASS.
Private43 triple/negative AFTER33 PASS; whole boot-m11-known-data-01 quick PASS with genuine G1/G2, nine smoke rows each.
Fixedpoint15/verify896/privateRuntime03==G2driver PASS. The genuine G2 Graph was rebuilt:
SHA17d12ce77360e99af075fb90967e0b7aef76f94985566a89e49b617d4bfd058a. G2 repeat43 triple/negative AFTER33 PASS on ready binaries.
All code gates390 PASS; render35/14 and fresh docs-check01 PASS35/14/27/44/615, links/LF28087; final index before commit.
Dynamic construction merge/fromLmx, source-known paths/type fields and full M11.7/8/M13/M14 remain OPEN.
See the [390 handoff](steps/handoff/m11-known-data-references-20261114.md). Work and commits remain directly on main.

Current slice389 (2026-11-14, bounded code acceptance and docs-check passed): Run57 binds CODE declaration sites to existing DATA rows, while bare WORD bindings
are formal-first. Self preserves exact physical occurrences; distinct CODE projects a unique DATA name.
A stable destination token is selected before the RHS and recovers the same row afterwards. Graph74 and C layouts are unchanged.
fn_data retains explicit CODE sites even with same-name formals; existing written DATA prevents auto-add regardless of kind.
The root occurrence regression now yields seen3; ambiguous bare names still refuse3. Seven new paired fixtures,
private36 interpreter/native/forced and negative AFTER18 PASS. Runtime05/Graph02 include the copy-cursor fix.
Frozen Source07:882 SHA58c44120bda44300403dcb057719be1c6395488c694ebe5b4c8c2a4b46355fd6;
Runtime05 SHA92f2ee24. Whole boot-m11-place-sites-01 quick PASS: genuine G1/G2, nine smoke rows each.
Fixedpoint15/verify882 PASS, including Runtime05==G2driver and retained Graph74/Run57 headers.
The rebuilt G2 Graph is SHAa883ec4cdacc71f49bd3d0437df19542d1f261c8b59d8b55cc65a4bb2d8f4a5b;
code tuple: stage/boot-m11-place-sites-01/g2 + graph-m11-place-sites-g2-01. G2 repeat36 triple/negative AFTER18 PASS.
Normal semantics render PASS35 paired/14 cases; grammar unchanged. Fresh docs-check02 PASS35/14/27/44/615, links/LF28085.
Final index03 and commit/push follow. Full M11.7/8/M13/M14 remain OPEN; next is
[known references in written DATA](steps/handoff/m11-known-data-references-20261114.md), without DATA autoexecution on step.
See the [slice389 evidence](steps/witnesses/m11-place-sites-20261114/notes.md).

This is a compact kernel map, not a second language specification or a
checkpoint diary. Normative sources are the paired
[L2 specification](docs/L2_spec_en.md), [L3 semantics](docs/LMX_semantics.en.md),
[grammar](docs/LMX_grammar.en.md), and
[L1 contract](docs/L1_spec_en.md). The binding and callable norm of 2026-11-19 is accepted in the
[TZ](docs/new_parts/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md); its normative text is in the semantics
anchors named in §3. The active migration order is
[next_core_tasks_v3.md](next_core_tasks_v3.md); older dependency evidence
remains in the [pinned v2 snapshot](https://github.com/michael0xf/LMX/blob/0e0a2978eb237e145e54715de805a88e65264ba4/next_core_tasks_v2.md). An intended invariant below
does not claim every current implementation path already satisfies it.

Current implementation note (2026-11-14, slice388; bounded code readiness, G2 repeat20/21; accepted base387/9897c99f): Graph74 shares an occurrence reader
for anonymous [WORD(decimal),WORD(name)] pairs; a literal WORD is always literal. size_t is checked and reader outputs survive refusal.
Run54 step/step_place and runtime/admission/native consumers use raw steps; literal access interns/allocates nothing, with no new tags/state/layouts.
Builder replaces manual splitting with existing P0→expression for compound path/index/exact heads, keeping WORD heads ordinary and nonWORD heads as carriers.
P0 shares scan_head between main/lookahead and compact_piece→scan_quoted; whole-token/global boundaries remain unchanged, with a local compact-colon fix.
Runtime03 SHA9b1f3ad1/Graph02 SHA91ae4fee and all new13 triple(8 positive+3 runtime refusal+2 build2;11 expected) PASS.
Private21 initially gave18 PASS/3 FAIL; two old occurrence goldens changed only outer RHS parentheses, with no numeric change.
Eight full AFTER seed/new/binaries and nine negative AFTER comparisons PASS through reuse. Aggregate20/21 retains root_occurrence_index runtime3
on both seed387/new, with expected seen3 preserved: OPEN common site→existing frame-row fix without a root bypass, then M11.7/M14 alignment.
[389 contract clarification](steps/handoff/m11-place-sites-20261114.md), bounded code acceptance above: a CODE declaration selects only mapped DATA;
bare WORD reads/stores remain formal-first. Self identity is a shared case even with a same-name formal; Code over another D uses
a unique canonical name/existing correspondence, not the source index. fn_own→fn_data retains an explicit CODE site as method own DATA
even with a same-name formal; bare/formal/dynamic inputs create no DATA place, and arbitrary supplied D is not extended.
Select the destination token before the RHS; recover the row after the RHS by its stable token index, without another name selection
or a pointer into reallocating rows. Physical DATA initialization stays unchanged; docs-check389 passed above and full M11/M14 remain OPEN.
A separate preexisting written-DATA `@: pick a` remains raw/step5 even for one reference: a construction/admission gap, not selectors or duplicates;
step must not autoexecute DATA(R12). Frozen Source06:867 SHA19d3d5dc, verify/stage-copy PASS; Source04 built code,05 added fixtures,06 changes only two old goldens.
Whole boot-m11-selector-encoding-01 passed in existing sol-m11-construction-fresh01/main: genuine G1/G2, nine smoke rows each.
Fixedpoint15 PASS: FE/tool L1/C, driver/observed, retained Graph/Run headers, privateRuntime03==G2driver,
normalized executables, backend and FrozenSource06/verify867. Source06 code is unchanged. Code tuple:
stage/boot-m11-selector-encoding-01/g2 + graph-m11-selector-encoding-g2-01, G2 Graph
SHA0fcf70f9e9c41f04b2912ce1930cb256bd14afde87c0072a6acd330dd937236c.
G2 repeat21 gave20 PASS/1 FAIL only root_occurrence_index in interp/native/forced; all13 new cases PASS, negative full AFTER9 PASS by reusing binaries.
Normal G2 render semantics and docs-check01 PASS35/14/27/44/615, links/LF27962; grammar unchanged.
Final index-check02 PASS, links/LF28021; commit/push388 to main follow.
No all21 PASS or full M11.7/8/M13/M14 claim, and no legacy frontend claim.
See [record388](steps/witnesses/m11-selector-encoding-20261114/notes.md) and the [main plan](next_core_tasks_v3.md#m11), goal ACTIVE.

Previous implementation note (2026-11-14, slice387; accepted/pushed9897c99fd55408cab3531af809bb885dab5ea85e): Graph73 declaration_view reports
default presence without evaluation; Run54/shared binding separates pure source-known shape from existing runtime guards.
Source07:843;12 maintained sources and5 expected files were added. Seven build refusals include the BODY exact-header guard regression;
positive controls give7/7/9,effects0; broad presence check0. Chars runtime3 on seed386/new is the prior limitation;
the indirect runtime guard gives5/effects0. The formal/data/pending probe constructs with0 and runs with5 on both, not result7.
Frozen Source06:843 SHA19dbb3ff5cc94e2c75ea34ce1b0534528babe3495171988d7c2fbf7f400bebde. Fresh stage
P/sol-m11-construction-fresh01 had neither Run header before bootstrap(False/False). Existing runtime→frontend objects→link
passed whole quick with genuine G1/G2, nine smoke rows each; fixedpoint13 includes retained Run.h, verify843 PASS.
Code tuple: boot-m11-construction-shape-01/g2; G2 Graph SHAd816ba5c2e71006183d9d9f7f99750487f5dc992b899f7426e7c939a9a2d95f6,
runtime SHAff20e0647b81bee07eb81145bc132f2cd30f402dfacc2eb18fedd30172fc74e9. All new11 triple +presence check
(12 sources/5 expected) PASS, broad masks check0; G2 BODY exact-header guard refuses build5. Three indirect-guard full AFTER checks passed by reusing binaries.
Initial extended22 gave21 PASS/1 stale known_assignment failure. Only its source/golden were migrated: initialized i1,
before_publish1, real checkpoint() calls before first5/second7, formal @:target Box and current RHS grouping.
Only this case was rebuilt, interp/native/forced PASS; seed386 and G2 full AFTER match its new golden.
All22 cases are accepted through21 reused results plus the migrated case; the full22 were not rerun. There is no alias defect:
working locals and physical cells differ before publication. Final Source07:843
SHAcbaac64eb9a44d3cbc338a230499f0f319057bad557628f4c876c9c3be326615 differs from06 only in the two known_assignment files;
code/compiler inputs are unchanged, verify/stage-copy PASS. Whole bootstrap used06; final fixedpoint02 repeated13 clean comparisons/verify843 on07, PASS.
This does not complete full M11.7.
G2 render semantics35 paired/14 cases/both snapshots and docs-check01 PASS35/14/27/44/615, links/LF27906;
grammar unchanged. Final index-check02 PASS, links/LF27961;387 was accepted and pushed as9897c99f, preserving the two foreign files.
Full implements/test, dynamic/path/group contracts,
quoted selector and M11.8/M13/M14 remain OPEN; [record387](steps/witnesses/m11-construction-shape-20261114/notes.md),
continue the [main plan](next_core_tasks_v3.md#m11), goal ACTIVE.

Previous implementation note (2026-11-14, slice386; bounded code acceptance passed, base385/9edf9666): admit_paths locally applies
target(model/candidate) once before the existing kind4 gate and used-path/type checks. Resolver and returned actual
remain unchanged, preserving the selected snapshot; no recursive unwrapping, physical Model lookup, cache, copy or publication.
Run53/Graph72 layouts stay unchanged. Runtime01 SHA075c4f9f/Graph01 SHA7317b6d5 and private10 triple/6 negative full AFTER PASS:
snapshot9/9/20, index7/8/9/NONE1/unused cycle10+self_len3 and refusal4/body0.
Frozen Source02:826 SHA59768bbe. Whole bootstrap01 quick passed genuine G1/G2, nine smoke rows each; fixedpoint13/verify826 PASS.
Genuine G2 rebuilt graph-tool SHA908154b9bbcefb94eddf238f0d93248087f171abbec9fee91e396ed1c7c7739e;
G2 repeat10 triple/6 negative full AFTER PASS. Working code tuple: boot-m11-admission-values-01/g2 + graph-m11-admission-values-g2-01.
Render35/14, docs-check35/14/27/44/615, final index02 and diff-check passed;386 was accepted and pushed as713af718.
Static preflight, full implements/test, quoted selector and M11.8/M13/M14 stay OPEN.
See [record386](steps/witnesses/m11-admission-values-20261114/notes.md) and the [main plan](next_core_tasks_v3.md#m11), goal ACTIVE.

Previous implementation note (2026-11-14, slice385; bounded implementation, acceptance passed): generated primitive-profile data
feeds the common declaration view, preserving physical cells and data/receiver-pseudoformal projections; Graph72/Run53 layouts stay unchanged.
Source05:816 is frozen, SHAde6f1d57. Graph03/private03 checked quoted7/arity2/escaped8/arity1;40 private full AFTER checks passed.
Whole bootstrap01 quick passed genuine G1/G2, nine smoke rows each; fixedpoint13/verify816 PASS.
Genuine G2 rebuilt graph-tool, SHAe742dba04a06366ab8e45ab921f145a7d5b0bac4dc23142600e43093f3114021;
G2 repeat15 in three modes/21 negative full AFTER PASS. The working code tuple is
boot-m11-formal-declarations-01/g2 + graph-m11-formal-declarations-g2-01. Normal render35/14 and docs-check35/14/27/44/615 passed;
final index02 and diff-check passed;385 was accepted and pushed as9edf9666.
Array runtime and full M11.7/8/M13/M14 remain OPEN; these checks accept bounded declaration descriptions.
See [record385](steps/witnesses/m11-formal-declarations-20261114/notes.md) and the [main plan](next_core_tasks_v3.md#m11), goal ACTIVE.

Previous implementation note (2026-11-14, slice384; bounded implementation, code acceptance passed; base383): Run-only, Run53/Frame ABI unchanged.
Common bind_formals no longer has by_head/mode2; direct fn/sub labels use only `:=`. Structure actuals pass through
common read_received_value(contract2): written groups remain inert, unknown named args/data/code Frames produce reached refusal3.
Word name/return written-description handling and `@: c.FILE` remain supported; colon fields in a whole-DATA descriptor stay data.
fn_decl_name is a pure graph-only query distinguishing direct positional/name:= actuals from one whole-DATA descriptor,
without recursive unwrapping, lookup/evaluation or Space. Runtime01/Graph01 and18 pure checks passed.
Private01 ran32 cases:29 PASS triple, two old synthetic-RHS golden mismatches and one static-name emit5.
Only13 RHS parentheses lines changed in fn_prepared/call_receivers; seed383 AFTER6/6 matched, with numbers unchanged.
Existing binaries were reused: private-after01 CHECKS89=87 full AFTER+2 baseline PASS. Private02 rebuilt only two changed fixtures:
name_refused(computed args:=held_args, reached5/before1/after0) and fn_name_call(finally at_end1/refusal5), both triple PASS.
A direct written unsuitable name refuses5, not unknown3. Mutation24 PASS; Runtime01 driver SHA210c8f72/Graph01 SHA5f7bd3b4.
Source03:798 is frozen, SHAac0d0a1c; eight fixture pairs and fn_name_call.expected were added. Genuine G1/G2 quick,
nine smoke rows each and fixedpoint13/verify798 passed. Genuine G2 rebuilt graph-tool, SHA09f0e983;
G2 repeat32 triple/21 negative full AFTER/mutation24 PASS. Native-receiver-actuals02 traced actual native
root→fn_apply→receiver_bind(evaluate1)→producer body0, effects1/later0/before1/after0 and expected host exit1.
The first missing-argv01 is retained as unaccepted proof. Normal render/docs check384 passed:35/14/27/44/615, links/LF.
Slice384 was accepted and pushed as62072bca, preserving foreign WIP.
The code tuple384 is boot-m11-receiver-actuals-01/g2 + graph-m11-receiver-actuals-g2-01.
Full formal-validation remains OPEN before M11.7;
use a common declaration view and canonical primitive catalog, not a narrow machine whitelist. Legacy frontend by_head
is M11.8 OPEN; general external/computed CodeBody and full M11.7/8/M13/M14 remain OPEN. Acceptance is limited to this code slice.
Include all subsequent work in the [main v3 plan](next_core_tasks_v3.md#m11); [record384](steps/witnesses/m11-receiver-actuals-20261114/notes.md).

Previous implementation note (2026-11-14, slice383; bounded implementation, code acceptance passed; base382/d0e384c1): only Run changes,
with the Run53/Frame ABI unchanged. One resolver separates a pure query from a consuming read with caller-local status.
The first actual read of an unbound raw fn/sub prepares its reached owner scope through existing space_declarations/evaluate0.
Neither the copier nor fn_data creates bindings or transfers SourceSpace; enclosing node reuses exact source/parent proof.
Ten pure cases passed: raw fn1/2/sub2/marks25/source3, unentered1/2, name7/7; held aliases8/8/8/9 at source3/next4;
clone4/5/source3; descriptor5; malformed5/before1/after0; pending3/touch0; ambiguity3; run2 reset source1/held3.
Private34 ran in three modes:32 matched; reference_alias/descriptor_merge needed only four pre380 synthetic-RHS
golden parentheses lines. Six baseline AFTER checks on seed382 matched; numbers stayed unchanged. All102 full AFTER checks on
the same34 binaries and mutation24 passed; actual native root→consuming declaration read→scope preparation traced7/7/normal exit.
Source01:761 built code,02 adds20 fixture inputs,03:781 changes only four golden parentheses lines, SHA4a7ed184.
Genuine G1/G2 quick, nine smoke rows each and fixedpoint13/verify781 passed. Genuine G2 rebuilt graph-tool,
SHA10dbb1b4. G2 repeat34 triple including runs2/negative AFTER33/mutation24 and normal render/docs check383 passed:35/14/27/44/615, links/LF.
The working tuple is383: boot-m11-copy-bindings-01/g2 + graph-m11-copy-bindings-g2-01. Both copy classes have bounded
private proofs; general external/computed CodeBody, M11.7/8 and full M11/M13/M14 remain OPEN. Native copied callees in
M14 are not accepted by the native caller/scope trace. Acceptance is limited to this slice. See the [main plan](next_core_tasks_v3.md#m11).
The direct fn/sub label boundary and whole descriptor DATA colon fields passed code acceptance384.
Before step7, full M11.5e formal-validation remains OPEN: structural formals in args refuse during method construction,
through the common declaration view/canonical primitive catalog. Binder356, copy383 and bounded384 do not close full M11.5e.

Previous implementation note (2026-11-14, slice382; bounded implementation, code acceptance passed; base381/38cf026c): common Run.code_body53
returns a borrowed body/from/to view through existing argument roles. An else/finally whole tail selects its sole
written group once. Already selected method/ordinary/if/loop bodies are not unwrapped again; a remaining standalone
inner group stays a value. Finally runs during unwind. Scanner, fn_own, walker, native and code_parent use the same
view without changing physical holder/parent, selected code/data or the activation. Runtime01/Graph01 built from
Source01:751 passed five pure cases: calls4, unwind21, written790/computed890, own late7/return4-after5/inert0
and an inert missing group; error6 retains cleanup/root trace21. Source02:761 adds only five fixture pairs,
SHA be5db8e3. Private25 triple/AFTER75/mutation24 and actual native written/computed outer trace passed;
genuine G1/G2 quick, nine smoke rows each and fixedpoint13/verify761 passed. Genuine G2 rebuilt graph-tool,
SHA f71df095. G2 repeat25 triple/negative AFTER21/mutation24 and normal render/docs check382 passed:35/14/27/44/615, links/LF.
The working tuple is382: boot-m11-codebody-01/g2 +
graph-m11-codebody-g2-01. General external/computed CodeBody coverage, fresh bindings for copied raw fn/sub,
held-F copying as Structure followed by an explicit fn constructor, M11.7/8 and full M13/M14 remain OPEN;
Acceptance is limited to this slice. See the [main plan](next_core_tasks_v3.md#m11).

Copy-reading clarification (2026-11-14): a raw declaration and its current F are separate values.
Copied raw fn/sub in `merge(scope)` gets a fresh binding from copied actuals; SourceSpace bindings never transfer.
A held F actually reachable through the graph copies its current parts/data/aliases as an ordinary Structure,
without an automatic FN role. A later explicit fn creates fresh F/D through the common constructor.
The warm3 → clone call4/source3 control belongs to explicit `fn:clone merge(leaf)` after warming the source,
not to plain `merge(scope)`. The previous candidate inheriting SourceSpace's current F/data into a raw binding is withdrawn.
Both classes have bounded private proofs383; genuine G1/G2/fixedpoint13/verify781 passed.
G2 repeat34 including runs2/AFTER33/mutation24 and docs383 passed; general coverage remains OPEN.
See the [normative reading](steps/handoff/copy-construction-reading-20261114.md).

Previous implementation note (2026-11-14, slice 381; bounded implementation, acceptance passed; base 380/c5ba5ef9): the existing
GraphFrame.lexical_scope selects the physical CodeBody through shared work_scope; body/code/data identity and
the activation stay unchanged. Inline fn/sub names remain lexical while data and the frame are shared.
Name-sensitive pending separates required admission bit 8, dynamic visibility bit 2 and AND-pending bit 4;
an actual external read/write exposes the frozen fallback, a scoped F does not. The 17 pure cases,
67 old full AFTER cases unchanged and private31 triple/AFTER93/mutation24 passed on runtime06/graph02, Source07:751.
Source08:751 is verified, SHA b84c11fe; Graph03/private02-inline triple passed after removal of the duplicate
first-statement scope call, with Runtime06 unchanged. Privacy 178/8/5/5, fallback 10550/outside8,
lexical/reentry/helper 790 and refusal boundaries are preserved. The actual NativeOuter/lexical scope/fn_apply
trace passed; a new dynamic callee still uses walker fallback. Genuine G1/G2 quick, nine smoke rows each,
fixedpoint13/verify751 and the genuine G2 graph rebuild passed, graph SHA b8abfe4c.
G2 repeat86 triple/negative AFTER102/mutation24 and normal render/docs check381 passed:35/14/27/44/615, links/LF. General CodeBody coverage
(else/finally/retained groups), fresh bindings for copied raw fn/sub, held F as Structure and explicit fn construction,
M11.7/8 and full M13/M14 remain open.
See the [main plan](next_core_tasks_v3.md#m11) and [record381](steps/witnesses/m11-computed-body-20261114/notes.md).

Previous implementation note (2026-11-14, slice 380; code acceptance passed): index writes capture the physical
place's requirement before RHS effects in the current GraphSpace, using existing ImplContractFact/CopyMap storage.
Captured NONE survives repeated replacements and constructor copies through merge/fn_data within that execution.
The context is discarded on exit; the next independent traversal derives requirements from the current graph.
This adds no persistent SourceName/port metadata, slot entries in the name table, assignment history, or serialized proof.
Pure cases passed: copy gives 41/2/2/41; an actual rhs() gives calls=1/seen=7;
subtype refusal4 follows effects=1 and preserves old=7; bounds refusal7 also follows effects=1.
The 58 existing pure cases pass; nine targeted fixtures were added. Private67 in all three modes,
204 AFTER including reset2 and mutation24 passed; actual native root/prepare/RHS/write was traced.
Genuine G1/G2 quick, nine smoke rows each and fixedpoint13/verify717 passed; rebuilt G2 graph repeated
68 cases in three modes,84 negative AFTER/mutation24. Normal render/docs checks passed:35/14/27/44/615,
links and LF27563 before staging; final index check03 passed LF27604. [Record380](steps/witnesses/m11-slot-contract-20261114/notes.md).
The previous code tuple is380. Full used-interface implements/test, fresh construction bindings for copied raw fn/sub,
M13 and M14 remain open; bounded computed BODY slice381 is described above.

Previous implementation note (2026-11-14, slice 378; code acceptance passed): common root work frame/block0, native wrapper completion and
forced reuse replace the separate root emitter. Scalar values stand without capture; discarded AST uses the common
value reader and computed body bindings use existing metadata/rows. Runtime01/graph01 and five pure cases passed.
Private01 executed 50 cases in three modes: 48 matched old goldens, 2 required five independently derived root-k snapshot updates;
open_result55 stayed. Existing 50 binaries were reused; added root_frame_error passed triple. All 51 cases executed in
three modes, 153 full AFTER comparisons and mutation24 passed. Source04: 685; whole bootstrap01 quick passed genuine
G1/G2, nine smoke rows each, fixedpoint13/verify685. Genuine G2 rebuilt graph-tool and repeated 51 cases in three modes,
AFTER60/mutation24; runtime01 matches G2. Working tuple: boot-m11-root-frame-01/g2 with graph-m11-root-frame-g2-01.
Normal render/docs check passed:35/14/27/44/615, links and index LF27517; both diff checks are clean.
Actual native root trace01 also passed with a normal exit.
Mapped own int local3/address1/direct1 before publication does not change formal/free-input control7.
Legacy computed-int preallocation in M13 permits neither a row.number address nor forced flush as a substitute.
That M13 work, shared cache/flush/ordinary native M14, path-head calls and full M11 remain open.
[Witness 378](steps/witnesses/m11-root-frame-20261114/notes.md).

Previous implementation note (2026-11-14, slice 377; accepted `04fbf275`): frame opening prepares written fn/sub in selected data/body
before free-input scanning; the existing scope/raw-source binding preserves F and its own data on re-entry.
Two pure cases passed: State 1/2 with leaf/sub counts2 and bumped2; D/C 32/34 with touch_calls0;
bare leaf refuses with 3 before the body when two raw declarations share its name. Source02:673;
private38 in three modes and AFTER45/mutation24 passed. Whole bootstrap01 quick passed genuine G1/G2,
nine smoke rows each, fixedpoint13/verify673. Genuine G2 rebuilt graph-tool and repeated 38 in three modes,
AFTER45/mutation24; runtime02 matches G2. Working tuple: boot-m11-ordinary-nested-01/g2 and
graph-m11-ordinary-nested-g2-01. Normal render/docs check passed:
35/14/27/44/615, links and index LF27467; both diff checks are clean.
Full M11.5г, root-frame, computed ordinary declarations,
M11.7/8 and M13/M14 remain open. [Witness 377](steps/witnesses/m11-ordinary-nested-20261114/notes.md).

Previous implementation note (2026-11-14, slice 376; accepted `9039fa89`): canonical no-candidate int-reference storage,
required formal8 admission and actual native TypeOnly8 have passed private acceptance (Source04: 669,
private36 in three modes, AFTER42/mutation24; direct GDB trace03). Whole bootstrap01 quick passed genuine G1/G2,
nine smoke rows each, fixedpoint13/verify669. Genuine G2 rebuilt graph-tool and repeated 36 in three modes,
AFTER42/mutation24; the rebuilt runtime matches runtime02. The working tuple is boot-m11-uninit-reference-01/g2 with
graph-m11-uninit-reference-g2-01. Normal render/docs check passed (35/14/27/44/615, links, index LF27434);
both diff checks are clean. G2 direct TypeOnly trace01 also passed; M11.7/8 and M13/M14 remain open.
[Evidence and remaining limits](steps/witnesses/m11-uninit-reference-20261114/notes.md).

## 1. Engineering boundary

L3 is the graph-level language. L2 adds machine operations and C99
interoperability. L3 compiles by the same L2 path and its constructed graph
can also be interpreted; L2 machine operations cannot be interpreted as L3.
L1 is generated intermediate code before C99, not the language of the
target self-build. The goal is L3 self-build with explicit L2 insertions,
then unified Message mail; see [v3 §§3, 8, 8a](next_core_tasks_v3.md).

The normal source-selection root is the tracked [selfbuild package](selfbuild/README.md).
The existing language manifest/stage-copy route preserves its src/tools/tests
layout before generation; older sandbox snapshots and six-list preparation
are historical evidence, not an active header/body fallback. Publishing a
source package and accepting its components does not itself close FULL, clean/native,
admission, clean-clone G0, or mail requirements.

A receiver and its argument Structure are formed by one algorithm before
the form is read. What the form is follows from the role of its Structure
in the launch, not from a classification of its head: in data it declares,
in code it is a call of its head ([roles](docs/LMX_semantics.en.md#data-code-roles)). One
expression resolver applies in every consuming position. A consumer checks
the resulting value; it does not secretly suppress or introduce a call.
There is one namespace. The walker uses the existing address-to-name table
to recognize a graph head; the translator sees the parser tree and generated
`native` does not need names for dispatch. This table is not a runtime
variable-binding map. A contradictory rule or need for a spelling-specific
branch is an author question, not a license for a shim.

## 2. Physical graph and identity

The target graph uses one flat Lmx descriptor: parent/length/storage. Native descriptors and capacity
belong to arena tables, not this header. Structure and Array<@> are interchangeable; typed arrays store
actual T elements. All arrays share variable-length allocation/resizing, including service arrays.
Descriptor addresses stay stable; storage may move. L2 indexing is raw offset calculation, including
negative indexes. L3 reduces adjacent dimensions to one index and one bounds check; its element
reference holds an Array descriptor reference plus index, never a cached storage address.
L3 primitive pointers have a distinct type on the common typed foundation.

sys\descriptor returns three actual header-field addresses (Lmx **, size_t *, void **), without proxies.
Writing through its length address does not allocate memory; sys\resize changes length and ensures
storage, sys\reserve changes reserve, sys\capacity reads the arena table. parent/length/sys\storage load
header values, sys\native queries call's descriptor tables. No-argument forms select the data role of the
current activation (former representation: the launch's `data`; norm of 2026-11-19: the actual parent of the
executing Structure, §3.2; for R0, which has no data, the norm does not define this reading). The arguments of
`call` are `args` and `code` (§3.2), and `node` keeps its existing activation contract.
[Target and open implementation](next_core_tasks_v3.md#flat-lmx-descriptor).

The one source graph retains declarations, values, operators, and nesting.
Execution changes declared values but does not replace the program with
a second data graph or AST.

Physical kind comes from the type code of the value's record; model
suitability comes from `implements`. Ordinary and immutable Structures
differ by that code.
An already-created ordinary Structure cannot become immutable in place.
Primitive cells, reference cells, graph-object headers, and typed backing
each have their physical access contract. Raw typed arena storage is not a
second kind of language-level graph Array. Models do not
create per-model C types or per-cell runtime tags.

### 2.1 Value records: one stream per arena

Every arena holds one stream of records: a type code immediately followed
by the value. The type is read from the record; nothing learns a type from
an address, a range or a chunk. Chunks are added without moving records;
the interval index tells ownership only. The type code is not `implements`.
`mark/revert` supports all-or-nothing construction; `attach` transfers
ownership without changing addresses. A Message owns an arena. Another
arena may not silently extend a reference's lifetime. Today's code still
keeps pools of cells of one type and classifies addresses by range: that
is the former scheme, removed by plan M15.
See [L2 §§3–6](docs/L2_spec_en.md#value-record).

### 2.2 The base Array and the separate List

An ordinary graph Array has exactly its fixed element count and no
reserve/resize contract. A Structure constructed as an owned element is
structurally parented to that Array; storing a reference to an existing
Structure does not reparent its referent. The Array's own parent is its
containing source occurrence, so lexical visibility comes from the graph
position; a second name-based context is not invented. Growable
`List`/`DynamicArray` is separate; its backing can move and therefore
cannot store addressable `Lmx` field slots. Adjacent `a[i][j]` indexes a
rectangular Array; `a[i]\[j]` follows a reference to another
Array. `s\[N]field` is a different selector: it addresses the Nth
occurrence of the name `field` at the root level of a Structure used as
`data` -- an occurrence is a form of the data that declares that name, be
it a declaration by a receiver of a place or a structural form with that
head --, not an Array element or a second data-field namespace.

## 3. Callable graph representation and activation

Two layers are kept apart here. §§3.1–3.3 state the norm of 2026-11-19 (accepted; not implemented yet; plan
[binding-callables-20261119](next_core_tasks_v3.md#binding-callables-20261119)) together with the activation rules
it leaves unchanged. §3.4 states the current representation (former norm) that the code still implements.

A callable is an ordinary source Structure `C` executed in the code role; its data role is performed by its actual
parent `parent(C)` ([structural-call](docs/LMX_semantics.en.md#structural-call)). There is no special name `data`,
no separate data part of `call`, and no `fncall`. The `args` parameter of `call` supplies actual values, not
declarations; inputs and requirements are declared in the data of `C`. Every call creates its own namespace.
Only root declarations of the data role and of code prepare that namespace; no branch traversal or graph-reference
walk occurs. Code locals never auto-fill source data. Ready declarations fold at clean-graph construction
without program calls. There is no initializer execution at entry; unused computed inputs are never
evaluated. Types without a value remain.

Actuals replace corresponding frame defaults, suppressing those original initializers. Bare `x` and `@x`
address the same place: the call's own place or, on the transparent path, the caller's place (§3.3). A value or
description put into an own place (explicit actual, own initializer, autofill, former binding) is independent of
its source immediately at entry, even before its first read; references still retain their targets. A write to an
own place never reaches the caller or the source. The transparent caller place is the designed exception, because it
is the caller's place itself: a write acts at once, with no copy-back on exit. The special path `data\x` is removed
([removed-builtins](docs/LMX_semantics.en.md#removed-builtins)); the data field of a call is addressed by `node\x`
or by the ordinary path from the name of the data Structure, `D\x` (executor's reading, Р107). Nested and recursive
calls have independent locals. Direct writes affect actual cells in sequential order, with no separate shared
direct-access cache or flush receiver.

### 3.1 Declarations and execution boundaries

Repeated int: x bump() retains bump(), type reception, and assignment to the visible x; only a repeated
C declaration is omitted. Repeated graph fields remain separate occurrences selected by S\[n]x.
Variables, including const, are visible sequentially from their initial declaration; named Structures
and callables remain bidirectional. New branch-local names are visible there and below, not outside.
Root collection does not expose future code locals. An earlier explicit field read does not suppress
the RHS when execution later reaches that declaration statement.

A declaration on a nested level shadows the outer declaration of the same name
([shadowing-levels](docs/LMX_semantics.en.md#shadowing-levels)): an inner `Text x` shadows an outer `int x` and does
not write a Text into the int place. On the same level there is nothing to shadow and the existing place is used; a
repeat follows the receiver contract: the new right part is evaluated and assigned, an absent right part does not
clear the value, and no second cell appears. After the inner area ends, the outer declaration is visible again with
its own place, write mode, and `private`. A use before a later own declaration resolves through the ordinary outer
path; a future declaration does not block the body, and no pre-pass searches all future declarations. The control
case of TZ §7.4 (a new `int: x` without a right part in a nested inline area, outer `x = 5`, no new callable call;
[inline-declaration-control](docs/LMX_semantics.en.md#inline-declaration-control)) is the executor's reading, not an
author decision (Р106): the place stays `uninit:int`, because autofill is defined between the caller's local context
and the callee's place at a call, while an inline area stays in the same activation; reading 5 would need a new
rule, which the TZ forbids introducing.

Computed inputs use the common field-read mechanism: with @: fptr getFuncPtr(), fptr("hello world")
first calls getFuncPtr(), then invokes its result. @x also evaluates a computed input and addresses
its place. For int: field getValue() in the data of a call, @(node\field) addresses the computed result (the former
writing was `@(data\field)`; executor's reading, Р107), using the existing native l2_tN (&l2_tN) or ordinary walker
result cell, without replacing the source declaration. A ready field retains its own cell address. Ordinary lifetime rules apply; no extra result
heap or special @f() support/prohibition task is introduced.

Mandatory executable-code snapshots at entry are cancelled; own places remain independent and hidden
arguments carry binding without an environment copy: an autofilled value is lowered as a parameter `T`, a
transparent caller place as the hidden address of the caller's cell, and the former binding gives an own place
(§3.3). Graph writes do not clear native. Methods and ordinary Structures share compilation, with `parent(C)` as the
data role and no `D = C`; actual calls determine C signatures.
Known native → native is a direct C call, with ordinary and required hidden parameters, without graph
packaging or a lookup solely to arrange the call.

sys\compile explicitly builds/checks a clean graph without executing the program, translates L1/C,
compiles/links and installs successful native descriptors in call's arena tables, not in a second graph. A missing
suitable native entry starts no hidden compilation, and no permanent cache of all environments or automatic
graph invalidation is added. Former representation: fn/sub/catch have ordinary native fields referencing those
descriptors, and other Structures get no automatic field. Under the norm of 2026-11-19 `fn` describes a signature and
creates neither an executable body nor a native entry, `sub` is removed, and `catch` stays an executable handler;
which Structures hold such a field after the migration is left to the plan, the TZ does not define it.
Remove edit watchers, invalidation tables/links, transfers and generator branches; no replacement dirty
journal, version service, endturn scans, or automatic repair. Compile a unit containing necessary direct
callers: recompiling B does not rewrite already compiled A → B.

sys\endturn exits nested calls through registered finally blocks to the normal turn boundary.
Ordinary catch does not intercept it; no continuation returns to the call site. It does not itself stop
Thread/Message or change running/success. Before the boundary executable edits take effect at an
unspecified time; successful explicit compilation plus endturn guarantees the update at the next entry.
Endturn alone does not detect, compile, check or publish anything. Old code remains alive through cleanup.
sys\toLmx(Thread) saves the selected Thread and its arena tables, including call/native; ready binaries
can be restored after a same-platform restart by module/entry identifiers, without retranslating.
[Agreed norm; implementation OPEN](docs/LMX_semantics.en.md#explicit-compilation).

### 3.2 Structural call, data role, and signature (norm of 2026-11-19)

With `C` the Structure selected for execution
([call-receivers](docs/LMX_semantics.en.md#call-receivers), [structural-call](docs/LMX_semantics.en.md#structural-call)):

| Form | Executed | Actuals | Data role |
| --- | --- | --- | --- |
| `call(C)` | `C` | none | `parent(C)` |
| `call(A C)` | `C` | the Structure `A` | `parent(C)` |
| `C()` | `C` | empty tail | `parent(C)` |
| `C(args)` | `C` | the written actuals, by the common selection | `parent(C)` |

The parameters of `call` are `args` and `code`. The one-argument form requires `code`, the two-argument form requires
`args` and `code`, so `call(code := C)` does not fit the two-argument form. `call` executes the selected `C` itself
and does not search a child field `code`. A call cannot substitute other data: the structural link is created first
(declaration, copy, merge, by their `parent` rules), then the selected occurrence is called.
`NewContainer: ExistingCode` stores a reference and leaves `parent` unchanged. The former `call(D C)` and `C(D)` no
longer substitute data: the first argument of the two-argument form is `args`. `call(C)` is not `call(C C)`: a
Structure is not its own data. A bridge or dispatcher of `call` does not replace the caller's context with its own
service locals. `node` stays a reserved operation and keeps its activation contract for the selected occurrence.

**R0 has no data** ([root-entry](docs/LMX_semantics.en.md#root-entry)). It is a procedural entry without arguments:
no artificial `D = C`, no empty service Structure, no artificial field `data`. Its own executable declarations and
ordinary reachable references remain. Runtime launch parameters and the host scaffold's access to the graph are not
user actuals. In which role the records of the unit root are read, when R0 has no data, `sub` is removed, and `fn`
only describes a signature, is an open question to the author
([unit-root-roles-20261119](LMX_blog/q/current/unit-root-roles-20261119.md)); this document does not decide it.

**Result.** A result is described by the field `return` in the data (`return: int`, or a nested block). The
declaration assigns nothing and is not a shared mutable cell of recursive activations
([return-in-data](docs/LMX_semantics.en.md#return-in-data)). In code `return` is the return receiver: bare `return`
is kept, `return: value` passes the result to where it is described, and reaching the end of code creates no
`return`. Both `call` and an ordinary call of a Structure may return a value; the former unconditional ban ("a
launch of a Structure has no result") is lifted.

**`fn` is a signature only** ([fn-signature](docs/LMX_semantics.en.md#fn-signature),
[whole-arguments](docs/LMX_semantics.en.md#whole-arguments)). It is written by the same data template, including
the field `return`: with `return` it is a value contract, without it a procedural contract.

```text
fn:
    int: a
    int: b
    return: int
```

The compact form is `fn(int: a; int: b; return: int)`. The arguments of `fn` are always read in the data role: `fn`
belongs to the group of data-role receivers, the readings W and E do not apply to it, and there is neither a separate
grammar of signatures nor a separate parser. A requirement taken from `fn` is checked by the common `implements`
against the call contract of the candidate with its `parent`; no separate signature validator exists. A whole example:

```text
SumContext:
    int: a
    int: b
    return: int
    sum:
        return: a + b
```

`SumContext\sum(a := 2; b := 3)` executes `sum` with the data `SumContext`. The typed pointer is
`@: sumPtr fn(int: a; int: b; return: int) SumContext\sum`, called as `sumPtr(a := 2; b := 3)`. There is no
executable `fn` or `sub`; these forms give `fn` no name, and no named form is defined.

**Selection of the declaration** ([declaration-selection](docs/LMX_semantics.en.md#declaration-selection),
[selection-examples](docs/LMX_semantics.en.md#selection-examples)). The stages are: resolve the callee name and its
visible declarations; select by the explicitly supplied material; execute the selected variant and apply implicit
binding. A candidate is (visible declaration, reading of the explicit actuals, actual-to-formal map). There are two
readings and they are equal: reading W (as written) and reading E (the single Structure expanded), considered when
exactly one actual is given, it is a Structure or a reference to one, and it is not given by assignment to a formal;
its immediate fields then form the sequence of actuals, once and one level deep, with the graph unchanged.
`f(arg := S)` gives no reading E. There is no preference for the whole Structure, for an arity, or for the first
declaration found, and E is not tried after W fails. No candidate is a refusal; exactly one is executed without
expanding again; more than one is an ambiguity error. Selection executes nothing: no assignments, defaults, or
`test`. Implicit binding (autofill, caller's place, former binding) does not take part in selection, does not rescue
a rejected candidate, and does not restart selection. The mandatory table is TZ §9.8. This replaces the rule of
2026-11-18 ("expansion is an attempt to find other signatures; a signature with one argument opens nothing").

**`catch`** is brought to the common model of data and call with the handler semantics kept
([catch-common-model](docs/LMX_semantics.en.md#catch-common-model)); it does not vanish with `sub` and does not
become an ordinary function.

### 3.3 Places, binding, and `private` (norm of 2026-11-19)

An **own place** gets its value or description in the current activation from an actual, from autofill, or from the
former binding. The **caller's place** is an existing local variable of the caller, with no working copy. In both
cases `x` has its ordinary type `T` in LMX: a native `T*` does not turn it into a pointer, and `x`, `x := v`,
expressions with `x`, and `@x` act on the selected logical place
([binding-places](docs/LMX_semantics.en.md#binding-places)).

An own declared place receives its value in this order: an explicit actual; its own ready value or the description of
its initializer; **autofill** with the value of the same-named local place of the caller (an own cell, not an alias;
forbidden when the receiving place or the selected source is `private`); the ordinary uninitialized state with the
existing `required` checks ([binding-autofill](docs/LMX_semantics.en.md#binding-autofill)). A used external name
without an own active declaration is resolved as follows: if the really visible lexical source is `private`, the
lexical binding applies and nothing is substituted dynamically; otherwise the **transparent caller place** acts
(reads, `x := v`, and `@x` act on the caller's place, the write is immediate with no copy-back on exit, an
`uninit:T` place also changes its initialization state, and the hidden address is a detail of the native
implementation; [binding-caller-place](docs/LMX_semantics.en.md#binding-caller-place)); otherwise the **former
binding (fallback)** acts: the former sources and an own working copy in the frame, never an alias
([binding-fallback](docs/LMX_semantics.en.md#binding-fallback)). Two substitutions are forbidden: replacing the
transparent place with a temporary copy and a copy-out, and replacing the fallback copy with the address of its
source. In a chain A → B → C reachability is kept even if B does not use the name, and there is no static
transitive accumulation of requirements; if B has an own copy of `x`, an access by C changes the `x` of B, not of A,
and if B holds the transparent place of the `x` of A, passing the `x` of B keeps the address of A's `x`
([binding-chain](docs/LMX_semantics.en.md#binding-chain)).

**Two-way `private`** ([private-binding](docs/LMX_semantics.en.md#private-binding)). One common mechanism, not a branch
for autofill, one for the caller's place, and one for the former binding, checks both sides for all implicit dynamic
binding. Source: a `private` place of the caller is offered neither as a value nor as a place. Receiver: a really
visible `private` declaration in the lexical context of the callee is not overridden by a value or a place from the
dynamic context. Not forbidden: explicit passing, explicit filling of a receiving `private` place with an actual,
nested lexical visibility, explicit paths and `node`, and shadowing an outer `private` by a new inner declaration.
`private` filters a particular place and is not a barrier of the name: a `private` source is skipped and the search
goes on. Restrictions of writing (`const`, `immutable`) stay. The graph record `S\private\field` is not flattened.

**Executors** ([binding-executors](docs/LMX_semantics.en.md#binding-executors)). native→native, native→walker,
walker→native, and walker→walker give one observable behavior. A native local place has no arena header
`[type][value]`, and there is no load-dirty, flush, publication, or copy-back. The transparent link does not extend
a lifetime, and at `yield` the selected link is not rebound.

**The graph** stays a graph of source forms: records of modifiers and receivers are kept by the existing rules;
binding does not rewrite them and adds no fields to data or code. Explicit compilation, the existing native/walker
choice, and the `endturn` boundary are unchanged (§3.1).

### 3.4 Current representation (former norm) and the norm of 2026-11-19

The code still implements the left column. Nothing in §§3.2–3.3 is implemented or checked yet; until the slices of
[binding-callables-20261119](next_core_tasks_v3.md#binding-callables-20261119) are accepted, the translator, the
interpreter, the kernel sources, the examples, and the tests keep the former forms.

| Aspect | Current representation (former norm) | Norm of 2026-11-19 (not implemented yet) |
| --- | --- | --- |
| Launch forms | `call(args data code)`, `call(data code)`, `call(code)` and `fncall(args data return code)`, `fncall(data return code)`, `fncall(return code)`; an omitted `data` means `code`; `call(code)` is `call(code code)`; in code `A()` is `call(A, A)` and `A(D)` is `call(D, A)` | four structural forms (§3.2); data role is `parent(C)`; `call(C)` is not `call(C C)` |
| Data of a call | a `data` part and the reserved name `data` (`data\x`, `data := ptr`, `@(data\field)`), also `code\x`; the unit root is launched as a Structure over itself | no special `data`; `node\x` or `D\x`; R0 has no data |
| Result | `fncall` and its `return` part; "a launch of a Structure has no result" | `return` in data; `call` and an ordinary call may return |
| `fn`, `sub`, `catch` | `fn`/`sub` receivers consume a name, unified data, a return description, and code, and create a callable with a native field; a header without code describes a call interface; abbreviated headers kept | `fn` is a signature only; `sub` removed; `catch` in the common model |
| Selection | rule of 2026-11-18: expansion is an attempt to find other signatures, a rejected one goes as written | readings W and E equal; ambiguity if both fit |
| Binding | a dynamic input, then a lexical source; the chosen value is copied into the frame; a local write never reaches the caller | own place order with autofill; transparent caller place; former binding as fallback; whether a write reaches the caller depends on the path |
| `private` | excludes a field from dynamic sources only; lexical fields cannot be hidden by it | two-way |
| Where it lives | builder, interpreter, translator, and call tables as in the dated notes above and in M14 | plan section binding-callables-20261119 |

## 4. Declaration, assignment, call, and admission

In accepted v3 rules a bare resolved atom reads a value/address, not a
nullary call. A method or method pointer uses an explicit call form. An
ordinary Structure executes through the structural call (§3.2): `call(C)`, `call(A C)` or, in code, the forms
`C()` and `C(args)` (the author's decision of 2026-11-11,
[journal](LMX_blog/2026-11-11.md#structure-call-by-name); its reading of `A()` as
`call(A, A)` and of `A(D)` as `call(D, A)` is withdrawn by the norm of 2026-11-19,
[structural-call](docs/LMX_semantics.en.md#structural-call)). In data `A()` and
`A:` declare an empty Structure `A`, and a repeated such form is one more
occurrence of the name; nothing is called. In code the same form is a call
of the head `A`: with `A` a callable it calls it, with `A` an ordinary
Structure it executes it with `parent(A)` as its data role, `A()` with an empty tail and `A(D)` with the actuals
`D` selected by the common algorithm (§3.2); it is an error when the head names neither a callable
nor a Structure. Do not reclassify a failed call as another operation.

M3 first normalizes legacy flat declarations to name-first order. A place
is declared only by a receiver form enumerating its arguments (the author's
decision of 2026-11-10, [semantics](docs/LMX_semantics.en.md#receiver-args-only)):
`int: i 5`, `@: ptr 0`, `@: ptr Model`, and `@: ptr Model 0`. The first
field names the place without invoking it; the second supplies a value or
requirement under the receiver's contract. The arguments of a receiver are
read as any arguments are -- as code (the author's decision of 2026-11-11,
[semantics](docs/LMX_semantics.en.md#data-code-roles)): the nested form
`Model: Other` in `@: ptr Model: Other` is a call of `Model`, not a
requirement with a candidate. The requirement and the candidate are written
flat, in three fields: `@: ptr Model Other`, and `@: ptr Model 0` for a
null address. A launch form of a Structure at a place where a value is
needed (an operand of an expression, an actual argument of a call, an
initial value, an operand of `merge`) was an error because a launch has no result
(the executor's reading -- [answers](LMX_blog/q/fable-self-answers-20261110.md),
Р22, item 3; Р25, item 4); that unconditional ban is lifted by the norm of 2026-11-19: the result is described by
`return` in the data ([return-in-data](docs/LMX_semantics.en.md#return-in-data), §3.2). The composed form with the
place in the outer head (`i: int: 5`, `i: int()`, `ptr: @()`, `ptr: @: 0`,
`ptr: @: Model: 0`), which N1–N6 retained, is withdrawn: `ms: int: time` in
data is a Structure `ms` with a field `time`, not a place `ms`. No translation path
reads the composed form as a declaration of a place any more, and the
project's sources and fixtures do not write it
([plan M9](next_core_tasks_v3.md#m9)).
`int: i` declares an int place without an initial value; `int: i 5`
supplies 5. Likewise, `@: ptr` declares a void reference without an initial
address, while `@: ptr 0` explicitly supplies null. A later write into
a void reference does not retroactively make its declaration
Model-constrained. Initializers, assignments, calls, and reference depth
use the general receiver–arguments model, not a special parse for `@`,
`int`, or a method name; each receiver still owns its argument contract.
Callables and ordinary named
Structures follow one structural contract (§3.2); `fn` is a signature and creates no callable. Generated L1 is migrated
after L2/L3; see [v3 M1–M4 and N1–N6](next_core_tasks_v3.md).

Norm of 2026-11-19: `fn` is read after common P0 as a data-form template and describes a signature only
(§3.2); there is no separate args declaration part and no auto-created data copied from code. Former
representation: the `fn` receiver consumed its name, unified input data, return description, and code where present;
a header without code described a call interface, and existing short definitions kept unified data (§3.4).

The launch forms are `call(C)`, `call(A C)`, `C()`, and `C(args)` (§3.2). The former six forms of `call` and
`fncall` with a `data` part are described only as the current representation (§3.4). An ordinary call selects
the declaration by the explicit actuals and supplies them to this shared binding/admission/frame/result path.
Pointer calls, `catch`, and ordinary Structures use that interpreter worker; known native-to-native
calls remain direct C calls. [Contract](docs/LMX_semantics.en.md#call-receivers), [M10](next_core_tasks_v3.md#m10)
(former plan of the six forms), [plan of 2026-11-19](next_core_tasks_v3.md#binding-callables-20261119).

`implements` checks the actual Consumer's explicitly required accesses;
without a Consumer, full suitability is checked. A requirement taken from an `fn` signature is checked by the same
`implements` against the call contract of the candidate with its `parent`. It is performed once, when
the clean graph is built; after that it is needed only where the candidate
is selected while the program runs
([cases](steps/implements-runtime-cases-20261111.md)), and an assignment of
primitives is not checked for admissibility at run time (the author's
decision of 2026-11-11; the rule speaks of the admission `implements`, not
of conversion: the range check on receiving a number of another type,
`u16(256)` into `u8`, remains at run time). The accepted address map
must apply to reads, writes, captures, and merge. User-authored behavioral
tests are separate; no system re-runs every possible test after each
mutation. Failed admission must not partly write the destination. See
[L3 semantics](docs/LMX_semantics.en.md#descriptions) and
[v3 K01–K12](next_core_tasks_v3.md).

An assignment sign is a receiver head tied to the name written to its
left. The priorities and the associativity of operations are those of C
(the power `**` follows Python); assignment has the lowest priority and
groups to the right, so its right part is the whole expression to its
right. Values are evaluated on demand: a receiver that needs the result
of another receiver has it executed first, whatever its priority, once
per evaluation, and the clean graph is not rewritten. `1 + v := 2 + 3`
gives 6 and assigns 5; `v := 2 - 3` assigns -1. An assignment inside the
expression of an argument writes into the place of the callee that the name selects (declared in its data role) and is no
separate argument; `f(v := 2 + 3; 6)` supplies a named argument.
`sys\name(identificator)` returns the spelling of an identifier as an
ordinary Lmx array of characters taken from the table of names;
`sys\operand` registers a user operand with a function of one signature,
`fn([]: @ args; return: @)` (the former writing was `fn: new_op ([]: @ args) @`), and a mandatory priority, and
`sys\priority` gives a priority by the name of an operand.
There is no general unwrapping of an Array into arguments. None of
this is implemented yet; the slices are in the plan. See
[the book](docs/LMX_semantics.en.md#assignment-inside-expression) and
[the requirements](docs/new_parts/to_fable_operands_arguments_priorities.md).

## 5. Message, Thread, and one turn

`LmxMsg` is the closed record `{running, success, handoff_ready, graph}`.
Its `graph` is the language root, not scheduler settings, mailbox state,
or children. An executable `Thread` begins with this Message record and
owns mail, scheduling, and the sole `Thread.children` List. The equal
address of Thread and its Message prefix does not turn a standalone
Message into a Thread.

One executor runs a turn for a Message identity. Successful end-turn
publishes prepared mail and children; failed end-turn discards unpublished
work, not earlier graph mutations. `running = 0` requests stop;
`success = 1` suffices for stop at the boundary. Dispatch is per selected
Structure's `native` word, not a Thread-wide mode.

### 5.1 Child identity and supervision

`Thread.parent` and `Thread.children` define Message supervision, not
`Lmx.parent`. R0 is an ordinary Thread under a host scaffold and has no data (norm of 2026-11-19,
[root-entry](docs/LMX_semantics.en.md#root-entry)): it is a procedural entry without user arguments. Launch
parameters and settings belong to the scaffold, are passed explicitly, and are not user actuals; they are not added
to R0's source graph, and no artificial `D = C`, empty service Structure, or field `data` stands in for the absent
data. Which role reads the records of the unit root is an open question to the author
([unit-root-roles-20261119](LMX_blog/q/current/unit-root-roles-20261119.md)). Child reservations become visible at the
parent's successful boundary. A parent settles direct children and each
child propagates the same rule.

## 6. Mail, ownership transfer, and collection

Each Thread has one `LmxPost`. `post`, `send`, and
`receive` must converge on this transport, not create a second
mailbox. The inbox FIFO holds an inseparable target/donor-arena pair.
The receiver attaches the donor on take; a refused attach preserves the
pair. Owner-local staging/outbox and the publication boundary remain
distinct from the inbox monitor. The unified language API is post-self-build
[v3 §8a](next_core_tasks_v3.md).

Collection follows live Message/Thread state, graph, mail targets, and
the one children List. Its ownership unit is an arena chunk.
An `independent: immutable` branch retained by another Message stays in
its owner's arena until that arena is destroyed, even without `const`.
Before `adopt: msg newParent` changes Message parent, owners of used
retained branches must remain on the new ancestor chain; refusal preserves
the hierarchy. Separate `independent: msg newParent` prepares this
particular adoption by copying only obstructing branches into `msg`'s
arena without adopting. These concern Message ancestry, not lexical
parents.

## 7. Copy and merge

`merge` constructs a new self-contained used graph closure in the
destination arena. One source→copy map preserves sharing and cycles,
redirects internal references and structural parents, and copies executable
operation records. A reference is like a directory link: redirect it to
the corresponding new target, do not manufacture a third instance.
Only qualified `independent: immutable` branches may retain old
address and owner, subject to §6. A dangling source-arena address is a
defect, not a merge mode.

An unchanged `native` entry is reusable only when its body and used
address/type contract still apply. Different layouts need the accepted
`implements` map or a native form for the result. Copy, merge, and
Message construction share ownership rules.
See [L2 §13](docs/L2_spec_en.md#copy-merge).

## 8. Translation and verification surfaces

The maintained source package is `selfbuild/` with the relative
`src/l2src/`, `tools/` and `tests/` layout recorded in
[selfbuild/README.md](selfbuild/README.md). Candidates remain in the named
private stages listed by the current handoff. Translation checks correct C
emission and explicit throws/catch obligations. Interface checking through
`implements` is performed once per candidate: at construction when known,
otherwise on actual reception. Construction does not execute `test`; actual
run-time admission performs this second step and stops on the first `0`.
A direct data pass executes only root-level declaration receivers (`private`, `required`,
`const`, `immutable` and `independent` execute in it, the variables under them are root-level); these may
reach code supplied to them through ordinary execution. The translators
still repeat admission when the call or assignment is reached
([plan](next_core_tasks_v3.md#m11), step 7). The shared collector and
three-pass integration remain implementation work, not a completed guarantee.
Parser normalization does not itself prove
head resolution. Expected rejection, link, reached execution, and
self-build generation are distinct evidence classes.

The [v3 plan](next_core_tasks_v3.md) orders the general migrations,
accepted code/data work, complete kernel gate, L3+L2 self-build, and
then unified mail. Tests must record
actual source bytes and reached result, not only zero exit. The goal is
two genuine self-replacements from supported L3/L2 sources with L1 only
generated between them and C99. The published package has real whole G1/G2 quick generations; the final
normative acceptance still requires the open plan items and final FULL.

## 9. Current implementation gap and helper tools

Accepted slices through400 and WIP401 contain earlier working-value publication and receiving-slot
machinery. They are not evidence that the 2026-11-15 model is implemented. The sole current task is
[M14](next_core_tasks_v3.md#native-structures): remove load-dirty, work flush boundaries, frozen slot
admission, their tables/fact copies/generator branches, and old tests requiring the withdrawn refusals.
Preserve necessary typed storage, ordinary GC/copying, and genuine receiving contracts.

**Gap to the norm of 2026-11-19.** The norm
([TZ](docs/new_parts/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md)) is accepted; the implementation still
executes the former norm (§3.4). The areas to bring in line are: the structural call with `parent(C)` as the data
role, R0 without data, and removal of the special `data`, `fncall`, and `sub`; `return` in data and `fn` as a
signature; declaration selection by the readings W and E on explicit material only; own place, autofill, transparent
caller place, and the former binding as the last source; two-way `private`; shadowing by level; the native ABI and the
bridge for hidden places; `catch` in the common model; migration of the kernel sources, examples, and tests. The first
plan step (TZ §13, item 1) matches the code against the norm, so this list names areas, not verified defects: which
points the code already meets is not established here. The checks that close the gap are the rows B01–B27 and C01–C19
of TZ §14, the key rows in all four executor combinations; none of them is reported as run in this document. This gap
is added to the M14 gap above and does not replace it. Plan section:
[binding-callables-20261119](next_core_tasks_v3.md#binding-callables-20261119).

S[n] := p and voidarray[n] := p store a void* without a former field contract. S\[n]x and
voidarray\[n]x select a named occurrence; named assignment checks the field requirement during
clean-graph construction where known. The raw store assigns no name or type to the slot.

Construction and checking first work in the builder, optimized for actual tasks. Move needed working
parts to runtime only for a concrete operation and share the code. No speculative second builder,
universal wrappers, or future states. sys\check and sys\checkL3 return diagnostics; sys\translate
returns L1 text and errors without executing S, compiling native, or serializing it as LMX.

Group helper receivers under sys rather than reserving global names: native, storage, descriptor,
typeof, toLmx, fromLmx, assert, check, checkL3, translate, compile, endturn, indexof, capacity, resize, reserve. length remains public by the author's instruction;
parent remains ordinary structural navigation. The header is parent/length/storage; native and capacity are arena-table queries.
sys\indexof(field parent) returns the unique occurrence's physical index; absence or ambiguity is an error.
sys\indexof(field index parent) selects occurrence index of the same reference, counted from zero,
and returns its physical position; a missing occurrence is an error. Use the same immediate-element
access for Structure/Array<@>, without an auxiliary reverse-index table.
[Group contract](docs/LMX_semantics.en.md#system-receivers). Earlier detailed receipts remain in
the dated records and witnesses; focused language checks, not new runtime infrastructure, establish progress.

## 10. Source map

| Concern | Maintained entry points |
| --- | --- |
| Graph, pools, arena | [lmx_pool.lm2](selfbuild/src/l2src/lmx_pool.lm2), [lmx_range.lm2](selfbuild/src/l2src/lmx_range.lm2), [build.lm2](selfbuild/tools/build.lm2) |
| Call and walker | [lmx_call.lm2](selfbuild/src/l2src/lmx_call.lm2), [lmx_walk_values.lm2](selfbuild/src/l2src/lmx_walk_values.lm2) |
| Thread, turn, root | [lmx_thread.lm2](selfbuild/src/l2src/lmx_thread.lm2), [lmx_turn.lm2](selfbuild/src/l2src/lmx_turn.lm2), [lmx_root.lm2](selfbuild/src/l2src/lmx_root.lm2) |
| Mail, children, collection | [lmx_post.lm2](selfbuild/src/l2src/lmx_post.lm2), [lmx_child.lm2](selfbuild/src/l2src/lmx_child.lm2), [lmx_gc_graph.lm2](selfbuild/src/l2src/lmx_gc_graph.lm2) |
| Copy, merge, admission | [lmx_graph_copy_owned.lm2](selfbuild/src/l2src/lmx_graph_copy_owned.lm2), [lmx_merge_owned.lm2](selfbuild/src/l2src/lmx_merge_owned.lm2), [lmx_implements.lm2](selfbuild/src/l2src/lmx_implements.lm2) |
| Frontend and backend | [l2_frontend_core.lm2](selfbuild/src/l2src/l2_frontend_core.lm2), [l2_frontend_emit.lm2](selfbuild/src/l2src/l2_frontend_emit.lm2), [build.lm2](selfbuild/tools/build.lm2) |
| Build, docs, receipts | [build.lm2](selfbuild/tools/build.lm2), [docs_check.lm2](selfbuild/tools/docs_check.lm2), [README.md](selfbuild/README.md) |
| Binding and callable norm (2026-11-19; documents and plan, not code) | [TZ](docs/new_parts/LMX_Fable_TZ_Binding_and_Callables_v2_2026-11-19.md), plan section [binding-callables-20261119](next_core_tasks_v3.md#binding-callables-20261119), semantics anchors [structural-call](docs/LMX_semantics.en.md#structural-call) and [binding-places](docs/LMX_semantics.en.md#binding-places), open question [unit-root-roles-20261119](LMX_blog/q/current/unit-root-roles-20261119.md), executor's answers Р106 and Р107 in [fable-self-answers-20261110.md](LMX_blog/q/fable-self-answers-20261110.md) |

This map locates a mechanism; it grants no write ownership. Check
`OWNED_BY`/`LOCKED` markers and the active writer before editing code.

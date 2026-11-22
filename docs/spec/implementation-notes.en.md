# LMX implementation integration and historical notes

This file separates the desired implementation model from historical receipts. The operative
contracts are the [semantics](LMX_semantics.en.md), [grammar](LMX_grammar.en.md),
[L2 specification](L2_spec_en.md), and [kernel specification](kernel-implementation.en.md).
The standalone package has not inspected, built, or tested a current LMX repository. Consequently,
no old “current”, “PASS”, “OPEN”, or commit/push statement below is a current acceptance claim.
This revision records documentation reconciliation and the evidence Fable will need when applying
it to code.

<a id="binding-callables-20261119"></a>
## Accepted model through 2026-11-21

The author's decisions of 2026-11-21 have priority for zero-payload uninit, graph assignment, complete source, and the graph-plus-method-binary program model ([program representation](LMX_semantics.en.md#program-representation)).
The field-stream correction makes all three receivers consume ordinary CODE arguments in every
placement, including inside DATA; common W/E applies everywhere. It supersedes the earlier
DATA→DATA/CODE→CODE source table. The latest field-stream rules refine earlier import and
composition examples. Earlier
accepted supplements are incorporated baseline material, not a new pending plan.

The complete program consists of the source graph and a binary containing compiled native methods.
`parent` and `length` derive logically from the source relationships; other program content is in the
Lmx pointer array and referenced records. R0 is an ordinary C method holding its R0-graph pointer
locally, and the interpreter also uses the binary R0. This leaves ordinary runtime bookkeeping in
place but permits no additional static DATA image, executable working graph, expanded program,
or persistent graph disguised as namespace. Activation values and operation-local source views
must serve their actual calls; they do not reconstruct a second executable program.

For example, private status is recognized from the ordinary `private` receiver in that same graph.
Generated methods implement its binding consequences without a binary copy marked with privacy,
initialization, or other program flags. Such a marked copy is the removed working graph even if
called a namespace image, descriptor cache, or execution metadata.

| Topic | Required model | Earlier mechanism to retire if still present |
|---|---|---|
| Graph and namespace | All written receivers stay in the source graph; computations/transforms happen in namespace; only terminal primitives use direct `{type value}` representation | Replacing receiver records with computed fields, saved resolution graphs, persistent expression results |
| Structural call | Execute selected C; DATA is its actual parent; call takes code or args/code; R0 has neither DATA nor user actuals | Separate data parameter, data=code launch convention, fncall, special data name |
| Named signature | Ordinary expression `name :: data`, with a left declaration identifier and one complete right DATA template; creates a constant positional signature description without operand unwrapping | Omitting the left declaration identifier, executable fn/sub, a signature that silently becomes an implementation |
| Requirement matching | Full explicitly described tree for an ordinary model; ordered input count/types plus result for fn inside common satisfies | Matching fn by input names/body, treating ordinary templates as reduced call signatures |
| Explicit actuals | Equal W/E candidates, retained actual map, no implicit-source selection, source-order effects | Whole/expanded preference, hidden rescue of required inputs, repeated expansion/execution |
| Binding | Own actual/autofill value; transparent caller place; retained fallback own value/description | One mode used for every external name, alias-to-copy or copy-to-alias substitutions |
| Private and scope | Private source excluded and visible private receiver protected; explicit/lexical access retained; sequential locals and real nested shadowing | Source-only private checks, global name barriers, whole-body future-local masking |
| Declaration arguments | Preserve declaration form without initializer execution; match known names, otherwise one positional Structure; repeated execution updates the receiving root place | Passing only initializer values, treating an absent inner name as an unknown named actual, fresh item per body invocation |
| Import/copy/merge | Ordinary CODE arguments everywhere; common W/E; import 1+, copy 1, merge 2+ admitted sources; output fields consumed by namespace | DATA-argument mode, const-filtered copy, one-source merge, implicit destination as model, automatic outer result container |
| User operands | Ordinary method with left/right and explicit constant PASS_ARGS_AS_IS/PRIORITY; ordinary result; shared eval for raw occurrences | sys\operand registration, one args Array, universal reference result, implicit mode/priority |
| Parser closure | Blank physical line invokes common complete close at local document root; protected content/pairs/Mix retain their rules | Ignoring a physical blank inside an intended continuing block or inventing a separate grammar subsystem |
| Storage/native | Typed records, common variable-sized Arrays, ordinary machine locals, direct native calls where known, existing bridge/arena/GC | Typing by address ranges, hidden native compilation, local publication/flush, universal wrapper/registry additions |
| Complete program | One complete graph plus compiled methods; R0 is a C method with a local graph pointer even for interpreter execution | Static DATA replicas, persistent working/expanded/callable graphs, global hidden program instances |

Fn matching and call selection are different operations. A method with types `[int, Array<char>]`
and different formal names can satisfy that fn requirement; one with reversed types cannot,
even if a direct named call could supply its parameters in another order. A reference constrained
by fn accepts the signature's public actual labels and maps positions to the candidate. Defaults,
requiredness, throws, and hidden binding remain those of the candidate under its real names.

The lexical node operation remains distinct from actual parent(C). Neither importing a method nor
receiving copied fields redefines node as the destination. An old explicit data path cannot be
mechanically renamed to node without checking the lexical source it should select.

<a id="source-migration"></a>
## 1. Sources and integration boundary

Maintained kernel, parser, and translator sources remain L3 with L2 insertions. L1 and C are
intermediate/generated outputs. A bootstrap seed is an implementation tool, not proof that the
full L3/L2 source chain conforms. Port a body through the common pipeline, retain required
headers/dependencies, and remove any obsolete authoritative fallback once its replacement is
accepted. The documentation package does not require maintaining a new external build runner.

Use a current implementation audit to determine what already conforms. Historical identifiers
in the appendices can locate older code, but they cannot establish present layouts or behavior.
The shared mechanisms to inspect are P0 closure, receiver roles, root DATA consumption, namespace
binding, actual selection, common admission, expression evaluation, copying, native bridging,
and source serialization. Avoid adding branches keyed to the demonstration names iteration,
item, body, add, or a particular primitive spelling.

<a id="l1-status"></a>
## 2. Generated L1 and machine boundaries

Generated L1 preserves the accepted flat declaration order: name, requirement, and initial value.
A type expression is distinct from declaring a named place. Language Arrays use the common flat
Lmx descriptor and variable length; raw C storage belongs to an explicit C-door contract, not to
a second fixed Array model. Exact scalar types, pointer depth, shape, signedness, and lifetime
remain target-machine concerns under L2, and a foreign pointer is not automatically a tagged
graph record.

Keep target os branch selection before semantic processing of unselected branches. Foreign-call
actuals are evaluated once in LMX written order before a function/macro receives the values;
literal c.sizeof keeps its own C operator rules. Direct C-compatible exports use their explicit
contract and do not require hidden root/Message/arena singletons. These boundaries use the same
parser, name resolution, admission, and generator as other machine L2 code.

<a id="l2-status"></a>
## 3. Kernel integration target

The kernel specification is organized by active responsibility rather than by old slice numbers.
The essential implementation separations are:

- The physical record's code/value and ownership are distinct from a source requirement or ABI
  spelling. Preserve exact scalar ABI transport and uninitialized-state inspection without
  reading nonexistent payload: `uninit:T` is its type code alone, with no reserved T cell.
  An explicit graph assignment replaces a fragment; execution-place assignment leaves source
  unchanged. Native locals do not have an arena tag before their address.
- The flat descriptor has parent/length/storage only. Capacity and native descriptors stay in
  their existing arena/call tables. Structure/reference Array operations share mechanisms;
  numeric Arrays remain dense typed storage.
- Each call/operation owns its needed namespace and temporary maps. Old source-binding or
  admission tables do not become a second permanent graph. A read-only query must not create
  an implementation, execute an initializer, or freeze a mutable alias.
- Explicit actuals, autofill, transparent caller places, and fallback copies retain different
  write owners. Native adapters preserve that distinction and initialization state on all four
  native/walker crossings. The language call site, rather than a bridge's locals, supplies the
  caller context.
- Copy/merge preserve sharing, cycles, parent links, required lexical chains, reusable native
  links, and qualified immutable retention through one map per operation. Import transfers
  original eligible declarations by reference without copying/reparenting them.
- Graph writes do not invalidate native. Explicit compilation and endturn retain their accepted
  roles; local-frame publication, load-dirty, shared-cache coherence, and flush are removed.

Each source import/copy/merge operation can supply zero, one, or many output fields independently
of its admitted input count. A group explicitly collects those fields into one Structure, and
ordinary CODE W/E still applies at its consumer. An operation does not use the receiving DATA
context as another source, and separate operations do not share an implicit combined map.

<a id="l3-status"></a>
## 4. Interpreter and admission

The interpreter consumes the current source graph under the ordinary role and namespace rules;
it does not depend on saved translator preparation. Construction establishes known candidate
interface facts without executing bodies, initializers, or `test`. Reached interpreted calls
invoke standard `satisfies`; prepared native calls use their prepared contracts without an
automatic runtime `satisfies`. An explicitly written `satisfies` executes in either path.
Reused admission facts remain within their established operation/reception scope, not a second
persistent namespace or admission store.
Candidate selection does not speculatively run assignments/defaults/converters/tests once per
variant. A known interface does not waive a required receiving check or an actual-value range check.

The separate build/test phase runs after clean-graph construction and before C generation.
`sys\compile` includes this phase: it may execute checkers and candidate calls required by the
ordinary build/test contracts, without launching the selected graph's application entry.
`sys\check`, `sys\checkL3`, and `sys\translate` do not execute application code or `test`.
No phase means that every later primitive write or graph edit reruns all checks.

For ordinary explicit structural models, the entire specified tree is a requirement. Where the
established receiving contract is relative to a particular Consumer, its ordinary projected
requirements remain. A signature requirement selects the accepted positional-signature rule inside the common satisfies
engine; it does not replace structural matching, invent a second admission system, or overlay the
candidate's DATA/defaults.

<a id="test-receiver-proposal"></a>
### 4.1. Test and handler integration

Test remains the accepted receiver. Checks belong to the receiving expression; absent an explicit
Consumer, their source is the receiving requirement rather than an unrelated candidate. The
checker's own accesses must be admitted before it runs. A check completes an admission already
in progress and does not recursively restart that same admission. The first false result stops
the remaining checks.

A DATA pass executes root declaration receivers by their ordinary contracts, including modifiers.
It does not recursively run every test form simply because one is present in DATA. Reached code
and the build/test phase invoke checks through those same receiving contracts. There is no
hidden test catalog or skip-tests mechanism.
The reserved receiver spelling test is not a user-method naming convention; examples may use
another ordinary method name without changing the test contract.

Catch retains failure/scope selection, payload reception, skipped body on initial traversal,
ordinary continuation/repeated-call behavior, throws, and cleanup. Its other dependencies follow
the same private/binding rules, and removal of sub/fncall does not remove handlers.

<a id="assign-named-merge"></a>
### 4.2. Actuals, declarations, and field streams

A standalone `name := expression` actual chooses a formal; an assignment inside an actual
expression writes the appropriate receiving place and contributes its result to that one actual.
Naming the current positional formal keeps the positional counter; naming another disables it.
The target map never reorders effects. The selected W/E reading remains fixed through execution,
and a supplied Structure is not expanded a second time after W has been selected.

A place-declaration actual is DATA material. A matching internal declaration name replaces the
receiving description. An absent internal name supplies the whole form positionally. An explicit
outer name chooses the formal independently of the declaration's internal name. None of those
transfers runs its initializer. Executing the saved form later establishes or updates the
receiving execution's root place; the associated body uses that same place and does not run the
initializer merely to read it. A fresh independent call still has independent locals, and a real
nested scope still shadows normally.

Import filters the ordinary root const declarations, including user Structures and constant
signature names; it retains their source identity and parent. Nested import supplies its enclosing
consumer without a second hidden import into the caller. Copy takes exactly one admitted source,
merge at least two; all three always use ordinary CODE arguments, even inside DATA. Bare
Structure references and anonymous Structure values are not themselves calls; their contents can
contain calls/initializers processed under ordinary contracts. Grouping neither quotes all content
nor eagerly runs every initializer. Explicit Producer() is a call when the receiver is consumed,
including in an enclosing DATA declaration. The ordinary
declaration-argument rule remains in force, and P0/source receiver records stay unchanged. Arity
is checked after common CODE W/E everywhere, so a single written merge(S) cannot be rejected
before an applicable E reading.
A stream's destination is not an implicit source or model. Matching fields overlay only inside
one merge; independent streams use ordinary DATA repeated occurrences.

For one copied value use `(copy(A))`, for one merged value `(merge(A B))`; for fields use the
ungrouped receiver. An explicit named formal suppresses E for that whole structural actual.
`(a b) := (copy(Pair))` uses ordinary positional group assignment: all RHS values and the count
check precede the first write, without rolling back prior RHS effects; the bare stream
`(a b) := copy(Pair)` is an error (author's decision, 2026-11-21).

<a id="compound-assign-notes"></a>
### 4.3. Expressions and operands

Assignment is low priority and right associative. Demand for a particular assignment result does
not raise its priority or truncate its RHS. `f(10 * v := 2 + 3)` writes receiving v = 5 and
supplies one actual 50; `10 * 2 + 3` is 23 because no assignment-result dependency exists there.
One required occurrence executes once per dynamic evaluation; new iterations or explicit eval
calls evaluate anew. Short-circuit skips all effects in the unneeded operand. Compound assignment
addresses its destination once. Power keeps its accepted right grouping and asymmetric unary
relationship; ordinary LMX numeric rules still determine values and type admissibility.

User operands are ordinary methods with mandatory explicit left/right and constant mode/priority
fields. Mode 0 transports references to prepared typed values; mode 1 transports source occurrences
with their original live context for sys\eval. The method returns its normal declared logical
type. Discovery, expression use, and sys\priority share its description, with no sys\operand
registration. sys\name consumes an identifier spelling and returns a normal char Array without
resolving or executing the named entity. Prefix dereference remains dereference, not eval.

An operand opens a group only when all three conditions hold: `left` is a written unnamed Structure, `length(right) = 1`, and `right[0]` is a written unnamed Structure. Only the one outer group on the RIGHT is removed, once for this operand application; its immediate fields become `right`. LEFT remains the same whole Structure and merely supplies the condition. Nested groups are not opened again, and a Structure returned by a function is not automatically opened. P0 never performs this transformation. Ordinary callable W/E selection is a separate rule, not an additional operand-opening pass. A named declaration such as `Name :: (A B)` has a name on the left, so its single right-hand Structure remains whole; `Name :: A B` instead has two right arguments.

<a id="open-design"></a>
## 5. Derived review cases and the resolved physical-layout decision

The common rules decide the inline-local and entry-role cases without a new language rule.
Their expected observations are derived below. An implementation report should name the entry/source
role used by its fixture and test the shared algorithm. The author answered P01 on 2026-11-21;
§5.3 records that binding decision and retains the old anchor for existing references.

<a id="inline-declaration-control"></a>
### 5.1. New uninitialized local in an inline nested scope

The [control example](LMX_semantics.en.md#inline-declaration-control) gives this exact situation: the current activation has outer x = 5; an inline
nested block introduces a new `int: x` without RHS/default; there is no new callable invocation,
and this activation's caller has no x. The inner declaration creates its own place and shadows
the outer one. Own-input autofill obtains a permitted same-named caller value; an inline lexical
scope does not create a new caller. There is therefore no applicable supplying source in this
fixture, and the inner place is `uninit:int`. A reached required check refuses that absence;
the outer place remains 5 when its scope is restored. Neither zero nor a copied 5 is synthesized.
This is the derivation requested by §7.4 from the ordinary algorithm, not an unavailable executor
answer, an eager default pass, or a new universal copy of outer locals.

<a id="root-role-control"></a>
### 5.2. Source records at a unit root

R0 is a procedural entry with no DATA, user actuals, artificial self binding, or empty DATA
object. The [R0 entry rule](LMX_semantics.en.md#root-entry) explicitly retains its own executable declarations and ordinary access
to references. Once an entry is selected, its reached records use the ordinary CODE head rules;
a form supplied in a DATA argument is read under that receiving declaration's contract. Removing
R0's DATA does not remove source-role classification or give import a special DATA-argument mode.

A source-file/host profile must identify the selected entry and the role of any surrounding
document it reads. Where a worked fragment does not supply that host profile, a fixture can
prepare its explicitly DATA description and invoke the named body through the ordinary call
path. This does not invent automatic main discovery, call every declared Structure, or assert
that arbitrary top-level text has one new default profile. In particular, do not restore
data=code or convert runtime launch settings into user formals.

Other old entries labeled OPEN—including implementation of call, source storage, precedence,
selection, import policy, and native adapters—are implementation work or have explicit answers
in the included requirements. They are not unresolved language questions in this packet.
Earlier unrelated limits, such as safely unloading a module whose immutable branches remain
externally retained, keep their ordinary ownership boundary without an invented new facility.

<a id="uninit-layout-conflict"></a>
### 5.3. P01 — resolved: uninit has zero payload; graph assignment replaces fragments

The [zero-payload rule](LMX_semantics.en.md#uninit-zero-payload)
supersedes both earlier alternatives. `uninit:T` is only the type code; `sizeof(value) = 0`.
There is neither an outer/inner T pair nor a single tag followed by reserved T storage. A
named declaration without a value remains a named source leaf without allocating its future value.

Assignment in an execution frame changes its namespace place and does not change the clean
graph. That graph is the full literal source representation, including terminal primitive leaves
`{type value}` at the addresses referenced by Structure cells. All receiver structures remain
as written, including `for`, `if`, `merge`, `copy`, and `import`; ordinary explicit graph
assignment can replace any of them. Required executable recompilation uses the existing
compile/endturn restart boundary. Explicit graph assignment supplies a new fragment to the selected structural
place: `struct\novalue := 5` replaces `{uninit:int}` with `{int 5}`. It does not retag an
existing same-address T cell. A later lookup sees the new fragment and type; the old raw
payload-address preservation promise is removed because no payload existed in the uninit leaf.

Absence, nil/required checks and the distinction from numeric zero remain. Stable descriptor
addresses, Array-element descriptor/index references, and execution-place binding keep their
own contracts; none requires a graph uninit leaf to contain a T value cell. The primary
[L2 rule](L2_spec_en.md#uninit-record-control) and
[kernel rule](kernel-implementation.en.md#primitive-storage) implement this decision. No author
question or blocked ABI oracle remains for P01.

<a id="grammar-extraction"></a>
## 6. Parser and documentation verification

P0 preserves groups and reads every receiver through the same structural grammar. `f()` and an
empty `f:` have an empty Frame/body; `f(())` and `f: ()` contain one empty Structure. A bare f is
an atom, not a call. A blank physical line closes the current syntactic block completely through
the existing level/closure mechanism. It must not be discarded as decorative whitespace, treated
as a new executable instruction, or used to synthesize a missing paired delimiter.

Source examples and source serializers must place blank lines only where a complete root close
is intended. Comment-only lines and lexical protected content retain their existing meaning.
Mix has a local root and still needs its terminator. A final ordinary block can close at EOF,
with or without a final LF. These rules describe the common functionality to check, not a mandate
to rewrite a conforming parser.

Documentation checks for this packet cover the agreement of declarations/call forms, named signatures,
parent versus lexical node, binding/write owners, source roles and stream/group boundaries,
operand properties/results, and the preservation of memory/ABI/ownership contracts. The active
files use included relative references; repository journals and old witness paths below are plain
provenance, not required files or links. No historical test result is counted as a test run for
this documentation revision.

## 7. Historical receipts: reading rule

The appendices preserve dated reports from the supplied baseline for provenance. Their source
spellings, internal function names, provisional expected values, commands, checksums, and reported
limits are historical evidence only. In particular, their executable fn/sub, fncall, separate
data arguments, self-data R0, one-source merge, automatic container results, a DATA argument
mode for import/copy/merge, old operand ABI, P0 group removal, or unconditional single-Structure/Array operand spreading,
type-by-region, load-dirty, flush, graph-rewriting, working execution graphs, static DATA copies,
materialized namespace/program copies, nested/preallocated uninit cells, and stable
raw payload addresses across graph-field replacement are **superseded** by the active
specifications. “Current”, “today”, “OPEN”, “PASS”, and publication language inside a receipt refer
to its original date, never the current target or a newly examined checkout. Historical observations of group removal below describe defects, not a competing rule. The active operand rule opens only the RIGHT outer group once when LEFT is an unnamed Structure and the sole RIGHT argument is another unnamed Structure; LEFT is never opened by that rule and P0 preserves both written groups.


<details>
<summary>Historical notes: reported translator and kernel slices</summary>

##### 3. Translator-L2 and kernel

(Implementation of the former norm, before 2026-11-19: the mentions of `fn`/`sub`, `fncall`, the order `call: data code`,
a launch "over itself" and the formals `args`/`data`/`code` in the slices of this section describe the former mechanism;
current norm -- `removed-builtins` (original reference: `LMX_semantics.en.md#removed-builtins`), `structural-call` (original reference: `LMX_semantics.en.md#structural-call`),
`fn-signature` (original reference: `LMX_semantics.en.md#fn-signature`), `root-entry` (original reference: `LMX_semantics.en.md#root-entry`); replacement --
section of this document (original reference: `#binding-callables-20261119`).)

**Current state, 2026-11-14, slice384 -- bounded implementation, code acceptance passed; base383 `58bc7f3a`.** Direct named actuals of `fn`/`sub`
bind through `:=` only. A whole descriptor retains its colon fields in the DATA role without execution.
Structure formals `args`/`data`/`code` use common `read_received_value` with contract2: a written group is inert,
an unknown named Frame is read as an application and refuses3. Written `name`/`return` contracts, including `@: c.FILE`, are retained.
`fn_decl_name` needs no Space: a direct name/AST `name := value` is separate from the unique DATA field `name` of one whole descriptor;
there is no recursive unwrapping of nested groups or former direct `name: value` label branch.
Runtime01/Graph01, private32 triple,87 full AFTER checks,2 baseline checks and mutation24 passed.
The first private32 had3 FAILs: stale fn_prepared/call_receivers goldens and static-name emit5. Seed383 gave6/6 full AFTER checks;
only13 synthetic RHS parenthesis lines were corrected, with numbers unchanged. The original static probe and emit5 are retained;
no native runtime was created for it. Two new private02 sources checked a reached name with computed args
and name-call/finally in all three modes:5/before1/after0 and cleanup1. Direct/whole DATA gives12/12;
actual order gives effects1/later0/refusal5, the inert code group length1.
Source03 SHA-256 `ac0d0a1ca48bfdb488c44982ada095ef2e7516dd304831d5987a735c55f13e9f`.
Whole bootstrap quick passed: genuine G1/G2, nine smoke cases each; fixedpoint13/verify798 PASS.
Native trace02: actual root → `fn_apply` → `receiver_bind` evaluate1 → actual native producer,
effects1/later0/body0/before1/after0, expected host exit1. The first GDB01 with missing args is retained and is not counted as proof.
The genuine G2 graph-tool is built, SHA-256 `09f0e983a7baa2b892bd755c5845495355062e673b41ff6556a02a6899004f82`;
G2 repeat32 triple/21 full negative AFTER checks/mutation24 PASS. Tested code tuple384:
boot-m11-receiver-actuals-01/g2 + graph-m11-receiver-actuals-g2-01.
Normal render/docs check384 passed:35/14/27/44/615, links/LF; commit/push main follows.
A common catalog/declaration view and formal validation are OPEN M11.5e; frontend `by_head` is OPEN M11.8;
full M11, external/computed CodeBody and M13/M14 remain OPEN. Historical by_head333–335 is marked in kernel §3.4.

**Previous state, 2026-11-14, slice383; base382 `d0e384c1`.** Only Run changed; Run53/Frame ABI is unchanged.
One resolver serves pure classification and consuming reads with a local status. Only an actual read
of an absent F for reached raw fn/sub prepares the owner scope through existing `space_declarations`/evaluate0.
Sibling written methods are prepared consistently before computed actuals; binder queries do not re-enter a receiver.
Scope/source/parent and the enclosing `node` retain their exact proof. A constructor failure does not become missing3;
there is no new registry/error field, SourceSpace transfer or copier/`fn_data` hook. An ordinary descriptor stays a Structure.
10 pure cases passed: raw Fn1/2/sub2/marks25/source3, unentered1/2, named parts7/7, held aliases8/8/8/9/source3/next4,
explicit clone4/5/source3, ordinary descriptor5, malformed constructor5/before1/after0,
pending3/touch0, ambiguity3 and two walks source1/held3. Private34 triple gave32 PASS and two shape-only differences in
reference_alias/descriptor_merge; Seed382 reproduced the same full AFTER shape in all three modes.
Only four synthetic RHS parenthesis lines were corrected; numbers are unchanged. All102 AFTER checks on the same binaries,
mutation24 and the actual native root → consuming declaration → scope preparation7/7/normal exit trace passed.
Code was built on Source01:761; Source02 adds10 fixture pairs, Source03 changes only four existing parenthesis lines:
781 inputs, SHA-256 `4a7ed184d976b820d605f14c2e9a33970b16e0dae54c0ae95e83c35d9b5e5604`.
Whole bootstrap quick passed: genuine G1/G2, nine smoke cases each; fixedpoint13/verify781 PASS. The genuine G2 graph-tool is built,
SHA-256 `10dbb1b4dab7e7dd3395ea441d8a481ec795e6992bf60f3afa0be91bc0e35b59`.
The G2 repeat (34 cases in three modes, including runs2; 33 full negative AFTER checks; mutation24) passed;
Normal render/docs check383 passed:35/14/27/44/615, links/LF.
The working tuple is383: boot-m11-copy-bindings-01/g2 + graph-m11-copy-bindings-g2-01.
Full M11, remaining5e/7/8, external/computed CodeBody, native copy and M13/M14 remain OPEN; a new callable may use the walker.

**Previous state, 2026-11-14, slice382; base381 `38cf026c`.** Common `code_body` returns
a borrowed `body/from/to` through existing CodeBody roles. A whole `else`/`finally` tail containing a sole
written group selects its fields once; an already selected body/remainder and nested standalone groups
are not unwrapped again. The scanner, `fn_own`, walker, native and `code_parent` use this selection,
retaining physical parents, source holder/raw index and the existing frame; Graph71/Run53/implements74.
Runtime01/Graph01 and five pure cases passed: calls4 instead of2, cleanup trace21 instead of1,
written Fn790/computed890 instead of90; own late7, cleanup return4-after5, inert fields0
with unknown in a double group; refusal6 retains cleanup/root trace21. `finally` still registers
without effects and runs on exit in reverse order. No descriptor is evaluated for selection.
Code was built on Source01:751; Source02:761 adds only five fixture pairs, SHA-256
`be5db8e3168082a1509b5b035f7d293b0f8ec40a6092c321b247647443e04d7f`.
Private25 triple/75 full AFTER checks/mutation24 and native written/computed outer/fn_apply trace passed.
Genuine G1/G2 quick with nine smoke cases each, fixedpoint13 and verify761 passed. The genuine G2 graph-tool is built,
SHA-256 `f71df0958fda2d9be2e958b70fcd3b081e2248305aa07a68a7dbf6eda5b89316`.
The G2 repeat (25 cases in three modes, 21 full negative AFTER checks, mutation24) and normal render/docs check382
passed:35/14/27/44/615, links/LF. The working tuple is382: boot-m11-codebody-01/g2 + graph-m11-codebody-g2-01.
External/computed CodeBody, copying raw declarations and held F,
full M11, M11.7/8 and M13/M14 remain OPEN; this slice does not establish ordinary native M14.
The copy-class reading (original reference: `../steps/handoff/copy-construction-reading-20261114.md`) separates a new binding from raw arguments
and a copy of a held F's current parts as an ordinary value; source Space bindings are not transferred.

**Previous state, 2026-11-14, slice381; base380 `c5ba5ef9`.** The existing frame gains
`lexical_scope`: selecting an inline body changes the physical CodeBody cursor while `code`/`body`/`data`
retain their identities. Common `work_scope` prepares written fn/sub only at entry; a computed F is created at its producer.
The walker restores the cursor on flow/error; native sets it before each statement and at control labels.
A local F masks only its scope's FREE fallback, after data/formals, without shared inline promotion.
A required input (bit8) is separate from an input visible to children (bit2); bit4 combines scoped pending
under the rule that every required use must be pending. Optional snapshots stay private until consumption.
Runtime06/graph02 and 17 pure cases passed: privacy178/8/5/5, fallback10550 and physical8;
inline quiet90/selected790/reentry790/dynamic helper790, loop23, sub2/2 and indexed path3.
The bare CODE path is ambiguous and refuses3: viewed as data, CODE includes call Frames as occurrences too.
A wrong write refuses4 before RHS (calls0), bare Fn gives1; mixed missing gives3/touch1/body0,
literal outside gives3/touch0. Fields of a retained written Structure in a data context do not execute;
an explicit merge constructor executes computed initializers (existing received_structure_values: merge_calls1).
The previous 67 full AFTER checks are unchanged; private31 triple/AFTER93/mutation24 passed on Source07:751.
The final emitter-only optimization covers the first statement with the entry prefix without a repeated call;
Graph03/private02 inline triple passed on Source08:751, SHA-256
`b84c11fec03b4eb7fa7a35db19ebf732be8ab13975191eb704207dab0961e906`.
The native trace confirmed actual native outer, `work_scope` and `fn_apply`. Genuine G1/G2 quick with nine smoke cases each,
fixedpoint13 and verify751 passed. The genuine G2 graph-tool is built, SHA-256
`b8abfe4c58cc5702009aa09f65ce0a9b040aec403602c1c31eec88989fbcce4f`.
The genuine G2 repeat (86 cases in three modes, 102 full negative AFTER checks, mutation24) passed;
normal render/docs check381 passed:35/14/27/44/615, links/LF. The working tuple is boot-m11-computed-body-01/g2
and graph-m11-computed-body-g2-01; record (original reference: `../steps/witnesses/m11-computed-body-20261114/notes.md`).
Full M11, copying live F/data and M13/M14 remain OPEN. A dynamic new callee may use walker fallback;
this is not acceptance of ordinary native M14.

**Previous state, 2026-11-14, slice380; code acceptance passed.** A physical slot's receiving
descriptor lives in the existing `ImplContractFact`/`CopyMap` of the current `GraphSpace` for the whole execution,
including nested calls and constructed copies. A lexical mention of a known Structure receives NONE;
replacement by a Structure or int address does not replace it with the current content's type. The next independent
traversal derives the descriptor anew from the current graph. Facts belong to neither names, `Work`, write history
nor the serialized graph. Run prepares the descriptor after base/index and before RHS; Graph admits the address
against retained kind/type before the existing write with invalidation. Initial payload is not read.
The common assignment builder distinguishes a direct formed Frame from a written group, removing only
the synthetic RHS list; assignment AST retains its previous exception.
Graph71/Run51/implements74 and the static `contract_append` prototype from the L3 generator are aligned;
Runtime02/graph02 passed checks. The atom cycle gives 7/41/9, lexical shadow 7 and fact growth 492.
In the RHS probe an index selector invokes rhs: it changes root-held Holder[0] from A to C; calls=1,
while the outer Slots write produces 7. Primitive subtype/ref refusal is 4 with effects=1 and old value 7;
an out-of-bounds index gives 7 with effects=1. Private67 triple/204 AFTER including reset2/mutation24 and native trace passed.
Whole bootstrap quick: genuine G1/G2, nine smoke rows each; fixedpoint13/verify717; G2 graph68 triple/84 AFTER/mutation24.
Normal render/docs checks380 passed:35/14/27/44/615, links and LF27563 before staging.
Record380 (original reference: `../steps/witnesses/m11-slot-contract-20261114/notes.md`).
Deep Structure `satisfies`,
static M11.7 checks, full M11 and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice 378: acceptance passed.** Common root frame/block0,
native wrapper completion and forced reuse replace the separate root emitter. Scalar values stand without capture;
discarded AST uses the common value reader and computed body bindings use existing metadata/rows. Runtime01/graph01 and five pure cases passed.
Private01 executed 50 cases in three modes: 48 matched old goldens, 2 needed five independently derived
root-k snapshot updates (three outside8→5, data_result118→115, second892→592; open_result55 stays).
The existing 50 binaries were not rebuilt; additional root_frame_error passed triple. In total 51 cases executed
in three modes, 153 complete AFTER comparisons and mutation24 passed. Missing full AFTER expectations for
finally_body_error/sub_error were added with root_trace12/seen12; three existing fixture pairs use explicit control Frames.
Source04: 685; whole bootstrap01 quick passed genuine G1/G2, nine smoke rows each, fixedpoint13/verify685. Genuine G2
rebuilt graph-tool and repeated 51 cases in three modes, AFTER60/mutation24; runtime01 matches G2.
Render/docs check passed:35/14/27/44/615, links and LF27517; both diff checks are clean, actual native root trace01 passed.
Working tuple: boot-m11-root-frame-01/g2 and graph-m11-root-frame-g2-01.
Mapped own int local3/address1/direct1 before publication does not change formal/free-input control7. Legacy computed-int
preallocation remains M13 OPEN, closed by neither a row.number address nor forced flush. The shared cache/flush/ordinary
native M14, path-head calls and full M11 remain OPEN. Witness 378 (original reference: `../steps/witnesses/m11-root-frame-20261114/notes.md`).

**Previous state, 2026-11-14, slice 377: accepted `04fbf275`.** Only `lmx_graph_run.lm2` changes in the core:
`work_open_parts` prepares written fn/sub in selected data/body before work scan; `space_declare` reuses
the existing scope/raw-source binding. State preserves F and its own data: first1/second2, leaf_count2/sub_count2,
bumped2. Separate D/C give 32/34, data_count12/code_count22, touch_calls0. Different raw leaf declarations do not merge:
bare leaf refuses with 3 before the body, before1/after0. Source02:673; private38 in three modes and AFTER45/mutation24 passed.
Whole bootstrap01 quick passed genuine G1/G2, nine smoke rows each, fixedpoint13/verify673. Genuine G2 rebuilt
graph-tool and repeated 38 in three modes, AFTER45/mutation24; runtime02 matches G2.
Render/docs check passed:35/14/27/44/615, links and LF27467; both diff checks are clean.
Working tuple: boot-m11-ordinary-nested-01/g2 and graph-m11-ordinary-nested-g2-01.
The whole of M11.5г, root-frame work, computed ordinary declarations,
M11.7/8 and M13/M14 remain OPEN. Witness 377 (original reference: `../steps/witnesses/m11-ordinary-nested-20261114/notes.md`).

**Previous state, 2026-11-14, slice 376: accepted `9039fa89`.** After accepted receiving-context 374
and physical reference code 375, canonical `@: p int` without a candidate preallocates wrapper8/cell5 before observations.
A required formal8 uses reference-expression context3 and an independent admitted cell5 without reading signature
payload. Frontend/dump and the single-address-map serializer are aligned; a type-only merge field is retained
while its computed neighbor runs. Source04: 669, private36 in three modes and AFTER42/mutation24 passed.
Actual native TypeOnly8 was confirmed by private GDB trace03 with a normal exit. Whole bootstrap01 quick passed:
genuine G1/G2, nine smoke rows each, fixedpoint13/verify669. Genuine G2 rebuilt graph-tool and repeated 36
in three modes, AFTER42/mutation24; runtime02 is identical to the rebuilt runtime. Working tuple:
boot-m11-uninit-reference-01/g2 and graph-m11-uninit-reference-g2-01. Render/docs check passed:
35/14/27/44/615, links and index LF27434; both diff checks are clean, G2 direct trace01 passed. The whole of M11.5г/M11.7/8,
ordinary physical5/6/9 native in M14 and arbitrary models/void/depth/Array in M13 remain OPEN.
Witness 376 (original reference: `../steps/witnesses/m11-uninit-reference-20261114/notes.md`).

The current generator still uses parent/native/embedded VoidArray: this is the former ABI.
The target record contains only parent/length/storage, with capacity in an arena table and native
descriptors in call's tables in the same arena. Structure/Array<@> are interchangeable; numeric Array stores T.
All variable-size arrays share allocation/resizing, including service Thread.children.
The header stays stable; storage may move. Remove separate inline capacity in DynamicArray.
L2 indexing has no checks; L3 checks one linear index and holds the descriptor reference plus index.
sys\descriptor returns three actual addresses; sys\native/sys\capacity query tables.
Contract and status (original reference: `L2_spec_en.md#lmx`), plan (original reference: `../next_core_tasks_v3.md#flat-lmx-descriptor`).

`LmxThread` embeds `LmxMsg message` by value as its first field; a
plain `LmxMsg` does not expose the Thread tail. The sole child List,
arena ownership, and close follow the common Thread path. Historical
fixed root slots, `LmxLink`, a second child registry, and `settings`
appended to the source graph are rejected designs. Old emergency-slice
measurements live in migration history (original reference: `../steps/voidarray-migration.md`),
not in today's gate criteria.

critical_graph_bug (original reference: `../plan_critical_graph_bug_critical_pointer_to_struct_bug_fix.md`)
and critical_pointer_to_struct_bug (original reference: `../steps/tickets/critical_pointer_to_struct_bug.md`)
remain open. In particular, typed machine-pointer cells, `Array<@T>`,
common `void **` graph-slot access, and full inter-arena copying require
verification. A positive test of one cell does not establish every
generator route, native/walker parity, or safety after freeing the source
arena. `satisfies` builds address correspondence from actually required
fields; a numeric position alone is not its contract. Current failures
and checks are in the current kernel gate (original reference: `../next_core_tasks_v3.md`).

Historically the clean graph adopted parts `args/return/data/code` and the order `call: data code` in 354;
355 executed sub-step 5а and 356 the first part of 5б, including launch by name over supplied data and named
arguments of `call`/`fncall`. Later slices added the own-data declaration pass and computed fn/sub,
and 372 extended shared named-head dispatch to the root and self. Their absence in 355/356 therefore
does not describe the current kernel. Full M11.5г/M11.8 remain open; the working frontend retains
the rules not yet migrated in step 8 of M11 (original reference: `../next_core_tasks_v3.md#m11`).

The accepted P0 package (slice 359, 2026-11-13) uses one stream parser inside `()`, `[]` and `{}` and post-processes a nested document once; it recognizes lost closing brackets, the end of a comment at the Mix document boundary, and marks attached to an intact string atom. The L2 `parser-suite` command passed 139 cases, including five saved changes to historical inputs; 11 end-to-end graph cases passed interp/native/forced. Exact builds, bootstrap acceptance and limits are in the witness (original reference: `../steps/witnesses/p0-unified-documents-20261113/notes.md`). That slice still unwrapped a sole anonymous Structure and rejected bare `f:`; both limits are removed in M8, slice 366 (witness (original reference: `../steps/witnesses/m8-preserved-groups-20261113/notes.md`)). The working frontend still retains the former M11 semantics; the P0 fix does not migrate it.

Slice 360 starts M8: the graph groups command records actual normalization events; 487 maintained .lm2 inputs contain 24,723 events. The working frontend gained a borrowed view of description groups, and L2 group-migrate can convert declaration sites selected from the report. General reception of the whole argument Structure is still pending, so normalization remains enabled. Exact inputs, commands and limits are in the M8 witness (original reference: `../steps/witnesses/m8-preparation-20261113/notes.md`).

Slice 361 extends the clean-graph binder of a computed argument Structure: a named field selects its formal by name and an unnamed field by its own position. New parts of the existing whole_arguments case produce 23 and 46. The L2 command `graph-same LOG EXPECTED` compares a completed log's AFTER section using the same comparison as graph-check, without rebuilding. Written Structure values in the working frontend and general reception of preserved groups remain unimplemented; P0 has not been switched. Evidence and next step (original reference: `../steps/witnesses/m8-argument-fields-20261113/notes.md`).

Later slices 362/363 let the working frontend receive a written Structure as a value or its direct named,
unnamed and mixed fields. The source object, fields and parent are retained; an anonymous body remains
both a data field and code of the same activation. Bootstrap quick G1/G2, the fixed point and focused
native/forced checks passed; slice 363 limits (original reference: `../steps/witnesses/m8-whole-fields-20261113/notes.md`).
Slice 364 (source05) adds one group reader for the clean graph, native emission and frame planning:
argument fields do not become names of the caller. An actual is read by the selected formal's contract,
and an anonymous whole operand uses the same live-frame eval_value after preflight. Named scalar groups
and alias calls give 7 in both paths. Bootstrap quick G1/G2, all thirteen comparisons and 597 inputs passed.
G2 rebuilt the graph tool; thirteen values, refusal before effects and whole_arguments passed
interp/native/forced, including matching refusal states. Evidence and limits (original reference: `../steps/witnesses/m8-graph-values-20261113/notes.md`).
Slice 365 (source01) reads written names and result requirements through one
borrowed reader of anonymous grouping, without resolving names, applying values or changing the graph.
The word formals of fn/sub, parts and both fncall paths use it. Bootstrap quick G1/G2,
thirteen comparisons and 597 inputs passed. G2 rebuilt the graph tool; nine values and the existing
fn_named_supply/fn_return_forms passed interp/native/forced.
Evidence and limits (original reference: `../steps/witnesses/m8-receiver-groups-20261113/notes.md`).
P0 has not been switched; M8 and the following M11/M13/M14 remain open.

Copying a description preserves evidence of its address layout. A later
argument can compose already known correspondences to that layout; the
result is cached as an address map, not as a new full reception check
of the description or Consumer.

Returned-method constructors stage captured value references and copy
that context together with the selected method through one graph map.
Repeated references to one captured Structure still denote one fresh
object, rather than one independent copy per name. Retention follows
the same admitted `independent: immutable` profiles as ordinary copying.
Current verification and remaining work are in the work log (original reference: `../steps/current.md`).

Identifier codes (IDENTIFIER-CODES; the author's decision of 2026-11-07,
the book (original reference: `LMX_semantics.en.md#fields`)). The process service `lmx_ids` --
the kernel's machine module `src/l2src/lmx_ids.lm2` -- holds the single
pair of tables code → name and name → code with one counter; the words of
the language the kernel compares against get the first codes in the order
of the `LMX_ID_*` constants of its header (the implicit throws 1..7
coincide with the walker's numbers). An emitted unit declares its table
`l2_ids` and its load `l2_ids_load`: as the first statement of its builder
it turns each written name into its code once (`lmx_ids_code`) and
publishes the table (`lmx_ids_unit_publish`, once per process); from then
on the unit holds only `l2_ids[K]`. A `LmxSourceName` row binds an
occurrence's address to a code, not to text; the registration of names,
the place tables `[m, SIZE_MAX, (code, type)...]`, the activation bindings,
the binder of named actuals, the path selectors `(code, occurrence,
prefix)` and the throw keys of native code and the walker work by codes; a
copy carries the code without reading a spelling (slice 302, an
intermediate result). Slice 308 (the translator's internal comparisons by
the same codes) was stopped by the author's directive of 2026-11-08 before
landing in selfbuild -- its candidate is kept as WIP in the
record (original reference: `../steps/witnesses/fix308-20261108/notes.md`). The author's decisions
of 2026-11-08 18:00–18:20Z (journal (original reference: `../LMX_blog/2026-11-08.md`)): a distinct type
"T without initialization" for every primitive, told apart by the region of the
cell's address -- a pointer onto the pre-existing cell of the place. Every write,
including the first, goes into that same cell. The later clarification (original reference: `../LMX_blog/2026-11-08.md#uninit-pointer-preserved`)
preserves the Structure field and internal pointer: neither is replaced or redirected on the first write.
This corrects the executor's earlier explanation rather than introducing a new language rule.
Every verification goes by arena addresses, addresses are
immovable; service operators and receivers have no separate codes; the term
"primitive" replaces "atom". The directive
(journal (original reference: `../LMX_blog/2026-11-08.md`)) replaces the numeric-codes
direction: the Lmx graph suffices to describe everything, the only
non-Structure is the primitive (its address gives its type, name and value), the
interpreter needs no parallel hidden structures of the program -- its
service traversal tables are left to the implementers; a name is read from
the address → name table; identifiers are single reused strings with stable
addresses compared by pointer; the arena attaches typed regions without
moving cells. The design is the kernel implementation
specification (original reference: `kernel-implementation.en.md`); the present `lmx_ids`,
`LmxSourceName`, place tables and codes are a transitional state to be
replaced by it (defect register (original reference: `../steps/defects.md`)).

</details>

<details>
<summary>Historical notes: older actual, merge, and expression migration</summary>

###### 4.2 `:=`, named arguments, a `merge` of arguments and the whole argument Structure: adopted rule, implemented by slices 303 and 304, partly by 307 (the remainders of Codex's review of 307 are the next slice)

(Implementation of the former norm, before 2026-11-19: the mentions below of the supply of the parts of `fn`/`sub`, of
the `args` of the receivers `call`/`fncall`, of the input description in `f\data` and of the hidden inputs of free
names describe the former mechanism; current norm -- `removed-builtins` (original reference: `LMX_semantics.en.md#removed-builtins`),
`structural-call` (original reference: `LMX_semantics.en.md#structural-call`), `binding-places` (original reference: `LMX_semantics.en.md#binding-places`);
replacement -- section of this document (original reference: `#binding-callables-20261119`). The norm of choosing the declaration by the
call was refined on 2026-11-19 (`declaration-selection` (original reference: `LMX_semantics.en.md#declaration-selection`)): the description
of the divergences below relates to the decisions of 2026-11-18 and is not reconciled with the refined norm.)

The author's decision of 2026-11-10 (book (original reference: `LMX_semantics.en.md#receiver-args-only`)): a place is declared only by
the form `receiver: arguments`, and a field written "name: type: value" (`a: int: 5`) is withdrawn. The slices below
are described as they ran: with the field of a `merge` operand in the former form, which the translators still
accept; under the norm it is written `(int: a 5)`. The same holds for the name that holds the result of a `merge`
(`pack: merge(...)`) and for a formal or a field written as a structural form (`Q: q`): under the norm of 2026-11-11
(book (original reference: `LMX_semantics.en.md#data-code-roles`)) they are declared `@: pack merge(...)` and `@: q Q`. Migrating the
fixtures and changing the reading is in plan M9 (original reference: `../next_core_tasks_v3.md#m9`) and M11 (original reference: `../next_core_tasks_v3.md#m11`).

The author's decisions of 2026-11-18 on the two kinds of receivers and on choosing the declaration by the call
(semantics (original reference: `LMX_semantics.en.md#two-kinds-of-receivers`),
choosing the declaration (original reference: `LMX_semantics.en.md#declaration-selection`)) are not yet carried out by the
implementation in four places. The clean graph does not choose among declarations of one name: two `fn`
with one name are refused when the name is resolved. The call binder does not check both readings of a sole
Structure: with one formal `h(One)` unwraps `One` and answers 9, and when both readings suit one declaration
it silently takes the unwrapped one. The native image chooses the callee and admits the arguments at every
call, and the translator refuses nothing. Modifiers unwrap a
Structure argument when it has exactly one field: `private: (int: x 10)` declares `x`, while by the rule the
argument there is a Structure and is not unwrapped. A path passes through a modifier's record: with
`Lib: private: int: x 10` the path `Lib\x` reads 10, while receivers are not executed in the graph and the
field is read by the path `Lib\private\x`.
The slices are in the plan (original reference: `../next_core_tasks_v3.md#two-kinds-of-receivers-plan`).

The rules are writing a known place (original reference: `LMX_semantics.en.md#assign-known`),
named arguments (original reference: `LMX_semantics.en.md#named-actuals`) and
the whole argument Structure (original reference: `LMX_semantics.en.md#whole-arguments`)
(the author's decisions of 2026-11-07). A probe on the published 301
tuple (record (original reference: `../steps/witnesses/named-assign-20261107/notes.md`)) found
the implementation did not carry them out: `:=` was not recognized,
`f(a: 5)` and `f(a(5))` bound the formal `a` because the head's name
matched it (35 and no call of `a`), the `merge` operands of the forms
`callable\args`, `a: int: 5` and `(a: int: 5)` were not lowered, and a
single Structure was not received as the whole argument Structure.
Slice 303 (record (original reference: `../steps/witnesses/fix303-20261107/notes.md`); native
and the walker, both roots) carries out the first two rules and a part
of the third:

- `:=` is one operator token of P0: a Frame of its left and its right
  side flagged `LM_P0_FRAME_ASSIGN`; `a := 5` and `a:=5` are one form,
  `a:` does not become a Frame head.
- Writing a known place is the general assignment path: a local, a
  formal (the activation's value), a field through a path, the
  conversion of the reception, a method reference (`target := two`
  redefines the reference without calling the bare right side --
  natively and in the walker's program, whose dispatch had read a binding
  holding a callable as a call of the method held). An unknown left side
  is the translation refusal ":= writes a place already known: its left
  side is not one here", in a method body and in a named Structure's
  body; it defines no field. The places are the declared formals, a
  visible own field (a unit field a method sees is its hidden input,
  Q52), a slot, a method-level local and the host activation of a nested
  method; the hidden input the collection makes of a free name for
  `x: v` (the rule is the one head resolution and the book;
  steps/free-names.md is the mechanism's history, its section 7 was
  withdrawn by the clarification of 2026-10-03) is no place for `:=`.
  A method's name as the left side inside a method (`one := two`) meets
  the existing implementation limit of writing a hidden input that has
  no activation value ("writing a hidden input that has no activation
  value is not supported yet"), the same as for `x: v`; it is not a rule
  of the language. Under the norm of 2026-11-11 such a form is an error by
  the rule of the language as well: the name of a function does not stand
  to the left of `:=` (book (original reference: `LMX_semantics.en.md#data-code-roles`)).
- A named argument is `f(a := v)` only: the left side selects the formal
  of the selected callable, the right side is evaluated in the ordinary
  way. `f(a: 5)` and `f(a(5))` with a callable `a` visible are its
  ordinary call with a positional result (62 and exactly one call of
  `a`); an unknown name ("zz is not an argument of tst") and a positional
  argument after a named one are translation refusals. The parts of the
  `table:` receiver are bound by the heads of its grammar by the same
  binder in its `by_head` mode. This is a remaining working-frontend path (OPEN M11.8);
  slice384 binds direct `fn`/`sub` parts in the clean graph by position or through `:=` only.
- A `merge` operand written name first -- `(a: int: 5)` and the bare
  `a: int: 5` -- is the typed field the declaration form `(int: a 5)`
  is: it writes the model's slot of its name, keeps the other fields and
  does not write the model; the parentheses of the second operand are
  optional.
- Slice 304 checked the former separate formal-description part; its details and results
  remain in the receipt (original reference: `../steps/witnesses/fix304-20261107/notes.md`).
  The current model stores input declarations and defaults in `f\data`, whereas the
  `args` of `call`/`fncall` contains actual supplied values.
  This distinction and the common call path are an open M10/M14 migration (original reference: `../next_core_tasks_v3.md#m10`),
  not behaviour already implemented by slice 304.
- The whole argument Structure from one Structure (slice 307,
  record (original reference: `../steps/witnesses/fix307-20261108/notes.md`); native and the
  walker, both roots): a call with a single Structure argument does not
  differ from a call with the chain of its fields. The binder marks one
  positional actual that may evaluate to a Structure (a name, a path, a
  `merge`, a call) as a candidate and defers the check of the omitted
  formals; the check decides on the static shape of the actual and the
  formals of the selected callable (`lm_compiler_whole_decide`): every
  field a formal of its name and of its kind's class, every other formal
  with a built default -- the fields are the arguments; otherwise the
  ordinary positional reading stands; when the Structure also fits the
  first formal, a Structure formal, by the first part of `satisfies` at
  translation, as the author instructed on 2026-11-08, with every other
  formal defaulted, both readings apply and ce01c206 refuses the call as
  ambiguous ("the Structure given to k is its argument q and its
  arguments: an ambiguous call", the fixture `whole_ambiguous_refused`);
  Codex's review of 307 established
  this as my own extension of the rule, not the author's decision (the
  author spoke of two really applicable methods; two `fn` of one name in
  one unit are refused at definition): the refusal is withdrawn by the
  next slice, the ordinary unambiguous call stands, no new priority of
  readings, the two-methods case stays a remainder. The binding is one kernel function of both
  executors after the evaluation of the single actual
  (`lmx_call_bind_whole`): the form against the current `args` part of the
  selected callable -- every field a formal, every other formal holding
  its current default, else the implicit `call`; then each formal, in its
  own order, receives the field of its name as a written actual of slices
  305-306 is received (a number through the route of its type or the
  implicit `convert`, a graph by the formal's own entry reception, an
  omitted formal by its default). The fields of the value are its named
  cells: the native layout of a declared Structure keeps a step cell
  beside each place (`Args: int: c 4; int: a 6` has four cells, `c` and
  `a` at 0 and 2). `pack: merge(mytest\args; (a: int: 5)); mytest(pack)`
  is 35, as `mytest(a := 5)` is; the declared `Args (c 4, a 6)` at
  `mytest` is 46 and `Args` is not written; `Only (a 9)` is 39; a
  Structure field at a Structure formal, a char field at an int formal
  through the program's receiver (one call), the callable place
  `Places\f` (a callable of other formal names held there: the implicit
  `call`); the ordinary reading at `take(Point)`, `take(p := Point)` and
  a Structure with extra fields (the fixture `whole_arguments`). The
  second pass of 307 (after Codex's review; the same record): the `merge`
  written in the call itself -- `mytest(merge(mytest\args; (a: int: 5)))`
  -- is lifted by the translation into a hidden declaration
  `l2_lift_<method>_<offset>: merge(...)` before the statement
  (`lm_compiler_merge_lift_walk`, before the owns are collected and the
  calls bound: the actuals of a call, the value of a declaration or of a
  `return`; the operands of a merge stay its operands) and gives 35 in
  both executors (`by_inline`); the names and the form of the whole are
  checked before the actual is evaluated -- the kernel
  `lmx_call_bind_whole_form` takes the codes of the static fields' names
  against the callable selected now (native `l2_wn`/`l2_wfs` before the
  evaluation, the WHOLE operand carries the names): a callable held with
  other formal names is the implicit `call` and a producer with a counter
  does not run (`early_form`, `Made\n` = 0); the applicability of the
  single-argument reading and the admission of the fields go by the
  general projection of the requirements relative to the Consumer
  (`lm_compiler_whole_applicable`: the uses of the input selected, the
  requirement's paths projected into the candidate), kind-strict at the
  leaves as the ordinary admission and the executors' reception are (the
  probe `whole_leaf_convert`: a candidate admitted by the conversion table
  stopped R0 in both executors -- the table at nested leaves stays a
  shared remainder); the refusal of two readings is withdrawn, and so is
  the hold (the author's answer of 2026-11-08, the journal): a Structure
  whose direct fields name the formals is given by its fields by the
  basic rule -- whether it would also fit the first formal as a value is
  not a question the rule asks (the fixture `whole_direct_fields`:
  `k (Q: q; int: z 0)` given `QZ (int: z 5; Q: q)` takes `q` and `z` from
  `QZ`, no default, 15; the explicit supply `k(q := QZ)` is 50); a
  Structure field without a leaf the callee reads is refused at
  translation (the fixture `whole_field_refused`), a field of another
  model with the leaves is admitted (`SArgs` with `Shape (x, y, w)` at `g`,
  10). Bounds: the operands of a
  `merge` written in the call evaluate before the call's form is checked,
  as a written `pack`'s do (a native statement's prologue reads the owns
  before its code -- the hidden declaration cannot be deferred to the call
  site); a `merge` in the actual of a callable held under a bare name, or
  deeper in an expression or in a control statement, is not lifted (the
  former refusal). The precedence of `:=` among operations and a value of
  the written form as an expression are not defined by the rule; the
  compound assignments are 4.3 (original reference: `#compound-assign-notes`).

The defects are recorded in the registry (original reference: `../steps/defects.md`).

###### 4.3 Compound assignments and `**`: adopted rule, unfinished implementation

The rules are compound assignments and the power (original reference: `LMX_semantics.en.md#compound-assign`)
and grammar §21 (original reference: `LMX_grammar.en.md#operators`) (the author's directive of
2026-11-07, with the clarification that `**` groups as in Python). The
implementation does not carry them out yet: P0 does not single out the
tokens `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`, `**=`
and `**`; neither native code nor the walker lowers a compound assignment
to a write of a known place or has a power operation. The intended route
is the one of `:=`: one token in P0, the lowering of `a op= b` as
`a := (a op b)` with the left place evaluated once (not a macro
substitution), `**` as a common numeric operation of the kernel for both
executors. To be clarified before the implementation: evaluating a place
with effects once, the types and conversions of `**`/`**=`, a negative or
fractional exponent, `0 ** 0`, the precedence of the assignments among
operations (plan M5 (original reference: `../next_core_tasks_v3.md#m5-assign-operators`)).

</details>

<details>
<summary>Historical kernel chronology: reported slices through 2026-11-15</summary>

**Slice401, 2026-11-15 -- typed overlap merge; bounded code gates PASS.**
Receiving closure fixes final layouts before Value edges; the common copier preserves scalar/WORD,
shared CHILDREN and reference Value cells. Graph84 get_in/put_in take explicit Graph context;
the legacy raw ABI remains for direct backing. Source07:934, G1/G2 quick/fixedpoint36,
G2 targeted5/0 and Graph6 triple PASS. This uses the earlier execution model; replacement M14 remains OPEN.
Witness401 (original reference: `../steps/witnesses/m13-overlap-20261115/notes.md`).


**Slice400, 2026-11-15 -- common mapped copier and written DATA fn_data; code gates PASS.**
Source04:934, genuine G1/G2 quick/fixedpoint32, actual G2 targeted5/0 and Graph6 triple PASS.
Full overlap merge, scalar CODE-own and native/cache/flush M14 remain OPEN.
Witness400 (original reference: `../steps/witnesses/m13-mapped-data-20261115/notes.md`), current pipeline (original reference: `../steps/current.md`).

**Slice399, 2026-11-15 -- written SOURCE and hidden transport; code gates PASS.** The common header-source
refusal and scalar FREE default metadata output are fixed. Written SOURCE and Model/capture admission guards are preserved.
Genuine G1/G2 quick/fixedpoint30, actual G2 targeted13/0 and Graph3 triple PASS; render/fresh docs check/final index PASS.
Current status (original reference: `../steps/current.md`). Common copier/construction and native M14 remain OPEN.

**Slice398, 2026-11-15 -- complete scalar Value in GraphRun working rows.** Ordinary Code over supplied typed DATA
preserves physical cell/slot, the place's SOURCE and RHS Model. Private06 and the sensitive GC mutant passed;
genuine G1/G2 quick/fixedpoint30 and Graph3 triple PASS. Actual G2:6 of9 rows PASS;3 existing L2 header-source
refusals reproduce on accepted397 and remain OPEN. G2 render35/14, fresh docs check and final index PASS.
Native/typed args/results/construction,
the shared cache and flush remain OPEN. Current status (original reference: `../steps/current.md`).

**Slice397, 2026-11-15 -- owned scalar receiving and formal places; bounded code gates PASS.**
Complete ACTIVE SOURCE is canonicalized by the existing counted TEXT interner separately from physical ABI.
Scalar actuals/returns retain the complete Value; the callee current Value and lazy mutable place are separate.
The first store/address creates its own cell and subsequent addresses are stable; an escaped pointer retains
the arena companion after activation exit. Direct stores update current; a read after an alias write refreshes
it from the companion and produces a snapshot. Runtime08/private13 SUITE1/0 covers a real dispatcher/scratch exit/GC.
FE07 raw/hosted ordinary-witness05/06 OSWALK0 confirms precision/store/address/caller isolation native/walker.
Source28:932/canonical, genuine G1/G2 quick smoke9/0, fixedpoint29 and actual G2 targeted6/0,
ordinary-witness07/Graph3 triple PASS. G2 render35/14 and fresh docs-check01 PASS35/14/27/44/615, links/LF28283;
the final index is checked before commit. Semantics source and grammar are unchanged.
Typed Run/FFI/Foreign-Array and the shared M14 cache/flush remain OPEN. Witness397 (original reference: `../steps/witnesses/m13-scalar-receiving-20261115/notes.md`).

**Slice396, 2026-11-15 -- public scalar resolver; bounded code gates PASS.**
The common frontend interner retains the source word, pointer depth, const and raw-C role; native printing
selects the exact scalar spelling from the active primitive.description. Translation-owned aliases use the
existing L1 type emitter; runtime row numbers and equal C spellings do not become semantic identity.
Public scalar machine units, including a separate reordered ACTIVE table with ProbeReal, pass private gates;
an ordinary method with double*** passes native/walker and root0/root1. Machine FP assertions remain native.
Whole01 genuine G1/G2 quick/fixedpoint29/canonical931, actual G2 recovery16 and Graph3 triple PASS.
Recovery reuses built objects after correcting the mistaken prod path; targeted01 SUITE is not reported as PASS.
G2 render35/14, fresh docs-check02 and indexed01 PASS35/14/27/44/615, links/LF28277/28283.
Owned scalar actual/result, runtime receiving/Run/FFI/Foreign-Array and the shared cache/flush remain OPEN.
Exact artifacts and acceptance limits are in witness396 (original reference: `../steps/witnesses/m13-public-scalars-20261115/notes.md`).

**Slice395, 2026-11-15 -- runtime/native execution GC roots; bounded code gates PASS.**
Before sweep, the marker visits existing activation/call_places, working frames and complete Values.
Temporary borrowed spans belong to the execution arena and detach before rewind/free; their owning scratch chunks
are retained explicitly, without treating scratch words as graph edges. Physical pool.profile is a separate live dependency.
Runtime02 and targeted collect/reclaim/pending PRIM/standalone Frame/native C ABI cases pass n/f/root0/root1.
The native emitter395 attaches working/pending Values and selected places to the same spans; existing statement,
loop/pad and inner branch scopes determine cleanup, and the trampoline drops body roots before the next poll.
Source27:927/Frontend04: the ordinary GC fixture passes native/walker and root0/root1, including a working snapshot after
clearing physical DATA, pending actuals, loops, short-circuit, catch and subsequent reclamation. Whole G1/G2 quick/fixedpoint31 PASS.
Public resolver/typed Run/receiving/FFI/Foreign-Array, the shared cache/flush and complete M11/M13/M14 remain OPEN.

**Current state, 2026-11-14, slice394 -- exact scalar ABI foundation; bounded code gates and docs-check PASS.**
The same35 Source rows generate header type aliases and profile bodies for32 scalar bindings (§3.2):
None/void have no cells, FILE remains opaque without a guessed binding. Source identity, C ABI and physical profile remain separate.
The machine C ABI unit passed native/forced with an ordinary owner and root0/root1: all32 bindings, float/double/flong precision,
i64/u64 limits, ABI rejection/protected write without mutation, immutable identity with nonzero physicalProfile,
and copy/projection/qualification/GC. FP assertions remain in the native C ABI unit; this does not establish general L3 FP execution.
Ordinary Graph.kind for Foreign remains0; SourceFact reads proven typed metadata before that fallback (§3.5).
Public primitive→frontend resolution, Run working/receiving/FFI, activation/pending GC roots and Foreign-Array ABI remain OPEN.
Source16:925, genuine G1/G2 quick with9 smoke each/fixedpoint20 PASS; actual G2 targeted4 n/f/root0/root1 and Graph3 triple PASS.
G2 render35/14, fresh docs-check01 and final indexed01 PASS; links/LF28270/28273.
Full acceptance of the common bridge and M11/M13/M14 is not claimed.

**Previous state, 2026-11-14, slice393 -- an operation-local SourceReader for source interface; bounded code acceptance/docs-check PASS.**
The common satisfies worker receives the selected Source's name/fact through a reader borrowed by the current operation (§3.5).
The full literal35-row/15-column projection of `primitive.description` is separate from physical `Fact.type` and ABI;
equal C spellings do not unify source contracts. All33 cell-row identity controls passed in private L2 native/forced
with root0/1. The qualifier chain is retained; references/Array give UNKNOWN without reading payloads.
Construction of direct three-argument `@` checks known candidate/Model by interface only: a proven missing Model field
refuses, `test` does not execute, and raw Model/default remain. No typed storage or runtime admission is claimed.
Actual G1/G2 quick/fixedpoint15, G2 interp23/AFTER22/image48, Unit08 and legacy2 PASS; this does not establish full
typed storage/runtime admission or M11/M13/M14. Render35/14 and docs-check01 PASS; the final index is checked before commit.

**Previous state, 2026-11-14, slice392 -- bounded code gates and docs-check01 passed.**
`declaration_parts` borrows the receiving leaf/model/candidate and presence/known while retaining the original root;
DATA logical names require a proven declaring contract (§3.5). The C-spelling projection extends the existing generated
primitive profile; `c_names` proves source-spelling roles without unifying C types with language aliases.
Arbitrary `c.*` remains provisional UNKNOWN. Construction does not turn receiving chains and their groups into DATA scopes;
model/default and unsupported qualified/Array/deep/typed forms stay raw, with no typed storage/admission claimed.
Final private Runtime06/Graph02: SHA-256 prefixes `fe17a328`/`69eab914`; frozen Source08:919, SHA-256
`b8b1b9b6095610b03bd26c80bc5c4988be3cfdc3c7b0eab0512a0c3994f44909`.
Private21: every interp/native/forced case and15 complete negative AFTER checks PASS; construction_shape_presence passes with its existing expected file.
Six new pairs; role oracles effects1/arithmetic15/called6/indexed12/via_whole13/done1.
Whole02: genuine G1/G2, nine smoke cases each, and tool PASS. Fixedpoint:13 artifact checks and2 canonical checks PASS after
canonical907→919 regeneration, without rebuilding artifacts. The genuine G2Graph SHA9c44994b is built;
actual G2 interp21/full AFTER21 PASS. Its42 emitted native/forced images and2 libc/backend files match byte-for-byte —44 PASS;
ready private binaries were reused without a new compilation or native/forced rerun.
The actual G1 frontend confirmed profile byte equality with quoted FILE; normal profile SHA-256
`d91946148a1c06809cd9ccd1a25a94cac303876a3032070ecb2fc7104a9facd5`; G1/G2 frontend exe equality PASS.
G2 render35 paired/14 cases/both snapshots PASS, with unchanged generated semantics and grammar.
Docs-check01/final index02 PASS35/14/27/44/615, links/LF28235/28262; commit/push392 follow. Record392 (original reference: `../steps/witnesses/m11-receiving-view-20261114/notes.md`)
retains the complete checks and history of intermediate attempts.
General typed storage/admission and the actual C-door bridge, full M11.7/8, M13/M14 and runtime `merge`/`sys\fromLmx` remain OPEN.

**Previous state, 2026-11-14, slice391 -- bounded implementation; code gates and docs-check passed.**
Only Run changes: private `construct_slot`/`construct_atom`/`construct_value` helpers extend bounded constructor390
to proven paths. Exports Graph75/Run58, ABI, layout and the public API are unchanged. A named step uses
`step_index`; a numeric index selects a physical slot and preserves its immediate value without turning raw `fn` into F
or resolving a WORD as a Structure name.
Only literal indices are used; index expressions are not executed. A named path retains exact source → F
and the existing masks (§3.5). Typed/qualified/common admission, full M11.7/8, M13/M14 and new construction
during runtime `merge`/`sys\fromLmx` remain OPEN; a held F without a native entry uses the walker.
6 sources/5 expected files were added, including `construction_paths_owned_data`; final Source07:907, SHA-256
`329fba48883be5014759e1fc74c4236873286c6050b69567c4ce3206f23ce9c3`.
The previous Source03/private48 triple and39 complete AFTER checks passed before the last correction, including43 existing
cases with unchanged expectations; this is an intermediate result, not final acceptance391. The combined probe
covers18 contexts/31 leaf oracles; a separate F.data probe checks two runs: initial11, bare8/9, held11/current9;
producer values change through `:=` to existing places. Graph01's index/atom distinction bug is corrected in Graph02;
the false EXPR pending blocker is also corrected. Final review found a missing pending audit for actual F.data,
which was outside the materialization queue: a method and a bodyless descriptor gave4 instead of2. Private `construct_data_scope`
corrects recognition of its lexical role without a materialization/blueprint walk; new Runtime03/Graph03 and the focused
check passed: method/descriptor2/2, data width2/2. Runtime03 SHA-256
`6a6105346ea9e3b841556ff5d29582dca09767931e7cc7bc9d2f88abad437582`, Graph03 SHA-256
`7aad957de36545b74dc225c2214f302357b9bcf48a3ab41ca4f44cc6e1af37c6`.
The owner stopped the first whole bootstrap01; its processes are terminated, with no acceptance claimed.
Private02: all49 cases in interp/native/forced and39 complete AFTER checks passed; the previous43 cases' expectations are unchanged.
Whole `boot-m11-construction-paths-02` passed: genuine G1/G2, nine smoke cases each, fixedpoint15/verify907 PASS;
private Runtime03 matches the G2 driver. Intermediate Source06 differs from verified Source05 only in formatting two
new fixture sources: a redundant single-level `end` after a bootstrap terminal was removed. Complete AFTER results match for2 cases,
and four generated native/forced programs match byte-for-byte. Source07 additionally removes redundant trailing blank lines
from the six new fixture sources:10 generated native/forced programs match the previous genuine G2 outputs byte-for-byte,
build4 control PASS, fixedpoint03:15/verify907 PASS. Core and compiler-build inputs are unchanged;
no additional whole was run for these fixture-only corrections. The genuine G2 graph-tool is built, SHA-256
`0cc869f7c12b9b3d7ae57aec8957602fcfaabe0750759ab9f5a131195f17b5a5`.
The G2 repeat of all49 cases in three modes and negative AFTER39 passed. Render35/14 PASS, generated content/grammar unchanged;
Fresh docs-check01 PASS35/14/27/44/615, links/LF28142; final index391 is checked before commit.

**Previous state, 2026-11-14, slice390 -- bounded implementation, code checks and docs-check passed.**
After filling the P0 fields, `lm_graph_build_root` calls `lmx_graph_construct`, then a separate pure preflight (§1a).
Construction owns a fresh namespace; held F values remain ordinary graph values, while raw `fn`/`sub`
remain written declarations. Source-known reference candidates fill places without executing CODE,
defaults, computed actuals or `test`; mutable aliases stay deferred (§3.5).
Private43 in three modes, including 36 existing cases, and 33 complete AFTER checks passed. Separately,18 logical interpreter
probes and2 FN-image cases in three modes passed. The initial mutable-alias mismatch1 instead of2 and native-image parent0/allocator failure are corrected.
Whole `boot-m11-known-data-01` quick passed: genuine G1/G2, nine smoke cases each, fixedpoint15/verify896 PASS;
private Runtime03 matches the G2 driver. The genuine G2 graph-tool is built, SHA-256
`17d12ce77360e99af075fb90967e0b7aef76f94985566a89e49b617d4bfd058a`; the G2 repeat of all 43 cases in interp/native/forced
and 33 complete negative AFTER checks on existing binaries passed. All code gates390 PASS.
Normal render35/14 and fresh docs-check01 PASS35/14/27/44/615, links/LF28087; final index before commit.
This route is bounded to direct two-argument `@`; paths, type fields and new construction
during runtime `merge`/`sys\fromLmx` remain OPEN. A held F without a native entry uses the walker.
Full M11.7/8 and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice388 -- bounded code and documentary acceptance are confirmed; commit/push follow.**
An occurrence and a literal exact name differ by the structure of the right step of the existing path3 (§3.3):
common `Graph.occurrence` (Graph74) reads an ordinary anonymous pair, and `Run.step`/`step_place` take a raw step (Run54).
The same reader, admission and native use this selection; P0 preserves quoted components through the common head scanner.
13 new cases passed in three modes; another 7 existing cases passed after golden formatting corrections only:
20/21 in aggregate. Genuine G1/G2 whole quick passed nine smoke cases each; fixedpoint15/verify867 PASS.
The genuine G2 graph-tool is built, SHA-256 prefix `0fcf70f9`; the G2 repeat gives the same 20/21, with all 13 new cases PASS.
9 full negative AFTER checks passed by reusing the existing binaries.
`root_occurrence_index` answers run3 under both seed387 and the new code;
its numeric seen3 expectation is retained, and the common declaration-site → frame map remains OPEN.
Source06:867, SHA-256 prefix `19d3d5dc`. Normal render and docs-check01 PASS35/14/27/44/615, links/LF27962;
Final index-check02 PASS, links/LF28021; commit/push388 to main follow.
Full M11.7/8 and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice384 -- bounded implementation, code acceptance passed; base383 `58bc7f3a`.** Direct named actuals of `fn`/`sub`
bind formals through `:=` only; `by_head`/mode2 and the former `frame_value` are removed from Run.
A whole descriptor is read as DATA: its colon fields are retained without execution. Structure formals `args`/`data`/`code`
read an actual through common `read_received_value` with contract2: a written group is inert, an unknown named Frame reaches
application and refuses3. `name`/`return` retain their written-description contract, including `@: c.FILE`.
`fn_decl_name` is a graph-only query: direct supply is separate from one whole-DATA descriptor, with no recursive
unwrapping or Space dependency (§3.4). The direct/whole-DATA positive pair gives12/12;
reception order gives effects1/later0/refusal5, and a retained code group with a missing call has length1 without effects.
Runtime01/Graph01, private32 triple,87 full AFTER checks,2 baseline checks and mutation24 passed.
The first private32 retains3 FAILs: stale fn_prepared/call_receivers goldens and a static name at emit5.
Seed383 confirmed six full AFTER checks; only13 synthetic RHS parenthesis lines were corrected, with numbers retained.
The static-name probe and emit5 are retained: no native runtime was created for it. A new reached-name case with computed args
and name-call/finally were checked by private02 on two new sources in three modes:5/before1/after0 and cleanup1.
Source03 SHA-256 `ac0d0a1ca48bfdb488c44982ada095ef2e7516dd304831d5987a735c55f13e9f`.
Whole bootstrap quick passed: genuine G1/G2, nine smoke cases each; fixedpoint13/verify798 PASS.
Native trace02 confirmed actual root → `fn_apply` → `receiver_bind` evaluate1 → actual native producer:
effects1/later0/body0/before1/after0, expected host exit1. The first GDB01 with missing args is retained and is not counted as proof.
The genuine G2 graph-tool is built, SHA-256 `09f0e983a7baa2b892bd755c5845495355062e673b41ff6556a02a6899004f82`;
G2 repeat:32 triple/21 full negative AFTER checks/mutation24 PASS. Tested code tuple384:
boot-m11-receiver-actuals-01/g2 + graph-m11-receiver-actuals-g2-01.
Normal render/docs check384 passed:35/14/27/44/615, links/LF; commit/push main follows.
A common catalog/declaration view and formal validation are OPEN M11.5e;
the working frontend's `by_head` is OPEN M11.8; full M11, external/computed CodeBody and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice383; base382 `d0e384c1`.** Only Run changed:
the common resolver distinguishes a pure query from a consuming read with a local status. Consuming raw fn/sub
without an F for the corresponding scope/source prepares the reached block through existing `space_declarations`/evaluate0;
sibling written methods are prepared in the existing order. Classification, slot requirements and binder queries stay pure
and do not re-enter a receiver being constructed. A constructor failure keeps its answer rather than becoming missing3.
The source/parent proof also covers the enclosing `node`. Copier, `fn_data`, Frame and Run53 ABI are unchanged;
there is no new registry/error field, SourceSpace transfer or restoration of FN-role on an ordinary F copy.
10 pure cases passed: raw Fn1/2/sub2/marks25 with source3; unentered1/2; named parts7/7;
held aliases8/8/8/9 with source3/next4; explicit clone4/5/source3; ordinary descriptor5;
malformed constructor5/before1/after0, pending3/touch0, ambiguity3; two walks give source1/held3.
Private34 triple gave32 PASS and two differences only in synthetic assignment RHS parentheses of existing
reference_alias/descriptor_merge. Seed382 confirmed that same shape through six full AFTER checks;
four parenthesis lines were corrected, with numbers retained. All102 full AFTER checks on the same binaries and mutation24 passed.
The trace confirmed actual native root → consuming declaration → scope preparation7/7 and normal exit;
a new callable may use the walker, M14 OPEN. Code was built on Source01:761; Source02 adds10 fixture pairs,
Source03 changes only four existing parenthesis lines:781 inputs, SHA-256
`4a7ed184d976b820d605f14c2e9a33970b16e0dae54c0ae95e83c35d9b5e5604`.
Whole bootstrap quick passed: genuine G1/G2, nine smoke cases each; fixedpoint13/verify781 PASS. The genuine G2 graph-tool is built,
SHA-256 `10dbb1b4dab7e7dd3395ea441d8a481ec795e6992bf60f3afa0be91bc0e35b59`.
The G2 repeat (34 cases in three modes, including runs2; 33 full negative AFTER checks; mutation24) passed;
Normal render/docs check383 passed:35/14/27/44/615, links/LF.
The working tuple is383: boot-m11-copy-bindings-01/g2 + graph-m11-copy-bindings-g2-01.
This is a bounded check of the copy classes; full M11, remaining5e/7/8, external/computed CodeBody,
native copy and M13/M14 remain OPEN.

**Previous state, 2026-11-14, slice382; base381 `38cf026c`.** Common `code_body` returns
borrowed `body/from/to` through existing control-argument roles (§6.3). For the whole
`else`/`finally` tail, a sole written group is selected as the body once; an already selected body or its remainder
is not unwrapped again. The scanner, `fn_own`, walker, native and `code_parent` use that same selection,
without changing physical parents or adding a frame or registry; exports are Graph71/Run53/implements74.
Runtime01/Graph01 and five pure cases passed: calls4 instead of2, cleanup trace21 instead of1,
written Fn790/computed890 instead of90, own late7/cleanup return4-after5/inert fields0,
including unknown inside a double group; the negative case gives6 with cleanup/root trace21.
Code was built on Source01:751; Source02:761 adds only five fixture pairs, SHA-256
`be5db8e3168082a1509b5b035f7d293b0f8ec40a6092c321b247647443e04d7f`.
Private25 triple/75 full AFTER checks/mutation24 and native written/computed outer/fn_apply trace passed.
Genuine G1/G2 quick with nine smoke cases each, fixedpoint13 and verify761 passed. The genuine G2 graph-tool is built,
SHA-256 `f71df0958fda2d9be2e958b70fcd3b081e2248305aa07a68a7dbf6eda5b89316`.
The G2 repeat (25 cases in three modes, 21 full negative AFTER checks, mutation24) and normal render/docs check382
passed:35/14/27/44/615, links/LF. The working tuple is382: boot-m11-codebody-01/g2 + graph-m11-codebody-g2-01.
External or computed CodeBody,
copying raw declarations and held F as distinct values, full M11, M11.7/8 and M13/M14 remain OPEN.
Acceptance of the copy classes is separated in the plan reading (original reference: `../steps/handoff/copy-construction-reading-20261114.md`):
source Space bindings are not transferred, and applying `fn` anew remains a separate construction.

**Previous state, 2026-11-14, slice381; base380 `c5ba5ef9`.** The existing frame's `lexical_scope`
tracks the selected physical CodeBody, preserving `code`/`body`/`data`; the walker and native share
`work_scope` (§6.3). Runtime06/graph02, 17 pure cases, the previous 67 full AFTER checks unchanged,
private31 in three modes, AFTER93 and mutation24 passed on Source07:751. The final emitter-only optimization
covers the first statement with the entry prefix without a repeated call. Graph03/private02 inline triple and native trace
passed on Source08:751, SHA-256 `b84c11fec03b4eb7fa7a35db19ebf732be8ab13975191eb704207dab0961e906`.
The trace confirmed actual native outer, `work_scope` and `fn_apply`. Genuine G1/G2 quick with nine smoke cases each,
fixedpoint13 and verify751 passed. The genuine G2 graph-tool is built, SHA-256
`b8abfe4c58cc5702009aa09f65ce0a9b040aec403602c1c31eec88989fbcce4f`.
The genuine G2 repeat (86 cases in three modes, 102 full negative AFTER checks, mutation24) passed;
normal render/docs check381 passed:35/14/27/44/615, links/LF. The working tuple is boot-m11-computed-body-01/g2
and graph-m11-computed-body-g2-01; record (original reference: `../steps/witnesses/m11-computed-body-20261114/notes.md`).
Full M11, copying a live F with its data and M13/M14 remain OPEN; a dynamically created callee may
use walker fallback, which does not establish ordinary native M14.

**Previous state, 2026-11-14, slice 378 -- acceptance passed.** Two core sources change:
the root uses the common work frame and block0; the native wrapper finishes that frame and forced reuses it.
The separate root emitter is removed. Scalar values stand without capture; discarded AST uses the common value reader,
and computed body bindings use existing metadata/rows. Runtime01/graph01 and five pure cases passed.
Private01 executed 50 cases in three modes: 48 matched their old goldens, 2 required five independently derived
root snapshot k5 changes: three outside8→5, data_result118→115, second892→592;
open_result55 is retained. The existing 50 binaries were not rebuilt. Additional root_frame_error passed triple;
in total 51 cases executed in three modes, all 153 complete AFTER comparisons and mutation24 passed.
finally_body_error/sub_error previously had no expected files; complete AFTER checks with root_trace12/seen12 were added.
Three existing fixture pairs now use explicit control Frames. Source04: 685, SHA-256:
b8e7d5a1a3742540b298ac30f0f1c2cc2f72fa776a358d14258ab1bd77e935d4.
Whole bootstrap01 quick passed genuine G1/G2, nine smoke rows each, fixedpoint13/verify685. Genuine G2 rebuilt
graph-tool and repeated 51 cases in three modes, AFTER60/mutation24; runtime01 matches G2.
Render/docs check passed:35/14/27/44/615, links and LF27517; both diff checks are clean, actual native root trace01 passed.
Working tuple: boot-m11-root-frame-01/g2 and graph-m11-root-frame-g2-01.
G2 graph SHA-256: dff1d7202b123be1758e88248960da8ba6f64aed57929729ba8edf453255eed7.
Full M11.5г, path-head calls,
computed ordinary declarations, M11.7/8, legacy computed-int construction M13 and shared cache/flush/ordinary native M14 remain OPEN.
Witness 378 (original reference: `../steps/witnesses/m11-root-frame-20261114/notes.md`).

**Previous state, 2026-11-14, slice 377 -- accepted `04fbf275`.** Only `lmx_graph_run.lm2` changes in the core:
frame opening prepares written fn/sub in selected data/body before work scan, and repeated preparation reuses
the existing scope/raw-source binding. State preserves F and its own data: first1/second2, leaf_count2/sub_count2,
bumped2. Separate D/C give 32/34, data_count12/code_count22, touch_calls0. Two leaf declarations at different
raw sources remain distinct occurrences; bare leaf refuses with 3 before the body, before1/after0. Source02:673;
private38 in three modes and AFTER45/mutation24 passed. Whole bootstrap01 quick passed genuine G1/G2,
nine smoke rows each, fixedpoint13/verify673. Genuine G2 rebuilt graph-tool and repeated 38 in three modes,
AFTER45/mutation24; runtime02 matches G2. Normal render/docs check passed:
35/14/27/44/615, links and index LF27467; both diff checks are clean.
Source02 SHA-256: 1441737c4cf71b27ab81c4734846f1b30a469326f7146f1dc86c33f74f8e4fa9.
Working tuple: boot-m11-ordinary-nested-01/g2 and graph-m11-ordinary-nested-g2-01.
G2 graph SHA-256: 039e29be84a420aa7ace00c0ba6003472bb56146c3fb5a40093aba124d6d2f5a.
The whole of M11.5г, root-frame work, computed ordinary declarations, M11.7/8, M13 and ordinary native M14 remain OPEN.
Witness 377 (original reference: `../steps/witnesses/m11-ordinary-nested-20261114/notes.md`).

**Previous state, 2026-11-14, slice 376 -- accepted `9039fa89`.** Canonical `@: p int`
without a candidate preallocates wrapper8/cell5 before index/typeof/path; a required formal8 receives an independent
reference cell through common admission. Source04: 669; runtime02/graph03, five pure cases, private36 in three modes,
AFTER42/mutation24 passed. Actual native TypeOnly with physical8 in method.code was confirmed by GDB trace03
in the private pipeline with a normal exit. Whole bootstrap01 quick passed: genuine G1/G2, nine smoke rows each,
fixedpoint13/verify669. Genuine G2 rebuilt graph-tool and repeated 36 in three modes,
AFTER42/mutation24; runtime02 is identical to the rebuilt runtime. Working tuple:
boot-m11-uninit-reference-01/g2 and graph-m11-uninit-reference-g2-01. Normal render/docs check passed:
35/14/27/44/615, links and index LF27434; both diff checks are clean. G2 direct trace01 also passed.
Source04 SHA-256: de34eb33fb7f603d1ed08c8bf7f69da0c7ffe5cd473d3408f9e770f5e6840daf.
M11.7/8, the whole of M11, M13 and ordinary native M14 remain open.
Witness 376 (original reference: `../steps/witnesses/m11-uninit-reference-20261114/notes.md`).

**Previous state, 2026-11-14, slice 373 -- computed reference places; code acceptance passed.** The existing work map
binds a retained raw `@` Frame with a candidate: three fields for an int reference, two for a Structure reference.
Admission does not run the initializer. Reading or launching that place before a working write refuses with 5;
the first write creates a working typed reference, and normal flush publishes it through the existing slot.
Existing initialized cells and wrappers retain their contract. `@: p int` without a candidate is OPEN:
it requires kind5 and already allocated wrapper8/cell5; the form currently refuses explicitly with 5,
is never treated as kind6 and does not allocate storage lazily. This is not refusal based on uninit:T contents.
Runtime02/graph01 passed six pure-interpreter cases: places 41/13/30/23 with calls0; read and head -- 5
after before1 with calls0; reference and numeric preflight -- 4 with calls0; binding priority 7/8/9/12 with calls0.
Full bootstrap quick built genuine G1/G2, nine smoke rows each; thirteen fixed-point checks and 643 inputs passed.
Genuine G2/graph repeated22 in three modes, AFTER24 and mutation24. Normal rendering and docs check passed:
35/14/27/44/615, links and LF for 27,317 indexed files; both diff checks are clean.
An independent probe reopened the M8 consumer for @2 with a written one-field Structure; it comes next.
The whole of M11.5г, the shared root route and ordinary Structure native in M14 remain OPEN.
Current slice and limits (original reference: `../steps/current.md`).

**2026-11-14, slice 372 -- root/self dispatch, M11.5г OPEN.** A named head is resolved against live data
and calls a method or launches an ordinary Structure through the shared mechanism, including the root and a self launch.
A standalone written anonymous Structure remains a value: its fields do not execute or add inputs or own places;
selected control bodies and directly consumed expressions retain their roles. The private bundle passed sixteen cases
in interp/native/forced, three complete AFTER comparisons and mutation. Full bootstrap quick built genuine G1/G2,
nine smoke rows each; thirteen fixed-point checks and 631 canonical inputs passed. Genuine G2/graph repeated eighteen
cases in three modes, AFTER3 and mutation24. Normal rendering and docs check passed:
35/14/27/44/615, links and LF for 27,273 indexed files; both diff checks are clean.
Root numeric/reference publication and direct calls through path heads still need the shared
route; the whole of M11.5г, the following 5д–5е, M11.7/8 and M13/M14 remain open.
Current checks and limits (original reference: `../steps/current.md`). The chronology below retains the results and limits of its own slices.

Paired version -- RU (original reference: `kernel-implementation.ru.md`). The normative sources of the language are the L3 semantics (original reference: `LMX_semantics.en.md`),
the grammar (original reference: `LMX_grammar.en.md`), L2 (original reference: `L2_spec_en.md`) and L1 (original reference: `L1_spec_en.md`); this document is the specification of the
**implementation** of the kernel and of the code it emits, by the author's directive of 2026-11-08 (the author's words
verbatim -- the journal (original reference: `../LMX_blog/2026-11-08.md`), the sections "Остановка инкрементальных кодов идентификаторов…",
"Атом — единственная не-структура…", "namespace — служебные таблицы обхода…", "Чистый граф…", "Единый механизм
неинициализированных примитивов…", "Все проверки — по адресам в арене…", "Замена указателя — при первом присваивании",
"Служебные операторы и ресиверы — без отдельных кодов…", "Термин: примитив, не атом…", "«int без инициализации» —
указатель на ту самую ячейку…"; the relays CODEX-FABLE-AUTHOR-KERNEL-REBUILD-20261108T171209823Z-01,
CODEX-FABLE-AUTHOR-ATOM-ADDRESS-20261108T172249908Z-01, CODEX-FABLE-AUTHOR-NAMESPACE-TRAVERSAL-20261108T172512156Z-01,
CODEX-FABLE-AUTHOR-CLEAN-GRAPH-FRESH-TRAVERSAL-20261108T172943665Z-01,
CODEX-FABLE-AUTHOR-UNIFIED-UNINITIALIZED-TYPES-20261108T180019959Z-01,
CODEX-FABLE-AUTHOR-ARENA-ADDRESS-VERIFICATION-20261108T180226654Z-01,
CODEX-FABLE-AUTHOR-FIRST-ASSIGNMENT-ONLY-20261108T181027312Z-01,
CODEX-FABLE-AUTHOR-OPERATORS-STRING-ADDRESSES-20261108T181832549Z-01,
CODEX-FABLE-AUTHOR-PRIMITIVE-TERMINOLOGY-20261108T182057865Z-01,
CODEX-FABLE-AUTHOR-UNINIT-POINTER-SAME-CELL-20261108T190254726Z-01; Codex's reviews
CODEX-FABLE-KERNEL-SPEC-REVIEW-20261108T175116933Z-01 and CODEX-FABLE-KERNEL-SPEC-REVIEW2-20261108T185727823Z-01 are applied).
Status: **the working specification of the transition; Codex has not declared the document accepted as a whole** -- the
direction and the order of §11 item 0 were allowed by the second review, the implementation has started from the
independent base; there are no open questions to the author. Marks: "norm" -- the author's words or the current book;
"decision" -- the implementer's choice within the norm, checked by Codex. The record of the slices below calls the
parts of a callable as the slice called them -- `var`, `body` -- and writes the order of the two arguments of `call` as
`call: code data`; by the author's decision of 2026-11-11 the parts are `data` and `code` and the order is
`call: data code`, and the clean graph reads them since slice 354 (§3.4) (implementation of the former norm, before
2026-11-19; current norm -- `structural-call` (original reference: `LMX_semantics.en.md#structural-call`): `call` has the parameters `args`
and `code`, and its data is `parent(C)`; replacement -- section of this document (original reference: `#binding-callables-20261119`)).

Codex's graph10/tool11/rt07 implementation executes the Point/take example of §10 and used-field checks through both
consumers; evidence and limits (original reference: `../steps/witnesses/clean-call-20261108/notes.md`). This is a partial migration:
int results, a body with one return, empty var, positional arguments and int defaults are supported.
The next graph11/tool11/rt08 (original reference: `../steps/witnesses/clean-expr-20261108/notes.md`) normalizes supported expressions:
a binary operation is Lmx [left, operator word, right], a prefix operation [operator word, operand]; construction sets
the nesting and respects P0 separators. Both consumers read this form without precedence parsing. The remaining
operators, body, admission, primitive and root forms are not implemented yet. The specification below
states the target, rather than claiming that the entire existing runtime conforms to it.

The graph15/tool12/rt12 continuation (original reference: `../steps/witnesses/working-var-20261108/notes.md`) supports explicit int var and
sequential fn bodies: assignments, calls and return. Working values belong to each activation, while actual fields
stay in var; dirty values are published after argument evaluation before a call and on exit, including an error.
Native computes the body itself using the shared working-place and publication mechanism. All 24 execution checks
and 19 graph-mutation checks passed.
The next graph18/tool13/rt15 (original reference: `../steps/witnesses/body-inputs-20261108/notes.md`) constructs body-declared int places in var,
visible from the first line; body initializers stay at their statements. Dynamic int inputs get activation-local
places before var; nested methods impose no input requirements on their callers. Native method collection uses one
traversal of the completed graph, independent of construction. All 30 execution and19 graph-mutation checks passed.
Control flow, other working-place types, full admission and general call:code data were still open at that point.
The next code/data continuation (original reference: `../steps/witnesses/code-data-20261108/notes.md`) binds int places of ordinary Structures
and fn to explicitly selected data. Shorthand selects var; code=data uses the same mechanism. The address map and working
values live only in the activation, data is not extended, and native computes the body directly. Remaining types,
control flow and full admission are still open; the activation model is not complete.
The next graph24/tool16/rt22 (original reference: `../steps/witnesses/control-flow-20261108/notes.md`) supports if/else, while, for,
nearest-loop break/continue/redo, return from inline bodies, comparisons and short-circuit &&/||. Bodies remain ordinary
Lmx and execute in the current activation; construction adds their own int fields to the shared var. Native emits its
own conditions and jumps. All27 execution and19 graph-mutation checks passed.
The current graph28/tool17/rt23 (original reference: `../steps/witnesses/post-loop-20261108/notes.md`) builds until as ordinary Lmx
[until, condition, body]. A named Structure retains its fields and an executable field referring to that loop;
fields shared by the body and Structure remain the same cells. Native allocates each encountered address once;
a temporary translation map associates it with a generated constructor local and is discarded after the traversal.
Both consumers evaluate the postcondition after the body; continue reaches it, while redo skips it.
All33 execution and19 graph-mutation checks passed. Named transfers, cleanups and remaining types/forms are still open;
this slice completes neither the activation model nor a general graph-state codec.
The current graph34/tool19/rt26 (original reference: `../steps/witnesses/finally-20261108/notes.md`) executes reached finally registrations
in reverse order on scope exit: normal completion, return, nearest-loop transfers and supported errors. The return
value is held before cleanup; dirty fields publish before activation-exit cleanups and afterwards. A transfer or
failure inside a cleanup neither reruns it nor omits outer cleanups. Native emits these paths directly; registration
state lives only in the current traversal/call. All42 execution and19 graph-mutation checks passed. Named targets,
throws/catch, stop/yield, other types and the complete activation/codec/selfbuild migration remain open.
The graph36/tool21/rt28 continuation (original reference: `../steps/witnesses/sub-calls-20261108/notes.md`) brings sub into the shared path:
the word sub and args/var/body parts, with no return part. Root and nested calls, defaults, explicit code/data,
dynamic inputs, fallthrough, bare return and finally use the same activation and publication rules.
Using sub as a number is refused before argument effects. All42 execution checks, two result-refusal checks
and19 graph-mutation checks passed. fm, other types, full admission, exceptions, graph-state operations and §§8/8a remain open.
The current graph40/tool22/rt30 (original reference: `../steps/witnesses/known-assignment-20261108/notes.md`) preserves := as Lmx
[the := word, destination, right operand]. No parser flag survives; a destination path is ordinary nested Lmx.
Both consumers check a known int destination before the RHS; a bare name writes its working value, an explicit path
writes the graph without refreshing the working snapshot. Native computes the RHS directly. A typed int literal
is built as the same primitive. All30 execution and19 graph-mutation checks passed. Other types, reference writes,
named := arguments and §§8/8a remain open.
The next graph41/tool23/rt31 (original reference: `../steps/witnesses/named-arguments-20261109/notes.md`) supplies named arguments `a := v`
in a callable's argument structure (Codex's WIP, checked and finished by Opus). One temporary call binder matches the
written positional and named actuals with the physical formal slots of the selected callee by name addresses; an
unknown name, a repeat, a positional after a named one and a missing required formal are form refusals before any
argument effect. Then the right operands are evaluated in the written order, each received by its formal at once; a
refused reception leaves the later ones unevaluated and the body does not start. The binding map lives only in the
call; native emits it and computes the right operands itself. `a(5)` and `a: 5` stay ordinary calls with positional
results. All 45 graph fixtures: 45 graph-check runs × interp/native/forced passed (sub_void_value separately),
mutation 11/11, method-mutation 8/8. Computed defaults, AXBY with user conversions, q/z, merge35 and §§8/8a remain open.
The next graph42/tool24/rt32 (original reference: `../steps/witnesses/whole-arguments-20261109/notes.md`) gives the whole argument structure
of one Structure: a single positional actual without effects (a name or a path) whose direct fields name formals of the
selected callee of the same kind, every other formal having its default, is supplied by its fields; otherwise it is the
ordinary first argument. One kernel function `lmx_graph_call_single` decides for the interpreter and native alike, by
the formals and the direct fields, with no tree search and no second reading: `k(s)` takes q and z from `s` (15),
`k(q := s)` gives 50. 48 graph-check runs × interp/native/forced, mutation 11/11, method-mutation 8/8 passed. `merge` in
the clean graph (example 35), a Structure producer with effects and the choice between two methods of one name remain.
The next graph43/tool24/rt33 (original reference: `../steps/witnesses/whole-empty-20261109/notes.md`), after Codex's review, replaces the
field/formal kind check by the common admission of the subset: a field is supplied to a formal only when that formal
accepts it (`lmx_graph_admit`); an empty Structure is the empty field chain, the call of a nullary or default-only
callee (`zero(zero\var)` = `zero()`, `defaults(zero\var)` = `defaults()`). The current builder does not construct an
empty named Structure (`Empty: ()`) — a recorded limitation. 49 graph-check runs × interp/native/forced passed.
The next graph44/tool25/rt34 (original reference: `../steps/witnesses/clean-merge-20261109/notes.md`) gives `merge` in the clean graph
(§6.4). The operands are evaluated once, left to right, by their general meaning: a name, a path, a nested `merge`, a
call; an anonymous Structure `(a: int: 5)` is built by the ordinary rules — an unknown name is defined by its field. Then
one kernel operation `lmx_graph_merge_values`, for the interpreter and native alike, builds a new root with the model's
layout and the new fields at the end; a same-named field of a later operand is written into the model's slot by the
admission of an assignment (the same cell). One source → copy map serves all operands: operand roots map to the
result, shared targets and cycles stay shared, the copies' name rows keep the canonical names; the sources are not
changed. A head naming a function is called once and no model field intercepts the call: `f(3)` and `f: 3` are one
graph, and an int result is no Structure — an admission refusal (4). A Frame whose head is no function describes a
structure; its copy carries written names, and copying their lexical chain is open (5), as is copying callables, so the
result has no lexical parent. `mytest(merge(mytest\args; (a: int: 5)))` = 35 in all three modes, the native code runs
`merge` at execution time. `merge(f1; f2)` of two functions (the builder does not build a descriptor without a body), a
held place `pack: merge(...)` and replacing a Structure slot remain open. 53 graph-check runs × interp/native/forced
passed.
The next graph45/tool26/rt35 (original reference: `../steps/witnesses/merge-places-20261109/notes.md`), after Codex's review: a field of a
later operand that names an int place of the result is that same place in the one map (its value and its cell, the
cell behind `uninit:int` included); the correspondences are set before references are copied, so a reference to it
reaches the result's place in any field order (`R\a := 9` → `\R\p` = 9, sources intact; a mutant without this step gives
5). A field `name: @x` of an anonymous Structure is a new reference place. A root statement `name: value` with an
unknown name defines the place by its value (`lmx_graph_define`, both consumers):
`pack: merge(mytest\args; (a: int: 5)); mytest(pack)` = 35. The interface descriptor `f2 :: (int: b 7) int` is built
with its `args` and `return` parts and an addressable empty `var`, without a body; it is no callable. Copying written
names and callables (with their lexical ancestors) and matching the `fn`/`return` parts in `merge(f1; f2)` (a question
to the author) remain open. 58 graph-check runs × interp/native/forced passed.
The next graph46/tool26/rt36 (original reference: `../steps/witnesses/merge-repeat-20261109/notes.md`), after Codex's review: a later supply
of a field is told from the first fill of its slot by its position (operand, field) — local data of the merge
traversal — not by its address, so the same source given again is written again in operand order:
`merge(M; N; M)\a` = 1, `merge(N; M; N)\a` = 5, sources intact. 59 graph-check runs × interp/native/forced passed.
The next graph48/tool27/rt37 (original reference: `../steps/witnesses/merge-callable-20261109/notes.md`), after Codex's review of 327:
`merge(f1)` copies a callable — its parts as ordinary Lmx, a written word as a new WORD cell holding the same canonical
address (`lmx_graph_word_of`) — and, when the copy holds written names or callables, takes their needed lexical
ancestors along, whole, through the same map up to `parent` = 0; the result's `parent` is the copy of the model's
parent. The copy is a new Lmx without `native`: the interpreter runs its call, since reusing the old implementation is
unproven. The place `g: merge(f1)` is defined by its value; the call `g(1)` in the root's native code is resolved, bound
and dispatched by the kernel at run time (the path `g \ field` is a read, not a call). With `int: k 2` and `k: 5` after
the merge: `f1(1)` = 15 (the live `k`), `g(1)` = 12 and `g(2)` = 22 (the copied `k` = 2), and the own `calls` stay
apart (`f1\var\calls` = 1, `g\var\calls` = 2). Open: the old name inside the copy — the slot `f1` of the copied root
holds the copy itself, named by its new place `g`, so a recursive `f1(...)` in the copy's body finds no name (3); a call
of a defined place from a method's native body. 60 graph-check runs × interp/native/forced passed.
The next graph49/tool28/rt38 (original reference: `../steps/witnesses/callable-reference-20261109/notes.md`), after Codex's review of 328:
the result of a one-operand `merge` is the copy of its root and keeps its name (§5.1), so the slot `f1` of a copied
ancestor answers `f1` at the copy and the copy's recursion stays in the copy: `g(3)` = 6 with `g\var\calls` = 4 and
`f1\var\calls` = 0. A new place for a named Structure or callable is a new named reference to the same instance (the
`LMX_TYPE_GRAPH_LMX_REF` region, `lmx_graph_ref_lmx`; `lmx_graph_target` takes the target): `g: merge(f1)` and `h: f1`
give `@: g f1` and `@: h f1`, the target's name does not change (`h(2)` = 21, the statement `h(5)`, `f1(3)` = 33, one
shared `calls` = 3), and `P\a := 7` through `P: M` changes `M\a`. A call head in an expression and in a statement, a
path, a field write, `call:`, a `merge` operand and a whole argument structure take the reference's target in both
consumers; the copy of a reference points at the copy of its target through the same map. Native: the call of a head
the translation cannot resolve is the common run-time resolve/bind/invoke in a root and in a method body alike, and a
statement on a place defined at run time is decided then (a call or a write), as by the interpreter: the body of
`twice` with the statement `g(a)` and `return: g(a) + 1` gives 13 with `g\var\calls` = 2. The clean graph has no
collector; the name of a composition of several roots and the `fn`/`return` parts (a question to the author), the `@`
address of a Structure reference and replacing a Structure or reference slot (5) are open. 63 graph-check runs ×
interp/native/forced passed.
The next graph50/tool28/rt38 (original reference: `../steps/witnesses/runtime-statement-20261109/notes.md`), after Codex's review of 329:
behind the call reading of a statement on a place defined at run time, the write reading takes only one value field
without a named actual (`lm_graph_emit_write_form`); another form — several actuals, named ones, none — is no write and
refuses when a place that is no callable is chosen, then (as the interpreter: answer 2 or 5), instead of stopping the
translation of a correct call. Reproduced on graph49 (`graph: emit answered 2`) and fixed: `f(a; b)` with
`calls`/`last`, `g: merge(f)`, `g(1; 2)` in the root, `g(3; 4)` in a native method body and `g(b := 7; a := 6)` give
the copy `calls` = 3, `last` = 67 and `f` 0 and 0; `x: 4`, `x(1; 2)` give answer 2; in native/forced R0 stops
(success 0) and `y` is not computed. 65 graph-check runs × interp/native/forced passed.
The next graph52/tool29/rt40 (original reference: `../steps/witnesses/clean-production-20261109/notes.md`), after Codex's review of 330 — the
first production input of the clean path, the machine module `src/l2src/lmx_schedule.lm2` (whose L1 F now writes in
build-runtime). With the existing command `G run`, graph50 stopped at construction (`graph: build answered 2`): the
builder did not take the reference formal `@: s T`. Now a formal `@: name T` is built as the Frame `[@, name, T]`,
named by field 1 (book :436), and printed; the C-door declarations `include:`/`predef:` are state words (`w_include`,
`w_predef`), their statements stay in the root and stand (the root runs nothing for them; the machine output will read
them). The graph of `lmx_schedule` is built whole and prints the same before and after its root runs; so do `l2_libc`,
`lmx_clock`, `os_native_path` and `tools/text`. The machine export from the clean graph (F's input instead of P0) is the
next step; the interpreter has no C door yet. 66 graph-check runs × interp/native/forced passed.

The author's decision of 2026-11-10 (journal (original reference: `../LMX_blog/2026-11-10.md#forms-declare-or-call`),
book (original reference: `LMX_semantics.en.md#forms-declare-or-call`)): structural forms only declare or call, and `:=` writes a value into
a known place. The following retains the historical description of
slice 346 (original reference: `../steps/witnesses/colon-declares-clean-graph-20261110/notes.md`): the definition of a place by its value
(`lmx_graph_define`) and the write by the form `name: value` are removed from both consumers; the descriptions of the
slices above state what the code did before it. A root form `Name: tail` whose head is no word of the language, no
receiver and no callable is a declaration of a Structure (`lmx_graph_root_declares`), executed where the traversal
reaches it (`lmx_graph_space_reach` → `lmx_graph_root_declare`): an atom of the tail that names a Structure, a callable
or a place now is that entity itself -- its address goes into the slot with no copy --, an unknown atom stays a word;
nested forms and kept statements stand as written. A repeated declaration gives the place of the name -- the slot of
the root holding the former Structure -- the newly declared one, and the slot of the form itself stays empty: there is
no second field, and the dump prints nothing for an empty slot. `Name: merge(...)` declares the Structure the receiver
builds: the name receives the result; a copy of one operand is named already and is held by `@: name merge(...)`. A
head that is a known place that is no Structure (an `int` place, a reference place) -- at the root, in a body and on a
path `owner\field:` -- is refused: answer 8 of the interpreter, a stop of R0 in a program (since slice 356 a reference place to an ordinary Structure at the root and in a body launches it -- below; on a path `owner\field:` and for a place that refers to neither a callable nor a Structure the refusal stays); the translator names `:=` in
its message and emits the refusal at the statement. A declaration of a Structure inside a running body and a repeated
declaration through a path are not executed by the slice (5). The fields of a written operand of `merge` are declared
by receivers -- `int: name value`, `@: name int value`; a field `name: tail` there is a description of a structure (5).
The author's example `Struct2: a b c`, `Struct1: q w e r t`, `Struct1: Struct2` gives the dump `Struct2: a b c` and
`Struct1: (Struct2 a b c)`. 99 graph-check runs × interp/native/forced PASS. The L3 lowering, the L2 machine path and
the walker still accept the colon assignment -- section M7 of the plan (original reference: `../next_core_tasks_v3.md#m7`). The author's
decisions of 2026-11-11 changed the norm of what this slice executes -- the binding of an atom of the tail at the
declaration, the replacement of the content on a repetition, the name that receives the result of `merge`, the
printing of the referent in the dump, the declaration of a Structure among executed forms itself and a form whose head
is an ordinary Structure, or a place holding a reference to it, in code, which now launches the Structure by name; what
holds by them and what the clean graph still does otherwise is told below, in the paragraphs on the roles `data` and
`code`, on the author's answers and on launching a Structure by name.

The census of such writes in the working frontend is slice 347 (original reference: `../steps/witnesses/colon-census-20261110/notes.md`),
step 1 of section M7. The translator itself names every structural Frame -- with the colon, compact or a block:
anything but the operator `:=` -- that it lowers as a write of a place: `lm_compiler_colon_write`
(`l2_frontend_types.lm2`) is called in the write branches of the lowering (`lm_compiler_emit_stmts_with_position`,
`lm_compiler_emit_loc_stmt`) and of the walker's lowering (`lm_compiler_rw_stmt_content`). When the environment names
a file in `L2_COLON_WRITES`, the function appends a row to it: the route of the translation (1 a machine method, 2 the
L3 lowering, 3 the walker), the kind of the left side (1 a bare name, 2 a field path, 3 an index, 4 a dereference,
5 a member path of C storage; 6–9 the forms that themselves make a place: a name by its value, a reference `h: Box`,
a callable's result `r: h(3)`, a place under a Structure in the head `Model: m`), the file, the line, column and
offset of the head, its length, the flags of the Frame and the text of the head. A head that is a word of the language
or the receiver `@` gives no row: the receiver makes that declaration. Without the variable the function does nothing,
and the L1 written does not depend on it. Two commands of the tool (`tools/migrate.lm2`) read the report:
`colon-report CENSUS STAGE SOURCES` counts the sites -- one colon of one file, whatever number of translations and
routes named it -- by route and kind and checks every row against the source text (the head at its offset, the colon
and a space after it); `colon-migrate` replaces the colon of every checked site of kinds 1–5 by ` :=`, prints the
sites of kinds 6–9 and leaves them as written, and does not touch a row the text did not confirm. The command finds
nothing by the text. The report over a build of the frontend, the kernel, the tool, the graph translator and over
the full list of fixtures: 53,998 rows, 193 files, 34,843 sites. The machine path -- 33,639 sites (a name 20,216, an
index 8,925, a dereference 1,188, a member path of C storage 3,310), every one confirmed by the text. The L3 lowering
-- 1,309 write sites (a name 937, a path 215, an index 140, a dereference 15, C storage 2) and 18 sites whose form
itself makes the place; the walker named 1,276 write sites (a name 906, a path 215, an index 140, a dereference 15)
and 18 such forms. The text did not confirm 76 sites (762 rows): 61 are the receiver form `@: place value`, which the
frontend brings to a write through a path, 15 are block and compact forms of a Structure at a known place (`T:` with
a body, `Outer\Model()`); the command does not migrate them. The report does not see three kinds of writes: the
kernel modules translated from the clean graph (`lmx_schedule`, `lmx_clock`, `lmx_process_deadline`), the `default:`
branches of `os` blocks (they are not lowered on Windows) and the sources only a generation build translates
(`l2_frontend_graph.lm2`, `tools/l2trans.lm2`, `tools/lmxchild.lm2`).

The same slice fixed a declaration read at a site that is not its own. The pass that, before the calls are bound,
lifts a `merge` written as an argument of a call into a hidden declaration (`lm_compiler_merge_lift_walk`) asks every
statement whether it declares, and the reading of a declaration asks the places of the current method and keeps its
answer for the node (`lm_compiler_declaration`; a repeated `@` receiver takes the requirement of the earlier
declaration of its name). From the second registration round on the current method stayed the one the collection had
ended with -- the last method of the unit -- and `@: p int @ x` of any other method was read as a repeat of the place
`p` of that method with two values: "a declaration takes one value". The refusal showed when the pointer of the same
name in the last method stood nearer to the start of its file than the declaration to the start of its own, that is
through a program part; that is how it was found -- by adding a part to the tool. The pass now reads every method as
its own (`lm_compiler_merge_lift_methods`) and gives the caller its former reading site back; the fixture is
`tests/dyn/declaration_site.lm2` with the part `declaration_site_part.lm2`. `bootstrap quick` -- 0 failures, the
generations are the same; the full list -- `SUITE 140 rows, 0 failures`, 1108 PASS; 99 graph-check runs ×
interp/native/forced PASS.

Slice 348 (original reference: `../steps/witnesses/colon-migrate-machine-20261111/notes.md`) closed the three gaps of the census and
migrated the machine sources -- the translator, the kernel, the tool and the graph translator -- to `:=`. The machine
path from the clean graph (`lm_compiler_graph_block`, `l2_frontend_graph.lm2`) emits the operator `left := value` --
the builder's unnamed Lmx [`:=`, left side, operand] -- as the very write it emits for the form `name: value` and
`owner\field: value`: `lmx_schedule` and `lmx_process_deadline`, migrated to `:=`, give byte for byte the former L1
from their graph. The clean graph has no positions in the source text, so the rows of the census for these modules
come from a translation by the same frontend without the word `--graph`. The target the branches of `os` blocks are
selected for is named by the environment variable `L2_OS_TARGET` -- `win` or `default`; without it the target is the
translator's own (`lm_compiler_os_target`). A translation for another target writes the L1 of that target; that is
how the `default:` branches are lowered on Windows and name their writes. The sources only a generation build
translates are named by a `bootstrap` run with `L2_COLON_WRITES`. The receiver form `@: place value`, brought by
the frontend to a write through a path, gives no row any more; a Structure written with its fields at the place of
its head is kind 10 of its own. The commands of the report tell a write with a colon and a space from a write of
another form -- compact or a block -- and print the second (`COLON-FORM`) without touching it. The whole census of
`src` and `tools` -- 76,776 rows, 34,117 sites in 101 files: the machine path 34,058 (a name 20,547, an index 8,986,
a dereference 1,188, a member of C storage 3,337), the root programs of the tool in the L3 lowering -- a name 64, an
index 19, and four forms `MainLetter: m`, which the command does not touch
(P1 (original reference: `../LMX_blog/q/colon-declares-answered-20261111.md`)). Every row is confirmed by the text, there is
no write of another form; by the text no statement with a colon whose head is a name, a path or a dereference is
left outside the census. `colon-migrate` rewrote 34,113 sites; every changed line differs from the former one by one
colon that became `:=`. The migration changed no generated file: all 172 L1 files of a generation -- the texts and
headers of the frontend, the kernel and the tool -- are byte for byte the files of the generation before the
migration; the frontend, `l1trans`, the tool and the graph translator are the same images (`EXE-SAME 1`), `driver.o`
is the same. What a build on Windows does not translate is compared apart: the L1 of the target `default` and the L1
of the graph-route modules read without `--graph` are the same before and after the migration. A repeated census of
the migrated sources names no write -- the four forms `MainLetter: m` are left in it. `bootstrap quick` -- 0
failures, the generations are the same; the full list -- `SUITE 140 rows, 0 failures`, 1108 PASS. The fixtures of
`tests` outside `tests/graph` were not migrated by this slice.

Slice 349 (original reference: `../steps/witnesses/colon-migrate-fixtures-20261111/notes.md`) migrated to `:=` the fixtures of
`selfbuild/tests` outside `tests/graph` -- the texts the L3 path lowers: the native lowering and the walker. The
census is refined. The put of a Structure that the receiver form `@: place (fields)` wrote gives no row: the origin
of the form has a node bit of its own (`lm_compiler_receiver_form_node`), and the role of a write through a path
stays on the first act of the written form only. A Frame with no field in its body that a write branch lowers as an
empty Structure at a known place (`Outer\Empty: ()`, `Outer\Model()`) is kind 10, a declaration. The rows come from
the full list, the small list of a generation build, the list `smoke-kernel225` and a translation of the fixtures
with `default:` branches for the target `default`: 13,187 rows, 1,221 sites in 103 files -- 1,160 write sites (the
native lowering: a name 887, a path 211, an index 45, a dereference 15, a member of C storage 2) and 61 forms that
declare: 54 Structures written at their own place, four places under a Structure in the head, two references and
one name defined by a value. A write of a known place here is also a write of a reference to a Structure,
`T: Swapped`, `Box\kid: Other`: the former reading assigned, the fixtures expect an assignment, and by the norm of
2026-11-10 it was written `T := Swapped`. `colon-migrate` rewrote 1,160 sites. Three forms that made a place
themselves were rewritten by hand into the forms of the same norm -- `var := D\var`, `@: b Inner2`,
`@: Other Answers`; 15 more writes stand behind the point of refusal in the fixtures of `refuses` rows, the
translation never reaches them, and they were migrated by reading the text. The operator `:=` knows the reserved
`var` -- the reference to the data of the current call -- as a known place: the collection already made it an input
of the activation, only the check of the left side refused it (`lm_compiler_check_body`). The author's decision of
2026-11-11 changed the norm of these writes: the names of Structures are not assigned -- `T := Swapped` is an error,
and pointer variables declared by `@: ptr T` are assigned --, and the special name `var` is called `data`
(book (original reference: `LMX_semantics.en.md#data-code-roles`)) (implementation of the former norm, before 2026-11-19; the special name
`data` is removed -- `removed-builtins` (original reference: `LMX_semantics.en.md#removed-builtins`); replacement --
section of this document (original reference: `#binding-callables-20261119`)); their migration is steps 3 and 8 of
section M11 of the plan (original reference: `../next_core_tasks_v3.md#m11`).

The checks of slice 349: the full list -- `SUITE 140 rows, 0 failures`, 1108 PASS. Of the 220 programs of the list
212 have byte for byte the former L1; two (`whole_arguments`) differ only in the name of a lifted `merge`, which
carries an offset in the source text; six -- the fixtures of the three forms rewritten by hand -- number their
places differently with the same results. The L1 of the 60 programs of the target `default` and of the 16 programs
of the list `smoke-kernel225` is the former one. A repeated census names no write: it holds 58 declarations.
`bootstrap quick` -- 0 failures, the generations are the same; `l1trans`, the tool, the graph translator and
`driver.o` are those of slice 348. Not migrated: `tests/native_closure_values.lm2` -- no command of the tool
translates it. The declarations keep the colon: written Structures and the records `Name: (fields)`
(P2 (original reference: `../LMX_blog/q/colon-declares-answered-20261111.md`)), a place under a Structure in the head
(P1), declarations through `merge` (P4), the composed form (M9 (original reference: `../next_core_tasks_v3.md#m9`)) and the second heads
in three refusal fixtures, which step 4 will revisit. In this slice the L3 lowering, the machine path and the walker
still accepted a write with a colon.

Slice 350 (original reference: `../steps/witnesses/colon-refusal-20261111/notes.md`) introduced the refusal in the working frontend: a
structural form declares or calls and writes no known place
(book (original reference: `LMX_semantics.en.md#forms-declare-or-call`)). The refusal stands where the write is: every branch that
would emit a write of a place for a structural Frame first asks the function of the census
(`lm_compiler_colon_write`, `l2_frontend_types.lm2`), and the census showed that every write of the native L3
lowering, of the walker and of the machine path passes through it. A form of the kinds 1-6 -- its head is a known
place: a name, a path through fields, an element, a dereferenced cell, a member of C storage -- is refused, and the
message names `:=`: "a form with a colon declares and writes no known place: assign with :=". The forms of the kinds
7 and 8, which defined a place by its value (`h: Box`, `r: h(3)`), are refused with a message of their own: a form
with an unknown head declares a Structure with its tail inside, a reference is declared `@: name value`. The kinds 9
and 10 -- declarations -- pass. The row of the census is written before the refusal, so a census names the form that
stopped the translation. The machine path from the clean graph (`lm_compiler_graph_block`) refuses in its two
branches that emitted a write for the forms `name: value` and `owner\field: value`; the write there is the operator
`:=` alone.

Limits: the L3 lowering builds a repeated declaration of a Structure only from a written body; a Structure with
an atom that names another entity -- `Struct1: Struct2` with a known `Struct1`, `h: Box` with an unknown `h` -- it
does not build and refuses such a form instead of assigning a reference as before. The clean graph executes such a declaration. The
refusal does not tell a Structure place from a value place: its message is true of both.

The checks of slice 350: nine refusal fixtures (`colon_known_*_refused`, `colon_absent_reference_refused`) -- a
literal, a name and the result of a call as the tail, a path, the root, an element, a dereference, a statement of a
named Structure's body, a reference by a value -- are refused natively and under the walker. The mutant -- the
refusal removed -- translates all nine. The machine path is checked on the kernel module `lmx_ids` with one write
turned back into a colon form: refused; the same module unchanged gives the L1 of the build. The machine path from
the graph -- on `lmx_schedule` and `lmx_process_deadline` with one such write each: refused. Two fixtures that pinned
the former rule (`occurrence_bare_refused`, `occurrence_node_refused`: a second root head written `y: 7`) write the
second head as a repeat of the declaration; their subject and message are the former ones. `bootstrap quick` -- 0
failures, the generations are the same: the sources of the translator, the kernel and the tool hold no write with a
colon. The full list -- `SUITE 149 rows, 0 failures`, 1162 PASS; the L1 of all 220 programs of the list is byte for
byte that of the previous slice; `l1trans`, the tool, the graph translator and `driver.o` are the former ones.

The author's decision of the same day (journal (original reference: `../LMX_blog/2026-11-10.md#receiver-args-only`),
book (original reference: `LMX_semantics.en.md#receiver-args-only`)): a place is declared only by the form `receiver: arguments`, and the
composed form `name: receiver: value` is withdrawn. The examples of slices 304 and 307 above are written in the former
form (`(a: int: 5)`); under the norm the same field is written `(int: a 5)`, and since slice 351 the fixtures write it
so.

Slice 351 (original reference: `../steps/witnesses/composed-form-20261111/notes.md`) removed the composed reading from the working
frontend (steps 1-3 of section M9 of the plan (original reference: `../next_core_tasks_v3.md#m9`); in the clean graph step 3 was done by
slice 346). Two places of `l2_frontend_resolve.lm2` read the composed form: the reader of a declaration
(`lm_compiler_declaration`) -- the outer head as the place, the receiver of the tail as an asserted requirement --
and the role of the content (`lm_compiler_decl_content`, role 4: "the tail is consumed by a receiver"), under which
the Frame was no definition of a Structure. Both readings stay with the operator `:=` (`place := int: 5` writes a
value its receiver checks) and with the receiver form brought to a write through its path (`@: Box\k Model: Other`,
node bit 8192); a form with a colon has neither. The common rule of the head applies from there. A head that names
nothing declares a named Structure with the tail inside: `holder: int: time` is a Structure with the field `time` at
the root, in the body of a Structure and in the body of a method, whatever `time` names outside it; before, a name
known outside turned the same line into a place with a value. A known place is refused with the message of slice
350. The field of a `merge` operand written name first (`(a: int: 5)`, label `MERGE-OPERAND-FORMS`) is withdrawn
together with the function `lm_compiler_named_typed_field_kind`: such an operand is refused as an operand form that
is not lowered.

So that `i: int: 6` with a known `i` is refused by the rule of the form and not by the words "int has no value"
about its tail, the check of a received value (`lm_compiler_check_receiving_value_at`, `l2_frontend_emit.lm2`) reads
a single application of a receiver of a primitive as an expression: its operand is received by the receiver's type,
and the place receives that type -- as it already read the initial value of a reference under an asserted
requirement. With that a write by index and through a reference takes such a value too (`a[1] := int: 6`,
`\p := int: 6`); before, it passed in a write by name -- through the composed reading -- and by path.

The limit: a Structure with a receiver call inside -- `i: int: 5`, `ptr: @: 0` under a head that names nothing --
is not built by the L3 lowering. An item of a body that is the application of a receiver of a value or of a type
(`int`, `char`, `size_t`, `unsigned`, `ulong`, `@`) to what is no name of a place is refused in
`lm_compiler_take_ns_body` where the application stands: "a receiver applied to a value declares no place, and a
Structure declared with it inside is not lowered yet…", and the message names the form that declares a place. The
reserved `var` with its data written as fields (`var: (int: n 3)`) does not fall under this rule. The clean graph
executes such a declaration.

The checks of slice 351: nine new rows of the list -- `composed_declares_structure` and `typed_value_write` give 7
natively and under the walker, with both executors of the root; seven refusal fixtures (`composed_value_refused`,
`composed_value_method_refused`, `composed_field_refused`, `composed_reference_refused`, `composed_known_refused`,
`composed_known_root_refused`, `merge_named_field_refused`) are refused with the named message at the named place.
A mutant -- the former reading restored in both readers -- fails `composed_declares_structure` ("unknown field path
segment" at `box\time`), makes the three forms under an unknown head a place again and translates the two on a known
place as a write (exits 6 and 8). The full list -- `SUITE 158 rows, 0 failures`, 1216 PASS. The first run gave 6
failures in three fixtures: the refusal of a receiver's application was wider than the norm and caught the data of
`var` written as fields; the condition was narrowed to the receivers that declare a field, and the tuple was built
again. Of the 220 programs of the previous slice 210 keep their L1 byte for byte; two (`whole_arguments`) differ
only by the name of the lifted `merge`, which embeds an offset in the source; two (`explicit_data_var_field`) by one
line of the name table: the word of the head `cell` became the word `int`; six (`free_c_abi`, `free_c_pointer`,
`free_value_consumers`) have a table of pointer types shorter by one or two unused entries, the codes of the types
after them shifted. The cause of the last: the question "a type word?" (`lm_compiler_prim_type_word`) interns a
pointer type for a word of the `c.` door as a side effect; it used to be asked of the head of the one Frame in the
tail of any form (`return: c.f(x)`), now only in the tail of the operator `:=` and of the receiver form. `bootstrap quick` -- 0
failures, the generations are the same; `l1trans`, `driver.o` and the graph translator are the former ones, the tool
is another (the export list of the frontend is one name shorter).

Slice 352 (original reference: `../steps/witnesses/receiver-check-20261111/notes.md`) did step 4 of
section M9 of the plan (original reference: `../next_core_tasks_v3.md#m9`) in the working frontend -- the one-argument forms of the
receivers of primitives (`int`, `char`, `size_t`, `unsigned`, `ulong`). The form with a name (`int: i`) and its
repetition were executed before. Two lowerings by the shape of a form were added, both in `l2_frontend_core.lm2`.

The check as a statement (`lm_compiler_receiver_check_lower`). A receiver of a primitive applied to a value and
standing as a statement in the body of a method or at the root -- `int: 5`, `int: bump()`, `int: (2 + 3)` -- checks
the value: it is evaluated once, received by the receiver's type and not kept. The statement becomes the declaration
of a place with a name from the translator's space (`l2_check_<part>_<offset>` -- one per place of the program's
text), which receives the value as every declared place does; the check, the lowering and the walker read it as a
declaration. The rewriting stands in two passes over statements -- the collection of places
(`lm_compiler_collect_asgn_body`) and the collection of the rows of declarations (`lm_compiler_collect_decls`) -- and
does not fire twice: a rewritten statement is already a declaration.

A literal outside the type (`lm_compiler_receiver_literal_lower`). In a receiving position a literal has no type of
its own: it takes the type of the place, and a literal the place cannot hold is refused by the translation. In the
form `receiver: literal` the place is the receiver itself and the form is the check, so such a literal is given the
type that holds it -- `int`, else `size_t` -- by the same form: `int: 4294967296U` reads as
`int: size_t: 4294967296U`. The outer receiver receives a number of another type, and that is the run-time `convert`
that `catch: convert ()` accepts -- as with a value of another type from a variable. The rewriting is done by the
walk of the forms that say what they are by their shape (`lm_compiler_place_write_walk`), before anything is read for
its meaning; the decision "does the literal fit" is moved from `lm_compiler_check_literal_kind` into
`lm_compiler_literal_kind_fits`, one for both.

The limits: a literal that no number type of the translation holds (`int: 342348523485629384569384`) is refused by
the translation -- it has no value to receive at run time; a declaration with a literal outside the range
(`int: x 4294967296U`) is refused by the translation as before; in the body of a named Structure the form with a
value is no statement but a value inside the Structure, and is refused by the limit of slice 351.

The checks of slice 352: four new rows of the list -- `receiver_check_statement` and `receiver_literal_range` give 7
natively and under the walker, with both executors of the root; `receiver_literal_unrepresentable_refused` and
`receiver_check_structure_refused` are refused with the named message at the named place. A mutant -- both
rewritings switched off -- translates neither `receiver_check_statement` ("unsupported body" at `int: 5`) nor
`receiver_literal_range` ("literal not representable as int"), and refuses the third fixture with another message.
The full list -- `SUITE 162 rows, 0 failures`, 1240 PASS; all 224 programs of the previous slice keep their L1 byte
for byte. `bootstrap quick` -- 0 failures, the generations are the same; `l1trans`, `driver.o` and the graph
translator are the former ones, the tool is another (the export list of the frontend is one name longer).

A repeated declaration by a receiver in code has no mechanism of its own: it is an out-of-turn type check with an
assignment, and no second field arises; in data a repeated declaration is one more occurrence of the name: it
neither replaces the former one nor writes into it, and after it the name is addressed only with the index of an
occurrence (the author's clarification of 2026-11-11,
journal (original reference: `../LMX_blog/2026-11-11.md#repeat-is-check-and-assignment`), and his decision on the roles of the same day;
the book -- structural forms (original reference: `LMX_semantics.en.md#forms-declare-or-call`),
names and paths (original reference: `LMX_semantics.en.md#fields`)). Both translators were measured against this clarification in the
same witness; the divergences of the implementation found there were written down as step 5 of
section M9 of the plan (original reference: `../next_core_tasks_v3.md#m9`) and moved into steps 5 and 8 of
section M11 (original reference: `../next_core_tasks_v3.md#m11`): with a repetition in the explicit `var` of a method the working
frontend silently reads the first occurrence; the clean graph did not write the place on a repetition at the root, and
until slice 355 it selected the first occurrence by a bare path and did not build the path with the index of an
occurrence (the last two were removed by slice 355, sub-step 5а). The root of a unit is launched as a Structure over itself, and an access without an index to a variable declared twice in it
is refused (the executor's reading -- answers (original reference: `../LMX_blog/q/fable-self-answers-20261110.md`), Р6 and Р11)
(implementation of the former norm, before 2026-11-19; current norm -- `root-entry` (original reference: `LMX_semantics.en.md#root-entry`):
R0 has no data, it is a procedural entry without arguments, and the role of the records of the root is an open question
at the author; replacement -- section of this document (original reference: `#binding-callables-20261119`)).

(Implementation of the former norm, before 2026-11-19: the paragraphs below, up to §1 (original reference: `#principles`), describe slices
353–372 by the former norm of launching -- six forms of `call`/`fncall`, `S(D)` as `call(D, S)`, the part `data` as a
separate parameter, the special name `data`, a launch "over itself", the ban "a launch has no result"; current norm --
`structural-call` (original reference: `LMX_semantics.en.md#structural-call`), `removed-builtins` (original reference: `LMX_semantics.en.md#removed-builtins`),
`root-entry` (original reference: `LMX_semantics.en.md#root-entry`), `return-in-data` (original reference: `LMX_semantics.en.md#return-in-data`); replacement --
section of this document (original reference: `#binding-callables-20261119`).)

Slice 353 (original reference: `../steps/witnesses/call-receivers-20261111/notes.md`) executed in the clean graph the author's decision
of 2026-11-11 on launching code over data (journal (original reference: `../LMX_blog/2026-11-11.md#call-receivers`); the book --
the receivers `call` and `fncall` (original reference: `LMX_semantics.en.md#call-receivers`); steps 1-5 of
section M10 of the plan (original reference: `../next_core_tasks_v3.md#m10`)). The working frontend does not read the new forms and
reads the one-argument `call` as before; a name used above the line of its declaration it still rejects by the
former rule of the book.

The current launch receives actuals separately from the input description data. Explicit receivers and
ordinary calls converge on one frame and execution worker; args is not read as formal declarations.
Migration of the former LmxGraphFrame/work_open_parts belongs to M10 with M14 (original reference: `../next_core_tasks_v3.md#m10`).
The historical place-model changes367 are in their receipt (original reference: `../steps/witnesses/m11-ordinary-model-20261113/notes.md`).
Slice 368 replaces the call of own data with a pass over its implemented root declaration
receivers in the same frame (`lmx_graph_data_run`). Other fields, including assignments,
test, data, if and nested Structures, remain data. After a computed initializer, the work
row binds the published cell again so the next initializer reads it.
An ordinary data()/data(D) record now uses the common resolve/launch/binder in runtime and native emission.
The constructor prepares written fn/sub in both its data and code; the common binding_value
reader returns the existing method after checking its source parent, without changing the source graph field.
A unique written data method is checked by name and path. At slice 368, indexed repeated methods,
reference places and computed fn/sub in data, root/self and M14 remained open;
checks and limits (original reference: `../steps/witnesses/m11-data-roles-20261113/notes.md`).
Slice 369 adds working values for the supported int/Structure references, a common known_place
preflight and reference writer; known_int remains numeric. A code @ writes a data place,
and its implicit own gets a real uninit:T with stable slot/wrapper/typed-cell identities.
The working snapshot is separate from the published cell: dirty values publish at standard points,
while a clean outer snapshot survives a nested call. The model's expected primitive kind is stored
once in the map row's expected_kind; another data cannot change that type through the RHS.
Native emits one RHS path for a fixed own model kind, retaining the same preflight and guard;
other places stay dynamic. Normal header generation supplies graph68/run52 and Work's contract field.
Full bootstrap quick built genuine G1/G2, nine smoke rows each; thirteen checks and 614 inputs passed. Genuine G2/graph repeated nine cases in three modes, the full mutation command and six AFTER comparisons;
checks and remaining work (original reference: `../steps/witnesses/m11-reference-work-20261113/notes.md`).
Slice 370 admits computed fn/sub at the root of the current frame's own data through the same binder/make.
The existing Space.rows select the constructed method by owner and the source declaration's parent;
its computed name works in paths, and another launch in the same traversal retains its data.
When a local declaration's name is still unknown, the existing frame's temporary binding_open
distinguishes unfinished binding from a missing free input. Known external values are held at entry;
a new local immediately overrides the entry fallback, including in the next initializer.
After ordered data, a still missing input refuses before the body, without rereading an external source.
A closed scope retains its refusal before data initializers. Native selects the callee in the live frame
and checks its result before actuals, rather than treating a lexical fallback as the final target.
A possible entry snapshot of an ambiguous argument lives in an existing frame row, but becomes
an input for child calls only when its owner actually consumes it. Shape queries do not consume it.
The reading selected by the live contract is carried in the temporary call map's tail and used alike
by native code and the walker. An empty or partial whole Structure retains the common binder/defaults;
P0 groups stay intact. Source08:624 inputs,19 cases in three modes, AFTER12 and mutation passed;
the full bootstrap03 quick G1/G2,9 smoke rows each, fixedpoint13 and the actual G2/graph rerun passed.
The normal semantics rendering and docs check passed:35/14/27/44/615, LF27224; diff --check is clean.
Computed declarations in code/inline blocks,
root/self and the whole M11 remain open;
checks and limits (original reference: `../steps/witnesses/m11-computed-data-20261113/notes.md`).
Slice371 extends lookup of a constructed fn/sub to fn_result(), retaining owner/name/parent:
a function description without a body remains available by name; method() is required at invocation.
This retains the absence of code without creating an artificial empty body. The remaining fixtures'
preparatory merge holders and references moved into own data; final readouts retain the complete
result dump. Source02:626 inputs;15 cases in three modes, AFTER6/mutation, the full bootstrap01
G1/G2, fixedpoint13 and the actual G2/graph passed. The normal render/docs check passed:
35/14/27/44/615, LF27241; diff --check is clean;
change and checks (original reference: `../steps/witnesses/m11-own-merge-references-20261113/notes.md`).
The running code reads the formals, the body and
the result from the frame (`lmx_graph_activation_args`, `lmx_graph_method_run`, `lmx_graph_launch_result`), not from
the Structure of the method; an activation without a frame answers by the Structure, as before. The ordinary call
`f(x)` therefore goes the same way as a launch that was given its parts.

The receivers use the six current forms (original reference: `LMX_semantics.en.md#call-receivers`).
args supplies values; data describes inputs, return describes the result, and code is the body.
Abbreviations supply no actuals and use code as data, not a callable's child data.
Ordinary and explicit calls must share binding/admission/frame/result; M10/M14 replace the
separate callable-without-args route and the former int-only result handling.
The old launch implementation does not establish acceptance of the new model.
The checks353 (original reference: `../steps/witnesses/call-receivers-20261111/notes.md`) remain historical evidence.

Slice354 (original reference: `../steps/witnesses/data-code-names-order-20261111/notes.md`) changed names to data/code
and the two-argument call order to data before code. Those decisions remain.
A current callable contains unified data, return when a result exists, and code;
launch receivers use args for actual values. Historical field names in internal
C/L2 procedures do not define an additional language contract.

The checks of slice 354: in 60 tracked files of `tests/graph` (44 sources and 16 expectations) `var` → `data` and
`body` → `code` (in `merge_arguments` the name `body` is a variable and stayed); 18 two-argument `call` lines in 11
fixtures and the same lines in six expectations are rearranged; the file names `call_var_not_selected`,
`code_data_no_var`, `var_copy_nesting` are the former ones. Four new negative fixtures: `former_var_part` (`f\var\x`,
answer 3), `former_body_part` (`body := …` in a record of `fn`, answer 5), `former_var_block` (a block `var:`,
answer 3), `former_call_order` (`call: Code Data`, answer 3). Graph-check -- `CHECKS 113 lines, 0 failed`, 339 `PASS`
in the three modes; `bootstrap quick` -- 0 failures, G1 and G2 built and tested; the full suite of the working
frontend -- `SUITE 162 rows, 0 failures`, 1240 `PASS`. The mutant "the former word `var` accepted" fails 3 rows of 3,
the mutant "the former order of the arguments" fails 4 of 4; in both lists every row is refused in all three modes. The
working frontend and its fixtures (`tests/dyn`, `tests/os_twins`) read the former `var`, `body` and `call: code data`
-- step 8; the clean graph still declares a Structure when the traversal of the root reaches it -- step 5 --, while the
binding of an atom at the moment the declaration is executed and the replacement of the content on a repetition were
removed by slice 355 (sub-step 5а).

Slice 355 (original reference: `../steps/witnesses/data-registry-atom-20261111/notes.md`) executed in the clean graph the registry of data,
the atom-pointer with no expansion and visibility in data in both directions (sub-step 5а of
section M11 of the plan (original reference: `../next_core_tasks_v3.md#m11`); the author's decisions of 2026-11-11 --
a mention is not expanded (original reference: `../LMX_blog/2026-11-11.md#known-name-not-expanded`),
a repeated declaration (original reference: `../LMX_blog/2026-11-11.md#repeat-is-check-and-assignment`),
the roles `data` and `code` (original reference: `../LMX_blog/2026-11-11.md#data-code-roles`),
the parser tree is not expanded (original reference: `../LMX_blog/2026-11-11.md#parser-tree-not-expanded`); the executor's readings --
Р12–Р15 and Р19 in the answers (original reference: `../LMX_blog/q/fable-self-answers-20261110.md`)). The registry of data is
`lmx_graph_data_find`: the records of a data level that declare a name are read whole at every consultation, with no
table; one record answers, with two or more the name without an index answers nothing (answer 3), and an occurrence is
chosen by the path `s\[N]name`; slice355's string encoding of the step is replaced in slice388 by the structural
representation below. The path step and the atom are `lmx_graph_step`, `lmx_graph_step_place` (the kernel
export, 43 names) and `lmx_graph_atom_target`: the atom of a declaration's tail is not bound when the declaration
is executed and the slot is not rewritten, while the name of the atom is looked up when a path goes through it --
lexically, from the holder outwards, by whole levels; a write through the atom writes the named place; the replacement
of the content on a repeated declaration is removed. The places and Structures of the root answer above and below their
line, and `data` in a root executed over itself is the root. A computed declaration of the data supplied to a launch is
not executed (`lmx_graph_data_realize` is removed, Р12): its place is without a value, and a read before a value answers
5. The print of the graph carries a path: a Structure met on it again is printed by its name.

**Implementation delta in slice388, with no change to occurrence-selection semantics.** The outer path retains three fields,
`[owner, WORD("\\"), step]`. An occurrence step is an ordinary anonymous pair,
`[WORD(decimal digits), WORD(canonical name)]`; an ordinary WORD always denotes a literal name, including `[0]x`.
Common `lmx_graph_occurrence` (Graph74) reads this pair without evaluating its fields, checks `size_t` overflow
before multiplication by 10, and leaves output parameters untouched for an invalid unit.
`lmx_graph_step` and `lmx_graph_step_place` take a raw step; reads, writes, `lmx_graph_admit_path` and native
use that same reader and the existing data registry. No new tag, registry or parser flag is added.
A compact selector is consumed again through existing P0 and the expression builder instead of a separate byte split;
common `lm_p0_scan_head` and the compact-piece reader use existing `lm_p0_scan_quoted`, preserving the boundaries
of an exact root, quoted components and doubled backticks. Global `lm_p0_is_quoted_token_boundary` is unchanged.

The checks of slice 355: 17 new and 6 changed fixtures of `tests/graph` (the list is in the
evidence (original reference: `../steps/witnesses/data-registry-atom-20261111/notes.md`)), 499 entries in `inputs.list`. Graph-check --
`CHECKS 130 lines, 0 failed`, 390 `PASS` in the three modes; `bootstrap quick` -- 0 failures, G1 and G2 built and
tested; the full suite of the working frontend -- `SUITE 162 rows, 0 failures`, 1240 `PASS`. Six mutants are killed in
all three modes. Limits: the answer 5 "a place without a value" is given only by the rows of a launch, while in the root
of a unit that has no frame a read of a name above its computed declaration answers 3 ("the root as a launch with a
frame" is moved to a sub-step after 5г); reading a place with no initial value (`int: z`) still gives 0; a form whose
head is the name of a place of the same level is not counted as an occurrence in a path either (sub-step 5д);
`Name: merge(...)` still declares the holder of the result by a structural form (the translation into `@: R merge(...)`
is sub-step 5в); the dump expands a reference to a Structure whose parent is not the holder (the results of `merge`), and printing such a reference by name is a separate change. The working frontend does not execute these rules -- step 8.

Slice 356 (original reference: `../steps/witnesses/callable-data-launch-by-name-20261111/notes.md`) executed in the clean graph the first
part of sub-step 5б of section M11 of the plan (original reference: `../next_core_tasks_v3.md#m11`): the launch of a Structure by name, one
binder of forms, and the visibility from code of the parts of a callable and of the Structures of the data of a launch
(the author's decisions of 2026-11-11 -- launching by name (original reference: `../LMX_blog/2026-11-11.md#structure-call-by-name`), the
parts of a callable see one another (original reference: `../LMX_blog/2026-11-11.md#callable-parts-visibility`),
the roles `data` and `code` (original reference: `../LMX_blog/2026-11-11.md#data-code-roles`),
`data` before `code` (original reference: `../LMX_blog/2026-11-11.md#data-before-code`); the executor's readings -- Р16 and Р20–Р23 in the
answers (original reference: `../LMX_blog/q/fable-self-answers-20261110.md`)). A form whose head is an ordinary Structure launches it in the
code of a callable and in code over given data (`lmx_graph_launch_head`, `lmx_graph_eval_launch_record`): `S()` over
itself, `S(D)` and `S(data := D)` over `D`; a head that is a place with a reference to an ordinary Structure launches it
everywhere, the root included; a head that is a number place is answer 8; no form (two positional arguments, an argument
of another name), and a launch form in the place of an operand, are 5. One binder (`lmx_graph_receiver_form_of`) chooses
the form of `call`, `fncall` and of the launch form by the written actuals -- by position or by name through `:=` --
before any of them is evaluated; the emitted code binds the form at translation (`lmx_graph_launch_formals` -- an
export; the export list of the interpreter has 45 names). The data/code/return parts of a callable (args supplies actual values, not a callable part)
answer in its code (`lmx_graph_resolve`); the Structures of the data of a launch are found by the registry of the data
of the launch (`lmx_graph_data_find`): a name is searched by the rows of the frame, the formals, the registry of the
data of the launch and the lexical levels (Р20), and a Structure answers by reference, there is one instance.

The checks of slice 356: 21 new and one rewritten fixture of `tests/graph` (the list is in the
evidence (original reference: `../steps/witnesses/callable-data-launch-by-name-20261111/notes.md`)), 536 entries in `inputs.list`.
Graph-check -- `CHECKS 151 lines, 0 failed`, 453 `PASS` in the three modes; `bootstrap quick` -- 0 failures, G1 and G2
built and tested; the full suite of the working frontend -- `SUITE 162 rows, 0 failures`, 1240 `PASS`. Seven mutants are
killed. The limits of that slice (history): until sub-step 5г the root of a unit and a Structure over itself do not execute the code role of a form
whose head is an ordinary Structure by name: `S()` in the root beside the declaration `S` stays one more occurrence of
the name (`struct_root_declares`, answer 3; this is a state of the implementation, not a rule -- Р22); `data()` in code
is skipped, the word `node` is unknown to the clean graph, and a multi-line part `data` in parentheses with a block
closed by `end:` is read with an extra form `end: Name` -- this is the second part of sub-step 5б; P0 expands a single
Structure in parentheses into the tail of the form, as in `Add((int: v 7))` (the debt of section M8); the supply by head
in the parts of `fn` and `sub` is removed by sub-step 5е; the word of the receiver `call` or `fncall` in the place of an operand finds the row of the contract, as `fn` did before (a state of the implementation, Р23); a head that is an empty reference (answer 8 by Р22) is shown by no fixture: `@: p 0` answers 4, `@: p` answers 5 on its own row. The working frontend does not execute these rules -- step 8.

The author's decision of 2026-11-11 on the roles `data` and `code` (journal (original reference: `../LMX_blog/2026-11-11.md#data-code-roles`);
the book -- the roles `data` and `code` (original reference: `LMX_semantics.en.md#data-code-roles`);
section M11 of the plan (original reference: `../next_core_tasks_v3.md#m11`)) is executed by the clean graph so far only in part: the
names and the order (slice 354, step 4 of section M11) -- the parts of a callable are called `data` and `code`, the
two-argument `call` is `call: data code`; sub-step 5а (slice 355) -- data is read as a whole, the registry of data, an
atom-pointer with no expansion, a repeated declaration does not replace the former one, visibility in data in both
directions; the first part of sub-step 5б (slice 356) -- the launch of a Structure by name and the named supply of the
arguments of `call` and `fncall`. The rest is executed by no path of translation yet, and the working frontend reads not
even this. For the clean graph the decision means the following. Data is read as a whole before the code, and the registry of its root forms -- the
declarations of Structures by their heads and the declarations by receivers of places by the declared names -- is
known before the first statement of the code; a traversal of code declares nothing but callables. In code every
form is a call: a declaration by a receiver is a type check with an assignment into a place of the data, a
structural form is a call of its head: of a callable, a method call; of an ordinary Structure, its launch by name
(journal (original reference: `../LMX_blog/2026-11-11.md#structure-call-by-name`)); it is an error when the head names neither a callable nor
a Structure. A repeated declaration in data is
one more occurrence of the name: it neither replaces the former one nor writes into it, and after it the name is
addressed only with the index of an occurrence. The left side of `:=` is a place of a primitive or a pointer
variable: the names of Structures and functions are not assigned. The arguments of calls and receivers are read as
code: `f(arg: v)` calls `arg`, only `:=` gives a named argument, and the formals are declared by receivers
(`int: arg default`, `@: arg Template`). A launch form of a Structure at a place where a value is needed (an operand of
an expression, an actual argument of a call, an initial value, an operand of `merge`) is an error: a launch has no
result (the executor's reading -- answers (original reference: `../LMX_blog/q/fable-self-answers-20261110.md`), Р22, item 3; Р25, item 4).
The name of a form `Name: merge(...)` does not receive the result: in code
it is a call of `Name`, in data a declaration of a Structure with the form of the call of `merge` inside, which is
not executed there; a pointer variable holds the result, `@: name merge(...)` (the executor's reading --
closed questions (original reference: `../LMX_blog/q/colon-declares-answered-20261111.md`), P4). The words of the
state `var` and `body` and the names of the formals in the contracts of the receivers `fn` and `sub` are called
`data` and `code` (the clean graph reads these names since slice 354). The admission `satisfies` is performed by one
pass when the graph is built; calls of the
admission at run time stay only for the cases of the
document (original reference: `../steps/implements-runtime-cases-20261111.md`). slice 372 removes the former
`lmx_graph_space_reach`, `lmx_graph_root_declares` and `lmx_graph_root_declare`: a named-head form
at the root or over self reaches shared resolution and launch. A standalone preserved anonymous Structure
does not execute; its receiving expression selects a code body. This is not the complete M11 migration:
root numeric/reference publication, path-head calls, the remaining forms of 5д–5е and admission migration M11.7 remain open.
The decision makes the choice between a
call, a declaration of a Structure and an assignment by the head and the tail of a form unnecessary -- the role
gives it; removing these branches is step 6 of section M11.

The author's answers of the same day to questions P3, P6 and P7 completed this norm
(a mention is not expanded (original reference: `../LMX_blog/2026-11-11.md#known-name-not-expanded`),
`data` before `code` (original reference: `../LMX_blog/2026-11-11.md#data-before-code`),
a Structure over itself has no rules of its own (original reference: `../LMX_blog/2026-11-11.md#self-launch-no-own-rules`); the book --
declaring by a colon form (original reference: `LMX_semantics.en.md#colon-declares`) and
visibility (original reference: `LMX_semantics.en.md#declaration-visibility`)); the questions are closed
(closed (original reference: `../LMX_blog/q/colon-declares-answered-20261111.md`)). A mention of a known Structure is expanded neither by
the parser nor by the builder: in `Struct1: Struct2` one atom stands under `Struct1` in the tree -- a pointer to
`Struct2`, immutable by name; it begins to refer to it at interpretation and translation, a path through it
continues into its fields, and the `parent` of `Struct2` itself -- its place in the tree -- does not change; the
slot of the atom is rewritten by index (`Struct1[0] := …`), and a mutable reference is declared by a receiver
(`Model: @: ptr knownModel`). The dump prints the tree -- the atom, not the referent (the executor's reading --
answers (original reference: `../LMX_blog/q/fable-self-answers-20261110.md`), Р2). Named Structures and callables retain bidirectional visibility;
variables and const are sequential under M14 of2026-11-15. Cyclic references to named Structures are no error. The data stands before the code in every form: the
two-argument launch is `call: data code`. A Structure launched over itself -- `call(code)` and the root of
a unit -- has no rules of its own: its forms are read in both roles by the general rules, and an uncertainty is an
error; a structural form that execution has reached is an error when its head names neither a callable nor a
Structure; a data block inside an executed Structure is the same kind of form, a call with its own tail in the place of
the argument (the paragraphs below), and so declarations of Structures are written in data, and data and code apart (the
executor's reading -- the same answers, part Р). Here too the clean graph does otherwise now: a form of an ordinary
Structure in the executed root it neither launches by name (the paragraphs below) nor refuses but declares where the
traversal reaches it (§6.1), and the child block `data` of an executed Structure it skips. The rest of the execution is
step 5 of section M11 (the names and the order of `call` are executed by step 4, sub-step 5а by slice 355, the first
part of sub-step 5б by slice 356; sub-step 5в and the remainders of sub-steps 5б, 5г, 5д and 5е remain), in the working frontend step 8.

The author's decision of 2026-11-11 on launching a Structure by name
(journal (original reference: `../LMX_blog/2026-11-11.md#structure-call-by-name`); the executor's reading --
answers (original reference: `../LMX_blog/q/fable-self-answers-20261110.md`), Р21) changed this norm for a form whose head is an ordinary
Structure (before the decision such a form was refused in code, and an ordinary Structure was executed only by the
receiver `call`). In code such a form launches that Structure: `S()` is the same as `call(S, S)` (the Structure over
itself), `S(D)` is the same as `call(D, S)` (the Structure over the given data `D`); so are the short form `S: D` and the
block form. It is a launch form of its own, not a form of a receiver: the receivers `call` and `fncall` remain the general
mechanism (the receivers `call` and `fncall` (original reference: `LMX_semantics.en.md#call-receivers`)): args supplies actual values,
and data describes inputs. The short S(D) form has only its data argument; explicit call also accepts args. The form has one argument and it is
named `data` -- by the same name by which executed code names the data of its launch
(the special name `data` (original reference: `LMX_semantics.en.md#ordinary-var`)); it is supplied by position or by name, `S(D)` and
`S(data := D)` are one form, just as with the receivers, whose arguments are named and are supplied by position or by
name (`call(data := D; code := C)`); another name of the argument and two or more positional arguments are an error; the
argument `data` must give a Structure (a name, a path, a reference place, an unnamed Structure written in parentheses),
anything else is an error. The head is a place with a reference: what the reference points at is called -- a callable or
a Structure; a number place, an empty reference and an unknown name are an error. In data nothing changes: `S()` still
declares an empty Structure `S`, and `S(D)` a Structure `S` with an atom `D`; nothing is called.

In the root of a unit and in a Structure launched over itself every form is read in both roles, so `S()` there is at once
a declaration of one more `S` and a call: if `S` is declared in the same Structure, the name has two occurrences, without
an index it answers nothing, and the call is refused; if `S` is declared outside, the form declares its own empty `S`, and
that one is launched, not the outer one; there is no rule of its own for this, and the receiver `call` launches the same
Structure there. A declaration of a Structure among executed forms is still, as a rule, an error, but for another reason:
in code such a form is a call of the declared Structure with its own tail in the place of the argument, and two or more
fields in the tail are not a defined number of arguments (the argument is one, `data`); one field is the data of the
launch and must give a Structure. Degenerate forms are not refused: an empty tail, a single atom that names a Structure,
a single unnamed Structure in parentheses. Declarations of Structures are still written in data. `data()` in code is a
launch of the data of the current launch over itself. Since slice 356 the clean graph executes the launch of a Structure
by name in the code of a method and in code over given data -- `S()`, `S(D)`, `S(data := D)` -- and a form whose head is
a place holding a reference to an ordinary Structure everywhere, the root of a unit included, as well as the named
supply of the arguments of `call` and `fncall` (the first part of sub-step 5б). slice 372 removes the former skip
of a named head at the root and over self; the private checks and remaining limits of 5г are stated at the start
of this document and in §6.1. The working frontend reads the former names and order and does not execute the launch by name (step 8).

</details>

<!-- receiver-integration-2026-11-22 -->
<a id="receiver-migration-20261122"></a>
## Receiver migration and source status, 22 November 2026

The receiver formerly spelled `implements` is now `satisfies`, with the same
admission semantics. Earlier implementation receipts and old exported symbol
spellings identify historical builds; they are not evidence that the present
kernel rename or the new receiver package has been applied.

The [kernel integration](kernel-implementation.en.md#receiver-kernel-integration),
[public API](patterns/LMX_Fn_Receivers/API.md) and
[normative receiver chapter](LMX_semantics.en.md#functional-receivers) document
the complete generic library. Old int-specific examples are retained as
procedural or legacy material. They are not the current generic implementation
and do not enter the primary comparison count.

Source bodies that call the specified FxKernel provider depend on its actual
implementation. A static BODY/BODY_WITH_BRIDGE label is not a runtime receipt.
The provider must preserve ordinary function types, full requirements, actual
parents, arena lifetime and declared failures. No native field, second working
graph or new List representation is introduced. Structures already serve as
reference sequences.

Both signature-description forms are interchangeable outside the preserved existing relationship
of named signatures and call. The type-token constructor is another entry to the same
signature kind; it is not Haskell `::`, an automatic execution of fn or a reason
to alter ordinary named-argument binding.

Historical algorithms stay preserved; only the notation of the named declaration
in them is updated to `Name :: signature`, so byte-for-byte preservation is
judged after this explicitly stated normalization. The former declaration form
is not kept as a second notation anywhere in the active documents, sources, text
generators, checks or preserved procedural variants.

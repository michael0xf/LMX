# Callable actuals: receiving-contract projection

Status: read-only source audit and proposed implementation, 2026-09-30. This note is not a language specification and does not record a completed repair.

<a id="scope-evidence"></a>
## Scope, accepted norm, and evidence

The narrow problem is selecting the value transmitted by an actual argument after its binding and receiving contract have been resolved. It is separate from the definition-content/head-resolution implementation clarified by the answered [Q58](../LMX_blog/q/q58.md), and it does not change declarations, assignment, callable rebinding, or implicit construction.

Accepted normative sources:

- [Callable expressions](../docs/LMX_semantics.en.md#callables), especially the argument-position paragraph: a declared callable formal receives the callable occurrence reference; a value-returning callable executes when the receiving contract requires its result; a callable without a returned value, including `sub`, is transmitted by reference. Transport is not execution. A bare `return` does not supply a result. A bodyless `fn` remains a transportable interface descriptor, without an invented executable body.
- [Construction and signatures](../docs/LMX_semantics.en.md#construction) and [L2 graph copy and merge](../docs/L2_spec_en.md#copy-merge): signatures are nonexecuting descriptions. Nonprimitive `(A: x)` and `(@: A x)` describe the same reference transmission and admission, not executable construction or copying. Primitive value and primitive-pointer formals are not synonyms.
- [L2 typed addresses](../docs/L2_spec_en.md#lowlevel-address): addressing an actual Structure or a nonprimitive signature input obtains its descriptor; addressing an explicit pointer-value cell adds a reference level. No hidden transport-cell address or automatic removal of pointer depth may be introduced.
- [Dynamic inputs and references](../docs/LMX_semantics.en.md#dynamic): explicit reference bindings keep their reference-value semantics. Their referent being callable does not turn the binding itself into an implicit call. Portable reference operations do not authorize machine address arithmetic in L3.

Equivalent canonical nullary source forms in an argument position must not acquire different semantics merely because one source node is an atom and another is a Frame. In particular, bare `s`, `s()`, `s: ()`, and an explicitly closed vertical nullary form cannot use punctuation to choose reference transmission versus invocation. Explicit execution in statement position is a different receiving role, not a punctuation exception.

Implementation evidence is the inspected [sandbox translator](../dev/l2src_sandbox/l2trans.lm1), Git blob `e19c599184993d79ff6c42e15619b39b08b12d33`. The inspected working file was `build/opus_wt/dev/l2src_sandbox/l2trans.lm1`; an identical frozen source is retained locally under `build/l2_harness/merge_live_20260930_final/src/l2src/l2trans.lm1`. These are source identities, not evidence that callable-actual tests passed. Line numbers below refer to this blob, not to future edits or the stable mirror.

The coordinator's DIAGNOSTIC-14 work reported that, after correcting the root trailer of [unit_value_call_sub_refused](../dev/l2src_sandbox/tests/unit_value_call_sub_refused.lm2), passing a bare `sub` to an `int` formal still produces `a callable without a result has no value`. The expected negative property remains incompatibility with the integer receiving contract, not a general prohibition against transporting a nonreturning callable. This audit independently traced the source route; it did not run that fixture or any build.

<a id="consumer-map"></a>
## Current failure and consumer map

### Checking and value classification

`l2_check_call` (18843) has two separate actual-argument routes:

1. A formal identified by `l2_cf_get` takes a special reference route. Except for the separate callable-merge route, its actual must be exactly one `LM_P0_NODE_ATOM`, found by `l2_find_method`. Signature compatibility is checked and `l2_m_value_used` is marked. Thus a bare unit-level `sub` can be recognized here as a descriptor, but equivalent Frame forms, forwarded callable formals, and general selected paths are not handled by this route.
2. An ordinary receiving formal routes the actual through `l2_check_fields`, including after a static Structure-admission decision. That ordinary value traversal does not carry the receiving contract into callable selection.

`l2_check_primary` (18354; callable branches at 18433-18442) sends both a callable formal name and a unit method name to `l2_check_value_call` (18961). That helper rejects result code `8` before ordinary actual compatibility can be decided. The failure is therefore earlier than the intended integer-versus-reference mismatch.

There is a second, independent shape-sensitive gate: `l2_frame_void_call` (18968), consumed by `l2_check_fields` at 19376-19377, recognizes a no-result call Frame and rejects it as a value. Removing only the first diagnostic would leave equivalent Frame actuals rejected. Conversely, deleting every no-result diagnostic would incorrectly alter genuinely evaluated no-result expressions outside reference-receiving argument positions.

The type consumers also need the same decision:

| Consumer at inspected blob | Current assumption that must not survive a reference projection |
| --- | --- |
| `l2_colon_simple_ty` (7070), `l2_colon_value_ty` (7172) | A callable Frame/name is treated through its result or existing bound machine type, rather than one resolved received value. |
| `l2_native_cf_ty` (8338) | A callable formal contributes its result type. |
| `l2_native_composite_ty` (8366) | Composite expression classification consumes the preceding type decisions. |
| `l2_check_value_convert_core` (8400), `l2_check_value_convert_field` (8439) | Numeric conversion has a callable-formal exception based on the assumption that it supplies a result. |
| `l2_actual_ns` (18720) | A callable Frame contributes its returned namespace model, not the occurrence being transported. |

A selected callable reference must be classified as a reference-valued actual, not as a void result, a fabricated number, or the receiving formal's model. Existing rejection of a reference where a primitive is required must remain effective. Returning callables still need their ordinary result type when the receiving contract selects execution.

### Native emission

`l2_emit_call` (21357) repeats the split: its callable-formal actual branch at 21430-21436 uses a unit method occurrence for an atom, while ordinary actuals use conversion plus `l2_emit_fields` (21784). `l2_prep` (21101; callable branches at 21155 and 21185) invokes callable formals or unit methods nullarily. Merely allowing the checker to pass would therefore still generate execution rather than descriptor transmission.

Existing physical-value emitters should be reused:

- `l2_tok_method_occ` (21642) and `l2_occ_expr` (21648) obtain an existing unit callable occurrence.
- `l2_tok_formal` obtains a forwarded formal value.
- Existing resolved path emission obtains a selected occurrence or field value; it must not be replaced with a textual method-name lookup.
- `l2_input_is_descriptor` (20472), `l2_address_name` (20481), and the existing address operand/emission machinery preserve the distinction between a descriptor input and an explicit pointer cell.

Reference transmission must not add a call edge, invoke the transported body, or add its execution failures to the caller's throw closure merely to fetch the descriptor. Evaluating an actual that really contains other executable work still has its ordinary effects and ordering. The outer receiving call retains its own call edge and failure handling.

### Admission and binding category

The existing admission paths are part of the solution, not checks to remove: `l2_emit_admit` (15381), `l2_admit_site`, static consumer admission in `l2_check_call`, and the walker admission builders described below.

`l2_actual_ns` cannot always assign a namespace-model index to a callable descriptor. A missing static model mapping is not permission to substitute the formal's model or bypass `implements`; use the existing candidate descriptor and the receiving contract's admission route. `l2_untyped_graph` (14350) currently classifies a narrower set of bound names, so it cannot alone identify every newly reference-projected callable actual.

Resolution must start from the actual binding in its lexical context: own field, explicit formal, hidden input, local binding, unit occurrence, or resolved path. An own/formal/path value that is already an explicit pointer must remain that value, even if its referent is callable. Signature-description metadata and explicit executable pointer declarations must not be conflated. The current address resolver's descriptor-versus-cell distinction and typed-reference depth checks stay unchanged.

<a id="shared-projection"></a>
## Proposed shared projection

This section proposes an implementation boundary; none of it is claimed implemented by this audit.

Use one transient, source-linked receiving-actual decision over the existing P0 span, resolved binding/value category, and formal contract. It selects either an ordinary evaluated value/result or the existing callable occurrence reference. It is not a new AST, runtime object, name registry, persistent graph, or declaration mini-language.

The dependency-closed sequence is:

1. Resolve the actual through the existing context and path machinery before deciding how its value is received. Keep the source span and selected physical binding/occurrence. Do not choose by `ATOM` versus `FRAME`, by a particular method name, or by the C backend type alone.
2. Apply the accepted receiving contract. An explicit callable formal receives the occurrence. A nonreturning callable actual is reference-valued. A returning callable supplies its result where that is what the contract receives. Explicit pointer bindings retain their ordinary reference value rather than being implicitly invoked.
3. Expose the selected value's type, reference depth, available signature/model metadata, and effects to ordinary checking and admission. The projection does not manufacture a namespace model, weaken typed-pointer admission, remove a pointer level, or copy a nonprimitive value.
4. Make `l2_check_call`, the actual type/conversion consumers, and `l2_emit_call` consume that same decision. Replace their atom-only callable-actual recognition instead of adding another special path beside it. Generic expression evaluation remains the fallback only when the decision actually selects evaluation.
5. Make walker call-argument construction consume the same decision. Store a known physical occurrence, or construct the existing value-producing path/argument node, rather than an unintended nested `CALL`. Preserve ordinary admission nodes and evaluate executable argument subexpressions once.
6. Remove or narrow the old result-only assumptions only where their callers now use this decision. Retain legitimate no-result-expression errors in other receiving roles. Keep signature compatibility, explicit execution, statement behavior, and outer-call arity/failure checks intact.

This is a shared value-selection mechanism, not a rule that every context receives every callable by reference. Likewise, this slice does not decide body/formal rebinding or the unresolved classification of an unknown defining head.

<a id="site-aware-hidden-source"></a>
### Dependency: site-aware hidden reference inputs

**Rebaseline before implementation, 2026-10-01.** The historical pointer
machine-local premise below has been superseded by the active
[portable-reference migration](native-selfbuild-20260930.md#portable-reference-value-projection).
Its exact source is now released as `71c4743` with the common transport ABI.
Rerun the witnesses on that source before marking anything complete or
starting another metadata migration.

The original failure is retained in
`build/l2_harness/bounded_indexed_expression_20260930_07/src/unit_pointer_actual_contract.lm2`:
`check` declares `@: int p @values[0]` and calls `hidden`; `hidden` passes
its free input p to `read(p)`. That translator reports `unresolved dynamic=p`
at 13:14. At that snapshot, explicit pointers were machine locals omitted
by hidden-input resolution. This diagnosis no longer describes their
current storage route.

#### Reuse existing declaration identity

In the current working slice, `l2_ml_collect` skips source pointer
declarations: ordinary own rows already retain their exact declaration node,
method, host, resolved type/model, and distinct storage for repeated
declarations. `l2_dyn_step` and `l2_hidden_from` already consult own rows.
Do not implement the former proposal for a second machine-local identity
table or original-name C pointer locals. The earlier design is retained in
this file's Git history, not as a parallel instruction.

This does not prove forward visibility or correct hidden-source selection.
The inspected `l2_own_find_last` chooses the last same-name active-host row,
skipping `l2_own_excl` but without the call site's declaration cutoff.
`l2_dyn_step` processes a combined caller/callee edge, not each call site.
`l2_hidden_from` receives a source node but repeats the same unbounded
lookup. Storage identity therefore cannot substitute for source visibility.

The next acceptance matrix must first measure:

- Direct and multi-hop hidden-pointer forwarding with exact identity and a
  changed pointee value observed at the call.
- A call before the only local declaration: refuse if no earlier binding
  supplies the name; select an earlier formal/outer binding when present.
- Two calls on opposite sides of a declaration and calls before, within,
  and after a same-name nested declaration; preserve 11/22/11 selection.
- Repeated declarations and an initializer that reads the preceding binding;
  no future or sibling declaration is visible.
- Reference depth and qualification, including incompatible candidates.
- Actual native and walked routes where the same source is supported; a
  walked caller entering a native callee does not prove walked callee behavior.

#### Share the selected source across type closure and emission

If the timing witnesses fail, preserve the existing own row selected at
each call site, or explicit absence, together with the current lexical
scopes and declaration cutoff. Reuse the source-ordered traversal,
`l2_here_at` and deferred-site machinery where appropriate. An existing row
already owns the type and physical/native storage identity; no pointer-only
registry or companion graph belongs here.

Use the same selected source in dynamic type closure and actual emission.
Keep `l2_m_edge` for reachability/failure propagation, not as a replacement
for individual sites. Two sites between the same methods can need different
rows or ordinary input forwarding. Preserve existing declaration/formal
precedence, initializer-before-binding order, and namespace visibility.
Delayed checks must replay their saved environment without duplicating
records or choosing a later row. Pointer depth/qualification use the existing
type projection; no pointee is copied and no receiving model is guessed.

The 2026-10-01 preflight identifies `l2_wait_add` as reusable site/scope
storage, not a complete saved environment yet: its six-int record does not
save `l2_own_excl`, and `l2_wait_run` restores the method without restoring
the exact visibility position. Deferred initializer checks must preserve or
derive the new declaration's exclusion as well as scope and site. Measure
an initializer containing a hidden-input call, not only a bare preceding
name. Retain every relevant call site, rather than just calls whose value
check happened to wait. Do not globally apply a caller-site cutoff to
`l2_own_find_last`: callee lexical fallback and fields of other source parts
require their own declaration context. Path segments after a resolved root
are structural selection, not lexical bindings subject to that cutoff.

Apply any required visibility correction to the common binding resolver,
not only to hidden-pointer calls. Ordinary read, assignment, address, path,
`sizeof`, type checking and emission must agree on the same preceding
declaration. Mutants selecting the latest future row, dropping the host or
site identity, binding before the initializer, or reducing pointer depth
must fail. This is independent of Q58's unknown-head classification.

#### Pre-gate correction: future own field is not lexical fallback

`site_visibility_20261001_08` exposed an obsolete positive expectation in
`unit_dyn_hidden_from_cross_method`: beta reads `shared` before its own
`int: shared 222`, while neither caller nor lexical parent supplies it.
The historical test expected beta's own cell to supply 0 and then 222.
That is not the current forward-visibility / `node` fallback contract.
Do not restore a future-own type seed only for directly scanned names:
replacing the read with a helper forwarding the same free name cannot
create a different source-priority rule.

The author's Q8/U2 in [the original question](../LMX_blog/q/q.md) is distinct:
a parent field precedes the callee's lexical definition, although the first
call precedes execution of the parent's declaration. That permits reading
the parent's not-yet-initialized storage, not a later declaration in the
callee's own body. Preserve that positive case, including an unrelated
method's same-named field as a contamination control. Migrate the original
beta source to a located negative expectation and document the changed
row; do not delete it or claim an unchanged oracle.

Also test mixed call sites: a valid caller may establish the hidden input's
type, but that cannot make a different caller's missing source admissible.
Rejecting only because type inference stays unresolved is insufficient;
the source selected by native and walker emission must obey the same rule.
These are in-progress acceptance requirements, not completed gate evidence.

#### Consumer inventory before the final visibility gate

The read-only systematic scan of the `_08` frozen translator (SHA256 prefix
`5E16F2CE`) found four remaining live lexical consumers: `l2_index_head` /
`l2_index_token` for native pointer indexed stores; the joined-suffix fallback
in `l2_prefix_deref`; the `for` scanner's first-own marking; and
`l2_check_catch`'s visible-name conflict lookup. They must select the same
source-site binding before testing its category. A first matching own row
or a formal's stale type is not a substitute. Preserve catch policy while
correcting the declaration selected by that policy.

Do not globally replace structural enumeration: explicit occurrence/path
tails, layout, publication and PAP binding enumeration are not lexical
source selection. The unknown/empty/local-Structure role helpers remain
the separate Q58 resolver work. Returned-capture value selection through
`l2_mad_host_own`, `l2_cap_host_src` and `l2_mad_emit` also needs a coherent
return-site audit; distinguish the current source value from an explicit
structural `node` path and retain it in the callable/capture follow-up.
These source traces are not additional executed failure counts.

#### Remaining machine-local categories: separate conditional debt

Predeclared C function-pointer locals (`ty40`) and explicit foreign C
by-value locals (`ty41`) remain in `l2_ml_collect`. Its first-name
deduplication/source-name emission may still mishandle repeated or shadowed
declarations. Establish a failing accepted source witness before repairing
those categories, and establish whether they can be dynamic inputs before
adding transport. Recheck reachability of the residual
`l2_ptr_local_ty`/`l2_const_local_ty` branches after own-pointer collection.
Their existence is not permission to restore a duplicate source-pointer
path or to make this separate machine-ABI debt a prerequisite for every
portable hidden reference.

<a id="admission-layout-provenance"></a>
#### Required admission-layout provenance repair

The measured two-origin collision is recorded under
[SITE-BINDING-CATEGORY-REGRESSIONS](defects.md#site-binding-category-regressions).
Equal projections into a required model do not identify the original
layout. Native D-105 and walked ADMIT_AS must not reconstruct it by choosing
the first or last equal source map.

The implementation boundary is the existing `LmxImplEntry`, not
`Lmx`, Array, a second graph or a new registry. A nullable opaque `layout`
key records the compiler-known source schema of the admitted value;
it is independent of the required model and the map into that model.
The earlier graph-descriptor-only witness is rejected: a local named
declaration has no unit schema child, and each constructed local instance
is not a stable declaration identity. Use module-lifetime compiler metadata
identity uniformly for known source schemas. This is not a new value type
or runtime name/type catalogue. Unknown remains unknown; an identity map
does not establish the source schema.
The witness is published only with successful admission at the reached
receiving operation, never by anticipating a later consumer's admission.

Resolve the candidate's provenance once before evaluation, using the same
source-site binding and value projection as its type and address. A direct
named/local Structure has its declaration's schema key, not a new key per
instance. A pointer binding, formal or
returned value obtains evidence from its existing correspondence; its
declared receiving model is not evidence of its original layout. Ordinary
reference initialization, reassignment, return and D-105 call reception
must use this same projection in native and walked lowering. Reassignment
records the new candidate before storing it; a later read cannot recover
its origin by rescanning the original initializer.

Preserve these boundaries together:

- Null needs no entry. Failure publishes neither an entry nor provenance
  and does not store the candidate or dirty the destination.
- A cached same-map success preserves a known layout. Unknown-to-known
  enrichment needs genuine producer evidence, not the current requirement
  or a map-shape inference.
- Reusing a correspondence is not a proof for a new consumer. In particular,
  holes admitted because earlier code did not use those fields cannot
  satisfy a later full-model receiver by an unconditional cached YES.
  Preserve the current receiving check before enriching a cached view;
  compile-proved current uses and ordinary full-model reception must not
  be conflated merely to make native and walked branches agree.
- A fresh capture is in its required model's physical slots, with the
  existing holes semantics. A compiler-known producer supplies that schema's
  key explicitly; a runtime-only producer without that evidence supplies
  unknown. Neither retains the original value's source key by default.
- Graph copy/merge produces a fresh value and does not inherit the source's
  admission entries. A known copy producer may supply its actual resulting
  schema; missing whole-merge projection remains the separate recorded debt.
- Value/model/frame links remain weak. The key is non-owning module
  metadata, not a graph pointer to classify during pruning. Its lifetime
  follows the existing static-map/module contract, not a new unload policy.
  Graph instruction operands carry it through ordinary typed pointer cells,
  never raw unclassified child references. Attach and realloc preserve the
  complete entry. No temporary activation pointer is retained.

Acceptance includes both colliding layouts, typed-reference initialization
and rebinding from another model, forwarding and returned inputs, actual
walked bodies, null/unknown, candidate-once, failure-no-store, capture holes,
fresh copies and prune/attach lifetimes. All registration producers and
manual selftest constructors migrate together; no legacy-format fallback.
Include two local declarations with colliding intermediate maps but different
later-consumer positions, and repeated construction/re-entry: values differ,
source keys do not. State exactly which producer/consumer bodies were walked;
a walked root invoking a still-native local producer is not a walked producer.
This section is a bounded repair plan, not completed runtime evidence.

<a id="witnesses"></a>
## Minimal witness matrix: pending implementation and execution

All rows below are acceptance work to perform, not recorded successes. Use declared Structures or explicit `merge` when construction is needed; do not revive withdrawn implicit `Model: fresh` setup.

| Witness | Required observable property |
| --- | --- |
| A nonreturning `sub task` received by a `(task: f)` formal, at root and inside a method | The exact occurrence is transmitted; a counter explicitly changed by the task remains unchanged during transport. A separate explicit invocation changes it once. |
| Forward the callable input from one formal to another | Identity and signature survive forwarding; the implementation cannot rely on `l2_find_method` of an atom in the unit namespace. |
| Bare, parenthesized, short, and closed vertical nullary actual forms | Same receiving contract, same descriptor identity, same absence of execution. Validate canonical parser shapes without adding a syntax-specific semantic route. |
| A returning callable received once by a callable formal and once by a result-receiving primitive formal | Reference reception does not execute it; result reception executes it once and obtains the expected nonzero result. |
| Compatible callable descriptor received by ordinary nonprimitive formal spellings `(A: x)` and `(@: A x)` | Same transmitted descriptor and normal candidate admission. Select a demonstrably compatible model; do not infer compatibility merely from pointer width. |
| Actual selected through an own binding or a structural path, plus a shadowing formal | The resolved binding wins over a same-named unit method. Physical identity is preserved; an explicit pointer binding is not implicitly executed because its referent is callable. |
| `g(int: x)` given a nonreturning callable | Ordinary incompatible actual/reference-versus-integer failure; no blanket assertion that a `sub` cannot be transported as a value. |
| An explicit pointer cell's address supplied to a single-depth receiving formal | Wrong extra depth is still rejected. Primitive pointer controls and existing nonprimitive signature/address identity witnesses remain green. |

A positive fixture must return a distinctive nonzero success result or emit a checked success marker. Include deliberate inversions of identity and side-effect assertions, then restore the exact positive bytes and rerun. A descriptor equality assertion alone does not prove that no body executed; the explicit counter distinguishes transport from execution.

Generated-graph observation must verify the received argument value/reference, not merely the presence of some `CALL` token. For a reference projection, require the receiving call to obtain that occurrence without a nested invocation used to produce it. Compare native execution with actual test-only clearing of an eligible caller's native word, and state which bodies were still dispatched natively.

<a id="walker-boundary"></a>
## Exact current walker boundary

At the inspected blob, `l2_rw_call` (25472; callable actual branch at 25547) accepts a callable formal's actual only as a single atom found by `l2_find_method`, then stores the physical unit occurrence in the call argument. This existing route demonstrates that descriptor transport itself does not require inventing a new runtime operation. It does not cover general forwarded formals, equivalent Frame forms, or paths.

`l2_rw_struct_arg` (25689) is also narrower than the language contract: it accepts an atomic name of a seen, root-owned pointer field with an allocated graph child. Its existing `l2_rw_admit` (24364) and surrounding `l2_rw_admit_as` (24327) paths must remain available for typed receiving contracts. `l2_rw_arg` (25767), resolved path/value nodes, and direct known occurrence references are existing building blocks, not proof that their full combination is implemented.

`l2_rw_operand` (25776) still routes callable expression forms toward ordinary calls. It must not override a reference-valued receiving-actual decision by reconstructing a call from the source node's shape.

Independently, `l2_rw_may` (27123; formal loop beginning at 27143) excludes a method with a callable formal; it also excludes other unsupported nonnumeric inputs without a namespace model. Therefore a walked root that transports an occurrence into a native receiving method proves caller-side transport only. It does not prove interpretation of the receiving method's body or invocation through a callable formal after clearing that receiver's native word.

Full walker execution of such a receiver remains an explicit implementation boundary. Acceptance must distinguish: native transport; a genuinely walked caller transporting to a native receiver; and a genuinely walked receiving body. Do not relabel the second as the third, disable eligibility evidence, or claim general Array/dynamic-input support from the limited existing formal metadata.

No builds, runtime checks, source edits, or test expectation changes were performed for this audit note. Its proposed repair and witness matrix remain pending.

# General receiver resolution: replace shape recognizers

Status: OPEN, 2026-09-30. Implementation plan, not a new language contract.
Source: the author's clarification in [Q56](../LMX_blog/q/q56.md).

## Required result

Keep the existing project, P0 trees and runtime representation. Replace the
translator's independent recognizers of selected source spellings with one
resolution of each ordinary receiving expression. `a: b: c: d: ...` is ordinary
nested application, not a declaration mini-language. In particular, `[]: []:`
must not have its own grammar, special Array kind, fixed depth, or separate
lowering route. The same Array receiver must consume an explicitly supplied
element description whether it denotes a primitive, a Structure, or an Array.
No implicit contextual type is invented when a required type is absent.

This does not equate different receiver orders without their contracts saying
so. Resolving a receiver is not eagerly executing all its syntax operands:
declaration names remain names, and existing bindings follow the agreed
call/assignment/construction rules. Preserve source locations and visibility.

## Measured failure

The saved s7b115 translator accepts P0 syntax for:

```text
A: ()
[]: A: b
return
```

It then refuses line 2 with `unsupported own array declaration`. The temporary
probe is under build/array_receiver_probe_20260930 in the main checkout. This
is not evidence that a special parser extension is needed.

Current duplicated semantic entry points in dev/l2src_sandbox/l2trans.lm1:

- `l2_own_array_count`, `l2_own_array_pointer_ty`, `l2_own_decl_ty`,
  `l2_own_decl_name`: re-read flat Array and primitive declaration spellings.
- `l2_ns_arrarr_field`: recognizes exactly primitive + two Array Frames.
- `l2_take_ns_body`: another declaration resolver, including fixed field-kind
  dispatch and an int/char-only Array branch.
- `l2_colon_decl_shape`, `l2_colon_bind_shape`, formal/signature consumers:
  existing binding/call distinctions must survive the common resolution.
- `l2_arr_operand`, `l2_arr_len_shape`, `l2_array_length_own`,
  `l2_rw_index_ty`: duplicated expression/path interpretation downstream.

## Replacement boundary

1. Resolve existing P0 nodes directly. Retain the actual argument subtree;
   do not parse emitted strings or rewrite one exceptional spelling into
   another. Receiver identity/contract and current bindings determine the act.
   The common application representation must accept any head with its ordered
   operands, not only recognized declarations. Declaration/type metadata is a
   semantic result derived from that representation. For example, `int: b: 5`
   is an outer int application containing a b application; `int: b 5` has two
   operands. Do not collapse these different trees or decide their equivalence
   by a spelling-specific rewrite. Receiver resolution, not syntactic nesting
   alone, determines whether an inner node is a declaration operand or executed.
2. Record the resolved act, explicit value/type description, binding/location,
   initializer/operands and source location once in compiler-owned metadata.
   This is not a hidden runtime data graph, type-name registry or new payload
   field in Lmx/Array. Reuse existing type and binding identities.
3. Make own fields, named-Structure fields, nested bodies and formals consume
   the same resolved declaration information. Migrate existing consumers;
   delete replaced recognizers in the same slice. An unused generic helper
   beside unchanged special paths is not a completed slice.
4. Native and interpreted graph emission consume the same resolved operations
   and actual types. Do not resolve source spelling independently in either.
5. `length` consumes an ordinary Array-valued operand and reads that descriptor;
   it does not inspect whether its element is another Array or reparse indices.
6. Keep Array as the existing minimal descriptor and typed backing. A structural
   element is an ordinary reference; no array-of-arrays runtime type or depth
   registry is introduced. Construction/admission use the existing machinery.

## Staged access and the ordinary unnamed index step

The author retains C-like `[][][]` for a flat rectangular Array, separately
from ordinary nested receiver applications. For Array-valued elements, use
the author's ordinary staged bindings now:

```text
[]: []: []: a
[]: []: b a[i]
[]: c: b[j]
```

The witness must supply actual typed values for a, i and j and observe reference
identity/value and lengths. These are ordinary bindings to the selected values,
not a hidden Array-of-Arrays construct.

The author's next clarification defines direct access through the existing
backslash path: `a[i]\[j]\[k]`. Each backslash explicitly continues from the
selected value. `[i]name` remains a same-name Structure occurrence selector;
an unnamed `[i]` step indexes a typed Array. Adjacent `a[i][j][k]` remains the
C-like flat multidimensional form. No inference of rectangularity, separate
Array-path resolver, index-count cap or dimension-recovery mechanism is used.

Required lowering: resolve each path step against its current typed operand,
then pass its ordinary typed result to the next step. Structure-field and
Array-element access have different storage projections, not different source
path algorithms. Preserve each index expression and evaluate it once. Native
and walker consume that same resolved path; `length` simply uses its result.

## Acceptance and landing

### Path implementation boundaries (read-only audit, 2026-09-30)

P0 already retains value-position paths as ordinary fields: the root, brackets,
their expression operands and backslashes. Update-position paths arrive in a
Frame head. Normalize both inputs into one source-linked, dynamically sized
path representation; do not introduce another Array-only parser. Reuse the
general expression machinery for index operands, including calls, rather than
inventing a restricted integer-expression scanner for compact heads.

- `l2_expr_span`, `l2_path_chain`, `l2_join_path`, `l2_rw_path_run` currently
  expect a name after a backslash. Distinguish a named occurrence step from
  an unnamed Array index by the following name, not by whether the index is
  a literal. Retain the index expression and its source position.
- `l2_path_kind` and `l2_emit_path_to` are the shared resolution boundary:
  current typed value plus the next field/occurrence/index step yields the
  next typed value. Read, write, address-taking, return and `length` must use
  this result. Do not make each consumer rediscover the path.
- Retire `l2_path_arr_leaf`, `l2_arr_operand`, `l2_emit_arr_operand`,
  `l2_arr_len_shape`, `l2_rw_indexed_path` and `l2_rw_index_ty` as their
  consumers migrate. Their fixed two-index/literal assumptions are not a
  language contract. Remove the walker path's fixed buffer/depth rejection.
- The runtime already has `LMX_WALK_OP_ELEM` and `LMX_WALK_OP_ELEMPUT`:
  descriptor and index are evaluated, and the descriptor's element type
  determines the result. Use these general operations for interpreted paths;
  native lowering emits the corresponding typed access with one evaluation
  of each index. No second index algorithm is needed for `length`.
- Tests need mixed field/index paths, reference and primitive elements,
  dynamic indices with observable call counters, address/write/read parity,
  non-Array intermediate values and malformed paths. Keep adjacent rectangular
  suffixes distinct from backslash-separated steps.

Use independently constructed Arrays for the first path witnesses if this
avoids unrelated mail dependencies. If using `mainArgs`, follow the later
string contract: `ok` has length 2 with no NUL in the Array (D-20,
[evidence](d20-mainargs.md)), not the superseded NUL-inclusive Q15 wording.

### Gates

- Positive witnesses must exercise the same implementation at unit, method,
  named-Structure and nested-body positions; check actual typed values and
  physical reference storage, not only translation success.
- Cover primitives, Structure elements and repeated ordinary receiver
  composition beyond the old two-Frame boundary. Use unequal inner lengths.
  Include the author's staged b/c bindings above with actual selected values.
  Compare them against direct backslash paths; include named-field/index mixtures,
  unequal lengths, dynamic indices with observable effects and deep chains.
  Add non-Array receiver compositions so an Array-only dispatcher cannot pass.
- Preserve unknown-name construction, existing callable invocation, primitive
  assignment, explicit-reference binding and admission failure diagnostics.
- Native and walker witnesses must agree. `length` must work on any supported
  Array-valued operand without a spelling-specific path.
- Negative/mutant witnesses must distinguish wrong type, wrong receiver order
  and missing declaration information; no fabricated interpretation on error.
- Before landing code: full affected parser, generated L2, kernel and L3 gates,
  check_docs, diff --check, exact dev/stable synchronization and tested-byte
  checkpoint. Focused runs are diagnostic evidence only.

The previous proposal to generalize a two-index Array scanner into an
arbitrary-depth Array scanner is superseded. The active requirement is general
receiver resolution. Independent runtime traversal-cap repairs do not satisfy
this translator repair, and old green gates do not certify it.

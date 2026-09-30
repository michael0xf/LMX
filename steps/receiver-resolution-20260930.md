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

## Staged access, without a new shorthand

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
not a hidden Array-of-Arrays construct. Do not invent a shorthand `a[i][j]`
that silently chooses between the original rectangular Array and the value
selected by the first suffix. A new quick syntax is deferred and does not block
this work. No dimension-recovery mechanism or shape/rank promise is introduced.

## Acceptance and landing

- Positive witnesses must exercise the same implementation at unit, method,
  named-Structure and nested-body positions; check actual typed values and
  physical reference storage, not only translation success.
- Cover primitives, Structure elements and repeated ordinary receiver
  composition beyond the old two-Frame boundary. Use unequal inner lengths.
  Include the author's staged b/c bindings above with actual selected values.
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

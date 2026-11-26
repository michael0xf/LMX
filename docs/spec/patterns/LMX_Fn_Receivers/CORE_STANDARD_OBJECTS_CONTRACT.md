# Standard acceptance contract: standard object operations

Edition: 23 November 2026. Scope: the 16 complete implementations in
[coreStandardObjects.lmx](src/coreStandardObjects.lmx), their public exports and
the existing typed-result/field-name bridges. **This contract uses the existing primitives, receivers and native providers.** Execution has not been performed in
this archive; the cases below and in
[standard_objects_cases.json](tests/standard_objects_cases.json) are `NOT_RUN`.

## Existing specification to apply

- [Ordinary receiver arguments and typed absence](../../LMX_semantics.en.md#receiver-args-only):
  `nil` represents absence of a value; comparison with `nil` observes that state
  without reading nonexistent payload bytes. A ready null pointer and zero are
  initialized values.
- [Zero-payload uninitialized records](../../LMX_semantics.en.md#uninit-zero-payload):
  an anonymous field name from `fieldNames` remains `uninit:[]char`; it must not
  acquire an empty-string or null-pointer sentinel.
- [Explicit paths do not execute](../../LMX_semantics.en.md#path-reads-no-execution):
  obtaining a graph field returns its record, including a computed declaration,
  without evaluating the initializer or invoking a returned callable.
- [Binding](../../LMX_semantics.en.md#binding-places) and
  [copy/merge](../../LMX_semantics.en.md#composition) remain the ordinary rules.
  `copy(FxFieldArguments)` supplies the three public input contracts through the
  existing namespace mechanism.
- [Kernel requirements](KERNEL_REQUIREMENTS.md), `attempt`, `fieldNames` and
  universal Array access, already specify the common bridges. The new functions
  use those bridges; they do not substitute a high-level opaque implementation.

## Export and source integration

Register the 16 entries from
[CORE_STANDARD_OBJECT_ADDITIONS.json](CORE_STANDARD_OBJECT_ADDITIONS.json) in the
one existing current-core catalog and `fun\const` export namespace. Preserve
their lowerCamelCase names, signatures and documented return kinds. Include the
complete source and its one shared `FxFieldArguments` description in the source
inventory; do not count an export alias as another algorithm.

`orElse` and `orElseGet` return a payload record. `orElseOption` returns a Maybe.
`orElseResult` returns a Result. Those are distinct contracts, not overloaded
spellings whose meaning is inferred from a convenient example.

## Result representation and invocation

Exercise each applicable direction: interpreted caller/interpreted callback,
interpreted caller/native callback, native caller/interpreted callback, and
native caller/native callback. The same ordinary preparation and admission
must serve all four.

1. Return `none()`, `some(value)`, `ok(value)` and `err(reason)` directly from
   callbacks. `orElseOption`/`orElseResult` must receive the actual container,
   without a mandatory extra `@` box or an unconditional dereference of its first
   field. The source follows the existing `FxBind`/`FxBindResult` admission path.
2. Repeat with a container whose payload is a reference to a mutable object.
   Preserve the reference target and full reference type. Container admission
   and reading the contained reference are separate operations.
3. Check primitive, empty Array, Structure, callable and explicit void results.
   Returning a callable does not invoke it. Ready zero, ready null, ready empty
   values and absent Maybe remain distinct.
4. Verify selected-branch counts: absent map/filter skip their callbacks;
   lazy fallbacks execute only on absence; Result mapping enters only its
   selected channel; folds enter exactly one branch; `tap` invokes its effect
   once and returns the original record.
5. `attempt` captures only the target's admitted declared failures through
   `FxTry`. Its error payload retains the complete original `FxOutcome`,
   including failure name and typed payload. Kernel/admission failures and
   implicit stop/abort paths are not converted into a fabricated err value.

## Physical field lookup

`findField(source; label; occurrence)` is a single physical-order scan of the
existing canonical name vector. `occurrence` is a required zero-based ordinal
among equal ready names. It returns some(existing field record), or none.
`hasField` and `getField` reuse that scan; neither contains a second lookup
algorithm. Missing `getField` and negative ordinals raise `FxIndex`.

Required observations:

1. Equal names at several physical positions remain separately addressable.
   Selecting occurrence 1 returns the second equal ready name, independent of
   unrelated fields between them. Out-of-range nonnegative occurrences are
   absent, not clamped.
2. An anonymous `nil` name is skipped before any string comparison or length
   operation. A ready empty name is still a name and can match an empty query.
3. A named uninitialized field is present. `hasField` returns 1 without reading
   nonexistent value bytes; `findField` retains its actual uninitialized record.
4. Returning a computed declaration or callable field performs no initializer
   or callable execution. No source text is printed, parsed or evaluated to
   resolve the runtime label.
5. No field-name table is recreated inside the graph. Owner/protection behavior
   is the same as the existing `fieldNames` and physical field-read operations;
   no private namespace bypass or remote mutable access is added.
6. Reading does not mutate or copy the source graph. A retained reference does
   not invent a longer lifetime than the ordinary ownership rules permit.

## Evidence to attach

Record the kernel build/revision, direction, exact source, observed result,
callback/initializer counts and failure name/payload for each accepted case.
Attach actual native/interpreter execution output. Source hashes and expected
results are review aids; they are not evidence that runtime acceptance passed.

The [coverage review](CORE_STANDARD_OBJECTS.md#reviewed-standard-facilities)
states which foreign contracts are equivalent, explicitly composed, or differ.
Java Optional null normalization, Rust borrowing, JavaScript getters/prototypes,
Java/Scala suppressed exceptions and lock-free atomic mutation must not be
inferred from the existence of a similarly named LMX helper.

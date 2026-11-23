# 084: why this client needs no failure-name comparison

The selected client handles the failure of its concrete resource callbacks.
Its entire declared target-failure set is `{ResourceFailure}`. This conclusion
applies to the shown program, not to arbitrary callers of `bracket`.

| Reached path | Declared recoverable failures | Delivery to `Trace\Example\run` |
| --- | --- | --- |
| `Acquire\open` → shared `Trace\code` | `ResourceFailure` | `FxCallFailure(originalOutcome)` from `FxApply` |
| `Action\use` → shared `Trace\code` | `ResourceFailure` | `FxCallFailure(originalOutcome)` from `FxApply`, after cleanup |
| `Release\close` → shared `Trace\eval` | none | Ordinary return; implicit failures retain their normal path |
| Bracket storage, argument concatenation and bridge admission | `FxKernelFailure`, `FxTypeToken`, `ReceiverIndex`, `SequenceSize` as applicable | Their own names, outside the target-failure envelope |

The proof follows the actual [core source](../../LMX_Fn_Receivers/src/generic_wrappers.lmx):
`FxAround` calls `FxApply` directly for the three supplied targets. It does not
wrap its own complete implementation in another `FxApply`. In
[generic_runtime.lmx](../../LMX_Fn_Receivers/src/generic_runtime.lmx), `FxApply`
calls `FxTry`, and `FxTry` gives the target's own `signature.throws` to the
ordinary `FxKernel.attempt` bridge. That bridge catches only those admitted
declared names under [its existing contract](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).
Argument concatenation uses the existing Array implementation and introduces
no additional user callback or `FxCallFailure` envelope.

Thus every `FxCallFailure` reaching this particular handler represents
`ResourceFailure`. Comparing the contained name would repeat a fact already
established by this finite callback set. It would add code without changing
which failure is handled. Haskell's `Either ResourceFailure Int` and Scala's
`case _: ResourceFailure` select the same application failure. The former
Haskell `IOException` catch was narrowed to the explicit custom failure so
that unrelated IO exceptions are not swallowed.

The handler keeps one ordinary unused `@: error` formal. The envelope carries
one payload, and [catch's common actual-argument rules](../../../LMX_semantics.en.md#catch-common-model)
do not grant a special excess-argument discard for an empty `()` parameter
list. No payload read is needed. `FxCallFailure` is handled on every path and
therefore need not remain in `run`'s outward `throws`; see
[shared throws](../../../LMX_semantics.en.md#shared-throws).

The three observable paths remain `42123`, `-123` and `-1`. Acquisition failure
registers no cleanup. After successful acquisition, cleanup runs once even
when the action fails. Infrastructure or implicit failures retain their
ordinary outward paths. Release failure/dual-failure policy is separately
described by comparison 098 and is not invented by this client.

The complete author `Around` variant from 22-Nov remains visible and measured
at 709 nonwhitespace characters. The selected core client is 586 characters
after removing the redundant guard; it still includes the complete shared
`Trace` callbacks. No new public string-equality function is needed.

These are source-level contract observations and prepared expectations.
Neither the LMX client nor the native/interpreter bridges have been executed
in this workspace.

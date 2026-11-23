# Adapter acceptance: prepared sources and unexecuted cases

**No runtime execution has occurred.** The real kernel and its call-phase provider are not in this archive. All 31 current specification cases remain `NOT_RUN` for all four required execution directions. Source probes and text checks do not change that status.

Use [the current semantics A01–A20](../../../LMX_semantics.en.md#adapter-observations) and [B01–B11](../../../LMX_semantics.en.md#uncurry-observations) as the oracle. The separately supplied priority task is reference material and may contain older names; current names, types and source forms prevail.

## Prepared concrete probes

[adapter_semantics.lmx](adapter_semantics.lmx) defines `FxAdapterExamples\run()`. Load the current assembled receiver definitions and this fixture through the actual kernel's normal source mechanism, then invoke that entry. The archive does not invent a kernel CLI command or claim a fixture command was executed.

| Observations | Concrete source behavior |
| --- | --- |
| A01/A02 | Own default 7 wins over caller x=50; explicit 0 overrides; a later call still uses 7 |
| A05/A06/A07 | Unused optional uninit and computed default remain unread; construction/signature inspection has no effect; actual demand runs the default; explicit actual suppresses it |
| A08 | One partial called from x=11 and x=22 contexts follows each current context |
| A09, partial coverage | Explicit actual remains accepted by a private receiver input |
| A11 | Captured x=5 remains available to default y=x+1 despite public removal of x |
| A16, partial coverage | Once miss/hits execute target once; an effectful explicit actual runs on hit; omitted unused default stays untouched |
| A17 | Guard's predicate reads its first input; the second target default is not forced |
| A18 | Passive trace receives enter/return snapshots with the second input absent and unready, without evaluating it |
| A19, partial coverage | Memo keys reflect different current autofill values; repeat of the first value hits only its own entry |
| B01/B02/B04 | No factory stage execution; exact callable-signature return; different inputs choose different next callable values; omitted flat positions retain reached stage defaults |
| B05, partial coverage | N=0 and N=1 stop correctly; the existing mixed generic fixture supplies larger finite arities |
| B06, partial coverage | Final callable is returned and is invoked only by an explicit later source call |
| B09, partial coverage | Prepared input values give the stated number/order of stage calls |

All probes use ordinary typed inputs; the counters are observation tools, not an int-only adapter implementation. The exact intermediate callable result is `FxAdapterNextSignature@`, using the current postfix pointer-type notation.

## Still to instantiate in the actual harness

The JSON records every original required case, not only those for which a positive source probe has been drafted. In particular, kernel integration must supply negative selection tests without pretending that an ordinary refusal is a declared catchable exception, and cover:

- A02's nil/null/empty/uninit distinctions; A03 and A04 selection versus reached required; all private directions and transparent-place/fallback chains.
- `node` and nested default identity, declaration-form actuals with associated bodies, actual label aliases, duplicate/excess/name/W/E pre-effect checks.
- Once failure/retry/reentrancy paths, memo failure/no insertion and mutable-key policy, mixed pointer depth and dense-array prefixes, full prefix and invalid prefix.
- Structure-model next stages, long mixed chains, final primitive/Structure/void, wrong reached stage/input/result, named and implicit failures, effectful outer actual ordering, independent user chains and native/graph-change/lifetime paths.

These are explicitly marked `scenario_to_instantiate_in_kernel_harness` or `partial_source_probe` in [adapter_acceptance.json](adapter_acceptance.json). No missing test body is represented as executable or passed.

## Four execution directions and evidence

Run I→I, I→N, N→I and N→N after explicit native compilation. Record actual native entries taken; silently interpreting the whole native case does not count. For each ID record the event journal, entered body count, observed place identities/initialization states, true result model or failure payload, cleanup order and ownership evidence. Frame release and no use-after-release require native/mixed checks, not just final numbers.

A completed kernel report should supply its real build/run commands and versions. Current package checks only syntax-like text properties, declared finite edges and assembly completeness; none is a kernel acceptance result.

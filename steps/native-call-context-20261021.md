# Private125: computed native-call results retain their CURRENT context

Baseline f4d22d29; exact124 snapshot in build/codex_native_call_125.
Codex sole writer/build; goal ACTIVE. Runtime, headers, shared Value layout
and uniform9 callback ABI remain exact122/123/124. Public dev is not promoted.

## Explicit computed output, same call and admission

The existing call emitter workers now accept an optional explicit result-context
output. l2_emit_call_value reserves one activation-local LmxWalkValue l2_cvN
alongside the same raw result temporary, BEFORE callable-class selection.
Every selected class arm passes that same output to lmx_call_prim_values;
the ordinary raw entry points remain wrappers of these same workers.
The input Value span is still absent here; this is not outbound-actual closure.

l2_prep_context, l2_emit_fields_context, l2_eval_and_context and
l2_eval_fields_context are the same existing evaluator workers with an explicit
optional companion output, not a second expression parser. Whole calls and
anonymous grouping preserve it. Numeric/logical operations do not leak an
operand's reference context into their numeric result. No Model tag is added
to L2Tx, no compiler/global last-result state or runtime address lookup is used.

An ordinary declared-Model statement/control-body/trailer return passes this
computed pair to the SAME bound receiving record and lmx_walk_value_admit
through l2_emit_model_admit_computed / l2_emit_model_admit_parts_core.
The worker materializes raw value + explicit Model/reference sheet together,
performs the existing implements operation and publishes only the successful
receiving result. It does not reconstruct Model from the candidate's physical
layout, first admission, source name or required return type. A present malformed
pair cannot be erased and rescued via the legacy raw source-frame route.

A universal pointer return with an explicitly computed pair forwards that pair
unchanged; it neither invents a Model nor performs a new admission. If its
expression has no produced context, it does not overwrite context deliberately
supplied by an explicit L2 service. Void/numeric results do not gain a pair.

## Exact tested bytes

| Input | SHA256 |
| --- | --- |
| compiler source | 2FA84CB96FD9BCF7D3CA521DE89651D77069DB936D22702ED9B8365A88D36873 |
| generated frontend C, build03 | B2CFE5624F1EE743B045AE3811584934BA94575D5AB2F125E0B7511B0CECCE86 |
| frontend EXE | 4041D156B95645E39BA324544244D1F395D79394B5D5EEBCA06E747ACD5ADE76 |
| witness L2/L1-generated C, probe02 | 931EF40E033E67CFEE13E765B6D6C4440F7BB78B9E6E855E5567954EC52D806D |
| executed160 C fixture | 985621E12058E87B0B57758343D1394CB17E7ECE816BA02F3132EA3702B04EF9 |
| explicit foreign test helper | C775B0D788F9EC242726D7E6B1B570E1B2CC6971EEBDD09A0AE0CAFD5ABB3382 |
| exact124→125 source patch | 93139B4ACA0AF4017E0620638DA391B5964DFB8E58EF6FFEF90021BBD7385D07 |
| executed L2 witness | 3B057ADB2405EA233FDC0349E941161E26A845DD83C6751ADAD0CB88EEE26DB9 |

The [source patch](witnesses/used-scope-20261020/native-call125-u0.patch)
applies with git apply --unidiff-zero --check -p0 to exact124 and changes only
src/l2src/l2trans.lm1. The [L2 witness](witnesses/used-scope-20261020/native-call125-probe.lm2),
[C assertions](witnesses/used-scope-20261020/native-call125-test.c) and
[helper](witnesses/used-scope-20261020/native_call125_test.h) are exact executed inputs.

## Actual native and walker values

Test02 executes160 assertions at O2/fstrict, all GREEN:93 unchanged earlier
checks +67 computed-native-result checks. The test-only C service chooses
between actual generated native D/E producers at runtime and calls the SAME
uniform dispatcher. It does not manufacture a Model or sheet. The opaque
candidate has independent D/E admissions and no physical-layout token.
The service starts with a fresh candidate per act, avoiding conflicting
receiving-map history across separate runs.

Ordinary generated universal forwarding, direct R receiving, receiving through
the forwarding method, and receiving inside a control body all preserve the
runtime-selected pair. D gives actual7; reordered E gives9. The result's R map
controls actual41 writes and taken-address replacement43, keeping the neighbor
9/7 intact. Real walked CALLs into those same generated native receivers then
perform OF, PUT and ADDRESS against the SAME computed result. Source counters
prove no second source evaluation. This is not merely successful translation.
The native read/write/address oracle here is a C consumer of the actual
generated native result. Source-native path coverage also remains in the
inherited execution matrix; this witness alone is not closure of every deep
mixed source path or every native working-value producer.

Additional checks preserve a half-present pair through universal forwarding,
reject it at ordinary receiving without raw-history rescue, preserve present-null
E/sheet through forwarding, and publish present-null R/sheet without admitting
an unrelated non-null candidate.

Three mechanical generated-C controls execute the IDENTICAL160 fixture/runtime:
drop all seven captured call contexts gives64 FAIL; drop the forwarding pair
gives34 FAIL; replace giving Model at the four R receiving sites with D gives21
FAIL. Each exits1 by assertions, no crash/setup/ABI mismatch. Native D/E producers
are unchanged by the last control. Test01 before null extension executes155/0.

The unchanged124 L2 source and111 assertions are freshly L2/L1/GCC/link/run
through125,111/0. Final build03 Source/CHECK profiles freshly compile against
its exact generated frontend C and execute336 unchanged assertions, all GREEN.
Runtime122 kernel evidence is inherited, not newly executed in this slice.

## Matrix and provenance

Fresh matrix01/session11348, child PID15504, startUTC
2026-10-21T12:59:40.2804235Z, is TERMINAL0. All85 units freshly pass
L2→L1→C→GCC/strict COMPILE→LINK, and all170 observations actually run:
162 GREEN +8 unchanged copy RED/exits. Only exact122 runtime and unchanged
libc56 objects are reused; no old unit object or EXE is reused.
All350 named input pins are verified. Actual native binding counts, root modes,
--walk-methods and original positive oracles are unchanged.

This is not full gate. The inherited source-provenance limit remains:
14 byte aliases and5 exact118 graph reconstructions; historical source bytes
of those5 reconstructions are not proved by this replay.

Terminal18654 pins are frozen in
build/codex_call125_terminal_01.inputs.sha256, SHA256
B4C3AD1A20C7CB08F0B8F2F0FA6B50F143DB5C77A7B5C0E06C796A68E4119EAB.
All17395 upstream124 pins, unchanged source/header bytes, final source/C/EXE,
all fresh85 unit artifacts and actual170 observations were independently
reverified, together with160/111/336 checks and the same160 loss controls.
All named workers are terminal.

## Preserved failed attempts and open dependency

Build01 compiled the initial call channel before evaluator consumers existed;
it is not a complete160 witness. Build02/probe01 generated invalid C for
unparenthesized .model/.references call operands: L1 split their tokens into
arguments. The generator is fixed in build03/probe02 with parenthesized operand
expressions; no source-language type/check rule is relaxed. The bad generated
C is preserved as inspection evidence, not an executed assertion result.

Mutants01 has a control-generator substitution error (the token 10 replaces a call);
its COMPILE refusal is preserved and is NOT counted as a killed semantic mutant.
Mutants02 corrects only the mechanical control generation and has the three
actual assertion-RED results above. Earlier stdout labels inherited from123/124
are stale; actual paths, exact bytes and assertions determine the stated result.

This is a private ordinary-call-result/return slice, not full native transport.
Working/formal/default/rebinding producers, outbound actual spans, pure
field/index/reference producers, pointer casts, held-callable remapping, typed
copy relocation and every remaining consumer still require the same explicit
computed Value context. A root call's context must not be reused for a suffix
whose leaf was separately selected. Callable-class propagation is wired in the
common emitter, but the new160 witness does not independently cover multiple
runtime callable classes. Trailer code uses the same worker; no new dedicated
runtime-selected trailer witness is claimed.

The8 copy positives remain RED in the fresh125 matrix. Full112's
1011 FAIL/3754, all-path unification, clean kernel, L3+L2 self-build and mail
T01–T26 are NOT closed by this targeted GREEN.

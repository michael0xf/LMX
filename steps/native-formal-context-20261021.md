# Private127: CURRENT native formal state is activation-owned

Baseline f133e9ba; immutable126b snapshot extended in
build/codex_native_formal_127. Codex sole writer/build; goal ACTIVE.
Only the compiler changes. Runtime, headers, Value layout and uniform9 ABI
remain exact122–126; public dev is not promoted.

## Formal producer and the same receiving/value operation

The native prologue allocates one local ordinary Value context for each
pointer formal/consumed hidden pointer input. It starts cleared. For a present
explicit computed input it checks REFERENCE kind and payload correspondence
with the already unmarshaled parameter, then copies the Model/reference sheet.
This is a per-pointer logical-input check, not a new claim of complete ABI
validation for all possible numeric/foreign/malformed input transports.
An absent/raw input does not acquire metadata from type, layout or history.
Forward-only raw hidden inputs retain their existing separate transport.

l2_tok_formal_context snapshots the SAME typed raw pointer and its CURRENT
local pair into an explicit computed result. A formal already bound to an own
field uses the existing working-value worker instead. The old text-only API
wraps this same worker; no separate expression parse or lookup is added.

The common direct formal store replaces the value AND its pair. An unannotated
replacement clears the pair even when its raw pointer equals the old pointer.
Annotated rebinding keeps the new computed pair, not the immutable input
snapshot. The caller's input record is never mutated. Ordinary reference
rebinding uses the SAME reference-value / bound receiving / value_admit chain
as a local: a declared Model formal is admitted before the new binding is stored.
This replaces the old special positional-admit path of direct formal rebinding,
not the language's implements obligation.

Names of these local machine variables are not program-graph fields. No
Model pool/graph field/fat-pointer program ABI, global current-call state,
candidate-address lookup or source-name resolver is introduced.

## Exact bytes and actual formal values

| Input | SHA256 |
| --- | --- |
| compiler source | 5C10A0C35AFA2B24B28785F8944E0C54DDC361B7E0EEA1D1C8646A9EA46F2C2A |
| generated frontend C build01 | D19FD0DF48CC91D84C5ADC27DA52F5B6CE82684B78FF5ABAFEA1D782221D01E4 |
| frontend EXE | 11DBF81DDC5668EF83F29C9E7BE360390FDC5F22AF761402D68AE09319F98487 |
| witness generated C probe01 | FFDC13F7094723D6C65D22F07F6D941641EA86CC0BBE0D6BBFC1C2A63A1FF2AB |
| witness L2 | BB81DE315B369059495D448B248FB0D89362A55BAB303C4F4828F87C55E19F39 |
| executed412 C fixture | 2AD11725799AA2E3FB66624EA237A5BE892FCB00252C386033C2D9DE2C929237 |
| exact126b→127 patch | 51F4645DA1FC1114C6079884F9F3731BE1B22457B11B93EE2E5AEBCE3E4D7CED |

The [patch](witnesses/used-scope-20261020/native-formal127-u0.patch) applies
with git apply --unidiff-zero --check -p0 to exact126b and changes only
src/l2src/l2trans.lm1. [L2 source](witnesses/used-scope-20261020/native-formal127-probe.lm2)
and [C assertions](witnesses/used-scope-20261020/native-formal127-test.c)
are byte-identical to the executed inputs. The explicit foreign helper remains
[exact125](witnesses/used-scope-20261020/native_call125_test.h).

Test02 freshly strictly compiles/links and executes412/0 O2/fstrict assertions:
the earlier288 plus124 formal checks. Test01 before the null/half/raw/alias
extension executes404/0. The SAME412 fixture/source freshly generated with
unchanged126b executes107 assertion failures, exit1, no crash/ABI mismatch.

The actual incoming pair comes from ordinary generated native D/E producers,
not a service manufacturing a formal's metadata. A typed R input is first
formed by an existing ordinary R receiving method; the C test does NOT bypass
implements by passing an unadmitted E reference as an R formal.

Formal forwarding, receiving, copy to a local followed by formal clearing,
universal/declared-Model rebinding, raw same-address replacement and a nested
checkpoint call are exercised. Rebinding deliberately selects the opposite
runtime D/E view in a fresh candidate. The old caller value and input metadata
remain unchanged. Both direct native calls and real walked CALLs into the same
generated native bodies return the actual required R map; subsequent reads,
writes41 and addresses43 preserve the neighbor7/9. Each written source act
is counted separately.

The native read/write/address oracle is a C consumer of the actual native
result. The walked consumers execute OF/PUT/ADDRESS themselves against the
SAME computed result, without re-executing the source call. Source-native path
coverage remains separately in the matrix; these counts do not prove every
deep mixed path or every alias/mutation route.

Additional checks preserve a present-null formal pair; validate/publish a null
R result; clear local metadata without clearing the caller's null metadata;
preserve a malformed present pair through universal forwarding and reject it
at ordinary receiving without history rescue; keep raw callers unannotated
across re-entry; and establish the formal snapshot before an aliased result
context destination is written.

Source/CHECK profiles freshly compile against final frontend C and execute336/0
unchanged assertions. Unchanged124 L2/source/111 fixture also freshly
L2/L1/GCC/link/run through127,111/0. New kernel execution is not claimed.
The inherited stdout labels still say123/124/125/126 in some recipes; exact
paths, bytes and actual assertions determine these results.

## Actual matrix/controls and remaining transport

Matrix01/session98018, child PID7512, startUTC2026-10-21T13:32:17.9030014Z
is TERMINAL0. All85 units freshly pass L2/L1/C/GCC O2/fstrict COMPILE/LINK.
All170 observations actually run:162 GREEN and8 unchanged old copy RED/exits.
No old unit object/EXE is reused; exact122 runtime and unchanged libc56 objects
are reused.350 named input pins, actual native binding counts, root modes and
--walk-methods are preserved. Historical provenance remains14 byte aliases
and5 exact118 graph reconstructions; historical source bytes of those5 are
not proved by this replay.

Four mechanical generated-C controls execute the IDENTICAL412 fixture/runtime:
erase18 entry pair fields gives65 FAIL; erase6 formal store pair fields gives22;
erase18 formal load pair fields gives87; skip only3 replacement clears gives5.
Entry initialization is preserved by the last control. All exit1 by assertions,
no setup refusal/crash/ABI mismatch. Their sources and final EXEs are retained.
The actual generated C separately verifies10 coherent working-value snapshots
and9 coherent formal snapshots; this is emitted-shape evidence, not additional
behavioral coverage of an unexercised effect point.

Terminal22378 pins are frozen in
build/codex_formal127_terminal_01.inputs.sha256, SHA256
06ECA8AC9FEF2045DBA6F665A48C94282B5A8D393FCF619243679E0B51DB059E.
All21127 upstream126 pins, unchanged source/header bytes, exact compiler,
all85 graph/C/object/EXE artifacts, actual170 observations,412/111/336 checks,
same412 old126 control and all four loss controls were independently verified.
All named workers are terminal. This receipt is not a full-gate certificate.

This is the native formal state producer/direct rebinding slice, not full
native argument transport. Ordinary generated outbound calls still send a
zero input Value span. The test explicitly supplies legitimate computed
inputs through the existing uniform9 channel; it does not prove their native
caller production. Numeric/foreign by-value ABI transport, named actual
formation, hidden/default-source production and held-callable remapping need
their common typed-value closure, not partial/back-end-specific metadata.

Raw initial/noncached graph places, cross-activation persistence, indirect
pointer/address mutation routes, pure field/index/cast producers and typed
copy relocation remain open. Only the direct formal mutation worker is closed
here; no claim that every alias/store can already update the companion is made.
In particular do not add a read-time native guard or a guess to hide a missing
general place/context store. The full goal still requires one consistent
resolved-place/value mechanism in every consumer.

Full112's1011 FAIL/3754,8 copy positives, complete path unification, clean
kernel, L3+L2 self-build and mail T01–T26 remain required. Goal ACTIVE.

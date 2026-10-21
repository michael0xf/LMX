# Private126: native working values retain computed CURRENT context

After baseline06c7c0fc. Codex sole writer/build; goal ACTIVE.
The old125 snapshot is immutable. Initial126 is build/codex_native_work_126;
the coherent payload/pair read refinement is build/codex_native_work_126b.
No public-dev promotion or full-gate acceptance is claimed here.

## Common working store/load and receiving worker

Every cached native pointer working value has an activation-local ordinary
LmxWalkValue companion. Initial raw graph-cell loads start unannotated; the
implementation does not guess Model from a pointer, layout or first admission.
The program graph's pointer-cell layout is unchanged.

The common l2_own_store wrapper calls l2_own_store_context. A computed annotated
replacement copies its own pair. Every unannotated replacement clears the
prior pair, including old raw callers of that same worker. Numeric stores
retain their existing behavior. The original single typed working-store worker
still performs the value write/dirty mark; no special mutation path is added.
The compiler source was inspected for emitted working-pointer writes: only
the common working-store worker writes them after prologue initialization.

l2_own_load_context uses the same own load and snapshots the CURRENT working
pair at that read. The126b refinement additionally materializes the payload
into the same result temporary; a delayed expression must not keep naming
mutable l2_q while carrying an earlier pair. Later assignment/publication
cannot change an already computed result. It introduces no resolver,
L2Tx tag, runtime address lookup or global current-call state.

Reference declarations, pointer rebinding and callable-result binding pass the
computed pair to the common store. The existing l2_emit_reference_value_at
entry point wraps the same context-aware worker. That worker also CONSUMES
the giving pair even when its caller discards the optional output: a typed
receiving consumer must not fall back to raw just because it needs only text.
The same bound receiving record / lmx_walk_value_admit operation publishes
the receiver's proven pair, then the same admitted materialized value is stored.
Asserted-Model followed by receiving-Model admission uses the same pair chain;
there is no asserted-type shortcut through candidate history.

Only the two Model/reference-sheet fields travel in these native output
companions. The ordinary raw payload remains the same typed machine local.
No new graph field, fat-pointer program ABI, opcode or shared receiving-record
mutation is introduced. Runtime/headers/Value layout/uniform9 ABI are unchanged.

## Initial and refined executed evidence

Initial126 source341E4E2534CFF6C30579F8BB2D0ABCA90068FEB0D055B2131018A00A8D06521F,
frontend C29FC7989457A3D7E62757A7B161FD98E8CD551E6FDFC60C176D6191F13F0CD30,
frontend EXE549957C01F529265E14C03F6F4B1730A74358E45AC4B0E24D467C8A9EEDDC32F.
Test02 executes288/0 O2/fstrict assertions against real L2/L1-generated native
bodies and exact122 production runtime. The same288 fixture/source freshly
generated with unchanged125 gives124 assertion failures, exit1, no crash or
ABI mismatch.

The93 earlier assertions and125's actual call-result cases remain; the new
cases add universal working forwarding, receiving after a working load,
rebinding, a checkpoint call, unannotated replacement, declared R working
receiving/rebinding, and copying a local before clearing the original.
D/E is selected at runtime by the same explicit foreign test service and
actual generated native producers. It gives real7/9, writes41 and addresses43
with the other field unchanged, native-C consumers and real walked CALL into
the generated native receiver followed by walked OF/PUT/ADDRESS.

Malformed present pairs survive working transport and are refused by receiving,
not erased/rescued from raw history. Present-null retains E/sheet through
working forwarding and is admitted as R/sheet. A copied local keeps its own
pair after the original is cleared. The checkpoint case performs a second
independent native call with a fresh candidate; the first local must retain
its original value/pair rather than consult a global last result.
Each written source act is counted separately; the rebinding/checkpoint methods
deliberately have two acts, not one evaluation of a single expression twice.

The native write/address oracle is a C consumer of the actual native result;
deep source-native paths retain their separate matrix coverage. This is not
proof that every native path/formal/copy producer is closed.

The initial288 witness C is9FD5A356560C44CCF8E9DE612284F484E932B83B707B44B073078FE3168C23CE;
L2 source202A92673414285307E621A7CC971DA3AA2F40B77116F08330DDEE7E9597F759.
The already published native_call125_test.h helper is unchanged.
Initial Source/CHECK profiles336/0 and unchanged124 L2/test111/0 are freshly
compiled/executed. Initial matrix01/session95512, child PID8960, startUTC
2026-10-21T13:11:09.7375542Z is TERMINAL0:85 freshly L2/L1/C/GCC/link units,
actual170 observations,162 GREEN and8 unchanged old copy RED/exits.

Final126b build02/test03 freshly executes the SAME288 fixture,288/0. The C
fixture's CALL125_SOURCE macro explicitly selects probe03 generated C in the
recorded compiler argv; its default include path is not used in that run.
All9 generated working-context reads were inspected and mechanically checked:
the same numbered raw-pointer temporary is materialized immediately before
its Value context is initialized/copied from the same working row. This
emitted-shape check is not an additional behavioral effect-point witness.

| Final input | SHA256 |
| --- | --- |
| compiler source126b | CE084377C105056B929D8A4B2136938D942229A1C412E2A00DBA781FC3363314 |
| frontend C build02 | 30446E0E2AB9FA566B6D52FCE312EC8880815B86B25CF5997D5E2017D15BA397 |
| frontend EXE | 180CBFCE08FC93EDD6A12815689CC339E5F3AE4942A2CB38BB213BFFF2227A9E |
| witness generated C probe03 | BA6E1613DD7FDA65E1A0A58090B20F82D709574564ACBA49A1426C394BE2840A |
| exact125→126b source patch | 3B86CD0F7D8E5F4F2F7540D230E06CBCABA50DB5DCA14D5C5914A02667A9D3F1 |

The [source patch](witnesses/used-scope-20261020/native-working126-u0.patch)
applies to exact125 with git apply --unidiff-zero --check -p0 and changes only
src/l2src/l2trans.lm1. The [executed L2 source](witnesses/used-scope-20261020/native-working126-probe.lm2)
and [same288 assertions](witnesses/used-scope-20261020/native-working126-test.c)
are copied byte-for-byte from the tested inputs. The [explicit foreign helper](witnesses/used-scope-20261020/native_call125_test.h)
is exact125, SHA C775B0D788F9EC242726D7E6B1B570E1B2CC6971EEBDD09A0AE0CAFD5ABB3382.

Final metadata02 freshly compiles against the final frontend C and executes336/0
unchanged Source/CHECK assertions. The unchanged124 L2/111 fixture is also
freshly L2/L1/GCC/link/run through final126b,111/0.

Three generated-C controls execute the IDENTICAL288 fixture/runtime:
erase30 working-store pair fields gives84 FAIL; erase18 working-load pair fields
gives84 FAIL; skip only2 replacement clears gives2 FAIL. Prologue initialization
is preserved in the last control, so it does not read uninitialized records.
All exit1 by assertions, no crash/setup/ABI mismatch. Mutants01 is only a
prepared unexecuted recipe for the initial126 C; results are from mutants02.

Final values02/session78014, child PID17160, startUTC
2026-10-21T13:16:06.1389470Z is TERMINAL0. All85 units are freshly
L2/L1/C/GCC O2/fstrict COMPILE/LINK; actual170 observations give162 GREEN
and8 unchanged old copy RED/exits. No old unit object or EXE is reused;
only exact122 runtime and unchanged libc56 objects are reused.350 named
input pins, actual native binding counts, root modes and --walk-methods
are preserved. Historical provenance remains14 byte aliases and5 exact118
graph reconstructions; the historical source bytes of those5 are not proved.

Terminal21127 pins are frozen in
build/codex_work126_terminal_01.inputs.sha256, SHA256
B274EA5DEDEFE1D7AE46913E80993EA30E4934B23726F1CDC421355857E97A8C.
All18654 upstream125 pins, unchanged source/header bytes, exact final compiler,
all final85 graph/C/object/EXE artifacts, actual170 observations,288/111/336
checks and same288 old/loss controls were independently reverified. All named
workers are terminal. The raw payload snapshots are checked in the actual final
generated C, not inferred merely from source helper names or green counts.

## Preserved attempts and remaining work

Test01 incorrectly expected one service act from the newly added methods
that intentionally contain two distinct source calls. Its220/16 failures
on126 are preserved. Test02 fixes only those new counters and extends the
witness; the earlier125 one-act oracles stay unchanged. The initial old125
220 test also contains those bad counters and is not the clean semantic
counterfactual; old02 freshly executes the corrected same288 assertions.

The coherent payload snapshot was added before publication, not left as a
consumer obligation. Initial126 and final126b are separate immutable snapshots;
no source/header input was edited under the initial running pipeline. Both
initial and final288 executions are retained. No full kernel gate is claimed.

Formal/default/rebinding producers, outbound actual spans, raw initial-cell
context, noncached places, pure field/index producers, pointer casts,
held-callable remapping, cross-activation persistence and typed copy relocation
remain open. This slice must not label a raw initial value using merely the
receiving type or the caller's immutable input snapshot. Full112's1011 FAIL/3754,
the8 copy positives, full path unification, clean kernel, L3+L2 self-build and
mail T01–T26 remain required.

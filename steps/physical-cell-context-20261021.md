# Owned pointer-cell current context — 2026-10-21

## State and exact baseline

Private dependency slice131, baseline main 9cfdcd0ce1780b2d5fef54bba595b6311c7940d1
and build/codex_value_place_130c. Final source snapshot:
build/codex_value_cell_131b. Public dev remains compiler56/runtime69/reader76.
This is implemented/tested private code, NOT a new language rule, a complete
path-consumer certificate, a full kernel gate or a self-built generation.

The nine-source exact130c→131b patch is
[witness](witnesses/used-scope-20261020/physical-cell131-u0.patch);
[executed source](witnesses/used-scope-20261020/physical-cell131-probe-final.lm2) and
[executed fixture](witnesses/used-scope-20261020/physical-cell131-test-final.c) match
the final LM2/C input bytes. The fixture requires PLACE130_SOURCE selecting
build/codex_cell131_probe_11/unit.c. Its historic default include is not that
unit. Build-local inherited fixture dependencies remain pinned by the receipt.

## Mechanism, not a Model lookup

An owned typed pointer pool now allocates one complete-context companion per
physical cell, in trailing storage of its chunk record. The existing arena
index proves the exact pool, its chunk and live cell ordinal. That ordinal
selects the cell's actual stored state. There is NO address→candidate-Model
registry, layout/prototype/history inference, copied graph, new graph field,
source-name dispatch or opcode. A pool still serves a pointer domain, not
each source Structure. The historic LmxWalkValue record is now declared with
the shared pool types; its payload/context layout is unchanged from130.

The physical T * cells keep their original stride and exact C99 pointer
read/write callbacks. A companion is not inserted into their backing and
does not turn a real T ** into void **. LmxChunk layout changes, so the
runtime AND all test/unit objects were rebuilt. Uniform9 and generated typed
body signatures do not change. Only pinned libc56 was reused: its1358-byte
source does not access these records.

lmx_pointer_cell_context obtains CURRENT state of an existing exact live
pointer cell, not a Model chosen from that cell's declaration. The shared
lmx_pointer_store_context_in snapshots the supplied complete context before
the physical write, then publishes it only after a successful callback.
An ordinary raw lmx_pointer_store_in calls the SAME store with absent
context; even a SAME-address replacement clears the old state. A present
null with explicitly supplied Model/sheet keeps that explicit state.
Neither helper performs a fresh implements admission.

The common walker value load and resolved-place load/store use this cell
owner. ADDRESS binds the already resolved cell owner; DEREF also obtains
its state from a proven physical pointer pool when the held raw address has
no activation binding. No container-record subtraction or guessed Model
is used. Existing ARG-owned values remain explicit owners. AT/OF/ELEM
reach this SAME physical load/store after their existing path resolution.

Working entry snapshots the cell's current context. Publication writes the
ready payload plus that context, without evaluating/admitting it again.
Native working entry, ordinary noncached own stores and the SAME native
publication emitter use these backend-neutral pool/value operations.
This closes those boundaries, not every native path producer.

GC follows the current stored Model, reference sheet and explicit referent
binding beside a live pointer cell's ordinary held address. Companion
storage has the same block lifecycle as its chunk record: rollback/drop/
attach do not invent another owner or leave a separate metadata allocation.
The first chunk shares a record allocation with its retained pool descriptor,
as before; this is not a promise that every metadata byte is freed when its
payload alone is swept. Replaced Model/sheet dependencies cease to be roots.
Address escape/lifetime and arbitrary foreign aliases are NOT closed here.

## Actual behavior and loss controls

Final build02 + probe11:4555 checks,0 failures. This includes all unchanged130
3243 checks and1312 additional assertions. Separate inherited profiles overlap;
their counts must not be added as independent new cases.

New physical-cell cases cover canonical void * and genuine Lmx * callback
objects, AT/OF and a typed Array element at index1, a fresh frame without a
working cache, working entry/assignment/publication, D↔E views of SAME or
different raw values, present-null and unannotated SAME-address replacement.
Values traverse the ordinary generated echoFormal body by direct native call
and real walked CALL. Receiving applies the reordered implements map to actual
7/9; mapped mutation observes41, taken-address mutation observes43 and preserves
the neighbor. ADDRESS of the pointer cell is stored/reloaded; dereference with
and without its explicit binding reads the cell's same CURRENT state.

The two new full-form methods use an explicit var part. Their native working
entry and publication are tested directly and through walked CALL, including
a SAME-payload D↔E change, then a fresh receiving/map read of actual7/9.
First and grown pointer chunks are separately tested across rollback, attach,
GC with a null payload whose only Model/sheet roots are the stored context,
raw clearing and a subsequent collection of the replaced dependencies.

SAME final4555 through the old130 compiler, matching old runtime and headers,
gives748 assertion FAIL,exit1. No mixed-layout objects or setup failure are
used as that baseline.

Four final-layout loss controls run the SAME4555 assertions:

| Removed dependency | Generated mutations | Assertion FAIL |
| --- | ---: | ---: |
| Shared physical context publication | 1 | 748 |
| GC current-context edges | 3 | 2 |
| Native working entry context load | 23 | 4 |
| Native ready-value context publication | 145 | 6 |

All compile/link successfully and exit1 by assertions, not a crash/refusal.
Final control inputs/results are build/codex_cell131_controls_03/.

Fresh matrix01 has85 L2/L1/C/GCC-O2-strict-aliasing/link builds with a newly
compiled normal runtime and170 actual executions:162 prior GREEN,8 unchanged
copy RED with the same exits. The337 unchanged input pins, native-binding
counts and root modes are preserved. Session30531/PID8492,
startUTC2026-10-21T15:10:07.8161782Z, terminal0.

Verification02/session76713 is terminal0. Fresh standalone kernel profiles
62/57+20/789/54/48 pass, including the backend-neutral helper without walker
implementation. Fresh unchanged hidden129/408,formal127/412,actual128/311 and
result124/111 pass. Foreign aggregate/enum bodies remain native-only; four
actual root-mode runs pass13/17. Thirteen source-linked compiler profiles
give336/0. These are regression runs, not language-owned self-builds.

## Preserved unsuccessful preparations

The original4227-case fixture used an int index where the walk ABI requires
size_t:old130 gives648 FAIL,initial131 gives304. With the correct typed index,
SAME corrected4227 gives516 FAIL on130 and0 on131. No value/map oracle changed.

The expanded fixture first lacked the GC header, then selected the empty var
part of a method whose local declaration was actually in body. The new full
var source uses @(void) so the return type cannot consume the var argument.
A zero-actual CALL was initially allocated with one extra null-actual slot:
probe07 gives4267/2; width5 in probe08 gives4267/0. The address expansion then
had a duplicate C local name; the final fixture only corrects that identifier.
Control01 had a generator replacement-string interpolation error and did not
compile; control02 supplies the actual same-layout negative evidence.
These failed preparations are retained, not counted as valid negative controls.

## Exact bytes and remaining obligations

build/codex_cell131_final_02.json records all23 final source/header/compiler/
runtime/fixture/patch identities. Important SHA256 values:

- l2trans.lm1: EA17D137919BF5A4C8C64CBC2BB5F528E4AEBF8469D657835A5D3E8272B41AD1
- lmx_walk.lm1: B56F24CE8F44560B13978C30DB1B52359DF885234DE2FC65085EC3FB13B569D9
- lmx.h.lm1: 14E44C745CDE1C4389E73308946208F485631A27708BF80733024576380BF96C
- frontend C: BBFD396475148874C31F00BF8858CB09B90A943978AC03AA7FFFE2784B3F07AF
- compiler EXE: F57833434FB7CDE11A87594B71E64D26D065B1B5E6390714DFD29FAA1DAC7BDF
- runtime C: 603EC5A73C35AE07F5881981041A87982FDCDCDC2DDE135F3F7B293AE5B9259D
- renamed runtime object: F77B95E7656DCEE244BB964EDE61BAC686A3A3D379186037029C59A3E6FFCF4A
- final target C: 0ACDF9CE290CBB7993951D10421371BBE1586A219362043379005753F02C4A4F
- patch: E5CA25F171BE3246876310545251D586AC07248F71DDBDBB401884FBF075C827
- fixture: A914CB8E3F60C220D2D8E2522EF2818B0013AFA14686B6276F2470E0D2A1F0E8
- LM2: 4321D84BF2028D4534B21348A1CF1F1898CC0146C6A8A93459B2A7A4BF80C687

The initial receipt is build/codex_cell131_terminal_01.inputs.sha256:
29600 pins,SHA256 9848FB7C7F97D2A25F11E7FEA06403A466905BB37B77DBEBAAFD7DB8B28E25A3.
All27868 upstream130 pins,unchanged inputs,23 final byte identities,matrix
commands/runs and named actual outcomes were independently verified.
The staged diff check then found whitespace in the initial fixture copies.
They and their byte pins remain unchanged at the original paths,locally
excluded from Git. Clean final witnesses use separate names. Fresh probe11
and old04 repeat4555/0 and4555/748 on those exact cleaned inputs;generated
target C is BYTE-IDENTICAL to probe10. Controls03 repeat the same failures;
their mutated C bytes match controls02. This is formatting,not changed oracles.
The final extension receipt is build/codex_cell131_terminal_02.inputs.sha256.
It has29646 pins,SHA256 E72854C6B98AB710350A9B6AA6F5665D9E7C1045EF79DBA67F9AB1A0FE9D8760.
All29600 earlier131 pins and new final inputs/actual outcomes were reverified;
the staged documentation check passes7076 tracked files. All workers terminal.
Recipes under build/ use prefix codex_cell131_:build_02,test_11,
old_04,controls_03,values_01,verify_02,publish_01,terminal_02. Some copied
console labels retain historical numbers; the inspected paths,byte hashes,
actual assertion strings and receipt,not those labels,identify this slice.

Direct Structure/Array slots and caller-owned unaccompanied chunks remain
outside this persisted owned-pointer-cell mechanism. Native field/index/
indirect producer coverage, raw/foreign C aliases, formal/capture/default
persistence, graph-copy relocation of context and address escape/lifetime
still need common closure. A correct snapshot here does NOT certify all
native mixed paths or force native stores to carry context where they still
emit a raw machine assignment. No fallback read guard replaces that work.

The8 copy observations remain RED;full112 remains1011 FAIL/3754. Clean
kernel closure, all path consumers, genuine L3+L2 self-build and T01–T26
remain OPEN. Existing scope/provenance limits of the85-case inventory also
remain:14 byte aliases and5 exact118 graph reconstructions are not historical
source-byte proofs. Nothing here is a self-built generation or final §8/8a.

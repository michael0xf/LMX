# Native consumers of the shared physical place/value store — private134

Dependency: main ff458b0e (common runtime store133). This is a verified private
consumer slice,not a clean-kernel or self-build gate. Final candidate source:
build/codex_native_store_134h; compiler build/codex_store134_build_12.
Do not mix it with the frozen134A..134g attempts.

## Mechanism

Explicit indirect assignment retains the complete parsed receiver in the
existing compiler L2Address. CHECK, the walker's COUNT/EMIT and native consume
the same location/type result. The native target and explicit owner are
frozen before the RHS. Native pointer assignments, working cells and formals
call the common133 lmx_value_cell_store; owned field stores pass the already
selected physical cell. Unowned automatic C cells supply an exact accessor
for their actual closed C type. Only demanded accessor definitions are emitted:
foreign interner entries also include C callee names, which are not C types.
There is no new runtime registry, graph field, opcode or Model inference.

lmx_value_array_place is the shared physical Array selector for native and
the walker's ELEM/ELEMPUT. It receives an evaluated descriptor and index,
returns address/type/context, and shares bounds, stride and owned-pool
validation. Native reads consume the resulting place through place_load;
writes create one ready giving Value and consume it through value_store.
The existing executable-write barrier is retained on this same physical cell
before the RHS; changing the representation must not drop qualification checks.
An INDEX freezes its descriptor before evaluating the index. The same path
cursor also returns the final field place when a path ends in NAME after
one or more indices. Its selected receiving Model is retained before the RHS.
No consumer searches that field again after this cursor result.

Address-of consumes the general adapter's complete names/indices record,
not its historical names-only view. It returns the cursor's physical cell,
not the address of a loaded temporary. A pointer's legacy return ABI spelling
is projected to the same closed consumed-value/witness type as its declaration,
input and address. The existing core pointer table is shared for that projection;
runtime type equality and c.-door/qualification distinctions are not relaxed.

Explicit referent context is valid only for its addressed cell: the common
selector requires a non-null cell and address.ref == cell. It cannot propagate
one cell's owner across an index/offset into another. Native per-pointer-step
Values now carry the actual held ref as well as context, preserving this
identity check rather than asking the selector to trust metadata-only records.

L2Address additions are compiler-only. Value/Place/chunk/uniform9 runtime
layouts are unchanged.

## Witnesses and intermediate failures

The unchanged source133 indirect-write witness is now GREEN48/0 in native
and forced walker; published133 was native48/24 versus walker48/0.
The source132 read focus remains4747/0, and true typed C-pointer depths2/6/18
remain2310/0 per actual engine on final134h.

New [source](witnesses/used-scope-20261020/native-place-store134-probe.lm2) adds ordinary field/Array
write, independent read and address functions. The valid second C fixture
proves36/0 per engine, including persisted CURRENT state at the SAME raw
payload, actual reordered7/9 values after receiving, and writing back through
the returned physical address. The stronger published
[fixture](witnesses/used-scope-20261020/native-place-store134-test.c) moves every
root field,including the Array descriptor: map3,4,0,2,1 and its LAST half.
Final profile places_final_01 repeats36/0 per engine from the published files.

The initial C fixture supplied competing accessors for one canonical void*
pool, then attempted the canonical field constructor. That preparation refused
before assertions; it was NOT a valid behavior RED or a program-builder defect.
Fixture02 uses the normal constructors and the actual five-slot Model layout.
The source program builder itself succeeded. Neither source values nor
assertion oracles were weakened.

Intermediate real failures were retained: the mixed hidden/indexed program
returned83 instead of7 because @ addressed a read temporary; the new walker
witness rejected a legacy return-witness type-id mismatch; and mixed paths
ending in a field after an index emitted an empty place. The fixes are in the
complete address adapter, consumed-type projection and common cursor, not
new source-case branches or changed positive expectations. Build05 also
caught L1 dotted-call/prototype errors; earlier attempted generated accessors
for all foreign entries did not compile. Such failures are not assertion RED.

The final audit also caught a dropped native Array write barrier. The
[source](witnesses/used-scope-20261020/native-place-write-barrier134-probe.lm2)
and [C physical-contract fixture](witnesses/used-scope-20261020/native-place-write-barrier134-test.c)
isolate the actual indexed writer over a prepared mapped input and a profiled
Array. The old134f native writer changes a sealed cell7→9: that observation
is policy RED,not a successful qualification test. Final134h native and walker
abort INVALID before the write and preserve7; mutable controls actually write9
and preserve neighbor3. Eight runs have six completed state assertions each.
SIGABRT interception exists only in this C invariant fixture,followed by _Exit;
it is not a language catch or a claim of normally unwound aborted frames.
A separate whole-language immutable-merge attempt stops in qualification
preflight before reaching the writer and is not used as barrier evidence.
Its first link/main-alias and incorrect Model-width C preparations likewise
provide no behavioral assertion RED.

[Source-linked closed-type checks](witnesses/used-scope-20261020/pointer-value-type134-test.c)
are58/0 on the actual final frontend C: all six builtin pointer bases at depths1/2,
legacy ABI-to-value projection,c.-door and qualification distinction,aggregates,
char ABI adapters and missing-argument preconditions. Greater depths retain
the existing unbounded closed type interner; the builtin table is not a depth cap.

## Final evidence and reproduction

verify_final_01/session53357 and verify_tail_01/session92024 TERMINAL0.
Fresh values_final_01 worker3936,startUTC2026-10-21T18:09:11.9638320Z:
85 fresh L2/L1/C/GCC/link units,170 actual runs,162GREEN+8 unchanged copyRED.
Actual native bindings,modes,counts and exits are preserved;341 selected parent
pins checked. Source-linked metadata336 and four fresh foreign runs13/17 pass.
The foreign links use the NEW matrix runtime object,not an old baseline object.

Build12 recompiles the frontend but reuses the exact verified134f runtime object
after proving generated runtime C identical. The matrix separately compiles a
fresh runtime object from that C. All non-compiler sources and headers134h/134f
are byte-identical. Final hidden/formal/actual/result units were freshly
re-emitted and match exactly the completed134f C bodies for408/412/311/111;
those actual runs are inherited by identity,not falsely reported as new134h runs.
The same runtime also has completed25/0 common-store and kernel62/57+20/789/54/48
focuses. Same25 common-store loss controls fail5/4/9/13 assertions,exit1.

Final source/C fixture loss controls recompile the SAME published final unit C,
not the earlier build-path unit with a different namespace hash. Removing giving
context only in the common store produces22 completed assertion FAIL of the same36
in EACH engine,exit1. No preparation error,INVALID or crash is counted as this RED.
places_controls_final_01/session49743 TERMINAL0.

The [six-source U0 patch](witnesses/used-scope-20261020/native-place-store134-u0.patch)
applies with git apply --unidiff-zero -p0 over source133. Replay02 reconstructs
all six changed source files byte-for-byte. Regenerate l2_application and the
existing runtime headers before L1→C. Actual commands remain in the named build,
verify,values and focused PowerShell recipes under build/;these are transitional
evidence tools,not the language-owned build required by §8.
Compiler is C99/O0,runtime and value units O2/fstrict-aliasing,with the existing
strict implicit-function/int,incompatible-pointer and discarded-qualifier errors;
one GCC pipeline,not concurrent builds.

Final identities:

```text
compiler source E4960F150A76759BD8E02C8999868A61F5BBB5F49D69944E05A552B2A77F6685
frontend C      99EB6EBFD2F06BBBCAD4DA5CF1FD677EACA55861E029FD32DB7B3E31C4295E99
frontend EXE    7C24C2001633DBA248D1DB02A44C5C407C10938914FA775FF0D1D5B28E49644A
runtime C       471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
reused runtime  3B207E91F6E1A2BA085D2126BD3DCBD8DCEE7C6121C8E8A4BD2C158EBD72176B
matrix runtime  36067E52937238C70EA8405CB4104D8D6552C17CD7830AADD9B3429588F32683
six-source U0   6837CDF224F4EB739752F71A2647942D5E314A797E51A90C2D5DBD7F78CF4205
published probe B58A9098366CD84963B1BEA40CC422C85C60456C8A970378F511244257F3438F
published test  6943575FCA234AEDC458BD6256B94570B63798AE47F90DF8D68A903D1881FA3E
```

terminal_01 has1892 pins,SHA256
01DE93D01ADC4FA77D6B0CAEC92C3E856ABC84BE4287DC208DAFD0E2BAD20DA3.
Parent133 and parent132 receipt digests are pinned;this is NOT a rehash of all31074
historical132 files. The include scan follows selected C/header edges,not the build
tree. It conservatively reports unresolved decNumber.h;system-header and complete
preprocessing/toolchain closure are not certified. Actual compiles above succeeded.
Both documentation generators passed;staged check_docs validated all7096 tracked
files and their LF endings. git diff --cached --check passed. Only the listed
slice artifacts/current-state note are staged;unrelated WIP is not included.

## Remaining boundaries

This is a physical-place/value consumer slice, not proof that every source
path consumer uses one complete retained resolution. Raw-C indexing still
re-parses in l2_emit_index_place and its consumer. Legacy atom dereference
typing/read/walker helpers remain. Removal of all alternate source readers,
per-step map provenance across every consumer and arbitrary unowned foreign
cell/accessor lifetime remain OPEN. No blanket C99 aliasing closure is claimed
for pointer producers not covered by exact C objects/accessors.

Native address context for unowned/escaping automatic storage and qualified-index
effect-order coverage are also not closed by these owned-cell witnesses.
The public dev baseline,the last full1121011 FAIL/3754,eight positive-copy RED
observations, clean-kernel closure, real L3/L2 self-build generations and mail
T01–T26 remain OPEN. A private slice is not a release or completion of §§8/8a.

The goal was unexpectedly BLOCKED at this heartbeat and was actually restored
through the existing status-only app-server client under the author's standing
resume instruction. get_goal confirms ACTIVE,with the original objective,
createdAt and usage preserved. No replacement goal or new hourly timer was created.

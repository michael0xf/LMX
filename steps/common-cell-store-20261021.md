# Common physical pointer-value store — private133, 2026-10-21

Dependency after main de7e6c3e. Source snapshot:
build/codex_value_store_133;fresh compiler/runtime:
build/codex_store133_build_01. This is shared runtime preparation for the
[measured native indirect-write defect](native-indirect-write-20261021.md),
NOT a claim that the generated native write consumers already use it.
No compiler source or Value/Work/Place/chunk/uniform9 ABI layout changed.
Public dev and the full clean-kernel/self-build/mail status remain unchanged.

## One operation,not a native guard

lmx_value_cell_store is in the existing value-owned module. It consumes an
already selected physical cell,an explicitly resolved live owner if any,
the raw giving value,its complete CURRENT context,and an exact physical
accessor supplied by a native C producer when storage is not arena-owned.
It does not parse a path,choose a field,look up an implements candidate,
infer Model from layout/history,or run another admission.

For an owned cell,the existing pool's exact C accessor is authoritative;
a competing supplied native writer cannot override it. For an unowned C
object,the producer must provide its exact accessor:absence is an error,
not permission to guess a void* object or cast an unrelated T** to void**.
The operation snapshots all CURRENT context components before its single
physical store. Only success publishes that snapshot to the actual pool
companion and,if distinct,the explicit resolved owner. Raw replacement
clears all prior state even when the raw address stays unchanged.

The old contextual/raw pointer-pool APIs delegate to this operation while
preserving their owned-pool precondition. The walker's resolved pointer
place store delegates too,including canonical explicit activation storage.
Its previous duplicate context-publication branches were removed. Scalar
and descriptor writes retain their existing semantics. No new runtime
registry,graph field,opcode,per-Structure pool or second resolver was added.

## Exact C object focus

The valid fixture is build/codex_store133_kernel_test_02.c. Its published
copy [common-cell-store133-test.c](witnesses/used-scope-20261020/common-cell-store133-test.c)
is byte-identical,SHA256
E502AD5CE66F0A1D97B5806012F4190FB7914AA951752F7D6E71FE56EF6FA1B8.
It requires CELL133_SOURCE explicitly. The source program for compilation
is the unchanged published indirect-value132-probe.lm2.

Actual25/0 covers true struct token* objects and their struct token**
addresses,actual void* storage,owned typed pointer pools,one accessor call,
failure with no context publication,competing-writer rejection,raw SAME
replacement,present-null,whole context components,input-owner aliasing,
pool companion/explicit owner aliasing and a distinct explicit owner.
The existing raw/contextual pool and walker place APIs are exercised,not
just direct calls of the new function. This is a physical/context operation
focus,not generated native field/index/write or mixed-path conformance.

The initial fixture01 counted constructor initialization as an executable
store and made its deliberately failing accessor reject pool construction.
Its process stopped before the summary:that preparation is NOT a valid
behavioral RED control. Fixture02 explicitly checks constructor initialization,
isolates subsequent store counters and enables failure only after a live
cell exists. It does not weaken a successful write/context oracle.
Kernel02 is25/0;final01 repeats25/0 from the published fixture and source,
with generated unit C byte-identical to kernel02.

## Current evidence and remaining consumers

Fresh values01/session66765,worker17480,startUTC2026-10-21T16:38:35.6523756Z,
is terminal0:85 freshly translated/compiled/linked units,new133 runtime,
170 actual runs=162 prior GREEN+8 unchanged copy RED. All346 unchanged
selected input pins,native-binding counts,root modes and exits are preserved.
These are regression snapshots,not self-built generations.

Important SHA256:

- value-owned source:EFE8AF7A3E297116459FC9D60C137B1440518BAEF2AB2E0D727E3BCC49E0C377
- value-owned header source:CB1F6FE14207168DD34AEED54151F12FC7FCA01E0698934BF3C28D11D52A8A84
- walker source:7522DC1AF81864A6773AB89ECEA374969B32E363B237E9BEEB0B7C8D9CFB1F3B
- compiler source:unchanged132288D0899...
- frontend C:byte-identical132 F2806CE4D3203744FF2326C76402E87FF91DD1559E7B46354589053BB53C2C92
- compiler EXE:30372147E872162BFF1BDC770713F1AD9A9308819649540F8468552A395D9EE1
- runtime C:B3A31FBC9D9ACEB3A71328AC9F352BA9558D71430CB0CC6CE2024A054FE87709
- renamed runtime object:A70EAFC6490DC1D7AF7EB4E7F99019A4A0EDFB42FFD80D5B2A1AD4402EE8DA10

Verification02/session69111 is terminal0. SAME25 controls02 each change
one site in the actual common-store function:drop pool context5 FAIL,drop
explicit-owner publication4,drop giving context9,drop pool accessor13.
All strictly compile/link and exit1 by assertions,not a crash or setup error.
Controls01 completed its first two controls but stopped before the third
because an unscoped generator pattern matched two different functions.
Controls02 scopes the SAME intended function;it changes no behavioral oracle.

Fresh inherited read4747/0 and deep2310/0 per native/forced-walker profile
pass. Fresh source-write baseline stays48/24 native,48/0 forced walker:
the new core has not silently repaired a returned value while leaving
the physical store wrong. Newly translated standalone kernel profiles
62/57+20/789/54/48,unchanged hidden408/formal412/actual311/result111,
four foreign13/17 runs with the NEW133 runtime,and source-linked336 all
pass. They do not close the remaining native consumers or full gate.

Bounded terminal receipt build/codex_store133_terminal_01.inputs.sha256:
1399 pins,SHA256
80EEAE82175C2E3EB1D412EDF0594A1E48BA641C058E611DD4BA9EB0927BB3CB.
It pins final source/header/recipe/fixture/build bytes and observed results;
the fresh matrix verifies346 selected unchanged inputs. It verifies the
chain digests of the132 receipt and source133 baseline receipt,NOT a new
rehash of all31074 historical132 files. All named133 workers are terminal.
Both documentation generators and check_docs pass;staged diff is checked
before publication. No source success is inferred from an ACK or intent.

The exact three-source132→133 patch is
[common-cell-store133-u0.patch](witnesses/used-scope-20261020/common-cell-store133-u0.patch);
it passes git apply --unidiff-zero --check -p0 against the exact132 snapshot.

Generated native field/index/indirect writes still need a projection of the
complete resolved Value/Place record into this SAME operation. Working and
formal native cells must preserve their activation/dirty/publication rules;
descriptor slots are not pointer-value cells. Reuse exact typed C accessors
already required for pointer Array/pool storage rather than adding another
physical pointer ABI. Freeze target address/owner and complete giving value
before later effects,store once,and apply CURRENT maps/types at each step.
The walker's existing unowned canonical transport accessor is not proof of
an arbitrary foreign C cell's ABI. Propagating producer-proven accessors
through Value/Place for those unowned addresses remains OPEN;this core API
and its exact-C focus do not certify that old fallback for every pointer.

The retained L2HeadExpression/P0 adapter must replace old compact-prefix
root/suffix cutting across CHECK,COUNT,EMIT,native and walker. Native and
walker must consume the same retained typed path result,not reparse after
the adapter or rediscover fields/references/indices. The existing legacy
l2_prefix_deref and native raw field/index store routes remain OPEN;this
helper's presence is not evidence that those routes were removed.
The source13348-check witness remains required as is;no RETURN-only repair
or native guard may replace persisted-cell and actual mapped-value checks.
Deep mixed-path native writes/address-taking,copy/default/capture/lifetime,
all8 copy RED,full1121011/3754 and §§8/8a remain OPEN. Goal stays ACTIVE.

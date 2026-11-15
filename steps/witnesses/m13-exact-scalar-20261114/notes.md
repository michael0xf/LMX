# M11.7/M13: exact scalar storage, slice394

2026-11-14. Base393 `328012416dd2d6349be15bb6e532a430e61c0d62`, main.
Goal remains ACTIVE. This is implementation evidence for the bounded C ABI foundation;
ordinary typed construction/Run/receiving/FFI and the full v3 remain OPEN.

## Source and representation

The existing primitive-profile exporter selects32 scalar rows from the current35 source rows.
It emits26 distinct C access contracts, sharing identical C spellings only at the physical ABI layer.
The complete raw source descriptions remain distinct. None/void have no cells; FILE is opaque
and receives no guessed scalar ABI, zero resource or pointer depth.

`LmxScalarABI {size, init, copy}` belongs to the existing typed pool key. The existing FOREIGN
Value carries owned storage plus explicit scalar ABI, physical profile and source description;
these do not replace its Model, references or referent. Physical family40 is not a source-row id.
The ordinary Graph.kind fallback still gives0 for this family; typed Source facts inspect proven
metadata first. Public primitive-name resolution and ordinary working-value integration are separate
required tasks in the [main v3](../../../next_core_tasks_v3.md#flat-lmx-descriptor).

Mutable capture/load/materialize preserves an exact owned C object. Immutable materialization keeps
its physical identity and qualification. Known source-pool ABI/stride mismatch is refused before copy.
The raw allocator creates no current Value: its existing `present` stays0. Load/copy preserve absence
without reading source payload, while metadata and actual pool.profile remain GC edges. The common
copy map relocates companions and graph metadata; an unowned nonzero referent refuses UNSUPPORTED.
Mapping these raw-storage facts to written declarations remains part of the open construction bridge.

Source aliases live in a generated declaration-only header; callbacks live in the executable profile.
The maintained L2 backend now recognizes fundamental C99 signed/_Bool in type declarations.
All L1/C artifacts are generated; there is no maintained L1/C test or alternate runner.

## Pipeline and private gates

Pipeline: `build2/codex_fix250generationchain01/runs/sol-m13-exact-storage-20261114-01`.
Stage: `build2/codex_fix250generationchain01/sol-m11-construction-fresh01`.
Source16:925, SHA256 `d51d54df08a3144fb5c2c9fc7c1f4656743fe4dd06acbdec9ae64ac7281b3034`.
Canonical manifest equals this frozen source; verify925 PASS.

The old-ABI host uses preserved393 consumed-inputs in `stage/abi-bridge393`. This is an artifact
directory under the main checkout, not a git worktree. Frontend05 reuses Frontend04's unchanged exe
SHA `015aa50eb2a3e056d143ccccfed7789473235c9ebcc7f5dfe49f576abdef1fc9`; its changed backend is
SHA `8e938cf166bf3f9e231c9accad25df10871c699ff35ddd7019fe3db99cb87edc`.
Tool bridge04 SHA `e5fa9dd403b35cba75165af962f49b619a117f65d47e8287ed0de285489a1fb8`.
Its selftest01 PASS, including15 malformed schema controls.

Runtime11 prod SHA `664a7d415e7e96810575261fe6dcae53d165601f4edc464a365edc4676741990`, observe
SHA `3884ac55eba888a93551efc0ec79670dc0d2fdef20360213f069130e607540bc`. Unchanged generated modules
were reused after located translation/compiler failures; only changed modules and the final aggregate were rebuilt.

The maintained [exact_scalar_storage unit](../../../selfbuild/tests/dyn/exact_scalar_storage.lm2) passes
Unit-machine06 native/forced ordinary owner, root0/root1. It covers all32 bindings and pure Source evidence,
Boolean/i8 remaining UNKNOWN despite shared ABI, float/double/long-double precision, i64/u64 boundaries,
stable storage, rejected ABI/protected writes without mutation, nonzero physical profile/immutable identity,
copy/projection/qualification/GC, unfilled storage, and rejection of unowned referent metadata.
The machine assertions execute natively; n/f/root checks exercise their ordinary L2 owner. This does not
claim walked FP/64-bit method bodies or full FFI. The existing suite's `machine SOURCE ENTRY MODES EXPORT`
row translates the machine unit once and uses existing build/run operations for that owner.

The pure Source unit also passes all33 cell rows on the actual G2 tuple, n/f/root0/root1. The same
G2 targeted01 list passes the machine unit and legacy place_map/map_chain:4 rows,0 failures.

## Rejected attempts and reuse

Early attempts exposed by-value struct-array C access, opaque-field casts, a reserved parameter name,
ungrouped const formals, and executable-L1 type aliases. The fixes stay in maintained L2/L3 producers.
The initial ordinary test hit the still-open C scalar graph lowering. The machine ABI unit states its
scope explicitly rather than claiming that the ordinary FP route is implemented.

Review added source ABI/stride checks, absence-aware load/copy/GC, and the existing unsupported policy
for unowned referents. Whole01 was deliberately stopped during G1 compiler translation before accepting
the earlier source. Whole02 then found missing compiler outputs removed by that interruption. Exactly10
missing generated artifacts were restored from the prepared host after matching their maintained source
hashes; `restored-compiler-artifacts02.txt` records them. No kernel source changed for that restoration.

## Whole and documentation gates

Whole03 quick PASS as `boot-m13-exact-storage-03`: actual G1 builds/tests G2, each9 smoke and tool startup/hash.
Fixedpoint01:20 comparisons PASS, including frontend/tool C/L1, PE comparison, both runtime objects, new
header/full profile/Value ABI, libc and canonical verification. Private Runtime11==G1==G2 driver.
Actual G2 frontend SHA `6bfad91263bb68a456ed6d70176d26dc358570eebf50139b3111604d778bacea`;
G2 backend SHA `12138e795c060c0dc02ca47d65f393d95ac55ced7b0a71a2097ec876b3137e1b`;
G2 Tool SHA `a78999334978d26a6899aba6983585fb09d2e4992dc0ec296cab5dbc69a9728d`.

The actual G2 Graph tool SHA `ece0680e0516e05c5d6049d0b1a867c732087b706e6951b2fd9db4ce4c5b307b` passes
declared_model_interface, construction_paths_owned_data and declared_model_missing in interp/native/forced.
The missing Model is refused at build4. An earlier one-off TSV argv construction was rejected before any
Graph build; corrected graph-checks02 is the accepted gate. Code/grammar inputs did not change.

G2 semantics render01 PASS:35 paired chapters,14 implements cases and both verbatim source snapshots.
Generated semantics and grammar did not change. Fresh docs-check01 PASS35/14/27/44/615, authored links and
LF/index checks for28270 tracked files. Only documentation/receipt annotations followed frozen Source16;
the successful code gates were not rebuilt or repeated. Final indexed01 also PASS35/14/27/44/615,
authored links and LF/index checks for28273 tracked files. Diff checks clean. These result annotations were
added after the successful indexed check as outputs, not new semantic inputs. Commit/push use main directly;
the two foreign untracked files retain their recorded SHA256 and are excluded from the explicit owned index.
Full language-bridge acceptance is not claimed.

Continue [the current pipeline](../../current.md). The full public resolver, ordinary typed Run/receiving/FFI,
activation/pending Value GC roots, foreign-Array ABI and complete M11/M13/M14 remain required OPEN work.

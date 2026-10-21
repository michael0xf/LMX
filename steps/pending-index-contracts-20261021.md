# Private138: indexed receiving checks wait for common source contracts

Base main: `4894fd25c0d0a8d9abb39cbd613db77fa54fcab6`.
Final source `build/codex_pending_path_138`; frontend
`build/codex_pending138_build_01`. The [one-source U0 patch](witnesses/used-scope-20261020/pending-path138-u0.patch)
applies over [Private137](raw-root-projection-20261021.md)'s final137c.
Replay `build/codex_pending138_replay_01` reconstructs it exactly. Runtime,
application header and ABI layouts are unchanged. This is a private kernel
dependency, **not full path unification, a full gate or self-build**.

## Common receiving check, not a hidden-root exception

`l2_check_indexed_write` borrows the complete cached P0 head and its prepared
path. It handles indexed receiving places before the statement check's old
early invalid-index rejection. The same check is entered by the existing
`l2_check_path_write` deferred continuation. A root or index input whose type
has not closed waits through **existing kind7**, with the same source environment,
then reruns the whole receiving check. No new wait kind or name/depth exception.

Dependency waiting examines the complete original head expression, not merely
its root. Index and RHS expressions are checked as ordinary original field
spans before waiting, so their calls/free inputs join the existing closure
fixed point. No expression is executed by CHECK or substituted with a zero.

After closure the Array view keeps its existing `l2_check_array_place` rules.
The raw-pointer/C view consumes `l2_raw_index_path`'s selected root, each retained
index span/type and receiving leaf. A typed leaf goes through the existing
receiving-value contract; an opaque C member does not acquire an invented type.
There is no new head parser or member dictionary extracted from C headers.

Opaque C-member write qualification is recorded in the existing
`L2Address.immutable` field from the selected root's closed contract. CHECK
refuses a const target before emission. This is not a special guard in native,
nor a change to pointer-cell/runtime layouts. Pure typed-pointer qualification
continues through the existing full-depth type fold.

## Actual source values and refusals

The [published source](witnesses/used-scope-20261020/pending-path138-probe.lm2)
contains both a hidden root and, separately, a hidden index with an explicit
root. It actually calls the methods, verifies indexed writes/readbacks41 then43,
and checks persistent state with an independent C getter. Index `k` is an int
input supplied by the caller; it is not replaced with a literal during lowering.

Old137c refuses the SAME source at `ptr\cells[k]` with `unsupported index`.
New138 strictly translates/compiles/links and runs, driver **13/17, 0 roots**
in native-root and walked-root modes. C bodies are still native under the walked
root: these counts do not prove interpretation of arbitrary C operations.
The136 value/pointer source separately repeats actual scalar/index writes,
SOURCE reads, by-value isolation and persistent pointer updates in both modes.

[Const hidden indexed write](witnesses/used-scope-20261020/pending-path138-const-refused.lm2)
refuses with `const write`; [incompatible typed leaf](witnesses/used-scope-20261020/pending-path138-leaf-refused.lm2)
refuses with `assignment value has incompatible type`. Both are actual L2
diagnostics, not failed signature preparations or C compiler crashes. Waiting
for a type is not permission to accept an invalid completed contract.

The three137 positive RED sources are unchanged. Their observations in
`open_observe_02` are still failures, **not accepted negative tests**:

- Nested foreign capture still has no hidden input and reports unknown root.
- The indexed-hidden-write source now gets past the old index refusal and
  reaches `dynamic input type has no value cell` in its separate by-value call.
  Its isolated pointer/index dependency is tested by the successful source above;
  the entire original program is not claimed GREEN.
- Hidden by-value C input still lacks a supported value cell.

One additional valid positive source is preserved:
[direct foreign factory in the root](witnesses/used-scope-20261020/pending-path138-foreign-root-open.lm2).
Scratch `probe_01`/`run_01` passes native-root13, but actual forced root RUN fails
`UNSUPPORTED`, **exit3** (`foreign_root_observe_01`, started,no timeout).
The successful `probe_02`/published source moves that factory into a no-argument
native check method without changing expected values. This narrows backend
coverage; it **does not fix or replace** the original root-walker RED.
Both source forms, compiled artifacts and observations are retained.

Clarification from the139 review: [L2 scope](../docs/L2_spec_en.md#scope)
assigns L2 machine operations to native lowering, not the L3 interpreter.
The historical forced-root RED above measures unsupported forcing of an
L2-only machine expression; it does not establish an obligation to interpret
arbitrary C or add such a prerequisite to §8. No source, expected value or
recorded failure is removed. Distinguish this boundary from genuine L3
native/walker mismatches and incorrect native behavior; see
[the139 scope and retained semantic REDs](ready-member-projection-20261021.md#l2-and-walker-scope).

## Final regression scope

`build/codex_pending138_verify_01.ps1`, session46200, **terminal0**:

- Existing frontend retained-root84/0; old135 SAME84/30 assertion FAIL.
- Existing native indexed-write82/0, including actual typed depth7, nonzero and
  negative indices, effect order, frozen target and SAME-address context changes.
- Permuted Structure/Array/read/write/taken-address36/0 **each native and forced
  walker**, independently compiled from the final sources.
- Source-linked compiler336 unchanged assertions.
- **85 fresh L2/L1/C/GCC/link units,170 actual runs:162 GREEN+same8copyRED**,
  same modes, native binding counts, exits and observations;341 selected parent
  pins. Worker2932,startUTC `2026-10-21T19:56:04.0765786Z`.
- Four foreign-value actual executions13/17/13/17 link the fresh138 matrix runtime.

Do not sum overlapping focuses, include the extra positive REDs as GREEN or
present this as the full gate. Strict C99 pointer/qualifier diagnostics stay
enabled, O2/fstrict-aliasing runtime/units and O0 frontend. One GCC pipeline.
PowerShell recipes and test-only L1 C ABI predefs are transitional evidence,
not the language-owned, handwritten-L1-free §8 closure.

Post-verification session20317 is **terminal0**. Exact final138 generated
indexed-unit controls each strictly compile/link and complete SAME82 with
**2 assertion FAIL**, exit1, for wrong owner and a target reselected after RHS.
The freshly translated/compiled/linked published programs repeat actual13/17
with the **new138 matrix runtime**. Old137's published-source index refusal and
both final semantic const/leaf refusals are separately captured.

```text
compiler source 2FBA9C15E225B6890E3D8D9AC8EAD774DF52A6E8DFD2C75936D86DDDABD5FA05
frontend C     65A17DCB64DF85C08D18E0A02DB8CE9557A6E28EEAA12BF1BF2B21E62FD5EC4B
frontend EXE   B278EC4602E7BE949BB93EB2F76F50D5434C6CCF9A97BFB955C5C6A7CA8C8D53
runtime C      471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh object   ACB0E6F66CA1EF7C4E35F4927FD102FE2C29AC251A2000A9AB963FD2A8C3F3EC
one-source U0  7D206A79FD666B7338514C9B2055F8369A2C562BC1BE79B45A55FEEF76A688C1
```

Terminal receipt `build/codex_pending138_terminal_01.inputs.sha256` has
**2040 pins**, SHA256
`119F2A079D948C2571C4F5E1F10612B8C3B00491440871E2D8A2AC4A73B2529B`.
The [summary](witnesses/used-scope-20261020/pending-path138-evidence.json)
records those identities and boundaries. Named sources/output dirs, source
witnesses, commands, quoted C/header dependencies, selected tools and parent
receipt digests are pinned.341 selected prior inputs were checked by the fresh
matrix, not all historical inputs. Conservative scan still has `decNumber.h`;
complete preprocessor/system-SDK closure is not certified.

Named `build/codex_pending138_*.ps1` recipes retain commands:
`build_01` → `verify_01` → `controls_01` → `published_01` →
`refusals_published_01` → `terminal_01`. Runtime C is unchanged137/134f;
standalone focuses reuse its exact verified renamed object, the85-unit matrix
builds a fresh object and final foreign/published executions link that object.

## Remaining work

The Array/raw views still do not constitute a single retained end-to-end
semantic result for all value/place consumers. Legacy atom/index/dereference
readers, native text re-entry after classification, opaque member types/target
freezing, all-consumer maps, foreign capture/value transport and address lifetime
remain OPEN. No native-only result is advertised as forced-C interpretation.

Public dev is unchanged. Last full1121011 FAIL/3754, eight old copy-positive REDs,
clean kernel, two L3/L2 self-built generations and mail T01–T26 remain OPEN.
Codex remains sole writer/build; goal ACTIVE. No pause, substitute goal,
duplicate timer, branch/worktree/PR. Unrelated WIP and protected diagnostics
are excluded from reads/staging/publication.
Both doc generators pass;staged check_docs7126 and diff check pass. All2040
terminal inputs were independently rehashed. All named138 workers are terminal.

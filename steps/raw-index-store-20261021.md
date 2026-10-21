# Private135: indexed pointer stores consume prepared head steps

Base main: `5b4d30a1b16305ce5f0a8323945b642436db1ca8`.
This is a private clean-kernel dependency slice, **not all-path unification,
a public-dev rollout, a full gate or self-build**. Writer/build remains Codex.

The [two-source U0 patch](witnesses/used-scope-20261020/raw-index135-u0.patch)
applies over `build/codex_native_store_134h`, the preceding
[Private134](native-place-store-20261021.md). Replay
`build/codex_index135_replay_01` reconstructs both final sources byte-for-byte.
No runtime Value/Place/chunk layout, graph field, opcode, Model registry,
branch or managed worktree was added.

## Mechanism and boundary

The old native `l2_emit_index_place`, `l2_emit_index_base` and
`l2_emit_index_expression` are removed. Statement CHECK, retained graph emission,
native store and head-effect classification borrow `l2_head_expression`'s cached
P0 expression and general path-adapter record. A head no longer goes back through
`l2_raw_index_text`, substring bracket matching and the native index-piece lexer.

The general run adapter retains **all** adjacent index groups as steps, including
their original bounded expression spans. `flat` still identifies the first
adjacency: retaining grammar does not erase the receiving Array's distinction
between rectangular addressing and a reference chain. Counts and index spans
travel together in independent prepared views; releasing a view does not cut
the retained head.

`l2_raw_index_path` folds the declared pointer type over those steps and records
each consumed type in the compiler-only `L2Address` kind8 view. It does not derive
a Model from candidate layout, parent or admission history. The graph's raw-C
representation consumes those prepared index spans in both COUNT and EMIT;
the native consumer uses the same spans and recorded types.

For known typed pointers, native emission freezes the pointer before each next
index, then the exact typed cell and current owner before RHS. Ownership is
selected using the **previous** address Value: first changing its raw address
would incorrectly attach index0's explicit owner to indexN. Pointer writes use
the existing common `lmx_value_cell_store` and exact C accessor; scalar writes
retain their existing conversion and physical write guard. No `T **` cell is
replaced by a generic `void **` cell.

This does **not** complete semantic/path closure. Root evaluation still enters
the ordinary expression/binding machinery; it is not proof that every backend
uses an already selected root without another lookup. Legacy atomic/raw read
consumers still use `l2_raw_index_text/span`, `l2_prefix_deref` and
`l2_deref_word`. Their migration remains work, not a permitted permanent fallback.
Opaque C member storage has no known L2 leaf type: its original P0 expressions
are retained, but its C lvalue is not yet universally frozen before RHS. No fake
typed writer or guessed Model was introduced to hide that boundary.

Raw C index bodies remain **native-only** in the existing retained-machine
representation. A successful raw-C native test is not forced-walker execution of
that arithmetic. The normal Structure/Array field/read/write/address witness
was independently rerun in both engines below. General typed-pointer interpreter
selection, all root/field/index consumers, per-step maps, unowned cell lifetime
and qualified-index effect order are still open.

## Actual observations

The [published source](witnesses/used-scope-20261020/raw-index135-probe.lm2),
[C fixture](witnesses/used-scope-20261020/raw-index135-test.c) and
[effect functions](witnesses/used-scope-20261020/raw-index135-effects.h)
complete **82/0 native assertions** (`codex_index135_published_01`, session15375,
terminal0). This is not just successful translation:

- The unchanged 48 baseline checks now write through `p[0]` and a working alias.
  SAME raw payload D/E replacement updates return context and persisted state;
  fresh independent reads and admission observe actual permuted `7/9` fields.
- Nonzero indices use actual two-cell typed pointer backing. An explicit owner
  for index0 must not become index1's owner. One- and two-index paths preserve
  the neighbor's payload/context and persist the selected cell's current state.
- Six written index steps traverse a genuine C pointer chain of depth7, with
  exact intermediate C types, and update the final owned pointer cell/context.
- Index callbacks and RHS execute once in order `1,2,3`. The second index and
  RHS change earlier pointer cells; the write still reaches the selected old
  intermediate/leaf, not a path re-evaluated after those changes.
- Typed scalar writes include a legitimate negative index from an interior
  pointer and verify the actual selected value plus untouched neighbors.

The basic SAME48 comparison is `codex_index135_old_01` vs `probe_02`: old134h
completes **48/24 FAIL, exit1**; new135 completes **48/0, exit0**. This is a smaller
unchanged observation set contained in the new82, not an old82 comparison.

Published-unit controls (`controls_published_01`, session94989, terminal0) use
the **exact published generated C**, the same82 assertions and unchanged runtime:

- Wrong explicit-owner propagation at offset selection: **2 assertion FAIL**.
- Discarding the ready cell and selecting it again after RHS: **2 assertion FAIL**.

Both strictly compile/link, complete all82 and exit1. Preparation errors or aborts
are not counted as these RED controls. Earlier controls02 measured the same
losses on the build-path unit; the published controls are separate actual runs.

The [actual-frontend grammar test](witnesses/used-scope-20261020/raw-index135-record-test.c)
completes SAME110 checks for ranks1/2/6/65/129, with and without a foreign-name
prefix. New135: **110/0**. Old134h: **110/24 assertion FAIL, exit1**. It checks
whole-span counters, every original index span, the adjacency marker, cached
head identity, independent views and existing allocation lifetime. It does not
claim actual depth129 pointer execution. The tracked test is byte-identical to
the executed `build/codex_index135_record_01.c`.

`verify_01`, session37117, terminal0, also completes:

- **336** unchanged source-linked compiler checks.
- The existing fully permuted field/Array/write/taken-address witness:
  **36/0 native and 36/0 forced walker** (`places_01`).
- **85 fresh L2/L1/C/GCC/link units, 170 actual runs: 162 GREEN and the same
  8 positive-copy RED**. Native binding counts, modes, exits and old observations
  are preserved; 341 selected parent inputs checked. Worker8252,
  startUTC `2026-10-21T18:41:02.0585751Z`.

Four additional foreign-value executions complete **13/17/13/17** with the
**fresh new matrix runtime object**, not an old runtime (`foreign_01`, terminal0).
Do not sum the overlapping focuses into a supposed full-gate count.

## Bytes and reproduction

Source is `build/codex_raw_index_135`; frontend build is
`build/codex_index135_build_04`. Only the compiler/application sources change.
Runtime C is byte-identical134f/134h. Focus fixtures reuse the verified renamed
runtime object; the85-unit matrix separately compiles a fresh runtime object.

Final source comments were corrected after the behavioral runs. `identity_01`
freshly regenerates **byte-identical frontend C and application header** from
the final sources. Existing exact compiled bodies/binary and behavior therefore
apply by identity; this is explicitly not another fresh GCC run. No executable
code changed after build04.

```text
compiler source 150C9EF2DFBB11AB8387A3011190400424E2286481E8688281959F73F88F1E74
application h  E1EDCC2A842EF745D202482A42F41FE8CCA2BDFF741F0EE1078EAD12110637AF
frontend C    DC73A263447FAA70D5A1266AE27B291370D1C20F3246F239AAEE9EB67C3377CF
frontend EXE  488BAF3AC8DDCE611BDA72CA8B717BEA67DBF4673A8F212C79480F7C7ECD1950
runtime C     471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh object  F817440A13B6404A5C703C206F139EC33FBB622D00A8729902CEB0AD5965C0B2
two-source U0 98E1526782ADE50BA7B3273E949085696F4C35C13F0A9C2E99AE8C9DF2F70DBF
```

Terminal receipt `build/codex_index135_terminal_01.inputs.sha256`: **1403 pins**,
SHA256 `1C10C1F87312CEAA801A16B9FFB293AF35A4861CCDEE2007E52DD8B0AC23AEAB`.
The [summary](witnesses/used-scope-20261020/raw-index135-evidence.json) records the
same identities and bounds. It pins named source/output dirs, actual unit inputs,
quoted C/header dependencies, recipes, selected tools and parent receipt digests.
This is not a rehash of all historical files or complete preprocessor/SDK closure;
the conservative include scan still reports unresolved `decNumber.h`.

Named PowerShell recipes under `build/codex_index135_*.ps1` retain actual commands.
They are transitional evidence tools, not the language-owned build required by
§8. Strict C99 incompatible-pointer/discarded-qualifier checks remain enabled;
native/runtime fixtures use O2/fstrict-aliasing, frontend O0. One GCC pipeline.

Preparation failures are retained separately: build01/02 L1 tail cutters,
probe01 wrong generated value-member projection, probe03 fixture's nonexistent
numeric constructor, probe04 missing scalar-result destination, controls01
linking the unrenamed driver's `main`. None is a behavior RED or an accepted
oracle. Final named workers are terminal; unrelated WIP is not included.

Both documentation generators passed. `tools/check_docs.py` validates all7103
tracked files,links and LF endings;staged `git diff --check` passes. Only the
listed slice files are staged;the protected diagnostic and unrelated117 patch
are not read or included.

The public dev baseline, last full112 **1011 FAIL/3754**, eight positive-copy RED,
all-consumer path closure, clean kernel, L3/L2 self-build generations and mail
T01–T26 remain open. Goal stays ACTIVE; no pause, replacement goal or new timer.

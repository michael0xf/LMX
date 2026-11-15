# Slice402: raw physical index writes under replacement M14

Code baseline: 16ea4e0851f2d271e1b6729732c549b9c0c447dc, directly on main.
Root is the sole code/test/build writer. Helpers reviewed code read-only; one helper corrected
three RU/EN address pairs in the concurrent author-prepared documentation, without build commands.
The author separately confirmed sequential visibility for variables and const; the complete Astra
documentation package is still being prepared. This code slice does not implement that visibility change.

## Change and limits

Removed frozen index-slot requirements, their receiving/receiving_index tables, fact copies during
merge/copy and generated slot_prepare calls. Graph exports84→81, Run61→60, ArenaRefs24→22.
Common implements/receiving composition maps remain. Removed future-execution machine-code write
admission and its scanner/call sites; actual reached SOURCE_MACHINE still returns UNSUPPORTED.
Existing physical barriers, pointer ABI/companion handling and code reset/link bookkeeping remain.

Index bases use the existing target interpretation before the exact physical pointer fallback.
Direct Structure and Array values are addresses; pointer payloads use the pool's exact reader.
Numeric UNINIT_INT, including its immutable physical variant, is refused before reading its service
pointer bytes. An explicit language pointer to that cell remains a valid raw address.
Index reads/writes use actual graph_cell_in places. Pointer Array payloads are read through
value_cell_access; primitive numeric Array storage is never treated as a void-pointer array.

Graph invalidation now separates preparation from completion. All affected-entry allocations/scans
happen before the existing common value_cell_store; entries are cleared only after successful store.
A failed protected write preserves payload and native. Physical pointer-cell identity is retained
when scanning executable Arrays, rather than lost when their field payload is decoded.
No duplicate rebind preparation, new registry or parallel ValueOwned store implementation was added.

This is a bounded physical-index change. Whole Array namespace/path/receiving support, activation-local
places, deletion of local publication, unified data, code snapshots, actual-based signatures and grouped
sys tools remain OPEN under M11/M13/M14. Current tests still run the earlier execution model.

## Inputs and build

Stage: `build2/codex_fix250generationchain01/sol-m14-index-01`.
Receipts: `build2/codex_fix250generationchain01/runs/sol-m14-index-20261115-01`.
Seed: accepted401 actual G2. Source09:935 is canonical and verified against repository and stage.
Manifest SHA: 5b90fde86088da265061d396f527ddb6ebcaccfeb3d2c52f552bf978abcd127c.
Fresh Tool01 built normally: eb7bb98110865c8afbb8cec0c65a1cf39df623008fd0fc762f69693a1390320c.

Runtime01 exposed an unsupported uncast callback result in L2. Runtime02's genuine suffix completed
through aggregate generation; its CC only lacked generated C headers. Runtime03 regenerated the98
headers and compiled both objects. Private01 exposed private test API calls and obsolete built-in
write-refusal assertions. Runtime04 corrected the driver assertions; private02 then exposed its missing
WalkContext and unsupported fixture getters. Runtime05 corrected those and added the reviewed nested
index/Array/invalidation cases. Private03 passed code_write_words but FD crashed: gdb identified
`read := pool.pointer_read` lowered as a null callback invocation. Source07 uses the existing explicit
void-pointer result cast around the direct pool callback, as in pointer_value_promised.
No generated L1/C source was hand-patched.

Runtime06 reused successful genuine prefix artifacts and replayed Graph+header+aggregate+two CC commands.
driver.c: 099089d55552612d067b3508f292855e74e4c4a446564d25dcea4f2cef066750.
Production: 806f30f01d64a61eb8d899947700fe1d2e1a240b404246b7bec93f4abe56eb61.
Observed: 8ba7942c7201f2f425bcf35f26b01aae2a2f24153573a98f586c0f1f2864fc46.
Fresh Graph01 built normally: ab373fcf6ae5be83e024918acf2567ebafde13e18ff95d8619706aee2d27c4e7.

## Focused checks

Private04 replayed two genuine link commands and four launches using unchanged private03 FD objects:
native/forced, root0/root1 all PASS. This unit checks FOREIGN double epsilon, opaque and present-null
addresses, old Array pointer-context clearing, unchanged numeric bytes/width, immutable refusal with
native retained, mutable native reset, pointer Array base, direct Array RHS, numeric service rejection,
explicit pointer to a service cell, nested index through a reference place and executable Array cell reset.
Private03 code_write_words passed native/forced/root0/root1. The built-in driver now has82 checks and
directly checks successful writes beside machine code plus UNSUPPORTED only when that code is reached.

Graph01 passed six focused cases in interpreter/native/forced: slot_typed_refused, slot_typed_rhs_refused,
struct_index, slot_atom_copy, slot_bounds_rhs_refused and admission_structure_type_refused.
The two former type refusals now succeed under the new rule; bounds answer7 and named admission answer4
remain unchanged. Their full negative AFTER dumps also match the existing expected files.

The former struct_index_admit negative fixture had an external j; the removed preflight refused before
that RHS was consumed. Source07/08 exposed missing-name answer3 in the attempted observer/external setup.
Source09 places j in the written DATA like existing struct_index, writes its address over nested N and
observes main.data.S.j after the call. Graph03 passed all three engines, seen40. The expected dump keeps
the original written N blueprint; it does not confuse that declaration with the constructed method DATA.
Only this new golden and the two canceled-refusal goldens changed; the bounds/named-admission goldens did not.

Genuine whole bootstrap01 passed: actual G1/G2 quick, smoke9/0 each. Fixedpoint01 passed CHECKS38/0,
including runtime06 production/observed equality with actual G2, retained Graph81/Run60/ArenaRefs22 headers,
canonical935 and consumed-input verification. Actual G2 targeted01 passed SUITE2/0, the expanded FD unit
and code_write_words in native/forced/root0/root1. Fresh actual G2 Graph01 passed all seven focused cases
in all three engines plus both negative AFTER comparisons: CHECKS9/0.
Actual G2 frontend: c9b3a640422b3349e1063a8842ebdd4f2b9e895e7b1c0b88204dcbae6aeb592e.
Actual G2 Tool: e81ecdcb7ec543aadbabc1234ae5818142154cd5021e7506a7485cfd766a8a92.
Actual G2 Graph: 9185c1a7e2be51b790985510f571668c54ab0c56dd0600507c4b7ff463012093.

All code producers are terminal. The complete author-prepared Astra package was received and reviewed;
normal render receipts pass35/14 and27/47. Fresh G2 docs-check01 passed35/14/27/44/615, LF28292.
Review corrected the remaining four manual L1/L2 dirty-publication phrases; final document-only index02
passed35/14/27/44/615, LF28296. Documentary commit92902adad375ae33ede003493c419a2306703522 precedes code402.
The final code index03 passed35/14/27/44/615, LF28297. Only status/evidence records were updated afterward;
source09 algorithms, tests and canonical935 did not change. Both working/cached diff checks pass before commit.
The two original unrelated untracked artifacts retain their accepted401 hashes. The unbounded goal remains ACTIVE.

# W4 candidate witness: arena-owned native descriptor table

This records the completed RT07/unit07 handoff step on 2026-11-24. The physical component remains a candidate;
G1/G2 and final acceptance are pending. This document changes neither the norm nor the author journal.
T is the tz-20261121 run directory; A = T/w4-accept-20261124/root01.

## 0. Status

The physical component is a CANDIDATE: PENDING until the G1/G2 generations; it is not accepted.
The finished step is RT07 plus unit07: RT07 built (exit 0) and the unit `native_descriptor_storage`, with its new
`nd_changed_leaf` check and the single-pool leaf lookup, passed 2 builds and 4 executions on it.
Earlier, 12 of the 14 other targeted rows
passed on an older runtime of the same family and two rows fail with their old reasons (section 4).
The candidate handoff commit saves the 32 code and control paths (section 4). The accepted ABI boundary
stays W3: the W3 host link must not be run on the W4 headers of S.
Not run: G1/G2 generations, the final targeted15 on the final sources. The author has resumed goal v3
with Sol 6.2 coordinating and coder GLM 5.4 implementing.
The whole of W4 is OPEN, because the source-level `sys/native` is still blocked (section 1), and W5, M13, M14 and
the rest of step 27.10 are open. The words "component accepted" are for the lead alone.

## 1. Physical component versus the whole of W4

PHYSICAL COMPONENT (what the saved sources implement; pending): one arena-owned call/native table that maps a
selected executable occurrence (a code `Lmx`) to an ORDINARY native descriptor, with the descriptor data held as
ordinary graph data, the `native` word removed from the `Lmx` header, and producers and consumers moved to it
(next_core_tasks_v3.md, W4 candidate entry).

NOT IN THE COMPONENT, STILL OPEN (relayed by the lead from Astra 247; her text is not in this checkout):
- there is no language-level `sys` provider or dispatch;
- an ordinary result-call through the language is blocked by the FN carrier;
- a source `sys/native` that returns an existing descriptor or 0 without creating or executing anything needs,
  nearest first: the step 21.7 callable result, the kernel constant-namespace export, and a zero-actual caller
  DATA form; it does not need the W5 globals;
- the new C API query and a test through the C door do NOT replace the source receiver. The C functions below
  are the physical door only.

## 2. Representation, as read in the canonical private sources (read, not accepted)

Table. `LmxArena.native_calls` is a `LmxNativeTable {rows, len, cap}` of `LmxNativeBinding {code, descriptor}`
rows keyed by the code address. There is no second registry, cache or reverse map. A pending table of the same
shape holds rows during a construction and is published as one validated step (`lmx_native_publish`).

Descriptor, built by `lmx_graph_native_descriptor` as an ordinary Structure: D (parent 0, one slot) holds the
variants list V (one slot), which holds the one variant X (six slots):
- slot 0: the prepared signature (0 means "no prepared annotation", not a proof of any kind);
- slot 1: a typed `LmxPrimitive {fn, signature, owner = 0}` record of the PRIMITIVE pool, `fn` a typed C9
  `LmxPrimitiveEntry`;
- slots 2 to 5: module, entry name, L1 path, C path, each a real dense `Array<Char>` with the NUL outside its
  length, or the slot left 0 when the text is unknown. Nothing is interned and no path is guessed.
The generator writes only a proven C symbol as the entry name; its L1 path is 0, because the final output path
is a parameter of `lm_compiler_emit_unit` that no cell retains.

Operations. Call module: `lmx_native_descriptor` (a read; creates and executes nothing), `lmx_native_entry`
(typed entry of the leaf, or 0), `lmx_native_bind` (descriptor 0 removes the row), `lmx_native_attach_prepare`
and `attach_move` (called from the arena attach), `lmx_native_drop` (called from the range removal),
`lmx_native_table_set` and `dispose` (dispose is called from `lmx_arena_release`), `lmx_native_publish`.
Graph module: `lmx_native_install`, the one explicit installation with 8 arguments (arena, code, typed entry,
signature, module, entry name, L1 path, C path; the descriptor is built in the arena that really owns the code;
entry 0 removes without constructing), and `lmx_graph_native_descriptor`.

Header. `struct Lmx` no longer has the `LmxEntry native` word (parent and array remain). Against R the canonical
private tree changes 28 paths and adds one test: 17 files under `src/l2src` (kernel, translator, driver),
nine dyn tests, `tests/native_closure_values.lm2`, `tools/build.lm2`, and the new unit
`tests/dyn/native_descriptor_storage.lm2`. Reads go through `lmx_native_entry`, writes through
`lmx_native_install` or `lmx_native_bind`; `lmx_walk_callable_addr` is removed.

GC. A live weak code key conditionally retains its descriptor and the graph dependencies it reveals, in the shared
fixed point (`lmx_gc_mark_native`, called from the metadata marking loop). The table never roots its keys.

Copy and merge. The copier extends one identity map (`lmx_copy_native_finish`, `lmx_graph_copy_native_mapped`).
The merge has a selected form `lmx_merge_selected_owned` (the 16 arguments of `lmx_merge_used_owned`, then the
selected operand index, its D-105 address table and width) that proves the result-to-source admission and composes
the descriptor inside the kernel, before the independent and immutable steps. The generated builder text no longer
assigns a native word: the emitter writes `lmx_native_install(l2_program_arena, l2_entry_leaf, (cast:
(LmxPrimitiveEntry) SYM), 0, 0, "SYM", 0, 0)` and the selected merge call.

RT06 change: the lookup no longer repeats `lmx_range_home` (the second call is removed); no cache is added.
Between RT05 and RT06 only `lmx_call.lm2` and the unit changed.

Changes after RT06 (read in the canonical tree; built in RT07 and run by unit07, section 4):
- `lmx_native_entry` resolves the leaf's pool once (`lmx_range_cell_pool`) and reads kind, type and stride from that
  one `LmxPool`, instead of three separate `range_cell_pool` wrappers; the physical checks are the same.
- the unit gains `nd_changed_leaf` (called from `nd_storage_check`): it replaces the leaf by 0, by an int and by a
  Structure, checks that the entry is 0 and the descriptor identity is kept, then restores the leaf and executes it
  (77). The description of its steps is the lead's; the unit07 receipt shows only that the six lines pass.

Points to settle before the final wording (my reading, not decisions):
- `lmx_graph_fn_make` binds the SAME descriptor object of the declaration to the made code of the same arena;
  say so, or change it.
- Revert/rollback of an attach is not separately verified by me; attach prepare/move, range drop and release
  (dispose) are present in the source.
- `l2_graph_tool.lm2` (the Graph producer) is also edited; I did not read that change.
- A stray file `native-table-body-v2.tmp` sits at the root of the canonical private tree; it is not a source path.

## 3. Seed and target boundary

The seed stays on the W3 ABI: the seed tool is built against the frozen W3 closure; the emitter delta is
text-only and the new native API is a target-only dependency, never called by the generator itself. The new `Lmx`
layout exists only in the target. Provenance receipt: base is the published W3 commit, all 382 generated stage
inputs matched the archived W3 hashes before mutation, the regenerated emit body and tool-only files are excluded
from the reuse set, and the strict reuse manifest has 377 files (the first manifest of 378 also had
`l2_frontend_lower.lm1`).

## 4. Receipts so far (A; exit codes and logged lines only, no acceptance)

Seed chain (W3 ABI):
- seedTool01: exit 0, 47 s (07:48:26 to 07:49:13); log ends `l2_eternal_driver: 42 checks, 0 roots`.
- SeedPart01: exit 1, 211 s; strict 377 verify 2 failed (`l2_frontend_emit.h.lm1`, `l2_frontend_lower.h.lm1`).
  Comparing the saved headers (`A/seed-fep01-consumed`) with the archived W3 headers, the only differing lines are
  the numeric ordinals inside generated parameter names (emit.h +2, lower.h +1), shifted by the helpers inserted
  before them; no name or type changed.
- SeedPart02: exit 0, 292 s (07:56:00 to 08:00:52), after the three new private helpers were moved to the end of
  their files; strict 377 verify 0 failed four times, the last after `HEADERS 129 regenerated`, so the public
  headers are byte-equal to the archived W3 ones.
- host link (feh02): exit 0, 83 s (08:01:09 to 08:02:32) against the W3 runtime; seed exe `60a124a1...`.
- W3 ABI before target: `VERIFIED 377 files, 0 failed`.

Target runtime:
- runtime01 to runtime04: each exit 1 after 22 to 32 s, no cause printed. As the lead gave them: an actual of
  unknown C type before a nested descriptor call in `GraphFnMake`; a reserved word used as a table local;
  and, twice, the old frontend wanting explicit typed casts of C fields in local L2 helper calls (GC, native hash).
- runtime05: exit 0, 111 s (08:10:47 to 08:12:38); the first W4 target-ABI runtime.
- runtime06: exit 0, 275 s (08:31:42 to 08:36:17); lowest free commit 2602 MB at 08:35:41, build peak about
  1026 MB; log ends `42 checks, 0 roots`.
- runtime07: exit 0, 4.8 min (09:07:17 to 09:12:03); lowest free commit 1362 MB at 09:09:47, build peak about
  529 MB; `HEADERS 130 regenerated`; log ends `42 checks, 0 roots`. The lead reports a verify-record of 154
  hashes, 0 failed; that line is not in `runtime07.log`.

Unit `native_descriptor_storage` (six lines per passing run: 2 builds + 4 executions, not 6 executions):
- one01 to one04 failed (L2 translation; CC; then both builds PASS but 4 of 4 executions exit 1). Causes per the
  lead: a reserved profile local; a missing graph_run header; a fixture that expected an unused lexical marker.
- one05: exit 0, 6 PASS (native and forced built; roots 0 and 1 give 7 in each).
- one06: exit 0 (08:37:16 to 08:37:21), 6 PASS in the same form, `SUITE 1 rows, 0 failures`. New checks since one05:
  after the source arena is released, the copied descriptor's module, entry-name and L1-path texts are dense
  `Array<Char>` of the exact bytes (`linked-test`, `nd_entry`, `native_descriptor_storage.lm1`; checked by kind,
  size and memcmp), and its C-path slot is 0 (the source was installed with C path 0).
- unit07: exit 0 (09:12:39 to 09:12:44) on RT07; 6 PASS = 2 builds + 4 executions (native and forced, roots 0 and
  1, each gives 7), `SUITE 1 rows, 0 failures`; unit source `9c51ec3f...` (full hash in section 5). It includes
  the changed-leaf check (0, int, Structure, recover) and the single-pool lookup.

What the unit covers (functions `nd_copy`, `nd_weak_key`, `nd_table_growth`, `nd_failed_copy`,
`nd_selected_merge`, `nd_storage_check`): descriptor identity and shape; the graph field unchanged; one copy map
that keeps both the user's descriptor alias and the service binding, with the signature and typed leaf pointing at
the final copied code; SOURCE RELEASE (the copied code is called after the source arena is released); ATTACH
(a nonempty receiver attaches the donor, and the donor is released); GC (a weak key conditionally retains the
descriptor, code and descriptor in separate chunks, and a user-held descriptor survives a dead key); table growth,
delete and backshift; a failed later descriptor closure that publishes no partial native rows; MERGE (a selected
second operand with another parent, cell alias and self/signature through the final receiving map, a qualified
copy after the selected binding, and an absent selected implementation that does not use the first operand's).
It makes no claim about raw `Array`, M14 or a `sys` query.

Targeted15 (`A/targeted15.tsv`: 11 machine rows and 4 `runs` rows):
- attempt 01 did not start: `NOT-STARTED`, free commit 893 MB against the floor of 600 MB;
- attempt 02 (08:19:11): stopped by the watchdog at 08:20:20 (lowest 552 MB); its first three rows completed
  (`exact_scalar_storage`, `execution_gc_roots`, `frame_description_gc`; 18 PASS);
- remain12-01 (08:23:21 to 08:26:18, exit 1, lowest 1745 MB, peak about 999 MB): 12 rows, 62 PASS, 6 FAIL.
Total: 13 of 15 rows green; 28 build PASS + 52 execution PASS = 80 PASS; 6 FAIL:
- `graph_call_frames`: 4 executions (native and forced, roots 0 and 1) `gives 7: driver exit 1`; the known
  baseline failure (case 122, value 5 against the expected 9) of the published W2 and W3;
- `immutable_reached_write`: 2 builds, L2 translation error at `tests/dyn/immutable_reached_write.lm2:136:10`,
  "an operand beside a runtime-typed value has no value record (an opaque C value: receive it into a typed local
  first)". `A/baseline-w3-immutable01.log` (08:30:00 to 08:30:02) repeats the same two failures with the same
  message on the consistent W3 stage, frontend and runtime.
All expected values are the old ones. The run is NOT "15 rows green". These 80 PASS lines were produced between
08:19 and 08:26, after RT05 (08:12) and before RT06 (08:31); the unit text of the one06 run (`da880355...`) is
newer than the unit text in the remain12 run (`1a3dd28c...`).

Graph translator and frontend:
- graph01: exit 0, 49 s (08:39:19 to 08:40:08); `HEADERS 130 regenerated`; `graph_trans-prod.exe` below.
- Graph cases: `root_closed_names` (exit 0) and `path_write_native_level2` (exit 0), each interp, native and
  forced PASS; the lead adds runs 1 and answer 0.
- FEH01: exit 0, 15.4 min (08:46:00 to 09:01:26); lowest free commit 1838 MB, peak about 1437 MB;
  `HEADERS 130 regenerated`; log ends `42 checks, 0 roots`. The lead reports a verify-record of 135 hashes, 0 failed;
  I did not find that line in `frontend01.log`.
- tool01: exit 0, 2.2 min (09:02:50 to 09:05:03); lowest free commit 1377 MB, peak about 1547 MB.

Candidate source/control integration into R. Receipts: `A/integration32.sha256` (32 paths: 17 under `src/l2src`,
12 under `tests` including `tests/full-suite.tsv`, `tools/build.lm2`, `inputs.list`, `inputs.sha256`) and
`A/inputs-final1688.sha256` (1688 lines). I re-checked read-only: `sha256sum -c integration32.sha256` against
`R/selfbuild` gives 32 OK, and the sha256 of both `A/inputs-final1688.sha256` and `R/selfbuild/inputs.sha256` is
the manifest identity in section 5. Final read-only verification is saved in A/handoff-records01.log:
FEH01 record 135/0, tool01 record 54/0, RT07 record 154/0, final source manifest 1688/0 and unchanged inputs 1658/0.
The source overlay matches S. `git diff --check` is clean. `inputs.list` and `tests/full-suite.tsv` gain the new unit.

The `42 checks, 0 roots` line is the observer's own count for a step, not a W4 unit result.

## 5. Identities that appear in receipts (sources are NOT compile receipts)

Published W3 base: `cb7a8798a1c9a271ec7cb544db335f1f908563e9` (seed-w3-provenance.txt).

seedTool01 (tool-seed01.log, seed-tool-source.sha256):
- `tools/build.lm2` source `75bf2f3debed724d1ddb0e807754d40e630a53fee07678ffd66387e8c58b562e`
- `lmxtool-tool.exe` `c46e9984d8da3657cfb8effd577e4b036d4b92bae6817072100398cb4ee7893a`

SeedPart01 (seed-frontend-source.sha256, seed-fep01.log):
- `l2_frontend_emit.lm2` `1481144197ec2ba287f48da9202abfa854b1133fabf6609aba43d8227dce2220`
- `l2_frontend_lower.lm2` `125a3072e2499b07881ee1775732ca534136a347d3afb746c558066a75413b87`
- W3 headers expected: emit.h `ee699c85effff8489c36ab7d4aa8cfb6e7ac222cb200cb214a87282fcef06cf2`,
  lower.h `65574a247d865a2e57bb08dc07e63e5a3608265836aeea6b6eb64b229e5a3664`
- headers it produced: `81a9ce00b0fe4f7181b9dc3f419648271e71122b38607c9bba29d9272f3b4b70`,
  `88d3d5bc7dc5df9f1bda6e4a8efd6f8f32106217d6dcba471afd6e3a2dade1c1`

SeedPart02 and host link (seed-fep02-source.sha256, seed-fep02.log, seed-feh02-link.log):
- `l2_frontend_emit.lm2` `1f62a6ee6c08550c92e214a4777a947af74215aace9b3d6bb7d689406fbdfcb8`
- `l2_frontend_lower.lm2` `c24fce3b5ab62d129c82f6889371619e2c14c950f3fb4cdf7e7919f731fa0717`
- seed `l2trans.exe` after the host link `60a124a14e76acde225842f37af0b6e6e3c9222c90b37787d1b7624d32131dd2`

Runtime source lists (draft-rt01.sha256 to draft-rt06.sha256, 29 paths each; SOURCE hashes, not results):
- `lmx_graph.lm2` `308dd802ac6e72e95952902ff706a740c7de0c703ffc1074cc2afe6bafb9f5b3` (all attempts)
- `lmx_call.lm2` at RT06 `108cc7ec47365532b8f1fad55df76f10b5a48cd4073382c780b82ab59c979446`
  (RT05 `680262e33d3076170bde979e329596dc6beb3165fc3d5b78d0bdf3d915f96d97`)
- `lmx_gc_graph.lm2` `b6d4435fa2e19c818ff67920133519c59fc86b23964d97a7e15c617a8efaa2d9`
- `lmx_graph_copy_owned.lm2` `9fcb848574e8403febf014f3c80d69b9f8b56dc4c3dab082d0fa75e6be98eaff`
- `lmx_graph_run.lm2` `82f38246007c6d70305b0a683aaf82a5bb3db7df78ab65e904a57802ca405351`
- `lmx_arena.lm2` `4f3be8fc40093064d940e40bd2e84a1a6f570dd9d9436edbbe3f9615657c8c99`
- `lmx_merge_owned.lm2` `a3906c8408c71c680089a792fc9bf3df72534b0bac99ca139bb927e5b20fd110`
- `tests/dyn/graph_mutation.lm2` `54fc32b2c82a5eeeee4d24a51ef57687e9ce2f015f2c3987461370ff36c9e367`
- `tools/build.lm2` `75bf2f3debed724d1ddb0e807754d40e630a53fee07678ffd66387e8c58b562e`
- unit at RT06 `da88035562ded871e28b50a78a5eb6af9570a80c4b78f1891631787a7881ac40`
RT07 source list (draft-rt07.sha256, 29 paths; the two paths that changed since RT06; SOURCE hashes):
- `lmx_call.lm2` `bcd15807df917a1fc6db74fe96f0ecd95da16ea8e9625ff1854bad12e60f0a85`
- unit `9c51ec3f2186b9552f2e0da044508f2b14180dde4295789549584201da1d1bba`
The other paths are in the receipt files and must be copied from them into the final witness, not retyped.
Integration (integration32.sha256, 32 paths, all re-checked OK in R): the same two hashes appear there; the manifest
of 1688 files is identified by the sha256 of `selfbuild/inputs.sha256`:
`86ab3082854c5c7d39ca175328598a800995ca95004857e53ab43fb856d543be` (equal for `A/inputs-final1688.sha256` and R).

RT07 artifacts (runtime07.log):
- `driver.c` `ef3e8db49187d724703e9d55290c1017588e2aec41143b23174c0982a4a23d13`
- `driver.o` `110bae531d2bd9a31181806b2e480fc55952374eaca2ffb5e8567f25fa380872`
- `driver-observe.o` `c6940b11c2ed71ff4b98c2de7a48c5c3f41c6f62c306d63a4e43d46544d168a8`
RT06 artifacts (runtime06.log):
- `driver.c` `e63e422bc1c800c5328c573f1c5db50e234f16cfff1708d5703f5eabcd69ee4d`
- `driver.o` `19b17e13077ae36fb55e0d5f432872dde0863d59ce155c8dbdf477d56487cf17`
- `driver-observe.o` `49bcd07c487944f1b657353611f9c2ee287edb698efc9630df01881548cdda2a`
RT05 artifacts (runtime05.log): `driver.o` `5c81fff3ba927aac1837fbe0d4d2c56ef9d6eb0a53a9cefea2d3bac050f9f476`,
`driver-observe.o` `4900b34992e4516e72c1b100db59d294cc9421cab8e89a9a363771e0d0f56c3a`.

Unit07 (descriptor-one07.log): test source `9c51ec3f2186b9552f2e0da044508f2b14180dde4295789549584201da1d1bba`;
generated `.h.lm1` `f4185ad3cdc7b5f09f69523b4719d61451bb3cb72365fae73ef01534cd4be10e`;
generated `.lm1` `deb1c44dd75ba52f6cb2ad0cb995f558791a541daf395738a4c02409684570e6`.
Unit one06 (descriptor-one06.log): test source `da88035562ded871e28b50a78a5eb6af9570a80c4b78f1891631787a7881ac40`;
generated `.h.lm1` `f4185ad3cdc7b5f09f69523b4719d61451bb3cb72365fae73ef01534cd4be10e`;
generated `.lm1` `e319bf1c12d6427962b3df294c2cb2a733b61c0700937dc07a3dd86ab19da302`.
Unit one05: test source `1a3dd28cc5fe829e2aaafb6e448a6b0d38d383c8c8576799d6503c99037583eb`.

Graph translator (graph01.log): `graph_trans-prod.exe`
`d485e9c0c302c4f710567c0ced748cb2bb0f0f1e3744e2233b5968318046a653`; `l2_graph_tool.lm2`
`31e457e2eede3ec7b9d4a2e07f881b0334b2b0655d224b3cd46e88a1025d39c9`.

Frontend FEH01 (frontend01.log):
- `l2trans.exe` `11d9e81097588822ed080fdaf89ee8bbca8460c0d2bec9a7d3778469429bb487`
- backend `l1trans.exe` `562c9c6310aa6d408db952fe4c54e2f0d43ebc3237760ae54cfa9e75d185a676`
- `l2_libc.o` `af9fdae33655f8e6235310720787102921450f0f88f9b7bb2f365d372f553d37`

Tool tool01 (tool01.log): `lmxtool-tool.exe` `995854b6dca958fbaa187b11f94825f861f9b3ecd01ebc771c64ca2c3a994585`;
`lmxtool.lm1` `ae5b99cd104c49e3c5625ac12f21e57b97bba48ec0f0043e832874f36512603f`;
`lmxtool.c` `ea48a06e87058f3165c1bdac8a129b5ff1a21490676ed54cc5f00c2f71e88f9a`.

## 6. What the final witness still needs (all pending)

1. Reconfirm the frozen sources and candidate commit before continuation; do not link W3 host objects to W4 headers.
2. The final targeted15 on the final sources (the targeted run predates RT07 and the changed unit), with the old
   expectations; the status of `graph_call_frames` case 122 and of `immutable_reached_write` (an old refusal, the
   same on the W3 baseline).
3. G1 and G2 generations from sources with a record of artifact comparisons, as W3 had them.
4. The scanner hunk (`l1_binds_native`) and the L1 text that now carries the install call, shown by a built
   program, not by source.
5. An explicit sentence that the source-level `sys/native` receiver is NOT part of this component (section 1), and
   that this unit shows no raw `Array`, M14 or `sys` query claim; plus the other open steps (W5, M13, M14, 27.10,
   the 32-bit ABI) from the lead's wording at that time.
6. Identify the saved candidate with git log -- to_sol.md; publication is not final ABI acceptance.

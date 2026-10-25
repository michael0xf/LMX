# Slice203: clock, process deadline and scheduler arithmetic in L2

Verified203; code SHA is recorded after the code commit. Base record `3a59de68` / Verified202 code `b6d6b454`.
Codex is sole writer/build; Opus remains stopped. Frozen202 is unchanged.

## Maintained implementation

Three actual L2 modules contain15 functions: clock8 (7 retained public operations plus one pure elapsed helper),
process deadline3 (arm/disarm/native OS callback), scheduler4. Fourteen selected machine names retain13 public
header entries plus the existing native OS callback's name;
the normal machine generator also emits the private elapsed helper's C name. No hidden unit/arena/root/state.
Clock reads the OS once and passes explicit `uint64_t` start/now into the ordinary L2 elapsed helper.
Actual generated C has `uint64_t` parameters, all three call temporaries and result, not `ulong`/`size_t` aliases.
The platform-word clock still reads GetTickCount64 directly. Saturation, modular comparisons, wait clamp,
per-operation watchdog arm/signal/join/handle close and caller-supplied scheduler readings preserve the old algorithms.
No new C helper, algorithm hidden in an L1/C string, language/parser/admission rule, platform facility or type dictionary.

The ordinary L3 recipe gains three header writers, four fputs chunks each;15 writers total, new3 before gc14.
It removes all15 old L1/C outputs before writing/translating them. Bootstrap has now executed all15 writers,
then translated the three new L2 modules before consumers. Six raw comparisons confirm the new3 L1/C headers
are byte-equal to202. The actual records bind source bytes, generated L1 and translated C headers in that order.
The old scheduler prototype comment about refusing zero arena is
historically stale; its field comment, implementation and actual witness allow zero. This port does not invent a refusal.

## Actual evidence and limits

- All three direct L2→L1→C translations and strict C syntax pass with unchanged FE201 sourceDE127434.
  Clock01/03 local C-scalar forms refused unresolved now;02 outer binding later produced a reference symptom.
  Those forms are NOT reported fixed. Clock04 uses the ordinary typed helper; no compiler exception was added.
- One small L2 native machine-main timing witness runs the actual current generated module bodies, not driver202.
  With runtime argc1: wide18446744073709551614, future0, half9223372036854775808, wait7, wrap-state2,
  arm0(success), closed0, failed0, exit0. It checks armed1 before one disarm/join and reset handles.
  This is Windows x64 native C-door transport, not walked callback bodies or a fatal-expiry campaign.
  Source638EBAF1, L1 383F10EE, C455BE39F, EXE766F0005; real commands/logs are retained.
  Witness01 hit the known opaque-actual/later-call limit;02 raw C-member actual emitted invalid C;
  03 splits output calls and uses an explicit int cast. Earlier sources/logs remain; neither compiler issue is closed.
- Three creating source patches replay at zero fuzz, raw cmp and source hashes pass.
  Source/header diff lists only new3 L2 files and their generated L1; headers currently equal202.
- Seed01 failed at translation because a stray plus preceded fn decl_clock; its recipe7F9F5198 and real log remain.
  The source typo is corrected, not bypassed. Seed02 with recipeA2D7BE50 completed: exit0,
  `REBUILD tool 0 failures`, start/hash/smoke pass. L1 A463477F, C EF75A10B, EXE2FD27BC0.

Seed02 links the ABI-compatible frozen runtime202; six raw header comparisons passed before the run.
No preliminary runtime203 was compiled: the one subsequent full short bootstrap built the new22-module kernel,
executed all15 writers and new3 module translations before consumers, then smoke/G1/G2. This seed's old-runtime
smoke is not claimed as proof of those new bodies or header-generation route. No new build/test system was added.
The new bootstrap runtime compiled production and observed objects, and smoke6/0 completed. All four actual
native/forced root0/1 logs retain41,41,42,42,43,42, after A1 count100 results101/43, candidate142/y42/x1/pad9/w10,
refusals30/33/34, callable3/8. Actual runtime C retains wide uint64_t arguments/temporaries and direct word read.
The new frontend regenerates the timing witness to EXACTLY the existing03 L1/C, with the same headers/backend/
C compiler/flags/support object. That compiled EXE and its real output are reused; no redundant C compilation
or new timing execution is claimed. This is a byte comparison, not an assumption from unchanged source names.
ONE short bootstrap completed, exit0/0 failures, smoke6/0; operator-observed interval1385s, not a profiler.
G1 actually built G2; both tools started/hashed their source and replaced the working binary.
G1 EXE A8E62E10; G2/working54CC0B07. Seed/G1/G2 L1 A463477F and C EF75A10B match;
normalized EXE-SAME1 is not raw EXE equality. The existing language verifier passes32 expected equalities.
Manifest148 passes both that verifier and independent GNU sha256sum, terminal0.
The ordinary GCC dependency query, after pipeline terminal and with the actual runtime include order,
selects203's generated clock/deadline/schedule and storage headers, not another stage's copy.
Runtime C E2BD0DAA, production object09B85190, observed objectCB6C59BB; FE203 EXE32744311.
Compiler sourceDE127434 and compiler C C82A106F remain unchanged. Final source/header diff lists only
the three L2 additions and their generated L1; all headers remain byte-equal to202.
The port count is22 of35. The remaining13 modules, driver, full translator/tooling closure, true self-build,
runtime-callable/Q49 and all mail contracts/T01–T26 remain OPEN.
No full bootstrap, broad corpus/gate or fatal-expiry campaign was run. Bootstrap tool generations are not S8.6.
Record copies use LF and trim trailing whitespace; the manifest pins original raw stage bytes.
Creating source patches are raw, not normalized record text. Frozen203 inputs will not change after publication.
The repo recipe may advance later; this recipe remains at build2/codex_fix203/tools/build.lm2.

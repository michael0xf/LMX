# Slice201: the existing mailbox algorithms in L2

Verified201; code SHA is recorded after publication. Base is record `fc4d4be4` / Verified200 code `fd86effe`.
Codex is the sole writer/build; Opus remains stopped. Frozen200 is unchanged.
Stage `build2/codex_fix201` copied only src/headers/tests/tools, excluding the protected basename.

## Implementation and measured boundary

`lmx_post.lm2` contains26 real functions (22fn/4sub),23 retained C entries and3 private helpers.
Ring growth, snapshot, admission, inseparable target/donor pairs, receiver attach, FIFO, cursors,
staged publication/discard and close are L2 bodies, not strings or wrappers over old handwritten L1.
Typed locals address the same embedded pool/API records; mailbox layout and public signatures are unchanged.
The original C header remains byte-equal (`1DCA7325…`). This is not a language/admission change.

The unused-value TLS token is removed, not relocated into an L2 unit/arena/library graph.
Both monitor paths use the existing `lmx_manager_running_thread_id`, whose current Windows backend calls
GetCurrentThreadId. The owner/depth/atomic gate still belong to this mailbox. There is no new lock,
platform mechanism, current-Thread lookup, provider registry, source-graph field or hidden root.
Microsoft documents live thread-ID uniqueness and nonzero IDs in
[Thread Handles and Identifiers](https://learn.microsoft.com/en-us/windows/win32/procthread/thread-handles-and-identifiers).
Other OS support is not added or claimed by this port.

The changed ordinary L3 recipe prints the entire post header in16 writes. It has12 writers;
post is before copier/Thread and gc, all12 old L1/C outputs are removed before writing.
Post is the last L2 module translation, without `--header`. The actual new writer has now executed in
bootstrap: exact post-header bytes `DC9F4E81…` and C header `1DCA7325…`, before copier/gc consumers.
The new frontend actually translates post source `62985E48…` to the same generated L1 bytes.
The preliminary runtime used T200 and the directly translated post04 L1; the bootstrap runtime regenerates them.

## Actual results so far

- Direct post04 L2→L1→C and strict C syntax pass. Only unused-result-temp warnings remain.
  Draft01 misclassified pointer-to-void results as sub; draft02 then refused old L1 nested dot field heads.
  Typed pool/API aliases fix those source forms, not the compiler. Draft03 retained stale pointer/integer
  conversion warnings;04 stores pointers as pointers and explicitly casts the collector snapshot address.
- Runtime201 is terminal: `REBUILD runtime 0 failures`, smoke6/0, exit0. All four preliminary AND final bootstrap S81 value logs
  were read:41,41,42,42,43,42; after A1 count100 results101/43; runtime candidate142/y42/x1/pad9/w10,
  refusals30/33/34 and callable3/8, unchanged. Bootstrap runtime C/objects equal the preliminary bytes, and its
  smoke6/0 is complete. This does not close arbitrary runtime-callable/Q49 or the whole bootstrap.
- One small maintained L2 machine witness, not a new runner or the full old L1 MPSC/corpus migration,
  compiles and runs with the actual kernel bodies. Worker argument arrays/counters/start gate are caller-owned
  and live through both joins, not module globals. It observes:
  `POST wrapped count=4 capacity=4`;
  `POST producers A=64 B=64 delivered A=64 B=64 total=128 ids=1`;
  `POST checks failed=0`, exit0. Reentry/depth/gate and staged publish/discard checks also pass.
  This is native OS/C-door callback transport, not interpretation of a machine body or all mail/ownership cases.
- Two recovery patches replay at zero fuzz and both raw comparisons pass. Source diff is exactly post L2,
  generated post L1 and header comments; all C headers equal200. The replay record explicitly identifies its
  normalized terminal copy rather than claiming an original tee sink.

## Inputs and pending work

- Post L2 `62985E48…`, generated L1 `E9C43BD4…`, direct C `B2F154AD…`.
- Post L1 header `DC9F4E81…`, C header `1DCA7325…`.
- Repo/stage recipe `7BA2E8BF…`; compiler source unchanged `DE127434…`.
- Preliminary runtime C `BFB2D9F9…`, production object `84FEA515…`, observed object `89565FE1…`.
- L2 witness source `D117CC22…`, actual EXE `9659EA52…`.

Seed201 completed: `REBUILD tool 0 failures`, exit0, start/hash/smoke pass; EXE `FD9B5241…`.
ONE short bootstrap201 completed: exit0,0 failures, smoke6/0; observed interval1315.477s.
G1 actually built G2; both new tools started/hashed their input and replaced the working binary.
G0/G1/G2 generated tool L1/C are equal, normalized `EXE-SAME 1` passes; raw EXEs differ.
G1 EXE is `43AD7A5275535881AB1CF2FA5249EEA64D6BC58959FF8D44277EF904BF662DF3`;
G2/working EXE is `CC64B0F87F359A1854FFA5E3E5748196FBD206858D6BBAE43F50BC7249C4CDF0`.
The existing verifier confirms all22 expected equalities; manifest123 passes it and independent `sha256sum -c`.
The actual read-only GCC query uses the ordinary runtime include order/flags and selects201's post/storage headers.
No whole-runtime-outside-post C equality is asserted: this port intentionally removes TLS identity and adds the
existing platform-service dependency. Source-diff and old/new C-header equality are the measured narrower boundaries.
No broad gate, corpus, mutant campaign or full bootstrap added/run; the witness is measured on this Windows x64 target.
This is the19th of35 modules, not a completed self-build. Thread/walker context state, the other16 runtime modules,
driver, translators/tooling closure, arbitrary runtime-callable/Q49 and the real L3+L2 self-build remain OPEN.
Next small dependency candidates: clock, process-deadline and scheduler arithmetic; their current sources were read,
but no202 source or build is included here. Record copies use LF; the manifest pins original raw bytes. The live
repo recipe may change later; this exact recipe remains in `build2/codex_fix201/tools/build.lm2`.

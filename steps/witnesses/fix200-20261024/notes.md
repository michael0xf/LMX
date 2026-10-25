# Slice 200: stateless common call in L2, explicit status/value transport

Verified200: runtime, seed, focused checks and one short bootstrap passed.
Published code: `fd86effe8a2290e0c9bedfcb693d69bf143cb265`; origin/main was independently read back.
The actual Git blobs of the recipe, L2 witness and all eight recovery patches equal the verified local bytes.
This is not the completed L3+L2 project self-build. Frozen200 is no longer modified.

Base: main record `4ef67c95` (Verified199 code `b75875e0`), frozen `build2/codex_fix199`.
Current stage: `build2/codex_fix200`, copied input directories only. Codex is the sole writer/build;
Opus is stopped. Frozen199 is unchanged. This is one runtime-module migration and its closed ABI dependencies.

## Implementation and dependency closure

- `src/l2src/lmx_call.lm2` has 15 real L2 functions (7 `fn`, 8 `sub`), with 13 public C entries.
  The call/publication bodies are not strings or wrappers over the former maintained L1 implementation.
  Seven obsolete hook/status functions and the four mutable call globals are removed, not relocated into
  an L2 unit, arena field, singleton, hidden module graph or library root.
- A selected nonzero native word calls its uniform `LmxPrimitiveEntry`; zero calls the statically linked
  common walker. No runtime hook installation, callback-identity inference or provider search remains in this module.
  Ordinary `call_prim_values` still transports the same explicit arena, code, data, declared-width storage
  and input/result context. Publication still stores already-computed dirty values at admitted physical places.
- The host/nullary `call0[_mode]` now RETURNS status and writes its activation int through an explicit output.
  It does not reinterpret a value as a turn verdict. This host transport is not language unary-call data selection.
  The walk failure helper returns the decoded selected-callee status; walker errors1–7 still abort, without
  writing a global last-failure cell. Both walker bridges return that result directly.
- Each Thread initializes/resets its own `body_status` service field and records its actual completed body status
  before the end boundary. This does not add a field to the source graph or Message prefix. The optional explicit
  output of `lmx_root_launch_result` copies it before teardown; existing launch/tapped signatures remain wrappers.
  The existing driver receives this output and uses the new separate call0 status/value channels.
- The existing L3 recipe prints the whole 4,158-byte call header in five ordinary `fputs` chunks.
  Eleven writers run before consumers, call before gc/Thread. All eleven generated L1/C headers are removed first;
  write/translation failure stops the route. The call L2 module is translated last, without `--header`.
  No language, grammar, parser, library signature rule or separate admission mechanism changed.

The seven bridge inputs are call.h, walk, thread.h/thread, root.h/root and the existing driver.
The source-creating call patch plus these seven diffs replay with GNU patch `--fuzz=0`; all eight raw `cmp`s pass.
The bounded source diff is exactly those inputs, new call L2 and generated call L1. C headers differ only for
call, root and Thread. The bridge changes are intentional, so no whole-runtime-outside-call equality is asserted.

| Input/output | SHA-256 prefix | Evidence |
| --- | --- | --- |
| maintained call L2 / generated L1 | `8099D18A…` / `784A7439…` | source/replay, direct translation and ordinary module step |
| repo/stage recipe | `C1A1A87D…` | L3 writer and normal machine module step |
| unchanged compiler source | `DE127434…` | old frontend and new bootstrap frontend input |
| call L1 / C header | `AE6EF665…` / `16208B24…` | explicit initial ABI output and actual L3 writer output |
| runtime C / production / observed object | `D40AC4A2…` / `843CB6AC…` / `5AA4D9A1…` | bootstrap equals preliminary runtime |
| seed tool L1 / C | `DAEED0A3…` / `92C40C31…` | actual seed build |
| status witness source / EXE | `B565E648…` / `3FDB63F0…` | actual L2 machine source and successful run |

## Actual results

- Direct call05 L2→L1 succeeded. L1→C and strict C syntax completed with an unused-result-temp warning.
  Silent commands produced no Tee sink files; `gen/direct-results.txt` records that fact, not fabricated empty logs.
  Earlier call01–03 used the wrong frontend CWD and failed before valid predef resolution. Call04/05 use `stage/src`,
  as the ordinary recipe requires; no compiler fix was made. Function-pointer locals use type-headed initialization.
- Tool199 builds runtime200: `REBUILD runtime 0 failures`, smoke6/0. The new recipe's seed builds and starts/hashes
  its input correctly, runs the same smoke, then returns `REBUILD tool 0 failures`, exit0.
- The existing computed caught-payload fixture `os_throws` gives7 native/forced, root0/1: one row,0 failures.
  The first ad hoc suite invocation used a relative OUT and failed before runtime. The additional ordinary entry
  correctly refused an unhandled `Bad`; it is not a successful runtime case. Its source/log remain in the stage.
- The separate machine ABI witness is L2, including all assertions. It uses the actual current kernel and explicit
  source-names dependency, not a C helper, duplicate harness main or a new test system. Actual native callback
  observations are `(status,value)=(0,41),(3,81),(5,42),(0,82)`: live per-object counter/status cells, not constants.
  Values printed by a failing producer are observations of partial effects, not promised successful ABI results.
  A caller-owned Root then runs its callback: `CALL status=3 value=41`, `THREAD status=3 launch=1`,
  `STATUS checks failed=0`, process exit0. The failed-child arena report records the real int cells41/3.
  Root performs normal close; the direct A/B owner arena is released once.
- Bootstrap200 actually executed the new call header writer and rebuilt the same runtime bytes.
  Terminal result: `BOOTSTRAP quick 0 failures`, smoke6/0, process exit0; observed interval1,283.322s.
  G1 built G2, both new tools started/hashed their input, and each replaced the working binary.
  G0/G1/G2 generated tool L1/C are equal; normalized `EXE-SAME 1` passes, not raw EXE equality.
  G1 EXE is `9BB8B052E733F7D107D60E00FA9761F47C3FFB6AA558AEEAC5344B35D1B7A6D9`;
  G2/working EXE is `D789E7196B9DED08E76B190A33D035602DF3241AA158E01D553DA22FD1F4F04D`.
  The existing L2 verifier confirms all29 expected equalities. Manifest160 passes the same verifier and
  independent `sha256sum -c`. The original manifest targets are unchanged after verification.
  The read-only GCC dependency query uses the actual runtime flags/include order and selects this stage's
  call, Root, Thread and storage headers; no old maintained header is a selected fallback.

All four preliminary AND final bootstrap native/forced root0/1 owner logs were read: calls41,41,42,42,43,42; counts42,42,43;
after A1 count100, results101/43; runtime merge candidate142/y42/x1/pad9/w10, refusals30/33/34 and callable values3/8.
Final value logs have the same raw hashes as the preliminary logs and the prior verified slice.

## Boundaries

This proves the measured native ABI/status transport, not execution of this C-door machine body by the walker,
not every named exit/payload, arbitrary runtime-callable/Q49, full native-equivalence guards or general admission.
The existing walker program-role/qualified-root globals and OS-lane current-Thread mechanism are separate remaining
ownership/context work; no claim that this slice removes every kernel global is made. General C-member typing stays OPEN.
This is the18th of35 runtime modules. The other17 runtime modules,
driver, both translators, tooling closure, the real L3+L2 self-build and mail T01–T26 remain unfinished.
No broad gate/corpus/mutant campaign, runner extension or full bootstrap was added/run.
Record copies use LF; the manifest pins original raw bytes. The live repo recipe may deliberately change later;
this slice's exact input remains `build2/codex_fix200/tools/build.lm2`.

Next: mail/Thread, preserving actual owner-local state and the common OS-lane identity rather than moving TLS into
an L2 unit. The existing `lmx_manager_running_thread_id` was found while preparing that port; no201 input or build
is included here. All current compilation processes have terminated; no second bootstrap was run.

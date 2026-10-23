# Slice 170 notes -- the L2 runner in L2, os branches with full bodies, bitwise operators

Opus, 2026-10-22/23 (to_opus.md; Codex stopped, consultant only). Stage `build2/opus_l2tools170`; inputs: the
281 files of the published Verified169 input set (`inputs170.sha256`, bootstrap-protocol.md step 1). Two of
them change: `src/l2src/l2trans.lm1` (the translator) and `src/l2src/lmx_walk.lm1` (the kernel walker, only
inside `ifdef: LMX_OBSERVE_WALK`); `stage-inputs.sha256` lists all 281 with their present hashes (written by
`lmxtool manifest`). Protected basenames are never read, hashed, copied or staged: a driver run writes
`l2_driver_launch.err` in its cwd, so runs use their own directories and every manifest is an explicit list.

Requirements: CODEX-AUTHOR-TESTS-SCRIPTS-L2L3-20261022T222439Z (Q1: the OS API through the C door, one
process contract, os branches; Q3: a one-time bootstrap kept as a protocol, then the L2 runner builds its next
version), CODEX-AUTHOR-L2L3-NO-FALLBACK-20261022T223831Z, OPUS-CODEX-20261022-OSBRANCH (P1/P2 now, P3
OPEN), CODEX-AUTHOR-OS-WALK-BODY-20261023T001133Z, CODEX-AUTHOR-OS-COMMON-PIPELINE-20261023T013324Z.

## 1. The L2 runner (tools/l2)

Program `lmxtool.lm2` (main source: its os block and the commands) with the parts `text.lm2` (texts,
files), `winargs.lm2` (the CommandLineToArgvW quoting rules), `sha256.lm2` (FIPS 180-4 in L2),
`replay.lm2` (rows, stage copies, manifests, the corpus replay, the record's executables), `build.lm2`
(the build recipes, L1 inspection, PE identity, the os walk witness), `suite.lm2` (the fixture suite, the
gate); the self-test's child `lmxchild.lm2` (part `text.lm2`) is a program of its own. Built with the
production runtime at -O0, `-lshell32 -lbcrypt`. Commands:

    selftest DIR [CHILD]                 the process contract, hashing, the evidence commands
    build-child REPO STAGE BASE FE RUNTIME OUT      tools/l2/lmxchild.lm2 -> OUT/lmxchild-prod.exe
    sha256 FILE | manifest LIST ROOT OUT | verify MANIFEST ROOT | stage-copy MANIFEST FROM TO
    deps RECORD                          the executables a run record started; fails on a script host
    same A B | exe-same A B              byte identity; PE identity apart from TimeDateStamp and CheckSum
    rows PS1 OUT | replay ROWS SANDBOX WORK FE-A FE-B OUT FIRST COUNT     the corpus replay
    suite LIST REPO STAGE BASE FE RUNTIME OUT [OBSERVED]                    rows runs/refuses/twins
    os-walk-witness REPO STAGE BASE FE PROD OBS SOURCE OUT ENTRY SPEC
    build-frontend REPO STAGE BASE LABEL | build-runtime REPO STAGE BASE LABEL
    build-self REPO STAGE BASE FE RUNTIME LABEL
    gate REPO STAGE BASE FE CENSUS-FE MUTANT-FE RUNTIME OBSERVED LIST CENSUS-LIST OUT

The process contract (`os_run`, win branch): CreateProcessW of an explicit path (no search, no shell, no
system()), the command line built by the CommandLineToArgvW rules, stdin from NUL, stdout/stderr to the
caller's files (or NUL), the child's cwd, a job object for the whole tree, the timeout by
WaitForSingleObject; kinds 0 exited (its code), 1 not started (the OS error), 2 stopped at the timeout
(the tree killed), 3 lost while waiting, 4 not prepared. The self-test: spaces, an empty argument,
`x&y|z<>^%!`, quotes, Unicode (`юникод ✓`), trailing and inner backslashes before a quote, exit codes and
the driver's own exit, both streams, cwd, the timeout (kind 2 at 500 ms, returned before the child's 3000 ms,
the stopped child never wrote its mark), spawn failure (kind 1 with the OS error), the platform hash against
FIPS vectors and the L2 SHA-256, and the evidence commands (manifest, verify of a changed and a missing file,
deps with and without a script host, same, exe-same of the image, another stamp, another byte, no image).
Kind 3 has no test (no way to provoke a lost wait). The default (POSIX) branch: fork/execv, a process group
of its own, a close-on-exec pipe for a failed start; not executed here (no POSIX toolchain): OPEN.

The self-test's child is `lmxchild` because a launch of the -O0 lmxtool takes 60 to 97 s here (the graph
build of RANGE-CELL-POOL-LINEAR): with the tool as its own child, the 60 s process checks would time out and
the timeout check would kill the child before it ran. The child's os methods repeat lmxtool's of the same
names, as a program part holds no os block yet (P3).

The tool's arguments are the C runtime's (ANSI) argv: this host's ANSI code page is 65001 (UTF-8), so a
path with `юникод` or `✓` arrives whole (measured: `sha256` of such files); a host with a legacy code page
is not measured: OPEN.

No PowerShell, Python, shell, batch or cmd script is started by the runner: `deps` reads every record and
fails on one (the gate checks its records). The old runners (tools/*.ps1, *.py) are not inputs of the
isolated gate (section 5).

## 2. os branches with full method bodies (translator)

L2 section 20 sets an explicit choice of a platform branch, not its phase; the deferred choice stays (L1
`os:` -> C `#ifdef _WIN32`), never the translator host's platform. The os adapter:

- variant: `l2_translate_program` translates a source with an os block once per branch it has (win, then
  default), each from its own fresh P0 parse of the same bytes (a translation writes its tree: a second
  translation needs its own parse) and through the whole common pipeline; `l2_os_select`,
  `l2_os_selected_branch`; the first parse only learns the branches (`l2_os_root_branches`) and translates
  nothing. These parses are the variant mechanism, not a fallback: all of them run for every os program,
  none runs because another failed, none reads a body again as text; a refused branch refuses the program,
  which publishes nothing.
- scope/dependencies: the selected branch's directives are taken by the unit's own takers
  (`l2_os_directives` -> `l2_take_predef/define/include`), its methods by the unit's collector
  (`l2_collect_os_methods` -> `l2_collect_method(item, path, -1)`), and the source census of the unit's
  methods reads them as the root's declarations (`l2_root_names_method` -> `l2_unit_names_method`, both
  ways; `l2_items_defined_fn` -> `l2_unit_defined_fn`, a forward header's definition).
- checks of the block itself: `l2_check_os` (win/default once each; methods and include/define/predef only;
  a counterpart of the same name in every branch, any order); `l2_os_contracts` (each method's contract --
  result, declared throw exits, formal names and types in order, hidden inputs; a foreign type by spelling --
  equal in every pass, else a located error with the other's place; the implicit status channel of live
  arithmetic is the platform body's own, each pass being a whole program with its own ABI).
- conditional wrapping: `l2_os_compose` writes both programs as one L1 os block (`l2_pub_commit`).
- removed: the literal-only `l2_check_os_fn`, `l2_emit_os_fn`, `l2_emit_os`, `l2_os_branches_match`,
  `l2_method_is_os`; `l2_source_atom_n` is reset per translation (deterministic branch outputs).

After collection the method table is the closed result every consumer reads: checks, types, maps, effects,
the retained COUNT (`l2_rw_methods_count` over `l2_m_n`) and EMIT, the walkability and the native word
(`l2_emit_native_word`: the knob walks a body with a completed lowering, the same predicate for every
method), the occurrence (`l2_occ_slot`: not a direct child of the unit, so the unit's tail as a part's
method; the os block keeps its source slot as inert source, as a directive does). `l2_method_in_os` serves
only `l2_os_contracts`. No os opcode, emitter, interpreter or name-based exception exists.

The census defect (OS-METHODS-MISSING-FROM-SOURCE-CENSUS, found by os/unit twin probes on frontend-05,
fixed in frontend-06): a named Structure's body calling an os method declared below was refused ("an
unknown head needs a Structure body"), a forward header at the root with its definition in the branch was
"duplicate definition", and the root's `os_bump: 3` and a vertical call above the os block SILENTLY declared
a named Structure os_bump (exit 4: the call never ran). The 11 twins (tests/l2/os_twins) pin every form:
the same exits, and per method the same native word and the same number of walked bodies as its unit twin
(natively a native word and no walked body; under --walk-methods no native word, at least one).

Walked bodies: `tests/l2/os/os_walk_values.lm2` (parameters, locals, a call of the other os method, a field
written twice and read by the caller; win and default bodies differ) -- the forced L1 binds no native word to
os_mix and os_twice and the observed runtime says `LMX_OBSERVE WALK_BODY os_mix` and `os_twice` twice each,
at the root and with walkroot 1; natively none. Controls that must fail: the constant twin
`os_walk_values_const.lm2`, and the native-substitute frontend (`mutants/osnative-02`, one line: the knob skips
os methods) -- both fail the witness; each forward twins row (`tests/l2/census170.tsv`) fails under
frontend-05 (= frontend-06 without the census fix, `mutants/census-control.patch`).

Bodies whose lowering holds a retained machine operation (a C-door call, address arithmetic, a bitwise
operator) stay native under --walk-methods for every method, os or not (`l2_m_why`: "retained machine
operation has no interpreted implementation"); such a method has its native word and no walked body, and
the selection is made at translation, never after a failed walk.

OPEN: P3 (an os block or a directive in a program part; several os blocks); the POSIX execution and ABI of
every default branch.

## 3. Bitwise operators (part of BITWISE-OPERATORS-NOT-CLASSIFIED)

Binary `| ^ & << >>` with C precedence (1 `||`, 2 `&&`, 3 `|`, 4 `^`, 5 `&`, 6 `= !=`, 7 `< > <= >=`,
8 `<< >>`, 9 `+ -`, 10 `* / %`) in the one operator list every classifier reads (`l2_rw_prec`); a shift's
count keeps its own type; refused: a reference operand ("a reference where a number is asked"), mixed operand
types ("mixed numeric types (a conversion)"); native code is C's operator. OPEN: the walker's evaluation (a
body holding one is native-only under --walk-methods, so the registered witness `unit_bitwise_and_return` --
169 refused, 170 translates: replay row 1402 -- exits 2 with f native and does not witness the fix); the
rejection of a shift count outside [0, width) and of a signed left shift's overflow before the C operation in
both engines, as signed ADD's; unary `~` ("unsupported body" at the declaration). The walker's evaluation is
a kernel change (opcodes of lmx_walk) that waits for the kernel gate in L2.

## 4. The observed runtime (kernel, src/l2src/lmx_walk.lm1)

`ifdef: LMX_OBSERVE_WALK` holds `lmx_walk_observe_body`, called from `lmx_walk_load_body`: a body the walker
enters is said on stderr as `LMX_OBSERVE WALK_BODY <name>`, the source name of the unit cell holding its
code (a method with header parts), else of the code itself (a sub's occurrence), else `-`. Compiled only into
`driver-observe.o`; the production `driver.o` of runtime-02, -03 and -04 is byte-identical to Verified169's
`actual-02` (c026245020cc2e54...).

## 5. Evidence

Hashes: `evidence-02.sha256` (tool-19's `manifest` over `evidence-02.list`, 55 files, paths relative to the
repository root; also re-verified by GNU sha256sum) pins the frontends with their sources and C, the mutant
frontend, both runtimes and Verified169's `driver.o`, the fixpoint pair, the gate's output and every record
of it, the replay's rows and results with 169's frontend and tools/l2_harness.ps1, the four published patches
with their replays, and the long vector's run. (`runs/evidence-01/evidence.sha256`, 40 files, was written
before the patches were cut without context lines, as Verified169's U0 patch is; it stays in build2.)

- Fixpoint: `tool-18` (built by `tool-17`) and `tool-19` (built by `tool-18`): lmxtool.lm1 86702f388ec8718d...,
  lmxtool.c 2be45e1ba6f9857d..., lmxtool.o identical; EXE identical apart from the link stamp -- the tool's own
  `same` and `exe-same`; the sources unchanged during both builds. The earlier pairs reached it too
  before the next changes (tool-10/11 compared by cmp and a masked comparison outside L2; tool-14/15 and
  tool-16/17 by `same` and `exe-same`).
- The isolated gate: `iso-03` holds only verified copies (`stage-copy` of manifests written by `manifest`):
  the 281 stage inputs, frontend-06, frontend-05, the mutant frontend, runtime-04, tool-19, bin/l1trans.exe,
  dev/l2src_sandbox/tests/unit_os_prologue.lm2, tools/l2, tests/l2 and the three base files; no
  .ps1/.py/.sh/.bat/.cmd; its OUT's parent did not exist. Its gate (`lmxtool gate`, 2026-10-23 02:50-03:11;
  `gate-03.out`, `gate.txt` "GATE 0 failures"):
  - the self-test's child built at -O2 (`lmxchild-prod.exe` 6477ec89649e4078...);
  - the self-test: SELFTEST 0 failures (every case of section 1: the eight arguments, the exits, the streams,
    the cwd with a space, the timeout, the spawn failure, the hashes, the evidence commands and their
    negatives);
  - the suite (`tests/l2/suite170.tsv`: 6 runs, 14 refuses, 11 twins rows): 427 checks, 0 failures, each
    refusal at its located needle;
  - the os walk witness: OSWALK 0 failures (section 2);
  - the controls that must fail, and did, each for its own reason: the constant twin (its 8 exit checks; its
    bodies still walk), the native-substitute frontend (6: a native word bound to os_mix and os_twice, their
    bodies walked 0), each census row under frontend-05 (row 0 "an unknown head needs a Structure body" at
    8:14; rows 1 and 2 exit 4 against the twin's 7 and os_bump walked 0 against 1; row 3 "duplicate
    definition" at 11:9), an expected exit 8 the program does not give (os_bodies), and a repository
    without `bin/l1trans.exe` (kind 1, not started: the build fails, it is never skipped);
  - `deps` over the gate's records: the child's build 3 executables, the suite 102, the witness 7, the
    native-substitute control 7 -- the stage's frontends, the repository's `bin/l1trans.exe`, gcc and the
    built programs; 0 script hosts or scripts.
- Earlier isolated runs (kept): `iso-02/gate-01` -- the tool then made one directory level only and OUT's
  parent was missing: every step FAILED, none passed (a broken environment is a failure, never a pass);
  `iso-02/gate-02` (OUT's parent made by hand) -- the self-test, the suite (198 runs, every refusal located),
  the witness and every control behaved as required, but its `deps` checks crawled (byte loops of L2 steps
  in txt_cat/next_line under RANGE-CELL-POOL-LINEAR) and it was stopped; the texts now move by the C library
  and `dir_make` makes the chain.
- Corpus replay (`lmxtool replay` of tool-10, bootstrap protocol section 4; rows of tools/l2_harness.ps1 read
  as text, 169's frontend-07 against frontend-06, 3,735 rows; `replay-results.tsv`): 3,733 SAME -- 2,236
  translated with byte-identical L1, 1,497 refused with identical diagnostics -- and 2 DIFF, both this
  slice's: unit_os_prologue (the os emission: two composed programs) and unit_bitwise_and_return (169
  refused; 170 translates, f native-only, section 3).
- U0 replay (`runs/u0-replay-02`): the two published patches (no context lines), applied by GNU patch to
  copies of the Verified169 inputs, give the stage's l2trans.lm1 and lmx_walk.lm1 byte for byte (`same`:
  `SAME 1` for both, exit 0; `u0-same.out`). The controls' deltas replay the same way
  (`runs/controls-replay-01`, `controls-same.out`): `census-control.patch` turns frontend-05's source into
  frontend-06's, `native-substitute-mutant.patch` the final source into the mutant frontend's.
- Before the census fix: runs/osfwd-probe-01 (frontend-05: the 4 forward os forms fail, their unit twins pass),
  -02 (frontend-06: all 22 probe rows pass), -03 (frontend-05: the 12 rows whose os block stands above its
  uses pass).
- Not gated: `tests/l2/sha/sha256_million.lm2` (the FIPS 180-4 vector of one million `a`) is no row of
  suite170.tsv: its 15,625 blocks take about 56 ms each (RANGE-CELL-POOL-LINEAR). Run once by tool-19's
  `suite` with a one-row list over the iso-03 copies (`runs/sha-million-01`; `sha-million.out`): exit 7, the
  digest equal, at the root in 890 s and with walkroot 1 in 877 s -- inside the runner's 900 s step limit by
  10 and 23 s, which is why it stays out of the default suite.

Packet (`steps/witnesses/l2tools170-20261023/`): this file and `bootstrap-protocol.md`; the deltas
`l2trans.lm1.patch` and `lmx_walk.lm1.patch` (against the Verified169 inputs), `census-control.patch`
(frontend-05 against frontend-06) and `native-substitute-mutant.patch` (the final source against the
mutant's), all without context lines; the manifests iso-03 was staged from -- `stage-inputs.sha256` (281),
`stage-artifacts-03.sha256`, `repo-inputs.sha256`, `publish-03.sha256` (tools/l2 and tests/l2),
`base-inputs.sha256` -- and `evidence-02.sha256` with its list `evidence-02.list`, all written by
`lmxtool manifest`; `gate.txt` and `replay-results.tsv` (exact copies); `gate-03.out`, `u0-same.out`,
`controls-same.out` and `sha-million.out` (LF copies without trailing blanks: the Windows C runtime writes
CRLF to a redirected stdout, and `PASS ARG 2` of the empty argument ends in a blank; the manifests pin the
originals); `defects/` (the reproductions of section 6).

## 6. Defects and OPEN

Registered in steps/defects.md: OS-METHODS-MISSING-FROM-SOURCE-CENSUS (fixed here), ASSIGN-VOID-TO-TYPED-REF,
C-DOOR-DEREF-UNLOCATED, RANGE-CELL-POOL-LINEAR, GENERATED-CODE-SIZE; BITWISE-OPERATORS-NOT-CLASSIFIED partly
fixed (section 3). Withdrawn after re-measurement: "C-DOOR-RESULT-UNTYPED" (seven forms translate on
frontend-06; the once failing probe translates on 169's and 170's frontends -- an intermediate translator
of this slice failed it); `c.sizeof(@: char)` refused "unresolved addressable name" is the norm
(steps/generated-diagnostic-migration-20260930.md:192, gated unit_csizeof_type_frame_refused).

OPEN capability, no norm yet: the C door names a type by one identifier (`c.NAME`), so a tagged type without
a typedef (POSIX `struct dirent`, `struct timespec`) has no spelling; lmxtool's default branch keeps
os_list_dir and the monotonic os_now_ms OPEN (a question to Codex).

Remaining migration (CODEX-AUTHOR-TESTS-SCRIPTS-L2L3): the corpus table still lives in tools/l2_harness.ps1
(read as text by `rows`; its expectations are not run by the L2 runner yet), the kernel selftests and their
gate (build_l2src.ps1, run_walk_selftest.py, run_l3_selftest.py), stage recipes, doc and relay tools.

## 7. Process

A recursive grep from the repository root scanned the forbidden root `build/` for about two minutes during
this slice (stopped; nothing read from it was used). Memory noted: never recurse from the repository root.

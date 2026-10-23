# Slice 172: one publication call per working field; the bootstrap regenerates the kernel's C headers

Opus, 2026-10-23, sole writer/build. This is the first step of GENERATED-CODE-SIZE, the measured blocker of the L3+L2
self-build (plan section 8, which stays OPEN).

The stage is `build2/opus_slice172`, a copy of Verified171's stage `build2/opus_fix171`. Three inputs change. Each has
a -U0 delta here, and GNU patch applied to the Verified171 input gives the stage's bytes (`u0-same.out`):

| Input | SHA-256 | Verified171 | Delta |
| --- | --- | --- | --- |
| `src/l2src/l2trans.lm1` | `ECD7146ACF7B258CDECB1B23B9CADF60C3E0879784436F62784B9DCECD21E52C` | `3CD010A2…` | `l2trans.lm1.patch` |
| `src/l2src/lmx_call.lm1` | `63D07B32B5827FDB9B6F7B216026CA5609ED0D768BCF0C542D741FB1F3487C01` | `8664A70E…` | `lmx_call.lm1.patch` |
| `src/l2src/lmx_call.h.lm1` | `9C2E9E3EC8BC066FE20B901E54BB6EBB9C8451E5D53FB6BEE0BE7A9DD6B1EADB` | `2C27B0B2…` | `lmx_call.h.lm1.patch` |

The runner's sources are `tools/l2`: `build.lm2` and `suite.lm2` change.

## Why

Verified171's tool, 4,805 lines of L2, lowered to 1,288,302 lines of L1 (72.3 MB), about 270 L1 lines per L2 line.
The largest part was the publication of working values at boundaries (L3 section 12):
- 63,771 inline blocks of 12 to 14 lines, against 1,518 write sites;
- every boundary publishes every working field the method writes: a call, a C-door call, a throw, a return, an
  arithmetic operation's implicit throw.

## What changed

Kernel (`lmx_call.lm1`, prototypes in `lmx_call.h.lm1`): `lmx_publish_int`, `_char`, `_size`, `_unsigned`, `_ulong`
and `_pointer`. When `dirty[0]` is set, each one does:
- the program's write guard, when `guard` is set: a cell under a qualified root, or in a sealed range, is the walk
  error INVALID, as at every guarded write;
- the typed store with its invariant (abort with "own field k store failed");
- clearing the mark.

Translator: `l2_emit_publish` writes one call per working field. A slot field keeps its inline binding. The guard
arguments come from the same program facts as before (`l2_ebr_n`, `l2_qmerge_n`), so a program without qualified
roots or merges gets `0, 0, 0U` and no guard test. A program with qualified merges only gets `1, 0, 0U`, and
`lmx_range_has_root_profile` answers 0 for no roots, so only the sealed test remains, as before. The old blocks
re-located the cell first (`if from = 0 ...`). That was dead code: the prologue locates every cached field's cell or
aborts, and nothing clears it.

Nothing else changes: the same boundaries, the same fields in the same order, the same stores, guards and invariant
texts. A snapshot comment in `l2trans.lm1` is re-wrapped.

Runner: `bld_headers` (`build.lm2`) translates again, with `bin/l1trans.exe`, every kernel header
`STAGE/headers/<dir>/X.lm1.h` whose source `STAGE/src/<dir>/X.h.lm1` exists. It is the first step of `bootstrap`
and of `rebuild runtime` (`suite.lm2`). See BOOTSTRAP-HEADERS-STALE below.

## Results

Size (`size.txt`; `l1_size`-style counts over each tool directory, step times from the files' modification times).
The same input, the 172 tools (4,879 lines of L2), through the 171 frontend (`tool-pre-01`) and the 172 frontend (G1;
G2's L1 and C are the same bytes). Verified171's own tool is given for reference:

| | Verified171 G2 | `tool-pre-01` | 172 G1 |
| --- | --- | --- | --- |
| L1 lines | 1,288,302 | 1,315,376 | 597,098 |
| L1 bytes | 72,303,165 | 73,897,865 | 41,706,918 |
| C lines | 1,575,210 | 1,607,974 | 759,100 |
| C bytes | 58,752,611 | 59,961,080 | 38,080,825 |
| inline publication blocks | 63,771 | 65,298 | 0 |
| `lmx_publish_*` calls | 0 | 0 | 65,298 |
| `lmx: invariant` lines | 130,385 | 133,486 | 2,890 |
| `l2_program_build` lines | 310,712 | 315,896 | 315,896 |
| L2→L1, L1→C, gcc -O0, link | 2:07, 0:35, 5:03, 0:04 | 2:00, 0:24, 5:01, 0:04 | 2:05, 0:17, 5:13, 0:04 |

So 122 L1 lines per L2 line instead of 270, and an executable of 18.7 MB instead of 25.3 MB. gcc's time did not drop.
`l2_program_build` is now 53% of the L1.

The compile warnings are the same kinds and nearly the same counts as `tool-pre-01`'s, including 23
`-Wint-conversion` (C-DOOR-POINTER-RESULT-INT-OPERAND).

Runs:
- `boot-quick-01` (`bootstrap-quick-01.out`; G0 = Verified171's working binary, which has no header step): runtime
  and frontend built; every smoke program failed its C compile on the stale `lmx_call.lm1.h` ("implicit declaration
  of function 'lmx_publish_int'"); `BOOTSTRAP quick 1 failures`. Its frontend was built from the stage before the
  comment re-wrap; its C is the same bytes as the final frontend's (`4E91FADC…`).
- `tool-pre-01` (`rebuild-tool-01.out`): `rebuild tool`, run by Verified171's working binary with Verified171's
  frontend and runtime, built the 172 tools. It hashed a file as G0 does, ran the smoke list, and gave
  `REBUILD tool 0 failures`.
- `boot-quick-02` (`bootstrap-quick-02.out`, `bootstrap-quick-02.command`; G0 = `tool-pre-01`), 10:26–10:54:
  `HEADERS 51 regenerated` (only `lmx_call.lm1.h` changed, the other 50 are Verified171's bytes); runtime and
  frontend built; smoke `SUITE 5 rows, 0 failures`, each program built once and run at the root and walked; G1 built,
  its `sha256` gives the digest and exits 0; G1 built G2 the same way; `BOOTSTRAP quick 0 failures`; G0's own exit 0
  after `l2_eternal_driver: 13 checks, 0 roots`. The smoke programs carry 9 to 71 publication calls each, all
  unguarded.
- The guarded publication, once (`guard-probe-02/`). No smoke program has a qualified root or merge, so a probe
  does: `guarded.lm2` has a const branch root and two methods, `bump` (`count: count + 1`, `return: count`) and
  `read_count`. The 172 frontend gives 47 calls with guard 1; the 171 frontend gives 47 inline blocks. Every build
  runs to the same end at the root and walked: `bump()` returns 2, `read_count()` reads 1, so the program exits 84,
  with no walk error. 84 is the norm's answer, not 7 as the probe first expected: a method's bare `count:` changes
  its activation's by-value input and leaves the unit's cell alone (book section 12; `unit_a3_caller_binding`). The
  control `unguarded.lm2` (no const branch, guard 0) gives the same. An earlier probe (`guard-probe-01`) joined two
  conditions in one exit and is superseded.

## Not run (LATER, by the author's priority of 2026-10-23)

- the gate with its controls;
- `bootstrap full`;
- a full corpus replay of the 172 frontend;
- the walker live-tree evidence.

## Defects (steps/defects.md)

| Defect | Status |
| --- | --- |
| BOOTSTRAP-HEADERS-STALE | new, fixed |
| GENERATED-CODE-SIZE | OPEN, first step |
| C-DOOR-POINTER-RESULT-INT-OPERAND | new, OPEN (seen in the tool's compile warnings, older than this slice) |

## Process

- The protected basename `l2_driver_launch.err`, written by every launch into its cwd, was excluded from every copy
  and comparison. Every run had a directory of its own.
- The re-wrap of `suite.lm2`'s comment on `rebuild` is ragged at one line. It was left as built, so that the committed
  runner is the bytes G1 and G2 were built from.
- `guard-probe-01/p.lm1` was written twice by the same frontend from the same source: a translation by hand at 10:46,
  then the probe script at 10:54. That breaks the rule of a new label per attempt; probe 1 is superseded by probe 2,
  which ran in its own label.

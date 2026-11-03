# Maintained L3/L2 source package

This is the selected repository source root for the existing language-owned
`manifest`, `stage-copy`, `rebuild`, and `bootstrap` route. Keep its relative
layout: `src/l2src/`, `tools/`, and `tests/`. In particular, the full suite's
`../tools/sha256.lm2` extra input is relative to `tests/`; moving that list to
`tests/l2/` without an explicit source change would break its resolution.

The selected package contains 179 inputs (65 source files, 34 tools and
80 tests). Slice 265 records the data places required by a named Structure
from its declarations. A call through a held reference and a direct call
admit the same requirements, including declarations inside an inline branch.

The quick bootstrap took 749.81 seconds. G1 and G2 each passed nine smoke
rows. G2 passed all 27 focused rows.
[Sources and checks](../steps/witnesses/fix265-20261103/notes.md).

| Artifact | SHA-256 |
| --- | --- |
| Input list | `24E8E7551475522126ECE5EE7C4537298092DAEDB2AEA67EB929DE5974E3FFC8` |
| Input manifest | `41ACDB1666CB7AD4A4FFFE5984CE801DEDE6A4C17B4CC47444BD83240E326DF7` |
| Working tool | `FF07ECBB0C65FE965380ED54A155CF9132514A1F5A13E31F26EE80AEFFEE5177` |
| G2 frontend | `BBCABDAC2CBB98EB9E23F725843E95AD50A1091B1639A4760F84CF206D77EAB2` |
| Production runtime | `1DB4884783710CD4424F2FCF23A32A7A015BEB77EBD88BFB371B23BD7F4DBB1A` |
| Observation runtime | `F4EAFB53512301BFB64BAA0CC53D1884CB87D014ECBAF8DC0BD10B94803FB756` |

[Slice 264](../steps/witnesses/fix264-20261103/notes.md) contained 178 inputs and introduced admission of the actual code/data pair at Structure calls.

[Slice 263](../steps/witnesses/fix263-20261103/notes.md) contained 173 inputs,
manifest `48951CA2…`, and established the shared dispatch of unary Structure calls.

The preceding packages were [slice 262](../steps/witnesses/fix262-20261102/notes.md)
(170 inputs, manifest `A148F03F…`) and [slice 261](../steps/witnesses/fix261-20261102/notes.md)
(167 inputs, manifest `CB155E7E…`).

The previous packages: boot122a is slice260 (manifest `8F34D77F…`; 6 files
over boot121a and one new fixture); boot121a is slice259 (manifest `BBCCB259…`; 6 files
over boot120a and one new fixture); boot120a is slice258 (manifest `55C1CC2D…`; 7 files
over boot119a and one new fixture); boot119a is slice257 (manifest `900AB284…`; 4 files
over boot118a and one new fixture); boot118a is slice256 (manifest `1016F41D…`; 4 files
over boot117a and one new fixture); boot117a is slice255 (manifest `FC9659DF…`; 10 files
over boot116c and one new fixture); boot116c is slice254 (manifest `DC4E8C62…`; 9 files
over boot115f and one new fixture); boot115f is slice253 (manifest `48F66AF0…`; 19 files
over boot114, the input list unchanged); boot114 is slice252 (manifest `FE3FDA29…`; 6 files
over boot112 — tp113 and tp114), boot112 is slice251 (manifest `7FA43F9E…`; 15 files
over boot89 — 9 inherited from full100, 8 of tp112), boot89 is
[slice246](../steps/witnesses/fix246-20261031/notes.md)
(its tested source [slice245](../steps/witnesses/fix245-20261031/notes.md));
the original unchanged publication is [slice239](../steps/witnesses/fix239-20261029/notes.md);
candidate48 and its FULL48 run are [slice240](../steps/witnesses/fix240-20261029/notes.md)
and [slice241](../steps/witnesses/fix241-20261029/notes.md).

## Normal source selection

Choose an explicit working G0 tool and its matching previous frontend,
backend and libc tuple; retain their provenance. Run each language CLI in a
fresh separate working directory, never the repository or source root.
STAGE is a new empty output root; do not prefill generated headers or bodies.
Using absolute substituted paths, the existing commands are:

```text
TOOL 0 entry 0 -- verify REPO/selfbuild/inputs.sha256 REPO/selfbuild
TOOL 0 entry 0 -- stage-copy REPO/selfbuild/inputs.sha256 REPO/selfbuild STAGE
TOOL 0 entry 0 -- bootstrap quick REPO STAGE BASE PREVIOUS_FRONTEND LABEL STAGE/tests/smoke-kernel225.tsv
TOOL 0 entry 0 -- bootstrap full REPO STAGE BASE PREVIOUS_FRONTEND OTHER_LABEL STAGE/tests/smoke-kernel225.tsv STAGE/tests/full-suite.tsv
```

Quick and full are separate requested modes, not an instruction to run both
automatically. One invocation of either builds/tests G1 and then G2 using the
actual G1 tool, promoting both. Normal generation reads staged inputs;
missing generation is a failure, not permission to reuse the older repository
headers or a cached object. Generated headers come before their consumers: the
runtime step writes the kernel's generated L1 and C headers that the smoke
list and the tool then read. The source package is authoritative; older
`dev/l2src_sandbox/`, `tools/l2/inputs/` selections and PS/Python gates are
historical inputs/routes, not an alternative fallback for this route.

boot115f selected, under the ignored `build2/codex_fix250generationchain01/`:
G0 `cold-tp115/tool115e/lmxtool-tool.exe` (`077477FD…`, the tp115 tool after
fix05, built by `rebuild tool` from this package's tool sources with boot114's
G2 frontend and runtime), previous frontend
`cold-boot114/quick114/g2/frontend/l2trans.exe` (`17DFEEA9…`, boot114's G2
frontend — the landed source-tp114's self-built frontend; tp115 changes the
frontend only in what it emits) with its adjacent backend (`93113080…`) and
libc (`AF9FDAE3…`), and BASE `cold-candidate48/full48/g2/frontend`. Its
promoted working tool is `cold-boot115f/quick115f/lmxtool.exe`
(`8C5D66EA…`), the G2 tool, with `working-bundle.sha256` equal to the G2 bundle.

## Current acceptance boundary

boot115f passed whole QUICK on these bytes from a fresh source-only stage
(2026-11-02, 06:01:02–06:17:04Z, 962 s): `BOOTSTRAP quick 0 failures`. G0
built and tested G1 (frontend, runtime, the 9-row smoke list with 0 failures,
tool) and promoted it; the actual G1 tool built and tested G2 the same way,
and G2 was promoted. Every program of the smoke list runs the driver's
start-up self-check of the code links (38 checks on a private arena)
before its own main. Quick runs neither the full list, the OS walk witness
nor the self-test, and does not compare the generations; FULL has not run on
these bytes (the full100 line's G1 passed the full list on its own sources,
this package without the tp112–tp115 changes; its G2 was stopped, slice250).
Compared from the receipts, 245 of the 248 paths hashed in both generations
are byte-equal — every frontend, backend and kernel L1, both C translation
units, the runtime objects, libc and the tool's L1 and C — and the three
executables differ only in the PE link stamp (TimeDateStamp, CheckSum). That
comparison is its own evidence, not a reproducibility gate. The previous
attempt on the tp115 sources before fix05, boot115d, passed the same way on
the frozen source-tp115 `7E6203F5…` and is the evidence of those bytes only
(Codex's review of them opened the two defects fix05 closes). The draft79
line's open items (V63, the split-pointer place, the bare return) are not
closed by this result.

Publishing these bytes removes their sole residence in ignored WIP. It does
not by itself provide a clean-clone platform G0, prove every consumed include
or close S8.6, the clean/native/admission/source-profile debts, or the mail
API. Those remain the current [plan](../next_core_tasks_v3.md) and
[handoff](../to_opus.md).

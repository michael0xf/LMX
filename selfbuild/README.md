# Maintained L3/L2 source package

This is the selected repository source root for the existing language-owned
`manifest`, `stage-copy`, `rebuild`, and `bootstrap` route. Keep its relative
layout: `src/l2src/`, `tools/`, and `tests/`. In particular, the full suite's
`../tools/sha256.lm2` extra input is relative to `tests/`; moving that list to
`tests/l2/` without an explicit source change would break its resolution.

`inputs.list` selects 159 maintained inputs: 65 source, 34 tool and 60 test
files. `inputs.sha256` binds those exact bytes with paths relative to this
directory. Generated L1/C, headers, objects and executables are not inputs.

The selected snapshot is the source of the whole quick bootstrap boot89
([slice245](../steps/witnesses/fix245-20261031/notes.md)): candidate84 —
Codex's handed-over source80 ([handoff](../to_opus.md)) with the 81–84 fixes
of [slice242](../steps/witnesses/fix242-20261031/notes.md) and
[slice243](../steps/witnesses/fix243-20261031/notes.md) — with walker86
(slice243) and the resolve fix green89 (slice245). Relative to the previous package, candidate48, it
changes 25 selected files: 9 frontend, 13 kernel, the owner fixture
`tests/lib/lib_owner.lm2`, `tools/build.lm2` and `tools/lmxtool_methods.lm2`;
the input list is unchanged. The landing is [slice246](../steps/witnesses/fix246-20261031/notes.md).
Input-list SHA-256:
`E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF`.
Input-manifest SHA-256 (byte-equal to boot89's `source-boot89.sha256`):
`9A5C12AC46199B8038F39496846D4B3D91113C2CF838D601468648EB810C5FA5`.
The original unchanged publication is [slice239](../steps/witnesses/fix239-20261029/notes.md);
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

boot89 selected, under the ignored `build2/codex_fix250generationchain01/`:
G0 `cold-generator84/tool84-parts/lmxtool-tool.exe` (`B9A2D857…`), previous
frontend `cold-candidate49c/fe49c/l2trans.exe` (`F646DD07…`) with its adjacent
backend (`B68E4DD2…`) and libc (`AF9FDAE3…`), and BASE
`cold-candidate48/full48/g2/frontend`. Its promoted working tool is
`cold-boot89/quick89/lmxtool.exe` (`7FD2E824…`), the G2 tool, with
`working-bundle.sha256` equal to the G2 bundle.

## Current acceptance boundary

boot89 passed whole QUICK on these bytes from a fresh source-only stage:
`BOOTSTRAP quick 0 failures`. G0 built and tested G1 (frontend, runtime, the
9-row smoke list with 0 failures, tool) and promoted it; the actual G1 tool
built and tested G2 the same way, and G2 was promoted. Quick runs neither the
full list, the OS walk witness nor the self-test, and does not compare the
generations; FULL has not run on these bytes. The FULL48 results are evidence
for candidate48's own bytes, not a FULL acceptance of this package. Compared
from the receipts, the runtime objects, libc and the tool's L1 and C are
byte-equal across G1 and G2, and the three executables differ only in the PE
link stamp; that comparison is its own evidence, not a reproducibility gate.
The separate draft79 line is not in this package; its open items (V63, the
split-pointer place, the bare return) are not closed by this result.

Publishing these bytes removes their sole residence in ignored WIP. It does
not by itself provide a clean-clone platform G0, prove every consumed include
or close S8.6, the clean/native/admission/source-profile debts, or the mail
API. Those remain the current [plan](../next_core_tasks_v3.md) and
[handoff](../to_opus.md).

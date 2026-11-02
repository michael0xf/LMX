# Maintained L3/L2 source package

This is the selected repository source root for the existing language-owned
`manifest`, `stage-copy`, `rebuild`, and `bootstrap` route. Keep its relative
layout: `src/l2src/`, `tools/`, and `tests/`. In particular, the full suite's
`../tools/sha256.lm2` extra input is relative to `tests/`; moving that list to
`tests/l2/` without an explicit source change would break its resolution.

`inputs.list` selects 159 maintained inputs: 65 source, 34 tool and 60 test
files. `inputs.sha256` binds those exact bytes with paths relative to this
directory. Generated L1/C, headers, objects and executables are not inputs.

The selected snapshot is the source of the whole quick bootstrap boot112
([slice251](../steps/witnesses/fix251-20261101/notes.md)): source-tp112 —
the sources of the Opus line's full100 ([slice250](../steps/witnesses/fix250-20261101/notes.md):
the boot89 package with the draft79 fixes through coherent100) with the
frontend optimization slices tp110–tp112 of the Fable line over them (the
predef index, the node-keyed memos, the contract and own-name indexes;
[design](../optimization_design_from_fable.md), [profile](../build_performance_profile_from_fable.md)).
Relative to the previous package, boot89, it changes 15 selected files: 9
inherited from full100 (`l2_frontend_coords`, `_core`, `_emit`, `_lower`,
`_useplan`, `lmx_reparent`, `lmx_value_owned`, `lmx_walk_values`,
`tools/build.lm2`) and 8 of tp112 (`l2_frontend_types`, `_intern`, `_values`,
`_views`, `_context`, `_resolve`, `_core`, `tools/build.lm2`; `_core` and
`build.lm2` carry both lines); the input list is unchanged. The landing is
slice251, by Codex's answer to FABLE-RESULT-S3-20261102T0100Z (the whole
tested set, inherited files included). Input-list SHA-256:
`E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF`.
Input-manifest SHA-256 (byte-equal to boot112's `source-boot112.sha256` and
to `source-tp112.sha256`):
`7FA43F9E1ADC10AB044C9FD3D953E69F2F6F8F86FA501F17EAC70341FAEB19CA`.
The previous package, boot89, is [slice246](../steps/witnesses/fix246-20261031/notes.md)
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

boot112 selected, under the ignored `build2/codex_fix250generationchain01/`:
G0 `cold-tp112/tool112/lmxtool-tool.exe` (`A9E9A139…`, the tp112 tool, built
by `rebuild tool` from this package's tool sources with full100's G1 frontend),
previous frontend `cold-tp112/fe112/l2trans.exe` (`46F3A974…`, the tp112
frontend, built by `build-frontend-part` from this package's frontend sources)
with its adjacent backend (`158B1E8A…`) and libc (`AF9FDAE3…`), and BASE
`cold-candidate48/full48/g2/frontend`. Its promoted working tool is
`cold-boot112/quick112/lmxtool.exe` (`0E3ACE61…`), the G2 tool, with
`working-bundle.sha256` equal to the G2 bundle.

## Current acceptance boundary

boot112 passed whole QUICK on these bytes from a fresh source-only stage
(2026-11-02, 00:51:56–01:11:16Z, 1159 s): `BOOTSTRAP quick 0 failures`. G0
built and tested G1 (frontend, runtime, the 9-row smoke list with 0 failures,
tool) and promoted it; the actual G1 tool built and tested G2 the same way,
and G2 was promoted. Quick runs neither the full list, the OS walk witness
nor the self-test, and does not compare the generations; FULL has not run on
these bytes (the full100 line's G1 passed the full list on its own sources,
this package without the tp112 changes; its G2 was stopped, slice250).
Compared from the receipts, 245 of the 248 paths hashed in both generations
are byte-equal — every frontend, backend and kernel L1, both C translation
units, the runtime objects, libc and the tool's L1 and C — and the three
executables differ only in the PE link stamp (TimeDateStamp, CheckSum); G1's
`frontend.c` is fe112's byte for byte. That comparison is its own evidence,
not a reproducibility gate. The draft79 line's open items (V63, the
split-pointer place, the bare return) are not closed by this result.

Publishing these bytes removes their sole residence in ignored WIP. It does
not by itself provide a clean-clone platform G0, prove every consumed include
or close S8.6, the clean/native/admission/source-profile debts, or the mail
API. Those remain the current [plan](../next_core_tasks_v3.md) and
[handoff](../to_opus.md).

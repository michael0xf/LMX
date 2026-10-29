# Maintained L3/L2 source package

This is the selected repository source root for the existing language-owned
`manifest`, `stage-copy`, `rebuild`, and `bootstrap` route. Keep its relative
layout: `src/l2src/`, `tools/`, and `tests/`. In particular, the full suite's
`../tools/sha256.lm2` extra input is relative to `tests/`; moving that list to
`tests/l2/` without an explicit source change would break its resolution.

`inputs.list` selects 159 maintained inputs: 65 source, 34 tool and 60 test
files. `inputs.sha256` binds those exact bytes with paths relative to this
directory. Generated L1/C, headers, objects and executables are not inputs.

The selected snapshot is candidate48, derived from the accepted whole-quick
[boot45](../steps/witnesses/fix238-20261027/cold-candidate45-boot45/) baseline45.
It changes11 selected files: the diagnostic/root-selector/full-row fixes46
and the existing docs tools' Windows temporary-stream fix plus phase output.
Input-list SHA-256:
`E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF`.
Input-manifest SHA-256:
`514564A99268D980EC7CD4A32F756E32AF4DADC7695705DDA8D965CF6F676B7A`.
The original unchanged publication is [slice239](../steps/witnesses/fix239-20261029/notes.md);
current component results and exact changes are [slice240](../steps/witnesses/fix240-20261029/notes.md).

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
automatically. One full invocation already builds/tests G1 and then G2 using
the actual G1 tool, promoting both. Normal generation reads staged inputs;
missing generation is a failure, not permission to reuse the older repository
headers or a cached object. The source package is authoritative; older
`dev/l2src_sandbox/`, `tools/l2/inputs/` selections and PS/Python gates are
historical inputs/routes, not an alternative fallback for this route.

## Current acceptance boundary

Candidate45 passed whole quick; its first FULL attempt is the preserved
[full45 failure](../steps/witnesses/fix238-20261027/cold-candidate45-full45/):
two erroneous positive walked-root expectations for a C-door root and one
diagnostic-literal mismatch. They are not hidden or reclassified as PASS.
Candidate48 includes those fixes explicitly. Its runtime and tool component
rebuilds passed the existing9-row smoke lists; the three focused46 cases
passed, and the invalid root selector was rejected as expected. Its new
tool verified35 paired semantic chapters and both original source snapshots.
The earlier fresh-stage frontend smoke failure (missing generated runtime
headers) is preserved; the normal runtime prerequisite generated those
headers and passed smoke with that same frontend. Whole FULL remains pending.

Publishing these bytes removes their sole residence in ignored WIP. It does
not by itself provide a clean-clone platform G0, prove every consumed include
or close S8.6, clean/native/admission debts, or the mail API. Those remain the
current [plan](../next_core_tasks_v3.md) and [handoff](../to_codex.md).

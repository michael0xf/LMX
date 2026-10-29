# Source publication after the Fable handoff

Prepared by Codex on 2026-10-29 from main
`a4ca664c5215d74ecb225e7db9605232c4a1931b`. Codex is the sole writer/build;
the author resumed the existing goal and the hourly automation now monitors it.

## Scope and expected evidence

Publish the unchanged, whole-quick-accepted candidate45 source bytes as the
tracked `selfbuild/` package, preserving its `src/`, `tools/`, and `tests/`
relative layout. Selection: 159 files (65 source, 34 tool, 60 test inputs).
The accepted source manifest is
`D74D30B4BB2459AFC0BCBC418953BC95E5AA7D7ED0EBD652AE98BD2D83ECA8DC`;
the ordered list is
`E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF`.

Use the existing language `stage-copy` command, not a new copying script.
The explicit G0 control tool is boot45's promoted G2:
`A69A7EE26315C058E85FE0FA9D1EFD921B4C3032421030704948575C16997FB4`.
Its manifest paths stay relative; copying to this new repository root must
not change source bytes or the layout used by the full suite's extra inputs.
The expected stage-copy result is `STAGED 159 files, 0 failed`, followed by
an independent ordinary SHA-256 verification of the same manifest.

The older six-list repository preparation is historical after this switch,
not an alternative source/fallback for the normal package. Changes are
limited to this package and its selected-route documentation. Existing
unrelated WIP and frozen candidates remain untouched.

This is source publication, not a new compiler variant or another bootstrap.
The boot45 evidence remains the acceptance evidence for candidate45's bytes.
It passed whole quick but failed FULL (two causes described in the current
handoff). Candidate46's three changes are still pending execution acceptance;
they are not silently included in this baseline.

## Live work retained

The candidate46 frontend rebuild fe46 continues in its separate stage.
Codex verified live parent PID10888 and translator PID16940 with increasing
CPU use. No compiler was stopped, duplicated, or launched by this publication.
Its acceptance and rt46/tool46/check46/full46 remain the immediate build queue.

## Results

- Existing L3/L2 `stage-copy` finished exit0: `STAGED 159 files, 0 failed`.
  The independent ordinary GNU `sha256sum --check --quiet inputs.sha256`
  from `selfbuild/` also returned0.
- The existing language `verify` command independently finished exit0:
  `VERIFIED 159 files, 0 failed` ([log](source-verify.log)).
  Both published metadata hashes are exactly the list/manifest hashes above.
- The source-publication command is the boot45 tool followed by
  `0 entry 0 -- stage-copy MANIFEST SOURCE_CANDIDATE45 REPO/selfbuild`.
  Verification is `0 entry 0 -- verify REPO/selfbuild/inputs.sha256 REPO/selfbuild`.
  Each execution used its own fresh private CWD under
  `P/component-publish45-239/`; no tool ran from the package/repository root.
- Hand-authored documentation passes scoped `git diff --check`. The raw
  published source files intentionally retain the accepted bytes, including
  seven extra-EOF-newline warnings and six trailing-comment-space warnings
  reported by `git diff --cached --check`; that check is **not clean** for
  this verbatim import. No source whitespace was silently rewritten and no
  checker/attribute was weakened to hide it. See [warnings](preserved-whitespace.log).
- Existing boot45 language `docs check` returned1
  ([log](docs-check.log)); isolating its first phase with the existing
  `docs verify semantics` CLI also returned1
  ([log](docs-semantics-verify.log)). It supplies no specific failure detail.
  Arguments were the repository root, the existing preferred sources
  `C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt` and
  `C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt`, and, for the full check,
  `C:/Git/cmd/git.exe` plus a fresh private output directory. The preferred
  source bytes match both archived snapshots exactly (SHA256 prefixes
  `BDB1A641` and `D4BB1E70`); changed external source bytes are not the cause.
  This is an observed pre-existing language-tooling failure, not a passed
  documentation check or a reason to substitute the Python checker.
- Captured console logs are stored with LF line endings. No old source,
  stage, build or execution record was rewritten.

Publication acceptance is the unchanged159 source bytes bound to whole-quick
boot45, not a claim that all repository/tooling checks pass. FULL, the language
documentation verifier failure, clean-clone G0, clean/native/admission,
S8.6 and mail remain open. The live fe46 queue is unchanged.

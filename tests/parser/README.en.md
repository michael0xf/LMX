# Parser tests

Migration proceeded in order: `lingvamyxa_old_worked_version` → `lingvamyxa` → `L1`. The old projects were not modified. All recursively discovered `tests/**/*.lmx` from these three trees are retained; matching paths and SHA-256 use one copy, while differing versions remain separate files. Each file's provenance, size, and SHA-256 are in the [manifest](../../provenance/parser-tests.json).

| Stage | Selected source files | New copies added |
| --- | ---: | ---: |
| Old working version | 169 | 169 |
| lingvamyxa | 294 | 125 |
| L1 | 501 | 321 |
| Additional lingvamyxa_prev audit | 119 | 0 |
| Total retained | | 615 |

The migration contains 184 versions of P0 `.lmx` inputs; 301 frozen `printTree.lm0` golden files; 78 tree/metadata contract files; 43 expression and C-surface test inputs; 7 historical harness files; 1 support file and 1 source used as a parser-acceptance input. A `trans_` prefix on some `.lmx` names does not imply semantic validation: in the P0 corpus these are parse-only inputs.

All 119 `.lmx` inputs in `lingvamyxa_prev` were additionally checked: every one is already represented by a byte-identical copy. Their provenance was added to those same manifest records.

The supported current-case check is the existing L2/L3 tool's `parser-suite` command. It takes a built graph tool and expectation JSON; each source is parsed once without rebuilding. It checks the complete tree or explicit fragments, and checks the P0 error code, line and column separately from process exit. Raw output and the result table are retained in a new OUT directory. A timeout or crash does not substitute for the required diagnostic.

From a new private working directory, with absolute paths:

```text
TOOL 0 entry 0 -- parser-suite REPO GRAPH_EXE REPO/tests/parser/current/expectations.json NEW_OUT
```

Parser and tool sources are in `selfbuild/src` and `selfbuild/tools`. `tools/run_parser.py`, the old `printTree`, root `l1src` and `dev/` remain historical material, not a supported fallback. Documentation is checked by the language-owned `docs check` command in [READ.ME](../../READ.ME#docs-cycle). The old profiles and dated run results described below are history.

`historical` checks the 131 cases in the old manifest: exit code and exact tree bytes, or error code/line/column. `previous-l1` checks the same corpus with pinned previous L1 admission changes. These profiles are historical regression, not a statement of the new norm. `current` checks new author clarifications; it must expose old implementation mismatches rather than conceal them. Rejection, crashing, and timeout are not interchangeable successful negative tests.

When an author rule changes the tree for a legacy case, imported goldens stay byte-immutable. Record each intentional divergence in `tests/parser/previous-l1/divergences.json` with a separate golden under `tests/parser/previous-l1/goldens/` (never under `imported/`). The `previous-l1` profile replaces that case's expected stdout, tags it `diverged`, and refuses a map golden that is still byte-equal to the imported one or a name absent from the manifest. Summary line: `previous-l1: N passed (M diverged as recorded), F failed`. Verified 2026-09-23 with P0 sole anonymous argument-container normalize: **131 passed (8 diverged as recorded), 0 failed** (123 imported matches + 8 recorded divergences).

Verified on 2026-09-19:

- Historical `printTree.lm0.exe`: 131/131 historical expectations matched.
- `L1/build/l1trans/gen2/printTree.exe`: 131/131 previous L1 expectations matched.
- New `receiver:` / `---`: current L1 rejects with `P0 parse error 32 at 1:1`; the historical parser accepts but loses the empty Structure argument. Neither conforms to the author's clarification.
- Control `receiver: ()`: both parsers retain one field containing an empty Structure.

Exact executable hashes and results of that historical run are in the [migration verification report](../../provenance/parser-verification.json). Other migrated scenarios and metadata/expression checks are retained, but that run is not claimed as their complete execution.

The September 20 correction was separately verified in `dev/l1src_sandbox`: **13/13 current tests** and **131/131 previous-L1 expectations**. Exact trees cover both forms, comments, a nested body, an empty colon trailer and two consecutive receivers. Actual argument absence before EOF, `;` or `)` still produces error 32. Stable sources are unchanged; the new behavior requires the dev driver documented above. Its `predef` explicitly selects the dev parser because the translator embeds dependencies in C.

Do not regenerate historical goldens to obtain a green result. New-language tests and old snapshots must remain distinguishable. In particular, check the presence of the empty Structure, not merely a successful exit code.

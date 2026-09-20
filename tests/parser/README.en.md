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

The current portable harness is `tools/run_parser.py`. It accepts a supplied `printTree`. Stable P0 has been migrated to `l1src`; the corrected dev copy and its driver are in [dev/l1src_sandbox](../../dev/l1src_sandbox/README.md). Historical scripts are retained for migrating additional checks and contain their original project paths/dependencies; they are archived harnesses, not a promise of standalone execution in LMX.

From the LMX root:

```text
python tools/check_docs.py
python tools/run_parser.py --parser PATH_TO_PRINTTREE --profile historical --output build/historical
python tools/run_parser.py --parser PATH_TO_PRINTTREE --profile previous-l1 --output build/previous-l1
python tools/run_parser.py --parser PATH_TO_PRINTTREE --profile current --output build/current
```

`historical` checks the 131 cases in the old manifest: exit code and exact tree bytes, or error code/line/column. `previous-l1` checks the same corpus with pinned previous L1 admission changes. These profiles are historical regression, not a statement of the new norm. `current` checks new author clarifications; it must expose old implementation mismatches rather than conceal them. Rejection, crashing, and timeout are not interchangeable successful negative tests.

Verified on 2026-09-19:

- Historical `printTree.lm0.exe`: 131/131 historical expectations matched.
- `L1/build/l1trans/gen2/printTree.exe`: 131/131 previous L1 expectations matched.
- New `receiver:` / `---`: current L1 rejects with `P0 parse error 32 at 1:1`; the historical parser accepts but loses the empty Structure argument. Neither conforms to the author's clarification.
- Control `receiver: ()`: both parsers retain one field containing an empty Structure.

Exact executable hashes and results of that historical run are in the [migration verification report](../../provenance/parser-verification.json). Other migrated scenarios and metadata/expression checks are retained, but that run is not claimed as their complete execution.

The September 20 correction was separately verified in `dev/l1src_sandbox`: **13/13 current tests** and **131/131 previous-L1 expectations**. Exact trees cover both forms, comments, a nested body, an empty colon trailer and two consecutive receivers. Actual argument absence before EOF, `;` or `)` still produces error 32. Stable sources are unchanged; the new behavior requires the dev driver documented above. Its `predef` explicitly selects the dev parser because the translator embeds dependencies in C.

Do not regenerate historical goldens to obtain a green result. New-language tests and old snapshots must remain distinguishable. In particular, check the presence of the empty Structure, not merely a successful exit code.

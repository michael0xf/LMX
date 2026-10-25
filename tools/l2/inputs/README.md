# Canonical inputs for the short bootstrap

These five lists are maintained input data for the existing `lmxtool manifest`
and `stage-copy` commands, not a new preparation runner. Cold219 executed this
exact 73-file selection from repository sources, with no prior generated kernel
headers or module bodies supplied. Its whole-bootstrap acceptance is recorded
in [packet219](../../../steps/witnesses/fix219-20261025/notes.md).

| List | Source root relative to REPO | Destination relative to STAGE | Files |
| --- | --- | --- | ---: |
| runtime.list | dev/l2src_sandbox | src/l2src | 44 |
| p0.list | dev/l2src_sandbox/l1src | src/l1src | 7 |
| driver.list | dev/l2src_sandbox/harness | src | 1 |
| tools.list | tools/l2 | tools | 8 |
| tests.list | tests/l2 | tests | 13 |

Use a new empty STAGE. Create its checks directory and a separate fresh working
directory for **each** language CLI execution using ordinary OS directory
operations. For each table row, run the existing commands (substitute absolute
paths; LIST is this directory's named list, FROM and TO are the table roots):

```text
TOOL 0 entry 0 -- manifest LIST FROM STAGE/checks/GROUP.sha256
TOOL 0 entry 0 -- stage-copy STAGE/checks/GROUP.sha256 FROM TO
```

Every call must terminate with zero failed files. The destination copies are
hash-verified by stage-copy. The next existing language command, from another
fresh working directory, is:

```text
TOOL 0 entry 0 -- bootstrap quick REPO STAGE BASE LABEL STAGE/tests/smoke.tsv
```

Do not first clone a historical stage or fill `headers`/generated kernel
`.lm1`/TLS outputs. The source-first recipe constructs frontend headers,
executes the L3 declaration writers, translates all 35 maintained L2 modules
and nine API headers, then creates the common C headers before their consumers.
A failed generation is a failure, not permission to copy a legacy header.
The short 13-test-file selection is not the full suite's dependency closure.

Temporary handwritten inputs are explicit, not hidden: frontend/compiler/API,
residual walker, P0, libc ABI and driver. The external bootstrap backend,
BASE support/libc object and generated tools also remain debts. This route is
**not** source-closed S8.6. The old PowerShell gates are not called by it; their
historical assertion sets still need migration and are not declared replaced
merely by this short bootstrap.

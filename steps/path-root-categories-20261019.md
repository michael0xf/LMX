# Path root category/index: implementation verification

This is a compiler implementation slice, not a new language rule and not a
claim that every path consumer is unified. The parent is the accepted walker
record-transfer snapshot described in
[the R2 manifest](r2-value-actual-migration-20261019.md).

## Change and exact inputs

`L2Path.root_kind` selects an ordinary namespace/binding, `node`, a control
body, a method occurrence or a machine local. `root` is the independent index
when that category needs one. The former `-3-i` / `-1000-mi` intervals and the
`i < 990` machine-local guard are removed, not enlarged. The common
`l2_path_root_resolve` fills that record. Step resolution, native emission and
walker lowering consume its category/index rather than decoding an interval.
No opcode or extra role field is added to a runtime `Lmx` graph.

Verified inputs of this slice:

| Input | SHA256 |
| --- | --- |
| `dev/l2src_sandbox/l2trans.lm1` | `c810e95138fdbc050c1fa2cef89bc66e9e339934ec90ddda6d5de238b4a67ffc` |
| `dev/l2src_sandbox/l2_application.h.lm1` | `42fd7f6ce03577e00102209114fe718a532b3c31b1bd839d370ca4df3738a068` |
| `tools/l2_harness.ps1` | `7a5445b842fb311e7983123c57952b5767333b0420b1d8c1edfb2124eb9e5044` |
| `tools/l2_path_roots_test.c` | `0f674e23f172d14f6207a6b4e9b6c09c44b153f3fcbf4a175a6c9a57852ae42d` |

The canonical frontend Git blob is
`1138b256eb6cad23b9930e099e5fca2298a6ff87`. These bytes are separate from the
later execution-map-copy WIP: the full gate froze its kernel sources before
that later change. Its pregate HEAD precedes publication of the parent walker
slice; the actual frozen source pins, not that HEAD alone, identify the run.

## Evidence and its limits

`tools/l2_path_roots_test.c` includes the tested generation's actual frontend
C with its entry point renamed. It constructs collected compiler metadata;
it does not implement a second resolver or expose a new production flag.
For machine locals, methods and control roots it selects indices
0,989,990,996,997,999,1000,1024,1030, plus one `node` selection:28 checks.
All pass. Restoring only the former990 guard fails seven local selections.
This proves category/index independence of the actual resolver. It does not
prove source reachability of legacy graph-typed machine locals; the present
source collector can exclude that route.

Five source programs also execute under normal/forced-method translation
and native/cleared-root dispatch. Their actual results are7 for deep
permuted values, a copied callable's self path, a returned-node path and
the hosted deep callable actual; the control-body address case returns30.
The generated forced-method files retain only native root m6,m2,m5,m7,m2
respectively. This is real walked-method execution, not successful translation
with those methods silently remaining native. These programs do not exercise
a source machine-local with index above990.

- Historical replay: `codex_path_root_record_replay_01`, SAME3573 against
  the accepted walker snapshot. Its known input/coverage gap is unchanged.
- Focus: `codex_path_root_record_focus_01`,84 targets/11 failures versus
  the parent's83/11. The sole new row is the28-selection compiler test;
  zero regressions, changed common FAIL notes/diagnostics or removed rows.
- Kernel: `codex_path_root_record_kernel_01`,305 targets/zero failures,
  118 executed self-tests. L3: all11 suites and four type budgets pass.
- Full: `codex_path_root_record_full_01`,15:17:39Z-16:07:50Z:
  **3616 targets/1027 failures**. Against the accepted walker3615/1027,
  exactly one new OK compiler-root test, zero regressions, changed common
  FAIL notes/diagnostic signatures or removed rows. Against EA3613/1025,
  the two already registered red Array positives remain the only new FAILs;
  no previously green row regresses. No clean-kernel claim is made.
- All13 canonical frozen pins match the acceptance index: frontend/header,
  compiler test, walk/walk.h, copier/implements/implements.h, driver and both
  deep/Array witnesses with their walk aliases. Minimum sampled free physical
  memory during the full:3437MiB. The frozen copier is the old accepted
  implementation, not the later execution-copy WIP.

### Launcher postamble failure

The PowerShell corpus completed its summary, cleanup and final RED line.
Codex had edited its shared running Bash launcher to fix module selection
for later invocations. When the long command returned, Bash read at an old
byte offset in the edited file and exited2 before writing the status and
running comparisons. The actual PowerShell return code was not captured;
it is not reported as an observed1.

After verifying the complete summary/final log and that the process stopped,
the comparisons above were run separately. The status was reconstructed
with `exit=unrecorded`, wrapper exit2 and this explanation; no corpus row
or input was fabricated, moved or rerun. Its retained
`WRAPPER_COMPLETION_NOTE.md` gives the evidence. This is acceptance of the
complete source-pinned corpus and comparisons with an explicitly failed
launcher postamble, not a claim that the wrapper succeeded. Do not edit a
running shell launcher, even after its child process has frozen source files.

## Still open

This removes numeric root encoding only. It does not provide computed-value
roots, ordered field/index suffix emission, a required-instance source after
an indexed reference, ancestor coordinate ownership, mapped executable-copy
proof, current-graph native invalidation, M1-M4/N4 or self-build/mail completion.
The [consumer audit](path-resolution-consumer-audit-20261019.md) remains the
map of those obligations. In particular, deleting a field-after-index guard
or reparsing at a backend is not an implementation of the common algorithm.

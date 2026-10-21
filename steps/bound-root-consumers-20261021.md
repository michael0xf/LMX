# Private136: selected roots and common foreign-member projection

Base main: `7ac11bccc4f03bb773f140710d38c17391c29281`.
Final source: `build/codex_bound_root_136d`; frontend:
`build/codex_root136_build_05`. This is a private K01/K05/K08 clean-kernel
dependency, **not all-path closure, a public-dev rollout, full gate or self-build**.
Codex remains sole writer/build; goal stays ACTIVE.

The [two-source U0 patch](witnesses/used-scope-20261020/bound-root136-u0.patch)
applies over [Private135](raw-index-store-20261021.md)'s
`build/codex_raw_index_135`. Replay `build/codex_root136_replay_01` reconstructs
both final sources exactly. No runtime Value/Place/chunk or uniform ABI layout,
graph field, opcode, Model registry, branch or managed worktree was added.

## One selected root, not another lookup

The prepared indexed-head consumer now calls the existing common root resolver
and retains its own/formal/machine-local/activation-slot coordinates. It no longer
looks up the source word again through `l2_colon_bound_ty`, nor asks ordinary
expression emission to select the root afresh. The selected closed input type
is projected from those coordinates; an unknown hidden input does not become int.

`l2_emit_binding_value` projects the selected native value/context;
`l2_rw_binding_value` and `l2_rw_index_base` project that same binding into retained
graph COUNT/EMIT. C-only locals remain source-machine leaves, not fictional
interpreter support. A selected formal uses `l2_tok_input_context` directly,
including the normal native path cursor. The ordinary unresolved formal wrapper
still selects an own row when appropriate; its preconditions are preserved.

The common resolver selects nearest machine bindings before unit-level roots,
including locals without graph metadata. Activation slots have compiler-only
root kind5, not a graph opcode. Its obsolete late duplicate formal-name fallback
is removed. Unused duplicate `L2RawIndex.source_type` is removed: the prepared
root and `L2Address.source_type` already hold the contract.

The [actual-frontend test](witnesses/used-scope-20261020/bound-root136-test.c)
completes SAME **84 checks**: final136d **0 failures**, old135 **30 assertion
failures, exit1** (`consumer_d_01`). It resolves formal/slot/machine bindings,
then poisons the lookup spelling. Native and graph COUNT/EMIT must still consume
the selected coordinates, preserve types and cached grammar, and release the
independent view correctly. The old compiler strictly compiles, executes all84
and fails assertions; this is not a setup crash. This is a translator-consumer
test, **not** a rule requiring runtime mutations to recover an earlier graph.

## Real by-value C aggregate defect, including the read consumer

Independent source testing found that a real C value record was emitted as
`box->cells[1]`. Both old135 and intermediate136b strictly fail C compilation:
`invalid type argument of '->' (have 'Root136Record')`. This is a preexisting
K08 lowering RED, not a bad test preparation. Artifacts are
`codex_root136_raw_value_old_01` and `raw_value_04`.

The common `l2_emit_raw_members` consumes the selected binding and retained NAME
steps. The first selector uses `.` for a known by-value root and the existing
pointer selector for a pointer root. Later opaque C selectors retain their
written representation: there is no C-header member dictionary or guessed Model.
The root's namespace context is not attached to an opaque member's result.

Prepared indexed stores and the legacy text raw-path entry use this SAME member
projection. Expanded tests then found that reads still used their own printer:
intermediate136c's scalar/indexed writes compiled, but source reads emitted
`box->scalar`/`box->cells[1]` and strictly failed (`raw_value_07`). Final136d removes
that read-side printer too. `l2_emit_fields_context` selects the root once, then
either projects C members or continues the existing semantic walk through
`l2_path_walk_selected`, without selecting the root a second time.

The [published L2 source](witnesses/used-scope-20261020/raw-value136-probe.lm2)
actually invokes both by-value and by-pointer methods. It performs scalar and
indexed writes, reads those values in SOURCE expressions and compares them with
independent C getters. It verifies that a by-value call leaves the original's
`5/9` unchanged, while pointer writes persist as `23/43`. Wrong values return a
different exit code. The [C backing/getters](witnesses/used-scope-20261020/root136_fields.h)
and [test-only declarative C ABI predef](witnesses/used-scope-20261020/root136_fields.h.lm1)
are explicit inputs, not runtime/kernel code.

Final136d actually passes both root modes: driver **13/17 checks, 0 roots**,
exit0 (`raw_value_08`, and separately the freshly translated/compiled/linked
published source in `raw_published_01`, session91838 terminal0).
The published run uses the **fresh final136d matrix runtime**. Foreign C bodies
remain native in both root modes; `walkroot` here is **not forced interpretation
of arbitrary C members**. True forced-walker Structure/Array evidence is separate.
The test-only L1 predef and PowerShell recipes are transitional bootstrap evidence,
not the language-owned build/test or handwritten-L1-free closure required by §8.

## Final136d actual regression and loss controls

`build/codex_root136_verify_d_01.ps1`, session97806, **terminal0**, runs sequentially:

- Source indexed-write witness **82/0 native**, unchanged135 source/oracles.
  Real typed pointer depth7, nonzero/negative indices, once-only effect order,
  frozen target, SAME-address context replacement and actual permuted7/9 remain.
- Fully permuted Structure/Array read/write/taken-address **36/0 native and
  36/0 forced walker**, independently compiled from the same final sources.
- **336** unchanged source-linked compiler checks.
- **85 fresh L2/L1/C/GCC/link units, 170 actual runs: 162 GREEN and the same
  8 positive-copy RED**. Native binding counts, modes, exits and observations are
  preserved;341 selected parent inputs verified. Worker6696,
  startUTC `2026-10-21T19:28:53.8125497Z`.
- Four foreign-value executions **13/17/13/17** use that fresh matrix runtime.

`controls_d_01`, session91838 terminal0, mutates the exact final136d indexed unit,
not an intermediate or a differently emitted source. SAME82: wrong explicit
owner propagation gives **2 assertion FAIL**; discarding the frozen target after
RHS gives **2 assertion FAIL**. Both strictly compile/link, complete82 and exit1.
These controls are not inferred from135 or136b's earlier runs.

Intermediate136a and136b also passed their named focuses. In particular, B's
85 re-emissions were byte-identical to A's tested C; that observation was
**not** another fresh run. The final136d85/170 matrix above is independently
fresh and supersedes any need to infer its behavior from those intermediates.
Do not add overlapping focuses into a fictitious full-gate count.

## Bytes, receipt and reproduction

```text
compiler source 403C5A0A5CC21266A04A1FBB885BEE0613E69D8C26F8C4E72E9B29A91B37F207
application h  67AE191A2C883F415BDCA80E269DCD095F3A15F26313B77155D9A5F1F36D7075
frontend C    1F10481D1A666F11FC36268275588FB796CEE880EC6490ED1060ABA0EF6BAEA5
frontend EXE  4891E02B222D7CE19A0D8BE5F35ABBFCC5CD4571C7AF6FF33F8BBCE3616EC4F7
runtime C     471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh object  EAADF47A3225A3E13D8FD49DB5F665A7A12A1B966CFF2BE61C99DC948C1C422F
two-source U0 9AA62F838FD9836BB7523D382442FE1BA6DE99E823362D79408C968F7A225D6B
```

Terminal receipt `build/codex_root136_terminal_01.inputs.sha256`: **1999 pins**,
SHA256 `FEFFEA67823B89AC630ED96D81B98CCE587DE726FA189E2D821EA2EF042B3B5D`.
The [summary](witnesses/used-scope-20261020/bound-root136-evidence.json) records
the same final identities and limits. Named source/output dirs, source witnesses,
actual argv/CWD, recipes, quoted C/header dependencies, selected tools and parent
receipt digests are pinned. This is **not** all historical files rehashed or a
complete SDK/preprocessor closure: conservative scan still has `decNumber.h`.

Named recipes under `build/codex_root136_*.ps1` retain commands. In particular:
`build_05` → `verify_d_01` → `controls_d_01` → `raw_published_01` → `terminal_01`.
Runtime C is unchanged134f; focus fixtures reuse its verified renamed object,
whereas the85-unit matrix compiles a fresh object and final foreign/published
aggregate runs link it. Strict C99 pointer/qualifier diagnostics remain enabled;
native/runtime O2/fstrict-aliasing, frontend O0. Only one GCC pipeline.

Preparation failures remain separate: build01's L1 nested dotted operands;
consumer01's unavailable Windows `tmpfile()` and failed debugger quoting;
raw_value01 missing opaque predef,02 outside-root predef,03 missing generated
header. Raw_value05 compiled but did not invoke its check; it is not behavioral
GREEN. Explicit capture paths and actually invoked programs replace those
preparations. The real aggregate04/old01/07 compile REDs above are not concealed.

## Remaining work

Legacy atom/raw readers still use `l2_raw_index_text/span`, `l2_prefix_deref`,
`l2_deref_word` and raw-path classifiers. They are not an accepted permanent
fallback. C member leaf types and mixed nested opaque member projection remain
unknown; universal target freezing before RHS, all-consumer/per-step map closure,
unowned lifetime and qualified-index effect order are OPEN. Common root and
member projection in this slice alone do not prove the whole path system unified.

Public dev is unchanged. Last full112 **1011 FAIL/3754**, the eight copy-positive
REDs, clean kernel, L3/L2 self-build generations and mail T01–T26 remain OPEN.
No goal pause, replacement goal or duplicate hourly reminder. Unrelated WIP
is excluded from publication; protected diagnostics are not read or staged.
Both doc generators passed; staged check_docs validates7110 tracked files and
LF/link invariants. Staged diff check passes. All named136 workers are terminal.

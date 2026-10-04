# Handoff to Fable — LMX kernel, 2026-10-03

Repository: `C:\Nyasha_Planet\LMX`. Active queue:
[next_core_tasks_v2.md](next_core_tasks_v2.md). This is a working handoff, not a
language specification.

The author has asked Codex to finish its current bounded step, update this file,
audit documentation, commit/push the documentation, and stop starting code
stages. Fable takes over implementation. Codex remains available to answer
Fable's questions about the plan and accepted rules; only an unresolved
contradiction or genuinely missing author decision goes to the author, in
Russian, through the Codex chat.

## 1. Read before writing

Read these documents completely in this order:

1. [AGENTS.md](AGENTS.md), [READ.ME](READ.ME), [steps/current.md](steps/current.md).
2. [next_core_tasks_v2.md](next_core_tasks_v2.md) and
   [next_core_tasks_dictionary_v2.md](next_core_tasks_dictionary_v2.md).
3. [CORE_L2_L3_v2.md](CORE_L2_L3_v2.md) and
   [L2_L3_CODING_INSTRUCTION.md](L2_L3_CODING_INSTRUCTION.md).
4. The current RU/EN semantics, grammar and L2 specification in `docs/`;
   the L1 specification for actual lowering/ABI work. Grammar is generated
   from `provenance/grammar.json`.
5. [The two-fix decomposition](plan_critical_graph_bug_critical_pointer_to_struct_bug_fix.md),
   [critical_graph_bug](steps/tickets/critical_graph_bug.md),
   [critical_pointer_to_struct_bug](steps/tickets/critical_pointer_to_struct_bug.md),
   and [the current evidence ledger](steps/critical-graph-namespace-source-layout-20261003.md).
6. [work_chat/README.md](work_chat/README.md) for the question/reply route.

The earlier `next_core_tasks.md`, old `CORE.md`, `from_grok.md`, and the
October1 merge release are historical context. They are not authority to
restore an obsolete layout or restart a superseded ticket. No application or
`myxa_manager` work is included in this handoff.

## 2. Ownership and exact state

There is **one writer/build slot**. Before taking it, inspect actual processes,
current agent/session state, Git status, worktrees and ownership markers.
A marker, dirty diff, old STARTED, delivery ACK or completed sub-ticket is not
proof that a current run is active.

The last documentation baseline before this handoff was `da9a6fc7` on
`main`, equal to `origin/main`. The documentation commit containing this
file supersedes it; obtain its actual SHA locally rather than guessing it.

Active implementation is `dev/l2src_sandbox/`, with relevant adapters in
`dev/l3_interp/`. Stable root `l2src/` has not been updated by these critical
fixes. Do not use `build/opus_wt/` as the current writer tree or silently
combine different ABI generations.

The checkout contains substantial **uncommitted inherited kernel/translator,
harness and fixture WIP**, including new untracked source-name modules and
many graph witnesses. All of it has been preserved. The documentation handoff
does not commit, release, discard or synchronize that code.

This is a **local checkout handoff**. A fresh/cloud clone sees the pushed
documents, not this uncommitted implementation. If continuing elsewhere,
arrange an explicit reviewed transfer of the preserved WIP before editing;
do not substitute the old committed translator or pretend it contains these
measured changes.

The just-finished bounded step changed:

- `tools/l2_harness.ps1`: four measured fixture-oracle migrations;
- `dev/l2src_sandbox/tests/unit_ref_local_path.lm2`;
- `dev/l2src_sandbox/tests/unit_site_layout_local.lm2`.

The production translator and driver were not changed by that step. These
three files remain part of the saved sandbox WIP. Do not stage their entire
larger inherited diff as if it were only the last four-row change.

Start with read-only checks:

```powershell
Set-Location C:\Nyasha_Planet\LMX
git status --short
git log -5 --oneline
git rev-parse HEAD
git rev-parse origin/main
git diff --cached --name-only
git worktree list
python claude_chat/chat_status.py peers
python claude_chat/uds.py --name lmx_uds status
python claude_chat/codex_inbound.py status
```

Do not `checkout/restore/reset/rebase/clean/stash/revert/force-push`, use
`git add -A`, wipe ignored evidence, or kill another writer's compiler.
Preserve backups, markers and unrelated WIP. Review and stage exact owned
paths. A source checkpoint must identify the tested dependency closure, not
just the translator file.

## 3. Core engineering principles — mandatory English instructions

This is the **kernel of a programming language**, not defensive end-user
application code. Implement the simplest universal working algorithm and
test it rigorously. Do not add defensive policy, poison/retry frameworks,
name allowlists, convenience fallbacks, shims or exceptional branches to
cover an ununderstood contract.

All language rules are universal within their domain: no exceptions by
identifier, type, syntax spelling, nesting depth, translation path or fixture.
A local need does not change a base abstraction. If a required contract is
missing or contradictory, present the minimal source example, exact normative
anchors and source symbols to Codex. Do not silently choose new semantics.

L1 is a **generated technical intermediate** on the way to C99. The final
kernel and its self-build orchestration must be L3 with necessary L2 inserts,
not maintained handwritten L1. Existing `.lm1` source is transitional.
Generated L1 remains legitimate. Earlier specification material may be in
`lingvamyxa_prev/Lingvamyxa_spec.txt`; compare it with current accepted
decisions, do not resurrect superseded text.

### One source-faithful graph

- Original containment, field/operation order and binary expressions must be
  recoverable from the retained graph. Declarations, executable operations,
  dormant tails and nested source bodies do not disappear because native
  code exists or a result is discarded.
- There is no permanent auxiliary data/context/callable graph and no second
  source AST/text replay in the runtime. Ordinary machine activation state,
  typed formals, work values and compiler-only borrowed views are allowed;
  they are not new persistent language Structures.
- Names are absent **everywhere** in the graph. The separate address-to-name
  service reconstructs source names; it is not an execution binding table.
  Comments have independent meaning and must be retained in full with their
  placement, outside the execution hot path.
- A materialized primitive cell such as `int: i 5` needs no extra leaf or
  atom metadata: its address and arena type identify it. An unresolved source
  leaf in a dormant Structure is a different role and must be retained.
- COUNT/PLACE/FILL, paths, schema projection, copy/merge and interpreter
  construction must share original source identity and actual physical places.
  Do not fix an oracle by changing only generated temporary names.

### Values, references, admission and calls

- Structure/Array values are descriptor references, not generated C aggregates
  stored by value. Unary `@A` addresses the **real cell holding that reference**
  and adds depth: conceptually `Lmx **`, not another `Lmx *` descriptor read.
  This remains an OPEN implementation repair; old descriptor exemptions do
  not establish correctness.
- A source reference cell, the referent, an activation-owned formal, a work
  cache and an ABI payload box are distinct. Taking an address must not
  expose a convenient temporary or discard a pointer level.
- Resolve the head and source role before interpreting its tail. Follow the
  current documented `b: A` / `@: b A`, ordinary application and explicit
  reassignment rules; do not replace retained bodies or repeated occurrences
  with an invented alias topology.
- Nonexecuting signatures are not bodies. Signature-only synonymy is not
  permission to execute a formal description or collapse unary address depth.
- An ordinary named Structure has a body and **no explicit formal arguments**.
  Its nullary invocation is valid. General `A: B` routing checks the resolved
  A's actual contract; if that contract has no formals, excess arguments are
  an ordinary call error, not assignment fallback. `fn/fm/sub` keep their
  declared formal contracts.
- Defining an unknown head does not execute its body. In Q57, **both** C and
  makeA unknown in `C: makeA()` retain C containing an empty named makeA.
  A known nested callable application is also retained, not eagerly executed
  while the containing Structure is defined.
- Named Structures are not automatically executed in the surrounding source
  sequence. Anonymous bodies execute inline. IF/WHILE/FOR/UNTIL do not acquire
  a separate procedure activation merely because their bodies are Structures.
- `node` is the executing callable's fixed method-parent contract, not the
  dynamic caller or the current control body's generic parent.
- Explicit `copy: merge Model` uses the ordinary merge mechanism.
  Reaching a declaration repeatedly must not invent implicit fresh copies.
- Conversion concerns primitive value categories, including pointers; actual
  Structure compatibility is Consumer-relative `implements`. Convert first,
  admit the actual candidate, then store the destination reference only on
  success. Earlier argument effects and ordinary call/exit publication are
  not rolled back by a later admission refusal.
- Current analytical admission checks the expected consumed interface, not
  algorithmic equivalence. The Consumer unit-test phase is a separate later
  stage; do not introduce candidate algorithm analysis now.
- Field/occurrence correspondence serves the Consumer's actual named paths
  and selectors, not positional zipping or behavioral inference.
- Invoke the actual selected occurrence. Native versus interpreted dispatch
  depends only on its actual native implementation word. Actual inputs,
  defaults, result/exits and admission must match that occurrence, not the
  original exemplar. Correct dispatch alone does not prove correct input
  preparation.

### Arrays and machine boundaries

- Scalar and pointer behavior follows target C99; invent only actual LMX
  abstractions. L2 does not add Array bounds checks. L3 checks the final
  linear element address/bound of rectangular access, not every dimension.
- The base erased Array is `VoidArray { size_t size; void *data; }`.
  Typed descriptors retain their actual C ABI field spelling such as `len`.
  There is no capacity, rank, shape or array-of-dimension-lengths in that base.
  Growth belongs to separate DynamicArray/List.
- `[]: []: ...` is ordinary receiver composition of arbitrary depth, not a
  special two-dimensional Array category. Each selected Array has its own
  descriptor and element contract; `length` reads that descriptor only.
- Flat C-like rectangular adjacent indexing and per-container `\[i]` steps
  are separate contracts. Never infer rectangle/rank from total length or
  confuse another descriptor with another dimension.
- Receiver nesting `a: b: c: ...` has no language depth cap. Remove artificial
  compiler/runtime ceilings through general ownership/traversal mechanisms,
  not a larger fixed number or syntax-specific local parser.
- `c.*` is the raw C token door. Non-`c.*` arguments use normal L2 lowering.
  No header scanners, C-name dictionaries or puts/sizeof/array name exceptions.
  Defined reserved language receivers are not raw-C special cases.

### Lifetime, control syntax and runtime placement

- The sole child-membership List is held by existing `Thread.children` in
  the parent's arena, **not** appended to the source root. Launch settings and
  service data belong to the already described R0 parent stub.
- Message remains minimal message/scheduling core; Thread owns Thread-only
  state. UI/application state belongs to adapters/application Structures.
- R0 follows the ordinary record close order and its ordinary parent stub.
  A shutdown dialog is UI/liveness policy, not a new cleanup protocol.
- A one-level dedent closes implicitly. An explicit closing form is required
  only for a larger dedent. A trailer may close multiple intervening levels,
  but `return` binds to its own method contract: it is not automatically a
  trailer for unrelated bodies.
- No method, sub or named Structure is required to contain explicit return
  or trailer merely to be recognized as a declaration.

## 4. Completed step and honest evidence boundary

[Exact current evidence](steps/critical-graph-namespace-source-layout-20261003.md#persistent-occurrence-oracles)
contains hashes, fixture changes, mutant commands/results and residual debts.

| Evidence | Result | Scope |
| --- | --- | --- |
| `critical_graph_fix_full_32` | RED130/1395 | Latest completed full generated harness. All1380 old targets retained; seven FAIL→OK, no OK→FAIL;15 additions,13 pass/two positive copy-call failures. |
| `critical_persistent_oracle_01` | GREEN7/7 | Four revised fixture rows plus two builds/scope. Not a full rerun or release. |
| Isolated `merge_alias` generated-runtime mutant | Compile0/link0; native/walk driver exit1 | Replacing copied result with original operand yields81 instead of7; confirms the explicit-copy independence oracle detects aliasing. Normal artifacts unchanged. |
| Kernel `critical_admit_status_01` | GREEN292;109 selftests | Bounded runtime admission/status closure,40 checks in the extended admit test; two separate mechanism mutants rejected. |
| L3 `l3_critical_source_admit_01` | All11 suites/four budgets GREEN |75 names/128,1070 bytes/8192; this is not proof of completed self-hosting. |

Current translator SHA256:
`BFF213AC9309EF2D2975499C6894ABA6EA10BE8EBD3DC9B95733E43B7985B81A`.

Current harness SHA256 after the bounded migration:
`DF38FC1D846566A502E6C4CF25AC12677768429B3DB000FFCFA64012D797EA1A`.

Driver SHA256:
`E30B6004CCC89193B3CBBCF1825A234EB79D24B5849F093E346CC4740B0405BA`.

The four revised rows verify actual Counter EXEC identity, persistent local
reference placement, explicit recursive-copy independence, and the unchanged
missing-field negative. Full details belong to the ledger, not an invented
new blanket PASS. Do not subtract focused recoveries from130 to announce a
guessed full verdict. Both critical tickets and8/8a remain OPEN.

## 5. Next work, in dependency order

Review the preserved WIP against the current source and frozen evidence first.
Then continue sequentially; add a concrete necessary subtask to the v2 plan
when discovered, rather than waiting for Codex to guess a new ticket.

1. Recheck the current focused cohort, expand with neighboring unchanged
   controls, then freeze the next full gate. Do not edit copied fixtures during
   a running gate; they are staged by the harness as rows start.
2. Continue **critical_graph_bug**. The immediate real gaps include:
   - actual copied/held-call contract and ordered hidden-input formation;
   - nondestructive named-actual binding: preserve original P0 wrappers/order,
     evaluate payloads once in written order and transport by resolved formal
     coordinates, without a runtime permutation registry or second graph;
   - complete comments/name/source codec and an independent graph decoder;
   - source-faithful producers for native-only imported C local records and
     function pointers, plus retained forward-only callable headers;
   - capture/original-owner closure and artificial metadata/traversal caps.
3. Keep `unit_named_until_copy_call` and its walk pair, plus
   `unit_held_nullary_source_field`, as required **positive** witnesses.
   They currently refuse. Do not rename them into expected negatives, supply
   invented zero-input adapters, or replace actual occurrence provenance with
   the first merge operand.
4. Finish full graph acceptance and publish one exact green dependency
   checkpoint. A source-name service, useful shape assertions or green exits
   alone do not close the codec or the critical ticket.
5. Next: **critical_pointer_to_struct_bug**. Cover real value/place/depth,
   Structure/Array reference cells, formals/locals, copy/merge, null values,
   returns/admission and C99 effective type. No `-fno-strict-aliasing` escape.
6. Then the separately planned Structure/reference application refactoring,
   remaining K01–K12 dependencies and the **clean-kernel checkpoint**.
7. Only after that: stage8 source migration and full two-generation L3/L2
   self-build without handwritten L1; stage8a ordinary calls over Message
   transport and its complete T01–T26 acceptance.

Important source anchors for the next actual-call investigation:
`l2_own_call_origin`, `l2_rw_ns_hidden`, `l2_emit_ns_exec_at`,
`l2_emit_parts`; runtime `lmx_call_prim` and EXEC already dispatch actual
occurrences. For named actuals inspect `l2_bind_call_in`, `l2_bind_calls`,
`l2_rw_call` and `lmx_walk_actuals`. Use symbols and actual current lines,
not old numeric coordinates.

The native-only producer work must preserve source identity while keeping
C ABI locals in ordinary machine activation storage. No persistent graph
pointer may outlive a stack object. The forward-header problem is retention of
the validated original descriptor-only source occurrence, not permission to
invent another METHOD registry or body.

The author question on
[hidden-input name binding](LMX_blog/q/graph-hidden-input-name-binding.md)
is answered (2026-10-04,
[record](LMX_blog/2026-10-04.md#no-runtime-name-table)): no name table at run
time under any conditions; names serve translation and `toLmx` only; addresses
of existing objects do not move. The ban on using the external name table for
construction/copy/call binding is therefore final. Form the actual
occurrence's inputs from correspondences resolved at translation and from
physical references. No name-lookup workaround, hashed-name registry or new
identity layer.

## 6. Verification and release discipline

Use unique fresh output directories and the pinned `bin/l1trans.exe`.
Its SHA256 is
`601D350E853CA16A35EC4B7ED7C2B5B82248A63E96B72A545329B1D8C6AA2196`.
The local compiler is `C:\Qt\Tools\mingw1310_64\bin\gcc.exe`.

Current tools:

```powershell
& .\tools\l2_harness.ps1 -KeepAll -Translator C:\Nyasha_Planet\LMX\bin\l1trans.exe -OutDir C:\Nyasha_Planet\LMX\build\l2_harness\fable_focus_01 -OnlyFixture @('unit_named_struct_call','unit_ref_local_path','unit_site_layout_local','unit_capture_struct_nofield_write_refused')
& .\tools\l2_harness.ps1 -KeepAll -Translator C:\Nyasha_Planet\LMX\bin\l1trans.exe -OutDir C:\Nyasha_Planet\LMX\build\l2_harness\fable_full_01
& .\tools\build_l2src.ps1 -Run -KeepAll -OutDir C:\Nyasha_Planet\LMX\build\l2src\fable_kernel_01
python tools/run_l3_selftest.py --help
python tools/check_docs.py
git diff --check
```

Select the L3 runner's actual output option after reading its help. Do not
overwrite the cited evidence directories. The ordinary kernel gate uses
`-Run -KeepAll`; `-Strict` is a different scope and must not be silently
substituted. Fixture selectors are stems, not paths.

Report compiler/linker/run results separately. Observe actual entry result,
field state, identity, dispatch and admission. A missing output with process
exit0 is still a translator refusal; an interrupted process is not a completed
gate. Clearing only root native does not prove every callee walked.

For a mechanism change, retain an independent mutant that compiles and fails
the intended runtime/structural observation. Do not use a compiler error,
wrong expected return, empty success or timeout as the mutation certificate.
Frozen staging and original artifact hashes must remain intact.

Before release: classify every full refusal against accepted norms, compare
fixture identities and retained failures, run the actual kernel/L3/generated/
documentation gates on the final bytes, review exact diffs, stage explicit
owned paths, commit/push and verify HEAD/upstream. A green kernel suite alone
does not release a red generated translator. Stable/dev convergence includes
the whole tested closure, not a partial ABI copy.

## 7. Questions to Codex through lmx_uds

All inter-agent messages are **English**. Codex addresses the author in Russian.
Use the existing relay/session, not a newly created agent, webhook writer,
watcher or filesystem mailbox.

Fable must **not** run `codex_inbound.py bind`: only the intended Codex task
binds its own incoming pipe. Check status and report routing failure; a stale
pipe is not a language blocker.

Inside Fable's Claude session, resolve the actual unique peer and use its
native tools:

```text
SendMessage(to="lmx_uds", message="From Fable. QUESTION FABLE-CODEX-<unique-id>. Route the full text verbatim to the existing bound Codex task. HEAD <sha>; ownership <files>; minimal program <source>; expected rule <doc anchor>; measured result <output/evidence>; exact source symbols <symbols>; question <one precise decision>. Ask Codex to reply to Fable through lmx_uds with the same request ID.", summary="Kernel question for Codex")
```

The equivalent local client is:

```powershell
python claude_chat/uds.py --name lmx_uds send "From Fable. QUESTION FABLE-CODEX-<unique-id>. Route verbatim to the bound Codex task; preserve sender Fable and request ID. <Full question and explicit return route to Fable through lmx_uds>."
```

The relay completes the final hop:

```powershell
python claude_chat/codex_inbound.py send --sender Fable --request-id FABLE-CODEX-<unique-id> "<Full question; reply to Fable through lmx_uds with the same ID>"
```

The message is a positional argument or stdin; there is no `--message`
option. Codex returns the substantive answer through `uds.py --name lmx_uds
send`, asking the relay to use native SendMessage to the unique Fable peer.
The relay must actually complete that hop, not leave the answer in its own
transcript. No ACK-of-ACK loops.

A good question includes: original source, known/unknown identifiers at that
site, receiving context, exact spec anchors, current symbols/lines, actual
native/walker outcomes and why existing rules do not answer it. Ask about the
shared rule, not a name-specific implementation exception. Established rules
are implemented without repeatedly asking the author.

Track `DELIVERED -> STARTED -> RESULT/BLOCKER` per request. A completed child
run does not mean an unfinished parent stage is still active. If the writer
is idle and its next dependent step is unblocked, explicitly start that
bounded continuation under the same ownership. Long running gates are work,
not idleness; do not interrupt them to manufacture progress.

## 8. Documents and unresolved questions

Specifications contain only accepted normative rules, not agents, tickets,
HOLD/status or implementation evidence. Plans/dictionaries contain the repair
route; `steps/` contains exact measured state. Separate Norm, Implementation
and Verification. Preserve historical hashes and failed attempts as labelled
history; do not keep them as current imperatives.

Store only verbatim technical author clarifications in `LMX_blog/`, with
source/date outside the quote. Organizational handoffs do not belong there.
Open questions **to the author**, not ordinary plan tickets, go in
`LMX_blog/q/current/`; answered questions move up to `LMX_blog/q/`.

This handoff corrected stale v2 claims about names/comments, Array addressing,
local fresh-instance cloning, completed indexed STORE work, the plain merge
spelling, named-Structure arity diagnostics, opcode inventory and old release
status. None of these edits invents a new language rule or closes the critical
fixes. Continue from measured state, not from a historical checkbox.

Codex's implementation turn ends after the documentation commit/push. Fable
owns continuation; Codex is the question-answering advisor. Do not revive the
old Grok reminder automation or other writers from earlier instructions.

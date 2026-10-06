# parser_critical_bug — nested Frame continuation loses its body at a marker

Date: 2026-10-06. Priority: **CRITICAL / P0**. Status: **OPEN**.
Implementation owner: the existing sole kernel writer/build. This ticket is
not an implementation release and does not authorize a competing build.

## 1. Authority, dependency and earlier work

The author identified the misplaced anonymous sibling as a parser defect,
not an alternative interpretation of the intended call. The accepted example
below must retain the body of the nested head. No new implicit prefix-call
syntax is requested: `r: twice 3` is not `r: twice: 3`.

This extends the earlier [common P0 form repair](../../next_parser_fix.md):
equivalent compact, short and vertical forms have one semantic Frame/body
representation, independently of a head's name or later declaration/call role.
That earlier audit is dated evidence, not proof that this extension is repaired.
Reconcile its old implementation findings with current code rather than
implementing a second normalization algorithm beside the existing one.

Track this as a blocking acceptance item in the [v2 plan](../../next_core_tasks_v2.md#parser-critical-bug).
Finish or explicitly hand off the current bounded writer stage before taking
the repair. The graph/pointer/application dependency order is not waived;
neither G5 nor parser migration/self-build may be declared complete while this
critical source-topology defect remains open.

## 2. Exact witnesses and required topology

The author's corrected vertical spelling is a required positive:

```text
r: twice:
. ---
. . 3
---
```

Its semantic P0 topology must equal these controls:

```text
r: twice: 3
```

```text
r: twice(3)
```

```text
r:
. twice:
. . 3
---
```

The common result is one field under `r`, the `twice` Frame; that Frame has
one body field, the atom `3`. Spans and spelling metadata may differ; semantic
ownership, field order and argument count may not. An anonymous positional
container of the entire tail follows the existing transparency rule; it must
not be moved beside its owning Frame.

The author's explicit level justification is part of acceptance: `r` is at
level 0, the nested `twice` at level 1, and the following body at level 2
belongs to `twice`. The physical line containing both heads does not erase
their logical nesting. A later `twice has no argument n` diagnostic from the
misbuilt empty Frame is a downstream symptom, not a language-level reason to
reject this source. Fix the owner selection before argument checking.

The earlier, distinct spelling must also be investigated exactly as supplied:

```text
r: twice:
---
. . 3
---
```

The author subsequently proposed `. ---` as the correct opener. Do not silently
move the first fence when reporting the earlier case, or assume both spellings
are approved synonyms. Establish its admission or rejection from the same
general marker/level rule; if the rule's boundary is genuinely unresolved,
bring the exact contrast to Codex rather than invent another special case.

### Measured baseline, not a repair claim

Read-only diagnostics are in `build/codex_call_vertical_20261006/`:

- `fragment_vertical_fence1.lmx`: existing `printTree` accepts, but its dump
  gives `r` two fields: an empty `twice` Frame and a separate anonymous
  Structure containing another anonymous Structure with `3`.
- `program_vertical_fence1.lm2`: gated `opus_full_32/bin/l2trans.exe` refuses
  at 5:4, `twice has no argument n`.
- `fragment_exact.lmx`: the column-zero first fence is refused by `printTree`
  with P0 error 13 at 3:5, `source level increase must be one step`.
  `program_exact.lm2` independently gets that parser diagnostic at 7:5 from
  the gated translator.
- `program_colon.lm2`, `program_paren.lm2` and `program_vertical_split.lm2`
  all translate successfully using that same translator and its staged
  `convert.lm2`/`primitive.lm2`. Their generated L1 bytes are identical,
  SHA256 `541D4D4B4130F559880897E813D6B54F7BB9C6BDB7E4F72DF66CA9B0B839861E`.

The translator's SHA256 is
`41BD93511C5F97D6E0B15A86A321FF2F362A9AA3DD38EF9BFDFFCEF943BED9D6`.
Its staged parser and the development parser both have SHA256
`F8A9B8E1C873B9FECD2C835D2FDEF9496BE905DAA3C509365D1768FAE4FDFEAF`.
These are parser/translation observations; no new native/walker run or
competing build was performed for this ticket.

## 3. Mandatory historical implementation comparison

The author's latest comparison baseline is the **working, self-building
`C:\Nyasha_Planet\lingvamyxa_old_worked_version`**. Test the real implementation,
not only its specification or examples. Located starting points are
`lm2/parser.lm2`, `lm2/printTree.lm2`, and the generated snapshot
`lm1/build/parser.lm1.c`. The latter also contains
`lm_p0_stream_resolve_pending_delimiter` and the source-level diagnostic.

The earlier requested `C:\Nyasha_Planet\lingvamyxa_prev` remains a secondary
comparison for inheritance, not a substitute for the working baseline.

Trace the same nested-head/marker transitions in that implementation. If a
corresponding executable is available, run the exact witnesses and compare
semantic dumps, with executable/source provenance. Otherwise distinguish a
source-traced comparison from an executed reproduction; any required build
belongs to the sole writer and a fresh output directory. Do not alter the
historical checkout, imported fixtures or goldens to make agreement appear.

**If the historical implementation repeats the bug, fix it anyway in the
current implementation.** Historical agreement is a regression/comparison
signal, never permission to contradict the approved common-form rule.
Record where the behavior was inherited, changed, or independently reproduced.

### Executed comparison and source trace, 2026-10-06

The working checkout reports HEAD `620db86`; its `lm2/parser.lm2` SHA256 is
`EBC4C43342888C4FA7D8CD263A7C07346EDA0778C98708D4729303A2E0F4FC63`.
Its two existing executables were run against the unchanged diagnostic inputs
in the current project's `build/codex_call_vertical_20261006/`:

- `build/p0_tree_contract/printTree_620db86.exe`, SHA256
  `CB564AD6FF52F35E918FFBAE6A6E2E166147DADCAAE445F9D5A2526A77801EF3`;
- `build/lm0/next/printTree.lm0.exe`, SHA256
  `B581C50C14C5C0D8E0E6F5BD540B7BD2F4A8547A45BAF499F125AAE424AF1EA2`.

Both return the same misplaced-sibling dump for `. ---` and the same P0
error 13 for the column-zero fence. The compact, inline-colon and split-head
controls keep `r -> twice -> 3`. These are executed checks of the existing
old binaries, not a claim of a fresh historical rebuild or proof that every
tracked old source byte matches those binaries. No historical files or WIP
were changed; no competing build/self-build was started.

The causal owner loss is source-traced in the old `lm2/parser.lm2`:

1. `lm_p0_stack_install_node_lineage` (4154) installs `parents[1] = r.body`,
   `owners[1] = r`, `parents[2] = twice.body`, `owners[2] = twice`. The empty
   nested body makes `hard[2] = 1`.
2. `lm_p0_stream_resolve_pending_delimiter` (4308), for marker level 1 and
   following item level 2, sees top level 2 and truncates deeper entries to
   level 1 **before choosing the owner of the opened body**.
3. It then chooses `parents[event.level]`, which is `r.body`, and appends the
   anonymous node there. `twice.body` has lost its level-2 continuation. The
   current resolver repeats that ordering (3383); the newer explicit-empty
   close flags are an additional stage, not the origin of this inherited loss.
4. The old physical-line check (5067), repeated in the current stream reader
   (4174), compares only with `last_physical_level`. Audit its interaction
   with installed logical head lineage too: the direct continuation control
   `r: twice:` / `. . 3` is currently rejected before owner resolution. Do
   not simply remove this check and thereby admit all genuine invalid jumps.

Line numbers are this audit's anchors, not stable APIs. These traces identify
repair points; they do not close the full general-level acceptance matrix.

## 4. Generic repair route

1. Freeze the current source/executable baseline and add the required positive
   as a failing P0 topology row and a failing translation/runtime acceptance
   row. Keep the two exact fence levels distinguishable in the evidence.
2. Trace the complete path: token/stream levels, inline nested-head lineage,
   marker lookahead, parent/owner selection, empty-body closure, and final
   normalization. Current starting symbols in
   `dev/l2src_sandbox/l1src/parser.lm1` are
   `lm_p0_stack_install_node_lineage`, `lm_p0_stack_collapse_soft_to_event`,
   `lm_p0_stream_apply_event`, `lm_p0_stream_resolve_pending_delimiter`,
   `lm_p0_stream_apply_item_event`, `lm_p0_validate_nonempty_colon_frames_in_node`
   and `lm_p0_normalize_sole_anonymous_container`.
   Include physical-line transition validation versus already installed
   logical head levels, not only the final anonymous-node attachment.
3. Establish one general owner/continuation invariant for heads composed on
   one line and across lines. A marker opening the nested body's admitted
   continuation must not first finalize that head as empty and then append
   the body to its outer owner. Determine open/continue/close from the general
   parse state and following level, not the callable name or arity.
4. Repair that shared state transition and reconcile every consumer. Preserve
   genuine anonymous sibling boundaries and named fields. Do not recursively
   flatten all Structures, ignore all fences, disable level validation, or
   compensate in `l2_call_args`/native/walker for an already wrong P0 tree.
   No branch for `twice`, `r`, known callables, two heads, two levels or a
   particular source position. Receiver/head chains have no fixed depth cap.
5. Revisit the whole earlier `next_parser_fix.md` matrix against the repaired
   common mechanism, including empty and nonempty bodies. Synchronize the
   three maintained parser copies and their generated/self-build seeds under
   the established development/stable promotion protocol; update the L2 port
   where the same mechanism is maintained. Do not leave a second old parser
   route as a fallback. Update current goldens, not imported historical bytes.
6. If current normative wording admits the wrong ownership or conflicts with
   the author's clarification, correct the paired grammar through
   `provenance/grammar.json` and its generator, with matching semantic links.
   Keep implementation observations in this ticket/steps, not in the specs.

## 5. Acceptance matrix and release barrier

- **Topology:** compact, colon and corresponding vertical forms have identical
  ordered semantic dumps, before any translator knows the head's role. Include
  one and several operands, empty bodies, longer chains, mixed inline/vertical
  nesting, and embeddings in named and anonymous outer bodies.
- **Ownership controls:** an intended body remains under its head; a genuinely
  separate anonymous sibling remains separate. A named argument and an
  anonymous Structure among other fields are not flattened away. Every source
  occurrence is retained once; no operand is dropped, duplicated or moved.
- **Grammar negatives:** unfinished `f:`, `f:;`, `f: )`, invalid level changes
  and incompatible closers still refuse with located diagnostics. Dedent by
  one remains implicit; a method's own trailer and an internal `return` retain
  their different targets. Test repeated markers and comments between items.
- **Role independence:** parser equivalence is the same for arbitrary/unknown
  heads, nested receiver composition, an assignment destination and a known
  callable. It neither executes a definition nor invents a `twice 3` call.
- **Runtime:** define `fn: twice (int: n) int / return: n * 2`, declare `int: r 0`,
  evaluate each admitted spelling, and observe `r = 6` in native and genuinely
  forced-walker execution. Add ordered/multiple-operand controls that expose
  loss or reparenting; translation success alone does not close this row.
- **Counterfactual:** disabling the common owner/continuation repair must make
  a topology or runtime observer fail for the misplaced-body reason. A test
  counting success exits alone is insufficient.

Run current, previous-l1 and historical parser profiles with the freshly built
parser in separate output directories (`tools/run_parser.py`). Historical
differences must be explained, not normalized by rewriting imported goldens.
Then run focused L2 fixtures, the full `tools/l2_harness.ps1` gate,
`tools/build_l2src.ps1 -Run`, `tools/run_l3_selftest.py`,
`python tools/check_docs.py`, and scoped `git diff --check` on the exact release
bytes. Use fresh output tags under the existing writer's ownership. Compare
full failures by fixture/stage/reason with the prior baseline; a focused green
test or previously green empty-form gate is not a universal-parser release.

Close only with the generic mechanism, old competing routes removed, current
copies/seeds and docs consistent, and the complete above matrix evidenced.
Record any remaining failures explicitly and keep G5 blocked accordingly.

# Parser level/form ownership — research after self-build

Date: 2026-10-06. Status: **DEFERRED RESEARCH — after accepted S8.6**.
The author cancelled the previously requested parser fix. This ticket is not
a bug classification, an implementation assignment, or a G5/stage-8 blocker.
Do not change parser code, seeds, normative admission or test expectations on
its authority. Any later implementation requires a separate decision.

## 1. Authority, dependency and earlier work

The author's latest instruction supersedes the earlier repair priority:
investigate the level/form question immediately after the full stage-8
self-build. The earlier parser implementation request is cancelled, not merely
waiting for a free build slot. Preserve measured differences without treating
their interpretation as a settled requirement to change the parser.
The separate explicit-call decision is unaffected: no new implicit prefix-call
syntax is requested; `r: twice 3` is not `r: twice: 3`.

Read the earlier [common P0 form investigation](../../next_parser_fix.md) and
the current paired grammar alongside this evidence. Determine which forms are
equivalent under the general rules and which markers establish a distinct
boundary. That older audit is dated evidence, not proof of the interpretation
of this particular nested-marker case. Do not introduce a second normalization
algorithm or infer a new call syntax from the comparison.

Placement: [immediately after S8.6 in the v2 plan](../../next_core_tasks_v2.md#parser-level-forms-research),
before the next written stage. This research is not part of self-build
acceptance and does not reopen G5. Continue the existing kernel and self-build
queue without a parser fix for this question. Preserve the sole writer/build;
no additional agent, competing build or automatic code stage is authorized.

## 2. Exact forms and the research question

Compare the author's proposed vertical spelling exactly as supplied:

```text
r: twice:
. ---
. . 3
---
```

Compare its semantic P0 topology with these controls:

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

The three controls produce one field under `r`, the `twice` Frame, whose body
contains atom `3`. The proposed marker spelling instead produces a sibling
in the tested implementations. Research whether the marker should continue
that nested head or close it and open another section, and reconcile the
answer with the general form-equivalence and positional-container rules.
Separate semantic ownership from source spans and spelling metadata.

The author's level argument is the question's starting point: `r` is at
level 0, the nested `twice` at level 1, and the following body at level 2 is
expected to belong to `twice`. Explain how logical head nesting, physical
line levels and the marker's own level interact. The downstream
`twice has no argument n` diagnostic establishes what the translated tree
contains; it does not itself settle the intended grammar interpretation.

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
report the exact contrast and alternatives rather than invent a special case.

### Measured baseline, not a grammar verdict

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

Historical agreement is evidence about implementation, not by itself an
answer to the language-design question. The earlier instruction to proceed
directly to a fix is superseded by the author's cancellation. Record where
the behavior was inherited, changed or independently reproduced; propose
any correction separately after research, without implementing it now.

### Executed comparison and source trace, 2026-10-06

The working checkout reports HEAD `620db86`; its `lm2/parser.lm2` SHA256 is
`EBC4C43342888C4FA7D8CD263A7C07346EDA0778C98708D4729303A2E0F4FC63`.
Its two existing executables were run against the unchanged diagnostic inputs
in the current project's `build/codex_call_vertical_20261006/`:

- `build/p0_tree_contract/printTree_620db86.exe`, SHA256
  `CB564AD6FF52F35E918FFBAE6A6E2E166147DADCAAE445F9D5A2526A77801EF3`;
- `build/lm0/next/printTree.lm0.exe`, SHA256
  `B581C50C14C5C0D8E0E6F5BD540B7BD2F4A8547A45BAF499F125AAE424AF1EA2`.

Both return the same sibling dump for `. ---` and the same P0
error 13 for the column-zero fence. The compact, inline-colon and split-head
controls keep `r -> twice -> 3`. These are executed checks of the existing
old binaries, not a claim of a fresh historical rebuild or proof that every
tracked old source byte matches those binaries. No historical files or WIP
were changed; no competing build/self-build was started.

The relevant state transitions are source-traced in the old `lm2/parser.lm2`:

1. `lm_p0_stack_install_node_lineage` (4154) installs `parents[1] = r.body`,
   `owners[1] = r`, `parents[2] = twice.body`, `owners[2] = twice`. The empty
   nested body makes `hard[2] = 1`.
2. `lm_p0_stream_resolve_pending_delimiter` (4308), for marker level 1 and
   following item level 2, sees top level 2 and truncates deeper entries to
   level 1 **before choosing the owner of the opened body**.
3. It then chooses `parents[event.level]`, which is `r.body`, and appends the
   anonymous node there; the saved level-2 owner is no longer installed. The
   current resolver repeats that ordering (3383); the newer explicit-empty
   close flags are an additional stage, not the origin of that ordering.
4. The old physical-line check (5067), repeated in the current stream reader
   (4174), compares only with `last_physical_level`. Audit its interaction
   with installed logical head lineage too: the direct continuation control
   `r: twice:` / `. . 3` is currently rejected before owner resolution. Do
   not simply remove this check and thereby admit all genuine invalid jumps.

Line numbers are this audit's anchors, not stable APIs. These traces explain
the observed tree; they do not settle the full general-level rule or authorize
changes to those transitions.

### Newline counter reset in the working historical source

In `lm_p0_parse_stream`, `level: 0U` (4925) initializes the next physical
line's level before scanning its leading zone. Dots increment that value
(4971); ordinary indentation instead supplies it through
`lm_p0_indent_level_from_column` (4991). The previous physical level remains
in the separate `last_physical_level` variable (5067, 5103), and the
parent/owner stack is allocated before the line loop, not reset here.
This temporary zero is not itself a close event for a nested head.

The bounded/short-form reader has a separate newline route:
`lm_p0_source_level_after_line_break` (2944) computes `next_level` from the
new line, and `lm_p0_skip_field_space` assigns it to `current_source_level`
(3007) after its continuation checks. Distinguish these counters and the
persistent owner stack when researching mixed inline/vertical forms; do not
infer a grammar rule merely from the initial zero of the line accumulator.

## 4. Research route — no implementation

1. Start after accepted S8.6. Freeze the then-current self-built source and
   executable baseline and reproduce the exact forms in isolated evidence
   directories. Keep the two fence levels distinguishable; do not convert
   proposed forms into mandatory positive or negative regression rows yet.
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
3. Derive and compare general open/continue/close interpretations from the
   current normative grammar, the earlier form-equivalence work, and the
   working historical implementation. Explain the role of physical versus
   logical levels, marker lookahead, empty bodies and real siblings. Do not
   assume every fence is an opener, every fence is a closer, or every
   anonymous boundary is transparent.
4. Measure a representative matrix: compact/short/vertical spellings, empty
   and nonempty tails, longer head chains, mixed inline/vertical nesting,
   named/anonymous outer bodies, real siblings, named arguments, comments,
   repeated markers, dedent and valid/invalid closers. Include arbitrary
   heads, not only callables; parser ownership cannot depend on callee arity.
5. For admitted examples, trace translation and native/walker consumption
   with observable results, keeping those observations separate from P0
   shape. Record any source, executable or seed drift and its consequences;
   a successful translation does not prove execution.
6. Deliver the findings and minimal alternatives to Codex. Any genuine
   unresolved language choice goes to the author in Russian, with exact
   examples and symbols. Do not implement an alternative, rewrite normative
   admission or change current/imported goldens without a separate decision.

## 5. Research completion

The deliverable is an evidence-backed report, not a parser patch:

- exact source/executable provenance for the self-built and historical runs;
- admission and ordered semantic dumps for each form, with actual owners;
- a coherent account of logical and physical levels and marker transitions;
- comparison with the paired grammar and the earlier common-form work;
- measured translation/execution consequences, clearly distinguished;
- unresolved questions, alternatives and consequences, without special cases;
- a separately proposed implementation ticket only if a decision requires one.

Existing parser tests and gates keep their independently approved contracts.
This research adds no required failure to G5, no prerequisite to S8.6, and no
automatic seed promotion or full repair gate. Its completion does not itself
authorize a parser change. Keep the cancellation and deferred status explicit.

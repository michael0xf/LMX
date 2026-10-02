# critical_graph_bug — source structure is destroyed while constructing the retained graph

Date: 2026-10-02. Priority: **CRITICAL / P0**. Status: **OPEN**.
Requested by the author; recorded by Codex. Implementation owner: not claimed.
This commit creates the ticket, not its implementation or a second writer.

This is a concrete defect under [K10: the complete lexical graph](../../next_core_tasks_v2.md#graph),
not a new language feature. It blocks a claim of complete graph preservation or
completion of the clean-kernel/self-build goal. Take it through the existing
single-writer/build process; do not overlap the current owner's code or gates.

## 1. Required invariant

**The source determines the graph's structure and the order of its fields.
The retained graph must contain enough information to recover the structure
of that source. Constructing the graph must not destroy that information.**

The author's exact clarification is archived in
[the technical journal](../../LMX_blog/2026-10-02.md#graph-preservation).
The existing architectural requirement is also recorded in
[CORE_L2_L3_v2, one graph](../../CORE_L2_L3_v2.md#one-graph).

This is structural recoverability, not a demand to reproduce identical source
bytes. Existing equivalence of short, block and parenthesized spellings and
the parser's general transparent-container rule remain in force. Do not invent
syntax-form distinctions to repair this defect. Existing source/name/comment
retention obligations are not weakened by this ticket.

Receivers may materialize typed value storage: for example, `int: i 5` can
produce an initialized int cell at the declaration's place. Recoverability
must account for that existing receiver semantics. It does **not** require
turning a primitive into another Lmx Structure, duplicating its storage,
preserving a history of its changing values, or recovering an old initializer
from a cell that has subsequently been modified.

It does require all of the following:

1. Preserve the source-defined ordered containment of declarations, value
   leaves, expressions, applications and nested bodies, including empty bodies.
   Source names and occurrence identity needed to recover that structure must
   remain available through the established graph/name mechanisms.
2. Do not gather all value fields first and append all executable statements
   later. The order of executable effects alone is not the order of the graph.
3. Do not erase a body or its operands because its result is discarded, it has
   no side effects, it is not currently called, or the native backend needs no
   instructions for it. Audit unreachable tails as well: execution stopping
   at `return` does not by itself erase the source structure after it.
4. Keep the distinction between an application Structure and the typed cell
   that receiving it may modify. `i: 6` is not the declaration cell `i`.
5. Native optimizations may change generated machine code, not the retained
   language graph. Presence or absence of `native` must not change its source
   structure. Dispatch and existing activation/publication semantics remain
   unchanged by this structural repair.
6. Do not satisfy the invariant with a source string, a test-side copy of P0,
   or a second persistent data/callable/source graph while leaving the actual
   retained graph incomplete. A test may use P0 as its independent oracle;
   the graph decoder must obtain the tested structure from the graph itself
   and its established source metadata, not replay the input file.

## 2. What was actually inspected and measured

Inspected development tree: `dev/l2src_sandbox/`.
Committed baseline: `36bbefca0e4b98fa254440fd9ee75d8fb6f0f281`.
The working translator and harness also contained another agent's WIP;
that WIP was neither changed nor used to build an audit binary.

Five fresh **translation-only** probes used the existing executable:

```text
build/l2_harness/gk_occ_formal_full_01/bin/l2trans.exe
SHA256 B196EB56270DF4400DDAB0CBC335FD42255FCE7AF4EFD84130B76D309A12FE73

frozen translator source:
build/l2_harness/gk_occ_formal_full_01/src/l2src/l2trans.lm1
git blob 44e8e4e1b355e2ad81de86d9c1e2cab4d5e08c9f
```

That source blob equals `HEAD:dev/l2src_sandbox/l2trans.lm1` at the baseline
above. Generated probes are local evidence under
`build/codex_graph_structure_audit_20261002/`, not tracked acceptance tests.
No new kernel build or runtime execution was performed in this audit.
The executable's prior full gate reported **1147 targets / 36 failed**;
it is not a green full-kernel certificate.

### 2.1 Values and instructions are separated; expression contents disappear

Minimal inspected body (`mixed_body.lm2`):

```text
sub: task ()
    int: i 5
    i: 6
    int: j 9
    (2 + 2)
    return
task
sendMessage: exit(exit_code: 7; stdout: ""; stderr: "")
return
```

Translation succeeds. The generated occurrence first receives signature parts,
the int cells for `i` and `j`, and an **empty** Structure for `(2 + 2)`.
Only afterwards are the executable SET nodes and return record appended.
In the measured output, `i` and `j` occupy slots 2 and 3, the empty container
slot 4; the executable SET nodes start at slot 5.

**`i: 6` has not vanished.** It is lowered to `SET(OWN(i), LIT(6))` and the
executable sequence still establishes `i = 5`, then `i = 6`, then `j = 9`.
The demonstrated defects are the loss of source-relative placement and the
erasure of the contents of `(2 + 2)`. Do not misreport this witness as proof
that the assignment itself never executes.

Relevant symbols in [l2trans.lm1](../../dev/l2src_sandbox/l2trans.lm1):

- `l2_m_kids`: header parts + own fields + control bodies.
- `l2_m_width`: adds the executable-step region after those children.
- `l2_rw_methods_emit`: emits statements starting at `l2_m_kids(i)`.
- `l2_body_inert`: treats pure discarded expressions as inert.
- `l2_rw_stmt`: returns without emitting their anonymous executable body.
- `l2_emit_unit`: constructs the control-body Structure even when the walker
  emission has removed its expression contents.

### 2.2 Unknown `A: b` is refused instead of retained

Both these complete-program prefixes fail at the unknown head `A` with
`unresolved name` (`unknown_atom.lm2`, `unknown_known_atom.lm2`):

```text
A: b
```

```text
int: b 5
A: b
```

`l2_tail_is_structure` explicitly classifies a single-atom tail as not a
Structure. This conflicts with the author's explanation in the current chat:
unknown `A: b` defines a Structure whose body contains atom `b`.
Repair through the general head/body classification, not by adding exceptions
for these names or one spelling. Retaining a definition is not executing its
body; do not impose value-evaluation requirements merely to preserve it.

### 2.3 A known call has a real Lmx header, but a lowered protocol layout

This prefix translates (`known_call.lm2`):

```text
sub: A (int: x)
    return
int: b 5
A: b
```

The generated CALL Structure contains a role, the selected occurrence twice
under the current ABI, a receiving contract, catch position, and an
`OWN(holder, slot)` operand for `b`. It is **not** the source application/body
structure with its atom retained as such.

[lmx_walk_frame](../../dev/l2src_sandbox/lmx_walk.lm1) really allocates an
ordinary Lmx via `lmx_walk_plain` / `lmx_struct_new_owned`. That confirms its
physical header, not preservation of the source's containment or field order.
Do not close this ticket by proving only `kind == LMX_KIND_STRUCT`.

Here `A` is a declared callable with a suitable formal. This witness does not
make every known head callable: primitives/references retain their assignment
rules; a call must satisfy the selected callable's existing contract. An
ordinary named Structure does not acquire formal arguments through this fix.

The additional `retained_body.lm2` probe, `Batch: (A: 5)` followed by `Batch`,
also translates. Translation success alone does not certify graph recovery.

## 3. History, without attributing unrelated edits

- `5a77cb2a` (2026-09-23, Opus co-author): introduced `l2_body_inert` and native
  discard handling.
- `2e8d1fb3` (2026-09-24, Opus co-author): explicitly omitted inert anonymous
  bodies from the walked graph; its message names `(2 + 2)`.
- `47b99677` (2026-09-24, Opus co-author): appended method op-trees after fields
  and control bodies to avoid moving existing field positions.

See [the block audit](../root-walk-blocks-arrays.md) and
[T4a history](../merge-parts-193.md). Later edits by several agents retained
these choices. This is not evidence that the latest callable-formal patch
introduced them. Historical passing effect tests do not prove graph fidelity.

## 4. Repair boundaries and approach

Primary scope is the common graph construction/layout in `l2trans.lm1` and
the consuming walker in `lmx_walk.lm1` / `lmx_walk.h.lm1`. Inspect
`lmx_interp.lm1`, graph-copy/merge and path/occurrence consumers for dependencies
on the old field-prefix/step-suffix layout. Change them only where the common
invariant requires it. Keep the minimal Lmx/Array representations unchanged.

Before editing, inventory every construction path: unit, named definition,
method, method-local definition, anonymous/control body, signature parts,
application/argument body, returned/merged occurrence and native-only body.
Identify each place that skips, flattens, reorders or substitutes source nodes.
Do not mistake the native output emitter for the source graph constructor.

Build one source-ordered representation with the receiver-created typed cells
at their appropriate source places. Native execution and interpretation must
consume that representation or its ordinary compiler metadata; neither may
require a second persistent graph. Internal operation metadata is not a reason
to replace the source graph by a non-recoverable instruction encoding.

Update occurrence/path layout and declaration lookup together. Do not keep the
old positions by sorting fields, adding an invisible prefix/suffix, or building
a compensating permanent index graph. Preserve existing bare-name versus
explicit occurrence-selector semantics and implements interface matching;
this ticket introduces no algorithm-equivalence analysis.

If a representation choice genuinely conflicts with an accepted language rule,
record the smallest example and exact symbols, ask Codex, and escalate only an
unresolved author decision in Russian. Do not invent a hidden exception.

## 5. Acceptance: inspect the graph, not only execution results

All items are required; implementation status remains OPEN until demonstrated.

- [ ] Add a graph-side structural decoder/witness, separate from execution,
  and compare it with the canonical source structure under existing parser
  normalization and receiver materialization rules. The test must not depend
  on generated temp names, raw addresses or the old slot constants.
- [ ] The mixed body in section 2.1 recovers the original ordered placement:
  declaration `i`, application `i: 6`, declaration `j`, anonymous expression
  body, return. The typed-cell representation of a declaration is permitted;
  moving both cells ahead of the intervening application is not.
- [ ] `(2 + 2)` retains its expression structure and operands, not an empty
  placeholder. Include `2`, `2 + 2`, `()`, strings, nested anonymous bodies,
  discarded call results and source after `return`. No side effect is needed
  for a source node to deserve retention.
- [ ] Unknown `A: b` retains the definition/body for both unknown and known
  `b`. Include nested definitions and nonempty equivalent surface forms.
  Separate graph construction from validation/execution of a reached use.
- [ ] Known `A: b` and equivalent `A(b)` retain the canonical application and
  argument-body structure; a suitable method call runs correctly. Existing
  primitive/ref assignment and invalid-call diagnostics remain correct.
- [ ] Cover source-ordered fields/operations in unit, method, named Structure,
  anonymous/control body and nested combinations. Include repeated names and
  indexed occurrences; do not infer source order from the current field table.
- [ ] Graph fidelity is the same with native implementations present and with
  supported execution forced through the walker. Verify actual dispatch, not
  merely successful compilation or an unexercised native word.
- [ ] Copy/merge preserve the recovered structure, order, sharing and parent
  relationships according to their existing contracts. No hidden companion
  graph or persistent activation object is introduced.
- [ ] Run independent mutation controls: erase a pure expression, move a
  declaration across a statement, collapse two occurrences, or replace a body
  by an empty container. Each must fail a structural assertion even when the
  program's exit value is unchanged. Restore exact bytes before final gates.
- [ ] Add positive runtime witnesses as well: assignment/call effects,
  working-state publication and existing native/walker behavior remain right.
  Runtime witnesses need an observable success value, not silent fall-through.

## 6. Checks and release evidence

Register the new fixtures and their graph-inspection assertions in the existing
harness before claiming acceptance. A new fixture selector/inspector command
must be documented here once implemented; this ticket does not pretend that
such a checker already exists.

Once the sole build slot is available, run the actual repository gates
sequentially, from the repository root, using a fresh output stamp per run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/l2_harness.ps1 -OutDir build/l2_harness/critical_graph_bug_full_01 -KeepAll
powershell -NoProfile -ExecutionPolicy Bypass -File tools/build_l2src.ps1 -Run -OutDir build/l2src/critical_graph_bug_01 -KeepAll
python tools/run_l3_selftest.py --output build/l3_selftest/critical_graph_bug_01
python tools/check_docs.py
git diff --check
```

Compare failures by exact identity against the declared baseline; do not call
an existing red full gate green or waive graph-specific failures. Record source
and executable hashes, fixture identities, structural assertion counts, actual
native/walker runs, mutation results and the final commit. A passing execution
gate with no structural assertions does not close this ticket.

Update contradictory current documentation/tests with the repair, preserving
historical evidence as history. List exact files touched and remove obsolete
graph-building paths rather than retaining fallback implementations.

When taking ownership, add `TAKEN <branch>@<sha> <UTC time>` here. Close with
`DONE <sha> <UTC time>` only after the structural and behavioral acceptance is
met. The next active plan is `next_core_tasks_v2.md`; the older plan remains
historical context.

Дальше — продолжать `next_core_tasks.md` (активная очередь — `next_core_tasks_v2.md`).

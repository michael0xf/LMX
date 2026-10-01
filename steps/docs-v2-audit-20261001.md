# Documentation handoff and audit — 2026-10-01

## Scope and authority

The author requested four detailed restart documents, a review of all `docs`,
commit/push of the current work and a full stop before the next code stage.
Application work is excluded from the new plan. The source checkpoint is
`8359a59f67b87382c55eb402e9f09f9a4b1ce954`; this audit does not claim that stages
8/8a or the clean-kernel gate are complete.

Deliverables:

- [Remaining work through 8/8a](../next_core_tasks_v2.md).
- [Implementation dictionary](../next_core_tasks_dictionary_v2.md).
- [Technical kernel/L2/L3 map](../CORE_L2_L3_v2.md).
- [L1→L2→L3 coding guide](../L2_L3_CODING_INSTRUCTION.md).

Normative claims were compared with current specifications and recorded author
decisions. Implementation claims were checked against source symbols and scoped
evidence; proposed construction ABI and unimplemented language paths are labelled
as such. A peer's review is not presented as a compiler/runtime test.

## Inventory reviewed

| Document family | Scope |
| --- | --- |
| `docs/L1_spec_{ru,en}.md` | Both languages; level role, C99 boundary, references, raw C, implementation symmetry |
| `docs/L2_spec_{ru,en}.md` | Both languages; descriptors, ranges, calls, node, typed storage, Array paths and bounds, mail |
| `docs/LMX_grammar.{ru,en}.md` | Both languages and `provenance/grammar.json`; active prose versus historical excerpts |
| `docs/LMX_semantics.{ru,en}.md` | Both languages and `provenance/semantics-book.md`; all chapters and current construction/call/Array/reference rules |
| `docs/implementation-notes.{ru,en}.md` | Snapshot qualifications and current versus historical mechanism claims |
| `docs/source-comparison.{ru,en}.md` | Historical status; no promotion of old layouts into current norms |
| `docs/new_parts/assignment_is_not_declaration.en.md` | Q50–Q52, declared storage, no extra data graph, current construction and references |
| `docs/new_parts/local_declarations_and_explicit_initialization.to_fable.en.md` | Explicit declarations, retained operators, historical reports, unknown-head examples |
| `docs/new_parts/dirty.md` | Restored cache semantics versus superseded argument-field/sticky/re-entry descriptions |
| `docs/new_parts/merge_documentation_corrections.en.md` and `_next.en.md` | Accepted copy/native/default decisions versus completed historical editing instructions |
| `docs/new_parts/threadMessageAPI.{ru,en}.md` | Common calls/mail, wait ownership, T01–T26, no alternate exported API |
| `docs/new_parts/threadMessageAPI_migration.{ru,en}.md` | Shared send/receive substrate and preserved explicit interface |
| `docs/new_parts/mutating_debug_API.{ru,en}.md` | Proposed versus established contracts and source links |

The directory contains 23 Markdown files. Historical imported excerpts and
source-comparison snapshots remain verbatim; their age is not a reason to
rewrite evidence. Current normative prose must not borrow superseded rules from
those excerpts.

## Corrections made

1. L1's role is a generated intermediate; the handwritten current runtime is
   transition state, not the final maintained kernel organization.
2. Current Lmx schematics include array/parent/native. Removed the contradictory
   active mention of a current `LmxArrayDesc` alias from the Array description.
3. Grammar and table prose now agree on LAST for unqualified repeated names and
   explicit `[N]` for a chosen occurrence. Historical quoted source is unchanged.
4. Array prose no longer promises implicit row-view descriptors or dimension
   recovery. L2 is unchecked; L3 checks the final linear element, not each
   coordinate. Adjacent flat indices and `\` hops remain distinct.
5. Older CORE text no longer describes Thread execution-mode requests, method
   occurrence retention as a general copy terminal, or already repaired stop
   routes as the current unresolved defect.
6. Active “saved call” terminology was replaced by the ordinary retained call
   operator, without inventing a saved-call object.
7. Completed merge editing tasks are marked historical so resolved questions
   and withdrawn proposals cannot masquerade as new assignments.
8. Four broken debug-document source links now point to canonical semantic
   documents; historical snapshot paths/hashes are explicitly retained as such.
9. [Q59](../LMX_blog/q/q59.md) closes the ambiguity found during this audit:
   ordinary named Structure has only a body and no arguments. `A: B` is the
   general call form and is checked against **resolved A**, not categorically
   banned by its syntax. fn/fm/sub signatures are unchanged. Current compiler
   “not built yet” refusal text remains an accurately recorded diagnostic debt.

## Array checklist carried into every v2 document

- General receiver composition has no fixed depth; `[]: []:` has no private
  two-level syntax or separate runtime kind.
- Flat C-like rectangular construction/addressing is separate from an Array
  holding references to other Arrays.
- `a[i][j]` uses one flat rectangle; `a[i]\[j]` selects another Array value.
- `a\[i]` is an unnamed typed Array step; `s\[N]name` is named occurrence access.
- `length` reads the selected descriptor, including total length for a rectangle.
- No runtime `shape`/`rank`, dimension vector or per-coordinate L3 bounds promise.
- Base Array has no capacity/growth/backing-swap policy; separate DynamicArray
  retains its own capacity.
- C99 primitive types, size_t lengths and actual typed-cell addresses are preserved.
- Char Arrays have exact logical length and no hidden NUL. C-string conversion
  is explicit; process argument letters have an ordinary declared structure.

## Four-document adversarial review

The author explicitly requested another check for invented semantics. The map
writer reviews the independently written plan/dictionary; the guide writer
reviews the map; the coordinator reviews the guide and all reported corrections.
This is separate from each writer's own check.

The coordinator identified guide examples that could silently redefine the
language: unknown `row:`/`cell:` used as if they were typed assignments; an
altered Array receiver example; ambiguous C-sizeof operand treatment; a control
body described as creating an activation; overly broad denial of method metadata;
and self-build phrased as two compilations rather than two tested replacements.
These must be corrected before the handoff is accepted. No kernel changes or
new language mechanism are authorized by those documentation repairs.

All listed guide corrections were applied. The independent plan/dictionary
review also narrowed “no header scanners” to the forbidden raw-C allowlist/
semantic-registry mechanism, preserving ordinary explicit ABI/header lowering,
and added the remaining runtime traversal caps to the dependency inventory.
The map review added the missing library lifetime/instance debt link and verified
that pending-release wording was replaced by the actual source checkpoint.
The final coordinator pass also distinguishes absence of explicit arguments from
absence of hidden inputs, and keeps artifact comparison optional rather than
quietly adding it to the two-generation self-build criterion.

The canonical post chapter no longer embeds the work order, T01–T26 task table,
agent/date narrative, ticket IDs or deliverable instructions. Its accepted
language/ownership/clock/mail rules remain; the detailed implementation task
and complete acceptance matrix are retained in `docs/new_parts` and the v2 plan.

## Validation and remaining limits

Validation includes regeneration of both semantic and grammar projections,
`python tools/check_docs.py`, whitespace/control-byte checks, and an additional
local-file/anchor pass over the four new root documents and every `docs` file.
The additional pass is necessary because the normal checker does not include
all root documents or `docs/new_parts`. Final results are recorded below before
commit.

Code evidence remains scoped: 1062/1110 generated targets with the same old 48
failures, kernel 286/286, L3 11 suites/295 checks and four budget controls.
The documentation does not convert these to a full clean-kernel success.
Open failure-interface/module-unload/crypto-profile questions in implementation
notes remain questions where not answered; they are not resolved by editorial
invention or allowed to expand this handoff into application work.

The active goal is paused after push. No next-stage ticket, external watcher,
build or background continuation is started by this documentation handoff.

## Final documentation validation

- `python tools/check_docs.py`: PASS; 35 paired semantic chapters,
  14 admission cases, 27 grammar sections, 229 preserved source excerpts,
  615 imported files, exact author opening and paired links.
- Additional check over 27 files (all 23 `docs` Markdown files plus the four
  root deliverables): 776 local file/anchor links, zero missing targets.
- All four root deliverables: zero disallowed control bytes/CR; balanced code
  fences. Final counts are 630/501/814/913 lines respectively, about 207 KB total.
- `git diff --check`: PASS. Indexed LF/control-byte validation is repeated after
  explicit staging so new documents are included in the standard checker.
- Exact source/staging verification remains the bounded merge release's own
  evidence, not a new build performed for this documentation edit.

The pre-existing `steps/receiver-declaration-review-20260930.md` change,
untracked `LMX_blog/q/q53.md` and `l2_driver_launch.err` are outside this owned
handoff and were preserved without staging or modification.

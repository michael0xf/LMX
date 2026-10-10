# COPIER-FULL-COPY — the pointer-cell pointee is copied (`fable_pc`, 2026-10-10)

## Rule

The author (2026-10-10, verbatim in [`LMX_blog/2026-10-10.md#full-copy-20261010`](../LMX_blog/2026-10-10.md#full-copy-20261010)
and [`#merge-universal-20261010`](../LMX_blog/2026-10-10.md#merge-universal-20261010)): copying at
any merge is full; only `independent: const: immutable` branches are retained by reference; the
rule is universal for merge, not a Message-creation special case, and it has no implicit
shared-mutable exception. The three explicit mechanisms for anything shared: a prototype
template initialized through arguments (separate mutable instances), `independent: const:
immutable` (shared immutable values), a Message (deliberately shared storage). A case the three
do not cover, or one that conflicts with Message/Thread identity, goes to the author as the
smallest witness before any exception is coded. The semantics book already said this of
ordinary copied targets ([composition](../docs/LMX_semantics.en.md#composition)); the kernel's
-186 k3 rule (pointer cell copied, pointee shared) contradicted it and is withdrawn. The
throw-name carrier question (slice A2) is not touched by this decision.

## Code

`dev/l2src_sandbox/lmx_graph_copy_owned.lm1`, `lmx_copy_value`, the branch
`vtype >= LMX_TYPE_POINTER_BASE`: the fresh pointer cell enters the map before its pointee is
copied (a pointee that points back finds it), then the pointee goes through `lmx_copy_value`
like any child value: a retained profile or a kernel terminal (OP, ROLE, PRIMITIVE record,
Message record) keeps its address; a Structure is copied through the same map (an alias is one
copy, a cycle ends at the map, its lexical parents are copied as for any reached Structure); a
value the source arena's range index does not classify is refused
(`LMX_GRAPH_COPY_UNSUPPORTED`) exactly as a direct child slot is. Header comment:
`lmx_graph_copy_owned.h.lm1`. No walker or translator change: the walker already stores
references into pointer cells (`lmx_walk.lm1`, work-list kind 2), and merge
(`lmx_merge_owned.lm1`), child Message creation (`lmx_child.lm1:45`) and the T7 part copies
all go through this copier.

## Pins moved from the withdrawn rule to the author's

- `dev/l2src_sandbox/tests/lmx_copy_ptr_share_selftest.lm1`: the copied pointee is a distinct
  STRUCT of the destination arena holding the copied int (77); two pointer cells at one
  pointee give one copy; the source is untouched.
- `dev/l2src_sandbox/tests/lmx_copy_msg_terminal_selftest.lm1` Case B: the pointee letter is
  copied, its slot 0 still names the SAME Message (terminal), its payload is a fresh copy. New
  Case C: a pointee of another arena that the source index does not classify is refused.
- Harness fixtures `unit_local_reference_model_copy_after`, `unit_local_reference_model_copy_deep`,
  `unit_reference_model_copy_source_container` and their `_walk` twins asserted that `copy\ref`
  still named the SOURCE's member and that a write through the copied reference reached the
  source. Now `copy\ref` names the copy's own member, the write stays inside the copy, the
  source keeps its values, and an explicit rebinding to the source still reaches it. Exit codes
  (7) and the method counts of the harness rows are unchanged.
- `unit_reference_model_copy_field_forward` (and `_walk`), found by the focused run: `first\ref`
  rebound to a root-level `Candidate` outside the operand, then `second: merge: first` asserted that
  `second\ref` was Candidate itself and that a write through it reached Candidate. Now the copy
  carries its own copy of Candidate (the author: shared mutable data is a prototype initialized
  through arguments, or a Message), the write stays in the copy, and `@ s\x != @ Candidate\x`.

## Message/Thread identity

A Message record is a copier terminal whenever the source arena's range index classifies it,
locally or by import: a letter whose slot 0 names a Message keeps that Message (Case B above).
Watch item, not a witness: a pointer cell whose pointee the source index does not classify (the
shape of a letter's sender cell pointing at the host's Message when the letter arena imports
nothing) was shared blindly before and is refused now, as a direct child in that position
always was. No gate path reached it: not the kernel self-tests, not L3, not the 761 + 9 + 182 focused harness targets.

## Evidence

- `build/l2src/fable_fullcopy_kernel_01`: 298 targets, 1 failed, the failure being
  `lmx_copy_msg_terminal_selftest` Case B, the withdrawn pin (the copier is unchanged since).
- `build/l2src/fable_fullcopy_kernel_02`: GREEN, 298 targets, 0 failed (lmx_copy_msg_terminal_selftest 34 checks).
- `build/l3/fable_fullcopy_l3_01`: all 11 suites ok, type budget 78/128.
- `build/l2_harness/fable_fullcopy_focus_01` (focused, 758 merge/copy/child/mail fixtures): 761 targets, 18 failed; re-runs `fable_fullcopy_focus_02` (the six OK->FAIL rows: 9 targets, 0 failed) and `fable_fullcopy_focus_03` (179 fixtures outside the first set that merge and hold reference fields: 182 targets, 7 failed, all seven pre-existing translator refusals with unchanged details: `unit_capture_struct_whole`, `unit_ns2_ref_capture` and `_walk`, `unit_s6_own_fn_capture_value` and `_walk`, `unit_held_definition_free_name`, `unit_callable_formal_unfollowed_actual`; FAIL->OK 0, OK->FAIL 0).
  Compared by fixture identity and outcome with `codex_interpreter_throw_full_02`: FAIL->OK 0; STILL FAIL 12 with unchanged details (`unit_letter_alias_before`, `unit_output_named_receive_address` and `_walk`, `unit_output_receive_address_method` and `_walk`, `unit_capture_struct_merge_two`, `unit_k03_merge_op_anon_typed` and `_walk`, `unit_t7_host_nested_return`, `unit_copy_call_addressed`, `unit_copy_call_from_method`, `unit_copy_call_other_owner`); OK->FAIL 6: `unit_reference_model_copy_field_forward` and `_walk`, the fourth pin of the shared pointee, rewritten and green in `fable_fullcopy_focus_02`; `unit_qualified_pointer_write`, `unit_qualified_alias_write` and their `_walk` twins, byte-identical program output (exit 3, `lmx: walk error: INVALID`), red only by the host's rendering of stderr in the log (HARNESS-X1-HOST-RENDERING, fixed in `tools/l2_harness.ps1`), green in `fable_fullcopy_focus_02`. Merge-timing probes with reference fields (k = 4, 6, 8 kept merges, 25 and 50 merges in a loop, a chain whose reference names a 32-field root sibling) run in the same time on the old and the new copier (within 0.05 s on every probe).
- `python tools/check_docs.py` and `git diff --check`: clean.
- The full harness replay (slices A, B and this step) is still pending: the host stopped the
  slice-A full run for memory pressure, and a full run starts again only when the user asks.

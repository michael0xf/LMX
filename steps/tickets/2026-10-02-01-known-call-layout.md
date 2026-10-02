# 2026-10-02-01 — known call keeps a lowered protocol layout

Status: OPEN. Sub-ticket of [critical_graph_bug](critical_graph_bug.md) §2.3.
The parent ticket stays open. This slice does not close it and does not start
[critical_pointer_to_struct_bug](critical_pointer_to_struct_bug.md).

## Norm

The source application is recoverable from the retained graph. For

```text
sub: A (int: x)
    return
int: b 5
A: b
```

the call is the source application: head `A`, body the occurrence `b`.
It is not a protocol record that repeats the callee and hides `b` in a contract shell.
Parent ticket §2.3. Witness file: `dev/l2src_sandbox/tests/graph_shape_call.lm2`.

## Where it is today

`l2_rw_call` in `dev/l2src_sandbox/l2trans.lm1` builds `LMX_WALK_OP_CALL` as
`[call, code, data, rtype, args...]`. The comment there records the 2026-09-28
choice that code and data are both the callee occurrence, `(M, M)`.
`lmx_walk_call` in `dev/l2src_sandbox/lmx_walk.lm1` requires that layout:
slot 1 is the callee, slot 2 is evaluated as the data occurrence, slot 3 is
the contract (`inputs`, `returns`), slot 4 is the catch count.

Measured on `graph_shape_call` (`regress_ns_31`, native and walked exit 5,
39 checks). `fn: A (int: x) int` returns `x`, and `exit_code: (A: b)` after
`int: b 5` exits 5. The shape fact is `int SET pub call OWN endcall endpub RET struct`.
`pub`/`endpub` open the publish; `call`/`endcall` open the call. The argument
is found by role.

A direct call stores the callee once, at slot 1, and does not store a contract
shell on the call. The contract is the method occurrence's last child, past
the body. `EXEC` still keeps its contract on the call and still evaluates slot 2.

An int own is a source-use leaf, not an `OWN` frame. Replacing the leaf with
`b`'s declaration cell made the value 0: that cell stays 0 after `int: b 5`
until publication, and the live value is the activation work row. That
replacement stays reverted. The call is still a `CALL`. Its contract still
hangs on the method, past the body. It is not yet only the source application.

`regress_ns_32`: the seven shape witnesses stayed green, native and walked.
`unit_make_adder` still fails only the baseline needle `c.LMX_WALK_OP_AT, 3U)`.

Codex `DS-CODEX-005` (`GROK-DS-CODEX-005-ANSWER-20261002-01`): the source
argument is the resolved use of binding `b`, not the number 5 and not a
snapshot of the declaration cell. `OWN` does not hold 5; evaluation loads the
activation work row. Holder, slot, and helper nodes must not replace that use
as source children. This is a general operand representation for owns, formals,
and repeated uses, not a call-only patch. No new permanent representation
without reporting the minimal change first.

Codex `GROK-DS-CODEX-005-REPRESENTATION-20261002-02`: there is no existing
runtime field for a source spelling. `Lmx` has array, parent, and native.
`LmxOp` has code. `l2_rw_spell` stores text as an ordinary graph child, so
adding `spell b` onto `OWN` does not repair the layout. A general
source-occurrence facility is already required. The spelling may be diagnostic
metadata outside the operand child list. Execution stays bound to the resolved
identity, not to the spelling.

Correction from Codex `GROK-DS-CODEX-005-LAYOUT-CORRECTION-20261002-03`.
`lmx_walk_store_size` allocates a `size_t` cell and stores it at `child[2]`.
That is a graph child. `code.array.size` stays the child count. A null holder
at `child[1]` is still a child slot. `lmx_walk_work_find` searches by the
physical slot address, not by a numeric work-row index. Renaming `OWN` to
`USE` leaves those children in place. Ordinary formals are `ARG` width 4:
formal index at `child[1]`, input witness at `child[3]`; evaluation reads
`f.args`, not the own-work row.

Record, emitted for an int own. One source-use leaf per use. The leaf is
not an `Lmx` Structure and has no synthetic children. It is the parent's one
source child. Beside it, arena-owned and freed with the graph:

- `kind`: own-place or formal. The two selectors stay distinct.
- own-place: the holder identity and child index that `lmx_walk_work_cell`
  already uses, resolved against the current activation. Not a stored
  `LmxWalkWork` pointer and not a global row number.
- formal: the formal index that `ARG` already uses, read from `f.args`.
- `spell`: diagnostic only. Execution never reads it.

- Bare own `b`: one leaf, own-place selector of `b`. Not the declaration cell.
- Formal `x`: one leaf, formal selector of `x`. Not an own-place read.
- Literal 5: a `LIT` whose payload is 5. Not a use leaf.
- Two uses of `b`: two leaves, one live binding, two spelling records.
  The value is not copied into either leaf.

Codex `GROK-DS-CODEX-005-LAYOUT2-PROCEED-20261002-04`: this direction may be
implemented. Formal index alone does not keep `ARG`'s witness or the hidden
default. Preparation must discover use leaves the way it discovers `OWN`.
Copy and re-entry must remap the record onto the new activation. Spelling
stays diagnostic. Renaming `OWN` or hiding its children in the decoder does
not close the parent.

Working tree, not committed. `LmxUseLeaf` is in
`dev/l2src_sandbox/lmx.h.lm1` (`selector`, `index`, `ty`, `spell`). It is not
an `Lmx` and it is not a child list. Selector 1 names the own-place: holder
is the current activation, index is the child `lmx_walk_work_cell` already
uses. `spell` is diagnostic. The walker never reads it. Copy keeps selector,
index, and `ty`, and leaves `spell` null. Hosted owns stay `OWN_OF`. Other
non-int owns stay `OWN`. Formals stay `ARG`.

`lmx_walk_actuals` evaluates a use leaf. A role of `NONE` is not a raw cell:
the leaf's type is not a number, and that load returned `INVALID`
(`regress_ns_34`). Actuals are still read before `lmx_walk_publish`.

Measured. `regress_ns_37`, `graph_shape_call`: shape
`int SET pub call use b endcall endpub RET struct`, Entry 5. Native: 33
checks, driver exit 0. Walked root: 37 checks, driver exit 0. The launch
exit is 5 in both. `regress_ns_35` was the same exit with a bare `use` and
no binding name. `regress_ns_36` failed gcc because a cast stood on the left
of the spell store; that directory is not reused. `regress_ns_38`: the seven
shape witnesses stayed green, native and walked, 10 targets.
`regress_ns_39`: `unit_make_adder` fails only the baseline debt
`c.LMX_WALK_OP_AT, 3U)`.

`@` of an int own takes the leaf's cell. Reading the leaf as an `Lmx` aborted
the walk (`-1073741819`). `regress_ns_40` and `regress_ns_41` are green on
those walks, and `graph_shape_call` still exits 5.

`critical_graph_bug_full_06` was RED 76 of 1159: the abort, plus pins that
still required the callee twice and an `OWN` frame for an int own.
`critical_graph_bug_full_07` is RED 36 of 1159. Those 36 texts are the same
as `critical_graph_bug_full_05`. The harness now reads a direct call's
contract from the callee and accepts a use leaf where an `OWN` pin names the
same index. The call is still a `CALL`. This slice stays open: `build_l2src`
and `run_l3_selftest` have not been re-run on this tree, and the translator
is not committed. The parent stays open.

## Do

One representation. The call's retained children are the source head and the
source argument body, in that order. Native execution and the walker consume
that graph or ordinary compiler metadata. They do not keep a second persistent
graph, and they do not keep the `(M, M)` plus contract shell as the only
recoverable form.

Do not give an ordinary named Structure formal arguments. A known callable
head stays a call; unknown `A: b` stays the Structure already witnessed by
`graph_shape_known_atom`.

## Done when

A shape witness reads the call's own body and identifies the argument as a
source use of binding `b`, distinct from the literal 5, without `l2_rwN` names
or old slot numbers. `graph_shape_call` exits 5 native and walked, with the
same checkpoint semantics: actuals are read before publication, and the
declaration cell may still be 0. `OWN` as an opcode is not that witness.
`l2_harness` does not grow failures beyond the baseline 36.
`build_l2src`, `run_l3_selftest`, and `check_docs` pass. Then this file gets
`DONE <sha> <UTC>`. The parent ticket gets its own `DONE` only after its
remaining acceptance, including this slice.

TAKEN main@9ac7d849 2026-10-02 13:03 UTC

Дальше — продолжать `next_core_tasks_v2.md`.

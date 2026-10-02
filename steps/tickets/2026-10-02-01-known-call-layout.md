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

Measured on `graph_shape_call` (`regress_ns_29`, native and walked exit 0,
41 checks). A direct call stores the callee once, at slot 1, and no longer
stores a contract shell on the call. The contract is the method occurrence's
last child, past the body; `lmx_walk_call` reads it from there. `EXEC` still
keeps its contract on the call and still evaluates slot 2.

The shape fact `call OWN endcall` finds the argument by role. That argument
is still an `OWN`. Replacing it with `b`'s declaration cell made the program
exit 0 when the initializer was 5: the cell was still 0, and the live value
is the `OWN`. That replacement was reverted. The call is not yet only the
source application.

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

A shape witness reads the call's own body and finds the argument occurrence,
without `l2_rwN` names or old slot numbers. `graph_shape_call` still exits 0
native and walked. `l2_harness` does not grow failures beyond the baseline 36.
`build_l2src`, `run_l3_selftest`, and `check_docs` pass. Then this file gets
`DONE <sha> <UTC>`. The parent ticket gets its own `DONE` only after its
remaining acceptance, including this slice.

TAKEN main@9ac7d849 2026-10-02 13:03 UTC

Дальше — продолжать `next_core_tasks_v2.md`.

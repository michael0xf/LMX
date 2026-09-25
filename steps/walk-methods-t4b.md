# T4b: widening the walkable subset of method bodies, one class at a time (Opus)

Ticket: fable's answer, `steps/tickets-20260925.md` §9 («затем T4b»); `opus_next.md` queue 1;
`steps/merge-parts-193.md` §9 (T4a).  Branch `claude/continue-opus-next-doc-rvjocj`, base main `adfa690`.

## k.1 The measure (main `adfa690`)

A private l2trans that prints why `l2_rw_may` refuses a method, run with `--walk-methods` over the
tracked `dev/l2src_sandbox/tests/*.lm2`.  Count = fixtures in which the reason occurs (each reason
once per fixture):

| Reason (`l2_rw_may`) | Fixtures |
|---|---|
| walkable (frames emitted) | 130 |
| throws (declared or implicit, the throw channel) | 51 |
| a formal that is not a number | 25 |
| a result that is not a number | 15 |
| a Structure formal (`T: m`, and since D-76 `@: T m`) | 14 |
| formal binding (an own field named like a formal) | 14 |
| an own field declared in a nested body | 10 |
| dynamic inputs | 6 |
| a callable formal | 5 |

Body refusals (the builder's own «root operation not walkable yet: …» under quiet tries) come after
these shape refusals and are measured per class as it opens.

## Order (one class per step, each with the differential run)

1. **Structure formals.**  A Structure formal j is ARG j, the reference the caller passed; `m\x` is
   OF(ARG j, slot of x in T) as a path root of its own (the D-76 formal root, walked), a write is
   PUT_OF.  The caller passes the Structure as its actual (`l2_rw_struct_arg`).  Rows: the 14
   fixtures' methods under the knob.
2. **Formal binding** (own field named like a formal, -189 c3b-2): the formal's first store binds its
   own field; in the walk a PUT of ARG j into the own slot at the binding line, then the own field.
3. **Own fields in nested bodies** (a hosted own field).
4. Throws and callable formals wait for CATCH (-201) and the callable parts (T5).

Each step: the knob-on differential run over every eternal-runs row (the rows' facts must hold
walked), the corpus diff (knob off: no output change; knob on: only the class's methods gain frames),
a mutant per rule, RESULT, merge into main.

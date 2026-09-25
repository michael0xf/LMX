# D-53: `@mo` on an own Structure field

Ticket: `steps/tickets-20260925.md` §2 (fable's reformulation in `steps/defects.md` D-53).  Branch
`claude/continue-opus-next-doc-rvjocj`, base main `e4fdb62`.

## Plan

- `l2_own_addr` (`l2trans.lm1` :6181): a branch for the slot.  An own Structure field is a slot that
  holds the Structure itself (-189 c3b-3), so `@mo` is the slot's value,
  `(cast: (@: Model) l2_q%d_from[0])` -- what `l2_own_load` already gives the slot.
- Its two callers in `l2_eval_fields` / `l2_prep` refuse a failed `l2_own_addr` with their own located
  text, not «expression too long» (the buffer-overflow branch) or a bare `return: 1`.
- Witness: `unit_ns_ref_field_general` gets the `h\q: @mo` round-trip, with an independent route to
  mo (`h\q != mo`, mo's own load) so that a wrong `@mo` is told apart; success 7; inverted check.

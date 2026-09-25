# -170, the translator half: arrays at the walked root (Opus)

Ticket: fable's answer, `steps/tickets-20260925.md` §6 («затем -170 трансляторная половина», plan
`steps/root-arrays-170.md` §6).  Branch `claude/continue-opus-next-doc-rvjocj`, base main `6b631a6`.

## Plan

The kernel roles on main (grok_bot -170 c2, `lmx_walk.lm1` :1603-:1711): ELEM `[elem, holder, slot,
index]`, ELEMPUT `[elemput, holder, slot, index, value]`, LENGTH `[length, holder, slot]`.  The
holder is a Structure by reference or 0 (this activation's data, K-OT2), NOT evaluated
(`lmx_walk_array_desc` :548); the index is a literal size cell, not evaluated.

- 5a, an own Array of the body (5 rows): `[]: T x n` is no step (the graph build makes the
  descriptor in the field's slot); `x[N]: v` → ELEMPUT(0, slot, N, v); `x[N]` → ELEM(0, slot, N).
- 5b, `length(m\mainArgs)` and `m\mainArgs[1][0]` (5 rows): the Array is a field of a Structure that
  exists only in R0's turn (m's pointee), or an element of another Array.  The roles take neither: a
  QUESTION below.

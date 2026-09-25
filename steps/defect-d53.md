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

## RESULT

Base main `e4fdb62`; STARTED `93c35bf`.

### l2trans.lm1

- `l2_own_addr`: the slot branch.  For an own Structure field (`l2_own_is_slot`) `@mo` is
  `(cast: (@: Lmx) l2_q%d_from[0])` -- the reference the slot holds, the same spelling
  `l2_own_load` gives the slot's value.  A pointer field's cell keeps its branch (the address of its
  pointer).
- The two callers now refuse a failed `l2_own_addr` with the located text «this field has no address
  to take», at the field's own atom: `l2_eval_fields` (the `@name` of a direct field; it was «expression
  too long», the buffer branch) and `l2_prep`'s `l2_addr_tail` branch (it was a bare `return: 1`, so
  the caller's `atom=@` detail with no message).  After the slot branch no fixture reaches this refusal
  (probed: an own array, an own `@: char`, a `char: []:` take other paths); mutant D53b below reaches it.

### Row

`unit_ns_ref_field_general` (eternal-runs): `Entry = 7` (it was the default 0 -- an empty witness by
`steps/current.md`'s rule).  The fixture gets the q round-trip: `Model: mo`, `h\q: @mo`, then
`h\q = 0` → 4, `h\q != @mo` → 5, `h\q != mo` → 6 (mo's own load, an independent route to the same
Structure), success 7.  The comment about a double indirection is gone.  Main `e4fdb62`: l2trans refuses
the fixture («expression too long», `atom=@`).  Inverted check (`entry 0`): red.

Generated L1 (the store into h\q and the two comparisons):

```text
    if: lmx_pointer_store_known(l2_pxp[0], (cast: (@: void) (cast: (@: Lmx) l2_q2_from[0]))) != 0
    ...
    @@: Lmx l2_t9
    l2_t9: (cast: (@@: Lmx) lmx_pointer_value_known(l2_xp[0]))
    if: l2_t9 != (cast: (@: Lmx) l2_q2_from[0])
    ...
    @@: Lmx l2_t11
    l2_t11: (cast: (@@: Lmx) lmx_pointer_value_known(l2_xp[0]))
    if: l2_t11 != (cast: (@: Lmx) l2_q2_from[0])
```

The read temp of `h\q` is `@@: Lmx`, one level deeper than the value it holds: gcc warns «comparison of
distinct pointer types» twice (not an error under the harness flags).  That is D-76, below.

### Mutants (private l2trans variants, run on the row)

| Mutant | What is mutated | Result |
|---|---|---|
| D53a | the slot branch gives the ADDRESS of the slot cell (`l2_q%d_from`, the old «double indirection») | red: exit 6 (`h\q != mo`) -- the round-trip alone (`h\q != @mo`) would not have caught it |
| D53b | the slot branch removed | red: l2trans refuses at 33:11 «this field has no address to take» (`atom=mo`) |

### Numbers (cloud)

- `python tools/build_l2src.py`: 174/230 (as main; red only the `<windows.h>` closure).
- `python tools/check_docs.py`: OK; `git diff --check`: clean.
- Corpus, the 644 tracked `.lm2` of the sandbox through main `e4fdb62`'s l2trans and this one: one
  outcome change, `unit_ns_ref_field_general` (refused → translated); no other output differs.
- Under the private `windows.h` shim (not in the repo, see `steps/root-merge-199.md`): harness 394/394.
  Evidence only; the machine gate decides.

### Found here: D-76 (OPEN, mine)

A field read THROUGH a `@: T` reference to a named Structure is not lowered: a local `@: Model r` is
declared `@@: Lmx r` and `r\value` goes to L1 as it is (gcc: «'r' is a pointer to pointer»); the same for
a formal `fn: peek (@: Model m) size_t` / `return: m\value` and for the reference field `h\q\value`.  No
row runs any of it.  It is not D-53 (`@mo` itself is right, measured by D53a), and it is not small: the
C type of `@: T` for a named Structure is one level too deep in locals, formals and read temps, and a
path through such a reference has no lowering.  Row in `steps/defects.md`; I take it as the next
translator item unless fable orders otherwise.

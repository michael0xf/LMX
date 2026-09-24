# FABLE-SONNET-SEND-REF-20260925-172 commit 1: the general reference field

Base: origin/main after FABLE-OPUS-MAINARGS-SENDER-20260925-173 (071f82e/4bcfbab),
rebased cleanly (fast-forward, no conflicts). -173 confirmed the letter shape: a
letter's graph is `(sender: @: LmxMsg; payload)`, field 0 the sender's Message,
field 1 the payload Structure -- matching author's rule K3=a.

## Design: the shared kernel-word helper (D-## fold, per -162 discipline)

Measured (read-only, before -173 landed) that `l2_ptr_type_word` (`l2trans.lm1`,
the -162 fold's own shared pointer-word table) does NOT itself recognize any
kernel type (LmxMsg etc.) -- code 29 for LmxMsg existed in two separate,
redundant inline tables, both gated to the CONST-qualified spelling only:
`l2_const_local_ty` (locals) and `l2_typed_formal`'s const branch (formals).
The plain (non-const) `@: LmxMsg x` spelling is admitted by NEITHER formals
nor locals today -- `l2_ptr_local_ty` is a pure forward to `l2_ptr_type_word`
(no fallback), and `l2_typed_formal`'s plain `@` branch falls to
`l2_resolve_type_atom`, which recognizes only "Lmx", a named Structure, or a
c-door name -- "LmxMsg" is none of these. Confirmed this stays unsupported in
commit 1 (fable's own fallback: don't admit a spelling that isn't admitted
today).

Factored the two redundant inline tables into one new function,
`l2_kernel_ptr_word` (l2trans.lm1, next to `l2_ptr_type_word`): the five
words, depth 1 only (none has a depth-2 spelling anywhere), codes unchanged
(char=3, LmxMsgRuntime/LmxRoot=28, LmxMsg=29, LmxMsgCopy=30, L2ImmutQuery=6,
with L2ImmutQuery's `l2_need_query: 1` side effect kept inside the helper
since it's a property of using that type, not of the call site). Both
existing callers now call it instead of repeating the list. One wrinkle
flagged, not touched: LmxMsgCopy has a THIRD, different code (31) in
`l2_typed_formal`'s separate plain-`@@` branch, out of scope for this fold
(that branch isn't one of the two duplicated const-tables).

Witness for the fold itself: l2_harness stayed GREEN across the change
(338 -> no regressions before the new field-kind fixture was added), and
`build_l2src` (which recompiles l2trans.lm1 itself via l1trans) stayed GREEN
256/256 throughout -- the two existing callers' generated output is
unaffected for every tracked input (neither call site's observable inputs
exercise a word the fold didn't already recognize).

## The general reference field: `@: T name` / `@@: T name` in `l2_take_ns_body`

Per the author's rule (`@` of any depth is a declaration receiver in L3, and
a named Structure is L3 too) and fable's explicit correction: NOT a
Message-only kind. `l2_take_ns_body` (the named-Structure field parser) had
no `@`/`@@` branch at all -- such a field fell through to the `Name: field`
catch-all (a reference to ANOTHER named Structure, exactly one body item),
which refused a 2-item `@` frame ("a Structure reference field needs a
name").

New branch, inserted before that catch-all, guarded by
`l2_address_depth(fld\as\frame\head) != 0`: takes the type atom and the name
atom, resolves the type via the SAME 3-tier ladder a formal/local pointer
already uses -- `l2_ptr_type_word` (six core words, either depth) first,
`l2_kernel_ptr_word` at depth 1 only, `l2_resolve_type_atom` last (Lmx, a
named Structure via `l2_ns_find`, or a c-door name) -- and pushes a NEW field
kind: 10 for depth 1, 11 for depth 2 (0-9 were all taken). The resolved
pointee code goes into `l2_nsf_ref` (not `l2_nsf_val`, which the numeric
kinds use for their literal) so `l2_path_kind`'s existing per-kind `ent`
plumbing can carry it to a reader without a new out-parameter -- kind 4
(callable) already reuses `out_mi` for exactly this purpose, so kind 10/11
does too (`l2_path_kind`, one new `if:` block).

## Wiring the field into read/write, not just declaration

Building a witness (`unit_ns_ref_field_general.lm2`: `Holder: @: int p /
@: Model q`) exposed that DECLARING the field is not enough for it to do
anything -- three more sites, all discovered by testing, not by reading
ahead:

1. **Terminal-leaf allowlists.** Both `l2_field_path_check` (the read-side
   gate) and the inline terminal check inside `l2_emit_path_to` (shared by
   read and write) hard-coded the primitive kinds only (0,1,7,8,9, plus 4 in
   `l2_emit_path_to` for callable). Widened both to also admit 10 and 11.
2. **The read side's C type.** `l2_field_path_read` picks the loaded C type
   via `l2_kind_cell_ty(kind)`, a pure kind->type table -- but a reference
   field's pointee varies PER FIELD, not per kind, so that table can't carry
   it. Fixed by re-deriving the field's `ent` (the pointee code, via the
   `l2_path_kind` out_mi plumbing above) when kind is 10/11, then converting
   it to an own-storage pointer code with `l2_own_ty_of_param` (the file's
   own established formal-code -> own-storage-code bridge, `1000 + raw` for
   any pointer code) before handing it to `l2_emit_cell_load`, which already
   has a generic `l2_own_is_pointer`-gated branch for exactly this shape.
3. **The write side.** The colon-assignment-to-a-field-path emitter
   (`l2_emit_body`'s field-path branch) had explicit per-kind store calls for
   0/1/7/8/9 and nothing else. Added one more: `lmx_pointer_store_known` for
   kind 10/11, using the ordinary `l2_eval_fields`-evaluated RHS token (a
   reference field is never a literal RHS -- `l2_path_rhs` doesn't recognize
   one for this kind, so only the token path applies).

## The bug that was actually blocking the witness (not in 1-3 above)

With 1-3 in place the witness still aborted, every time, on any read OR
write through the new field: `lmx: invariant: a field path met no
Structure`. Bisected with a temporary debug print inside `l2_emit_path_to`
(removed before landing) that showed the parent Structure's own address
(`l2_pst`) was valid and IDENTICAL across every access -- an existing-kind
sibling field in the same instance, at a different slot, read and wrote
correctly with that same address; the very next call, same address, slot 0
(the kind-10 field) failed. Ruled out via control fixtures: not slot 0 vs 1
(an ordinary field at slot 0 works), not literal vs non-literal RHS, not
Holder's overall shape or field count, not q/LmxMsg specifically (reproduces
with `@: int p` alone).

fable's read (confirmed correct): a named Structure's PROTOTYPE construction
(`l2trans.lm1`'s per-kind loop building `l2_nsp[k]`'s own fields, one arm per
kind -- char gets `lmx_char_cell_known`, an array gets `lmx_array_new_owned`,
kind 3 deliberately gets nothing there since it's materialized later by its
own merge step) had NO arm for kind 10/11, so the slot stayed the arena's raw
zeroed child -- never `lmx_value_allocate_owned`'d into a real cell. Such a
slot is not something `lmx_pointer_store_known`/`_value_known` (or the
kernel's merge/copy machinery, which is what `Holder: h` -- an ordinary
typed declaration -- goes through, `merge(Holder, empty)`) can treat as a
live value cell.

Fixed by adding the missing arm, in both the ordinary and the
profiled/eternal cases, using the SAME allocator the walked root's own
graph-typed own fields and a formal's/local's own pointer locals already use
elsewhere in this file: `lmx_pointer_new_owned(c.LMX_TYPE_POINTER_BASE + <raw
pointee code>, l2_program_arena)` for the ordinary case,
`lmx_arena_take_profiled(..., c.LMX_TYPE_POINTER_BASE + <code>, l2_eprofile%u)`
for the profiled one (mirroring kind 1's own two arms).

## Mutation witness

Reverted just the new prototype-construction arms (both, via scratchpad
backup/restore -- confirmed byte-identical after restore); harness RED,
`unit_ns_ref_field_general` fails with the exact original abort. Restored;
harness GREEN again, 339/339.

## What the witness actually proves, and what it leaves out

`unit_ns_ref_field_general.lm2`: `Holder` declares `@: int p` (a core word)
and `@: Model q` (another named Structure) -- both ADMITTED at declaration.
`p` round-trips a live address at runtime: assigned from a stable `@: int`
local, read back non-null and pointer-identical to the address taken.

`q`'s own runtime round-trip is NOT exercised, deliberately: taking the
address of a Structure-typed OWN FIELD (`@mo` for a bare `Model: mo`) hits a
SEPARATE, pre-existing bug -- `l2_eval_fields`'s naive `"@ " + token`
emission (used for a bare `@x` operand, `l2_addr_tail`) takes the address of
the working-copy POINTER VARIABLE itself instead of using its value, a
double-indirection. This is unrelated to this ticket's field-kind work (it
is about the pre-existing `@`-address-of mechanism for ANY Structure-typed
own field, kind 10/11 or not) and was never caught before because the one
prior fixture combining a Structure-typed own field with a bare `@` address
(`unit_field_path_unit_addr.lm2`) is root-level and root-pending -- never
actually executed. Not fixed here; reported to fable separately for a scope
decision. `Holder\q` is exercised for declaration only until that lands.

## Gates

l2_harness GREEN 339/339 (338 + this ticket's new fixture), `build_l2src -Run`
GREEN 256/256 (kernel selftests included, all exit 0 or the one documented
expected-fatal), L3 selftest 11/11 suites + type budget OK (4 units),
check_docs OK, `git diff --check` clean.

## Still open for -172

Part (2) (`m\sender`/`m\payload\mainArgs` reads via a synthesized letter
model at the receive site) and part (3) (`sendMessage: Ref X`) per fable's
design message -- not started; commit 1 was this field-branch/helper/runtime
plumbing alone.

# FABLE-SONNET-SEND-IN-METHODS-20260925-168 commit 1: measure-first

Base `540c7fe`. Opus's -159 c2b left `sendMessage: X` inside a method body as a located refusal
(`l2trans.lm1` :14002 area, `"sendMessage is built in the root only yet"`) -- only the root's
walker step exists.

## What `l2_send<k>` builds (`l2_emit_send`, `:16787`)

Generated once per root `sendMessage: X` site, in the **prim-ABI signature** every other kernel
primitive and trampoline already uses:
```
fn: l2_send<k> (@: void owner; @@: void refs; size_t: nargs; @: void dest; @@: void out) int
```
`owner` and `dest`/`out` are UNUSED by this specific prim (send is a statement, not a value-
producing call) -- confirmed by direct read, nothing in the body references them. Body, in order:

1. `t: lmx_thread_current()` -- the CURRENT thread, whichever one is running. Not root-specific;
   this is already a dynamic, per-call lookup.
2. `nargs != <ni>U` refused (`ni` = the number of INT-typed fields the site has; TEXT fields are
   NOT runtime arguments at all -- see below).
3. A fresh arena (`calloc` + `lmx_arena_open`), a letter `m`, its graph `g` (2 fields), and the
   payload Structure `p` (`nf` fields, one per message field in source order).
4. Per field, in declaration order: an INT field takes its value from `refs[ni]` via
   `lmx_int_value_known(refs[ni])` (`:198`-`:202` in lmx_value_owned.lm1: just `*(int*)cell` --
   `refs[i]` only needs to be the ADDRESS of a plain C int, no boxing/arena cell required) and
   stores it into a fresh `lmx_int_new_owned` cell at `p`'s slot; a TEXT field is a **compile-time
   literal**, baked directly into the generated function body (`memcpy(text\data, "...", len)`) --
   never a runtime argument, so it does not count toward `nargs`/`ni` at all.
5. `g`'s field 0 = `lmx_thread_message(t)` (the CURRENT thread's own Message -- the sender
   reference); field 1 = `p` (the payload).
6. `lmx_service_post(lmx_child_service(t), lmx_thread_parent(t), m, a)` -- posts to the CURRENT
   thread's PARENT. Also not root-specific: `lmx_thread_parent(t)` resolves per-thread, always.

**Conclusion: `l2_emit_send`/`l2_send<k>` needs NO changes to be called from a method body.**
Every part of it is already a dynamic, per-call lookup (current thread, its parent, its own
message) with no assumption that the caller is the root. The prim-ABI signature is the SAME shape
`lmx_call_prim`'s trampolines already use for a native method call from the walker.

## How a method body can reuse it (a direct native call, not `lmx_call_prim`)

The target (`l2_send<k>`, a specific generated C function) is known at TRANSLATION time for a
method-body `sendMessage: X` exactly as for a root one -- there is no need for `lmx_call_prim`'s
dynamic callable-graph lookup (that machinery exists for when the callee is not known until run
time, e.g. a callable formal). A native call site can call `l2_send<k>(...)` directly, C-style,
the same way any other generated function is called.

It still has to satisfy the prim-ABI signature, though, which means building a `refs` array of
`void*` even for a direct call -- searched the file for an existing native emission site that
already does this (`grep -n 'refs\[0\]:'`, and broader) and found none: every EXISTING native
call site uses the DIRECT, TYPED trampoline signature (`l2_m1(node, self, arg0, arg1, ...)`), not
the boxed prim-ABI convention -- only the walker (`lmx_walk_prim`, scratch-arena-backed) and
dynamic dispatch (`lmx_call0`/`lmx_call_prim`, for a callable formal) build a `refs[]` array
today. This is new ground for native emission, but simple: given `lmx_int_value_known`'s trivial
cast-and-deref (`:198` above), each int-typed field just needs a local `int:` temp holding its
evaluated expression, and `refs[i]: @ that_temp` -- no arena, no boxing. Plan for commit 2:
1. Emit `int: l2_sfN <expr>` for each INT field of `X`, evaluated the ordinary way
   (`l2_eval_fields`, matching how any other native call's actual argument gets evaluated).
2. `c.array: [ni]: void l2_send_refs` (or an equivalent local buffer), `l2_send_refs[i]: @ l2_sfN`
   for each.
3. Call `l2_send<k>(0, l2_send_refs, <ni>U, 0, 0)` directly (owner/dest/out unused, per above).
4. A nonzero status is the SAME invariant-failure shape the root's own walker step treats a
   failed send as (X1 route) -- `l2_rw_send`'s own generated code has no separate recoverable-
   failure path for this prim either; mirror that, not invent a new one.

The FIELD PARSING/VALIDATION half of `l2_rw_send` (`:16677`-`:16759`, the shape checks: one
Structure `Name(f: v; ...)`, fields are `name: literal-or-int-expr`, at most 16 fields, a text
field must be a quoted literal with no escape) is REUSABLE as-is for a method-body site too --
it does not touch the walker-op-tree emission (`l2_rw_frame`/`l2_rw_put`) until after the shape is
already validated and `k` assigned. Commit 2 needs a method-body-specific EMISSION tail (the four
steps above) in place of `l2_rw_send`'s walker-graph tail, sharing the same parse/count logic and
the same `l2_emit_send` generator -- one path for both, as the ticket asks, not a twin.

## `sendMessage: Ref X`: measured, the reference value does not exist yet, anywhere

`l2_rw_send` itself already refuses the 2-argument form UNCONDITIONALLY, even at root
(`:16692`-`:16693`, `l2_count_active(stmt\as\frame\body) = 2` -> `"sendMessage to a referenced
Message"`) -- this is not a method-body-specific gap, it is not implemented at all yet, matching
`l2_rw_send`'s own header comment: "`sendMessage: Ref X` ... needs a reference value the walker
does not hold yet."

What a received letter's sender field actually is, read today: `receiveMessage: m` binds `m` as
an UNTYPED graph (confirmed directly, and already measured in steps/receive-rename-166.md for
commit 2 there). The letter's graph field 0 (`g`'s field 0` in `l2_emit_send` above, and the
identical shape in the C `main`/root construction) is `lmx_thread_message(t)` -- an `@: LmxMsg`
POINTER, stored via `lmx_arena_ref_store(g, 0U, (cast: (@: void) lmx_thread_message(t)))`: the
EXACT SAME untyped `void*` graph-cell storage an ordinary Structure reference uses. Nothing in
`l2trans.lm1`'s type/kind vocabulary (`l2_own_ty`, `l2_nsf_kind`, every place that maps a "kind"
number to a meaning) has a slot for "this cell holds a Message reference, not a Structure
reference" -- grepped for any mention of `LmxMsg` combined with a kind/type table, found none.
Reading `m\[0]` today, through the ordinary graph-field-reading path (`l2_own_seg_scan`/
`l2_field_path_read`, built for `Lmx` Structure references), would treat that `LmxMsg*` as if it
were an `Lmx*` -- a kind confusion, not a working "reference value".

**This is the missing piece commit 3 needs, and it lives in the kernel/type layer, not just the
translator**: an L2-level way to read a graph cell KNOWING it holds a Message reference (not a
Structure reference), so `m\[0]` can be typed and passed as `sendMessage: Ref X`'s `Ref`. Per the
ticket's own fallback, commit 3 reports this and stops there rather than inventing an ad hoc
reinterpretation of the existing untyped cell.

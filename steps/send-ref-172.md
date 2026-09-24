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

## Commit 2: `receiveMessage: m Model`, the synthesized letter, and D-56

Base: origin/main after commit 1 integrated (4aee8cf).

### The two-name form

`receiveMessage: m Model` types `m` to a synthesized letter model
`{sender: @: LmxMsg; payload: Model}` -- `l2_receive_msg_shape` widened to
accept a 1- or 2-item body (`out_model` new out param, 0 for the 1-item
form), all 7 call sites updated. Synthesis is memoized by payload model
(`l2_letter_ns_for`, a small parallel-array table keyed by model text,
`l2_text_same`) -- two receive sites naming the same Model, or the same
name rebound later, share one synthesized `l2_ns_push` entry: a letter's
shape is a type, not a per-site construction. The synthesized entry's name
is never source-findable (`l2_letter_synth_name`: a leading space, which no
L2 identifier can start with, prepended to the model's own name text, or a
fixed `" receiveMessage"` for the untyped form -- built but unused, see
below).

Wired at both sites `Model: m`'s own colon-decl mechanism already uses:
the early collection pass (`l2_collect_asgn_body`, runs before any
statement is checked) and `l2_check_body`'s own pass -- `l2_own_add` then
`l2_own_nsty_set`, mirroring `l2_colon_decl_shape`'s exact sequence.
`l2_emit_body`'s own binding site needed no change at all: its admission
call (`l2_own_nsty_get(oi) >= 0 && l2_emit_admit(...)`) was already
conditional on the own field actually being typed, so once `l2_own_nsty_set`
runs at check time, the existing admission machinery fires automatically.

**First attempt over-scoped, reverted**: retyping even the BARE
`receiveMessage: m` (no model) broke `unit_admit_letter_formal.lm2` and two
siblings, which rely on the bare form staying untyped -- an untyped graph
value is admissible into WHATEVER typed target it is later bound to or
assigned into; a synthesized type would make it match only itself. Narrowed
so ONLY the two-name form synthesizes; the bare form is byte-for-byte
unchanged from before this ticket. One harness row's expected text updated
(`unit_next_message_one_name.lm2`): `receiveMessage: a b` is now valid
2-name syntax, refusing on `b` not being a declared model
("receiveMessage: unknown payload model"), not on the shape itself
("receiveMessage binds one name" is gone, replaced by "...binds one or two
names").

### D-56: typed admission had never actually run, ever

The witness (`receiveMessage: m MainLetter` inside a method, receiving R0's
own mainArgs letter -- the -168 method-body path, since the walked root's
own `take` primitive doesn't exist yet, Grok -177 later) aborted every time:
`R0 closed ... R0 was stopped`, an uncaught `implements` throw. Bisected
past this ticket's own code entirely -- swapped in the PRE-EXISTING,
untouched mechanism (`MainLetter: m` / bare `receiveMessage: m`, no
synthesis) in the same position: identical failure. Checked every existing
"admit a typed letter" fixture's harness row: every single one is
`root-pending`, never actually executed. Typed receiveMessage admission has
never run in this codebase's history; this witness is the first.

fable's first hypothesis (a stale `l2_program_arena`, the host's instead of
the running Thread's) was measured directly with a temporary debug print at
the admit site and disproven: the two arena addresses printed identical,
and classifying the letter's graph in that arena succeeded (kind != NONE).

Reading `lmx_implements_walk` in full (`lmx_implements.lm1:106-184`) found
the real cause: per field the consumer (the model's own prototype instance)
declares, it compares `lmx_domain_kind` of the incoming value, of `varB`,
and of the consumer's own slot value at that index -- ANY kind mismatch is
NO. Commit 1's D-52 fix gave the prototype's kind-10 sender slot the
address of a freshly `lmx_pointer_new_owned`-allocated cell (`KIND_PRIMITIVE`).
A real letter's sender slot holds the raw `LmxMsg*` address directly, no
wrapper (`lmx_arena_ref_store(letter_graph, 0U, message)`, -173's own code)
-- a different domain. Kind mismatch, refused.

fable's diagnosis (confirmed by re-reading `lmx_implements_walk:135`,
`if: c != 0`): the guard is keyed on the CONSUMER's own slot -- when it is
null, the WHOLE field check (including reading `varA`/`varB`) is skipped,
matching the file's own ":78 an empty uses is true" reasoning. My admission
call passes the same prototype instance for both `varB` and `consumer`, so
the fix is representational, not kernel-side: a kind-10/11 field's slot
should hold the pointee's address DIRECTLY, exactly like kind 3's own
reference field (`lmx_arena_ref_store`/`ref_value`, no cell) -- a pointer
CELL is the representation an own local or root own field's own pointer
value uses (a primitive of the pointer pool the walker PUTs/DEREFs), not
what a Structure field that merely references something needs. With no
cell, the prototype's slot for a reference field simply stays null (matching
kind 3/4's own silence in the same construction loop), so `lmx_implements_walk`
skips it entirely -- admission never compares the sender field's domain at
all, and the bound letter still carries its real sender for `m\sender` to
read afterward (a runtime read of the bound value, independent of the
static admission check).

Revised commit 1's own D-52 fix accordingly:
- **Prototype construction**: the two kind-10/11 arms (ordinary and
  profiled) removed entirely -- no arm at all, like kind 3/4.
- **Write side**: `l2_pxp` is already the slot's own address (the walk gives
  it generically, same as every other kind); the store is now a direct
  `l2_pxp[0]: (cast: (@: void) <token>)`, not `lmx_pointer_store_known`
  (which would treat the slot's contents as ANOTHER pointer to write
  through -- the double indirection D-52's cell representation needed,
  gone now that there is no cell).
- **Read side**: `l2_xp[0]` (== `l2_pxp[0]`, the slot's own contents) is the
  pointee's address directly, one deref; rewritten to bypass
  `l2_emit_cell_load`/`l2_own_ty_of_param` (that path is specifically for a
  separately allocated own-storage pointer cell, the representation this
  kind no longer uses) and instead emit a plain declare-and-cast using
  `l2_emit_raw_pointer_type` directly with the raw pointee code
  `l2_path_kind`'s `out_mi` already carries.

Two L1 syntax traps hit and fixed by testing, not guessing, matching this
project's own established gotcha: (1) a `source level decrease must be one
step` parse error from a multi-level dedent needing an explicit `---`
cutter; (2) a subtler one -- `l2_emit_path_bail`'s own output is only the
BODY of an `if: ... != 0` block (the `if:` line itself is always the
caller's own, emitted separately, one per kind), so a bare assignment with
no `if:` of its own left that body dangling, and l1trans merged the next
two statements into one malformed C expression -- fixed by giving the write
its own (trivially false, no real status to check) `if: 0` line to nest
under, matching the shape every other kind already uses. A third,
independent bug in the SAME area: the read side's declaration line was
missing its leading `fputs(ind, l2_out)` (indentation prefix) before the
type spelling, landing the declaration at column 0 while its own
initializer line stayed indented -- l1trans read the indented line as
nested inside the declaration, merging two statements into one. Both were
found by actually compiling the generated C, not by re-reading the L1
source for reasonableness.

### D-56's mutation witness

Reverted just the prototype-construction removal (restored the D-52-style
`lmx_pointer_new_owned` arm, scratchpad backup/restore, confirmed
byte-identical restore afterward): `unit_receive_letter_model` RED, the
exact same `R0 was stopped` failure; `unit_ns_ref_field_general` (commit 1's
own witness) stayed GREEN even with the mutant, since its write
unconditionally overwrites whatever the prototype's slot held before
copying, never reading it -- correctly isolating that the prototype
representation, not the read/write rewrite, is what D-56 needed.

### Witness

`unit_receive_letter_model.lm2`: `MainLetter` (the existing K6 payload
shape, one field `mainArgs`); a method `check()` does
`receiveMessage: m MainLetter`, receiving R0's own mainArgs letter (the
same one the host posts, per -168's own established "a method called during
R0's turn takes the letter of the current Thread"); asserts `m != 0`,
`m\sender != 0` (the general reference field, live), and
`length(m\payload\mainArgs) != 0` (an ordinary field path through the
payload, kind 3, into MainLetter's own field -- no new machinery needed
there at all: an intermediate Structure-reference field already composed
correctly before this ticket, proven by the pre-existing
`unit_field_path_nested.lm2`). Called from the root; result relayed via
`sendMessage: exit(...)`.

Per fable's scope note: the walked root's own version of this same read
needs the `take` primitive at the root, which does not exist yet (Grok -177
later) -- the existing root-level K6 fixtures (`entry_argc_if.lm2` etc.)
stay `root-pending`, untouched by this commit.

### Gates (commit 2)

l2_harness GREEN 343/343, `build_l2src -Run` GREEN 260/260 (kernel selftests
included), L3 selftest 11/11 + type budget OK, check_docs OK,
`git diff --check` clean.

## Commit 3: `sendMessage: Ref X`, root + method body

Base: origin/main after commit 2 integrated (`fbd3081`), then rebased again
onto `8292bc3` once -178 c3 / -179 / D-57 / D-58 landed (harness 349 clean
before this commit's own edits).

### The witness-construction blocker, and fable's design answer

Before writing translator code, traced whether either of fable's two
proposed driver-side witness shapes (a sibling child of the host root, or a
standalone Message record) could actually observe a real reply. Both hit
the same root cause: `lmx_root_launch` (`lmx_root.lm1:990-1123`) is one
opaque call giving R0 exactly one scheduled turn
(`lmx_manager_round(mgr, 1U, now)`, ticks=1U literally = one
`lmx_manager_step`); R0's own mailbox/service do not exist until partway
through that same call, and the only existing driver hook
(`l2_driver_program`) fires even earlier, before R0 has a mailbox at all.
No hook existed between R0's mailbox coming into existence and its one
turn running, so nothing the driver built could get a second letter into
R0's inbox before that turn -- not just a host-graph-field-count problem
(fable's own first guess), a deeper one. Reported with line numbers rather
than working around it, per the ticket's standing rule; fable's answer:
Grok issues a real kernel tap (FABLE-GROKBOT-LAUNCH-TAP-20260925-182,
landed after this commit as `LmxRootBeforeTurn`/`before_turn` on
`LmxRootLaunch`), and this commit proceeds on the translator mechanism
alone, with a structural (generated-C) witness instead of a behavioral one
-- the driver-side behavioral witness is commit 4, gated on -182.

### The shape: Ref is everything before the last field, not a fixed 1-or-2 count

First design (matching commit 2's `receiveMessage: m Model`) assumed
`sendMessage: Ref X` is always exactly 2 top-level items. Wrong: P0 does
not lex a field path as one atom with an embedded backslash -- `m\sender`
is three SEPARATE sibling fields (`m`, `\`, `sender`), only merged back
into one logical token by `l2_rw_tokens`/`l2_rw_path_run`'s own path-run
detection (confirmed by reading `l2_rw_path_run`'s doc comment and body,
`l2trans.lm1:16957-16973`, before writing any shape-parsing code). So
`sendMessage: m\sender Pong(n: 1)`'s body is FOUR active fields (`m`, `\`,
`sender`, the `Pong(...)` frame), not two. Redesigned the shape check
around this: the message Structure is always the body's LAST active field
(`l2_count_active(body) - 1` fields before it, 0 meaning no Ref, the
ordinary form unchanged); the Ref run, whatever its own internal field
count, is handed whole to `l2_rw_texpr` (root) / `l2_eval_fields` (method
body) -- both already tokenize an arbitrary field-path run internally
(`l2_rw_path_run`/`l2_rw_path_atom`), so no new path-merging code was
needed, only the boundary computation (`l2_skip_span(f, refn)` to find the
message field, matching `l2_rw_tokens`'s own use of the same helper).

### Where the Ref value travels: refs[], not dest

`l2_emit_send`'s shared generated-function signature already carries a
`dest` parameter, unused inside the body -- the pre-commit-3 comment
called it "the natural place" for an explicit addressee. Measured this is
wrong before using it: at the walked root, `dest` is the WALKER's own
per-step result-destination slot (`lmx_walk_prim(f, code, dest, out)` ->
`record\fn(record\owner, refs, n, dest, out)`, `dest = f\dest`, read in
`lmx_walk.lm1:1082-1123`), not a caller-suppliable input -- reusing it for
an addressee would collide with what every other prim already uses it for
(a call's or merge's own result slot). `refs[]`, by contrast, is the
walker's ordinary per-step EVALUATED-INPUT array, already how every
payload int field reaches the prim; the Ref value travels the same way,
as one more evaluated input, placed LAST (`refs[ni]`, after the payload's
own `ni` int fields) so the existing payload-field indices need no
renumbering. `has_ref_arr[k]`, a new per-site STATIC flag threaded through
`l2_emit_send`'s existing `count_arr`/`kind_arr`/`text_arr` parameters,
picks which of two `lmx_service_post` lines this k's OWN generated
function gets -- a generation-time choice, not a runtime branch, since
each `l2_send<k>`/`l2_msend<k>` is a freshly emitted function per site
either way.

### Two forms, one shared mechanism

`l2_msend_register` (method body) and `l2_rw_send` (root) both gained the
same shape logic (total/refn/has_ref, `l2_skip_span` to the message
field); `l2_rw_send` additionally type-checks the Ref via
`l2_rw_fields_ty(f, refn)`, refusing "a Ref that is not a reference" when
its static type is not >= 1000 (the file's own reference-type convention,
`l2trans.lm1:17751`). `l2_msend_register`'s method-body side leaves this
to `l2_eval_fields`'s own natural refusal instead of a duplicate check
(consistent with how payload fields are not separately type-checked there
either). `l2_emit_msend` evaluates the stored Ref field run
(`l2_eval_fields(f, refn, ...)`) into the last `l2_msr%d[]` slot;
`l2_rw_send` walks it (`l2_rw_texpr(f, refn, refty, ...)`) into the last
PRIM input slot (`l2_rw_put(\out, 2 + ni, e)`). Both call sites, and
`l2_emit_send`'s own `nargs`/array-size arithmetic, extend by exactly
`has_ref` (0 or 1). A `l2_scan_body` name-visibility pre-pass (unrelated
to emission, feeds forward-reference checking) had its own hardcoded
"item 0 is always the message" assumption, found by grepping every
`sendMessage` reference in the file, not just the emission sites --
updated the same way (scan the Ref run too, via `l2_scan_fields`, which
already skips a path run's own `\name` segments for the same reason
`l2_rw_tokens` does).

### L1 syntax traps (again), caught by building, not guessing

Two multi-level dedents needing an extra `---` cutter (matching this
project's own recurring "source level decrease must be one step" gotcha):
the `if: has_ref != 0 / if: ... / return: 1` -> `else:` shape in
`l2_emit_send`'s addressee branch, and the parallel one-level-too-shallow
`---` after `l2_rw_send`'s own Ref-input `l2_rw_put` call. Both found by
running `l2_harness.ps1` and reading `build.l2trans.translate.log`'s exact
line:column, not by re-reading the L1 source for reasonableness.

### The root-walked form's witness: three measured probes, not a guess

Tried three things before settling on what to pin, each an actual
`l2trans.exe` invocation against the currently staged build, not a
prediction:

1. `receiveMessage: m MainLetter` (the 2-name form) at the root, then
   `sendMessage: m\sender exit(...)` -- refuses "an admission to a
   Structure type" at the `receiveMessage` line itself, before ever
   reaching the `sendMessage`. Pre-existing and unrelated: the same
   refusal is already documented in `0e4b00e`'s own integration message
   ("the two-name form receiveMessage: m Model at the walked root refuses
   as an admission to a Structure type -- -178 c3's receive-if, not the
   take"), landed before this commit touched anything.
2. A root-level `const: @(LmxMsg m 0)` own-field declaration (the same
   unit-level cursor form `l2_const_local_ty`'s own comment describes,
   `l2trans.lm1:5428-5430`) -- refuses "this statement" (`frame=const`), a
   different, separately pre-existing root-walk gap.
3. The bare `receiveMessage: m` (untyped, 1-name) letter reference itself,
   used directly as Ref -- TRANSLATES, BUILDS, and LINKS cleanly (the only
   root-walkable reference value reachable today), but at RUNTIME crashes
   uncontrolled (`lmx: walk error: PRIMITIVE`, exit 3): `m` is the letter
   Structure, not a Thread/Message address, so `lmx_service_post` correctly
   refuses it -- not a `Fails`/`Thrown`-shaped outcome any harness row
   category fits, so nothing is pinned on this probe; the file (and its
   would-be row) were dropped rather than forced into a category that
   does not describe what actually happens.

Net: the root-walked mechanism itself (`l2_rw_send`'s shape detection,
`l2_rw_fields_ty`'s type check, `l2_emit_send`'s shared refs[]-based
addressee) is exercised and correct -- probe 3 proves the ACCEPT path,
`unit_send_ref_root_type_refused.lm2` (kept as a harness row) proves the
REFUSE path -- but there is no reference value at the root today that is
both type-accepted AND a real postable address, so no positive root-level
harness row exists for this commit. That gap is entirely upstream of
`sendMessage`, in `receiveMessage`'s own root-walked admission; not this
ticket's to fix.

### Witnesses

`unit_send_ref_method.lm2`: `receiveMessage: m MainLetter` inside a
method (R0's own mainArgs letter, as `unit_receive_letter_model.lm2`
already establishes), then `sendMessage: m\sender exit(exit_code: 0; ...)`
-- ONE send site only, deliberately (a defensive fallback send for the
m=0/m\sender=0 paths would emit its own `lmx_thread_parent(t)` for a
DIFFERENT k, defeating the Absent pin below on an unrelated function, not
a real regression). R0's own mainArgs sender is the host, the same
destination the implicit form already reaches, so this cannot pin a
BEHAVIORAL difference from Ref (no L2-level second sender exists before
-182) -- it pins the STRUCTURAL one instead: `Absent = @('lmx_thread_parent')`,
`Debt = @('lmx_service_post(lmx_child_service(t), refs[')`, reading the
generated C directly the way the harness's own Debt/Absent mechanism is
designed for. `unit_send_ref_root_type_refused.lm2`: a plain `int` own
field named as Ref at the root, refused at the exact statement --
positive/refusal-shape confirmation that `l2_rw_send`'s new type-check
actually fires (measured via probe, not assumed).

### Mutation witness

Reverted `l2_emit_send`'s `if: has_ref != 0` to `if: 0 != 0` (scratchpad
backup/restore, confirmed byte-identical after restore) -- RED, exactly 1
of 351 targets, `unit_send_ref_method` failing its Debt/Absent text check
(the generated C reverts to `lmx_thread_parent(t)` for every site);
`unit_send_ref_root_type_refused` unaffected (it refuses before reaching
the addressee-emission code at all, correctly isolating what the mutant
touches). Restored; harness GREEN again, 351/351.

### Gates (commit 3)

l2_harness GREEN 351/351 (349 + this commit's 2 new rows), `build_l2src -Run`
GREEN (kernel selftests included), L3 selftest 11/11 suites + type budget
OK (4 units), check_docs OK, `git diff --check` clean.

## Still open for -172

Commit 4 (the driver-side behavioral witness: a peer Message built via
Grok's new `before_turn` launch tap, FABLE-GROKBOT-LAUNCH-TAP-20260925-182,
posting a `Ping` letter to R0 with that peer as sender, observing the
reply land in the peer's own inbox rather than the host's) -- not started,
gated on -182 landing on origin/main.

D-53 (the pre-existing `@`-on-a-Structure-typed-own-field double-indirection
bug, found building commit 1's witness) remains open, reported to fable,
not fixed by this ticket.

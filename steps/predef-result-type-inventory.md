# FABLE-SONNET-PREDEF-RESULT-TYPE-20260924-160 commit 1: measure before touching code

D-35: `l2_colon_simple_ty` (`dev/l2src_sandbox/l2trans.lm1` :5420, branch :5461 `if: m < 0 &&
l2_is_known(value\as\frame\head) != 0 -> \out_ty: -10; return: 0`) gives EVERY call admitted only
through `l2_is_known` (a predef'd function OR a bare `c.*` door call) the numeric-literal type code
`-10`. `l2_colon_types_compatible` accepts `-10` only into a numeric target (int/size_t/unsigned/
ulong); a pointer or Structure target is refused, and a `void`-returning predef assigned to a
numeric target is silently accepted at the L2 level (caught only by gcc). The real declared return
type of a predef'd function exists in its `prototype:` block; `l2_predef_file_has_function` (:4506)
already re-parses that block but only for a yes/no name match, discarding the return-type field it
walks right past.

## (a) Which predef'd calls the corpus actually assigns, and to what target

`rg` over `dev/l2src_sandbox/tests/*.lm2` for `NAME: callee(...)`-shaped lines, filtered to callees
that are NOT local L2 methods (predef'd C adapters) -- the corpus is narrow, four fixtures:

- `entry_parse_min.lm2:20`: `status: lm_p0_parse_file(...)` into `int: status`. `lm_p0_parse_file`'s
  prototype (`l1src/parser.lm1`) declares `int`. **-10 already accepts this** (numeric into
  numeric) -- passes today, will keep passing under the real type (also `int`, same numeric
  bucket). No behavior change.
- `unit_predef_result_struct_refused.lm2:15`: `bad: lm_p0_parse_file(...)` into `Model: bad` (a
  named-Structure-typed local). Registered `Expect = 'l2trans-refuses'`, `Needle = 'assignment
  value has incompatible type'`. **-10 already refuses this** (numeric into a Structure target).
  Under the real type (`int`), still refused, same message, same reason class (numeric into a
  non-numeric target) -- **no row change needed**, but the reason changes from "read as a numeric
  literal, refused" to "read as its real `int` return, refused" -- worth a one-line comment update,
  not a behavior change.
- `unit_predef_result_void_refused.lm2:15`: `status: lm_p0_document_destroy_owners(document)` into
  `int: status`. `lm_p0_document_destroy_owners` is `sub:`-declared (void return). Registered
  `Expect = 'toolchain-refuses'` (l2trans MUST currently accept; only gcc refuses, "void value not
  ignored as it ought to be"). **-10 currently accepts this** (numeric into numeric -- L2 has no
  idea the real return is void). Under the real type (void/8, not in `l2_colon_types_compatible`'s
  numeric set `{-10,0,1,2,10,34,36}`, and target_ty=0 != 8), **this flips to L2trans REFUSING** with
  "assignment value has incompatible type" -- **the harness row must change**:
  `Expect: 'toolchain-refuses'` -> `Expect: 'l2trans-refuses'`, `Needle: 'assignment value has
  incompatible type'`. This is the fixture's own comment's "not caught at the L2 level" claim
  becoming false, in the intended direction (D-35's whole point) -- update the comment too.
- `unit_lm_own_actual_span.lm2:15`: `copy: lm_own_copy_bytes(text, n + 1U)` into `@: char copy`
  (own-field). `lm_own_copy_bytes`'s prototype (`l1src/own.h.lm1`, added in -155) declares
  `@: char`. **-10 currently refuses this** (numeric into a pointer target) -- measured directly
  during -155 (manual l2trans run, "assignment value has incompatible type" at this exact line);
  recorded as D-35 from that finding. Under the real type (`@: char`, matching the target exactly),
  **this now SUCCEEDS** -- this is D-35's primary motivating, currently-broken case. The fixture is
  presently un-gated (orphan, per -155); once this lands it should translate clean end to end
  (already confirmed l2trans/l1trans accept the rest of the file during -155's own measurement) and
  can be gated.

No other `.lm2` fixture assigns a predef'd call's result to anything but a numeric target (the
`(cast: (@: T) c.foo(...))` shapes found by the same `rg` sweep are a DIFFERENT case, see (c)).

## (b) What a `prototype:` line's return-type field actually looks like, and its P0 shape

Surveyed every `fn:`/`sub:` line inside every `*.h.lm1` prototype header in the corpus (`rg`, see
scratch count). Wide variety of POINTER return spellings (`@: Lmx`, `@: LmxMsg`, ... -- kernel
internal types used only inside the kernel's own `.lm1` units, never assigned in an `.lm2`
fixture), but the vocabulary that (a) shows is actually ASSIGNED is exactly: bare `int`, `@: char`,
and the absent/`void` spelling for `sub:`.

P0 shape, confirmed by TWO independent readings that agree exactly: the real method-registration
code's own return-type read (~:12670-:12690, the `field: l2_next_active(...)` chain after formals)
AND, more directly, `l2_check_os_fn` (:5078) -- which checks precisely this bodiless-`fn:`-with-
empty-params shape (`l2_count_active(fn\as\frame\body) != 3`, then `f = first field (name, ATOM)`,
`p = l2_next_active(f\next)` (params, `l2_empty_struct(p\value)`), `ty = l2_next_active(p\next)`
(return type, `l2_frame_head(ty\value, "@")`)). A `prototype:`-block declaration is a FRAME (head
`"fn"` or `"sub"`) whose BODY is a flat field sequence `[name-atom, params-STRUCTURE, return-type-
node?]` -- exactly like a real method signature, just without a 4th body-Structure field (no
executable body). `params` is a `LM_P0_NODE_STRUCTURE`, not a frame (confirmed: `l2_typed_formal`
is applied per-field by walking `params\as\structure\first_field`, not to a single frame value).
The return-type node, when present, is `l2_next_active(l2_next_active(decl\as\frame\body\first_
field)\next)\next)\value` -- skip the name field, skip the params field, land on the third. A
bodiless `sub:` line may omit the return-type field entirely (matches `is_sub`'s own unconditional
`l2_m_ret[l2_m_n]: 8` in the real registration code, no atom read at all).

## (c) The `c.*` door question

Every bare (non-cast-wrapped) `c.*` call assigned in the corpus targets a numeric local (`v:
c.rand()` into `int: v`, `unit_c_empty_call.lm2`) -- already fine under `-10` either way, no
corpus signal either direction. Every NON-numeric-target case found by the same sweep is a
`(cast: (@: T) c.foo(...))` shape (`unit_c_member_write.lm2` and ~10 siblings) -- there the outer
frame head is `"cast"`, not `"c.foo"`; `l2_head_method("cast")` and `l2_is_known("cast")` are both
false, so `l2_colon_simple_ty` returns 1 for the OUTER expression today already ("unable to
determine type") -- UNLESS the target itself is foreign (`@: c.LmP0Text`, not `@: LmP0Text`), which
every one of these examples is. A foreign-typed target's own assignment path is the raw-C-member
mechanism (-14's norm: `c.*` is a syntax-transparent door; the raw member/foreign-typed write path
is a separate mechanism from `l2_colon_check_assignment`'s numeric-literal-for-`-10` path, not
touched by this ticket, not exercised by `l2_colon_simple_ty` at all here since the target isn't a
plain L2 pointer). So there is no cast-wrapped case in the corpus routed through `l2_colon_simple_
ty` needing a plain-pointer target either -- this whole family is a red herring for D-35 (verified,
not just assumed: `l2_colon_bound_ty` on a foreign-prefixed name returns a foreign (>=100) code,
`l2_colon_check_assignment`'s `target_ty >= 100 && l2_foreign_const[...]` branch (:5524) is the
first thing that even looks at it, well before `l2_colon_simple_ty` would matter to the outcome).

**Recommendation: -10 stays exactly as-is for a genuine `c.*` door call (matches `l2_is_known` via
the `c.*` prefix, NOT via `l2_predef_has_function`).** Reasoning: a bare door call has no signature
anywhere to read -- there is nothing to upgrade it TO. The quoted norm ("the door's text goes to C,
gcc checks, no L2 type at all") is about not inventing C-parsing/type-inference for raw text, which
`-10` does not do -- it is the same conservative, already-established fallback from -137, applied
only to the narrow `target: call()` compatibility pre-check, refusing into a non-numeric target and
accepting into a numeric one either way. Replacing it with "skip the check entirely" would make an
UNKNOWN-signature call MORE permissive than a KNOWN-signature one now gets (this ticket's whole
point is the opposite direction: known signatures get checked precisely). No corpus fixture needs
the wider reading; the norm's harder claim (gcc is the only judge of `c.*` text) is already true
for calls that get emitted verbatim regardless of what `l2_colon_simple_ty` decides for the
COMPATIBILITY PRE-CHECK specifically -- narrowing to "no L2 opinion AT ALL, not even a fail-closed
default" is a wider-door change this ticket does not need and the corpus gives no signal to make.
Commit 2 therefore only changes the branch for calls resolved via `l2_predef_has_function`; the
`c.*`-door sibling condition (already a separate, ORable clause today) is untouched.

## Commit 2 plan

One new accessor next to `l2_predef_has_function`, mirroring its exact file-walk (including the
nested-`predef:` recursion) but extracting the return-type node once a name matches instead of
just setting a found flag, then converting that node to an `l2_own_ty`-family int the same way the
real method-registration code already does for the handful of spellings this corpus actually needs
(bare `int`/`size_t`/`unsigned`/`ulong`, `void`/absent, `@: char`, `@: void`, and a named-Structure
atom via the same generic `l2_colon_graph_ty()` real methods use -- `l2_colon_simple_ty`'s existing
downstream recovery (:5473-:5477) already turns that into the right own-field code, unchanged).
`l2_colon_simple_ty`'s :5461 branch calls the new accessor instead of unconditionally setting -10;
falls back to -10 only when the accessor reports no prototype found (name not predef'd -- must be
the `c.*` door per (c), or `l2_is_known` would not have been true in the first place).

Witness rows: `unit_lm_own_actual_span.lm2` gated (now succeeds, `@: char` target). New pointer-
target success row (`@: T p` from a predef'd call declaring `@: T`) if the existing fixture doesn't
already cover it end to end. `unit_predef_result_void_refused.lm2`'s row updated (`l2trans-refuses`
/ new Needle) per (a). Mutant: the accessor forced to always report "not found" -> falls back to
`-10` -> the pointer-target success row flips to refused (RED).

## Commit 3 (D-34)

`unit_indent_stack_field_index.lm2` / `unit_void_value.lm2`: bare `LmP0IndentStack`/`LmP0Text` CAST
TARGETS, stale against the `a2cf69e` migration to `c.LmP0*` raw spellings (measured during -155:
"unknown type", atom=`LmP0IndentStack`/`LmP0Text`). Fix = respell the cast target with the `c.`
prefix (`(cast: (@: c.LmP0IndentStack) ...)` / `(cast: (@: c.LmP0Text) ...)`), matching the already-
established migration every other fixture in the corpus uses (`unit_c_member_*` etc.). Gate each to
its nonzero success value if it then runs clean; if a further gap surfaces, report it rather than
force a fix outside this ticket's scope.

**Commit 3 landed: the respelling was wrong in scope, corrected, and each fixture hit a further,
separate gap -- reported per the plan above, neither fixture gated.**

Re-measured on the current tree (after commit 2) rather than trusting the -155-era note above: the
"unknown type" in `unit_indent_stack_field_index.lm2` was NOT at the cast target -- it was at the
FORMAL parameter (`fn: store_and_read (@: LmP0IndentStack stack; ...)`, column landed exactly on
the type atom), i.e. the file's own header comment ("a formal is admitted and reads back") is
itself stale. Respelled every bare `LmP0IndentStack` in the file (the formal, the local, and the
cast target -- three sites, not one). That clears "unknown type" entirely (confirmed: re-running
l2trans no longer names it), but the SAME statement that was always going to run next,
`stack\columns[idx]: value` (`idx` a `size_t:` local, not a decimal literal), now refuses "own
array index requires an in-bounds primitive literal" -- a raw-member-array-write limitation
unrelated to the type spelling, was never reachable before since the formal failed first. Not
fixed: dynamic own-array indexing through a raw member path is its own, separate capability gap,
not a D-34 respelling.

`unit_void_value.lm2`: the bare `LmP0Text` WAS exactly where expected (`sub: d`'s formal). Respelled
it. That clears "unknown type", but the fixture's very next statement, `fn: m (...) int` returning
`d(0)` where `d` is a `sub:` (no result), now refuses "incompatible entry signature" (frame=return)
-- not the "a callable without a result has no value" message the same shape gets elsewhere in the
corpus (`unit_value_call_sub_refused.lm2`, `unit_return_sub_refused.lm2`). The fixture's own name
suggests this IS the void-value-in-return-position case it was written to probe, but whether
"incompatible entry signature" is the intended/correct message for it, or itself a gap, is a
separate question this ticket does not answer. Not fixed.

Both respellings are correct and kept (they match the established `c.LmP0*` migration exactly, and
demonstrably clear the type-resolution error each fixture led with) even though neither fixture
newly gates -- reporting the deeper gap each one now surfaces, as the plan above said to, rather
than chasing either into its own separate ticket's territory.

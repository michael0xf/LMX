# FABLE-SONNET-DIAG-AND-INDEX-20260924-163 commit 2 (D-39): measured, not fixed

D-39: `stack\columns[idx]: value` (`unit_indent_stack_field_index.lm2`, `idx` a `size_t:` local, not
a decimal literal) refuses "own array index requires an in-bounds primitive literal". Asked to
measure whether the existing dynamic-index lowering for own arrays (`a[i]` on a local array, -144)
can be reused for this member-path case, or to write up the anchors and the size of the change if
not.

## Where the literal-only check lives

`l2_own_index_tail` (`:7825`, member-path array index: `root\field[idx]`) and `l2_own_index_head`
(`:7792`, bare-rooted array index: `node\buf[idx]` / a top-level own-array name) both resolve the
bracket contents via `l2_array_literal` (`:7865`, `:7811`/`:7818`) into a `size_t` OUT-PARAMETER --
`l2_array_literal` only accepts a decimal literal atom; anything else (a variable name) makes it
return non-zero, which both callers turn into status `2` ("...requires an in-bounds primitive
literal"). This is `stack\columns[idx]`'s exact path: `stack` resolves as a formal (`l2_formal_find`
at `:7836`), `columns` is the field name, `[idx]` reaches `l2_array_literal` and fails because `idx`
is an atom naming a local, not a digit string.

## The existing dynamic-index mechanism (-144) is a DIFFERENT function, not reusable as one helper

`l2_index_head` (`:7412`, NOT `l2_own_index_head` -- confusingly similar name, unrelated function)
is what handles `a[i]` on a bare local/own/formal array name. It resolves the array NAME against
three flat tables (own-fields `:7446`, method-locals `:7452`, formals `:7458`) and, critically
(`:7464-:7475`), does NOT require the index to be a literal: if the digit-scan at `:7465-:7470`
fails, it falls through to `ok: 1` anyway ("A compact assignment head keeps the index expression as
source text... the L1 compiler validates the expression after `l2_index_token` has renamed any
formal identifiers it contains"). The EMISSION side (`:18137-:18157`, and its `unit_native_
activation.lm2`-gated sibling around `:13930`) confirms this concretely: for the dynamic case it
just emits `l2_p%d_%d[%s]: %s` (or the local/slot equivalent) with the index token dropped in
VERBATIM as raw C -- **no runtime bounds check at all**, ordinary C array-indexing UB if out of
range. This directly measures a claim in the ticket's own framing: there is no "existing refusal/
abort" for the dynamic case to reuse for bounds -- the -144 mechanism trusts the C compiler/runtime
entirely, matching the `c.*`-door norm elsewhere in this corpus, not a checked own-array primitive.
(Whether some OTHER, kernel-side runtime array type has its own bounds abort is a separate question
this note does not answer; the l2trans EMISSION path measured here has none.)

`l2_index_head` operates on a bare NAME token (`t\data` is the whole `name[expr]` text, scanned
byte-by-byte for the matching bracket) -- it has no concept of a multi-SEGMENT field path
(`root\field[idx]`) at all. `l2_own_index_tail` is a completely different parser, walking P0
FIELDS (`f`, `f\next`, ...) across a slash-separated path, not scanning one atom's raw bytes.
Reusing `l2_index_head`'s literal-or-fall-through trick for the member-path case is not "call the
existing helper instead" -- it would mean teaching `l2_own_index_tail`'s own bracket-parsing (which
currently only ever produces a resolved `size_t`) to ALSO produce "an unresolved index expression,
emit it verbatim" and propagating that second outcome through every consumer.

## Every consumer that would need updating

`l2_own_index_tail`/`l2_own_index_head`, together, have **9 call sites** (`rg` over
`dev/l2src_sandbox/l2trans.lm1`, confirmed): `:13092`, `:13387`, `:13515`, `:13707` (checking),
`:14847`, `:15435`, `:15569`, `:16686`, `:17797` (emission). Every one currently assumes `out_index`
is a resolved `size_t` it can print as a decimal literal directly into the generated C array index
(`l2_p%d_%d\%.*s[%zu]`-style, contrast the `%s` token `l2_index_head`'s dynamic case uses). Making
the member-path form accept a dynamic index means: (a) `l2_own_index_tail`/`l2_own_index_head`
themselves gain a second success mode (literal found vs. index-expression-to-emit-verbatim, mirroring
`l2_index_head`'s `ok`/fallthrough), (b) every one of the 9 call sites' checking-side logic (which
today only ever handles a compile-time-known index, e.g. static bounds checks against a fixed
Array's count at some of these sites) has to accept the new mode or explicitly keep refusing it
there, and (c) every one of the 9 call sites' EMISSION logic has to switch from printing a literal
`size_t` to interpolating an expression token the way `l2_index_token`/`l2_eval_fields` already do
for `l2_index_head`'s case. That is a substantially bigger change than one helper -- not attempted
here, per this ticket's own instruction.

## Not fixed

`unit_indent_stack_field_index.lm2` stays ungated (D-39 stays OPEN, this note supersedes the
one-line description in `steps/defects.md`). No code touched in this commit.

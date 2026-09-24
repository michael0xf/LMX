# Name-specials inventory (FABLE-SONNET-NAME-SPECIALS-20260924-155 commit 1)

Measure-first, docs only, no code changes in this commit. Norm: plan §7a + §0
doctrine -- `c.*` is the raw door into C; no hidden registry, no name/substring
special, adapters are visible only through `predef:` declarations a fixture
itself writes. Measured on `dev/l2src_sandbox/l2trans.lm1` against
`sonnet/name-specials`, base `origin/main 22692ee`. Line numbers cited are
current on this base and will drift; re-locate by content.

## (a) `l2_is_known`'s hard-coded adapter-name list (:8698-:8717)

The function checks, in order: `c.*` prefix (raw door, always known) --
11 hard-coded literal names -- `l2_predef_has_function(t)` (the general
mechanism: does ANY of the unit's own `predef:` files declare `fn:`/`sub:
<name>`). The plan §7a tick claiming "adapters visible only through predef
declarations, not a hard-coded list" is false against this code (fable
already marked it so, `e7ef416`). Measured each of the 11 names against
every fixture under `dev/l2src_sandbox/tests/*.lm2` that calls it, and
whether that fixture's own `predef:` set already declares the name (in
which case `l2_predef_has_function` alone already succeeds and the
hard-coded entry is inert) or not (in which case deleting the entry
without adding a `predef:` line would newly refuse that fixture: this
IS the general mechanism failing to see the adapter, exactly the "unresolved
name" the norm wants, but the fixture needs the mechanism it was
skipping to have a real declaration to point at).

| Name | Verdict | Evidence |
| --- | --- | --- |
| `lm_p0_parse_file` | REDUNDANT | 2 callers (`entry_parse_min.lm2`, `unit_predef_result_struct_refused.lm2`), both `predef: "l1src/parser.lm1"`, which declares `fn: lm_p0_parse_file(...)` at `l1src/parser.lm1:196`/`:4601`. |
| `lm_p0_document_destroy` | REDUNDANT | 2 callers (`entry_parse_min.lm2`, `unit_predef_result_void_refused.lm2`), both `predef: "l1src/parser.lm1"`, which declares it as `sub: lm_p0_document_destroy(...)` at `:198`/`:4666`. `l2_predef_file_has_function` (:4515) matches both `l2_frame_head(decl,"fn")` and `l2_frame_head(decl,"sub")`, so a `sub:` declaration resolves the same way. |
| `lm_p0_dump_alloc` | N/A | Zero calling fixtures, zero `tools/l2_harness.ps1` mentions. Deleting this entry is a no-op against the current corpus. |
| `lm_p0_free` | N/A | Same: zero callers. |
| `lm_p0_document_diagnostic` | N/A | Same: zero callers. |
| `lm_own_new_zero` | RELIED-ON (2 of 4 callers) | `repro_fnptr_value.lm2` and `unit_fnptr_prototype_value.lm2` predef their own `*.h.lm1` (which DOES declare it) -- redundant for these two. `unit_indent_stack_field_index.lm2` and `unit_lm_own_actual_span.lm2` have **no `predef:` line at all** (confirmed reading their first lines) -- these two rely entirely on the hard-coded entry. |
| `lm_own_copy_bytes` | RELIED-ON (2 of 2) | `unit_bad_sizeof.lm2` and `unit_lm_own_actual_span.lm2`, neither has a `predef:` line. |
| `lm_own_delete` | RELIED-ON (4 of 4) | `repro_fnptr_value.lm2` and `unit_fnptr_prototype_value.lm2` DO predef a `*.h.lm1`, but that file only declares `lm_own_new_zero` (line 4 of each), not `lm_own_delete` -- so even these two do not resolve it via the general mechanism today. `unit_lm_own_actual_span.lm2` and `unit_void_value.lm2` have no `predef:` line at all. All 4 rely on the hard-coded entry. |
| `lm_own_resize` | RELIED-ON (1 of 1) | `unit_lm_own_actual_span.lm2`, no `predef:` line. |
| `l2_immut_query_fill` | N/A | Zero callers. |
| `l2_hash_compare_q` | N/A | Zero callers. |

**Blast for commit 2**: deleting the list outright and adding nothing else
would newly refuse 5 fixtures (`unit_indent_stack_field_index.lm2`,
`unit_lm_own_actual_span.lm2`, `unit_bad_sizeof.lm2`,
`unit_fnptr_prototype_value.lm2`, `repro_fnptr_value.lm2` -- the last two
only for `lm_own_delete` specifically, their `lm_own_new_zero` calls stay
fine). Fix is per fable's reading: these fixtures get the `predef:`/
declaration they lacked (the migration), not a relaxation of the norm.
Concretely: add `predef: "l1src/parser.lm1"` (or the specific adapter
header) to the 3 fixtures with no `predef:` line at all, and add the
missing `fn: lm_own_delete(...)` prototype line to
`repro_fnptr_value.h.lm1` and `unit_fnptr_prototype_value.h.lm1` (both
already predef `lm_own_new_zero` from the identical family, so the
missing sibling prototype is a one-line addition to files that already
exist for exactly this purpose). The other 6 names (2 REDUNDANT + 4 N/A)
need no fixture changes at all. `l2trans.lm1`'s OWN predef list (`predef:
"l1src/parser.lm1"` / `"l1src/libc_abi.lm1"`, its own lines 1-2) is an
L1-layer concern -- l2trans.lm1 is itself compiled by l1trans -- separate
from `l2_is_known`, which only gates names in the L2 *fixture* source
being translated; `l2_predef_file_has_function` itself calls
`lm_p0_parse_file`/`lm_p0_document_destroy` as ordinary bare L1 calls via
that same top-of-file predef, internal to the translator's own
implementation, not a special case for the L2-side lookup.

Witness for commit 2 (per fable): pin a row where a fixture calls an
adapter with NO matching predef and is refused "unresolved name" -- the
mutant's inverse and the norm's own witness that names now resolve only
through `c.*` spelling and `l2_predef_has_function`.

## (b) Substring type dispatch around `lm_own_new_zero` (:14848-:14864 in this build)

`s0` is not raw source text or a type spelling -- it is the **generated C
expression text of `lm_own_new_zero`'s own size argument** (`l2_emit_fields`
writes it into `s0` first, e.g. a `c.sizeof(...)`-derived expression). The
three arms `c.strstr(s0,"IndentStack")` / `"size_t"` / else-`LmP0Text`
decide only the C cast type of a throwaway temp that the call's `@: void`
result gets stuffed into before `return: l2_tok_temp(t, dest)` -- a name
(well, substring)-special standing in for the declaration `lm_own_new_zero`
already has: `(size_t: size) @: void` in every `.h.lm1` that declares it.

Checked all call sites across the 4 fixtures that use `lm_own_new_zero`:
every one already wraps the call in its own EXPLICIT outer cast --
`(cast: (@: LmP0IndentStack) lm_own_new_zero(...))`,
`(cast: (@: size_t) lm_own_new_zero(...))`,
`(cast: (@: int) lm_own_new_zero(...))`,
`(cast: (@: LmOwnPtrStack) lm_own_new_zero(...))` (2 fixtures). None
depends on the internal temp's guessed type surviving past the call site;
the outer cast always overrides it, and C's `void *` conversion rules mean
the temp's own declared type is inert once re-cast. The already-available
replacement is `lm_own_new_zero`'s real declared return type (`@: void`,
i.e. a bare `void *` temp) -- no substring inspection needed, and every
current caller's outer cast keeps working unchanged. This is the cheapest
of the four items to land.

## (c) `l2_array_local` / L2 `c.array:` declarator (:5039, gated at :5049)

Matches literal head spelling `"c.array"` (`l2_frame_head(stmt,
"c.array")`) plus a required 3-item `[]: T name count` body -- a
name-special L2-level declarator, not an ordinary `c.*` door call.
4 call sites (not fable's estimated ~3): `:3698`, `:13682`, `:16551`,
`:16553`.

`grep -rln "c\.array:" dev/l2src_sandbox/tests/*.lm2` --> **zero fixtures**.
No fixture in the current corpus exercises this L2-level shape at all.
Deleting `l2_array_local` and its 4 call sites is dead-code removal with
zero fixture blast.

**Layer warning, confirmed real** (plan §7a already HOLDs this
separately, "L1 `c.array` (separate, unproven -- do not merge)"):
`l2trans.lm1` itself spells `c.array:` 70 times in its own source, every
one of them **L1 syntax** -- ordinary local scratch-buffer declarations
(`c.array: [256]: char buf`-style), l1trans's own grammar, used
throughout this very file including this ticket's own edits. That is a
completely different compiler layer from the L2-level `l2_array_local`
match and must not be touched by commit 4. Separately, the plan also
tracks ~5 sites where l2trans EMITS `c.array:` INTO its *generated L1
output* (codegen target-language detail, not L2 input syntax) -- also
out of scope here, already its own HOLD item in the plan.

## (d) Unconditional `include: "<stdio.h>" "<stdlib.h>" "<string.h>"` (generated preamble, :18318 in this build)

Written unconditionally into every generated unit's preamble (a second,
unrelated unconditional include set at l2trans.lm1's own line 3 is that
file's own L1-level includes for its own compile, not generated output).

Did not trace every kernel-emitted C snippet exhaustively (that is its
own real pass, not "cheap"). What is visible without that full trace:
essentially every generated method's checkpoint/invariant-violation path
emits `c.fprintf(c.stderr, "lmx: invariant: ...")` / `c.abort()`-style
diagnostics -- kernel-emitted safety-net plumbing present in generated
output regardless of what the user's own L2 source does or does not
predef/include, seen throughout this session in essentially every
generated method body. That strongly suggests stdio.h is a genuine,
pervasive dependency of the generated program's own kernel-level
diagnostic machinery, not merely user-code-derived -- but stating "every
generated program unconditionally hits at least one such site" as a
measured fact, rather than a strong impression, needs the full trace this
commit did not do.

Per the ticket's own instruction ("make stdio use-derived only if commit
1 shows it is cheap; otherwise document the unconditional include as the
intentional mapping and tick the item with that wording"): this is not
shown cheap. Recommend documenting the unconditional include as the
intentional mapping (the kernel diagnostic/checkpoint machinery's own
dependency, not a user-code-derived one) and closing the plan item with
that wording, rather than spending a full trace pass to attempt making it
conditional for a benefit that is unclear given how pervasive the
diagnostic call sites already appear to be.

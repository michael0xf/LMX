# FABLE-SONNET-RECEIVE-RENAME-20260924-166

## Commit 1: nextMessage -> receiveMessage

Landed `9d302fe`. Mechanical rename, full detail in the commit message. Gates: harness 335/335,
build_l2src 253/253, L3 11/11, check_docs OK, diff --check clean.

## Commit 2 (measure-first): does the mainArgs letter have a (sender; payload) shape?

**Measured directly: the letter is bare. No translator change is needed or made.**

`lmx_root_launch` (`dev/l2src_sandbox/lmx_root.lm1:990-1079`, Opus's host-root work) builds the
mainArgs letter with exactly ONE field: `lmx_arena_refs_open_owned(letter_at, letter_graph, 1U)`
(`:1052`, one child slot) and `lmx_arena_ref_store(letter_graph, 0U, main_args)` (`:1066`, that
one slot holds the char-Array-of-Arrays directly). No sender reference field exists; nothing here
was touched, per the ticket's own instruction not to change the letter's producer.

There is nothing to "align" in the translator, because the translator does not special-case
`mainArgs` (a positional field index, or the name itself) anywhere -- confirmed: `mainArgs`
appears exactly once in the whole of `l2trans.lm1`, inside a comment in the generated C `main`
template, never in any field-path-resolution logic (`grep -c mainArgs dev/l2src_sandbox/l2trans.lm1`
= 1, that one line). `receiveMessage: m` binds `m` as an UNTYPED graph; a path through it (`m\
mainArgs`, `m\mainArgs[i]`) has no fields to walk until the program declares its own named
Structure type and admits `m` into it (`MainLetter: char: []: []: mainArgs` / `MainLetter: m` /
`receiveMessage: m`, `unit_entry_args.lm2`'s own shape) -- checked at run time by the kernel's
`implements` walk against the DECLARED shape, comparing the declared field count/types to the
actual graph. `unit_arr_path_untyped_refused.lm2`'s own header comment confirms this directly:
"The letter as receiveMessage gives it is a graph with no declared type: a path through it has no
fields to walk. A program declares `MainLetter: m` first."

So the connection between "what the user calls the field" and "which position it actually is in
the untyped letter" is made entirely by the PROGRAM's own Structure declaration plus the kernel's
`implements` admission -- not by any translator-side positional assumption. Since the letter
today is 1 field (bare payload, no sender), every existing program's `MainLetter`-style
declaration also has exactly 1 field, and `implements` succeeds because the shapes already match.
If `lmx_root_launch` is ever changed to wrap the letter as (sender; payload) -- a SEPARATE,
not-yet-decided change to the producer, out of this ticket's scope -- every program reading
`mainArgs` would need to add a leading sender field to its own `MainLetter` declaration to keep
matching; nothing in the translator itself would need to change even then, since it already reads
purely by the user's declared shape.

**Conclusion: measured, letter is bare, translator already reads correctly relative to that
shape, no commit-2 code change.** Reporting this and stopping at the measurement, per the
ticket's own fallback instruction.

## Commit 3 (D-48, Q24 = A): a repeated typed declaration is a new occurrence

Author (LMX_blog/2026-09-25.md, q24.md): a second typed declaration of the same name in one
body/scope is a new occurrence -- same-type unconditionally (`int: arg 1` / `int: arg 2` ->
`[0]arg=1`, `[1]arg=2`, unqualified `arg=2`); different-type needs the ported lingvamyxa_prev
converters (S7, not landed) to carry the value across types, so it is a located refusal, not a C
cast or implicit widening; the old "duplicate declaration" refusal (`l2_own_add`, "one name, one
cell per scope") was a self-made S2 rule (Opus -112), never the author's -- the book already kept
repeats. Landed, with three findings measured along the way that changed the shape of the fix:

1. **The refusal had to be lifted narrowly, not generally.** `l2_own_add`'s existing fall-through
   for "a repeat is a new occurrence" (the argument same-name-binding rule, `l2_is_asgn` both
   sides) already existed; Q24 needed a SEPARATE, parallel branch for "both sides typed
   declarations" -- kept entirely apart from the existing branch rather than merged into its
   condition, specifically so the existing mechanism (formals, dynamic inputs, receiveMessage's
   own rebind) is untouched. First cut merged the two, guarded only by `l2_param_find < 0`, and
   broke 3 existing, unrelated proof fixtures (`unit_arg_addr_ordinary.lm2` and its two
   siblings -- a typed LOCAL re-declaring a FORMAL's name, an existing, older, different
   mechanism) -- caught by the harness's own binding-order structural check, not a runtime value.
   Fixed by keeping Q24's branch fully separate, guarded off both `l2_param_find` and
   `l2_dyn_find` (a dynamic input has the identical "declared once, already registered before its
   own explicit declaration" shape).
2. **A repeated NAMED declaration exists at UNIT level too** (`unit_root_field_duplicate.lm2`,
   S2: "the unit is the entry, the unit's fields are E's own fields" -- the same `l2_own_add`
   mechanism, `mi` = the entry). Its own comment already said "at unit level as in a method body"
   -- Q24 applies there identically, no separate code path. Fixture flipped from a refusal pin to
   an admission pin.
3. **Two emission/check sites resolved a declaration's OWN row by name only** (`l2_own_find`,
   first match) -- safe before Q24 only because a repeated TYPED declaration could not exist yet,
   so "first match" was always "the only match". Once Q24 lifted the refusal, both sites always
   picked occurrence 0 for EVERY same-named declaration's own bind-mark/value-write, regardless of
   which statement was actually being processed (measured directly: `int: arg 1` / `int: arg 2`
   both wrote into occurrence 0, leaving occurrence 1 uninitialised at its own cell -- exactly the
   dead "Category C" sites this ticket's own -164 catalog named and deliberately deferred, now the
   real bug source Q24 exposes). Fixed by routing both to `l2_own_find_decl(mi, name, stmt)` (the
   exact statement's own row), matching the idiom `l2_own_find_decl`-then-fallback already used
   elsewhere in this file.
4. **The "canonical cell" sharing a repeated own field's occurrences use for the argument
   same-name-binding rule (`l2_own_canon`) does not apply to Q24's repeats.** Measured directly
   (generated C): without a guard, a Q24 same-type second declaration's value got written into
   occurrence 0's cell and then COPIED into occurrence 1's, instead of occurrence 1 getting its
   own independent value -- `l2_own_canon`'s "find an earlier same-named USED row" search is
   specific to the untyped rebinding mechanisms (argument, receiveMessage), which genuinely share
   one cell across occurrences; a Q24 row (`l2_own_decl_ty(l2_own_decl[i]) != 0`) must never be
   treated as another row's canon target. Guarded accordingly.
5. **A repeated declaration's own initialiser expression must not see its own row** (the author,
   verbatim: the initialiser of `char: x (x + 2)` reads the FIRST x, not the row this statement is
   creating). Measured directly: it did -- `int: x (x + 2)` after `int: x 1` compiled to
   `l2_q3: (l2_q3 + 2)` (reading its own, not-yet-initialised cell), because registration runs the
   whole body ahead of emission, so by the time THIS row's initialiser emits, every occurrence of
   `x` (including this one) is already in `l2_own_n` -- a name-only lookup cannot tell "declared
   before this row" from "this row itself". Fixed with a new global, `l2_own_excl` (the row index
   to hide from `l2_own_find_last`, restored to -1 right after), set only around the one call site
   that evaluates a declaration's own initialiser expression.

Witnesses: `unit_q24_repeated_decl.lm2` (the q24.md program plus the author's own expr-initialiser
example, `int: x 1` / `int: x (x + 2)` -> `[1]x = 3`; a write `test\arg: 5` landing in `[1]`, `[0]`
unaffected); `unit_q24_mixed_type_refused.lm2` (`int: x 1` / `char: x (x + 2)` ->
`"conversion int -> char: converters not ported yet (S7)"`); `unit_root_field_duplicate.lm2`
flipped from refusal to admission. Mutant: reverting the same-type fall-through back to the old
refusal turns BOTH `unit_q24_repeated_decl.lm2` and `unit_root_field_duplicate.lm2` RED
(translation failure) -- confirmed directly, then the real fix restored and reverified GREEN.

Gates: l2_harness GREEN 337/337 (334 base + 3 new rows), build_l2src -Run 253/253, L3 11/11 + type
budget, check_docs OK, git diff --check clean.

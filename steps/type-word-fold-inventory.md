# FABLE-SONNET-TYPE-WORD-FOLD-20260924-162 commit 1: measure before touching code

Method: a research fork read every candidate site in full and cross-tabulated their numbering
(`a74b7a6266a9a3cbb`, 16 tool calls); I independently re-verified its two most consequential
claims myself before trusting the rest (both confirmed, see "Verified myself" below). Line numbers
are current-tree (`dev/l2src_sandbox/l2trans.lm1`, base `602f4ae`).

## Every site

| Site (function, anchor) | Parses | Kind |
|---|---|---|
| `l2_proto_ret_ty` (~4586-4637, mine, -160) | `prototype:` decl return type | word+depth→code |
| `l2_ptr_local_ty` (5023-5108; fable's :5059/:5083) | `@: T name` / `@@: T name` local | word+depth→code |
| `l2_const_local_ty` (5110-5162) | `const: @(T name[,0])` local | word(depth1 only, 2 words)→code |
| `l2_own_array_count` (7876-7901, fable's :7886) | `[]: [T name N]` own-array elem gate | **existence-only**, missing `unsigned` |
| `l2_own_array_pointer_ty` (7903-7957; fable's :7931/:7943) | `[]: [(@:T) name N]` own-array pointer elem | word+depth→code, **identical table to `l2_ptr_local_ty`** |
| `l2_own_decl_ty` (7993-8033, fable's :8006 + an uncited scalar branch 8011-8020) | own-field decl, array-of-scalar AND plain scalar | word→code, **two separate sub-tables**, array branch missing `unsigned` |
| `l2_slot_decl_ty` (8735-8756, fable's :8754) | `@: T name` address-slot (11.2.1) | word→code, **only 2 words, mixes two other spaces' numbers** |
| `l2_prim_type_word` (8849-8850) | any atom, `sizeof:` operand gate | **existence-only**, full 6-word chain (what fable called "yes/no only") |
| `l2_typed_formal` (12385-12519+, my extra :12479/:12496) | a real method's formal parameter | word+depth→code, **the omitted 9th site** (see below) |
| `l2_collect_method`'s inline return-type block (~12888-12988, my extra :12894/:12983) | a real method's return type | word+depth→code |
| `l2_cast_type` (14371+, my extra :14397) | `sizeof:`/cast type operand | **word passthrough as raw C text**, not a code at all -- a different kind of site, excluded from this consolidation (nothing to fold it into; it already delegates to the C compiler, matching the `c.*`-door norm) |

Shared infrastructure already NOT duplicated: `l2_resolve_type_atom` (the `Lmx`/named-Structure/
`c.*`-door fallback via `l2_foreign_intern`), reused by `l2_proto_ret_ty`, `l2_typed_formal`'s
depth>2 branch, and `l2_collect_method`'s depth>2/const branches.

## The 9th site

Fable named 8 anchors; those resolve to only 5 distinct functions (two anchors each land in
`l2_ptr_local_ty`, `l2_own_array_pointer_ty`, and one in `l2_own_decl_ty`). `l2_typed_formal` --
every formal parameter in the corpus goes through it -- is the strongest candidate for the
uncounted 9th; `l2_collect_method`'s inline block is the alternate reading. Genuinely ambiguous
from her message alone; doesn't change the work either way, both are real un-consolidated
converters.

## Distinct numbering spaces (the load-bearing finding)

1. **Pointer-local** -- depth1 `{char=12, size_t=9, int=11, void=16, unsigned=25, ulong=38}`,
   depth2 `{char=17, size_t=20, int=19, void=18, unsigned=24, ulong=39}`. Used **byte-identically**
   by `l2_ptr_local_ty`, `l2_own_array_pointer_ty`, and `l2_typed_formal`'s depth-2 block. Has a
   real decoder (`l2_emit_raw_pointer_type` :8045, `l2_emit_own_pointer_type` :8131). **The
   cleanest fold: 3 sites, zero renumbering, one existing decoder to keep.**
2. **Return-code** -- `int=0, size_t=2, unsigned=33 (LmxMsgAddr alias), ulong=36, void=8,
   char-ptr=3, void-ptr=16, void@@=32, const-char-ptr=35`. Consistent between `l2_collect_method`
   and `l2_proto_ret_ty` (confirms my -160 accessor modeled it correctly). **Second clean fold: 2
   sites, zero renumbering.**
3. **Formal-scalar** (`l2_typed_formal`'s non-pointer branch) -- `int=0, char=1, size_t=2,
   unsigned=34, ulong=36`. Agrees with space 2 on int/size_t/ulong; **disagrees on unsigned (34 vs
   33)**; adds a plain char-by-value code space 2 has none for.
4. **Own-field scalar** (`l2_own_decl_ty`) -- `char=1, size_t=2, int=3, unsigned=6, ulong=36`.
   `int=3` collides numerically with space 2's `char-ptr=3` -- different meaning, same digit, no
   shared consumer found (separate arrays throughout), so not a live bug today, just fragile.
5. **Own-field array-of-scalar** (`l2_own_decl_ty`'s other branch) -- `int=4, char=5, size_t=7,
   ulong=37, else=8`; `else=8` collides with space 2's `void=8`, same caveat as above.
6. **`l2_slot_decl_ty`** -- `char=3` (space 2's convention), `size_t=9` (space 1's convention) --
   the single most confusing site: two words, each borrowed from a DIFFERENT other space, in the
   same function.
7. **`l2_typed_formal`'s extra named-type codes** -- `LmxMsgBlock=26, LmxArenaBlock=26 (same code,
   two different names), LmxOwnedRange=27, LmxMsgCopy=31`.

None of the cross-space digit collisions (spaces 2/4, 2/5) are live bugs: every place two spaces
need to interoperate already goes through explicit, named remap glue (`l2_colon_simple_ty`'s
`33→34, 3→12, 35→3, 32→17` block; `l2_own_of_dt`/`l2_ft_of_own`). The risk is that the glue has to
be hand-maintained in step with every chain, not a present miscompile.

## A real bug, found while verifying the fork's flag (not guessed, read directly)

`l2_typed_formal` :12463-12470 (verified myself, exact text):
```
if: l2_text_eq(f\value\as\atom, "LmxMsgBlock")
    \out_ty: 26
    \out_name: g\value\as\atom
if: l2_text_eq(f\value\as\atom, "LmxArenaBlock")
    \out_ty: 26
    \out_name: g\value\as\atom
    return: 0
    return: 0
```
The `LmxMsgBlock` branch is missing its `return: 0` -- it falls through into the `LmxArenaBlock`
check (which won't match), then past this whole block to whatever comes next (`LmxOwnedRange`),
instead of returning immediately with `\out_ty: 26` set. A formal declared `@: LmxMsgBlock name`
does not stop here as intended; whether a later branch in the same chain happens to also match
(unlikely) or the function falls through to its own final failure path is not yet traced -- this
needs one more read before commit 2 touches this function, since folding it without first fixing
(or at least preserving) this behavior would either propagate the bug silently into the new shared
function or accidentally fix it as an uncredited side effect of unrelated work. The doubled
`return: 0` on the `LmxArenaBlock` branch is the same typo's other half -- looks like a
copy-paste of one `return: 0` line landing one `if:` block too high. Recommend fixing this as its
own tiny, separately-cited fix inside commit 2 (or its own D-ticket if fable wants it split out),
not silently folded into the consolidation's diff.

## Verified myself (not just trusted from the fork)

- The `LmxMsgBlock`/`LmxArenaBlock` missing-return bug above: read :12458-12471 directly, confirmed
  exact text.
- Codes 5, 10, 13 (flagged by the fork as appearing in an exclusion list with no found setter):
  grepped `l2_m_ret[...]: 5` / `10` / `13` and `l2_m_ret[...] = 5` / `10` / `13` across the whole
  file -- zero matches, confirming no setter exists. Read the exclusion site itself (:15982,
  `l2_emit_method_head`-family): `l2_ret_uns(mi) = 0 && l2_m_ret[mi] != 3 && != 5 && != 8 && != 10
  && != 13 && != 16 && != 32 && != 35 && < 100 && fputs(") int", ...)`. This is a defensive
  fallback ("anything not specifically excluded gets the generic `) int` suffix"), and 5/10/13 sit
  alongside 3/8/16/32/35 (all real, reachable codes) in that exclusion list even though nothing
  produces them -- reserved/historical placeholders in the return-code space, not a missing setter
  or a live gap. Not blocking; noted so commit 2 doesn't chase it further.

## Not independently re-verified (fork's claim, time-boxed, flagged by the fork itself)

- The full consumer-side trace for spaces 4/5/6 (own-field scalar, own-field array, slot-decl)
  against space 2 was less exhaustive than the space-1-vs-space-2 trace; the "no live collision"
  conclusion rests on "no shared consumer found by grep," not a line-by-line trace like the
  return-code/pointer-local pair got. Worth a spot check if commit 2 ends up touching `l2_own_
  decl_ty` or `l2_slot_decl_ty`'s output range.

## Recommendation for commit 2 (this is a judgment call, stating it rather than guessing silently)

The 9 sites are not one duplicated chain wearing 9 costumes -- they are (at least) 7 distinct
output-code vocabularies, 2 of which (`pointer-local`, `return-code`) are ALREADY internally
consistent across their multiple sites and safe to fold with zero renumbering, and the rest of
which have real, if narrow, differences (missing words, different digit choices, extra named
types) that a single universal `word+depth -> code` function cannot honor without either (a)
silently changing some site's output number, which requires re-auditing and updating every
consumer of that number, a materially bigger and riskier change than "delete duplicate branches",
or (b) taking a "which vocabulary" selector as a third parameter, which is really "shared word-
matching, N output tables" rather than fable's literal "one function."

Plan: commit 2 folds the two large, already-consistent groups first -- one shared pointer-local
function replacing `l2_ptr_local_ty` + `l2_own_array_pointer_ty` + `l2_typed_formal`'s depth-2
block (3 sites, 0 renumbering), and one shared return-code function replacing `l2_collect_method`'s
inline block + `l2_proto_ret_ty` (2 sites, 0 renumbering) -- fixing the `LmxMsgBlock` bug as part
of touching `l2_typed_formal`, cited separately in the commit. `l2_prim_type_word` becomes a thin
wrapper (or is deleted and its 2 call sites call the shared word-matcher directly, whichever the
actual code shows is cleaner once written). The remaining narrower sites (`l2_const_local_ty`,
`l2_own_array_count`, `l2_own_decl_ty`'s two branches, `l2_slot_decl_ty`) are measured but NOT
folded into the two shared functions in this commit -- each keeps its own narrower table, since
each recognizes a genuinely different (smaller, or differently-numbered) word set on purpose or by
long-standing accident that a byte-identical-output witness can't tell apart from intent without
author input. Reports each clearly rather than silently leaving them or silently renumbering them.

Witness: `dev/l2src_sandbox/tests/*.lm2` (553 files) translated with the pre-commit-2 and
post-commit-2 `l2trans.exe`, diffed byte-for-byte; count reported in the RESULT. A refusal fixture
compares its diagnostic text instead (no L1 generated either way). Mutant: one of the folded call
sites (e.g. `l2_own_array_pointer_ty`) edited to keep its OLD standalone chain instead of calling
the shared function, with one digit changed -- the byte-identical-diff witness must catch it (RED).

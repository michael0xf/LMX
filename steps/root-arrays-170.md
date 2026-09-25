# FABLE-GROKBOT-ROOT-ARRAYS-20260926-170 -- Commit 1 plan (read-only refresh)

Base: origin/main `939bfc8` (integrate sonnet -194 k.5: K-OT1 + K-OT2).
Branch: `fable/grokbot-170-root-arrays-c1`.
Scope of this commit: docs only. No kernel code, no selftests, no GATE?.

Supersedes the Arrays sections of `steps/root-walk-blocks-arrays.md` (old bases
63cc240 / pre-native) for this ticket. Blocks/CATCH content there is untouched
and out of -170 scope.

## 1. Model this plan sits under (landed; do not revive)

From `next_core_tasks.md` §3 (native landing), `steps/native-word-191.md`,
`steps/merge-kernel-194.md`, tip `939bfc8`:

- `Lmx.native` is the native-body word on every Lmx record. Zero => walk.
- CALL node form: `[call, code, data, rtype, args...]`. `rtype` = a plain
  reference to the callee's return cell (not a plan / not METHOD.sig).
- **K-OT1**: OP / role frames are *code*; the copier and `lmx_fresh` keep them
  by address (do not deep-copy into a fresh data instance).
- **K-OT2**: holder operand `0` means *this activation's data* (resolved by
  `lmx_walk_data_holder`). Same rule as AT / PUT / PUT_REF.
- **G-call** (-194 k.4): `lmx_call_prim` walks a native-0 callee with live
  args/data via `lmx_walk_call_prim_dispatch` -> `lmx_walk_activate`.
- Gone (do not use in design or selftests): `lmx_plan`, `LmxCallable`,
  `LmxMethod`, `lmx_own`, `lmx_dirty`, child[0] METHOD descriptors,
  `ARRAY_OF_METHOD`.

Array elements and length are reached by **position** on the Array
descriptor (`{len, data}` / domain type), not by a plan layout.

## 2. Walker roles (kernel half; Commit 2+)

Next free ops after `LMX_WALK_OP_PUT_REF` 24 / `OP_COUNT` 25 (tip). Assign
contiguous codes; bump `OP_COUNT`. Exact numbers chosen in Commit 2.

### ELEM -- element read (expression / call input)

Node form by position (no plan):

`[elem, holder, slot, index]`

- `holder`: Structure that owns the Array descriptor cell. `0` = this
  activation data (K-OT2), same convention as AT.
- `slot`: child index of that Structure holding the Array descriptor ref.
- `index`: size_t (literal from translator for the 10 rows; runtime still
  bounds-checks).
- Yield: a typed value cell for the element:
  - int / size_t / …: numeric cell of the element domain;
  - char: the interned `lmx_char_cell(byte)` (table already live; see §4).

### ELEMPUT -- element write (statement `x[i]: v`)

`[elemput, holder, slot, index, value]`

- Same holder/slot/index as ELEM.
- `value`: typed operand; must match the Array's element type (else INVALID,
  like PUT).
- Store into `descriptor->data[index]` (char stores the byte).

### Length role

`length(P)` at the walked root currently refuses «an array»
(`l2trans.lm1` root builder: `l2_text_eq(t, "length")` -> refuse). Native
methods already lower via `l2_emit_array_length` reading `LmxArrayDesc.len`.

Walker form by position (proposed; Commit 2 locks it):

`[length, holder, slot]`  -- or an operand form that yields `size_t` from the
descriptor at `(holder, slot)`.

- Reads `descriptor->len` only. No plan. Kind-5 own arrays and kind-6
  (Array of refs to Arrays) both expose `.len` the same way; nested
  `length(P[k])` needs ELEM (or an equivalent indexed descriptor load) first
  so the inner Array descriptor is the length target (native already allows
  the inner Array "only inside length()").

## 3. Bounds by the array descriptor

- Runtime: both ELEM and ELEMPUT require `index < descriptor->len`, else
  INVALID. Descriptor identity and element type come from arena classification
  / `lmx_domain_type` of the cell in `slot` (ARRAY_OF_INT, ARRAY_OF_CHAR, …).
- Translator (Opus half): for the 10 rows, indices are in-bounds decimal
  literals (`l2_array_literal`; `08` is decimal 8). That is proof, not a
  substitute for the runtime check.
- Dynamic index (D-39) is out of Commit 2's flip set; same roles should still
  bounds-check when the translator later emits a non-literal index.

## 4. Char arrays via the interned table (D-63 FIXED)

D-63 / F-55 (Sonnet -192 option C): `lmx_array_new_owned`'s ARRAY_OF_CHAR
branch calls `lmx_chars_init(arena)` *before* taking char-array backing;
`lmx_chars_array_order_selftest` pins it. **Not a prerequisite for -170.**

ELEM(char) returns `lmx_char_cell(byte)`; ELEMPUT(char) stores the byte.
Char element literals at the root (`0`, `'\0'`) stay LIT char (typed ops from
-175). No separate char-table ticket.

## 5. The 10 array rows (next-phase-195.md §4)

Class needle: **«an array»**. Count: **10**. What they stop at (examples from
§4): root `[]: char command 8`, `length(m\mainArgs)`.

### 5a. Element / declaration cohort (named measure:
`steps/root-walk-blocks-arrays.md`)

| row | first stop (examples) | success exit |
|---|---|---|
| unit_matrix_path_array_elem | `[]: int buf 3`; then `buf[i]: v` / `buf[1]` | 0 |
| unit_matrix_callable_array_elem | `[]: int buf 2`; elem as call input | 0 |
| entry_array_leading_zero | `[]: char values 10`; `values[08]: 1` | 0 |
| entry_array | `[]: char command 32`; `command[0]: 0` | 0 |
| entry_nul | `[]: char command 8`; `command[0]: '\0'` | 0 |

### 5b. Length / mainArgs cohort (same needle; named in
`steps/root-admit-178.md` / `steps/root-take-179.md`)

| row | first stop (examples) | success exit (fixture intent) |
|---|---|---|
| entry_argc_if | `length(m\mainArgs)` after MainLetter take | 0 (len == 1) |
| entry_index | `length(m\mainArgs)` / `mainArgs[1][0]` | 0 (harness Argv) |
| entry_strcmp | `length(m\mainArgs)` / `mainArgs[1][…]` | 0 |
| unit_entry_args | `length(m\mainArgs)` into `plus_one` | 2 (= len+1) |
| unit_charpp_return | path through `mainArgs[0][0]` (elem of nested) | 0 |

Together these are the 10 named rows that share the class. Exact first-refusal
order on tip may list a sibling name if -178/-179/-196 shifted an earlier
needle; Commit 2 measures the live 10 on `939bfc8` (or successor) before
flipping. Expected process exits above are the fixtures' own success letters.

Also unblocked later (not in the 10): D-39 dynamic own-array index (translator
+ same ELEM/ELEMPUT).

## 6. Translator half (Opus; after kernel roles exist)

From `steps/root-walk-blocks-arrays.md` «What the root emits once the roles
exist», refreshed for the native model:

1. Root own-array decl `[]: T x n` (unit child): still **no walk step** --
   builder already plants the typed descriptor via `lmx_array_new_owned`. Stop
   refusing the statement with «an array»; keep the refuse for non-root /
   unsupported array shapes.
2. `x[i]: v` -> ELEMPUT `[elemput, holder, slot, index, value]`.
   Holder/slot as AT/PUT (`l2_rw_cell`); value via `l2_rw_texpr` at element
   type. Prefer holder `0` when the array lives on this activation data
   (K-OT2).
3. `x[i]` in an expression / call input -> ELEM `[elem, holder, slot, index]`.
4. `length(P)` / `length(P[k])` -> LENGTH role (or equivalent operand),
   mirroring native `l2_emit_array_length` (read `.len`).
5. Element static types (own type -> element): int->int, char->char,
   size_t->size_t, … as in the old table; `command[0]: 0` and `'\0'` are LIT
   char 0.
6. CALL sites that pass an ELEM result stay ordinary CALL
   `[call, code, data, rtype, args…]` (G-call / rtype unchanged).

Witness mutants (Opus + kernel joint): wrong index on ELEMPUT; char array
typed as int; length of non-array refused.

## 7. Commit plan

| step | owner | content |
|---|---|---|
| **c1** (this) | Grok | Read-only plan refresh under the native model. Push. RESULT. STOP for ACK. |
| **c2** | Grok | Walker: ELEM + ELEMPUT + length roles; bounds; char via interned cell; selftests + mutants. No translator. No GATE?. |
| **c3** (if needed) | Grok | Measure/fix the live 10 on tip; any small walker gap the measure shows. |
| **translator** | Opus | Root builder emits ELEM/ELEMPUT/length; admit root `[]:` decls; flip the 10 rows (+ D-39 when ready). |
| **GATE?** | Grok | Only after fable GATE OK. Full gate (build / harness / L3). Texts <= 4 KB. |

Gate rule unchanged: ask GATE? / wait GATE OK (Sonnet and Opus gate too).
Never ACK an ACK.

## 8. Out of scope / blockers for c1

- No kernel or l2trans edits in c1.
- D-63: fixed -- not a blocker.
- D-39, CATCH, root merge, VoidArray: other tickets.
- Frozen `%TEMP%\lmx170` left alone; shared `C:\Nyasha_Planet\LMX` stays clean.

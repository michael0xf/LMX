# Merge by the author's rule, after k.4: k.1, read-only (-193)

FABLE-OPUS-MERGE-PARTS-20260926-193 (Opus), k.1.  Base: main a39fe1b (k.4 and c4 landed).  No code
changes.

The norm is plan §4 «Merge: правило автора» (next_core_tasks.md :358, the author's text of
2026-09-24/25) and §7 «return вложенного callable через merge» (:420).
- The first operand is the model.  A later operand's or body's field that matches a model field
  (same name and type, known to the translator; admission as for an assignment) is written INTO the
  model's slot.  The other fields are appended.
- The result's layout is the model's layout plus the new fields: no model slot moves, and there is
  no hidden offset.
- merge makes no repeated names: `merged\x` is the one slot.
- A callable has the parts `args`/`return`/`body`, and any other Structure is a `body`.  merge goes
  pairwise by parts, recursively, with later operands merged INTO the model.  The unnamed operators
  of an operand's body REPLACE the model's.
- A conversion to a declared callable type is one more merge, `merge(m; fields; header)`.
- A returned nested method is one merge with three operands, `merge(addN; {used values}; header)`.
- A native implementation is not merged.  The result's `native` is 0, so it is walked.  Until method
  bodies have op-trees, a callable merge is a located refusal.

## 1. Already in place after k.4 (measured at a39fe1b)

- `LmxCallable.offset` and the descriptor's COW clone are gone with `LmxCallable` (k.4).
- The `A: fn: M` terminal is the copier's.
  - lmx_graph_copy_owned.lm1 :482-:500: any Structure whose parent lies outside the copied operand
    is kept by address, with its parent unchanged.  This is Q22 = II, generalised.
  - `native` is copied verbatim (:790-:793).
- A merge result's `native` is 0: `lmx_node_new_owned` zeroes it (lmx_merge_owned.lm1 :202-:209).
- The signature is the `args`/`return` parts: c4, form A, in which a method with a header has args@0
  and return@1.
- The kernel has a position map already: `LmxMergePair {model_slot, operand, field}`
  (lmx_merge_owned.h.lm1 :56-:64), used when `overrides != 0`.
  - It is covered by lmx_merge_override_selftest: model {1,2} + {99} with the pair (0 ← 1.0) gives
    len 2 with slot 0 = 99.
  - The translator never passes one: all four call sites (l2trans.lm1 :19937, :19939, :20522,
    :21662) pass `0, 0U`.
- The two witnesses already give the norm's value natively.  Measured inside a method, on a driver
  built from main:
  - q22.md: `R: merge: A` with `A: fn: M` reading `node\tag` gives R\M() = **3** (was 90);
  - q20-next.md §2: A\M(), R\M(), Q\M() all 3 gives **5**.
  - At the walked root both are root-pending («a Structure value»): a merge statement is not walkable
    at the root yet.  See (2d).

## 2. What remains

### (1) The kernel (lmx_merge_owned, a walker primitive)

a. The body as a pair source.  Today `operand >= count` is INVALID and the body is always appended
   (lm1 :99-:108, :319-:337).  A body field that matches a model field must go to the model's slot.
   Proposed: the body is operand `count` in the map.
b. A pair's target is any result slot placed before it: the model's slots, and a field an EARLIER
   operand appended.  «No repeated names» holds across later operands too (`merge: A B C`, B and C
   both new `z`).  Today `model_slot < model_w` only.
c. Map validity.  Two pairs with the same source, or the same target twice, are INVALID; today the
   later one wins silently.  Kind and type are the translator's, which knows them statically.  A
   Structure-typed pair is admitted as an assignment is (implements).
d. The parent of nested Structures.  The copier parents a copied child to the copy of its source
   parent, the operand-root copy.  merge re-points only `result\parent` (lm1 :341).  So a nested
   Structure of the result has an orphan copy as its parent, and a later merge of that result would
   share it rather than copy it (read from the code, not run).  Proposed: re-parent the result's
   children whose parent is an operand-root copy to the result, with a selftest and a mutant.
e. Parts, recursively (callables).  A pair must be able to say «merge this operand part INTO the
   model's part» (args ← args, return ← return, body ← body; in form A the parts are slots 0/1 and
   the rest), not only «store».
   - Proposed: a pair kind «merge into» carrying a sub-map, applied recursively.  That is the same
     operation as Q26.1's `o\inner: a` (merge into the same Structure).
   - Alternative: the translator emits one merge per part and assembles them.  It is more emission
     for the same result.
f. Operators replace.  When an operand's body part has operators (OP frames among its children),
   they replace the model's operators.  Otherwise the model's stay.  This only matters for walked
   bodies.
g. The walked root.  A merge statement at the root needs a walker primitive that takes the operands
   and the map (today only `Model: m` has one, `lmx_walk_merge_model`, with a null map).

### (2) The translator

a. Data merges (`R: merge: A B [body]`, `Model: m`, the unit's typed-occurrence copies):
   - `l2_mrs_build` builds the MERGED layout instead of the flat one.
     - The model's rows come first.
     - Each later operand's and body's field whose name matches a placed row maps to that slot, if
       its type is assignable to the row's type; a type that is not is a located refusal.
     - A new name is appended.
   - The site emits a static `LmxMergePair` array and passes it.
   - `merged\x` is the one slot (`l2_mrs_slot_named` today returns the LAST occurrence).
   - `merged\[N]x` exists only for the model's own repeats (Q24's repeated typed declarations), so
     `l2_mrs_slot_nth` counts over the model's rows only.
   - The checks 71-74, 80, 90, 91 are re-derived from the map: the width is model + appended, and
     the first and last values follow from it.
b. Rows:
   - unit_merge_last_occurrence is rewritten to the override rule: R\x = 7 in the model's slot,
     R\y = 2, and `R\[1]x` is refused «merge occurrence index out of range».
   - unit_merge_occurrence_range_refused: `[1]` is now the one out of range.
   - FrozenA/FrozenB (unit_s1_merge_profiles_uncaught, unit_eternal_multi_profile_merge_refused)
     share `size_t: value`, so the width is 1 and the pinned call carries a map.
   - unit_merged_callable (Q22's hit counter) gets its missing harness row.
   - New rows: q22 → 3 and q20-next §2 → 5, inside a method.  Both are green today.
c. Pieces of the kernel list above: body pairs (1a) and earlier-slot pairs (1b) are needed only when
   a later operand or the body repeats a name the model lacks, or the body overrides the model.
   Everything else is expressible with today's kernel, so (2a) can land first on model-slot pairs.
d. Merge at the walked root, root-pending today (the K3 class, 7 rows of the coverage survey): a
   PRIM step with the map (1g).
e. Callable merge needs walked method bodies.
   - The norm: native bodies do not merge; the result is walked.
   - Today the translator emits an op-tree for the root only.
   - Prerequisite T-OT: every method whose body lies in the walkable subset (L3: numbers, fields,
     calls, if/while, return) also gets its body as an op-tree.  It lives in the occurrence after
     the fields, as code: OP frames are copier terminals, shared by address.  (Not yet: only the role
     records are; see §6, K-OT1.)
   - The native word stays for direct calls.  A merge result has `native` 0 and walks the copied
     tree over its own data.
   - A body outside the subset is a located refusal at the merge.
f. PAP (the author's example, LMX_blog 2026-09-25 :76, plan :331):
   - Source: `fn: add5 (int: x) int merge(y: 5; add)` over `fn: add (int: x; int: y) int return:
     x + y`.
   - add5 = merge(add; {y: 5}; the header of add5): args from the header (x), and y, a formal
     outside the declared signature, bound to the same-name field 5.  The body operators are add's.
   - Its native is 0, so a call of add5 goes through `lmx_call_prim` (dispatch by `native`), not the
     static symbol.  `add5: 1` → 6.
   - Parser/translator: the declaration form `fn: name (sig) ret merge(...)`.
g. makeAdder (§7, plan :696):
   - At `return: addN` in makeAdder, the translator knows addN's free names from the enclosing
     activation (n).  It emits a runtime Structure {n: <current value>} and the three-operand merge
     (addN; {n}; the header).
   - Each call returns a new callable with n as its own field.
   - `[add5: 1; add100: 1; add5: 1]` → `[6 101 6]`.

### (3) The converter (§7): a Structure holding a callable occurrence → a callable

- It is one more merge, at a conversion point: an assignment, argument or result whose target has a
  callable type.
- Source `{n: 5; addN}` (from `merge((n: 5); addN)`, which is not itself callable) against the header
  `fn: (int: x) int` gives merge(addN; {n: 5}; header).
- A source with no callable occurrence, or more than one, is a located refusal, and so is a header
  the occurrence cannot fit.  The translator decides statically, from the declared types.

## 3. Commit plan (kernel ↔ translator)

| # | Who | What | Depends on |
|---|---|---|---|
| K1 | kernel (Sonnet, after -192) | 1a–1d: body pairs, earlier-slot pairs, map validity, nested re-parenting; selftests and mutants | — |
| T1 | translator (Opus) | 2a–2b on model-slot pairs; rows rewritten, witnesses q22/q20 | — (lands before K1) |
| T2 | translator | 2a for body and earlier-slot pairs | K1 |
| K2 + T3 | walker prim + translator | merge at the walked root (1g, 2d) | K1 |
| T4 | translator | T-OT: op-trees for walkable method bodies | — |
| K3 + T5 | kernel + translator | callable merge by parts, operators replace (1e, 1f); PAP (2f) | K1, T4 |
| T6 | translator | makeAdder (2g) | T5 |
| T7 | translator | the converter (3) | T5 |

Open, for fable and the author:
- Q1.  The carrier of part recursion: a «merge into» pair kind with a sub-map in the kernel (1e,
  proposed), or per-part merges emitted by the translator.
- Q2.  Which operators replace: the OP frames among the body part's children (proposed).  A body
  with no operators leaves the model's.
- Q3.  T4 widens the walkable subset from the root to method bodies.  It is the prerequisite of
  everything callable here; is that the intended order, or does the author want the callable
  merges refused until the full L2 body port?

## 4. T1: data merge on model-slot pairs (branch opus/merge-193-t1, base 1889ca1)

fable: «GO T1» with Q1 = no new pair kind (one «merge into» primitive; the translator emits the
parts), Q2 = yes (the operand body's OP frames replace the model's, fields pair up), Q3 = T4 first,
and until then a callable merge is a located refusal.

The translator (l2trans.lm1) builds the MERGED layout in the pre-scan and hands the kernel a pair map:
- `l2_mrs_build` → `l2_mrs_join`, field by field:
  - the model's fields (operand 0) are the first rows, its own repeats included;
  - a later operand's field whose name a model row carries goes INTO that row (the last such row, the
    one `merged\x` names) when its type is the row's: same kind, and the same entry for kinds 2–6
    (nested, reference, callable, arrays).  It becomes a pair (model slot, operand, field) in the
    new source table `l2_msrc_*`, and it takes over the row's known value;
  - any other later field is a row of its own; the body fields come last.
- Refused, located (they need K1, or they are not an override):
  - a later field repeating a name an EARLIER operand added: «a merge operand field repeats a field
    an earlier operand added»;
  - a body field repeating an operand's field: «a merge result body field repeats a field of the
    operands»;
  - a same-name field of another type: «a merge operand field has another type than the model field
    of its name».
- The width is the map's (`l2_mres_width` is set in the pre-scan).  `l2_mres_first/last/fok/lok` are
  gone: each row carries the value the translator knows it holds (`l2_mrs_vk/val`).
- Emission: `c.array: [P]: LmxMergePair l2_mpv` and `c.array: [P]: @: LmxMergePair l2_mpp` beside
  `l2_mops` (P = the most pairs one merge passes, `l2_merge_pmax`).  At a merge with pairs:
  `l2_mpp[k]: @ l2_mpv[k]`, the three fields, and `…, l2_mpp, <P>U, @ l2_mresult)` in place of
  `0, 0U`.  A merge with no pairs keeps `0, 0U` (the kernel's layouts agree then).
- Checks.
  - 71: the width is the map's.
  - 74/75/77/79/80/90/91: each operand field is checked at the slot the map gave it, and only if it
    SURVIVED there (`l2_msrc_at`: no later operand wrote that slot again).
  - 72/73: the first and last slot's known values, from the rows.
- `merged\x` is the one slot.  `merged\[N]x` past 0 exists only for the model's own repeats, since
  the rows have no other repeats (`l2_mrs_slot_nth` unchanged).
- The other merge sites (`Model: m`, the unit's typed-occurrence copies) have one operand, so no
  pairs.

Rows (tools/l2_harness.ps1):
- unit_merge_last_occurrence: rewritten to the override rule and moved into a method (it was
  root-pending, so it never ran): R = {x, y}, `R\x` = `R\[0]x` = 7, the write lands in slot 0, and
  the operands keep 1 and 7.  eternal-runs, Entry 7, with the pair and the call pinned.
- unit_merge_occurrence_range_refused: `R\[1]x` is now the one out of range.
- New:
  - unit_merge_three_operands (B's x and C's x both into Model's x, C's last; B's z added; {3, 2, 9});
  - unit_merge_eternal_pair (FrozenB's value into FrozenA's slot: one slot, FrozenB's retained cell,
    2);
  - the three refusals above, and unit_merge_field_entry_refused (both `at` fields are
    references, to Point and to Size).
- FrozenA/FrozenB: unit_s1_merge_profiles_uncaught pins `…, l2_mprofiles, 2U, l2_mpp, 1U, @
  l2_mresult)`.  unit_eternal_multi_profile_merge_refused (root-pending, Debt not checked) gets the
  same pin.
- unit_merged_callable: moved into a method (it was root-level, root-pending «a Structure value»),
  its BOM dropped, and given its row (Entry 5; checks 77/79 pinned).
- q22 and q20-next §2 inside a method: unit_q22_merge_in_method (3) and unit_q20_merge_in_method (5).

Mutants (private variants, each against unit_merge_last_occurrence unless named):
- no pair found (flat layout): exit 82, and unit_merge_occurrence_range_refused translates;
- checking a field a later operand overwrote: X1 check 74;
- a pair that leaves the model's known value on the row: X1 check 72;
- no kind check: unit_merge_field_type_refused translates;
- no entry check: unit_merge_field_entry_refused translates.

For K1 (the kernel's map validity, 1c): with today's kernel an unpaired later field is APPENDED, so
two later operands carrying the model's name must both be pairs on the same model slot, applied in
operand order (unit_merge_three_operands).  «The same target twice is INVALID» would refuse this.
Either keep taking duplicate targets in order, or give the map a way to say «dropped».

fable (T1 landed, main a952dd5): ordered duplicate targets are legal; K1 records «pairs apply in
operand order, duplicate targets allowed».  The `if: R\x` finding is D-61 (§5 explains why the
spelling decides between a located refusal and gcc).

## 5. T1b: `l2_upper_name`, measured (read-only, main a952dd5)

fable: a spelling name special, which the doctrine (§0) forbids.  The raw door into C is `c.*`, by
token.  An unresolved L2 name is always a located refusal, and C constants come as `c.NAME`.
Measure before changing anything.

### What it is

l2trans.lm1 :9240-:9254.  An atom of `[A-Z0-9_]` with at least one capital is «a constant supplied
by a predef C seam», and the translator leaves it to the C compiler.  It has two call sites, and
nothing else calls it; no kernel `.lm1` has one.
- :13641, the expression atom check.  It admits the atom before any L2 lookup: formal, method,
  local, own field, declaration or merge result.
- :7004, `l2_scan_ident`, the free-name scan.  This scan makes an unresolved name a dynamic input of
  the method, and it marks the unit fields a method reads (`l2_own_unit_seen` → `l2_m_uses`).  The
  all-caps return comes BEFORE that marking.

### What else it does: two defects, measured on scratch builds of main

- A unit field with an all-caps name, read in a method, reaches gcc.
  - Program: `int: N 5` in the unit, `k: N + 1` in method m.  It is emitted as a raw `N`, and gcc
    stops with «'N' undeclared».  The same program with `nn` runs, and gives 6.
  - :7004 skips the use marking, then :13641 passes the name on.
  - With both sites off the program runs (6).  With only :7004 off it runs (6).  With only :13641
    off it gets a located «unresolved name».
  - An all-caps OWN field of the method (`int: N 5` inside m) is not affected (6), because other
    paths find it.
- D-61's `R\x`: an all-caps merge-result name in an expression reaches gcc, and a lowercase one gets
  a located «unresolved name».  It is the same rule.

### Who relies on it

Dynamic measurement:
- Every tracked `.lm2` (1012 files) was translated by main's translator and by three variants:
  both sites off, only :13641 off, only :7004 off.  The outcome compared was the exit code, the
  first error, and a hash of the output.  Of the 1012, 419 translate and 593 are refused for other
  reasons.
- One file changes: unit_define_actual.lm2, plus its copy under l2src/tests.  With the rule off,
  PROBE_DEFINE_LABEL/_FG/_OK (the `define:`s of its predef) get «unresolved name»:
  - with :7004 off, as an unresolved dynamic input;
  - with :13641 off, at the atom check.
- No harness row changes.  unit_define_actual has no row, and none of the 370 rows uses a bare
  all-caps constant.

Static scan: code only (no comments, strings, `end:` lines or declarations), all 1012 files.
- The gated tree (dev/l2src_sandbox and its l2src copy):
  - PROBE_DEFINE_* ×3: a predef `define:`, in an expression.
  - PROBE_UNIT_LABEL: the unit's own `define:`, in an expression.
  - L2_TEST_OWN_COUNT (a predef `define:`) and L2_TEST_UNIT_COUNT (the unit's own): own-array
    COUNTS.  These resolve through `l2_define_count`, not this rule, and are unchanged dynamically.
  - Every other all-caps token is an L2 name: a Structure or merge-result name such as A, B, R, Z2,
    E0..E69.
- dev/mixa_sandbox is not gated, and 50 of its 54 `.lm2` files are refused today for «unknown type»
  before any atom is checked.  Its uses:
  - 1084 of names a predef `define:` declares;
  - 88 of its own `define:`s;
  - 914 uses (247 file/name pairs) of names declared nowhere in the repo.  These are C constants and
    types from system or C headers (e.g. WIN32_FIND_DATAW), which only `c.NAME` can name.

### Migration

(a) The declared constants: `define:`, which is L1 that l2trans passes through (`l2_take_define`).
    The translator already reads them:
    - the unit's own `define:`s, in `l2_def`;
    - the predef chain's, through `l2_predef_file_define`, used today only for own-array counts
      (`l2_define_count`).

    Generalize it: an atom that names a `define:` of the unit or of its predef chain is admitted at
    both sites.  That is the resolution of a declared name, not spelling.  unit_define_actual needs
    no change, and neither do mixa's 1172 uses of declared names.

    The other way is `c.NAME` for these too.  That touches 4 gated sites and about 1170 mixa ones.
(b) Any other name that no L2 declaration and no `define:` names gets a located «unresolved name».
    C-only names go through the raw door `c.NAME`.  That is mixa's 914 uses, and 0 in the gated
    tree.
(c) `l2_upper_name` goes, at both sites, in the same commit as (a).
    - Rows: the all-caps unit field read in a method gives 6 (today gcc); unit_define_actual gets a
      row; D-61's `R\x` gets a located refusal until D-61 itself lands.
    - Mixa's move to `c.NAME` is separate work: mixa is not gated, and its sources are behind on
      types too.

Q6 (fable/author): is a `define:` name, the unit's own or a predef's, a declared name the translator
resolves (a)?  Or does everything that is not L2 go through `c.`?  I recommend (a): the translator
already treats these names as declarations for array counts.

## 6. T4 k.1: op-trees for walkable method bodies (read-only plan)

### Facts (main a952dd5)

- The walker already runs a walked callee.
  - CALL `[call, code, data, rtype, args...]` dispatches on `code\native`.  When native is 0 it
    calls `lmx_walk_activate(code, data, refs, n)`.
  - ARG k reads the k-th reference passed in.
  - OWN, SET and PUT read and write the cells of `data` when the holder is the activation's code
    (`lmx_walk_data_holder`, lmx_walk.lm1 :479).
  - RET hands back a value.
  - The arity is the highest ARG k + 1 (`lmx_walk_arg_arity`), checked when native is 0.
  - The body is the OP frames among the code Structure's DIRECT children.  `lmx_walk_body` scans
    from slot 0 and skips non-op slots: header parts and own fields.
- `lmx_call_prim`, the dynamic call from native code, walks a native-0 callee only if it has no
  args and returns int, and it ignores data (lmx_call.lm1 :155-:169, «stays nullary until k.4»).  A
  native caller of a walked method with args is a kernel gap, G-call below.
- The root's op-tree is built by `l2_rw_*`: l2trans :16753-:18620, 49 functions, in two passes
  (count, then emit from `l2_rw_base` into the unit).  Only 9 lines name the root's holder
  (`l2_entry_unit`): the OWN holder, the CALL code and data refs, and the PRIM owner.
- A method occurrence (form A, `l2_emit_parts` :20948): args@0, return@1 (the result cell), own
  fields from slot 2 (`l2_own_mslot`), width `l2_m_kids(i)`, native = `<sym>_tr`.
- A correction to §2(2e): only the role RECORDS (LmxOp, `LMX_DOMAIN_KIND_OP`) are terminals for the
  copier and for `lmx_fresh`.
  - An OP FRAME is an ordinary Structure (`lmx_walk_plain` → `lmx_struct_new_owned(parent)`).
  - So frames whose parent is M are deep-copied by `lmx_fresh` on every re-entry («Control-body /
    field-only Structure whose parent is the prototype: recurse», lmx_fresh.lm1 :49-:57).
  - Any merge that copies M copies them too.

### (1) Which bodies

- At run time a method body is walked only when a CALL reaches an occurrence whose native is 0.
  - Today every method's native is its trampoline, and a Structure merge keeps `A: fn: M` by address
    (Q22 = II).  So nothing walks a method body yet.
  - The first need is T5: the result of a callable merge (native 0 by the kernel), whose body is the
    model operand's frames (Q2).  Then T6 needs addN's frames, and T7 the frames of the converter's
    callable occurrence.
- implements needs no op-tree: `lmx_implements` compares structure and never interprets.
- Proposal: emit the op-tree of EVERY method whose body is in the walkable subset, always.
  - The native word stays, so direct and dynamic calls stay native.
  - The graph then carries each method's code, as the doctrine says (one graph = code + data), and
    T5 only picks the frames.
- Alternative, for smaller graphs: only the operands of a callable merge (none before T5), plus a
  test knob.
- I recommend «always» once K-OT1 below is in.  Without it, every re-entry copies the frames, which
  argues for the alternative.
- A method outside the subset gets no frames.  That is not a refusal: the refusal comes where a walk
  is needed, at T5's merge site («a callable merge needs a walkable body: <class>»).

### (2) Emission form, beside the native entry

- The frames are M's own children after its own fields, from slot `l2_m_head` + own count.
  `l2_m_kids(i)` grows by the step count.  No field slot moves, so the native code (direct cells by
  slot) is unchanged.
- They are built in the program build right after `l2_emit_parts(i)`, by the `l2_rw_*` builder
  parametrized by the method:
  - holder = M's occurrence (`lmx_arena_ref_struct(l2_entry_unit, l2_unit_base + i)`) instead of
    the unit, or no holder (K-OT2);
  - own slot = `l2_own_mslot`;
  - formal j → ARG j;
  - `return: V` → RET V.  The root rewrites value returns into tails; a method keeps them.
  - CALL passes the callee as data, or FRESH on re-entry (`l2_reenters`), as the root does.
- The `l2_rw_*` state is global (`l2_rw_n`, `l2_rw_base`, `l2_rw_steps`), so it becomes per method.

### (3) The operator subset

- The subset is the root's: the walker's roles LIT, OWN, AT, PUT, SET, the arithmetic and
  comparisons, IF, WHILE, OF, DEREF, PUT_OF, PUT_REF, PRIM, CALL, FRESH and RET.  Methods add ARG
  and RET V.
- The classes the root still refuses stay out, and such a method gets no frames.  From the needles
  of the root-pending rows:

  | Refused class | Rows |
  |---|---|
  | arrays | 10 |
  | Structure values (root merge; T3) | 9 |
  | throw and catch | 7 |
  | field paths | 4 |
  | non-number call inputs | 4 |
  | loops | 3 |
  | conversions | 2 |
  | admission | 2 |
  | dynamic inputs | 2 |
  | `&&` and `\|\|` | 2 |
  | strings | 1 |
  | reference assignment | 1 |
  | non-number results | 1 |
  | other | 1 |

- A Structure formal: ARG gives the reference, and OF or DEREF read through it.  Callable formals
  stay out at first.

### (4) Kernel dependencies (the walker is Sonnet's, after K1)

- K-OT1: OP frames are code.  `lmx_fresh` and the copier keep them by address: structurally, a
  Structure whose child 0 is an OP role record.  Then a re-entry's fresh data and a merge copy carry
  no copy of the code.  Mutant: a frame copied per re-entry.
- K-OT2: frames shareable between occurrences of the same layout.
  - The problem: T5 hands the model's frames to the merge result R.  Their OWN holder is M, but the
    running code is R, so `lmx_walk_data_holder` does not map M to data.
  - Proposal: the method's own-field frames name no holder, meaning «this activation's data»: an
    OWN/SET/PUT form without a holder, or holder = 0.  That is exactly what makes the model's frames
    valid on R, because merge keeps every model slot in place (§4).
  - If the kernel takes that form, T4 emits it from the start.  Otherwise T4 emits holder = M, and
    T5 has to rebuild the frames.
- G-call: `lmx_call_prim` walking a native-0 callee with args, data and a typed dest (today it is
  nullary, int and ignores data).
  - It is needed once native code dynamically calls a walked result, e.g. T5's `add5: 1` inside a
    method body.
  - The walker's own CALL already does this.
- Structural consumers that iterate an occurrence's children will now see frames:
  - a method occurrence's merge width, which only matters in callable merges (K3);
  - implements, which compares parts (to verify on a row);
  - harness check 79 (first own child) is unaffected.

### (5) Witness and fixture volume

- A differential run.  A translator knob (`--walk-methods`, test only) sets native = 0 on every
  method that has frames.
  - The root's CALLs then walk those methods, while native-to-native calls stay native.
  - Every eternal-runs row runs both ways and must give the same exit.  139 of the 160 eternal-runs
    rows declare methods (261 methods in all).
  - A method outside the subset keeps its native, and the build says so.
- Direct rows: a method with formals, own fields, a value return, recursion (FRESH), a loop, and a
  call chain.  The rows for the refused classes come with T5.
- Mutants: ARG off by one; RET without its value; the unit as OWN holder; re-entry without FRESH.

Order:
1. K-OT1 and K-OT2 decided (Sonnet, after K1 or with it).
2. T4a (translator): `l2_rw_*` parametrized by method, frames after the fields, the knob and the
   differential run.
3. T4b: the direct rows.
4. G-call before T5.

Questions:
- Q4: emit always (recommended, with K-OT1), or only for merge operands plus the knob?
- Q5 (K-OT2): holder-less own-field frames («this activation's data») as the form for a method's own
  fields?

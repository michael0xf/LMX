# The code/data split in the native translator: commit 1, read-only (-189)

FABLE-OPUS-CODE-DATA-SPLIT-20260925-189 (Opus), commit 1.  Base: origin/main 14472de.

The model is in next_core_tasks.md §3 «Пара исполнения code/data», q27.md, L2 §10-§11,
LMX_semantics.ru.md §11-§12 and CORE.md §3.
- An execution is two Structures: code, which is immutable, and data.
- An activation is a fresh instance of the data prototype, in the lexical parent's data slot for
  this callable.
- Formals, locals and the result belong to the machine activation.  An argument is a data field
  only by L3 §12's bare assignment, or by binding through merge.
- The native ABI is `(node, self) = (data\parent, data)`.

This file measures the translator as it is (l2trans.lm1 at 14472de, 22 077 lines) and lays out the
split.  Every choice is marked as proposed or open.  No code has been written.

It replaces steps/native-cells-189.md (branch opus/cells189, not continued).  That file's census is
in «Removal sites» below, with its line numbers moved to 14472de.

## 1. The callable Structure today, and its two graphs

### The unit

The unit is E's occurrence (the program's entry).  Its children, in order (l2_emit_unit :20930; the
layout comment at :9144 and the `kids` computation near :21474):

| children | what | role in the pair |
|---|---|---|
| 0 | E's LmxCallable | code (a descriptor) |
| 1 .. | E's own fields, in lexical order (own rows with `l2_own_mi = l2_e`, `l2_own_host = 0`, slot `l2_own_uchild`), then E's control bodies (`l2_for_uchild = 1 + own count + rank`) | data |
| `l2_unit_base + i` | method i's occurrence M | code and data mixed (below) |
| then | eternal branches (`l2_ebr_n`), merge results (`l2_mres_base`), named Structures (`l2_ns_base`), the Thread's children, the settings | data |
| `l2_rw_base` .. | the walked root's step nodes (l2_rw_*) | CODE, stored among the unit's data fields |

### A method occurrence M

The builder makes it once (:21573 «One ordinary Structure per callable occurrence»; the descriptor
at :21713-:21745):
- child 0 is an LmxCallable → LmxMethod `{addr, sig}`.  `addr` is the method's trampoline, `<sym>_tr`,
  or 0 for a bodiless `fn`.  This is code.
- Children 1 .. are M's unhosted own fields in lexical order (the same own-table rows, `l2_own_mi =
  i`), then M's control bodies.  A control body is a Structure whose children are its hosted own
  fields (`l2_own_fid` / `l2_own_fchild`, reached as `l2_h<fid>`).  This is data.
- The operators are the native C function `l2_m<i>`, immutable.  This is code.

### Named Structures

l2_ns, at `l2_ns_base + rank`, and nested ones inside their owner:
- They are data: fields filled by the builder (:21752 on).
- A callable field (kind 4) holds a reference to a callable occurrence, today an M.
- A named Structure executed as a bare atom has no native body of its own: the translator refuses
  «executing a named Structure is not supported yet» (:14057).

### The split, measured against today's tables

- M's data prototype is today's M minus child 0.
  - The own table is already the prototype's slot table: `l2_own_uchild` (the slot in M),
    `l2_own_fid` / `l2_own_fchild` (the slot in a control body), `l2_for_uchild` (the control body's
    slot).
  - Occurrences are already separate rows: a second declaration of a name is a second row (Q22.2 /
    Q24; `\[N]x` is l2_own_find_occ).
- Formals.  A formal gets an own row only when it is bound: argument-as-own, -67; `l2_own_param_of`
  and `l2_m_alias`; the row exists when the body assigns or declares the name.
  - That is L3 §12's rule («полем экземпляра он становится только при направленном в него голом
    присваивании»), so the prototype takes exactly those rows.
  - Every other formal stays the C parameter `l2_p<mi>_<fi>`.
- M's code is child 0's descriptor, the signature (`l2_method_sig_text`) and the C function.  Natively
  nothing in it is written by execution.  The one exception is the walked root, whose steps sit among
  the unit's data children.
- The unit's data is children 1 .., the method slots, and the tail except the root's steps.  The unit's
  code is E's descriptor and the root's steps.

OPEN (commit 4 below): once M's slot holds a data instance, where does M's code live?
- (a) A parallel code tree: the unit's code Structure, holding each method's code as a child.  Data
  nests like code, and both trees keep the same shape.
- (b) The instance's child 0 keeps a reference to its code descriptor.
- The model says data has no operators and code is «a Structure with the descriptor at child[0]»,
  which reads as (a).
- Direct native calls do not need either: the symbol is static.
- Dynamic calls do: a callable field (kind 4), `lmx_call_prim` through the trampoline, and
  `someCode(someData)`.

## 2. Removal sites

Counts from n159/sites.py at 14472de: lines of each function that mention a pattern.

| pattern | lines | functions |
|---|---|---|
| `_dirty` | 22 | 5: l2_emit_unit 12, l2_emit_stmts 5, l2_emit_checkpoint 3, l2_emit_occ_write 1, l2_emit_finalize_old 1 |
| `checkpoint` (any mention) | 42 (+1 prototype) | 19 |
| `l2_emit_checkpoint(` calls | 17 | 10: l2_emit_call 3, l2_emit_stmts 3, l2_emit_ret_tr 2, l2_emit_unit 2, l2_prep 2, l2_emit_ccall, l2_emit_fnptr_call, l2_emit_implicit_throw, l2_emit_throw, l2_hidden_from |
| `l2_emit_own_from(` | 7 | l2_emit_stmts 5, l2_emit_occ_write, l2_emit_bind_mark |
| `l2_emit_occ_write(` | 8 | l2_emit_stmts 6, l2_emit_handler 2 |
| `l2_emit_cell_load(` | 6 | l2_emit_fields 2, l2_emit_path_load, l2_field_path_read, l2_hidden_from, l2_mrs_occ_read |
| `l2_q%d` (any spelling) | 72 | 18 |
| `l2_q%d_from` | 40 | 6: l2_emit_unit 20, l2_emit_own_reload 7, l2_prep_addr 6, l2_emit_checkpoint 3, l2_emit_stmts 3, l2_emit_own_from |
| `l2_q%d_sticky` / `l2_q%d_active` | 5 / 7 | l2_emit_unit, l2_emit_checkpoint, l2_emit_finalize_old, l2_emit_addr_mark, l2_emit_occ_write, l2_emit_bind_mark |
| `l2_p%d_%d` (formals: they stay) | 52 | 12 (l2_emit_formal 26) |
| `l2_m_uses` | 98 | 30 |

The pieces:

| piece | where | today | after the split |
|---|---|---|---|
| the prelude | l2_emit_unit :21309-:21377 | per used own field: `l2_q<k>` (value), `_from` (slot), `_dirty`, and `_sticky` / `_active` for an address-taken bound argument; the value loaded from the cell | gone.  A slot handle may stay (address only, not a value): see §3 |
| a write | l2_emit_occ_write :6519; l2_emit_stmts :20269, :20281, :20397, :20431, :20434 | `l2_q<k>: v` (or the parameter, for a bound argument), `_dirty: 1` | a typed store into self's cell: l2_own_store_helper / l2_own_store_value, today's checkpoint store moved to the write |
| binding the slot | l2_emit_own_from :6478, over l2_own_from_expr :6469 | `_from: lmx_arena_ref_cell(ctr, uchild)` once, X1 if absent | the cell of the instance: the same expression, with `self` the instance |
| publication | l2_emit_checkpoint :18711 (17 calls) | dirty or sticky fields stored into their cells, X1 invariants «checkpoint lost / store failed» | gone: a write is already in the cell |
| reload | l2_emit_own_reload :18800 | after a checkpoint, read unit fields back | gone |
| the sticky rule (-67) | l2_emit_finalize_old :6495, l2_emit_addr_mark :6545, l2_emit_bind_mark :6557, l2_canon_spell :6448 | a canonical working value; `active` selects the publication target | gone: `@x` is the cell (L2 §10: «ячейка стабильна на время жизни экземпляра, липких отметок и перенацеливания нет») |
| a read of a working value | l2_prefix_deref :7759, l2_index_token :7947 and :7993, l2_hidden_from :14682, l2_prep :15335 and :15362, l2_emit_fields :16109; `c.sizeof(l2_q<k>)` l2_sizeof_name_bytes :15048; l2_emit_own_pointer_temp_decl :8682 | `l2_q<k>` | a typed load of the cell (l2_emit_cell_load :14634 is it, into a temp; inline as `lmx_int_value_known(<cell>[0])` inside an expression).  sizeof becomes the own type's size |

Already cell-true, with no copy:
- `@x` of an own field: l2_prep_addr :14866-:14879, `(cast: (@: T) l2_q<k>_from[0])`.
- A path or hosted read: l2_emit_path_load, then l2_emit_cell_load.
- The receive and rebind stores through `_from[0]`: l2_emit_stmts :20581, :20689, :20803.

`l2_m_uses` (98 lines) is the per-(method, own) «touches» set.  Its prelude and checkpoint roles go.
What remains is its use set:
- `@x` legality: l2_check_addr :14781;
- the dynamic-input steps (l2_dyn_step, l2_dyn_local);
- the reservation (l2_own_reserve, l2_meth_reserve, l2_own_free).

## 3. The native activation

A call site today (l2_emit_call :15580, direct: `l2_m<i>(l2_c<t>\parent, l2_c<t>, args...)`; dynamic:
l2_emit_dyn_call :16510, `lmx_call_prim` through the trampoline :16553, `l2_self = owner`) selects
the occurrence `l2_c<t>` and passes it as `self`.  Under the pair:
- The instance.  A fresh instance of M's prototype is built as today's builder builds M's own
  children (:21589-:21700), for each call:
  - `lmx_struct_new_owned(node, arena)`, then `lmx_arena_refs_open_owned`;
  - one typed cell per own row: int, char, size_t, unsigned, ulong, pointer, arrays;
  - the control bodies as nested Structures with their hosted cells;
  - then `lmx_arena_ref_store(node, M's slot, instance)`, a direct slot: an own child, as in «Две
    формы».
  - Proposed: one generated `l2_new<i>(node)` per method, called at the call site.  It is the
    `Model: fresh` of M's prototype, the same layout code the builder uses once today.
- The ABI stays `(node, self, args...)`, with `node = l2_c<t>\parent` (the parent's data) and
  `self` = the new instance.
- The trampoline (dynamic calls, and the walked root's CALL):
  - `owner` is today the occurrence.  Proposed: the trampoline builds the instance itself in
    `owner`'s slot, callee-side, so the walker's CALL does not change.
  - A caller that supplies data (merge-bound, `add5: 1`) is §6's case, and it is not native today.
- Own reads and writes are typed loads and stores on `self`'s cells (l2_own_from_expr already
  spells `lmx_arena_ref_cell(self, uchild)`).
  - A slot handle per used field, `@@: void` bound once per activation, may stay as an address
    cache: the slot's address is stable for the instance's life; a char rebinds the value in the
    slot, and a read goes through `[0]`.
  - Or the expression is computed at each access.  Proposed: keep the handle; it is not a copy of
    a value.
- Arguments, temporaries and the result stay C parameters and locals (`l2_p<mi>_<fi>`, `l2_t<N>`).
  An argument bound by §12 is initialized in its field at its binding line (§4 below).
- OPEN, cost:
  - Every call allocates an instance in the program's arena, which does not reclaim.  A loop of N
    calls leaves N - 1 unreachable instances, because the slot shows only the latest.
  - The model allows reusable frame storage for machine state (L3 §11), but an instance is graph.
  - Reclaiming the previous instance when nothing else references it needs a liveness answer.  That
    is Grok's and the author's; a first build may accept the growth and measure it.

## 4. The three rows whose facts are the argument/field distinction

- unit_arg_addr_sticky, unit_arg_addr_dynamic and unit_occ_sticky_selector print
  «<case> <local> <graph field>».
- The facts depend on two readings the model leaves to be named:
  - R1: a bound argument is its data field from entry: one cell, initialized with the actual.
  - R2: before its binding line, the name is the machine argument; the field exists in the
    prototype, and the binding line writes it (L3 §12: «полем экземпляра он становится только при
    направленном в него голом присваивании»).
  - The binding line here is a declaration without an initializer (`int: na`).  Today it carries
    the argument's current value into the field (A1 is 6 = 5 + 1).  «Carry» names that.
- Proposed: R2 with carry.  It matches L3 §12's text, and it is the only reading under which every
  line not preceded by a graph write keeps its fact.  The plan names exactly that as the exception:
  «порядок публикации в липких фикстурах -67, где теперь видна живая активация».

Under R2 with carry the lines that change are those printed after `M\x: v` writes a bound name's
field.  Today a sticky checkpoint republishes the working value over v; under the pair the name IS
the field.

| row | today (Says) | under the pair (R2, carry) |
|---|---|---|
| unit_arg_addr_sticky | A1 6 6, A2 6 6, A3 9 9, A4 9 9, B 5 100, B 5 100, B+ 6 6, B 5 100, C1 4 4, C2 9 9, C3 9 9, D1 6 6, D0 5 5, E 6 6 | A1 6 6, **A2 100 100**, A3 9 9, **A4 200 200**, B 5 100, B 5 100, **B+ 200 200**, B 5 100, C1 4 4, C2 9 9, **C3 100 100**, **D1 100 100**, **D0 100 100**, **E 100 100** |
| unit_arg_addr_dynamic | IA1 6 6, IA2 6 6, IA3 9 9, IA4 9 9, IB 5 100 ×2, IB+ 6 6, IB 5 100, IC1 4 4, IC2 9 9, IC3 9 9; the same Z lines; CALLER 3 3 3 3 3 3 | IA1 6 6, **IA2 100 100**, IA3 9 9, **IA4 200 200**, IB 5 100 ×2, **IB+ 200 200**, IB 5 100, IC1 4 4, IC2 9 9, **IC3 100 100**; the same for Z; CALLER 3 3 3 3 3 3 |
| unit_occ_sticky_selector | BEFORE 1 1, AFTER 9 9, NONE 7 100, NONE 7 100, NONE+ 1 1 | **BEFORE 100 100**, **AFTER 100 100**, NONE 7 100, NONE 7 100, NONE+ 1 1 |

- The `5 100` and `7 100` lines stay.  Before its binding line the name is the machine argument,
  which `@x` wrote, while `M\x` wrote the field.  They are L3 §12's two places, not working copies.
  This corrects native-cells-189.md, which said those lines could not keep their facts.
- Under R1 they become `100 100` too.  Under R2 without carry, A1 becomes `1 1`, and every line
  after a declaration-binding follows the prototype's 0.
- A field whose declaration did not run in this activation (a branch not taken) holds the
  prototype's initial value in a fresh instance.  None of the three rows observes it: each skipped
  declaration's field is written through `M\x` before it is read.
  - Plan §3 item 7 asks for it at landing.  Proposed: a probe at commit 3.  A method whose `if`
    declares a field is called twice, taken then not taken, and `M\x` is read after the second call.
    Today it shows the first call's value; under the pair, the prototype's.

## 5. Dependencies

- Native methods do not depend on Grok -186 (PUT_REF) or -188 (the walker's split).
  - Native code stores the instance with lmx_arena_ref_store directly.
  - The walked root reads and writes its own fields as cells of the unit with AT and PUT (-159 F4),
    and the unit's data keeps those slots.
  - The root calls native methods through `lmx_call_prim` and the trampoline, which builds the
    instance callee-side (§3).
- So the native activation (§3) and the removal (§2) can land before -186 and -188.
- -188 is the walked root's own copies (LmxWalkOwn, 21.5/21.6) and interpreted methods.
- The root's step nodes leaving the unit's data (§1) belong with -188 and the code tree (commit 4).
- -183 c4 and -184 (PUT_REF / ELEM on the walked root) are independent of this, except for a rebase.

## 6. Commits (proposed), each gated by fable (one gate on the machine at a time)

- c1: this file, to main after the ACK.
- c2: the fresh instance.
  - A per-method `l2_new<i>` builds M's prototype.
  - The call site and the trampoline build the instance in the parent's slot and pass it as `self`.
  - The working copies stay for now.  The prelude binds `_from` to the new instance's cells, so the
    facts are unchanged except the not-taken-branch probe.  That probe is added as a row with its
    measured fact.
  - Mutant: pass the old occurrence instead of the new instance.  A recursion row that reads `M\x`
    goes RED.
- c3: no working copies.
  - Reads and writes go to the instance's cells.
  - The checkpoint, publication, reload, dirty, sticky and selector go, along with the prelude's
    value declarations.
  - The three rows' Says change to §4's table (with fable's and the author's word on R2 and carry).
  - The Debt and Absent pins re-pin.
  - Mutant: a write that misses the cell makes a cross-method `M\x` read RED (fable's).
- c4: the code tree.
  - The descriptors leave the data slots (§1 (a) or (b), decided first).
  - Dynamic calls take the code.
  - The root's steps leave the unit's data, with -188.
- The rows that pin -189's text (fact-neutral), from n159/pins189.py:
  - the sticky and selector declarations in unit_arg_addr_sticky, _types, _pointer, and in
    unit_occ_sticky_selector / _snapshot_selector;
  - Absent `l2_q0_early` and `l2_q0_bound`;
  - the `_from` binding in unit_occ_arg_slots;
  - the checkpoint store in unit_arg_addr_types, _pointer, _dyn_types and unit_char_own_publish;
  - the checkpoint invariants in unit_struct_int_field (root-pending on main; my -183 c4 WIP
    re-pins it);
  - `l2_q<k>` spelled into calls and assignments in unit_s2_vis_dynamic, unit_recursion,
    unit_nested_body_for and unit_fnptr_noncallable_assign.

## Spec notes found on the way (for fable)

- LMX_semantics.ru.md §12 is rewritten at its start (the instance field, no working copies), but
  still keeps the old model further down.
  - The paragraphs «Перед передачей управления … публикуются только собственные рабочие поля с
    активной отметкой dirty», «dirty определяется выполненной записью …» and «рабочее голое x … может
    сохранять прежнее значение».
  - «Стек активаций…» with «отметками dirty».
  - The recursion trace table (clean/dirty columns, «Опубликованное S.x»).
- CORE.md §3.1's last paragraph says `@fresh` addresses «the slot holding that reference (conceptually
  `Lmx **`)».  Q26.2 = (B) (2026-09-25) made `@` of a Structure binding the Structure's address.

## Commit 2: a fresh instance per activation

Built on origin/main 20dc61a.  The working copies stay; commit 3 removes them.

What is built:
- `l2_emit_cell_new` makes one fresh typed own cell into `<slot>[0]`.
  - The builder's two type ladders (unhosted own fields, and hosted ones in control bodies) now use it.
  - Checked text-neutral: all 353 fixtures translate byte-identical to the translator without this
    commit.
- `l2_emit_fresh` emits `l2_new<i>(node)` for each native method with data fields (`l2_m_kids(i) > 1`).
  It lays out method i's data prototype anew:
  - the shared callable descriptor goes into child 0 (the code, until c4 takes it out);
  - each own field gets a fresh typed cell;
  - each control body gets a fresh Structure holding its hosted cells;
  - a char field's first cell is the interned 0, found from the instance being replaced
    (`lmx_char_rebind_known`).
  - It stores the instance into the unit's slot answering i (`l2_unit_base + i`), which shows it from
    then on, and returns it as `self`.
  - A failure to make it is X1.
- A call by name (sel 0) runs over `l2_new<idx>(node)`.
- The trampoline (dynamic calls, and the walked root's CALL) makes the instance callee-side:
  `l2_self: l2_new<i>(l2_self\parent)`.  The walker needs no change.
- A method with no data fields keeps its occurrence: there is nothing to lay out.
- A call through a path (sel 1) keeps the selected occurrence until c4.  No row needs more (the
  per-row check below).

New row: unit_fresh_instance_skipped_decl (Entry 70).
- After keep(1), the slot shows its instance: `keep\v` is 7.
- keep(0) returns before `int: v 7`, so its fresh instance keeps the prototype's 0 (plan §3 item 7):
  7 * 10 + 0 = 70.
- The translator without this commit gives 77 (a shared occurrence).
- Mutant F1: the instance is made, but the activation runs over the occurrence the slot held before
  (n159/mkc2m.py).  It gives 0: RED.

Per-row check of all 354 rows (fable's gate, verify2b on this tree):
- 0 red; eternal-runs 150 (148 + 2 argv rows) = main's 149 + the new row.
- No existing row changed its facts.  The three sticky and selector rows keep today's Says in c2,
  because the working copies publish into the activation's own instance, which is also what the slot
  shows.  Their §4 Says come with c3.

## Commit 3: the plan after the author's Q28 and Q29 (main b7b7b99)

The decisions (plan §3 items 1-4 and 7, §4 Q29; L2 §10; L3 §11/§12; CORE §3/§3.1):
- One graph may be both code and data.  An ordinary call runs M over its own graph, (M, M); the root
  runs as (R0, R0).  Code stays immutable in its operators, literals and `native`; execution writes
  only declared fields.
- Q28: a fresh prototype instance is made only where the translator cannot rule out re-entry
  (recursion in the static call graph, a dynamic call by reference) or where data is passed
  explicitly.
  - It lives in the activation's frame and is not visible from outside.
  - `M\x` from outside reads M's own fields.
  - A field whose declaration did not run in this activation keeps the previous activation's value.
- Q29: one cell per declaration.  A repeated bare assignment writes the same cell, and `\[N]` numbers
  declarations.

So c2's `l2_new<i>` on every call becomes the exception, not the rule.  c3 is planned as three
commits, each gated:

### c3a: M over its own graph; a fresh instance only on re-entry

- A call by name, and a call through a path (sel 1), pass the occurrence itself as `self`, as before
  c2.
- `l2_new<i>` stays, with two changes.  It no longer stores into the parent's slot, because a
  frame-only instance is not visible outside; its parent stays `node` for `node\x`.  And only these
  call sites use it:
  - Recursion in the static call graph: a call site in method j that calls i, where i and j are in
    one strongly connected component (i = j included).  The translator knows every direct call
    (sel 0 and sel 1 with a static callee).  The first entry into the cycle from outside runs over M
    itself; each re-entry from inside the cycle gets a fresh instance.
  - A dynamic call by reference: a callable formal, `lmx_call_prim` through the trampoline.
- OPEN, for fable and Grok (-188): the trampoline is also how the walked root's CALL enters a native
  method.  The trampoline cannot tell a static CALL (which should run over M) from a call by
  reference (which should get a fresh instance).
  - (i) The caller chooses the data and passes it as `owner`.  But a dynamic native caller does not
    know the callee's prototype, so it would need a kernel entry that makes one from the callee.
  - (ii) Every trampoline entry gets a fresh instance, the root's CALL included.  `M\x` then does
    not show a root-called activation.  The rows measure whether any row reads it.
  - (iii) Two entries: `<sym>_tr` over `owner`, and a fresh-instance entry for calls by reference;
    that needs a place for the second address.
  - Proposed: measure (ii) first, since it needs no kernel change, then decide.
- The probe row unit_fresh_instance_skipped_decl returns to 77: over M's own graph, keep(0) leaves
  keep(1)'s 7 (plan §3 item 7).
- A new row, unit_recursive_fresh_instance.  A recursive method declares `int: x n` and recurses
  before it reads x.
  - With a fresh instance per re-entry, the outer activation reads its own n.
  - Mutant: recursion over M itself, where the inner activation's write clobbers the outer's x.
    RED, once the working copies are gone (c3b).  While they remain, the outer's working copy hides
    it, so the row is pinned in c3b.
- The working copies stay in c3a, so every fact but the probe's should hold.  The gate measures it.

### c3b: no working copies

- Own reads and writes are typed loads and stores on `self`'s cells: M itself, or the re-entry
  instance.
- The checkpoint, publication, reload, dirty, sticky and selector go, along with the prelude's
  value declarations (§2's table).  A slot-address handle may stay.
- The three rows' Says change to §4's table, accepted as c3's pins (R2 with carry).  The `5 100` and
  `7 100` lines stay.
- The Debt and Absent pins re-pin (§6's list).
- Mutants: a write that misses the cell makes a cross-method `M\x` read RED (fable's); recursion
  without a fresh instance makes unit_recursive_fresh_instance RED.

### c3c: Q29, one cell per declaration

- Today l2_collect_asgn_body (:6746) adds an own row for every bare assignment to a parameter.
  `arg: 1` then `arg: 2` are two slots, and `\[0]arg` / `\[1]arg` read them (l2_own_find_occ).
- Under Q29 the first bare assignment binds the field (L3 §12), and later ones write the same cell.
  `\[N]` counts declarations only, so `\[1]arg` with one declaration is refused at translation, «no
  such occurrence».
- The rows to rewrite are named in plan §4: unit_occ_arg_slots, unit_occ_root_named,
  unit_occ_snapshot_selector.  Their new facts come with the commit, measured.
- The sticky rows are unaffected: their binding line is a declaration (`int: na`), and
  `na: na + 1` writes that field.

Gates: one per commit, asked «GATE?» and «GATE DONE» with fable.  c4 (the `Lmx.native` word, and
the signature as a graph field) is joint with Grok's -188 c4.

### The re-entry data: fable's decision (i), and a proposal for Grok -188 c3

Decision (fable, 2026-09-25): the caller always passes the data, explicitly.  That is role by
position; the trampoline decides nothing and receives the data as an argument (for a native entry,
`self`).
- A static call outside a strongly connected component (the root's CALL included; `M\x` after a
  call from the root must show that activation): data = M.
- A static call inside one (a re-entry), and every dynamic call by reference: data = a fresh
  instance (Q28).
- A native caller that does not know the callee's prototype gets it from the kernel.
- Option (ii) is out.  Option (iii) is not needed.

Proposed shapes (Grok -188 c3: the kernel and the walker; mine, c3a: the emission):

1. `lmx_fresh (@: LmxArena arena; @: Lmx code) @: Lmx`: the same operation as `Model: fresh`,
   `merge(prototype, empty)`.
   - It returns a new Structure with `parent = code\parent`, `len = code\len`, and no operators.
   - Child 0 until c4: the code's child 0, the shared callable, kept by address so the slot numbers
     stay those of the translator's own tables.  With `Lmx.native` (c4) the prototype's numbering
     loses it.
   - Each other child, by what the arena classifies it as in `code`:
     - a numeric cell: a fresh cell of the same type, 0;
     - a char: the interned 0 (`lmx_char_cell(arena, 0)`);
     - a pointer cell: a fresh pointer cell of the same type, null;
     - an Array descriptor: a fresh Array of the same element type and length, zeroed;
     - a Structure whose parent is `code` (a control body, fields only): the same rule, recursively,
       its parent the new instance;
     - a terminal reference (a field pointing to a callable occurrence or a METHOD, e.g. `A: fn: M`:
       the copier's shared terminals, §4): kept by address, like child 0 (fable's correction);
     - only what the arena does not classify is refused: it is not guessed.
   - This is the layout the builder and c2's `l2_new<i>` make, read from the graph itself: no
     translator table and no role record.  That is plan §3 item 9's «ничего сверх самой
     Structure».  If Grok prefers `lmx_plan`'s paths, the result is the same instance.
   - Status: NULL on NOMEM, or a refused child.  The caller's X1.
2. The prim ABI carries data explicitly: `lmx_call_prim (@: LmxArena arena; @: Lmx code; @: Lmx
   data; @@: void refs; size_t: nargs; @: void dest; @@: void out) int`.
   - It dispatches on `code`: child 0 today, the `native` word after c4.
   - It enters `entry(data, refs, nargs, dest, out)`: the trampoline's `owner` is the data, `self`,
     and `node` is `data\parent`.
   - The trampoline makes nothing.  c2's callee-side `l2_new` in the trampoline goes.
3. The walker's CALL.  Proposed: the data is an operand, not a flag word:
   `[call, code, data, arg ...]`.
   - For an in-place call, `data` is the code Structure itself: a plain Structure child evaluates to
     itself (-174 c2).
   - For a re-entry it is `[fresh, code]`, a new role evaluating `lmx_fresh`.
   - The translator decides per site, and the walker evaluates `data` like any operand and passes
     it on.
   - A flag word on CALL would work too; the operand keeps «data by position» in the graph.

On my side (c3a), after -188 c3 lands:
- The root's op tree gets the data operand of each CALL.
- Native code:
  - `l2_m<i>(M\parent, M, ...)` outside a strongly connected component;
  - `l2_c<t>: lmx_fresh(l2_program_arena, M)` then `l2_m<i>(l2_c<t>\parent, l2_c<t>, ...)` on a
    re-entry;
  - `l2_d<t>: lmx_fresh(l2_program_arena, code)` then `lmx_call_prim(arena, code, l2_d<t>, ...)` on
    a dynamic call.
- c2's `l2_new<i>` then goes: one mechanism for a fresh instance (CORE, one mechanism per role).
- So c3a lands with or after -188 c3.  c3b (no working copies) and c3c (Q29) do not depend on it.

## Commit c3c: Q29, one cell per declaration

fable accepted doing c3c before c3b.  With repeated bare assignments as occurrences, a read without
working copies would need a runtime selector; Q29 removes that case first.

What is built:
- l2_own_add dropped the branch «a later assignment of the same name is a new occurrence only when
  the existing row is itself an assignment» (`l2_is_asgn(...) && l2_is_asgn(at) → i: -1`).
  - A later bare assignment now resolves to the existing row, the one cell.
  - `\[N]` counts declarations.
- A missing occurrence is refused where it stands, «own occurrence index out of range».
  - The check pass already said so for a method-rooted `M\[N]x` (:13930).
  - Three emission paths returned 1 silently and gave «translation failed with no located
    diagnostic»: l2_prep's atom form, l2_emit_fields' `\ [ N ] x` run, and both method-rooted
    spellings.  They now give that same message at the name.

Rows (measured), the three the plan named plus one:
- unit_occ_arg_slots: `arg: 1; arg: 2` is one cell and `\[0]arg` is 2.  Re-pinned: `l2_q0_from`
  stays, and `l2_q1_from` (the second slot) is Absent.
- unit_occ_arg_second_refused (new, l2trans-refuses): `\[1]arg` with one cell, «own occurrence index
  out of range».
- unit_occ_root_named: its `test\[1]arg` check goes.  `test\[0]arg` and `test\arg` read the one cell;
  it stays root-pending, needle unchanged.
- unit_occ_snapshot_selector: `\[0]bt` is 2 and `\[0]al` is 9 (the cell's last value), and the `\[1]`
  checks go.  Its Says (`BETWEEN 2`, `LAST 9`) are unchanged.
- Mutant: the branch restored (the translator without c3c).  unit_occ_arg_slots has `l2_q1_from`,
  RED; unit_occ_arg_second_refused translates, RED; unit_occ_snapshot_selector prints nothing,
  because it returns before its line: RED on Says.
- The per-row tool (n159/verify2b.py) now checks `Says` the harness's way: the program's non-empty
  lines, whole and in order.
  - Until now it checked exit codes and pins only, so the Says rows were covered by fable's full
    gates alone.
  - The full gate on bf86717, which checks Says, was GREEN for c2.

## Commit c3b-1: no working copy for a plain own field

A PLAIN own field is a number (int, char, size_t, unsigned, ulong) with its own cell, not bound to
a formal or a dynamic input, and self-canonical (`l2_own_plain`).  That covers ordinary declared own
fields, hosted fields in control bodies, and the unit's fields a method reads.

What is built:
- A read is a typed load of the field's cell (`l2_own_load` / `l2_own_spell`): `lmx_int_value_known(
  l2_q<k>_from[0])` and the like.  It is used at every read spelling: l2_index_token (both),
  l2_hidden_from, l2_prep (both), l2_emit_fields.
- A write is a typed store into the cell (`l2_own_store`: X1 when it fails, a char rebinding its
  interned cell, `---` closing the failure branch).  It is used for an own assignment
  (l2_emit_occ_write), a field-path value into an own local, and a C-style `for`'s init and step.
- The prelude keeps only the slot handle `@@: void l2_q<k>_from`, an address bound at entry.  The
  value `l2_q<k>`, its load and `_dirty` go.
- The checkpoint skips a plain field: nothing to publish, and no reload.
- Formal-bound fields (argument-as-own, dynamic inputs) and pointer fields keep the old machinery
  until c3b-2.

Rows:
- unit_nested_body_for: re-pinned to the store `if: lmx_int_store_known(l2_q1_from[0], (4)) != 0`,
  with `int: l2_q1_dirty` Absent.
- unit_s2_vis_dynamic: re-pinned to the cell load passed as the dynamic input.
- unit_forj_stale: a fact change, intended (fable).  Says `9 | 9 42` became `9 | 42 42`.
  - After `for\j: 42` the bare `j` is the cell.
  - The old «a bare working x may keep its previous value while the path sees the new one» is the
    L3 §12 text the author removed (061d753, «for example (9 9)»).  Sonnet's -190 predicted this.
- Mutant W1: a plain store emits nothing, so a write misses the cell.  unit_fresh_instance_skipped_decl
  exits 0 instead of 70: probe's read of `keep\v` from another method sees 0.  RED.

Found by the per-row check (first run: 6 red), then fixed:
- `@x` of a bare plain own field was spliced as `@ ` onto its load (a C error in
  unit_ns_ref_field_general).
  - `l2_own_addr` now spells the cell's address (L2 §10), as l2_prep_addr does for an own field.
  - It is used in l2_emit_fields' `@` operator and in the call-argument list.
- The text buffers were fixed at 256.  The cell loads are longer than the old names, so
  unit_sizeof_type_frame's eight-field condition overflowed.
  - Every 256-byte text buffer is now 1024, with l2_cat's and l2_index_token's limits to match.
  - The call actuals' and hidden inputs' slots (`l2_act_at`) are 1024 each.
  - Three `memcpy(dest, ..., 256U)` copies, which cut the expression short, now copy the string.
  - The spelling itself is not shortened.
- Two more rows change facts (intended).  unit_addr_take and unit_addr_depth: after
  `set_one(@: n)` writes 1 through the taken address, the bare `n` reads that cell, so 1, not 0.
  - The rows pinned L2 §18.2's example, «`p: @x`, `\p: 9` leaves bare working x at 5».  That is the
    old model, and it is still in docs/L2_spec_{ru,en}.md §18.2 (lines ~177-194): a leftover for
    fable.
  - The sibling unit_addr_arg, where n is a formal, already read 1 and is unchanged.
- One more Q29 row: unit_own_last_occurrence numbered assignment occurrences (`test\[1]arg`).  It now
  reads the one cell: 2, then 5 after `test\arg: 5`.  Entry 7 is kept.
- unit_fnptr_noncallable_assign (translates-with-debt): re-pinned from `l2_q0: 7` to the store.

## Commit c3a: the caller passes the data

Base: fable/join-k3 (main a6a79cd + Grok -188 k.3b `lmx_call_prim(arena, code, data, ...)` + k.3c
walker CALL `[call, code, data, args...]` and FRESH op 23).  Decision (i) and Q28, as planned above.

What is built:
- Re-entry is decided from the call graph (`l2_reach_close`, after the throws closure, for a unit
  and a library alike).
  - `l2_m_edge` now has two bits.  Bit 1: a call of the method itself, by name or path.  Bit 2: a
    call through a callable formal whose contract is that method.
  - A bit-2 edge calls whichever method its actual names, so it counts as an edge to every method
    passed by reference (`l2_m_value_used`).
  - `l2_m_reach` is Warshall's closure over the methods.  A call in j of i is a re-entry when i
    reaches j (`l2_reenters`): i may then be active.  A call of the method itself is one.
- A call by name or path (native, sel 0/1) passes the occurrence itself: `l2_m<i>(M\parent, M, ...)`.
  On a re-entry it passes `lmx_fresh(l2_program_arena, M)`, with X1 on NULL.  A method with no data
  fields keeps its occurrence (nothing to lay out), as in c2.
- A call by reference (a callable formal, sel 2) always makes `l2_d<t>: lmx_fresh(arena, code)` and
  calls `lmx_call_prim(arena, code, l2_d<t>, 0, 0U, ...)`.  The caller does not know the callee's
  prototype; the kernel makes the instance from the code.
- The trampoline makes nothing: `owner` is the data its caller passed.  c2's callee-side
  `l2_self: l2_new<i>(l2_self\parent)` goes.
- c2's `l2_new<i>` (l2_emit_fresh) goes: `lmx_fresh` is the one mechanism for a fresh instance.
  `l2_emit_cell_new` stays: the builder uses it.
- The generated program predefs `lmx_fresh.h.lm1`.  Its body reaches the eternal driver through
  lmx_walk.lm1 (grok_bot k.3c-fix, f6e55e1); the driver's own predef, needed before that fix, went.
- The walked root's CALL is `[call, code, data, args...]`: code and data are both the occurrence,
  (M, M), and the inputs move from 2 to 3.
  - No root CALL needs `[fresh, code]`.  The root has no name (l2_make_entry), so no call and no
    actual can name it; it is in no cycle, and no call from it is a re-entry.
  - A `[fresh, code]` branch there would be unreachable, so it is not emitted.  The first walked
    CALL that can be a re-entry is one inside a walked method body, which does not exist yet.
  - The walker's FRESH node (Grok -188 k.3c) stays, for those future interpreted method bodies
    (fable, 2026-09-25).

Rows:
- unit_fresh_instance_skipped_decl returns to 77 (Entry 77): probe's call of keep is outside any
  cycle, so keep(0) leaves keep(1)'s 7.  Its pins: `l2_c0 lmx_arena_ref_struct(node, 1U)`, and
  `lmx_fresh(` and `l2_new0` Absent.
- New: unit_recursive_fresh_instance.
  - `down` recurses (re-entry, fresh instance); r = down(3) = 123.
  - The root's CALL of `down` passes `down` itself, so down\x is 3 afterwards.
  - `apply` calls `seven` by reference (fresh instance), so seven\s stays 0.
  - The exit is r + 1000 * (down\x + 100 * seven\s) - 3123 + (d - 7) = 0.
- 15 Debt pins on a walked CALL frame's child count move up by one, for the data operand
  (12 rows).
- The five rows that did not compile on k3b's `lmx_call_prim` (unit_bare_in_method,
  unit_value_call_formal, unit_dyn_call_throw_caught, unit_callable_formal_descriptor,
  unit_matrix_callable_callable_arg) run green.

Mutants (private variants; each is RED by behaviour, not only by a pin):
- M1, no fresh instance on a re-entry: unit_recursive_fresh_instance exits -3123.
- M2, a fresh instance on every native static call (option (ii) for native code):
  unit_fresh_instance_skipped_decl exits 0 instead of 77.
- M3, the root CALL's data a builder-time fresh instance instead of M: unit_recursive_fresh_instance
  exits -3000 (down\x reads 0).
- M4, a call by reference over the code itself (data = code): unit_recursive_fresh_instance exits
  700000 (seven\s reads 7).

Per-row check (verify2b over all 356 rows, scratch driver with lmx_fresh): 0 red after the CALL
re-pin.  The 2 argv rows are run by the harness only.

## c3b-2 plan (prep, not built): a formal-bound field is its cell after its binding line

Today (measured on the c3a tree), a formal-bound own row k (`l2_m_alias` >= 0, or `l2_own_param_of`
>= 0 through the canonical row) has no runtime selector.  Every bare read spells the parameter
`l2_p<mi>_<fi>`, before and after the binding line (l2_prep :15444, l2_index_token :8029/:8075,
l2_hidden_from :14768/:14775, l2_prep_addr :14942/:14956, l2_prefix_deref :7825/:7841).  A write
goes to the parameter and copies it into `l2_q<k>` with `_dirty` (l2_emit_occ_write).  The
checkpoint publishes the parameter, or, when `@x` was evaluated (`_sticky`/`_active`), republishes
it over any graph write.  That republication is what the old facts pin.

The rule (R2 with carry, static by position; fable):
- Before its binding line the name is the machine argument; after it, the field.  The binding line
  is the row's declaration (`int: na`, with or without an initializer) or its first bare assignment
  (Q29: later ones write the same cell).
- A binding inside an if/for body binds that body's hosted field.  Outside the body the name is
  whatever it was before: the parameter, or an enclosing field already bound.
- Carry: a declaration without an initializer stores the name's current value, read as the name
  just before the line (the parameter, or an enclosing bound field).

What the emitter does:
- Keep emission-time state per own row: `l2_own_bseq[k]`, 0 before its binding line, else the
  emission sequence number at which it was bound.
  - At a body's exit, every row bound inside the body is cleared (bseq > the value at entry).  A
    row's binding statement is in its host body, so exactly the rows scoped to that body are
    cleared.
  - A use resolves to the bound row of that name with the largest bseq (the innermost in scope), or
    to the parameter when there is none.  One helper, used by the six spelling sites above.
- Numeric formal-bound rows (0/1/2/3/36) become direct, like c3b-1's plain rows:
  - prelude: `_from` only, bound eagerly; no `l2_q<k>`, `_dirty`, `_sticky` or `_active`;
  - read: `l2_own_load(k)`; write: `l2_own_store(k, value)`; `@x`: `l2_own_addr(k)` after binding,
    `@ l2_p` before;
  - binding line: evaluate the RHS (or the carry) with the row still unbound, store it into the
    cell, then mark the row bound.
- The checkpoint neither publishes nor reloads them.  l2_emit_addr_mark, l2_emit_bind_mark and
  l2_emit_finalize_old lose their numeric cases.
  - Pointer formal-bound rows keep the old machinery until c3b-3 (pointer own fields), so the sticky
    code goes with c3b-3.
- The harness's BindOrder assertion (Test-BindOrder, on 8 rows) asserts the sticky machinery's text
  order.  It goes where that machinery goes: c3b-2 for the numeric rows, and the function with c3b-3.

Facts, predicted by the rule.  Every changed line is printed after `M\x: v` wrote a bound name's
field, so it shows v:
- unit_arg_addr_sticky: A2 100 100, A4 200 200, B+ 200 200, C3 100 100, D1 100 100, D0 100 100,
  E 100 100 (§4).
- unit_arg_addr_dynamic: IA2, IA4, IB+, IC3 and ZA2, ZA4, ZB+, ZC3 the same way (§4).
- unit_occ_sticky_selector: BEFORE 100 100, AFTER 100 100 (§4).
- Not in §4's table, found reading the fixtures:
  - unit_arg_addr_types: U 100 100, Z local/graph 100, L local/graph 100 (today 51 and 71/81);
  - unit_arg_addr_dyn_types: U2, L2, F2 100 100 (today 6 6);
  - unit_arg_addr_ordinary: OC3 100 100, OE 100 100, OD3 100 100 (today 9 9, 6 6, 9 9).
  Sonnet's -190 inventory predicted these three rows unchanged.  They are the same sticky shape
  (address taken before or after the binding, then `M\x: 100`), so I expect them to change.  The
  build measures it.
- Unchanged: the `5 100` / `7 100` lines, unit_occ_snapshot_selector (BETWEEN 2, LAST 9: every read
  is after the binding), unit_arg_addr_pointer (a pointer row, c3b-3), and the CALLER line.

Witnesses:
- A new row for the body scope: a formal bound by a bare assignment inside an `if`, read inside and
  after the body.  Inside it is the body's field; after it, the parameter.
- Mutants, each to be RED by behaviour:
  - MB1: never bound (always the parameter);
  - MB2: bound from entry (R1): the `5 100` lines become `100 100`;
  - MB3: no carry: A1 becomes `1 1`;
  - MB4: a body's bindings not cleared at its exit: the new row.

Order: after c3a lands on main.  c3b-3 (pointer own fields, `Model: m` / received `m`) follows as
its own commit.

## Commit c3b-2: a formal-bound field is its cell after its binding line

Base: main 039bf22 (c3a landed).  Built as planned above; what changed from the plan is marked.

What is built:
- `l2_own_plain` became `l2_own_direct`: every numeric own field (int, char, size_t, unsigned, ulong) is
  its cell.  Plain fields and formal-bound ones alike have no working copy.
  - Direct fields get no `l2_q<k>` in the prelude, and no `_dirty`, `_sticky` or `_active`.
  - Their `_from` is bound eagerly, and the checkpoint skips them.
  - The sticky helpers (bind_mark, addr_mark, finalize_old) do nothing for them.
- The binding state is `l2_own_bseq[k]`.  It replaces `l2_own_live`, which was written and never read.
  - A row gets its number (`l2_bseq_n`) at its first store (`l2_own_store`).  That store is the binding
    line, whose value was spelled before the line, with the name still the argument.
  - `l2_emit_body` became a wrapper around the old body, now `l2_emit_body_in`.  On leaving a body it
    clears every row bound inside it.
- `l2_formal_row(mi, pk)`: the latest bound row whose name is parameter pk, else -1 (the argument).
  - `l2_tok_formal` resolves through it, so l2_prep, l2_hidden_from and the field-path root follow.
  - l2_index_token (both own-row sites) and l2_prep_addr (`@x`: the cell after binding, `@ l2_p`
    before) follow it too.  So do the `@ name` operator and the call-argument list, through
    `l2_name_cell`.
- Carry: a declaration without an initializer stores the name's value, read just before the line
  (the argument, or an enclosing bound field).
- Changed from the plan: a field binds the formal by NAME (`l2_own_formal(mi, k)` = l2_param_find of
  the row's name), not by `l2_own_param_of`.
  - A bare assignment in a body makes that body's hosted row.  l2_bind_own aliases occurrence 0
    only, and the hosted row is its own canonical row, so its param_of is -1.
  - Measured on a probe: `y: y + 10` in an `if` body was stored in the body's cell, but `in2: y` read
    the method-level field (1404 expected, 404 printed).  The old model gave 404 too.
- Pointer own fields keep the working copy and the sticky machinery until c3b-3.  So
  unit_arg_addr_dyn_types (its DP pointer row) and unit_arg_addr_pointer keep `BindOrder`.

Rows:
- The facts predicted in the plan, all measured as predicted:
  - unit_arg_addr_sticky: A2 100 100, A4 200 200, B+ 200 200, C3 100 100, D1 100 100, D0 100 100,
    E 100 100;
  - unit_arg_addr_dynamic: IA2, IA4, IB+, IC3, ZA2, ZA4, ZB+, ZC3 the same way;
  - unit_occ_sticky_selector: BEFORE 100 100, AFTER 100 100;
  - unit_arg_addr_types: U 100 100, Z 100/100, L 100/100;
  - unit_arg_addr_dyn_types: U2, L2, F2 100 100;
  - unit_arg_addr_ordinary: OC3, OE, OD3 100 100.
  - Every `5 100` / `7 100` line, unit_occ_snapshot_selector and the CALLER line are unchanged.
- The -67 sticky pins were re-pinned to the new text, with `_sticky`/`_active`/`_dirty` Absent:
  - the carry store `if: lmx_int_store_known(l2_q1_from[0], (l2_p3_0)) != 0`;
  - `@ l2_p3_0` before the binding, `(cast: (@: int) l2_q1_from[0])` after it.
- `BindOrder` was dropped from the numeric rows: sticky, types, dynamic, ordinary, sticky_selector,
  snapshot_selector.
- Each changed fixture got a header note: the facts are now R2 with carry, and the sticky text below
  it is the old model's.
- New: unit_arg_bind_body_scope.  scoped(3, 1) is 73: in the body the field (7); after it the
  argument (3).  nested(3) is 1404: the body's field is 14, the method's 4.

Mutants (private variants, each RED by behaviour):
- MB1, never bound (always the argument): sticky prints A1 5 6, ...; body_scope exits -1141.
- MB2, bound from entry (R1): the `5 100` lines become `100 100`, C1 1 1; body_scope exits -1299.
- MB3, the declaration binds with the prototype's 0 instead of carrying: A1 1 1, C1 1 1; body_scope
  exits -303.
- MB4, a body's bindings outlive it: body_scope exits 14 (scoped 77).

Per-row check (verify2b, 357 rows, scratch driver): 0 red.

## c3b-3 plan (prep, not built): pointer own fields direct; an own Structure field is a direct slot

Agreed with grok_bot -186, whose PUT_REF is walker op 24 with frame [put_ref, holder, slot, value]
(branch fable/grokbot-186-putref-k2).  It lands with or after that op; the builder's slot layout is
shared by native methods and the walked root, so both change in one commit.

Measured on c3b-2 (7ce60f9):
- The one gate is `l2_own_direct`, numbers only.  `l2_own_load` / `l2_own_addr` return 1 for a
  pointer; `l2_own_store`'s template has no `(cast: (@: void) ...)` for one.
- The builder makes every pointer own row a pointer cell: `l2_emit_cell_new`,
  `lmx_pointer_new_owned(c.LMX_TYPE_POINTER_BASE + t)`.
  - `@: T` reference fields are not own rows but namespace fields (kind 10/11, a separate builder
    loop), so they stay cells without a test.
  - Every Structure-typed own row has `ty = l2_own_of_dt(l2_colon_graph_ty())`.  The test is
    `l2_colon_is_graph_ty(l2_dt_of_own(ty))`, which also covers untyped `receiveMessage: m` and `f()`.
    `l2_own_nsty_get` covers typed rows only.
- Native writes of an own Structure field, which become one helper (bind = `lmx_arena_ref_store(ctr,
  uchild, g)`):
  - receiveMessage / `T: m` (:20877);
  - `Model: m` (:20913, via `l2_xp`);
  - `f()` declaration (:20944);
  - `f()` assignment (:20985);
  - the S3 admitted rebinding (:21103, which then also falls through to the generic write);
  - generic `m: expr` and the catch parameter (occ_write + the checkpoint).
- Native reads, which become `lmx_arena_ref_struct(ctr, uchild)` for a Structure field and
  `lmx_pointer_value_known(l2_q<k>_from[0])` for any other pointer:
  - l2_own_spell;
  - l2_canon_spell;
  - l2_prefix_deref :7886 (no direct check today);
  - `c.sizeof(l2_q%d)` :15216 (the declared working copy);
  - the path-root load (`l2_emit_cell_load`'s pointer branch :14810);
  - the prelude's initial load;
  - the checkpoint's publication and reload.
- `@x` of a Structure field: a direct slot has no pointer cell to take the address of.  Proposed:
  refuse it by name of the reason («an own Structure field has no cell address»), unless a row needs
  it.
- Walked root:
  - DEREF(AT(m)) becomes a direct slot read at :17367 (the path root) and :17753 (struct_arg);
  - PUT(m, ...) becomes PUT_REF at :17483 (admit_assign), :17524/:17531 (take) and :17570 (model);
  - AT reads of the cell at :17485, :17747 and :17820 (`m = 0`) follow;
  - :17381, a kind-3 reference in a path, stays DEREF.
- Harness:
  - DEREF pins in unit_root_model_field, unit_field_path_unit_colon and
    unit_matrix_callable_struct_identity;
  - the pointer sticky pins in unit_arg_addr_pointer and unit_arg_addr_dyn_types, whose
    `BindOrder` then has no sticky row left.  `Test-BindOrder` and the flag go.
- The copier, shared with grok_bot: lmx_fresh copies a POINTER_BASE cell per instance.
  - A direct slot holding a Structure bound in an earlier activation would be kept BY ADDRESS in a
    re-entry's fresh instance: a Structure whose parent is not the code counts as a shared terminal.
  - The fresh instance's own Structure slot must start empty (null), as the prototype's does.
  - That is lmx_fresh's rule to add: an own Structure slot of the prototype becomes null, not shared.
    The kernel is grok_bot's, joint with c3b-3.

Witnesses planned:
- Mutant: bind through a pointer cell while reading the slot.  unit_root_model_field and the
  receive rows go RED.
- Recursion with a `Model: m` field read after the inner call: each activation keeps its own m.

## Commit c3b-3: pointer own fields direct; an own Structure field is a direct slot

Base: main 260c6ce + grok_bot's -186 k3 (10f9e38, the copier shares a pointer cell's pointee) +
k4 when it lands (below).  Plan: «c3b-3 plan» above.

What is built:
- `l2_own_direct` now also covers every pointer own field.  No own field keeps a working copy.
  - The fixtures' generated L1 (197 programs) has no `_dirty`, `_sticky`, `_active` and no
    `l2_q<k>: ...` assignment left.
- `l2_own_is_slot(k)` is a field of the graph type whose declaration is not `@: T x`.  That covers
  `Model: m`, `T: m`, `receiveMessage: m`, `f()` and a Structure catch parameter.  Its slot holds
  the Structure:
  - the builder makes no cell for it (`l2_emit_cell_new`); it stays 0 until the field is bound;
  - a read is `(cast: (@: Lmx) l2_q<k>_from[0])`, the slot itself;
  - a binding is `lmx_arena_ref_store(<ctr>, <slot>, g)`, inside `l2_own_store`.
- A pointer field reads `(cast: (T) lmx_pointer_value_known(l2_q<k>_from[0]))`.  It stores with
  `lmx_pointer_store_known(l2_q<k>_from[0], (cast: (@: void) v))`, and `@p` is its cell's address.
- The pointer type spelling is one function, `l2_pointer_decl_text`: a type alone or a declarator.
  - l2_emit_raw_pointer_type and l2_emit_own_pointer_temp_decl had each carried the table.
  - An unknown code now returns 1 with depth 0, not with an uninitialized depth.
- The native binding sites that each hand-emitted `lmx_pointer_store_known(<cell>, g)` before the
  working-copy write are now the one `l2_own_store`, through occ_write: receiveMessage / `T: m`,
  `Model: m`, `f()` declaration, `f()` assignment, the S3 admitted rebinding.
- Own-row loads from a slot address go through `l2_emit_own_cell_load`: the path root, `M\x` and
  `M\[N]x` from another method, a hidden input.  `@m` of an own Structure field is refused: «an own
  Structure field has no cell address».
- `\p` of a direct pointer field: L1 dereferences a name only.  `\(expr)` is refused, «prefix
  dereference expects an operand» (measured on l1trans).
  - So an emitting caller loads the pointer into a temporary first (`l2_deref_load`).
  - l2_prefix_deref takes `ind`; the two check-phase callers pass 0.
- Walked root:
  - an own Structure root is AT(slot), not DEREF(AT(cell)) (l2_rw_path_value, l2_rw_struct_arg);
  - admit-assign, take and model bind it with PUT_REF (`l2_rw_bind_op`), op 24,
    [put_ref, holder, slot, value];
  - a kind-3 reference field in a path keeps DEREF.

The kernel side, grok_bot -186 k4 (in progress):
- Six root rows compare an own Structure field: `if: m = 0`, `m != 0`, `letter = m`.  They are
  take_empty, take_letter, next_message_twice, next_message_in_method, admit_letter_coarse and
  charpp_return.  On the walker as of k3 they fail «walk error: INVALID»:
  - AT of an empty slot was INVALID;
  - EQ with a Structure reference or no value was INVALID.
- Measured with a private scratch patch of the staged lmx_walk.lm1 (n159/kslot.json): with AT of an
  empty slot giving no value, and EQ comparing addresses when a side is STRUCT or 0, all six are
  green.  grok_bot is writing that as k4.
- lmx_fresh (83e1bda) clears an own Structure slot of a re-entry's instance to 0, the prototype's
  value; an OP/ROLE frame's Structure operand is still kept by address.  That is the rule the
  c3b-3 plan named: no discrepancy.
- The copier (k3): a pointer cell's pointee is shared.  An own Structure field is a STRUCT child now,
  so it is copied with its parent.

Rows:
- Pins:
  - unit_root_model_field, unit_field_path_unit_colon and unit_matrix_callable_struct_identity pin
    `c.LMX_WALK_OP_PUT_REF, 4U)`, with `c.LMX_WALK_OP_DEREF` Absent;
  - unit_arg_addr_pointer loses its sticky pins.
- `BindOrder` and `Test-BindOrder` are gone from the harness: no own field carries a sticky flag.
- New: unit_recursive_model_slot.  `nest` recurses with `Box: b` and `b\v: n`; each activation
  binds its own slot, so nest(3) = 123.

Mutants (private variants, each RED by behaviour):
- MS1, the old form (the builder's pointer cell, binding stored into it) under slot reads: the
  recursive row, model_field, take_letter and admit_letter_coarse all stop with exit 3.
- MS2, the walked root binding by PUT: model_field, take_letter and admit_letter_coarse exit 3.
- MS3, a native binding stored into the method's occurrence M instead of the activation's data:
  unit_recursive_model_slot exits 3.

Per-row check (357 rows, a scratch driver with the scratch walker patch): 0 red after the re-pins.

### c3b-3, part 2: the working-copy machinery goes

Once every own field but an array is direct, nothing reaches the old machinery.  The 197 fixtures'
generated L1 (c3b-3 part 1) has no `_dirty`, `_sticky`, `_active` and no `l2_q<k>: ...` assignment.
So these go:
- the checkpoint (`l2_emit_checkpoint`, 17 call sites), its reload (`l2_emit_own_reload`,
  `l2_own_unit_field`);
- occ_write, whose calls are now `l2_own_store`, and `l2_own_spell`, whose calls are now
  `l2_own_load`;
- the sticky rule: l2_canon_spell, l2_emit_finalize_old, l2_emit_addr_mark, l2_emit_bind_mark,
  l2_own_addr_taken, l2_param_addr_taken and its memo, l2_addr_scan, l2_own_of_param;
- the prelude's value declarations, initial loads and sticky flags: a direct field keeps its slot
  handle;
- helpers left without a caller: l2_own_param_of, l2_own_canon, l2_param_name, l2_own_store_value;
- the comments that described publication at a checkpoint.

Witness: every fixture translated before and after (n159/genall.sh: 214 outputs, the library form
too, and each refusal's stderr) is byte-identical.  l2trans.lm1 is 552 lines shorter.

## c4 plan (k.1, read-only): the `Lmx.native` word

Base: main 2f8d475.  The norm (plan §3 item 8; L2 §2/§5/§11; CORE §2/§3):
- `Lmx` becomes `{array, parent, native}`, with `native` the C entry of the body or 0.
- Dispatch is by that word: non-null enters native code, 0 runs the walker over the operators.
- The signature is an ordinary lexical graph field.
- These go: the `child[0]` descriptor, `LmxCallable {method, header}`, `LmxMethod {addr, sig}`, the
  `sig` word, lmx_plan's role records (the plan is the data prototype's layout), and child[0]
  classification in lmx_call.
- The copier carries `native` verbatim.  A merge result takes the word of its last operand with a
  body.

Measured at 2f8d475: the kernel `Lmx` is still `{parent, len, data}`.
- lmx.h.lm1:59-70: «THIS STRUCTURE IS CLOSED… A fourth field here is a DEFECT».  That comment goes
  with the author's refactoring (k.4).
- `VoidArray` exists only in LMX_ARRAY_OWNED.txt (the accepted target, «code not migrated»).

### (1) Where the translator builds or reads the descriptor, and what goes

Built:
- The builder's descriptor loop (l2trans.lm1 :21475-:21512):
  - for every occurrence, `lmx_method_new_owned` + `\addr` (`<sym>_tr`, or 0 for a bodiless `fn`
    and for E) + `\sig` (`l2_method_sig_text`);
  - then `lmx_callable_new_owned` + `\method`, `\header: 0`, and `lmx_arena_ref_store(leaf, 0U,
    callable)`.
  - The loop also fills `l2_methods`, an ARRAY_OF_METHOD, at unit child `l2_unit_base +
    l2_occ_n()` (:21481, :21702), which carries the `l2_entry_rec\sig` recheck.
  - All of that goes.  It becomes one store per native occurrence: `leaf\native: (cast: (LmxEntry)
    <sym>_tr)`.  E, a bodiless `fn` and every named Structure keep 0.
- `l2_method_sig_text` (:20764) and the emitted intern recheck (`l2_intern_again != l2_sigv`, :21705)
  go.
  - `l2_tramp_class` stays: it types the trampoline's result, a machine matter.
- The numbering that reserves child 0 moves down by one:
  - `l2_own_mslot` starts at 1 (:8941);
  - `l2_m_kids` = 1 + own + bodies (:9004);
  - `l2_for_uchild` = 1 + own + rank (:9039);
  - `l2_unit_base` = `l2_m_kids(l2_e)` (:9043), and everything after it: `l2_mres_base`, `l2_ns_base`,
    eternal refs, `kids`, the entry-length check at :21387.
  - Without the METHOD array the unit tail loses one more child.
  - `l2_m_kids(idx) > 1` («a method with no data fields», the fresh-instance gate at :15527) becomes
    `> 0`.
- Named Structures' callable field (kind 4, :11326/:21663) keeps its reference to the occurrence.
  - Merge check 78 (child-0 identity, :20001) goes.  Checks 77 (the occurrence) and 79 (the first
    own child, `l2_first_own_child`) stay, renumbered.

Read at run time:
- Generated code reads child 0 directly only in merge check 78.
- Everything else reads it through the kernel: `lmx_call_prim` for a callable formal (:16457), the
  walked root's CALL (:17451), and `lmx_fresh` on a re-entry (:15528).

### (2) The emission: the native entry and the signature as a graph field

- The native entry: `native` holds the trampoline `<sym>_tr (owner, refs, nargs, dest, out)`, which
  is today's `\addr`.  The trampoline itself does not change.
- The signature: the norm says the callable's named parts are `args`, `return` and `body` (semantics
  «Вызываемая Structure состоит из именованных частей»; merge is by these parts).  PROPOSED, for fable
  and the author:
  - Form A: two leading parts of the occurrence, in lexical order — the header precedes the body.
    - Slot 0 `args`: a Structure with one typed cell per formal, in order, holding the prototype's 0.
      A callable formal's cell is a slot holding its contract's occurrence.
    - Slot 1 `return`: a Structure with one typed cell of the result type, empty for a `sub`.
    - Own fields and bodies from slot 2.
    - The translator's numbering then shifts by +1 instead of -1.  No offset is hidden: the parts are
      lexical fields, which merge by parts can use as they are.
    - Formals stay the machine activation's (C parameters).  The `args` cells are the signature's
      shape, not the arguments.
  - Form B: no signature graph in a native occurrence until merge by parts needs one.
    - The walker's CALL still needs the result class that `sig`'s low byte carries today
      (`lmx_walk_callable_result_type`).  So B needs some other carrier, and that is exactly what the
      norm removes.
  - Recommended: A.  It is the norm's shape, and it gives the walker the result type
    (`return`'s cell type) and implements its comparison (args/return by type ranges) without any
    word.
  - OPEN: whether `M\x` resolution must skip the two parts.  The translator resolves by its own
    tables, so no name lookup reaches them.

### (3) The walked root and named Structures

- `native` = 0 for E (the root is always walked) and for every named Structure.
- E loses child 0.  Its own fields start at slot 0, or 2 under form A.  The walked root's
  `l2_rw_cell` indices follow `l2_own_uchild` and so need no change.
- A merge result has an empty `native` unless its last operand with a body has one (kernel).

### (4) What lmx_call_prim and the walker see after k.4, and which rows change

- `lmx_call_prim(arena, code, data, …)`: `code\native` non-null means `entry(data, refs, nargs,
  dest, out)`; 0 means walk `code` over `data`.  No child-0 classification remains, and no
  «callable» test: any Structure in head position executes, and a refusal is the translator's.
- The walker CALL:
  - `lmx_walk_callable_addr` becomes `callee\native`;
  - the result class comes from the `return` part under form A;
  - `lmx_walk_data_holder`'s child-0 comparison goes, since data and code are already separate
    operands;
  - `lmx_walk_steps` / `lmx_walk_scan` / `lmx_walk_body` start at 0, not 1;
  - the plan is the prototype's layout, not `info\header`.
- lmx_fresh's `keep_slot0` goes, and `native` is copied into the instance.  So is the copier's
  METHOD/CALLABLE terminal handling.
- The harness pins that change:
  - 13 slot-number strings in 11 rows (unit base: merge_in_method, s1_merge_uncaught,
    s1_merge_profiles_uncaught, s1_implements_uncaught, colon_method_lexical_model,
    recursive_fresh_instance ×2, fresh_instance_skipped_decl; own slots: nested_body_else ×2,
    nested_body_while, nested_body_for, occ_arg_slots);
  - the `SIG_MARK` pins in unit_s1_throws_intern, unit_root_call_wide and unit_method_sig_distinct.
    Those rows test the sig word itself, so they are rewritten to the `return` part (A) or retired
    with the word.
  - No pin names `l2_entry_rec`, `lmx_callable_new_owned`, `lmx_method_new_owned`, `\sig` or `_tr`.

### (5) Dependencies: grok_bot k.4, one joint landing (as c3a)

grok_bot's kernel side:
- `Lmx` gets its `native` word (lmx.h.lm1; the author's refactoring, not a precedent);
- lmx_call: `lmx_call_ready`, `lmx_call0`, `lmx_call_prim`, `lmx_call_method` / `lmx_call_callable`
  go or become the word;
- lmx_walk: callable_addr, is_callable, result_type, data_holder, the descriptor paths, and enter /
  prepare / plan_check on `info\header`;
- lmx_plan: publish and the role records;
- lmx_fresh: keep_slot0;
- lmx_graph_copy_owned: callable-occurrence recognition by child 0, METHOD sharing;
- lmx_implements: the sig comparison, which becomes args/return under A;
- lmx_value_owned: `lmx_method_new_owned` / `lmx_callable_new_owned`;
- lmx_interp, lmx_thread (`lmx_call0`), lmx_pool `lmx_method_intern`, and the
  ARRAY_OF_METHOD users.

My side (the translator): (1)-(3) above and the harness pins.  The order is the same as c3a: his k.4
branch, my commit on top, per-row check, one gate.

### Do generated programs still reference lmx_own / lmx_dirty?

- No, as code.  No emitted predef/include names `lmx_own`, `lmx_dirty`, `own.h` or `l1src/own`.  The
  only hit is a sentence inside the emitted header comment, «…not OwnUsed and not lmx_own…», written
  at l2trans.lm1 :21143.  It can go with c4.  unit_bad_sizeof's `lm_own_copy_bytes` is that
  fixture's own `predef: "l1src/own.h.lm1"`, the L1 own module, not lmx_own.
- Kernel and L3:
  - lmx_dirty has no user but its selftest.
  - lmx_own is still used by the L3 interpreter: dev/l3_interp/l3_exec.lm1 (predef, `lmx_own_checkpoint`,
    `lmx_own_write`), l3_recv.h.lm1 and tests/l3_02_selftest.lm1.
  - So -187 k.3 can delete lmx_dirty.  lmx_own goes only after L3's own working copies do.

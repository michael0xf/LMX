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

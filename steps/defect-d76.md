# D-76: a path through a `@: T` reference to a named Structure

Ticket: fable's answer, `steps/tickets-20260925.md` §6 (Opus: «D-76 — твой следующий»).  Branch
`claude/continue-opus-next-doc-rvjocj`, base main `bcad1f0`.

## Plan

1. The norm of the C type: `@: T` of a named Structure T is ONE level, `@: Lmx` -- its value is the
   Structure itself, the pointee its pointer cell holds, the value `@mo` gives (D-53) and `T: mo`'s
   slot holds.  Two sites made it `@@: Lmx` (depth + 1): `l2_resolve_type_atom` and the shared
   pointer-local table `l2_ptr_type_word`.
2. The lowering of a path through such a reference, in the path walk every reader and writer shares
   (`l2_path_root` / `l2_path_kind` / `l2_emit_path_to`):
   - a formal `@: T m`: typed T at registration (`l2_nsty_set`), as `T: m` is;
   - a local `@: T r` (a C local, `l2_ml_*`): a path root, its value the Structure;
   - a reference field `@: T q`: a segment the walk goes on through, into its pointee T.
3. Rows (success 7): a local, a formal, a reference field, each read and written through; corpus diff.

## RESULT

Base main `bcad1f0`; STARTED is the commit before this one.

### l2trans.lm1

- The C type (plan 1): `l2_resolve_type_atom` and `l2_ptr_type_word` give `@: T` of a named Structure
  `Lmx` at the declared depth, not depth + 1.  `@: Model` is `@: Lmx` in locals, formals and read
  temps, the same C type as the value put into it.  `l2_own_is_slot` already told the two apart by the
  declaration (`@: T` a pointer cell, `T:` a slot), so nothing else had to learn a new type.
- A formal `@: T m`: `l2_collect_method` records T (`l2_nsty_set`) through the new
  `l2_ref_formal_ns(decl)`, so `m\value` is the path walk's formal root with T, as for `T: m`.
- A local `@: T r`: `l2_ml_ns` (the pointee T of each C local, set in `l2_ml_add` by the same
  `l2_ref_formal_ns`); `l2_path_root` makes it a root, `out_root = -3 - i` (next to -2 node, ≤ -1000 a
  method, ≥ 0 a for); `l2_path_kind` / `l2_emit_path_to` take its segment 1 from T, and the seed is
  `l2_pst: (cast: (@: Lmx) r)` with the null bail.
- A reference field `@: T q`: its registration keeps T's name (`l2_nsf_name`, read only for kinds
  3/4 until now); `l2_ns_ref_pointee` gives T for a segment, and the walk goes on through the pointer
  cell: `l2_pxp: lmx_arena_ref_cell(l2_pst, slot)`, `l2_pst: (cast: (@: Lmx) lmx_pointer_value_known(l2_pxp[0]))`,
  each with its bail.

Not in this ticket: a CHAINED read inside a condition (`if: h\q\value != 9U`, and equally
`if: h\In\x != 4U` through an inline nested Structure) is refused before and after: the expression
reader wires one hop (`l2_field_path_check`'s own comment).  The rows read through `v: h\q\value`.

### Rows

| Row | main `bcad1f0` | Now |
|---|---|---|
| `unit_ref_local_path` (new) | l2trans: «unknown field path root» | eternal-runs, Entry 7: `r: @mo`; a write to mo read through r (9), a write through r read in mo (11).  Absent `@@: Lmx r`; Debt `@: Lmx r`, `l2_pst: (cast: (@: Lmx) r)` |
| `unit_ref_formal_path` (new) | l2trans: «field path goes through a slot with no Structure» (the write); the read was raw `l2_p0_0\value` on `@@: Lmx` | eternal-runs, Entry 7: `peek(@mo)` reads 9, `poke(@mo, 13U)` writes mo.  Absent `@@: Lmx l2_p`; Debt `@: Lmx l2_p0_0` |
| `unit_ref_field_path` (new) | l2trans: «field path goes through a slot with no Structure» | eternal-runs, Entry 7: `v: h\q\value` reads mo's 9, `h\q\value: 12U` writes mo.  Debt the pointee load |
| `unit_ns_ref_field_general` (D-53) | 2 gcc warnings «comparison of distinct pointer types» | the read temps of `h\q` are `@: Lmx`: 0 warnings |

Inverted check (`entry 0`): red on each new row.

Generated L1, the three roots:

```text
    @: Lmx r
    r: (cast: (@: Lmx) l2_q1_from[0])
    ...
    l2_pst: (cast: (@: Lmx) r)
    if: l2_pst = 0
```

```text
    fn: l2_m0 (@: Lmx node; @: Lmx self; @: Lmx l2_p0_0) size_t
```

```text
    @: Lmx l2_t2
    l2_t2: (cast: (@: Lmx) l2_xp[0])
    l2_pst: l2_t2
    l2_pxp: lmx_arena_ref_cell(l2_pst, 0U)
    if: l2_pxp = 0
    l2_pst: (cast: (@: Lmx) lmx_pointer_value_known(l2_pxp[0]))
    if: l2_pst = 0
    l2_pxp: lmx_arena_ref_cell(l2_pst, 0U)
```

(the X1 bail lines under each `if:` are cut.)

### Mutants (private l2trans variants)

| Mutant | What is mutated | Result |
|---|---|---|
| D76a | `l2_ptr_type_word` back to depth + 1 | runs (C only warns), red by the pins: `@@: Lmx r` in `unit_ref_local_path` (Absent), `@@: Lmx l2_p…` in `unit_ref_formal_path` (Absent) |
| D76b | the formal's T not recorded | `unit_ref_formal_path`: l2trans refuses «field path goes through a slot with no Structure» |
| D76c | no local root (`l2_ml_ns` -1) | `unit_ref_local_path`: l2trans refuses «unknown field path root» |
| D76d | the reference field's cell taken as the Structure (no pointer load) | `unit_ref_field_path`: X1 «a field path met no Structure», abort |

### Numbers (cloud)

- `python tools/build_l2src.py`: 174/230 (as main; red only the `<windows.h>` closure).
- `python tools/check_docs.py` OK; `git diff --check` clean.
- Corpus, the 644 tracked `.lm2` through main `bcad1f0`'s l2trans and this one: no outcome change; one
  output differs, `unit_ns_ref_field_general` (three read temps `@@: Lmx` → `@: Lmx`).  So no fixture
  used `@: T` of a named Structure anywhere else.
- Private `windows.h` shim (not in the repo): harness 397/397.  Evidence; the machine gate decides.

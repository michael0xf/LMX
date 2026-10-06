# K02 — ordinary merge values (next_core_tasks_v2.md, §2)

Editorial correction — 2026-10-06: this historical record includes the
incorrectly accepted prefix spelling `b: merge A C`. It is not a language
rule or an alias. Operand-bearing applications require their own actual
P0 Frame, such as `b: merge: A C`, `b: merge(A C)` or an equivalent vertical
form. The former K02d "book spelling" collector is a crutch to remove,
not a verified common application path. Old measurements remain evidence
of the old bytes, not gates of the corrected syntax. See the
[author's correction](../LMX_blog/2026-10-06.md#explicit-receiver-frames) and
[mandatory removal stage](../next_core_tasks_v2.md#explicit-receiver-frames).

Status 2026-10-01: **OPEN**; first slice K02a implemented on the K01 release (`65e4cf4`). This
note records reproductions before repairs, as the plan's §1 asks.

## 1. K02a — the merge projects the ACTUAL operand, not the declared model

**Reproduction.** `unit_merge_actual_operand.lm2`:

```
A: (size_t: x 1U)
B: (size_t: pad 9U; size_t: x 2U)
C: (size_t: x 3U)
fn: m () int
    @: A p B
    R: merge: p C
    size_t: pad
    pad: R\pad
    ...
```

On the K01 bytes this is refused:

```
unit_merge_actual_operand.lm2:24:12: unresolved name
l2trans detail: atom=pad
```

`p` is a reference binding whose declared model is `A`; its referent is a `B`. The merge's
result schema came from the **declared** model, so `R` had no `pad` — the field the actual
operand really has. That is the plan's first bullet verbatim ("reference-to-A holding B must
copy/project B's real fields").

**Where it comes from.** `l2_mrs_build` (the pre-scan that builds the result's slot map, because
a method lowered before the entry may already read a field of the result) classifies an operand
through `l2_resolved_own` and, for an own field, takes `l2_own_nsty_get(own)` — the DECLARED
named model. The candidate is not in the own-field record, but it is in the declaration itself:
P0 gives `@: A p B` as the frame `head="@"` with body `[A, p, B]` (dumped with
`build/fable127_part1b/printTree.exe`), so the third atom is the model of the value the binding
holds.

**Repair.** New `l2_own_ref_candidate(own)`: the `@` frame's third active atom, resolved with
`l2_ns_find` — -1 when the binding names no candidate, or names something other than a unit
Structure. `l2_mrs_build` now takes that model for the operand's entry when it is ≥ 0, keeping
the declared model as the fallback. One model, one place: nothing is added to the own-field
record, no registry and no hidden Structure is introduced.

**Witness.** `unit_merge_actual_operand.lm2` is an `eternal-runs` row (WalkRoot, Entry 7):
`R\pad` = 9 and `R\x` = 3 (C's later `x` goes INTO the model's `x` slot, merge making no repeated
names), and the fixture exits 7. The other merge rows (`unit_merge_live_source`,
`unit_merge_added_repeat`, `unit_merge_body_repeat`, `unit_merge_eternal_pair`,
`unit_merge_last_occurrence`, `unit_merge_value_*`, `unit_merge_in_method`,
`unit_merge_path_expr`) stay green in the same focused run.

## 2. K02b — a FORMAL merge operand

**Reproduction.** A method that merges its own formals:

```
fn: m (Source: source; Extra: extra) int
    R: merge: source extra
    ...
```

was refused outright on the K02a bytes:

```
unit_merge_formal_operand.lm2:10:15: unknown merge operand
l2trans detail: atom=source
```

the same classifier note the defect register carries ("Тот же классификатор вообще не принимает
формальный merge-операнд: … «unknown merge operand» для `source`. Это отказ трансляции, не
норма запрета формалов", steps/defects.md#merge-held-operand-layout).

**Where it comes from.** THREE classifiers decide an operand's provenance, and each named only an
own field, a unit-level Structure and a prior merge result:

- `l2_mrs_build` (the pre-scan that builds the result's slot map) — the refusal above;
- `l2_emit_stmts`'s merge arm (the native emission writes `l2_mops[k]: <expr>`);
- `l2_rw_merge` (the walked emission writes the same operands as `OF`-built values).

**Repair.** A formal behaves exactly as an own field does in the schema: the operand's model is
`l2_input_model(mi, k)` when that is a named Structure, and the value itself travels the ordinary
path every other use of a formal takes — `l2_tok_formal` natively (the bound cell once bound, the
machine argument before) and `l2_rw_arg` in the walker (the `ARG` frame). The native
namespace branch of `l2_emit_stmts` gained `ni >= 0` so a formal operand cannot fall into it, and
the walker's `else` arm wraps the old classification. No new operand category, no registry, no
hidden Structure: the same three sites, each with the expression its own mode already has.

**Witness.** `unit_merge_formal_operand.lm2` (WalkRoot, Entry 7): `R: merge: source extra` gives
`R\x` = 1 and `R\z` = 2 (the later operand's added field joins the first operand's model), exit 7,
native and walked. Focused run `build/l2_harness/k02b_focus_20261001_03` — **GREEN 9 targets**,
the neighbouring merge rows (`unit_merge_actual_operand`, `unit_merge_live_source`,
`unit_merge_value_failure`, `unit_merge_in_method`, `unit_merge_added_repeat`) included.

**Still open in this bullet:** a *runtime-selected* operand — a reference that is a B at one call
and a C at another. The compiler's `mrs` describes one schema, so that case needs the result's
correspondence to follow the ACTUAL operand at runtime (the defect's "общий случай меняющейся
ссылки B/C" and its note that the selector/uses projection had to come first — K01 has now
landed). Not attempted here; it is the natural next slice.

## 3. Next reproductions (not yet repaired)

**A free merge result does not resolve from the caller.** Plan bullet 3 ("Restore caller-local →
inherited input → lexical fallback for a free merge result. A global result-name lookup must not
bypass a dynamic input"). Probe:

```
Model: (int: x 1)
fn: g () int
    int: got
    got: R\x
    return: got
end: g
fn: f () int
    R: merge: Model
    return: g()
end: f
```

On the K02b bytes this is `unknown field path root / frame=got` at the read: a name bound to a
merge result in the caller is not visible to the callee at all. The repair has to give the free
name the plan's order — the caller's local, then an inherited input, then the lexical fallback —
and it must NOT let a global result-name lookup bypass a dynamic input.

**A runtime-selected operand (B at one call, C at another).** Recorded with K02b above: the
compiler's `mrs` names one schema, so the result's correspondence has to follow the ACTUAL
operand at runtime. This is the part of
[MERGE-HELD-OPERAND-LAYOUT](defects.md#merge-held-operand-layout) that its own note defers until
the selector/uses projection lands (K01, now released).

**A merge in a value position.** `return: merge: A` / `return: merge: A B` are refused with
"implements is false in return value" (not with "not lowered in this receiving context"): the
whole block that reads a `return:` value in `l2_collect_method` treats a lone name as a method
definition and a `merge` frame as a CALLABLE merge (`l2_t7_from_return`), which is a different
mechanism expecting a callable operand. A structural merge there would have to register a result
without a destination own field — plan bullet 4's "a destination name is not a first operand, and
a `return` receiver is not an own-field declaration".

## 4. K02c reproduction — the exact site (MERGE-HIDDEN-INPUT-PROJECTION)

Witness `unit_merge_hidden_input.lm2` (the defect's own source, registered as a row): a
unit-level `copy: merge: Model` (value 1), `read` naming the free `copy\value`, and a `caller`
whose OWN `copy: merge: Other` (value 22) calls `read`.  Measured on the K02b bytes
(`build/l2_harness/k02c_repro_20261001_01`): **the program exits 81, not 7** — the free name
took the unit-level result.

The site is the free-name scan's early return, `l2_scan_uses`-region:

```
    # A unit-level declaration or a bound merge result is a name IN SCOPE,
    # reached through the program unit. It is not a free name, so it must
    # not become an untyped dynamic input.
    if: l2_ns_find(t) >= 0 && l2_ns_parent[l2_ns_find(t)] < 0
        return: 0
    if: l2_mres_find(mi, t) >= 0
        return: 0
```

`l2_mres_find(mi, t)` is `l2_mres_of_own(l2_resolved_own(mi, t))`: for `read` the name resolves
to the unit-level own field `copy` (visible through the unit) whose schema IS a merge result, so
the scan classifies it as "in scope, not free" and the caller's own `copy` never becomes a
caller source.  The caller-local priority the plan asks for lives one branch below, where a name
that IS free becomes a dynamic input with `l2_dyn_add(mi, t, ty)`.

Deleting the early return is not the repair: `ty` there is a translator type code, while this
value's schema is a compiler-side tagged merge schema (`l2_schema_merge(res)`), and the
receiving consumers that ask `l2_input_model` want a named namespace.  So the slice needs a
decision on the dynamic-input type space, which is what the design question to Codex
(DS-CODEX-004) asks. (The witness file existed but had no harness row at this point; §5 registers
it, green.)

### DS-CODEX-004 — the reply (2026-10-01, received by fable continuing deepseek's queue)

Codex answered through lmx_uds (read-only consultation, no code changed). The substance, for the
K02c writer:

1. **No new language decision and no invented named model.** A merge result is an ordinary
   Structure value; passing it as a hidden input passes the ordinary Structure reference. A tagged
   composed schema is permitted as TRANSLATOR METADATA only (dictionary v2 §10: absent, named and
   tagged composed schema handles are compiler metadata; consumers assuming every schema is named
   must be generalized). Do NOT store `l2_schema_merge(res)` in the existing `l2_dyn_add(..., ty)`
   slot: its consumers read `ty` as a type code. Keep the transport type, the receiving requirement
   and the known source schema/layout distinct; their representation is an implementation choice.
2. **Resolve the value source first by the universal priority** (semantics §12 "A free name's
   sources have this priority"; plan K02 bullet 3; dictionary §8): caller's nearest current local
   binding → already inherited dynamic input → callee's permitted lexical fallback. In the witness
   the caller's `copy` supplies 22; with no caller/inherited source the eligible lexical copy
   supplies 1. The root `copy` is selected this way; the member `value` is then selected on THAT
   Structure. One valid caller must not establish a universal source layout for every caller.
3. **The seam is the shared source/input projection, not a merge-input route.** The
   `l2_scan_ident` early return on `l2_mres_find` is not sufficient evidence of a local binding,
   and deleting it alone is not the repair. `l2_own_schema` already returns named or tagged
   composed metadata; `l2_input_schema` handles own keys but delegates to named-only
   `l2_input_model`; `l2_hidden_model_source` loses composed information through `l2_input_model`.
   Repair these consistently with downstream path/receiving consumers, native and walker. Keep the
   source evidence attached to the selected input/call site; do not substitute the lexical
   fallback's schema as every caller's actual layout.
4. **K01 does not turn the hidden argument into an individual field target.** The transported
   value stays the selected Structure reference; per-used-access targets are the address lowering
   for paths into the candidate. A requested field is selected by NAME (with its occurrence index
   if present) on the actual candidate; a cached map may implement that but adds no structural
   equivalence requirement. Compiler schema handles must not escape as runtime graph pointers.
5. **Sources and limits:** q52 (hidden-input mutation changes the activation's input, no field);
   `LMX_blog/2026-09-27.md` "Свободное имя при вызове именованной Structure" (same rule for a nullary
   named Structure); q24/q39/q44 do not mandate an integer encoding for dynamic-input schema
   metadata. Do not ask the author to choose tag values or a model name.

Suggested focused acceptance: caller-local override; forwarding through an intermediate caller
with no local copy; lexical fallback when no dynamic source exists; a compatible candidate whose
requested field sits at a different position; native and walker. For a genuinely new contradiction,
send a minimal example back under DS-CODEX-004; otherwise no author decision is needed.

## 5. K02c — the repair: a merge result is an ordinary hidden input (fable, 2026-10-01)

Done along Codex's reply (DS-CODEX-004 above): no new language decision, no named model invented,
no schema Structure, no registry; the existing source/input projection generalized where it was
named-only, and the kernel's walker given the one general mechanism the result needed.

**Translator (`l2trans.lm1`).**
- `l2_scan_ident`: the early return on `l2_mres_find` is now "a merge result bound in THIS scope"
  (`l2_resolved_own` ≥ 0, a merge result, not `l2_own_unit_seen`); the UNIT's merge result seen
  from a method falls to the Q52 branch and becomes the method's hidden input, as `int: total`
  does in `unit_named_struct_hidden_input`.
- `l2_input_schema(mi, k)` is the receiving metadata of ANY input: own-key source, formal's
  declared model, or — new — a hidden input's lexical source schema (`l2_own_schema` of
  `l2_own_lexical`), tagged for a merge result. `l2_input_model` stays named-only and untouched;
  the hidden-input consumers moved to the schema: `l2_hidden_model_source` (a forwarded input),
  `l2_path_root` (a tagged root is walked as a slot map, `res`, like an own merge root),
  `l2_check_fields`' D-97 refusal (keyed on `res` too), `l2_hidden_emit_admit` /
  `l2_d105_emit_source` / `l2_emit_model_admit` (the requirement; `-1` is "none", a tagged value is
  one), `l2_dyn_site` and `l2_d105_close` (sources, edges and pairs of a place by its schema),
  `l2_d105_emit_slot` (the by-name read), `l2_untyped_graph`, `l2_rw_call` / `l2_rw_path` /
  `l2_rw_path_value` / `l2_rw_d105_need` (the walker).
- `l2_model_inst`: a tagged schema is instanced by the merge result ITSELF — the Structure its own
  slot holds (`l2_own_slot_at`), the one place its layout exists at run time. `l2_d105_width`,
  `l2_d105_table`, `l2_admit_paths`, `l2_admit_consumer_at`, `l2_descriptor_used` take a tagged
  requirement (their fields were already read through `l2_schema_*`, K01).
- `l2_dyn_site`: an intermediate caller without a binding INHERITS a graph input unless the name is
  a unit Structure or an eternal branch — `l2_colon_model` had called a merge result a model and
  stopped the inheritance (`mid` read the unit's `copy` instead of forwarding the caller's).
- The walker's model operands (`l2_rw_admit_project`'s ADMIT_AS child 4, `l2_rw_path_value`'s OF
  child 3): a named Structure's `l2_nsp[req]` as before; for a tagged requirement a FRAME in the
  model's place — `l2_rw_own` of the result's own slot (an AT), evaluated where the op runs, since
  the result does not exist when the frames are built. `l2_rw_admit` (the PRIM admit of an
  unknown source) keeps named models only; a tagged requirement always has a known source.

**Kernel (`lmx_walk.lm1`).** `lmx_walk_model_operand(f, operand, @out)`: the model Structure
itself, or a frame (told by role, `lmx_walk_node`) evaluated to a reference; used by ADMIT_AS
(child 4) and OF/PUT_OF (the optional model). `tests/lmx_walk_admit_selftest.lm1` gains the case
"a frame in the model's place is evaluated to the model" and its negative (a frame evaluating to no
reference is INVALID): 34 checks, 0 failures; on HEAD's `lmx_walk.lm1` (the kernel mutant) the new
case fails — recorded below.

**Witnesses** (rows in `l2_harness.ps1`, all `Entry 7` unless said):
- `unit_merge_hidden_input` — the caller's `copy: merge: Other` (22) wins over the unit's (1); was
  81. `unit_walk_merge_hidden_input` — the same, `read` and `caller` walked (`Debt` pins the
  ADMIT_AS).
- `unit_merge_hidden_forward` — through `mid`, which binds no `copy`: inherited input, 22.
- `unit_merge_hidden_lexical` — no caller binding: the unit's result, 1.
- `unit_merge_hidden_position` — the caller's `copy: merge: Wide` (`pad` first): `value` selected by
  NAME through the pair map, 22, never 5.
- `unit_merge_hidden_refused` — the caller's `copy: merge: Bare` has no `value`: refused at
  translation at the call, `11:13: implements is false in function argument` (K01's used-edge
  check on the source).

**Evidence.** Focused `build/l2_harness/k02c_focus_20261001_04` (staged `l2trans.lm1` blob
`273e4185`, `lmx_walk.lm1` `88816478`): **19 targets, 0 failed** — the six K02c rows and the
neighbours `unit_named_struct_hidden_input` (+ walk twin), `unit_merge_formal_operand`,
`unit_merge_actual_operand`, `unit_merge_value_method`, `unit_merge_in_method`, `unit_d105r_formal`,
`unit_d105n_passon`, `unit_walk_d105_perm`, `unit_d105r_edge_refused`. The runs before it record the
repair's path: `_01` the kernel helper without its prototype (driver did not build); `_02` 18/19 —
`forward` red, `mid` read the unit's `copy` (the `l2_dyn_site` inheritance stopped by
`l2_colon_model`); `_03` 18/19 — `lexical` red, the root admitted its own `copy` against its not yet
published cell (`l2_model_inst` keyed on the callee, not the emitted method). Kernel selftest
`lmx_walk_admit_selftest`: 34 checks, 0 failures with the patched walker; on HEAD's `lmx_walk.lm1`
the new case fails ("a frame in the model's place is evaluated to the model (K02c)") — 1 failure.
Mutants through the harness (each restored and re-hashed before the next step):
- M0, the defect itself — HEAD's `l2trans.lm1` (`c1950c3a`) and `lmx_walk.lm1` (`5e2b2377`) with the
  new rows, `build/l2_harness/k02c_mutant_head_20261001_01`: `_input`, `_forward`, `_position` **exit
  81** (read takes the unit's 1), the walk twin lacks its ADMIT_AS, `_refused` is ACCEPTED; `_lexical`
  green by coincidence (1 is the old behaviour too). 5 of 9 targets red, each for the defect's reason.
- M1, the old `l2_scan_ident` early return alone on the K02c bytes (`c04c9cf5`),
  `k02c_mutant_scan_20261001_01`: the four positives red with "gcc exit 1 on the generated C" — NOT
  the witness: with `copy` back in scope, `read` reads the unit's merge result by an own-rooted path
  whose place is now marked (`l2_d105_sub`), so the by-name read is emitted without the reading
  method's `l2_dslot` local (declared only where `l2_d105_any(mi)`). Recorded as "did not reach";
  M0 is the counterfactual for the scan rule. The latent `l2_dslot` gap is a residual below.
- M2, HEAD's kernel walker under the K02c translator (`lmx_walk.lm1` `5e2b2377`),
  `k02c_mutant_kernel_20261001_01`: `unit_walk_merge_hidden_input` red with `lmx: walk error:
  INVALID` (ADMIT_AS finds a frame where it expects the model); `unit_walk_named_struct_hidden_input`,
  `unit_walk_d105_perm`, `unit_merge_hidden_input` (native) stay green.
Full gates on the committed bytes (`l2trans.lm1` `273e4185`, `lmx_walk.lm1` `88816478`):
- generated `build/l2_harness/k02c_full_20261001_01`: **47 of 1128 targets failed** (K03b's
  `k03b_full_20261001_01`: 47 of 1122) — by exact ID and diagnostic the six new rows OK, no newly
  failing target, the 47 retained failures unchanged;
- kernel `build/l2src/k02c_kernel_20261001_01` (`build_l2src.ps1 -Run -KeepAll`): **286 targets, no
  failures**, `lmx_walk_admit_selftest` included;
- L3 `tools/run_l3_selftest.py`: all 11 suites ok, type budget ok.
A bounded improvement on the disclosed red baseline, not the clean-kernel checkpoint.

**Residual.** `unit_merge_hidden_input`'s explicit `node\...` path case (Codex's "explicit physical
path that by the rules does not become a dynamic input") is not a new row: `node\copy\value` in a
method reads the unit's field in place (the `node` root, FABLE-SONNET-NODE-ROOT-20260923-121) and is
untouched by this slice. The runtime-selected operand (B at one call, C at another) of §2 stays
open. A method reading ANOTHER method's marked own by an own-rooted path would emit the by-name
read without its `l2_dslot` local (declared only where `l2_d105_any(mi)`); no real program reached
it (the unit's fields are hidden inputs from a method, `node\…` is a different root), only M1 did.

<a id="merge-atom-spelling"></a>
## 6. K02d — the book's own spelling `b: merge A C`

Status 2026-10-01 (deepseek, continuing fable's queue). Reproductions first, as the plan's §1 asks.

**The norm.** The semantics book spells an explicit merge with the receiver as an ATOM and its
operands after it: `b: merge A C` — "операнды — A и C, внешний b получает результат; имя результата
не является первым операндом merge" (`provenance/semantics-book.md` :980 =
`docs/LMX_semantics.ru.md#composition`, and the English twin :1046). The plan asks for it by that
spelling: K02 bullet 4, "Support the existing `b: merge A C` form … A destination name is not a
first operand". The frame spelling `b: merge: A C` is the other surface form of the same statement,
and it worked; only the book's own spelling did not.

**Reproduction** (K03c's bytes, `build/fable_k02c/stage/bin/l2trans.exe`, source blob `4f612450`;
probes `build/deepseek_k03d/src/`):

| source | HEAD said | P0 shape (printTree) |
| --- | --- | --- |
| `w: merge Model` in a method | `7:8: unresolved name`, `detail: atom=merge` | `frame{head=w, body=[atom merge, atom Model]}` |
| `copy: merge Model` at the unit root | translated, and `copy\x` then `unresolved name atom=x` | the same shape |
| `copy: merge: Model` / `w: merge: Model` | accepted (L1 produced) | `frame{head=copy, body=[frame{head=merge, body=[Model]}]}` |

The unit-level row is the worse of the two: nothing refused. `l2_tail_is_structure` counted the two
atoms as "several items", so the tail was a Structure, `l2_unit_role` made `copy` a **named
Structure**, and the merge never existed at all. In a method the atoms became statements of the new
nested body, and the first one — `merge` — was then an unresolved name. This is also the exact shape
`steps/k03-head-roles-20261001.md` recorded as blocking K03's last item ("`w: merge Model` inside a
method is still `unresolved name`").

**Repair** (two halves, both needed; `dev/l2src_sandbox/l2trans.lm1`):

1. `l2_tail_is_structure`: a tail whose first item is a reserved **receiver written as an atom** is
   that receiver's application — the head's VALUE, exactly as a receiver FRAME already is one branch
   below (`l2_receiver_word`). One rule for the whole receiver list, no branch on a name. Without
   this half the unit-role walk still makes `copy` a named Structure (mutant M2 below).
2. `l2_merge_atom_settle` (new) + `l2_merge_frame`: the atom spelling is settled into the ONE frame
   form `R: merge: A B` — in the tree, once, at the same place the frame spelling is recognized — so
   arity, `l2_mrs_build`, native emission and the walker read one form and no second merge route
   exists. The operand fields keep their own nodes and spans (the new inner frame's body is a
   structure over them); a trailing Structure stays the result-body sibling the frame form carries.
   The statement must be an ordinary binding's (`l2_is_asgn`), so a call of a method, a C door or
   another receiver frame is not this spelling.

Both spellings now settle to the same tree: on the probes the generated L1 is **byte-identical**
(`cmp` on `p_recv`/`p_recv2`, on `p_unitread`/`p_unitread2`, and on the `unit_merge_live_source`
twin with its `merge: Source` line replaced by `merge Source`).

**Witnesses** (rows in `tools/l2_harness.ps1`, all `Entry 7` unless said):

- `unit_merge_atom_receiver` — the method-local atom twin of `unit_merge_live_source`: the copy reads
  the CURRENT cells (`Source\x: 9U` before the merge, 9 in `R`, then `R\x: 12U` leaving Source at 9).
- `unit_merge_atom_operands` (`Entry 4`) — three operands, `R: merge Model B C`: B adds `z`, C's `z`
  joins the appended slot, so `R\[0]z` is C's 3 (the atom twin of `unit_merge_added_repeat`).
- `unit_merge_atom_unit` — the unit-level `copy: merge Model`, read by a method as the free name's
  hidden input (K02c's priority: caller-local → inherited input → lexical fallback; the lexical
  source is the unit's own result, value 1): the shape that was still unresolved.
- `unit_merge_atom_assign_refused` — the destination name already bound (`int: w 5` then
  `w: merge Model`): refused at `10:5`, "assignment value has unknown type", the SAME diagnostic at
  the SAME site as its frame-spelling twin `w: merge: Model`. The row pins that the atom spelling is
  not a new way around the receiving-context refusal; it is not a claim about that message.

**Evidence.**

- Focused `build/l2_harness/dk_atom_focus_02` (22 targets: the four new rows and the merge neighbours
  `unit_merge_live_source`, `_added_repeat`, `_actual_operand`, `_hidden_input`, `_hidden_forward`,
  `_hidden_lexical`, `_hidden_position`, `_hidden_refused`, `_value_failure`, `_in_method`,
  `_last_occurrence`, `_body_repeat`, `_eternal_pair`, `unit_named_struct_hidden_input`): **0 failed**;
  staged `l2trans.lm1` blob `2e4131dd` = the committed bytes.
- M1, only the receiver rule, no settle (`l2trans.lm1` blob printed in the log,
  `build/l2_harness/dk_atom_m1`): all four new rows RED for the intended reason — the three positives
  `l2trans produced no L1` with `unresolved dynamic=R` / `unresolved dynamic=copy` (the result never
  exists, so its field read is unresolved), the refusal row red on its needle (the old refusal,
  `unresolved name`, is not the one the patched bytes give). The seven neighbours stayed green.
- M2, only the settle, no receiver rule (`build/l2_harness/dk_atom_m2`): the method-local rows stay
  GREEN and the unit-level `unit_merge_atom_unit` goes RED (`11:14: unresolved name` — `copy` is a
  named Structure again). This is why BOTH halves are in the slice, and it is the executed contrast
  between them.
- Full gate `build/l2_harness/dk_atom_full_01` (K03c's committed result: 37 of 1132): **37 of 1136**
  targets failed — the four new rows OK, no newly failing target, and the 37 retained failures
  unchanged by exact ID and diagnostic (`build/fable_k03b/compare_full.py` against
  `k03c_full_20261001_01`; the only name-level difference is fable's own K03c re-authoring,
  `unit_named_struct_guard_call_refused` → `unit_named_struct_call_body_retained`, which the
  pre-commit K03c run still carried). Staged `l2trans.lm1` blob `2e4131dd` = the committed bytes.
  Kernel and L3 sources are untouched by this slice (the translator build is the only changed
  input), so those gates are not re-run here.
- `python tools/check_docs.py` OK, `tools/gate_p0_header.ps1 -Root .` OK (47 P0 defines, 7 files),
  `git diff --check` clean.

**Residuals (not this slice).** A merge in a value position — `return: merge: A B` and a `return`
receiver as a destination (the plan's "a `return` receiver is not an own-field declaration") — is
still refused by the receiving-context path; the atom spelling is not a way to write those. The
runtime-selected operand of §2 and the `l2_dslot` gap above are untouched. `b: merge` with no
operands is not the frame spelling's parse shape (the frame spelling `b: merge:` is a P0 parse error,
"tail-cutter target is not valid for this receiver"), so the two spellings cannot be compared there.
Other receivers written as atoms (`cast x`, `sizeof T`) now classify as their application like
`merge` does, but their atom-spelling LOWERING is each receiver's own contract and was not measured
here.

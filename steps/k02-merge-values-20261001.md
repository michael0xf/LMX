# K02 — ordinary merge values (next_core_tasks_v2.md, §2)

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
(DS-CODEX-004) asks; until then the slice stays open and the witness is registered red-by-design
in the row above.

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

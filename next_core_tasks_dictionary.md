# next_core_tasks_dictionary — implementation / semantic map

Lead invariant: **ALL LANGUAGE RULES ARE UNIVERSAL.** Exceptions and contradictions are surfaced explicitly for author discussion; they are never silent specials.

This file is an implementation/semantic map, **not** a second schedule. Ownership and progress stay in `next_core_tasks.md` / `steps/`. Provenance of author rulings stays in each article.

Statuses (never collapse into ready):
- **Norm:** `accepted` | `unresolved`
- **Implementation:** `absent` | `partial` | `present` | `divergent`
- **Verification:** `none` | `fixture` | `generated-L1` | `runtime` | `native+interp`

Baton: `DICT-GROK-BOT-20260922-01` + … + **`AUTHOR-DOC-BOUNDARY-20260922-21`** (plan only in this file + `next_core_tasks.md`; specs normative-only; RELEASE → DeepSeek).

Writer: Grok Bot (first sequential documentation baton). **No commit** this pass. RELEASE for next named writer after this file is saved.

## Decision graph (universal resolved-binding priority)

```
head resolution
  -> if callable binding     => call   (call-first; no assignment fallback)
  -> if non-callable binding => assignment (full admission/implements)
  -> if absent name          => declaration ONLY when type is explicit in the construction; else error
```

Provenance: `next_core_tasks.md` section 3 / universal binding priority (`GROK-BOT-CLEAN-PLAN-CORRECT-20260922-12`). No name/syntax exception.

## Dependency order (ending)

1. `clean-kernel` (GATE before section 8)
2. exact pushed checkpoint (harness + check_docs + diff --check green)
3. migration / `self-build` (section 8)
4. `manager` (`myxa_manager`, section 9)

<a id="architectural-placement"></a>
## `architectural-placement`

- **level:** Cross-cutting AUTHOR doctrine (all layers; docs + implementation acceptance)
- **Norm:** `accepted` — AUTHOR-ARCH-DOCTRINE-20260922-17. Every decision must be architectural, not a local patch. When a required contract is missing, **STOP and ask the author directly**; never fill the gap with a name-special parser branch, allowlist, header scanner, hidden registry, shim, fallback, or extra field in a base kernel type.
- **Implementation:** N/A as a single mechanism; governs how mechanisms are placed. Existing violations are **cleanup debt** blocking the clean-kernel checkpoint before self-build.
- **Verification:** Clean-kernel GATE + inventory of residual specials/shims/extra base fields; docs parity RU/EN; no invented contracts while OPEN.
- **definition:** Place new demand as a **separate type / receiver / library / adapter at the correct layer**. Do not mutate a lower abstraction to satisfy one consumer.
- **invariants:**
  - Architectural decision over local patch.
  - Missing contract ⇒ STOP + ask author (never invent).
  - Anti-patterns below are FORBIDDEN replacements for missing architecture.
- **anti-patterns and replacements:**
  1. **`c.*` raw door:** Translator must not separately recognize `c.sizeof` / `c.puts` / other names, parse `*.h`, or construct an "allowed C" dictionary. Invalid raw C is diagnosed by the C toolchain. Lmx needs use ordinary language receivers/libraries, not `c.*` special semantics. → [`c-raw-door`](#c-raw-door); Lmx sizing → [`sizeof-receiver`](#sizeof-receiver) (contract OPEN).
  2. **Base Array:** Keep minimal `{len, data}` invariant. Dynamic growth belongs to a separate List/ArrayList implementation. Never add capacity or policy fields to Array for one consumer.
  3. **Base Message:** Stay minimal kernel graph/scheduling/message machinery. Win32 UI and application state belong in adapters/application structures referenced through ordinary composition — never embedded into Message.
  4. **Future similar demand:** Add a separate type/receiver/library/adapter at the correct layer; do not mutate the lower abstraction.
- **not-confused-with:** Local "quick fix" branches; feature flags inside base kernel types; name allowlists as semantics.
- **links:** [next_core_tasks doctrine](next_core_tasks.md#architectural-doctrine); [clean-kernel-acceptance](#clean-kernel-acceptance); GATE in next_core_tasks.md; blog 2026-09-22.
- **sources:** AUTHOR-ARCH-DOCTRINE-20260922-17; standing AUTHOR-C-RAW-DOOR-20260922-14; AUTHOR-SIZEOF-OPERATOR-20260922-19.
- **impl files/functions:** Cross-cutting; inventory violations under GATE / DeepSeek scanner ownership where applicable.
- **witnesses:** Clean-kernel checkpoint (future); residual violation inventory is debt until closed.
- **gap:** Existing code/docs violations remain cleanup debt until GATE green.
- **positive:** New capability appears as ordinary typed/receiver/library/adapter placement without widening a base kernel record.
- **forbidden:** Name-special parser branch; allowlist; header scanner; hidden registry; shim; fallback; extra field on base Array/Message/Lmx for one consumer; inventing contracts while genuinely OPEN; do **not** invent a global `sizeof:` argument/result HOLD — withdrawn (-18/-19). `sizeof:` is planned/ввести under DESIGN-20; do not invent HOLD/OPEN.
- **cross-level:** Applies to L1/L2/L3 and adapters; L3 never receives raw `c.*` leaks.

---

<a id="clean-kernel-acceptance"></a>
## `clean-kernel-acceptance`

- **level:** Cross-cutting acceptance section (blocking before L2 self-build / §8)
- **Norm:** `accepted` as GATE criteria — AUTHOR-ARCH-DOCTRINE-20260922-17 + GROK-BOT-C-DOOR-UNIFY clean-kernel GATE. Existing architectural-placement violations are **cleanup debt** that block the clean-kernel checkpoint.
- **Implementation:** Must reach zero specials / zero stale `c.*` machinery / zero duplicate discard paths / zero hidden fallbacks / zero contradictory docs on one pushed SHA (see next_core_tasks GATE). Docs-only passes may advance documentation debt without claiming GATE closed.
- **Verification:** Full supported L2 harness, relevant L3 runner, `python tools/check_docs.py`, `git diff --check` green on one exact pushed commit; source inventory of removed helpers has zero references.
- **definition:** Clean kernel means architectural-placement anti-patterns are absent from the tracked supported surface, and the GATE checklist in `next_core_tasks.md` is simultaneously true.
- **invariants:**
  - No name-special `c.*` semantics; raw door only.
  - No capacity/policy fields on base Array; List separate.
  - No Win32/UI/app state embedded in base Message.
  - No invented contracts while genuinely OPEN; `sizeof:` has no global-contract HOLD.
- **not-confused-with:** Partial local cleanup that leaves shims; claiming self-build-ready while L1 `c.array` debt is unowned.
- **links:** [architectural-placement](#architectural-placement); next_core_tasks.md GATE; [`c-raw-door`](#c-raw-door).
- **sources:** AUTHOR-ARCH-DOCTRINE-20260922-17; GROK-BOT-C-DOOR-UNIFY-20260922-11 GATE.
- **gap:** Debt inventory until GATE; CODE PAUSED / discard STOP still govern implementation workstreams.
- **forbidden:** Declaring clean-kernel / self-build-ready while anti-pattern debt remains; treating named language receivers as automatic debt; inventing `c.sizeof` specials.

---

<a id="c-raw-door"></a>
## `c-raw-door`

- **level:** L2->C emission
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** `c.*` is a **raw door into C**. There is NO declared foreign-entity registry, NO header scanning for a C-name dictionary, NO generated dictionary of C entities, and NO classification of `c.sizeof` / `c.puts` as declared/builtin entity kinds. `c.sizeof(...)` lowers through the general raw-C door to C `sizeof(...)`; the **C compiler** supplies unevaluated sizeof semantics. `c.puts(...)` passes through the same raw-C door without a name-specific L2 checker/emitter.
- **invariants:** Syntax-transparent passthrough of `c.<name>(...)` into valid C; L2 does not resolve `c.*` against L2 value bindings as language entities.
- **not-confused-with:** foreign-namespace / foreign-callable / foreign-type / foreign-operator **as declared L2 entity kinds** (FORBIDDEN after AUTHOR-C-RAW-DOOR-20260922-14); L2 binding-KIND (applies to L2 callables, not a C registry).
- **links:** requires=clean emission path to C; produces=valid C text for c.* forms; consumes=P0 Frame/atoms under c.* heads; selects=none
- **authoritative sources:** AUTHOR-C-RAW-DOOR-20260922-14; next_core_tasks.md section 7a Raw-C door; overrides GROK-BOT-C-DOOR-EVIDENCE-20260922-13 entity-kind HOLD
- **implementation (files/functions):** `dev/l2src_sandbox/l2trans.lm1` inventory candidates: `l2_c_header_walk`, `l2_c_header_chain_has`, `l2_c_header_chain_has_typedef`, `l2_predef_has_function`, `l2_predef_has_type`, `l2_predef_has_fnptr`, `l2_foreign_intern`, `l2_c_stmt_door`, `l2_c_door`, `l2_simple_puts_main`, `l2_emit_ccall` (UNKNOWN exact role of each until inventory). DeepSeek previously tasked by author to remove scanners/dictionaries — coordinate, do not duplicate.
- **witnesses:** entry_puts_* (20 ungated); unit_c_empty_call.lm2; UNKNOWN full matrix
- **open gap to next_core_tasks.md:** section 7a Raw-C door tasks + GATE zero stale scanners/dictionaries/whitelists; coordinate DeepSeek ownership
- **positive behavior:** `c.sizeof(T)` -> C `sizeof(T)`; `c.puts(s)` -> ordinary raw-C call emission; `c.rand()` via same door
- **forbidden / contrast:** FORBIDDEN: scanning *.h to populate a C-name dictionary; resolving c.* against L2 bindings as semantic entities; pre-evaluating operands in a way that changes raw C semantics; name-specific branches for puts/sizeof/array; inventing an entity-kind registry. Preserve only mapping rules required to emit valid C; label unknown mechanics for audit.
- **cross-level projection:** L1 may still spell c.* in generated output; that is emission surface, not an L2 foreign-entity model.



<a id="doc-boundary"></a>
## `doc-boundary`

- **level:** Documentation process (AUTHOR-DOC-BOUNDARY-20260922-21)
- **Norm:** Specifications must not contain conversations or plans. Current plan lives only in `next_core_tasks.md` and this dictionary. Chronology → `LMX_blog` (historical, not normative). Specs may state terse accepted semantics (e.g. `c.*` = raw C door) without ticket IDs, status, or planned features.
- **Implementation:** N/A
- **Verification:** Scoped diff of specs vs pre-ticket HEAD shows only intended normative `c.*` door correction; no planned `sizeof:` in specs; `check_docs`; `git diff --check`.
- **sources:** AUTHOR-DOC-BOUNDARY-20260922-21

---
<a id="sizeof-receiver"></a>
## `sizeof-receiver`

- **level:** Planned L2 language **receiver-operator** (same architectural class as receiver `fn:` once introduced — a receiver is **not** a function/callable). Never `c.*`.
- **Norm:** `accepted` as **design choice** — AUTHOR-SIZEOF-DESIGN-20260922-20 (clarifies / overrides overstatements in -19). A size operation is needed by current work. Instead of retaining separate L2 parsing/checking/emission for raw `c.sizeof`, we **choose to introduce** a normal language receiver-operator `sizeof:`. This is a new architectural design/implementation task, more coherent than a `c.sizeof` special case. Until implemented, status is **absent/planned**, not a violated pre-existing obligation and not a HOLD awaiting another author contract.
- **Implementation:** `absent` / planned. Later bounded ticket after docs baton/ownership order: introduce `sizeof:` into the existing receiver-operator architecture (do not model as function/callable). Remove `c.sizeof`-specific L2 parser/checker/emitter; keep `c.sizeof(...)` only as raw C text through the uniform [`c-raw-door`](#c-raw-door) where raw C is intentionally used.
- **Verification:** none yet. After introduction: receiver-operator dispatch + surface-form equivalence + native+interpreter; `rg` finds zero `c.sizeof`-specific semantic branches.
- **definition:** Planned L2 language receiver-operator for Lmx structure/storage size. Not yet present in the translator/interpreter as an obligation; not raw C `sizeof`.
- **invariants:**
  - Design = introduce `sizeof:` under receiver-operator architecture; never as callable/function.
  - Until landed: **planned**, not “already required” / “translator must already recognize”.
  - Do **not** generalize this ticket into judgments about `length` / `capacity` / etc.
  - Zero `c.sizeof`-specific L2 parser/checker/emitter semantics.
- **not-confused-with:** [`c-raw-door`](#c-raw-door); C `sizeof`; function/callable; claims that sizeof already follows automatically from the language.
- **links:** [next_core_tasks §7a](next_core_tasks.md); [L2 sizeof-receiver](docs/L2_spec_ru.md#sizeof-receiver); blog 2026-09-22.
- **sources:** AUTHOR-SIZEOF-DESIGN-20260922-20 (authoritative clarification); AUTHOR-SIZEOF-OPERATOR-20260922-19 (partially overstated “already know”); AUTHOR-SIZEOF-UNHOLD-20260922-18; AUTHOR-C-RAW-DOOR-20260922-14; AUTHOR-ARCH-DOCTRINE-20260922-17.
- **impl files/functions:** UNKNOWN pending later bounded ticket (`l2_prep_sizeof_name` / former `c.sizeof` specials inventory).
- **witnesses:** none yet — add with implementation ticket.
- **gap:** Implementation of `sizeof:` (ввести) after docs baton/ownership order. No HOLD/OPEN for another author contract.
- **positive (once introduced):** `sizeof:` participates in existing receiver-operator architecture; Lmx size asks use it instead of L2 `c.sizeof` specials.
- **forbidden:** Claiming translator/interpreter are already obliged to recognize `sizeof`; modeling `sizeof:` as function/callable; `c.sizeof`-specific L2 semantics; HOLD/OPEN invented for a global sizeof contract; generalizing this decision to length/capacity/etc. under this ticket.
- **cross-level:** L3 has no raw C sizeof/memory-size primitive; higher-level size ops are declared receivers/operators when introduced, not `c.*` leaks.


## `structure`

- **level:** L2
- **Norm:** accepted
- **Implementation:** present
- **Verification:** runtime
- **definition:** Structure is the graph-shaped composite value / descriptor host.
- **invariants:** Nonprimitive reference projection applies
- **not-confused-with:** array; frame; merge-construction
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `surface-form-equivalence`

- **level:** P0/L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Parenthesized, short/colon, vertical/block forms are equivalent after P0 normalization.
- **invariants:** No semantic branch tables on COMPACT/COLON
- **not-confused-with:** call-first vs surface flags
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `frame`

- **level:** P0
- **Norm:** accepted
- **Implementation:** present
- **Verification:** none
- **definition:** Normalized callable/update container (head, body, flags, trailer).
- **invariants:** One normal zero-arg Frame for closed empty forms; incomplete f: rejected at P0
- **not-confused-with:** anonymous-container-transparency; bare atom
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `anonymous-container-transparency`

- **level:** P0/L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Sole anonymous Structure of entire arg list is transparent.
- **invariants:** Empty Structure remains a real value
- **not-confused-with:** empty-argument-sequence; empty-structure-value; P0 HOLD
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `empty-argument-sequence`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Zero consumed args for nullary callable.
- **invariants:** Distinct from empty Structure as one value
- **not-confused-with:** empty-structure-value
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `empty-structure-value`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Empty Structure/unit is a real value needing opaque/named position as one argument.
- **invariants:** Not empty arg list
- **not-confused-with:** empty-argument-sequence
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `head-resolution`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Resolve head to binding/method before call/assign/decl.
- **invariants:** Universal; no name/syntax exception
- **not-confused-with:** binding-kind; call-first
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `binding-kind`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Resolved KIND: method/callable field invoke; typed fnptr value evaluate/discard without call.
- **invariants:** KIND not COMPACT/COLON flags
- **not-confused-with:** call-first; fnptr-value-discard
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `call-first`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Callable head always calls; failure stays call error; no assignment fallback.
- **invariants:** Across surfaces
- **not-confused-with:** binding-kind
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `fnptr-value-discard`

- **level:** L2
- **Norm:** accepted
- **Implementation:** absent
- **Verification:** none
- **definition:** Expression-statement: typed fnptr discards without call; method invokes; no admission on discard; typed l2_tN; void never undeclared temp.
- **invariants:** Not l2_new_temp as universal allocator
- **not-confused-with:** call-first
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `explicit-typed-declaration`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Declaration when type is explicit in the construction.
- **invariants:** Absent name alone does not declare
- **not-confused-with:** structural-declaration
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `structural-declaration`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Type given by Structure on the right (merge-normalize path).
- **invariants:** One construction path
- **not-confused-with:** merge-construction
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `merge-construction`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** merge builds/combines Structures.
- **invariants:** No emitter-only shortcut
- **not-confused-with:** structural-declaration; implements
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `nonprimitive-reference-projection`

- **level:** L2/L1
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Nonprimitives project as Lmx *; no C by-value aggregate.
- **invariants:** @ adds address-of-cell level
- **not-confused-with:** l2-address-of
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `l2-address-of`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** L2 @name addresses canonical local cell; sticky dirty.
- **invariants:** Address does not switch to graph slot
- **not-confused-with:** l2-address-slot; sticky
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `l2-address-slot`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** @: Type slot lowers to pointer-to-cell consistent with reference projection.
- **invariants:** Matches nonprimitive projection
- **not-confused-with:** l2-address-of
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `l3-reference-receiver`

- **level:** L3
- **Norm:** unresolved
- **Implementation:** absent
- **Verification:** none
- **definition:** L3 reference/receiver rules — detailed map UNKNOWN this baton.
- **invariants:** Open for next writer vs LMX_semantics
- **not-confused-with:** l2-address-of
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `binding`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Named typed association in activation or unit.
- **invariants:** Universal resolution input
- **not-confused-with:** occurrence
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `occurrence`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Repeated same-name fields as distinct occurrences.
- **invariants:** Lexical order preserved
- **not-confused-with:** occurrence-selector
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `occurrence-selector`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Selects current occurrence as future publication target.
- **invariants:** Not a second name journal
- **not-confused-with:** selector; occurrence
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `canonical-local-cell`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** One stable physical cell per logical activation-local name.
- **invariants:** Bare name and @name use this cell
- **not-confused-with:** sticky; dirty
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `selector`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Publication target selector for current occurrence.
- **invariants:** Updates pending snapshot on switch
- **not-confused-with:** occurrence-selector; checkpoint
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `sticky`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** After any @name, logical local sticky to end of activation.
- **invariants:** Independent of bind timing
- **not-confused-with:** dirty; canonical-local-cell
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `dirty`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Pending write state published at checkpoints when sticky.
- **invariants:** Conservative publish when sticky
- **not-confused-with:** checkpoint
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `checkpoint`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Point where graph publication may occur from canonical cell.
- **invariants:** Emit via checkpoint helpers
- **not-confused-with:** dirty; sticky
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `admission`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Semantic gate before store/pass (implements/uses).
- **invariants:** Must pass implements call point
- **not-confused-with:** implements; uses
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `implements`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** implements relation between descriptors.
- **invariants:** Port after sections 2-6 green
- **not-confused-with:** admission; uses
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `uses`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** uses(Consumer, bVar) analytic + runtime validation.
- **invariants:** Real Consumer required
- **not-confused-with:** implements
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `identity-admission`

- **level:** L2
- **Norm:** accepted
- **Implementation:** divergent
- **Verification:** none
- **definition:** candidate==required may succeed but must still call implements.
- **invariants:** No early bypass
- **not-confused-with:** empty-uses-admission
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `empty-uses-admission`

- **level:** L2
- **Norm:** accepted
- **Implementation:** divergent
- **Verification:** none
- **definition:** Empty uses may succeed but must pass implements point.
- **invariants:** Same call obligation
- **not-confused-with:** identity-admission
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `array`

- **level:** L2/kernel
- **Norm:** accepted
- **Implementation:** present
- **Verification:** runtime
- **definition:** Base Array is {len,data}.
- **invariants:** Growth/capacity on List not Array
- **not-confused-with:** list; l2-c-array-removal
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `list`

- **level:** L2/kernel
- **Norm:** accepted
- **Implementation:** present
- **Verification:** none
- **definition:** Dynamic List separate from base Array (KIND_LIST).
- **invariants:** Not base Array
- **not-confused-with:** array
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `arena`

- **level:** L2/runtime
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Message/unit arena owning graph storage.
- **invariants:** Ownership lifetime
- **not-confused-with:** storage-owner
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `storage-owner`

- **level:** L2/runtime
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Owner responsible for lifetime of cells/graphs.
- **invariants:** With arena
- **not-confused-with:** arena; reachability
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `reachability`

- **level:** L2/runtime
- **Norm:** unresolved
- **Implementation:** absent
- **Verification:** none
- **definition:** Reachability for collection — detailed map UNKNOWN this baton.
- **invariants:** Open
- **not-confused-with:** arena
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `c-puts-passthrough`

- **level:** L2->C
- **Norm:** accepted
- **Implementation:** divergent
- **Verification:** fixture
- **definition:** c.puts uses raw-C door only; remove name-specific checker/emitter/simple-main.
- **invariants:** Same door as other c.*
- **not-confused-with:** c-raw-door
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `l2-c-array-removal`

- **level:** L2
- **Norm:** accepted
- **Implementation:** divergent
- **Verification:** none
- **definition:** L2 c.array special declarator removable; use language arrays or ordinary raw-C/library mechanisms.
- **invariants:** Declarator not call
- **not-confused-with:** c-raw-door; array
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `l1-c-array-measurement-boundary`

- **level:** L1
- **Norm:** unresolved
- **Implementation:** present
- **Verification:** none
- **definition:** L1 [] vs c.array distinct emitters; RO equivalence before removal schedule; not L2 semantics.
- **invariants:** Separate owned debt
- **not-confused-with:** l2-c-array-removal
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `clean-kernel`

- **level:** process/L2
- **Norm:** accepted
- **Implementation:** absent
- **Verification:** none
- **definition:** Blocking GATE before self-build: zero specials/duplicates/shims/hidden fallbacks; zero stale header scanners/C dictionaries/whitelists; green harness+docs on one pushed commit.
- **invariants:** Required before section 8
- **not-confused-with:** self-build
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `self-build`

- **level:** L2
- **Norm:** accepted
- **Implementation:** absent
- **Verification:** none
- **definition:** L2 builds own units after clean-kernel.
- **invariants:** Depends on GATE
- **not-confused-with:** clean-kernel; manager
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `manager`

- **level:** app
- **Norm:** accepted
- **Implementation:** absent
- **Verification:** none
- **definition:** myxa_manager atop verified kernel after L2 self-build.
- **invariants:** One reproducible entrypoint
- **not-confused-with:** self-build
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## Explicit non-articles (FORBIDDEN after AUTHOR-C-RAW-DOOR-20260922-14)

Do **not** define L2 semantic articles as declared `foreign-namespace`, `foreign-callable`, `foreign-type`, or `foreign-operator` registries. Those framings are superseded by `c-raw-door`. Mapping rules required to emit valid C are audited as mechanics under `c-raw-door` without becoming an entity dictionary.

## RELEASE

- File: `C:\Nyasha_Planet\LMX\next_core_tasks_dictionary.md`
- Status: **WIP saved, not committed**
- **RELEASED for DeepSeek baton** (AUTHOR-DOC-BOUNDARY-20260922-21).
- Plan locus: **only** `next_core_tasks.md` + this dictionary (`sizeof:` planned/ввести; `c-raw-door`; architectural-placement; clean-kernel-acceptance; doc-boundary).
- Specs: normative only — terse `c.*` raw door; **no** planned `sizeof:` / ticket chatter.
- Blog: historical chronology; intermediate spec expansions superseded.
- No commit from this docs pass.

# next_core_tasks_dictionary — implementation / semantic map

Lead invariant: **ALL LANGUAGE RULES ARE UNIVERSAL.** Exceptions and contradictions are surfaced explicitly for author discussion; they are never silent specials.

This file is an implementation/semantic map, **not** a second schedule. Ownership and progress stay in `next_core_tasks.md` / `steps/`. Provenance of author rulings stays in each article.

Current semantic correction (author, 2026-10-02): use the [v2 front queue](next_core_tasks_v2.md#critical-pointer-to-struct-bug). Structure A is held by reference; @A addresses that reference cell (Lmx** conceptually). For absent b, b: A equals @: b A; b: args applies the selected Structure, and @: b B explicitly reassigns. Preserve the written source body and repeated declaration occurrences. The older measured symbol inventories below remain historical evidence, not alternative address/application rules.

Evidence discipline: unless a current checkpoint is explicitly identified, the detailed symbol/line inventories and old fixture results below are historical measurements, not proof of the current contract. In particular, tests of implicit model cloning or of @Structure returning the descriptor without the required extra level must be corrected, not reused as acceptance. This documentation update does not mark the new implementation complete.

Statuses (never collapse into ready):
- **Norm:** `accepted` | `unresolved`
- **Implementation:** `absent` | `partial` | `present` | `divergent`
- **Verification:** `none` | `fixture` | `generated-L1` | `runtime` | `native+interp`

## Decision graph (universal resolved-binding priority)

```
application in its receiving context
  -> reserved language receiver => its declared operator contract
  -> signature description     => describe, do not execute
  -> existing Structure/callable head => call (no assignment fallback)
  -> existing primitive/explicit reference head => assignment with admission
  -> unknown ordinary head     => define named Structure; do not execute its body
```

An unknown actual in an existing head's call is an error, not a declaration. Unknown nested heads retain their written bodies; known nested callables remain ordinary operators, not definition-time execution. **Current correction, 2026-10-02:** absent-b `b: A` equals `@: b A`; ordinary `b: args` applies the selected Structure, and `@: b B` explicitly reassigns. Repeated declarations retain distinct occurrences. The address level of unary `@A` is never erased by signature transport. See the v2 plan's two stages following critical_graph_bug.

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
  1. **`c.*` raw door:** Translator tests no concrete C names (not printf, sizeof, LmxArena, puts, array, or any other). No allowlist, header scan, or C-name dictionary. Invalid raw C is diagnosed by the C toolchain. Lmx needs use ordinary language receivers/libraries, not `c.*` special semantics. → [`c-raw-door`](#c-raw-door); Lmx sizing → [`sizeof-receiver`](#sizeof-receiver) (planned receiver-operator, not a HOLD).
  2. **Base Array:** `VoidArray {size_t size, void *data}`, embedded by value as the first member `Lmx.array`, with no separate `LmxArrayDesc` alias; its backing is registered in the arena range index. Dynamic growth belongs to a separate List/ArrayList implementation. Never add capacity or policy fields to Array for one consumer. This physical ABI migration is implemented (`c955f24`; `steps/voidarray-migration.md`): `Lmx` embeds `array` first, then `parent` and direct `native`. `lmx_dynarray_layout_selftest` and `gate_dynarray_capacity.ps1` witness the separate fixed/dynamic layouts. Remaining Array-formal and walked-value projection gaps are not unfinished physical layout migration.
  3. **Base Message:** Stay minimal kernel graph/scheduling/message machinery. Win32 UI and application state belong in adapters/application structures referenced through ordinary composition — never embedded into Message.
  4. **Future similar demand:** Add a separate type/receiver/library/adapter at the correct layer; do not mutate the lower abstraction.
- **not-confused-with:** Local "quick fix" branches; feature flags inside base kernel types; name allowlists as semantics.
- **links:** [next_core_tasks doctrine](next_core_tasks.md#architectural-doctrine); [clean-kernel-acceptance](#clean-kernel-acceptance); [no-defensive-kernel](#no-defensive-kernel); GATE in next_core_tasks.md; blog 2026-09-22.
- **sources:** AUTHOR-ARCH-DOCTRINE-20260922-17; standing AUTHOR-C-RAW-DOOR-20260922-14; AUTHOR-SIZEOF-OPERATOR-20260922-19.
- **impl files/functions:** Cross-cutting; inventory violations under GATE scanner ownership where applicable.
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

<a id="no-defensive-kernel"></a>
## `no-defensive-kernel`

- **level:** architecture / kernel construction
- **Norm:** `accepted` — AUTHOR doctrine for base kernel types (ticket REMOVE-4DA4658-DEFENSIVE-CLOSE-20260922-53).
- **definition:** Kernel invariants are guaranteed **by construction and by tests**, not by defensive state machines inside base kernel types. A base type does not grow CLOSING/POISONED (or equivalent) resume/diagnostic states, stored close stages, repeated internal-invariant validation, partial-recovery wrappers, or policy that papers over a broken invariant. Arena-per-thread plus mutual timeouts are the intended protection. Semantically required admission, ownership, and protocol operations remain part of the universal algorithm; this forbids only *defensive* machinery layered on top of a failed construction.
- **implementation:** Removal of the 4da4658 defensive close package from `LmxRoot` (no `LMX_ROOT_CLOSING` / `LMX_ROOT_POISONED`, no `close_stage` / stored `close_deadline`, no `lmx_root_arena_blocks_valid` / `lmx_root_release_final` poison path). Close is ordinary linear sync with a **local** deadline and process watchdog only.
- **verification:** Residual scan for forbidden symbols; focused + full `build_l2src`, L3, harness, `check_docs.py`, bounded `git diff --check`.
- **links:** [architectural-placement](#architectural-placement); [clean-kernel-acceptance](#clean-kernel-acceptance).
- **forbidden:** Defensive state machines, partial-resume close, poison-and-keep-handle policy in base kernel types; inventing recovery where construction/tests should have refused earlier.
- **positive:** Broken ownership/protocol fails at the admitting/operating step; teardown stays linear; diagnosis lives in tests and tools, not in extra kernel states.


<a id="c-raw-door"></a>
## `c-raw-door`

- **level:** L2->C emission
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** `c.*` is a **raw door into C**. There is NO declared foreign-entity registry, NO header scanning for a C-name dictionary, NO generated dictionary of C entities, and NO classification of any concrete C spelling as a declared/builtin L2 entity kind. Examples: `c.printf("%d", x)` — `c.printf` is raw C, `x` is an ordinary L2 expression; `c.sizeof(c.LmxArena)` — both tokens are raw C, and C supplies sizeof/type semantics. Planned `sizeof: value` is the separate Lmx receiver-operator ([`sizeof-receiver`](#sizeof-receiver)), not a `c.*` special.
- **invariants:**
  - Every token spelled `c.*` is a raw C name. The translator copies it as C text. C supplies the meaning.
  - Every non-`c.*` argument inside the construct is an ordinary L2 expression and follows general L2 expression lowering.
  - The translator tests **no concrete C names at all**: not printf, sizeof, LmxArena, puts, array, or any other. No allowlist, header scan, dictionary, or name-specific parser/checker/emitter.
  Classification is uniformly by token namespace `c.*` versus ordinary L2 expression, never by concrete name. Neither raw-text-everything nor evaluated-everything.
- **not-confused-with:** foreign-namespace / foreign-callable / foreign-type / foreign-operator **as declared L2 entity kinds** (FORBIDDEN after AUTHOR-C-RAW-DOOR-20260922-14); L2 binding-KIND (applies to L2 callables, not a C registry).
- **links:** requires=clean emission path to C; produces=valid C text for c.* forms; consumes=P0 Frame/atoms under c.* heads; selects=none
- **authoritative sources:** AUTHOR-C-RAW-DOOR-20260922-14; next_core_tasks.md section 7a Raw-C door; overrides GROK-BOT-C-DOOR-EVIDENCE-20260922-13 entity-kind HOLD
- **implementation (files/functions):** `dev/l2src_sandbox/l2trans.lm1` — measured roles (definitions at the given lines): `l2_c_door` `:8911` (expression door; delegates to the statement door, `:8912-8914`), **`l2_c_stmt_door` `:8918`** (the statement door: accepts a `c.<name>` head and returns 0 for the three excluded forms at `:8921` — `c.sizeof`, `c.puts`, `c.array`), `l2_predef_has_fnptr` `:3906`, `l2_predef_has_type` `:4011`, `l2_c_header_walk` `:4197`, `l2_c_header_chain_has` `:4295`, `l2_c_header_chain_has_typedef` `:4325`, `l2_predef_has_function` `:4545`, `l2_foreign_intern` `:4576`, `l2_simple_puts_main` `:2388`, `l2_emit_ccall` `:14178`. Door prerequisites are the `l2_need_*` include flags (`:200` string, `:201` stdlib, `:231` p0, `:232` query, `:233` own, `:234` diag). **The five header/predef scanners above are the debt the GATE targets** — they are the C-entity machinery this article's invariant says must not exist.
  **MEASURED BOUNDARY — the door cannot declare storage.** It covers calls (`c.<name>(...)`) and constants (`l2_upper_name` `:8928`, compile-time names). **Type operands are NOT a door route today:** `c.sizeof(T)` is emitted by the name-specific branch `:12822-12850` (textual re-spelling of the operand), which the door EXCLUDES at `:8921`; the door itself has no type-operand path. There is **no** general route to a *local raw buffer* through it. That is why removing `c.array` costs a heap allocation plus a failure path rather than a syntax swap — see [`l2-c-array-removal`](#l2-c-array-removal).
  **CURRENT LOWERING, measured (matches the three invariants; not a second model).** The HEAD `c.<name>` is never resolved (`l2_c_stmt_door` `:8922`: any `c.`-prefixed spelling is the door). Arguments are ordinary L2 expressions: statement form `:11546-11560` (`l2_check_fields` over the body; a door call may have NO arguments, `:11548`), expression form `:12815` → `l2_emit_ccall` `:14178` → `l2_emit_fields` `:13289`. In `l2_emit_fields`, a `c.*` atom or a literal is copied VERBATIM (`l2_tok_text` `:12174-12193`); a non-`c.*` L2 binding is resolved, and an own/path operand is LOADED (`l2_emit_path_load` `:13337`). So `c.printf("%d", x)` copies `c.printf` and loads `x`. Corpus at `20911ad7` (13 fixtures + 8 ports, 21 files): operands are 16 `c.<Type>` atoms, 3 `(@: T)`, 11 bare L2 names, 11 designators. First two classes are raw C tokens; last two are L2 expressions.
  **IMPLEMENTABILITY — what rule 3 deletes.** The `:8921` exclusion list (`c.sizeof`, `c.puts`, `c.array`) is a concrete-name test and must go. The `c.sizeof` emission branch `:12815`/`:12822-12850` is a second concrete-name test and must go, together with its operand type-name table `:12852-12865` (`LmP0Text`/`c.LmP0Text`, `size_t`/`c.size_t`, `char`/`c.char`, `int`/`c.int`) — that table IS the `c.sizeof(T)` mapping, and it dissolves when `sizeof:` becomes the receiver-operator. **A THIRD AND LARGER ONE IS `l2_is_known` (`:8873`), which is itself a concrete C-name dictionary** — `malloc/calloc/realloc/free/getenv/system` → `l2_need_stdlib`, `strcmp/strlen/memcpy` → `l2_need_string`, `lm_p0_set_diagnostic` → `l2_need_p0` — with 18 call sites. It is the allowlist rule 3 names, and it is NOT the `:8921` list. Name-specific checking also survives at `l2_check_primary` `:11521`/`:11543` and `l2_prep` `:12962`, and frame tests at `:2323`/`:2405` (`c.puts`), `:4994` (`c.array`), `:6509` (`c.sizeof`). **WHAT STAYS IS THE PER-TOKEN PREFIX TEST** — `t\data[0] = 99 && t\data[1] = 46` at `l2_c_stmt_door` `:8919-8920` and inside `l2_is_known` `:8897` — because that is the ruling's own discriminator; only the name comparisons die. After both are gone, `c.sizeof(c.LmxArena)` and `c.sizeof((@: T))` pass as raw C through the general door (19 raw-C operands stay). `c.sizeof(buffer)` / designators become ordinary L2 expressions that the door **loads** — wrong size for an L2 cell — so those 22 uses migrate to [`sizeof-receiver`](#sizeof-receiver). Deleting `:8921`/`:12822` before `sizeof:` exists is an order-of-operations defect, not a HOLD, and not a reason to keep a name test. The same rule deletes the puts cluster ([`c-puts-passthrough`](#c-puts-passthrough)) and the `c.array` name tests ([`l2-c-array-removal`](#l2-c-array-removal)). The previous A/B alternatives (raw-text-everything vs evaluated-everything) are **withdrawn**: classification is the namespace rule above.
  **MECHANIC (emission, not semantics): the door's field-name codes.** The translator resolves a **C** field name appearing on a raw-C surface to an emission code `out_fld`: `data`→0, `length`→1, `columns`→2, `count`→3, `capacity`→4, and 5 = "spelled as written" for a runtime-struct/foreign-type field (`l2trans.lm1:6886-6928`, with the block's own comment "A runtime struct or foreign type field is spelled as written"). **These are C-side field names resolved to emit valid C** — they say nothing about L2 record fields, and no conclusion about any L2 type may be drawn from this table.
- **witnesses:** **all of the named ones are ungated.** `entry_puts_*`: 20 `*puts*.lm2` in `dev/l2src_sandbox/tests/`, **0 named in `tools/l2_harness.ps1`**; `unit_c_empty_call.lm2` — exists, **0 harness rows**. `c.array`: 4 fixtures (`entry_array`, `entry_array_leading_zero`, `entry_nul`, `unit_native_activation`), **all 0**. Nothing in `tools/` globs `*.lm2`, so **ungated means never run**: a behaviour change here is invisible to the fixture gate and needs its own witness.
- **open gap to next_core_tasks.md:** section 7a Raw-C door tasks + GATE zero stale scanners/dictionaries/whitelists
- **positive behavior:** `c.sizeof(T)` -> C `sizeof(T)`; `c.puts(s)` -> ordinary raw-C call emission; `c.rand()` via same door
- **forbidden / contrast:** FORBIDDEN: scanning *.h to populate a C-name dictionary; testing any concrete C name (printf, sizeof, LmxArena, puts, array, or other); resolving `c.*` tokens against L2 bindings as semantic entities; pre-evaluating a `c.*` token; inventing an entity-kind registry. Non-`c.*` arguments remain ordinary L2 expressions (they are resolved/loaded). Preserve only mapping rules required to emit valid C.
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
- **impl files/functions:** inventoried at `f559f9dd` (nothing here is a contract, only what the code does today). `l2_prep_sizeof_name` **exists**: `dev/l2src_sandbox/l2trans.lm1:12641`, with its operand-bytes region `:12572-12649`. The `c.sizeof`-specific sites are a small cluster: the door exclusion `:8921`; a head test at `:6509` (*"c.sizeof names a C type; nothing inside it is a lexical reference"*); `:11521`; and the emission block `:12815`, `:12822`, `:12832`, `:12842`, `:12849`, `:12853`, `:12858`, `:12862`, `:12866`, `:12876`. The region emits `c.sizeof(l2_p%d_%d)` `:12601` and `c.sizeof(l2_t%d)` `:12634`, and already has a refusal of its own — *"c.sizeof of this own field type not yet implemented"* `:12621`. **The total is not the surface:** `l2trans.lm1` contains **172** `c.sizeof` occurrences, and the great majority are the translator's own emitted C (`c.sizeof(c.int)`, `c.sizeof(l2_ptr_probe)`, `c.sizeof(c.LmP0Text)` in its own bookkeeping) — the same counting trap as `c.array` (see [`l2-c-array-removal`](#l2-c-array-removal)). **No conclusion about `length`, `capacity` or any other receiver name is drawn or implied here.**
  **WHY A RECEIVER-OPERATOR AND NOT A CALL — the measured property.** `sizeof` takes a TYPE or an UNEVALUATED object designator: the special branch exempts its operand from lexical resolution (`:6508-6509`, "names a C type; nothing inside it is a lexical reference"), accepts a type spelled as written, a struct-typed local (type code 22, `:11533-11538`), a `(@: T)` frame (`:11529-11530`) or an L2 designator (`:11527-11528`), and re-spells the operand textually without emitting a load (`:12831`, `:12840`, `:12847`). A call evaluates its arguments; `sizeof` must not — so the size operation is an OPERATOR in kind, which is exactly the receiver-operator class this article plans, and why the binding-KIND rule ([`binding-kind`](#binding-kind)) has nothing to say about it: `sizeof` resolves nothing. The same class already exists in the translator for `cast` (`(cast: (T) x)`: lexical scan `:6513`, checker `:11503`, emitter `:12778`; 20 fixtures, 5 ports, 9 harness rows) and `length` (`:11517-11520`, compile-time count of a known own array); `c.sizeof` is the only member that wears the `c.` prefix, which is what makes the `:8921` exclusion list look homogeneous when it is not.
  **Migration boundary once `sizeof:` exists** (from the corpus classes measured under [`c-raw-door`](#c-raw-door), now under the namespace decision): `c.sizeof(c.LmxArena)` / `c.sizeof((@: T))` — every `c.*` token is raw C and stays on the general door (16 + 3 = 19). `c.sizeof(buffer)` / designators — `buffer` is a non-`c.*` L2 expression, so the door loads it; those 22 L2 size asks move to `sizeof:`. Rule 3 also deletes the `:12822` name-specific branch (no concrete name may be tested). Deleting `:8921`/`:12822` BEFORE `sizeof:` exists sends those 22 through evaluate-and-load (wrong size, silently) — order of operations, not a HOLD, and not a reason to keep a name test.
- **witnesses:** none yet — add with implementation ticket. The first row to write is the negative that separates operator from call: `sizeof:` of an own field whose cell is a pointer must yield the cell's type size, not the pointee's and not the loaded temp's.
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
- **implementation (files/functions):** the flag reads the invariant forbids are **measured, 11 sites**: `dev/l2src_sandbox/l2trans.lm1` has **7** `LM_P0_FRAME_COMPACT` reads (`:4792`, `:7775`, `:11553`, `:11558`, `:11956`, `:12815`, `:14531`) and **0** `LM_P0_FRAME_COLON`; `l1src/l1trans.lm1` has **4** `LM_P0_FRAME_COLON` reads (`:3664`, `:3666`, `:4929`, `:5457`). **`l2_head_is_call` (`l2trans.lm1:10203`) is NOT among them** — it returns 1 as soon as `l2_find_method(t) >= 0` (`:10207-10208`), *before* the COMPACT/path-kind test at `:10213`, so the form-before-resolution defect is fixed and any citation of it is stale. Flag definitions: `l1src/p0.h.lm1:9` `LM_P0_FRAME_COLON 1U`, `:10` `LM_P0_FRAME_COMPACT 2U`, `:12` `LM_P0_FRAME_SEPARATOR_CLOSED 8U`.
  **MEASURED STATE, NOT NORM (superseded by author 2026-09-23).** In `tests/parser/current/expectations.json` case 0 (`empty_vertical_body.lmx`, `receiver:` + `---`) and case 1 (`empty_parenthesized_argument.lmx`, `receiver: ()`) produce **identical** `stdout_exact` (`body=structure fields=1` → `structure fields=0`), while case 11 (`compact_no_arguments.lmx`, `receiver()`) has `body=structure fields=0`. Required normal form: all three have the latter P0 body shape; the same sole-container rule applies when nonempty. See `next_parser_fix.md`.
- **witnesses:** **these goldens ARE gated** — `tools/run_parser.py --profile current` reads `tests/parser/current/expectations.json` and compares the child's **exit code AND `stdout_exact` byte-for-byte** (CRLF-normalised), plus optional `stdout_file`, `diagnostic` and `stdout_contains`. The current file has 20 cases; the closed-empty accept and dangling-colon reject cases are among them. A shape change here fails this gate until accepted goldens are updated. A `*.lm2` behavior change has a different harness route (see [`c-raw-door`](#c-raw-door)).
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
- **implementation (files/functions):** node kinds `l1src/p0.h.lm1:1-4` (`LM_P0_NODE_STRUCTURE 1`, `FRAME 2`, `ATOM 3`, `DISABLED 4`). **Four frame flags, all at `:9-12`** — `LM_P0_FRAME_COLON 1U`, `LM_P0_FRAME_COMPACT 2U`, `LM_P0_FRAME_INLINE_BODY 4U`, `LM_P0_FRAME_SEPARATOR_CLOSED 8U` — with measured readers:
  - `COMPACT`: **7 reads in `dev/l2src_sandbox/l2trans.lm1`** (`:4792`, `:7775`, `:11553`, `:11558`, `:11956`, `:12815`, `:14531`), 0 in `l1src/l1trans.lm1`;
  - `COLON`: **4 reads in `l1src/l1trans.lm1`** (`:3664`, `:3666`, `:4929`, `:5457`), 0 in `l2trans.lm1`;
  - `INLINE_BODY`: set at `l1src/parser.lm1:2704` and `:2840`, read at `:4428` — it marks a frame whose body was wrapped from the same line (`lm_p0_wrap_fields_from_line`);
  - `SEPARATOR_CLOSED`: set at `l1src/parser.lm1:2973-2974` when `lm_p0_is_short_form_separator` (`l1src/parser_text.lm1:44`) matches the preceding character, and read at `:2557`, `:2559`, `:3271`, `:3288`. **`:3271` is the discriminating predicate** — `(COLON != 0U) && (SEPARATOR_CLOSED = 0U)` — i.e. *a colon frame that is NOT separator-closed* is the closed empty form; a separator-closed one is the incomplete/dangling case P0 rejects.
  - **TRAP, measured:** `LM_P0_FRAME_SEPARATOR_CLOSED` **reads as "explicitly closed" and means closure by `;`/`)`** — the dangling family. A validator relaxed on that flag does not merely invert the rule in prose: the three reject goldens (`missing_colon_argument{,_semicolon,_bounded}`) are exactly that family, so it would turn three `exit 1` cases green.
  - **TRAP, tree:** three parser copies exist with **divergent line numbers** — `l1src/parser.lm1` (4950 lines, setter `:2974`), `dev/l1src_sandbox/parser.lm1` (4986, `:2974`), `dev/l2src_sandbox/l1src/parser.lm1` (4951, `:2975`). `dev/l2src_sandbox/l2trans.lm1:1` predefs `l1src/parser.lm1`, which resolves against the **working directory**, so which copy is live depends on where the build runs. Cite the copy, not the name.
- **witnesses:** parser goldens (`tests/parser/current/`), **gated** by `tools/run_parser.py --profile current` on exit code **and** byte-exact `stdout_exact` — accepts for the closed empty frame are cases 0 (`empty_vertical_body`), 1 (`empty_parenthesized_argument`), 2 (`empty_vertical_then_parenthesized`), 3 (`empty_vertical_comment`); the rejects for the dangling family are cases 8, 9, 10.
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `anonymous-container-transparency`

- **level:** P0/L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** P0 normalizes a sole anonymous Structure occupying the entire argument list into that list's fields exactly once, for any head and both empty/nonempty cases.
- **invariants:** Empty Structure remains a real value in a nontransparent position; incomplete `f:` remains invalid.
- **not-confused-with:** empty-argument-sequence; empty-structure-value; consumer-only unwrapping in current code
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
- **definition:** Resolve the actual receiving act. A callable Structure can be applied directly or through its held reference; explicit reference reassignment uses `@:`. A raw C function-pointer primitive is not automatically an LMX callable occurrence.
- **invariants:** KIND not COMPACT/COLON flags
  - **Current rule (2026-10-02):** a Structure and its reference have equal application behavior. `b: args` invokes the selected callable contract; `@: b B` selects reference reassignment. The receiver's contract, exact depth and source context determine the act, not COMPACT/COLON flags or a descriptor-specific pointer exemption.
  - **Value versus invocation** follows the resolved logical binding and receiving contract, never ATOM versus FRAME alone. An explicit pointer/reference remains a value binding in every equivalent surface form; invocation of its referent requires dereference. A bare callable atom invokes nullarily under the same callable-first rule. P0 normalizes equivalent Frame forms ([`surface-form-equivalence`](#surface-form-equivalence)); it does not decide the binding's role.
- **not-confused-with:** call-first; fnptr-value-discard
- **links:** requires=[head-resolution](#head-resolution); produces=the operation kind (`CALL` | value); consumes=resolved binding; selects=none. See also [`c-raw-door`](#c-raw-door) — a `c.` head is not a binding and is outside this rule.
- **authoritative sources:** next_core_tasks.md — `### Вызов` ("Голый callable в statement position — частный случай expression statement / discard"), `## 2` ("Голый `f` в исполняемой позиции — одноатомное выражение"), `### Expression statement и discard`; AUTHOR tickets 20260922.
- **historical inventory boundary:** The following `20911ad7`/`f559f9dd` measurements describe the then-existing method-only classification and fnptr routes. Their claim that only two binding kinds are callable is obsolete. Current acceptance must also cover actual named Structures and distinguish explicit reference bindings under closed Q56/Q57; the historical fnptr routes do not authorize calling an explicit Structure-reference binding without dereference.
- **implementation (files/functions):** measured at `20911ad7` (`dev/l2src_sandbox/l2trans.lm1` blob `32617491db5b`; unchanged at `f559f9dd`). **Callable-head test at the measured revision: `l2_head_is_call` `:10203-10217`** — TRUE for a unit method (`l2_find_method` `:10207-10208`), for a callable field reached by path (`l2_path_kind = 4`, `:10213-10214`), **and for any head whose Frame has NO BODY (`:10215-10216`, `body = 0 || count = 0 -> 1`)** — the third clause is form-derived (emptiness of the argument sequence), not kind-derived, and contradicts the invariant: a non-callable `x` with `x()` is classified "call" before `x` is resolved. **Function-pointer values at the measured revision:** a method-local of type code 40 (`l2_fnptr_local` `:4761-4777`, declared with a predef `fnptr:` type; `l2_ml_find` / `l2_ml_ty`); a call THROUGH it is recognised **only when the Frame is COMPACT** — checker `:11553` (`l2_ml_ty[...] = 40 && (call\flags & LM_P0_FRAME_COMPACT) != 0U`) and emitter `:14531` (same test → `l2_emit_fnptr_call`), comment `:14529-14530` "the head names what is CALLED, not what is assigned to". So `fp(a b)` calls through the pointer, `fp: a b` takes the ASSIGNMENT path, and a bare `fp` is refused as a statement (see [`fnptr-value-discard`](#fnptr-value-discard)). These two sites are two of the seven COMPACT reads listed under [`surface-form-equivalence`](#surface-form-equivalence). **Resolution tables a bare identifier can reach**, in the checker's order: unit methods (`l2_find_method`), method locals incl. fnptr (`l2_ml_find`), formals (`l2_param_find` / `l2_formal_find`), own fields (`l2_own_find`), dynamic inputs (`l2_dyn_find`), slots (`l2_slot_find`), unit-level entries/locals (`l2_entry_find` / `l2_loc_find`), named Structures / eternal branches / method results (`l2_ns_find` / `l2_ebr_find` / `l2_mres_find`), C names (`l2_is_known`, `l2_c_door`). Exactly two of these kinds are callable bindings (unit method; callable graph field); all others are value bindings.
- **witnesses:** current acceptance must distinguish a bare explicit pointer/reference value (counter stays 0), an actual callable (nullary invocation), and explicit invocation of the pointer's resolved referent. Exercise equivalent surface forms only after fixing the same binding role; old `fp(...)`-means-call rows are historical expectations, not the accepted rule.
- **open gap to next_core_tasks.md:** remove both COMPACT and ATOM/FRAME-only invocation gates from the historical sites `:11553` / `:14531`. Consume the common resolved binding/operation. Drop the empty-body-call shortcut at historical `l2_head_is_call :10215-10216`; an empty tail alone never establishes callability.
- **positive behavior:** an executable callable atom, including a bound Structure reference, follows ordinary nullary application. Primitive/data evaluation does not become a call. Value/argument positions retain their receiving contract; no indiscriminate invocation of every transported reference.
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries; classifying by TYPE (function-typed value ⇒ callable); classifying by form (empty body ⇒ call; COMPACT ⇒ pointer call).

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
- **implementation (files/functions):** measured in `dev/l2src_sandbox/l2trans.lm1`. **Where a receiverless statement goes today:** `l2_emit_body` (`:14928`–`~15820`) routes it into the **field-path assignment branch** (`:15320-15350`), which looks up a destination (`l2_loc_find` / `l2_own_find`, `:15331-15335`) and refuses without one — *"a field path value needs a declared destination"* (`:15336`). **A bare nullary callable hits exactly that refusal today.** **The allocator gap:** `l2_new_temp` (`:9038-9044`) emits `"%sint: l2_t%d\n"` unconditionally — **it has no type parameter**; its 6 callers are all int-context, none a discard path. **What already exists:** the typed emitter `l2_emit_cell_load(oty, …)` (`:12215-12234`; codes 0 int, 1 char, 2 size_t, 3 unsigned, 36 ulong, any pointer own-type; refuses with *"type has no value cell to load from"*), its coverage boundary `l2_own_store_helper` (`:13868-13880`), and **a typed temp for a call already exists in `l2_hidden_from`** (`:12236-12315`) — bump `l2_tn`, then `l2_emit_cell_load(l2_own_of_dt(ty), …)`, **gated on the callee's return type** (`l2_ret_uns` `:4947-4953`; `l2_m_ret[mi] != 8`). **Shape of the fix:** `l2_new_temp_ty(oty, …)` = bump + `l2_emit_cell_load` + `l2_tok_temp`, with `l2_new_temp` reduced to `l2_new_temp_ty(0, …)` and `l2_hidden_from` routed through the same core. **Counterexamples to an int-only shortcut:** a `sub`/void callee (`l2_m_ret[mi] = 8`) has **no value** and must allocate nothing; `size_t`/`ulong` returns **truncate silently** under `int:` (the flag set has no `-Wconversion`); pointers fail loudly (`-Werror=incompatible-pointer-types`); `char` widens silently. `2+2` is a **control**, not a test of the fix.
  **REFUSAL SITE OF A BARE ATOM — TWO CANDIDATES, UNWITNESSED WHICH FIRES.** Besides the emitter refusal `:15336` above, the CHECKER `l2_check_body` (`:11714-12058`) handles the keyword atoms `break` / `continue` / `return` (`:11749-11763`) and then, at `:12027-12030`, refuses a statement that is not `if` / char-decl / `return` and does not resolve as a head (`unsupported body`, or `unknown field path root` for a pathed head). Checking precedes emission, so a bare data atom or bare method name may never reach `:15336`; no fixture spells a lone identifier statement (scan of `tests/*.lm2`: 0), so which diagnostic a user sees today is **unmeasured** — one refused fixture settles it and must be the first row written.
  **NO ADMISSION ON THE DISCARD PATH — the trap is one line away.** The single-atom `return` at `:12049-12051` already calls `l2_admit_consumer_uses` (`:9757`; sibling `l2_admit_implements` `:9739`) for return-value admission. An expression statement that discards has no receiver, so if `l2_eval_discard` is built from the return evaluator, that call must be excluded explicitly; if built from the assignment-value evaluator, the destination lookup `:15331-15336` must be excluded. Either way the shared part is the EVALUATOR only.
  **The (c) discriminator in code terms:** the fnptr call gates `:11553` / `:14531` ([`binding-kind`](#binding-kind)) are the only thing standing between "bare `fp` is a value" and "bare `fp` is a call" once the bare atom becomes an expression statement — the discard path must classify by binding KIND before those sites are reached, or a fnptr local in statement position falls through to them by accident of form.
- **witnesses:** earlier measurements are history, not a current gate. Verify ordinary calls through held Structure references and explicit @: reassignment, across equivalent forms and both engines. Unary @ adds one level; an actual's address level cannot disappear to make admission succeed.
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `explicit-typed-declaration`

- **level:** L2
- **Norm:** accepted
- **Implementation:** divergent — historical implicit model construction must not remain a second declaration rule
- **Verification:** none for the complete current contract; old fixtures are historical evidence below
- **definition:** A reserved receiver supplies its declared contract, for example `int: i`. For explicit Structure-reference assignment use `@: b A`; the same unknown-b case can be written `b: A`. Ordinary application of an existing Structure is not an implicit model-cloning receiver.
- **invariants:** Classify the resolved head in context. Unknown ordinary head defines that head's Structure; unknown actual argument in an existing Structure call is an error.
- **not-confused-with:** structural-declaration
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** [Q56](LMX_blog/q/q56.md), [Q57](LMX_blog/q/q57.md); normative construction rules; `next_core_tasks.md`.
- **implementation (files/functions):** Historical inventory: `l2_colon_model` at old `l2trans.lm1:5468` and `l2_colon_rewrite_decl` at `:5718-5772` rewrote `Model: fresh` to `fresh: merge(Model)`. That rewrite is cleanup debt, not a route to preserve. Migrate its consumers to common resolved application/declaration metadata; preserve genuine reserved-receiver declarations and explicit merge separately.
- **witnesses:** historical fixtures are not authority. B and @B must have different reference depths; all actuals, formals and returns preserve it. No generated by-value C aggregate Model or silent removal of address levels.
- **open gap to next_core_tasks.md:** remove the implicit-clone rewrite and stale expectations while retaining equivalent parser forms and the explicit merge expression.
- **positive behavior:** `int: i` declares through the primitive receiver. With absent `b`, `b: A` and `@: b A` are equivalent under the common source-construction rule; `@: b B` later selects reference reassignment. An existing `Model: fresh` calls `Model` and must satisfy its actual contract.
- **forbidden / contrast:** FORBIDDEN: implicit clone, empty reference or by-value aggregate inferred from `Model: fresh`; deriving a primitive variable type from an unknown ordinary head's literal body.

## `structural-declaration`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** An unknown ordinary head defines a named Structure whose tail is its body. Defining that Structure does not execute its body or require all free body names to be resolved already.
- **invariants:** No implicit merge normalization. Existing Structure heads call; parentheses/colon/block form do not choose the semantic operation.
- **not-confused-with:** merge-construction
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** closed [Q56](LMX_blog/q/q56.md) and [Q57](LMX_blog/q/q57.md); normative construction rules; `next_core_tasks.md`.
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** Unknown `A: b` defines `A` with body `b`, not a reference named `b`. With both heads unknown, `C: makeA()` defines `C` with the empty named Structure `makeA`. With known callable `put`, `Batch: (put: 7)` instead retains the ordinary application in its body without executing it on definition (closed [Q58](LMX_blog/q/q58.md)). Empty `f()` and `f: ()` define an empty named Structure when `f` is unknown; an existing Structure `f` is called.
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `merge-construction`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Explicit merge builds/combines Structures. `b: merge A C` keeps `A` and `C` as merge operands and `b` as the external result recipient.
- **invariants:** No implicit `Model: fresh` clone and no invented result-name-first merge receiver. The established composition on returning a nested callable is a separate return contract and is not removed by this declaration correction.
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
- **Verification:** historical fixtures only; current reference-level matrix still requires a fresh gate
- **definition:** Structure values are references to their `Lmx` descriptors, not C by-value aggregates. Array values likewise retain their typed descriptor reference representation.
- **invariants:** B holds a Structure reference; @B addresses its real reference cell and adds one level, exactly as @ptr. Do not return the descriptor from the address operation.
- **not-confused-with:** l2-address-of
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** closed [Q56](LMX_blog/q/q56.md); CORE §3.1/§4; normative reference/construction rules; `next_core_tasks.md`.
- **implementation (files/functions):** Historical inventory: `l2_colon_graph_ty` (old `l2trans.lm1:5481`) and Structure formals/returns (`:13589`, `:16085`) already used `@: Lmx` / `Lmx *`. Old `Model: fresh` publication through `lmx_arena_ref_store` at `:15280-15281` belonged to the withdrawn implicit-clone route; it does not define address semantics. Audit current ordinary-value, address, explicit-reference and formal consumers against the same resolved type contract.
- **witnesses:** Historical `unit_colon_model_decl.lm2` and the old STRUCT-ADDR fixture proposals are not current acceptance. Required: passing actual `B` and `@B` preserves descriptor identity and reference level; passing `@ptr` adds a level and is not silently dereferenced; no generated C aggregate `Model`.
- **open gap to next_core_tasks.md:** shared resolved type/address representation and conversion-before-admission, across declaration, assignment, argument and return consumers.
- **positive behavior:** A compatible Structure `B` is transmitted by descriptor reference; `(A: b)` and `(@: A b)` describe the same nonprimitive formal only in a signature.
- **forbidden / contrast:** implicit aggregate copying, per-model conversion registries, descriptor exemptions from address-taking, and silent removal of explicitly requested pointer levels.

## `l2-address-of`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none for the complete current address/reference-level contract
- **definition:** Unary `@` addresses the resolved operand's real value storage. A Structure/Array already has a descriptor-reference value, so `@` addresses the cell holding that reference and adds one level. A primitive yields its primitive-cell address. Explicit reference variables obey the same storage rule.
- **invariants:** Do not substitute a descriptor, cache, ABI carrier or copied temporary for the actual value cell. A primitive's child-reference slot is not its primitive data cell; a reference-held value must expose its own reference cell. Preserve exact pointer depth and storage type. Graph declarations and activation-local inputs retain their respective lifetime rules.
- **not-confused-with:** l2-address-slot; dirty
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** [author's 2026-10-02 correction](LMX_blog/2026-10-02.md#structure-reference-address), normative [L2 §18](docs/L2_spec_en.md#lowlevel-address), and [critical_pointer_to_struct_bug](steps/tickets/critical_pointer_to_struct_bug.md). Q56 records the earlier discussion, not authority for a descriptor exemption.
- **implementation (historical audit):** earlier l2_check_addr/l2_prep_addr/l2_mres_find evidence treated the Structure-slot address proposal as withdrawn. That withdrawal is superseded by the author's 2026-10-02 correction: @Structure must address its real reference-holding cell. The live descriptor exemptions are critical_pointer_to_struct_bug; exact C99 storage types still require proof, not a void** cast.
- **witnesses:** Required fresh native/interpreter matrix: Structure and Array reference-cell identity and one extra level; explicit reference cells; declared primitive storage; activation-local formal storage/lifetime; no temporary referent. Old descriptor-return expectations must fail. Proving `Lmx **` text alone is insufficient: a store through the actual cell must update its reference, not mutate the descriptor.
- **open gap to next_core_tasks.md:** migrate address consumers to the common typed operand path; retain the L2/L3 profile distinction without syntax/name branches.
- **positive behavior:** ordinary B has descriptor-reference value, conceptually Lmx*; @B has reference-cell address, conceptually Lmx**. Repeating valid address-taking never collapses levels.
- **forbidden / contrast:** FORBIDDEN: exposing an unrelated service slot or primitive child-reference slot instead of the selected value's real cell; returning a descriptor from unary `@Structure`; addressing a copy; using sticky/cache policy to change the addressed place.

## `l2-address-slot`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** none
- **definition:** Explicit `@: b A` selects reference assignment; for absent `b`, `b: A` is its synonym. Subsequently `b: args` applies the selected Structure, while `@: b B` explicitly reassigns the reference. Repeated source declarations retain separate occurrences.
- **invariants:** Ordinary Structure transport is conceptually `Lmx *`; unary `@b` addresses its actual reference cell, conceptually `Lmx **`. Candidate conversion and Consumer-relative implements precede storage. A Structure reference has the same application behavior as the selected Structure; pointer depth is not silently adjusted.
- **not-confused-with:** l2-address-of
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** [author's 2026-10-02 application correction](LMX_blog/2026-10-02.md#structure-reference-application), normative [construction](docs/LMX_semantics.en.md#construction), and [reference-application refactoring](steps/tickets/structure_reference_application_refactor.md).
- **implementation (historical inventory):** `l2_ptr_local_ty` at `:4802-4878`, `l2_address_depth` at `:4556`, `l2_emit_foreign_named` at `:4660-4688`, and `l2_const_local_ty` at `:4939` describe the earlier receiver lowering. Inventory these consumers against the accepted destination/value forms; do not preserve an old operand-order ambiguity with a name heuristic. Unary address-taking and receiver binding are separate operations; no C aggregate Model or duplicate graph declaration is introduced.
- **witnesses:** absent-b synonymy; explicit @: reassignment after conversion/admission; ordinary invocation through the selected Structure reference; distinct repeated declarations; exact address depth in actuals/results; primitive value/reference differences.
- **open gap to next_core_tasks.md:** the v2 pointer-address repair precedes the explicit-reference/application refactor. Fresh behavior and graph-shape gates replace obsolete expectations; historical operand-role collisions must be reported, not guessed.
- **positive behavior:** `@: b B` stores an admitted reference; `b: args` invokes the selected callable under its actual signature. An ordinary named Structure is still nullary; explicit reference assignment does not execute the candidate.
- **forbidden / contrast:** FORBIDDEN: implicit model cloning, treating `b: args` as reference reassignment, inventing explicit arguments for an ordinary named Structure, model-pair conversion tables, or silently adding/removing pointer levels.

## `l3-reference-receiver`

- **level:** L3
- **Norm:** accepted
- **Implementation:** partial — exact coverage must be verified against the current reference contract
- **Verification:** none
- **definition:** L3 permits typed reference declaration, acquisition, assignment and dereference under the shared reference rules, without numeric address arithmetic, raw-memory/backing access or machine casts. It is not restricted to declaration-only `@:` syntax.
- **invariants:** preserve referent identity, real cell identity and reference depth separately. B reads the held reference; @B addresses its cell. Ordinary Structure-reference application calls; @: explicitly reassigns.
- **not-confused-with:** l2-address-of
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** closed [Q56](LMX_blog/q/q56.md); normative L3 reference rules; `next_core_tasks.md`.
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** Required native/interpreter parity for typed reference binding, rebinding, referent admission, explicit dereference and argument indirection; negative witnesses for L2-only numeric/raw-memory operations. No new runtime result is claimed by this documentation edit.
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
- **Verification:** fixture
- **definition:** One declaration-position instance of a field or callable. Repeated declarations with the same name are distinct occurrences.
- **invariants:** Declaration order is lexical. `[N]field` selects the Nth declaration; an unqualified repeated name selects the last declaration under the accepted rule. Source identity, the graph slot, and its stored value/address are distinct facts.
- **not-confused-with:** occurrence-selector; physical child slot; activation-local working value
- **links / sources:** [CORE](CORE.md); paired specifications; Q24/Q29 decisions; next_core_tasks.md §7b; [implementation log](steps/native-selfbuild-20260930.md).
- **implementation (historical measurement at `0c5dd61`):** `l2_own_find_decl` selects declaration-source identity; `l2_own_find_occ` selects a lexical same-name occurrence; `l2_own_find_last` performs unqualified lookup. Placement is separate own-row/slot metadata. The measured `l2_own_addr` descriptor-return path for Structure/Array is now a defect under critical_pointer_to_struct_bug, not current address semantics. `l2_occ_slot` / `l2_occ_expr` select callable occurrences as ordinary Lmx Structures. The symbol inventory alone proves neither the pointer repair nor graph completeness.
- **witnesses:** `unit_q24_repeated_decl` covers explicit occurrences, unqualified-last and preceding-environment initialization; `unit_occ_local_read` and `unit_occ_root_out_of_range_refused` cover one occurrence and a missing one.
- **open gap:** These fixtures cover their supported positions, not every pending nested/canonical-body position.
- **positive behavior:** Two same-name declarations retain two selectable occurrences and two physical storage identities.
- **forbidden:** Bare assignment creates no occurrence; do not restore the removed activation-plan/header model.

## `occurrence-selector`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** `[N]field` selects a declaration on a resolved Structure/path. Callable selection carries the actual `Lmx` occurrence into dispatch.
- **invariants:** Lexical resolution precedes physical slot/path resolution; no publication journal, stored plan index, or second name registry.
- **not-confused-with:** selector; occurrence; activation-local working value
- **links / sources:** [CORE](CORE.md); paired specifications; Q24/Q29; next_core_tasks.md §7b; [implementation log](steps/native-selfbuild-20260930.md).
- **implementation:** At stable `0c5dd61`, `l2_occ_head` / `l2_own_find_occ` handle explicit selection; `l2_rw_path_occ` handles retained graph paths. Native resolution carries the selected Structure in `l2_pst`. `l2_call_sel` is emission-time state for a unit occurrence, path-selected occurrence, or callable formal. `l2_emit_call` snapshots the selected occurrence before evaluating actuals. Runtime dispatch uses that occurrence's direct `native` word or retained body, not `lmx_plan_slot_known`.
- **witnesses:** `unit_q24_repeated_decl`, `unit_occ_local_read`, `unit_occ_root_out_of_range_refused`, `unit_occ_snapshot_selector`.
- **open gap:** Pending nested/canonical-body positions still require the common path resolver; these fixtures do not establish universal completion.
- **positive behavior:** Generated temporary names or a new activation cannot change which declaration `[N]field` denotes.
- **forbidden:** No occurrence identity inferred from a temporary name, first matching own row, or removed callable header.

## `canonical-local-cell`

- **level:** L2
- **Norm:** accepted
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Stable addressable storage for an activation-local primitive or pointer value whose address is obtained; not a requirement to materialize every local.
- **invariants:** The address lasts for that activation and does not create a graph field or publication destination. Declared graph values retain declaration storage; actual Structure/Array values, including reference-transmitted formals, yield descriptor references. An explicitly declared pointer/reference binding, or an input whose value is itself a primitive pointer, adds a level when its pointer-value cell is addressed. See `l2-address-of`.
- **not-confused-with:** declaration storage; a nonprimitive formal's hidden transport parameter; dirty
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** [L2 §18.2–18.3](docs/L2_spec_en.md#lowlevel-address); [L3 working values](docs/LMX_semantics.en.md#dynamic); next_core_tasks.md §5/§7b.
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `selector`

- **level:** L2
- **Norm:** superseded publication mechanism; historical term only
- **Implementation:** audit remaining uses against current declaration/argument rules
- **Verification:** none
- **definition:** Historical selector for publication from the old canonical-cell implementation. It is not the language's occurrence-selector and is not a current argument-publication rule.
- **invariants:** Current repeated declarations have distinct physical occurrences. Argument assignment creates none. A backend may reuse working storage only while preserving each declared destination and pending dirty value; it cannot infer publication from address-taking.
- **not-confused-with:** occurrence-selector; checkpoint
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** Historical audit -142/-146, retained in Git before 17d3837; superseding contract: [L2 §18](docs/L2_spec_en.md#lowlevel-address), next_core_tasks.md §5/§7b.
- **implementation (files/functions):** UNKNOWN exact symbol set unless noted in c-raw-door / nearby articles — label for audit
- **witnesses:** UNKNOWN or see next_core_tasks fixture lists
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `sticky`

- **level:** L2
- **Norm:** superseded; not a current language requirement
- **Implementation:** remove any surviving address-triggered publication of clean own caches
- **Verification:** old fixtures are historical evidence, not conformance proof
- **definition:** Historical policy that made taking a local address trigger conservative graph publication. The current address contract does not use this policy: declared addresses reach actual typed data, and activation-only arguments have no graph publication target.
- **invariants:** Taking an address alone is not a write, does not dirty a working value and must not cause a clean cache to overwrite an explicit graph write. Dirty values still follow the ordinary checkpoint contract.
- **not-confused-with:** dirty; canonical-local-cell
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** Historical author discussion 2026-09-22; superseding [L2 §18.2–18.3](docs/L2_spec_en.md#lowlevel-address) and [assignment correction](docs/new_parts/assignment_is_not_declaration.en.md); next_core_tasks.md §5/§7b.
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
- **definition:** An admitted assignment has changed an own-field working value that must be written back to its declared graph destination at the specified publication boundary.
- **invariants:** Loading, reading or taking an address does not dirty the working value. A clean cache is never published merely because it exists. Explicit/hidden input assignment remains activation-local and creates no own destination. Explicit graph writes do not dirty an unchanged working copy. Failed admission commits no attempted write and does not erase an earlier accepted pending change.
- **not-confused-with:** checkpoint
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** [L3 working values](docs/LMX_semantics.en.md#dynamic), [L2 §18](docs/L2_spec_en.md#lowlevel-address); next_core_tasks.md §7b.
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
- **definition:** A specified control-transfer/publication boundary at which required dirty own-field working values are written to their declaration storage.
- **invariants:** Native and interpreter preserve the same boundaries and observations. No argument publication, clean-cache write-back, automatic reload or new checkpoint is inferred from an address operation. Backend helpers and physical dirty bits are implementation choices, not language operators.
- **not-confused-with:** dirty; Message publication; construction publication
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** [L3 working values](docs/LMX_semantics.en.md#dynamic), [exits](docs/LMX_semantics.en.md#exits), [suspension](docs/LMX_semantics.en.md#suspension); next_core_tasks.md §7b.
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
- **definition:** Structural admission relation between an available value, a required descriptor, and the paths used by the consumer.
- **invariants:** Every required used path has an admissible leaf kind/type or registered correspondence. Cycles use operation-local pending/visited triples, not a language depth cap. Callable arguments/result are ordinary lexical fields, not a `sig` number.
- **not-confused-with:** admission site; uses; conversion execution
- **links / sources:** paired specifications; D-105/Q39; next_core_tasks.md §7; [port route](steps/implements-port-plan.md); [mapping](steps/d105-index-table.md); [native admission](steps/d105-native.md).
- **implementation:** Stable `0c5dd61`, `lmx_implements.h.lm1` / `lmx_implements.lm1`: `lmx_implements`, `lmx_runtime_implements`, `lmx_implements_walk`, `lmx_implements_walk_view`, and `lmx_implements_view` traverse actual range kinds/types and Structure fields. `lmx_implements_register`, `lmx_implements_register_map`, `lmx_implements_find`, and `lmx_implements_slot` retain admitted identity/by-name correspondence in the arena. The old `lmx_implements_signature`, `LmxMethod`, fixed `DEPTH 32` and `sig` comparison are absent.
- **witnesses:** `unit_implements_{methods,primitives,namespace,argument,assignment,return,admission}`; `unit_s7_identity`, `unit_s7_used`, `unit_s7_nested_shape`, and corresponding missing-path/leaf-kind refusals.
- **open gap:** Consumer/call-site, Array-formal, canonical-body/copy and conversion coverage remains in its existing §7 tickets.
- **positive behavior:** A non-identical Structure supporting the consumer-used paths can be admitted with the required slot correspondence.
- **forbidden:** No numeric callable signature, fixed-depth refusal, kernel name registry, or hidden converter execution inside `implements`.

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
- **Implementation:** partial
- **Verification:** fixture
- **definition:** Physical/descriptor identity may make admission succeed, but does not remove the obligation at a non-null receiving site.
- **invariants:** No non-null identity fast path skips the ordinary analytic/runtime `implements` point. A null reference candidate follows the separate null admission route; a supplied null remains a present reference value, not an absent argument.
- **not-confused-with:** empty-uses-admission; null admission; correspondence-map lookup
- **links / sources:** accepted §7 admission rules; [port route](steps/implements-port-plan.md); [native admission](steps/d105-native.md).
- **implementation:** Stable `0c5dd61`: `l2_admit_implements` / `l2_descriptor_implements` are analytic sites; `l2_emit_admit` / `l2_emit_admit_own` emit receiving admission. The non-null path calls `lmx_runtime_implements`; successful identity/by-name admission uses `lmx_implements_register` / `lmx_implements_register_map`. Identity participates in the structural route, not equality of removed `sig` fields.
- **witnesses:** `unit_s7_identity` requires equal descriptors to succeed while admission still runs; its mutation makes the row refuse. `unit_implements_admission` is the adjacent general witness.
- **open gap:** Remaining receiving/call/result/copy sites under §7 prevent a universal-completion claim.
- **positive behavior:** An identical non-null candidate passes through ordinary admission and succeeds.
- **forbidden:** No early `candidate == required` bypass or `sig == sig` substitute.

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
- **implementation (files/functions):** the empty case **is answered by the walk, not shortcut around it**: `dev/l2src_sandbox/lmx_implements.lm1:114-117` — `if: depth > c.LMX_IMPLEMENTS_DEPTH → UNKNOWN` (`DEPTH 32`, `lmx_implements.h.lm1:42`), then **`if: consumer = 0 → YES`**. So an empty/absent consumer passes *at the implements point*; the invariant's obligation is that the call is made, not that it returns NO. The walk's contract comment states the discipline in full: an unset child of the Consumer is not a used path ("An empty `uses` is true: there is nothing to use"), a missing path or a known mismatch is NO, and anything it cannot inspect is **UNKNOWN — never YES**.
- **witnesses:** none — `Verification: none` in this article.
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md
- **positive behavior:** per definition
- **forbidden / contrast:** FORBIDDEN: silent specials contradicting universal rules; inventing registries

## `array`

**General receiving expressions, not an Array-specific recursion:** `a: b: c: ...` is ordinary nested application. `[]: []:` has no separate grammar, Array kind or lowering route. Resolve the existing P0 nodes and their explicit type/binding information once for all consumers; remove `l2_ns_arrarr_field` and duplicated declaration recognizers rather than adding a generic-looking Array scanner beside them. `length` receives the evaluated descriptor. The author's direct syntax uses the existing path separator: `a[i]\[j]\[k]` follows selected Array values, while adjacent indices address the original flat rectangular Array. A nameless `[i]` path step selects an Array element; `[i]name` selects a Structure field occurrence. Ordinary intermediate bindings `[]: []: b a[i]`, then `[]: c: b[j]`, remain valid witnesses. One typed path resolver serves all steps; do not infer rectangularity or introduce shape storage. See [replacement plan](steps/receiver-resolution-20260930.md).

**Author clarification 2026-09-30 (Q56):** no `shape`/`rank` contract or promised future dimension-aware numeric profile. Remove the stale promise instead of deferring it to a library. `T: []: []: x` is ordinary composition: an outer one-dimensional Array holds references to independently sized inner Arrays. It differs from the single rectangular `T: [][]: x`. Norm: [values](docs/LMX_semantics.en.md#values), [L2 Array](docs/L2_spec_en.md#method-array). Implementation evidence: `l2_ns_arrarr_field` recognizes the declaration; field kind 6 constructs an outer `LMX_TYPE_ARRAY_OF_DESC`; `unit_arrarr_field` covers int and char declarations. This is not full conformance: the §7 admission gap for the inner element type remains open (`unit_admit_letter_coarse`). [Author's answer](LMX_blog/q/q56.md).

- **level:** L2/kernel
- **Norm:** accepted
- **Implementation:** pending ABI migration; current base descriptor exists with old member names
- **Verification:** runtime
- **definition:** Accepted target: `VoidArray {size_t size, void *data}` is the standalone base Array descriptor and the first by-value member of `Lmx {array, parent}`. No separate `LmxArrayDesc` alias is needed. `Lmx.array` is the actual array of physical child references. Its backing, not the `VoidArray` record itself, is registered in the arena as `LMX_KIND_CHILDREN`/`LMX_TYPE_REFS`. The external `LmxRange` entry remains distinct; `&node->array` shares the node address but the arena still classifies the whole node as `LMX_KIND_STRUCT`, while a separately allocated `VoidArray` descriptor is `LMX_KIND_ARRAY`.
- **invariants:** Growth/capacity on List not Array
- **not-confused-with:** list; l2-c-array-removal
- **links:** requires=see related articles; produces=see definition; consumes=see definition; selects=see definition
- **authoritative sources:** next_core_tasks.md; AUTHOR tickets 20260922; LMX_blog 2026-09-22 where applicable
- **implementation (files/functions):** Current code has **not** adopted the target. `dev/l2src_sandbox/lmx.h.lm1` still defines `Lmx` as `{parent, int len, void *data}` and `LmxArrayDesc` as `{size_t len, void *data}`; child backing is allocated/registered by `lmx_arena_refs.lm1`. Migrating to first-member `VoidArray` requires every `Lmx.len`/`Lmx.data` and descriptor `len` access, replacement of `LmxArrayDesc` type uses, range/refs code, graph copy/merge, bounds and `INT_MAX`/negative-sentinel assumptions, stable/dev copies, generated seeds, and gates to move together. **`LmxListDesc` no longer exists as a header type**; dynamic membership remains separate `KIND_LIST` with capacity in private backing. Historical landing commits for the old base are `dc57747`, `7419470`, `f0afb6a`.
- **witnesses:** UNKNOWN as a runtime fixture. Nearest measured facts: the four `*.lm2` fixtures that mention `c.array` (`entry_array`, `entry_array_leading_zero`, `entry_nul`, `unit_native_activation`) are **all ungated** — see [`c-raw-door`](#c-raw-door); and the L2 gate compiles the kernel, which is a link/compile statement and **not** readiness.
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
- **implementation (files/functions):** the implementation units are **`dev/l2src_sandbox/lmx_list_owned.lm1`** and **`lmx_list_owned.h.lm1`**, and they are **dev-only** — absent from the stable `l2src/` tree. `KIND_LIST` appears in `lmx.h.lm1`, `lmx_array_owned.h.lm1`, `lmx_array_ref_owned.h.lm1`, `lmx_graph_copy_owned.lm1` and `lmx_list_owned.lm1`. **Both list units are `.lm1` — L1 sources**: the dynamic container exists, but on the L1 side, which is exactly the open item "port the dynamic container from L1 to L2 as a separate implementation without changing the base Array" (`next_core_tasks.md` §8). So `Implementation: present` is true of an **L1** List, not of an L2 one.
- **witnesses:** UNKNOWN as a runtime fixture; no harness row names a list fixture. The tree-level check that this article's claim can be verified with today: `ls dev/l2src_sandbox/lmx_list_owned.*` and `grep -rl KIND_LIST dev/l2src_sandbox/*.lm1`.
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
- **implementation (files/functions):** the name-specific path is a **closed cluster** in `dev/l2src_sandbox/l2trans.lm1` — every symbol has 1–2 callers, all inside it: `l2_check_puts` `:2319` (the checker the ruling forbids; callers `:2420`, `:2444`), `l2_take_puts_body` `:2410` (caller `:2488`), `l2_emit_puts_line` `:2718` (the emitter the ruling forbids; caller `:2792`), `l2_simple_puts_main` `:2388`, and `l2_write_triple_as_l1` `:2298` whose **sole caller is `:2725`, inside the puts emitter**. Plus head tests at `:2323` and `:2405`, an emitted literal at `:2722`, and the two door exclusions (`:8891`, `:8921`).
  **THE GENERAL MECHANISM ALREADY EXISTS — no new mechanism is needed.** `l2_tok_text` `:12174` is the standard text tokeniser — **15 callers**, including the generic C-call argument builders at `:13394`, `:13400`, `:13407`, `:14288` — and for a triple-quoted input it decodes and formats through **`l2_fmt_l1_string` `:2228`** (whose only callers are inside `l2_tok_text`). So the ordinary door already turns a triple-quoted L2 string into an L1 string literal; `l2_write_triple_as_l1` is a second, puts-only implementation of the same idea. The single thing to verify at implementation rather than assume: that the `c.<name>` **statement** lowering routes its arguments through `l2_tok_text`.
- **witnesses:** the behaviour change is **invisible to the gate**: 20 `*puts*.lm2` fixtures exist in `dev/l2src_sandbox/tests/` and **0 are named in `tools/l2_harness.ps1`**. Nothing in `tools/` globs `*.lm2`, so these are never run by the fixture gate — de-special-casing needs a newly added harness row to be witnessed at all.
- **open gap to next_core_tasks.md:** see open checklist in next_core_tasks.md — plus, specifically: **no harness row exists for any `*puts*.lm2` fixture**, so a de-special-casing witness must be ADDED, not merely found, or the removal lands unwitnessed.
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
- **implementation (files/functions):** in `dev/l2src_sandbox/l2trans.lm1` the L2 surface is **3 name tests + 1 user-facing lowering emitter** — `:4994` (`l2_frame_head(stmt, "c.array")`), `:8891`, `:8921` (the two door exclusions), and `:14444`, which emits `c.array: []: char <name>` for a user's L2 char-array local (reached when `l2_array_local` is 0 and the local's method type code is 22). **The article's own count is not the surface: of the 49 `c.array` lines in that file, 39 are the translator's OWN L1 declarations** (`l2trans.lm1` is an L1 source and L1 keeps `c.array`: `l2_ctr_buf` `:139`, `l2_tok` `:265`, `l2_addr_path` `:266`, …), 2 are comments, and **4 of the 5 emission sites are the translator writing L1 for its own machinery** — `:15953` (qualified roots), `:16085` (`l2_mops`/`l2_mprofiles`), `:16305` (`l2_nsp`), `:16308` — triggered by eternal branches/merges/throws, so they stay.
  **Migration cost, measured:** the raw door cannot declare storage (see [`c-raw-door`](#c-raw-door)), so a local raw buffer has no general replacement **syntax** — the ordinary L2 mechanism is owned allocation (`lm_own_new_zero` / `lm_own_delete`, already used in `dev/l2src_sandbox/parser_dump_port.lm2` at `:92`, `:142`, `:279`). That converts a stack buffer into a heap allocation **with a failure path** where the body may currently have none, and changes `c.sizeof(buffer)` from the array's size to the pointer's size (32 → 8), so the length must be carried explicitly. `dev/l2src_sandbox/parser_dump_port.lm2:51` is the ONE `c.array` use in that file (and it has **zero** `c.puts`).
- **witnesses:** 4 `.lm2` fixtures use `c.array` — `entry_array`, `entry_array_leading_zero`, `entry_nul`, `unit_native_activation` — and **all 4 have 0 rows in `tools/l2_harness.ps1`**. Nothing in `tools/` globs `*.lm2`, so **none of them is ever run**: the removal has no witness today and must add one.
- **open gap to next_core_tasks.md:** **the documentation half is already done at HEAD** — quoted from committed HEAD with `git show HEAD:<path>` (`f559f9dd`), not from the worktree: `docs/L2_spec_en.md` `:204` `## 19. Raw C storage`, `:206` "The `c.*` prefix is the raw door into C. **L2 does not define a separate language entity `c.array`**…", and its counterpart `docs/L2_spec_ru.md` `:204` `## 19. Сырое C-хранилище`, `:206`. One occurrence each, **0 `c.puts`** in either, symmetric RU/EN. So the remaining gap is code (3 tests + 1 emitter) and a witness, not spec text.
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
- **implementation (files/functions):** measured split of the 47 `c.array` lines in `l1src/l1trans.lm1`: **28 are the translator's own L1 declarations** (`c.array: []: char l1_th_names 2048` `:44`, `c.array: []: int l1_th_ar 32` `:45`, `l1_ca_names` `:54`, `l1_ca_ids` `:55`, …), **4 are name classification** (`l1_text_eq` at `:3664`, `:3666`, `:4929`, `:5457`), and 16 sit inside quoted/emitted text (the classification lines are a subset of those — a `l1_text_eq(t,"c.array")` call contains the quoted form, so those buckets overlap). The boundary this article names is therefore **not** "L1 has more of it" but: **the L2 translator `dev/l2src_sandbox/l2trans.lm1` is itself an L1 source whose own working buffers are declared with `c.array:`** (`:139` `c.array: [160]: char l2_ctr_buf`, `:265`, `:266`, `:2130`, `:5908`, `:6027`, … — 39 such lines). Removing `c.array` from L2 does not touch them; removing it from L1 would have to re-home those buffers first.
- **witnesses:** none — a measurement-boundary article, not a mechanism with fixtures. Its evidence is the census above, reproducible with `grep -cE '^[[:space:]]*c\.array:' <file>`.
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

## `discard-expression-statement`

- **level:** L2
- **Norm:** accepted (design fixed at f559f9dd; implementation open — see next_core_tasks.md, subsection `### Expression statement и discard`)
- **Implementation:** partial
- **Verification:** none — the six-case probe set from the `### Expression statement и discard` subsection is not gated yet
- **definition:** A receiverless body statement evaluates its span and discards the result to the already existing typed generated `l2_tN` destination, dead after the complete expression. The same body consumer covers lone `2`, bare `f`, `2 + 2`, bounded `(f)` and `(2 + 2)`, empty `()`, and the corresponding vertical anonymous Structure. Mixed Frame and headless fields execute in lexical order. Bare callable invocation is resolved by KIND, while bare data are evaluated without invocation; neither parentheses nor an empty Structure constitute an error or a separate semantic route. These are accepted rules, not claims that the current translator passes the full matrix. Bare-atom execution remains separate from the P0 Frame tree-shape invariant in `next_parser_fix.md`.
- **invariants:**
  - Single shared `l2_eval_discard` / body-dispatch, not per-form branches
  - `l2_new_temp` (:9038–:9044) must become `l2_new_temp_ty(oty)` — today it emits `"%sint: l2_t%d\n"` unconditionally (no type parameter)
  - `l2_emit_cell_load` (:12215–:12234) provides the typed emission model
  - A typed temp for call returns already exists in `l2_hidden_from` (:12236–:12315); route discard through the same core
- **not-confused-with:** anonymous-container-transparency; empty-argument-sequence; fnptr-value-discard
- **links:** requires=[fnptr-value-discard](#fnptr-value-discard); [surface-form-equivalence](#surface-form-equivalence); produces=discard-result-slot; consumes=body-dispatch in `l2_emit_body` (:14928–~15820); selects=none
- **authoritative sources:** next_core_tasks.md, subsection `### Expression statement и discard`; AUTHOR-DISCARD-PLAN-20260922-01
- **implementation (files/functions):**
  - Receiverless statement entry: `l2_emit_body` (:14928–~15820) at `dev/l2src_sandbox/l2trans.lm1` (f559f9dd)
  - Field-path assignment branch: :15320–:15350; destination lookup `l2_loc_find` / `l2_own_find` :15331–:15335
  - Refusal for bare callable today: :15336 "a field path value needs a declared destination"
  - Int-only allocator: `l2_new_temp` :9038–:9044; 6 callers all int-context, none a discard path
  - Typed emitter: `l2_emit_cell_load` :12215–:12234 (codes 0 int, 1 char, 2 size_t, 3 unsigned, 36 ulong, pointer own-types; refusal at :12230)
  - Typed temp for call: `l2_hidden_from` :12236–:12315 (bump `l2_tn`, then `l2_emit_cell_load(l2_own_of_dt(ty))`; gated on caller return type via `l2_ret_uns` :4947–:4953 and `l2_m_ret[mi] != 8`)
  - Token emitter for new temp: `l2_tok_temp` — referenced by `l2_new_temp` at :9039, full range TBD
  - Call return type lookup: `l2_ret_uns` :4947–:4953, `l2_m_ret` array (base TBD in article)
- **witnesses:** none — implementation is `absent`; the `### Expression statement и discard` subsection six-case probe set has no harness rows
- **open gap to next_core_tasks.md:** the `### Expression statement и discard` subsection requires `l2_eval_discard` / shared body dispatch plus both the initial six cases and the expanded anonymous-Structure matrix
- **positive behavior:** `2`, `2 + 2`, `(2 + 2)`, `f`, `(f)`, `()`, anonymous vertical body, mixed four-field Structure, bare callable side effect, nested call, unknown-name error and no access violation — gate each with parser tree and/or observable runtime result as appropriate
- **forbidden / contrast:** FORBIDDEN: per-form name-specific branches; inventing a global `sizeof:`-style HOLD; `l2_new_temp` staying int-only; treating the accepted P0 normalization as optional or CALL-only

## `discard-test-matrix`

- **level:** L2 / `tools/l2_harness.ps1`
- **Norm:** accepted — defines the six-case probe set from next_core_tasks.md, subsection `### Expression statement и discard`
- **Implementation:** absent — dedicated `tb_discard_*` fixtures and harness rows still need to be created and verified on the current tree
- **Verification:** fixture (must add harness rows)
- **definition:** Initial six cases plus the author's expanded P0/native/interpreter matrix exercise one `l2_eval_discard` body-dispatch path. Cover lone `2`, bare `f`, `2 + 2`, `(f)`, `(2 + 2)`, `()`, the corresponding anonymous vertical form and the mixed form below; fixtures alone do not count until gated. With an explicitly typed `f` already in scope, the mixed source witness is `( f: 1 / . f: 2 / . 2 * 2 / . f )` (slashes denote line breaks): P0 must preserve four ordered fields, and runtime must execute both writes, evaluate/discard the multiplication, then consume bare `f` through the same resolver. The literal `1` does not infer `f`'s type.

| Fixture file | Expect class | Needle / Says / Exit | Absent | Debt |
|---|---|---|---|---|
| `tb_discard_2plus2.lm2` | `runs` | Exit 0; Needle: `; (void)0;` or equivalent discard marker | `l2_new_temp` | (empty: control case proves dispatch exists) |
| `tb_discard_bare_data.lm2` | `runs` | Exit 0; Says: @() (no output) | `l2_new_temp` | (no result used) |
| `tb_discard_bare_callable.lm2` | `runs` | Exit 0; **Says must pin the side effect as evidence of invocation** | `l2_new_temp` | (no form-specific marker — invoke and observe) |
| `tb_discard_nested_call.lm2` | `runs` | Exit 0; Says must pin inner + outer side effects | `l2_new_param` / name-special | (same dispatch path) |
| `tb_discard_unknown_name.lm2` | `l2trans-refuses` | **Needle: error text** — must NOT route through `runs`/`eternal-runs` (that class is green-on-refusal) | (empty — the refusal IS the assertion) | (none) |
| `tb_discard_no_av.lm2` | `runs` | Exit 0; no crash, no segfault | `SIGSEGV` / `access violation` | (clean run proves no dangling deref) |

Additional required witnesses, each with a current P0 dump and a real native/interpreter runtime assertion: lone `2`; `(2 + 2)` versus `2 + 2`; `(f)` versus bare `f` for both callable and non-callable bindings; empty `()`; and bounded versus vertical anonymous Structure. The mixed `( f: 1 / . f: 2 / . 2 * 2 / . f )` witness must additionally pin four P0 fields and observable sequencing. Use a declared `f` in the runtime context; do not treat `f: 1` as type inference. These cases may share a fixture only when its assertions still distinguish each operation and a failing gate localizes the fault.

- **rows required by [`binding-kind`](#binding-kind) beyond the six** (same columns; counters are unit-level `int:` cells printed once at the end, so `Says` pins a number and no row asserts a P0 field count):

| Fixture file | Expect class | Needle / Says / Exit | Purpose |
|---|---|---|---|
| `tb_discard_fnptr_value.lm2` | `runs` | Exit 0; Says: counter 0 | bare `fp` (fnptr-typed local bound to `tick`) is a VALUE — evaluated, not called; today this file would be `l2trans-refuses`, so the class flip is the acceptance |
| Explicitly dereferenced callable-reference witnesses, using the common resolved call path | `runs` | Nonzero success result; invocation counter 1 in every equivalent form | Replaces the historical `tb_call_fnptr_*` expectation: a Frame headed by an explicit reference does not become a call just because it is a Frame |
| `tb_call_nonpath_empty_body.lm2` | `l2trans-refuses` | Needle: the call/assignment-role diagnostic | `x()` with `int: x` must NOT be classified a call by the empty-body clause of `l2_head_is_call` `:10215-10216` |

- **harness rows:** Add the initial six `[pscustomobject]` rows and the expanded witnesses above to `tools/l2_harness.ps1` `$fixtures` array with the appropriate `Expect` / `Needle` / `Says` / `Absent` / `Exit` assertions. **A new .lm2 file is NOT coverage until its row exists.** `l2trans-refuses` MUST use Needle+refusal, not `runs` exit-code. Recount current harness classes from HEAD before claiming coverage.

- **invariants**
  - `tb_discard_bare_callable`: side effect is the evidence of invocation, not any form-specific marker — bare callable resolves by the ordinary callable-first rule, invocation is proven by its observable effect, not by a form marker
  - `tb_discard_unknown_name`: l2trans-refuses with Needle, NOT runs — a refused fixture must not be gated as `runs`/`eternal-runs`, which are green on an exit code and would invert the refusal
  - `tb_discard_no_av`: must run under the eternal driver OR as a plain `runs` with Args @() — the point is no memory fault; `library-links` row's Exit=0 is NOT a model (cannot distinguish "ran clean" from "could not open library")
  - P0 transparency of the sole whole-sequence container **is** a required tree-shape invariant; current CALL-only unwrapping is an implementation gap (see `next_parser_fix.md`).

- **not-confused-with:** fnptr-value-discard (mechanism); anonymous-container-transparency (P0 form); c-puts-passthrough (foreign door)
- **links:** requires=[fnptr-value-discard](#fnptr-value-discard); [head-resolution](#head-resolution); [call-first](#call-first); [surface-form-equivalence](#surface-form-equivalence); produces=harness rows; consumes=body dispatch
- **authoritative sources:** next_core_tasks.md, subsection `### Expression statement и discard`; AUTHOR-DISCARD-PLAN-20260922-01
- **implementation (files/functions):** NEW FIXTURES only — no code change yet; harness rows go in tools/l2_harness.ps1 `$fixtures` array alongside lines :471–:473 (existing runs + l2trans-refuses rows)
- **witnesses:** none for this expanded matrix — current harness must receive explicit rows; nothing globs `*.lm2`
- **open gap to next_core_tasks.md:** the `### Expression statement и discard` subsection (shared `l2_eval_discard`); the six fixture rows must be ADDED to `$fixtures`, not found
- **positive behavior:** each case asserts exactly one observable (exit, printed line, or Needle); no cross-case bundling
- **forbidden / contrast:** FORBIDDEN: a combined row whose assertions cannot localize a failing operation; `runs` class for a refused test; CALL-only P0 tree shape; quoting ticket/provenance text verbatim into a harness row

## `harness-coverage-census`

- **level:** process / tooling
- **Norm:** accepted — distinguishes "not in l2_harness" from "ungated"
- **Implementation:** present (census is stable across instruments)
- **Verification:** measured
- **definition:** Of 331 `.lm2` files in `dev/l2src_sandbox/tests/`, exactly **64** are referenced by `tools/l2_harness.ps1` — 63 as `Name = '<file>.lm2'` rows and 1 (`unit_lib_pair_b.lm2`) only as a `With = @(...)` input at :752. **267 are not referenced** by the fixture gate. Nothing in `tools/` globs `*.lm2`.
- **invariants:**
  - "not in l2_harness" does NOT mean ungated — kernel `.lm1` selftests are gated by `tools/build_l2src.ps1`'s `tests/` glob, a separate gate
  - `l2trans-refuses` (21 rows) is green ON AN EXPECTED REFUSAL — it is the right class for unknown-name; `runs`/`eternal-runs` would invert that
  - `library-links` (1 row: `unit_lib_pair_a.lm2` at :751) runs NOTHING; Exit 0 is indistinguishable from a wrapper that could not open the library
- **not-confused-with:** build_l2src gate; l3_type_budget gate
- **links:** [c-raw-door](#c-raw-door); [c-puts-passthrough](#c-puts-passthrough); [l2-c-array-removal](#l2-c-array-removal); [discard-test-matrix](#discard-test-matrix)
- **authoritative sources:** measured independently by three instruments
- **implementation (files/functions):** `tools/l2_harness.ps1` `$fixtures` array :471–:473 onward (row classes, confirmed at :438–:453 comment block)
- **witnesses:** `tools/l2_harness.ps1` — `Get-ChildItem $sandbox -Filter 'tests/*.lm2'` has been confirmed to NOT exist; only explicit `$fixtures` rows gate
- **open gap:** no `c.puts` or `c.array` fixture has a row — de-special-casing needs ADD, not find
- **positive behavior:** precise row-counting (`Name =` rows = 63, +1 `With`-only = 64, +267 unreferenced)
- **forbidden / contrast:** FORBIDDEN: treating 267 unreferenced as "ungated"; treating `library-links` Exit=0 as a passing run; matching basenames without `.lm2` (caused my 69→64 correction)

Do **not** define L2 semantic articles as declared `foreign-namespace`, `foreign-callable`, `foreign-type`, or `foreign-operator` registries. Those framings are superseded by `c-raw-door`. Mapping rules required to emit valid C are audited as mechanics under `c-raw-door` without becoming an entity dictionary.

<a id="counting-traps"></a>
## `counting-traps`

- **level:** Measurement discipline for every article in this file.
- **Norm:** `accepted` — a count is evidence only when the instrument is stated.
- **Implementation:** N/A
- **Verification:** each trap below was measured, then re-measured by a second instrument that disagreed.
- **the traps, with the measurement that exposed each:**
  - **A construct's occurrence count in a translator is mostly the translator's own use of its source
    language.** `c.array` has 49 lines / 51 occurrences in `dev/l2src_sandbox/l2trans.lm1`, but **39 are the
    translator's own L1 declarations**; the L2-removal surface is 3 name tests plus 1 user-facing emitter.
    The same trap holds for `c.sizeof` (172 occurrences, overwhelmingly its own L1 uses).
  - **`l2_own_count` is an array length, not an occurrence counter.**
  - **A `*.lm2` fixture is ungated unless a harness row names it.** 331 fixtures exist in
    `dev/l2src_sandbox/tests/`; **64** are referenced by `tools/l2_harness.ps1` (63 `Name =` rows plus
    `unit_lib_pair_b.lm2` as a `With` input); **267 are referenced by nothing**, and nothing globs `*.lm2`.
    "No fixture covers X" and "no GATED fixture covers X" differ by 267 files.
  - **Gates are not interchangeable.** "Not in `l2_harness`" is true of every kernel `.lm1` selftest and
    does not mean ungated — those are gated by `tools/build_l2src.ps1`'s `tests/` glob. Name the gate per
    artifact.
  - **A substring match over-counts and a character class under-counts.** Matching a fixture basename
    without its `.lm2` scored 69 where the answer is 64 (`unit_own_eq` matching a row for
    `unit_own_eq_extra`); a class of `[a-z-]` silently dropped 21 `l2trans-refuses` rows because `l2trans`
    contains a digit. Print the matches, not the count.
  - **A row's green can be structurally incapable of failing.** The single `library-links` row runs nothing
    — `tools/l2_harness.ps1:450-453` says so in its own words, "LINK AND SYMBOLS ONLY: nothing is run" — so
    its `Exit = 0` is indistinguishable from a wrapper that could not open the library. The 21
    `l2trans-refuses` rows are green on an expected refusal and are honest about it; only `library-links`
    is green in a way that looks like execution.
- **positive/forbidden:** a number quoted without its instrument is not a measurement. Before citing a
  count in this file, state what was matched and against which tree.

---

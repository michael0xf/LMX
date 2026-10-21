# Native indirect CURRENT context — baseline132, 2026-10-21

OPEN dependency after slice131/main8f99b320. No132 implementation or success
is claimed. Final green source remains build/codex_value_cell_131b, with
compiler/runtime build/codex_cell131_build_02. No source/receipted input was
changed while constructing this new witness.

## Actual reproduction

build/codex_deref132_baseline_01 is terminal0 as a RED-baseline recipe.
Its test executable exits1 by assertions:4747 checks,60 failures.
The inherited4555 remain0 failures. The recipe's inherited console word
GREEN is a stale label;the recorded assertion string and process exit are
the evidence,not that label.

The three additional source methods return a pointer read by explicit
indirection,pass it as an ordinary echoFormal actual,or save it in a working
pointer before clearing the original formal. Each executes one observable
mark8. Cases use direct native dispatch and real walked CALL into the native
body,with D/E current views and two actual C99-compatible storage forms:

- an owned canonical void * arena cell whose SAME raw value was changed
  from the prior current context to the selected current context;
- a live LmxWalkValue.ref void * object addressed explicitly,with the
  input Value carrying that resolved owner. No containing-record arithmetic.

The declared native parameter is a genuine void ** pointing to an actual
void * object. No Lmx ** is passed as void **,and no Model is guessed from
the referent layout or from past admissions.

Payloads and once-only effects succeed,but returned CURRENT Model/sheet
is absent. Separate assertions check the caller's unchanged records,
receiving with the reordered map,real7/9,write41,taken field address and
observed43 with the neighbor intact. Some absent-context receptions happen
to produce the expected layout;that coincidence is not a source-context
proof. The explicit CURRENT-state assertions stay required.

Exact SHA256 inputs:

- build/codex_deref132_probe.lm2:
  FF6A6CB6375E3366A0AD15638A1B00AF4E278A0AC0B201F9078142035963B843
- build/codex_deref132_test_01.c:
  5B24D9788BAF682E29F60592002B19F73173B72ACBA8BCBC31B008A7A4A4616E
- generated unit.c:
  8BB7657F9BB74569456A96899D850F988A1368C5FB74412C60EF8171B59AB4B4
- test.exe:
  7D8AB2D1F378B7CD2AED2DF9E5DB843EE1DF03AA8362B23E76768750BE2CAEDC

Recipe:build/codex_deref132_baseline_01.ps1;session79703 terminal0.
The C fixture needs PLACE130_SOURCE selecting that directory's unit.c.
Root64 adds source methods at60/61/62;prior source indices are unchanged.

## Traced producer gap and next implementation constraint

In the current131b compiler,l2_prep_context calls l2_prefix_deref for a
compact prefix word and returns without a value-context result.
l2_prefix_deref still emits prefix text from a separately selected root;
its remaining suffix route manually cuts the root from the path.
The spaced-prefix route,l2_emit_indirect_span,also materializes only a
typed raw pointer via l2_eval_fields,not its explicit current context.
These are inspected gaps,not yet a complete inventory of every consumer.

Do NOT add a Model guess/read guard or a case-specific context repair inside
one legacy emitter. Normalize the complete operand into the shared resolved
value/place/path mechanism,retain the exact source pointer contract and
per-step current owner/map,and have native and walker project that result.
A proven owned cell can supply its actual stored state through the131 pool
operation;an explicitly bound live activation owner supplies its own state.
Neither is permission to infer a Model from the physical candidate.

Preserve exact C99 storage operations and snapshot operand/address once
before later effects. Account for compact/spaced/grouped forms,field/index
transitions,all receiving uses and writes,address lifetime and copying;
do not call a fix to these three methods complete path unification.
Re-run the SAME4747 or expanded unchanged oracles,negative loss controls
and the affected native/forced-walker matrices. Full112/copy/self-build/mail
remain open as recorded in current.md.

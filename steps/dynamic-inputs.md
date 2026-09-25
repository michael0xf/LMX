# Dynamic inputs (grok_next §4 п.6)

A dynamic input is one more argument of the same activation frame, after the declared formals. It is not a field and not a third graph. Mixed numeric types stay a refusal, not a cast. Q7 is not this ticket.

## Kernel

`lmx_walk_call` keeps `n ==` the args-part width. That width is every signature input of the frame, declared formals and dynamic inputs together. An extra argument stays `INVALID` (D-04). A missing one is too. No third graph.

`lmx_walk_dyn_selftest`: width 2, the body reads `ARG 1`, the call passes 1 and 4, the result is 4. One extra argument is `INVALID`. Omitting the dynamic input is `INVALID`. Mutant: drop the `n !=` check — the extra-argument check goes OK.

## Translator

The root (not a quiet method-body try) passes each numeric dynamic input as a call argument after the declared ones. Resolution is `l2_hidden_from`: the caller's formal, then the caller's own field, then the callee's lexical field (`AT` of that occurrence). No binding is `unbound dynamic input <name>`. A non-number stays `a call with an input that is not a number`. A quiet try still refuses `a call of a method with dynamic inputs`, so the walked-method set does not change.

Rows: `unit_dyn_hidden_from_cross_method` (Says `shared=0` then `shared=222`), `unit_asgn_fallback` (host exit 0), `unit_dyn_hidden_from_undeclared_refused` (`unbound dynamic input shared`, frame `gamma`).

## RESULT

Branch tip after the gate commit. Base `404fef8`.

- `lmx_walk_dyn_selftest`: checks=3 failures=0 (width 2 → 4; extra `INVALID`; omitted `INVALID`).
- Mutant: the `n !=` check replaced by `if: 0` — `FAIL one extra argument is INVALID`, checks=3 failures=1, exit 1. Live source restored.
- `unit_dyn_hidden_from_cross_method`: said its 2 lines (`beta sees shared=0`, `beta sees shared=222`).
- `unit_asgn_fallback`: ran, host exit 0.
- `unit_dyn_hidden_from_undeclared_refused`: `unbound dynamic input shared`.
- build 282/282 (`build/l2src/20260925_185022`). harness 401/401 (`build/l2_harness/20260925_185316`).
- Mixed numeric types were not cast. Q7 was not waited on. No third graph.

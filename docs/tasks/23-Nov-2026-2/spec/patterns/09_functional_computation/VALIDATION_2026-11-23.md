# Functional comparison validation — 2026-11-23

All eight comparison subjects remain: four usage scenarios (082–085) and four companion implementations (091, 092, 098, 099). There are 24 primary listings. LMX usage calls direct core functions; foreign usage calls real facilities and does not import the custom comparison modules.

## Boundary and completeness

| Scenario | Haskell usage | Scala usage | Separate implementation |
| --- | --- | --- | --- |
| Monad | `Maybe`, `Just`, `Nothing`, `(>>=)` from base | `Option`, `Some`, `None`, `flatMap` | Generic constructors and bind, 091 |
| Trampoline | `Free Identity` and `iter`, package `free` | `scala.util.control.TailCalls` | Generic done/more/runner, 092 |
| Execute Around | `Control.Exception.bracket` | `scala.util.Using.resource` | Complete scoped single-resource API, 098 |
| Currying | Ordinary curried application | `Function2.curried` | Arbitrary typed prefix binding, 099 |

The implementation scopes are explicit. They do not claim to reproduce every function of `Option`, `Free`, `TailCalls`, or `Using.Manager`. Full generic value and prefix handling, cleanup on failure, relevant interruption semantics and shared dependency costs are disclosed rather than reduced to the usage example's integer values.

The Haskell resource implementation now masks setup/cleanup and restores the caller's masking state during action. The Scala implementation preserves dual failures using severity and suppression. The LMX implementation allocates its cleanup actual vector before acquire, stores the successful result in the ready cell, and registers `finally` before preparing action arguments; failed acquisition never registers release. Successful resource transfer through the native provider remains an integration obligation. [Failure boundaries](FAILURE_BOUNDARIES.md) explain precisely what Message/post already provides and what a single local resource lifetime cannot cover.

## Deduplication

The primary source is emitted once per language. Duplicate primary files in `variants/` and full commented historical tails were removed. Minor import, spelling, repeated-body and type-specialization variations are described in text. Only two full non-primary alternatives remain:

- 084: complete local callback composition through `Around`, compared with direct core `bracket` usage.
- 085: independent prefix binding through `partial`, compared with staged `curry`.

The source upload remains the base of the merge diff; historical receipts are explicitly superseded and do not validate the new source.

## Performed checks

`tools/check_publication.py` performs 195 source/publication checks: exact JSON/source/fence correspondence, declared selection boundary and counts, retained complete alternatives, no custom comparison imports in foreign clients, scope-specific cleanup source invariants, generic prefix declarations and honest runtime status.

The [machine report](validation_2026-11-23.json) records the current outcome. [33 prepared acceptance observations](acceptance_cases.json) cover non-integer payloads, absence, callable final values, stack-driving transitions, acquisition/action/release failures, dual failure, interruption, Message ownership, empty/full/mixed prefixes, void and independent captures. They are **NOT_RUN**.

The workspace has no executable LMX kernel, GHC or Scala compiler. Static source checks are not parsing/typechecking or runtime acceptance. No language execution or performance result is claimed. Integration still needs the existing ordinary LMX call-phase hooks documented in [KERNEL_REQUIREMENTS](../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md).

## Reproduce publication

Run these scripts from this directory in order:

1. `python3 tools/sync_receiver_bodies.py`
2. `python3 tools/select_shortest.py`
3. `python3 tools/regenerate_publication.py`
4. `python3 tools/curry_appendix.py`
5. `python3 tools/check_publication.py`

The archive-wide generators then regenerate statistics, workbooks and PDFs from the same primary listings. The component [dependency ledger](IMPLEMENTATION_DEPENDENCIES.md) counts shared LMX definitions separately and identifies native kernel boundaries without assigning them a fictitious zero implementation cost.

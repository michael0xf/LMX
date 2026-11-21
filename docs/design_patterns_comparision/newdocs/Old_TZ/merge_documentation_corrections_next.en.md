# Composition follow-up: current decision index

**Status:** applied documentation requirements, reconciled through 2026-11-21.
The prior follow-up questions are not reopened; this document states their surviving consequences under the
[current composition rules](../LMX_semantics.en.md#composition) and
[copy/merge note](merge_documentation_corrections.en.md). It records no new runtime test result.

| Earlier finding | Current consequence |
|---|---|
| N01 — callable descriptions | A selected ordinary Structure C executes over its actual `parent(C)`. `call(A C)` supplies actuals A; it does not substitute DATA. Composing code and composing its input description are distinct operations, and merely storing a reference does not reparent C. |
| N02 — working-state publication | Own activation places have no write-back. Load-dirty, the shared direct-access value cache, and flush are withdrawn. Transparent caller binding writes the caller's real cell immediately and must not be simulated by copy-out. |
| N03 — same-name occurrences | DATA declarations remain separate occurrences selected by `S\[N]field`. A reached same-level CODE redeclaration updates the existing place; a real nested declaration shadows with a distinct place. Inside one merge, its own model-slot overlay is separate from ordinary DATA acceptance. |
| N04 — editorial separation | Clear descriptions of source copying, native reuse, namespaces, and binding are required; an old paragraph count or repository build diary is not an acceptance condition. |

copy has one source and merge has at least two admitted sources, with ordinary CODE W/E selection.
All three receivers `import`, `copy`, and `merge` consume CODE arguments in every placement; a DATA recipient does not change that argument role. Bare references and anonymous Structures remain values, while explicit source calls execute on consumption. Their results are field streams; explicitly group when one Structure is required.
Neither operation receives the current target implicitly. Each operation preserves its own common copying map;
accepting its stream does not mutate the source receiver or combine the maps of separate operations.

A named fn: name data requirement checks the number and ordered types of explicit inputs and its result, ignoring
formal names, initializer values, and implementation-body trees. An ordinary structural model instead requires
all its explicitly described fields and subtrees. Neither check binds arguments or changes `parent(C)`.
Actual candidate defaults/required/throws remain in force.

A free name uses a protected lexical private source, otherwise an eligible transparent caller place, otherwise
the preserved own-copy fallback. Copying does not rewrite that order. Explicit node paths remain lexical.
Reuse of a machine implementation does not establish identity of mutable callable occurrences.

Qualified independent: immutable retention does not require const. This supersedes the older stricter
independent: const: immutable-only condition while preserving qualification and lifetime checks.

If a real contradiction remains after the current requirements are applied, record the conflicting current
rules and a minimal distinguishing example. Do not restore a superseded rule or create a receiver-specific
implementation branch merely to satisfy an old example.

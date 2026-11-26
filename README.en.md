# LMX

LMX is an active language and kernel project. Its current goal is the [v3 plan](next_core_tasks_v3.md): a unified L3 graph, kernel migration, and self-build from L3 with L2 inserts; L1 remains a generated intermediate level. The [current work status](steps/current.md) distinguishes approved semantics from the ABI not yet implemented.

- [Semantics](docs/spec/LMX_semantics.en.md): current rules and the approved migration target.
- [Short explanations and examples](docs/spec/LMX_semantics_guide.en.md): data traversal, receiver execution and two admission steps.
- [Sol handoff and next work](to_sol.md): P0/M8/M11 status, preserved WIP and the selfbuild priority (Russian).
- [L1 and C99 lowering](docs/spec/L1_spec_en.md).
- [Low-level L2 operations](docs/spec/L2_spec_en.md).
- [Grammar](docs/spec/LMX_grammar.en.md): P0 rules and original examples, separate from the kernel.
- [Types and arrays](docs/ARRAY_TYPE_MIGRATION.md), [Expression integration](docs/ARRAY_EXPRESSION_INTEGRATION.md), and the [interpreter and SLJIT design](docs/LMX_INTERPRETER_JIT.md) describe the current migration contracts and the planned execution architecture.
- [Implementation and migration notes](docs/spec/implementation-notes.en.md): nonnormative code snapshots, translator limits, developer work, and open decisions.
- [Comparison of previous specifications](docs/spec/source-comparison.en.md).
- [Parser tests and migration status](tests/parser/README.en.md).

Each specification and notes document has an adjacent English/Russian counterpart with the same sections, rules, and examples. Code examples retain their source language. `provenance/semantics-book.md` and `provenance/grammar.json` are sources of generated specifications; historical snapshots in the notes and `tests/parser/imported` do not establish current semantics on their own.

The grammar is stored as paired translations and exact source excerpts in `provenance/grammar.json`; the language-owned `docs render grammar` command renders both readable files. `docs check` checks synchronization, links, source excerpts, and imported-test integrity; [the commands](READ.ME#docs-cycle). This check does not require the old projects; when available, their original bytes are also compared.

An explicitly empty vertical body (`f:` closed by `---`) gives the same Frame with an empty body as `f()` and `f:`, while `f: ()` is the same as `f(())`: a Frame with one field, an empty Structure (the author's clarification of 2026-09-19 and decision of 2026-11-10, [grammar, §18](docs/spec/LMX_grammar.en.md#empty-colon)). This rule takes precedence over the old parser's rejection. P0 unwraps nothing: the unwrapping postpass was removed in M8, slice 366. A sole Structure among the arguments is unwrapped only when a call is processed -- for a callable and for a receiver that takes its arguments as `code`, when the name has no declaration with one argument and has declarations with several; a receiver that takes its arguments as `data` receives exactly what is written ([semantics](docs/spec/LMX_semantics.en.md#two-kinds-of-receivers)).

# LMX

The new project starts with documentation. The previous kernel design is not imported.

- [Semantics](docs/LMX_semantics.en.md): the opening supplied by the author and levels L0–L3.
- [Grammar](docs/grammar.en.md): P0 rules and original examples, separate from the kernel.
- [Comparison of previous specifications](docs/source-comparison.en.md).
- [Parser tests and migration status](tests/parser/README.en.md).

Each document has an adjacent English/Russian counterpart with the same sections, rules, and examples. Code examples retain their source language. Historical material in `provenance` and `tests/parser/imported` does not establish the new kernel's semantics.

The grammar is stored as paired translations and exact source excerpts in `provenance/grammar.json`; `python tools/build_docs.py` renders both readable files. `python tools/check_docs.py` checks synchronization, links, source excerpts, and imported-test integrity. This check does not require the old projects; when available, their original bytes are also compared.

An empty vertical body is a `()` argument, per the author's 2026-09-19 clarification. This rule takes precedence over the old parser's rejection.

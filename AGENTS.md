# LMX documentation-first restart

- Start from `docs/semantics.ru.md` / `docs/semantics.en.md` and the user's current instructions. Do not import old Message/arena/runtime designs as new requirements.
- Keep RU/EN documents synchronized in meaning, order, examples, and cross-references. Preserve the author's Russian semantic opening verbatim.
- Grammar source: `provenance/grammar.json`; render using `python tools/build_docs.py`. Preserve copied examples and their source ranges.
- An explicitly formed empty vertical body is a present empty Structure argument, synonymous with `()`. `receiver:` followed by `---` is valid. Never treat an empty argument's interior as absence of that argument.
- Imported tests and goldens are historical evidence. Do not rewrite them to hide a disagreement. Current language expectations are separate under `tests/parser/current`.
- Work only in this LMX repository unless the user explicitly requests edits to another project. The initial work is documentation and parser-test migration, not kernel implementation.
- Before committing, run `python tools/check_docs.py`. Report parser conformance separately from historical-regression agreement.

# Visibility corrections and private examples — 2026-11-15

Documentation only; no runtime changes.

- Group positional assignment and catch refer to the common declaration-visibility rule.
  Variables and const are sequential; named Structures and callables remain bidirectional.
- The adjacent structural-forms paragraph no longer permits declarations anywhere in a method.
- Paired private examples show receiver composition, dynamic-source exclusion, retained lexical
  lookup, explicit field reads/writes, and independent local/source-code places.
  These are specified results, not execution claims; private implementation remains OPEN.

Source: provenance/semantics-book.md. Generated: docs/LMX_semantics.ru.md and .en.md.
Normal accepted Tool03 SHA256:
aed079b8814716847a34a8fc5af66ac64e2d1922ab9ee704ddc3bf46decee37b.
Run output: build2/visibility-private-examples-20261115.

- Semantics render: PASS35 paired chapters, 14 cases, both source snapshots.
- Final staged docs check: PASS35/14/27/44/615, links/opening, LF28305, exit 0.
- Working and staged diff checks: PASS; superseded visibility wording scan: no matches.
- Concurrent code and steps/current.md work excluded.

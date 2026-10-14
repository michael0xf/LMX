# Merge documentation correction — completed historical task

**Status:** Fable's 2026-09-28 bilingual edit is complete. The original
line-by-line request, D01–D12 review, and run record are available in Git
history; this file is not an open ticket. Current authority is the
[composition rule](../LMX_semantics.en.md#composition),
[copy/merge mechanics](../L2_spec_en.md#copy-merge), and
[plan v3](../../next_core_tasks_v3.md).

The useful distinction from that correction remains:

- Ordinary used graph material is copied into the result. A common
  source-to-copy map redirects internal links to copied targets and
  preserves intended sharing/cycles; a copied mutable occurrence does
  not keep pointing to the old arena merely because it is a method.
- A machine implementation address is not a graph instance. Native
  implementation reuse is possible only for a compatible selected
  body and its used ABI; changing the selected body cannot keep an
  unrelated native entry.
- `merge` does not bind formals, capture a caller frame, or override
  dynamic inputs. Caller-supplied free inputs precede permitted lexical
  fallback; explicit `node\…` selects the lexical context. An explicit
  value `y: 5` merged into a callable description can become formal
  `y`'s default under the ordinary call contract. Zero supplied by a
  caller is not absence.
- A qualified `independent: immutable` branch may retain its original
  physical reference under its owner/lifetime contract. This is
  distinct from native-code reuse and ordinary copying.

The 2026-09-28 instruction in this file used
`independent: const: immutable` as the **only** retained branch. That
strict `const` requirement is **superseded** by the later author ruling:
`const` is not mandatory for this qualified retention. The old note's
same-name occurrence discussion and any special sharing of file-level
methods are likewise not current rules. Consult the canonical specs and
[current critical copy gate](../../next_core_tasks_v3.md) before
claiming an implementation passes.

The following [historical follow-up](merge_documentation_corrections_next.en.md)
records which 2026-09 questions were answered and which of its premises
were later superseded.

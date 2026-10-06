# Source-level grammar audit — 2026-10-06

## Scope and result

This is a non-normative audit of the explanation of source-level transitions,
short/vertical forms, markers, and closing scope in the paired LMX grammar.
It does not certify that every semantic rule in every historical specification
has been retained. Historical semantics intentionally changed as the author
revised the language; source preservation is not semantic equivalence.

Before this edit, the main level rules were present, but their rationale was
compressed across §§2, 10, 14–17, and 24. In particular, §15 did not explain
the shared event model, the opening/completion asymmetry, or the difference
between an inline implicit level and a physical source line's level in enough
detail. §10 also used N without making that distinction explicit when nested
short forms occur on one line. These explanations are now restored in
[RU §15](../docs/LMX_grammar.ru.md#levels) and
[EN §15](../docs/LMX_grammar.en.md#levels), with §10 linking to that account.

This edit changes no parser code, acceptance expectation, or semantic call rule.
The already resolved `r: twice:` / fence witness is explained, not reopened as
a bug or a post-self-build research task.

## Sources actually compared

The grammar's extraction source is
`C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt`, SHA-256
`d4bb1e70c9d660b185ec084ed4c636ce75bc08dd100786c754401017cade221c`.
The tracked [older source snapshot](semantics-sources/older.txt) has the same
SHA-256. Line references below refer to this extraction source.

For comparison with the working old checkout, the audit also read the relevant
parts of `C:/Nyasha_Planet/lingvamyxa_old_worked_version/Lingvamyxa_spec.txt`,
SHA-256 `70fabd2de0a5a90655a55952fa0d9f3862f672a183dffd1d6e62ff6ff369c61a`,
and its `Lingvamyxa_parser_P0_close_rules.txt`. These are not byte-identical
revisions of the extraction source. The latter file explicitly calls itself
an implementation instruction, not a replacement specification.

Current author clarifications consulted:

- [One-step cuts and scoped terminal return](../LMX_blog/2026-10-02.md#indent-close).
- [Explicit call frames](../LMX_blog/2026-10-06.md#explicit-call-frame).
- [The resolved short-form/fence witness](../LMX_blog/2026-10-06.md#vertical-call-fence).

## Coverage of the level model

| Old extraction source | Contract checked | Current primary location |
| --- | --- | --- |
| Reading guide, lines 741–784; §4.5, 3329–3359 | Source items and events build the tree; physical lines are not AST containers; one model includes colons, brackets, and markers. | §15, “One stream of structural events”; §24 |
| §4.5, 3312–3327; §4.5.2.1, 3544–3560 | Absolute dotted levels and relative indentation columns map to the same tree; a first deeper column is one step. | §15, first subsection; §14 |
| §4.2.1, 2857–2870 | A colon opens the implicit argument level; whitespace/comma separate; semicolon and matching brackets have distinct closing roles. | §10; §11; §14; §15, short forms |
| §4.2.1, 2872–2889; §15.0, 8651–8672 | An increase opens a Structure; a newline separator alone is not a trailer; an inline/vertical transition retains its Structure boundary. | §10; §15, short forms |
| §4.2.1.1, 3054–3088 | A newline returns to the completed physical line's level, not the deepest inline head; a later two-level increase is invalid. | §15, short forms; both unchanged old examples at 3076–3079 and 3085–3088 |
| §4.5, 3340–3351; §15.0, 8629–8645 | Ordinary increases and decreases are one-step; larger decreases require an admitted tail cutter; names do not require explicit `end:`. | §15, transition table; §17 |
| §4.5, 3391–3424 | Head/body/trailer is an envelope; trailer means completion, not a mandatory token; a marker can close one anonymous section and open the next. | §15, envelope and markers; §16 |
| §4.5.1, 3481–3520; §4.5.2.1, 3562–3597 | A marker has its own written level, no receiver payload, and opens an anonymous field only with deeper following children; admitted fences can cut multiple levels. | §16; §15, marker ownership |
| §4.5, 3476–3479; §15.0, 8647–8649 | Empty physical lines are separate level-0 boundary events, not same-level anonymous separators. | §15, final subsection |
| §4.5.2.1, 3551–3558; §15.0, 8687–8705 | Bounded forms retain their context across newlines; tail cutters do not replace matching brackets; Mix uses its own local base. | §14; §19; §24; §15, bounded forms |
| §15.0, 8612–8627 | Shielded literal/comment payload does not create outer structural events. | §§3, 5–9, 19, 24; §15, final subsection |
| §§7.5, 8.3; current author's scoped-return clarification | A terminal return is admitted at its executable definition's level, not promoted from an inner body by spelling alone. | §17; §15, closing scope |

The matrix concerns these concepts, not every line of the whole old book.
It distinguishes source-level syntax from semantic invocation and from the
implementation's choice of scanner routines or temporary counters.

## Historical differences not reintroduced

1. In the working old specification, §4.2.1.1 at lines 2551–2569 labels the
   nested short-form witness followed directly by level 2 as valid. The
   extraction source at 3070–3088 explicitly labels it invalid and supplies
   the one-step vertical spelling. Both current grammar examples already
   retain the extraction source's labels. Restoring the earlier “valid” claim
   would contradict that revision and the resolved author clarification.
   “Working” identifies the checkout, not proof that this old text matches
   its parser. A read-only run of that checkout's existing
   `build/p0_tree_contract/printTree_620db86.exe` against
   `build/codex_call_vertical_20261006/fragment_vertical_direct.lmx` returned
   P0 error 13 at 2:5, “source level increase must be one step”. The old
   implementation rejects the jump despite the old specification's wording.
2. In the working old specification, §4.5.2.1 at 3108–3111 says a dash fence
   is not a general multi-level tail cutter. The extraction source at
   3572–3579 and 3833 explicitly admits a multi-level fence close from a valid
   position; the author also confirmed multi-level admitted trailers. The
   current rule is retained, not weakened to the earlier one-step statement.
3. The working old close-instruction file calls comma a short-form trailer,
   treats empty lines as formatting only, and describes general downward cuts
   without the later one-step restriction. Its wording conflicts with the
   extraction specification and current grammar: comma separates fields,
   semicolon closes short forms, empty lines are level-0 events, and larger
   ordinary decreases need an admitted cutter. It is historical evidence,
   not authority for silently replacing these current rules.

## Preservation and verification boundary

All 232 existing example records in `provenance/grammar.json` remain unchanged,
including the 229 line-ranged verbatim source excerpts,
including their start/end lines, text, and captions. No imported historical
test or golden is edited. Both grammar documents are generated by
`python tools/build_docs.py` from the same bilingual input. The existing
`python tools/check_docs.py` gate verifies rendering, source SHA-256, exact
excerpt bytes, imported file bytes, links, and tracked text hygiene.

Those checks establish preservation and consistency of the materials they
cover. They do not prove that the parser implements every normative rule, that
all historical parser runners have been integrated, or that the whole former
semantic specification is identical to the current language. No build or
parser repair is claimed by this documentation checkpoint.

The two `r`/`twice` examples were also rechecked read-only with the existing
`build/fable127_part1b/printTree.exe`; no compiler was started. The split-head
form gives `r -> twice -> atom 3`. The marker form gives two fields under `r`:
an empty `twice` Frame and an anonymous Structure which itself contains an
anonymous Structure with atom `3`. The grammar explains ownership of that
field without presenting a flattened schematic as an exact parser dump.

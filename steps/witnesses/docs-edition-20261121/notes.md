# The documentation edition of 2026-11-21 is transferred into the current documents

Written 2026-11-21 by Fable (fable_pc), the single writer of main. The author's order of 2026-11-21: transfer
the new edition of the documentation (`docs/new_parts/newdocs/`) wholly into the current `docs`, `CORE.md` and
`L2_L3_CODING_INSTRUCTION.md`, extend the plan by the application of the changes and continue the work. The
semantics book was transferred by the peer session sonnet, the grammar by the peer session haiku; Fable set the
rules, transferred the other documents, fixed the links, wrote the plan section and checked the result. The
plan: `next_core_tasks_v3.md#docs-20261121`; the executor's record: R111 and R112 of
`LMX_blog/q/fable-self-answers-20261110.md`.

This is a documentation change. No compiler, runtime or test was built or run for it.

## What the packet is

`docs/new_parts/newdocs/` as committed by the author (`876d1ef5` and the following commits): nine primary English
documents, `README.md`, `REVIEW_NOTES.md`, six requirement files in `TZ/`, eight maintained supplements in
`Old_TZ/`. All files have LF line endings, no byte-order mark and a final line feed. The packet stays where the
author put it: his `docs/new_parts/MANIFEST.sha256` and the example documents refer to it.

## Where it went

| Packet file | Current document | How |
|---|---|---|
| `README.md`, `REVIEW_NOTES.md` | `docs/README.md`, `docs/REVIEW_NOTES.md` | copied |
| `TZ/*` (6), `Old_TZ/*` (8) | `docs/TZ/*`, `docs/Old_TZ/*` | copied |
| `L2_spec_en.md`, `LMX_semantics_guide.en.md`, `kernel-implementation.en.md`, `implementation-notes.en.md`, `source-comparison.en.md` | the same names in `docs/` | copied |
| `LMX_semantics.en.md` | `docs/LMX_semantics.en.md` | through `provenance/semantics-book.md`, by the generator |
| `LMX_grammar.en.md` | `docs/LMX_grammar.en.md` | through `provenance/grammar.json`, by the generator |
| `CORE.md`, `L2_L3_CODING_INSTRUCTION.md` | the same names in the repository root | copied |

The text is verbatim. What differs from the packet:

- Link targets required by the placement. In the two root files every relative target got the prefix `docs/`
  (25 links in `CORE.md`, 12 in the instruction). In `docs/README.md` the two links to the root files point one
  level up; in `docs/TZ/to_fable_operands_arguments_priorities.md` two links to the root files point two levels
  up. No other file needed a change of links.
- A marked repository note after the title of `CORE.md`, of `L2_L3_CODING_INSTRUCTION.md` and of
  `docs/README.md`: where the edition came from, where the state of the implementation is recorded, the mandatory
  build order, the state of the Russian documents.
- `docs/LMX_semantics.en.md` equals the packet byte for byte (`cmp`).
- `docs/LMX_grammar.en.md` differs from the packet in three places, all written by the generator: the caption of
  the EBNF example (`** — ` where the packet has `**, `) and the fence language of two examples (`text` where the
  packet has `ebnf`).

## The semantics book (sonnet)

- The generator takes the opening of each book from the document itself and the chapters from the source. The
  source was rebuilt by inverting what the generator does to a chapter body: the anchor it inserts before each
  of the fourteen admission cases is removed and the two source snapshots become the placeholders again.
- `docs render semantics` and `docs verify semantics` answer «35 paired semantic chapters, 14 implements cases and
  both verbatim source snapshots»; Fable repeated `cmp` and `verify`.
- The structure is unchanged: 35 chapters with the same titles. Explicit anchors: 125 before, 131 now, none lost;
  the six new ones are `declaration-arguments`, `expression-eval`, `graph-fragment-assignment`,
  `import-receiver`, `program-representation`, `raw-operands`. All 527 links into the book from the other
  documents still resolve.
- Paragraphs of the chapters: 623 before, 702 now. In the Russian halves 371 keep their former Russian text
  (the English paragraph did not change), 4 keep it with new link targets, 327 stand in English and wait for the
  translation: 232 new paragraphs and 95 changed ones, about 28 000 words. Code blocks are byte-equal in both
  halves.
- The Russian opening begins with the author's three paragraphs byte for byte: the check of the opening compares
  them. The edition changed the third paragraph of the English opening; its translation stands in the paragraph
  added after them, together with the note that the English text governs. The English document has the title
  line `# LMX semantics`, the Russian one cannot begin with it; the paragraph counts of the two documents are
  equal, 747.

## The grammar (haiku)

- `provenance/grammar.json`: the fields `en` and `ru` of 18 of the 27 sections and the examples of two sections.
  The identifiers and titles of the sections are unchanged; all 27 section anchors are kept; four link targets
  are new (`declaration-arguments`, `field-streams`, `graph-fragment-assignment`, `operand-templates`).
- The EBNF example is no longer a verbatim excerpt of the former specification: the edition's text is the
  current projection with the accepted corrections. Its `start` and `end` are removed, so the check of excerpts
  does not compare it; its caption comes from its `origin`.
- The Russian paragraphs that changed or are new were translated, 50 blocks; Fable read them. The field `origin`
  of an example is shared by both languages, so three Russian captions carry the English word `author` and the
  caption of the EBNF example is English.

## The other Russian documents

`docs/L2_spec_ru.md`, `docs/LMX_semantics_guide.ru.md`, `docs/kernel-implementation.ru.md`,
`docs/implementation-notes.ru.md` and `docs/source-comparison.ru.md` are replaced by bridges: a title, a link to
the English edition and the explicit anchors of the English document (54, 49, 28, 13 and 0 of them), each linking
into the English text. The former Russian texts described the withdrawn norm, and the new English documents are
rewritten almost entirely: of the bytes of the new English text 43 % (L2), 32 % (guide), under 1 % (kernel), 18 %
(notes) stand on lines that the former English document also had. The former texts are in the history
(`git show 150f01f5:docs/<name>`). The L1 specification was not part of the packet and is unchanged except for
link targets and one sentence about the closed question on the unit root.

## Links to the files the author moved

The author moved the requirement files and supplements out of `docs/new_parts/` (to `docs/old_parts/` and into
the packet). 28 link targets in 15 tracked files now point to `docs/TZ/`, `docs/Old_TZ/` or `docs/old_parts/`.
Only link targets were changed, not plain mentions of a path and not quoted text. Before the transfer
`docs check` failed on `150f01f5` at the phase of links for this reason (`O/docs-index158.log`).

## Questions closed by the edition

Two open questions are moved from `LMX_blog/q/current/` to `LMX_blog/q/` with the text of the edition that
answers them: the declaration argument and `for` (the requirement on declaration arguments, §3.2 and §12) and
the unit root under R0 without data (the derivation D2 of the review notes). The question on the arithmetic
contract of integers stays open.

## Checks

- `cmp docs/LMX_semantics.en.md docs/new_parts/newdocs/LMX_semantics.en.md`: equal.
- `diff docs/LMX_grammar.en.md docs/new_parts/newdocs/LMX_grammar.en.md`: the three places named above.
- The copied files against the packet: equal after undoing the link prefixes and the repository notes (the
  script `transfer_docs.py` writes them from the packet in one pass).
- The scan of links and explicit anchors over the documents the tool reads (root `*.md`, `docs/*.md`,
  `steps/*.md`): no missing target and no missing anchor that the transfer introduced.
- `docs check` of the tool on the tree with the transfer (`O/docs-index161.log`): «OK: 35 paired semantic
  chapters, 14 implements cases, both source snapshots; 27 paired grammar sections, 43 verbatim source
  excerpts, 615 imported files, links, exact semantic opening; line endings LF in the index for all 29562
  tracked files». The excerpts were 44: the EBNF example is no longer one.

Two findings of that check in the files the author committed, fixed with this change:

- The spreadsheets `*.xlsx` of `docs/new_parts/` and `docs/.DS_Store` are binaries without an explicit
  attribute; `.gitattributes` now names `*.xlsx` and `.DS_Store` as `-text`.
- `docs/new_parts/03_domain_and_persistence/024_domain_model_comparision.md` held the control character
  0x08 twice, in `node<0x08>alance`: a path `node` + backslash + `balance` whose backslash and `b` had been
  read as an escape. Both places are restored, and the line of the file in the author's
  `docs/new_parts/MANIFEST.sha256` carries the new hash (17d8b787… → 83b337e8…).

## Not done

- The Russian edition: the five documents replaced by bridges. The 327 waiting paragraphs of the book were
  translated by haiku on the same day in four portions (78, 68, 87 and 94 paragraphs), each verified by the
  generator, and the terms of the translated paragraphs were brought to those of the unchanged Russian text.
- The L1 specification is not compared with the edition.
- The dated paragraphs of `READ.ME` that describe the former norms are history; a paragraph that states a
  withdrawn form as current is brought to the edition with the step that removes the form from the code.

Receipts outside the repository, under
`build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01/fable/tz-20261121/`: `PROGRESS.md`,
`sonnet-semantics/` (report, the list of waiting paragraphs, scripts), `haiku-grammar/` (report, renders),
`opus-map/MAP.md` (the map of the edition against the code, step 21.1 of the plan).

## After the transfer: an author's decision applied to the working documents

2026-11-21, the same day. The author's decision recorded in `LMX_blog/2026-11-21.md#group-assign-decision` (the
single `right` argument of an operand, when it is an unnamed Structure, is opened; a Structure
returned from a function is not opened; a field stream on the right of a group assignment is written inside a
group) was applied to the working documents: the semantics book and the grammar through their sources, the L2
specification, the guide, the kernel implementation notes, the implementation notes, `CORE.md`, the developer
instruction, dated notes in two requirements, the author's example R02 with its manifest hashes. Record of the
executor: R124 of `LMX_blog/q/fable-self-answers-20261110.md`.

2026-11-22. The author edited that rule (`LMX_blog/2026-11-22.md#operand-left-unnamed-structure`): the
parentheses on the right are opened when `left` is an unnamed Structure and the single `right` argument is an
unnamed Structure too. The same documents carry the edited rule; records of the executor: R136, and R137 for
the integer numeric contract decided the same day.

## The packet copy is removed

2026-11-21, on the author's order («удалите дубли в newdocs и поменяйте ссылки в md везде в документах из
new_part»): the 25 files of `docs/new_parts/newdocs/` were removed as duplicates of the working documents — 20 of
them equalled the working copies byte for byte before the decision above, five differed only by the link targets
of the placement, the repository notes and the generator's formatting of the grammar. In 149 documents of
`docs/new_parts/` 825 references to the packet directory were rewritten to the working documents; the manifest
`docs/new_parts/MANIFEST.sha256` lost the 25 lines of the removed files and got the new hashes of the rewritten
ones. Four validation records in JSON keep the packet paths as the history of the author's review.

## The directory `docs/old_parts/` is removed

2026-11-22, on the author's order to remove the duplicates of `docs/Old_TZ/` to the end. `docs/old_parts/` held
fifteen files the author had moved out of `docs/new_parts/` before the packet arrived: earlier versions
(2026-10-14 to 2026-11-20) of the eight supplements whose current texts are in `docs/Old_TZ/`, earlier versions
of four requirements of `docs/TZ/` (one byte-equal, three older) and three Russian translations of earlier
supplement texts. The twelve earlier versions are removed. The three Russian files are moved to `docs/Old_TZ/`
and brought to the current English texts line by line; `dirty.ru.md` there is the Russian text of the current
`dirty.md`, with the author's former Russian wording kept where the meaning is unchanged. Three links follow
the move: in the executor's ledger, in the plan dictionary and in a review record of 2026-09-30. No current
working document linked to `docs/old_parts/`. In the three moved files nine kept Russian lines that had
lagged behind the earlier English text were corrected as well.

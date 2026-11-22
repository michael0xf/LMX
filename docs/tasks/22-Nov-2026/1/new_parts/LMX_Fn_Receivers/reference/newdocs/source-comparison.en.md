# Source specification comparison and provenance

This note preserves the reported comparison of two historical source files on 2026-09-19:

- C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt
- C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt

The original comparison reported 596 added and 33 removed lines in 19 changed regions in the L1 copy.
It reported line-for-line agreement in grammar sections §0.0.2, §§3.4–4.10, §§6.1–6.4, §7.5, §§8.1–8.4,
§§11–13, §15, §16.4, and §§20.1–20.3. The §6.5 addition concerned array storage.

The original source files, full diff, and machine comparison report are not included in this standalone archive.
These counts and digests are retained provenance claims, not a comparison rerun for this revision and not additional
LMX semantics. The archive is usable without those missing artifacts.

| Historical section | Reported L1 change |
|---|---|
| §2 | Added the LmxMsg record with running, success, handoff_safe, root, and index; other management data remained graph contents. |
| §2, §6.5 | Clarified nonmoving arena arrays, typed descriptor arrays, and one address-to-description table with binary search; known-type writes use real cells rather than separate owner/eternal-range lists. |
| §19.28.R2.2 | Clarified Message/L3 Thread relationships, one writing lane per arena, mailbox synchronization, scheduling, and management. |
| §19.29.2 | Restated one arena per Message and arena attachment on consumption. |
| §19.29.6 | Expanded family release, self-termination, supervision changes, and root-state rules. |
| §19.29.7 | Distinguished transferring a Message with its arena from supervision; described hierarchical addressing and no extra delivery copy. |
| §19.29.7.1 | Described the then-named copy-only path through graph copying into its own arena and transfer; removed separate envelope/deduplication identifiers and clarified timeouts and completion flags. |
| §20.5.7 | Retained synchronized as a general L2 capability rather than making one kernel's restriction a language prohibition. |

The earlier merge name for single-source copying is historical. Current copy accepts one admitted source,
merge accepts at least two, and both supply field streams. `import`, `copy`, and `merge` always consume ordinary CODE arguments, including when their output is accepted in DATA. Bare references and anonymous Structures remain values; explicit source calls execute on consumption. These and all other current contracts are governed by
[semantics](LMX_semantics.en.md), [grammar](LMX_grammar.en.md), and the in-archive
[2026-11-21 requirements](TZ/LMX_Fable_TZ_Import_Copy_Merge_Field_Streams_2026-11-21.md),
not by the older comparison.

P0 preserves a sole anonymous Structure, including an empty one. `f()`, f:, and an explicitly empty vertical
body have an empty Frame-body; f: () is `f(())` with one empty Structure field.
A blank physical line outside shielded content completes the whole current block to its document root without
creating a field or return. These rules supersede any historical P0 unwrapping or level-0-only empty-line
annotation. See [empty bodies](LMX_grammar.en.md#empty-colon) and [source levels](LMX_grammar.en.md#levels).

All receivers remain as written in the source graph, with terminal primitive declarations represented directly
as `{type value}` at the addresses held by Structure cells. These leaves are part of the complete literal source.
The [latest author clarification](TZ/LMX_Author_Clarification_Uninit_Graph_Assignment_2026-11-21.md) also fixes
code-only zero-payload uninit and ordinary graph-fragment replacement, including executable receiver structures;
the existing compile/endturn boundary handles required machine updates. Computations and transformations belong
to the namespace. Historical excerpts or examples
do not authorize graph rewriting, former executable function/sub forms, a sys operand registry, or container-valued merge.

Reported source SHA-256 values:

| Historical source | SHA-256 |
|---|---|
| lingvamyxa | d4bb1e70c9d660b185ec084ed4c636ce75bc08dd100786c754401017cade221c |
| L1 | bdb1a6411a47f1cfc9721c1ff002a001cb7fd19cd087ce15fb398f085cc71b53 |

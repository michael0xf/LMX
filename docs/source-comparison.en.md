# Source specification comparison

`C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt` and `C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt` were compared on 2026-09-19. The complete [line diff](../provenance/spec-comparison.diff) and [machine report with SHA-256](../provenance/spec-comparison.json) are retained for provenance verification. This is a historical comparison, **not additional LMX semantics**.

L1 relative to lingvamyxa contains **596 added and 33 removed lines in 19 changed regions**. Grammar sections §0.0.2, §§3.4–4.10, §§6.1–6.4, §7.5, §§8.1–8.4, §§11–13, §15, §16.4, and §§20.1–20.3 match line for line. The addition in §6.5 concerns array storage, not syntax.

Substantive L1 changes:

| Previous specification section | Change |
| --- | --- |
| §2 | Adds the `LmxMsg` record with `running`, `success`, `handoff_safe`, `root`, and `index`; other management data are described as graph contents. |
| §2, §6.5 | Clarifies nonmoving arena arrays, typed descriptor arrays, and one address → description table with binary search. Direct cell writes are required when the type is known. Separate owner-range and eternal-range lists are rejected. |
| §19.28.R2.2 | Clarifies the Message/L3 Thread relationship, one writing lane per arena, mailbox synchronization, and scheduling/management roles. |
| §19.29.2 | Restates one arena per Message and arena attachment on consumption. |
| §19.29.6 | Expands family release, self-termination, supervision changes, and root-state rules. |
| §19.29.7 | Clarifies transfer of the Message itself with its arena, no extra delivery copy, the distinction between supervision and storage transfer, and hierarchical addressing. |
| §19.29.7.1 | Reduces `copy-only` to creating a copy through merge in its own arena and transferring that arena; no separate mechanism is introduced. Removes `create_id`/tombstone idempotence, deduplication keys, and a separate envelope entity. Clarifies timeouts, the root thread's parent, and completion flags. |
| §20.5.7 | Retains `synchronized` as a general L2 capability; synchronization restrictions of a particular kernel are not declared a language prohibition. |

These provisions were not imported into the [new semantics](semantics.en.md). At initial extraction it contained only the opening supplied by the author and the transition to grammar; further sections are added at the author's direction.

A separate new author clarification on 2026-09-19 states that an empty vertical body is a present empty Structure argument, equivalent to `()`. `receiver:` followed by a `---` line is valid. This clarification **was not a difference between the two old files**; it is incorporated into the [new grammar](grammar.en.md#empty-colon) and separate current tests.

Source SHA-256:

- lingvamyxa: `d4bb1e70c9d660b185ec084ed4c636ce75bc08dd100786c754401017cade221c`
- L1: `bdb1a6411a47f1cfc9721c1ff002a001cb7fd19cd087ce15fb398f085cc71b53`

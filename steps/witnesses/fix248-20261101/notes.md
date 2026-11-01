# Slice248 — V63's used closure: p's own Value copied by the used copy

Base main/origin `9280f1cd` (slice247). Opus sole writer/build; Codex consults. R=`C:/Nyasha_Planet/LMX`;
P=`R/build2/codex_fix250generationchain01`. Every tool CLI from a fresh private CWD. No source of the language tools,
the kernel or the runtime changed: FE94 (`P/cold-candidate94/fe94/l2trans.exe` `4FF3DB52`, its `l1trans.exe`
`05CCE3A5`) and RT92 (`P/cold-candidate92/rt92/driver.o` `0728B3EB`, `driver-observe.o` `826100A3`) with stage92 are
reused exactly; only the owner fixture differs. Suite tool: generator93 (`P/cold-generator93/tool93-parts/
lmxtool-tool.exe` `DF3B7ED0`).

## What Codex asked for

CODEX-OPUS-V63EDGE-20261031-ANSWER01 (b) ([slice247 records](../fix247-20261101/records/CODEX-OPUS-V63EDGE-20261031-ANSWER01.txt)):
`Value.references` may point to the reference-contract graph N of the receiving instruction; no code-ancestry rule,
no cleared or replaced N. The full-used closure is witnessed through the existing `lmx_graph_copy_many_used_staged`
(used=1, part_roots=0, chain=1; `use_count=0` and null use arrays allowed), "preserving ALL existing V63 checks:
distinct copied roots/cells/candidate/Model/References, one-map relocation, canonical referent/owner inversion, and
post-copy mutation independent of the source". V63's `lmx_graph_copy_owned` asks for the whole lexical chain, which
includes the own `arena` of `try_dynamic_m` (the activation's stack arena); its failure stays that stronger
operation's.

## owner73d: the used-closure block

`P/variants/runtime-callable73d/lib_owner.lm2` (`B3638EEB`; [diff](owner73d.diff) against owner73c `04518DAC`) adds one
block to `try_dynamic_m`, after V64 and before V69. Each check returns 29 with its number:

1. `lmx_walk_value_cell` of p's own cell (`@ p`): present, ref = the runtime graph (`value_graph`), model and
   references nonzero — p's legitimate Value: the Model declaration and N.
2. `from_value` = that ref with p's model and references (`lmx_walk_value_ref_parts`), materialized through `box_cell`.
3. The materialized owner cell and its context (`lmx_pointer_cell_context`, `lmx_value_context_cell_in` inverts it).
4. A typed address cell of the owner cell, loaded (`lmx_walk_value_load`): a present REFERENCE to the owner cell.
5. The address materialized with the owner's context as referent.
6. and 7. A root with V63's five fields: the outer address cell, the owner cell, the runtime graph, p's Model, N.
8. and 9. The whole copy `lmx_graph_copy_owned` into a fresh arena, which is released; its status is kept.
10. and 11. The used copy `lmx_graph_copy_many_used_staged` (one source, no use coordinates) into another fresh arena,
   then `lmx_copy_names_finish`: OK and a new root.
12. The five copied fields are new (not the source's cells, candidate, Model or N), and both copied cells have
   contexts.
13. The copied outer cell is a typed REFERENCE to the copied inner cell; its referent is the inner cell's context,
   which `lmx_value_context_cell_in` maps back to the copied inner cell and which carries the copied Model and N.
14. The copied inner cell holds the copied candidate with the copied Model and N.
15. The correspondence (see below).
16. 45 stored at the copy's y slot and read back; the source's y is read too.

Then it prints `V63 used-closure whole=%d used=%d y=%d source-y=%d refs=1 owner-alias=%d` (`refs=1` is literal; check 1
already required p's references; owner-alias = the outer context's referent is the inner context) and returns 29
unless whole = `LMX_GRAPH_COPY_UNSUPPORTED`, y = 45, source-y = 42 and the destination arena releases.

chain96 (`pins/chain96-detached.command` → `suites96`, 06:17:21Z → 06:28:36Z; launcher EXIT=0, the suite exit 1;
`pins/owner-values73d-hidden55-fe94-rt92-suite-01.log`): all library and main builds pass; in all four runs (native and
forced, root0 and root1) the V63 copy and typed-places lines are as on owner73c, then `V63 used-closure failure=15` →
driver exit 1; `SUITE 1 rows, 4 failures`. Checks 1–14 passed: the used copy returned OK and its fields were checked.
Failure 15 was the fixture's: p's own Model is `Model: int: y` (one field, y at source position 0), while check 15
asked the copied Model's entry for positions 0 and 2 — FlatModel's x and y from V63's admission.

## owner73e: the correspondence of p's own Model

`P/variants/runtime-callable73e/lib_owner.lm2` (`041A51D5`; [diff](owner73e.diff) against owner73d): check 15 asks the
source's entry (`lmx_implements_find(arena, value_graph, p's Model)`) for position 0 → slot 2; the new check 17 asks the
copy's entry (copied candidate, copied Model) for the same; check 16 stores at that slot. Nothing else changed.

chain97 (`pins/chain97-detached.command` → `suites97`, 06:30:55Z → 06:42:10Z; launcher and suite exit 0;
`pins/owner-values73e-hidden55-fe94-rt92-suite-01.log`): `SUITE 1 rows, 0 failures`, `failures.tsv` empty; every
library and main build passes; all four runs give 7 and print, besides the unchanged S81/V59/V64/V69/V73 lines:

```
V63 copy values y=43 source-y=42 x-slot=1 y-slot=2 refs=1 owner-alias=1
V63 typed places absent=0 null=1 plain-null=1 write=1 address=1 missing=1 failed=0
V63 used-closure whole=3 used=0 y=45 source-y=42 refs=1 owner-alias=1
```

whole=3 is `LMX_GRAPH_COPY_UNSUPPORTED` (the final check requires it), used=0 is `LMX_GRAPH_COPY_OK` (check 11). The
suite record (`P/owner-values73e-hidden55-fe94-rt92-suite-01/record.txt`) lists the inputs: the fixture `041A51D5`,
FE94 `4FF3DB52`, RT92 `0728B3EB`; executables native `7DF4EA2F`, forced `FC56E4BF`. The native and forced run logs
are byte-identical per root: root0 `FD8F168B` (`l2_eternal_driver: 13 checks, 0 roots`), root1 `DAC0560D` (17 checks).

## Result

In build2 (not released), on FE94 + RT92 with stage92, Codex's (b) is witnessed: p's legitimate Value — the runtime
graph with its Model and N — is copied by the used copy with the V63 checks that apply to it (distinct copied root,
cells, candidate, Model and N; one-map relocation of the outer → inner → candidate references and of the contexts;
the canonical referent/owner inversion; the correspondence of p's own Model; a post-copy write independent of the
source), while the whole copy keeps refusing. x-slot is not part of the used closure: p's own Model has no x; V63's
copy keeps checking x-slot=1 through its FlatModel admission. The refined copy contract recorded in the ledger:
`lmx_graph_copy_owned` asks for the whole lexical chain and stays UNSUPPORTED where that chain reaches the
activation's stack arena; `lmx_graph_copy_many_used_staged` copies the selected root whole and its lexical parents
only in the places it uses, and does not reach that arena here.

Not closed here: the draft79 line's bootstrap and its landing; the raw index place and the deref-word route; the
unused `pc102_write` prototype (cause inferred, not traced).

## Process

A new Opus session took the handoff over at about 07:15Z (to_opus.md and the named documents re-read); chain97 had
already finished. Codex relayed a connectivity check (no visible request ID); the reply
([ACCEPT2](records/OPUS-CODEX-ACCEPT2-20261101T0720Z.md)) failed at the last hop with `MCP connection closed`; Codex
read it from the relay, rebound the bridge and asked for one post-rebind probe
([LINK-AFTER-REBIND](records/OPUS-CODEX-LINK-AFTER-REBIND-20261101-01.md)), delivered (exit 0). Codex's independent
read-only check of slice247 ([record](records/CODEX-SLICE247-20261101-independent-check.md)): no objection.

## Evidence and checks

[evidence.list](evidence.list) names the originals under P that these notes cite (Codex's answer, the messages, the
fixtures and the suite's other libraries, the chain and suite records with their logs, FE94/RT92 and the suite tool,
each suite's record, failures, generated `p.lm1`, executables and run logs); `P/pins/docs248.command` computed
[evidence.sha256](evidence.sha256) and verified it, and `P/pins/docs248-check.command` ran the full docs check with
the slice in the Git index — both with the promoted working tool `7FD2E824…`. `records/` holds LF copies (trailing
blanks removed). The `.diff` files are `diff -U0` of the fixtures under their P-relative paths.

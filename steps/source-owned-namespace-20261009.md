# Source-owned namespace selection

## Scope and baseline

Codex is the sole writer/build owner, Opus Q&A only. Baseline is `626636ad`:
full12 RED74/2741, kernel12 GREEN297/114 executed selftests, L3_12 eleven
suites/four budgets. This is the namespace-owner child of
[SOURCE-DECLARATION-ORDER](defects.md#source-declaration-order), not closure
of that parent, T7, either critical ticket or §§8/8a. Stable root is unchanged.

Owned implementation: `dev/l2src_sandbox/l2trans.lm1`, eight
`unit_source_scope_*.lm2` fixtures, the namespace-parent witness comment,
and `tools/l2_harness.ps1`. Documentation for this same child is in this
journal, the working instructions, defect ledger, v2 plan/map/dictionary
and porting guide. No runtime name lookup, new graph or per-atom metadata.

## Census and connected mechanism

The read-only census found 53 call-site lines in 47 functions mentioning
the ordinary/payload namespace lookup; seven lines use payload lookup.
These are textual counts, not proof every route is live. The old lookup
matched the first name and source offset, ignoring `l2_ns_parent`: an
earlier nested h prevented a later independent root h. A root-only filter
would break already valid nested model declarations.

`l2_ns_source_site` recovers the existing original P0 node through source
Text identity, already parsed MAIN/part documents and parsed head bodies.
Stored type/free-input words retain their original declaration/callee
source. Compiler-created Text views use the existing explicit current
source environment; this is not a runtime lookup or graph annotation.
The common `l2_ns_source_rank` checks parent-source membership and ordinary
forward visibility, and chooses the closest eligible source owner. Both
`l2_ns_find` and `l2_ns_find_payload` use this one eligibility route, lazily
recovering the source site only after a spelling matches. Existing payload
decoding, method-local own/formal precedence and callable visibility stay
unchanged. The selected declaration supplies its existing physical places.

Nested membership establishes a same-source owner. Root offset comparison
also requires both nodes in the same original MAIN tree. Cross-file byte
offsets never establish relative order. The existing part visibility
boundary is preserved: the author's
[MAIN-to-part question](../LMX_blog/q/program-parts-declaration-visibility.md)
is not silently decided by this repair.

## Private diagnostics, not final acceptance

Private stage02 SHA256 `9BB7B2C183A8245C166334E8A9B41FAC7636AB270946C7A644391285D97FD4AC`
passes sixteen positive executions of four sources in native/walked-method
and native/actually-cleared-root combinations. Existing nested types and
sibling paths stay valid; nested/root empty declarations and the old NODE
namespace-parent pair recover. Known outer callable with a nonempty tail
still refuses its arguments; a nested-only root value read stays unresolved.

Its 2615-command replay has 2613 identical results and only the two
`unit_k03_vis_nested_sibling_refused` diagnostics change: old lookup leaked
the nested model, then failed on v; the corrected route fails on the
unbound free input Inner at the caller. Both still refuse and produce no
L1. The exact located oracle is updated, not weakened to a generic refusal.
No old successful L1 changes or output-presence/exit changes occur.

The final private same-source horizon guard produces SHA256
`D4442DB24BA368537BD13AEF25F40C0788B0852D80FA95C7E3A6C3A4861AB963`.
Stage03 repeats those sixteen successful executions and four more payload
owner executions: plain/quoted descriptor words distinguish Left's Inner
with x from Right's Inner with y. Two backward-root controls refuse.
The 2615 replay results are exactly identical to stage02, including all
1795 successful L1 files and 820 nonzero exits. Maintained source was
promoted byte-identically only after those checks.

The old published translator refuses the payload-owner positive at
`implements`'s candidate; this is another recovered reader, not only
removal of a duplicate diagnostic. A generated-native-only wrong-owner
result mutant gives entry81 instead of7 and is rejected with both native
and actually cleared root. The original generated/source bytes are unchanged.

Diagnostic files, all under ignored `build/codex_handoff/`:
`source_declaration_census_01.md`, `source_scope_probes_03.log`,
`source_scope_extra_06.log`, `source_scope_replay_01`, `_02`,
`source_scope_replay_02_compare.log`, `source_scope_final_private_01.log`,
and `source_scope_wrong_owner_mutant_01`.

## Separate measured debts

Three attempted stronger reference probes do not certify initialized
nested-model references: the typed initializer inside a named Structure
still refuses three arguments; assigning its typed field from a nested
Structure still refuses `internal: admission without receiving model` on
the old binary too. Diagnostic generated-C traces confirm the reference
row's stored model word selects its original Inner; `l2_model_inst` then
reaches the root-only `l2_type_inst` guard. A later root namesake no longer
collides, but fixing selection does not add that missing physical model
instance path. `unit_source_scope_contract_declaration` is registered in
both backends as REQUIRED-positive RED, not an expected refusal. A separate
nested alias probe also remains unsupported by the old named-body binding
producer; do not claim this child implements it.

Mixed primitive/named occurrence order and own-part named construction
remain independent required debts. Do not remove `l2_make_entry`'s guard
alone: the selected kind must also govern value/call/field-tail readers.

## Fresh acceptance

The serial source-scope chain is terminal on fourteen unchanged frozen
inputs. Fresh focus `codex_source_scope_focus_01` is RED26/410: sixteen
added rows, fourteen GREEN/two required receiving-model debts RED, exactly
two old namespace-parent recoveries and no old regression or changed old
failure detail. Fresh `codex_kernel_13` is GREEN297 with 114 executed
selftests; `codex_l3_13` passes all eleven suites and four type budgets.
Full `codex_full_13` is RED74/2757 (2755 fixtures/two build rows), not an
overall GREEN gate. Compared with full12: two FAIL-to-OK, zero OK-to-FAIL,
sixteen additions/fourteen GREEN/two required RED, no removed rows and
no changed old refusal details. The namespace-parent pair is repaired;
other source producers and all parent stages remain OPEN.

Final `source_scope_replay_03`, using full13's binary, exactly matches
the final private replay02 on all 2615 recorded translations: every exit,
diagnostic, output-presence result and all 1795 successful L1 files are
identical; 820 translations refuse. Against the preceding NODE release,
only the two classified negative diagnostics change, not any successful
L1 file. All forty-six staged source copies match the maintained inputs.
The generated-native wrong-owner-result mutant is rejected twice, with
native and actually cleared root. It is not a walked-method mutant.

The source-owner native binary in full13 has SHA256
`59CE6AB01097102FC972F3102711FC22F6119C9F1B5D977E40B4B19F074E1618`;
maintained source Git blob is `5117410c19583c0711197cfc7a848e7db9bed99c`.
These identify the exact freshly gated bytes. The source SHA256 above
remains `D4442DB2...`; stable root has not been promoted.

Acceptance commands (serial, exact logs retained):

```powershell
& build/codex_handoff/tools/run_source_scope_gates_01.ps1
# Focus: tools/l2_harness.ps1 -KeepAll -Translator bin/l1trans.exe
#   -OutDir build/l2_harness/codex_source_scope_focus_01
#   -OnlyFixture <407 recorded namespace/NODE/admission rows>
# Kernel: tools/build_l2src.ps1 -Run -KeepAll
#   -OutDir build/l2src/codex_kernel_13
# L3: python tools/run_l3_selftest.py --output build/l3_selftest/codex_l3_13
# Full: tools/l2_harness.ps1 -KeepAll -Translator bin/l1trans.exe
#   -OutDir build/l2_harness/codex_full_13
python tools/check_docs.py
git diff --check
```

The diagnostic driver records the fourteen full fingerprints before the
first gate and checks them after every phase. It runs the row-set checker,
full12/full13 comparison, forty-six-copy verifier and recorded-command
replay after the public gates. Diagnostic helpers/logs are ignored evidence,
not another language-owned build implementation. Exact evidence:
`build/codex_handoff/source_scope_gates_01.log`,
`source_scope_full13_compare_01.log`, `source_scope_copies_01.log`,
`source_scope_replay_03.log`, the two harness summaries, kernel summary
and L3 log. The driver exits zero after every explicit invariant is checked.

## Next bounded dependency

The read-only census selects NESTED-RECEIVING-MODEL-INSTANCE next: obtain
the actual declaration instance through existing source-field/holder
places and the selected lexical occurrence. Connect ordinary/native
reception, receiving admissions and the walker's model operands, including
reference-path crossings. COUNT counts topology; PLACE/FILL supply physical
edges. Preserve the successful root route and test actual local/copy
holders, shifted/deep places and different same-name owners. No runtime
names, new model graph, pre-PLACE slot guess or arbitrary nesting limit.
The typed-field initializer/alias producer gaps, mixed-kind declarations,
own-part construction and unresolved MAIN/part visibility remain separate.
No next-child source change/build ran during this frozen acceptance.
After publishing this bounded development checkpoint, continue that next
child immediately as the same sole owner; no separate agent/build starts.

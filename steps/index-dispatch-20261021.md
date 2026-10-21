# Indexed dispatch carries the resolved result

The migrated indexed readers and stores now choose their Array or machine
representation from one completed common path record. They no longer drop
the machine result after trying Array and resolve the same source again.
Their spare one-index getter is removed, not moved behind another guard.
Other legacy consumers still exist; this is not all-path or kernel closure.

Base main `3ac746ddce22b0eb96b994277c784e2daffb1197`. Candidate
`build/codex_index_dispatch_143`, final frontend
`build/codex_dispatch143_build_05`. The [compiler U0 patch](witnesses/used-scope-20261020/index-dispatch143-u0.patch)
applies over [Private142](path-index-resolution-20261021.md) with
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
Replay `build/codex_dispatch143_replay_01` reproduces the compiler source.
Application header and runtime C are unchanged; no graph, Value, Place or
uniform ABI layout change, new runtime operation or interpreter opcode.

## Dispatch from one verdict

`l2_index_head_place` and `l2_index_run_place` prepare the original head or
operand, run the common semantic fold, then call `l2_index_place_view`.
The chooser projects the whole selected record into the Array or machine
representation. It retains counts, source coordinates, index ASTs,
pre/post-step types, qualification, model/map context and current leaf.
An operand's owned joined text transfers before the temporary view is
released; a head borrows the existing cached grammar's text. A cached head
does not retain a stale semantic verdict after its current binding changes.

These consumers use that boundary: indexed-write CHECK; native operand
typing and reads; retained operand typing, reads and stores; retained
prefix-address typing/construction; closed typed-native indexed stores.
Array-only callers keep a wrapper over the same entry. The old
`l2_raw_span_location` entry is deleted. The migrated value consumers no
longer invoke `l2_indexed_operand` after the common chooser has answered.
Native opaque C member/callee role dispatch still runs later and is OPEN.

Taking a const cell's qualified address uses the exact address contract
already in its record. It does not grant a write or drop qualification.
Native physical selection, CURRENT-value loading and live owner selection
remain the existing operations. Retention still uses the same completed
place in COUNT and EMIT; no second raw-index object was introduced.

## Actual entry counts and values

The [GCC-instrumented control](witnesses/used-scope-20261020/index-dispatch143-count-test.c)
counts entries to the real common root selector AND step fold. It parses
actual P0 heads and operands at ranks1/2/6/65/129, checks qualifiers and
ownership, exercises retained prefix-address typing, and changes the current
binding to a nonpointer without replacing its cached grammar. SAME200 gives
**old14280 failures / exit1 → final1430 failures / exit0**. Both counters
must be one; skipping the step fold while repeating root lookup would fail.
This is a compiler-consumer control, not ancestor recovery after a runtime
graph mutation and not runtime interpretation of arbitrary C.

The expanded address control caught a real residual in build04: SAME160/2.
A one-index legacy attempt still walked the path before the prefix-address
consumer did. Build05 removes that spare route from the migrated consumers.
Earlier fixture01 had ten extra INVALID assertions comparing the integer
`owned` flag with a pointer. The corrected ownership assertions preserve
that observation separately; it was not a compiler ownership defect.

An independent generated-C diagnostic wrapper preserves the original legacy
getter's result and logs successful legacy representations. On the actual85
sources, normal04 and diagnostic04 complete170 L2-only translations with
byte-identical L1 in every unit and zero legacy-positive units. Final05's
fresh85 L1 outputs are also byte-identical to normal04. This supports removal
of the spare route in this sample; zero trace hits do not prove the remaining
legacy package dead or replace actual execution.

Final sequential session99966 completed. Fresh85-unit worker10068 started at
`2026-10-21T22:45:23.9538752Z`. All named checks are terminal.

| Final check | Actual result |
| --- | --- |
| Common pointer-step record; original type-table poison | 420/0; old141420/300 |
| Common observations on identical real read-probe source | 0 first-index refusals; old1417,13 records, not a complete Consumer |
| Source-linked metadata; unchanged assertions | 336/0 |
| Retained-root spelling poison; equal COUNT/EMIT | 84/0; original old13584/30 |
| Canonical P0 grammar, old140 and final143 | 343/0 EACH |
| Indexed native stores | 82/0 |
| Field/Array read, write and taken-address source | 36/0 EACH native and genuinely forced walker |
| CURRENT read, address/write, rebinding effects | 66/0, 50/0, 24/0 against freshly compiled runtime |
| Exact lost-CURRENT, wrong-owner, delayed-selection controls | SAME66/12,66/4,24/10; exit1 |
| Existing indexed-store controls | SAME82/2 each; exit1 |
| Const index write, const dereference write, qualification drop | Three located CHECK refusals |
| Fresh85 units /170 actual runs | 162 GREEN and SAME8 copy-positive RED |

The matrix preserves every previous status/exit and reverifies341 selected
inputs. Two foreign programs, three published value programs and three
indexed-callee programs also produce their actual13/17 checks in both root
modes. Their raw C bodies remain native when the root is walked; the
field/Array source above genuinely runs through the interpreter. The three
focused generated-C units are byte-identical to final141. The opaque
effectful callee and mixed store positives remain RED, not accepted refusals.

## Exact source and evidence

```text
compiler source FCE8F882A0A713B6B30FCC5D9511507D8C0DE4D9E7524245D51517F884EE6487
application     CF6648189ECA39C4E348A167AB4015C462DDF476C40144DCE5FEEB98AE4FC08A
frontend C      5DB6862946B1D89CA1AA1733506AD39AEDBE59C0D76B5D72B104313EB6052938
frontend EXE    5C93DEA08986B8A8DF8768C527263A494289295C4EC9B4EB9543AB860E4A2098
runtime C       471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh matrix    C72CD47891E940F8A472A72A8AD17BE26976136430B51730704AFFBAD254DBE1
fresh renamed   BD3B422E92A066E12626B7DCCF7E46EF3E2350E2017920E39978793EEFF52C1F
compiler U0     7F57E1D6A2E531B3EC355F2AAEC1B0BD7D47C8ED8ED12EC7BC08A6D9E1B1AFB4
```

Receipt `build/codex_dispatch143_terminal_01.inputs.sha256` contains
**12086 pins**, SHA256
`DD11B9D35BD456A783F373FBC2BB5970D5B7C635F7E2E343AB23C8796F5D7AE3`.
All9247 parent142 inputs were rehashed. All341 actually selected matrix
inputs, including the historic inventory/results, are explicitly rehashed
and pinned through their original133/132 receipt links. Trace01's missing
inventory pin did not establish changed bytes; trace02 uses those provenance
links. The [evidence summary](witnesses/used-scope-20261020/index-dispatch143-evidence.json)
preserves the results and boundaries. `decNumber.h` remains unresolved by
the conservative quoted-include scan; SDK/preprocessor closure is not certified.

Recipes under `build/`: `codex_dispatch143_build_05.ps1`,
`codex_dispatch143_final_verify_01.ps1`, `codex_dispatch143_count_05.ps1`,
`codex_dispatch143_legacy_trace_02.ps1`,
`codex_dispatch143_source_compare_01.ps1`,
`codex_dispatch143_common_05.ps1`, `codex_dispatch143_resolved_05.ps1`,
`codex_dispatch143_terminal_01.ps1`. The resource preflight for the bounded
metadata repeat is192MB rather than a whole-matrix reservation; no oracle
changed. Exact frozen artifacts and completed paired matrix units were
LZX-compressed with before/after SHA equality, without deletion, system or
directory targets, live/pending unit changes or protected-diagnostic access.

## Remaining consumers

The legacy indexed package still serves scalar/node type queries
(`l2_colon_simple_ty`, `l2_native_leaf_ty`, `l2_native_composite_ty`),
Array-binding contract carry (`l2_ab_collect`), pointer resolution
(`l2_indirect_resolve`), numeric/pointer arithmetic (`l2_int_span`,
`l2_ptr_arith_ty`), field/address checks (`l2_check_fields`, `l2_check_addr`),
node preparation (`l2_prep_context`) and C-call actuals (`l2_emit_ccall_ready`).
These need migration to the complete common contract/map result, not a
rank/root shortcut or another member dictionary. Opaque/mixed physical
projection, earlier call roles, capture transport and lifetime also remain open.

Public-dev integration, last full1121011 FAIL/3754, eight copy-positive REDs,
clean kernel, two real L3/L2 self-built generations and mail T01–T26 remain
OPEN. Transitional PowerShell/C verification does not satisfy §8. Codex
remains sole writer/build; goal ACTIVE. Next: eliminate the remaining legacy
queries and derive Array-binding carry from the resolved contract at any depth.

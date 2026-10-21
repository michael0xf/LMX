# Raw indexed retention consumes prepared address records

The retained native-only raw-index operation now consumes the completed
`L2Address` directly. Its separate `L2RawIndex` representation, text/bracket
recognizers and unprepared retention fallbacks are removed. The ordinary
graph/Array resolver and raw-pointer physical fold still need consolidation;
this slice does not establish all-path resolution or kernel closure.

Base main `5e12052ef8a9f8365c75ba1d4140e32e0793f5ac`.
Candidate `build/codex_index_record_141`, final frontend
`build/codex_record141_build_02`. The [two-source U0 patch](witnesses/used-scope-20261020/index-record141-u0.patch)
applies over [Private140](index-value-context-20261021.md) using
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
Replay `build/codex_record141_replay_01` reproduces both source hashes.
Only the compiler and its internal application header change. Runtime C
remains byte-identical; no graph, Value, Place or uniform ABI layout changes.

## Direct consumers of the selected place

`l2_rw_machine_index` accepts the selected `L2Address`, the operation's
original source name and an optional original RHS span. `l2_rw_index_base`
projects that record's already selected root coordinates and original NAME
prefix. It does not search for the root again. Each INDEX consumes its
retained P0 expression span through ordinary expression preparation. Native
read/address, retained read/address and receiving-head store consumers no
longer copy those facts into another raw-index object.

The common path's `indexed` count determines the retained operand width.
The constructor checks its agreement with the completed place's levels and
the path's step count. COUNT and EMIT use the same constructor, root and
spans. The retained operation is the existing native-only source operation,
not a fabricated Array ELEM or new runtime opcode.

The removed package consists of `L2RawIndex`, `l2_raw_index_text`,
`l2_raw_index_group`, `l2_index_piece`, `l2_rw_machine_index_expression` and
the now-unused `l2_rw_machine_word`. Both atom consumers' text-index branches
are gone. The retention constructor has no remaining text/unprepared branch
that can retry a failed prepared selection.

## Canonical P0 index expressions

P0 already produces the original index tree. In
`src/l1src/parser.lm1`, `lm_p0_scan_compact_atom_piece` ends an ordinary
identifier before its bracket; `lm_p0_append_compact_atom_pieces` appends
separate bracket tokens and parses the enclosed fields. A receiving Frame's
compact head is handled once by the existing cached `l2_head_expression`.
The deleted raw-index package was another interpretation of spelling,
not the producer of those valid index expressions.

The [canonical P0 fixture](witnesses/used-scope-20261020/index-record141-p0-test.c)
runs against old140 and final141: **343 checks / 0 failures EACH**. It checks
actual parsed value operands and receiving heads, signed indices, nested
calls, a quoted closing bracket, grouping, mixed fields/reference crossings
and ranks1/2/6/65/129. Every index retains its actual source span; expression
preparation consumes the whole operand; prepared views preserve the counts
and source anchor together; repeated access returns the same cached head.
This is grammar/record evidence, not execution of its unresolved sample calls.

The [retained-root fixture](witnesses/used-scope-20261020/index-record141-consumer-test.c)
keeps all84 original assertions. Its only changes remove the deleted wrapper
and pass the already selected place to the new API. After resolution it
poisons the spelling tables, then verifies formal/activation-slot/machine-local
coordinates, native output and equal COUNT/EMIT cardinality. Final141 passes
84/0; the original fixture against old135 still gives84/30 and exit1.

## Actual execution on final bytes

Sequential session43874 completed; fresh85-unit worker15404 started at
`2026-10-21T21:31:44.8991870Z`. No named GCC worker remains live.

| Final check | Actual result |
| --- | --- |
| Source-linked compiler metadata | 336/0 |
| Indexed native stores | 82/0 |
| Field/Array read, write and taken-address source | 36/0 EACH native and genuinely forced walker |
| Indexed CURRENT read, address/write, rebinding effects | 66/0, 50/0, 24/0 against freshly compiled runtime |
| Exact generated-C lost CURRENT and wrong-owner controls | SAME66/12 and66/4, exit1 |
| Exact generated-C delayed-selection control | SAME24/10, exit1 |
| Existing indexed-write wrong-owner and late-target controls | SAME82/2 each, exit1 |
| Const index write, const dereference write, qualification drop | Three located CHECK refusals, exit1 |
| 85 freshly translated and compiled units | 170 actual runs:162 GREEN and SAME8 copy-positive RED |

The matrix retains every prior actual exit/status observation and reverifies
341 selected parent inputs. Two foreign programs, three published value
programs and three indexed-callee programs also produce their actual13/17
checks in the two root modes. Their raw C bodies remain native, including
when the root is walked. This is distinct from the genuinely interpreted
L3 field/Array source above; it is not an arbitrary-C interpreter claim.

The opaque effectful C-callee bracket program still fails strict C compilation;
the mixed NAME-after-INDEX store still refuses in CHECK. Both original
positive expectations remain RED. The older statement-call role defect is
also still open; this slice does not change callable-role classification.

## Reproducible source and artifact identities

```text
compiler source E6AE536B180FEA7EE9A7B0BFC1587E47E9E07CCD2C9B11D5BE7523BE788E4E20
application    2C0DD610CE851BAB9BF7F6843F8AAF3DB62277A9DD65276C67EDE7C9AAEB1C77
frontend C     C14F1E3384B67DDE9793A907EBA526DFAE207819DB182FA1A45EDAD0F5C093BF
frontend EXE   36860F696057734576A31A068EF959BC907505F3772B15141BFA59F423DF2B0E
runtime C      471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh matrix   638C27CE6A5A24366C98F9A4C110DCA4F8B8394BEB207AF1BD3B6E63E36ED86A
fresh renamed  BB275EECAAE8984D87B3176BE52FF20B7D6755957741C909AB1E643CAB5F6DD9
two-source U0  7F865F845FD03A93BC856B406FF1DA2731D5F934E7FEA3B7C654CF40484F7EB5
```

Receipt `build/codex_record141_terminal_01.inputs.sha256` contains **7025 pins**,
SHA256 `117B8C1409AD0FEA66460918A30882F72AB83D16F1034EDDE4C3A77C5A2FE5A9`.
All4943 parent140 inputs were rehashed. The [evidence summary](witnesses/used-scope-20261020/index-record141-evidence.json)
records the final identities and retained boundaries. The conservative
quoted-include scan still reports `decNumber.h`; full system/preprocessor
closure is not certified. Recipes preserve commands and actual outcomes:
`build_02` → `verify_01` → `terminal_01` under `build/codex_record141_`.
Build01 and its preliminary84/343 results remain separate from final02.

Before this slice,336 explicit frozen140 generated C/object/executable files
were NTFS-compressed. Every before/after SHA matched; free space rose
342372352→578461696 bytes. The operation ledger is preserved. No deletion,
move, directory compression, system target or protected diagnostic access.

## Remaining resolution work

Deleting the second raw-index grammar does not consolidate the ordinary
graph/Array semantic walk with the raw-pointer physical fold. Earlier role
resolution, dereference readers and other consumers still require migration
to the common resolved result with its types and field maps at every step.
Opaque member type/target/callee handling, capture/value transport and lifetime
also remain open. No fixed rank, member dictionary, Model guess or special
permission for a source name was introduced.

Public dev, last full1121011 FAIL/3754, the same eight copy-positive REDs,
clean kernel, two actual L3/L2 self-built generations and mail T01–T26 remain
OPEN. The transitional PowerShell/C tests and handwritten-L1 bootstrap changes
do not meet the language-owned self-build goal. Codex remains sole writer/build;
goal ACTIVE, without a pause, replacement goal, new timer or branch/worktree/PR.
Both documentation generators and check_docs7162 pass; staged and working
diff checks pass. All7025 receipt inputs were independently rehashed unchanged
after documentation generation and staging.

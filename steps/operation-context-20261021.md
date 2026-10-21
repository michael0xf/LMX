# Operation-local giving context — private114 WIP

Base:private113;public dev unchanged. Codex sole writer/build,goal ACTIVE.
This is a common receiving-kernel prerequisite,**not** completion of current
Model transport,typed graph copying,native/walker parity or self-build.

The receiving record is retained/shared ordinary data. Writing a call's
current sourceContext into it would leak activation state under interleaved
calls,recursion and re-entry.114 instead adds
`lmx_implements_admit_receiving_context(arena,value,req,frame,context)`;
its first four record parts use the exact existing decoder/common kernel.
An explicit null context means absence,not recovery from another call's
fifth field. The old four-argument frame adapter forwards its own fifth
field to the SAME worker,retaining its ABI and semantics.

Context is the already-defined ordinary two-cell data `[CURRENT Model,
declared-reference sheet]`. No new Model pool,opcode,graph field or copied
receiving graph. This function validates it and never mutates the shared
record. Names/physical token/first historical admission do not select it.

The same resolver now refuses a present CURRENT namespace when the value
has no proved correspondence to it. It cannot silently fall through to a
different historical namespace. Reuse of a completed proof for the SAME
receiving role remains valid above this resolver;that is not a Model guess.

| Actual input/output | SHA256 |
| --- | --- |
| lmx_implements.lm1 | 8815360B61B8D1550FA14B0C3C9A11163FEAA1572C4769D47D719FF9C9DF1923 |
| lmx_implements.h.lm1 | 12B5C0DF5CC430C4755829C1FCE4AA8D2E7A04DD0D0D6E4CE547F4C389025A41 |
| corrected kernel C,translate02 | 5DA98E883A81B6B640C512E4D835D676367A39CD42439AD9B902A9C758241631 |
| pre-proof API-only kernel C,translate01 | 4B857A3EB4688500BDEEF45CE8FB38574D557830CD8E755CA791B90899BFCD3C |
| driver C,translate01 | 3E87B6103CF60F220912C2C5D90BD104284256F0D8A4E7CF3771D7374B3336B8 |

Actual L1→C and O2/strict kernel/runtime builds completed. **36 new kernel
checks GREEN**,original57+20/789/54/48 GREEN. The SAME36 checks against the
API-only pre-proof kernel finish36/1 FAIL,exit1:an unproved present E is
incorrectly replaced by a historical D admission. No missing symbol/crash.
The actual154 source-value matrix is now **TERMINAL GREEN**,independently
counted32 original +42 Consumer +76 mixed +4 header RUN cells,all exit0.
Both native/root-walk routes run;per-method machine bindings remain recorded
so native-only header/factory doors are not called pure walked bodies.
The36 kernel checks
cover two current namespaces over the same opaque value,reordered ordinal/
LAST read/write/taken-address values,interleaved operations,explicit absence,
malformed metadata,shared-record immutability and missing current proof.
Original154 value/header cells retain their oracles;prepared cells are not
counted as executions. No source-language current-context fix is claimed.

Prepared5057-pin receipt:`build/codex_context114_prepared_01.inputs.sha256`,
SHA`F9CBBF4ED6D5A6EB54606947ADCE5C25746EAFF548DC2B8BF59AD3D280E010AB`.
Queue session57757/PID16816,startUTC`2026-10-21T09:37:06.1345807Z`,waited
for exact113/13032 terminal0,then ran114 kernel/control/runtime/154 values/
copy inventory in order. It is **TERMINAL0**,not a live worker. Copy positives
remain10 observations/6 RED:Model=value4 GREEN,opaque4 runtime RED,index2
L2 RED. Their unchanged7 oracles and failure phases remain recorded.
`build/codex_context114_after_copy113_01.log` is terminal evidence,not a gate
claim for those still-failing programs.

Terminal5935-pin receipt:`build/codex_context114_terminal_01.inputs.sha256`,
SHA`9FE01DB28AE20FED20DEC812C6464F77AC18A7C6A97DD714CF52C446519FB7FB`.
All5057 prepared pins reverified,along with actual kernel/control/runtime
objects,original value/copy outputs and the published patch/fixture.

Published [exact113→114 patch](witnesses/used-scope-20261020/operation-context114.patch),
SHA`4944014D74322B72073448C1A4068EADEDF346DDF6F91B2F3D7E4A0965B808B9`;
[executed36-check fixture](witnesses/used-scope-20261020/operation-context114-test.c),
SHA`4F78BAB79D18402F4FEED4F05B150DB2C445BCC6408A5E26A2DB36E2AF53B6BA`.
`git apply --check` passes against exact113;public dev is unchanged.

Private113's first relocation fixture aborted before its57 checks because
its helper called `refs_open_owned(...,0)` after constructing an already
empty node. Read-only GDB03 identifies `c106_node(n=0)` at main116;production
was not reached there. Numbered fixture02 skips opening absent child storage;
all57 assertions and113 source/C bytes remain unchanged. The same helper
repair is applied in numbered114 fixture03. Original attempts remain.

## Still-open connected implementation

`l2_rw_receiving_record` and `l2_emit_receiving_seed_record` still produce
sourceContext0. `LmxWalkValue`/working rows still carry no current Model.
Neither backend yet passes this operation-local context. Existing110
whole-formal model_input and113 final relocation map are prerequisites,
not substitutes. The same once-evaluated value must carry its CURRENT
Model,declared reference obligations and reached path coordinates through
ordinary/formal/capture/node/return/copy routes. Internal copied Models
use the SAME final relocation map;external retention must be proved.
Do not independently re-evaluate an indexed prefix or fix only one backend.

Documentation generation completed and `python tools/check_docs.py` passes
35 paired semantic chapters,14 implements cases,27 grammar sections,
44 verbatim excerpts,615 imports and LF checks for7012 staged tracked files.
Both incremental source patches pass `git apply --check` at their exact
bases;staged `git diff --check` passes. These are not a full114 L2 gate.

See [final copy map113](final-copy-map-20261021.md),
[full112](template-priority-20261021.md) and
[recoverable evidence storage](completed-evidence-storage-20261021.md).

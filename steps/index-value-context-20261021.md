# Indexed reads and addresses consume the prepared physical place

Base main `e1e1837a074076e9b206c7e99c2e793dd0ed4672`.
Final candidate `build/codex_index_value_140`, frontend
`build/codex_index140_build_04`. The [compiler-only U0 patch](witnesses/used-scope-20261020/index-value140-u0.patch)
applies over [Private139e](ready-member-projection-20261021.md) with
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
Replay `build/codex_index140_replay_01` reconstructs the exact compiler source.
Runtime/application sources and graph, Value, Place and uniform ABI layouts
are unchanged. This is a private dependency slice, **not public-dev integration,
all-path closure, a full kernel gate or self-build**.

## One selected indexed place for split-operand consumers

Removed `l2_raw_index_span`, the manual base/member/bracket recognizer for
split P0 value operands. `l2_raw_span_location` obtains the complete common
run adapter record in the original source method and uses the ordinary
semantic walk first. A real graph/Array path remains on that route. Its
recorded Array contract cannot become unchecked C indexing after refusal.

The existing typed physical pointer fold `l2_raw_index_path` now supplies the
same compiler-only `L2Address` to native reads, address-taking, native/walker
span typing, retained native-only graph construction and path-effect analysis,
as well as the receiving-head/write consumers of Private135/138. The selected
root coordinates and closed contract are reused when the semantic walk already
selected them; a topology-only head view selects its root once. This is not
a claim that the earlier role/type/check passes all share one resolution.

At each INDEX the record retains the original index span and the pointer and
leaf types. Native projection freezes the intermediate pointer, evaluates
the next index once, and captures the physical cell and its actual owner.
`l2_emit_raw_index_value` loads that selected cell through the existing typed
indirect-value operation. Its CURRENT Model/reference sheet comes from that
cell, not from the root, a nonselected neighbor or the candidate's stored view.
There is no return-only context repair and no raw-text fallback after a
successful typed place selection.

Fresh span records own joined name text, whereas cached head views borrow it.
The fresh view and address projection explicitly transfer that text ownership
before releasing the old step array; original index nodes still belong to P0.
The retained graph consumer borrows the same steps/types/root through its
compatibility view. COUNT and EMIT use that same prepared branch, not the
removed split-operand parser.

`l2_capture_place_address` keeps the exact previous pointer contract rather
than reconstructing an unqualified address from the loaded scalar. Address
projection returns the actual selected cell and its live owner, not a loaded
temporary. A qualified C pointee's write prohibition is not a prohibition on
obtaining its qualified address. Graph-eternal address checks remain intact;
no consumer-specific kind exception was left in `l2_check_addr`. Direct const
index writes, const dereference writes and qualification-dropping returns
still refuse in CHECK.

## Actual values, addresses and effects

The [read source](witnesses/used-scope-20261020/index-value140-read-probe.lm2)
and [66-assertion fixture](witnesses/used-scope-20261020/index-value140-read-test.c)
exercise pooled nonzero indices, explicit live owner storage, two-level typed
pointers, a real C pointer-object chain of depth seven and signed scalar
indices. Pointer states carry the SAME raw candidate but different CURRENT
Models. Assertions check exact payload/context, unchanged incoming records,
untouched index0, independent selected loads and actual 7/9 values after
admission through a permuted receiving map.

On the SAME correct fixture, old139e gives **66 checks / 12 failures / exit1**;
final140 gives **66 / 0 / exit0**. The uniform ABI transports raw payload and
context separately. The caller fixture combines them with the existing common
marshaller, without inventing a Model/sheet. It does not treat a context-only
ABI result as a full Value.

The [address/write source](witnesses/used-scope-20261020/index-value140-address-probe.lm2)
and [50-assertion fixture](witnesses/used-scope-20261020/index-value140-address-test.c)
also take the selected address, write through it using the common store, load
the persistent cell independently, then run a source method that takes a
working address, writes through it and reads the indexed result. Both giving
Models and pooled/explicit-owner storage are exercised. Const reads/addresses
at signed indices produce the actual 11/33 values under strict qualifier checks.
Final **50 / 0 / exit0**; the address points to the real cell, not a stack Value.

The [effect source](witnesses/used-scope-20261020/index-value140-effect-probe.lm2),
[24-assertion fixture](witnesses/used-scope-20261020/index-value140-effect-test.c)
and [test-only C effects](witnesses/used-scope-20261020/index140_effects.h)
force index1 to select backing B and index2 to replace the earlier pointer
with C. Both read and address methods retain the selected B cell/context,
run the two effects exactly once in order12, observe actual 7/9 through the
receiving map and use the taken address for a persistent write. Final **24 / 0**.

All three focused final tests were rerun against a freshly compiled renamed
runtime object, not merely the older verified object used during exploration.
These raw L2 machine bodies **actually execute native**. L2 does not promise
an interpreter for arbitrary C pointer operations; those results are not
reported as forced-L3-walker execution.

### Controls and rejected preparations

Exact final generated-C controls preserve the same positive assertions:

| Mutation | Actual checks | Failures | Exit |
| --- | ---: | ---: | ---: |
| Discard CURRENT at the nine selected pointer-load sites | 66 | 12 | 1 |
| Use index0's owner in the simple indexed reader | 66 | 4 | 1 |
| Delay the selected intermediate until after index2 rebinding, read and address | 24 | 10 | 1 |
| Existing indexed-write wrong owner | 82 | 2 | 1 |
| Existing indexed-write late target | 82 | 2 | 1 |

The three [const CHECK](witnesses/used-scope-20261020/index-value140-const-write.lm2)
[refusals](witnesses/used-scope-20261020/index-value140-const-deref-write.lm2),
including [qualification drop](witnesses/used-scope-20261020/index-value140-const-drop.lm2),
are actual located exit1 refusals, not compile/link failures.

Exploratory failures are retained and not inflated into compiler findings:

- Initial read fixture01 treated context-only output as a full Value. Its old
  66/24 result is not 24 compiler defects. Correct fixture02 is the SAME66
  comparison used above: old12/new0.
- Address fixture01 obtained an absent third argument's storage before making
  it present; this caused INVALID before complete assertions. Fixture02 updates
  that ABI storage after construction. This is a test setup repair.
- Fixture02 then expected a second admission to the same already admitted R
  to replace its map when the giving Model changed: 50/4. That expectation
  contradicts [preservation of established correspondence](../docs/LMX_semantics.en.md#correspondence-stability).
  Final fixture03 uses separate fresh R/S receiving roles for the two actual
  value observations; it does not demand an implicit remap. The original
  fixture02, its 50/4 result and the stable-map implementation are preserved.
- The first attempt at a const local initializer refused its construction
  before the write; it is not counted as a successful const-write check. The
  final indirect test writes through the valid const formal instead.
- Build01 failed L1 translation after a misplaced prototype edit. Build02
  compiled but overbroad contract-level classification rejected typed pointer
  steps. Final classification distinguishes the real Array contract, not a
  depth/name special case. Address01 then exposed the const/eternal check
  conflation; final04 projects the address contract centrally. These are
  stopped preparations, not passing runtime tests.

## Broad regression evidence on final bytes

Terminal session37386, worker12496 startUTC `2026-10-21T21:15:08.8249691Z`:

- Retained root consumers84/0; old135 SAME84/30. Source-linked metadata336/0.
- Indexed native stores82/0; existing field/Array/read/write/taken-address
  source36/0 EACH native and genuinely forced walker.
- 85 freshly translated/compiled units, 170 actual runs: **162 GREEN + the
  SAME8 copy-positive RED**, all prior actual exit/status observations unchanged;
  341 selected parent inputs reverified. Runtime freshly compiled.
- Four foreign root runs13/17 each; three published value programs13/17 each;
  three indexed-callee programs13/17 each. Their C bodies remain native even
  with a walked root.
- The positive effectful opaque-C-callee bracket case still fails strict C
  compilation; the mixed NAME-after-INDEX store still refuses in CHECK. The
  original positive expectations remain RED, not accepted rejection tests.

Session34844 completed fresh runtime +66/50/24 and both read controls. The
separate delayed-selection control and terminal receipt61792 also completed.
No named GCC/semantic worker remains live. No overlapping GCC pipeline ran.

```text
compiler source 096DAA946ECD3F5ACB1EA87D5905167AA1E2D8A917128E37FF942DCF42532810
frontend C     636D61763C82FD2579E8290D67917D4B29BC3CFE7149F5824216B6504D115808
frontend EXE   F092D3284E5E686F7BBB6891B6A624D6268037C167EBF0DCB3EFD16CEDD094CB
runtime C      471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh matrix   C6E64584D5ADC3D90440B348EF0B1AD506115E118AC9C1E3EF315030F419973F
fresh renamed  D42305BD6670441C854DB09A38A1068BAF63CF32E472043A2EC854127670BDDD
one-source U0  BD812CB0E3B7BCE7A5D26C351AEF4E6B06C18C63F2209A5B99832D07378DA099
```

Receipt `build/codex_index140_terminal_01.inputs.sha256`: **4943 pins**,
SHA256 `4B475743DFBC95D503C1EC04A7038EEDA6D1317F0E84D9E096049F52C55F3593`.
All2751 parent139 pins were rehashed. The [evidence summary](witnesses/used-scope-20261020/index-value140-evidence.json)
records final source/tool/artifact identities and boundaries. The conservative
quoted-include scan still reports `decNumber.h`; system/preprocessor closure
is not certified. Scripts preserve exact arguments and actual phase results:
`build_04` → `verify_01` → `more_01` → `effect_control_01` → `terminal_01`.
Intermediate files and the hash-preserving compression ledger for703 explicitly
pinned frozen artifacts are retained; no deletion, move or system target.

## Remaining dependency work

The ordinary graph/Array semantic walk and raw-pointer physical fold are still
separate resolution representations. The text-only atom reader
`l2_raw_index_text`/`l2_raw_index_group`, dereference readers, earlier role
resolution and other legacy consumers remain to migrate. The raw physical
fold's old opaque mixed-shape guard remains; this slice does not add a new
depth cap or make that refusal normative. Keeping full per-step contracts/maps,
opaque C target/callee freezing, capture/value transport and lifetime across
ALL consumers remains open. No opcode, Model registry, graph field, fixed
pointer rank or ad-hoc member dictionary was added here.

Public dev, last full1121011 FAIL/3754, the same eight copy-positive REDs, clean
kernel, two real L3/L2 self-built generations and mail T01–T26 remain OPEN.
These transitional PowerShell/C tests and handwritten-L1 bootstrap changes
do not satisfy the language-owned self-build goal. Codex remains sole
writer/build and goal ACTIVE; no new timer, branch/worktree/PR or pause.
Both documentation generators pass; check_docs verifies7157 staged files and
all links. Staged/working diff checks pass. All4943 receipt inputs were
independently rehashed unchanged after documentation generation and staging.

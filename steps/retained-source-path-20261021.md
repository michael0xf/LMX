# Retained current source route — private99

This is a compiler foundation, not a sourceContext fix or a completed uniform
path audit. The public dev tree remains at 0b8c6ded. Codex is the sole
writer/build; the existing goal and hourly lmx-goal are ACTIVE.

## Change and lifetime

The patch [retained-source-path99.patch](witnesses/used-scope-20261020/retained-source-path99.patch)
applies to the exact private98 l2trans.lm1 and l2_application.h.lm1, not directly
to the public dev tree. L2ReferenceSource borrows the existing L2PathFact from
the current resolution. The fact already owns its text and steps in the
translation's bound allocations. Releasing a temporary L2Path therefore does
not leave a dangling namespace route. No second source graph, runtime name
table, permission, physical layout, fn field or opcode is introduced.

The scalar source projection is unchanged. Changing its schema explicitly
invalidates its old borrowed route. The original mi remains current until
projection has found the exact grammar/source/environment fact. A fact is
mutable current state: its pending stage is not replaced by a secretly retained
older successful verdict. Metadata-only synthetic paths may have no fact;
this is not a claim that every real source namespace is already covered.

Source-plan convergence includes the root, formal/header origin, step counts,
types, declaring namespaces, receiving maps, reference contracts and index
origins of the retained path. TypeContract allocation addresses are not
semantic state: equivalent contracts at different allocations serialize alike.

## Executed checks

`build/codex_catalog99_build_02.ps1` terminated0, session34059 closed:
194 distinct prior compiler assertions, the original13 source-projection
checks and the new17 checks in
[retained_source_path99_test.c](witnesses/used-scope-20261020/retained_source_path99_test.c)
are GREEN. The new checks prepare metadata, including129 mixed steps; they
are **not**129-step source execution or a native/walker value proof.

Build01 is preserved as a failed attempt. Its new L1 call argument lacked
parentheses around a nested record field and generated invalid C. The L1
source, not generated C, was corrected before the separate build02.

`build/codex_catalog99_values_all_01.ps1` terminated0, session52088 closed.
Compiler99 regenerated and executed all previous150 source/root value cells
(32 values,42 Consumer,76 mixed), plus the previous4 header/result cells,
with unchanged runtime95 and unchanged source/helper/oracles. These include
deep mixed reference/index reads, writes, address use and unchanged neighbors.
Original machine-only multiclass rows are not relabeled as pure walker.
The header/result forced-method cells retain only the two original C doors.

Patch application independently reproduced both frozen tested99 files:

| File | Exact98 SHA256 | Tested99 SHA256 |
| --- | --- | --- |
| l2trans.lm1 | C4C00DF3138D8A2E5C875DD0654E90AF9977FB266D7AACCAC0B37AAFC3248376 | FAC6F5EC20E9BDC09D1DDFBE6680CF34B334D328BE5A012CE3BB5972632B8399 |
| l2_application.h.lm1 | 67E513D68E4088B5E06744C927C044E54DFE01D6558CEC17E2273ABA8F585C4D | 39ABA659B86B94D63F26111B9B2D19D5D3A8BDBCE29870C0BBA2A35C49000B59 |

`build/codex_retained_source99_publish_01.ps1` validated154 actual value
cells, rechecked all previous1088 pins unchanged, and pinned883 explicitly
bounded terminal artifacts. The receipt is
`build/codex_retained_source99_terminal_01.inputs.sha256`, SHA256
`9F30CE73117F67FDBE7351B496247D4A375CED6F6F3D7DE1AF3DA79E0900CA41`.
It does not hash the incomplete full98 subtree or claim a complete L2 gate.

## Index source: measured next dependency

`build/codex_source98_index_trace_02.ps1` and03 terminate0 on the original
giving-index source and actual compiler98. Its items[pick()] operand has P0
count4. Before projection there is exactly one source-use fact for that
original occurrence, with one INDEX step, indexed1, stage0 and own4. Yet the
old source core returns schema/layout/method/place all-1. The names-only
resolve_whole rejects indexed paths. The separate n>=3 guard is not itself a
proved cause; P0 has already split this source into four fields.

Trace01 failed because the debugger cannot evaluate the macro
LM_P0_NODE_ATOM as a DWARF enum. Attempts02/03 use macro3 from the exact
generated p0 header. No application/runtime value was changed by these
diagnostics. They are not a passing giving-index test.

The next source producer must consume that existing grammar with the common
semantic fold and its current bound root, not parse the original span again,
retry a text fallback or evaluate an effectful index twice. Root-only facts
remain distinct from field paths. Neither receiving-record producer emits a
nonzero sourceContext yet. Giving32 was last run on98 and remains RED there;
no new99 giving/covariance result is asserted.

## Full98 host interruption and disk recovery

Full98 session81593/worker13904 terminated1 when C: AvailableFreeSpace reached0.
The exact failure is Out-File at harness1128 while appending
fixture.unit_k03_ref_root_chain.l2trans.log. There is no terminal summary and
no complete3752-target verdict. All partial outputs and original oracles are
preserved; `build/codex_catalog98_full_interrupted_01.json` records the host
failure. Full97's1011 FAIL/3752 remains the last complete comparable result.

Recovery uses reversible LZX compression of only the completed exe files in
known full97/95/63 bin directories, without deleting source/evidence or
changing their bytes. Only the duplicate stage99 generated l2trans.c was
removed after checking it against the preserved frozen03 output; build02
regenerated it. The forbidden err file was not read or touched. New builds
check free capacity; an old interrupted full-run stamp is never silently
reused or reported as complete.

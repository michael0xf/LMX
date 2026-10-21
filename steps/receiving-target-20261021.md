# Prepared receiving target — private118 WIP

Base:117 frozen source,recorded in [value producer](value-producer-20261021.md);
published checkpoint `f39c365e`. Only private
`build/codex_target_source_118/src/l2src/l2trans.lm1` changes. No runtime/header
change. Plan K01/K05/K12:receiving flow must consume the same resolved path
that selected its target,not parse that target again from text.

`l2_check_path_write` keeps its resolved `L2Path` alive through reception.
`l2_check_array_place` passes its same prepared/resolved path. Both enter
`l2_check_receiving_value_at`;transparent value groups retain that target.
The common `l2_check_reference_receiving_at` projects the target leaf through
`l2_reference_path_projection`. It propagates allocation/index failure and
records an existing bound port only when that port exists. No target name
lookup or parser is used there. Ordinary no-path wrappers use the same
workers with a null target,not the deleted old route.

Removed `l2_reference_path_source` (the text reparse) and unused
`l2_reference_path_leaf`. The existing common projection facade remains for
its actual metadata tests. This does NOT claim every other CHECK/native/
walker consumer is unified;other text adapters and repeated semantic folds
still require audit. Nor does this carry runtime CURRENT Model through copy.

Attempt01 sourceAB688BB9...,C642BED3E... built the frontend and passed288
checks,but the old status fixture could not compile after a private API
arity change. This is a test/API build failure,not a language refusal. The
source snapshot is `build/codex_target118_before_apiwrap_01/l2trans.lm1`.
Attempt02 keeps the old ordinary6-argument wrapper,which calls the same
worker with no path. Final source
`647B41755227BC468BB434CEBC8255D997D097D88B51183D4DA99FB094369E85`,
generated C`547C5CDA8BDA55646ADA8272CDECC956C51630D77F582140FEB5E6EDB2860A4D`.
Actual compiler/336 metadata assertions GREEN;old10932-check control8 FAIL
remains expected and separately recorded.

New receiving-target fixture:10 assertions GREEN,including a synthetic
129-step/counter inventory with no target text,source-to-field and source-to-formal ports,
same-occurrence Consumer roles,geometry preservation,deduplication,refused
and Array views,and flow-key overflow. Unchanged117 runs the same oracles
with its old-API call adapter:4 failed assertions,exit1,not a crash. This is
metadata evidence,not a parsed129-step program or a runtime behavior claim.

Actual value recipe:`build/codex_target118_values_01.ps1`. New source
[reference-target-prepared-values.lm2](witnesses/used-scope-20261020/reference-target-prepared-values.lm2)
keeps oracle7,one effectful target index,reordered Box/E layouts,actual
reference assignment,field write,taken-address write and shared alias
observations. Original154 and existing copy oracles are unchanged.

The actual value inventory is TERMINAL0:PID12516,startUTC
2026-10-21T10:26:54.1565070Z,session26010. New4 target translation/root cells
GREEN,with actual result7 and Counter1,field values41/43,taken-address write,
and shared Wide values/untouched extras checked. Native graph has8 method
bindings;forced-method graph has1 (`l2_m7_tr`,launcher only),so both check
and pick execute walked in that mode. Original154 source/root/header value
cells are GREEN. Existing copy inventory remains12 RUN observations/8 RED:
opaque4/index-once4 fail;Model=value4 passes. No copy oracle was weakened.
No full118 L2 gate was run. New copy-indexed declared/mixed positives from117
were not rerun on118;their last actual RED results remain117's.

Published exact executed [metadata fixture](witnesses/used-scope-20261020/receiving-target118-test.c),
SHA256 `CE233D649BC4E39D31D9B44B57AD48F6AF8B59DFF56A2CE6497E8B978668889C`.
The control macro adapts only the old117 checker call's API;all10 assertion
oracles are unchanged. New language source SHA256
`3662370ACD33FF8058C9309E512144CDC112E988DB4F95F7A07942F838AD5156`.
[Compiler delta117→118](witnesses/used-scope-20261020/receiving-target118-u0.patch)
SHA256 `4A2E9F75D9224020489529CDF785C19F5ECD5682614273089E93F1FE0DDC28B3`;
`git apply --unidiff-zero --check` passes on exact117.

Terminal9153 pins:`build/codex_target118_terminal_01.inputs.sha256`,SHA256
`0372CA517E08CE0854F2DBEDE6B9845442991451967E991E220F0B5F1A1DE16E`.
All7846 upstream117 terminal pins checked;all source/header bytes other than
the compiler independently match117. Runtime114 is reused without rebuilding.
Every118 compile/value worker above is terminal;do not wait on a reused PID.

Next connected dependency:CURRENT giving Model/reference sheet must accompany
the same evaluated value through producers,working/argument/result transport
and the final copy map. The already available path-cursor Model must not be
discarded and then recovered by reevaluating a prefix. Do not guess it from
a physical layout token/first admission,add per-Model pools,or put a native
guard around the copy's wrong field read. This slice changes no pointer ABI
and does not establish that dependency's implementation.

Public dev unchanged;full kernel/self-build/§§8/8a OPEN. Goal ACTIVE.

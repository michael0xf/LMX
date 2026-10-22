# Prepared INDEX grammar in source analysis — private158

Implementation checkpoint,not a new language rule. Base main
f56fa7b4cc1aa76c34d2ad391fea574671e4860a;working snapshot
`build2/codex_analysis_children158`. The281-file source/header closure was
copied and verified from frozen157. Only the compiler changes;both application
headers and280 other inputs remain identical. The old build directory being
deleted externally is untouched.

## Shared grammar,different analysis roles

Free-name/capture traversal of an INDEX now borrows its owned ordinary value
spans. Nested paths,groups,signs,address operands and dereferences are visited
without reconstructing their field lists. A path root is not an additional
whole-value read. A bare value retains the ordinary whole-binding observation;
an address marks existing storage without reading its stored value. Flat and
Frame address spellings share that lexical role. A raw address-node entry
constructs one ordinary list and delegates to the same visitor;it is not a
second parser behind a retained result or refusal.

Effects also borrow the operand grammar,but intentionally take a fresh
semantic view for the current analysis environment. This differs from backend
projection,which must use its already closed types/maps. A currently refused
binding must not recover a successful ancestor verdict;conversely,an effects
query must not overwrite the closed operand used by CHECK/native/retained
projection. The common path walk still selects the root and every step.

The raw primary/control-body effects visitor is shared rather than copied.
It preserves scopes,for-body hosts,independent call bodies and trailers. An
already owned group or prefix does not re-enter that raw boundary. Sign and
address syntax already identified by preparation is not reparsed as a path
head. These are compiler visitors,not runtime opcodes or binding tables.

## Evidence status

Final frontend01 source SHA256:
`DEE511AB69257D679D3E0507F0A7229E29F91B28826B49FCF6DA71DFA4FF9643`;
C:`16C1EEAE582773F8F4DE8671547940AC3C7D02866A28679D2E0DCF0BE492A66C`;
executable:`D967D8FD2AFF6838C316EA3B8C8BBA22CF1DC0DAC71665AFF5586E0375145EB0`.
Strict compilation and82 analysis checks passed.
Depths1/4/16 exercise lexical/effect traversal with0 adapter calls. After
name+FT poison,effects see a current refusal while the held native result
stays intact. All17 compatibility profiles pass;root124,native134,CHECK159,
owned2026,INDEX61 and child281 pass. All85 current L1 outputs are byte-identical
157. Additional held group/sign/address/separated-dereference cases actually
pass with0 adapters and balanced scopes/compilation owners.

The draft `\(...)` source was not a separated prefix:observed P0 is a compact
Frame,node kind2,head backslash,flags2,with no prepared body. The deliberately
positive no-reparse witness remains RED:82checks/2failures,lexical3/effect2
adapter calls. Its [unaltered source](witnesses/used-scope-20261020/analysis158-primary-open-test.c)
and [actual result](witnesses/used-scope-20261020/analysis158-primary-open-results.json)
are preserved as the still-open generic-primary/body boundary. This is not a
new language refusal oracle or evidence that an unknown head is a valid
dereference operation. The accepted unary test uses the separated prefix
`\ (@: q[0])`;no compiler syntax guard was added to exclude the other tree.

All85 units were freshly O2/strict-aliasing compiled and actually run170times:
162GREEN and the same8 copy-family RED rows,same native eligibility. Deep
mixed/permuted/hidden/address auxiliary witnesses add16 units44 executions:
32 positives with actual native/forced-body/value assertions and12 unchanged
runtime write-drop refusals;2 legitimate Array CHECK refusals remain.
Constants add8old/new units32runs;method-address rebinding4units16runs.
The nested physical-pointer source adds4units16runs,including the actual
31→37 via taken address→41 via indexed alias sequence. That C-pointer method
remains native-only even in forced mode;genuine interpreted-body coverage
comes from the separate graph-path witnesses,not from this source.

Selected final phases contain117 fresh C units/278 actual executions,
including8old152comparison units/32old executions.12 located diagnostic
oracles remain unchanged across24 translator observations;7 additional
source classifications remain identical,without promoting old refusals.

[Receipt](witnesses/used-scope-20261020/analysis158-evidence.json),
[source patch](witnesses/used-scope-20261020/analysis158-u0.patch),
[281 input pins](witnesses/used-scope-20261020/analysis158-inputs.json),
[exact results](witnesses/used-scope-20261020/analysis158-results.json) and
[82-check fixture](witnesses/used-scope-20261020/analysis158-test.c) pin the
actual bytes. One source-file patch replays exactly over157;the unchanged
application source header regenerates the exact consumed C header. Final
phases:frontend01,fixtures05,profiles/routes/root/native/check/negatives/extra/
values/aux/constants/method/machine01,receipt02.16 recipes refuse overwriting
old attempts;new replay destinations need fresh labels. Deleted historical
binaries are not claimed rehashed or replayed.

## Remaining boundary

Array INDEX receiving/conversion helpers still take raw fields. Independent
call/receiving/conversion plans and their operands are not made owned merely
by surrounding a raw helper with a new function. The conversion receiver must
be captured before argument effects,not selected after evaluating a converted
value. Own-storage/descriptor/leaf producers,pointer-type spelling and other
indirect/callable/text entry points also remain open.

This is a verified private slice with the explicit open Frame/body witness,
not public-dev integration,full path/kernel,Model/Shelf/K03,self-build or mail
completion. Goal remains active.

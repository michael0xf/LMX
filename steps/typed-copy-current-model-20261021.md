# Typed copy: current Model and physical coordinates — OPEN

Codex remains the sole writer/build; goal ACTIVE. Public dev is unchanged.
These are measurements on compiler103/runtime95, not a105 implementation
or proof that the common paths are globally closed. The language contract
remains [composition](../docs/LMX_semantics.ru.md#composition):one graph copy
and one relocation map, not a name/Model guess or a backend-specific repair.

## Two measured losses, not one native guard

`build/codex_copy104_carry_trace_03.ps1` observes the unchanged original
`codex_giving96_copy_01.lm2` executable. The held value has two physical
integer cells,7/9, and two real receiving maps to D/E. Both maps have width4
because those Model graphs also contain initializer operations. Both entries
have proof2 and layout0:neither requirement is a physical-layout witness.

The common carry sees part_roots0/absorbed0, returns success, and leaves the
copied root with no receiving entries. The common merge finalizer then adds
a self entry with a fresh synthetic layout token. The original program still
exits3. This is not a supplied sourceContext or a successful copy test.
The first two debugger attempts are retained with their inspection errors;
only03 completed the carry/finalizer observation and executable-byte check.

`build/codex_copy105_source_trace_02.ps1` observes the actual103 compiler,
without changing its data. Its single-copy record already knows schema1(E),
layout-1, the giving binding's method/place, and two logical data fields.
The subsequent whole-copy source query instead returns merge schema-2.
These are schema handles, not unknown/error codes. Do not confuse the two
logical fields with four physical children in the Model graph.

The same trace records29 completed copy-field resolutions across analysis
and construction. Even in the final construction phase2,copy\v has root
Model-1/result0,locus2,row2,nsrow3,view_model-1. It is still an unmapped
constructed-result route. Thus this is not merely an early query whose
temporary slot becomes correct during final layout. The runtime value has
two physical cells; the compiler must preserve the relation to the giving
Model rather than declare its synthetic coordinates to be physical.

These observations narrow the next implementation boundary:the common
typed result must keep its logical Model distinct from physical constructor
evidence, and the copier must transport the relevant correspondences through
its same relocation map. A hardcoded E,unconditional identity/fresh token,
first arbitrary existing admission,or native-only bounds guard is not that
transport. Nor is blindly retaining all absorbed-root maps:composition can
change their target slots. No new encoding or runtime metadata API is claimed
implemented by this note.

## New independent positive witnesses

The original giving/copy witnesses and their7 oracles remain unchanged.
These additional sources isolate dependencies hidden behind their earlier
receiving failure:

- [opaque current Model](witnesses/used-scope-20261020/typed-copy-opaque-current-model.lm2):copy an opaque value with two valid giving views but no physical-layout token;observe9,write41,take an address and write43,keep neighbor7 and the original value unchanged.
- [Model/value alias](witnesses/used-scope-20261020/typed-copy-model-value-alias.lm2):the giving Model is also the held value;copy independence and the value/address operations must still work. This guards against fixing only the opaque external case.
- [indexed source](witnesses/used-scope-20261020/typed-copy-index-once.lm2):copy an array element admitted to E;the effectful index runs once and the source stays unchanged. Its expected result is positive7,not an approved refusal or a depth/shape restriction.

The foreign helper is the existing
[explicit D/E fixture](witnesses/used-scope-20261020/include/l2src/tests/opaque_declared_views_test.h),
unchanged and byte-identical to the private runtime input;SHA256
BF749DB5F70BFA85FBF189B8CD9864A70D3EEEF80CBE86CFCE7E12D7E180706D.
Its sibling positions are a fixture's foreign ABI,not a language lookup rule.

`build/codex_copy105_translate_01.ps1` completed six actual103 L2 translations:
opaque and Model/value alias produce graphs in both modes;indexed source
refuses at values with “this merge operand form is not lowered yet”. All
three runtime7 oracles remain uncompiled/unexecuted at this checkpoint.
Successful translation is not a runtime value or pure-walker proof.

`build/codex_copy105_values_01.ps1` is prepared to measure the three sources
on actual104/runtime95 after the existing sole103/104 queue is terminal.
It preserves every phase/exit/binding count and does not turn a positive
failure into an expected rejection. It has not been started;do not overlap
the live full103 or its queued continuation.

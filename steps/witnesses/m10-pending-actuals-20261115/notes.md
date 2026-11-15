# M10 step405: pending actual lifetime

Baseline cb6d9305 follows the author's c7f2825f. All six call/fncall forms,
unified data declarations and private remain the required target; this bounded
change does not claim their execution is complete or restore formal args.

## Change

GraphRun retains its existing temporary actual arrays before later actuals,
whole-argument admission, missing defaults and invocation. Selected code,
data and scope use graph roots. A WalkPlace argument is not a second graph
root; the old incorrect uses in invocation/launch are corrected as well.

GraphTool initializes the pending array before argument effects and retains
the selected callee/result. Its existing temporary-label mechanism funnels
every later failure through root cleanup before the prior error/finally exit.
Normal and whole-argument calls use the same checkpoint cleanup.

No new runtime table, record layout, dispatcher or generated C/L1 edit.
Graph83/Run67/Walk189 and the actual G2 frontend remain unchanged.

## Inputs and producers

Logs/manifests: build2/codex_fix250generationchain01/runs/sol-m10-pending-actuals-20261115-01.
The previous stage sol-m14-field-values-01 is reused with fresh labels.

Source05 has935 inputs, SHA
`bb425f56e33519ff11f3a79c62cd9004c3efae1708c6c48ebd00117c66005ddd`.
Source02 fixed the reviewed root-slot misuse before code acceptance. Sources03–05
only correct/isolate the fixture; Runtime-call-02 and Graph-call-01 code is unchanged.

Runtime-call-02 normal PASS,98 headers:

- C `3755b25aee1d96690c02a6c57f0d44f637480c51337d42484da13c9a6e806973`.
- production `23e305dfb7ab103f512867a12160558d5c6944f583ec2b16fe50cd3a8a3c59fd`.
- observed `55a2193db9e44b70e3f654378d19c620b7c61908f48b05dbff643155a50af15a`.

Graph-call-01 normal PASS:
`25906835152c47f0d6709d93b86184249016154bbecf53626415e9f9df63e1cd`.

## Verification

Focused05 graph_scalar_working PASS1/0, native/forced and root0/root1. Parsed
GraphRun evaluates `Pending(@number; Collect())` twice. The second actual's
native callback sweeps while the first admitted reference is still pending.
Answer80 and counter2 prove the value and one effect per call. The formal's
first reference chunk is filled before the call, so only the pending span can
retain the new chunk; a later sweep reclaims that transient chunk.
Existing execution_gc_roots also passes on Runtime02.

The assertion owner's native/forced modes do not mean the parsed GraphRun
caller is emitted GraphTool code. Graph named/finally/whole_empty independently
pass interpreter/native/forced and cover emitted syntax and cleanup; real GC
inside an emitted GraphTool argument is not claimed by this receipt.

Earlier attempts are retained: focused01 passed a runtime directory instead
of an object (LD); focused02 misused int_ref_of for a plain scalar (126);
focused03 exposed the unisolated formal/pending chunk (128); focused04 lacked
one L2 tail cutter. Focused05 corrects those fixture issues without weakening
the pending lifetime or reclaim assertions. Runtime01 was superseded by review.

The isolated negative control removes only eval_call's pending-actual span;
the one-line source diff is confirmed. Its normal runtime build passes, then
all four native/forced/root runs fail with status122, assertion exit126 and
counter0. The live first actual was reclaimed during the second actual's sweep.
Positive expected7 and all assertions are unchanged. The normal stage and its
compiled runtime are not mutated for this control.

Source05 is canonical; repo and stage verification both pass935/0. Final indexed
docs-index01 passes35/14/27/44/615, links/opening and LF28304; exit0. Semantic and
grammar sources are unchanged since c7's normal rendering. Working/indexed diff
checks pass. All producers are terminal. The explicit ten-file index excludes
the two unrelated untracked files, whose original hashes are unchanged.

Unified DATA binder, full-Value
actual transport, private and full M13/M14 remain OPEN.

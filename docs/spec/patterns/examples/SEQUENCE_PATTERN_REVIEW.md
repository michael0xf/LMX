# Review of all 24 examples under the new sequence and Pattern rules

**2026-11-22.** The basis is the current uploaded archive and its root tasks.
This review does not restore an older delivery over the user's current files.
The earlier implementations, expectations, and meaningful fields are retained.
Code-length selection is over complete eligible source, including declared
failure names; neither source review nor character counting is execution.

## Results

The 2026-11-23 revision separates real-library usage from standalone implementation
comparisons. LMX reusable functions are proposed core entries. Foreign clients
use actual packages/operators; no custom comparison module is imported.

R01 uses derive with width, height and depth unchanged. Its one-line merge spelling
is a note, not a second full program. H04 similarly keeps bindFields with a short
merge-equivalence note. V03 keeps local sample reuse and describes the two changed
lines without repeating the whole test.

H09 calls the core iterateUntilStop and retains the live declaration/body protocol.
Its complete finite failure handling needs the explicit AE01 receiving-activation
bridge; this is documented, not disguised as an already executed implementation.
V02 calls core between; Haskell uses Data.Ix.inRange. All eleven ASCII/invalid-input
cases remain. The Pattern matcher is a distinct approach, not a substitute for the
inclusive-range comparison. H07 raw/prepared occurrence tests remain distinct from
lazy value caching. All typed heads retain current @T/[]T syntax.

## Individual decisions

| Example | Mechanism and invariants retained | Decision after considering the new operations |
| --- | --- | --- |
| H01 | Choose a callable, call it, replace the selected reference, call again | Direct calls remain shorter than generic apply; a sequence wrapper adds no useful operation |
| H02 | Named signature admission, positional relation to candidate names, direct comparison | Keep both signature forms; migrate the typed pointer head, retain the shorter named form |
| H03 | Two independent captured prefixes, repeated add5 use, same-name outer local | Keep the shorter partial formulation and the entire procedural capture alternative; update actual declared exits |
| H04 | Default 5, explicit override 25, explicit zero, unchanged later default | Keep bindFields and explain the small merge spelling difference without a full duplicate |
| H05 | Copied lexical owner versus immediate-caller dynamic binding | Preserve direct calls; another ordinary receiver would change the caller boundary being observed |
| H06 | Both composition orders and intermediate arithmetic | Direct nested calls remain shorter; retain the complete pipe alternative with current exits |
| H07 | Prepared occurrence evaluated once versus actual raw occurrence evaluated twice | Preserve the raw source/eval mechanism. Lazy-plus-two-calls stays an explanatory alternative, not an eligible replacement |
| H08 | Own input place versus transparent caller place | Preserve direct invocation and mutations; collection callbacks introduce a different binding context |
| H09 | Three yielded values, four next calls including Stop, live declaration, mutable body place | Use core iterateUntilStop, retain the live declaration and Stop protocol; document AE01 and all named exits |
| R01 | width=2, height=5, depth=7, one model composition, unchanged inputs | Keep derive and the native Haskell control; explain direct merge in a one-line note |
| R02 | Explicit copy stream and the written anonymous assignment groups | Keep grouped assignment. Selecting indices or materializing a list would hide the expansion rule being demonstrated |
| R03 | Import identity, ordinary dynamic binding, copied owner, subsequent owner write | Preserve those explicit operations; a selection helper is not a substitute for import/copy ownership |
| R04 | Computed default per call, suppressed/defaulted initialization, local writes not published | Keep reached declarations and assignments; eager collection preparation would test a different mechanism |
| R06a | Two references share one copied target; source target remains distinct | Keep one copy operation. Independent per-field copies would be wrong; project over all fields adds no saving |
| R06b | Cycle retained by one copy map; source and copied values differ | Keep cyclic graph construction/copy. A flattened or recursively expanded sequence would destroy the tested graph |
| R07 | OPERANDS_TEMPLATE first, one ordinary graph, executable operand tree | Keep the explicit operand; new sequence APIs do not replace the tree/execution relation |
| R09 | Uninitialized primitive/reference, local write versus graph-fragment replacement | Preserve all states. Empty arrays, null, and initialized zero cannot replace uninit |
| A01 | One physical slot replacement, descriptor length, new named content | The existing one-slot assignment is already shortest. replaceRange is for length-changing/range operations and adds checks/arguments here |
| V02 | Exact length, separator, two ASCII letters/digits, NUL and Unicode rejection, custom helper contract | Use core between against real Data.Ix.inRange; keep Pattern separately and retain all eleven cases |
| V03 | Good/biased/twice-reading candidates, exactly one observable reader call | Reuse sample; retain every verdict and read count; replace the near-identical old program with a short note |
| V04 | Named NoSample exit differs from numeric zero success | Keep the catch path; none/false/collection filtering cannot replace a declared failure |
| V05 | On/write/read/off/write/read acknowledgements, sensed state, counters and trace | Preserve every field and effect order. A sequence reduction could return the same Boolean while losing the protocol trace |
| M01 | Owner-side counter mutation and reads | Retain Message-oriented ownership behavior; no shared-memory or generic collection substitute |
| M05 | Commanded Lamp state at the owner | Retain the existing Message/HTTP scenario and its direct state transition |

These examples are mostly semantic probes, not collection-processing workloads.
It is appropriate for many to remain direct. The new general algorithms and
dense/reference cases have their own
[prepared sequence fixtures](../LMX_Fn_Receivers/examples/sequence_examples.lmx),
where their full behavior can be exercised without weakening these probes.

## Reproducibility and preserved material

[variants.json](variants.json) contains complete source only for different approaches.
The [deduplication decisions](validation/dedup_decisions_20261123.json) identify small
variants compacted to notes. The current [style index](haskell_comparision/comparison_index.json) and [client review](OPTIMIZATION_REVIEW.md) publish both complete LMX styles for every scenario. The earlier optimization decisions below do not authorize removing either style because of length. A documented same_minimal_form uses one shared source and two equal metric entries. The historical selection script [select_variants.py](tools/select_variants.py) is not the authority for dropping a required style.
[expected_results.json](expected_results.json) preserves scenario observations.

The client [Cabal component](haskell_comparision/lmx-examples.cabal) depends on base, array and
monad-loops, and deliberately excludes comparison modules from its source path.
[Implementation comparisons](libraries/README.md) retain the foreign and LMX
algorithms, with complete source and explicit kernel integration boundaries.
No LMX/GHC runtime receipt is claimed. The 23 GoF controls retain their original
primary programs; only near-identical explanatory LMX copies in 12, 20 and 21
were compacted to notes.

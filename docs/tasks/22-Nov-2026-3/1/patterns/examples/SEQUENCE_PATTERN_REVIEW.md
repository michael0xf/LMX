# Review of all 24 examples under the new sequence and Pattern rules

**2026-11-22.** The basis is the current uploaded archive and its root tasks.
This review does not restore an older delivery over the user's current files.
The earlier implementations, expectations, and meaningful fields are retained.
Code-length selection is over complete eligible source, including declared
failure names; neither source review nor character counting is execution.

## Results

R01 has one new equivalent, eligible alternative: `derive` returns the value
already collected by its ordinary merge body. It takes 183 nonwhitespace
characters versus 184 for the preserved direct formulation. Width, height,
depth, model ordering, source independence, and one composition map remain.
The complete 71-character helper is shown in
[the adjacent comparison](library_comparisons/r01_derive_comparision.md).

V02 has a Pattern alternative of 248 characters. Its competitive original is
now a complete 462-character listing: the 263-character client plus the
199-character local CharacterRange helper. It keeps all eleven ticket cases on its explicit byteText profile.
It is **not eligible for the existing competitive comparison**: that control
shows a small custom character-range helper, not a regex engine; the original
between/RangeArity mechanism and its own tests also remain meaningful. Both
sources are in [V02](lmx/V02.lm3), and the
[implementation comparison](library_comparisons/v02_character_range_comparision.md)
explains the boundary. A shorter result alone does not override eligibility.

H02's model-qualified pointer is now `PairOperation@: selected Candidate\encode`.
The specialized prepared left in H07 is `int@: left`; this is a type requirement,
not an initialized universal reference to the atom int. Both changes also
apply to variant records and the corresponding helper/source listings. H02,
H03, H06, and H07 receiver variants now declare the current adapter allocation
and index failures. No obsolete all-formals-required interpretation is retained
in the regenerated apply/partial/pipe/lazy comparison descriptions.

## Individual decisions

| Example | Mechanism and invariants retained | Decision after considering the new operations |
| --- | --- | --- |
| H01 | Choose a callable, call it, replace the selected reference, call again | Direct calls remain shorter than generic apply; a sequence wrapper adds no useful operation |
| H02 | Named signature admission, positional relation to candidate names, direct comparison | Keep both signature forms; migrate the typed pointer head, retain the shorter named form |
| H03 | Two independent captured prefixes, repeated add5 use, same-name outer local | Keep the shorter partial formulation and the entire procedural capture alternative; update actual declared exits |
| H04 | Default 5, explicit override 25, explicit zero, unchanged later default | Retain merge/bindFields variants and the fair shortest/tie rule; map or a fold would alter the call being tested |
| H05 | Copied lexical owner versus immediate-caller dynamic binding | Preserve direct calls; another ordinary receiver would change the caller boundary being observed |
| H06 | Both composition orders and intermediate arithmetic | Direct nested calls remain shorter; retain the complete pipe alternative with current exits |
| H07 | Prepared occurrence evaluated once versus actual raw occurrence evaluated twice | Preserve the raw source/eval mechanism. Lazy-plus-two-calls stays an explanatory alternative, not an eligible replacement |
| H08 | Own input place versus transparent caller place | Preserve direct invocation and mutations; collection callbacks introduce a different binding context |
| H09 | Three yielded values, four next calls including Stop, live declaration, mutable body place | Keep the live declaration and Stop protocol; include the complete Cycles helper in the counted primary |
| R01 | width=2, height=5, depth=7, one model composition, unchanged inputs | Add equivalent derive; select its 183-character complete client; retain direct merge and Haskell control |
| R02 | Explicit copy stream and the written anonymous assignment groups | Keep grouped assignment. Selecting indices or materializing a list would hide the expansion rule being demonstrated |
| R03 | Import identity, ordinary dynamic binding, copied owner, subsequent owner write | Preserve those explicit operations; a selection helper is not a substitute for import/copy ownership |
| R04 | Computed default per call, suppressed/defaulted initialization, local writes not published | Keep reached declarations and assignments; eager collection preparation would test a different mechanism |
| R06a | Two references share one copied target; source target remains distinct | Keep one copy operation. Independent per-field copies would be wrong; project over all fields adds no saving |
| R06b | Cycle retained by one copy map; source and copied values differ | Keep cyclic graph construction/copy. A flattened or recursively expanded sequence would destroy the tested graph |
| R07 | OPERANDS_TEMPLATE first, one ordinary graph, executable operand tree | Keep the explicit operand; new sequence APIs do not replace the tree/execution relation |
| R09 | Uninitialized primitive/reference, local write versus graph-fragment replacement | Preserve all states. Empty arrays, null, and initialized zero cannot replace uninit |
| A01 | One physical slot replacement, descriptor length, new named content | The existing one-slot assignment is already shortest. replaceRange is for length-changing/range operations and adds checks/arguments here |
| V02 | Exact length, separator, two ASCII letters/digits, NUL and Unicode rejection, custom helper contract | Keep Pattern as a separately scoped alternative; count CharacterRange with the unchanged original client and retain all eleven cases |
| V03 | Good/biased/twice-reading candidates, exactly one observable reader call | Reuse the existing sample method in biased and readsTwice; preserve the old full listing alongside, every verdict, and the exact read count |
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

[variants.json](variants.json) keeps both complete sources and their cases for
eight examples. [select_variants.py](tools/select_variants.py) selects the
shortest eligible one and emits the other after the exact exclusion marker.
The V02 Haskell comparison and explanatory text are preserved in the guide,
not replaced by its Pattern listing. App-specific CharacterRange loading is
explicitly permitted for that record; it is not a second selectable core.

[expected_results.json](expected_results.json) retains all original cases and
the variant-specific cases separately. The whole current core is shared by
both formulations. The adjacent apply/partial/pipe/lazy implementations are
regenerated from their actual transitive source dependencies, including the
new common array helpers when referenced. No execution receipt is claimed
for either LMX or Haskell.

## Complete-source and local-reuse audit

The later [47-example audit](../validation/reuse_review_gof_examples_20261122.json) includes all 24 clients and all 23 root GoF examples. H09 and V02 now include their complete application helpers in the primary source; their former client text is retained unchanged. V03 uses its existing sample method without changing DATA or callback counts. Foreign sources remain unchanged. This is source review, not execution.

# The typed notation of a type in L2: path and group bases, the bare reference (step 23.6, second slice)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. The second slice of step 23.6 of the
plan section `next_core_tasks_v3.md#docs-20261122-2`; the first is
[witnessed here](../l2-typed-notation-20261123/notes.md). The design, the code, the parser cases, the pair and the
mutants are by the peer session sonnet. Fable read every pair of the new cases, derived their expected results
with the accepted parser before any run of the new code, built the set from the tree step by step and ran the
gates on its own builds. The decisions are the executor's answers Р161 and Р168 in
`LMX_blog/q/fable-self-answers-20261110.md`.

## What changed

The pass that rewrites the typed notation into the tree of the former one, at the translator's entry, now takes
the forms the first slice left as written and the sources use.

- The base of a typed head may be a path or a group: `Holder\f@: p x` becomes `@: p Holder\f x`, and
  `(Model)@@: p x` becomes `@@: p (Model) x`. The nodes of the base are the fields the parser's own reader of
  fields gives for the text of the head; they stand after the name, and the separator mark of the name moves to
  the last of them.
- A postfix after a path types the whole path: `(cast: (Holder\f@) x)` becomes `(cast: (@: Holder\f) x)`.
- A run of `@` alone where a type stands is the reference to `void` in every such position: the result of a
  function, `sizeof(@)`, `const: @`, the type group of a cast. The head of the Frame says where the type stands.

Left as written, each refused by the translator with its position: a base with an index, a postfix after a group,
a postfix after a dereference. `T[]` in a head is still refused by the pass.

The translator itself takes neither a path nor a group as the type of a place, in either notation. For those
forms there is therefore no pair of units to compare: the gate is the tree after the pass, equal to the tree of
the former notation, and the same refusal of both notations.

## Acceptance

The base is the accepted set of the second part of slice K1b. Every build was one step under the commit watchdog;
the frontend step ran as a process of its own, 9.1 minutes.

| Check | Result |
| --- | --- |
| manifest of the tree | 1644 files, 59d5933f; the stage verified against it |
| runtime by the accepted frontend and by the new one | bc9377ce / f943d725 both times, the accepted bytes |
| the Graph by the accepted frontend and by the new one | the same L1 and the same C, byte for byte |
| hosted frontend, Graph, tool | ebc3181d, fc75e868, 81dd449e |
| parser suite on the new Graph | 425 cases, 0 failed |
| the 92 cases of both slices, derived by Fable before the run | no difference from the tree's expectations |
| pairs on Fable's frontend, three translations each | 8 of 8: the seven of the first slice and the bare reference |
| forms left as written, and path and group bases | refused with a position by the new translator |
| the whole list on Fable's builds, three modes | 480 rows, 416 green, no verdict changed |
| kernel self-tests on the new set | 15, no failures |

The helper's own window was built on the set before slice K1b and is not compared byte for byte. Its gates that
Fable did not repeat: the frontend built from the sources of HEAD by the new frontend and by the accepted one, in
one stage, gives the same L1 and headers for every unit (33 inputs, 59 outputs); the pass run over the 430 `.lm2`
files of the corpus changes none and refuses none; the corpus of parse trees, 1842 files, does not change.

A diagnostic inside a lowered head names the same node as for the former notation, with the column of that node
in the text as written: the name of the place stands at another column because the words stand in another order.

## Mutants

Ten, built by the helper in a private stage. Nine are killed by cases of the suite: a postfix typing one word and
not the path; a path base and a group base not taken; the bare reference not lowered in `sizeof`, under `const:`
and as a result; the guard of a dereference removed (seven cases, more than the one forecast); an index in a base
read as a path; the count of fields of a Structure reduced by one and not by the length of the path.

One is not distinguished: the separator mark not moved to the last field of a path base. Nothing reads it there,
because the translator refuses a path as the type of a place before it would. The mark is moved so that the tree
after the pass is the tree of the former notation.

## Known limits

- A path or a group as the type of a place is refused by the translator in both notations. The typed notation
  inherits the limit; it is not part of this step.
- `T[]` and `T@[]` wait for the author's answer on the array of L2.
- The sources are not translated yet: step 23.7.

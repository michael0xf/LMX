# The sources of L2 are in the typed notation of a reference (step 23.7, the translation)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. The command, its launcher and the
patch of the build tool are by the peer session sonnet. Fable ran the accepted command on the tree, wrote its own
gates, built the chain and compared every build with the accepted set. The decisions are the executor's answers
Р168, Р172 and Р173 in `LMX_blog/q/fable-self-answers-20261110.md`.

## What changed

- The accepted command `retype` rewrote the records of the old notation of a reference in the sources the
  builds read: `@: name T value` is `T@: name value`, `@: name void` is `@: name`, and in the places of a type
  `@: T` is `T@` and `@: void` is `@`. 51 132 records in 105 files of `selfbuild/src/l2src` and
  `selfbuild/tools`; no line was added or removed.
- Left as written: 876 records the command keeps (858 of the form `@: name void value`, which wait for the step
  where the new meaning is switched on; 3 without a type; 15 with a compact head); the three units read by the
  builder of the clean graph, 12 records; one record inside the index of an assignment head, which the tree does
  not show (`l2_frontend_resolve.lm2:640`).
- One change of code: the build tool looked for the kernel's list of receiver words in the text of the kernel's
  source by the pattern of the old notation. It now takes the first string literal after the word `words`,
  whatever the notation. This search is interim: the author's word of the same day is that nobody reads LMX text
  past the parser, and plan step 21.26 (b) removes the generator with its searches.

## Gates

| Gate | Result |
| --- | --- |
| the run of the command on the tree | 108 files, 52 008 records, 51 132 edited, 876 kept, no error |
| a second run | nothing left to edit |
| manifest of the translated tree | 1651 files, 4f01b781: equal to the helper's own translation of an export |
| trees: the old text by the accepted Graph against the new text after the pass | 105 files, none differs |
| the records left, counted by the text | those the command reports and the one inside the head's index |
| two program roots the chain does not build | the L1 of each from the old and the new text is equal |

The tree gate reads the old text without any pass and the new text after the pass of the typed notation; the one
rule that changes a tree by design, `@: name void` to `@: name`, was applied to the old print: 1016 records.

## The chain

The base is the accepted set of the tool slice of this step.

| Build from the translated tree | Result |
| --- | --- |
| the tool, before the patch of the search | 76c6fc33: equal to the accepted tool with the PE stamp masked |
| the runtime, by the accepted frontend | 760bb272 / 16dc4144: the accepted runtime, byte for byte |
| the hosted frontend, before the patch | stopped at once: the list of receiver words was not found |
| the tool with the patch, and once more by itself | 68a20818 and bdaecfa6, equal with the PE stamp masked |
| the hosted frontend, by the accepted frontend and runtime | 3135b662: equal to the accepted one, PE stamp masked |
| the runtime, by the new frontend | the accepted runtime, byte for byte |
| the Graph | 42ca5d68: equal to the accepted one, PE stamp masked |
| parser suite; kernel self-tests | 439 cases, 0 failed; 15, no failures |

Every executable is the accepted one, so the row list was not run again: its run on the accepted set of the tool
slice stands (483 rows, 418 green).

The failed frontend build stripped the stage of its generated files, and the next runtime build failed for that
reason alone. The cure was the frontend build by the accepted frontend and the accepted runtime, which is also
the build the table shows.

## Known limits

- The pass of the typed notation is still needed: the translator reads the typed heads through it until the step
  that reads them directly.
- The programs of the tests and the three units of the graph route stay in the old notation until the kernel
  reads typed heads.
- The typed notation inside the index of a head is not lowered yet: plan step 21.26 (a).

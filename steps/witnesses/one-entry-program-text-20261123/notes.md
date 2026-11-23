# One entry for reading program text in the L2 translator (plan step 21.26, item (а); the third slice of 23.6)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. The design, the code, the programs and
the gates are by the peer session sonnet. Fable read the change, wrote its pins before any build, built the chain
and ran the checks. The decisions are the executor's answers Р172 and Р174 in
`LMX_blog/q/fable-self-answers-20261110.md`.

## The norm

The author, 2026-11-23 ([journal](../../../LMX_blog/2026-11-23.md#one-parser-everywhere)): one parser everywhere;
the inside of the brackets of a path is read by the same parser and computed by the same general expression.

## What was wrong

The text of an assignment head with an index is one text in the parse tree. The translator read it again as a
document of its own, and on that reading the transitional pass of the typed notation was not called. So
`p[f((cast: (char@) q))] := 1` was refused while the old notation was translated: the inside of the brackets was
not read in the same way as the rest of the program.

## What changed

- One function of the translator turns bytes into the tree in the form the translator reads: the parse and, today,
  the pass of the typed notation. Four readers use it: the file of a program and its parts, the text of an
  indexed head, a predef document, the header text of the receiver table.
- No other place of the translator calls the parse or the pass. A static gate of the slice lists every call:
  outside the entry the modules of the translator hold none.
- The export list of one frontend module grows by the new name; the tool is rebuilt for that.
- Three programs and their rows: twins of three heads with a type inside the index, in the old and in the typed
  notation, and a refusal inside the index.

## Acceptance

The base is the accepted set of the translation of the sources.

| Check | Result |
| --- | --- |
| manifest of the tree | 1654 files, 5abd2f69; the stage verified against it |
| the tool by the accepted tool, and once more by itself | 42bd48ac and 818a4ff0, equal with the PE stamp masked |
| the runtime by the accepted frontend and by the new one | the accepted runtime, byte for byte, both times |
| the hosted frontend | 33950d88 |
| the Graph | 4faa0cf3: equal to the accepted one with the PE stamp masked |
| the static gate | two calls inside the entry, none outside it in the translator |
| the twin in the old notation on the accepted set | answers 7 |
| the typed twin and the refusal on the accepted set | refused at translation; the needle is not said |
| the three rows on the new set | all green; the refusal names line 7, column 5 and the pass's message |
| the L1 of the twins by the new frontend | 6377 lines each; 3 differ, the heads' own text in the name table |
| parser suite; kernel self-tests | 439 cases, 0 failed; 15, no failures |
| the whole row list, three modes | 483 rows, 418 green, no verdict changed |

## What the pins showed

Fable's pins were written before any build. Two of the helper's did not hold, and the record keeps both.

- The twins as first delivered computed the index 9 for an array of four: the size of a reference is 8. Derived
  before the run, then confirmed. Corrected to the index 2.
- The twin in the old notation then still stopped: an index whose type is `int` stops a native root by an
  uncaught throw, while the same index as `size_t` works. Reproduced by Fable with a program of five lines on the
  accepted set. It is a defect of its own, entered in the plan; the twins cast the index to `size_t`.
- The pin «the L1 of the twins is equal» was wrong in the letter: the text of a head is a name of the program
  and stands in the name table as written, so three lines differ and must.

## Mutants

Six, by the helper, three of them builds of the frontend: run after this acceptance in a private stage; their
table is added to this note when they are done.

## Known limits

- The builder of the clean graph reads the index of a head by its own parse: plan step 21.26, item (д).
- The one record of the frontend's own sources inside a head's index is still in the old notation.
- An assignment head that combines a path with an index is refused: plan step 21.26, item (г).

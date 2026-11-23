# The command that translates reference records and the print of nodes with positions and flags (step 23.7)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. The design, the code, the cases and
the mutants are by the peer session sonnet. Fable read the change, built the touched components from the tree,
ran the suites and the whole row list on its own builds and checked the new print independently. The decisions
are the executor's answers Р168 and Р172 in `LMX_blog/q/fable-self-answers-20261110.md`.

## What the slice is

The first of the two slices of step 23.7, the tool for the mechanical translation of the sources of L2 from the
old notation of a reference (`@: name T value`) into the typed one (`T@: name value`).

- A permanent mode of the Graph: `p0 FILE [lower-types] [flags|nodes]`. After the ordinary line of the print come
  ` ##`, with `nodes` the position of the node (offset and length in bytes, line and column), then the flags of
  the node in brackets and the flags of its Frame or trailer in braces. A case of the parser suite can now pin a
  flag the ordinary print hides: the separator after a field, the colon of a Frame, the mark of a postfix.
- A transitional command of the Graph, in a module of its own: `retype --dry|--write ROOT LIST [REPORT]`. It reads
  every file by P0, finds the records of the old notation by the place they stand in and rewrites them, copying
  the bytes between records as they are. A record whose layout is not the plain one is kept and reported with the
  reason; the command never guesses. It leaves with the pass of the typed notation.
- The parser suite takes the two words of the print in a case; 14 new cases, 439 in all.

Touched: the Graph's tool module, the root of the Graph, the build step of the Graph and the parser suite in the
tool, one new module. The sources of the kernel and of the frontend are not touched, so the frontend and the
runtime of the accepted set stay as they are and were not rebuilt.

## Acceptance

| Check | Result |
| --- | --- |
| manifest of the tree | 1651 files, e165b8f3; the stage verified against it |
| the tool by the accepted tool, and once more by itself | 42e4ec33 and 998d9a2b, equal with the PE stamp masked |
| the Graph | 8acbb0eb |
| parser suite on the new Graph | 439 cases, 0 failed |
| the helper's cases of the command on Fable's Graph | 10 of 10 |
| the whole row list, three modes, new tool and Graph | 483 rows, 418 green, no verdict changed |
| kernel self-tests by the new tool | 15, no failures |

## The independent check of the print

Predictions were written before the slice was applied and before the helper's cases were read.

- The names of the print's three tables were compared with the definitions of the generated header: all 19 bits
  agree.
- Over the 2097 `.lm2`, `.lm3` and `.lmx` files of `selfbuild` and `tests` (2011 read by P0, 86 refused): the
  ordinary print and the exit code of the new Graph equal those of the accepted Graph; every line of the print
  with `flags` and with `nodes`, up to its ` ##`, is the line of the accepted Graph's ordinary print, and a
  refused file prints what the ordinary print does.
- Positions: of 773 638 atoms, 773 629 have a span that is their text in the source, with the line and the column
  counted from the source (a line break is CR LF, CR or LF). The other nine are atoms of block strings in seven
  files of the parser tests: their span has the offset of the opening line and the length of the payload. That
  is how P0 records them; the command refuses to edit a record whose atom is not the text at its span.
- Small programs: of thirteen predicted clauses nine held. Four did not, each because the executor's model of
  the tree was wrong, not the print: the separator mark sits on the last field inside the formal; an index and a
  postfix written in a head are part of the head's text; a `---` leaves no trailer. In each the line before
  ` ##` is the accepted print.

## The dry run of the translation and one finding

The dry run over the tree, by the records of the builds of the accepted set: 108 files, 52 008 records of the old
notation, 51 132 to be edited, 876 kept (858 of the form `@: name void value`, which wait for step 23.8; 3
without a type; 15 with a compact head). Three units are read by the builder of the clean graph, which the pass
of the typed notation does not reach: they are left, 12 records, until the kernel reads typed heads.

Fable counted the records by the text instead of the tree. The two counts differ by the 14 compact heads on
seven lines, which have no colon, and by one record the tree does not show:
`selfbuild/src/l2src/l2_frontend_resolve.lm2:640`, a cast inside the index of the head of an assignment. A head
with an index is one text in the tree, so the census and the command do not see a record there. A probe on the
accepted frontend showed the same hole in the pass of step 23.6: `p[f((cast: (@: char) q))] := 1` is
translated, `p[f((cast: (char@) q))] := 1` is refused. That record stays in the old notation in the mass
translation; the pass gets the head's own parse as its next slice.

## Mutants

Twenty-six, by the helper: thirteen of the print and thirteen of the command. Twenty-five are killed; one
survives as equivalent (an inactive Frame node does not exist).

## Known limits

- A trailer has no span in the tree, so its line is printed without a position.
- The typed notation inside the index of a head is not lowered (the next slice of step 23.6).
- The span of a block string atom is not its text (above).

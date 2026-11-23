# Composed heads, the square group and the postfix reference in the parser (step 23.3)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. Step 23.3 of the plan section
`next_core_tasks_v3.md#docs-20261122-2`. The design, the code, the parser cases and the mutants are by the peer
session sonnet. Fable derived the expected trees independently before the run, read the code, built the set from
the tree step by step and compared it with the helper's. The decisions are the executor's answers Р152, Р156 and
Р160 in `LMX_blog/q/fable-self-answers-20261110.md`.

## The norm

- A head is a base and a run of type suffixes, kept as written; the base may be a bounded group
  ([grammar, section 29](../../../docs/spec/LMX_grammar.en.md#postfix-pattern-grammar)).
- A Structure written in square brackets is the explicit group of elements; a written empty suffix `T[]` and an
  index are told apart by the record ([types](../../../docs/spec/CORE_SEQUENCES_REGEX.en.md#types)).
- `T@` is the type of a reference and `@x` takes an address: the same sign after an operand and before one.

## What the parser did before

It already kept a head whole when its base was a word (`int[]`, `Model@`, `@[]`), and an empty suffix differed
from an index in an expression. Four things were missing, and the slice adds exactly them.

| Missing | Now |
| --- | --- |
| a group as the base of a head: `(Model)@@: p` was two fields | one colon Frame with the head as written |
| a mark of the square group: `[1 2 3]` was the tree of `(1 2 3)` | the node carries a flag, printed `Square` |
| a mark of the postfix `@`: `T@ x` and `T @x` were one tree | the atom carries a flag, printed `Postfix` |
| one function that splits a head into its base and suffixes | `lm_p0_head_split`, exported to the next steps |

A run of `@` is a postfix when it is written right after the end of an operand — a name, a number, an exact
name, `)` or `]`; what stands on its right does not matter. A group, then the run of suffixes, then a colon that
is neither `::` nor `:=`, is a head; `(Model): p` is one too. Rule D reads a head through the same split.

## What changed

- `selfbuild/src/l2src/p0_parser.lm2`: the split of a head (`lm_p0_split_base`, `lm_p0_scan_suffix_run`,
  `lm_p0_head_split`), the head with a group base, the two flags and their print.
- `selfbuild/tools/build.lm2`: the two flags in the generated header; `lm_p0_head_split` and
  `lm_p0_scan_suffix_run` among the exported parser names.
- `tests/parser/current`: 112 new cases, one case re-pinned (a square group of several lines gets the flag); the
  suite is 333 cases.

## Acceptance

Every build was one step under the commit watchdog; the frontend step runs as a process of its own.

| Check | Result |
| --- | --- |
| manifest of the tree | 1625 files, 2de148c9; the stage verified against it |
| tool by the accepted set, then by the new frontend and runtime | 0f299830, 46581c62; equal to the helper's |
| runtime by the accepted frontend and by the hosted one | f55def3b / 346d0668 both times, the accepted bytes |
| hosted frontend, Graph | 00f091ee, 95eec970; equal to the helper's |
| parser suite on the new Graph | 333 cases, 0 failed |
| cases derived by Fable before the run | 113, no difference from the tree's expectations |
| generated list of receiver words; one primitive profile | equal; cdb0036d |
| the helper's log of the whole list (474 rows, three modes) | 412 green as in the witness of slice K1a |
| addressed set on Fable's builds | 91 rows, no verdict differs from the helper's |
| nine kernel self-tests on the new set | 9, no failures |
| parse trees of the corpus (1651 files, the helper's run) | all equal without the two flags |

The executables are compared with the helper's with the PE time stamp and checksum masked. The runtime is
byte-equal to the accepted one: the slice does not touch the kernel. In the corpus the square flag appears in
four files, ten groups; the postfix flag in none, and no L2 source has a postfix node — the condition the step
of the L2 notation starts from.

How the expected trees were derived: for 88 cases the tree without the two flags is the tree of the accepted
parser; for 16 it is that tree with the group node and the Frame after it merged into one Frame whose head is
the written text; for 4 the accepted parser refuses the text, and the tree comes from the same text with `@`
before the colon; 4 are refusals with their positions. The flags were derived from the written text alone: a
postfix where a run of `@` follows the end of an operand, a square flag for every `[` outside heads that is not
an atom of the tree. The same derivation over all 333 cases finds no case that lacks a flag.

## Mutants

Ten, built by the helper in a private stage, all killed by the parser suite: rule D rolled back (20 cases
fail); the head with a group base without the run of suffixes (16); the square flag only on a group of one line
(3); the flag on a round group too (64); the postfix needing a boundary on the right too (1); the postfix flag
with no adjacency test (8); the print without the square flag (23); `::` no longer a stop after the suffixes
(1); `:=` no longer a stop (1); an empty square with a space inside no longer a suffix (1).

For five of them the set of failed cases differed from the helper's forecast. Each difference is explained: two
refusal cases give the same position without the new path; a case whose group stands in the head has no group
node to flag; a `@` at the very start of a group's text is never a postfix; groups of several lines fail with the
flag restricted to one line. No difference points to a weak case.

## Known limits

- `(a b) := value` is refused by the parser as before: a group on the left of `:=` belongs to the step of the
  group assignment.
- The split of a head does not skip a character constant that holds a bracket; a type head has none.

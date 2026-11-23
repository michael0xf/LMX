# A supplied declaration is a Structure at its position: its name is not looked up (step 21.9, the removal slice)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. The design, the code, the rows and the
mutants are by the peer session opus. Fable wrote the pins of the rows and the rule of their derivation before the
slice was drafted, read the change, built the set from the tree step by step, ran the whole list on its own builds
and compared the set and every verdict with the helper's. The decisions are the executor's answers Р157, Р158 and
Р171 in `LMX_blog/q/fable-self-answers-20261110.md`.

## The norm

- A declaration passed as an argument is a data Structure. The receiving variable is chosen by the ordinary
  positional and explicit-name rules; the name declared inside the form is never searched for. After the position
  is selected the call attempts the ordinary admission of the Structure to that variable; it does not execute the
  declaration to make an incompatible argument fit
  ([book, declarations among arguments](../../../docs/spec/LMX_semantics.en.md#declaration-arguments)).
- No `int` input admits a declaration Structure, with a named addressee or without (the author's answer of
  2026-11-23; the ledger, Р158).

## What changed

A removal slice in one module: 27 lines in, 53 out.

- A form among the actuals written in the code of a call takes its position like any positional actual. The
  branch that found an input of the callee by the name the form declares is gone.
- With it goes the description of an input by a form of its name: a row of the callee made from the form's
  record and evaluated on demand. The function that recognized such a form is removed.
- The DATA arguments of a receiver (`fn`, `sub`, `call`) are not touched: there a declaration still assigns the
  formal of its name, until the step on receivers with code arguments.

## Rows

The rule of derivation was written before the slice: after it the inner name of a form has no effect, so a
program whose form names an input of the callee must observe what the same program observes with a name the
callee does not have. The accepted kernel already executed that second program by the general path.

| Row | Pin | What it observes |
| --- | --- | --- |
| `declarg_a01_literal_matched`, re-pinned from 0 1 0 | 1 1 4 | `g(int: b 5)`: the form goes to `a`, an `int` |
| `declarg_a02_a04_unread`, re-pinned | 1 1 4 | the same with a computed form; the producer is not called |
| `declarg_a06_named_on_own_position`, re-pinned | 1 1 4 | `h(int: x 5; 4)`: the form goes to `x`, an `int` |
| `declsel_b07`, re-pinned from 1 1 5 | 1 1 4 | both actuals have positions; the first is not admitted |
| `declsel_b08`, re-pinned | 1 1 4 | `g(int: b 2)`: the form goes to `a`, an `int` |
| `c6_decl_folded`, re-pinned | 1 1 4 | `f(int: a 5)` with two `f`: no `int` input admits the form |
| `declarg_same_name_by_position`, new | 0 1 0 | the form goes to the first input though an input has its name: 6 |
| `declarg_same_name_then_positional`, new | 0 1 0 | the following unnamed argument uses the next position: 4 |
| `declarg_outer_name_same_inner`, new | 0 1 0 | the outer name selects, the inner name stays inside the form: 6 |
| `declarg_no_position_left`, new | 1 1 5 | an excess actual: the call refuses before any argument runs |
| `declarg_int_by_outer_name`, new | 1 1 4 | an `int` input admits no declaration Structure by name either |
| `declarg_outer_name_literal_length`, new, red | 0 1 0 | a literal form after an outer name; 6 by the norm |

Three rows left the list with their files: they observed the lazy description of an input, the mechanism the
slice removes. The last row of the table stays red until the builder keeps a literal form after an outer name as
a record of two fields (step 21.9, part (b)); its pin is the norm's.

`c6_decl_folded` was not in Fable's inventory, which searched by the names of rows; the helper's early run showed
it, and it was re-pinned by the rule written before that run. The helper then listed every program with a
declaration among the actuals of a call by parsing: the 35 programs of `tests/graph`, and none among the 1211
texts embedded elsewhere in `selfbuild`.

## Acceptance

The base is the accepted set of the second slice of step 23.6. Every build was one step under the commit
watchdog, one build on the machine at a time; the frontend step ran as a process of its own, 6.6 minutes.

| Check | Result |
| --- | --- |
| manifest of the tree | 1650 files, 04e8b218; the stage verified against it |
| pins, rewritten programs, expected dumps of the new rows | as pinned; no difference from the source graph |
| self-tests of the staged tree on the accepted set | 15, no failures |
| runtime by the accepted frontend and by the new one | 760bb272 / 16dc4144 both times; byte-equal to the helper's |
| hosted frontend, Graph, tool | 14e02a70, b1cad4ce, 3e1e31da; equal to the helper's with the PE stamp masked |
| parser suite on the new Graph | 425 cases, 0 failed |
| the pins against the helper's list | 483 rows, no pin differs |
| the helper's log of the whole list, three modes | 418 green: the 413 of the base and 5 of the 6 new |
| the whole list on Fable's builds | 483 rows; no verdict differs from the helper's |
| self-tests on the new set | 15, no failures |

The witness table of the slice is [witness-rows.tsv](witness-rows.tsv): 483 rows, 418 green. Against the base
without the three removed rows, 477 rows and 413 green: five new rows are green, one new row is red as pinned,
nothing else changed.

## Mutants

Two, by the helper. The lookup of the form's name put back: killed, `declarg_same_name_by_position` fails in all
three modes. The second restores only the skipped admission of a form whose name is the input's: it is not
distinguished today, because the admission of a form by a reference input with a model never refuses — a debt of
the `satisfies` library, step 21.8 (a). A candidate row waits with the helper for that step.

## Known limits

- A literal form after an outer name arrives as a Structure of one field: part (b) of the step.
- The DATA arguments of a receiver keep the assignment by the declared name until the step on receivers with
  code arguments.

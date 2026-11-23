# The type context of the kernel, the repair of the autofill, the root programs without `data`

Written 2026-11-23 by Fable, the coordinator and the single writer of main. One kernel window of three independent
parts, built and accepted on one chain: the first slice of the types of step 23.4 (T1), the first part of slice K1b
of step 21.7 (the autofill), and the translation of 26 programs of the witness rows. The design, the code, the
programs, the counters and the mutants are by the peer session opus. Fable pinned the rows from the norm before the
run, read the code, built the set from the tree step by step and compared it with the helper's. The decisions are
the executor's answers Р151, Р155 and Р162 in `LMX_blog/q/fable-self-answers-20261110.md`.

## The norm

- A type is an ordinary code; an array `T[]`, a reference `T@` and a place without a value `uninit:T` are
  constructors over the code of their operand; a model is a type by its identity
  ([types](../../../docs/spec/CORE_SEQUENCES_REGEX.en.md#types)).
- An input without its own value takes the current value of the place of the same name of the immediate caller
  ([autofill](../../../docs/spec/LMX_semantics.en.md#binding-autofill)); a place declared without a value and
  written afterwards has that value
  ([a place without a value](../../../docs/spec/LMX_semantics.en.md#uninit-zero-payload)).
- The special meaning of the name `data` is withdrawn, and R0 is a procedure without data
  ([the root entry](../../../docs/spec/LMX_semantics.en.md#root-entry),
  [removed built-ins](../../../docs/spec/LMX_semantics.en.md#removed-builtins)).

## What changed

**The type context (T1).** A new kernel module `selfbuild/src/l2src/lmx_types.lm2`: one table of the process that
gives a code to a constructor applied to an operand code and to a model. The codes the kernel already has keep
their numbers as rows of the table; other codes are given by a counter that only grows, so the number of a removed
type is never given to another type. The rows of the types built over a model leave with the model: when its arena
is released, when its block is taken back, when a failed construction is rolled back; the collection keeps the
models that have a code. No existing path asks the table yet. The same slice makes `lmx_l3_type` find the region of
an address once instead of twice.

**The autofill.** `lmx_graph_work_autofill` takes the value behind the pointer cell of a place that was declared
without a value and written afterwards; before, the input received the cell that was never written and the call
answered 5.

**The programs.** 26 programs of the witness rows read the root through the special name `data` in the code of the
root. They are rewritten to name the root from inside a method of the root (`@: shared node[0]`); three of them
move the code of the root into a sub of the root, and one makes each capture of a value a call of a root sub at the
same place. Both kernels observe each program the same; no pin and no observed value changes.

## Acceptance

Every build was one step under the commit watchdog; the frontend step runs as a process of its own.

| Check | Result |
| --- | --- |
| manifest of the tree | 1638 files, 2eeec13f; the stage verified against it |
| runtime by the accepted frontend and by the hosted one | a081a985 / 0db8716a both times; differs from the accepted |
| hosted frontend, Graph, the tool by them | e4826536, a04cc2ec, a133ce51; equal to the helper's |
| parser suite on the new Graph | 333 cases, 0 failed |
| kernel self-tests on the new set | 15 (nine of the graph, six of the types), no failures |
| the 26 rewritten programs against HEAD | the observed block of every expected file is byte-equal |
| expected dumps of the three new rows against Fable's table | equal |
| the helper's log of the whole list (477 rows, three modes) | 414 green; see below |
| addressed set on Fable's builds | 134 rows, no verdict differs from the helper's |

The whole list: the 412 rows green in the witness of slice K1a stay green; `sc_input_autofill_root` turns green
with its pin unchanged; the new row `bind_autofill_written_uninit_source` is green; the new rows
`sc_input_path_written_uninit` and `flow_bare_return_ends_body` are red by the norm — the first until a place
without a value has no hidden cell (step 21.17), the second until a bare `return` ends a body. No other verdict
changed. The new base of the witness rows is `witness-rows.tsv` beside this note: 477 rows, 414 green.

The transitional tool of the chain — the tool built first, by the accepted set — differs from the helper's in
twelve bytes: it takes the size of the arena record from the generated C header that is in the stage when it is
compiled, and the helper's chain had the former header there. The generated C of both is equal, and the tool, the
frontend, the runtime and the Graph that run the checks are equal to the helper's.

## Counters

Measured by the helper on three loop programs, per iteration, the accepted kernel against the kernel with the
slice: the answers and the takes of the arena are equal; the table of types is not asked; the calls of
`lmx_range_cell_pool` fall from 4588 to 3826, from 3132 to 2671 and from 3978 to 3388 (15–17 %).

## Mutants

Eight, built by the helper one at a time, each in a private stage copied from the tree; all killed. A control run of
the same checks in the same private stage with the unchanged runtime passes, so each failure is the mutation.

| Mutant | Killed by |
| --- | --- |
| the repair of the autofill taken back | `sc_input_autofill_root`, `bind_autofill_written_uninit_source`: answer 5 |
| an array and a reference over one operand get one code | `types_codes`, `types_compositions`, `types_rollback` |
| a code the kernel already has is not a row of the table | `types_codes` |
| the number of a removed type is given again | `types_arena_release`, `types_arena_drop`, `types_rollback` |
| the collection does not keep the models that have a code | `types_arena_drop` |
| a rollback takes types over a model made before its mark | `types_rollback` |
| a block leaving its arena removes every row of the arena | `types_arena_drop` |
| the type of an address is read from the kind of its region | eight of the nine self-tests of the graph |

The seventh mutant was killed by no self-test of the helper's first run: every revert there took all the blocks of
its arena. The self-test `types_arena_drop` got one more case — a revert of a later block keeps the row of the
model — before the window.

## Known limits

- The table of types is heap storage of the kernel beside the table of names; it moves into the graph with it.
- R0 still runs over the root as its data; the second part of slice K1b removes that.

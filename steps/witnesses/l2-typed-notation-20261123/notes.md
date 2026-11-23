# The L2 translator reads the typed notation of a type (step 23.6)

Written 2026-11-23 by Fable, the coordinator and the single writer of main. Step 23.6 of the plan section
`next_core_tasks_v3.md#docs-20261122-2`. The design, the code, the parser cases, the pairs and the mutants are by
the peer session sonnet. Fable derived the expected results of the cases independently before the run, read the
code, built the set from the tree step by step, ran the pairs on its own frontend and compared the set with the
helper's. The decisions are the executor's answers Р152, Р156, Р161 and Р163 in
`LMX_blog/q/fable-self-answers-20261110.md`.

## The norm

- The type of a reference to T is written `T@`: a place `T@: name value`, a result `) T@`, a cast
  `(cast: (T@) x)`, `sizeof(T@)`, a formal `const: (T@: name)`
  ([grammar, section 29](../../../docs/spec/LMX_grammar.en.md#postfix-pattern-grammar); the ledger, Р152).
- A head is a base and a run of suffixes; the base is a word or an exact name; a run of `@` right after the end of
  an operand is a postfix (the ledger, Р156).

## What changed

**The parser, two corrections.** Step 23.3 left two records behind the norm; no case of its suite had them.
`x: c.FILE@` gave one atom `c.FILE@`: a name of the C surface took the `@` with it. An exact name followed by
`@` — the head `` `a b`@: v `` and the value `` x: `a b`@ `` — was refused with code 18. Now both read as every
other operand: an atom and its postfix, a head kept whole.

**The pass.** The L2 translator reads a place through the form `@: name T value`. One pass over the parsed
document, `lm_p0_lower_types`, called at the translator's entry, rewrites the typed notation into the tree the
parser builds for that form; the readers of the translator do not change. A typed place `T@..: name tail`
becomes `@..: name T tail`; an operand followed by a postfix run becomes the Frame `@..: operand` (a result, a
cast, `sizeof`, an operand of `const:`); a run of `@` alone in the type group of a cast is the reference to
`void`. Only a colon Frame that is no assignment has a typed head. The pass is a mechanism of the transition:
only the translator calls it, L3 programs do not pass through it, and step 23.8 removes it when the translator
reads the head directly.

The Graph tool prints the tree after the pass on request (`p0 FILE lower-types`), and a case of the parser suite
asks for it with the key `lower_types`.

## Acceptance

Every build was one step under the commit watchdog; the frontend step runs as a process of its own (7.4 minutes).

| Check | Result |
| --- | --- |
| manifest of the tree | 1638 files, 99e918f3; the stage verified against it |
| tool by the accepted set, then by the new frontend and runtime | dfd64335, dfd1191c; equal to the helper's |
| runtime by the accepted frontend and by the hosted one | a081a985 / 0db8716a both times, the accepted bytes |
| hosted frontend, Graph | 467bde09, b3588d0a; equal to the helper's |
| the Graph by the accepted frontend and by the new one | the same L1 and the same C, byte for byte |
| parser suite on the new Graph | 402 cases, 0 failed |
| cases derived by Fable before the run | 69, no difference from the tree's expectations |
| the pairs on Fable's frontend | 7 pairs, 24 functions: three L1 texts and three headers equal |
| the helper's log of the whole list (477 rows, three modes) | 414 green as in the witness, no verdict changed |
| addressed set on Fable's builds | 163 rows, no verdict differs from the helper's |
| kernel self-tests on the new set | 15, no failures |

The two gates of the step. First: the frontend built from the sources of HEAD by the new frontend and by the
accepted one, in one stage, gives the same L1 and the same headers for every unit — 33 inputs, 59 outputs, no
difference (the helper's run); the pass is empty on the former notation. Second, the pairs: one unit written in
the former notation and in the typed one gives the same L1 — translated here three times, the former text by the
accepted frontend, the former and the typed text by the new one.

The corpus of parse trees, 1773 files, does not change: no source has the two records the parser correction
touches (the helper's run).

How the expected results were derived: a lowered case expects the tree the accepted parser gives for the former
notation of the same record, the pair being read by the rules of translation; a case of the parser correction
expects the tree the accepted parser gives when the name is written as a plain word, the name put back; a
refusal expects the diagnostic at the first byte of the head.

## What the window found

The print of a tree shows no flags, so the cases of the suite cannot see them; the pairs can.

- The pass put the type after the name and left the mark of a separator after the node on the name, where the
  tree of the former notation has it on the type: `int@: q, \pp` did not translate. Found by a pair.
- The pass read the head of every Frame, so the assignment `int@ := p` was rewritten and the new translator
  accepted it silently. Found when every flag of a node and of a Frame was listed against the pass; now only a
  colon Frame that is no assignment has a typed head, and the record is refused with its position as before.

## Mutants

Twenty-one, built by the helper in a private stage.

Seventeen are killed. Fifteen by exactly the cases forecast from the place of the edit: the pair of an operand
and a postfix skipped; the type atom not put in; the depth of the run lost in a head and in a pair; a pair taken
without the postfix flag; the C name not split from its `@`; the bare `@` of a cast; an array not refused; a
postfix after a path; a path or a group as a base; the tree not opened for the pass; an exact name not continued
by `@`; the cut at an `@` inside brackets; the head of an assignment and of a compact call read as typed; the
pass entering a mix mark. The pass called on the path of the Graph is killed by 26 cases. The separator mark not
carried is the first build of the window itself: three pairs did not translate.

Four are not distinguished by anything the step can observe. Three leave out a flag on a node the pass makes — the
separator mark after a merged postfix and after the bare `@` of a cast, the colon flag of the new Frame — and the
translator reads none of them there; one of the three was checked with a frontend built from the mutant, and all
seven pairs pass. The fourth is equivalent: an inactive line is a node of another kind and is cut off by the first
test. The flags stay, so that the tree after the pass is the tree the parser builds for the former notation; no
check of this step guards them.

## Known limits

- Left for the next slice, before the sources are translated: a base that is a path or a group, a postfix after
  a path, and a run of `@` alone as a result, in `sizeof` and under `const:`. The new translator refuses each
  with its position, as the accepted one does.
- `T[]` and `T@[]` in a head are refused by the pass: the array of L2 waits for the author's answer.
- The frontend unit grows with the parser; the step takes seven to eleven minutes depending on what else runs.

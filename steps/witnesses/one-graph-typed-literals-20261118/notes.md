# One graph, G2 step 1: a number written in the program is a typed number of the clean graph

Written 2026-11-18 by Fable (fable_pc), the single writer/build of main. The code of the kernel, the builder, the
emitter and the frontend, and the two fixtures are by the peer session opus, who ran the component builds, the
candidate runs and the mutants under the pipeline token; Fable set the order, took the decisions and ran the
acceptance gates. Base: the slice of the terminal `return`, `e8a9d493`.

## The norm and the defect

The grammar, section 4: the forms of integer and floating literals follow ANSI C/C99 -- decimal, octal and
hexadecimal integers, the suffixes of the integer types, decimal and hexadecimal floating numbers, exponents and the
suffixes of the floating types; a number-like text in backquotes is an exact identifier.

The builder of the clean graph made a number only of a decimal spelling, and with no bound: a decimal beyond the
largest `int` was built as a wrapped `int`. Every other spelling -- `1U`, `0x1F`, `1.0`, `2.5L` -- became a word, and
the interpreter read the word as a name: `unsigned: r 3U` and then `r := r + 1U` answered 3.

## What changed

One mechanism: a C99 number spelling is a typed number of the graph. It is decided by the builder on the raw text of
the program, as the decimal `int` already was, so `1U` is a number and the same text in backquotes a name.

- `lmx_graph_number` (kernel, `lmx_graph.lm2`) is the one reader of number spellings. The type is the one C99 gives
  the constant: the first of the list of its spelling that holds the magnitude -- an unsuffixed decimal `int`, `long`,
  `llong`; an unsuffixed octal or hexadecimal `int`, `unsigned`, `long`, `ulong`, `llong`, `ullong`; `U`, `L`, `UL`,
  `LL`, `ULL` by their lists; a floating constant `double`, with `f` `float`, with `L` `flong`.
- A constant whose type is `int` is the `int` primitive, whatever its spelling: `0x1F` is 31.
- Any other constant is a value cell of the row of its type in the catalog of primitives: a cell of a pool
  `LMX_TYPE_FOREIGN` with the scalar ABI of that row -- the cell the interpreter already read and copied. The catalog
  is the one written in LMX (`primitive.lm2`), its C view emitted by the translator. No flag, no table and no record
  beside the graph.
- The `int` literal of the builder got the bound of `int`: a longer decimal is a `long` or `llong` by the list.
- A constant that no type of its list holds is refused where it stands, before any execution: the construction
  answers 2. No word, no wrapped value and no other type is made of it.
- `lmx_graph_scalar_text` (kernel) writes a value cell as its canonical C99 spelling. The dump prints it; the image
  of an emitted program makes the cell again from it by `lmx_graph_number`; the graph path of a machine function
  (route 331, `l2_frontend_graph.lm2`) writes it into C as the same constant.

## The canonical spelling

The graph keeps the type and the value, not the spelling. The condition on the printed text: read again, it gives the
same type and the same value.

| written | printed | |
|---|---|---|
| `3U`, `5UL`, `18446744073709551615ULL`, `-5L`, `0U` | as written | the suffix of the type |
| `3000000000` | `3000000000LL` | an unsuffixed decimal beyond `int` and `long` is `llong` |
| `0xFFFFFFFFU` | `4294967295U` | octal and hexadecimal print in decimal |
| `0x1F` | `31` | an `int` |
| `0.1`, `0.1234567890123`, `1.5f`, `2.5L` | as written | the shortest text that reads back |
| `1e3` | `1e+03` | the same rule: the shortest `%g` text that reads back |
| `5.0` | `5.0` | `.0` when the text would have neither a point nor an exponent |

## Recorded and not changed here

- The places of the interpreter are not touched. `unsigned: r 3U` and then `r := r + 1U` answers 4 where it
  answered 3: the operand is now read, and the store into a place of a primitive type other than `int` refuses. The
  store is the next step of the group (G2.2), together with the slice «assignment changes the type of the record».
- A typed number in a field of a letter (`exit_code: 7U`) is not taken by `send` -- recorded in the slice of `send`.
- The rows of the full suite run on the former path, which does not read this builder: no name of the full suite
  changed its verdict.
- The fixture `literal_typed_spellings` pins the target of the self-build, where `long` has 32 bits: `3000000000` is
  `llong` there and prints `3000000000LL`. On a target whose `long` has 64 bits the same constant is `long` by the
  same list and prints `3000000000L`; a port to such a target pins this row for that target.
- A lesson of the build order: `build-frontend` with `build-frontend-link` does not translate `l2_frontend_graph`
  again; only `build-frontend-host` does. A first hosted frontend of the candidate linked the old translation of that
  module with the new builder, and the runtime built by it failed at route 331 -- the symptom of the mutant mD. The
  set below was built by `build-frontend-host`; `steps/current.md` names the rule.

## Acceptance on the frozen sources

Freeze Source15: 1008 inputs, manifest SHA ec780b9b26a27008…, verify 1008/0 for the repository and the stage; the
canonical `selfbuild/inputs.sha256` is byte-equal to it.

- Which command translated each changed module (opus's record): `lmx_graph` by the runtime build; `l2_graph_build`
  and `l2_graph_tool` by `build-graph`; `l2_frontend_graph` by `build-frontend-host`; `tools/build.lm2` by
  `build-self`. The hosted frontend was built from the final sources and built the runtime and the Graph tool of the
  candidate; it translates every changed module to the same bytes as the working frontend.
- Whole bootstrap, quick, label `boot-fg21-01`: genuine G1 and actual G1→G2, 9 smoke rows and 0 failures each,
  19.3 min. G0 is the candidate tool built from the new `tools/build.lm2` (9f364fbc: the list of `lmx_graph` grew
  from 85 to 87 exported functions), the previous frontend the hosted candidate (772b9cc5).
- `fixedpointg21-01`: CHECKS 18 lines, 0 failed: 11 `same` and 3 `exe-same` between G1 and G2, the G2 runtime
  objects byte-equal to the candidate runtime, and the two source verifications.
- Actual G2: working tool `boot-fg21-01/lmxtool.exe` 4cad81eb, frontend f8cdbf70, runtime production object 4366080f and
  observed object d5b70d77.
- Route 331 (opus): `lmx_clock`, `lmx_process_deadline` and `lmx_schedule`, translated from the graph by the working
  frontend, where `0U` was a word, and by the candidate, where it is a value cell written by the printer, are the
  same bytes. The whole bootstrap repeats it: the generated runtime of G1 and of G2 is byte-equal.
- Targeted list on the actual G2: SUITE 12 rows, 0 failures, 72 PASS.
- Full suite on the actual G2 (`g2-g21-full01`, 16.8 min): **SUITE 210 rows, 44 failures**, 1450 PASS.
  By fixture names 16 are red, the same names as the base; none is newly red.
- Graph tool on this G2 (`graph-fg21-01`, 06a70c86): `private_binding` and `call_frame_local`, each triple
  interp / native / forced PASS.
- Programs of the full suite on the clean graph, text unchanged, three modes: **11 of 11 pass in all
  three**, the same stage and answer as the base, row for row.
- Clean-graph list, 283 pinned rows (the 281 of the base and two new ones, `literal_typed_spellings` and
  `literal_typed_unheld`), each under a 60 s limit: **221 pass, 62 fail**, rows over the time limit: 0.
  Red by names: 62, the names of the base; the 281 rows of the base answer as before, row by row. No existing
  `.expected` changed. `literal_typed_unheld` pins the refusal of the construction, answer 2, in the three modes; its
  `.expected` is empty, a refusal compares no dump.
- Mutants (run by opus, each undoing one edit in a private copy of the stage with its own runtime and Graph tool),
  eight, all killed: the builder calls no reader of numbers (`literal_typed_spellings` and `_unheld` fail in the
  three modes); the bound of `int` undone (`3000000000` wraps); an integral `double` printed without `.0`; the
  printer of `double` without the search of the shortest text (`0.1234567890123` loses digits); an unsigned value
  printed without `U`; the image refuses a value cell (interp passes, native and forced fail); a constant no type
  holds made a word again (`_unheld` fails); the frontend writes no value cell (route 331 refused).
- Closers: the source diff adds no `end:`. It adds eight fences, each where the next line rises two levels (from
  level 3 to level 1); the two new programs add none.

Generated L1 and C were not edited by hand; no row was disabled.

## What the running program holds after the step

The clean graph, the native methods and the values of a call, as before. New in the graph: a typed number is a value
cell where the builder put the word of its spelling. An emitted program makes the same cell from the canonical
spelling: the string is the C print of the graph.

## Files beside these notes

- `graph-baseline.tsv`: the 283 rows with their results -- the new base of the graph gate.
- `graph-red-names.txt`: the 62 red fixtures of the graph list.
- The base of the clean rows is unchanged: `../one-graph-terminal-return-20261117/clean-rows.tsv`.
- The base of the full-suite gate is unchanged: `../m10-code-places-step1-20261117/full-suite-red-names.txt`.

Receipts outside the repository: `build2/codex_fix250generationchain01/runs/fable-m10-call-forms-20261116-01`,
directories `receipts/opus/one-graph` (`G2-1.txt`, `g21/tree/RESULT.txt`, mutants), `fable` (bootstrap, fixedpoint,
G2 runs, graph list).

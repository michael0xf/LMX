# Admission at the walked root (-178 commit 3)

FABLE-OPUS-ROOT-STRUCTS-20260925-178 commit 3 (Opus).  The translator side of the admission of an
untyped graph at a typed place (the 2026-09-23 rule B2), written against Grok's -180 (lmx_walk_admit /
lmx_walk_admit_letter) as agreed with fable.  It was measured on a private scratch driver carrying the
two primitives to that shape; nothing of it is committed.  Base: origin/main f142b58 (-179, Sonnet
-172 c2).

## The primitives (Grok -180, the shape agreed)

`PRIM [prim, record, value, model]`, nargs 2, owner the program's arena:
- The value is null (out 0, no admission, as natively), a pointer cell (its held reference), or a
  Structure.
- `lmx_walk_admit` admits the value itself; its out is the value.
- `lmx_walk_admit_letter` admits the letter's payload (slot 1); its out is the payload (q25 (ii),
  pending the author).
- A refusal is `LMX_PRIMITIVE_THROW_IMPLEMENTS`, the caller's implicit throw (-177 c5: THROWN + 2
  at the root).

## What the root builds

| form | step |
|---|---|
| `T: m` then `receiveMessage: m` (the one-name, pre-typed form: take the next letter, admit or throw) | PUT(m, admit_letter(take, l2_nsp[T])) |
| `m: raw`, m of type T, raw an untyped reference field | PUT(m, admit(AT(raw), T)); admit_letter when raw is a letter (declared by `receiveMessage: raw`) |
| a letter or untyped graph to a formal of type T | CALL input admit / admit_letter(AT(x), T) |

- The two-name form `receiveMessage: m T` is the selective receive (receive-if).  No row uses it at
  the root, and it stays refused there («an admission to a Structure type»).
- The native two-name form (Sonnet -172 c2) is untouched.

## D-57, the native path

The native path admitted the whole letter, `(sender; payload)` since -173, and refused every host
letter.  Now:
- the one-name typed receive admits and binds the payload;
- a letter passed to a typed formal goes as its payload, admitted;
- `m: raw` of a letter binds the payload, admitted.

Each rewrite is `lmx_arena_ref_value(value, 1U)`, which gives 0 for a null letter.

## D-59

Found while measuring: at the walked root, any merge after a take throws `merge`.
- The root merge copies the unit.
- After the take the unit holds the letter, whose sender is the host's Message: an address R0's
  copier cannot classify.
- A method is unaffected.

The fix is Grok's -181.  unit_admit_letter_formal is translates-with-debt until then.

## Rows

- eternal-runs: unit_admit_letter_typed (an Argv row), unit_admit_letter_not_model,
  unit_admit_letter_extra_field, unit_admit_formal_refused, unit_admit_rebind_refused,
  unit_admit_letter_coarse, unit_charpp_return.  Their tails were rewritten: 17 returns in 7 files.
- New row: unit_native_typed_receive (Entry 7), the D-57 witness.
- translates-with-debt: unit_admit_letter_formal (D-59).
- «an array»: unit_admit_rebind_read, entry_argc_if, entry_index, entry_strcmp, unit_entry_args.
- «throw and catch»: unit_s1_catch_implements.

## Witness (scratch driver with the two primitives)

- Every row that uses receiveMessage, a letter model or a named Model (75) passes: 0 red.
- Mutant A1, the root admitting a letter whole: unit_admit_letter_coarse and unit_charpp_return are
  RED.
- Mutant A2, the native one-name receive admitting the whole letter (D-57 undone):
  unit_native_typed_receive is RED (exit 1).  Sonnet's unit_receive_letter_model stays green.

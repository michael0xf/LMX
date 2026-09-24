# Interpreted root: per-method trampolines (Opus, measure-first for -159 commit 1)

This is read-only preparation for -159 commit 1. It was measured on `e67c900` and follows `steps/root-walk-coverage.md`. Nothing in the code was changed.

The design, as fable decided it for plan §3:
- **One native entry.** There is a single uniform native entry, the prim ABI `LmxPrimitiveEntry (owner; refs; nargs; dest; out) int` (`lmx_primitive.h.lm1` :67).
- **A trampoline per method.** The translator emits one per method, with that ABI. It sets `node = owner\parent` and `self = owner`, reads `refs` as the typed cells the signature names, and calls `l2_mK` by its direct symbol. It writes the result through `dest`/`out` and returns a status only for the throw ABI.
- **Descriptors.** A method's descriptor `addr` points to its trampoline.
- **Native-to-native calls.** Direct native-to-native calls are unchanged.

## What a cell is

A cell is the address of the typed storage itself. `lmx_int_value_known(cell)` is `*(int*)cell` (`lmx_value_owned.lm1` :198–:203). The same holds for the char, size_t, unsigned, uchar, ulong, pointer and charptr accessors (`lmx_value_owned.h.lm1` :26–:47).

The walker's int values are such addresses:
- a literal is its graph int cell;
- a computed value lives in the caller's scratch cells or in a C int of the frame (`lmx_walk.lm1` :516–:570).

So a trampoline handles values like this:
- an int argument is read with `lmx_int_value_known(refs[i])`;
- a Structure argument is `(cast: (@: Lmx) refs[i])`;
- an int result is written with `lmx_int_store_known(dest, r)` followed by `\out: dest`;
- no result is `\out: 0`.

## Shapes

There are 297 methods other than E in the 215 generated files of the last full harness run. The most frequent shapes:

| ABI | result (arguments) | methods |
|---|---|---|
| value | `int ()` | 100 |
| value | `int (int)` | 33 |
| status | `int ()` | 29 |
| value | `int (@: Lmx)` | 14 |
| value | `int (@: int)` | 13 |
| status | `int (int)` | 9 |
| value | `@: void (const: @(L2TestAllocVTable), size_t)` | 9 |
| value | `int (int, int)` | 8 |
| value | `int (@: size_t)` | 8 |
| status | `size_t ()` | 8 |
| value | `size_t (@: Lmx)`, `int (size_t)` | 7 each |
| other | 29 shapes, 52 methods | 1–4 each |

**Batches:**
- **Slice 1** (K0 plus the value-ABI part of K1; 76 rows, of which 75 were in that run) has 147 methods.
  - The root calls five shapes, and their trampolines must work: value `int ()` 46, value `int (int)` 17, value `int (int, int)` 7, value `int (@: Lmx)` 4, value `void ()` 2. All of them take int or Structure arguments and return an int or nothing.
  - The other 86 methods, in 21 shapes, are called only from native code. They take pointer, size_t, unsigned, ulong, char or foreign-type parameters, return size_t, or use the throw ABI (9 of them).
  - The files also hold 5 `lmx_call0` sites (dynamic calls of a callable formal), all of value `int ()`.
- **Slice 2** (the 16 throw-ABI K1 rows) has 29 methods. The root calls one shape, status `int ()` (17 callees), and 12 methods are called only from native code.

## The trampoline per root-called shape

value `int (int, int)`. The other value shapes drop or change the reads:

```
fn: l2_mK_tr (@: void owner; @@: void refs; size_t: nargs; @: void dest; @@: void out) int
    @: Lmx self (cast: (@: Lmx) owner)
    if: self = 0 || nargs != 2U || refs = 0 || dest = 0 || out = 0
        return: <refusal status>
    lmx_int_store_known(dest, l2_mK(self\parent, self, lmx_int_value_known(refs[0]), lmx_int_value_known(refs[1])))
    \out: dest
    return: 0
```

- value `int (@: Lmx)` passes `(cast: (@: Lmx) refs[0])`.
- value `void ()` calls the method, then sets `\out: 0`.
- status `int ()`:

```
    int: v 0
    @: Lmx thrown 0
    int: st l2_mK(self\parent, self, 0, @ v, @ thrown)
    if: st != 0
        return: st
    lmx_int_store_known(dest, v)
    \out: dest
    return: 0
```

The thrown payload is dropped here, just as the entry adapter drops `l2_entry_throw` today.

## Facts for the kernel half (-158)

1. **The arity of a native callee.**
   - The walker takes a callee's arity from the ARG nodes in its body (`lmx_walk_arg_arity`, `lmx_walk.lm1` :497–:510). It refuses a call with a different argument count, both at prepare (:300) and at call (:542).
   - A native method's occurrence has no body nodes, so its arity reads 0, and every call with arguments to it is INVALID.
   - In slice 1, 19 of the 59 value-ABI K1 rows call a method with arguments from the root (28 callees). In slice 2 none do.
   - For `addr != 0` the count has to come from elsewhere: the trampoline's own `nargs` check, or `sig`.
2. **The throw status.**
   - `lmx_walk_prim` turns any nonzero status of its entry into `LMX_WALK_PRIMITIVE` (:626–:628), so the value is lost.
   - The driver checks `entry_rc = thrown` (`harness/l2_eternal_driver.lm1` :423/:426) and `running = 0` at close (:417).
   - Rows pinning it:
     - `Thrown = 1` (merge): `unit_s1_merge_uncaught`, `unit_s1_merge_profiles_uncaught`, `unit_s1_return_callable_throw_abi_fails`;
     - `Thrown = 2` (implements): `unit_s1_implements_uncaught`;
     - `Stopped = 1`: all four.
   - Today the entry adapter sets `l2_message\running: 0` and returns the status. Once the root is walked, the walk must hand the status to the turn, and the turn must stop the Message.
3. **The Message argument of the throw ABI.**
   - In the generated L1, `l2_msg` is only ever passed down to another throw-ABI call. No method body uses it otherwise.
   - At the top, the adapter passes its own `node`, and the driver asserts that it is 0 (:403, "the entry adapter's node is 0").
   - So a trampoline passes 0 for `l2_msg`, exactly as the adapter does today, and no Message accessor is needed.
4. **`lmx_call0`.**
   - Today it casts `addr` to `LmxCallEntrySelf (node, self)` and returns that int as the value (`lmx_call.lm1` :80–:97). With `addr` pointing to a trampoline, it calls the prim ABI with `nargs` 0 and a local int `dest`.
   - It has two kinds of caller:
     - `lmx_thread_dispatch_native` (`lmx_thread.lm1` :597), for the Message body occurrence; -156 routes `addr = 0` to the walker;
     - 6 generated sites in 4 files, all dynamic calls of a callable formal, nullary only. The emitter (`l2trans.lm1` :15130) refuses any other form with "incompatible entry signature".
   - For a throwing callable formal, the emitter assigns `lmx_call0`'s int to the status temp `l2_tsN` (:15124): that is the S1.2 remainder. The prim ABI's separate status and `dest` split the two apart.

## Translator sites for -159 commit 1

- **The method record.** `l2trans.lm1` :18902 emits `l2_entry_rec\addr: (cast: (LmxEntry) l2_mK)`, which becomes the trampoline symbol.
  - :18897 emits `(cast: (LmxEntry) 0)` for a bodiless `fn` (a descriptor-only interface). There, `addr = 0` stays and still means "no native entry".
  - With no op tree, the walker answers NOT_CALLABLE (`lmx_walk_enter` :982–:988), as it does today.
- **The dynamic call.** :15130 `lmx_call0(...)` follows `lmx_call0`'s new contract.
- **The trampolines themselves.** They are new: one for each method that has a body. E gets none, because the root is walked.
- **The function-pointer type.** `LmxEntry` is `fnptr: LmxEntry () void` (`lmx.h.lm1` :178). The record stores the trampoline through the same cast, and callers cast it to `LmxPrimitiveEntry`.

## Methods the root never calls

In slice 1, 86 methods in 21 shapes are never reached from the root or through `lmx_call0`. Their descriptors still need `addr != 0`, because `addr = 0` now means "interpret". Two readings are possible:
- **(a) A typed trampoline for every shape.** size_t, unsigned, ulong and char would go through their accessors. A pointer parameter such as `@: int` would be the reference itself, since a cell is the storage address. But the walker never produces one: `@x` at root is L2 and is refused.
- **(b) An explicit refusal.** Each such trampoline would return a status of its own for any shape the walker cannot supply.

No row of slice 1 exercises either reading, so the choice belongs to -159.

## Not covered here

The rest of -159 is out of scope for this note: emitting the root's op tree, the roles (`lmx_walk_roles_open`), `lmx_walk_prepare` before the turn, and the walker context. For those, see `steps/root-walk-coverage.md`.

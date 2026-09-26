# The next phase: what is open outside §4 merge, and what stands before the GATE (-195, k.1)

FABLE-OPUS-NEXT-PHASE-20260926-195 (Opus), k.1, read-only.  Base: main 4c42a31.
- The gate there: harness 376, build 270, L3 11.
- Sonnet's K1 has landed since then: main d877738.
- §4 merge is planned in -193/-194 and is left out here.

Sources:
- next_core_tasks.md: every `[ ]` item, with its line number;
- the harness rows, by class;
- steps/defects.md;
- measurements made on a translator built from 4c42a31: the refused statement of each root-pending
  row, the mixa corpus, and residue in the code.

What «the GATE» needs (next_core_tasks.md :760) is a CLEAN kernel and door:
- no name specials, scanners or dictionaries;
- no duplicate or dead paths;
- all gates green on one pushed commit.

It does not need every language feature.  §8 (self-build) needs the features.  Below, each item says
which of the two it blocks.

## 1. §2 (P0), §3 (the driver/harness and implements)

§2 P0 (:169–:186).  Every P0 fix is ticked.  Three items are open:
- :175, a rule rather than a task: do not settle an ambiguous nesting by a golden.  Nothing to do
  unless a fixture needs it.
- :185, drop `COLON` as a routing signal in `l1trans.lm1`.  This is L1 work.  It blocks nothing on
  L2's path; §8 needs it once L1 is migrated.
- :186, parity checks between the stable `l2src/`, `dev/l2src_sandbox` and the self-build mirrors.
  - This is real: the root `l2src/` twin is frozen and has drifted (its `tests/` copies,
    printTree D-12).
  - The GATE item «no contradictory docs/tests» needs a decision: gate its parity, or delete the
    twin.
  - GATE-blocking (small; a decision plus one commit).

§3 :263, the driver/harness: «`entry N` = the value of the walker's turn, fixtures migrated in
batches».
- The author's revision of 2026-09-24 superseded this item: the exit goes through the host root and
  the exit letter.
- -159 k.2b did it: 310 `return: V` tails became `sendMessage: exit(...)`, and `entry N` is the
  launch's exit code.
- What remains of it is the 50 root-pending rows (§4 here).
- Proposal: tick it with that pointer.  It is not a ticket of its own.

§3 :264, «implements after the §7 port: the methods under test are walked, a descriptor with
`addr = 0` over the body's op-tree».
- The wording is pre-k.4.  Today it reads: the method is walked through `native` = 0 over its op-tree
  (-193 T4, Q4 = always), with no switch.
- It depends on T4a and on the §7 port (§2 here).
- §8-blocking, not GATE-blocking.

The other open §3 items are mostly status notes of the model.  The ones with work in them:
- :212/:218/:219/:233: admission on every known assignment, the A1 audit.  This is the §7 port.
- :222: the check-order gap.  `u_struct\value` inside a compound expression, in a method checked
  before E.  Measured by -131, not fixed; translator.
- :240–:244: the P0/native/interpreter gates for `return` trailers and the bare `f` executing a named
  Structure.  Largely done by -139/-143.  The interpreter's parity rows come with T4.
- :274: the S1.2 leftovers, which are D-09.

## 2. §7 implements/admission and §7a the `c.*` door

§7 (:399–:418, :694–:697): the port from `lingvamyxa_prev` has NOT started.
- What exists: the intermediate admission of an untyped graph (S3 B2: `l2_emit_admit` →
  `lmx_runtime_implements`), and the walker's `lmx_walk_admit` / `admit_letter` PRIM (-180).
- Not ported:
  - the conversion table §2.2.3/§2.2.4;
  - `Consumer/uses`;
  - the receiving-expression admission.  The inner `T` of `T: []: []: x` is still unchecked.
- The fast paths still bypass admission: the identity/empty-uses and own/local/formal/primitive paths
  (:413, :415).
- The callable items (:694–:697) are -193 T5–T7.
- The root class «mixed numeric types (a conversion)» (2 rows) waits for the conversion table, as does
  Q24 = A (a declaration of another type converts).
- §8-blocking.  It is not strictly GATE-blocking, but the GATE's «no hidden fallback» covers the fast
  paths that bypass admission.

§7a, done:
- the `c.puts` specials removed;
- the L2 `c.array` declarator removed (-155);
- `sizeof:` as an operator;
- the raw door is transparent;
- the name-coded LmP0 types removed and `l2_is_known` made predef-only (-155);
- `l2_upper_name` removed (T1b);
- define constants passed as themselves (D-68).

§7a, open.  Measured on 4c42a31 unless marked:
- a. `<stdio.h>` (with stdlib/string) is still unconditional in the generated preamble (l2trans
  :21142).  Make it use-derived, or document it as a mapping rule.  GATE item, small.
- b. An L2 puts library without `c.`.  There is no such unit; callers use the raw `c.puts`.  §8 item.
- c. The scanners and dictionaries are still present, with these call counts:

  | Function | Calls |
  |---|---|
  | `l2_c_header_walk` | 2 |
  | `l2_c_header_chain_has` | 1 |
  | `l2_c_header_chain_has_typedef` | 1 |
  | `l2_predef_has_function` | 5 |
  | `l2_predef_has_type` | 3 |
  | `l2_predef_has_fnptr` | 2 |
  | `l2_foreign_intern` | 9 |
  | `l2_c_stmt_door` | 3 |

  - The plan says «DeepSeek owns deletion».  DeepSeek is not an active helper, so this needs an owner.
  - Proposed split:
    - The `l2_predef_*` readers look up DECLARATIONS in LMX headers (`.h.lm1` with `prototype:` /
      `struct:` / `define:`).  That is how a predef declares; T1b's `l2_define_name` is the same
      kind.  Keep them.
    - The `l2_c_header_*` readers scan plain C headers for typedefs.  That is the dictionary the norm
      forbids.  Remove them, and have C types spelled `c.Type`.
    - This needs an inventory first: which fixtures reach a type only through a C header.
  - GATE-blocking.
- d. L1 `c.array` (HOLD, the L1 backend's debt).  l2trans emits `c.array:` into the generated L1 at
  7 sites.  The plan counted 5; T1 added `l2_mpv`/`l2_mpp` beside `l2_mops`, the same scratch form.
  The GATE allows this as an explicitly owned blocker.

## 3. The 24 translates-with-debt rows

| Class | Rows | Nature | What lifts it |
|---|---|---|---|
| Form-parity pins, fnptr (batch C-76) | 14: `unit_discard_fnptr`, `unit_fnptr_decl_init`, `_call_compact/_colon/_vertical`, `_call_arg_compact/_colon`, `_call_sig_refuse`, `_noncallable_assign`, `_call_args_paren/_forms/_nullary_stmt/_nullary_value`, `unit_struct_decl_opp_fnptr_call` | Not debt: they pin that the three surface forms lower alike.  The foreign fnptr types come from test headers, and there is nothing to link | Nothing to lift.  Since D-68 the test headers compile, so they could go one step further to gcc (toolchain level); optional |
| Form-parity pins, raw field (batch A-72) | 2: `unit_rawfield_compact/_colon` | the same | the same |
| Form-parity pins, struct local (batch B-75) | 4: `unit_struct_decl_colon/_compact/_vertical`, `_opp_call` | the same | the same |
| Pins of a deletion | 1: `unit_bad_sizeof` (Absent = the removed `lm_own_*` injection) | Not debt | none |
| Prototype-only link | 1: `unit_define_actual` (D-68; its running twin is `unit_define_ccall`) | Not debt | none |
| **Real debt** | 1: `unit_admit_letter_formal` | D-60: a root merge copies the unit, which holds the letter, whose sender is the host's Message, KIND_NONE in the program's arena | Kernel: the receiver gets the sender's range, or the copier treats the sender as a terminal (Grok -185, paused; reassign) |
| **Real debt** | 1: `unit_s1_merge_uncaught_entry` | D-55: a kernel primitive's failure is `LMX_WALK_PRIMITIVE` (X1), not THROWN + k in the caller's numbering | Kernel (Grok -177 c5, paused; reassign) |

- The kind is overloaded: 22 of the 24 are pins, not debt.
- Proposal: a kind `translates` for «stops after l1trans by nature», which keeps `translates-with-debt`
  for real gaps (the 2).  Harness only; GATE item «no contradictory tests».

## 4. The 50 root-pending rows

Each row is refused at one statement: the first one the root builder cannot build.  «Kernel» means
the walker/kernel (Sonnet, or whoever takes Grok's paused tickets); «translator» means Opus.

| Class (needle) | Rows | What they stop at (examples) | What gives it |
|---|---|---|---|
| a Structure value | 9 | `R: merge: A B C`, `c: merge: Counts`, `copy: merge: Model` at the root | -193 K2 + T3 (a merge PRIM at the root with the pair map); kernel + translator |
| an array | 10 | `[]: char command 8` at the root, `length(m\mainArgs)` | -170 ELEM/ELEMPUT + length (Grok -170 k.2, paused), then the translator |
| throw and catch | 7 | `catch: Oops (int: x)` at the root | A walker CATCH role (PAD + a per-site k→pad table + landing; steps/root-walk-blocks-arrays.md), then the translator; its own ticket |
| a field path | 4 | `E\deep\d`, `Frozen\value` (eternal branches, F3: unit fields with parent 0), `bump\val` (a method-occurrence root), `Holder\viaPath(4U)` (a call through a path) | Translator root paths; the eternal ones need the kernel's G3 answer for parent-0 branches |
| a call with a non-number input | 4 | `ptr(@: v)`, `pokez(@: A\e)`, `grow(0, 0, 1)`, `copy_tail("abc", 2U)` | Addresses and string actuals at the root.  The walker has no pointer or address values.  Own ticket, or out of the walkable subset by rule (raw pointers are native) — an author call |
| a loop | 3 | `while: m != 0 && n < 5`, and `while: k < 10` inside S1 catch rows | `&&` in a condition (next row) and the catch role; no separate loop work |
| `&&` / `\|\|` | 2 | `if: a = 0 && m = 7`, `... != 41 \|\| ...` | Translator only: lower to IF (short-circuit by construction); no walker role needed |
| a call of a method with dynamic inputs | 3 | `inc()`, `beta()`, `gamma()` (21.3 dynamic inputs) | The walker has no dynamic inputs of 21.3; own ticket (kernel + translator) |
| mixed numeric types | 2 | `go(0U)` into an int formal, `get(a)` | The §7 conversion table, or a narrow numeric conversion step in the walker |
| an admission to a Structure type | 2 | `fresh()`, `S()` (a named Structure executed, its result admitted) | The walker's admit PRIM (-180) at a call result; translator, small |
| this expression | 1 | `if: test\[0]arg != 2` (an occurrence index at the root) | Translator root paths (with the field-path row) |
| a string or char literal | 1 | a bare `"text"` statement | Translator only: an inert statement, no step |
| a reference assignment | 1 | `E()` into an untyped reference | Kernel PUT_REF at the root plus the translator; small |
| a call whose result is not a number | 1 | `mptr() = 0` (a pointer result compared) | Same as addresses (the non-number input row) |

So: 9 + 10 + 7 = 26 rows ride on three kernel tickets (root merge, ELEM, CATCH).  About 10 are
translator-only: `&&`/`||`, the literal statement, the root paths and the occurrence index.  About 10
need an author call or their own ticket: addresses and pointers at the root, dynamic inputs,
conversions.  T4 itself flips none of them: it is method bodies, not the root.  It shares the builder,
so each root class that lands lands for method bodies too.

## 5. mixa → `c.NAME`: its form and size

First, a correction to my -193 §5.  «50 of its 54 `.lm2` are refused for unknown type» was measured
from the wrong working directory: the mixa predefs are relative to `dev/mixa_sandbox`.  Measured again
from there on 4c42a31:
- 1 of 54 translates;
- 53 are refused: 51 «unknown type», 1 «unsupported own array declaration», 1 «incompatible entry
  signature».

The unknown types are two kinds:
- `wchar_t`, which is a C type;
- mixa's own `Mixa*` Structures, 88 distinct type names in type positions (1099 uses).
  - 77 of mixa's 150 `.h.lm1` declare `struct: Mixa*`, and `l2_predef_file_has_type` does recurse
    through predef chains.
  - So WHY the lookup misses them is not measured yet.  Candidates: declarations inside `external:`,
    or a chain that goes through a plain C header.
  - That is the first measurement of a mixa ticket.

The constants: 914 uses (247 file/name pairs) of names no `define:` declares, which are C-only and
need `c.NAME`.  1172 uses of declared defines need nothing since T1b.

Form of the ticket:
1. Measure the type lookup miss, and fix it if it is the translator's.
2. C-only types and constants become `c.NAME`, mechanically, a file at a time, each file translated
   after its batch.
3. Then mixa's own semantic refusals.

Size: a ticket of its own, off the GATE path (§9: mixa builds after the self-build gate).

## 6. Open defects: an owner for each

| # | Status in defects.md | Measured now | Proposed owner |
|---|---|---|---|
| D-08 | OPEN, `l2_uses_is_control` dead | 0 references, gone | close (stale) |
| D-48 | OPEN, «duplicate declaration» | the refusal string is gone (Sonnet -166, Q24 = A) | close (stale), with the rows -166 added |
| D-09 | OPEN, library/throw-channel ABI | not re-measured | Opus (translator), after T4 |
| D-12 | OPEN, printTree example | still present, in both twins | fable: delete or rewrite, together with the l2src twin decision (§1 here) |
| D-17 | OPEN, infra | — | infrastructure |
| D-19 | OPEN, a negative literal in an eternal field | not re-measured | Sonnet or Opus, small, translator |
| D-20 | OPEN, a string literal as LmxCharArray | not re-measured | own ticket (translator + kernel); §8-blocking |
| D-23 | OPEN, `f(x: ())` | not re-measured | Opus, translator, small |
| D-24 | OPEN, address arithmetic | needs expression typing | later; with the root-address class |
| D-25 | CLOSED, recount 2026-09-26 (`steps/d25-fixtures.md`) | 14 named: 7 deleted in `298ef1e`, 7 still registered | — |
| D-27 | OPEN, `\[N]x` crash on a twice-assigned local | not re-measured | Opus, translator |
| D-33 | measured, reading past a Structure | the static bound is still absent | Opus, translator (a static bound on `node\x`) |
| D-36 | OPEN, `lmx_call_install_walk` global | 7 references | Sonnet, with G-call (-194) |
| D-39 | OPEN, a dynamic own-array index | refusal still present (3 sites) | Opus or Sonnet, translator; with ELEM |
| D-53 | OPEN, `@mo` double indirection | not re-measured | Opus, translator |
| D-60 | OPEN, the sender range | — | kernel (Grok -185 paused → Sonnet) |
| D-62 | OPEN, `sendMessage: Ref` to a non-Thread | — | kernel |
| D-65 | OPEN, test flake | — | Sonnet |
| D-67 | OPEN, pool chunk growth | — | Sonnet (kernel), small |

## 7. Proposed order of the next tickets

Today: Sonnet is on -194 (K1 landed; then merge-into, G-call, K-OT1/K-OT2); Grok is paused;
Opus is free for T2.

| # | Ticket | Who | Needs | Gives |
|---|---|---|---|---|
| 1 | -193 T2: body pairs and pairs into earlier-appended slots (lift T1's two K1 refusals) | Opus | K1 (landed) | the rest of the data merge |
| 2 | -194 k.3–k.5: K-OT1, K-OT2, G-call, and K2 (the root merge PRIM with the pair map) | Sonnet | K1 | T3, T4a |
| 3 | -193 T3: merge at the walked root | Opus | K2 | 9 root-pending rows |
| 4 | -193 T4a/T4b: op-trees for walkable method bodies, plus the native-vs-walked differential run | Opus | K-OT1/K-OT2, G-call | T5; implements after §7 |
| 5 | Root classes, translator-only: `&&`/`\|\|` to IF, the bare literal statement, root paths and the occurrence index, admission of a call result | Opus | — (can run beside 2) | about 10 rows |
| 6 | Arrays at the root: ELEM/ELEMPUT + length, then the translator (-170, reassigned) | kernel owner, then Opus | — | 10 rows (and D-39) |
| 7 | The catch role at the root (walker CATCH + translator) | kernel owner, then Opus | — | 7 rows (+2 loop rows) |
| 8 | GATE cleanup | Opus (translator/harness) + fable (docs) | — | the GATE's cleanliness items |

Ticket 8 covers:
- §7a (c): split the scanners, removing the C-header ones after an inventory;
- §7a (a): stdio use-derived or documented;
- the stale defect rows (D-08, D-48);
- the l2src-twin decision and D-12;
- the `translates` harness kind;
- an inventory of dead helpers.

After these: -193 T5–T7 (callable merge by parts, PAP, makeAdder, the converter; after K3).  Then the
§7 implements port, which is large and comes after the callable parts, since a callable's `implements`
is by parts.  These are §8-blocking.

Before the GATE, on the kernel side: §1, `VoidArray`.  It is not started: the kernel has 123 lines of
`LmxArrayDesc` in 21 files and 0 of `VoidArray`, and the `Lmx` layout now also carries `native`
(c4).  The plan puts this one-writer kernel migration BEFORE the GATE («the kernel's representation
is fixed before self-build»).  It needs its own ticket and an author check that `{VoidArray array;
Lmx *parent}` still holds now that `native` exists.

Questions for fable:
- Q7: should the root-address class (`@:` actuals, pointer results, strings at the root) be in the
  walkable subset at all, or refused by rule, since raw pointers are native?  This is an author call.
- Q8: the l2src twin: gate its parity, or delete it?
- Q9: `VoidArray` with `native`: is the layout `{VoidArray array; Lmx *parent; LmxEntry native}`?
  This is an author check before the §1 ticket.

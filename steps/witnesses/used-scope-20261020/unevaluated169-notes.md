# Unevaluated169: C sizeof keeps its operand unevaluated, not C-door closure

Opus is the sole writer/build (to_opus.md, 5a52eddc). All work is under
`build2`; the old root `build` and the protected basenames are not accessed.
The source is the frozen168 closure plus the U0 delta in two inputs,
`l2trans.lm1` and `l2_application.h.lm1`, and the application header generated
from the latter. This is not a promotion into public `dev` and not completion
of kernel/self-build/mail.

## The contract

L2 section 20: `c.sizeof` means C `sizeof`. C99 6.5.3.4p2: its operand is not
evaluated (unless it is a variable length array type). L2 section 17: machine
types keep the numeric semantics of the corresponding C99 types. The common
foreign C-door adapter evaluated `c.sizeof` actuals like any foreign call: it
emitted their calls and loads as statements, boxed int/char values into an int
temporary (so `c.sizeof(ch)` of a char gave 4), published dirty own fields as
before a foreign call, and CHECK recorded the obligations of a call in it.

`c.sizeof` is classified after the common preparation like every receiver
(role 5 next to bare `sizeof`, role 4); a selected L2 application keeps its own
signature. This is a receiver contract, not a C-name registry: every other
`c.*` head keeps the uniform door (Codex ruling OPUS-CODEX-20261022-CDOOR-01).
CHECK, native, retained COUNT/EMIT and the M2 may-write summary read one
projection of the SAME prepared operand:

- CHECK checks the operand as a value -- names, paths, INDEX, conversions,
  operators, calls and their actuals must be valid -- in an unevaluated
  context. A call there never runs, so it records no call edge, throw
  obligation, hidden-input demand, held-call obligation or conversion edge,
  and no actual reaches a formal: no callable class (K04 CFL), merge site or
  constructor (T7), admission site, D-105 source or receiving fact. The
  context is part of every saved source site (`L2SourceSite`), so a deferred
  check and a use-site check replay in it. Bare `sizeof` value operands are
  checked in the same context.
- Native writes C's operator over the operand and nothing else (a guard turns
  any write to the output into an internal error). A part with a C spelling
  keeps it: a binding, a machine INDEX chain, an opaque C member path, a
  literal (a triple-quoted text too), a C word, an operator, a cast, a nested
  `c.sizeof`. An L2 part with no C spelling (an L2 call, a graph path, a
  language Array INDEX) is the UNEVALUATED typed witness `*((T *)0)` of its
  prepared type, through the common L1 pointer formatter. A by-value C member
  is spelled through its root's address, `(&x)->m`: L1 splits a dotted call
  argument even in parentheses. Inside a C call nested in the operand a macro
  may evaluate a part, so a part without a C spelling is a located OPEN
  refusal there.
- A number in an arithmetic group (`+ - * / %`) of the operand has the
  group's L2 type, as when the group is evaluated (unsigned beside an
  unsigned, int beside an int), not the type C gives the bare constant:
  `c.sizeof(u + 3000000000)` is `sizeof(u)`. A comparison or logical group is
  an int either way and keeps the constant as written.
- No publication precedes `c.sizeof`: control does not pass to another
  callable (semantics, publication boundary, origin 21.6).
- Retained COUNT/EMIT keep the operand as inert source (`l2_rw_inert_value`),
  not machine values; bare `sizeof` value operands too. A retained source
  number its primitive cell cannot hold (an int literal beyond the int range,
  an unsigned one beyond 32 bits or negative) keeps its written spelling as a
  symbolic leaf: a source cell never narrows what the program wrote.
- M2 skips the operand: no call in it is an edge.

## Evidence and boundaries

- `unevaluated-test.c` (source-linked, ten forms: machine INDEX nested,
  group, cast, nested `c.sizeof`, binding, sign, address of a machine element,
  a C type word, a logical group, a nested C call): after owner release and
  name/FT poison CHECK/native/COUNT/EMIT have zero parser/root/fold/raw
  retries; native writes zero bytes, no temporary, no temporary number, no
  publication and enters the native emitter once; COUNT=EMIT with no retained
  machine value. The SAME behavioural oracles over parent168 fail: 20 of 60,
  every form's native and retained check (statements, boxing temporaries,
  publications, retained machine values).
- Programs, eight strictO2 production/observed root0/1 runs each:
  `unevaluated-values` (every position: initializer, assignment, statement,
  condition, arithmetic, machine and language INDEX, cast, nested, a logical
  group, an own char of one byte, a big literal beside an unsigned and the
  int minimum beside an int, a triple-quoted text and a C call over it),
  `unevaluated-obligations` (a declared throw and a hidden input inside
  `c.sizeof` and `sizeof`), `unevaluated-deferred` (a call check deferred
  inside `c.sizeof` replays unevaluated), `unevaluated-opaque` (an opaque C
  aggregate, its member, C calls), `unevaluated-callable-class` (a merge
  actual of a call inside `c.sizeof` adds no class to the callee's formal),
  `unevaluated-callable-input` (a method named inside `c.sizeof` does not
  reach the formal, so its free name is asked of no caller),
  `unevaluated-receiver` (a reference inside `c.sizeof` is received by no
  formal) and the historical counterexample `machine-unevaluated-open` (now
  7, touches 0). `unevaluated-entry` holds the forms at the entry: a root with
  any `c.*` operation is walker-UNSUPPORTED, so its four native-root runs are
  positive and its walkroot runs are not counted. Methods with `c.*` stay
  native-only; the forced body counts are the walked methods outside them.
- Shapes: each of the three flow programs against the SAME program with the
  operand replaced by `c.sizeof(c.int)`, native and forced: method headers,
  merge-site constructors and the receiving facts (`L2_PATH_FACTS`, without
  pointers) are equal on current169. On parent168 every pair differs: the
  callable programs are refused ("a call through a callable formal that
  receives a callable built at run time among callables formed differently
  is not built yet", "unbound dynamic input zz") and the reference is
  received by `reads`.
- Parent168 observations of the SAME programs stay OPEN: eager evaluation
  (touches 1), refusals of a call that never runs ("unhandled throw", the two
  callable refusals above), the dotted member split.
- Negative mutants on isolated copies of the final source, each reddening a
  named witness while the real frontend keeps every witness green: M1 drops
  the CHECK context of `c.sizeof` (obligation/entry/deferred refused), M2
  drops it from the saved source site (deferred refused), M3 records the
  merge class (callable-class refused), M4 lets a method reach the formal
  (callable-input headers differ), M5 builds the merge site (callable-class
  shape differs: two dead constructors), M6 records the receiving
  (receiver shape differs), M7 leaves literals with C's constant type (the
  values program returns 80 at run time), M8 narrows the retained literal
  (`3000000000` stored in an int cell instead of a symbol).
- Builds: frontend-01 is the first candidate; its own witness passed, but the
  opaque program then failed to compile (a dotted C member split by L1) and
  deferred checks kept the context only for two call kinds. Frontend-02 spells
  the member through its root's address and carries the context in every saved
  source site; frontend-03 changes only two L1 comments (C byte-identical to
  02). A review of frontend-03 (check, role, native and retained lenses)
  confirmed four defects: callable-flow facts of an unevaluated call (cf5,
  cf2), a big literal narrowed in the retained source, a refused triple-quoted
  text, and literal typing in groups. Frontend-04 gates the flow facts and the
  merge site and keeps big literals as symbols; 05 accepts triple quotes (its
  site-based typing was reverted: inert operands record no sites); 06 casts a
  group literal through own-type codes, which miss unsigned; 07 casts it
  through the primitive code names and excludes void and comparison groups.
  The review's arity finding is design (C judges it) and is OPEN below. All
  counted evidence is frontend-07's.
- A whole language Array operand is its reference cell's C type, `void *`
  (implementation notes). Parent168 loaded and null-checked the descriptor
  first (an evaluation, with a bail) and measured that `LmxArray *`: the same
  size here, not a language rule.
- Controls: all 44 sandbox fixtures that use `sizeof`, both tiers, native and
  forced, against their harness rows. No translation or runtime regression;
  shared refusals keep their text; the shared walkroot UNSUPPORTED rows stay
  OPEN. Every changed L1 line of the 16 changed pairs is a removed publication
  block, an inert retained operand or a removed boxing temporary
  (`classify-l1.py`). Eleven negative pairs: each `c.sizeof` form is refused
  as its evaluated twin is (void call, text and unconverted INDEX, mixed
  numeric types, operators, an unknown name, a scalar member, a scalar
  dereference, an address of a call): the unevaluated context hides no invalid
  operand. Corpus 85 units: the same values and native eligibility, the same 8
  baseline RED.

Open: other `c.*` heads keep eager actuals, and C macros receiving eager L2
actuals stay with the author (P4); VLA/variably modified bounds; an L2 part
inside a nested C call; the eager adapter's dotted member split in evaluated
`c.*` actuals (same on both tiers); the arity of `c.sizeof` is judged by C (an
empty or comma operand list reaches gcc); a literal in a comparison or logical
group keeps C's constant type; planning facts and the status-ABI scans
(`l2_body_throws`) still read inside the operand; the result type of
`c.sizeof` stays unknown and conditions keep int temporaries. The harness row
`unit_csizeof_operand_lowered` pins the eager temporary (`Debt return:
c.sizeof(l2_t`) and must flip, with this citation, at dev promotion. No C-door
closure is claimed.

# JVM / L3 Path B ? ABI + expression printer

## Runtime ABI (`lmx/`)

`LmxOccurrence`: `node` = lexical parent; no reparent-on-store; two-phase identity-map merge (52B). Keep unchanged.

## Expression / callable printer (`graph/` + `printer/`)

Physical roles (`graph.L3Role`, identity `==` only):

- `CALLABLE`, `RETURN`, `SUBJECT_REF`, `INT_LITERAL`, `FIELD_FOLLOW` (index in `intPayload`), `ADD`, `UNSUPPORTED` (reject)

Fixture `L3ExprFixture.callableAddField0Plus5()` = `return subject[0] + 5`.

Printer emits `lmx/gen/PrintedL3Expr.eval(LmxOccurrence)I` from the graph (not Java source, not CHECK_* selftest bodies).

### ASM pin (not committed)

| | |
|---|---|
| URL | https://repo1.maven.org/maven2/org/ow2/asm/asm/9.7.1/asm-9.7.1.jar |
| Version | 9.7.1 |
| SHA-256 | `8cadd43ac5eb6d09de05faecca38b917a040bb9139c7edeb4cc81c740b713281` |
| Path | `build/vm_jvm/asm-9.7.1.jar` |

### Commands

```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

Expect: see `steps/vm-jvm-l3-smoke.md` for current check counts.

## CALL (Path B slice 55B)

- Role `L3Role.CALL`: child[0] is a **physical** `L3Node` reference to a `CALLABLE` (object identity); remaining children are argument expressions (this slice: one `SUBJECT_REF`).
- Printer collects reachable callables with a deterministic preorder IdentityHashMap (`c0` = entry, then callees as CALL edges are seen). One JVM static method per reachable callable; `eval` aliases `c0`.
- No language-level name/text lookup for callees or method ids.
- Unsupported arity / non-CALLABLE callee / unsupported roles reject **before** class bytes.
- Unreachable CALLABLE (orphan not linked from entry) is **not** emitted.
- Recursion: self/mutual CALL via physical CALLABLE identity (seal-once shells).

Fixture: entry `return CALL(leaf, subject) + 5` where leaf is `return subject[0]`.

## IF (Path B slice 56B)

- Role `L3Role.IF`: children are condition, then, else (arity 3).
- Condition is an int expression (zero = false, nonzero = true). Emit `IFEQ` / `GOTO`; exactly one branch runs.
- Nested physical `CALL` allowed in either branch; reachability walk visits IF children.
- Malformed arity and non-int conditions (`SUBJECT_REF` alone, `UNSUPPORTED`) rejected before class bytes.
- Untaken branch is not evaluated (smoke: CHECKCAST-failing field follow in untaken arm).
- WHILE deferred (later landed). Recursion: see RECURSIVE-CALL below.

## ARG / CALL args (Path B slice 57B)

- Role `L3Role.ARG`: `intPayload` is the compile-time parameter index (0 = subject `LmxOccurrence` local; 1.. = int locals). No name/text lookup.
- Callable arity = `max(1, max ARG index + 1)` from that callable's body only (CALL callees excluded from the scan).
- JVM descriptor fixed per callable: `(LmxOccurrence;I*)I`. CALL sites must pass exactly that many args; args evaluated once left-to-right.
- `L3Role.PROBE` (smoke): `ArgEvalCounter.tick()` for exactly-once evaluation order.
- No varargs. IF and reachable-only emission preserved. Recursion: see below.
## Locals / SEQUENCE (Path B slice 58B)

- SEQUENCE: evaluate children left-to-right; yield the last int.
- LOCAL_SET / LOCAL_GET: compile-time slot index; JVM local = arity + slot (after subject/args). Per CALL activation; no TLS/shared array/name table.
- Slot count from LOCAL_SET indices only. Definite assignment rejects uninitialized LOCAL_GET. Negative / out-of-range / malformed arity rejected before class bytes.
- Reference locals still deferred. Int-only boundary kept. Recursion: see below.
## WHILE (Path B slice 59B)

- Pre-test WHILE: children condition, body. Int condition (zero=false); ordinary JVM back-edge; no fuel cap.
- Statement only: valid solely as a **non-final** SEQUENCE child (no invented int result). Rejected in value/final-expression context before class bytes.
- UNTIL / FOR still deferred. BREAK/CONTINUE: see below. Recursion: see below.
## BREAK / CONTINUE (Path B slice 60B)

- Statement-only BREAK / CONTINUE for the **nearest** active WHILE via an explicit compile-time loop-label stack (no named labels).
- BREAK → loop exit; CONTINUE → condition recheck. Rejected outside a loop or in value/final-expression context before class bytes.
- Stmt-position IF may carry BREAK/CONTINUE in a branch. REDO/RETRY/cleanup/finally/UNTIL/FOR deferred.

## Nested RETURN (Path B slice NESTED-RETURN / 87)

- Nested `L3Role.RETURN` under SEQUENCE / IF / WHILE exits the **nearest current CALLABLE** via JVM `IRETURN` (not merely the loop).
- Return expression evaluated exactly once; statements/probes after a taken RETURN do not run.
- RETURN inside a callee exits only that callee; caller continues and receives the value.
- BREAK/CONTINUE remain nearest-WHILE only and cannot cross a CALL boundary (callee BREAK does not affect caller loops).
- CALLABLE body remains a single root RETURN wrapper; nested RETURNs appear inside its expression tree.
- Malformed arity / non-int value / CALLABLE body without RETURN rejected before class bytes.
- No graph/callable copy; physical `L3Role` identity only; no hidden global return slot.

## Recursive / mutual CALL (Path B slice RECURSIVE-CALL / 88)

- Self and mutually recursive `CALL` through **physical** `L3Node` CALLABLE identity only (no numeric/runtime names).
- Seal-once construction: `L3Node.unsealedCallable()` + `seal(RETURN body)` exactly once; double-seal / use-unsealed → rejected before emission. After seal, child array is frozen (see SEAL-FREEZE-CHILDREN).
- Printer walk: IdentityHashMap of CALLABLEs; if already mapped, return immediately (reference edge ≠ owned-tree) so cycles terminate.
- Self-CALL emits the same `INVOKESTATIC` to the mapped method index as any other CALL; fresh args/locals per JVM activation; subject identity preserved.
- Nested RETURN (slice 87) still exits the nearest activation only; CALLABLE still requires a single root RETURN wrapper.
- Unreachable CALLABLE not emitted. Malformed owned CALLABLE-as-value cycle / arity mismatch / non-CALLABLE target rejected before class loading.
- No arbitrary depth cap (JVM stack); no hidden global current-callable state.

## Seal-freeze children (Path B slice SEAL-FREEZE-CHILDREN / 90)

- Sealed `L3Node` has **no public writable children array**; children are private.
- Accessors: `childCount()` + `child(int)` return physical `L3Node` refs (printer hot path).
- Constructor varargs and successful `seal` replace children with a defensive copy so caller aliases cannot mutate count/content after construction/seal.
- Failed `seal` (null / non-RETURN) leaves the shell **unsealed** with no partial child stuck; a later valid seal may still succeed once. Double-seal rejected.
- Physical CALL target identity and legal self/mutual recursion unchanged. No ownership-cycle guard in this slice.

## Ownership-cycle guard (GROK-BOT-JVM-L3-OWNERSHIP-CYCLE-GUARD-20260921-91)

Illegal structural/ownership cycles among non-CALLABLE expression nodes are rejected with an identity gray/black DFS before bytecode emission (IllegalArgumentException naming the role category). Shared acyclic DAG data remains legal. CALLABLE reference edges (self/mutual recursion) stay non-ownership and terminate without cycle failure. No recursion-depth cap, graph copy, or global/TLS ownership state.

## Unlabelled REDO (GROK-BOT-JVM-L3-WHILE-REDO-20260921-93)

`L3Role.REDO` repeats the nearest active WHILE body without rechecking the condition (semantics §12). Loop-label frame is `{cond, break, body}`; CONTINUE→cond, BREAK→exit, REDO→body. Statement-only; cannot cross CALL. RETRY/labels deferred.

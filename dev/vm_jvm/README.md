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

Expect: `PASS ExprSmokeDriver checks=7 failures=0` and `PASS HelloStructureSmoke checks=25 failures=0`.

## CALL (Path B slice 55B)

- Role `L3Role.CALL`: child[0] is a **physical** `L3Node` reference to a `CALLABLE` (object identity); remaining children are argument expressions (this slice: one `SUBJECT_REF`).
- Printer collects reachable callables with a deterministic preorder IdentityHashMap (`c0` = entry, then callees as CALL edges are seen). One JVM static method per reachable callable; `eval` aliases `c0`.
- No language-level name/text lookup for callees or method ids.
- Unsupported arity / non-CALLABLE callee / unsupported roles reject **before** class bytes.
- Unreachable CALLABLE (orphan not linked from entry) is **not** emitted.
- Recursion: deferred (self-CALL rejected with clear error).

Fixture: entry `return CALL(leaf, subject) + 5` where leaf is `return subject[0]`.

## IF (Path B slice 56B)

- Role `L3Role.IF`: children are condition, then, else (arity 3).
- Condition is an int expression (zero = false, nonzero = true). Emit `IFEQ` / `GOTO`; exactly one branch runs.
- Nested physical `CALL` allowed in either branch; reachability walk visits IF children.
- Malformed arity and non-int conditions (`SUBJECT_REF` alone, `UNSUPPORTED`) rejected before class bytes.
- Untaken branch is not evaluated (smoke: CHECKCAST-failing field follow in untaken arm).
- WHILE deferred. Recursion still deferred.

## ARG / CALL args (Path B slice 57B)

- Role `L3Role.ARG`: `intPayload` is the compile-time parameter index (0 = subject `LmxOccurrence` local; 1.. = int locals). No name/text lookup.
- Callable arity = `max(1, max ARG index + 1)` from that callable's body only (CALL callees excluded from the scan).
- JVM descriptor fixed per callable: `(LmxOccurrence;I*)I`. CALL sites must pass exactly that many args; args evaluated once left-to-right.
- `L3Role.PROBE` (smoke): `ArgEvalCounter.tick()` for exactly-once evaluation order.
- No varargs, no WHILE, no recursion. IF and reachable-only emission preserved.

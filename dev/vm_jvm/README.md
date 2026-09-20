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

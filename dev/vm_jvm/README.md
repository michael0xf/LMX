# JVM / L3 Path B ? ABI + first classfile printer

## Runtime ABI (`lmx/`)

See prior fixes 51B/52B: `node` = parent; no reparent-on-store; two-phase merge copy.

## L3 ? classfile printer (`graph/` + `printer/`)

In-memory L3 fixture (`graph.L3SmokeFixture`) with **physical** `L3Role` singletons (identity `==`, no runtime text lookup).
`printer.L3ClassfilePrinter` emits `lmx/gen/PrintedL3Smoke` via ASM; `PrinterDriver` writes, loads, runs it.

### ASM pin (ignored under `build/vm_jvm/`, not committed)

| Field | Value |
|---|---|
| URL | https://repo1.maven.org/maven2/org/ow2/asm/asm/9.7.1/asm-9.7.1.jar |
| Version | 9.7.1 |
| SHA-256 | `8cadd43ac5eb6d09de05faecca38b917a040bb9139c7edeb4cc81c740b713281` |

### Build / run

```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.PrinterDriver
```

Expect: `PASS PrintedL3Smoke checks=7 failures=0` (exit 0).

Smoke covers: integer, void step, independent node, nested node, bounds, field-follow, bounded merge.

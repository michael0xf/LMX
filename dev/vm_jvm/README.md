# JVM / L3 Path B ? bounded first slice (`GROK-BOT-JVM-L3-20260920-50B`)

Isolated from native `dev/l3_interp` and from Path A C99 VMs.

## Inventory (no system install this ticket)

| Tool | Status |
|---|---|
| Host JDK | **Liberica OpenJDK 11.0.15.1** at `C:\jdk\liberica-11.0.15.1` (`JAVA_HOME`); `java`/`javac` on PATH |
| WSL JDK | absent |
| ASM / BCEL | **not present** in tree; not downloaded this slice (`javac` enough for runtime ABI smoke) |
| Relocatable Temurin (`include_openjdk.txt`) | not required while Liberica already runs smokes |

## L3 ? classfile printer boundary

**Exact blocker for emission:** there is **no** L3 input `hello.lm3`, and **no** L3?JVM classfile printer in `l1trans` / repo (plan item 4 requires a new L3 printer; do not emit classfiles from Translator-L1). `steps/vm-porting.md` still queues items 4?7 after L3 interface agreement.

This slice delivers the **runtime ABI smoke** (plan ?4 process step 3 runtime library), not `hello.lm3` compilation.

## Minimal JVM ABI

See `lmx/LmxOccurrence.java`:

- Occurrence = one Java object; physical reference equivalence = `==`
- `{node, len, data}`: `Kind node`, fixed `len()`, mutable `data[i]` via `setChild` / `child`
- `merge(...)` ? **new** STRUCTURE root, forward copy, operands unchanged
- Bounds checks on every index access

## Smallest L3 subset (smoke only)

Included: Structure construction, index field-follow, merge-copy, occurrence identity, bounds.
Excluded: `c.*`, L2-only / machine ops, Message FIFO, Mix, interpreter dispatch, named `[0]name` selection (deferred).

## Build / run

```
javac -d dev/vm_jvm/out dev/vm_jvm/lmx/LmxOccurrence.java dev/vm_jvm/smoke/HelloStructureSmoke.java
java -cp dev/vm_jvm/out smoke.HelloStructureSmoke
```

Expect: `PASS HelloStructureSmoke checks=4 failures=0` (exit 0).

Keep `dev/vm_jvm/out/` untracked.

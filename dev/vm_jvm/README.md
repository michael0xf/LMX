# JVM / L3 Path B ? isolated Lmx ABI (`dev/vm_jvm`)

Latest correction: `GROK-BOT-JVM-NODE-FIX-20260920-52B`.

## Rules

- `{node, len, data}` with **`node` = lexical parent** (`null` = independent)
- **Storing a reference in `data` does not reparent** (?8). Use `nested(parent, ?)` for explicit nesting
- **Bounded `merge`**: two-phase identity map ? allocate shells (data graph + `node` ancestors), then `dst.node = map(src.node)` (never the data-slot container). Hidden ancestors are copied but not result fields. Result root `node == null` (isolated expression; not a full merge entrypoint with expression-location parent)
- `LmxTerminal` shared by identity under merge

## Build / run

```
javac -d dev/vm_jvm/out \
  dev/vm_jvm/lmx/LmxOccurrence.java \
  dev/vm_jvm/lmx/LmxTerminal.java \
  dev/vm_jvm/smoke/HelloStructureSmoke.java
java -cp dev/vm_jvm/out smoke.HelloStructureSmoke
```

Expect: `PASS HelloStructureSmoke checks=25 failures=0`

# JVM / L3 Path B ? isolated Lmx ABI (`dev/vm_jvm`)

Corrected under `GROK-BOT-JVM-FIX-20260920-51B` (supersedes the Kind-as-node mistake in `69dce94`).

## Inventory

| Tool | Status |
|---|---|
| Host Liberica OpenJDK 11.0.15.1 | used for `javac`/`java` |
| ASM / BCEL | not required for this ABI slice |
| L3?classfile printer / `hello.lm3` | still absent (emission blocker unchanged) |

## ABI

`lmx/LmxOccurrence.java`:

- `{node, len, data}` ? **`node` = lexical parent occurrence** (`null` = independent / `node = 0`), not a kind tag
- `independent(...)` / `nested(parent, ...)` construction; nested children bind `node` to their container (alias-preserving)
- `merge` ? graph copy with `IdentityHashMap` (shared mutable ? one copy; `node` rewritten into copy; operands unchanged)
- `lmx/LmxTerminal.java` ? admitted terminal retained by identity under merge (?19 / ?22)

Cites: `docs/LMX_semantics.en.md` ?3, ?8, ?9, ?19, ?22. Merge root `node` is `null` here as an isolated expression (zero parent); full ?parent follows merge expression location? needs an expression frame when a printer exists.

## Smoke

```
javac -d dev/vm_jvm/out \
  dev/vm_jvm/lmx/LmxOccurrence.java \
  dev/vm_jvm/lmx/LmxTerminal.java \
  dev/vm_jvm/smoke/HelloStructureSmoke.java
java -cp dev/vm_jvm/out smoke.HelloStructureSmoke
```

Expect: `PASS HelloStructureSmoke checks=26 failures=0` (exit 0).

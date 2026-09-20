# JVM / L3 Path B first slice (`GROK-BOT-JVM-L3-20260920-50B`)

- request_id: `GROK-BOT-JVM-L3-20260920-50B`
- author: Grok Bot
- utc: 2026-09-20T22:30:00Z
- tree HEAD: `4c68130`
- scope: new `dev/vm_jvm/**` + this report. No edits to `dev/l3_interp`, `lmx_walk`/plan/scratch, l2trans eternal emission, manager, LOCKED/OWNED, watchers.

## Inventory

| Tool | Result |
|---|---|
| Host Liberica OpenJDK | 11.0.15.1 at `C:\jdk\liberica-11.0.15.1` ? used |
| WSL java/javac | absent |
| ASM / BCEL in tree | absent ? not fetched; `javac` sufficient for ABI smoke |
| System package install | none |

## Printer boundary (emission blocker)

No `hello.lm3` in tree. No L3?JVM classfile printer in `l1trans` (plan forbids classfile emission from Translator-L1; item 4 needs a dedicated L3 printer). Documented in `dev/vm_jvm/README.md`.

## Delivered: runtime ABI + Structure smoke

| Path | Role |
|---|---|
| `dev/vm_jvm/lmx/LmxOccurrence.java` | `{node,len,data}` ABI: fixed len, bounds, merge-new-root, `==` identity |
| `dev/vm_jvm/smoke/HelloStructureSmoke.java` | Structure / assign / bounds / merge / identity |
| `dev/vm_jvm/README.md` | inventory, subset, commands |

L3 subset: Structure, index field-follow, merge, identity, bounds. Excludes `c.*` and L2-only ops.

## Commands / exits

```
javac -d dev/vm_jvm/out dev/vm_jvm/lmx/LmxOccurrence.java \
  dev/vm_jvm/smoke/HelloStructureSmoke.java
# exit 0

java -cp dev/vm_jvm/out smoke.HelloStructureSmoke
# exit 0
# PASS HelloStructureSmoke checks=4 failures=0
```

## Verdict

**PASS (runtime ABI smoke)** with **documented emission blocker** (no L3 printer / no `hello.lm3`). Next when authorized: fetch ASM + define L3 printer boundary / `hello.lm3` ? not started here.

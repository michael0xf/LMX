# JVM / L3 Path B ABI smoke

- `GROK-BOT-JVM-L3-20260920-50B` / `51B` / **`52B`**
- HEAD at draft: `72fe8a9`

## 52B fix

Removed `bindNestedParents` / reparent-on-store. Two-phase copy: `dst.node = map(src.node)`.

| Test | Proves |
|---|---|
| store does not reparent | `A.node` stays `P` when `H` stores `A` |
| unrelated holder copy | `A_copy.node == P_copy`, not merge root / `H` |
| hidden lexical ancestor | `P_copy` not a result field |
| back-edge cycle | self-ref preserved in copy |
| repeated alias | one copy |
| operands unchanged | sources intact |

```
javac ? ? exit 0
java ? ? exit 0
PASS HelloStructureSmoke checks=25 failures=0
```

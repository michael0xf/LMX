# JVM / L3 Path B ABI smoke

- requests: `GROK-BOT-JVM-L3-20260920-50B` (initial), `GROK-BOT-JVM-FIX-20260920-51B` (ABI correction)
- author: Grok Bot
- tree at report refresh: `69dce94` (see latest commit for fix)

## Fix (51B)

`69dce94` stored `Kind` in `node` and used shallow merge ? **rejected**. New commit redesigns:

| Requirement | Evidence in smoke |
|---|---|
| independent `node == null` | `testIndependentNodeNull` |
| nested `node` exact parent | `testNestedNodeExactParent` |
| mutable descendants copied | `testMutableDescendantsCopied` |
| repeated mutable ref copied once | `testRepeatedMutableCopiedOnce` |
| copied `node` links in copied graph | `testCopiedNodeLinksInCopiedGraph` |
| admitted terminal identity shared | `testAdmittedTerminalShared` |
| operands unchanged | `testOperandsUnchanged` |
| bounds | `testBounds` |

## Commands / exits (51B)

```
javac -d dev/vm_jvm/out ? ? exit 0
java -cp dev/vm_jvm/out smoke.HelloStructureSmoke ? exit 0
PASS HelloStructureSmoke checks=26 failures=0
```

No history rewrite of `69dce94`. No edits to `l3_interp` / `lmx_walk` / printer.

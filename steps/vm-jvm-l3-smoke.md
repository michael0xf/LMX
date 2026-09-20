# JVM / L3 Path B smoke

- ABI: 50B?52B; printer CHECK_*: 53B; **expression callable: `GROK-BOT-JVM-L3-EXPR-20260920-54B`**

## 54B

Replaced CHECK_* lowering with expression roles. Emitted method from graph: `PrintedL3Expr.eval(subject)`.

| Check | Result |
|---|---|
| unsupported role rejected at print | yes |
| field-follow + add + return | 10+5=15 |
| subject physical identity / no graph copy | yes |

```
javac -d dev/vm_jvm/out ?graph? ? exit 0
javac -cp out;asm ?printer? ? exit 0
java ? ExprSmokeDriver ? PASS checks=7 failures=0 exit 0
java ? HelloStructureSmoke ? PASS checks=25 failures=0 exit 0
```

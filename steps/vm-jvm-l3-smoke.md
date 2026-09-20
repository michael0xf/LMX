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

## GROK-BOT-JVM-L3-CALL-20260920-55B (2026-09-20 22:42 UTC)

Path-B CALL between physical callable graph nodes.

- Commit follows this note (source/docs only under `dev/vm_jvm` + this file).
- `L3Role.CALL`: callee = physical child[0] CALLABLE; arg = SUBJECT_REF.
- Methods `c0`..`cN` from deterministic traversal map; `eval` ? `c0`.
- `ExprSmokeDriver` PASS checks=13 failures=0 (unsupported, bad arity, bad callee, call+add+return, subject identity, unreachable not emitted).
- `HelloStructureSmoke` PASS checks=25 failures=0.
- Recursion deferred (documented).
- Forbidden trees untouched; no jar/class in commit.

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

## GROK-BOT-JVM-L3-IF-20260920-56B (2026-09-20 22:46 UTC)

Path-B IF (int condition) + EOF hygiene on this file and `dev/vm_jvm/README.md`.

- `L3Role.IF`: condition / then / else; JVM branch bytecode; one arm evaluated.
- Nested CALL in selected branch; bad arity / non-int condition rejected pre-emit.
- WHILE deferred. Loader fix: generate `PrintedL3Expr` without parent classpath cache.
- `ExprSmokeDriver` PASS checks=22 failures=0; `HelloStructureSmoke` PASS checks=25 failures=0.

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

## GROK-BOT-JVM-L3-ARGS-20260920-57B (2026-09-20 22:48 UTC)

Path-B positional CALL args (`ARG`, fixed descriptors).

- `ExprSmokeDriver` PASS checks=32 failures=0; `HelloStructureSmoke` PASS checks=25 failures=0.
- Covers: direct ARG return, two-arg add, nested computed args, subject identity via ARG(0), missing/extra/negative ARG reject, PROBE left-to-right once.

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

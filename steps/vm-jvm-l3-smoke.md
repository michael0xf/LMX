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
## GROK-BOT-JVM-L3-LOCALS-20260920-58B (2026-09-20 22:52 UTC)

Path-B activation locals (SEQUENCE, LOCAL_GET, LOCAL_SET).

- ExprSmokeDriver PASS checks=43 failures=0; HelloStructureSmoke PASS checks=25 failures=0.
- Covers: set/get, overwrite, RHS once, nested CALL isolation, two fresh activations, negative/OOR/uninit/malformed reject.

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

## GROK-BOT-JVM-L3-WHILE-20260920-59B (2026-09-20 22:55 UTC)

Path-B pre-test WHILE (statement-only in SEQUENCE).

- ExprSmokeDriver PASS checks=51 failures=0; HelloStructureSmoke PASS checks=25 failures=0.
- Zero iters; three iters to 0; cond/body probe counts 4+3; nested CALL isolation; arity/value/final reject.
- Commits use `git commit --only -- <exact paths>` (no shared index sweep).

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

## GROK-BOT-JVM-L3-LOOP-XFER-20260920-60B (2026-09-20 22:57 UTC)

Path-B BREAK/CONTINUE (nearest WHILE, loop-label stack).

- `ExprSmokeDriver` PASS checks=58 failures=0; `HelloStructureSmoke` PASS checks=25 failures=0.
- Break after 3; continue skips tail; nested nearest-only; code after loop; outside/value/malformed reject.
- Commit: `git commit --only -- <exact paths>`.

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

## GROK-BOT-JVM-L3-NESTED-RETURN-20260921-87 (2026-09-21)

Path-B RETURN as control transfer from nested SEQUENCE, selected IF branch, and WHILE body to the nearest CALLABLE activation.

- Nested `RETURN` → JVM `IRETURN` of the current callable method; expression once; tail after taken return skipped.
- RETURN in callee exits only that callee; caller continues. RETURN in WHILE exits the callable (not merely the loop).
- BREAK/CONTINUE remain nearest-WHILE; BREAK in callee does not cross CALL.
- `ExprSmokeDriver` PASS checks=72 failures=0; `HelloStructureSmoke` PASS checks=25 failures=0.
- Commit: named paths under `dev/vm_jvm/**` + this file only (no `.class`/`.jar`).

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

## GROK-BOT-JVM-L3-RECURSIVE-CALL-20260921-88 (2026-09-21)

Path-B self/mutual recursive CALL through physical CALLABLE identity (seal-once shells).

- `L3Node.unsealedCallable()` + `seal(RETURN)` once; walk terminates on already-mapped CALLABLE; self-CALL emits INVOKESTATIC to mapped index.
- Positive: countdown, mutual even/odd, recursive fresh-local isolation, nested RETURN at base, unreachable not emitted.
- Negative: unsealed entry/callee, arity mismatch on recursive edge, malformed owned CALLABLE cycle, non-callable target, double-seal.
- `ExprSmokeDriver` PASS checks=93 failures=0; `HelloStructureSmoke` PASS checks=25 failures=0.
- Commit: named paths under `dev/vm_jvm/**` + this file only (no `.class`/`.jar`).

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

## GROK-BOT-JVM-L3-SEAL-FREEZE-CHILDREN-20260921-90 (2026-09-21)

Path-B sealed L3Node children freeze: no public writable children[] after seal.

- Private children; `childCount()` / `child(int)` accessors; constructor/seal defensive copy; failed seal leaves unsealed (retry OK once).
- Printer migrated off public `.children` to `child(i)` / `childCount()`.
- Positive: alias mutation does not affect node; retry after null seal; recursive countdown still green.
- Negative: null/malformed seal body; double-seal; public children field absent (reflection).
- `ExprSmokeDriver` PASS checks=117 failures=0; `HelloStructureSmoke` PASS checks=25 failures=0.
- Commit: named paths under `dev/vm_jvm/**` + this file only (no `.class`/`.jar`). Ownership-cycle guard deferred (-91).

Verify:
```
javac -d dev/vm_jvm/out lmx/*.java graph/*.java smoke/*.java
javac -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" -d dev/vm_jvm/out printer/*.java
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.ExprSmokeDriver
java -cp "dev/vm_jvm/out" smoke.HelloStructureSmoke
```

## Ownership-cycle guard (GROK-BOT-JVM-L3-OWNERSHIP-CYCLE-GUARD-20260921-91)

Illegal structural/ownership cycles among non-CALLABLE expression nodes are rejected with an identity gray/black DFS before bytecode emission (IllegalArgumentException naming the role category). Shared acyclic DAG data remains legal. CALLABLE reference edges (self/mutual recursion) stay non-ownership and terminate without cycle failure. No recursion-depth cap, graph copy, or global/TLS ownership state.

## Unlabelled REDO (GROK-BOT-JVM-L3-WHILE-REDO-20260921-93)

`L3Role.REDO` repeats the nearest active WHILE body without rechecking the condition (semantics §12). Loop-label frame is `{cond, break, body}`; CONTINUE→cond, BREAK→exit, REDO→body. Statement-only; cannot cross CALL. Physical LOOP_LABEL done; RETRYABLE/RETRY in separate slice; FINALLY deferred.

## Physical loop labels (GROK-BOT-JVM-L3-PHYSICAL-LOOP-LABELS-20260921-94)

`L3Role.LOOP_LABEL` is a sealed leaf referenced by object identity from labelled `WHILE` (arity 3: cond, body, label) and labelled `BREAK`/`CONTINUE`/`REDO` (one child). Unlabelled forms stay nearest-WHILE. Labels cannot cross CALL; duplicate active bindings and invisible/non-label targets are rejected. Descriptor references are not ownership edges.

## RETRYABLE / RETRY (GROK-BOT-JVM-L3-RETRYABLE-LOCAL-20260921-96)

`RETRYABLE` is a statement region; `RETRY` restarts its body in the same CALLABLE without a new activation and without rolling back locals/args/probes. Optional physical `RETRY_LABEL` (distinct from `LOOP_LABEL`). Cross-type label use and CALL crossing are rejected. FINALLY/cleanup-on-abandoned-attempt remains deferred.

## UNTIL (GROK-BOT-JVM-L3-UNTIL-20260921-98)

Post-test UNTIL: children condition, body[, LOOP_LABEL] (same shape as WHILE). Body runs first, then condition; repeat while condition is zero (body at least once). BREAK/CONTINUE/REDO reuse the physical loop-label frame {cond, break, body} with CONTINUE → postcondition. Unlabelled transfers target the nearest active WHILE or UNTIL; labelled transfers stay in the same CALLABLE. FOR/FINALLY deferred.

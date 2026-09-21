# vm-cil-l3-smoke — CIL/PE L3 baseline + physical CALL

GROK-BOT-CIL-L3-BASELINE-20260921-101, GROK-BOT-CIL-L3-PHYSICAL-CALL-20260921-102.

Isolated under `dev/vm_cil/**`. No changes to `dev/vm_jvm`.

## Toolchain

- `csc` = `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`
- `System.Reflection.Emit` → saved PE; `Assembly.LoadFrom`
- TEMP-only outputs; never commit exe/dll/pdb/obj/bin

## Model

- `LmxOccurrence`, identity `L3Role`, frozen-children `L3Node`
- Physical `CALL` / `CALLABLE`: ARG 0=subject, 1..=ints; CALL child[0] physical CALLABLE; one static CIL method per reachable CALLABLE; entry `Eval(LmxOccurrence)->int`
- Unsealed CALLABLE + seal-once for self/mutual recursion; CALL target is non-ownership; ordinary ownership cycles rejected
- Nested `RETURN` under IF/SEQUENCE; PROBE for evaluate-once smokes

## Commands (TEMP)

```text
set OUT=%TEMP%\vm_cil_build
csc /nologo /t:exe /out:%OUT%\CilExprSmokeDriver.exe ^
  dev\vm_cil\Lmx\*.cs dev\vm_cil\Graph\*.cs dev\vm_cil\Emitter\*.cs ^
  dev\vm_cil\Smoke\CilExprSmokeDriver.cs
%OUT%\CilExprSmokeDriver.exe
csc /nologo /t:exe /out:%OUT%\HelloStructureSmoke.exe ^
  dev\vm_cil\Lmx\*.cs dev\vm_cil\Smoke\HelloStructureSmoke.cs
%OUT%\HelloStructureSmoke.exe
```

External 30s timeout on smoke processes.

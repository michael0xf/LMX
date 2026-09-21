# vm-cil-l3-smoke — CIL/PE L3 baseline

GROK-BOT-CIL-L3-BASELINE-20260921-101. Second managed L3 VM; isolated under `dev/vm_cil/**`. No changes to `dev/vm_jvm`.

## Toolchain

- `csc` = `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe` (Framework v4; no network/SDK/NuGet)
- Emit via `System.Reflection.Emit` → saved PE; load with `Assembly.LoadFrom`
- Compile/run outputs only under `%TEMP%`

## Model

- `Lmx.LmxOccurrence` — `{node,len,data}` identity; store does not reparent; merge two-phase copy
- `Graph.L3Role` — singleton records; validate/emit dispatch by `ReferenceEquals` only
- `Graph.L3Node` — defensive child copy; `ChildCount` / `Child(i)` accessors
- Minimal roles: `CALLABLE`, `RETURN`, `SUBJECT_REF`, `ARG(0)`, `INT_LITERAL`, `FIELD_FOLLOW`, `ADD`, `IF`, `SEQUENCE`
- `Emitter.L3CilEmitter.EmitCallableToPe` validates then writes PE with static `Eval(LmxOccurrence)->int`; invalid graphs must not publish a PE

## Commands (TEMP)

```text
set OUT=%TEMP%\vm_cil_build
mkdir %OUT%
csc /nologo /t:exe /out:%OUT%\CilExprSmokeDriver.exe ^
  /r:System.dll ^
  dev\vm_cil\Lmx\*.cs dev\vm_cil\Graph\*.cs dev\vm_cil\Emitter\*.cs ^
  dev\vm_cil\Smoke\CilExprSmokeDriver.cs
%OUT%\CilExprSmokeDriver.exe
csc /nologo /t:exe /out:%OUT%\HelloStructureSmoke.exe ^
  dev\vm_cil\Lmx\*.cs dev\vm_cil\Smoke\HelloStructureSmoke.cs
%OUT%\HelloStructureSmoke.exe
```

Use an external 30s timeout on the smoke processes. Record exit codes and `PASS ... checks=N failures=0`.

## Gates

- `python tools/check_docs.py`
- `git diff --check` on exact committed paths
- One commit+push; preserve WIP/locks; no root spill; never commit build outputs

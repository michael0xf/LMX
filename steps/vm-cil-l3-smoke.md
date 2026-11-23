# vm-cil-l3-smoke — CIL/PE L3

**Отменено автором 2026-11-23:** внешние L3 VM — JVM classfile, .NET CIL, WASM GC и Lua 5.4 — отменены полностью и сняты из очереди; сохраняются Path A (C99, MIR, WASM linear, RISC-V ISA). Всё, что ниже об этих четырёх целях, — история, а не требования и не очередь; ссылки на пункты 4–7 плана портирования считать снятыми. Основание: [план](../next_core_tasks_v3.md#backends-20261123).

Tickets: BASELINE-101, PHYSICAL-CALL-102, LOCALS-WHILE-103.

Isolated under `dev/vm_cil/**`. No `dev/vm_jvm` edits.

## Toolchain

- `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`
- Reflection.Emit PE; TEMP-only; never commit binaries

## Slices

- CALLABLE/CALL, seal/recursion, nested RETURN
- LOCAL_SET/LOCAL_GET with definite-assignment; per-activation CIL locals
- Unlabelled WHILE / BREAK / CONTINUE / REDO (nearest, same CALLABLE, no CALL cross)

## Commands

```text
set OUT=%TEMP%\vm_cil_build
csc /nologo /t:exe /out:%OUT%\CilExprSmokeDriver.exe ^
  dev\vm_cil\Lmx\*.cs dev\vm_cil\Graph\*.cs dev\vm_cil\Emitter\*.cs ^
  dev\vm_cil\Smoke\CilExprSmokeDriver.cs
%OUT%\CilExprSmokeDriver.exe
```

30s external timeout on smoke.

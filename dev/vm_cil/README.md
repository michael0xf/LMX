# vm_cil ? .NET CIL / PE L3 baseline

Isolated second managed L3 VM (after JVM). Does **not** modify `dev/vm_jvm`.

## Toolchain (local only)

- `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`
- `System.Reflection.Emit` / `ILGenerator` (no NuGet, no SDK download)

Build and run only under `%TEMP%`. Never commit `exe` / `dll` / `pdb` / `obj` / `bin`.

## Slices

- GROK-BOT-CIL-L3-BASELINE-20260921-101 ? Eval PE smoke
- GROK-BOT-CIL-L3-PHYSICAL-CALL-20260921-102 ? physical CALLABLE/CALL, seal/recursion, nested RETURN

See [steps/vm-cil-l3-smoke.md](../../steps/vm-cil-l3-smoke.md).

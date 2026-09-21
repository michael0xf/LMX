# vm_cil ? .NET CIL / PE L3

Isolated second managed L3 VM. Does **not** modify `dev/vm_jvm`.

Toolchain: Framework64 v4 `csc` + Reflection.Emit; TEMP-only builds; never commit binaries.

Slices: BASELINE-101, PHYSICAL-CALL-102, LOCALS-WHILE-103 (LOCAL_SET/GET + unlabelled WHILE/BREAK/CONTINUE/REDO).

See [steps/vm-cil-l3-smoke.md](../../steps/vm-cil-l3-smoke.md).

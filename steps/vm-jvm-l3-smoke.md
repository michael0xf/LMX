# JVM / L3 Path B ? ABI + printer

- `50B`/`51B`/`52B` ABI; **`GROK-BOT-JVM-PRINTER-20260920-53B`** printer
- HEAD draft `6f5d7ed`

## 53B

- Fixture: `dev/vm_jvm/graph/L3SmokeFixture.java` (in-memory; roles = physical `L3Role` records)
- Printer: `dev/vm_jvm/printer/L3ClassfilePrinter.java`
- Driver: `dev/vm_jvm/printer/PrinterDriver.java`
- ASM 9.7.1 ? `build/vm_jvm/` only (SHA-256 `8cadd43ac5eb6d09de05faecca38b917a040bb9139c7edeb4cc81c740b713281`)

```
java -cp "dev/vm_jvm/out;build/vm_jvm/asm-9.7.1.jar" printer.PrinterDriver
? WROTE ?/PrintedL3Smoke.class
? PASS PrintedL3Smoke checks=7 failures=0
? exit 0
```

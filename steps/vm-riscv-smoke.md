# VM RISC-V Path A smoke (item 3 / VM-03)

- request_id: `GROK-BOT-VM-NOW-20260920-49B`
- author: Grok Bot
- utc: 2026-09-20T22:25:00Z
- tree: `C:\Nyasha_Planet\LMX` HEAD `a0abc8d`
- scope: evidence report only. Toolchain/QEMU/ELF under ignored `build/vm/`. No edits to `dev/l3_interp`, `lmx_walk`, l2trans eternal-emission, manager ingress, LOCKED/OWNED_BY, or inbox/outbox watchers.

Path A status entering this ticket: MIR PASS (`steps/vm-mir-smoke.md`), WASM linear PASS (`steps/vm-wasm-linear-smoke.md`). Earliest unfinished of plan items 1?3: **RISC-V**.

## Prerequisites (inventory)

| Tool | Before | Action |
|---|---|---|
| `riscv64-linux-gnu-gcc` / `qemu-riscv64` in WSL PATH | **absent** | not `apt install` |
| apt candidates | `gcc-riscv64-linux-gnu`, `qemu-user-static` listed | **not installed** (no system/global change) |
| Portable download into `build/vm/` | allowed (same rule as WASM smoke) | used |

## Downloads (local SHA-256)

| Artifact | URL / source | Bytes | SHA-256 |
|---|---|---|---|
| riscv64-glibc toolchain | https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2026.08.27/riscv64-glibc-ubuntu-22.04-gcc.tar.xz | 694898352 | `b82bdae169cff6c99820cde4cf82cd81646dddc71759649d49804c8870e6ecc2` |
| qemu-user-static .deb | http://archive.ubuntu.com/ubuntu/pool/universe/q/qemu/qemu-user-static_6.2+dfsg-2ubuntu6.31_amd64.deb | 13047942 | `2d22939f98f2ee8b84c5cc53b01082a4a937cfc7b4a8aa432788b9eaf4a14a41` |

Unpack (ignored):

- `build/vm/riscv/` ? `bin/riscv64-unknown-linux-gnu-gcc` (g6afcc4f6d) **16.1.0**, sysroot `build/vm/riscv/sysroot`
- `build/vm/qemu-user-static-root/` via `dpkg-deb -x` (not `dpkg -i`) ? `usr/bin/qemu-riscv64-static` **6.2.0**

Exact compile/run pattern:

```
GCC=build/vm/riscv/bin/riscv64-unknown-linux-gnu-gcc
QEMU=build/vm/qemu-user-static-root/usr/bin/qemu-riscv64-static
SYSROOT=$($GCC -print-sysroot)
$GCC -std=c99 -Wall -O2 -I. -Ilm1 -Il1src -o printTree.elf lm1/build/printTree.lm1.c
$QEMU -L "$SYSROOT" ./printTree.elf [args]
```

## Fixtures and exits

| Fixture | Compile | Run | Notes |
|---|---|---|---|
| `lm1/build/make.lm1.c` (blob `b33f7a9e?`) | exit **0** ? `make.elf` | `qemu ? make.elf mkdir ?` exit **0**; dir created | Linux ABI provides `system()` (unlike WASI) |
| `lm1/build/printTree.lm1.c` (blob `64c0c4e1?`) | exit **0** ? `printTree.elf` (ELF riscv64, dynamically linked) | bare exit **0** ? `usage: printTree <source>`; with `l1src/add.lm1` exit **0** ? parse tree | Primary representative (same as WASM) |

ELF hashes: `printTree.elf` `c4751792?`, `make.elf` `de350f6e?`.

## Verdict

**PASS** ? RISC-V Linux ABI (`riscv64-unknown-linux-gnu` + glibc sysroot) build and `qemu-riscv64-static -L sysroot` load/run of tracked L1 C99 seeds. Missing on-host packages recorded; filled via portable archives only.

Not claimed: bare-metal/newlib, Spike, full P0 corpus, or Path B. Path A items 1?3 now have smoke reports.

## Untracked only

`build/vm/riscv/`, `qemu-user-static-root/`, `downloads/*riscv*`, `downloads/qemu-user-static.deb`, `riscv-smoke/`. This report is the only intended Git path.

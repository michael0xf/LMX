# Path A canonical fixtures (VM porting)

Status: documentation of **observed** Path A evidence from Grok Bot tickets
`GROK-BOT-VM-PATHA-QUEUE-20260921-17` (subtasks 17–20) and earlier Path A smoke
reports under `steps/vm-*-smoke.md`. This file does **not** invent success.

Repo root for all relative paths: `C:\Nyasha_Planet\LMX` (also
`/mnt/c/Nyasha_Planet/LMX` under WSL).

## Feed: tracked generated C99

Path A consumes committed seeds under `lm1/build/*.c` (see
`steps/core-self-build.md`). These are Translator-L1 C99 images already in Git.
They are **not** produced by a new printer in these tickets.

| File | Bytes | SHA-256 (uppercase as measured 2026-09-21) | `main` |
|------|------:|---------------------------------------------|--------|
| `lm1/build/make.lm1.c` | 7443 | `1E8E04E23850657FE0729096EC6AC1C428033888F76DA4B5D5B13A3590165213` | yes |
| `lm1/build/own.lm1.c` | 7728 | `9999F774B4646B862C52B21464DBB6CFFB39A993C2BCF7AF219A2D71D33FAE60` | **no** |
| `lm1/build/parser.lm1.c` | 220449 | `E8C3ACB0E9C11E835BD74CF2B3A3C28E323BA12A2522970946748ACA90F99A51` | **no** |
| `lm1/build/printTree.lm1.c` | 221583 | `055E955C65AD86C8CC7F14524484FC1CAF8BF210232F777833003DD8A3477BC0` | yes |

Sample path-string scan on the smallest fixtures: no `C:\Nyasha_Planet\L1` /
`Nyasha_Planet\L1` hits inside those `.c` files (ticket 17). Runtime/build of
these seeds for Path A smokes used tools under ignored `build/vm/` and did not
require the sibling L1 tree.

## Canonical shared **execute** fixture

**`lm1/build/printTree.lm1.c`** — only tracked seed proven to **execute** on all
three Path A targets in ticket 19 / 18 (MIR `-ei` prints usage; WASM and RISC-V
print `usage: printTree <source>`).

Secondary MIR/RISC-V execute fixture: **`lm1/build/make.lm1.c`** (MIR `-ei mkdir
…` exit 0; RISC-V historically PASS in `steps/vm-riscv-smoke.md`). **Not** a
WASI execute fixture (see limits).

## Observed results by target (do not over-claim)

### MIR (`c2m` / `m2b` / `b2m`)

Toolchain (ignored): `build/vm/mir` @ `a8ab7c31cd5f9b23b77d84c60b3d83e62d9d304c`,
tools in `build/vm/mir-build/{c2m,m2b,b2m}`. Evidence:
`build/vm_porting/ticket18_mir_smoke.txt`, also `steps/vm-mir-smoke.md`.

| Fixture | Action | Exit | Note |
|---------|--------|-----:|------|
| `make.lm1.c` | `c2m … -ei mkdir build/vm_porting/mir-smoke/from_mir_make` | **0** | directory created |
| `make.lm1.c` | `c2m … -S -o make.mir` then `m2b` / `b2m` round-trip | **0** | text MIR 16062 B; `.bmir` 4647 B |
| `printTree.lm1.c` | `c2m … -ei` | **0** | stdout: `usage: printTree <source>` |
| `own.lm1.c` | `c2m … -S -o own.mir` | **0** | MIR emit OK |
| `own.lm1.c` | `c2m … -ei` | **1** | `cannot link program w/o main function` |
| `parser.lm1.c` | `c2m … -S` | **0** | MIR emit OK (large) |
| `parser.lm1.c` | `c2m … -ei` | **1** | `cannot link program w/o main function` |

### WASM linear (wasi-sdk + wasmtime)

Toolchain (ignored): `build/vm/wasi-sdk-34.0-x86_64-linux`,
`build/vm/wasmtime-v48.0.2-x86_64-linux`. Evidence:
`build/vm_porting/ticket19_wasm_riscv_ready.txt`, `steps/vm-wasm-linear-smoke.md`.

| Fixture | Action | Exit | Note |
|---------|--------|-----:|------|
| `printTree.lm1.c` | clang `--target=wasm32-wasip1` → `.wasm` | **0** | ~383474 B module |
| `printTree.lm1.c` | `wasmtime printTree_check.wasm` | **0** | usage line |
| `make.lm1.c` | same clang link | **1** | `undefined symbol: system` |

### RISC-V (cross gcc + qemu-user)

Toolchain (ignored): `build/vm/riscv/bin/riscv64-unknown-linux-gnu-gcc`,
`build/vm/qemu-user-static-root/usr/bin/qemu-riscv64-static`. Evidence: ticket 19
log; `steps/vm-riscv-smoke.md`.

| Fixture | Action | Exit | Note |
|---------|--------|-----:|------|
| `printTree.lm1.c` | gcc → `printTree_rv.elf` then qemu `-L sysroot` | **0** | usage line |
| Spike | — | — | **MISSING** (not installed; not required for qemu path) |

## Hard limits (explicit)

- No downloads or vendor trees committed; SDKs stay under ignored `build/vm/` /
  `build/vm_porting/`.
- No new L1 printer / Path B / L3 work in these tickets.
- `own.lm1.c` / `parser.lm1.c`: compile-to-MIR only until a **main**-bearing
  harness exists (follow-up ticket territory; not invented here).
- `make.lm1.c` on WASI: blocked on `system()` — recorded failure, not patched.

## Exact first commands (WSL, repo `/mnt/c/Nyasha_Planet/LMX`)

```
# MIR
build/vm/mir-build/c2m lm1/build/printTree.lm1.c -ei
build/vm/mir-build/c2m lm1/build/make.lm1.c -ei mkdir /tmp/from_mir

# WASM
build/vm/wasi-sdk-34.0-x86_64-linux/bin/clang --target=wasm32-wasip1 -std=c99 \
  -Wall -I. -Ilm1 -Il1src -o build/vm_porting/printTree_check.wasm \
  lm1/build/printTree.lm1.c
build/vm/wasmtime-v48.0.2-x86_64-linux/wasmtime build/vm_porting/printTree_check.wasm

# RISC-V
GCC=build/vm/riscv/bin/riscv64-unknown-linux-gnu-gcc
QEMU=build/vm/qemu-user-static-root/usr/bin/qemu-riscv64-static
$GCC -std=c99 -Wall -O2 -I. -Ilm1 -Il1src -o build/vm_porting/printTree_rv.elf \
  lm1/build/printTree.lm1.c
$QEMU -L "$($GCC -print-sysroot)" ./build/vm_porting/printTree_rv.elf
```

After ticket 22, prefer: `powershell -NoProfile -File tools/run_vm_patha_smoke.ps1 -Target all`

## Smoke runner (ticket 22)

`tools/run_vm_patha_smoke.ps1` (Windows PowerShell 5.1): `-Target mir|wasm|riscv|all`.
Uses only tools under ignored `build/vm/…`, writes under ignored `build/vm_porting/smoke_runner/`,
no downloads or PATH mutation. Observed on OAK65536 (2026-09-21):

| Target | Status | Exit |
|--------|--------|-----:|
| mir | OK | 0 |
| wasm | OK | 0 |
| riscv | OK | 0 |
| all | OK | 0 |

## Reproducibility (ticket 23)

Two consecutive `tools/run_vm_patha_smoke.ps1 -Target all` runs on OAK65536 at HEAD
`d150f93`: both OVERALL=OK, stable RESULT lines matched, no tracked worktree dirt from
the runner (artifacts only under ignored `build/vm_porting/smoke_runner/`).
Evidence: `build/vm_porting/ticket23_repro_audit.txt`.

## Next fixtures own / parser (ticket 24, read-only)

Observed on OAK65536 (no harness invented):

| Fixture | MIR `-S` | MIR `-ei` | WASM build | wasmtime | RISC-V link |
|---------|----------|-----------|------------|----------|-------------|
| `own.lm1.c` | OK (16645 B) | FAIL no main | OK | FAIL `undefined_weak:main` | FAIL undefined `main` |
| `parser.lm1.c` | OK (416229 B) | FAIL no main | OK (warnings) | FAIL `undefined_weak:main` | FAIL undefined `main` |

They remain compile-only seeds until a main harness exists. Evidence:
`build/vm_porting/ticket24_next_fixture_audit.txt`.

## Own harness (ticket GROK-BOT-VM-PATHA-OWN-HARNESS-20260921-32)

Tracked seed `lm1/build/own.lm1.c` has **no `main`**. Executable coverage is provided by a
small tracked C99 harness that **links the seed unchanged**:

- Harness: `include_languages/vm/own_harness_main.c`
- Header resolution: `-I. -Ilm1/build` so the seed's `#include "l1src/p0.lm1.h"` finds
  tracked `lm1/build/l1src/p0.lm1.h`
- Exercises real ownership (not a stub): `lm_own_copy_bytes` content+NUL; pointer-stack
  push/top/pop/order; arena init/new_zero/copy_bytes/destroy; `lm_own_alloc_fails`
  allocation-failure control + recovery
- Stable success line: `VM_OWN_OK checks=21` (exit 0); any mismatch prints `VM_OWN_FAIL …`
  and exits nonzero

### Observed (OAK65536, 2026-09-21) — all exit 0, same line

| Path | Command sketch | Exit | Output |
|------|----------------|-----:|--------|
| Host C99 (oracle) | `gcc -std=c99 -O2 -I. -Ilm1/build -o build/vm_porting/own_harness/own_host.exe include_languages/vm/own_harness_main.c lm1/build/own.lm1.c` then run | **0** | `VM_OWN_OK checks=21` |
| MIR | `build/vm/mir-build/c2m -I. -Ilm1/build … -ei` | **0** | `VM_OWN_OK checks=21` |
| WASM | wasi-sdk clang → `own.wasm`; `wasmtime own.wasm` | **0** | `VM_OWN_OK checks=21` |
| RISC-V | cross gcc → `own_rv.elf`; qemu-riscv64-static | **0** | `VM_OWN_OK checks=21` |

Artifacts only under ignored `build/vm_porting/own_harness/` and `build/vm_porting/smoke_runner/`.
No seed regeneration; no downloads; no vendor commits.

Smoke integration: `tools/run_vm_patha_smoke.ps1 -Fixture printTree|own` (default **printTree**).
Default `-Target all` outcome unchanged (printTree path). Own:

```
powershell -NoProfile -File tools/run_vm_patha_smoke.ps1 -Fixture own -Target all
```

**Still not an execute fixture:** `parser.lm1.c` (no main; no harness in this ticket).

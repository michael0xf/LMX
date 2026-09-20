# VM WASM linear-memory smoke (Path A item 2)

- request_id: `LMX-VM-WASM-LINEAR-SMOKE-20260920-40B`
- author: Grok Bot
- utc: 2026-09-20T15:52:00Z
- tree: `C:\Nyasha_Planet\LMX` HEAD `727cc0f`
- scope: evidence report only. SDK/runtime/wasm/logs under ignored `build/vm/`. No edits to dirty `lmx_walk`, `l3_interp`, mixa, self-build, or migration inventory.

Continues Path A after MIR PASS (`steps/vm-mir-smoke.md`, commits `3def333` / `8b59090`).

## Prerequisites

| Tool | Status |
|---|---|
| Host wasmtime / clang | absent from PATH |
| WSL2 Ubuntu | present (same as MIR smoke) |
| wasi-sdk / wasmtime in WSL | **absent** before this ticket ? downloaded into `build/vm/` (no system install, no global PATH change) |

## Tool downloads (local SHA-256; no upstream `.sha256` assets on these release tags)

| Artifact | URL | Version | Bytes | SHA-256 (local) |
|---|---|---|---|---|
| wasi-sdk | https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-34/wasi-sdk-34.0-x86_64-linux.tar.gz | wasi-sdk-34 / 34.0 | 192383077 | `b761e3a0721dbae9c09a0059e5fdb2bf917d1b4a8a7b430fb3b5aafb0984b2c4` |
| wasmtime | https://github.com/bytecodealliance/wasmtime/releases/download/v48.0.2/wasmtime-v48.0.2-x86_64-linux.tar.xz | v48.0.2 | 11424388 | `f2b0ad1ce9253f2f9a38793c2c42cd1cba4e90b27dc40d685eaf723dc8438d94` |

Unpack roots (ignored): `build/vm/wasi-sdk-34.0-x86_64-linux/`, `build/vm/wasmtime-v48.0.2-x86_64-linux/`.

- clang: `23.1.0-wasi-sdk` (llvm-project `895aa2c896ada719451be2e3673c83da8ddf1141`), default target `wasm32-unknown-wasip1`
- wasmtime: `48.0.2 (e9f1ea232 2026-09-10)`

## Fixture selection

### First try ? `lm1/build/make.lm1.c` (smallest tracked seed with `main`, used in MIR)

```
clang --target=wasm32-wasip1 -std=c99 ? lm1/build/make.lm1.c
```

- Exit: **1**
- Exact linker error: `wasm-ld: error: ? undefined symbol: system`
- Recorded; **not patched**. SHA-256 `1e8e04e2?` / git blob `b33f7a9e?` unchanged.

### Next representative ? `lm1/build/printTree.lm1.c`

- Tracked generated L1 C99; has `main`; **no** `system()`; uses `fopen` / heap (`calloc`) / tree walk.
- Bytes: 221583
- SHA-256: `055e955c65ad86c8cc7f14524484fc1caf8bf210232f777833003dd8a3477bc0`
- git blob: `64c0c4e1f4e5bb5d141323dafd79495e969b2936`
- Compile:

```
build/vm/wasi-sdk-34.0-x86_64-linux/bin/clang \
  --target=wasm32-wasip1 -std=c99 -Wall \
  -I. -Ilm1 -Il1src \
  -o build/vm/wasm-smoke/printTree.wasm \
  lm1/build/printTree.lm1.c
```

- Exit: **0** (warnings only). Module size 383468 bytes. Module SHA-256 `fbbee845455fd2a26e0a2de4472670b94c59f473a723f3d58b5b2cc2d74ff767`.

Also noted: `finalize.lm1.c` fails similarly (`undefined symbol: system` and `clock` without emulation libs) ? not used further.

## Load / run evidence

| Step | Command | Exit | Result |
|---|---|---|---|
| Validate/compile cache | `wasmtime compile printTree.wasm -o printTree.cwasm` | **0** | Module validates/loads |
| Usage (no args) | `wasmtime printTree.wasm` | **0** | stdout: `usage: printTree <source>` |
| File + `--dir` preopen | `wasmtime --dir=. printTree.wasm add.lm1` (cwd = preopen copy of tracked `l1src/add.lm1`) | **0** | Parsed tree printed (`fn add` / `return a + b`) |
| Preopen header smoke | `wasmtime --dir=. printTree.wasm input.lm1` (copy of tiny tracked header) | **0** | `structure fields=1` / `include` frame |

No host-pointer-alias claim. Linear memory is the WASI C heap; guest paths only via `--dir` preopen (not whole repo).

## Verdict

**PASS** ? wasi-sdk 34 + wasmtime 48 in WSL; tracked `printTree.lm1.c` ? `wasm32-wasip1`; module loads; deterministic usage; file/`fopen` via `--dir` succeeds. `make.lm1.c` blocked on WASI-missing `system()` as predicted.

Not claimed: full P0 corpus, memcpy-only microbench, browser WASI, or WASM GC (Path B). Next Path A when authorized: RISC-V (VM-03).

## Untracked only

`build/vm/downloads/`, `wasi-sdk-*`, `wasmtime-*`, `wasm-smoke/`, helper scripts. This report is the only intended Git path.

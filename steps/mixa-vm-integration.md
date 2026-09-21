# Mixa × VM portability integration (working note)

Ticket: `GROK-BOT-MIXA-PORTABILITY-SYSTEMATIZE-20260921-54`.
Editor: Grok Bot (Path A / VM smoke evidence owner).
Status labels used below: **PROPOSED** (plan only), **OBSERVED** (measured in-repo),
**NOT PROVEN** (explicit non-claim), **REF-TO-VERIFY** (external citation to re-check).

This file **systematizes** an attached portability analysis for Mixa against the Path A
VM queue. It is **not** a claim that myxa_manager already runs on these backends, and it
does **not** paste the source analysis verbatim.

## 1. Scope

| In scope | Out of scope (this ticket) |
| --- | --- |
| Record shared host surface, named profiles, routes, adapters, acceptance | Qt introduction; redesign of LMX Message core for a windowing library |
| Two-axis complexity vs JVM / .NET CIL / WASM GC / Lua 5.4 | Downloads, builds, runner edits, seed/kernel/manager source changes |
| Tie claims to existing `steps/*.md` Path A evidence | Editing `include_languages/vm_porting_plan_*.txt` or other owned WIP |

**Hard non-claim:** Path A core smoke (`tools/run_vm_patha_smoke.ps1` fixtures
printTree / own / parser / l1trans) proves **executable C99 seeds** on MIR /
WASM-linear / RISC-V user-mode. It does **NOT** prove myxa_manager UI, PTY/ConPTY,
filesystem workspace identity, or overlay rendering on any profile.
See [vm-patha-canonical-fixtures.md](vm-patha-canonical-fixtures.md),
[vm-porting.md](vm-porting.md).

## 2. Shared host surface (reuse first)

**Primary contracts are already in-tree** under
`dev/mixa_sandbox/mixa_manager/`: [BACKEND_SEAM.txt](../dev/mixa_sandbox/mixa_manager/BACKEND_SEAM.txt),
[FILE_SEAM.txt](../dev/mixa_sandbox/mixa_manager/FILE_SEAM.txt),
[PROCESS_SEAM.txt](../dev/mixa_sandbox/mixa_manager/PROCESS_SEAM.txt), plus conversion notes in
[CONVERSION.md](../dev/mixa_sandbox/mixa_manager/CONVERSION.md).
`Mixa_Manager_DISTRIBUTION_MODEL.txt` was **not present** in this tree when inspected (2026-09-21);
BACKEND_SEAM still cites it as design context — treat that citation as **REF-TO-VERIFY** if the file
returns.

Preserve Mixa UI, renderer, text-cell layout, overlay composition, and the **existing**
headless + Win32 backend/file/process implementations. VM profiles must **implement or host
these seams**, not replace them with a new SDL/libuv architecture. Optional libraries (SDL3,
libuv, libvterm, …) are only candidate **fills behind a seam operation** when a target lacks an
already-working adapter.

| Seam / surface | In-tree contract | Already present | Still additional |
| --- | --- | --- | --- |
| Display / input (`BACKEND_SEAM`) | `mixa_backend.h` ABI; sections 11.2/11.5 per-handle dispatch; headless + Win32 coexist | Headless (byte-comparable present/poll) and Win32 backends named in seam + CONVERSION | Other OS backends; optional SDL only if a target has no backend |
| Glyphs / half-cell lattice | BACKEND_SEAM §§9.4, 10.5–10.8 | Part of backend contract | Do not move cell metrics into a foreign UI toolkit |
| Files (`FILE_SEAM`) | open/close/…; console scrollback **is** a file | File seam + Win32 file unit (`mixa_file_win32`) | Panel-scale listing ops when panels need them |
| Processes (`PROCESS_SEAM`) | spawn/read/write/status/kill/close; stderr merged; nonblocking read | **Mode 0.1.2 ordinary pipes** (delegation) — Win32 process seam | **Mode 0.1.1** PTY/ConPTY + terminal-state engine (libvterm class) — explicitly out of PROCESS_SEAM today |
| Modes | 0.1.2 = console file + child pipes; 0.1.1 = real terminal host | 0.1.2 path described as current | 0.1.1 still additional work |

Platform / OS affinity stays in adapters; concurrent work uses Message ingress
(PROCESS_SEAM §6) — not private C locks. Platform state stays **outside** the LMX Message core.

## 3. Profiles (first fixed set)

| Profile ID | Where UI runs | Where third-party programs run | Primary bridge | Status |
| --- | --- | --- | --- | --- |
| `MIR_NATIVE` | Native app | Host OS | MIR external C + PTY/ConPTY | **PROPOSED** |
| `WASM_NATIVE_HOST` | Native app | Host OS | Wasmtime imports + PTY/ConPTY | **PROPOSED** (Path A has linear/WASI smoke only) |
| `WASM_BROWSER_BACKEND` | Browser | Local helper or server | WebSocket + node-pty | **PROPOSED** |
| `WASM_BROWSER_LINUX_SANDBOX` | Browser | In-browser Linux (CheerpX/WebVM class) | Custom console → libvterm | **PROPOSED** optional |
| `RISCV64_LINUX` | Guest or physical Linux | Same Linux | Linux PTY | **PROPOSED** (Path A has user-mode ELF smoke only) |
| `RISCV64_EMBEDDED_LINUX` | Kiosk/DRM Linux | Same Linux | PTY + KMSDRM display | **PROPOSED** after desktop Linux |
| `RISCV_EMBEDDED_HOST` | Native host | Host OS | Guest→host syscall/call adapters | **PROPOSED** |

Graphics rule for every profile: reuse an existing backend when fit; SDL3 is a
concrete fill for a **missing** backend, not a new mandatory Mixa foundation.

## 4. Per-profile routes, adapters, acceptance

### 4.1 `MIR_NATIVE`

- **Route:** Mixa via MIR interpreter/JIT ↔ native platform adapter (display/SDL3,
  files, libvterm, PTY/ConPTY). Third-party programs stay native processes; do not
  translate them into MIR modules.
- **Adapters:** `MIR_load_module` / `MIR_load_external` / `MIR_link` with import
  resolver; register native C entry points. Unix 0.1.1: forkpty/openpty + termios +
  `TIOCSWINSZ`. Windows 0.1.1: ConPTY (`CreatePseudoConsole` …) with careful pipe
  servicing off a blocked GUI thread. 0.1.2: `uv_spawn`/pipes or real console
  inheritance — no libvterm requirement.
- **Acceptance:** own UI + overlay; workspace file visible to child; real
  shell/editor in 0.1.1; resize/Unicode/keys/mouse/exit; 0.1.2 returns control and
  redraws; unsupported ops fail explicitly.
- **Evidence / caveats:** Path A MIR smoke is **OBSERVED** for C seeds only
  ([vm-mir-smoke.md](vm-mir-smoke.md), [vm-patha-canonical-fixtures.md](vm-patha-canonical-fixtures.md)).
  Upstream MIR README emphasizes Linux/macOS; Windows executor status must be kept
  separate from “compile succeeded” (**REF-TO-VERIFY** upstream MIR docs).

### 4.2 `WASM_NATIVE_HOST`

- **Route:** native host embeds Wasmtime + same display/fs/PTY surface; guest is the
  existing Core Wasm artifact (do not silently swap Emscripten ↔ WASI modules).
- **Adapters:** linker-defined host funcs; validate guest linear memory
  (`data`/`data_size`, no dangling host pointers across grow); optional WASI
  preopens are **not** a sandbox for native child processes.
- **Acceptance:** same matrix as MIR_NATIVE after the host↔guest ABI is explicit.
- **Evidence:** Path A WASM-linear + wasmtime smoke **OBSERVED** for printTree/own/
  parser/l1trans ([vm-wasm-linear-smoke.md](vm-wasm-linear-smoke.md),
  [vm-patha-canonical-fixtures.md](vm-patha-canonical-fixtures.md)). Manager UI /
  PTY **NOT PROVEN**.

### 4.3 `WASM_BROWSER_BACKEND` (first browser profile)

- **Route:** browser Mixa (Emscripten + renderer/SDL3) + libvterm; real programs via
  local/remote helper (`node-pty`, `ws`, `node:fs/promises`, `child_process`).
- **Adapters:** application terminal + file protocols, auth/session ownership,
  backpressure, orderly shutdown; main loop must stay non-blocking.
- **Acceptance:** 0.1.1 stream helper↔libvterm↔renderer; 0.1.2 completion + redraw;
  browser storage ≠ helper workspace.
- **Evidence:** none in Path A smoke (**NOT PROVEN**). Emscripten websocket /
  node-pty / SDL browser notes are **REF-TO-VERIFY**.

### 4.4 `WASM_BROWSER_LINUX_SANDBOX` (optional)

- CheerpX/WebVM-class Linux in browser; custom console into libvterm. Licensing and
  full 0.1.1 with Mixa UI need separate tests (**REF-TO-VERIFY**). Not a property of
  ordinary Wasm modules.

### 4.5 `RISCV64_LINUX` / `RISCV64_EMBEDDED_LINUX`

- **Route:** full Linux (hw or `qemu-system-riscv64` virt) with guest SDL3/libvterm/
  PTY; child programs must be guest-arch Linux binaries (not host Windows FAR.exe).
- **Embedded variant:** same process/PTY stack; display via SDL KMSDRM + board DRM —
  verify after ordinary desktop Linux so board driver noise is separated.
- **Evidence:** Path A RISC-V is **user-mode** qemu-riscv64 ELF smoke
  ([vm-riscv-smoke.md](vm-riscv-smoke.md)) — **NOT** a Linux system profile.
  Full virt + VirtIO GPU is **PROPOSED** / **REF-TO-VERIFY** (QEMU docs).

### 4.6 `RISCV_EMBEDDED_HOST`

- Small ISA executor inside native Mixa host (existing project executor and/or
  libriscv class). Same native display/fs/PTY as MIR/Wasmtime hosts. Do not assume
  full Linux syscalls; do not replace the current emulator without a separate
  decision. Bare-metal stands stay compute/codegen only — not full Mixa + third-party
  programs.

## 5. Evidence map (Path A vs manager)

| Claim class | Where recorded | Status for myxa_manager |
| --- | --- | --- |
| MIR / WASM-linear / RISC-V user-mode execute of tracked C seeds | [vm-patha-canonical-fixtures.md](vm-patha-canonical-fixtures.md), [vm-mir-smoke.md](vm-mir-smoke.md), [vm-wasm-linear-smoke.md](vm-wasm-linear-smoke.md), [vm-riscv-smoke.md](vm-riscv-smoke.md), smoke runner | Path A **OBSERVED**; manager **NOT PROVEN** |
| JVM L3 smoke notes | [vm-jvm-l3-smoke.md](vm-jvm-l3-smoke.md) | Separate queue item; not Mixa UI proof |
| Queue order MIR → WASM linear → RISC-V; JVM / WASM GC / Lua / CIL deferred | [vm-porting.md](vm-porting.md) | Policy **OBSERVED** in docs |
| `myxa_manager` lives elsewhere; not in early VM bootstrap | [vm-porting.md](vm-porting.md) | Explicit boundary |

## 6. Two-axis complexity matrix

Axes:

- **X — Host surface glue:** how much new display/input/fs/PTY/protocol work Mixa needs
  beyond a working native adapter.
- **Y — Execution / ABI glue:** how hard it is to run Mixa (or its C image) and call
  into that host surface safely.

Scores are relative **PROPOSED** judgments for *Mixa manager integration*, not Path A
smoke scores. Lower is easier.

| Backend / profile | X host surface | Y exec/ABI | Combined (X+Y) | Why (short) |
| --- | ---: | ---: | ---: | --- |
| Native (no VM) + existing backends | 1 | 1 | **2** | Baseline; reuse working adapters |
| `MIR_NATIVE` | 2 | 2 | **4** | Same OS processes/PTY; MIR external C is close to native |
| `WASM_NATIVE_HOST` | 2 | 3 | **5** | Same host PTY/display; linear memory ↔ host pointer boundary |
| `RISCV_EMBEDDED_HOST` | 2 | 3 | **5** | Same host surface; guest syscall/call surface must be explicit |
| `RISCV64_LINUX` | 3 | 2 | **5** | Full Linux PTY/packages available; need guest system (or virt), guest-arch children |
| `WASM_BROWSER_BACKEND` | 4 | 3 | **7** | Split UI/helper; protocols, auth, non-blocking loop |
| `RISCV64_EMBEDDED_LINUX` | 4 | 3 | **7** | Linux stack + board DRM/KMS risk |
| `WASM_BROWSER_LINUX_SANDBOX` | 4 | 4 | **8** | Extra Linux-in-browser product; license + console integration |
| **Lua 5.4** (deferred Path A item) | 3 | 3 | **6** | Embeddable C API friendly; still need full host adapters; no Path A Mixa proof ([vm-porting.md](vm-porting.md) queue) |
| **JVM** | 4 | 4 | **8** | JNI/foreign + packaging; L3 smoke notes exist but manager UI **NOT PROVEN** ([vm-jvm-l3-smoke.md](vm-jvm-l3-smoke.md)) |
| **.NET CIL** | 4 | 4 | **8** | Hosting / P/Invoke / AOT variants; deferred in [vm-porting.md](vm-porting.md) |
| **WASM GC** | 4 | 5 | **9** | Different memory/ABI from Path A linear/WASI; browser + GC toolchain; deferred explicitly in [vm-porting.md](vm-porting.md) |

Reading: for Mixa portability, **MIR_NATIVE** and **WASM_NATIVE_HOST** (then
**RISCV_EMBEDDED_HOST** / **RISCV64_LINUX**) stay ahead of JVM / CIL / WASM GC.
Lua sits mid-pack: easier ABI than JVM/CIL/GC, still not free of host-surface work.
Path A smoke does not move any row into “manager proven.”

## 7. Shared vs per-backend glue

**Shared (write once, reuse):**

- Mode 0.1.1 vs 0.1.2 contracts and acceptance tests
- Display present + input policy (existing backend or SDL3 fill)
- libvterm screen model for 0.1.1
- Workspace identity: files Mixa mutates == files children see
- “Unsupported → explicit fail” policy; no Qt; platform state outside Message core

**Per-backend:**

- MIR: external symbol resolver / JIT vs interpreter test split
- Wasmtime: import table + memory validation + WASI vs native-child permission split
- Browser: WebSocket protocols + helper process stack
- RISC-V Linux: guest packages / virt devices; embedded DRM hints
- Embedded RISC-V / libriscv: syscall/call handlers without claiming full Linux
- JVM / CIL / Lua / WASM GC: separate foreign-function and packaging layers (queued)

## 8. Sequencing recommendation

1. Inventory existing Mixa platform boundary (display, fonts/cells, fs, process, PTY,
   guest/native calls); reuse what works.
2. Keep Path A smokes as **executor** regression only; do not treat them as manager
   acceptance.
3. First manager-facing profiles: **`MIR_NATIVE`**, then **`WASM_NATIVE_HOST`**
   (same host PTY/display lessons).
4. Browser: **`WASM_BROWSER_BACKEND`** before any in-browser Linux sandbox.
5. RISC-V: **`RISCV64_LINUX`** (or virt) before **`RISCV64_EMBEDDED_LINUX`**; keep
   **`RISCV_EMBEDDED_HOST`** aligned with MIR/Wasmtime host adapters.
6. Only after L3 + interface agreement: JVM, WASM GC, Lua 5.4, CIL
   ([vm-porting.md](vm-porting.md)).

## 9. Citations (references to verify)

Do not treat the following as already re-validated in this ticket; re-check before
implementation:

- SDL3 / SDL3_ttf wiki (window, texture present, text input, Emscripten, KMSDRM)
- libuv docs (fs + spawn; distinct from PTY)
- libvterm / pkg-config `vterm`
- Linux PTY (`forkpty`/`openpty`, termios, `TIOCSWINSZ`); Windows ConPTY deadlock notes
- Wasmtime C API (linker, memory, WASI preopens)
- Emscripten websocket C API (`-lwebsocket.js`); Node `ws`, `node-pty`, `fs/promises`
- QEMU `virt` + VirtIO GPU/keyboard/mouse; Debian riscv64 SDL3/libvterm packages
- MIR upstream platform list; libriscv embedding/syscall examples
- CheerpX / WebVM custom console APIs and licensing



## 11. Addendum — map profiles onto existing seams (ticket 54)

Inspected on OAK65536 under `dev/mixa_sandbox/mixa_manager/` before this rewrite.
Orientation inventory only (not effort): about **823** manager files and **66** paths whose
names match `win32` (filename scan 2026-09-21). External brief cited ~799 / ~74 — same order
of magnitude; do not treat either pair as a cost metric.

Product entrypoint status ([mixa-manager-run-audit.md](mixa-manager-run-audit.md)):
`mixa_app_main` is a **build-only / not yet proven runnable** interactive Win32 shell in
automated evidence; gate `bin/` publishes selftests/fixtures, not a headless product manager
exe. Path A VM smoke remains unrelated to that gap.

| Profile | BACKEND_SEAM | FILE_SEAM | PROCESS_SEAM | What the VM adds |
| --- | --- | --- | --- | --- |
| `MIR_NATIVE` | Host MIR loads Mixa; call existing headless/Win32 (or later X11) **backend vtables** via `MIR_load_external` — do not invent a parallel SDL UI | Same file ABI; native Win32/Unix file adapter stays host-side | Keep **0.1.2 pipes** as today; add **0.1.1** PTY/ConPTY + terminal model as a **new** producer behind FILE console, not a PROCESS_SEAM rewrite | JIT/interpreter + import resolver |
| `WASM_NATIVE_HOST` | Wasmtime host defines imports that forward to the **same** backend/file/process C adapters; guest must not hold raw host HWND/HANDLEs across calls | Host file seam; align guest-visible paths with child cwd | Same: 0.1.2 already; 0.1.1 still host PTY + terminal model | Linear-memory validation; import table |
| `WASM_BROWSER_BACKEND` | Browser build still targets BACKEND_SEAM ops (present/poll/…); Emscripten/SDL only if used **as one backend implementation** | Browser storage ≠ workspace; file ops go to helper implementing FILE_SEAM semantics | Helper runs 0.1.2 pipes / later 0.1.1 PTY (`node-pty`) and streams into the console-file + eventual terminal model | Protocols + helper — not a replacement seam |
| `WASM_BROWSER_LINUX_SANDBOX` | Same BACKEND_SEAM front-end | Guest Linux disk is the FILE_SEAM workspace for that profile | PTY inside sandbox → terminal model → present | Extra product (CheerpX class); **REF-TO-VERIFY** |
| `RISCV64_LINUX` | Guest implements BACKEND_SEAM (existing or SDL fill **behind** the vtable) | Guest filesystem = FILE_SEAM | Guest Linux PTY for 0.1.1; pipes for 0.1.2 | Full guest Linux — distinct from Path A user-mode ELF smoke |
| `RISCV64_EMBEDDED_LINUX` | KMSDRM/etc. still must satisfy BACKEND_SEAM tests (headless oracle first) | Same Linux FILE_SEAM | Same process modes | Board display risk after desktop Linux |
| `RISCV_EMBEDDED_HOST` | Like MIR/Wasmtime: native host owns backend/file/process seams | Host FILE_SEAM | Host 0.1.2 now; 0.1.1 later | Guest→host call adapters only |
| JVM / .NET CIL / Lua / WASM GC (queued) | Foreign runtime must still expose BACKEND/FILE/PROCESS seams to Mixa logic | Same | Same mode split | Packaging/FFI cost; no license to bypass seams |

**Do not:** replace headless/Win32 with SDL “because portability”; fold files into the backend;
claim 0.1.1 because 0.1.2 pipes are green; treat Path A `run_vm_patha_smoke` as manager
acceptance; treat `mixa_app_main` build-only linkage as a proven product run.

## 10. Ticket closure checklist

- [x] Working file: `steps/mixa-vm-integration.md` (created, then addendum-updated against seam docs)
- [ ] `python tools/check_docs.py` (run at commit time)
- [ ] `git diff --check` on the new file
- [ ] Commit/push **only** this path

No downloads, no builds, no VM runner changes in this ticket.
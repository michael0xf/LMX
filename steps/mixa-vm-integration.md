# Mixa × VM portability integration (working note)

Ticket: `GROK-BOT-MIXA-PORTABILITY-SYSTEMATIZE-20260921-54` (REVIEW1 amend).
Editor: Grok Bot (Path A / VM smoke evidence owner).
Status labels: **PROPOSED** (plan only), **OBSERVED** (measured in-repo),
**NOT PROVEN** (explicit non-claim), **REF-TO-VERIFY** (external citation to re-check).

This file systematizes Mixa portability against Path A VM evidence and the
**existing** manager seam contracts. It is not a claim that the product manager
already runs on these backends.

## 1. Scope

| In scope | Out of scope (this ticket) |
| --- | --- |
| Record shared host surface via existing seams; profiles; routes; acceptance | Qt; redesign of LMX Message core for a windowing library |
| Two-axis complexity (kernel/compiler vs full manager product) vs JVM / .NET CIL / WASM GC / Lua 5.4 | Downloads, builds, runner edits, seed/kernel source changes |
| Tie claims to `steps/*.md` evidence | Editing `include_languages/vm_porting_plan_*.txt` or other owned WIP |

**Hard non-claim:** Path A core smoke (`tools/run_vm_patha_smoke.ps1` fixtures
printTree / own / parser / l1trans) proves **executable C99 seeds** on MIR /
WASM-linear / RISC-V user-mode. It does **NOT** prove myxa_manager UI, PTY/ConPTY,
filesystem workspace identity, or overlay rendering on any profile.
See [vm-patha-canonical-fixtures.md](vm-patha-canonical-fixtures.md),
[vm-porting.md](vm-porting.md).

## 2. Existing manager seams (primary contracts)

Inspected under `dev/mixa_sandbox/mixa_manager/`:

| Document | Role |
| --- | --- |
| [BACKEND_SEAM.txt](../dev/mixa_sandbox/mixa_manager/BACKEND_SEAM.txt) | Display/input ABI (`mixa_backend.h`; §§11.2/11.5 per-handle dispatch) |
| [FILE_SEAM.txt](../dev/mixa_sandbox/mixa_manager/FILE_SEAM.txt) | Names/bytes; console scrollback **is** a file |
| [PROCESS_SEAM.txt](../dev/mixa_sandbox/mixa_manager/PROCESS_SEAM.txt) | Child lifetime; spawn/read/write/status/kill/close |
| [CONVERSION.md](../dev/mixa_sandbox/mixa_manager/CONVERSION.md) | C→L1 conversion status; names headless + Win32 units |

`Mixa_Manager_DISTRIBUTION_MODEL.txt` was **absent** in this tree when inspected
(BACKEND_SEAM still cites it) — **REF-TO-VERIFY** if it returns.

**Already present (OBSERVED in seam docs + CONVERSION):**

- Headless backend (byte-comparable present/poll path) **and** Win32 backend
- Win32 file adapter (`mixa_file_win32`) and Win32 process adapter (`mixa_process_win32`)
- **Mode 0.1.2 ordinary pipes** — PROCESS_SEAM is explicitly ClearShell-style
  delegation (no PTY, no terminal emulation, no child screen)

**Still new work:**

- **Mode 0.1.1** — real PTY/ConPTY session + terminal-state engine (libvterm-class)
  feeding the console/file/display path. PROCESS_SEAM today says this is out of
  scope until 0.1.1.

**Optional libraries map into seams — they are not a replacement architecture:**

| Library | Maps into | When |
| --- | --- | --- |
| SDL3 / SDL3_ttf | BACKEND_SEAM implementation | Only if a target lacks a working backend; present/poll/clipboard stay the contract |
| libuv | FILE_SEAM / PROCESS_SEAM fill | Only if a target lacks a working native file/process adapter |
| libvterm | Terminal-state engine for **0.1.1** | Additional to PROCESS_SEAM pipes; do not route Mixa UI through escape sequences |

Do not replace headless/Win32 with SDL “for portability.” Do not fold files into
the backend. Do not claim 0.1.1 because 0.1.2 pipes are green.

The tree has many Win32 implementations and tests (orientation only — filename
hits are **not** an effort metric). Concurrent work uses Message ingress
(PROCESS_SEAM §6), not private C locks. Platform state stays outside the LMX
Message core.

## 3. Profiles (first fixed set)

| Profile ID | Where UI runs | Where third-party programs run | Primary bridge | Status |
| --- | --- | --- | --- | --- |
| `MIR_NATIVE` | Native app | Host OS | MIR external C → existing seams + later 0.1.1 | **PROPOSED** |
| `WASM_NATIVE_HOST` | Native app | Host OS | Wasmtime imports → same seams | **PROPOSED** (Path A has linear/WASI smoke only) |
| `WASM_BROWSER_BACKEND` | Browser | Local helper or server | WebSocket + helper implementing seams | **PROPOSED** |
| `WASM_BROWSER_LINUX_SANDBOX` | Browser | In-browser Linux | Custom console → terminal model → BACKEND | **PROPOSED** optional |
| `RISCV64_LINUX` | Guest or physical Linux | Same Linux | Guest BACKEND/FILE/PROCESS | **PROPOSED** (Path A has user-mode ELF smoke only) |
| `RISCV64_EMBEDDED_LINUX` | Kiosk/DRM Linux | Same Linux | Same + KMSDRM behind BACKEND | **PROPOSED** after desktop Linux |
| `RISCV_EMBEDDED_HOST` | Native host | Host OS | Guest→host calls into host seams | **PROPOSED** |

Graphics rule: reuse an existing BACKEND implementation when fit; SDL3 is only a
candidate **behind** the vtable when missing.

## 4. Per-profile routes (seams first)

### 4.1 `MIR_NATIVE`

Host MIR loads Mixa; `MIR_load_external` / link resolver call **existing**
headless/Win32 (later X11) backend/file/process adapters. Keep 0.1.2 pipes; add
0.1.1 as a new producer behind the console file + terminal model. Path A MIR
smoke is **OBSERVED** for C seeds only
([vm-mir-smoke.md](vm-mir-smoke.md), [vm-patha-canonical-fixtures.md](vm-patha-canonical-fixtures.md)).
Upstream MIR Windows support remains **REF-TO-VERIFY**.

### 4.2 `WASM_NATIVE_HOST`

Wasmtime host imports forward to the **same** C seam adapters; validate linear
memory; do not treat WASI preopens as a sandbox for native children. Path A
WASM-linear smoke **OBSERVED** for seeds
([vm-wasm-linear-smoke.md](vm-wasm-linear-smoke.md)); manager UI/PTY **NOT PROVEN**.

### 4.3 `WASM_BROWSER_BACKEND`

Browser build still targets BACKEND_SEAM ops; helper implements FILE/PROCESS
semantics (0.1.2 now, 0.1.1 via node-pty-class later). Protocols/auth/backpressure
are application work. No Path A evidence (**NOT PROVEN**).

### 4.4 `WASM_BROWSER_LINUX_SANDBOX` (optional)

CheerpX/WebVM-class; custom console into terminal model. Licensing and full 0.1.1
with Mixa UI **REF-TO-VERIFY**.

### 4.5 `RISCV64_LINUX` / `RISCV64_EMBEDDED_LINUX`

Guest implements the three seams; children must be guest-arch Linux binaries.
Path A RISC-V is **user-mode** ELF smoke ([vm-riscv-smoke.md](vm-riscv-smoke.md))
— **not** a Linux system profile. Embedded DRM after ordinary Linux.

### 4.6 `RISCV_EMBEDDED_HOST`

Like MIR/Wasmtime: native host owns seams; guest gets explicit call/syscall
adapters without assuming full Linux.

## 5. Evidence map (Path A vs manager)

| Claim class | Where recorded | Status for myxa_manager |
| --- | --- | --- |
| MIR / WASM-linear / RISC-V user-mode execute of tracked C seeds | [vm-patha-canonical-fixtures.md](vm-patha-canonical-fixtures.md), [vm-mir-smoke.md](vm-mir-smoke.md), [vm-wasm-linear-smoke.md](vm-wasm-linear-smoke.md), [vm-riscv-smoke.md](vm-riscv-smoke.md) | Path A **OBSERVED**; manager product **NOT PROVEN** |
| Manager sources + seams in this repo | `dev/mixa_sandbox/mixa_manager/` (BACKEND/FILE/PROCESS + CONVERSION) | Tree **OBSERVED** present here |
| Real product entry / run | [mixa-manager-run-audit.md](mixa-manager-run-audit.md) | `mixa_app_main` source exists; **product executable/run not proven**; gate evidence is selftests / controller e2e proxy |
| JVM L3 smoke notes | [vm-jvm-l3-smoke.md](vm-jvm-l3-smoke.md) | Partial L3 smoke only — **not** a full JVM compiler or manager |
| Path A queue vs L3 managed targets | [vm-porting.md](vm-porting.md) | Path A = MIR → WASM linear → RISC-V; JVM / WASM GC / Lua / CIL are **L3 printer / Path-B** queue after interface agreement — **Lua is never a deferred Path A item** |

## 6. Two-axis complexity matrix

Axes (user-requested):

- **A — Kernel / compiler cost:** get Mixa’s executable image onto the target
  (Path A C seeds vs L3 printer/runtime).
- **B — Full myxa_manager product integration cost:** drive existing
  BACKEND/FILE/PROCESS seams, UI/overlay, 0.1.2 today, and eventually 0.1.1 on
  that profile.

Levels: **Low / Medium / High / Very High** (ranges allowed). Scores are
**PROPOSED** judgments with uncertainty — not Path A smoke scores and not fake
additive precision.

| Backend / profile | A kernel/compiler | B full manager product | Notes / uncertainty |
| --- | --- | --- | --- |
| `MIR_NATIVE` | **Low–Medium** | **Medium** | Path A MIR **OBSERVED** for C seeds; native C host can call existing Win32/headless seams. Windows MIR upstream caveat **REF-TO-VERIFY**. |
| `WASM_NATIVE_HOST` (linear) | **Low–Medium** | **Medium–High** | Path A linear/WASI smoke **OBSERVED**; manager needs import↔seam bridge + memory validation; 0.1.1 still new. |
| `WASM_BROWSER_BACKEND` | **Medium** | **Very High** | Split UI/helper, protocols, auth, non-blocking loop; hardest manager path among Path A–adjacent profiles. |
| `RISCV64_LINUX` | **Low–Medium** | **High** | Core/user-mode cheap (**OBSERVED** ELF smoke); full manager needs guest Linux system + guest-arch children + seams on guest. |
| `RISCV64_EMBEDDED_LINUX` | **Low–Medium** | **High–Very High** | Same process stack + board DRM/KMS risk after desktop Linux. |
| `RISCV_EMBEDDED_HOST` | **Low–Medium** | **High–Very High** | Core embed may be cheap; manager risk is complete guest→host service surface without full Linux. |
| **JVM** | **High–Very High** | **High–Very High** | L3 managed/Path-B printer+runtime + host bindings; only partial L3 smoke ([vm-jvm-l3-smoke.md](vm-jvm-l3-smoke.md)) — not a full compiler or manager. |
| **WASM GC** | **High–Very High** | **High–Very High** | Different memory/ABI from Path A linear; L3 printer/runtime; B depends on native-hosted vs browser-hosted GC target. |
| **Lua 5.4** | **High** | **Medium–High** | **L3 managed / Path-B printer target** (not Path A). Needs L3 printer/runtime + host-service bindings into existing seams. |
| **.NET CIL** | **High–Very High** | **High–Very High** | L3 managed/Path-B; hosting/PInvoke/AOT variants; deferred with JVM/GC/Lua in [vm-porting.md](vm-porting.md). |

### 6.1 Interpretation (explicit)

- **MIR native** is likely **easier overall** than JVM, .NET CIL, WASM GC, and Lua:
  Path A evidence plus native C calling existing manager seams.
- **WASM native (linear)** and **RISC-V Linux**: cheap **A**, but manager **B** is
  Medium–High / High — roughly comparable to **Lua manager** work, and usually
  below a fresh **JVM / CIL / WASM-GC** compiler+manager total.
- **WASM browser helper**: manager **Very High** — harder than JVM/CIL/Lua
  *manager-integration* alone, and comparable to or above **WASM GC** depending
  on whether that GC target is native-hosted or browser-hosted.
- **RISC-V embedded Linux / embedded host**: **High to Very High** manager risk,
  comparable to managed targets, despite relatively cheap core (**A**).

Path A smoke does not move any **B** cell to “proven.”

## 7. Shared one-time vs per-profile work (existing seams)

**Shared one-time (write against seam contracts, reuse):**

- Keep BACKEND / FILE / PROCESS ABIs stable; headless oracle remains the
  correctness baseline for new backends
- Mode contracts: 0.1.2 pipes (exists) vs 0.1.1 PTY/ConPTY + terminal-state engine
  (new)
- Acceptance: overlay/UI; workspace file visible to child; 0.1.1 shell/editor;
  resize/Unicode/keys/mouse/exit; explicit fail for unsupported
- Message ingress for foreign callbacks (PROCESS_SEAM §6); no Qt; platform state
  outside Message core

**Per-profile:**

- MIR: import resolver; interpreter vs JIT test split
- Wasmtime: import table + memory validation
- Browser helper: protocols + helper process stack implementing the same seams
- RISC-V Linux / embedded: guest packages or DRM behind BACKEND
- Embedded RISC-V host: syscall/call handlers without claiming full Linux
- JVM / CIL / Lua / WASM GC: L3 printer/runtime **plus** bindings that still
  terminate on BACKEND/FILE/PROCESS — never a bypass of those seams

Win32 has many implementations/tests already; that inventory orients ports, it
does **not** measure remaining effort by file count.

## 8. Sequencing recommendation

1. Inventory against BACKEND/FILE/PROCESS; reuse headless+Win32.
2. Keep Path A smokes as **executor** regression only.
3. First manager-facing profiles: **`MIR_NATIVE`**, then **`WASM_NATIVE_HOST`**.
4. Browser helper only after native host lessons; sandbox Linux later.
5. **`RISCV64_LINUX`** before embedded DRM; keep **`RISCV_EMBEDDED_HOST`** aligned
   with MIR/Wasmtime host adapters.
6. JVM / WASM GC / Lua / CIL only after L3 + interface agreement
   ([vm-porting.md](vm-porting.md)) — all are managed/Path-B, not Path A.

## 9. Citations (references to verify)

SDL3/ttf wiki; libuv; libvterm; Linux PTY / Windows ConPTY notes; Wasmtime C API;
Emscripten websocket; Node `ws` / `node-pty`; QEMU virt / VirtIO GPU; Debian
riscv64 packages; MIR upstream platform list; libriscv; CheerpX/WebVM licensing.

## 10. Ticket closure checklist

- [x] Working file: `steps/mixa-vm-integration.md` (systematize + seam addendum + REVIEW1)
- [x] Navigation sentence in `steps/vm-porting.md` → this file
- [x] `python tools/check_docs.py` (run at commit time)
- [x] `git diff --check` on the committed paths
- [x] Commit/push **only** `steps/mixa-vm-integration.md` and `steps/vm-porting.md`

No downloads, no builds, no VM runner or source edits in this ticket.

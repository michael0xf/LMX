# Mixa × VM portability integration (working note)

Tickets: `GROK-BOT-MIXA-PORTABILITY-SYSTEMATIZE-20260921-54` (REVIEW1),
`GROK-BOT-L3-VM-COMPLEXITY-20260921-72` (L3 VM complexity model).
Editor: Grok Bot (Path A / VM smoke evidence owner).
Status labels: **PROPOSED** (plan only), **OBSERVED** (measured in-repo),
**NOT PROVEN** (explicit non-claim), **REF-TO-VERIFY** (external citation to re-check).

This file systematizes Mixa portability against Path A VM evidence and the
**existing** manager seam contracts. It is not a claim that the product manager
already runs on these backends. Section 6 is the bounded complexity model for
the **four external L3 VMs** (JVM classfile, .NET CIL, WASM GC, Lua 5.4) versus
Path A manager ports.

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
| Path A queue vs four external L3 VMs | [vm-porting.md](vm-porting.md), §6 below | Path A = MIR → WASM-linear → RISC-V (**separate**). Four L3 targets = JVM classfile → .NET CIL → WASM GC → Lua 5.4. Native binary-graph L3 interpreter = **semantic oracle**, not a fifth target. **Java/JVM is the first L3 candidate** (not excluded). |

## 6. Complexity model (Path A manager ports vs four external L3 VMs)

### 6.0 Hard separations

| Track | What it is | What it is not |
| --- | --- | --- |
| **Path A** | MIR → WASM-**linear** → RISC-V user-mode; L1 → C99 → external tool | Not an L3 bytecode printer; not WASM GC |
| **Four external L3 VMs** | JVM **classfile**, .NET **CIL**, **WASM GC**, **Lua 5.4** | Not Path A; not "any managed language" |
| **Native binary-graph L3 interpreter** | Existing in-repo L3 semantic **oracle** / shared foundation for Message, walk, prims, identity | **Not** one of the four external VMs and not a fifth port target |

**Java / JVM is the first L3 candidate.** Do not exclude it from the L3 queue or
bury it behind "managed = always hardest."

**Identity / representation rules (all four L3 targets):** do **not** turn JVM
classes, CIL objects, WASM GC structs, or Lua tables into LMX Structures.
Preserve occurrence identity, fixed `len`, physical role refs, Message/turn
semantics, and **no text dispatch**. Host values stay behind physical primitive
tables and OS-service adapters that terminate on BACKEND/FILE/PROCESS.

Status of every score below: **PROPOSED** ranges with uncertainty — not Path A
smoke scores and not fake additive precision.

### 6.1 Cost split: shared one-time vs per-target

Manager/UI complexity dominates. Re-evaluate totals by splitting:

**Shared one-time (paid once, reused by every L3 target and by the oracle):**

- L3 frontend: binary-graph → walk/plan/roles against the existing interpreter
- Runtime/identity: occurrence identity, fixed len, physical role refs
- Message / turn / mail / mode semantics (oracle = native binary-graph L3)
- myxa_manager **application/UI** code expressed on BACKEND/FILE/PROCESS
  (headless oracle; 0.1.2 pipes today; 0.1.1 later) — not rewritten per VM
- Acceptance criteria and Message ingress for foreign callbacks

**Per-target slice (paid once per external VM):**

- Bytecode **emitter** for that format
- **Verifier / loader** for that format
- **Physical primitive table** for that host
- **OS-service adapter** into existing BACKEND/FILE/PROCESS (never a seam bypass)

Path A profiles still need **per-profile** seam adapters and product validation;
they do **not** buy the shared L3 frontend, but they also do **not** share one
managed UI image the way four L3 emitters can share one UI+Message stack.

### 6.2 Path A profiles (independent manager/UI ports) — axis reminder

Axes (unchanged names, clarified meaning):

- **A — Kernel / bring-up:** get an executable image onto the target (Path A C
  seeds today).
- **B — Full myxa_manager product:** seams + UI/overlay + 0.1.2 / later 0.1.1.

| Backend / profile | A | B | Notes / uncertainty |
| --- | --- | --- | --- |
| `MIR_NATIVE` | **Low–Medium** | **Medium** | Path A MIR **OBSERVED** for C seeds; native host can call existing seams. Windows MIR upstream **REF-TO-VERIFY**. |
| `WASM_NATIVE_HOST` (linear) | **Low–Medium** | **Medium–High** | Path A linear/WASI **OBSERVED**; manager needs import↔seam bridge; 0.1.1 still new. |
| `WASM_BROWSER_BACKEND` | **Medium** | **Very High** | Split UI/helper, protocols, auth; hardest Path A–adjacent manager path. |
| `RISCV64_LINUX` | **Low–Medium** | **High** | User-mode ELF smoke **OBSERVED**; full manager needs guest Linux + guest-arch children. |
| `RISCV64_EMBEDDED_LINUX` | **Low–Medium** | **High–Very High** | Same + board DRM/KMS after desktop Linux. |
| `RISCV_EMBEDDED_HOST` | **Low–Medium** | **High–Very High** | Core embed may be cheap; risk is complete guest→host service surface. |

**Combined Path A manager cost (rough):** if the product must be a **first-class
UI on each** of MIR, WASM-linear host, and RISC-V Linux, pay roughly
**three independent B integrations** (plus browser/embedded extras). Path A
smoke only proves **A**, not any **B**.

### 6.3 Four external L3 VMs — relative ranges

Recommended **implementation order to test** (not Path A order):

1. **JVM classfile** (first)
2. **.NET CIL**
3. **WASM GC**
4. **Lua 5.4** (last for the *real* backend)

| L3 target | Shared stack reuse | Per-target emitter/loader/prims/OS | Combined relative | Uncertainty |
| --- | --- | --- | --- | --- |
| **JVM classfile** | High (UI/Message/oracle shared) | **Medium–High** | **Medium–High** overall once shared paid | Classfile + JNI/FFM host bindings well-trodden; only partial L3 smoke today ([vm-jvm-l3-smoke.md](vm-jvm-l3-smoke.md)) — not a full printer or manager. |
| **.NET CIL** | High | **Medium–High** | **Medium–High** (often near JVM) | Hosting / PInvoke / AOT variants; similar object-model lessons to JVM if JVM went first. |
| **WASM GC** | High for native-hosted; lower if browser-hosted UI | **High** | **High** | Distinct from Path A **linear**; GC proposal + loader/verifier; B jumps if UI is browser-split. |
| **Lua 5.4** (real backend) | Shared UI helps little for value model | **High–Very High** | **High–Very High** | Register VM; tagged values / tables / upvalues; **version-locked chunks**; **no standard UI** — most idiosyncratic of the four. |

**Lua smoke vs Lua backend (explicit):** emitting **Lua source** as a cheap
readability/smoke printer is **Low** and useful. That is **not** the cost of a
faithful **Lua 5.4 bytecode** backend plus manager/UI identity. Direct bytecode
+ manager/UI is why Lua belongs **last** among the four for the real backend.

Do **not** score "Lua Medium because source print is easy."

### 6.4 When the four L3 targets can be cheaper than Path A manager ports

Compare **combined** cost of (shared L3+UI once + four per-target slices) with
**independent** manager/UI ports on MIR + WASM-linear + RISC-V (and optionally
browser).

The four L3 targets are **defensibly cheaper** when **all** of the following
hold:

1. **Shared stack exists or is committed once:** L3 frontend + native oracle
   semantics + myxa_manager UI on BACKEND/FILE/PROCESS are paid **once**, not
   per VM.
2. **Manager/UI dominates:** product effort is mostly overlay, files, process,
   0.1.1 terminal — not tiny kernel bring-up (Path A **A** is already Low–Medium).
3. **Path A would multiply B:** shipping the *same* product UI on MIR, WASM-linear
   host, and RISC-V Linux means roughly **three** full seam/UI validations (more
   with browser/embedded), whereas four L3 targets share one UI and differ mainly
   in emitter/loader/prims/OS adapters.
4. **Managed hosting is acceptable** for those product surfaces (JVM/.NET/Wasmtime-GC/Lua
   host), i.e. the goal is not "native MIR/WASM/RISC-V executable is the only
   ship vehicle."
5. **Identity rules stay cheap:** no project to reify host objects as LMX
   Structures; physical prims + Message/turn remain the bridge.

They are **not** cheaper when Path A only needs **executor/smoke** (no product
UI on those ISAs), when each L3 target would still fork a separate UI, or when
the team must ship native ISA binaries as the primary product with full UI on
each.

### 6.5 Interpretation (short)

- **Path A** stays the verified **executor** track (MIR → WASM-linear → RISC-V).
  Its smoke does not move any manager **B** cell to proven.
- **Four L3 VMs** are a **separate** product/portability track. **JVM first**,
  then CIL, then WASM GC, then Lua bytecode backend last.
- **Native L3 interpreter** anchors semantics for both tracks; it is not scored
  as a competing fifth VM.
- Older "managed = High–Very High on both axes, deferred equally" scoring under-
  stated shared UI amortization and incorrectly treated JVM as exclude-able.

## 7. Shared one-time vs per-profile / per-target work

**Shared one-time (seams + L3 oracle + UI):**

- Keep BACKEND / FILE / PROCESS ABIs stable; headless oracle remains the
  correctness baseline for new backends
- Mode contracts: 0.1.2 pipes (exists) vs 0.1.1 PTY/ConPTY + terminal-state engine
  (new)
- L3 binary-graph frontend + Message/turn/identity (native interpreter oracle)
- Acceptance: overlay/UI; workspace file visible to child; 0.1.1 shell/editor;
  resize/Unicode/keys/mouse/exit; explicit fail for unsupported
- Message ingress for foreign callbacks (PROCESS_SEAM §6); no Qt; platform state
  outside Message core; **no** mapping of JVM/CIL/GC/Lua host objects into LMX
  Structures

**Per Path A profile:**

- MIR: import resolver; interpreter vs JIT test split
- Wasmtime linear: import table + memory validation
- Browser helper: protocols + helper process stack
- RISC-V Linux / embedded: guest packages or DRM behind BACKEND
- Embedded RISC-V host: syscall/call handlers without claiming full Linux

**Per external L3 target:**

- Emitter + verifier/loader + physical primitive table + OS-service adapter into
  the **same** seams — JVM, CIL, WASM GC, Lua 5.4 each pay this slice; they do
  not each rebuild the manager UI from scratch if §6.1 holds

Win32 has many implementations/tests already; that inventory orients ports, it
does **not** measure remaining effort by file count.

## 8. Sequencing recommendation

**Path A (separate, executor/smoke):** keep MIR → WASM-linear → RISC-V as
regression only; do not conflate with L3 printers.

**Manager-facing Path A profiles (product UI on native hosts):** inventory
seams; reuse headless+Win32; prefer `MIR_NATIVE` then `WASM_NATIVE_HOST` before
browser/embedded RISC-V.

**Four external L3 VMs (test order):**

1. **JVM classfile** — first candidate to prove shared L3→bytecode + prims + seams
2. **.NET CIL** — second; reuse JVM lessons on managed identity boundaries
3. **WASM GC** — third; keep Path A linear evidence out of this cell
4. **Lua 5.4 bytecode backend** — last; Lua **source** emission may smoke early,
   but the real backend (register VM / tables / upvalues / version-locked chunks /
   no standard UI) waits until JVM/CIL/GC have exercised the shared stack

Interface agreement for L3 printers still applies ([vm-porting.md](vm-porting.md));
this order replaces "defer all four equally / exclude JVM."
## 9. Citations (references to verify)

SDL3/ttf wiki; libuv; libvterm; Linux PTY / Windows ConPTY notes; Wasmtime C API;
Emscripten websocket; Node `ws` / `node-pty`; QEMU virt / VirtIO GPU; Debian
riscv64 packages; MIR upstream platform list; libriscv; CheerpX/WebVM licensing.

## 10. Ticket closure checklist

- [x] Working file: `steps/mixa-vm-integration.md` (54 + **72** complexity model)
- [x] Consistency note in `steps/vm-porting.md` → four L3 VMs + this §6
- [x] `python tools/check_docs.py` (run at commit time)
- [x] `git diff --check` on the committed paths
- [x] Commit/push **only** `steps/mixa-vm-integration.md` and `steps/vm-porting.md`
- [x] Preserve Fable WIP / Grok locks / untracked (not staged)

No downloads, no builds, no VM runner or source edits in this ticket.

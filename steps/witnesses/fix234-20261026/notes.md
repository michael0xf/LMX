# Allocation helpers in ordinary L2

Date: 2026-10-26. Verified234 moves 20 allocation and text-buffer helpers
from the handwritten frontend to ordinary L2. Base main is
70dca909f355af99e89d17058ecf6b97ac4324b4. One source-only whole SHORT
finishes with exit0, nine smoke rows and zero failures. G1 actually builds
G2; both start, hash and replace the working tool. This remains the mixed
bootstrap, not source-closed S8.6.

## Source and build selection

Module8899731C replaces 20 old bodies,385 lines, and20 matching prototypes.
The other2052 regular frontend definitions and original root storage remain
unchanged apart from selected identifier renames outside strings/comments.
The new module uses32 local address aliases to19 existing compiler cells;
it adds no module storage. All19 cells precede the sequential body import
at frontend1085; the API predef is at5. Eight literals,113 control rows and
84 call sites preserve their contents and order.

The text_clone local length becomes text_length. tok_tx passes a.data and
a.length with the same old const-char-pointer and size_t C formal types.
Allocation accounting, raw realloc behavior, partial-failure cleanup and
room_tag restoration retain the old ordering. Consumer changes are14
name-only occurrences: xfree6, bound_alloc5 and tx_cat3. No parser,
grammar, admission rule, guard or alternate implementation is introduced.

Recipe05095665 exports all20 functions in module order. It removes52
generated targets, including the new module/API/C header, then translates
helpers, allocation helpers, receiving source and Consumer uses before
their consumers. Generation failure returns instead of selecting old code.
The ordinary runtime list981E1316 adds the new module exactly once:
49runtime/compiler/support +0driver +1libc ABI +8tools +17tests =75 inputs.

## Actual cold chain

Warm seed3632 finishes0, executable65FCD5C8. It compiles the recipe using
58 separately supplied generated declarations; it does not execute the
new allocation module. Cold02 instead receives75 maintained inputs and
no prior generated headers. Source-copy93296 and manifest3591 finish
0/75files/0failed; source75 manifestB963D61F passes independent GNU checks.

Whole SHORT41954 runs17:05:19.9965451–17:48:01.2934543 UTC,
2561.2969092 seconds, actual terminal0. Prelaunch free virtual memory is
4102944 KiB, above the838861 KiB guard. The existing nine-row smoke set passes.

| Artifact | Actual SHA prefix |
| --- | --- |
| Frontend source / C / executable | B7717BE4 / B5FA00B0 / 891EFA19 |
| Generated allocation L1 / API / C header | 1916AFB1 / 16D51747 / EB7C2D13 |
| Production / observed runtime object | 120A0981 / DC776EE3 |
| G1 / G2 and working executable | E86E91B0 / 143CA08E |
| Both tool L1 / C / object | 4AC929A8 / 2BD41939 / 226406F8 |

Completed G1 L2/L1 outputs are pinned at17:22:25 UTC while G1 C compilation
is live and neither executable exists. G2 matches those two expectations
before its C compilation finishes, at17:39:54.8847267 UTC. Object equality
is observed after completion, not predicted. Both generations start,
hash and replace; working/G2 raw cmp is0 and EXE-SAME returns1/exit0.

The actual G2 language verifier and independent GNU checks pass source75,
expected2, canonical5 and runtime49 with zero failed files. Runtime49
compares all selected canonical runtime/compiler inputs with consumed
cold bytes; equality of every canonical fixture is not claimed.
Five source patches replay from published233 with GNU --fuzz=0 and
reproduce canonical5. The inherited native_closure_values snapshot remains
distinct from canonical, as in previous slices.

Serial dependency-only readback uses the actual component flags and selects
15 frontend and40 runtime headers, all generated under this cold stage.
It performs no second C/object build. Actual records and commands are in
the adjacent actual-* and cold02-* files; full source pins are in the
canonical5 and runtime49 manifests.

The whole command accidentally used the private cold-stage root instead
of its prepared fresh runs directory. Its recorded command/checkpoint
retain that mistake; the run was not restarted. The protected implicit
diagnostic output was not inspected, hashed, copied or staged. Subsequent
manual language commands use separate fresh runs directories.

## Preserved actual values

All four existing native/forced root0/1 owner runs retain:

```text
calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
counts A1=42 A2=42 B1=43
after A1 count100 A1=101 A2=43
runtime r=142 p.y=42 p.x=1 p.pad=9 q.w=10
refusals C=30 Thin=33 Far=34 y=2
seven unused=3 called-plus1=8
```

Four logs and five source fixtures are raw-equal to233. Thirty-one actual
source/compiler/runtime/program/object/log pins match their records.
All four owner runs link production120A; observedDC776 is built but not
linked into them. Forced A/B/M method children have ordinary graph bodies
without native assignments; constructor initializers retain native entries.
C-door owner paths may remain native. No new per-operation body-walk trace
is claimed.

Point/Leaf are declared layouts, not the required Structure assembled
from previously unknown graph fields. The final A2 increment is not followed
by a new A1 read. These preserved values do not close general runtime
admission, complete Consumer-interface narrowing or retained/copy-callable
obligations.

## Remaining work

Common used-interface narrowing and UNKNOWN handling, clean native/Q49,
remaining frontend/backend/libc/tooling closure, source-closed S8.6 and
mail T01–T26 remain OPEN. Slice235 has a separate warm recipe build for
150 more functions;236 is source-only preparation for101 functions.
Neither is included in this acceptance. No broad suite or new runner was added.

Packet text copies use LF line endings; the API copy also omits one trailing
empty line after the first diff-check rejected it. Raw source/output pins
refer to the unchanged consumed stage. The normalized five packet patches replay with
GNU --fuzz=0 and reproduce all five canonical source pins.

Semantic and grammar generation finish0. Documentation checks pass35 paired
semantic chapters,14 implements cases,27 grammar sections,44 verbatim excerpts
and615 imported files. Index line endings are LF; staged diff-check is0
after the packet API-only EOF cleanup. All five staged source blobs are
raw-equal to the verified canonical pins.

# Bootstrap protocol, slice 170 (L2 tool foundation)

A record of commands that were actually executed once, interactively, before
an L2 runner exists (Codex answer Q3 to CODEX-AUTHOR-TESTS-SCRIPTS-L2L3-
20261022T222439Z: a one-time platform bootstrap is allowed; it is evidence, not
an executable recipe). Every later build and check is done by the maintained
L2 runner. Paths: R = C:/Nyasha_Planet/LMX, P = R/build2/codex_unevaluated169
(parent169), N = R/build2/opus_l2tools170 (this stage).

## 1. Stage inputs (2026-10-22, Git bash, GNU coreutils)

    mkdir N
    grep -o '"Path": "[^"]*"\|"Sha256": "[^"]*"' R/steps/witnesses/used-scope-20261020/unevaluated169-inputs.json \
      | sed 's/"Path": "\(.*\)"/P \1/; s/"Sha256": "\(.*\)"/H \1/' \
      | awk '/^P /{p=$2} /^H /{print tolower($2) "  " p}' > N/inputs170.sha256
    (cd P && cut -c67- N/inputs170.sha256 | xargs cp --parents -t N)
    (cd N && sha256sum -c --quiet inputs170.sha256)

Result: 281 manifest rows, no protected basename among them, all 281 copied
files verified; the stage holds exactly those 281 files plus inputs170.sha256.

## 2. Hand builds before the L2 runner existed (2026-10-22, Git bash, interactive)

The exact command lines, with their outputs, are in the session's transcript (Claude Code session
b9cb1007-1f82-49a7-84a0-415eacd95981, published as https://claude.ai/code/session_0173C9Du7JFDwCesdY74YyFM;
rows of 2026-10-22T22:42Z .. 2026-10-23T01:18Z); the recipes, with G = C:/Qt/Tools/mingw1310_64/bin/gcc.exe
and every step run in N/src:

    frontend:  R/bin/l1trans.exe src/l2src/l2_application.h.lm1 N/headers/l2src/l2_application.lm1.h
               cp src/l2src/l2trans.lm1 OUT/frontend-source.lm1
               R/bin/l1trans.exe OUT/frontend-source.lm1 OUT/frontend.c
               G -pipe -std=c99 -O0 -Wall -Wextra -Werror=implicit-function-declaration -Werror=implicit-int
                 -Werror=incompatible-pointer-types -Werror=discarded-qualifiers -I N/headers
                 -I B/codex_header98_source_control_06/includes -I R/build2/includes -I R -I R/lm1/build -I N/src
                 --param ggc-min-heapsize=16384 --param ggc-min-expand=20 OUT/frontend.c
                 B/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o -o OUT/l2trans.exe
    runtime:   R/bin/l1trans.exe src/l2_eternal_driver.lm1 OUT/driver.c
               G <the same strict flags at -O2 -fstrict-aliasing, without R/build2/includes> -c OUT/driver.c -o OUT/driver.o
               G <the same> -DLMX_OBSERVE_WALK -c OUT/driver.c -o OUT/driver-observe.o
    program:   FRONTEND [--walk-methods] SOURCE [PARTS] B/l2_harness/codex_consumer49_full_01/src/convert.lm2
                 B/l2_harness/codex_consumer49_full_01/src/primitive.lm2 OUT.lm1
               R/bin/l1trans.exe OUT.lm1 OUT.c
               G <the strict flags at -O2 -fstrict-aliasing (-O0 for lmxtool-09)> -Dmain=l2_generated_main
                 -Dlmx_root_launch=l2_driver_root_launch -Dlmx_merge_owned=l2_driver_merge_owned
                 -Dlmx_merge_profiles_owned=l2_driver_merge_profiles_owned
                 -Dlmx_merge_used_owned=l2_driver_merge_used_owned -Dlmx_service_post=l2_driver_service_post
                 -c OUT.c -o OUT.o
               G OUT.o RUNTIME/driver.o B/l2_harness/codex_impl56_public_focus_01/gen/l2_libc.o
                 [-lshell32 -lbcrypt] -Wl,--strip-debug -o OUT.exe

| label | what | SHA-256 |
|---|---|---|
| frontend-01 | 169 + bitwise operators | source f3efbb56ad8f5e06..., C d493a2696c7bb377..., exe 481f869056817aad... |
| frontend-02 | + os branches | source 96ac9c9fbad72267..., C eee0cdb10b7100be..., exe 1f76480079597f2f... |
| frontend-03 | + l2_source_atom_n reset | source 28e19548ce4fd09c..., C 5630f697fd681659..., exe 60823da4a90efc56... |
| frontend-04 | + declared-exits contract | source 1e14b4228ee8c2e6..., C a88dca0b8ba165b1..., exe 10c2fe1079948bc0... |
| runtime-00 | 169 kernel | driver.c 67392efa7ea1a1c3... (= actual-02's), driver.o c026245020cc2e54... (= actual-02's, byte for byte) |
| runtime-01 | failed | l1trans: "cannot read import l2src/lmx_walk.lm1" (no output) |
| runtime-02 | + the observation channel | driver.c 84925bacafb54f8a..., driver.o c026245020cc2e54... (= actual-02's), driver-observe.o 0f66597e13f96d38... |
| lmxtool-02 .. -07 | the tool at -O2, growing | exe d92f53bd.., 736019a6.., f13f02df.., 0c4f38fe.., 6a9a8deb.., c8165de0.. (-01 and -08 failed: no exe) |
| lmxtool-09 | the tool at -O0 (-O2 of the 51 MB C ran out of memory) | lm1 72,752,744 bytes, C 51,969,318, exe 65651554562d34e6... |

## 3. Built by the L2 runner (each output directory holds the runner's record.txt)

| label | built by | result |
|---|---|---|
| runtime-03 | lmxtool-09 `build-runtime` | driver.c, driver.o, driver-observe.o identical to runtime-02's |
| frontend-05 | lmxtool-09 `build-frontend` | source and C identical to frontend-04's; exe b41f36bc0175cde6... |
| tool-10 | lmxtool-09 `build-self` (frontend-05, runtime-03) | exe 6af19563052995984040... |
| tool-11 | tool-10 `build-self` | lmxtool.lm1, .c and .o identical to tool-10's |
| frontend-06 | tool-10 `build-frontend` | + the os branch in the method census; source 5b29bf1402e42566..., C 21bf57611b9d7962..., exe 93d23fec116672ed... |
| tool-12 | tool-10 `build-self` (frontend-06, runtime-03) | + the twins row; exe f734cb088bd6d55c... |
| runtime-04 | tool-12 `build-runtime` | + the observation's name of a sub's occurrence: driver.c 2a14fbe278e5d82f..., driver.o c026245020cc2e54... (unchanged: production identical), driver-observe.o 0fed25c40a289... |
| tool-13 | tool-12 `build-self` (frontend-06, runtime-04) | an intermediate builder (its sources were edited while it translated) |
| tool-14 | tool-13 `build-self` | the final sources; exe 498c67b46868207f... |
| tool-15 | tool-14 `build-self` | lmxtool.lm1, .c, .o identical to tool-14's; EXE identical apart from the link stamp |
| tool-16 | tool-15 `build-self` | + the self-test's child lmxchild; exe 3a48d16ba83412341198... |
| tool-17 | tool-16 `build-self` | lmxtool.lm1, .c, .o identical to tool-16's; EXE identical apart from the link stamp |
| tool-18 | tool-17 `build-self` | + dir_make, text by the C library; exe b87ad810a6753a5b5ea0... |
| tool-19 | tool-18 `build-self` | the final tool: see section 4 |

## 4. The fixpoint and the final runs

tool-19, built by tool-18 from the same sources (unchanged during both builds, checked against
runs/tools-sources-tool18.sha256): lmxtool.lm1 86702f388ec8718d8ed3bc7ef39e2dea68bb272df7f16c74cbfcce4fc66ed475,
lmxtool.c 2be45e1ba6f9857d24df9082098f11b274db178aba74a4faaccdeb91c3535020, lmxtool.o identical to tool-18's
(`lmxtool same`), EXE 9af4aee382a71eb80d1951cc06b0151f088387d0fc1b92099b4f5a5e9a11c66f identical to tool-18's
apart from the link stamp (`lmxtool exe-same`). Every later check is a run of tool-19: the isolated gate
(iso-03), the U0 replay's `same`, the evidence manifest and the long SHA-256 vector (notes.md section 5).
The corpus replay (runs/replay-02) ran on tool-10, an earlier build of this runner: replay and replay_one
were edited after it only where replay makes its output directory (dir_make), and the text helpers then
still moved bytes one L2 step at a time.

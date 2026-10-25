# Fix224 local completion: P0 C/compact-token scanner source port

Date: 2026-10-25. ONE whole224 SHORT has completed locally, including
frontend, runtime, smoke, G1 and G2. This packet does not yet record a
published224 SHA or publication acceptance. It is the bounded scanner
source port and the mixed current bootstrap, not source-closed S8.6.

## Published base and four promoted source paths

Base code223: `4540a067dda8bf17a38c9031888d0d7be3708948`.
Base record223: `d8a89b41b2b74eec0c17d2b39af7c87160e09b48`.
That published result is the bounded physical-family foundation, not general
immutable/admission closure.

The four tested files were separate from that published base:

| Draft path under build2/codex_fix224/draft | SHA256 |
| --- | --- |
| p0_scan.lm2 | 09DB50493FC66D840E6FE8A5FBF2E379EA7179E14EFBFFBCA4C1F07AF9F06A02 |
| l1src/parser.lm1 | 9CD9244FF87D4F4A95E4FFEDBC4B24F92FC8F175F5901EFE6AE575BBC0F1254C |
| tools/l2/build.lm2 | B7828EFA53B71595831A8C668312A92808153A75BEF1BD796F2DF3BE0DC3AC86 |
| tools/l2/inputs/runtime.list | AFF86B5F340ABBD7586E5A55B919C8107AED8B01D7D02FDF0A142761790FEB6E |

Their maintained paths are dev/l2src_sandbox/p0_scan.lm2,
dev/l2src_sandbox/l1src/parser.lm1, tools/l2/build.lm2 and
tools/l2/inputs/runtime.list. Main has promoted exactly these four paths
with apply_patch, preserving the four tested SHA256 values above. The
canonical language verification subsequently completed as noted below;
promotion is not represented as a published canonical revision.

Main prepared source-224-from223.patch in this packet for these four paths.
Its completed GNU replay with `--fuzz=0` in build2/codex_fix224replay01
returned 0 and reproduced all four selected source SHAs, according to main's
readback. That source replay is not a build or bootstrap completion.

## Source scope and ordinary generation route

The 235-line scanner source moves thirteen existing algorithms from the
maintained L1 parser into one ordinary L2 machine module. The six exports are:

- lm_p0_starts_c_prefixed_quote;
- lm_p0_scan_c_char_token;
- lm_p0_scan_c_prefixed_quote_token;
- lm_p0_starts_c_surface_atom;
- lm_p0_scan_c_surface_atom;
- lm_p0_scan_compact_atom_piece.

The seven private functions are registry compact-atom scanning, bare
identifier start/rest, hex-digit and number scanning, C quoted-token
scanning, and the C-surface top-boundary predicate. The removed unused
L1 helper is lm_p0_scan_builtin_compact_atom_piece. These are genuine
algorithm bodies, not a copy of the old L1 program printed as a string.

The parser now predefs l2src/p0_scan.lm1 alongside the already generated
p0_own/p0_text modules; the old selected scanner bodies are removed rather
than retained as a second callable implementation. The module uses the
existing P0 header, p0_text API and explicit ctype dependency. This is a
port of existing scanner behavior, not new token grammar, a second parser,
or an expanded runner/test system.

The existing bld_p0_l2 recipe now deletes fourteen generated targets before
generation (the prior eleven plus p0_scan.lm1, p0_scan.h.lm1 and its C
header). It calls the ordinary bld_machine_module through the explicitly
selected previous frontend with the six exports and --header. A failed
generation returns failure; it does not select an older scanner/header.
The runtime source list adds the one maintained p0_scan.lm2 input.

## Preserved failed attempts and source transport

The first scanner source is retained under
build2/codex_fix224/refused-scan01/p0_scan.lm2, SHA256
`C9B1B311E3F14C0000DEDD9CB4880B44ECA98313E3B425DB7A5AB9A7E79491CE`.
Its FE.log reports parse error 13 at 71:9: source level decrease needs a
tail cutter. The correction adds five existing tail cutters, with no other
line changes (230 to 235 lines). The refused log is preserved; the similarly
named draft translate-01 log also records this refused attempt and is not
credited as the successful corrected translation.

The first driver manifest attempt used the wrong source root and returned
HASH-FAIL l2_eternal_driver.lm1, MANIFEST 1/1, outer exit 1. It performed no
driver copy. The retained cold01/trace/driver-manifest-01.log records that
failure. The corrected driver-copy-02.log gives STAGED 1/0 and 13 driver
checks/0 roots, using the correct dev/l2src_sandbox/harness source and the
previously pinned A89128FC driver. The failed evidence was not overwritten.

Cold transport uses the existing manifest/stage-copy commands and fresh
working directories. It transports named sources from the published base,
then overlays the explicit scanner/parser/recipe candidates; no previous
stage/output tree or generated C/L1 headers/objects populates cold01.
The maintained70 selection has 46 runtime/frontend inputs, two P0 inputs,
one driver, eight tool parts and thirteen test files. The final manifest is
build2/codex_fix224cold01/pins/maintained70.sha256, pinned by the launch as
`94AAACAE3C77AE308F74D44BE4BC0093FB8588E8E15F3E158EA1D8FFF664FB28`.
The thirteen selected test files are not a complete parser/runtime corpus.

## Completed warm recipe seed

The seed is deliberately mixed and explicit: 118 named files from completed
runtime223 provide a generated header capsule and unchanged support/tool
parts; the candidate recipe is supplied separately. It is not a cold or
source-closed seed. Controller seed223 is 720FB50C; previous frontend is
DD7FD2EE, and the link uses production runtime223
`E0A4AAA710446F3DB87067D1C652869A4A155EE847AE58D1A8B28861F0DA8C60`.
None of those reused seed inputs proves cold scanner generation.

Existing build-self session65603 terminated 0. Main observed the interval
21:05:20.5234636Z to 21:20:20.3014329Z UTC. The completed
build2/codex_fix224seed01/seed-tool-01/record.txt binds FE, backend, serial
C compile and link commands, each exit 0, to these outputs:

| Seed artifact | SHA256 |
| --- | --- |
| lmxtool.lm1 | E5E2DC5CF7145775D7FC5254284FAEB3C1D8ADC2C43CD12B04002ABD40BE3F4D |
| lmxtool.c | F4511647505F73AFD5463A63FC8AF9F6718691DABEB86AA9AEF045AF40BE0226 |
| lmxtool.o | 33EE20D32F1E7C6292F018A4215BB5F98E3B386C219E7DAD4A7BFAE6A8649FA3 |
| lmxtool-tool.exe | 39412FAB7EF0D166D593565BBAE9B6ED89774C63C97C943297E7087B636302A3 |

Startup/hash session52145 terminated 0. Its actual log gives the intended
B7828EFA recipe digest and 13 driver checks/0 roots. The command and seed
boundary are saved under build2/codex_fix224/pins; the actual build/startup
logs are under build2/codex_fix224seed01/trace.

## Completed ONE cold SHORT: frontend, runtime, smoke, G1 and G2

ONE existing whole bootstrap quick, session81707, terminated with actual
outer exit 0. Main observed start 2026-10-25T21:22:02.2742416Z and launch-shell
end 2026-10-25T21:54:18.5022611Z, elapsed 1936.2280195 seconds. These are the
shell/terminal observations, not log-embedded phase durations. Its exact
command is cold01/pins/bootstrap-quick-01.command. It used the new 39412FAB
recipe seed and explicit previous frontend DD7FD2EE; no separate unchanged
frontend build was performed first, and no second SHORT was run.

The cold frontend component has actually completed. Its closed record is
build2/codex_fix224cold01/boot-quick-01/frontend/record.txt, not a reading
of an unfinished runtime/G1/G2 record. It shows fresh P0 own/text/scan
generation through the previous frontend, followed by backend and C compile
exit 0 for the new frontend.

| Cold frontend artifact | SHA256 |
| --- | --- |
| compiler source | FB61904843813AE627468FD418409E2320E471C80E7B307EB298F6AAD9CE9216 |
| frontend.c | 486FA464C5A88E7C4C25E1D234717BFEF593046CB89FD346B0B0A69F31F537A0 |
| l2trans.exe | 7FBC1A561993B4B44F6B77FFC933F4EBA473D48E36C86BEA3247D718D3C63627 |
| freshly generated p0_scan.lm1 | 65023C1A6E608947D356A02EA56ACEC7297B59ED12013CF0A7362CAC6A39C943 |
| freshly generated p0_scan.h.lm1 | B54BC16CBA6A69672291B6CE57EC7B02766659DFFDB34C1B28FD5BA119274C7A |

The fresh scanner L1/API digests match the corrected standalone generated
outputs. This is executed generation of the selected scanner source before
its frontend consumer; it is not merely the presence of a generated file.
It does not establish every scanner branch or an interpreted helper body:
these machine algorithms use their ordinary native C ABI.

The cold runtime component has also completed. Its closed record is
cold01/boot-quick-01/runtime/record.txt. The regenerated common C-header set
contains 55 files. Backend translation and strict production/observer C
compilations exit 0; the raw outputs match the completed223 runtime exactly:

| Cold runtime artifact | SHA256 |
| --- | --- |
| driver.c | D4863E2F21638BBFBE797FE3A799B2C018E9817993C560184F8423FB94AE4EC4 |
| production driver.o | E0A4AAA710446F3DB87067D1C652869A4A155EE847AE58D1A8B28861F0DA8C60 |
| driver-observe.o | 7ABB37B327A9D7D0F9362F0ADF61B9DE45FA3DCBDAC8F7DCC2A06509A640F760 |

The closed smoke record contains six selected rows; failures.tsv is empty.
The actual bootstrap stdout ends with SUITE 6 rows/0 failures,
BOOTSTRAP quick 0 failures and 13 driver checks/0 roots. This is the selected
short smoke, not a complete parser/runtime corpus.
Main and the read-only reviewer read all four actual lib_owner native/forced,
root0/root1 logs. Each gives calls41/41/42/42/43/42, counts42/42/43,
A1=101/A2=43 after the A1 count100 change, runtime candidate142 and
p.y42/p.x1/p.pad9/q.w10, refusals30/33/34 with y2 and callable3->8.
Root0 reports13 driver checks/0 roots; root1 reports17/0. The smoke record
binds the current production runtime and program/library bytes to exit0 of
each of these four runs. This is not every signature/runtime-callable case.

G1's closed build record shows actual frontend/backend/C compile/link exit0.
Its independently hashed L1 is C4AA16C39E965FDE433A6A6F51CAB281316D8C7285AADD0E57DD1E843DD7AD6F,
C is0CECD74178282F8E71ED0A354A13826E82EA2A010C74A8595F08957514B6E69C,
object is1A0703C03AE1303E21C3559B8314F9715FAF7A267FAAC37725A1DC83DBFA5ACA,
EXE isE005B9210DB8BF468864B8FBB3FE477BA439F4DE097299F808F3D27E37A8287E.
At the21:40:17Z observation, G1 startup/hash exited0, working lmxtool.exe
had exactly the G1 EXE bytes (independent SHA and GNU cmp0), and G1 process
PID16888 had launched frontend PID4804 to build G2. The G1 and mixed seed
L1/C outputs differ; no seed/G1 byte-equality claim is made.

The two expected G2 L1/C hashes were fixed from completed G1 outputs at
21:35:25Z while both G2 targets were absent. Its expected object hash was
fixed from the completed G1 object after the21:39:11Z process snapshot,
before G2's L1/object existed. The original two-file and one-file future
manifests were then checked by GNU sha256sum after completion: all three
entries OK, exit0. These are predictions fixed before G2 outputs, not
expectations inferred from completed G2 bytes.

G1 actually built G2, as bound by g1-builds-g2-record.txt. G2's closed build
record shows FE/backend/C compile/link exit0; its executable SHA256 is
`4C2A0F1B1EC9D1F2D0389F3695BA7C0C76FAEBD1ACD3405AE8001D4F1C889281`.
G2 startup/hash exited0. The final working lmxtool.exe replacement has
exactly those bytes by raw comparison0 and independent SHA256. The first
G1 replacement had already been captured before G2, as described above.

G1 and G2 raw L1, C and object match: respectively C4AA16C3, 0CECD741 and
1A0703C0 (the full hashes are recorded above and in the future manifests).
The two raw executable hashes differ. The existing EXE-SAME check later
returned1/exit0 (session98147): normalized PE equality, not raw EXE equality.
The successful whole SHORT is the mixed bootstrap described here; it does
not remove the external backend, libc object or other source-closure debt.

After actual whole-SHORT terminal and with no live GCC, main ran ONE serial
GCC-MM dependency-only command, exit0; this was not another C compile,
link or runtime execution. frontend-deps-01.d selects exactly five
frontend C headers, all under this cold stage's generated headers tree:
p0_own API, P0 ABI, p0_text API, p0_scan API and l2_application. Ten generated
frontend C headers must not be reported as ten headers read by this build.

The whole completion, replacement observations and dependency-only command
are bound by completed-224.txt, the two startup records, closed G1/G2 build
records, future manifests and frontend-MM-01.command. Session/UTC
observations are main's terminal observations; raw diagnostic logs are not
claimed to embed those times.

## Evidence transport and completed byte checks; publication still OPEN

evidence-transports.tsv maps 47 completed raw evidence files to separately
LF-normalized packet copies. Normalization changes copy bytes only; raw
commands, closed records and their source/output bindings remain the
authority. The original failed scanner and wrong-root driver attempt are
preserved and are not credited as successful generation or transport.

The artifact selection has 234 paths. Main subsequently read actual
completion of canonical language verification: VERIFIED 4 files, 0 failed,
13 checks/0 roots, exit 0. Artifact manifest generation also completed:
MANIFEST 234 files, 0 failed, exit 0. Independent GNU verification of the
four candidate source hashes and 234 artifact hashes returned 0. These
completion observations are main's readback, not a second reviewer run.

Main subsequently read terminal0 from artifact language verification26230:
VERIFIED234files0failed/13driverchecks0roots. The manifest SHA256 is
CAF92620DA1391C6CC5C4FFA72B6A1534E0A8C8A3F4F91DA08923C0737126093.
The existing EXE-SAME98147 also terminated0 with result1. The selection
deliberately omits the large seed/G1/G2 L1/C/object files already bound by
their closed records and the three future hashes; it does not claim every
raw artifact was copied into this packet. The four final verification logs
are transported separately in post-verification-transports.tsv, outside
the already verified234-file manifest. Publication SHA/acceptance will be
recorded after actual publication, not invented here.

Final notes/current/checklist publication pins are separate from the
artifact selection to avoid a cyclic artifact-manifest claim. Draft225
and its source-only preflight are not inputs or results of this224 release.

## Remaining boundaries

This scanner port does not complete the remaining P0 parser, frontend,
L1-to-C backend or driver maintained-source closure, removal of the external
libc object, language-owned tool/test closure, or S8.6 self-build. General
directional/Consumer and runtime-callable/signature admission, immutable
first-construction and per-path write/address/dirty/UNKNOWN effects,
legacy profile/root-span authority debt, native/walk equivalence beyond
the actually observed cases, Q49 and mail T01-T26 remain OPEN. No new broad
test campaign is credited or requested in place of source porting.

The notes reviewer initially wrote only this notes file; main subsequently
added the smoke/G1 observations, and the reviewer updated this file alone
for local whole-SHORT completion. The reviewer changed no frozen source,
other documents or build outputs and ran no build or test.

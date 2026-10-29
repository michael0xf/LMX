# Slice240 — candidate48 components, source publication and docs streams

Base main: `bf34899f28b6e7d0d6b52580cbd56ee80858cb75`. Codex is sole writer/build.
P=`build2/codex_fix250generationchain01`; commands below use absolute R/P paths.
R=`C:/Nyasha_Planet/LMX`; STAGE48=`P/cold-candidate48-tool`;
FE46=`P/cold-candidate46-tool/fe46/l2trans.exe`;
BASE=`P/cold-candidate45/boot45/g2/frontend`; RT45=`P/cold-candidate45/boot45/g2/runtime`.
All tool CLI commands have the normal `0 entry 0 --` prefix. L1/OLDER are
`C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt` and `C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt`.
Every language invocation had its own fresh private CWD. No source grammar,
admission rule, test assertion or handwritten header fallback was introduced.

## Source and executing bytes

The selected159 inputs now match [the maintained manifest](../../../selfbuild/inputs.sha256):
SHA256 `514564A99268D980EC7CD4A32F756E32AF4DADC7695705DDA8D965CF6F676B7A`.
The list remains `E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF`.
Compared with baseline45, exactly11 selected files change: emit diagnostic,
suite root selector/full-list row; os_file_open plus7 docs parts. The latter
replace11 temporary-stream calls and retain a failure-only phase diagnostic.
Original source45/46/47/48 snapshots and failed records remain separate.

| Executing artifact | SHA256 |
| --- | --- |
| G0 boot45 tool | A69A7EE26315C058E85FE0FA9D1EFD921B4C3032421030704948575C16997FB4 |
| fe46 frontend | 7C907E696667C6614BA64FAF304BDDB89A93BCB19291532ADAFC3D4AB807626F |
| fe46 backend | 37671678FBB1175951308B519AE8D449FDB10F1691ED3B59DFC6D6F76206C966 |
| fe46 libc | AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37 |
| fe46 C | F2A66EF111355AF400D5FF47128C2A677505D1366CD8CB9CEA41146A6500D17B |
| rt48 production | 8C2708AF530BC624F1A1C48207F00685AC5C6F5FB72843A49C4C0258277BEEDC |
| rt48 observed | 0A1C51D9BAF3B3449D65419169659DD77F1C787697CDE03821203BD3F96A2DB4 |
| rt48 C | B16D77513C3771A5E742910A418131415035C601CF8A4A1A9791180018B2A22C |
| tool48 | 4ECFF786BEA55D66525C72BCB3089FCB88628C6E8E4F00D1C779CF728C6FB274 |
| tool48 L1 | 2880C951E0052284526572FABBBC7799B29F447DD7EC08BA55299812A802FF4F |
| tool48 C | 04D5BC3C1ADF07BCA37D65C9844A8B1370F7A7EC258FDD7B9D12CA76DCA9EFD0 |

## Actual component results

fe46 finished15:33:26UTC: its frontend built, but the rebuild as a whole
FAILED15 smoke builds at L1. [First refusal](fe46-first-smoke-L1.log): missing
`l2src/lmx_array_owned.h.lm1` in the fresh stage. [Terminal](cold-candidate46-tool-rebuild-frontend.terminal.txt)
and [record](fe46-record.txt) are preserved as FAIL. Full generated emit-L1/C
diff versus boot45 is exactly the expected diagnostic literal. Backend L1/C
are unchanged; its exe differs only in the existing PE timestamp/checksum fields.

Normal `rebuild runtime R STAGE48 BASE FE46 RT45 rt48 SMOKE48` then generated
the stage's own declarations/bodies/headers before consumers. [rt48 record](rt48-record.txt),
[smoke record](rt48-smoke-record.txt), [stdout](cold-candidate48-tool-rebuild-runtime.log):
actualexit0, SUITE9rows0failures, REBUILD runtime0failures. Both objects equal boot45.
No expensive frontend replay or copied old headers was needed.

`rebuild tool R STAGE48 BASE FE46 STAGE48/rt48 tool48 SMOKE48`:
[record](tool48-record.txt), [stdout](cold-candidate48-tool-rebuild-tool48.log),
[newtool smoke record](tool48-smoke-record.txt), [smoke stdout](tool48-smoke.log).
Actualexit0, same-digest self check, newtool SUITE9rows0failures, REBUILD tool0failures.
The source-dependent header/call paths and compiler inputs are bound in these records.

Existing check46 list hash `1363FBAE143C90D983E51CD105DBEF487A06831F575DE81CF3700BFF8C7B78DF`:
`suite LIST R STAGE48 BASE FE46 RT48/driver.o OUT01` — actualexit0,
[SUITE3rows0failures](check48.log); [build/run record](check48-record.txt).
The C-door root gives7 in native/forced at root0 only; the ordinary row still
gives7 in both modes and both roots. The second-os refusal matches its needle.
Invalid-list hash `EA29D6619041DCACD2A2923E638BF9809CB5744325689DB95067D6F439015A64`:
[actualexit1, SCHEMA refusal for nf2](check48-invalid.log), as intended.
This does not prove walked execution of the C callee's body.

## Actual docs execution and evidence formatting

tool48 `docs verify semantics R L1 OLDER` — actualexit0,
[35 paired semantic chapters,14 document cases and both snapshots](docs48-semantics-verify.log).
L1/OLDER bytes remain `BDB1A641…`/`D4BB1E70…`. No leftover `lmx*.tmp` was found
in either completed docs CWD. The actual Windows stream fix therefore goes
beyond translation/linking; default-platform execution is not claimed.

Full `docs check R L1 OLDER C:/Git/cmd/git.exe PRIVATE_OUT` first reached
[66 EOL findings](docs48-check.log). Original Python and L2 checkers BOTH
require LF in index and working copy; neither assertion was weakened.
All66 paths in [the explicit list](witness-eol48.list) had indexLF and
`text=auto eol=lf`:42 workCRLF and24 mixed, all in packet238. Their raw working
bytes/timestamps were archived first at `P/witness-eol48-raw.tar`
(66 entries, SHA256 `2525349D88590E7D037E2DA881CA315D1715F924208236EEF871C88F6B12D30C`).
Ordinary dos2unix with keepdate/keep-bom restored the existing committed LF;
Git full diff for that packet was empty immediately afterwards.

The next check reached [five control-byte lines](docs48-check02.log) in one
old terminal report. Its original bytes are preserved in
[raw base64](p0-header-probe13-L2.first-run.raw.base64): decoded SHA256
`141D67AE3C91E5189F6FCFB958B32DFD8FDAAB30F3E3F3DEEAEE06F0C001F0F5`,
independently decoded and checked. In the existing readable terminal copy
only ESC became visible `\x1b`; all messages/results remain. Its new hash is
`27218E4368B6DD11896D9B7529AD8D39128DD23685125C9778FC6B643105A7BE`.
This is an explicit display representation, not a rewritten execution result.
Published stdout/record copies here use LF; original native logs remain at P.

Language [stage-copy](source48-publication.log) and [verify](source48-verify.log)
both159/0; independent GNU manifest check0. Existing source layout is preserved.
[Final full docs-check](docs48-check03.log) returned actualexit0:35 paired
semantic chapters,14 document cases,27 paired grammar sections,44 verbatim
excerpts,615 imports, links/opening and LF/control checks for12138 staged
tracked files. No lmx*.tmp remained in that fresh CWD. Scoped cached
diff--check also passed. Whole FULL/G1/G2 acceptance is not claimed by this packet.
General admission, clean/uniform native, clean-clone closure and mail remain OPEN.

Published source commit: `6dfe7bfa2d3d22768f82d15be67466690f29456a`.
FULL48 started16:24:09UTC from a NEW source-only stage copied from tracked
selfbuild, with tool48/FE46. Stage159/0, GNU0, all four checked generated/output
targets absent. It is live work, not a FULL acceptance result. Exact launch
pins/argv: P/pins/cold-candidate48-full-bootstrap.md; stdout/stderr beside it.

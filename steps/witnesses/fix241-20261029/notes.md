# Slice241 — source48 whole FULL, actual G1 and G2

Base main/origin `5b9c18c5c6202f2660fc94fbebd902c23179f0e2`.
Source commit `6dfe7bfa2d3d22768f82d15be67466690f29456a` remains unchanged.
Codex sole writer/build; this slice publishes results and documentation,
not the separate uncompiled source49/50 drafts.

R=`C:/Nyasha_Planet/LMX`; P=`R/build2/codex_fix250generationchain01`;
S=`P/cold-candidate48`; B=`S/full48`. Native originals remain at these paths.
Every separate tool CLI invocation uses a fresh private CWD.

## Actual normal FULL

Started2026-10-29 16:24:09UTC; final bootstrap receipt22:27:20UTC.
Native session8775 returned actualexit0; known parent21332/G1child9584 and
last compiler2504 are terminal. [Invocation and start pins](invocation.md):

    TOOL48 0 entry 0 -- bootstrap full R S P/cold-candidate46-tool/fe46 P/cold-candidate46-tool/fe46/l2trans.exe full48 S/tests/smoke-kernel225.tsv S/tests/full-suite.tsv

Initial tool48 SHA `4ECFF786BEA55D66525C72BCB3089FCB88628C6E8E4F00D1C779CF728C6FB274`.
The ordinary L3 stage-copy copied only the published159 selected inputs,
156 `.lm2` and3 `.tsv`, into a fresh stage:159files/0failed. Generated headers,
frontend/runtime outputs and this FULL directory were absent at launch.
[Source manifest](source48.sha256) SHA
`514564A99268D980EC7CD4A32F756E32AF4DADC7695705DDA8D965CF6F676B7A`;
[source list](source48.list) SHA
`E6FFBCFB4C4F8C2CA670961F1D22EEED25E1275F5086FEF0EE01517C494364AF`.

[Parent stdout](bootstrap.log) and [final receipt](bootstrap.txt):
`BOOTSTRAP full 0 failures`. Both generations built frontend, backend, libc,
runtime and tool. Each new frontend/runtime passed the actual full37-row
list and `OSWALK 0 failures`; each generation's executing orchestrator ran
its existing self-test0. The printed SCHEMA/INFRA
failures inside that self-test are its expected negative controls, not failed
whole-suite rows. Both published suite-failures files are empty.

[Actual G1 child command](g2-build-record.txt) pins executing G1 tool
`158ACF5CA631A9FD45400EBFAD5A7E1CDB1807DC38F129271876D0DFE7845C7E`
and G1 frontend `0C4462F3…`, invoking `build-generation full ... full48/g2`:
kind0/exit0, [G2 stdout](g2-build.log). It is not a second invocation of G0.
Both tested whole bundles were promoted. The parent then ran the actual G2
tool hash probe and all three FULL comparisons: tool L1/C byte equality and
`exe_same=1` apart from existing PE timestamp/checksum fields. G2 promotion
precedes these comparisons in the recipe, so promotion alone was not accepted.

| Actual output | G1 SHA256 | G2 SHA256 |
| --- | --- | --- |
| frontend | 0C4462F3B1D18665AA7CC274105FF38ECD2642EC9BFBEBAC708B1124F581718B | E9873EBE8EFF797200A6EB75B5211D88E1B708F742B19BCE19608A7E63B3C246 |
| backend | 9AC4EE473582F094EC397B14E30CC4E5E1F52BB462BCBFA5457AC8BADAC84621 | 519A37A453B372427B70CA599F3DFB16F76FA552F2069AD4795BBF53A3D70AEC |
| tool | 158ACF5CA631A9FD45400EBFAD5A7E1CDB1807DC38F129271876D0DFE7845C7E | A6D5EC401F9703BEEDC192BAFA6B348B43D3AE759C69DABB6AE728164AC923B1 |

Both generations: libc `AF9FDAE33655F8E6235310720787102921450F0F88F9B7BB2F365D372F553D37`,
production runtime `8C2708AF530BC624F1A1C48207F00685AC5C6F5FB72843A49C4C0258277BEEDC`,
observed runtime `0A1C51D9BAF3B3449D65419169659DD77F1C787697CDE03821203BD3F96A2DB4`.
Tool L1 `AC67B60C881D38E995E6AABF795D7945687334B7D5243BF424E3A33F8029251B`;
tool C `CC1D4E6259AFDE40FE630CBAB4495CAD1784294C47E0AF17ABE6FC4199E9BF0D`.
Final working `B/lmxtool.exe` is raw-identical to G2 tool; working bundle
manifest is raw-identical to G2's manifest (`3F3F1C00…`). Per-generation
bundle, component/suite/probe records and306-input snapshots are retained here.

The new G1 tool executes the self-test while building G2. After the normal
FULL completed, the actual new G2 tool was also executed directly:

    G2TOOL 0 entry 0 -- selftest P/g2-tool-selftest241-data B/g2/child/lmxchild-prod.exe

Fresh CWD `P/g2-tool-selftest241-run-01`, actualexit0, [SELFTEST0](g2-tool-selftest.log).
The already built child is `3ED7E75F5921F06B6FC5CBC2F4935049486864C7BF72A0941CDE550FA8DC3CF4`;
no compiler or new test system was started. Raw log SHA
`8C4DB50EBA555CB7F981EEA3D41ABF2CABC60C64F2580D88A52670065B9D18FA`;
published readable copy `E16490E87708A8ED10F65744FC77F993FF773201ECE8430F286262072E4FB970`.

## Source generation and import path checked

Actual frontend/runtime/tool command records bind source, executing compiler,
generated L1/C, headers, runtime objects and programs. In particular G1 L1
`9AC4EE47…` actually translates G2 backend-source; newly built G2 L1
`519A37A4…` actually translates its libc and frontend root before GCC links G2.
Both frontend C outputs are `F2A66EF111355AF400D5FF47128C2A677505D1366CD8CB9CEA41146A6500D17B`.

The executed supported L3 recipe `selfbuild/tools/build.lm2:1722–1763/1842`
removes old declaration outputs, writes declarations as ordinary L1 text and
removes failed outputs; generation precedes consumers. Frontend/backend
scaffold declarations likewise precede their first modules. No new L2 syntax,
parser or output mechanism was introduced for these declarations.

The selected ordinary resolver path was read: backend text1050 resolves bare
imports alongside the importing source and uses already qualified paths as
given; emit3192 passes that exact path to P0, parser4598 opens that one path.
The recipe's L1 CWD is S/src; project C include is S/headers only. This route
uses generated stage declarations and stops on missing imports, with no old
repo/dev/include/BASE header search in those paths. Historical packages are
not used as fallback by this executed recipe.

This is dependent source plus actual command/output evidence. Retained
consumed-inputs are byte snapshots, not a recursive fopen/read ledger. No
claim is made to an OS-level record of every opened file or all historical
recipes. The saved initial seed is a pinned bootstrap executable, not a
maintained handwritten-L1 source route in this selected package.

## Actual values and remaining boundaries

The existing library owner source is
`84682014F84E0B20E66FD77CD44A003B3BAEF71AD7C24695FCED0EBBD50EEA2F`.
G2 record pins FE `E9873EBE…` -> owner L1 `31B69E95…` -> backend `519A37A4…`
-> C `8CA59719…`; native executable `7214C9FB…`, forced executable `DF8E9704…`
link actual G2 runtime and the separately translated native/forced libraries.
Their real root0/root1 runs and log hashes are in the suite records.
All eight retained G1/G2 owner logs show:

    calls41,41,42,42,43,42
    counts42,42,43
    after A1.count100: A1=101,A2=43
    C refused30
    runtime candidate r142,p.y42,p.x1,p.pad9,q.w10
    Thin33; Far34,y2; held seven3; plus1(seven)8

These are actual values, not just exit/link/translation success. They do not
prove every runtime candidate or callable signature. The owner does not reread
A1 after A2 changes; the separate small future witness adds this and distinct
count-address checks, and is still uncompiled. A walked root alone does not
prove a native callee's body was walked.

The ordinary source48 whole-FULL protocol is now confirmed. Full §8/S8.6
normative acceptance still depends on the open clean-kernel/common CALL,
default/current-state, used-interface/UNKNOWN and uniform-native/Q49 work.
Retained/copy-callable boundaries are not enlarged by this result. Mail §8a
and T01–T26 remain open. No second identical FULL is scheduled; the next
connected source change uses the existing component/short-bootstrap route.

## Publication format and checks

Files in evidence.list are byte copies of exact native files before text
formatting. `raw-evidence.sha256` records those bytes; originals remain at P.
Published text copies use LF. Three intentional trailing spaces on the
self-test's empty-argument `PASS ARG 2` lines are represented visibly as
`\x20`, so Git whitespace checks preserve that information without an invisible
line ending. Native logs/assertions are unchanged. `evidence.sha256` records
these published bytes after both formatting steps.
Formatting changes no source or assertion and is not presented as a raw log.
Both manifests cover the38 core files in evidence.list; raw and published
language manifest each38/0, published verify38/0, actualexit0. The additional
G2 self-test log has its own raw/published hashes above. All use the existing
L3 tool, not a new runner.
The actual newly built G2 tool ran the full language checker:

    G2TOOL 0 entry 0 -- docs check R C:/Nyasha_Planet/L1/Lingvamyxa_spec.txt C:/Nyasha_Planet/lingvamyxa/Lingvamyxa_spec.txt C:/Git/cmd/git.exe P/docs241-out-01

Fresh CWD `P/docs241-check-run-01`; started22:41:40UTC, completed log
22:48:10UTC. [Actual checker output](docs-check.log): OK35 paired semantic
chapters,14 implements cases, both source snapshots,27 grammar sections,
44 excerpts,615 imported files, links/opening and LF for12182 indexed files.
Driver reports13 checks/0roots. The managed-session terminal was unavailable
on the following observation; no separate observed process-exit claim is made.
The completed success output and checked source return path were read; this
check was not repeated merely to recover the terminal handle. The raw log is
`P/pins/docs241-check.log`, raw SHA256
`654DA5C66051215FDAB1DAAC9718C9AFFEEEB37C5343466A0634AB9261A14D4D`;
the published LF copy is
`29ABA79D8EB5C460BE33E13BA14B8FD98EE40CDBEB57C42031A82EDFB798E056`.
Git cached whitespace
check passed after selected staging. No source or test assertion changed.

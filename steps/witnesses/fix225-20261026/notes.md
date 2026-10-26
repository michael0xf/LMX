# Fix225 P0 parser and qualified construction

Date: 2026-10-26. This slice contains the tested225 sources, based on
published224 record `f506c1e215a4192dc783a1098a185b0cc0c5f447`.
ONE normal cold bootstrap completed frontend, runtime,
nine smoke rows, G1 and G2 with outer exit0. G1 really built G2; both started
and hashed their L1, and each replaced the working binary. This remains a
mixed bootstrap rather than source-closed S8.6.

## Maintained sources and retirement

The initial15 promoted source and test-data files matched
`canonical-source15.sha256`; G1 and GNU verified that initial byte-for-byte
copy. Publication whitespace checking then rejected one final blank line in
P0. Only that blank line was removed from the checkout; the executed cold
source remains272DC7F7. The final `canonical-source15-02.sha256` records
872A0144 for the checkout and the same other14 hashes. Actual G2 verified
these final15 files with0 failures/13 checks/0 roots; independent GNU also
returned0. The original stage, manifests and execution records are unchanged.
The extra `tests.list` change selects the four explicitly executed test-data
files; ordinary `smoke.tsv` remains the previous six-row list.

| Maintained path | SHA256 |
| --- | --- |
| dev/l2src_sandbox/lmx_graph_copy_owned.lm2 | 3a09a1cfccadb9d9c0a48f54704ab909f88a28f51e78757d8829b65bc816aba8 |
| dev/l2src_sandbox/lmx_implements.lm2 | 26b6a98072a10fb2428c756d76115987f337e847a511d980e22d79ff48ee8d3e |
| dev/l2src_sandbox/lmx_merge_owned.lm2 | 0bc922acdc0e26ddd4fc56104dfcbe3f4b6bd93aa7d7add49c925d69258d0bc3 |
| dev/l2src_sandbox/lmx_walk_values.lm2 | cae135d3f428a88fc058c2909ac09fd68d20700f51f306788325a050e00f2a28 |
| dev/l2src_sandbox/l2trans.lm1 | 5b054576aa779ef8fbe6cf1b8d2f3cc5d19ba9b2ecb2459344e52596b737aaad |
| tools/l2/build.lm2 | c28065b194550652f2df22cc1a7ef269d008d965aa356b2e90bbf5e5ce2ee599 |
| dev/l2src_sandbox/p0_parser.lm2 | 872a0144db5f0b75548c16e7e948e0d6597f65c3cc54be36ae2dd3f36d832b75 |
| dev/l2src_sandbox/l2_machine_types.lm2 | a10d07061e1d306d4241b719f3de6f5dedd022f50bf81cf823cbb820a1131992 |
| dev/l2src_sandbox/l2_copy_uses.lm2 | bd8ef7aa4cadbe48e14f436000de6589925158cf509f742a27d93be6f7f14f13 |
| tools/l2/inputs/runtime.list | 7c77e13dbde7ec7a898bd5f39cb0e94a4b07f1909f470de9889dce2073f8a480 |
| tools/l2/inputs/p0.list | f2094af6b5074977d20ae4d1c6b1482679bd196609e247a2378d0e86674000dc |
| tests/l2/smoke-kernel225.tsv | 32ead2c43e749ea531b0b6d4d610891c17ec9704134fa1c72c63864f51aa3ec6 |
| tests/l2/rr2/unit_rr2_qualified_merge_immutable.lm2 | 0bde2d0cc584266c0236b36149b2031c1995fbc561e513e93f1b89b82f15b535 |
| tests/l2/rr2/unit_rr2_qualified_merge_root.lm2 | dc61380145e112d5585cd50e5c2fb068312dd965b452f9e94e9b01c0a4bbc82c |
| tests/l2/rr2/unit_rr2_qualified_merge_callable.lm2 | 1be5e9c120b5443cedd402dcdc826448f9c140c04beb65af27d73baf8e957169 |

The old maintained `dev/l2src_sandbox/l1src/parser.lm1` is removed, not
replaced by a maintained copy of its generated forward. Its previous bytes
remain in Git224. The P0 input list now selects only `libc_abi.lm1`;
`bld_p0_l2` writes the stage's parser bindings before the frontend backend
reads them. Runtime input selection grows46 to49 with the three new L2
modules. The compiler itself is still maintained L1 and is not represented
as a completed L3 frontend port.

`source225-from224.patch` is the exact staged source delta from published224,
with zero context lines. GNU patch replay from a Git archive of the ten
existing base paths returned0 with `--fuzz=0`; all15 final source/test hashes
then matched. This source replay is not another build or runtime test.

## P0 algorithms and ordinary generation

`p0_parser.lm2` contains the remaining204 ordinary P0 algorithm bodies,
5007 checkout lines and21 exports; the executed stage has one additional
final blank line. The previous ownership, text and scanner modules
remain separate L2 sources. Foreign C fields receive explicit machine casts;
the retained pointer operations, guards, ownership and source order are not
replaced by numeric-address arithmetic or another parser.

The ordinary L2 machine-type helper supplies the pointer subtraction's
`ptrdiff_t` result. The existing C compiler checks the pointer operands;
an explicit outer `size_t` cast remains a distinct operation. The common
compiler CHECK/FILL route and generated callback declarations support this
existing machine operation without a new L2 grammar or C-layout mechanism.

Recipe kind42 emits the compiler callback ABI; kind43 emits only the parser
forward. The26-output deletion ledger removes old generated P0 outputs
before regeneration. Module generation runs own, text, scan, machine types,
parser and copy-use algorithms, then generates headers and frontend C.
Failure returns failure rather than restoring a previous parser or header.

The cold parser forward contains only these five stage-relative predefs:

```text
l2src/p0_own.lm1
l2src/p0_text.lm1
l2src/p0_scan.lm1
l1src/libc_abi.lm1
l2src/p0_parser.lm1
```

Its actual frontend C imports the complete generated204-body tail verbatim,
with each name defined once. The L3 writer produced the P0 and callback
declarations at02:41:00 UTC, before module/forward completion02:41:44 and
frontend C02:41:46. This proves execution and consumption in the ordinary
recipe. After whole-bootstrap termination, GCC dependency readback selects
nine frontend headers, all from this cold stage's generated header directory.
They include the parser API, machine-type helper and callback ABI as well as
P0 ownership/text/scanner and application/copy-use declarations.

## Qualified construction and receiving transport

The inherited225 changes preserve qualified graph copying and construction,
common implements/merge behavior, source-name coordinates and copy-use
planning. The receiving adapter transports two actual descriptors: the
explicitly selected declaring code and the actual expression read from its
header. Native and real walker use the same closed Model decoder. It does
not infer a provider or declaring home from a name, body or ambient graph.

The earlier bounded native and genuine-walker witness returned44 through
the2-to0 physical map with `q.x=4` before and after. The native adapter is
not evidence that its own body was walked. These results do not establish
general scalar/pointer receiving declarations, named/default/result/exit
contracts or admission of every runtime-built callable.

## Cold inputs and completed phases

The warm tool uses an explicit177-file bootstrap capsule. Its build-self
completed0 and produced executable
`a49b9ebe177dca6bdb519a2e70859dd26e34acdc8eeed86db176daa1e8eeeecff`.
A fresh startup/hash returned0 and the exact recipe digest above.

The separate cold stage is
`build2/codex_fix225p0normalcold01`. Its76 maintained inputs comprise49
runtime/frontend,1 maintained `libc_abi.lm1`,1 driver,8 tool parts and17 test-data files.
The input manifest is
`681a42412347a223b65f96c195af996499a7d33f163f7a7b626067847e281bd7`.
All known generated P0/module/ABI targets and the header directory were
absent before launch. G1 subsequently verified the76 unchanged inputs
with0 failures; independent GNU verification returned0.

ONE `bootstrap quick` ran2026-10-26T02:40:34.9690768Z to
2026-10-26T03:13:54.4083832Z, session73839, outer exit0:1999.439 observed
seconds. Its explicit compatible previous frontend is5FA1515E. It uses the
existing language-owned runner and the explicit `smoke-kernel225.tsv`
argument. Final output gives SUITE9 rows,0 failures and BOOTSTRAP quick0
failures, with13 driver checks/0 roots.

| Completed output | SHA256 |
| --- | --- |
| P0 parser module L1 | 411e5b3b1912e3272d9e9ed2d3691f451429d3bcee340ca3eb9b4ddeb12fe562 |
| Frontend C | 66c0dc22466ddbb84c915d4379cf7ef2d57dccd12304cef1a8e95ba1c261993d |
| Frontend executable | bd2cf60b5ae8f9171df07398d8dc1e4de0b6986f029cb851e3e98ad03e2194b1 |
| Runtime C | 7bb692c53c30c6b347f2e9d003df65ccdc84c8ace7607b2b851fe108d229f888 |
| Production runtime object | 4641205ea2a745233624dadbbd60efb133970f88415d7b73f1b8749af2e88037 |
| Observed runtime object | 7b88392210767c1dd2d141e920bd56b56bcfd655acac62925fcfd660bfea58d5 |

Both strict runtime compilations returned0. The recipe generated59 C
headers before consumers; this count is not a claim that all59 were read.
Serial GCC dependency readback after termination selects39 runtime headers,
all from the same cold generated-header directory. The runtime objects match
the earlier actually executed API02 objects.

The first frontend dependency-only command used a nonexistent `l2trans.c`
filename and returned1 before parsing. The actual completed frontend record
names `frontend.c`; corrected dependency command02 and runtime command01
each returned0. The refused command is retained separately. No C recompilation
or runtime rerun was needed for these dependency reads.

## Smoke values and current generations

The smoke failure file is empty. The three qualified fixtures complete all
36 recorded commands across native/forced modes: frontend, backend, C
compile, link and roots0/1. The expected unknown-name case refuses during
translation. No additional test campaign or runner was added.

All four actual S8.1 native/forced root0/1 logs contain:

```text
calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
counts A1=42 A2=42 B1=43
after A1 count100 A1=101 A2=43
runtime r=142 p.y=42 p.x=1 p.pad=9 q.w=10
refusals C=30 Thin=33 Far=34 y=2
seven unused=3 called-plus1=8
```

Root0 logs end13 checks/0 roots; root1 logs17 checks/0 roots. These are
actual values, not a conclusion from linking or an exit status.

G1 completed frontend/backend/strict C/link with0 exits, then started and
hashed its L1 with0 exit and13 checks/0 roots. Its executable and the
working tool both hash
`21debb59875dc4cff445e282c33d3d1f2319c72a06af39fed99c80b7582a6056`.
Its object is
`2af37297594ff9b0255ee03a0700a95ee7346162ed24a6247c5a20996cac104f`.

That actual G1 process launched G2 build-self. G2 frontend/backend returned0
and produced the same L1/C hashes as G1:

```text
573d5cde23db58ba199d6fc5b6ae1aeb361fd11ad980f9c0e8026b844bd32cdd
46a2667be9f8fd74c9784427d00fcfc82898c417ef6bd6d0557eacff7bd946c3
```

These expected G2 L1/C hashes were pinned while both targets were absent;
the G1 object hash was pinned before the G2 object existed. All three G2
outputs match those original pins: G2 language verification returned0 with
VERIFIED3 files,0 failed, and independent GNU verification returned0.

G2 strict C/link, startup/hash and final replacement completed0. Its object
equals the G1 object above. G2 executable and final working binary both hash
`a5a1da796dcb23da0fcb15842db65c7608a07d1de67585c00c2134bca0c59250`.
The whole cold source, tool and generated inputs are now frozen; no second
bootstrap or unchanged smoke run is part of this slice.

The existing language `exe-same` command returned EXE-SAME1/exit0 with13
checks/0 roots. This is equality apart from PE link metadata, not a claim
that the two differently stamped executable files have the same raw hash.

## Remaining closure

The packet's command/record/value files are LF text copies. Their hashes are
not substituted for raw stage-file hashes recorded inside those commands;
the original files and component manifests remain under their named build2
paths. The existing documentation generators both completed0. Initial
`git diff --cached --check` reported the P0 EOF blank line above; the initial
documentation checker separately completed0 with10660 tracked files.

The final53-file artifact binding is `artifacts53.sha256`, SHA256
`7e923d17d36b6c537b4c21ed49641c54b8f7cbecaf9c409a404dd65a5e0a3051`.
Actual G2 generated it with MANIFEST53 files/0 failed, then independently
verified it with VERIFIED53 files/0 failed; both commands returned0 with
13 checks/0 roots. GNU verification also returned0. It binds the fixed LF
packet copies and named raw stage records, not a source-closure manifest.
Its own verification logs and this mutable summary are deliberately outside
that binding.

This is a mixed bootstrap and bounded construction/P0 source migration,
not source-closed S8.6. Compiler/backend, remaining ABI/driver/libc support,
tool/test/doc closure and the common clean-kernel contracts remain open.
The old physical call signature comparison loses actual/named/default,
Consumer-result and declared-exit demand; the closed Model adapter does not
repair it. The next coherent change must retain real receiving declarations
and concrete Consumer calls while preserving the exact physical ABI.

Ordinary valid body composition, general immutable effects and uniform
native behavior also remain open. Native pointer-offset3 execution and a
native callee reached from walkroot are not proof of walking those helper
bodies. Section8a and T01–T26 remain after accepted section8.

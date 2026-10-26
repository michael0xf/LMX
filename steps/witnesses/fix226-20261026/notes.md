# Fix226 receiving declarations and callable ABI

Date: 2026-10-26. Based on published225
`1817ad625b231055c239d98b64bbfb1c378e9596`. ONE ordinary cold SHORT completed
the frontend, runtime, nine smoke rows, G1 and G2 with outer exit0. G1
really built G2; both started, hashed their L1 and replaced the working
binary. This remains a mixed bootstrap, not source-closed S8.6.

The change retains each declared callable input and result as an ordinary
pair of the active receiving SOURCE and its exact physical ABI witness.
It does not yet implement full Consumer signature admission. Actual and
named arguments, defaults, the receiving result and declared exits still
need their concrete Consumer demands carried into the common analysis.

## Source and ABI transport

`l2_receiving_source.lm2` is an ordinary L2 producer. It preserves active
declaration syntax and replaces the one resolved semantic leaf by its
existing graph occurrence, using identity of the original P0 text leaf
rather than spelling.
The compiler supplies the original formal or result declaration and its
declaring scope. Scope restoration follows the existing common cursor.

Header entries alone contain the SOURCE and ABI pair. Ordinary physical
operands for arguments, addresses, dereference, stores and places keep
their old representation. Primitive, hidden and projected ABI-only entries
explicitly have no SOURCE; that absence is not permission to admit them.
The common decoder `lmx_callable_entry` unwraps only a selected header
entry, not every two-slot Structure in the graph.

Native entry and walked Model-input projection use
`lmx_walk_receiving_header_model` with explicit selected code, data and
input coordinate. It extracts an underlying closed Model from the retained
SOURCE. It is not a general evaluator or a complete qualifier, scalar,
pointer, function or result-contract checker. Existing limited physical
call comparison remains a separate open dependency.

The selected callable's own address map now chooses its args slot in the
implements comparison, walked CALL and generated `l2_mad_inputs` helper.
The helper receives the existing explicit arena rather than recovering
hidden state. SOURCE extraction rejects a named wrapper whose child is
another raw NONE or SOURCE_INERT node; such a node is not a resolved Model.

## Ordinary L3 generation

Recipe kind44 prints only the compiler callback declarations needed by
the L2 producer. Its deletion ledger has31 generated P0/compiler outputs,
including the new producer's L1, API and C header and the callback L1/C
headers. Old generated targets are removed before regeneration. The new
module is translated before its frontend consumer, and failure does not
restore a maintained L1 copy. No new L2 syntax, parser or C-layout facility
is introduced. Generated L1 and C remain intermediate outputs.

The five frozen input hashes in component03 are:

| Stage path | SHA256 |
| --- | --- |
| src/l2src/l2trans.lm1 | 23280dca2690fcba855792d69c96e6cd85868b8dfa3d09e89a75b4690b78d0ff |
| src/l2src/l2_receiving_source.lm2 | aa015c1a6a6d78efdeba30588822cc4aa6752948443fb25cbd0ccaad7075a94d |
| src/l2src/lmx_implements.lm2 | 189da9f0ef4a014ffeb93969ef17318b5610da58afa60d6d0140f37b420cb237 |
| src/l2src/lmx_walk_values.lm2 | ea7b147e65f07b5ff923cb4034b02fb0391fea2c8bf14534309db792098897cc |
| tools/build.lm2 | ecc7425c551554787a0096d70e60205855b1c329e1b72a36212ab619b4e84821 |

The five promoted source files match these executed stage bytes exactly;
the sixth maintained change appends the new module to runtime.list.
`canonical-source6.sha256` binds that promotion separately from the stage.
The unchanged P0 retains the known225 EOF-only difference between its
executed stage and checkout, as recorded in packet225; no claim of raw
equality for all77 canonical inputs follows.
The cold77 manifest is
`fd560fbf7659b176b488a151e97bf331fcb05247589ba0e6a5e7a705003b241b`.
The unchanged nine-row fixture list is
`32ead2c43e749ea531b0b6d4d610891c17ec9704134fa1c72c63864f51aa3ec6`.
Actual G1 independently verified all77 inputs against that prelaunch
manifest with0 failed files,13 checks/0 roots and terminal exit0. This
read-only verification did not compile or rerun the fixture suite.

## Failed attempts and correction

Component01 stopped during frontend module translation because `node` is
a reserved word. Component02 stopped in the same phase because a P0
foreign-field expression needed its ordinary explicit pointer cast. Neither
attempt reached frontend C compilation, runtime, smoke, G1 or G2. Their
sources and logs are preserved unchanged. The correction renames the local
binding and uses existing C99 casts for the declared P0 pointer types; it
does not change the grammar or grant a type-check exception.

An incremental translation of the corrected producer returned0 and made
L1 `7974fec452b2fe1d923ef0a3e7f9290570c53a29a0c8d2cf869cd240ac291f81`
and API `4653867acb38ace402c449ee27f71e6e887ec0a9579c898d986901ae20a3e7f0`.
There was no separate successful frontend/runtime C build before the third
ordinary SHORT attempt. Its module generation reproduces those same bytes.

## Completed phases of the cold SHORT

The existing seed2 tool, executable
`2a5d5b95e0cc669fd0be35f59b07643837f0a2eaf07c44de2e0c6385206169f0`,
started the whole SHORT in component03 at04:53:59 UTC. It copied no
generated header targets from the failed attempts. The L3 callback writer
ran before the new producer and frontend.

The ordinary frontend source above produced C
`a7cf971c6018185d0e503a64d11fb1707590f47416921b31f1e442529b418be0`
and executable
`6bb9cdd104f9c2fa8c3d72b9511ea5821f2f58c689f54d449e4aa909b980deeb`.
Backend, strict C compilation and link returned0. The new frontend then
translated the runtime. Its generated C is
`9cdca4ea67a8d6386c3532944f32a1f4057297c1d1f13d2b661f7c3fd0eb472e`,
production object
`147d591c5813e6e48f49862d5625b0a9827ae496989a0d049f12e0cee370f577`
and observer object
`ae032b6436daff854bf345cbfb940f09f64a97802b1e914d4b0fbfe536db3b3b`.
Both runtime C variants completed0. Header regeneration counts16 and61
count created outputs, not headers proven to have been read by C.

The existing nine smoke rows completed with0 failures. Native and
`--walk-methods` are distinct compiler variants; each binary runs roots0/1
without recompilation. The unknown-name row refuses during translation,
before any C compilation of that refused program.

All four S8.1 native/forced root0/1 logs retain these actual values:

```text
calls A1=41 A2=41 B1=42 A1=42 B1=43 A2=42
counts A1=42 A2=42 B1=43
after A1 count100 A1=101 A2=43
runtime r=142 p.y=42 p.x=1 p.pad=9 q.w=10
refusals C=30 Thin=33 Far=34 y=2
seven unused=3 called-plus1=8
```

Root0 logs finish13 checks/0 roots and root1 logs17 checks/0 roots. These
existing concrete cases do not establish full callable signature admission.
The unchanged qualified callable witness also returns7 after asserting its
actual mapped call result44. Its native C calls the new common header
Model extractor;44 is an assertion value, not a claimed printed trace.
That holder's existing lifetime is covered, not the general lifetime of
every retained or copied callable after its original owner closes.

G1 completed frontend, backend, strict C and link with0 exits, then started
and hashed its L1. G1 executable is
`d9675405278e365a8accbd688a8dc2a5e1733b1136f9c4f1832e9424f4eefc29`.
Its actual process launched G2 `build-self`, with the same frontend and
production runtime. Expected G2 L1 and C hashes were recorded from completed
G1 while both targets were absent. The expected object hash was also taken
from completed G1, before G2's first strict C compilation. The working
binary's raw hash and an independent byte comparison confirm the first
replacement by G1.

G2 completed strict C/link, started, hashed its L1 and replaced the working
binary. G2 and that final working binary both hash
`43744b43f039244cd0f27e8039439f7d38b3871f6f3983113da73d975c6ff82d`;
independent raw comparison returns0. Its original three expected L1/C/object
hashes match: actual G2 language verification returned0 with3 files/0 failed,
and GNU verification returned0. The existing language `exe-same` command
returned EXE-SAME1/exit0, equality apart from PE link metadata rather than
equal raw executable hashes.

Whole SHORT launch was04:53:59 UTC and terminal0 was observed at05:27:58 UTC.
After its termination, serial GCC dependency-only readback returned0 for
both frontend and runtime. It selects11 frontend and39 runtime C headers,
all from this cold stage's generated header directory. The frontend reads
both the new producer API and its L3-generated callback ABI; runtime reads
the generated arena and callable/walker headers. No extra compilation,
link or fixture execution is part of that dependency readback.

## Publication binding

The exact staged six-path `source226-from225.patch` replays from the five
existing published225 paths with GNU `--fuzz=0`; all six final hashes match.
The initial archive extraction mistook the Windows drive prefix for a
remote host, so its following empty-target replay failed. That target is
preserved; corrected fresh base02 uses `tar --force-local` and both replay
and hash verification return0. Neither replay performs a build or run.

The packet copies are LF text; raw stage hashes remain separately bound
by the named records and manifest. Notes and the artifact verifier's own
logs are outside the artifact binding. The existing semantics and grammar
documentation generators both returned0 without changing the specification.
G2 generated and verified the initial62-file binding with0 failed files and
terminal exit0; independent GNU verification also returned0. Its SHA256 is
`e51de9e0a8ba16799a277573b0314c983b013f9a02fa8369c5400a3d4eca4d75`.
Publication checks then rejected CRLF in the two artifact-tool console logs
and one extra final blank line in each working-hash log. Only packet text
formatting is corrected; the raw stage records, compiler/runtime/program
bytes and original manifest are unchanged. The final62-file binding is
generated separately after that correction, not relabelled as the first one.
Final `artifacts62-02.sha256` is
`9837aa73ee44a1880636d40e8746052cadb3f7ea8f868b20e9cae76704aa6214`.
G2 generated and verified it with62 files/0 failed and terminal exit0;
independent GNU also returned0. Corrected documentation checking and staged
whitespace checking return0. No source or runtime rerun accompanies this
packet-only formatting correction.

## Remaining work

A bootstrap using handwritten compiler/backend/driver/libc support is still
mixed, not the L3 plus L2 source-closed selfbuild required by S8.6. The
frozen component03 inputs and completed outputs are not rewritten or rebuilt.

Full Consumer admission must preserve concrete calls and their actual,
named and default arguments, receiving result and required exits through
the common analytical machinery. SOURCE preservation and raw ABI decoding
are prerequisites, not that admission itself. General immutable effects,
uniform native behavior, runtime-callable/Q49, source closure and mail
T01–T26 remain open.

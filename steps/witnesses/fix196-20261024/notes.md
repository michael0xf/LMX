# Verified196: resolve L1 predef dependencies beside their includer

Base: Verified195 `0b86acdb`, record `a3256b4de85f7c2172a5b9ec49ff1e75356eaa02`.
Codex is the sole writer/build. Only 195's `src`, `headers`, `tests`, `tools` were copied into the new
`build2/codex_fix196`, excluding the protected driver-output basename. Frozen stages and unrelated files were not edited.

## Code and scope

The sole code delta is the existing `src/l2src/l2trans.lm1`:
`7A1442F9BB7EFCAF1B9A7C31675FC620197DA5B28ECDCCD5C45E8D5381490A77` to
`DE127434244AC3BC8839E849E5C144665DA7924BFCCA069D511BD3901981F9FF`.
GNU patch reconstructs that exact source with zero fuzz (`replay.command`, checked by the parity manifest).

`l2_predef_import` implements the existing L1 rule (`l1_import_path_text` / `l1_resolve_bare_import`):
only a bare filename is prefixed by its includer's directory; slash/backslash or drive paths keep their spelling.
It does not search the filesystem for a fallback. The collector applies it to each unit/part's imports; all four
predef readers apply it to every nested dependency, including the type reader's mapped generated-header include.
Emitted predefs thus name the dependency actually queried.

L1 already permits several paths in one predef Frame (`l1_hdr_register_path`); the four readers now traverse all its
existing fields in order until a match. The L2 collector's arity and the P0 parser are unchanged. The path spelling
uses the existing `l2_cnt_keep` owner; no source/header AST is changed. Successful read-only documents still belong
to the program snapshot (195); semantic answers are not cached. This is a compiler dependency lookup, not runtime
variable lookup, provider search, an admission passport or a library-specific comparator.

## Actual runs

| Run | Observed result |
| --- | --- |
| `control-gc-195` | Existing GC source with only its direct arena-block-header predef removed: 195 refuses at 214:34, `unresolved dynamic=disposer`, exit 1 |
| `bootstrap quick` | `BOOTSTRAP quick 0 failures`, exit 0, 1117 s; smoke 6/0; G1 actually builds G2 and both start and hash a file |
| `gc-indirect-196` | The *same* indirect GC source passes L2→L1→C and GCC syntax checking, exit 0 in 1 s; no direct substitute header was added |
| `checks/commands.txt` | Existing language-owned `verify`: 12 expected files, 0 failed; separate `EXE-SAME 1` |
| `checks/normalized.command` | Tool L1/C equal 195 after the existing unit-path-prefix normalisation; bounded `src` diff contains only the compiler source; `headers` diff is empty |
| `manifest/manifest-196.command` | `MANIFEST 67 files, 0 failed`, then `VERIFIED 67 files, 0 failed` |

The old/new GC commands use the same source and stage dependencies. The L1 frontends and backend run from
`stage/src`, as in the recipe; they do not use the L2 driver. All language-owned tool commands run from new empty
runs directories, never the repository root. The positive probe syntax-checks its generated C; it does **not** claim
execution of that GC body. An existing unused-variable warning is not treated as an error or hidden.

The unchanged byte equalities use static `checks/expected-parity.sha256`: the frozen 195 runtime/active-GC/S8.1
files, G1's L1/C for G2, and the stage source for its replay and the frontend's saved source.
This batches the same checks through existing `verify`, with no new runner or repeated compilation.
G1/G2 L1: `416772673DBA6C8F0AD7046D8472087C1C972082E8354798D1BF68B7AF6283E6`;
their C: `F5D252AF3E78F2C4959DB8CA7BD52772C1EA7788B55B7DF1DD54BB8E3CCBFA5E`.
Raw executables differ; only the existing `exe-same` comparison is claimed. The new frontend is `33C2EA33…`.

Runtime C and both objects equal 195 (`26F4E99A…`, `B0690EE7…`, `9CFB64B3…`), as do all regenerated modules and
headers. Actual smoke retains the four S8.1 native/forced root0/1 logs: `A1=41 A2=41 B1=42 A1=42 B1=43 A2=42`,
post-write `A1=101 A2=43`, runtime-candidate `r=142 p.y=42 p.x=1 p.pad=9 q.w=10`, refusals 30/33/34, 17 checks.
These preserve the bounded prior cases, not arbitrary runtime-callable admission.

One serial build pipeline ran; nothing was killed. Interactive samples stayed above 1.5 GiB free commit; this is
not a continuous minimum measurement. No new watchdog, test system or multi-path matrix was added.

## Evidence and limits

The manifest pins the original stage files; published text copies remove CR/trailing whitespace only.
All 67 entries were independently checked with `sha256sum -c`, all OK.
Commands, results, the source/witness deltas and actual frontend/runtime/G2 records are in this packet.

PREDEF-BARE-NESTED-PATH-FROM-CWD is fixed in the measured scope. No extra kernel module was ported: 14 of 35 are L2;
21 modules, the driver, parser and translators still have hand-written L1 inputs.
Not run: `bootstrap full`, wide kernel/gate/corpus/mutants. Arbitrary import cycles are not exercised here.
S8.3–S8.6, the remaining clean-kernel obligations and S8a/T01–T26 remain OPEN.

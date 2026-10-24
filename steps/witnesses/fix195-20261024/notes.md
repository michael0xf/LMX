# Verified195: retain each predef file's parsed tree for one translation

Base: handover `5e7ce1588b056a7436c9ada09f46c34f48a16f5a`, after Verified194 `03c5a3ee` and its record `bc3edf80`.
Codex is the sole writer/build. The fresh stage `build2/codex_fix195` copies only 194's `src`, `headers`, `tests`,
`tools`, excluding the protected driver-output basename. Neither frozen stage nor unrelated files were edited.

## Code

The only code delta is the existing translator's `src/l2src/l2trans.lm1`, appendix A of the handover:
`D8F10E375087296766A7BC1562A94D48D7E4DD1969FF94D5C10667A687844733` to
`7A1442F9BB7EFCAF1B9A7C31675FC620197DA5B28ECDCCD5C45E8D5381490A77`.
The published zero-context delta reconstructs that exact source with GNU patch, zero fuzz, and language-owned
`same` (`u0-same.out`).

The program snapshot owns the read-only P0 document of each successfully parsed predef file, beside its bytes.
Its four readers borrow `l2_snap_document(path)`; these are parsed trees, not cached semantic answers.
Source and part trees retain their separate mutable parses. A failed parse's partial document is destroyed and
not stored. Snapshot cleanup destroys the retained documents once. The result-type reader still builds fresh
contracts; their borrowed header words now remain alive until snapshot cleanup. No syntax, grammar, admission rule
or emitter changes.

## Actual runs

The G2 bootstrap tool of 194 (`4BE31126…`) ran `bootstrap-quick-01.command` from the new empty
`runs/run-boot-01`, never the repository root. The compiler it built is `36759299…`; its saved source is the stage's
`7A1442F9…`. No other compiler pipeline ran beside this one.

| Run | Observed result |
| --- | --- |
| `bootstrap quick` | `BOOTSTRAP quick 0 failures`, exit 0, 1124 s (194: 2298 s); smoke 6/0; G1 actually builds G2 and both start and hash a file |
| `gen-195-01` | The existing GC module, same recipe command as `gen-194-06`, new frontend: exit 0 in 2 s (194: 300 s); the same generated L1 |
| `checks/commands.txt` | Ten `SAME 1` and one `EXE-SAME 1`: G1/G2 L1/C, executable comparison, runtime C and both objects against 194, timed GC output, four saved library-owner outputs |
| `checks/normalized.command` | Tool L1/C equal 194 after the existing unit-path-prefix normalisation; bounded `src` diff contains only the compiler source; `headers` diff is empty |
| `manifest/manifest-195.command` | `MANIFEST 62 files, 0 failed`, then `VERIFIED 62 files, 0 failed` |

The same 62 entries were independently checked with `sha256sum -c`, all OK (`manifest/sha256sum.out`).

G1/G2 L1: `1420BD3E491303326DB3C71138F50AD5213BCE30F89AC3B98C2BC0761DFCF599`.
Their C: `4C5C3D8E55D18A51BE5D47E42143C02AC4C6BDE5FAA0465CC5768D56E97D120B`.
Their raw executables differ; only the existing `exe-same` comparison is claimed, not raw byte equality.
The runtime C is `26F4E99A…`, its two objects `B0690EE7…` and `9CFB64B3…`, the actual 194 bytes.

All four saved native/forced root0/1 library-owner logs equal 194. The read forced-root1 output includes
`A1=41 A2=41 B1=42 A1=42 B1=43 A2=42`, independent post-write `A1=101 A2=43`, runtime-candidate
`r=142 p.y=42 p.x=1 p.pad=9 q.w=10`, and the same refusals 30/33/34. These preserve the previously measured bounded
S8.1 cases, not arbitrary runtime-callable admission. The timings are individual observed runs, not a benchmark campaign.

Interactive memory samples stayed above 2 GiB free commit; this is not a continuous minimum measurement.
Nothing was killed. No new watchdog, runner, test system or wide test campaign was introduced.

## Evidence and remaining work

The manifest pins the original stage files; published text copies remove CR/trailing whitespace only.
Commands, results and the actual frontend/runtime/G2 records are in this packet; `evidence-195.list` and
`evidence-195.sha256` bind the selected inputs, tools, artifacts and logs.

PREDEF-HEADER-REPARSED-PER-QUERY is fixed in the measured scope. PREDEF-BARE-NESTED-PATH-FROM-CWD is still OPEN.
No additional kernel module was ported: 14 of 35 are L2; 21 modules, the driver, parser and translators still have
hand-written L1 inputs. Not run: `bootstrap full`, kernel/gate/corpus/mutants.
S8.3–S8.6, the remaining clean-kernel obligations and S8a/T01–T26 are not closed by this slice.

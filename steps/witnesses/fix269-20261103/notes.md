# Slice 269: shared unary bitwise complement

Current verified state: 2026-11-03, source182 installed in selfbuild after
boot131b and the complete 30-row G2 focus. All checks described below are
actual; ordinary-var WIP267 remains separate. Its former U3 question is
resolved by the author and documentation commit a17c0781, not an open gate.

The following candidate chronology is retained as history; final acceptance
is recorded at the end.

Base main 81f35977e1e47203b7d49361c260be3255e3ed75 (published268).
The BITWISE ledger still lacks unary ~. This candidate extends the existing
prefix classifier and executable unary operation; no new grammar or resolver.
The shared kernel promotes the operand and complements its unsigned stored
word, then uses the existing numeric store for the result width. Retained
BNOT calls the same unary helper as native. Machine/unevaluated output keeps
the normal C spelling. The native unary adapter delivers a present reference
mismatch as the existing named convert instead of a generic walk failure.

Changed source: frontend_helpers, frontend_core, frontend_lower, walk_values,
and tools/build (BNOT64, OP_COUNT65). A new tool is required before generating
headers/runtime/frontend. Expected checks: int/unsigned/size_t and char
promotion, prefix/group/nested expressions, free values and pointer convert,
native and forced walker, both roots. Existing signs and shifts retained.
U3 ordinary-var WIP267 remains separate; no author answer is inferred.

No candidate build or test result yet. Source and receipts: variants/tp131,
cold-tp131, pins/tp131-* under build2/codex_fix250generationchain01.

## First candidate

Seven selected inputs changed; 182 total input paths. Prepare01 (6 steps)
and reuse (5 steps) succeeded through the language-owned tool.
Source manifest: 5bb2684f4ba4963334d2cb3ac712cfef6e9e10ee68143f94e95af8526a7a8988.

Tool131 rebuilt and passed its hash/start/smoke checks, 0 failures
(05:49:55.5535499Z--05:51:37.6382882Z).
Executable: 16e0cdb8849a2d2b36ac89db560b88a9ec195ca51edb9b9f1ca2c410fcd099c4.

Runtime rt131 completed, 05:51:47.1157517Z--05:52:36.6738644Z, exit0.
driver.o: 738e187f401a22571ac9cec0b794f716793e57ae2fb22530ce9c902fb6c8a672.
driver-observe.o: df8cd15198bd47338a5ce3baff9894c6b4da360f9fb46f438082a727046711a4.
Its generated header contains BNOT64 and OP_COUNT65.
Frontend fe131a is the next single pipeline; no suite PASS claimed yet.

First focus: 3 rows, 2 translation failures, both modes of unary_complement at line27/result. Existing free_machine_ops and typed_shift_guards pass all four runs. Prefix result typing preserved the old -12 opaque class but lost current FREE45 after a unary expression. Fix02 preserves the actual runtime-typed transport class in prefix_value_type; the typed target keeps runtime receive. No test assertion removed. Values module is the eighth changed input.

Before testing fix02, source review caught a correction: value_type_kind returns -20 for FREE45, not -99. The variant now retains exact FREE for result kind -20 and leaves the legacy -99/-12 rule intact. The already-started fe131b uses the earlier frozen candidate and cannot prove this correction. No runtime source changed.

Fix03 frontend fe131c built successfully. Focus03 still has 3 rows/2
translation refusals, now line75 got: ~once(@count); the FREE receive case
at line27 is past. The actual P0 compact-Frame branch retained ~once as
one head. Fix04 uses the existing compact-token scanner before a compact
Frame: earlier tokens stay fields, the final token owns its arguments.
Quoted heads remain atomic. This is the normal token boundary of grammar
§21, not an emitter rewrite or a second evaluation of once. Parser is the
ninth changed input. Existing final regression set remains required.

Focus04 passed compact ~once parsing and found grouped dereference rejection
at the explicit count read. Fix06 prepares that Frame through the existing
operand record and common indirect resolver; frontend passed. Focus06
then exposed two native emitter sites still classifying dereference by the
raw atom spelling. Fix07 consumes indirect_span's common verdict instead;
2 means not a dereference, 1 a refused operand, 0 a resolved place. No new
semantic algorithm or repeated operand execution. The same candidate
preserves FREE through grouped prefix receiving and tests its convert catch.
None of these intermediate suites is a PASS for unary_complement.

Focus07 is the first actual 3/0: fe131f b08d5b6272da00cd201b6ca29b7b0e2ee06fff419f2ceacbb4e1ae1d4cf1e134,
rt131 unchanged, fixture616e9a1d; all native/forced root0/1 return7.
06:21:39.7290040Z--06:22:11.6564779Z. This does not close the architecture:
generated native p.lm1 still computes some typed ~ directly in conditions.
Fix08 sends typed language unary spans to the existing dynamic unary
operation and receives the numeric C view, even without a requested full
output record. The kernel remains the only operation implementation.
The earlier prediction that grouped FREE would fail was not observed:
focus07 generated its existing dynamic unary call and caught convert.
A record-only Frame branch also now uses that same existing adapter.

Focus08 exposed a compiler recursion, exit -1073741571 for unary_complement:
the dynamic leaf fallback sent a flat prefix back to native_span, whose new
typed unary route called the same dynamic span. Fix09 consumes the prepared
flat prefix operand in dyn_span_full before its ordinary-leaf fallback and
then emits the same shared unary operation. Existing bit/shift rows stayed
green; no resource failure or semantic oracle was changed.

Focus09 refused without a location; diagnostic-only fix10 located the first refusal at line4 (~value). The new unary dispatch had consumed a grammar3 expression wrapper as a flat prefix, yielding an unprepared operand. Fix11 leaves grammar3 expressions to their prepared children and applies prefix_rest only to the prepared unary leaf. Lower-only build10 verified 410 reused inputs and 166 ABI artifacts; all inner steps succeeded. Focus10 still failed the two unary translations; existing bit/shift rows stayed green. No assertion changed.

## Checked candidate, bootstrap in progress

Focus11: 06:41:18.5737597Z--06:41:49.9616122Z, 3 rows, 0 failures.
Frontend fe131j caa6aa558744b8578988051f6a6a6e840ec1e602e1bdd41005b86e555f56de0e;
rt131 and fixture616e9a1d unchanged. All three fixtures give7 in native and forced, roots0/1.
The generated unary_complement native p.lm1 has 16 BNOT calls plus one POS call to lmx_walk_value_unary and no raw ~ operation.
The ordinary language compiler takes prepared grammar3 expression children before recognizing a flat unary leaf.

The existing os-walk-witness (obs01) passed with 0 failures: 13 named bodies,
including once=4, both roots. Native reports no walked bodies, forced reports the exact expected body counts.
This checks real execution, including the compact and spaced prefix call operands and grouped explicit dereference.

Frozen182-input manifest d0cdc2f3592d1175204a6b107e938ccbbd4394b7c8d08496a4ace8e68d0c06ae.
boot131a has been prepared through the existing tool and started; no bootstrap result, landing or publication is claimed yet.

boot131a is RED: 06:42:22.0940479Z--06:46:09.3108746Z, runtime G1 step5, lmx_range.lm2:394 (return pool\pointer_read(cell)), assignment value has unknown type. The compact-call token split had cut a receiver path at its last identifier. Fix12 preserves the complete receiver path and index subexpressions; only preceding expression operators move the compact call boundary. The stopped frozen stage remains intact; no bootstrap retry yet. This was not an OOM or a resource stop.

## Author clarification: ordinary var and method-reference assignment

Before the documentation delta: HEAD 81f35977e1e47203b7d49361c260be3255e3ed75. Baseline hashes: pins/var-docs-baseline-20261103.json. The author requested exact chat history reconciliation on 2026-11-03. Scope: the source semantic book (RU/EN), generated chapters, paired L2 address contract, coding/migration instructions, and U3 question status. No change to frozen boot131b sources. Verification: language-owned semantic render and docs check after the live single bootstrap pipeline. History receipts are exact user-message extracts from this thread, not inferred recollections.

## Candidate12 and boot131b, completed

Parser component12 uses fe131k 0627cd62d4b010f5e9d476a3606fe19e6b67642190253cc107437a9aedcc67b8.
rt02 rebuilt all runtime modules with that frontend (06:49:39.3456234Z--06:50:31.4450085Z),
exit0; production and observe objects are raw-equal to rt131.
Suite12: 3 rows, 0 failures in native/forced roots0/1.
Obs02: OSWALK 0, the same 13 bodies and exact counts (once4), no native fallback.

boot131b: 06:52:55.3079527Z--07:06:20.5968097Z, BootstrapExit0 (805.29s).
Source182 manifest a4e6cc19f8b47342899e94f0119c6de1bcec161e6335773bd1224356cc6647f1.
Both generations ran nine smoke rows with zero failures. Independent current
hashes checked all 248 entries of each generation: 0 stale, 245 raw-equal,
three equal-size PE binaries differ only at actual TimeDateStamp/CheckSum
offsets136/137/216/217. Consumed306 inputs raw-equal. Frozen182 source hashes match.
Full evidence: pins/boot131b-independent-hashes.json. G2 final focus is running;
no source269 landing or publication yet.

## Separate documentation publication

The author's requested clarification was completed independently as a17c0781:
ordinary var declaration/reassignment, @ first for method-reference assignment,
bare atoms do not invoke, local hidden-input addresses. U3 is no longer waiting
on the author; WIP267 code remains unaccepted.
Existing tool130 rendered both books at07:06:24--25Z, exit0.
var-docs-check07:06:56.0853178Z--07:07:18.4692804Z exit0:
35 paired chapters,14 implements,27 grammar sections,44 excerpts,615 imports,
links, exact opening and15588 index LF files. Exact reviewed hashes:
pins/var-docs-reviewed.sha256. No source131 frozen input changed for the docs.

## Final G2 and landing

tp131-suite-g2: 07:07:43.6906557Z--07:10:33.1409856Z, SuiteExit0,
30 rows, 0 failures; native and forced, both roots. Its actual G2 frontend,
runtime and tool are the hashes below. The generated native unary fixture has
17 shared unary calls (16 BNOT plus POS), with no raw ~ expression.
The existing separate obs02 verified 13 bodies, once=4, native no walked bodies,
forced exact counts in both roots.

Land269 completed all eight language-owned steps at07:11:05Z. Both65-source
consumed subsets match, selfbuild manifest equals frozen source, all182
maintained hashes independently re-read with0 mismatches. The G1/G2 producers
are recorded in pins/boot131b-producers.json:33 frontend,39 runtime,6 tool
steps per generation, all actual inner exits0. The working tool is the raw
G2 tool. This is the next coherent quick generation, not a final FULL.

| Artifact | SHA-256 |
| --- | --- |
| Input list | `4ee22d619a417eea79937c34f1cc267a3fcdd6e62722ae01813bc24f9366cab4` |
| Input manifest | `a4e6cc19f8b47342899e94f0119c6de1bcec161e6335773bd1224356cc6647f1` |
| Working tool | `692f9d4d20dafafdde68df6c583e836060f10163589d89b539e691ae8b75a6e9` |
| G2 frontend | `6b586e49f1954532c5b64621721964d6f3976fdc4b0b7faf77df7f6caf0473e0` |
| Production runtime | `738e187f401a22571ac9cec0b794f716793e57ae2fb22530ce9c902fb6c8a672` |
| Observation runtime | `df8cd15198bd47338a5ce3baff9894c6b4da360f9fb46f438082a727046711a4` |

Remaining: the clarified ordinary-var and FREE-root paths, remaining
body/throws/D105 closures, the shared collector and three compiler passes,
final FULL and §§8/8a. None is closed by this focused bitwise result.

Archival records are UTF-8 LF text copies (BOM/line endings normalized).
Original receipts under build2 remain unchanged and are the inputs hashed by
evidence.sha256. No original terminal or failed frozen source was rewritten.

## Final documentation check

docs269 manifest/verify both exited0. docs269-check ran
07:13:42.0487854Z--07:14:02.6009471Z and exited0:35 paired semantic chapters,
14 implements cases,27 grammar sections,44 verbatim excerpts,615 imports,
links, opening and15832 index LF files. The driver reported60 checks.
All new archival text was normalized to LF before this check; the final
check receipts are archived with the same LF-only rule. git diff --check passed.

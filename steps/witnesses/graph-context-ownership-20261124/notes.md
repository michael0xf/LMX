# W3: arena-owned graph context and traversal

Component accepted by the lead on 2026-11-24 on the addressed receipts below.
The containing Git commit identifies the source slice; publication is recorded by the lead.

The component concerns the clean Graph translator and the graph service context.
The ordinary legacy frontend and its program globals remain W5 work.
W4, the flat descriptor, M13, M14, and all of step 27.10 are not accepted here.

## 1. Representation and lifetime

The program remains the passed Lmx graph and its compiled methods.
LmxGraph is the existing weak-name service record, owned once by its explicit arena.
LmxArena.graph_metadata points to it; no program root is stored in that record.
Graph entries read this field from their already passed arena.
The selected code still arrives as its separate existing C9 argument.

The process graph chain, lmx_graph_find, and process traversal top are removed.
Each LmxGraph holds only its currently active traversal stack.
Every space helper receives g explicitly; nested traversals push and pop on that same owner.
Independent arenas do not borrow another arena's namespace or GC roots.
The canonical spelling interner retains its separate existing process lifetime.

The clean generated builder uses a local program pointer.
Its program arena/unit/root globals and l2_program_graph accessor are removed.
The observer receives the actual builder graph through its existing observation boundary.
Its redundant accessor equality assertion is removed; graph shape, parent, and W2 launch checks remain.
The observer consequently reports 42 checks rather than 43.

Arena release and explicit Graph close detach and free the same service record once.
Attach preserves record identity and moves weak-name storage with the transferred records.
A nonempty recipient validates and reserves its merged name table before publication.
A refusal rolls back only newly inserted borrowed range views.
It does not retire live source storage or remove prior weak names in the recipient.
The common range-removal implementation distinguishes view rollback from storage retirement.
Message take, cursor take, and child handoff close emptied donor metadata before forgetting that donor.

## 2. Sources

There are 25 code/control paths: 24 modified and one added.
The 1687-file manifest includes the new graph_context_ownership test.
Of the previous 1686 manifest paths, 1664 remain byte-identical and 22 change.
The other two modified controls are inputs.list and inputs.sha256.

Manifest SHA-256:
`63fb3da222da53bf79fd40a182260a4d63c908f2d6dc11b326c1700ae3b153d9`

Unchanged-input manifest SHA-256:
`899539808abf3dea9ed03321db468e1ff4217ac6931c280f49e54f820216ab38`

Both R/selfbuild and S verified all 1687 inputs with zero failures before G1.

## 3. Seed and target boundary

The original W2 source manifest and 379 consumed generated declaration/implementation files were frozen.
The seed tool was linked wholly against W2 declarations and W2 runtime.
Its shared Arena, Primitive, and Graph headers remained byte-identical to that frozen closure.
It writes new target declarations; no new-layout target object is linked into the old-layout seed.

Runtime03 is built from the final frozen W3 sources and supplies G1's runtime.
The full hosted frontend and tool consumers are rebuilt with the new Arena layout.
C9 and the existing ScalarABI4 remain unchanged.
The range export list grows from 31 to 32 for lmx_range_forget_view.

Target tool02 SHA-256:
`723ce8674a4c2bfa1da0a31af7c04284fcae0471e62d35dc73039c917920bc4c`

Runtime03 driver.o SHA-256:
`f5354ecabf2a9860ca7c9c4f861978fb4dad50f4a4c53b03c15a9be5dc10071b`

Runtime03 driver-observe.o SHA-256:
`417e42b359a1c19b0f39642b2759c1c06854321f5d49c50c35e748bcaa36106e`

## 4. Addressed observations and open baseline

The new unit covers independent and nested spaces, namespace GC roots, weak-name retirement,
empty/nonempty attach, failed attach rollback, donor release, explicit close, revert, and repeated release.
It also covers owner take, cursor take, and child handoff with preserved names.
Runtime03 passed the unit's native/forced executions at roots 0 and 1.

Controls13-02 built all 26 native/forced programs.
Twelve rows passed all 48 executions; graph_call_frames failed four executions at case 122.
The complete result is 13 rows, four failures. It is not a green thirteen-row suite.

The accepted published W2 source, its frozen compatible generated closure, frontend, and runtime were rebuilt
for that one row in a separate baseline stage. The same four executions fail at case 122:
status 0, value 5, expected 9; program exit 122 instead of expected 7.
The W3 edit in this test changes only graph-context and traversal arguments.
Its expected values remain unchanged. The selected-description case remains open.

The first controls run exposed lost member separators in seven test callback edits.
Those source typos were corrected. The strengthened rollback pin then exposed real name retirement
through lmx_range_drop; Runtime03 corrects that path. No expected result was changed.

## 5. Final generation and publication receipts

Both source-built generations completed: Runtime03 supplies G1; G1 builds the G2 runtime, frontend and tool.
G1 frontend: exit 0, 423 s, minimum free commit 2189 MB.
G1 tool: exit 0, 48 s. G2 runtime: exit 0, 109 s.
G2 frontend: exit 0, 504 s, minimum free commit 2032 MB. G2 tool: exit 0, 106 s.
Smoke10 passes with zero failures on each actual generation, including the new ownership unit.

The tool's L1 and C are byte-identical between generations.
Tool, frontend and backend executable images match after normalization of service PE fields.
The libc companion, production runtime and observed runtime are byte-identical.
All eight artifact comparisons passed. Each generation's runtime/frontend/tool record verified
154/135/54 hashes respectively, with zero failures.

The frozen source manifest covers 1687 paths.
The archive pins 64 record-listed generated inputs and 382 broader generated body/declaration/header files.
Two overwritten historical input versions are retained with their original recorded hashes.
The Range input comes from the frozen compatible W2 closure.
The Arena input is recovered by undoing the two rollback call-name changes in its current L1;
the complete SHA-256 matches the original RT02 output/G1 input.
Its recovered L2 source also matches the old candidate02 manifest.
A replay of that source succeeds from the proper src cwd; the private output path changes one scalar alias name.
The recovered historical L1 is archival data and was not patched into the build stage or linked.
Details and failed replay cwd attempts remain in root01/historical-recovery.txt.

Final G2 Graph translator: exit 0, 28 s.
Eight rows passed all 24 interp/native/forced routes:
root_closed_names, send_exit, send_in_fn, path_write_native_level2.lm2,
frame_computed_description, level2_record_node, bind_place_computed_once, and r0_exit_text.
The three exit-letter rows keep expected exit 1.
The final native/forced r0_exit_text logs retain both texts after GRAPH-AFTER-END.

Final G2 controls repeat the same complete thirteen-row result:
26 builds pass, 48 executions pass, four graph_call_frames executions reproduce baseline case 122.
The result contains 74 PASS lines and four failures, not a green full suite.

Generated clean Graph C has a local l2_program_unit.
The deleted program globals/getter, graph registry search and traversal top are absent.
The final driver also contains no lmx_graph_find, lmx_graph_space_top or l2_program_graph.
No full-suite, full documentation check, cross-platform or 32-bit ABI result is claimed.

## 6. Final artifact identities

G1 frontend l2trans.exe:
`6db051003ff6aaf0230a575481ef1cdbbaf4843c8c905b3d6f32f6b45b601ddf`

G1 tool:
`e888ab94bc07cf0c9c90c532656e99f94751814b0f20a8012df6454cba6e5a73`

G2 frontend l2trans.exe:
`b03086109404256c8aaae8af3bbf0214f98117838aaa7a165f649874c13abca6`

G2 backend l1trans.exe:
`6b844c3ca6f2ef8cd52fc50d24d164580e50e55cdba63a1f14cd70e11d9fc6ce`

G2 tool:
`51e74e25710fe37d8c912d4dd837fd00e87e815ecb6d78c5921d2ec779c669cf`

G2 Graph translator:
`121fad49c8d7f789e3f43d4afea0fb90d8ab47321fd50748407569c7c6ab5184`

G2 production/observed runtime hashes equal Runtime03 above.
Receipts live under T/w3-accept-20261124/root01; T is the tz-20261121 acceptance directory.
The seven working-instruction files also record Sonnet's return by the author's 2026-11-24 instruction.
W4 is still private: its normative call/native table does not add an extra registry or cache.

# M11.7 — source-known path construction, slice391

Base main:780411910064984dd50a15ecab92b9dd5ea5bb22, accepted and pushed390.
The previous goal turn is progress. Work and commits remain directly on main.
Root is the sole code/test/build writer; helpers only researched existing contracts.

The new private projector extends the existing fresh construction walk. It reuses
step_index/occurrence for selection and binding_method for the exact written fn slot.
A bare initializer still has its unique-name/formal/DATA/FREE/pending guards.
A selected anonymous WORD is lexical-only from its physical holder, using the existing
nonconstructing atom reader plus a pending-scope audit. No activation lookup is used.
Literal physical indices project a Structure value, without allocating a graph-index
reference or evaluating an index. Mutable references and F.args/code links remain
deferred reads; constructor ownership proves neither immutable bindings nor payloads.
The actual F.data is stored directly as kind4 by fn_make, so the same generic
physical-Structure rule admits it without an exception based on its field name.

Graph01 found an index/path mismatch: A[0] over WORD atom B was incorrectly promoted
to the Structure named B (raw1 instead of2), and raw fn/declaration Frames lost their
physical meaning. Graph02 separates immediate index values from logical path selection.
Indexing a WORD is outside this bounded Structure materializer and retains its initializer;
its reached runtime4 is not a universal generic-@ rule while M13 void references remain open.
The atom pending audit now considers DATA/CODE declarations, not fn-shaped call actuals.
Pure probes show path7→9, exact functions11/12, raw index Frames4/2, lexical atom under
formal/FREE7 with ordinary initializer still raw2, DATA pending2 and application effects0.

Baselines on390: path, occurrence, atom and index refuse5; mutable control gives2.
The typed Model/Value probe refuses3. Typed/qualified construction is not fixed by
erasing its wrapper: it requires the common receiving-chain/name/role consumers,
typed storage and real interface admission. Physical slot equality is not implements.
Those dependencies remain in the main M11.7/M13 plan; runtime merge/fromLmx construction
integration and full M11/M14 are OPEN.

## Code evidence

Only lmx_graph_run.lm2 changes code. Graph75/Run58 exports and C layouts are unchanged;
there is no new parser, opcode, registry, journal, graph copy or persistent proof state.
The accepted390 tool/FE are reused; no unchanged tool rebuild is needed.
Runtime01/Graph01 compiled the initial projector; their index/atom and EXPR pending
findings are corrected in Runtime02/Graph02. These initial attempts are not acceptance.
Runtime02 driver.o SHA256:
5bff703916ec3a2702fb026eb4930be7cf8b2f8a099bc2c8f2b4f8c7d5c85a45.
Graph02 SHA256:
dc69220a199eaf6088da34ef2d8e135cc9499b0bd7a7a753416ee2e9615de4e0.
Frozen Source03:905 files, SHA256:
c34aeea2a565667cc83031d99e847a2635839b2374e101d0d1be4efec3ef537d.

Five maintained sources/four expected files add a combined18 contexts/31 numeric leaf
oracles, a separate two-walk F.data identity case, two runtime refusals3/4 and build4.
The F.data case uses stable := producers for repeated execution; its second-walk values
are constructor data11, fresh bare f8/9, retained data11 and current bare data9. Args/code
references remain raw2. It does not assert completion of the separate M13 producer work.
The combined controls include forward/self/quoted paths, exact functions11/12, index raw
Frames4/2, atom/formal/FREE/EXPR role cases, pending DATA, mutable/index changes and calls0.
Private01 all48 interp/native/forced rows PASS, including the accepted43 unchanged.
Negative full AFTER39 comparisons PASS on ready binaries. No old expected was edited.
Source03 bootstrap01 was deliberately stopped after a confirmed final-review defect:
an actual F.data was absent from the materialization queue and therefore missed by the
atom pending audit. The method and bodyless descriptor probes both gave raw4 instead
of2 without executing either body. Runtime03 adds only a readonly actual-F.data role
proof for this audit, without putting its contents into the materialization queue.
Source03/private48 and bootstrap01 are not final acceptance. Runtime03/Graph03 passed
the method and bodyless descriptor probes: raw2/2 and DATA widths2/2. The new maintained
construction_paths_owned_data pair covers both cases without calling either body.
Final Runtime03 driver.o SHA256:
6a6105346ea9e3b841556ff5d29582dca09767931e7cc7bc9d2f88abad437582.
Graph03 SHA256:
7aad957de36545b74dc225c2214f302357b9bcf48a3ab41ca4f44cc6e1af37c6.
Frozen Source05:907 files, SHA256:
730e65b60251f23e7c95e99650dd7375fa4c661ac8e70f96cfe8d69171ddb218.
Six maintained sources/five expected; private02 all49 triple and full AFTER39 PASS,
including all43 accepted cases unchanged. Final read-only review found no further defects.
New boot-m11-construction-paths-02 quick PASS: actual G1 and G2 each pass nine smoke
rows and their tools. Fixedpoint15/verify907 PASS, including retained Graph75/Run58
headers, both runtime objects, private Runtime03==G2 driver.o and normalized executables.
Genuine G2 Graph SHA256:
0cc869f7c12b9b3d7ae57aec8957602fcfaabe0750759ab9f5a131195f17b5a5.
G2 repeat49 interp/native/forced and full negative AFTER39 PASS on ready binaries.
G2 render semantics PASS35 paired chapters/14 cases/both source snapshots; generated
content and grammar are unchanged. Fresh-CWD/private-OUT docs-check01 PASS35/14/27/44/615,
links and index LF28142. Final fully staged index-check02 PASS with links/LF28234.
Its normalized LF receipt and this result line are added afterward as gate outputs,
not semantic inputs. Both diff --check gates are clean. The two foreign untracked
files retain their original SHA256 and are excluded. Commit/push follow these gates.
Full M11/M13/M14 remain open; this slice does not claim general typed admission or native execution.

The project's single-indent style removes redundant end trailers in two new fixtures.
Ignored format-only variants give identical complete AFTER via the language graph-same
(runs1/2) and byte-identical generated native/forced programs (four language same checks).
They replaced only those sources after bootstrap02 became terminal; the final manifest
and G2 repeat use them. Source05→06 manifest diff confirms exactly two fixture entries,
with code and compiler inputs unchanged. There is no repeated whole build for formatting.
Intermediate format-only Source06:907 files, SHA256:
5311f9c11883327b729710f2f920b87ac00a55fb45c214e6de4e7ab2c3c52a36.

The staged diff check also found an extra blank EOF line in each of the six new sources.
These were trimmed. The ten generated native/forced programs match byte-for-byte against
the actual G2 outputs; the build4 control still passes. There is no changed executable or
compiler input. Fixedpoint03 all15/verify907 PASS on the final Source07 manifest; no whole
or native binary rebuild is repeated for identical generated programs. Generated program
files are the graph emitter's intermediate output, not new maintained runners.
Final Source07:907 files, SHA256:
329fba48883be5014759e1fc74c4236873286c6050b69567c4ce3206f23ce9c3.

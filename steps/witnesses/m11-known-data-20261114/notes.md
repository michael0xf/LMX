# M11.7 — source-known reference construction (slice390)

Base: main 95715038f916123872a56372c224357de91af216 (slice389).
Root is the only code/test/build writer, directly in the main tree.
The previous goal turn made progress:389 was committed and pushed with all gates.

## Implemented boundary

Graph75 appends space_push_fresh; ordinary space_push still shares the live table.
Fresh construction uses the existing root/prior/rows and restores prior on every exit.
Run58 appends construct. Builder calls it after all P0 fields and before a separate pure
preflight. It is an explicit new-graph construction, never a recurring run/read backfill.
There are no new C layouts, persistent registries, parser flags, caches or journals.

Three temporary DATA/CODE/EXPR queues preserve receiving roles. Source signatures/defaults,
result descriptions and method DATA blueprints are not materialized. Actual F values
already created by the constructor expose their CODE, including F created in DATA copies;
that examines a real new occurrence instead of rewriting the original DATA blueprint.
For-header condition is EXPR; only its statement positions prepare declarations.
An ordinary user field named data remains ordinary DATA, not a method-part exclusion.

The current materializer handles the direct two-argument @ reference source form.
Written DATA and exact source-known Structure/F names become initialized source cells
through the existing reference constructor/publish/write/invalidate path. This is not
execution of a CODE destination write:389 still chooses DATA and commits at the reached line.
Formal, DATA, FREE, ambiguous and pending bindings close an outer fallback.
Mutable references stay deferred reads; there is no fixedpoint over their initial targets.
Calls, merge, defaults, user CODE and test are not evaluated to obtain a candidate.

Construction is itself an independent walk (kernel5.2). Raw fn/sub stay written declarations.
A retained constructor F is an ordinary graph value; the next preflight/execution creates
its own bare F. This deliberately permits a different bare F on the first execution
after construction. No table or prepared binding is transplanted to another walk.

The emitted image preserves an actual retained F with an FN-role node shell, then the
same existing source-address map fills fields, reference payloads and parents.
The map preserves sharing/cycles. No C native address or namespace row is serialized.
Ordinary language merge(F) remains an ordinary descriptor; image reconstruction is different.
Held F currently uses the walker when it has no native entry; full M14 native remains OPEN.

## Findings and corrections

Initial Graph01 proved functions11/12, nested9 and separate bare/held counter1/1/2/2.
Review exposed a real mutable-alias bug: p=a; p:=b; @q p gave1 instead of2.
Kinds5/6 are no longer source-known constants; the corrected reached initializer reads
the current working p and gives2. The forward mutable alias in unexecuted DATA stays raw
and refuses5; reaching the same declarations as CODE initializes it normally (result11).

Other corrections: DATA pending closes fallback; exact for-header condition is excluded;
ordinary data-named scopes are preserved; CODE of real copied F is included.
The first native image allocated an FN struct shell with parent0, which that allocator
refuses. The existing node_new_role_profiled shell is the correct allocate-before-edges
operation. Image02 functions/counter pass interpreter/native/forced.

## Focused evidence

18 standalone logical probes establish the chosen action; retained oracle numbers include:
- direct a/b references11/12; nested Structure9 and ordinary data field7;
- cold CODE source11 without calling cold; later DATA write11;
- mutable alias2; FREE counter2 versus constructor-held1;
- method DATA remains a two-field raw initializer before entry, then gives11;
- DATA pending stays raw (length2); header condition does not mask local a (result1);
- actual copied-F.CODE works (result9), outer/inner user-code counters0;
- ordinary self reference7;
- one independent execution:bare1/held1/bare2/held2;
- two independent executions:bare1/held3/bare2/held4.

Seven new maintained source/expected pairs consolidate compatible positive cases into one
graph (13 positive contexts and29 explicit leaf oracles), plus runs2 and five refusal cases.
Private01 all43 interpreter/native/forced rows PASS, including the accepted389 cases unchanged.
Full negative AFTER33 comparisons PASS (11 refusal cases, three executors), using ready binaries.
Old expected files were not changed. The combined alias mutation observes19 through both aliases.

Frozen Source05:896 files, SHA256
fe85448c4a7a56f8b255be21acb2a43ab10d07d45b527d7bd6c90e17aa6371ef.
Runtime03 driver.o:
0633c73b5f59743bdccaeb770a030482002c430a5325b2a691da21d91d6e10f2.
Graph02:
1c7ea326a0fd5722c8ce5735f7765e4c36e7c94087009b5cbe01eac54f2615a9.

## Bootstrap and G2

Whole boot-m11-known-data-01 quick PASS: genuine G1/G2, nine smoke rows each and working tools.
The root bootstrap log records G1; g2-build.log records the actual G1-produced G2.
Fixedpoint15 / verify896 PASS: FE/tool L1/C, both runtime objects, retained Graph75/Run58
headers, private Runtime03 == G2 driver.o, normalized executables, backend and frozen manifest.
Genuine G2 Graph SHA256:
17d12ce77360e99af075fb90967e0b7aef76f94985566a89e49b617d4bfd058a.
G2 repeat all43 interpreter/native/forced and full negative AFTER33 PASS on ready binaries.
Final read-only review found no further actionable defects; no helper built or wrote code.
G2 render semantics PASS:35 paired chapters,14 cases,both source snapshots; generated content
and grammar are unchanged. Fresh-CWD/private-OUT docs-check01 PASS35/14/27/44/615,
links and index LF28087. Final staged-index check02 PASS with links/LF28141. Its own
LF receipt and this result line are added after that check as gate outputs, not semantic
inputs. Both diff --check gates are clean. The two foreign untracked files retain their
original SHA256 values and are excluded from the slice. Commit/push follow these gates.

## Remaining scope

Source-known paths, other receiving type fields and actual new runtime merge/fromLmx
construction integration remain OPEN. Existing DATA is never repaired by step/read or
work_open_parts. Before full pure used-interface admission, admit_paths must distinguish
Consumer roles from inert DATA/groups and nested method CODE, then reuse selected bindings.
Full M11.7/8 and M13/M14 are not complete; held F without a native entry uses the walker.

# M11.7 / M14 — declaration sites and activation places (slice389)

Base: main 51929242c6b5928c875acc1bc55a8bf87e342809 (slice388).
Work/build/commit remain in the main tree. The two foreign untracked files are excluded.

## Implemented boundary

Run57 appends place_site, place_store_int and place_store_reference after the old54 exports.
Graph74 and C layouts are unchanged. There is no new map, registry, journal or activation.

A CODE int/@ declaration requires selected DATA even when a formal has the same name.
For holder == DATA the physical source index is the destination; distinct CODE projects a
unique canonical name into DATA. Inline code shares the activation DATA. Supplied DATA is
never extended. Bare WORD reads/stores are formal-first and retain DATA ambiguity.

The existing frame.rows map is bound by physical DATA slot. Distinct slots may share a
name. A destination token is either a formal index or active.width + an existing row index.
The receiving kind is checked before the RHS without reading an uninitialized payload.
After the RHS, the same row is recovered by token; no name is selected again and no row
pointer survives a possible realloc. Integer/reference working values and dirty publication
use the existing contracts; explicit path/index writes keep their direct-access role.

fn_data collects real CODE declarations even when they share a formal name. Any written
DATA entry of that name prevents auto-add, including a Structure of the wrong kind.
A formal/bare input alone adds no DATA field. The DATA initializer refresh uses its
physical row index, independent of CODE formal lookup.

## Focused evidence

The accepted388 seed refuses root_occurrence_index with3. The new interpreter obtains
seen3 with both physical x2/x3 preserved. root_repeat_refused still answers3 with unchanged
DATA; its new expected records that full AFTER.

Seven new paired fixtures have independently checked semantic oracles:
- declaration/formal overlap: caller7, receiver result7/DATA2; bare result2/DATA100;
- implicit method DATA: formal result7, newly prepared DATA2;
- distinct CODE and reordered DATA: seen10/x3/pad99; inline seen7/x7/pad90;
- formal over duplicate Self: Args5, physical x2/x3, bare seen6;
- reference overlap: receiver result7/DATA9, bare result9/DATA7, caller7;
- wrong-kind written DATA: refusal4, before1/after0, no fabricated numeric x;
- missing supplied DATA: refusal3, calls0/DATA.seen0, before1/after0.

Private01 initially18/20: reference_work exposed a real new copy-cursor defect; the
new DATA-name query overwrote the existing merge-copy queue cursor. A separate local
written_at fixes it. own_publication had only stale outer RHS parentheses: the seed and
new logs retain first21/published2/second22. Four distinct existing seed/interp/native/forced
AFTER logs match its corrected expected without rebuilding for the expected-only edit.

Final Runtime05 / Graph02: private02 all36 rows PASS in interpreter/native/forced,
including reference_work, the seven new fixtures, root positive/negative, uninit/deferred
references, call/formal/publication controls and the accepted388 selector cases.
Full negative AFTER18 comparisons (six refusal cases, three executors) PASS on reused binaries.

Earlier Runtime01/02 refused missing L2 tail cutters; Runtime03 found a struct-array
member emission error. Both were corrected before Runtime04. Runtime05 additionally
contains the copy-cursor correction. These failed attempts are not acceptance.

Frozen source07:882 files; SHA256
58c44120bda44300403dcb057719be1c6395488c694ebe5b4c8c2a4b46355fd6.
Runtime05 driver.o:
92f2ee24a59ff613b0d027666905043294861d3a24fb6459cac652703065d2c0.
Graph02:
e03d4e220a18f993543004835372ba676527246382557142a8b82b1a5acf2e34.

## Bootstrap and G2

Whole boot-m11-place-sites-01 quick PASS: genuine G1/G2, nine smoke rows each and working tools.
Fixedpoint15 / verify882 PASS: FE/tool L1/C, both runtime objects, retained Graph/Run headers,
private Runtime05 == G2 driver.o, normalized executables, backend and the frozen source manifest.
Genuine G2 Graph SHA a883ec4cdacc71f49bd3d0437df19542d1f261c8b59d8b55cc65a4bb2d8f4a5b.
G2 repeat all36 triple and full negative AFTER18 PASS on reused binaries.
G2 render semantics PASS:35 paired chapters,14 cases,both verbatim snapshots; grammar unchanged.
Docs-check01 found a wrong relative receipt link in the new steps/current block.
The link was corrected; fresh-CWD/private-OUT docs-check02 PASS35/14/27/44/615,
links and LF28085. Code is unchanged. The final staged-index check03 follows;
its own LF receipt is added after that check, as a gate output rather than a semantic input.
Commit/push follow the successful docs/index gates in the same sequential pipeline.

## Remaining work

This is bounded declaration-place work, not full M11.7/8 or M13/M14 readiness.
The common direct-access cache and complete native ordinary-Structure execution remain OPEN.
Next M11.7: materialize known admitted references in written DATA through construction,
without executing computed DATA initializers on step or retaining another traversal's bindings.

# Slice270 candidate: declared data bindings and physical source cells

Baseline published269:5f468398b569e10802a487ee64cc07cf8ef5761b.
The old267 candidate was three-way merged against its original266 base into
the current269 sources. Only normalized temporary inputs were used to
avoid a whole-file CRLF/LF conflict; frozen stages and old WIP were unchanged.
Seven compiler/tool deltas are retained; BNOT and prepared-prefix/deref fixes
from269 are present. Source184 includes the two existing diagnostic fixtures
as maintained L2. The explicit-data witness now also checks that the reached
ordinary var assignment changes D/var/x to2, while D/x becomes13 and
S/var/x remains2. The physical source-cell witness keeps D/x10 distinct
from D/var/x2.

This is not a declaration of complete ordinary-var semantics. The author
question is resolved; exact call/data/source roles must be implemented by
the common mechanism, with no name-specific execution/rebinding rule.
Short-call var, FREE-root paths, uniform status/closure removal,
collector/three passes/FULL and8/8a remain open. No build/result yet.

## Initial preparation and tool result

The 184-input candidate manifest is
0334dd014cbed622f84a4dcddbb0194d013ecd21832752c4c3521a996a8710a4.
Prepare01 completed six language-owned verify/manifest/stage-copy steps;
reuse completed five, using the existing 232 named generated support paths
from coherent boot131b. The core source is not taken from old WIP wholesale.
Tool build01 completed 2026-11-03T07:20:16.3464973Z to
07:21:58.0772139Z, RebuildExit0. Actual tool SHA256:
4723ed04f4a79a04d164080a0d11595a00ccced100a23ed5338df032cce9dae5.
Its output directory remains cold-tp132/tool131 because the reused recipe
retained its label; the source and exported L2DataBinding contracts are132.
Do not interpret that directory label as source131 or rebuild to rename it.
Frontend fe132a started at07:22:08.8273271Z; its result is still pending.

The active v3 U3 paragraph still contained the old data-rebinding proposal.
It now points to the confirmed ordinary declaration/assignment and atom
rules, without declaring their implementation complete.

## Focus and actual walker observation

fe132a completed07:25:58.5150975Z,33 producer commands exit0;
frontend SHA ffbc29fb13d4a47e8a0fa98311c0aa496d0b3538955fb8b502ad7a633e7260bb.
Suite01 has2 rows/0 failures: data_source_cells and unary_complement,
native/forced root0/root1 actual7. The explicit_data_var_field fixture
was run once via the existing os-walk-witness to collect production and
observed results without duplicating its plain build.

Observation01,07:26:34.4488010Z to07:26:37.8463882Z, is NOT a green whole
witness: its static l1_binds_native classifier returns-1 for an ordinary
namespace S (two NATIVE failures). All eight actual executions return7;
observed forced runs each contain WALK_BODY S once, native runs none.
Independent generated-L1 inspection maps source name S to l2_nsp[0].
Native2440..2443 selects that node and sets native=l2_m0_tr;
forced2468..2473 selects the same node and emits no native assignment;
the freshly allocated Structure retains its initial zero word.
Thus actual walking and the strengthened D/var/x=2 result are established;
the method-only text classifier is not silently declared successful.
Neither oracle nor driver was weakened or patched. The existing G2 suite
will verify this fixture again with the genuinely new generation tuple.

Frozen boot132a starts from source0334DD01,184 maintained inputs;
its four preparation steps completed. Whole quick result is pending.

## Following open implementation boundary (read-only during bootstrap)

The existing Copy/Inner witness from266 remains a separate FREE-root path
failure. Current resolve path_root_select retains the hidden input row;
path_root_close preserves its selected contract. path_walk_bound then calls
path_walk_steps_from, whose no-schema branch (resolve3144..3147 in269)
rejects the first named step before any actual runtime value can be used.
The walker OF path currently projects a physical index or an admitted
model/code slot (walk_values3467..3634). A repair must share the actual
place selection and classification with native, preserve the current held
root value and named admission, and must not substitute a lexical schema
or introduce body preflight. No new runtime implementation is claimed here.

The independent observer check also reads node allocation:
lmx_value_owned78..88 initializes native to zero. The forced S constructor
omits its native assignment, consistent with both actual WALK_BODY logs.

## Admission-use review before publication

One further separating case is prepared at tp132-unused-probe/unused_data.lm2:
the same S/var and D/var both include an unused nested field, while D has no
separate top-level unused cell. The body refers only to x; its reached var
assignment has a compatible nested destination. collect_data_bindings sets
m_uses for every added alias, dyn_local scan_bound repeats that mark, and
split_data_row/place tables currently include all logical aliases. This
may demand data/unused despite no consumer of it. The concern must be
checked with the one prepared case after boot132a, before landing. No
runtime failure or new normative choice is inferred from this note.


## Boot132a completed; unused binding failure confirmed

Boot132a completed07:40:04.9505308Z, BootstrapExit0,764.07s. Each
generation has248 inventory hashes;496 actual hashes checked, zero stale.
245 files match raw, three equal-size PE files differ only at actual
TimeDateStamp/CheckSum offsets136/137/216/217. All33/39/6 producer commands
in each generation exit0. Consumed-inputs306 match raw; working tool is G2.
The independent hash/producers receipts are retained under pins.

This does not accept the candidate: tp132-unused-probe-01 completed
07:40:36.4158295Z, SuiteExit1,one row/four run failures. Both native/forced
compile, but both roots close R0 unsuccessfully before the expected exit.
The unused nested declaration was incorrectly a top-level data requirement.
Fix02 removes eager use marks, retains entry visibility, and records actual
reads/writes through scan_bound. The common split-place predicate excludes
unused logical aliases, while written body declarations retain their rules.
The existing explicit_data_var_field fixture now includes the separating
unused nested field and verifies its reached assignment. No new language
rule, body preflight, driver change, or weakened expected value is introduced.
Frozen132a and its historical receipts remain unchanged; selfbuild is269.

## Author-history correction before publication

The exact2026-10-15T22:09:00.405Z author example was recovered from the
same chat (msg_01a1419c-89f4-7ba2-bbe2-aaf98a1f12d4). Reserved var defaults
to the selected data reference; assigning var replaces that binding
normally. Later explicit paths use its new value. The recent documentation
claim that this reference cannot change was incorrect and is removed.

Boot132b remains a useful generation check of the frozen candidate, not
acceptance of ordinary-var semantics. In particular, the current maintained
explicit_data_var_field candidate still expects a write to D/var merely
from the var head; it does not separate the reserved activation reference
from an explicit field path. DO NOT LAND270 or accept that oracle as the
author's rule. Keep the frozen results; adapt the active implementation and
separating case to the recovered ordinary assignment, with no new author
question. Selfbuild269 remains the accepted package.

## Normative correction source and next implementation boundary

The full point5 and example are archived verbatim in LMX_blog/2026-11-03.md,
with the original message id and timestamp. Adjacent author replies in the
same bounded history extract include the instruction to document the change
at2026-10-15T22:20:13.297Z; there is no unresolved request for author approval.
The live book's RU/EN namespace tables and ordinary-var section, migration
plan, coding instruction and resolved U3 question now agree on the default
reference and ordinary assignment. Generated RU/EN must be rerendered from
the book after the one current bootstrap completes.

Current source has no default reserved-var binding: path_root_select handles
ordinary roots and node; the sole walker literal var lookup selects a code
field for unary-call data. The proposed fix must initialize the real local
binding from the selected data and reuse ordinary place/read/write/address
semantics, including the author's local @ rule. A lexical code/var shortcut
or a required data/var field cannot implement that binding. A separating
case must read var/x before reassignment (selected data), then after an
ordinary var assignment (new reference), while an actual data/var field
remains separately observable. No implementation of that path is claimed.

## Boot132b diagnostic result

Boot132b ended2026-11-03T08:02:20.0110732Z, BootstrapExit0,790.29s.
Both generation smoke lists have9rows/0failures. Independent hashes verify
all184 source inputs and both248-entry inventories (496 actual hashes):
245 raw-equal, three equal-size PE files differing only in actual
TimeDateStamp/CheckSum offsets136/137/216/217. Consumed inputs306 match raw,
and the working tool equals G2. All33/39/6 producer commands in each
generation exit0. Exact receipts:
pins/boot132b-quick.terminal.txt,
pins/boot132b-independent-hashes.json, pins/boot132b-producers.json.
Source manifest1d03f906a1708a2e65f1845b2f0a9f750e7dce57699eea5a800c9cf79e53f76e.
G2frontend8a41861fb97a5282baa055ddb5fa26619fb229d0bcf0722a762a4963cb364ecf.
G2tool4aae5f226b61d9e87643db2c9909babb8d1de369d779ed74bc7e0b7a94167ce6.
The pipeline has ended. There is no G2 semantic acceptance or landing270;
selfbuild269 remains unchanged for the ordinary-var correction described above.

The corrected book was rendered by the accepted boot131b working tool
using pins/docs270-render02.command; its actual terminal records exit0.
The following docs270-norm-check is the existing language-owned complete
documentation check, not a compiler/test run of the candidate.

## Documentation correction verified; semantic diagnostic remains open

docs270-norm-check01 (named docs270-norm-check) exited1 before the EOL
phase because the new archive link needed an explicit id anchor. The link
and anchor were corrected; docs270-render03 exited0. The ordinary complete
docs270-norm-check02 ran2026-11-03T08:03:59.8281123Z through
08:06:57.9117729Z and exited0:35 paired semantic chapters,14 implements
cases,27 paired grammar sections,44 verbatim excerpts,615 imported files,
links/opening and LF for15838 indexed files. No checker rule was changed.
The primary point5 excerpt is a contiguous exact match of the recovered
author message, including original escapes, typos and HTML sequences.

The mutable explicit_data_var_field fixture now separates initial var=data
from reassignment and from the distinct explicit D/var field; its SHA256 is
262aaba319522ecb08f8181c6afe07557e3150f435d5bf614398c1efca1b79d3.
Only this revised variant/test copy changed; frozen132b and its source
manifest stay unchanged. The existing suite recipe ran one diagnostic
using the verified132b G2 compiler/runtime/tool:
pins/tp132-var-binding-probe-01.terminal.txt and .log,
2026-11-03T08:07:21.1951527Z through08:07:21.5891638Z.
SuiteExit1,one row/two translation failures. Both native and forced reject
the first var/x at4:13 with "field path goes through a slot with no Structure",
atom=x. This is a confirmed implementation gap, not a normative refusal or
a successful semantic test. Do not land270 from the previous green oracle.
Next: provide the actual default binding and reuse the common runtime path
and ordinary assignment; preserve data-field/activation-cell distinction.

# Private137: C-member roles project the common selected root

Base main: `c4c8f04b123b6b9b68dde738e6192ba68d56858f`.
Final source `build/codex_raw_classify_137c`, frontend
`build/codex_raw137_build_03`. The [one-source U0 patch](witnesses/used-scope-20261020/raw-root137-u0.patch)
applies over [Private136](bound-root-consumers-20261021.md)'s final136d.
Replay `build/codex_raw137_replay_01` reconstructs the exact compiler source.
Application/runtime/ABI sources are unchanged. This is a private clean-kernel
dependency, **not all-path unification, public-dev deployment, full gate or §8**.

## Mechanism and consumers

The independent `l2_raw_path_root` formal/slot/local loops and their summed
numeric category are removed, together with `l2_raw_path`/`l2_raw_path_rec`.
`l2_raw_c_root` is now a text-root entry to the existing common root resolver,
not another table search. `l2_path_root_raw_c` projects a selected root's closed
type, including a typed hidden input; it never resolves the source spelling.

Whole-value and operand-run CHECK choose the root once, classify that record,
then either leave opaque C members to C or continue `l2_path_walk_selected`.
The native member reader uses that same classification. The write check also
uses the retained root, under the explicit source method's environment.
`l2_is_path_head` receives that method explicitly and selects once, without
first asking another raw classifier to choose a binding.

The raw-head API no longer returns the old numeric category. Its old
formal-index-specific const checks are removed: the path-write check consumes
the selected closed root type instead, including hidden inputs. Actual const
refusals below guard this migration; no const rule is relaxed.

Graph span typing/read production consume their selected root and continue
the same semantic walk for non-C paths. `l2_rw_member_body` projects the
selected root directly into the existing native-only source representation,
using the common binding projector in both COUNT and EMIT. The old
`l2_rw_foreign_path` substring classifier and manual root split/relookup in
machine-member production are removed. Text-only member operands enter the
common adapter once for that production. A scalar member-store producer borrows
the cached P0 head record, not its own split of the head string.

No new resolver, graph field, opcode, Model candidate table or runtime context
layout was added. Foreign C body operations remain **native-only**; retaining
them in a graph is not interpreter execution of arbitrary C storage.

## Actual corrected source behavior

The [positive hidden-pointer source](witnesses/used-scope-20261020/raw-hidden137-probe.lm2)
calls a method with a hidden C pointer supplied by its caller. It writes the
actual record's scalar field, then reads that field and indexed `cells[1]`
in SOURCE expressions. The caller requires the result32 and independently
observes original scalar23/cells9. Thus translation alone cannot pass it.

Old136d refuses the SAME source at `ptr\scalar` with `unknown field path
segment`. Final137c translates, strictly compiles/links and actually passes
both root modes, driver **13/17, 0 roots**, exit0. Native bodies remain native
under `walkroot`; this is not forced interpretation of those C operations.
The [136 value/pointer source](witnesses/used-scope-20261020/raw-value136-probe.lm2)
also repeats actual reads, scalar/indexed writes, copy isolation and persistent
pointer writes in both root modes. Both published programs use the **fresh137
matrix runtime**, not an older object.

The [formal const](witnesses/used-scope-20261020/raw-const137-formal-refused.lm2)
and [hidden const](witnesses/used-scope-20261020/raw-const137-hidden-refused.lm2)
sources each refuse the actual write with `const write`, exit1. They use the
current name-first declaration order. Earlier type-first const preparations
stopped at `incompatible entry signature`; those are not these semantic controls.

## Positive REDs remain positive, not convenient refusals

These new registered evidence files still require successful actual values.
`open_observe_01` records their current L2 failures without changing that oracle:

- [Nested foreign capture](witnesses/used-scope-20261020/raw-capture137-open.lm2):
  `unknown field path root`. Diagnostic-only compiler copy `trace_01` shows
  the inner method has dyn0/arity0 and no selected root. Existing capture
  admission leaves this foreign value unrecorded. Replacing a later classifier
  cannot supply a nonexistent hidden input; no C-type allowlist was added.
- [Indexed hidden write](witnesses/used-scope-20261020/raw-hidden137-index-open.lm2):
  `unsupported index` at `ptr\cells[1]`, before type closure. The old/new
  head grammar is preserved; the receiving check must respect pending common
  source contracts rather than create a one-case permission.
- [Hidden by-value C input](witnesses/used-scope-20261020/raw-hidden137-value-open.lm2):
  `dynamic input type has no value cell`. This source omits that early indexed
  write to expose the earlier value-transport dependency independently.

These are additional known positive REDs, not members magically counted GREEN
in the old85/170 comparison and not a changed full-gate count. Original scratch
sources and diagnostics are retained. The first tentative classifier-only137
build did not resolve all these programs; neither did137b. Do not report otherwise.

## Final regression scope

`build/codex_raw137_verify_01.ps1`, session12429, **terminal0**:

- Existing actual-frontend retained-root SAME84: **0 FAIL**, old135 **30 FAIL**.
  This protects the136 consumer invariant, not a newly invented137 test count.
- Native indexed-write source **82/0**, same135 source/oracles.
- Permuted Structure/Array/read/write/taken-address **36/0 native and
  36/0 forced walker**, independently compiled.
- Source-linked compiler metadata **336 unchanged checks**.
- **85 fresh L2/L1/C/GCC/link units, 170 actual runs:162 GREEN+same8copyRED**,
  same native binding counts, modes, exits and observations;341 parent pins.
  Worker12092,startUTC `2026-10-21T19:45:07.0114456Z`.
- Four foreign-value executions **13/17/13/17** link that fresh runtime.

Do not sum overlapping focuses or turn the three additional RED programs above
into a claimed full-gate result. Named PowerShell recipes are transitional
evidence tools, not language-owned self-build. Strict C99 incompatible-pointer
and discarded-qualifier checks remain enabled; O2/fstrict-aliasing runtime/units,
O0 frontend. One GCC pipeline, no branches/worktrees/PRs.

`controls_01` and `published_01`, session32009, **terminal0**: exact final137c
indexed-unit SAME82 wrong-owner and late-target controls each strictly
compile/link, complete82 with **2 assertion FAIL**, exit1. Both published
positive sources complete the actual13/17 runs described above; the old source
refusal and both const refusals are separately captured by
`refusals_published_01`. They are not inferred from earlier binaries.

```text
compiler source BD2BDA642432B242A7FB021EF5ED0F2F7D939298FF9998AA8729B90641D12663
frontend C     7C702EF2CD60176B1721A4DA3B90242B53F4B36CC5D0C9FBC73E17899998245C
frontend EXE   643E880A0E1D9735E2D855AA47A122E4DE6C7B61E7D5F7521EF7A4AEA85EE6BC
runtime C      471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh object   063E9F3EB602D341EF2C2629BFA55D7796B07DF72FDF0B254240C5095AFF5892
one-source U0  235073D49ED3C580D6C29D9478037D2530327E1AF45F2ECB9E398DEE22CE6D52
```

Terminal receipt `build/codex_raw137_terminal_01.inputs.sha256`: **2059 pins**,
SHA256 `6E676097B15AEB2C3C6A5293380B7897D01B23F4DCEAF29AAF702E433082D018`.
The [summary](witnesses/used-scope-20261020/raw-root137-evidence.json) records
identities and limits. It pins named sources/output dirs, commands, source
witnesses, quoted C/header dependencies, selected tools and parent receipt
digests.341 selected prior inputs were verified by the fresh matrix, not every
historical input. This is not full SDK/preprocessor closure: `decNumber.h`
remains unresolved by the conservative include scan.

Named `build/codex_raw137_*.ps1` recipes retain reproduction commands:
`build_03` → `verify_01` → `controls_01` → `published_01` →
`refusals_published_01` → `terminal_01`. The matrix freshly compiles runtime;
focus fixtures reuse the byte-verified renamed134f object. Test-only C ABI
predefs remain transitional evidence, not supported handwritten-L1-free §8.
Diagnostic prints exist only in `trace_01`'s C copy, not in the final source.

## Still open

The native text entry can still classify a raw head and subsequently re-enter
the common adapter in emission. Ordinary non-C fall-throughs and the raw index
atom/span readers are not yet one retained end-to-end result. Old
`l2_raw_index_text/span`, `l2_prefix_deref`, `l2_deref_word`, per-step maps in
all consumers, pending type-dependent index checks, opaque C leaf types/target
freezing, address lifetime, capture and value transport remain work.
Shared root classification alone is not proof of universal path resolution.

Public dev remains unchanged. Last full112 **1011 FAIL/3754**, eight old
positive-copy REDs, clean kernel, two L3/L2 self-built generations and mail
T01–T26 remain OPEN. Goal ACTIVE, Codex sole writer/build. No pause, substitute
goal or duplicate timer. Unrelated WIP is excluded; protected diagnostics are
not read, copied, hashed or staged.
Both doc generators and staged check_docs7119 pass;staged diff check passes.
All2059 terminal inputs were independently rehashed;all named137 workers ended.

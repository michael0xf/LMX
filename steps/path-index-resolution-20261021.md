# Typed machine indices resolve in the common path fold

Typed machine INDEX steps now receive their address type, consumed value
type, receiving model and write qualification in `l2_path_walk_steps_from`.
The raw indexed-place projector no longer repeats the pointer-type fold.
This closes that duplication, not all path consumers: repeated entries into
the common resolver and opaque/mixed physical projections remain open.

Base main `7e7ff96b7d7ebc23db284236acedb811b0cf94c7`. Candidate
`build/codex_path_index_142`, final frontend `build/codex_path142_build_06`.
The [two-source U0 patch](witnesses/used-scope-20261020/path-index142-u0.patch)
applies over [Private141](index-record-retention-20261021.md) with
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
Replay `build/codex_path142_replay_02` reproduces both source hashes.
Only compiler source and its internal application header change. Runtime C
is byte-identical; no graph, Value, Place or uniform ABI layout changes.

## The mismatch and the selected result

Before this change the actual read-probe source translated successfully and
passed its66 actual-value assertions, but its common path observations
contained **seven first-INDEX refusals**. The later raw physical fold rescued
those same typed pointer paths. Final142 translates the identical source
with zero such refusals. The13 observation records include unresolved
whole-value observations; this dump is not a complete Consumer certificate.

An Array INDEX still consumes its receiving Array level. A machine INDEX
consumes the exact closed pointer contract before that step. `address_ft`
retains its C qualification; `elem_ty` and `cell_ft` carry the value after
the step; `cell_const` records the selected cell's write restriction. A
receiving model is derived from the original declared contract and consumed
depth, not from a runtime candidate's parent. Ordinary graph references are
not silently reclassified as C-indexable storage.

`l2_path_record_view` carries the current root, steps, types/maps and leaf
together while borrowing the original text and AST. A grammar-only prepared
view clears those verdicts, including the new fields. The raw projector
copies a completed record; an unresolved cached head enters the common
resolver. It no longer calls `l2_indirect_type` or reconstructs the typed
cell's const restriction. Native uses each recorded address contract; its
existing physical selection and CURRENT-value load are unchanged.

The Array-place view distinguishes resolved machine cells from descriptor
Arrays. Address-taking projects the same selected physical cell and its
qualified pointer. Effects consume the same step verdict: checked Array
cells retain their failure channel, physical C indexing does not acquire an
Array bounds channel, and index expressions keep their own effect scan.
Retention uses Private141's completed-place constructor; no new runtime
operation or interpreter opcode was added.

## Independent controls and actual values

The [source-linked common-resolution fixture](witnesses/used-scope-20261020/path-index142-common-test.c)
parses actual P0 receiving heads for formal, activation-slot and machine-local
roots, at ranks1/2/6/65/129. It checks every pre/post-step type, original
index AST, qualifier, geometry and effect verdict. After resolution it
poisons both spelling and type tables: physical projection must consume the
completed record. This is a compiler-consumer control, not recovery of an
ancestor of a changed runtime graph. SAME420 gives **old141300 failures /
exit1 → final1420 failures / exit0**. The test also checks that a fresh
grammar view clears all typed verdicts.

Sequential session21895 completed. Fresh85-unit worker7792 started at
`2026-10-21T22:16:46.6634384Z`. All named checks are terminal.

| Final check | Actual result |
| --- | --- |
| Source-linked metadata, unchanged assertions | 336/0 |
| Retained-root spelling poison; equal COUNT/EMIT | 84/0; original old13584/30 |
| Canonical P0 grammar, old140 and final142 | 343/0 EACH |
| Indexed native stores | 82/0 |
| Field/Array read, write and taken-address source | 36/0 EACH native and genuinely forced walker |
| CURRENT read, address/write, rebinding effects | 66/0, 50/0, 24/0 against freshly compiled runtime |
| Exact lost-CURRENT and wrong-owner controls | SAME66/12 and66/4, exit1 |
| Exact delayed-selection control | SAME24/10, exit1 |
| Existing write controls | SAME82/2 each, exit1 |
| Const index write, const dereference write, qualification drop | Three located CHECK refusals |
| Fresh85 units /170 actual runs | 162 GREEN and SAME8 copy-positive RED |

The matrix reverifies341 selected parent inputs and preserves every prior
actual status/exit. Two foreign programs, three published value programs
and three indexed-callee programs also produce their actual13/17 checks in
both root modes. Their raw C bodies remain native when the root is walked;
this is not arbitrary-C interpretation. The three focused generated-C units
are byte-identical to final141. Common-resolution evidence above, not an
altered native emitter, establishes the semantic change.

## Exact bytes and rejected attempts

```text
compiler source 498EDD34A9DC735CA52A6844F4225F2296A2DB6719F19733849BC5DCF4515E49
application     CF6648189ECA39C4E348A167AB4015C462DDF476C40144DCE5FEEB98AE4FC08A
frontend C      19DA3EE72F89C493CB35EC5AE2E3C59559CDB1102D0A80CC8FA655F213F5B7FF
frontend EXE    1533345659D78E349608DFC66F821764FC779D697A5F42500B54D2DAC719278B
runtime C       471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9
fresh matrix    323E311FCEF6F7E175F50BCF72BDF0138C5E80B46416AE41D9FC8FCEDEBF65D8
fresh renamed   6595B22636E1ECB9BDF2B048ABA82A3A3050EBC4D7C78D3F8BBE61E04166F9BF
two-source U0   6527262AEE7D98657BA862A9E4F33CEF154437CB80D9EAFD8F356FC8935A5A21
```

Receipt `build/codex_path142_terminal_01.inputs.sha256` contains **9247 pins**,
SHA256 `9598A888D81FEDA70D635BA391BF88E3AC8C6D25ACF381C66C7486ABF421A2E4`.
All7025 parent141 inputs were rehashed. The [evidence summary](witnesses/used-scope-20261020/path-index142-evidence.json)
retains the exact identities and boundaries. The conservative quoted-include
scan still reports `decNumber.h`; SDK/preprocessor closure is not certified.
Recipes: `codex_path142_build_06.ps1`,
`codex_path142_pass06_verify_01.ps1`, `codex_path142_terminal_01.ps1` under
`build/` preserve commands and outcomes.

Preliminary02 lacked forward declarations. Build04 exposed an unneeded
machine-type read while resolving an ordinary NAME-only schema path;
build05 then exposed an unnecessary Array-descriptor interning allocation
in the unchanged cursor test32/1. Final06 asks for machine typing only where
an actual non-Array INDEX needs it. The original336 assertions pass unchanged.
Those failed attempts and the prefix-mismatched replay01 remain preserved;
neither is final evidence. Explicit frozen artifacts and completed matrix
units were compressed with before/after SHA equality, without deletion,
directory/system targets or protected-diagnostic content access.

## Work that remains

Some dispatchers resolve an Array view, release a machine result, then ask
the common resolver again through the raw entry. The separate type fold is
gone, but those duplicate common entries still need removal. NAME-after-INDEX
physical projection, opaque member/callee contracts, earlier call-role
resolution, other dereference consumers, capture transport and lifetime are
not closed. The original opaque effectful callee and mixed store positives
remain RED; a missing physical projection is not a successful negative test.

Public-dev integration, last full1121011 FAIL/3754, the same eight copy
positives, clean kernel, two actual L3/L2 self-built generations and mail
T01–T26 remain OPEN. The transitional PowerShell/C tests do not satisfy §8.
Codex remains sole writer/build and goal ACTIVE. Next: carry the one resolved
head/run result through representation dispatch instead of resolving it again.

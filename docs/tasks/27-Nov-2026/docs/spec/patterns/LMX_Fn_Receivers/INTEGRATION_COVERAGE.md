# Canonical library integration coverage

The current package publishes **215 canonical operation names in 227 semantic
variants**. The [migration inventory](CANONICAL_MIGRATION.json) accounts for all
212 input exports, with the exact input catalog SHA-256. Renamed exports are
not retained as callable aliases. `pipe` denotes immediate value application;
callable composition is `compose`.

## Source ownership and one shared algorithm

| Contract | LMX implementation and shared dependency |
| --- | --- |
| Ordinary/deep Array equality and stable generic uniqueness | `FxValueSame`, `FxEqualFields`, `FxSequenceDifference`, `FxUnique`; optional equality delegates to the same pass |
| Membership, association, properties, mismatch, search and memo keys | Shared `FxKeyIndex`, `FxSequenceSearch` and equality; key projection is optional and evaluated once per selected value |
| Adaptive constructors | `FxRecordAdapter` captures one admitted whole value and invokes the single constructor positionally; `some`, `ok`, `err`, `done` retain exact container results |
| Canonical `bind` | Maybe and Result use typed short-circuit wrappers over `FxBindChain`; Array delegates to `FxSeqBind`; no legacy callable aliases |
| `type` and `->` | `FxValueType` observes the record type; `FxToTypes`/`FxToTokens` place the result TYPE last and use one signature-construction body |
| Receiver and operand forms | Every catalog variant records both targets, roles, source declarations, required fields, exact result and declared finite throws |
| Prepared operand DATA | One ordinary `FxPreparedOperands` fragment; each consumer supplies its explicit ready priority, requiredness and result |
| Value pipelines, projection equality and result retry | `coreGenericOperations.lmx`; `FxPipeBuild` and `FxRetryBuild` publish exact R through the existing `FxWrap` engine protocol |
| Generic Pattern sources | `RxPreparedSource` plus explicit `ArrayView` and text profiles; the same Pattern/cursor/backtracking/capture engine consumes actual units |
| Pattern builders and extraction | Generic literal/element/members/within/predicate/boundary/then/sameAs and source-domain slices; text encoding remains an explicit profile |
| Generic sequence/text operations | One search, trim, pad, translation, affix, join and cycle implementation; text defaults are thin adapters |
| Range and codecs | Existing exact integer profiles plus explicit `FxRangeProfile`, `FxProfileRange`, `FxProfileFormat`, `FxProfileParse`; selected profiles retain their domain and error contracts |

The [publication contract](PUBLICATION_CONTRACT.md) contains the concrete actor
and translator integration requirements: whole-value capture before default
admission, semantic family selection, exact R/void, TYPE/RAW/FORM/PLACE routing,
canonical names and finite callback failures. Prepared family data is ordinary
graph data. It does not by itself prove those production hooks are connected.

## Catalog and source coverage

- [catalog.json](catalog.json) is generated from
  [operation_definitions.json](operation_definitions.json). Each variant also
  contains its current explicit source declaration and resolved finite throws.
- `src/public.lmx` contains one canonical projection per name;
  `src/public_families.lmx` records the actual family pairs and
  `src/public_operands.lmx` prepares ordinary VALUE adapters.
- All seven addition manifests point to existing canonical variants and contain
  refreshed implementation hashes. Shared definitions remain in their source
  files and are assembled once.
- [LMX_Receivers.lmx](LMX_Receivers.lmx) contains 52 source/fixture parts. The
  package retains the 20 explicitly named kernel provider interfaces.

## Verification and required runtime observations

`tools/check_static.py` passes the package checks: canonical migration and
variant coverage, two forms, unique public projections, source existence,
balanced literals/brackets, indentation/cutters, qualified root coverage,
documented external provider identities and exact assembly equality. These
checks cover 637 active Fx/Rx root definitions and 221 prepared assertions.
They also reject undocumented system-template imports and missing explicit
priorities on the shared prepared-operand fragment's consumers.

`tools/sync_effects.py --check` resolves **410 recorded contracts, including 389
explicit declarations and 20 shared lists**, without changing their authored
form. [The earlier explicit declaration change record](tests/effect_contract_changes.json)
and [the current tensor source revision](tests/tensor_effect_revision_20261127.json)
describe the integration changes. This is neither an effect inference engine
nor proof of all dynamic call/catch paths.

`tools/check_standard_objects.py` passes its 44 source/hash/metadata checks.
The current Pattern visible-level audit covers 66 files. Its two remaining
observations identify balanced multiline call groups for manual review; they
are not parser failures or runtime results.

The permanent original core matrix retains **181 cases** (58 type, 82 sequence,
41 Pattern). [The generic matrix](tests/generic_operations_acceptance.json)
adds **327 observations**, including one ordinary/operand equivalence obligation
for every one of the 227 variants. Representative LMX source fixtures live in
[generic_operations.lmx](tests/generic_operations.lmx). All four interpreter/native
execution modes remain **NOT_RUN**: no LMX parser/compiler/runtime executable
was included in this package.

## Regeneration

From this package directory:

```sh
python tools/rebuild_catalog.py
python tools/assemble.py
python tools/sync_metadata.py
python tools/rebuild_acceptance.py
python tools/rebuild_generic_acceptance.py
python tools/check_static.py
python tools/sync_effects.py --check
python tools/check_standard_objects.py
```

`tools/rebuild_core_inventory.py` regenerates only the canonical tables inside
the current `spec/CORE_FUNCTIONS.md`, preserving its authored normative prose.
The repository-wide publication process refreshes comparison mirrors, statistics
and final manifests after source changes; this package does not execute those
external publication steps automatically.

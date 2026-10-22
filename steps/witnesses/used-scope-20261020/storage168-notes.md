# Storage/address168: verified slice, not whole-primary closure

The author still assigns Codex the sole writer/build role. The existing goal
stays ACTIVE. All work is under `build2`; the old root `build` and protected
basenames are not accessed. Source is the frozen167 closure plus the U0 delta;
this is not a promotion into public `dev` or completion of kernel/self-build.

## Shared result, not a second path grammar

`l2_primary_sizeof_value` borrows the same complete prepared body used by
ordinary primaries. `l2_value_type_operand` recognizes an explicit machine
type position only after preparation; existing declaration/cast type syntax
is interpreted by the common contract reader. Value paths go through the
existing owned path verdict, including all INDEX children. The storage query
reads its selected type and declaration address, never finds a binding by name.
The previously private sizeof name and type-frame readers are deleted.

CHECK, native and retained COUNT/EMIT use those projections. Native produces
only a size/type expression: it does not load an operand, call an operand or
initialize an index/numeric temporary. Existing declared backing-Array byte
size is preserved separately from a reference/returned Array's ABI. This does
not certify all foreign opaque types, dynamic storage cases or C operators.

The first stronger test found a general address-owner defect, not a special
sizeof case. Address representations deep-copy paths. CHECK was closing
nested INDEX verdicts in that representation copy, then discarding it; the
expression's original children were left unresolved. `l2_address_target_record`
and `l2_address_operand_span` now give CHECK that original owned target. Later
backend copies carry the completed child verdicts. Raw machine-index selection
also reads the selected root contract rather than re-reading the own-type table.
No borrowed stack pointer or additional mutable cache is stored in an address.

## Evidence and boundaries

- The same strengthened storage fixture runs on parent167 and final06. Current72 assertions
  include original-owner release, name AND FT poison, exact size_t type,
  zero parser/root/fold/raw retries, zero operand emission and COUNT=EMIT.
- A distinct ordinary-address fixture has no recursive type warm-up. Its
  54 assertions cover three address spellings at INDEX depths1/4/16. All
  post-poison projections use the closed original children. Parent167 loses
  those child verdicts and retries a root lookup. Sampled depths are witnesses,
  not a language limit or a claim of exhaustive coverage.
- `sizeof-values.lm2` executes nested pointer/Array indices, distinct declared
  extents3/4, a cyclic implements field permutation, taken-address write31,
  readback through that address, the physical Have field and untouched sentinel.
  Unevaluated index and result calls keep touches=0. Eight strictO2 production/
  observed root0/1 runs are recorded. The methods remain native-only; forced
  root traversal must not be called proof that sizeof method bodies walked.
- The inherited pure `projection-length` witness genuinely walks its mapped
  Array/address method. Native-only machine/cast programs remain explicitly
  separate. Existing corpus failures are not converted into refusal oracles.
- Early01's non-path status mix-up and early02's original address-owner defect
  remain pinned. 04's broad gate then caught an accepted opaque C-member
  address incorrectly rejected by CHECK's new demand for an L2 leaf type.
  05 consumes the SAME admitted address result and its original INDEX owners,
  including a C-selected representation whose member type remains opaque.
  Three opaque spellings have18assertions on the same test: parent167/05pass,
  04has6failures. Native and COUNT/EMIT have0parse/root/fold/raw retries.
  Historical strictO2 then caught05's raw `ulong` alias emitted as a C type
  identifier. 06 uses the common L1 pointer declaration formatter and an
  UNEVALUATED typed witness,`sizeof(*((T *)0))`,for every known formal type.
  It does not load the operand or execute that null-pointer expression. The
  strengthened fixture covers scalar,type,cast and pointer aliases;the real
  program covers a scalar and backing Array of ulong. The small standalone
  `type-witness.lm1` also passes L1 translation,strict C99 `-O2 -Wall -Wextra
  -Werror` compilation and execution0. L1's prefix dereference requires the
  separate operator `\ (cast:...)`,not a Frame headed `\`.
  No old or intermediate result is counted as final06 evidence.

The historical control selection preserves the original source bytes, including
the1100-level pointer type. Both compiler generations are measured. Positive
historical files still rejected by the preceding declaration migration remain
OPEN; their refusal is not certified as a language rule. Translation of an
inspect-only example is not counted as an execution.
Historical root-walker machine-sizeof UNSUPPORTED cases are also kept OPEN
with their original required values,not changed into expected failures.
Their runtime rows stay unsuccessful and are excluded from positive/matching
execution counts. That is not evidence of a pointer/type depth limit.

## Next common dependency

L2 specification section19 explicitly gives `c.sizeof` C sizeof semantics.
The existing foreign-call adapter eagerly emits its actuals, unlike a C
unevaluated operand. `machine-unevaluated-open.lm2` is a positive counterexample:
expected result7/touches0; measured parent/current result88/touches1 is kept
OPEN, not included in the green runtime count. The repair belongs in the common
foreign receiver's operand/evaluation contract after full preparation, not a
native-only spelling guard or another source parser. Opaque C typing must not
be hidden by substituting an untyped0 or pretending an arbitrary C symbol is
an L2 primitive.

The common unevaluated contract must preserve operand validity as well as its
size. In particular, machine INDEX currently delegates some C constraints to
the C compiler; a type-only projection must not be mistaken for proof of those
constraints. Invalid index/operator type controls and opaque C constraints
need explicit coverage in that follow-up. The current positive fixtures and
zero-emission measurement do not certify all such type-error cases.

`implements` still has a shallow field-intersection predicate, not the complete
directional used-path/call-contract rule from L3 section7. Raw Model receiving,
actual/return/source clients (including the still-raw native function-pointer
call's expr-span/fields loop), signature/root metadata, the `l2_bind_call_in`
synthetic P0 copier/settling loop, defaults, full body/trailer semantics and
kernel/K03/self-build/mail remain open. No runtime/header field, opcode or new
name registry is added by this slice.

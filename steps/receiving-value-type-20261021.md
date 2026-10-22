# Receiving values retain their selected root type

Numeric receivers, assignments and conversion emission now preserve the
actual operand field and obtain a bare named value's type from the common
resolved result. A local number no longer becomes an unrelated same-name
Structure in these consumers. Three programs pass24 actual native/walker
runs, including the previously failing numeric initialization and assignment.
This private compiler change does not close public-dev or all path consumers.

Base main `c53f43f0a9e14b02c1c5bae491e9a95be6ac61dc`. Candidate
`build/codex_receive_value_147` uses unchanged frozen144 headers and L1
working-directory inputs. Final frontend is `build/codex_receive147_build_03`.
The [compiler patch](witnesses/used-scope-20261020/receiving-value147-u0.patch)
replays over [Private146](root-value-type-20261021.md) with
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
Application/runtime ABI, graph fields and runtime operations are unchanged.

## Receiving consumers use the actual operand field

`l2_colon_field_ty` passes the original P0 field, node and single-field span
to the existing `l2_root_value_type`. It projects the common completed root
type. Only another expression shape enters the existing literal/Frame reader;
a failed named root does not retry namespace classification. No replacement
P0 tree, compiler registry or runtime marker is introduced.

The numeric receiver check and native conversion emission share that query.
Assignment's `l2_colon_value_ty` and all nine callers now retain actual fields,
including pointer arithmetic, argument checks, stores and indexed operands.
Throw payload typing and the numeric-return reader use it too. The receiver's
separate namespace-head override is deleted. The numeric core checks pointer
kind from the selected type, rather than accepting a raw pointer because it
has no primitive numeric code. An unreachable second bare-atom callable
lookup in the value typer is removed.

The [numeric positive](witnesses/used-scope-20261020/receiving-value147-numeric_receive.lm2)
declares local int Need91 beside a global Structure Need, initializes saved
from it, then assigns it again. Published146 refuses the initialization.
Exploratory14701 fixes that consumer but exposes the assignment's second
type query. Final03 fixes both through the same field query; it does not
special-case Need, int, declaration versus assignment, or a backend.

The [independent fixture](witnesses/used-scope-20261020/receiving-value147-type-test.c)
runs114 assertions against actual generated frontends. Old146 has20 failures;
final03 has zero. It retains the eight-type and post-resolution type-table
poison controls from146, then counts actual GCC entries into the common root
resolver for receiving/assignment queries. Each enters once. Failed names do
not enter the old simple classifier; literals keep their literal type without
a root lookup. These are dispatch/type assertions, not114 source programs.

## Actual values and conversion effects

The numeric positive and the two unchanged146 scoped positives produce
**24 actual runs, all exit0**: native/forced methods, native/walked roots and
production/observed runtime. Six unit objects are freshly strict-O2 compiled
and12 executables freshly linked. Production143 runtime and the existing
observed runtime object are reused by exact SHA. Entry is7 with13/17 driver
checks. Observed actual walker-body counts are0/1 for native/forced work under
native root and1/2 under walked root. The full scoped program still checks
Need91, mapped Array reads, writes through the captured x address, x43 through
the original reordered Have and unchanged sentinel17.

The separate [conversion effect positive](witnesses/used-scope-20261020/receiving-value147-convert_effect.lm2)
provides the receiver named by primitive.convert's char-to-int row. Its
counter increments once per conversion. Initialization and assignment must
produce saved65 and counter2. Eight complete uninstrumented runs pass these
unchanged assertions. They reuse the exact04 unit objects/executables; no
fresh compilation is claimed for replay05.

Independent07 starts from byte-identical04 L1/C and adds only prints on actual
typed-body entry. All eight diagnostic runs pass. The converter's typed body
is entered twice in every mode; work's typed body once in native mode and
zero times in forced mode. The runtime's independent walker print observes
0/1 and1/2 bodies. Thus work genuinely interprets the receiving/conversion
path, but the conversion receiver itself remains native. This is not proof
of a fully interpreted converter. The initial04 expectation of three walked
bodies was incorrect; its partial result is preserved, not counted as such
proof. Terminal verification removes exactly the two diagnostic insertions
in memory and rechecks each resulting C against04.

The [effect-drop control](witnesses/used-scope-20261020/receiving-value147-convert_effect_drop.lm2)
removes only that receiver's counter increment. Saved65 and counter2 remain
the assertions. All eight control runs actually exit1 after successful L2,
strict-O2 compilation and linking; they are RED, not GREEN or CHECK refusals.
This proves the value test detects omission of the receiver's effect.

The explicit-import char conversion also translates successfully. Without
the required implementation, the same input correctly refuses with a missing
receiver diagnostic. Graph, raw-pointer and text values given to a numeric
receiver remain located CHECK refusals. Probe03 omitted that implementation;
probe04 records both the provided-receiver positive and missing-receiver
negative, rather than weakening the source rule.

## Regression boundaries and exact inputs

Fresh metadata336, common-record420 and indexed-dispatch200 checks all pass,
with two legitimate Array binding mismatch refusals preserved. There are85
fresh L2 translations and152 verified selected input pins. All generated L1
is byte-identical to published143/144/145/146. No fresh85-unit C/runtime gate
is claimed; inherited full143 remains162 GREEN plus the same8copyRED.

Compiler source:
`7EDE3F5DE04C781E66D89102DFB29AC4B11751B1C6CF37E698A1781B4ADBD244`.
Generated frontend C:
`9E0ACA4AD716CD71884BFF028FD9BDCB3E915E63F5EA8045F87323824920B7B5`.
Frontend EXE:
`EA8BE810BF6833AD59E86228A5A2934128E15672FC0820FD95177F01AD4DF6E1`.
Application remains `CF6648189ECA39C4E348A167AB4015C462DDF476C40144DCE5FEEB98AE4FC08A`;
production runtime C remains `471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9`.

The41 closed executed EXE files are kept in nine tar.xz containers. Each member
is streamed back and SHA-verified before removing a redundant raw copy, and
again during terminal verification. Recovery uses
`tar.exe -xJf archive -C destination`. Source, generated C, objects and logs
remain; no older pinned artifact, protected log or unrelated WIP is removed.
Byte-preserving compression of selected parent artifacts adds disk headroom
without changing any assertion or input digest.

The [evidence record](witnesses/used-scope-20261020/receiving-value147-evidence.json)
binds the exact replay, terminal receipt and reuse boundaries. Receipt
`build/codex_receive147_terminal_03.inputs.sha256` contains14620 pins,
SHA `03156CA74A6F1D1D4F448AF115BB13AF7153D577D2DBC796440D0EFCA572F2E5`.
All14093 parent146 inputs and all41 archived executable members were rehashed.
SDK/preprocessor
closure is not certified; inherited quoted decNumber.h remains unresolved.

Local Model/Shelf positives remain open. Independent source-context tracing
finds no own/formal Model and no hidden inputs in Shelf's procedure, while
its declaring work selected the constructed Model. No namespace-tag or parent
guess was added to mask this gap. Other legacy node/indexed/type/call consumers,
fully interpreted conversion, capture/lifetime, public-dev, full kernel,
L3/L2 self-build and mail remain OPEN. Goal ACTIVE under the unchanged v3 plan.

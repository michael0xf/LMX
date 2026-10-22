# Current root values use the common resolved type

Native kind checking and retained typing now obtain a bare named value's
type from the common path result. They no longer classify a same-name
namespace Structure as a callable before considering the selected local
value. Both previously failing scoped positives execute successfully,
including the unchanged full Array, implements-map and address checks.
Other path consumers and public-dev integration remain open.

Base main `d4a8be073b4dbd1eaab776493c22638ec3b823d4`. The private compiler
candidate is `build/codex_root_value_146`; final frontend is
`build/codex_value146_build_01`. Unchanged headers and L1 working-directory
inputs are explicitly reused from frozen144. The
[compiler patch](witnesses/used-scope-20261020/root-value146-u0.patch)
replays over [Private145](contract-source-20261021.md) using
`git apply -p0 --unidiff-zero --directory=<snapshot> <patch>`.
No application/runtime ABI, graph field, opcode or compiler record is added.

## One selected root and a closed value type

The common zero-step walk already selected own, formal, machine, slot or
namespace coordinates. It now closes the value type from those coordinates
in the same result. A whole Array retains its selected semantic contract;
`l2_path_rec_leaf_ft` projects that contract to the descriptor ABI without
reinterpreting its type spelling or inferring a model from candidate.parent.

`l2_root_value_type` adapts an actual one-field identifier through the same
`l2_path_resolve_value` entry as other complete values. Native and retained
span typing project the completed result. A failed named root does not retry
namespace/callable classification. Other expression shapes retain their
existing routes; this is not a claim that every consumer is migrated.

The independent [type fixture](witnesses/used-scope-20261020/root-value146-type-test.c)
checks eight exact formal types: int, char, size_t, unsigned int, unsigned
long, int pointer, const-qualified int pointer and graph reference. Actual
GCC function-entry instrumentation counts common root selection, rather
than incrementing a counter in a replacement resolver. Each consumer enters
it once. Mutating the formal type table after resolution does not alter the
stored verdict. The same72 assertions yield42 failures with old145 and zero
with146, including valid int type code0. These are compiler metadata tests,
not72 executions of source programs.

## Actual native and walker values

The [minimal scoped value](witnesses/used-scope-20261020/contract-source145-scope_value_control_01.lm2)
and [full scoped positive](witnesses/used-scope-20261020/contract-source145-scope_shadow_02.lm2)
are unchanged. Old145 refuses both at the numeric comparison with local
`Need`. New146 translates both and performs16 actual runs: two programs,
native/forced methods, native/walked roots, production/observed runtime.
All exit0 with entry7 and13/17 driver checks.

The full program checks local Need91 while an Array element carries the
global Need contract. It writes through reordered Have storage, takes the
mapped x address, writes43 through that address and reads back43 through the
Array, original Have and captured address. Sentinel17 remains unchanged.
No assertion was removed or turned into an expected refusal.

All four unit objects are freshly strict-O2 compiled; all eight executables
are freshly linked. The exact production143 runtime object and the existing
observed runtime object are reused. The observer changes only the print at
actual `lmx_walk_load_body` entry. Counts are0/1 for native/forced methods
under native root and1/2 under walked root, proving execution of the intended
forced body. Total native bindings or m0 are not used as walker evidence.

Fresh unchanged checks pass: metadata336, common machine-step record420 and
indexed dispatch200. Two legitimate Array binding mismatches still refuse;
a newly declared Array under a numeric type-name shadow also still refuses.
There are85 fresh L2 translations of the prior matrix, all generated L1
byte-identical to published143/144/145, with152 selected input pins verified.
Those85 units were not C-compiled or executed again; the inherited full143
runtime result remains162 GREEN plus the same8copyRED.

## Exact artifacts and remaining work

Compiler source SHA256 is
`B1705F9D7FFCEB94F451D7E0E6C0AA96EB59EB6704D7715AE0489A585DBC2FA7`;
generated C is
`B840F5A2AEB06841D0E2820F108A49A5C3F90659D21C1D6E8F85717067564C47`;
frontend EXE is
`33475E9AB3EB859880D7AA26FAE9CD69A52A4E4D1695AC3CD4A1EE85523EF8E8`.
Application remains `CF6648189ECA39C4E348A167AB4015C462DDF476C40144DCE5FEEB98AE4FC08A`;
production runtime C remains `471F364A15F60AE25B56E31D06EFB24D1560DAF198CA401B8C617B30B09375D9`.

The23 closed executed EXE files are recoverable from four verified tar.xz
containers:13 metadata profiles, two comparative root fixtures and eight
program executables. Every member was streamed back and SHA-verified before
removing its redundant raw copy. Sources, C, objects and logs remain. Older
pinned artifacts, the protected log and unrelated WIP were not removed.
Recovery uses `tar.exe -xJf archive -C destination`. Byte-preserving
compression of selected frozen source/text files and GCC `-pipe` reduced
temporary disk demand without changing an oracle.

The [evidence record](witnesses/used-scope-20261020/root-value146-evidence.json)
binds the terminal receipt, exact replay, results and reuse boundaries.
SDK/preprocessor closure is not certified; inherited quoted `decNumber.h`
remains unresolved in that closure inventory.

The local Model/Shelf Array positives from145 remain open. Other legacy
type, address, callable and C-call consumers still require migration/audit;
neither this helper nor the passing matrix proves them dead. Public-dev,
full kernel, capture/lifetime, L3/L2 self-build and mail remain OPEN under
the unchanged v3 goal. Goal ACTIVE.

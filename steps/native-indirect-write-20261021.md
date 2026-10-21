# Source indirect write — baseline133, 2026-10-21

OPEN after main6742b7a2/private132. This is a measured next dependency,
not an implementation or a request to stop the full goal. Private132 source,
headers,compiler and runtime remain unchanged. No133 engine edit yet.

## Actual same-source difference

build/codex_indirect133_baseline_02,session10692,is terminal0 as a
distinguishing-baseline recipe. It freshly translates and strictly compiles
both source profiles against132. Normal native:48 checks,24 assertion FAIL,
test exit1. Forced --walk-methods:the SAME48 checks,0 failures,test exit0.
The selected native flag is asserted for both added methods,not inferred
from a filename or translation success. Calls use the common generic call
entry;this baseline does not yet add a surrounding walked CALL operation.

The two pure methods write through the incoming pointer or its working
alias,then read through the original pointer. D/E is selected at runtime;
the raw candidate address is unchanged while its current namespace changes.
An actual owned void* arena cell and an explicitly bound live Value.ref
void* object are tested. The generated void** parameter addresses an actual
void* object:there is no Lmx**/void** pun or fake native deep-pointer proof.
No source effect or oracle was removed to obtain the existing walker GREEN.

Native writes the correct physical pointer but fails to replace its CURRENT
Model/reference sheet. Three assertions fail in each of8 cases:return
context,fresh independent place-load context,and real reordered7/9 reads
after receiving that fresh load. Incoming Value records remain unchanged.
This is not merely a missing return pair;repairing the returned record alone
would leave the persisted-cell and real-value assertions RED.

Recipe01 incorrectly required RED from both backends. Its forced-walker
executable actually passed48/0 and exited0;the wrapper then rejected that
success. Recipe02 changes only this harness expectation and output directory,
not LM2/C fixtures or any value assertion. The failed wrapper is retained.

Published inputs are
[source](witnesses/used-scope-20261020/indirect-write133-probe.lm2) and
[C fixture](witnesses/used-scope-20261020/indirect-write133-test.c).
They are byte-identical to the actual build inputs. Root66 has the two
added source methods at63/64 and final return65.

SHA256:

- source:29E122EF2585F8BBAC1732DC06923749407117AC6A019655033C4B495C5831D6
- C fixture:283B57B54F7F23145100AC9A3370703AECEDE5AE8040537440CA1F3253E38C3A
- native unit C:D8E1DCFD80B7E8151CB1C194505476F515B7294BEA710B53CB4E60EBE08D1E02
- native test EXE:856735830BEBE27527206305C3255D1F2FD0F8317AC544E228860FD7D04ECF28
- forced-walker unit C:6DDF49D92688BA7B66DA133A3AED510996CAC32224D0FE9FC4AA64B5EF9F27BB
- forced-walker test EXE:ED2965F8014C5EB359F6F6136226B3E3C4E552B4E432FF793D9BE7A60D475ABF

Compiler F0420ADB2496F09F881DD9B5DBBE6D4340951A2CD85F10BE615855DDA5C4B54D
and matching132 runtime113318D4... are the published132 build,not a new
generation. Source-linked dependencies remain those pinned by132.

The bounded receipt build/codex_indirect133_baseline_02.inputs.sha256 has
326 pins,SHA11370C39D4ED624EB33FC6ED4F2E91421AF7DACA3F8147B670209AD6EC66CAC0.
It independently rechecks288 selected current132 dependencies (all snapshot
sources/headers plus named compiler/runtime/tool/input dependencies) and
pins the new recipes,inputs,artifacts and observations. It verifies the
parent132 receipt's chain digest;it does NOT claim to rehash every31074
historical132 input again. Both baseline workers are terminal;no GCC live.

## Root cause and common-route work

The132 compiler's l2_prefix_deref (line18043) still manually selects a
binding and cuts a raw suffix. Its native assignment consumer (line63477)
captures a C lvalue,then emits a plain C assignment;the accompanying
CURRENT state is lost. The two actual emitted writes are at native unit C
7942 and8025. Re-reading through the corrected132 read producer cannot
recover a state that the store never published.

Other inspected native write consumers have the same transport gap:
reference-field writes call raw lmx_pointer_store_in around63158;raw indexed
writes take their independent emitter near63522. These must not remain
separate semantics behind a helper added only for this witness. Direct
own/formal working stores already carry explicit context,but physical
publication and ordinary field/index/indirect places need the same complete
resolved Value/Place contract. Actual C storage access must remain exact.

The retained L2HeadExpression already parses a whole head with P0 once and
caches its prepared adapter verdict,including no-path. Reuse that retained
tree/adapter for prefix locations;do not cut the root/suffix again or build
a second graph. CHECK,COUNT,EMIT,native and walker must consume the same
resolved source/place facts,including each pointer/index contract and map.
The present L2Path step inventory covers fields/indices but does not yet
express every explicit pointer-cell step;do not label a current-state helper
as proof that this missing unification is complete.

The runtime's common lmx_walk_value_store already publishes actual owned
pool-cell context and explicit live owners:its existing walker GREEN is
evidence to reuse the value/place operation,not permission to add a native
read guard. For arbitrary native C pointer objects,reuse the exact physical
accessor contract already used by typed Array/pool cells. Never pass an
unrelated T** to a void** accessor. Avoid a second write or a later guessed
Model;freeze the complete giving value and target place before effects,
store once,and publish CURRENT state only after that store succeeds.

Then repeat the SAME48 and deep mixed field/index/reference read/write/
address cases in both engines,including mapped implements layouts,raw
same-address clearing,null,input/output aliasing and once-only effects.
Do not weaken positive value tests,leave a fallback parser,or infer a
namespace from candidate layout/history. Full clean-kernel,self-build and
mail remain OPEN;the original goal is ACTIVE and work continues.

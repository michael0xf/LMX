# Native indirect CURRENT context — private132, 2026-10-21

Dependency after slice131/main8f99b320. The baseline below is preserved.
Private implementation132 is build/codex_value_deref_132, with fresh
compiler/runtime build/codex_deref132_build_01. Public dev remains unchanged.
The broader common-path obligation is still OPEN; this is a current-state
transport repair, not proof that every path consumer has been unified.

## Actual reproduction

build/codex_deref132_baseline_01 is terminal0 as a RED-baseline recipe.
Its test executable exits1 by assertions:4747 checks,60 failures.
The inherited4555 remain0 failures. The recipe's inherited console word
GREEN is a stale label;the recorded assertion string and process exit are
the evidence,not that label.

The three additional source methods return a pointer read by explicit
indirection,pass it as an ordinary echoFormal actual,or save it in a working
pointer before clearing the original formal. Each executes one observable
mark8. Cases use direct native dispatch and real walked CALL into the native
body,with D/E current views and two actual C99-compatible storage forms:

- an owned canonical void * arena cell whose SAME raw value was changed
  from the prior current context to the selected current context;
- a live LmxWalkValue.ref void * object addressed explicitly,with the
  input Value carrying that resolved owner. No containing-record arithmetic.

The declared native parameter is a genuine void ** pointing to an actual
void * object. No Lmx ** is passed as void **,and no Model is guessed from
the referent layout or from past admissions.

Payloads and once-only effects succeed,but returned CURRENT Model/sheet
is absent. Separate assertions check the caller's unchanged records,
receiving with the reordered map,real7/9,write41,taken field address and
observed43 with the neighbor intact. Some absent-context receptions happen
to produce the expected layout;that coincidence is not a source-context
proof. The explicit CURRENT-state assertions stay required.

Exact SHA256 inputs:

- build/codex_deref132_probe.lm2:
  FF6A6CB6375E3366A0AD15638A1B00AF4E278A0AC0B201F9078142035963B843
- build/codex_deref132_test_01.c:
  5B24D9788BAF682E29F60592002B19F73173B72ACBA8BCBC31B008A7A4A4616E
- generated unit.c:
  8BB7657F9BB74569456A96899D850F988A1368C5FB74412C60EF8171B59AB4B4
- test.exe:
  7D8AB2D1F378B7CD2AED2DF9E5DB843EE1DF03AA8362B23E76768750BE2CAEDC

Recipe:build/codex_deref132_baseline_01.ps1;session79703 terminal0.
The C fixture needs PLACE130_SOURCE selecting that directory's unit.c.
Root64 adds source methods at60/61/62;prior source indices are unchanged.

## Traced producer gap and next implementation constraint

In the baseline131b compiler,l2_prep_context calls l2_prefix_deref for a
compact prefix word and returns without a value-context result.
l2_prefix_deref still emits prefix text from a separately selected root;
its remaining suffix route manually cuts the root from the path.
The spaced-prefix route,l2_emit_indirect_span,also materializes only a
typed raw pointer via l2_eval_fields,not its explicit current context.
These are inspected gaps,not yet a complete inventory of every consumer.

The actual valid compact source in this witness is split by P0 into the
prefix operator and operand and reaches l2_emit_indirect_span. It does NOT
exercise the legacy compact-word fallback merely because its source has
no space. That distinction was checked in the generated L1/C.

Do NOT add a Model guess/read guard or a case-specific context repair inside
one legacy emitter. Normalize the complete operand into the shared resolved
value/place/path mechanism,retain the exact source pointer contract and
per-step current owner/map,and have native and walker project that result.
A proven owned cell can supply its actual stored state through the131 pool
operation;an explicitly bound live activation owner supplies its own state.
Neither is permission to infer a Model from the physical candidate.

Preserve exact C99 storage operations and snapshot operand/address once
before later effects. Account for compact/spaced/grouped forms,field/index
transitions,all receiving uses and writes,address lifetime and copying;
do not call a fix to these three methods complete path unification.
Re-run the SAME4747 or expanded unchanged oracles,negative loss controls
and the affected native/forced-walker matrices. Full112/copy/self-build/mail
remain open as recorded in current.md.

## Implemented current-state step

The existing native indirect-span emitter evaluates the complete operand
through l2_eval_fields_context once. It freezes the pointer payload and its
complete CURRENT context,then projects one exactly typed C pointer object
per written indirection. A relative pointer-depth declarator changes only
C representation;it does not search for another namespace or infer Model.
Only a whole indirect expression exports its resulting context;one operand
of a compound expression cannot donate metadata for the whole expression.
A final scalar/foreign by-value leaf retains its prior C rvalue behavior.

Both native pointer steps and walker DEREF/place selection call the SAME
backend-neutral lmx_value_address_context:an explicitly carried live owner
wins;otherwise the exact owned typed cell supplies its actual current state
through the existing131 arena-pool operation. No layout/parent/prototype,
previous admission,candidate registry,name lookup,opcode or graph field is
introduced. An absent state stays absent;present-null stays present.
There is no Value/Work/Place/chunk layout or uniform9/body ABI change132.
The new shared function/header still requires fresh runtime and unit builds.

## Actual values and distinguishing controls

The SAME4747 checks now pass,including the inherited4555 unchanged assertions.
The three additional native bodies are called both directly and through a
real walked CALL. Source effect mark8 occurs exactly once;working/formal
rebinding does not mutate caller Values. Both actual void* arena cells and
explicit live Value.ref owners preserve the current D/E namespace.

The additional pure source fixture has compact,spaced and grouped forms at
1,5,17 written dereferences:actual C pointer depths2,6,18. Every stored cell
is a genuine exact C pointer object with matching sizeof/read/write callback;
there is no T** to void** aliasing. Source-graph DEREF witnesses supply the
type contracts. Normal and --walk-methods profiles each pass2310 checks.
They assert the actually selected native flag and per-cell callback counts:
native reads the exact C objects directly;walker calls every read once.
Both direct generic calls and actual walked CALLs are exercised in each
profile. SAME-address D↔E replacement,raw clearing,explicit null,input
immutability and real reordered7/9 results are checked.

After receiving the returned Value,the common runtime map reads7/9,writes41,
takes the actual mapped field address and observes43 through it,with the
neighbor intact. These later PUT/ADDRESS operations are runtime/walker
operations,NOT generated native field-write/address bodies. This evidence
does not close the author's separate demand for native deep mixed-path
writes and address-taking. No translation-only success is counted as a
value observation.

Controls keep exactly the same fixture oracles and compatible layout:

| Control | Actual checks | Assertion failures |
| --- | --- | --- |
| Old131 native deep source | 2310 | 126 |
| Old131 forced walker,which already supported the pool state | 2310 | 0 |
| Erase72 generated native step context copies | 2310 | 126 |
| Same erased native copies with forced walker | 2310 | 0 |
| Remove explicit-owner selection from common helper | 4747 | 707 |
| Remove typed-pool state from common helper | 4747 | 702 |
| Same pool-state loss,native deep source | 2310 | 126 |
| Same pool-state loss,forced walker deep source | 2310 | 126 |

Every RED exits1 by assertions after strict compile/link,not setup failure
or crash. Recipes/results:build/codex_deref132_controls_01,session22253
terminal0. The initial deep fixture used the nonexistent enum spelling
LMX_WALK_OP_RETURN;its compile failure is retained in deep_01,not a valid
negative control. Correct deep_test_02 uses the existing LMX_WALK_OP_RET.

Fresh values_01 rebuilds85 units with L2/L1/C/GCC-O2-strict-aliasing/link,
fresh132 normal runtime and170 actual executions:162 prior GREEN plus the
same8 copy RED. All345 unchanged pins,native-binding counts,root modes and
exit observations are preserved. Worker15772 completed with summary.json;
its original interactive tool result was truncated,so no invented terminal
session ID is reported.

Published clean witnesses are indirect-value132-{probe.lm2,test.c,deep.lm2,
deep-test.c};the C fixture explicitly requires its selected generated unit.
The four-source131b→132 patch is indirect-value132-u0.patch and passes
git apply --unidiff-zero --check -p0 against the exact131b stage.

Important SHA256 values:

- compiler source: 288D08999A9CD646ACB80EE8C45C8E9A746DAF8FFD0F9D5675D7E2FF95369B7C
- walker source: 763A82B788D266ECB20C7E2EED0CB3DD66CE172222C94B16C664B84C4003C3A4
- value-owned source: 3CFBD7CF1B18268F273693FE32E06E5F44068DB3A04439E4F688395B82B0E9EA
- value-owned header source: 37AF362E35C906CC67D5314C5BAF1A369F20B5CF04CE7D39846B7C3C552FEEB0
- frontend C: F2806CE4D3203744FF2326C76402E87FF91DD1559E7B46354589053BB53C2C92
- compiler EXE: F0420ADB2496F09F881DD9B5DBBE6D4340951A2CD85F10BE615855DDA5C4B54D
- runtime C: FAE064B445311B9875F4D6A63A7A6D61E1109528F9AA96F96D2FF50ECD97C4EB
- renamed runtime object: 113318D4109B344394D33970A8C43EEEAE0169F0220F3A4C253191A70E7B8715

Final verification01/session31318 is terminal0. The published clean source
generates BYTE-IDENTICAL C for the4747 profile and both2310 profiles;all
freshly compile/link/run GREEN. Newly translated standalone kernel checks
62/57+20/789/54/48,unchanged hidden408/formal412/actual311/result111 and
thirteen source-linked336 checks pass. Four foreign13/17 actual runs use
the fresh132 matrix runtime;the historical foreign recipe's old130 link was
fixed BEFORE these executions. Foreign bodies remain native-only.

Final receipt build/codex_deref132_terminal_01.inputs.sha256 has31074 pins,
SHA256 B9DAA3ABF77AAF5049088F5898425466CDAFFBE2DA8DCD0CB04CE98F691D3D52.
Session8827 terminal0 independently rechecks every29646 upstream131 pin,
plus final sources,headers,objects,recipes,inputs and actual observations.
All132 GCC/check workers are terminal. Both documentation generators and
tools/check_docs.py pass;the staged index contains7082 checked files.
git diff --cached --check passes. These are private regression snapshots,
not self-built generations or clean-kernel/full-language gate acceptance.

## Still open

The old l2_prefix_deref root/suffix parser and its consumers remain.
l2_indirect_span still computes a source type and releases a resolved path
that downstream evaluation may resolve again. Native field/index producers,
indirect writes,formal/capture/default persistence,copy relocation and
address escape/lifetime are not closed. The shared owner helper is NOT a
second path resolver,and adding it is NOT proof that the old routes were
removed. Continue from the common retained value/place/path record and
eliminate those repeated searches,not isolated guards or Model guesses.
Full1121011/3754,the8 copy RED,clean-kernel closure,self-build and mail remain
OPEN;the original full goal remains ACTIVE.

#!/usr/bin/env python3
"""Compare implementations, without importing them into foreign usage clients.

Common LMX dependencies are linked to their complete canonical source instead of
pasting the same hundreds of lines into every comparison. Both boundary counts
(entry roots and complete reachable LMX source) remain explicit.
"""
from pathlib import Path
import json,re,hashlib
ROOT=Path(__file__).resolve().parents[2];EX=ROOT/'examples';LIB=ROOT/'LMX_Fn_Receivers'
def metric(s):
 s=s.strip()+'\n';return {'characters':sum(not c.isspace() for c in s),'nonblank_lines':sum(bool(x.strip()) for x in s.splitlines()),'utf8_bytes':len(s.encode()),'sha256':hashlib.sha256(s.encode()).hexdigest()}
def definitions():
 out={};loc={}
 for p in sorted((LIB/'src').glob('*.lmx')):
  if p.name in ['functions_specialized.lmx','wrappers.lmx','kernel_contracts.lmx','public.lmx']:continue
  for block in re.split(r'\n[ \t]*\n',p.read_text()):
   lines=block.splitlines()
   while lines and (not lines[0].strip() or lines[0].lstrip().startswith('#')):lines.pop(0)
   if not lines:continue
   m=re.match(r'^(?:independent: )?([A-Za-z_][\w]*):\s*$',lines[0])
   if m:out[m[1]]='\n'.join(lines).rstrip()+'\n';loc[m[1]]=p.relative_to(ROOT).as_posix()
 return out,loc
def closure(start,defs):
 seen=set();result=[]
 def visit(n):
  if n in seen:return
  if n not in defs:raise ValueError('Missing source root '+n)
  seen.add(n)
  for dep in sorted(set(re.findall(r'\b(?:Fx|Rx)[A-Za-z_0-9]+\b',defs[n])) if n!='FxThrows' else []):
   if dep!=n and dep in defs:visit(dep)
  result.append(n)
 for n in start:visit(n)
 return result
def lazy_review(defs):
 engine=defs['FxLazyEngine']
 guarded=engine.index('finally:') < engine.index('state\\status := 1')
 ordering=('The cleanup guard is registered before setting Busy. Cache-hit and reentrant-busy checks occur before this guard; therefore an inner recursive attempt cannot reset the outer running computation.' if guarded else 'The source already has both cycle detection and failure reset. Its guard is currently registered after setting Busy; the reviewed hardening moves guard registration before that write, without changing the public contract. This ordering should be applied before native acceptance.')
 return r"""
## Completeness review: lazy and once

The compared reusable API is first-success caching within one owner. LMX `lazy`
restricts the target to zero inputs; `once` retains the target's complete input
contract. Haskell `lazyIO` uses the zero-input IO action, and `onceIO` accepts any
input product/record/vector type. Later successful-cache calls may pass different
inputs but return the first successful result; this is not per-key memoization.

| Event | LMX source behavior | Haskell source behavior |
| --- | --- | --- |
| Construct wrapper | Fresh state 0; target not executed | Fresh Cold cell; action not executed |
| First force/call | Set state 1; enter the already prepared target frame once | Set Busy; run the supplied action once |
| Successful result | Store the actual value record; publish state 2 | Store Ready value after evaluating its outer form |
| Cache hit | Return the stored record; do not enter the target | Return the stored value; do not run the action |
| Reentrant force | State 1 throws FxLazyCycle before installing an inner reset guard | Busy throws LazyCycle before installing an inner reset handler |
| Target failure | finally resets to state 0 while completed is 0; the failure continues outward | onException resets Cold and rethrows the same exception |
| Retry after failure | A later call can execute again, with its own ordinary actuals | A later call can execute again, with its own input |
| Foreign owner | Message ownership prevents sharing the mutable state across arenas; use post to its owner | Explicit ThreadId check throws LazyForeignOwner; the cell is unchanged |

""" + ordering + r"""

LMX's finite engine exits are `FxCallFailure FxKernelFailure FxLazyCycle FxTypeToken`.
`FxOnce` combines the target's finite exits with FxLazyCycle; `FxWrap` removes the
internal call envelope and uses the declared original name/payload on the public
callable path. The reset is a finally action, not a wildcard catch that consumes
unknown errors. Implicit failures retain normal Message behavior.

The ordinary call preparation policy still applies on cache hits; caching skips
the target body, not all caller expression evaluation or receiving admission.
Haskell similarly retains its ordinary argument/effect sequencing. Neither
implementation promises exactly-once external effects when an earlier attempt
performed effects and then failed.

The interruption mechanisms are different. Haskell masks cache bookkeeping and
restores the caller's masking state around the action. LMX uses one Message owner
lane and registered cleanup on ordinary unwinding; it has no newly invented
Haskell-style asynchronous exception injection or mask operator. Existing `post`
provides asynchronous invocation, not a shared-memory cache or forced cancellation.
Abrupt process termination is outside both successful-cleanup contracts.

Haskell evaluate forces only the outer result form (WHNF), not all referenced data;
LMX retains the returned typed record, including void and references, without
recursively forcing graph contents. [GHC's specified evaluate/mask/onException
contracts](https://downloads.haskell.org/ghc/9.6.7.20250131/docs/libraries/base-4.18.3.0/Control-Exception.html)
explain the foreign exception boundary.

[Prepared completeness cases](../validation/lazy_completeness_20261123.json)
include retry, recursive forcing, void, mixed input, owner rejection and the
separate interruption models. All runtime statuses remain NOT_RUN.
"""

CONFIG=[
 ('h01_apply_comparision.md','Apply','H01',['apply'],['FxApply'],'IntApply.hs','Ordinary Haskell application, with no custom apply import.','The full typed actual vector uses real record types; failures keep their names and payload inside FxCallFailure. Haskell uses native curried function application; its generic a/b implementation is not a reflection API.'),
 ('h03_capture_comparision.md','Partial application','H03',['partial'],['FxPartial'],'Partial.hs','Native Haskell application: makeAdder n = (+) n.','LMX captures any finite prefix, preserving value/reference rules, remaining input policies and the original result. The Haskell comparison uses a heterogeneous typed argument representation; no Int or binary arity cap is intended.'),
 ('h06_pipe_comparision.md','Composition','H06',['pipe','compose'],['FxPipe','FxCompose'],'IntPipe.hs','Native (.) for composition; Data.List.foldl\' / Control.Monad.foldM for stage lists.','Construction does not execute stages. The stored callable preserves the first input policy and receives the exact final result. Pure and effectful Haskell variants are separate contracts; all effectful stages execute in order.'),
 ('h07_evaluation_modes_comparision.md','Lazy and evaluation modes','H07',['lazy','once'],['FxLazyState','FxLazyEngine','FxOnce','FxLazy'],'Lazy.hs','Native let / do and Control.Monad.replicateM.','lazy accepts a zero-input thunk; partial may bind all arguments first. once retains its general input contract. The first successful result is cached; failure permits retry, recursive forcing fails. LMX state belongs to one Message, Haskell Lazy.hs enforces one owning ThreadId. This does not replace the separate raw-occurrence test.'),
 ('h09_iterator_comparision.md','Iteration until Stop','H09',['iterateUntilStop'],['FxIterateUntilStop'],'StepIterator.hs','Control.Monad.Loops.whileJust_ from the actual monad-loops package.','The accepted declaration remains DATA until execution. Its established item and caller total stay live in the receiving activation. Only source Stop terminates; body Stop and other failures propagate in FxCallFailure. The Haskell loop passes values explicitly. AE01 is a concrete pending kernel integration boundary; see CORE_EXAMPLE_HELPERS.md.'),
 ('v02_character_range_comparision.md','Inclusive range','V02',['between'],['FxBetween'],'CharacterRange.hs','Data.Ix.inRange from base.','Two inclusive bounds, original ordered types, no int conversion, reversed interval false. The LMX operand checks exactly two right values and uses comparison priority. Haskell fixes two bounds by a pair and requires Ord. Neither helper is a regular-expression matcher.')]
def main():
 defs,loc=definitions();rows=[]
 for filename,title,ident,public,entries,hsfile,usage,contract in CONFIG:
  roots=closure(entries,defs);body='\n\n'.join(defs[x].rstrip() for x in entries)+'\n';allcode='\n\n'.join(defs[x].rstrip() for x in roots)+'\n';hs=(EX/'libraries/haskell'/hsfile).read_text()
  paths=sorted({loc[n] for n in roots});links='\n'.join('- ['+Path(p).name+'](../../'+p+')' for p in paths)
  extra=''
  if ident=='H03':
   extra='\n## Native curried implementation approach\n\nThe earlier capture helper uses the host curried function representation. Its result may itself be a function, so the type variables do not impose a numerical or final-result specialization. It is a different representation from the explicit heterogeneous vector above. Clients use native application directly.\n\n```haskell\n'+(EX/'libraries/haskell/CurryInt.hs').read_text().rstrip()+'\n```\n'
  if ident=='H07':
   extra='\n## Separate prepared/raw test fixture\n\nThese test operands deliberately use numeric addition; they test evaluation count, not a second lazy library.\n\n```lmx\n'+(EX/'libraries/lmx/EvaluationModes.lm3').read_text().rstrip()+'\n```\n\n```haskell\n'+(EX/'libraries/haskell/EvaluationModes.hs').read_text().rstrip()+'\n```\n'
  if ident=='H07':extra+=lazy_review(defs)
  text=f'''# {title}: usage and implementation are separate

Edition: 2026-11-23. Client: [{ident}](../lmx/{ident}.lm3), [scenario](../../LMX_examples_and_analogies.ru.md#{ident.lower()}).

## Contract

{contract}

LMX public names: {', '.join('`'+p+'`' for p in public)}. These names belong to the proposed core; no user library import is needed.

**Foreign usage client:** {usage} The implementation below is for comparison only. It is not on the client's module search path, and [Analogies.hs](../haskell/Analogies.hs) does not import it.

## LMX implementation

Complete entry definitions, with no omitted branch:

```lmx
{body.rstrip()}
```

Complete canonical source files for the entry and its LMX dependencies:

{links}

The reachable roots are: {', '.join('`'+n+'`' for n in roots)}.
These shared definitions are kept once in the canonical source package rather than copied into every comparison. Their full bodies remain available by the links above and in [LMX_Receivers.lmx](../../LMX_Fn_Receivers/LMX_Receivers.lmx).

The kernel-provider boundary is explicit in [KERNEL_REQUIREMENTS.md](../../LMX_Fn_Receivers/KERNEL_REQUIREMENTS.md). The declaration/body bridge and ownership contract are detailed in [CORE_EXAMPLE_HELPERS.md](../../LMX_Fn_Receivers/CORE_EXAMPLE_HELPERS.md). A linked integration requirement is not a claim that its native implementation has already run.

## Haskell comparison implementation

[Exact standalone module](../libraries/haskell/{hsfile}):

```haskell
{hs.rstrip()}
```
{extra}
## Size boundaries

| Source boundary | Nonwhitespace characters | Nonblank lines | UTF-8 bytes |
| --- | ---: | ---: | ---: |
| LMX entry definitions shown above | {metric(body)['characters']} | {metric(body)['nonblank_lines']} | {metric(body)['utf8_bytes']} |
| All reachable LMX source roots, counted once | {metric(allcode)['characters']} | {metric(allcode)['nonblank_lines']} | {metric(allcode)['utf8_bytes']} |
| Complete Haskell comparison module | {metric(hs)['characters']} | {metric(hs)['nonblank_lines']} | {metric(hs)['utf8_bytes']} |

These are implementation sizes, separate from client sizes. They do not compare runtime internals or claim the same type-system representation. A language's built-in function machinery need not be reproduced as a second interpreter just to match LMX's graph representation.

## Ownership and async scope

The reusable helpers here are synchronous computations on their owner. To run an LMX owner operation asynchronously, use existing Message `post`; it already provides delivery and reply handling, including the documented HTTP transport. No cross-Message mutable cache, hidden global scheduler, cancellation guarantee or extra worker pool is claimed. In the Haskell comparison Lazy explicitly checks its owning thread and masks the bookkeeping around an interruptible action.

**Verification:** reproducible source/metric checks only; neither LMX runtime nor GHC execution is claimed. The client dependency list is [lmx-examples.cabal](../haskell/lmx-examples.cabal).
'''
  (EX/'library_comparisons'/filename).write_text(text)
  rows.append({'file':'library_comparisons/'+filename,'entry':entries[0],'public':public[0],'public_names':public,'roots':roots,'source_files':paths,'lmx_entry':metric(body),'lmx':metric(allcode),'haskell':metric(hs),'haskell_source':'libraries/haskell/'+hsfile,'comparison_scope':'implementation_only','imported_by_clients':False,'core_versions':1,'kernel_provider_excluded_and_disclosed':True})
 (EX/'validation/receiver_library_counts.json').write_text(json.dumps({'format':'receiver-library-comparisons-v2','status':'publication_consistency_not_execution','date':'2026-11-23','comparisons':rows},ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'comparisons':len(rows),'all_foreign_implementation_only':True}))
if __name__=='__main__':main()

"""Canonical direct API and links. No language execution."""
from pathlib import Path
import json
R=Path(__file__).resolve().parents[1]
rows=[
('types','RxTypes\\types','reflection','source','physical field type codes; []:int by language contract'),
('names','RxNames\\names','reflection_bridges','source','physical canonical names; anonymous entries retain typed absence'),
('signature','RxSignature\\signature','reflection_bridges','operation','ordinary positional signature description'),
('signatureTypes','FxSignatureOperand\\make','fn_operand','left; right','same signature kind: result type token left, all ordered input tokens right'),
('curry','FxLambda\\lambda','generic_functions','operation','arbitrary finite arity, exact stage input type and terminal result'),
('apply','FxApply\\apply','generic_runtime','operation; args','arbitrary actual record vector; result record including explicit void'),
('partial','FxPartial\\partial','generic_functions','operation; prefix','prefix 0..N; exact residual signature, complete prefix yields thunk'),
('uncurry','FxUncurry\\uncurry','generic_functions','operation; contract; failures','explicit full target contract and stage failures, callable result preserved'),
('flip','FxFlip\\flip','generic_functions','operation','swap first two positions of N>=2 with full input types'),
('compose','FxCompose\\compose','generic_combinators','outer; inner','inner arbitrary arity; outer consumes its one result; exact final R'),
('pipe','FxPipe\\pipe','generic_combinators','first; second','compose(second; first), exact callable signature'),
('identity','FxIdentity\\identity','generic_combinators','typeToken','typed T -> T for any valid value type'),
('map','FxMap\\map','collections','items; transform','each record admitted as actual callback type, result record vector'),
('filter','FxFilter\\filter','collections','items; accepts','typed values; ordinary int truth predicate'),
('foldl','FxFold\\fold','collections','items; seed; step','left fold over any accumulator/item/result records'),
('zip','FxZip\\zip','collections','first; second','pairs of typed records, min length'),
('zipWith','FxZipWith\\zipWith','collections','first; second; combine','arbitrary binary callback types, result records'),
('scanl','FxScan\\scan','collections','items; seed; step','seeded scan, n+1 records; accumulator type not hardwired'),
('bind','FxBind\\bind','containers','input; next','Maybe of any typed record; next gets actual payload value'),
('traverse','FxTraverse\\traverse','collections','items; next','Maybe of direct Structure record vector; stop at first absence'),
('memoize','FxMemo\\memo','generic_combinators','operation; sameKey','any arity/R; explicit key-vector equality, Message-local linear cache'),
('fix','FxFix\\fix','generic_combinators','operation','F(self;T0..Tn)->R becomes T0..Tn->R'),
('select','RxSelect\\select','structures','source; indices','physical selection in direct Structure/Array<@>'),
('omit','RxOmit\\omit','structures','source; indices','physical omissions in direct Structure/Array<@>'),
('rename','RxRename\\rename','reflection_bridges','source; indices; labels','one graph copy then canonical field names updated'),
('reorder','RxReorder\\reorder','structures','source; permutation','full checked permutation, any field value types'),
('project','RxProject\\project','structures','source; indices','one shared graph copy of selected fields'),
('defaults','RxDefaults\\defaults','structures','source; fallback','merge(fallback; source), existing presence including uninit wins'),
('diff','RxDiff\\diff','structures','before; after','identity-vector patch, not deep payload equality'),
('patch','RxPatch\\patch','structures','source; change','prevalidated identity-vector patch in fresh container'),
('bindFields','RxBindFields\\bindFields','structures','operation; bindings','DATA defaults through merge; residual input positions not removed'),
('derive','RxDerive\\derive','structures','base; extension','ordinary merge composition'),
('transpose','FxTranspose\\transpose','collections','rows','rectangular Structure of row values; no fixed dimensions'),
('groupBy','FxGroupBy\\groupBy','collections','items; keyOf; sameKey','typed keys and explicit equality, stable group/member order'),
('lazy','FxLazy\\lazy','generic_wrappers','operation','typed nullary thunk, first successful result cached'),
('force','FxForce\\force','generic_wrappers','thunk','nullary call returning typed result record; direct thunk() keeps R'),
('once','FxOnce\\once','generic_wrappers','operation','any arity/R; first success reused, failure permits retry'),
('repeat','FxRepeat\\repeat','generic_wrappers','operation; count; args=()','count calls with arbitrary typed actual vector; result records'),
('runUntil','FxUntil\\runUntil','generic_wrappers','step; finished; initial','record state; step then predicate, no fixed payload type'),
('retryCall','FxRetry\\retryCall','generic_wrappers','operation; attempts; args=()','finite attempts, declared failures retained in FxCallFailure envelope'),
('bracket','FxAround\\around','generic_wrappers','acquire; release; action; arguments=()','any resource/result; finally release; arbitrary extra action inputs'),
('recover','FxRecover\\recover','generic_wrappers','operation; handler','exact signature; handler(name,payload,actualVector) -> R'),
('adapter','FxAdapter\\adapter','generic_combinators','operation; before; after; contract','arbitrary external/internal arity, explicit new exact contract'),
('permute','FxPermute\\permute','generic_combinators','operation; permutation','arbitrary N, reorder interface and actuals together'),
('overload','FxOverload\\overload','generic_combinators','candidates; accepts; contract','explicit pure predicates, exactly one branch, full external signature'),
('predicate','FxPredicate\\predicate','generic_combinators','operation','same arbitrary inputs; normalize ordinary int Boolean output'),
('guard','FxGuard\\guard','generic_combinators','operation; accepts','same exact signature with precondition over all actuals'),
('trace','FxTrace\\trace','generic_wrappers','operation; sink','arbitrary signature, events retain typed args/result/void distinction'),
('contract','FxContract\\contract','generic_combinators','operation; pre; post','same signature, pre(args), post(args,result) or post(args) for void'),
('composeData','RxComposeData\\composeData','structures','code; overlay','merge actual parent DATA with explicit data overlay'),
('record','FxRecordOperands\\record','generic_functions','left; right=()','prepared postfix capture; pointer to typed record, no value dereference'),
('some','FxSome\\some','containers','value','Maybe present with any typed value record, including null'),
('none','FxNone\\none','containers','','Maybe absence, distinct from present empty/null value'),
('ok','FxOk\\ok','containers','value','Result success carrying any typed value record'),
('err','FxErr\\err','containers','reason','Result failure carrying any typed reason record'),
('bindResult','FxBindResult\\bindResult','containers','input; next','typed Result success chain, failure kept'),
('list','FxList\\list','containers','values','bare Structure/Array<@>, shallow copied record vector'),
('flatMap','FxListBind\\flatMap','containers','items; next','List bind, no artificial list.items box'),
('done','FxDone\\done','containers','value','terminal Bounce with result record'),
('more','FxMore\\more','containers','thunk','suspended nullary callable, arbitrary captures via partial'),
('trampoline','FxTrampoline\\trampoline','containers','current','iterate Bounce until done, never execute callable final result'),
]
former={ 'signatureTypes':'fn','curry':'lambda','foldl':'fold','scanl':'scan','memoize':'memo','runUntil':'until','retryCall':'retry','bracket':'around'}
no_bridge={'types','select','omit','reorder','project','defaults','diff','patch','bindFields','derive','composeData','record','some','none','ok','err','list','done'}
catalog=[]
for i,(name,api,src,args,scope) in enumerate(rows,1):
 catalog.append({'id':i,'name':name,'former_name':former.get(name,name) if i<=50 else None,'public_name':name,'api':api,'signature':('R signatureTypes T0 ... TN; explicit fun\\const\\signatureTypes(left := R; right := types)' if name=='signatureTypes' else name+'('+args+')'),'source':'src/'+src+'.lmx','status':'BODY' if name in no_bridge else 'BODY_WITH_BRIDGE','scope':scope,'implementation_layer':'core','availability':'core_integration_task','namespace_root':'fun\\const','lmx_executed':False})
(R/'catalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n')
lines=['# Прямые публичные ресиверы','', 'Редакция 2026-11-22. Все прежние 50 позиций сохранены; 11 контейнерных/служебных операций добавлены.', '', 'Все имена входят в единое ядро и доступны напрямую; собственные DATA и фактический parent каждого метода сохраняются. Клиентский import не требуется.', '`BODY` — LMX-алгоритм; `BODY_WITH_BRIDGE` — LMX-алгоритм с явно указанным интерфейсом ядра. Это не отметка запуска.', '', '| № | Имя | Прежнее имя | Вызов | Исходник | Статус |', '|---|---|---|---|---|---|']
for x in catalog:
 lines.append(f"| {x['id']} | `{x['name']}` | {x['former_name'] or 'новое'} | `{x['signature']}` | [{x['source']}]({x['source']}) | {x['status']} |")
lines+=['','## Области применения','']
for x in catalog:lines.append(f"- **{x['name']}** — {x['scope']}.")
(R/'CATALOG.md').write_text('\n'.join(lines)+'\n')
public=['# ВНУТРЕННИЙ НАБОР ЭКСПОРТОВ ЕДИНОГО ЯДРА: fun.', '# Ядро включает fun/const в штатные корневые объявления; клиенты пишут прямые имена.', '# Один const-блок даёт root-constant экспорты общего namespace; CODE не копируется.', '# signatureTypes — обычный ядерный type-token оператор; declaration head удалён.', '# Name :: DATA — единственная именованная форма того же вида сигнатуры.', 'fun:', '    const:']
for x in catalog:public.append('        @: '+x['name']+' '+x['api'])
(R/'src/public.lmx').write_text('\n'.join(public)+'\n')
print(len(catalog))

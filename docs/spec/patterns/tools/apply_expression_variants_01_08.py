#!/usr/bin/env python3
"""Reproducible bounded review/update of current archive groups 01--08.

Only four equivalent expression simplifications are selected. The complete
previous primary is retained in JSON, Markdown and the standalone source.
Uses the existing canonical counting helpers; full statistics/PDF/XLSX remain
jobs of the existing publication generators and are not run here.
"""
from pathlib import Path
import json,re,hashlib
from recount_patterns import canonical_code,metrics,PROCEDURAL_BEGIN,PROCEDURAL_END

ROOT=Path(__file__).resolve().parents[1]
CHANGES={
7:("        if: income - expense >= 30\n            return: 1\n        return: 0", "        return: income - expense >= 30", "Return the existing comparison's canonical 0/1 result directly; policy, presenter and injection boundary remain complete."),
70:("        if: amount < 0\n            return: 0\n        if: node\\balance < amount\n            return: 0", "        if: amount < 0 || node\\balance < amount\n            return: 0", "Combine two pure rejection guards with ordinary short-circuit OR. A negative amount still skips the balance read; the accepted update remains one Message turn."),
75:("        if: first = again && busy = 0\n            return: 1\n        return: 0", "        return: first = again && busy = 0", "Return the same identity/null observation as canonical Boolean int. Pool operations, resource identity, second-acquisition refusal and all fields are preserved."),
78:("        if: satisfies(item; Marker)\n            return: 1\n        return: 0", "        return: satisfies(item; Marker) != 0", "Normalize the existing satisfies result through comparison rather than a branch. The auditable marker, unmarked value field and structural-versus-nominal limitation remain."),
}
SPECIAL={
13:('pipe','The current receiver is a value-pipeline operand with a measured companion implementation. Core pipe composes two functions and is not a drop-in variadic value pipeline; explicit construction and complete failure declarations do not shorten this client.'),
93:('pipe, foldl','This is the measured implementation, not a client. Replacing its loop by an imported pipeline would move the compared implementation across the counting boundary. Retained.'),
16:('index, select','Repository returns the existing record or a null reference. index returns its own search result and needs a predicate plus conversion to this identity/absence API; it is not a shorter complete substitute.'),
94:('index','The implementation comparison must keep the search algorithm visible. Importing ready search would turn the implementation into a client; the first-duplicate and original-reference observations are retained.'),
17:('forEach, map','Database writes are transaction-ordered effects. A callback adapter and declared-failure policy do not shorten this explicit loop, and map would build an unused result.'),
18:('project, select','Rows must become a domain object with id/cents and no DB reference. Generic positional selection does not by itself supply those named fields or preserve the mapping contract.'),
23:('project, select','The DTO must have exactly named id/cents and exclude token and methods. Blind prefix slicing or merge could leak fields or lose names; explicit index discovery and admission would exceed the small copy/write body.'),
26:('foldl, map','A fold needs an accumulator callback, typed record/result handling and complete failure declarations. The controls currently expose the loop; no shorter equally scoped library-free complete listing was established.'),
28:('memoize','The provided cache, loader-call count and original object identity are observable. A memoize owner plus key/comparator policy is a different or longer construction, not replacement by the word memoize alone.'),
29:('lazy, once','Caching must persist in the Holder across calls and failed attempts. A computed DATA initializer does not automatically publish a persistent thunk; an honest factory/owner and failure declarations make this variant longer.'),
31:('predicate, all','predicate normalizes one callable; it does not compose two predicates with AND. all requires a callable/application adapter and does not directly return this retained unary predicate.'),
95:('predicate, all','Kept the existing explicit copied owner and short-circuit predicate construction. No guessed rewrite of lexical node or copied DATA ownership is selected; alternative ownership spelling is not claimed to prove an old bug.'),
32:('record, satisfies','Value equality compares cents and currency, not type admission or record identity. Existing equals performs exactly the necessary observations.'),
96:('satisfies','The compared implementation includes both immutable value fields and equality. Type compatibility cannot replace value equality, and no field can be removed.'),
12:('foldl','Replay uses an explicitly shown ordered integer accumulation and retains optimistic append behavior. A higher-order reducer adds a callback and errors; silently importing a reduction would change the current control boundary.'),
48:('forEach, map','Each publish must precede markSent, with crash/replay behavior unchanged. A sequence result or batched side-effect helper cannot replace that transactional protocol for free.'),
39:('retryCall','This retry is driven by successful HTTP status values 503, not declared failures; it includes delay values 1,2. retryCall has neither the same status policy nor the delay contract.'),
45:('retryCall','The ambassador must preserve HTTP endpoint/path and retry status 503 twice. Generic exception retry without a status adapter changes behavior and does not shorten the complete client.'),
97:('retryCall','The paired library compares visible status/backoff algorithms. Reusing an exception-only core wrapper does not implement or preserve that policy.'),
49:('memoize, lazy','put writes to the store before invalidation. A ready cache/thunk alone does not express this external-store ordering and invalidation protocol.'),
64:('lazy, once','A Future stores waiting client addresses, delivers replies and rejects second resolution. It is not a local deferred computation.'),
66:('lazy, once','The serial Message is the ownership/concurrency mechanism. A persistent ordinary thunk still requires explicit construction and complete failure metadata; the existing owner is already smaller in this fixture.'),
67:('guard, lazy','Waiting requests must leave the Message able to process publish and reply to all waiters. A local guard or delayed callable is not this suspension/reply protocol.'),
88:('traverse, zipWith','Structured concurrency must cancel and wait for both child stop notifications, including duplicates. Sequential collection combinators do not implement child lifetimes or Message delivery.'),
90:('map, groupBy, foldl','The example includes separate reducers and acknowledgement barrier. A local map/group/fold over partitions would delete the distributed protocol rather than shorten it.'),
79:('patch, bindFields, derive','Both fluent setters return and mutate the same Options object. Copy/patch/derive would change identity or still require setters; the existing OPERANDS_TEMPLATE is the appropriate operator mechanism.'),
80:('derive, copy','Both instances share mutable TypeData. Copying or deriving private type data would remove the demonstrated shared-change observation.'),
81:('adapter, bindFields','Host identity and explicit install/query of one extension are the pattern. A wrapper adapter is a separate mechanism and does not eliminate those required operations.'),
}
GENERIC={
'01':('pipe, compose, guard','The fixture uses small field updates, callback boundaries or routing decisions. A higher-order wrapper adds construction/admission/error surface without removing a required model/view/controller boundary; no text or sequence matcher is needed.'),
'02':('pipe, compose, adapter','The scenario exposes architectural ports and distinct calls. Replacing them with a helper must keep callback count, adapter replacement and HTTP/Message effects; no complete shorter new-library variant was established.'),
'03':('select, project, foldl, lazy','Keep named domain fields, identity, validation and database/transaction behavior. No complete shorter equivalent library substitution was established with those observations and the current control boundary.'),
'04':('foldl, forEach','The observable unit is event/transaction/Message state, including duplicate and error paths. Collection/text operations cannot remove that protocol or its effects.'),
'05':('retryCall, once, guard','Clock, status, capacity, HTTP paths and delivery effects define this fixture. Generic callable wrappers do not replace those policies without additional code and a different comparison boundary.'),
'06':('map, traverse, once','Keep Message ownership, post/ask/answer, callback counts and child lifetimes. Local sequence or regex computation is not a substitute for a separate execution lane or delivery protocol.'),
'07':('lazy, once, guard','Keep the serial Message owner and its externally visible state/replies. A callable wrapper is not a lock, waiting-reply protocol or separate participant.'),
'08':('adapter, derive, select, predicate','Preserve every field, reference identity and object/type relationship. Ordinary direct calls and copying already express the small fixture; no shorter complete library variant was established.'),
}
entries=[];changed=[]
for jp in sorted(ROOT.glob('0[1-8]_*/patterns.json')):
    data=json.loads(jp.read_text());modified=False
    for p in data['patterns']:
        listing=next(l for l in p['listings'] if l['language']=='LMX')
        old=canonical_code(p.get('variants',{}).get('LMX',{}).get('procedural',listing['code']))
        after=canonical_code(listing['code'])
        candidate,reason=SPECIAL.get(p['id'],GENERIC[jp.parent.name[:2]])
        decision='retained'
        if p['id'] in CHANGES:
            before_fragment,after_fragment,reason=CHANGES[p['id']]
            if before_fragment not in old: raise ValueError((jp,p['id'],'original fragment absent'))
            after=canonical_code(old.replace(before_fragment,after_fragment,1))
            if metrics(after)['nonwhitespace_characters']>=metrics(old)['nonwhitespace_characters']:
                raise ValueError((p['id'],'new candidate is not shorter'))
            p['procedural_lmx']=old
            p.setdefault('variants',{}).setdefault('LMX',{}).update({'procedural':old,'direct_expression':after})
            p.setdefault('primary_variant',{})['LMX']='direct_expression'
            p.setdefault('eligible_variants',{})['LMX']=['procedural','direct_expression']
            p.setdefault('fairness_notes',{})['LMX']=reason+' No library implementation is moved outside the listing, and the controls already use the same Boolean/guard mechanism.'
            listing['code']=after
            stem=f"{p['id']:03d}_{p['slug']}"
            source=jp.parent/'examples/lmx'/(stem+'.lm3')
            source.write_text(after+'\n'+PROCEDURAL_BEGIN+'\n'+'\n'.join('# '+line for line in old.splitlines())+'\n'+PROCEDURAL_END+'\n')
            md=jp.parent/(stem+'_comparision.md');text=md.read_text()
            m=re.search(r'^```lmx\n([\s\S]*?)^```',text,re.M)
            if not m or canonical_code(m[1]) not in (old,after): raise ValueError((md,'first primary differs'))
            text=text[:m.start(1)]+after+text[m.end(1):]
            marker='<!-- postfix-expression-review-2026-11-22 -->'
            section=(marker+'\n\n## Процедурный аналог LMX — вне основного подсчёта\n\n'
                     'Полный прежний вариант сохранён. Основным выбран более короткий эквивалентный вариант с обычным Expression; новые библиотеки не скрывают часть реализации.\n\n'
                     '```lmx\n'+old+'```\n\n**Основание выбора / Selection:** '+reason+'\n\n')
            if marker not in text:
                at=text.find('## English explanation')
                text=text[:at]+section+text[at:] if at>=0 else text+'\n'+section
            md.write_text(text)
            candidate='ordinary comparison / short-circuit Expression'
            decision='selected_shorter_direct_expression';modified=True
            changed.append({'group':jp.parent.name,'id':p['id'],'before':metrics(old)['nonwhitespace_characters'],'after':metrics(after)['nonwhitespace_characters'],'saved':metrics(old)['nonwhitespace_characters']-metrics(after)['nonwhitespace_characters']})
        entries.append({'group':jp.parent.name,'id':p['id'],'name':p['name'],'kind':p.get('kind','pattern'),'considered':candidate,'decision':decision,'reason':reason,'source_sha256':hashlib.sha256(after.encode()).hexdigest(),'characters':metrics(after)['nonwhitespace_characters'],'scenario_and_expected_observations_retained':True,'runtime_executed':False})
    if modified: jp.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
report={'date':'2026-11-22','scope':'Current uploaded archive only; groups 01--08, all current patterns and paired implementations','reviewed':len(entries),'selected':changed,'decision_rule':'Preserve complete scenario, fields, identity, effects, error paths and counting boundary. New higher-order/library operations are not automatically free. Select strictly shorter eligible code and keep the complete prior code adjacent.','runtime_executed':False,'statistics_generation':'Pending the existing aggregate generators; this report measures only reviewed source candidates.','entries':entries}
(ROOT/'validation/sequence_regex_review_01_08.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
lines=['# Current sequence / Pattern / core review: groups 01–08','Date: 2026-11-22. All **'+str(len(entries))+'** current records were read against their full scenario and expected observations. Only current uploaded source was used.','## Selected shorter variants','Four ordinary Expression simplifications preserve all fields and observations. They introduce no unmeasured library dependency. Complete previous LMX listings remain in JSON, a separate Markdown code fence and commented standalone source.','| ID | Before | After | Saved |\n| ---: | ---: | ---: | ---: |']
lines[-1]+='\n'+'\n'.join(f"| {x['id']:03d} | {x['before']} | {x['after']} | {x['saved']} |" for x in changed)
lines+=['## Why the other examples remain','No Pattern-based replacement was selected merely to insert the new API into an unrelated architectural example. The direct regex implementation and acceptance fixtures are linked in [REGEX_IMPLEMENTATION](LMX_Fn_Receivers/REGEX_IMPLEMENTATION.md). The serial/transport examples continue using Message and the documented HTTP ports. Local map/fold cannot substitute for their delivery, transaction, cancellation or acknowledgement protocols.','Status-based retry with exponential delay is not generic exception retry. A field-sharing Type Object is not a copy/derive operation. A persistent cache cannot be replaced by a computed DATA initializer that creates a fresh wrapper for each call. DTO projection must retain the exact named fields and exclude the secret and methods. Specification construction retains its explicitly copied owner; no unsupported assumption about node ownership is used to declare the existing code wrong.','The measured companion implementations remain implementations. Replacing their bodies with calls to a ready high-level library would move the comparison boundary. The 095 ownership-sensitive spelling was retained, and no previous variant or explanatory code was removed.','## Full decision record','[Machine-readable record for all 91 entries](validation/sequence_regex_review_01_08.json). It contains the considered APIs, concrete reason, source hash and selected count for every current entry. Full CSV/XLSX/PDF statistics must be regenerated afterwards by the existing publication tools. This review did not execute LMX or control programs.']
(ROOT/'SEQUENCE_REGEX_REVIEW_01_08.md').write_text('\n\n'.join(lines)+'\n')
print(json.dumps({'reviewed':len(entries),'changed':changed},ensure_ascii=False,indent=2))

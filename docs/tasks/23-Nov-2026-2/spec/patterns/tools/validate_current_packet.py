#!/usr/bin/env python3
"""Проверка текущего пакета без миграций и изменения исходников.

python3 patterns/tools/validate_current_packet.py --baseline /path/to/baseline/spec
Записывается только JSON-отчёт. Программы LMX/Julia/Perl/Haskell не запускаются.
"""
from __future__ import annotations
import sys
sys.dont_write_bytecode = True
import argparse
from collections import Counter
import csv
import hashlib
import importlib.util
import json
from pathlib import Path
import re
from packet_metadata import addition_metadata, restoration_metadata
from throws_metrics import measure_throws

LANG = {'LMX':('lmx','lm3','lmx'),'TypeScript':('typescript','ts','typescript'),
        'C#':('csharp','cs','csharp'),'Java':('java','java','java'),'Go':('go','go','go'),
        'Python':('python','py','python'),'Erlang':('erlang','erl','erlang'),
        'Rust':('rust','rs','rust'),'Haskell':('haskell','hs','haskell'),
        'Scala':('scala','scala','scala')}
GOF = {'lmx':'LMX','python':'Python','java':'Java','cpp':'C++','csharp':'C#',
       'typescript':'TypeScript','go':'Go','rust':'Rust'}
BRIDGES = {'attempt','callable','fieldNames','normalizeType','raise','renameFields',
           'signature','signatureData','currentCall','frameSlot','prepare','enter',
           'releaseCall','arrayInfo','arrayRead','arrayAdmit','arrayWrite',
           'attemptAccepted','acceptsRequirement'}
MARKER = re.compile(r'^# BEGIN (?:PROCEDURAL|ALTERNATIVE) LMX \(excluded from character counts\)',re.M)

def canonical(code): return code.replace('\r\n','\n').replace('\r','\n').strip()+'\n'
def primary(code): return canonical(MARKER.split(code,1)[0])
def digest(code): return hashlib.sha256(code.encode()).hexdigest()
def metric(code):
    return {'characters_with_whitespace':len(code),'nonwhitespace':sum(not x.isspace() for x in code),
            'nonblank_lines':sum(bool(x.strip()) for x in code.splitlines()),'sha256':digest(code)}
def fences(text):
    return [(m[1].strip(),canonical(m[2]),m.start()) for m in re.finditer(r'^```([^\n]*)\n([\s\S]*?)^```[ \t]*$',text,re.M)]
def production(library):
    result={}
    for path in sorted((library/'src').rglob('*.lmx')):
        for chunk in re.split(r'\n[ \t]*\n',path.read_text()):
            match=re.search(r'^((?:Fx|Rx)[A-Za-z0-9_]+):[^\n]*\n',chunk,re.M)
            if match:
                result[match[1]]={'code':canonical(chunk[match.start():]),'source':path}
    return result

def check_packet(patterns,baseline):
    spec=patterns.parent; library=patterns/'LMX_Fn_Receivers';examples=patterns/'examples'
    checks=[];errors=[];warnings=[];summary={};import_rows=[]
    provenance=restoration_metadata(patterns)
    reviewed=json.loads((patterns/'validation/reviewed_source_changes_20261123.json').read_text())
    shared_review={x['id']:x for x in reviewed['shared_implementation_clients']}
    reviewed_helpers={x['id']:x for x in reviewed['shared_implementations']}
    import_allowances={}
    def check(ok,label,details=None):
        row={'check':label,'status':'PASS' if ok else 'FAIL'}
        if details is not None:row['details']=details
        checks.append(row)
        if not ok:errors.append(row)
        return ok
    def read_json(path):
        try:return json.loads(path.read_text())
        except Exception as exc:
            check(False,'read_json',{'file':str(path),'error':str(exc)});return None
    def file(path,label):return check(path.is_file(),label,{'file':str(path)})
    def no_custom_import(code,label,blocked):
        allowed=set(import_allowances.get(label,[]));approved=[]
        imports=[]
        for line in code.splitlines():
            trimmed=line.strip()
            if re.match(r'(?:import|from|using|use|require)\b',trimmed):imports.append(trimmed)
            # Go imports inside an import(...) group are quoted bare paths.
            elif re.match(r'(?:\w+\s+)?"[^"\n]+"\s*$',trimmed):imports.append(trimmed)
        suspicious=[]
        for line in imports:
            if line in allowed:
                approved.append(line);continue
            if re.search(r'(?:library_comparisons|PerlComparison|Julia(?:Ordered|Array|Mutation|OrderGroup)Reference|pipecomparison|retrycomparison|retryhelper|PatternHelpers)',line,re.I):
                suspicious.append(line);continue
            for name in blocked:
                if re.search(r'(?<![\w.])'+re.escape(name)+r'(?=[.\s(;]|$)',line):
                    suspicious.append(line);break
        check(not suspicious and set(approved)==allowed,label+(': reviewed shared implementation imports only' if allowed else ': no comparison imports'),{'unexpected':suspicious,'approved':approved})
        import_rows.append({'client':label,'imports':imports,'custom_comparison_imports':suspicious,'approved_shared_imports':approved})
    statistics=read_json(patterns/'validation/statistics_20261122.json') or {'groups':[],'root_examples':[],'gof':{'records':[]},'shared_implementation_components':[]}
    published_records={record['id']:record for group in statistics['groups'] for record in group['records']}
    published_gof={record['file']:record for record in statistics['gof']['records']}
    published_examples={record['id']:record for record in statistics['root_examples']}
    source_defs=production(library)
    catalog=read_json(library/'catalog.json') or []
    added,addition_documents=addition_metadata(library)
    added_names={x['name'] for x in added}
    names=[x['name'] for x in catalog];name_set=set(names)
    check(len(names)==len(name_set),'core: unique public names',len(names))
    check(all(re.fullmatch(r'[a-z][A-Za-z0-9]*',n) for n in names),'core: lowerCamelCase public names')
    for manifest in addition_documents:
        document=manifest['document'];entries=document.get('entries',[])
        check(len({x['name'] for x in entries})==len(entries),'addition manifest unique identities: '+manifest['file'])
        for key in ('public_count_added','new_public_count'):
            if key in document:check(document[key]==len(entries),'addition manifest count: '+manifest['file']+'/'+key)
    pub=(library/'src/public.lmx').read_text()
    exports=re.findall(r'^\s+@:\s+([A-Za-z][A-Za-z0-9_]*)\s+([A-Za-z][A-Za-z0-9_]*\\[A-Za-z][A-Za-z0-9_]*)\s*$',pub,re.M)
    export_map=dict(exports)
    check(len(exports)==len(export_map)==len(name_set) and set(export_map)==name_set,'core: catalog/export identity')
    check(all(export_map.get(x['name'])==x['api'] for x in catalog),'core: exact callable export targets')
    for entry in catalog:
        check((library/entry['source']).is_file(),'core source: '+entry['name'],entry['source'])
        check(entry['api'].split('\\')[0] in source_defs,'core definition: '+entry['name'],entry['api'])
    for entry in added:
        record=next((x for x in catalog if x['name']==entry['name']),None)
        check(record is not None and record['api']==entry['api'],'addition exported: '+entry['name'])
    baseline_patterns=baseline/'patterns'
    old_names=set()
    if file(baseline_patterns/'LMX_Fn_Receivers/catalog.json','immutable baseline catalog present'):
        old_path=baseline_patterns/'LMX_Fn_Receivers/catalog.json'
        old=read_json(old_path) or [];old_names={x['name'] for x in old}
        check(hashlib.sha256(old_path.read_bytes()).hexdigest()==provenance['base_archive']['catalog_sha256'],'baseline catalog belongs to reviewed23-Nov archive')
        check(len(old_names)==provenance['base_archive']['public_names'],'baseline public count agrees with provenance')
        check(old_names<=name_set and name_set-old_names==added_names-old_names,'core: uploaded identities retained; new names exactly match deduplicated addition metadata')
    assembled=(library/'LMX_Receivers.lmx').read_text()
    called=set(re.findall(r'\bFxKernel\\+(\w+)\s*\(',assembled))
    check(called==BRIDGES,'core: 19 internal bridges; no extra public name',{'observed':sorted(called),'expected':sorted(BRIDGES)})
    assembly_spec=importlib.util.spec_from_file_location('_packet_assembly',library/'tools/assemble.py')
    module=importlib.util.module_from_spec(assembly_spec);assembly_spec.loader.exec_module(module)
    module.ROOT=library
    check(assembled==module.assembled(),'core: assembly equals current source parts')
    summary['core']={'public_names':len(names),'uploaded_names':len(old_names),'additions':len(name_set-old_names),'metadata_identities':len(added_names),'internal_bridges':len(called),'assembly_sha256':digest(assembled)}

    # All nine groups: authoritative JSON -> source -> first primary language fence.
    records={};groups=[];primary_count=0;foreign_clients=[];implementation_count=0;blocked={'MaybeValue','Bounce','Around','Partial','IntApply','IntPipe','Lazy','StepIterator','CharacterRange','CurryInt','EvaluationModes','FirstMatch','PredicateSet','FieldEquality'}
    for path in sorted(patterns.glob('[0-9][0-9]_*/patterns.json')):
        data=read_json(path)
        if data is None:continue
        ids=[]
        csv_path=path.parent/f'LMX_Comparison_{path.parent.name}.csv'
        csv_rows={}
        if file(csv_path,'group CSV present: '+path.parent.name):
            with csv_path.open(encoding='utf-8-sig',newline='') as stream:
                csv_rows={int(x['id']):x for x in csv.DictReader(stream)}
        for record in data['patterns']:
            ident=record['id'];ids.append(ident)
            check(ident not in records,'unique extended ID '+str(ident));records[ident]=(path.parent,record)
            listed=record['listings'];stem=f'{ident:03d}_{record["slug"]}'
            check(len(listed)==3 and len({x['language'] for x in listed})==3,'three primaries: '+stem)
            check({x['language'] for x in listed}==({'LMX'} | set(data['languages'])),'group language identity: '+stem)
            md_path=path.parent/(stem+'_comparision.md');md_blocks=[]
            if file(md_path,'comparison MD: '+stem):md_blocks=fences(md_path.read_text())
            for listing in listed:
                primary_count+=1;language=listing['language'];folder,ext,tag=LANG[language]
                code=canonical(listing['code']);source=path.parent/'examples'/folder/(stem+'.'+ext)
                if file(source,'primary source: '+stem+'/'+language):
                    check(primary(source.read_text())==code,'JSON/source mirror: '+stem+'/'+language)
                matching=[body for label,body,_ in md_blocks if label==tag]
                check(bool(matching) and matching[0]==code,'JSON/Markdown mirror: '+stem+'/'+language)
                stat=csv_rows.get(ident,{})
                check(stat.get(language+'_characters')==str(metric(code)['nonwhitespace']) and stat.get(language+'_nonblank_lines')==str(metric(code)['nonblank_lines']),'JSON/CSV metrics: '+stem+'/'+language)
                if language=='LMX':
                    extra=measure_throws(code,patterns)['without_complex_throws_characters']
                    check(stat.get('LMX_without_complex_throws_characters')==str(extra),'JSON/CSV supplementary Throws metric: '+stem)
                    check(listing.get('metrics',{}).get('without_complex_throws_characters')==extra,'JSON supplementary Throws metric: '+stem)
                    published=published_records.get(ident,{}).get('metrics',{}).get('LMX',{})
                    check(published.get('without_complex_throws_characters')==extra and published.get('characters')==metric(code)['nonwhitespace'],'aggregate full/supplementary LMX metrics: '+stem)
                if ident<=90 and language!='LMX':
                    label=f'group/{stem}/{language}'
                    foreign_clients.append((code,label))
                    if record.get('comparison_level')=='shared_implementation_client':
                        allowance=shared_review.get(ident,{})
                        check(allowance.get('listing_sha256',{}).get(language)==digest(code),'reviewed synchronous shared client: '+label)
                        import_allowances[label]=allowance.get('allowed_imports',{}).get(language,[])
            if record.get('kind')=='implementation':implementation_count+=1
        check(set(csv_rows)==set(ids),'group CSV record identity: '+path.parent.name)
        published_group=next((group for group in statistics['groups'] if group['directory']==path.parent.name),{})
        for layer,totals in published_group.get('totals',{}).items():
            rows=[row for row in published_group['records'] if row['layer']==layer]
            for language,values in totals.items():
                fields=['characters']+(['without_complex_throws_characters'] if language=='LMX' else [])
                check(all(values.get(field)==sum(row['metrics'][language][field] for row in rows) for field in fields),'aggregate group layer full/supplementary totals: '+path.parent.name+'/'+layer+'/'+language)
        groups.append({'directory':path.parent.name,'records':len(ids),'primaries':3*len(ids)})
    check(len(groups)==9 and set(records)==set(range(1,100)),'extended groups: nine groups / IDs 1..99')
    check(primary_count==297,'extended groups: 297 primary listings',primary_count)
    check(implementation_count==9 and all(records[i][1].get('kind')=='implementation' for i in range(91,100)),'extended groups: nine implementation records 091..099')
    relations=[]
    for ident,(_,record) in records.items():
        for impl in record.get('implementation_ids',[]):
            good=impl in records and records[impl][1].get('kind')=='implementation'
            good=good and ident in records[impl][1].get('usage_ids',[])
            check(good,f'bidirectional usage relation: {ident}->{impl}')
            if impl in records:check({x['language'] for x in record['listings']}=={x['language'] for x in records[impl][1]['listings']},f'paired language identity: {ident}->{impl}')
            relations.append([ident,impl])
    for ident in range(91,100):
        for usage in records.get(ident,(None,{}))[1].get('usage_ids',[]):
            check(usage in records and ident in records[usage][1].get('implementation_ids',[]),f'bidirectional implementation relation: {ident}->{usage}')
    manifest=read_json(patterns/'comparison_sources/catalog_manifest.json') or {}
    check(set(manifest.get('pattern_ids',[]))==set(range(1,91)) and set(manifest.get('implementation_ids',[]))==set(range(91,100)),'comparison manifest ID identity')
    check(len(manifest.get('comparisons',[]))==99 and {x['id'] for x in manifest.get('comparisons',[])}==set(records),'comparison manifest covers all 99 records')
    shared_costs=[]
    check({i for i,(_,r) in records.items() if r.get('comparison_level')=='shared_implementation_client'}==set(shared_review),'shared implementation classification is explicitly reviewed')
    for ident,allowance in shared_review.items():
        record=records.get(ident,(None,{}))[1]
        check(record.get('implementation_ids')==allowance['implementation_ids'],f'shared client links complete helper: {ident}')
        for listing in record.get('listings',[]):
            check(digest(canonical(listing['code']))==allowance['listing_sha256'].get(listing['language']),f'shared client reviewed source: {ident}/{listing["language"]}')
    for ident,allowance in reviewed_helpers.items():
        record=records.get(ident,(None,{}))[1];usage=allowance['usage_ids']
        check(record.get('usage_ids')==usage and record.get('kind')=='implementation',f'shared helper complete relation: {ident}')
        costs={}
        for listing in record.get('listings',[]):
            language=listing['language'];code=canonical(listing['code'])
            check(digest(code)==allowance['listing_sha256'].get(language),f'shared helper reviewed source: {ident}/{language}')
            helper=metric(code)['nonwhitespace']
            client=sum(metric(canonical(next(l['code'] for l in records[i][1]['listings'] if l['language']==language)))['nonwhitespace'] for i in usage)
            costs[language]={'helper_once':helper,'clients':client,'complete_component':helper+client}
            if language=='LMX':
                costs[language]['without_complex_throws_characters']=measure_throws(code,patterns)['without_complex_throws_characters']+sum(measure_throws(canonical(next(l['code'] for l in records[i][1]['listings'] if l['language']==language)),patterns)['without_complex_throws_characters'] for i in usage)
            if language=='LMX':check(code.strip() in (library/'src/coreComparisonGroups.lmx').read_text(),f'shared helper actual canonical definition: {ident}')
        shared_costs.append({'implementation_id':ident,'usage_ids':usage,'costs':costs})
    for component in shared_costs:
        published=next((record for record in statistics['shared_implementation_components'] if record['implementation_id']==component['implementation_id']),{})
        check(published.get('usage_ids')==component['usage_ids'] and published.get('costs')==component['costs'],'aggregate complete shared component counts: '+str(component['implementation_id']))
    summary['shared_implementation_components']=shared_costs
    summary['extended_patterns']={'groups':groups,'records':len(records),'primaries':primary_count,'implementation_records':implementation_count,'usage_implementation_relations':relations}

    # Source preservation with exact, explicitly reviewed LMX changes09/20.
    def gof_primary(path):
        out={};text=path.read_text()
        for tag,body,offset in fences(text):
            if tag not in GOF or GOF[tag] in out:continue
            if '<!-- uncounted-code:' in text[max(0,offset-120):offset]:continue
            out[GOF[tag]]=body
        return out
    gof=[]
    allowed_gof={(x['file'],x['language']):x for x in reviewed['gof_changes']}
    for path in sorted(patterns.glob('[0-9][0-9]_*_comparison.md')):
        base=baseline_patterns/path.name;current=gof_primary(path)
        check(len(current)==8,'GoF: eight primary languages '+path.name)
        before=gof_primary(base) if file(base,'GoF baseline: '+path.name) else {}
        unchanged=current==before
        accepted=True;changed=[]
        for language,body in current.items():
            if before.get(language)==body:continue
            changed.append(language);allowed=allowed_gof.get((path.name,language),{})
            accepted=accepted and allowed.get('baseline_sha256')==digest(before.get(language,'')) and allowed.get('reviewed_sha256')==digest(body)
        check(accepted and set(current)==set(before),'GoF primary preservation with exact reviewed changes: '+path.name,changed)
        gof.append({'file':path.name,'languages':len(current),'unchanged':unchanged,'accepted':accepted,'reviewed_changed_languages':changed,'sha256':{k:digest(v) for k,v in current.items()}})
        for language,code in current.items():
            published=published_gof.get(path.name,{}).get('metrics',{}).get(language,{})
            check(published.get('characters')==metric(code)['nonwhitespace'],'GoF aggregate full metric: '+path.name+'/'+language)
            if language=='LMX':
                check(published.get('without_complex_throws_characters')==measure_throws(code,patterns)['without_complex_throws_characters'],'GoF aggregate supplementary Throws: '+path.name)
            else:foreign_clients.append((code,'GoF/'+path.name+'/'+language))
    check(len(gof)==23 and sum(x['languages'] for x in gof)==184,'GoF: 23 comparisons / 184 uploaded primary listings')
    summary['gof']={'comparisons':len(gof),'primary_listings':sum(x['languages'] for x in gof),'all_preserved':all(x['unchanged'] for x in gof),'all_changes_reviewed':all(x['accepted'] for x in gof),'reviewed_changes':sum(len(x['reviewed_changed_languages']) for x in gof),'records':gof}

    # The original examples: preserve all identities, allowing requested edits.
    expected=read_json(examples/'expected_results.json') or {'source_examples':[]}
    originals=expected['source_examples'];original_ids={x['id'] for x in originals}
    baseline_ids={x.stem for x in (baseline_patterns/'examples/lmx').glob('*.lm3')}
    current_ids={x.stem for x in (examples/'lmx').glob('*.lm3')}
    check(len(originals)==24 and original_ids==baseline_ids==current_ids,'original examples: uploaded 24 identities retained')
    for e in originals:
        source=examples/e['file']
        if file(source,'original example source: '+e['id']):
            code=primary(source.read_text());published=published_examples.get(e['id'],{})
            check(published.get('characters')==metric(code)['nonwhitespace'] and published.get('without_complex_throws_characters')==measure_throws(code,patterns)['without_complex_throws_characters'],'original example aggregate full/supplementary metric: '+e['id'])
    snapshots=read_json(examples/'validation/primary_listings.json') or {'listings':{},'selected':{}}
    variants=read_json(examples/'variants.json') or {'records':[]}
    by_variant={x['id']:x for x in variants['records']}
    for ident,code in snapshots['listings'].items():
        check(primary((examples/'lmx'/f'{ident}.lm3').read_text())==canonical(code),'original selected JSON/source mirror: '+ident)
        item=by_variant.get(ident,{});chosen=snapshots['selected'].get(ident)
        selected=next((v for v in item.get('variants',[]) if v['id']==chosen),None)
        check(selected is not None and canonical(selected['code'])==canonical(code),'original selected variant identity: '+ident)
    index=read_json(examples/'haskell/comparison_index.json') or {'entries':[]}
    indexed=index['entries'];module_path=examples/'haskell/Analogies.hs';hs=module_path.read_text();hs_lines=hs.splitlines()
    check(len(indexed)==24 and {x['id'] for x in indexed}==original_ids,'Haskell coverage index: all 24 identities, no forced analogies')
    check(digest(hs)==index.get('source_module_sha256'),'Haskell index module hash current')
    statuses=Counter()
    for item in indexed:
        statuses[item['status']]+=1
        check(item['status'] in ('complete_pair','related_analogy','lmx_only'),'Haskell comparison status: '+item['id'])
        source=examples/item['lmx_source']
        check(digest(source.read_text())==item['lmx_source_sha256'],'Haskell index LMX hash current: '+item['id'])
        if item.get('foreign_code'):
            code=item['foreign_code'];check(digest(code)==item['foreign_listing_sha256'],'Haskell listing hash: '+item['id'])
            for span in item.get('source_ranges',[]):
                raw='\n'.join(hs_lines[span['first_line']-1:span['last_line']]).strip()
                check(raw in code,'Haskell whole declaration slice: '+item['id']+'/'+span['symbol'])
            for imp in item.get('imports',[]):
                check(hs_lines[imp['first_line']-1]==imp['original_text'],'Haskell narrowed import provenance: '+item['id']+'/'+imp['module'])
        check(bool(item.get('pair_ratio_eligible'))==(item['status']=='complete_pair'),'Haskell ratio eligibility: '+item['id'])
    foreign_clients.append((hs,'original/Haskell Analogies.hs'))
    helper_inventory=read_json(examples/'validation/receiver_library_counts.json') or {'comparisons':[]}
    helper_pages=sorted((examples/'library_comparisons').glob('*_comparision.md'))
    check(len(helper_pages)==7,'original examples: seven implementation/primitive comparison pages')
    for page in helper_pages:
        blocks=fences(page.read_text());tags={tag for tag,_,_ in blocks}
        check({'lmx','haskell'}<=tags,'original helper pair retained: '+page.name)
        lmx='\n'.join(code for tag,code,_ in blocks if tag=='lmx')
        for chunk in re.split(r'\n[ \t]*\n',lmx):
            match=re.search(r'^((?:Fx|Rx)[A-Za-z0-9_]+):[^\n]*\n',chunk,re.M)
            if match:
                check(match[1] in source_defs and canonical(chunk[match.start():])==source_defs[match[1]]['code'],'helper exact production body: '+page.name+'/'+match[1])
    for item in helper_inventory['comparisons']:
        page=examples/item['file'];blocks=fences(page.read_text())
        lmx=next(code for tag,code,_ in blocks if tag=='lmx')
        foreign=next(code for tag,code,_ in blocks if tag=='haskell')
        check(digest(lmx)==item['lmx_entry']['sha256'],'helper LMX-entry metadata: '+item['file'])
        check(digest(foreign)==item['haskell']['sha256'],'helper Haskell metadata: '+item['file'])
        check(canonical((examples/item['haskell_source']).read_text())==foreign,'helper standalone Haskell/source mirror: '+item['file'])
        check(item.get('imported_by_clients') is False,'helper excludes foreign usage import: '+item['file'])
    summary['original_examples']={'records':len(originals),'haskell_statuses':dict(statuses),'helper_comparisons':len(helper_pages),'standalone_haskell_comparison_modules':len(helper_inventory['comparisons'])}

    # The two new suites use one common logical schema and distinct local paths.
    suites={}
    for suite,prefix,language,tag in [('julia','J','Julia','julia'),('perl','P','Perl','perl')]:
        directory=examples/(suite+'_comparison');data=read_json(directory/'examples.json')
        if data is None:continue
        clients=data['examples'];implementations=data['implementations'];by_impl={x['id']:x for x in implementations}
        check(len(by_impl)==len(implementations)==(4 if suite=='julia' else 7),suite+': complete unique implementation records')
        check(len(clients)==24 and {x['id'] for x in clients}=={f'{prefix}{i:02d}' for i in range(1,25)},suite+': 24 unique client records')
        check(data['foreign_language']==language and data['suite']==suite,suite+': schema language identity')
        local_stats=read_json(directory/'statistics.json') or {'rows':[]}
        stat_map={(r['id'],r['language']):r for r in local_stats['rows']}
        dependency_definitions={};shared_dependency_code=''
        if suite=='perl':
            dependency_report=read_json(directory/'validation/implementation_dependencies.json') or {'definitions':[]}
            dependency_definitions={entry['name']:entry for entry in dependency_report['definitions']}
            shared_path=directory/'library_comparisons/shared_dependencies.lmx'
            if file(shared_path,'perl: explicit shared implementation bodies'):
                shared_dependency_code=shared_path.read_text()+'\n'+'\n'.join(item['lmx'] for item in implementations)
            check(len(dependency_definitions)==len(dependency_report['definitions']),'perl: unique implementation dependency definitions')
            dependency_spec=importlib.util.spec_from_file_location('_packet_perl_dependencies',directory/'tools/rebuild.py')
            dependency_module=importlib.util.module_from_spec(dependency_spec);dependency_spec.loader.exec_module(dependency_module)
        for role,items in [('client',clients),('implementation',implementations)]:
            for item in items:
                ident=item['id'];paths=item.get('source_files')
                if not isinstance(paths,dict):paths={'lmx':item['lmx_file'],'foreign':item['foreign_file']}
                md_path=directory/(ident+'_comparision.md') if role=='client' else directory/'library_comparisons'/(ident+'_comparision.md')
                if not md_path.exists() and role=='implementation':
                    found=list((directory/'library_comparisons').glob(ident+'*_comparision.md'))
                    if len(found)==1:md_path=found[0]
                md_blocks=fences(md_path.read_text()) if file(md_path,suite+': '+role+' MD '+ident) else []
                for current_language,key,current_tag in [('LMX','lmx','lmx'),(language,'foreign',tag)]:
                    code=canonical(item[key]);source=directory/paths[key]
                    if file(source,suite+': '+role+' source '+ident+'/'+current_language):
                        check(source.read_text()==code,suite+': JSON/source mirror '+ident+'/'+current_language)
                    matching=[body for label,body,_ in md_blocks if label==current_tag]
                    check(bool(matching) and matching[0]==code,suite+': JSON/Markdown mirror '+ident+'/'+current_language)
                    stat=stat_map.get((ident,current_language),{});m=metric(code)
                    names_to_keys=({'characters_with_whitespace':'characters_with_whitespace','nonwhitespace':'characters_without_whitespace','nonblank_lines':'nonblank_lines'} if suite=='julia' else {'characters_with_whitespace':'characters','nonwhitespace':'nonwhitespace','nonblank_lines':'nonblank_lines'})
                    check(all(stat.get(key2)==m[key1] for key1,key2 in names_to_keys.items()),suite+': statistics mirror '+ident+'/'+current_language)
                    if key=='lmx':check(stat.get('without_complex_throws_characters')==measure_throws(code,patterns)['without_complex_throws_characters'],suite+': supplementary Throws statistic '+ident)
                check(set(item['core_functions'])<=name_set,suite+': known public core names '+ident)
                if role=='client':
                    foreign_clients.append((item['foreign'],suite+'/'+ident))
                    for operation in item['core_functions']:
                        if suite=='julia':
                            link=item.get('implementation_links',{}).get(operation,'')
                            found=bool(link) and (directory/link).is_file() and any(operation in impl['core_functions'] for impl in implementations)
                        else:
                            links=item.get('implementation_pairs',{}).get(operation,[])
                            found=bool(links) and all(ident2 in by_impl and operation in by_impl[ident2]['core_functions'] for ident2 in links)
                            if not links:
                                reference=item.get('core_sources',{}).get(operation,{})
                                root=reference.get('root');definition=source_defs.get(root,{})
                                names=reference.get('all_definitions',[])
                                public=next((entry for entry in catalog if entry['name']==operation),{})
                                found=bool(root and names) and public.get('api','').split('\\')[0]==root
                                found=found and reference.get('sha256')==digest(definition.get('code',''))
                                found=found and (directory/reference.get('source','')).resolve()==definition.get('source')
                                found=found and root in names and reference.get('comparison_pairs')==[]
                                needed,external=dependency_module.closure([root],source_defs) if root else (set(),set())
                                found=found and set(names)==needed and set(reference.get('external_boundaries',[]))==external
                                for name in names:
                                    entry=dependency_definitions.get(name,{})
                                    actual=source_defs.get(name,{})
                                    body=actual.get('code','')
                                    found=found and bool(body) and entry.get('sha256')==digest(body)
                                    found=found and (directory/entry.get('source','')).resolve()==actual.get('source')
                                    found=found and body.strip() in shared_dependency_code
                                check(found,'perl: unpaired operation has exact source and full declared dependency bodies '+ident+'/'+operation,{'root':root,'definitions':len(names),'comparison_pairs':reference.get('comparison_pairs')})
                        check(found,suite+': full implementation coverage '+ident+'/'+operation)
                    check(all(x.get('count_eligible',True) in (True,False) and bool(x.get('code','').strip()) for x in item.get('alternatives',[])),suite+': complete declared alternatives '+ident)
                else:
                    check(bool(item['lmx'].strip()) and bool(item['foreign'].strip()),suite+': both full implementation listings '+ident)
                    for definition in item.get('production_definitions',[]):
                        check(definition['name'] in source_defs and digest(source_defs[definition['name']]['code'])==definition['sha256'],suite+': exact production definition '+ident+'/'+definition['name'])
                    for source_info in item.get('canonical_sources',[]):
                        source=spec/source_info['file']
                        check(source.is_file() and hashlib.sha256(source.read_bytes()).hexdigest()==source_info['file_sha256'],suite+': canonical source provenance '+ident+'/'+source_info['file'])
        suites[suite]={'clients':len(clients),'primaries':2*len(clients),'implementation_pairs':len(implementations),'core_names':sorted({n for x in clients for n in x['core_functions']})}
    # SBCL uses the same source-boundary policy with its own explicit schema.
    directory=examples/'SBCL_comparison'
    sbcl=read_json(directory/'examples.json') or {'examples':[]}
    sbcl_impl=read_json(directory/'implementation_data.json') or {'implementations':[]}
    clients=sbcl['examples'];implementations=sbcl_impl['implementations']
    check({x['id'] for x in clients}=={f'S{i:02d}' for i in range(1,25)},'SBCL:24 unique scenario identities')
    check(len({x['id'] for x in implementations})==len(implementations)==6,'SBCL:six complete implementation comparisons')
    for role,items in [('client',clients),('implementation',implementations)]:
        for item in items:
            ident=item['id'];md=directory/(ident+'_comparision.md') if role=='client' else directory/'library_comparisons'/(ident+'_comparision.md')
            blocks=fences(md.read_text()) if file(md,'SBCL comparison:'+ident) else []
            for language,key,tags in [('LMX','lmx',{'lmx'}),('Common Lisp','foreign',{'lisp','common-lisp'})]:
                code=canonical(item[key]);path=directory/item['source_files'][key]
                check(path.is_file() and canonical(path.read_text())==code,'SBCL JSON/source:'+ident+'/'+language)
                bodies=[body for tag,body,_ in blocks if tag in tags]
                check(bool(bodies) and bodies[0]==code,'SBCL JSON/Markdown:'+ident+'/'+language)
                m=metric(code)
                if role=='client':
                    observed=item['counts'][key]
                    check(observed['characters_nonwhitespace']==m['nonwhitespace'] and observed['sha256']==digest(code),'SBCL source metrics:'+ident+'/'+language)
                else:
                    observed=item['metrics'][language]
                    check(observed['characters_without_whitespace']==m['nonwhitespace'],'SBCL implementation metrics:'+ident+'/'+language)
                if key=='lmx':check(observed.get('without_complex_throws_characters')==measure_throws(code,patterns)['without_complex_throws_characters'],'SBCL supplementary Throws:'+ident)
            check(set(item['core_functions'])<=name_set,'SBCL known core names:'+ident)
            if role=='client':
                check(item.get('lmx_runtime_execution')=='NOT_RUN','SBCL honest LMX execution status:'+ident)
                foreign_clients.append((item['foreign'],'SBCL/'+ident))
            else:
                for definition in item.get('production_definitions',[]):
                    check(definition['name'] in source_defs and digest(source_defs[definition['name']]['code'])==definition['sha256'],'SBCL exact production:'+ident+'/'+definition['name'])
    suites['SBCL']={'clients':len(clients),'primaries':2*len(clients),'implementation_pairs':len(implementations),'complete_pairs':sum(x['comparison_status']=='complete_pair' for x in clients),'related_analogies':sum(x['comparison_status']=='related_analogy' for x in clients)}
    summary['new_suites']=suites
    check(len(originals)+sum(x['clients'] for x in suites.values())==96,'examples:24 original +24 Julia +24 Perl +24 SBCL')
    check(len(suites)==3 and all(x['primaries']==48 for x in suites.values()),'new suites:48 primary listings each')
    for code,label in foreign_clients:no_custom_import(code,label,blocked)
    summary['foreign_import_boundaries']={'clients_checked':len(foreign_clients),'custom_imports_found':sum(bool(x['custom_comparison_imports']) for x in import_rows),'reviewed_shared_imports':sum(len(x['approved_shared_imports']) for x in import_rows),'rows':import_rows}
    summary['implementation_comparisons_total']=implementation_count+len(helper_pages)+sum(x['implementation_pairs'] for x in suites.values())

    # Receipts are references only; this validator does not execute a language.
    receipts={}
    for label,path in [('julia_static',examples/'julia_comparison/validation/check_report.json'),('perl_clients',examples/'perl_comparison/validation/client_tests.json'),('perl_implementations',examples/'perl_comparison/validation/implementation_tests.json'),('SBCL_clients',examples/'SBCL_comparison/validation/common_lisp.json'),('SBCL_implementations',examples/'SBCL_comparison/validation/implementation_execution.json')]:
        if path.exists():
            receipt=read_json(path) or {}
            receipts[label]={'file':path.relative_to(patterns).as_posix(),'file_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'reported_status':receipt.get('status'),'executed_cases':receipt.get('executed_cases'),'executed_checks':receipt.get('executed_checks'),'provenance':'Existing separate receipt; not executed by this validator.'}
    runtime={'executed_by_this_validator':[],'LMX':'NOT_RUN','Julia':'NOT_RUN','Haskell':'NOT_RUN','Scala':'NOT_RUN','separate_receipts':receipts}
    return {'edition':'2026-11-23','status':'PASS' if not errors else 'FAIL','scope':'Комплектность, идентичность исходников, зеркала публикации и границы импортов; это не разбор, компиляция, runtime или проверка скорости.','source_root':str(spec),'immutable_baseline':str(baseline),'uploaded_archive_sha256':provenance['base_archive']['sha256'],'short_example_reference':provenance['short_example_reference'],'summary':summary,'checks_count':len(checks),'checks':checks,'errors':errors,'warnings':warnings,'runtime':runtime}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1],help='patterns directory, or its parent spec')
    parser.add_argument('--baseline',type=Path,help='Immutable uploaded spec directory; never modified')
    parser.add_argument('--report',type=Path,help='Default patterns/validation/current_packet_20261123.json')
    args=parser.parse_args();patterns=args.root.resolve()
    if (patterns/'patterns').is_dir():patterns=patterns/'patterns'
    baseline=args.baseline.resolve() if args.baseline else patterns.parents[2]/'baseline/spec'
    report=check_packet(patterns,baseline)
    output=args.report or patterns/'validation/current_packet_20261123.json';output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'status':report['status'],'checks':report['checks_count'],'errors':len(report['errors']),'core':report['summary']['core'],'extended_records':report['summary']['extended_patterns']['records'],'extended_primaries':report['summary']['extended_patterns']['primaries'],'gof_changes_reviewed':report['summary']['gof']['all_changes_reviewed'],'original_examples':report['summary']['original_examples']['records'],'new_suites':report['summary']['new_suites'],'implementation_comparisons':report['summary']['implementation_comparisons_total'],'report':str(output)},ensure_ascii=False))
    if report['errors']:
        print(json.dumps(report['errors'][:25],ensure_ascii=False,indent=2));return 1
    return 0
if __name__=='__main__':raise SystemExit(main())

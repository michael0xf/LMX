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
BASE_SHA = '4b142bab169cf7cc3fd89766da35b90561f913b68dca3ab1f0725793e4ecb932'
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
        imports=[]
        for line in code.splitlines():
            trimmed=line.strip()
            if re.match(r'(?:import|from|using|use|require)\b',trimmed):imports.append(trimmed)
            # Go imports inside an import(...) group are quoted bare paths.
            elif re.match(r'(?:\w+\s+)?"[^"\n]+"\s*$',trimmed):imports.append(trimmed)
        suspicious=[]
        for line in imports:
            if re.search(r'(?:library_comparisons|PerlComparison|Julia(?:Ordered|Array|Mutation|OrderGroup)Reference|pipecomparison|retrycomparison)',line,re.I):
                suspicious.append(line);continue
            for name in blocked:
                if re.search(r'(?<![\w.])'+re.escape(name)+r'(?=[.\s(;]|$)',line):
                    suspicious.append(line);break
        check(not suspicious,label+': no comparison imports',suspicious)
        import_rows.append({'client':label,'imports':imports,'custom_comparison_imports':suspicious})
    source_defs=production(library)
    catalog=read_json(library/'catalog.json') or []
    additions=read_json(library/'CORE_ADDITIONS_20261123.json') or {'entries':[]}
    names=[x['name'] for x in catalog];name_set=set(names)
    check(len(names)==123 and len(name_set)==123,'core: 123 unique public names',len(names))
    check(all(re.fullmatch(r'[a-z][A-Za-z0-9]*',n) for n in names),'core: lowerCamelCase public names')
    added=additions['entries'];added_names={x['name'] for x in added}
    check(additions.get('baseline_public_count')==115 and len(added)==8 and len(added_names)==8,'core: 115 + 8 additions')
    pub=(library/'src/public.lmx').read_text()
    exports=re.findall(r'^\s+@:\s+([A-Za-z][A-Za-z0-9_]*)\s+([A-Za-z][A-Za-z0-9_]*\\[A-Za-z][A-Za-z0-9_]*)\s*$',pub,re.M)
    export_map=dict(exports)
    check(len(exports)==123 and len(export_map)==123 and set(export_map)==name_set,'core: catalog/export identity')
    check(all(export_map.get(x['name'])==x['api'] for x in catalog),'core: exact callable export targets')
    for entry in catalog:
        check((library/entry['source']).is_file(),'core source: '+entry['name'],entry['source'])
        check(entry['api'].split('\\')[0] in source_defs,'core definition: '+entry['name'],entry['api'])
    for entry in added:
        record=next((x for x in catalog if x['name']==entry['name']),None)
        check(record is not None and record['api']==entry['api'],'addition exported: '+entry['name'])
    baseline_patterns=baseline/'patterns'
    if file(baseline_patterns/'LMX_Fn_Receivers/catalog.json','immutable baseline catalog present'):
        old=read_json(baseline_patterns/'LMX_Fn_Receivers/catalog.json') or []
        old_names={x['name'] for x in old}
        check(len(old_names)==115 and old_names<=name_set and name_set-old_names==added_names,'core: all uploaded 115 identities retained, only eight additions')
    assembled=(library/'LMX_Receivers.lmx').read_text()
    called=set(re.findall(r'\bFxKernel\\+(\w+)\s*\(',assembled))
    check(called==BRIDGES,'core: 19 internal bridges; no extra public name',{'observed':sorted(called),'expected':sorted(BRIDGES)})
    assembly_spec=importlib.util.spec_from_file_location('_packet_assembly',library/'tools/assemble.py')
    module=importlib.util.module_from_spec(assembly_spec);assembly_spec.loader.exec_module(module)
    module.ROOT=library
    check(assembled==module.assembled(),'core: assembly equals current source parts')
    summary['core']={'public_names':len(names),'uploaded_names':115,'additions':len(added),'internal_bridges':len(called),'assembly_sha256':digest(assembled)}

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
                if ident<=90 and language!='LMX':foreign_clients.append((code,f'group/{stem}/{language}'))
            if record.get('kind')=='implementation':implementation_count+=1
        check(set(csv_rows)==set(ids),'group CSV record identity: '+path.parent.name)
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
    summary['extended_patterns']={'groups':groups,'records':len(records),'primaries':primary_count,'implementation_records':implementation_count,'usage_implementation_relations':relations}

    # Immutable original GoF source bodies, not mutable prose/metric rows.
    def gof_primary(path):
        out={};text=path.read_text()
        for tag,body,offset in fences(text):
            if tag not in GOF or GOF[tag] in out:continue
            if '<!-- uncounted-code:' in text[max(0,offset-120):offset]:continue
            out[GOF[tag]]=body
        return out
    gof=[]
    for path in sorted(patterns.glob('[0-9][0-9]_*_comparison.md')):
        base=baseline_patterns/path.name;current=gof_primary(path)
        check(len(current)==8,'GoF: eight primary languages '+path.name)
        before=gof_primary(base) if file(base,'GoF baseline: '+path.name) else {}
        unchanged=current==before
        check(unchanged,'GoF primary preservation: '+path.name)
        gof.append({'file':path.name,'languages':len(current),'unchanged':unchanged,'sha256':{k:digest(v) for k,v in current.items()}})
        for language,code in current.items():
            if language!='LMX':foreign_clients.append((code,'GoF/'+path.name+'/'+language))
    check(len(gof)==23 and sum(x['languages'] for x in gof)==184,'GoF: 23 comparisons / 184 uploaded primary listings')
    summary['gof']={'comparisons':len(gof),'primary_listings':sum(x['languages'] for x in gof),'all_preserved':all(x['unchanged'] for x in gof),'records':gof}

    # The original examples: preserve all identities, allowing requested edits.
    expected=read_json(examples/'expected_results.json') or {'source_examples':[]}
    originals=expected['source_examples'];original_ids={x['id'] for x in originals}
    baseline_ids={x.stem for x in (baseline_patterns/'examples/lmx').glob('*.lm3')}
    current_ids={x.stem for x in (examples/'lmx').glob('*.lm3')}
    check(len(originals)==24 and original_ids==baseline_ids==current_ids,'original examples: uploaded 24 identities retained')
    for e in originals:file(examples/e['file'],'original example source: '+e['id'])
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
    summary['new_suites']=suites
    check(len(originals)+sum(x['clients'] for x in suites.values())==72,'examples: 24 original + 24 Julia + 24 Perl = 72')
    check(len(suites)==2 and all(x['primaries']==48 for x in suites.values()),'new suites: 48 primary listings each')
    for code,label in foreign_clients:no_custom_import(code,label,blocked)
    summary['foreign_import_boundaries']={'clients_checked':len(foreign_clients),'custom_imports_found':sum(bool(x['custom_comparison_imports']) for x in import_rows),'rows':import_rows}
    summary['implementation_comparisons_total']=implementation_count+len(helper_pages)+sum(x['implementation_pairs'] for x in suites.values())

    # Receipts are references only; this validator does not execute a language.
    receipts={}
    for label,path in [('julia_static',examples/'julia_comparison/validation/check_report.json'),('perl_clients',examples/'perl_comparison/validation/client_tests.json'),('perl_implementations',examples/'perl_comparison/validation/implementation_tests.json')]:
        if path.exists():
            receipt=read_json(path) or {}
            receipts[label]={'file':path.relative_to(patterns).as_posix(),'file_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'reported_status':receipt.get('status'),'executed_cases':receipt.get('executed_cases'),'executed_checks':receipt.get('executed_checks'),'provenance':'Existing separate receipt; not executed by this validator.'}
    runtime={'executed_by_this_validator':[],'LMX':'NOT_RUN','Julia':'NOT_RUN','Haskell':'NOT_RUN','Scala':'NOT_RUN','separate_receipts':receipts}
    return {'edition':'2026-11-23','status':'PASS' if not errors else 'FAIL','scope':'Комплектность, идентичность исходников, зеркала публикации и границы импортов; это не разбор, компиляция, runtime или проверка скорости.','source_root':str(spec),'immutable_baseline':str(baseline),'uploaded_archive_sha256':BASE_SHA,'summary':summary,'checks_count':len(checks),'checks':checks,'errors':errors,'warnings':warnings,'runtime':runtime}

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
    print(json.dumps({'status':report['status'],'checks':report['checks_count'],'errors':len(report['errors']),'core':report['summary']['core'],'extended_records':report['summary']['extended_patterns']['records'],'extended_primaries':report['summary']['extended_patterns']['primaries'],'gof_preserved':report['summary']['gof']['all_preserved'],'original_examples':report['summary']['original_examples']['records'],'new_suites':report['summary']['new_suites'],'implementation_comparisons':report['summary']['implementation_comparisons_total'],'report':str(output)},ensure_ascii=False))
    if report['errors']:
        print(json.dumps(report['errors'][:25],ensure_ascii=False,indent=2));return 1
    return 0
if __name__=='__main__':raise SystemExit(main())

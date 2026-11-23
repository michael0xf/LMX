#!/usr/bin/env python3
from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
from rebuild import production, metrics, public_roots, closure
from lmx_style_variants import get_variants, validate_variants

def lmx_checks(text):
    errors=[];stack=[];last=None;quote=None;escaped=False
    for n,line in enumerate(text.splitlines(),1):
        if not line.strip():
            last=None
            continue
        if "\t" in line: errors.append(f"{n}: tab")
        indent=len(line)-len(line.lstrip())
        if indent%4: errors.append(f"{n}: indentation {indent}")
        if last is not None and indent<last-4 and line.strip()!="---" and not line.lstrip().startswith("end:"):
            errors.append(f"{n}: multi-level decrease {last}->{indent} without cutter")
        last=indent
        for c in line:
            if quote:
                if escaped: escaped=False
                elif c=="\\": escaped=True
                elif c==quote: quote=None
            elif c=="#": break
            elif c in "\"'"+chr(96): quote=c
            elif c in "([": stack.append((c,n))
            elif c in ")]":
                if not stack or stack[-1][0]!={")":"(","]":"["}[c]:
                    errors.append(f"{n}: unmatched {c}")
                else: stack.pop()
    if quote: errors.append("unterminated literal")
    if stack: errors.append(f"unclosed brackets {stack}")
    if re.search(r"\bfn\s*:|\bimplements\s*[(:]",text): errors.append("obsolete syntax")
    return errors

def main():
    data=json.loads((ROOT/"examples.json").read_text())
    runtime=subprocess.run(["perl","-MList::Util","-e",'print "$^V / List::Util $List::Util::VERSION"'],capture_output=True,text=True)
    client_rows=[];source_rows=[];failures=[]
    allowed={"strict","warnings","feature","sort","List::Util"}
    for ex in data["examples"]:
        lmx=(ROOT/ex["lmx_file"]).read_text()
        perl=(ROOT/ex["foreign_file"]).read_text()
        errors=lmx_checks(lmx)
        errors.extend(validate_variants(ex,ROOT))
        for style,variant in get_variants(ex):
            errors.extend(style+': '+error for error in lmx_checks(variant["code"]))
        if lmx!=ex["lmx"] or perl!=ex["foreign"]:
            errors.append("rendered source differs from examples.json")
        imports=re.findall(r"^\s*(?:use|require)\s+([A-Za-z_:]\w*(?:::\w+)*)",perl,re.M)
        if any(x not in allowed for x in imports):
            errors.append("client imports custom comparison helper: "+str(imports))
        compiled=subprocess.run(["perl","-c",str(ROOT/ex["foreign_file"])],capture_output=True,text=True)
        if compiled.returncode: errors.append("Perl syntax: "+compiled.stderr.strip())
        request={"file":str(ROOT/ex["foreign_file"]),"cases":ex["test_cases"]}
        run=subprocess.run(["perl",str(ROOT/"tools/run_case.pl")],input=json.dumps(request),capture_output=True,text=True)
        outcomes=[]
        if run.returncode: errors.append("Perl invocation: "+run.stderr.strip())
        else:
            for i,(case,answer) in enumerate(zip(ex["test_cases"],json.loads(run.stdout)),1):
                passed=answer["ok"] and answer["result"]==case["expected"] and (ex.get("input_mutation") or answer["input_unchanged"])
                outcomes.append({"case":i,"args":case["args"],"expected":case["expected"],"actual":answer["result"],"input_unchanged":answer["input_unchanged"],"status":"PASS" if passed else "FAIL","error":answer["error"]})
                if not passed: failures.append(f"{ex['id']} fixture {i}")
        source_rows.append({"id":ex["id"],"lmx_status":"NOT_RUN","limited_source_status":"PASS" if not errors else "FAIL","errors":errors,"perl_imports":imports,"lmx_sha256":hashlib.sha256(lmx.encode()).hexdigest(),"lmx_variants":{style:{"source":variant["source_file"],"sha256":variant["metrics"]["sha256"]} for style,variant in get_variants(ex)},"foreign_sha256":hashlib.sha256(perl.encode()).hexdigest()})
        client_rows.append({"id":ex["id"],"syntax":"PASS" if not compiled.returncode else "FAIL","cases":outcomes})
        failures.extend(f"{ex['id']}: {e}" for e in errors)
    available=production(); aliases=public_roots(available)
    dependencies=json.loads((ROOT/"validation/implementation_dependencies.json").read_text())
    current_stats=json.loads((ROOT/"statistics.json").read_text())
    by_stats={(r['id'],r['language']):r for r in current_stats['rows']}
    by_style={(r['id'],r['style']):r for r in current_stats['comparison_rows']}
    dependency_checks=[]
    for definition in dependencies['definitions']:
        name=definition['name']
        okay=name in available and hashlib.sha256(available[name]['code'].encode()).hexdigest()==definition['sha256']
        if not okay:failures.append('shared production source drift: '+name)
        dependency_checks.append({'name':name,'status':'PASS' if okay else 'FAIL'})
    for ex in data['examples']:
        aliases=public_roots(available,ex.get('core_families'))
        for style,variant in get_variants(ex):
            row=by_style.get((ex['id'],style),{})
            for field,value in variant['metrics'].items():
                if row.get(field)!=value:failures.append(ex['id']+': '+style+' stale full-source metric '+field)
        for name, source in ex['core_sources'].items():
            if aliases.get(name)!=source['root']:failures.append(ex['id']+': wrong canonical source '+name)
            if source['root'] not in available:failures.append(ex['id']+': missing canonical source '+name)
        for alt in ex.get('alternatives',[]):
            if alt['language']=='LMX':
                failures.extend(ex['id']+' alternative: '+error for error in lmx_checks(alt['code']))
                if metrics(alt['code'])['nonwhitespace']<metrics(ex['lmx'])['nonwhitespace']:
                    failures.append(ex['id']+': shorter complete alternative was not selected')
    md_entries=[]
    for item in data['examples']+data['implementations']:
        folder=ROOT/'library_comparisons' if item['id'].startswith('PI') else ROOT
        md=(folder/(item['id']+'_comparision.md')).read_text()
        md_ok=all('```'+language+'\n'+item[key]+'```' in md for language,key in [('lmx','lmx'),('perl','foreign')])
        if 'lmx_variants' in item:
            md_ok=md_ok and all('```lmx\n'+variant['code']+'```' in md for _,variant in get_variants(item))
        if not md_ok:failures.append(item['id']+': Markdown source block mismatch')
        md_entries.append({'id':item['id'],'json_md_source_statistics':'PASS' if md_ok else 'FAIL'})
        for language,key in [('LMX','lmx'),('Perl','foreign')]:
            for field,value in metrics(item[key]).items():
                if by_stats[item['id'],language][field]!=value:failures.append(item['id']+': stale metric '+field)
    primary={name for item in data['implementations'] for source in item.get('lmx_extract',[]) for name in source['roots']}
    all_names={row['name'] for row in dependencies['definitions']}
    shared_names=all_names-primary
    expected_shared='\n'.join(available[name]['code'] for name in sorted(shared_names))
    actual_shared=(ROOT/'library_comparisons/shared_dependencies.lmx').read_text()
    if actual_shared!=expected_shared:failures.append('shared dependencies source is stale')
    failures.extend('shared dependencies: '+error for error in lmx_checks(actual_shared))
    shared_report={'status':'PASS' if not failures else 'FAIL','checks':dependency_checks,'unique_definitions':len(all_names),'unpaired_functions':dependencies['unpaired_functions'],'shared_source_matches':actual_shared==expected_shared,'runtime':'NOT_RUN'}
    (ROOT/'validation/dependency_source_checks.json').write_text(json.dumps(shared_report,ensure_ascii=False,indent=2)+'\n')
    coverage=json.loads((ROOT/"validation/library_coverage.json").read_text())
    failures.extend("uncovered core: "+n for n in coverage["missing"])
    implementation_sources=[]
    for impl in data["implementations"]:
        path=ROOT/impl["foreign_file"]
        parsed=subprocess.run(["perl","-c",str(path)],capture_output=True,text=True)
        text_errors=lmx_checks((ROOT/impl["lmx_file"]).read_text())
        if (ROOT/impl["lmx_file"]).read_text()!=impl["lmx"] or path.read_text()!=impl["foreign"]:
            text_errors.append("implementation source differs from examples.json")
        hashes=all(hashlib.sha256((ROOT.parents[2]/source["file"]).read_bytes()).hexdigest()==source["file_sha256"] for source in impl["canonical_sources"])
        if parsed.returncode: failures.append(impl["id"]+": Perl syntax")
        if text_errors: failures.extend(impl["id"]+": "+s for s in text_errors)
        if not hashes: failures.append(impl["id"]+": stale canonical extraction; rebuild required")
        implementation_sources.append({"id":impl["id"],"perl_syntax":"PASS" if not parsed.returncode else "FAIL","perl_diagnostic":parsed.stderr.strip(),"lmx_text_errors":text_errors,"canonical_hashes_match":hashes,"lmx_execution":"NOT_RUN"})
    (ROOT/"validation/implementation_source_checks.json").write_text(json.dumps(implementation_sources,ensure_ascii=False,indent=2)+"\n")
    implementation_run=subprocess.run(["perl",str(ROOT/"tools/test_implementations.pl")],capture_output=True,text=True,timeout=30)
    implementation_checks=0
    try:
        summary=json.loads(implementation_run.stdout)
        implementation_checks=summary["checks"]
        if implementation_run.returncode or summary["status"]!="PASS":
            failures.append("implementation execution failed: "+implementation_run.stdout.strip())
    except (ValueError,KeyError):
        failures.append("implementation harness did not produce its completion report")
    if implementation_run.stderr:
        failures.append("implementation diagnostics: "+implementation_run.stderr.strip())
    result={"runtime":runtime.stdout,"status":"PASS" if not failures else "FAIL","executed_cases":sum(len(r["cases"]) for r in client_rows),"implementation_executed_checks":implementation_checks,"clients":client_rows,"failures":failures,"lmx":"NOT_RUN"}
    (ROOT/"validation/final_consistency.json").write_text(json.dumps({"status":result["status"],"checked_comparisons":len(md_entries),"checked_primary_source_files":len(md_entries)*2,"shared_source_files":1,"entries":md_entries,"dependency_definitions_checked":len(all_names),"errors":failures,"review":"Current canonical roots, source/JSON/MD/count consistency, named end syntax, complete alternative selection and transitive shared dependencies checked. LMX binding/types/lifetime remain runtime acceptance requirements.","lmx_execution":"NOT_RUN"},ensure_ascii=False,indent=2)+"\n")
    (ROOT/"validation/client_tests.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n")
    (ROOT/"validation/source_checks.json").write_text(json.dumps({"scope":"Brackets, indentation, fences/named end cutters, obsolete forms, source equality, allowed client imports; not full parsing/name/type/runtime proof.","lmx_runtime_executed":False,"rows":source_rows},ensure_ascii=False,indent=2)+"\n")
    print(json.dumps({"runtime":runtime.stdout,"cases":result["executed_cases"],"implementation_checks":implementation_checks,"status":result["status"],"failures":failures},ensure_ascii=False))
    return bool(failures)

if __name__=="__main__":
    sys.exit(main())

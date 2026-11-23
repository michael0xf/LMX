#!/usr/bin/env python3
"""Ограниченная текстовая проверка и независимый oracle ожиданий; не runtime."""
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import copy, hashlib, json, re, shutil
from functools import reduce
from rebuild import metrics, production, closure, COMPONENTS, R
from lmx_style_variants import get_variants, validate_variants

def check_lmx(path):
    errors=[];stack=[];quote=None;escaped=False;last=None
    for number,line in enumerate(path.read_text().splitlines(),1):
        if '\t' in line:errors.append(f'{number}: tab indentation')
        if not line.strip():
            last=None;continue
        body=[];i=0
        while i<len(line):
            char=line[i]
            if quote:
                if escaped:escaped=False
                elif char=='\\' and quote!='`':escaped=True
                elif char==quote:
                    if quote=='`' and i+1<len(line) and line[i+1]=='`':i+=1
                    else:quote=None
                body.append(' ')
            elif char=='#':break
            elif char in ('"',"'",'`'):
                quote=char;body.append(' ')
            else:
                body.append(char)
                if char in '([{':stack.append((char,number))
                elif char in ')]}':
                    if not stack or stack[-1][0]!={')':'(',']':'[','}':'{'}[char]:errors.append(f'{number}: unmatched {char}')
                    else:stack.pop()
            i+=1
        code=''.join(body).rstrip()
        if not code.strip():continue
        indent=len(line)-len(line.lstrip())
        if indent%4:errors.append(f'{number}: indentation {indent}')
        if last and indent<last[0]-4 and code.strip()!='---' and not code.lstrip().startswith('end:'):errors.append(f'{number}: multi-level decrease {last[0]}->{indent} without cutter')
        last=(indent,number)
    if stack:errors.append('unclosed brackets '+repr(stack))
    if quote:errors.append('unclosed literal '+quote)
    return errors

def logical(ident,a):
    if ident=='J01':
        if a[2]==0:raise ValueError('zero_step')
        return list(range(*a))
    if ident=='J02':
        xs,lo,hi=a
        if not 0<=lo<=hi<=len(xs):raise ValueError('bounds')
        return xs[lo:hi]
    if ident=='J03':return a[0][::-1]
    if ident=='J04':
        if len(a[0])!=len(a[1]):raise ValueError('shape')
        return [x for x,m in zip(*a) if m!=0]
    if ident=='J05':return [x*x for x in a[0]]
    if ident=='J06':return [x for x in a[0] if x%2!=0]
    if ident=='J07':return reduce(lambda x,y:x-y,a[0],a[1])
    if ident=='J08':
        out=[a[1]]
        for x in a[0]:out.append(out[-1]+x)
        return out
    if ident=='J09':return [list(p) for p in zip(*a)]
    if ident=='J10':
        assert len(a[0])==len(a[1])
        return [2*x+y*y for x,y in zip(*a)]
    if ident=='J11':return [y for x in a[0] for y in (x,x*x)]
    if ident=='J12':
        out={}
        for x in a[0]:out.setdefault('true' if x%2 else 'false',[]).append(x)
        return out
    if ident=='J13':return any(x>a[1] for x in a[0])
    if ident=='J14':return all(x>0 for x in a[0])
    if ident=='J15':
        for i,x in enumerate(a[0]):
            if x>a[1]:return {'present':True,'value':i}
        return {'present':False}
    if ident=='J16':return sum(x%2==0 for x in a[0])
    if ident=='J17':
        a[0].extend(a[1]);return {'returned':a[0],'target':a[0],'same_target':True}
    if ident=='J18':
        target,lo,hi,values=a
        if not 0<=lo<=hi<=len(target):raise ValueError('bounds')
        removed=target[lo:hi];target[lo:hi]=values
        return {'removed':removed,'target':target}
    if ident=='J19':return [list(column) for column in zip(*a[0])]
    if ident=='J20':return sorted(a[0],key=lambda x:x['key'])
    if ident=='J21':return list(dict.fromkeys(a[0]))
    if ident=='J22':return ''.join(c for c in a[0] if '0'<=c<='9')
    if ident=='J23':return [value for part in a[0] for value in part]
    if ident=='J24':return [[x,y] for x in a[0] for y in a[1]]
    raise AssertionError(ident)

def main():
    data=json.loads((R/'examples.json').read_text());errors=[];checks=[];expectations=[]
    assert len(data['examples'])==24 and len(data['implementations'])==4
    current=production()
    stats=json.loads((R/'statistics.json').read_text());by_stats={(x['id'],x['language']):x for x in stats['rows']}
    by_style={(x['id'],x['style']):x for x in stats['comparison_rows']}
    for item in data['examples']+data['implementations']:
        for language,key in [('LMX','lmx'),('Julia','foreign')]:
            path=R/item['source_files'][key]
            if path.read_text()!=item[key]:errors.append(item['id']+' source mismatch '+language)
            for metric,value in metrics(item[key]).items():
                if by_stats[item['id'],language][metric]!=value:errors.append(item['id']+' metric mismatch '+metric)
            checks.append({'id':item['id'],'language':language,'check':'source_json_statistics_equal','status':'PASS'})
        if 'production_definitions' in item:
            for owner in item['production_definitions']:
                if hashlib.sha256(current[owner['name']]['code'].encode()).hexdigest()!=owner['sha256']:errors.append('Production source drift '+owner['name'])
        else:
            errors.extend(item['id']+': '+error for error in validate_variants(item,R))
            markdown=(R/(item['id']+'_comparision.md')).read_text()
            for style,variant in get_variants(item):
                row=by_style.get((item['id'],style),{})
                for metric,value in variant['metrics'].items():
                    if row.get(metric)!=value:errors.append(item['id']+': '+style+' full-source statistic '+metric)
                if '```lmx\n'+variant['code']+'```' not in markdown:
                    errors.append(item['id']+': '+style+' Markdown source mismatch')
                checks.append({'id':item['id'],'style':style,'source':variant['source_file'],
                               'check':'paired_source_json_md_metrics','runtime_execution':'NOT_RUN',
                               'status':'PASS'})
            for name in item['core_functions']:
                if not (R/item['implementation_links'][name]).is_file():errors.append(item['id']+' uncovered core '+name)
            if re.search(r'Julia(?:Ordered|Array|Mutation|OrderGroup)Reference|include\(|library_comparisons',item['foreign']):errors.append(item['id']+' custom library imported by client')
            if item['alternatives']:errors.append(item['id']+' unreviewed alternative')
            cases=[{'inputs':list(item['inputs'].values()),'expected':item['expected']}]+item['semantic_cases']
            for number,case in enumerate(cases):
                try:
                    observed=logical(item['id'],copy.deepcopy(case['inputs']))
                    okay='error' not in case and observed==case['expected']
                except ValueError as err:
                    observed={'error':str(err)};okay=str(err)==case.get('error')
                if not okay:errors.append(item['id']+' expectation mismatch '+str(number))
                expectations.append({'example':item['id'],'case':number,'status':'PASS' if okay else 'FAIL','observed':observed})
    dep_report=json.loads((R/'validation/implementation_dependencies.json').read_text())
    for definition in dep_report['definitions']:
        name=definition['name']
        if name not in current or hashlib.sha256(current[name]['code'].encode()).hexdigest()!=definition['sha256']:
            errors.append('Shared production source drift '+name)
    lmx_paths=list((R/'source/lmx').rglob('*.lm3'))+list((R/'library_comparisons').glob('*.lmx'))
    for path in sorted(lmx_paths):
        found=check_lmx(path)
        errors.extend(str(path.relative_to(R))+': '+x for x in found)
        checks.append({'source':path.relative_to(R).as_posix(),'check':'literal_bracket_indent_cutter','status':'FAIL' if found else 'PASS','errors':found})
    cases_json=json.loads((R/'validation/semantic_cases.json').read_text())
    if len(cases_json['cases'])!=len(expectations):errors.append('Cases count mismatch')
    # Check concrete local links. Root is responsible for these pending PDFs/XLSX.
    pending={'LMX_Comparison_Julia.pdf','LMX_Comparison_Julia.xlsx','../STATISTICS.md'}
    for path in R.rglob('*.md'):
        text=path.read_text()
        for target in re.findall(r'\]\(([^)]+)\)',text):
            if '://' in target or target.startswith('#'):continue
            plain=target.split('#')[0]
            if path==R/'README.md' and plain in pending:continue
            if not (path.parent/plain).exists():errors.append(str(path.relative_to(R))+': missing local link '+plain)
    report={'status':'FAIL' if errors else 'PASS','edition':'2026-11-23','scope':'Static source/metrics/provenance checks plus Python logical expectation oracle; not Julia/LMX execution.','checks':checks,'errors':errors,'logical_cases_checked':len(expectations),'lmx_source_files_checked':len(lmx_paths),'julia_executable':shutil.which('julia'),'julia_execution':'NOT_RUN','lmx_execution':'NOT_RUN'}
    (R/'validation/check_report.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    (R/'validation/python_expectation_check.json').write_text(json.dumps({'status':'PASS' if all(x['status']=='PASS' for x in expectations) else 'FAIL','kind':'logical expectations in Python, not language execution','cases':expectations},ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'status':report['status'],'checks':len(checks),'cases':len(expectations),'errors':errors},ensure_ascii=False))
    if errors:raise SystemExit(1)
if __name__=='__main__':main()

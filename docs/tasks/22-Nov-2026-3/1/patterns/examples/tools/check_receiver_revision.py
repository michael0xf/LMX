#!/usr/bin/env python3
"""Check same-core alternatives, fair minimum, guide identity and exact counts."""
from pathlib import Path
import hashlib,json,re
ROOT=Path(__file__).resolve().parents[2]
EX=ROOT/'examples'
BEGIN='# BEGIN ALTERNATIVE LMX (excluded from character counts)'
END='# END ALTERNATIVE LMX'
def canonical(t):return t.strip()+'\n'
def metric(t):
 t=canonical(t)
 return {'characters':sum(not c.isspace() for c in t),'nonblank_lines':sum(bool(x.strip()) for x in t.splitlines()),'utf8_bytes':len(t.encode()),'sha256':hashlib.sha256(t.encode()).hexdigest()}
def main():
 errors=[]
 def check(ok,msg):
  if not ok:errors.append(msg)
 registry=json.loads((EX/'variants.json').read_text());variants={r['id']:r for r in registry['records']}
 counts=json.loads((EX/'validation/functional_receiver_counts.json').read_text());guide=(ROOT/'LMX_examples_and_analogies.ru.md').read_text()
 expectations=json.loads((EX/'expected_results.json').read_text());cases={r['id']:r for r in expectations['source_examples']}
 checked=[]
 for row in counts['rows']:
  ident=row['id'];text=(EX/row['file']).read_text();primary=canonical(text.split(BEGIN)[0])
  check(metric(primary)==row['after'],ident+': primary metric mismatch')
  main=re.search(r'<!-- example: '+re.escape(ident)+r' -->\s*```lmx\n(.*?)\n```',guide,re.S)
  check(main is not None,ident+': guide primary missing')
  if main:check(canonical(main.group(1))==primary,ident+': guide primary differs')
  if ident in variants:
   r=variants[ident];v={x['id']:x for x in r['variants']};selected=v[r['selected']];other=v[r['alternative']]
   eligible=[x for x in r['variants'] if x['correct_for_scenario'] and x['id'] in r['eligible_variants']]
   best=min(eligible,key=lambda x:(metric(x['code'])['characters'],x['id']!='original'))
   check(best['id']==selected['id'],ident+': selected primary is not the shortest fair correct variant')
   check(bool(r['fairness_note']),ident+': missing fairness explanation')
   check(primary==canonical(selected['code']),ident+': selected source mismatch')
   check(text.count(BEGIN)==1 and text.count(END)==1,ident+': alternative markers not unique')
   lines=text.split(BEGIN+'\n',1)[1].split(END,1)[0].splitlines()
   check(all(x.startswith('# ') for x in lines),ident+': uncommented alternative source')
   restored='\n'.join(x[2:] for x in lines[1:])+'\n'
   check(canonical(restored)==canonical(other['code']),ident+': alternative algorithm differs')
   alt=re.search(r'<!-- alternative-example: '+ident+r' -->\s*```lmx\n(.*?)\n```',guide,re.S)
   check(alt is not None,ident+': guide alternative missing')
   if alt:check(canonical(alt.group(1))==canonical(other['code']),ident+': guide alternative differs')
   for x in r['variants']:
    check('        import: fun' not in x['code'],ident+': current core receiver still requires import')
    check(not re.search(r'(?m)^\s*fn:',x['code']),ident+': obsolete named declaration')
    check(set(x['load_before']) <= set(r.get('allowed_user_helpers',[])),ident+': undeclared user-helper or alternate core dependency retained')
   check(cases[ident].get('selected_variant')==selected['id'],ident+': expected cases selected variant mismatch')
   check(cases[ident].get('core_versions')==1,ident+': current-core scope missing')
  source_record=selected if ident in variants else cases[ident]
  if source_record.get('embedded_helpers'):
   historical=source_record['historical_client']
   check(metric(historical['code'])==historical['metrics'],ident+': preserved client metrics differ')
   helper_sources=[]
   for helper in source_record['embedded_helpers']:
    helper_code=canonical((EX/helper['source']).read_text())
    check(metric(helper_code)==helper['metrics'],ident+': embedded helper source changed')
    helper_sources.append(helper_code.rstrip())
   complete='\n\n'.join(helper_sources+[canonical(historical['code']).rstrip()])+'\n'
   check(primary==complete,ident+': complete listing is not exact helper prefix plus preserved client')
   check(not cases[ident].get('load_before'),ident+': embedded helper still loaded separately')
  checked.append({'id':ident,'primary':metric(primary),'selected':row.get('selected_variant','single_existing'),'has_alternative':ident in variants})
 check((EX/'libraries/haskell/Partial.hs').read_bytes()==(ROOT/'09_functional_computation/examples/haskell/099_integer_partial_application_implementation.hs').read_bytes(),'Partial.hs differs from generic099')
 report={'format':'examples-receiver-revision-v2','date':'2026-11-22','status':'PASS' if not errors else 'FAIL','scope':'One-core semantic alternatives, shortest fair primary, exact source identity and counts. No parser or runtime execution.','core_versions':1,'runtime':{'lmx_executed':False,'haskell_executed':False},'source_count':len(checked),'paired_ids':list(variants),'selected':{k:v['selected'] for k,v in variants.items()},'checks':checked,'error_count':len(errors),'errors':errors,'counts_report':'functional_receiver_counts.json','library_counts_report':'receiver_library_counts.json'}
 (EX/'validation/receiver_revision.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'status':report['status'],'checked':len(checked),'errors':errors},ensure_ascii=False));return bool(errors)
if __name__=='__main__':raise SystemExit(main())

"""Add finite declared effect closures to ordinary library helpers.
Does not invent dynamic throws:* and is not a semantic LMX analysis.
Generated bodies have their separate computed target failure contract.
"""
from pathlib import Path
import re,json
R=Path(__file__).resolve().parents[1]
FILES=[p for p in (R/'src').glob('*.lmx') if p.name not in {'public.lmx','kernel_contracts.lmx'}]+list((R/'examples').glob('*.lmx'))
records={}; contents={}
DYNAMIC_SEEDS={'FxCaptureOne\\capture':{'FxRecordArity'}}
def clean(s):
 return re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|`(?:``|[^`])*`|#[^\n]*',lambda m:' '*len(m.group()),s)
for p in FILES:
 lines=p.read_text().splitlines();contents[p]=lines;roots=[]
 for i,line in enumerate(lines):
  m=re.match(r'^(?:independent:\s*)?([A-Za-z_]\w*):\s*$',line)
  if m:roots.append((i,m.group(1)))
 roots.append((len(lines),''))
 for (start,root),(end,_) in zip(roots,roots[1:]):
  for j in range(start+1,end):
   m=re.match(r'^    ([A-Za-z_]\w*):\s*$',lines[j])
   if not m or m.group(1) in {'private','return','required','const','immutable','independent','throws'}:continue
   stop=j+1
   while stop<end and (not lines[stop].strip() or lines[stop].startswith('        ') or lines[stop].lstrip().startswith('#')):stop+=1
   block='\n'.join(lines[j+1:stop]);c=clean(block)
   if not re.search(r'\breturn\b|\bthrow:|\b[A-Za-z_]\w*\\\w+\s*\(|:=|\+=|-=|\*=|/=',c):continue
   body=lines[j+1:stop];out=[];k=0
   while k<len(body):
    if body[k].startswith('        throws:'):
     k+=1
     while k<len(body) and (body[k].startswith('            ') or not body[k].strip()):k+=1
    else:out.append(body[k]);k+=1
   text='\n'.join(out);code=clean(text)
   own=set(re.findall(r'\bthrow:\s*(\w+)\s*\(',code))
   edges=set(re.findall(r'\b((?:Fx|Rx)\w+\\\w+)\s*\(',code))
   edges |= set(re.findall(r'\b((?:Fx|Rx)\w+\\\w+)\s*\)',code))
   own |= DYNAMIC_SEEDS.get(root+'\\'+m.group(1),set())
   if any(x.startswith('FxKernel\\') for x in edges):own|={'FxTypeToken','FxKernelFailure'}
   records[root+'\\'+m.group(1)]={'p':p,'start':j+1,'stop':stop,'body':out,'own':own,'edges':edges,'effects':set(own)}
for _ in range(len(records)+1):
 changed=False
 for a in records.values():
  before=len(a['effects'])
  for e in a['edges']:
   if e in records:a['effects']|=records[e]['effects']
  changed|=len(a['effects'])!=before
 if not changed:break
# Direct generated-call invocations in probes can raise constructor/stage errors.
# Preserve these explicit fixture contracts separately from ordinary call-graph edges.
for key,a in records.items():
 if a['p'].parent.name=='examples':
  a['effects']|={'FxIndex','FxArity','FxRecordArity','FxTypeToken','FxKernelFailure'}
  if a['p'].name in {'value_generic_examples.lmx','run_all.lmx'}:a['effects']|={'FxLazyCycle'}
for p,lines in contents.items():
 for a in sorted([a for a in records.values() if a['p']==p],key=lambda a:a['start'],reverse=True):
  decl=[]
  if a['effects']:
   decl=['        throws:']+['            '+x for x in sorted(a['effects'])]
  lines[a['start']:a['stop']]=decl+a['body']
 p.write_text('\n'.join(lines)+'\n')
report={k:sorted(a['effects']) for k,a in sorted(records.items())}
(R/'tests/effect_contracts.json').write_text(json.dumps(report,indent=2)+'\n')
print('helpers',len(records),'with finite effects',sum(bool(a['effects']) for a in records.values()))

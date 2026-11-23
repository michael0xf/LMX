#!/usr/bin/env python3
"""Migrate the previous publication's type spellings; never execute LMX.
The whitelist is deliberately limited to forms present in that publication.
Do not rewrite the root change specifications' historical before/after tables.
"""
from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parents[2]
OWNED={'generic_functions.lmx','generic_runtime.lmx','generic_wrappers.lmx','generic_combinators.lmx','kernel_contracts.lmx','fn_operand.lmx','reflection_bridges.lmx','collections.lmx','API.md','GENERIC_IMPLEMENTATION.md','KERNEL_REQUIREMENTS.md','ACCEPTANCE.md'}
EXT={'.md','.lmx','.lm3','.json','.py','.mjs','.csv'}

def migrate(s):
    s=s.replace('new_parts/','patterns/').replace('new_parts\\\\','patterns\\\\')
    # Result specifications consume a type code, not a new declaration.
    s=re.sub(r'(return:\s*)\[\]\s*:\s*@\(int\)',r'\1int@[]',s)
    s=re.sub(r'(return:\s*)\[\]\s*:\s*(char|int|@)(?=\s|[;),`]|$)',lambda m:m.group(1)+m.group(2)+'[]',s)
    s=re.sub(r'\[\]\s*:\s*@\(int\)', 'int@[]:', s)
    s=re.sub(r'\[\]\s*:\s*(char|int|@)(?=\s|[;),`]|$)',lambda m:m.group(1)+'[]:',s)
    # Anonymous empty typed construction and a named empty initializer.
    s=re.sub(r'((?:char|int|@)\[\]:\s+[A-Za-z_]\w*\s+)\(\)',r'\1[]',s)
    # Existing compact address examples contain explicit paths, not names.
    s=re.sub(r'@\(((?:[A-Za-z_]\w*\\+)+[A-Za-z_]\w*)\)',r'(@\1)',s)
    s=s.replace('[]:int','int[]').replace('[]: int by language contract','int[] by language contract')
    return s

def walk(v):
    if isinstance(v,str):return migrate(v)
    if isinstance(v,list):return [walk(x) for x in v]
    if isinstance(v,dict):return {k:walk(x) for k,x in v.items()}
    return v

def main():
 changes=[]
 for p in ROOT.rglob('*'):
  if not p.is_file() or p.suffix not in EXT or p.resolve()==Path(__file__).resolve():continue
  rel=p.relative_to(ROOT).as_posix()
  if '/reference/' in rel or '/regex/' in rel or p.name.startswith('sequences'):continue
  if 'LMX_Fn_Receivers' in rel and p.name in OWNED:continue
  if rel.endswith('LMX_Receivers.lmx') or '/validation/' in rel or '/tests/' in rel:continue
  old=p.read_text(encoding='utf-8-sig')
  if p.suffix=='.json':
   try: new=json.dumps(walk(json.loads(old)),ensure_ascii=False,indent=2)+'\n'
   except json.JSONDecodeError:new=migrate(old)
  else:new=migrate(old)
  if new!=old:p.write_text(new);changes.append(rel)
 out=ROOT/'patterns/validation/postfix_migration.json'
 out.write_text(json.dumps({'status':'source_migration_only','files_changed':changes,'excluded':'Concurrent implementation owners and explicitly historical references; integrated later.','runtime_executed':False},ensure_ascii=False,indent=2)+'\n')
 print(json.dumps({'files_changed':len(changes)}))
if __name__=='__main__':main()

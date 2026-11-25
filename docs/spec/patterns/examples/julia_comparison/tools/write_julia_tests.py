#!/usr/bin/env python3
"""Стенд из согласованных JSON cases; генерация не запускает Julia."""
from pathlib import Path
import json
R=Path(__file__).resolve().parents[1]
def literal(value, records=False):
    if value is None:return 'nothing'
    if value is True:return 'true'
    if value is False:return 'false'
    if isinstance(value,(int,float)):return repr(value)
    if isinstance(value,str):return json.dumps(value,ensure_ascii=False)
    if isinstance(value,list):return ('['+', '.join(literal(x,records) for x in value)+']') if value else 'Int[]'
    if isinstance(value,dict):
        if records and set(value)=={'key','id'}:
            return '(key='+literal(value['key'])+', id='+literal(value['id'])+')'
        return 'Dict{String,Any}('+', '.join(literal(k)+'=>'+literal(v,records) for k,v in value.items())+')'
    raise ValueError(value)
def main():
 d=json.loads((R/'examples.json').read_text());lines=['using Test','',
 'const SUITE = normpath(joinpath(@__DIR__, ".."))',
 'function loadClient(id)',
 '    namespace = Module(Symbol("Client" * id))',
 '    Base.include(namespace, joinpath(SUITE, "source", "julia", id * ".jl"))',
 '    getfield(namespace, :example)',
 'end',
 'function observe(id, value, args)',
 '    if id == "J24"',
 '        return [collect(pair) for pair in value]',
 '    elseif id == "J12"',
 '        return Dict{String,Any}((key ? "true" : "false") => value[key] for key in keys(value))',
 '    elseif id == "J15"',
 '        return isnothing(value) ? Dict{String,Any}("present"=>false) : Dict{String,Any}("present"=>true, "value"=>value)',
 '    elseif id == "J17"',
 '        return Dict{String,Any}("returned"=>value, "target"=>args[1], "same_target"=>value === args[1])',
 '    elseif id == "J18"',
 '        return Dict{String,Any}("removed"=>value, "target"=>args[1])',
 '    elseif id == "J20"',
 '        return [Dict{String,Any}("key"=>x.key, "id"=>x.id) for x in value]',
 '    end',
 '    value',
 'end','']
 total=0
 for e in d['examples']:
  lines+=['@testset "'+e['id']+'" begin','    call = loadClient("'+e['id']+'")']
  cases=[{'inputs':list(e['inputs'].values()),'expected':e['expected']}]+e['semantic_cases']
  for n,c in enumerate(cases):
   args=c['inputs'];parts=[literal(x,e['id']=='J20') for x in args]
   if e['id']=='J19':
    rows=args[0];matrix='['+'; '.join(' '.join(str(x) for x in row) for row in rows)+']' if rows else 'Matrix{Int}(undef, 0, 0)'
    if len(rows)==1 and len(rows[0])==1:matrix='reshape(['+str(rows[0][0])+'], 1, 1)'
    parts=[matrix]+parts[1:]
   argtuple='('+', '.join(parts)+(',' if len(parts)==1 else '')+')'
   lines+=['    # Случай '+str(n)+': подготовка и assertions вне сравниваемого кода.','    args = '+argtuple,'    before = deepcopy(args)']
   if 'error' in c:
    kind={'bounds':'BoundsError','shape':'DimensionMismatch','zero_step':'ArgumentError'}[c['error']]
    lines+=['    @test_throws '+kind+' Base.invokelatest(call, args...)','    @test args == before']
   else:
    lines+=['    value = Base.invokelatest(call, args...)','    @test observe("'+e['id']+'", value, args) == '+literal(c['expected'])]
    if e['id'] not in ('J17','J18'):lines+=['    @test args == before']
    if e['id'] in ('J02','J03','J20'):lines+=['    @test value !== args[1]']
    if e['id']=='J18':lines+=['    @test value !== args[1]']
   total+=1
  lines+=['end','']
 (R/'validation/run_clients.jl').write_text('\n'.join(lines)+'\n')
 print('Prepared Julia client cases:',total)
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Publish both complete LMX client styles and one shared implementation set."""
from pathlib import Path
import sys
sys.dont_write_bytecode=True
import csv, hashlib, io, json
ROOT=Path(__file__).resolve().parents[1]
PATTERNS=ROOT.parents[1]
sys.path.insert(0,str(PATTERNS/'tools'))
from lmx_style_variants import attach_variants, validate_variants, markdown_variants, STYLES
from lmx_execution_contract import apply_execution_contract, ensure_startup_note
EDITION='2026-11-25-workflows'
FENCE='`'*3

def normalized(text):
    return text.replace('\r\n','\n').replace('\r','\n').strip()+'\n'

def metrics(text):
    text=normalized(text)
    return {'characters_nonwhitespace':sum(not c.isspace() for c in text),
        'characters_all':len(text),'nonblank_lines':sum(bool(x.strip()) for x in text.splitlines()),
        'utf8_bytes':len(text.encode()),'sha256':hashlib.sha256(text.encode()).hexdigest()}

def write(relative,text):
    p=(ROOT/relative).resolve()
    if not p.is_relative_to(ROOT):raise ValueError('Output escapes comparison directory: '+str(relative))
    p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text,encoding='utf-8',newline='\n')

def write_json(relative,data):write(relative,json.dumps(data,ensure_ascii=False,indent=2)+'\n')

def code_block(language,code):return f'{FENCE}{language}\n{normalized(code)}{FENCE}\n'

def source_code(relative):
    p=(ROOT/relative).resolve()
    if not p.is_relative_to(ROOT):raise ValueError('Source escapes comparison directory: '+str(relative))
    return normalized(p.read_text())

def source_list(values):
    return '\n'.join('- <'+x+'>' if isinstance(x,str) else '- ['+x.get('title',x['url'])+']('+x['url']+')' for x in values)+'\n'

def as_paragraphs(value):
    if not value:return ''
    if isinstance(value,str):return value+'\n'
    if isinstance(value,list):return '\n\n'.join(as_paragraphs(x).rstrip() for x in value)+'\n'
    return code_block('json',json.dumps(value,ensure_ascii=False,indent=2))

def count_table(*pairs):
    lines=['| Источник | Без пробельных | Все символы | Непустые строки |','| --- | ---: | ---: | ---: |']
    for label,m in pairs:lines.append(f"| {label} | {m['characters_nonwhitespace']} | {m['characters_all']} | {m['nonblank_lines']} |")
    return '\n'.join(lines)+'\n'

def total(rows,language):
    return {k:sum(row[language][k] for row in rows) for k in ['characters_nonwhitespace','characters_all','nonblank_lines','utf8_bytes']}

def main():
    data=apply_execution_contract(json.loads((ROOT/'examples.json').read_text()))
    data['edition']=EDITION
    data['metrics_status']='current'
    impl_data=json.loads((ROOT/'implementation_data.json').read_text())
    implementations=impl_data['implementations']
    catalog={x['name']:x for x in json.loads((PATTERNS/'LMX_Fn_Receivers/catalog.json').read_text())}
    coverage={}
    for item in implementations:
        for name in item['core_functions']:coverage.setdefault(name,[]).append(item['id'])
    rows=[]; alternatives=[]; inventory=[]
    for entry in data['examples']:
        entry['metrics_status']='current'
        if entry.get('contract_revision'):
            entry['selection_reason']='Оба стиля решают новый полный прикладной договор; оба измеряются целиком и остаются в сравнении.'
        for key in ('historical_counts','historical_counts_revision','metric_note'):
            entry.pop(key,None)
        sid=entry['id'];functional=source_code(entry['source_files']['lmx'])
        proc_path=entry['source_files']['lmx'] if entry.get('style_relation')=='same_minimal_form' else f'source/lmx/procedural/{sid}.lm3'
        procedural=source_code(proc_path)
        foreign=source_code(entry['source_files']['foreign'])
        relation='same_minimal_form' if procedural==functional else 'distinct'
        attach_variants(entry,procedural=procedural,functional=functional,procedural_source=proc_path,
            functional_source=entry['source_files']['lmx'],contract_id=sid,style_relation=relation,style_note=entry['style_note'])
        entry['lmx_variants']['procedural']['core_functions']=[]
        entry['lmx_variants']['functional']['core_functions']=entry.get('core_functions',[])
        for variant in entry['lmx_variants'].values():
            variant['metrics_status']='current'
            variant['parser_execution']='NOT_RUN'
        problems=validate_variants(entry,ROOT)
        if problems:raise ValueError((sid,problems))
        entry['lmx']=functional;entry['foreign']=foreign
        counts={'lmx':metrics(functional),'foreign':metrics(foreign),
            'lmx_procedural':metrics(procedural),'lmx_functional':metrics(functional)}
        entry['counts']=counts
        status=entry.get('comparison_status','complete_pair')
        row={'id':sid,'title':entry['title'],'category':entry['category'],'comparison_status':status,
            'style_relation':relation,'lmx_legacy_role':entry['lmx_legacy_role'],**counts}
        for style in STYLES:
            key='lmx_'+style
            row['ratio_foreign_over_'+key]=counts['foreign']['characters_nonwhitespace']/counts[key]['characters_nonwhitespace'] if status=='complete_pair' else None
            if relation!='same_minimal_form' or style=='functional':
                inventory.append({'id':sid,'scope':'client','language':key if relation!='same_minimal_form' else 'lmx_shared',
                    'styles':[style] if relation!='same_minimal_form' else list(STYLES),
                    'path':entry['lmx_variants'][style]['source_file'],**counts[key]})
        row['ratio_foreign_over_lmx']=row['ratio_foreign_over_lmx_functional'];rows.append(row)
        inventory.append({'id':sid,'scope':'client','language':'foreign','path':entry['source_files']['foreign'],**counts['foreign']})
        entry['implementation_links']={name:coverage.get(name,[]) for name in entry.get('core_functions',[])}
        entry['core_sources']={name:'../../LMX_Fn_Receivers/'+catalog[name]['source'] for name in entry.get('core_functions',[])}
        scope='Полное сравнение на указанном домене.' if status=='complete_pair' else 'Протокольная аналогия: LMX host fixture ожидает интеграции; оба стиля вне итоговых коэффициентов.'
        parts=[f"# {sid}. {entry['title']}\n",scope+'\n','## Общий договор\n',as_paragraphs(entry['contract']),
            as_paragraphs(entry.get('domain')),as_paragraphs(entry.get('observables')),
            '## Входы и ожидаемые наблюдения\n',code_block('json',json.dumps(entry.get('test_cases',[]),ensure_ascii=False,indent=2)),
            '## Размер полных вариантов\n',count_table(('LMX — процедурный',counts['lmx_procedural']),('LMX — функциональный',counts['lmx_functional']),('Common Lisp / SBCL',counts['foreign'])),
            'Оба стиля LMX сравниваются независимо по одному договору. Все объявления, вспомогательные определения и Throws входят в размер. Реализация общих библиотечных операций учитывается отдельно один раз.\n',
            markdown_variants(entry),'## Common Lisp / SBCL\n',f"[Полный исходник]({entry['source_files']['foreign']}).\n",code_block('common-lisp',foreign),
            '## Соответствие стилей договору\n',entry['style_note']+'\n',as_paragraphs(entry.get('notes_ru')),as_paragraphs(entry.get('limitations')),
            as_paragraphs(entry.get('foreign_boundary')),as_paragraphs(entry.get('lmx_boundary')),'## Общие операции и реализации\n']
        for name,link in entry['core_sources'].items():
            comparisons=', '.join(f'[{ident}](library_comparisons/{ident}_comparision.md)' for ident in coverage.get(name,[]))
            parts.append(f'- `{name}`: [тело ядра]({link})'+('; отдельное сравнение '+comparisons if comparisons else '')+'.\n')
        if not entry['core_sources']:parts.append('Общий договор выражен базовыми средствами языка и приведёнными прикладными определениями.\n')
        parts.append('Common Lisp-клиент использует указанные native/standard средства и не импортирует сравнительные реализации.\n')
        used_hashes={counts['lmx_procedural']['sha256'],counts['lmx_functional']['sha256']}
        retained=[]
        for alt in entry.get('alternatives',[]):
            code=source_code(alt['source_file']);m=metrics(code)
            if m['sha256'] in used_hashes:continue
            used_hashes.add(m['sha256']);alt['code']=code;alt['counts']=m;retained.append(alt)
            alternatives.append({'example':sid,'approach':alt['approach'],'language':alt.get('language','LMX'),'source_file':alt['source_file'],**m})
            inventory.append({'id':sid,'scope':'alternative','language':alt.get('language','LMX'),'path':alt['source_file'],**m})
            parts += ['## Дополнительный способ: '+alt['approach']+'\n',as_paragraphs(alt.get('reason')),f"[Исходник]({alt['source_file']}); вне двух основных сравнений.\n",code_block('lmx',code)]
        entry['alternatives']=retained
        runtime_note=('Для обновлённого кода **SBCL: NOT_RUN; LMX parser/runtime: NOT_RUN**. '
                      'Статистика пересчитана по полным исходникам; это не выполнение программ. '
                      '[Статус и прежний receipt](validation/common_lisp.json).\n'
                      if entry.get('contract_revision') else
                      'SBCL: [статус и датированный отчёт](validation/common_lisp.json). Оба LMX-варианта: **NOT_RUN**; проверки текста не доказывают исполнение.\n')
        parts += ['## Проверка\n',runtime_note,'## Первичные источники\n',source_list(entry.get('sources',[]))]
        write(sid+'_comparision.md','\n'.join(x for x in parts if x))
    impl_rows=[]
    for item in implementations:
        measures={key:metrics(source_code(item['source_files'][key])) for key in ('lmx','foreign')}
        impl_rows.append({'id':item['id'],'title':item['title'],'core_functions':item['core_functions'],'dependency_role':item.get('dependency_role','primary'),**measures})
        for key in measures:inventory.append({'id':item['id'],'scope':'implementation','language':key,'path':item['source_files'][key],**measures[key]})
    paired=[x for x in rows if x['comparison_status']=='complete_pair']
    totals={key:total(paired,key) for key in ('lmx_procedural','lmx_functional','foreign')};totals['lmx']=totals['lmx_functional']
    for style in STYLES:totals['ratio_foreign_over_lmx_'+style]=totals['foreign']['characters_nonwhitespace']/totals['lmx_'+style]['characters_nonwhitespace']
    totals['ratio_foreign_over_lmx']=totals['ratio_foreign_over_lmx_functional']
    statistics={'suite':'sbcl','edition':EDITION,'method':'Full Unicode nonwhitespace source counts including every Throws. Both LMX styles are primary comparisons; lmx is only a functional compatibility mirror.',
        'counts':{'examples':len(rows),'complete_pairs':len(paired),'related_analogies':len(rows)-len(paired),'lmx_style_variants':2*len(rows),'lmx_source_files':sum(1 if e['style_relation']=='same_minimal_form' else 2 for e in data['examples']),'implementation_pairs':len(impl_rows),'alternatives':len(alternatives)},
        'paired_totals':totals,'all_client_totals':{key:total(rows,key) for key in ('lmx_procedural','lmx_functional','foreign','lmx')},
        'implementation_primary_totals':{key:total(impl_rows,key) for key in ('lmx','foreign')},'examples':rows,'implementations':impl_rows,'alternatives':alternatives,
        'dependency_closure':impl_data.get('totals',{}),'runtime':{'common_lisp':'See validation/common_lisp.json and implementation_execution.json','lmx':'NOT_RUN'}}
    write_json('examples.json',data);write_json('statistics.json',statistics);write_json('SOURCE_INVENTORY.json',{'edition':EDITION,'files':inventory})
    selections=[]
    for e in data['examples']:
        selections.append({'id':e['id'],'variants':[{'style':s,'path':e['lmx_variants'][s]['source_file'],
            'compared':True,**e['counts']['lmx_'+s]} for s in STYLES],
            'alternatives':[{'path':a['source_file'],'compared':False,**a['counts']} for a in e.get('alternatives',[])],
            'style_relation':e['style_relation'],'style_note':e['style_note'],'metrics_status':'current',
            'selection_rule':'Both complete LMX styles are compared; size never selects or discards a style'})
    write_json('variant_selection.json',{'methodology':'Both full procedural and functional LMX variants are primary. Current full counts; no shortened Throws metric.','examples':selections})
    flat=[]
    for scope,selected in [('client',rows),('implementation',impl_rows)]:
        for row in selected:
            for key in (('lmx_procedural','lmx_functional','foreign') if scope=='client' else ('lmx','foreign')):
                flat.append({'scope':scope,'id':row['id'],'title':row['title'],'language':key,'comparison_status':row.get('comparison_status','separate_implementation'),**row[key]})
    fields=['scope','id','title','language','comparison_status','characters_nonwhitespace','characters_all','nonblank_lines','utf8_bytes','sha256']
    stream=io.StringIO(newline='');writer=csv.DictWriter(stream,fieldnames=fields,lineterminator='\n');writer.writeheader();writer.writerows(flat);write('statistics.csv',stream.getvalue())
    used={n for e in data['examples'] for n in e.get('core_functions',[])}
    alt_used={n for e in data['examples'] for a in e.get('alternatives',[]) for n in a.get('core_functions',[])}
    write_json('validation/library_coverage.json',{'coverage':coverage,'primary_core_functions':sorted(used),'alternative_core_functions':sorted(alt_used),
        'core_sources':{n:'../../LMX_Fn_Receivers/'+catalog[n]['source'] for n in sorted(used|alt_used) if n in catalog},
        'missing_primary':sorted(used-catalog.keys()),'missing_alternative':sorted(alt_used-catalog.keys()),'rule':'Every core call links to its actual canonical source; implementation pairs remain separate and are never imported by foreign clients.'})
    table=['| ID | Задача | LMX процедурный | LMX функциональный | Common Lisp | Lisp / процедурный | Lisp / функциональный |','| --- | --- | ---: | ---: | ---: | ---: | ---: |']
    for row in rows:
        ratios=['вне итога' if row['ratio_foreign_over_lmx_'+s] is None else f"{row['ratio_foreign_over_lmx_'+s]:.3f}" for s in STYLES]
        table.append(f"| [{row['id']}]({row['id']}_comparision.md) | {row['title']} | {row['lmx_procedural']['characters_nonwhitespace']} | {row['lmx_functional']['characters_nonwhitespace']} | {row['foreign']['characters_nonwhitespace']} | {ratios[0]} | {ratios[1]} |")
    table.append(f"| **Итого: {len(paired)} полных договоров** | | **{totals['lmx_procedural']['characters_nonwhitespace']}** | **{totals['lmx_functional']['characters_nonwhitespace']}** | **{totals['foreign']['characters_nonwhitespace']}** | **{totals['ratio_foreign_over_lmx_procedural']:.3f}** | **{totals['ratio_foreign_over_lmx_functional']:.3f}** |")
    impl_table=['| ID | Операции | LMX | Common Lisp |','| --- | --- | ---: | ---: |']
    for row in impl_rows:impl_table.append(f"| [{row['id']}](library_comparisons/{row['id']}_comparision.md) | {row['title']} | {row['lmx']['characters_nonwhitespace']} | {row['foreign']['characters_nonwhitespace']} |")
    write('LMX_Comparison_SBCL.md','# LMX / Common Lisp на SBCL\n\nОба полных стиля LMX, включая все Throws, сравниваются отдельно. Размер не является скоростью.\n\n'+'\n'.join(table)+'\n\nS24 остаётся протокольной аналогией вне итогов. Одинаковые минимальные формы имеют один общий файл и объяснение; фиктивные обходы не добавляются.\n\n## Реализации общих операций\n\n'+'\n'.join(impl_table)+'\n\nЯдровые тела и общие зависимости учитываются один раз, без размножения по стилям. [Методика](README.md), [JSON](statistics.json), [CSV](statistics.csv), [PDF](LMX_Comparison_SBCL.pdf), [XLSX](LMX_Comparison_SBCL.xlsx).\n')
    design=['# Common Lisp / SBCL и два LMX-стиля','']
    for category in dict.fromkeys(e['category'] for e in data['examples']):
        design += ['## '+category,'']+[f"- [{e['id']}. {e['title']}]({e['id']}_comparision.md): процедурный и функциональный варианты." for e in data['examples'] if e['category']==category]+['']
    write('LMX_Design_Patterns.SBCL.md','\n'.join(design))
    write_json('validation/throws_metrics.json',{'status':'REMOVED_FROM_COMPARISON','rule':'Every source character is counted, including complete Throws and copy references. No alternate throws metric is calculated.'})
    readme=ROOT/'README.md'
    readme.write_text(ensure_startup_note(readme.read_text(),'../../../LMX_semantics.en.md#source-entry-profiles'))
    print(json.dumps({'counts':statistics['counts'],'paired_totals':totals,'missing_core_coverage':sorted(used-catalog.keys())},ensure_ascii=False))

if __name__=='__main__':main()

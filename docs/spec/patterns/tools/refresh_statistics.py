#!/usr/bin/env python3
"""Recompute publication metrics from current primary sources, never archives.

This updates Markdown/CSV and a complete machine-readable statistics report.
It does not run the languages or render workbooks/PDFs.
"""
from pathlib import Path
from collections import defaultdict
import json,re,csv,hashlib

ROOT=Path(__file__).resolve().parents[1]
DATE='2026-11-22'
MARKER='# BEGIN PROCEDURAL LMX (excluded from character counts)'
ALTERNATIVE_MARKER='# BEGIN ALTERNATIVE LMX (excluded from character counts)'

def canon(s):return s.strip()+'\n'
def metrics(s):
    s=canon(s)
    return {'characters':sum(not c.isspace() for c in s),'nonblank_lines':sum(bool(x.strip()) for x in s.splitlines()),'utf8_bytes':len(s.encode()),'sha256':hashlib.sha256(s.encode()).hexdigest()}
def primary(path):return canon(path.read_text().split(MARKER)[0].split(ALTERNATIVE_MARKER)[0])
def order(p):return (p.get('paired_with',p['id']),p.get('kind','pattern')=='implementation',p['id'])
def put(p,s):p.write_text(s)
def main():
    report={'date':DATE,'method':'Unicode nonwhitespace codepoints, nonblank lines, UTF8 bytes; shortest valid available variant is primary. Other variants retained and excluded. Shared dependencies separate. No runtime or performance claim.','groups':[],'variant_selection':[]}
    flat=[]
    for jp in sorted(ROOT.glob('[0-9][0-9]_*/patterns.json')):
        d=json.loads(jp.read_text());directory=jp.parent;langs=['LMX']+d['languages'];rows=[];summary=[]
        group={'directory':directory.name,'title':d['group_title_ru'],'languages':langs,'records':[]}
        totals={layer:{lang:{'characters':0,'nonblank_lines':0,'utf8_bytes':0} for lang in langs} for layer in ('scenario','usage','implementation')}
        for p in sorted(d['patterns'],key=order):
            layer='implementation' if p.get('kind')=='implementation' else 'usage' if p.get('implementation_ids') else 'scenario'
            stem=f"{p['id']:03d}_{p['slug']}";source=stem+'_comparision.md'
            rec={'id':p['id'],'name':p['name'],'layer':layer,'kind':p.get('kind','pattern'),'source':directory.name+'/'+source,'metrics':{}}
            counts=[]
            for listing in p['listings']:
                lang=listing['language'];m=metrics(listing['code']);rec['metrics'][lang]=m;counts.append(m)
                for k in ('characters','nonblank_lines','utf8_bytes'):totals[layer][lang][k]+=m[k]
                variants=p.get('variants',{}).get(lang,{})
                if variants:
                    sizes={name:metrics(code)['characters'] for name,code in variants.items()}
                    eligible=p.get('eligible_variants',{}).get(lang,list(sizes))
                    if m['characters']!=min(sizes[v] for v in eligible):raise ValueError(f'{directory.name}/{p["id"]}/{lang}: primary is not shortest eligible')
                    report['variant_selection'].append({'group':directory.name,'id':p['id'],'language':lang,'primary':p['primary_variant'][lang],'eligible_variants':eligible,'fairness_note':p.get('fairness_notes',{}).get(lang,''),'characters':sizes,'selected_characters':m['characters']})
            labels={'scenario':{'core':'Ядро сценария','protocol':'Протокол и порты','executable':'Самостоятельный пример'}.get(p['scope'],p['scope']),'usage':'Использование библиотеки','implementation':'Реализация библиотеки'}
            summary.append('| '+f"{p['id']:03d}"+' | '+f"[{p['name']}]({source})"+' | '+' | '.join(f"{m['characters']} / {m['nonblank_lines']}" for m in counts)+' | '+labels[layer]+' |')
            row={'id':p['id'],'pattern':p['name'],'scope':p['scope'],'kind':p.get('kind','pattern'),'layer':layer}
            for field,key in [('characters','characters'),('nonblank_lines','nonblank_lines')]:
                for lang in langs:row[f'{lang}_{field}']=rec['metrics'][lang][key]
            row['source']=source;rows.append(row);group['records'].append(rec);flat.append(rec)
            md=directory/source;text=md.read_text()
            for lang,m in rec['metrics'].items():
                text=re.sub(r'^\| '+re.escape(lang)+r' \| \d+ \| \d+ \|',f"| {lang} | {m['characters']} | {m['nonblank_lines']} |",text,flags=re.M)
            put(md,text)
        cmp=directory/f'LMX_Comparison_{directory.name}.md';text=cmp.read_text();lines=text.splitlines();positions=[i for i,l in enumerate(lines) if re.match(r'^\|\s*\d+\s*\|',l)]
        if len(positions)!=len(summary):raise ValueError((cmp,len(positions),len(summary)))
        for pos,new in zip(positions,summary):lines[pos]=new
        text='\n'.join(lines)+'\n';text=text.replace('Дата редакции: 2026-11-21','Дата редакции: '+DATE)
        put(cmp,text)
        cp=directory/f'LMX_Comparison_{directory.name}.csv'
        fields=['id','pattern','scope','kind','layer']+[f'{l}_characters' for l in langs]+[f'{l}_nonblank_lines' for l in langs]+['source']
        with cp.open('w',encoding='utf-8-sig',newline='') as f:w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(rows)
        group['totals']=totals;group['pattern_count']=sum(x['kind']=='pattern' for x in group['records']);group['implementation_count']=sum(x['kind']=='implementation' for x in group['records'])
        report['groups'].append(group)
    report['pattern_count']=sum(g['pattern_count'] for g in report['groups']);report['implementation_count']=sum(g['implementation_count'] for g in report['groups']);report['primary_listing_count']=3*len(flat)
    example_counts=[]
    for p in sorted((ROOT/'examples/lmx').glob('*.lm3')):example_counts.append({'id':p.stem,'source':p.relative_to(ROOT).as_posix(),**metrics(primary(p)),'procedural_archived':MARKER in p.read_text() or ALTERNATIVE_MARKER in p.read_text()})
    report['root_examples']=example_counts
    for name in ('functional_receiver_counts.json','receiver_library_counts.json'):
        p=ROOT/'examples/validation'/name
        if p.exists():report[name.removesuffix('.json')]=json.loads(p.read_text())
    p=ROOT/'09_functional_computation/implementation_dependencies.json'
    if p.exists():report['functional_library_dependencies']=json.loads(p.read_text())
    # The original eight-language collection is independent of the 99 rows.
    fences={'lmx':'LMX','python':'Python','java':'Java','cpp':'C++','csharp':'C#','typescript':'TypeScript','go':'Go','rust':'Rust'}
    gof=[]
    for p in sorted(ROOT.glob('[0-9][0-9]_*_comparison.md')):
        text=p.read_text();seen={}
        for match in re.finditer(r'^```([^\n]*)\n([\s\S]*?)^```\s*$',text,re.M):
            language=fences.get(match.group(1).strip())
            if not language or language in seen:continue
            prefix=text[max(0,match.start()-120):match.start()]
            if '<!-- uncounted-code:' in prefix:continue
            code=canon(match.group(2))
            seen[language]={**metrics(code),'total_characters':len(code),'physical_lines':len(code.splitlines())}
        if len(seen)!=8:raise ValueError(f'{p}: expected eight primary language listings, found {len(seen)}')
        for language,m in seen.items():
            table=re.search(r'^\|\s*'+re.escape(language)+r'\s*\|\s*(\d+)\s*\|',text,re.M)
            if not table:raise ValueError(f'{p}/{language}: published count row missing')
            ratio=m['characters']/seen['LMX']['characters']
            text=re.sub(r'^\|\s*'+re.escape(language)+r'\s*\|\s*\d+\s*\|.*$',f"| {language} | {m['characters']} | {m['total_characters']} | {m['physical_lines']} | {ratio:.2f}× |",text,count=1,flags=re.M)
        put(p,text)
        gof.append({'file':p.name,'metrics':seen})
    report['gof']={'comparisons':len(gof),'listings':8*len(gof),'records':gof,'total_characters':{l:sum(x['metrics'][l]['characters'] for x in gof) for l in fences.values()}}
    lib=ROOT/'LMX_Fn_Receivers';cat=json.loads((lib/'catalog.json').read_text());report['receiver_library']={'public_receivers':len(cat),'assembled':metrics((lib/'LMX_Receivers.lmx').read_text()),'runtime_executed':False}
    target=ROOT/'validation/statistics_20261122.json';target.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    out=['# Статистика редакции 22 ноября 2026 года',
         '**90 паттернов + 9 реализаций библиотек: 99 сравнений и 297 основных листингов.** Сохранены также 23 исходных GoF-сравнения (184 листинга) и отдельная подборка 24 LMX-примеров.',
         'Считаются непробельные Unicode-символы и непустые строки основного листинга. Из двух корректных вариантов основным выбирается более короткий; альтернативы сохранены рядом и исключены. Реализации общих зависимостей учитываются отдельно; размеры кода не означают скорость исполнения.',
         '## Группы и границы сравнения',
         '| Группа | Слой | Количество | LMX, символы | Контроль 1 | Символы | Контроль 2 | Символы |\n| --- | --- | ---: | ---: | --- | ---: | --- | ---: |']
    summarycsv=[]
    for g in report['groups']:
        for layer in ('scenario','usage','implementation'):
            count=sum(x['layer']==layer for x in g['records'])
            if not count:continue
            title={'scenario':'Сценарии','usage':'Клиенты библиотек','implementation':'Реализации'}[layer];t=g['totals'][layer];a,b=g['languages'][1:]
            out[-1]+=f"\n| [{g['title']}]({g['directory']}/LMX_Comparison_{g['directory']}.md) | {title} | {count} | {t['LMX']['characters']} | {a} | {t[a]['characters']} | {b} | {t[b]['characters']} |"
            summarycsv.append({'group':g['directory'],'title':g['title'],'layer':layer,'comparisons':count,'LMX_characters':t['LMX']['characters'],'control1':a,'control1_characters':t[a]['characters'],'control2':b,'control2_characters':t[b]['characters']})
    out+=['По разным группам не строится общий рейтинг языков: контрольные языки, сценарии и границы библиотек различаются. Основные и альтернативные реализации имеют явно указанные границы обобщения и зависимости; короткий клиент использует показанный рядом компонент единого текущего ядра.',
          '## Функциональная группа и общие зависимости',
          '[Восемь сравнений](09_functional_computation/LMX_Comparison_09_functional_computation.md) сохраняют предыдущие исходники как пояснение и показывают текущую реализацию. [Реестр зависимостей](09_functional_computation/IMPLEMENTATION_DEPENDENCIES.md) считает реальные LMX-определения по одному разу, включая дополнительный curry-механизм клиента 085; неопубликованное ядро не объявляется имеющим нулевой размер.',
          '## Корневые примеры',
          '| Пример | Основной код, символы | Непустые строки | Второй вариант рядом |\n| --- | ---: | ---: | --- |']
    for x in example_counts:out[-1]+=f"\n| [{x['id']}]({x['source']}) | {x['characters']} | {x['nonblank_lines']} | {'Да' if x['procedural_archived'] else 'Исходный пример сохранён'} |"
    out+=['[Выбор основного варианта и размеры обоих](examples/validation/functional_receiver_counts.json) и [полная стоимость библиотечных реализаций](examples/validation/receiver_library_counts.json). Общая реализация остаётся доступной, даже если более короткий процедурный вариант выбран основным.',
          '## Исходные 23 GoF-сравнения',
          'Все 184 основных листинга повторно пересчитаны. Для Composite, Prototype и Abstract Factory сохранены альтернативные LMX-алгоритмы, основной выбран по краткости при сопоставимой границе подсчёта. В Flyweight исправлен уровень отступа финального return; прежний некорректный вариант помечен историческим и не участвует в выборе по краткости.',
          '| Язык | Непробельных символов |\n| --- | ---: |']
    for lang,n in report['gof']['total_characters'].items():out[-1]+=f'\n| {lang} | {n} |'
    out+=['## Форматы и воспроизводимость',
          '[CSV сводки](STATISTICS_2026-11-22.csv), [Excel сводки](STATISTICS_2026-11-22.xlsx), [PDF сводки](STATISTICS_2026-11-22.pdf), [полный JSON](validation/statistics_20261122.json). Во всех девяти группах отдельно обновлены Markdown, CSV, XLSX и PDF.',
          '`python3 tools/refresh_statistics.py` обновляет текстовые числовые таблицы и JSON. `python3 tools/recount_patterns.py --json validation/recount_report.json` проверяет совпадение первичных JSON/исходников/Markdown и сохранённые варианты. Обновление Excel/PDF и их визуальная проверка имеют отдельные отчёты в validation. Инструменты не исполняют LMX и не измеряют скорость.']
    put(ROOT/'STATISTICS_2026-11-22.md','\n\n'.join(out)+'\n')
    with (ROOT/'STATISTICS_2026-11-22.csv').open('w',encoding='utf-8-sig',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(summarycsv[0]));w.writeheader();w.writerows(summarycsv)
    print(json.dumps({'groups':len(report['groups']),'comparisons':len(flat),'primary_listings':report['primary_listing_count'],'gof_comparisons':len(gof),'root_examples':len(example_counts)},ensure_ascii=False))
if __name__=='__main__':main()

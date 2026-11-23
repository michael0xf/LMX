#!/usr/bin/env python3
"""Recount the 23 primary GoF examples and refresh their aggregate text.

Other LMX blocks are retained explanations, implementations or alternatives;
only the first counted block of each language participates in the comparison.
"""
from pathlib import Path
import re,json,hashlib

ROOT=Path(__file__).resolve().parents[1]
LANGS={'lmx':'LMX','python':'Python','java':'Java','cpp':'C++','csharp':'C#','typescript':'TypeScript','go':'Go','rust':'Rust'}
def canon(s):return s.strip()+'\n'
def collect():
    rows=[]
    for p in sorted(ROOT.glob('[0-9][0-9]_*_comparison.md')):
        text=p.read_text();found={}
        for m in re.finditer(r'^```([^\n]*)\n([\s\S]*?)^```\s*$',text,re.M):
            lang=LANGS.get(m[1].strip())
            if not lang or lang in found or '<!-- uncounted-code:' in text[max(0,m.start()-120):m.start()]:continue
            code=canon(m[2]);found[lang]={'characters':sum(not c.isspace() for c in code),'total_characters':len(code),'physical_lines':len(code.splitlines()),'nonblank_lines':sum(bool(x.strip()) for x in code.splitlines()),'utf8_bytes':len(code.encode()),'sha256':hashlib.sha256(code.encode()).hexdigest()}
        if len(found)!=8:raise ValueError(f'{p}: expected eight counted language blocks')
        for lang,m in found.items():
            row=f"| {lang} | {m['characters']} | {m['total_characters']} | {m['physical_lines']} | {m['characters']/found['LMX']['characters']:.2f}× |"
            text,n=re.subn(r'^\|\s*'+re.escape(lang)+r'\s*\|\s*\d+\s*\|.*$',row,text,count=1,flags=re.M)
            if n!=1:raise ValueError(f'{p}/{lang}: expected one metric row, found {n}')
        p.write_text(text)
        title=re.search(r'^#\s+(?:\d+[.]?\s*)?(.*)',text,re.M)[1]
        rows.append({'id':int(p.name[:2]),'file':p.name,'title':title,'metrics':found})
    return rows
def aggregate(rows):
    totals={lang:sum(x['metrics'][lang]['characters'] for x in rows) for lang in LANGS.values()}
    return {'count':len(rows),'totals':totals,'reduction_python':100*(1-totals['LMX']/totals['Python']),'shorter_python':sum(x['metrics']['LMX']['characters']<x['metrics']['Python']['characters'] for x in rows),'minimum_all':sum(x['metrics']['LMX']['characters']==min(m['characters'] for m in x['metrics'].values()) for x in rows)}
def main():
    rows=collect();sets={label:aggregate([x for x in rows if a<=x['id']<=b]) for label,a,b in [('1–9',1,9),('10–18',10,18),('19–23',19,23),('1–18',1,18),('1–23',1,23)]}
    all_=sets['1–23'];first=sets['1–18']
    def percent(n,ru):return f'{n:.2f}'.replace('.',',' if ru else '.')+'%'
    for suffix,label in [('', '1–9'),('10-18','10–18'),('19-23','19–23')]:
        for locale in ('ru','en'):
            p=ROOT/f'LMX_Design_Patterns{suffix}.{locale}.md';s=p.read_text();t=sets[label]['totals'];ru=locale=='ru'
            s=re.sub(r'^\| \*\*(Сумма|Total)\*\* \|.*$', '| **'+('Сумма' if ru else 'Total')+'** | '+' | '.join(f'**{t[x]}**' for x in LANGS.values())+' |',s,flags=re.M)
            s=re.sub(r'^\| \*\*(Сумма|Total) / LMX\*\* \|.*$', '| **'+('Сумма' if ru else 'Total')+' / LMX** | '+' | '.join(f'{t[x]/t["LMX"]:.3f}×' for x in LANGS.values())+' |',s,flags=re.M)
            if suffix=='19-23':
                for lang in LANGS.values():
                    ratio=f'{t[lang]/t["LMX"]:.2f}'.replace('.',',' if ru else '.')
                    s=re.sub(r'^\| '+re.escape(lang)+r' \|.*$',f'| {lang} | {t[lang]} | {ratio}× |',s,flags=re.M)
            p.write_text(s)
    for locale in ('ru','en'):
        ru=locale=='ru';p=ROOT/f'about_languages_comparision.{locale}.md';s=p.read_text()
        for label in ('1–9','10–18','19–23','1–23'):
            a=sets[label];rowlabel=('Все ' if ru else 'All ')+label if label=='1–23' else label
            row=f"| {rowlabel} | {a['totals']['LMX']} | {a['totals']['Python']} | {percent(a['reduction_python'],ru)} | {a['shorter_python']} {'из' if ru else 'of'} {a['count']} |"
            s=re.sub(r'^\| '+re.escape(rowlabel)+r' \|.*$',row,s,flags=re.M)
        if ru:
            s=re.sub(r'\*\*В этой подборке LMX короче Python в \d+ из 23 примеров\*\*, а суммарный объём прикладных листингов меньше на \*\*[\d,]+%\*\*',f"**В этой подборке LMX короче Python в {all_['shorter_python']} из 23 примеров**, а суммарный объём прикладных листингов меньше на **{percent(all_['reduction_python'],True)}**",s)
            s=re.sub(r'В первых 18 примерах суммы — .*?Python имеет',f"В первых 18 примерах суммы — **{first['totals']['LMX']} и {first['totals']['Python']}**, сокращение **{percent(first['reduction_python'],True)}**. LMX короче Python в {first['shorter_python']} из 18 случаев и минимален среди восьми языков в {first['minimum_all']}. Python имеет",s)
            s=s.replace('Пять исключений относительно Python:','Четыре исключения относительно Python:')
            s=re.sub(r'В Prototype перед изменением полей .*?исключениям\.', 'В Prototype основным стал более короткий вызов bindFields, входящего в ядро; процедурный аналог сохранён рядом. Ядро одно, реализации не разделяются на версии.',s)
        else:
            s=re.sub(r'\*\*In this collection, LMX is shorter than Python in \d+ of 23 examples\*\*, with \*\*[\d.]+%\*\* less',f"**In this collection, LMX is shorter than Python in {all_['shorter_python']} of 23 examples**, with **{percent(all_['reduction_python'],False)}** less",s)
            s=re.sub(r'The first 18 examples total .*?Python has',f"The first 18 examples total **{first['totals']['LMX']} versus {first['totals']['Python']}**, a **{percent(first['reduction_python'],False)}** reduction. LMX is shorter than Python in {first['shorter_python']} of 18 cases and shortest among eight languages in {first['minimum_all']}. Python has",s)
            s=s.replace('There are five exceptions relative to Python:','There are four exceptions relative to Python:')
            s=re.sub(r'Prototype now explicitly selects .*?another exception\.', 'Prototype now uses the shorter bindFields operation of the single current kernel; its procedural equivalent remains beside it. These are alternative algorithms, not different library versions.',s)
        s=re.sub(r'^\| Prototype \|.*\n','',s,flags=re.M)
        for record in rows:
            lm=record['metrics']['LMX']['characters'];py=record['metrics']['Python']['characters']
            if lm<=py:continue
            name=record['title'].split(':',1)[0]
            row=f'| {name} | {lm} | {py} | {percent(100*(lm/py-1),ru)} |'
            s=re.sub(r'^\| '+re.escape(name)+r' \|.*$',row,s,flags=re.M)
        p.write_text(s)
    p=ROOT/'README.md';s=p.read_text()
    s=re.sub(r'Для исходной корневой подборки из 23 GoF-паттернов LMX занимает .*?Подробные цифры,',f"Для корневой подборки из 23 GoF-паттернов LMX занимает **{all_['totals']['LMX']}**, Python — **{all_['totals']['Python']}** непробельных символов: сокращение **{percent(all_['reduction_python'],True)}**. LMX короче Python в **{all_['shorter_python']} из 23** примеров и минимален среди восьми языков в **{all_['minimum_all']}**. Python имеет наименьшую сумму среди остальных семи языков. Подробные цифры,",s)
    p.write_text(s)
    report={'date':'2026-11-23','scope':'23 GoF primary listings; all 184 counted blocks','records':rows,'aggregates':sets,'runtime_executed':False}
    (ROOT/'validation/gof_statistics_20261122.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(all_,ensure_ascii=False))
if __name__=='__main__':main()

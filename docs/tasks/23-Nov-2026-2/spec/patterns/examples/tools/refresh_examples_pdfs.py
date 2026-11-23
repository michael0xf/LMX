#!/usr/bin/env python3
"""Render the complete examples directory metrics; source execution is separate."""
from pathlib import Path
import importlib.util
import json,hashlib
from reportlab.platypus import Spacer,PageBreak,TableStyle

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('lmx_pdf_style',ROOT.parent/'tools/refresh_pdfs.py')
style=importlib.util.module_from_spec(spec);spec.loader.exec_module(style)
p,table,doc=style.p,style.table,style.doc
STATUS={'complete_pair':'Полная пара','related_analogy':'Аналогия','lmx_only':'Только LMX'}

def footer(canvas,document):
    w,h=style.landscape(style.A4)
    canvas.setStrokeColor(style.colors.HexColor('#CFD8E0'));canvas.line(36,32,w-36,32)
    canvas.setFillColor(style.colors.HexColor('#4E5E6D'));canvas.setFont('LMX',7)
    canvas.drawString(36,20,'LMX / examples — текущие исходники — 23 ноября 2026')
    canvas.drawRightString(w-36,20,str(document.page))

def cases(rows,language):
    body=[]
    for x in rows:
        foreign=f"{x['foreign']['characters']} / {x['foreign']['nonblank_lines']}" if x['foreign'] else '—'
        ratio=f"{x['ratio']:.3f}×" if x['ratio'] is not None else '—'
        body.append([x['id'],x['title'],f"{x['lmx']['characters']} / {x['lmx']['nonblank_lines']}",x['lmx']['without_complex_throws_characters'],foreign,ratio,STATUS[x['comparison_status']]])
    result=table(['ID','Сценарий','LMX\nсимв. / стр.','без сложного\nThrows',language+'\nсимв. / стр.','Контроль / LMX','Граница'],body,[40,235,90,90,90,90,100])
    result.setStyle(TableStyle([('TOPPADDING',(0,0),(-1,-1),2),('BOTTOMPADDING',(0,0),(-1,-1),2)]))
    style.highlight_minimums(result,[(i+1,(2,x['lmx']['characters']),(3,x['lmx']['without_complex_throws_characters']),[(4,x['foreign']['characters'])]) for i,x in enumerate(rows) if x['comparison_status']=='complete_pair'])
    return result

def implementations(rows,all_suites=False):
    result=table(['Набор / ID' if all_suites else 'ID','Операции','LMX\nсимв. / стр.','без сложного\nThrows','Контроль\nсимв. / стр.'],
        [[(('SBCL' if x['suite']=='sbcl' else x['foreign_language'])+' / ' if all_suites else '')+x['id'],x['title'],f"{x['lmx']['characters']} / {x['lmx']['nonblank_lines']}",x['lmx']['without_complex_throws_characters'],f"{x['foreign']['characters']} / {x['foreign']['nonblank_lines']}"] for x in rows],
        [100,330,110,100,110] if all_suites else [65,365,110,100,110])
    result.setStyle(TableStyle([('TOPPADDING',(0,0),(-1,-1),2),('BOTTOMPADDING',(0,0),(-1,-1),2)]))
    style.highlight_minimums(result,[(i+1,(2,x['lmx']['characters']),(3,x['lmx']['without_complex_throws_characters']),[(4,x['foreign']['characters'])]) for i,x in enumerate(rows)])
    return result

def method():
    return [p('Граница подсчёта и проверка','HeadingLMX'),
        p('Непробельные Unicode-символы и непустые строки полного основного листинга. Необходимые объявления, импорты и предметный код включены. Тестовая обвязка, отдельная реализация ядра и существенные альтернативы исключены из клиента и описаны отдельно.'),
        p('Клиенты контрольного языка используют настоящие средства языка или библиотеки. Их самостоятельные реализации сохранены для сравнения с LMX и не подставляются вместо настоящей библиотеки. LMX использует прямые функции единого ядра с lowerCamelCase именами.'),
        p('На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод. Общий список и throws: copy(Throws) сохраняют эту ясность, и сокращать такие записи ради размера не хочется.'),
        p('Колонка «без сложного Throws» сохраняет заголовок, первый написанный аргумент каждого списка и полные ссылки copy. Только аргументы после первого не входят в дополнительный подсчёт. Сами исходники не меняются. Зелёным показан минимум сопоставимой строки; дополнительный счётчик LMX выбирается, когда меньше полного.','SmallLMX'),
        p('Отношение строится только для полных пар одного договора. Размеры разных наборов не образуют рейтинг языков. Это метрика исходников, не скорости или памяти. LMX runtime в архив не входит; его семантические случаи имеют NOT_RUN. Доступные выполненные проверки контрольных языков отмечены в validation соответствующего набора.','SmallLMX')]

def main():
    data=json.loads((ROOT/'STATISTICS.json').read_text());generated=[]
    style.CURRENT_FILE='examples/STATISTICS.pdf'
    story=[p('LMX: все примеры и контрольные языки','TitleLMX'),p('23 ноября 2026 года · Haskell / Julia / Perl / SBCL','SmallLMX'),
        p(f"{data['counts']['lmx_examples']} сценария LMX, {data['counts']['complete_pairs']} полных сопоставимых пар. Исходные 24 сценария сохранены. В Julia, Perl и Common Lisp/SBCL добавлены самостоятельные характерные подборки; реализация библиотек учитывается отдельно."),
        style.highlight_minimums(table(['Набор','Сценарии','Полные пары','Аналогии','Только LMX','LMX, пары','без сложного\nThrows','Контроль, пары','Контроль / LMX'],
            [[x['foreign_language'],x['examples'],x['complete_pairs'],x['related_analogies'],x['lmx_only'],x['paired_lmx_characters'],x['paired_lmx_without_complex_throws_characters'],x['paired_foreign_characters'],f"{x['paired_ratio']:.3f}×" if x['paired_ratio'] else '—'] for x in data['summaries']],
            [110,60,70,65,70,85,95,90,100]),[(i+1,(5,x['paired_lmx_characters']),(6,x['paired_lmx_without_complex_throws_characters']),[(7,x['paired_foreign_characters'])]) for i,x in enumerate(data['summaries'])]),Spacer(1,12),*method(),
        p('Машинные данные: STATISTICS.json, STATISTICS.csv, IMPLEMENTATIONS.csv и SOURCE_INVENTORY.json. Полные договоры и границы Haskell-аналогий: haskell/comparison_index.json.','SmallLMX')]
    for summary in data['summaries']:
        suite=summary['suite'];language=summary['foreign_language'];rows=[x for x in data['examples'] if x['suite']==suite]
        story.extend([PageBreak(),p(language+': основные примеры','TitleLMX'),cases(rows,language)])
        if suite=='haskell':
            story.append(p('Поясняющие аналогии и случаи без Haskell-пары сохраняются в каталоге. Их частичный или отсутствующий листинг не участвует в коэффициентах. Величины для полных пар могут включать явно указанную нормализацию результата (например, tuple вместо десятичной упаковки).','SmallLMX'))
    story.extend([PageBreak(),p('Самостоятельные реализации','TitleLMX'),
        p('Таблица отделена от клиентов. Общие зависимости LMX могут пересекаться между строками; сумма таких замыканий не является размером единственного приложения. Исходники, договоры и официальные источники находятся в library_comparisons каждого набора.')])
    story.append(implementations(sorted(data['implementations'],key=lambda x:(x['suite'],x['id'])),all_suites=True))
    target=ROOT/'STATISTICS.pdf';doc(target,'LMX: все примеры').build(story,onFirstPage=footer,onLaterPages=footer);generated.append(target.relative_to(ROOT).as_posix())
    for suite,language in [('julia','Julia'),('perl','Perl')]:
        style.CURRENT_FILE='examples/'+suite+'_comparison/LMX_Comparison_'+language+'.pdf'
        summary=next(x for x in data['summaries'] if x['suite']==suite)
        rows=[x for x in data['examples'] if x['suite']==suite]
        impl=[x for x in data['implementations'] if x['suite']==suite]
        story=[p('LMX / '+language,'TitleLMX'),p('Характерные примеры · 23 ноября 2026','SmallLMX'),
            p(f"{len(rows)} сценария. Сумма по полным парам: LMX {summary['paired_lmx_characters']}, {language} {summary['paired_foreign_characters']} непробельных символов; отношение {summary['paired_ratio']:.3f}×."),cases(rows,language)]
        if impl:story.extend([PageBreak(),p('Реализации библиотечных операций','TitleLMX'),implementations(impl),Spacer(1,10),p('В этих строках считаются полные явно приведённые тела реализации. Общая инфраструктура и ссылки на зависимости указаны в каждом сравнении. Клиентские программы сравнительные helpers не импортируют.','SmallLMX')])
        story.extend([Spacer(1,10),*method()])
        target=ROOT/(suite+'_comparison')/('LMX_Comparison_'+language+'.pdf');doc(target,'LMX / '+language).build(story,onFirstPage=footer,onLaterPages=footer);generated.append(target.relative_to(ROOT).as_posix())
    (ROOT/'validation/pdf_generation_20261123.json').write_text(json.dumps({'edition':'2026-11-23','files':generated,'source':'STATISTICS.json','source_sha256':hashlib.sha256((ROOT/'STATISTICS.json').read_bytes()).hexdigest(),'generator_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'tables':style.TABLE_AUDIT,'green_cells':style.GREEN_AUDIT,'visual_review':'separate report'},ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'generated':generated}))

if __name__=='__main__':main()

#!/usr/bin/env python3
"""Build a compact, reproducible reading report; sources remain in Markdown."""
from pathlib import Path
import json
from xml.sax.saxutils import escape
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT, TA_RIGHT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Preformatted

ROOT=Path(__file__).resolve().parents[1]
FONT=Path('/usr/share/fonts/truetype/dejavu')
for name,file in [('Body','DejaVuSans.ttf'),('Bold','DejaVuSans-Bold.ttf'),('Mono','DejaVuSansMono.ttf')]:
    pdfmetrics.registerFont(TTFont(name,str(FONT/file)))
ink=colors.HexColor('#17324D');muted=colors.HexColor('#526171');rule=colors.HexColor('#DCE4EB');band=colors.HexColor('#F2F5F8')
styles={
 'title':ParagraphStyle('title',fontName='Bold',fontSize=18,leading=22,textColor=ink,spaceAfter=7),
 'sub':ParagraphStyle('sub',fontName='Bold',fontSize=12,leading=16,textColor=ink,spaceBefore=8,spaceAfter=6),
 'body':ParagraphStyle('body',fontName='Body',fontSize=9,leading=12,textColor=ink,spaceAfter=6),
 'small':ParagraphStyle('small',fontName='Body',fontSize=8,leading=11,textColor=muted,spaceAfter=5),
 'cell':ParagraphStyle('cell',fontName='Body',fontSize=8,leading=10,textColor=ink),
 'header':ParagraphStyle('header',fontName='Bold',fontSize=8,leading=10,textColor=colors.white),
 'winner':ParagraphStyle('winner',fontName='Bold',fontSize=8,leading=10,textColor=colors.HexColor('#176233')),
 'code':ParagraphStyle('code',fontName='Mono',fontSize=8.3,leading=10.3,textColor=ink,leftIndent=9,backColor=band,spaceBefore=5,spaceAfter=8),
}
def p(text,style='body'):return Paragraph(escape(str(text)),styles[style])
def minimum_cells(row,full=2,adjusted=3,foreign=4):
    smallest=min(row[full],row[adjusted],row[foreign]);selected=adjusted if row[adjusted]<row[full] else full
    return {i for i in (selected,foreign) if row[i]==smallest}

def table(rows,widths,header=True,winners=None,padding=3):
    winners=winners or set()
    cells=[[p(v,'header' if header and i==0 else 'winner' if (j,i) in winners else 'cell') for j,v in enumerate(row)] for i,row in enumerate(rows)]
    t=Table(cells,colWidths=widths,repeatRows=1 if header else 0,hAlign='LEFT')
    commands=[('VALIGN',(0,0),(-1,-1),'MIDDLE'),('TOPPADDING',(0,0),(-1,-1),padding),('BOTTOMPADDING',(0,0),(-1,-1),padding),('LEFTPADDING',(0,0),(-1,-1),6),('RIGHTPADDING',(0,0),(-1,-1),6),('LINEBELOW',(0,-1),(-1,-1),0.5,rule)]
    if header:commands += [('BACKGROUND',(0,0),(-1,0),ink)]
    for i in range(1 if header else 0,len(rows)):
        if i%2==0:commands.append(('BACKGROUND',(0,i),(-1,i),band))
    for cell in sorted(winners):commands += [('BACKGROUND',cell,cell,colors.HexColor('#DDF0DF')),('TEXTCOLOR',cell,cell,colors.HexColor('#176233'))]
    t.setStyle(TableStyle(commands));return t
def footer(canvas,doc):
    canvas.saveState();canvas.setStrokeColor(rule);canvas.line(32,25,810,25)
    canvas.setFont('Body',7);canvas.setFillColor(muted);canvas.drawString(32,14,'LMX / Common Lisp на SBCL · 23-Nov-2026 · полные исходники и договоры в каталоге')
    canvas.drawRightString(810,14,str(doc.page));canvas.restoreState()

def main():
    s=json.loads((ROOT/'statistics.json').read_text());deps=json.loads((ROOT/'validation/implementation_dependencies.json').read_text())
    expression=json.loads((ROOT/'validation/expression_review.json').read_text());cl=json.loads((ROOT/'validation/common_lisp.json').read_text());ref=json.loads((ROOT/'validation/implementation_execution.json').read_text())
    story=[p('LMX / Common Lisp на SBCL','title'),p('24 сценария · 23 полные пары + S24 отдельно · 6 пар реализаций · полный аудит 978 COMMON-LISP символов','small')]
    rows=[['ID','Задача','LMX полный','Без сложного Throws','Lisp полный','Lisp / LMX']]
    winners=set()
    for r in s['examples']:
        rows.append([r['id'],r['title'],r['lmx']['characters_nonwhitespace'],r['lmx']['without_complex_throws_characters'],r['foreign']['characters_nonwhitespace'],f"{r['ratio_foreign_over_lmx']:.3f}" if r['ratio_foreign_over_lmx'] is not None else 'вне итога'])
        if r['comparison_status']=='complete_pair':winners.update((c,len(rows)-1) for c in minimum_cells(rows[-1]))
    t=s['paired_totals'];rows.append(['Итого','23 полные пары',t['lmx']['characters_nonwhitespace'],t['lmx']['without_complex_throws_characters'],t['foreign']['characters_nonwhitespace'],f"{t['ratio_foreign_over_lmx']:.3f}"])
    winners.update((c,len(rows)-1) for c in minimum_cells(rows[-1]))
    story.append(table(rows,[42,318,82,102,82,88],winners=winners,padding=2.4));story.append(Spacer(1,7))
    story.append(p('Размер — Unicode-символы без пробельных. Коэффициент использует полный текст. Зелёный — минимум сопоставимой строки: LMX без сложного Throws, если короче, иначе полный; равенства разных языков сохранены. S24 требует host/parser fixture и исключён из итога и подсветки. Это не замер скорости или памяти.','small'))
    story.append(PageBreak())
    story += [p('Алгоритмы, зависимости и проверка','title'),p('Клиенты Common Lisp используют настоящую стандартную библиотеку. Отдельные reference-реализации показывают сравнимые алгоритмы и не загружаются клиентским стендом.','body')]
    rows=[['ID','Реализуемая задача','LMX полный','Без сложного Throws','Lisp полный']]
    winners=set()
    for r in s['implementations']:
        rows.append([r['id'],r['title'],r['lmx']['characters_nonwhitespace'],r['lmx']['without_complex_throws_characters'],r['foreign']['characters_nonwhitespace']])
        winners.update((c,len(rows)-1) for c in minimum_cells(rows[-1]))
    story.append(table(rows,[40,370,90,115,99],winners=winners));story.append(Spacer(1,9))
    rows=[['Общая инфраструктура','Полный размер','Без сложного Throws'],
          [f"Уникальное замыкание LMX: {deps['unique_definitions']} определений",deps['unique_lmx_total']['characters_without_whitespace'],deps['unique_lmx_total']['without_complex_throws_characters']],
          ['LMX: общая часть вне шести первичных тел',deps['shared_not_in_primary']['characters_without_whitespace'],deps['shared_not_in_primary']['without_complex_throws_characters']],
          ['Common Lisp: общая инфраструктура',deps['common_lisp_runtime']['characters_without_whitespace'],'—']]
    story.append(table(rows,[500,104,110]));story += [p('Общие зависимости считаются один раз. Внешний FxKernel — реальная граница интеграции; отсутствие его native-кода в этом отчёте не означает нулевую стоимость.','small'),p('Десять функций общего ядра из этого аудита','sub')]
    story.append(table([
        ['Задача','Добавленные функции'],
        ['Ассоциации','assoc, pairlis'],
        ['Свойства','getProperty, setProperty, removeProperty, getProperties'],
        ['Последовательности','mismatch, searchSequence, substitute'],
        ['Expression','asOperand — одно тело, обычный left/right template']],[180,534]))
    story += [Spacer(1,8),p(f"Фактически выполнено SBCL: {cl['passed']}/{cl['expected_assertions']} клиентских проверок и {ref['checks']} проверок reference-реализаций. LMX runtime: NOT_RUN; подготовлены исходники и 42 пункта приёмки новых функций.",'body'),p('Явные Throws и copy(Throws) — преимущество LMX: видны объявленные ошибки. Дополнительная колонка сохраняет заголовок и первый аргумент; copy и ссылки остаются целиком. Исходники и основной коэффициент не сокращены.','small')]
    story.append(PageBreak())
    story += [p('Один Expression, один myOp','title'),p('Один обычный operand допускает оба положения. Обычная функция становится таким операндом через написанный общий asOperand; её результат R/void и имена ошибок сохраняются.','body'),Preformatted((ROOT/'source/lmx/Expression_examples.lm3').read_text().rstrip(),styles['code'])]
    em=expression['example']['metrics'];am=expression['asOperand']['primary'];dm=expression['asOperand']['unique_dependency_metrics']
    story.append(table([['Что посчитано','Полный размер','Без сложного Throws'],['E01 полностью, настройка включена',em['characters_nonwhitespace'],em['without_complex_throws_characters']],['Одно тело asOperand',am['characters_nonwhitespace'],am['without_complex_throws_characters']],['Уникальное замыкание asOperand',dm['characters_nonwhitespace'],dm['without_complex_throws_characters']]],[500,104,110]))
    story += [p('Ожидаемый результат E01: [15,15]. Настройка и зависимости посчитаны явно; этот дополнительный пример не включён в коэффициент 23 пар. Ни нового вида операнда, ни второго парсера нет.','small'),p('Сокращения в основных примерах','sub'),Preformatted('S11: return: (+ 0 copy(items))\n\nS17: int[]: odd compress(items; items % 2 != 0)\n     return: (+ 0 copy(odd * odd))',styles['code']),p('copy(items) выдаёт явный поток полей. Произвольный Array не раскрывается автоматически. S17 сначала отбирает нечётные элементы, поэтому не вычисляет квадраты исключённых значений. Для одиночного sort/compress локальная настройка asOperand длиннее прямого вызова: короткий полный вариант сохранён. Все 24 решения изложены в EXPRESSION_REVIEW.md.','body')]
    story.append(PageBreak())
    story += [p('978 символов: охват и реальные границы','title'),p('Список фактически перечислен через do-external-symbols в SBCL 2.2.9.debian. Каждая запись классифицирована в COMMON_LISP_COVERAGE.json/.csv и COMMON_LISP_SYMBOLS.md. Классификация задачи не означает полной семантической совместимости или пройденного LMX runtime.','body')]
    gaprows=[['Группа','Родное решение / остающаяся граница'],
        ['L01 · Multiple values','Структурный результат и явное раскрытие; не скрытая CL-арность values'],
        ['L02 · Symbols/packages','Имена, import и пути; точная CL symbol identity отдельно'],
        ['L03 · Reader/macros','Единый P0, raw receivers, sys\\eval; полный macro environment не подменён'],
        ['L04 · CLOS/MOP','Структуры и методы; multiple dispatch/method combination явно не обещаны'],
        ['L05 · Restarts','Именованные ошибки и finally; возобновление чужого стека требует договора'],
        ['L06 · FORMAT','Общие text API и positional format; весь FORMAT DSL не объявлен готовым'],
        ['L07 · I/O/OS/network','Реальные host/provider функции, units, encoding и lifetime'],
        ['L08 · Time/random','Фактические clock/entropy/state profiles, без подмены константами'],
        ['L09 · Hash tables','Честные линейные assoc/memo; hash/equality/weak contracts отдельно'],
        ['L10 · Numeric profile','Обычная арифметика и числовые семьи; точные math/float profiles отдельно'],
        ['L11 · Unicode','Версионированные таблицы; ASCII не называется стандартным Unicode'],
        ['L12 · Cons/trees','Родные Arrays/графы с сохранением нужной identity и shared nodes'],
        ['L13 · Toolchain','Явная компиляция и реальное наблюдение работающего executor']]
    story.append(table(gaprows,[170,544]));story += [Spacer(1,10),p('SBCL-расширения сверх COMMON-LISP дополнительно рассмотрены по публичным семействам: threads, FFI, streams, OS/network, Unicode, MOP, GC, timers, profiler и SIMD. Это обзор публичных возможностей, а не обещание перечислить все внутренние symbols реализации.','body'),p('Источники и воспроизведение: официальные CLHS и SBCL Manual; ссылки, команды, source hashes, границы интеграции и манифесты находятся в README.md, VALIDATION.md и TZ_Standard_Lisp_and_Expression.md. Полные клиентские и библиотечные листинги находятся в отдельных .md/.lm3/.lisp, а не обрезаны до фрагментов этого отчёта.','small')]
    path=ROOT/'LMX_Comparison_SBCL.pdf'
    doc=SimpleDocTemplate(str(path),pagesize=landscape(A4),leftMargin=32,rightMargin=32,topMargin=30,bottomMargin=34,title='LMX / Common Lisp на SBCL',author='LMX comparison')
    doc.build(story,onFirstPage=footer,onLaterPages=footer)
    print(json.dumps({'file':str(path),'bytes':path.stat().st_size},ensure_ascii=False))


if __name__=='__main__':main()

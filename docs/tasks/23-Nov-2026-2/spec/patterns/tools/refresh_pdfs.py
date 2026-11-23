#!/usr/bin/env python3
"""Render current pattern metrics and summary with ReportLab; no language runs."""
from pathlib import Path
from html import escape
import json,hashlib
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,Table,TableStyle,PageBreak
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4,landscape
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

ROOT=Path(__file__).resolve().parents[1]
THROWS_NOTE='Я считаю явные конечные ошибки и общий Throws/copy(Throws) преимуществом LMX: видно, какой метод что порождает. Сокращать эти записи ради размера не хочется. «Без сложного Throws» оставляет заголовок и первый написанный аргумент списка в исходном порядке; ссылки/copy считаются полностью, общий банк - один раз, также с первым аргументом. Исходники, полные размеры и отношения сохраняются. Зелёный - минимум сопоставимых значений; при равных счётчиках LMX выделена полная колонка.'
CURRENT_FILE=''
TABLE_AUDIT=[]
GREEN_AUDIT=[]
GREEN='#D9EEDB'
LAYERS=('scenario','usage','shared_implementation_client','implementation')
LAYER_LABELS={'scenario':'Сценарий','usage':'Клиент','shared_implementation_client':'Общий клиент','implementation':'Реализация'}
SUMMARY_LABELS={'scenario':'Сценарии','usage':'Клиенты','shared_implementation_client':'Клиенты общего компонента','implementation':'Реализации'}

FONTS=Path('/usr/share/fonts/truetype/noto')
if not (FONTS/'NotoSans-Regular.ttf').exists():
    FONTS=Path('/usr/share/fonts/truetype/dejavu');REG='DejaVuSans.ttf';BOLD='DejaVuSans-Bold.ttf'
else:REG='NotoSans-Regular.ttf';BOLD='NotoSans-Bold.ttf'
pdfmetrics.registerFont(TTFont('LMX',str(FONTS/REG)));pdfmetrics.registerFont(TTFont('LMXBold',str(FONTS/BOLD)))
pdfmetrics.registerFontFamily('LMX',normal='LMX',bold='LMXBold')
ST=getSampleStyleSheet()
for name,font,size,leading,color in [('TitleLMX','LMXBold',19,24,'#18344C'),('HeadingLMX','LMXBold',12,16,'#18344C'),('TextLMX','LMX',9,12,'#243B4B'),('SmallLMX','LMX',8,11,'#4E5E6D'),('CellLMX','LMX',8.4,11,'#243B4B'),('HeadLMX','LMXBold',8.4,11,'#FFFFFF'),('MinCellLMX','LMXBold',8.4,11,'#155B29')]:
    ST.add(ParagraphStyle(name=name,fontName=font,fontSize=size,leading=leading,textColor=colors.HexColor(color),spaceAfter=7 if name not in ('CellLMX','HeadLMX','MinCellLMX') else 0))
def p(s,style='TextLMX'):
    return Paragraph(escape(str(s).replace('—','-').replace('–','-').replace('‑','-')).replace('\n','<br/>'),ST[style])
def footer(c,doc):
    w,h=landscape(A4);c.setStrokeColor(colors.HexColor('#CFD8E0'));c.line(36,32,w-36,32)
    c.setFillColor(colors.HexColor('#4E5E6D'));c.setFont('LMX',7)
    c.drawString(36,20,'LMX - статистика основных листингов - 23 ноября 2026');c.drawRightString(w-36,20,str(doc.page))
def doc(target,title):return SimpleDocTemplate(str(target),pagesize=landscape(A4),rightMargin=36,leftMargin=36,topMargin=30,bottomMargin=44,title=title,author='LMX documentation')
def table(headers,rows,widths):
    values=[[p(x,'HeadLMX') for x in headers]]+[[p(x,'CellLMX') for x in row] for row in rows]
    widths=[w*(landscape(A4)[0]-72)/sum(widths) for w in widths]
    t=Table(values,colWidths=widths,repeatRows=1,hAlign='LEFT')
    padding=2.4 if CURRENT_FILE.startswith('05_') else 3
    t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#233D55')),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),padding),('BOTTOMPADDING',(0,0),(-1,-1),padding),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,colors.HexColor('#F0F3F6')])]))
    t._audit_index=len(TABLE_AUDIT)
    TABLE_AUDIT.append({'file':CURRENT_FILE,'headers':headers,'row_count':len(rows),'column_count':len(headers)})
    return t

def minimum_cells(pairs, foreign):
    """Equivalent to report_minima.mjs: one candidate per LMX pair.

    Cells are (column, row, value); ties between full/adjusted retain full.
    Every equally minimal foreign/current-alternative candidate is highlighted.
    """
    candidates=[extra if extra[2] < full[2] else full for full,extra in pairs]+list(foreign)
    minimum=min(cell[2] for cell in candidates)
    return [cell for cell in candidates if cell[2]==minimum]

def mark_minimums(tab, pairs, foreign, label):
    selected=minimum_cells(pairs,foreign)
    commands=[]
    for column,row,value in selected:
        commands.append(('BACKGROUND',(column,row),(column,row),colors.HexColor(GREEN)))
        tab._cellvalues[row][column]=p(tab._cellvalues[row][column].getPlainText(),'MinCellLMX')
    tab.setStyle(TableStyle(commands))
    GREEN_AUDIT.append({'file':CURRENT_FILE,'table_index':tab._audit_index,'comparison':label,
                        'pairs':pairs,'foreign':foreign,'selected':selected})
    return tab

def highlight_minimums(tab, rows):
    """Rows: row, full cell, extra cell, foreign cells, optional extra pairs."""
    for entry in rows:
        row,full,extra,foreign=entry[:4]
        other=entry[4] if len(entry)>4 else []
        pairs=[((full[0],row,full[1]),(extra[0],row,extra[1]))]
        pairs.extend(((left[0],row,left[1]),(right[0],row,right[1])) for left,right in other)
        mark_minimums(tab,pairs,[(col,row,value) for col,value in foreign],f'row {row}')
    return tab

def main():
    global CURRENT_FILE
    stats=json.loads((ROOT/'validation/statistics_20261122.json').read_text());generated=[]
    for g in stats['groups']:
        CURRENT_FILE=g['directory']+'/LMX_Comparison_'+g['directory']+'.pdf'
        jp=ROOT/g['directory']/'patterns.json';data=json.loads(jp.read_text());a,b=g['languages'][1:]
        story=[p(g['title'],'TitleLMX'),p(f'LMX / {a} / {b}; {g["pattern_count"]} паттернов + {g["implementation_count"]} реализаций; 23 ноября 2026','SmallLMX'),p(data['rationale_ru'])]
        if g['directory']=='09_functional_computation':
            story.append(p('Общие ресиверы и контейнеры вместо int-специализаций. Отдельно сохранены реализации и действительно разные подходы. Основной листинг выбирается среди корректных вариантов того же договора. Все операции относятся к одному ядру; его реализация посчитана отдельно.'))
        else:story.append(p(data['overview_ru']))
        rows=[]
        for x in g['records']:
            m=x['metrics'];nums=[f"{m[l]['characters']} / {m[l]['nonblank_lines']}" for l in g['languages']]
            rows.append([f"{x['id']:03d}",x['name'],nums[0],m['LMX']['without_complex_throws_characters'],*nums[1:],LAYER_LABELS[x['layer']]])
        story += [Spacer(1,4),highlight_minimums(table(['ID','Сравнение','LMX\nсимв. / стр.','без сложного\nThrows',a+'\nсимв. / стр.',b+'\nсимв. / стр.','Слой'],rows,[32,230,85,95,100,100,85]),[(i+1,(2,x['metrics']['LMX']['characters']),(3,x['metrics']['LMX']['without_complex_throws_characters']),[(4,x['metrics'][a]['characters']),(5,x['metrics'][b]['characters'])]) for i,x in enumerate(g['records'])]),Spacer(1,10),p('Граница подсчёта','HeadingLMX'),p('Символы - непробельные Unicode-символы основного листинга, включая его комментарии; строки - непустые. Альтернативы исключены. Необходимые вызовы и объявления включены. Библиотечный уровень допустим при сопоставимой операции контрольного языка; общий код ядра показан отдельно и учитывается один раз при сравнении реализации.','SmallLMX')]
        if g['directory']=='09_functional_computation':
            dep=stats['functional_library_dependencies'];u=dep['unique_required_total'];aliases=sum(x['characters'] for x in dep['public_bundle'])
            story.append(p(f"Общие определения {len(dep['components'])} учитываемых LMX-компонентов без повторов: {u['characters']} символов / {u['lines']} строк; без сложного Throws - {u['without_complex_throws_characters']} символов. В их числе дополнительный curry-механизм клиента 085; он не создаёт нового сравнительного сценария. Внутренний набор экспортов ядра: ещё {aliases} символов один раз. Реестр: IMPLEMENTATION_DEPENDENCIES.md. В 099 показаны произвольные префиксы и неоднородные типы во всех трёх реализациях; способы выражения остаточной сигнатуры различаются.",'SmallLMX'))
        story += [p('Полные сценарии, исходники, зависимости и границы находятся в NNN_*_comparision.md, patterns.json и examples/. Эти числа не являются измерением скорости или отчётом о выполнении LMX.','SmallLMX')]
        story.append(p(THROWS_NOTE,'SmallLMX'))
        target=ROOT/g['directory']/f"LMX_Comparison_{g['directory']}.pdf";doc(target,'LMX: '+g['title']).build(story,onFirstPage=footer,onLaterPages=footer);generated.append(target.relative_to(ROOT).as_posix())
    CURRENT_FILE='STATISTICS_2026-11-22.pdf'
    story=[p('LMX: сводная статистика','TitleLMX'),p('Редакция 23 ноября 2026 года','SmallLMX'),p('90 паттернов и 9 реализаций библиотек: 99 сравнений, 297 основных листингов. Отдельно сохранены 23 GoF-сравнения (184 листинга) и 24 исходных примера LMX. Новые наборы Julia/Perl/SBCL и статистика всей examples опубликованы отдельно в examples/STATISTICS.*. Существенно разные подходы доступны рядом; малозначимые дубли удалены. Основным выбран самый короткий корректный вариант с сопоставимой границей подсчёта.')]
    rows=[]
    for g in stats['groups']:
        for layer in LAYERS:
            count=sum(x['layer']==layer for x in g['records'])
            if not count:continue
            t=g['totals'][layer];a,b=g['languages'][1:]
            rows.append([g['title'],SUMMARY_LABELS[layer],count,t['LMX']['characters'],t['LMX']['without_complex_throws_characters'],a,t[a]['characters'],b,t[b]['characters']])
    story += [highlight_minimums(table(['Группа','Слой','N','LMX','без сложного\nThrows','Контроль 1','Симв.','Контроль 2','Симв.'],rows,[180,75,25,60,90,80,60,80,60]),[(i+1,(3,row[3]),(4,row[4]),[(6,row[6]),(8,row[8])]) for i,row in enumerate(rows)]),Spacer(1,10),p('Разные группы имеют разные контрольные языки и сценарии. Суммарный рейтинг языков по этим неодинаковым наборам не строится. Слои клиентов и реализаций не смешиваются.','SmallLMX'),PageBreak(),p('Функциональные реализации и зависимости','TitleLMX')]
    shared_rows=[]
    for component in stats['shared_implementation_components']:
        label=str(component['implementation_id'])+' / '+', '.join(f'{n:03d}' for n in component['usage_ids'])
        for language,cost in component['costs'].items():
            shared_rows.append([label,language,cost['clients'],cost['helper_once'],cost['complete_component'],cost.get('without_complex_throws_characters','-')])
    if shared_rows:
        shared_table=table(['Компонент / клиенты','Язык','Клиенты','Helper один раз','Полный размер','LMX без сложного Throws'],shared_rows,[170,90,100,120,130,170])
        for index,component in enumerate(stats['shared_implementation_components']):
            start=index*len(component['costs'])+1
            rows_by_lang={language:start+offset for offset,language in enumerate(component['costs'])}
            lm=component['costs']['LMX'];lmx_row=rows_by_lang['LMX']
            mark_minimums(shared_table,[((4,lmx_row,lm['complete_component']),(5,lmx_row,lm['without_complex_throws_characters']))],[(4,rows_by_lang[language],cost['complete_component']) for language,cost in component['costs'].items() if language!='LMX'],label)
        story += [p('Синхронные клиенты и весь общий helper','HeadingLMX'),shared_table,p('Клиенты 039/045 используют компонент 097 во всех трёх языках. Полная сумма включает оба клиента и helper один раз. Отдельный client + helper указан в JSON. Ни импорт, ни принадлежность исходника ядру не исключают эту реализацию из указанной полной суммы.','SmallLMX'),Spacer(1,6)]
    dep=stats['functional_library_dependencies'];rows=[]
    for x in dep['components']:
        a=x['primary'];b=x['shared'];label=f"{x['id']:03d}"+(' / curry клиента' if x.get('role')=='usage_companion' else '');rows.append([label,f"{a['characters']} / {a['lines']}",a['without_complex_throws_characters'],f"{b['characters']} / {b['lines']}",b['without_complex_throws_characters'],a['characters']+b['characters'],a['without_complex_throws_characters']+b['without_complex_throws_characters']])
    story += [table(['Компонент','Основное тело\nсимв. / стр.','Тело без сложного Throws','Зависимости\nсимв. / стр.','Зависимости без сложного Throws','Вместе, символы','Вместе без сложного Throws'],rows,[90,125,105,130,110,100,120]),Spacer(1,10)]
    u=dep['unique_required_total'];alias=sum(x['characters'] for x in dep['public_bundle'])
    story += [p(f"Все {len(dep['components'])} компонентов с устранением повторов: {u['characters']} символов / {u['lines']} строк; без сложного Throws - {u['without_complex_throws_characters']} символов. Внутренний набор экспортов добавляет {alias} символов один раз. Столбец зависимостей выше нельзя суммировать без удаления повторов.")]
    story += [p('Код адаптеров FxKernel должен быть реализован в настоящем ядре. Он не выдаётся за уже выполненную библиотеку или за компонент нулевого размера. В 099 контрольные реализации также обобщены на произвольный префикс; прикладные клиенты используют средства своих языков.','SmallLMX'),PageBreak(),p('Корневые примеры: изменённые варианты','TitleLMX')]
    rows=[]
    for x in stats['functional_receiver_counts']['rows']:
        if x['changed']:rows.append([x['id'],x['before']['characters'],x['after']['characters'],x['after']['without_complex_throws_characters'],x['after']['characters']-x['before']['characters'],f"{x['before']['nonblank_lines']} / {x['after']['nonblank_lines']}"])
    story += [table(['Пример','Символы до','Символы после','без сложного\nThrows','Изменение','Строки до / после'],rows,[80,120,120,120,120,160]),Spacer(1,10),p('Сравнение до/после относится к исторической базе, отмеченной в examples/validation, и текущей редакции; оно не служит основанием выбирать длинный вариант. Текущие альтернативы проверяются на один договор задачи и сравнимый уровень ядра; выбор основного и размеры обоих приведены отдельно.','SmallLMX'),PageBreak(),p('Исходные 24 примера LMX','TitleLMX')]
    rows=[[x['id'],x['characters'],x['without_complex_throws_characters'],x['nonblank_lines'],'Да' if x['procedural_archived'] else 'Нет'] for x in stats['root_examples']]
    story += [table(['Пример','Основные символы','без сложного\nThrows','Непустые строки','Второй вариант рядом'],rows,[120,165,160,145,190]),PageBreak(),p('Исходная подборка GoF','TitleLMX'),p('Все 184 основных листинга повторно пересчитаны. Все договоры сохранены; Visitor и Abstract Factory сокращены общим кодом и copy/merge. В Flyweight исправлен отступ return; width остаётся во всех языках.')]
    rows=[[lang,n,stats['gof']['total_without_complex_throws_characters'] if lang=='LMX' else '—'] for lang,n in stats['gof']['total_characters'].items()]
    vertical=table(['Язык','Непробельных символов','без сложного\nThrows'],rows,[270,260,250])
    lmx_row=next(i+1 for i,row in enumerate(rows) if row[0]=='LMX')
    mark_minimums(vertical,[((1,lmx_row,rows[lmx_row-1][1]),(2,lmx_row,rows[lmx_row-1][2]))],[(1,i+1,row[1]) for i,row in enumerate(rows) if row[0]!='LMX'],'all GoF languages')
    story += [vertical,Spacer(1,15),p('Метод и проверка','HeadingLMX'),p('Источник всех чисел: основные строки кода в patterns.json, отдельные .lm3 и помеченные прикладные блоки корневых Markdown. Нормализация LF, удаление пустых строк по краям, один LF в конце. Unicode-символы, для которых isspace=false, считаются по одному. В JSON также сохранены UTF-8-байты и SHA-256.'),p('Эти измерения описывают конкретные исходники. Они не подтверждают runtime-корректность, одинаковую универсальность всех реализаций, скорость или расход памяти. Проверки публикации и формул отделены от будущей приёмки LMX на ядре.'),p('Полные данные: validation/statistics_20261122.json. Текстовая сводка и CSV/XLSX: STATISTICS_2026-11-22.*. Групповые PDF/Excel находятся в девяти каталогах сравнения.','SmallLMX')]
    story += [p('Клиенты и реализации ядра считаются раздельно. Самостоятельные подходы сохранены как пояснение; мелкие различия описаны текстом. Для 085 показаны сопоставимые curry/partial. В 084 основной клиент использует bracket ядра; контрольные клиенты используют Control.Exception.bracket и scala.util.Using. Локальная композиция Around сохранена как отдельный подход. Полные основания выбора находятся в patterns.json и Markdown.','SmallLMX')]
    story += [PageBreak(),p('Выбор основного варианта','TitleLMX'),p('Сначала проверяется один договор задачи и сопоставимый уровень подсчёта, затем выбирается минимум по символам. Архитектурные преимущества динамического LMX сохраняются; одинаковое устройство алгоритмов не требуется. Все варианты работают в одном текущем ядре, а исторические листинги не подключаются как другие версии библиотек.')]
    choices=[]
    for x in stats['functional_receiver_counts']['rows']:
        if not x.get('has_alternative'):continue
        selected=x['selected_variant'];alternate=x['alternative_variant'];eligible=x.get('eligible_variants',list(x['variants']))
        choices.append([x['id'],selected,x['variants'][selected]['characters'],x['variants'][selected]['without_complex_throws_characters'],x['variants'][alternate]['characters'],x['variants'][alternate]['without_complex_throws_characters'],'Да' if alternate in eligible else 'Нет: другой договор'])
    if choices:story += [highlight_minimums(table(['Пример','Основной вариант','Основной, символы','Основной без сложного Throws','Второй, символы','Второй без сложного Throws','Второй сопоставим'],choices,[60,140,95,120,95,120,150]),[(i+1,(2,row[2]),(3,row[3]),[],[((4,row[4]),(5,row[5]))]) for i,row in enumerate(choices) if row[6]=='Да']),Spacer(1,8)]
    story += [p('Полное основание выбора записано рядом с каждым примером и в examples/validation/functional_receiver_counts.json. Более короткий код, который убирает реальные raw-occurrences, поля или эффекты, не заменяет исходный сценарий.','SmallLMX'),p('Функциональная группа: текущие варианты','HeadingLMX')]
    choices=[]
    variant_metrics={(row['id'],row['variant']):row['without_complex_throws_characters'] for row in stats['throws_variant_metrics']}
    for x in json.loads((ROOT/'09_functional_computation/patterns.json').read_text())['patterns']:
        active=x.get('primary_variant',{}).get('LMX','core')
        variants=x.get('variants',{}).get('LMX',{})
        alternatives=[n for n in variants if n!=active]
        if not alternatives:continue
        code=next(y['code'] for y in x['listings'] if y['language']=='LMX')
        for name in alternatives:
            old=variants[name]
            note=x.get('variant_descriptions',{}).get(name, name)
            if not isinstance(note,str):note=str(note)
            if x['id']==84:note='Ядерный bracket / локальная композиция Around; в основной таблице клиент ядра'
            if x['id']==85:note='Поэтапное связывание curry / захват префикса partial'
            choices.append([f"{x['id']:03d}",sum(not c.isspace() for c in code),variant_metrics[(x['id'],active)],sum(not c.isspace() for c in old),variant_metrics[(x['id'],name)],note])
    if choices:story += [highlight_minimums(table(['ID','Основной LMX','Основной без сложного Throws','Второй LMX','Второй без сложного Throws','Другой подход'],choices,[50,105,120,100,120,285]),[(i+1,(1,row[1]),(2,row[2]),[],[((3,row[3]),(4,row[4]))]) for i,row in enumerate(choices)])]
    story.append(p(THROWS_NOTE,'SmallLMX'))
    target=ROOT/'STATISTICS_2026-11-22.pdf';doc(target,'LMX: статистика 23 ноября 2026').build(story,onFirstPage=footer,onLaterPages=footer);generated.append(target.name)
    gof=json.loads((ROOT/'validation/gof_statistics_20261122.json').read_text())
    languages=['LMX','Python','Java','C++','C#','TypeScript','Go','Rust']
    for filename,first,last,label in [('LMX_Comparison_2026-11-20.pdf',1,9,'1–9'),('LMX_Comparison_10-18.pdf',10,18,'10–18'),('LMX_Comparison_19-23.pdf',19,23,'19–23')]:
        CURRENT_FILE=filename
        records=[x for x in gof['records'] if first<=x['id']<=last];totals=gof['aggregates'][label]['totals'];rows=[]
        for x in records:rows.append([x['title'],*[x['metrics'][l]['characters'] for l in languages],x['metrics']['LMX']['without_complex_throws_characters']])
        adjusted=sum(x['metrics']['LMX']['without_complex_throws_characters'] for x in records)
        rows.append(['Итого',*[totals[l] for l in languages],adjusted])
        rows.append(['Итого / LMX',*[f"{totals[l]/totals['LMX']:.3f}×" for l in languages],'—'])
        story=[p(f'LMX: паттерны {label}','TitleLMX'),p(f'{len(records)} сценариев, восемь языков; 23 ноября 2026','SmallLMX'),p('Непробельные символы полных основных листингов. Из корректных сопоставимых вариантов выбран самый короткий; альтернативы и исходники ядра приведены отдельно в соответствующем сравнении.'),highlight_minimums(table(['Сценарий',*languages,'без сложного\nThrows'],rows,[195,62,62,62,62,62,62,62,62,100]),[(i+1,(1,row[1]),(9,row[9]),[(j,row[j]) for j in range(2,9)]) for i,row in enumerate(rows[:-1])]),Spacer(1,12),p('Граница и сохранение смысла','HeadingLMX'),p('Включены нужные объявления, вызовы, импорты и demo. Внешний запуск, печать и тестовая обвязка исключены. Библиотечная операция LMX сопоставляется с библиотекой или оператором контрольного языка; принадлежность ядру не скрывает отдельный предметный алгоритм. Поля и ожидаемое поведение сохранены, в том числе width в Flyweight. Сам язык LMX динамический; искусственная имитация статической архитектуры не требуется.'),p('Отношения вычислены из сумм. Это метрика приведённого исходника, не скорости или памяти. Подробные договоры, второй вариант и фактическая стоимость helper находятся в NN_*_comparison.md и RU/EN-руководствах.','SmallLMX')]
        story.append(p(THROWS_NOTE,'SmallLMX'))
        target=ROOT/filename;doc(target,f'LMX: паттерны {label}').build(story,onFirstPage=footer,onLaterPages=footer);generated.append(target.name)
    (ROOT/'validation/pdf_generation_20261122.json').write_text(json.dumps({'date':'2026-11-23','files':generated,'source':'validation/statistics_20261122.json','source_sha256':hashlib.sha256((ROOT/'validation/statistics_20261122.json').read_bytes()).hexdigest(),'gof_source_sha256':hashlib.sha256((ROOT/'validation/gof_statistics_20261122.json').read_bytes()).hexdigest(),'generator_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'minimum_policy':'Equivalent to report_minima.mjs: smaller LMX count is one candidate; full wins own tie; all equal global minima highlighted; ineligible comparisons excluded.','tables':TABLE_AUDIT,'green_cells':GREEN_AUDIT,'visual_review':'separate report; generation alone is not visual verification'},ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'generated':len(generated),'files':generated},ensure_ascii=False))
if __name__=='__main__':main()

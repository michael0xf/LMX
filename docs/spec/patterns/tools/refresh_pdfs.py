#!/usr/bin/env python3
"""Render current pattern metrics and summary with ReportLab; no language runs."""
from pathlib import Path
from html import escape
import json
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,Table,TableStyle,PageBreak
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4,landscape
from reportlab.lib.styles import getSampleStyleSheet,ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

ROOT=Path(__file__).resolve().parents[1]
FONTS=Path('/usr/share/fonts/truetype/noto')
if not (FONTS/'NotoSans-Regular.ttf').exists():
    FONTS=Path('/usr/share/fonts/truetype/dejavu');REG='DejaVuSans.ttf';BOLD='DejaVuSans-Bold.ttf'
else:REG='NotoSans-Regular.ttf';BOLD='NotoSans-Bold.ttf'
pdfmetrics.registerFont(TTFont('LMX',str(FONTS/REG)));pdfmetrics.registerFont(TTFont('LMXBold',str(FONTS/BOLD)))
pdfmetrics.registerFontFamily('LMX',normal='LMX',bold='LMXBold')
ST=getSampleStyleSheet()
for name,font,size,leading,color in [('TitleLMX','LMXBold',19,24,'#18344C'),('HeadingLMX','LMXBold',12,16,'#18344C'),('TextLMX','LMX',9,12,'#243B4B'),('SmallLMX','LMX',8,11,'#4E5E6D'),('CellLMX','LMX',8.4,11,'#243B4B'),('HeadLMX','LMXBold',8.4,11,'#FFFFFF')]:
    ST.add(ParagraphStyle(name=name,fontName=font,fontSize=size,leading=leading,textColor=colors.HexColor(color),spaceAfter=7 if name not in ('CellLMX','HeadLMX') else 0))
def p(s,style='TextLMX'):
    return Paragraph(escape(str(s).replace('—','-').replace('–','-').replace('‑','-')).replace('\n','<br/>'),ST[style])
def footer(c,doc):
    w,h=landscape(A4);c.setStrokeColor(colors.HexColor('#CFD8E0'));c.line(36,32,w-36,32)
    c.setFillColor(colors.HexColor('#4E5E6D'));c.setFont('LMX',7)
    c.drawString(36,20,'LMX - статистика основных листингов - 22 ноября 2026');c.drawRightString(w-36,20,str(doc.page))
def doc(target,title):return SimpleDocTemplate(str(target),pagesize=landscape(A4),rightMargin=36,leftMargin=36,topMargin=30,bottomMargin=44,title=title,author='LMX documentation')
def table(headers,rows,widths):
    values=[[p(x,'HeadLMX') for x in headers]]+[[p(x,'CellLMX') for x in row] for row in rows]
    widths=[w*(landscape(A4)[0]-72)/sum(widths) for w in widths]
    t=Table(values,colWidths=widths,repeatRows=1,hAlign='LEFT')
    t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#233D55')),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),4),('BOTTOMPADDING',(0,0),(-1,-1),4),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,colors.HexColor('#F0F3F6')])]))
    return t
def main():
    stats=json.loads((ROOT/'validation/statistics_20261122.json').read_text());generated=[]
    for g in stats['groups']:
        jp=ROOT/g['directory']/'patterns.json';data=json.loads(jp.read_text());a,b=g['languages'][1:]
        story=[p(g['title'],'TitleLMX'),p(f'LMX / {a} / {b}; {g["pattern_count"]} паттернов + {g["implementation_count"]} реализаций; 22 ноября 2026','SmallLMX'),p(data['rationale_ru'])]
        if g['directory']=='09_functional_computation':
            story.append(p('Общие ресиверы и контейнеры вместо int-специализаций. Исторический код сохранён рядом. Основной листинг выбирается среди корректных вариантов того же договора. Все операции относятся к одному ядру; его реализация посчитана отдельно.'))
        else:story.append(p(data['overview_ru']))
        rows=[]
        for x in g['records']:
            m=x['metrics'];nums=[f"{m[l]['characters']} / {m[l]['nonblank_lines']}" for l in g['languages']]
            rows.append([f"{x['id']:03d}",x['name'],*nums,{'scenario':'Сценарий','usage':'Клиент','implementation':'Реализация'}[x['layer']]])
        story += [Spacer(1,4),table(['ID','Сравнение','LMX\nсимв. / стр.',a+'\nсимв. / стр.',b+'\nсимв. / стр.','Слой'],rows,[32,258,91,106,106,87]),Spacer(1,10),p('Граница подсчёта','HeadingLMX'),p('Символы - непробельные Unicode-символы основного листинга, включая его комментарии; строки - непустые. Альтернативы исключены. Необходимые вызовы и объявления включены. Библиотечный уровень допустим при сопоставимой операции контрольного языка; общий код ядра показан отдельно и учитывается один раз при сравнении реализации.','SmallLMX')]
        if g['directory']=='09_functional_computation':
            dep=stats['functional_library_dependencies'];u=dep['unique_required_total'];aliases=sum(x['characters'] for x in dep['public_bundle'])
            story.append(p(f"Общие определения {len(dep['components'])} учитываемых LMX-компонентов без повторов: {u['characters']} символов / {u['lines']} строк. В их числе дополнительный curry-механизм клиента 085; он не создаёт нового сравнительного сценария. Внутренний набор экспортов ядра: ещё {aliases} символов один раз. Реестр: IMPLEMENTATION_DEPENDENCIES.md. В 099 LMX поддерживает произвольный префикс N входов, а контрольный общий случай связывает первый вход A×B→R; равная универсальность не заявляется.",'SmallLMX'))
        story += [p('Полные сценарии, исходники, зависимости и границы находятся в NNN_*_comparision.md, patterns.json и examples/. Эти числа не являются измерением скорости или отчётом о выполнении LMX.','SmallLMX')]
        target=ROOT/g['directory']/f"LMX_Comparison_{g['directory']}.pdf";doc(target,'LMX: '+g['title']).build(story,onFirstPage=footer,onLaterPages=footer);generated.append(target.relative_to(ROOT).as_posix())
    story=[p('LMX: сводная статистика','TitleLMX'),p('Редакция 22 ноября 2026 года','SmallLMX'),p('90 паттернов и 9 реализаций библиотек: 99 сравнений, 297 основных листингов. Отдельно сохранены 23 GoF-сравнения (184 листинга) и 24 корневых примера LMX. Альтернативные и исторические листинги доступны рядом. Основным выбран самый короткий корректный вариант с сопоставимой границей подсчёта.')]
    rows=[]
    for g in stats['groups']:
        for layer in ('scenario','usage','implementation'):
            count=sum(x['layer']==layer for x in g['records'])
            if not count:continue
            t=g['totals'][layer];a,b=g['languages'][1:]
            rows.append([g['title'],{'scenario':'Сценарии','usage':'Клиенты','implementation':'Реализации'}[layer],count,t['LMX']['characters'],a,t[a]['characters'],b,t[b]['characters']])
    story += [table(['Группа','Слой','N','LMX','Контроль 1','Симв.','Контроль 2','Симв.'],rows,[208,78,29,65,94,67,94,45]),Spacer(1,10),p('Разные группы имеют разные контрольные языки и сценарии. Суммарный рейтинг языков по этим неодинаковым наборам не строится. Слои клиентов и реализаций не смешиваются.','SmallLMX'),PageBreak(),p('Функциональные реализации и зависимости','TitleLMX')]
    dep=stats['functional_library_dependencies'];rows=[]
    for x in dep['components']:
        a=x['primary'];b=x['shared'];label=f"{x['id']:03d}"+(' / curry клиента' if x.get('role')=='usage_companion' else '');rows.append([label,f"{a['characters']} / {a['lines']}",f"{b['characters']} / {b['lines']}",a['characters']+b['characters']])
    story += [table(['Компонент','Основное тело\nсимв. / стр.','Общие зависимости\nсимв. / стр.','Вместе, символы'],rows,[100,220,250,210]),Spacer(1,10)]
    u=dep['unique_required_total'];alias=sum(x['characters'] for x in dep['public_bundle'])
    story += [p(f"Все {len(dep['components'])} компонентов с устранением повторов: {u['characters']} символов / {u['lines']} строк. Внутренний набор экспортов добавляет {alias} символов один раз. Столбец зависимостей выше нельзя суммировать без удаления повторов.")]
    story += [p('Код адаптеров FxKernel должен быть реализован в настоящем ядре. Он не выдаётся за уже выполненную библиотеку или за компонент нулевого размера. LMX 099 имеет более широкий контракт частичного применения, чем короткие контрольные реализации первого связывания.','SmallLMX'),p('Корневые примеры: изменённые варианты','HeadingLMX')]
    rows=[]
    for x in stats['functional_receiver_counts']['rows']:
        if x['changed']:rows.append([x['id'],x['before']['characters'],x['after']['characters'],x['after']['characters']-x['before']['characters'],f"{x['before']['nonblank_lines']} / {x['after']['nonblank_lines']}"])
    story += [table(['Пример','Символы до','Символы после','Изменение','Строки до / после'],rows,[100,170,170,140,200]),Spacer(1,10),p('Это историческое сравнение до/после, а не основание выбирать длинный вариант. Текущие альтернативы проверяются на один договор задачи и сравнимый уровень ядра; выбор основного и размеры обоих приведены отдельно.','SmallLMX'),PageBreak(),p('Все корневые примеры','TitleLMX')]
    rows=[[x['id'],x['characters'],x['nonblank_lines'],'Да' if x['procedural_archived'] else 'Исходный код'] for x in stats['root_examples']]
    story += [table(['Пример','Основные символы','Непустые строки','Второй вариант рядом'],rows,[160,205,185,230]),PageBreak(),p('Исходная подборка GoF','TitleLMX'),p('Все 184 основных листинга повторно пересчитаны. Более короткие варианты Composite, Prototype и Abstract Factory сохранены вместе с процедурными аналогами. В Flyweight исправлен отступ return; width остаётся во всех языках.')]
    rows=[[lang,n] for lang,n in stats['gof']['total_characters'].items()]
    story += [table(['Язык','Непробельных символов'],rows,[300,480]),Spacer(1,15),p('Метод и проверка','HeadingLMX'),p('Источник всех чисел: основные строки кода в patterns.json, отдельные .lm3 и помеченные прикладные блоки корневых Markdown. Нормализация LF, удаление пустых строк по краям, один LF в конце. Unicode-символы, для которых isspace=false, считаются по одному. В JSON также сохранены UTF-8-байты и SHA-256.'),p('Эти измерения описывают конкретные исходники. Они не подтверждают runtime-корректность, одинаковую универсальность всех реализаций, скорость или расход памяти. Проверки публикации и формул отделены от будущей приёмки LMX на ядре.'),p('Полные данные: validation/statistics_20261122.json. Текстовая сводка и CSV/XLSX: STATISTICS_2026-11-22.*. Групповые PDF/Excel находятся в девяти каталогах сравнения.','SmallLMX')]
    story += [p('Клиенты и реализации ядра считаются раздельно. Исторические специализации сохранены как пояснение. Для 085 показаны сопоставимые curry/partial. В 084 весь локальный Around входит в основной размер; общий bracket сохранён рядом. Прежний процедурный код также доступен. Полные основания выбора находятся в patterns.json и Markdown.','SmallLMX')]
    story += [PageBreak(),p('Выбор основного варианта','TitleLMX'),p('Сначала проверяется один договор задачи и сопоставимый уровень подсчёта, затем выбирается минимум по символам. Архитектурные преимущества динамического LMX сохраняются; одинаковое устройство алгоритмов не требуется. Все варианты работают в одном текущем ядре, а исторические листинги не подключаются как другие версии библиотек.')]
    choices=[]
    for x in stats['functional_receiver_counts']['rows']:
        if not x.get('has_alternative'):continue
        selected=x['selected_variant'];alternate=x['alternative_variant'];eligible=x.get('eligible_variants',list(x['variants']))
        choices.append([x['id'],selected,x['variants'][selected]['characters'],x['variants'][alternate]['characters'],'Да' if alternate in eligible else 'Нет: другой договор'])
    if choices:story += [table(['Пример','Основной вариант','Основной, символы','Второй, символы','Второй сопоставим'],choices,[80,180,140,140,240]),Spacer(1,8)]
    story += [p('Полное основание выбора записано рядом с каждым примером и в examples/validation/functional_receiver_counts.json. Более короткий код, который убирает реальные raw-occurrences, поля или эффекты, не заменяет исходный сценарий.','SmallLMX'),p('Функциональная группа: текущие варианты','HeadingLMX')]
    choices=[]
    for x in json.loads((ROOT/'09_functional_computation/patterns.json').read_text())['patterns']:
        code=next(y['code'] for y in x['listings'] if y['language']=='LMX')
        active=x.get('primary_variant',{}).get('LMX','core');variants=x.get('variants',{}).get('LMX',{});eligible=x.get('eligible_variants',{}).get('LMX',[])
        alternatives=[n for n in eligible if n!=active]
        if alternatives:
            name=min(alternatives,key=lambda n:sum(not c.isspace() for c in variants[n]));old=variants[name]
            note=('Общие code/eval / отдельные callbacks; оба helper учтены полностью' if x['id']==84 else f'Сопоставимая пара: {active} / {name}; выбран минимум')
        else:
            old=x.get('alternative',{}).get('LMX',{}).get('code','');note='Исторический исходник сохранён; договор отличается'
        choices.append([f"{x['id']:03d}",sum(not c.isspace() for c in code),sum(not c.isspace() for c in old),note])
    story += [table(['ID','Основной LMX','Второй LMX','Граница сравнения'],choices,[70,140,160,410])]
    target=ROOT/'STATISTICS_2026-11-22.pdf';doc(target,'LMX: статистика 22 ноября 2026').build(story,onFirstPage=footer,onLaterPages=footer);generated.append(target.name)
    gof=json.loads((ROOT/'validation/gof_statistics_20261122.json').read_text())
    languages=['LMX','Python','Java','C++','C#','TypeScript','Go','Rust']
    for filename,first,last,label in [('LMX_Comparison_2026-11-20.pdf',1,9,'1–9'),('LMX_Comparison_10-18.pdf',10,18,'10–18'),('LMX_Comparison_19-23.pdf',19,23,'19–23')]:
        records=[x for x in gof['records'] if first<=x['id']<=last];totals=gof['aggregates'][label]['totals'];rows=[]
        for x in records:rows.append([x['title'],*[x['metrics'][l]['characters'] for l in languages]])
        rows.append(['Итого',*[totals[l] for l in languages]])
        rows.append(['Итого / LMX',*[f"{totals[l]/totals['LMX']:.3f}×" for l in languages]])
        story=[p(f'LMX: паттерны {label}','TitleLMX'),p(f'{len(records)} сценариев, восемь языков; 22 ноября 2026','SmallLMX'),p('Непробельные символы полных основных листингов. Из корректных сопоставимых вариантов выбран самый короткий; альтернативы и исходники ядра приведены отдельно в соответствующем сравнении.'),table(['Сценарий',*languages],rows,[240,67,67,67,67,67,67,67,67]),Spacer(1,12),p('Граница и сохранение смысла','HeadingLMX'),p('Включены нужные объявления, вызовы, импорты и demo. Внешний запуск, печать и тестовая обвязка исключены. Библиотечная операция LMX сопоставляется с библиотекой или оператором контрольного языка; принадлежность ядру не скрывает отдельный предметный алгоритм. Поля и ожидаемое поведение сохранены, в том числе width в Flyweight. Сам язык LMX динамический; искусственная имитация статической архитектуры не требуется.'),p('Отношения вычислены из сумм. Это метрика приведённого исходника, не скорости или памяти. Подробные договоры, второй вариант и фактическая стоимость helper находятся в NN_*_comparison.md и RU/EN-руководствах.','SmallLMX')]
        target=ROOT/filename;doc(target,f'LMX: паттерны {label}').build(story,onFirstPage=footer,onLaterPages=footer);generated.append(target.name)
    (ROOT/'validation/pdf_generation_20261122.json').write_text(json.dumps({'date':'2026-11-22','files':generated,'source':'validation/statistics_20261122.json','visual_review':'separate report; generation alone is not visual verification'},ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'generated':len(generated),'files':generated},ensure_ascii=False))
if __name__=='__main__':main()

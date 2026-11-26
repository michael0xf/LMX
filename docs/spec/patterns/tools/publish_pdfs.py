#!/usr/bin/env python3
"""Render current comparison PDFs from PUBLICATION_DATA.json, including both styles."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Table, TableStyle, Spacer, PageBreak, CondPageBreak
from build_publication_data import METHOD, STYLE_METHOD, RUNTIME, edition_label

ROOT=Path(__file__).resolve().parents[1]
PAGE=landscape(A4)
WIDTH=PAGE[0]-72
INK=colors.HexColor('#17344C')
GREEN=colors.HexColor('#176233')
AUDIT=[]
EDITION_LABEL=''


def styles():
    font=Path('/usr/share/fonts/truetype/dejavu')
    pdfmetrics.registerFont(TTFont('LMX',str(font/'DejaVuSans.ttf')))
    pdfmetrics.registerFont(TTFont('LMXBold',str(font/'DejaVuSans-Bold.ttf')))
    pdfmetrics.registerFontFamily('LMX',normal='LMX',bold='LMXBold')
    return {
        'title':ParagraphStyle('title',fontName='LMXBold',fontSize=18,leading=22,textColor=INK,spaceAfter=9),
        'heading':ParagraphStyle('heading',fontName='LMXBold',fontSize=11,leading=14,textColor=INK,spaceBefore=8,spaceAfter=5),
        'body':ParagraphStyle('body',fontName='LMX',fontSize=8,leading=11,textColor=INK,spaceAfter=7),
        'note':ParagraphStyle('note',fontName='LMX',fontSize=7,leading=9.5,textColor=colors.HexColor('#526575'),spaceAfter=6),
        'cell':ParagraphStyle('cell',fontName='LMX',fontSize=7.4,leading=10,textColor=INK),
        'header':ParagraphStyle('header',fontName='LMXBold',fontSize=7.5,leading=10,textColor=colors.white),
    }


def para(value,style):
    text='—' if value is None else str(value)
    return Paragraph(escape(text).replace('\n','<br/>'),style)


def build_table(tab,sty,document_name,sheet_name):
    values=[tab['headers']]+tab['rows']
    if tab.get('total'):values=values+[tab['total']['values']]
    widths=[WIDTH*w/sum(tab['widths']) for w in tab['widths']]
    # Keep the total label readable even in the narrow GoF ID column.
    if widths[0] < 42:
        old_first=widths[0]
        widths=[42]+[width*(WIDTH-42)/(WIDTH-old_first) for width in widths[1:]]
    rendered=[[para(v,sty['header'] if r==0 else sty['cell']) for v in row] for r,row in enumerate(values)]
    rules=[('BACKGROUND',(0,0),(-1,0),INK),('VALIGN',(0,0),(-1,-1),'MIDDLE'),
           ('LEFTPADDING',(0,0),(-1,-1),6),('RIGHTPADDING',(0,0),(-1,-1),6),
           ('TOPPADDING',(0,0),(-1,0),4),('BOTTOMPADDING',(0,0),(-1,0),4),
           ('TOPPADDING',(0,1),(-1,-1),1.5),('BOTTOMPADDING',(0,1),(-1,-1),1.5)]
    for r in range(1,len(values)):
        if r%2==0:rules.append(('BACKGROUND',(0,r),(-1,r),colors.HexColor('#F0F3F6')))
    green=[]
    eligible=tab['eligible_rows']+([tab['total']['compare']] if tab.get('total') else [])
    for r,row in enumerate(values[1:],1):
        if not eligible[r-1]:continue
        candidates={c:row[c] for c in tab['comparison_columns'] if isinstance(row[c],(int,float))}
        if not candidates:continue
        winner=min(candidates.values())
        for c,value in candidates.items():
            if value!=winner:continue
            # Only the actual minimum cells receive green text and an underline.
            rendered[r][c]=Paragraph('<font color="#176233"><b><u>'+escape(str(value))+'</u></b></font>',sty['cell'])
            green.append({'row':r-1,'column':c,'value':value})
    if tab.get('total'):
        r=len(values)-1;rules.extend([('LINEABOVE',(0,r),(-1,r),.5,colors.HexColor('#91A6B8')),
                                    ('BACKGROUND',(0,r),(-1,r),colors.HexColor('#E3EBF1'))])
    result=Table(rendered,colWidths=widths,repeatRows=1,hAlign='LEFT')
    result.setStyle(TableStyle(rules))
    AUDIT.append({'file':document_name+'.pdf','sheet':sheet_name,'table':tab['title'],
                  'rows':len(tab['rows']),'green_cells':green,'minimum_basis':'full source characters'})
    return result


def footer(canvas,doc):
    canvas.setStrokeColor(colors.HexColor('#CFD8E0'));canvas.line(36,39,PAGE[0]-36,39)
    canvas.setFillColor(colors.HexColor('#526575'));canvas.setFont('LMX',7)
    canvas.drawString(36,29,'LMX · полные листинги · '+EDITION_LABEL)
    canvas.drawRightString(PAGE[0]-36,29,str(doc.page))
    canvas.setFont('LMX',6.5)
    canvas.drawString(36,18,'Весь непробельный Unicode-текст; Throws/copy включены. Зелёное подчёркивание — минимум, включая все равенства.')
    canvas.drawString(36,8,'LMX parser/runtime: NOT_RUN. Проверки исходников и таблиц не являются исполнением; размер не измеряет скорость или память.')


def main():
    global EDITION_LABEL
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--only',help='Only document stems containing this text')
    args=parser.parse_args()
    model=json.loads((ROOT/'PUBLICATION_DATA.json').read_text())
    EDITION_LABEL=edition_label(model['edition'])
    sty=styles();generated=[]
    previous={}
    target=ROOT/f"validation/pdf_generation_{model['edition'].replace('-', '')}.json"
    if args.only:
        previous_path=target if target.is_file() else next(iter(sorted(
            (ROOT/'validation').glob('pdf_generation_*.json'),reverse=True)),None)
        if previous_path:
            previous=json.loads(previous_path.read_text())
            for item in previous.get('files',[]):
                item.setdefault('generation_receipt',previous_path.relative_to(ROOT).as_posix())
                item.setdefault('generation_edition',previous.get('edition'))
    for source in model['documents']:
        if args.only and args.only not in source['stem']:continue
        story=[]
        for index,view in enumerate(source['sheets']):
            if index:story.append(PageBreak())
            story.extend([para(view['title'],sty['title']),para('Полные размеры исходников · '+EDITION_LABEL,sty['note'])])
            for tab in view['tables']:
                story.append(CondPageBreak(65))
                story.append(para(tab['title'],sty['heading']))
                story.append(build_table(tab,sty,source['stem'],view['name']))
                if tab['note']:story.append(para(tab['note'],sty['note']))
                story.append(Spacer(1,4))
            for note in view['notes']:
                # Common methodology is visible in every page footer. Repeating
                # it after every table produced pages with only one status line.
                if note and note not in {METHOD,STYLE_METHOD,RUNTIME}:
                    story.append(para(note,sty['note']))
        path=ROOT/(source['stem']+'.pdf')
        doc=SimpleDocTemplate(str(path),pagesize=PAGE,leftMargin=36,rightMargin=36,topMargin=31,bottomMargin=45,
                              title=source['title'],author='LMX',pageCompression=1)
        doc.build(story,onFirstPage=footer,onLaterPages=footer)
        generated.append({'file':path.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
                          'generation_receipt':target.relative_to(ROOT).as_posix(),'generation_edition':model['edition']})
    for mirror in model['mirrors']:
        if any(x['file']==mirror['source']+'.pdf' for x in generated):
            shutil.copyfile(ROOT/(mirror['source']+'.pdf'),ROOT/(mirror['target']+'.pdf'))
            generated.append({'file':mirror['target']+'.pdf','byte_identical_to':mirror['source']+'.pdf',
                              'generation_receipt':target.relative_to(ROOT).as_posix(),'generation_edition':model['edition']})
    changed={item['file'] for item in generated}
    all_files=[item for item in previous.get('files',[]) if isinstance(item,dict) and item.get('file') not in changed]+generated
    all_tables=[item for item in previous.get('tables',[]) if item.get('file') not in changed]+AUDIT
    report={'edition':model['edition'],'source':'PUBLICATION_DATA.json',
            'source_sha256':hashlib.sha256((ROOT/'PUBLICATION_DATA.json').read_bytes()).hexdigest(),
            'files':all_files,'tables':all_tables,'visual_review':'separate rendered-page review','lmx_runtime_execution':'NOT_RUN'}
    target.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'pdf_files':len(all_files),'updated':len(generated),'tables':len(all_tables)},ensure_ascii=False))


if __name__=='__main__':main()

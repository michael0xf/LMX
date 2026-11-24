#!/usr/bin/env python3
"""Render PDFs and inspect final XLSX XML. Visual sign-off is a separate step."""
from pathlib import Path
import argparse,hashlib,json,zipfile
import xml.etree.ElementTree as ET
import fitz
from PIL import Image,ImageDraw,ImageFont

NS={'s':'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def contacts(items,out,prefix,width=700,cols=2,rows=2):
    files=[];font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
    for offset in range(0,len(items),cols*rows):
        group=items[offset:offset+cols*rows];tiles=[]
        for label,path in group:
            img=Image.open(path).convert('RGB');height=round(img.height*width/img.width)
            img=img.resize((width,height));tile=Image.new('RGB',(width,height+42),'#e8edf2');tile.paste(img,(0,42))
            draw=ImageDraw.Draw(tile);draw.text((8,6),label[:90],font=font,fill='#17344c');tiles.append(tile)
        tileH=max(x.height for x in tiles);canvas=Image.new('RGB',(width*cols,tileH*rows),'#d7dfe7')
        for i,tile in enumerate(tiles):canvas.paste(tile,((i%cols)*width,(i//cols)*tileH))
        path=out/f'{prefix}_{1+offset//(cols*rows):02d}.png';canvas.save(path);files.append(str(path))
    return files

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--report',type=Path,required=True)
    args=ap.parse_args();root=args.root.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
    pdfs=[];pages=[];errors=[]
    for path in sorted(root.rglob('*.pdf')):
        relative=path.relative_to(root).as_posix();document=fitz.open(path);entry={'file':relative,'sha256':sha(path),'pages':len(document),'outside_page_spans':[],'empty_pages':[]}
        for number,page in enumerate(document):
            if not page.get_text().strip():entry['empty_pages'].append(number+1)
            for block in page.get_text('dict')['blocks']:
                if 'lines' not in block:continue
                for line in block['lines']:
                    for span in line['spans']:
                        rect=fitz.Rect(span['bbox'])
                        if not page.rect.contains(rect):entry['outside_page_spans'].append({'page':number+1,'text':span['text'],'bbox':list(rect)})
            imagePath=out/(relative.replace('/','__')+f'.page{number+1:02d}.png')
            page.get_pixmap(matrix=fitz.Matrix(1.4,1.4),alpha=False).save(imagePath)
            pages.append((path.stem+f' · p{number+1}',imagePath))
        if entry['empty_pages'] or entry['outside_page_spans']:errors.append({'file':relative,'issue':'PDF page bounds or empty page'})
        pdfs.append(entry)
    books=[]
    for path in sorted(root.rglob('*.xlsx')):
        entry={'file':path.relative_to(root).as_posix(),'sha256':sha(path),'formulas':0,'formula_errors':[],'missing_cached_results':[],'worksheets':0}
        with zipfile.ZipFile(path) as archive:
            if archive.testzip():errors.append({'file':entry['file'],'issue':'ZIP CRC'})
            for name in archive.namelist():
                if name.startswith('xl/worksheets/sheet') and name.endswith('.xml'):
                    entry['worksheets']+=1;tree=ET.fromstring(archive.read(name))
                    for cell in tree.findall('.//s:c',NS):
                        if cell.attrib.get('t')=='e':entry['formula_errors'].append({'sheet':name,'cell':cell.attrib.get('r'),'value':cell.findtext('s:v',namespaces=NS)})
                        if cell.find('s:f',NS) is not None:
                            entry['formulas']+=1
                            if cell.find('s:v',NS) is None:entry['missing_cached_results'].append({'sheet':name,'cell':cell.attrib.get('r')})
        if entry['formula_errors'] or entry['missing_cached_results']:errors.append({'file':entry['file'],'issue':'XLSX error or missing formula cache'})
        books.append(entry)
    report={'edition':'2026-11-24','scope':'final PDF page bounds and rendering; XLSX archive/XML/cached-formula checks, not native Excel or LMX execution',
        'pdf_files':pdfs,'xlsx_files':books,'pdf_pages':len(pages),'errors':errors,
        'pdf_contact_sheets':contacts(pages,out,'pdf_contact'),'visual_signoff':'pending human/model inspection of rendered files'}
    args.report.parent.mkdir(parents=True,exist_ok=True);args.report.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'pdf_files':len(pdfs),'pdf_pages':len(pages),'xlsx_files':len(books),'errors':errors,'contact_sheets':report['pdf_contact_sheets']},ensure_ascii=False))
    return 1 if errors else 0

if __name__=='__main__':raise SystemExit(main())

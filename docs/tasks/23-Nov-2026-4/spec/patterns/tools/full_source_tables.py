#!/usr/bin/env python3
"""Remove the retired supplementary metric from publication Markdown/CSV.

Source listings, their Throws contracts and JSON evidence are never rewritten.
All current publication values use the complete source text.
"""
from pathlib import Path
import argparse
import csv
import re

OLD = re.compile(r'(?:без\s+сложного\s+throws|without\s+complex\s+throws|without_complex_throws)',re.I)


def columns(line):
    # Publication table cells escape literal pipes; preserve those escapes.
    return [cell.strip() for cell in re.split(r'(?<!\\)\|',line.strip().strip('|'))]


def clean_markdown(text):
    lines=text.splitlines();out=[];index=0;fence=None
    while index<len(lines):
        line=lines[index]
        marker=re.match(r'^ {0,3}(`{3,}|~{3,})',line)
        if marker:
            token=marker[1]
            if fence is None:fence=(token[0],len(token))
            elif token[0]==fence[0] and len(token)>=fence[1]:fence=None
            out.append(line);index+=1;continue
        if fence is not None:
            out.append(line);index+=1;continue
        # A legacy statistics refresh can append its retired fourth value to
        # rows whose three-column header was already cleaned.  Repair only
        # this exact known full-source schema.  Complete three-cell rows,
        # including totals, remain byte-for-byte unchanged.
        if (line.startswith('|')
                and columns(line)==['Язык','Непробельные символы','Непустые строки']
                and index+1<len(lines)
                and re.fullmatch(r'[\s|:\-]+',lines[index+1])):
            while index<len(lines) and lines[index].startswith('|'):
                current=lines[index];cells=columns(current)
                if len(cells)==4:
                    current='| '+' | '.join(cells[:3])+' |'
                out.append(current);index+=1
            continue
        if line.startswith('|') and OLD.search(line):
            header=columns(line)
            removed={i for i,value in enumerate(header) if OLD.search(value)}
            # Only a header followed by a delimiter is a publication table.
            if index+1<len(lines) and re.fullmatch(r'[\s|:\-]+',lines[index+1]):
                while index<len(lines) and lines[index].startswith('|'):
                    cells=columns(lines[index])
                    out.append('| '+' | '.join(v for i,v in enumerate(cells) if i not in removed)+' |')
                    index+=1
                continue
        if OLD.search(line):
            if line.lstrip().startswith('#'):
                out.append(re.sub(r'без\s+сложного\s+throws|without\s+complex\s+throws','полный размер исходника',line,flags=re.I))
            else:
                sentences=re.split(r'(?<=[.!?])\s+',line)
                kept=[sentence for sentence in sentences if not OLD.search(sentence)]
                if kept:out.append(' '.join(kept))
            index+=1;continue
        out.append(line);index+=1
    return '\n'.join(out)+'\n'


def clean_csv(path):
    with path.open(encoding='utf-8-sig',newline='') as stream:
        rows=list(csv.reader(stream))
    if not rows:return False
    removed={i for i,value in enumerate(rows[0]) if OLD.search(value)}
    if not removed:return False
    with path.open('w',encoding='utf-8-sig',newline='') as stream:
        csv.writer(stream).writerows([[v for i,v in enumerate(row) if i not in removed] for row in rows])
    return True


def clean_paths(paths):
    changed=[]
    for path in paths:
        if path.suffix=='.md':
            before=path.read_text();after=clean_markdown(before)
            if after!=before:path.write_text(after);changed.append(str(path))
        elif path.suffix=='.csv' and clean_csv(path):changed.append(str(path))
    return changed


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root',type=Path)
    args=parser.parse_args()
    changed=clean_paths(path for path in args.root.rglob('*') if path.is_file() and path.suffix in {'.md','.csv'})
    print({'changed':len(changed)})


if __name__=='__main__':main()

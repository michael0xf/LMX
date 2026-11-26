#!/usr/bin/env python3
"""Bounded static checks of the catalogue's generated LMX source subset.

This is NOT P0, an LMX parser, type checker, compiler or interpreter. It checks
literal shielding, paired delimiters, layout/cutters, blank root boundaries and
the explicit L2 placement of c.*. It cannot prove DATA/CODE roles, declarations,
foreign ABI, effects, overload selection or execution. Unsupported raw constructs
are reported rather than silently treated as ordinary generated-source syntax.
"""
from __future__ import annotations
import argparse
from collections import Counter
import json
from pathlib import Path
import re


def check(path: Path):
    errors=[]; unsupported=[]; stack=[]; quote=None; quote_at=None
    last_indent=None; after_blank=False; l2_levels=[]; calls=0
    try:
        with path.open(encoding='utf-8', newline='') as source:
            lines = source.readlines()
    except (OSError,UnicodeError) as exc:
        return {'file':str(path),'errors':[str(exc)],'unsupported':[],'c_tokens':0}
    for line_no, raw in enumerate(lines, 1):
        line = raw.rstrip('\r\n')
        if not quote and re.fullmatch(r'={3,80}[ \t]*',line):
            unsupported.append(f'{line_no}: raw block text requires the production P0 parser')
        if '\x00' in line and not quote:
            errors.append(f'{line_no}: NUL outside a supported ordinary literal')
        if not line.strip(' \t') and not quote:
            if stack:
                errors.append(f'{line_no}: blank physical line closes the block with an unmatched {stack[-1][0]} from line {stack[-1][1]}')
            last_indent=None; after_blank=True; l2_levels=[]
            continue
        clean=[];i=0;had_literal=quote is not None
        while i<len(line):
            ch=line[i]
            if quote:
                if quote=='`':
                    if ch=='`':
                        if i+1<len(line) and line[i+1]=='`':
                            clean.extend('  ');i+=2;continue
                        quote=None
                    clean.append(' ');i+=1;continue
                if ch=='\\':
                    clean.append(' ')
                    if i+1<len(line):
                        clean.append(' ');i+=2;continue
                    # Ordinary C splicing is permitted by the grammar.
                    i+=1;break
                if ch==quote:
                    quote=None
                clean.append(' ');i+=1;continue
            if ch=='#':
                break
            if ch in ('"',"'",'`'):
                had_literal=True
                if ch!='`' and line[i:i+3]==ch*3:
                    unsupported.append(f'{line_no}: triple raw literal requires the production P0 parser')
                quote=ch;quote_at=line_no;clean.append(' ');i+=1;continue
            if ch.isspace() and ch not in ' \t':
                unsupported.append(f'{line_no}: non-layout whitespace outside a literal or comment')
            clean.append(ch)
            if ch in '([{':
                if ch=='{':
                    unsupported.append(f'{line_no}: Mix requires the production P0 parser')
                stack.append((ch,line_no))
            elif ch in ')]}':
                expected={')':'(',']':'[','}':'{'}[ch]
                if not stack or stack[-1][0]!=expected:
                    errors.append(f'{line_no}: unmatched {ch}')
                else:
                    stack.pop()
            i+=1
        code=''.join(clean).rstrip()
        if quote and quote!='`' and not line.endswith('\\'):
            errors.append(f'{line_no}: unescaped newline in ordinary literal opened on {quote_at}')
            quote=None
        if not code.strip() and not had_literal:
            continue
        indent=len(line)-len(line.lstrip(' '))
        if '\t' in line[:len(line)-len(line.lstrip())]:
            errors.append(f'{line_no}: tab indentation is outside the generated subset')
        if indent%4:
            errors.append(f'{line_no}: indentation {indent}, expected a multiple of four in generated sources')
        cutter=bool(re.match(r'^(?:---(?:\s|$)|end\s*:)',code.strip()))
        if after_blank and indent:
            errors.append(f'{line_no}: indented source after a blank-line root closure')
        if last_indent is not None and indent<last_indent-4 and not cutter:
            errors.append(f'{line_no}: multi-level decrease {last_indent}->{indent} without an explicit cutter/root boundary')
        after_blank=False
        while l2_levels and indent<=l2_levels[-1]:
            l2_levels.pop()
        explicit_l2=bool(re.match(r'^L2\s*:',code.strip()))
        if explicit_l2:
            l2_levels.append(indent)
        tokens=len(re.findall(r'(?<![A-Za-z0-9_])c\.[A-Za-z_]',code))
        calls+=tokens
        if tokens and path.suffix!='.lm2' and not l2_levels:
            errors.append(f'{line_no}: c.* outside an explicit L2 region')
        last_indent=indent
    if quote:
        errors.append(f'EOF: unclosed literal from line {quote_at}')
    if stack:
        errors.append('EOF: unclosed delimiters '+repr(stack))
    return {'file':str(path),'errors':errors,'unsupported':unsupported,'c_tokens':calls}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('paths',nargs='+',type=Path)
    parser.add_argument('--report',type=Path)
    args=parser.parse_args()
    files=[]
    for p in args.paths:
        files.extend(sorted(x for x in p.rglob('*') if x.suffix in {'.lmx','.lm2','.lm3'} and x.is_file()) if p.is_dir() else [p])
    files=list(dict.fromkeys(files))
    results=[check(p) for p in files]
    counts=Counter()
    for row in results:
        counts['files']+=1;counts['errors']+=len(row['errors']);counts['unsupported_forms']+=len(row['unsupported']);counts['c_tokens']+=row['c_tokens']
    report={'mode':'STATIC_SOURCE_CHECKS_NOT_P0_NOT_RUNTIME','counts':dict(counts),'files':results,
            'limitations':['No type/admission/ABI checking','No declaration or semantic role resolution','No runtime execution','Only generated lexical subset supported']}
    if args.report:
        args.report.parent.mkdir(parents=True,exist_ok=True)
        args.report.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'mode':report['mode'],'counts':dict(counts),'problems':[x for x in results if x['errors'] or x['unsupported']]},ensure_ascii=False))
    raise SystemExit(bool(counts['errors'] or counts['unsupported_forms']))


if __name__=='__main__':
    main()

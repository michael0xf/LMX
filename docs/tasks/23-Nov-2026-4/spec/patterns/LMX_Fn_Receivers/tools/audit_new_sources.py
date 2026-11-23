#!/usr/bin/env python3
"""Conservative structural-level audit for NEW LMX source files.

This is not P0, a grammar validator, a type checker, or an execution test.
It checks visible indentation transitions and missing multi-level tail cuts.
C strings/chars (including splices), triple-quoted raw literals, exact names,
block text (= fences) and raw file comments (* fences) are shielded. Ordinary
# comments do not create structural items. Blank lines inside shields do not
close a block. Multiline bounded forms are reported for manual review; they
are never rewritten. Canonical dotted levels are audited but not rewritten.

end/return/until/throw may have profile-dependent terminal meanings. They are
reported as review items, not rejected as proved syntax errors. --fix inserts
--- only at unambiguous ordinary multi-level cuts. --body-terminals also allows
that insertion before return/until/throw in newly generated ordinary bodies;
it is an explicit author-intent option, not a general terminal-role inference.
Never use --fix indiscriminately on pre-existing examples or unknown sources.
"""
from __future__ import annotations
import argparse,json,re
from pathlib import Path


def mask_source(text: str):
    """Return same-length masked text, protected-line set, lexical diagnostics."""
    a=list(text); n=len(text); i=0; mode=None; start=0; quote=''; issues=[]; protected=set()
    line=1; at_line=True
    def hide(lo,hi):
        for k in range(lo,hi):
            if text[k] not in '\r\n': a[k]=' '
    while i<n:
        if mode in ('block','comment_block'):
            end=text.find('\n',i); end=n if end<0 else end
            raw=text[i:end].rstrip('\r')
            protected.add(line); hide(i,end)
            if raw.rstrip(' \t')==quote:
                mode=None
            i=end
        elif mode=='raw':
            protected.add(line)
            if text[i]==quote:
                j=i
                while j<n and text[j]==quote: j+=1
                hide(i,j)
                if j-i==3:
                    if line>start: issues.append({'line':start,'kind':'multiline_raw_manual_review','fixable':False})
                    mode=None
                i=j; continue
            hide(i,i+1)
        elif mode=='exact':
            protected.add(line)
            if text[i]=='`':
                if i+1<n and text[i+1]=='`':
                    hide(i,i+2);i+=2;continue
                if line>start: issues.append({'line':start,'kind':'multiline_exact_name_manual_review','fixable':False})
                mode=None
            hide(i,i+1)
        elif mode=='quoted':
            protected.add(line)
            if text[i]=='\\':
                if i+1<n:
                    hide(i,i+2)
                    if text[i+1]=='\n': line+=1;at_line=True
                    elif text[i+1]=='\r' and i+2<n and text[i+2]=='\n':
                        hide(i+2,i+3);i+=1;line+=1;at_line=True
                    i+=2;continue
            elif text[i]==quote:
                if line>start: issues.append({'line':start,'kind':'spliced_literal_manual_review','fixable':False})
                mode=None
            elif text[i]=='\n':
                issues.append({'line':line,'kind':'unclosed_c_literal','fixable':False})
                mode=None
            hide(i,i+1)
        else:
            if at_line:
                end=text.find('\n',i);end=n if end<0 else end
                raw=text[i:end].rstrip('\r')
                if re.fullmatch(r'={3,80}[ \t]*',raw) or re.fullmatch(r'\*{3,80}[ \t]*',raw):
                    mode='block' if raw[0]=='=' else 'comment_block';quote=raw.rstrip(' \t');start=line
                    issues.append({'line':line,'kind':'block_payload_manual_review','fixable':False})
                    protected.add(line);hide(i,end);i=end;continue
            if text[i]=='#':
                end=text.find('\n',i);end=n if end<0 else end
                hide(i,end);i=end;continue
            if text[i]=='`':
                mode='exact';start=line;hide(i,i+1)
            elif text[i] in ('"',"'"):
                quote=text[i];start=line
                if text[i:i+3]==quote*3:
                    mode='raw';hide(i,i+3);i+=3;at_line=False;continue
                mode='quoted';hide(i,i+1)
        if i<n and text[i]=='\n': line+=1;at_line=True
        else: at_line=False
        i+=1
    if mode:
        issues.append({'line':start or line,'kind':'unclosed_'+mode,'fixable':False})
    return ''.join(a),protected,issues


def audit(path: Path, fix=False, body_terminals=False):
    text=path.read_text(encoding='utf-8');masked,protected,issues=mask_source(text)
    if '{' in masked or '}' in masked:
        issues.append({'line':1,'kind':'mix_document_manual_review','fixable':False})
    complex_source=bool(issues)
    can_rewrite=fix and not complex_source
    rawlines=text.splitlines(keepends=True); codelines=masked.splitlines(keepends=True)
    cols=[0]; previous=0; depth=0; insert={}; bounded=[]; multiline_bounded=set()
    for ln,(raw,code) in enumerate(zip(rawlines,codelines),1):
        # Quotes on an ordinary line are safe; lines which start inside a
        # multiline payload can have a completely masked body and are ignored.
        stripped=code.strip()
        if not raw.strip() and ln not in protected:
            if bounded:
                issues.append({'line':ln,'kind':'blank_inside_bounded_form','fixable':False})
            cols=[0];previous=0;depth=0
            continue
        if not stripped:
            continue
        was_bounded=bool(bounded)
        for ch in stripped:
            if ch in '([': bounded.append((ch,ln))
            elif ch in ')]':
                if bounded and ((bounded[-1][0]=='(' and ch==')') or (bounded[-1][0]=='[' and ch==']')):
                    opener=bounded.pop()
                    if opener[1]!=ln: multiline_bounded.add(opener[1])
                else:
                    issues.append({'line':ln,'kind':'unmatched_bounded_close','fixable':False})
        if was_bounded:
            continue
        lead=re.match(r'^[ .\t]*',code).group(0)
        dotted='.' in lead
        if dotted:
            level=lead.count('.')
        else:
            col=len(lead.expandtabs(8))
            if col>cols[-1]: cols.append(col)
            elif col<cols[-1]:
                while len(cols)>1 and col<cols[-1]: cols.pop()
                if col!=cols[-1]:
                    issues.append({'line':ln,'kind':'unknown_indent_column','fixable':False})
            level=len(cols)-1
        item=code[len(lead):].strip()
        cutter=bool(re.fullmatch(r'-{3,80}',item)) or item.startswith('end:')
        terminal=bool(re.match(r'(return|until|throw)(?:\s|:|$)',item))
        if previous-level>1 and not cutter:
            kind='terminal_cut_review' if terminal else 'missing_tail_cut'
            can_fix=not dotted and (not terminal or body_terminals)
            issues.append({'line':ln,'kind':kind,'from_level':previous,'to_level':level,'fixable':can_fix})
            if can_rewrite and can_fix: insert[ln]=lead+'---\n'
        if level-previous>1:
            issues.append({'line':ln,'kind':'level_increase_jump','fixable':False})
        previous=level;depth=level
    for _,line in bounded:
        issues.append({'line':line,'kind':'unclosed_bounded_form','fixable':False})
    for line in sorted(multiline_bounded):
        issues.append({'line':line,'kind':'multiline_bounded_manual_review','fixable':False})
    if fix and multiline_bounded:
        insert.clear()
    if fix and insert:
        # The scan never rewrites tokens, strings or lines. Only inserted cuts.
        result=''.join(insert.get(i,'')+line for i,line in enumerate(rawlines,1))
        path.write_text(result,encoding='utf-8')
    return {'file':str(path),'inserted_cuts':len(insert),'observations':issues,
            'rewrite_blocked_for_complex_source':complex_source or bool(multiline_bounded),
            'scope':'visible-level audit only; no P0/type/runtime validation'}


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('paths',nargs='+',type=Path)
    ap.add_argument('--fix',action='store_true')
    ap.add_argument('--body-terminals',action='store_true')
    ap.add_argument('--json',type=Path)
    args=ap.parse_args()
    paths=[]
    for p in args.paths:
        paths.extend(sorted(p.rglob('*.lmx')) if p.is_dir() else [p])
    results=[audit(p,args.fix,args.body_terminals) for p in paths]
    out={'files':results,'executed_LMX':False,'parser_validation':False}
    if args.json: args.json.write_text(json.dumps(out,indent=2,ensure_ascii=False)+'\n')
    for r in results:
        print(f"{r['file']}: {len(r['observations'])} observations; {r['inserted_cuts']} inserted cuts")
    return 0
if __name__=='__main__': raise SystemExit(main())

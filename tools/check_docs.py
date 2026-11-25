"""Check paired grammar, preserved source examples, links, and imported bytes."""
from pathlib import Path
import hashlib
import json
import re
from build_docs import render
from build_semantics import build as check_semantics

ROOT=Path(__file__).resolve().parents[1]

def doc_link_targets(text):
    '''Targets of the `](...)` links of a document text (fences already removed). A `](` after an odd number of backticks in
    its paragraph (counted from the last blank line) stands in inline code and is not a link; the search goes on after it.
    Twin of dl_in_code in selfbuild/tools/docs_check_links.lm2.'''
    targets=[];scan=0
    while True:
        first=text.find('](',scan)
        if first<0:break
        blank=text.rfind('\n\n',0,first);start=blank+2 if blank>=0 else 0
        if text.count('`',start,first)%2:
            scan=first+2;continue
        first+=2;after=text.find(')',first)
        if after<0:break
        if after>first:targets.append(text[first:after])
        scan=after+1
    return targets

def check_links(root=ROOT):
    # Check only authored documentation; historical fixture links belong to their source trees.
    docs=[*root.glob('README*.md'),*root.glob('docs/spec/*.md'),*root.glob('steps/*.md'),*root.glob('claude_chat/*.md'),root/'AGENTS.md',*root.glob('tests/parser/README*.md')]
    for path in docs:
        text=path.read_text(encoding='utf-8')
        text=re.sub(r'(?ms)^(`{3,}).*?^\1\s*$','',text)
        for target in doc_link_targets(text):
            if '://' in target:continue
            file,_,anchor=target.partition('#')
            dest=(path.parent/file).resolve() if file else path
            assert dest.exists(),f'Broken link in {path}: {target}'
            if anchor:
                assert f'id="{anchor}"' in dest.read_text(encoding='utf-8'),f'Missing anchor {target}'

def check_preface(data):
    assert 'preface' not in data or (isinstance(data['preface'],dict) and all(isinstance(data['preface'].get(l),str) and data['preface'][l].strip() for l in ('ru','en'))),'Preface needs both languages'

def main():
    semantic_count=check_semantics(check=True)
    data=json.loads((ROOT/'provenance/grammar.json').read_text(encoding='utf-8'))
    for lang in ('ru','en'):
        path=ROOT/'docs'/'spec'/f'LMX_grammar.{lang}.md'
        assert path.read_text(encoding='utf-8')==render(data,lang),f'Out of sync: {path}'
    ids=[s['id'] for s in data['sections']]
    assert len(ids)==len(set(ids))
    check_preface(data)
    source=Path(data['source']['path'])
    lines=None
    if source.is_file():
        assert hashlib.sha256(source.read_bytes()).hexdigest()==data['source']['sha256'],'Source changed since extraction'
        lines=source.read_text(encoding='utf-8-sig').splitlines()
    count=0
    for number,s in enumerate(data['sections'],1):
        assert s['number']==number
        for lang in ('ru','en'):
            assert s[lang]['title'].strip() and s[lang]['text'].strip()
        for e in s['examples']:
            assert e['text'].strip(),f'Empty excerpt: {e}'
            assert '````' not in e['text'],'Fence collision'
            if 'start' in e:
                count+=1
                if lines is not None:
                    assert e['text']=='\n'.join(lines[e['start']-1:e['end']]),f'Altered source excerpt {e["start"]}'
    ru=(ROOT/'docs/spec/LMX_semantics.ru.md').read_text(encoding='utf-8').split('\n\n')
    expected=[
        '**Lingvamyxa (далее LMX) — язык, в котором программа — лексический лес примитивных массивов, связанный в динамический граф.** Эта организация самоподобно повторяется на уровне локальных акторов с физической адресацией в памяти и далее — на уровне дальних межмашинных сообщений с комплексной адресацией.',
        '**И данные, и исполняемые тела являются массивами**, представленными одними и теми же простыми универсальными структурами; каждое исполняемое тело — полноценное абстрактное выражение.',
        '**Типизация аналитическая, на уровне лексических ветвей.** Допуск любого кандидата в аргументы любого выражения сначала проверяет используемые поля и их интерфейсы для реальных Consumer-вызовов; дополнительную аналитическую часть (`test`) программист явно задаёт в принимающем выражении. Протестированные кандидаты и проверяющие выражения однозначно идентифицируются своими физическими адресами.'
    ]
    assert ru[:3]==expected,'Author opening changed'
    assert len((ROOT/'docs/spec/LMX_semantics.en.md').read_text(encoding='utf-8').split('\n\n'))==len(ru),'Semantic paragraph counts differ between RU/EN'
    inventory=json.loads((ROOT/'provenance/parser-tests.json').read_text(encoding='utf-8'))
    files=inventory['files']
    for f in files:
        raw=(ROOT/f['path']).read_bytes()
        assert len(raw)==f['bytes'] and hashlib.sha256(raw).hexdigest()==f['sha256'],f'Altered imported file {f["path"]}'
        for origin in f['origins']:
            p=Path(origin['root'])/origin['path']
            if p.is_file():
                assert p.read_bytes()==raw,f'Source no longer matches imported snapshot: {p}'
    for source in inventory['sources']:
        base=Path(source['root'])
        if not base.is_dir():continue
        represented={o['path'] for f in files for o in f['origins'] if o['stage']==source['stage']}
        for p in (base/'tests').rglob('*.lmx'):
            assert p.relative_to(base).as_posix() in represented,f'Missing parser input {p}'
    check_links()
    tracked=check_eol()
    print(f'OK: {semantic_count} paired semantic chapters, 14 satisfies cases, both source snapshots; {len(ids)} paired grammar sections, {count} verbatim source excerpts, {len(files)} imported files, links, exact semantic opening; line endings LF in the index for all {tracked} tracked files (verbatim imports exempt)')

def check_eol():
    '''Every tracked text file is LF in the index (author, 2026-09-27: the whole project is LF, Windows adapts).
    Only the explicit -text attribute of .gitattributes exempts a path -- verbatim imports and the binaries named
    there by extension.  Git's own guess (i/-text) is not an exemption: a lone CR, a NUL or too many control bytes
    make git read a text file as binary, and steps/review-log.md passed both checks that way with one eaten `\r`
    (REVIEW 0b60c45).  i/none -- no line break at all -- has no ending to check.  The only CRLF working copy by
    design is one of the five .cmd of the author's C99 bundle (C99_CMD): LF in the index, CRLF at checkout by its own
    attribute text eol=crlf.  The three facts are required of each of them before any skip (Sol, 2026-11-25): another
    state is a finding, and check_ctrl still reads them.  No other path is exempt by an attribute.'''
    import subprocess
    # The five .cmd of the author's C99 bundle, by their exact paths (vendor/civetweb/.gitattributes: *.cmd text eol=crlf).
    C99_CMD={'third_party/lmx_c99_bundle/vendor/civetweb/build.cmd','third_party/lmx_c99_bundle/vendor/civetweb/mingw.cmd','third_party/lmx_c99_bundle/vendor/civetweb/test/windows.cgi.cmd','third_party/lmx_c99_bundle/vendor/civetweb/test/windows_fail.cgi.cmd','third_party/lmx_c99_bundle/vendor/civetweb/test/windows_fail_silent.cgi.cmd'}
    out=subprocess.run(['git','-C',str(ROOT),'ls-files','--eol','-z'],capture_output=True,check=True).stdout
    NUL=bytes([0]);TAB=bytes([9]);bad=[];seen=0
    for rec in out.split(NUL):
        if not rec:continue
        seen+=1
        head,path=rec.split(TAB,1)
        fields=head.split();name=path.decode()
        index=fields[0].decode();attrs=b' '.join(fields[2:]).decode();work=fields[1].decode()
        if name in C99_CMD:
            # Before the general skip: -text, text=false or a missing eol=crlf does not make it an ordinary file.
            if not (index=='i/lf' and work=='w/crlf' and 'eol=crlf' in attrs.split() and '-text' not in attrs and 'attr/text=false' not in attrs):
                bad.append(index+' '+work+' '+name+' (a .cmd of the C99 bundle must be i/lf + w/crlf + text eol=crlf)')
            continue
        if '-text' in attrs or index=='i/none':continue
        if index=='i/-text':bad.append(index+' '+name+' (git reads it as binary: a lone CR, a NUL or control bytes? a real binary needs -text in .gitattributes)');continue
        if index!='i/lf':bad.append(index+' '+name)
        if work in ('w/crlf','w/mixed'):bad.append(work+' '+name+' (a tool or editor wrote CRLF into the working tree)')
        if work=='w/-text':bad.append(work+' '+name+' (git reads the working copy as binary: a lone CR, a NUL or control bytes?)')
    assert not bad,'CRLF or mixed line endings (LF everywhere; index and working tree): '+', '.join(bad[:12])+(' ... %d files'%len(bad) if len(bad)>12 else '')
    check_ctrl(out)
    return seen


def check_ctrl(listing):
    '''No control byte but TAB and LF in a tracked text file (CR is check_eol's).  A writer that put
    L1 text through a non-raw Python string turned `\\b`, `\\f`, `\\a`, `\\v` into bytes 8, 12, 7, 11
    (REVIEW b307a0f; 10 such bytes found 2026-09-27).  -text imports and git's binaries are exempt, as
    in check_eol (only the explicit attribute, never git's guess); dev/mixa_sandbox is not touched until the
    kernel is finished (author, q34), its one byte is a debt in next_core_tasks.md §9.'''
    NUL=bytes([0]);TAB=bytes([9]);bad=[]
    for rec in listing.split(NUL):
        if not rec:continue
        head,path=rec.split(TAB,1)
        fields=head.split()
        index=fields[0].decode();attrs=b' '.join(fields[2:]).decode()
        name=path.decode()
        if '-text' in attrs or name.startswith('dev/mixa_sandbox/'):continue
        data=(ROOT/name).read_bytes()
        for n,line in enumerate(data.split(b'\n'),1):
            hit=[b for b in line if b<32 and b not in (9,13)]
            if hit:bad.append('%s:%d byte %d'%(name,n,hit[0]))
    assert not bad,'control bytes in tracked text (a non-raw string ate a backslash escape?): '+', '.join(bad[:12])+(' ... %d'%len(bad) if len(bad)>12 else '')


if __name__=='__main__':main()

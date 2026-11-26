#!/usr/bin/env python3
"""Reproducible C API source inventory for the pinned LMX compact collection.

This is a source census, not a compiler or a claim that every declaration links.
It tokenizes declarators with balanced delimiters; GCC preprocessing supplements
token-pasted public API families. Public macro templates and callbacks remain
separate entry kinds and are never reported as binary-exported functions.
"""
from __future__ import annotations
import argparse, collections, concurrent.futures, hashlib, json, re, subprocess, tempfile
from pathlib import Path

PREFIX='third_party/lmx_c99_compact/'
# Explicit public/header surface from retained CMake PUBLIC/INTERFACE includes,
# upstream umbrella headers, and generated-view recipes. Internal headers in
# these directories are retained with an internal disposition, not discarded.
SURFACES={
'curl':'vendor/curl/include/curl/*.h',
'mbedtls':'vendor/mbedtls/include/mbedtls/*.h vendor/mbedtls/include/psa/*.h',
'zlib':'vendor/zlib/zlib.h vendor/zlib/zconf.h',
'sqlite3':'vendor/sqlite3/sqlite3.h',
'stb':'vendor/stb/*.h',
'klib':'vendor/klib/*.h vendor/klib/lmx/*.h',
'stc':'vendor/stc/include/stc/*.h vendor/stc/include/stc/priv/*.h',
'decnumber':'vendor/decnumber/*.h',
'libsodium':'vendor/libsodium/src/libsodium/include/sodium.h vendor/libsodium/src/libsodium/include/sodium/*.h',
'sljit':'vendor/sljit/sljit_src/sljitLir.h',
'linmath':'vendor/linmath/linmath.h',
'kissfft':'vendor/kissfft/kiss_fft.h vendor/kissfft/kiss_fftr.h vendor/kissfft/kiss_fftnd.h vendor/kissfft/kiss_fftndr.h vendor/kissfft/kfc.h',
'tinyspline':'vendor/tinyspline/src/tinyspline.h',
'wavelib':'vendor/wavelib/header/*.h',
'cephes':'include/lmx_cephes.h',
'cmpfit':'vendor/cmpfit/mpfit.h',
'xoshiro':'include/lmx_rng.h include/c99_gsl.h',
'libtommath':'vendor/libtommath/tommath.h',
'mpdecimal':'vendor/mpdecimal/libmpdec/mpdecimal.h.in',
'cquadpack':'include/lmx_quadpack.h include/c99_quad.h vendor/cquadpack/include/cquadpack.h',
'stroud_rule':'include/lmx_stroud.h vendor/stroud_rule/stroud_rule.h',
'sparse_grid_hw':'include/lmx_sparse_grid_hw.h vendor/sparse_grid_hw/sparse_grid_hw.h',
'sobol':'include/lmx_sobol.h',
'dyad':'vendor/dyad/src/dyad.h',
'enet':'vendor/enet/include/enet/*.h',
'libssh2':'vendor/libssh2/include/*.h',
'monocypher':'vendor/monocypher/src/monocypher.h vendor/monocypher/src/optional/monocypher-ed25519.h',
'miniz':'vendor/miniz/*.h',
'lz4':'vendor/lz4/lib/*.h',
'microtar':'vendor/microtar/src/microtar.h',
'jsmn':'vendor/jsmn/jsmn.h',
'cjson':'vendor/cjson/cJSON.h vendor/cjson/cJSON_Utils.h',
'tinydir':'vendor/tinydir/tinydir.h',
'tinycthread':'vendor/tinycthread/source/tinycthread.h',
'libvterm':'vendor/libvterm/include/*.h',
'llhttp':'vendor/llhttp/include/llhttp.h',
'sokol':'vendor/sokol/*.h vendor/sokol/util/*.h extensions/graphics/include/lmx_sokol_backend.h',
'nuklear':'vendor/nuklear/nuklear.h',
'microui':'vendor/microui/src/microui.h',
'olive':'vendor/olive/olive.c',
'qoi':'vendor/qoi/qoi.h',
'lodepng':'vendor/lodepng/lodepng.h',
'libspng':'vendor/libspng/spng/spng.h',
'tpng':'vendor/tpng/tpng.h',
'tjpgdec':'vendor/tjpgdec/src/tjpgd.h',
'nanojpeg':'extensions/graphics/include/lmx_nanojpeg.h vendor/nanojpeg/nanojpeg.c',
'gifdec':'vendor/gifdec/gifdec.h',
'msf_gif':'vendor/msf_gif/msf_gif.h',
'miniaudio':'vendor/miniaudio/miniaudio.h',
'dr_wav':'vendor/dr_libs/dr_wav.h',
'dr_mp3':'vendor/dr_libs/dr_mp3.h',
'dr_flac':'vendor/dr_libs/dr_flac.h',
'minimp3':'vendor/minimp3/minimp3.h vendor/minimp3/minimp3_ex.h',
'TinySoundFont':'vendor/tinysoundfont/tsf.h vendor/tinysoundfont/tml.h',
'pl_mpeg':'vendor/pl_mpeg/pl_mpeg.h',
'jo_mpeg':'vendor/jo_mpeg/jo_mpeg.cpp',
'jo_gif':'vendor/jo_gif/jo_gif.cpp',
'jo_mp1':'vendor/jo_mp1/jo_mp1.cpp',
'minih264':'vendor/minih264/minih264e.h',
'nestegg':'vendor/nestegg/include/nestegg/nestegg.h',
'h264bsd':'vendor/h264bsd/src/*.h',
'libwebp':'vendor/libwebp/src/webp/*.h vendor/libwebp/sharpyuv/sharpyuv.h vendor/libwebp/sharpyuv/sharpyuv_csp.h',
'pdfgen':'vendor/pdfgen/pdfgen.h',
'md4c':'vendor/md4c/src/md4c.h vendor/md4c/src/md4c-html.h',
'gumbo':'vendor/gumbo/src/gumbo.h',
'yxml':'vendor/yxml/yxml.h',
'ezxml':'vendor/ezxml/ezxml.h',
'tomlc99':'vendor/tomlc99/toml.h',
'libyaml':'vendor/libyaml/include/yaml.h',
'cgltf':'vendor/cgltf/cgltf.h vendor/cgltf/cgltf_write.h',
'fast_obj':'vendor/fast_obj/fast_obj.h',
'kuba_zip':'vendor/kuba_zip/src/zip.h',
'zstd':'vendor/zstd/lib/*.h',
'lzma_sdk':'vendor/lzma_sdk/C/*.h',
'cmp':'vendor/cmp/cmp.h',
'mpack':'vendor/mpack/src/mpack/*.h',
'nanopb':'vendor/nanopb/*.h',
'xlsxio':'vendor/xlsxio/include/*.h',
'expat':'vendor/expat/lib/expat.h vendor/expat/lib/expat_external.h',
'minizip':'vendor/zlib/contrib/minizip/zip.h vendor/zlib/contrib/minizip/unzip.h vendor/zlib/contrib/minizip/ioapi.h vendor/zlib/contrib/minizip/mztools.h',
'hiredis':'vendor/hiredis/*.h vendor/hiredis/adapters/*.h',
'mongo_c_driver':'vendor/mongo_c_driver/src/libbson/src/bson/*.h vendor/mongo_c_driver/src/libmongoc/src/mongoc/*.h vendor/mongo_c_driver/src/utf8proc-2.11.3/utf8proc.h',
'postgresql-libpq':'vendor/postgresql/src/interfaces/libpq/libpq-fe.h vendor/postgresql/src/interfaces/libpq/libpq-events.h',
'sqlite_vec':'vendor/sqlite_vec_amalgamation/sqlite-vec.h',
'tinyfiledialogs':'vendor/tinyfiledialogs/tinyfiledialogs.h',
'whereami':'vendor/whereami/src/whereami.h',
'cglm':'vendor/cglm/include/cglm/**/*.h vendor/cglm/include/cglm/*.h',
'quirc':'vendor/quirc/lib/quirc.h',
'qrcodegen':'vendor/qrcodegen/c/qrcodegen.h',
'tiny_regex_c':'vendor/tiny_regex_c/re.h',
'geodesic':'vendor/geodesic/src/geodesic.h',
'h3':'vendor/h3/src/h3lib/include/h3api.h.in',
'rtree':'vendor/rtree/rtree.h',
'shapelib':'vendor/shapelib/shapefil.h',
'minmea':'vendor/minmea/minmea.h',
'ryu':'vendor/ryu/ryu/ryu.h',
'tlsf':'vendor/tlsf/tlsf.h',
'genann':'vendor/genann/genann.h',
'kann':'vendor/kann/kann.h vendor/kann/kautodiff.h vendor/kann/kann_extra/kann_data.h',
'liquid_dsp':'vendor/liquid_dsp/include/liquid.h',
'quiet':'vendor/quiet/include/quiet.h vendor/quiet/include/quiet/*.h',
'jansson':'vendor/jansson/src/jansson.h',
'sgp4':'vendor/sgp4/src/c/*.h',
'utensil':'vendor/utensil/utensil.h',
'mint':'vendor/mint/mint.h',
'cwalk':'vendor/cwalk/include/cwalk.h',
'utf8':'vendor/utf8/utf8.h',
'tinn':'vendor/tinn/Tinn.h',
'afan_neural_network':'vendor/afan_neural_network/neural_network.h',
'nnom':'vendor/nnom/inc/*.h vendor/nnom/inc/layers/*.h',
'static_embeddings':'extensions/embeddings/include/lmx_static_embeddings.h',
'libcorrect':'vendor/libcorrect/include/correct.h vendor/libcorrect/include/correct-sse.h vendor/libcorrect/include/fec_shim.h',
}
TARGETS={
'libsodium':['sodium'],'libtommath':['tommath'],'mpdecimal':['mpdec'],
'xoshiro':['rng'],'cquadpack':['quadpack','quadrature'],'stroud_rule':['stroud','quadrature'],
'sparse_grid_hw':['sparse_grid_hw','quadrature'],'libvterm':['vterm'],
'TinySoundFont':['tinysoundfont','tsf'],'libwebp':['webp','webpmux','webpdemux'],
'mongo_c_driver':['bson','mongoc'],'postgresql-libpq':['pq','libpq'],
'xlsxio':['xlsxio_read','xlsxio_write'],'ryu':['ryu'],'libcorrect':['correct','correct_fec'],
'utf8':['utf8_headers'],'md4c':['md4c','md4c_html']}
TYPE_WORDS=set('void char short int long float double signed unsigned const volatile restrict static extern register auto inline __inline __inline__ _Bool bool struct union enum typedef _Complex complex'.split())
IGNORE_NAMES=set('if while for switch return sizeof alignof _Alignof __attribute__ __attribute __declspec __asm __asm__ asm typeof __typeof__ _Static_assert static_assert defined __volatile__'.split())
TOKEN=re.compile(r'(?P<string>"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\')|(?P<id>[A-Za-z_$][\w$]*)|(?P<num>\d+(?:\.\d*)?(?:[eEpP][+-]?\d+)?[uUlLfF]*)|(?P<op>\.\.\.|##|->|==|!=|<=|>=|&&|\|\||<<|>>|[^\s])')
COMMENT=re.compile(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',re.S)

def clean_comments(text):
    return COMMENT.sub(lambda m: ''.join('\n' if c=='\n' else ' ' for c in m[0]) if m[0].startswith(('/',)) else m[0],text)

def logical_preprocessor(text):
    """Yield complete directive spans, including every continued physical line."""
    offset=0;begin=None;parts=[]
    for line in text.splitlines(True):
        if begin is None and re.match(r'^[ \t]*#',line):begin=offset;parts=[]
        if begin is not None:
            parts.append(line)
            if not line.rstrip('\r\n').endswith('\\'):
                yield begin,offset+len(line),''.join(parts)
                begin=None;parts=[]
        offset+=len(line)
    if begin is not None:yield begin,len(text),''.join(parts)

def normalize(text): return re.sub(r'\s+',' ',text).strip()
def split_balanced(tokens,sep=','):
    result=[]; start=0; depth=0
    for i,t in enumerate(tokens):
        if t[0] in ('(','[','{'): depth+=1
        elif t[0] in (')',']','}'): depth-=1
        elif t[0]==sep and depth==0: result.append(tokens[start:i]);start=i+1
    result.append(tokens[start:]);return result

def render(tokens): return normalize(' '.join(t[0] for t in tokens))

def params_from(tokens):
    out=[]
    if render(tokens) in ('','void'): return out
    for i,part in enumerate(split_balanced(tokens)):
        raw=render(part)
        if raw=='...':out.append({'name':'varargs','c_type':'...','declaration':'...','variadic':True});continue
        # Declarator identifier: explicit (*name) first, then final non-keyword
        # outside attributes. Preserve unnamed parameters using argN.
        name=None; name_index=None
        for j in range(len(part)-2):
            if part[j][0]=='*' and re.fullmatch(r'[A-Za-z_]\w*',part[j+1][0]) and part[j+2][0]==')':
                name=part[j+1][0]; name_index=j+1;break
        if not name:
            # Ignore identifiers in an array bound and in nested callback args.
            depth=0; ids=[]
            for j,t in enumerate(part):
                v=t[0]
                if v in ('(','['):depth+=1
                elif v in (')',']'):depth-=1
                elif depth==0 and re.fullmatch(r'[A-Za-z_]\w*',v) and v not in TYPE_WORDS:ids.append((j,v))
            if ids:
                j,v=ids[-1]
                preceding=[q[0] for q in part[:j] if q[0] not in ('const','volatile','restrict')]
                if preceding and not (len(preceding)==1 and preceding[0] in ('struct','union','enum')):
                    name=v;name_index=j
        ctype=render([t for j,t in enumerate(part) if j!=name_index])
        # Annotation macros such as SDL_OUT_Z_CAP(n) are not function-pointer
        # arguments. Recognize the actual declarator and resolve named callback
        # typedefs later within their component.
        is_callback=bool(re.search(r'\(\s*(?:[A-Za-z_]\w*\s+)*\*[^)]*\)\s*\(',raw)
                         or (name and re.search(r'\b'+re.escape(name)+r'\s*\(',raw)))
        out.append({'name':name or f'arg{i+1}','c_type':ctype,'declaration':raw,'name_in_source':name is not None,'pointer':('*' in raw) or is_callback,'array':('[' in raw),'callback':is_callback})
    return out

def scan_decl(tokens,text,body=False):
    if not tokens:return None
    vals=[t[0] for t in tokens]
    if vals[0] in ('return','if','for','while','switch','case') or '=' in vals:return None
    # Function-pointer typedefs / struct fields are callback types, not functions.
    nesting=[];level=0
    for v in vals:
        nesting.append(level)
        if v=='(':level+=1
        elif v==')':level=max(0,level-1)
    for i in range(len(tokens)-4):
        if nesting[i]!=0 or vals[i]!='(':continue
        depth=1;close=i+1
        while close<len(tokens) and depth:
            depth+=(vals[close]=='(')-(vals[close]==')');close+=1
        close-=1
        if depth or close+1>=len(tokens) or vals[close+1]!='(':continue
        # Calling-convention tokens may precede the star: (SDLCALL *cb).
        # A function typedef may omit it entirely: typedef int (cb)(...).
        # APIENTRYP and similar platform macros may themselves expand to '*'.
        inside=vals[i+1:close];is_typedef='typedef' in vals[:i]
        if '*' not in inside and not is_typedef:continue
        indices=[k for k in range(i+1,close) if re.fullmatch(r'[A-Za-z_]\w*',vals[k]) and vals[k] not in TYPE_WORDS]
        if not indices:continue
        if '*' in inside:
            star=max(k for k in range(i+1,close) if vals[k]=='*')
            indices=[k for k in indices if k>star]
            if not indices:continue
            ni=indices[0]
        else:ni=indices[-1]
        depth=1;j=close+2
        while j<len(tokens) and depth:
            depth+=(vals[j]=='(')-(vals[j]==')');j+=1
        if depth:return None
        return dict(name=vals[ni],kind='callback',return_type=render(tokens[:i]).replace('typedef ','',1),parameters=params_from(tokens[close+2:j-1]),signature=render(tokens),offset=tokens[ni][1],body=body)
    pairs=[];stack=[]
    for i,v in enumerate(vals):
        if v=='(':stack.append(i)
        elif v==')' and stack:
            a=stack.pop()
            if not stack and a>0 and re.fullmatch(r'[A-Za-z_$][\w$]*',vals[a-1]):pairs.append((a-1,a,i))
    candidates=[p for p in pairs if vals[p[0]] not in IGNORE_NAMES and not vals[p[0]].startswith(('__attribute','__declspec'))]
    if not candidates:return None
    # Suffix annotations are usually all capitals; prefer a name with ordinary
    # casing. A prefix macro call (EXPORT(type)) is not the callable itself.
    real=[p for p in candidates if p[0]>0 and (not vals[p[0]].isupper() or vals[p[0]].startswith(('H3_','H264','XML_')))]
    if not real:real=[p for p in candidates if p[0]>0]
    if not real:return None
    n,a,b=real[-1]
    if n>0 and vals[n-1] in ('*','&') and n>=2 and vals[n-2]=='(':return None
    prefix=render(tokens[:n])
    if not prefix or prefix.endswith(('#','##','.','->')):return None
    if any(x in vals[:n] for x in ('return','if','case')):return None
    if 'typedef' in vals[:n]: kind='callback'
    elif any(x in prefix.lower() for x in ('inline','forceinline')):kind='static_inline'
    elif 'static' in vals[:n]:kind='static_header_function'
    else:kind='function'
    return dict(name=vals[n],kind=kind,return_type=prefix,parameters=params_from(tokens[a+1:b]),signature=render(tokens),offset=tokens[n][1],body=body)

def declarations(text):
    # Keep all conditional branches in the raw census; mask preprocessor logical
    # lines so function macro bodies cannot impersonate real declarations.
    clean=clean_comments(text)
    chunks=[];last=0
    for a,b,part in logical_preprocessor(clean):
        chunks.append(clean[last:a]);chunks.append(''.join('\n' if c=='\n' else ' ' for c in part));last=b
    chunks.append(clean[last:]);masked=''.join(chunks)
    tokens=[(m[0],m.start(),m.end()) for m in TOKEN.finditer(masked)]
    result=[];start=0;i=0;paren=0;bracket=0
    while i<len(tokens):
        v=tokens[i][0]
        if v=='(':paren+=1
        elif v==')':paren=max(0,paren-1)
        elif v=='[':bracket+=1
        elif v==']':bracket=max(0,bracket-1)
        elif v==';' and paren==0 and bracket==0:
            d=scan_decl(tokens[start:i],masked)
            if d:result.append(d)
            start=i+1
        elif v=='{' and paren==0 and bracket==0:
            prefix=tokens[start:i]
            if any(t[0]=='extern' for t in prefix) and any(t[0]=='"C"' for t in prefix):
                start=i+1;i+=1;continue
            d=scan_decl(prefix,masked,True)
            if d:result.append(d)
            # Entire body or aggregate. Examine callback fields of aggregates
            # separately, never recurse into function bodies.
            depth=1;j=i+1
            while j<len(tokens) and depth:
                depth+=(tokens[j][0]=='{')-(tokens[j][0]=='}');j+=1
            if not d:
                parts=split_balanced(tokens[i+1:j-1],';')
                for part in parts:
                    cb=scan_decl(part,masked)
                    if cb and cb['kind']=='callback':result.append(cb)
            i=j-1;start=j
        elif v=='}' and paren==0:
            start=i+1
        i+=1
    return result

def macro_records(text):
    clean=clean_comments(text)
    pattern=re.compile(r'^[ \t]*#\s*define\s+([A-Za-z_]\w*)\((.*?)\)(.*)',re.S)
    for offset,end,logical in logical_preprocessor(clean):
        m=pattern.match(logical.replace('\\\n',' '))
        if not m:continue
        name,args,body=m.group(1,2,3);body=normalize(body)
        yield dict(name=name,kind='template' if ('##' in body and ('(' in body or 'typedef' in body)) else 'function_macro',signature=f'{name}({args})',return_type=None,parameters=[{'name':a.strip(),'c_type':None,'declaration':a.strip()} for a in args.split(',') if a.strip()],offset=offset,body=False,macro_replacement=body,unresolved=True)

def conditions_by_line(text):
    stack=[];out={};line=1;continued=False
    for s in text.splitlines():
        m=re.match(r'\s*#\s*(if|ifdef|ifndef|elif|else|endif)\b(.*)',s)
        if m:
            op,expr=m.groups();expr=expr.strip()
            if op in ('if','ifdef','ifndef'):stack.append(f'{op} {expr}')
            elif op in ('elif','else') and stack:stack[-1]=f'{op} {expr}'.rstrip()
            elif op=='endif' and stack:stack.pop()
        out[line]=tuple(stack);line+=1
    return out

def main():
    ap=argparse.ArgumentParser();ap.add_argument('source',type=Path);ap.add_argument('output',type=Path);args=ap.parse_args()
    r=args.source.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
    manifest=json.loads((r/'SOURCES.json').read_text());components=[];all_entries=[];header_records=[];diagnostics=[];component_macros={}
    for comp in manifest['components']:
        cid=comp['id'];short=cid.split(':',1)[1]
        patterns=comp.get('public_headers') or SURFACES.get(short)
        if not patterns:raise ValueError('No public surface definition for '+cid+'; add public_headers to SOURCES.json or SURFACES in this script')
        if isinstance(patterns,str):patterns=patterns.split()
        target_names=comp.get('cmake_targets') or comp.get('targets') or TARGETS.get(short,[short])
        if isinstance(target_names,str):target_names=[target_names]
        for pattern in patterns:
            if not any(p.is_file() for p in r.glob(pattern)):
                diagnostics.append({'operation':'public_surface_resolution','component':cid,'severity':'missing_declared_surface','pattern':pattern})
        headers=sorted({p for pattern in patterns for p in r.glob(pattern) if p.is_file()})
        component=dict(comp);component['targets']=[x if '::' in x else 'LMX::'+x for x in target_names];component['surface_patterns']=patterns;component['headers']=[PREFIX+p.relative_to(r).as_posix() for p in headers];component['source_validation']='source_census_only_not_link_test';components.append(component)
        cached={path:path.read_text(errors='replace') for path in headers}
        macro_cache={path:list(macro_records(raw)) for path,raw in cached.items()}
        component_macros[cid]={m['name'] for ms in macro_cache.values() for m in ms}
        for path in headers:
            rel=path.relative_to(r).as_posix();raw=cached[path];conds=conditions_by_line(raw)
            ds=declarations(raw);ms=macro_cache[path];
            header_records.append({'component':cid,'path':PREFIX+rel,'targets':component['targets'],'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size,'raw_declarations':len(ds),'function_macros':len(ms)})
            for d in ds+ms:
                line=raw.count('\n',0,d.pop('offset'))+1
                d.update(component=cid,source={'path':PREFIX+rel,'line':line},conditions=list(conds.get(line,())),targets=component['targets'],extraction='balanced_declarator_scan',canonical_header=canonical_header(rel),classification=d.pop('kind'))
                classify(d,short,rel,component_macros[cid])
                all_entries.append(d)
        print(cid,len(headers),sum(e['component']==cid for e in all_entries),flush=True)
    # Literal aliases are retained separately; the public names are never
    # silently treated as a new binary symbol.
    callable_names={(e['component'],e['name']) for e in all_entries if e['classification'] in ('function','static_inline','static_header_function')}
    for h in header_records:
        rel=h['path'][len(PREFIX):];raw=(r/rel).read_text(errors='replace')
        for m in re.finditer(r'^\s*#\s*define\s+(\w+)\s+(\w+)\s*(?:/\*.*?\*/\s*)?$',raw,re.M):
            a,b=m.group(1,2)
            if a!=b and (h['component'],b) in callable_names:
                all_entries.append({'component':h['component'],'name':a,'classification':'alias','signature':a+' -> '+b,'return_type':None,'parameters':[],'source':{'path':h['path'],'line':raw.count('\n',0,m.start())+1},'canonical_header':canonical_header(rel),'targets':next(c['targets'] for c in components if c['id']==h['component']),'alias_of':b,'availability':'header_alias','unresolved':False,'notes':['Alias has no independent addressable binary entry.'],'extraction':'object_macro_alias'})
    supplement_isolated_headers(r,out,all_entries,header_records,diagnostics,component_macros)
    supplement_preprocessor(r,out,all_entries,diagnostics)
    add_source_exports(r,all_entries)
    add_sql_entries(r,all_entries)
    build_findings=audit_build_inputs(r)
    diagnostics.extend(build_findings)
    for component in components:
        component['build_input_status']='blocked_missing_retained_build_files' if component['id']=='databases:mongo_c_driver' and build_findings else 'not_configured_or_link_tested'
    # One callable identity regardless of extern/static/inline profile. Preserve
    # linkage kinds as declaration variants; macros and callbacks stay separate.
    callable_kinds=('function','static_inline','static_header_function')
    groups={}
    for e in all_entries:
        identity_kind='callable' if e['classification'] in callable_kinds else e['classification']
        key=(e['component'],e['name'],identity_kind)
        if e['classification']=='callback':key+=(e['source']['path'],)
        if key not in groups:
            groups[key]=dict(e,declarations=[])
        old=groups[key]
        variant={k:e.get(k) for k in ('signature','return_type','parameters','source','conditions','extraction','availability','unresolved','notes','body','classification','canonical_header','targets')}
        if variant not in old['declarations']:old['declarations'].append(variant)
        # Prefer the preprocessed signature if it resolves a real name/type.
        if e.get('extraction')=='gcc_preprocessed' and old.get('extraction')!='gcc_preprocessed':
            decls=old['declarations'];groups[key]=dict(e,declarations=decls)
    entries=[]
    components_by_id={c['id']:c for c in components}
    for e in groups.values():
        # A public prototype outside IMPLEMENTATION wins over the corresponding
        # implementation definition. Functions that exist only in implementation
        # regions stay in the census but are not published as public API.
        def in_implementation(v):
            for condition in v.get('conditions') or []:
                if condition.startswith('ifndef'):continue
                positive=re.sub(r'!\s*defined\s*(?:\([^)]*\)|\w+)','',condition)
                if re.search(r'(?:IMPLEMENTATION|_IMPL\b)',positive):return True
            return False
        e['symbol_kinds']=sorted({v.get('classification',e['classification']) for v in e['declarations']})
        if e['classification'] in callable_kinds+('function_macro','template'):
            public=[v for v in e['declarations'] if not in_implementation(v)
                    and not any(disabled_condition(x) for x in v.get('conditions') or [])
                    and v.get('availability') not in ('internal_header_surface','disabled_example','unexpanded_declarator_template')]
            if not public and e['availability'] not in ('internal_header_surface','disabled_example','unexpanded_declarator_template'):
                e['availability']='implementation_helper'
                e['notes'].append('No public declaration outside implementation/disabled-example region was found.')
            elif public:
                # Prefer expanded names/types. The isolated profile is explicitly
                # marked as such and still does not prove the configured ABI.
                def priority(v):
                    if v.get('extraction')=='gcc_preprocessed':return 0
                    if v.get('extraction')=='gcc_isolated_header_macro_expansion':return 1
                    return 3 if v.get('body') else 2
                candidate=min(public,key=priority)
                for k in ('signature','return_type','parameters','source','conditions','extraction','body','classification','canonical_header','targets','availability','unresolved','notes'):
                    if candidate.get(k) is not None:e[k]=candidate[k]
        identity_kind='callable' if e['classification'] in callable_kinds else e['classification']
        identity=e['component']+'|'+identity_kind+'|'+e['name']
        if e['classification']=='callback':identity+='|'+e['source']['path']
        e['id']='capi_'+hashlib.sha256(identity.encode()).hexdigest()[:16]
        e['abi_symbol']=e.get('alias_of',e['name'])
        if e['availability']=='upstream_symbol_renamed':
            rename_prefix={'base:cquadpack':'lmx_quadpack_','base:stroud_rule':'lmx_stroud_','base:sparse_grid_hw':'lmx_sparse_'}[e['component']]
            e['abi_symbol']=rename_prefix+e['name'];e['alias_of']=e['abi_symbol']
        comp=components_by_id[e['component']]
        exact=comp.get('abi_symbol_map',{})
        prefixes=comp.get('abi_symbol_prefix_map',{})
        if e['name'] in exact:e['abi_symbol']=exact[e['name']]
        else:
            for before,after in sorted(prefixes.items(),key=lambda kv:-len(kv[0])):
                if e['name'].startswith(before):
                    e['abi_symbol']=after+e['name'][len(before):];break
        header_overrides=comp.get('canonical_header_map',{})
        source_relative=e['source']['path'].removeprefix(PREFIX)
        if source_relative in header_overrides:e['canonical_header']=header_overrides[source_relative]
        if e['abi_symbol']!=e['name'] and e['availability']!='upstream_symbol_renamed':
            e['notes'].append('Collection ABI namespace rewrite: '+e['name']+' -> '+e['abi_symbol']+'. Use the generated public header from the CMake target.')
        if e['name'] in comp.get('declared_unimplemented',[]) and e['availability'] not in ('implementation_helper','internal_header_surface','disabled_example'):
            e['availability']='declared_without_implementation'
            e['notes'].append('Retained public declaration has no implementation in this pinned source/build; keep as a contract stub, never enable a native-call branch.')
        e['return_type_original']=e.get('return_type')
        if e.get('return_type'):
            e['return_type']=clean_return_type(e['return_type'])
        e['publish_candidate']=e['classification'] in ('function','static_inline','static_header_function') and e['availability'] not in ('implementation_helper','internal_header_surface','disabled_example','upstream_symbol_renamed','unexpanded_declarator_template')
        e['pub_candidate']=e['publish_candidate']
        if not e['publish_candidate'] and e['classification'] in ('function','static_inline','static_header_function'):
            e['ffi_disposition']='retain_internal_or_renamed_reference'
        elif e['availability']=='declared_without_implementation':e['ffi_disposition']='unimplemented_declaration_contract'
        elif e['classification']=='callback':e['ffi_disposition']='callback_contract_and_actor_trampoline'
        elif e['classification']=='sql_api':e['ffi_disposition']='prepared_sql_adapter'
        elif e['classification']=='alias':e['ffi_disposition']='canonical_symbol_alias'
        elif e['classification']=='template':e['ffi_disposition']='typed_template_instantiation' if e.get('macro_role')=='generic_code_generator' else 'metadata_only_declaration_template'
        elif e['classification']=='function_macro':e['ffi_disposition']='typed_macro_shim' if e.get('macro_role')=='runtime_operation' else 'metadata_only_non_runtime_macro'
        elif e['component'] in ('scientific_formats:hdf5','scientific_formats:netcdf','scientific_formats:pnetcdf'):
            e['ffi_disposition']='typed_scientific_resource_bridge'
        elif any(p.get('variadic') for p in e.get('parameters',[])):e['ffi_disposition']='fixed_signature_varargs_adapter'
        elif e['classification'] in ('static_inline','static_header_function'):e['ffi_disposition']='addressable_C_shim'
        else:e['ffi_disposition']='typed_L2_shim_then_L3_wrapper'
        e['variant_count']=len(e['declarations']);entries.append(e)
    # Numeric C IDs can represent live resources. Preserve the native signature
    # while giving the proposed LMX boundary an owner-bound resource model.
    for e in entries:
        if e['component'] not in ('scientific_formats:netcdf','scientific_formats:pnetcdf'):continue
        for params in [e.get('parameters',[])]+[v.get('parameters') or [] for v in e['declarations']]:
            for p in params:
                name=p.get('name','')
                if name in {'ncid','ncid1','ncid2','ncid_in','ncid_out','src_ncid','dst_ncid','parent_ncid','grpid','grp_ncid','rootid','hid'}:
                    p['semantic_role']='native_resource_output' if p.get('pointer') else 'native_resource_id'
                    p['resource_kind']='cdf_header' if name=='hid' else 'dataset_file_or_group'
                    p['resource_backend']=e['component']
                elif name in {'ncidp','grpidp','new_ncid','new_ncidp','hidp'}:
                    p['semantic_role']='native_resource_output'
                    p['resource_kind']='cdf_header' if name=='hidp' else 'dataset_file_or_group'
                    p['resource_backend']=e['component']
                elif name=='ncids':
                    p['semantic_role']='native_resource_vector'
                    p['resource_kind']='dataset_file_or_group'
                    p['resource_backend']=e['component']
        if e.get('pub_candidate'):
            e['notes'].append('C integer file/group IDs are owner-bound resources at the LMX boundary. Validate child variable/dimension/type IDs against that file/group; do not expose a process-global ncid as an unrestricted scalar capability.')
    # A callback typedef hides the pointer syntax at its use site. Resolve these
    # references from declarations, rather than treating the typedef as a scalar
    # or opaque resource. Callback struct fields themselves are not typedefs.
    callback_types={(e['component'],e['name']):e['id'] for e in entries
                    if e['classification']=='callback' and e['name'] not in TYPE_WORDS and re.search(r'\btypedef\b',e['signature'])}
    for e in entries:
        refs=set()
        for params in [e.get('parameters',[])]+[v.get('parameters') or [] for v in e['declarations']]:
            for p in params:
                ids=re.findall(r'\b[A-Za-z_]\w*\b',p.get('c_type') or '')
                matched=[(name,callback_types[(e['component'],name)]) for name in ids if (e['component'],name) in callback_types]
                if matched:
                    p['callback']=True;p['pointer']=True;p['callback_type_refs']=[ref for name,ref in matched]
                    refs.update(name for name,ref in matched)
        if refs:
            e['notes'].append('Callback typedef parameter(s): '+', '.join(sorted(refs))+'. Use an actor-owned trampoline/lifetime contract.')
    entries.sort(key=lambda e:(e['component'],e['classification'],e['name'],e['id']))
    coverage=make_coverage(r,components,entries,header_records,diagnostics)
    result={'schema_version':1,'scope':'Pinned archive public-header and generated-view API source census; not ABI/link validation','source_root':PREFIX.rstrip('/'),'source_manifest_sha256':hashlib.sha256((r/'SOURCES.json').read_bytes()).hexdigest(),'components':components,'entries':entries,'header_coverage':header_records,'diagnostics':diagnostics,'limitations':coverage['limitations']}
    (out/'inventory.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    (out/'coverage.json').write_text(json.dumps(coverage,ensure_ascii=False,indent=2)+'\n')
    write_report(out,coverage)
    print(json.dumps(coverage['summary'],ensure_ascii=False))

def canonical_header(rel):
    if rel.startswith('include/'):return rel[len('include/'):]
    if '/include/' in rel:return rel.split('/include/',1)[1]
    for marker,prefix in [('/src/libmongoc/src/mongoc/','mongoc/'),('/src/libbson/src/bson/','bson/'),('/libwebp/src/webp/','webp/'),('/mpack/src/mpack/','mpack/'),('/ryu/ryu/','ryu/'),('/lzma_sdk/C/','lzma_sdk/'),('/zlib/contrib/minizip/','minizip/')]:
        if marker in rel:return prefix+rel.split(marker,1)[1]
    if '/kuba_zip/src/' in rel:return 'kuba_zip/'+Path(rel).name
    if rel.endswith('mpdecimal.h.in'):return 'mpdecimal.h'
    if rel.endswith('h3api.h.in'):return 'h3api.h'
    if '/jo_' in rel and rel.endswith('.cpp'):return Path(rel).stem+'.h'
    if rel.endswith('/olive.c'):return 'olive.c'
    return Path(rel).name

def clean_return_type(value):
    value=re.sub(r'\b(?:BSON_EXPORT|MONGOC_EXPORT|CJSON_PUBLIC|XMLPARSEAPI|APR_DECLARE|APR_DECLARE_NONSTD|APU_DECLARE|APU_DECLARE_NONSTD)\s*\(\s*([^()]+?)\s*\)',r'\1',value)
    value=re.sub(r'\b(?:extern|static|inline|__inline|__inline__|__forceinline|typedef)\b',' ',value)
    value=re.sub(r'\b(?:CURL_EXTERN|CURL_CALL|ZEXTERN|ZEXPORT|ZEXPORTVA|SQLITE_API|SQLITE_DEPRECATED|SQLITE_EXPERIMENTAL|LIBSSH2_API|LIBSSH2_DEPRECATED|BSON_BEGIN_DECLS|MONGOC_BEGIN_DECLS|MPD_PRAGMA|WAI_FUNCSPEC|CGLM_INLINE|CGLM_EXPORT|MA_API|MA_API_PRIVATE|DRWAV_API|DRMP3_API|DRFLAC_API|DRWAV_PRIVATE|DRMP3_PRIVATE|DRFLAC_PRIVATE|NK_API|NK_LIB|NK_PRIVATE|NK_INTERN|STBIDEF|STBIRDEF|STBTT_DEF|STBRP_DEF|STBIWDEF|STBSP__PUBLICDEC|STBSP__PUBLICDEF|SOKOL_API_DECL|SOKOL_API_IMPL|SOKOL_GFX_API_DECL|SOKOL_GL_API_DECL|MPACK_INLINE|MPACK_STATIC_INLINE|MPACK_INLINE_SPEED|MPACK_SPEED|MPACK_EXTERN_C_BEGIN|MPACK_SILENCE_WARNINGS_BEGIN|MTDEF|OLIVECDEF|UTF8_NULLABLE|UTF8_PURE|UTF8_CONST|utf8_constexpr14|UTF8_RESTRICT|YAML_DECLARE|SPNG_API|LZ4LIB_API|LZ4FLIB_API|ZSTDLIB_API|ZDICTLIB_API|WEBP_EXTERN|DECLSPEC|CALLBACK|__stdcall|__cdecl|SQLITE_VEC_API)\b',' ',value)
    value=re.sub(r'__attribute(?:__)?\s*\(\s*\([^)]*\)\s*\)',' ',value)
    value=re.sub(r'\b[A-Z][A-Z_0-9]*(?:_API|_EXPORT|_EXPORT_SYMBOL|_PUBLIC|_DECL|_EXTERN|_CALL)\b',' ',value)
    value=re.sub(r'\b(?:SDL_DECLSPEC|SDLMAIN_DECLSPEC|SDLCALL|APR_THREAD_FUNC|GB_DEF|GB_EXTERN|gb_inline|gb_no_inline|H5_DLL|H5_HLDLL|H5_DLLVAR|XMLPUBFUN|XMLPUBVAR|XMLCALL|EXTERNL|OPTEXPORT)\b',' ',value)
    return normalize(value)

def disabled_condition(value):
    return bool(re.fullmatch(r'if\s+\(?\s*0\s*\)?',clean_comments(value).strip()))

def classify(e,short,rel,declared_macros=()):
    name=e['name'];kind=e['classification'];notes=[];avail='declared_source_profile_not_link_checked'
    if kind in ('function_macro','template'):
        body=e.get('macro_replacement','')
        if kind=='template':
            role='generic_code_generator' if re.search(r'\b(?:typedef|static|inline|struct)\b',body) or ('##' in body and '{' in body) else 'name_or_type_generator'
        elif not body or re.search(r'__attribute|__declspec|\b_Pragma\b|__pragma',body):role='declaration_annotation'
        elif re.search(r'(?:ATTR|EXPORT|IMPORT|DEPRECAT|DECL|PRAGMA|INLINE|NOEXCEPT|ALIGN|VISIBILITY|RESTRICT|WARN_UNUSED|PRINTF_FORMAT|SCANF_FORMAT|NONNULL|NORETURN|FALLTHROUGH|BEGIN_EXTERN|END_EXTERN)',name):role='declaration_annotation'
        elif '##' in body or re.search(r'\b(?:typedef|struct|union|enum)\b',body) or re.search(r'(?:MANGLE|DECORATE|STRUCTAPI|CONCAT|STRINGIFY|PASTE|CAT[0-9]?)',name):role='name_or_type_generator'
        elif re.fullmatch(r'\(?\s*(?:extern|static|inline|const|volatile|restrict|__inline__|[A-Za-z_]\w*)\s*\)?',body) and not any(re.search(r'\b'+re.escape(p['name'])+r'\b',body) for p in e.get('parameters',[])):role='configuration_or_alias'
        elif re.search(r'(?:STATIC_ASSERT|COMPILE_ASSERT|BUILD_ASSERT)',name) or '_Static_assert' in body:role='compile_time_contract'
        elif re.search(r'\b(?:return|for|while|do|if)\b|[()+*/%&|^?:<>=\[\]]',body):role='runtime_operation'
        else:role='configuration_or_alias'
        e['macro_role']=role;e['unresolved']=role in ('runtime_operation','generic_code_generator')
        notes.append('Function-like macro has no independent C symbol; role: '+role+'.')
    elif kind=='callback':
        e['unresolved']=False;avail='callback_contract';notes.append('Callback type/slot, not an exported callable.')
    else:e['unresolved']=bool(re.search(r'\b[A-Z][A-Z_0-9]*\s*\(',e['return_type'] or ''))
    private=name.startswith(('_','stb__','stbi__','stbir__','stbtt__','ma__','mt__','glm__','gb__','lwc__')) or any(x in rel for x in ('/priv/','-private.h','_private.h','/sse2/','/simd/')) or any(x in (e.get('return_type') or '') for x in ('DRWAV_PRIVATE','DRMP3_PRIVATE','DRFLAC_PRIVATE','NK_LIB','NK_INTERN','NK_PRIVATE'))
    if private:avail='internal_header_surface';notes.append('Internal helper or private header surface; keep out of direct L3 publication.')
    if any(disabled_condition(x) for x in e.get('conditions',[])) or name in ('main','dummy','my_stbtt_initfont'):
        avail='disabled_example';notes.append('Disabled/example code region, not library API.')
    if kind in ('function','static_inline') and re.search(r'\b(?:STB_SPRINTF_DECORATE|H3_EXPORT|CGLM_STRUCTAPI|_c_MEMB|i_extern|CURL_EXTERN)\s*\(',e['signature']) and name in ('STB_SPRINTF_DECORATE','STBSP__ATTRIBUTE_FORMAT','H3_EXPORT','CGLM_STRUCTAPI','_c_MEMB'):
        e['classification']='template';e['unresolved']=True;avail='unexpanded_declarator_template';notes.append('Macro-built function name; concrete expansions are separate entries when available.')
    # C identifiers may legitimately be all capitals (XXH128, imath MP_USED,
    # quadrature G_K15). Casing alone is never evidence of a declaration macro.
    # Recognize a function-like macro definition or a malformed macro-built
    # declarator, while preserving ordinary typed uppercase C functions.
    cleaned_prefix=clean_return_type(e.get('return_type') or '')
    uppercase_macro=(name in declared_macros or not cleaned_prefix or '(' in cleaned_prefix or
                     any(re.match(r'^\d',p.get('declaration') or '') for p in e.get('parameters',[])))
    if kind in ('function','static_inline','static_header_function') and name.isupper() and uppercase_macro:
        e['classification']='template';e['unresolved']=True;avail='unexpanded_declarator_template';notes.append('Unexpanded declaration/type/annotation macro; not an independently callable symbol.')
    if short=='nanojpeg' and name not in ('njInit','njDecode','njGetWidth','njGetHeight','njIsColor','njGetImage','njGetImageSize','njDone'):
        avail='implementation_helper';notes.append('Only the eight nj* header-mode declarations form the NanoJPEG API.')
    if kind=='static_header_function' and e.get('body'):
        if short not in ('utf8','linmath','tinydir','minimp3','klib','stc','mdns','fp16','miniz','kann'):
            avail='implementation_helper';notes.append('Static function in implementation portion, not a linked export.')
    if short=='sokol' and Path(rel).name in ('sokol_app.h','sokol_glue.h','sokol_audio.h','sokol_fetch.h','sokol_time.h'):
        avail='header_only_not_in_selected_sokol_target';notes.append('Selected target builds renderer/util; this header requires a separate implementation/application integration.')
    if short in ('mint','utensil'):
        avail='application_implementation_required';notes.append('INTERFACE target: application must provide exactly one compatible C implementation.')
        if any(re.search(r'CUDA|METAL|OPENCL|APPLE|GPU',x) and not re.search(r'ifndef|!\s*defined',x) for x in e.get('conditions',[])):
            avail='outside_selected_tensor_profile';notes.append('GPU/platform branch is outside the selected CPU tensor profile.')
    if short=='mint' and any(x in name for x in ('model','layer','load_gguf')):
        avail='outside_selected_tensor_profile';notes.append('Selected CMake profile is tensor-only; model runtime is not supplied.')
    if short=='hiredis' and rel.endswith('hiredis_ssl.h'):
        avail='not_built_tls_profile';notes.append('Collection excludes hiredis OpenSSL adapter.')
    if short=='hiredis' and '/adapters/' in rel:
        avail='event_loop_header_adapter';notes.append('Requires external event loop headers/runtime; not supplied by hiredis target.')
    if short=='miniz' and name in ('adler32','crc32','compress','compress2','compressBound','deflate','deflateBound','deflateEnd','deflateInit','deflateInit2','deflateReset','inflate','inflateEnd','inflateInit','inflateInit2','inflateReset','uncompress','uncompress2','zError'):
        avail='outside_selected_profile';notes.append('Header-only zlib-compatible naming facade is disabled by MINIZ_NO_ZLIB_COMPATIBLE_NAMES in this collection; use its mz_* operation through a reviewed alias adapter, not a global same-named zlib symbol.')
    if short=='libevent' and rel.endswith('bufferevent_ssl.h'):
        avail='outside_selected_profile';notes.append('This collection selects libevent core/extra/pthreads without OpenSSL; the retained SSL buffer-event declarations do not have implementations in that profile.')
    if short=='mongo_c_driver' and '/utf8proc-' in rel:
        e['targets']=['LMX::mongoc'];notes.append('Reuse already bundled utf8proc; add its retained include directory to the typed shim, do not compile a second copy.')
    if short=='pcg-c' and (any('PCG_HAS_128BIT_OPS' in c or '__SIZEOF_INT128__' in c for c in e.get('conditions',[])) or 'pcg128_t' in e.get('signature','')):
        avail='outside_selected_portable_profile';notes.append('The retained upstream 128-bit-state API requires a compiler extension and is disabled in the generated portable C99 header; keep the source contract, do not assume this target links it.')
    if short=='softfloat':
        notes.append('Selected C99 build enables SOFTFLOAT_FAST_INT64 with INLINE_LEVEL=0; rounding/exception/tininess state is process-global (THREAD_LOCAL empty), requiring a serialized owner adapter.')
    if short=='pcre2':
        if re.search(r'_(?:16|32)$',name):
            avail='outside_selected_profile';notes.append('The delivered PCRE2 profile builds only the 8-bit library and POSIX facade. The header also declares 16/32-bit families; preserve their contracts without claiming those implementations are linked.')
        if 'jit_' in name:
            notes.append('JIT is disabled in this profile. Upstream may provide an error-returning JIT stub; presence of an exported name does not make JIT execution available.')
    if short=='lwip':
        disabled_headers={'api.h','netbuf.h','netdb.h','netifapi.h','sockets.h','tcpip.h','altcp.h','altcp_tcp.h','altcp_tls.h','stats.h','snmp.h'}
        if Path(rel).name in disabled_headers:
            avail='outside_selected_profile';notes.append('Selected lwIP NO_SYS=1 raw stack disables socket/netconn/threaded TCPIP/ALTCP/SNMP/statistics layers. Retained source declaration is a separate feature profile, not a callable promise for this build.')
        if name in ('sys_now','sys_jiffies'):
            avail='application_implementation_required';notes.append('Platform time hook supplied by the owner/port; no library-owned wall clock is invented.')
        notes.append('All raw-stack calls and timers have one serialized owner; shared immutable LMX definitions do not make lwIP globals thread-safe.')
    if short=='fatfs':
        if name in {'f_chdir','f_chdrive','f_getcwd','f_forward','f_gets','f_putc','f_puts','f_printf','f_setcp','get_fattime','ff_memalloc','ff_memfree','ff_mutex_create','ff_mutex_delete','ff_mutex_take','ff_mutex_give'}:
            avail='outside_selected_profile';notes.append('The selected FF_FS_RPATH=0, FF_USE_STRFUNC=0, FF_USE_FORWARD=0, fixed code page, stack LFN, non-RTOS and fixed-date profile omits this optional entry.')
        if name.startswith('disk_'):
            avail='application_implementation_required';notes.append('Block-device operation must be supplied by the application/board port; the FatFs library does not itself implement a device.')
    if short=='spiffs' and name=='SPIFFS_buffer_bytes_for_cache':
        avail='outside_selected_profile';notes.append('The selected strict-C99 SPIFFS profile disables its optional cache.')
    if short=='apr':
        if name.startswith('apr_skiplist_') or Path(rel).name=='apr_skiplist.h':
            avail='outside_selected_profile';notes.append('The retained APR skiplist source orders function pointers, which is outside ISO C99. This collection excludes that translation unit from its strict-C99 target; the header remains an explicit unavailable contract.')
        if name.startswith('apr_dso_') or Path(rel).name=='apr_dso.h':
            notes.append('APR DSO support is enabled in the selected native profile. Dynamic library loading remains an explicit owner-side capability; sharing package CODE does not grant arbitrary native code-loading authority.')
        if 'pool' in name or Path(rel).name in ('apr_pools.h','apr_allocator.h'):
            notes.append('APR pools own descendants and borrowed allocations. Pool clear/destroy invalidates dependent native views; a shared immutable LMX package definition does not make a mutable pool universally accessible.')
    if short=='apr_util':
        if Path(rel).name.startswith('apr_ldap') or Path(rel).name=='apr_crypto.h':
            avail='outside_selected_profile';notes.append('The selected APR-Util profile has no LDAP or external crypto driver. The retained abstract contract must not be exposed as a working backend without enabling and testing its dependency.')
        if Path(rel).name=='apr_dbd.h':
            notes.append('APR-Util DBD abstraction is retained but no external DBD driver is selected. An exported dispatcher is not proof that a requested database provider can be opened.')
    if short=='sdl3':
        header=Path(rel).name
        if header=='SDL_stdinc.h' and not name.startswith('SDL_') and kind in ('function','static_inline','static_header_function'):
            avail='internal_header_surface';notes.append('Host-runtime or static-analyzer declaration inside SDL stdinc, not a public function implemented by the SDL library. Use the corresponding SDL_* contract where present.')
        if header.startswith(('SDL_opengl','SDL_opengles')) or header=='SDL_egl.h':
            if kind in ('function','static_inline','static_header_function') and not name.startswith('SDL_'):
                avail='not_built_in_target_graphics_api';notes.append('This retained graphics interoperability header declares driver entry points, not definitions supplied by the SDL3 target. A typed context-bound GL/EGL procedure resolver or explicitly linked graphics provider is required; no direct native-call branch is emitted for this declaration.')
        if header.startswith('SDL_test'):
            avail='outside_selected_profile';notes.append('SDLTest declarations belong to the optional test support library, not the selected production SDL3-static target.')
        if header=='SDL_main_impl.h':
            avail='implementation_helper';notes.append('Application entry-point glue supplied by SDL headers; not a reusable production library entry.')
        if name in ('SDL_main','SDL_AppInit','SDL_AppIterate','SDL_AppEvent','SDL_AppQuit'):
            avail='application_implementation_required';notes.append('This entry is implemented by the application/actor host and invoked by SDL startup glue; it is not a function provided by the SDL3 static library.')
        if header in ('SDL_gpu.h','SDL_vulkan.h'):
            notes.append('The selected native build disables GPU/Vulkan backends. Public dispatch functions or error-returning stubs may still be exported; a symbol match does not establish that a requested device/backend can be created.')
        if header in ('SDL_video.h','SDL_events.h','SDL_render.h','SDL_dialog.h','SDL_tray.h'):
            notes.append('SDL video/event/UI thread and context requirements remain part of the per-API adapter contract; sharing immutable package CODE does not bypass them.')
    if short=='gb':
        if any(re.search(r'\bGB_PLATFORM\b',c) and not c.startswith('ifndef') for c in e.get('conditions',[])):
            avail='outside_selected_profile';notes.append('GB_PLATFORM window/input/OpenGL backend is disabled in the selected gb core target; retain the original header contract without claiming its implementation.')
        if name.startswith('gb_dll_'):
            notes.append('Dynamic loader access is an explicit native capability and platform-specific operation; the presence of a loader API does not grant arbitrary L3 code-loading authority.')
    if short=='cute_net' and (name=='cn_run_tests' or any('CUTE_NET_TESTS' in c for c in e.get('conditions',[]))):
        avail='outside_selected_profile';notes.append('CUTE_NET_TESTS belongs only to the dedicated upstream test executable, not the production library ABI.')
    if short=='cute_sound':
        if name in ('cs_load_ogg','cs_read_mem_ogg','cs_load_ogg_rw','cs_load_wav_rw'):
            avail='outside_selected_profile';notes.append('The selected scalar WAV + SDL3 mixer profile has no stb_vorbis OGG implementation and no SDL2 RWops adapter. The source declarations remain separate optional contracts.')
        notes.append('Cute sound uses a process-global current mixer context. Owner serialization and audio callback lifetime are required; sharing immutable package definitions does not create independent native mixer state.')
    if short=='ea_libc':
        if name in ('lmx_ea_rand','lmx_ea_srand','lmx_ea_strtok'):
            notes.append('This selected libc algorithm uses process-global mutable state. Use an explicitly serialized owner, or the rand_r/strtok_r stateful alternative when applicable.')
        if name in ('lmx_ea_strtoll','lmx_ea_strtoull'):
            notes.append('Curated implementation saturates on overflow without errno; an L3 exact conversion requires separate range/grammar validation and may not infer success only from the return value.')
    if short=='matio':
        notes.append('MAT format support follows the configured matio target, including its optional HDF5 dependency for MAT7.3. The source declaration alone does not prove that a requested file version or filter can be opened; dimension products, class types and native ownership require a typed adapter.')
    if short=='hdf5':
        notes.append('The selected HDF5 target includes core, high-level APIs and MPI support; each file/dataset/datatype/dataspace/property-list identifier has an exact kind and lifetime. Native HDF5 thread-safety is not enabled, so all HDF5 calls in a process require one serialized owner/executor or equivalent process-wide exclusion, not independent per-file locks.')
        if name.startswith('H5M'):
            notes.append('H5M map API is retained, but native VOL map capability is not implied. Query the selected connector capability and propagate unsupported-operation results.')
        if name.startswith(('H5FD','H5Pset_fapl_')):
            notes.append('Optional virtual-file drivers are selected by generated H5pubconf and dependency configuration. Header presence or a stub symbol does not establish driver availability.')
    if short=='pnetcdf':
        notes.append('Parallel-netCDF CDF-1/CDF-2/netCDF-5(CDF-5) calls require the same MPI ABI at build and runtime. Collective ordering, file mode, MPI_Offset/count width and outstanding request buffer lifetime need explicit owner-side admission.')
    if short=='netcdf' and Path(rel).name in ('ncjson.h','ncproplist.h'):
        if name in ('NCJdump','NCJtotext') or any(c.startswith('ifndef NETCDF_JSON_H') for c in e.get('conditions',[])):
            avail='outside_selected_header_facade';notes.append('This internal source-header branch is omitted from the installed NETCDF_JSON_H single-header facade. The retained contract is not a declaration available from canonical netcdf_json.h.')
        elif kind in ('function','static_inline','static_header_function'):
            e['classification']='static_header_function'
            notes.append('The installed public facade concatenates this declaration header with its retained libdispatch C implementation and selects OPTEXPORT static. Use a typed addressable shim including the generated netcdf_json.h/netcdf_proplist.h, not a guessed external symbol declaration.')
    if short=='pdfio' and name in ('pdfioFileGetCreationDate','pdfioDictGetDate'):
        notes.append('Known failing encrypted CreationDate regression is retained in extensions/pdf_extra/KNOWN_LIMITATIONS.md; ordinary/encrypted date behavior must not be conflated.')
    if short=='cminpack' and name=='__cminpack_func__':
        e['classification']='template';e['unresolved']=True;avail='unexpanded_declarator_template';notes.append('Type/name template; default double-profile named functions are recovered by preprocessing.')
    if short=='sqlite_vec':notes.append('Only extension initialization is C API; vector operations are SQL registrations.')
    if short=='stb' and rel.endswith('stb_leakcheck.h'):
        e['targets']=['LMX::stb_leakcheck'];avail='explicit_instrumentation_target';notes.append('Allocator instrumentation is opt-in; linking LMX::all does not activate it.')
    if short=='lzma_sdk' and re.search(r'(Enc|Encode|Compress|Mt|SHA|Sha|Aes)',name):
        avail='header_declaration_build_subset_review';notes.append('Target is extract-only Z7_EXTRACT_ONLY; this declaration may not have a linked implementation.')
    if short in ('stroud_rule','sparse_grid_hw','cquadpack') and rel.startswith('vendor/'):
        avail='upstream_symbol_renamed';notes.append('Use lmx_* names from collection include/ facade; upstream symbol is renamed by CMake.')
    if any('WIN32' in x or '_WIN32' in x or 'WINDOWS' in x for x in e.get('conditions',[])):
        notes.append('Contains a platform guard; verify selected platform branch before generating the shim.')
    if any(p.get('variadic') for p in e.get('parameters',[])):
        notes.append('Variadic API requires a fixed typed adapter; do not forward L3 values through C varargs.')
    if any(p.get('callback') for p in e.get('parameters',[])):
        notes.append('Callback parameter needs actor-owned trampoline/lifetime and exception translation.')
    if short=='jo_mp1':
        e['signature']=e['signature'].replace('short * & output','short ** output').replace('int & outputSize','int * outputSize').replace('int & hz','int * hz').replace('int & channels','int * channels')
        for p in e.get('parameters',[]):
            if '&' in (p.get('c_type') or ''):p['c_type']=p['c_type'].replace('&','*');p['declaration']=p['declaration'].replace('&','*');p['pointer']=True
        notes.append('C99 public signature follows extensions/media/cmake/generate_views.py reference-to-pointer rewrite.')
    if private:avail='internal_header_surface'
    if any(disabled_condition(x) for x in e.get('conditions',[])) or name in ('main','dummy','my_stbtt_initfont'):avail='disabled_example'
    e['availability']=avail;e['notes']=notes

def supplement_isolated_headers(r,out,entries,headers,diagnostics,component_macros):
    """Recover locally macro-generated declarations without needing a full build.

    This operation deliberately does not claim to reproduce configured ABI.
    Includes and diagnostic #error lines are masked; ordinary default C99
    conditionals remain. Fully dependent families get full GCC jobs below.
    """
    known={(e['component'],e['name'],e['classification']) for e in entries}
    temp=out/'preprocessed_inputs';temp.mkdir(exist_ok=True)
    def job(h):
        rel=h['path'][len(PREFIX):];original=(r/rel).read_text(errors='replace')
        if h['component'].split(':',1)[1] in ('stc','klib'):return None
        clean=clean_comments(original);parts=[];last=0
        for a,b,part in logical_preprocessor(clean):
            if re.match(r'\s*#\s*(?:include|error)\b',part):
                parts.extend([clean[last:a],''.join('\n' if c=='\n' else ' ' for c in part)]);last=b
        parts.append(clean[last:]);clean=''.join(parts)
        clean=re.sub(r'@[^@\n]+@','0',clean)
        source='#line 1 "'+str(r/rel)+'"\n'+clean
        p=subprocess.run(['gcc','-E','-x','c','-std=c99','-nostdinc','-D_XOPEN_SOURCE=700','-'],input=source,text=True,capture_output=True)
        return h, p
    added=collections.Counter();errors=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=8) as pool:
        for result in pool.map(job,headers):
            if result is None:continue
            h,p=result;cid=h['component'];rel=h['path'][len(PREFIX):]
            if p.returncode:errors.append({'component':cid,'header':h['path'],'return_code':p.returncode,'diagnostic':p.stderr[:500]})
            pieces=[];locations=[];current=None;line_number=0
            for line in p.stdout.splitlines(True):
                m=re.match(r'#\s+(\d+)\s+"([^"]+)"',line)
                if m:line_number=int(m[1]);current=m[2];pieces.append('\n');locations.append((None,0));continue
                pieces.append(line);locations.append((current,line_number));line_number+=1
            text=''.join(pieces)
            for d in declarations(text):
                at=text.count('\n',0,d.pop('offset'));src,lno=locations[min(at,len(locations)-1)] if locations else (None,0)
                if src!=str(r/rel):continue
                d.update(component=cid,source={'path':h['path'],'line':lno},conditions=['isolated header preprocessing; dependency includes masked'],targets=h['targets'],extraction='gcc_isolated_header_macro_expansion',canonical_header=canonical_header(rel),classification=d.pop('kind'))
                classify(d,cid.split(':',1)[1],rel,component_macros.get(cid,()))
                key=(cid,d['name'],d['classification'])
                if key in known:continue
                if d['name'].startswith(('__','_c_')):continue
                # Only macro expansions that are real ordinary named C
                # declarations; unresolved macro invocation stays in raw census.
                if d['classification'] not in ('function','static_inline','static_header_function','callback'):continue
                if re.search(r'\b[A-Z_]+\s*\(',d['name']):continue
                entries.append(d);known.add(key);added[cid]+=1
    diagnostics.append({'operation':'isolated_header_macro_expansion','mode':'includes and #error masked; not ABI validation','new_entries':sum(added.values()),'by_component':dict(added),'preprocessor_errors':errors})

def supplement_preprocessor(r,out,entries,diagnostics):
    jobs=[('acoustic:liquid_dsp','vendor/liquid_dsp/include/liquid.h',[]),('extras:cglm','vendor/cglm/include/cglm/struct.h',['-DCGLM_USE_ANONYMOUS_STRUCT=0']),('base:linmath','vendor/linmath/linmath.h',[]),('geospatial:h3','vendor/h3/src/h3lib/include/h3api.h.in',[])]
    allowed=set(SURFACES)
    for cid,rel,defines in jobs:
        if not (r/rel).exists():continue
        original=(r/rel).read_text();source=r/rel
        if rel.endswith('.in'):
            source=out/'preprocessed_inputs'/Path(rel).name[:-3];source.parent.mkdir(exist_ok=True)
            source.write_text(re.sub(r'@[^@\n]+@','0',original))
        cmd=['gcc','-E','-x','c','-std=c99','-D_XOPEN_SOURCE=700','-I'+str(r/'vendor/cglm/include')]+defines+[str(source)]
        p=subprocess.run(cmd,text=True,capture_output=True)
        diagnostics.append({'operation':'preprocess','component':cid,'header':PREFIX+rel,'return_code':p.returncode,'diagnostic':p.stderr[:2000]})
        # Turn line markers into an offset map while preserving newlines.
        pieces=[];loc=[];current=None;lineno=0
        for line in p.stdout.splitlines(True):
            m=re.match(r'#\s+(\d+)\s+"([^"]+)"',line)
            if m:lineno=int(m[1]);current=m[2];pieces.append('\n');loc.append((None,0));continue
            pieces.append(line);loc.append((current,lineno));lineno+=1
        text=''.join(pieces)
        for d in declarations(text):
            at=text.count('\n',0,d.pop('offset'));src,lno=loc[min(at,len(loc)-1)] if loc else (None,0)
            if not src:continue
            try:srel=Path(src).relative_to(r).as_posix()
            except ValueError:
                if Path(src)==source:srel=rel
                else:continue
            if cid=='extras:cglm' and not srel.startswith('vendor/cglm/include/cglm/'):continue
            if cid!='extras:cglm' and srel!=rel:continue
            # Preprocessing is supplementary: only add new public names. Existing
            # raw variants retain all inactive feature branches.
            if d['name'].startswith('__'):continue
            d.update(component=cid,source={'path':PREFIX+srel,'line':lno},conditions=['gcc default C99 profile for generated API expansion'],targets=['LMX::'+x for x in TARGETS.get(cid.split(':',1)[1],[cid.split(':',1)[1]])],extraction='gcc_preprocessed',canonical_header=canonical_header(srel),classification=d.pop('kind'))
            classify(d,cid.split(':',1)[1],srel);entries.append(d)

def add_sql_entries(r,entries):
    p=r/'vendor/sqlite_vec_amalgamation/sqlite-vec.c'
    if not p.exists():return
    text=p.read_text();registration_start=text.index('SQLITE_VEC_API int sqlite3_vec_init')
    # SQL names in registration table/string calls, preserving source origin.
    seen=set()
    for m in re.finditer(r'"(vec_[A-Za-z0-9_]+|vec0)"',text[registration_start:]):
        name=m.group(1)
        if name in seen:continue
        seen.add(name)
        entries.append({'component':'sqlite_vec:sqlite_vec','name':name,'classification':'sql_api','signature':name+' (SQL registration)','return_type':None,'parameters':[],'source':{'path':PREFIX+p.relative_to(r).as_posix(),'line':text.count('\n',0,registration_start+m.start())+1},'targets':['LMX::sqlite_vec'],'canonical_header':'sqlite-vec.h','extraction':'sql_registration_string_census','availability':'sql_surface_candidate','unresolved':True,'notes':['SQL registration: invoke through prepared SQLite statement; not a C symbol.']})

def add_source_exports(r,entries):
    p=r/'vendor/sqlite_vec_amalgamation/sqlite-vec.c';text=p.read_text();conds=conditions_by_line(text)
    for d in declarations(text):
        if not d['name'].startswith('sqlite3_vec_') or 'SQLITE_VEC_API' not in d['return_type']:continue
        line=text.count('\n',0,d.pop('offset'))+1
        d.update(component='sqlite_vec:sqlite_vec',classification=d.pop('kind'),source={'path':PREFIX+p.relative_to(r).as_posix(),'line':line},conditions=list(conds.get(line,())),targets=['LMX::sqlite_vec'],canonical_header='sqlite-vec.h',declaration_requirement='source_export_requires_explicit_prototype_in_typed_shim',extraction='export_annotated_C_definition')
        classify(d,'sqlite_vec',p.relative_to(r).as_posix());entries.append(d)

def make_coverage(r,components,entries,headers,diagnostics):
    counts=collections.Counter(e['classification'] for e in entries)
    availability=collections.Counter(e['availability'] for e in entries)
    cs=[]
    for c in components:
        es=[e for e in entries if e['component']==c['id']]
        cs.append({'component':c['id'],'headers':len(c['headers']),'entries':len(es),'classification_counts':dict(collections.Counter(e['classification'] for e in es)),'availability_counts':dict(collections.Counter(e['availability'] for e in es))})
    limitations=[
      'This inventory records public header declarations, selected generated APIs, macros/templates and callback contracts. It is not a link/export verification.',
      'Conditional raw declarations are retained as alternatives; incompatible platform/feature variants are not asserted to coexist.',
      'C declarator extraction uses a lexical balanced-delimiter scanner. Attributes and type-generating macros may leave unresolved C types; signatures and source locations are preserved for review.',
      'Generic template families have unbounded application instantiations; template entrypoints are inventoried once, not expanded into invented types.',
      'Third-party private/helper surface exposed by broad include directories is retained with a non-public disposition.',
      'Source-only callbacks and SQL registrations are separate from callable C API.',
      'Generated views and platform profiles must be used for actual ABI compilation; this census does not copy or modify vendor sources.',
    ]
    return {'schema_version':1,'summary':{'components':len(components),'headers':len(headers),'entries':len(entries),'publish_candidate_count':sum(e['pub_candidate'] for e in entries),'ordinary_source_profile_callable_count':sum(e['pub_candidate'] and e['availability']=='declared_source_profile_not_link_checked' for e in entries),'classification_counts':dict(counts),'availability_counts':dict(availability),'macro_role_counts':dict(collections.Counter(e.get('macro_role') for e in entries if 'macro_role' in e)),'ffi_disposition_counts':dict(collections.Counter(e['ffi_disposition'] for e in entries)),'components_without_entries':[c['component'] for c in cs if not c['entries']]},'components':cs,'diagnostics':diagnostics,'limitations':limitations}

def audit_build_inputs(r):
    b=r/'vendor/mongo_c_driver';result=[]
    builtin=set('FeatureSummary CheckCCompilerFlag CheckLanguage InstallRequiredSystemLibraries CMakeDependentOption GNUInstallDirs CTest CPack CheckFunctionExists CheckIncludeFile CheckIncludeFiles CheckStructHasMember CheckSymbolExists CheckTypeSize CMakePushCheckState FindZLIB FindOpenSSL TestBigEndian CMakePackageConfigHelpers CheckCSourceCompiles'.split())
    missing={}
    for p in [*b.rglob('CMakeLists.txt'),r/'extensions/databases/cmake/MongoC.cmake']:
        raw=p.read_text()
        for m in re.finditer(r'include\s*\(\s*([A-Za-z][A-Za-z0-9_-]*)\s*\)',raw,re.I):
            name=m.group(1)
            if name not in builtin:
                rel='build/cmake/'+name+'.cmake'
                if not (b/rel).exists():missing.setdefault(rel,[]).append({'path':PREFIX+p.relative_to(r).as_posix(),'line':raw.count('\n',0,m.start())+1})
        for m in re.finditer(r'(build/cmake/[A-Za-z0-9_.-]+)',raw):
            rel=m.group(1)
            if not (b/rel).exists():missing.setdefault(rel,[]).append({'path':PREFIX+p.relative_to(r).as_posix(),'line':raw.count('\n',0,m.start())+1})
    if missing:
        result.append({'operation':'build_input_audit','component':'databases:mongo_c_driver','severity':'configuration_blocker','finding':'Retained CMake paths refer to missing vendor/mongo_c_driver/build/cmake inputs; MongoC.cmake reads ResSearch.cmake unconditionally. No source build success is claimed.','missing_references':[{'path':PREFIX+'vendor/mongo_c_driver/'+k,'references':v} for k,v in sorted(missing.items())]})
    return result

def write_report(out,c):
    lines=['# C API source coverage','', 'Generated from the pinned compact collection by `extract_inventory.py`.','', 'The inventory records declarations and adapters to be implemented. Counts do not prove link availability.','', '## Summary','', '```json',json.dumps(c['summary'],ensure_ascii=False,indent=2),'```','', '## Components','', '| Component | Headers | Entries | Kinds |','|---|---:|---:|---|']
    for row in c['components']:lines.append('| '+row['component']+' | '+str(row['headers'])+' | '+str(row['entries'])+' | '+', '.join(f'{k}: {v}' for k,v in row['classification_counts'].items())+' |')
    lines+=['','## Limits','']+['- '+x for x in c['limitations']]
    (out/'coverage.md').write_text('\n'.join(lines)+'\n')

if __name__=='__main__':main()

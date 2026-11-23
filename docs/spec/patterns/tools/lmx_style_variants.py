#!/usr/bin/env python3
"""Shared full-source contract for procedural/functional LMX comparison clients.

No selection by size and no supplementary Throws normalization happens here.
Implementation comparisons retain one canonical body instead of style copies.
"""
from pathlib import Path
import hashlib
import re

STYLES = ('procedural', 'functional')
LEGACY_ROLE = 'compatibility_mirror_not_separate_comparison'
PROCEDURAL_FORBIDDEN = frozenset({'map','filter','fold','foldl','foldr','scanl','scanr','reduce','unique','pipe','bind'})


def normalize(code):
    return code.replace('\r\n','\n').replace('\r','\n').strip()+'\n'


def measure(code):
    code=normalize(code)
    return {'characters':sum(not char.isspace() for char in code),
            'characters_with_whitespace':len(code),
            'nonblank_lines':sum(bool(line.strip()) for line in code.splitlines()),
            'utf8_bytes':len(code.encode('utf-8')),
            'sha256':hashlib.sha256(code.encode('utf-8')).hexdigest()}


# Alias retained for generators that use a conventional metric function name.
metrics = measure


def make_variant(code, source_file, contract_id, **extra):
    code=normalize(code)
    return {'code':code, 'source_file':str(source_file), 'contract_id':str(contract_id),
            'runtime_execution':'NOT_RUN', 'metrics':measure(code), **extra}


def get_variants(record):
    variants=record.get('lmx_variants',{})
    return [(style,variants[style]) for style in STYLES if style in variants]


def attach_variants(record, *, procedural, functional, procedural_source, functional_source,
                    contract_id, style_relation='distinct', style_note=''):
    if style_relation=='same_minimal_form':
        procedural_source=functional_source
    record['lmx_variants']={
        'procedural':make_variant(procedural,procedural_source,contract_id),
        'functional':make_variant(functional,functional_source,contract_id),
    }
    record['lmx_comparison_variants']=list(STYLES)
    record['lmx_legacy_role']=LEGACY_ROLE
    record['style_relation']=style_relation
    record['style_note']=style_note
    return record


def write_sources(record, directory):
    directory=Path(directory)
    written={}
    for _,variant in get_variants(record):
        path=directory/variant['source_file'];code=normalize(variant['code'])
        if path in written:
            if written[path]!=code:raise ValueError('Different style bodies cannot share a source path')
            continue
        written[path]=code
        path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text(code)


def type_declaration_issues(code):
    """Typed reference declarations are Model@: p / int@: left / FxMaybe@: input.

    A generic @: target expression is valid and must not be rewritten as a type.
    """
    issues=[]
    primitives='(?:bool|byte|char|short|int|long|float|double|word|uint|uint8|uint16|uint32|uint64|int8|int16|int32|int64)'
    for number,line in enumerate(code.splitlines(),1):
        line=line.split('#',1)[0]
        if re.search(r'(?<![A-Za-z0-9_])@[A-Za-z_][A-Za-z0-9_]*\s*:',line):
            issues.append(f'line {number}: prefix @Type declaration; use Type@: name')
        if re.search(r'\[\][A-Za-z_][A-Za-z0-9_]*\s*:',line):
            issues.append(f'line {number}: prefix []Type declaration; use Type[]: name')
        if re.search(r'@:\s*'+primitives+r'\s+[A-Za-z_][A-Za-z0-9_]*\s*$',line):
            issues.append(f'line {number}: old @: Type name declaration; use Type@: name')
        if re.search(r'@:\s*[A-Za-z_][A-Za-z0-9_]*\s+'+primitives+r'\s*$',line):
            issues.append(f'line {number}: old @: name Type declaration; use Type@: name')
    return issues


def validate_variants(record, directory=None, *, procedural_restrictions=True):
    errors=[]
    variants=record.get('lmx_variants',{})
    if set(variants)!=set(STYLES):
        return ['exactly procedural and functional variants are required']
    if record.get('lmx_comparison_variants')!=list(STYLES):errors.append('comparison order must include both styles')
    if record.get('lmx_legacy_role')!=LEGACY_ROLE:errors.append('legacy mirror must not count as a third comparison')
    if len({v.get('contract_id') for v in variants.values()})!=1 or not variants['functional'].get('contract_id'):
        errors.append('both styles require the same nonempty observable contract ID')
    source_count=len({v.get('source_file') for v in variants.values()})
    if record.get('style_relation')=='distinct' and source_count!=2:errors.append('distinct styles require separate complete source files')
    if record.get('style_relation')=='same_minimal_form' and source_count!=1:errors.append('identical minimal forms share one canonical source')
    for style,variant in get_variants(record):
        code=variant.get('code','')
        if not code.strip():errors.append(style+': empty source')
        errors.extend(style+': '+issue for issue in type_declaration_issues(code))
        if variant.get('metrics')!=measure(code):errors.append(style+': full-source metrics are stale')
        if variant.get('runtime_execution')!='NOT_RUN':errors.append(style+': this publication has no new LMX execution receipt')
        if directory is not None:
            path=Path(directory)/variant.get('source_file','')
            if not path.is_file() or path.read_text()!=normalize(code):errors.append(style+': source/JSON mirror differs')
    relation=record.get('style_relation')
    same=normalize(variants['procedural']['code'])==normalize(variants['functional']['code'])
    if relation not in {'distinct','same_minimal_form'}:errors.append('unknown style relation')
    if same and (relation!='same_minimal_form' or not record.get('style_note','').strip()):
        errors.append('identical minimal forms require a contract explanation')
    if not same and relation=='same_minimal_form':errors.append('same_minimal_form sources differ')
    if procedural_restrictions:
        code='\n'.join(line.split('#',1)[0] for line in variants['procedural']['code'].splitlines())
        for operation in sorted(PROCEDURAL_FORBIDDEN):
            if re.search(r'(?<![A-Za-z0-9_])'+operation+r'(?=\s*\(|\s+[^:=\n]|\\)',code):
                errors.append('procedural: functional traversal '+operation)
        arrays=re.findall(r'^\s*(?:[A-Za-z_@][A-Za-z0-9_@]*)?\[\]:\s+([A-Za-z_][A-Za-z0-9_]*)',code,re.M)
        for name in arrays:
            if re.search(r'\b'+re.escape(name)+r'\s*[+*/%]',code):
                errors.append('procedural: element-wise Array arithmetic on '+name)
    return errors


def markdown_variants(record):
    if record.get('style_relation')=='same_minimal_form':
        variant=record['lmx_variants']['functional']
        return '\n'.join(['## LMX — общая минимальная форма обоих стилей','',record.get('style_note',''),'',
            '```lmx',normalize(variant['code']).rstrip(),'```','',
            f"[Общий полный исходник]({variant['source_file']}). Оба стилевых столбца учитывают этот текст целиком: {variant['metrics']['characters']} непробельных символов; {variant['metrics']['nonblank_lines']} непустых строк.",''])
    chunks=[]
    for style,variant in get_variants(record):
        label='процедурный' if style=='procedural' else 'функциональный'
        chunks += [f'## LMX — {label}', '', '```lmx', normalize(variant['code']).rstrip(), '```', '',
                   f"[Полный исходник]({variant['source_file']}). {variant['metrics']['characters']} непробельных символов; "
                   f"{variant['metrics']['nonblank_lines']} непустых строк. Все объявления и Throws включены.", '']
    return '\n'.join(chunks)

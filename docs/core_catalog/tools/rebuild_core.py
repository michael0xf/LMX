#!/usr/bin/env python3
"""Import the existing normative core catalogue as ordinary LMX DATA.

No vendor/core source is changed. Generated inventory.lmx is the inspectable
catalogue; JSON and Markdown are projections, not an LMX runtime dependency.
The source catalogue is not treated as proof of a running implementation.
"""
from __future__ import annotations
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
import sys

TOOLS_DIR = str(Path(__file__).resolve().parents[2] / 'tools')
if TOOLS_DIR not in sys.path:
    sys.path.insert(0, TOOLS_DIR)
from normalize_lmx_closers import normalize_text

LIB = Path('docs/spec/patterns/LMX_Fn_Receivers')


def quote(value):
    return json.dumps(str(value), ensure_ascii=False)


def ident(value):
    return value if re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', value) else '`' + value + '`'


def package_for(row, variant):
    name, family, source = row['name'], variant['family'], variant['source']
    if name == 'bind':
        return {'Maybe': 'maybe', 'Result': 'result', 'Array': 'seq'}[family]
    if family == 'text':
        return 'text'
    if name in {'some', 'none', 'mapOption', 'filterOption', 'orElse', 'orElseGet', 'orElseOption', 'foldOption', 'flattenOption'}:
        return 'maybe'
    if name in {'ok', 'err', 'mapResult', 'mapErr', 'orElseResult', 'foldResult', 'attempt'}:
        return 'result'
    if name == 'retryPost':
        return 'message'
    if name in {'allOf', 'between'}:
        return 'call'
    if name == 'equalFields' or name == 'type':
        return 'graph'
    if name in {'arrayView', 'element'} or '/regex/' in source:
        return 'pattern'
    if source.endswith(('reflection.lmx', 'reflection_bridges.lmx', 'structures.lmx', 'coreStandardLisp.lmx')):
        return 'graph'
    if source.endswith('coreStandardNumeric.lmx'):
        return 'math'
    if source.endswith('coreStandardText.lmx'):
        return 'text'
    if source.endswith(('generic_combinators.lmx', 'generic_functions.lmx', 'generic_runtime.lmx', 'generic_wrappers.lmx', 'fn_operand.lmx', 'coreGenericOperations.lmx')):
        return 'call'
    if name in {'done', 'more', 'trampoline', 'iterateUntilStop', 'asOperand', 'tap'}:
        return 'call'
    return 'seq'


def source_line(project, rel, target):
    lines = (project / rel).read_text().splitlines()
    owner, method = target.split('\\', 1)
    start = next((i for i, line in enumerate(lines) if re.match(r'^(?:independent:\s*)?' + re.escape(owner) + r'\s*:(?!:)', line)), None)
    if start is None:
        raise ValueError(f'No owner {owner}: {rel}')
    want = method.strip('`')
    for i in range(start + 1, len(lines)):
        line = lines[i]
        if line and not line.startswith((' ', '\t', '#')):
            break
        if re.match(r'^\s+(?:' + re.escape(want) + '|' + re.escape('`' + want + '`') + r')\s*:(?!:)', line):
            return i + 1
    raise ValueError(f'No method {target}: {rel}:{start + 1}')


def emit_records(path, owner, rows, field_order=None):
    out = ['# Catalogue DATA, not automatically executed.',
           '# Current documentation takes precedence over historical selfbuild.',
           owner + ':']
    for number, row in enumerate(rows, 1):
        out.append(f'    entry{number:04d}:')
        for key in field_order or row:
            value = row[key]
            if isinstance(value, list):
                # Ordinary child Structures contain their string atoms directly.
                # No JSON text is embedded as a substitute for LMX collection DATA.
                out.append(f'        {key}:')
                for item in value:
                    if not isinstance(item,str):
                        raise ValueError(f'Non-string field in the declared catalogue subset: {key}')
                    out.append('            '+quote(item))
            elif isinstance(value, bool):
                out.append(f'        int: {key} {int(value)}')
            elif isinstance(value, int):
                out.append(f'        int: {key} {value}')
            else:
                if not isinstance(value, str):
                    value = json.dumps(value, ensure_ascii=False, separators=(',', ':'))
                out.append(f'        []char: {key} {quote(value)}')
        out.append('    ---')
    path.write_text(normalize_text('\n'.join(out) + '\n')[0])


def project_records(path):
    """Read only this catalogue's explicit primitive-record subset; not an LMX parser."""
    rows, current, list_field = [], None, None
    for line in path.read_text().splitlines():
        if re.fullmatch(r'    entry\d+:', line):
            current = {}
            rows.append(current)
            list_field=None
        elif match := re.fullmatch(r'        (\w+):',line):
            list_field=match[1]
            current[list_field]=[]
        elif re.fullmatch(r'            ".*"',line):
            if list_field is None:
                raise ValueError('Unowned list field in '+str(path))
            current[list_field].append(json.loads(line.strip()))
        elif match := re.fullmatch(r'        (\[\]char|char\[\]|int): (\w+) (.*)', line):
            kind, key, value = match.groups()
            current[key] = json.loads(value) if kind != 'int' else int(value)
            list_field=None
    return rows


def bridge_rows(project):
    file = LIB / 'src/kernel_contracts.lmx'
    text = (project / file).read_text().splitlines()
    names = {
        'Signature': 'signature', 'NormalizeType': 'normalizeType', 'SignatureData': 'signatureData',
        'Callable': 'callable', 'Attempt': 'attempt', 'Raise': 'raise', 'FieldNames': 'fieldNames',
        'RenameFields': 'renameFields', 'AcceptsRequirement': 'acceptsRequirement',
        'CurrentCall': 'currentCall', 'FrameSlot': 'frameSlot', 'Prepare': 'prepare',
        'Enter': 'enter', 'ReleaseCall': 'releaseCall', 'ArrayInfo': 'arrayInfo',
        'ArrayRead': 'arrayRead', 'ArrayAdmit': 'arrayAdmit', 'ArrayWrite': 'arrayWrite'
    }
    rows = []
    for i, line in enumerate(text, 1):
        if match := re.match(r'^FxKernel(\w+)API\s*::\s*(.*)$', line):
            suffix, signature = match.groups()
            rows.append(dict(name=names[suffix], package='internal\\kernel', target='FxKernel\\'+names[suffix],
                             signature=signature, source=str(file), sourceLine=i,
                             status='REQUIRED_KERNEL_INTERFACE_NOT_IMPLEMENTED', cSymbol='', executed=False))
    rows.append(dict(name='attemptAccepted', package='internal\\kernel', target='FxKernel\\attemptAccepted',
                     signature='attemptAccepted(form) -> FxOutcome; current receiving activation; gate AE01',
                     source=str(LIB/'CORE_EXAMPLE_HELPERS.md'), sourceLine=1,
                     status='REQUIRED_KERNEL_INTERFACE_NOT_IMPLEMENTED', cSymbol='', executed=False))
    if len(rows) != 19:
        raise ValueError(f'Expected 19 bridge records, found {len(rows)}')
    return rows


def system_rows(project):
    rel = Path('docs/spec/LMX_semantics.en.md')
    lines = (project/rel).read_text().splitlines()
    text = '\n'.join(lines[145:154])
    names = list(dict.fromkeys(re.findall(r'sys\\([A-Za-z][A-Za-z0-9]*)', text)))
    rows = []
    signatures = {
        'check': 'check(S)', 'checkL3': 'checkL3(S)', 'translate': 'translate(S)',
        'compile': 'compile(S)', 'endturn': 'endturn()', 'native': 'native(S=current DATA)',
        'storage': 'storage(S=current DATA)', 'descriptor': 'descriptor(S=current DATA)',
        'capacity': 'capacity(S=current DATA)', 'resize': 'resize(S; length)',
        'reserve': 'reserve(S; capacity)', 'typeof': 'typeof(value)', 'toLmx': 'toLmx(S)',
        'fromLmx': 'fromLmx(text)', 'assert': 'assert(condition)',
        'indexof': 'indexof(field; parent) / indexof(field; occurrence; parent)',
        'name': 'name(NAME)', 'priority': 'priority(nameText)', 'eval': 'eval(rawOccurrence)'
    }
    for name in names:
        first = next(i for i,line in enumerate(lines, 1) if 'sys\\'+name in line)
        rows.append(dict(name=name, package='sys', target='sys\\'+name,
                         signature=signatures.get(name,'see governing source'), source=str(rel), sourceLine=first,
                         status='NORMATIVE_SYSTEM_CONTRACT; IMPLEMENTATION_NOT_VERIFIED', cSymbol='', executed=False))
    for name, sig, anchor, package in [
        ('parent','parent(S=current DATA)', '### Receivers parent,', 'graph'),
        ('length','length(S=current DATA)', '### Receivers parent,', 'graph'),
        ('copy','copy(source)', '## 20. Composition', 'graph'),
        ('merge','merge(first; second; ...)', '## 20. Composition', 'graph'),
        ('import','import(source; ...)', '### `import`:', 'graph'),
        ('call','call(code) / call(args; code)', '## 11. Callable', 'call'),
        ('satisfies','satisfies(candidate; requirement; consumer?)', '## 7. Used interface', 'graph'),
        ('post','post(exchangeDescription)', '## 28. Ordinary', 'message'),
        ('send','send(public transport form)', '## 28. Ordinary', 'message'),
        ('receive','receive(public transport form)', '## 28. Ordinary', 'message'),
        ('synchronized','synchronized(protected expression)', '## 1. Language scope', 'message'),
    ]:
        first = next(i for i,line in enumerate(lines, 1) if line.startswith(anchor))
        src = str(rel)
        if name == 'synchronized':
            src='docs/spec/L2_spec_en.md'
            first=next(i for i,line in enumerate((project/src).read_text().splitlines(),1) if line.startswith('## 22. synchronized'))
        rows.append(dict(name=name,package=package,target=name,signature=sig,source=src,sourceLine=first,
                         status='EXISTING_LANGUAGE_RECEIVER; RETAIN_CURRENT_ROLE', cSymbol='', executed=False))
    return rows


def runtime_rows(project):
    rows=[]
    for p in sorted((project/'selfbuild').rglob('*.lm2')):
        if '/tests/' in str(p):
            continue
        for i, line in enumerate(p.read_text(errors='replace').splitlines(),1):
            if m := re.match(r'^\s*(fn|sub|fm):\s+(`[^`]+`|\S+)(.*)$',line):
                kind,name,tail=m.groups()
                rows.append(dict(name=name.strip('`'), source=str(p.relative_to(project)),sourceLine=i,
                                 historicalKind=kind, signature=tail.strip(),
                                 status='HISTORICAL_SELFBUILD_SOURCE_ONLY; NOT_CURRENT_L3_API', executed=False))
    return rows


def language_form_rows(project):
    rel=Path('docs/spec/OPERATION_FORMS.md')
    rows=[]; active=False
    for i,line in enumerate((project/rel).read_text().splitlines(),1):
        if line.startswith('## 5. '):
            active=True
        elif active and line.startswith('## '):
            break
        if active and line.startswith('| ') and not line.startswith(('| ---','| Семейство')):
            cells=re.split(r'(?<!\\)\|',line)[1:-1]
            if len(cells)!=2:
                raise ValueError(f'Unexpected role matrix row {rel}:{i}')
            rows.append(dict(forms=cells[0].strip(),contract=cells[1].strip(),source=str(rel),sourceLine=i,
                             status='NORMATIVE_ROLE_MATRIX; NOT_A_FUNCTION_COUNT'))
    return rows


def profile_role_rows(project):
    rel=Path('docs/spec/LMX_semantics.en.md');lines=(project/rel).read_text().splitlines()
    rows=[];active=False
    for i,line in enumerate(lines,1):
        if line.startswith('## 35. '): active=True
        elif active and line.startswith('## '): break
        if active and line.startswith('| ') and not line.startswith(('| ---','| Family')):
            cells=[x.strip() for x in re.split(r'(?<!\\)\|',line)[1:-1]]
            rows.append(dict(role=cells[0],package='crypto',signature=cells[1],contract=cells[2],
                             source=str(rel),sourceLine=i,status='SEMANTIC_PROFILE_ROLE; CONCRETE_BINDING_REQUIRED',executed=False))
    for name,package,anchor,contract in [
        ('matmul','tensor','## 18. Array operations','Matrix/vector product profile of * at depth 0; logical-axis depth 1 gives row-dot for rank 2, depth 2 gives scalar componentwise multiplication'),
        ('dot','tensor','## 18. Array operations','Dot product; explicit selected numeric profile'),
        ('contract','tensor','## 18. Array operations','Tensor contraction; distinct from call/contract'),
        ('outer','tensor','## 18. Array operations','Outer product; explicit selected numeric profile'),
        ('reduce','math','## 18. Array operations','Explicit numeric reduction contract; no invented left/right association'),
        ('scan','math','## 18. Array operations','Inclusive/exclusive numeric profile; distinct from seeded scanl'),
        ('sqrt','math','## 19. Numeric operations','Selected numeric provider, domain/precision/rounding contract'),
        ('sin','math','## 19. Numeric operations','Selected numeric provider, precision/rounding contract'),
        ('cos','math','## 19. Numeric operations','Selected numeric provider, precision/rounding contract'),
        ('pow','math','## 19. Numeric operations','Selected numeric provider, domain/precision/rounding contract'),
        ('abs','math','## 19. Numeric operations','Selected scalar type; minimum signed integer case explicit'),
        ('rounding','number','## 19. Numeric operations','Profile family, not a mandated exact callable spelling'),
        ('bigint','number','## 19. Numeric operations','One semantic extended integer family; provider implementation separate'),
        ('real','number','## 19. Numeric operations','One semantic extended real family; explicit precision/rounding context'),
        ('decimal','number','## 19. Numeric operations','One semantic decimal family; exponent/quantization context'),
        ('insert','sys\\debug','### Insert new source','Owner-side insertion of exact source with explicit target/context; not seq/insert'),
        ('interpreter.next','sys\\debug','### Interpreter control','One specific real continuation; no hidden switch from native to interpreter'),
        ('table/query/provider','graph','## 21. Tables, queries','Ordinary data/selected profiles; no additional implicit lookup namespace')
    ]:
        i=next(i for i,line in enumerate(lines,1) if line.startswith(anchor))
        rows.append(dict(role=name,package=package,signature='see selected profile',contract=contract,
                         source=str(rel),sourceLine=i,status='SEMANTIC_PROFILE_ROLE; CONCRETE_BINDING_REQUIRED',executed=False))
    return rows


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project',type=Path,required=True)
    parser.add_argument('--output',type=Path,default=Path(__file__).resolve().parents[1]/'core')
    args=parser.parse_args()
    project=args.project.resolve(); out=args.output.resolve(); out.mkdir(parents=True,exist_ok=True)
    original=json.loads((project/LIB/'catalog.json').read_text())
    records=[]; families=defaultdict(lambda:defaultdict(list)); packages=defaultdict(set)
    for row in original:
        for variant in row['variants']:
            package=package_for(row,variant); source=LIB/variant['source']; contract=variant.get('implementation_contract',{})
            record=dict(name=row['name'],family=variant['family'],package=package,path=package+'\\'+row['name'],
                        signature=row['signature'],target=variant['api'],operandTarget=variant['operand']['target'],
                        source=str(source),sourceLine=source_line(project,source,variant['api']),
                        sourceSha256=hashlib.sha256((project/source).read_bytes()).hexdigest(),
                        sourceStatus=row['status'],status='PRESERVE_EXISTING_LMX_ALGORITHM; RUNTIME_NOT_RUN',
                        declaredInputs=contract.get('declared_inputs',[]),result=contract.get('result_declaration',''),
                        requiredInputs=contract.get('required',[]),declarationCopies=contract.get('declaration_copies',[]),
                        sourceDeclaration=contract.get('source_declaration',''),
                        declaredThrows=contract.get('declared_throws',[]),argumentRoles=variant.get('roles',[]),
                        callRoute=variant['call']['route'],operandRoute=variant['operand']['route'],
                        resultContract=variant.get('result',''),failureContract=variant.get('throws',''),
                        publicationStatus=variant.get('publication_status',''),scope=row['scope'],
                        cSymbol='',executed=False)
            records.append(record); families[package][row['name']].append(record);packages[package].add(row['name'])
    emit_records(out/'inventory.lmx','CoreInventory',records)
    projection=project_records(out/'inventory.lmx')
    (out/'inventory.json').write_text(json.dumps(projection,ensure_ascii=False,indent=2)+'\n')
    publication=['# Source references preserve their actual parent DATA.', '# This is the family-publication input, not an already integrated dispatcher.', '# Load source closure first; role and family selection follow PUBLICATION_CONTRACT.', 'CoreFamilies:']
    for package, operations in sorted(families.items()):
        publication.append('    '+ident(package)+':')
        for name, variants in sorted(operations.items()):
            publication.append('        '+ident(name)+':')
            for variant in variants:
                publication.append('            '+ident(variant['family'])+':')
                publication.append('                @: call '+variant['target'])
                publication.append('                @: operand '+variant['operandTarget'])
                publication.append('            ---')
            publication.append('        ---')
        publication.append('    ---')
    (out/'publication.lmx').write_text(normalize_text('\n'.join(publication)+'\n')[0])
    values=json.loads((project/LIB/'value_symbols.json').read_text())
    value_records=[]
    for row in values:
        value_records.append(dict(name=row['name'],target=row['target'],role=row['role'],source=str(LIB/row['source']),
                                  package='pattern',bareNameCalls=False))
    emit_records(out/'values.lmx','CoreValues',value_records)
    emit_records(out/'kernel_bridges.lmx','KernelBridges',bridge_rows(project))
    systems=system_rows(project);emit_records(out/'system_receivers.lmx','SystemReceivers',systems)
    forms=language_form_rows(project);emit_records(out/'language_forms.lmx','LanguageFormRoles',forms)
    profiles=profile_role_rows(project);emit_records(out/'profile_roles.lmx','PlannedProfileRoles',profiles)
    runtime=runtime_rows(project);emit_records(out/'selfbuild_index.lmx','HistoricalSelfbuildFunctions',runtime)
    stats={'canonical_names':len(original),'semantic_variants':len(records),'noncallable_symbols':len(values),
           'internal_kernel_interfaces':19,'system_and_language_receiver_entries':len(systems),
           'historical_selfbuild_declarations':len(runtime),
           'language_form_families':len(forms),'planned_profile_role_groups':len(profiles),
           'packages':{k:len(v) for k,v in sorted(packages.items())},
           'runtime_executed':False,'source_catalog_sha256':hashlib.sha256((project/LIB/'catalog.json').read_bytes()).hexdigest()}
    (out/'summary.json').write_text(json.dumps(stats,ensure_ascii=False,indent=2)+'\n')
    md=['# Каталог функций ядра', '',
        'Исходная опись — [inventory.lmx](inventory.lmx); [JSON-проекция](inventory.json) удобна для инструментария и не вводит JSON в runtime языка.', '',
        f'В исходном каноническом каталоге **{len(original)} имён и {len(records)} семантических вариантов**. Предложенная группировка сохраняет все тела, роли аргументов, сигнатуры и declared failures. Самосборщик не использовался как замена действующей спецификации.', '',
        '| Пакет | Канонических имён в пакете |', '|---|---:|']
    md.extend(f'| `{k}` | {len(v)} |' for k,v in sorted(packages.items()))
    md.extend(['', 'Сумма по пакетам может превышать 215: варианты одного имени (`bind`, `join`, `cycle`) имеют разные семантические семейства. Это не дублирование реализации.', '',
       '[publication.lmx](publication.lmx) содержит ссылки на исходные CODE-occurrences и operand-формы. Он требует штатной публикации семейств из [PUBLICATION_CONTRACT](../../spec/patterns/LMX_Fn_Receivers/PUBLICATION_CONTRACT.md), не вызывает тела и не меняет их `parent`.', '',
       'Отдельные реестры:', '',
       '- [values.lmx](values.lmx): 24 значения, требования и именованных исхода; они не прибавляются к количеству функций.',
       '- [kernel_bridges.lmx](kernel_bridges.lmx): 19 требуемых внутренних интерфейсов ядра; объявления не считаются реализованными C-функциями.',
       '- [system_receivers.lmx](system_receivers.lmx): системные и базовые языковые receiver-контракты, сохраняющие текущие роли.',
       '- [language_forms.lmx](language_forms.lmx): полная матрица классов ресиверов/операндов из OPERATION_FORMS; управляющие формы и объявления не превращены в обычные VALUE-callables.',
       '- [profile_roles.lmx](profile_roles.lmx): математические, тензорные, криптографические и отладочные контракты спецификации вне каталога 215 имён; семантическая роль отделена от будущего точного имени и ABI.',
       '- [selfbuild_index.lmx](selfbuild_index.lmx): все найденные `fn/sub/fm`-объявления в исходниках и инструментах старого selfbuild, без тестовых файлов. Это индекс исторической реализации, не дополнительный публичный L3 API.', '',
       '## Карта операций', '', '| Путь | Семейство | Сигнатура | Исходное тело |', '|---|---|---|---|'])
    for row in records:
        # core/ -> core_catalog/ -> docs/; project-root source is ../../.. .
        path='../../../'+row['source']
        md.append(f"| `{row['path']}` | `{row['family']}` | `{row['signature'].replace('|','&#124;')}` | [{row['target']}]({path}), строка {row['sourceLine']} |")
    (out/'README.ru.md').write_text('\n'.join(md)+'\n')
    print(json.dumps(stats,ensure_ascii=False))


if __name__=='__main__':
    main()

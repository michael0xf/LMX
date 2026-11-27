"""Generate build-time canonical family inventory; never a runtime registry."""
from pathlib import Path
import json
import re
import sys
from sync_effects import Source
from identifier_spelling import markdown_code, spell
from catalog_data import owner_data

R = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(Path(__file__).resolve().parents[4] / 'tools'))
from normalize_lmx_closers import normalize_text

def write_lmx(path, lines):
    text = '\n'.join(lines) + '\n'
    cleaned, _ = normalize_text(text)
    path.write_text(cleaned, encoding="utf-8", newline="\n")
texts = {p.relative_to(R): p.read_text() for p in sorted((R/'src').rglob('*.lmx'))}
source = Source(texts)
effects = source.contracts()
roots = {}
for path, text in texts.items():
    starts = list(re.finditer(r'(?m)^(?:independent:\s*)?([A-Za-z_]\w*)\s*(?:::|:(?!:))', text))
    for i, match in enumerate(starts):
        roots[match[1]] = (path.as_posix(), text[match.start():starts[i+1].start() if i+1<len(starts) else len(text)])

def contract(api):
    owner, method = api.rsplit('\\', 1)
    if owner not in roots:
        raise ValueError('missing contract owner '+api)
    path, text = roots[owner]
    start = re.search(r'(?m)^    '+re.escape(method)+r':', text)
    if start is None:
        raise ValueError('missing contract method '+api)
    declaration = owner_data(text)
    source_declaration = declaration.pop('source_declaration')
    return {'source': path, **declaration,
            'declared_throws': effects.get(api, []),
            'throws_scope': 'explicit source declaration only; publication adds reached adapter/target failures',
            'source_declaration': source_declaration}

definitions = json.loads((R/'operation_definitions.json').read_text())['operations']
migration = json.loads((R/'CANONICAL_MIGRATION.json').read_text())
assert len({x['name'] for x in definitions}) == len(definitions)
assert len({x['old'] for x in migration['entries']}) == migration['baseline_count']
assert {x['new'] for x in migration['entries']} <= {x['name'] for x in definitions}
rows = []
operands = ['# Prepared ordinary-value forms. Built once in the actor/library', '# context before grouping; actual algorithms remain in the original methods.', '', 'StandardOperands:', '    const:']
public = ['# Canonical receiver projections. Complete family/role publication uses', '# PublishedFamilies and PUBLICATION_CONTRACT.md; this const projection', '# alone does not choose between semantic families or input roles.', 'fun:', '    const:']
families = ['# Explicit ordinary graph data for actor-context family publication.', '# Role, declared semantic family and full requirements select the same body.', '# This is not a callable kind, definition-order fallback or runtime registry.', '', 'PublishedFamilies:']
for index, d in enumerate(definitions, 1):
    name = d['name']
    first = d['variants'][0]
    for variant in d['variants']:
        variant['implementation_contract'] = contract(variant['api'])
    row = {'id':index, 'name':name, 'public_name':name, 'api':first['api'], 'source':first['source'], 'signature':d['signature'], 'scope':d['scope'], 'status':'BODY_WITH_BRIDGE', 'implementation_layer':'core', 'availability':'source_and_publication_contract', 'namespace_root':'fun\\const', 'lmx_executed':False, 'forms':d['forms'], 'variants':d['variants']}
    row['former_name'] = next((e['old'] for e in migration['entries'] if e['new']==name), None)
    rows.append(row)
    public.append('        @: '+spell(name)+' '+first['api'])
    if index > 1:
        families.append('    ---')
    families.append('    '+spell(name)+':')
    for variant in d['variants']:
        assert (R/variant['source']).is_file(), variant
        if variant['operand']['route']=='asOperand':
            field = variant['operand']['target'].split('\\')[-1]
            operands.append('        @: '+field+' FxAsOperand\\asOperand('+variant['api']+'; sys\\priority("+"))')
        families += ['        '+variant['family']+':', '            @: call '+variant['call']['target'], '            @: operand '+variant['operand']['target']]
write_lmx(R/'src/public.lmx', public)
write_lmx(R/'src/public_operands.lmx', operands)
write_lmx(R/'src/public_families.lmx', families)
(R/'catalog.json').write_text(json.dumps(rows, ensure_ascii=False, indent=2)+'\n', encoding="utf-8", newline="\n")
lines = ['# Canonical library operations and their two forms', '',
    f'{len(rows)} canonical names. Every input export is accounted for in [the migration inventory](CANONICAL_MIGRATION.json). Former names are not callable aliases.', '',
    'Both forms use the same algorithms and real owner DATA. Complete family/role binding, adaptive capture and exact result projection are defined in [PUBLICATION_CONTRACT.md](PUBLICATION_CONTRACT.md). Runtime execution is **NOT_RUN**.', '',
    'Operand DATA order is `left`, optional `int: depth`, `right`, with ready `PASS_ARGS_AS_IS` and `PRIORITY`. Absent depth preserves the ordinary method contract. Explicit `.(expression)op` uses zero for maximum logical-axis traversal and positive d for d outer axes. Positive d above an Array rank is diagnosed. The selected base entry is called without re-entering automatic Array Map. Ordinary operations are elementwise; [*] is matmul and .(1)[*] gives row dot products. There is no .op shorthand or array-of-arrays primitive. Structure/[]@ and text participate through actual types. Whole/RAW/DATA/TYPE/PLACE profiles retain their consuming roles. PD01 is required production integration, not a passed runtime implementation. Settings are ordinary LMX structures. See [source tensor contracts](TENSOR_OPERATIONS_IMPLEMENTATION.md).', '',
    '| Name | Ordinary form | Implementations and operand form |', '| --- | --- | --- |']
for row in rows:
    variants = '; '.join(f"**{v['family']}** [{markdown_code(v['api'])}]({v['source']}) → {markdown_code(v['operand']['target'])} ({v['operand']['route']})" for v in row['variants'])
    lines.append(f"| {markdown_code(row['name'])} | {markdown_code(row['signature'])} | {variants} |")
lines += ['', '## Roles, results and failures', '']
for row in rows:
    lines.append(f"- **{row['name']}** — {row['scope']}. Roles: "+', '.join(row['variants'][0]['roles'])+'.')
lines += ['', 'Every variant retains its actual result, void/field-stream/control role, context and finite failures. Quoting does not select a different implementation. See [forms](../../OPERATION_FORMS.md), [generic operations](../../GENERIC_OPERATIONS.md), [monads](../../MONADIC_OPERATIONS.md) and [equality](../../GENERIC_EQUALITY.md).']
(R/'CATALOG.md').write_text('\n'.join(lines)+'\n', encoding="utf-8", newline="\n")
regex = json.loads((R/'REGEX_EXPORTS.json').read_text())
values = [x for x in regex['exports'] if x['role'] not in {'builder','receiver','text_profile','operand','source_profile'}]
(R/'value_symbols.json').write_text(json.dumps(values, ensure_ascii=False, indent=2)+'\n', encoding="utf-8", newline="\n")
print(json.dumps({'canonical_names':len(rows),'variants':sum(len(x['variants']) for x in rows),'baseline_exports_covered':len(migration['entries']),'runtime_executed':False}))

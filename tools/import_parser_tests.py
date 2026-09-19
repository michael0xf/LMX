"""Import parser fixtures and existing expectations byte-for-byte, in source order."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
SOURCES = [
    ('01-old-worked', Path(r'C:\Nyasha_Planet\lingvamyxa_old_worked_version')),
    ('02-lingvamyxa', Path(r'C:\Nyasha_Planet\lingvamyxa')),
    ('03-l1', Path(r'C:\Nyasha_Planet\L1')),
    ('04-prev-audit', Path(r'C:\Nyasha_Planet\lingvamyxa_prev')),
]
records = []
by_content = {}

def import_file(base, stage, p, role):
    relative = p.relative_to(base).as_posix()
    raw = p.read_bytes()
    sha = hashlib.sha256(raw).hexdigest()
    key = (relative, sha)
    if key in by_content:
        by_content[key]['origins'].append({'stage':stage, 'root':str(base), 'path':relative})
        return
    target = Path('tests/parser/imported') / stage / relative
    dest = ROOT / target
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(raw)
    record = {'path':target.as_posix(), 'original_path':relative, 'sha256':sha,
              'bytes':len(raw), 'role':role,
              'origins':[{'stage':stage,'root':str(base),'path':relative}]}
    by_content[key] = record
    records.append(record)

for stage, base in SOURCES:
    selected = {}
    # Full recursive historical parser corpus, including parse-only registry inputs.
    for p in (base/'tests').rglob('*.lmx'):
        selected[p]='p0-fixture'
    if stage=='04-prev-audit':
        before=len(records)
        for p,role in sorted(selected.items(),key=lambda item:item[0].as_posix()):
            import_file(base,stage,p,role)
        print(stage, 'source files',len(selected),'new byte-distinct files',len(records)-before)
        continue
    for p in (base/'tests/p0_tree_contract').glob('*'):
        if p.is_file(): selected[p]='p0-fixture' if p.suffix=='.lmx' else 'historical-contract-artifact'
    for p in (base/'tests/l1/goldens/printTree.lm0').glob('*'):
        if p.is_file():selected[p]='frozen-oracle'
    # Keep expression/C-surface regression sources and their original runners.
    for p in (base/'tests/l1').glob('*'):
        if p.is_file() and (p.name.startswith('expr_') or p.name in (
            'run_expr.ps1','run_parser.ps1','run_legacy_p0.ps1','legacy_p0_manifest.txt',
            'integer_add.lm1','shift_ops.lm1','invalid_deref_target.lm1','quote_run.lm1')):
            selected[p]='expression-fixture' if p.suffix=='.lm1' else 'historical-harness'
    for p in (base/'tests').glob('*'):
        if p.is_file() and (re.search(r'^trans_.*(c_surface|value_field_dot|getenv_index|index_bracket|index_semantic|nested_call_namespace|multiline_paren|parser_|quoted|python_string|block_string)',p.name)
                           or p.name=='run_c_surface_reference.ps1'):
            selected[p]='expression-fixture' if p.suffix in ('.lm1','.lm2') else 'historical-harness'
    # Dependencies of the parser acceptance/expressions are test inputs, not a port of the compiler.
    acceptance=base/'l1src/make.lm1'
    if acceptance.is_file() and (base/'tests/l1/run_parser.ps1').is_file():
        selected[acceptance]='parser-acceptance-input'
    # Copy explicit local includes/predefs referenced by selected fixtures.
    pending=list(selected)
    while pending:
        p=pending.pop()
        if p.suffix not in ('.lm1','.lm2','.lmx','.h'):continue
        text=p.read_text(encoding='utf-8-sig',errors='replace')
        refs=re.findall(r'(?:include|predef)\s*:\s*"([^"<>]+)"',text)
        for ref in refs:
            if ref.startswith(('l1src/','lm1/','lm2/','l2src/')):continue
            candidates=[p.parent/ref,base/ref,base/'tests'/ref]
            q=next((x.resolve() for x in candidates if x.is_file()),None)
            if q is not None and q.is_relative_to(base) and q not in selected:
                selected[q]='fixture-support';pending.append(q)
    before=len(records)
    for p,role in sorted(selected.items(),key=lambda item:item[0].as_posix()):
        import_file(base,stage,p,role)
    print(stage, 'source files',len(selected),'new byte-distinct files',len(records)-before)

(ROOT/'provenance/parser-tests.json').write_text(json.dumps({'sources':[{'stage':s,'root':str(p)} for s,p in SOURCES], 'files':records},ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Total stored files:',len(records))

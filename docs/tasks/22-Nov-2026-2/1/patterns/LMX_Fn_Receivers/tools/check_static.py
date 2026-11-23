"""Limited text/package checks only. NOT an LMX parser, compiler or runtime."""
from pathlib import Path
import json
import re
from collections import Counter
from assemble import assembled, PARTS

ROOT = Path(__file__).resolve().parents[1]
source_path = ROOT / 'LMX_Receivers.lmx'
source = source_path.read_text(encoding='utf-8')
errors = []
clean = []
stack = []
quote = None
escaped = False
last = None
roots = set()
disabled = set()

for n, line in enumerate(source.splitlines(), 1):
    if '\t' in line:
        errors.append(f'{n}: tab indentation')
    if not line.strip():
        last = None
        clean.append('')
        continue
    body = []
    i = 0
    while i < len(line):
        c = line[i]
        if quote:
            if escaped:
                escaped = False
            elif c == '\\' and quote != '`':
                escaped = True
            elif c == quote:
                if quote == '`' and i + 1 < len(line) and line[i + 1] == '`':
                    i += 1
                else:
                    quote = None
            body.append(' ')
        elif c == '#':
            break
        elif c in ('"', "'", '`'):
            quote = c
            body.append(' ')
        else:
            body.append(c)
            if c in '([':
                stack.append((c, n))
            elif c in ')]':
                if not stack or stack[-1][0] != {')': '(', ']': '['}[c]:
                    errors.append(f'{n}: unmatched {c}')
                else:
                    stack.pop()
        i += 1
    code = ''.join(body).rstrip()
    clean.append(code)
    if not code.strip():
        continue
    indent = len(line) - len(line.lstrip())
    if indent % 4:
        errors.append(f'{n}: indentation {indent}')
    if last and indent < last[0] - 4 and code.strip() != '---':
        errors.append(f'{n}: multi-level decrease {last[0]}->{indent} without cutter')
    last = (indent, n)
    if indent == 0:
        m = re.match(r'(?:independent:\s*)?((?:Rx|Fx)\w+)\s*(?:::|:|\()', code)
        if m:
            name = m.group(1)
            if name in roots:
                errors.append(f'{n}: duplicate root {name}')
            roots.add(name)
        m = re.match(r'%((?:Rx|Fx)\w+):', code)
        if m:
            disabled.add(m.group(1))

if stack:
    errors.append(f'unclosed brackets: {stack}')
if quote:
    errors.append(f'unclosed literal: {quote}')

code = '\n'.join(clean)
refs = set(re.findall(r'\b((?:Rx|Fx)\w+)\\', code))
providers = {'FxKernel'}
missing = sorted(refs - roots - disabled - providers)
errors += [f'unlisted external qualified root {name}' for name in missing]
if source != assembled():
    errors.append('combined file does not match src/examples')
if re.search(r'doubleColon|RxTypeChain', code):
    errors.append('obsolete active receiver remains')

catalog = json.loads((ROOT / 'catalog.json').read_text(encoding='utf-8'))
if len(catalog) != 115 or len({row['name'] for row in catalog}) != 115:
    errors.append('catalog must retain all 61 uploaded identities plus 14 sequence and 40 text operations')
expected_entries = {
    'replaceRange': ('FxSeqReplaceRange\\replaceRange', 'replaceRange(target; begin; end; values)'),
    'splice': ('FxSeqSplice\\splice', 'splice(target; begin; end; values)'),
    'replace': ('RxReplace\\replace', 'replace(source; pattern; replacement)'),
    'hasPrefix': ('RxHasPrefix\\hasPrefix', 'hasPrefix(source; pattern)'),
    'hasSuffix': ('RxHasSuffix\\hasSuffix', 'hasSuffix(source; pattern)'),
}
for name, (api, signature) in expected_entries.items():
    matches = [x for x in catalog if x['name'] == name]
    if len(matches) != 1 or matches[0]['api'] != api or matches[0]['signature'] != signature:
        errors.append('wrong or non-unique agreed API entry ' + name)
for row in catalog:
    name = row['api'].split('\\')[0]
    expected = disabled if row['status'] == 'GAP' else roots
    if name not in expected:
        errors.append(f"catalog {row['name']}: root does not match status {row['status']}")

for required in ['(a b c) := (b c a)', '(a b c) := (copy(s))']:
    if required not in code:
        errors.append(f'missing current assignment example: {required}')

kernel_calls = sorted(set(re.findall(r'\bFxKernel\\+(\w+)\s*\(', source)))
expected_kernel_calls = sorted(['attempt', 'callable', 'fieldNames', 'normalizeType', 'raise', 'renameFields', 'signature', 'signatureData', 'currentCall', 'frameSlot', 'prepare', 'enter', 'releaseCall', 'arrayInfo', 'arrayRead', 'arrayAdmit', 'arrayWrite'])
if kernel_calls != expected_kernel_calls:
    errors.append(f'provider calls differ from 17 documented common interfaces: {kernel_calls}')

for row in catalog:
    if not (ROOT / row['source']).is_file():
        errors.append('missing catalog source '+row['source'])
former=[r['former_name'] for r in catalog[:50]]
if len(set(former)) != 50:
    errors.append('original 50 catalog identities were lost or duplicated')
public=(ROOT/'src/public.lmx').read_text()
if 'fun:\n    const:\n' not in public:
    errors.append('core exports must be root constants under one const block')
if re.search(r'^\s*@:\s+fn\s',public,re.M):
    errors.append('removed public fn alias remains')
for row in catalog:
    if '        @: '+row['name']+' '+row['api'] not in public:
        errors.append('missing constant export '+row['name'])
if re.search(r'RxInt|IntUnary|IntBinary|IntCurried|RxCollectionInt',code):
    errors.append('legacy payload specialisation leaked into current assembly')
if re.search(r'\bfn\s*:', code):
    errors.append('removed named declaration syntax remains')
if re.search(r'\bimplements\s*[(:]',code):
    errors.append('old receiver spelling in active source')

report = {
    'scope': 'Limited source/package checks; not LMX parsing, compilation or execution',
    'lmx_runtime_executed': False,
    'combined_file': source_path.name,
    'source_parts': len(PARTS),
    'source_lines': len(source.splitlines()),
    'requested_receivers': len(catalog),
    'catalog_status_counts': dict(Counter(row['status'] for row in catalog)),
    'active_root_definitions': len(roots),
    'disabled_catalog_skeletons': sorted(disabled),
    'intentional_external_providers': sorted(providers),
    'provider_methods': kernel_calls,
    'prepared_assertions': len(re.findall(r'\bsys\\assert\(', code)),
    'checks': ['literal and bracket balance', 'four-space indentation',
               'explicit multi-level cutters', 'qualified root coverage',
               'single-file assembly equality', '115-entry unique callable/operand catalog coverage',
               'no active obsolete receiver', 'two current assignment examples',
               'exact documented provider dependencies'],
    'limitations': ['does not implement full LMX grammar or name lookup',
                    'does not prove type admission, parent links or execution',
                    'does not execute generated body text',
                    'does not verify allocator/lifetime or native ABI'],
    'errors': errors,
}
(ROOT / 'tests' / 'STATIC_REPORT.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps(report, ensure_ascii=False))
raise SystemExit(bool(errors))


#!/usr/bin/env python3
"""Check local sources, published counts, links and actual SBCL receipts."""
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import argparse
import hashlib
import json
import re
from rebuild import metrics, normalized, validate_variants, STYLES
from lmx_execution_contract import acceptance_document

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def validate_artifacts(check, catalog):
    """Use current common receipts and independently read the two exported files."""
    patterns = ROOT.parents[1]
    stem = 'examples/SBCL_comparison/LMX_Comparison_SBCL'
    report_names = {
        'model': 'PUBLICATION_DATA.json',
        'workbook': 'validation/workbook_publication_20261123.json',
        'pdf': 'validation/pdf_generation_20261123.json',
        'independent': 'validation/publication_checks.json',
    }
    reports = {}
    for kind, name in report_names.items():
        path = patterns / name
        if not check(path.is_file(), f'current publication report exists: {name}'):
            continue
        try:
            reports[kind] = json.loads(path.read_text())
        except (ValueError, UnicodeError) as exc:
            check(False, f'cannot read current publication report {name}: {exc}')
    if set(reports) != set(report_names):
        return {'status': 'FAIL', 'reason': 'Current common model or reports missing'}
    model_hash = digest(patterns / report_names['model'])
    model = reports['model']
    for kind in ('workbook', 'pdf', 'independent'):
        check(reports[kind].get('source_sha256') == model_hash, f'{kind}: receipt uses exact current publication model')
    independent = reports['independent']
    check(independent.get('status') == 'PASS', 'all 18 exported workbook/PDF pairs pass independent publication checks')
    check(independent.get('verifier', {}).get('sha256') == digest(patterns / 'tools/verify_publication.py'),
          'independent audit uses the current verifier')
    for kind, label in (('workbook', 'workbooks'), ('pdf', 'pdfs')):
        recorded = independent.get('generation_reports', {}).get(label, {})
        check(recorded.get('sha256') == digest(patterns / report_names[kind]), f'{kind}: independent audit uses current generation receipt')
    matches = [doc for doc in model['documents'] if doc['stem'] == stem]
    if not check(len(matches) == 1, 'SBCL has exactly one publication document'):
        return {'status': 'FAIL', 'reason': 'Missing or repeated SBCL publication model'}
    document = matches[0]
    client_tables = [table for view in document['sheets'] for table in view['tables']
                     if 'LMX\nпроцедурный' in table['headers'] and 'LMX\nфункциональный' in table['headers']]
    if check(len(client_tables) == 1, 'SBCL model has both full LMX count columns'):
        table = client_tables[0]
        pc = table['headers'].index('LMX\nпроцедурный')
        fc = table['headers'].index('LMX\nфункциональный')
        rows = {row[0]: row for row in table['rows']}
        check(set(rows) == {entry['id'] for entry in catalog['examples']}, 'publication model includes all 24 SBCL clients')
        for entry in catalog['examples']:
            row = rows.get(entry['id'])
            if row is not None:
                check(row[pc] == entry['counts']['lmx_procedural']['characters_nonwhitespace'], f"{entry['id']} published procedural full count")
                check(row[fc] == entry['counts']['lmx_functional']['characters_nonwhitespace'], f"{entry['id']} published functional full count")
    sys.path.insert(0, str(patterns / 'tools'))
    from verify_publication import workbook_check, pdf_check
    results = []
    for kind, suffix, label in (('workbook', '.xlsx', 'workbooks'), ('pdf', '.pdf', 'pdfs')):
        filename = stem + suffix
        receipts = [item for item in reports[kind].get('files', []) if item.get('file') == filename]
        check(len(receipts) == 1, f'{filename}: exactly one current generation receipt')
        receipt = receipts[0] if len(receipts) == 1 else None
        if kind == 'workbook':
            actual = workbook_check(patterns, document, filename, receipt)
        else:
            actual = pdf_check(patterns, document, filename, receipt, reports[kind].get('tables', []))
        check(actual['status'] == 'PASS', f'{filename}: current file values, full dual columns, formulas and every green minimum agree: {actual["errors"]}')
        recorded = [item for item in independent.get(label, []) if item.get('file') == filename]
        check(len(recorded) == 1 and recorded[0].get('status') == 'PASS'
              and recorded[0].get('sha256') == actual.get('sha256'), f'{filename}: independent report matches actual exported bytes')
        results.append(actual)
    return {'status': 'PASS' if all(item['status'] == 'PASS' for item in results) else 'FAIL',
            'source_sha256': model_hash, 'files': results,
            'native_excel_execution': 'NOT_RUN', 'lmx_runtime_execution': 'NOT_RUN'}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--skip-artifacts', action='store_true')
    args = parser.parse_args()
    errors, checks = [], []

    def check(ok, label):
        checks.append(label)
        if not ok:
            errors.append(label)
        return bool(ok)

    catalog = json.loads((ROOT / 'examples.json').read_text())
    if catalog.get('workflow_expansion_ids'):
        # Validate current workflow sources, measurements and acceptance data.
        # The earlier runtime receipt is kept separate from these new sources.
        from check_workflow_sources import main as check_workflows
        result = check_workflows()
        if result or args.skip_artifacts:
            return result
        artifacts = validate_artifacts(check, catalog)
        (ROOT / 'validation/workflow_artifact_checks.json').write_text(
            json.dumps(artifacts, ensure_ascii=False, indent=2) + '\n')
        print(json.dumps({'artifacts': artifacts, 'errors': errors}, ensure_ascii=False))
        return 1 if errors else 0
    stats = json.loads((ROOT / 'statistics.json').read_text())
    implementations = json.loads((ROOT / 'implementation_data.json').read_text())
    index = {row['id']: row for row in stats['examples']}
    check([e['id'] for e in catalog['examples']] == [f'S{i:02}' for i in range(1, 25)], '24 consecutive client identifiers')
    check(len(implementations['implementations']) == 6, 'six implementation pairs')
    check(stats['counts']['complete_pairs'] == 23 and stats['counts']['related_analogies'] == 1, '23 paired tasks plus S24 protocol analogy')
    total = {'lmx_procedural':0,'lmx_functional':0,'foreign':0}
    selections = []
    for entry in catalog['examples']:
        sid = entry['id']
        page = (ROOT / f'{sid}_comparision.md').read_text()
        problems=validate_variants(entry,ROOT)
        check(not problems,f'{sid} complete style contract: '+str(problems))
        check(entry['lmx']==entry['lmx_variants']['functional']['code'],f'{sid} legacy LMX is only functional mirror')
        variants=[]
        for style in STYLES:
            variant=entry['lmx_variants'][style]
            source=normalized((ROOT/variant['source_file']).read_text());count=metrics(source);key='lmx_'+style
            check(count==entry['counts'][key]==index[sid][key],f'{sid} {style} exact full metrics')
            check(source in page,f'{sid} {style} complete source in Markdown')
            if entry['comparison_status']=='complete_pair':total[key]+=count['characters_nonwhitespace']
            variants.append({'style':style,'path':variant['source_file'],'compared':True,**count})
        source=normalized((ROOT/entry['source_files']['foreign']).read_text());count=metrics(source)
        check(source==entry['foreign'],f'{sid} unchanged foreign source mirror')
        check(count==entry['counts']['foreign']==index[sid]['foreign'],f'{sid} foreign exact metrics')
        check(source in page,f'{sid} complete foreign source in Markdown')
        if entry['comparison_status']=='complete_pair':total['foreign']+=count['characters_nonwhitespace']
        seen={v['sha256'] for v in variants}
        alternatives=[]
        for alternative in entry.get('alternatives',[]):
            code=normalized((ROOT/alternative['source_file']).read_text());count=metrics(code)
            check(code in page,f"{sid} complete distinct alternative: {alternative['source_file']}")
            check(count['sha256'] not in seen,f'{sid} alternative is not a style duplicate')
            seen.add(count['sha256']);alternatives.append({'path':alternative['source_file'],'compared':False,**count})
        selections.append({'id':sid,'variants':variants,'alternatives':alternatives,'style_relation':entry['style_relation'],
            'style_note':entry['style_note'],'selection_rule':'Both complete LMX styles are compared; size never selects or discards a style'})
    for language in total:
        check(total[language] == stats['paired_totals'][language]['characters_nonwhitespace'], f'{language} paired total')
    coverage = json.loads((ROOT / 'validation/library_coverage.json').read_text())
    check(not coverage['missing_primary'] and not coverage['missing_alternative'], 'all named core operations have canonical implementation sources')

    for item in implementations['implementations']:
        page = (ROOT / 'library_comparisons' / f"{item['id']}_comparision.md").read_text()
        for language in ('lmx', 'foreign'):
            source = normalized((ROOT / item['source_files'][language]).read_text())
            check(source == item[language] and source in page, f"{item['id']} {language} source JSON Markdown agree")
    report = json.loads((ROOT / 'validation/common_lisp.json').read_text())
    check(report['status'] == 'PASS' and report['passed'] == report['expected_assertions'] and report['failed'] == 0, 'actual SBCL client checks passed')
    for filename, expected in report['source_sha256'].items():
        check(digest(ROOT / filename) == expected, f'fresh client test receipt: {filename}')
    report = json.loads((ROOT / 'validation/implementation_execution.json').read_text())
    check(report['status'] == 'PASS' and report['checks'] > 0, 'actual SBCL implementation checks passed')
    for item in report['files']:
        check(digest(ROOT / item['file']) == item['sha256'], f"fresh implementation receipt: {item['file']}")

    for markdown in sorted(ROOT.rglob('*.md')):
        for raw in re.findall(r'(?<!!)\[[^\]]*\]\(([^)]+)\)', markdown.read_text()):
            url = raw.split()[0].strip('<>')
            if re.match(r'^[a-zA-Z][a-zA-Z0-9+.-]*:', url) or url.startswith('#'):
                continue
            file_part = url.split('#', 1)[0]
            target = (markdown.parent / file_part).resolve()
            if args.skip_artifacts and target.suffix in ('.pdf', '.xlsx'):
                continue
            if target.is_relative_to(ROOT) or target.exists():
                check(target.exists(), f'link: {markdown.relative_to(ROOT)} -> {file_part}')
            # The separate directory deliberately keeps external spec links.

    artifact_results = {'status': 'SKIPPED', 'reason': '--skip-artifacts source-only mode'}
    if not args.skip_artifacts:
        artifact_results = validate_artifacts(check, catalog)
    output = {'status': 'PASS' if not errors else 'FAIL', 'checks': len(checks),
              'errors': errors, 'lmx_runtime': 'NOT_RUN',
              'artifacts': artifact_results,
              'meaning': 'Source consistency, links and actual Common Lisp receipts; optional current exported publication checks; not execution of LMX or native Excel.'}
    (ROOT / 'validation/source_checks.json').write_text(json.dumps(output, ensure_ascii=False, indent=2) + '\n')
    (ROOT / 'variant_selection.json').write_text(json.dumps({'methodology':'Both full procedural and functional LMX variants are primary; no alternative Throws count or shortest-style selection.','examples':selections}, ensure_ascii=False, indent=2) + '\n')
    (ROOT / 'validation/lmx_acceptance_cases.json').write_text(json.dumps(acceptance_document({'status': 'NOT_RUN', 'examples': [{'id': e['id'], 'operation': e['lmx_operation'], 'source': e['source_files']['lmx'], 'source_role':'functional_compatibility_mirror', 'variants':{style:{'source':e['lmx_variants'][style]['source_file'],'status':'NOT_RUN'} for style in STYLES}, 'contract': e['contract'], 'cases': e['test_cases'], 'additional_cases': e.get('lmx_acceptance_cases', [])} for e in catalog['examples']]}), ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(output, ensure_ascii=False))
    return 0 if not errors else 1


if __name__ == '__main__':
    raise SystemExit(main())

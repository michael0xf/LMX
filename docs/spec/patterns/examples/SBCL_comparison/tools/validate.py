#!/usr/bin/env python3
"""Check local sources, published counts, links and actual SBCL receipts."""
import sys
sys.dont_write_bytecode = True
from pathlib import Path
import argparse
import hashlib
import json
import re
from rebuild import metrics, normalized

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--skip-artifacts', action='store_true')
    args = parser.parse_args()
    errors, checks = [], []

    def check(ok, label):
        checks.append(label)
        if not ok:
            errors.append(label)

    catalog = json.loads((ROOT / 'examples.json').read_text())
    stats = json.loads((ROOT / 'statistics.json').read_text())
    implementations = json.loads((ROOT / 'implementation_data.json').read_text())
    index = {row['id']: row for row in stats['examples']}
    check([e['id'] for e in catalog['examples']] == [f'S{i:02}' for i in range(1, 25)], '24 consecutive client identifiers')
    check(len(implementations['implementations']) == 6, 'six implementation pairs')
    check(stats['counts']['complete_pairs'] == 23 and stats['counts']['related_analogies'] == 1, '23 paired tasks plus S24 protocol analogy')
    total = {'lmx': 0, 'foreign': 0}
    selections = []
    for entry in catalog['examples']:
        sid = entry['id']
        page = (ROOT / f'{sid}_comparision.md').read_text()
        for language in ('lmx', 'foreign'):
            file = ROOT / entry['source_files'][language]
            source = normalized(file.read_text())
            count = metrics(source)
            check(source == entry[language], f'{sid} {language} source matches catalogue')
            check(count == entry['counts'][language] == index[sid][language], f'{sid} {language} exact metrics')
            check(source in page, f'{sid} {language} complete source in Markdown')
            if entry['comparison_status'] == 'complete_pair':
                total[language] += count['characters_nonwhitespace']
        candidates = [{'path': entry['source_files']['lmx'], 'primary': True,
                       'approach': entry.get('selected_approach', 'selected'), **metrics(entry['lmx'])}]
        seen = {metrics(entry['lmx'])['sha256']}
        for alternative in entry.get('alternatives', []):
            code = normalized((ROOT / alternative['source_file']).read_text())
            count = metrics(code)
            check(code in page, f"{sid} alternative complete in Markdown: {alternative['source_file']}")
            check(count['sha256'] not in seen, f'{sid} alternative is not an identical listing')
            seen.add(count['sha256'])
            candidates.append({'path': alternative['source_file'], 'primary': False,
                               'approach': alternative['approach'], **count})
            if sid != 'S23':
                check(count['characters_nonwhitespace'] >= candidates[0]['characters_nonwhitespace'], f'{sid} shortest eligible full listing selected')
        selections.append({'id': sid, 'candidates': candidates,
                           'selection_rule': 'S23 primary contains the cache algorithm; ready memoize is a separate level' if sid == 'S23' else 'Shortest considered full approach on the stated domain'})
    for language in total:
        check(total[language] == stats['paired_totals'][language]['characters_nonwhitespace'], f'{language} paired total')
    coverage = json.loads((ROOT / 'validation/library_coverage.json').read_text())
    check(not coverage['missing_primary'] and not coverage['missing_alternative'], 'all named core operations have implementation links')

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

    if not args.skip_artifacts:
        for name in ('LMX_Comparison_SBCL.pdf', 'LMX_Comparison_SBCL.xlsx'):
            check((ROOT / name).is_file() and (ROOT / name).stat().st_size > 1000, f'artifact exists: {name}')
    output = {'status': 'PASS' if not errors else 'FAIL', 'checks': len(checks),
              'errors': errors, 'lmx_runtime': 'NOT_RUN',
              'meaning': 'Source consistency, links and actual Common Lisp receipts; not execution of LMX.'}
    (ROOT / 'validation/source_checks.json').write_text(json.dumps(output, ensure_ascii=False, indent=2) + '\n')
    (ROOT / 'variant_selection.json').write_text(json.dumps({'methodology': 'Full Unicode nonwhitespace counts; substantive alternatives only.', 'examples': selections}, ensure_ascii=False, indent=2) + '\n')
    (ROOT / 'validation/lmx_acceptance_cases.json').write_text(json.dumps({'status': 'NOT_RUN', 'examples': [{'id': e['id'], 'entry_point': e['lmx_entry_point'], 'source': e['source_files']['lmx'], 'contract': e['contract'], 'cases': e['test_cases'], 'additional_cases': e.get('lmx_acceptance_cases', [])} for e in catalog['examples']]}, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(output, ensure_ascii=False))
    return 0 if not errors else 1


if __name__ == '__main__':
    raise SystemExit(main())

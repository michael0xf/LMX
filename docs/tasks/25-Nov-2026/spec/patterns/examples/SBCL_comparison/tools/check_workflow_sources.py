#!/usr/bin/env python3
"""Check expanded sources, current full-source metrics, and acceptance data.

This does not evaluate Lisp or parse/execute LMX. Fixture properties are
checks of the declared acceptance observations, not a runtime receipt.
"""

from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]


def balanced_lisp(text):
    depth, string, escaped, comment = 0, False, False, False
    for char in text:
        if comment:
            if char == '\n':
                comment = False
            continue
        if string:
            if escaped:
                escaped = False
            elif char == '\\':
                escaped = True
            elif char == '"':
                string = False
            continue
        if char == ';':
            comment = True
        elif char == '"':
            string = True
        elif char == '(':
            depth += 1
        elif char == ')':
            depth -= 1
            if depth < 0:
                return False
    return depth == 0 and not string


def fixture_properties(id, args, result):
    if id == 'S01':
        items, gain, offset = args
        calibrated, total = result
        return calibrated == [x * gain + offset for x in items] and total == sum(calibrated)
    if id == 'S02':
        items, limit = args
        accepted, total, rejected = result
        return (limit >= 0 and accepted == [x for x in items if 0 < x <= limit]
                and total == sum(accepted) and len(accepted) + rejected == len(items))
    if id == 'S03':
        initial, costs = args
        remaining, accepted, rejected = result
        # Check every prefix's accepted charge; rejected requests leave its budget intact.
        balances = [initial]
        decisions = []
        for charge in costs:
            decisions.append(charge <= balances[-1])
            balances.append(balances[-1] - charge if decisions[-1] else balances[-1])
        return (remaining == balances[-1] >= 0 and accepted == sum(decisions)
                and accepted + rejected == len(costs))
    if id == 'S04':
        quantities, prices = args
        totals, total, extra_quantities, extra_prices = result
        return (totals == [q * p for q, p in zip(quantities, prices)]
                and total == sum(totals) and len(totals) + extra_quantities == len(quantities)
                and len(totals) + extra_prices == len(prices))
    if id == 'S06':
        items, = args
        accepted, total, bad = result
        count = len(items) if bad < 0 else bad
        return (accepted == items[:count] and all(x >= 0 for x in accepted)
                and total == sum(accepted) and ((bad == -1 and count == len(items))
                    or (0 <= bad < len(items) and items[bad] < 0)))
    if id == 'S07':
        items, limit = args
        selected, deferred = result
        indexed = sorted(enumerate(items), key=lambda item: (item[1][0], item[0]))
        return (selected == [row for _, row in indexed[:limit]]
                and deferred + len(selected) == len(items))
    if id == 'S08':
        items, completed = args
        pending, duplicates, done = result
        distinct = list(dict.fromkeys(items))
        return (pending == [x for x in distinct if x not in completed]
                and len(pending) == len(set(pending)) and not set(pending).intersection(completed)
                and duplicates == len(items) - len(distinct)
                and len(pending) + done + duplicates == len(items))
    if id == 'S09':
        items, start, end, replacement = args
        updated, changed, delta = result
        return (0 <= start <= end <= len(items) and end - start == len(replacement)
                and updated == items[:start] + replacement + items[end:]
                and len(updated) == len(items)
                and changed == sum(a != b for a, b in zip(updated, items))
                and sum(updated) == sum(items) + delta)
    if id == 'S11':
        opening, charges, credits = args
        charged, credited, closing = result
        return charged == sum(charges) and credited == sum(credits) and closing + credited == opening + charged
    if id == 'S15':
        n, capacity = args
        full, remainder, boxes, unused = result
        return (n >= 0 and capacity > 0 and n == full * capacity + remainder
                and 0 <= remainder < capacity and boxes == (n + capacity - 1) // capacity
                and boxes * capacity == n + unused and 0 <= unused < capacity)
    raise KeyError(id)


def main():
    data = json.loads((ROOT / 'examples.json').read_text())
    statistics = json.loads((ROOT / 'statistics.json').read_text())
    measures = {row['id']: row for row in statistics['examples']}
    ids = data['workflow_expansion_ids']
    acceptance = {row['id']: row for row in json.loads((ROOT / 'validation/lmx_acceptance_cases.json').read_text())['examples']}
    selection = {row['id']: row for row in json.loads((ROOT / 'variant_selection.json').read_text())['examples']}
    public = (ROOT / '../../LMX_Fn_Receivers/src/public.lmx').resolve().read_text()
    errors, checks, fixture_count, file_count = [], 0, 0, 0

    def check(ok, label):
        nonlocal checks
        checks += 1
        if not ok:
            errors.append(label)

    def measure(source):
        text = source.replace('\r\n', '\n').replace('\r', '\n').strip() + '\n'
        return dict(characters_nonwhitespace=sum(not c.isspace() for c in text), characters_all=len(text),
                    nonblank_lines=sum(bool(line.strip()) for line in text.splitlines()),
                    utf8_bytes=len(text.encode()), sha256=hashlib.sha256(text.encode()).hexdigest())

    totals = dict(lmx_procedural=0, lmx_functional=0, foreign=0)
    for entry in data['examples']:
        id = entry['id']
        page = (ROOT / f'{id}_comparision.md').read_text()
        for style, variant in entry['lmx_variants'].items():
            source = (ROOT / variant['source_file']).read_text()
            size = measure(source)
            key = 'lmx_' + style
            check(size == entry['counts'][key] == measures[id][key], f'{id}/{style}: current complete count')
            check(size['characters_nonwhitespace'] == variant['metrics']['characters']
                  and size['sha256'] == variant['metrics']['sha256'], f'{id}/{style}: current variant metric')
            check(source == variant['code'] and source.rstrip() in page, f'{id}/{style}: current full listing mirror')
            if entry['comparison_status'] == 'complete_pair':
                totals[key] += size['characters_nonwhitespace']
        source = (ROOT / entry['source_files']['foreign']).read_text()
        size = measure(source)
        check(size == entry['counts']['foreign'] == measures[id]['foreign'], f'{id}: current full Lisp count')
        check(source == entry['foreign'] and source.rstrip() in page, f'{id}: current Lisp mirror')
        if entry['comparison_status'] == 'complete_pair':
            totals['foreign'] += size['characters_nonwhitespace']
    for language, total in totals.items():
        check(total == statistics['paired_totals'][language]['characters_nonwhitespace'], f'{language}: complete current paired total')

    for entry in data['examples']:
        id = entry['id']
        if id not in ids:
            continue
        page = (ROOT / f'{id}_comparision.md').read_text()
        check(entry['metrics_status'] == 'current' and 'counts' in entry, f'{id}: active metrics current')
        check(entry['lmx'] == entry['lmx_variants']['functional']['code'], f'{id}: legacy field mirrors functional')
        check(acceptance[id]['cases'] == entry['test_cases'] and acceptance[id]['contract'] == entry['contract'], f'{id}: acceptance fixture mirrors')
        check(json.loads(re.search(r'```json\n(.*?)\n```', page, re.S).group(1)) == entry['test_cases'], f'{id}: Markdown fixtures mirror')
        for style, variant in entry['lmx_variants'].items():
            source = (ROOT / variant['source_file']).read_text()
            check(source == variant['code'] and source.rstrip() in page, f'{id}/{style}: source JSON Markdown agree')
            check(variant['metrics_status'] == 'current' and 'metrics' in variant, f'{id}/{style}: active metrics current')
            check(variant['runtime_execution'] == 'NOT_RUN' and variant['parser_execution'] == 'NOT_RUN', f'{id}/{style}: honest LMX status')
            check(next(row for row in selection[id]['variants'] if row['style'] == style)['path'] == variant['source_file'], f'{id}/{style}: selection path')
            check(acceptance[id]['variants'][style]['source'] == variant['source_file'], f'{id}/{style}: fixture source')
            check(not re.search(r'@:\s+(?:int|Model)\s+\w+', source), f'{id}/{style}: no old typed-reference declaration')
            file_count += 1
        foreign = (ROOT / entry['source_files']['foreign']).read_text()
        check(foreign == entry['foreign'] and foreign.rstrip() in page, f'{id}: Lisp source JSON Markdown agree')
        check(balanced_lisp(foreign), f'{id}: Lisp delimiters/strings balanced (not a Lisp parser)')
        check(entry['foreign_runtime_execution'] == 'NOT_RUN', f'{id}: honest Lisp execution status')
        file_count += 1
        for operation, path in entry['core_sources'].items():
            check((ROOT / path).is_file(), f'{id}: actual core source exists for {operation}')
            check(bool(re.search(r'@:\s+' + re.escape(operation) + r'\s', public)), f'{id}: published core operation {operation}')
        for alternative in entry.get('alternatives', []):
            check(alternative['role'] == 'compatibility_mirror_of_functional_variant'
                  and (ROOT / alternative['source_file']).read_text() == entry['lmx'], f'{id}: alternative compatibility path')
        for case in entry['test_cases']:
            check(fixture_properties(id, case['args'], case['expected']), f'{id}: declared fixture invariant {case!r}')
            fixture_count += 1
    harness = (ROOT / 'tools/test_common_lisp.lisp').read_text()
    check(balanced_lisp(harness), 'generated Lisp harness has balanced delimiters/strings')
    for id in ids:
        check(f'"{id}"' in harness, f'{id}: included in generated Lisp harness')
    report = dict(status='PASS' if not errors else 'FAIL', meaning='Current full-source metrics, source/fixture consistency; no language execution.',
                  checks=checks, listing_files=file_count, fixture_cases=fixture_count, errors=errors,
                  metrics='CURRENT_FULL_SOURCE', measured_examples=len(data['examples']), paired_totals=totals,
                  sbcl_runtime='NOT_RUN', lmx_parser='NOT_RUN', lmx_runtime='NOT_RUN')
    (ROOT / 'validation/workflow_source_checks.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 1 if errors else 0


if __name__ == '__main__':
    raise SystemExit(main())

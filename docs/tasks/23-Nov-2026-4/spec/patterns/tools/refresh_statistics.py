#!/usr/bin/env python3
"""Refresh complete-source statistics without rewriting authored comparisons.

--metadata-only refreshes current listing metrics and the aggregate JSON report.
The default additionally delegates generated summary Markdown/CSV publication to
build_publication_data.py --text. That shared publisher owns both complete LMX
style columns. Per-case prose, source listings, PDF/XLSX and historical receipts
are never rewritten here. No language runtime is executed.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys

from lmx_style_variants import LEGACY_ROLE, STYLES, measure, normalize, validate_variants

ROOT = Path(__file__).resolve().parents[1]
DATE = '2026-11-23'
MARKER = '# BEGIN PROCEDURAL LMX (excluded from character counts)'
ALTERNATIVE_MARKER = '# BEGIN ALTERNATIVE LMX (excluded from character counts)'
LAYERS = ('scenario', 'usage', 'shared_implementation_client', 'implementation')
METRIC_KEYS = ('characters', 'nonblank_lines', 'utf8_bytes')
METHOD = (
    'Complete nonwhitespace Unicode codepoints, nonblank lines and UTF-8 bytes; '
    'all declarations, Throws arguments and copy references are included. '
    'Where lmx_variants are declared, procedural and functional are both compared '
    'under one contract; their compatibility LMX listing is not a third comparison. '
    'Equal minimal forms share one physical source and retain both style metrics. '
    'Implementation comparisons use one common body with dependencies counted '
    'separately. Other published controls retain their declared comparison scope. '
    'No size-based style selection, runtime execution or performance claim.'
)


def canon(text):
    return normalize(text)


def metrics(text):
    """Keep the existing four-key compatibility metric shape, with full source."""
    full = measure(text)
    return {key: full[key] for key in (*METRIC_KEYS, 'sha256')}


def primary(path):
    return canon(path.read_text().split(MARKER)[0].split(ALTERNATIVE_MARKER)[0])


def order(record):
    return (record.get('paired_with', record['id']),
            record.get('kind', 'pattern') == 'implementation', record['id'])


def read_json(path):
    return json.loads(path.read_text())


def write_json(path, value):
    text = json.dumps(value, ensure_ascii=False, indent=2) + '\n'
    if path.exists() and path.read_text() == text:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)
    return True


def style_metadata(record, directory):
    """Reference both complete sources without duplicating their code in a report."""
    errors = validate_variants(record, directory, procedural_restrictions=False)
    if errors:
        raise ValueError(f'{directory}/{record["id"]}: ' + '; '.join(errors))
    return {
        style: {
            **{key: value for key, value in record['lmx_variants'][style].items()
               if key not in {'code', 'metrics'}},
            'metrics': measure(record['lmx_variants'][style]['code']),
        }
        for style in STYLES
    }


def add_style_fields(target, record, directory):
    target['lmx_variants'] = style_metadata(record, directory)
    target['lmx_comparison_variants'] = list(STYLES)
    target['lmx_legacy_role'] = LEGACY_ROLE
    target['style_relation'] = record['style_relation']
    target['style_note'] = record.get('style_note', '')


def empty_totals(languages):
    return {layer: {language: {key: 0 for key in METRIC_KEYS}
                    for language in languages} for layer in LAYERS}


def build_metadata(root=ROOT):
    """Read primary sources and return the report plus permitted metadata writes."""
    root = Path(root)
    report = {
        'date': DATE, 'method': METHOD, 'groups': [], 'variant_selection': [],
        'compatibility_listing_role': LEGACY_ROLE,
    }
    writes = []
    flat = []
    compatibility_count = compared_count = 0
    for path in sorted(root.glob('[0-9][0-9]_*/patterns.json')):
        data = read_json(path)
        directory = path.parent
        languages = ['LMX', *data['languages']]
        group = {'directory': directory.name, 'title': data['group_title_ru'],
                 'languages': languages, 'records': []}
        totals = empty_totals(languages)
        style_totals = empty_totals(STYLES)
        style_cases = 0
        group_compared = 0
        for record in sorted(data['patterns'], key=order):
            layer = ('implementation' if record.get('kind') == 'implementation' else
                     'shared_implementation_client'
                     if record.get('comparison_level') == 'shared_implementation_client' else
                     'usage' if record.get('implementation_ids') else 'scenario')
            source = f'{record["id"]:03d}_{record["slug"]}_comparision.md'
            row = {'id': record['id'], 'name': record['name'], 'layer': layer,
                   'kind': record.get('kind', 'pattern'),
                   'source': directory.name + '/' + source,
                   'implementation_ids': record.get('implementation_ids', []),
                   'usage_ids': record.get('usage_ids', []), 'metrics': {}}
            styled = bool(record.get('lmx_variants'))
            if styled:
                add_style_fields(row, record, directory)
                style_cases += 1
                for style in STYLES:
                    for key in METRIC_KEYS:
                        style_totals[layer][style][key] += row['lmx_variants'][style]['metrics'][key]
            for listing in record['listings']:
                language = listing['language']
                full = metrics(listing['code'])
                listing['metrics'] = full
                row['metrics'][language] = full
                for key in METRIC_KEYS:
                    totals[layer][language][key] += full[key]
                variants = record.get('variants', {}).get(language, {})
                if styled and language == 'LMX':
                    functional = record['lmx_variants']['functional']['code']
                    if canon(listing['code']) != canon(functional):
                        raise ValueError(f'{directory.name}/{record["id"]}: LMX compatibility mirror differs')
                    sizes = {style: row['lmx_variants'][style]['metrics']['characters']
                             for style in STYLES}
                    eligible = list(STYLES)
                    role = LEGACY_ROLE
                elif variants:
                    sizes = {name: metrics(code)['characters'] for name, code in variants.items()}
                    eligible = record.get('eligible_variants', {}).get(language, list(sizes))
                    role = 'published_control_under_declared_scope'
                else:
                    continue
                selection = {
                    'group': directory.name, 'id': record['id'], 'language': language,
                    'primary': record.get('primary_variant', {}).get(language,
                                listing.get('primary_variant', 'published')),
                    'eligible_variants': eligible,
                    'fairness_note': record.get('fairness_notes', {}).get(language, ''),
                    'characters': sizes, 'selected_characters': full['characters'],
                    'primary_role': role,
                }
                if styled and language == 'LMX':
                    selection['comparison_variants'] = list(STYLES)
                    selection['selection_policy'] = 'Both complete styles are compared; primary identifies only the compatibility mirror.'
                report['variant_selection'].append(selection)
            group['records'].append(row)
            flat.append(row)
            compatibility_count += len(record['listings'])
            group_compared += len(record['listings']) + int(styled)
        group['totals'] = totals
        group['pattern_count'] = sum(row['kind'] == 'pattern' for row in group['records'])
        group['implementation_count'] = sum(row['kind'] == 'implementation' for row in group['records'])
        group['compared_listing_count'] = group_compared
        if style_cases:
            group['lmx_style_clients'] = style_cases
            group['lmx_style_totals'] = style_totals
        compared_count += group_compared
        report['groups'].append(group)
        writes.append((path, data))
    report['pattern_count'] = sum(group['pattern_count'] for group in report['groups'])
    report['implementation_count'] = sum(group['implementation_count'] for group in report['groups'])
    # Retain the old key for its actual compatibility-row count; do not count it
    # in addition to the compared style listings.
    report['primary_listing_count'] = compatibility_count
    report['compatibility_listing_count'] = compatibility_count
    report['compared_listing_count'] = compared_count

    by_id = {row['id']: row for row in flat}
    shared = {}
    for row in flat:
        if row['layer'] == 'shared_implementation_client':
            for implementation_id in row['implementation_ids']:
                shared.setdefault(implementation_id, []).append(row['id'])
    components = []
    for implementation_id, usage_ids in sorted(shared.items()):
        helper = by_id[implementation_id]
        costs = {}
        independent = []
        for language, helper_metrics in helper['metrics'].items():
            clients = sum(by_id[ident]['metrics'][language]['characters'] for ident in usage_ids)
            costs[language] = {'helper_once': helper_metrics['characters'], 'clients': clients,
                               'complete_component': helper_metrics['characters'] + clients}
            for ident in usage_ids:
                client = by_id[ident]['metrics'][language]['characters']
                independent.append({'usage_id': ident, 'language': language,
                                    'client_characters': client,
                                    'helper_characters': helper_metrics['characters'],
                                    'complete_component_characters': helper_metrics['characters'] + client})
        components.append({'implementation_id': implementation_id, 'usage_ids': sorted(usage_ids),
                           'helper_source': helper['source'], 'costs': costs,
                           'individual_client_plus_helper': independent})
    report['shared_implementation_components'] = components

    root_styles = {}
    variant_path = root / 'examples/variants.json'
    if variant_path.is_file():
        for record in read_json(variant_path)['records']:
            if not record.get('lmx_variants'):
                continue
            source = record['lmx_variants']['functional']['source_file']
            if source in root_styles:
                raise ValueError(f'Duplicate root compatibility source: {source}')
            root_styles[source] = record
    examples = []
    for path in sorted((root / 'examples/lmx').glob('*.lm3')):
        row = {'id': path.stem, 'source': path.relative_to(root).as_posix(),
               **metrics(primary(path)),
               'procedural_archived': MARKER in path.read_text() or ALTERNATIVE_MARKER in path.read_text()}
        source = path.relative_to(root / 'examples').as_posix()
        if source in root_styles:
            add_style_fields(row, root_styles[source], root / 'examples')
        examples.append(row)
    report['root_examples'] = examples
    for name in ('functional_receiver_counts.json', 'receiver_library_counts.json'):
        path = root / 'examples/validation' / name
        if path.exists():
            report[name.removesuffix('.json')] = read_json(path)
    path = root / '09_functional_computation/implementation_dependencies.json'
    if path.exists():
        report['functional_library_dependencies'] = read_json(path)

    fences = {'lmx': 'LMX', 'python': 'Python', 'java': 'Java', 'cpp': 'C++',
              'csharp': 'C#', 'typescript': 'TypeScript', 'go': 'Go', 'rust': 'Rust'}
    gof = []
    for path in sorted(root.glob('[0-9][0-9]_*_comparison.md')):
        text = path.read_text()
        seen = {}
        for match in re.finditer(r'^```([^\n]*)\n([\s\S]*?)^```\s*$', text, re.M):
            language = fences.get(match.group(1).strip())
            if not language or language in seen:
                continue
            if '<!-- uncounted-code:' in text[max(0, match.start()-120):match.start()]:
                continue
            code = canon(match.group(2))
            seen[language] = {**metrics(code), 'total_characters': len(code),
                              'physical_lines': len(code.splitlines())}
        if len(seen) != 8:
            raise ValueError(f'{path}: expected eight declared language listings, found {len(seen)}')
        gof.append({'file': path.name, 'metrics': seen})
    report['gof'] = {'comparisons': len(gof), 'listings': 8 * len(gof), 'records': gof,
                     'total_characters': {language: sum(row['metrics'][language]['characters'] for row in gof)
                                          for language in fences.values()}}
    library = root / 'LMX_Fn_Receivers'
    assembled = (library / 'LMX_Receivers.lmx').read_bytes()
    report['receiver_library'] = {
        'public_receivers': len(read_json(library / 'catalog.json')),
        'assembled': metrics(assembled.decode('utf-8')),
        'assembled_file_utf8_bytes': len(assembled),
        'assembled_file_sha256': hashlib.sha256(assembled).hexdigest(),
        'runtime_executed': False,
    }
    writes.append((root / 'validation/statistics_20261122.json', report))
    return report, writes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--metadata-only', action='store_true',
                        help='Refresh only current JSON metrics; keep prose, model and every exported file unchanged')
    args = parser.parse_args()
    report, writes = build_metadata()
    # Validate all inputs before publishing any of the prepared metadata changes.
    changed = [path.relative_to(ROOT).as_posix() for path, value in writes if write_json(path, value)]
    if not args.metadata_only:
        subprocess.run([sys.executable, str(ROOT / 'tools/build_publication_data.py'), '--text'], check=True)
    print(json.dumps({'status': 'PASS', 'mode': 'metadata_only' if args.metadata_only else 'metadata_and_shared_summary_text',
                      'groups': len(report['groups']),
                      'comparisons': sum(len(group['records']) for group in report['groups']),
                      'compatibility_listings': report['compatibility_listing_count'],
                      'compared_listings': report['compared_listing_count'],
                      'gof_comparisons': report['gof']['comparisons'],
                      'root_examples': len(report['root_examples']), 'changed_metadata': changed,
                      'lmx_runtime_execution': 'NOT_RUN'}, ensure_ascii=False))


if __name__ == '__main__':
    main()

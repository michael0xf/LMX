#!/usr/bin/env python3
"""Validate the current source packet and publication, without executing LMX.

Record identities, language pairs and measurement boundaries are discovered from
current metadata. Historical receipts and earlier migration approvals are not
acceptance criteria. The immutable uploaded spec is used only to prove that the
original Haskell-suite LMX sources survived the directory move byte for byte.
"""
from __future__ import annotations

import argparse
from collections import Counter
import csv
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
from canonical_operations import definitions
from lmx_style_variants import STYLES, measure, normalize, source_files, validate_variants

DEFAULT_BASELINE = Path('/workspace/scratch/9db6626f6828/work/LMX_uploaded_20261124_d88d7732/spec')
LANG = {
    'LMX': ('lmx', 'lm3'), 'Python': ('python', 'py'), 'C++': ('cpp', 'cpp'),
    'Java': ('java', 'java'), 'JavaScript': ('javascript', 'js'),
    'TypeScript': ('typescript', 'ts'), 'C#': ('csharp', 'cs'), 'Go': ('go', 'go'),
    'Rust': ('rust', 'rs'), 'Erlang': ('erlang', 'erl'),
    'Haskell': ('haskell', 'hs'), 'Scala': ('scala', 'scala'),
}
TAGS = {'lmx': 'LMX', 'python': 'Python', 'cpp': 'C++', 'c++': 'C++',
        'java': 'Java', 'javascript': 'JavaScript', 'typescript': 'TypeScript',
        'csharp': 'C#', 'go': 'Go', 'rust': 'Rust', 'erlang': 'Erlang',
        'haskell': 'Haskell', 'scala': 'Scala', 'julia': 'Julia', 'perl': 'Perl',
        'lisp': 'Common Lisp / SBCL', 'common-lisp': 'Common Lisp / SBCL'}
IDENTIFIER = r'(?:[A-Za-z_][A-Za-z0-9_]*|`(?:``|[^`\x00])+`)'
METRIC_FIELDS = ('characters', 'characters_with_whitespace', 'nonblank_lines', 'utf8_bytes', 'sha256')


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def identifier(text):
    return text[1:-1].replace('``', '`') if text.startswith('`') else text


def fences(text):
    return [(match[1].strip().lower(), normalize(match[2])) for match in
            re.finditer(r'^```([^\n]*)\n(.*?)^```[ \t]*$', text, re.M | re.S)]


def import_file(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def listing_paths(item):
    paths = item.get('source_files')
    if isinstance(paths, dict):
        return paths
    return {'lmx': item.get('lmx_file'), 'foreign': item.get('foreign_file')}


class Validator:
    def __init__(self, patterns, baseline):
        self.patterns = patterns.resolve()
        self.spec = self.patterns.parent
        self.examples = self.patterns / 'examples'
        self.baseline = baseline.resolve()
        self.checks = []
        self.errors = []
        self.warnings = []
        self.summary = {}
        self.cases = {}
        self.implementations = {}
        self.measured_files = set()

    def check(self, ok, label, details=None):
        row = {'check': label, 'status': 'PASS' if ok else 'FAIL'}
        if details is not None and (not ok or isinstance(details, str)):
            row['details'] = details
        self.checks.append(row)
        if not ok:
            self.errors.append(row.copy())
        return bool(ok)

    def text(self, path):
        path = Path(path)
        try:
            return path.read_text(encoding='utf-8')
        except (OSError, UnicodeError) as exc:
            self.check(False, 'Readable UTF-8 file: ' + str(path), str(exc))
            return ''

    def read(self, path):
        try:
            return json.loads(self.text(path))
        except (TypeError, ValueError) as exc:
            self.check(False, 'Valid JSON: ' + str(path), str(exc))
            return {}

    def csv(self, path):
        text = self.text(path).lstrip('\ufeff')
        return list(csv.DictReader(text.splitlines()))

    def metric(self, recorded, code, label, schema='full'):
        actual = measure(code)
        aliases = {'characters_nonwhitespace': 'characters', 'characters_without_whitespace': 'characters',
                   'nonwhitespace': 'characters', 'characters_all': 'characters_with_whitespace',
                   'total_characters': 'characters_with_whitespace', 'bytes_utf8': 'utf8_bytes',
                   'non_whitespace_characters': 'characters', 'nonempty_lines': 'nonblank_lines'}
        if schema in ('perl', 'haskell_listing'):
            aliases['characters'] = 'characters_with_whitespace'
        self.check(bool(recorded), label + ': metric present')
        for key, value in recorded.items():
            dest = aliases.get(key, key)
            if dest in actual:
                self.check(value == actual[dest], label + ': ' + key,
                           {'recorded': value, 'actual': actual[dest]})
        return actual

    def boundary(self, directory, names, code, label):
        names = [names] if isinstance(names, str) else list(names or [])
        self.check(bool(names), label + ': explicit source boundary')
        paths = [(directory / name).resolve() for name in names]
        self.check(len(set(paths)) == len(paths), label + ': no source counted twice')
        parts = [self.text(path) for path in paths]
        self.measured_files.update(str(path) for path in paths)
        complete = normalize('\n\n'.join(part.rstrip() for part in parts))
        self.check(complete == normalize(code), label + ': physical sources equal JSON',
                   {'sources': names, 'physical_sha256': measure(complete)['sha256'],
                    'json_sha256': measure(code)['sha256']})
        return parts

    def visible(self, page, code, parts=None, label=None):
        """Whole code or each declared fragment must be visible in linked Markdown.

        One local Markdown link level permits a shared helper to be published
        once, for example GraphCopy. Merely linking a source file is insufficient.
        """
        text = self.text(page)
        blocks = {body for _, body in fences(text)}
        if normalize(code) not in blocks and parts:
            for target in re.findall(r'\]\(([^)]+\.md(?:#[^)]*)?)\)', text):
                path = (page.parent / target.split('#')[0]).resolve()
                if path.is_file() and path.is_relative_to(self.spec):
                    blocks.update(body for _, body in fences(self.text(path)))
        ok = normalize(code) in blocks or bool(parts) and all(normalize(p) in blocks for p in parts)
        self.check(ok, (label or str(page)) + ': complete Markdown body/fragments')

    def numeric_table(self, page, expected):
        """Check numeric columns of a scenario's local source-size table."""
        found = set()
        headers = None
        for line in self.text(page).splitlines():
            if not line.startswith('|'):
                headers = None
                continue
            cells = [re.sub(r'<[^>]+>', '', cell).replace('**', '').strip()
                     for cell in line.strip().strip('|').split('|')]
            if any('символ' in c.lower() or 'пробель' in c.lower() for c in cells):
                headers = cells
                continue
            if not headers or len(cells) != len(headers):
                continue
            name = re.sub(r'[—–\-]', ' ', cells[0]).lower()
            if 'lmx' in name:
                key = ('procedural' if 'процедур' in name else
                       'functional' if 'функцион' in name else 'LMX')
            else:
                key = next((k for k in expected if k.lower() == name or
                            k == 'Common Lisp / SBCL' and ('lisp' in name or 'sbcl' in name)), None)
            if key not in expected:
                continue
            for index, header in enumerate(headers[1:], 1):
                low = header.lower()
                field = ('characters' if 'непробел' in low or 'без пробел' in low else
                         'characters_with_whitespace' if 'символ' in low else
                         'nonblank_lines' if 'строк' in low else
                         'utf8_bytes' if 'байт' in low else None)
                if field:
                    value = cells[index]
                    self.check(value.isdigit() and int(value) == expected[key][field],
                               f'{page.name}: Markdown {key}/{field}',
                               {'recorded': value, 'actual': expected[key][field]})
                    found.add(key)
        self.check(set(expected) <= found, page.name + ': numeric rows cover all compared forms',
                   {'missing': sorted(set(expected) - found)})

    def styles(self, item, directory, page, suite, ident, foreign, status='complete_pair'):
        label = f'{suite}/{ident}'
        try:
            issues = validate_variants(item, directory)
        except (OSError, ValueError, KeyError, TypeError) as exc:
            issues = [str(exc)]
        self.check(not issues, label + ': validate_variants', issues)
        measured = {}
        for style in STYLES:
            variant = item.get('lmx_variants', {}).get(style, {})
            if not self.check(bool(variant), label + ': ' + style + ' present'):
                continue
            code = variant.get('code', '')
            parts = self.boundary(directory, source_files(variant), code, label + '/' + style)
            self.visible(page, code, parts, label + '/' + style)
            measured[style] = self.metric(variant.get('metrics', {}), code, label + '/' + style)
            self.check(variant.get('runtime_execution') == 'NOT_RUN', label + '/' + style + ': LMX execution not claimed')
        self.check(status in {'complete_pair', 'related_analogy', 'lmx_only'}, label + ': comparability status')
        self.check(status != 'complete_pair' or bool(foreign), label + ': complete pair has control source')
        self.check((suite, str(ident)) not in self.cases, label + ': unique styled contract')
        self.cases[(suite, str(ident))] = {'lmx_variants': measured, 'foreign': foreign,
                                        'comparison_status': status}
        return measured

    def core(self):
        library = self.patterns / 'LMX_Fn_Receivers'
        catalog = self.read(library / 'catalog.json')
        if not isinstance(catalog, list):
            self.check(False, 'Core catalog is a list')
            return
        try:
            self.definitions = definitions(library)
            self.check(True, 'Core physical top-level definitions are unique')
        except (ValueError, OSError) as exc:
            self.definitions = {}
            self.check(False, 'Core physical top-level definitions are unique', str(exc))
        names = [entry['name'] for entry in catalog]
        self.check(len(names) == len(set(names)), 'Core public catalog names are unique')
        public = self.text(library / 'src/public.lmx')
        matches = re.findall(r'^\s+@:\s+(' + IDENTIFIER + r')\s+(' + IDENTIFIER +
                             r'(?:\\' + IDENTIFIER + r')+)\s*$', public, re.M)
        exports = [(identifier(name), api) for name, api in matches]
        self.check(len(exports) == len(set(name for name, _ in exports)), 'Core physical exports are unique')
        expected = {entry['name']: entry['api'] for entry in catalog}
        self.check(dict(exports) == expected, 'Core public exports equal catalog targets',
                   {'catalog_only': sorted(set(expected) - {x[0] for x in exports}),
                    'exports_only': sorted({x[0] for x in exports} - set(expected))})
        for entry in catalog:
            label = 'core/' + entry['name']
            self.check((library / entry['source']).is_file(), label + ': source exists')
            root = identifier(entry['api'].split('\\')[0])
            self.check(root in self.definitions, label + ': API root exists')
            self.check(entry.get('lmx_executed') is False, label + ': LMX execution not claimed')
            for owner, forms in [('public', entry.get('forms', {}))] + [
                    (v.get('family', 'variant'), {key: v.get(key) for key in ('call', 'operand')})
                    for v in entry.get('variants', [])]:
                for form in ('call', 'operand'):
                    value = forms.get(form) or {}
                    target = value.get('target', '')
                    self.check(bool(target) and bool(value.get('route')), f'{label}/{owner}/{form}: target and route')
                    self.check(identifier(target.split('\\')[0]) in self.definitions,
                               f'{label}/{owner}/{form}: physical target root')
            for variant in entry.get('variants', []):
                self.check((library / variant['source']).is_file(), label + ': variant source exists')
                self.check(identifier(variant['api'].split('\\')[0]) in self.definitions,
                           label + ': variant API root exists')
        try:
            module = import_file('current_packet_core_assemble', library / 'tools/assemble.py')
            module.ROOT = library
            self.check(len(module.PARTS) == len(set(module.PARTS)), 'Core assembly has no duplicate source part')
            self.check(self.text(library / 'LMX_Receivers.lmx') == module.assembled(),
                       'Core assembly exactly equals current ordered sources')
        except (OSError, ValueError, KeyError) as exc:
            self.check(False, 'Core assembly can be reproduced', str(exc))
        self.summary['core'] = {'public_names': len(names), 'physical_definitions': len(self.definitions),
                                'canonical_variants': sum(len(e.get('variants', [])) for e in catalog)}

    def groups(self):
        records = []; count = 0
        for path in sorted(self.patterns.glob('[0-9][0-9]_*/patterns.json')):
            data = self.read(path); directory = path.parent; count += 1
            csv_rows = self.csv(directory / ('LMX_Comparison_' + directory.name + '.csv'))
            by_id = {int(row['id']): row for row in csv_rows}
            self.check(len(by_id) == len(csv_rows), directory.name + ': CSV IDs unique')
            ids = []
            for record in data.get('patterns', []):
                ident = record['id']; ids.append(ident); label = f'{directory.name}/{ident:03d}'
                pair = record.get('languages', data['languages'])
                self.check(len(pair) == len(set(pair)) == 2, label + ': exactly two distinct control languages')
                listings = {x['language']: x for x in record['listings']}
                self.check(len(listings) == len(record['listings']) and set(listings) == {'LMX', *pair},
                           label + ': one listing for each declared language')
                filename = record.get('source') or record.get('comparison_file') or f"{ident:03d}_{record['slug']}_comparision.md"
                page = directory / filename; metrics = {}; table_metrics = {}
                for language, listing in listings.items():
                    code = listing['code']
                    names = listing.get('source_files') or [listing.get('source_file') or listing.get('source') or
                        f"examples/{LANG[language][0]}/{ident:03d}_{record['slug']}.{LANG[language][1]}"]
                    parts = self.boundary(directory, names, code, label + '/' + language)
                    self.visible(page, code, parts, label + '/' + language)
                    metrics[language] = self.metric(listing.get('metrics', {}), code, label + '/' + language)
                if record.get('lmx_variants'):
                    suite = directory.name if data.get('language_pairing') == 'per_record' or data.get('language_pairs_scope') else 'functional'
                    styles = self.styles(record, directory, page, suite, f'{ident:03d}', {key: metrics[key] for key in pair})
                    self.check(normalize(listings['LMX']['code']) == normalize(record['lmx_variants']['functional']['code']),
                               label + ': functional compatibility mirror')
                    table_metrics.update(styles)
                    csv_metrics = {'LMX_' + key: value for key, value in styles.items()}
                else:
                    table_metrics['LMX'] = metrics['LMX']
                    csv_prefix = 'LMX_implementation' if record.get('kind') == 'implementation' else 'LMX'
                    csv_metrics = {csv_prefix: metrics['LMX']}
                table_metrics.update({key: metrics[key] for key in pair})
                self.numeric_table(page, table_metrics)
                csv_metrics.update({key: metrics[key] for key in pair})
                row = by_id.get(ident, {})
                self.check(row.get('source') == filename, label + ': CSV source path')
                self.check([row.get('language_1'), row.get('language_2')] == pair, label + ': CSV per-record language pair')
                for column, value in row.items():
                    field = next((f for f in METRIC_FIELDS if column.endswith('_' + f)), None)
                    if field:
                        prefix = column[:-len(field)-1]
                        actual = str(csv_metrics[prefix][field]) if prefix in csv_metrics else ''
                        self.check(value == actual, label + ': CSV ' + column, {'recorded': value, 'actual': actual})
                records.append({'id': ident, 'directory': directory.name, 'kind': record.get('kind', 'pattern'),
                                'languages': pair, 'metrics': metrics})
            self.check(len(ids) == len(set(ids)) and set(ids) == set(by_id), directory.name + ': JSON/CSV record identities')
        self.check(len({r['id'] for r in records}) == len(records), 'Grouped record IDs are globally unique')
        manifest = self.read(self.patterns / 'comparison_sources/catalog_manifest.json')
        current = {(r['directory'], r['id']) for r in records}
        listed = {(r['directory'], r['id']) for r in manifest.get('comparisons', [])}
        self.check(current == listed and len(listed) == len(manifest.get('comparisons', [])), 'Catalog manifest covers all current grouped records')
        for kind, key in [('pattern', 'pattern_ids'), ('algorithm', 'algorithm_ids'), ('implementation', 'implementation_ids')]:
            self.check(set(manifest.get(key, [])) == {r['id'] for r in records if r['kind'] == kind}, 'Catalog manifest ' + key)
        self.summary['groups'] = {'groups': count, 'records': len(records),
                                  'compared_primary_listings': sum(len(r['metrics']) for r in records)}

    def haskell(self):
        directory = self.examples / 'haskell_comparision'
        index = self.read(directory / 'comparison_index.json')
        baseline_index = self.read(self.baseline / 'patterns/examples/haskell/comparison_index.json')
        original = {item['id']: item for item in baseline_index.get('entries', [])}
        entries = index.get('entries', [])
        self.check({item['id'] for item in entries} == set(original), 'Haskell current/baseline contract identities')
        preserved = {}; seen_files = set(); statuses = Counter()
        for item in entries:
            ident = item['id']; label = 'haskell/' + ident
            page = self.examples / item['lmx_style_comparison']
            names = item.get('foreign_measurement_sources') or [item['foreign_source']]
            foreign = item.get('foreign_measurement_code', item['foreign_code'])
            parts = self.boundary(self.examples, names, foreign, label + '/Haskell complete')
            self.boundary(self.examples, item['foreign_source'], item['foreign_code'], label + '/Haskell entry')
            self.visible(page, foreign, parts, label + '/Haskell')
            measured = self.metric(item.get('foreign_full_metrics', {}), foreign, label + '/Haskell full metric')
            self.metric(item.get('foreign_listing_metrics', {}), item['foreign_code'], label + '/Haskell entry metric', 'haskell_listing')
            styles = self.styles(item, self.examples, page, 'haskell', ident, measured, item['status'])
            self.numeric_table(page, {**styles, 'Haskell': measured})
            statuses[item['status']] += 1
            self.check(item.get('pair_ratio_eligible') == (item['status'] == 'complete_pair'), label + ': ratio eligibility')
            self.check(sha(self.text(self.examples / item['lmx_source']).encode()) == item['lmx_source_sha256'], label + ': LMX source hash')
            self.check(sha(item['foreign_code'].encode()) == item['foreign_listing_sha256'], label + ': Haskell entry hash')
            for style in STYLES:
                old = original.get(ident, {}).get('lmx_variants', {}).get(style, {})
                now = item['lmx_variants'][style]
                old_names = source_files(old) if old else []
                now_names = source_files(now)
                self.check(len(old_names) == len(now_names), label + '/' + style + ': baseline boundary cardinality')
                for old_name, new_name in zip(old_names, now_names):
                    before = self.baseline / 'patterns/examples' / old_name
                    after = self.examples / new_name
                    old_bytes = before.read_bytes() if before.is_file() else None
                    new_bytes = after.read_bytes() if after.is_file() else None
                    ok = old_bytes is not None and new_bytes == old_bytes
                    self.check(ok, label + '/' + style + ': immutable uploaded LMX bytes preserved',
                               {'before': old_name, 'after': new_name})
                    seen_files.add(str(after.resolve()))
                    preserved[str(before.resolve())] = {'baseline': old_name, 'current': new_name,
                        'sha256': sha(old_bytes) if old_bytes is not None else None, 'preserved': ok}
        self.check(len(preserved) == len(seen_files), 'Haskell move preserves one physical file per original source')
        self.summary['haskell'] = {'contracts': len(entries), 'statuses': dict(statuses),
            'preserved_lmx_physical_files': len(preserved), 'all_preserved': all(r['preserved'] for r in preserved.values()),
            'baseline_index_sha256': sha(self.text(self.baseline / 'patterns/examples/haskell/comparison_index.json').encode()),
            'sources': list(preserved.values())}

    def suites(self):
        suite_summary = {}
        for suite, dirname, language in [('julia', 'julia_comparison', 'Julia'), ('perl', 'perl_comparison', 'Perl'),
                                         ('sbcl', 'SBCL_comparison', 'Common Lisp / SBCL')]:
            directory = self.examples / dirname; data = self.read(directory / 'examples.json')
            impl_file = directory / 'implementation_data.json'
            impls = self.read(impl_file).get('implementations', []) if impl_file.exists() else data.get('implementations', [])
            expected_csv = {}; expected_stats = {}
            for item in data.get('examples', []):
                ident = item['id']; label = suite + '/' + ident; paths = listing_paths(item)
                page = directory / (ident + '_comparision.md')
                parts = self.boundary(directory, paths['foreign'], item['foreign'], label + '/foreign')
                self.visible(page, item['foreign'], parts, label + '/foreign')
                foreign = measure(item['foreign'])
                styles = self.styles(item, directory, page, suite, ident, foreign, item.get('comparison_status', 'complete_pair'))
                self.check(normalize(item['lmx']) == normalize(item['lmx_variants']['functional']['code']), label + ': functional compatibility mirror')
                self.numeric_table(page, {**styles, language: foreign})
                for style, metric in {**styles, 'foreign': foreign}.items():
                    csv_style = ('lmx_' + style if style in STYLES else 'foreign') if suite == 'sbcl' else style
                    expected_csv[('client', ident, csv_style)] = metric
                    expected_stats[(ident, style)] = metric
                if item.get('counts'):
                    for name, metric in item['counts'].items():
                        code = item['lmx_variants'][name[4:]]['code'] if name.startswith('lmx_') else item[name]
                        self.metric(metric, code, label + '/counts/' + name, 'perl' if suite == 'perl' else 'full')
            for item in impls:
                ident = item['id']; label = suite + '/' + ident; paths = listing_paths(item)
                page = directory / 'library_comparisons' / (ident + '_comparision.md')
                measured = {}
                for key in ('lmx', 'foreign'):
                    parts = self.boundary(directory, paths[key], item[key], label + '/' + key)
                    self.visible(page, item[key], parts, label + '/' + key)
                    measured[key] = measure(item[key])
                    csv_key = key if suite == 'sbcl' else 'LMX' if key == 'lmx' else data['foreign_language']
                    expected_csv[('implementation', ident, csv_key)] = measured[key]
                self.implementations[(suite, ident)] = measured
            rows = self.csv(directory / 'statistics.csv'); observed = {}
            for row in rows:
                key = (row['scope'], row['id'], row.get('style') if row['scope'] == 'client' and suite != 'sbcl' else row['language'])
                self.check(key not in observed, f'{suite}: CSV unique {key}')
                observed[key] = row
                expected = expected_csv.get(key)
                self.check(expected is not None, f'{suite}: CSV record {key} belongs to current sources')
                if expected:
                    for field in METRIC_FIELDS:
                        column = {'characters': 'characters_nonwhitespace', 'characters_with_whitespace': 'characters_all'}.get(field, field) if suite == 'sbcl' else field
                        self.check(row.get(column) == str(expected[field]), f'{suite}: CSV {key}/{column}')
            self.check(set(observed) == set(expected_csv), suite + ': CSV covers all styles and implementations once')
            stats = self.read(directory / 'statistics.json')
            if suite == 'sbcl':
                for row in stats.get('examples', []):
                    for style in STYLES:
                        self.metric(row.get('lmx_' + style, {}), next(x for x in data['examples'] if x['id'] == row['id'])['lmx_variants'][style]['code'], f'{suite}/{row["id"]}: statistics/{style}')
                    self.metric(row.get('foreign', {}), next(x for x in data['examples'] if x['id'] == row['id'])['foreign'], f'{suite}/{row["id"]}: statistics/foreign')
            else:
                got = {(row['id'], row['style']): row for row in stats.get('comparison_rows', [])}
                self.check(set(got) == set(expected_stats), suite + ': statistics rows cover current styles')
                for key, expected in expected_stats.items():
                    self.check(all(got.get(key, {}).get(field) == value for field, value in expected.items()), f'{suite}: statistics exact full metric {key}')
            suite_summary[suite] = {'clients': len(data.get('examples', [])), 'implementations': len(impls), 'csv_rows': len(rows)}
        self.summary['suites'] = suite_summary

    def gof_and_shared(self):
        data = self.read(self.patterns / 'validation/gof_statistics_20261122.json')
        records = data.get('records', [])
        actual_pages = {p.name for p in self.patterns.glob('[0-9][0-9]_*_comparison.md')}
        self.check({row['file'] for row in records} == actual_pages, 'GoF statistics discover every current primary page')
        for row in records:
            blocks = [(TAGS[tag], code) for tag, code in fences(self.text(self.patterns / row['file'])) if tag in TAGS]
            measured = {}
            for language, code in blocks:
                if language in row['metrics'] and language not in measured:
                    measured[language] = self.metric(row['metrics'][language], code, 'GoF/' + row['file'] + '/' + language)
            self.check(set(measured) == set(row['metrics']), 'GoF complete language coverage: ' + row['file'])
        inventory = self.read(self.examples / 'validation/receiver_library_counts.json')
        for item in inventory.get('comparisons', []):
            page = self.examples / item['file']; blocks = fences(self.text(page))
            entry = next((code for tag, code in blocks if tag == 'lmx'), '')
            if item['entry'] == 'Cycles':
                complete = self.text(self.examples / 'libraries/lmx/Cycles.lm3')
            else:
                missing = set(item['roots']) - set(self.definitions)
                self.check(not missing, item['file'] + ': canonical dependency roots exist', sorted(missing))
                complete = normalize('\n\n'.join(self.definitions[name]['code'].rstrip() for name in item['roots'] if name in self.definitions))
            foreign = self.text(self.examples / item['haskell_source'])
            self.visible(page, foreign, [foreign], item['file'] + '/Haskell')
            self.metric(item.get('lmx_entry', {}), entry, item['file'] + '/entry')
            lm = self.metric(item.get('lmx', {}), complete, item['file'] + '/canonical closure')
            fm = self.metric(item.get('haskell', {}), foreign, item['file'] + '/Haskell')
            ident = Path(item['file']).stem.split('_')[0].upper()
            self.implementations[('haskell', ident)] = {'lmx': lm, 'foreign': fm}
        page = self.examples / 'library_comparisons/r01_derive_comparision.md'
        blocks = fences(self.text(page))
        self.implementations[('haskell', 'R01')] = {
            key: measure('\n'.join(code for tag, code in blocks if tag == language))
            for key, language in [('lmx', 'lmx'), ('foreign', 'haskell')]}
        self.summary['gof'] = {'comparisons': len(records), 'validation': 'Current embedded sources remeasured; historical receipt status ignored'}

    def root_statistics(self):
        stats = self.read(self.examples / 'STATISTICS.json')
        cases = {key: value for key, value in self.cases.items() if key[0] in {'haskell', 'julia', 'perl', 'sbcl'}}
        rows = {(row['suite'], row['id']): row for row in stats.get('examples', [])}
        self.check(set(rows) == set(cases) and len(rows) == len(stats.get('examples', [])), 'Root examples statistics contract identities')
        for key, expected in cases.items():
            row = rows.get(key, {})
            for field in ('lmx_variants', 'foreign', 'comparison_status'):
                self.check(row.get(field) == expected[field], f'Root statistics {key}/{field}')
            for style in STYLES:
                ratio = expected['foreign']['characters'] / expected['lmx_variants'][style]['characters'] if expected['comparison_status'] == 'complete_pair' else None
                self.check(row.get('ratios', {}).get(style) == ratio, f'Root statistics {key}/{style} ratio')
        impls = {(row['suite'], row['id']): row for row in stats.get('implementations', [])}
        self.check(set(impls) == set(self.implementations) and len(impls) == len(stats.get('implementations', [])), 'Root statistics implementation identities')
        for key, expected in self.implementations.items():
            for field in ('lmx', 'foreign'):
                self.check(impls.get(key, {}).get(field) == expected[field], f'Root statistics implementation {key}/{field}')
        refresher = import_file('current_packet_statistics', self.examples / 'tools/refresh_examples_statistics.py')
        self.check(stats.get('summaries') == refresher.summarize(stats.get('examples', []), stats.get('implementations', [])), 'Root statistics source-derived suite totals')
        for key, expected in [('lmx_examples', len(cases)), ('lmx_style_listings', 2 * len(cases)), ('implementation_comparisons', len(impls))]:
            self.check(stats.get('counts', {}).get(key) == expected, 'Root statistics count: ' + key)
        haskell_stats = self.read(self.examples / 'haskell_comparision/statistics.json')
        self.check(haskell_stats.get('examples') == [r for r in stats.get('examples', []) if r['suite'] == 'haskell'], 'Haskell own statistics agree with root')
        hs_csv = self.csv(self.examples / 'haskell_comparision/statistics.csv')
        self.check({r['id'] for r in hs_csv} == {key[1] for key in cases if key[0] == 'haskell'}, 'Haskell CSV coverage')
        for row in hs_csv:
            expected = cases[('haskell', row['id'])]
            for style in STYLES:
                for field in ('characters', 'nonblank_lines'):
                    self.check(row['LMX_' + style + '_' + field] == str(expected['lmx_variants'][style][field]), f'Haskell CSV {row["id"]}/{style}/{field}')
            for field in ('characters', 'nonblank_lines'):
                self.check(row['Haskell_' + field] == str(expected['foreign'][field]), f'Haskell CSV {row["id"]}/Haskell/{field}')
        inventory = self.read(self.examples / 'SOURCE_INVENTORY.json')
        actual_files = {p.relative_to(self.examples).as_posix() for p in self.examples.rglob('*') if p.is_file() and p.suffix in {'.lm3', '.lmx', '.hs', '.jl', '.pl', '.pm', '.lisp', '.cl'}}
        declared = {r['file'] for r in inventory.get('files', [])}
        self.check(actual_files == declared and len(declared) == len(inventory.get('files', [])), 'Source inventory current physical file identities')
        for row in inventory.get('files', []):
            self.metric(row.get('metrics', {}), self.text(self.examples / row['file']), 'Inventory/' + row['file'])
        self.summary['example_statistics'] = {'clients': len(cases), 'shared_implementation_pairs': len(impls), 'inventoried_files': len(declared)}

    def publication(self):
        path = self.patterns / 'PUBLICATION_DATA.json'; current = self.read(path)
        module = import_file('current_packet_publication', self.patterns / 'tools/build_publication_data.py')
        module.ROOT = self.patterns; module.EXAMPLES = self.examples
        expected = module.build()
        self.check(not expected.get('errors'), 'Publication builder source checks', expected.get('errors'))
        self.check(current == expected, 'PUBLICATION_DATA exactly equals read-only reconstruction',
                   {'different_top_level_keys': [key for key in set(current) | set(expected) if current.get(key) != expected.get(key)]})
        cases = {(row['suite'], row['id']): row for row in current.get('cases', [])}
        self.check(set(cases) == set(self.cases) and len(cases) == len(current.get('cases', [])), 'Publication covers all current styled contracts')
        for key, expected_case in self.cases.items():
            for field in ('lmx_variants', 'foreign', 'comparison_status'):
                self.check(cases.get(key, {}).get(field) == expected_case[field], f'Publication {key}/{field} equals physical source metrics')
        self.check(current.get('lmx_style_clients') == len(self.cases) and current.get('lmx_style_listings') == 2 * len(self.cases), 'Publication dynamic style counts')
        for field in ('lmx_parser_execution', 'lmx_runtime_execution'):
            self.check(current.get(field) == 'NOT_RUN', 'Publication ' + field)
        document_stems = set()
        for doc in current.get('documents', []):
            stem = doc['stem']; document_stems.add(stem); page = self.patterns / (stem + '.md')
            text = self.text(page); csv_expected = []
            for view in doc['sheets']:
                for table in view['tables']:
                    self.check(module.md_table(table) in text, stem + ': exact numeric Markdown table ' + table['title'])
                    rows = table['rows']; headers = table['headers']; eligible = table['eligible_rows']
                    self.check(len(rows) == len(eligible) and all(len(r) == len(headers) for r in rows), stem + ': table dimensions ' + table['title'])
                    total = table.get('total')
                    if total:
                        included = [i for i, ok in enumerate(eligible) if ok]
                        self.check(total['included_rows'] == included, stem + ': total uses only eligible rows')
                        for col in total['columns']:
                            actual = sum(rows[i][col] for i in included if isinstance(rows[i][col], (int, float)))
                            self.check(total['values'][col] == actual, stem + ': independently summed total ' + str(col))
                    csv_expected.extend([[view['title'] + ' — ' + table['title']], [h.replace('\n', ' ') for h in headers]])
                    csv_expected.extend([[str(v) if v is not None else '' for v in row] for row in rows])
                    if total:
                        csv_expected.append([str(v) if v is not None else '' for v in total['values']])
                    csv_expected.append([])
            if stem in {'STATISTICS_2026-11-22', 'examples/STATISTICS'}:
                observed = list(csv.reader(self.text(self.patterns / (stem + '.csv')).lstrip('\ufeff').splitlines()))
                self.check(observed == csv_expected, stem + ': exact sectioned publication CSV')
        self.check(len(document_stems) == len(current.get('documents', [])), 'Publication document stems unique')
        self.summary['publication'] = {'styled_contracts': len(self.cases), 'lmx_style_listings': 2 * len(self.cases),
            'documents': len(document_stems), 'mirrors': len(current.get('mirrors', [])), 'model_sha256': sha(path.read_bytes())}

    def run(self):
        for name in ('core', 'groups', 'haskell', 'suites', 'gof_and_shared', 'root_statistics', 'publication'):
            try:
                getattr(self, name)()
            except Exception as exc:
                self.check(False, 'Validation section completed: ' + name, f'{type(exc).__name__}: {exc}')
        return {'format': 'lmx-current-source-packet-validation-v2',
                'checked_at_utc': datetime.now(timezone.utc).isoformat(),
                'status': 'PASS' if not self.errors else 'FAIL',
                'scope': 'Current sources, multipart boundaries, JSON, Markdown, CSV, publication data, core exports/assembly and immutable Haskell LMX preservation. No language execution.',
                'source_root': str(self.spec), 'immutable_baseline': str(self.baseline),
                'historical_receipts_used_for_acceptance': False,
                'summary': self.summary, 'checks_count': len(self.checks),
                'checks': self.checks, 'errors': self.errors, 'warnings': self.warnings,
                'runtime': {'LMX_P0': 'NOT_RUN', 'LMX_L3': 'NOT_RUN', 'foreign_execution_by_this_validator': 'NOT_RUN',
                            'note': 'Runtime results require their separate current language runners; source checks are not parser/runtime execution.'},
                'doc_examples': {'status': 'NOT_RUN_BY_THIS_VALIDATOR', 'note': 'Owned and checked by the separate documentation-example validator.'}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--patterns', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--baseline', type=Path, default=DEFAULT_BASELINE, help='Immutable uploaded spec directory')
    parser.add_argument('--output', type=Path, help='JSON receipt (default: patterns/validation/current_packet_expansion_20261124.json)')
    args = parser.parse_args()
    report = Validator(args.patterns, args.baseline).run()
    output = args.output or args.patterns / 'validation/current_packet_expansion_20261124.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'status': report['status'], 'checks': report['checks_count'], 'errors': len(report['errors']),
                      'summary': {k: v for k, v in report['summary'].items() if k != 'haskell'},
                      'preserved_haskell_lmx_files': report['summary'].get('haskell', {}).get('preserved_lmx_physical_files'),
                      'report': str(output)}, ensure_ascii=False))
    if report['errors']:
        print(json.dumps(report['errors'][:30], ensure_ascii=False, indent=2))
    return int(bool(report['errors']))


if __name__ == '__main__':
    raise SystemExit(main())

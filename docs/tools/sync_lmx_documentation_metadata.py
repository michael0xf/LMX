#!/usr/bin/env python3
"""Refresh existing LMX documentation metadata without rebuilding source bodies.

This is a source-mirror/metadata tool, not an LMX parser or runtime test. It
does not create catalogue APIs, regenerate selfbuild, publish PDFs/workbooks,
or modify the implementation/example sources from which it reads.
"""
from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

from normalize_lmx_closers import normalize_text


SOURCE_SUFFIXES = {'.lmx', '.lm1', '.lm2', '.lm3'}
HISTORY_KEYS = {'before_code', 'after_code', 'original_code', 'rejected_candidate',
                'original_source_sha256_at_import'}


def canonical(text):
    return text.replace('\r\n', '\n').replace('\r', '\n').strip() + '\n'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def measure(code):
    code = canonical(code)
    return {'characters': sum(not c.isspace() for c in code),
            'characters_with_whitespace': len(code),
            'nonblank_lines': sum(bool(s.strip()) for s in code.splitlines()),
            'utf8_bytes': len(code.encode()), 'sha256': sha(code.encode())}


def update_metrics(previous, code, complete=False):
    """Retain each existing metric schema; never change the comparison boundary."""
    current = measure(code)
    aliases = {'characters_without_whitespace': 'characters',
               'non_whitespace_characters': 'characters', 'bytes_utf8': 'utf8_bytes',
               'nonempty_lines': 'nonblank_lines'}
    result = dict(previous or {})
    for key in list(result):
        if key in current:
            result[key] = current[key]
        elif key in aliases:
            result[key] = current[aliases[key]]
        elif key == 'physical_lines':
            result[key] = len(canonical(code).splitlines())
    if complete:
        result.update(current)
    return result


class Sync:
    def __init__(self, docs, baseline=None):
        self.docs = docs.resolve()
        self.project = self.docs.parent
        self.baseline = baseline.resolve() if baseline else None
        self.snapshots = {}
        self.planned = {}
        self.events = []
        self.warnings = []
        self.counts = Counter()
        self.listing_replacements = {}

    def label(self, path):
        try:
            return str(path.relative_to(self.docs))
        except ValueError:
            return str(path)

    def read(self, path):
        path = path.resolve()
        if path not in self.snapshots:
            self.snapshots[path] = path.read_bytes()
        return self.snapshots[path].decode('utf-8')

    def plan(self, path, text):
        path = path.resolve()
        before = self.read(path)
        if text != before:
            self.planned[path] = text.encode('utf-8')

    def json(self, path):
        return json.loads(self.read(path))

    def plan_json(self, path, value):
        self.plan(path, json.dumps(value, ensure_ascii=False, indent=2) + '\n')

    def warn(self, message):
        if message not in self.warnings:
            self.warnings.append(message)

    def source(self, ref, directory):
        """Use the documented local base first; stop at docs/project boundaries."""
        if not isinstance(ref, str) or not ref:
            return None
        candidates = [directory / ref]
        candidates += [p / ref for p in directory.parents if p == self.project or self.project in p.parents]
        candidates += [self.docs / ref, self.project / ref]
        for path in candidates:
            path = path.resolve()
            if self.docs not in path.parents:
                continue
            if path.is_file():
                return path
        return None

    def code_from_refs(self, refs, directory, context):
        if isinstance(refs, str):
            refs = [refs]
        if not isinstance(refs, list) or not refs:
            return None
        if len(set(refs)) != len(refs):
            self.warn(f'{context}: duplicate source references; preserved')
            return None
        paths = [self.source(ref, directory) for ref in refs]
        if any(p is None or p.suffix not in SOURCE_SUFFIXES for p in paths):
            self.warn(f'{context}: unavailable/non-LMX source; preserved: {refs}')
            return None
        return canonical('\n\n'.join(self.read(p).rstrip() for p in paths))

    def clean_string(self, code, context):
        revised, detail = normalize_text(code)
        removed = detail['removed']
        if removed:
            self.counts['embedded_closers_removed'] += len(removed)
            self.events.append({'where': context, 'removed': removed})
        return revised

    def remember_listing(self, old, new, context):
        old, new = canonical(old), canonical(new)
        if old == new:
            return
        previous = self.listing_replacements.get(old)
        if previous is not None and previous != new:
            self.listing_replacements[old] = False
            self.warn(f'{context}: ambiguous Markdown mirror; preserved')
        else:
            self.listing_replacements[old] = new

    def code_object(self, record, directory, context, *, complete=False):
        if not isinstance(record.get('code'), str):
            return
        refs = record.get('source_files')
        if not isinstance(refs, list):
            refs = record.get('source_file')
        if not refs and Path(str(record.get('source', ''))).suffix in SOURCE_SUFFIXES:
            refs = record['source']
        if refs:
            code = self.code_from_refs(refs, directory, context)
            if code is None:
                return
        else:
            code = self.clean_string(record['code'], context)
        if record['code'] != code:
            self.remember_listing(record['code'], code, context)
            self.counts['source_mirrors_refreshed'] += bool(refs)
            record['code'] = code
        if isinstance(record.get('metrics'), dict):
            record['metrics'] = update_metrics(record['metrics'], code, complete=complete)
        if 'source_sha256' in record:
            record['source_sha256'] = measure(code)['sha256']
        if 'fragment_code' in record:
            ref = record.get('entry_source_file') or record.get('source')
            fragment = self.code_from_refs(ref, directory, context + '.fragment_code') if ref else None
            if fragment is not None:
                record['fragment_code'] = fragment

    def visit(self, value, directory, context, lmx=False):
        if isinstance(value, list):
            for i, item in enumerate(value):
                self.visit(item, directory, f'{context}[{i}]', lmx)
            return
        if not isinstance(value, dict):
            return
        language = str(value.get('language', '')).upper()
        if language and language not in {'LMX', 'LM1', 'LM2', 'LM3'}:
            return
        local_lmx = lmx or language in {'LMX', 'LM1', 'LM2', 'LM3'}
        for key in ('source_file', 'source'):
            if Path(str(value.get(key, ''))).suffix in SOURCE_SUFFIXES:
                local_lmx = True
        if local_lmx:
            self.code_object(value, directory, context)
        # A style may contain the complete dependency closure. Its entry source
        # is a separate fragment and must never replace that measured closure.
        styles = value.get('lmx_variants')
        if isinstance(styles, dict):
            for name, variant in styles.items():
                self.code_object(variant, directory, f'{context}.lmx_variants.{name}', complete=True)
            functional = styles.get('functional', {}).get('code')
            for listing in value.get('listings', []):
                if listing.get('language') == 'LMX' and functional is not None:
                    self.remember_listing(listing['code'], functional, context + '.listings.LMX')
                    listing['code'] = functional
                    if 'metrics' in listing:
                        listing['metrics'] = update_metrics(listing['metrics'], functional)
            old_variants = value.get('variants')
            if isinstance(old_variants, dict) and isinstance(old_variants.get('LMX'), dict):
                for name in ('procedural', 'functional'):
                    if name in old_variants['LMX'] and name in styles:
                        old_variants['LMX'][name] = styles[name]['code']
            if isinstance(old_variants, list):
                for item in old_variants:
                    if item.get('id') in styles:
                        item['code'] = styles[item['id']]['code']
                        if 'metrics' in item:
                            item['metrics'] = update_metrics(item['metrics'], item['code'])
        if isinstance(value.get('lmx'), str):
            refs = value.get('source_files', {})
            ref = refs.get('lmx') if isinstance(refs, dict) else None
            ref = ref or value.get('lmx_file')
            if isinstance(styles, dict) and isinstance(styles.get('functional', {}).get('code'), str):
                code = styles['functional']['code']
            else:
                code = self.code_from_refs(ref, directory, context + '.lmx') if ref else self.clean_string(value['lmx'], context + '.lmx')
            if code is not None:
                self.remember_listing(value['lmx'], code, context + '.lmx')
                value['lmx'] = code
                metrics = value.get('metrics', {})
                for language in ('LMX', 'lmx'):
                    if isinstance(metrics.get(language), dict):
                        metrics[language] = update_metrics(metrics[language], code)
        if 'lmx_source_sha256' in value and value.get('lmx_source'):
            path = self.source(value['lmx_source'], directory)
            if path:
                value['lmx_source_sha256'] = sha(self.read(path).encode())
            else:
                self.warn(f'{context}: unavailable lmx_source; hash preserved')
        for key, item in value.items():
            if key in HISTORY_KEYS or key in {'lmx_variants', 'code', 'fragment_code', 'lmx', 'metrics',
                                              'foreign', 'foreign_code', 'foreign_measurement_code'}:
                continue
            if key == 'listings' and isinstance(styles, dict):
                # The compatibility listing was just set to the measured
                # functional closure, which may differ from its entry source.
                continue
            child_lmx = local_lmx or key in {'LMX', 'lmx_variants'}
            if isinstance(item, str) and child_lmx and key in {'procedural', 'functional', 'core'}:
                value[key] = self.clean_string(item, context + '.' + key)
            elif isinstance(item, (dict, list)):
                self.visit(item, directory, context + '.' + key, child_lmx)

    def conventional_primary_sources(self, path, data):
        """Prove legacy group source ownership against the immutable baseline."""
        if not self.baseline or path.name != 'patterns.json':
            return
        baseline_path = self.baseline / path.relative_to(self.docs)
        if not baseline_path.exists():
            return
        old_data = json.loads(baseline_path.read_text())
        old_records = {row['id']: row for row in old_data.get('patterns', [])}
        for record in data.get('patterns', []):
            if record.get('lmx_variants'):
                continue
            source = path.parent / 'examples/lmx' / f"{record['id']:03d}_{record['slug']}.lm3"
            old_source = self.baseline / source.relative_to(self.docs)
            old = old_records.get(record['id'], {})
            old_listing = next((x for x in old.get('listings', []) if x.get('language') == 'LMX'), None)
            listing = next((x for x in record.get('listings', []) if x.get('language') == 'LMX'), None)
            if not old_listing or not listing or not source.exists() or not old_source.exists():
                continue
            if canonical(old_source.read_text()) != canonical(old_listing['code']):
                continue
            code = self.read(source)
            if '# BEGIN PROCEDURAL LMX' in code or '# BEGIN ALTERNATIVE LMX' in code:
                continue
            code = canonical(code)
            if canonical(listing['code']) != code:
                self.remember_listing(listing['code'], code, self.label(path) + ':' + str(record['id']))
                listing['code'] = code
                self.counts['legacy_primary_sources_refreshed'] += 1

    def markdown_mirrors(self):
        """Only exact complete LMX fences proven by the synchronized source JSON."""
        pattern = re.compile(r'(?m)^```(?:lmx|lm1|lm2|lm3)\s*\n(.*?)^```[ \t]*$', re.S)
        for path in sorted((self.docs / 'spec/patterns').rglob('*.md')):
            if any(part in {'validation', 'tests'} for part in path.parts):
                continue
            if path.name.startswith(('CHANGELOG', 'VALIDATION_')):
                continue
            text = self.read(path)
            count = 0
            def replace(match):
                nonlocal count
                replacement = self.listing_replacements.get(canonical(match[1]))
                if not replacement:
                    return match[0]
                count += 1
                opening = match[0].split('\n', 1)[0]
                return opening + '\n' + replacement + '```'
            revised = pattern.sub(replace, text)
            if count:
                self.plan(path, revised)
                self.counts['markdown_fences_refreshed'] += count

    def listings(self):
        base = self.docs / 'spec/patterns'
        paths = list(base.glob('*/patterns.json'))
        paths += list(base.glob('*/extended_comparisons/*.json'))
        for relative in ('examples/variants.json',
                         'examples/julia_comparison/examples.json',
                         'examples/perl_comparison/examples.json',
                         'examples/SBCL_comparison/examples.json',
                         'examples/SBCL_comparison/implementation_data.json',
                         'examples/haskell_comparision/comparison_index.json'):
            if (base / relative).exists():
                paths.append(base / relative)
        for path in sorted(set(paths)):
            data = self.json(path)
            self.conventional_primary_sources(path, data)
            self.visit(data, path.parent, self.label(path), lmx=path.name == 'variants.json')
            self.plan_json(path, data)
            self.counts['listing_json_files_inspected'] += 1

    def owner_text(self, source, target):
        owner = target.split('\\', 1)[0]
        lines = self.read(source).splitlines()
        start = next((i for i, line in enumerate(lines)
                      if re.match(r'^(?:independent:\s*)?' + re.escape(owner) + r'\s*:(?!:)', line)), None)
        if start is None:
            raise ValueError(f'owner {owner} not found')
        end = start + 1
        while end < len(lines):
            line = lines[end]
            if line and not line.startswith((' ', '\t', '#')):
                break
            end += 1
        return '\n'.join(lines[start:end]).rstrip()

    def method_line(self, source, target):
        if '\\' not in target:
            return None
        owner, method = target.split('\\', 1)
        lines = self.read(source).splitlines()
        start = next((i for i, line in enumerate(lines)
                      if re.match(r'^(?:independent:\s*)?' + re.escape(owner) + r'\s*:(?!:)', line)), None)
        if start is None:
            return None
        name = method.strip('`')
        pattern = r'^\s+(?:' + re.escape(name) + '|' + re.escape('`' + name + '`') + r')\s*:(?!:)'
        for i in range(start + 1, len(lines)):
            line = lines[i]
            if line and not line.startswith((' ', '\t', '#')):
                break
            if re.match(pattern, line):
                return i + 1
        return None

    def relocate_line(self, source, row, baseline_row=None):
        lines = self.read(source).splitlines()
        target = row.get('target', '')
        if source.suffix in SOURCE_SUFFIXES:
            found = self.method_line(source, target)
            if found:
                return found
        if target.startswith('sys\\'):
            hits = [i for i, line in enumerate(lines, 1)
                    if re.search(re.escape(target) + r'(?![A-Za-z0-9_])', line)]
            if hits:
                return hits[0]
        for table_key in ('forms', 'role'):
            if row.get(table_key):
                hits = [i for i, line in enumerate(lines, 1)
                        if line.startswith('| ' + row[table_key] + ' |')]
                if len(hits) == 1:
                    return hits[0]
        if self.baseline and baseline_row:
            old_path = self.baseline / source.relative_to(self.docs)
            if old_path.is_file():
                old = self.read(old_path).splitlines()
                # Use the immutable metadata line number, not a number already
                # refreshed by an earlier invocation of this tool.
                number = baseline_row.get('sourceLine', 0)
                if 0 < number <= len(old):
                    needle = old[number - 1]
                    hits = [i for i, line in enumerate(lines, 1) if line == needle]
                    if len(hits) == 1 and needle.strip():
                        return hits[0]
                    if 0 < number <= len(lines) and lines[number - 1] == needle:
                        return number
        return None

    def patch_records(self, path, changes):
        """Patch existing scalar fields in place, preserving every other byte."""
        lines = self.read(path).splitlines(keepends=True)
        row = -1
        seen = set()
        for i, line in enumerate(lines):
            if re.fullmatch(r'    entry\d+:\s*', line):
                row += 1
            match = re.fullmatch(r'(        )(\[\]char|char\[\]|int): (\w+) (.*?)(\r?\n)?', line)
            if not match or row not in changes or match[3] not in changes[row]:
                continue
            key = match[3]
            value = changes[row][key]
            encoded = json.dumps(str(value), ensure_ascii=False) if match[2] != 'int' else str(int(value))
            lines[i] = f'{match[1]}{match[2]}: {key} {encoded}' + (match[5] or '')
            seen.add((row, key))
        expected = {(i, key) for i, values in changes.items() for key in values}
        if seen != expected:
            raise ValueError(f'{path}: failed to patch existing fields {expected - seen}')
        self.plan(path, ''.join(lines))

    def core(self):
        lib = self.docs / 'spec/patterns/LMX_Fn_Receivers'
        sys.path.insert(0, str(lib / 'tools'))
        from catalog_data import owner_data
        module_path = self.docs / 'core_catalog/tools/rebuild_core.py'
        spec = importlib.util.spec_from_file_location('_lmx_core_metadata_reader', module_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        core = self.docs / 'core_catalog/core'
        inventory = None
        for path in sorted(core.glob('*.lmx')):
            if path.name == 'selfbuild_index.lmx':
                # Intentionally never re-infer this from an absent selfbuild/.
                self.read(path)
                self.counts['historical_selfbuild_files_preserved'] += 1
                continue
            if '    entry0001:' not in self.read(path):
                continue
            rows = module.project_records(path)
            profile_lines = {}
            if path.name == 'profile_roles.lmx':
                # These rows explicitly refer to semantic-profile headings,
                # not callable declarations. Reuse the existing generator's
                # exact role/package/source mapping and heading anchors only;
                # never re-create the catalogue or infer new membership.
                self.read(self.docs / 'spec/LMX_semantics.en.md')
                for profile in module.profile_role_rows(self.project):
                    # The generator writes str(Path), which has backslashes on
                    # Windows; the records keep POSIX paths.
                    key = tuple(profile.get(k, '').replace('\\', '/') if k == 'source' else profile.get(k, '')
                                for k in ('role', 'package', 'source'))
                    if key in profile_lines:
                        raise ValueError('Ambiguous profile-role source anchor: ' + repr(key))
                    profile_lines[key] = profile['sourceLine']
            def identity(row):
                return tuple(row.get(k, '') for k in ('source', 'target', 'forms', 'role', 'name', 'family'))
            baseline_records = {}
            baseline_path = self.baseline / path.relative_to(self.docs) if self.baseline else None
            if baseline_path and baseline_path.exists():
                baseline_records = {identity(row): row for row in module.project_records(baseline_path)}
            changes = {}
            for i, row in enumerate(rows):
                if not row.get('source'):
                    continue
                source = self.source(row['source'], self.project)
                if source is None:
                    self.counts['unavailable_source_records_preserved'] += 1
                    continue
                revised = {}
                if 'sourceLine' in row:
                    profile_key = tuple(row.get(k, '') for k in ('role', 'package', 'source'))
                    found = profile_lines.get(profile_key)
                    if found is None:
                        found = self.relocate_line(source, row, baseline_records.get(identity(row)))
                    if found is not None:
                        revised['sourceLine'] = found
                    else:
                        self.warn(f'{self.label(path)} entry{i+1:04d}: source line not relocated; preserved')
                if 'sourceSha256' in row:
                    revised['sourceSha256'] = sha(self.read(source).encode())
                if 'sourceDeclaration' in row and row.get('target'):
                    try:
                        header = owner_data(self.owner_text(source, row['target']))['source_declaration']
                        revised['sourceDeclaration'] = self.clean_string(header, self.label(path) + f' entry{i+1:04d}.sourceDeclaration')
                    except ValueError as error:
                        self.warn(f'{self.label(path)} entry{i+1:04d}: declaration preserved: {error}')
                revised = {key: value for key, value in revised.items() if row[key] != value}
                if revised:
                    changes[i] = revised
                    row.update(revised)
            self.patch_records(path, changes)
            self.counts['core_records_refreshed'] += len(changes)
            if path.name == 'inventory.lmx':
                inventory = rows
                self.plan_json(path.with_suffix('.json'), rows)
        # Update the same existing implementation headers in the public JSON
        # projection; creating/removing APIs is another generator's decision.
        catalog_path = lib / 'catalog.json'
        catalog = self.json(catalog_path)
        for entry in catalog:
            for variant in entry.get('variants', []):
                contract = variant.get('implementation_contract', {})
                if 'source_declaration' not in contract:
                    continue
                source = self.source(variant.get('source'), lib)
                if source is None:
                    continue
                try:
                    header = owner_data(self.owner_text(source, variant['api']))['source_declaration']
                    contract['source_declaration'] = self.clean_string(header, str(catalog_path) + ':' + variant['api'])
                except ValueError as error:
                    self.warn(f'catalog.json {variant["api"]}: declaration preserved: {error}')
        self.plan_json(catalog_path, catalog)
        summary_path = core / 'summary.json'
        if summary_path.exists():
            summary = self.json(summary_path)
            summary['source_catalog_sha256'] = sha(self.planned.get(catalog_path.resolve(), self.read(catalog_path).encode()))
            self.plan_json(summary_path, summary)
        readme = core / 'README.ru.md'
        if inventory is not None and readme.exists():
            text = self.read(readme)
            for row in inventory:
                marker = '[' + row['target'] + '](../../../' + row['source'] + '), строка '
                text = re.sub(re.escape(marker) + r'\d+', lambda m: marker + str(row['sourceLine']), text)
            self.plan(readme, text)

    def finish(self, write=False):
        # Detect concurrent source or metadata edits before changing any file.
        if write:
            changed = [self.label(path) for path, old in self.snapshots.items() if path.read_bytes() != old]
            if changed:
                raise RuntimeError('Inputs changed during sync; rerun after writers finish: ' + ', '.join(changed))
            for path, data in self.planned.items():
                path.write_bytes(data)
        return {'mode': 'SOURCE_METADATA_SYNC_NOT_P0_NOT_RUNTIME', 'write': write,
                'counts': dict(self.counts), 'changed_files': len(self.planned),
                'files': [{'file': self.label(p), 'sha256_before': sha(self.snapshots[p]),
                           'sha256_after': sha(b)} for p, b in sorted(self.planned.items())],
                'warnings': self.warnings, 'embedded_cleanup': self.events,
                'preserved': ['selfbuild_index.lmx', 'unavailable source records',
                              'historical before/after/rejected source evidence',
                              'LMX implementation and example source bodies',
                              'foreign-language source and listings', 'PDF/XLSX exports'],
                'next_steps': ['Run the current publication generators after JSON synchronization',
                               'Run static checks; this script does not claim production P0/runtime execution',
                               'Refresh manifests after all final exports and reports']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--docs', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--baseline-docs', type=Path, help='immutable previous docs/ for exact line relocation')
    parser.add_argument('--core', action='store_true', help='refresh existing core metadata/header projections')
    parser.add_argument('--listings', action='store_true', help='refresh active source-linked listing JSON')
    parser.add_argument('--markdown-mirrors', action='store_true', help='refresh only exact source-backed complete LMX fences in active patterns Markdown')
    parser.add_argument('--write', action='store_true', help='apply; default is a dry run')
    parser.add_argument('--check', action='store_true', help='exit 1 if any target needs refresh')
    parser.add_argument('--report', type=Path)
    args = parser.parse_args()
    sync = Sync(args.docs, args.baseline_docs)
    if args.core or not args.listings:
        sync.core()
    if args.listings or not args.core:
        sync.listings()
    if args.markdown_mirrors:
        sync.markdown_mirrors()
    result = sync.finish(args.write)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in ('mode', 'write', 'counts', 'changed_files', 'warnings')}, ensure_ascii=False))
    if args.check and sync.planned:
        raise SystemExit(1)


if __name__ == '__main__':
    main()

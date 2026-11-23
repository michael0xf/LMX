#!/usr/bin/env python3
"""Publish both complete LMX styles for all96 examples and separate shared bodies.

Inputs are read-only. Source/JSON inconsistencies are errors, never a reason to
silently bless a new hash. This tool does not execute any compared language.
"""
from pathlib import Path
import csv
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = ROOT.parent
EDITION = '2026-11-23'
sys.path.insert(0, str(PATTERNS/'tools'))
from canonical_operations import definitions as canonical_definitions
from lmx_style_variants import normalize, measure as metric, validate_variants

SUITES = {'julia': 'julia_comparison', 'perl': 'perl_comparison', 'sbcl': 'SBCL_comparison'}
STYLES = ('procedural', 'functional')
STATUSES = {'complete_pair', 'related_analogy', 'lmx_only'}
LEGACY_ROLE = 'Functional compatibility mirror only; not a third compared LMX listing.'


def read(path):
    return json.loads(path.read_text())


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def listing_paths(item):
    sources = item.get('source_files')
    if isinstance(sources, dict):
        return sources
    return {'lmx': item['lmx_file'], 'foreign': item['foreign_file']}


def check_source(directory, name, code):
    path = directory/name
    require(path.is_file(), f'Missing source: {path}')
    require(path.read_text() == normalize(code), f'JSON/whole-source mismatch: {path}')
    return path.relative_to(ROOT).as_posix()


def measured_styles(item, directory):
    issues = validate_variants(item, directory)
    require(not issues, f"{item['id']}: invalid full style contracts: {issues}")
    measured = {style: metric(item['lmx_variants'][style]['code']) for style in STYLES}
    sources = {style: (directory/item['lmx_variants'][style]['source_file']).relative_to(ROOT).as_posix()
               for style in STYLES}
    return measured, sources


def check_recorded_metric(actual, recorded, label):
    # Older helper inventories record four full fields; the current publication
    # also calculates characters_with_whitespace from the actual complete body.
    for key in ('characters', 'nonblank_lines', 'utf8_bytes', 'sha256'):
        require(recorded.get(key) == actual[key], f'{label}: stale complete-source {key}')


def client_record(suite, item, directory, foreign_language, status, foreign_code,
                  foreign_source, title, contract, **extra):
    require(status in STATUSES, f"{suite}/{item['id']}: invalid comparability status")
    require(status != 'complete_pair' or bool(foreign_code.strip()),
            f"{suite}/{item['id']}: complete pair has no foreign listing")
    measured, sources = measured_styles(item, directory)
    foreign = metric(foreign_code) if foreign_code.strip() else None
    ratios = {style: foreign['characters']/measured[style]['characters']
              if status == 'complete_pair' else None for style in STYLES}
    return {'suite': suite, 'id': item['id'], 'title': title,
            'foreign_language': foreign_language, 'comparison_status': status,
            'lmx_variants': measured, 'lmx_sources': sources, 'ratios': ratios,
            'style_relation': item['style_relation'], 'style_note': item['style_note'],
            'lmx': measured['functional'], 'lmx_source': sources['functional'],
            'ratio': ratios['functional'], 'lmx_legacy_role': LEGACY_ROLE,
            'foreign': foreign, 'foreign_source': foreign_source,
            'contract': contract, **extra}


def summarize(examples, implementations):
    summaries = []
    for suite in ('haskell', *SUITES):
        rows = [row for row in examples if row['suite'] == suite]
        pairs = [row for row in rows if row['comparison_status'] == 'complete_pair']
        foreign = sum(row['foreign']['characters'] for row in pairs)
        totals = {}
        for style in STYLES:
            paired = sum(row['lmx_variants'][style]['characters'] for row in pairs)
            totals[style] = {'all_characters': sum(row['lmx_variants'][style]['characters'] for row in rows),
                             'paired_characters': paired,
                             'paired_ratio': foreign/paired if paired else None}
        summary = {'suite': suite, 'foreign_language': rows[0]['foreign_language'],
                   'examples': len(rows), 'style_listings': 2*len(rows),
                   'complete_pairs': len(pairs),
                   'related_analogies': sum(row['comparison_status'] == 'related_analogy' for row in rows),
                   'lmx_only': sum(row['comparison_status'] == 'lmx_only' for row in rows),
                   'lmx_variants': totals, 'paired_foreign_characters': foreign,
                   'implementation_comparisons': sum(row['suite'] == suite for row in implementations),
                   'lmx_legacy_role': LEGACY_ROLE}
        for style in STYLES:
            summary['all_lmx_'+style+'_characters'] = totals[style]['all_characters']
            summary['paired_lmx_'+style+'_characters'] = totals[style]['paired_characters']
            summary['paired_'+style+'_ratio'] = totals[style]['paired_ratio']
        summary.update(all_lmx_characters=totals['functional']['all_characters'],
                       paired_lmx_characters=totals['functional']['paired_characters'],
                       paired_ratio=totals['functional']['paired_ratio'])
        summaries.append(summary)
    return summaries


def publish_csv(examples, implementations):
    fields = ['suite', 'id', 'title', 'status', 'LMX_procedural_characters', 'LMX_functional_characters',
              'foreign_language', 'foreign_characters', 'foreign_per_LMX_procedural', 'foreign_per_LMX_functional',
              'LMX_procedural_nonblank_lines', 'LMX_functional_nonblank_lines', 'foreign_nonblank_lines',
              'LMX_procedural_source', 'LMX_functional_source', 'style_relation']
    with (ROOT/'STATISTICS.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=fields); writer.writeheader()
        for row in examples:
            value = {key: row[key] for key in ('suite', 'id', 'title', 'foreign_language', 'style_relation')}
            value.update(status=row['comparison_status'],
                         foreign_characters=row['foreign']['characters'] if row['foreign'] else '',
                         foreign_nonblank_lines=row['foreign']['nonblank_lines'] if row['foreign'] else '')
            for style in STYLES:
                value['LMX_'+style+'_characters'] = row['lmx_variants'][style]['characters']
                value['LMX_'+style+'_nonblank_lines'] = row['lmx_variants'][style]['nonblank_lines']
                value['LMX_'+style+'_source'] = row['lmx_sources'][style]
                value['foreign_per_LMX_'+style] = row['ratios'][style] if row['ratios'][style] is not None else ''
            writer.writerow(value)
    with (ROOT/'IMPLEMENTATIONS.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.writer(stream)
        writer.writerow(['suite', 'id', 'title', 'LMX_characters', 'foreign_language', 'foreign_characters',
                         'LMX_nonblank_lines', 'foreign_nonblank_lines', 'scope'])
        for row in implementations:
            writer.writerow([row['suite'], row['id'], row['title'], row['lmx']['characters'], row['foreign_language'],
                             row['foreign']['characters'], row['lmx']['nonblank_lines'], row['foreign']['nonblank_lines'],
                             row['comparison_scope']])


def format_ratio(value):
    return f'{value:.3f}' if value is not None else '—'


def publish_markdown(result):
    summaries = result['summaries']; examples = result['examples']; implementations = result['implementations']
    lines = ['# Статистика всей директории examples', '',
             f"Редакция **{EDITION}**. По текущим исходникам опубликованы **{len(examples)} контрактов /{2*len(examples)} полных LMX-измерений**. Обе стилевые формы сравниваются; общие реализации имеют одно тело.", '',
             '## Итоги полных пар', '',
             '| Набор | Сценарии | Полные пары | Аналогии | Только LMX | LMX процедурный | LMX функциональный | Контроль | Контроль / процедурный | Контроль / функциональный |',
             '| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |']
    for row in summaries:
        lines.append(f"| {row['foreign_language']} | {row['examples']} | {row['complete_pairs']} | {row['related_analogies']} | {row['lmx_only']} | {row['paired_lmx_procedural_characters']} | {row['paired_lmx_functional_characters']} | {row['paired_foreign_characters']} | {format_ratio(row['paired_procedural_ratio'])} | {format_ratio(row['paired_functional_ratio'])} |")
    lines += ['', 'Числовые итоги и отношения используют одни и те же полные пары каждого набора. Частичная аналогия и отсутствующий контроль не становятся нулевым размером и не включаются в суммы. Разные составы задач не дают общего рейтинга языков.', '',
              '## Две полные LMX-записи', '',
              '| Набор / ID | Сценарий | Статус | LMX процедурный: символы / строки | LMX функциональный: символы / строки | Контроль: символы / строки | Контроль / процедурный | Контроль / функциональный |',
              '| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |']
    labels = {'complete_pair': 'Полная пара', 'related_analogy': 'Связанная аналогия', 'lmx_only': 'Только LMX'}
    for row in examples:
        display = []
        for style in STYLES:
            m = row['lmx_variants'][style]
            display.append(f"[{m['characters']} / {m['nonblank_lines']}]({row['lmx_sources'][style]})")
        foreign = f"{row['foreign']['characters']} / {row['foreign']['nonblank_lines']}" if row['foreign'] else '—'
        title = row['title'].replace('|', r'\|')
        lines.append(f"| {row['suite']} / {row['id']} | {title} | {labels[row['comparison_status']]} | {display[0]} | {display[1]} | {foreign} | {format_ratio(row['ratios']['procedural'])} | {format_ratio(row['ratios']['functional'])} |")
    lines += ['', 'При style_relation=same_minimal_form оба измерения ссылаются на один физический исходник; его тело публикуется один раз с пояснением. Различающиеся формы имеют отдельные файлы и сохраняют один observable contract.', '',
              '## Общие реализации', '',
              'Эти тела сравниваются отдельно от клиентов. Пересекающиеся зависимости нельзя повторно складывать как размер одного приложения; иностранные клиенты не импортируют сравнительные модули.', '',
              '| Набор / ID | Операции | LMX: символы / строки | Контроль: символы / строки |',
              '| --- | --- | ---: | ---: |']
    for row in implementations:
        title = row['title'].replace('|', r'\|')
        lines.append(f"| {row['suite']} / {row['id']} | {title} | {row['lmx']['characters']} / {row['lmx']['nonblank_lines']} | {row['foreign']['characters']} / {row['foreign']['nonblank_lines']} |")
    lines += ['', '## Полный подсчёт и воспроизведение', '',
              'Обе клиентские записи включают все объявления, локальные helpers, комментарии внутри границы, Throws и ссылки copy. Убираются только пробельные Unicode-символы. Дополнительно сохраняются все символы, непустые строки, UTF-8-байты и SHA-256. Исходные строки нормализуются в LF с одним завершающим переводом строки.', '',
              'По авторской оценке, явные конечные Throws и общий throws: copy(Throws) — преимущество LMX: точно видны возможные ошибки метода. Они полностью входят в каждое измерение. Процедурная запись использует прямые операции и явный поток управления; функциональная — композицию, Expression и общие операции.', '',
              'Поле lmx и прежние однозначные totals/ratio оставлены в JSON только как явно помеченные функциональные совместимые зеркала. Сравниваемые значения находятся в lmx_variants/ratios; в пользовательских таблицах обе формы представлены отдельными столбцами.', '',
              'Источники: [Haskell coverage](haskell/comparison_index.json), [Julia](julia_comparison/examples.json), [Perl](perl_comparison/examples.json), [SBCL](SBCL_comparison/examples.json). [JSON](STATISTICS.json), [CSV клиентов](STATISTICS.csv), [CSV реализаций](IMPLEMENTATIONS.csv), [реестр физических исходников](SOURCE_INVENTORY.json).', '',
              'Из корня spec: python3 patterns/examples/tools/refresh_examples_statistics.py. Затем python3 patterns/tools/build_publication_data.py --text создаёт единую модель всех100 контрактов, включая четыре клиента группы09. PDF и XLSX строятся через patterns/tools/publish_pdfs.py и patterns/tools/publish_workbooks.mjs из этой общей модели.', '',
              result['runtime_note'], '']
    (ROOT/'STATISTICS.md').write_text('\n'.join(lines))


def main():
    expected = read(ROOT/'expected_results.json')
    index = read(ROOT/'haskell/comparison_index.json')
    by_haskell = {item['id']: item for item in index['entries']}
    require(len(index['entries']) == len(by_haskell) == 24, 'Haskell: exactly24 unique scenarios required')
    require({item['id'] for item in expected['source_examples']} == set(by_haskell), 'Haskell acceptance/index identities differ')
    require(hashlib.sha256((ROOT/'haskell/Analogies.hs').read_bytes()).hexdigest() == index['source_module_sha256'],
            'Haskell module fingerprint is stale')
    examples = []; implementations = []
    for expectation in expected['source_examples']:
        item = by_haskell[expectation['id']]
        require(expectation['file'] == item['lmx_variants']['functional']['source_file'], f"{item['id']}: compatibility source path mismatch")
        require(hashlib.sha256((ROOT/item['lmx_source']).read_bytes()).hexdigest() == item['lmx_source_sha256'], f"{item['id']}: source index fingerprint is stale")
        foreign = item.get('foreign_code', '')
        if foreign:
            require(hashlib.sha256(foreign.encode()).hexdigest() == item['foreign_listing_sha256'], f"{item['id']}: Haskell listing fingerprint is stale")
        examples.append(client_record('haskell', item, ROOT, 'Haskell', item['status'], foreign,
                        'haskell/Analogies.hs', item.get('title', item['id']), item.get('contract_notes', ''),
                        source_symbols=item.get('source_symbols', []), runtime={'LMX': 'NOT_RUN', 'Haskell': 'NOT_RUN'}))
    for suite, dirname in SUITES.items():
        directory = ROOT/dirname; data = read(directory/'examples.json')
        require(len(data['examples']) == len({item['id'] for item in data['examples']}) == 24,
                f'{suite}: exactly24 unique clients required')
        for item in data['examples']:
            paths = listing_paths(item)
            check_source(directory, paths['lmx'], item['lmx'])
            foreign_source = check_source(directory, paths['foreign'], item['foreign'])
            require(item['lmx'] == item['lmx_variants']['functional']['code'], f"{suite}/{item['id']}: functional compatibility mirror differs")
            alternatives = []
            for alternative in item.get('alternatives', []):
                alt = {key: value for key, value in alternative.items() if key != 'code'}
                if 'code' in alternative:
                    alt['metrics'] = metric(alternative['code'])
                    if alternative.get('source_file'):
                        check_source(directory, alternative['source_file'], alternative['code'])
                alternatives.append(alt)
            examples.append(client_record(suite, item, directory, data['foreign_language'], item.get('comparison_status', 'complete_pair'),
                            item['foreign'], foreign_source, item['title'], item['contract'],
                            category=item.get('category', ''), core_functions=item.get('core_functions', []),
                            foreign_dependencies=item.get('foreign_dependencies', []), sources=item.get('sources', []),
                            alternatives=alternatives, runtime={'LMX': 'NOT_RUN', data['foreign_language']: 'see separate suite validation receipt'}))
        impl_data = read(directory/'implementation_data.json') if (directory/'implementation_data.json').exists() else data
        for item in impl_data.get('implementations', []):
            paths = listing_paths(item)
            actual_sources = {key: check_source(directory, paths[key], item[key]) for key in ('lmx', 'foreign')}
            implementations.append({'suite': suite, 'id': item['id'], 'title': item['title'],
                'foreign_language': data['foreign_language'], 'core_functions': item.get('core_functions', []),
                'lmx': metric(item['lmx']), 'foreign': metric(item['foreign']), 'contract': item['contract'],
                'sources': item.get('sources', []), 'source_files': item.get('source_files', []),
                'listing_sources': actual_sources, 'comparison_scope': 'implementation_only',
                'dependencies': item.get('implementation_dependencies', item.get('dependencies', [])),
                'production_definitions': item.get('production_definitions', []),
                'shared_lmx_definitions': item.get('shared_lmx_definitions', []),
                'external_boundaries': item.get('external_boundaries', []), 'imported_by_clients': False})
    core = canonical_definitions(PATTERNS/'LMX_Fn_Receivers')
    for item in read(ROOT/'validation/receiver_library_counts.json')['comparisons']:
        page = (ROOT/item['file']).read_text()
        entry = next(normalize(match[1]) for match in re.finditer(r'^```lmx\n(.*?)^```\s*$', page, re.M|re.S))
        if item['entry'] == 'Cycles':
            complete = (ROOT/'libraries/lmx/Cycles.lm3').read_text()
        else:
            require(set(item['roots']) <= set(core), f"{item['file']}: missing canonical dependency")
            complete = '\n\n'.join(core[name]['code'].rstrip() for name in item['roots'])+'\n'
        foreign = (ROOT/item['haskell_source']).read_text()
        measured = metric(complete); entry_metric = metric(entry); foreign_metric = metric(foreign)
        check_recorded_metric(measured, item['lmx'], item['file']+'/reachable LMX')
        check_recorded_metric(entry_metric, item['lmx_entry'], item['file']+'/LMX entry')
        check_recorded_metric(foreign_metric, item['haskell'], item['file']+'/foreign')
        implementations.append({'suite': 'haskell', 'id': Path(item['file']).stem.split('_')[0].upper(),
            'title': ', '.join(item['public_names']), 'foreign_language': 'Haskell',
            'core_functions': item['public_names'], 'lmx': measured, 'lmx_entry': entry_metric,
            'foreign': foreign_metric, 'source_files': item['source_files'], 'comparison_file': item['file'],
            'comparison_scope': 'implementation_only',
            'contract': 'Complete entry and reachable LMX definitions; complete standalone Haskell module. Shared roots overlap across rows.',
            'imported_by_clients': False})
    page = ROOT/'library_comparisons/r01_derive_comparision.md'
    blocks = re.findall(r'```(lmx|haskell)\n(.*?)```', page.read_text(), re.S)
    require({language for language, _ in blocks} == {'lmx', 'haskell'}, 'R01: both complete comparison bodies required')
    bodies = {language: '\n'.join(code for tag, code in blocks if tag == language) for language in ('lmx', 'haskell')}
    implementations.append({'suite': 'haskell', 'id': 'R01', 'title': 'derive / record composition',
        'foreign_language': 'Haskell', 'core_functions': ['derive'], 'lmx': metric(bodies['lmx']),
        'foreign': metric(bodies['haskell']), 'comparison_file': 'library_comparisons/r01_derive_comparision.md',
        'comparison_scope': 'implementation_only', 'imported_by_clients': False,
        'contract': 'Exact explicitly delimited comparison bodies, including the stated host representation boundary.'})
    require(len(examples) == len({(row['suite'], row['id']) for row in examples}) == 96, 'Expected96 unique client contracts')
    require(len(implementations) == len({(row['suite'], row['id']) for row in implementations}) == 24, 'Expected24 unique shared implementation comparisons')
    summaries = summarize(examples, implementations)
    source_styles = {}
    for row in examples:
        for style, source in row['lmx_sources'].items():
            source_styles.setdefault(source, []).append({'suite': row['suite'], 'id': row['id'], 'style': style})
    inventory = []
    for path in sorted(ROOT.rglob('*')):
        if not path.is_file() or path.suffix not in ('.lm3', '.lmx', '.hs', '.jl', '.pl', '.pm', '.lisp', '.cl'):
            continue
        if '__pycache__' in path.parts:
            continue
        name = path.relative_to(ROOT).as_posix()
        layer = 'implementation' if ('libraries/' in name or 'library_comparisons/' in name or '/implementation/' in name) else 'source_or_fixture'
        item = {'file': name, 'layer': layer, 'metrics': metric(path.read_text())}
        if name in source_styles:
            item['compared_styles'] = source_styles[name]
        inventory.append(item)
    result = {'format': 'lmx-full-dual-style-statistics-v1', 'edition': EDITION,
        'metric': 'Full nonwhitespace Unicode source, all declarations, local helpers, comments and Throws included; LF normalized.',
        'lmx_legacy_role': LEGACY_ROLE,
        'ratio': 'foreign / full LMX style; only complete pairs, with identical membership for both ratios; no cross-suite language ranking',
        'counts': {'lmx_examples': len(examples), 'lmx_style_listings': 2*len(examples),
                   'unique_lmx_client_sources': len(source_styles), 'complete_pairs': sum(row['complete_pairs'] for row in summaries),
                   'implementation_comparisons': len(implementations), 'source_files': len(inventory)},
        'summaries': summaries, 'examples': examples, 'implementations': implementations,
        'haskell_module': {'file': 'haskell/Analogies.hs', 'metric': metric((ROOT/'haskell/Analogies.hs').read_text()),
                           'scope': 'Whole source with assertions/shared declarations; not added to per-case totals'},
        'lmx_parser_execution': 'NOT_RUN', 'lmx_runtime_execution': 'NOT_RUN',
        'runtime_note': 'Source/JSON/publication checks only. No language is executed by this generator. Revised LMX parsing and runtime execution are NOT_RUN. Existing foreign execution receipts remain separate in suite validation.'}
    write_json(ROOT/'STATISTICS.json', result)
    write_json(ROOT/'SOURCE_INVENTORY.json', {'edition': EDITION, 'files': inventory, 'sum_is_not_application_size': True})
    publish_csv(examples, implementations)
    publish_markdown(result)
    print(json.dumps(result['counts'], ensure_ascii=False))


if __name__ == '__main__':
    main()

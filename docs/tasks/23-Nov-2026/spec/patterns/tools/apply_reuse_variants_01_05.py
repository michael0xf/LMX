#!/usr/bin/env python3
"""Apply the source-reviewed reuse plan for groups 01--05, reproducibly.

All previous listings stay in JSON and adjacent Markdown. The original archived
listing also stays in the primary standalone source as comments. This script
does not execute LMX, change controls, or regenerate aggregate publications.
"""
from pathlib import Path
import hashlib
import json
import re

from recount_patterns import (
    canonical_code, metrics, fenced_blocks, source_parts,
    PROCEDURAL_BEGIN, PROCEDURAL_END,
)

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / 'validation/reuse_plan_01_05_20261122.json'
REPORT = ROOT / 'validation/reuse_review_01_05_20261122.json'


def sha(code):
    return hashlib.sha256(canonical_code(code).encode()).hexdigest()


def section(marker, heading, code, reason):
    return (
        f'<!-- {marker} -->\n\n## {heading}\n\n'
        'Полный предыдущий листинг сохранён; в текущую статистику входит только '
        'основной, более короткий вариант. Все самописные вспомогательные '
        'определения остаются в основном листинге и учитываются целиком.\n\n'
        f'```lmx\n{code}```\n\n'
        f'**Основание выбора / Selection:** {reason}\n\n'
        f'<!-- /{marker} -->\n\n'
    )


def main():
    plan = json.loads(PLAN.read_text())
    by_id = {entry['id']: entry for entry in plan['entries']}
    if len(by_id) != 64:
        raise ValueError('Expected the complete 64-record review')
    reports = []
    changed = []
    for path in sorted(ROOT.glob('0[1-5]_*/patterns.json')):
        group = json.loads(path.read_text())
        modified = False
        for pattern in group['patterns']:
            entry = by_id[pattern['id']]
            if entry['group'] != path.parent.name:
                raise ValueError((pattern['id'], 'group changed'))
            listing = next(x for x in pattern['listings'] if x['language'] == 'LMX')
            controls = {x['language']: x['code'] for x in pattern['listings'] if x['language'] != 'LMX'}
            before = canonical_code(entry['before_code'] or listing['code'])
            after = canonical_code(entry['after_code'] or listing['code'])
            if entry['after_code']:
                if canonical_code(listing['code']) not in (before, after):
                    raise ValueError((pattern['id'], 'primary source changed since review'))
                if metrics(after)['nonwhitespace_characters'] >= metrics(before)['nonwhitespace_characters']:
                    raise ValueError((pattern['id'], 'candidate is not strictly shorter'))
                old_primary = pattern.get('primary_variant', {}).get('LMX', 'procedural')
                prior = pattern.setdefault('reuse_review', {})
                prior.setdefault('previous_primary', old_primary)
                prior.setdefault('previous_fairness_note', pattern.get('fairness_notes', {}).get('LMX', ''))
                prior['mechanism'] = entry['mechanism']
                prior['review_plan'] = PLAN.relative_to(ROOT).as_posix()
                variants = pattern.setdefault('variants', {}).setdefault('LMX', {})
                if not pattern.get('procedural_lmx'):
                    pattern['procedural_lmx'] = before
                    variants.setdefault('procedural', before)
                elif before != canonical_code(pattern['procedural_lmx']):
                    previous_name = prior['previous_primary']
                    if previous_name == 'reuse':
                        raise ValueError((pattern['id'], 'missing previous primary identity'))
                    variants.setdefault(previous_name, before)
                    inline = pattern.setdefault('inline_current_lmx_variants', [])
                    for name in (previous_name, 'reuse'):
                        if name not in inline:
                            inline.append(name)
                variants['reuse'] = after
                eligible = pattern.setdefault('eligible_variants', {}).setdefault('LMX', list(variants))
                for name in variants:
                    if name not in eligible:
                        eligible.append(name)
                if min(metrics(variants[name])['nonwhitespace_characters'] for name in eligible) != metrics(after)['nonwhitespace_characters']:
                    raise ValueError((pattern['id'], 'a shorter eligible variant exists'))
                pattern.setdefault('primary_variant', {})['LMX'] = 'reuse'
                pattern.setdefault('fairness_notes', {})['LMX'] = (
                    entry['reason'] + ' All custom helper definitions remain in the counted listing; '
                    'no new unmeasured library is introduced. Previous complete variants are retained.'
                )
                listing['code'] = after
                stem = f"{pattern['id']:03d}_{pattern['slug']}"
                source = path.parent / 'examples/lmx' / (stem + '.lm3')
                archived = canonical_code(pattern['procedural_lmx'])
                source.write_text(after + '\n' + PROCEDURAL_BEGIN + '\n' +
                                  '\n'.join('# ' + line for line in archived.splitlines()) +
                                  '\n' + PROCEDURAL_END + '\n')
                markdown = path.parent / (stem + '_comparision.md')
                text = markdown.read_text()
                match = re.search(r'^```lmx\n([\s\S]*?)^```', text, re.M)
                if not match or canonical_code(match[1]) not in (before, after):
                    raise ValueError((markdown, 'unexpected primary Markdown'))
                text = text[:match.start(1)] + after + text[match.end(1):]
                marker = 'reuse-review-01-05-2026-11-22'
                title = ('Предыдущий текущий вариант LMX — вне основного подсчёта'
                         if before != archived else
                         'Предыдущий полный вариант LMX — вне основного подсчёта')
                addition = section(marker, title, before, entry['reason'])
                if f'<!-- {marker} -->' in text:
                    expression = re.compile(r'<!-- ' + re.escape(marker) + r' -->[\s\S]*?<!-- /' + re.escape(marker) + r' -->\n*')
                    text = expression.sub(lambda _: addition, text, count=1)
                else:
                    anchor = ('<!-- postfix-expression-review-2026-11-22 -->'
                              if before != archived else '## English explanation')
                    position = text.find(anchor)
                    text = text[:position] + addition + text[position:] if position >= 0 else text + '\n' + addition
                counts = metrics(after)
                text = re.sub(r'^\| LMX \| [0-9]+ \| [0-9]+ \|',
                              f"| LMX | {counts['nonwhitespace_characters']} | {counts['nonblank_lines']} |",
                              text, flags=re.M)
                markdown.write_text(text)
                blocks, closed = fenced_blocks(text)
                current = [name for name in pattern.get('inline_current_lmx_variants', []) if name != 'reuse']
                if not closed or blocks[0] != ('lmx', after) or len(blocks) != 4 + len(current):
                    raise ValueError((markdown, 'fence count or primary mismatch'))
                for index, name in enumerate(current, 3):
                    if blocks[index] != ('lmx', canonical_code(variants[name])):
                        raise ValueError((markdown, 'current alternate mismatch', name))
                if ('lmx', archived) not in blocks[3:] or source_parts(source.read_text()) != (after, archived):
                    raise ValueError((markdown, 'historical source missing'))
                changed.append({'id': pattern['id'], 'group': path.parent.name,
                                'before': metrics(before)['nonwhitespace_characters'],
                                'after': counts['nonwhitespace_characters'],
                                'saved': metrics(before)['nonwhitespace_characters'] - counts['nonwhitespace_characters']})
                modified = True
            if controls != {x['language']: x['code'] for x in pattern['listings'] if x['language'] != 'LMX'}:
                raise ValueError((pattern['id'], 'controls changed'))
            reports.append({
                'group': path.parent.name, 'id': pattern['id'], 'name': pattern['name'],
                'kind': pattern.get('kind', 'pattern'), 'before': metrics(before), 'after': metrics(after),
                'before_sha256': sha(before), 'after_sha256': sha(after),
                'decision': entry['decision'], 'mechanism': entry['mechanism'], 'reason': entry['reason'],
                'helpers_complete': True, 'scenario_and_observations_preserved': True,
                'foreign_listings_unchanged': True, 'runtime_executed': False,
            })
        if modified:
            path.write_text(json.dumps(group, ensure_ascii=False, indent=2) + '\n')
    if {x['id'] for x in reports} != set(by_id):
        raise ValueError('Review coverage mismatch')
    result = {
        'date': '2026-11-22', 'scope': 'All 64 current scenarios and primary LMX listings in groups 01--05',
        'source': 'Current supplied archive only; no web or prior-version substitution',
        'reviewed': len(reports), 'selected_count': len(changed),
        'saved_nonwhitespace_characters': sum(x['saved'] for x in changed),
        'selection_rule': 'Shortest complete eligible equivalent; every custom helper is counted. Positional simplification is distinguished from reuse.',
        'runtime_executed': False, 'aggregate_statistics': 'Regenerate through the existing publication tools after all group edits.',
        'selected': changed, 'entries': reports,
    }
    REPORT.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in ('reviewed', 'selected_count', 'saved_nonwhitespace_characters')}, indent=2))


if __name__ == '__main__':
    main()

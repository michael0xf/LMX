#!/usr/bin/env python3
"""Check the 24 current Haskell comparisons; deferred counts are not failures."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / 'tools'))
from lmx_style_variants import validate_variants, normalize, metrics_deferred


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path)
    args = parser.parse_args()
    index = json.loads((ROOT / 'haskell_comparision/comparison_index.json').read_text())
    checks = []; errors = []; sources = set()
    def check(ok, label):
        checks.append(label)
        if not ok: errors.append(label)
    check(len(index['entries']) == 24, 'all 24 scenario IDs retained')
    for entry in index['entries']:
        ident = entry['id']
        issues = validate_variants(entry, ROOT)
        check(not issues, ident + ': source/style/declaration gates: ' + repr(issues))
        page = (ROOT / entry['lmx_style_comparison']).read_text()
        blocks = [normalize(m[1]) for m in re.finditer(r'^```lmx\n(.*?)^```\s*$', page, re.M | re.S)]
        variants = entry['lmx_variants']
        expected = [normalize(variants['functional']['code'])] if entry['style_relation'] == 'same_minimal_form' else [normalize(variants[s]['code']) for s in ('procedural', 'functional')]
        check(blocks == expected, ident + ': distinct LMX bodies appear exactly once')
        for style, variant in variants.items():
            sources.add(variant['source_file'])
            if args.baseline:
                old = args.baseline / 'patterns/examples/lmx'
                prior = old / 'procedural' / (ident + '.lm3') if style == 'procedural' else old / (ident + '.lm3')
                if not prior.exists(): prior = old / (ident + '.lm3')
                check(prior.is_file() and prior.read_bytes() == (ROOT / variant['source_file']).read_bytes(), ident + '/' + style + ': parser-checked bytes preserved')
        foreign = (ROOT / entry['foreign_source']).read_text()
        check(foreign == entry['foreign_code'], ident + ': Haskell source/JSON')
        check(hashlib.sha256(foreign.encode()).hexdigest() == entry['foreign_listing_sha256'], ident + ': current Haskell hash')
        check(entry['status'] in ('complete_pair', 'related_analogy'), ident + ': foreign listing and explicit comparison boundary')
        check('без сложного' not in page.lower(), ident + ': no reduced Throws metric')
    report = {'status': 'PASS' if not errors else 'FAIL', 'checks': len(checks), 'errors': errors,
              'scenarios': len(index['entries']), 'unique_lmx_sources': len(sources),
              'runtime_execution': 'NOT_RUN', 'metrics_recounted': False,
              'scope': 'Current source/JSON/Markdown boundaries, optional exact LMX baseline preservation; historical numerical reports are not refreshed.'}
    (ROOT / 'validation/style_variants_expansion.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(report, ensure_ascii=False)); return bool(errors)


if __name__ == '__main__':
    raise SystemExit(main())

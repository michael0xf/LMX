#!/usr/bin/env python3
"""Recount current group sources; both LMX styles include all source fragments."""
from pathlib import Path
import csv
import json
from lmx_style_variants import measure, validate_variants

ROOT = Path(__file__).resolve().parents[1]

def main():
    count = 0
    for path in sorted(ROOT.glob('[0-9][0-9]_*/patterns.json')):
        data = json.loads(path.read_text())
        rows = []
        for item in data['patterns']:
            row = {'id': item['id'], 'pattern': item['name'],
                   'kind': item.get('kind', 'algorithm' if path.parent.name=='10_algorithms' else 'pattern'),
                   'source': f"{item['id']:03d}_{item['slug']}_comparision.md"}
            pair = item.get('languages', data['languages'])
            row.update(language_1=pair[0], language_2=pair[1])
            if item.get('lmx_variants'):
                issues = validate_variants(item, path.parent)
                if issues: raise ValueError((item['id'], issues))
                for style, variant in item['lmx_variants'].items():
                    m = measure(variant['code'])
                    for key in ('characters', 'nonblank_lines', 'utf8_bytes', 'sha256'):
                        row['LMX_'+style+'_'+key] = m[key]
            for listing in item['listings']:
                if listing['language']=='LMX' and item.get('lmx_variants'): continue
                m = measure(listing['code'])
                label = 'LMX_implementation' if listing['language']=='LMX' and item.get('kind')=='implementation' else listing['language']
                for key in ('characters', 'nonblank_lines', 'utf8_bytes', 'sha256'):
                    row[label+'_'+key] = m[key]
            rows.append(row)
        fields = list(dict.fromkeys(key for row in rows for key in row))
        target = path.parent/f'LMX_Comparison_{path.parent.name}.csv'
        with target.open('w', encoding='utf-8-sig', newline='') as stream:
            writer=csv.DictWriter(stream, fieldnames=fields)
            writer.writeheader(); writer.writerows(rows)
        count += len(rows)
    print(json.dumps({'groups':len(list(ROOT.glob('[0-9][0-9]_*/patterns.json'))),'records':count,'metrics':'current full sources'}))

if __name__=='__main__': main()

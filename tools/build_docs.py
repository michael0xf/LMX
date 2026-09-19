"""Render paired grammar documents from reviewed bilingual sections and source excerpts."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'provenance' / 'grammar.json'

def render(data, lang):
    title = 'Грамматика LMX' if lang == 'ru' else 'LMX grammar'
    out = [f'# {title}', '']
    out += [f'- [{s["number"]}. {s[lang]["title"]}](#{s["id"]})' for s in data['sections']]
    out += ['']
    for section in data['sections']:
        out += [f'<a id="{section["id"]}"></a>', '', f'## {section["number"]}. {section[lang]["title"]}', '', section[lang]['text'], '']
        for example in section.get('examples', []):
            label = example.get(lang, 'Исходный фрагмент' if lang == 'ru' else 'Source excerpt')
            origin = example.get('origin', f'`Lingvamyxa_spec.txt`, {example.get("start")}–{example.get("end")}')
            out += [f'**{label}** — {origin}.', '', '````text', example['text'], '````', '']
    return '\n'.join(out)

def main():
    data = json.loads(DATA.read_text(encoding='utf-8'))
    for lang in ('ru', 'en'):
        (ROOT / 'docs' / f'grammar.{lang}.md').write_text(render(data, lang), encoding='utf-8', newline='\n')
    examples = [e for s in data['sections'] for e in s.get('examples', [])]
    print(f'{len(data["sections"])} paired sections; {len(examples)} source excerpts')

if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Refresh the combined guide from authored Haskell comparison pages.

The historical command name remains usable. Both LMX styles are retained;
shared bodies appear once. This command neither selects by size nor recounts
statistics. Source fragments and comparison pages remain canonical.
"""
from pathlib import Path
import json
import os
import re
import sys

PATTERNS = Path(__file__).resolve().parents[2]
EXAMPLES = PATTERNS / 'examples'
GROUP = EXAMPLES / 'haskell_comparision'
TARGET = PATTERNS / 'LMX_examples_and_analogies.ru.md'
MARKER = '## Дополнительные главы и пояснения к примерам LMX'


def relative_links(text, source, destination):
    def move(match):
        link = match.group(2)
        if re.match(r'[a-zA-Z][a-zA-Z0-9+.-]*:', link) or link.startswith('#'):
            return match.group(0)
        path, sep, anchor = link.partition('#')
        target = (source / path).resolve()
        return match.group(1) + os.path.relpath(target, destination) + (sep + anchor if sep else '') + ')'
    return re.sub(r'(\]\()([^\s)]+)\)', move, text)


def main():
    if sys.argv[1:] not in ([], ['--guide-only']):
        raise SystemExit('usage: select_variants.py [--guide-only]')
    index = json.loads((GROUP / 'comparison_index.json').read_text())
    old = TARGET.read_text()
    if MARKER not in old:
        raise ValueError('Authored supplementary chapters must be retained')
    supplement = old[old.index(MARKER):]
    header = '''# Примеры LMX и аналоги Haskell: две полные стилевые записи

Все 24 исходных сценария имеют отдельные Haskell-реализации и страницы сравнения в [haskell_comparision](examples/haskell_comparision/README.md). Сохранены обе LMX-формы одного договора; одинаковый минимальный текст показан один раз. Граница полной пары или ограниченной аналогии указана у каждого сценария.

LMX запускается с корня как L3 Thread без DATA и пользовательских аргументов. Именованные операции примеров выполняются после старта по обычным правилам; Haskell Main относится только к контрольному тестовому harness. [Профили запуска](../LMX_semantics.en.md#source-entry-profiles).

Размеры пересчитаны по актуальным исходникам. Сравниваются обе полные LMX-формы и сопоставимый иностранный листинг, включая необходимые собственные helpers и Throws. Неполные аналогии не получают числового победителя.
'''
    parts = [header.rstrip()]
    for entry in index['entries']:
        page = EXAMPLES / entry['lmx_style_comparison']
        text = page.read_text().split('\n', 1)[1].strip()
        text = relative_links(text, page.parent, TARGET.parent)
        parts.append(f'<a id="{entry["id"].lower()}"></a>\n### {entry["id"]}. {entry["title"]}\n\n' + text)
    TARGET.write_text('\n\n'.join(parts) + '\n\n' + supplement)
    print(json.dumps({'guide': str(TARGET.relative_to(PATTERNS)), 'scenarios': len(index['entries']),
                      'source_files_changed': False, 'metrics_recounted': False}))


if __name__ == '__main__':
    main()

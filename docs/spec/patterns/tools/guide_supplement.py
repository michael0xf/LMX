"""Compose the measured guide with its permanent, uncounted semantic chapters."""
from pathlib import Path
import os
import re

STRUCTURAL_ANCHORS = {'basis', 'haskell-to-lmx', 'lmx-to-haskell', 'arrays',
                      'validation', 'messages', 'patterns', 'coverage', 'r06'}


def _rebase_links(text, source, target):
    def replace(match):
        address = match[1]
        if re.match(r'^[A-Za-z][A-Za-z0-9+.-]*:', address) or address.startswith('/'):
            return match[0]
        path, separator, fragment = address.partition('#')
        if not path:
            return match[0]
        destination = (source.parent/path).resolve()
        if destination == target.resolve() and separator:
            rewritten = '#'+fragment
        else:
            rewritten = os.path.relpath(destination, target.parent)
            if separator:
                rewritten += '#'+fragment
        return ']('+rewritten+')'
    # Link-like text inside a source body is source, not documentation markup.
    chunks = []; offset = 0
    for fence in re.finditer(r'^```[^\n]*\n[\s\S]*?^```[ \t]*$', text, re.M):
        chunks.append(re.sub(r'\]\(([^\n)]+)\)', replace, text[offset:fence.start()]))
        chunks.append(fence[0]); offset = fence.end()
    chunks.append(re.sub(r'\]\(([^\n)]+)\)', replace, text[offset:]))
    return ''.join(chunks)


def compose_guide(compared_text, examples, target, expected_fixtures):
    source = examples/'GUIDE_SUPPLEMENTARY.md'
    if not source.is_file():
        raise ValueError('The permanent supplementary guide is missing; refusing to publish a truncated guide')
    supplement = source.read_text()
    anchors = set(re.findall(r'<a\s+(?:id|name)="([^"]+)"', supplement))
    required = STRUCTURAL_ANCHORS | {row['id'].lower() for row in expected_fixtures}
    if not required <= anchors:
        raise ValueError('Supplementary guide lost required anchors: '+repr(sorted(required-anchors)))
    supplement = _rebase_links(supplement, source, target)
    supplement = re.sub(r'^# ', '## ', supplement, count=1)
    combined = compared_text.rstrip()+'\n\n'+supplement.rstrip()+'\n'
    all_anchors = re.findall(r'<a\s+(?:id|name)="([^"]+)"', combined)
    if len(all_anchors) != len(set(all_anchors)):
        raise ValueError('Guide contains duplicate explicit anchors')
    return combined

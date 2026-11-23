#!/usr/bin/env python3
"""One-time migration from the preceding archive to the user's exact API table.

Run before adding the new splice implementation. A completed receipt makes
reruns a no-op, since the new splice must never be renamed to replaceRange.
"""
from pathlib import Path
import io
import json
import re
import tokenize

PATTERNS = Path(__file__).resolve().parents[1]
ROOT = PATTERNS.parents[1]
MAP_FILE = PATTERNS / 'api_revision_20261122.json'
RECEIPT = PATTERNS / 'validation/api_revision_rename_20261122.json'
SPEC = json.loads(MAP_FILE.read_text())
PUBLIC = SPEC['map']
INTERNAL = {
    'FxSeqSplice': 'FxSeqReplaceRange',
    'FxSeqDeleteat': 'FxSeqDeleteAt',
    'RxBackref': 'RxSameAs',
    'RxLookahead': 'RxAhead',
    'RxNegativeLookahead': 'RxNotAhead',
    'RxLookbehind': 'RxBehind',
    'RxNegativeLookbehind': 'RxNotBehind',
    'RxFullmatch': 'RxWholeMatch',
    'RxEachmatch': 'RxEachMatch',
}
NAMES = {**PUBLIC, **INTERNAL}
RX = re.compile(r'(?<!\w)(' + '|'.join(re.escape(x) for x in sorted(NAMES, key=len, reverse=True)) + r')(?!\w)')
FOREIGN = {'haskell', 'scala', 'java', 'python', 'c++', 'c#', 'go', 'rust', 'erlang', 'typescript', 'javascript', 'julia', 'matlab', 'perl', 'swift'}
FOREIGN_FENCES = FOREIGN | {'cpp', 'csharp', 'cs', 'js', 'c', 'bash', 'sh', 'shell', 'ruby', 'clojure', 'lisp', 'scheme', 'commonlisp', 'kotlin'}
FOREIGN_WORDS = re.compile(r'\b(?:Scala|Java|JavaScript|Haskell|Parsec|Python|Perl|Julia|MATLAB|Swift|NumPy|pandas)\b')
KEEP_KEYS = {'previous_controls', 'former_name', 'original_source_sha256_at_import', 'original_code', 'source_sha256', 'sha256'}


def replace(text):
    parts = re.split(r'(https?://[^\s<>"\)]+)', text)
    return ''.join(p if p.startswith(('http://', 'https://')) else RX.sub(lambda m: NAMES[m[0]], p) for p in parts)


def prose(line):
    # Bibliographic mentions of other APIs are not LMX identifiers. Mixed
    # comparison rows and the naming document are reviewed separately.
    if FOREIGN_WORDS.search(line) and 'LMX' not in line:
        return line
    return replace(line)


def markdown(text):
    out = []
    fence = None
    lang = ''
    fence_rx = re.compile(r'^\s*([' + chr(96) + r'~]{3,})([^\n]*)')
    for line in text.splitlines(keepends=True):
        m = fence_rx.match(line)
        if m:
            if fence is None:
                fence, lang = m[1][0], m[2].strip().lower().split(' ')[0]
            elif m[1][0] == fence:
                fence, lang = None, ''
            out.append(line)
        elif fence:
            out.append(line if lang in FOREIGN_FENCES else replace(line))
        else:
            out.append(prose(line))
    return ''.join(out)


def walk(value, key=None):
    if str(key).lower() in FOREIGN or key in KEEP_KEYS:
        return value
    if isinstance(value, dict):
        if str(value.get('language', '')).lower() in FOREIGN:
            return value
        out = {}
        for k, v in value.items():
            nk = k if str(k).lower() in FOREIGN or k in KEEP_KEYS else replace(k)
            if nk in out:
                raise ValueError('Migration would merge distinct JSON keys: ' + repr(k))
            out[nk] = walk(v, k)
        return out
    if isinstance(value, list):
        return [walk(x) for x in value]
    if isinstance(value, str):
        return markdown(value)
    return value


def python_strings(text):
    tokens = []
    for t in tokenize.generate_tokens(io.StringIO(text).readline):
        if t.type in {tokenize.STRING, tokenize.COMMENT}:
            t = tokenize.TokenInfo(t.type, markdown(t.string), t.start, t.end, t.line)
        tokens.append(t)
    return tokenize.untokenize(tokens)


def main():
    if RECEIPT.exists():
        previous = json.loads(RECEIPT.read_text())
        if previous.get('revision') != SPEC['revision'] or previous.get('public_map') != PUBLIC:
            raise SystemExit('Different migration receipt; review before applying a new mapping')
        print(json.dumps({'already_applied': True, 'revision': SPEC['revision']}))
        return
    skipped = {
        MAP_FILE,
        Path(__file__).resolve(),
        PATTERNS / 'api_renaming_20261122.json',
        PATTERNS / 'validation/api_renaming_20261122.json',
        PATTERNS / 'tools/rename_readable_api.py',
        PATTERNS / 'reference/current_upload_baseline/primary_sources.json',
        ROOT / '1/NAMING_2026-11-22.md',
    }
    changes = []
    for path in sorted(ROOT.rglob('*')):
        if not path.is_file() or path in skipped or '__pycache__' in path.parts:
            continue
        if path.suffix not in {'.md', '.lmx', '.lm3', '.lm2', '.json', '.py'}:
            continue
        if path.suffix == '.py' and 'tools' not in path.parts:
            continue
        original = path.read_text(encoding='utf-8-sig')
        if path.suffix == '.json':
            edited = json.dumps(walk(json.loads(original)), ensure_ascii=False, indent=2) + '\n'
        elif path.suffix == '.md':
            edited = markdown(original)
        elif path.suffix == '.py':
            edited = python_strings(original)
        else:
            edited = replace(original)
        if edited != original:
            path.write_text(edited)
            changes.append(path.relative_to(ROOT).as_posix())
    receipt = {
        'revision': SPEC['revision'],
        'public_map': PUBLIC,
        'internal_map': INTERNAL,
        'new_receivers_added_after_migration': SPEC['new_receivers'],
        'changed_files': changes,
        'foreign_language_code_renamed': False,
        'imported_source_baseline_renamed': False,
        'runtime_execution': 'NOT_RUN',
    }
    RECEIPT.parent.mkdir(parents=True, exist_ok=True)
    RECEIPT.write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({'public_renames': len(PUBLIC), 'changed_files': len(changes), 'new_receivers': SPEC['new_receivers']}))


if __name__ == '__main__':
    main()

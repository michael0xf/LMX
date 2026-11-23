#!/usr/bin/env python3
"""Record explicit finite throws declarations without inferring effects.

The earlier lexical inference pass accumulated conservative seeds, including
blanket fixture failures. This tool preserves those authored declarations; it
does not prove that they are minimal, complete, caught, or executable. Source
formatting is preserved by default. The optional --normalize legacy pass factors
equal lists through qualified copy streams; it is never required for a valid
contract. Published comparisons count the complete source, including every
authored declaration; this tool introduces no alternative Throws metric.

The existing effect_contracts.json is a preservation guard, not an inference
input. An intentional contract edit must update that reviewed declaration
snapshot together with the LMX source; an uncoordinated mismatch is rejected.
"""
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
BANK = Path('src/failures.lmx')
BANK_ROOT = 'FxThrows'
REPORT = ROOT / 'tests/effect_contracts.json'
AUDIT = ROOT / 'tests/effect_formatting_review.json'
REGEN = ROOT / 'tests/effect_regeneration_review.json'
IDENT = r'[A-Za-z_]\w*'
QUALIFIED = rf'{IDENT}(?:\\{IDENT})*'
HEADER = re.compile(rf'^( *)(?:independent:\s*)?({IDENT}):\s*$')
DECL = re.compile(r'^( *)throws:\s*(.*?)\s*$')
COPY = re.compile(rf'copy\(\s*({QUALIFIED})\s*\)|copy:\s*({QUALIFIED})')

# These readable names identify exact conservative declarations, not categories
# inferred from code. Unknown future sets remain inline until explicitly named.
NAMES = {
    'kernel': 'FxKernelFailure FxTypeToken',
    'call': 'FxCallFailure FxKernelFailure FxTypeToken',
    'sequence': 'FxKernelFailure FxTypeToken ReceiverIndex SequenceSize',
    'adapter': 'FxArity FxIndex FxKernelFailure FxTypeToken ReceiverIndex SequenceSize',
    'capture': 'FxArity FxIndex FxKernelFailure FxRecordArity FxTypeToken ReceiverIndex SequenceSize',
    'traversal': 'FxCallFailure FxKernelFailure FxTypeToken ReceiverIndex SequenceSize',
    'selection': 'FxIndex FxKernelFailure FxTypeToken ReceiverIndex SequenceSize',
    'mutation': 'FxKernelFailure FxTypeToken ReceiverIndex SequenceElement SequenceSize',
    'fixture': 'FxArity FxIndex FxKernelFailure FxRecordArity FxTypeToken',
    'lazyfixture': 'FxArity FxIndex FxKernelFailure FxLazyCycle FxRecordArity FxTypeToken',
    'mutationfixture': 'FxArity FxIndex FxKernelFailure FxRecordArity FxTypeToken ReceiverIndex SequenceElement SequenceSize',
    'recordcall': 'FxCallFailure FxKernelFailure FxRecordArity FxTypeToken',
    'snapshot': 'FxCallFailure FxIndex FxKernelFailure FxRecordArity FxTypeToken ReceiverIndex SequenceSize',
    'retry': 'FxArity FxCallFailure FxIndex FxKernelFailure FxRecordArity FxTypeToken ReceiverIndex SequenceSize',
    'predicate': 'FxCallFailure FxKernelFailure FxPredicate FxTypeToken ReceiverIndex',
    'permutation': 'FxArity FxIndex FxKernelFailure FxTypeToken ReceiverIndex ReceiverPermutation SequenceSize',
    'sequencefixture': 'FxArity FxCallFailure FxIndex FxKernelFailure FxPredicate FxRecordArity FxShape FxTypeToken ReceiverIndex ReceiverPermutation SequenceElement SequenceSize SequenceStep',
    'rangefixture': 'FxArity FxIndex FxKernelFailure FxRecordArity FxTypeToken SequenceSize SequenceStep',
    'reorder': 'FxKernelFailure FxTypeToken ReceiverIndex ReceiverPermutation SequenceSize',
}
BY_SET = {tuple(sorted(value.split())): name for name, value in NAMES.items()}
BANK_HEADER = ('# Shared finite throws lists; ordinary copy streams preserve their names.\n'
               '# Conservative declarations are retained, not inferred or minimized.\n\n')


def count(text):
    return sum(not ch.isspace() for ch in text)


def digest(value):
    text = value if isinstance(value, str) else json.dumps(value, sort_keys=True)
    return hashlib.sha256(text.encode()).hexdigest()


def mask(text):
    """Keep line positions while hiding comments and source literals."""
    out = list(text)
    quote = None
    comment = False
    i = 0
    while i < len(text):
        ch = text[i]
        if comment:
            if ch == '\n':
                comment = False
            else:
                out[i] = ' '
        elif quote:
            if ch != '\n':
                out[i] = ' '
            if ch == '\\' and quote != '`' and i + 1 < len(text):
                i += 1
                if text[i] != '\n':
                    out[i] = ' '
            elif ch == quote:
                if quote == '`' and i + 1 < len(text) and text[i + 1] == '`':
                    i += 1
                    out[i] = ' '
                else:
                    quote = None
        elif ch == '#':
            out[i] = ' '
            comment = True
        elif ch in ('"', "'", '`'):
            out[i] = ' '
            quote = ch
        i += 1
    if quote:
        raise ValueError('unterminated literal; refusing to normalize')
    return ''.join(out)


@dataclass
class Span:
    file: Path
    start: int
    end: int
    indent: int
    key: str
    tail: str = ''


class Source:
    def __init__(self, texts):
        self.texts = texts
        self.lines = {p: s.splitlines(keepends=True) for p, s in texts.items()}
        self.clean = {p: mask(s).splitlines() for p, s in texts.items()}
        self.headers = defaultdict(list)
        self.declarations = []
        for path, lines in self.clean.items():
            stack = []
            raw = self.lines[path]
            for i, line in enumerate(lines):
                if not raw[i].strip():
                    stack.clear()
                    continue
                if not line.strip():
                    continue
                indent = len(line) - len(line.lstrip())
                while stack and stack[-1].indent >= indent:
                    stack.pop()
                decl = DECL.fullmatch(line)
                if decl:
                    if not stack:
                        raise ValueError(f'{path}:{i + 1}: throws without a containing structure')
                    self.declarations.append(Span(path, i, self.end(path, i, indent), indent,
                                                  stack[-1].key, decl.group(2)))
                    continue
                if re.search(r'\bthrows\s*:', line):
                    raise ValueError(f'{path}:{i + 1}: unsupported inline throws form')
                header = HEADER.fullmatch(line)
                if header:
                    key = '\\'.join([stack[-1].key, header.group(2)] if stack else [header.group(2)])
                    span = Span(path, i, self.end(path, i, indent), indent, key)
                    self.headers[key].append(span)
                    stack.append(span)
        self.cache = {}

    def end(self, path, start, indent):
        for i in range(start + 1, len(self.clean[path])):
            raw = self.lines[path][i]
            if not raw.strip():
                return i
            if raw.lstrip().startswith('#') and len(raw) - len(raw.lstrip()) <= indent:
                following = next((j for j in range(i + 1, len(self.clean[path]))
                                  if not self.lines[path][j].strip() or self.clean[path][j].strip()), None)
                if following is None or not self.lines[path][following].strip():
                    return i
                next_line = self.clean[path][following]
                if len(next_line) - len(next_line.lstrip()) <= indent:
                    return i
            line = self.clean[path][i]
            if line.strip() and len(line) - len(line.lstrip()) <= indent:
                return i
        return len(self.clean[path])

    def entries(self, span):
        for raw in self.lines[span.file][span.start:span.end]:
            if any(mark in raw.split('#', 1)[0] for mark in ('"', "'", '`')):
                raise ValueError(f'{span.file}:{span.start + 1}: literal in finite failure list is unsupported')
        values = [span.tail] if span.tail else []
        for i in range(span.start + 1, span.end):
            line = self.clean[span.file][i]
            if not line.strip():
                continue
            if len(line) - len(line.lstrip()) != span.indent + 4:
                raise ValueError(f'{span.file}:{i + 1}: unsupported nested failure list')
            values.append(line.strip())
        return values

    def resolve(self, span, visiting=()):
        names = set()
        entries = []
        token = re.compile(rf'copy\(\s*{QUALIFIED}\s*\)|copy:\s*{QUALIFIED}|{IDENT}')
        for line in self.entries(span):
            offset = 0
            for match in token.finditer(line):
                if line[offset:match.start()].strip():
                    raise ValueError(f'{span.file}:{span.start + 1}: unsupported failure-list entry {line!r}')
                entries.append(match.group())
                offset = match.end()
            if line[offset:].strip():
                raise ValueError(f'{span.file}:{span.start + 1}: unsupported failure-list entry {line!r}')
        for entry in entries:
            match = COPY.fullmatch(entry)
            if match:
                target = match.group(1) or match.group(2)
                if target not in self.headers:
                    parts = span.key.split('\\')
                    for size in range(len(parts), 0, -1):
                        candidate = '\\'.join(parts[:size] + [target])
                        if candidate in self.headers:
                            target = candidate
                            break
                if target in visiting:
                    raise ValueError('cyclic failure list: ' + ' -> '.join(visiting + (target,)))
                if target not in self.cache:
                    choices = self.headers.get(target, [])
                    if len(choices) != 1:
                        raise ValueError(f'failure copy target {target!r}: expected one definition, got {len(choices)}')
                    self.cache[target] = self.resolve(choices[0], visiting + (target,))
                names.update(self.cache[target])
            elif re.fullmatch(rf'{IDENT}(?:\s+{IDENT})*', entry):
                names.update(entry.split())
            else:
                raise ValueError(f'{span.file}:{span.start + 1}: unsupported failure-list entry {entry!r}')
        return tuple(sorted(names))

    def contracts(self):
        result = {}
        for decl in self.declarations:
            if decl.key in result:
                raise ValueError('multiple explicit throws lists in ' + decl.key)
            result[decl.key] = list(self.resolve(decl))
        return dict(sorted(result.items()))

    def without_declarations(self, path):
        lines = self.lines[path][:]
        for decl in sorted((d for d in self.declarations if d.file == path),
                           key=lambda d: d.start, reverse=True):
            lines[decl.start:decl.end] = []
        return ''.join(lines)


def inline(names, indent=0):
    line = ' ' * indent + 'throws:' + (' ' + ' '.join(names) if names else '')
    if len(line) <= 110 or len(names) <= 1:
        return line + '\n'
    return ' ' * indent + 'throws:\n' + ''.join(' ' * (indent + 4) + name + '\n' for name in names)


def reference(name, indent=0):
    return ' ' * indent + f'throws: copy({BANK_ROOT}\\{name})\n'


def field(name, names):
    return '    ' + name + ':\n' + ''.join('        ' + x + '\n' for x in names)


def normalize(texts):
    source = Source(texts)
    contracts = source.contracts()
    occurrences = Counter(tuple(values) for values in contracts.values())
    shared = {}
    groups = []
    for names, uses in sorted(occurrences.items()):
        label = BY_SET.get(names)
        if len(names) < 2 or uses < 2 or not label:
            continue
        explicit = uses * count(inline(names))
        factored = uses * count(reference(label)) + count(field(label, names))
        if factored < explicit:
            shared[names] = label
            groups.append({'field': label, 'names': list(names), 'uses': uses,
                           'explicit_characters': explicit, 'factored_characters': factored,
                           'saved_characters_before_shared_header': explicit - factored})
    bank = BANK_HEADER + BANK_ROOT + ':\n' + ''.join(
        field(name, names) for names, name in sorted(shared.items(), key=lambda item: item[1]))
    if shared and sum(g['saved_characters_before_shared_header'] for g in groups) <= count(BANK_HEADER + BANK_ROOT + ':'):
        shared = {}
        groups = []
        bank = BANK_HEADER + BANK_ROOT + ':\n'
    proposed = dict(texts)
    for path, lines in source.lines.items():
        if path == BANK:
            continue
        changed = lines[:]
        for decl in sorted((d for d in source.declarations if d.file == path),
                           key=lambda d: d.start, reverse=True):
            original = ''.join(lines[decl.start:decl.end])
            if '#' in original:
                raise ValueError(f'{path}:{decl.start + 1}: annotated failure list needs manual formatting')
            names = source.resolve(decl)
            formatted = reference(shared[names], decl.indent) if names in shared else inline(names, decl.indent)
            changed[decl.start:decl.end] = [formatted]
        proposed[path] = ''.join(changed)
    proposed[BANK] = bank
    after = Source(proposed)
    if contracts != after.contracts():
        raise AssertionError('normalization changed finite declarations')
    for path in texts:
        if path != BANK and source.without_declarations(path) != after.without_declarations(path):
            raise AssertionError('normalization changed code outside throws in ' + str(path))
    return proposed, contracts, sorted(groups, key=lambda g: g['field'])


def preserve(texts):
    """Resolve authored lists, including mixed copy/name arguments, unchanged."""
    source = Source(texts)
    contracts = source.contracts()
    groups = []
    for key, spans in sorted(source.headers.items()):
        if not key.startswith(BANK_ROOT + '\\') or len(spans) != 1:
            continue
        names = list(source.resolve(spans[0]))
        uses = sum(len(re.findall(r'copy\(\s*' + re.escape(key) + r'\s*\)', text))
                   for path, text in texts.items() if path != BANK)
        groups.append({'field': key.split('\\')[-1], 'names': names,
                       'uses': uses, 'format': 'as_authored'})
    return dict(texts), contracts, groups


def metrics(texts):
    return {'files': len(texts), 'characters_without_whitespace': sum(count(s) for s in texts.values()),
            'physical_lines': sum(len(s.splitlines()) for s in texts.values()),
            'utf8_bytes': sum(len(s.encode()) for s in texts.values())}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='verify resolved report without writing or requiring compact formatting')
    parser.add_argument('--normalize', action='store_true', help='explicit legacy formatting pass; never changes the finite error set')
    args = parser.parse_args()
    paths = sorted((ROOT / 'src').rglob('*.lmx')) + sorted((ROOT / 'examples').glob('*.lmx'))
    texts = {p.relative_to(ROOT): p.read_text() for p in paths}
    transform = normalize if args.normalize else preserve
    proposed, explicit, groups = transform(texts)
    again, again_contracts, again_groups = transform(proposed)
    if proposed != again or explicit != again_contracts or groups != again_groups:
        raise AssertionError('normalizer is not idempotent')
    old = json.loads(REPORT.read_text())
    before_source = Source(texts)
    for key, values in old.items():
        if key not in before_source.headers:
            raise ValueError('existing report key has no source structure: ' + key)
        if sorted(values) != explicit.get(key, []):
            raise ValueError('existing contract differs from its explicit source: ' + key)
    report = dict(sorted({**{key: [] for key, values in old.items() if not values}, **explicit}.items()))
    changed = sorted(str(path) for path in proposed if proposed[path] != texts.get(path))
    if args.check:
        if changed or old != report:
            raise SystemExit(json.dumps({'normalized': False, 'changed_files': changed,
                                         'report_matches': old == report}))
        print(json.dumps({'normalized': True, 'contracts': len(report), 'explicit_declarations': len(explicit),
                          'shared_lists': len(groups), 'idempotent': True, 'runtime_executed': False}))
        return
    previous = json.loads(AUDIT.read_text()) if AUDIT.exists() else None
    baseline = previous['baseline'] if previous and previous['resolved_contracts_sha256'] == digest(report) else {
        'source': metrics(texts), 'contracts': old,
        'source_sha256': {str(p): digest(s) for p, s in sorted(texts.items())},
        'explicit_declarations': len(explicit),
    }
    audit = {
        'scope': 'Exact resolution of authored finite declarations; no effect inference or LMX execution',
        'source_format': 'normalized' if args.normalize else 'as_authored',
        'runtime_executed': False, 'baseline': baseline, 'current_source': metrics(proposed),
        'resolved_contracts_sha256': digest(report), 'contracts': len(report),
        'explicit_declarations': len(explicit), 'shared_root': BANK_ROOT, 'shared_source': BANK.as_posix(),
        'shared_lists': groups, 'referenced_declarations': sum(g['uses'] for g in groups),
        'original_contracts_preserved': all(report.get(k) == v for k, v in baseline['contracts'].items()),
        'all_explicit_contracts_preserved': True, 'non_throws_code_unchanged': True,
        'idempotent': True,
        'source_characters_saved': baseline['source']['characters_without_whitespace'] - metrics(proposed)['characters_without_whitespace'],
        'limitations': [
            'Existing conservative overdeclarations are intentionally preserved, including old blanket fixture names.',
            'No calls, implicit failures, dynamic targets, catch coverage, or rethrows are inferred or proved.',
            'Only authored identifier lists and unambiguous copy streams are resolved; other syntax is an error.',
            'Source formatting is preserved unless --normalize is explicitly requested. Long Throws are a documented language benefit.',
            'Empty legacy report entries mean no explicit list was recorded; they do not prove a method cannot fail.',
        ],
    }
    if not audit['original_contracts_preserved']:
        raise AssertionError('original report contracts changed')
    # A future reviewed source change can establish a fresh baseline which is
    # already compact. Saving characters was verified for this revision, but
    # is not a perpetual precondition for a valid idempotent normalization.
    audit['revision_source_footprint_reduced'] = audit['source_characters_saved'] > 0
    regen = {
        'scope': 'In-memory contract resolution repeated twice on the current source; exact finite contracts and source text compared',
        'source_format': 'normalized' if args.normalize else 'as_authored',
        'runtime_executed': False, 'effect_inference_performed': False,
        'normalizer': 'tools/sync_effects.py', 'contracts': len(report), 'explicit_declarations': len(explicit),
        'shared_lists': len(groups), 'all_explicit_contracts_preserved': True,
        'prior_report_contracts_preserved': True, 'non_throws_code_unchanged': True,
        'idempotent': True, 'second_run_changed_files': [],
        'resolved_contracts_sha256': digest(report), 'limitations': audit['limitations'],
    }
    for path, text in proposed.items():
        if text != texts.get(path):
            (ROOT / path).write_text(text)
    REPORT.write_text(json.dumps(report, indent=2) + '\n')
    AUDIT.write_text(json.dumps(audit, indent=2) + '\n')
    REGEN.write_text(json.dumps(regen, indent=2) + '\n')
    print(json.dumps({'contracts': len(report), 'explicit_declarations': len(explicit),
                      'shared_lists': len(groups), 'changed_files': changed,
                      'source_characters_saved': audit['source_characters_saved'],
                      'idempotent': True, 'runtime_executed': False}))


if __name__ == '__main__':
    main()

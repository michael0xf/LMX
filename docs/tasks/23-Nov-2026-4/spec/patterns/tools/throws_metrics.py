#!/usr/bin/env python3
"""Supplementary LMX source count: retain the first written Throws argument.

This never rewrites a source file or changes its main count. Headers, the first
argument, complete copy/reference expressions, strings and comments are kept.
A referenced failure bank is measured with its first argument as well; an
external bank is reported separately, never silently added to every client.
This recognises finite name/copy lists, not arbitrary executable LMX expressions.
"""
from functools import lru_cache
from pathlib import Path
import re

METHOD = ('Nonwhitespace Unicode characters; supplementary view keeps every '
          'throws/bank header and its first syntactic argument in source order. '
          'Complete copy/reference expressions, strings and comments remain. '
          'External bank definitions stay outside the measured source boundary '
          'and are reported for once-only dependency accounting.')
_NAME = r'[A-Za-z_][A-Za-z0-9_]*(?:\\[A-Za-z_][A-Za-z0-9_]*)*'
_HEAD = re.compile(r'^( *)([A-Za-z_][A-Za-z0-9_]*):')
_ATOM = re.compile(_NAME)


def _count(text):
    return sum(not ch.isspace() for ch in text)


def _shield(text):
    """Position-preserving mask; quoted tokens remain opaque sentinels."""
    out = list(text)
    quote = None
    comment = False
    escaped = False
    for i, ch in enumerate(text):
        if comment:
            if ch == '\n':
                comment = False
            else:
                out[i] = ' '
            continue
        if quote:
            if ch != '\n':
                out[i] = ' '
            if escaped:
                escaped = False
            elif ch == '\\':
                escaped = True
            elif ch == quote:
                quote = None
            continue
        if ch == '#':
            comment = True
            out[i] = ' '
        elif ch in ('"', "'"):
            quote = ch
            out[i] = '\x01'
    return ''.join(out)


class _Document:
    def __init__(self, text, source='<source>'):
        self.text, self.source = text, source
        self.mask = _shield(text)
        self.lines = self.mask.splitlines(keepends=True)
        self.original_lines = text.splitlines(keepends=True)
        self.starts = []
        at = 0
        for line in self.lines:
            self.starts.append(at)
            at += len(line)
        self.nodes = []
        stack = []
        for i, line in enumerate(self.lines):
            if not self.original_lines[i].strip():
                stack = []
                continue
            head = _HEAD.match(line)
            if not head:
                continue
            indent, name = len(head[1]), head[2]
            while stack and stack[-1]['indent'] >= indent:
                stack.pop()
            path = tuple(x['name'] for x in stack) + (name,)
            end_line = i + 1
            while end_line < len(self.lines):
                if not self.original_lines[end_line].strip():
                    break
                next_line = self.lines[end_line]
                if next_line.strip() and len(next_line) - len(next_line.lstrip(' ')) <= indent:
                    break
                end_line += 1
            end = self.starts[end_line] if end_line < len(self.starts) else len(text)
            node = {'doc': self, 'name': name, 'path': path, 'indent': indent,
                    'start': self.starts[i] + indent,
                    'body': self.starts[i] + head.end(), 'end': end,
                    'lines': [i + 1, end_line]}
            node['arguments'] = _arguments(self.mask, node['body'], end)
            self.nodes.append(node)
            stack.append(node)
        self.index = {node['path']: node for node in self.nodes}


def _arguments(mask, begin, end):
    """Accept only a finite sequence of names or copy(single named bank)."""
    args, i = [], begin
    while i < end:
        while i < end and mask[i].isspace():
            i += 1
        if i == end or mask[i] == ';':
            return args
        match = _ATOM.match(mask, i)
        if not match:
            return None
        start, name = i, match[0]
        i = match.end()
        look = i
        while look < end and mask[look].isspace():
            look += 1
        if look < end and mask[look] == '(':
            depth, stop = 1, look + 1
            while stop < end and depth:
                if mask[stop] == '(':
                    depth += 1
                elif mask[stop] == ')':
                    depth -= 1
                stop += 1
            if depth or name != 'copy':
                return None
            inside = mask[look + 1:stop - 1].strip()
            if not re.fullmatch(_NAME, inside):
                return None
            args.append({'start': start, 'end': stop, 'copy': inside})
            i = stop
        else:
            if look < end and mask[look] in ':([{':
                return None
            args.append({'start': start, 'end': i, 'name': name})
    return args


def _references(node):
    return [arg['copy'] for arg in node['arguments'] or [] if 'copy' in arg]


def _resolve(reference, node, local, external):
    parts = tuple(reference.split('\\'))
    # The local exact/nearest path wins. A unique remaining local suffix also
    # permits a shared dynamic bank outside this lexical branch.
    context = node['path'][:-1]
    for size in range(len(context), -1, -1):
        found = local.index.get(context[:size] + parts)
        if found:
            return found
    found = [n for n in local.nodes if n['path'][-len(parts):] == parts]
    if len(found) == 1:
        return found[0]
    candidates = external.get(parts, [])
    return candidates[0] if len(candidates) == 1 else None


@lru_cache(maxsize=8)
def _library(signature):
    documents = [_Document(Path(path).read_text(), path) for path, _, _ in signature]
    index = {}
    for doc in documents:
        for node in doc.nodes:
            index.setdefault(node['path'], []).append(node)
    banks = set()
    pending = [node for doc in documents for node in doc.nodes if node['name'] == 'throws']
    seen = set()
    while pending:
        node = pending.pop()
        identity = (node['doc'].source, node['start'])
        if identity in seen:
            continue
        seen.add(identity)
        for reference in _references(node):
            found = _resolve(reference, node, node['doc'], index)
            if found:
                banks.add(found['path'])
                pending.append(found)
    return index, banks


def _signature(patterns_root):
    folder = Path(patterns_root) / 'LMX_Fn_Receivers/src'
    if not folder.is_dir():
        return ()
    return tuple((str(path.resolve()), path.stat().st_mtime_ns, path.stat().st_size)
                 for path in sorted(folder.rglob('*.lmx')))


def _spelling(node, arg):
    return node['doc'].text[arg['start']:arg['end']]


def _removed_positions(node):
    """Only actual code after the first arg; shielded comments stay counted."""
    positions = set()
    for arg in (node['arguments'] or [])[1:]:
        positions.update(i for i in range(arg['start'], arg['end'])
                         if not node['doc'].mask[i].isspace()
                         and node['doc'].mask[i] != '\x01')
    return positions


def measure_throws(code: str, patterns_root: Path | None = None) -> dict:
    """Return full/supplementary counts plus auditable per-source exclusions.

    `without_complex_throws_characters` belongs to exactly `code`, with no
    automatic source normalization or hidden dependency additions. Definitions
    outside that boundary appear in `referenced_definitions` only.
    """
    root = Path(patterns_root) if patterns_root else Path(__file__).resolve().parents[1]
    external, known_banks = _library(_signature(root))
    doc = _Document(code)
    selected = {}
    unresolved, references = [], {}
    pending = []
    for node in doc.nodes:
        if node['name'] == 'throws':
            selected[node['start']] = (node, 'throws_clause')
            pending.append(node)
        elif node['path'] in known_banks or node['name'] == 'Throws' or node['name'].endswith('Failures'):
            if node['arguments'] is not None:
                selected[node['start']] = (node, 'shared_bank')
                pending.append(node)
    visited = set()
    while pending:
        node = pending.pop()
        identity = (node['doc'].source, node['start'])
        if identity in visited:
            continue
        visited.add(identity)
        if node['arguments'] is None:
            unresolved.append({'source': node['doc'].source, 'lines': node['lines'],
                               'reference': '\\'.join(node['path']),
                               'reason': 'Not a finite names/copy list; source kept unchanged.'})
            continue
        for reference in _references(node):
            found = _resolve(reference, node, node['doc'], external)
            if found is None:
                unresolved.append({'source': node['doc'].source, 'lines': node['lines'],
                                   'reference': reference,
                                   'reason': 'Definition unavailable or ambiguous; complete copy expression retained.'})
                continue
            key = (found['doc'].source, found['path'])
            references[key] = found
            if found['doc'] is doc:
                selected[found['start']] = (found, 'shared_bank')
            pending.append(found)

    def names(node, seen=None):
        seen = set() if seen is None else set(seen)
        key = (node['doc'].source, node['start'])
        if key in seen or node['arguments'] is None:
            return []
        seen.add(key)
        values = []
        for arg in node['arguments']:
            if 'name' in arg:
                values.append(arg['name'])
            else:
                found = _resolve(arg['copy'], node, node['doc'], external)
                if found:
                    values.extend(names(found, seen))
        return list(dict.fromkeys(values))

    excluded, exclusions = set(), []
    for node, kind in sorted(selected.values(), key=lambda x: x[0]['start']):
        args = node['arguments']
        if args is None or len(args) < 2:
            continue
        positions = _removed_positions(node) - excluded
        excluded.update(positions)
        exclusions.append({'kind': kind, 'lines': node['lines'],
                           'path': '\\'.join(node['path']),
                           'argument_count': len(args),
                           'kept_argument': _spelling(node, args[0]),
                           'removed_arguments': [_spelling(node, arg) for arg in args[1:]],
                           'resolved_names': names(node),
                           'removed_characters': len(positions),
                           'reason': 'Only arguments after the first written argument are omitted from this supplementary count.'})
    bank_report = []
    for (_, _), node in sorted(references.items()):
        args = node['arguments']
        fragment = node['doc'].text[node['start']:node['end']]
        removed = len(_removed_positions(node))
        try:
            source = Path(node['doc'].source).relative_to(root).as_posix()
        except ValueError:
            source = node['doc'].source
        bank_report.append({'source': source, 'path': '\\'.join(node['path']),
                            'lines': node['lines'], 'included_in_source': node['doc'] is doc,
                            'full_characters': _count(fragment),
                            'without_complex_throws_characters': _count(fragment) - removed,
                            'argument_count': None if args is None else len(args),
                            'kept_argument': _spelling(node, args[0]) if args else None,
                            'resolved_names': names(node)})
    full = _count(code)
    return {'full_characters': full,
            'without_complex_throws_characters': full - len(excluded),
            'removed_characters': len(excluded), 'exclusions': exclusions,
            'referenced_definitions': bank_report, 'unresolved': unresolved,
            'method': METHOD}


def _self_test():
    # No production file or expected count is changed by these fixtures.
    cases = [
        ('direct', 'F:\n    throws: First Second Third\n', len('SecondThird')),
        ('single', 'F:\n    throws: ResourceFailure\n', 0),
        ('copy', 'F:\n    throws: copy(Missing)\n', 0),
        ('mixed', 'F:\n    throws: copy(Missing) Later\n', len('Later')),
        ('bank', 'Throws:\n    Zeta\n    Alpha\n\nF:\n    throws: copy(Throws)\n', len('Alpha')),
        ('strings', 'F:\n    char[]: text "throws: A B"\n    # throws: A B\n', 0),
        ('comments', 'F:\n    throws: A B # throws: C D\n', 1),
        ('multiline', 'F:\n    throws:\n        Zeta\n        Alpha\n', len('Alpha')),
        ('opaque', 'F:\n    throws: choose(A; B)\n', 0),
        ('reference_text', 'F:\n    throws: copy(FxThrows\\call) Other\n', len('Other')),
        ('order', 'Throws: Zeta Alpha Beta\n', len('AlphaBeta')),
        ('duplicate', 'F:\n    throws: Same Same\n', len('Same')),
    ]
    for label, source, expected in cases:
        result = measure_throws(source, Path('/missing-patterns-root'))
        assert result['removed_characters'] == expected, (label, result)
        assert result['full_characters'] - result['without_complex_throws_characters'] == expected
    # Nested copies inside an external bank resolve in that bank's document.
    # The reference and header stay in the client; each bank remains a separate
    # dependency boundary rather than being repeatedly charged to the client.
    from tempfile import TemporaryDirectory
    with TemporaryDirectory() as directory:
        root = Path(directory)
        source_dir = root / 'LMX_Fn_Receivers/src'
        source_dir.mkdir(parents=True)
        (source_dir / 'banks.lmx').write_text('Bank:\n    base: Zeta Alpha\n    shared: copy(base) Beta\n')
        result = measure_throws('F:\n    throws: copy(Bank\\shared)\n', root)
        assert not result['unresolved'], result
        banks = {item['path']: item for item in result['referenced_definitions']}
        assert banks['Bank\\shared']['resolved_names'] == ['Zeta', 'Alpha', 'Beta'], banks
        assert banks['Bank\\base']['kept_argument'] == 'Zeta', banks
        assert result['removed_characters'] == 0
    return len(cases) + 1


if __name__ == '__main__':
    import json
    print(json.dumps({'status': 'PASS', 'fixture_count': _self_test(),
                      'scope': 'Supplementary metric fixtures only; no LMX execution.'}))

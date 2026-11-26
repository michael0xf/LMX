#!/usr/bin/env python3
"""Remove provably redundant standalone LMX closers without relaxing P0.

This is a bounded lexical/layout normalizer, NOT the production parser. It
preserves multi-level cutters, anonymous-group markers, protected payloads and
syntax fixtures. A one-level dedent, physical blank boundary or EOF can make a
closing-only line redundant. No blank line is inserted inside a live block.
"""
from __future__ import annotations

import argparse
from collections import Counter
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re


SOURCE_SUFFIXES = {'.lmx', '.lm1', '.lm2', '.lm3'}
SOURCE_LANGUAGES = {'lmx', 'lm1', 'lm2', 'lm3'}
CUTTER = re.compile(r'^(?:-{3,80}|end\s*:\s*([^\s:;()\[\]{}]+))\s*$')
# These files intentionally exhibit structural grammar, including negative
# cases, or are inputs tied to external parser expectations. Their closers are
# not formatting noise. User-facing ordinary examples remain eligible.
FIXTURE_PARTS = {'parser_cases', 'parser_tests', 'p0_cases', 'negative', 'invalid'}
# This newly supplied design note must remain byte-identical to its attachment.
VERBATIM_DOCUMENTS = {'LMX_INTERPRETER_JIT.md'}


@dataclass
class Line:
    number: int
    raw: str
    code: str
    level: int | None
    kind: str
    cutter: str | None = None
    target: str | None = None
    comment: str = ''
    depth: int = 0


def protected_path(path: Path) -> bool:
    return (path.name in VERBATIM_DOCUMENTS or bool(set(path.parts) & FIXTURE_PARTS)
            or path.name.startswith(('LMX_grammar.', 'L1_grammar.')))


def scan(text: str) -> tuple[list[Line], list[str]]:
    """Shield literals/comments; derive only physical source-level events."""
    rows: list[Line] = []
    warnings: list[str] = []
    quote = None
    raw_fence = None
    pairs: list[str] = []
    columns = [0]
    for number, raw in enumerate(text.splitlines(keepends=True), 1):
        body = raw.rstrip('\r\n')
        if raw_fence is not None:
            if re.fullmatch(re.escape(raw_fence) + r'[ \t]*', body):
                raw_fence = None
            rows.append(Line(number, raw, '', None, 'protected'))
            continue
        if quote is None and re.fullmatch(r'(?:={3,80}|\*{3,80})[ \t]*', body):
            raw_fence = body.rstrip(' \t')
            rows.append(Line(number, raw, '', None, 'protected'))
            continue
        start_quote = quote
        initial_depth = len(pairs)
        clean: list[str] = []
        comment = ''
        i = 0
        while i < len(body):
            ch = body[i]
            if quote is not None:
                if quote in ('"""', "'''"):
                    if body.startswith(quote, i):
                        end = i
                        while end < len(body) and body[end] == quote[0]:
                            end += 1
                        if end - i == 3:
                            quote = None
                        clean.extend(' ' * (end - i)); i = end
                    else:
                        clean.append(' '); i += 1
                    continue
                if quote == '`':
                    if ch == '`':
                        if i + 1 < len(body) and body[i + 1] == '`':
                            clean.extend('  '); i += 2; continue
                        quote = None
                    clean.append(' '); i += 1; continue
                if ch == '\\':
                    width = min(2, len(body) - i)
                    clean.extend(' ' * width); i += width; continue
                if ch == quote:
                    quote = None
                clean.append(' '); i += 1; continue
            if ch == '#':
                comment = body[i:]
                break
            if ch in ('"', "'", '`'):
                quote = ch * 3 if ch != '`' and body.startswith(ch * 3, i) else ch
                # Keep a token placeholder so a literal-only field is a field.
                clean.extend('L' + ' ' * (len(quote) - 1)); i += len(quote)
                continue
            if ch == '{' or ch == '}':
                # Mix has a document-local comment/blank-line scope. Rather
                # than guessing that scope, leave this complete code unit alone.
                warnings.append(f'{number}: Mix requires production P0; code unit preserved')
            if ch in '([{':
                pairs.append(ch)
            elif ch in ')]}':
                if not pairs or pairs[-1] != {')': '(', ']': '[', '}': '{'}[ch]:
                    warnings.append(f'{number}: unmatched paired delimiter; code unit preserved')
                else:
                    pairs.pop()
            clean.append(ch); i += 1
        code = ''.join(clean).rstrip()
        if start_quote is not None:
            kind = 'protected'
            level = None
        elif not body.strip() and quote is None:
            if initial_depth:
                warnings.append(f'{number}: blank boundary in paired form; code unit preserved')
            kind = 'blank'; level = -1; columns = [0]
        elif not code.strip():
            kind = 'comment'; level = None
        else:
            kind = 'item'
            if body.startswith('.'):
                if (re.match(r'^\.[+*/%=<>!&|^:~0-9-]', body)
                        and not re.fullmatch(r'\.+[ \t]*-{3,80}[ \t]*(?:#.*)?', body)):
                    # Column-zero .+ / .: / .5 needs the current lexer's
                    # leading-zone decision. Do not infer a level for a
                    # closer-removal proof from the old dotted-layout subset.
                    warnings.append(f'{number}: leading dot token needs production P0; code unit preserved')
                lead = re.match(r'^[. \t]*', body)[0]
                level = lead.count('.')
                code = code[len(lead):].strip()
            else:
                lead = re.match(r'^[ \t]*', body)[0]
                if '\t' in lead:
                    warnings.append(f'{number}: tab layout not normalized')
                col = len(lead.expandtabs(8))
                if col > columns[-1]:
                    columns.append(col)
                elif col < columns[-1]:
                    if col not in columns:
                        warnings.append(f'{number}: unknown dedent column; code unit preserved')
                    while len(columns) > 1 and col < columns[-1]:
                        columns.pop()
                level = len(columns) - 1
                code = code.lstrip()
        match = CUTTER.fullmatch(code) if kind == 'item' and not initial_depth else None
        rows.append(Line(number, raw, code, level,
                         'cutter' if match else kind,
                         ('end' if match.group(1) else 'dash') if match else None,
                         match.group(1) if match else None,
                         comment, initial_depth))
    if quote is not None or raw_fence is not None or pairs:
        warnings.append('EOF: unclosed protected or paired form; code unit preserved')
    return rows, sorted(set(warnings))


def next_event(rows: list[Line], at: int, removed: set[int]):
    for i in range(at + 1, len(rows)):
        if i not in removed and rows[i].kind not in {'comment', 'protected'}:
            return i, rows[i]
    return None, None


def previous_event(rows: list[Line], at: int, removed: set[int]):
    for i in range(at - 1, -1, -1):
        if i not in removed and rows[i].kind not in {'comment', 'protected'}:
            return i, rows[i]
    return None, None


def known_end_target(rows: list[Line], at: int) -> bool:
    """Require a visible matching head; do not erase a checked unknown close."""
    row = rows[at]
    if row.cutter != 'end':
        return True
    for prev in reversed(rows[:at]):
        if prev.kind == 'blank':
            return False
        if prev.level is None or prev.level > row.level:
            continue
        if prev.level < row.level:
            return False
        if prev.kind == 'cutter':
            return False
        match = re.match(r'^([^\s:]+)\s*:', prev.code)
        return bool(match and match.group(1) == row.target)
    return False


def normalize_text(text: str) -> tuple[str, dict]:
    rows, warnings = scan(text)
    if warnings:
        return text, {'removed': [], 'preserved_code_unit': warnings,
                      'projection_equal': True}
    removed: set[int] = set()
    decisions: dict[int, str] = {}
    changed = True
    while changed:
        changed = False
        for i in reversed(range(len(rows))):
            row = rows[i]
            if i in removed or row.kind != 'cutter' or not known_end_target(rows, i):
                continue
            _, nxt = next_event(rows, i, removed)
            _, prev = previous_event(rows, i, removed)
            if nxt is None or nxt.kind == 'blank':
                reason = 'EOF closes the same forms' if nxt is None else 'physical blank line closes the same forms'
            elif (nxt.kind == 'item' and nxt.level <= row.level
                  and prev is not None and prev.kind == 'item'
                  and prev.level >= row.level
                  and 0 <= prev.level - nxt.level <= 1):
                reason = 'next ordinary item closes by a zero/one-level transition'
            else:
                continue
            removed.add(i); decisions[i] = reason; changed = True
    out = []
    records = []
    for i, row in enumerate(rows):
        if i not in removed:
            out.append(row.raw)
            continue
        # A retained comment is not a blank physical line, hence does not add a
        # full-root closure. Preserve comment text without keeping the cutter.
        if row.comment:
            prefix = re.match(r'^[ \t]*', row.raw)[0]
            eol = '\r\n' if row.raw.endswith('\r\n') else '\n' if row.raw.endswith('\n') else ''
            out.append(prefix + row.comment + eol)
        records.append({'line': row.number, 'closer': row.code,
                        'reason': decisions[i]})
    result = ''.join(out)
    # A bounded projection verifies the retained fields and physical boundaries;
    # it is deliberately not advertised as a P0 graph-equivalence proof.
    def projection(source):
        events, problems = scan(source)
        if problems:
            raise ValueError('normalization produced unsupported layout: ' + '; '.join(problems))
        return [(r.kind, r.level, r.code if r.kind != 'protected' else r.raw)
                for r in events if r.kind not in {'cutter', 'comment'}]
    if projection(text) != projection(result):
        raise ValueError('retained source/layout projection changed')
    return result, {'removed': records, 'projection_equal': True,
                    'preserved_code_unit': []}


def normalize_markdown(text: str) -> tuple[str, dict]:
    """Touch only explicitly tagged LMX fenced blocks, never Markdown rules."""
    lines = text.splitlines(keepends=True)
    out, units = [], []
    i = 0
    while i < len(lines):
        opening = re.match(r'^([ \t]*)(`{3,}|~{3,})[ \t]*([A-Za-z0-9_-]*)[^\r\n]*', lines[i])
        if not opening:
            out.append(lines[i]); i += 1; continue
        indent, fence, language = opening.groups()
        j = i + 1
        while j < len(lines) and not re.fullmatch(re.escape(indent) + re.escape(fence[0]) + '{' + str(len(fence)) + r',}[ \t]*[\r\n]*', lines[j]):
            j += 1
        if j == len(lines):
            out.extend(lines[i:]); break
        out.append(lines[i])
        body = ''.join(lines[i + 1:j])
        if language.lower() in SOURCE_LANGUAGES and not indent:
            revised, detail = normalize_text(body)
            for record in detail['removed']:
                record['line'] += i + 1
            detail['fence_line'] = i + 1
            units.append(detail); out.append(revised)
        else:
            out.append(body)
        out.append(lines[j]); i = j + 1
    return ''.join(out), {'units': units,
                          'removed': [r for u in units for r in u['removed']],
                          'projection_equal': all(u['projection_equal'] for u in units),
                          'preserved_code_unit': [w for u in units for w in u['preserved_code_unit']]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('paths', nargs='+', type=Path)
    parser.add_argument('--write', action='store_true', help='apply safe edits; default is a dry run')
    parser.add_argument('--check', action='store_true', help='exit 1 when redundant closers remain')
    parser.add_argument('--markdown', action='store_true', help='include LMX fences in Markdown')
    parser.add_argument('--report', type=Path)
    parser.add_argument('--relative-to', type=Path)
    args = parser.parse_args()
    paths = []
    for path in args.paths:
        if path.is_dir():
            paths.extend(p for p in path.rglob('*') if p.is_file()
                         and (p.suffix in SOURCE_SUFFIXES or (args.markdown and p.suffix == '.md')))
        elif path.suffix in SOURCE_SUFFIXES or (args.markdown and path.suffix == '.md'):
            paths.append(path)
    counts = Counter()
    records = []
    for path in sorted(set(paths)):
        counts['files_scanned'] += 1
        display = str(path.relative_to(args.relative_to)) if args.relative_to else str(path)
        if protected_path(path):
            kind = 'verbatim_document' if path.name in VERBATIM_DOCUMENTS else 'fixture'
            counts[kind + '_files_preserved'] += 1
            records.append({'file': display, kind + '_preserved': True})
            continue
        with path.open('r', encoding='utf-8', newline='') as stream:
            before = stream.read()
        after, detail = (normalize_markdown(before) if path.suffix == '.md' else normalize_text(before))
        count = len(detail['removed'])
        counts['closers_removed' if args.write else 'removable_closers'] += count
        counts['changed_files' if args.write else 'changeable_files'] += before != after
        counts['code_units_preserved'] += bool(detail['preserved_code_unit'])
        if before != after:
            detail['sha256_before'] = hashlib.sha256(before.encode()).hexdigest()
            detail['sha256_after'] = hashlib.sha256(after.encode()).hexdigest()
            if args.write:
                with path.open('w', encoding='utf-8', newline='') as stream:
                    stream.write(after)
        if count or detail['preserved_code_unit']:
            records.append({'file': display, **detail})
    report = {'mode': 'BOUNDED_LEXICAL_LAYOUT_NORMALIZATION_NOT_P0_NOT_RUNTIME',
              'write': args.write, 'counts': dict(counts), 'files': records,
              'rules': ['Keep multi-level cuts unless a blank boundary or EOF follows',
                        'Keep anonymous-group markers before deeper children',
                        'Keep protected literals, raw comments and syntax fixtures',
                        'No blank lines inserted; no executable terminal removed',
                        'Retained field/layout projection must stay equal'],
              'limitations': ['Not the production parser', 'No receiver/type/runtime verification',
                              'Mix, tabs and unsupported layout are preserved for manual/P0 review']}
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps({'mode': report['mode'], 'counts': dict(counts)}, ensure_ascii=False))
    if args.check and counts['removable_closers']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()

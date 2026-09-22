#!/usr/bin/env python3
"""Rewrite L2 fixtures from the `fn: main` wrapper to top-level entry statements (S2).

L2 has no `main`: a program is the unit body from its first line (author, LMX_blog 2026-09-22,
D3).  This tool performs the mechanical part of that migration on `.lm2` sources:

    fn: main () int              <body statements, dedented one level>
        <body statements>   ->   return: ...
        return: ...
    end: main

* The header line `fn: main () int` is removed; the body lines that follow it (everything more
  indented than the header) are dedented by exactly the body's own indentation step; a closing
  `end: main` at the header's indentation is removed.  A column-header `return:` trailer after
  the header (`fn: main () int` / `return: 0`) is already a unit-level statement and is kept.
* Comment-only lines inside the body are dedented when they are indented like the body and are
  otherwise left alone; blank lines are kept.
* A unit whose `main` has formals is REFUSED and left untouched: arguments arrive as a letter
  (S3, `receive:`), which a mechanical rewrite cannot write.  So is a unit with more than one
  `fn: main`, and any `main` header whose result is not `int`.
* Idempotent: a unit without `fn: main` is left untouched, so a second run changes nothing.
* Bytes are preserved apart from the rewritten lines: a UTF-8 BOM, the line-ending style (LF or
  CRLF) and the presence of a final newline survive.

    python tools/l2_s2_migrate_main.py dev/l2src_sandbox/tests            # rewrite in place
    python tools/l2_s2_migrate_main.py --check dev/l2src_sandbox/tests    # report only

It also REPORTS, without rewriting, every method whose header or body names a non-callable
(unit field, named Structure/model, `independent:` branch) declared below the method: every
non-callable is visible only after its declaration, methods see each other both ways (author,
LMX_blog 2026-09-22).  Moving a declaration changes lexical order, so that is left to a person.
The check is textual and heuristic; the S2 translator is the authority.

Exit status: 0 when nothing was refused or reported, 1 otherwise (the report names every unit),
2 on a usage error.  A refusal or a report is not a failure of the tool.
"""

import argparse
import os
import re
import sys

HEADER = re.compile(r'^(?P<ind>[ \t]*)fn: main \((?P<formals>[^)]*)\)\s*(?P<ret>\S+)\s*$')
ANY_MAIN = re.compile(r'^[ \t]*(?:fn|sub): main\b')
END_MAIN = re.compile(r'^[ \t]*end: main\s*$')


def indent_of(line):
    return len(line) - len(line.lstrip(' \t'))


def split_lines(text):
    """Lines without terminators, the terminator, and whether the text ended with one."""
    eol = '\r\n' if '\r\n' in text else '\n'
    final = text.endswith(eol) or text.endswith('\n')
    body = text[:-len(eol)] if text.endswith(eol) else (text[:-1] if text.endswith('\n') else text)
    return body.split(eol) if body else [], eol, final


def rewrite(lines):
    """Return (new_lines, status, detail).  status: 'rewritten', 'nomain', 'refused'."""
    mains = [i for i, l in enumerate(lines) if ANY_MAIN.match(l)]
    if not mains:
        return lines, 'nomain', ''
    if len(mains) > 1:
        return lines, 'refused', '%d `main` definitions' % len(mains)
    h = mains[0]
    m = HEADER.match(lines[h])
    if not m:
        return lines, 'refused', 'main header is not `fn: main (...) T`: ' + lines[h].strip()
    if m.group('formals').strip():
        return lines, 'refused', 'main has formals (%s): arguments arrive as a letter (S3)' % m.group('formals').strip()
    if m.group('ret') != 'int':
        return lines, 'refused', 'main result is %s, not int' % m.group('ret')
    head = indent_of(lines[h])
    # The body step is the indentation of the first body statement (not a comment).
    step = None
    j = h + 1
    while j < len(lines):
        s = lines[j].strip()
        if s == '' or s.startswith('#'):
            j += 1
            continue
        if indent_of(lines[j]) > head:
            step = indent_of(lines[j]) - head
        break
    out = lines[:h]
    j = h + 1
    while j < len(lines):
        line = lines[j]
        s = line.strip()
        if s == '':
            out.append(line)
            j += 1
            continue
        if s.startswith('#'):
            if step is not None and indent_of(line) >= head + step:
                out.append(line[step:])
            else:
                out.append(line)
            j += 1
            continue
        if indent_of(line) <= head:
            break
        if step is None or line[:head + step].strip(' ') != '':
            return lines, 'refused', 'main body line %d is not indented by the body step' % (j + 1)
        out.append(line[step:])
        j += 1
    if j < len(lines) and END_MAIN.match(lines[j]) and indent_of(lines[j]) == head:
        j += 1
    out.extend(lines[j:])
    return out, 'rewritten', ''


RESERVED = {'L2', 'os', 'prototype', 'profile', 'predef', 'include', 'define', 'independent', 'fn',
            'sub', 'end', 'return', 'if', 'else', 'while', 'for', 'merge', 'const', 'immutable',
            'int', 'char', 'size_t', 'unsigned', 'ulong', 'uchar', 'void', 'node', 'c'}
TYPED_DECL = re.compile(r'^[ \t]*(?:const: |immutable: )?(?:int|char|size_t|unsigned|ulong|uchar|@|@@)[^:\n]*: +([A-Za-z_]\w*)')
METHOD_HEAD = re.compile(r'^[ \t]*(?:fn|sub): ([A-Za-z_]\w*) \(')
NAMED_HEAD = re.compile(r'^[ \t]*([A-Za-z_]\w*):(?:\s*$|\s+\S)')
BRANCH = re.compile(r'^[ \t]*\(\): ([A-Za-z_]\w*)\s*$')
WORD = re.compile(r'[A-Za-z_]\w*')


def words(line):
    """Identifiers of one source line, outside comments and quoted text."""
    line = re.sub(r'"(?:[^"\\]|\\.)*"', ' ', line)
    line = re.sub(r"'(?:[^'\\]|\\.)*'", ' ', line)
    line = line.split('#', 1)[0]
    return set(WORD.findall(line))


def visibility(lines):
    """Backward visibility of every non-callable name (author, LMX_blog 2026-09-22): a method
    may name only non-callables declared ABOVE it (methods see both ways).  Heuristic, textual:
    returns [(method, name, method_line, decl_line)] for unit-level non-callables that a
    method's header or body names although they are declared below the method."""
    heads = [indent_of(l) for l in lines if METHOD_HEAD.match(l)]
    if not heads:
        return []
    unit = min(heads)
    decls = {}
    methods = []
    i = 0
    while i < len(lines):
        line = lines[i]
        s = line.strip()
        if s == '' or s.startswith('#') or indent_of(line) != unit:
            i += 1
            continue
        m = METHOD_HEAD.match(line)
        if m:
            j = i + 1
            while j < len(lines) and (lines[j].strip() == '' or indent_of(lines[j]) > unit or lines[j].strip().startswith('#')):
                j += 1
            if j < len(lines) and lines[j].strip() in ('end: ' + m.group(1),):
                j += 1
            elif j < len(lines) and lines[j].strip().startswith('return:') and indent_of(lines[j]) == unit:
                j += 1
            methods.append((m.group(1), i, j))
            i = j
            continue
        if s.startswith('independent:'):
            j = i + 1
            while j < len(lines) and not (indent_of(lines[j]) == unit and lines[j].strip() == 'end: independent'):
                b = BRANCH.match(lines[j])
                if b:
                    decls.setdefault(b.group(1), i)
                j += 1
            i = j + 1
            continue
        t = TYPED_DECL.match(line)
        if t:
            decls.setdefault(t.group(1), i)
        else:
            n = NAMED_HEAD.match(line)
            if n and n.group(1) not in RESERVED:
                decls.setdefault(n.group(1), i)
            b = BRANCH.match(line)
            if b:
                decls.setdefault(b.group(1), i)
        i += 1
    found = []
    callables = {name for name, _, _ in methods}
    for name, start, end in methods:
        if name == 'main':
            continue
        used = set()
        for k in range(start, end):
            used |= words(lines[k])
        for w in sorted(used):
            if w in decls and w not in callables and decls[w] > start:
                found.append((name, w, start + 1, decls[w] + 1))
    return found


def process(path, check):
    raw = open(path, 'rb').read()
    bom = raw.startswith(b'\xef\xbb\xbf')
    text = raw[3:].decode('utf-8') if bom else raw.decode('utf-8')
    lines, eol, final = split_lines(text)
    forward = visibility(lines)
    new, status, detail = rewrite(lines)
    if status == 'rewritten' and not check:
        out = eol.join(new) + (eol if final else '')
        data = out.encode('utf-8')
        if bom:
            data = b'\xef\xbb\xbf' + data
        with open(path, 'wb') as fh:
            fh.write(data)
    return status, detail, forward


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('--check', action='store_true', help='report only; write nothing')
    ap.add_argument('dirs', nargs='+', help='directories whose *.lm2 files are migrated')
    a = ap.parse_args(argv)
    counts = {'rewritten': 0, 'nomain': 0, 'refused': 0}
    refused = []
    forwards = []
    for d in a.dirs:
        if not os.path.isdir(d):
            print('l2_s2_migrate_main: not a directory: ' + d, file=sys.stderr)
            return 2
        for name in sorted(os.listdir(d)):
            if not name.endswith('.lm2'):
                continue
            path = os.path.join(d, name)
            status, detail, forward = process(path, a.check)
            counts[status] += 1
            if status == 'refused':
                refused.append((path, detail))
            for f in forward:
                forwards.append((path,) + f)
    verb = 'would rewrite' if a.check else 'rewrote'
    print('l2_s2_migrate_main: %s %d, without main %d, refused %d'
          % (verb, counts['rewritten'], counts['nomain'], counts['refused']))
    for path, detail in refused:
        print('REFUSED %s: %s' % (path.replace(os.sep, '/'), detail))
    # Not rewritten automatically: moving a declaration changes the unit's lexical order.
    print('l2_s2_migrate_main: forward uses of non-callables by methods: %d' % len(forwards))
    for path, method, name, mline, dline in forwards:
        print('FORWARD %s: method %s (line %d) names %s declared at line %d' % (path.replace(os.sep, '/'), method, mline, name, dline))
    return 1 if refused or forwards else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))

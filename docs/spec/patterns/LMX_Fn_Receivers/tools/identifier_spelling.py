"""Exact identifier spelling for source inventories, not an LMX parser."""
import re

BARE = r'[A-Za-z_]\w*'
QUOTED = r'`(?:[^`\x00]|``)*`'
IDENT = rf'(?:{BARE}|{QUOTED})'
QUALIFIED = rf'{IDENT}(?:\\{IDENT})*'


def decode(name):
    if not re.fullmatch(IDENT, name):
        raise ValueError('invalid identifier spelling: ' + repr(name))
    return name[1:-1].replace('``', '`') if name.startswith('`') else name


def spell(name):
    if '\x00' in name:
        raise ValueError('NUL in identifier')
    return name if re.fullmatch(BARE, name) else '`' + name.replace('`', '``') + '`'


def path_parts(path):
    if not re.fullmatch(QUALIFIED, path):
        raise ValueError('invalid identifier path: ' + repr(path))
    return [spell(decode(m.group())) for m in re.finditer(IDENT, path)]


def canonical_path(path):
    return '\\'.join(path_parts(path))


def markdown_code(text):
    """Quote displayed LMX including any lexical backticks without nesting."""
    longest = max((len(m.group()) for m in re.finditer(r'`+', text)), default=0)
    delimiter = '`' * (longest + 1)
    padding = ' ' if text.startswith('`') or text.endswith('`') else ''
    return delimiter + padding + text + padding + delimiter

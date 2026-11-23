"""Resolve canonical operation families and exact top-level source bodies."""
from pathlib import Path
import json
import re


def definitions(library):
    result = {}
    for path in sorted((Path(library) / 'src').rglob('*.lmx')):
        text = path.read_text()
        starts = list(re.finditer(r'^(?:independent:\s*)?([A-Za-z_][A-Za-z0-9_]*)\s*(?:::|:)', text, re.M))
        for pos, match in enumerate(starts):
            name = match[1]
            stop = starts[pos + 1].start() if pos + 1 < len(starts) else len(text)
            body = text[match.start():stop].splitlines()
            while body and (not body[-1].strip() or body[-1].lstrip().startswith('#')):
                body.pop()
            if name in {'fun', 'const'}:
                continue
            if name in result:
                raise ValueError('Duplicate canonical definition: ' + name)
            result[name] = {'code':'\n'.join(body).strip()+'\n', 'source':path.relative_to(library).as_posix()}
    return result


def selected_operations(library, families=None):
    families = families or {}
    result = {}
    for entry in json.loads((Path(library) / 'catalog.json').read_text()):
        name = entry['name']
        family = families.get(name)
        if family is None:
            result[name] = entry
            continue
        variants = [v for v in entry.get('variants', []) if v['family'].casefold() == family.casefold()]
        if len(variants) != 1:
            raise ValueError(f'{name}: expected exactly one {family} variant')
        result[name] = dict(entry, **variants[0])
    return result


def public_roots(library, available, families=None):
    operations = selected_operations(library, families)
    roots = {name:entry['api'].split('\\')[0] for name,entry in operations.items()}
    missing = {name:root for name,root in roots.items() if root not in available}
    if missing:
        raise ValueError('Unresolved canonical public definitions: ' + str(missing))
    return roots

"""Read the library's written owner DATA for build-time catalogue metadata.

This is a structural inventory of the library's declaration style, not a type
analyzer or an LMX executor. Only owner-level declarations and declarations
under DATA modifiers are visited. A method or a nested named Structure is a
separate subtree: its local declarations never become the owner's inputs.
Explicit copy sources remain source references; this module does not expand
field streams or infer a complete callable signature from their spelling.
"""
import re

from sync_effects import mask


MODIFIERS = {'private', 'public', 'const', 'immutable', 'independent', 'required'}
NON_INPUTS = {
    'return', 'required', 'throws', 'throw', 'catch', 'if', 'else', 'while',
    'for', 'break', 'continue', 'yield', 'test', 'end', 'import', 'merge',
}


def owner_data(text):
    """Return written input/copy/return metadata, independent of method order."""
    raw = text.splitlines()
    clean = mask(text, keep_identifiers=True).splitlines()
    if not raw or clean[0].startswith(' ') or ':' not in clean[0]:
        raise ValueError('expected one top-level owner declaration')
    inputs, copies, results, required = [], [], [], []

    def children(start, end, indent):
        positions = []
        for i in range(start, end):
            line = clean[i]
            if not line.strip():
                continue
            depth = len(line) - len(line.lstrip())
            if depth < indent:
                raise ValueError('unexpected parent boundary inside owner DATA')
            if depth == indent:
                positions.append(i)
        return [(i, positions[n + 1] if n + 1 < len(positions) else end)
                for n, i in enumerate(positions)]

    def entry(i, end, declaration, constant=False, original=None):
        """Visit one immediate field; never recurse into an arbitrary head."""
        original = raw[i].strip() if original is None else original
        written = declaration.strip()
        code = mask(written, keep_identifiers=True).strip()
        if re.match(r'^copy\s*(?::|\()', code):
            copies.append(original)
            return raw[i:end]
        match = re.match(r'^([^:]+):\s*(.*)$', code)
        if not match:
            # Separators and nondeclaration forms do not describe input places.
            return []
        head, tail = match.group(1).strip(), match.group(2).strip()
        if head in MODIFIERS:
            if tail:
                if head == 'required' and ':' not in tail:
                    required.append(re.search(r'\brequired:\s*(.*)$', raw[i])[1])
                    return raw[i:end]
                # Keep the authored outer spelling in the input/copy entry.
                return entry(i, end, written.split(':', 1)[1],
                             constant or head == 'const', original)
            nested = []
            depth = len(clean[i]) - len(clean[i].lstrip())
            for begin, stop in children(i + 1, end, depth + 4):
                nested.extend(entry(begin, stop, raw[begin].strip(),
                                    constant or head == 'const'))
            return [raw[i]] + nested if nested else []
        if head == 'return':
            value = written.split(':', 1)[1].strip()
            if not value:
                value = '\n'.join(raw[i + 1:end]).rstrip()
            results.append(value)
            return raw[i:end]
        if head in NON_INPUTS:
            return []
        if not tail:
            # An ordinary named subtree is not an owner's input declaration.
            # In particular, this excludes the whole CODE of every sibling
            # method, including methods preceding the selected public one.
            return []
        if not constant:
            inputs.append(original)
        return raw[i:end]

    selected = [raw[0]]
    for start, end in children(1, len(raw), 4):
        selected.extend(entry(start, end, raw[start].strip()))
    return {
        'declared_inputs': inputs,
        'declaration_copies': copies,
        'required': required,
        'result_declaration': results[-1] if results else
                              'inherited via declaration_copies' if copies else 'void',
        'source_declaration': '\n'.join(selected).rstrip(),
    }

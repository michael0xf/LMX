"""Classify every parent168 -> current169 L1 change of the historical controls.

Each changed (fixture, mode) pair must be explained by these classes; any
other removed or added line is reported and fails the run:
  publication  an own-field publication block before c.sizeof (an operator,
               not a call: semantics publication boundary, origin 21.6)
  inert        a retained sizeof/c.sizeof operand: its value-read nodes (OP_OWN,
               OP_AT, OP_ARG with the entry slot and their child links) become
               one inert source symbol
  boxing       an eager int temporary of a c.sizeof actual (l2_tN: value)
Generated numbers (l2_rwN, l2_rwpN, l2_tN, l2_source_textN, l2_cvN, l2_nvN) are erased
before the comparison: a removed node renumbers everything after it.
Usage: classify-l1.py <controls dir> <out json>
"""
import difflib, json, os, re, sys

def drop_publish(lines):
    out, i, removed = [], 0, 0
    while i < len(lines):
        m = re.match(r'^(\s*)if: (l2_q\d+)_dirty != 0$', lines[i])
        if m:
            ind, q = m.group(1), m.group(2)
            j = i + 1
            while j < len(lines) and lines[j] != ind + '    ' + q + '_dirty: 0':
                j += 1
            if j < len(lines):
                k = j + 1
                if k < len(lines) and lines[k] == ind + '---':
                    k += 1
                removed += 1
                i = k
                continue
        out.append(lines[i])
        i += 1
    return out, removed

def erase(lines):
    return [re.sub(r'\b(l2_rwp|l2_rw|l2_t|l2_source_text|l2_cv|l2_nv)\d+\b', r'\1#', ln) for ln in lines]

R = r'l2_rw#'
INERT_OLD = [r'^@: Lmx ' + R + r' lmx_walk_frame_profiled\(l2_program_arena, l2_rw_roles, ' + R + r', c\.LMX_WALK_OP_(OWN|AT|ARG), \d+U, ',
             r'^if: ' + R + r' = 0$', r'^return: 1$',
             r'^if: lmx_arena_ref_store\(' + R + r', 1U, \(cast: \(@: void\) l2_(sc\d+|entry_unit)\)\) != 0 \|\| lmx_walk_store_size\(l2_program_arena, ' + R + r', 2U, \dU\) != c\.LMX_WALK_OK$',
             r'^if: lmx_walk_source_mark\(l2_program_arena, l2_rw_roles, ' + R + r', c\.LMX_WALK_SOURCE_ARG_ENTRY\) != 0$',
             r'^l2_entry_slot: lmx_arena_ref_cell\(' + R + r', 3U\)$', r'^if: l2_entry_slot = 0$',
             r'^l2_entry_slot\[0\]: lmx_\w+_new_profiled\(l2_program_arena, lmx_range_profile\(l2_program_arena, \(cast: \(@: void\) l2_entry_slot\)\)\)$',
             r'^if: l2_entry_slot\[0\] = 0$',
             r'^if: lmx_walk_store_size\(l2_program_arena, ' + R + r', 1U, 0U\) != c\.LMX_WALK_OK$',
             r'^if: lmx_arena_ref_store\(' + R + r', 2U, \(cast: \(@: void\) ' + R + r'\)\) != 0$']
INERT_NEW = [r'^@: void ' + R + r' 0$',
             r'^' + R + r': lmx_arena_take_profiled\(l2_program_arena, c\.sizeof\(c\.char\), c\.LMX_KIND_SOURCE_SYMBOL, c\.LMX_TYPE_SOURCE_SYMBOL, lmx_range_profile\(l2_program_arena, \(cast: \(@: void\) ' + R + r'\)\)\)$',
             r'^if: ' + R + r' = 0$', r'^return: 1$',
             r'^memset\(\(cast: \(@: void\) ' + R + r'\), 0, c\.sizeof\(c\.char\)\)$',
             r'^if: lmx_source_name_set\(l2_program_arena, \(cast: \(@: void\) ' + R + r'\), "[A-Za-z_][A-Za-z_0-9]*", \d+U\) != 0$']
BOX_OLD = [r'^int: l2_t#$', r'^l2_t#: l2_q\d+$', r'^return: c\.sizeof\(l2_t#\)$']
BOX_NEW = [r'^return: c\.sizeof\(l2_q\d+\)$']

def kind(line, groups):
    body = line.strip()
    for name, pats in groups:
        if any(re.search(p, body) for p in pats):
            return name
    return None

def classify(a, b):
    pa, ra = drop_publish(open(a, encoding='utf-8').read().split('\n'))
    pb, rb = drop_publish(open(b, encoding='utf-8').read().split('\n'))
    na, nb = erase(pa), erase(pb)
    removed, added = [], []
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(None, na, nb, autojunk=False).get_opcodes():
        if tag != 'equal':
            removed += na[i1:i2]
            added += nb[j1:j2]
    unexplained = ['-' + l for l in removed if kind(l, [('inert', INERT_OLD), ('boxing', BOX_OLD)]) is None]
    unexplained += ['+' + l for l in added if kind(l, [('inert', INERT_NEW), ('boxing', BOX_NEW)]) is None]
    symbols = sum(1 for l in added if 'LMX_KIND_SOURCE_SYMBOL' in l)
    reads = sum(1 for l in removed if re.search(r'c\.LMX_WALK_OP_(OWN|AT|ARG), ', l))
    return {'PublicationBlocksParent': ra, 'PublicationBlocksCurrent': rb, 'PublicationRemoved': ra - rb,
            'InertSymbols': symbols, 'RemovedValueReads': reads,
            'BoxingRemoved': sum(1 for l in removed if l.strip() == 'int: l2_t#'),
            'RemovedLines': len(removed), 'AddedLines': len(added), 'Unexplained': unexplained}

controls, target = sys.argv[1], sys.argv[2]
routes = json.load(open(os.path.join(controls, 'routes.json'), encoding='utf-8-sig'))
rows = []
for r in routes:
    if r['Tier'] != 'parent168' or not r['L1Sha256']:
        continue
    twin = [x for x in routes if x['Case'] == r['Case'] and x['Mode'] == r['Mode'] and x['Tier'] == 'current169']
    if len(twin) != 1 or not twin[0]['L1Sha256']:
        continue
    row = {'Case': r['Case'], 'Mode': r['Mode'], 'Identical': r['L1Sha256'] == twin[0]['L1Sha256'],
           'ParentL1Sha256': r['L1Sha256'], 'CurrentL1Sha256': twin[0]['L1Sha256']}
    if not row['Identical']:
        row.update(classify(os.path.join(controls, '%s-parent168-%s.lm1' % (r['Case'], r['Mode'])),
                            os.path.join(controls, '%s-current169-%s.lm1' % (r['Case'], r['Mode']))))
        if row['RemovedLines'] + row['AddedLines'] and not (row['InertSymbols'] or row['BoxingRemoved']) and row['RemovedLines'] + row['AddedLines'] > 0:
            row['Unexplained'].append('a change without an inert symbol or removed boxing')
        if row['InertSymbols'] > row['RemovedValueReads']:
            row['Unexplained'].append('an inert symbol that replaces no value read')
    rows.append(row)
with open(target, 'w', encoding='utf-8', newline='\n') as f:
    json.dump(rows, f, indent=1)
    f.write('\n')
for r in rows:
    print('%-32s %-6s %s' % (r['Case'], r['Mode'], 'identical' if r['Identical'] else
          'publication-%d inert-%d/%d boxing-%d lines-%d/%d unexplained-%d' % (r['PublicationRemoved'], r['InertSymbols'], r['RemovedValueReads'], r['BoxingRemoved'], r['RemovedLines'], r['AddedLines'], len(r['Unexplained']))))
bad = [r for r in rows if r.get('Unexplained')]
for r in bad:
    print('UNEXPLAINED', r['Case'], r['Mode'])
    for l in r['Unexplained'][:40]:
        print('   ', l)
if bad or not rows:
    sys.exit(1)
print('CLASSIFY169 every changed L1 line is a publication block, an inert operand or removed boxing')

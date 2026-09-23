"""FABLE-SONNET-OWN-LOOKUP-AUDIT-20260923-131 part 1.

Inventories every own-field read/write emission site in
dev/l2src_sandbox/l2trans.lm1 and classifies which resolver it uses. Purely
mechanical (line/function/resolver), no semantic "agrees/disagrees"
judgment -- that is a separate, per-site analysis reported alongside this
script's output, not automated here (see the ticket's RESULT for the
compiled table).

Usage: python tools/own_lookup_audit.py [path/to/l2trans.lm1]
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / 'dev' / 'l2src_sandbox' / 'l2trans.lm1'

# Named own-field resolvers: a call site using one of these is understood to
# be resolving a source name to an own-field row or a path root through the
# function whose own correctness this ticket's D1/D2/-129 history already
# scrutinized once each, separately. New/undiscovered call sites of these
# are LOW risk by construction (they inherit whatever that function's own
# fallback behavior is); the audit is about whether all of them, and
# everything NOT on this list, actually agree.
RESOLVERS = [
    'l2_own_find', 'l2_own_find_last', 'l2_own_find_decl', 'l2_own_find_occ',
    'l2_own_find_host', 'l2_own_any', 'l2_own_first',
    'l2_path_root', 'l2_own_seg_scan', 'l2_e_own_seg', 'l2_for_own_seg',
    'l2_field_path_check', 'l2_field_path_read',
    'l2_formal_find', 'l2_param_find', 'l2_tok_formal',
    'l2_slot_find', 'l2_ns_slot_named', 'l2_mrs_slot_named',
]

# Direct low-level cell/struct access: the primitive the resolvers
# themselves are built on. A call to one of these OUTSIDE a resolver (or a
# resolver's own small helper layer) is a name-to-cell path that bypasses
# every named resolver above -- exactly the shape D2's direct
# lmx_pointer_store_known call had. Not inherently wrong (own_ctr/
# emit_own_from/emit_occ_write are exactly this, already reviewed, reused
# pervasively) but every site needs a look.
DIRECT_CELL_FNS = ['lmx_arena_ref_cell', 'lmx_arena_ref_struct']

# The established helper layer built directly on DIRECT_CELL_FNS, already
# reviewed as part of this ticket's own D1/D2/-129 history or pre-existing
# and pervasively reused. Sites INSIDE these are not re-flagged as raw
# ad-hoc uses; sites everywhere else calling DIRECT_CELL_FNS are.
KNOWN_CELL_HELPERS = {
    'l2_own_ctr', 'l2_emit_own_from', 'l2_emit_finalize_old',
    'l2_emit_occ_write', 'l2_emit_path', 'l2_emit_cell_load',
    'l2_emit_bind_mark', 'l2_emit_addr_mark', 'l2_first_own_child',
}

FN_DEF_RE = re.compile(r'^fn:\s+(\S+)\s*\(')


def load_lines(path):
    return path.read_text(encoding='utf-8-sig').splitlines()


def function_spans(lines):
    """Return [(name, start_line_1based, end_line_1based_inclusive)] for
    every top-level `fn: name (...)` definition, in source order. A
    function's body is taken to run up to (not including) the next
    top-level `fn:` line, matching this file's consistent one-function-per-
    top-level-block style."""
    starts = []
    for i, line in enumerate(lines, start=1):
        m = FN_DEF_RE.match(line)
        if m:
            starts.append((m.group(1), i))
    spans = []
    for idx, (name, start) in enumerate(starts):
        end = starts[idx + 1][1] - 1 if idx + 1 < len(starts) else len(lines)
        spans.append((name, start, end))
    return spans


def enclosing_function(spans, line_no):
    for name, start, end in spans:
        if start <= line_no <= end:
            return name
    return None


def find_calls(lines, fn_name):
    """Call sites of fn_name(...), excluding its own `fn: fn_name (` def
    line. A call is any occurrence of `fn_name(` not immediately preceded
    by `fn: `."""
    pattern = re.compile(r'(?<![A-Za-z0-9_])' + re.escape(fn_name) + r'\(')
    hits = []
    for i, line in enumerate(lines, start=1):
        stripped = line.lstrip()
        if stripped.startswith('fn: ' + fn_name + ' ') or stripped.startswith('fn: ' + fn_name + '('):
            continue
        for m in pattern.finditer(line):
            hits.append((i, line.strip()))
    return hits


def main(argv):
    source = Path(argv[1]) if len(argv) > 1 else DEFAULT_SOURCE
    lines = load_lines(source)
    spans = function_spans(lines)
    print(f'own_lookup_audit: {source} ({len(lines)} lines, {len(spans)} top-level fn: blocks)')
    print()

    print('== resolver call sites ==')
    total_calls = 0
    for resolver in RESOLVERS:
        hits = find_calls(lines, resolver)
        if not hits:
            continue
        total_calls += len(hits)
        print(f'-- {resolver}: {len(hits)} call site(s)')
        for line_no, text in hits:
            caller = enclosing_function(spans, line_no) or '(top level)'
            print(f'   :{line_no} in {caller}: {text[:140]}')
    print(f'total resolver call sites: {total_calls}')
    print()

    print('== direct cell/struct access outside the known helper layer ==')
    total_direct = 0
    for fn_name in DIRECT_CELL_FNS:
        hits = find_calls(lines, fn_name)
        for line_no, text in hits:
            caller = enclosing_function(spans, line_no) or '(top level)'
            if caller in KNOWN_CELL_HELPERS:
                continue
            total_direct += 1
            print(f'   :{line_no} in {caller} calls {fn_name}: {text[:140]}')
    print(f'total direct (non-helper-layer) cell/struct access sites: {total_direct}')
    print()

    print('== known helper layer (reviewed, not re-flagged) ==')
    for helper in sorted(KNOWN_CELL_HELPERS):
        present = any(name == helper for name, _, _ in spans)
        print(f'   {helper}: {"defined" if present else "NOT FOUND -- update KNOWN_CELL_HELPERS"}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
